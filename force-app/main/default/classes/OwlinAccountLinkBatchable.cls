/**
 * this class is used to link entities to owlin
 * default scope of a batch is 200. API is bulkified to handle 200 records in one go
 */
global class OwlinAccountLinkBatchable implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts  {

    Exception[] errors = new Exception[0];
    List<Configuration_Settings__c> requestedConfigurationList;
    String queryString='';
    Integer limitFilter;

    public OwlinAccountLinkBatchable(String query, Integer limitEntitiesFilter){
        //get the primary configuration
        requestedConfigurationList = OwlinEntitiesHandler.getRequestedConfiguration(null);
        queryString=query;
        limitFilter = limitEntitiesFilter;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        if(String.isBlank(queryString)) {
            String queryFilter = 'WHERE Owlin_Link_Requested__c!= true ' +
                    'AND Owlin_Entity_Id__c = null ' +
                    'ORDER BY CreatedDate DESC';
            if(limitFilter!=null && limitFilter > 0){
                queryFilter += ' limit '+limitFilter;
            }
            queryString = 'SELECT Id,Name,Owlin_Entity_Id__c,Owlin_Link_Requested__c ' +
                    'FROM Account '+queryFilter;
            System.debug('query >>'+queryString);
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