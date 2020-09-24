/**
 * Class to test batch clone opportunity with product automatically 90 days before a Subscription Expiration Date.
 * Create date : 06/01/2014
 */
@isTest
public class TestBatchCloneOpportunity {
    private static final String TYPE_SINGLE             = 'Single';
    private static final String TYPE_MULTI              = 'Multi';
    private static final String FAMILY_SUBSCRIPTION     = 'Subscriptions';
    private static final String RECORDTYPE_SUBSCRIPTION = 'Subscriptions_Opportunity';
    private static final String BUSINESSUNIT            = 'Compliance Week';
    private static final String STAGE_PROPOSAL          = 'Proposal/Price Quote';
    private static final String STAGE_CLOSEWON          = 'Closed Won';
    private static final String BUSINESSTYPE_RENEWAL    = 'Renewal';

    public static Opportunity initData(){

        String proId = [Select Id From Profile Where Name = 'System Administrator' limit 1].Id;
        User user;
        User customerServiceUser;

        String salt = 'LR' + Datetime.now().format('yyMMddHHmmssSSS');

        System.runAs(new User(Id = UserInfo.getUserId())) { 
            user = new User(
                alias              = 'u2', 
                email               = 'BatchCloneOpp@test.com', 
                emailencodingkey    = 'UTF-8', 
                FirstName           = 'BatchCloneOpp' , 
                lastname            = 'User', 
                languagelocalekey   = 'en_US',
                localesidkey        = 'en_US', 
                profileid           = proId, 
                timezonesidkey      = 'America/Los_Angeles', 
                CommunityNickname   = 'VE',
                isActive            = true, 
                username            = salt+'BatchCloneOpp@test.com');

            customerServiceUser = new User(
                alias              = 'custserv', 
                email               = 'customerService@test.com', 
                emailencodingkey    = 'UTF-8', 
                FirstName           = 'Customer Service' , 
                lastname            = 'User', 
                languagelocalekey   = 'en_US',
                localesidkey        = 'en_US', 
                profileid           = proId, 
                timezonesidkey      = 'America/Los_Angeles', 
                CommunityNickname   = 'CS',
                isActive            = true, 
                username            = salt+'customerService@test.com');
            insert new List<User>{user, customerServiceUser};
        }

        AssignRenewalOpptoCustomerService__c customSettingRenewal = new AssignRenewalOpptoCustomerService__c(Name='Assign Renewal to User ID');
        customSettingRenewal.Renewal_Assignee__c = customerServiceUser.Id;
        insert customSettingRenewal;

        Account accRecord = new Account(Name = 'testAccount');
        insert accRecord;

        Product2 prod = new Product2(Name = 'testProduct', Min_Users__c = 1, Max_Users__c = 1, Family = FAMILY_SUBSCRIPTION, Duration_Days__c = 90, IsActive = true);
        insert prod;

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry pbe = new PricebookEntry(UnitPrice = 100,Pricebook2Id=pricebookId, Product2Id = prod.ID, IsActive = true);
        insert pbe;

        Contact con = new Contact(LastName = 'test', AccountId = accRecord.Id);
        insert con;

        RecordType reType = [select id from RecordType where DeveloperName =: RECORDTYPE_SUBSCRIPTION ];
        
        Opportunity opp = new Opportunity(
            Name      = 'test renewal opp', 
            StageName       = STAGE_PROPOSAL, 
            RecordTypeId    = reType.Id, 
            Origination__c  = 'test',
            CloseDate       = System.today()+90,
            Amount          = 100,
            AccountId       = accRecord.Id,
            Pricebook2Id    = pricebookId,
            Business_Unit__c = 'test',
            Business_Type__c = BUSINESSTYPE_RENEWAL,
            OwnerId         = user.Id);
        insert opp;

        OpportunityContactRole ocr = new OpportunityContactRole(ContactId=con.Id, Role='Decision Maker', OpportunityId=opp.Id);
        insert ocr;

        OpportunityLineItem oppLine = new OpportunityLineItem(
            UnitPrice         = 100, 
            Quantity            = 1, 
            PricebookEntryId    = pbe.Id, 
            OpportunityId       = opp.Id, 
            Contact__c          = con.Id, 
            ServiceDate         = System.today());
        insert oppLine;

        System.runAs(new User(Id = UserInfo.getUserId())) { 
            user.isActive = false;
            update user;
        }

        opp.Business_Unit__c = BUSINESSUNIT;
        opp.StageName = STAGE_CLOSEWON;
        update opp;
        return opp;
    }
    
    static testMethod void myUnitTest(){
        Test.startTest();
        Opportunity opp = initData();
        //assert is batch clone
        //System.assert(BatchCloneOpportunity.cloneOpportunity(opp.Id));
        //assert is batch in process
        //System.assert(BatchCloneOpportunity.isBatchInProcess('BatchCloneOpportunity'));
        Test.stopTest();
        //select subscription after clone
        OpportunityLineItem opLineSelect = [select id,Subscription__r.Name, Subscription__r.Renewal_Opportunity__r.Name,Subscription__r.Renewal_Opportunity__r.OwnerId, Subscription__c from OpportunityLineItem where OpportunityId = :opp.Id];
        //assert if the existing subscription have look up to renewal opportunity
        //System.assertEquals('testAccount - '+opLineSelect.Subscription__r.Name+' - '+System.today().year()+' Renewal', opLineSelect.Subscription__r.Renewal_Opportunity__r.Name);
        //assert for renewal opportunity owner, if previous opp owner is inactive, get user from custom setting
        AssignRenewalOpptoCustomerService__c cs = AssignRenewalOpptoCustomerService__c.getValues('Assign Renewal to User ID');
        //System.assertEquals(cs.get('Renewal_Assignee__c')+'', opLineSelect.Subscription__r.Renewal_Opportunity__r.OwnerId);
    }

    @isTest 
    static void testContactRolesCloned()
    {
        Test.startTest();
        Opportunity opp = initData();
        //assert is batch clone
        //System.assert(BatchCloneOpportunity.cloneOpportunity(opp.Id));
        //assert is batch in process
        //System.assert(BatchCloneOpportunity.isBatchInProcess('BatchCloneOpportunity'));
        Test.stopTest();

        //select subscription after clone
        OpportunityLineItem opLineSelect = [select id, Subscription__r.Renewal_Opportunity__c from OpportunityLineItem where OpportunityId = :opp.Id];

        //System.assert(null != opLineSelect.Subscription__c, 'A subscription should exist for opLine.');

        Id newOppId = opLineSelect.Subscription__r.Renewal_Opportunity__c;

        //System.assert(null != newOppId, 'A renewal Opp should be present.');

        //select contact roles after clone
        List<OpportunityContactRole> contactRoles = [select id, ContactId from OpportunityContactRole where OpportunityId = :newOppId];

        //System.assertEquals(1, contactRoles.size());
    }
}