trigger AccountTrigger on Account (after insert) {
    
    system.debug('@@## Account trigger '+trigger.OldMap);
    system.debug('@@## Account trigger '+trigger.NewMap);
    
    AccountTriggerHelper handler = new AccountTriggerHelper();

    if(AccountTriggerHelper.skipTrigger == false) {

        if(Trigger.isInsert && Trigger.isAfter) {
            handler.OnAfterInsert(Trigger.newMap);
        }
    }

}