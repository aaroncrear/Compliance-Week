trigger UpdateContactsOnAccount on Account (before Update) {

    List<Contact> Contactlist = [select id, Accountid, User_Type__c, Expiration_Date__c from contact where AccountID In :trigger.new];
    List<Lead> leadList = [select id, Account__c, Status from Lead where Account__c In :trigger.new ];
    system.Debug('Starting Trigger UpdateContactsOnAccount');
    for(account acct:trigger.new) {
        system.Debug('acct.id = '  + acct.id);
        acct.Number_of_Singles_Users__c = 0;
        acct.Number_of_Multi_Users__c = 0;
        acct.Number_Of_Contacts__c = 0;
        acct.Number_of_Leads__c = 0;
        map<id, integer> allCountMap = new map<id, integer>();
        map<id, integer> singleCountMap = new map<id, integer>();
        map<id, integer> multiCountMap = new map<id, integer>();
        map<id, integer> allLeadCountMap = new map<id, integer>();
        integer iAll = 1;
        integer iSingle = 0;
        integer iMulti = 0;
        integer iLeads = 0;
        system.Debug('iAll = '  + iAll);
        system.Debug('iLeads = '  + iLeads);
        for(Contact aCon:contactlist) {
            if(aCon.AccountId == acct.id) {
                if(allCountMap.containskey(acct.id)) {
                    iAll = allCountMap.get(acct.id) +1;
                    allCountMap.put(acct.id, iAll);
                    if (aCon.User_Type__c != null && aCon.User_Type__c.contains('Multi') && aCon.Expiration_Date__c != null && aCon.Expiration_Date__c > System.today()) {
                        iMulti = multiCountMap.get(acct.id) +1;
                        multiCountMap.put(acct.id, iMulti);
                    } else if (aCon.User_Type__c != null && aCon.User_Type__c == 'Single' && aCon.Expiration_Date__c != null && aCon.Expiration_Date__c > System.today()) {
                        iSingle = singleCountMap.get(acct.id) +1;
                        singleCountMap.put(acct.id, iSingle);
                    }
                } else {
                    allCountMap.put(acct.id, iAll);
                    if (aCon.User_Type__c != null && aCon.User_Type__c.contains('Multi') && aCon.Expiration_Date__c != null && aCon.Expiration_Date__c > System.today()) {
                        multiCountMap.put(acct.id, iMulti +1);
                    } else {
                        multiCountMap.put(acct.id, iMulti);
                    }
                        
                    if (aCon.User_Type__c != null && aCon.User_Type__c == 'Single' && aCon.Expiration_Date__c != null && aCon.Expiration_Date__c > System.today()) {
                        singleCountMap.put(acct.id, iSingle +1);
                    } else {
                        singleCountMap.put(acct.id, iSingle); 
                    }
                }
            }
        }
        
        for(Lead aLead:leadList) {
            system.Debug('found Lead');
            if(aLead.Account__c == acct.Id) {
                system.Debug('found Lead for Acct');
                if (aLead.Status != 'Converted') {
                    system.Debug('passed Converted Test');
                    if(allLeadCountMap.containskey(acct.id)) {
                            iLeads = allLeadCountMap.get(acct.id) +1;
                            allLeadCountMap.put(acct.id, iLeads);
                            system.Debug('adding More');
                    } else {
                            allLeadCountMap.put(acct.id, iLeads +1);
                            system.Debug('adding First');
                    }
                }
            }
        }
    
        if(allCountMap.containskey(acct.id)) {
            acct.Number_Of_Contacts__c = allCountMap.get(acct.id);
            acct.Number_of_Singles_Users__c = singleCountMap.get(acct.id);
            acct.Number_of_Multi_Users__c = multiCountMap.get(acct.id);
            system.Debug('iAll2 = '  + iAll);
            //system.Debug('allCountMap.get(acct.id) = '  + allCountMap.get(acct.id));
            
        }
        if (allLeadCountMap.containskey(acct.id)){
            acct.Number_of_Leads__c = allLeadCountMap.get(acct.id);
            //system.Debug('acct.id = '  + acct.id);
            system.Debug('iLeads2 = '  + iLeads);
            //system.Debug('allLeadCountMap.get(acct.id) = '  + allLeadCountMap.get(acct.id));
        }
        allCountMap = null;
        singleCountMap = null;
        multiCountMap = null;
        allLeadCountMap = null;
        iAll = 1;
        iSingle = 0;
        iMulti = 0;
        iLeads = 1;
    }
}