public class AccountRollupUtilityController {
    List <Account> accts;
    Public Integer consUpdated {get;set;}
    Public Integer leadsUpdated {get;set;}
    
    public AccountRollupUtilityController() {
        consUpdated = 0;
        leadsUpdated = 0;
        accts = [select Id, Number_Of_Contacts__c, Number_of_Multi_Users__c, Number_of_Singles_Users__c from Account];
    }
    
    Public void rollupContacts () {
        List <Contact> cons = [select Id, AccountID, User_Type__c from Contact];
        Map<ID, List <Contact>> mapCons = new Map<ID, List <Contact>>();
        for(Account acct : accts) {
            List <Contact> acctCons = new List <Contact>();
            for (Contact aCon : cons) {
                if (aCon.AccountID == acct.Id) {
                    acctCons.add(aCon);
                }
            }
            mapCons.put(acct.id, acctCons);
        }
        for (Account acct : accts) {
            List <Contact> allAcctCons = mapCons.get(acct.Id);
            if (allAcctCons.size() > 0) {
                acct.Number_Of_Contacts__c = allAcctCons.size();
                if (acct.Number_of_Multi_Users__c == null) {
                    acct.Number_of_Multi_Users__c = 0;
                }
                if (acct.Number_of_Singles_Users__c == null) {
                    acct.Number_of_Singles_Users__c = 0;
                }
                integer iMultiCons = 0;
                integer iSingleCons = 0;
                for(Contact aConType : allAcctCons) {
                    if (aConType.User_Type__c != null && aConType.User_Type__c.contains('Multi')) {
                        iMultiCons++;
                    } else if (aConType.User_Type__c != null &&  aConType.User_Type__c == 'Single') {
                        iSingleCons++;
                    }
                }
                acct.Number_of_Multi_Users__c = iMultiCons;
                acct.Number_of_Singles_Users__c = iSingleCons;
                System.debug('iMultiCons = ' + iMultiCons);
                System.debug('iSingleCons = ' + iSingleCons);
                System.debug('Number of Contacts = ' + allAcctCons.size());
                consUpdated++;
            }
        }
        update accts;
    }

	Public void rollupLeads () {
        List <Lead> leads = [select Id, Account__c from Lead];
        Map<ID, List <Lead>> mapLeads = new Map<ID, List <Lead>>();
        for(Account acct : accts) {
            List <Lead> acctleads = new List <Lead>();
            for (Lead aLead : leads) {
                if (aLead.Account__C == acct.Id) {
                    acctleads.add(aLead);
                }
            }
            mapLeads.put(acct.id, acctleads);
        }
        for (Account acct : accts) {
            List <Lead> allAcctLeads = mapLeads.get(acct.Id);
			acct.Number_of_Leads__c = allAcctLeads.size();
            System.debug('Number of Leads = ' + allAcctLeads.size());
            leadsUpdated++;
        }
        update accts;
    }
    
}