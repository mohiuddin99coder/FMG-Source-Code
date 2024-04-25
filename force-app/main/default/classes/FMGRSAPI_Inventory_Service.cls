/**
 * @AUTHOR Adam Inscore
 * @DESCRIPTION This is for managing rootstock inventory
 **/
public with sharing class FMGRSAPI_Inventory_Service implements  FMGRSAPI_Inventory_ServiceInterface{


    /*************************************************************************************
    * Data Classes Output
    **************************************************************************************/

    /**
     * @AUTHOR Adam Inscore
     * @DESCRIPTION Custom object for the given class as parameters
     **/
    public class Location{
        public String LocationId{get;set;}
        public String LocationNumber{get;set;}
    }

    /**
     * @AUTHOR Adam Inscore
     * @DESCRIPTION Custom object for the given class as parameters
     **/
    public class InventoryMoveRequest{
        public Location FromLocation {get;set;}
        public Location ToLocation {get;set;}
        public String ProductSku{get;set;}
        public Integer Quantity {get;set;}
        public String SalesforceProductId {get;set;}
    }


    /*************************************************************************************
    * Internal Data Classes and Data Calls With Unit Test Injection
    **************************************************************************************/



    /**
     * @description This is to wrap the rstk__sylocid__c sObject so that it has an easy layout and Unit test are easy to create
     **/
    public class RawLocationId{
        public Id SalesforceId{get;set;}
        public String Name{get;set;}
        public String LocationId{get;set;}
        public Id SiteId{get;set;}
        public Id DivisionId{get;set;}
        public Id HomeProject{get;set;}
        public List<RawLocationNumber> LocationNumbers{get;set;}
        public RawLocationId(){
            LocationNumbers = new List<RawLocationNumber>();
        }
        public RawLocationId(rstk__sylocid__c locInfo){
            SalesforceId = locInfo.Id;
            Name = locInfo.Name;
            LocationId = locInfo.rstk__sylocid_locid__c;
            SiteId = locInfo.rstk__sylocid_site__r.Id;
            DivisionId = locInfo.rstk__sylocid_site__r.rstk__sysite_div__r.Id;
            HomeProject = locInfo.rstk__sylocid_site__r.rstk__sysite_div__r.rstk__sydiv_dflthomeproj__c;
            LocationNumbers = new List<RawLocationNumber>();
            for(rstk__sylocnum__c locNumber:locInfo.rstk__sylocnums__r){
                LocationNumbers.add(new RawLocationNumber(locNumber));
            }
        }
    }

    /**
     * @description This is to wrap the rstk__sylocnum__c sObject so that it has an easy layout and Unit test are easy to create
     **/
    public class RawLocationNumber{
        public Id SalesforceId{get;set;}
        public String Name{get;set;}
        public String LocationNumber{get;set;}

        public RawLocationNumber(Id locNumber,String name, String locnum){
            this.SalesforceId = locNumber;
            this.Name = name;
            this.LocationNumber = locnum;
        }
        public RawLocationNumber(rstk__sylocnum__c locNumber){
            SalesforceId = locNumber.Id;
            Name = locNumber.Name;
            LocationNumber = locNumber.rstk__sylocnum_locnum__c;
        }
    }


    @TestVisible
    private List<RawLocationId> UnitTestLocationData{get;set;}

    public List<RawLocationId> getLocationIds(Set<String> locationIds){
        List<RawLocationId> rawLocationIds = new List<RawLocationId>();

        // If Unit test is running use the UnitTestLocationData
        if(Test.isRunningTest() && UnitTestLocationData != null){
            rawLocationIds = UnitTestLocationData;
        } else {
            for (rstk__sylocid__c locId : [
                    SELECT Id, Name, rstk__sylocid_locid__c, (
                            SELECT Id, Name, rstk__sylocnum_locnum__c
                            FROM rstk__sylocnums__r
                    ),
                            rstk__sylocid_site__r.Id, rstk__sylocid_site__r.rstk__sysite_div__r.Id,
                            rstk__sylocid_site__r.rstk__sysite_div__r.rstk__sydiv_dflthomeproj__c
                    FROM rstk__sylocid__c
                    WHERE Id = :locationIds OR Name = :locationIds OR rstk__sylocid_locid__c = :locationIds
            ]) {
                rawLocationIds.add(new RawLocationId(locId));
            }
        }

        return rawLocationIds;
    }

    @TestVisible
    private Map<String,Id> UnitTestSkuData{get;set;}

    @TestVisible
    private Map<String,Id> getSkuToId(Set<String> productSku){
        Map<String,Id> skuToId = new Map<String, Id>();
        if(productSku.isEmpty()){
            return skuToId;
        }

        if(Test.isRunningTest() && UnitTestSkuData != null){
            skuToId = UnitTestSkuData;
        }else{
            // pull Item Mapping
            for (rstk__icitem__c item : [
                    SELECT Id, rstk__icitem_item__c,
                            rstk__icitem_item__r.rstk__index_item__c
                    FROM rstk__icitem__c
                    WHERE rstk__icitem_item__r.rstk__index_item__c = :productSku
            ]) {
                skuToId.put(item.rstk__icitem_item__r.rstk__index_item__c, item.Id);

            }
        }

        return skuToId;
    }


    /*************************************************************************************
    * Private functions
    **************************************************************************************/

    /**
       * @param fromLocation Location where the product will be pulled from
       * @param fromLocationNumber Location number where the product is at
       * @param toLocation Location where the product will be moved to
       * @param toLocationNumber Location number where the product is going to
       * @param product The Id of the product that is going to be moved
       * @param qty The Qty that is going to be moved
       * @param backgroundProcess To run as a background process.
       *
       * @return The sydata object that needs to be inserted to run.
       **/

    public rstk__sydatat__c generateInventoryMove(RawLocationId fromLocation,String fromLocationNumber,
            RawLocationId toLocation,String toLocationNumber,
            Id product,Decimal qty, Boolean backgroundProcess){

        return generateLocalInventoryMove(product,qty,
                fromLocation.HomeProject,fromLocation.DivisionId,fromLocation.SiteId,fromLocation.SalesforceId,fromLocationNumber,
                toLocation.HomeProject,toLocation.DivisionId,toLocation.SiteId,toLocation.SalesforceId,toLocationNumber,
                backgroundProcess);
    }

    public rstk__sydatat__c generateLocalInventoryMove(
            Id product,Decimal qty,
            Id fromProject,Id fromDivision,Id fromSite,Id fromLocationId, String fromLocationNumber,
            Id toProject,Id toDivision,Id toSite,Id toLocationId, String toLocationNumber,
            Boolean backgroundProcess
    ){
        rstk__sydatat__c action = new rstk__sydatat__c();
        action.rstk__sydata_txnid__c = 'INVLOCLOC';
        action.rstk__sydata_txntype__c = 'Inventory Transfer';

        action.rstk__sydata_txnqty__c = qty;
        action.rstk__sydata_backgroundprocessing__c = backgroundProcess;

        action.rstk__sydata_fromdiv__c = fromDivision;
        action.rstk__sydata_fromsite__c = fromSite;
        action.rstk__sydata_fromproj__c = fromProject;

        action.rstk__sydata_fromlocid__c = fromLocationId;
        action.rstk__sydata_fromlocnum__c = fromLocationNumber;

        action.rstk__sydata_todiv__c = toDivision;
        action.rstk__sydata_tosite__c = toSite;
        action.rstk__sydata_toproj__c = toProject;
        action.rstk__sydata_tolocid__c = toLocationId;
        action.rstk__sydata_tolocnum__c = toLocationNumber;

        action.rstk__sydata_icitem__c = product;

        return action;
    }

    /**
        * @param locationIdToNumbers Collection of location id that map to location numbers
        * @param nameToLocationId Maps the name of the location to it's Id
        * @param locIdToLocationId Maps the locId ex(14) with the location Id
        * @param location location to be looking at
        *
        * @return The Id of the location being used
        **/
    @TestVisible
    private static Id getLocationId(Map<Id,List<String>> locationIdToNumbers,
            Map<String,Id> nameToLocationId,
            Map<String,Id> locIdToLocationId,String Location){
        if(Location instanceof Id && locationIdToNumbers.containsKey(Location)){
            return Location;
        } else if (nameToLocationId.containsKey(Location)){
            return nameToLocationId.get(Location);
        } else if(locIdToLocationId.containsKey(Location)){
            return locIdToLocationId.get(Location);
        }
        return null;
    }

    /**
     * @param locationIdToNumbers Collection of location id that map to location numbers
     * @param nameToLocationId Maps the name of the location to it's Id
     * @param locIdToLocationId Maps the locId ex(14) with the location Id
     * @param location location to be looking at
     * @param locationNumber the value to check
     *
     * @return either the passed in value or null
     **/
    @TestVisible
    private static String getLocationNumber(Map<Id,List<String>> locationIdToNumbers,
            Map<String,Id> nameToLocationId,
            Map<String,Id> locIdToLocationId,
            String location,
            String locationNumber){
        if(location instanceof Id &&locationIdToNumbers.containsKey(location)){
            if(locationIdToNumbers.get(location).contains(locationNumber)){
                return locationNumber;
            }
        } else if (nameToLocationId.containsKey(location)){
            if(locationIdToNumbers.get(nameToLocationId.get(location)).contains(locationNumber)){
                return locationNumber;
            }
        } else if(locIdToLocationId.containsKey(location)){
            if(locationIdToNumbers.get(locIdToLocationId.get(location)).contains(locationNumber)){
                return locationNumber;
            }
        }
        return null;
    }


    public class LocationInfo implements Comparable {
        public Id IclocitemId { get; set; }
        public Decimal Qty { get; set; }
        public Decimal OriginalQty { get; set; }

        public String LocationNumber { get; set; }
        public Id LocationId { get; set; }
        public String LocationName { get; set; }

        public String LocationFormulaName{get;set;}
        public Id DivisionId{get;set;}
        public Id SiteId{get;set;}
        public Id ProjectId{get;set;}

        public Id ItemId { get; set; }
        public String Item { get; set; }
        public Boolean AscOrder { get; set; }

        public Decimal SupplyMultiplier{get;set;}
        public Decimal DesiredInventoryOnHand{get;set;}

        public LocationInfo() {
            AscOrder = false;
        }


        /**
         * @param iclocitem Location information to populate the object
         * @param Multiplier The Supply Multiplier value
         * @param desiredInventoryOnHand the Desired qty at primary location
         **/
        public LocationInfo(rstk__iclocitem__c iclocitem, Decimal Multiplier,Decimal desiredInventoryOnHand){
            SetData(iclocitem);
            if(Multiplier == null || Multiplier < 1){
                SupplyMultiplier = 1;
            } else {
                SupplyMultiplier = Multiplier;
            }

            if(desiredInventoryOnHand == null || desiredInventoryOnHand < 0){
                this.DesiredInventoryOnHand = 0;
            } else {
                this.DesiredInventoryOnHand = desiredInventoryOnHand;
            }
        }

        public LocationInfo(rstk__iclocitem__c iclocitem) {
            SetData(iclocitem);

            Decimal rawSupplyMultiplier = iclocitem.rstk__iclocitem_icitem__r.rstk__icitem_supplymultiplier__c;
            if(rawSupplyMultiplier == null || rawSupplyMultiplier < 1){
                SupplyMultiplier = 1;
            } else {
                SupplyMultiplier = rawSupplyMultiplier;
            }
        }

        private void SetData(rstk__iclocitem__c iclocitem){
            IclocitemId = iclocitem.Id;

            Qty = iclocitem.rstk__iclocitem_locqty__c;
            OriginalQty = iclocitem.rstk__iclocitem_locqty__c;

            LocationNumber = iclocitem.rstk__iclocitem_locnum__c;
            LocationId = iclocitem.rstk__iclocitem_locid__r.Id;
            LocationName = iclocitem.rstk__iclocitem_locid__r.rstk__sylocid_locid__c;

            LocationFormulaName = iclocitem.rstk__iclocitem_locid__r.rstk__formula_name__c;
            DivisionId = iclocitem.rstk__iclocitem_locid__r.rstk__sylocid_div__r.Id;
            SiteId = iclocitem.rstk__iclocitem_locid__r.rstk__sylocid_site__r.Id;
            ProjectId = iclocitem.rstk__iclocitem_proj__r.Id;

            ItemId = iclocitem.rstk__iclocitem_icitem__c;
            Item = iclocitem.rstk__iclocitem_icitem__r.rstk__icitem_item__r.rstk__peitem_item__c;
            AscOrder = false;
        }

        /**
         * @description checks this object with another agenst there Qty value
         * @param compareTo object to compair to
         *
         * @return the qty is smaller then the one being passed in returns 1. If the same 0 else -1
         **/
        public Integer compareTo(Object compareTo) {
            LocationInfo compareToEntity = (LocationInfo) compareTo;
            if (AscOrder) {
                return compareToAsc(compareToEntity);
            } else {
                return compareToDesc(compareToEntity);
            }
        }

        private Integer compareToAsc(LocationInfo compareToEntity) {
            if (Qty == compareToEntity.Qty) {
                return 0;
            }
            if (Qty < compareToEntity.Qty) {
                return -1;
            }
            return 1;
        }

        private Integer compareToDesc(LocationInfo compareToEntity) {
            if (Qty == compareToEntity.Qty) {
                return 0;
            }
            if (Qty < compareToEntity.Qty) {
                return 1;
            }
            return -1;
        }
    }
    public class PickLocation{
        public Id LocationId{get;set;}
        public String LocationName{get;set;}
        public String LocationNumber{get;set;}
        public Decimal Qty{get;set;}
        public String LocationFormulaName{get;set;}
        public Id DivisionId{get;set;}
        public Id SiteId{get;set;}
        public Id ProjectId{get;set;}
        public Decimal SupplyMultiplier{get;set;}
        public PickLocation(){}
        public PickLocation(LocationInfo locationInfo){
            this.Qty = locationInfo.Qty;
            this.LocationNumber = locationInfo.LocationNumber;
            this.LocationId = locationInfo.LocationId;
            this.LocationName = locationInfo.LocationName;
            this.LocationFormulaName = locationInfo.LocationFormulaName;
            this.DivisionId = locationInfo.DivisionId;
            this.SiteId = locationInfo.SiteId;
            this.ProjectId = locationInfo.ProjectId;
            this.SupplyMultiplier = locationInfo.SupplyMultiplier;
        }
    }

    @TestVisible
    private Map<String, Map<String, Map<String, LocationInfo>>>  UnitTest_GetProductLocations{get;set;}

    /**
     * @description Used to either Use the test Object or information of the DRP or MRP. The Current Set is for the DRP
     * @param products Collection of location Ids to pull the information
     * @param locationIds The locations that will be used for the lookup
     *
     * @return Returns all of the locations that will be used
     **/
    public Map<String, Map<String, Map<String, LocationInfo>>> getProductLocations(Set<String> products,List<String> locationIds) {
        if (Test.isRunningTest() && UnitTest_GetProductLocations != null) {

            return UnitTest_GetProductLocations;

        }
        return getProductLocationsDRP(products,locationIds);
    }

    @TestVisible
    private Map<String, Map<String, Map<String, LocationInfo>>> createSearchableProductLocation(List<LocationInfo> formattedLocationData){

        // Generate collection
        // Location Id, ProductName, Location Number = Product
        Map<String, Map<String, Map<String, LocationInfo>>> locations = new Map<String, Map<String, Map<String, LocationInfo>>>();

        // Sorts the location infomration
        for (LocationInfo loc : formattedLocationData) {
            if (!locations.containsKey(loc.LocationName)) {
                locations.put(loc.LocationName, new Map<String, Map<String, LocationInfo>>());
            }

            if (!locations.get(loc.LocationName).containsKey(loc.Item)) {
                locations.get(loc.LocationName).put(loc.Item, new Map<String, LocationInfo>());
            }

            if (!locations.get(loc.LocationName).get(loc.Item).containsKey(loc.LocationNumber)) {
                locations.get(loc.LocationName).get(loc.Item).put(loc.LocationNumber, loc);
            }
        }

        return locations;
    }

    @TestVisible
    private Map<String, Map<String, Map<String, LocationInfo>>> getProductLocationsDRP(Set<String> products,List<String> locationIds){

        List<LocationInfo> formattedLocationData = new List<LocationInfo>();

        for (rstk__icitem__c icitem : [
                SELECT Id, rstk__icitem_descr__c,
                        rstk__icitem_item__r.rstk__peitem_item__c,
                (
                        SELECT rstk__icreplenish_multiplier__c,
                                rstk__icreplenish_tolocnum__c, rstk__icreplenish_tolocid__c,
                                rstk__icreplenish_tolocid__r.rstk__sylocid_locid__c,
                                rstk__icreplenish_maxqtyoh__c
                        FROM rstk__Replenishment_Location_Master__r
                ),
                (
                        SELECT
                                Id,
                                rstk__iclocitem_locqty__c,
                                rstk__iclocitem_locnum__c,
                                rstk__iclocitem_locid__r.Id,
                                rstk__iclocitem_locid__r.rstk__sylocid_locid__c,
                                rstk__iclocitem_locid__r.rstk__formula_name__c,
                                rstk__iclocitem_locid__r.rstk__sylocid_div__r.Id,
                                rstk__iclocitem_locid__r.rstk__sylocid_site__r.Id,
                                rstk__iclocitem_proj__r.Id,
                                rstk__iclocitem_icitem__r.rstk__icitem_descr__c,
                                rstk__iclocitem_icitem__c,
                                rstk__iclocitem_icitem__r.rstk__icitem_item__r.rstk__peitem_item__c
                        FROM rstk__ICLOCITEMs__r
                        WHERE  rstk__iclocitem_locid__r.rstk__sylocid_locid__c IN :locationIds AND
                        rstk__iclocitem_locqty__c > 0
                        ORDER BY rstk__iclocitem_locqty__c ASC
                ),
                        rstk__icitem_wmslocnum__c, rstk__icitem_wmslocid__c
                FROM rstk__icitem__c
                WHERE rstk__icitem_item__r.rstk__peitem_item__c IN :products
        ]) {
            Decimal supplyMultiplier = null;
            Decimal desiredInventoryOnHand = null;
            for(rstk__icreplenish__c dRPvalue: icitem.rstk__Replenishment_Location_Master__r){
                if(icitem.rstk__icitem_wmslocid__c == dRPvalue.rstk__icreplenish_tolocid__c &&
                        icitem.rstk__icitem_wmslocnum__c == dRPvalue.rstk__icreplenish_tolocnum__c){
                        supplyMultiplier = dRPvalue.rstk__icreplenish_multiplier__c;
                        desiredInventoryOnHand = dRPvalue.rstk__icreplenish_maxqtyoh__c;
                    break;
                }
            }
            for(rstk__iclocitem__c iclocitem:icitem.rstk__ICLOCITEMs__r){

                formattedLocationData.add(new LocationInfo(iclocitem,supplyMultiplier,desiredInventoryOnHand));
            }
        }

        // Generate collection
        // Location Id, ProductName, Location Number = Product
        Map<String, Map<String, Map<String, LocationInfo>>> locations = createSearchableProductLocation(formattedLocationData);


        System.debug(LoggingLevel.FINE,'Called getProductLocations:');
        System.debug(LoggingLevel.FINE,'Input:');
        System.debug(LoggingLevel.FINE,'Products: ');
        System.debug(LoggingLevel.FINE,JSON.serialize(products));
        System.debug(LoggingLevel.FINE,'location Ids: ');
        System.debug(LoggingLevel.FINE,JSON.serialize(locationIds));
        System.debug(LoggingLevel.FINE,'Output:');
        System.debug(LoggingLevel.FINE,JSON.serialize(locations));
        return locations;
    }



    public List<PickLocation> getPickLocations(String item,
            Decimal qty,
            Map<String, Map<String, Map<String, LocationInfo>>> location, List<String> locationOrder,
            Boolean allowMultipleLocationNumbers,
            Boolean allowMultipleLocationIds,
            Boolean applySupplyMultiplier){
        List<PickLocation> returnObject;
        returnObject = subGetPickLocations(item,qty,location,locationOrder,false,false,applySupplyMultiplier);
        if(returnObject.size() > 0 || allowMultipleLocationNumbers == false){
            return returnObject;
        }

        returnObject = subGetPickLocations(item,qty,location,locationOrder,true,false,applySupplyMultiplier);
        if(returnObject.size() > 0 || allowMultipleLocationIds == false){
            return returnObject;
        }

        return subGetPickLocations(item,qty,location,locationOrder,true,true,applySupplyMultiplier);
    }

    private static Decimal calculateSupplyMultiplier(LocationInfo loc,Decimal qty,Boolean applySupplyMultiplier ){
        if(loc.SupplyMultiplier > 1 && applySupplyMultiplier){
            Decimal newQty = loc.SupplyMultiplier*(qty/loc.SupplyMultiplier).round(RoundingMode.CEILING);
            if(loc.Qty < newQty){
                return loc.Qty;
            } else {
                return newQty;
            }
        } else {
            return qty;
        }
    }

    private List<PickLocation> subGetPickLocations(String item,
            Decimal qty,
            Map<String, Map<String, Map<String, LocationInfo>>> location, List<String> locationOrder,
            Boolean allowMultipleLocationNumbers,
            Boolean allowMultipleLocationIds,
            Boolean applySupplyMultiplier){

        List<PickLocation> returnList = new List<PickLocation>();
        System.debug(LoggingLevel.FINE,locationOrder);
        Map<String,List<LocationInfo>> pickLocationClone = new Map<String, List<LocationInfo>>();

        System.debug(LoggingLevel.FINE,pickLocationClone);

        // Generates location List
        for(String locId: locationOrder) {
            if(location.containsKey(locId)){
                if(location.get(locId).containsKey(item)){
                    if(!pickLocationClone.containsKey(locId)){
                        pickLocationClone.put(locId,new List<LocationInfo>());
                    }
                    for(LocationInfo locInfo :location.get(locId).get(item).values()){
                        pickLocationClone.get(locId).add(locInfo);
                        locInfo.AscOrder = !allowMultipleLocationNumbers;
                    }
                    pickLocationClone.get(locId).sort();
                }
            }
        }

        System.debug(LoggingLevel.FINE,locationOrder);
        Decimal workingQty = qty;
        // Generates location List
        for(String locId: locationOrder) {
            if (pickLocationClone.containsKey(locId)) {
                for(LocationInfo loc: pickLocationClone.get(locId)){
                    System.debug(LoggingLevel.FINE,'LocId: ' + loc.LocationName+ ' LocNum: ' + loc.LocationNumber+ ' Qty: ' + loc.Qty);

                    if(allowMultipleLocationNumbers){
                        if(loc.Qty >= workingQty){
                            PickLocation newLocation = new PickLocation(loc);

                            newLocation.Qty = calculateSupplyMultiplier(loc,workingQty,applySupplyMultiplier);

                            returnList.add(newLocation);
                            return returnList;
                        } else {
                            PickLocation newLocation = new PickLocation(loc);
                            newLocation.Qty = loc.Qty;
                            returnList.add(newLocation);
                            // reduce the qty needed
                            workingQty = workingQty - loc.Qty;
                        }
                    } else {
                        // this will occur when you are not allowing multiple location numbers
                        if(loc.Qty >= qty){
                            PickLocation newLocation = new PickLocation(loc);

                            newLocation.Qty = calculateSupplyMultiplier(loc,qty,applySupplyMultiplier);


                            returnList.add(newLocation);
                            return returnList;
                        }
                    }
                }

                // If we are not allowing to go across multiple sites for pulling an Item the
                // return collection needs to be cleared and check Qty needs be to reset
                if(!allowMultipleLocationIds){
                    returnList.clear();
                    workingQty = qty;
                }
            }
        }
        return returnList;

    }



    /*************************************************************************************
    * Public functions
    **************************************************************************************/


    /**
     * @description Collection of all location moves that will be inserted from moveItems
     **/
    @TestVisible
    private List<rstk__sydatat__c> itemMoves = new List<rstk__sydatat__c>();

    /**
     * @param moveEvents passed in events/actions to be executed
     * @param isBackground for running as a background operation or not. This is true by default
     *
     * @return collection of all sydatat object Ids associated with the moves
     **/
    public List<Id> moveItems(List<InventoryMoveRequest> moveEvents,Boolean isBackground){
        if(isBackground==null){
            isBackground = true;
        }

        Set<String> locationIds = new Set<String>();

        Set<String> productSku = new Set<String>();
        Set<String> productIds = new Set<String>();

        // Generate List of all locations
        for(InventoryMoveRequest moveRequest:moveEvents){
            locationIds.add(moveRequest.FromLocation.LocationId);
            locationIds.add(moveRequest.ToLocation.LocationId);

            // If specified do not add the product sku
            if(moveRequest.ProductSku != null && moveRequest.SalesforceProductId == null){
                productSku.add(moveRequest.ProductSku);
            }
            if(moveRequest.SalesforceProductId != null){
                productIds.add(moveRequest.SalesforceProductId);
            }
        }

        Map<Id,List<String>> locationIdToNumbers = new Map<Id, List<String>>();
        Map<Id,RawLocationId> locationIdToLocData = new Map<Id, RawLocationId>();
        Map<String,Id> nameToLocationId = new Map<String, Id>();
        Map<String,Id> locIdToLocationId = new Map<String, Id>();

        List<RawLocationId> rawLocationIds = getLocationIds(locationIds);


        // Pull all locations and populate mappings
        for(RawLocationId locId:rawLocationIds){


            List<String> locationNumbers = new List<String>();
            for(RawLocationNumber locNumber: locId.LocationNumbers){
                locationNumbers.add(locNumber.Name);
                locationNumbers.add(locNumber.LocationNumber);
            }

            locationIdToLocData.put(locId.SalesforceId,locId);
            locationIdToNumbers.put(locId.SalesforceId,locationNumbers);
            nameToLocationId.put(locId.Name,locId.SalesforceId);
            locIdToLocationId.put(locId.LocationId,locId.SalesforceId);
        }


        Map<String,Id> skuToId = getSkuToId(productSku);

        // Loop thru all move events and add them into SYDATAT
        for(InventoryMoveRequest moveRequest:moveEvents){

            Id fromLocationId = getLocationId(
                    locationIdToNumbers,
                    nameToLocationId,
                    locIdToLocationId,
                    moveRequest.FromLocation.LocationId);

            String fromLocationNumber= getLocationNumber(locationIdToNumbers,
                    nameToLocationId,
                    locIdToLocationId,
                    moveRequest.FromLocation.LocationId,
                    moveRequest.FromLocation.LocationNumber);

            Id toLocationId = getLocationId(locationIdToNumbers,
                    nameToLocationId,
                    locIdToLocationId,
                    moveRequest.ToLocation.LocationId);

            String toLocationNumber= getLocationNumber(locationIdToNumbers,
                    nameToLocationId,
                    locIdToLocationId,
                    moveRequest.ToLocation.LocationId,
                    moveRequest.ToLocation.LocationNumber);

            if(fromLocationNumber != null && fromLocationId != null &&
                    toLocationId != null && toLocationNumber != null) {
                Id productId;
                if (moveRequest.SalesforceProductId == null) {
                    productId = skuToId.get(moveRequest.ProductSku);
                } else {
                    productId = moveRequest.SalesforceProductId;
                }

                rstk__sydatat__c action = generateInventoryMove(locationIdToLocData.get(fromLocationId), fromLocationNumber,
                        locationIdToLocData.get(toLocationId), toLocationNumber, productId, moveRequest.Quantity, isBackground);
                itemMoves.add(action);
            }

        }

        if(itemMoves.isEmpty()){
            return new List<Id>();
        }

        // If this is running at a Unit test do not try to insert Expected Error if executed due to lack of data
        if(!Test.isRunningTest()) {
            insert itemMoves;
        }

        List<Id> syDataIds =  new List<Id>();

        // If this is running as a Unit test this will be a collection of nulls generated
        for(rstk__sydatat__c sydata:itemMoves){
            syDataIds.add(sydata.Id);
        }

        return syDataIds;
    }



    /*************************************************************************************
    * Invoice Moves
    **************************************************************************************/


    /**
     * @description Location Ids for picking
     **/
    @TestVisible
    private List<String> pickOrderLocationIds = null;

    /**
     * @description Test object to override the return of the GetOrderItems
     **/
    @TestVisible
    private List<rawOrderItem> UnitTest_GetOrderItems = null;

    /**
     * @description Pulls the collection of all pick order locations from the configuration sObject
     * @return Collection of location Ids in Order of preference
     **/
    @TestVisible
    private List<String> getPickOrderLocationIds(){
        if(pickOrderLocationIds != null ){
            return pickOrderLocationIds;
        }

        FMG_Configuration__c[] locationIds = [
                SELECT
                        Id,
                        Setting__c,
                        Value__c,
                        Application__c
                FROM FMG_Configuration__c
                WHERE Application__c = 'FMGRSAPI - InventoryAccess' AND
                Setting__c = 'Create Inventory Move Source Location Ids' LIMIT 1];
        if(locationIds.isEmpty()){
            pickOrderLocationIds = new List<String>{'26','25','P1'};
        } else {
            pickOrderLocationIds = locationIds[0].Value__c.split(',');
        }

        return pickOrderLocationIds;
    }

    /**
     * @description Pulls all items from the passed in order Ids. These are merged together by the item
     * @param orderIds Order Ids to get the Items needed
     *
     * @return Collection of raw items that where pulled
     **/
    public List<rawOrderItem> getOrderItems(List<Id> orderIds) {
        List<rawOrderItem> rawData = new List<rawOrderItem>();

        List<Id> inventoryItemMasterOrderSelect = new List<Id>();
        for (AggregateResult solines : [
                SELECT rstk__soline_icitem__r.rstk__icitem_item__r.Id inventoryItemMasterId
                from rstk__soline__c
                WHERE rstk__soline_sohdr__r.Id = :orderIds
                GROUP BY rstk__soline_icitem__r.rstk__icitem_item__r.Id
        ]) {
            if (solines.get('inventoryItemMasterId') != null) {
                inventoryItemMasterOrderSelect.add(String.valueOf(solines.get('inventoryItemMasterId')));
            }
        }
        system.debug('Items info pulled from orders');
        system.debug(LoggingLevel.FINE,JSON.serializePretty(inventoryItemMasterOrderSelect));




        List<Id> WorkingOrders = new List<Id>();
        FOR(fmgsohdrext__c orderInfo: [SELECT fmgsohdrext_sohdr__c
        FROM fmgsohdrext__c
        WHERE Inventory_Transferred__c = TRUE
        AND fmgsohdrext_sohdr__r.rstk__sohdr_closed__c = FALSE]){
            WorkingOrders.add(orderInfo.fmgsohdrext_sohdr__c);
        }

        WorkingOrders.addAll(orderIds);

        system.debug('orders to calculate');
        system.debug(LoggingLevel.FINE,JSON.serializePretty(WorkingOrders));


        // rstk__soline_status__c Number Info
        // 1- Planned
        // 2- Firmed
        // 3- Partial Allocated
        // 4- Allocated
        // 5- Partial Issued
        // 6- Issued
        // 7- Partial Packaged
        // 8- Packaged
        // 9- Partial Ship
        // 10- Shipped
        for (AggregateResult rawPickListElement : [
                SELECT
                        rstk__soline_icitem__r.Id,
                        MIN(rstk__soline_icitem__r.rstk__icitem_item__r.rstk__peitem_item__c) ItemNumber,
                        SUM(rstk__soline_avtoallocpick__c) QtyAvailAllocandPick,
                        MIN(rstk__soline_icitem__r.rstk__icitem_wmslocnum__c) WMSLocationNumber,
                        MIN(rstk__soline_icitem__r.rstk__icitem_wmslocid__r.Id) WMSLocationID,
                        MIN(rstk__soline_icitem__r.rstk__icitem_wmslocid__r.rstk__sylocid_locid__c) InventoryLocationName,
                        MIN(rstk__soline_icitem__r.rstk__icitem_wmslocid__r.rstk__formula_name__c) InventoryLocationNameFormula,
                        MIN(rstk__soline_icitem__r.rstk__icitem_wmslocid__r.rstk__sylocid_site__r.Id) SiteId,
                        MIN(rstk__soline_icitem__r.rstk__icitem_wmslocid__r.rstk__sylocid_div__c) DivisionId,
                        MIN(rstk__soline_project__c) ProjectId,
                        MIN(rstk__soline_icitem__r.rstk__icitem_supplymultiplier__c) SupplyMultiplier
                FROM rstk__soline__c
                WHERE rstk__soline_status__c IN (2, 3, 4, 5)
                AND rstk__soline_sohdr__c = :WorkingOrders
                AND rstk__soline_icitem__r.rstk__icitem_item__r.Id = :inventoryItemMasterOrderSelect
                AND rstk__soline_cancelled__c = FALSE
                AND rstk__soline_prod__r.rstk__soprod_prodtype__c = 'Stock'
                GROUP BY rstk__soline_icitem__r.Id
        ]) {
            rawData.add(new rawOrderItem(rawPickListElement));
        }

        if (Test.isRunningTest() && UnitTest_GetOrderItems != null) {
            rawData = UnitTest_GetOrderItems;
        }

        system.debug('Inventory Required');
        system.debug(LoggingLevel.FINE,JSON.serializePretty(rawData));

        return rawData;
    }

    /**
     * @description Raw Object of the Order Item. This is for easy testing and cleaner JSON Objects
     **/
    public class rawOrderItem{
        public String Item{get;set;}
        public Decimal Qty{get;set;}
        public Id ItemId{get;set;}
        public String LocationNumber{get;set;}
        public Id LocationId{get;set;}
        public String LocationName{get;set;}
        public String LocationFormulaName{get;set;}
        public Id DivisionId{get;set;}
        public Id SiteId{get;set;}
        public Id ProjectId{get;set;}
        public Double SupplyMultiplier{get;set;}

        public rawOrderItem(){}

        /**
         * @description Creates the object by the passed in Raw data that is will be mapped.
         * @param rawData The information that is going to be mapped
         **/
        public rawOrderItem(AggregateResult rawData){
            ItemId=String.valueOf(rawData.get('Id'));
            Item = String.valueOf(rawData.get('ItemNumber'));
            Qty = Decimal.valueOf(String.valueOf(rawData.get('QtyAvailAllocandPick')));
            LocationNumber = String.valueOf(rawData.get('WMSLocationNumber'));
            LocationId = String.valueOf(rawData.get('WMSLocationID'));
            LocationName = String.valueOf(rawData.get('InventoryLocationName'));
            LocationFormulaName = String.valueOf(rawData.get('InventoryLocationNameFormula'));
            SiteId = String.valueOf(rawData.get('SiteId'));
            DivisionId = String.valueOf(rawData.get('DivisionId'));
            ProjectId = String.valueOf(rawData.get('ProjectId'));

            // Checks to see if there is a multiplier if there is none specified or the value is less then one then use 1
            if(rawData.get('SupplyMultiplier') == null){
                SupplyMultiplier = 1;
            } else {
                SupplyMultiplier = Decimal.valueOf(String.valueOf(rawData.get('SupplyMultiplier')));
                if(SupplyMultiplier < 1){
                    SupplyMultiplier = 1;
                }
            }

            // Checks to see if all of the needed location information is available else throws an exception
            if(LocationId == null || LocationNumber == null || LocationNumber==''){
                MissingWMSException error = new MissingWMSException();
                error.Message = 'Missing WMS Location Data unable to complete';
                error.LocationId = this.LocationId;
                error.LocationNumber = this.LocationNumber;
                error.Item = this.Item;
                error.ItemId = this.ItemId;
                error.Url = Url.getSalesforceBaseUrl().toExternalForm() + '/' + this.ItemId;
                throw error;
            }

        }
    }

    /**
     * @description Exception object that contains information on the items that has missing information
     **/
    public class MissingWMSException extends Exception{
        public String Message{get;set;}
        public Id ItemId{get;set;}
        public String Item{get;set;}
        public String LocationNumber{get;set;}
        public Id LocationId{get;set;}
        public String Url{get;set;}

        /**
         * @description Generates a custom formatted json object string
         * @return Json object with the error information
         **/
        public String GetJson(){
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartObject();
            gen.writeStringField('Error Message',Message);
            gen.writeIdField('ItemId',ItemId);
            gen.writeStringField('ItemName',Item);
            if(LocationNumber != null){
                gen.writeStringField('LocationNumber',LocationNumber);
            } else {
                gen.writeNullField('LocationNumber');
            }
            if(LocationId != null){
                gen.writeIdField('LocationId',LocationId);
            } else {
                gen.writeNullField('LocationId');
            }
            gen.writeStringField('ItemUrl',Url);
            gen.writeStringField('StackTraceString',this.getStackTraceString());
            gen.writeStringField('TypeName',this.getTypeName());
            gen.writeEndObject();

            return gen.getAsString();
        }
    }

    /**
     * @description Output Collection
     **/
    @TestVisible
    private List<fmginvmove__c> CreateInventoryMoves_FMGInventoryMoves = new List<fmginvmove__c>();

    /**
    * @description Output Collection
    **/
    @TestVisible
    private List<rstk__sydatat__c> CreateInventoryMoves_RootstockInventoryMoves = new List<rstk__sydatat__c>();


    /**
     * @description Items that will need to be fulfilled at the main location
     **/
    @TestVisible
    private List<rawOrderItem> UnitTest_CreateInventoryMoves_OrderItems{get;set;}

    /**
     * @description Location Name > Item -> Location Number -> Locations(s)
     **/
    @TestVisible
    private  Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>> UnitTest_CreateInventoryMoves_PossibleDestinationInfo{get;set;}

    /**
     * @description Location Name > Item -> Location Number -> Locations(s)
     **/
    @TestVisible
    private  Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>> UnitTest_CreateInventoryMoves_ActivePullLocations{get;set;}

    /**
     * @description Generates the move request for the passed in orders.
     * @param orderIds Id's to be checked and if needed moves created
     *
     * @return List of all sydatat for moving information
     **/
    public List<Id> createInventoryMoves(List<Id> orderIds){
        List<Id> sydatatIds = new List<Id>();
        List<rawOrderItem> orderItems = new List<rawOrderItem>();
        List<rawOrderItem> rawOrderItems;

        // Gets the raw items that will need to be check and moves created
        if(Test.isRunningTest() && UnitTest_CreateInventoryMoves_OrderItems != null){
            rawOrderItems = UnitTest_CreateInventoryMoves_OrderItems;
        }
        else{
            rawOrderItems = getOrderItems(orderIds);
        }

        System.debug(LoggingLevel.FINE,'*********************************** rawOrderItems ******************************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(rawOrderItems));

        // Remove Items that have no inventory changes
        for(rawOrderItem item: rawOrderItems){
            if(item.Qty>0){
                orderItems.add(item);
            }
        }

        System.debug(LoggingLevel.FINE,'*********************************** orderItems ******************************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(orderItems));


        // If no records with values exit
        if(orderItems.isEmpty()){
            return new List<Id>();
        }
        Map<String,rawOrderItem> products = new Map<String,rawOrderItem>();
        Set<String> locationIds = new Set<String>();



        for(rawOrderItem item: orderItems){
            products.put(item.Item,item);
            locationIds.add(item.LocationName);
        }

        Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>> possibleDestinationInfo;

        // Gets the product location information that will be used to generate the moves
        if(Test.isRunningTest() && UnitTest_CreateInventoryMoves_PossibleDestinationInfo != null){
            possibleDestinationInfo = UnitTest_CreateInventoryMoves_PossibleDestinationInfo;
        }
        else{
            possibleDestinationInfo = getProductLocations(products.keySet(),new List<String>(locationIds));
        }
        System.debug(LoggingLevel.FINE,'*********************************** possibleDestinationInfo ******************************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(possibleDestinationInfo));

        // Build collection for Desired Qtys
        Map<String,Decimal> desiredPrimaryLocationQty = new Map<String, Decimal>();
        for(String locationId :possibleDestinationInfo.keySet()){
            Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>> locationInfoMapMap = possibleDestinationInfo.get(locationId);
            for(String itemId:locationInfoMapMap.keySet()){
                if(!desiredPrimaryLocationQty.containsKey(itemId)){
                    for(FMGRSAPI_Inventory_Service.LocationInfo locationInfo: locationInfoMapMap.get(itemId).values()){
                        if(locationInfo.DesiredInventoryOnHand != null) {
                            desiredPrimaryLocationQty.put(itemId, locationInfo.DesiredInventoryOnHand);
                            break;
                        }

                    }
                }
            }
        }


        List<rawOrderItem> missingPrimaryLocationInventory = new List<rawOrderItem>();
        Set<String> missingPrimaryItems = new Set<String>();

        // Loops thru all of the order items and creates the end sizes that will need to be moved
        for(rawOrderItem item: orderItems){
            if(possibleDestinationInfo.containsKey(item.LocationName)){
                if(possibleDestinationInfo.get(item.LocationName).containsKey(item.Item)){
                    if(possibleDestinationInfo.get(item.LocationName).get(item.Item).containsKey(item.LocationNumber)){
                        // Primary location for the Item
                        FMGRSAPI_Inventory_Service.LocationInfo locationInfo = possibleDestinationInfo.get(item.LocationName).get(item.Item).get(item.LocationNumber);

                        // Calculates what is needed to be moved
                        if(item.Qty > locationInfo.Qty){
                            item.Qty = (item.Qty -locationInfo.Qty);
                            if(desiredPrimaryLocationQty.containsKey(item.Item)){
                                item.Qty = item.Qty + desiredPrimaryLocationQty.get(item.Item);
                            }
                            missingPrimaryLocationInventory.add(item);
                            missingPrimaryItems.add(item.Item);
                        } else {
                            item.Qty = 0;
                        }
                    } else {
                        if(desiredPrimaryLocationQty.containsKey(item.Item)){
                            item.Qty = item.Qty + desiredPrimaryLocationQty.get(item.Item);
                        }
                        missingPrimaryLocationInventory.add(item);
                        missingPrimaryItems.add(item.Item);
                    }
                } else {
                    if(desiredPrimaryLocationQty.containsKey(item.Item)){
                        item.Qty = item.Qty + desiredPrimaryLocationQty.get(item.Item);
                    }
                    missingPrimaryLocationInventory.add(item);
                    missingPrimaryItems.add(item.Item);
                }
            } else {
                if(desiredPrimaryLocationQty.containsKey(item.Item)){
                    item.Qty = item.Qty + desiredPrimaryLocationQty.get(item.Item);
                }
                missingPrimaryLocationInventory.add(item);
                missingPrimaryItems.add(item.Item);
            }
        }

        Map<String, Map<String, Map<String, LocationInfo>>> ActivePullLocations;

        //
        if(Test.isRunningTest() && UnitTest_CreateInventoryMoves_ActivePullLocations != null){
            ActivePullLocations = UnitTest_CreateInventoryMoves_ActivePullLocations;
        }
        else{
            ActivePullLocations = getProductLocations(missingPrimaryItems,getPickOrderLocationIds());
        }

        System.debug(LoggingLevel.FINE, '*********************************** missingPrimaryLocationInventory ******************************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(missingPrimaryLocationInventory));

        System.debug(LoggingLevel.FINE,'*********************************** ActivePullLocations ******************************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(ActivePullLocations));

        List<PickLocation> foundPicks;
        Map<String,List<PickLocation>> pickList = new Map<String, List<PickLocation>>();

        // Builds the collection locations that need to be picked
        for(rawOrderItem item:missingPrimaryLocationInventory){

            foundPicks = getPickLocations(item.Item,item.Qty,ActivePullLocations,getPickOrderLocationIds(),false,false,true);
            if(foundPicks.isEmpty()){
                foundPicks = getPickLocations(item.Item,item.Qty,ActivePullLocations,getPickOrderLocationIds(),true,false,true);
                if(foundPicks.isEmpty()){
                    foundPicks = getPickLocations(item.Item,item.Qty,ActivePullLocations,getPickOrderLocationIds(),true,true,true);
                }
            }


            // If no location was found then place an empty collection
            if(!foundPicks.isEmpty()){

                if(!pickList.containsKey(item.Item)){
                    pickList.put(item.Item,new List<PickLocation>());
                }
                pickList.get(item.Item).addAll(foundPicks);
            }
        }

        System.debug(LoggingLevel.FINE,'*********************************** pickList ******************************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(pickList));

        // Builds the collection that wil be used for moving items to a new location
        for(String item:pickList.keySet()){
            rawOrderItem dest = products.get(item);
            for(PickLocation sourceLocation:pickList.get(item)){
                CreateInventoryMoves_RootstockInventoryMoves.add(generateLocalInventoryMove(
                        dest.ItemId,
                        sourceLocation.Qty,
                        sourceLocation.ProjectId,
                        sourceLocation.DivisionId,
                        sourceLocation.SiteId,
                        sourceLocation.LocationId,
                        sourceLocation.LocationNumber,
                        dest.ProjectId,
                        dest.DivisionId,
                        dest.SiteId,
                        dest.LocationId,
                        dest.LocationNumber,
                        true
                ));
            }
        }


        // Check to see if there are any moves if there are none then there are no insert statement required
        if(!CreateInventoryMoves_RootstockInventoryMoves.isEmpty()){
            // If this is a test then the insert is not needed
            if(!Test.isRunningTest()){
                insert CreateInventoryMoves_RootstockInventoryMoves;
            }
            // Generates the Move information that will be places in the fmginvmove collection
            for(rstk__sydatat__c moves:CreateInventoryMoves_RootstockInventoryMoves){
                sydatatIds.add(moves.Id);
                fmginvmove__c fmginvmove = new fmginvmove__c();
                fmginvmove.fromsylocid__c=moves.rstk__sydata_fromlocid__c;
                fmginvmove.fromlocnum__c=moves.rstk__sydata_fromlocnum__c;
                fmginvmove.fmginvmove_icitem__c = moves.rstk__sydata_icitem__c;
                fmginvmove.status__c = 'Pending';
                fmginvmove.fmginvmove_sydatat__c = moves.Id;
                fmginvmove.tosylocid__c=moves.rstk__sydata_tolocid__c;
                fmginvmove.tolocnum__c=moves.rstk__sydata_tolocnum__c;
                fmginvmove.qty__c = moves.rstk__sydata_txnqty__c;
                CreateInventoryMoves_FMGInventoryMoves.add(fmginvmove);
            }
            // If this is a test then the insert is not needed
            if(!Test.isRunningTest()){
                insert CreateInventoryMoves_FMGInventoryMoves;
            }
        }

        List<fmgsohdrext__c> setInventoryTransferIndicator = [SELECT Id, Inventory_Transferred__c FROM fmgsohdrext__c WHERE fmgsohdrext_sohdr__c = :orderIds];
        for(fmgsohdrext__c headerUpdate: setInventoryTransferIndicator){
            headerUpdate.Inventory_Transferred__c = true;
        }
        update setInventoryTransferIndicator;

        return sydatatIds;
    }





}