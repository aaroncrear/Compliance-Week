/**
 * Class to test webservice for a button "Upgrade"
 * Create Date 21/01/2014
 */
@isTest
private class TestCreateUpgradeOpportunity {

    static testMethod void myUnitTest() {
        Test.startTest();
            Account accRecord = new Account(Name = 'testAccount');
            insert accRecord;
            Contact con = new Contact(LastName = 'test', AccountId = accRecord.Id);
            insert con;
            Subscription_NEW__c subScription = new Subscription_NEW__c(Expiration_Date__c  = System.today()+200,
                                                                       Contact__c          = con.Id,
                                                                       Account__c          = accRecord.Id,
                                                                       Type__c             = 'Single',
                                                                       Start_Date__c       = System.today(),
                                                                       Amount__c           = 100,
                                                                       Renewal_Rate__c     = 100,
                                                                       Minimum_Users__c    = 2,
                                                                       Maximum_Users__c    = 5);
           insert subScription;
           CreateUpgradeOpportunity.CreateUpgradeOpportunity(subScription.Id);
           Subscription_NEW__c subSelect = [select Renewal_Opportunity__r.Name, Renewal_Opportunity__c, Name from Subscription_NEW__c where id =: subScription.Id];
           System.assert(subSelect.Renewal_Opportunity__c != null);
           System.assertEquals('testAccount - '+subSelect.Name+' - Upgrade', subSelect.Renewal_Opportunity__r.Name);
        Test.stopTest();
    }
}