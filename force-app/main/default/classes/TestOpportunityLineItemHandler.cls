@IsTest
public class TestOpportunityLineItemHandler {

    public static testMethod void TestcheckOppProductsBeforeInsert() {
        
        // Create Test Data
        OpportunityLineItem[] OpportunityProducts = new List<OpportunityLineItem>();
        Product2[] Products = new List<Product2>();
        PricebookEntry[] PriceBookEntries = new List<PricebookEntry>();
        
        // Create Products
        Product2 Prod1049DC = new Product2 (
            Name = '1049DC',
            ProductCode = '1049DC',
            Description = 'Tent Card Crystal Passion In House Use Case=10000',
            IsActive = True,
            Family = 'Regular'
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
            IsActive = True,
            Family = 'GSK'
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
        
        Account FMGAccount = new Account(
            LastName = 'Test FMG Account',
            PersonEmail = 'testfmgaccount@etggs.com',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            GSK__c = 'GSK'
        );
        Insert FMGAccount;
        
        Opportunity SpecialOrder = new Opportunity(
            Name = 'Test Opp',
            AccountId = FMGAccount.Id,
            CloseDate = System.today() + 30,
            StageName = 'New',
            Pricebook2Id = Test.getStandardPricebookId()
        );
        Insert SpecialOrder;
        
        // Create Opportunity Products
        OpportunityLineItem NormalProd1 = new OpportunityLineItem(
            OpportunityId = SpecialOrder.Id,
            Product2Id = Prod1049DC.Id,
            PriceBookEntryId = Prod1049DCStandardPrice.Id,
            Quantity = 2,
            UnitPrice = 100
        );
        System.debug('NormalProd1 - '+ NormalProd1);
        OpportunityProducts.add(NormalProd1);
        
        OpportunityLineItem NormalProd2 = new OpportunityLineItem(
            OpportunityId = SpecialOrder.Id,
            Product2Id = Prod1076DC.Id,
            PriceBookEntryId = Prod1076DCStandardPrice.Id,
            Quantity = 4,
            UnitPrice = 50
        );
        System.debug('NormalProd2 - ' + NormalProd2);
        OpportunityProducts.add(NormalProd2);
        Insert OpportunityProducts; 
        
        Map<String,String> Headers = new Map<String, String>();
        Headers.put('Content-Type', 'application/json');
        String body = '{"Name":"Test"}';
        SingleRequestMock fakeResp = new SingleRequestMock(200,body,Headers);
        // Invoke BatchInventoryCheckJob Class
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeResp);
        OpportunityLineItemHandler.checkOppProductsBeforeInsert(OpportunityProducts);
        Test.stopTest();
        
        
    }
}