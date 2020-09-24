trigger UpdateAccountContactsTrigger on Contact (After insert, Before delete, After Update) {

    List <Account> modifiedAccounts = new List<Account>();
    if (Trigger.isBefore) {
        Map <ID, Account> modifiedAccountsMap = new Map<ID, Account>();
        if (Trigger.isDelete) {
            List<Account> accts = [select Id,  Number_Of_Contacts__c,  Number_of_Multi_Users__c, Number_of_Singles_Users__c from Account where ID IN (select AccountId from Contact where ID IN :Trigger.oldMap.keySet())];
            Map<Id, Account> acctMap = new Map<ID, Account>();
            for (Account aAcct: accts) {
                acctMap.put(aAcct.id, aAcct);
            }
            System.debug('acctMap Size = ' + acctMap.size());
            for (Contact aCon : Trigger.old) {
                Account acct = acctMap.get(aCon.AccountId);
                
                if (acct != null) {
                    if(modifiedAccountsMap.get(acct.id) != null) {
                       acct = modifiedAccountsMap.get(acct.id);
                    }
                    if (acct.Number_of_Multi_Users__c == null) {
                        acct.Number_of_Multi_Users__c = 0;
                    }
                    if (acct.Number_of_Singles_Users__c == null) {
                        acct.Number_of_Singles_Users__c = 0;
                    }
                    if (acct.Number_Of_Contacts__c !=null && acct.Number_Of_Contacts__c > 0) {
                        acct.Number_Of_Contacts__c = acct.Number_Of_Contacts__c - 1;
                    }
                    if (aCon.User_Type__c != null && aCon.User_Type__c.contains('Multi')) {
                        acct.Number_of_Multi_Users__c = acct.Number_of_Multi_Users__c - 1;
                    } else if (aCon.User_Type__c != null && aCon.User_Type__c == 'Single' ) {
                        acct.Number_of_Singles_Users__c = acct.Number_of_Singles_Users__c - 1;
                    }
                    modifiedAccountsMap.put(acct.id, acct);
                    //modifiedAccounts.add(acct);
                }
            }
        }
        for (Account upAcct:modifiedAccountsMap.values()) {
            System.debug('upAcct.id = ' + upAcct.id);
            modifiedAccounts.add(upAcct);
        }
        if (modifiedAccounts.size() > 0) {
            update modifiedAccounts;
        }
    } else if (Trigger.isAfter) {
        List<Account> accts = [select Id,  Number_Of_Contacts__c,  Number_of_Multi_Users__c, Number_of_Singles_Users__c from Account where ID IN (select AccountId from Contact where ID IN :Trigger.newMap.keySet())];
        Map<Id, Account> acctMap = new Map<ID, Account>();
        Map<Id, Account> acctModifiedMap = new Map<ID, Account>();
        for (Account aAcct: accts) {
            acctMap.put(aAcct.id, aAcct);
        }
        System.debug('acctMap Size = ' + acctMap.size());
        for(Contact aCon : Trigger.new) {
            if (aCon.AccountId != null) {
                Account acct = acctMap.get(aCon.AccountId);
                
                System.debug('acct.id = ' + acct.id);
                if (acct != null) {
                    if (acct.Number_of_Multi_Users__c == null) {
                        acct.Number_of_Multi_Users__c = 0;
                    }
                    if (acct.Number_of_Singles_Users__c == null) {
                        acct.Number_of_Singles_Users__c = 0;
                    }  
                    if (acct.Number_Of_Contacts__c == null) {
                        acct.Number_Of_Contacts__c = 0;
                    }
                    if(Trigger.isInsert) {
                       acct.Number_Of_Contacts__c = acct.Number_Of_Contacts__c + 1;
                       if (aCon.User_Type__c != null && aCon.User_Type__c.contains('Multi') && (aCon.Expiration_Date__c != null && aCon.Expiration_Date__c > System.today())) {
                           acct.Number_of_Multi_Users__c = acct.Number_of_Multi_Users__c + 1;
                       } else if (aCon.User_Type__c != null && aCon.User_Type__c == 'Single' && (aCon.Expiration_Date__c != null && aCon.Expiration_Date__c > System.today())) {
                           acct.Number_of_Singles_Users__c = acct.Number_of_Singles_Users__c + 1;
                       }
                       if(String.isBlank(acct.Email_Domain__c) && !String.isBlank(aCon.Email) && !(aCon.Email.Contains('gmail') || aCon.Email.Contains('hotmail') || aCon.Email.Contains('yahoo'))) {
                           System.debug('Found Domain to update');
                           Integer startIndex = aCon.Email.indexOf('@');
                           Integer endIndex = aCon.Email.length();
                           String emailDomain = aCon.Email.subString(startIndex + 1 , endIndex);
                           acct.Email_Domain__c = emailDomain;
                       } 
                    } else {
                        System.debug('in Update');
                        Contact oldCon = Trigger.oldMap.get(aCon.Id);
                        if ((aCon.User_Type__c != null && oldCon.User_Type__c != null) && (aCon.User_Type__c.contains('Multi') && !oldCon.User_Type__c.contains('Multi'))
                           && (aCon.Expiration_Date__c != null && aCon.Expiration_Date__c > System.today())) {
                            acct.Number_of_Multi_Users__c = acct.Number_of_Multi_Users__c + 1;
                               System.debug('in Update Multi');
                            if (oldCon.User_Type__c == 'Single') {
                                acct.Number_of_Singles_Users__c = acct.Number_of_Singles_Users__c - 1;
                            } 
                        } else if ((aCon.User_Type__c != null && oldCon.User_Type__c != null) && (aCon.User_Type__c == 'Single' && oldCon.User_Type__c != 'Single')
                                  && (aCon.Expiration_Date__c != null && aCon.Expiration_Date__c > System.today())) {
                            acct.Number_of_Singles_Users__c = acct.Number_of_Singles_Users__c + 1;
                            if (oldCon.User_Type__c.contains('Multi')) {
                                acct.Number_of_Multi_Users__c = acct.Number_of_Multi_Users__c - 1;
                            }
                        }  else if ((oldCon.User_Type__c == null && aCon.User_Type__c != null) && aCon.User_Type__c.contains('Multi')
                                   && (aCon.Expiration_Date__c != null && aCon.Expiration_Date__c > System.today())) {
                            acct.Number_of_Multi_Users__c = acct.Number_of_Multi_Users__c + 1;
                        }  else if ((oldCon.User_Type__c == null && aCon.User_Type__c != null) && aCon.User_Type__c == 'Single'
                                   && (aCon.Expiration_Date__c != null && aCon.Expiration_Date__c > System.today())) {
                                acct.Number_of_Singles_Users__c = acct.Number_of_Singles_Users__c + 1;
                        } else if (aCon.User_Type__c != null && aCon.Expiration_Date__c != null && oldCon.Expiration_Date__c != null && aCon.Expiration_Date__c > System.today() && 
                                   oldCon.Expiration_Date__c < System.today() && aCon.User_Type__c.contains('Multi')) {
                             acct.Number_of_Multi_Users__c = acct.Number_of_Multi_Users__c + 1;          
                        } else if (aCon.User_Type__c != null && aCon.Expiration_Date__c != null && oldCon.Expiration_Date__c != null && aCon.Expiration_Date__c > System.today() && 
                                   oldCon.Expiration_Date__c < System.today() && aCon.User_Type__c  == 'Single') {
                             acct.Number_of_Singles_Users__c = acct.Number_of_Singles_Users__c + 1;          
                        }
                    } 
                    acctModifiedMap.put(acct.id, acct);
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