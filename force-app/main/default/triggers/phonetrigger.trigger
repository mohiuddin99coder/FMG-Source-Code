trigger phonetrigger on ContactPointPhone (before insert, before update) {
  Trigger_Switch__c LT =Trigger_Switch__c.getValues('phoneTrigger'); 
    
    if(LT !=NULL && LT.IsActive__c == TRUE){
    if(trigger.isbefore && trigger.isinsert){
        PhoneTriggerHandler.preventCreatePrimaryPhoneOnInsert(trigger.new);
    }
   if(trigger.isbefore && trigger.isupdate){
       PhoneTriggerHandler.preventPrimaryPhoneOnUpdate(trigger.newMap,trigger.oldMap);
   }
}
}