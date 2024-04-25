/* BraintreeCaptureErrorClass_Test : Test class for covering 'BraintreeCaptureErrorClass' */
@IsTest
public class BraintreeCaptureErrorClass_Test {
    @IsTest(SeeAllData=true)
    public static void BTCErrorClass(){
        Account testAccount = new Account(
            LastName = 'Test Account09081',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            BillingCity = 'Trumbull',
            BillingCountry = 'United States',
            BillingPostalCode = '06611',
            BillingState = 'connecticut',
            BillingStreet = '5 Dayton Cir',
            PersonEmail='Bhanuprakashreddy1230908@gmail.com'
        );
        insert testAccount;
        System.debug('Accc Id ---- > '+ testAccount.Id);
        
        /* get pricebook */
        Id pricebookId = Test.getStandardPricebookId();
        System.debug('pricebookId ---- > '+ pricebookId);
        
        Product2 product1 = new Product2(Name = 'Product 1',StockKeepingUnit = 'SKU1111',Description = 'Test Product 1', IsActive = true );
        insert product1;
        System.debug('Product2 ---- > '+ product1.Id);
        
        /* Pricebook entry */
        PricebookEntry pbEntry1 = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = product1.Id,UnitPrice = 100,IsActive = true);
        insert pbEntry1;
        System.debug('PricebookEntry ---- > '+ pbEntry1.Id);

        Order order1 = new Order(AccountId = testAccount.Id , Status = 'Draft',EffectiveDate = Date.today(),Pricebook2Id =pbEntry1.Pricebook2Id ,orderedDate = Date.today(),OrderReferenceNumber='1234');
        insert order1;
        System.debug('Order ---- > '+ order1.Id);
        // Create OrderDeliveryMethod
        OrderDeliveryMethod orderDeliveryMethod1 = new OrderDeliveryMethod(
            Name = 'OrderDeliveryMethod 1',
            ProductId = product1.Id
        );
        insert orderDeliveryMethod1;
        System.debug('OrderDeliveryMethod ---- > '+ orderDeliveryMethod1.Id);
        //insert order delivery group
        OrderDeliveryGroup orderDeliveryGroup1 = new OrderDeliveryGroup(
            DeliverToName = 'orderDeliveryGroup Name 1',
            OrderDeliveryMethodId = orderDeliveryMethod1.Id,
            OrderId = order1.Id,
            Description = 'CartDeliveryGroup.Description',
            DesiredDeliveryDate = Date.today(),
            DeliverToStreet = 'test Street',
            DeliverToCity= 'Flower Mound',
            DeliverToState = 'Texas',
            DeliverToPostalCode ='75028',
            DeliverToCountry ='United States'
        );
        insert orderDeliveryGroup1;
        System.debug('orderDeliveryGroup---- > '+ orderDeliveryGroup1.Id);
        //insert Order line items
        
        OrderItem orderItem1 = new OrderItem(
            PricebookEntryId = pbEntry1.Id,
            Product2Id = product1.Id,
            OrderId = order1.Id,
            Quantity = 5,
            Type = 'Order Product',
            UnitPrice = 100,
            ListPrice = 100,
            OrderDeliveryGroupId = orderDeliveryGroup1.Id,
            TotalLineAmount = 500
        );
        insert orderItem1;
        System.debug('Order item product Id-----> ' + orderItem1.Product2Id );
        
        
        // update order status to Active
        order1.Status = 'Activated';
        update order1; 
        System.debug('updateOrderId-----> ' + order1.Id );
        // Mock OrderSummary creation
        ConnectApi.OrderSummaryInputRepresentation inputRepresentation = new ConnectApi.OrderSummaryInputRepresentation();
        inputRepresentation.orderId = order1.Id;
        //inputRepresentation.orderLifeCycleType='UNMANAGED';
        ConnectApi.OrderSummaryOutputRepresentation outputRepresentation = ConnectApi.OrderSummaryCreation.createOrderSummary(inputRepresentation);
        System.debug('orderSummaryCreation---->'+outputRepresentation);
        
