global class AccountRollupJob implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        AccountRollupBatch arb = new AccountRollupBatch();
        Id batchId = Database.executeBatch(arb);
    }

}