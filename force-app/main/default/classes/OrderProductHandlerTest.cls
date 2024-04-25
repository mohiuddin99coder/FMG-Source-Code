@isTest
public class OrderProductHandlerTest {
    
 public class MockOrderdeliverygroupWebService implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"orderdeliverygroupId": "mock_order_deliverygroup_id"}');
            res.setStatusCode(200);
            return res;
        }
    }
    static testMethod void updateOrderDeliveryGroupTest(){
       String AccRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Trigger_Switch__c ts = new Trigger_Switch__c(Name='Order Product Trigger');
         ts.IsActive__c = true;
         insert ts;
        List<Product2> prodlist = new List<Product2>();
               Product2 p = new product2();
               p.Name = 'Test Product11';
               p.Description = 'Test Product11';
               p.productCode = 'WS3545-33';
               p.isActive = true;
        prodlist.add(p);
        
        Product2 p1 = new product2();
               p1.Name = 'Test Product12';
               p1.Description = 'Test Product12';
               p1.productCode = 'WS3545-33';
               p1.isActive = true;
        prodlist.add(p1);
        insert prodlist;
        
        pricebookEntry standardprice = new pricebookEntry();
        standardprice.pricebook2Id = Test.getStandardPricebookId();
        standardprice.Product2Id = p.Id;
        standardprice.UnitPrice = 120;
        standardprice.IsActive = true;
        standardprice.UseStandardPrice = false;
        insert standardprice;
        
           Account acc = new Account( 
               FirstName='Test',
               LastName = 'Acc101',
            //Rating = 'Hot',
            RecordTypeId = AccRecordTypeID,
            BillingCountry = 'United States',
            //Industry = 'Banking',
            //Phone = '9087654321',
            shippinglatitude=34.22573,
            ShippingLongitude=-115.94471
        );
       insert acc;
        
        Order order = new Order(
        AccountId = acc.Id,
         EffectiveDate = System.today(),
            Is_Special_Order__c = True,
            Status = 'Draft',
            BillingCountry = 'United States',
            BillingCity ='Test11',
            BillingPostalCode ='500001',
            BillingState ='Alaska',
            BillingStreet='Test Street',
            BillingPhoneNumber ='112211221',
            OrderedDate = System.now(),
            Order_Shipping_Method__c='BW',
            PriceBook2Id = Test.getStandardPricebookId()
        );
       insert order; 
        system.debug('OrderShippingMethod' + order.Order_Shipping_Method__c);
            
        OrderDeliveryMethod orderDeliveryMethod = new OrderDeliveryMethod(
           Name = 'BW',
            ProductId = p.Id
            );
        insert orderDeliveryMethod;
        
        //List<OrderDeliveryGroup> ODG =new List<OrderDeliveryGroup>();
        OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup(
        DeliverToName = 'Buyer USer',
        DeliverToStreet = 'test Street',
            DeliverToCity= 'Flower Mound',
             DeliverToState = 'Texas',
             DeliverToPostalCode ='75028',
           DeliverToCountry ='United States',
            OrderDeliveryMethodId = orderDeliveryMethod.Id,
            OrderId = order.Id
            //orderDeliveryGroup.add(ODG);
            );
         insert orderDeliveryGroup;
        System.debug(order.Id);
        
        List<OrderItem> orderItemlist = new List<OrderItem>();
        OrderItem lineitem = new OrderItem();
        lineitem.OrderId = order.Id;
        lineitem.Quantity = 20 ;
        lineitem.UnitPrice = 290;
        lineitem.product2id = p.Id;
        lineitem.Description = 'Test Descriprtion';
        lineitem.OrderDeliveryGroupId = orderDeliveryGroup.Id;
        lineitem.PricebookEntryId = standardprice.Id;
       //lineitem.Order_Shipping_Method__c = order.Order_Shipping_Method__c;
        
        orderItemlist.add(lineitem);
        insert orderItemlist;
        
        order.Status = 'Activated';
        update order;
        
       Test.startTest();
       Test.setMock(HttpCalloutMock.class, new MockOrderdeliverygroupWebService());
       OrderProductHandler.beforeInsertTrigger(orderItemlist);
        
        Test.stopTest();
    }
   static testMethod void updateOrderDeliveryGroupTest1(){
        String AccRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
         Trigger_Switch__c ts = new Trigger_Switch__c(Name='Order Product Trigger');
         ts.IsActive__c = true;
         insert ts;
        
        List<Product2> prodlist = new List<Product2>();
               Product2 p = new product2();
               p.Name = 'Test Product11';
               p.Description = 'Test Product11';
               p.productCode = 'WS3545-33';
               p.isActive = true;
        prodlist.add(p);
        
        Product2 p1 = new product2();
               p1.Name = 'Test Product12';
               p1.Description = 'Test Product12';
               p1.productCode = 'WS3545-33';
               p1.isActive = true;
        prodlist.add(p1);
        insert prodlist;
        
        pricebookEntry standardprice = new pricebookEntry();
        standardprice.pricebook2Id = Test.getStandardPricebookId();
        standardprice.Product2Id = p.Id;
        standardprice.UnitPrice = 120;
        standardprice.IsActive = true;
        standardprice.UseStandardPrice = false;
        insert standardprice;
        
         Account acc = new Account( 
             FirstName = 'Test',
             LastName = 'Acc101',
            //Rating = 'Hot',
            RecordTypeId = AccRecordTypeID,
            BillingCountry = 'United States',
            //Industry = 'Banking',
            //Phone = '9087654321',
            shippinglatitude=34.22573,
            ShippingLongitude=-115.94471,
            PersonEmail='test@gmail.com'       
       );
       insert acc;
        
         Order order = new Order(
        AccountId = acc.Id,
         EffectiveDate = System.today(),
            Is_Special_Order__c = True,
            Status = 'Draft',
            BillingCountryCode = 'US',
            BillingCity ='Test11',
            BillingPostalCode ='500001',
            BillingState ='Alaska',
            BillingStreet='Test Street',
            BillingPhoneNumber ='112211221',
             ShippingCountryCode = 'US',
            ShippingCity ='Test11',
            ShippingPostalCode ='500001',
            ShippingState ='Alaska',
            ShippingStreet='Test Street',
         //ShippingPhoneNumber ='112211221',
            OrderedDate = System.now(),
            Order_Shipping_Method__c='BW',
            PriceBook2Id = Test.getStandardPricebookId()
        );
       insert order; 
        
        OrderDeliveryMethod orderDeliveryMethod = new OrderDeliveryMethod(
           Name = 'BW',
            ProductId = p.Id
            );
        insert orderDeliveryMethod; 
        
        /*OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup(
        DeliverToName = 'Buyer USer',
        DeliverToStreet = 'test Street',
            DeliverToCity= 'Flower Mound',
             DeliverToState = 'Texas',
             DeliverToPostalCode ='75028',
           DeliverToCountry ='United States',
            OrderDeliveryMethodId = orderDeliveryMethod.Id,
            OrderId = order.Id
            //orderDeliveryGroup.add(ODG);
            );
         insert orderDeliveryGroup;*/
        
        
       List<OrderItem> orderItemlist = new List<OrderItem>();
        OrderItem lineitem = new OrderItem();
        lineitem.OrderId = order.Id;
        lineitem.Quantity = 20 ;
        lineitem.UnitPrice = 290;
        lineitem.product2id = p.Id;
        lineitem.Description = 'Test Descriprtion';
       // lineitem.OrderDeliveryGroupId = orderDeliveryGroup.Id;
        lineitem.PricebookEntryId = standardprice.Id;
        //lineitem.Order_Shipping_City__c= order.ShippingCity;
        //lineitem.Order_Shipping_Street__c = order.ShippingStreet;
        //lineitem.Order_Shipping_Country_Code__c = order.ShippingCountryCode;
        //lineitem.Order_Shipping_Zip_Postal_Code__c = order.ShippingPostalCode;
        //lineitem.Order_Shipping_Phone_number__c = acc.Phone;
        //lineitem.Order_Account_Email_Address__c = acc.PersonEmail;
        lineitem.Account__c= acc.Name;
        

        orderItemlist.add(lineitem);
        insert orderItemlist;
        
        

        order.Status = 'Activated';
        update order;
        
         Test.startTest();
       Test.setMock(HttpCalloutMock.class, new MockOrderdeliverygroupWebService());
       OrderProductHandler.beforeInsertTrigger(orderItemlist);
        
        Test.stopTest();
    }
}