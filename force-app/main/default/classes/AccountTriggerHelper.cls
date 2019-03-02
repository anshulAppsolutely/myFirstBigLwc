/**
Created by : Anshul Agrawal
Created Date : 01/03/2019
**/
public class AccountTriggerHelper {
    
    public static boolean skipTrigger = false;
    public static integer counter=0; 
    
    public void OnBeforeInsert(List<Account> accounts) {
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
            //add accounts only which are allowed upto license
            for(Account acc : accounts){
                if(accountIdsToRequest.size() < totalEntitiesToRequest) accountIdsToRequest.add(acc.Id);
                //avoid http callouts limit in a transaction assumption account will not be created so many, if so limit it to send to owlin to avoid governer limit
                if(accountIdsToRequest.size() > 99 ) break;
            }
            linkAccountsToOwlin(accountIdsToRequest);
        }catch (Exception e){
            exceptionMessage = e.getMessage();

        }
        finally {
            //publish event with message or success
        }
         
    }

    @future
    public static void linkAccountsToOwlin(Set<Id> requestedAccountIds){
        List<AsyncApexJob> futureCalls = [
                Select Id, CreatedById, CreatedBy.Name, ApexClassId,MethodName,Status
                FROM AsyncApexJob
                WHERE JobType = 'future' AND ApexClassId IN (SELECT Id
                FROM ApexClass
                WHERE Name = 'AccountTriggerHelper')];
        Map<Id, Account> accountRequestedToLinkMap = new Map<Id, Account>();

        for(Account accToRequest :[Select Id, Name, Website,Owlin_Entity_Id__c,Owlin_Entity_Requested_Id__c
        From Account
        where Id in : requestedAccountIds]){

            accToRequest.Owlin_Entity_Requested_Id__c = futureCalls[0].Id;
            accountRequestedToLinkMap.put(accToRequest.id, accToRequest);
        }
        //make callouts

    }
    
    public void OnAfterInsert(Map<ID, Account> newAccountMap) {
        
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