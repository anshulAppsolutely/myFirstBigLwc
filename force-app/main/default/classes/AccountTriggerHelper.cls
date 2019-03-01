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

}