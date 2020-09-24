@isTest
public class UpdateContactsOnAccountTest {

    static testmethod void UpdateLeadsOnAccountTest() {
        Account acct = new Account();
        acct.Name = 'test';
        insert acct;
        List<Lead> leads2 = new List<Lead>();
        for (integer x = 0; x < 2; x++) {
            Lead aLead = new Lead();
            aLead.lastName = 'Test2' + x;
            aLead.Company = 'TestComany2' + x;
            aLead.Account__c = acct.id;
            leads2.add(aLead);
        }
        insert leads2;
        
        Test.startTest();
        AccountRollupBatch arb = new AccountRollupBatch();
        Id batchId = Database.executeBatch(arb);
        Test.stopTest();
        
        Account acct1 = [select Number_Of_Contacts__c, Number_of_Singles_Users__c, Number_of_Leads__c from Account where id =: acct.id].get(0);
        System.assert(acct1.Number_of_Leads__c == 2);
    }


    static testmethod void UpdateContactsOnAccountTest() {
        Account acct = new Account();
        acct.Name = 'test';
        insert acct;
        List<Contact> cons = new List<Contact>();
        for (integer x = 0; x < 100; x++) {
            Contact aCon = new Contact();
            aCon.FirstName = 'Test1FName' + x;
            aCon.LastName = 'Test1LName' + x;
            aCon.AccountId = acct.id;
            aCon.User_Type__c = 'Single';
            aCon.Expiration_Date__c = System.today() +1;
            cons.add(aCon);
        }
        insert cons;
        
        
        Account acct2 = new Account();
        acct2.Name = 'test2';
        insert acct2;
        Contact aCon2 = new Contact();
        aCon2.FirstName = 'Test1FName2';
        aCon2.LastName = 'Test1LName2';
        aCon2.AccountId = acct2.id;
        aCon2.User_Type__c = 'Single2';
        insert aCon2;
        
        Test.startTest();
        AccountRollupBatch arb = new AccountRollupBatch();
        Id batchId = Database.executeBatch(arb);
        Test.stopTest();

        System.Debug('cons.size() = ' + cons.size());
        Account acct1 = [select Number_Of_Contacts__c, Number_of_Singles_Users__c, Number_of_Leads__c from Account where id =: acct.id].get(0);
        System.Debug('acct1.Number_Of_Contacts__c = ' + acct1.Number_Of_Contacts__c);
        System.assert(acct1.Number_Of_Contacts__c == 100);
        System.assert(acct1.Number_of_Singles_Users__c == 100);

    }


}