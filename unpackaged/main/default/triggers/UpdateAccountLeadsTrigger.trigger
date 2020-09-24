trigger UpdateAccountLeadsTrigger on Lead (After insert, Before delete, After update) { //add After Update
    
    List <Account> modifiedAccounts = new List<Account>();

    if (Trigger.isBefore) {
        Map <ID, Account> modifiedAccountsMap = new Map<ID, Account>();
        List<Account> accts = [select Id, Number_of_Leads__c from Account where ID IN 
                               (select Account__c from Lead where ID IN :Trigger.oldMap.keySet())];
        Map<Id, Account> acctMap = new Map<ID, Account>();
        for (Account aAcct: accts) {
            acctMap.put(aAcct.id, aAcct);
        }
        if (Trigger.isDelete) {
            for (Lead aLead : Trigger.old) {
                if(aLead.Account__c != null) {
                    Account acct = acctMap.get(aLead.Account__c);
                    if (acct != null) {
                        if (acct.Number_of_Leads__c == null) {
                           acct.Number_of_Leads__c = 0; 
                        }
                        //acct.Number_of_Leads__c = acct.Number_of_Leads__c -1;
                        System.debug('Is Delete, subtracting number of Lead');
                        //modifiedAccounts.add(acct);
                        if(modifiedAccountsMap.get(acct.id) == null) {
                            acct.Number_of_Leads__c = acct.Number_of_Leads__c -1;
                            modifiedAccountsMap.put(acct.Id, acct);
                            System.debug('acct.Number_of_Leads__c = ' + acct.Number_of_Leads__c);
                            System.debug('Adding First to account Map');
                        } else {
                            Account modMapAcct = modifiedAccountsMap.get(acct.id);
                            acct.Number_of_Leads__c = acct.Number_of_Leads__c -1;
                            System.debug('updateing to account Map');
                        }

                    }
                }
            }
            for (Account upAcct:modifiedAccountsMap.values()) {
                modifiedAccounts.add(upAcct);
            }
            if (modifiedAccounts.size() > 0) {
                System.debug('Begin Update');
                update modifiedAccounts;
            }
        } 
    } else {
        Map<Id, Account> acctModifiedMap = new Map<ID, Account>();
        List<Account> accts = [select Id, Number_of_Leads__c from Account where ID IN 
                               (select Account__c from Lead where ID IN :Trigger.newMap.keySet())];
        Map<Id, Account> acctMap = new Map<ID, Account>();
        for (Account aAcct: accts) {
            acctMap.put(aAcct.id, aAcct);
        }
        for(Lead aLead : Trigger.new) { 
            if(aLead.Account__c != null) {
                Account acct = acctMap.get(aLead.Account__c);
                if (acct != null && Trigger.isInsert) {
                    if (acct.Number_of_Leads__c == null) {
                        acct.Number_of_Leads__c = 0; 
                    }
                    acct.Number_of_Leads__c = acct.Number_of_Leads__c +1;
                    acctModifiedMap.put(acct.id, acct);
                } else if (acct != null && Trigger.isUpdate && aLead.Status == 'Converted') {
                    Lead oldLead = Trigger.oldMap.get(aLead.Id);
                    if (oldLead.Status != 'Converted') {
                        if(acct.Number_of_Leads__c != null && acct.Number_of_Leads__c > 0){
                            acct.Number_of_Leads__c = acct.Number_of_Leads__c -1;
                            System.debug('Is Update, subtracting number of Lead');
                            acctModifiedMap.put(acct.id, acct);
                        }
                    }
                }
            }
        }
        if (acctModifiedMap.size() > 0 ) {
            for(ID acctID : acctModifiedMap.keySet()) {
                modifiedAccounts.add(acctModifiedMap.get(acctID));
            }
            upsert modifiedAccounts;
        }
    }


}