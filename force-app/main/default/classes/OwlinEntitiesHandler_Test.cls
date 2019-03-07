@isTest
private class OwlinEntitiesHandler_Test {

    @testSetup
    static void setUp() {

    AccountTriggerHelper.skipTrigger = true;
    list<Account> accountList = new list<Account>();
    Account acc1 = new Account();
    acc1.Name = 'Test';
    accountList.add(acc1);

    Account acc2 = new Account();
    acc2.Name = 'Test 123';
    acc2.Website = 'test123.com';
    accountList.add(acc2);

    Account acc3 = new Account();
    acc3.Name = 'Test 13';
    acc3.Website = 'test13.com';
    acc3.Owlin_Entity_Requested_Id__c = 'abc123';
    accountList.add(acc3);

    Account acc4 = new Account();
    acc4.Name = 'Test 12';
    acc4.Website = 'test12.com';
    acc4.Owlin_Entity_Requested_Id__c = 'abc234';
    acc4.Owlin_Entity_Id__c = '1234';
    accountList.add(acc4);

    insert accountList;

    }

    @isTest
    static void entitiesLinkCount(){
        Integer count = OwlinEntitiesHandler.getLinkedEnities();
        System.assertEquals(1, count);
    }

    @isTest
    static void entitiesNotLinkedCount(){
        Integer count = OwlinEntitiesHandler.getNotLinkedEnities();
        System.assertEquals(2, count);
    }

    @isTest
    static void entitiesRequestedCount(){
        Integer count = OwlinEntitiesHandler.getRequestedEntities();
        System.assertEquals(1, count);
    }

    @isTest
    static void entitiesLicenseCount(){
        OwlinEntitiesManagementController controller  = new OwlinEntitiesManagementController();
        Integer count = OwlinEntitiesHandler.getFeatureLicenseCount();
        System.assert(count!=null);
    }

    @isTest
    static void testLinkEntitiesToOwlin(){
        //create custom setting test data
        list<Configuration_Settings__c> toInsertCustomSettingRecList = new list<Configuration_Settings__c>();

        Configuration_Settings__c configProd = new Configuration_Settings__c();
        configProd.Name = 'Test_Owlin';
        configProd.Email__c = 'test@test.com';
        configProd.Endpoint__c = 'api.test.owlin/v1/';
        configProd.Password__c = 'testPassword';
        configProd.Token__c = 'testToken';
        configProd.Token_Expiry_Date__c = System.Today().addDays(-2);
        configProd.Is_Primary__c = True;
        toInsertCustomSettingRecList.add(configProd);

        insert toInsertCustomSettingRecList;

        OwlinEntitiesHandler.linkEntitiesToOwlin(5, 'testToken');
        //System.assertEquals(1, count);
        AsyncApexJob job = [SELECT Id, Status, MethodName, ApexClass.Name FROM AsyncApexJob];
        System.assertEquals('OwlinAccountLinkBatchable', job.ApexClass.Name);
    }

