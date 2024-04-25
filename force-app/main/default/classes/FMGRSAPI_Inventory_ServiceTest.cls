@IsTest
private class FMGRSAPI_Inventory_ServiceTest {
    @IsTest
    static void moveItemsTest() {


        FMGRSAPI_Inventory_Service testObject = new FMGRSAPI_Inventory_Service();

        testObject.UnitTestLocationData = new List<FMGRSAPI_Inventory_Service.RawLocationId>();
        // location 26
        FMGRSAPI_Inventory_Service.RawLocationId loc26 = new FMGRSAPI_Inventory_Service.RawLocationId();
        loc26.SalesforceId = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType);
        loc26.Name = '26';
        loc26.LocationId = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType);
        loc26.SiteId = FMG_TestUtility.getFakeId(rstk__sysite__c.SObjectType);
        loc26.DivisionId = FMG_TestUtility.getFakeId(rstk__sydiv__c.SObjectType);
        loc26.HomeProject = FMG_TestUtility.getFakeId(rstk__pjproj__c.SObjectType);

        loc26.LocationNumbers.add(new FMGRSAPI_Inventory_Service.RawLocationNumber(
                FMG_TestUtility.getFakeId(rstk__sylocnum__c.SObjectType),'HF12BB00 (Aisle H, Section 12, Shelf BB)','HF12BB00'

        ));
        loc26.LocationNumbers.add(new FMGRSAPI_Inventory_Service.RawLocationNumber(
                FMG_TestUtility.getFakeId(rstk__sylocnum__c.SObjectType),'HN13HH00 (Aisle HN, Section 13, Shelf HH)','HN13HH00'

        ));


        // location P1
        FMGRSAPI_Inventory_Service.RawLocationId locP1 = new FMGRSAPI_Inventory_Service.RawLocationId();
        locP1.SalesforceId = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType);
        locP1.Name = 'P1';
        locP1.LocationId = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType);
        locP1.SiteId = FMG_TestUtility.getFakeId(rstk__sysite__c.SObjectType);
        locP1.DivisionId = FMG_TestUtility.getFakeId(rstk__sydiv__c.SObjectType);
        locP1.HomeProject = FMG_TestUtility.getFakeId(rstk__pjproj__c.SObjectType);

        locP1.LocationNumbers.add(new FMGRSAPI_Inventory_Service.RawLocationNumber(
                FMG_TestUtility.getFakeId(rstk__sylocnum__c.SObjectType),'C5 (Carousel 5)','C5'

        ));
        locP1.LocationNumbers.add(new FMGRSAPI_Inventory_Service.RawLocationNumber(
                FMG_TestUtility.getFakeId(rstk__sylocnum__c.SObjectType),'C14 (Carousel 14)','C14'

        ));

        testObject.UnitTestLocationData.add(loc26);
        testObject.UnitTestLocationData.add(locP1);

        testObject.UnitTestSkuData = new Map<String, Id>();
                Map<Id,String> skuDataReversLookup = new Map<Id,String>();
        testObject.UnitTestSkuData.put('product1',FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType));
        skuDataReversLookup.put(testObject.UnitTestSkuData.get('product1'),'product1');
        testObject.UnitTestSkuData.put('product2',FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType));
        skuDataReversLookup.put(testObject.UnitTestSkuData.get('product2'),'product2');


        Map<String,FMGRSAPI_InventoryMove_Rest.InventoryMoveRequest> movesToExecute
                = new Map<String,FMGRSAPI_InventoryMove_Rest.InventoryMoveRequest>();
        FMGRSAPI_InventoryMove_Rest.InventoryMoveRequest moveRequest = new FMGRSAPI_InventoryMove_Rest.InventoryMoveRequest();
        moveRequest.Quantity = 10;
        moveRequest.ToLocation = new FMGRSAPI_InventoryMove_Rest.Location();
        moveRequest.ToLocation.LocationId = 'P1';
        moveRequest.ToLocation.LocationNumber = 'C5';
        moveRequest.FromLocation = new FMGRSAPI_InventoryMove_Rest.Location();
        moveRequest.FromLocation.LocationId = '26';
        moveRequest.FromLocation.LocationNumber = 'HF12BB00';
        moveRequest.ProductSku = 'product1';
        movesToExecute.put('product1',moveRequest);

        moveRequest = new FMGRSAPI_InventoryMove_Rest.InventoryMoveRequest();
        moveRequest.Quantity = 10;
        moveRequest.ToLocation = new FMGRSAPI_InventoryMove_Rest.Location();
        moveRequest.ToLocation.LocationId = 'P1';
        moveRequest.ToLocation.LocationNumber = 'C14';
        moveRequest.FromLocation = new FMGRSAPI_InventoryMove_Rest.Location();
        moveRequest.FromLocation.LocationId = '26';
        moveRequest.FromLocation.LocationNumber = 'HN13HH00';
        moveRequest.SalesforceProductId = testObject.UnitTestSkuData.get('product2');
        movesToExecute.put('product2',moveRequest);

        List<FMGRSAPI_Inventory_Service.InventoryMoveRequest> convertedMoveEvents = new List<FMGRSAPI_Inventory_Service.InventoryMoveRequest>();

        for(FMGRSAPI_InventoryMove_Rest.InventoryMoveRequest moveEvent: movesToExecute.values()) {
            convertedMoveEvents.add(moveEvent.convert());
        }



        Test.startTest();
        testObject.moveItems(convertedMoveEvents,false);
        Test.stopTest();

        for(rstk__sydatat__c results: testObject.itemMoves){
            FMGRSAPI_InventoryMove_Rest.InventoryMoveRequest request = movesToExecute.get(skuDataReversLookup.get(results.rstk__sydata_icitem__c));
            System.assert(request.Quantity == results.rstk__sydata_txnqty__c);
        }

    }

    @IsTest(SeeAllData=true)
    static void SkuIdPullTest(){
        //getSkuToId

        rstk__icitem__c testRecord = [
        SELECT Id, rstk__icitem_item__c,
                rstk__icitem_item__r.rstk__index_item__c
        FROM rstk__icitem__c
        limit 1];

        Set<string> testRequest = new Set<String>();
        testRequest.add(testRecord.rstk__icitem_item__r.rstk__index_item__c);


        FMGRSAPI_Inventory_Service testObject = new FMGRSAPI_Inventory_Service();

        System.debug(JSON.serializePretty(testRequest));
        Test.startTest();
        Map<String, Id> results = testObject.getSkuToId(testRequest);
        Test.stopTest();
        System.debug(JSON.serializePretty(results));
        System.assertEquals(testRecord.Id,results.get(testRecord.rstk__icitem_item__r.rstk__index_item__c));

    }
    @IsTest
    static void SingleLocationPick(){
        FMGRSAPI_Inventory_Service testObject =InitPickGen();
        Map<String, Map<String, Map<String,FMGRSAPI_Inventory_Service.LocationInfo >>> locationData =
                getLocationData(testObject);
        List<String> locationIds = new List<String>();


        locationIds.add('26');
        locationIds.add('25');
        locationIds.add('P1');

        System.debug('**********Run Test*******');
        Test.startTest();
        List<FMGRSAPI_Inventory_Service.PickLocation> Pull1 = testObject.getPickLocations('A1',2.0,locationData,locationIds,false,false,false);
        List<FMGRSAPI_Inventory_Service.PickLocation> Pull2 = testObject.getPickLocations('A1',5.0,locationData,locationIds,false,false,false);
        List<FMGRSAPI_Inventory_Service.PickLocation> Pull3 = testObject.getPickLocations('A1',10.0,locationData,locationIds,false,false,false);

        Test.stopTest();
        System.debug('**********Raw Output*******');
        System.debug(Pull1);
        System.assert(Pull1.size() == 1);
        System.assert(Pull1[0].LocationName == '26');
        System.assert(Pull2.size() == 1);
        System.assert(Pull2[0].LocationName == 'P1');
        System.assert(Pull3.size() == 0);
    }

    @IsTest
    static void SingleLocationPickWithSupplyMultiplier(){

        FMGRSAPI_Inventory_Service testObject = new FMGRSAPI_Inventory_Service();
        List<FMGRSAPI_Inventory_Service.LocationInfo> locationInfos = new List<FMGRSAPI_Inventory_Service.LocationInfo>();


        locationInfos.add(FMG_TestUtility.generateLocationInfo('A1','26','H1',30,10,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('B1','26','H1',15,10,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));

        testObject.UnitTest_GetProductLocations = testObject.createSearchableProductLocation(locationInfos);

        Map<String, Map<String, Map<String,FMGRSAPI_Inventory_Service.LocationInfo >>> locationData =
                getLocationData(testObject);

        List<String> locationIds = new List<String>();

        locationIds.add('26');

        System.debug('**********Run Test*******');
        Test.startTest();
        List<FMGRSAPI_Inventory_Service.PickLocation> pull1 = testObject.getPickLocations('A1',12.0,locationData,locationIds,false,false,true);
        List<FMGRSAPI_Inventory_Service.PickLocation> pull2 = testObject.getPickLocations('B1',12.0,locationData,locationIds,false,false,true);

        Test.stopTest();
        System.debug('**********Raw Output*******');
        System.debug(pull1);
        System.debug(pull2);
        System.assertEquals(pull1.size() , 1, 'pull1: Did not generate 1 location pull');
        System.assertEquals(pull1[0].Qty , 20, 'pull1: Expected value of 20 but got back ' + pull1[0].Qty);
        System.assertEquals(pull2.size(), 1, 'pull2: Did not generate 1 location pull');
        System.assertNotEquals(pull2[0].Qty, 20, 'pull2: Expected value of 20 but got back ' + pull2[0].Qty);
    }

    @IsTest
    static void MultipleNumLocationPick(){
        FMGRSAPI_Inventory_Service testObject =InitPickGen();
        Map<String, Map<String, Map<String,FMGRSAPI_Inventory_Service.LocationInfo >>> locationData =
                getLocationData(testObject);
        List<String> locationIds = new List<String>();


        locationIds.add('26');
        locationIds.add('25');
        locationIds.add('P1');

        System.debug('**********Run Test*******');
        Test.startTest();

        List<FMGRSAPI_Inventory_Service.PickLocation> Pull1 = testObject.getPickLocations('A1',2.0,locationData,locationIds,true,false,false);
        List<FMGRSAPI_Inventory_Service.PickLocation> Pull2 = testObject.getPickLocations('A1',5.0,locationData,locationIds,true,false,false);
        List<FMGRSAPI_Inventory_Service.PickLocation> pull3 = testObject.getPickLocations('A1',6.0,locationData,locationIds,true,false,false);

        Test.stopTest();
        System.debug('**********Raw Output*******');
        System.debug(Pull1);
        System.debug(Pull2);
        System.debug(pull3);
        System.assert(Pull1.size() == 1, 'Pull 1 - Found: ' + Pull1.size() + ' Expected: 1' );
        System.assert(Pull1[0].LocationName == '26', 'Pull 1 - Found: ' + Pull1[0].LocationName + ' Expected: 1' );
        System.assert(Pull2.size() == 1, 'Pull 2 - Found: ' + Pull2.size() + ' Expected: 1' );
        System.assert(Pull2[0].LocationName == 'P1', 'Pull 2 - Found: ' + Pull2[0].LocationName + ' Expected: 2' );
        System.assert(pull3.size() == 2, 'Pull 3 - Found: ' + pull3.size() + ' Expected: 2' );

        Decimal count = 0;
        for(FMGRSAPI_Inventory_Service.PickLocation pull3Data: pull3){
            count = count + pull3Data.Qty;
            System.assert(pull3Data.LocationName == '26', 'Pull 3 - Found: ' + pull3Data.LocationName + ' Expected: 26' );
        }

        System.assert(count == 6);


    }

    @IsTest
    static void MultipleNumLocationPickWithSupplyMultiplier(){

        FMGRSAPI_Inventory_Service testObject = new FMGRSAPI_Inventory_Service();
        List<FMGRSAPI_Inventory_Service.LocationInfo> locationInfos = new List<FMGRSAPI_Inventory_Service.LocationInfo>();

        locationInfos.add(FMG_TestUtility.generateLocationInfo('A1','26','H1',11,10,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('A1','26','H2',11,10,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('B1','26','H1',7,10,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('B1','26','H2',7,10,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));

        testObject.UnitTest_GetProductLocations = testObject.createSearchableProductLocation(locationInfos);

        Map<String, Map<String, Map<String,FMGRSAPI_Inventory_Service.LocationInfo >>> locationData =
                getLocationData(testObject);

        List<String> locationIds = new List<String>();

        locationIds.add('26');

        System.debug('**********Run Test*******');
        Test.startTest();
        List<FMGRSAPI_Inventory_Service.PickLocation> pull1 = testObject.getPickLocations('A1',12.0,locationData,locationIds,true,false,true);
        List<FMGRSAPI_Inventory_Service.PickLocation> pull2 = testObject.getPickLocations('B1',12.0,locationData,locationIds,true,false,true);

        Test.stopTest();
        System.debug('**********Raw Output*******');
        System.debug(JSON.serializePretty(pull1));
        System.debug(JSON.serializePretty(pull2));
        System.assertEquals(pull1.size() , 2, 'pull1: Did not generate 2 location pull');
        System.assertEquals(pull1[0].Qty , 11, 'pull1: Expected value of 11 but got back ' + pull1[0].Qty);
        System.assertEquals(pull1[1].Qty , 10, 'pull1: Expected value of 10 but got back ' + pull1[1].Qty);
        System.assertEquals(pull2.size(), 2, 'pull2: Did not generate 1 location pull');
        System.assertEquals(pull2[0].Qty, 7, 'pull2: Expected value of 7 but got back ' + pull2[0].Qty);
        System.assertEquals(pull2[0].Qty, 7, 'pull2: Expected value of 7 but got back ' + pull2[0].Qty);
    }

    @IsTest
    static void MultipleLocIdLocationPick(){
        FMGRSAPI_Inventory_Service testObject =InitPickGen();
        Map<String, Map<String, Map<String,FMGRSAPI_Inventory_Service.LocationInfo >>> locationData =
                getLocationData(testObject);
        List<String> locationIds = new List<String>();


        locationIds.add('26');
        locationIds.add('25');
        locationIds.add('P1');

        System.debug('**********Run Test*******');
        Test.startTest();

        List<FMGRSAPI_Inventory_Service.PickLocation> Pull1 = testObject.getPickLocations('A1',2.0,locationData,locationIds,true,true,false);
        List<FMGRSAPI_Inventory_Service.PickLocation> Pull2 = testObject.getPickLocations('A1',5.0,locationData,locationIds,true,true,false);
        List<FMGRSAPI_Inventory_Service.PickLocation> pull3 = testObject.getPickLocations('A1',10.0,locationData,locationIds,true,true,false);

        Test.stopTest();
        System.debug('**********Raw Output*******');
        System.debug(Pull1);
        System.debug(Pull2);
        System.debug(pull3);
        System.assert(Pull1.size() == 1, 'Pull 1 - Found: ' + Pull1.size() + ' Expected: 1' );
        System.assert(Pull1[0].LocationName == '26', 'Pull 1 - Found: ' + Pull1[0].LocationName + ' Expected: 1' );
        System.assert(Pull2.size() == 1, 'Pull 2 - Found: ' + Pull2.size() + ' Expected: 1' );
        System.assert(Pull2[0].LocationName == 'P1', 'Pull 2 - Found: ' + Pull2[0].LocationName + ' Expected: 2' );
        System.assert(pull3.size() == 4, 'Pull 3 - Found: ' + pull3.size() + ' Expected: 4' );

        Decimal count = 0;
        for(FMGRSAPI_Inventory_Service.PickLocation pull3Data: pull3){
            count = count + pull3Data.Qty;
            //System.assert(pull3Data.LocationIdName == '26', 'Pull 3 - Found: ' + pull3Data.LocationIdName + ' Expected: 26' );
        }
        System.assert(count == 10);
    }

    @IsTest
    static void LocationInfoSourceAsc(){
        List<FMGRSAPI_Inventory_Service.LocationInfo> locationInfos = new List<FMGRSAPI_Inventory_Service.LocationInfo>();
        locationInfos.add(FMG_TestUtility.generateLocationInfo('A1','26','H1',5,1,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('A1','26','H2',2,1,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('A1','26','H3',3,1,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));

        for(FMGRSAPI_Inventory_Service.LocationInfo item:locationInfos){
            item.AscOrder=true;
        }
        System.debug(locationInfos);
        Test.startTest();
        locationInfos.sort();
        Test.stopTest();
        System.debug(locationInfos);
        System.assert(locationInfos[0].Qty == 2);
        System.assert(locationInfos[1].Qty == 3);
        System.assert(locationInfos[2].Qty == 5);
    }

    @IsTest
    static void LocationInfoSourceDesc(){
        List<FMGRSAPI_Inventory_Service.LocationInfo> locationInfos = new List<FMGRSAPI_Inventory_Service.LocationInfo>();
        locationInfos.add(FMG_TestUtility.generateLocationInfo('A1','26','H1',5,1,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('A1','26','H2',2,1,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('A1','26','H3',3,1,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));

        for(FMGRSAPI_Inventory_Service.LocationInfo item:locationInfos){
            item.AscOrder=false;
        }
        System.debug(locationInfos);
        Test.startTest();
        locationInfos.sort();
        Test.stopTest();
        System.debug(locationInfos);
        System.assert(locationInfos[0].Qty == 5);
        System.assert(locationInfos[1].Qty == 3);
        System.assert(locationInfos[2].Qty == 2);
    }



    @IsTest(SeeAllData=true)
    static void getLocationIdsSOQLAndMapping(){


        FMGRSAPI_Inventory_Service testOjbject = new FMGRSAPI_Inventory_Service();
        Set<String> TestLocationIds = new Set<String>();

        List<FMGRSAPI_Inventory_Service.RawLocationId> location_P1;
        List<FMGRSAPI_Inventory_Service.RawLocationId> location_P1_ById;
        List<FMGRSAPI_Inventory_Service.RawLocationId> location_25;
        Test.startTest();
        TestLocationIds.add('P1');
        location_P1 = testOjbject.getLocationIds(TestLocationIds);
        TestLocationIds.clear();
        String p1Id = location_P1[0].LocationId;
        TestLocationIds.add(p1Id);
        location_P1_ById = testOjbject.getLocationIds(TestLocationIds);
        TestLocationIds.clear();

        TestLocationIds.add('25 (DC Bulk)');
        location_25 = testOjbject.getLocationIds(TestLocationIds);

        Test.stopTest();

        System.assertEquals(1,location_P1.size());
        System.assertEquals(1,location_P1_ById.size());
        System.assertEquals(1,location_25.size());

        System.assertEquals('P1 (Primary)', location_P1[0].Name );
        System.assertEquals('P1',location_P1[0].LocationId);

        System.assertEquals( 'P1 (Primary)',location_P1[0].Name );
        System.assertEquals( 'P1',location_P1[0].LocationId );

        System.assertEquals( 'P1 (Primary)',location_P1_ById[0].Name );
        System.assertEquals( 'P1',location_P1_ById[0].LocationId );


        System.assertEquals('25 (DC Bulk)',location_25[0].Name );
        System.assertEquals('25',location_25[0].LocationId );

    }

    /*@IsTest(SeeAllData=true)
    static void getProductLocationsAndMapping(){
        FMGRSAPI_Inventory_Service testOjbject = new FMGRSAPI_Inventory_Service();
        Set<String> product = new Set<String>();
        List<String> locationIds = new List<String>();
        locationIds.add('P1');
        locationIds.add('26');
        product.add('3176CY');
        product.add('1101CY');

        Test.startTest();
        Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>> products = testOjbject.getProductLocations(
                product  ,locationIds
        );
        Test.stopTest();
        if(products.isEmpty()){
          System.debug('No data to test with');
            return;
        }

        System.assert(products.containsKey('P1'));
        System.assert(products.containsKey('26'));
        System.assert(products.get('P1').size()>0);
        System.assert(products.get('26').size()>0);
    }*/

    /*@IsTest(SeeAllData=true)
    static void getProductLocationsAndMappingtest(){
        FMGRSAPI_Inventory_Service testOjbject = new FMGRSAPI_Inventory_Service();
        Set<String> product = new Set<String>();
        List<String> locationIds = new List<String>();
        locationIds.add('26');
        locationIds.add('25');
        locationIds.add('P1');
        product.add('1063PS');
        product.add('1034CH');
        product.add('3664CR');
        product.add('4964NB');
        product.add('5616MD');
        Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>> productsMRP = testOjbject.getProductLocationsMRP(product  ,locationIds);

        Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>> productsDRP = testOjbject.getProductLocationsDRP(product  ,locationIds);

        system.debug('************************DRP Qty Pull*************************');
        System.debug(JSON.serializePretty(productsDRP));
        system.debug('************************MRP Qty Pull*************************');
        System.debug(JSON.serializePretty(productsMRP));



        // Check for missing and content of found
        for(String locationName: productsMRP.keySet()){

            if(!productsDRP.containsKey(locationName)){
                System.assert(false,'new pull missing: ' + locationName);
                continue;
            }
            System.assert(true);
            Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>> MRPLocationNameValue = productsMRP.get(locationName);
            Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>> DRPLocationNameValue = productsDRP.get(locationName);




            for(String item: MRPLocationNameValue.keySet()){
                if(!DRPLocationNameValue.containsKey(item)){
                    System.assert(false,'new pull missing: ' + locationName + '.' + item);
                    continue;
                }
                System.assert(true);
                Map<String, FMGRSAPI_Inventory_Service.LocationInfo> MRPItemValue = MRPLocationNameValue.get(item);
                Map<String, FMGRSAPI_Inventory_Service.LocationInfo> DRPItemValue = DRPLocationNameValue.get(item);


                for(String locationNumber: MRPItemValue.keySet()){

                    if(!DRPItemValue.containsKey(locationNumber)){
                        System.assert(false,'new pull missing: ' + locationName + '.' + item + '.' + locationNumber);
                        continue;
                    }
                    FMGRSAPI_Inventory_Service.LocationInfo mprLocation = MRPItemValue.get(locationNumber);
                    FMGRSAPI_Inventory_Service.LocationInfo drpLocation = DRPItemValue.get(locationNumber);

                    System.assertEquals(mprLocation.IclocitemId,drpLocation.IclocitemId);
                    System.assertEquals(mprLocation.OriginalQty,drpLocation.OriginalQty);
                    System.assertEquals(mprLocation.LocationNumber,drpLocation.LocationNumber);
                    System.assertEquals(mprLocation.LocationId,drpLocation.LocationId);
                    System.assertEquals(mprLocation.LocationName,drpLocation.LocationName);
                    System.assertEquals(mprLocation.LocationFormulaName,drpLocation.LocationFormulaName);
                    System.assertEquals(mprLocation.DivisionId,drpLocation.DivisionId);
                    System.assertEquals(mprLocation.SiteId,drpLocation.SiteId);
                    System.assertEquals(mprLocation.ProjectId,drpLocation.ProjectId);
                    System.assertEquals(mprLocation.ItemId,drpLocation.ItemId);
                    System.assertEquals(mprLocation.Item,drpLocation.Item);
                    System.assertEquals(mprLocation.AscOrder,drpLocation.AscOrder);
                }
            }
        }

        // Check for missing and content of found
        for(String locationName: productsDRP.keySet()){

            if(!productsMRP.containsKey(locationName)){
                System.assert(false,'new pull missing: ' + locationName);
                continue;
            }
            System.assert(true);
            Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>> MRPLocationNameValue = productsMRP.get(locationName);
            Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>> DRPLocationNameValue = productsDRP.get(locationName);



            for(String item: DRPLocationNameValue.keySet()){
                if(!MRPLocationNameValue.containsKey(item)){
                    System.assert(false,'new pull missing: ' + locationName + '.' + item);
                    continue;
                }
                System.assert(true);
                Map<String, FMGRSAPI_Inventory_Service.LocationInfo> MRPItemValue = MRPLocationNameValue.get(item);
                Map<String, FMGRSAPI_Inventory_Service.LocationInfo> DRPItemValue = DRPLocationNameValue.get(item);


                for(String locationNumber: DRPItemValue.keySet()){

                    if(!MRPItemValue.containsKey(locationNumber)){
                        System.assert(false,'new pull missing: ' + locationName + '.' + item + '.' + locationNumber);
                    }
                }
            }
        }


    }*/

    /*@IsTest(SeeAllData=true)
    static void getOrderItemsLocationsAndMapping(){
        // Get a random order
        AggregateResult[] testdata = [SELECT  rstk__soline_sohdr__c, COUNT(Id) lines
        FROM rstk__soline__c
        WHERE rstk__soline_avtoallocpick__c > 1 AND rstk__soline_cancelled__c = FALSE
        GROUP BY rstk__soline_sohdr__c
        LIMIT 1];

        if(testdata.isEmpty()){
            System.debug('No data to test with');
            return ;
        }
        FMGRSAPI_Inventory_Service testOjbject = new FMGRSAPI_Inventory_Service();
        List<String> orders = new List<Id>();
        orders.add(String.valueOf(testdata[0].get('rstk__soline_sohdr__c')));
        Test.startTest();
        List<FMGRSAPI_Inventory_Service.rawOrderItem> results = testOjbject.getOrderItems(orders);
        Test.stopTest();


        //system.debug(JSON.serializePretty(results));
        System.assert(results.size()>0);
        FMGRSAPI_Inventory_Service.rawOrderItem firstItem = results[0];
        System.assert(firstItem.SupplyMultiplier >=0);
        System.assert(firstItem.SiteId != null);
        System.assert(firstItem.Qty > 0);
        System.assert(firstItem.ProjectId != null);
        System.assert(firstItem.LocationId != null);
        System.assert(firstItem.LocationNumber != null);
        System.assert(firstItem.LocationId != null);
        System.assert(firstItem.ItemId != null);
        System.assert(firstItem.Item != null);
        System.assert(firstItem.DivisionId != null);
    }
*/
  /*  @IsTest(SeeAllData=true)
    static void getSkuToId(){
        rstk__icitem__c  testRecords = [SELECT Id, rstk__icitem_item__c,
                rstk__icitem_item__r.rstk__index_item__c
        FROM rstk__icitem__c LIMIT 1];
        FMGRSAPI_Inventory_Service testObject = new FMGRSAPI_Inventory_Service();
        Set<String> emptyTestSkus = new Set<String>();
        Set<String> testSkus = new Set<String>();
        testSkus.add(testRecords.rstk__icitem_item__r.rstk__index_item__c);
        Test.startTest();
        Map<String,Id> mapping = testObject.getSkuToId(testSkus);
        Map<String,Id> mappingEmpty = testObject.getSkuToId(emptyTestSkus);
        Test.stopTest();

        System.debug('***************** Mapping ******************');
        System.debug(mapping);
        System.debug('***************** Empty ******************');
        System.debug(mappingEmpty);
        System.assertEquals(mappingEmpty.size(),0);
        System.assertEquals(mapping.size(),1);
        System.assert(mapping.containsKey(testRecords.rstk__icitem_item__r.rstk__index_item__c));
        System.assertEquals(mapping.get(testRecords.rstk__icitem_item__r.rstk__index_item__c),testRecords.Id);
    }*/

    @IsTest
    static void configPull(){
        FMGRSAPI_Inventory_Service testObject = new FMGRSAPI_Inventory_Service();
        FMG_Configuration__c testData = new FMG_Configuration__c();
        testData.Application__c = 'FMGRSAPI - InventoryAccess';
        testData.Setting__c = 'Create Inventory Move Source Location Ids';
        testData.Value__c = '26,25,P1';

        Test.startTest();
        List<String> results = testObject.getPickOrderLocationIds();
        Test.stopTest();

        System.assertEquals(results[0],'26');
        System.assertEquals(results[1],'25');
        System.assertEquals(results[2],'P1');


    }

    @IsTest
    static void CreateInventoryMoves(){
        FMGRSAPI_Inventory_Service testObject = new FMGRSAPI_Inventory_Service();

        // Dummy data collections
        List<FMGRSAPI_Inventory_Service.rawOrderItem> orderItems = new List<FMGRSAPI_Inventory_Service.rawOrderItem>();
        Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>> possibleDestinationInfo =
                new Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>>();
        Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>> activePullLocations =
                new Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>>();

        // Linking testing data collections
        testObject.UnitTest_CreateInventoryMoves_OrderItems = orderItems;
        testObject.UnitTest_CreateInventoryMoves_PossibleDestinationInfo = possibleDestinationInfo;
        testObject.UnitTest_CreateInventoryMoves_ActivePullLocations = activePullLocations;
        testObject.pickOrderLocationIds = new List<String>();
        testObject.pickOrderLocationIds.add('26');
        testObject.pickOrderLocationIds.add('25');

        // Init Items
        orderItems.add(generateRawOrderItem('Item1',15,10,'C1','P1'));
        possibleDestinationInfo.put('P1',new Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>());
        possibleDestinationInfo.get('P1').put('Item1',new Map<String, FMGRSAPI_Inventory_Service.LocationInfo>());
        possibleDestinationInfo.get('P1').get('Item1').put('C1',FMG_TestUtility.generateLocationInfo('Item1',10,10,0,'C1','P1'));

        activePullLocations.put('26',new Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>());
        activePullLocations.get('26').put('Item1',new Map<String, FMGRSAPI_Inventory_Service.LocationInfo>());
        activePullLocations.get('26').get('Item1').put('H1',FMG_TestUtility.generateLocationInfo('Item1',50,10,0,'H1','26'));

        List<Id> orderListIgnore = new List<Id>();
        orderListIgnore.add(FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType));
        Test.startTest();

        List<Id> sydataIds = testObject.createInventoryMoves(orderListIgnore);

        Test.stopTest();


        System.debug(LoggingLevel.FINE,'*********************************** SYDATAT ******************************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(testObject.CreateInventoryMoves_RootstockInventoryMoves));
        System.debug(LoggingLevel.FINE,'*********************************** Custom Move List ******************************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(testObject.CreateInventoryMoves_FMGInventoryMoves));
        System.debug(LoggingLevel.FINE,'*********************************** SYDATATIds ******************************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(sydataIds));

        System.assertEquals(testObject.CreateInventoryMoves_FMGInventoryMoves.size(),1);
        System.assertEquals(testObject.CreateInventoryMoves_FMGInventoryMoves[0].qty__c,10);
        System.assertEquals(testObject.CreateInventoryMoves_RootstockInventoryMoves.size(),1);
        System.assertEquals(testObject.CreateInventoryMoves_RootstockInventoryMoves[0].rstk__sydata_txnqty__c,10);
    }

    @IsTest
    static void CreateInventoryMoves_ordersQty0_NoPrimary(){
        FMGRSAPI_Inventory_Service testObject = new FMGRSAPI_Inventory_Service();

        // Generate New Ids
        Id siteId_fmg = FMG_TestUtility.getFakeId(rstk__sysite__c.SObjectType,'FMG');
        Id projectId_fmg = FMG_TestUtility.getFakeId(rstk__pjproj__c.SObjectType,'FMG');
        Id divisionId_fmg = FMG_TestUtility.getFakeId(rstk__sydiv__c.SObjectType,'FMG');
        Id locationId_P1 = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'P1');
        Id locationId_26 = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'26');
        //Id locationId_25 = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'25');
        Id itemId_5616MD = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'5616MD');
        Id itemId_1063PS = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'1063PS');
        Id itemId_1034CH = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'1034CH');
        Id itemId_3664CR = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'3664CR');
        Id itemId_2293CY = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'2293CY');
        Id itemId_4964NB = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'4964NB');
        Id itemId_1072PS = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'1072PS');
        Id itemId_1394BB = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'1394BB');
        Id itemId_2959PK = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'2959PK');
        Id itemId_1444BB = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'1444BB');
        Id itemId_1058PS = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'1058PS');
        Id itemId_2321CY = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'2321CY');


        Id IclocitemId_5616MD = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'5616MD');
        Id IclocitemId_1063PS = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'1063PS');
        Id IclocitemId_1034CH = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'1034CH');
        Id IclocitemId_3664CR = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'3664CR');
        Id IclocitemId_2293CY = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'2293CY');
        Id IclocitemId_4964NB = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'4964NB');
        Id IclocitemId_1072PS = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'1072PS');
        Id IclocitemId_1394BB = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'1394BB');
        Id IclocitemId_2959PK = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'2959PK');
        Id IclocitemId_1444BB = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'1444BB');
        Id IclocitemId_1058PS = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'1058PS');
        Id IclocitemId_2321CY = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'2321CY');

        // Json Test Data
        String activePullLocationsJson = '{"26":{"2293CY":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":197,"ProjectId":"'+projectId_fmg+'","OriginalQty":197,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_2293CY+'","Item":"2293CY","IclocitemId":"'+IclocitemId_2293CY+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":8,"AscOrder":false}},"1063PS":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":191,"ProjectId":"'+projectId_fmg+'","OriginalQty":191,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1063PS+'","Item":"1063PS","IclocitemId":"'+IclocitemId_1063PS+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":45,"AscOrder":false}},"4964NB":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":197,"ProjectId":"'+projectId_fmg+'","OriginalQty":197,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_4964NB+'","Item":"4964NB","IclocitemId":"'+IclocitemId_4964NB+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":20,"AscOrder":false}},"3664CR":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":199,"ProjectId":"'+projectId_fmg+'","OriginalQty":199,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_3664CR+'","Item":"3664CR","IclocitemId":"'+IclocitemId_3664CR+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":24,"AscOrder":false}},"1034CH":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":198,"ProjectId":"'+projectId_fmg+'","OriginalQty":198,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1034CH+'","Item":"1034CH","IclocitemId":"'+IclocitemId_1034CH+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":0,"AscOrder":false}},"1444BB":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":199,"ProjectId":"'+projectId_fmg+'","OriginalQty":199,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1444BB+'","Item":"1444BB","IclocitemId":"'+IclocitemId_1444BB+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":8,"AscOrder":false}},"1072PS":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":184,"ProjectId":"'+projectId_fmg+'","OriginalQty":184,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1072PS+'","Item":"1072PS","IclocitemId":"'+IclocitemId_1072PS+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":0,"AscOrder":false}},"2321CY":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":196,"ProjectId":"'+projectId_fmg+'","OriginalQty":196,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_2321CY+'","Item":"2321CY","IclocitemId":"'+IclocitemId_2321CY+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":52,"AscOrder":false}},"1058PS":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":196,"ProjectId":"'+projectId_fmg+'","OriginalQty":196,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1058PS+'","Item":"1058PS","IclocitemId":"'+IclocitemId_1058PS+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":8,"AscOrder":false}},"2959PK":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":198,"ProjectId":"'+projectId_fmg+'","OriginalQty":198,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_2959PK+'","Item":"2959PK","IclocitemId":"'+IclocitemId_2959PK+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":52,"AscOrder":false}},"1394BB":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":199,"ProjectId":"'+projectId_fmg+'","OriginalQty":199,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1394BB+'","Item":"1394BB","IclocitemId":"'+IclocitemId_1394BB+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":30,"AscOrder":false}},"5616MD":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":199,"ProjectId":"'+projectId_fmg+'","OriginalQty":199,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_5616MD+'","Item":"5616MD","IclocitemId":"'+IclocitemId_5616MD+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":20,"AscOrder":false}}}}';
        String possibleDestinationInfoJson = '{"26":{"2293CY":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":197.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":197.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_2293CY+'","Item":"2293CY","IclocitemId":"'+IclocitemId_2293CY+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":8.000000,"AscOrder":false}},"1063PS":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":191.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":191.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1063PS+'","Item":"1063PS","IclocitemId":"'+IclocitemId_1063PS+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":45.000000,"AscOrder":false}},"4964NB":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":197.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":197.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_4964NB+'","Item":"4964NB","IclocitemId":"'+IclocitemId_4964NB+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":20.000000,"AscOrder":false}},"3664CR":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":199.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":199.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_3664CR+'","Item":"3664CR","IclocitemId":"'+IclocitemId_3664CR+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":24.000000,"AscOrder":false}},"1034CH":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":198.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":198.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1034CH+'","Item":"1034CH","IclocitemId":"'+IclocitemId_1034CH+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":0,"AscOrder":false}},"1444BB":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":199.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":199.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1444BB+'","Item":"1444BB","IclocitemId":"'+IclocitemId_1444BB+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":8.000000,"AscOrder":false}},"1072PS":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":184.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":184.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1072PS+'","Item":"1072PS","IclocitemId":"'+IclocitemId_1072PS+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":0,"AscOrder":false}},"2321CY":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":196.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":196.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_2321CY+'","Item":"2321CY","IclocitemId":"'+IclocitemId_2321CY+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":52.000000,"AscOrder":false}},"1058PS":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":196.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":196.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1058PS+'","Item":"1058PS","IclocitemId":"'+IclocitemId_1058PS+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":8.000000,"AscOrder":false}},"2959PK":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":198.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":198.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_2959PK+'","Item":"2959PK","IclocitemId":"'+IclocitemId_2959PK+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":52.000000,"AscOrder":false}},"1394BB":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":199.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":199.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1394BB+'","Item":"1394BB","IclocitemId":"'+IclocitemId_1394BB+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":30.000000,"AscOrder":false}},"5616MD":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":199.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":199.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_5616MD+'","Item":"5616MD","IclocitemId":"'+IclocitemId_5616MD+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":20.000000,"AscOrder":false}}}}';
        String orderItemJson = '[{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_5616MD+'","Item":"5616MD","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_1063PS+'","Item":"1063PS","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_1034CH+'","Item":"1034CH","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_3664CR+'","Item":"3664CR","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_2293CY+'","Item":"2293CY","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_4964NB+'","Item":"4964NB","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_1072PS+'","Item":"1072PS","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_1394BB+'","Item":"1394BB","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C40","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_2959PK+'","Item":"2959PK","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_1444BB+'","Item":"1444BB","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_1058PS+'","Item":"1058PS","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_2321CY+'","Item":"2321CY","DivisionId":"'+divisionId_fmg+'"}]';



        // Generate Test Data Objects
        List<FMGRSAPI_Inventory_Service.rawOrderItem> orderItem = (List<FMGRSAPI_Inventory_Service.rawOrderItem>)JSON.deserialize(orderItemJson,List<FMGRSAPI_Inventory_Service.rawOrderItem>.class);
        Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>> possibleDestinationInfo = (Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>>)JSON.deserialize(possibleDestinationInfoJson,Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>>.class);
        Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>> activePullLocations =  (Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>>)JSON.deserialize(activePullLocationsJson,Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>>.class);

        // Linking testing data collections
        testObject.UnitTest_CreateInventoryMoves_OrderItems = orderItem;
        testObject.UnitTest_CreateInventoryMoves_PossibleDestinationInfo = possibleDestinationInfo;
        testObject.UnitTest_CreateInventoryMoves_ActivePullLocations = activePullLocations;
        testObject.pickOrderLocationIds = new List<String>();
        testObject.pickOrderLocationIds.add('26');
        testObject.pickOrderLocationIds.add('25');



        List<Id> orderListIgnore = new List<Id>();
        orderListIgnore.add(FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType));
        Test.startTest();

        List<Id> sydataIds = testObject.createInventoryMoves(orderListIgnore);

        Test.stopTest();


        System.debug('*********************************** SYDATAT ******************************');
        System.debug(JSON.serializePretty(testObject.CreateInventoryMoves_RootstockInventoryMoves));
        System.debug('*********************************** Custom Move List ******************************');
        System.debug(JSON.serializePretty(testObject.CreateInventoryMoves_FMGInventoryMoves));
        System.debug('*********************************** SYDATATIds ******************************');
        System.debug(JSON.serializePretty(sydataIds));

        System.assertEquals(0,testObject.CreateInventoryMoves_FMGInventoryMoves.size(), 'there should be no values');

    }

    @IsTest
    static void CreateInventoryMoves_ordersQty1_NoPrimary(){
        FMGRSAPI_Inventory_Service testObject = new FMGRSAPI_Inventory_Service();

        // Generate New Ids
        Id siteId_fmg = FMG_TestUtility.getFakeId(rstk__sysite__c.SObjectType,'FMG');
        Id projectId_fmg = FMG_TestUtility.getFakeId(rstk__pjproj__c.SObjectType,'FMG');
        Id divisionId_fmg = FMG_TestUtility.getFakeId(rstk__sydiv__c.SObjectType,'FMG');
        Id locationId_P1 = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'P1');
        Id locationId_26 = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'26');
        //Id locationId_25 = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'25');
        Id itemId_5616MD = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'5616MD');
        Id itemId_1063PS = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'1063PS');
        Id itemId_1034CH = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'1034CH');
        Id itemId_3664CR = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'3664CR');
        Id itemId_2293CY = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'2293CY');
        Id itemId_4964NB = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'4964NB');
        Id itemId_1072PS = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'1072PS');
        Id itemId_1394BB = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'1394BB');
        Id itemId_2959PK = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'2959PK');
        Id itemId_1444BB = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'1444BB');
        Id itemId_1058PS = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'1058PS');
        Id itemId_2321CY = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'2321CY');


        Id IclocitemId_5616MD = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'5616MD');
        Id IclocitemId_1063PS = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'1063PS');
        Id IclocitemId_1034CH = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'1034CH');
        Id IclocitemId_3664CR = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'3664CR');
        Id IclocitemId_2293CY = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'2293CY');
        Id IclocitemId_4964NB = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'4964NB');
        Id IclocitemId_1072PS = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'1072PS');
        Id IclocitemId_1394BB = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'1394BB');
        Id IclocitemId_2959PK = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'2959PK');
        Id IclocitemId_1444BB = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'1444BB');
        Id IclocitemId_1058PS = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'1058PS');
        Id IclocitemId_2321CY = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'2321CY');

        // Json Test Data
        String activePullLocationsJson = '{"26":{"2293CY":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":197,"ProjectId":"'+projectId_fmg+'","OriginalQty":197,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_2293CY+'","Item":"2293CY","IclocitemId":"'+IclocitemId_2293CY+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":8,"AscOrder":false}},"1063PS":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":191,"ProjectId":"'+projectId_fmg+'","OriginalQty":191,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1063PS+'","Item":"1063PS","IclocitemId":"'+IclocitemId_1063PS+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":45,"AscOrder":false}},"4964NB":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":197,"ProjectId":"'+projectId_fmg+'","OriginalQty":197,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_4964NB+'","Item":"4964NB","IclocitemId":"'+IclocitemId_4964NB+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":20,"AscOrder":false}},"3664CR":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":199,"ProjectId":"'+projectId_fmg+'","OriginalQty":199,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_3664CR+'","Item":"3664CR","IclocitemId":"'+IclocitemId_3664CR+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":24,"AscOrder":false}},"1034CH":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":198,"ProjectId":"'+projectId_fmg+'","OriginalQty":198,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1034CH+'","Item":"1034CH","IclocitemId":"'+IclocitemId_1034CH+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":0,"AscOrder":false}},"1444BB":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":199,"ProjectId":"'+projectId_fmg+'","OriginalQty":199,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1444BB+'","Item":"1444BB","IclocitemId":"'+IclocitemId_1444BB+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":8,"AscOrder":false}},"1072PS":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":184,"ProjectId":"'+projectId_fmg+'","OriginalQty":184,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1072PS+'","Item":"1072PS","IclocitemId":"'+IclocitemId_1072PS+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":0,"AscOrder":false}},"2321CY":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":196,"ProjectId":"'+projectId_fmg+'","OriginalQty":196,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_2321CY+'","Item":"2321CY","IclocitemId":"'+IclocitemId_2321CY+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":52,"AscOrder":false}},"1058PS":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":196,"ProjectId":"'+projectId_fmg+'","OriginalQty":196,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1058PS+'","Item":"1058PS","IclocitemId":"'+IclocitemId_1058PS+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":8,"AscOrder":false}},"2959PK":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":198,"ProjectId":"'+projectId_fmg+'","OriginalQty":198,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_2959PK+'","Item":"2959PK","IclocitemId":"'+IclocitemId_2959PK+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":52,"AscOrder":false}},"1394BB":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":199,"ProjectId":"'+projectId_fmg+'","OriginalQty":199,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1394BB+'","Item":"1394BB","IclocitemId":"'+IclocitemId_1394BB+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":30,"AscOrder":false}},"5616MD":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":199,"ProjectId":"'+projectId_fmg+'","OriginalQty":199,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_5616MD+'","Item":"5616MD","IclocitemId":"'+IclocitemId_5616MD+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":20,"AscOrder":false}}}}';
        String possibleDestinationInfoJson = '{"26":{"2293CY":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":197.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":197.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_2293CY+'","Item":"2293CY","IclocitemId":"'+IclocitemId_2293CY+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":8.000000,"AscOrder":false}},"1063PS":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":191.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":191.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1063PS+'","Item":"1063PS","IclocitemId":"'+IclocitemId_1063PS+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":45.000000,"AscOrder":false}},"4964NB":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":197.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":197.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_4964NB+'","Item":"4964NB","IclocitemId":"'+IclocitemId_4964NB+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":20.000000,"AscOrder":false}},"3664CR":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":199.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":199.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_3664CR+'","Item":"3664CR","IclocitemId":"'+IclocitemId_3664CR+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":24.000000,"AscOrder":false}},"1034CH":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":198.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":198.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1034CH+'","Item":"1034CH","IclocitemId":"'+IclocitemId_1034CH+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":0,"AscOrder":false}},"1444BB":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":199.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":199.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1444BB+'","Item":"1444BB","IclocitemId":"'+IclocitemId_1444BB+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":8.000000,"AscOrder":false}},"1072PS":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":184.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":184.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1072PS+'","Item":"1072PS","IclocitemId":"'+IclocitemId_1072PS+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":0,"AscOrder":false}},"2321CY":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":196.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":196.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_2321CY+'","Item":"2321CY","IclocitemId":"'+IclocitemId_2321CY+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":52.000000,"AscOrder":false}},"1058PS":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":196.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":196.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1058PS+'","Item":"1058PS","IclocitemId":"'+IclocitemId_1058PS+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":8.000000,"AscOrder":false}},"2959PK":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":198.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":198.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_2959PK+'","Item":"2959PK","IclocitemId":"'+IclocitemId_2959PK+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":52.000000,"AscOrder":false}},"1394BB":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":199.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":199.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1394BB+'","Item":"1394BB","IclocitemId":"'+IclocitemId_1394BB+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":30.000000,"AscOrder":false}},"5616MD":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":199.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":199.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_5616MD+'","Item":"5616MD","IclocitemId":"'+IclocitemId_5616MD+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":20.000000,"AscOrder":false}}}}';
        String orderItemJson = '[{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":1,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_5616MD+'","Item":"5616MD","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_1063PS+'","Item":"1063PS","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_1034CH+'","Item":"1034CH","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_3664CR+'","Item":"3664CR","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_2293CY+'","Item":"2293CY","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_4964NB+'","Item":"4964NB","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_1072PS+'","Item":"1072PS","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_1394BB+'","Item":"1394BB","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C40","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_2959PK+'","Item":"2959PK","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_1444BB+'","Item":"1444BB","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_1058PS+'","Item":"1058PS","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_2321CY+'","Item":"2321CY","DivisionId":"'+divisionId_fmg+'"}]';



        // Generate Test Data Objects
        List<FMGRSAPI_Inventory_Service.rawOrderItem> orderItem = (List<FMGRSAPI_Inventory_Service.rawOrderItem>)JSON.deserialize(orderItemJson,List<FMGRSAPI_Inventory_Service.rawOrderItem>.class);
        Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>> possibleDestinationInfo = (Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>>)JSON.deserialize(possibleDestinationInfoJson,Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>>.class);
        Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>> activePullLocations =  (Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>>)JSON.deserialize(activePullLocationsJson,Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>>.class);

        // Linking testing data collections
        testObject.UnitTest_CreateInventoryMoves_OrderItems = orderItem;
        testObject.UnitTest_CreateInventoryMoves_PossibleDestinationInfo = possibleDestinationInfo;
        testObject.UnitTest_CreateInventoryMoves_ActivePullLocations = activePullLocations;
        testObject.pickOrderLocationIds = new List<String>();
        testObject.pickOrderLocationIds.add('26');
        testObject.pickOrderLocationIds.add('25');



        List<Id> orderListIgnore = new List<Id>();
        orderListIgnore.add(FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType));
        Test.startTest();

        List<Id> sydataIds = testObject.createInventoryMoves(orderListIgnore);

        Test.stopTest();


        System.debug('*********************************** SYDATAT ******************************');
        System.debug(JSON.serializePretty(testObject.CreateInventoryMoves_RootstockInventoryMoves));
        System.debug('*********************************** Custom Move List ******************************');
        System.debug(JSON.serializePretty(testObject.CreateInventoryMoves_FMGInventoryMoves));
        System.debug('*********************************** SYDATATIds ******************************');
        System.debug(JSON.serializePretty(sydataIds));

        System.assertEquals(1,testObject.CreateInventoryMoves_FMGInventoryMoves.size(), 'there should be no values');

    }

    @IsTest
    static void CreateInventoryMoves_ordersQty0_WithPrimary(){
        FMGRSAPI_Inventory_Service testObject = new FMGRSAPI_Inventory_Service();

        // Generate New Ids
        Id siteId_fmg = FMG_TestUtility.getFakeId(rstk__sysite__c.SObjectType,'FMG');
        Id projectId_fmg = FMG_TestUtility.getFakeId(rstk__pjproj__c.SObjectType,'FMG');
        Id divisionId_fmg = FMG_TestUtility.getFakeId(rstk__sydiv__c.SObjectType,'FMG');
        Id locationId_P1 = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'P1');
        Id locationId_26 = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'26');
        //Id locationId_25 = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'25');
        Id itemId_5616MD = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'5616MD');
        Id itemId_1063PS = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'1063PS');
        Id itemId_1034CH = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'1034CH');
        Id itemId_3664CR = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'3664CR');
        Id itemId_2293CY = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'2293CY');
        Id itemId_4964NB = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'4964NB');
        Id itemId_1072PS = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'1072PS');
        Id itemId_1394BB = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'1394BB');
        Id itemId_2959PK = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'2959PK');
        Id itemId_1444BB = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'1444BB');
        Id itemId_1058PS = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'1058PS');
        Id itemId_2321CY = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'2321CY');


        Id IclocitemId_5616MD = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'5616MD');
        Id IclocitemId_5616MD_P1 = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'5616MD_P1');
        Id IclocitemId_1063PS = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'1063PS');
        Id IclocitemId_1034CH = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'1034CH');
        Id IclocitemId_3664CR = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'3664CR');
        Id IclocitemId_2293CY = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'2293CY');
        Id IclocitemId_4964NB = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'4964NB');
        Id IclocitemId_1072PS = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'1072PS');
        Id IclocitemId_1394BB = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'1394BB');
        Id IclocitemId_2959PK = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'2959PK');
        Id IclocitemId_1444BB = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'1444BB');
        Id IclocitemId_1058PS = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'1058PS');
        Id IclocitemId_2321CY = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'2321CY');

        // Json Test Data
        String activePullLocationsJson = '{"26":{"2293CY":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":197,"ProjectId":"'+projectId_fmg+'","OriginalQty":197,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_2293CY+'","Item":"2293CY","IclocitemId":"'+IclocitemId_2293CY+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":8,"AscOrder":false}},"1063PS":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":191,"ProjectId":"'+projectId_fmg+'","OriginalQty":191,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1063PS+'","Item":"1063PS","IclocitemId":"'+IclocitemId_1063PS+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":45,"AscOrder":false}},"4964NB":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":197,"ProjectId":"'+projectId_fmg+'","OriginalQty":197,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_4964NB+'","Item":"4964NB","IclocitemId":"'+IclocitemId_4964NB+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":20,"AscOrder":false}},"3664CR":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":199,"ProjectId":"'+projectId_fmg+'","OriginalQty":199,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_3664CR+'","Item":"3664CR","IclocitemId":"'+IclocitemId_3664CR+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":24,"AscOrder":false}},"1034CH":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":198,"ProjectId":"'+projectId_fmg+'","OriginalQty":198,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1034CH+'","Item":"1034CH","IclocitemId":"'+IclocitemId_1034CH+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":0,"AscOrder":false}},"1444BB":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":199,"ProjectId":"'+projectId_fmg+'","OriginalQty":199,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1444BB+'","Item":"1444BB","IclocitemId":"'+IclocitemId_1444BB+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":8,"AscOrder":false}},"1072PS":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":184,"ProjectId":"'+projectId_fmg+'","OriginalQty":184,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1072PS+'","Item":"1072PS","IclocitemId":"'+IclocitemId_1072PS+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":0,"AscOrder":false}},"2321CY":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":196,"ProjectId":"'+projectId_fmg+'","OriginalQty":196,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_2321CY+'","Item":"2321CY","IclocitemId":"'+IclocitemId_2321CY+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":52,"AscOrder":false}},"1058PS":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":196,"ProjectId":"'+projectId_fmg+'","OriginalQty":196,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1058PS+'","Item":"1058PS","IclocitemId":"'+IclocitemId_1058PS+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":8,"AscOrder":false}},"2959PK":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":198,"ProjectId":"'+projectId_fmg+'","OriginalQty":198,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_2959PK+'","Item":"2959PK","IclocitemId":"'+IclocitemId_2959PK+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":52,"AscOrder":false}},"1394BB":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":199,"ProjectId":"'+projectId_fmg+'","OriginalQty":199,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1394BB+'","Item":"1394BB","IclocitemId":"'+IclocitemId_1394BB+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":30,"AscOrder":false}},"5616MD":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":199,"ProjectId":"'+projectId_fmg+'","OriginalQty":199,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_5616MD+'","Item":"5616MD","IclocitemId":"'+IclocitemId_5616MD+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":20,"AscOrder":false}}}}';
        String possibleDestinationInfoJson = '{ "P1" : {"5616MD" : {"HB10AA00" : { "SupplyMultiplier" : 25.00, "SiteId" : "'+siteId_fmg+'", "Qty" : 10.000000, "ProjectId" : "'+projectId_fmg+'", "OriginalQty" : 199.000000, "LocationNumber" : "HB10AA00", "LocationName" : "P1", "LocationId" : "'+locationId_P1+'", "LocationFormulaName" : "P1 (Bunker Bulk)", "ItemId" : "'+itemId_5616MD+'", "Item" : "5616MD", "IclocitemId" : "'+IclocitemId_5616MD_P1+'", "DivisionId" : "'+divisionId_fmg+'", "DesiredInventoryOnHand" : 20.000000, "AscOrder" : false } } },"26":{"2293CY":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":197.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":197.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_2293CY+'","Item":"2293CY","IclocitemId":"'+IclocitemId_2293CY+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":8.000000,"AscOrder":false}},"1063PS":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":191.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":191.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1063PS+'","Item":"1063PS","IclocitemId":"'+IclocitemId_1063PS+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":45.000000,"AscOrder":false}},"4964NB":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":197.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":197.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_4964NB+'","Item":"4964NB","IclocitemId":"'+IclocitemId_4964NB+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":20.000000,"AscOrder":false}},"3664CR":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":199.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":199.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_3664CR+'","Item":"3664CR","IclocitemId":"'+IclocitemId_3664CR+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":24.000000,"AscOrder":false}},"1034CH":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":198.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":198.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1034CH+'","Item":"1034CH","IclocitemId":"'+IclocitemId_1034CH+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":0,"AscOrder":false}},"1444BB":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":199.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":199.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1444BB+'","Item":"1444BB","IclocitemId":"'+IclocitemId_1444BB+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":8.000000,"AscOrder":false}},"1072PS":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":184.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":184.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1072PS+'","Item":"1072PS","IclocitemId":"'+IclocitemId_1072PS+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":0,"AscOrder":false}},"2321CY":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":196.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":196.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_2321CY+'","Item":"2321CY","IclocitemId":"'+IclocitemId_2321CY+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":52.000000,"AscOrder":false}},"1058PS":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":196.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":196.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1058PS+'","Item":"1058PS","IclocitemId":"'+IclocitemId_1058PS+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":8.000000,"AscOrder":false}},"2959PK":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":198.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":198.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_2959PK+'","Item":"2959PK","IclocitemId":"'+IclocitemId_2959PK+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":52.000000,"AscOrder":false}},"1394BB":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":199.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":199.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1394BB+'","Item":"1394BB","IclocitemId":"'+IclocitemId_1394BB+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":30.000000,"AscOrder":false}},"5616MD":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":199.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":199.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_5616MD+'","Item":"5616MD","IclocitemId":"'+IclocitemId_5616MD+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":20.000000,"AscOrder":false}}}}';
        String orderItemJson = '[{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_5616MD+'","Item":"5616MD","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_1063PS+'","Item":"1063PS","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_1034CH+'","Item":"1034CH","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_3664CR+'","Item":"3664CR","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_2293CY+'","Item":"2293CY","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_4964NB+'","Item":"4964NB","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_1072PS+'","Item":"1072PS","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_1394BB+'","Item":"1394BB","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C40","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_2959PK+'","Item":"2959PK","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_1444BB+'","Item":"1444BB","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_1058PS+'","Item":"1058PS","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_2321CY+'","Item":"2321CY","DivisionId":"'+divisionId_fmg+'"}]';



        // Generate Test Data Objects
        List<FMGRSAPI_Inventory_Service.rawOrderItem> orderItem = (List<FMGRSAPI_Inventory_Service.rawOrderItem>)JSON.deserialize(orderItemJson,List<FMGRSAPI_Inventory_Service.rawOrderItem>.class);
        Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>> possibleDestinationInfo = (Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>>)JSON.deserialize(possibleDestinationInfoJson,Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>>.class);
        Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>> activePullLocations =  (Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>>)JSON.deserialize(activePullLocationsJson,Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>>.class);

        // Linking testing data collections
        testObject.UnitTest_CreateInventoryMoves_OrderItems = orderItem;
        testObject.UnitTest_CreateInventoryMoves_PossibleDestinationInfo = possibleDestinationInfo;
        testObject.UnitTest_CreateInventoryMoves_ActivePullLocations = activePullLocations;
        testObject.pickOrderLocationIds = new List<String>();
        testObject.pickOrderLocationIds.add('26');
        testObject.pickOrderLocationIds.add('25');



        List<Id> orderListIgnore = new List<Id>();
        orderListIgnore.add(FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType));
        Test.startTest();

        List<Id> sydataIds = testObject.createInventoryMoves(orderListIgnore);

        Test.stopTest();


        System.debug('*********************************** SYDATAT ******************************');
        System.debug(JSON.serializePretty(testObject.CreateInventoryMoves_RootstockInventoryMoves));
        System.debug('*********************************** Custom Move List ******************************');
        System.debug(JSON.serializePretty(testObject.CreateInventoryMoves_FMGInventoryMoves));
        System.debug('*********************************** SYDATATIds ******************************');
        System.debug(JSON.serializePretty(sydataIds));

        System.assertEquals(0,testObject.CreateInventoryMoves_FMGInventoryMoves.size(), 'there should be no values');

    }

    @IsTest
    static void CreateInventoryMoves_ordersQty1_WithPrimary(){
        FMGRSAPI_Inventory_Service testObject = new FMGRSAPI_Inventory_Service();

        // Generate New Ids
        Id siteId_fmg = FMG_TestUtility.getFakeId(rstk__sysite__c.SObjectType,'FMG');
        Id projectId_fmg = FMG_TestUtility.getFakeId(rstk__pjproj__c.SObjectType,'FMG');
        Id divisionId_fmg = FMG_TestUtility.getFakeId(rstk__sydiv__c.SObjectType,'FMG');
        Id locationId_P1 = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'P1');
        Id locationId_26 = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'26');
        //Id locationId_25 = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,'25');
        Id itemId_5616MD = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'5616MD');
        Id itemId_1063PS = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'1063PS');
        Id itemId_1034CH = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'1034CH');
        Id itemId_3664CR = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'3664CR');
        Id itemId_2293CY = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'2293CY');
        Id itemId_4964NB = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'4964NB');
        Id itemId_1072PS = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'1072PS');
        Id itemId_1394BB = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'1394BB');
        Id itemId_2959PK = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'2959PK');
        Id itemId_1444BB = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'1444BB');
        Id itemId_1058PS = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'1058PS');
        Id itemId_2321CY = FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,'2321CY');


        Id IclocitemId_5616MD = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'5616MD');
        Id IclocitemId_5616MD_P1 = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'5616MD_P1');
        Id IclocitemId_1063PS = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'1063PS');
        Id IclocitemId_1034CH = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'1034CH');
        Id IclocitemId_3664CR = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'3664CR');
        Id IclocitemId_2293CY = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'2293CY');
        Id IclocitemId_4964NB = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'4964NB');
        Id IclocitemId_1072PS = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'1072PS');
        Id IclocitemId_1394BB = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'1394BB');
        Id IclocitemId_2959PK = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'2959PK');
        Id IclocitemId_1444BB = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'1444BB');
        Id IclocitemId_1058PS = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'1058PS');
        Id IclocitemId_2321CY = FMG_TestUtility.getFakeId(rstk__iclocitem__c.SObjectType,'2321CY');

        // Json Test Data
        String activePullLocationsJson = '{"26":{"2293CY":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":197,"ProjectId":"'+projectId_fmg+'","OriginalQty":197,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_2293CY+'","Item":"2293CY","IclocitemId":"'+IclocitemId_2293CY+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":8,"AscOrder":false}},"1063PS":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":191,"ProjectId":"'+projectId_fmg+'","OriginalQty":191,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1063PS+'","Item":"1063PS","IclocitemId":"'+IclocitemId_1063PS+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":45,"AscOrder":false}},"4964NB":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":197,"ProjectId":"'+projectId_fmg+'","OriginalQty":197,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_4964NB+'","Item":"4964NB","IclocitemId":"'+IclocitemId_4964NB+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":20,"AscOrder":false}},"3664CR":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":199,"ProjectId":"'+projectId_fmg+'","OriginalQty":199,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_3664CR+'","Item":"3664CR","IclocitemId":"'+IclocitemId_3664CR+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":24,"AscOrder":false}},"1034CH":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":198,"ProjectId":"'+projectId_fmg+'","OriginalQty":198,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1034CH+'","Item":"1034CH","IclocitemId":"'+IclocitemId_1034CH+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":0,"AscOrder":false}},"1444BB":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":199,"ProjectId":"'+projectId_fmg+'","OriginalQty":199,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1444BB+'","Item":"1444BB","IclocitemId":"'+IclocitemId_1444BB+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":8,"AscOrder":false}},"1072PS":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":184,"ProjectId":"'+projectId_fmg+'","OriginalQty":184,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1072PS+'","Item":"1072PS","IclocitemId":"'+IclocitemId_1072PS+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":0,"AscOrder":false}},"2321CY":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":196,"ProjectId":"'+projectId_fmg+'","OriginalQty":196,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_2321CY+'","Item":"2321CY","IclocitemId":"'+IclocitemId_2321CY+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":52,"AscOrder":false}},"1058PS":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":196,"ProjectId":"'+projectId_fmg+'","OriginalQty":196,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1058PS+'","Item":"1058PS","IclocitemId":"'+IclocitemId_1058PS+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":8,"AscOrder":false}},"2959PK":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":198,"ProjectId":"'+projectId_fmg+'","OriginalQty":198,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_2959PK+'","Item":"2959PK","IclocitemId":"'+IclocitemId_2959PK+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":52,"AscOrder":false}},"1394BB":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":199,"ProjectId":"'+projectId_fmg+'","OriginalQty":199,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1394BB+'","Item":"1394BB","IclocitemId":"'+IclocitemId_1394BB+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":30,"AscOrder":false}},"5616MD":{"HB10AA00":{"SupplyMultiplier":25,"SiteId":"'+siteId_fmg+'","Qty":199,"ProjectId":"'+projectId_fmg+'","OriginalQty":199,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_5616MD+'","Item":"5616MD","IclocitemId":"'+IclocitemId_5616MD+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":20,"AscOrder":false}}}}';
        String possibleDestinationInfoJson = '{ "P1" : {"5616MD" : {"HB10AA00" : { "SupplyMultiplier" : 25.00, "SiteId" : "'+siteId_fmg+'", "Qty" : 10.000000, "ProjectId" : "'+projectId_fmg+'", "OriginalQty" : 199.000000, "LocationNumber" : "HB10AA00", "LocationName" : "P1", "LocationId" : "'+locationId_P1+'", "LocationFormulaName" : "P1 (Bunker Bulk)", "ItemId" : "'+itemId_5616MD+'", "Item" : "5616MD", "IclocitemId" : "'+IclocitemId_5616MD_P1+'", "DivisionId" : "'+divisionId_fmg+'", "DesiredInventoryOnHand" : 20.000000, "AscOrder" : false } } },"26":{"2293CY":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":197.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":197.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_2293CY+'","Item":"2293CY","IclocitemId":"'+IclocitemId_2293CY+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":8.000000,"AscOrder":false}},"1063PS":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":191.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":191.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1063PS+'","Item":"1063PS","IclocitemId":"'+IclocitemId_1063PS+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":45.000000,"AscOrder":false}},"4964NB":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":197.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":197.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_4964NB+'","Item":"4964NB","IclocitemId":"'+IclocitemId_4964NB+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":20.000000,"AscOrder":false}},"3664CR":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":199.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":199.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_3664CR+'","Item":"3664CR","IclocitemId":"'+IclocitemId_3664CR+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":24.000000,"AscOrder":false}},"1034CH":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":198.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":198.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1034CH+'","Item":"1034CH","IclocitemId":"'+IclocitemId_1034CH+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":0,"AscOrder":false}},"1444BB":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":199.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":199.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1444BB+'","Item":"1444BB","IclocitemId":"'+IclocitemId_1444BB+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":8.000000,"AscOrder":false}},"1072PS":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":184.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":184.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1072PS+'","Item":"1072PS","IclocitemId":"'+IclocitemId_1072PS+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":0,"AscOrder":false}},"2321CY":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":196.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":196.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_2321CY+'","Item":"2321CY","IclocitemId":"'+IclocitemId_2321CY+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":52.000000,"AscOrder":false}},"1058PS":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":196.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":196.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1058PS+'","Item":"1058PS","IclocitemId":"'+IclocitemId_1058PS+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":8.000000,"AscOrder":false}},"2959PK":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":198.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":198.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_2959PK+'","Item":"2959PK","IclocitemId":"'+IclocitemId_2959PK+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":52.000000,"AscOrder":false}},"1394BB":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":199.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":199.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_1394BB+'","Item":"1394BB","IclocitemId":"'+IclocitemId_1394BB+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":30.000000,"AscOrder":false}},"5616MD":{"HB10AA00":{"SupplyMultiplier":25.00,"SiteId":"'+siteId_fmg+'","Qty":199.000000,"ProjectId":"'+projectId_fmg+'","OriginalQty":199.000000,"LocationNumber":"HB10AA00","LocationName":"26","LocationId":"'+locationId_26+'","LocationFormulaName":"26 (Bunker Bulk)","ItemId":"'+itemId_5616MD+'","Item":"5616MD","IclocitemId":"'+IclocitemId_5616MD+'","DivisionId":"'+divisionId_fmg+'","DesiredInventoryOnHand":20.000000,"AscOrder":false}}}}';
        String orderItemJson = '[{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":1,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_5616MD+'","Item":"5616MD","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_1063PS+'","Item":"1063PS","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_1034CH+'","Item":"1034CH","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_3664CR+'","Item":"3664CR","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_2293CY+'","Item":"2293CY","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_4964NB+'","Item":"4964NB","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_1072PS+'","Item":"1072PS","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_1394BB+'","Item":"1394BB","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C40","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_2959PK+'","Item":"2959PK","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_1444BB+'","Item":"1444BB","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_1058PS+'","Item":"1058PS","DivisionId":"'+divisionId_fmg+'"},{"SupplyMultiplier":1,"SiteId":"'+siteId_fmg+'","Qty":0,"ProjectId":"'+projectId_fmg+'","LocationNumber":"C5","LocationName":"P1","LocationId":"'+locationId_P1+'","LocationFormulaName":"P1 (Primary)","ItemId":"'+itemId_2321CY+'","Item":"2321CY","DivisionId":"'+divisionId_fmg+'"}]';



        // Generate Test Data Objects
        List<FMGRSAPI_Inventory_Service.rawOrderItem> orderItem = (List<FMGRSAPI_Inventory_Service.rawOrderItem>)JSON.deserialize(orderItemJson,List<FMGRSAPI_Inventory_Service.rawOrderItem>.class);
        Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>> possibleDestinationInfo = (Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>>)JSON.deserialize(possibleDestinationInfoJson,Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>>.class);
        Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>> activePullLocations =  (Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>>)JSON.deserialize(activePullLocationsJson,Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>>.class);

        // Linking testing data collections
        testObject.UnitTest_CreateInventoryMoves_OrderItems = orderItem;
        testObject.UnitTest_CreateInventoryMoves_PossibleDestinationInfo = possibleDestinationInfo;
        testObject.UnitTest_CreateInventoryMoves_ActivePullLocations = activePullLocations;
        testObject.pickOrderLocationIds = new List<String>();
        testObject.pickOrderLocationIds.add('26');
        testObject.pickOrderLocationIds.add('25');



        List<Id> orderListIgnore = new List<Id>();
        orderListIgnore.add(FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType));
        Test.startTest();

        List<Id> sydataIds = testObject.createInventoryMoves(orderListIgnore);

        Test.stopTest();


        System.debug('*********************************** SYDATAT ******************************');
        System.debug(JSON.serializePretty(testObject.CreateInventoryMoves_RootstockInventoryMoves));
        System.debug('*********************************** Custom Move List ******************************');
        System.debug(JSON.serializePretty(testObject.CreateInventoryMoves_FMGInventoryMoves));
        System.debug('*********************************** SYDATATIds ******************************');
        System.debug(JSON.serializePretty(sydataIds));

        System.assertEquals(1,testObject.CreateInventoryMoves_FMGInventoryMoves.size(), 'there should be no values');

    }

    @IsTest
    static void CreateInventoryMovesWithDesired(){
        FMGRSAPI_Inventory_Service testObject = new FMGRSAPI_Inventory_Service();

        // Dummy data collections
        List<FMGRSAPI_Inventory_Service.rawOrderItem> orderItems = new List<FMGRSAPI_Inventory_Service.rawOrderItem>();
        Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>> possibleDestinationInfo =
                new Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>>();
        Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>> activePullLocations =
                new Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>>();

        // Linking testing data collections
        testObject.UnitTest_CreateInventoryMoves_OrderItems = orderItems;
        testObject.UnitTest_CreateInventoryMoves_PossibleDestinationInfo = possibleDestinationInfo;
        testObject.UnitTest_CreateInventoryMoves_ActivePullLocations = activePullLocations;
        testObject.pickOrderLocationIds = new List<String>();
        testObject.pickOrderLocationIds.add('26');
        testObject.pickOrderLocationIds.add('25');

        // Init Items
        orderItems.add(generateRawOrderItem('Item1',15,10,'C1','P1'));
        possibleDestinationInfo.put('P1',new Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>());
        possibleDestinationInfo.get('P1').put('Item1',new Map<String, FMGRSAPI_Inventory_Service.LocationInfo>());
        possibleDestinationInfo.get('P1').get('Item1').put('C1',FMG_TestUtility.generateLocationInfo('Item1',10,5,25,'C1','P1'));

        activePullLocations.put('26',new Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>());
        activePullLocations.get('26').put('Item1',new Map<String, FMGRSAPI_Inventory_Service.LocationInfo>());
        activePullLocations.get('26').get('Item1').put('H1',FMG_TestUtility.generateLocationInfo('Item1',50,5,25,'H1','26'));

        List<Id> orderListIgnore = new List<Id>();
        orderListIgnore.add(FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType));
        Test.startTest();

        List<Id> sydataIds = testObject.createInventoryMoves(orderListIgnore);

        Test.stopTest();


        System.debug(LoggingLevel.FINE,'*********************************** SYDATAT ******************************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(testObject.CreateInventoryMoves_RootstockInventoryMoves));
        System.debug(LoggingLevel.FINE,'*********************************** Custom Move List ******************************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(testObject.CreateInventoryMoves_FMGInventoryMoves));
        System.debug(LoggingLevel.FINE,'*********************************** SYDATATIds ******************************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(sydataIds));

        System.assertEquals(1,testObject.CreateInventoryMoves_FMGInventoryMoves.size());
        System.assertEquals(30,testObject.CreateInventoryMoves_FMGInventoryMoves[0].qty__c);
        System.assertEquals(1,testObject.CreateInventoryMoves_RootstockInventoryMoves.size());
        System.assertEquals(30,testObject.CreateInventoryMoves_RootstockInventoryMoves[0].rstk__sydata_txnqty__c);


    }

    /**
     * @param Item Name of the Item
     * @param qty Qty that is being requested
     * @param SupplyMultiplier The amount to fill by chunks
     * @param locationNumber The location number for the default location of the item
     * @param LocationId The location Id Name for the default location Id Name of the item
     *
     * @return Generated version of the needed object
     **/
    private static FMGRSAPI_Inventory_Service.rawOrderItem generateRawOrderItem(String Item,Decimal qty,Decimal supplyMultiplier,String locationNumber,String LocationId){
        FMGRSAPI_Inventory_Service.rawOrderItem rawOrderItem = new FMGRSAPI_Inventory_Service.rawOrderItem();

        rawOrderItem.ItemId=FMG_TestUtility.getFakeId(rstk__icitem__c.SObjectType,Item);
        rawOrderItem.Item = Item;
        rawOrderItem.Qty = qty;
        rawOrderItem.LocationNumber = locationNumber;
        rawOrderItem.LocationId = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,LocationId);
        rawOrderItem.LocationName = LocationId;
        rawOrderItem.LocationFormulaName = LocationId + ' - FormulaName';
        rawOrderItem.SiteId = FMG_TestUtility.getFakeId(rstk__sysite__c.SObjectType,'FMG1');
        rawOrderItem.DivisionId = FMG_TestUtility.getFakeId(rstk__sydiv__c.SObjectType,'FMG');
        rawOrderItem.ProjectId = FMG_TestUtility.getFakeId(rstk__pjproj__c.SObjectType,'FMG');
        rawOrderItem.SupplyMultiplier = supplyMultiplier;
        return rawOrderItem;
    }
    private static Map<String, Map<String, Map<String,FMGRSAPI_Inventory_Service.LocationInfo >>> getLocationData(FMGRSAPI_Inventory_Service testObject){
        List<String> locations = new List<String>();
        locations.add('26');
        locations.add('25');
        locations.add('P1');
        Set<String> products = new Set<String>();
        products.add('A1');
        products.add('A2');
        products.add('A3');
        return testObject.getProductLocations(products,locations);
    }

    private static FMGRSAPI_Inventory_Service InitPickGen(){
        FMGRSAPI_Inventory_Service testObject = new FMGRSAPI_Inventory_Service();
        List<FMGRSAPI_Inventory_Service.LocationInfo> locationInfos = new List<FMGRSAPI_Inventory_Service.LocationInfo>();




        locationInfos.add(FMG_TestUtility.generateLocationInfo('A1','26','H1',3,1,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('A2','26','H2',5,1,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('A1','26','H3',3,1,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('A3','26','H4',5,1,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('A2','26','H5',3,1,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('A2','26','H6',5,1,0,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));

        locationInfos.add(FMG_TestUtility.generateLocationInfo('A1','25','G1',3,1,0,'25 (DC Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('A2','25','G2',5,1,0,'25 (DC Bulk)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('A3','25','G3',3,1,0,'25 (DC Bulk)','FMG','FMG_FMG1','FMG_'));

        locationInfos.add(FMG_TestUtility.generateLocationInfo('A1','P1','C1',5,1,0,'P1 (Primary)','FMG','FMG_FMG1','FMG_'));
        locationInfos.add(FMG_TestUtility.generateLocationInfo('A2','P1','C2',3,1,0,'P1 (Primary)','FMG','FMG_FMG1','FMG_'));

        testObject.UnitTest_GetProductLocations = testObject.createSearchableProductLocation(locationInfos);

        return testObject;
    }

}