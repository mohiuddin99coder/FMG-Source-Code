/**
 * Created by inscorea on 8/22/2023.
 */

public with sharing class FMG_Inventory_Service implements FMG_Inventory_IService,FMG_Inventory_IServiceData {

    public List<rstk__sydatat__c> generateTransfers(List<FMG_Inventory_Classes.InventoryTransferInput> items) {
        List<String> pulllocation = getPickOrderLocationIds();
        return generateTransfers(items,pulllocation);
    }

    public List<rstk__sydatat__c> generateTransfers(List<FMG_Inventory_Classes.InventoryTransferInput> items, List<String> locationNames) {

        Set<Id> ItemIds = new Set<Id>();
        for(FMG_Inventory_Classes.InventoryTransferInput item: items){
            ItemIds.add(item.Item);
        }
        List<FMG_Inventory_Classes.InventoryTransferLocationInfo> productLocation = getProductLocations(ItemIds,locationNames);

        return generateTransfers(items,locationNames,productLocation);
    }

    public List<rstk__sydatat__c> generateTransfers(List<FMG_Inventory_Classes.InventoryTransferInput> items,List<String> locationNames,List<FMG_Inventory_Classes.InventoryTransferLocationInfo> locationData ) {

        if(items == null || items.isEmpty()){
            System.debug(System.LoggingLevel.WARN,'FMG_Inventory_Service.GenerateTransfers had no Items passed in');
            return new List<rstk__sydatat__c>();
        } else {
            System.debug(LoggingLevel.FINE,'Items Data: ');
            System.debug(LoggingLevel.FINE,JSON.serialize(items));
        }

        if(locationNames == null || locationNames.isEmpty()){
            System.debug(System.LoggingLevel.WARN,'FMG_Inventory_Service.GenerateTransfers had no locations passed in');
            return new List<rstk__sydatat__c>();
        } else {
            System.debug(LoggingLevel.FINE,'Location Name: ');
            System.debug(LoggingLevel.FINE,JSON.serialize(locationNames));
        }

        if(locationData == null || locationData.isEmpty()){
            System.debug(System.LoggingLevel.WARN,'FMG_Inventory_Service.GenerateTransfers had no location data passed in');
            return new List<rstk__sydatat__c>();
        } else {
            System.debug(LoggingLevel.FINE,'Location Data: ');
            System.debug(LoggingLevel.FINE,JSON.serialize(locationData));
        }


        List<InventoryTransferLocationInfo> formattedLocationData = new List<FMG_Inventory_Service.InventoryTransferLocationInfo>();

        for(FMG_Inventory_Classes.InventoryTransferLocationInfo inventoryTransferLocationInfo: locationData){
            formattedLocationData.add(new InventoryTransferLocationInfo(inventoryTransferLocationInfo));
        }

        Map<Id, Map<String, List<InventoryTransferLocationInfo>>> searchableItemLocationInfo =  createSearchableProductLocation(formattedLocationData);
        System.debug(LoggingLevel.FINE,'searchable Item Location Info Data: ');
        System.debug(LoggingLevel.FINE,JSON.serialize(searchableItemLocationInfo));
        return generateTransfers(items,locationNames,searchableItemLocationInfo);
    }

    @TestVisible
    private List<rstk__sydatat__c> generateTransfers(List<FMG_Inventory_Classes.InventoryTransferInput> items, List<String> locationNames, Map<Id, Map<String, List<InventoryTransferLocationInfo>>> locationData) {

        List<rstk__sydatat__c> returnTransactions = new List<rstk__sydatat__c>();
        System.debug('Attempting Single Location');

        for(FMG_Inventory_Classes.InventoryTransferInput item: items){


            List<TransferData> transactions = locationPulls(item.Item,item.Qty,locationData,locationNames);
            for(TransferData transferInfo: transactions){
                returnTransactions.add(generateLocalInventoryMove(item,transferInfo,true));
            }

        }

        return returnTransactions;
    }

    @TestVisible
    private rstk__sydatat__c generateLocalInventoryMove(
            FMG_Inventory_Classes.InventoryTransferInput toLocation,
            TransferData fromLocation,
            Boolean backgroundProcess
    ) {
        rstk__sydatat__c action = new rstk__sydatat__c();
        action.rstk__sydata_txnid__c = 'INVLOCLOC';
        action.rstk__sydata_txntype__c = 'Inventory Transfer';


        action.rstk__sydata_txnqty__c = fromLocation.Qty;
        action.rstk__sydata_backgroundprocessing__c = backgroundProcess;

        action.rstk__sydata_fromdiv__c = fromLocation.Division;
        action.rstk__sydata_fromsite__c = fromLocation.Site;
        action.rstk__sydata_fromproj__c = fromLocation.Project;
        action.rstk__sydata_fromlocid__c = fromLocation.LocId;
        action.rstk__sydata_fromlocnum__c = fromLocation.LocNum;

        action.rstk__sydata_todiv__c = toLocation.Div;
        action.rstk__sydata_tosite__c = toLocation.Site;
        action.rstk__sydata_toproj__c = toLocation.Project;
        action.rstk__sydata_tolocid__c = toLocation.LocId;
        action.rstk__sydata_tolocnum__c = toLocation.LocNo;

        action.rstk__sydata_icitem__c = toLocation.Item;

        return action;
    }


    @TestVisible
    private List<TransferData> locationPulls(Id item, Decimal qty, Map<Id, Map<String, List<InventoryTransferLocationInfo>>> products, List<String> locations) {

        List<TransferData> returnCollection;
        System.debug('Attempting Single Location to pull Item ' + item + ' with a qty of ' + qty );
        System.debug(LoggingLevel.FINE,JSON.serializePretty(products));
        returnCollection = singleLocationPull(item,qty,products,locations);
        if(returnCollection != null &&  returnCollection.size() > 0 ){
            return returnCollection;
        }

        System.debug('Attempting Multiple Location Numbers with in location id to pull Item ' + item + ' with a qty of ' + qty);
        System.debug(LoggingLevel.FINE,JSON.serializePretty(products));
        returnCollection = multipleLocationNumPull(item,qty,products,locations);
        if(returnCollection != null && returnCollection.size() > 0 ){
            return returnCollection;
        }


        System.debug('Attempting to pull anything to pull Item ' + item + ' with a qty of ' + qty);
        System.debug(LoggingLevel.FINE,JSON.serializePretty(products));
        returnCollection = multipleLocationNumAndIdPull(item,qty,products,locations);
        return returnCollection;
    }

    // Pull Objects
    /**
     * @description Location Ids for picking
     **/

    @TestVisible
    private List<String> pickOrderLocationIds = null;

    /**
     * @description Pulls the collection of all pick order locations from the configuration sObject
     * @return Collection of location Ids in Order of preference
     **/

    @TestVisible
    private List<String> getPickOrderLocationIds() {
        if (pickOrderLocationIds != null) {
            return pickOrderLocationIds;
        }

        List<FMG_Configuration__c> locationIds = getPickOrderLocationIdsData();
        if (locationIds.isEmpty()) {
            pickOrderLocationIds = new List<String>{
                    '26', '25'
            };
        } else {
            pickOrderLocationIds = locationIds[0].Value__c.split(',');
        }

        return pickOrderLocationIds;
    }

    @TestVisible
    private List<FMG_Inventory_Classes.InventoryTransferLocationInfo> productLocations_TestData = null;

    @TestVisible
    private List<FMG_Inventory_Classes.InventoryTransferLocationInfo> getProductLocations(Set<Id> products, List<String> locationIds){
        System.debug(LoggingLevel.FINE, 'Called getProductLocations:');
        System.debug(LoggingLevel.FINE, 'Input:');
        System.debug(LoggingLevel.FINE, 'Products: ');
        System.debug(LoggingLevel.FINE, JSON.serialize(products));
        System.debug(LoggingLevel.FINE, 'location Ids: ');
        System.debug(LoggingLevel.FINE, JSON.serialize(locationIds));

        if(System.Test.isRunningTest() && productLocations_TestData != null){
            return productLocations_TestData;
        }

        List<FMG_Inventory_Classes.InventoryTransferLocationInfo> formattedLocationData = new List<FMG_Inventory_Classes.InventoryTransferLocationInfo>();

        List<rstk__icitem__c> icitems = getProductLocationsData(products,locationIds);
        for (rstk__icitem__c icitem : icitems) {
            Decimal supplyMultiplier = null;
            Decimal desiredInventoryOnHand = null;
            for (rstk__icreplenish__c dRPvalue : icitem.rstk__Replenishment_Location_Master__r) {
                if (icitem.rstk__icitem_wmslocid__c == dRPvalue.rstk__icreplenish_tolocid__c &&
                        icitem.rstk__icitem_wmslocnum__c == dRPvalue.rstk__icreplenish_tolocnum__c) {
                    supplyMultiplier = dRPvalue.rstk__icreplenish_multiplier__c;
                    desiredInventoryOnHand = dRPvalue.rstk__icreplenish_maxqtyoh__c;
                    break;
                }
            }
            for (rstk__iclocitem__c iclocitem : icitem.rstk__ICLOCITEMs__r) {

                FMG_Inventory_Classes.InventoryTransferLocationInfo newData = new FMG_Inventory_Classes.InventoryTransferLocationInfo();
                newData.IclocitemId = iclocitem.Id;

                newData.Qty = iclocitem.rstk__iclocitem_locqty__c;

                newData.LocationNumber = iclocitem.rstk__iclocitem_locnum__c;
                newData.LocationId = iclocitem.rstk__iclocitem_locid__r.Id;
                newData.LocationName = iclocitem.rstk__iclocitem_locid__r.rstk__sylocid_locid__c;

                newData.LocationFormulaName = iclocitem.rstk__iclocitem_locid__r.rstk__formula_name__c;
                newData.DivisionId = iclocitem.rstk__iclocitem_locid__r.rstk__sylocid_div__r.Id;
                newData.SiteId = iclocitem.rstk__iclocitem_locid__r.rstk__sylocid_site__r.Id;
                newData.ProjectId = iclocitem.rstk__iclocitem_proj__r.Id;

                newData.ItemId = iclocitem.rstk__iclocitem_icitem__c;
                newData.Item = iclocitem.rstk__iclocitem_icitem__r.rstk__icitem_item__r.rstk__peitem_item__c;

                Decimal rawSupplyMultiplier = iclocitem.rstk__iclocitem_icitem__r.rstk__icitem_supplymultiplier__c;
                if (rawSupplyMultiplier == null || rawSupplyMultiplier < 1) {
                    newData.SupplyMultiplier = 1;
                } else {
                    newData.SupplyMultiplier = rawSupplyMultiplier;
                }

                formattedLocationData.add(newData);
            }
        }

        System.debug(LoggingLevel.FINE, 'Output:');
        System.debug(LoggingLevel.FINE, JSON.serialize(formattedLocationData));
        return formattedLocationData;
    }

    @TestVisible
    private Map<Id, Map<String, List<InventoryTransferLocationInfo>>> createSearchableProductLocation(List<InventoryTransferLocationInfo> formattedLocationData) {
        // Generate collection
        // Location Id, ProductName, Location Number = Product
        Map<Id, Map<String, List<InventoryTransferLocationInfo>>> locations = new Map<Id, Map<String, List<InventoryTransferLocationInfo>>>();

        // Sorts the location infomration
        for (InventoryTransferLocationInfo loc : formattedLocationData) {
            System.debug(LoggingLevel.FINE,'Processing Item: '  +  loc.ItemId);

            if (!locations.containsKey(loc.ItemId)) {
                locations.put(loc.ItemId, new Map<String,List<InventoryTransferLocationInfo>>());
            }
            Map<String,List<InventoryTransferLocationInfo>> locationMap = locations.get(loc.ItemId);


            if (!locationMap.containsKey(loc.LocationName)) {
                locationMap.put(loc.LocationName, new List<InventoryTransferLocationInfo>());
            }

            List<InventoryTransferLocationInfo> ItemMap = locationMap.get(loc.LocationName);

            ItemMap.add(loc);

        }
        return locations;
    }

    @TestVisible
    private List<TransferData> singleLocationPull(Id item, Decimal qty, Map<Id, Map<String, List<InventoryTransferLocationInfo>>> products, List<String> locations) {
        if(!products.containsKey(item)){
            return new List<TransferData>();
        }
        Map<String, List<InventoryTransferLocationInfo>> productLocationData = products.get(item);

        List<TransferData> returnCollection = new List<TransferData>();
        for (String location : locations) {
            if (productLocationData.containsKey(location)) {

                List<InventoryTransferLocationInfo> locationInfo = productLocationData.get(location);
                locationInfo.sort();
                //for (Integer i = 0; i< locationInfo.size(); i-- ){
                for (Integer i = locationInfo.size()-1; i>= 0; i-- ){
                    InventoryTransferLocationInfo loc = locationInfo[i];
                    System.debug(LoggingLevel.FINE,System.JSON.serializePretty(loc));
                    //for (LocationInfo loc : locationInfo) {
                    System.debug(LoggingLevel.FINE,JSON.serializePretty(loc));
                    System.debug('Checking if working Qty of ' + loc.WorkingQty + ' is Greater than or Equal to ' + qty);
                    if (loc.WorkingQty >= qty) {

                        loc.WorkingQty = loc.WorkingQty - qty;
                        loc.Qty = loc.WorkingQty;
                        TransferData transferData = new TransferData();
                        transferData.Qty = qty;
                        transferData.Item = item;
                        transferData.Project = loc.ProjectId;
                        transferData.Site = loc.SiteId;
                        transferData.Division = loc.DivisionId;
                        transferData.LocId = loc.LocationId;
                        transferData.LocIdName = loc.LocationName;
                        transferData.LocNum = loc.LocationNumber;
                        returnCollection.add(transferData);
                        return returnCollection;
                    }

                }

            }
        }
        return returnCollection;
    }

    @TestVisible
    private List<TransferData> multipleLocationNumPull(Id item, Decimal qty, Map<Id, Map<String, List<InventoryTransferLocationInfo>>> products, List<String> locations) {
        if(!products.containsKey(item)){
            return new List<TransferData>();
        }
        Map<String, List<InventoryTransferLocationInfo>> productLocationData = products.get(item);

        // Loop thru the locations to use
        for (String location : locations) {
            System.debug('Looping thru location ' + location);
            // Checks to see if the location is avalable
            if (productLocationData.containsKey(location)) {


                List<InventoryTransferLocationInfo> locationsData = productLocationData.get(location);
                locationsData.sort();
                InventoryTransferLocationInfo lastPick = null;
                List<TransferData> returnCollection = new List<TransferData>();
                Decimal loopQty = qty;
                do {
                    lastPick = null;
                    System.debug('Check Pass ');
                    for (Integer i = locationsData.size() - 1; i >= 0; i--) {

                        InventoryTransferLocationInfo loc = locationsData[i];
                        System.debug('checking ' + loc.ItemId + ' with Qty of ' + loc.WorkingQty);
                        // Checks to see if location can compleate the request
                        if (loc.WorkingQty >= loopQty) {

                            loc.WorkingQty = loc.WorkingQty - loopQty;
                            TransferData transferData = new TransferData();
                            transferData.Qty = loopQty;
                            transferData.Item = item;
                            transferData.Project = loc.ProjectId;
                            transferData.Site = loc.SiteId;
                            transferData.Division = loc.DivisionId;
                            transferData.LocId = loc.LocationId;
                            transferData.LocIdName = loc.LocationName;
                            transferData.LocNum = loc.LocationNumber;
                            returnCollection.add(transferData);

                            // Update Base Qtys
                            for (InventoryTransferLocationInfo locupdate : locationsData) {

                                locupdate.Qty = locupdate.WorkingQty;
                            }
                            System.debug('Added in last and returning');
                            System.debug(LoggingLevel.FINE,System.JSON.serializePretty(transferData));

                            return returnCollection;
                        } else {
                            if (loc.WorkingQty > 0) {
                                System.debug('Changing last pick');
                                lastPick = loc;
                            }
                        }
                    }


                    //Adds Used Item
                    if (lastPick != null) {
                        System.debug('Adding in last pick');

                        loopQty = loopQty - lastPick.WorkingQty;
                        TransferData transferData = new TransferData();
                        transferData.Qty = lastPick.WorkingQty;
                        transferData.Item = item;
                        transferData.Project = lastPick.ProjectId;
                        transferData.Site = lastPick.SiteId;
                        transferData.Division = lastPick.DivisionId;
                        transferData.LocId = lastPick.LocationId;
                        transferData.LocIdName = lastPick.LocationName;
                        transferData.LocNum = lastPick.LocationNumber;
                        returnCollection.add(transferData);

                        lastPick.WorkingQty = 0;
                        System.debug('Adding to return collection');
                        System.debug(System.JSON.serializePretty(transferData));

                    }

                    System.debug('Remaining qty needed: ' + loopQty);
                } while (lastPick != null);

                // Update Base Qtys
                for (InventoryTransferLocationInfo locupdate : locationsData) {

                    locupdate.WorkingQty = locupdate.Qty;
                }
            }

        }
        return new List<TransferData>();
    }

    @TestVisible
    private List<TransferData> multipleLocationNumAndIdPull(Id item, Decimal qty, Map<Id, Map<String, List<InventoryTransferLocationInfo>>> products, List<String> locations) {

        if(!products.containsKey(item)){
            return new List<TransferData>();
        }
        Map<String, List<InventoryTransferLocationInfo>> productLocationData = products.get(item);
        List<TransferData> returnCollection = new List<TransferData>();
        Decimal loopQty = qty;
        // Loop thru the locations to use
        for (String location : locations) {
            System.debug('Looping thru location ' + location);
            // Checks to see if the location is avalable
            if (productLocationData.containsKey(location)) {


                List<InventoryTransferLocationInfo> locationsData = productLocationData.get(location);
                locationsData.sort();
                InventoryTransferLocationInfo lastPick = null;
                do {
                    lastPick = null;
                    System.debug('Check Pass ');
                    for (Integer i = locationsData.size() - 1; i >= 0; i--) {

                        InventoryTransferLocationInfo loc = locationsData[i];
                        System.debug('checking ' + loc.ItemId + ' with Qty of ' + loc.WorkingQty);
                        // Checks to see if location can compleate the request
                        if (loc.WorkingQty >= loopQty) {

                            loc.WorkingQty = loc.WorkingQty - loopQty;
                            TransferData transferData = new TransferData();
                            transferData.Qty = loopQty;
                            transferData.Item = item;
                            transferData.Project = loc.ProjectId;
                            transferData.Site = loc.SiteId;
                            transferData.Division = loc.DivisionId;
                            transferData.LocId = loc.LocationId;
                            transferData.LocIdName = loc.LocationName;
                            transferData.LocNum = loc.LocationNumber;
                            returnCollection.add(transferData);

                            // Update Base Qtys
                            for (InventoryTransferLocationInfo locupdate : locationsData) {

                                locupdate.Qty = locupdate.WorkingQty;
                            }
                            System.debug('Added in last and returning');
                            System.debug(System.JSON.serializePretty(transferData));

                            return returnCollection;
                        } else {
                            if (loc.WorkingQty > 0) {
                                System.debug('Changing last pick');
                                lastPick = loc;
                            }
                        }
                    }


                    //Adds Used Item
                    if (lastPick != null) {
                        System.debug('Adding in last pick');

                        loopQty = loopQty - lastPick.WorkingQty;
                        TransferData transferData = new TransferData();
                        transferData.Qty = lastPick.WorkingQty;
                        transferData.Item = item;
                        transferData.Project = lastPick.ProjectId;
                        transferData.Site = lastPick.SiteId;
                        transferData.Division = lastPick.DivisionId;
                        transferData.LocId = lastPick.LocationId;
                        transferData.LocIdName = lastPick.LocationName;
                        transferData.LocNum = lastPick.LocationNumber;
                        returnCollection.add(transferData);

                        lastPick.WorkingQty = 0;
                        System.debug('Adding to return collection');
                        System.debug(System.JSON.serializePretty(transferData));

                    }

                    System.debug('Remaining qty needed: ' + loopQty);
                } while (lastPick != null);

                // Update Base Qtys
                for (InventoryTransferLocationInfo locupdate : locationsData) {

                    locupdate.Qty = locupdate.WorkingQty;
                }

            }
        }
        return returnCollection;
    }

    @TestVisible
    private class InventoryTransferLocationInfo implements Comparable{

        public Id IclocitemId { get{return internalData.IclocitemId;} set{internalData.IclocitemId = value;} }
        public Decimal Qty { get{return internalData.Qty;} set{internalData.Qty = value;} }

        public String LocationNumber { get{return internalData.LocationNumber;} set{internalData.LocationNumber = value;} }
        public Id LocationId { get{return internalData.LocationId;} set{internalData.LocationId = value;} }
        public String LocationName { get{return internalData.LocationName;} set{internalData.LocationName = value;} }

        public String LocationFormulaName { get{return internalData.LocationFormulaName;} set{internalData.LocationFormulaName = value;} }
        public Id DivisionId { get{return internalData.DivisionId;} set{internalData.DivisionId = value;} }
        public Id SiteId { get{return internalData.SiteId;} set{internalData.SiteId = value;} }
        public Id ProjectId { get{return internalData.ProjectId;} set{internalData.ProjectId = value;} }

        public Id ItemId { get{return internalData.ItemId;} set{internalData.ItemId = value;} }
        public String Item { get{return internalData.Item;} set{internalData.Item = value;} }

        public Decimal SupplyMultiplier { get{return internalData.SupplyMultiplier;} set{internalData.SupplyMultiplier = value;} }
        public Decimal DesiredInventoryOnHand { get{return internalData.DesiredInventoryOnHand;} set{internalData.DesiredInventoryOnHand = value;} }

        public Decimal WorkingQty { get; set; }
        public Decimal OriginalQty { get; set; }
        public Boolean AscOrder { get; set; }

        private final FMG_Inventory_Classes.InventoryTransferLocationInfo internalData;
        public InventoryTransferLocationInfo(){
            internalData = new FMG_Inventory_Classes.InventoryTransferLocationInfo();
        }
        public InventoryTransferLocationInfo(FMG_Inventory_Classes.InventoryTransferLocationInfo data) {
            AscOrder = false;
            internalData = data;
            WorkingQty = data.Qty;
            OriginalQty = data.Qty;
        }



        /**
         * @description checks this object with another agenst there Qty value
         * @param compareTo object to compair to
         *
         * @return the qty is smaller then the one being passed in returns 1. If the same 0 else -1
         **/
        public Integer compareTo(Object compareTo) {
            InventoryTransferLocationInfo compareToEntity = (InventoryTransferLocationInfo) compareTo;
            if (AscOrder) {
                return compareToAsc(compareToEntity);
            } else {
                return compareToDesc(compareToEntity);
            }
        }

        private Integer compareToAsc(InventoryTransferLocationInfo compareToEntity) {
            if (Qty == compareToEntity.Qty) {
                return 0;
            }
            if (Qty < compareToEntity.Qty) {
                return -1;
            }
            return 1;
        }

        private Integer compareToDesc(InventoryTransferLocationInfo compareToEntity) {
            if (Qty == compareToEntity.Qty) {
                return 0;
            }
            if (Qty < compareToEntity.Qty) {
                return 1;
            }
            return -1;
        }
    }

    @TestVisible
    private class TransferData {
        public Id Project { get; set; }
        public Id Division { get; set; }
        public Id Site { get; set; }
        public Id LocId { get; set; }
        public String LocIdName { get; set; }
        public String LocNum { get; set; }

        public Id Item { get; set; }
        public Decimal Qty { get; set; }
    }

    @TestVisible
    private FMG_Inventory_IServiceData mockDataAccess{get;set;}

    public List<FMG_Configuration__c> getPickOrderLocationIdsData() {
        List<FMG_Configuration__c> Records = [
                SELECT
                        Id,
                        Setting__c,
                        Value__c,
                        Application__c
                FROM FMG_Configuration__c
                WHERE Application__c = 'FMG Inventory Service' AND
                Setting__c = 'Create Inventory Move Source Location Ids'
                LIMIT 1
        ];
        if(mockDataAccess != null && test.isRunningTest()){
            Records = mockDataAccess.getPickOrderLocationIdsData();
        }
        return Records;
    }

    public List<rstk__icitem__c> getProductLocationsData(Set<Id> products, List<String> locationIds) {

                List<rstk__icitem__c> Records = [
                SELECT Id, rstk__icitem_descr__c,
                        rstk__icitem_item__r.rstk__peitem_item__c, (
                        SELECT rstk__icreplenish_multiplier__c,
                                rstk__icreplenish_tolocnum__c, rstk__icreplenish_tolocid__c,
                                rstk__icreplenish_tolocid__r.rstk__sylocid_locid__c,
                                rstk__icreplenish_maxqtyoh__c
                        FROM rstk__Replenishment_Location_Master__r
                ), (
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
                                rstk__iclocitem_icitem__r.rstk__icitem_item__r.rstk__peitem_item__c,
                                rstk__iclocitem_icitem__r.rstk__icitem_supplymultiplier__c
                        FROM rstk__ICLOCITEMs__r
                        WHERE rstk__iclocitem_locid__r.rstk__sylocid_locid__c IN :locationIds AND
                        rstk__iclocitem_locqty__c > 0
                        ORDER BY rstk__iclocitem_locqty__c ASC
                ),
                        rstk__icitem_wmslocnum__c, rstk__icitem_wmslocid__c
                FROM rstk__icitem__c
                WHERE Id IN :products
        ];

        if(mockDataAccess != null && test.isRunningTest()){
            Records = mockDataAccess.getProductLocationsData(products,locationIds);
        }

        return Records;
    }
}