@isTest
public class PersonAccountRestMockClass implements HttpCalloutMock {
    
    public HTTPResponse respond (HTTPRequest req) {
        String jsonString = '{'+
            '"_v": "21.3",'+
            '"_type": "customer",'+
            '"_resource_state": "678e1ca196850475d2fe03189ce8483e64b96e9e3442207bbc04123a9937a5f5",'+
            '"birthday": "2023-01-01",'+
            '"creation_date": "2023-09-29T06:09:41.000Z",'+
            '"credentials": {'+
            '"_type": "credentials",'+
            '"enabled": true,'+
            '"locked": false,'+
            '"login": "test.personaccount5@etg.digital"'+
            '},'+
            '"customer_id": "acNB0EKfMPJ5fiLizUivpYal9S",'+
            '"customer_no": "STG-00042914",'+
            '"email": "test.personaccount5@etg.digital",'+
            '"first_name": "Test1",'+
            '"last_login_time": "2023-09-29T15:16:18.000Z",'+
            '"last_modified": "2023-10-04T17:53:05.727Z",'+
            '"last_name": "personAccount",'+
            '"last_visit_time": "2023-09-29T15:16:18.000Z",'+
            '"phone_home": "3333333333",'+
            '"previous_login_time": "2023-09-29T15:16:18.000Z",'+
            '"previous_visit_time": "2023-09-29T15:16:18.000Z",'+
            '"c_b2ccrm_accountId": "001DK00000zhsUfYAI",'+
            '"c_b2ccrm_contactId": "003DK00000d8BfVYAU",'+
            '"c_b2ccrm_gsk": "222",'+
            '"c_b2ccrm_syncStatus": "exported",'+
            '"c_braintreeCustomerId": "82736253319"'+
            '}';
        HttpResponse res = new HttpResponse ();
        res.setStatusCode(200);
        res.setBody(jsonString);
        return res;
    }
}