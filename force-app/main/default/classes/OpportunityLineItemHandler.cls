public class OpportunityLineItemHandler {
    public static void checkOppProductsBeforeInsert(List<OpportunityLineItem> OppPrds) {
        Boolean RegularPrd = False;
        Boolean GSKPrd = False;
        Set<String> RelatedProductIds = new Set<String>();
        for(OpportunityLineItem prd : OppPrds) {
            RelatedProductIds.add(prd.Product2Id);
        }
        
        Product2[] RelatedProducts = [SELECT Id, Name, ProductCode, Family FROM Product2 WHERE Id =: RelatedProductIds];
        for(Product2 prd2 : RelatedProducts) {
            if(prd2.Family == Null || prd2.Family == 'Regular') {
                RegularPrd = True;
            } else if (prd2.Family == 'GSK') {
                GSKPrd = True;
            }
        }
        
        for(OpportunityLineItem oppPrd : OppPrds) {
            if(RegularPrd == True && GSKPrd == True && oppPrd.Special_Price_Request__c == True) {
                oppPrd.addError('You can\'t have both products, either GSK Product or Non-GSK Product with Special Price.');
            }
        }
    }
}