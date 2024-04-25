@IsTest
public class SalesOrderInvoiceLineTest {
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
    @TestVisible public static void soException() {
        try{
        
        //insert Account
        Account testAccount = new Account(
            LastName = 'Test Account09081',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            BillingCity = 'Trumbull',
            BillingCountry = 'United States',
            BillingPostalCode = '06611',
            BillingState = 'connecticut',
            BillingStreet = '5 Dayton Cir',
            PersonEmail='gorupotusita15@gmail.com'
        );
        insert testAccount;
        System.debug('Accc Id ---- > '+ testAccount.Id);
        
        //get pricebook
        Id pricebookId = Test.getStandardPricebookId();
        // Query Normal product
        Product2 product1 = [select id , Name ,StockKeepingUnit ,Description from product2 where Name = '1000DS' Limit 1];
        
        //Query ship product 
        Product2 product2 = [select id , Name  from product2 where Name='$6.99 - Best Way Shipping' Limit 1];
        
        //Pricebook entry
        PricebookEntry pbEntry1 = [SELECT Id ,Pricebook2Id , Product2Id FROM PricebookEntry where Product2Id = :product1.Id];
        
        //'01sDn000005VENVIA4'
        PricebookEntry pbEntry2 = new PricebookEntry(Pricebook2Id = pricebookId ,Product2Id = product2.Id,UnitPrice = 100,IsActive = true);
        insert pbEntry2;
        
        //insert order
        Order order1 = new Order(AccountId = testAccount.Id , Status = 'Draft',EffectiveDate = Date.today(),Pricebook2Id =pbEntry1.Pricebook2Id ,orderedDate = Date.today(),ShippingCity=testAccount.BillingCity , ShippingCountry = testAccount.BillingCountry , ShippingState = testAccount.BillingState ,ShippingStreet = testAccount.ShippingStreet , ShippingPostalCode = testAccount.ShippingPostalCode);
        insert order1;
        
        // Create OrderDeliveryMethod
        OrderDeliveryMethod orderDeliveryMethod1 = [SELECT Id , ProductId FROM OrderDeliveryMethod where ProductId = :product2.Id];
        
        
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
            //ListPrice = 100,
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
            //ListPrice = 100,
            OrderDeliveryGroupId = orderDeliveryGroup1.Id
            //TotalLineAmount = 100
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
        
        // Mock OrderSummary creation
        ConnectApi.OrderSummaryInputRepresentation inputRepresentation = new ConnectApi.OrderSummaryInputRepresentation();
        inputRepresentation.orderId = order1.Id;
        // inputRepresentation.orderLifeCycleType='UNMANAGED';
        ConnectApi.OrderSummaryOutputRepresentation outputRepresentation = ConnectApi.OrderSummaryCreation.createOrderSummary(inputRepresentation);
        System.debug('orderSummaryCreation---->'+outputRepresentation); 
        
        //Query inserted Order Summary
        OrderSummary orderSum=[SELECT Id,status,SalesChannelId, OriginalOrderId,OrderLifeCycleType, OrderNumber,OwnerId FROM OrderSummary WHERE OriginalOrderId =:order1.Id];
        System.debug('ordersum Status----->'+ orderSum.status);
        
        // OrderPaymentSummary creation
        OrderPaymentSummary orderPaymentSummary = new OrderPaymentSummary();
        orderPaymentSummary.OrderSummaryId = orderSum.Id; 
        //outputRepresentation.orderSummaryId
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
        orderSumIdOrderItemsmap.put(orderSum.Id, 'FMG Warehouse');
        
        
        //update orderSum;
        
        order1.OrderReferenceNumber =orderSum.OrderNumber ;
        update order1;
        System.debug('Order----->'+order1 + 'Id---->'+order1.Id + 'orderSum----->'+orderSum);
        System.debug('OrderNumber----->'+orderSum.OrderNumber);
        
        
        
        String orderSummaryId = orderSum.Id;
        String fulfillmentType = 'warehouse';
        
        String warehouseFromLocationId = [SELECT Id , Name from Location WHERE LocationType='Warehouse' AND Name = 'Virtual Warehouse' LIMIT 1].Id;
        System.debug('Location Name------>'+ [SELECT Id , Name from Location WHERE LocationType='Warehouse' LIMIT 1].Name);
        
        ConnectApi.FulfillmentOrderInputRepresentation fulfillmentOrderInput = new ConnectApi.FulfillmentOrderInputRepresentation();
        fulfillmentOrderInput.orderSummaryId = orderSummaryId;
        
        
        List<OrderDeliveryGroupSummary> orderDeliveryGroupSummaryList = [SELECT Id FROM OrderDeliveryGroupSummary WHERE OrderSummaryId =: orderSummaryId];
        
        for (OrderDeliveryGroupSummary orderDeliveryGroupSummary: orderDeliveryGroupSummaryList){
            
            fulfillmentOrderInput.orderDeliveryGroupSummaryId = orderDeliveryGroupSummary.Id;
            List<ConnectApi.FulfillmentGroupInputRepresentation> fulfillmentGroups = new List<ConnectApi.FulfillmentGroupInputRepresentation>();
            ConnectApi.FulfillmentGroupInputRepresentation fulfillmentGroup = new ConnectApi.FulfillmentGroupInputRepresentation();
            fulfillmentGroup.fulfilledFromLocationId = warehouseFromLocationId;
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
        fulfillmentOrder1 = [select Id ,DeliveryMethodId,GrandTotalAmount,OrderSummaryId ,TotalTaxAmount ,FulfilledToPhone,Status,FulfilledToName,FulfilledToCity,FulfilledToCountry,FulfilledToEmailAddress,FulfilledToPostalCode,FulfilledToState,FulfilledToStreet,AccountId from fulfillmentOrder where Id=:result.fulfillmentOrderIds];
        System.debug('fulfillment order---->' + fulfillmentOrder1);  
        
        //Query FulfillmentOrderLineItem
        List<FulfillmentOrderLineItem> fO_lineItem = new List<FulfillmentOrderLineItem>();
        FulfillmentOrderLineItem fO_lineItemList = [select Id,Quantity,UnitPrice,Product2Id,TotalLineTaxAmount,OrderItemId,OrderItemSummaryId from FulfillmentOrderLineItem where FulfillmentOrderId = :fulfillmentOrder1.Id Limit 1];
        System.debug('fulfillment product---->' + fO_lineItem);
       
       fO_lineItem.add(fO_lineItemList);
        
        
        List<Id> fulfillmentOrders = new List<Id>();
        fulfillmentOrders.add(fulfillmentOrder1.Id);
        
        orderSum.Status = 'Approved';
        update orderSum;
        System.debug('orderSum Status---->' + orderSum.Status);
        
        OrderDeliveryGroupSummary ODGS = [SELECT id , OrderSummaryId ,DeliverToCity FROM OrderDeliveryGroupSummary where OrderSummaryId = :orderSum.Id Limit 1];
        System.debug('ODGS---->'+ ODGS);
        
        System.debug('order ADd---->' + order1.ShippingCity);
        
        
        String Regular = 'a5SDK000000MFLf2AO';
        rstk__sotax__c taxLocation =[select id from rstk__sotax__c LIMIT 1];
        String CarrierCode = [select Id,Name from rstk__sycarrier__c WHERE Name ='TBD (To Be Determined)'  Limit 1].id;
        
        //insert customer Account
        rstk__socust__c rstkCustomer = new rstk__socust__c(
            rstk__socust_sf_account__c = testAccount.Id,
            rstk__socust_sf_account_name__c = testAccount.LastName,
            rstk__socust_custno__c =  testAccount.Id,
            rstk__socust_overconfigs__c = true ,
            // rstk__socust_carrier__c = test_CarrierCode.Id,
            // rstk__socust_custcurr__c = test_Currency.Id,
            rstk__socust_cclass__c = Regular
            
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
        
        insert rstk_CustAddr1;
        System.debug('rstk_CustAddress---------->' + rstk_CustAddr1);
        
        rstk__soprod__c rstk_product = [select id ,rstk__soprod_div__c,rstk__soprod_icitem__c from rstk__soprod__c where rstk__soprod_sf_product__c = :product1.Id Limit 1];
        System.debug('rstk_product--->'+rstk_product);  
        
        Test.startTest();
       // Test.setMock(HttpCalloutMock.class, new MockFulfillmentOrderWebService());
        
        Order OrderRef = [Select Id , OrderReferenceNumber from Order where Id = :orderSum.OriginalOrderId];
        System.debug('OrderRef---->' + OrderRef.OrderReferenceNumber);
        
        rstk__sydiv__c salesDivision = [select Id,Name, rstk__sydiv_mainsite__c from rstk__sydiv__c WHERE Name ='Fire Mountain Gems and Beads, Inc. (FMG)' Limit 1];  
        
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
        soHeader.rstk__soapi_ssysdiv__c = rstk_product.rstk__soprod_div__c;
        //soHeader.rstk__soapi_salesdiv__c = salesDivision.Id;
        soHeader.rstk__soapi_billtoaddr__c = rstk_CustAddr.Id;
        soHeader.rstk__soapi_shipvia_useonline__c = true;
        soHeader.rstk__soapi_ordpayid__c =paymentAuthorization.GatewayRefNumber;
        soHeader.rstk__soapi_ordpayamt__c =fulfillmentOrder1.GrandTotalAmount;
        soHeader.rstk__soapi_ordprepaid__c =true;
        soHeader.rstk__soapi_invoice__c = true;
        soHeader.rstk__soapi_invoiceorder__c = true;
        soHeader.rstk__soapi_addtobatch__c = true;
        
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
        soh = [select id,Name,rstk__soapi_orderno__c,rstk__soapi_email__c,rstk__soapi_socust__c,rstk__soapi_customer__c,rstk__soapi_sohdr__c,rstk__soapi_ssysdiv__c from rstk__soapi__c where Id =: soHeader.id Limit 1];
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
        soLine.rstk__soapi_taxloc__c =taxLocation.id;
        //soLine.rstk__soapi_async__c = True;
        soLine.rstk__soapi_ssysdiv__c = rstk_product.rstk__soprod_div__c;
        soLine.rstk__soapi_isysdiv__c = rstk_product.rstk__soprod_div__c;
        soLine.rstk__soapi_lineshiptoaddr__c = rstk_CustAddr1.Id;
        
        insert soLine;
        System.debug('So Line List----------->' + soLinesList);
        
        //rstk__soapi_soline__c
        rstk__soapi__c sol = new rstk__soapi__c();
       // sol = [select id ,rstk__soapi_line__c,rstk__soapi_orderno__c,rstk__soapi_socust__c,rstk__soapi_error__c,rstk__soapi_customer__c,rstk__soapi_sohdr__c,rstk__soapi_soline__c,rstk__soapi_ssysdiv__c,rstk__soapi_upgroup__c from rstk__soapi__c where Id =: soLine.id Limit 1];
        
        System.debug('So line Id----->' +sol.rstk__soapi_soline__c );
        System.debug('error ----->' +sol.rstk__soapi_error__c );
        System.debug('Line number ----->' +sol.rstk__soapi_line__c );
        
        
        String sydivAddr = [select Id from rstk__sydivaddr__c Limit 1].id;
        String shipviaType =[select Id from rstk__syshipviatype__c Limit 1].id;
        String site_Master = [select Id from rstk__sysite__c Limit 1].id;
        
        
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
        
        //insert sydata
        rstk__sydata__c sysdata = new rstk__sydata__c(
            rstk__sydata_txntype__c = 'Create Invoice for Shipper' ,
            rstk__sydata_soship__c = ship_header.Id,
            rstk__sydata_sohdr__c = soh.rstk__soapi_sohdr__c,
            rstk__sydata_sydiv__c = salesDivision.id,
            rstk__sydata_backgroundprocessing__c = false
        );
        
        insert sysdata; 
        
        System.debug('sysdata----------->' + sysdata );  
        
        rstk__soinv__c RSInvoice = [Select id from rstk__soinv__c where rstk__soinv_order__c = :soh.rstk__soapi_sohdr__c];
        System.debug('RSInvoice-------->' + RSInvoice);
        List<Id> RSinvoiceheader = new List<Id>{RSInvoice.Id};
        
        ConnectApi.FulfillmentOrderInvoiceInputRepresentation invoiceInput = new ConnectApi.FulfillmentOrderInvoiceInputRepresentation();
        ConnectApi.FulfillmentOrderInvoiceOutputRepresentation outputInvoice = ConnectApi.FulfillmentOrder.createInvoice(fulfillmentOrder1.Id, invoiceInput);
        
        
        Invoice getInvoice = [Select Id from Invoice where Id = : outputInvoice.invoiceId Limit 1];
        System.debug('invoice ---------->' + getInvoice);
        
        List<Id> invoiceIds = new List<Id>{getInvoice.Id}; 
            
       SalesOrderInvoiceLine.soInvoiceLineQtyCheck(RSinvoiceheader);
        
        Test.stopTest();
        } 
        
         catch(exception e){
             System.debug('Exception is-->' + e.getMessage());
            }
   
    }
}