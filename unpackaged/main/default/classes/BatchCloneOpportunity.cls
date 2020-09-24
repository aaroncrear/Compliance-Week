/**
 * Class to clone opportunity with product automatically 90 days before a Subscription Expiration Date.
 * Create Date : 02/01/2013
 */
global class BatchCloneOpportunity implements Database.Batchable<sObject>{
    public static final String TYPE_SINGLE = 'Single';
    public static final String RENEWAL_TYPE = 'Renewal';
    public static final String STAGE_PROPOSAL = 'Proposal/Price Quote';
    public static final String SUBSCRIPTIONRECORDTYPE = 'Subscriptions_Opportunity';
    public static final String OPP_TYPE = 'Subscription';
    public String id ; 
    public Boolean isButton = false; 
    
    public BatchCloneOpportunity(String id, Boolean isButton){
        this.id = id;
        this.isButton = isButton;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Date next90Day = System.today().addDays(90);
        String CheckDate = ' =: next90Day';
        if(isButton) CheckDate = ' = NEXT_90_DAYS';
        return Database.getQueryLocator('Select ListPrice , Renewal_Rate__c,Contact__c,PricebookEntryId,Legacy_SalesforceID__c,Quantity,Expiry_Date__c, Description, ServiceDate, '+
            'Subscription__r.Type__c, Subscription__r.Name , Subscription__r.Renewal_Opportunity__c, Subscription__r.Expiration_Date__c, Subscription__r.Start_Date__c, '+
            'Subscription__r.Renewal_Opportunity__r.Business_Type__c,Subscription__r.Renewal_Rate__c, PricebookEntry.Product2.Max_Users__c, PricebookEntry.Product2.Duration_Days__c, Subscription__c, OpportunityId '+
            'From OpportunityLineItem '+
            'Where Subscription__c!= null and Subscription__r.Expiration_Date__c != null and '+
            'Subscription__r.Expiration_Date__c '+CheckDate+' '+(!isEmpty(id)?'and OpportunityId =: id':''));
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        Set<String> sOppID = new Set<String>();
        Map<String,Date> mapOppWithExpiredDate = new Map<String,Date>();
        List<OpportunityLineItem> lstOppLines = new List<OpportunityLineItem>();
        Map<String,String> mapOppSub = new Map<String,String>();
        Map<Id, OpportunityContactRole> mapOppConRol = new Map<Id, OpportunityContactRole>();

        for(Sobject s : scope){
            OpportunityLineItem oppLine = (OpportunityLineItem) s;
            //for avoid duplicate clone the same opportunity and opp line
            if(oppLine.Subscription__r.Renewal_Opportunity__c != null && oppLine.Subscription__r.Renewal_Opportunity__r.Business_Type__c == RENEWAL_TYPE) continue;
            sOppID.add(oppLine.OpportunityId);
            mapOppSub.put(oppLine.OpportunityId,oppLine.Subscription__r.Name);
            mapOppWithExpiredDate.put(oppLine.OpportunityId,oppLine.Subscription__r.Expiration_Date__c);
            lstOppLines.add(oppLine);
        }
        //clone Opportunity with business type = 'Renewal', close date = subscription expired date, 
        //opportunity name always update to "Current year + 'Renewal'" , and stage name = 'Proposal/Price Quote'
        RecordType recordType = [select id from RecordType where DeveloperName =: SUBSCRIPTIONRECORDTYPE];
        List<Opportunity> lstOpp = new List<Opportunity>();
        Map<String,Opportunity> mapOpp = new Map<String, Opportunity>();
        AssignRenewalOpptoCustomerService__c cs = AssignRenewalOpptoCustomerService__c.getValues('Assign Renewal to User ID');

        for(Opportunity opp : [select Account.Name, Owner.IsActive,OwnerId, Type,AccountId, RecordTypeId, Origination__c,Name,StageName,Business_Type__c,CloseDate, (select OpportunityId, ContactId, Role, IsPrimary from OpportunityContactRoles) from Opportunity where id IN: sOppID]){//Database.query(getCreatableFieldsSOQL('Opportunity','Id IN: sOppID',''))){//[Select * From Opportunity where Id IN: sOppId]
            Opportunity oppClone = opp.clone(false, true);
            //check for activ user
            oppClone.OwnerId            = cs == null ? oppClone.OwnerId : cs.get('Renewal_Assignee__c')+'';
            //--check to replace year in opp name--//
            oppClone.Name               = opp.Account.Name+' - '+mapOppSub.get(opp.Id)+' - '+System.today().year()+' Renewal'; 
            oppClone.StageName          = STAGE_PROPOSAL;
            oppClone.Business_Type__c   = RENEWAL_TYPE;
            oppClone.CloseDate          = mapOppWithExpiredDate.get(opp.Id);
            oppClone.RecordTypeId       = recordType.Id;
            oppClone.Type               = OPP_TYPE;
            lstOpp.add(oppClone);
            mapOpp.put(opp.Id, oppClone);
            mapOppConRol.putAll(opp.OpportunityContactRoles);
        }

        if(!lstOpp.isEmpty()) insert lstOpp;

        //clone opportunity contact role
        List<OpportunityContactRole> ocrToCreate = new List<OpportunityContactRole>();
        for (OpportunityContactRole ocr : mapOppConRol.values()) {
            if(!mapOpp.containsKey(ocr.OpportunityId)) continue;
            ocrToCreate.add(new OpportunityContactRole(ContactId=ocr.ContactId, OpportunityId=mapOpp.get(ocr.OpportunityId).Id, Role=ocr.Role, IsPrimary=ocr.IsPrimary));
        }
        if (!ocrToCreate.isEmpty()) insert ocrToCreate;

        //clone opportunity product
        List<OpportunityLineItem> lstOppLine = new List<OpportunityLineItem>();
        List<Subscription_NEW__c> lstSub = new List<Subscription_NEW__c>();
        Map<String,String> mapSubOpp = new Map<String,String>();

        for(OpportunityLineItem oppLine : lstOppLines){
            if(!mapOpp.containsKey(oppLine.OpportunityId)) continue;
            OpportunityLineItem oppLineClone = oppLine.clone(false, true);
            oppLineClone.OpportunityId       = mapOpp.get(oppLine.OpportunityId).Id; 
             //-- clone unitPrice from old product if subscription type is single else zero--//
            oppLineClone.UnitPrice           = (oppLine.Subscription__r.Type__c == TYPE_SINGLE && oppLine.Subscription__r.Renewal_Rate__c != null?oppLine.Subscription__r.Renewal_Rate__c:0);
            //--start date = subscription expiredate--//
            oppLineClone.ServiceDate         = oppLine.Subscription__r.Expiration_Date__c;
            //--expiredate = product duration + start date--//
            Integer dateDuration = (oppLine.PricebookEntry.Product2.Duration_Days__c != null ? Integer.valueOF(oppLine.PricebookEntry.Product2.Duration_Days__c) : 0);
            oppLineClone.Expiry_Date__c      = oppLine.Subscription__r.Expiration_Date__c + dateDuration;
            oppLineClone.Subscription__c     = null;
            lstOppLine.add(oppLineClone);
            //update The expiring subscription look up to the renewal opportunity.
            if(mapSubOpp.containsKey(oppLine.Subscription__c)) continue;
            mapSubOpp.put(oppLine.Subscription__c, oppLineClone.OpportunityId);
        }
        if(!lstOppLine.isEmpty()) insert lstOppLine;
        if(mapSubOpp != null && !mapSubOpp.isEmpty()){
            for(String subId : mapSubOpp.keySet()){
                 lstSub.add(new Subscription_NEW__c(id = subId , Renewal_Opportunity__c = mapSubOpp.get(subId)));
            }
        }
        if(!lstSub.isEmpty()) update lstSub;
    }

    global void finish(Database.BatchableContext BC){

    }
    
    /**
     * For testing only
     */
     
    public static final String QUEUED_STATUS='Queued'; 
    public static final String PROCESSING_STATUS='Processing';
    public static final String PREPARING_STATUS='Preparing';
    
    /**
     * Check is full batch in process
     */
    public static Boolean isFullBatchInProcess(){
        return 5 == [Select count() From AsyncApexJob a where Status=:QUEUED_STATUS OR Status=:PROCESSING_STATUS OR Status=:PREPARING_STATUS];
       
   }    
   
   /**
    * Check is current batch in process
    */
    public static Boolean isBatchInProcess(String className){
        List<AsyncApexJob> jobs = [Select a.Status,a.ApexClass.Name, a.MethodName, a.JobType, a.ApexClassId From AsyncApexJob a where Status=:QUEUED_STATUS OR Status=:PROCESSING_STATUS OR Status=:PREPARING_STATUS];
        for(AsyncApexJob job: jobs) {
            if(job.ApexClass.Name == className) return true;
        }
        return false;
   }
   
   /**
    * Check is empty string
    */
    public static Boolean isEmpty(String val) {
        return null == val || '' == val || '--None--'==val || 'null'==val;
    }
    
    /**
     * Webservice methode for testing
     */   
    webservice static Boolean cloneOpportunity(String id) {
        if(isFullBatchInProcess() || isBatchInProcess('BatchCloneOpportunity')) return false;
        Date next90Day = System.today().addDays(90);
        String query = 'Select ListPrice , Renewal_Rate__c,Contact__c,PricebookEntryId,Legacy_SalesforceID__c,Quantity,Expiry_Date__c, Description, ServiceDate, '+
                        'Subscription__r.Type__c, Subscription__r.Renewal_Opportunity__c, Subscription__r.Expiration_Date__c, Subscription__r.Start_Date__c, '+
                        'Subscription__r.Renewal_Rate__c, PricebookEntry.Product2.Max_Users__c, PricebookEntry.Product2.Duration_Days__c, Subscription__c, OpportunityId '+
                        'From OpportunityLineItem '+
                        'where Subscription__c!= null and Subscription__r.Expiration_Date__c != null and '+
                        'Subscription__r.Expiration_Date__c = NEXT_90_DAYS '+(!isEmpty(id)?'and OpportunityId =: id':'');
        List<OpportunityLineItem> oplines = Database.query(query);
        if(oplines.isEmpty()) return false;
        BatchCloneOpportunity batch = new BatchCloneOpportunity(id, true);
        database.executeBatch(batch);
        return true;
    }       
        
}