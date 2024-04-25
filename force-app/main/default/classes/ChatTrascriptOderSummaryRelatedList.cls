public class ChatTrascriptOderSummaryRelatedList {
    @AuraEnabled
    public static List<OrderSummary> getOrderSummaries(string chatId) {
        String accId='';
        String conId='';
        string casId='';
        string ordNumber='';
        List<OrderSummary> orderSummaries;
        
        If(chatId != NULL && !string.isBlank(chatId)) {
            //conId = [SELECT AccountId, ContactId FROM LiveChatTranscript WHERE Id = :chatId].contactId;
            //accId = [SELECT AccountId FROM contact WHERE Id = :conId].AccountId;
            accId = [SELECT AccountId FROM LiveChatTranscript WHERE Id = :chatId].AccountId;
            casId = [SELECT CaseId FROM LiveChatTranscript WHERE Id = :chatId].CaseId;
            ordNumber=[SELECT AccountId,Account_Order_Number__c FROM Case WHERE Id = :casId].Account_Order_Number__c;
        
        }
        System.debug('OrdNumber: '+ordNumber);
        If(accId != NULL && !string.isBlank(accId) && string.isBlank(ordNumber)) {
          orderSummaries = [SELECT Id, OrderNumber,AccountId,OrderedDate,Status,TotalAmount FROM OrderSummary WHERE AccountId = :accId Order By OrderedDate DESC];  
          system.debug('Order summeries:'+orderSummaries);
        }else{
            orderSummaries = [SELECT Id, OrderNumber,AccountId,OrderedDate,Status,TotalAmount FROM OrderSummary WHERE AccountId = :accId and OrderNumber like :'%'+ordNumber+'%' Order By OrderedDate DESC];
            system.debug('Order summeries:'+orderSummaries);
        }
        
        return orderSummaries;
    }
    
    @auraEnabled
    public static string returnAccountId(string chatId){
        
        string accId='';
        List<OrderSummary> orderSummaries;
        
        If(chatId != NULL && !string.isBlank(chatId)) {
            accId = [SELECT AccountId FROM LiveChatTranscript WHERE Id = :chatId].AccountId;
            system.debug('accId :'+accId);
        }
        
        return accId;
    }
}