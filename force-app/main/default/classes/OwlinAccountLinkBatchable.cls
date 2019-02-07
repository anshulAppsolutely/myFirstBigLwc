/**
 * this class is used to link entities to owlin
 * default scope of a batch is 200. API is bulkified to handle 200 records in one go
 */
global class OwlinAccountLinkBatchable implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts  {

    Exception[] errors = new Exception[0];
    List<Configuration_Settings__c> requestedConfigurationList;
    String queryString='';

    public OwlinAccountLinkBatchable(String query){
        //get the primary configuration
        requestedConfigurationList = OwlinEntitiesHandler.getRequestedConfiguration(null);
        queryString=query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        if(String.isBlank(queryString)) {
            queryString = 'SELECT Id,Name FROM Account where Owlin_Link_Requested__c!= true and Owlin_Entity_Id__c = null';
        }
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext BC, List<Account> accList) {

        system.debug('executing batch >>'+requestedConfigurationList[0]);
        system.debug('accList size >>'+accList.size());
        try {

            //collection of accounts scope is defined as 200
            //create wrapper for 200 accounts to send


        } catch(Exception e) {
            errors.add(e);
        }


    }

    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like error handling
    }
}