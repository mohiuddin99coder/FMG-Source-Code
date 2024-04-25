@isTest

public class Schedule_BatchDeleteLeadsIntgLogTest {

    @isTest
    static void testScheduleBatchDeleteLeads() {
        // Create test data if needed
        
        // Start the scheduled job
        Test.startTest();
        String leadJobId = System.schedule('Test Batch Delete Leads', '0 0 * * * ?',new Schedule_BatchDeleteLeads());
        String IntegrationLogJobId = System.schedule('Test Batch Delete Integration Logs', '0 0 * * * ?',new Schedule_BatchDeleteIngrationLogs());
        Test.stopTest();
        
          }


}