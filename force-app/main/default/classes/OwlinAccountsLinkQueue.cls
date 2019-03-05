/**
 * Created by anshulagrawal on 2019-03-03.
 */

public with sharing class OwlinAccountsLinkQueue implements System.Queueable, Database.AllowsCallouts {

    private Set<Id> queuedAccountIds;
    private Configuration_Settings__c owlinConfiguration;
    String token;

    public OwlinAccountsLinkQueue(Configuration_Settings__c owlinConfiguration, Set<Id> queuedAccountIds, String token) {
        this.queuedAccountIds = queuedAccountIds;
        this.owlinConfiguration = owlinConfiguration;
        this.token = token;
    }

    /**
     * queueable execute method
     *
     * @param context
     */
    public void execute(System.QueueableContext context) {

        try {
            //handle queued transactions
            if (queuedAccountIds.size() > 0 && owlinConfiguration != null) {
                List<Account> accountsToLinkList = new List<Account>();
                //iterate accounts
                for (Account accountToLink : [
                        SELECT
                                id,Website,Name,Owlin_Entity_Id__c,Owlin_Entity_Requested_Id__c
                        from Account
                        where id in :queuedAccountIds
                ]) {
                    accountToLink.Owlin_Entity_Requested_Id__c = context.getJobId();
                    accountsToLinkList.add(accountToLink);
                }
                if (accountsToLinkList != null) {
                    //for updating with owlin entity id
                    Map<Id, Account> accountRequestedToLinkMap = new Map<Id, Account>(accountsToLinkList);
                    OwlinLinkEntitiesRequestWrapper requestWrapper = OwlinEntitiesHandler.prepareOwlinEntityLinkRequest(accountsToLinkList);
                    HttpResponse httpResponse;
                    if (requestWrapper != null) {
                        String body = Json.serialize(requestWrapper);
                        system.debug('body in OwlinAccountsLinkQueue >>' + body);
                        HttpClient client = new HttpClient();
                        String endpointString = 'https://' + owlinConfiguration.Endpoint__c + 'filters/suggest';
                        client.post(endpointString, body, token!=null ? token: owlinConfiguration.Token__c);
                        httpResponse = client.getHttpResponse();
                        if (httpResponse != null) {
                            String jsonResponse = httpResponse.getBody();
                            System.debug('jsonResponse in queue'+jsonResponse);
                            OwlinLinkEntitiesResponseWrapper apiResponse = OwlinLinkEntitiesResponseWrapper.parse(jsonResponse);
                            for (OwlinLinkEntitiesResponseWrapper.matches owlinEntity : apiResponse.matches) {
                                Id accountId = Id.valueOf(owlinEntity.original_id);
                                if (accountRequestedToLinkMap.containsKey(accountId)) {
                                    accountRequestedToLinkMap.get(accountId).Owlin_Entity_Id__c = owlinEntity.filter_id;
                                }
                            }
                        }
                        //updating accounts with filter ids
                        update accountRequestedToLinkMap.values();
                    }

                }
            }
        }catch (Exception e){
            system.debug('Exception occurred in queueable OwlinAccountsLinkQueue job '+e.getMessage());
        }
    }

}