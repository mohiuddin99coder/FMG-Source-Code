/**
* @author Abraham David Lloyd
* @date April 11th, 2021
*
* @description This trigger is used to create Platform Events that trigger an
* update of the PersonAccount with a details of a mapped B2C Commerce Customer Profile.
*/
trigger B2CProcessPersonAccount on Account (before update,after update,after insert,before insert) {
    
    //If the trigger switch is enabled do not do anything
    Trigger_Switch__c LT =Trigger_Switch__c.getValues('FMGAccountTrigger');
    if( LT !=NULL && LT.IsActive__c == FALSE){
        return ;
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
        system.debug('Inside Trigger Account');
        FMGAccountHandler.updatePlatinumFieldUpdate(Trigger.new, Trigger.old,Trigger.newMap, Trigger.oldMap);
    }
    
    
    // Only process and evaluate updates to PersonAccounts when the trigger is enabled
    // Do not process this trigger if the AccountContactModel is configured for Accounts / Contacts
    if (Trigger.isBefore && Trigger.isUpdate && B2CConfigurationManager.isB2CProcessContactTriggerEnabled() == true &&
        B2CConfigurationManager.getDefaultAccountContactModel() == B2CConstant.ACCOUNTCONTACTMODEL_PERSON) {
            System.debug('inside before update B2CProcessPersonAccount**');
            // Process the trigger and handle the personAccount updates
            // FMGAccountHandler.updatePlatinumFieldUpdate(Trigger.new, Trigger.old,Trigger.newMap, Trigger.oldMap);
            B2CProcessPersonAccountHelper.processTrigger(Trigger.new, Trigger.old);
            
        }
    
    
    
    if(Trigger.isBefore && Trigger.isInsert){
        System.debug('account before trigger list is : '+trigger.new);
        B2CPersonAccountTriggerHelper.updateCustomerList(trigger.new);
    }
    
    if(Trigger.isAfter && Trigger.isInsert){
        System.debug('in after.. insert Trigger');
        if(!Test.isRunningTest() && !system.isBatch()){
            B2CPersonAccountTriggerHelper.callQueueableClass(Trigger.new);
        }
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        B2CPersonAccountTriggerHelper.updateRelatedCustomerAddresses(Trigger.new,Trigger.old);
        FMGAccountHandler.createTasks(Trigger.new, Trigger.old,Trigger.newMap, Trigger.oldMap);
    }
}