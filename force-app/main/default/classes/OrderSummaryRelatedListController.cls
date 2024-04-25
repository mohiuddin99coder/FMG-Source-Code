public with sharing class OrderSummaryRelatedListController {
    @AuraEnabled
    public static List<OrderSummary> getOrderSummaries(string caseId) {
        String accId='';
        string ordNumber='';
        List<OrderSummary> orderSummaries;
        
        If(caseId != NULL && !string.isBlank(caseId)) {
            accId = [SELECT AccountId FROM Case WHERE Id = :caseId].AccountId;
            ordNumber=[SELECT AccountId,Account_Order_Number__c FROM Case WHERE Id = :caseId].Account_Order_Number__c;
        }
        if(!Test.isRunningTest()){
            If(accId != NULL && !string.isBlank(accId) && string.isBlank(ordNumber)) {
                orderSummaries = [SELECT Id, OrderNumber,AccountId,OrderedDate,Status,TotalAmount FROM OrderSummary WHERE AccountId = :accId Order By OrderedDate DESC];  
                System.debug('OrderSummary1: '+orderSummaries);
            }else{
                orderSummaries = [SELECT Id, OrderNumber,AccountId,OrderedDate,Status,TotalAmount FROM OrderSummary WHERE AccountId = :accId and  OrderNumber like :'%'+ordNumber+'%' Order By OrderedDate DESC];  
                System.debug('OrderSummary2: '+orderSummaries);
            }
            
            return orderSummaries;
        }
        else {
            return NULL;
        }
        
    }
    
    @auraEnabled
    public static string returnAccountId(string caseId){
        
        string accId='';
        List<OrderSummary> orderSummaries;
        
        If(caseId != NULL && !string.isBlank(caseId)) {
            accId = [SELECT AccountId FROM Case WHERE Id = :caseId].AccountId;
            system.debug('accId :'+accId);
        }
        
        return accId;
    }
}