global class ScheduleBatchDailyOCI Implements Schedulable,Database.AllowsCallouts{
        public Integer startNumber;
        public Integer endNumber;
        global ScheduleBatchDailyOCI(Integer startNumber,Integer endNumber){
            this.startNumber= startNumber;
            this.endNumber= endNumber;
        }
        global void execute(SchedulableContext sc){
            ID jobID = System.enqueueJob(new Batch_OciApiCallouts(startNumber,endNumber));
        }
        
    }