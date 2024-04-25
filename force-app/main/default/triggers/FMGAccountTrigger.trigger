trigger FMGAccountTrigger on Account (before update) {
    Trigger_Switch__c LT =Trigger_Switch__c.getValues('FMGAccountTrigger'); 
    
    if(LT !=NULL && LT.IsActive__c == TRUE){
    if(Trigger.isUpdate && Trigger.isBefore){
        system.debug('Inside Trigger Account');
        FMGAccountHandler.accountBeforeUpdate(Trigger.new, Trigger.old,Trigger.newMap, Trigger.oldMap);
    }}}