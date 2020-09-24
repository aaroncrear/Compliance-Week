/**
 * We would like to implement a workflow alert using a Visualforce email template.
 * The email will contain some text content and two buttons, Accept and Decline.
 * The workflow will run from Opportunity Product. If the recipient clicks Accept, the Opportunity stage should change to Closed Won. 
 * If the recipient clicks Decline, a task should be created and assigned to the Opportunity owner.
 * @author : SUY Sreymol
 * @createddate : 09-Jan-2014
 */
global class VisualforceEmailController {
	private String oppLineItemId;
	private String action;
	private Opportunity opp;
	private OpportunityLineItem oli;
	
	public static final String CLOSED_WON_OPP = 'Closed Won';
	public static final String CLOSED_LOST_OPP = 'Closed Lost';
	private static final String DECLINE_RENEWAL_OPP = 'Declined Renewal';
	private static final String returnURL = 'http://www.complianceweek.com';
	private static final String RESPONSE_SUBJECT_TASK = 'Declined Renewal - Follow up call';
	private static final String STATUS_NOTSTARTED_TASK = 'Not Started';
	private static final String STATUS_COMPLTETED_TASK = 'Completed';
	private static final String TYPE_SUB_CALL_TASK = 'Sub | Call';
	private static final String COMMENTS_TASK = 'Subscription due for renewal was declined by the contact. Please follow up with a call.';
	
	public VisualforceEmailController(){
		oppLineItemId = Apexpages.currentPage().getParameters().get('id') == null ? '' : Apexpages.currentPage().getParameters().get('id');
		action = Apexpages.currentPage().getParameters().get('action') == null ? '' : Apexpages.currentPage().getParameters().get('action');
		
		if (oppLineItemId != '') oli = [select OpportunityId, Contact__c From OpportunityLineItem Where Id =: oppLineItemId limit 1];
		if (oli != null) opp = [Select o.StageName, o.OwnerId, Lost_Reason__c, o.Id, o.Products_with_Expiry_Date__c , o.Type From Opportunity o Where Id = : oli.OpportunityId];
	}
	
	/**
	 * To update StageName of Opportunity to Closed Lost and create Task assign to Opportunity Owner if recipient clicks Decline button
	 * To update StageName of Opportunity to Closed Won if recipient clicks Accept button 
	 * @return : returnURL, Pagereference
	 */
	public Pagereference updateOppAndCreateTask() {
		if (oli != null && opp != null) {
			if (opp.StageName.equals(CLOSED_WON_OPP) || opp.StageName.equals(CLOSED_LOST_OPP)) return new Pagereference(returnURL);
			if (action != '') {
				if (action == 'decline') {
					opp.StageName = CLOSED_LOST_OPP;
					opp.Lost_Reason__c = DECLINE_RENEWAL_OPP;
					opp.Closed_Won_Via_Email__c = false;
					// Create a Task after person clicks on decline button
					insert new Task(WhatId = opp.Id, OwnerId = opp.OwnerId, WhoId = oli.Contact__c, Type = TYPE_SUB_CALL_TASK, Subject = RESPONSE_SUBJECT_TASK, Status = STATUS_NOTSTARTED_TASK, Description = COMMENTS_TASK, Priority = 'High');
				} else { 
					opp.StageName = CLOSED_WON_OPP;
					opp.Closed_Won_Via_Email__c = true;
				}
			} 
			update opp;
		}
		
		return new Pagereference(returnURL);
	}
	
	/**
	 * To send email to all Contact that relate to Opportunity Product.
	 * This method call by custom button 'Send Renewal Reminder' on Opportunity detail page.
	 * @param : oppId, String
	 * @return : String
	 */
	WebService static String sendMail(String oppId) {
		oppId = String.escapeSingleQuotes(oppId);
		oppId = oppId.trim();
		String status = 'fail';
		
		// Get email template id
		EmailTemplate etp = [Select e.Id, e.DeveloperName, e.HtmlValue From EmailTemplate e Where DeveloperName = 'Contacts_Email'];
		
		// Get organisation email address
		OrgWideEmailAddress orgEmail = [Select o.Id, o.DisplayName, o.Address From OrgWideEmailAddress o limit 1];
		
		// Get Product recordType
		RecordType rt = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r Where SobjectType = 'Product2' and DeveloperName = 'Subscription' limit 1];
		
		// List of task to be insert
		List<Task> ts = new List<Task>();
		// Set of emails address
		Set<String> emailAddress = new Set<String>();
		
		// Get all Contact that relate to each Opportunity Product and send mail to them
		for (OpportunityLineItem oli : [Select id, Contact__c, Contact__r.Email, PricebookEntry.Product2Id, PricebookEntryId, 
										PricebookEntry.Product2.Family, PricebookEntry.Product2.RecordTypeId, UnitPrice    
										From OpportunityLineItem 
										Where (OpportunityId = : oppId And Contact__c != null And Contact__r.Email != null And PricebookEntry.Product2.RecordTypeId = : rt.Id And UnitPrice > 0)]) {
			// Check to avoid sending duplicate email to a contact
			if (!emailAddress.contains(oli.Contact__r.Email)) {
				// create a mail object to send a single email.
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				// set the email properties
				mail.setToAddresses(new string[] {oli.Contact__r.Email});
				//Setting Target Ids
		        mail.setTargetObjectId(oli.Contact__c);
		        // To use setWhatId() method, set saveAsActivity to false
		        mail.saveAsActivity = false;
		        // To set relatedToType in email template
		        mail.setWhatId(oli.Id);
		        // to set email of sender
		        if (orgEmail != null) mail.setOrgWideEmailAddressId(orgEmail.Id);
		        // Set email template to mail object 
		        if (etp != null) mail.setTemplateId(etp.id);
		       	//send the email to Contact of Opportunity Product
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail } );
				emailAddress.add(oli.Contact__r.Email);
				ts.add(new Task(WhatId = oppId, WhoId = oli.Contact__c, Type = 'Sub | Email', Subject = 'Renewal Email Sent', Status = 'Completed', Description = 'Sent by ' + orgEmail.DisplayName, ActivityDate = system.today()));
			}
		}
		// Create new Task when email send
		if (!ts.isEmpty()){
			insert ts;
			status =  'success';
		}
		
		return status;
	}
}