/**
 * Created by inscorea on 6/6/2023.
 */

@IsTest
private class FMGRSAPI_Orders_ServiceRestTest {


    @IsTest
    static void FMGRSAPI_OrdersProcessing_Rest_ExecutePost() {
        FMGRSAPI_OrdersProcessing_Rest.ordersService = (FMGRSAPI_Orders_ServiceInterface)new FMGRSAPI_Orders_ServiceMock();

        List<FMGRSAPI_OrdersProcessing_Rest.ProcessOrderEvent> orderEvents = new List<FMGRSAPI_OrdersProcessing_Rest.ProcessOrderEvent>();
        Set<String> expectedOutputs = new Set<String>();
        FMGRSAPI_OrdersProcessing_Rest.ProcessOrderEvent testRecord = new FMGRSAPI_OrdersProcessing_Rest.ProcessOrderEvent();
        testRecord.SalesforceOrderId = FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType);
        testRecord.OrderEvent='Invalid';
        testRecord.EventTime=Datetime.now();
        testRecord.Username='It\'s me';
        orderEvents.add(testRecord);
        expectedOutputs.add(JSON.serialize(testRecord));
        List<String> outputrecords = FMGRSAPI_OrdersProcessing_Rest.ExecutePost(orderEvents,null);
        System.debug(''+expectedOutputs);
        System.debug(outputrecords);
        for(String outputrecord:outputrecords){
            System.assert(expectedOutputs.contains(outputrecord));
        }

    }

    @IsTest
    static void FMGRSAPI_OrdersBatch_Rest_GetExistingBatch(){
        FMGRSAPI_OrdersBatch_Rest.ordersService = (FMGRSAPI_Orders_ServiceInterface)new FMGRSAPI_Orders_ServiceMock();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/fmgrsapi/orders/batch'; //Request URL
        req.httpMethod = 'GET';
        req.params.put('BatchId','1');
        RestContext.request = req;
        RestContext.response= res;

        FMGRSAPI_OrdersBatch_Rest.GetExistingBatch();

        System.assertEquals(200,RestContext.response.statusCode);
        System.assertEquals('application/json',RestContext.response.headers.get('Content-Type'));
        Map<String, Object> body = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        System.assertEquals(body.get('BatchId'),1);
    }

    @IsTest
    static void FMGRSAPI_OrdersBatch_Rest_GetNewBatch_NoData(){
        FMGRSAPI_OrdersBatch_Rest.ordersService = (FMGRSAPI_Orders_ServiceInterface)new FMGRSAPI_Orders_ServiceMock();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/fmgrsapi/orders/batch'; //Request URL
        req.httpMethod = 'POST';
        req.params.put('BatchSize','-1');
        RestContext.request = req;
        RestContext.response= res;

        FMGRSAPI_OrdersBatch_Rest.GetNewBatch();

        System.assertEquals(RestContext.response.statusCode,204);
        System.assertEquals('application/json',RestContext.response.headers.get('Content-Type'));
        String body = RestContext.response.responseBody.toString();
        System.assertEquals(body,'{"Error": "No Records Found"');
    }

    @IsTest
    static void FMGRSAPI_OrdersBatch_Rest_GetNewBatch_SpecifiedSize(){
        FMGRSAPI_OrdersBatch_Rest.ordersService = (FMGRSAPI_Orders_ServiceInterface)new FMGRSAPI_Orders_ServiceMock();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/fmgrsapi/orders/batch'; //Request URL
        req.httpMethod = 'POST';
        req.params.put('BatchSize','2');
        RestContext.request = req;
        RestContext.response= res;

        FMGRSAPI_OrdersBatch_Rest.GetNewBatch();

        System.assertEquals(200,RestContext.response.statusCode);
        System.assertEquals('application/json',RestContext.response.headers.get('Content-Type'));
        Map<String, Object> body = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        System.assertEquals(body.get('BatchId'),2);
    }

    @IsTest
    static void FMGRSAPI_OrdersBatch_Rest_GetNewBatch_DefaultSize(){
        FMGRSAPI_OrdersBatch_Rest.ordersService = (FMGRSAPI_Orders_ServiceInterface)new FMGRSAPI_Orders_ServiceMock();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/fmgrsapi/orders/batch'; //Request URL
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;

        FMGRSAPI_OrdersBatch_Rest.GetNewBatch();

        System.assertEquals(200,RestContext.response.statusCode);
        System.assertEquals('application/json',RestContext.response.headers.get('Content-Type'));
        Map<String, Object> body = (Map<String, Object>)JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        System.assertEquals(body.get('BatchId'),100);
    }

    @IsTest
    static void FMGRSAPI_Orders_Rest_getOrders(){
        FMGRSAPI_Orders_Rest.ordersService = (FMGRSAPI_Orders_ServiceInterface)new FMGRSAPI_Orders_ServiceMock();
        Set<String> testOrderIds = new Set<String>();
        testOrderIds.add(FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType));
        testOrderIds.add(FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType));
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/fmgrsapi/orders'; //Request URL
        req.httpMethod = 'GET';
        req.params.put('Id',String.join(new List<String>(testOrderIds),','));
        RestContext.request = req;
        RestContext.response= res;

        FMGRSAPI_Orders_Rest.getOrders();

        System.assertEquals(200,RestContext.response.statusCode);
        System.assertEquals('application/json',RestContext.response.headers.get('Content-Type'));
        FMGRSAPI_Orders_Service.BatchData body = (FMGRSAPI_Orders_Service.BatchData)JSON.deserialize(RestContext.response.responseBody.toString(),FMGRSAPI_Orders_Service.BatchData.class);
        System.assertEquals(body.BatchId,-1);
        for(FMGRSAPI_Orders_Service.OrderInfo order: body.Orders){
            System.assert(testOrderIds.contains(order.Id));
        }
    }

    @IsTest
    static void FMGRSAPI_Orders_Rest_getOrders_NoParam(){
        FMGRSAPI_Orders_Rest.ordersService = (FMGRSAPI_Orders_ServiceInterface)new FMGRSAPI_Orders_ServiceMock();
        Set<Id> testOrderIds = new Set<Id>();
        testOrderIds.add(FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType));
        testOrderIds.add(FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType));
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/fmgrsapi/orders'; //Request URL
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;

        FMGRSAPI_Orders_Rest.getOrders();

        System.assertEquals(200,RestContext.response.statusCode);
        System.assertEquals('application/json',RestContext.response.headers.get('Content-Type'));
        System.assertEquals('[]',RestContext.response.responseBody.toString());
    }

    @IsTest
    static void FMGRSAPI_Orders_Rest_getOrders_NoValue(){
        FMGRSAPI_Orders_Rest.ordersService = (FMGRSAPI_Orders_ServiceInterface)new FMGRSAPI_Orders_ServiceMock();
        Set<Id> testOrderIds = new Set<Id>();
        testOrderIds.add(FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType));
        testOrderIds.add(FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType));
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/fmgrsapi/orders'; //Request URL
        req.httpMethod = 'GET';
        req.params.put('Id','');
        RestContext.request = req;
        RestContext.response= res;

        FMGRSAPI_Orders_Rest.getOrders();

        System.assertEquals(200,RestContext.response.statusCode);
        System.assertEquals('application/json',RestContext.response.headers.get('Content-Type'));
        System.assertEquals(RestContext.response.responseBody.toString(),'[]');
    }


    @IsTest
    static void FMGRSAPI_OrdersLines_Rest_doPut(){
        FMGRSAPI_OrdersLines_Rest.ordersService = (FMGRSAPI_Orders_ServiceInterface)new FMGRSAPI_Orders_ServiceMock();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/fmgrsapi/orders/lines'; //Request URL
        req.httpMethod = 'Put';
        RestContext.request = req;
        RestContext.response= res;

        FMGRSAPI_OrdersLines_Rest.doPut(FMG_TestUtility.getFakeId(rstk__soline__c.SObjectType),5);


        System.assertEquals(200,RestContext.response.statusCode);
        System.assertEquals('application/json',RestContext.response.headers.get('Content-Type'));
        Map<String, Object> response =
                (Map<String, Object>)
                        JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        System.assertEquals(false,(Boolean)response.get('ReRun'));
        List<Object> executionIds = (List<Object>)response.get('Ids');
        System.assertEquals(true,executionIds.isEmpty());

    }

    @IsTest
    static void FMGRSAPI_OrdersLines_Rest_doPut_exception(){
        FMGRSAPI_Orders_ServiceMock mockService = new FMGRSAPI_Orders_ServiceMock();
        FMGRSAPI_OrdersLines_Rest.ordersService = (FMGRSAPI_Orders_ServiceInterface)mockService;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/fmgrsapi/orders/lines'; //Request URL
        req.httpMethod = 'Put';
        RestContext.request = req;
        RestContext.response= res;

        FMGRSAPI_Orders_Service.OrderItemReversal exceptionDataObject = new FMGRSAPI_Orders_Service.OrderItemReversal();
        exceptionDataObject.Qty = 10;
        exceptionDataObject.FirmedAllocated = 5;
        exceptionDataObject.Issued = 3;
        exceptionDataObject.Packed = 2;
        mockService.reduceLineQtyExceptionObject = exceptionDataObject;
        FMGRSAPI_OrdersLines_Rest.doPut(FMG_TestUtility.getFakeId(rstk__soline__c.SObjectType),5);


        System.assertEquals(404,RestContext.response.statusCode);
        System.assertEquals('application/json',RestContext.response.headers.get('Content-Type'));
        Map<String, Object> response =
                (Map<String, Object>)
                        JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        System.assertEquals(true,response.containsKey('Error'));
        Map<String, Object> badObject = (Map<String, Object>)response.get('badObject');
        System.assertEquals(exceptionDataObject.Packed,badObject.get('Packed'));
        System.assertEquals(exceptionDataObject.FirmedAllocated,badObject.get('FirmedAllocated'));
        System.assertEquals(exceptionDataObject.Issued,badObject.get('Issued'));
        System.assertEquals(exceptionDataObject.Packed,badObject.get('Packed'));

    }

    @IsTest
    static void FMGRSAPI_OrdersShippingContainers_Rest_DoPost(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/fmgrsapi/work/orders'; //Request URL
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;

        FMGRSAPI_Orders_ServiceMock serviceMock = new FMGRSAPI_Orders_ServiceMock();
        FMGRSAPI_OrdersShippingContainers_Rest.ordersService = (FMGRSAPI_Orders_ServiceInterface)serviceMock;
        List<FMGRSAPI_OrdersShippingContainers_Rest.ShippingContainer> testData = new List<FMGRSAPI_OrdersShippingContainers_Rest.ShippingContainer>();
        FMGRSAPI_OrdersShippingContainers_Rest.ShippingContainer InputRecord = new FMGRSAPI_OrdersShippingContainers_Rest.ShippingContainer();
        testData.add(InputRecord);
        InputRecord.TrackingNumber = 'TestTrackingNumber!@#$`124';
        InputRecord.ContainerType='Test';
        InputRecord.SalesforceOrderId = FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType);
        InputRecord.ShipToAddress = new FMGRSAPI_OrdersShippingContainers_Rest.ShippingContainerAddress();
        InputRecord.ShipToAddress.City='Grants Pass';
        InputRecord.ShipToAddress.AddressLine1 = 'Good';
        InputRecord.Products = new List<FMGRSAPI_OrdersShippingContainers_Rest.ShippingContainerItem>();
        FMGRSAPI_OrdersShippingContainers_Rest.ShippingContainerItem product = new FMGRSAPI_OrdersShippingContainers_Rest.ShippingContainerItem();
        product.Quantity=10;
        product.SalesforceOrderLineId=FMG_TestUtility.getFakeId(rstk__soline__c.SObjectType);
        InputRecord.Products.add(product);
        Test.startTest();
        FMGRSAPI_OrdersShippingContainers_Rest.doPost(testData);
        Test.stopTest();


        System.debug(JSON.serializePretty(testData));
        System.debug(JSON.serializePretty(serviceMock));
        System.assertEquals(testData.size(),serviceMock.GenerateContainersPramater.size());
        FMGRSAPI_Orders_Service.ShippingContainer resultedData = serviceMock.GenerateContainersPramater[0];

        System.assertEquals(InputRecord.Products.size(),resultedData.Products.size());
        System.assertEquals(InputRecord.Products[0].SalesforceOrderLineId,resultedData.Products[0].SalesforceOrderLineId);
        System.assertEquals(InputRecord.Products[0].Quantity,resultedData.Products[0].Quantity);

        System.assertNotEquals(null,resultedData.ShipToAddress);

        System.assertEquals(InputRecord.SalesforceOrderId,resultedData.SalesforceOrderId);
        System.assertEquals(InputRecord.ContainerType,resultedData.ContainerType);
        System.assertEquals(InputRecord.TrackingNumber,resultedData.TrackingNumber);
        System.assertEquals(InputRecord.ShipToAddress.City,resultedData.ShipToAddress.City);
        System.assertEquals(InputRecord.ShipToAddress.AddressLine1,resultedData.ShipToAddress.Address1);
    }

    @IsTest
    static void FMGRSAPI_OrdersShippingContainers_Rest_DoPostWithNoShippingHeadersException(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/fmgrsapi/work/orders'; //Request URL
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;

        FMGRSAPI_Orders_ServiceMock serviceMock = new FMGRSAPI_Orders_ServiceMock();
        FMGRSAPI_OrdersShippingContainers_Rest.ordersService = (FMGRSAPI_Orders_ServiceInterface)serviceMock;
        List<FMGRSAPI_OrdersShippingContainers_Rest.ShippingContainer> testData = new List<FMGRSAPI_OrdersShippingContainers_Rest.ShippingContainer>();
        FMGRSAPI_OrdersShippingContainers_Rest.ShippingContainer InputRecord = new FMGRSAPI_OrdersShippingContainers_Rest.ShippingContainer();
        testData.add(InputRecord);
        InputRecord.TrackingNumber = 'TestTrackingNumber!@#$`124';
        InputRecord.ContainerType='Test';
        InputRecord.SalesforceOrderId = FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType);
        InputRecord.ShipToAddress = new FMGRSAPI_OrdersShippingContainers_Rest.ShippingContainerAddress();
        InputRecord.ShipToAddress.City='Grants Pass';
        InputRecord.ShipToAddress.AddressLine1 = 'Good';
        InputRecord.ShipToAddress.AddressLine2 = 'Evil';
        InputRecord.Products = new List<FMGRSAPI_OrdersShippingContainers_Rest.ShippingContainerItem>();
        FMGRSAPI_OrdersShippingContainers_Rest.ShippingContainerItem product = new FMGRSAPI_OrdersShippingContainers_Rest.ShippingContainerItem();
        product.Quantity=10;
        product.SalesforceOrderLineId=FMG_TestUtility.getFakeId(rstk__soline__c.SObjectType);
        InputRecord.Products.add(product);
        Test.startTest();
        FMGRSAPI_OrdersShippingContainers_Rest.doPost(testData);
        Test.stopTest();


        System.debug(JSON.serializePretty(testData));
        System.debug(JSON.serializePretty(serviceMock));
        System.assertEquals(testData.size(),serviceMock.GenerateContainersPramater.size());
        FMGRSAPI_Orders_Service.ShippingContainer resultedData = serviceMock.GenerateContainersPramater[0];

        System.assertEquals(InputRecord.Products.size(),resultedData.Products.size());
        System.assertEquals(InputRecord.Products[0].SalesforceOrderLineId,resultedData.Products[0].SalesforceOrderLineId);
        System.assertEquals(InputRecord.Products[0].Quantity,resultedData.Products[0].Quantity);

        System.assertNotEquals(null,resultedData.ShipToAddress);

        System.assertEquals(InputRecord.SalesforceOrderId,resultedData.SalesforceOrderId);
        System.assertEquals(InputRecord.ContainerType,resultedData.ContainerType);
        System.assertEquals(InputRecord.TrackingNumber,resultedData.TrackingNumber);
        System.assertEquals(InputRecord.ShipToAddress.City,resultedData.ShipToAddress.City);
        System.assertEquals(InputRecord.ShipToAddress.AddressLine1,resultedData.ShipToAddress.Address1);
        System.assertEquals(InputRecord.ShipToAddress.AddressLine2,resultedData.ShipToAddress.Address2);
    }


    class FMGRSAPI_Orders_ServiceMock implements FMGRSAPI_Orders_ServiceInterface{

        public List<String> processOrders(List<FMGRSAPI_Orders_Service.ProcessOrderEvent> orderEvents, Boolean isBackground) {
                    List<String> returnObject = new List<String>();
            for(FMGRSAPI_Orders_Service.ProcessOrderEvent event: orderEvents){
                returnObject.add(JSON.serialize(event));
            }
            return returnObject;
        }

        public FMGRSAPI_Orders_Service.BatchData getOrdersByBatchId(Integer batchId) {
            FMGRSAPI_Orders_Service.BatchData response = new FMGRSAPI_Orders_Service.BatchData();
            response.BatchId = batchId;
            response.Orders = new List<FMGRSAPI_Orders_Service.OrderInfo>();
            System.debug(JSON.serializePretty(response));
            return response;
        }

        /**
         * @param size Value to be returned
         *
         * @return size Is the return value
         **/
        public Integer generateOrderBatch(Integer size) {
            return size;
        }

        public FMGRSAPI_Orders_Service.BatchData getOrdersById(List<Id> orderIds) {

            FMGRSAPI_Orders_Service.BatchData response = new FMGRSAPI_Orders_Service.BatchData();
            response.BatchId = -1;
            response.Orders = new List<FMGRSAPI_Orders_Service.OrderInfo>();
            for(Id orderId:orderIds){
                FMGRSAPI_Orders_Service.OrderInfo newOrder =new FMGRSAPI_Orders_Service.OrderInfo();
                newOrder.BatchId=1;
                newOrder.Id = orderId;
                response.Orders.add(newOrder);
            }

            return response;
        }

        public List<FMGRSAPI_Orders_Service.ShippingContainer> GenerateContainersPramater{get;set;}
        public Map<String, Object> generateContainers(List<FMGRSAPI_Orders_Service.ShippingContainer> packages) {
            GenerateContainersPramater = packages;
            System.debug(JSON.serializePretty(packages));
            Map<String,Object> extendedInfo = new Map<String, Object>();
            return extendedInfo;
        }


        public FMGRSAPI_Orders_Service.OrderItemReversal reduceLineQtyExceptionObject{get;set;}
        public FMGRSAPI_Orders_Service.ReduceLineQtyResults reduceLineQty(Id salesOrderLine, Decimal qty) {
            if(reduceLineQtyExceptionObject != null){
                FMGRSAPI_Orders_Service.ExceededMaxRemovalException testException =
                        new FMGRSAPI_Orders_Service.ExceededMaxRemovalException();
                testException.ReversalItem = reduceLineQtyExceptionObject;
                throw testException;
            }
            FMGRSAPI_Orders_Service.ReduceLineQtyResults testData = new FMGRSAPI_Orders_Service.ReduceLineQtyResults();
            testData.Ids = new List<Id>();
            testData.ReRun=false;
            return testData;
        }

        public void updateFmgExtendedHeaderFields(List<FMGRSAPI_Orders_Service.updateFmgExtendedHeader> records) {
        }

        public void updateOrderShippingHeaders(List<FMGRSAPI_Orders_Service.ShippingHeader> headers) {
        }
    }
}