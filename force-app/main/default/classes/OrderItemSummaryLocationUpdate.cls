public class OrderItemSummaryLocationUpdate {
    @InvocableMethod(label='Fulfilment Location Update In OIS' description='Order Item Summary Location Update' category='OrderSummary')
    public static void locationUpdate(List<Id> OdrSummaryIds){
        List<OrderItemSummary> ListOIS = [SELECT Id, Product2Id, Name,StockKeepingUnit, Quantity,Type, Fulfillment_Location__c, OrderSummary.AccountId,OrderSummary.Account.Shippinglatitude,OrderSummary.Account.Shippinglongitude FROM OrderItemSummary Where OrderSummaryId IN: OdrSummaryIds and Type != 'Delivery Charge'];
        List<OrderItemSummary> UpdateList = new list<OrderItemSummary>();
        Map<String,String> orderSumIdOrderItemsmap = new Map<String,String>();
        system.debug('OdrSummaryIds==>'+OdrSummaryIds);
        for(OrderItemSummary OIS : ListOIS){
            if(OIS.StockKeepingUnit == 'eGiftCertificate' && OIS.Type == 'Order Product'){
                OIS.Fulfillment_Location__c = 'Virtual Warehouse';
                UpdateList.add(OIS);
                system.debug('OIS.StockKeepingUnit' + UpdateList);
            }
           
            
            else if (OIS.StockKeepingUnit != 'eGiftCertificate' && OIS.Type == 'Order Product'){
                OIS.Fulfillment_Location__c = 'FMG Warehouse';
                UpdateList.add(OIS);
                 system.debug('OIS.Fulfillment_Location__c==>'+OIS.Fulfillment_Location__c);
            }
        }
        system.debug('orderSumIdOrderItemsmap==>'+orderSumIdOrderItemsmap);
        
        Update UpdateList;
    }
}