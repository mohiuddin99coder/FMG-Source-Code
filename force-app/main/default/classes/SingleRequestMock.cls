@isTest
global class SingleRequestMock implements HttpCalloutMock {
		Integer code;
		String bodyAsString;
		Map<String, String> responseHeaders;

		global SingleRequestMock(Integer code, String body,Map<String, String> responseHeaders) {
			this.code = code;
			this.bodyAsString = body;
			this.responseHeaders = responseHeaders;
		}

	    global HTTPResponse respond(HTTPRequest req) {
	        HttpResponse resp = new HttpResponse();
			resp.setStatusCode(code);
			resp.setBody(bodyAsString);
			if (responseHeaders != null) {
			     for (String key : responseHeaders.keySet()) {
				resp.setHeader(key, responseHeaders.get(key));
			     }
			}
			return resp;
	    }
}