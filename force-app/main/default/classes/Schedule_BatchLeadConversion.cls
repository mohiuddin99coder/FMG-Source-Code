global class Schedule_BatchLeadConversion implements Schedulable {
    global void execute(SchedulableContext sc){
        BatchLeadConversion blc = new BatchLeadConversion();
		Database.executeBatch(blc,1);
    }

}