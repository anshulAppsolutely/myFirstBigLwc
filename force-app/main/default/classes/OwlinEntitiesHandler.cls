/**
 * Created by anshulagrawal.
 * this class is used to handle data for entities and make request to Owlin
 *
 */

public with sharing class OwlinEntitiesHandler {

    /**
     * get all accounts in the org which are linked to owlin
     *
     * @return
     */
    public static Integer getLinkedEnities(){
        return [Select Count() from Account where Owlin_Entity_Id__c!=null] ;
    }

    /**
     * get all accounts in the org which are not linked to owlin and not requested
     *
     * @return
     */
    public static Integer getNotLinkedEnities(){
        return [Select Count() from Account where website!=null and Owlin_Entity_Requested_Id__c = null and Owlin_Entity_Id__c = null] ;
    }

    /**
     * get all accounts in the org which are not linked to owlin but requested
     *
     * @return
     */
    public static Integer getRequestedEnities(){
        return [Select Count() from Account where Owlin_Entity_Requested_Id__c!=null and Owlin_Entity_Id__c = null] ;
    }

    /**
     * feature management
     *
     * @return
     */
    public static Integer getFeatureLicenseCount(){
        return 20 ;
    }

    /**
     * this method is used to request entities to Owlin
     * A batch class is called to handle the request to handle all accounts
     *
     * @param accountsToLink
     */
    public static void linkEntitiesToOwlin(Integer limitEntitiesFilter, String tokenString){
        //pass owlin config to batch
        system.debug('linking entities to owlin >>>');
        //call apex batch class to process records
        OwlinAccountLinkBatchable linkEntities = new OwlinAccountLinkBatchable('',limitEntitiesFilter, tokenString);
        //set to maximum scope size
        Database.executeBatch(linkEntities, 200);

    }

    /**
     * get the api token to mae a call.
     * admin will going to call it
     *
     * @return String token
     */
    public static String requestAPIToken(Configuration_Settings__c owlinConfig){
        system.debug('getting token >>>');
        String token = null;
        if(owlinConfig!=null) {
            try {
                HttpResponse httpResponse;
                OwlinAPITokenRequestWrapper apiRequestWrapper = prepareAPITokenRequest(owlinConfig);
                String body = Json.serialize(apiRequestWrapper);
                HttpClient client = new HttpClient();
                String endpointString = 'https://' + owlinConfig.Endpoint__c + 'tokens';
                client.post(endpointString, body, null);
                httpResponse = client.getHttpResponse();
                if(httpResponse!=null) {
                    String jsonResponse = httpResponse.getBody();
                    OwlinAPITokenResponseWrapper apiResponse = OwlinAPITokenResponseWrapper.parse(jsonResponse);
                    //system.debug('apiTokenResponse >>'+apiResponse);
                    token = apiResponse.token;
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.DEBUG, '***** Error:while Requesting API token ' + e.getMessage());
                return null;

            }
        }
        return token;
    }

    /**
     * get the entity timeline response
     *
     * @return boolean
     */
    public static String getEntityTimeline(final Configuration_Settings__c owlinConfig, String token){
        String timeLineResponse = null;
        if(owlinConfig!=null) {
            try {
                //get all owlin entity that are required
                Set<String> keys = new Set<String>();
                // method is called from a with sharing context and will send records to which user has access too.
                /*Set<String> sharedAccountIds = new Set<String>();

                List<String> userOrGroupIds = new List<String>();
                //get all the groups user is member of
                for (GroupMember gm : [SELECT Id, group.id, group.name, group.type FROM GroupMember where UserOrGroupId = :UserInfo.getUserId()]){
                    userOrGroupIds.add(gm.group.id);
                }
                //add current user in the group of ids
                userOrGroupIds.add(UserInfo.getUserId());
                //check in share object if any account has been shared to loggedin user
                for(AccountShare s : [SELECT AccountId,  UserOrGroupId FROM AccountShare WHERE UserOrGroupId =: userOrGroupIds ]){
                    sharedAccountIds.add(s.AccountId);
                }*/

                //query all accounts which were shared/accessible to it
                for(Account account : [SELECT
                        Id, Name, Owlin_Entity_Id__c
                FROM Account WHERE Owlin_Entity_Id__c!=null
                ORDER BY CreatedDate DESC LIMIT 100]){
                    keys.add(account.Owlin_Entity_Id__c);
                }
                Map<String, Set<String>> jsonMap = new Map<String, Set<String>>();
                jsonMap.put('keys',keys);
                String inputJson = JSON.serialize(jsonMap);
                system.debug('input json >>>'+inputJson);

                HttpResponse httpResponse;
                HttpClient client = new HttpClient();
                String endpointString = 'https://' + owlinConfig.Endpoint__c + 'jobs/salesforce/versions/production/timelines';
                client.post(endpointString,inputJson, token!=null ? token: owlinConfig.Token__c);
                httpResponse = client.getHttpResponse();
                if(httpResponse!=null) {
                    timeLineResponse = httpResponse.getBody();
                    system.debug('timeLineResponse >>'+timeLineResponse);
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.DEBUG, '***** Error:while getting entity timeline ' + e.getMessage());
                return null;
            }
        }
        return timeLineResponse;
    }


    /**
     * prepare requesting API token
     *
     * @return
     */
    private static OwlinAPITokenRequestWrapper prepareAPITokenRequest(Configuration_Settings__c owlinConfig){
        OwlinAPITokenRequestWrapper apiRequestWrapper = new OwlinAPITokenRequestWrapper();
        apiRequestWrapper.email = owlinConfig.Email__c;
        apiRequestWrapper.password = owlinConfig.Password__c;
        apiRequestWrapper.expire = '30d';
        return apiRequestWrapper;
    }

    /**
     * prepare request to link entities to Owlin
     *
     * @return
     */
    public static OwlinLinkEntitiesRequestWrapper prepareOwlinEntityLinkRequest(List<Account> requestedAccountList){
        OwlinLinkEntitiesRequestWrapper apiRequestWrapper = new OwlinLinkEntitiesRequestWrapper();
        List<OwlinLinkEntitiesRequestWrapper.entities> entityList = new List<OwlinLinkEntitiesRequestWrapper.entities>();
        for(Account entity : requestedAccountList){
            OwlinLinkEntitiesRequestWrapper.entities entityToLink = new OwlinLinkEntitiesRequestWrapper.entities();
            entityToLink.id = entity.Id;
            entityToLink.domain = entity.Website;
            entityToLink.name = entity.Name;
            entityList.add(entityToLink);
        }
        apiRequestWrapper.entities = entityList;
        return apiRequestWrapper;
    }

    /**
     * this method is used to save the token for future use
     * expiry date is set to 29 days
     *
     * @param token
     */
    @future
    public static void saveAPIToken(String token){
        List<Configuration_Settings__c> owlinConfigList = OwlinEntitiesHandler.getRequestedConfiguration(null);
        system.debug('owlinConfig >>'+owlinConfigList[0]);
        Date today = System.Today();
        owlinConfigList[0].Token__c = token;
        owlinConfigList[0].Token_Expiry_Date__c = today.addDays(25);
        update owlinConfigList[0];
    }

    /**
     * this method is used to get the configuration custom settings at runtime
     *
     * @param owlinConfig
     *
     * @return
     */
    public static List<Configuration_Settings__c> getRequestedConfiguration(String owlinConfig) {

        List<Configuration_Settings__c> owlinConfigList;
        if(!String.isBlank(owlinConfig)) {
            Configuration_Settings__c requestedConfiguration = Configuration_Settings__c.getInstance(owlinConfig);
            if(requestedConfiguration!=null && requestedConfiguration.Endpoint__c != null){
                owlinConfigList = new List<Configuration_Settings__c>();
                owlinConfigList.add(Configuration_Settings__c.getInstance(owlinConfig));
            }
        }
        //if its still null get the primary configuration. Only one can be primary
        if(owlinConfigList == null) {
            owlinConfigList = [
                    SELECT Name,ID,Endpoint__c,Is_Primary__c,Email__c,
                            Password__c,Token__c,Token_Expiry_Date__c
                    FROM Configuration_Settings__c
                    WHERE Is_Primary__c = true];
        }
        return owlinConfigList;
    }

}