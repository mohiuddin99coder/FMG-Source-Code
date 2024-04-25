@isTest
public class HandleInvoiceCreationTest {

    @IsTest(SeeAllData=true)
    static void testCreateInvoiceAndEnsureFunds_Success() {//insert Account
        Account testAccount = new Account(
            LastName = 'Test Account09081',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            BillingCity = 'Trumbull',
            BillingCountry = 'United States',
            BillingPostalCode = '06611',
            BillingState = 'connecticut',
            BillingStreet = '5 Dayton Cir',
            PersonEmail='Charishma1230908@gmail.com'
        );
        insert testAccount;
        System.debug('Accc Id ---- > '+ testAccount.Id);
                
        //get pricebook
        Id pricebookId = Test.getStandardPricebookId();
        
        //insert product
        Product2 product1 = new Product2(Name = 'Product 1',StockKeepingUnit = 'SKU1111',Description = 'Test Product 1', IsActive = true );
        // Product2 product1 = [SELECT Id,Name, StockKeepingUnit, Description,IsActive FROM Product2 Where IsActive = true Limit 1];        
        insert product1;
        
        Product2 product2 = new Product2(Name = 'Ship 2',StockKeepingUnit = 'SKU11111',Description = 'Test Product 2', IsActive = true );
        // Product2 product1 = [SELECT Id,Name, StockKeepingUnit, Description,IsActive FROM Product2 Where IsActive = true Limit 1];        
        insert product2;
        
        List<Product2> ProdList = new List<Product2>{product1,product2};
            
            //Pricebook entry
            PricebookEntry pbEntry1 = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = product1.Id,UnitPrice = 100,IsActive = true);
        insert pbEntry1;
        
        //'01sDn000005VENVIA4'
        PricebookEntry pbEntry2 = new PricebookEntry(Pricebook2Id = pricebookId ,Product2Id = product2.Id,UnitPrice = 100,IsActive = true);
        insert pbEntry2;
        
        //insert order
        Order order1 = new Order(AccountId = testAccount.Id , Status = 'Draft',EffectiveDate = Date.today(),Pricebook2Id =pbEntry1.Pricebook2Id ,orderedDate = Date.today());
        insert order1;
        
        // Create OrderDeliveryMethod
        OrderDeliveryMethod orderDeliveryMethod1 = new OrderDeliveryMethod(
            Name = 'OrderDeliveryMethod 1',
            ProductId = product1.Id
        );
        insert orderDeliveryMethod1;
        
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
        System.debug('Order item product Id-----> ' + orderItem.Product2Id );
        
        //insert Order line items
        
        OrderItem orderItem2 = new OrderItem(
            PricebookEntryId = pbEntry2.Id,
            Product2Id = product2.Id,
            OrderId = order1.Id,
            Quantity = 1,
            Type = 'Delivery Charge',
            UnitPrice = 100,
            ListPrice = 100,
            OrderDeliveryGroupId = orderDeliveryGroup1.Id,
            TotalLineAmount = 100
        );
        insert orderItem2;
        System.debug('Order item product Id-----> ' + orderItem.Product2Id );
        
        //create OrderItemTaxLineItems
        
        OrderItemTaxLineItem oTI1 = new OrderItemTaxLineItem(
            Amount = 3,
            Name = orderItem1.Product2.Name + ' Tax',
            OrderItemId = orderItem1.Id ,
            Type = 'Actual',
            TaxeffectiveDate = System.today()
        );
        
        insert oTI1;
        
        OrderItemTaxLineItem oTI2 = new OrderItemTaxLineItem(
            Amount = 2,
            Name = orderItem2.Product2.Name + ' Tax',
            OrderItemId = orderItem2.Id ,
            Type = 'Actual',
            TaxeffectiveDate = System.today()
        );
        
        insert oTI2;
        
        
        
        // update order status to Active
        order1.Status = 'Activated';
        update order1; 
        
