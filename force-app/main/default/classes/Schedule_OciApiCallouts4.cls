global class Schedule_OciApiCallouts4 Implements Schedulable,database.allowscallouts
    {
        global void execute(SchedulableContext sc)
        {
            
            ID jobID = System.enqueueJob(new Batch_OciApiCallouts(60000,80000));
        }
    }