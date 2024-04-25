@isTest
private class Schedule_OciApiCalloutsTest {
    static testmethod void Schedule_OciApiCalloutsT() {
        String accessTk = 'eyJ0eXAiOiJKV1QiLCJraWQiOiJEMWhPUDdEODN4TjBqZWlqaTI3WWFvZFRjL0E9IiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiIzNDdjMWRmZC02ZmM0LTQxYjctYjYwYi1mZWMzNmFmOTg3YzYiLCJjdHMiOiJPQVVUSDJfU1RBVEVMRVNTX0dSQU5UIiwiYXVkaXRUcmFja2luZ0lkIjoiZTRlYjUzMmUtNWEyZC00MmU4LTkxZGYtNGU5ZDRmNGU2NjVhLTE4MzQ4ODAwIiwic3VibmFtZSI6IjM0N2MxZGZkLTZmYzQtNDFiNy1iNjBiLWZlYzM2YWY5ODdjNiIsImlzcyI6Imh0dHBzOi8vYWNjb3VudC5kZW1hbmR3YXJlLmNvbTo0NDMvZHdzc28vb2F1dGgyIiwidG9rZW5OYW1lIjoiYWNjZXNzX3Rva2VuIiwidG9rZW5fdHlwZSI6IkJlYXJlciIsImF1dGhHcmFudElkIjoiOVZFaUx0RkNPZ0kxVXh1WkF1aWFlY182R2lnIiwiYXVkIjoiMzQ3YzFkZmQtNmZjNC00MWI3LWI2MGItZmVjMzZhZjk4N2M2IiwibmJmIjoxNjY2ODQwMzMyLCJncmFudF90eXBlIjoiY2xpZW50X2NyZWRlbnRpYWxzIiwic2NvcGUiOlsic2ZjYy5pbnZlbnRvcnkucmVzZXJ2YXRpb25zIiwic2ZjYy5pbnZlbnRvcnkucmVzZXJ2YXRpb25zLnJ3Iiwic2ZjYy5pbnZlbnRvcnkuaW1wZXgtaW52ZW50b3J5LnJ3Iiwic2ZjYy5pbnZlbnRvcnkuYXZhaWxhYmlsaXR5LnJ3Iiwic2ZjYy5pbnZlbnRvcnkuYWRtaW4ucnciLCJzZmNjLmludmVudG9yeS5pbXBleC1pbnZlbnRvcnkiLCJzZmNjLmludmVudG9yeS5pbXBleC1ldmVudC1sb2ciLCJTQUxFU0ZPUkNFX0NPTU1FUkNFX0FQSTpiamJ2X2RldiIsInNmY2MuaW52ZW50b3J5LmF2YWlsYWJpbGl0eSIsInNmY2MuaW52ZW50b3J5LmltcGV4LWdyYXBocyIsInNmY2MuaW52ZW50b3J5LmltcGV4LWdyYXBocy5ydyJdLCJhdXRoX3RpbWUiOjE2NjY4NDAzMzIsInJlYWxtIjoiLyIsImV4cCI6MTY2Njg0MjEzMiwiaWF0IjoxNjY2ODQwMzMyLCJleHBpcmVzX2luIjoxODAwLCJqdGkiOiJSRkFfR3h1bUhNSTZ2cUlLQkpiRGsxUFFnYUkiLCJjbGllbnRfaWQiOiIzNDdjMWRmZC02ZmM0LTQxYjctYjYwYi1mZWMzNmFmOTg3YzYifQ.IvVtkXGba-CU2ooCNL9goPyNDmMDbQqiZvFV7-YjbdKybL050Hpnp_221u1cVPpfiartSZv3g4dMxxJNaNMFVjt718Yp1EOYRYeD0qk6eImC0QK-QuVuwOVNm2mp82lnt2QuhpTCr2Yj--YhD9mqZ2fcUVVaSZCzYQUxxC2v7jkFTwPlh5w80fz5Nh19ei4u1xoPAwRjCyfarV6kvdugrbW1jRc3IhUUyJohMqU8eFkswBQQnoLHCbwXdZyItiTE_9si65d1VVtxPmPGOzu51IPuobq-HjaDvZ6_s1RebI_zTvS7-pvqGZXCtkzbHVxGfM4Omt2OhcF84AnuFJUK5A';
        Test.setMock(HttpCalloutMock.class, new getmockdata2());
        list<product2> prdList = new list<product2>();
        Product2 p = new Product2();
        p.Name = 'Test Product199';
        p.Description='Test Product199';
        p.productCode = 'WS109-006';
        p.isActive = true;
        p.StockKeepingUnit='WS1655-001';
        insert p;
        prdList.add(p);
        system.debug('p--->'+p.Product_Count__c);
        Schema.Location LC =  new Schema.Location();
        LC.Name = 'FMG Warehouse';
        LC.LocationType ='Warehouse';
        LC.latitude = 37.83933;
        LC.longitude = -84.27002 ;
        LC.ExternalReference='fmgloc';
        insert LC;
        
        OCILocationGroup__c Location = new OCILocationGroup__c();
        Location.Location__c = 'fmgloc';
        insert Location;
        
      /*  Product_Location__c  PRL = new Product_Location__c();
        PRL.ProductID__c = p.Id;
        PRL.Location_ID__c = LC.id;
        PRL.Inventory__c = 805;
        PRL.Geo_Location__Latitude__s = 34.2257;
        PRL.Geo_Location__Longitude__s = -115.9447 ;
        PRL.Netsuite_ID__c ='Test1234';
        insert PRL;*/
        Test.StartTest();
        Schedule_OciApiCallouts scheduler=new Schedule_OciApiCallouts(); 
        scheduler.execute(null);
       /* Schedule_OciApiCallouts ad = new Schedule_OciApiCallouts();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Batch_OciApiCallouts', sch, ad);*/
        Batch_OciApiCallouts BCO = new Batch_OciApiCallouts(0,10);
        BCO.generateJsonMethod(prdList);
        Batch_OciApiCallouts.getUUID();
        Test.stopTest();
    }

