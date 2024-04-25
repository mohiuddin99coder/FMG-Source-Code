public class CaseProductRelatedListComponent {
    @AuraEnabled
    public static List<Product2> getOrderSummaries(string caseId) {
        String accId='';
        string productsku='';
        List<Product2> orderSummaries;
        If(caseId != NULL && !string.isBlank(caseId)) {
            productsku=[SELECT Product_Sku__c FROM Case WHERE Id = :caseId].Product_Sku__c;
        }
        System.debug('ProductSku:'+productsku);
        If(productsku != NULL && !string.isBlank(productsku)) {
            System.debug('ProductSku:'+productsku);
          orderSummaries = [SELECT Id,Name, StockKeepingUnit,QOH__c FROM Product2 WHERE StockKeepingUnit= :productsku];  
            System.debug('OrderSummary1: '+orderSummaries);
        }   
        System.debug('OrderSummary1: '+orderSummaries);
        return orderSummaries;
    }
    /*
    @auraEnabled
    public static string returnAccountId(string caseId){
        
        string accId='';
        List<OrderSummary> orderSummaries;
        
        If(caseId != NULL && !string.isBlank(caseId)) {
            accId = [SELECT AccountId FROM Case WHERE Id = :caseId].AccountId;
            system.debug('accId :'+accId);
        }
        
        return accId;
    }*/
}