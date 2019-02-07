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
            Boolean isTokenGenerated = true;
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
            //check for valid token or expiry
            //if token is not valid get the new token first
            if(owlinConfigList!=null && owlinConfigList.size() > 0
                    && owlinConfigList[0]!= null
                    && (owlinConfigList[0].Token__c == null || owlinConfigList[0].Token_Expiry_Date__c < today)) {
                system.debug('requesting API token from linkAccountsToOwlin');
                isTokenGenerated = OwlinEntitiesHandler.requestAndSaveAPIToken(owlinConfigList[0]);
            }
            if(!isTokenGenerated){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to link entities.Token not received'));
                return null;
            }

            //request to link accounts to owlin
            OwlinEntitiesHandler.linkEntitiesToOwlin();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Accounts sent to link'));

        }catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to link entities'));
            system.debug('Unable to link entities '+e.getMessage());
            return null;
        }
        return null;
    }

}