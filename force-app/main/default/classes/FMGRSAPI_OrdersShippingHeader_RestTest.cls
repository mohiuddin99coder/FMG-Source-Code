/**
 * Created by Adam-Hotmail on 10/12/2023.
 */

@IsTest
private class FMGRSAPI_OrdersShippingHeader_RestTest {
    @IsTest
    static void callTest() {
        FMGRSAPI_Orders_ServiceMock mockService =new FMGRSAPI_Orders_ServiceMock();
        FMGRSAPI_OrdersShippingHeader_Rest.ordersService = (FMGRSAPI_Orders_ServiceInterface)mockService;


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/fmgrsapi/orders/shippingHeader'; //Request URL
        req.httpMethod = 'POST';

        List<FMGRSAPI_OrdersShippingHeader_Rest.ShipperHeader> testData = new List<FMGRSAPI_OrdersShippingHeader_Rest.ShipperHeader>();
        FMGRSAPI_OrdersShippingHeader_Rest.ShipperHeader header = new FMGRSAPI_OrdersShippingHeader_Rest.ShipperHeader();
        header.ShippingAddress = new FMGRSAPI_OrdersShippingHeader_Rest.ShippingAddress();

        header.CarrierCode='UPS';
        header.ShipMethod='PICK-UP-DOOR';
        header.ShippingAddress.CustomerName = 'Adam Inscore';
        header.SalesforceOrderId = 'a7qDK000008qxRxYAI';
        testData.add(header);
        RestContext.request = req;
        RestContext.response= res;

        FMGRSAPI_OrdersShippingHeader_Rest.doPost(testData);

        System.assertEquals('Adam Inscore',mockService.convertedShippingContainers[0].ShippingAddress.CustName);
        System.assertEquals('a7qDK000008qxRxYAI',mockService.convertedShippingContainers[0].SalesforceOrderId);
        System.assertEquals(200,RestContext.response.statusCode);

    }


    class FMGRSAPI_Orders_ServiceMock implements FMGRSAPI_Orders_ServiceInterface{



        public void updateFmgExtendedHeaderFields(List<FMGRSAPI_Orders_Service.updateFmgExtendedHeader> records) {
        }

        public List<FMGRSAPI_Orders_Service.ShippingHeader> convertedShippingContainers;
        public void updateOrderShippingHeaders(List<FMGRSAPI_Orders_Service.ShippingHeader> headers) {
            convertedShippingContainers = headers;
        }

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
            return null;
        }

        public Map<String, Object> generateContainers(List<FMGRSAPI_Orders_Service.ShippingContainer> packages) {
            return null;
        }

        public FMGRSAPI_Orders_Service.ReduceLineQtyResults reduceLineQty(Id salesOrderLine, Decimal qty) {
            return null;
        }
    }
}