@isTest
private class OwlinLinkEntitiesResponseWrapper_Test {

    @isTest
    static void parseOwlinLinkEntitiesResponse() {
        String requestJson = '{ "matches": [ { "score": 18, "title": "Vodafone India Ltd", "filter_id": "acfb5d84-d838-447a-938d-58480bc1c54d", ' +
                '"original_id": "originalId1" }, { "score": 14, "title": "HEMbrug", "filter_id": "9b682ae6-4b10-43c8-a408-ac2323a481b2", ' +
                '"original_id": "originalId12" } ], "base_filter_library_size": 2929 }';

        OwlinLinkEntitiesResponseWrapper obj = OwlinLinkEntitiesResponseWrapper.parse(requestJson);
        System.assert(obj != null);
        System.assertEquals(2, obj.matches.size());
        System.assertEquals('originalId1', obj.matches[0].original_id);
    }

}