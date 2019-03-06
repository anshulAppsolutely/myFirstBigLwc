@isTest
private class OwlinAccountLinkScheduler_Test {

    @testSetup
    static void setUp() {
        
        
        //create custom setting test data
        list<Configuration_Settings__c> toInsertCustomSettingRecList = new list<Configuration_Settings__c>();

        Configuration_Settings__c configProd = new Configuration_Settings__c();
        configProd.Name = 'Test_Owlin';
        configProd.Email__c = 'test@test.com';
        configProd.Endpoint__c = 'api.test.owlin/v1/';
        configProd.Password__c = 'testPassword';
        configProd.Is_Primary__c = True;
        toInsertCustomSettingRecList.add(configProd);

        insert toInsertCustomSettingRecList;
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
        acc4.Owlin_Entity_Id__c = '1234';
        accountList.add(acc4);

        insert accountList;

    }

    @isTest
    static void testBatchExecution() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200,'linkEntity'));
        test.startTest();
        // This test runs a scheduled job at midnight Sept. 3rd. 2022
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        OwlinAccountLinkScheduler sch = new OwlinAccountLinkScheduler();
        String jobId = system.schedule('Example Batch Schedule job', CRON_EXP, sch);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        // Verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        test.stopTest();
    }

}