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
            if(responseType!= null && responseType == 'getTimelines') {
                responseJson = '[{"claim":null,"claimed_at":null,"key":"3f74ab1c-41d6-4393-81fe-c2b728ea94cf","stats":{"topnews:day":{"value":[{"score":125,"urlhash":"813e4af759c886c87bce0df22585d034","epoch":1550669654}]},"topnews:week":{"value":[{"score":579,"urlhash":"dd45e16ed6a20bc71107b53cc4c43c71","epoch":1550512114},{"score":150,"urlhash":"696e4c02dc58de957864f653e64c1a04","epoch":1550496404}]},"topnews:month":{"value":[{"score":579,"urlhash":"dd45e16ed6a20bc71107b53cc4c43c71","epoch":1550512114},{"score":150,"urlhash":"696e4c02dc58de957864f653e64c1a04","epoch":1550496404}]},"topnews:quarter":{"value":[{"score":579,"urlhash":"dd45e16ed6a20bc71107b53cc4c43c71","epoch":1550512114},{"score":228,"urlhash":"67bbbf7abd9691669ced2f5c2a0bfcf7","epoch":1547424000}]},"buzz:day":{"value":1}},"status":"Ran at 26th Feb","status_at":1551223986,"title":"NN Investment Partners (NN IP) (Delta Llyod Asset Management) (NNIP)","version_at":1550565527,"version_id":"salesforce:1550565527"}]';
                if(request.getEndpoint()!=null && request.getEndpoint().equalsIgnoreCase('topNewsTestEndPoint')){
                    responseJson = '{ "ca13713c-fcd4-44a7-82ca-fcda6fd96011":[ { "event_at":1550512114, "id":"salesforce:1550565527:ca13713c-fcd4-44a7-82ca-fcda6fd96011:dd45e16ed6a20bc71107b53cc4c43c71", "key":"dd45e16ed6a20bc71107b53cc4c43c71", "props":{ "cluster_count":1, "cluster_id":"dd45e16ed6a20bc71107b53cc4c43c71", "domain":"urban.org", "epoch":1550512114, "header":"The Potential for Catalyzing Community Criminal Justice Reform with Data", "hits":{ "all":[ "criminal", "incarceration", "partnership" ], "risk:general":[ "partnership" ], "risk:governance":[ "criminal", "incarceration" ] }, "language":"en", "rawbody":null, "type":"article", "url":"https://www.urban.org/research/publication/potential-catalyzing-community-criminal-justice-reform-data", "urlhash":"dd45e16ed6a20bc71107b53cc4c43c71" }, "shard_id":"940f9b13fb228724096a866f1a52e93e6f0208d3", "stats":{ "all":1, "risk:all":1, "risk:general":1, "risk:governance":1 }, "timeline":"ca13713c-fcd4-44a7-82ca-fcda6fd96011", "version_id":"salesforce:1550565527" } ] }';
                }
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