global class Schedule_BatchDeleteLeads implements Schedulable {
    global void execute(SchedulableContext sc){
        BatchDeleteProcessedLeads bdl = new BatchDeleteProcessedLeads();
		Database.executeBatch(bdl,1);
    }

}