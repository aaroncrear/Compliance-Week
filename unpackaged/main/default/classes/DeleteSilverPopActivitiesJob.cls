Global class DeleteSilverPopActivitiesJob implements Schedulable {
    global void execute(SchedulableContext sc) {
        DeleteSilverPopActivities uca = new DeleteSilverPopActivities();
        Id batchId = Database.executeBatch(uca);
    }

}