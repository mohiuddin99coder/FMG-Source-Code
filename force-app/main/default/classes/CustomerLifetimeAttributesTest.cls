@IsTest
public class CustomerLifetimeAttributesTest {
    @testSetup static void setup() {
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Person_Account').getRecordTypeId();
        Account acc = new Account();
        acc.Name ='Test Name';
        acc.RecordTypeId=recTypeId;
        insert acc;
        
        Order order = new Order();
        order.EffectiveDate=date.newInstance(2023, 04, 19);
        order.Status='Draft';
        order.AccountId=acc.id;
        insert order;
        
        Refund ref = new Refund();
        ref.Amount=100;
        ref.ProcessingMode='External';
        ref.Status='Processed';
        ref.Type='Referenced';
        ref.AccountId=acc.Id;
        insert ref;
    }
    public static testMethod void testUpdateCustomerAttributesSheduler() {
        Test.StartTest();
        CustomerLifetimeAttributesScheduler testsche = new CustomerLifetimeAttributesScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('CustomerLifetimeAttributesSchedulerJob', sch, testsche );
        Test.stopTest();
    }
    @isTest static void testUpdateCustomerLifetimeAttributesBatch() 
    {
        Test.startTest();
        UpdateCustomerLifetimeAttributesBatch uc = new UpdateCustomerLifetimeAttributesBatch();
        DataBase.executeBatch(uc);
        Test.stopTest();
    }
    
}