/**
 * Created by Adam-Hotmail on 6/6/2023.
 */

public interface FMGRSAPI_Orders_ServiceInterface {
    List<String> processOrders(List<FMGRSAPI_Orders_Service.ProcessOrderEvent> orderEvents,Boolean isBackground);
    FMGRSAPI_Orders_Service.BatchData getOrdersByBatchId(Integer batchId );
    Integer generateOrderBatch(Integer size);
    FMGRSAPI_Orders_Service.BatchData getOrdersById(List<Id> orderIds);
    Map<String, Object> generateContainers(List<FMGRSAPI_Orders_Service.ShippingContainer> packages);
    FMGRSAPI_Orders_Service.ReduceLineQtyResults reduceLineQty(Id salesOrderLine,Decimal qty);
    void updateFmgExtendedHeaderFields(List<FMGRSAPI_Orders_Service.updateFmgExtendedHeader> records);
    void updateOrderShippingHeaders(List<FMGRSAPI_Orders_Service.ShippingHeader> headers);
}