/**
 * Created by anshulagrawal.
 * this class is used to handle data for entities and make request to Owlin
 *
 */

public with sharing class OwlinEntitiesHandler {

    /**
     * get all accounts in the org which are linked to owlin or not
     *
     * @return
     */
    public static List<Account> getAllEnities(){
        return [Select Id, Owlin_Entity_Id__c, Owlin_Link_Requested__c, Name, Owner.name from Account] ;
    }

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
        return [Select Count() from Account where Owlin_Link_Requested__c!= true and Owlin_Entity_Id__c = null] ;
    }

    /**
     * get all accounts in the org which are not linked to owlin but requested
     *
     * @return
     */
    public static Integer getRequestedEnities(){
        return [Select Count() from Account where Owlin_Link_Requested__c = true and Owlin_Entity_Id__c = null] ;
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
    public static void linkEntitiesToOwlin(){
        //pass owlin config to batch
        system.debug('linking entities to owlin >>>');
        //call apex batch class to process records
        OwlinAccountLinkBatchable linkEntities = new OwlinAccountLinkBatchable('');
        //set to maximum scope size
        Database.executeBatch(linkEntities, 2000);
    }

    /**
     * get the api token to mae a call.
     *
     * @return boolean
     */
    public static Boolean requestAPIToken(Configuration_Settings__c owlinConfig){
        system.debug('getting token >>>');
        Boolean tokenGenerated = false;
        if(owlinConfig!=null) {
            try {
                HttpResponse httpResponse;
                OwlinAPITokenRequestWrapper apiRequestWrapper = prepareAPITokenRequest(owlinConfig);
                String body = Json.serialize(apiRequestWrapper);
                HttpClient client = new HttpClient();
                String endpointString = 'https://' + owlinConfig.Endpoint__c + 'tokens';
                client.post(endpointString, body, null);
                httpResponse = client.getHttpResponse();
                system.debug(' error code >>'+httpResponse.getStatusCode());
                if(httpResponse!=null) {
                    String jsonResponse = httpResponse.getBody();
                    OwlinAPITokenResponseWrapper apiResponse = OwlinAPITokenResponseWrapper.parse(jsonResponse);
                    system.debug('apiTokenResponse >>'+apiResponse);
                    saveAPIToken(apiResponse.token);
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.DEBUG, '***** Error:while Requesting API token ' + e.getMessage());
                return tokenGenerated;

            }
        }

        return tokenGenerated;
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
     * this method is used to save the token for future use
     * expiry date is set to 29 days
     *
     * @param token
     */
    public static void saveAPIToken(String token){

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
        //String requestedCustomSettingEntry = 'PayperEmail_SandboxConfiguration';
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