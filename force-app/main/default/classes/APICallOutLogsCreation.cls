public class APICallOutLogsCreation {
    public static Integration_Log__c createIntegrationLogRecord(Set<String> RecordIds,string reqBody,string resBody,string exceptionMsg,String processName,string endPoint,String status){
        String RecordId;
        for(String s : RecordIds){
            RecordId =  RecordId+','+s;
        }
        
        Integration_Log__c gcRecord = new Integration_Log__c();
            gcRecord.Request__c = reqBody;
            gcRecord.Record_Id_List__c = RecordId;
            gcRecord.Response__c = resBody;
            gcRecord.End_Point__c =endPoint;
            gcRecord.Process_Name__c=processName;
            gcRecord.Retry_Count__c= 0;
            gcRecord.Status__c=status;
            gcRecord.Remarks__c = exceptionMsg;
        return gcRecord;    
    }
    
    
	public static Integration_Log__c createIntegrationLogRecord(string reqBody,string resBody,string exceptionMsg,String processName,string endPoint,String status){
      
        Integration_Log__c gcRecord = new Integration_Log__c();
            gcRecord.Request__c = reqBody;
            //gcRecord.Record_ID__c = RecordId;
            gcRecord.Response__c = resBody;
            gcRecord.End_Point__c =endPoint;
            gcRecord.Process_Name__c=processName;
            gcRecord.Retry_Count__c= 0;
            gcRecord.Status__c=status;
            gcRecord.Remarks__c = exceptionMsg;
        return gcRecord;    
    }    
    
    
}