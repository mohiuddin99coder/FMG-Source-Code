/**
 * Created by Adam-Hotmail on 6/3/2023.
 */
@RestResource(UrlMapping='/fmgrsapi/order/inventory/move')
global with sharing class FMGRSAPI_OrderInventoryMove_Rest {


    @TestVisible
    static FMGRSAPI_Inventory_ServiceInterface inventoryService {get;set; }
    static{
        inventoryService = (FMGRSAPI_Inventory_ServiceInterface)new FMGRSAPI_Inventory_Service();
    }

    @HttpPost
    global static void CreateInventoryMoves(List<Id> orderIds){
        try {
            List<Id> sydatatIds = inventoryService.createInventoryMoves(orderIds);
            RestContext.response.statusCode = 200;
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(sydatatIds));
            RestContext.response.headers.put('Content-Type', 'application/json');
        } catch (FMGRSAPI_Inventory_Service.MissingWMSException ex){
            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf(ex.GetJson());
            RestContext.response.headers.put('Content-Type','application/json');

        }
    }

}