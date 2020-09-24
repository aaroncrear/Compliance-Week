trigger PrintRun on Print_Run__c (after insert, after update) {
	if(Trigger.isInsert){
		PrintRunMember.createOnPrintRunInsert(Trigger.new, NULL); 
	}else{
		PrintRunMember.createOnPrintRunUpdate(Trigger.old, Trigger.new);
	} 
}