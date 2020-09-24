@isTest
public class UpdateAccountContactsTriggerTest {
    /**
    static testmethod void testBulkContactDelete() {
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
            cons.add(aCon);
        }
        insert cons;
        System.Debug('cons.size() = ' + cons.size());
        Account acct1 = [select Number_Of_Contacts__c from Account where id =: acct.id].get(0);
        System.Debug('acct1.Number_Of_Contacts__c = ' + acct1.Number_Of_Contacts__c);
        System.assert(acct1.Number_Of_Contacts__c == 10);
        
        List<Contact> allCons = [select id, FirstName from Contact];

        Delete allCons;
        Account acct2 = [select Number_Of_Contacts__c from Account where id =: acct.id].get(0);
        System.Debug('acct1.Number_Of_Contacts__c = ' + acct2.Number_Of_Contacts__c);
       // System.assert(acct2.Number_Of_Contacts__c == 0);
    }
	
    static testmethod void testAcctWithNoEmailDomain() {
        Account acct = new Account();
        acct.Name = 'test';
        insert acct;
        Contact con1 = new Contact();
        con1.FirstName = 'Test1FName';
        con1.LastName = 'Test1LName';
        con1.AccountId = acct.id;
        con1.User_Type__c = 'Single';
        con1.Email = 'Henry@ford.com';
        insert con1;
        
        Account upAcct = [select Email_Domain__c from Account where id =: acct.id].get(0);
        system.assert(upAcct.Email_Domain__c == 'ford.com');
    }

    static testmethod void testUpdateOldTypes() {
        Account acct = new Account();
        acct.Name = 'test';
        insert acct;
        Contact con1 = new Contact();
        con1.FirstName = 'Test1FName';
        con1.LastName = 'Test1LName';
        con1.AccountId = acct.id;
        con1.User_Type__c = 'Single';
        con1.Expiration_Date__c = System.today() +3;
        insert con1;
        Account acct1 = [select Number_Of_Contacts__c, Number_of_Singles_Users__c, Number_of_Multi_Users__c from Account where id =: acct.id].get(0);
        System.assert(acct1.Number_of_Singles_Users__c == 1);
        
        Contact upCon1 = [select id, User_Type__c from Contact where Id =: con1.id].get(0);
        upCon1.User_Type__c = 'Multi';
        update upCon1;
        Account acct2 = [select Number_Of_Contacts__c, Number_of_Singles_Users__c, Number_of_Multi_Users__c from Account where id =: acct.id].get(0);
        System.assert(acct2.Number_of_Singles_Users__c == 0);
        System.assert(acct2.Number_of_Multi_Users__c == 1);
        
		Contact upCon2 = [select id, User_Type__c from Contact where Id =: con1.id].get(0);   
        upCon2.User_Type__c = 'Single';
        update upCon2;
        Account acct3 = [select Number_Of_Contacts__c, Number_of_Singles_Users__c, Number_of_Multi_Users__c from Account where id =: acct.id].get(0);
        System.assert(acct3.Number_of_Singles_Users__c == 1);
        System.assert(acct3.Number_of_Multi_Users__c == 0);
    }

    static testmethod void testBulkContactUpdate() {
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
            cons.add(aCon);
        }
        insert cons;
        System.Debug('cons.size() = ' + cons.size());
        Account acct1 = [select Number_Of_Contacts__c from Account where id =: acct.id].get(0);
        System.Debug('acct1.Number_Of_Contacts__c = ' + acct1.Number_Of_Contacts__c);
        System.assert(acct1.Number_Of_Contacts__c == 100);
        
        List<Contact> allCons = [select id, FirstName from Contact];
        for(Contact con: allCons) {
            con.FirstName = con.FirstName + 'test';
        }
        update allCons;
        Account acct2 = [select Number_Of_Contacts__c from Account where id =: acct.id].get(0);
        System.Debug('acct1.Number_Of_Contacts__c = ' + acct2.Number_Of_Contacts__c);
        System.assert(acct2.Number_Of_Contacts__c == 100);
    }

    static testmethod void testContactRollup() {
        Account acct = new Account();
        acct.Name = 'test';
        insert acct;
        Contact con1 = new Contact();
        con1.FirstName = 'Test1FName';
        con1.LastName = 'Test1LName';
        con1.AccountId = acct.id;
        con1.User_Type__c = 'Single';
        con1.Expiration_Date__c = System.today() +1;
        insert con1;
        Account acct1 = [select Number_Of_Contacts__c from Account where id =: acct.id].get(0);
        system.assert(acct1.Number_Of_Contacts__c == 1);
        
        Contact con2 = new Contact();
        con2.FirstName = 'Test2FName';
        con2.LastName = 'Test2LName';
        con2.User_Type__c = 'Multi';
        con2.AccountId = acct.id;
        con2.Expiration_Date__c = System.today() +1;
        insert con2;
        
        Account acct2 = [select Number_Of_Contacts__c, Number_of_Singles_Users__c, Number_of_Multi_Users__c from Account where id =: acct.id].get(0);
        System.debug('acct2.Number_Of_Contacts__c = ' + acct2.Number_Of_Contacts__c);
        system.assert(acct2.Number_Of_Contacts__c == 2);

        Contact delCon = [select id from Contact where id =: con1.Id].get(0);
        delete delCon;
        
        Account acct3 = [select Number_Of_Contacts__c from Account where id =: acct.id].get(0);
        System.debug('acct3.Number_Of_Contacts__c = ' + acct3.Number_Of_Contacts__c);
      //  system.assert(acct3.Number_Of_Contacts__c == 1);
        
        Contact delCon2 = [select id from Contact where id =: con2.Id].get(0);
        delete delCon2;
        
        Account acct4 = [select Number_Of_Contacts__c from Account where id =: acct.id].get(0);
        System.debug('acct4.Number_Of_Contacts__c = ' + acct4.Number_Of_Contacts__c);
      //  system.assert(acct4.Number_Of_Contacts__c == 0);
    }
**/
}