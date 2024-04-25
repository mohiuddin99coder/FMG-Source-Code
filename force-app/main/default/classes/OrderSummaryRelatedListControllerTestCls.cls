@istest
public class OrderSummaryRelatedListControllerTestCls {
    static testMethod void OrderItemsummarytest1(){
        Test.startTest();
        
        
        
        Account acc = new Account(
            LastName = 'Test Acc',
            Rating = 'Hot',
            BillingCountry = 'United States',
            Industry = 'Banking',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            Phone = '9087654321'
            //rstk__IndexedAccountNumber__c='123',
            /*shippinglatitude=34.22573,
ShippingLongitude=-115.94471*/
        );
        insert acc;
        
        Case testCase = new Case();
        testCase.AccountId = acc.Id;
        testCase.Subject = 'Test Case';
        insert testCase;
        
        Order order = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'Draft',
            BillingCountry = 'United States',
            
            OrderedDate = System.now(),
            PriceBook2Id = Test.getStandardPricebookId()
        );
        insert order;
        
        
        List<OrderSummary> result = OrderSummaryRelatedListController.getOrderSummaries(testCase.Id); 
        String acresult = OrderSummaryRelatedListController.returnAccountId(testCase.Id);
        Test.stopTest();
    }
}