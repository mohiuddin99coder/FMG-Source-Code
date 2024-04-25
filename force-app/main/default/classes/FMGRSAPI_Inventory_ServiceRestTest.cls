/**
 * Created by Adam-Hotmail on 6/7/2023.
 */

@IsTest
private class FMGRSAPI_Inventory_ServiceRestTest {
    @IsTest
    static void FMGRSAPI_OrderInventoryMove_Rest_CreateInventoryMoves() {
        FMGRSAPI_Inventory_ServiceMock testService = new FMGRSAPI_Inventory_ServiceMock();
        FMGRSAPI_OrderInventoryMove_Rest.inventoryService = testService;


        Set<Id> fakeOrders = new Set<Id>();
        fakeOrders.add(FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType));
        fakeOrders.add(FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType));
        fakeOrders.add(FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType));
        fakeOrders.add(FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType));
        fakeOrders.add(FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType));

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/fmgrsapi/order/inventory/move'; //Request URL
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        FMGRSAPI_OrderInventoryMove_Rest.CreateInventoryMoves(new List<Id>(fakeOrders));
        System.assertEquals(200,RestContext.response.statusCode);
        System.assertEquals('application/json',RestContext.response.headers.get('Content-Type'));
        List<Object> body = (List<Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        System.assertEquals(fakeOrders.size(), body.size());
        for(Object order: body){
            System.assert(fakeOrders.contains((Id)order));
        }
    }
    @IsTest
    static void FMGRSAPI_OrderInventoryMove_Rest_CreateInventoryMoves_Exception() {
        FMGRSAPI_Inventory_ServiceMock testService = new FMGRSAPI_Inventory_ServiceMock();
        FMGRSAPI_OrderInventoryMove_Rest.inventoryService = testService;

        FMGRSAPI_Inventory_Service.MissingWMSException ex = new FMGRSAPI_Inventory_Service.MissingWMSException();
        ex.Url = 'https://firemountaingems--rspilot.sandbox.my.salesforce.com/a1YDK000001iyFP2AY';
        ex.Item='jjb-phantommembrane';
        ex.LocationNumber=null;
        ex.LocationId = null;
        ex.ItemId = FMG_TestUtility.getFakeId(rstk__peitem__c.SObjectType);
        ex.Message='test message';



        testService.createInventoryMovesErrorException=ex;

        Id fakeOrder = FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType);
        List<Id> fakeOrders = new List<Id>();
        fakeOrders.add(fakeOrder);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/fmgrsapi/order/inventory/move'; //Request URL
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        FMGRSAPI_OrderInventoryMove_Rest.CreateInventoryMoves(fakeOrders);


        System.assertEquals(500,RestContext.response.statusCode);
        System.assertEquals('application/json',RestContext.response.headers.get('Content-Type'));
        Map<String, Object> body = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        System.assertEquals(ex.Message,body.get('Error Message'));
        System.assertEquals(ex.ItemId,body.get('ItemId'));
        System.assertEquals(ex.Item,body.get('ItemName'));
        System.assertEquals(ex.LocationNumber,body.get('LocationNumber'));
        System.assertEquals(ex.LocationId,body.get('LocationId'));
        System.assertEquals(ex.Url,body.get('ItemUrl'));
        System.assertEquals('FMGRSAPI_Inventory_Service.MissingWMSException',body.get('TypeName'));

        System.debug(RestContext.response.responseBody.toString());
    }

    @IsTest
    static void FMGRSAPI_InventoryMove_Rest_moveItem() {
        FMGRSAPI_Inventory_ServiceMock testService = new FMGRSAPI_Inventory_ServiceMock();
        FMGRSAPI_InventoryMove_Rest.inventoryService = testService;



        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/fmgrsapi/order/inventory/move'; //Request URL
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        Set<Id> fakeIds = new Set<Id>();

        List<FMGRSAPI_InventoryMove_Rest.InventoryMoveRequest> moveEvents = new List<FMGRSAPI_InventoryMove_Rest.InventoryMoveRequest>();
        FMGRSAPI_InventoryMove_Rest.InventoryMoveRequest testEvent = new FMGRSAPI_InventoryMove_Rest.InventoryMoveRequest();
        testEvent.SalesforceProductId = FMG_TestUtility.getFakeId(rstk__sydatat__c.SObjectType);
        testEvent.Quantity=10;
        testEvent.ProductSku='h0h0h0';
        testEvent.FromLocation = new FMGRSAPI_InventoryMove_Rest.Location();
        testEvent.FromLocation.LocationId = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType);
        testEvent.FromLocation.LocationNumber='C1';
        testEvent.ToLocation = new FMGRSAPI_InventoryMove_Rest.Location();
        testEvent.ToLocation.LocationId = FMG_TestUtility.getFakeId(rstk__sylocid__c.SObjectType);
        testEvent.ToLocation.LocationNumber='C2';
        fakeIds.add(testEvent.SalesforceProductId);

        moveEvents.add(testEvent);

        FMGRSAPI_InventoryMove_Rest.moveItem(moveEvents,true);

        System.assertEquals(200,RestContext.response.statusCode);
        System.assertEquals('application/json',RestContext.response.headers.get('Content-Type'));
        List<Object> body = (List<Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        System.assertEquals(fakeIds.size(), body.size());
        for(Object order: body){
            System.assert(fakeIds.contains((Id)order));
        }
    }



    class FMGRSAPI_Inventory_ServiceMock implements FMGRSAPI_Inventory_ServiceInterface{

        public FMGRSAPI_Inventory_ServiceMock(){
            createInventoryMovesErrorException = null;
        }
        public FMGRSAPI_Inventory_Service.MissingWMSException createInventoryMovesErrorException{get;set;}
        public List<Id> createInventoryMoves(List<Id> orderIds) {
            if(createInventoryMovesErrorException!= null){
                throw createInventoryMovesErrorException;
            }
            return orderIds;
        }

        public List<Id> moveItems(List<FMGRSAPI_Inventory_Service.InventoryMoveRequest> moveEvents, Boolean isBackground) {
            System.debug('****************************************************************************');
            System.debug(moveEvents);
            System.debug('****************************************************************************');
            List<Id> returnCollection = new List<Id>();
            for(FMGRSAPI_Inventory_Service.InventoryMoveRequest event: moveEvents){
                returnCollection.add(event.SalesforceProductId);
            }
            return returnCollection;
        }
    }
}