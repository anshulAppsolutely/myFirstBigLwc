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