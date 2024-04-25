public class HandleInvoiceCreation {
    
    @InvocableMethod(label='Create Invoices')
    public static void createInvoice(List<Id> FulfillmentOrderIds) {
        List<Id> InvoiceIds = new List<Id>();
        
        for(FulfillmentOrder FO :[SELECT Id, OrderSummaryId FROM FulfillmentOrder WHERE Id =:FulfillmentOrderIds]) {
            system.debug('Current FulfillmentOrderId: '+ FO.Id);
            createInvoiceAndEnsureFunds(FO.Id,FO.OrderSummaryId);
        }
    }
    
    @Future
    public static void createInvoiceAndEnsureFunds(Id FoID,Id OrderSumId) {
        Id invoiceid = createInvoice(FoID, OrderSumId);
        if (invoiceId != null ){
            ensureFunds(invoiceId,OrderSumId);  
        }
        return;    
    }
    
    
    public static Id createInvoice(Id FoID,Id OrderSumId) {
        Id invoiceID=null;
        Map<Id,Id> ordSumIdInvIdMap = new Map<Id,Id>();
        try {
            ConnectApi.FulfillmentOrderInvoiceInputRepresentation inputRep = 
                new ConnectApi.FulfillmentOrderInvoiceInputRepresentation();
            ConnectAPI.FulfillmentOrderInvoiceOutputRepresentation result = 
                ConnectApi.FulfillmentOrder.createInvoice(FoID, inputRep);
            
            invoiceId=result.invoiceId;
            
        } catch(Exception error) {
            
            system.debug('Error occured while creating Invoice for Fulfillment Order with Id: '+ FoID);
            system.debug('Error: '+ error);
            
            ProcessException pe = new ProcessException();
            pe.AttachedToId = FoID;
            pe.Category = 'Invoicing';
            pe.Status = 'New';
            pe.Priority = 'High';
            pe.Severity = 'High';
            pe.OrderSummaryId = OrderSumId;
            pe.Message = 'Invoice Creation Failed';
            pe.Description = error.getMessage();
            insert pe;
        }
        system.debug('Invoice Id which was created: '+invoiceId);
        return invoiceId;
    }
    
    
    public static void ensureFunds(Id invoiceId, Id ordSumId) {  
        system.debug('OrderSummaryId: '+ordSumId+'; InvoiceId: '+invoiceId);
        
        ConnectApi.EnsureFundsAsyncInputRepresentation ensureFundsAsyncInput = 
            new ConnectApi.EnsureFundsAsyncInputRepresentation();
        ensureFundsAsyncInput.invoiceId = invoiceId;
        
        ConnectApi.EnsureFundsAsyncOutputRepresentation outputRepresentation = 
            ConnectApi.OrderSummary.ensureFundsAsync(ordSumId, ensureFundsAsyncInput);
        Id backGroundId = outputRepresentation.backgroundOperationId;
        system.debug('Background Operation Id: '+BackgroundId);
        //this looks suspicious, check the parameter to the method
        checkBackgroundPaymentProcess(backGroundId,ordSumId);
    }
    
    public static void checkBackgroundPaymentProcess(Id backGroundId , Id ordSumId) {
        
        if(ordSumId!=null) { 
            
            List<BackgroundOperation> BackgroundOperationList;
            BackgroundOperationList = [SELECT Id,Status FROM BackgroundOperation WHERE id=:backGroundId AND Status = 'Error'];
            
            If(!BackgroundOperationList.IsEmpty()){
                system.debug('BackgroundOperationList: '+ BackgroundOperationList);
                
                for(BackgroundOperation BckGOp :BackgroundOperationList) {
                    ProcessException pe = new ProcessException();
                    pe.AttachedToId = ordSumId;
                    pe.Category = 'Payment';
                    pe.Status = 'New';
                    pe.Priority = 'High';
                    pe.Severity = 'High';
                    pe.OrderSummaryId = ordSumId;
                    pe.Message = 'Amount Capture Failed';
                    system.debug('Processexcption: '+ pe);
                    insert pe;
                }
            } //end of if !backgroundOplist
        } // end of if ordsumId != null
    }
    
}