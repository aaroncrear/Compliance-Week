global class CreateUpgradeOpportunity {
	public static final String SUBSCRIPTIONRECORDTYPE = 'Subscriptions_Opportunity';
	public static final String BUSINESSTYPE_RENEWAL   = 'Renewal';
	public static final String STAGE_PROPOSAL = 'Proposal/Price Quote';
	public static final String BUSINESSTYPE_UPGRADE   = 'Upgrade';
	public static final String BUSINESSUNIT           = 'Compliance Week';
	public static final String OPP_TYPE 			  = 'Subscription';
	webservice static String CreateUpgradeOpportunity(String id) {
		Subscription_NEW__c sub = [select id,Renewal_Opportunity__c,Name,Account__r.Name, Renewal_Opportunity__r.Business_Type__c,Expiration_Date__c from Subscription_NEW__c where id =: id];
		if((sub.Renewal_Opportunity__c != null && sub.Renewal_Opportunity__r.Business_Type__c != null && sub.Renewal_Opportunity__r.Business_Type__c.equalsIgnoreCase(BUSINESSTYPE_RENEWAL)) || (sub.Expiration_Date__c != null && sub.Expiration_Date__c <= System.today()+90)) return 'false';
		 RecordType recordType = [select id from RecordType where DeveloperName =: SUBSCRIPTIONRECORDTYPE];
		 Opportunity opp = new Opportunity(Name 			= sub.Account__r.Name+' - '+sub.Name+' - Upgrade', 
					 						RecordTypeId	= recordType.Id, 
					 						AccountId		= sub.Account__c, 
					 						Type			= OPP_TYPE, 
					 						Business_Type__c= BUSINESSTYPE_UPGRADE, 
					 						CloseDate		= System.today(),
					 						StageName 		= STAGE_PROPOSAL,
					 						Business_Unit__c= BUSINESSUNIT);
		 insert opp;
		 sub.Renewal_Opportunity__c = opp.Id;
		 //sub.Upgraded__c            = true;
		 update sub;
		 return opp.Id ;
	}
}