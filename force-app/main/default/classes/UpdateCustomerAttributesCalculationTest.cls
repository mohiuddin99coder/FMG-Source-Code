@isTest
public class UpdateCustomerAttributesCalculationTest {
    
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
        UpdateCustomerAttributesSheduler testsche = new UpdateCustomerAttributesSheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('UpdateCustomerAttributesShedulerJob', sch, testsche );
        Test.stopTest();
    }
    public static testMethod void testUpdatePlatinumAttributesSheduler() {
        Test.StartTest();
        UpdatePlatinumAttributesSheduler testsche = new UpdatePlatinumAttributesSheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('UpdatePlatinumAttributesShedulerJob', sch, testsche );
        Test.stopTest();
    }
    public static testMethod void testUpdatePriorAttributesSheduler() {
        Test.StartTest();
        UpdatePriorAttributesSheduler testsche = new UpdatePriorAttributesSheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('UpdatePriorAttributesShedulerJob', sch, testsche );
        Test.stopTest();
    }
    
    @isTest static void testUpdateCustomerAttributesBatch() 
    {
        Test.startTest();
        UpdateCustomerAttributesBatch uc = new UpdateCustomerAttributesBatch();
        DataBase.executeBatch(uc);
        Test.stopTest();
    }
    @isTest static void testUpdatePlatinumFieldsBatch() {
        Test.startTest();
        UpdatePlatinumFieldsBatch uc = new UpdatePlatinumFieldsBatch();
        DataBase.executeBatch(uc);
        Test.stopTest();
    }
    @isTest static void testUpdatePriorAndLyTyAmtBatch() {
        Test.startTest();
        UpdatePriorAndLyTyAmtBatch uc = new UpdatePriorAndLyTyAmtBatch();
        DataBase.executeBatch(uc);
        Test.stopTest();
    }
    
}