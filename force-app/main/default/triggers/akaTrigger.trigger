trigger akaTrigger on AKA__c (before insert,before update) {
Trigger_Switch__c LT =Trigger_Switch__c.getValues('akaTrigger'); 
    
    if(LT.IsActive__c == TRUE){
    if(trigger.isbefore && trigger.isinsert){
        akaHandler.preventCreatePrimaryAKAOnInsert(trigger.new);
    }
    if(trigger.isbefore && trigger.isupdate){
        akaHandler.preventPrimaryAkaOnUpdate(trigger.newMap, trigger.oldMap);
    }
}
}