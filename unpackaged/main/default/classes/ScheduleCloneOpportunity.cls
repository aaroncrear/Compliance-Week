global class ScheduleCloneOpportunity implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchCloneOpportunity batch = new BatchCloneOpportunity('', false); 
        database.executebatch(batch);
    }
}