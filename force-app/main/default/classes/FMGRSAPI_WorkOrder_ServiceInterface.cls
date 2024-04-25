public interface FMGRSAPI_WorkOrder_ServiceInterface {
    FMGRSAPI_WorkOrder_Service.WorkOrderBatch getBatchData(Integer batchId);
    Integer generateWorkOrderBatch(Integer batchSize);
    List<FMGRSAPI_WorkOrder_Service.WorkOrder> getWorkOrders(List<Id> workOrderIds);
}