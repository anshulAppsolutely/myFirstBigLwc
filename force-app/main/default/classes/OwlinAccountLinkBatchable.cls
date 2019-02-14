/**
 * this class is used to link entities to owlin
 * default scope of a batch is 200. API is bulkified to handle 200 records in one go
 */
global class OwlinAccountLinkBatchable implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts  {

    Exception[] errors = new Exception[0];
    List<Configuration_Settings__c> owlinConfiguration;
    String queryString='';
    Integer limitFilter;

    public OwlinAccountLinkBatchable(String query, Integer limitEntitiesFilter){
        //get the primary configuration
        owlinConfiguration = OwlinEntitiesHandler.getRequestedConfiguration(null);
        queryString=query;
        limitFilter = limitEntitiesFilter;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        if(String.isBlank(queryString)) {
            String queryFilter = 'WHERE Owlin_Link_Requested__c != true ' +
                    'AND Owlin_Entity_Id__c = null ' +
                    'AND Website != null ' +
                    'ORDER BY CreatedDate DESC';
            if(limitFilter!=null && limitFilter > 0){
                queryFilter += ' limit '+limitFilter;
            }
            queryString = 'SELECT Id,Name,Website,Owlin_Entity_Id__c,Owlin_Link_Requested__c ' +
                    'FROM Account '+queryFilter;
            System.debug('query >>'+queryString);
        }
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext BC, List<Account> accList) {

        system.debug('accList size >>'+accList.size());
        if(accList.size() > 0) {
            //for updating with owlin entity id
            Map<Id, Account> accountRequestedToLinkMap = new Map<Id, Account>(accList);
            try {
                //not checking API expiry. If batch fails request a new token from UI
                if (owlinConfiguration != null && owlinConfiguration.size() > 0
                        && owlinConfiguration[0] != null) {
                    HttpResponse httpResponse;
                    //collection of accounts scope is defined as 200
                    //create wrapper for 200 accounts to send
                    OwlinLinkEntitiesRequestWrapper requestWrapper = OwlinEntitiesHandler.prepareOwlinEntityLinkRequest(accList);
                    if (requestWrapper != null) {
                        String body = Json.serialize(requestWrapper);
                        system.debug('body >>'+body);
                        HttpClient client = new HttpClient();
                        String endpointString = 'https://' + owlinConfiguration[0].Endpoint__c + 'filters/suggest';
                        client.post(endpointString, body, owlinConfiguration[0].Token__c);
                        httpResponse = client.getHttpResponse();
                        if (httpResponse != null) {
                            String jsonResponse = httpResponse.getBody();
                            //system.debug('jsonResponse in batch>>' + jsonResponse);
                            OwlinLinkEntitiesResponseWrapper apiResponse = OwlinLinkEntitiesResponseWrapper.parse(jsonResponse);
                            for(OwlinLinkEntitiesResponseWrapper.matches owlinEntity : apiResponse.matches){
                                Id accountId = Id.valueOf(owlinEntity.original_id);
                                if(accountRequestedToLinkMap.containsKey(accountId)){
                                    accountRequestedToLinkMap.get(accountId).Owlin_Link_Requested__c = true;
                                    accountRequestedToLinkMap.get(accountId).Owlin_Entity_Id__c = owlinEntity.filter_id;
                                }
                            }
                        }
                        //updating accounts with filter ids
                        update accountRequestedToLinkMap.values();
                    }

                }
            } catch (Exception e) {
                System.debug(LoggingLevel.DEBUG, '***** Error:while linking accounts to Owlin in OwlinAccountLinkBatchable ' + e.getMessage());
                errors.add(e);
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like error handling
        if(!errors.isEmpty()) {
            // TODO check with dan
        }

    }
}