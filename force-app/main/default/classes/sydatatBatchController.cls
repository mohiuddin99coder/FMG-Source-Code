public with sharing class sydatatBatchController {

public class FlowInput {
        @InvocableVariable
        public String fromLodId;
        @InvocableVariable
        public String fromLocNum;
        @InvocableVariable
        public String comment;
        @InvocableVariable
        public String toLocId;
        @InvocableVariable
        public String toLocNum;
        @InvocableVariable
        public String vToLocation;
        @InvocableVariable
        public String vFromLocation;
        @InvocableVariable
        public String vItemNumber;
	}

    public class FlowOutput {
        @InvocableVariable 
        public List<rstk__sydatat__c> outputSYDATAT;
    }

    @InvocableMethod(label='Process Sydatat Records' description='Process Sydatat records and return result')
    public static List<FlowOutput> processRecords(List<FlowInput> flowinput) {
            List<rstk__iclocitem__c> locRecords = [Select Id, Name, rstk__iclocitem_proj__c, rstk__iclocitem_site__c, rstk__iclocitem_div__c, rstk__iclocitem_icitem__c, rstk__iclocitem_icitem__r.Name,rstk__iclocitem_locqty__c, rstk__iclocitem_locid__c, rstk__iclocitem_locid__r.Name, rstk__iclocitem_locnum__c from rstk__iclocitem__c where rstk__iclocitem_locqty__c>0 and  rstk__iclocitem_locid__c=:flowinput[0].fromLodId and rstk__iclocitem_locnum__c=:flowinput[0].fromLocNum limit 250];
            List<rstk__sydatat__c> recordsToInsert = new List<rstk__sydatat__c>();
            List<FlowOutput> flowOutputList = new List<FlowOutput>();
       		FlowOutput flowOutput = new FlowOutput(); 
            if(!locRecords.isEmpty()){
                for (rstk__iclocitem__c record : locRecords) {
                    rstk__sydatat__c newSYDATATRecord = new rstk__sydatat__c();
                    System.debug('record'+record);
                    newSYDATATRecord.rstk__sydata_process__c = 'Hold';
                    newSYDATATRecord.rstk__sydata_fromlocid__c = record.rstk__iclocitem_locid__c;
                    newSYDATATRecord.rstk__sydata_fromlocnum__c = record.rstk__iclocitem_locnum__c; 
                    newSYDATATRecord.rstk__sydata_txnqty__c = record.rstk__iclocitem_locqty__c;
                    newSYDATATRecord.rstk__sydata_icitem__c = record.rstk__iclocitem_icitem__c;
                    newSYDATATRecord.rstk__sydata_tolocid__c = flowinput[0].toLocId;
                    newSYDATATRecord.rstk__sydata_tolocnum__c = flowinput[0].toLocNum;
                    newSYDATATRecord.rstk__sydata_fromproj__c = record.rstk__iclocitem_proj__c;
                    newSYDATATRecord.rstk__sydata_toproj__c = record.rstk__iclocitem_proj__c;
                    newSYDATATRecord.rstk__sydata_fromsite__c = record.rstk__iclocitem_site__c;
                    newSYDATATRecord.rstk__sydata_tosite__c = record.rstk__iclocitem_site__c;
                    newSYDATATRecord.rstk__sydata_txnid__c = 'INVLOCLOC';
                    newSYDATATRecord.rstk__sydata_txntype__c = 'Inventory Transfer';
                    newSYDATATRecord.Comment__c = flowinput[0].comment;
                    newSYDATATRecord.rstk__sydata_fromdiv__c = record.rstk__iclocitem_div__c;
                    newSYDATATRecord.rstk__sydata_todiv__c = record.rstk__iclocitem_div__c;
                    newSYDATATRecord.vTo_Location__c = flowinput[0].vToLocation;
                    newSYDATATRecord.vFrom_Location__c = flowinput[0].vFromLocation;
                    newSYDATATRecord.vItemNumber__c = record.rstk__iclocitem_icitem__r.Name;
                    recordsToInsert.add(newSYDATATRecord);
                }
                flowOutput.outputSYDATAT = recordsToInsert;
                flowOutputList.add(FlowOutput);
                system.debug(flowOutputList);
            }
            return flowOutputList;
        } 
    /*public static void processBatch(List<rstk__sydatat__c> recordsToInsert) { // Corrected parameter type
        if (!recordsToInsert.isEmpty()) {
            try {
                insert recordsToInsert;
                // Handle results if needed
            } catch (Exception ex) {
                // Handle exceptions
            }
        } else {
            // Handle case where there are no records to insert
        }      
    }*/
}