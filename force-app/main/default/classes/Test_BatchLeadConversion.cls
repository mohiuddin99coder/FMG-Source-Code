@isTest
public class Test_BatchLeadConversion {
    static testMethod void leadBatchTestMethod1(){
        Lead l = new Lead();
        l.FirstName='Test';
        l.LastName='Lead';
        l.Email='testlead@batch.com';
        l.leadsource='Catalog Request';
        l.CheckScheduleJobCompleted__c = false;
        l.Status = 'New';
        l.APT_Suite__c='123';
        insert l;
        
        l.Catalog_Offer_Code_Sent__c = 'TEST BATCH';
        l.Catalog_Status__c = 'Mailed';
        l.Estimated_In_Home_Date__c=  Date.newInstance(2024, 01, 3);
        update l;
        
        Test.startTest();
        BatchLeadConversion ba= new BatchLeadConversion();
        Id jobid= Database.executeBatch(ba,1);
        Test.stopTest();
         
    }
    
    static testMethod void leadBatchTestMethod2(){
        Test.startTest();
        Account acc = new Account();
        acc.LastName = 'Test Account';
        acc.PersonEmail = 'testleadaccEx@batch.com';
        acc.BillingCity = 'Wilmington';
        insert acc;
        
        Lead l = new Lead();
        l.FirstName='Test';
        l.LastName='Lead';
        l.Email='testleadaccEx@batch.com';
        l.leadsource='Catalog Request';
        l.CheckScheduleJobCompleted__c = false;
        l.Status = 'New';
        l.APT_Suite__c='123';
        insert l;
        
        l.Catalog_Offer_Code_Sent__c = 'TEST BATCH';
        l.Catalog_Status__c = 'Mailed';
        l.Estimated_In_Home_Date__c=  Date.newInstance(2024, 01, 3);
        update l;
        
        
        BatchLeadConversion ba= new BatchLeadConversion();
        Id jobid= Database.executeBatch(ba,1);
        Test.stopTest();
        //list<task> tsList = [select id,WhatId,Subject from task where WhatId=:acc.id and type='Catalog Mailed'];
        //system.assertEquals(tsList[0].Subject, 'Catalog Mailed');
        //

    }
}