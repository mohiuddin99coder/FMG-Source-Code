/**
 * This class is for functions that are used for Unit tests. This should never be used for live Code
 **/
@IsTest
public with sharing class FMG_TestUtility {

    /**
     * @param Url Request Url
     * @param Method Request Method ex. POST, GET,PATCH
     **/
    public static void InitRest(String Url,String Method){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = Url; //Request URL
        req.httpMethod = Method;
        RestContext.request = req;
        RestContext.response= res;
    }

    public class FMG_TestUtilityException extends Exception {}
    /**
     * @description To check and see if this is running as a test.
     * @throws FMG_TestUtilityException exception if not running as Unit Test
     **/
    private static void IsRunningUnitTestCheck(){
        if(!Test.isRunningTest()){
            throw new FMG_TestUtilityException('This is not allowed to be used outside of Unit Tests');
        }
    }
/**************************** Generates Fake Salesforce Ids ******************************/

    /**
     * @DESCRIPTION Incrementing number for each new fake Id
     **/
    static Integer fakeIndex = 1;

    /**
     * @param sObjectType The type of the sObject to be used for generating the fake Id
     *
     * @return The fake Id that was generated
     **/
    public static Id getFakeId(Schema.SObjectType sObjectType) {
        String index = String.valueOf(fakeIndex++);
        return (Id) (sObjectType.getDescribe().getKeyPrefix() +
                '0'.repeat(12 - index.length()) +
                index);
    }

    /**
     * @DESCRIPTION Collection of Ids that can be reused
     **/
    public static final Map<Schema.SObjectType,Map<String,Id>> ReuseIds = new Map<SObjectType, Map<String, Id>>();

    /**
     * @param sObjectType The type of the sObject to be used for generating the fake Id
     * @param name The name of the fakeId so that it can be reused
     *
     * @return The fake Id that was generated
     **/
    public static Id getFakeId(Schema.SObjectType sObjectType,String name) {
        if(!ReuseIds.containsKey(sObjectType)){
            ReuseIds.put(sObjectType,new Map<String, Id>());
            ReuseIds.get(sObjectType).put(name,getFakeId(sObjectType));
        } else if(!ReuseIds.get(sObjectType).containsKey(name)){
            ReuseIds.get(sObjectType).put(name,getFakeId(sObjectType));
        }
        return ReuseIds.get(sObjectType).get(name);
    }





    /**************************** Class Generation ******************************/

    /**
     * @param Item Item Name
     * @param LocationId Name of the location ex. P1 or 26
     * @param LocationNumber Location number Ex. C1
     * @param Qty The number of items in that location
     * @param LocationFormulaName The formatted name of the location
     * @param Division The name of the division
     * @param Site The name of the Site
     * @param Project The name of the Project
     * @param supplyMultiplier The Multiplier to try and hit a minimum. This value needs to be >= 1 and should be the same fore the same item;
     *
     * @return a fake version of the Inventory Service Location Information
     *
     * @example FMG_TestUtility.generateLocationInfo('Item1','26','Location1',3,1,'26 (Bunker Bulk)','FMG','FMG_FMG1','FMG_'));
     * @example FMG_TestUtility.generateLocationInfo('Item2','25','Location2',3,1,'25 (DC Bulk)','FMG','FMG_FMG1','FMG_'));
     * @example FMG_TestUtility.generateLocationInfo('Item3','P1','Location3',5,1,'P1 (Primary)','FMG','FMG_FMG1','FMG_'));
     **/
    public static FMGRSAPI_Inventory_Service.LocationInfo generateLocationInfo(String Item,String LocationId,String locationNumber, Decimal qty,Decimal supplyMultiplier,Decimal desiredInventoryOnHand,
            String LocationFormulaName,String Division,String Site,String Project){
        FMGRSAPI_Inventory_Service.LocationInfo locationInfo = new FMGRSAPI_Inventory_Service.LocationInfo();
        locationInfo.LocationNumber = locationNumber;
        locationInfo.LocationName = LocationId;
        locationInfo.Qty = qty;
        locationInfo.Item = Item;
        locationInfo.LocationId = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType,LocationId);
        locationInfo.OriginalQty = qty;
        locationInfo.LocationFormulaName = LocationFormulaName;
        locationInfo.DivisionId=FMG_TestUtility.getFakeId(rstk__sydiv__c.SObjectType,Division);
        locationInfo.SiteId=FMG_TestUtility.getFakeId(rstk__sysite__c.SObjectType,Site);
        locationInfo.ProjectId=FMG_TestUtility.getFakeId(rstk__pjproj__c.SObjectType,Project);
        locationInfo.SupplyMultiplier = supplyMultiplier;
        locationInfo.DesiredInventoryOnHand = desiredInventoryOnHand;
        return locationInfo;
    }


    public static FMGRSAPI_Inventory_Service.LocationInfo generateLocationInfo(String Item,Decimal qty,Decimal supplyMultiplier,Decimal desiredInventoryOnHand,String locationNumber,String LocationId
    ){
        return generateLocationInfo(Item,LocationId,locationNumber, qty,supplyMultiplier,desiredInventoryOnHand,
                LocationId + ' - FormulaName','FMG','FMG1','FMG');
    }


}