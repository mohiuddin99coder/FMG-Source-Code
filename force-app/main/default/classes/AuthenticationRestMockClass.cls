@isTest
public class AuthenticationRestMockClass implements HttpCalloutMock {

    public HTTPResponse respond (HTTPRequest req) {
        String jsonString = '{"access_token":"1234"}';

        
        HttpResponse res = new HttpResponse ();
        res.setStatusCode(200);
        res.setBody(jsonString);
        return res;
    }
}