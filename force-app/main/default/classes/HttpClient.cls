/**
 * Created by anshulagrawal.
 * This class is used to make post or get request and receive response
 */

public with sharing virtual class HttpClient {

    private static final Boolean RUNNING_TEST = Test.isRunningTest();
    private static final Integer HTTP_MAX_REQUEST_TIME = 120000;

    private HttpRequest httpRequest;
    private HttpResponse httpResponse;
    private Http http;
    private String endpoint;
    private String method;
    private String body;
    private String authorizationHeader;

    /**
     * method for get request based on endpoint
     *
     * @param endpoint
     */
    public void get(String endpoint) {
        this.setEndpoint(endpoint);
        this.get();
    }

    /**
     * method used to make post request with parameters
     *
     * @param endpoint - endpoint to make a request
     * @param body - request body
     * @param authorizationHeader - auth parameter, if needed to set
     */
    public void post(String endpoint, String body, String authorizationHeader) {
        this.setEndpoint(endpoint);
        this.setBody(body);
        this.setAuthorizationHeader(authorizationHeader);
        this.post();
    }

    public HttpResponse getHttpResponse() {
        return httpResponse;
    }

    public HttpRequest getHttpRequest() {
        return httpRequest;
    }

    private void get() {
        this.setMethod('GET');
        this.execute();
    }

    private void post() {
        this.setMethod('POST');
        this.execute();
    }

    /**
     * method used to build http request based on parameters
     */
    private void buildHttpRequest() {
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint(this.endpoint);
        httpRequest.setMethod(this.method);
        httpRequest.setHeader('Content-Type', 'application/json');
        if (this.body != null) {
            httpRequest.setBody(this.body);
        }
        if(this.authorizationHeader!=null){
        	httpRequest.setHeader('Authorization', this.authorizationHeader);
        }
        this.httpRequest = httpRequest;
    }

    private void buildHttp() {
        Http http = new Http();
        this.http = http;
    }

    /**
     * method used to make callout and get http response
     */
    private void execute() {
        if (this.httpRequest == null) {
            this.buildHttpRequest();
        }
        this.buildHttp();
        this.httpResponse = this.http.send(this.httpRequest);
        this.checkStatusCode();
    }

    private void checkStatusCode() {
        if (httpResponse.getStatusCode() > 299) {
            throw new HttpClientException('Response Code: ' + this.httpResponse.getStatusCode());
        }
    }

    private void setEndpoint(String endpoint) {
            this.endpoint = endpoint;
    }

    private void setAuthorizationHeader(String authorizationHeader) {
        this.authorizationHeader = authorizationHeader;
    }

    private void setMethod(String method) {
        this.method = method;
    }

    private void setBody(String body) {
        this.body = body;
    }

    public class HttpClientException extends Exception {
        
    }

}