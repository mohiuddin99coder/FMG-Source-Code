global class cls_Schedule_OciApiCallouts Implements Schedulable,database.allowscallouts
    {
        global void execute(SchedulableContext sc)
        {
            
            ID jobID = System.enqueueJob(new Cls_Batch_OciApiCallouts(0,20000));
        }
    }