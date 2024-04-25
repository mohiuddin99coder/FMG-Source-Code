@isTest
    global class CustomerCalloutMock implements HttpCalloutMock{
      global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        String json=        '{'+
        '    "access_token": "12345",'+
        '    "expires_in": 899,'+
        '    "token_type": "Bearer"'+
        '}';
        res.setBody(json);
        return res;
      }
    }