@isTest
public class GiftCertificateOCAPITest {
    private class MockHttpResponse implements HttpCalloutMock {
        private Integer statusCode;
        private String status;
        private String responseBody;
        
        public MockHttpResponse(Integer statusCode, String status, String responseBody) {
            this.statusCode = statusCode;
            this.status = status;
            this.responseBody = responseBody;
        }
        
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(statusCode);
            response.setStatus(status);
            response.setBody(responseBody);
            return response;
        }
    }
    
    @isTest
    public static void testCreateIntegrationLogRecord() {
        
        Test.startTest();
        Integration_Log__c gcRecord = APICallOutLogsCreation.createIntegrationLogRecord(
            'reqBody', 'resBody', 'exceptionMsg', 'processName', 'endPoint', 'status'
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
            new List<String>{ '00009011' }
        };
            List<List<String>> emptyMerchantIDs = new List<List<String>>();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, 'OK', '{"_v": "23.2","_type": "customer","auth_type": "guest","customer_id": "acdY210a8VTJoXn7SoEwxnOSwD","preferred_locale": "default","visit_id": "7b2b02da5ef42a593157b06da7"}'));
        
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
        GiftCertificateOCAPI.OCAPIGenerateAccessToken(new List<String>{ '00009011' });
        GiftCertificateOCAPI.OCAPIGenerateAccessToken(new List<String>{ '00009011' });
        Test.stopTest();
        // Assert the expected behavior
        
        // Test case 2: Exception occurred during the API call
        // Assert the expected behavior
    }
    
    @isTest
    public static void testUpdateGiftCertificate() {
        
        /*MockHttpResponse1 mock= new MockHttpResponse1(200, 'Ok', 'Res Body', new Map<String,string>());
Test.setMock(HttpCalloutMock.class, mock);*/
        // Test case 1: Successful API call
        Test.startTest();
        GiftCertificateOCAPI.updateGiftCertificate('bearerToken', new List<String>{ '00009011' });
        GiftCertificateOCAPI.updateGiftCertificate('bearerToken', new List<String>{ '00009011' });
        Test.stopTest();
        // Assert the expected behavior
        
        // Test case 2: Exception occurred during the API call
        
        // Assert the expected behavior
    }
}

/*
 @isTest
public class GiftCertificateOCAPITest {
    @isTest
    public static void testCreateIntegrationLogRecord() {
        Test.startTest();
        Integration_Log__c gcRecord = APICallOutLogsCreation.createIntegrationLogRecord(
            'reqBody', 'resBody', 'exceptionMsg', 'processName', 'endPoint', 'status'
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
}*/