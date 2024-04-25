@IsTest
public class UpdatePlatinumAttributesFromCDPBatchTest {
    
    @IsTest(SeeAllData=true)
    @TestVisible public static void testDataSetUp(){
        
        Account testAcc = new Account(
            LastName = 'Account-MM01042023',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            BillingCity = 'Trumbull',
            BillingCountry = 'United States',
            BillingPostalCode = '06611',
            BillingState = 'connecticut',
            BillingStreet = '5 Dayton Cir',
            PersonEmail='mm01042023@etgtest.com'
        );
        insert testAcc;
        System.debug('Acc: '+ testAcc);
        
        // Get Pricebook
        Id pricebookId = Test.getStandardPricebookId();
        
        // Insert Products
        Product2 prod1 = new Product2(Name = 'Product 1',StockKeepingUnit = 'SKU1111',Description = 'Test Product 1', IsActive = true );        
        insert prod1;
        
        Product2 prod2 = new Product2(Name = 'Ship 2',StockKeepingUnit = 'SKU11111',Description = 'Test Product 2', IsActive = true );     
        insert prod2;
        
        Product2 UPS = new Product2(Name = 'UPS',StockKeepingUnit = 'UPS1',Description = 'Test UPS', IsActive = true );     
        insert UPS;        
        
        // Pricebook entry
        PricebookEntry pbEntry1 = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prod1.Id,UnitPrice = 100,IsActive = true);
        insert pbEntry1;
        
        PricebookEntry pbEntry2 = new PricebookEntry(Pricebook2Id = pricebookId ,Product2Id = prod2.Id,UnitPrice = 100,IsActive = true);
        insert pbEntry2;
        
        PricebookEntry pbEntryUPS = new PricebookEntry(Pricebook2Id = pricebookId ,Product2Id = UPS.Id,UnitPrice = 10,IsActive = true);
        insert pbEntryUPS;
        
        // Insert order
        Order ord = new Order(AccountId = testAcc.Id , Status = 'Draft',EffectiveDate = Date.today(),Pricebook2Id =pbEntry1.Pricebook2Id ,orderedDate = Date.today());
        insert ord;
        
        // Create OrderDeliveryMethod
        OrderDeliveryMethod ODM = new OrderDeliveryMethod(
            Name = 'UPS',
            ProductId = UPS.Id
        );
        insert ODM;
        
        // Insert order delivery group
        OrderDeliveryGroup ODG = new OrderDeliveryGroup(
            DeliverToName = 'orderDeliveryGroup1',
            OrderDeliveryMethodId = ODM.Id,
            OrderId = ord.Id,
            Description = 'CartDeliveryGroup.Description',
            DesiredDeliveryDate = Date.today(),
            DeliverToStreet = 'test Street',
            DeliverToCity= 'Flower Mound',
            DeliverToState = 'Texas',
            DeliverToPostalCode ='75028',
            DeliverToCountry ='United States'
        );
        insert ODG;
        
        // Insert Order line items
        OrderItem orderItem1 = new OrderItem(
            PricebookEntryId = pbEntry1.Id,
            Product2Id = prod1.Id,
            OrderId = ord.Id,
            Quantity = 5,
            Type = 'Order Product',
            UnitPrice = 100,
            ListPrice = 100,
            OrderDeliveryGroupId = ODG.Id,
            TotalLineAmount = 500
        );
        insert orderItem1;
        System.debug('Order item product Id-----> ' + orderItem.Product2Id );
        
        OrderItem orderItem2 = new OrderItem(
            PricebookEntryId = pbEntryUPS.Id,
            Product2Id = UPS.Id,
            OrderId = ord.Id,
            Quantity = 1,
            Type = 'Delivery Charge',
            UnitPrice = 10,
            ListPrice = 10,
            OrderDeliveryGroupId = ODG.Id,
            TotalLineAmount = 100
        );
        insert orderItem2;
        System.debug('Order item product Id-----> ' + orderItem.Product2Id );
        
        // Create OrderItemTaxLineItems
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
        
        // Update order status to Active
        ord.Status = 'Activated';
        update ord; 
        
        // Create Order Summary
        ConnectApi.OrderSummaryInputRepresentation inputRepresentation = new ConnectApi.OrderSummaryInputRepresentation();
        inputRepresentation.orderId = ord.Id;
        ConnectApi.OrderSummaryOutputRepresentation outputRepresentation = ConnectApi.OrderSummaryCreation.createOrderSummary(inputRepresentation);
        System.debug('orderSummaryCreation---->'+outputRepresentation);
        
        OrderSummary OrdSum =[SELECT Id, OriginalOrderId, OrderNumber,OwnerId FROM OrderSummary WHERE OriginalOrderId =:ord.Id];
        ord.OrderReferenceNumber =OrdSum.OrderNumber ;
        update ord;
        
        Id[] OrdSumIds = new List<Id>();
        OrdSumIds.add(OrdSum.Id);
        
        Map<String,String> Headers = new Map<String, String>();
        Headers.put('Content-Type', 'application/json');
        String body = '{"Name":"Test"}';
        SingleRequestMock fakeResp = new SingleRequestMock(200,body,Headers);
        Test.setMock(HttpCalloutMock.class, fakeResp);
        
        Test.StartTest();
        
        UpdatePlatinumAttributesFromCDPBatch job = new UpdatePlatinumAttributesFromCDPBatch('Where Perf365Days__c = Null and PersonContactId != null Limit 1');
        Database.executeBatch(job);
        UpdatePlatinumAttributesFromCDPBatch job1= new UpdatePlatinumAttributesFromCDPBatch(2);
        
        Test.StopTest();
    }
}