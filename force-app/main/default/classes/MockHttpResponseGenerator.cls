@isTest
public class MockHttpResponseGenerator implements HttpCalloutMock {

    private Integer requestedStatus;
    private String responseType;

    public MockHttpResponseGenerator(Integer requestedStatus, String responseType) {
        this.requestedStatus = requestedStatus;
        this.responseType = responseType;
    }

    /**
     * method used to send mocked response
     * using status code to check and sending the request body as the variable
     * @param request
     *
     * @return
     */
    public HttpResponse respond(HttpRequest request) {

        HttpResponse mockResponse = new HttpResponse();
        //send response body as per satus code requested
        if(requestedStatus!= null && requestedStatus == 200){
            String responseJson;
            if(responseType!= null && responseType == 'linkEntity') {
                responseJson = '{ "matches": [ { "score": 18, "title": "Vodafone India Ltd", "filter_id": "acfb5d84-d838-447a-938d-58480bc1c54d", ' +
                        '"original_id": "0019E00000uB55lQAC" }, { "score": 14, "title": "HEMbrug", "filter_id": "9b682ae6-4b10-43c8-a408-ac2323a481b2", ' +
                        '"original_id": "0019E00000tvpjNQAQ" } ], "base_filter_library_size": 2929 }';
            }
            if(responseType!= null && responseType == 'apiToken') {
                responseJson = '{"token": "testToken"}';
            }
            if(responseJson == null) responseJson = 'Valid';
            mockResponse.setStatus('ok');
            mockResponse.setStatusCode(200);
            mockResponse.setBody(responseJson);

        }else if(requestedStatus!=null && requestedStatus == 400){
            String responseJson = 'Invalid Request';
            mockResponse.setStatusCode(400);
            mockResponse.setStatus('Error');
            mockResponse.setBody(responseJson);
        }
        return mockResponse;
    }

}