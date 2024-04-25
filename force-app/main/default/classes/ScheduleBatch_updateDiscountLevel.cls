global class ScheduleBatch_updateDiscountLevel implements Schedulable {
    global void execute(SchedulableContext sc) {
        Batch_updateDiscountLevel blc = new Batch_updateDiscountLevel(Date.newInstance(System.now().year(), 6, 30));
        Database.executeBatch(blc,50);
        
    }
}