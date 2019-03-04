/**
Created by : Anshul Agrawal
Created Date : 01/03/2019
**/
public class AccountTriggerHelper {
    
    public static boolean skipTrigger = false;
    public static integer counter=0; 
    
    public void OnBeforeInsert(List<Account> accounts) {
         
    }
    
    public void OnAfterInsert(Map<ID, Account> newAccountMap) {

        set<id> accountIdsToRequest = new set<id>();
        String exceptionMessage;
        Boolean sentToLink = false;

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
                sentToLink = false;
                throw new AccountException(Label.Error_APITokenError);
            }
            //total entities to request again on clicking link as batch id will get change>>
            Integer totalEntitiesToRequest = OwlinEntitiesHandler.getFeatureLicenseCount() - OwlinEntitiesHandler.getLinkedEnities();
            //add accounts only to which are allowed upto license count and only those accounts which are just added
            for(Account acc : newAccountMap.values()){
                if(totalEntitiesToRequest > 0  && accountIdsToRequest.size() < totalEntitiesToRequest) accountIdsToRequest.add(acc.Id);
            }
            system.debug('accountIdsToRequest to link  >>'+accountIdsToRequest);
            if(accountIdsToRequest.size() > 0) linkAccountsToOwlin(accountIdsToRequest);
            sentToLink = true;
        }catch (Exception e){
            exceptionMessage = e.getMessage();
            system.debug('exceptionMessage >> in trigger'+exceptionMessage);

        }
        finally {
            //publish event with message or success
        }
        
    }

    /**
    * call queueable and check size to avoid callout exception
    * you cant add more than 50 queueable jobs in a transaction,
    * assumption we will get less than 5000 accounts to track for owlin in one go!
    *
    * @param requestedAccountIds
    */
    @future
    public static void linkAccountsToOwlin(Set<Id> requestedAccountIds){

        if(requestedAccountIds!=null) {
            List<Configuration_Settings__c> owlinConfigList = OwlinEntitiesHandler.getRequestedConfiguration(null);
            Set<ID> accountIdsToQueue = new Set<ID>();
            for(Id accountId : requestedAccountIds) {
                accountIdsToQueue.add(accountId);
                //check for max count. Queue if size is large
                //avoid sending then to queue to avoid callout exception
                if(accountIdsToQueue.size() > 100) {
                    OwlinAccountsLinkQueue queueAccounts = new OwlinAccountsLinkQueue(owlinConfigList[0], accountIdsToQueue);
                    System.enqueueJob(queueAccounts);
                    accountIdsToQueue = new Set<ID>();
                }
            }
            if(accountIdsToQueue.size() > 0) {
                OwlinAccountsLinkQueue queueAccounts = new OwlinAccountsLinkQueue(owlinConfigList[0], accountIdsToQueue);
                System.enqueueJob(queueAccounts);
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