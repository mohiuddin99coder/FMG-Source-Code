/**
 * Created by inscorea on 6/19/2023.
 */
@RestResource(UrlMapping='/fmgrsapi/orders/lines')
global with sharing class FMGRSAPI_OrdersLines_Rest {

    @TestVisible
    static FMGRSAPI_Orders_ServiceInterface ordersService {get;set; }
    static{
        ordersService = (FMGRSAPI_Orders_ServiceInterface)new FMGRSAPI_Orders_Service();
    }

    @HttpPut
    global static void doPut(Id id,Decimal qty){
        System.debug('('+id.class.getName()+')' +id + ':' + qty);
        RestContext.response.headers.put('Content-Type','application/json');
        try {
            FMGRSAPI_Orders_Service.ReduceLineQtyResults results = ordersService.ReduceLineQty(id, qty);
            String returnBody = JSON.serialize(results,true);
            RestContext.response.statusCode = 200;
            RestContext.response.responseBody = Blob.valueOf(returnBody);
        }
        catch (FMGRSAPI_Orders_Service.ExceededMaxRemovalException ex){
            RestContext.response.statusCode = 404;
            String errorObject = Json.serialize(ex.ReversalItem);
            RestContext.response.responseBody = Blob.valueOf('{"Error": "Qty exceeded the amount tryed to remove","badObject":' + errorObject +'}');

        }




    }

}