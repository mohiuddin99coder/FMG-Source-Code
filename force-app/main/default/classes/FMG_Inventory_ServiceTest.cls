/**
 * Created by inscorea on 8/22/2023.
 */

@IsTest
private class FMG_Inventory_ServiceTest {

    private static final Id Loc26 = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'26');
    private static final Id Loc25 = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'25');
    private static final Id ItemA = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'ItemA');
    private static final Id ItemB = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'ItemB');

    private static FMG_Inventory_Service.InventoryTransferLocationInfo genItem(String itemName,Decimal qty, String locationName, String locNum ){
        FMG_Inventory_Classes.InventoryTransferLocationInfo item = new FMG_Inventory_Classes.InventoryTransferLocationInfo();
        item.Qty = qty;
        item.ItemId = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,itemName);
        item.Item = itemName;
        item.SiteId = FMG_TestUtility.getFakeId(rstk__sysite__c.SObjectType,'FMG');
        item.DivisionId = FMG_TestUtility.getFakeId(rstk__sydiv__c.SObjectType,'FMG');
        item.ProjectId = FMG_TestUtility.getFakeId(rstk__pjproj__c.SObjectType,'FMG');
        item.LocationId = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,locationName);
        item.LocationName = locationName;
        item.LocationNumber = locNum;

        return  new FMG_Inventory_Service.InventoryTransferLocationInfo(item);
    }
    private static Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> productSet1(){

        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = new Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>>();

        products.put(ItemA,new Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>());
        products.put(ItemB,new Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>());


        // Item Info
        List<FMG_Inventory_Service.InventoryTransferLocationInfo> testLocationInfo = new List<FMG_Inventory_Service.InventoryTransferLocationInfo>();

        testLocationInfo.add(genItem(ItemA,5,'26','L1'));
        testLocationInfo.add(genItem(ItemA,10,'26','L2'));
        testLocationInfo.add(genItem(ItemA,15,'26','L3'));

        products.get(ItemA).put('26',testLocationInfo);
        testLocationInfo = new List<FMG_Inventory_Service.InventoryTransferLocationInfo>();
        testLocationInfo.add(genItem(ItemA,5,'25','L1'));
        testLocationInfo.add(genItem(ItemA,30,'25','L2'));
        testLocationInfo.add(genItem(ItemA,15,'25','L3'));

        products.get(ItemA).put('25',testLocationInfo);
        testLocationInfo = new List<FMG_Inventory_Service.InventoryTransferLocationInfo>();

        testLocationInfo.add(genItem(ItemB,15,'26','L1'));
        testLocationInfo.add(genItem(ItemB,110,'26','L2'));
        testLocationInfo.add(genItem(ItemB,115,'26','L3'));

        products.get(ItemB).put('26',testLocationInfo);
        testLocationInfo = new List<FMG_Inventory_Service.InventoryTransferLocationInfo>();

        testLocationInfo.add(genItem(ItemB,15,'25','L1'));
        testLocationInfo.add(genItem(ItemB,130,'25','L2'));
        testLocationInfo.add(genItem(ItemB,115,'25','L3'));

        products.get(ItemB).put('25',testLocationInfo);
        System.debug('Initial Product List');
        System.debug(System.JSON.serializePretty(products));
        return products;
    }
    private static void testSet1(Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products, Id item,Decimal n26l1,Decimal n26l2,Decimal n26l3,Decimal n25l1,Decimal n25l2,Decimal n25l3){

        Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>> productLocationData = products.get(item);
        for(FMG_Inventory_Service.InventoryTransferLocationInfo info: productLocationData.get('26')){
            if(info.LocationNumber == 'L1'){
                System.assertEquals(n26l1,info.Qty, 'Invalid Qty for loc26 - L1');
                System.assertEquals(n26l1,info.WorkingQty, 'Invalid Working Qty for loc26 - L1');
            } else if(info.LocationNumber == 'L2'){
                System.assertEquals(n26l2,info.Qty, 'Invalid Qty for loc26 - L2');
                System.assertEquals(n26l2,info.WorkingQty, 'Invalid Working Qty for loc26 - L2');
            } else if(info.LocationNumber == 'L3'){
                System.assertEquals(n26l3,info.Qty, 'Invalid Qty for loc26 - L3');
                System.assertEquals(n26l3,info.WorkingQty, 'Invalid Working Qty for loc26 - L3');
            }
        }

        for(FMG_Inventory_Service.InventoryTransferLocationInfo info: productLocationData.get('25')){
            if(info.LocationNumber == 'L1'){
                System.assertEquals(n25l1,info.Qty, 'Invalid Qty for L1');
                System.assertEquals(n25l1,info.WorkingQty, 'Invalid Working Qty for loc25 - L1');
            } else if(info.LocationNumber == 'L2'){
                System.assertEquals(n25l2,info.Qty, 'Invalid Qty for L2');
                System.assertEquals(n25l2,info.WorkingQty, 'Invalid Working Qty for loc25 - L2');
            } else if(info.LocationNumber == 'L3'){
                System.assertEquals(n25l3,info.Qty, 'Invalid Qty for L3');
                System.assertEquals(n25l3,info.WorkingQty, 'Invalid Working Qty for loc25 - L3');
            }
        }
    }
    private static void ItemCheck(FMG_Inventory_Service.TransferData data,Id item,Id locationId,String locationNumber,Decimal qty){
        System.debug(System.JSON.serializePretty(data));
        System.assertEquals(item,data.Item, 'Did not pull correct Item');
        System.assertEquals(locationId,data.LocId, 'Did not pull correct location Id');
        System.assertEquals(locationNumber,data.LocNum, 'Did not pull correct location number');
        System.assertEquals(qty,data.Qty, 'Did not pull correct qty');
    }

    @IsTest
    static void GenerateTransfersExecutionTest(){


        FMG_Inventory_Service worker = new FMG_Inventory_Service();

        DataMap mockData = new DataMap();
        worker.mockDataAccess = (FMG_Inventory_IServiceData)mockData;

        List<FMG_Inventory_Classes.InventoryTransferInput> items = new List<FMG_Inventory_Classes.InventoryTransferInput>();
        Set<Id> product = new Set<Id>();


        for(AggregateResult item:[SELECT
                rstk__ictransreq_ictransreqh__c
        FROM rstk__ictransreq__c
        WHERE rstk__ictransreq_ictransreqh__c != NULL
        GROUP BY rstk__ictransreq_ictransreqh__c
        HAVING COUNT(rstk__ictransreq_ictransreqh__c ) > 1]){
            product.add((Id)item.get('rstk__ictransreq_ictransreqh__c'));
        }

        product.add('a2IDK000001XIhj2AG');
        FMG_Inventory_Classes.InventoryTransferInput item = (FMG_Inventory_Classes.InventoryTransferInput)JSON.deserializeStrict('{"Item":"a1YDK000001ihX22AI","Qty":25,"Div":"a8fDK000000KysNYAS","LocId":"a8uDK000000GqVAYA0","LocNo":"C2","Project":"a3BDK000001cxAN2AY","Site":"a9CDK000000Kz0r2AC"}',FMG_Inventory_Classes.InventoryTransferInput.class);

        items.add(item);

        System.debug(JSON.serializePretty(product));


        System.debug(JSON.serializePretty(items));
        List<rstk__sydatat__c> transfers = worker.generateTransfers(items);
        System.debug(JSON.serializePretty(transfers));

    }

    @IsTest
    static void GetAndSortProductPullTest(){


        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        DataMap mockData = new DataMap();
        worker.mockDataAccess = (FMG_Inventory_IServiceData)mockData;

        Set<Id> productList = new Set<Id>();
        List<String> locations = new List<String>();
        locations.add('26');
        locations.add('25');
        productList.add('a1YDK000001ihXC2AY');
        productList.add('a1YDK000001ihX22AI');
        productList.add('a1YDK000001j1tq2AA');
        productList.add('a1YDK000001jAdQ2AU');


        Test.startTest();
        List<FMG_Inventory_Classes.InventoryTransferLocationInfo> productLocations = worker.getProductLocations(productList,locations);
        List<FMG_Inventory_Service.InventoryTransferLocationInfo> formattedLocationData = new List<FMG_Inventory_Service.InventoryTransferLocationInfo>();
        for(FMG_Inventory_Classes.InventoryTransferLocationInfo inventoryTransferLocationInfo: productLocations){
            formattedLocationData.add(new FMG_Inventory_Service.InventoryTransferLocationInfo(inventoryTransferLocationInfo));
        }
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> searchableProductLocation = worker.createSearchableProductLocation(formattedLocationData);
        Test.stopTest();

        for(Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>> item : searchableProductLocation.values()){
            for(List<FMG_Inventory_Service.InventoryTransferLocationInfo> locInfo:item.values()){
                System.assertNotEquals(0,locInfo.size());
            }
        }
    }

    @IsTest
    static void CheckPickLocationIdPull(){
        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        DataMap mockData = new DataMap();
        worker.mockDataAccess = (FMG_Inventory_IServiceData)mockData;
        List<String> PickOrderLocationIds;
        Test.startTest();
        PickOrderLocationIds = worker.getPickOrderLocationIds();
        Test.stopTest();
        System.assertNotEquals(0,PickOrderLocationIds.size());

    }

    @IsTest
    static void CheckPickLocationIdPullDefault(){
        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        List<String> PickOrderLocationIds;
        Test.startTest();
        PickOrderLocationIds = worker.getPickOrderLocationIds();
        Test.stopTest();
        System.assertEquals(2,PickOrderLocationIds.size());


    }

    @IsTest
    static void GenerateLocationInventoryMove(){

        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        FMG_Inventory_Classes.InventoryTransferInput toLocation = new FMG_Inventory_Classes.InventoryTransferInput();
        FMG_Inventory_Service.TransferData fromLocation = new FMG_Inventory_Service.TransferData();
        fromLocation.Qty = 1;
        fromLocation.Division = FMG_TestUtility.getFakeId(rstk__sydiv__c.SObjectType,'FMG');
        fromLocation.Site = FMG_TestUtility.getFakeId(rstk__sysite__c.SObjectType,'FMG');
        fromLocation.Project = FMG_TestUtility.getFakeId(rstk__pjproj__c.SObjectType,'FMG');
        fromLocation.LocId = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'26');
        fromLocation.LocNum = 'H1';


        toLocation.Div = FMG_TestUtility.getFakeId(rstk__sydiv__c.SObjectType,'FMG');
        toLocation.Site = FMG_TestUtility.getFakeId(rstk__sysite__c.SObjectType,'FMG');
        toLocation.Project = FMG_TestUtility.getFakeId(rstk__pjproj__c.SObjectType,'FMG');
        toLocation.LocId = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'P1');
        toLocation.LocNo = 'C1';
        toLocation.Item =FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'MyItem');

        rstk__sydatat__c testOutput;
        Test.startTest();
        testOutput = worker.generateLocalInventoryMove(toLocation,fromLocation,true);
        Test.stopTest();


        System.assertEquals('INVLOCLOC',testOutput.rstk__sydata_txnid__c);
        System.assertEquals('Inventory Transfer',testOutput.rstk__sydata_txntype__c);
        System.assertEquals(1,testOutput.rstk__sydata_txnqty__c);
        System.assertEquals(true,testOutput.rstk__sydata_backgroundprocessing__c);
        System.assertEquals(FMG_TestUtility.getFakeId(rstk__sydiv__c.SObjectType,'FMG'),testOutput.rstk__sydata_fromdiv__c);
        System.assertEquals(FMG_TestUtility.getFakeId(rstk__sysite__c.SObjectType,'FMG'),testOutput.rstk__sydata_fromsite__c);
        System.assertEquals(FMG_TestUtility.getFakeId(rstk__pjproj__c.SObjectType,'FMG'),testOutput.rstk__sydata_fromproj__c);
        System.assertEquals(FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'26'),testOutput.rstk__sydata_fromlocid__c);
        System.assertEquals('H1',testOutput.rstk__sydata_fromlocnum__c);
        System.assertEquals(FMG_TestUtility.getFakeId(rstk__sydiv__c.SObjectType,'FMG'),testOutput.rstk__sydata_todiv__c);
        System.assertEquals(FMG_TestUtility.getFakeId(rstk__sysite__c.SObjectType,'FMG'),testOutput.rstk__sydata_tosite__c);
        System.assertEquals(FMG_TestUtility.getFakeId(rstk__pjproj__c.SObjectType,'FMG'),testOutput.rstk__sydata_toproj__c);
        System.assertEquals(FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'P1'),testOutput.rstk__sydata_tolocid__c);
        System.assertEquals('C1',testOutput.rstk__sydata_tolocnum__c);
        System.assertEquals(FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'MyItem'),testOutput.rstk__sydata_icitem__c);



    }
    @IsTest
    static void InventoryTransferLocationInfoSortTestAsc(){
        List<FMG_Inventory_Service.InventoryTransferLocationInfo> testList = new List<FMG_Inventory_Service.InventoryTransferLocationInfo>();
        FMG_Inventory_Service.InventoryTransferLocationInfo object1 = new FMG_Inventory_Service.InventoryTransferLocationInfo();
        FMG_Inventory_Service.InventoryTransferLocationInfo object2 = new FMG_Inventory_Service.InventoryTransferLocationInfo();
        FMG_Inventory_Service.InventoryTransferLocationInfo object3 = new FMG_Inventory_Service.InventoryTransferLocationInfo();
        object1.Qty = 3;
        object1.AscOrder = true;
        object2.Qty = 5;
        object2.AscOrder = true;
        object3.Qty = 1;
        object3.AscOrder = true;
        testList.add(object1);
        testList.add(object2);
        testList.add(object3);

        System.assertEquals(3,testList[0].Qty);
        System.assertEquals(5,testList[1].Qty);
        System.assertEquals(1,testList[2].Qty);
        Test.startTest();
        testList.sort();
        Test.stopTest();
        System.assertEquals(1,testList[0].Qty);
        System.assertEquals(3,testList[1].Qty);
        System.assertEquals(5,testList[2].Qty);
    }

    @IsTest
    static void InventoryTransferLocationInfoSortTestDesc(){
        List<FMG_Inventory_Service.InventoryTransferLocationInfo> testList = new List<FMG_Inventory_Service.InventoryTransferLocationInfo>();
        FMG_Inventory_Service.InventoryTransferLocationInfo object1 = new FMG_Inventory_Service.InventoryTransferLocationInfo();
        FMG_Inventory_Service.InventoryTransferLocationInfo object2 = new FMG_Inventory_Service.InventoryTransferLocationInfo();
        FMG_Inventory_Service.InventoryTransferLocationInfo object3 = new FMG_Inventory_Service.InventoryTransferLocationInfo();
        object1.Qty = 3;
        object1.AscOrder = false;
        object2.Qty = 5;
        object2.AscOrder = false;
        object3.Qty = 1;
        object3.AscOrder = false;
        testList.add(object1);
        testList.add(object2);
        testList.add(object3);

        System.assertEquals(3,testList[0].Qty);
        System.assertEquals(5,testList[1].Qty);
        System.assertEquals(1,testList[2].Qty);
        Test.startTest();
        testList.sort();
        Test.stopTest();
        System.assertEquals(5,testList[0].Qty);
        System.assertEquals(3,testList[1].Qty);
        System.assertEquals(1,testList[2].Qty);
    }



    @IsTest
    static void SingleLocationPull_Insufficient() {
        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');

        FMG_Inventory_Service inventoryService = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();


        List<FMG_Inventory_Service.TransferData> testdata;
        Test.startTest();

        testdata = inventoryService.singleLocationPull(ItemA,35,products,locationIds);
        Test.stopTest();

        System.debug('Remaining Product List');
        System.debug(System.JSON.serializePretty(products));
        System.debug('ResultData');
        System.debug(System.JSON.serializePretty(testdata));
        System.assertEquals(0,testdata.size());
        testSet1(products,ItemA,5,10,15,5,30,15);
    }

    @IsTest
    static void SingleLocationPull_InsufficientFirst() {
        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');


        FMG_Inventory_Service inventoryService = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();

        System.debug(System.JSON.serializePretty(products));
        List<FMG_Inventory_Service.TransferData> pull1;
        Test.startTest();
        pull1 = inventoryService.singleLocationPull(ItemA,25,products,locationIds);
        Test.stopTest();


        System.assertEquals(1,pull1.size(),'Did not pull correct amount');

        ItemCheck(pull1[0],ItemA,Loc25,'L2',25);
        testSet1(products,ItemA,5,10,15,5,5,15);
    }

    @IsTest
    static void SingleLocationPull_Completed() {
        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');


        FMG_Inventory_Service inventoryService = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();

        List<FMG_Inventory_Service.TransferData> pull1;
        Test.startTest();
        pull1 = inventoryService.singleLocationPull(ItemA,2,products,locationIds);
        Test.stopTest();

        System.debug(System.JSON.serializePretty(pull1));
        System.assertEquals(1,pull1.size(),'Did not pull correct amount');

        ItemCheck(pull1[0],ItemA,Loc26,'L1',2);
        testSet1(products,ItemA,3,10,15,5,30,15);
    }

    @IsTest
    static void SingleLocationPull_DoublePullSameLocation() {

        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');


        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();

        System.debug('***************************** Initial Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));

        List<FMG_Inventory_Service.TransferData> pull1;
        List<FMG_Inventory_Service.TransferData> pull2;
        Test.startTest();
        pull1 = worker.singleLocationPull(ItemA,3,products,locationIds);
        pull2 = worker.singleLocationPull(ItemA,3,products,locationIds);
        Test.stopTest();

        System.debug('***************************** Ending Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));
        System.assertEquals(1,pull1.size(),'Did not pull correct amount');
        System.assertEquals(1,pull2.size(),'Did not pull correct amount');


        ItemCheck(pull1[0],ItemA,Loc26,'L1',3);
        ItemCheck(pull2[0],ItemA,Loc26,'L2',3);
        testSet1(products,ItemA,2,7,15,5,30,15);

    }

    @IsTest
    static void SingleLocationPull_DoublePullMultipleLocation() {
        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');


        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();

        System.debug('***************************** Initial Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));

        List<FMG_Inventory_Service.TransferData> pull1;
        List<FMG_Inventory_Service.TransferData> pull2;
        Test.startTest();
        pull1 = worker.singleLocationPull(ItemA,12,products,locationIds);
        pull2 = worker.singleLocationPull(ItemA,12,products,locationIds);
        Test.stopTest();

        System.debug('***************************** Ending Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));

        System.assertEquals(1,pull1.size(),'Did not pull correct amount');
        System.assertEquals(1,pull2.size(),'Did not pull correct amount');

        ItemCheck(pull1[0],ItemA,Loc26,'L3',12);
        ItemCheck(pull2[0],ItemA,Loc25,'L3',12);
        testSet1(products,ItemA,5,10,3,5,30,3);


    }

    @IsTest
    static void MultipleNumberLocationPull_Insufficient() {

        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');


        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();

        List<FMG_Inventory_Service.TransferData> testdata;
        System.debug('***************************** Initial Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));
        Test.startTest();
        testdata = worker.multipleLocationNumPull(ItemA,100,products,locationIds);
        Test.stopTest();
        System.debug('***************************** Ending Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));

        System.assertEquals(0,testdata.size());
        testSet1(products,ItemA,5,10,15,5,30,15);
    }

    @IsTest
    static void MultipleNumberLocationPull_InsufficientFirst() {
        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');


        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();

        System.debug('***************************** Initial Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));
        List<FMG_Inventory_Service.TransferData> pull1;
        Test.startTest();
        pull1 = worker.multipleLocationNumPull(ItemA,35,products,locationIds);
        Test.stopTest();


        System.debug('***************************** Ending Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));


        System.assertEquals(2,pull1.size(),'Did not pull correct amount');


        ItemCheck(pull1[0],ItemA,Loc25,'L2',30);
        ItemCheck(pull1[1],ItemA,Loc25,'L1',5);

        testSet1(products,ItemA,5,10,15,0,0,15);

    }

    @IsTest
    static void MultipleNumberLocationPull_Completed() {
        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');


        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();


        System.debug('***************************** Initial Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));
        List<FMG_Inventory_Service.TransferData> testdata;
        Test.startTest();
        testdata = worker.multipleLocationNumPull(ItemA,30,products,locationIds);
        Test.stopTest();


        System.debug('***************************** Ending Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));

        System.assertEquals(3,testdata.size(),'Did not pull correct amount');
        ItemCheck(testdata[0],ItemA,Loc26,'L3',15);
        ItemCheck(testdata[1],ItemA,Loc26,'L2',10);
        ItemCheck(testdata[2],ItemA,Loc26,'L1',5);

        testSet1(products,ItemA,0,0,0,5,30,15);
    }

    @IsTest
    static void MultipleNumberLocationPull_DoublePullSameLocation() {

        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');


        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();


        System.debug('***************************** Initial Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));
        List<FMG_Inventory_Service.TransferData> pull1;
        List<FMG_Inventory_Service.TransferData> pull2;
        Test.startTest();
        pull1 = worker.multipleLocationNumPull(ItemA,15,products,locationIds);
        pull2 = worker.multipleLocationNumPull(ItemA,15,products,locationIds);
        Test.stopTest();


        System.debug('***************************** Ending Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));

        System.assertEquals(1,pull1.size(),'Did not pull correct amount on pull1');
        System.assertEquals(2,pull2.size(),'Did not pull correct amount on pull2');

        ItemCheck(pull1[0],ItemA,Loc26,'L3',15);
        ItemCheck(pull2[0],ItemA,Loc26,'L2',10);
        ItemCheck(pull2[1],ItemA,Loc26,'L1',5);

        testSet1(products,ItemA,0,0,0,5,30,15);


    }

    @IsTest
    static void MultipleNumberLocationPull_DoublePullMultipleLocation() {
        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');


        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();


        System.debug('***************************** Initial Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));
        List<FMG_Inventory_Service.TransferData> pull1;
        List<FMG_Inventory_Service.TransferData> pull2;
        Test.startTest();
        pull1 = worker.multipleLocationNumPull(ItemA,30,products,locationIds);
        pull2 = worker.multipleLocationNumPull(ItemA,30,products,locationIds);
        Test.stopTest();


        System.debug('***************************** Ending Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));
        System.debug('***************************** Results Info ****************************** ' );
        System.debug(System.JSON.serializePretty(pull1));
        System.debug(System.JSON.serializePretty(pull2));

        System.assertEquals(3,pull1.size(),'Did not pull correct amount on pull1');
        System.assertEquals(1,pull2.size(),'Did not pull correct amount on pull2');

        ItemCheck(pull1[0],ItemA,Loc26,'L3',15);
        ItemCheck(pull1[1],ItemA,Loc26,'L2',10);
        ItemCheck(pull1[2],ItemA,Loc26,'L1',5);
        ItemCheck(pull2[0],ItemA,Loc25,'L2',30);

        testSet1(products,ItemA,0,0,0,5,0,15);

    }

    @IsTest
    static void MultipleNumberLocationPull_DoublePullMultipleLocationReverse() {
        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');


        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();


        System.debug('***************************** Initial Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));
        List<FMG_Inventory_Service.TransferData> pull1;
        List<FMG_Inventory_Service.TransferData> pull2;
        Test.startTest();
        pull1 = worker.multipleLocationNumPull(ItemA,35,products,locationIds);
        pull2 = worker.multipleLocationNumPull(ItemA,30,products,locationIds);
        Test.stopTest();


        System.debug('***************************** Ending Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));


        System.assertEquals(2,pull1.size(),'Did not pull correct amount on pull1');
        System.assertEquals(3,pull2.size(),'Did not pull correct amount on pull2');

        ItemCheck(pull1[0],ItemA,Loc25,'L2',30);
        ItemCheck(pull1[1],ItemA,Loc25,'L1',5);
        ItemCheck(pull2[0],ItemA,Loc26,'L3',15);
        ItemCheck(pull2[1],ItemA,Loc26,'L2',10);
        ItemCheck(pull2[2],ItemA,Loc26,'L1',5);

        testSet1(products,ItemA,0,0,0,0,0,15);

    }

    @IsTest
    static void MultipleLocationNumAndIdPull_CoveredByFirst(){
        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');


        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();

        System.debug('***************************** Initial Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));

        List<FMG_Inventory_Service.TransferData> pull1;
        Test.startTest();
        pull1 = worker.multipleLocationNumAndIdPull(ItemA,17,products,locationIds);
        Test.stopTest();

        System.debug('***************************** Ending Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));
        System.debug('***************************** pull1 ****************************** ' );
        System.debug(System.JSON.serializePretty(pull1));


        System.assertEquals(2,pull1.size(),'Did not pull correct amount on pull1');

        ItemCheck(pull1[0],ItemA,Loc26,'L3',15);
        ItemCheck(pull1[1],ItemA,Loc26,'L1',2);

        testSet1(products,ItemA,3,10,0,5,30,15);


    }

    @IsTest
    static void MultipleLocationNumAndIdPull_CoveredBySecond(){
        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');


        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();

        System.debug('***************************** Initial Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));

        List<FMG_Inventory_Service.TransferData> pull1;

        Test.startTest();
        pull1 = worker.multipleLocationNumAndIdPull(ItemA,50,products,locationIds);
        Test.stopTest();

        System.debug('***************************** Ending Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));
        System.debug('***************************** pull1 ****************************** ' );
        System.debug(System.JSON.serializePretty(pull1));


        System.assertEquals(4,pull1.size(),'Did not pull correct amount on pull1');

        ItemCheck(pull1[0],ItemA,Loc26,'L3',15);
        ItemCheck(pull1[1],ItemA,Loc26,'L2',10);
        ItemCheck(pull1[2],ItemA,Loc26,'L1',5);
        ItemCheck(pull1[3],ItemA,Loc25,'L2',20);

        testSet1(products,ItemA,0,0,0,5,10,15);
    }

    @IsTest
    static void MultipleLocationNumAndIdPull_InsufficientAll(){
        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');


        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();

        System.debug('***************************** Initial Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));

        List<FMG_Inventory_Service.TransferData> pull1;
        Test.startTest();
        pull1 = worker.multipleLocationNumAndIdPull(ItemA,1000,products,locationIds);
        Test.stopTest();

        System.debug('***************************** Ending Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));
        System.debug('***************************** pull1 ****************************** ' );
        System.debug(System.JSON.serializePretty(pull1));


        System.assertEquals(6,pull1.size(),'Did not pull correct amount on pull1');

        ItemCheck(pull1[0],ItemA,Loc26,'L3',15);
        ItemCheck(pull1[1],ItemA,Loc26,'L2',10);
        ItemCheck(pull1[2],ItemA,Loc26,'L1',5);
        ItemCheck(pull1[3],ItemA,Loc25,'L2',30);
        ItemCheck(pull1[4],ItemA,Loc25,'L3',15);
        ItemCheck(pull1[5],ItemA,Loc25,'L1',5);

        testSet1(products,ItemA,0,0,0,0,0,0);
    }

    @IsTest
    static void MultipleLocationNumAndIdPull_CoveredByFirstSecondPull(){
        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');


        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();

        System.debug('***************************** Initial Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));

        List<FMG_Inventory_Service.TransferData> pull1;
        List<FMG_Inventory_Service.TransferData> pull2;
        Test.startTest();
        pull1 = worker.multipleLocationNumAndIdPull(ItemA,9,products,locationIds);
        pull2 = worker.multipleLocationNumAndIdPull(ItemA,9,products,locationIds);
        Test.stopTest();

        System.debug('***************************** Ending Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));
        System.debug('***************************** pull1 ****************************** ' );
        System.debug(System.JSON.serializePretty(pull1));
        System.debug('***************************** pull2 ****************************** ' );
        System.debug(System.JSON.serializePretty(pull2));


        System.assertEquals(1,pull1.size(),'Did not pull correct amount on pull1');
        System.assertEquals(1,pull2.size(),'Did not pull correct amount on pull2');

        ItemCheck(pull1[0],ItemA,Loc26,'L2',9);
        ItemCheck(pull2[0],ItemA,Loc26,'L3',9);

        testSet1(products,ItemA,5,1,6,5,30,15);
    }

    @IsTest
    static void MultipleLocationNumAndIdPull_CoveredBySecondSecondPull(){
        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');


        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();

        System.debug('***************************** Initial Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));

        List<FMG_Inventory_Service.TransferData> pull1;
        List<FMG_Inventory_Service.TransferData> pull2;
        Test.startTest();
        pull1 = worker.multipleLocationNumAndIdPull(ItemA,50,products,locationIds);
        pull2 = worker.multipleLocationNumAndIdPull(ItemA,20,products,locationIds);
        Test.stopTest();

        System.debug('***************************** Ending Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));
        System.debug('***************************** pull1 ****************************** ' );
        System.debug(System.JSON.serializePretty(pull1));
        System.debug('***************************** pull2 ****************************** ' );
        System.debug(System.JSON.serializePretty(pull2));


        System.assertEquals(4,pull1.size(),'Did not pull correct amount on pull1');
        System.assertEquals(2,pull2.size(),'Did not pull correct amount on pull2');

        ItemCheck(pull1[0],ItemA,Loc26,'L3',15);
        ItemCheck(pull1[1],ItemA,Loc26,'L2',10);
        ItemCheck(pull1[2],ItemA,Loc26,'L1',5);
        ItemCheck(pull1[3],ItemA,Loc25,'L2',20);
        ItemCheck(pull2[0],ItemA,Loc25,'L3',15);
        ItemCheck(pull2[1],ItemA,Loc25,'L1',5);

        testSet1(products,ItemA,0,0,0,0,10,0);
    }

    @IsTest
    static void MultipleLocationNumAndIdPull_InsufficientAllSecondPull(){
        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');

        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();

        System.debug('***************************** Initial Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));

        List<FMG_Inventory_Service.TransferData> pull1;
        List<FMG_Inventory_Service.TransferData> pull2;
        Test.startTest();
        pull1 = worker.multipleLocationNumAndIdPull(ItemA,50,products,locationIds);
        pull2 = worker.multipleLocationNumAndIdPull(ItemA,50,products,locationIds);
        Test.stopTest();

        System.debug('***************************** Ending Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));
        System.debug('***************************** pull1 ****************************** ' );
        System.debug(System.JSON.serializePretty(pull1));
        System.debug('***************************** pull2 ****************************** ' );
        System.debug(System.JSON.serializePretty(pull2));



        System.assertEquals(4,pull1.size(),'Did not pull correct amount on pull1');
        System.assertEquals(3,pull2.size(),'Did not pull correct amount on pull2');

        ItemCheck(pull1[0],ItemA,Loc26,'L3',15);
        ItemCheck(pull1[1],ItemA,Loc26,'L2',10);
        ItemCheck(pull1[2],ItemA,Loc26,'L1',5);
        ItemCheck(pull1[3],ItemA,Loc25,'L2',20);
        ItemCheck(pull2[0],ItemA,Loc25,'L3',15);
        ItemCheck(pull2[1],ItemA,Loc25,'L2',10);
        ItemCheck(pull2[2],ItemA,Loc25,'L1',5);

        testSet1(products,ItemA,0,0,0,0,0,0);
    }

    @IsTest
    static void locationPulls_FirstLocation_OnePull_OneResult(){
        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');


        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();


        System.debug('***************************** Initial Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));

        List<FMG_Inventory_Service.TransferData> pull1;
        Test.startTest();
        pull1 = worker.locationPulls(ItemA,11,products,locationIds);
        Test.stopTest();

        System.debug('***************************** Ending Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));
        System.debug('***************************** pull1 ****************************** ' );
        System.debug(System.JSON.serializePretty(pull1));

        System.assertEquals(1,pull1.size(),'Did not pull correct amount on pull1');

        ItemCheck(pull1[0],ItemA,Loc26,'L3',11);

        testSet1(products,ItemA,5,10,4,5,30,15);

    }

    @IsTest
    static void locationPulls_FirstLocation_OnePull_TwoResult(){
        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');


        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();


        System.debug('***************************** Initial Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));

        List<FMG_Inventory_Service.TransferData> pull1;
        Test.startTest();
        pull1 = worker.locationPulls(ItemA,40,products,locationIds);
        Test.stopTest();

        System.debug('***************************** Ending Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));
        System.debug('***************************** pull1 ****************************** ' );
        System.debug(System.JSON.serializePretty(pull1));

        System.assertEquals(2,pull1.size(),'Did not pull correct amount on pull1');

        ItemCheck(pull1[0],ItemA,Loc25,'L2',30);
        ItemCheck(pull1[1],ItemA,Loc25,'L3',10);

        testSet1(products,ItemA,5,10,15,5,0,5);

    }

    @IsTest
    static void locationPulls_SecondLocation_OnePull(){
        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');


        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();

        System.debug('***************************** Initial Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));

        List<FMG_Inventory_Service.TransferData> pull1;
        Test.startTest();
        pull1 = worker.locationPulls(ItemA,40,products,locationIds);
        Test.stopTest();

        System.debug('***************************** Ending Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));
        System.debug('***************************** pull1 ****************************** ' );
        System.debug(System.JSON.serializePretty(pull1));

        System.assertEquals(2,pull1.size(),'Did not pull correct amount on pull1');

        ItemCheck(pull1[0],ItemA,Loc25,'L2',30);
        ItemCheck(pull1[1],ItemA,Loc25,'L3',10);

        testSet1(products,ItemA,5,10,15,5,0,5);
    }

    @IsTest
    static void locationPulls_AllSecondLocation_OnePull(){
        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');


        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();

        System.debug('***************************** Initial Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));

        List<FMG_Inventory_Service.TransferData> pull1;
        Test.startTest();
        pull1 = worker.locationPulls(ItemA,50,products,locationIds);
        Test.stopTest();

        System.debug('***************************** Ending Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));
        System.debug('***************************** pull1 ****************************** ' );
        System.debug(System.JSON.serializePretty(pull1));

        System.assertEquals(3,pull1.size(),'Did not pull correct amount on pull1');

        ItemCheck(pull1[0],ItemA,Loc25,'L2',30);
        ItemCheck(pull1[1],ItemA,Loc25,'L3',15);
        ItemCheck(pull1[2],ItemA,Loc25,'L1',5);

        testSet1(products,ItemA,5,10,15,0,0,0);
    }

    @IsTest
    static void locationPulls_AllLocation_OnePull(){
        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');


        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();

        System.debug('***************************** Initial Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));

        List<FMG_Inventory_Service.TransferData> pull1;
        Test.startTest();
        pull1 = worker.locationPulls(ItemA,100,products,locationIds);
        Test.stopTest();

        System.debug('***************************** Ending Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));
        System.debug('***************************** pull1 ****************************** ' );
        System.debug(System.JSON.serializePretty(pull1));

        System.assertEquals(6,pull1.size(),'Did not pull correct amount on pull1');

        ItemCheck(pull1[0],ItemA,Loc26,'L3',15);
        ItemCheck(pull1[1],ItemA,Loc26,'L2',10);
        ItemCheck(pull1[2],ItemA,Loc26,'L1',5);
        ItemCheck(pull1[3],ItemA,Loc25,'L2',30);
        ItemCheck(pull1[4],ItemA,Loc25,'L3',15);
        ItemCheck(pull1[5],ItemA,Loc25,'L1',5);

        testSet1(products,ItemA,0,0,0,0,0,0);
    }

    @IsTest
    static void locationPulls_TwoPull_Test1(){
        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');


        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();
        
        
        System.debug('***************************** Initial Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));

        List<FMG_Inventory_Service.TransferData> pull1;
        List<FMG_Inventory_Service.TransferData> pull2;
        Test.startTest();
        pull1 = worker.locationPulls(ItemA,9,products,locationIds);
        pull2 = worker.locationPulls(ItemA,9,products,locationIds);
        Test.stopTest();

        System.debug('***************************** Ending Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));
        System.debug('***************************** pull1 ****************************** ' );
        System.debug(System.JSON.serializePretty(pull1));
        System.debug('***************************** pull2 ****************************** ' );
        System.debug(System.JSON.serializePretty(pull2));

        System.assertEquals(1,pull1.size(),'Did not pull correct amount on pull1');
        System.assertEquals(1,pull2.size(),'Did not pull correct amount on pull2');

        ItemCheck(pull1[0],ItemA,Loc26,'L2',9);
        ItemCheck(pull2[0],ItemA,Loc26,'L3',9);

        testSet1(products,ItemA,5,1,6,5,30,15);
    }

    @IsTest
    static void locationPulls_TwoPull_Test2(){
        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');


        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();
        
        
        System.debug('***************************** Initial Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));

        List<FMG_Inventory_Service.TransferData> pull1;
        List<FMG_Inventory_Service.TransferData> pull2;
        Test.startTest();
        pull1 = worker.locationPulls(ItemA,15,products,locationIds);
        pull2 = worker.locationPulls(ItemA,35,products,locationIds);
        Test.stopTest();

        System.debug('***************************** Ending Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));
        System.debug('***************************** pull1 ****************************** ' );
        System.debug(System.JSON.serializePretty(pull1));
        System.debug('***************************** pull2 ****************************** ' );
        System.debug(System.JSON.serializePretty(pull2));

        System.assertEquals(1,pull1.size(),'Did not pull correct amount on pull1');
        System.assertEquals(2,pull2.size(),'Did not pull correct amount on pull2');

        ItemCheck(pull1[0],ItemA,Loc26,'L3',15);
        ItemCheck(pull2[0],ItemA,Loc25,'L2',30);
        ItemCheck(pull2[1],ItemA,Loc25,'L1',5);

        testSet1(products,ItemA,5,10,0,0,0,15);
    }

    @IsTest
    static void locationPulls_TwoPull_Test3(){
        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');


        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();
        
        
        System.debug('***************************** Initial Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));

        List<FMG_Inventory_Service.TransferData> pull1;
        List<FMG_Inventory_Service.TransferData> pull2;
        Test.startTest();
        pull1 = worker.locationPulls(ItemA,36,products,locationIds);
        pull2 = worker.locationPulls(ItemA,50,products,locationIds);
        Test.stopTest();

        System.debug('***************************** Ending Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));
        System.debug('***************************** pull1 ****************************** ' );
        System.debug(System.JSON.serializePretty(pull1));
        System.debug('***************************** pull2 ****************************** ' );
        System.debug(System.JSON.serializePretty(pull2));

        System.assertEquals(2,pull1.size(),'Did not pull correct amount on pull1');
        System.assertEquals(5,pull2.size(),'Did not pull correct amount on pull2');

        ItemCheck(pull1[0],ItemA,Loc25,'L2',30);
        ItemCheck(pull1[1],ItemA,Loc25,'L3',6);
        ItemCheck(pull2[0],ItemA,Loc26,'L3',15);
        ItemCheck(pull2[1],ItemA,Loc26,'L2',10);
        ItemCheck(pull2[2],ItemA,Loc26,'L1',5);
        ItemCheck(pull2[3],ItemA,Loc25,'L3',9);
        ItemCheck(pull2[4],ItemA,Loc25,'L1',5);

        testSet1(products,ItemA,0,0,0,0,0,0);

    }

    @IsTest
    static void locationPulls_TwoPull_Test4(){
        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');


        FMG_Inventory_Service worker = new FMG_Inventory_Service();
        Map<Id, Map<String, List<FMG_Inventory_Service.InventoryTransferLocationInfo>>> products = productSet1();
        
        
        System.debug('***************************** Initial Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));

        List<FMG_Inventory_Service.TransferData> pull1;
        List<FMG_Inventory_Service.TransferData> pull2;
        Test.startTest();
        pull1 = worker.locationPulls(ItemA,100,products,locationIds);
        pull2 = worker.locationPulls(ItemA,100,products,locationIds);
        Test.stopTest();

        System.debug('***************************** Ending Info ****************************** ' );
        System.debug(System.JSON.serializePretty(products));
        System.debug('***************************** pull1 ****************************** ' );
        System.debug(System.JSON.serializePretty(pull1));
        System.debug('***************************** pull2 ****************************** ' );
        System.debug(System.JSON.serializePretty(pull2));

        System.assertEquals(6,pull1.size(),'Did not pull correct amount on pull1');
        System.assertEquals(0,pull2.size(),'Did not pull correct amount on pull2');

        ItemCheck(pull1[0],ItemA,Loc26,'L3',15);
        ItemCheck(pull1[1],ItemA,Loc26,'L2',10);
        ItemCheck(pull1[2],ItemA,Loc26,'L1',5);
        ItemCheck(pull1[3],ItemA,Loc25,'L2',30);
        ItemCheck(pull1[4],ItemA,Loc25,'L3',15);
        ItemCheck(pull1[5],ItemA,Loc25,'L1',5);

        testSet1(products,ItemA,0,0,0,0,0,0);
    }

    public class DataMap implements FMG_Inventory_IServiceData {

        public DataMap(){
            getPickOrderLocationIdsDataRaw = new List<FMG_Configuration__c>();
            FMG_Configuration__c data = (FMG_Configuration__c)json.deserializeStrict('{"Id":"0000000000000004AS","Setting__c":"Create Inventory Move Source Location Ids","Value__c":"26,25","Application__c":"FMG Inventory Service"}',FMG_Configuration__c.class);
            getPickOrderLocationIdsDataRaw.add(data);

            getProductLocationsDataRaw=new List<rstk__icitem__c>();
            rstk__icitem__c icitem =(rstk__icitem__c)json.deserializeStrict('{"Id":"a1YDK000001ihX22AI","rstk__icitem_descr__c":"DELICA #11 OP MATTE DYED JADE GRN 7.5GM","rstk__icitem_item__c":"a35DK000001ZjYUYA0","rstk__icitem_wmslocnum__c":"C2","rstk__icitem_wmslocid__c":"a8uDK000000GqVAYA0","rstk__ICLOCITEMs__r":{"totalSize":4,"done":true,"records":[{"rstk__iclocitem_icitem__c":"a1YDK000001ihX22AI","Id":"a1yDK000001dgawYAA","rstk__iclocitem_locqty__c":1.000000,"rstk__iclocitem_locnum__c":"HB10GG00","rstk__iclocitem_locid__c":"a8uDK000000GqOcYAK","rstk__iclocitem_proj__c":"a3BDK000001cxAN2AY","rstk__iclocitem_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26","rstk__formula_name__c":"26 (Bunker Bulk)","rstk__sylocid_div__c":"a8fDK000000KysNYAS","rstk__sylocid_site__c":"a9CDK000000Kz0r2AC","rstk__sylocid_div__r":{"Id":"a8fDK000000KysNYAS"},"rstk__sylocid_site__r":{"Id":"a9CDK000000Kz0r2AC"}},"rstk__iclocitem_proj__r":{"Id":"a3BDK000001cxAN2AY"},"rstk__iclocitem_icitem__r":{"Id":"a1YDK000001ihX22AI","rstk__icitem_descr__c":"DELICA #11 OP MATTE DYED JADE GRN 7.5GM","rstk__icitem_item__c":"a35DK000001ZjYUYA0","rstk__icitem_supplymultiplier__c":33,"rstk__icitem_item__r":{"Id":"a35DK000001ZjYUYA0","rstk__peitem_item__c":"DB0797V"}}},{"rstk__iclocitem_icitem__c":"a1YDK000001ihX22AI","Id":"a1yDK000001dgYjYAI","rstk__iclocitem_locqty__c":2.000000,"rstk__iclocitem_locnum__c":"HF10GG00","rstk__iclocitem_locid__c":"a8uDK000000GqOcYAK","rstk__iclocitem_proj__c":"a3BDK000001cxAN2AY","rstk__iclocitem_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26","rstk__formula_name__c":"26 (Bunker Bulk)","rstk__sylocid_div__c":"a8fDK000000KysNYAS","rstk__sylocid_site__c":"a9CDK000000Kz0r2AC","rstk__sylocid_div__r":{"Id":"a8fDK000000KysNYAS"},"rstk__sylocid_site__r":{"Id":"a9CDK000000Kz0r2AC"}},"rstk__iclocitem_proj__r":{"Id":"a3BDK000001cxAN2AY"},"rstk__iclocitem_icitem__r":{"Id":"a1YDK000001ihX22AI","rstk__icitem_descr__c":"DELICA #11 OP MATTE DYED JADE GRN 7.5GM","rstk__icitem_item__c":"a35DK000001ZjYUYA0","rstk__icitem_supplymultiplier__c":33,"rstk__icitem_item__r":{"Id":"a35DK000001ZjYUYA0","rstk__peitem_item__c":"DB0797V"}}},{"rstk__iclocitem_icitem__c":"a1YDK000001ihX22AI","Id":"a1yDK000001ddxpYAA","rstk__iclocitem_locqty__c":500.000000,"rstk__iclocitem_locnum__c":"HE18BB00","rstk__iclocitem_locid__c":"a8uDK000000GqOcYAK","rstk__iclocitem_proj__c":"a3BDK000001cxAN2AY","rstk__iclocitem_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26","rstk__formula_name__c":"26 (Bunker Bulk)","rstk__sylocid_div__c":"a8fDK000000KysNYAS","rstk__sylocid_site__c":"a9CDK000000Kz0r2AC","rstk__sylocid_div__r":{"Id":"a8fDK000000KysNYAS"},"rstk__sylocid_site__r":{"Id":"a9CDK000000Kz0r2AC"}},"rstk__iclocitem_proj__r":{"Id":"a3BDK000001cxAN2AY"},"rstk__iclocitem_icitem__r":{"Id":"a1YDK000001ihX22AI","rstk__icitem_descr__c":"DELICA #11 OP MATTE DYED JADE GRN 7.5GM","rstk__icitem_item__c":"a35DK000001ZjYUYA0","rstk__icitem_supplymultiplier__c":33,"rstk__icitem_item__r":{"Id":"a35DK000001ZjYUYA0","rstk__peitem_item__c":"DB0797V"}}},{"rstk__iclocitem_icitem__c":"a1YDK000001ihX22AI","Id":"a1yDK000001ddwkYAA","rstk__iclocitem_locqty__c":2268.000000,"rstk__iclocitem_locnum__c":"NV20CC09","rstk__iclocitem_locid__c":"a8uDK000000GqOXYA0","rstk__iclocitem_proj__c":"a3BDK000001cxAN2AY","rstk__iclocitem_locid__r":{"Id":"a8uDK000000GqOXYA0","rstk__sylocid_locid__c":"25","rstk__formula_name__c":"25 (DC Bulk)","rstk__sylocid_div__c":"a8fDK000000KysNYAS","rstk__sylocid_site__c":"a9CDK000000Kz0r2AC","rstk__sylocid_div__r":{"Id":"a8fDK000000KysNYAS"},"rstk__sylocid_site__r":{"Id":"a9CDK000000Kz0r2AC"}},"rstk__iclocitem_proj__r":{"Id":"a3BDK000001cxAN2AY"},"rstk__iclocitem_icitem__r":{"Id":"a1YDK000001ihX22AI","rstk__icitem_descr__c":"DELICA #11 OP MATTE DYED JADE GRN 7.5GM","rstk__icitem_item__c":"a35DK000001ZjYUYA0","rstk__icitem_supplymultiplier__c":33,"rstk__icitem_item__r":{"Id":"a35DK000001ZjYUYA0","rstk__peitem_item__c":"DB0797V"}}}]},"rstk__icitem_item__r":{"Id":"a35DK000001ZjYUYA0","rstk__peitem_item__c":"DB0797V"}}',rstk__icitem__c.class);
            getProductLocationsDataRaw.add(icitem);
            icitem =(rstk__icitem__c)json.deserializeStrict('{"Id":"a1YDK000001ihXC2AY","rstk__icitem_descr__c":"XTLPAS CRYSTAL AB   BICONE 4MM PK48","rstk__icitem_item__c":"a35DK000001ZjYeYAK","rstk__icitem_wmslocnum__c":"C21","rstk__icitem_wmslocid__c":"a8uDK000000GqVAYA0","rstk__ICLOCITEMs__r":{"totalSize":3,"done":true,"records":[{"rstk__iclocitem_icitem__c":"a1YDK000001ihXC2AY","Id":"a1yDK000001deM7YAI","rstk__iclocitem_locqty__c":25.000000,"rstk__iclocitem_locnum__c":"HC17FF00","rstk__iclocitem_locid__c":"a8uDK000000GqOcYAK","rstk__iclocitem_proj__c":"a3BDK000001cxAN2AY","rstk__iclocitem_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26","rstk__formula_name__c":"26 (Bunker Bulk)","rstk__sylocid_div__c":"a8fDK000000KysNYAS","rstk__sylocid_site__c":"a9CDK000000Kz0r2AC","rstk__sylocid_div__r":{"Id":"a8fDK000000KysNYAS"},"rstk__sylocid_site__r":{"Id":"a9CDK000000Kz0r2AC"}},"rstk__iclocitem_proj__r":{"Id":"a3BDK000001cxAN2AY"},"rstk__iclocitem_icitem__r":{"Id":"a1YDK000001ihXC2AY","rstk__icitem_descr__c":"XTLPAS CRYSTAL AB   BICONE 4MM PK48","rstk__icitem_item__c":"a35DK000001ZjYeYAK","rstk__icitem_supplymultiplier__c":0,"rstk__icitem_item__r":{"Id":"a35DK000001ZjYeYAK","rstk__peitem_item__c":"3176CY"}}},{"rstk__iclocitem_icitem__c":"a1YDK000001ihXC2AY","Id":"a1yDK000001dfdfYAA","rstk__iclocitem_locqty__c":150.000000,"rstk__iclocitem_locnum__c":"HB10AA00","rstk__iclocitem_locid__c":"a8uDK000000GqOcYAK","rstk__iclocitem_proj__c":"a3BDK000001cxAN2AY","rstk__iclocitem_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26","rstk__formula_name__c":"26 (Bunker Bulk)","rstk__sylocid_div__c":"a8fDK000000KysNYAS","rstk__sylocid_site__c":"a9CDK000000Kz0r2AC","rstk__sylocid_div__r":{"Id":"a8fDK000000KysNYAS"},"rstk__sylocid_site__r":{"Id":"a9CDK000000Kz0r2AC"}},"rstk__iclocitem_proj__r":{"Id":"a3BDK000001cxAN2AY"},"rstk__iclocitem_icitem__r":{"Id":"a1YDK000001ihXC2AY","rstk__icitem_descr__c":"XTLPAS CRYSTAL AB   BICONE 4MM PK48","rstk__icitem_item__c":"a35DK000001ZjYeYAK","rstk__icitem_supplymultiplier__c":0,"rstk__icitem_item__r":{"Id":"a35DK000001ZjYeYAK","rstk__peitem_item__c":"3176CY"}}},{"rstk__iclocitem_icitem__c":"a1YDK000001ihXC2AY","Id":"a1yDK000001dc7rYAA","rstk__iclocitem_locqty__c":1500.000000,"rstk__iclocitem_locnum__c":"HN41CC00","rstk__iclocitem_locid__c":"a8uDK000000GqOcYAK","rstk__iclocitem_proj__c":"a3BDK000001cxAN2AY","rstk__iclocitem_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26","rstk__formula_name__c":"26 (Bunker Bulk)","rstk__sylocid_div__c":"a8fDK000000KysNYAS","rstk__sylocid_site__c":"a9CDK000000Kz0r2AC","rstk__sylocid_div__r":{"Id":"a8fDK000000KysNYAS"},"rstk__sylocid_site__r":{"Id":"a9CDK000000Kz0r2AC"}},"rstk__iclocitem_proj__r":{"Id":"a3BDK000001cxAN2AY"},"rstk__iclocitem_icitem__r":{"Id":"a1YDK000001ihXC2AY","rstk__icitem_descr__c":"XTLPAS CRYSTAL AB   BICONE 4MM PK48","rstk__icitem_item__c":"a35DK000001ZjYeYAK","rstk__icitem_supplymultiplier__c":0,"rstk__icitem_item__r":{"Id":"a35DK000001ZjYeYAK","rstk__peitem_item__c":"3176CY"}}}]},"rstk__icitem_item__r":{"Id":"a35DK000001ZjYeYAK","rstk__peitem_item__c":"3176CY"}}',rstk__icitem__c.class);
            getProductLocationsDataRaw.add(icitem);
            icitem =(rstk__icitem__c)json.deserializeStrict('{"Id":"a1YDK000001j1tq2AA","rstk__icitem_descr__c":"BEAD PEWTER ENAMEL  CRYS ORG RNDL EA","rstk__icitem_item__c":"a35DK000001cqHGYAY","rstk__icitem_wmslocnum__c":"C15","rstk__icitem_wmslocid__c":"a8uDK000000GqVAYA0","rstk__ICLOCITEMs__r":{"totalSize":3,"done":true,"records":[{"rstk__iclocitem_icitem__c":"a1YDK000001j1tq2AA","Id":"a1yDK000001eBXlYAM","rstk__iclocitem_locqty__c":20.000000,"rstk__iclocitem_locnum__c":"HB26AA00","rstk__iclocitem_locid__c":"a8uDK000000GqOcYAK","rstk__iclocitem_proj__c":"a3BDK000001cxAN2AY","rstk__iclocitem_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26","rstk__formula_name__c":"26 (Bunker Bulk)","rstk__sylocid_div__c":"a8fDK000000KysNYAS","rstk__sylocid_site__c":"a9CDK000000Kz0r2AC","rstk__sylocid_div__r":{"Id":"a8fDK000000KysNYAS"},"rstk__sylocid_site__r":{"Id":"a9CDK000000Kz0r2AC"}},"rstk__iclocitem_proj__r":{"Id":"a3BDK000001cxAN2AY"},"rstk__iclocitem_icitem__r":{"Id":"a1YDK000001j1tq2AA","rstk__icitem_descr__c":"BEAD PEWTER ENAMEL  CRYS ORG RNDL EA","rstk__icitem_item__c":"a35DK000001cqHGYAY","rstk__icitem_item__r":{"Id":"a35DK000001cqHGYAY","rstk__peitem_item__c":"1000BB"}}},{"rstk__iclocitem_icitem__c":"a1YDK000001j1tq2AA","Id":"a1yDK000001dg0NYAQ","rstk__iclocitem_locqty__c":260.000000,"rstk__iclocitem_locnum__c":"HN10CC00","rstk__iclocitem_locid__c":"a8uDK000000GqOcYAK","rstk__iclocitem_proj__c":"a3BDK000001cxAN2AY","rstk__iclocitem_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26","rstk__formula_name__c":"26 (Bunker Bulk)","rstk__sylocid_div__c":"a8fDK000000KysNYAS","rstk__sylocid_site__c":"a9CDK000000Kz0r2AC","rstk__sylocid_div__r":{"Id":"a8fDK000000KysNYAS"},"rstk__sylocid_site__r":{"Id":"a9CDK000000Kz0r2AC"}},"rstk__iclocitem_proj__r":{"Id":"a3BDK000001cxAN2AY"},"rstk__iclocitem_icitem__r":{"Id":"a1YDK000001j1tq2AA","rstk__icitem_descr__c":"BEAD PEWTER ENAMEL  CRYS ORG RNDL EA","rstk__icitem_item__c":"a35DK000001cqHGYAY","rstk__icitem_item__r":{"Id":"a35DK000001cqHGYAY","rstk__peitem_item__c":"1000BB"}}},{"rstk__iclocitem_icitem__c":"a1YDK000001j1tq2AA","Id":"a1yDK000001eCziYAE","rstk__iclocitem_locqty__c":1680.000000,"rstk__iclocitem_locnum__c":"DH222","rstk__iclocitem_locid__c":"a8uDK000000GqOcYAK","rstk__iclocitem_proj__c":"a3BDK000001cxAN2AY","rstk__iclocitem_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26","rstk__formula_name__c":"26 (Bunker Bulk)","rstk__sylocid_div__c":"a8fDK000000KysNYAS","rstk__sylocid_site__c":"a9CDK000000Kz0r2AC","rstk__sylocid_div__r":{"Id":"a8fDK000000KysNYAS"},"rstk__sylocid_site__r":{"Id":"a9CDK000000Kz0r2AC"}},"rstk__iclocitem_proj__r":{"Id":"a3BDK000001cxAN2AY"},"rstk__iclocitem_icitem__r":{"Id":"a1YDK000001j1tq2AA","rstk__icitem_descr__c":"BEAD PEWTER ENAMEL  CRYS ORG RNDL EA","rstk__icitem_item__c":"a35DK000001cqHGYAY","rstk__icitem_item__r":{"Id":"a35DK000001cqHGYAY","rstk__peitem_item__c":"1000BB"}}}]},"rstk__icitem_item__r":{"Id":"a35DK000001cqHGYAY","rstk__peitem_item__c":"1000BB"}}',rstk__icitem__c.class);
            getProductLocationsDataRaw.add(icitem);
            icitem =(rstk__icitem__c)json.deserializeStrict('{"Id":"a1YDK000001jAdQ2AU","rstk__icitem_descr__c":"SUPL NEEDLE WIDE EYE 4IN #20 PK/2","rstk__icitem_item__c":"a35DK000001czhBYAQ","rstk__icitem_wmslocnum__c":"C12","rstk__icitem_wmslocid__c":"a8uDK000000GqVAYA0","rstk__ICLOCITEMs__r":{"totalSize":4,"done":true,"records":[{"rstk__iclocitem_icitem__c":"a1YDK000001jAdQ2AU","Id":"a1yDK000001eBcoYAE","rstk__iclocitem_locqty__c":50.000000,"rstk__iclocitem_locnum__c":"HB12AA00","rstk__iclocitem_locid__c":"a8uDK000000GqOcYAK","rstk__iclocitem_proj__c":"a3BDK000001cxAN2AY","rstk__iclocitem_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26","rstk__formula_name__c":"26 (Bunker Bulk)","rstk__sylocid_div__c":"a8fDK000000KysNYAS","rstk__sylocid_site__c":"a9CDK000000Kz0r2AC","rstk__sylocid_div__r":{"Id":"a8fDK000000KysNYAS"},"rstk__sylocid_site__r":{"Id":"a9CDK000000Kz0r2AC"}},"rstk__iclocitem_proj__r":{"Id":"a3BDK000001cxAN2AY"},"rstk__iclocitem_icitem__r":{"Id":"a1YDK000001jAdQ2AU","rstk__icitem_descr__c":"SUPL NEEDLE WIDE EYE 4IN #20 PK/2","rstk__icitem_item__c":"a35DK000001czhBYAQ","rstk__icitem_item__r":{"Id":"a35DK000001czhBYAQ","rstk__peitem_item__c":"2619BS"}}},{"rstk__iclocitem_icitem__c":"a1YDK000001jAdQ2AU","Id":"a1yDK000001eBhPYAU","rstk__iclocitem_locqty__c":100.000000,"rstk__iclocitem_locnum__c":"HB10BB00","rstk__iclocitem_locid__c":"a8uDK000000GqOcYAK","rstk__iclocitem_proj__c":"a3BDK000001cxAN2AY","rstk__iclocitem_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26","rstk__formula_name__c":"26 (Bunker Bulk)","rstk__sylocid_div__c":"a8fDK000000KysNYAS","rstk__sylocid_site__c":"a9CDK000000Kz0r2AC","rstk__sylocid_div__r":{"Id":"a8fDK000000KysNYAS"},"rstk__sylocid_site__r":{"Id":"a9CDK000000Kz0r2AC"}},"rstk__iclocitem_proj__r":{"Id":"a3BDK000001cxAN2AY"},"rstk__iclocitem_icitem__r":{"Id":"a1YDK000001jAdQ2AU","rstk__icitem_descr__c":"SUPL NEEDLE WIDE EYE 4IN #20 PK/2","rstk__icitem_item__c":"a35DK000001czhBYAQ","rstk__icitem_item__r":{"Id":"a35DK000001czhBYAQ","rstk__peitem_item__c":"2619BS"}}},{"rstk__iclocitem_icitem__c":"a1YDK000001jAdQ2AU","Id":"a1yDK000001eBc1YAE","rstk__iclocitem_locqty__c":100.000000,"rstk__iclocitem_locnum__c":"HB10EE00","rstk__iclocitem_locid__c":"a8uDK000000GqOcYAK","rstk__iclocitem_proj__c":"a3BDK000001cxAN2AY","rstk__iclocitem_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26","rstk__formula_name__c":"26 (Bunker Bulk)","rstk__sylocid_div__c":"a8fDK000000KysNYAS","rstk__sylocid_site__c":"a9CDK000000Kz0r2AC","rstk__sylocid_div__r":{"Id":"a8fDK000000KysNYAS"},"rstk__sylocid_site__r":{"Id":"a9CDK000000Kz0r2AC"}},"rstk__iclocitem_proj__r":{"Id":"a3BDK000001cxAN2AY"},"rstk__iclocitem_icitem__r":{"Id":"a1YDK000001jAdQ2AU","rstk__icitem_descr__c":"SUPL NEEDLE WIDE EYE 4IN #20 PK/2","rstk__icitem_item__c":"a35DK000001czhBYAQ","rstk__icitem_item__r":{"Id":"a35DK000001czhBYAQ","rstk__peitem_item__c":"2619BS"}}},{"rstk__iclocitem_icitem__c":"a1YDK000001jAdQ2AU","Id":"a1yDK000001eBcLYAU","rstk__iclocitem_locqty__c":100.000000,"rstk__iclocitem_locnum__c":"HB22LL00","rstk__iclocitem_locid__c":"a8uDK000000GqOcYAK","rstk__iclocitem_proj__c":"a3BDK000001cxAN2AY","rstk__iclocitem_locid__r":{"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26","rstk__formula_name__c":"26 (Bunker Bulk)","rstk__sylocid_div__c":"a8fDK000000KysNYAS","rstk__sylocid_site__c":"a9CDK000000Kz0r2AC","rstk__sylocid_div__r":{"Id":"a8fDK000000KysNYAS"},"rstk__sylocid_site__r":{"Id":"a9CDK000000Kz0r2AC"}},"rstk__iclocitem_proj__r":{"Id":"a3BDK000001cxAN2AY"},"rstk__iclocitem_icitem__r":{"Id":"a1YDK000001jAdQ2AU","rstk__icitem_descr__c":"SUPL NEEDLE WIDE EYE 4IN #20 PK/2","rstk__icitem_item__c":"a35DK000001czhBYAQ","rstk__icitem_item__r":{"Id":"a35DK000001czhBYAQ","rstk__peitem_item__c":"2619BS"}}}]},"rstk__icitem_item__r":{"Id":"a35DK000001czhBYAQ","rstk__peitem_item__c":"2619BS"}}',rstk__icitem__c.class);
            getProductLocationsDataRaw.add(icitem);





        }

        List<FMG_Configuration__c> getPickOrderLocationIdsDataRaw{get;set;}
        public List<FMG_Configuration__c> getPickOrderLocationIdsData() {
            return getPickOrderLocationIdsDataRaw;
        }

        public List<rstk__icitem__c> getProductLocationsDataRaw{get;set;}
        public List<rstk__icitem__c> getProductLocationsData(Set<Id> products, List<String> locationIds) {
            return getProductLocationsDataRaw;
        }
    }
}