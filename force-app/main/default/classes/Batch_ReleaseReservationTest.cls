@isTest(SeeAllData=true)
public class Batch_ReleaseReservationTest {
    public class MockOCIWebService implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"OCI": "Release_Reservations"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    static void check() {
        List<Product2> productList = new List<Product2>();
        List<String> productSkuList = new List<String>();
        Map<String, Decimal> locationLevelReservations = new Map<String, Decimal>();
        Map<String, Decimal> grpLevelReservations = new Map<String, Decimal>();
        for (Integer i = 1; i <= 10; i++) {
            Product2 p = new Product2();
            p.Name = 'ABC';
            p.Description = 'Test Product199';
            p.ProductCode = 'ABCD';
            p.IsActive = true;
            p.Family = 'ABC';
            p.StockKeepingUnit = 'ABC123' + i;
            productList.add(p);
        }
        Insert productList;
        
        for (Product2 product : productList) {
            productSkuList.add(product.StockKeepingUnit);
            locationLevelReservations.put(product.StockKeepingUnit,2);

        }
               
        String location = [SELECT Location__c FROM OCILocationGroup__c LIMIT 1].Location__c;
        String locationGroup = [SELECT LG_ExternalRef__c FROM OCILocationGroup__c LIMIT 1].LG_ExternalRef__c;
        system.debug('locationGroup:'+locationGroup);
        Test.setMock(HttpCalloutMock.class, new MockOCIWebService());
        
        Test.startTest();
        // ReleaseReservationAtLocation
        Batch_ReleaseReservationAtLocation batchJob = new Batch_ReleaseReservationAtLocation();
        Database.executeBatch(batchJob);
        batchJob.getReservations(ProductSkuList,'fmgloc');        
        batchJob.ReleaseReservation(locationLevelReservations, location);
        
        // ReleaseReservationAtLocationGroup
        Batch_ReleaseReservationAtLocationGroup bc = new Batch_ReleaseReservationAtLocationGroup();
        bc.getReservations(ProductSkuList,'invRootStock');
        bc.ReleaseReservation(locationLevelReservations, locationGroup);
        Database.executeBatch(bc);
        Test.stopTest();
        
        
    }
}