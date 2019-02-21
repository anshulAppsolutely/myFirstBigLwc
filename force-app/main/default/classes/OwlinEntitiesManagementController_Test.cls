@isTest
private class OwlinEntitiesManagementController_Test {

    @testSetup
    static void setUp() {

        list<Account> accountList = new list<Account>();
        Account acc1 = new Account();
        acc1.Name = 'Test';
        acc1.Website = 'test.com';
        accountList.add(acc1);

        Account acc2 = new Account();
        acc2.Name = 'Test 123';
        acc2.Website = 'test123.com';
        accountList.add(acc2);

        Account acc3 = new Account();
        acc3.Name = 'Test 13';
        acc3.Website = 'test13.com';
        acc3.Owlin_Entity_Requested_Id__c = 'abcd123';
        accountList.add(acc3);

        Account acc4 = new Account();
        acc4.Name = 'Test 12';
        acc4.Website = 'test12.com';
        acc4.Owlin_Entity_Requested_Id__c = 'abc23';
        acc4.Owlin_Entity_Id__c = '1234';
        accountList.add(acc4);

        insert accountList;

    }

    @isTest
    static void likedEntitiesCount(){
        OwlinEntitiesManagementController controller  = new OwlinEntitiesManagementController();
        Integer count = controller.linkedEntitiesCount;
        System.assertEquals(1, count);
    }

    @isTest
    static void entitiesNotLinkedCount(){
        OwlinEntitiesManagementController controller  = new OwlinEntitiesManagementController();
        Integer count = controller.entitiesNotLinkedCount;
        System.assertEquals(2, count);
    }

    @isTest
    static void entitiesRequestedCount(){
        OwlinEntitiesManagementController controller  = new OwlinEntitiesManagementController();
        Integer count = controller.entitiesRequestedCount;
        System.assertEquals(1, count);
    }

    @isTest
    static void entitiesLicenseCount(){
        OwlinEntitiesManagementController controller  = new OwlinEntitiesManagementController();
        Integer count = controller.entitiesLicenseCount;
        System.assert(count!=null);
    }

    @isTest
    static void testRequestAPIToken(){
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

        OwlinEntitiesManagementController controller  = new OwlinEntitiesManagementController();
        system.runAs(OwlinTestUtils.getOwlinUserWithPermission()) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200,'apiToken'));
            controller.linkAccountsToOwlin();
            ApexPages.Message[] pageMessages = ApexPages.getMessages();
            System.assertNotEquals(0, pageMessages.size());

            // Check that the error message you are expecting is in pageMessages
            Boolean messageFound = false;
            for (ApexPages.Message message : pageMessages) {
                if (message.getSeverity() == ApexPages.Severity.INFO) {
                    messageFound = true;
                    //System.assertEquals(Label.Success_EntitiesLinked, message.getSummary());
                }
            }

            //System.assert(messageFound);
            Test.stopTest();
        }
    }

    @isTest
    static void testEntitiesToLink(){
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

        OwlinEntitiesManagementController controller  = new OwlinEntitiesManagementController();
        system.runAs(OwlinTestUtils.getOwlinUserWithPermission()) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200,'linkEntity'));
            controller.linkAccountsToOwlin();
            ApexPages.Message[] pageMessages = ApexPages.getMessages();
            System.assertNotEquals(0, pageMessages.size());

            // Check that the error message you are expecting is in pageMessages
            Boolean messageFound = false;
            for (ApexPages.Message message : pageMessages) {
                if (message.getSeverity() == ApexPages.Severity.INFO) {
                    messageFound = true;
                    System.assertEquals(Label.Success_EntitiesLinked, message.getSummary());
                }
            }

            System.assert(messageFound);
            Test.stopTest();
        }
    }


    @isTest
    static void testTokenException() {
        //create custom setting test data
        system.runAs(OwlinTestUtils.getOwlinUserWithPermission()) {
            Test.startTest();
            list<Configuration_Settings__c> toInsertCustomSettingRecList = new list<Configuration_Settings__c>();
            Configuration_Settings__c configProd = new Configuration_Settings__c();
            configProd.Name = 'Test_Owlin';
            configProd.Email__c = 'test@test.com';
            configProd.Endpoint__c = 'api.test.owlin/v1/';
            configProd.Password__c = 'testPassword';
            configProd.Is_Primary__c = true;
            toInsertCustomSettingRecList.add(configProd);
            insert toInsertCustomSettingRecList;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(700,null));
            try {
                OwlinEntitiesManagementController.getAccountForBubble();
            } catch (Exception e) {
                System.assertEquals(Label.Error_APITokenError, e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testNoConfigException() {

        Test.startTest();
        try{
            OwlinEntitiesManagementController.getAccountForBubble();
        }
        catch (Exception e)
        {
            System.assertEquals(Label.Error_NoOwlinConfig, e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testAccountBubble() {
        //create custom setting test data
        system.runAs(OwlinTestUtils.getOwlinUserWithPermission()) {
            list<Configuration_Settings__c> toInsertCustomSettingRecList = new list<Configuration_Settings__c>();
            Configuration_Settings__c configProd = new Configuration_Settings__c();
            configProd.Name = 'Test_Owlin';
            configProd.Email__c = 'test@test.com';
            configProd.Endpoint__c = 'api.test.owlin/v1/';
            configProd.Password__c = 'testPassword';
            configProd.Is_Primary__c = true;
            configProd.Token__c = 'testToken';
            configProd.Token_Expiry_Date__c = System.Today().addDays(2);
            toInsertCustomSettingRecList.add(configProd);
            insert toInsertCustomSettingRecList;
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200,'getTimelines'));
            try {
                Map<String, Object> timelineResponse = OwlinEntitiesManagementController.getAccountForBubble();
                System.assert(timelineResponse!=null);
                List<Account> entities = (List<Account>)timelineResponse.get('accounts');
                String timeLine = (String)timelineResponse.get('values');
                System.assertEquals(1,entities.size());
                System.assert(timeLine!=null);
            } catch (Exception e) {

            }
            Test.stopTest();
        }
    }
}