@IsTest
public class RootstockCreateInvoiceTest  {
    
    public class MockFulfillmentOrderWebService implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"orderSummaryId": "mock_order_summary_id"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest(SeeAllData=true)
    @TestVisible public static void createInvoice(){        
        //insert Account
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
        //  testAccount.PersonEmail='Cherri123@gmail.com';
        //  update testAccount;        
        // Account testAccount = [Select Id,Name ,Shipping_Address__City__ps,Shipping_Address__CountryCode__ps,PersonEmail,Shipping_Address__PostalCode__ps,Shipping_Address__StateCode__ps,Shipping_Address__Street__ps from Account where id='001DK00000xzZtiYAE'];
        
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
 
        
       String Regular = [select Id,Name from rstk__socclass__c WHERE Name ='DFLT-CLASS'  Limit 1].id;
        rstk__sotax__c taxLocation =[select id from rstk__sotax__c LIMIT 1];
        
        //insert customer Account
        rstk__socust__c rstkCustomer = new rstk__socust__c(
            rstk__socust_sf_account__c = testAccount.Id,
            rstk__socust_sf_account_name__c = testAccount.LastName,
            rstk__socust_custno__c =  testAccount.Id,
            // rstk__socust_carrier__c = test_CarrierCode.Id,
            // rstk__socust_custcurr__c = test_Currency.Id,
            rstk__socust_cclass__c = Regular
            // rstk__socust_fob__c = test_FOB.Id,
            // rstk__socust_frghtrm__c = test_Freight.Id,
            // rstk__socust_shipviatype__c = test_ShippingMeth.Id, 
            // rstk__socust_terms__c = test_TermsCode.Id
            
        );
        
        System.debug('Fulfill Acc Id ------> '+ fulfillmentOrder1.AccountId);
        insert rstkCustomer ;
        System.debug('rstk Customer =====>' + rstkCustomer );
        
        //Create rootstock Customer Address
        rstk__socaddr__c rstk_CustAddr = new rstk__socaddr__c(
            rstk__socaddr_custno__c = rstkCustomer.Id ,
            //rstk__socaddr_defaultbillto__c = true ,
            rstk__socaddr_address1__c = testAccount.BillingStreet,
            rstk__socaddr_city__c =  testAccount.BillingCity,
            rstk__socaddr_country__c =  testAccount.BillingCountry,
            rstk__socaddr_zip__c = testAccount.BillingPostalCode,
            rstk__socaddr_name__c = testAccount.LastName,
            Name = testAccount.LastName,
            rstk__socaddr_email__c = testAccount.PersonEmail,
            rstk__socaddr_seq__c = 3,
            rstk__socaddr_phone__c = testAccount.Phone,
            rstk__socaddr_useasbillto__c = true 
            //rstk__socaddr_taxloc__c  = taxLocation.Id
            
        );
        
        insert rstk_CustAddr;
        System.debug('rstk_CustAddress---------->' + rstk_CustAddr);
        
        //Create rootstock Customer Address
        rstk__socaddr__c rstk_CustAddr1 = new rstk__socaddr__c(
            rstk__socaddr_custno__c = rstkCustomer.Id ,
            //rstk__socaddr_defaultshipto__c = true ,
            rstk__socaddr_address1__c = '4367 Franklin Avenue',
            rstk__socaddr_city__c =  'Daytona Beach',
            rstk__socaddr_country__c =  'United States',
            rstk__socaddr_zip__c = '32114',
            rstk__socaddr_name__c = testAccount.LastName,
            Name = testAccount.LastName,
            rstk__socaddr_email__c = testAccount.PersonEmail,
            rstk__socaddr_seq__c =4,
            rstk__socaddr_phone__c = testAccount.Phone,
            rstk__socaddr_useasshipto__c = true,
            rstk__socaddr_taxloc__c  = taxLocation.Id
           
        );
        
        //  insert rstk_CustAddr1;
        System.debug('rstk_CustAddress---------->' + rstk_CustAddr1);
        rstk__sydiv__c salesDivision = [select Id, rstk__sydiv_mainsite__c from rstk__sydiv__c Limit 1];  
        String UOM = [select Id from rstk__syuom__c Limit 1].id;
        String pro_Grp_master =[select Id from rstk__socomm__c Limit 1].id;
        String inventory_Master = [select Id from rstk__icitem__c Limit 1].id;
        String site_Master = [select Id from rstk__sysite__c Limit 1].id;
        String costOfSalesAcc = [select Id from rstk__syacc__c Limit 1].id;
        List<rstk__soprod__c> rtsk_ProdList = new List<rstk__soprod__c>();
        
        //Insert rootstock product 
        rstk__soprod__c rstk_product = new rstk__soprod__c(
            rstk__soprod_sf_product__c = product1.Id,
            rstk__soprod_prod__c = product1.Name,
            rstk__soprod_prodtype__c ='Stock',
            rstk__soprod_slsuom__c = UOM ,
            rstk__soprod_comcod__c = pro_Grp_master,
            rstk__soprod_div__c = salesDivision.Id,
            rstk__soprod_icitem__c = inventory_Master,
            rstk__soprod_activeind__c = true,
            rstk__soprod_freightamt__c = 0 ,
            rstk__soprod_handlingamt__c = 0,
            rstk__soprod_shipdiv__c = salesDivision.Id,
            rstk__soprod_packageamt__c = 0,
            rstk__soprod_price__c = 0,
            rstk__soprod_shipsite__c = site_Master,
            rstk__soprod_umcf__c = 1,
            rstk__soprod_weight__c = 0.1134 ,
            rstk__soprod_height__c = 0 ,
            rstk__soprod_width__c = 0 ,
            rstk__soprod_hscode__c = '3924.10.40',
           // rstk__soprod_cosacct__c = 'a8JDK000000Xb482AC',
            rstk__soprod_cosacct__c = costOfSalesAcc
           // rstk__soprod_cospendacct__c = 'a8JDK000000Xb482AC'
            
        ); 
        
        System.debug('rstk_Product------->' + rstk_product );      
        
        try {
            // Insert the record
            insert rstk_product ;
            System.debug('rstk product---------->' + rstk_product );
            System.debug('rstk product Id---------->' + rstk_product.Id );
        } catch (Exception e) {
            // Handle exceptions 
            System.debug('Error: ' + e.getMessage());
        } 
        
        Order OrderRef = [Select Id , OrderReferenceNumber from Order where Id = :orderSum.OriginalOrderId];
        System.debug('OrderRef---->' + OrderRef.OrderReferenceNumber);
        //SO header soapi
        rstk__soapi__c soHeader = new rstk__soapi__c();
        soHeader.rstk__soapi_mode__c = 'Add Header';
        soHeader.rstk__soapi_socust__c = rstkCustomer.Id;
        //soHeader.rstk__soapi_orderno__c =fulfillmentOrder1.OrderSummary.OriginalOrder.OrderReferenceNumber  ;
        soHeader.rstk__soapi_orderno__c = OrderRef.OrderReferenceNumber;
        soHeader.rstk__soapi_customer__c = rstkCustomer.rstk__socust_custno__c;
        soHeader.rstk__soapi_email__c =fulfillmentOrder1.FulfilledToEmailAddress;
        soHeader.rstk__soapi_conmethod__c='Email';
        soHeader.rstk__soapi_taxloc__c =taxLocation.id;
        soHeader.rstk__soapi_addstaddrovr__c =true;
        soHeader.rstk__soapi_email__c=fulfillmentOrder1.FulfilledToEmailAddress;
        soHeader.rstk__soapi_stname__c =fulfillmentOrder1.FulfilledToName;
        soHeader.rstk__soapi_address1__c =fulfillmentOrder1.FulfilledToStreet;        
        soHeader.rstk__soapi_city__c =fulfillmentOrder1.FulfilledToCity;
        soHeader.rstk__soapi_state__c =fulfillmentOrder1.FulfilledToState;
        soHeader.rstk__soapi_country__c =fulfillmentOrder1.FulfilledToCountry;
        soHeader.rstk__soapi_zip__c =fulfillmentOrder1.FulfilledToPostalCode;
        soHeader.rstk__soapi_phone__c=fulfillmentOrder1.FulfilledToPhone;
        soHeader.rstk__soapi_hdfreighatamt__c = 100;
        soHeader.rstk__soapi_orderdate__c = Date.Today();
        soHeader.rstk__soapi_ssysdiv__c = salesDivision.Id;
        //soHeader.rstk__soapi_salesdiv__c = salesDivision.Id;
        soHeader.rstk__soapi_billtoaddr__c = rstk_CustAddr.Id;        
        System.debug('Order number--------> ' + soHeader.rstk__soapi_orderno__c + 'Division---->'+ soHeader.rstk__soapi_ssysdiv__c);        
        try {
            // Insert the record
            insert soHeader;  
            System.debug('soh-header---------->' + soHeader.rstk__soapi_sohdr__c );
        } catch (Exception e) {
            // Handle exceptions 
            System.debug('Error: ' + e.getMessage());
        }
        System.debug('SOH Soap----->' + soHeader);
        System.debug('So header---->'+ soHeader.rstk__soapi_sohdr__c + 'SoH Id---->'+soHeader.Id);        
        rstk__soapi__c soh = new rstk__soapi__c();
        soh = [select id,Name,rstk__soapi_orderno__c,rstk__soapi_email__c,rstk__soapi_socust__c,rstk__soapi_customer__c,rstk__soapi_sohdr__c,rstk__soapi_ssysdiv__c from rstk__soapi__c where Id =: soHeader.id ];
        System.debug(soh);
        System.debug('Sohdr------->'+soh.rstk__soapi_sohdr__c);
        Double tax = double.valueOf(fO_lineItem[0].TotalLineTaxAmount);
        List<rstk__soapi__c> soLinesList = new List<rstk__soapi__c>(); 
        //Sales order Line soapi 
        rstk__soapi__c soLine = new rstk__soapi__c();
        soLine.rstk__soapi_mode__c = 'Add Line';
        soLine.rstk__soapi_upgroup__c =soh.rstk__soapi_orderno__c;
        soLine.rstk__soapi_orderno__c =soh.rstk__soapi_orderno__c;
        soLine.rstk__soapi_sohdr__c = soh.rstk__soapi_sohdr__c;
        soLine.rstk__soapi_qtyorder__c =fO_lineItem[0].Quantity;
        System.debug('Fol-Quant----------->' + fO_lineItem[0].Quantity);
        soLine.rstk__soapi_price__c = fO_lineItem[0].UnitPrice;
        System.debug('Fol-UnitPrice----------->' + fO_lineItem[0].UnitPrice);
        soLine.rstk__soapi_taxamount__c = tax;
        soLine.rstk__soapi_taxoverride__c =true;
        soLine.rstk__soapi_soprod__c = rstk_product.Id;
        //soLine.rstk__soline_prodtype__c='Stock';
        //soLine.rstk__soapi_lineinstaddr__c=rstk_CustAddr.id;
        // soLine.rstk__soapi_pricebook__c = 
        //rstk__soapi_line__c ,rstk__soapi_pricebook__c
        soLine.rstk__soapi_taxloc__c =taxLocation.id;
        //soLine.rstk__soapi_async__c = True;
        soLine.rstk__soapi_ssysdiv__c = salesDivision.Id;
        soLine.rstk__soapi_isysdiv__c = salesDivision.Id;
        soLine.rstk__soapi_lineshiptoaddr__c = rstk_CustAddr1.Id;
        
        insert soLine;
        System.debug('SolineId------------->' + soLine.rstk__soapi_soline__c);
        //rstk__soprod__c 
        // soLinesList.add(soLine);
        
        //insert soLinesList ;
        System.debug('So Line----------->' + soLine);
        System.debug('So Line List----------->' + soLinesList);
        
        //rstk__soapi__c soLine = new rstk__soapi__c();
        
        //rstk__soapi_soline__c
        rstk__soapi__c sol = new rstk__soapi__c();
        sol = [select id ,rstk__soapi_line__c,rstk__soapi_orderno__c,rstk__soapi_socust__c,rstk__soapi_error__c,rstk__soapi_customer__c,rstk__soapi_sohdr__c,rstk__soapi_soline__c,rstk__soapi_ssysdiv__c,rstk__soapi_upgroup__c from rstk__soapi__c where Id =: soLine.id];
        
        System.debug('So line Id----->' +sol.rstk__soapi_soline__c );
        System.debug('error ----->' +sol.rstk__soapi_error__c );
        System.debug('Line number ----->' +sol.rstk__soapi_line__c );
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockFulfillmentOrderWebService());
        