        // OrderPaymentSummary creation
        OrderPaymentSummary orderPaymentSummary = new OrderPaymentSummary();
        orderPaymentSummary.OrderSummaryId = outputRepresentation.orderSummaryId; 
        orderPaymentSummary.Method = 'Visa-1111'; 
        orderPaymentSummary.Type  = 'VISA'; 
        insert orderPaymentSummary;
        System.debug('OrderPaymentSummary-->'+orderPaymentSummary);
        
        
        // PaymentAuthorization creation
        PaymentAuthorization paymentAuthorization = new PaymentAuthorization();
        paymentAuthorization.OrderPaymentSummaryId = orderPaymentSummary.Id;
        paymentAuthorization.Amount = 500.0; 
        paymentAuthorization.Status='Processed';
        paymentAuthorization.ProcessingMode='External';
        paymentAuthorization.GatewayRefNumber = 'abcdtqwe';
        insert paymentAuthorization;
        System.debug('PaymentAuthorization-->'+paymentAuthorization);
        // Prepare the orderSumIdOrderItemsmap to simulate different scenarios
        Map<String, String> orderSumIdOrderItemsmap = new Map<String, String>();
        orderSumIdOrderItemsmap.put(outputRepresentation.orderSummaryId, 'FMG Warehouse');
        
        //Query inserted Order Summary
        OrderSummary orderSum=[SELECT Id, OriginalOrderId, Status, OrderNumber,OwnerId FROM OrderSummary WHERE Id =:outputRepresentation.orderSummaryId];
        order1.OrderReferenceNumber =orderSum.OrderNumber ;
        update order1;
        System.debug('Order----->'+order1 + 'Id---->'+order1.Id + 'orderSum----->'+orderSum);
        System.debug('OrderNumber----->'+orderSum.OrderNumber);
        
        String orderSummaryId = outputRepresentation.orderSummaryId;
        String fulfillmentType = 'warehouse';
        
        // String warehouseFromLocationId = [SELECT Id from Location WHERE LocationType='Warehouse' LIMIT 1].Id;
        Schema.Location LC = new Schema.Location(); 
        LC.Name = 'FMG Warehouse'; 
        LC.LocationType ='Warehouse'; 
        LC.IsInventoryLocation = True; 
        insert LC;
        System.debug('Location-->'+ LC);
        
        ConnectApi.FulfillmentOrderInputRepresentation fulfillmentOrderInput = new ConnectApi.FulfillmentOrderInputRepresentation();
        fulfillmentOrderInput.orderSummaryId = orderSummaryId;
        
        
        List<OrderDeliveryGroupSummary> orderDeliveryGroupSummaryList = [SELECT Id FROM OrderDeliveryGroupSummary WHERE OrderSummaryId =: orderSummaryId];
        
        for (OrderDeliveryGroupSummary orderDeliveryGroupSummary: orderDeliveryGroupSummaryList){
            
            fulfillmentOrderInput.orderDeliveryGroupSummaryId = orderDeliveryGroupSummary.Id;
            List<ConnectApi.FulfillmentGroupInputRepresentation> fulfillmentGroups = new List<ConnectApi.FulfillmentGroupInputRepresentation>();
            ConnectApi.FulfillmentGroupInputRepresentation fulfillmentGroup = new ConnectApi.FulfillmentGroupInputRepresentation();
            fulfillmentGroup.fulfilledFromLocationId = LC.Id;
            fulfillmentGroup.fulfillmentType = fulfillmentType;
            
            List<ConnectApi.OrderItemSummaryInputRepresentation> orderItemSummaries = new List<ConnectApi.OrderItemSummaryInputRepresentation>();
            
            List<OrderItemSummary> orderItemSummaryList = [Select Id, quantity FROM OrderItemSummary WHERE OrderSummaryId =: orderSummaryId AND OrderDeliveryGroupSummaryId =: orderDeliveryGroupSummary.Id];
            for(OrderItemSummary orderItemSummary : orderItemSummaryList){
                ConnectApi.OrderItemSummaryInputRepresentation oisInputRepresentation = new ConnectApi.OrderItemSummaryInputRepresentation();
                oisInputRepresentation.orderItemSummaryId = orderItemSummary.Id;
                oisInputRepresentation.quantity = orderItemSummary.quantity;
                orderItemSummaries.add(oisInputRepresentation);
            }
            
            fulfillmentGroup.orderItemSummaries = orderItemSummaries;
            fulfillmentGroups.add(fulfillmentGroup);      
            fulfillmentOrderInput.fulfillmentGroups = fulfillmentGroups;
            
        }
        
        ConnectApi.FulfillmentOrderOutputRepresentation result = ConnectAPI.FulfillmentOrder.createFulfillmentOrders(fulfillmentOrderInput);
        System.debug('RRRR----->' + result);
        
