trigger CustomerAddressTrigger on Customer_Address__c (before insert,after insert,after update) {
    if(Trigger.isBefore){
        List<ID> accIdList = new List<ID>();
        if(Trigger.isInsert){
            for(Customer_Address__c customerAddress:Trigger.new){
                accIdList.add(customerAddress.ParentId__c);
            }
            
            CustomerAddressTriggerHandler.checkDuplicateAddress(Trigger.new,accIdList);
            
        }
    }
    
    if(Trigger.isAfter){
        List<ID> accIdList = new List<ID>();
        List<Customer_Address__c> updateCustomerAddressList = new List<Customer_Address__c>();
        for(Customer_Address__c customerAddress:Trigger.new){
            accIdList.add(customerAddress.ParentId__c);
            System.debug('customerAddress is : '+customerAddress);
            if(customerAddress.LastModifiedById!=Label.FMG_Integration_User_Id){
                updateCustomerAddressList.add(customerAddress);
            }
        }
        System.debug('accIdList is : '+accIdList);
        if(Trigger.isInsert){
            System.enqueueJob(new CreateCustomerAddressQueue(Trigger.new,accIdList));
        }
        if(Trigger.isUpdate){
            System.enqueueJob(new updateCustomerAddressQueue(updateCustomerAddressList,accIdList));
        }
    }
}