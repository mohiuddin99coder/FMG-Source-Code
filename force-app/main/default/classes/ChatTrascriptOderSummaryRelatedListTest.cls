@isTest
public class ChatTrascriptOderSummaryRelatedListTest {
    static testmethod void testGetOrderSummaries() {
        try{
            List<Product2> prodlist= new List<Product2>();
            Product2 p = new Product2();
            p.Name = 'Test Product199444';
            p.Description='Test Product199444';
            p.productCode = 'KS109-0064';
            p.isActive = false;
            prodlist.add(p);
            
            Product2 p1 = new Product2();
            p1.Name = 'Test Product199145';
            p1.Description='Test Product199145';
            p1.productCode = 'KS109-0067';
            p1.isActive = false;
            prodlist.add(p1);
            
            insert prodlist;
            
            PricebookEntry standardPrice = new PricebookEntry();
            standardPrice.Pricebook2Id = Test.getStandardPricebookId();
            standardPrice.Product2Id = p.Id;
            standardPrice.UnitPrice = 100;
            standardPrice.IsActive = true;
            standardPrice.UseStandardPrice = false;
            insert standardPrice ;
            
            Account acc = new Account(
                LastName = 'Test Acc1',
                Rating = 'Hot',
                BillingCountry = 'United States',
                Industry = 'Banking',
                Phone = '9087654321',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
                shippinglatitude=34.22573,
                ShippingLongitude=-115.94471
            );
            insert acc;
            
            Case testCase = new Case();
            testCase.AccountId = acc.Id;
            testCase.Subject = 'Test Case1';
            insert testCase;
            
            LiveChatVisitor testVisitor = new LiveChatVisitor();
            insert testVisitor;
            
            LiveChatTranscript testTranscript = new LiveChatTranscript();
            testTranscript.AccountId = acc.Id;
            testTranscript.CaseId = testCase.Id;
            testTranscript.LiveChatVisitorId=testVisitor.Id;
            insert testTranscript;
            
            // Call the method to test
            Test.startTest();
            List<OrderSummary> result = ChatTrascriptOderSummaryRelatedList.getOrderSummaries(testTranscript.Id); 
            String acresult = ChatTrascriptOderSummaryRelatedList.returnAccountId(testTranscript.Id);
            Test.stopTest();
            
        }catch(exception e){
            System.debug('Exception'+e);
            System.debug('Exception'+e.getStackTraceString());
        }
    }
}