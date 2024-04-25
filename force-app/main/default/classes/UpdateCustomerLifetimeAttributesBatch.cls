global class UpdateCustomerLifetimeAttributesBatch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'select id,Life_Time_Order_Count__c,Total_Gift_Certificate_Amount__c,Total_Orders_Amount__c from Account';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accountList) {
        updateCustomerLifetimeAttributesHandler.updateCustomerLifetimeAttributes(accountList);
    }
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
}