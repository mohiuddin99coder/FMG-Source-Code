public class SalesOrderInvocieLine {
    @invocableMethod(label = 'Sales Order Invoice Line' Description = 'SO Invoice Line Qty Check' Category = ' SO Invoice Header')

    public static void soInvoiceLineQtyCheck(List<Id> soInvHeader){
        List<rstk__soinv__c> soInvoiceHeader = new List<rstk__soinv__c>();
          Map<String,Decimal> soInvSKUandQty = new Map<String,Decimal>();
        Set <String> Ordernumbers = new Set<String>();
        List<FulfillmentOrderLineItem> foLineList = new List<FulfillmentOrderLineItem>();
         for(rstk__soinv__c soInvoice :[Select Id,rstk__soinv_order__r.rstk__sohdr_order__c,
                                        (Select Id,rstk__soinvline_qty__c,rstk__soinvline_prod__c,rstk__soinvline_prod__r.rstk__soprod_prod__c from  rstk__Invoice_Line__r) from rstk__soinv__c where Id IN :soInvHeader]){
                 Ordernumbers.add(soInvoice.rstk__soinv_order__r.rstk__sohdr_order__c);
                 for(rstk__soinvline__c soInvline : soInvoice.rstk__Invoice_Line__r){
                     if(soInvSKUandQty.isempty() || (!soInvSKUandQty.isempty() && !soInvSKUandQty.containskey(soInvline.rstk__soinvline_prod__r.rstk__soprod_prod__c)) ){
                     soInvSKUandQty.put(soInvline.rstk__soinvline_prod__r.rstk__soprod_prod__c, soInvline.rstk__soinvline_qty__c);
                     }
                     else if(!soInvSKUandQty.isempty() && soInvSKUandQty.containskey(soInvline.rstk__soinvline_prod__r.rstk__soprod_prod__c)){
                         //newly added logic for same product shifted multiple times.
                         soInvSKUandQty.put(soInvline.rstk__soinvline_prod__r.rstk__soprod_prod__c, soInvSKUandQty.get(soInvline.rstk__soinvline_prod__r.rstk__soprod_prod__c)+soInvline.rstk__soinvline_qty__c);
                         
                     }
                 }
                 
                                        }
        system.debug('soInvSKUandQty' + soInvSKUandQty);
        
                 List<FulfillmentOrder> fulfillmentOrderLst = [Select Id,Status,FulfillmentOrderNumber,AccountId,Account.Name,OrderSummaryId,
                                                                OrderSummary.OriginalOrder.OrderReferenceNumber, 
                                                                  (Select Id,OrderItem.Product2.Family,Type,FulfillmentOrderId,Quantity,OrderItem.Product2.StockKeepingUnit,OrderItemId,OrderItem.Product2Id,
                                                                     OrderItem.Product2.ProductCode,OriginalQuantity,TypeCode,UnitPrice from FulfillmentOrderLineItems where FulfillmentOrder.OrderSummary.OriginalOrder.OrderReferenceNumber IN : Ordernumbers) 
                                                                     from FulfillmentOrder where OrderSummary.OriginalOrder.OrderReferenceNumber IN :Ordernumbers];
                 if(!fulfillmentOrderLst.IsEmpty()){
                 for(FulfillmentOrder foOrder : fulfillmentOrderLst){
                     for(FulfillmentOrderLineItem foLineItem :foOrder.FulfillmentOrderLineItems){
                         system.debug('SKU'+foLineItem.OrderItem.Product2.StockKeepingUnit);
                             
                         if(!soInvSKUandQty.isempty() && soInvSKUandQty.containskey(foLineItem.OrderItem.Product2.StockKeepingUnit)){
                             system.debug('INSIDE IF'+soInvSKUandQty.get(foLineItem.OrderItem.Product2.StockKeepingUnit));
                           // foLineItem.Quantity = soInvSKUandQty.containskey(foLineItem.OrderItem.Product2.StockKeepingUnit) && soInvSKUandQty.get(foLineItem.Quantity);
                           foLineItem.Quantity =  soInvSKUandQty.get(foLineItem.OrderItem.Product2.StockKeepingUnit);
                             foLineList.add(foLineItem);
                         }
                         else if(foLineItem.OrderItem.Product2.Family!='Shipping')
                         {
                             foLineItem.Quantity=0;
                             foLineList.add(foLineItem);
                         }
                     }   
                 
                 }
                     
                     if(!foLineList.isempty()){
                        update foLineList; 
                     }
             }        
    
    }     
}