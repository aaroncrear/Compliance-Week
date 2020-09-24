/**
 * Class to test trigger SubscrptionNewTrigger on Subscription_NEW__c When a Subscription is created, the Expiration Date field on Contact should be updated with 
 * the Expiration Date on the new Subscription record (assuming it is the greatest date of all Subscriptions associated with that Contact).
 * Create Date 31/12/2013
 */
@isTest
private class TestSubscrptionNewTrigger {

    static testMethod void myUnitTest() {
        Test.startTest();
            Account accRecord = new Account(Name = 'testAccount');
            insert accRecord;
            Contact con = new Contact(LastName = 'test', AccountId = accRecord.Id);
            insert con;
            List<Subscription_NEW__c> lstSub = new List<Subscription_NEW__c>();
            for(Integer i = 0 ; i < 50; i++){
                lstSub.add(new Subscription_NEW__c(Expiration_Date__c = System.today()+7,
                                                    Contact__c = con.Id,
                                                    Account__c =accRecord.ID));
            }
            insert lstSub;
           //System.assertEquals(System.today()+7, [select Expiration_Date__c from Contact where id =: con.ID ].Expiration_Date__c);
            lstSub[0].Expiration_Date__c = System.today()+8;
            update lstSub;
            //System.assertEquals(System.today()+8, [select Expiration_Date__c from Contact where id =: con.ID ].Expiration_Date__c);
            delete lstSub[0];
            //System.assertEquals(null, [select Expiration_Date__c from Contact where id =: con.ID ].Expiration_Date__c);
        Test.stopTest();
    }
}