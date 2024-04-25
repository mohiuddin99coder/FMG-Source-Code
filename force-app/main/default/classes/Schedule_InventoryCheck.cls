global class Schedule_InventoryCheck implements Schedulable{
    global void execute(SchedulableContext sc){
        BatchInventoryCheckJob BIC = new BatchInventoryCheckJob();
        database.executeBatch(BIC,1);
    }
}