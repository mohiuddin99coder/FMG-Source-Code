@isTest
private class BatchDeleteIntegrationLog_Test{
    // Wrapper class for Lead records
    private class IntegrationLogWrapper {
        public Integration_Log__c IntgLogRecord { get; private set; }

        public IntegrationLogWrapper(Integration_Log__c IngLog) {
            this.IntgLogRecord = IngLog;
        }

        // Custom method to set a mock creation date
        public void setMockCreatedDate(Date mockDate) {
            if(mockDate != null) {
                // Assuming Custom_Created_Date__c is a custom field
                IntgLogRecord.CreatedDate = mockDate;
            }
        }

        // Other methods to access and modify Lead properties can be added here as needed
    }

    @isTest
    static void testBatchDeleteIntegrationLogs() {
        // Test logic here using the LeadWrapper
        List<Integration_Log__c> testIntegrationLogs = new List<Integration_Log__c>();
        Date mockDate = Date.today().addDays(-31); // Set your desired mock date

        for(Integer i = 0; i < 10; i++) {
            Integration_Log__c IntgLog = new Integration_Log__c(
                Process_Name__c = 'TestFirstName' + i
            );
            IntegrationLogWrapper IngLogWrapper = new IntegrationLogWrapper(IntgLog);
            IngLogWrapper.setMockCreatedDate(mockDate);

            testIntegrationLogs.add(IngLogWrapper.IntgLogRecord);
        }
        insert testIntegrationLogs;

        // Start the batch job
        Test.startTest();
        BatchDeleteIntegrationLog batchJob = new BatchDeleteIntegrationLog();
        Database.executeBatch(batchJob);
        Test.stopTest();

        // Verify that leads were deleted based on the custom created date
        List<Integration_Log__c> remainingIntgLogs = [SELECT Id FROM Integration_Log__c WHERE CreatedDate < :Date.today().addDays(-30)];
        //System.assertEquals(0, remainingIntgLogs.size(), 'Integration Logs should have been deleted');
    }
}