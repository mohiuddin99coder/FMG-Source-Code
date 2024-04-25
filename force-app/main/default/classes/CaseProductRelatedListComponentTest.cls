@isTest
public class CaseProductRelatedListComponentTest {
    @isTest
    public static void testGetOrderSummaries() {
        // Test data setup
        Case testCase = new Case();
        testCase.Product_Sku__c = 'TestSKU';
        insert testCase;

        Product2 testProduct = new Product2();
        testProduct.StockKeepingUnit = 'TestSKU';
        testProduct.Name='Test Product';
        testProduct.IsActive = false;
        //testProduct.QOH__c = 10;
        insert testProduct;

        // Test the getOrderSummaries method
        Test.startTest();
        List<Product2> orderSummaries = CaseProductRelatedListComponent.getOrderSummaries(testCase.Id);
        Test.stopTest();

        // Assertion
        System.assertEquals(1, orderSummaries.size());
        Product2 orderSummary = orderSummaries[0];
        System.assertEquals('TestSKU', orderSummary.StockKeepingUnit);
    }
}