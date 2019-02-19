@isTest
private class OwlinAccountLinkBatchable_Test {

    @testSetup
    static void setUp() {

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

        list<Account> accountList = new list<Account>();
        Account acc1 = new Account();
        acc1.Name = 'Test';
        acc1.Website = 'test.com';
        accountList.add(acc1);

        Account acc2 = new Account();
        acc2.Name = 'Test 123';
        acc1.Website = 'test123.com';
        accountList.add(acc2);

        insert accountList;

    }


    @isTest
    static void linkEntitiesTest(){
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200,'linkEntity'));
        OwlinAccountLinkBatchable linkOwlinBatch = new OwlinAccountLinkBatchable('',2,null);
        database.executeBatch(linkOwlinBatch, 200);
        Test.stopTest();
        list<Account> account = [Select id, Owlin_Link_Requested__c from Account limit 5];
        System.assertEquals(true, account[0].Owlin_Link_Requested__c);
    }

}