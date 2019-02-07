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
        OwlinAccountLinkBatchable linkEntities = new OwlinAccountLinkBatchable();
        //set to maximum scope size
        Database.executeBatch(linkEntities, 2000);
    }

    /**
     * get the api token to mae a call.
     *
     * @return
     */
    public static String requestAPIToken(){
        system.debug('getting token >>>');
        return null;
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
     * @param requestedCustomSettingName
     *
     * @return
     */
    public static List<Configuration_Settings__c> getRequestedConfiguration(String requestedCustomSettingName) {

        List<Configuration_Settings__c> requestedConfigurationList;
        //String requestedCustomSettingEntry = 'PayperEmail_SandboxConfiguration';
        if(!String.isBlank(requestedCustomSettingName)) {
            Configuration_Settings__c requestedConfiguration = Configuration_Settings__c.getInstance(requestedCustomSettingName);
            if(requestedConfiguration!=null && requestedConfiguration.Endpoint__c != null){
                requestedConfigurationList = new List<Configuration_Settings__c>();
                requestedConfigurationList.add(Configuration_Settings__c.getInstance(requestedCustomSettingName));
            }
        }
        //if its still null get the primary configuration. Only one can be primary
        if(requestedConfigurationList == null) {
            requestedConfigurationList = [
                    SELECT Name,ID,Endpoint__c,Is_Primary__c,Email__c,
                            Password__c,Token__c,Token_Expiry_Date__c
                    FROM Configuration_Settings__c
                    WHERE Is_Primary__c = true];
        }

        return requestedConfigurationList;
    }

}