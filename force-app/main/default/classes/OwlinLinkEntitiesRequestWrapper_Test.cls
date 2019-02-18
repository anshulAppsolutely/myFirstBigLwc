@isTest
private class OwlinLinkEntitiesRequestWrapper_Test {

    @isTest
    static void parseOwlinLinkEntitiesRequest() {
        String requestJson = '{ "entities": [ { "id": "testId1", "name": "test1", "domain": "test1.com" } ,{ "id": "testId2", "name": "test2", "domain": "test2.com" } ] }';

        OwlinLinkEntitiesRequestWrapper obj = OwlinLinkEntitiesRequestWrapper.parse(requestJson);
        System.assert(obj != null);
        System.assertEquals(2, obj.entities.size());
        System.assertEquals('test1', obj.entities[0].name);
    }

}

{ "matches": [ { "score": 18, "title": "Vodafone India Ltd", "filter_id": "acfb5d84-d838-447a-938d-58480bc1c54d", "original_id": "0019E00000uB55lQAC" }, { "score": 14, "title": "HEMbrug", "filter_id": "9b682ae6-4b10-43c8-a408-ac2323a481b2", "original_id": "0019E00000tvpjNQAQ" } ], "base_filter_library_size": 2929 }