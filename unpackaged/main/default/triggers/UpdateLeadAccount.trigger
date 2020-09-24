trigger UpdateLeadAccount on Lead (before insert) {
    System.debug('Lead Insert Before');
    Map<String, ID> ConEmailMap = new Map<String, ID>();
    for (Account acct: [select id, 	Email_Domain__c from Account where Email_Domain__c !=null]) {
        ConEmailMap.put(acct.Email_Domain__c, acct.id);
        system.debug('acct.Email_Domain__c = ' + acct.Email_Domain__c);
    }
    /**
    for (Contact acon: [select AccountId, Email from Contact where AccountId !=null and Email !=null and Deliverability__c  = 'Active' and  (NOT email  like '%gmail.com') and  (NOT email  like '%yahoo.com') and  (NOT email  like '%hotmail.com')]) {
        Integer startIndex = acon.Email.indexOf('@');
        Integer endIndex = aCon.Email.length();
        String emailDomain = aCon.Email.subString(startIndex, endIndex);
        ConEmailMap.put(emailDomain, aCon.AccountId);
    }*/
    for(Lead aLead : Trigger.new) { 
        if(aLead.Account__c == null && aLead.email != null) {
            Integer startIndex = aLead.Email.indexOf('@');
            Integer endIndex = aLead.Email.length();
            String emailDomain = aLead.Email.subString(startIndex + 1 , endIndex);
            if (ConEmailMap.get(emailDomain) !=null) {
                System.debug('Found Email match');
                aLead.Account__c = ConEmailMap.get(emailDomain);
                //aLead.OwnerId = userinfo.getUserId();
            }
        }
    }
}