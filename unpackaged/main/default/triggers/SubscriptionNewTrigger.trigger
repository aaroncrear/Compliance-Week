/**
  * When a Subscription is created, the Expiration Date field on Contact should be updated with 
  * the Expiration Date on the new Subscription record (assuming it is the greatest date of all Subscriptions associated with that Contact).
  * User Type should also be updated:
  * If new subscription Type = Multi, User Type = Multi
  * If new Subscription Type = Single, User Type = Single
  * Create date: 31/12/2013
  */
trigger SubscriptionNewTrigger on Subscription_NEW__c (after insert, after update, after delete) {
    final String SUB_MULTI_TYPE = 'Multi';
    final String SUB_SINGLE_TYPE = 'Single';
    
    if(Trigger.isDelete){
        //group contact with subscription delete
        Map<String, List<Subscription_NEW__c>> mapSub = new Map<String,List<Subscription_NEW__c>>();
        for(Subscription_NEW__c sub : Trigger.old){
            List<Subscription_NEW__c> lstSub = mapSub.get(sub.Contact__c);
            if(lstSub == null) lstSub = new List<Subscription_NEW__c>();
            lstSub.add(sub);
            mapSub.put(sub.Contact__c, lstSub);
        }
        //check if contact expiredate equal the deleted subscription expired date , => update contact expired date to null
        List<Contact> lstCon = new List<Contact>();
        for(Contact con : [select Expiration_Date__c from Contact where id IN: mapSub.keySet()]){
            if(!mapSub.containsKey(con.Id)) continue;
            for(Subscription_NEW__c sub : mapSub.get(con.Id)){
                if(sub.Expiration_Date__c == con.Expiration_Date__c) lstCon.add(new Contact(id = con.Id, Expiration_Date__c = null));
            }
        }   
        if(!lstCon.isEmpty()) update lstCon;
    }else{
        Set<String> sContact = new Set<String>();
        for(Subscription_NEW__c sub : Trigger.new){
            sContact.add(sub.Contact__c);
        }
        List<Contact> lstCon = new List<Contact>();
        for(Contact con : [select Expiration_Date__c,Id,User_Type__c, (Select Expiration_Date__c,Type__c From Subscriptions_NEW__r order by Expiration_Date__c Desc limit 1) from Contact where id IN: sContact]){
            if(con.Subscriptions_NEW__r.isEmpty()) continue;
            con.Expiration_Date__c = con.Subscriptions_NEW__r[0].Expiration_Date__c;
            con.User_Type__c       = (con.Subscriptions_NEW__r[0].Type__c != null?(con.Subscriptions_NEW__r[0].Type__c == SUB_MULTI_TYPE? SUB_MULTI_TYPE:SUB_SINGLE_TYPE):null);
            lstCon.add(con);
        }
        if(!lstCon.isEmpty()) update lstCon;
    }
    
}