trigger ContactTrigger on Contact (after insert, after update) {
	PrintRunMember.createOnContact(Trigger.old, Trigger.new);
}