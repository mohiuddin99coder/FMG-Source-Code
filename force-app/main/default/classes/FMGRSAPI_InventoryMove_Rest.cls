/**
 * @AUTHOR Adam Inscore
 * @DESCRIPTION Rest endpoint for moving inventory in Rootstock
 **/
@RestResource(UrlMapping='/fmgrsapi/inventory/move')
global with sharing class FMGRSAPI_InventoryMove_Rest {

    @TestVisible
    static FMGRSAPI_Inventory_ServiceInterface inventoryService {get;set; }
    static{
        inventoryService = (FMGRSAPI_Inventory_ServiceInterface)new FMGRSAPI_Inventory_Service();
    }

    /**
     * @AUTHOR Adam Inscore
     * @description Describing the location for either the to and from on the request. This is used as a parameter on the rest call
     **/
    global class Location{
        global String LocationId{get;set;}
        global String LocationNumber{get;set;}


        /**
         * @return Returns the converted version that the FMGRSAPI_Inventory Accepts
         **/
        public FMGRSAPI_Inventory_Service.Location Convert(){
            FMGRSAPI_Inventory_Service.Location returnValue = new FMGRSAPI_Inventory_Service.Location();

            returnValue.LocationId = LocationId;
            returnValue.LocationNumber = LocationNumber;

            return returnValue;
        }
    }

    /**
     * @AUTHOR Adam Inscore
     * @description Describing the move operation. This is used as a parameter on the rest call
     **/
    global class InventoryMoveRequest{
        global Location FromLocation {get;set;}
        global Location ToLocation {get;set;}
        global String ProductSku{get;set;}
        global Integer Quantity {get;set;}
        global String SalesforceProductId {get;set;}

        /**
         * @return Returns the converted version that the FMGRSAPI_Inventory Accepts
         **/
        public FMGRSAPI_Inventory_Service.InventoryMoveRequest convert(){
            FMGRSAPI_Inventory_Service.InventoryMoveRequest returnValue = new FMGRSAPI_Inventory_Service.InventoryMoveRequest();
            returnValue.FromLocation = FromLocation.Convert();
            returnValue.ToLocation = ToLocation.Convert();
            returnValue.ProductSku = ProductSku;
            returnValue.Quantity = Quantity;
            returnValue.SalesforceProductId = SalesforceProductId;

            return returnValue;
        }
    }

    /**
     * @param moveEvents passed in events/actions to be executed
     * @param isBackground for running as a background operation or not. This is true by default
     *
     * @return collection of all sydatat object Ids associated with the moves
     **/
    @HttpPost
    global static void moveItem(List<InventoryMoveRequest> moveEvents,Boolean isBackground){
        List<FMGRSAPI_Inventory_Service.InventoryMoveRequest> convertedMoveEvents = new List<FMGRSAPI_Inventory_Service.InventoryMoveRequest>();

        for(InventoryMoveRequest moveEvent: moveEvents) {
            convertedMoveEvents.add(moveEvent.convert());
        }

        List<Id> sysDatat = inventoryService.moveItems(convertedMoveEvents,isBackground);
        System.debug(sysDatat);
        RestContext.response.statusCode = 200;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(sysDatat));
        RestContext.response.headers.put('Content-Type', 'application/json');

    }


}