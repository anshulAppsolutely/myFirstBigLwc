@isTest
private class OwlinAPITokenResponseWrapper_Test {

    @isTest
    static void parseOwlinAPITokenResponse() {
            String requestJson = '{"token": "testToken"}';

        OwlinAPITokenResponseWrapper obj = OwlinAPITokenResponseWrapper.parse(requestJson);
        System.assert(obj != null);
        System.assertEquals('testToken', obj.token);
    }

}