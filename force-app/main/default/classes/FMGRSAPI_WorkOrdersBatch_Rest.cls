/**
 * Created by Adam-Hotmail on 5/19/2023.
 */

@RestResource(UrlMapping='/fmgrsapi/work/orders/batch')
global  with sharing class FMGRSAPI_WorkOrdersBatch_Rest {

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
    global static void GetExistingBatch() {
        Map<String,String> paramsMap = RestContext.request.params;
        RestContext.response.statusCode = 200;
        RestContext.response.headers.put('Content-Type','application/json');
        if(paramsMap.containsKey('BatchId')){
            Integer batchId = Integer.valueOf(paramsMap.get('BatchId'));
            FMGRSAPI_WorkOrder_Service.WorkOrderBatch workOrderBatch = workOrderService.getBatchData(batchId);
            String jsonBody = JSON.serializePretty(workOrderBatch,true);
            System.debug(jsonBody);
            if(workOrderBatch != null) {
                RestContext.response.responseBody = Blob.valueOf(jsonBody);
                return;
            }
        }
        RestContext.response.responseBody = Blob.valueOf('{}');

    }

    /**
     * @description Post request that creates the new objects that are going to be pulled and returns the results.
      * This uses the query parameter BatchSize
     * @return The work order batch data
     **/
    @HttpPost
    global static void GetNewBatch() {
        Map<String,String> paramsMap = RestContext.request.params;
        RestContext.response.statusCode = 200;
        RestContext.response.headers.put('Content-Type','application/json');
        Integer batchId;

        if(paramsMap.containsKey('BatchSize')){
            Integer batchSize = Integer.valueOf(paramsMap.get('BatchSize'));
            batchId = workOrderService.generateWorkOrderBatch(batchSize);
        } else{
            batchId = workOrderService.generateWorkOrderBatch(100);
        }

        if(batchId != null){
            String returnBody = JSON.serialize(workOrderService.getBatchData(batchId),true);
            RestContext.response.responseBody = Blob.valueOf(returnBody);

        } else {
            RestContext.response.responseBody = Blob.valueOf('{}');
        }
    }
}