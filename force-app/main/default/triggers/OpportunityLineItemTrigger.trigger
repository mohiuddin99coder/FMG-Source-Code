trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert) {
Trigger_Switch__c LT =Trigger_Switch__c.getValues('OpportunityLineItemTrigger'); 
    
    if(LT !=NULL && LT.IsActive__c == TRUE){
    if(Trigger.isInsert && Trigger.isBefore) {
        OpportunityLineItemHandler.checkOppProductsBeforeInsert(Trigger.new);
    }
}
}