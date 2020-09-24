trigger PublicationIssue on Publication_Issue__c (after update) {
	PrintRunMember.createOnPublicationIssue(Trigger.old, Trigger.new);
}