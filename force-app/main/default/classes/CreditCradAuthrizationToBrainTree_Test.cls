@isTest
public class CreditCradAuthrizationToBrainTree_Test {
    
    public static String creditCardTestData() {
        // Create Test Data
        OpportunityLineItem[] OpportunityProducts = new List<OpportunityLineItem>();
        Product2[] Products = new List<Product2>();
        PricebookEntry[] PriceBookEntries = new List<PricebookEntry>();
        
        // Create Products
        Product2 Prod1049DC = new Product2 (
        	Name = '1049DC',
            ProductCode = '1049DC',
            Description = 'Tent Card Crystal Passion In House Use Case=10000',
            IsActive = True
            //Family = 'Regular'
        );
        Insert Prod1049DC;
        // Create PriceBookEntry
        PricebookEntry Prod1049DCStandardPrice = new PricebookEntry(
        	Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = Prod1049DC.Id,
            UnitPrice = 100,
            UseStandardPrice = False,
            IsActive = True
        );
        Insert Prod1049DCStandardPrice;
        
        Product2 Prod1076DC = new Product2 (
        	Name = '1076DC',
            ProductCode = '1076DC',
            Description = 'Cap Hanging 0.537 rd Molded Wht Case = 5000',
            IsActive = True
            //Family = 'Regular'
        );
        Insert Prod1076DC;
        // Create PriceBookEntry
        PricebookEntry Prod1076DCStandardPrice = new PricebookEntry(
        	Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = Prod1076DC.Id,
            UnitPrice = 100,
            UseStandardPrice = False,
            IsActive = True
        );
        Insert Prod1076DCStandardPrice;
        
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        
        // Create test account
        Account testAccount = new Account(LastName='Test harsha',RecordTypeId =recordTypeId,PersonEmail='harsha1234@gmail.com');
        insert testAccount;
        System.debug('testAccount: ' + testAccount);
        
        // Create test opportunity
        Opportunity testOpportunity = new Opportunity(
            Name='Test Opportunity',
            StageName='New',
            CloseDate=Date.today(),
            AccountId=testAccount.Id
        );
        insert testOpportunity;
        System.debug('testOpportunity: ' + testOpportunity);
        
        // Create Opportunity LineItems
        OpportunityLineItem NormalProd1 = new OpportunityLineItem(
        	OpportunityId = testOpportunity.Id,
            Product2Id = Prod1049DC.Id,
            PriceBookEntryId = Prod1049DCStandardPrice.Id,
            Quantity = 10,
            UnitPrice = 100
        );
        System.debug('NormalProd1 - '+ NormalProd1);
        OpportunityProducts.add(NormalProd1);
        
        OpportunityLineItem NormalProd2 = new OpportunityLineItem(
        	OpportunityId = testOpportunity.Id,
            Product2Id = Prod1076DC.Id,
            PriceBookEntryId = Prod1076DCStandardPrice.Id,
            Quantity = 20,
            UnitPrice = 50
        );
        System.debug('NormalProd2 - ' + NormalProd2);
        OpportunityProducts.add(NormalProd2);
        
        Insert OpportunityProducts;
        
        return testOpportunity.Id;
    }
    
    @isTest
    static void testAuthrizeCreditCardInfo() {
        
        String OppId = creditCardTestData();
        
        // Test data
        Map<String, Object> creditCardData = new Map<String, Object>();
        creditCardData.put('cardholderName', 'John Doe');
        creditCardData.put('cardNumber', '4111111111111111');
        creditCardData.put('expirationMonth', '12');
        creditCardData.put('expirationYear', '2025');
        creditCardData.put('cvv', '123');
        creditCardData.put('advanceAmount', '100.00');
        creditCardData.put('recordId', OppId);
        
        // HTTP callout Data
        Map<String,String> Headers = new Map<String, String>();
        Headers.put('Content-Type', 'application/json');
        String tokenizeBody = '{"data":{"tokenizeCreditCard":{"paymentMethod":{"id":"tokencc_bh_bfp2jc_dm8ytm_tvr3kc_wjh4pm_3j7","details":{"brandCode":"VISA","last4":"1111","expirationMonth":"02","expirationYear":"24"}}}},"extensions":{"requestId":"a5d7305e-e2e1-4626-9d3b-c63da51f63d8"}}';
        //String chargeBody = '{"data":{"chargePaymentMethod":{"transaction":{"id":"dHJhbnNhY3Rpb25fNGN0ZGY2MWo","status":"SUBMITTED_FOR_SETTLEMENT"}},"extensions":{"requestId":"a1e9c0fe-71e0-4c82-b3ac-96de23dd3062}}';
        SingleRequestMock fakeTokenizeCreditCardResp = new SingleRequestMock(200,tokenizeBody,Headers);
   
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeTokenizeCreditCardResp);
        
        CreditCradAuthrizationToBrainTree.ResponseWrapper result = CreditCradAuthrizationToBrainTree.authrizeCreditCardInfo(creditCardData);

