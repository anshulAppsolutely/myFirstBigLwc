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

    public Integer linkedEntitiesCount
    {
        get
        {
            if(linkedEntitiesCount==null) {
                linkedEntitiesCount = OwlinEntitiesHandler.getLinkedEnities();
            }
            return linkedEntitiesCount;
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
                entitiesRequestedCount = OwlinEntitiesHandler.getRequestedEntities();
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
            Integer limitEntitiesFilter = entitiesLicenseCount - linkedEntitiesCount;
            if (entitiesNotLinkedCount == 0 && entitiesRequestedCount == 0){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Error_NoEntitiesToLink);
                ApexPages.addMessage(msg);
                return null;
            }
            if (linkedEntitiesCount >= entitiesLicenseCount) {
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
            //total entities to request again on clicking link as batch id will get change>>
            Integer totalEntitiesToRequest = entitiesNotLinkedCount + entitiesRequestedCount;
            if(totalEntitiesToRequest > limitEntitiesFilter){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING, Label.Warning_MoreEntitiesRequested);
                ApexPages.addMessage(msg);
            }
            system.debug('token received >>>'+token);
            //get accounts that can be linked based on license
            //here we will always get the positive value as we checked condition

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

    /**
     * this method is used to generate the bubble chart and make api call to owlin
     *
     * @return
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getAccountForBubble() {
        String token;
        Map<String, Object> response = new Map<String, Object>();
        Boolean isTokenNew = false;
        //check for any filters
        //check backend configurations
        system.debug('getting timeline from aura >>>');
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
            system.debug('requesting API token from bubble');
            token = OwlinEntitiesHandler.requestAPIToken(owlinConfigList[0]);
            isTokenNew = true;
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
            system.debug('timelineResponse in bubble>>'+timelineResponse);
            List<Account> accessibleAccounts = OwlinEntitiesHandler.getAccessibleAccounts();
            response.put('accounts', accessibleAccounts);
            response.put('values', timelineResponse);
            response.put('token', token);
            //save token now after http calls are done and if new token was requested
            if(isTokenNew) OwlinEntitiesHandler.saveAPIToken(token);
        }catch(Exception e){
            system.debug('exception in getting bubbles '+e.getMessage());
            AuraHandledException auraException = new AuraHandledException(Label.Error);
            auraException.setMessage(Label.Error);
            throw auraException;
        }
        return response;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getAccountTimeline(Id recordId) {
        System.debug('recordId');
        System.debug(recordId);

        String token;
        Map<String, Object> response = new Map<String, Object>();
        //check for any filters
        //check backend configurations
        system.debug('getting timeline from aura >>>');
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
            String timelineResponse = OwlinEntitiesHandler.getSingleEntityTimeline(owlinConfigList[0], token, recordId);
            OwlinEntitiesHandler.saveAPIToken(token);
            response.put('values', timelineResponse);
            
        }catch(Exception e){
            AuraHandledException auraException = new AuraHandledException(Label.Error);
            auraException.setMessage(Label.Error);
            throw auraException;
        }
        return response;
    }
    /**
     * this method is used to get the topnews data
     * the request is created from bubble data with entities as keys as list of article ids
     *
     * @param filter
     *
     * @return
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getTopNewsData(String filter) {
        Map<String, Object> response = new Map<String, Object>();
        system.debug('filter >>>'+filter);
        String token;
        Boolean isTokenNew = false;
        if(!String.isBlank(filter)) {
            //check for any filters
            //check backend configurations
            system.debug('getting getTopNewsData from aura >>>');
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
                system.debug('requesting API token from getTopNewsData');
                token = OwlinEntitiesHandler.requestAPIToken(owlinConfigList[0]);
                isTokenNew = true;
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
                //get timeline data for making topnews request
                String timelineResponse = OwlinEntitiesHandler.getEntityTimeline(owlinConfigList[0], token);
                system.debug('timelineResponse in top news >>'+timelineResponse);

                List<Object> objm = (List<Object>) JSON.deserializeUntyped(timelineResponse);
                Map<String, List<String>> topNewRequest = getTopNewRequest(objm, filter);
                system.debug('topNewRequest >>>'+topNewRequest);
                if(topNewRequest!= null && topNewRequest.size() > 0) {
                    Map<String, Object> requestToSerialize = new Map<String, Object>{'timelines' => topNewRequest};
                    system.debug('requestToSerialize in topnews >>>'+requestToSerialize);
                    String serializedString =  JSON.serialize(requestToSerialize);
                    String topNewsResponse = OwlinEntitiesHandler.getTopNewsData(serializedString,owlinConfigList[0], token);
                    Map<String,Object> topNewsMap = (Map<String,Object>)JSON.deserializeUntyped(topNewsResponse);
                    List<Object> topNewsResponseObj = new List<Object>();
                    for(String topNews : topNewsMap.keySet()){
                        List<Object> articleTopNewsList = (List<Object>)topNewsMap.get(topNews);
                        if(articleTopNewsList!=null && articleTopNewsList.size() > 0){
                            for(Object articleTopNews : articleTopNewsList){
                                topNewsResponseObj.add(articleTopNews);
                            }
                        }
                    }

                    system.debug('topNewsResponseObj  '+topNewsResponseObj);
                    response.put('values', topNewsResponseObj);
                    //if there are no articles dont fetch the accounts
                    if(topNewsResponseObj.size() > 0) {
                        List<Account> accessibleAccounts = OwlinEntitiesHandler.getAccessibleAccounts();
                        response.put('accounts', accessibleAccounts);
                    }
                    //save token now after http calls are done
                    if(isTokenNew) OwlinEntitiesHandler.saveAPIToken(token);
                }

            } catch (Exception e) {
                system.debug('exception in getting top news '+e.getMessage());
                AuraHandledException auraException = new AuraHandledException(Label.Error);
                auraException.setMessage(Label.Error);
                throw auraException;
            }
        }
        return response;
    }

    /**
     * the method is used to parse json and get top news
     *
     * @param objm
     * @param filter
     *
     * @return
     */
    private static Map<String, List<String>> getTopNewRequest(List<Object> objm, String filter) {
        Map<String, List<String>> topNewRequest = new Map<String, List<String>>();

        for (Object responseObject : objm) {
            String entityKey;
            List<String> articles = new List<String>();
            Map<String, Object> responseMap = OwlinEntitiesHandler.getJsonDesialzedMap(responseObject);
            if (responseMap != null) {
                for (String keyVal : responseMap.keySet()) {
                    if (keyVal == 'key') {
                        entityKey = (String) responseMap.get(keyVal);
                    }
                    if (keyVal == 'stats') {
                        Object statsObject = responseMap.get(keyVal);
                        Map<String, Object> statsMap = OwlinEntitiesHandler.getJsonDesialzedMap(statsObject);
                        if (statsMap != null) {
                            for (String statsKey : statsMap.keySet()) {
                                if (statsKey.equalsIgnoreCase(filter)) {
                                    Object filterNewsObj = statsMap.get(statsKey);
                                    Map<String, Object> filterNewsMap = OwlinEntitiesHandler.getJsonDesialzedMap(filterNewsObj);
                                    //system.debug('filterNewsMap >>>'+filterNewsMap);
                                    for (String filterNews : filterNewsMap.keySet()) {
                                        //system.debug('filterNews >'+filterNewsMap.get(filterNews));
                                        List<Object> resultslist = (List<Object>) filterNewsMap.get(filterNews);
                                        for (Object mapa : resultslist) {
                                            Map<String, Object> tempMap = (Map<String, Object>) mapa;
                                            String articleId = (String) tempMap.get('urlhash');
                                            //system.debug('articleId '+tempMap.get('urlhash'));
                                            articles.add(articleId);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if (!topNewRequest.containsKey(entityKey)) topNewRequest.put(entityKey, articles);
            }
        }
        return topNewRequest;
    }
}