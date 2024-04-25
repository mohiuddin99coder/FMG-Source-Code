global class Schedule_OciApiCallouts2 Implements Schedulable,database.allowscallouts
    {
        global void execute(SchedulableContext sc)
        {
            
            ID jobID = System.enqueueJob(new Batch_OciApiCallouts(20000,40000));
        }
    }