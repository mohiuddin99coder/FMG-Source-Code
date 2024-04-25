/**
 * @AUTHOR Adam Inscore
 * @DESCRIPTION Rest endpoint for moving inventory in Rootstock
 **/
@RestResource(UrlMapping='/fmgrsapi/orders/batch')
global with sharing class FMGRSAPI_OrdersBatch_Rest {

    @TestVisible
    static FMGRSAPI_Orders_ServiceInterface ordersService {get;set; }
    static{
        ordersService = (FMGRSAPI_Orders_ServiceInterface)new FMGRSAPI_Orders_Service();
    }

    /**
        * @description Pulls an existing batch
        * @param BatchId The Id of the order batch
        **/
    @HttpGet
    global static void GetExistingBatch(){
        Map<String,String> paramsMap = RestContext.request.params;



        if(paramsMap.containsKey('BatchId')){
            Integer BatchId = Integer.valueOf(paramsMap.get('BatchId'));
            String returnBody = JSON.serialize(ordersService.getOrdersByBatchId(BatchId),true);

            RestContext.response.statusCode = 200;
            RestContext.response.responseBody = Blob.valueOf(returnBody);
            RestContext.response.headers.put('Content-Type','application/json');
        }
    }

    /**
     * @description Post request that creates the new objects that are going to be pulled and returns the results
     *
     * @param BatchSize This is the size of the batch that will be created and returned
     **/
    @HttpPost
    global static void GetNewBatch() {
        Map<String,String> paramsMap = RestContext.request.params;
        Integer batchId;


        if(paramsMap.containsKey('BatchSize')){
            Integer batchSize = Integer.valueOf(paramsMap.get('BatchSize'));
            batchId  = ordersService.generateOrderBatch(batchSize);
        } else{
            batchId = ordersService.generateOrderBatch(100);
        }


        // On a value of -1 return 404 for no data found
        // On a value that is not -1 then will return batch data
        if(batchId == -1) {
            RestContext.response.statusCode = 204;
            RestContext.response.headers.put('Content-Type','application/json');
            RestContext.response.responseBody = Blob.valueOf('{"Error": "No Records Found"');
        } else {
            String returnBody = JSON.serialize(ordersService.getOrdersByBatchId(batchId),true);
            RestContext.response.statusCode = 200;
            RestContext.response.responseBody = Blob.valueOf(returnBody);
            RestContext.response.headers.put('Content-Type','application/json');
        }
    }
}