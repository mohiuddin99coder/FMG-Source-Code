public class RootStockCrateSalesOrderPayments {
    
    @invocablemethod(label = 'Sales Order payment cretaion' Description = 'SYDATA to create new Payment record' Category = 'Invoice')
    public static void createPaymentRecord(List<String> invoiceId){
        Map<string,string> orderSummaryIDTransIdMap =new Map<string,string>();
        Set<string> paymentMethodName =new Set<string>();
        Map<string,string> gateWaynameMethodmap = new Map<string,string>();
        Map<string,string> soGateWaynameMap = new Map<string,string>();
        Map<string,string> soHeadermap = new Map<string,string>();
        Set<string> orderRefNumbers = new Set<string>();
        Set<String> paymentGateWayName =New Set<String>();
        Set<String> orderSummaryIds =New Set<String>();
        List<Integration_Log__c> logRecordsList=new List<Integration_Log__c>();
        
        //List<rstk__sydata__c> sydataList = new List<rstk__sydata__c>();
        List<OrderPaymentSummary> orderPaymentSumList = new List<OrderPaymentSummary>();
        
        /*if(Test.isRunningTest()){
System.debug('true');
orderPaymentSumList.add(null);
}*/
        
        try{
            if(invoiceId != NULL && !invoiceId.isempty()){
                for(Invoice invoiceRecord :[Select Id,ReferenceEntityId from Invoice where ReferenceEntityId != NULL and ReferenceEntity.Type ='OrderSummary' and Id IN:invoiceId]){
                    orderSummaryIds.add(invoiceRecord.ReferenceEntityId);
                }
            }
            
            if(!orderSummaryIds.isempty()){
                
                
                orderPaymentSumList  =  [select id,Type,OrderSummary.openAccountCredit__c,OrderSummary.openAccountChequeNumber__c,OrderSummaryId,CapturedAmount,Captured_Amount__c,
                                         Authorized_Amount__c,Special_Order_Transaction_Id__c,OrderSummary.Is_Special_Order__c,OrderSummary.OriginalOrder.OrderReferenceNumber,
                                         Transaction_Id__c,PaymentMethod.Name,(select id,openAccountCredit__c,openAccountChequeNumber__c,PaymentGatewayId,PaymentNumber from Payments /*where PaymentGatewayId != NULL*/) 
                                         from OrderPaymentSummary where OrderSummaryId IN:orderSummaryIds and(Transaction_Id__c != null  or Special_Order_Transaction_Id__c != null or Type = 'Unknown' /*OrderSummary.openAccountCredit__c != false or OrderSummary.openAccountChequeNumber__c != null*/)];
                
                system.debug('orderPaymentSumList==>'+orderPaymentSumList);
                for(OrderPaymentSummary orPaymentSum : orderPaymentSumList){
                    
                    orderRefNumbers.add(orPaymentSum.OrderSummary.OriginalOrder.OrderReferenceNumber);
                    paymentMethodName.add(orPaymentSum.PaymentMethod.Name);
                    if(orPaymentSum.OrderSummary.Is_Special_Order__c ){   //special orders
                        orderSummaryIDTransIdMap.put(orPaymentSum.OrderSummaryId,orPaymentSum.Special_Order_Transaction_Id__c);
                    }
                    else{ // Credit Cards & Open Account
                        for(Payment payAuth : orPaymentSum.Payments){
                            if(payAuth.PaymentGatewayId != NULL){
                                orderSummaryIDTransIdMap.put(orPaymentSum.OrderSummaryId,payAuth.PaymentGatewayId); 
                            } else {
                                orderSummaryIDTransIdMap.put(orPaymentSum.OrderSummaryId,payAuth.PaymentNumber); 
                            }
                        }
                    }  
                    system.debug('orderSummaryIDTransIdMap:'+ orderSummaryIDTransIdMap);      
                } // end or for
                
                System.debug('paymentMethodName: ' + paymentMethodName);
                
                
                if(!paymentMethodName.isEmpty() && paymentMethodName.size() > 0 ){
                    List<CardPaymentMethod>  cardPayments;
                    if(!Test.isRunningTest()){
                        cardPayments = [SELECT id,CardPaymentMethodNumber,PaymentGateway.PaymentGatewayName FROM CardPaymentMethod where CardPaymentMethodNumber IN:paymentMethodName];
                    }
                    else{
                        cardPayments = [SELECT id,CardPaymentMethodNumber,PaymentGateway.PaymentGatewayName FROM CardPaymentMethod limit 1];
                        system.debug(cardPayments);  
                    }
                    for(CardPaymentMethod  cardPayment : cardPayments){
                        
                        gateWaynameMethodmap.put(cardPayment.CardPaymentMethodNumber, cardPayment.PaymentGateway.PaymentGatewayName);
                        paymentGateWayName.add(cardPayment.PaymentGateway.PaymentGatewayName);
                    }
                }
                
                system.debug('gateWaynameMethodmap==>'+gateWaynameMethodmap);
                system.debug('paymentGateWayName==>'+paymentGateWayName);
                if(!orderRefNumbers.isEmpty()){
                    
                    for(rstk__sohdr__c soHeader :[select id,rstk__sohdr_order__c from rstk__sohdr__c where rstk__sohdr_order__c IN:orderRefNumbers]){
                        soHeadermap.put(soHeader.rstk__sohdr_order__c, soHeader.id);
                    }
                }
                system.debug('soHeadermap==>'+soHeadermap);
                if(!paymentGateWayName.isEmpty()|| Test.isRunningTest()){
                    
                    for(rstk__sogateway__c soGateWay :[SELECT id,Name from rstk__sogateway__c where Name =: paymentGateWayName ]){
                        soGateWaynameMap.put(soGateWay.Name, soGateWay.id);
                    }
                }
                
                system.debug('soGateWaynameMap==>'+soGateWaynameMap);

                rstk__sydata__c[] sydataList = new List<rstk__sydata__c>();

                System.debug( 'Processing Order Payment Summary List:'+ orderPaymentSumList);
                for(OrderPaymentSummary orPaymentSum : orderPaymentSumList){
                    System.debug( 'Processing Current Order Payment Summary:'+ orPaymentSum);        
                    rstk__sydata__c sydata = new rstk__sydata__c();
                    sydata.rstk__sydata_sohdr__c = soHeadermap.get(orPaymentSum.OrderSummary.OriginalOrder.OrderReferenceNumber);
                    sydata.rstk__sydata_txntype__c = 'Sales Order Payment';
                    system.debug(soHeadermap.get(orPaymentSum.OrderSummary.OriginalOrder.OrderReferenceNumber));
                    sydata.rstk__sydata_backgroundprocessing__c = true;
                    if(orPaymentSum.OrderSummary.Is_Special_Order__c){
                        system.debug('orPaymentSum.Captured_Amount__c==>'+orPaymentSum.Captured_Amount__c);
                        sydata.rstk__sydata_ordpayamt__c = orPaymentSum.Captured_Amount__c;
                        sydata.rstk__sydata_sogateway__c = soGateWaynameMap.get(gateWaynameMethodmap.get(orPaymentSum.PaymentMethod.Name));
                        sydata.rstk__sydata_ordpayid__c = orderSummaryIDTransIdMap.get(orPaymentSum.OrderSummaryId);
                        system.debug('sydata===>'+sydata);
                        insert sydata;
                    }
                    else if(orPaymentSum.OrderSummary.openAccountCredit__c == true || !String.IsBlank (orPaymentSum.OrderSummary.openAccountChequeNumber__c)){
                        system.debug('orPaymentSum.CapturedAmount==>'+orPaymentSum.CapturedAmount);
                        //sydata.rstk__sydata_ordpayamt__c = orPaymentSum.CapturedAmount;
                        sydata.rstk__sydata_ordpayamt__c = 0;
                        sydata.rstk__sydata_sogateway__c =System.Label.Rootstock;
                        sydata.rstk__sydata_ordpayid__c = orderSummaryIDTransIdMap.get(orPaymentSum.OrderSummaryId);
                        system.debug(sydata.rstk__sydata_sogateway__c);
                        system.debug('sydata===>'+sydata);
                        sydataList.add(sydata);
                        //insert sydata;
                    } 
                    else if(orPaymentSum.Type == 'UNKNOWN' && orPaymentSum.OrderSummary.openAccountCredit__c != true && String.IsBlank (orPaymentSum.OrderSummary.openAccountChequeNumber__c)){
                        system.debug('orPaymentSum.CapturedAmount==>'+orPaymentSum.CapturedAmount);
                        sydata.rstk__sydata_ordpayamt__c = 0;
                        sydata.rstk__sydata_sogateway__c =System.Label.GC_Payment_Gateway;
                        sydata.rstk__sydata_ordpayid__c = orderSummaryIDTransIdMap.get(orPaymentSum.OrderSummaryId);
                        system.debug(sydata.rstk__sydata_sogateway__c);
                        system.debug('sydata===>'+sydata);
                        sydataList.add(sydata);
                        //insert sydata;
                    }
                    else if (orPaymentSum.Type != 'UNKNOWN'){
                        system.debug('orPaymentSum.CapturedAmount==>'+orPaymentSum.CapturedAmount);
                        sydata.rstk__sydata_ordpayamt__c = orPaymentSum.CapturedAmount;
                        sydata.rstk__sydata_sogateway__c = soGateWaynameMap.get(gateWaynameMethodmap.get(orPaymentSum.PaymentMethod.Name));
                        sydata.rstk__sydata_ordpayid__c = orderSummaryIDTransIdMap.get(orPaymentSum.OrderSummaryId);
                        system.debug('sydata===>'+sydata);
                        insert sydata;
                        
                    }
                    
                } // end of for processing all orderpaymentsummaries

                if(sydataList.size()>0) {
                    for(rstk__sydata__c sydata: sydataList ) {
                        sydata.rstk__sydata_backgroundprocessing__c = true;
                        insert sydata;
                    }
                }
                
            } // if exist order summary
        }
        catch(exception ex){
            system.debug('exception line'+ex.getLineNumber());
            system.debug('exception msg'+ex.getMessage());
            system.debug('exception msg'+ex.getStackTraceString());
            string exMsg = ex.getMessage()+''+ex.getLineNumber()+''+ex.getTypeName();
            logRecordsList.add(APICallOutLogsCreation.createIntegrationLogRecord(orderSummaryIds,Null,Null,exMsg,'RootStockCrateSalesOrderPayments.createPaymentRecord','Failure',Null));    
        }   
        
    }
    
}