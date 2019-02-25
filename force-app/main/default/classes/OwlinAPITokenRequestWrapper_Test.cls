@isTest
private class OwlinAPITokenRequestWrapper_Test {

    @isTest
    static void parseOwlinAPITokenRequest() {
        String requestJson = '{"email": "test@test.com","password": "testPassword","expire": "30d"}';

        OwlinAPITokenRequestWrapper obj = OwlinAPITokenRequestWrapper.parse(requestJson);
        System.assert(obj != null);
        System.assertEquals('test@test.com', obj.Email);
        System.assertEquals('testPassword', obj.password);
    }

}