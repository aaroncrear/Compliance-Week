@istest
public class DeleteSilverPopActivitiesTest {
/*    @testSetup 
    static void setup() {
        List<silverpop__Silverpop_Email_Activity__c> seas = new List<silverpop__Silverpop_Email_Activity__c>();
        List<silverpop__Email_Link__c> els = new List<silverpop__Email_Link__c>();
        // insert 10 accounts
        for (Integer i=0;i<10;i++) {
            seas.add(new silverpop__Silverpop_Email_Activity__c(name='test '+i));
        }
        insert seas;
        // find the account just inserted. add contact for each
        for (silverpop__Silverpop_Email_Activity__c allSeas : [select id from silverpop__Silverpop_Email_Activity__c]) {
            els.add(new silverpop__Email_Link__c(name = 'aName', silverpop__Silverpop_Email_Activity__c=allSeas.id));
        }
        insert els;
    }
*/
    static testmethod void testDeleteAll() {    
        
        String CRON_EXP = '0 0 0 15 3 ? *';
        Test.startTest();
        String jobId = System.schedule('test',  CRON_EXP, new DeleteSilverPopActivitiesJob());

        DeleteSilverPopActivities uca = new DeleteSilverPopActivities();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
		
        // after the testing stops, assert records were updated properly
       // System.assertEquals(0, [select count() from silverpop__Silverpop_Email_Activity__c]);
        //System.assertEquals(0, [select count() from silverpop__Email_Link__c]);
    }
    /*
    static testmethod void testPartial() {   
        silverpop__Silverpop_Email_Activity__c aSea = new silverpop__Silverpop_Email_Activity__c(name = 'testx');
        insert aSea;
        
        Test.startTest();
        DeleteSilverPopActivities uca = new DeleteSilverPopActivities();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();

        // after the testing stops, assert records were updated properly
        System.assertEquals(0, [select count() from silverpop__Silverpop_Email_Activity__c]);
        System.assertEquals(0, [select count() from silverpop__Email_Link__c]);
    }
    
    static testmethod void testPartial2() {   
        //Keep, SEA count = 1
        silverpop__Silverpop_Email_Activity__c aSea = new silverpop__Silverpop_Email_Activity__c(name = 'testx');
        insert aSea;
        //Keep, EL count = 1
        silverpop__Email_Link__c el1 = new silverpop__Email_Link__c(name = 'aName', silverpop__Last_Clicked__c = system.today(), silverpop__Silverpop_Email_Activity__c = aSea.id);
        insert el1;
        //delete, EL count = 1
        silverpop__Email_Link__c el2 = new silverpop__Email_Link__c(name = 'aName', silverpop__Silverpop_Email_Activity__c = aSea.id);
        insert el2;
        //Keep, EL count = 2
        silverpop__Email_Link__c el3 = new silverpop__Email_Link__c(name = 'aName', silverpop__Last_Clicked__c = system.today());
        insert el3;
        //keep, EL count = 3
        silverpop__Email_Link__c el4 = new silverpop__Email_Link__c(name = 'aName');
        insert el4;
        //Delete, SEA count = 1
        silverpop__Silverpop_Email_Activity__c aSea2 = new silverpop__Silverpop_Email_Activity__c(name = 'testx');
        insert aSea2;
        //Delete, SEA count = 2
        silverpop__Silverpop_Email_Activity__c aSea3 = new silverpop__Silverpop_Email_Activity__c(name = 'testx');
        insert aSea3;
        //Delete EL Count = 3
        silverpop__Email_Link__c el5 = new silverpop__Email_Link__c(name = 'aName', silverpop__Silverpop_Email_Activity__c = aSea3.id);
        insert el5;
        
        Test.startTest();
        DeleteSilverPopActivities uca = new DeleteSilverPopActivities();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();

        // after the testing stops, assert records were updated properly
        System.assertEquals(1, [select count() from silverpop__Silverpop_Email_Activity__c]);
        System.assertEquals(3, [select count() from silverpop__Email_Link__c]);
    }
    
    public static testMethod void testDeleteActivityNoEmailLink() {
        silverpop__Silverpop_Email_Activity__c sea1 = new silverpop__Silverpop_Email_Activity__c();
        insert sea1;
        silverpop__Silverpop_Email_Activity__c sea2 = new silverpop__Silverpop_Email_Activity__c();
        insert sea2;
        silverpop__Silverpop_Email_Activity__c sea3 = new silverpop__Silverpop_Email_Activity__c();
        insert sea3;
        silverpop__Email_Link__c el1 = new silverpop__Email_Link__c(name = 'aName', silverpop__Last_Clicked__c = system.today(), silverpop__Silverpop_Email_Activity__c = sea3.id);
        insert el1;
        System.assertEquals(13, [select count() from silverpop__Silverpop_Email_Activity__c]);
        
        Test.startTest();
        DeleteSilverPopActivities uca = new DeleteSilverPopActivities();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        System.assertEquals(1, [select count() from silverpop__Silverpop_Email_Activity__c]);
    }
    
    public static testMethod void testJob() {
        DeleteSilverPopActivitiesJob job = new DeleteSilverPopActivitiesJob();
        job.execute(null);
    }
   */ 
}