        //Query fulfillment order
        FulfillmentOrder fulfillmentOrder1 = new FulfillmentOrder();
        fulfillmentOrder1 = [select Id ,DeliveryMethodId,OrderSummaryId ,TotalTaxAmount ,FulfilledToPhone,Status,FulfilledToName,FulfilledToCity,FulfilledToCountry,FulfilledToEmailAddress,FulfilledToPostalCode,FulfilledToState,FulfilledToStreet,AccountId from fulfillmentOrder where Id=:result.fulfillmentOrderIds];
        System.debug('fulfillment order---->' + fulfillmentOrder1);  
        
        //Query FulfillmentOrderLineItem
        List<FulfillmentOrderLineItem> fO_lineItem = [select Id,Quantity,UnitPrice,Product2Id,TotalLineTaxAmount,OrderItemId,OrderItemSummaryId from FulfillmentOrderLineItem where FulfillmentOrderId = :fulfillmentOrder1.Id];
        System.debug('fulfillment product---->' + fO_lineItem);
        
        List<Id> fulfillmentOrderIds = new List<Id>();
        fulfillmentOrderIds.add(fulfillmentOrder1.Id);
        System.debug('fulfillmentOrders'+fulfillmentOrderIds);
        
        fulfillmentOrder1.Status='Fulfilled';
        Update fulfillmentOrder1;
        System.debug('After status Update to fulfillmentOrder1'+fulfillmentOrder1);
        orderSum.Status = 'Fulfilled';
        Update orderSum;
        System.debug('Order Summary Status: '+ orderSum);
        order1.Status = 'Fulfilled';
        update order1;
        System.debug('OrginalOrder Status: '+ order1);
        
        
        ConnectApi.FulfillmentOrderInvoiceInputRepresentation input = new ConnectApi.FulfillmentOrderInvoiceInputRepresentation();
        ConnectAPI.FulfillmentOrderInvoiceOutputRepresentation result1 = ConnectApi.FulfillmentOrder.createInvoice(fulfillmentOrder1.Id, input);
        System.debug('FulfillmentOrderInvoiceOutputRepresentation'+result1);
        
        
        ConnectApi.EnsureFundsAsyncInputRepresentation inputEFAIR = new ConnectApi.EnsureFundsAsyncInputRepresentation();
        inputEFAIR.invoiceId =result1.invoiceId;
        
        ConnectApi.EnsureFundsAsyncOutputRepresentation output = ConnectApi.OrderSummary.ensureFundsAsync(orderSummaryId,inputEFAIR);
        System.debug('EnsureFundsAsyncOutputRepresentation'+output);
        
        Id BackgroundId = output.backgroundOperationId;
        List<Id> ListBGIds = new List<Id>();
        ListBGIds.add(BackgroundId);
        System.debug('BackgroundId--->'+BackgroundId);
        System.debug('fulfillmentOrder1.Id--->'+fulfillmentOrder1.Id);
            
        
        BraintreeCaptureErrorClass.createListInputs argument = new BraintreeCaptureErrorClass.createListInputs();
        System.debug('argument.FOIds[0]--->'+argument.FOIds);
        System.debug('argument.BGIds[0]--->'+argument.BGIds);
        /*List<BackgroundOperation> BackgroundOperationList = [SELECT Id,Status FROM BackgroundOperation WHERE Id IN: ListBGIds AND Status = 'Error'];
        List<Id> ListBGId = new List<Id>();
        ListBGId.add(BackgroundOperationList[0].id);*/
        argument.FOIds = fulfillmentOrderIds;
        argument.BGIds = ListBGIds;
        
        
        // Fake Http Request
        Map<String,String> Headers = new Map<String, String>();
        Headers.put('Content-Type', 'application/json');
        String tokenizeBody = '{"orderSummaryId": "mock_order_summary_id"}';
        SingleRequestMock fakeRequest = new SingleRequestMock(200,tokenizeBody,Headers);
        
        
        // Data for Schedule_BraintreeCaptureErrors
        Map<Id,Id> FOandBGIdsMap = new Map<Id,Id>();
        FOandBGIdsMap.put(BackgroundId,fulfillmentOrderIds[0]);
        
        test.starttest();
        Test.setMock(HttpCalloutMock.class, fakeRequest);
        BraintreeCaptureErrorClass.braintreeCaptureError(
            new List<BraintreeCaptureErrorClass.createListInputs>{ argument }
        );
        String jobId = System.schedule('Test Schedule', '0 0 0 * * ?', new Schedule_BraintreeCaptureErrors(FOandBGIdsMap));
        Test.stopTest();
    }
    
    
}