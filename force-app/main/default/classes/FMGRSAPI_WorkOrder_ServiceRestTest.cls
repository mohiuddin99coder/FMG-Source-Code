/**
 * Created by Adam-Hotmail on 6/8/2023.
 */

@IsTest
public with sharing class FMGRSAPI_WorkOrder_ServiceRestTest {

    @IsTest
    static void FMGRSAPI_WorkOrdersBatch_Rest_GetExistingBatch(){

        FMGRSAPI_WorkOrder_ServiceMock serviceMock = new FMGRSAPI_WorkOrder_ServiceMock(false);
        FMGRSAPI_WorkOrdersBatch_Rest.workOrderService = (FMGRSAPI_WorkOrder_ServiceInterface)serviceMock;
        FMG_TestUtility.InitRest('/fmgrsapi/work/orders/batch','GET');
        RestContext.request.params.put('BatchId','1');
        FMGRSAPI_WorkOrdersBatch_Rest.GetExistingBatch();

        System.assertEquals(200,RestContext.response.statusCode);
        System.assertEquals('application/json',RestContext.response.headers.get('Content-Type'));
        System.debug(JSON.serializePretty(RestContext.response.responseBody.toString()));
        FMGRSAPI_WorkOrder_Service.WorkOrderBatch body =
                (FMGRSAPI_WorkOrder_Service.WorkOrderBatch)JSON.deserialize(RestContext.response.responseBody.toString(),FMGRSAPI_WorkOrder_Service.WorkOrderBatch.class);
        System.assertEquals(1,body.BatchId);

    }
    @IsTest
    static void FMGRSAPI_WorkOrdersBatch_Rest_GetExistingBatch_MissingParam(){

        FMGRSAPI_WorkOrder_ServiceMock serviceMock = new FMGRSAPI_WorkOrder_ServiceMock(false);
        FMGRSAPI_WorkOrdersBatch_Rest.workOrderService = (FMGRSAPI_WorkOrder_ServiceInterface)serviceMock;
        FMG_TestUtility.InitRest('/fmgrsapi/work/orders/batch','GET');
        FMGRSAPI_WorkOrdersBatch_Rest.GetExistingBatch();

        System.assertEquals(200,RestContext.response.statusCode);
        System.assertEquals('application/json',RestContext.response.headers.get('Content-Type'));
        String body = RestContext.response.responseBody.toString();
        System.assertEquals('{}',body);

    }
    @IsTest
    static void FMGRSAPI_WorkOrdersBatch_Rest_GetExistingBatch_Null(){
        FMGRSAPI_WorkOrder_ServiceMock serviceMock = new FMGRSAPI_WorkOrder_ServiceMock(true);
        FMGRSAPI_WorkOrdersBatch_Rest.workOrderService = (FMGRSAPI_WorkOrder_ServiceInterface)serviceMock;
        FMG_TestUtility.InitRest('/fmgrsapi/work/orders/batch','GET');
        RestContext.request.params.put('BatchId','1');
        FMGRSAPI_WorkOrdersBatch_Rest.GetExistingBatch();
        System.assertEquals(200,RestContext.response.statusCode);
        System.assertEquals('application/json',RestContext.response.headers.get('Content-Type'));

        System.debug(JSON.serializePretty(RestContext.response.responseBody.toString()));
        String body = RestContext.response.responseBody.toString();
        System.assertEquals('{}',body);
    }
    @IsTest
    static void FMGRSAPI_WorkOrdersBatch_Rest_GetNewBatch_SetValue(){
        FMGRSAPI_WorkOrder_ServiceMock serviceMock = new FMGRSAPI_WorkOrder_ServiceMock(false);
        FMGRSAPI_WorkOrdersBatch_Rest.workOrderService = (FMGRSAPI_WorkOrder_ServiceInterface)serviceMock;
        FMG_TestUtility.InitRest('/fmgrsapi/work/orders/batch','GET');
        RestContext.request.params.put('BatchSize','1');

        FMGRSAPI_WorkOrdersBatch_Rest.GetNewBatch();

        System.assertEquals(200,RestContext.response.statusCode);
        System.assertEquals('application/json',RestContext.response.headers.get('Content-Type'));
        FMGRSAPI_WorkOrder_Service.WorkOrderBatch body =
                (FMGRSAPI_WorkOrder_Service.WorkOrderBatch)JSON.deserialize(RestContext.response.responseBody.toString(),FMGRSAPI_WorkOrder_Service.WorkOrderBatch.class);
        System.assertEquals(1,body.BatchId);
    }

    @IsTest
    static void FMGRSAPI_WorkOrdersBatch_Rest_GetNewBatch_default(){
        FMGRSAPI_WorkOrder_ServiceMock serviceMock = new FMGRSAPI_WorkOrder_ServiceMock(false);
        FMGRSAPI_WorkOrdersBatch_Rest.workOrderService = (FMGRSAPI_WorkOrder_ServiceInterface)serviceMock;
        FMG_TestUtility.InitRest('/fmgrsapi/work/orders/batch','GET');
        FMGRSAPI_WorkOrdersBatch_Rest.GetNewBatch();

        System.assertEquals(200,RestContext.response.statusCode);
        System.assertEquals('application/json',RestContext.response.headers.get('Content-Type'));
        FMGRSAPI_WorkOrder_Service.WorkOrderBatch body =
                (FMGRSAPI_WorkOrder_Service.WorkOrderBatch)JSON.deserialize(RestContext.response.responseBody.toString(),FMGRSAPI_WorkOrder_Service.WorkOrderBatch.class);
        System.assertEquals(100,body.BatchId);
    }

    @IsTest
    static void FMGRSAPI_WorkOrdersBatch_Rest_Null(){
        FMGRSAPI_WorkOrder_ServiceMock serviceMock = new FMGRSAPI_WorkOrder_ServiceMock(true);
        FMGRSAPI_WorkOrdersBatch_Rest.workOrderService = (FMGRSAPI_WorkOrder_ServiceInterface)serviceMock;
        FMG_TestUtility.InitRest('/fmgrsapi/work/orders/batch','GET');
        RestContext.request.params.put('BatchSize','1');
        FMGRSAPI_WorkOrdersBatch_Rest.GetNewBatch();
        System.assertEquals(200,RestContext.response.statusCode);
        System.assertEquals('application/json',RestContext.response.headers.get('Content-Type'));
        String body = RestContext.response.responseBody.toString();
        System.assertEquals('{}',body);
    }

    @IsTest
    static void FMGRSAPI_WorkOrderGet(){
        FMGRSAPI_WorkOrder_ServiceMock serviceMock = new FMGRSAPI_WorkOrder_ServiceMock(true);
        FMGRSAPI_WorkOrdersBatch_Rest.workOrderService = (FMGRSAPI_WorkOrder_ServiceInterface)serviceMock;

        Set<String> testWorkOrderIds = new Set<String>();
        testWorkOrderIds.add(FMG_TestUtility.getFakeId(rstk__wocst__c.SObjectType));
        testWorkOrderIds.add(FMG_TestUtility.getFakeId(rstk__wocst__c.SObjectType));
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/fmgrsapi/work/orders'; //Request URL
        req.httpMethod = 'GET';
        req.params.put('Id',String.join(new List<String>(testWorkOrderIds),','));
        RestContext.request = req;
        RestContext.response= res;
        FMGRSAPI_WorkOrders_Rest.doGet();

        System.assertEquals(200,RestContext.response.statusCode);
        System.assertEquals('application/json',RestContext.response.headers.get('Content-Type'));
        List<FMGRSAPI_WorkOrder_Service.WorkOrder> data = (List<FMGRSAPI_WorkOrder_Service.WorkOrder>)JSON.deserialize(RestContext.response.responseBody.toString(),List<FMGRSAPI_WorkOrder_Service.WorkOrder>.class);

        for(FMGRSAPI_WorkOrder_Service.WorkOrder workOrder: data){
            System.assert(testWorkOrderIds.contains(workOrder.WorkOrderId));
        }
    }

    @IsTest
    static void FMGRSAPI_WorkOrderGet_nothing(){
        FMGRSAPI_WorkOrder_ServiceMock serviceMock = new FMGRSAPI_WorkOrder_ServiceMock(true);
        FMGRSAPI_WorkOrdersBatch_Rest.workOrderService = (FMGRSAPI_WorkOrder_ServiceInterface)serviceMock;

        Set<String> testWorkOrderIds = new Set<String>();
        testWorkOrderIds.add(FMG_TestUtility.getFakeId(rstk__wocst__c.SObjectType));
        testWorkOrderIds.add(FMG_TestUtility.getFakeId(rstk__wocst__c.SObjectType));
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/fmgrsapi/work/orders'; //Request URL
        req.httpMethod = 'GET';
        req.params.put('Id','');
        RestContext.request = req;
        RestContext.response= res;
        FMGRSAPI_WorkOrders_Rest.doGet();

        System.assertEquals(200,RestContext.response.statusCode);
        System.assertEquals('application/json',RestContext.response.headers.get('Content-Type'));
        List<FMGRSAPI_WorkOrder_Service.WorkOrder> data = (List<FMGRSAPI_WorkOrder_Service.WorkOrder>)JSON.deserialize(RestContext.response.responseBody.toString(),List<FMGRSAPI_WorkOrder_Service.WorkOrder>.class);

        System.assertEquals(true,data.isEmpty(),'There should be no returned records');


    }

    public class FMGRSAPI_WorkOrder_ServiceMock implements FMGRSAPI_WorkOrder_ServiceInterface{

        Boolean returnNull = false;
        public FMGRSAPI_WorkOrder_ServiceMock(Boolean returnNull){
            this.returnNull = returnNull;
        }
        public FMGRSAPI_WorkOrder_Service.WorkOrderBatch getBatchData(Integer batchId) {
            if(returnNull){
                return null;
            }
            FMGRSAPI_WorkOrder_Service.WorkOrderBatch batch = new FMGRSAPI_WorkOrder_Service.WorkOrderBatch();
            batch.BatchId = batchId;
            return batch;
        }

        public Integer generateWorkOrderBatch(Integer batchSize) {

            System.debug(batchSize);
            if(returnNull){
                return null;
            }
            return batchSize;
        }

        public List<FMGRSAPI_WorkOrder_Service.WorkOrder> getWorkOrders(List<Id> workOrderIds) {
            System.debug(workOrderIds);
            if(returnNull){
                return null;
            }

            List<FMGRSAPI_WorkOrder_Service.WorkOrder> testOutput = new List<FMGRSAPI_WorkOrder_Service.WorkOrder>();

            for(Id woId: workOrderIds){
                FMGRSAPI_WorkOrder_Service.WorkOrder tmpwo = new FMGRSAPI_WorkOrder_Service.WorkOrder();
                tmpwo.WorkOrderId = woId;
                testOutput.add(tmpwo);
            }

            return testOutput;
        }
    }
}