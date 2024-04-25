global class Schedule_OciApiCallouts8 Implements Schedulable,database.allowscallouts
    {
        global void execute(SchedulableContext sc)
        {
            
            ID jobID = System.enqueueJob(new Batch_OciApiCallouts(140000,160000));
        }
    }