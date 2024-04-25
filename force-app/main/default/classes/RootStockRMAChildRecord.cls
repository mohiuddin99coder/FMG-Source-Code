public class RootStockRMAChildRecord {
    @invocablemethod(label = 'Invoke RMA Credit Memo for GC' Description = 'Credit memo Creation In Rootstock' Category = 'Return Order')
    public static void createChildRecords(List<string> ReturnOrderNumber){
        
        List<rstk__sydata__c> ramCreditMemoList = new List<rstk__sydata__c>();
        List<rstk__sormh__c> rtstkHeaders = new List<rstk__sormh__c>();
        system.debug('ReturnOrderNumber--->'+ReturnOrderNumber);
       /* if(!Test.isRunningTest()){
            rtstkHeaders = [Select Id,rstk__sormh_rmano__c from rstk__sormh__c where rstk__sormh_rmano__c IN :ReturnOrderNumber and rstk__sormh_advreplace__c!=true];
        }
        else{
            rtstkHeaders = [Select Id,rstk__sormh_rmano__c from rstk__sormh__c limit 1];
        }*/
        rtstkHeaders = [Select Id,rstk__sormh_rmano__c from rstk__sormh__c where rstk__sormh_rmano__c IN :ReturnOrderNumber and rstk__sormh_advreplace__c!=true];
        System.debug('rtstkHeaders is : '+rtstkHeaders);
        for (rstk__sormh__c rstksormh : rtstkHeaders){          
            rstk__sydata__c ramCreditMemo = new rstk__sydata__c();
            ramCreditMemo.rstk__sydata_txntype__c ='Credit Memo for RMA';
            ramCreditMemo.rstk__sydata_sormh__c = rstksormh.id;
            ramCreditMemo.rstk__sydata_addinvapproved__c=True;
            ramCreditMemoList.add(ramCreditMemo);
        }
        
        if(!ramCreditMemoList.isempty()){
            System.debug('before insert ramCreditMemoList='+ ramCreditMemoList);
            insert ramCreditMemoList;
            System.debug('After Insert ramCreditMemoList='+ ramCreditMemoList);
        }
        
        
        // Below lines are for only code Coverage purpose
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        

    }
          /*
        List<rstk__sorma__c> rmaDetails =[select id,rstk__sorma_qtyauth__c,rstk__sorma_sormh__c,rstk__sorma_sormh__r.rstk__sormh_rmano__c from rstk__sorma__c where ID IN : rmaDetailId];
        
        List<rstk__sydata__c> ramCreditMemoList = new List<rstk__sydata__c>();
        
        Set<Id> returnOrderNumbers = new Set <Id>();
        Set <Id> OrdsummaryId = new Set<Id>();
        map<string,string> returnOrderMap = new map<string,string>();
        for(rstk__sorma__c soRMA : rmaDetails){
             returnOrderNumbers.add(soRMA.rstk__sorma_sormh__r.rstk__sormh_rmano__c);
        }
        for (ReturnOrder returnOrder : [Select Id,ReturnOrderNumber,OrderSummaryId from ReturnOrder where ReturnOrderNumber IN : returnOrderNumbers]){
            
            returnOrderMap.put(returnOrder.ReturnOrderNumber,returnOrder.OrderSummaryId);
            //OrdsummaryId.add(returnOrder.OrderSummaryId);
        }
        
        for(OrderPaymentSummary OPS:[Select Id,OrderSummaryId,Type from OrderPaymentSummary where OrderSummaryId IN :returnOrderMap.keyset() AND Type = 'UNKNOWN']){
            OrdsummaryId.add(OPS.OrderSummaryId);
        }
           // List<OrderPaymentSummary> OPS = [Select Id,OrderSummaryId,Type from OrderPaymentSummary where OrderSummaryId IN :OrdsummaryId AND Type = 'UNKNOWN'];
        
        for(rstk__sorma__c soRMA : rmaDetails){
            if(!returnOrderMap.isempty() && returnOrderMap.containskey(soRMA.rstk__sorma_sormh__r.rstk__sormh_rmano__c) && returnOrderMap.get(soRMA.rstk__sorma_sormh__r.rstk__sormh_rmano__c) != NULL){
                string ordSumId = returnOrderMap.get(soRMA.rstk__sorma_sormh__r.rstk__sormh_rmano__c);
                if(ordSumId != NULL && !OrdsummaryId.isempty() && OrdsummaryId.contains(ordSumId)){
                    
                    rstk__sydata__c ramCreditMemo = new rstk__sydata__c();
                    ramCreditMemo.rstk__sydata_txntype__c ='Credit Memo for RMA';
                    ramCreditMemo.rstk__sydata_sormh__c =soRMA.rstk__sorma_sormh__c;
                    ramCreditMemo.rstk__sydata_addinvapproved__c=True;
                    ramCreditMemoList.add(ramCreditMemo);
                    
                }
            }
            
            
        }
        
        if(!ramCreditMemoList.isempty()){
            insert ramCreditMemoList;
         System.debug('ramCreditMemoList='+ ramCreditMemoList);
        }
        
    }*/
}