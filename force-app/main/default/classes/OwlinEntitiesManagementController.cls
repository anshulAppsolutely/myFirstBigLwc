/**
 * Created by anshulagrawal.
 * this class is used to match the linked entities to owlin and
 * also to request more based on license
 *
 */

public with sharing class OwlinEntitiesManagementController {

    //private String
    private static Map<String, Map<string, List<String>>> accessMapByrecordName = new Map<String, Map<String, List<String>>> {

            'Account' => new Map<String, List<String>> {
                    'Read' => new List<String> {
                            'Owlin_Entity_Id__c', 'Owlin_Entity_Requested_Id__c', 'Name'
                    }
            }
    };

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
        set;
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
        set;
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
        set;
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
        set;
    }

    /**
     * method used to send data to owlin to request to a future method to make API request
     * only primary will be updated
     */
    public PageReference linkAccountsToOwlin(){
        try {
            String token = null;
            if (entitiesNotLinkedCount == null || entitiesNotLinkedCount == 0){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Error_NoEntitiesToLink);
                ApexPages.addMessage(msg);
                return null;
            }
            if (likedEntitiesCount >= entitiesLicenseCount) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Error_EntitiesLicense);
                ApexPages.addMessage(msg);
                return null;
            }
            //check backend configurations
            List<Configuration_Settings__c> owlinConfigList = OwlinEntitiesHandler.getRequestedConfiguration(null);
            if(owlinConfigList == null || owlinConfigList.size() == 0){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Error_NoOwlinConfig);
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
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Error_APITokenError));
                return null;
            }
            system.debug('token received >>>'+token);
            //get accounts that can be linked based on license
            //here we will always get the positive value as we checked condition
            Integer limitEntitiesFilter = entitiesLicenseCount - likedEntitiesCount;

            //request to link accounts to owlin
            OwlinEntitiesHandler.linkEntitiesToOwlin(limitEntitiesFilter, token);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.Success_EntitiesLinked));

        }catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Error));
            system.debug('Unable to link entities '+e.getMessage());
            return null;
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getAccountForBubble() {
        String token;
        Map<String, Object> response = new Map<String, Object>();
        //check for any filters
        //check backend configurations
        List<Configuration_Settings__c> owlinConfigList = OwlinEntitiesHandler.getRequestedConfiguration(null);
        if (owlinConfigList == null || owlinConfigList.size() == 0) {
            AuraHandledException auraException = new AuraHandledException(Label.Error_NoOwlinConfig);
            auraException.setMessage(Label.Error_NoOwlinConfig);
            throw auraException;
        }
        Date today = System.Today();
        if (owlinConfigList != null && owlinConfigList.size() > 0
                && owlinConfigList[0] != null
                && owlinConfigList[0].Token__c != null
                && owlinConfigList[0].Token_Expiry_Date__c > today) {
            token = owlinConfigList[0].Token__c;
        }
        //check for valid token or expiry
        //if token is not valid get the new token first
        if (owlinConfigList != null && owlinConfigList.size() > 0
                && owlinConfigList[0] != null
                && (owlinConfigList[0].Token__c == null || owlinConfigList[0].Token_Expiry_Date__c < today)) {
            system.debug('requesting API token from linkAccountsToOwlin');
            token = OwlinEntitiesHandler.requestAPIToken(owlinConfigList[0]);
        }

        if (token == null) {
            AuraHandledException auraException = new AuraHandledException(Label.Error_APITokenError);
            auraException.setMessage(Label.Error_APITokenError);
            throw auraException;
        }
        //check whether user has permission to read account object
        try{
            OwlinDMLManager.checkAccess(accessMapByrecordName);
        }catch(Exception e){
            AuraHandledException auraException = new AuraHandledException(Label.Owlin_Permission_Error);
            auraException.setMessage(Label.Owlin_Permission_Error);
            throw auraException;
        }
        try{
            String timelineResponse = OwlinEntitiesHandler.getEntityTimeline(owlinConfigList[0], token);
            OwlinEntitiesHandler.saveAPIToken(token);
            Set<String> sharedAccountIds = new Set<String>();
            List<String> userOrGroupIds = new List<String>();
            //the class is marked as with sharing. Will get all the records for a user to which he has access to!
            /*for (GroupMember gm : [SELECT Id, group.id, group.name, group.type FROM GroupMember where UserOrGroupId = :UserInfo.getUserId()]){
                userOrGroupIds.add(gm.group.id);
            }
            //add current user in the group of ids
            userOrGroupIds.add(UserInfo.getUserId());
            //check in share object if any account has been shared to loggedin user
            for(AccountShare s : [SELECT AccountId,  UserOrGroupId FROM AccountShare WHERE UserOrGroupId =: userOrGroupIds ]){
                sharedAccountIds.add(s.AccountId);
            }*/
            // check for limit
            List<Account> accessibleAccounts = [SELECT
                    Id, Name, Owlin_Entity_Id__c
            FROM Account
            WHERE Owlin_Entity_Id__c!=null ORDER BY CreatedDate DESC];
            response.put('accounts', accessibleAccounts);
            response.put('values', timelineResponse);
            
        }catch(Exception e){
            AuraHandledException auraException = new AuraHandledException(Label.Error);
            auraException.setMessage(Label.Error);
            throw auraException;
        }
        return response;
    }
}