@isTest
public class MockHttpResponseGenerator implements HttpCalloutMock {

    private Integer requestedStatus;

    public MockHttpResponseGenerator(Integer requestedStatus) {
        this.requestedStatus = requestedStatus;
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
            String responseJson = 'Request is valid';
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