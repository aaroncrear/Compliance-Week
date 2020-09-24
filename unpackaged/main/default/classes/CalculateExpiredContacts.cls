public class CalculateExpiredContacts {
    
    public void updateAccounts() {
        List<Account> acctUpdateList = new List<Account>();
        List<Contact> expiredCons = [Select Id, AccountID, User_type__c from Contact where Expiration_Date__c =: System.today()];
        Map<ID, Contact> AcctIDMap = new Map<ID, Contact>();
        for (Contact aCon: expiredCons) {
            AcctIDMap.put(aCon.AccountID, aCon);
        }
        Map<ID, Account> acctsToUpdate = new Map<ID, Account>([select ID, Number_of_Multi_Users__c, Number_of_Singles_Users__c from Account where ID IN: AcctIDMap.keySet()]);
        for (Contact aCon: expiredCons) {
            Account acct = acctsToUpdate.get(aCon.AccountId);
            if (aCon.User_Type__c != null && aCon.User_Type__c.contains('Multi')) {
                acct.Number_of_Multi_Users__c = acct.Number_of_Multi_Users__c - 1;
            } else if (aCon.User_Type__c != null && aCon.User_Type__c == 'Single' ) {
                acct.Number_of_Singles_Users__c = acct.Number_of_Singles_Users__c - 1;
            }
        }
        
        for(ID acctID : acctsToUpdate.keySet()) {
            acctUpdateList.add(acctsToUpdate.get(acctID));
        }
        update acctUpdateList;
    }

}