    public class getmockdata1 implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse response =new HttpResponse();
            response.setHeader('Content-Type','application/json');
            response.setBody('{"access_token": "eyJ0eXAiOiJKV1QiLCJraWQiOiJEMWhPUDdEODN4TjBqZWlqaTI3WWFvZFRjL0E9IiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiIzNDdjMWRmZC02ZmM0LTQxYjctYjYwYi1mZWMzNmFmOTg3YzYiLCJjdHMiOiJPQVVUSDJfU1RBVEVMRVNTX0dSQU5UIiwiYXVkaXRUcmFja2luZ0lkIjoiZTRlYjUzMmUtNWEyZC00MmU4LTkxZGYtNGU5ZDRmNGU2NjVhLTE4MzQ4ODAwIiwic3VibmFtZSI6IjM0N2MxZGZkLTZmYzQtNDFiNy1iNjBiLWZlYzM2YWY5ODdjNiIsImlzcyI6Imh0dHBzOi8vYWNjb3VudC5kZW1hbmR3YXJlLmNvbTo0NDMvZHdzc28vb2F1dGgyIiwidG9rZW5OYW1lIjoiYWNjZXNzX3Rva2VuIiwidG9rZW5fdHlwZSI6IkJlYXJlciIsImF1dGhHcmFudElkIjoiOVZFaUx0RkNPZ0kxVXh1WkF1aWFlY182R2lnIiwiYXVkIjoiMzQ3YzFkZmQtNmZjNC00MWI3LWI2MGItZmVjMzZhZjk4N2M2IiwibmJmIjoxNjY2ODQwMzMyLCJncmFudF90eXBlIjoiY2xpZW50X2NyZWRlbnRpYWxzIiwic2NvcGUiOlsic2ZjYy5pbnZlbnRvcnkucmVzZXJ2YXRpb25zIiwic2ZjYy5pbnZlbnRvcnkucmVzZXJ2YXRpb25zLnJ3Iiwic2ZjYy5pbnZlbnRvcnkuaW1wZXgtaW52ZW50b3J5LnJ3Iiwic2ZjYy5pbnZlbnRvcnkuYXZhaWxhYmlsaXR5LnJ3Iiwic2ZjYy5pbnZlbnRvcnkuYWRtaW4ucnciLCJzZmNjLmludmVudG9yeS5pbXBleC1pbnZlbnRvcnkiLCJzZmNjLmludmVudG9yeS5pbXBleC1ldmVudC1sb2ciLCJTQUxFU0ZPUkNFX0NPTU1FUkNFX0FQSTpiamJ2X2RldiIsInNmY2MuaW52ZW50b3J5LmF2YWlsYWJpbGl0eSIsInNmY2MuaW52ZW50b3J5LmltcGV4LWdyYXBocyIsInNmY2MuaW52ZW50b3J5LmltcGV4LWdyYXBocy5ydyJdLCJhdXRoX3RpbWUiOjE2NjY4NDAzMzIsInJlYWxtIjoiLyIsImV4cCI6MTY2Njg0MjEzMiwiaWF0IjoxNjY2ODQwMzMyLCJleHBpcmVzX2luIjoxODAwLCJqdGkiOiJSRkFfR3h1bUhNSTZ2cUlLQkpiRGsxUFFnYUkiLCJjbGllbnRfaWQiOiIzNDdjMWRmZC02ZmM0LTQxYjctYjYwYi1mZWMzNmFmOTg3YzYifQ.IvVtkXGba-CU2ooCNL9goPyNDmMDbQqiZvFV7-YjbdKybL050Hpnp_221u1cVPpfiartSZv3g4dMxxJNaNMFVjt718Yp1EOYRYeD0qk6eImC0QK-QuVuwOVNm2mp82lnt2QuhpTCr2Yj--YhD9mqZ2fcUVVaSZCzYQUxxC2v7jkFTwPlh5w80fz5Nh19ei4u1xoPAwRjCyfarV6kvdugrbW1jRc3IhUUyJohMqU8eFkswBQQnoLHCbwXdZyItiTE_9si65d1VVtxPmPGOzu51IPuobq-HjaDvZ6_s1RebI_zTvS7-pvqGZXCtkzbHVxGfM4Omt2OhcF84AnuFJUK5A","scope": "sfcc.inventory.reservations sfcc.inventory.reservations.rw sfcc.inventory.impex-inventory.rw sfcc.inventory.availability.rw sfcc.inventory.admin.rw sfcc.inventory.impex-inventory sfcc.inventory.impex-event-log SALESFORCE_COMMERCE_API:bjbv_dev sfcc.inventory.availability sfcc.inventory.impex-graphs sfcc.inventory.impex-graphs.rw","token_type": "Bearer","expires_in": 1799}');
            response.setStatusCode(200);
            return response;
        }
    }
    public class getmockdata2 implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse response =new HttpResponse();
            response.setHeader('Content-Type','application/json');
            response.setBody('{"importId" : "b6bb5cf4-5986-4c92-8a0b-049e5817aaa6","importStatusLink" : "/inventory/impex/v1/organizations/6fad962a-56e1-4995-9eed-f86b1cc668bb/availability-records/imports/b6bb5cf4-5986-4c92-8a0b-049e5817aaa6/status","uploadLink" : "/inventory/impex/v1/organizations/6fad962a-56e1-4995-9eed-f86b1cc668bb/availability-records/imports/uploadlink/b6bb5cf4-5986-4c92-8a0b-049e5817aaa6","uploadMethod" : "POST","uploadLinkExpirationUTC" : "2022-10-27T09:55:58.987Z"}');
            response.setStatusCode(200);
            return response;
        }
    }
}