        String sydivAddr = [select Id from rstk__sydivaddr__c Limit 1].id;
        String shipviaType =[select Id from rstk__syshipviatype__c Limit 1].id;
        /*String inventory_Master = [select Id from rstk__icitem__c Limit 1].id;
        String site_Master = [select Id from rstk__sysite__c Limit 1].id;
        String costOfSalesAcc = [select Id from rstk__syacc__c Limit 1].id;*/
        
        
        //insert ship header
        rstk__soship__c ship_header = new rstk__soship__c(
            rstk__soship_custno__c = rstkCustomer.id,
            rstk__soship_order__c = soh.rstk__soapi_sohdr__c,
            rstk__soship_taxloc__c = taxLocation.Id,
            //rstk__soship_sydivaddr__c = 'a8gDK000000KzwpYAC',
            rstk__soship_sydivaddr__c = sydivAddr,
            //rstk__soship_shipsite__c = 'a9CDK000000Kz0r2AC',
            rstk__soship_shipsite__c = site_Master ,
            rstk__soship_shipper__c = 1,
            rstk__soship_email__c = 'CheckWEb@etg.com',
            rstk__soship_country__c = 'United States',
            rstk__soship_city__c = 'Flower Mound',
            rstk__soship_address1__c = 'test Street',
            rstk__soship_state__c = 'Texas',
            rstk__soship_name__c = 'Ship header',
            rstk__soship_phone__c = '7799421291',
            rstk__soship_conmethod__c = 'Email',
            rstk__soship_shiptoaddr__c = rstk_CustAddr1.id,
            //rstk__soship_shipvia__c = 'a9BDK000000L3Nj2AK'
            rstk__soship_shipvia__c = shipviaType,
            rstk__soship_allshipped__c = true

        );
        
