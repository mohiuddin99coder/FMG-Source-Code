/**
 * Created by Adam-Hotmail on 6/5/2023.
 */
@IsTest
public with sharing class FMGRSAPI_Orders_ServiceTest {



    @IsTest
    static void firstOrderTest() {
        FMGRSAPI_Orders_Service testService = new FMGRSAPI_Orders_Service();
        FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock testData = new FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock();
        testService.dataAccess = (FMGRSAPI_Orders_Service_DataInterface)testData;

        Map<Id,Account> accounts = new Map<Id,Account>();

        Account newAccount;
        // Is First Order
        newAccount = (Account)json.deserializeStrict('{"Id":"001000000000001AAA","Orders":{"totalSize":1,"done":true,"records":[{"Id":"801000000000001AAA","OrderReferenceNumber":"Order1","EffectiveDate": "2024-03-29"}]},"rstk__Sales_Orders__pr":{"totalSize":1,"done":true,"records":[{"Id":"a6Y000000000001EAA","rstk__sohdr_order__c":"Order1","rstk__sohdr_dateadded__c": "2024-03-29"}]}}',Account.class);
        accounts.put(newAccount.Id,newAccount);
        //Rootstock is first order
        newAccount = (Account)json.deserializeStrict('{"Id":"001000000000003AAA","Orders":{"totalSize":1,"done":true,"records":[{"Id":"801000000000002AAA","OrderReferenceNumber":"Order3","EffectiveDate": "2024-03-29"}]},"rstk__Sales_Orders__pr":{"totalSize":1,"done":true,"records":[{"Id":"a6Y000000000002EAA","rstk__sohdr_order__c":"Order2","rstk__sohdr_dateadded__c": "2024-03-28"}]}}',Account.class);
        accounts.put(newAccount.Id,newAccount);

        //OMS is first order
        newAccount = (Account)json.deserializeStrict('{"Id":"001000000000004AAA","Orders":{"totalSize":1,"done":true,"records":[{"Id":"801000000000003AAA","OrderReferenceNumber":"Order5","EffectiveDate": "2024-03-28"}]},"rstk__Sales_Orders__pr":{"totalSize":1,"done":true,"records":[{"Id":"a6Y000000000003EAA","rstk__sohdr_order__c":"Order4","rstk__sohdr_dateadded__c": "2024-03-29"}]}}',Account.class);
        accounts.put(newAccount.Id,newAccount);

        //No OMS Orders
        newAccount = (Account)json.deserializeStrict('{"Id":"001000000000005AAA","Orders":{"totalSize":0,"done":true,"records":[]},"rstk__Sales_Orders__pr":{"totalSize":1,"done":true,"records":[{"Id":"a6Y000000000004EAA","rstk__sohdr_order__c":"Order6","rstk__sohdr_dateadded__c": "2024-03-29"}]}}',Account.class);
        accounts.put(newAccount.Id,newAccount);

        newAccount = (Account)json.deserializeStrict('{"Id":"001DC00000hiYU3YAM","Orders":{"totalSize":1,"done":true,"records":[{"Id":"801DC000000weGRYAY","OrderReferenceNumber":"D000013113","EffectiveDate": "2024-04-05"}]},"rstk__Sales_Orders__pr":{"totalSize":1,"done":true,"records":[{"Id":"a6YDC000000DBab2AG","rstk__sohdr_order__c":"D000013113","rstk__sohdr_dateadded__c": "2024-04-05"}]}}',Account.class);
        accounts.put(newAccount.Id,newAccount);


        testData.getAccountInfo_results = accounts.values();


        System.debug('****************************** Accounts *****************************');
        System.debug(JSON.serializePretty(accounts));



        Test.startTest();
        List<FMGRSAPI_Orders_Service.generateOrderBatch_RawAccountInformation> results = testService.generateOrderBatch_GetAccountInformation(accounts.keySet());
        Test.stopTest();

        System.debug('****************************** Results *****************************');
        System.debug(JSON.serializePretty(results));

        Map<String,FMGRSAPI_Orders_Service.generateOrderBatch_RawAccountInformation> resultsCheck = new Map<String,FMGRSAPI_Orders_Service.generateOrderBatch_RawAccountInformation>();
        for(FMGRSAPI_Orders_Service.generateOrderBatch_RawAccountInformation rec:results){
            resultsCheck.put(rec.Id,rec);
        }

        system.assertEquals(accounts.get('001000000000001AAA').rstk__Sales_Orders__pr[0].Id,resultsCheck.get('001000000000001AAA').FirstOrder);
        system.assertEquals(accounts.get('001000000000003AAA').rstk__Sales_Orders__pr[0].Id,resultsCheck.get('001000000000003AAA').FirstOrder);
        system.assertNotEquals(accounts.get('001000000000004AAA').rstk__Sales_Orders__pr[0].Id,resultsCheck.get('001000000000004AAA').FirstOrder);
        system.assertEquals(accounts.get('001000000000005AAA').rstk__Sales_Orders__pr[0].Id,resultsCheck.get('001000000000005AAA').FirstOrder);
        system.assertEquals(accounts.get('001DC00000hiYU3YAM').rstk__Sales_Orders__pr[0].Id,resultsCheck.get('001DC00000hiYU3YAM').FirstOrder);

    }

    @IsTest
    static void generateOrderBatch(){
        FMGRSAPI_Orders_Service testService = new FMGRSAPI_Orders_Service();
        FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock testData = new FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock();
        testService.dataAccess = (FMGRSAPI_Orders_Service_DataInterface)testData;

        List<Account> accounts = new List<Account>();
        List<FMGRSAPI_Orders_Service.generateOrderBatch_RawOrderHeader> orders = new List<FMGRSAPI_Orders_Service.generateOrderBatch_RawOrderHeader>();

        testData.getAccountInfo_results = accounts;

        accounts.add((Account)json.deserializeStrict('{"Id":"001000000000002AAA","Orders":{"totalSize":1,"done":true,"records":[{"Id":"801Dn0000041ea9IAA","OrderReferenceNumber":"Order1", "EffectiveDate": "2024-03-29"}]},"rstk__Sales_Orders__pr":{"totalSize":1,"done":true,"records":[{"Id":"a6Y000000000001EAA","rstk__sohdr_order__c":"Order1","rstk__sohdr_dateadded__c": "2024-03-29"}]}}',Account.class));
        accounts.add((Account)json.deserializeStrict('{"Id":"001DC00000hiYU3YAM","Orders":{"totalSize":1,"done":true,"records":[{"Id":"801DC000000weGRYAY","OrderReferenceNumber":"D000013113","EffectiveDate": "2024-04-05"}]},"rstk__Sales_Orders__pr":{"totalSize":1,"done":true,"records":[{"Id":"a6YDC000000DBab2AG","rstk__sohdr_order__c":"D000013113","rstk__sohdr_dateadded__c": "2024-04-05"}]}}',Account.class));
        testService.UnitTestGenerateOrderBatch_GetOrders = orders;

        orders.add((FMGRSAPI_Orders_Service.generateOrderBatch_RawOrderHeader)json.deserializeStrict('{"Name":"Order1","Id":"a6Y000000000001EAA","AccountId":"001000000000002AAA"}',FMGRSAPI_Orders_Service.generateOrderBatch_RawOrderHeader.class));
        orders.add((FMGRSAPI_Orders_Service.generateOrderBatch_RawOrderHeader)json.deserializeStrict('{"Name":"Order2","Id":"a6Y000000000003EAA","AccountId":"001000000000002AAA"}',FMGRSAPI_Orders_Service.generateOrderBatch_RawOrderHeader.class));
        orders.add((FMGRSAPI_Orders_Service.generateOrderBatch_RawOrderHeader)json.deserializeStrict('{"Name":"Order3","Id":"a6Y000000000004EAA","AccountId":"001000000000002AAA"}',FMGRSAPI_Orders_Service.generateOrderBatch_RawOrderHeader.class));
        orders.add((FMGRSAPI_Orders_Service.generateOrderBatch_RawOrderHeader)json.deserializeStrict('{"Name":"Order4","Id":"a6Y000000000005EAA","AccountId":"001000000000002AAA"}',FMGRSAPI_Orders_Service.generateOrderBatch_RawOrderHeader.class));
        orders.add((FMGRSAPI_Orders_Service.generateOrderBatch_RawOrderHeader)json.deserializeStrict('{"Name":"Order4","Id":"a6Y000000000005EAA","AccountId":"001000000000002AAA"}',FMGRSAPI_Orders_Service.generateOrderBatch_RawOrderHeader.class));
        orders.add((FMGRSAPI_Orders_Service.generateOrderBatch_RawOrderHeader)json.deserializeStrict('{"Name":"D000013113","Id":"a6YDC000000DBab2AG","AccountId":"001DC00000hiYU3YAM"}',FMGRSAPI_Orders_Service.generateOrderBatch_RawOrderHeader.class));


        System.debug('****************************** Accounts *****************************');
        System.debug(JSON.serializePretty(accounts));
        System.debug('****************************** Orders  *****************************');
        System.debug(JSON.serializePretty(testService.UnitTestGenerateOrderBatch_GetOrders));


        Test.startTest();
        Integer batchId = testService.generateOrderBatch(100);
        Test.stopTest();




        for(fmgsohdrext__c orderInfo:testService.generateOrderBatch_NewHeaders){

            System.debug('Order: ' +  orderInfo.Name);
            System.debug(JSON.serializePretty(orderInfo));
            if(orderInfo.Name == 'Order1' || orderInfo.Name == 'D000013113'){
                System.assertEquals(orderInfo.IsFirstOrder__c,true,'Order Name: '+ orderInfo.Name + ':' + FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType,orderInfo.Name));
            } else {
                System.assertEquals(orderInfo.IsFirstOrder__c,false,'Order Name: '+ orderInfo.Name + ':' + FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType,orderInfo.Name));
            }
            System.assertEquals(orderInfo.batchId__c,batchId);
        }

        // generateOrderBatch_NewHeaders

    }





    @IsTest
    static void addNewSyDataPick(){
        FMGRSAPI_Orders_Service testService = new FMGRSAPI_Orders_Service();


        // ************************** orderEvent **********************************
        FMGRSAPI_Orders_Service.ProcessOrderEvent orderEvent = new FMGRSAPI_Orders_Service.ProcessOrderEvent();
        orderEvent.SalesforceOrderId = FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType,'Order1');
        orderEvent.OrderEvent = 'Picked';
        orderEvent.EventTime=Datetime.newInstance(2023,6,5);


        // ************************** sohdrByIds **********************************
        Map<Id,FMGRSAPI_Orders_Service.ProcessOrders_RawOrder> sohdrByIds = new Map<Id, FMGRSAPI_Orders_Service.ProcessOrders_RawOrder>();
        FMGRSAPI_Orders_Service.ProcessOrders_RawOrder order = new FMGRSAPI_Orders_Service.ProcessOrders_RawOrder();
        order.Id = FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType,'Order1');
        order.Batch = new fmgsohdrext__c();
        order.Batch.Id = FMG_TestUtility.getFakeId(fmgsohdrext__c.SObjectType,'Order1Batch');
        order.orderLines = new List<FMGRSAPI_Orders_Service.ProcessOrders_RawOrderLine>();
        sohdrByIds.put(order.Id,order);

        // ************************** sohdrByIds **********************************
        FMGRSAPI_Orders_Service.ProcessOrders_RawOrderLine orderLine = new FMGRSAPI_Orders_Service.ProcessOrders_RawOrderLine();
        orderLine.Id = FMG_TestUtility.getFakeId(rstk__soline__c.SObjectType,'Order1Lime1');
        orderLine.LocationId = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'Loc1');
        orderLine.LocationNumber='C1';
        orderLine.QtyAvailableAndPick=10;
        orderLine.ToPack=0;
        orderLine.ToShip=0;
        order.orderLines.add(orderLine);


        Map<Id,fmgsohdrext__c> updatefmgsohdr = new Map<Id, fmgsohdrext__c>();
        Map<Id,rstk__sydata__c> pickEvents = new Map<Id, rstk__sydata__c>();


        Test.startTest();
        testService.addNewSyDataPick(orderEvent,sohdrByIds,updatefmgsohdr,pickEvents,true,false);
        Test.stopTest();


        System.debug('****************************************************');
        System.debug(JSON.serializePretty(pickEvents));
        System.debug('****************************************************');
        System.debug(JSON.serializePretty(updatefmgsohdr));

        System.assertEquals(pickEvents.size(),1);
        System.assertEquals(updatefmgsohdr.size(),1);
        System.assertNotEquals(updatefmgsohdr.values()[0].Time_of_Pick__c,null);
        System.assertEquals(updatefmgsohdr.values()[0].Time_of_Pack__c,null);
        rstk__sydata__c data = pickEvents.values()[0];


        System.assertEquals(data.rstk__sydata_txnqty__c,10);
        System.assertEquals('Sales Order Pick(Issue)',data.rstk__sydata_txntype__c);
        System.assertNotEquals('Sales Order Pack',data.rstk__sydata_txntype__c);
        System.assertNotEquals('Sales Order Shipment',data.rstk__sydata_txntype__c);
        System.assertEquals(data.rstk__sydata_soline__c,FMG_TestUtility.getFakeId(rstk__soline__c.SObjectType,'Order1Lime1'));
        System.assertEquals(data.rstk__sydata_sylocid__c,FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'Loc1'));
        System.assertEquals(data.rstk__sydata_locnum__c,'C1');
        System.assertEquals(data.rstk__sydata_backgroundprocessing__c,true);

    }
    @IsTest
    static void addNewSyDataPickPack(){
        FMGRSAPI_Orders_Service testService = new FMGRSAPI_Orders_Service();


        // ************************** orderEvent **********************************
        FMGRSAPI_Orders_Service.ProcessOrderEvent orderEvent = new FMGRSAPI_Orders_Service.ProcessOrderEvent();
        orderEvent.SalesforceOrderId = FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType,'Order1');
        orderEvent.OrderEvent = 'Picked';
        orderEvent.EventTime=Datetime.newInstance(2023,6,5);


        // ************************** sohdrByIds **********************************
        Map<Id,FMGRSAPI_Orders_Service.ProcessOrders_RawOrder> sohdrByIds = new Map<Id, FMGRSAPI_Orders_Service.ProcessOrders_RawOrder>();
        FMGRSAPI_Orders_Service.ProcessOrders_RawOrder order = new FMGRSAPI_Orders_Service.ProcessOrders_RawOrder();
        order.Id = FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType,'Order1');
        order.Batch = new fmgsohdrext__c();
        order.Batch.Id = FMG_TestUtility.getFakeId(fmgsohdrext__c.SObjectType,'Order1Batch');
        order.orderLines = new List<FMGRSAPI_Orders_Service.ProcessOrders_RawOrderLine>();
        sohdrByIds.put(order.Id,order);

        // ************************** sohdrByIds **********************************
        FMGRSAPI_Orders_Service.ProcessOrders_RawOrderLine orderLine = new FMGRSAPI_Orders_Service.ProcessOrders_RawOrderLine();
        orderLine.Id = FMG_TestUtility.getFakeId(rstk__soline__c.SObjectType,'Order1Lime1');
        orderLine.LocationId = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'Loc1');
        orderLine.LocationNumber='C1';
        orderLine.QtyAvailableAndPick=10;
        orderLine.ToPack=0;
        orderLine.ToShip=0;
        order.orderLines.add(orderLine);


        Map<Id,fmgsohdrext__c> updatefmgsohdr = new Map<Id, fmgsohdrext__c>();
        Map<Id,rstk__sydata__c> pickEvents = new Map<Id, rstk__sydata__c>();


        Test.startTest();
        testService.addNewSyDataPick(orderEvent,sohdrByIds,updatefmgsohdr,pickEvents,true,true);
        Test.stopTest();


        System.debug('****************************************************');
        System.debug(JSON.serializePretty(pickEvents));
        System.debug('****************************************************');
        System.debug(JSON.serializePretty(updatefmgsohdr));

        System.assertEquals(pickEvents.size(),1);
        System.assertEquals(updatefmgsohdr.size(),1);
        System.assertNotEquals(updatefmgsohdr.values()[0].Time_of_Pick__c,null);
        System.assertEquals(updatefmgsohdr.values()[0].Time_of_Pack__c,null);
        rstk__sydata__c data = pickEvents.values()[0];


        System.assertEquals(data.rstk__sydata_txnqty__c,10);
        System.assertEquals('Sales Order Pick-Pack',data.rstk__sydata_txntype__c);
        System.assertNotEquals('Sales Order Pack',data.rstk__sydata_txntype__c);
        System.assertNotEquals('Sales Order Shipment',data.rstk__sydata_txntype__c);
        System.assertEquals(data.rstk__sydata_soline__c,FMG_TestUtility.getFakeId(rstk__soline__c.SObjectType,'Order1Lime1'));
        System.assertEquals(data.rstk__sydata_sylocid__c,FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'Loc1'));
        System.assertEquals(data.rstk__sydata_locnum__c,'C1');
        System.assertEquals(data.rstk__sydata_backgroundprocessing__c,true);

    }

    @IsTest
    static void addNewSyDataPack(){
        FMGRSAPI_Orders_Service testService = new FMGRSAPI_Orders_Service();


        // ************************** orderEvent **********************************
        FMGRSAPI_Orders_Service.ProcessOrderEvent orderEvent = new FMGRSAPI_Orders_Service.ProcessOrderEvent();
        orderEvent.SalesforceOrderId = FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType,'Order1');
        orderEvent.OrderEvent = 'Packed';
        orderEvent.EventTime=Datetime.newInstance(2023,6,5);


        // ************************** sohdrByIds **********************************
        Map<Id,FMGRSAPI_Orders_Service.ProcessOrders_RawOrder> sohdrByIds = new Map<Id, FMGRSAPI_Orders_Service.ProcessOrders_RawOrder>();
        FMGRSAPI_Orders_Service.ProcessOrders_RawOrder order = new FMGRSAPI_Orders_Service.ProcessOrders_RawOrder();
        order.Id = FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType,'Order1');
        order.Batch = new fmgsohdrext__c();
        order.Batch.Id = FMG_TestUtility.getFakeId(fmgsohdrext__c.SObjectType,'Order1Batch');
        order.orderLines = new List<FMGRSAPI_Orders_Service.ProcessOrders_RawOrderLine>();
        sohdrByIds.put(order.Id,order);

        // ************************** sohdrByIds **********************************
        FMGRSAPI_Orders_Service.ProcessOrders_RawOrderLine orderLine = new FMGRSAPI_Orders_Service.ProcessOrders_RawOrderLine();
        orderLine.Id = FMG_TestUtility.getFakeId(rstk__soline__c.SObjectType,'Order1Lime1');
        orderLine.LocationId = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'Loc1');
        orderLine.LocationNumber='C1';
        orderLine.QtyAvailableAndPick=10;
        orderLine.ToPack=0;
        orderLine.ToShip=0;
        order.orderLines.add(orderLine);


        Map<Id,fmgsohdrext__c> updatefmgsohdr = new Map<Id, fmgsohdrext__c>();
        Map<Id,rstk__sydata__c> packEvents = new Map<Id, rstk__sydata__c>();


        Test.startTest();
        testService.addNewSyDataPack(orderEvent,sohdrByIds,updatefmgsohdr,packEvents,true);
        Test.stopTest();


        System.debug('****************************************************');
        System.debug(JSON.serializePretty(packEvents));
        System.debug('****************************************************');
        System.debug(JSON.serializePretty(updatefmgsohdr));

        System.assertEquals(packEvents.size(),1);
        System.assertEquals(updatefmgsohdr.size(),1);
        System.assertEquals(updatefmgsohdr.values()[0].Time_of_Pick__c,null);
        System.assertNotEquals(updatefmgsohdr.values()[0].Time_of_Pack__c,null);
        rstk__sydata__c data = packEvents.values()[0];

        System.assertNotEquals('Sales Order Pick(Issue)',data.rstk__sydata_txntype__c);
        System.assertEquals('Sales Order Pack',data.rstk__sydata_txntype__c);
        System.assertNotEquals('Sales Order Shipment',data.rstk__sydata_txntype__c);
        System.assertEquals(data.rstk__sydata_soline__c,FMG_TestUtility.getFakeId(rstk__soline__c.SObjectType,'Order1Lime1'));
        System.assertEquals(data.rstk__sydata_backgroundprocessing__c,true);
    }

    @IsTest
    static void addNewSyDataShip(){
        FMGRSAPI_Orders_Service testService = new FMGRSAPI_Orders_Service();


        // ************************** orderEvent **********************************
        FMGRSAPI_Orders_Service.ProcessOrderEvent orderEvent = new FMGRSAPI_Orders_Service.ProcessOrderEvent();
        orderEvent.SalesforceOrderId = FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType,'Order1');
        orderEvent.OrderEvent = 'Shipped';
        orderEvent.EventTime=Datetime.newInstance(2023,6,5);


        // ************************** sohdrByIds **********************************
        Map<Id,FMGRSAPI_Orders_Service.ProcessOrders_RawOrder> sohdrByIds = new Map<Id, FMGRSAPI_Orders_Service.ProcessOrders_RawOrder>();
        FMGRSAPI_Orders_Service.ProcessOrders_RawOrder order = new FMGRSAPI_Orders_Service.ProcessOrders_RawOrder();
        order.Id = FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType,'Order1');
        order.Batch = new fmgsohdrext__c();
        order.Batch.Id = FMG_TestUtility.getFakeId(fmgsohdrext__c.SObjectType,'Order1Batch');
        order.orderLines = new List<FMGRSAPI_Orders_Service.ProcessOrders_RawOrderLine>();
        order.ShippingClosed = new Map<Id, Boolean>();
        order.ShippingClosed.put(FMG_TestUtility.getFakeId(rstk__soship__c.SObjectType,'Order1ShipC'),false);

        sohdrByIds.put(order.Id,order);

        // ************************** sohdrByIds **********************************
        FMGRSAPI_Orders_Service.ProcessOrders_RawOrderLine orderLine = new FMGRSAPI_Orders_Service.ProcessOrders_RawOrderLine();
        orderLine.Id = FMG_TestUtility.getFakeId(rstk__soline__c.SObjectType,'Order1Lime1');
        orderLine.LocationId = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'Loc1');
        orderLine.LocationNumber='C1';
        orderLine.QtyAvailableAndPick=10;
        orderLine.ToPack=0;
        orderLine.ToShip=0;
        order.orderLines.add(orderLine);


        Map<Id,fmgsohdrext__c> updatefmgsohdr = new Map<Id, fmgsohdrext__c>();
        Map<Id,rstk__sydata__c> shipEvents = new Map<Id, rstk__sydata__c>();


        Test.startTest();
        testService.addNewSyDataship(orderEvent,sohdrByIds,updatefmgsohdr,shipEvents,true,false);
        Test.stopTest();


        System.debug('****************************************************');
        System.debug(JSON.serializePretty(shipEvents));
        System.debug('****************************************************');
        System.debug(JSON.serializePretty(updatefmgsohdr));

        System.assertEquals(shipEvents.size(),1);
        System.assertEquals(updatefmgsohdr.size(),1);
        System.assertEquals(updatefmgsohdr.values()[0].Time_of_Pick__c,null);
        System.assertEquals(updatefmgsohdr.values()[0].Time_of_Pack__c,null);
        rstk__sydata__c data = shipEvents.values()[0];

        System.assertNotEquals('Sales Order Pick(Issue)',data.rstk__sydata_txntype__c);
        System.assertNotEquals('Sales Order Pack',data.rstk__sydata_txntype__c);
        System.assertEquals('Sales Order Shipment',data.rstk__sydata_txntype__c);
        System.assertEquals(false,data.rstk__sydata_spawninv__c);
        System.assertEquals(data.rstk__sydata_soship__c,FMG_TestUtility.getFakeId(rstk__soship__c.SObjectType,'Order1ShipC'));
        System.assertEquals(data.rstk__sydata_backgroundprocessing__c,true);
    }

    @IsTest
    static void addNewSyDataShipWithInvoice(){
        FMGRSAPI_Orders_Service testService = new FMGRSAPI_Orders_Service();


        // ************************** orderEvent **********************************
        FMGRSAPI_Orders_Service.ProcessOrderEvent orderEvent = new FMGRSAPI_Orders_Service.ProcessOrderEvent();
        orderEvent.SalesforceOrderId = FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType,'Order1');
        orderEvent.OrderEvent = 'ShippedWithInvoice';
        orderEvent.EventTime=Datetime.newInstance(2023,6,5);


        // ************************** sohdrByIds **********************************
        Map<Id,FMGRSAPI_Orders_Service.ProcessOrders_RawOrder> sohdrByIds = new Map<Id, FMGRSAPI_Orders_Service.ProcessOrders_RawOrder>();
        FMGRSAPI_Orders_Service.ProcessOrders_RawOrder order = new FMGRSAPI_Orders_Service.ProcessOrders_RawOrder();
        order.Id = FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType,'Order1');
        order.Batch = new fmgsohdrext__c();
        order.Batch.Id = FMG_TestUtility.getFakeId(fmgsohdrext__c.SObjectType,'Order1Batch');
        order.orderLines = new List<FMGRSAPI_Orders_Service.ProcessOrders_RawOrderLine>();
        order.ShippingClosed = new Map<Id, Boolean>();
        order.ShippingClosed.put(FMG_TestUtility.getFakeId(rstk__soship__c.SObjectType,'Order1ShipC'),false);

        sohdrByIds.put(order.Id,order);

        // ************************** sohdrByIds **********************************
        FMGRSAPI_Orders_Service.ProcessOrders_RawOrderLine orderLine = new FMGRSAPI_Orders_Service.ProcessOrders_RawOrderLine();
        orderLine.Id = FMG_TestUtility.getFakeId(rstk__soline__c.SObjectType,'Order1Lime1');
        orderLine.LocationId = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'Loc1');
        orderLine.LocationNumber='C1';
        orderLine.QtyAvailableAndPick=10;
        orderLine.ToPack=0;
        orderLine.ToShip=0;
        order.orderLines.add(orderLine);


        Map<Id,fmgsohdrext__c> updatefmgsohdr = new Map<Id, fmgsohdrext__c>();
        Map<Id,rstk__sydata__c> shipEvents = new Map<Id, rstk__sydata__c>();


        Test.startTest();
        testService.addNewSyDataship(orderEvent,sohdrByIds,updatefmgsohdr,shipEvents,true,true);
        Test.stopTest();


        System.debug('****************************************************');
        System.debug(JSON.serializePretty(shipEvents));
        System.debug('****************************************************');
        System.debug(JSON.serializePretty(updatefmgsohdr));

        System.assertEquals(shipEvents.size(),1);
        System.assertEquals(updatefmgsohdr.size(),1);
        System.assertEquals(updatefmgsohdr.values()[0].Time_of_Pick__c,null);
        System.assertEquals(updatefmgsohdr.values()[0].Time_of_Pack__c,null);
        rstk__sydata__c data = shipEvents.values()[0];

        System.assertNotEquals('Sales Order Pick(Issue)',data.rstk__sydata_txntype__c);
        System.assertNotEquals('Sales Order Pack',data.rstk__sydata_txntype__c);
        System.assertEquals('Sales Order Shipment',data.rstk__sydata_txntype__c);
        System.assertEquals(true,data.rstk__sydata_spawninv__c);
        System.assertEquals(data.rstk__sydata_soship__c,FMG_TestUtility.getFakeId(rstk__soship__c.SObjectType,'Order1ShipC'));
        System.assertEquals(data.rstk__sydata_backgroundprocessing__c,true);
    }

    @IsTest
    static void addNewSyDataCreateInvoice(){
        FMGRSAPI_Orders_Service testService = new FMGRSAPI_Orders_Service();


        // ************************** orderEvent **********************************
        FMGRSAPI_Orders_Service.ProcessOrderEvent orderEvent = new FMGRSAPI_Orders_Service.ProcessOrderEvent();
        orderEvent.SalesforceOrderId = FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType,'Order1');
        orderEvent.OrderEvent = 'CreateInvoice';
        orderEvent.EventTime=Datetime.newInstance(2023,6,5);


        // ************************** sohdrByIds **********************************
        Map<Id,FMGRSAPI_Orders_Service.ProcessOrders_RawOrder> sohdrByIds = new Map<Id, FMGRSAPI_Orders_Service.ProcessOrders_RawOrder>();
        FMGRSAPI_Orders_Service.ProcessOrders_RawOrder order = new FMGRSAPI_Orders_Service.ProcessOrders_RawOrder();
        order.Id = FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType,'Order1');
        order.Batch = new fmgsohdrext__c();
        order.Batch.Id = FMG_TestUtility.getFakeId(fmgsohdrext__c.SObjectType,'Order1Batch');
        order.orderLines = new List<FMGRSAPI_Orders_Service.ProcessOrders_RawOrderLine>();
        order.ShippingClosed = new Map<Id, Boolean>();
        order.ShippingClosed.put(FMG_TestUtility.getFakeId(rstk__soship__c.SObjectType,'Order1ShipC'),true);

        sohdrByIds.put(order.Id,order);

        // ************************** sohdrByIds **********************************
        FMGRSAPI_Orders_Service.ProcessOrders_RawOrderLine orderLine = new FMGRSAPI_Orders_Service.ProcessOrders_RawOrderLine();
        orderLine.Id = FMG_TestUtility.getFakeId(rstk__soline__c.SObjectType,'Order1Lime1');
        orderLine.LocationId = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'Loc1');
        orderLine.LocationNumber='C1';
        orderLine.QtyAvailableAndPick=10;
        orderLine.ToPack=0;
        orderLine.ToShip=0;
        order.orderLines.add(orderLine);


        Map<Id,fmgsohdrext__c> updatefmgsohdr = new Map<Id, fmgsohdrext__c>();
        Map<Id,rstk__sydata__c> createInvoiceEvents = new Map<Id, rstk__sydata__c>();

        System.debug('********************** orderEvent ******************************');
        System.debug(JSON.serializePretty(orderEvent));

        System.debug('********************** sohdrByIds ******************************');
        System.debug(JSON.serializePretty(sohdrByIds));
        Test.startTest();
        testService.addNewSyDataInvoice(orderEvent,sohdrByIds,createInvoiceEvents,true);
        Test.stopTest();


        System.debug('****************************************************');
        System.debug(JSON.serializePretty(createInvoiceEvents));
        System.debug('****************************************************');
        System.debug(JSON.serializePretty(updatefmgsohdr));

        System.assertEquals(1,createInvoiceEvents.size(),'Failed Ship Events Test');
        rstk__sydata__c data = createInvoiceEvents.values()[0];

        System.assertNotEquals('Sales Order Pick(Issue)',data.rstk__sydata_txntype__c);
        System.assertNotEquals('Sales Order Pack',data.rstk__sydata_txntype__c);
        System.assertNotEquals('Sales Order Shipment',data.rstk__sydata_txntype__c);
        System.assertEquals('Create Invoice for Shipper',data.rstk__sydata_txntype__c);
        System.assertEquals(data.rstk__sydata_soship__c,FMG_TestUtility.getFakeId(rstk__soship__c.SObjectType,'Order1ShipC'));
        System.assertEquals(data.rstk__sydata_backgroundprocessing__c,true);
    }

    @IsTest
    static void processOrders(){
        FMGRSAPI_Orders_Service testService = new FMGRSAPI_Orders_Service();
        testService.UnitTestProcessOrders_GetOrders = new Map<Id, FMGRSAPI_Orders_Service.ProcessOrders_RawOrder>();
        FMGRSAPI_Orders_Service.ProcessOrders_RawOrder toPickOrder = generateOrderUnitTestProcessOrdersGetOrdersLine('Order1Extended','Order1',new Map<Id, Boolean>());
        toPickOrder.orderLines.add(generateOrderLineUnitTestProcessOrdersGetOrdersLine(0,0,5,'P1','C1','Order1Line1'));
        testService.UnitTestProcessOrders_GetOrders.put(toPickOrder.Id,toPickOrder);

        FMGRSAPI_Orders_Service.ProcessOrders_RawOrder toPackOrder = generateOrderUnitTestProcessOrdersGetOrdersLine('Order2Extended','Order2',new Map<Id, Boolean>());
        toPackOrder.orderLines.add(generateOrderLineUnitTestProcessOrdersGetOrdersLine(5,0,0,'P1','C1','Order3Line1'));
        testService.UnitTestProcessOrders_GetOrders.put(toPackOrder.Id,toPackOrder);

        FMGRSAPI_Orders_Service.ProcessOrders_RawOrder toShipOrder = generateOrderUnitTestProcessOrdersGetOrdersLine('Order3Extended','Order3',new Map<Id, Boolean>());
        toShipOrder.ShippingClosed.put(FMG_TestUtility.getFakeId(rstk__soship__c.SObjectType,'Order3_ship1'),false);
        toShipOrder.ShippingClosed.put(FMG_TestUtility.getFakeId(rstk__soship__c.SObjectType,'Order3_ship2'),false);
        toShipOrder.orderLines.add(generateOrderLineUnitTestProcessOrdersGetOrdersLine(0,5,0,'P1','C1','Order3Line1'));
        testService.UnitTestProcessOrders_GetOrders.put(toShipOrder.Id,toShipOrder);

        FMGRSAPI_Orders_Service.ProcessOrders_RawOrder otherOrder1 = generateOrderUnitTestProcessOrdersGetOrdersLine('ExtraOrder1Extended','ExtraOrder1',new Map<Id, Boolean>());
        otherOrder1.ShippingClosed.put(FMG_TestUtility.getFakeId(rstk__soship__c.SObjectType,'ExtraOrder1Ship'),false);
        otherOrder1.orderLines.add(generateOrderLineUnitTestProcessOrdersGetOrdersLine(0,5,0,'P1','C1','ExtraOrder1Line1'));
        testService.UnitTestProcessOrders_GetOrders.put(otherOrder1.Id,otherOrder1);

        FMGRSAPI_Orders_Service.ProcessOrders_RawOrder otherOrder2 = generateOrderUnitTestProcessOrdersGetOrdersLine('ExtraOrder2Extended','ExtraOrder2',new Map<Id, Boolean>());
        otherOrder2.orderLines.add(generateOrderLineUnitTestProcessOrdersGetOrdersLine(3,0,0,'P1','C1','ExtraOrder2Line1'));
        testService.UnitTestProcessOrders_GetOrders.put(otherOrder2.Id,otherOrder2);

        List<FMGRSAPI_Orders_Service.ProcessOrderEvent> orderEvents = new List<FMGRSAPI_Orders_Service.ProcessOrderEvent>();
        Map<Id,Datetime> checkData = new Map<Id, Datetime>();
        checkData.put(toPickOrder.Id,Datetime.newInstance(2023,6,1,5,0,1));
        checkData.put(toPackOrder.Id,Datetime.newInstance(2023,6,1,5,0,1));
        checkData.put(toShipOrder.Id,Datetime.newInstance(2023,6,1,5,0,1));

        orderEvents.add(new FMGRSAPI_Orders_Service.ProcessOrderEvent(checkData.get(toPickOrder.Id),
                'Picked',toPickOrder.Id,'TestUser'));
        orderEvents.add(new FMGRSAPI_Orders_Service.ProcessOrderEvent(checkData.get(toPackOrder.Id),
                'Packed',toPackOrder.Id,'TestUser'));
        orderEvents.add(new FMGRSAPI_Orders_Service.ProcessOrderEvent(checkData.get(toShipOrder.Id),
                'Shipped',toShipOrder.Id,'TestUser'));

        Test.startTest();
        testService.processOrders(orderEvents,true);
        Test.stopTest();

        System.debug('***************** Pick Events ******************');

        System.debug(JSON.serializePretty(testService.pickEventsCollection));
        System.assertEquals(testService.pickEventsCollection.size(),1);
        for(rstk__sydata__c sydata:testService.pickEventsCollection.values()){
            System.assertEquals(sydata.rstk__sydata_txntype__c,'Sales Order Pick(Issue)');
            System.assertNotEquals(sydata.rstk__sydata_txnqty__c,null);
            System.assertNotEquals(sydata.rstk__sydata_soline__c,null);
            System.assertNotEquals(sydata.rstk__sydata_sylocid__c,null);
            System.assertNotEquals(sydata.rstk__sydata_locnum__c,null);
            System.assertEquals(sydata.rstk__sydata_backgroundprocessing__c,true);
        }


        System.debug('***************** Pack Events ******************');
        System.debug(JSON.serializePretty(testService.packEventsCollection));
        System.assertEquals(testService.packEventsCollection.size(),1);
        for(rstk__sydata__c sydata:testService.packEventsCollection.values()){
            System.assertEquals(sydata.rstk__sydata_txntype__c,'Sales Order Pack');
            System.assertNotEquals(sydata.rstk__sydata_soline__c,null);
            System.assertEquals(sydata.rstk__sydata_backgroundprocessing__c,true);
        }


        System.debug('***************** Ship Events ******************');
        System.debug(JSON.serializePretty(testService.shipEventsCollection));
        System.assertEquals(testService.shipEventsCollection.size(),2);
        for(rstk__sydata__c sydata:testService.shipEventsCollection.values()){
            System.assertEquals(sydata.rstk__sydata_txntype__c,'Sales Order Shipment');
            System.assertNotEquals(sydata.rstk__sydata_soship__c,null);
            System.assertEquals(sydata.rstk__sydata_backgroundprocessing__c,true);
        }

        System.debug('***************** Custom Header Update ******************');
        System.debug(JSON.serializePretty(testService.updatefmgsohdrCollection));
        System.assertEquals(testService.updatefmgsohdrCollection.size(),3);
        for(fmgsohdrext__c extednedInfo:testService.updatefmgsohdrCollection.values()){
            if(extednedInfo.fmgsohdrext_sohdr__c == toPickOrder.Id){
                System.assertEquals(extednedInfo.Time_of_Pick__c,checkData.get(extednedInfo.fmgsohdrext_sohdr__c));
            }
            if(extednedInfo.fmgsohdrext_sohdr__c == toPackOrder.Id){
                System.assertEquals(extednedInfo.Time_of_Pack__c,checkData.get(extednedInfo.fmgsohdrext_sohdr__c));

            }
            if(extednedInfo.fmgsohdrext_sohdr__c == toShipOrder.Id){
                System.assertEquals(extednedInfo.Time_of_Ship__c,checkData.get(extednedInfo.fmgsohdrext_sohdr__c));

            }
        }
    }


    static FMGRSAPI_Orders_Service generateContainers_Setup(){
        FMGRSAPI_Orders_Service testService = new FMGRSAPI_Orders_Service();
        FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock mockData = new FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock();
        testService.ordersServiceDataAccessOverride = (FMGRSAPI_Orders_Service_DataInterface)mockData;


        /***************************************** Container Type Setup ****************************************************************/
        Map<String,FMGRSAPI_Orders_Service.RawContainerTypes> mockContainerTypes = new Map<String, FMGRSAPI_Orders_Service.RawContainerTypes>();
        testService.MockData_GetContainerTypes = mockContainerTypes;
        FMGRSAPI_Orders_Service.RawContainerTypes testContainerType = createTestContainerType('TestContainer');
        mockContainerTypes.put(testContainerType.ContainerType,testContainerType);
        return testService;
    }

    @IsTest
    static void generateContainers_TrackingOnly_1Container(){
        FMGRSAPI_Orders_Service testService = generateContainers_Setup();

        List<FMGRSAPI_Orders_Service.ShippingContainer> containers = new List<FMGRSAPI_Orders_Service.ShippingContainer>();
        FMGRSAPI_Orders_Service.ShippingContainer container1 = new FMGRSAPI_Orders_Service.ShippingContainer();
        container1.SalesforceOrderId = 'a6UDK000000L77d2AC';
        container1.TrackingNumber = 'From Test 1';

        containers.add(container1);

        Test.startTest();
        testService.generateContainers(containers);
        Test.stopTest();

        System.Debug('******************** newContainers *************************');
        system.debug(JSON.serializePretty(testService.GenerateContainers_newContainers));

        System.Debug('******************** itemList *************************');
        system.debug(JSON.serializePretty(testService.GenerateContainers_ItemList));




        System.assertEquals(true,testService.GenerateContainers_ItemList.isEmpty());
        System.assertEquals(1,testService.GenerateContainers_newContainers.size());
        for(FMGRSAPI_Orders_Service.ShippingContainer conainer: testService.GenerateContainers_newContainers.keySet()){
            System.assertEquals(conainer.TrackingNumber,testService.GenerateContainers_newContainers.get(conainer).rstk__socontainer_tracking__c);
        }
    }

    @IsTest
    static void generateContainers_TrackingOnly_2Container_SameOrder(){
        FMGRSAPI_Orders_Service testService = generateContainers_Setup();

        List<FMGRSAPI_Orders_Service.ShippingContainer> containers = new List<FMGRSAPI_Orders_Service.ShippingContainer>();
        FMGRSAPI_Orders_Service.ShippingContainer container1 = new FMGRSAPI_Orders_Service.ShippingContainer();
        container1.SalesforceOrderId = 'a6UDK000000L77d2AC';
        container1.TrackingNumber = 'From Test 1';

        FMGRSAPI_Orders_Service.ShippingContainer container2 = new FMGRSAPI_Orders_Service.ShippingContainer();
        container2.SalesforceOrderId = 'a6UDK000000L77d2AC';
        container2.TrackingNumber = 'From Test 2';
        containers.add(container1);
        containers.add(container2);
        Test.startTest();
        testService.generateContainers(containers);
        Test.stopTest();

        System.Debug('******************** newContainers *************************');
        system.debug(JSON.serializePretty(testService.GenerateContainers_newContainers));

        System.Debug('******************** itemList *************************');
        system.debug(JSON.serializePretty(testService.GenerateContainers_ItemList));

        Set<String> expectedNames = new Set<String>();
        expectedNames.add('R000009048 - 1-01');
        expectedNames.add('R000009048 - 1-02');

        System.assertEquals(true,testService.GenerateContainers_ItemList.isEmpty());
        System.assertEquals(2,testService.GenerateContainers_newContainers.size());
        for(FMGRSAPI_Orders_Service.ShippingContainer conainer: testService.GenerateContainers_newContainers.keySet()){
            System.assertEquals(conainer.TrackingNumber,testService.GenerateContainers_newContainers.get(conainer).rstk__socontainer_tracking__c);
            System.assert(expectedNames.contains(testService.GenerateContainers_newContainers.get(conainer).rstk__socontainer_container__c),'The expected value was not found for the Name: ' + testService.GenerateContainers_newContainers.get(conainer).rstk__socontainer_container__c);
        }
    }

    @IsTest
    static void generateContainers_AddressAndTracking(){
        FMGRSAPI_Orders_Service testService = generateContainers_Setup();

        List<FMGRSAPI_Orders_Service.ShippingContainer> containers = new List<FMGRSAPI_Orders_Service.ShippingContainer>();
        FMGRSAPI_Orders_Service.ShippingContainer container1 = new FMGRSAPI_Orders_Service.ShippingContainer();
        container1.SalesforceOrderId = 'a6UDK000000L77d2AC';
        container1.TrackingNumber = 'From Test 1';
        container1.ShipToAddress = new FMGRSAPI_Orders_Service.OrderAddressInfo();

        container1.ShipToAddress.Email='bad@aol.bad';
        container1.ShipToAddress.Address1='123 Bad';
        container1.ShipToAddress.Address2='Apt 666';
        container1.ShipToAddress.City='Unknown';
        container1.ShipToAddress.CountryIso='US';
        container1.ShipToAddress.State='Unknown';
        container1.ShipToAddress.CustName='John Doe';

        containers.add(container1);
        Test.startTest();
        testService.generateContainers(containers);
        Test.stopTest();

        System.debug('******************** newContainers *************************');
        System.debug(JSON.serializePretty(testService.GenerateContainers_newContainers));

        System.debug('******************** itemList *************************');
        System.debug(JSON.serializePretty(testService.GenerateContainers_ItemList));


        System.assertEquals(true,testService.GenerateContainers_ItemList.isEmpty());
        System.assertEquals(1,testService.GenerateContainers_newContainers.size());

        rstk__socontainer__c sObjectContainer = testService.GenerateContainers_newContainers.values()[0];
        System.assertEquals('From Test 1',sObjectContainer.rstk__socontainer_tracking__c);
        System.assertEquals('R000009048 - 1-01',sObjectContainer.rstk__socontainer_container__c);
        System.assertEquals('bad@aol.bad',sObjectContainer.rstk__socontainer_email__c);
        System.assertEquals('123 Bad',sObjectContainer.rstk__socontainer_address1__c);
        System.assertEquals('Apt 666',sObjectContainer.rstk__socontainer_address2__c);
        System.assertEquals('Unknown',sObjectContainer.rstk__socontainer_city__c);
        System.assertEquals('US',sObjectContainer.rstk__socontainer_isocountry__c);
        System.assertEquals('Unknown',sObjectContainer.rstk__socontainer_state__c);
        System.assertEquals('John Doe',sObjectContainer.rstk__socontainer_name__c);
        //System.assertEquals('',sObjectContainer.rstk__socontainer_zip__c);


    }

    private static FMGRSAPI_Orders_Service.RawContainerTypes createTestContainerType(String Name){
        return new FMGRSAPI_Orders_Service.RawContainerTypes(
                FMG_TestUtility.getFakeId(rstk__socontype__c.SObjectType,Name),
                Name,
                FMG_TestUtility.getFakeId(rstk__sydiv__c.SObjectType,'P1')
        );
    }
    private static FMGRSAPI_Orders_Service.RawSalesOrderLineInfo createTestShippingDemand(String soLine,String shipperLine,String productName){
        FMGRSAPI_Orders_Service.RawSalesOrderLineInfo data = new FMGRSAPI_Orders_Service.RawSalesOrderLineInfo();

        data.SalesOrderLine = FMG_TestUtility.getFakeId(rstk__soline__c.SObjectType,soLine);
        data.ShipperLine = FMG_TestUtility.getFakeId(rstk__soshipline__c.SObjectType,shipperLine);
        data.ShipperLineName = shipperLine;
        data.ShipperDemand = FMG_TestUtility.getFakeId(rstk__soshipdmd__c.SObjectType,soLine);
        data.ProductName = productName;
        data.ProductId = FMG_TestUtility.getFakeId(rstk__soprod__c.SObjectType,productName);
        return data;
    }

    private static FMGRSAPI_Orders_Service.RawShipperHeader createTestShipperHeader(String orderNumber,String name,String shipToName, String address1, String address2, String city, String state, String postal,Integer containerCount){
        FMGRSAPI_Orders_Service.RawShipperHeader data = new FMGRSAPI_Orders_Service.RawShipperHeader();

        data.ContainerCount=containerCount;
        data.OrderNumber=FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType,orderNumber);
        data.Name=name;
        data.Address1=address1;
        data.Address2=address2;
        data.Address3='';
        data.City=city;
        data.Country='United States';
        data.Division=FMG_TestUtility.getFakeId(rstk__sydiv__c.SObjectType,'P1');
        data.Email=shipToName + '@firemtn.test';
        data.Fax='';
        data.FOB=FMG_TestUtility.getFakeId(rstk__syfob__c.SObjectType,'P1');
        data.FreightTerm=FMG_TestUtility.getFakeId(rstk__syfrghtrm__c.SObjectType,'P1');
        data.ISOCountry='US';
        data.ShipToName=shipToName;
        data.Phone='555-555-5555';
        data.Id=FMG_TestUtility.getFakeId(rstk__soship__c.SObjectType,'P1');
        data.ShipMethod=FMG_TestUtility.getFakeId(rstk__syshipviatype__c.SObjectType,'P1');
        data.Customer=FMG_TestUtility.getFakeId(rstk__socust__c.SObjectType,'P1');
        data.State=state;
        data.Carrier=FMG_TestUtility.getFakeId(rstk__sycarrier__c.SObjectType,'P1');
        data.ZipCode=postal;
        
        return data;
    }

    private static FMGRSAPI_Orders_Service.ProcessOrders_RawOrder generateOrderUnitTestProcessOrdersGetOrdersLine(
            String extendedInfoName, String orderNumber,Map<Id,Boolean> shippingClosed){
        // Initial
        FMGRSAPI_Orders_Service.ProcessOrders_RawOrder order = new FMGRSAPI_Orders_Service.ProcessOrders_RawOrder();

        // Order header Id
        order.Id = FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType,orderNumber);

        // Batch Object
        order.Batch = new fmgsohdrext__c();
        order.Batch.Id = FMG_TestUtility.getFakeId(fmgsohdrext__c.SObjectType,extendedInfoName);

        order.ShippingClosed = shippingClosed;
        order.orderLines = new List<FMGRSAPI_Orders_Service.ProcessOrders_RawOrderLine>();
        return order;
    }

    private static FMGRSAPI_Orders_Service.ProcessOrders_RawOrderLine generateOrderLineUnitTestProcessOrdersGetOrdersLine(Decimal toPack,Decimal toShip,Decimal qtyAvailableAndPick
    ,String locationName,String locationNumber,String orderLineName){
        FMGRSAPI_Orders_Service.ProcessOrders_RawOrderLine orderLine = new FMGRSAPI_Orders_Service.ProcessOrders_RawOrderLine();
        orderLine.Id=FMG_TestUtility.getFakeId(rstk__soline__c.SObjectType,orderLineName);
        orderLine.QtyAvailableAndPick=qtyAvailableAndPick;
        orderLine.ToPack=toPack;
        orderLine.ToShip=toShip;
        orderLine.LocationId=FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,locationName);
        orderLine.LocationNumber=locationNumber;
        return orderLine;
    }


    @IsTest(SeeAllData=true)
    static void reduceLineQty_getIvcResearchLocation(){
        rstk__sylocid__c[] locationIds = [SELECT Id, rstk__sylocid_div__c, rstk__sylocid_site__c,
                rstk__sylocid_div__r.rstk__sydiv_dflthomeproj__c
        FROM rstk__sylocid__c
        WHERE rstk__sylocid_locid__c = '90'];

        rstk__sylocid__c locationId  = locationIds[0];
        FMGRSAPI_Orders_Service testObject = new FMGRSAPI_Orders_Service();

        Test.startTest();
        FMGRSAPI_Orders_Service.itemLocation testData = testObject.getIvcResearchLocation();
        Test.stopTest();

        System.assertEquals(locationId.rstk__sylocid_div__c,testData.DivisionId);
        System.assertEquals(locationId.rstk__sylocid_site__c,testData.SiteId);
        System.assertEquals(locationId.rstk__sylocid_div__r.rstk__sydiv_dflthomeproj__c,testData.ProjectId);
        System.assertEquals(locationId.Id,testData.LocId);

    }

    private static FMGRSAPI_Orders_Service init_reduceLineQtyTest(Decimal qty, Decimal firmedAllocated, Decimal issued, Decimal packed, Id itemId ){
        FMGRSAPI_Orders_Service testService = new FMGRSAPI_Orders_Service();

        // Setup IVC Research Location
        testService.ReduceLineQty_getIvcResearchLocation = new FMGRSAPI_Orders_Service.ItemLocation();
        testService.ReduceLineQty_getIvcResearchLocation.DivisionId = FMG_TestUtility.getFakeId(rstk__sydiv__c.SObjectType,'FMG');
        testService.ReduceLineQty_getIvcResearchLocation.SiteId = FMG_TestUtility.getFakeId(rstk__sysite__c.SObjectType,'FMG');
        testService.ReduceLineQty_getIvcResearchLocation.ProjectId = FMG_TestUtility.getFakeId(rstk__pjproj__c.SObjectType,'FMG');
        testService.ReduceLineQty_getIvcResearchLocation.LocId = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'90');
        testService.ReduceLineQty_getIvcResearchLocation.LocNumber = 'IVCRSRCH';


        // Setup Sales Order Line Info
        testService.ReduceLineQty_getOrderLine = new FMGRSAPI_Orders_Service.OrderItemReversal();
        testService.ReduceLineQty_getOrderLine.Qty=qty;
        testService.ReduceLineQty_getOrderLine.FirmedAllocated=firmedAllocated;
        testService.ReduceLineQty_getOrderLine.Issued=issued;
        testService.ReduceLineQty_getOrderLine.Packed=packed;
        testService.ReduceLineQty_getOrderLine.InventoryProductId = itemId;
        testService.ReduceLineQty_getOrderLine.Demands = new List<FMGRSAPI_Orders_Service.ItemReversalLocation>();

        FMGRSAPI_Orders_Service.ItemReversalLocation demandInfo = new FMGRSAPI_Orders_Service.ItemReversalLocation();
        demandInfo.DemandId = FMG_TestUtility.getFakeId(rstk__soorddmd__c.SObjectType,'lineDemand');
        demandInfo.qty=5;
        demandInfo.LocId = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'P1');
        demandInfo.LocNumber = 'C1';
        demandInfo.SiteId = FMG_TestUtility.getFakeId(rstk__sysite__c.SObjectType,'FMG');
        demandInfo.ProjectId = FMG_TestUtility.getFakeId(rstk__pjproj__c.SObjectType,'FMG');
        demandInfo.DivisionId = FMG_TestUtility.getFakeId(rstk__sydiv__c.SObjectType,'FMG');
        testService.ReduceLineQty_getOrderLine.Demands.add(demandInfo);


        return testService;
    }
    @IsTest
    static void reduceLineQty_ReducePacked(){
        Id itemId = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'Product');
        Id soLine = FMG_TestUtility.getFakeId(rstk__soline__c.SObjectType);
        FMGRSAPI_Orders_Service testService = init_reduceLineQtyTest(5,0,5,4,itemId);
        Test.startTest();
        FMGRSAPI_Orders_Service.ReduceLineQtyResults results = testService.reduceLineQty(soLine,3);
        Test.stopTest();

        System.assertEquals(null,testService.reduceLineQty_qtyChange);
        System.assertEquals(0,testService.reduceLineQty_transfer.size());
        System.assertEquals(1,testService.reduceLineQty_statsChange.size());

        rstk__sydata__c changeInfo = testService.reduceLineQty_statsChange[0];
        System.assertEquals('Sales Order Pack Reversal',changeInfo.rstk__sydata_txntype__c);
        System.assertEquals(soLine,changeInfo.rstk__sydata_soline__c);
        System.assertEquals(1,changeInfo.rstk__sydata_txnqty__c);

        System.assertEquals(true,results.ReRun);


    }

    @IsTest
    static void reduceLineQty_ReducePiced(){
        Id itemId = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType);
        Id soLine = FMG_TestUtility.getFakeId(rstk__soline__c.SObjectType);
        FMGRSAPI_Orders_Service testService = init_reduceLineQtyTest(5,0,5,0,itemId);
        Test.startTest();
        FMGRSAPI_Orders_Service.ReduceLineQtyResults results = testService.reduceLineQty(soLine,3);
        Test.stopTest();

        System.assertEquals(null,testService.reduceLineQty_qtyChange);
        System.assertEquals(1,testService.reduceLineQty_transfer.size());
        System.assertEquals(1,testService.reduceLineQty_statsChange.size());

        rstk__sydata__c changeInfo = testService.reduceLineQty_statsChange[0];
        System.assertEquals('Sales Order Pick(Issue) Reversal',changeInfo.rstk__sydata_txntype__c);
        System.assertEquals(soLine,changeInfo.rstk__sydata_soline__c);
        System.assertEquals(2,changeInfo.rstk__sydata_txnqty__c);
        System.assertEquals(FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'P1'),changeInfo.rstk__sydata_sylocid__c);
        System.assertEquals(testService.ReduceLineQty_getOrderLine.Demands[0].LocNumber,changeInfo.rstk__sydata_locnum__c);


        rstk__sydatat__c transferInfo = testService.reduceLineQty_transfer[0];
        System.assertEquals('INVLOCLOC',transferInfo.rstk__sydata_txnid__c);
        System.assertEquals('Inventory Transfer',transferInfo.rstk__sydata_txntype__c);
        System.assertEquals(2,transferInfo.rstk__sydata_txnqty__c);
        System.assertEquals(FMG_TestUtility.getFakeId(rstk__sydiv__c.SObjectType,'FMG'),transferInfo.rstk__sydata_fromdiv__c);
        System.assertEquals(FMG_TestUtility.getFakeId(rstk__sysite__c.SObjectType,'FMG'),transferInfo.rstk__sydata_fromsite__c);
        System.assertEquals(FMG_TestUtility.getFakeId(rstk__pjproj__c.SObjectType,'FMG'),transferInfo.rstk__sydata_fromproj__c);
        System.assertEquals(FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'P1'),transferInfo.rstk__sydata_fromlocid__c);
        System.assertEquals(testService.ReduceLineQty_getOrderLine.Demands[0].LocNumber,transferInfo.rstk__sydata_fromlocnum__c);

        System.assertEquals(FMG_TestUtility.getFakeId(rstk__sydiv__c.SObjectType,'FMG'),transferInfo.rstk__sydata_todiv__c);
        System.assertEquals(FMG_TestUtility.getFakeId(rstk__sysite__c.SObjectType,'FMG'),transferInfo.rstk__sydata_tosite__c);
        System.assertEquals(FMG_TestUtility.getFakeId(rstk__pjproj__c.SObjectType,'FMG'),transferInfo.rstk__sydata_toproj__c);
        System.assertEquals(FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'90'),transferInfo.rstk__sydata_tolocid__c);
        System.assertEquals(testService.ReduceLineQty_getIvcResearchLocation.LocNumber,transferInfo.rstk__sydata_tolocnum__c);
        System.assertEquals(itemId,transferInfo.rstk__sydata_icitem__c);

        System.assertEquals(true,results.ReRun);

    }

    @IsTest
    static void reduceLineQty_ReduceBasic(){
        Id itemId = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType);
        Id soLine = FMG_TestUtility.getFakeId(rstk__soline__c.SObjectType);
        FMGRSAPI_Orders_Service testService = init_reduceLineQtyTest(5,5,0,0,itemId);

        testService.ReduceLineQty_getItemBaseLocation = new List<FMGRSAPI_Orders_Service.ItemLocation>();
        FMGRSAPI_Orders_Service.ItemLocation locInfo = new FMGRSAPI_Orders_Service.ItemLocation();
        locInfo.LocNumber = 'C2';
        locInfo.DivisionId = FMG_TestUtility.getFakeId(rstk__sydiv__c.SObjectType,'FMG');
        locInfo.LocId = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'P1');
        locInfo.ProjectId = FMG_TestUtility.getFakeId(rstk__pjproj__c.SObjectType,'FMG');
        locInfo.SiteId = FMG_TestUtility.getFakeId(rstk__sysite__c.SObjectType,'FMG');
        locInfo.Qty = 100;

        testService.ReduceLineQty_getItemBaseLocation.add(locInfo);

        Test.startTest();
        FMGRSAPI_Orders_Service.ReduceLineQtyResults results = testService.reduceLineQty(soLine,3);
        Test.stopTest();

        System.assertNotEquals(null,testService.reduceLineQty_qtyChange,'Make sure that there is a qty change');
        System.assertEquals(1,testService.reduceLineQty_transfer.size(),'Checks the number of transfers');
        System.assertEquals(0,testService.reduceLineQty_statsChange.size(),'Checks the number of status changes');

        rstk__sydatat__c transferInfo = testService.reduceLineQty_transfer[0];
        System.assertEquals('INVLOCLOC',transferInfo.rstk__sydata_txnid__c,'Validate Transfer Type');
        System.assertEquals('Inventory Transfer',transferInfo.rstk__sydata_txntype__c,'checks the sydatat mode');
        System.assertEquals(2,transferInfo.rstk__sydata_txnqty__c,'Validates the qty that will be moved');
        System.assertEquals(FMG_TestUtility.getFakeId(rstk__sydiv__c.SObjectType,'FMG'),transferInfo.rstk__sydata_fromdiv__c,'Checks the from div');
        System.assertEquals(FMG_TestUtility.getFakeId(rstk__sysite__c.SObjectType,'FMG'),transferInfo.rstk__sydata_fromsite__c,'Checks the from site');
        System.assertEquals(FMG_TestUtility.getFakeId(rstk__pjproj__c.SObjectType,'FMG'),transferInfo.rstk__sydata_fromproj__c,'Checks the from project');
        System.assertEquals(FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'P1'),transferInfo.rstk__sydata_fromlocid__c,'Checks the from location ID');
        System.assertEquals('C2',transferInfo.rstk__sydata_fromlocnum__c,'Checks the from location number');

        System.assertEquals(FMG_TestUtility.getFakeId(rstk__sydiv__c.SObjectType,'FMG'),transferInfo.rstk__sydata_todiv__c,'Checks the to div');
        System.assertEquals(FMG_TestUtility.getFakeId(rstk__sysite__c.SObjectType,'FMG'),transferInfo.rstk__sydata_tosite__c,'Checks the to site');
        System.assertEquals(FMG_TestUtility.getFakeId(rstk__pjproj__c.SObjectType,'FMG'),transferInfo.rstk__sydata_toproj__c,'Checks the to project');
        System.assertEquals(FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'90'),transferInfo.rstk__sydata_tolocid__c,'Checks the to location ID');
        System.assertEquals(testService.ReduceLineQty_getIvcResearchLocation.LocNumber,transferInfo.rstk__sydata_tolocnum__c,'Checks the to location number');
        System.assertEquals(itemId,transferInfo.rstk__sydata_icitem__c,'Checks the item to be moved');

        System.assertEquals('Change Line',testService.reduceLineQty_qtyChange.rstk__soapi_mode__c,'Checks the soapi mode');
        System.assertEquals(soLine,testService.reduceLineQty_qtyChange.rstk__soapi_soline__c,'Checks the sales order line');
        System.assertEquals(3,testService.reduceLineQty_qtyChange.rstk__soapi_qtyorder__c,'Checks the Qty');
        System.assertEquals(true,testService.reduceLineQty_qtyChange.rstk__soapi_async__c,'Check if its a background operation');


        System.assertEquals(false,results.ReRun,'Checks to see if there is a rerun');
    }

    @IsTest
    static void reduceLineQty_ReduceNothing(){
        Id itemId = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType);
        Id soLine = FMG_TestUtility.getFakeId(rstk__soline__c.SObjectType);
        FMGRSAPI_Orders_Service testService = init_reduceLineQtyTest(5,0,0,0,itemId);

        Test.startTest();
        FMGRSAPI_Orders_Service.ReduceLineQtyResults results = testService.reduceLineQty(FMG_TestUtility.getFakeId(rstk__soline__c.SObjectType),5);
        Test.stopTest();
        System.assertEquals(null,testService.reduceLineQty_qtyChange);
        System.assertEquals(0,testService.reduceLineQty_transfer.size());
        System.assertEquals(0,testService.reduceLineQty_statsChange.size());


        System.assertEquals(false,results.ReRun);

    }

    @IsTest
    static void orderPullById(){
        FMGRSAPI_Orders_Service testService = new FMGRSAPI_Orders_Service();
        FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock mockData = new FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock();
        testService.ordersServiceDataAccessOverride = (FMGRSAPI_Orders_Service_DataInterface)mockData;
        List<Id> testIds = new List<Id>();
        Id idName = FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType);
        Id testId = FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType,idName);
        testIds.add(testId);
        test.startTest();
        testService.getOrdersById(testIds);
        test.stopTest();
    }

    @IsTest
    static void processOrders_GetOrders(){

        FMGRSAPI_Orders_Service testOrdersService = new FMGRSAPI_Orders_Service();
        FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock mockData = new FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock();
        testOrdersService.ordersServiceDataAccessOverride = (FMGRSAPI_Orders_Service_DataInterface)mockData;

        Set<Id> ids = new Set<Id>();

        test.startTest();
        Map<Id,FMGRSAPI_Orders_Service.ProcessOrders_RawOrder> results = testOrdersService.processOrders_GetOrders(ids);
        test.stopTest();

        System.debug(json.serializePretty(results));
        System.assert(!results.isEmpty());

    }

    @IsTest
    static void updateFmgExtendedHeaderFields(){

        FMGRSAPI_Orders_Service testOrdersService = new FMGRSAPI_Orders_Service();
        FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock mockData = new FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock();
        testOrdersService.ordersServiceDataAccessOverride = (FMGRSAPI_Orders_Service_DataInterface)mockData;

        List<FMGRSAPI_Orders_Service.updateFmgExtendedHeader> records = new List<FMGRSAPI_Orders_Service.updateFmgExtendedHeader>();
        FMGRSAPI_Orders_Service.updateFmgExtendedHeader record = new FMGRSAPI_Orders_Service.updateFmgExtendedHeader();
        record.Id = 'a6UDK000000L76u2AC';
        record.IsEmployee= true;
        record.IsFacility= true;
        record.IsForeign= true;
        record.IsHazardous= true;
        record.IsLightweight= true;
        record.IsOverweight= true;
        record.IsPlatinum= true;

        records.add(record);
        test.startTest();
        testOrdersService.updateFmgExtendedHeaderFields(records);
        test.stopTest();

        System.assertEquals(false,mockData.updateFmgExtendedHeadersFieldsResponse.isEmpty());
        fmgsohdrext__c results = mockData.updateFmgExtendedHeadersFieldsResponse[0];
        System.assertEquals(true,results.IsEmployee__c);
        System.assertEquals(true,results.IsFacility__c);
        System.assertEquals(true,results.IsForeign__c);
        System.assertEquals(true,results.IsHazardous__c);
        System.assertEquals(true,results.IsLightweight__c);
        System.assertEquals(true,results.IsOverweight__c);
        System.assertEquals(true,results.IsPlatinum__c);

    }

    @IsTest
    static void generateOrderBatch_GetOrders_ReadyToProcess(){
        FMGRSAPI_Orders_Service testService = new FMGRSAPI_Orders_Service();
        FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock mockData = new FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock();
        testService.ordersServiceDataAccessOverride = (FMGRSAPI_Orders_Service_DataInterface)mockData;

        test.startTest();
        List<FMGRSAPI_Orders_Service.generateOrderBatch_RawOrderHeader> results =  testService.generateOrderBatch_GetOrders(1);
        test.stopTest();

        rstk__sohdr__c testData = mockData.generateOrderBatch_GetOrdersDataRaw[0];
        System.assertEquals(false,results.isEmpty());
        FMGRSAPI_Orders_Service.generateOrderBatch_RawOrderHeader result = results[0];
        System.assertEquals('a6UDK000000L76u2AC',result.Id);
        System.assertEquals('R000009042',result.Name);
        System.assertEquals('001DK00000zs3kFYAQ',result.AccountId);
    }

    @IsTest
    static void generateOrderBatch_GetOrders_HeaderOnlyOrder(){
        FMGRSAPI_Orders_Service testService = new FMGRSAPI_Orders_Service();
        FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock mockData = new FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock();
        mockData.GetOrdersDataRaw_HeaderOnly();
        testService.ordersServiceDataAccessOverride = (FMGRSAPI_Orders_Service_DataInterface)mockData;

        test.startTest();
        List<FMGRSAPI_Orders_Service.generateOrderBatch_RawOrderHeader> results =  testService.generateOrderBatch_GetOrders(1);
        test.stopTest();

        rstk__sohdr__c testData = mockData.generateOrderBatch_GetOrdersDataRaw[0];
        System.assertEquals(true,results.isEmpty());
    }

    @IsTest
    static void generateOrderBatch_GetOrders_NotFullyReady(){
        FMGRSAPI_Orders_Service testService = new FMGRSAPI_Orders_Service();
        FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock mockData = new FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock();
        mockData.GetOrdersDataRaw_NotFullyProcessed();
        testService.ordersServiceDataAccessOverride = (FMGRSAPI_Orders_Service_DataInterface)mockData;

        test.startTest();
        List<FMGRSAPI_Orders_Service.generateOrderBatch_RawOrderHeader> results =  testService.generateOrderBatch_GetOrders(1);
        test.stopTest();

        rstk__sohdr__c testData = mockData.generateOrderBatch_GetOrdersDataRaw[0];
        System.assertEquals(true,results.isEmpty());
    }
    @IsTest
    static void OrderNumberShipperHeaderUpdate(){
        FMGRSAPI_Orders_Service testService = new FMGRSAPI_Orders_Service();
        FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock mockData = new FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock();
        testService.ordersServiceDataAccessOverride = (FMGRSAPI_Orders_Service_DataInterface)mockData;

        List<FMGRSAPI_Orders_Service.ShippingHeader> updateList = new List<FMGRSAPI_Orders_Service.ShippingHeader>();

        FMGRSAPI_Orders_Service.ShippingHeader changeShippingHeader = new FMGRSAPI_Orders_Service.ShippingHeader();
        changeShippingHeader.ShippingAddress = new  FMGRSAPI_Orders_Service.OrderAddressInfo();
        changeShippingHeader.SalesforceOrderId = 'a6UDK000000L0x82AC';
        changeShippingHeader.ShipMethod = 'PICK-UP-DOOR';
        changeShippingHeader.CarrierCode='UPS';
        changeShippingHeader.ShippingAddress.CustName = 'Adam Inscore';

        updateList.add(changeShippingHeader);
        test.startTest();
        testService.updateOrderShippingHeaders(updateList);
        test.stopTest();

        system.assertEquals('Adam Inscore',mockData.updateShipperHeadersRaw[0].rstk__soship_contact__c);
        system.assertNotEquals(null,mockData.updateShipperHeadersRaw[0].rstk__soship_email__c);
    }


    @IsTest
    static void InvalidOrderNumberShipperHeaderUpdate(){
        FMGRSAPI_Orders_Service testService = new FMGRSAPI_Orders_Service();
        FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock mockData = new FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock();
        testService.ordersServiceDataAccessOverride = (FMGRSAPI_Orders_Service_DataInterface)mockData;

        List<FMGRSAPI_Orders_Service.ShippingHeader> updateList = new List<FMGRSAPI_Orders_Service.ShippingHeader>();

        FMGRSAPI_Orders_Service.ShippingHeader changeShippingHeader = new FMGRSAPI_Orders_Service.ShippingHeader();
        changeShippingHeader.ShippingAddress = new  FMGRSAPI_Orders_Service.OrderAddressInfo();
        changeShippingHeader.SalesforceOrderId = '999DK000000L0x82AC';
        changeShippingHeader.ShipMethod = 'PICK-UP-DOOR';
        changeShippingHeader.CarrierCode='UPS';
        changeShippingHeader.ShippingAddress.CustName = 'Adam Inscore';
        updateList.add(changeShippingHeader);
        test.startTest();
        testService.updateOrderShippingHeaders(updateList);
        test.stopTest();

        system.assertEquals(null,mockData.updateShipperHeadersRaw);
    }


    @IsTest
    static void OrderNumberShipperHeaderUpdateAllData(){
        FMGRSAPI_Orders_Service testService = new FMGRSAPI_Orders_Service();
        FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock mockData = new FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock();
        testService.ordersServiceDataAccessOverride = (FMGRSAPI_Orders_Service_DataInterface)mockData;

        List<FMGRSAPI_Orders_Service.ShippingHeader> updateList = new List<FMGRSAPI_Orders_Service.ShippingHeader>();

        FMGRSAPI_Orders_Service.ShippingHeader changeShippingHeader = new FMGRSAPI_Orders_Service.ShippingHeader();
        changeShippingHeader.ShippingAddress = new  FMGRSAPI_Orders_Service.OrderAddressInfo();
        changeShippingHeader.SalesforceOrderId = 'a6UDK000000L0x82AC';
        changeShippingHeader.ShipMethod = 'PICK-UP-DOOR';
        changeShippingHeader.CarrierCode='UPS';

        changeShippingHeader.ShippingAddress.Address1 = 'test1';
        changeShippingHeader.ShippingAddress.Address2 = 'test1';
        changeShippingHeader.ShippingAddress.Address3 = 'test1';
        changeShippingHeader.ShippingAddress.CustName = 'test1';
        changeShippingHeader.ShippingAddress.City = 'test1';
        changeShippingHeader.ShippingAddress.Contact = 'test1';
        changeShippingHeader.ShippingAddress.CompanyName = 'test1';
        changeShippingHeader.ShippingAddress.Country = 'test1';
        changeShippingHeader.ShippingAddress.CountryIso = '';
        changeShippingHeader.ShippingAddress.CustNo = 'test1';
        changeShippingHeader.ShippingAddress.Email = 'test1@test.com';
        changeShippingHeader.ShippingAddress.Phone = '555-555-5555';
        changeShippingHeader.ShippingAddress.Zip = 'test1';
        changeShippingHeader.ShippingAddress.State = 'test1';

        updateList.add(changeShippingHeader);
        test.startTest();
        testService.updateOrderShippingHeaders(updateList);
        test.stopTest();

        system.assertEquals('test1',mockData.updateShipperHeadersRaw[0].rstk__soship_address1__c);
        system.assertEquals('test1',mockData.updateShipperHeadersRaw[0].rstk__soship_address2__c);
        system.assertEquals('test1',mockData.updateShipperHeadersRaw[0].rstk__soship_address3__c);
        system.assertEquals('test1',mockData.updateShipperHeadersRaw[0].rstk__soship_city__c);
        system.assertEquals('test1',mockData.updateShipperHeadersRaw[0].rstk__soship_contact__c);
        system.assertEquals('test1',mockData.updateShipperHeadersRaw[0].rstk__soship_country__c);
        system.assertEquals('',mockData.updateShipperHeadersRaw[0].rstk__soship_isocountry__c);
        system.assertEquals('test1@test.com',mockData.updateShipperHeadersRaw[0].rstk__soship_email__c);
        system.assertEquals('555-555-5555',mockData.updateShipperHeadersRaw[0].rstk__soship_phone__c);
        system.assertEquals('test1',mockData.updateShipperHeadersRaw[0].rstk__soship_zip__c);
        system.assertEquals('test1',mockData.updateShipperHeadersRaw[0].rstk__soship_state__c);
    }
}