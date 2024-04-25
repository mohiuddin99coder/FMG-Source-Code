global class Schedule_OciApiCallouts Implements Schedulable,Database.AllowsCallouts{
    global void execute (SchedulableContext sc){
        
        List<OCI_Job__mdt> metadataRecords = [SELECT Id,MasterLabel, Start_Count__c,End_Count__c,Hours__c,Minutes__c FROM OCI_Job__mdt ORDER BY MasterLabel ASC];
        System.debug('metadataRecords--->'+metadataRecords);
        for (OCI_Job__mdt prodCount : metadataRecords) {
            System.debug('OCI_Job__mdt inside for--->'+ prodCount);
            String jobName = 'Schedule OCI Job';
            System.debug('jobName--->'+jobName);
            // Construct the cron expression based on offsetTime
            String cronExpression = '0 ' + Integer.valueOf(prodCount.Minutes__c) + ' ' + Integer.valueOf(prodCount.Hours__c) + ' * * ?';
            System.debug('cronExpression'+cronExpression);
            if(!Test.isRunningTest()){
	            System.schedule(prodCount.MasterLabel, cronExpression, new ScheduleBatchDailyOCI(Integer.valueOf(prodCount.Start_Count__c),Integer.valueOf(prodCount.End_Count__c)));
            }
            else{
               System.schedule('IsRunningTest'+ prodCount.MasterLabel, cronExpression, new ScheduleBatchDailyOCI(Integer.valueOf(prodCount.Start_Count__c),Integer.valueOf(prodCount.End_Count__c)));
               
            }
            
        }
        
    }
   
    
    
}