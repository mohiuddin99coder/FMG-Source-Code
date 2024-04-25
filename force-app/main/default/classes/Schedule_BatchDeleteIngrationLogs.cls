global class Schedule_BatchDeleteIngrationLogs implements Schedulable {
    global void execute(SchedulableContext sc){
        BatchDeleteIntegrationLog bdil = new BatchDeleteIntegrationLog();
        Database.executeBatch(bdil,1);
    }

}