        insert ship_header; 
        System.debug('Shipper header--------->' + ship_header.Id);
        
        rstk__soapi__c sol1 = new rstk__soapi__c(
        rstk__soapi_mode__c = 'Change Line',
        rstk__soapi_soline__c = sol.rstk__soapi_soline__c,
        //sol.rstk__soapi_line__c = 10;
        //sol.rstk__soapi_invoice__c = true;
        rstk__soapi_fulfill__c = true,
        rstk__soapi_async__c = false 
        //sol.rstk__soapi_taxloctoline__c = true ;
        );
       
        
        insert sol1;
        System.debug('soLine.Status10------>'+ sol.rstk__soapi_line__c); 
        
        //Query inserted SOLine
        rstk__soline__c InsertedsoLine =[Select Id , rstk__soline_linestatustext__c,rstk__soline_status__c from rstk__soline__c where Id =:sol.rstk__soapi_soline__c ];
        System.debug('AfterStatus2------>'+ InsertedsoLine.rstk__soline_status__c);
  
        //insert sydata
        rstk__sydata__c sysdata = new rstk__sydata__c(
            //rstk__sydata_txntype__c = 'Create Sales Invoice' ,
            rstk__sydata_txntype__c = 'Create Invoice for Shipper' ,
           // rstk__sydata_txntype__c = 'Sales Order Pick-Pack-Ship' ,
           // rstk__sydata_txntype__c = 'Sales Order Shipment' ,
            rstk__sydata_soship__c = ship_header.Id,
            //rstk__sydata_process__c = 'ProcessingComplete',
            rstk__sydata_sohdr__c = soh.rstk__soapi_sohdr__c,
            rstk__sydata_soline__c = sol.rstk__soapi_soline__c,
            //rstk__sydata_soshipline__c = salesDivision.id,
            rstk__sydata_addinvapproved__c = true, //new change,
            rstk__sydata_backgroundprocessing__c = false
        );
        
