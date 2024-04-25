global class Schedule_OciApiCallouts6 Implements Schedulable,database.allowscallouts
    {
        global void execute(SchedulableContext sc)
        {
            
            ID jobID = System.enqueueJob(new Batch_OciApiCallouts(100000,120000));
        }
    }