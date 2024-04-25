@isTest
private class BatchDeleteProcessedLeadsTest{
    // Wrapper class for Lead records
    private class LeadWrapper {
        public Lead leadRecord { get; private set; }

        public LeadWrapper(Lead lead) {
            this.leadRecord = lead;
        }

        // Custom method to set a mock creation date
        public void setMockCreatedDate(Date mockDate) {
            if(mockDate != null) {
                // Assuming Custom_Created_Date__c is a custom field
                leadRecord.CreatedDate = mockDate;
            }
        }

        // Other methods to access and modify Lead properties can be added here as needed
    }

    @isTest
    static void testBatchDeleteProcessedLeads() {
        // Test logic here using the LeadWrapper
        List<Lead> testLeads = new List<Lead>();
        Date mockDate = Date.today().addDays(-31); // Set your desired mock date

        for(Integer i = 0; i < 10; i++) {
            Lead lead = new Lead(
                FirstName = 'TestFirstName' + i,
                LastName = 'TestLastName' + i,
                Mapped_to_Existing_Account__c = true
            );

            LeadWrapper leadWrapper = new LeadWrapper(lead);
            leadWrapper.setMockCreatedDate(mockDate);

            testLeads.add(leadWrapper.leadRecord);
        }
        insert testLeads;

        // Start the batch job
        Test.startTest();
        BatchDeleteProcessedLeads batchJob = new BatchDeleteProcessedLeads();
        Database.executeBatch(batchJob);
        Test.stopTest();

        // Verify that leads were deleted based on the custom created date
        List<Lead> remainingLeads = [SELECT Id FROM Lead WHERE Mapped_to_Existing_Account__c = true AND CreatedDate < :Date.today().addDays(-30)];
        System.assertEquals(0, remainingLeads.size(), 'Leads should have been deleted');
    }
}