       /*  ConnectApi.OrderSummaryInputRepresentation inputRepresentation = new ConnectApi.OrderSummaryInputRepresentation();
        inputRepresentation.orderId=order1.Id; //replace this recordId with an appropriate value.
        inputRepresentation.orderLifeCycleType='UNMANAGED';
        ConnectApi.OrderSummaryOutputRepresentation OutputRepresentation =ConnectApi.OrderSummaryCreation.createOrderSummary(inputRepresentation);
        
         OrderSummary orderSum=[SELECT Id, OriginalOrderId, OwnerId FROM OrderSummary WHERE OriginalOrderId =:order.Id];
        
        List<String> osId=new List<String>();
        osId.add(orderSum.Id);
        System.debug('orderSumId------>'+ orderSum.id );*/
        
        //id SalesChannelId =[select id from SalesChannel LIMIT 1].id;
        
        // Mock OrderSummary creation
        ConnectApi.OrderSummaryInputRepresentation inputRepresentation = new ConnectApi.OrderSummaryInputRepresentation();
        inputRepresentation.orderId = order1.Id;
        
        
       // inputRepresentation.orderLifeCycleType='UNMANAGED';
        ConnectApi.OrderSummaryOutputRepresentation outputRepresentation = ConnectApi.OrderSummaryCreation.createOrderSummary(inputRepresentation);
        System.debug('orderSummaryCreation---->'+outputRepresentation);
        
        // OrderPaymentSummary creation
        OrderPaymentSummary orderPaymentSummary = new OrderPaymentSummary();
        orderPaymentSummary.OrderSummaryId = outputRepresentation.orderSummaryId; 
        orderPaymentSummary.Method = 'Visa-1111'; 
        orderPaymentSummary.Type  = 'VISA'; 
        insert orderPaymentSummary;
        
        
        
        // PaymentAuthorization creation
        PaymentAuthorization paymentAuthorization = new PaymentAuthorization();
        paymentAuthorization.OrderPaymentSummaryId = orderPaymentSummary.Id;
        paymentAuthorization.Amount = 500.0; 
        paymentAuthorization.Status='Processed';
        paymentAuthorization.ProcessingMode='External';
        paymentAuthorization.GatewayRefNumber = 'abcdtqwe';
        insert paymentAuthorization;
        
        // Prepare the orderSumIdOrderItemsmap to simulate different scenarios
        Map<String, String> orderSumIdOrderItemsmap = new Map<String, String>();
        orderSumIdOrderItemsmap.put(outputRepresentation.orderSummaryId, 'FMG Warehouse');
        
        //Query inserted Order Summary
        OrderSummary orderSum=[SELECT Id, OriginalOrderId,SalesChannelId,OrderLifeCycleType, OrderNumber,OwnerId FROM OrderSummary WHERE OriginalOrderId =:order1.Id];
      /*  orderSum.SalesChannelId = SalesChannelId ;
        update orderSum; */
        //orderSum.OrderLifeCycleType = 'Managed';
        //update orderSum;
        
        order1.OrderReferenceNumber =orderSum.OrderNumber ;
        update order1;
        System.debug('Order----->'+order1 + 'Id---->'+order1.Id + 'orderSum----->'+orderSum);
        System.debug('OrderNumber----->'+orderSum.OrderNumber);
        
        //Order summary products
        List<OrderItemSummary> orderSumPro =[Select Id  from OrderItemSummary Where OrderSummaryId=:orderSum.Id];
        
        System.debug('orderSumPro---->'+orderSumPro);   
        
        
        
        String orderSummaryId = outputRepresentation.orderSummaryId;
        //String fulfillmentType = 'warehouse';
        
        Schema.Location LC = new Schema.Location(); 
        LC.Name = 'FMG Warehouse'; 
        LC.LocationType ='Warehouse'; 
        LC.IsInventoryLocation = True; 
        insert LC;
        System.debug('Location-->'+ LC);
        
        
        //String warehouseFromLocationId = [SELECT Id , Name from Location WHERE LocationType='Warehouse' LIMIT 1].Id;
        System.debug('Location Name------>'+ [SELECT Id , Name from Location WHERE LocationType='Warehouse' LIMIT 1].Name);
        
