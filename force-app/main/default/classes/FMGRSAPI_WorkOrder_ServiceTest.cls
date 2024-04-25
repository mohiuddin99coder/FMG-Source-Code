/**
 * Created by Adam-Hotmail on 5/21/2023.
 */

@IsTest
public with sharing class FMGRSAPI_WorkOrder_ServiceTest {


    static FMGRSAPI_WorkOrder_Service.RawFmgWorkOrderComponentDetail generateRawFmgWorkOrderComponentDetail(String FMGWOC,
            Integer BatchId, String WorkOrderComponentName, String WorkOrder, String ItemDescription, Decimal QtyReq,
            String ItemNumber, String WorkComponentName, String FromLocationId, String FromLocationName, Decimal QtyIssued,
            String SyData, String sydataErrorMessage, String sydataProcess, String SyTransType){
        FMGRSAPI_WorkOrder_Service.RawFmgWorkOrderComponentDetail rawFmgWorkOrderComponentDetail =
                new FMGRSAPI_WorkOrder_Service.RawFmgWorkOrderComponentDetail();
        rawFmgWorkOrderComponentDetail.SalesforceId = FMG_TestUtility.getFakeId(rstk__woorddmd__c.SObjectType,FMGWOC);
        rawFmgWorkOrderComponentDetail.BatchId = BatchId;
        rawFmgWorkOrderComponentDetail.WorkOrderComponentId = FMG_TestUtility.getFakeId(rstk__woorddmd__c.SObjectType,WorkOrderComponentName);
        rawFmgWorkOrderComponentDetail.WorkOrderNumberId = FMG_TestUtility.getFakeId(rstk__wocst__c.SObjectType,WorkOrder);
        rawFmgWorkOrderComponentDetail.OrderNumber = WorkOrder;
        rawFmgWorkOrderComponentDetail.ItemDescription = ItemDescription;
        rawFmgWorkOrderComponentDetail.QtyRequested = QtyReq;
        rawFmgWorkOrderComponentDetail.ItemNumber = ItemNumber;
        rawFmgWorkOrderComponentDetail.ComponentItemId = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,ItemNumber);
        rawFmgWorkOrderComponentDetail.WorkOrderComponentDetailId = FMG_TestUtility.getFakeId(rstk__woorddmdcst__c.SObjectType,WorkComponentName);
        rawFmgWorkOrderComponentDetail.FromLocation = FromLocationName;
        rawFmgWorkOrderComponentDetail.FromLocationIdId = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,FromLocationId);
        rawFmgWorkOrderComponentDetail.FromLocationId = FromLocationId;
        rawFmgWorkOrderComponentDetail.QtyIssued = QtyIssued;
        rawFmgWorkOrderComponentDetail.SyDataId = FMG_TestUtility.getFakeId(rstk__sydata__c.SObjectType,SyData);
        rawFmgWorkOrderComponentDetail.ErrorMessage = sydataErrorMessage;
        rawFmgWorkOrderComponentDetail.ProcessingIndicator = sydataProcess;
        rawFmgWorkOrderComponentDetail.TransactionType = SyTransType;
        rawFmgWorkOrderComponentDetail.rawObject = new fmgwoorddmdcst__c();

        return rawFmgWorkOrderComponentDetail;
    }

    static FMGRSAPI_WorkOrder_Service.RawWorkOrderComponent generateRawWorkOrderComponent(String WorkOrderComponentName,
            Decimal Qty, String Description, String ItemName,String WorkOrderNumber, Decimal RequestedQty
    ){
        FMGRSAPI_WorkOrder_Service.RawWorkOrderComponent rawWorkOrderComponent = new FMGRSAPI_WorkOrder_Service.RawWorkOrderComponent();
        rawWorkOrderComponent.ComponentId = FMG_TestUtility.getFakeId(rstk__woorddmd__c.SObjectType,WorkOrderComponentName);
        rawWorkOrderComponent.Qty = Qty;
        rawWorkOrderComponent.ItemDescription = Description;
        rawWorkOrderComponent.InventoryItem = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,ItemName);
        rawWorkOrderComponent.Item = ItemName;
        rawWorkOrderComponent.WorkOrderId = FMG_TestUtility.getFakeId(rstk__wocst__c.SObjectType,WorkOrderNumber);
        rawWorkOrderComponent.WorkOrder = WorkOrderNumber;
        rawWorkOrderComponent.QtyRequested = RequestedQty;
        rawWorkOrderComponent.Found = false;
        rawWorkOrderComponent.Generated = false;

        return rawWorkOrderComponent;
    }

    private static void InfoOut(FMGRSAPI_WorkOrder_Service testObject){
        System.debug('************************** Test Pick List ******************************');
        System.debug(JSON.serializePretty(testObject.UnitTestPickList));
        System.debug('************************** Test Custom Lookup ******************************');
        System.debug(JSON.serializePretty(testObject.UnitTestCustomLookupInfo));
        System.debug('************************** Test Issued List ******************************');
        System.debug(JSON.serializePretty(testObject.UnitTestIssued));
        System.debug('************************** Fake Id Collection ******************************');
        System.debug(JSON.serializePretty(FMG_TestUtility.ReuseIds));
    }

    /**
     * @return Returns a generated base version of the Work Order Service that has no Data
     **/
    private static FMGRSAPI_WorkOrder_Service generateWorkOrderBatchSetup(){
        // Settings
        FMG_Configuration__c testConfig = new FMG_Configuration__c();
        testConfig.Setting__c = 'Generate Pick Order Location Ids';
        testConfig.Value__c = '26,25,P1';
        testConfig.Application__c = 'FMGRSAPI - Work Order Settings';
        insert testConfig;

        // Initial Inventory Service SEtup
        FMGRSAPI_Inventory_Service inventoryService = new FMGRSAPI_Inventory_Service();
        inventoryService.UnitTest_GetProductLocations = new Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>>();

        // Initial work order service setup
        FMGRSAPI_WorkOrder_Service testObject = new FMGRSAPI_WorkOrder_Service();
        testObject.inventoryService = inventoryService;
        testObject.batchId = new FMGRSAPI_IncrementingNumbersWIthLock('WorkOrderProcessingBatch Test');


        testObject.UnitTestGetWorkOrderComponents = new List<FMGRSAPI_WorkOrder_Service.RawWorkOrderComponent>();
        return testObject;
    }

    @IsTest
    static void generateWorkOrderBatch_NotFound() {
        System.debug('*********************** Running generateWorkOrderBatch_NotFound ****************************** ');
        FMGRSAPI_WorkOrder_Service testObject = generateWorkOrderBatchSetup();

        testObject.UnitTestGetWorkOrderComponents.add(generateRawWorkOrderComponent('WO1_C1',10,'Test Item','Item2','WO1',10));

        Test.startTest();
        testObject.generateWorkOrderBatch(1);
        Test.stopTest();

        InfoOut(testObject);

        System.assert(testObject.UnitTestIssued.isEmpty());
        System.assert(testObject.UnitTestCustomLookupInfo.size() == 1);
    }

    @IsTest
    static void generateWorkOrderBatch_OneLocation() {
        System.debug('*********************** Running generateWorkOrderBatch_OneLocation ****************************** ');
        FMGRSAPI_WorkOrder_Service testObject = generateWorkOrderBatchSetup();

        List<FMGRSAPI_Inventory_Service.LocationInfo> locationInfos = new List<FMGRSAPI_Inventory_Service.LocationInfo>();
        locationInfos.add(FMG_TestUtility.generateLocationInfo('Item1','26','C1',2,1,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('Item1','25','C1',12,1,0,'25 (DC Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('Item1','P1','C1',7,1,0,'P1 (Primary)','FMG','FMG_FMG1','FMG_'));

        testObject.inventoryService.UnitTest_GetProductLocations = testObject.inventoryService.createSearchableProductLocation(locationInfos);

        testObject.UnitTestGetWorkOrderComponents.add(generateRawWorkOrderComponent('WO1_C1',10,'Test Item','Item1','WO1',10));

        Test.startTest();
        testObject.generateWorkOrderBatch(1);
        Test.stopTest();

        InfoOut(testObject);

        System.assert(testObject.UnitTestIssued.size() == 1);
        System.assert(testObject.UnitTestCustomLookupInfo.size() == 1);
        rstk__sydata__c data = testObject.UnitTestIssued[0];
        System.assert(data.rstk__sydata_backgroundprocessing__c == true);
        System.assert(data.rstk__sydata_woorddmd__c == FMG_TestUtility.getFakeId(rstk__woorddmd__c.SObjectType,'WO1_C1'));
        System.assert(data.rstk__sydata_sylocid__c == FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'25'));
        System.assertEquals('C1',data.rstk__sydata_locnum__c);
        System.assert(data.rstk__sydata_txnqty__c == 10);
    }

    @IsTest
    static void generateWorkOrderBatch_MultipleLocationNumbers() {
        System.debug('*********************** Running generateWorkOrderBatch_MultipleLocationNumbers ****************************** ');
        FMGRSAPI_WorkOrder_Service testObject = generateWorkOrderBatchSetup();

        List<FMGRSAPI_Inventory_Service.LocationInfo> locationInfos = new List<FMGRSAPI_Inventory_Service.LocationInfo>();
        locationInfos.add(FMG_TestUtility.generateLocationInfo('Item1','26','C1',6,1,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('Item1','26','C2',6,1,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('Item1','25','C1',6,1,0,'25 (DC Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('Item1','P1','C1',7,1,0,'P1 (Primary)','FMG','FMG_FMG1','FMG_'));

        testObject.inventoryService.UnitTest_GetProductLocations = testObject.inventoryService.createSearchableProductLocation(locationInfos);

        testObject.UnitTestGetWorkOrderComponents.add(generateRawWorkOrderComponent('WO1_C1',10,'Test Item','Item1','WO1',10));

        Test.startTest();
        testObject.generateWorkOrderBatch(1);
        Test.stopTest();

        InfoOut(testObject);

        System.assert(testObject.UnitTestIssued.size() == 2);
        System.assert(testObject.UnitTestCustomLookupInfo.size() == 2);

        Decimal qtyAllocated = 0;
        for(rstk__sydata__c data : testObject.UnitTestIssued){
            System.assert(data.rstk__sydata_backgroundprocessing__c == true);
            System.assert(data.rstk__sydata_woorddmd__c == FMG_TestUtility.getFakeId(rstk__woorddmd__c.SObjectType,'WO1_C1'));
            System.assert(data.rstk__sydata_sylocid__c == FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'26'));
            System.assert(data.rstk__sydata_locnum__c == 'C1' || data.rstk__sydata_locnum__c == 'C2');
            qtyAllocated = qtyAllocated + data.rstk__sydata_txnqty__c;
        }

        System.assert(qtyAllocated == 10);
    }

    @IsTest
    static void generateWorkOrderBatch_MultipleLocationNumbersAndIds() {
        System.debug('*********************** Running generateWorkOrderBatch_MultipleLocationNumbersAndIds ****************************** ');
        FMGRSAPI_WorkOrder_Service testObject = generateWorkOrderBatchSetup();

        List<FMGRSAPI_Inventory_Service.LocationInfo> locationInfos = new List<FMGRSAPI_Inventory_Service.LocationInfo>();

        locationInfos.add(FMG_TestUtility.generateLocationInfo('Item1','26','C1',4,1,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('Item1','26','C2',4,1,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('Item1','25','C1',4,1,0,'25 (DC Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('Item1','P1','C1',4,1,0,'P1 (Primary)','FMG','FMG_FMG1','FMG_'));
        testObject.inventoryService.UnitTest_GetProductLocations = testObject.inventoryService.createSearchableProductLocation(locationInfos);
        testObject.UnitTestGetWorkOrderComponents.add(generateRawWorkOrderComponent('WO1_C1',10,'Test Item','Item1','WO1',10));

        Test.startTest();
        testObject.generateWorkOrderBatch(1);
        Test.stopTest();

        InfoOut(testObject);

        System.assert(testObject.UnitTestIssued.size() == 3);
        System.assert(testObject.UnitTestCustomLookupInfo.size() == 3);

        Decimal qtyAllocated = 0;
        for(rstk__sydata__c data : testObject.UnitTestIssued){
            System.assert(data.rstk__sydata_backgroundprocessing__c == true);
            System.assert(data.rstk__sydata_woorddmd__c == FMG_TestUtility.getFakeId(rstk__woorddmd__c.SObjectType,'WO1_C1'));
            System.assert(data.rstk__sydata_sylocid__c != FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'P1'));
            qtyAllocated = qtyAllocated + data.rstk__sydata_txnqty__c;
        }
        System.assert(qtyAllocated == 10);

    }

    @IsTest
    static void generateWorkOrderBatch_Short() {
        System.debug('*********************** Running generateWorkOrderBatch_Short ****************************** ');
        FMGRSAPI_WorkOrder_Service testObject = generateWorkOrderBatchSetup();
        List<FMGRSAPI_Inventory_Service.LocationInfo> locationInfos = new List<FMGRSAPI_Inventory_Service.LocationInfo>();

        locationInfos.add(FMG_TestUtility.generateLocationInfo('Item1','26','C1',3,1,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('Item1','26','C2',3,1,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('Item1','25','C1',3,1,0,'25 (DC Bulk)','FMG','FMG_FMG1','FMG_'));

        testObject.inventoryService.UnitTest_GetProductLocations = testObject.inventoryService.createSearchableProductLocation(locationInfos);

        testObject.UnitTestGetWorkOrderComponents.add(generateRawWorkOrderComponent('WO1_C1',10,'Test Item','Item1','WO1',10));

        Test.startTest();
        testObject.generateWorkOrderBatch(1);
        Test.stopTest();

        InfoOut(testObject);

        System.assert(testObject.UnitTestIssued.size() == 3);
        System.assert(testObject.UnitTestCustomLookupInfo.size() == 3);

        Decimal qtyAllocated = 0;
        for(rstk__sydata__c data : testObject.UnitTestIssued){
            System.assert(data.rstk__sydata_backgroundprocessing__c == true);
            System.assert(data.rstk__sydata_woorddmd__c == FMG_TestUtility.getFakeId(rstk__woorddmd__c.SObjectType,'WO1_C1'));
            qtyAllocated = qtyAllocated + data.rstk__sydata_txnqty__c;
        }
        System.assert(qtyAllocated < 10);
    }


    /**
     * SOQL Query Tests
     **/

    @IsTest
    static void getBatchDataAndMapping(){
        FMGRSAPI_WorkOrder_Service testService = new FMGRSAPI_WorkOrder_Service();
        MockData mockData = new MockData();
        testService.MockData = mockData;


        FMGRSAPI_WorkOrder_Service.WorkOrderBatch test = testService.getBatchData(1);
        System.assertNotEquals(0,test.WorkOrders.size());

    }

    @IsTest
    static void getWorkOrderComponentsAndMappingMultiple() {

        FMGRSAPI_WorkOrder_Service testService = new FMGRSAPI_WorkOrder_Service();
        MockData mockData = new MockData();
        testService.MockData = mockData;
        Test.startTest();
        List<FMGRSAPI_WorkOrder_Service.RawWorkOrderComponent> testOutput = testService.getWorkOrderComponents(1);
        Test.stopTest();
        System.assertNotEquals(0,testOutput.size(),'Count Returned');
        System.assertNotEquals(1,testOutput.size(),'Count Returned');
    }
    @IsTest
    static void getWorkOrderComponentsAndMapping() {

        FMGRSAPI_WorkOrder_Service testService = new FMGRSAPI_WorkOrder_Service();
        MockData mockData = new MockData();
        testService.MockData = mockData;
        mockData.getWorkOrderComponents_workOrdersItemsDataRaw = new List<rstk__woorddmd__c>();
        rstk__woorddmd__c record = (rstk__woorddmd__c)json.deserializeStrict('{"Id":"a9mDK000000LD2cYAG","rstk__woorddmd_qtyoutstdg__c":29.000000,"rstk__woorddmd_desc__c":"CRYSTAL CLEAR ZIP BAG 2X2IN CASE","rstk__woorddmd_compitem__c":"a1YDK000001iqxK2AQ","rstk__woorddmd_ordno__c":"a9hDK000000L0V7YAK","rstk__woorddmd_qtyreq__c":50.000000,"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxK2AQ","rstk__icitem_item__c":"a35DK000001aG04YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG04YAE","rstk__peitem_item__c":"1233DC"}},"rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0V7YAK","Name":"WO-1108","rstk__wocst_ordsts__c":"5","rstk__wocst_ordno__c":"WO-1108"}}',rstk__woorddmd__c.class);
        mockData.getWorkOrderComponents_workOrdersItemsDataRaw.add(record);

        Test.startTest();
        List<FMGRSAPI_WorkOrder_Service.RawWorkOrderComponent> testOutput = testService.getWorkOrderComponents(1);
        Test.stopTest();
        System.assertEquals(1,testOutput.size(),'Count Returned');
        System.assertEquals('a9hDK000000L0V7YAK',testOutput[0].WorkOrderId,'WorkOrderId');
        System.assertEquals('WO-1108',testOutput[0].WorkOrder,'WorkOrder');
        System.assertEquals(50,testOutput[0].QtyRequested,'QtyRequested');
        System.assertEquals(29,testOutput[0].Qty,'Qty');
        System.assertEquals('CRYSTAL CLEAR ZIP BAG 2X2IN CASE',testOutput[0].ItemDescription,'ItemDescription');
        System.assertEquals('1233DC',testOutput[0].Item,'Item');
        System.assertEquals('a1YDK000001iqxK2AQ',testOutput[0].InventoryItem,'InventoryItem');
        System.assertEquals(false,testOutput[0].Generated,'Generated');
        System.assertEquals(false,testOutput[0].Found,'Found');
        System.assertEquals('a9mDK000000LD2cYAG',testOutput[0].ComponentId,'ComponentId');
        System.debug(JSON.serializePretty(testOutput));

    }

    @IsTest
    static void getFMGWorkOrderComponent_FmgDetails() {
        FMGRSAPI_WorkOrder_Service testService = new FMGRSAPI_WorkOrder_Service();
        MockData mockData = new MockData();
        testService.MockData = mockData;
        List<Id> workorderIds = new List<Id>();
        workorderIds.add(FMG_TestUtility.getFakeId(rstk__wocst__c.SObjectType));
        Test.startTest();
        List<FMGRSAPI_WorkOrder_Service.WorkOrder> workOrders = testService.getWorkOrders(workorderIds);
        Test.stopTest();
        System.debug(JSON.serializePretty(workOrders));
    }




    public class MockData implements FMGRSAPI_WorkOrder_Service_DataInterface {
        public MockData(){
            addGetFMGWorkOrderComponentBatchDataRaw();
            addGetWorkOrderComponents_workOrderIdsDataRaw();
            addGetWorkOrderComponents_workOrdersItemsDataRaw();
            addGetFMGWorkOrderComponent_WorkOrdersDataRaw();
        }
        private void addGetFMGWorkOrderComponentBatchDataRaw(){
            getFMGWorkOrderComponentBatchDataRaw = new List<fmgwoorddmdcst__c>();
            fmgwoorddmdcst__c record = (fmgwoorddmdcst__c)json.deserializeStrict('{"Id":"aELDK000000GmcZ4AS","batchId__c":1,"fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD2bYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zMHYAY","fmgwoorddmdcst_sydata__c":"a8XDK000000PbSS2A0","fmgwoorddmdcst_woorddmd__r":{"Id":"a9mDK000000LD2bYAG","rstk__woorddmd_ordno__c":"a9hDK000000L0V7YAK","rstk__woorddmd_desc__c":"TENT CARD CRYSTAL   PASSION IN HOUSE USE","rstk__woorddmd_qtyreq__c":50.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxP2AQ","rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0V7YAK","rstk__wocst_ordno__c":"WO-1108"},"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxP2AQ","rstk__icitem_item__c":"a35DK000001aG09YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG09YAE","rstk__peitem_item__c":"1049DC"}}},"fmgwoorddmdcst_woorddmdcst__r":{"Id":"a9nDK0000032zMHYAY","rstk__woorddmdcst_locnum__c":"HC17FF00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":50.000000,"rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}},"fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbSS2A0","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}}',fmgwoorddmdcst__c.class);
            getFMGWorkOrderComponentBatchDataRaw.add(record);
            record = (fmgwoorddmdcst__c)json.deserializeStrict('{"Id":"aELDK000000Gmca4AC","batchId__c":1,"fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD2cYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zMRYAY","fmgwoorddmdcst_sydata__c":"a8XDK000000PbST2A0","fmgwoorddmdcst_woorddmd__r":{"Id":"a9mDK000000LD2cYAG","rstk__woorddmd_ordno__c":"a9hDK000000L0V7YAK","rstk__woorddmd_desc__c":"CRYSTAL CLEAR ZIP BAG 2X2IN CASE","rstk__woorddmd_qtyreq__c":50.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxK2AQ","rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0V7YAK","rstk__wocst_ordno__c":"WO-1108"},"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxK2AQ","rstk__icitem_item__c":"a35DK000001aG04YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG04YAE","rstk__peitem_item__c":"1233DC"}}},"fmgwoorddmdcst_woorddmdcst__r":{"Id":"a9nDK0000032zMRYAY","rstk__woorddmdcst_locnum__c":"HC17FF00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":7.000000,"rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}},"fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbST2A0","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}}',fmgwoorddmdcst__c.class);
            getFMGWorkOrderComponentBatchDataRaw.add(record);
            record = (fmgwoorddmdcst__c)json.deserializeStrict('{"Id":"aELDK000000Gmcb4AC","batchId__c":1,"fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD2cYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zMWYAY","fmgwoorddmdcst_sydata__c":"a8XDK000000PbSU2A0","fmgwoorddmdcst_woorddmd__r":{"Id":"a9mDK000000LD2cYAG","rstk__woorddmd_ordno__c":"a9hDK000000L0V7YAK","rstk__woorddmd_desc__c":"CRYSTAL CLEAR ZIP BAG 2X2IN CASE","rstk__woorddmd_qtyreq__c":50.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxK2AQ","rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0V7YAK","rstk__wocst_ordno__c":"WO-1108"},"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxK2AQ","rstk__icitem_item__c":"a35DK000001aG04YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG04YAE","rstk__peitem_item__c":"1233DC"}}},"fmgwoorddmdcst_woorddmdcst__r":{"Id":"a9nDK0000032zMWYAY","rstk__woorddmdcst_locnum__c":"C10","rstk__woorddmdcst_locid__c":"a8uDK000000GqVAYA0","rstk__woorddmdcst_qtyiss__c":7.000000,"rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqVAYA0","rstk__sylocid_locid__c":"P1"}},"fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbSU2A0","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}}',fmgwoorddmdcst__c.class);
            getFMGWorkOrderComponentBatchDataRaw.add(record);
            record = (fmgwoorddmdcst__c)json.deserializeStrict('{"Id":"aELDK000000Gmcc4AC","batchId__c":1,"fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD2cYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zMMYAY","fmgwoorddmdcst_sydata__c":"a8XDK000000PbSV2A0","fmgwoorddmdcst_woorddmd__r":{"Id":"a9mDK000000LD2cYAG","rstk__woorddmd_ordno__c":"a9hDK000000L0V7YAK","rstk__woorddmd_desc__c":"CRYSTAL CLEAR ZIP BAG 2X2IN CASE","rstk__woorddmd_qtyreq__c":50.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxK2AQ","rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0V7YAK","rstk__wocst_ordno__c":"WO-1108"},"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxK2AQ","rstk__icitem_item__c":"a35DK000001aG04YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG04YAE","rstk__peitem_item__c":"1233DC"}}},"fmgwoorddmdcst_woorddmdcst__r":{"Id":"a9nDK0000032zMMYAY","rstk__woorddmdcst_locnum__c":"HC23FF00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":7.000000,"rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}},"fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbSV2A0","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}}',fmgwoorddmdcst__c.class);
            getFMGWorkOrderComponentBatchDataRaw.add(record);
            record = (fmgwoorddmdcst__c)json.deserializeStrict('{"Id":"aELDK000000Gmce4AC","batchId__c":1,"fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD62YAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zLYYAY","fmgwoorddmdcst_sydata__c":"a8XDK000000PbW52AK","fmgwoorddmdcst_woorddmd__r":{"Id":"a9mDK000000LD62YAG","rstk__woorddmd_ordno__c":"a9hDK000000L0ZJYA0","rstk__woorddmd_desc__c":"TENT CARD CRYSTAL   PASSION IN HOUSE USE","rstk__woorddmd_qtyreq__c":100.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxP2AQ","rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0ZJYA0","rstk__wocst_ordno__c":"WO-1132"},"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxP2AQ","rstk__icitem_item__c":"a35DK000001aG09YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG09YAE","rstk__peitem_item__c":"1049DC"}}},"fmgwoorddmdcst_woorddmdcst__r":{"Id":"a9nDK0000032zLYYAY","rstk__woorddmdcst_locnum__c":"HC17FF00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":100.000000,"rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}},"fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbW52AK","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}}',fmgwoorddmdcst__c.class);
            getFMGWorkOrderComponentBatchDataRaw.add(record);
            record = (fmgwoorddmdcst__c)json.deserializeStrict('{"Id":"aELDK000000Gmcf4AC","batchId__c":1,"fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD63YAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zLdYAI","fmgwoorddmdcst_sydata__c":"a8XDK000000PbW62AK","fmgwoorddmdcst_woorddmd__r":{"Id":"a9mDK000000LD63YAG","rstk__woorddmd_ordno__c":"a9hDK000000L0ZJYA0","rstk__woorddmd_desc__c":"Test for Mike Early","rstk__woorddmd_qtyreq__c":1.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iuRe2AI","rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0ZJYA0","rstk__wocst_ordno__c":"WO-1132"},"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iuRe2AI","rstk__icitem_item__c":"a35DK000001bBHaYAM","rstk__icitem_item__r":{"Id":"a35DK000001bBHaYAM","rstk__peitem_item__c":"FMG - Parent"}}},"fmgwoorddmdcst_woorddmdcst__r":{"Id":"a9nDK0000032zLdYAI","rstk__woorddmdcst_locnum__c":"HN18AA00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":1.000000,"rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}},"fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbW62AK","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}}',fmgwoorddmdcst__c.class);
            getFMGWorkOrderComponentBatchDataRaw.add(record);
            record = (fmgwoorddmdcst__c)json.deserializeStrict('{"Id":"aELDK000000Gmcg4AC","batchId__c":1,"fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD5xYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zLiYAI","fmgwoorddmdcst_sydata__c":"a8XDK000000PbW72AK","fmgwoorddmdcst_woorddmd__r":{"Id":"a9mDK000000LD5xYAG","rstk__woorddmd_ordno__c":"a9hDK000000L0YzYAK","rstk__woorddmd_desc__c":"TENT CARD CRYSTAL   PASSION IN HOUSE USE","rstk__woorddmd_qtyreq__c":100.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxP2AQ","rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0YzYAK","rstk__wocst_ordno__c":"WO-1130"},"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxP2AQ","rstk__icitem_item__c":"a35DK000001aG09YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG09YAE","rstk__peitem_item__c":"1049DC"}}},"fmgwoorddmdcst_woorddmdcst__r":{"Id":"a9nDK0000032zLiYAI","rstk__woorddmdcst_locnum__c":"HC17FF00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":100.000000,"rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}},"fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbW72AK","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}}',fmgwoorddmdcst__c.class);
            getFMGWorkOrderComponentBatchDataRaw.add(record);
            record = (fmgwoorddmdcst__c)json.deserializeStrict('{"Id":"aELDK000000Gmch4AC","batchId__c":1,"fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD5yYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zLnYAI","fmgwoorddmdcst_sydata__c":"a8XDK000000PbW82AK","fmgwoorddmdcst_woorddmd__r":{"Id":"a9mDK000000LD5yYAG","rstk__woorddmd_ordno__c":"a9hDK000000L0YzYAK","rstk__woorddmd_desc__c":"Test for Mike Early","rstk__woorddmd_qtyreq__c":1.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iuRe2AI","rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0YzYAK","rstk__wocst_ordno__c":"WO-1130"},"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iuRe2AI","rstk__icitem_item__c":"a35DK000001bBHaYAM","rstk__icitem_item__r":{"Id":"a35DK000001bBHaYAM","rstk__peitem_item__c":"FMG - Parent"}}},"fmgwoorddmdcst_woorddmdcst__r":{"Id":"a9nDK0000032zLnYAI","rstk__woorddmdcst_locnum__c":"HN18AA00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":1.000000,"rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}},"fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbW82AK","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}}',fmgwoorddmdcst__c.class);
            getFMGWorkOrderComponentBatchDataRaw.add(record);
            record = (fmgwoorddmdcst__c)json.deserializeStrict('{"Id":"aELDK000000Gmci4AC","batchId__c":1,"fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD5sYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zIUYAY","fmgwoorddmdcst_sydata__c":"a8XDK000000PbW92AK","fmgwoorddmdcst_woorddmd__r":{"Id":"a9mDK000000LD5sYAG","rstk__woorddmd_ordno__c":"a9hDK000000L0Z4YAK","rstk__woorddmd_desc__c":"TENT CARD CRYSTAL   PASSION IN HOUSE USE","rstk__woorddmd_qtyreq__c":100.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxP2AQ","rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0Z4YAK","rstk__wocst_ordno__c":"WO-1131"},"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxP2AQ","rstk__icitem_item__c":"a35DK000001aG09YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG09YAE","rstk__peitem_item__c":"1049DC"}}},"fmgwoorddmdcst_woorddmdcst__r":{"Id":"a9nDK0000032zIUYAY","rstk__woorddmdcst_locnum__c":"HE18BB00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":50.000000,"rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}},"fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbW92AK","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}}',fmgwoorddmdcst__c.class);
            getFMGWorkOrderComponentBatchDataRaw.add(record);
            record = (fmgwoorddmdcst__c)json.deserializeStrict('{"Id":"aELDK000000Gmcj4AC","batchId__c":1,"fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD3xYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zLxYAI","fmgwoorddmdcst_sydata__c":"a8XDK000000PbWA2A0","fmgwoorddmdcst_woorddmd__r":{"Id":"a9mDK000000LD3xYAG","rstk__woorddmd_ordno__c":"a9hDK000000L0X3YAK","rstk__woorddmd_desc__c":"TENT CARD CRYSTAL   PASSION IN HOUSE USE","rstk__woorddmd_qtyreq__c":10.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxP2AQ","rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0X3YAK","rstk__wocst_ordno__c":"WO-1111"},"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxP2AQ","rstk__icitem_item__c":"a35DK000001aG09YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG09YAE","rstk__peitem_item__c":"1049DC"}}},"fmgwoorddmdcst_woorddmdcst__r":{"Id":"a9nDK0000032zLxYAI","rstk__woorddmdcst_locnum__c":"HC17FF00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":10.000000,"rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}},"fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbWA2A0","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}}',fmgwoorddmdcst__c.class);
            getFMGWorkOrderComponentBatchDataRaw.add(record);
            record = (fmgwoorddmdcst__c)json.deserializeStrict('{"Id":"aELDK000000Gmck4AC","batchId__c":1,"fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD3rYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zM2YAI","fmgwoorddmdcst_sydata__c":"a8XDK000000PbWB2A0","fmgwoorddmdcst_woorddmd__r":{"Id":"a9mDK000000LD3rYAG","rstk__woorddmd_ordno__c":"a9hDK000000L0X8YAK","rstk__woorddmd_desc__c":"SWAROV ROSE GOLD 2X BICONE 3MM PK/1440","rstk__woorddmd_qtyreq__c":1.000000,"rstk__woorddmd_compitem__c":"a1YDK000001isE52AI","rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0X8YAK","rstk__wocst_ordno__c":"WO-1112"},"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001isE52AI","rstk__icitem_item__c":"a35DK000001aZhvYAE","rstk__icitem_item__r":{"Id":"a35DK000001aZhvYAE","rstk__peitem_item__c":"A2655CY"}}},"fmgwoorddmdcst_woorddmdcst__r":{"Id":"a9nDK0000032zM2YAI","rstk__woorddmdcst_locnum__c":"HJ36GG00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":1.000000,"rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}},"fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbWB2A0","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}}',fmgwoorddmdcst__c.class);
            getFMGWorkOrderComponentBatchDataRaw.add(record);
            record = (fmgwoorddmdcst__c)json.deserializeStrict('{"Id":"aELDK000000Gmcl4AC","batchId__c":1,"fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD3uYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zM7YAI","fmgwoorddmdcst_sydata__c":"a8XDK000000PbWC2A0","fmgwoorddmdcst_woorddmd__r":{"Id":"a9mDK000000LD3uYAG","rstk__woorddmd_ordno__c":"a9hDK000000L0X8YAK","rstk__woorddmd_desc__c":"TENT CARD CRYSTAL   PASSION IN HOUSE USE","rstk__woorddmd_qtyreq__c":10.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxP2AQ","rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0X8YAK","rstk__wocst_ordno__c":"WO-1112"},"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxP2AQ","rstk__icitem_item__c":"a35DK000001aG09YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG09YAE","rstk__peitem_item__c":"1049DC"}}},"fmgwoorddmdcst_woorddmdcst__r":{"Id":"a9nDK0000032zM7YAI","rstk__woorddmdcst_locnum__c":"HC17FF00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":10.000000,"rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}},"fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbWC2A0","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}}',fmgwoorddmdcst__c.class);
            getFMGWorkOrderComponentBatchDataRaw.add(record);
            record = (fmgwoorddmdcst__c)json.deserializeStrict('{"Id":"aELDK000000Gmcm4AC","batchId__c":1,"fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD3nYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zMCYAY","fmgwoorddmdcst_sydata__c":"a8XDK000000PbWD2A0","fmgwoorddmdcst_woorddmd__r":{"Id":"a9mDK000000LD3nYAG","rstk__woorddmd_ordno__c":"a9hDK000000L0WtYAK","rstk__woorddmd_desc__c":"TENT CARD CRYSTAL   PASSION IN HOUSE USE","rstk__woorddmd_qtyreq__c":10.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxP2AQ","rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0WtYAK","rstk__wocst_ordno__c":"WO-1109"},"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxP2AQ","rstk__icitem_item__c":"a35DK000001aG09YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG09YAE","rstk__peitem_item__c":"1049DC"}}},"fmgwoorddmdcst_woorddmdcst__r":{"Id":"a9nDK0000032zMCYAY","rstk__woorddmdcst_locnum__c":"HC17FF00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":10.000000,"rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}},"fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbWD2A0","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}}',fmgwoorddmdcst__c.class);
            getFMGWorkOrderComponentBatchDataRaw.add(record);

        }
        public List<fmgwoorddmdcst__c> getFMGWorkOrderComponentBatchDataRaw{get;set;}
        public List<fmgwoorddmdcst__c> getFMGWorkOrderComponentBatchData(Integer batchId) {
            return getFMGWorkOrderComponentBatchDataRaw;
        }

        private void addGetWorkOrderComponents_workOrderIdsDataRaw(){
            getWorkOrderComponents_workOrderIdsDataRaw = new List<AggregateResult>();
            AggregateResult record = (AggregateResult)json.deserializeStrict('{"Id":"a9hDK000000L0V7YAK"}',AggregateResult.class);
            getWorkOrderComponents_workOrderIdsDataRaw.add(record);
            record = (AggregateResult)json.deserializeStrict('{"Id":"a9hDK000000L0WtYAK"}',AggregateResult.class);
            getWorkOrderComponents_workOrderIdsDataRaw.add(record);
            record = (AggregateResult)json.deserializeStrict('{"Id":"a9hDK000000L0X8YAK"}',AggregateResult.class);
            getWorkOrderComponents_workOrderIdsDataRaw.add(record);
            record = (AggregateResult)json.deserializeStrict('{"Id":"a9hDK000000L0X3YAK"}',AggregateResult.class);
            getWorkOrderComponents_workOrderIdsDataRaw.add(record);
            record = (AggregateResult)json.deserializeStrict('{"Id":"a9hDK000000L0Z4YAK"}',AggregateResult.class);
            getWorkOrderComponents_workOrderIdsDataRaw.add(record);
            record = (AggregateResult)json.deserializeStrict('{"Id":"a9hDK000000L0YzYAK"}',AggregateResult.class);
            getWorkOrderComponents_workOrderIdsDataRaw.add(record);
            record = (AggregateResult)json.deserializeStrict('{"Id":"a9hDK000000L0ZJYA0"}',AggregateResult.class);
            getWorkOrderComponents_workOrderIdsDataRaw.add(record);
        }
        public List<AggregateResult> getWorkOrderComponents_workOrderIdsDataRaw{get;set;}
        public List<AggregateResult> getWorkOrderComponents_workOrderIdsData(Integer batchSize) {
            return getWorkOrderComponents_workOrderIdsDataRaw;
        }

        private void addGetWorkOrderComponents_workOrdersItemsDataRaw(){
            getWorkOrderComponents_workOrdersItemsDataRaw = new List<rstk__woorddmd__c>();
            rstk__woorddmd__c record = (rstk__woorddmd__c)json.deserializeStrict('{"Id":"a9mDK000000LD62YAG","rstk__woorddmd_qtyoutstdg__c":0.000000,"rstk__woorddmd_desc__c":"TENT CARD CRYSTAL   PASSION IN HOUSE USE","rstk__woorddmd_compitem__c":"a1YDK000001iqxP2AQ","rstk__woorddmd_ordno__c":"a9hDK000000L0ZJYA0","rstk__woorddmd_qtyreq__c":100.000000,"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxP2AQ","rstk__icitem_item__c":"a35DK000001aG09YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG09YAE","rstk__peitem_item__c":"1049DC"}},"rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0ZJYA0","Name":"WO-1132","rstk__wocst_ordsts__c":"5","rstk__wocst_ordno__c":"WO-1132"}}',rstk__woorddmd__c.class);
            getWorkOrderComponents_workOrdersItemsDataRaw.add(record);
            record = (rstk__woorddmd__c)json.deserializeStrict('{"Id":"a9mDK000000LD63YAG","rstk__woorddmd_qtyoutstdg__c":0.000000,"rstk__woorddmd_desc__c":"Test for Mike Early","rstk__woorddmd_compitem__c":"a1YDK000001iuRe2AI","rstk__woorddmd_ordno__c":"a9hDK000000L0ZJYA0","rstk__woorddmd_qtyreq__c":1.000000,"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iuRe2AI","rstk__icitem_item__c":"a35DK000001bBHaYAM","rstk__icitem_item__r":{"Id":"a35DK000001bBHaYAM","rstk__peitem_item__c":"FMG - Parent"}},"rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0ZJYA0","Name":"WO-1132","rstk__wocst_ordsts__c":"5","rstk__wocst_ordno__c":"WO-1132"}}',rstk__woorddmd__c.class);
            getWorkOrderComponents_workOrdersItemsDataRaw.add(record);
            record = (rstk__woorddmd__c)json.deserializeStrict('{"Id":"a9mDK000000LD5xYAG","rstk__woorddmd_qtyoutstdg__c":0.000000,"rstk__woorddmd_desc__c":"TENT CARD CRYSTAL   PASSION IN HOUSE USE","rstk__woorddmd_compitem__c":"a1YDK000001iqxP2AQ","rstk__woorddmd_ordno__c":"a9hDK000000L0YzYAK","rstk__woorddmd_qtyreq__c":100.000000,"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxP2AQ","rstk__icitem_item__c":"a35DK000001aG09YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG09YAE","rstk__peitem_item__c":"1049DC"}},"rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0YzYAK","Name":"WO-1130","rstk__wocst_ordsts__c":"5","rstk__wocst_ordno__c":"WO-1130"}}',rstk__woorddmd__c.class);
            getWorkOrderComponents_workOrdersItemsDataRaw.add(record);
            record = (rstk__woorddmd__c)json.deserializeStrict('{"Id":"a9mDK000000LD5yYAG","rstk__woorddmd_qtyoutstdg__c":0.000000,"rstk__woorddmd_desc__c":"Test for Mike Early","rstk__woorddmd_compitem__c":"a1YDK000001iuRe2AI","rstk__woorddmd_ordno__c":"a9hDK000000L0YzYAK","rstk__woorddmd_qtyreq__c":1.000000,"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iuRe2AI","rstk__icitem_item__c":"a35DK000001bBHaYAM","rstk__icitem_item__r":{"Id":"a35DK000001bBHaYAM","rstk__peitem_item__c":"FMG - Parent"}},"rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0YzYAK","Name":"WO-1130","rstk__wocst_ordsts__c":"5","rstk__wocst_ordno__c":"WO-1130"}}',rstk__woorddmd__c.class);
            getWorkOrderComponents_workOrdersItemsDataRaw.add(record);
            record = (rstk__woorddmd__c)json.deserializeStrict('{"Id":"a9mDK000000LD5sYAG","rstk__woorddmd_qtyoutstdg__c":0.000000,"rstk__woorddmd_desc__c":"TENT CARD CRYSTAL   PASSION IN HOUSE USE","rstk__woorddmd_compitem__c":"a1YDK000001iqxP2AQ","rstk__woorddmd_ordno__c":"a9hDK000000L0Z4YAK","rstk__woorddmd_qtyreq__c":100.000000,"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxP2AQ","rstk__icitem_item__c":"a35DK000001aG09YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG09YAE","rstk__peitem_item__c":"1049DC"}},"rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0Z4YAK","Name":"WO-1131","rstk__wocst_ordsts__c":"5","rstk__wocst_ordno__c":"WO-1131"}}',rstk__woorddmd__c.class);
            getWorkOrderComponents_workOrdersItemsDataRaw.add(record);
            record = (rstk__woorddmd__c)json.deserializeStrict('{"Id":"a9mDK000000LD5tYAG","rstk__woorddmd_qtyoutstdg__c":0.000000,"rstk__woorddmd_desc__c":"Test for Mike Early","rstk__woorddmd_compitem__c":"a1YDK000001iuRe2AI","rstk__woorddmd_ordno__c":"a9hDK000000L0Z4YAK","rstk__woorddmd_qtyreq__c":1.000000,"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iuRe2AI","rstk__icitem_item__c":"a35DK000001bBHaYAM","rstk__icitem_item__r":{"Id":"a35DK000001bBHaYAM","rstk__peitem_item__c":"FMG - Parent"}},"rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0Z4YAK","Name":"WO-1131","rstk__wocst_ordsts__c":"5","rstk__wocst_ordno__c":"WO-1131"}}',rstk__woorddmd__c.class);
            getWorkOrderComponents_workOrdersItemsDataRaw.add(record);
            record = (rstk__woorddmd__c)json.deserializeStrict('{"Id":"a9mDK000000LD4BYAW","rstk__woorddmd_qtyoutstdg__c":0.000000,"rstk__woorddmd_desc__c":"SWAROV CRYSTAL AB   BICONE 4MM PK1440","rstk__woorddmd_compitem__c":"a1YDK000001ihA62AI","rstk__woorddmd_ordno__c":"a9hDK000000L0WtYAK","rstk__woorddmd_qtyreq__c":1.000000,"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001ihA62AI","rstk__icitem_item__c":"a35DK000001ZhjXYAS","rstk__icitem_item__r":{"Id":"a35DK000001ZhjXYAS","rstk__peitem_item__c":"3177CY"}},"rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0WtYAK","Name":"WO-1109","rstk__wocst_ordsts__c":"5","rstk__wocst_ordno__c":"WO-1109"}}',rstk__woorddmd__c.class);
            getWorkOrderComponents_workOrdersItemsDataRaw.add(record);
            record = (rstk__woorddmd__c)json.deserializeStrict('{"Id":"a9mDK000000LD3vYAG","rstk__woorddmd_qtyoutstdg__c":1.000000,"rstk__woorddmd_desc__c":"SWAROV DENIM BL     BICONE 4MM PK1440","rstk__woorddmd_compitem__c":"a1YDK000001irdJ2AQ","rstk__woorddmd_ordno__c":"a9hDK000000L0X3YAK","rstk__woorddmd_qtyreq__c":1.000000,"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001irdJ2AQ","rstk__icitem_item__c":"a35DK000001aW7pYAE","rstk__icitem_item__r":{"Id":"a35DK000001aW7pYAE","rstk__peitem_item__c":"6311CR"}},"rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0X3YAK","Name":"WO-1111","rstk__wocst_ordsts__c":"5","rstk__wocst_ordno__c":"WO-1111"}}',rstk__woorddmd__c.class);
            getWorkOrderComponents_workOrdersItemsDataRaw.add(record);
            record = (rstk__woorddmd__c)json.deserializeStrict('{"Id":"a9mDK000000LD3yYAG","rstk__woorddmd_qtyoutstdg__c":0.000000,"rstk__woorddmd_desc__c":"CRYSTAL CLEAR ZIP BAG 2X2IN CASE","rstk__woorddmd_compitem__c":"a1YDK000001iqxK2AQ","rstk__woorddmd_ordno__c":"a9hDK000000L0X3YAK","rstk__woorddmd_qtyreq__c":10.000000,"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxK2AQ","rstk__icitem_item__c":"a35DK000001aG04YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG04YAE","rstk__peitem_item__c":"1233DC"}},"rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0X3YAK","Name":"WO-1111","rstk__wocst_ordsts__c":"5","rstk__wocst_ordno__c":"WO-1111"}}',rstk__woorddmd__c.class);
            getWorkOrderComponents_workOrdersItemsDataRaw.add(record);
            record = (rstk__woorddmd__c)json.deserializeStrict('{"Id":"a9mDK000000LD3xYAG","rstk__woorddmd_qtyoutstdg__c":0.000000,"rstk__woorddmd_desc__c":"TENT CARD CRYSTAL   PASSION IN HOUSE USE","rstk__woorddmd_compitem__c":"a1YDK000001iqxP2AQ","rstk__woorddmd_ordno__c":"a9hDK000000L0X3YAK","rstk__woorddmd_qtyreq__c":10.000000,"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxP2AQ","rstk__icitem_item__c":"a35DK000001aG09YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG09YAE","rstk__peitem_item__c":"1049DC"}},"rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0X3YAK","Name":"WO-1111","rstk__wocst_ordsts__c":"5","rstk__wocst_ordno__c":"WO-1111"}}',rstk__woorddmd__c.class);
            getWorkOrderComponents_workOrdersItemsDataRaw.add(record);
            record = (rstk__woorddmd__c)json.deserializeStrict('{"Id":"a9mDK000000LD3wYAG","rstk__woorddmd_qtyoutstdg__c":10.000000,"rstk__woorddmd_desc__c":"SWINGLINE S.F. PREMIUM 1/4IN -35108 BOX","rstk__woorddmd_compitem__c":"a1YDK000001iqxU2AQ","rstk__woorddmd_ordno__c":"a9hDK000000L0X3YAK","rstk__woorddmd_qtyreq__c":10.000000,"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxU2AQ","rstk__icitem_item__c":"a35DK000001aG0EYAU","rstk__icitem_item__r":{"Id":"a35DK000001aG0EYAU","rstk__peitem_item__c":"1295DC"}},"rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0X3YAK","Name":"WO-1111","rstk__wocst_ordsts__c":"5","rstk__wocst_ordno__c":"WO-1111"}}',rstk__woorddmd__c.class);
            getWorkOrderComponents_workOrdersItemsDataRaw.add(record);
            record = (rstk__woorddmd__c)json.deserializeStrict('{"Id":"a9mDK000000LD3rYAG","rstk__woorddmd_qtyoutstdg__c":0.000000,"rstk__woorddmd_desc__c":"SWAROV ROSE GOLD 2X BICONE 3MM PK/1440","rstk__woorddmd_compitem__c":"a1YDK000001isE52AI","rstk__woorddmd_ordno__c":"a9hDK000000L0X8YAK","rstk__woorddmd_qtyreq__c":1.000000,"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001isE52AI","rstk__icitem_item__c":"a35DK000001aZhvYAE","rstk__icitem_item__r":{"Id":"a35DK000001aZhvYAE","rstk__peitem_item__c":"A2655CY"}},"rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0X8YAK","Name":"WO-1112","rstk__wocst_ordsts__c":"5","rstk__wocst_ordno__c":"WO-1112"}}',rstk__woorddmd__c.class);
            getWorkOrderComponents_workOrdersItemsDataRaw.add(record);
            record = (rstk__woorddmd__c)json.deserializeStrict('{"Id":"a9mDK000000LD3uYAG","rstk__woorddmd_qtyoutstdg__c":0.000000,"rstk__woorddmd_desc__c":"TENT CARD CRYSTAL   PASSION IN HOUSE USE","rstk__woorddmd_compitem__c":"a1YDK000001iqxP2AQ","rstk__woorddmd_ordno__c":"a9hDK000000L0X8YAK","rstk__woorddmd_qtyreq__c":10.000000,"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxP2AQ","rstk__icitem_item__c":"a35DK000001aG09YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG09YAE","rstk__peitem_item__c":"1049DC"}},"rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0X8YAK","Name":"WO-1112","rstk__wocst_ordsts__c":"5","rstk__wocst_ordno__c":"WO-1112"}}',rstk__woorddmd__c.class);
            getWorkOrderComponents_workOrdersItemsDataRaw.add(record);
            record = (rstk__woorddmd__c)json.deserializeStrict('{"Id":"a9mDK000000LD3tYAG","rstk__woorddmd_qtyoutstdg__c":10.000000,"rstk__woorddmd_desc__c":"SWINGLINE S.F. PREMIUM 1/4IN -35108 BOX","rstk__woorddmd_compitem__c":"a1YDK000001iqxU2AQ","rstk__woorddmd_ordno__c":"a9hDK000000L0X8YAK","rstk__woorddmd_qtyreq__c":10.000000,"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxU2AQ","rstk__icitem_item__c":"a35DK000001aG0EYAU","rstk__icitem_item__r":{"Id":"a35DK000001aG0EYAU","rstk__peitem_item__c":"1295DC"}},"rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0X8YAK","Name":"WO-1112","rstk__wocst_ordsts__c":"5","rstk__wocst_ordno__c":"WO-1112"}}',rstk__woorddmd__c.class);
            getWorkOrderComponents_workOrdersItemsDataRaw.add(record);
            record = (rstk__woorddmd__c)json.deserializeStrict('{"Id":"a9mDK000000LD3sYAG","rstk__woorddmd_qtyoutstdg__c":0.000000,"rstk__woorddmd_desc__c":"CRYSTAL CLEAR ZIP BAG 2X2IN CASE","rstk__woorddmd_compitem__c":"a1YDK000001iqxK2AQ","rstk__woorddmd_ordno__c":"a9hDK000000L0X8YAK","rstk__woorddmd_qtyreq__c":10.000000,"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxK2AQ","rstk__icitem_item__c":"a35DK000001aG04YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG04YAE","rstk__peitem_item__c":"1233DC"}},"rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0X8YAK","Name":"WO-1112","rstk__wocst_ordsts__c":"5","rstk__wocst_ordno__c":"WO-1112"}}',rstk__woorddmd__c.class);
            getWorkOrderComponents_workOrdersItemsDataRaw.add(record);
            record = (rstk__woorddmd__c)json.deserializeStrict('{"Id":"a9mDK000000LD3mYAG","rstk__woorddmd_qtyoutstdg__c":0.000000,"rstk__woorddmd_desc__c":"CRYSTAL CLEAR ZIP BAG 2X2IN CASE","rstk__woorddmd_compitem__c":"a1YDK000001iqxK2AQ","rstk__woorddmd_ordno__c":"a9hDK000000L0WtYAK","rstk__woorddmd_qtyreq__c":10.000000,"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxK2AQ","rstk__icitem_item__c":"a35DK000001aG04YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG04YAE","rstk__peitem_item__c":"1233DC"}},"rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0WtYAK","Name":"WO-1109","rstk__wocst_ordsts__c":"5","rstk__wocst_ordno__c":"WO-1109"}}',rstk__woorddmd__c.class);
            getWorkOrderComponents_workOrdersItemsDataRaw.add(record);
            record = (rstk__woorddmd__c)json.deserializeStrict('{"Id":"a9mDK000000LD3oYAG","rstk__woorddmd_qtyoutstdg__c":10.000000,"rstk__woorddmd_desc__c":"SWINGLINE S.F. PREMIUM 1/4IN -35108 BOX","rstk__woorddmd_compitem__c":"a1YDK000001iqxU2AQ","rstk__woorddmd_ordno__c":"a9hDK000000L0WtYAK","rstk__woorddmd_qtyreq__c":10.000000,"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxU2AQ","rstk__icitem_item__c":"a35DK000001aG0EYAU","rstk__icitem_item__r":{"Id":"a35DK000001aG0EYAU","rstk__peitem_item__c":"1295DC"}},"rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0WtYAK","Name":"WO-1109","rstk__wocst_ordsts__c":"5","rstk__wocst_ordno__c":"WO-1109"}}',rstk__woorddmd__c.class);
            getWorkOrderComponents_workOrdersItemsDataRaw.add(record);
            record = (rstk__woorddmd__c)json.deserializeStrict('{"Id":"a9mDK000000LD3nYAG","rstk__woorddmd_qtyoutstdg__c":0.000000,"rstk__woorddmd_desc__c":"TENT CARD CRYSTAL   PASSION IN HOUSE USE","rstk__woorddmd_compitem__c":"a1YDK000001iqxP2AQ","rstk__woorddmd_ordno__c":"a9hDK000000L0WtYAK","rstk__woorddmd_qtyreq__c":10.000000,"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxP2AQ","rstk__icitem_item__c":"a35DK000001aG09YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG09YAE","rstk__peitem_item__c":"1049DC"}},"rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0WtYAK","Name":"WO-1109","rstk__wocst_ordsts__c":"5","rstk__wocst_ordno__c":"WO-1109"}}',rstk__woorddmd__c.class);
            getWorkOrderComponents_workOrdersItemsDataRaw.add(record);
            record = (rstk__woorddmd__c)json.deserializeStrict('{"Id":"a9mDK000000LD2ZYAW","rstk__woorddmd_qtyoutstdg__c":0.000000,"rstk__woorddmd_desc__c":"SWAROV DENIM BL     BICONE 4MM PK1440","rstk__woorddmd_compitem__c":"a1YDK000001irdJ2AQ","rstk__woorddmd_ordno__c":"a9hDK000000L0V7YAK","rstk__woorddmd_qtyreq__c":5.000000,"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001irdJ2AQ","rstk__icitem_item__c":"a35DK000001aW7pYAE","rstk__icitem_item__r":{"Id":"a35DK000001aW7pYAE","rstk__peitem_item__c":"6311CR"}},"rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0V7YAK","Name":"WO-1108","rstk__wocst_ordsts__c":"5","rstk__wocst_ordno__c":"WO-1108"}}',rstk__woorddmd__c.class);
            getWorkOrderComponents_workOrdersItemsDataRaw.add(record);
            record = (rstk__woorddmd__c)json.deserializeStrict('{"Id":"a9mDK000000LD2aYAG","rstk__woorddmd_qtyoutstdg__c":0.000000,"rstk__woorddmd_desc__c":"SWINGLINE S.F. PREMIUM 1/4IN -35108 BOX","rstk__woorddmd_compitem__c":"a1YDK000001iqxU2AQ","rstk__woorddmd_ordno__c":"a9hDK000000L0V7YAK","rstk__woorddmd_qtyreq__c":50.000000,"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxU2AQ","rstk__icitem_item__c":"a35DK000001aG0EYAU","rstk__icitem_item__r":{"Id":"a35DK000001aG0EYAU","rstk__peitem_item__c":"1295DC"}},"rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0V7YAK","Name":"WO-1108","rstk__wocst_ordsts__c":"5","rstk__wocst_ordno__c":"WO-1108"}}',rstk__woorddmd__c.class);
            getWorkOrderComponents_workOrdersItemsDataRaw.add(record);
            record = (rstk__woorddmd__c)json.deserializeStrict('{"Id":"a9mDK000000LD2bYAG","rstk__woorddmd_qtyoutstdg__c":0.000000,"rstk__woorddmd_desc__c":"TENT CARD CRYSTAL   PASSION IN HOUSE USE","rstk__woorddmd_compitem__c":"a1YDK000001iqxP2AQ","rstk__woorddmd_ordno__c":"a9hDK000000L0V7YAK","rstk__woorddmd_qtyreq__c":50.000000,"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxP2AQ","rstk__icitem_item__c":"a35DK000001aG09YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG09YAE","rstk__peitem_item__c":"1049DC"}},"rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0V7YAK","Name":"WO-1108","rstk__wocst_ordsts__c":"5","rstk__wocst_ordno__c":"WO-1108"}}',rstk__woorddmd__c.class);
            getWorkOrderComponents_workOrdersItemsDataRaw.add(record);
            record = (rstk__woorddmd__c)json.deserializeStrict('{"Id":"a9mDK000000LD2cYAG","rstk__woorddmd_qtyoutstdg__c":29.000000,"rstk__woorddmd_desc__c":"CRYSTAL CLEAR ZIP BAG 2X2IN CASE","rstk__woorddmd_compitem__c":"a1YDK000001iqxK2AQ","rstk__woorddmd_ordno__c":"a9hDK000000L0V7YAK","rstk__woorddmd_qtyreq__c":50.000000,"rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxK2AQ","rstk__icitem_item__c":"a35DK000001aG04YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG04YAE","rstk__peitem_item__c":"1233DC"}},"rstk__woorddmd_ordno__r":{"Id":"a9hDK000000L0V7YAK","Name":"WO-1108","rstk__wocst_ordsts__c":"5","rstk__wocst_ordno__c":"WO-1108"}}',rstk__woorddmd__c.class);
            getWorkOrderComponents_workOrdersItemsDataRaw.add(record);

        }
        public List<rstk__woorddmd__c> getWorkOrderComponents_workOrdersItemsDataRaw{get;set;}
        public List<rstk__woorddmd__c> getWorkOrderComponents_workOrdersItemsData(Set<Id> workOrderIds) {
            return getWorkOrderComponents_workOrdersItemsDataRaw;




        }

        private void addGetFMGWorkOrderComponent_WorkOrdersDataRaw(){
            getFMGWorkOrderComponent_WorkOrdersDataRaw = new List<rstk__wocst__c>();
            rstk__wocst__c record = (rstk__wocst__c)json.deserializeStrict('{"Id":"a9hDK000000L0V7YAK","rstk__wocst_ordno__c":"WO-1108","fmgwoorddmdcst_wocst__r":{"totalSize":10,"done":true,"records":[{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0V7YAK","Id":"aELDK000000GmcZ4AS","batchId__c":1,"fmgwoorddmdcst_sydata__c":"a8XDK000000PbSS2A0","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD2bYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zMHYAY","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbSS2A0","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0V7YAK","Id":"aELDK000000Gmca4AC","batchId__c":1,"fmgwoorddmdcst_sydata__c":"a8XDK000000PbST2A0","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD2cYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zMRYAY","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbST2A0","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0V7YAK","Id":"aELDK000000Gmcs4AC","batchId__c":6,"fmgwoorddmdcst_sydata__c":"a8XDK000000PbWd2AK","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD2aYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zMgYAI","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbWd2AK","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0V7YAK","Id":"aELDK000000Gmcr4AC","batchId__c":6,"fmgwoorddmdcst_sydata__c":"a8XDK000000PbWc2AK","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD2ZYAW","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zMbYAI","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbWc2AK","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0V7YAK","Id":"aELDK000000Gmcq4AC","batchId__c":6,"fmgwoorddmdcst_sydata__c":"a8XDK000000PbWb2AK","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD2cYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zMWYAY","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbWb2AK","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0V7YAK","Id":"aELDK000000Gmcp4AC","batchId__c":6,"fmgwoorddmdcst_sydata__c":"a8XDK000000PbWa2AK","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD2cYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zMRYAY","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbWa2AK","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0V7YAK","Id":"aELDK000000Gmcb4AC","batchId__c":1,"fmgwoorddmdcst_sydata__c":"a8XDK000000PbSU2A0","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD2cYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zMWYAY","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbSU2A0","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0V7YAK","Id":"aELDK000000Gmcc4AC","batchId__c":1,"fmgwoorddmdcst_sydata__c":"a8XDK000000PbSV2A0","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD2cYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zMMYAY","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbSV2A0","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0V7YAK","Id":"aELDK000000Gmcn4AC","batchId__c":6,"fmgwoorddmdcst_sydata__c":"a8XDK000000PbWY2A0","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD2bYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zMHYAY","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbWY2A0","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0V7YAK","Id":"aELDK000000Gmco4AC","batchId__c":6,"fmgwoorddmdcst_sydata__c":"a8XDK000000PbWZ2A0","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD2cYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zMMYAY","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbWZ2A0","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}}]},"rstk__WOORDDMDs__r":{"totalSize":4,"done":true,"records":[{"rstk__woorddmd_ordno__c":"a9hDK000000L0V7YAK","Id":"a9mDK000000LD2aYAG","rstk__woorddmd_desc__c":"SWINGLINE S.F. PREMIUM 1/4IN -35108 BOX","rstk__woorddmd_qtyreq__c":50.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxU2AQ","rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxU2AQ","rstk__icitem_item__c":"a35DK000001aG0EYAU","rstk__icitem_item__r":{"Id":"a35DK000001aG0EYAU","rstk__peitem_item__c":"1295DC"}}},{"rstk__woorddmd_ordno__c":"a9hDK000000L0V7YAK","Id":"a9mDK000000LD2ZYAW","rstk__woorddmd_desc__c":"SWAROV DENIM BL     BICONE 4MM PK1440","rstk__woorddmd_qtyreq__c":5.000000,"rstk__woorddmd_compitem__c":"a1YDK000001irdJ2AQ","rstk__woorddmd_compitem__r":{"Id":"a1YDK000001irdJ2AQ","rstk__icitem_item__c":"a35DK000001aW7pYAE","rstk__icitem_item__r":{"Id":"a35DK000001aW7pYAE","rstk__peitem_item__c":"6311CR"}}},{"rstk__woorddmd_ordno__c":"a9hDK000000L0V7YAK","Id":"a9mDK000000LD2bYAG","rstk__woorddmd_desc__c":"TENT CARD CRYSTAL   PASSION IN HOUSE USE","rstk__woorddmd_qtyreq__c":50.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxP2AQ","rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxP2AQ","rstk__icitem_item__c":"a35DK000001aG09YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG09YAE","rstk__peitem_item__c":"1049DC"}}},{"rstk__woorddmd_ordno__c":"a9hDK000000L0V7YAK","Id":"a9mDK000000LD2cYAG","rstk__woorddmd_desc__c":"CRYSTAL CLEAR ZIP BAG 2X2IN CASE","rstk__woorddmd_qtyreq__c":50.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxK2AQ","rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxK2AQ","rstk__icitem_item__c":"a35DK000001aG04YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG04YAE","rstk__peitem_item__c":"1233DC"}}}]},"rstk__woorddmdcsts__r":{"totalSize":7,"done":true,"records":[{"rstk__woorddmdcst_ordno__c":"a9hDK000000L0V7YAK","Id":"a9nDK0000032zMHYAY","rstk__woorddmdcst_locnum__c":"HC17FF00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":50.000000,"rstk__woorddmdcst_woorddmd__c":"a9mDK000000LD2bYAG","rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}},{"rstk__woorddmdcst_ordno__c":"a9hDK000000L0V7YAK","Id":"a9nDK0000032zMMYAY","rstk__woorddmdcst_locnum__c":"HC23FF00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":7.000000,"rstk__woorddmdcst_woorddmd__c":"a9mDK000000LD2cYAG","rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}},{"rstk__woorddmdcst_ordno__c":"a9hDK000000L0V7YAK","Id":"a9nDK0000032zMRYAY","rstk__woorddmdcst_locnum__c":"HC17FF00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":7.000000,"rstk__woorddmdcst_woorddmd__c":"a9mDK000000LD2cYAG","rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}},{"rstk__woorddmdcst_ordno__c":"a9hDK000000L0V7YAK","Id":"a9nDK0000032zMWYAY","rstk__woorddmdcst_locnum__c":"C10","rstk__woorddmdcst_locid__c":"a8uDK000000GqVAYA0","rstk__woorddmdcst_qtyiss__c":7.000000,"rstk__woorddmdcst_woorddmd__c":"a9mDK000000LD2cYAG","rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqVAYA0","rstk__sylocid_locid__c":"P1"}},{"rstk__woorddmdcst_ordno__c":"a9hDK000000L0V7YAK","Id":"a9nDK0000032zMbYAI","rstk__woorddmdcst_locnum__c":"REC","rstk__woorddmdcst_locid__c":"a8uDK000000GqbTYAS","rstk__woorddmdcst_qtyiss__c":2.000000,"rstk__woorddmdcst_woorddmd__c":"a9mDK000000LD2ZYAW","rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqbTYAS","rstk__sylocid_locid__c":"27"}},{"rstk__woorddmdcst_ordno__c":"a9hDK000000L0V7YAK","Id":"a9nDK0000032zMgYAI","rstk__woorddmdcst_locnum__c":"BULK-01-01","rstk__woorddmdcst_locid__c":"a8uDK000000GqbTYAS","rstk__woorddmdcst_qtyiss__c":50.000000,"rstk__woorddmdcst_woorddmd__c":"a9mDK000000LD2aYAG","rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqbTYAS","rstk__sylocid_locid__c":"27"}},{"rstk__woorddmdcst_ordno__c":"a9hDK000000L0V7YAK","Id":"a9nDK0000032zMcYAI","rstk__woorddmdcst_locnum__c":"REC","rstk__woorddmdcst_locid__c":"a8uDK000000GqbTYAS","rstk__woorddmdcst_qtyiss__c":3.000000,"rstk__woorddmdcst_woorddmd__c":"a9mDK000000LD2ZYAW","rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqbTYAS","rstk__sylocid_locid__c":"27"}}]}}',rstk__wocst__c.class);
            getFMGWorkOrderComponent_WorkOrdersDataRaw.add(record);
            record = (rstk__wocst__c)json.deserializeStrict('{"Id":"a9hDK000000L0WtYAK","rstk__wocst_ordno__c":"WO-1109","fmgwoorddmdcst_wocst__r":{"totalSize":5,"done":true,"records":[{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0WtYAK","Id":"aELDK000000Gn3F4AS","batchId__c":8,"fmgwoorddmdcst_sydata__c":"a8XDK000000Pc4i2AC","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD3nYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zMCYAY","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000Pc4i2AC","rstk__sydata_message__c":"Transaction Quantity must be greater than zero for a non-serial component.","rstk__sydata_process__c":"Validation Failure","rstk__sydata_txntype__c":"WO Issue"}},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0WtYAK","Id":"aELDK000000Gn3E4AS","batchId__c":8,"fmgwoorddmdcst_sydata__c":"a8XDK000000Pc4h2AC","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD3mYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zysYAA","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000Pc4h2AC","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0WtYAK","Id":"aELDK000000Gn3A4AS","batchId__c":8,"fmgwoorddmdcst_sydata__c":"a8XDK000000Pc4d2AC","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD4BYAW","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zHMYAY","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000Pc4d2AC","rstk__sydata_message__c":"Transaction Quantity must be greater than zero for a non-serial component.","rstk__sydata_process__c":"Validation Failure","rstk__sydata_txntype__c":"WO Issue"}},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0WtYAK","Id":"aELDK000000Gmcm4AC","batchId__c":1,"fmgwoorddmdcst_sydata__c":"a8XDK000000PbWD2A0","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD3nYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zMCYAY","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbWD2A0","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0WtYAK","Id":"aELDK000000Gn3H4AS","batchId__c":8,"fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD3oYAG"}]},"rstk__WOORDDMDs__r":{"totalSize":4,"done":true,"records":[{"rstk__woorddmd_ordno__c":"a9hDK000000L0WtYAK","Id":"a9mDK000000LD3mYAG","rstk__woorddmd_desc__c":"CRYSTAL CLEAR ZIP BAG 2X2IN CASE","rstk__woorddmd_qtyreq__c":10.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxK2AQ","rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxK2AQ","rstk__icitem_item__c":"a35DK000001aG04YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG04YAE","rstk__peitem_item__c":"1233DC"}}},{"rstk__woorddmd_ordno__c":"a9hDK000000L0WtYAK","Id":"a9mDK000000LD3nYAG","rstk__woorddmd_desc__c":"TENT CARD CRYSTAL   PASSION IN HOUSE USE","rstk__woorddmd_qtyreq__c":10.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxP2AQ","rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxP2AQ","rstk__icitem_item__c":"a35DK000001aG09YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG09YAE","rstk__peitem_item__c":"1049DC"}}},{"rstk__woorddmd_ordno__c":"a9hDK000000L0WtYAK","Id":"a9mDK000000LD3oYAG","rstk__woorddmd_desc__c":"SWINGLINE S.F. PREMIUM 1/4IN -35108 BOX","rstk__woorddmd_qtyreq__c":10.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxU2AQ","rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxU2AQ","rstk__icitem_item__c":"a35DK000001aG0EYAU","rstk__icitem_item__r":{"Id":"a35DK000001aG0EYAU","rstk__peitem_item__c":"1295DC"}}},{"rstk__woorddmd_ordno__c":"a9hDK000000L0WtYAK","Id":"a9mDK000000LD4BYAW","rstk__woorddmd_desc__c":"SWAROV CRYSTAL AB   BICONE 4MM PK1440","rstk__woorddmd_qtyreq__c":1.000000,"rstk__woorddmd_compitem__c":"a1YDK000001ihA62AI","rstk__woorddmd_compitem__r":{"Id":"a1YDK000001ihA62AI","rstk__icitem_item__c":"a35DK000001ZhjXYAS","rstk__icitem_item__r":{"Id":"a35DK000001ZhjXYAS","rstk__peitem_item__c":"3177CY"}}}]},"rstk__woorddmdcsts__r":{"totalSize":3,"done":true,"records":[{"rstk__woorddmdcst_ordno__c":"a9hDK000000L0WtYAK","Id":"a9nDK0000032zMCYAY","rstk__woorddmdcst_locnum__c":"HC17FF00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":10.000000,"rstk__woorddmdcst_woorddmd__c":"a9mDK000000LD3nYAG","rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}},{"rstk__woorddmdcst_ordno__c":"a9hDK000000L0WtYAK","Id":"a9nDK0000032zHMYAY","rstk__woorddmdcst_locnum__c":"HJ36GG00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":1.000000,"rstk__woorddmdcst_woorddmd__c":"a9mDK000000LD4BYAW","rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}},{"rstk__woorddmdcst_ordno__c":"a9hDK000000L0WtYAK","Id":"a9nDK0000032zysYAA","rstk__woorddmdcst_locnum__c":"HB10BB00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":10.000000,"rstk__woorddmdcst_woorddmd__c":"a9mDK000000LD3mYAG","rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}}]}}',rstk__wocst__c.class);
            getFMGWorkOrderComponent_WorkOrdersDataRaw.add(record);
            record = (rstk__wocst__c)json.deserializeStrict('{"Id":"a9hDK000000L0X8YAK","rstk__wocst_ordno__c":"WO-1112","fmgwoorddmdcst_wocst__r":{"totalSize":6,"done":true,"records":[{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0X8YAK","Id":"aELDK000000Gmck4AC","batchId__c":1,"fmgwoorddmdcst_sydata__c":"a8XDK000000PbWB2A0","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD3rYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zM2YAI","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbWB2A0","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0X8YAK","Id":"aELDK000000Gmcl4AC","batchId__c":1,"fmgwoorddmdcst_sydata__c":"a8XDK000000PbWC2A0","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD3uYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zM7YAI","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbWC2A0","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0X8YAK","Id":"aELDK000000Gn3G4AS","batchId__c":8,"fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD3tYAG"},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0X8YAK","Id":"aELDK000000Gn3D4AS","batchId__c":8,"fmgwoorddmdcst_sydata__c":"a8XDK000000Pc4g2AC","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD3sYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zynYAA","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000Pc4g2AC","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0X8YAK","Id":"aELDK000000Gn3C4AS","batchId__c":8,"fmgwoorddmdcst_sydata__c":"a8XDK000000Pc4f2AC","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD3uYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zM7YAI","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000Pc4f2AC","rstk__sydata_message__c":"Transaction Quantity must be greater than zero for a non-serial component.","rstk__sydata_process__c":"Validation Failure","rstk__sydata_txntype__c":"WO Issue"}},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0X8YAK","Id":"aELDK000000Gn3B4AS","batchId__c":8,"fmgwoorddmdcst_sydata__c":"a8XDK000000Pc4e2AC","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD3rYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zM2YAI","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000Pc4e2AC","rstk__sydata_message__c":"Transaction Quantity must be greater than zero for a non-serial component.","rstk__sydata_process__c":"Validation Failure","rstk__sydata_txntype__c":"WO Issue"}}]},"rstk__WOORDDMDs__r":{"totalSize":4,"done":true,"records":[{"rstk__woorddmd_ordno__c":"a9hDK000000L0X8YAK","Id":"a9mDK000000LD3sYAG","rstk__woorddmd_desc__c":"CRYSTAL CLEAR ZIP BAG 2X2IN CASE","rstk__woorddmd_qtyreq__c":10.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxK2AQ","rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxK2AQ","rstk__icitem_item__c":"a35DK000001aG04YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG04YAE","rstk__peitem_item__c":"1233DC"}}},{"rstk__woorddmd_ordno__c":"a9hDK000000L0X8YAK","Id":"a9mDK000000LD3rYAG","rstk__woorddmd_desc__c":"SWAROV ROSE GOLD 2X BICONE 3MM PK/1440","rstk__woorddmd_qtyreq__c":1.000000,"rstk__woorddmd_compitem__c":"a1YDK000001isE52AI","rstk__woorddmd_compitem__r":{"Id":"a1YDK000001isE52AI","rstk__icitem_item__c":"a35DK000001aZhvYAE","rstk__icitem_item__r":{"Id":"a35DK000001aZhvYAE","rstk__peitem_item__c":"A2655CY"}}},{"rstk__woorddmd_ordno__c":"a9hDK000000L0X8YAK","Id":"a9mDK000000LD3tYAG","rstk__woorddmd_desc__c":"SWINGLINE S.F. PREMIUM 1/4IN -35108 BOX","rstk__woorddmd_qtyreq__c":10.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxU2AQ","rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxU2AQ","rstk__icitem_item__c":"a35DK000001aG0EYAU","rstk__icitem_item__r":{"Id":"a35DK000001aG0EYAU","rstk__peitem_item__c":"1295DC"}}},{"rstk__woorddmd_ordno__c":"a9hDK000000L0X8YAK","Id":"a9mDK000000LD3uYAG","rstk__woorddmd_desc__c":"TENT CARD CRYSTAL   PASSION IN HOUSE USE","rstk__woorddmd_qtyreq__c":10.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxP2AQ","rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxP2AQ","rstk__icitem_item__c":"a35DK000001aG09YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG09YAE","rstk__peitem_item__c":"1049DC"}}}]},"rstk__woorddmdcsts__r":{"totalSize":3,"done":true,"records":[{"rstk__woorddmdcst_ordno__c":"a9hDK000000L0X8YAK","Id":"a9nDK0000032zM2YAI","rstk__woorddmdcst_locnum__c":"HJ36GG00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":1.000000,"rstk__woorddmdcst_woorddmd__c":"a9mDK000000LD3rYAG","rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}},{"rstk__woorddmdcst_ordno__c":"a9hDK000000L0X8YAK","Id":"a9nDK0000032zynYAA","rstk__woorddmdcst_locnum__c":"HB10BB00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":10.000000,"rstk__woorddmdcst_woorddmd__c":"a9mDK000000LD3sYAG","rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}},{"rstk__woorddmdcst_ordno__c":"a9hDK000000L0X8YAK","Id":"a9nDK0000032zM7YAI","rstk__woorddmdcst_locnum__c":"HC17FF00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":10.000000,"rstk__woorddmdcst_woorddmd__c":"a9mDK000000LD3uYAG","rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}}]}}',rstk__wocst__c.class);
            getFMGWorkOrderComponent_WorkOrdersDataRaw.add(record);
            record = (rstk__wocst__c)json.deserializeStrict('{"Id":"a9hDK000000L0X3YAK","rstk__wocst_ordno__c":"WO-1111","fmgwoorddmdcst_wocst__r":{"totalSize":5,"done":true,"records":[{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0X3YAK","Id":"aELDK000000Gmcj4AC","batchId__c":1,"fmgwoorddmdcst_sydata__c":"a8XDK000000PbWA2A0","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD3xYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zLxYAI","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbWA2A0","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0X3YAK","Id":"aELDK000000Gn464AC","batchId__c":9,"fmgwoorddmdcst_sydata__c":"a8XDK000000PcT92AK","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD3xYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zLxYAI","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PcT92AK","rstk__sydata_message__c":"Transaction Quantity must be greater than zero for a non-serial component.","rstk__sydata_process__c":"Validation Failure","rstk__sydata_txntype__c":"WO Issue"}},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0X3YAK","Id":"aELDK000000Gn474AC","batchId__c":9,"fmgwoorddmdcst_sydata__c":"a8XDK000000PcTA2A0","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD3yYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK00000330tFYAQ","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PcTA2A0","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0X3YAK","Id":"aELDK000000Gn4G4AS","batchId__c":9,"fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD3vYAG"},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0X3YAK","Id":"aELDK000000Gn4H4AS","batchId__c":9,"fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD3wYAG"}]},"rstk__WOORDDMDs__r":{"totalSize":4,"done":true,"records":[{"rstk__woorddmd_ordno__c":"a9hDK000000L0X3YAK","Id":"a9mDK000000LD3vYAG","rstk__woorddmd_desc__c":"SWAROV DENIM BL     BICONE 4MM PK1440","rstk__woorddmd_qtyreq__c":1.000000,"rstk__woorddmd_compitem__c":"a1YDK000001irdJ2AQ","rstk__woorddmd_compitem__r":{"Id":"a1YDK000001irdJ2AQ","rstk__icitem_item__c":"a35DK000001aW7pYAE","rstk__icitem_item__r":{"Id":"a35DK000001aW7pYAE","rstk__peitem_item__c":"6311CR"}}},{"rstk__woorddmd_ordno__c":"a9hDK000000L0X3YAK","Id":"a9mDK000000LD3wYAG","rstk__woorddmd_desc__c":"SWINGLINE S.F. PREMIUM 1/4IN -35108 BOX","rstk__woorddmd_qtyreq__c":10.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxU2AQ","rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxU2AQ","rstk__icitem_item__c":"a35DK000001aG0EYAU","rstk__icitem_item__r":{"Id":"a35DK000001aG0EYAU","rstk__peitem_item__c":"1295DC"}}},{"rstk__woorddmd_ordno__c":"a9hDK000000L0X3YAK","Id":"a9mDK000000LD3xYAG","rstk__woorddmd_desc__c":"TENT CARD CRYSTAL   PASSION IN HOUSE USE","rstk__woorddmd_qtyreq__c":10.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxP2AQ","rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxP2AQ","rstk__icitem_item__c":"a35DK000001aG09YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG09YAE","rstk__peitem_item__c":"1049DC"}}},{"rstk__woorddmd_ordno__c":"a9hDK000000L0X3YAK","Id":"a9mDK000000LD3yYAG","rstk__woorddmd_desc__c":"CRYSTAL CLEAR ZIP BAG 2X2IN CASE","rstk__woorddmd_qtyreq__c":10.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxK2AQ","rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxK2AQ","rstk__icitem_item__c":"a35DK000001aG04YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG04YAE","rstk__peitem_item__c":"1233DC"}}}]},"rstk__woorddmdcsts__r":{"totalSize":2,"done":true,"records":[{"rstk__woorddmdcst_ordno__c":"a9hDK000000L0X3YAK","Id":"a9nDK0000032zLxYAI","rstk__woorddmdcst_locnum__c":"HC17FF00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":10.000000,"rstk__woorddmdcst_woorddmd__c":"a9mDK000000LD3xYAG","rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}},{"rstk__woorddmdcst_ordno__c":"a9hDK000000L0X3YAK","Id":"a9nDK00000330tFYAQ","rstk__woorddmdcst_locnum__c":"HB10BB00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":10.000000,"rstk__woorddmdcst_woorddmd__c":"a9mDK000000LD3yYAG","rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}}]}}',rstk__wocst__c.class);
            getFMGWorkOrderComponent_WorkOrdersDataRaw.add(record);
            record = (rstk__wocst__c)json.deserializeStrict('{"Id":"a9hDK000000L0YzYAK","rstk__wocst_ordno__c":"WO-1130","fmgwoorddmdcst_wocst__r":{"totalSize":2,"done":true,"records":[{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0YzYAK","Id":"aELDK000000Gmcg4AC","batchId__c":1,"fmgwoorddmdcst_sydata__c":"a8XDK000000PbW72AK","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD5xYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zLiYAI","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbW72AK","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0YzYAK","Id":"aELDK000000Gmch4AC","batchId__c":1,"fmgwoorddmdcst_sydata__c":"a8XDK000000PbW82AK","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD5yYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zLnYAI","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbW82AK","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}}]},"rstk__WOORDDMDs__r":{"totalSize":2,"done":true,"records":[{"rstk__woorddmd_ordno__c":"a9hDK000000L0YzYAK","Id":"a9mDK000000LD5xYAG","rstk__woorddmd_desc__c":"TENT CARD CRYSTAL   PASSION IN HOUSE USE","rstk__woorddmd_qtyreq__c":100.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxP2AQ","rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxP2AQ","rstk__icitem_item__c":"a35DK000001aG09YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG09YAE","rstk__peitem_item__c":"1049DC"}}},{"rstk__woorddmd_ordno__c":"a9hDK000000L0YzYAK","Id":"a9mDK000000LD5yYAG","rstk__woorddmd_desc__c":"Test for Mike Early","rstk__woorddmd_qtyreq__c":1.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iuRe2AI","rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iuRe2AI","rstk__icitem_item__c":"a35DK000001bBHaYAM","rstk__icitem_item__r":{"Id":"a35DK000001bBHaYAM","rstk__peitem_item__c":"FMG - Parent"}}}]},"rstk__woorddmdcsts__r":{"totalSize":2,"done":true,"records":[{"rstk__woorddmdcst_ordno__c":"a9hDK000000L0YzYAK","Id":"a9nDK0000032zLiYAI","rstk__woorddmdcst_locnum__c":"HC17FF00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":100.000000,"rstk__woorddmdcst_woorddmd__c":"a9mDK000000LD5xYAG","rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}},{"rstk__woorddmdcst_ordno__c":"a9hDK000000L0YzYAK","Id":"a9nDK0000032zLnYAI","rstk__woorddmdcst_locnum__c":"HN18AA00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":1.000000,"rstk__woorddmdcst_woorddmd__c":"a9mDK000000LD5yYAG","rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}}]}}',rstk__wocst__c.class);
            getFMGWorkOrderComponent_WorkOrdersDataRaw.add(record);
            record = (rstk__wocst__c)json.deserializeStrict('{"Id":"a9hDK000000L0Z4YAK","rstk__wocst_ordno__c":"WO-1131","fmgwoorddmdcst_wocst__r":{"totalSize":3,"done":true,"records":[{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0Z4YAK","Id":"aELDK000000Gn454AC","batchId__c":9,"fmgwoorddmdcst_sydata__c":"a8XDK000000PcT82AK","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD5tYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zIZYAY","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PcT82AK","rstk__sydata_message__c":"Transaction Quantity must be greater than zero for a non-serial component.","rstk__sydata_process__c":"Validation Failure","rstk__sydata_txntype__c":"WO Issue"}},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0Z4YAK","Id":"aELDK000000Gn444AC","batchId__c":9,"fmgwoorddmdcst_sydata__c":"a8XDK000000PcT72AK","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD5sYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zIUYAY","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PcT72AK","rstk__sydata_message__c":"Transaction Quantity must be greater than zero for a non-serial component.","rstk__sydata_process__c":"Validation Failure","rstk__sydata_txntype__c":"WO Issue"}},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0Z4YAK","Id":"aELDK000000Gmci4AC","batchId__c":1,"fmgwoorddmdcst_sydata__c":"a8XDK000000PbW92AK","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD5sYAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zIUYAY","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbW92AK","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}}]},"rstk__WOORDDMDs__r":{"totalSize":2,"done":true,"records":[{"rstk__woorddmd_ordno__c":"a9hDK000000L0Z4YAK","Id":"a9mDK000000LD5sYAG","rstk__woorddmd_desc__c":"TENT CARD CRYSTAL   PASSION IN HOUSE USE","rstk__woorddmd_qtyreq__c":100.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxP2AQ","rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxP2AQ","rstk__icitem_item__c":"a35DK000001aG09YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG09YAE","rstk__peitem_item__c":"1049DC"}}},{"rstk__woorddmd_ordno__c":"a9hDK000000L0Z4YAK","Id":"a9mDK000000LD5tYAG","rstk__woorddmd_desc__c":"Test for Mike Early","rstk__woorddmd_qtyreq__c":1.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iuRe2AI","rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iuRe2AI","rstk__icitem_item__c":"a35DK000001bBHaYAM","rstk__icitem_item__r":{"Id":"a35DK000001bBHaYAM","rstk__peitem_item__c":"FMG - Parent"}}}]},"rstk__woorddmdcsts__r":{"totalSize":3,"done":true,"records":[{"rstk__woorddmdcst_ordno__c":"a9hDK000000L0Z4YAK","Id":"a9nDK0000032zIUYAY","rstk__woorddmdcst_locnum__c":"HE18BB00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":50.000000,"rstk__woorddmdcst_woorddmd__c":"a9mDK000000LD5sYAG","rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}},{"rstk__woorddmdcst_ordno__c":"a9hDK000000L0Z4YAK","Id":"a9nDK0000032zLsYAI","rstk__woorddmdcst_locnum__c":"HC17FF00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":50.000000,"rstk__woorddmdcst_woorddmd__c":"a9mDK000000LD5sYAG","rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}},{"rstk__woorddmdcst_ordno__c":"a9hDK000000L0Z4YAK","Id":"a9nDK0000032zIZYAY","rstk__woorddmdcst_locnum__c":"HN18AA00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":1.000000,"rstk__woorddmdcst_woorddmd__c":"a9mDK000000LD5tYAG","rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}}]}}',rstk__wocst__c.class);
            getFMGWorkOrderComponent_WorkOrdersDataRaw.add(record);
            record = (rstk__wocst__c)json.deserializeStrict('{"Id":"a9hDK000000L0ZJYA0","rstk__wocst_ordno__c":"WO-1132","fmgwoorddmdcst_wocst__r":{"totalSize":2,"done":true,"records":[{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0ZJYA0","Id":"aELDK000000Gmce4AC","batchId__c":1,"fmgwoorddmdcst_sydata__c":"a8XDK000000PbW52AK","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD62YAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zLYYAY","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbW52AK","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}},{"fmgwoorddmdcst_wocst__c":"a9hDK000000L0ZJYA0","Id":"aELDK000000Gmcf4AC","batchId__c":1,"fmgwoorddmdcst_sydata__c":"a8XDK000000PbW62AK","fmgwoorddmdcst_woorddmd__c":"a9mDK000000LD63YAG","fmgwoorddmdcst_woorddmdcst__c":"a9nDK0000032zLdYAI","fmgwoorddmdcst_sydata__r":{"Id":"a8XDK000000PbW62AK","rstk__sydata_process__c":"ProcessingComplete","rstk__sydata_txntype__c":"WO Issue"}}]},"rstk__WOORDDMDs__r":{"totalSize":2,"done":true,"records":[{"rstk__woorddmd_ordno__c":"a9hDK000000L0ZJYA0","Id":"a9mDK000000LD62YAG","rstk__woorddmd_desc__c":"TENT CARD CRYSTAL   PASSION IN HOUSE USE","rstk__woorddmd_qtyreq__c":100.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iqxP2AQ","rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iqxP2AQ","rstk__icitem_item__c":"a35DK000001aG09YAE","rstk__icitem_item__r":{"Id":"a35DK000001aG09YAE","rstk__peitem_item__c":"1049DC"}}},{"rstk__woorddmd_ordno__c":"a9hDK000000L0ZJYA0","Id":"a9mDK000000LD63YAG","rstk__woorddmd_desc__c":"Test for Mike Early","rstk__woorddmd_qtyreq__c":1.000000,"rstk__woorddmd_compitem__c":"a1YDK000001iuRe2AI","rstk__woorddmd_compitem__r":{"Id":"a1YDK000001iuRe2AI","rstk__icitem_item__c":"a35DK000001bBHaYAM","rstk__icitem_item__r":{"Id":"a35DK000001bBHaYAM","rstk__peitem_item__c":"FMG - Parent"}}}]},"rstk__woorddmdcsts__r":{"totalSize":2,"done":true,"records":[{"rstk__woorddmdcst_ordno__c":"a9hDK000000L0ZJYA0","Id":"a9nDK0000032zLYYAY","rstk__woorddmdcst_locnum__c":"HC17FF00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":100.000000,"rstk__woorddmdcst_woorddmd__c":"a9mDK000000LD62YAG","rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}},{"rstk__woorddmdcst_ordno__c":"a9hDK000000L0ZJYA0","Id":"a9nDK0000032zLdYAI","rstk__woorddmdcst_locnum__c":"HN18AA00","rstk__woorddmdcst_locid__c":"a8uDK000000GqOcYAK","rstk__woorddmdcst_qtyiss__c":1.000000,"rstk__woorddmdcst_woorddmd__c":"a9mDK000000LD63YAG","rstk__woorddmdcst_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26"}}]}}',rstk__wocst__c.class);
            getFMGWorkOrderComponent_WorkOrdersDataRaw.add(record);
        }
        public List<rstk__wocst__c> getFMGWorkOrderComponent_WorkOrdersDataRaw{get;set;}
        public List<rstk__wocst__c> getFMGWorkOrderComponent_WorkOrdersData(List<Id> Ids) {
            return getFMGWorkOrderComponent_WorkOrdersDataRaw;
        }
    }



    @IsTest(SeeAllData=true)
    static void getBatchDataAndMapping_Live(){
        FMGRSAPI_WorkOrder_Service testService = new FMGRSAPI_WorkOrder_Service();
        AggregateResult[] batchData = [SELECT  MIN(batchId__c) batchId   FROM fmgwoorddmdcst__c];


        FMGRSAPI_WorkOrder_Service.WorkOrderBatch test = testService.getBatchData(1);
        System.debug(test.WorkOrders.size());
    }

    @IsTest(SeeAllData=true)
    static void getWorkOrderComponentsAndMapping_Live() {

        FMGRSAPI_WorkOrder_Service testService = new FMGRSAPI_WorkOrder_Service();
        Test.startTest();
        List<FMGRSAPI_WorkOrder_Service.RawWorkOrderComponent> testOutput = testService.getWorkOrderComponents(1);
        Test.stopTest();
        System.debug(JSON.serializePretty(testOutput));
    }

    @IsTest(SeeAllData=true)
    static void getFMGWorkOrderComponentBatchsAndMapping_Live(){
        AggregateResult[] batchData = [SELECT  MIN(batchId__c) batchId, Count(Id) totalRecords   FROM fmgwoorddmdcst__c];
        if(batchData.isEmpty() || Integer.valueOf(batchData[0].get('totalRecords')) == 0){
            System.debug(LoggingLevel.WARN,'Unable to test mapping no existing batch available');
            return;
        }

        Integer batchId = Integer.valueOf(batchData[0].get('batchId'));
        FMGRSAPI_WorkOrder_Service testService = new FMGRSAPI_WorkOrder_Service();

        Test.startTest();
        List<FMGRSAPI_WorkOrder_Service.RawFmgWorkOrderComponentDetail> testOutput = testService.getFMGWorkOrderComponentBatch(batchId);
        Test.stopTest();

        System.assertNotEquals(0,testOutput.size());
        System.assertEquals(batchId,testOutput[0].BatchId);
    }


    @IsTest(SeeAllData=true)
    static void getMissingWorkOrderComponentDetail_NoDetails_Live(){
        List<rstk__woorddmd__c> testDataRecords = [SELECT Id,
        (
                SELECT Id, rstk__woorddmdcst_locnum__c, rstk__woorddmdcst_locid__r.Id,
                        rstk__woorddmdcst_locid__r.rstk__sylocid_locid__c, rstk__woorddmdcst_qtyiss__c
                FROM rstk__woorddmdcsts__r
        )
        FROM rstk__woorddmd__c
        WHERE Id NOT IN (SELECT  rstk__woorddmdcst_woorddmd__c
        FROM rstk__woorddmdcst__c)
        LIMIT 1
        ];

        if(testDataRecords.isEmpty()){
            System.debug('No data to test with');
            return;
        }

        List<Id> workOrderIds = new List<Id>();
        for(rstk__woorddmd__c testDataRecord:testDataRecords){
            workOrderIds.add(testDataRecord.Id);
        }
        FMGRSAPI_WorkOrder_Service testService = new FMGRSAPI_WorkOrder_Service();

        Test.startTest();
        List<FMGRSAPI_WorkOrder_Service.RawWorkOrderComponentDetail> testOutput = testService.getMissingWorkOrderComponentDetail(workOrderIds);
        Test.stopTest();

        System.assertEquals(0,testOutput.size());
    }

    @IsTest(SeeAllData=true)
    static void getMissingWorkOrderComponentDetail_WithDetails_Live(){
        List<rstk__woorddmd__c> testDataRecords = [SELECT Id,
        (
                SELECT Id, rstk__woorddmdcst_locnum__c, rstk__woorddmdcst_locid__r.Id,
                        rstk__woorddmdcst_locid__r.rstk__sylocid_locid__c, rstk__woorddmdcst_qtyiss__c
                FROM rstk__woorddmdcsts__r
        )
        FROM rstk__woorddmd__c
        WHERE Id  IN (SELECT  rstk__woorddmdcst_woorddmd__c
        FROM rstk__woorddmdcst__c)
        LIMIT 1
        ];

        if(testDataRecords.isEmpty()){
            System.debug('No data to test with');
            return;
        }
        List<Id> workOrderIds = new List<Id>();
        for(rstk__woorddmd__c testDataRecord:testDataRecords){
            workOrderIds.add(testDataRecord.Id);
        }
        FMGRSAPI_WorkOrder_Service testService = new FMGRSAPI_WorkOrder_Service();

        Test.startTest();
        List<FMGRSAPI_WorkOrder_Service.RawWorkOrderComponentDetail> testOutput = testService.getMissingWorkOrderComponentDetail(workOrderIds);
        Test.stopTest();
        System.debug(JSON.serializePretty(testDataRecords));
        System.debug('********************************************');
        System.debug(JSON.serializePretty(testOutput));
        System.assertNotEquals(0,testOutput.size());
        System.assertEquals(testDataRecords[0].rstk__woorddmdcsts__r.size(),testOutput.size());

    }

    @IsTest(SeeAllData=true)
    static void getFMGWorkOrderComponent_FmgDetails_Live(){

        List<rstk__wocst__c> queryResults = [SELECT Id,rstk__wocst_ordno__c,
        (
                SELECT Id,
                        rstk__woorddmd_desc__c,
                        rstk__woorddmd_qtyreq__c,
                        rstk__woorddmd_compitem__r.rstk__icitem_item__r.rstk__peitem_item__c,
                        rstk__woorddmd_compitem__r.Id,rstk__woorddmd_ordno__c
                FROM rstk__WOORDDMDs__r
        ),
        (
                SELECT Id,
                        rstk__woorddmdcst_locnum__c,
                        rstk__woorddmdcst_locid__r.Id,
                        rstk__woorddmdcst_locid__r.rstk__sylocid_locid__c,
                        rstk__woorddmdcst_qtyiss__c,
                        rstk__woorddmdcst_woorddmd__c
                FROM rstk__woorddmdcsts__r
        ),
        (
                SELECT Id, batchId__c,fmgwoorddmdcst_sydata__c,
                        fmgwoorddmdcst_sydata__r.rstk__sydata_message__c, fmgwoorddmdcst_sydata__r.rstk__sydata_process__c,
                        fmgwoorddmdcst_sydata__r.rstk__sydata_txntype__c, fmgwoorddmdcst_woorddmd__c, fmgwoorddmdcst_woorddmdcst__c
                FROM fmgwoorddmdcst_wocst__r
        )
        FROM rstk__wocst__c
        WHERE
                Id in (SELECT	fmgwoorddmdcst_wocst__c FROM fmgwoorddmdcst__c Where batchId__c > 0)
        LIMIT 1];

        if(queryResults.isEmpty()){
            System.debug('No data to test with');
            return;
        }

        rstk__wocst__c testDataRecords = queryResults[0];

        System.debug('********** Test Record Data ***************');
        System.debug(JSON.serializePretty(testDataRecords));
        // Dont need to fail if there are no records to test
        if(testDataRecords == null){
            System.debug(LoggingLevel.INFO,'Unable to run getFMGWorkOrderComponent_NoComponents due to no work orders found for test');
            return;
        }
        List<Id> workOrderIds = new List<Id>();
        workOrderIds.add(testDataRecords.Id);

        FMGRSAPI_WorkOrder_Service testService = new FMGRSAPI_WorkOrder_Service();

        List<FMGRSAPI_WorkOrder_Service.WorkOrder> workOrders = testService.getWorkOrders(workOrderIds);
        System.debug('**********Output Test Record Data ***************');
        System.debug(JSON.serializePretty(workOrders));
        Assert.areNotEqual(0,workOrders.size());
        FMGRSAPI_WorkOrder_Service.WorkOrder wo = workOrders[0];
        Assert.areEqual(testDataRecords.Id,wo.WorkOrderId,'Work Order Id should be the same');
        Assert.areEqual(testDataRecords.rstk__wocst_ordno__c,wo.WorkOrderNumber,'Work Order Number should be the same');
        Assert.areNotEqual(0,wo.WorkOrderComponent.size(),'There should be  Items in the work order');
        FMGRSAPI_WorkOrder_Service.WorkOrderComponent woc = wo.WorkOrderComponent[0];
        Assert.areNotEqual(NULL,woc.ProductDescription,'Should have a discription');

        Assert.areNotEqual(-1,woc.BatchId);
        Assert.areNotEqual(0,woc.BatchId);
    }

    @IsTest(SeeAllData=true)
    static void getFMGWorkOrderComponent_NoFmgDetailsWithDetails_Live(){

        List<rstk__wocst__c> queryResults = [SELECT Id,rstk__wocst_ordno__c,
        (
                SELECT Id,
                        rstk__woorddmd_desc__c,
                        rstk__woorddmd_qtyreq__c,
                        rstk__woorddmd_compitem__r.rstk__icitem_item__r.rstk__peitem_item__c,
                        rstk__woorddmd_compitem__r.Id,rstk__woorddmd_ordno__c
                FROM rstk__WOORDDMDs__r
        ),
        (
                SELECT Id,
                        rstk__woorddmdcst_locnum__c,
                        rstk__woorddmdcst_locid__r.Id,
                        rstk__woorddmdcst_locid__r.rstk__sylocid_locid__c,
                        rstk__woorddmdcst_qtyiss__c,
                        rstk__woorddmdcst_woorddmd__c
                FROM rstk__woorddmdcsts__r
        ),
        (
                SELECT Id, batchId__c,fmgwoorddmdcst_sydata__c,
                        fmgwoorddmdcst_sydata__r.rstk__sydata_message__c, fmgwoorddmdcst_sydata__r.rstk__sydata_process__c,
                        fmgwoorddmdcst_sydata__r.rstk__sydata_txntype__c, fmgwoorddmdcst_woorddmd__c, fmgwoorddmdcst_woorddmdcst__c
                FROM fmgwoorddmdcst_wocst__r
        )
        FROM rstk__wocst__c
        WHERE
                Id not in (SELECT	fmgwoorddmdcst_wocst__c FROM fmgwoorddmdcst__c) AND
                Id in (SELECT rstk__woorddmdcst_ordno__c FROM rstk__woorddmdcst__c )
        LIMIT 1];

        if(queryResults.isEmpty()){
            System.debug('No data to test with');
            return;
        }

        rstk__wocst__c testDataRecords = queryResults[0];

        // Dont need to fail if there are no records to test
        if(testDataRecords == null){
            System.debug(LoggingLevel.INFO,'Unable to run getFMGWorkOrderComponent_NoComponents due to no work orders found for test');
            return;
        }
        List<Id> workOrderIds = new List<Id>();
        workOrderIds.add(testDataRecords.Id);

        FMGRSAPI_WorkOrder_Service testService = new FMGRSAPI_WorkOrder_Service();

        List<FMGRSAPI_WorkOrder_Service.WorkOrder> workOrders = testService.getWorkOrders(workOrderIds);
        Assert.areNotEqual(0,workOrders.size());
        FMGRSAPI_WorkOrder_Service.WorkOrder wo = workOrders[0];
        Assert.areEqual(testDataRecords.Id,wo.WorkOrderId,'Work Order Id should be the same');
        Assert.areEqual(testDataRecords.rstk__wocst_ordno__c,wo.WorkOrderNumber,'Work Order Number should be the same');
        Assert.areNotEqual(0,wo.WorkOrderComponent.size(),'There should be  Items in the work order');
        FMGRSAPI_WorkOrder_Service.WorkOrderComponent woc = wo.WorkOrderComponent[0];
        Assert.areNotEqual(NULL,woc.ProductDescription,'Should have a discription');
        Assert.areNotEqual(0,woc.Locations.size(),'There should be location information');
        Assert.areEqual(-1,woc.BatchId);
    }

    @IsTest(SeeAllData=true)
    static void getFMGWorkOrderComponent_NoDetails_Live(){

        List<rstk__wocst__c> queryData = [SELECT Id,rstk__wocst_ordno__c,
        (
                SELECT Id,
                        rstk__woorddmd_desc__c,
                        rstk__woorddmd_qtyreq__c,
                        rstk__woorddmd_compitem__r.rstk__icitem_item__r.rstk__peitem_item__c,
                        rstk__woorddmd_compitem__r.Id,rstk__woorddmd_ordno__c
                FROM rstk__WOORDDMDs__r
        ),
        (
                SELECT Id,
                        rstk__woorddmdcst_locnum__c,
                        rstk__woorddmdcst_locid__r.Id,
                        rstk__woorddmdcst_locid__r.rstk__sylocid_locid__c,
                        rstk__woorddmdcst_qtyiss__c,
                        rstk__woorddmdcst_woorddmd__c
                FROM rstk__woorddmdcsts__r
        ),
        (
                SELECT Id, batchId__c,fmgwoorddmdcst_sydata__c,
                        fmgwoorddmdcst_sydata__r.rstk__sydata_message__c, fmgwoorddmdcst_sydata__r.rstk__sydata_process__c,
                        fmgwoorddmdcst_sydata__r.rstk__sydata_txntype__c, fmgwoorddmdcst_woorddmd__c, fmgwoorddmdcst_woorddmdcst__c
                FROM fmgwoorddmdcst_wocst__r
        )
        FROM rstk__wocst__c
        WHERE
                Id in (SELECT rstk__woorddmd_ordno__c FROM rstk__woorddmd__c) AND
                Id not in (SELECT rstk__woorddmdcst_ordno__c FROM rstk__woorddmdcst__c )
        LIMIT 1];

        if(queryData.isEmpty()){
            System.debug('No data to test with');
            return;
        }

        rstk__wocst__c testDataRecords = queryData[0];
        // Dont need to fail if there are no records to test
        if(testDataRecords == null){
            System.debug(LoggingLevel.INFO,'Unable to run getFMGWorkOrderComponent_NoComponents due to no work orders found for test');
            return;
        }
        List<Id> workOrderIds = new List<Id>();
        workOrderIds.add(testDataRecords.Id);

        FMGRSAPI_WorkOrder_Service testService = new FMGRSAPI_WorkOrder_Service();

        List<FMGRSAPI_WorkOrder_Service.WorkOrder> workOrders = testService.getWorkOrders(workOrderIds);
        Assert.areNotEqual(0,workOrders.size());
        FMGRSAPI_WorkOrder_Service.WorkOrder wo = workOrders[0];
        Assert.areEqual(testDataRecords.Id,wo.WorkOrderId,'Work Order Id should be the same');
        Assert.areEqual(testDataRecords.rstk__wocst_ordno__c,wo.WorkOrderNumber,'Work Order Number should be the same');
        Assert.areNotEqual(0,wo.WorkOrderComponent.size(),'There should be  Items in the work order');
        FMGRSAPI_WorkOrder_Service.WorkOrderComponent woc = wo.WorkOrderComponent[0];
        Assert.areNotEqual(NULL,woc.ProductDescription);
        Assert.areEqual(-1,woc.BatchId);

    }

    @IsTest(SeeAllData=true)
    static void getFMGWorkOrderComponent_NoLines_Live(){



        List<rstk__woorddmd__c> testDataRecords = [SELECT Id,
        (
                SELECT Id, rstk__woorddmdcst_locnum__c, rstk__woorddmdcst_locid__r.Id,
                        rstk__woorddmdcst_locid__r.rstk__sylocid_locid__c, rstk__woorddmdcst_qtyiss__c
                FROM rstk__woorddmdcsts__r
        )
        FROM rstk__woorddmd__c
        WHERE Id  IN (SELECT  rstk__woorddmdcst_woorddmd__c
        FROM rstk__woorddmdcst__c)
        LIMIT 1
        ];

        if(testDataRecords.isEmpty()){
            System.debug('No data to test with');
            return;
        }
        List<Id> workOrderIds = new List<Id>();
        for(rstk__woorddmd__c testDataRecord:testDataRecords){
            workOrderIds.add(testDataRecord.Id);
        }
        FMGRSAPI_WorkOrder_Service testService = new FMGRSAPI_WorkOrder_Service();

        Test.startTest();
        List<FMGRSAPI_WorkOrder_Service.RawWorkOrderComponentDetail> testOutput = testService.getMissingWorkOrderComponentDetail(workOrderIds);
        Test.stopTest();
        System.debug(JSON.serializePretty(testDataRecords));
        System.debug('********************************************');
        System.debug(JSON.serializePretty(testOutput));
        System.assertNotEquals(0,testOutput.size());
        System.assertEquals(testDataRecords[0].rstk__woorddmdcsts__r.size(),testOutput.size());

    }
}