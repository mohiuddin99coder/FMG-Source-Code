public class RootstockSalesOrderPrepayment {
    
    @invocablemethod(label = 'Sales Order prepayment' Description = 'SYDATA to apply the sales order prepayment' Category = 'Sales Order Payment')
    
    public static void SalesOrderPrepayment(List<String> SalesOrderHeaders){
        List<Integration_Log__c> logRecordsList=new List<Integration_Log__c>();
        List<rstk__sydata__c> sydataList = new List<rstk__sydata__c>();
        List <rstk__soinv__c> soInvoice = new List <rstk__soinv__c>();
        Set<String> salesOrderHeadersSet = new Set<String>(SalesOrderHeaders);
        try {
            for(rstk__soinv__c soInv :[select id,rstk__soinv_approved__c,rstk__soinv_order__r.rstk__sohdr_order__c from rstk__soinv__c where rstk__soinv_order__r.rstk__sohdr_order__c  IN : SalesOrderHeaders and rstk__soinv_approved__c != true]){
                system.debug('Sales Order Invoice' + soInv);
 
                rstk__sydata__c sydata = new rstk__sydata__c();
                sydata.rstk__sydata_txntype__c ='Apply Prepayments to Sales Invoice';
                sydata.rstk__sydata_backgroundprocessing__c = true;
                sydata.rstk__sydata_soinv__c = soInv.Id;
                sydata.rstk__sydata_addinvapproved__c = true;
                sydataList.add(sydata);
                system.debug('SYDATA' + sydataList);
                
            }
            if(!sydataList.isempty()) {
                insert sydataList; 
                system.debug('sydataList===>'+sydataList[0]);
            }
            
        }
        catch(exception ex){
            system.debug('exception line'+ex.getLineNumber());
            system.debug('exception msg'+ex.getMessage());
            system.debug('exception msg'+ex.getStackTraceString());
            string exMsg = ex.getMessage()+''+ex.getLineNumber()+''+ex.getTypeName();
            logRecordsList.add(APICallOutLogsCreation.createIntegrationLogRecord(salesOrderHeadersSet,Null,Null,exMsg,'RootstockSalesOrderPrepayment.SalesOrderPrepayment','Failure',Null)); 
            
            
            /*string exMsg = ex.getMessage();
            Integer exNum = ex.getLineNumber();
            system.debug('ex ms==>'+exMsg);
            system.debug('ex num==>'+exNum);*/
            
        }
    }
}