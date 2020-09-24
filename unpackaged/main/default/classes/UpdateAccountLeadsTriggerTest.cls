@isTest
public class UpdateAccountLeadsTriggerTest {
/**
    static testmethod void testBulkLeadDelete() {
        Account acct = new Account();
        acct.Name = 'test';
        insert acct;
        List<Lead> leads = new List<Lead>();
        for (integer x = 0; x < 100; x++) {
            Lead aLead = new Lead();
            aLead.lastName = 'Test1' + x;
            aLead.Company = 'TestComany1' + x;
            aLead.Account__c = acct.id;
            leads.add(aLead);
        }
        insert leads;
        System.Debug('leads.size() = ' + leads.size());
        Account acct1 = [select Number_of_Leads__c from Account where id =: acct.id].get(0);
        System.Debug('acct1.Number_of_Leads__c = ' + acct1.Number_of_Leads__c);
        System.assert(acct1.Number_of_Leads__c == 100);
        
        List<Lead> allLeads = [select Id from Lead];
        delete allLeads;
    }

    static testmethod void testUpdateLeadAccount() {
        Account acct = new Account();
        acct.Name = 'testCopy';
        acct.Email_Domain__c = 'ford.com';
        insert acct;
        Contact aCon = new Contact();
        aCon.FirstName = 'fname';
        aCon.LastName = 'lname';
        aCon.AccountId = acct.id;
        aCon.Email = 'test@ford.com';
        insert aCon; 
        
        Lead aLead = new Lead();
        aLead.lastName = 'Test1';
        aLead.Company = 'TestCopy';
        aLead.Email = 'testLead@ford.com';
        insert aLead;
        
        Lead upLead = [select Account__c, Email from Lead where id =: aLead.id].get(0);
        Account upAcct = [select Number_of_Leads__c from Account where id =: acct.id].get(0);
        system.assert(upLead.Account__c == acct.id);
        system.assert(upAcct.Number_of_Leads__c == 1);
        delete upLead;
        Account upAcct2 = [select Number_of_Leads__c from Account where id =: acct.id].get(0);
      //  system.assert(upAcct2.Number_of_Leads__c == 0);
    }

    static testmethod void testLeadAcctCopy() {
        Account acct = new Account();
        acct.Name = 'testCopy';
        insert acct;
        Contact aCon = new Contact();
        aCon.FirstName = 'fname';
        aCon.LastName = 'lname';
        aCon.AccountId = acct.id;
        aCon.Email = 'test@test.com';
        insert aCon;
        List<Lead> leads = new List<Lead>();
        for (integer x = 100; x < 1; x++) {
            Lead aLead = new Lead();
            aLead.lastName = 'Test1' + x;
            aLead.Company = 'TestCopy' + x;
            aLead.Email = 'testLead@test.com';
            leads.add(aLead);
        }
        insert leads;
        system.debug('acct.id = ' + acct.id);
        for(Lead aLead : [select Account__c from Lead]) {
            system.debug('aLead.Account__c = ' + aLead.Account__c);
            system.assert(aLead.Account__c == acct.id);
        }
    }
    
    static testmethod void testBulkLeadInsert() {
        Account acct = new Account();
        acct.Name = 'test';
        insert acct;
        List<Lead> leads = new List<Lead>();
        for (integer x = 0; x < 100; x++) {
            Lead aLead = new Lead();
            aLead.lastName = 'Test1' + x;
            aLead.Company = 'TestComany1' + x;
            aLead.Account__c = acct.id;
            leads.add(aLead);
        }
        insert leads;
        System.Debug('leads.size() = ' + leads.size());
        Account acct1 = [select Number_of_Leads__c from Account where id =: acct.id].get(0);
        System.Debug('acct1.Number_of_Leads__c = ' + acct1.Number_of_Leads__c);
        System.assert(acct1.Number_of_Leads__c == 100);
    }
    
    static testmethod void testLeadRollup() {
        Account acct = new Account();
        acct.Name = 'test';
        insert acct;
        Lead lead1 = new Lead();
        lead1.lastName = 'Test1';
        lead1.Company = 'TestComany1';
        lead1.Account__c = acct.id;
        insert lead1;
        Account acct1 = [select Number_of_Leads__c from Account where id =: acct.id].get(0);
        system.assert(acct1.Number_of_Leads__c == 1);
        
        Lead lead2 = new Lead();
        lead2.lastName = 'Test2';
        lead2.Company = 'TestComany2';
        lead2.Account__c = acct.id;
        insert lead2;
        
        Account acct2 = [select Number_of_Leads__c from Account where id =: acct.id].get(0);
        system.assert(acct2.Number_of_Leads__c == 2);
        

    }
    
    static testmethod void testLeadNoAcct() {
        Lead lead1 = new Lead();
        lead1.lastName = 'Test1';
        lead1.Company = 'TestComany1';
        insert lead1;
    }
**/
}