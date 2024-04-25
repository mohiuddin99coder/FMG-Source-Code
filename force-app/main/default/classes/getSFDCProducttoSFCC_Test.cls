@IsTest
public class getSFDCProducttoSFCC_Test {
     public class MockFulfillmentOrderWebService implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"orderSummaryId": "mock_order_summary_id"}');
            res.setStatusCode(200);
            return res;
        }
    }
    @IsTest
    public static void testLocationUpdate() {
        List<Product2> productList = New List<Product2>();
        
      for(integer i = 1 ; i < 100 ; i++){
    Product2 test = new Product2();
    test.Name = 'testQ' + i ;
    test.StockKeepingUnit = 'testQ' + i ;
    test.IsActive = true;
    test.Description = 'testQ' + i ;
    productList.add(test);
    } 
        
        insert productList ;
        
        Test.startTest();
        Integration_Log__c gcRecord = APICallOutLogsCreation.createIntegrationLogRecord(
            'reqBody', 'resBody', 'exceptionMsg', 'processName', 'endPoint', 'status'
        );
        getSFDCProducttoSFCC.getProductdetails(productList);
        Test.setMock(HttpCalloutMock.class, new MockFulfillmentOrderWebService());
        //ProductOMSSFCC.OCAPIGenerateAccessToken();
        Test.stopTest();
        
    }
    
    @IsTest
    public static void testAccessTokenWrapper() {
        Test.startTest();
        Rest_getAccessTokenWrapper accessWrap = new Rest_getAccessTokenWrapper();
        accessWrap.access_token='1234';
        Test.stopTest();
    }
}