public class CreateInvoiceInRSTK {
    
    @invocablemethod(label = 'Update for Invoice In Rstk' Description = 'Invoice update in rootstock' Category = 'Invoice')
    Public static void createSalesOrderInvoice(List<Id> invoiceId){        
        Set<String> orderSummaryIds = new Set<String>();
        Set<String> orderNumbers = new Set<String>();
        Boolean isInvHeader = false;
        Map<string,Decimal> soNumberTaxAmountMap = new Map<string,Decimal>();
        List<Sobject> sObjectList = new List<Sobject>();
        List<Integration_Log__c> logRecordsList = new List<Integration_Log__c>();
        
        if(Test.isRunningTest()){
         System.debug('true');
         sObjectList.add(null);
        }
        
        try
        {
            if(invoiceId != NULL && !invoiceId.isempty()){            
                for(Invoice invoiceRecord :[Select Id,ReferenceEntityId from Invoice where ReferenceEntityId != NULL and ReferenceEntity.Type ='OrderSummary' and Id IN:invoiceId]){
                    orderSummaryIds.add(invoiceRecord.ReferenceEntityId);
                }
                system.debug('orderSummaryIds==>'+orderSummaryIds);
                if(orderSummaryIds != NULL && !orderSummaryIds.isempty()){
                    for(orderSummary os:[select id,OrderNumber,(select id,TotalTaxAmount,FulfilledFromLocation.Name from FulfillmentOrders where FulfilledFromLocation.Name !='Virtual Warehouse' ) from orderSummary where ID IN:orderSummaryIds AND OrderNumber != NULL]){
                        orderNumbers.add(os.OrderNumber);
                        for(FulfillmentOrder fo : os.FulfillmentOrders){
                            /* if(fo.FulfilledFromLocation.Name =='Virtual Warehouse'){                            string orderNum = os.OrderNumber+'- GC';                        soNumberTaxAmountMap.put(orderNum,fo.TotalTaxAmount);                        }
                            else{*/
                                soNumberTaxAmountMap.put(os.OrderNumber,fo.TotalTaxAmount);
                            system.debug('soNumberTaxAmountMap:'+ os.OrderNumber+','+fo.TotalTaxAmount);
                        }
                    }
                    system.debug('soNumberTaxAmountMap==>'+orderNumbers);
                    if(!orderNumbers.isempty() && orderNumbers != NULL){
                        for(rstk__soinv__c soInvHeader :[select id,rstk__soinv_approved__c,rstk__soinv_order__r.rstk__sohdr_order__c,(select id,rstk__soinvline_taxamount__c,rstk__soinvline_taxoverride__c from rstk__Invoice_Line__r LIMIT 1 ) from rstk__soinv__c where rstk__soinv_order__r.rstk__sohdr_order__c  IN : orderNumbers ]){
                            System.debug('soInvHeader-->'+soInvHeader);
                            for(rstk__soinvline__c soInvLine : soInvHeader.rstk__Invoice_Line__r){
                                System.debug('soInvLine--->'+soInvLine);
                                if(soInvHeader.rstk__soinv_order__r.rstk__sohdr_order__c != NULL && !soNumberTaxAmountMap.isempty() && soNumberTaxAmountMap.containskey(soInvHeader.rstk__soinv_order__r.rstk__sohdr_order__c) && soNumberTaxAmountMap.get(soInvHeader.rstk__soinv_order__r.rstk__sohdr_order__c) != NULL){
                                    soInvLine.rstk__soinvline_taxamount__c = soNumberTaxAmountMap.get(soInvHeader.rstk__soinv_order__r.rstk__sohdr_order__c);
                                    soInvLine.rstk__soinvline_taxoverride__c = true;
                                    sObjectList.add(soInvLine);
                                    isInvHeader = true;
                                }
                           /* if(isInvHeader){                            //soInvHeader.rstk__soinv_approved__c = true;                             sObjectList.add(soInvHeader);                        } */                        
                            }                    
                       }
                    }
                }
                System.debug('sObjectList==>'+sObjectList);
                if(!sObjectList.isempty()){
                    update sObjectList;
                }
            }
            //if(!orderSummaryIds.isempty()){     /*   DateTime start = System.Now();            while(System.Now().getTime()< start.getTime()+2000){      }                 RootStockCrateSalesOrderPayments.createPaymentRecord(orderSummaryIds);*/        
            //}//logRecordsList.add(APICallOutLogsCreation.createIntegrationLogRecord(orderSummaryIds,null,Null,ex.getMessage(),'CreateInvoiceInRSTK.createSalesOrderInvoice','Failure',null));      //system.debug('logRecordsList-->' +logRecordsList); 
        }catch(exception ex){
            //string exp ='';
            system.debug('exception line'+ex.getLineNumber());
            system.debug('exception msg'+ex.getMessage());
            system.debug('exception msg'+ex.getStackTraceString());
            string exMsg = ex.getMessage()+''+ex.getLineNumber()+''+ex.getTypeName();
            logRecordsList.add(APICallOutLogsCreation.createIntegrationLogRecord(orderSummaryIds,null,Null,exMsg,'CreateInvoiceInRSTK.createSalesOrderInvoice','Failure',null));            
            system.debug('logRecordsList-->' +logRecordsList);            
        }
        insert logRecordsList;        
    }    
}