        system.debug('result'+ result);
        Test.stopTest();

       // System.assertEquals('Success', result.status);

    }
    
    
    @isTest
    static void testAuthrizeCreditCardInfoError1() {
        
        String OppId = creditCardTestData();
        
        // Test data
        Map<String, Object> creditCardData = new Map<String, Object>();
        creditCardData.put('cardholderName', 'John D1oe');
        creditCardData.put('cardNumber', '41111111111');
        creditCardData.put('expirationMonth', '12');
        creditCardData.put('expirationYear', '2023');
        creditCardData.put('cvv', '13');
        creditCardData.put('advanceAmount', '100.00');
        creditCardData.put('recordId',OppId);
        
        // HTTP callout Data
        Map<String,String> Headers = new Map<String, String>();
        Headers.put('Content-Type', 'application/json');
        String tokenizeBody = '{"errors": [{"message": "Validation error of type FieldUndefined: Field \'number\' in type \'PaymentMethodDetails\' is undefined @ \'tokenizeCreditCard/paymentMethod/details/number\'","locations": [{"line": 6,"column": 9}]}],"extensions": {"requestId": "dc95de24-9fbb-44d1-9065-be0c94260edd"}}';
        SingleRequestMock fakeTokenizeCreditCardResp = new SingleRequestMock(200,tokenizeBody,Headers);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeTokenizeCreditCardResp);
        CreditCradAuthrizationToBrainTree.ResponseWrapper result = CreditCradAuthrizationToBrainTree.authrizeCreditCardInfo(creditCardData);
        system.debug('result'+ result);
        Test.stopTest();
    }
    
     @isTest
    static void testAuthrizeCreditCardInfoError2() {
        
        String OppId = creditCardTestData();
        
        // Test data
        Map<String, Object> creditCardData = new Map<String, Object>();
        creditCardData.put('cardholderName', 'John Doe');
        creditCardData.put('cardNumber', '4111111111111111');
        creditCardData.put('expirationMonth', '12');
        creditCardData.put('expirationYear', '2024');
        creditCardData.put('cvv', '13');
        creditCardData.put('advanceAmount', '100.00');
        creditCardData.put('recordId',OppId);
        
        // HTTP callout Data
        Map<String,String> Headers = new Map<String, String>();
        Headers.put('Content-Type', 'application/json');
        String tokenizeBody = '{"errors": [{"message": "Validation error of type FieldUndefined: Field \'number\' in type \'PaymentMethodDetails\' is undefined @ \'tokenizeCreditCard/paymentMethod/details/number\'","locations": [{"line": 6,"column": 9}]}],"extensions": {"requestId": "dc95de24-9fbb-44d1-9065-be0c94260edd"}}';
        SingleRequestMock fakeTokenizeCreditCardResp = new SingleRequestMock(204,tokenizeBody,Headers);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeTokenizeCreditCardResp);
        CreditCradAuthrizationToBrainTree.ResponseWrapper result = CreditCradAuthrizationToBrainTree.authrizeCreditCardInfo(creditCardData);
        system.debug('result'+ result);
        Test.stopTest();
    }
    
    @isTest
    static void testAuthrizeCreditCardInfoError3() {
        
        String OppId = creditCardTestData();
        
        // Test data
        Map<String, Object> creditCardData = new Map<String, Object>();
        creditCardData.put('cardholderName', 'John Doe');
        creditCardData.put('cardNumber', '4111111111111111');
        creditCardData.put('expirationMonth', '12');
        creditCardData.put('expirationYear', '2024');
        creditCardData.put('cvv', '13');
        creditCardData.put('advanceAmount', '100.00');
        creditCardData.put('recordId',OppId);
        
        // HTTP callout Data
        Map<String,String> Headers = new Map<String, String>();
        Headers.put('Content-Type', 'application/json');
        String tokenizeBody = '{"data":{"tokenizeCreditCard":{"paymentMethod":{"id":"tokencc_bh_bfp2jc_dm8ytm_tvr3kc_wjh4pm_3j7","details":{"brandCode":"VISA","last4":"1111","expirationMonth":"02","expirationYear":"24"}}}},"extensions":{"requestId":"a5d7305e-e2e1-4626-9d3b-c63da51f63d8"},"errors": [{"message": "Validation error of type FieldUndefined: Field \'number\' in type \'PaymentMethodDetails\' is undefined @ \'tokenizeCreditCard/paymentMethod/details/number\'","locations": [{"line": 6,"column": 9}]}],"extensions": {"requestId": "dc95de24-9fbb-44d1-9065-be0c94260edd"}}';
        SingleRequestMock fakeTokenizeCreditCardResp = new SingleRequestMock(200,tokenizeBody,Headers);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeTokenizeCreditCardResp);
        CreditCradAuthrizationToBrainTree.ResponseWrapper result = CreditCradAuthrizationToBrainTree.authrizeCreditCardInfo(creditCardData);
        system.debug('result'+ result);
        Test.stopTest();
    }

}