@isTest

public class Schedule_BatchDeleteLeadsTest {

    @isTest
    static void testScheduleBatchDeleteLeads() {
        // Create test data if needed
        
        // Start the scheduled job
        Test.startTest();
        String jobId = System.schedule('Test Batch Delete Leads', '0 0 * * * ?',new Schedule_BatchDeleteLeads());
        Test.stopTest();
        
          }


}