/**
 * Created by anshulagrawal.
 * this class is used to match the linked entities to owlin and
 * also to request more based on license
 *
 */

public with sharing class OwlinEntitiesManagementController {

    //private String

    public OwlinEntitiesManagementController(){

    }

    public Integer likedEntitiesCount
    {
        get
        {
            if(likedEntitiesCount==null) {
                likedEntitiesCount = OwlinEntitiesHandler.getLinkedEnities();
            }
            return likedEntitiesCount;
        }
        private set;
    }

    public Integer entitiesNotLinkedCount
    {
        get
        {
            if(entitiesNotLinkedCount==null) {
                entitiesNotLinkedCount = OwlinEntitiesHandler.getNotLinkedEnities();
            }
            return entitiesNotLinkedCount;
        }
        private set;
    }

    public Integer entitiesRequestedCount
    {
        get
        {
            if(entitiesRequestedCount==null) {
                entitiesRequestedCount = OwlinEntitiesHandler.getRequestedEnities();
            }
            return entitiesRequestedCount;
        }
        private set;
    }

    public Integer entitiesLicenseCount
    {
        get
        {
            if(entitiesLicenseCount==null) {
                entitiesLicenseCount = OwlinEntitiesHandler.getFeatureLicenseCount();
            }
            return entitiesLicenseCount;
        }
        private set;
    }

    public void requestLicense(){
        //create a case ?

    }

    /**
     * method used to send data to owlin to request to a future method to make API request
     * only primary will be updated
     */
    public PageReference linkAccountsToOwlin(){
        try {
            String token = null;
            if (entitiesNotLinkedCount == null || entitiesNotLinkedCount == 0){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'There are no accounts to link');
                ApexPages.addMessage(msg);
                return null;
            }
            if (likedEntitiesCount >= entitiesLicenseCount) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot link more entities. Please request more license');
                ApexPages.addMessage(msg);
                return null;
            }
            //check backend configurations
            List<Configuration_Settings__c> owlinConfigList = OwlinEntitiesHandler.getRequestedConfiguration(null);
            if(owlinConfigList == null || owlinConfigList.size() == 0){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please configure Owlin data in setup');
                ApexPages.addMessage(msg);
                return null;
            }
            Date today = System.Today();
            if(owlinConfigList!=null && owlinConfigList.size() > 0
                    && owlinConfigList[0]!= null
                    && owlinConfigList[0].Token__c != null
                    && owlinConfigList[0].Token_Expiry_Date__c > today){
                token = owlinConfigList[0].Token__c;
            }
            //check for valid token or expiry
            //if token is not valid get the new token first
            if(owlinConfigList!=null && owlinConfigList.size() > 0
                    && owlinConfigList[0]!= null
                    && (owlinConfigList[0].Token__c == null || owlinConfigList[0].Token_Expiry_Date__c < today)) {
                system.debug('requesting API token from linkAccountsToOwlin');
                token = OwlinEntitiesHandler.requestAPIToken(owlinConfigList[0]);
                OwlinEntitiesHandler.saveAPIToken(token);
            }
            if(token == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to link entities.Token not received'));
                return null;
            }
            system.debug('token received >>>'+token);
            //get accounts that can be linked based on license
            //here we will always get the positive value as we checked condition
            Integer limitEntitiesFilter = entitiesLicenseCount - likedEntitiesCount;

            //request to link accounts to owlin
            OwlinEntitiesHandler.linkEntitiesToOwlin(limitEntitiesFilter, token);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Accounts sent to link'));

        }catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to link entities'));
            system.debug('Unable to link entities '+e.getMessage());
            return null;
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getAccountForBubble() {
        String token;
        //check for any filters
        //check backend configurations
        List<Configuration_Settings__c> owlinConfigList = OwlinEntitiesHandler.getRequestedConfiguration(null);
        if(owlinConfigList == null || owlinConfigList.size() == 0){
            AuraHandledException noAccessException = new AuraHandledException('Please configure Owlin data in setup');
            noAccessException.setMessage('Please configure Owlin data in setup');
            throw noAccessException;
        }
        Date today = System.Today();
        if(owlinConfigList!=null && owlinConfigList.size() > 0
                && owlinConfigList[0]!= null
                && owlinConfigList[0].Token__c != null
                && owlinConfigList[0].Token_Expiry_Date__c > today){
            token = owlinConfigList[0].Token__c;
        }
        //check for valid token or expiry
        //if token is not valid get the new token first
        if(owlinConfigList!=null && owlinConfigList.size() > 0
                && owlinConfigList[0]!= null
                && (owlinConfigList[0].Token__c == null || owlinConfigList[0].Token_Expiry_Date__c < today)) {
            system.debug('requesting API token from linkAccountsToOwlin');
            token = OwlinEntitiesHandler.requestAPIToken(owlinConfigList[0]);
        }
        if(token == null){
            AuraHandledException noAccessException = new AuraHandledException('Unable to Request timeline.Token not received');
            noAccessException.setMessage('Unable to Request timeline.Token not received');
            throw noAccessException;
        }
        String timelineResponse = OwlinEntitiesHandler.getEntityTimeline(owlinConfigList[0], token);
        OwlinEntitiesHandler.saveAPIToken(token);
        return timelineResponse;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getUserAccountList() {
        return [SELECT Id, Name, Owlin_Entity_Id__c FROM Account WHERE OwnerId = :UserInfo.getUserId()]; // WHERE Owlin_Entity_Id__c IS NOT NULL
    }
}