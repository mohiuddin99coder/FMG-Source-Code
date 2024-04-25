/**
 * Created by Adam-Hotmail on 5/26/2023.
 */

@IsTest
private class FMGRSAPI_Orders_RestTest {

    @IsTest
    static void getOrdersMissingIdTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/fmgrsapi/orders'; //Request URL
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        FMGRSAPI_Orders_Service_ServiceMock serviceMock = new FMGRSAPI_Orders_Service_ServiceMock();
        FMGRSAPI_Orders_Rest.ordersService = serviceMock;

        FMGRSAPI_Orders_Rest.getOrders();

        System.assertEquals(200,RestContext.response.statusCode);
        System.assertEquals('application/json',RestContext.response.headers.get('Content-Type'));
        System.assertEquals('[]',RestContext.response.responseBody.toString());
    }
    @IsTest
    static void getOrdersNoIdTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/fmgrsapi/orders'; //Request URL
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        FMGRSAPI_Orders_Service_ServiceMock serviceMock = new FMGRSAPI_Orders_Service_ServiceMock();
        FMGRSAPI_Orders_Rest.ordersService = serviceMock;

        List<String> testOrderIds = new List<String>();
        req.params.put('Id',String.join(new List<String>(testOrderIds),','));

        FMGRSAPI_Orders_Rest.getOrders();

        System.assertEquals(200,RestContext.response.statusCode);
        System.assertEquals('application/json',RestContext.response.headers.get('Content-Type'));
        System.assertEquals('[]',RestContext.response.responseBody.toString());
    }

    @IsTest
    static void getOrders2IdTest() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/fmgrsapi/orders'; //Request URL
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        FMGRSAPI_Orders_Service_ServiceMock serviceMock = new FMGRSAPI_Orders_Service_ServiceMock();
        FMGRSAPI_Orders_Rest.ordersService = serviceMock;

        List<String> testOrderIds = new List<String>();
        testOrderIds.add(FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType));
        testOrderIds.add(FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType));
        req.params.put('Id',String.join(new List<String>(testOrderIds),','));

        Test.startTest();
        FMGRSAPI_Orders_Rest.getOrders();
        Test.stopTest();

        for(FMGRSAPI_Orders_Service.OrderInfo order: FMGRSAPI_Orders_Rest.getOrdersTestResponse.Orders ){
            System.assert(testOrderIds.contains(order.OrderNumber));
        }

        System.assertEquals(200,RestContext.response.statusCode);
        System.assertEquals('application/json',RestContext.response.headers.get('Content-Type'));


    }

    @IsTest
    static void BasicUpdateOrderAttributesTest() {

        FMGRSAPI_Orders_Service ordersService = new FMGRSAPI_Orders_Service();
        FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock mockData = new FMGRSAPI_MockClasses.FMGRSAPI_Orders_Service_DataMock();
        ordersService.ordersServiceDataAccessOverride = (FMGRSAPI_Orders_Service_DataInterface)mockData;
        List<fmgsohdrext__c> getFmgExtendedHeadersResponseData = new List<fmgsohdrext__c>();


        fmgsohdrext__c record = new fmgsohdrext__c();
        record.Id = FMG_TestUtility.getFakeId(fmgsohdrext__c.SObjectType,'testRecord');
        record.IsEmployee__c = false;
        record.IsFacility__c = false;
        record.IsHazardous__c = false;
        record.IsLightweight__c = false;
        record.IsOverweight__c = false;
        record.IsPlatinum__c = false;
        record.batchId__c = -2;
        //record.fmgsohdrext_sohdr__c = (String)FMG_TestUtility.getFakeId(rstk__sohdr__c.SObjectType,'testRecord');
        getFmgExtendedHeadersResponseData.add(record);

        mockData.getFmgExtendedHeadersRaw = getFmgExtendedHeadersResponseData;




        List<FMGRSAPI_Orders_Rest.UpdateData> UpdateCollection = new List<FMGRSAPI_Orders_Rest.UpdateData>();
        FMGRSAPI_Orders_Rest.UpdateData updateData = new FMGRSAPI_Orders_Rest.UpdateData();
        //updateData.Id = record2.fmgsohdrext_sohdr__c;
        updateData.IsEmployee= true;
        updateData.IsOverweight= true;
        updateData.IsHazardous= true;
        updateData.IsLightweight= true;
        updateData.IsPlatinum= true;
        updateData.IsForeign= true;
        updateData.IsFacility=false;
        UpdateCollection.add(updateData);


        FMGRSAPI_Orders_Rest.ordersService = ordersService;

        Test.startTest();
        FMGRSAPI_Orders_Rest.patchOrders(UpdateCollection);
        Test.stopTest();


        Assert.areNotEqual(0,mockData.updateFmgExtendedHeadersFieldsResponse.size());
        fmgsohdrext__c updatedRecord = mockData.updateFmgExtendedHeadersFieldsResponse[0];


        system.debug(Json.serializePretty(updatedRecord));

        Assert.areEqual(true,updatedRecord.IsEmployee__c,'Is Employee');
        Assert.areEqual(false,updatedRecord.IsFacility__c,'Is Facility');
        Assert.areEqual(true,updatedRecord.IsHazardous__c,'Is Hazardous');
        Assert.areEqual(true,updatedRecord.IsLightweight__c,'Is Lightweight');
        Assert.areEqual(true,updatedRecord.IsOverweight__c,'Is Overweight');
        Assert.areEqual(true,updatedRecord.IsPlatinum__c,'Is Platinum');
        Assert.areEqual(true,updatedRecord.IsForeign__c,'Is Foreign');

    }


    class FMGRSAPI_Orders_Service_ServiceMock implements FMGRSAPI_Orders_ServiceInterface
    {


        public List<String> processOrders(List<FMGRSAPI_Orders_Service.ProcessOrderEvent> orderEvents, Boolean isBackground) {
            return null;
        }

        public FMGRSAPI_Orders_Service.BatchData getOrdersByBatchId(Integer batchId) {
            return null;
        }

        public Integer generateOrderBatch(Integer size) {
            return 0;
        }

        public FMGRSAPI_Orders_Service.BatchData getOrdersById(List<Id> orderIds) {
            FMGRSAPI_Orders_Service.BatchData batchData = new FMGRSAPI_Orders_Service.BatchData();
            batchData.BatchId=-1;
            batchData.Orders = new  List<FMGRSAPI_Orders_Service.OrderInfo>();
            for(String orderId: orderIds){
                FMGRSAPI_Orders_Service.OrderInfo newOrder = new FMGRSAPI_Orders_Service.OrderInfo();
                newOrder.OrderNumber = orderId;
            }
            return batchData;
        }

        public Map<String, Object> generateContainers(List<FMGRSAPI_Orders_Service.ShippingContainer> packages) {
            return null;
        }

        public FMGRSAPI_Orders_Service.ReduceLineQtyResults reduceLineQty(Id salesOrderLine, Decimal qty) {
            return null;
        }

        public void updateFmgExtendedHeaderFields(List<FMGRSAPI_Orders_Service.updateFmgExtendedHeader> records) {

        }

        public void updateOrderShippingHeaders(List<FMGRSAPI_Orders_Service.ShippingHeader> headers) {
        }
    }

}