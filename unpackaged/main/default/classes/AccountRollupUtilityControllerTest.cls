@isTest
public class AccountRollupUtilityControllerTest {
    /**
    static testMethod void accountRollupTest() {
     	Account acct1 = new Account();
        acct1.Name = 'test 1';
        insert acct1;
        Contact con1 = new Contact();
        con1.FirstName = 'Test1FName';
        con1.LastName = 'Test1LName';
        con1.AccountId = acct1.id;
        con1.User_Type__c = 'Single';
        insert con1;
        
        Contact con2 = new Contact();
        con2.FirstName = 'Test2FName';
        con2.LastName = 'Test2LName';
        con2.User_Type__c = 'Multi';
        con2.AccountId = acct1.id;
        insert con2; 
        
        Account acct2 = new Account();
        acct2.Name = 'test 2';
        insert acct2;
        
        Contact con3 = new Contact();
        con3.FirstName = 'Test3FName';
        con3.LastName = 'Test3LName';
        con3.AccountId = acct2.id;
        con3.User_Type__c = 'Single';
        insert con3;
        
        Contact con4 = new Contact();
        con4.FirstName = 'Test4FName';
        con4.LastName = 'Test4LName';
        con4.User_Type__c = 'Multi';
        con4.AccountId = acct2.id;
        insert con4; 
        
        Contact con5 = new Contact();
        con5.FirstName = 'Test5FName';
        con5.LastName = 'Test5LName';
        con5.User_Type__c = 'Multi';
        con5.AccountId = acct2.id;
        insert con5; 
        
        AccountRollupUtilityController util = new AccountRollupUtilityController();
        util.rollupContacts();
        
        Account rollAcct1 = [select Number_Of_Contacts__c, Number_of_Singles_Users__c, Number_of_Multi_Users__c from Account where id =: acct1.id].get(0);
        system.assert(rollAcct1.Number_Of_Contacts__c == 2);
        system.assert(rollAcct1.Number_of_Multi_Users__c == 1);
        
        Account rollAcct2 = [select Number_Of_Contacts__c, Number_of_Singles_Users__c, Number_of_Multi_Users__c from Account where id =: acct2.id].get(0);
        system.assert(rollAcct2.Number_Of_Contacts__c == 3);
        system.assert(rollAcct2.Number_of_Multi_Users__c == 2);
        system.debug('Cons Update = ' + util.consUpdated);
    }
    
    static testMethod void leadRollupTest() {
        Account acct1 = new Account();
        acct1.Name = 'test 1';
        insert acct1;
        
        Account acct2 = new Account();
        acct2.Name = 'test 2';
        insert acct2;
        
        Lead lead1 = new Lead();
        lead1.LastName = 'test1';
        lead1.Company = 'test1';
        lead1.Status = 'New';
        lead1.Account__c = acct1.id;
        insert lead1;
        
        Lead lead2 = new Lead();
        lead2.LastName = 'test2';
        lead2.Company = 'test2';
        lead2.Status = 'New';
        lead2.Account__c = acct1.id;
        insert lead2;
        
        AccountRollupUtilityController util = new AccountRollupUtilityController();
        util.rollupLeads();
        
        Account acct1Lead = [select id, Number_of_Leads__c from Account where id =: acct1.id].get(0);
        System.assert(acct1Lead.Number_of_Leads__c == 2);
        
        Account acct2Lead = [select id, Number_of_Leads__c from Account where id =: acct2.id].get(0);
        System.assert(acct2Lead.Number_of_Leads__c == 0);
        system.debug('Leads Updated = ' + util.leadsUpdated);
    }
**/
}