Global class CalculateExpiredContactJob implements Schedulable {
    global void execute(SchedulableContext sc) {
		CalculateExpiredContacts calcExpContacts = new CalculateExpiredContacts();
		calcExpContacts.updateAccounts();
    }
}