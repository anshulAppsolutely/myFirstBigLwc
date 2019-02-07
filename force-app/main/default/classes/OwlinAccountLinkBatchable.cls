/**
 * this class is used to link entities to owlin
 */
global class OwlinAccountLinkBatchable implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts  {

    Exception[] errors = new Exception[0];
    List<Configuration_Settings__c> requestedConfigurationList;

    public OwlinAccountLinkBatchable(){
        //get the primary configuration
        requestedConfigurationList = OwlinEntitiesHandler.getRequestedConfiguration(null);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        String query = 'SELECT Id,Name FROM Account where Owlin_Link_Requested__c!= true and Owlin_Entity_Id__c = null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> accList) {

        system.debug('executing batch >>'+requestedConfigurationList[0]);
        system.debug('accList size >>'+accList.size());
        try {

            //collection of accounts
            //check with owlin how much records their API can handle


        } catch(Exception e) {
            errors.add(e);
        }


    }

    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like error handling
    }
}