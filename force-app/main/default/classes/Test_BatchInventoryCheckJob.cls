@isTest
public class Test_BatchInventoryCheckJob {
  

    static testmethod void inventoryBatchTestMethod1(){
        Test.startTest();
        Account acc = new Account();
        acc.LastName = 'TestLast';
        acc.PersonEmail	= 'test123876543w@gmail.com';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        insert acc;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Opportunity opp = new Opportunity();
        opp.name ='Test Oppo';
        opp.StageName = 'New';
        opp.CloseDate = date.today();
        opp.AccountId = acc.Id;
        opp.Pricebook2Id = pricebookId;
        opp.Shipping_Address__PostalCode__s= '20235';
        opp.Shipping_Address__City__s='Wellburn';
        opp.Shipping_Address__Street__s='14657 James St';
        opp.Shipping_Address__StateCode__s='AR';
        opp.Shipping_Address__CountryCode__s='US';
        opp.Billing_Address__City__s='Wellburn';
        opp.Billing_Address__Street__s='14657 James St';
        opp.Billing_Address__PostalCode__s='20235';
        opp.Billing_Address__CountryCode__s='US';
        opp.Billing_Address__StateCode__s='AR';
        
        insert opp;
        list<Product2> prdlist = new list<Product2>();
        //Create your product
        Product2 prod = new Product2(
            Name = 'TestProduct1',
            ProductCode = 'PRD1',
            isActive = true
        );
        insert prod;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        system.debug('pbEntry  -->'+pbEntry);
        
        //Create your product
        Product2 prod2 = new Product2(
            Name = 'TestProduct2',
            ProductCode = 'PRD2',
            isActive = true
        );
       // insert prod2;
        
        //Create your pricebook entry
        PricebookEntry pbEntry2 = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod2.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        //insert pbEntry2;
        
       Product2 prod3 = new Product2(
            Name = 'UPS',
            ProductCode = 'UPS',
            //ProductCode = 'BW',
            //ProductCode = 'EUR001',
            //StockKeepingUnit = 'EUR001',
            isActive = true,
            Family = 'Shipping'
        );
        insert prod3; 
        
        PricebookEntry pbEntryprod3 = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod3.Id,
            UnitPrice = 6.99,
            IsActive = true
        );
        insert pbEntryprod3;
        system.debug('pbEntry3  -->'+pbEntryprod3);
        
        
        
        /* Product2 prod3 = [Select Id , ProductCode from product2 where ProductCode = 'UPS' Limit 1];
         PricebookEntry pbEntryprod3 = [Select Id , Pricebook2Id ,Product2Id ,UnitPrice from PricebookEntry where Product2Id = :prod3.Id];*/
        
        system.debug('prod1 Shipping -->'+ prod3);
        system.debug('pbEntryprod1 Shipping -->'+ pbEntryprod3);
        list<OpportunityLineItem> olilist = new list<OpportunityLineItem>();
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 5,
            Product2Id = prod.Id,
            PricebookEntryId = pbEntry.Id,
            UnitPrice = 10
        );
        //olilist.add(oli);
        insert oli;
        
        
        
        OpportunityLineItem oli2 = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 1,
            Product2Id = prod2.Id,
            PricebookEntryId = pbEntry2.Id,
            UnitPrice = 6.99
            //Opp_Shipping_Product__c = true
            
            //Shipping_Product__c = True
        );
        //insert oli2;
        //olilist.add(oli2);
        
		OpportunityLineItem oli3 = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 1,
            Product2Id = prod3.Id,
            PricebookEntryId = pbEntryprod3.Id,
            UnitPrice = 6.99
            //Opp_Shipping_Product__c = true
            
            //Shipping_Product__c = True
        );
        //insert oli3;
        //olilist.add(oli3);
        //insert olilist;
        
        opp.HasShippingProduct__c = True;
        Update opp;
        
        system.debug('Shipping Product-->'+oli3);
        opp.Shipping_Cost__c = 2;
        opp.Shipping_Method__c= prod3.ProductCode;
        opp.AVA_SFCLOUD__AvaTax_Message__c='Sales Tax Current';
        opp.AVA_SFCLOUD__Sales_Tax__c=5;
        update opp;
        
        opp.StageName = 'Vendor Confirmation';
        update opp;
        
        system.debug('Shipping Product-->'+oli3);
        
        list<Task> t = [select id,subject,status,Result_Code__c from task where status='Open' and subject='PM Vendor Confirmation Details' and WhatId=:opp.id limit 1];
        system.debug('t PM vendor -->'+t);
       // t[0].Status = 'Completed';
        t[0].Result_Code__c = 'Vendor confirmed';
        update t;
        system.debug('t PM vendor -->'+t);
        
        if(opp.Stagename != 'In Review'){
            opp.stagename ='In Review';
            update opp;
        }
        
        
       // opp.AVA_SFCLOUD__AvaTax_Message__c='Sales Tax Current';
       // opp.AVA_SFCLOUD__Sales_Tax__c=5;
        //update opp;
        
        
        system.debug('opp -->'+opp);
        list<Task> t2 = [select id,subject,status,Result_Code__c from task where subject='Special Order Review by Platinum Team' and WhatId=:opp.id limit 1];
        t2[0].Status = 'Completed';
        t2[0].Result_Code__c = 'Customer Accepted';
        update t2;
        system.debug('t2 task-->'+t2);
        system.debug('opp -->'+opp);
        
        if(opp.Stagename != 'Quote'){
            opp.stagename ='Quote';
            update opp;
        }
        system.debug('opp -->'+opp);
        
        list<quote> qt = [select name,id,status from quote where OpportunityId=:opp.id];
        system.debug('qt -->'+qt);        
        qt[0].Status = 'Needs Review';
        update qt;
        
        list<task> t3 = [select id, status,subject from task where status='Open' and WhatId=:qt[0].id limit 1];
        system.debug('t Quote -->'+t3);
        t3[0].status = 'Completed';
        update t3;
        system.debug('t3-->'+t3);
        
        qt[0].Status = 'Accepted';
        update qt;
        system.debug('qt -->'+qt);
        system.debug('opp -->'+opp);
        list<Task> t4 = [select id,subject,status from task where status='Open' and subject='PM Place Order with Vendor' and WhatId=:opp.id limit 1];
        system.debug('t PM vendor -->'+t4);
        // t4[0].Status = 'Completed';
        t4[0].Result_Code__c = 'PO Placed';	
        update t4;
        system.debug('t PM vendor -->'+t4);
        
        if(opp.Stagename != 'Awaiting for Inventory'){
            opp.stagename ='Awaiting for Inventory';
            update opp;
        }
        system.debug('opp -->'+opp);
        
        
        Map<String,String> Headers = new Map<String, String>();
        Headers.put('Content-Type', 'application/json');
        String body = '{"Name":"Test"}';
        SingleRequestMock fakeResp = new SingleRequestMock(200,body,Headers);
        Test.setMock(HttpCalloutMock.class, fakeResp);
        BatchInventoryCheckJob job = new BatchInventoryCheckJob();
        Database.executeBatch(job);
        Test.stopTest();
    }
}