        insert sysdata; 
        
        System.debug('sysdata----------->' + sysdata );  

        
        rstk__sydata__c getSysdata = [select id ,rstk__sydata_message__c, rstk__sydata_process__c from rstk__sydata__c where id =:sysdata.id ];
        System.debug('sysdata process----------->'+getSysdata.rstk__sydata_process__c );
        System.debug('sysdata error----------->'+getSysdata.rstk__sydata_message__c );

        
       // rstk__soinv__c RSInvoice = [Select id from rstk__soinv__c where rstk__soinv_order__c = :soh.rstk__soapi_sohdr__c];
        
        rstk__soinv__c soInvHeader =[select id,rstk__soinv_approved__c,rstk__soinv_order__r.rstk__sohdr_order__c from rstk__soinv__c where rstk__soinv_order__c = :soh.rstk__soapi_sohdr__c];
                           
        
        System.debug('soInvHeader -------->' + soInvHeader );
      
        ConnectApi.FulfillmentOrderInvoiceInputRepresentation invoiceInput = new ConnectApi.FulfillmentOrderInvoiceInputRepresentation();
        ConnectApi.FulfillmentOrderInvoiceOutputRepresentation outputInvoice = ConnectApi.FulfillmentOrder.createInvoice(fulfillmentOrder1.Id, invoiceInput);
        
        
        Invoice getInvoice = [Select Id from Invoice where Id = : outputInvoice.invoiceId];
        System.debug('invoice ---------->' + getInvoice);
        
        List<Id> invoiceIds = new List<Id>{getInvoice.Id}; 
       
        system.debug( '----------invoiceIds---------'+invoiceIds);
         CreateInvoiceInRSTK.createSalesOrderInvoice(invoiceIds);

        Test.stopTest();
        
    } 
  
}