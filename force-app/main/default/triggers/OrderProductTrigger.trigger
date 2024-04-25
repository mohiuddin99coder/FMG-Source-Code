trigger OrderProductTrigger on OrderItem (before insert) {
    Trigger_Switch__c TS = Trigger_Switch__c.getValues('Order Product Trigger');
    if(TS != null && TS.IsActive__c == TRUE){
        if(Trigger.isInsert && Trigger.isBefore){
            system.debug('Order Trigger Inside');
                
            OrderProductHandler.beforeInsertTrigger(Trigger.new);
        }
    }
}