@isTest
private class HttpClient_Test {

    private static HttpClient httpClient;
    private static HttpRequest httpRequest;
    private static HttpResponse mockResponse;
    private static Http http;

    @isTest
    static void httpPostRequest() {
        String endpoint = 'THE ENDPOINT';
        String method = 'POST';
        String body = 'THE BODY';
        String authorizationHeader = 'AUTHORIZATION';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400,null));
        httpClient = new HttpClient();
        System.assert(httpClient != null);

        Test.startTest();
        try{
            httpClient.post(endpoint, body, authorizationHeader);
        }catch(Exception e){
            mockResponse = httpClient.getHttpResponse();
            System.assertEquals('Error', mockResponse.getStatus());
            System.assertEquals(400, mockResponse.getStatusCode());
        }
        Test.stopTest();
        
    }

    @isTest
    static void httpGetRequest() {
        String endpoint = 'THE ENDPOINT';
        String method = 'GET';
        String authorizationHeader = 'AUTHORIZATION';
        httpClient = new HttpClient();
        System.assert(httpClient != null);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200,null));

        Test.startTest();
        httpClient.get(endpoint,authorizationHeader);
        Test.stopTest();

        httpRequest = httpClient.getHttpRequest();
        System.assertEquals('THE ENDPOINT', httpRequest.getEndpoint());
        System.assertEquals('', httpRequest.getBody());
        System.assertEquals(method, httpRequest.getMethod());
        mockResponse = httpClient.getHttpResponse();
        System.assertEquals('ok', mockResponse.getStatus());
        System.assertEquals(200, mockResponse.getStatusCode());
    }

}