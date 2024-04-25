global class Schedule_OciApiCallouts7 Implements Schedulable,database.allowscallouts
    {
        global void execute(SchedulableContext sc)
        {
            
            ID jobID = System.enqueueJob(new Batch_OciApiCallouts(120000,140000));
        }
    }