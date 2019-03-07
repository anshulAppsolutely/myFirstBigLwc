/**
 * Created by anshulagrawal.
 * this class is used to handle data for entities and make request to Owlin
 *
 */

public with sharing class OwlinEntitiesHandler {
    @testVisible private static List<Owlin_Notification__e> eventList;

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
        return [Select Count() from Account where Owlin_Entity_Requested_Id__c = null and Owlin_Entity_Id__c = null] ;
    }

    /**
     * get all accounts in the org which are not linked to owlin but requested
     *
     * @return
     */
    public static Integer getRequestedEntities(){
        return [Select Count() from Account where Owlin_Entity_Requested_Id__c!=null and Owlin_Entity_Id__c = null] ;
    }

    /**
     * feature management
     *
     * @return
     */
    public static Integer getFeatureLicenseCount(){
        Integer licenseCount = 0;
        try {
            licenseCount = System.FeatureManagement.checkPackageIntegerValue('Entities_Permitted');
        }catch(Exception e){
            system.debug('error received while fetching the feature parameter'+e.getMessage());
            return 40;
        }
        return licenseCount ;
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
        //defining scope to avoid all out limit, batch is executed in chunks based on scope size.
        Database.executeBatch(linkEntities, 75);

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
                String endpointString = (owlinConfig.Endpoint__c.indexOf('https')!= -1 ? owlinConfig.Endpoint__c: 'https://' + owlinConfig.Endpoint__c) + 'tokens';
                if(Test.isRunningTest()) endpointString = 'getToken';
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
                for(Account account : [SELECT
                        Id, Name, Owlin_Entity_Id__c
                FROM Account WHERE Owlin_Entity_Id__c!=null
                ORDER BY LastModifiedDate DESC LIMIT 100]){
                    keys.add(account.Owlin_Entity_Id__c);
                }
                Map<String, Set<String>> jsonMap = new Map<String, Set<String>>();
                jsonMap.put('keys',keys);
                String inputJson = JSON.serialize(jsonMap);
                system.debug('input json >>>'+inputJson);

                HttpResponse httpResponse;
                HttpClient client = new HttpClient();
                String endpointString = (owlinConfig.Endpoint__c.indexOf('https')!= -1 ? owlinConfig.Endpoint__c: 'https://' + owlinConfig.Endpoint__c) + 'jobs/salesforce/versions/production/timelines';
                client.post(endpointString,inputJson, token!=null ? token: owlinConfig.Token__c);
                httpResponse = client.getHttpResponse();
                if(httpResponse!=null) {
                    timeLineResponse = httpResponse.getBody();
                    //system.debug('timeLineResponse >>'+timeLineResponse);
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.DEBUG, '***** Error:while getting entity timeline ' + e.getMessage());
                throw e;
            }
        }
        return timeLineResponse;
    }

    /**
     * get the entity timeline response
     *
     * @return boolean
     */
    public static String getSingleEntityTimeline(final Configuration_Settings__c owlinConfig, String token, Id recordId){
        String timeLineResponse = null;
        
        if(owlinConfig!=null) {
            try {
                //get all owlin entity that are required
                Set<String> keys = new Set<String>();
                List<Account> account = [SELECT
                        Id, Name, Owlin_Entity_Id__c
                FROM Account WHERE Id = :recordId];
                
                if (account[0].Owlin_Entity_Id__c == null) return '';

            
                HttpResponse httpResponse;
                HttpClient client = new HttpClient();
                String endpointString = (owlinConfig.Endpoint__c.indexOf('https')!= -1 ? owlinConfig.Endpoint__c: 'https://' + owlinConfig.Endpoint__c) + 'jobs/salesforce/versions/production/timelines/' + account[0].Owlin_Entity_Id__c + '/stats/hour';
                System.debug(endpointString);
                client.get(endpointString, token!=null ? token: owlinConfig.Token__c);
                httpResponse = client.getHttpResponse();
                if(httpResponse!=null) {
                    timeLineResponse = httpResponse.getBody();
                    system.debug('timeLineResponse >>'+timeLineResponse);
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.DEBUG, '***** Error:while getting entity timeline ' + e.getMessage());
                throw e;
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
            entityToLink.domain = String.ISBLANK(entity.Website) ? 'null': entity.Website;
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

    /**
     * deserialize json and return key value
     *
     * @param obj
     *
     * @return
     */
    public static Map<String, Object> getJsonDesialzedMap(Object obj) {
        String jsonString = JSON.serialize(obj);
        return (Map<String, Object>) JSON.deserializeUntyped(jsonString);
    }

    /**
     * get the top news data
     *
     * @return boolean
     */
    public static String getTopNewsData(String requestedString, final Configuration_Settings__c owlinConfig, String token){
        String topNewResponse = null;
        if(owlinConfig!=null && requestedString!=null) {
            try {
                system.debug('input json >>>'+requestedString);
                HttpResponse httpResponse;
                HttpClient client = new HttpClient();
                String endpointString = (owlinConfig.Endpoint__c.indexOf('https')!= -1 ? owlinConfig.Endpoint__c: 'https://' + owlinConfig.Endpoint__c) + 'jobs/salesforce/versions/production/events';
                if(Test.isRunningTest()) endpointString = 'topNewsTestEndPoint';
                client.post(endpointString,requestedString, token!=null ? token: owlinConfig.Token__c);
                httpResponse = client.getHttpResponse();
                if(httpResponse!=null) {
                    topNewResponse = httpResponse.getBody();
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.DEBUG, '***** Error:while getting top news ' + e.getMessage());
                throw e;
            }
        }
        return topNewResponse;
    }

    /**
     * get the list of accessible accounts
     *
     * @return boolean
     */
    public static List<Account> getAccessibleAccounts(){
        return [SELECT
                Id, Name, Owlin_Entity_Id__c
        FROM Account
        WHERE Owlin_Entity_Id__c!=null ORDER BY LastModifiedDate DESC limit 100];
    }

    /**
     * method used to publish notifications
     *
     * @param event
     */
    public static void publishNotification(Owlin_Notification__e event){
        eventList = new List<Owlin_Notification__e>();
        eventList.add(event);
        EventBus.publish(event);
    }

}