    @isTest
    static void testRequestToken(){
        //create custom setting test data
        list<Configuration_Settings__c> toInsertCustomSettingRecList = new list<Configuration_Settings__c>();

        Configuration_Settings__c configProd = new Configuration_Settings__c();
        configProd.Name = 'Test_Owlin';
        configProd.Email__c = 'test@test.com';
        configProd.Endpoint__c = 'api.test.owlin/v1/';
        configProd.Password__c = 'testPassword';
        configProd.Token__c = 'testToken';
        configProd.Token_Expiry_Date__c = System.Today().addDays(-2);
        configProd.Is_Primary__c = True;
        toInsertCustomSettingRecList.add(configProd);

        insert toInsertCustomSettingRecList;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200,'apiToken'));
        String token = OwlinEntitiesHandler.requestAPIToken(toInsertCustomSettingRecList[0]);
        System.assertEquals('testToken', token);
        Test.stopTest();
    }

    @isTest
    static void testSaveToken(){
        //create custom setting test data
        list<Configuration_Settings__c> toInsertCustomSettingRecList = new list<Configuration_Settings__c>();

        Configuration_Settings__c configProd = new Configuration_Settings__c();
        configProd.Name = 'Test_Owlin';
        configProd.Email__c = 'test@test.com';
        configProd.Endpoint__c = 'api.test.owlin/v1/';
        configProd.Password__c = 'testPassword';
        configProd.Token__c = 'testToken';
        configProd.Token_Expiry_Date__c = System.Today().addDays(-2);
        configProd.Is_Primary__c = True;
        toInsertCustomSettingRecList.add(configProd);

        insert toInsertCustomSettingRecList;
        Test.startTest();
        OwlinEntitiesHandler.saveAPIToken('testTokenNewVal');
        Test.stopTest();
        //get the custom settings again
        Map<String, Configuration_Settings__c> setting = Configuration_Settings__c.getall();
        Configuration_Settings__c config = setting.get('Test_Owlin');
        String token = config.Token__c;
        System.assertEquals('testTokenNewVal', token);
    }

    @isTest
    static void testEntityTimeline(){
        //create custom setting test data
        list<Configuration_Settings__c> toInsertCustomSettingRecList = new list<Configuration_Settings__c>();

        Configuration_Settings__c configProd = new Configuration_Settings__c();
        configProd.Name = 'Test_Owlin';
        configProd.Email__c = 'test@test.com';
        configProd.Endpoint__c = 'api.test.owlin/v1/';
        configProd.Password__c = 'testPassword';
        configProd.Token__c = 'testToken';
        configProd.Token_Expiry_Date__c = System.Today().addDays(-2);
        configProd.Is_Primary__c = True;
        toInsertCustomSettingRecList.add(configProd);

        insert toInsertCustomSettingRecList;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200,'getTimelines'));
        String timelineJson = OwlinEntitiesHandler.getEntityTimeline(toInsertCustomSettingRecList[0],'testToken');
        System.assert(timelineJson!=null);
        Test.stopTest();
    }

    @isTest
    static void testTopNews(){
        //create custom setting test data
        list<Configuration_Settings__c> toInsertCustomSettingRecList = new list<Configuration_Settings__c>();

        Configuration_Settings__c configProd = new Configuration_Settings__c();
        configProd.Name = 'Test_Owlin';
        configProd.Email__c = 'test@test.com';
        configProd.Endpoint__c = 'api.test.owlin/v1/';
        configProd.Password__c = 'testPassword';
        configProd.Token__c = 'testToken';
        configProd.Token_Expiry_Date__c = System.Today().addDays(2);
        configProd.Is_Primary__c = True;
        toInsertCustomSettingRecList.add(configProd);

        insert toInsertCustomSettingRecList;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200,'getTimelines'));
        String requestedString ='{"timelines":{"ca13713c-fcd4-44a7-82ca-fcda6fd96011":["dd45e16ed6a20bc71107b53cc4c43c71","696e4c02dc58de957864f653e64c1a04"]}}';
        String timelineJson = OwlinEntitiesHandler.getTopNewsData(requestedString,toInsertCustomSettingRecList[0],'testToken');
        System.assert(timelineJson!=null);
        Test.stopTest();
    }

    @isTest
    static void testSingleEntityTimeline(){
        //create custom setting test data
        list<Configuration_Settings__c> toInsertCustomSettingRecList = new list<Configuration_Settings__c>();

        Configuration_Settings__c configProd = new Configuration_Settings__c();
        configProd.Name = 'Test_Owlin';
        configProd.Email__c = 'test@test.com';
        configProd.Endpoint__c = 'api.test.owlin/v1/';
        configProd.Password__c = 'testPassword';
        configProd.Token__c = 'testToken';
        configProd.Token_Expiry_Date__c = System.Today().addDays(2);
        configProd.Is_Primary__c = True;
        toInsertCustomSettingRecList.add(configProd);

        insert toInsertCustomSettingRecList;
        List<Account> requestedAccount = [Select id, name from account where Owlin_Entity_Id__c!=null limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200,'getSingleEntityTimeline'));
        String singleEntityTimeline = OwlinEntitiesHandler.getSingleEntityTimeline(toInsertCustomSettingRecList[0],'testToken',requestedAccount[0].id);
        System.assert(singleEntityTimeline!=null);
        Test.stopTest();
    }

}