        ConnectApi.FulfillmentOrderInputRepresentation fulfillmentOrderInput = new ConnectApi.FulfillmentOrderInputRepresentation();
        fulfillmentOrderInput.orderSummaryId = orderSummaryId;
        
        
        List<OrderDeliveryGroupSummary> orderDeliveryGroupSummaryList = [SELECT Id FROM OrderDeliveryGroupSummary WHERE OrderSummaryId =: orderSummaryId];
        
        for (OrderDeliveryGroupSummary orderDeliveryGroupSummary: orderDeliveryGroupSummaryList){
            
            fulfillmentOrderInput.orderDeliveryGroupSummaryId = orderDeliveryGroupSummary.Id;
            List<ConnectApi.FulfillmentGroupInputRepresentation> fulfillmentGroups = new List<ConnectApi.FulfillmentGroupInputRepresentation>();
            ConnectApi.FulfillmentGroupInputRepresentation fulfillmentGroup = new ConnectApi.FulfillmentGroupInputRepresentation();
            fulfillmentGroup.fulfilledFromLocationId = LC.Id;
            fulfillmentGroup.fulfillmentType = LC.LocationType;
            
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
        fulfillmentOrder1 = [select Id ,DeliveryMethodId,OrderSummaryId ,TotalTaxAmount ,GrandTotalAmount,FulfilledToPhone,Status,FulfilledToName,FulfilledToCity,FulfilledToCountry,FulfilledToEmailAddress,FulfilledToPostalCode,FulfilledToState,FulfilledToStreet,AccountId from fulfillmentOrder where Id=:result.fulfillmentOrderIds];
        System.debug('fulfillment order---->' + fulfillmentOrder1);  
        
        //Query FulfillmentOrderLineItem
        List<FulfillmentOrderLineItem> fO_lineItem = [select Id,Quantity,UnitPrice,Product2Id,TotalLineTaxAmount,OrderItemId,OrderItemSummaryId from FulfillmentOrderLineItem where FulfillmentOrderId = :fulfillmentOrder1.Id];
        System.debug('fulfillment product---->' + fO_lineItem);
        
        List<Id> fulfillmentOrders = new List<Id>();
        fulfillmentOrders.add(fulfillmentOrder1.Id);
          
        
        ConnectApi.FulfillmentOrderInvoiceInputRepresentation input = new ConnectApi.FulfillmentOrderInvoiceInputRepresentation();
        //invoiceId =input.invoiceId;
        ConnectAPI.FulfillmentOrderInvoiceOutputRepresentation result1 = ConnectApi.FulfillmentOrder.createInvoice(fulfillmentOrder1.Id, input);
        System.debug('FulfillmentOrderInvoiceOutputRepresentation'+result1);
        //Id invoiceId = result1.invoiceId;
        
        ConnectApi.EnsureFundsAsyncInputRepresentation inputEFAIR = new ConnectApi.EnsureFundsAsyncInputRepresentation();
        inputEFAIR.invoiceId =result1.invoiceId;
        
        ConnectApi.EnsureFundsAsyncOutputRepresentation output = ConnectApi.OrderSummary.ensureFundsAsync(orderSummaryId,inputEFAIR);
        System.debug('EnsureFundsAsyncOutputRepresentation'+output);
        
        Id BackgroundId = output.backgroundOperationId;
        List<Id> ListBGIds = new List<Id>();
        ListBGIds.add(BackgroundId);
        System.debug('BackgroundId--->'+BackgroundId);
        System.debug('fulfillmentOrder1.Id--->'+fulfillmentOrder1.Id);
        
        Map<String,String> Headers = new Map<String, String>();
        Headers.put('Content-Type', 'application/json');
        String body = '{"Name":"Test"}';
        SingleRequestMock fakeResp = new SingleRequestMock(200,body,Headers);
        Test.setMock(HttpCalloutMock.class, fakeResp);
        
        Test.startTest();
        HandleInvoiceCreation.createInvoice(fulfillmentOrders);
        HandleInvoiceCreation.ensureFunds(inputEFAIR.invoiceId,orderSummaryId);
        Test.stopTest();
    }
}