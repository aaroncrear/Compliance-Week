@isTest
public class CalculateExpiredContactsTest {
    /**
    static testmethod void testBulkContactInsert() {
        Account acct = new Account();
        acct.Name = 'test';
        insert acct;
        List<Contact> cons = new List<Contact>();
        for (integer x = 0; x < 10; x++) {
            Contact aCon = new Contact();
            aCon.FirstName = 'Test1FName' + x;
            aCon.LastName = 'Test1LName' + x;
            aCon.AccountId = acct.id;
            aCon.User_Type__c = 'Single';
            aCon.Expiration_Date__c = System.today() +1;
            cons.add(aCon);
        }
        insert cons;

        System.Debug('cons.size() = ' + cons.size());
        Account acct1 = [select Number_Of_Contacts__c, Number_of_Multi_Users__c, Number_of_Singles_Users__c from Account where id =: acct.id].get(0);
        System.Debug('acct1.Number_Of_Contacts__c = ' + acct1.Number_Of_Contacts__c);
        System.Debug('acct1.Number_of_Singles_Users__c = ' + acct1.Number_of_Singles_Users__c);
        System.assert(acct1.Number_Of_Contacts__c == 10);
        System.assert(acct1.Number_of_Singles_Users__c == 10);
        
        List <Contact> allCons = [select id, Expiration_Date__c from Contact where AccountID =: acct.id];
        for (Contact upCon: allCons) {
            upCon.Expiration_Date__c = System.today();
        }
        update allCons;
        
        CalculateExpiredContacts cex = new CalculateExpiredContacts();
        cex.updateAccounts();
        Account acct2 = [select Number_Of_Contacts__c, Number_of_Multi_Users__c, Number_of_Singles_Users__c from Account where id =: acct.id].get(0);
        System.Debug('acct2.Id ' + acct2.Id);
        System.assert(acct2.Number_Of_Contacts__c == 10);
        System.Debug('acct2.Number_of_Singles_Users__c = ' + acct2.Number_of_Singles_Users__c);
        System.assert(acct2.Number_of_Singles_Users__c == 0);
    }

    static testmethod void testBulkContactMix() {
        Account acct = new Account();
        acct.Name = 'test';
        insert acct;
        List<Contact> cons = new List<Contact>();
        for (integer x = 0; x < 5; x++) {
            Contact aCon = new Contact();
            aCon.FirstName = 'Test1FName' + x;
            aCon.LastName = 'Test1LName' + x;
            aCon.AccountId = acct.id;
            aCon.User_Type__c = 'Single';
            aCon.Expiration_Date__c = System.today();
            cons.add(aCon);
        }
        insert cons;
        
        Contact aSingleCon = new Contact();
        aSingleCon.FirstName = 'Testame';
        aSingleCon.LastName = 'Testame';
        aSingleCon.AccountId = acct.id;
        aSingleCon.User_Type__c = 'Single';
        insert aSingleCon;
        
        Account acct2 = new Account();
        acct2.Name = 'test2';
        insert acct2;
        List<Contact> cons2 = new List<Contact>();
        for (integer x = 0; x < 5; x++) {
            Contact aCon = new Contact();
            aCon.FirstName = 'Test2FName' + x;
            aCon.LastName = 'Test2LName' + x;
            aCon.AccountId = acct2.id;
            aCon.User_Type__c = 'Multi';
            aCon.Expiration_Date__c = System.today();
            cons2.add(aCon);
        }
        insert cons2;
        
        Contact aMultiCon = new Contact();
        aMultiCon.FirstName = 'Testame';
        aMultiCon.LastName = 'Testame';
        aMultiCon.AccountId = acct.id;
        aMultiCon.User_Type__c = 'Multi';
        insert aMultiCon;
        
        Contact aMulti2Con = new Contact();
        aMulti2Con.FirstName = 'adfads';
        aMulti2Con.LastName = 'adfad';
        aMulti2Con.AccountId = acct2.id;
        aMulti2Con.User_Type__c = 'Multi';
        aMulti2Con.Expiration_Date__c = System.today() +2;
        insert aMulti2Con;
        
        Contact aConNoType = new Contact();
        aConNoType.FirstName = 'adfadsddd';
        aConNoType.LastName = 'adfaddddd';
        aConNoType.AccountId = acct2.id;
        aConNoType.Expiration_Date__c = System.today();
        insert aConNoType;
        
        System.Debug('cons.size() = ' + cons.size());
        Account acct1 = [select Number_Of_Contacts__c, Number_of_Multi_Users__c, Number_of_Singles_Users__c from Account where id =: acct.id].get(0);
        System.Debug('acct1.Number_Of_Contacts__c = ' + acct1.Number_Of_Contacts__c);
        System.assert(acct1.Number_Of_Contacts__c == 7);
        //System.assert(acct1.Number_of_Singles_Users__c == 6);
        
        CalculateExpiredContacts cex = new CalculateExpiredContacts();
        cex.updateAccounts();
        Account Upacct1 = [select Number_Of_Contacts__c, Number_of_Multi_Users__c, Number_of_Singles_Users__c from Account where id =: acct.id].get(0);
        System.Debug('Upacct1.Number_Of_Contacts__c = ' + Upacct1.Number_Of_Contacts__c);
        System.assert(Upacct1.Number_Of_Contacts__c == 7);
        System.Debug('Upacct1.Number_of_Singles_Users__c = ' + Upacct1.Number_of_Singles_Users__c);
        //System.assert(Upacct1.Number_of_Singles_Users__c == 1);
        //System.assert(Upacct1.Number_of_Multi_Users__c == 1);
        
        Account Upacct2 = [select Number_Of_Contacts__c, Number_of_Multi_Users__c, Number_of_Singles_Users__c from Account where id =: acct2.id].get(0);
        System.Debug('Upacct2.Number_Of_Contacts__c = ' + Upacct2.Number_Of_Contacts__c);
        System.assert(Upacct2.Number_Of_Contacts__c == 7);
        System.Debug('Upacct2.Number_of_Singles_Users__c = ' + Upacct2.Number_of_Singles_Users__c);
        //System.assert(Upacct2.Number_of_Singles_Users__c == 0);
        //System.assert(Upacct2.Number_of_Multi_Users__c == 1);
    }
    **/
    public static testMethod void testJob() {
        CalculateExpiredContactJob job = new CalculateExpiredContactJob();
        job.execute(null);
    }

}