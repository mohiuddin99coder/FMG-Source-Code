@isTest
public class CustomerAddressRestMockClass implements HttpCalloutMock {
    
    public HTTPResponse respond (HTTPRequest req) {
        String jsonString = '{'+
            '"_v": "21.3",'+
            '"_type": "customer_address",'+
            '"_resource_state": "27f658aa617f19c242e9222763238a76b6f03980e5b86b300cd3cbcce79f5836",'+
            '"address1": "100 Centre Street\\r\\nManhattan",'+
            '"address_id": "Test",'+
            '"city": "New York",'+
            '"country_code": "US",'+
            '"creation_date": "2023-10-04T18:44:36.000Z",'+
            '"etag": "27f658aa617f19c242e9222763238a76b6f03980e5b86b300cd3cbcce79f5836",'+
            '"first_name": "Test1",'+
            '"full_name": "Test1 personAccount",'+
            '"last_modified": "2023-10-04T18:44:36.000Z",'+
            '"last_name": "personAccount",'+
            '"postal_code": "10013",'+
            '"state_code": "NY"'+
            '}';
        
        HttpResponse res = new HttpResponse ();
        res.setStatusCode(200);
        res.setBody(jsonString);
        return res;
    }
}