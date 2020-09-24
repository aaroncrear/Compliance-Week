/**
  * 1/ Trigger to create Subscription_NEW__c for each product when an Opportunity is Closed Won , businessUnit = 'Compliance Week', product family = 'Subscriptions'
  * Additional requirement:
  * 2/ Trigger on Opportunity to create another opportunity with product when opportunity is Close Lost and Lost Reason = Renewal Opportunity Expired
    We would like another Opportunity to be created if this rule fires. The Opportunity will copy the Closed Lost Renewal with Products and the following changes:
    - Business Type = Recapture
    - Close Date = Created Date + 30days
    - Stage = Follow Up, Interested
    - Probability = 50
    Some amendments on Recapture Opportunity:
    - Sales Price = Renewal Rate On Opportunity Product
    - Close Date = Created Date + 150
    - I will create a lookup field on subscription 'Recapture Opportunity'. Please link Recapture opportunity to old subscription when it is created.
    - recaptured = true
  * 3/ When a Renewal Opportunity is Closed Won, the Product Minimum users should be compared to Minimum Users on existing subscription. 
        If Product Minimum Users > existing Subscription Minimum Users, update Upgraded = TRUE
        If Product Minimum Users < existing Subscription Minimum Users, update downgraded = TRUE
  * 4/ trigger on oppportunity to update the expired date of existing subscription to TODAY when upgrade opportuity is closed won
   
    Change request point 4: 
    trigger on oppportunity to update the expired date of existing subscription to new product start date when upgrade opportuity is closed won
    Currently when Upgrade button is clicked the Upgrade checkbox is populated automatically. It should only be updated if the Upgrade Opportunity is Closed Won.
    
  * 5/ Trigger on Opportunity to update subscription When opportunity is close won
    - Update 1:
        When an Opportunity with Business Type = Recapture is Closed Won and new Subscription Type = Single, check the Contact for any Subscriptions with Type = Single and Expiration Date < (TODAY - 30). 
        If a record is found, update the Subscription with highest Expiration Date as Recaptured = TRUE.
        If no match is found, search same criteria except Type = Multi. If a matching record is found, update old subscription as Downgraded = TRUE and Recaptured = TRUE.
    - Update 2:
        When an Opportunity with Business Type = Recapture is Closed Won and new Subscription Type = Multi, check the Account for any Subscriptions with Type = Multi and Expiration Date < (TODAY - 30). 
        If a record is found, update the Subscription with the highest Expiration Date as Recaptured = TRUE. 
        If minimum users on matched record is < minimum users on new Subscription, update Upgraded = TRUE on matched record (old subscription).
        If minimum users on matched record is > minimum users on new Subscription, update Downgraded = TRUE on matched record (old subscription).
        If no match is found, search same criteria except Type = Single. Execute same actions.
    
    Change request on point 5:
    
    An update on priority 5 - I believe we have overcomplicated this. Since original specification we have added a Lookup field 
      (Recapture Opportunity) on Subscription, which is populated when the recapture opportunity is created. 
      That means the relationship exists to the correct subscription to be updated, so the criteria to search for subscription to 
      update is not necessary.
    The only thing required is to compare no. of users, the same as with upgrade opportunities, and update Upgrade or Downgrade 
      checkboxes accordingly. Recapture checkbox should also be updated as TRUE when the recapture opportunity is Closed Won - currently 
      it is updated when the opportunity is created.
    Please note: 'Opportunity Business Unit = Compliance Week' should be used as additional criteria on all of the above items.
  * Create date: 31/12/2013
  */
