@isTest
private class OwlinAccountsLinkQueue_Test {


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
        accountList.add(acc3);

        Account acc4 = new Account();
        acc4.Name = 'Test 12';
        acc4.Website = 'test12.com';
        accountList.add(acc4);

        insert accountList;

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

    }


    @isTest
    static void queueAccountsToLinkTest()
    {
        Map<String, Configuration_Settings__c> setting = Configuration_Settings__c.getall();
        Configuration_Settings__c config = setting.get('Test_Owlin');
        Set<ID> queuedAccountIds = new Map<ID, Account>([SELECT Id, Name FROM Account]).keySet();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200,'linkEntity'));
        test.startTest();
        System.enqueueJob(new OwlinAccountsLinkQueue(config, queuedAccountIds, null));
        test.stopTest();
        for(Account acc : [Select id,Name,Owlin_Entity_Requested_Id__c FROM Account]){
            System.assert(acc.Owlin_Entity_Requested_Id__c!=null);
        }
    
    }

}