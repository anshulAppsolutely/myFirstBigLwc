@isTest
private with sharing class  AccountTriggerHelper_Test {

    @isTest
    private static void testAccountToLinkWithToken() {

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
        system.runAs(OwlinTestUtils.getOwlinUserWithPermission()) {
            Test.startTest();
            list<Account> accountList = new list<Account>();
            Account acc1 = new Account();
            acc1.Name = 'Test';
            accountList.add(acc1);

            Account acc2 = new Account();
            acc2.Name = 'Test 123';
            acc1.Website = 'test123.com';
            accountList.add(acc2);

            insert accountList;
            Test.stopTest();
            AsyncApexJob job = [SELECT Id, Status, MethodName, ApexClass.Name FROM AsyncApexJob];
            System.assertEquals('OwlinAccountsLinkQueue', job.ApexClass.Name);
            System.assertEquals( 1, OwlinEntitiesHandler.eventList.size());
        }
    }
    
        @isTest
    private static void testAccountToLinkWithoutToken() {

        //create custom setting test data
        list<Configuration_Settings__c> toInsertCustomSettingRecList = new list<Configuration_Settings__c>();

        Configuration_Settings__c configProd = new Configuration_Settings__c();
        configProd.Name = 'Test_Owlin';
        configProd.Email__c = 'test@test.com';
        configProd.Endpoint__c = 'api.test.owlin/v1/';
        configProd.Password__c = 'testPassword';
        configProd.Token_Expiry_Date__c = System.Today().addDays(-2);
        configProd.Is_Primary__c = True;
        toInsertCustomSettingRecList.add(configProd);

        insert toInsertCustomSettingRecList;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200,'getToken'));
        system.runAs(OwlinTestUtils.getOwlinUserWithPermission()) {
            Test.startTest();
            list<Account> accountList = new list<Account>();
            Account acc1 = new Account();
            acc1.Name = 'Test';
            accountList.add(acc1);

            Account acc2 = new Account();
            acc2.Name = 'Test 123';
            acc1.Website = 'test123.com';
            accountList.add(acc2);

            insert accountList;
            Test.stopTest();
            Map<String, Configuration_Settings__c> setting = Configuration_Settings__c.getall();
        	Configuration_Settings__c config = setting.get('Test_Owlin');
            System.assertEquals('testToken' , config.Token__c);
        	System.assertEquals(config.Token_Expiry_Date__c > System.Today(), true);
            AsyncApexJob job = [SELECT Id, Status, MethodName, ApexClass.Name FROM AsyncApexJob];
            System.assertEquals('OwlinAccountsLinkQueue', job.ApexClass.Name);
            System.assertEquals( 1, OwlinEntitiesHandler.eventList.size());
            
            //update
            acc2.Website = 'test23.com';
            update acc2;
            
            delete acc2;
        }
    }

}