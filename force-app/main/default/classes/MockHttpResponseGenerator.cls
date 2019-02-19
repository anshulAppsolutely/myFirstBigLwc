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
                responseJson = '[{"claim":null,"claimed_at":null,"dirty":null,"id":"salesforce:1549791673:acfb5d84-d838-447a-938d-58480bc1c54d",' +
                        '"job_id":"salesforce","key":"acfb5d84-d838-447a-938d-58480bc1c54d","labels":["project-id","project-id:base-id","raw",' +
                        '"type","type:entity","type:entity:company"],"meta":{"core_words":{"exact":"\"Vodafone India Ltd\" \"Vodafone India\" ' +
                        '\"Vodafone India Limited\"","loose":"","standard":"\"vodafone india ltd\" \"vodafone india\" \"vodafone india limited\""},' +
                        '"full_legal_name":"Vodafone India Ltd.","links":["https://en.wikipedia.org/wiki/Vodafone_India","www.vodafone.in"]},"score_cats":' +
                        '{"environmental":["environmental-impact"],"financial":["bankruptcy","downsizing","financial-issues","future-outlook"],"general":' +
                        '["hostile-acquisitions","mna","general-issues","natural-disasters"],"governance":["market-manipulation","internal-wrongdoing",' +
                        '"investigations","ip-problems","lawsuits","sentencing","strategic-problems","c-level-changes"],"social":["human-rights-violations",' +
                        '"acts-of-violence","human-accidents","labour-problems","product-problems","operational-risk","pr-problems"]},"scoring_id":"baserisklexicon2017",' +
                        '"shard_id":"edbf2513e58b252f46dcf58f6409f90407e19ea1","stats":{"article_count":{"value":21},"cluster_count":{"value":17},"buzz:no-risk:day":' +
                        '{"value":0},"buzz:no-risk:week":{"value":0},"buzz:no-risk:month":{"value":5.4},"buzz:no-risk:quarter":{"value":9.4},"buzz:no-risk:halfyear":' +
                        '{"value":9.4},"buzz:day":{"value":0},"buzz:week":{"value":0},"buzz:month":{"value":9.4},"buzz:quarter":{"value":17.4},"buzz:halfyear":' +
                        '{"value":17.4},"delta:day":{"value":0},"delta:daywithtail":{"value":0},"delta:week":{"value":0},"delta:month":{"value":28.014432471017173},' +
                        '"delta:quarter":{"value":27.495350333139566},"latest-article":{"value":1549681844},"buzz:risk:financial:day":{"value":0},' +
                        '"buzz:risk:financial:week":{"value":0},"buzz:risk:financial:month":{"value":812},"buzz:risk:financial:quarter":{"value":1104},' +
                        '"buzz:risk:financial:halfyear":{"value":1104},"delta:risk:financial:day":{"value":0},"delta:risk:financial:daywithtail":{"value":0},' +
                        '"delta:risk:financial:week":{"value":0},"delta:risk:financial:month":{"value":5827316.474917359},"delta:risk:financial:quarter":' +
                        '{"value":4092682.847206205},"buzz:risk:general:day":{"value":0},"buzz:risk:general:week":{"value":0},"buzz:risk:general:month":' +
                        '{"value":321},"buzz:risk:general:quarter":{"value":638},"buzz:risk:general:halfyear":{"value":638},"delta:risk:general:day":{"value":0},' +
                        '"delta:risk:general:daywithtail":{"value":0},"delta:risk:general:week":{"value":0},"delta:risk:general:month":{"value":5083238.972594801},' +
                        '"delta:risk:general:quarter":{"value":2096461.0618934634},"buzz:risk:all:day":{"value":0},"buzz:risk:all:week":{"value":0},' +
                        '"buzz:risk:all:month":{"value":1427},"buzz:risk:all:quarter":{"value":1976},"buzz:risk:all:halfyear":{"value":1976},"delta:risk:all:day":' +
                        '{"value":0},"delta:risk:all:daywithtail":{"value":0},"delta:risk:all:week":{"value":0},"delta:risk:all:month":{"value":8268153.927868524}' +
                        ',"delta:risk:all:quarter":{"value":3371630.8516176334},"topnews:day":{"value":[]},"topnews:week":{"value":[{"score":322,"header":"Vodafone Idea Q3 loss widens; firm loses 35 million users","url":"https://newscliq.com/vodafone-idea-q3-loss-widens-firm-loses-35-million-users/","language":"en","urlhash":"83d7ec51046b8ed7646136a0482af66f","epoch":1549463315,"hits":{"risk:financial":["post loss","widens loss","loses million","lost million"],"all":["post loss","widens loss","loses million","lost million"]},"cluster_count":1,"cluster_id":"83d7ec51046b8ed7646136a0482af66f","id":"salesforce:1549791673:acfb5d84-d838-447a-938d-58480bc1c54d:83d7ec51046b8ed7646136a0482af66f","type":"article"},{"score":321,"header":"Télécoms : Jio menace le leadership dAirtel en Inde","url":"https://www.jeuneafrique.com/mag/728408/economie/telecoms-jio-menace-le-leadership-dairtel-en-inde/?utm_source=jeuneafrique&utm_medium=flux-rss&utm_campaign=flux-rss-jeune-afrique-15-05-2018","language":"fr","urlhash":"45be8ac1845daf84fb1930f1ebb60249","epoch":1549277976,"hits":{"risk:financial":["price war"],"all":["price war","war","threatens"],"risk:general":["war","threatens"]},"cluster_count":1,"cluster_id":"45be8ac1845daf84fb1930f1ebb60249","id":"salesforce:1549791673:acfb5d84-d838-447a-938d-58480bc1c54d:45be8ac1845daf84fb1930f1ebb60249","type":"article"}]},"topnews:month":{"value":[{"score":615,"header":"Supreme Court admits Trai plea against TDSAT predatory pricing order","url":"https://www.business-standard.com/article/current-affairs/supreme-court-admits-trai-plea-against-tdsat-predatory-pricing-order-119012100877_1.html","language":"en","urlhash":"803ea2bd70daf22f17fe5f7c0ffb1099","epoch":1548077520,"hits":{"risk:governance":["court","court order"],"all":["court","court order"]},"cluster_count":1,"cluster_id":"803ea2bd70daf22f17fe5f7c0ffb1099","id":"salesforce:1549791673:acfb5d84-d838-447a-938d-58480bc1c54d:803ea2bd70daf22f17fe5f7c0ffb1099","type":"article"},{"score":322,"header":"Vodafone Idea Q3 loss widens; firm loses 35 million users","url":"https://newscliq.com/vodafone-idea-q3-loss-widens-firm-loses-35-million-users/","language":"en","urlhash":"83d7ec51046b8ed7646136a0482af66f","epoch":1549463315,"hits":{"risk:financial":["post loss","widens loss","loses million","lost million"],"all":["post loss","widens loss","loses million","lost million"]},"cluster_count":1,"cluster_id":"83d7ec51046b8ed7646136a0482af66f","id":"salesforce:1549791673:acfb5d84-d838-447a-938d-58480bc1c54d:83d7ec51046b8ed7646136a0482af66f","type":"article"}]},"topnews:quarter":{"value":[{"score":615,"header":"Supreme Court admits Trai plea against TDSAT predatory pricing order","url":"https://www.business-standard.com/article/current-affairs/supreme-court-admits-trai-plea-against-tdsat-predatory-pricing-order-119012100877_1.html","language":"en","urlhash":"803ea2bd70daf22f17fe5f7c0ffb1099","epoch":1548077520,"hits":{"risk:governance":["court","court order"],"all":["court","court order"]},"cluster_count":1,"cluster_id":"803ea2bd70daf22f17fe5f7c0ffb1099","id":"salesforce:1549791673:acfb5d84-d838-447a-938d-58480bc1c54d:803ea2bd70daf22f17fe5f7c0ffb1099","type":"article"},{"score":322,"header":"Vodafone Idea Q3 loss widens; firm loses 35 million users","url":"https://newscliq.com/vodafone-idea-q3-loss-widens-firm-loses-35-million-users/","language":"en","urlhash":"83d7ec51046b8ed7646136a0482af66f","epoch":1549463315,"hits":{"risk:financial":["post loss","widens loss","loses million","lost million"],"all":["post loss","widens loss","loses million","lost million"]},"cluster_count":1,"cluster_id":"83d7ec51046b8ed7646136a0482af66f","id":"salesforce:1549791673:acfb5d84-d838-447a-938d-58480bc1c54d:83d7ec51046b8ed7646136a0482af66f","type":"article"}]},"buzz:risk:governance:day":{"value":0},"buzz:risk:governance:week":{"value":0},"buzz:risk:governance:month":{"value":615},"buzz:risk:governance:quarter":{"value":847},"buzz:risk:governance:halfyear":{"value":847},"delta:risk:governance:day":{"value":0},"delta:risk:governance:daywithtail":{"value":0},"delta:risk:governance:week":{"value":0},"delta:risk:governance:month":{"value":15168824.961210547},"delta:risk:governance:quarter":{"value":3791651.895789333}},"status":"article_count:21 buzz:day:0 buzz:halfyear:17.4 buzz:month:12.4 buzz:no-risk:day:0 buzz:no-risk:halfyear:9.4 buzz:no-risk:month:7.4 buzz:no-risk:quarter:9.4 buzz:no-risk:week:3.4 buzz:quarter:17.4 buzz","status_at":1549951753,"title":"Vodafone India Ltd","version_at":1549791673,"version_id":"salesforce:1549791673"}]';
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