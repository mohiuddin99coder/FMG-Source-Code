@IsTest
public class TestOrderItemSummaryLocationUpdate {
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
    @IsTest(SeeAllData=True)
    public static void testLocationUpdate() {
        
        Id pricebookId = Test.getStandardPricebookId();
        // Create Product
        Product2 product = new Product2(
            Name = 'Test Product',
            StockKeepingUnit = 'SKU1236',
            IsActive = true
        );
        insert product;
        
        Product2 pr1 = new Product2(Name='Test Product1',
                                    StockKeepingUnit = 'SKU123456',
                                    IsActive = true);
        insert pr1;
        
        //List<Product2> giftProduct =[SELECT Id ,StockKeepingUnit,Name,IsActive From product2 WHERE Id='01tDK000006hEP2YAM'];
        //Product2 pr = new Product2(Name = giftproduct[0].Name,StockKeepingUnit =giftProduct[0].StockKeepingUnit ,IsActive = true,Id='01tDK000006hEP2YAM');
        
        /*Product2 Gift = new Product2();
        Gift.Name = 'Gift Prod';
        Gift.StockKeepingUnit = 'eGiftCertificate';
        Gift.IsActive = True;
        insert Gift;*/
        // Create Pricebook Entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = product.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbEntry;
       /* PricebookEntry pbEntry1 = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pr.Id,
            UnitPrice = 100,
            IsActive = true
        );
        //insert pbEntry1;*/
        PricebookEntry pbEntry2 = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = pr1.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbEntry2;
        // Create Account
        Account acc = new Account(
            LastName = 'Test Account',
            PersonEmail='Bhanu71230899@gmail.com',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );
        insert acc;
        System.debug('Account==>'+acc);
        // Create Order
        Order order = new Order(
            Status = 'Draft',
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Pricebook2Id = pricebookId,
            orderedDate = Date.today(),
            Name = 'Order 1001'
        );
        insert order;
        System.debug('order==>'+order);
        
        // Create OrderDeliveryMethod
        OrderDeliveryMethod orderDeliveryMethod = new OrderDeliveryMethod(
            Name = 'OrderDeliveryMethod Name'
        );
        insert orderDeliveryMethod;
        
        // Create OrderDeliveryGroup
        OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup(
            DeliverToName = 'orderDeliveryGroup Name',
            OrderDeliveryMethodId = orderDeliveryMethod.Id,
            OrderId = order.Id,
            Description = 'CartDeliveryGroup.Description',
            DesiredDeliveryDate = Date.today()
        );
        insert orderDeliveryGroup;
        System.debug('orderDeliveryGroup==>'+orderDeliveryGroup);
        
        // Create OrderItem
        OrderItem orderItem = new OrderItem(
            PricebookEntryId = pbEntry.Id,
            Product2Id = product.Id,
            OrderId = order.Id,
            Quantity = 5,
            Type = 'Order Product',
            UnitPrice = 150,
            ListPrice = 100,
            OrderDeliveryGroupId = orderDeliveryGroup.Id,
            TotalLineAmount = 250
        );
        insert orderItem;
        System.debug('orderItem==>'+orderItem);
        /*OrderItem orderItem1 = new OrderItem(
            PricebookEntryId = pbEntry1.Id,
            Product2Id = pr.Id,
            OrderId = order.Id,
            Quantity = 5,
            Type = 'Order Product',
            UnitPrice = 150,
            ListPrice = 100,
            OrderDeliveryGroupId = orderDeliveryGroup.Id,
            TotalLineAmount = 250
        );
        //insert orderItem1;
        System.debug('orderItem==>'+orderItem1);*/
        // Create an OrderItem for "Delivery Charge" type
        OrderItem orderItem2 = new OrderItem(
            PricebookEntryId = pbEntry2.Id,
            Product2Id = pr1.Id,
            OrderId = order.Id,
            Quantity = 1,
            Type = 'Delivery Charge',
            UnitPrice = 150,
            ListPrice = 100,
            OrderDeliveryGroupId = orderDeliveryGroup.Id,
            TotalLineAmount = 250
        );
        insert orderItem2;
        System.debug('orderItem==>'+orderItem2);
        
        
        OrderItem orderItemDeliveryCharge = new OrderItem(
            PricebookEntryId = pbEntry.Id,
            Product2Id = product.Id,
            OrderId = order.Id,
            Quantity = 1,
            UnitPrice = 10,
            ListPrice = 100,
            OrderDeliveryGroupId = orderDeliveryGroup.Id,
            TotalLineAmount = 10
        );
        insert orderItemDeliveryCharge;
        
        // Update Order Status
        order.Status = 'Activated';
        update order;
        System.debug('order==>'+order);
        
        
        // Mock OrderSummary creation
        ConnectApi.OrderSummaryInputRepresentation inputRepresentation = new ConnectApi.OrderSummaryInputRepresentation();
        inputRepresentation.orderId = order.Id;
        ConnectApi.OrderSummaryOutputRepresentation outputRepresentation = ConnectApi.OrderSummaryCreation.createOrderSummary(inputRepresentation);
        
        String[] OrdSumIdsList = new List<String>();
        
        System.debug('orderSummaryCreation==>'+outputRepresentation);
        OrdSumIdsList.add(outputRepresentation.orderSummaryId);
        
        
        Test.startTest();
        OrderItemSummaryLocationUpdate.locationUpdate(OrdSumIdsList);
        Test.setMock(HttpCalloutMock.class, new MockFulfillmentOrderWebService());
        Test.stopTest();
        
    }
}