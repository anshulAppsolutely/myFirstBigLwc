/**
Created by : Anshul Agrawal
Created Date : 01/03/2019
**/
public with sharing class AccountTriggerHelper {
    
    public static boolean skipTrigger = false;
    public static integer counter=0; 
    
    public void OnBeforeInsert(List<Account> accounts) {
         
    }
    
    public void OnAfterInsert(Map<ID, Account> newAccountMap) {

        set<id> accountIdsToRequest = new set<id>();
        String exceptionMessage;
        Boolean sentToLink = false;
        Boolean generateToken = false;

        try {
            String token = null;
            if (OwlinEntitiesHandler.getLinkedEnities() >= OwlinEntitiesHandler.getFeatureLicenseCount()) {
                sentToLink = false;
                throw new AccountException(Label.Error_EntitiesLicense);
            }
            //check backend configurations
            List<Configuration_Settings__c> owlinConfigList = OwlinEntitiesHandler.getRequestedConfiguration(null);

            if(owlinConfigList == null || owlinConfigList.size() == 0){
                sentToLink = false;
                throw new AccountException(Label.Error_NoOwlinConfig);
            }
            Date today = System.Today();
            if (owlinConfigList != null && owlinConfigList.size() > 0
                    && owlinConfigList[0] != null
                    && owlinConfigList[0].Token__c != null
                    && owlinConfigList[0].Token_Expiry_Date__c > today) {
                token = owlinConfigList[0].Token__c;
            }

            if (token == null) {
                generateToken = true;
            }
            //total entities to request again on clicking link as batch id will get change>>
            Integer totalEntitiesToRequest = OwlinEntitiesHandler.getFeatureLicenseCount() - OwlinEntitiesHandler.getLinkedEnities();
            //add accounts only to which are allowed upto license count and only those accounts which are just added
            for(Account acc : newAccountMap.values()){
                if(totalEntitiesToRequest > 0  && accountIdsToRequest.size() < totalEntitiesToRequest) accountIdsToRequest.add(acc.Id);
            }
            system.debug('accountIdsToRequest to link  >>'+accountIdsToRequest);
            if(accountIdsToRequest.size() > 0) linkAccountsToOwlin(accountIdsToRequest,generateToken);
            sentToLink = true;
        }catch (Exception e){
            exceptionMessage = e.getMessage();
            system.debug('exceptionMessage >> in trigger'+exceptionMessage);

        }
        finally {
            //publish event with message or success
            Owlin_Notification__e notification = new Owlin_Notification__e(
                    Message__c = (sentToLink == true ? Label.Success_EntitiesLinked : Label.Error+'- '+exceptionMessage)+' for Ids '+accountIdsToRequest
            );
            // Call method to publish events
            OwlinEntitiesHandler.publishNotification(notification);
        }
        
    }

    /**
    * call queueable and check size to avoid callout exception
    * you cant add more than 50 queueable jobs in a transaction,
    * assumption we will get less than 5000 accounts to track for owlin in one go!
    *
    * @param requestedAccountIds
    */
    @future(callout = true)
    public static void linkAccountsToOwlin(Set<Id> requestedAccountIds, Boolean generateToken){

        if(requestedAccountIds!=null) {
            String token = null;
            Boolean isTokenNew = false;
            Date today = System.Today();
            List<Configuration_Settings__c> owlinConfigList = OwlinEntitiesHandler.getRequestedConfiguration(null);

            if (generateToken) {
                system.debug('requesting API token from account trigger');
                token = OwlinEntitiesHandler.requestAPIToken(owlinConfigList[0]);
                isTokenNew = true;
            }
            Set<ID> accountIdsToQueue = new Set<ID>();
            for(Id accountId : requestedAccountIds) {
                accountIdsToQueue.add(accountId);
                //check for max count. Queue if size is large
                //avoid sending then to queue to avoid callout exception
                if(accountIdsToQueue.size() > 100) {
                    OwlinAccountsLinkQueue queueAccounts = new OwlinAccountsLinkQueue(owlinConfigList[0], accountIdsToQueue,token);
                    System.enqueueJob(queueAccounts);
                    accountIdsToQueue = new Set<ID>();
                }
            }
            if(accountIdsToQueue.size() > 0) {
                OwlinAccountsLinkQueue queueAccounts = new OwlinAccountsLinkQueue(owlinConfigList[0], accountIdsToQueue,token);
                System.enqueueJob(queueAccounts);
            }
            //save token now after http calls are done
            if(isTokenNew) {
                system.debug('owlinConfig >>'+owlinConfigList[0]);
                owlinConfigList[0].Token__c = token;
                owlinConfigList[0].Token_Expiry_Date__c = today.addDays(25);
                update owlinConfigList[0];
            }
        }
    }

    public void OnBeforeUpdate(Map<ID, Account>  oldAccountMap, Map<ID, Account> newAccountMap) {
        
    }
    
    public void OnAfterUpdate(Map<ID, Account>  oldAccountMap, Map<ID, Account> newAccountMap)
    {
        
    }
    
    public void OnBeforeDelete(Account[] accountsToDelete, Map<ID, Account> oldAccountMap) {
        
    }
    
    public void OnAfterDelete(Account[] deletedAccounts, Map<ID, Account> oldAccountMap) {
        
    }
    
    public void OnUndelete(Account[] restoredAccounts) {
        
    }

    public class AccountException extends Exception {}

}