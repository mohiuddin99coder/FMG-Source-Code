@isTest
public class APICallOutLogsCreationTest {
    @isTest
    public static void testCreateIntegrationLogRecord() {
        Test.startTest();
        Set<String> ids  = new Set<String>();
        ids.add('1111');
        ids.add('22222');
        Integration_Log__c gcRecord = APICallOutLogsCreation.createIntegrationLogRecord(
            ids,'reqBody', 'resBody', 'exceptionMsg', 'processName', 'endPoint', 'status'
        );
        Test.stopTest();

        System.assertEquals('reqBody', gcRecord.Request__c);
        System.assertEquals('resBody', gcRecord.Response__c);
        System.assertEquals('exceptionMsg', gcRecord.Remarks__c);
        // Assert other field values as needed
    }

    @isTest
    public static void testOrderSummaryRelatedOPS() {
        // Test case 1: merchantIDsList is not empty
        List<List<String>> merchantIDs = new List<List<String>>{
            new List<String>{ 'merchantID1', 'merchantID2' }
        };
            List<List<String>> emptyMerchantIDs = new List<List<String>>();
        Test.startTest();
        GiftCertificatePaymentCaptrure.OrderSummaryRelatedOPS(merchantIDs);
        GiftCertificatePaymentCaptrure.OrderSummaryRelatedOPS(emptyMerchantIDs);
        Test.stopTest();
        // Assert the expected behavior
        
        // Test case 2: merchantIDsList is empty
        // Assert the expected behavior
    }

    @isTest
    public static void testOCAPIGenerateAccessToken() {
        // Test case 1: Successful API call
        Test.startTest();
        GiftCertificateOCAPI.OCAPIGenerateAccessToken(new List<String>{ 'merchantID1', 'merchantID2' });
        GiftCertificateOCAPI.OCAPIGenerateAccessToken(new List<String>{ 'merchantID1', 'merchantID2' });
        Test.stopTest();
        // Assert the expected behavior
        
        // Test case 2: Exception occurred during the API call
        // Assert the expected behavior
    }
    
    @isTest
    public static void testUpdateGiftCertificate() {
        // Test case 1: Successful API call
        Test.startTest();
        GiftCertificateOCAPI.updateGiftCertificate('bearerToken', new List<String>{ 'merchantID1', 'merchantID2' });
        GiftCertificateOCAPI.updateGiftCertificate('bearerToken', new List<String>{ 'merchantID1', 'merchantID2' });
        Test.stopTest();
        // Assert the expected behavior
        
        // Test case 2: Exception occurred during the API call

        // Assert the expected behavior
    }
}