trigger OpportunityTrigger on Opportunity (after update) {
    final String TYPE_SINGLE            = 'Single';
    final String TYPE_MULTI             = 'Multi';
    final String STAGE_CLOSEWON         = 'Closed Won';
    final String STAGE_CLOSELOST        = 'Closed Lost';
    final String STAGE_FOLLOWUP         = 'Follow-up, Interested';
    final String LOST_REASON            = 'Renewal Opportunity Expired';
    final String BUSINESSUNIT           = 'Compliance Week';
    final String PRODUCTFAMILLY_SUBSCRIPTION= 'Subscriptions';
    final String BUSINESSTYPE_RECAPTURE = 'Recapture';
    final String BUSINESSTYPE_UPGRADE   = 'Upgrade';
    final String BUSINESSTYPE_RENEWAL   = 'Renewal';
    final String BUSINESSTYPE_RENEWAL_UPGRADE   ='Renewal Upgrade';
        Map<String,Opportunity> mapOpp = new Map<String,Opportunity>();
        Set<String> sOppClosedLost = new Set<String>();
        Set<String> sOppRenewal    = new Set<String>();
        Set<String> sOppUpgrade    = new Set<String>();
        Set<String> sOppRecapture  = new Set<String>();
        for(Opportunity opp : Trigger.new){
            if(opp.Business_Unit__c == BUSINESSUNIT){
                if(opp.StageName == STAGE_CLOSEWON) {
                    mapOpp.put(opp.Id,opp);
                    if(opp.Business_Type__c.equalsIgnoreCase(BUSINESSTYPE_RENEWAL)) sOppRenewal.add(opp.Id);
                    else if(opp.Business_Type__c.equalsIgnoreCase(BUSINESSTYPE_UPGRADE)) sOppUpgrade.add(opp.Id);
                    else if(opp.Business_Type__c.equalsIgnoreCase(BUSINESSTYPE_RECAPTURE)) sOppRecapture.add(opp.Id);
                }
                else if (opp.StageName == STAGE_CLOSELOST && opp.Lost_Reason__c == LOST_REASON){
                    sOppClosedLost.add(opp.id);
                }
            }
        }
        //check for subscription name for "point 2:"
        Map<String,String> mapOppSub = new Map<String,String>();
        for(Subscription_NEW__c subScription : [Select Renewal_Opportunity__c, Name From Subscription_NEW__c s where Renewal_Opportunity__c IN: sOppClosedLost]){
            mapOppSub.put(subScription.Renewal_Opportunity__c,subScription.Name);
        }
        //-- Point 2 : Clone opp --//
        List<Opportunity> lstOppClone = new List<Opportunity>();
        Map<String,Opportunity> mapAfterClone = new Map<String,Opportunity>();
        for(Opportunity opp : [select OwnerId, id, Type,Account.Name , AccountId, RecordTypeId, Origination__c, Name, CreatedDate from Opportunity where id IN: sOppClosedLost]){
            Opportunity oppClone = opp.clone(false, true);
                    oppClone.Name               = opp.Account.Name+(mapOppSub.containsKey(opp.Id)?' - '+mapOppSub.get(opp.Id):'')+' - Recapture';
                    oppClone.StageName          = STAGE_FOLLOWUP;
                    oppClone.Business_Type__c   = BUSINESSTYPE_RECAPTURE;
                    oppClone.CloseDate          = date.newinstance(opp.CreatedDate.year(), opp.CreatedDate.month(), opp.CreatedDate.day()) + 150;
                    lstOppClone.add(oppClone);
                    mapAfterClone.put(opp.Id, oppClone);
        }
        if(!lstOppClone.isEmpty()) insert lstOppClone;
        
        List<Subscription_NEW__c> listSubScription = new List<Subscription_NEW__c >();
        Map<String,Subscription_NEW__c> mapLineSub = new Map<String,Subscription_NEW__c>();
        List<OpportunityLineItem> lstOppLineClone = new List<OpportunityLineItem>();
        Map<String,OpportunityLineItem> mapOppAndOppLine = new Map<String,OpportunityLineItem>();
        Map<String,OpportunityLineItem> mapOppAndOppLineForExptd = new Map<String,OpportunityLineItem>();
        Map<String,OpportunityLineItem> mapOppAndOppLineRecapture = new Map<String,OpportunityLineItem>();
        for(OpportunityLineItem oppLine : [select id,UnitPrice,Renewal_Rate__c,OpportunityId,Expiry_Date__c,Contact__c,PricebookEntryId,ServiceDate,PricebookEntry.Product2.Max_Users__c,
                                            PricebookEntry.Product2.Min_Users__c,PricebookEntry.Product2.Family,Subscription__c ,ListPrice,Legacy_SalesforceID__c,Quantity,Description
                                            from OpportunityLineItem 
                                            where OpportunityId IN: mapOpp.keySet() OR OpportunityId IN: sOppClosedLost]){
            //--Point 1 : Create new subscription for any opp line that not yet have look up to subscription --//
            if(mapOpp.containsKey(oppLine.OpportunityId)){
                //for update old subscription expired date to new product start date
                mapOppAndOppLineForExptd.put(oppLine.OpportunityId, oppLine);
                //create new sub
                if(oppLine.Subscription__c == null && oppLine.PricebookEntry.Product2.Family != null && oppLine.PricebookEntry.Product2.Family.equals(PRODUCTFAMILLY_SUBSCRIPTION)){
                    Opportunity opp = mapOpp.get(oppLine.OpportunityId);
                    Subscription_NEW__c subScription = new Subscription_NEW__c(Expiration_Date__c   = oppLine.Expiry_Date__c,
                                                                                Contact__c          = oppLine.Contact__c,
                                                                                Account__c          = opp.AccountId,
                                                                                Type__c             = (oppLine.PricebookEntry != null && oppLine.PricebookEntry.Product2 != null && (oppLine.PricebookEntry.Product2.Min_Users__c != null) ? (oppLine.PricebookEntry.Product2.Min_Users__c == 1?TYPE_SINGLE:TYPE_MULTI): null),
                                                                                Start_Date__c       = oppLine.ServiceDate,
                                                                                Amount__c           = oppLine.UnitPrice,
                                                                                Renewal_Rate__c     = oppLine.Renewal_Rate__c,
                                                                                Minimum_Users__c    = oppLine.PricebookEntry.Product2.Min_Users__c,
                                                                                Maximum_Users__c    = oppLine.PricebookEntry.Product2.Max_Users__c);
                    listSubScription.add(subScription);
                    //map new subscription fo update look up relationship on opp line
                    mapLineSub.put(oppLine.ID, subScription);
                }
            }
            //-- Point 2 :  Clone Opp line --//
            if(mapAfterClone.containsKey(oppLine.OpportunityId)){
                OpportunityLineItem oppLineClone = oppLine.clone(false, true);
                oppLineClone.OpportunityId       = mapAfterClone.get(oppLine.OpportunityId).Id;
                oppLineClone.Subscription__c     = null;
                oppLineClone.UnitPrice           = (oppLine.Renewal_Rate__c == null?0:oppLine.Renewal_Rate__c);
                lstOppLineClone.add(oppLineClone);
            }
            //-- Point 3 : Use for update existing subscription when renewal opporutnity is closed won--//
            if(sOppRenewal.contains(oppLine.OpportunityId))mapOppAndOppLine.put(oppLine.OpportunityId, oppLine);
            //-- Point 5 : Use for update existing subscription when recapture opporutnity is closed won--//
            if(sOppRecapture.contains(oppLine.OpportunityId)) mapOppAndOppLineRecapture.put(oppLine.OpportunityId,oppLine);
        }
        if(!listSubScription.isEmpty())insert listSubScription;
        if(!lstOppLineClone.isEmpty()) insert lstOppLineClone; 
        
        // Point 1 : update opportunity product to look up to subscription that just create
        List<OpportunityLineItem> listOppLineItem = new List<OpportunityLineItem>();
        if(!mapLineSub.isEmpty()){
            for(String oppLineID : mapLineSub.keySet()){
                listOppLineItem.add(new OpportunityLineItem(Id = oppLineID, Subscription__c = mapLineSub.get(oppLineID).ID));
            }
            if(!listOppLineItem.isEmpty()) update listOppLineItem;
        }
        //select the existing subscription 
        List<Subscription_NEW__c> lstSubs = new List<Subscription_NEW__c>();
        List<Opportunity> lstOpps         = new List<Opportunity>();
        for(Subscription_NEW__c subScription : [Select Renewal_Opportunity__c,Recapture_Opportunity__c ,s.Upgraded__c, s.Minimum_Users__c, s.Maximum_Users__c, s.Downgraded__c,Recaptured__c,Renewal_Opportunity__r.Business_Type__c, Expiration_Date__c From Subscription_NEW__c s 
                                                    where Renewal_Opportunity__c IN: mapOpp.keySet() OR Renewal_Opportunity__c IN: mapAfterClone.keySet()]){
            //when opportunity is close won update expired date of existing subscrption to new product start date
            if(mapOppAndOppLineForExptd.containsKey(subScription.Renewal_Opportunity__c)) {
                
                // if the new Product Start Date is < old Subscription Expiration Date, the Expiration Date should = Start Date.
                Date opli_startDate = mapOppAndOppLineForExptd.get(subScription.Renewal_Opportunity__c).ServiceDate;
                if(opli_startDate > subScription.Expiration_Date__c) continue;
                subScription.Expiration_Date__c = opli_startDate;
            }
            
            //-- Point 3 : update expired subscription(upgrade, downgrade) when renewal opporutnity is closed won--//
            if(mapOppAndOppLine.containsKey(subScription.Renewal_Opportunity__c)){
                OpportunityLineItem oppLine = mapOppAndOppLine.get(subScription.Renewal_Opportunity__c);
                if(oppLine.PricebookEntry.Product2.Min_Users__c > subScription.Minimum_Users__c) {
                    subScription.Upgraded__c = true;
                    subScription.Downgraded__c = false;
                    //if upgrade => update business type to "renewal upgrade"
                    lstOpps.add(new Opportunity(id=subScription.Renewal_Opportunity__c, Business_Type__c = BUSINESSTYPE_RENEWAL_UPGRADE));
                }
                else if(oppLine.PricebookEntry.Product2.Min_Users__c < subScription.Minimum_Users__c) {
                    subScription.Downgraded__c = true;
                    subScription.Upgraded__c = false;
                }
                else{
                    subScription.Upgraded__c = false;
                    subScription.Downgraded__c = false;
                }
            }
            
            //-- Point 4 : Upgrade true , if the Upgrade Opportunity is Closed Won.
            if(sOppUpgrade.contains(subScription.Renewal_Opportunity__c)) subScription.Upgraded__c = true;
            //-- Point 2 : link the existing subscription to recapture opportunity--//
            if(mapAfterClone.containsKey(subScription.Renewal_Opportunity__c)) {
                subScription.Recapture_Opportunity__c = mapAfterClone.get(subScription.Renewal_Opportunity__c).Id;
                //subScription.Recaptured__c = true;
            }
            lstSubs.add(subScription);
        }
        if(!lstOpps.isEmpty()) update lstOpps;
        if(!lstSubs.isEmpty()) update lstSubs;
        //-- Point 5 : update expired subscription(upgrade, downgrade) when recapture opporutnity is closed won--//
        List<Subscription_NEW__c> lstRecaputreSub = new List<Subscription_NEW__c>();
        for(Subscription_NEW__c subScription : [Select Renewal_Opportunity__c,Recapture_Opportunity__c ,s.Upgraded__c, s.Minimum_Users__c, s.Maximum_Users__c, s.Downgraded__c,Recaptured__c,Renewal_Opportunity__r.Business_Type__c, Expiration_Date__c From Subscription_NEW__c s 
                                                    where Recapture_Opportunity__c IN: sOppRecapture]){
            if(mapOppAndOppLineRecapture.containsKey(subScription.Recapture_Opportunity__c)){
                subScription.Recaptured__c = true;
                OpportunityLineItem oppLine = mapOppAndOppLineRecapture.get(subScription.Recapture_Opportunity__c);
                if(oppLine.PricebookEntry.Product2.Min_Users__c > subScription.Minimum_Users__c) {
                    subScription.Upgraded__c = true;
                    subScription.Downgraded__c = false;
                }
                else if(oppLine.PricebookEntry.Product2.Min_Users__c < subScription.Minimum_Users__c) {
                    subScription.Downgraded__c = true;
                    subScription.Upgraded__c = false;
                }
                else{
                    subScription.Upgraded__c = false;
                    subScription.Downgraded__c = false;
                }
                lstRecaputreSub.add(subScription);
            }
        }
        if(!lstRecaputreSub.isEmpty()) update lstRecaputreSub;
}