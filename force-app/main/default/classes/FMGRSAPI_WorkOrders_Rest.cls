/**
 * Created by Adam-Hotmail on 7/6/2023.
 */

@RestResource(UrlMapping='/fmgrsapi/work/orders')
global with sharing class FMGRSAPI_WorkOrders_Rest {
    @TestVisible
    static FMGRSAPI_WorkOrder_ServiceInterface workOrderService {get;set; }
    static{
        workOrderService = (FMGRSAPI_WorkOrder_ServiceInterface)new FMGRSAPI_WorkOrder_Service();
    }

    /**
    * @description Pulls an existing batch. This uses the query parameter BatchId
    *
    * @return The work order batch data
    * @param BatchId The Id of the order batch
    **/
    @HttpGet
    global static void doGet() {
        Map<String,String> paramsMap = RestContext.request.params;
        RestContext.response.statusCode = 200;
        RestContext.response.headers.put('Content-Type','application/json');
        if(paramsMap.containsKey('Id')){
            if(paramsMap.get('Id').isWhitespace()){
                RestContext.response.responseBody = Blob.valueOf('[]');
                return;
            }
            List<Id> data = paramsMap.get('Id').split(',');

            if(!data.isEmpty()){
                String returnBody = JSON.serialize(workOrderService.getWorkOrders(data),true);
                RestContext.response.responseBody = Blob.valueOf(returnBody);
                return;
            }
        }



    }
}