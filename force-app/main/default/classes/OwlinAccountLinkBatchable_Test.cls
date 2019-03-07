@isTest
private class OwlinAccountLinkBatchable_Test {

    @testSetup
    static void setUp() {

        AccountTriggerHelper.skipTrigger = true;
        list<Account> accountList = new list<Account>();
        Account acc1 = new Account();
        acc1.Name = 'Test';
        accountList.add(acc1);

        Account acc2 = new Account();
        acc2.Name = 'Test 123';
        acc1.Website = 'test123.com';
        accountList.add(acc2);

        insert accountList;

    }

    @isTest
    static void linkEntitiesTest(){
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
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200,'linkEntity'));
        OwlinAccountLinkBatchable linkOwlinBatch = new OwlinAccountLinkBatchable('',2,null);
        database.executeBatch(linkOwlinBatch, 200);
        Test.stopTest();
        list<Account> account = [Select id, Owlin_Entity_Requested_Id__c from Account limit 5];
        System.assert(account[0].Owlin_Entity_Requested_Id__c!=null);
    }
    
    @isTest
    static void testGenerateNewToken(){
        //create custom setting test data
        list<Configuration_Settings__c> toInsertCustomSettingRecList = new list<Configuration_Settings__c>();

        Configuration_Settings__c configProd = new Configuration_Settings__c();
        configProd.Name = 'Test_Owlin1';
        configProd.Email__c = 'test@test.com';
        configProd.Endpoint__c = 'api.test.owlin/v1/';
        configProd.Password__c = 'testPassword';
        configProd.Token_Expiry_Date__c = System.Today().addDays(-2);
        configProd.Is_Primary__c = True;
        toInsertCustomSettingRecList.add(configProd);

        insert toInsertCustomSettingRecList;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200,'linkEntity'));
        OwlinAccountLinkBatchable linkOwlinBatch = new OwlinAccountLinkBatchable('',2,null);
        database.executeBatch(linkOwlinBatch, 200);
        Test.stopTest();
        for(Account acc : [Select id,Name,Owlin_Entity_Requested_Id__c FROM Account]){  
            System.assert(acc.Owlin_Entity_Requested_Id__c!=null);
        }
        //get the custom settings again
        Map<String, Configuration_Settings__c> setting = Configuration_Settings__c.getall();
        Configuration_Settings__c config = setting.get('Test_Owlin1');
        System.assertEquals('testToken' , config.Token__c);
        System.assertEquals(config.Token_Expiry_Date__c > System.Today(), true);
    }
}