/**
 * Created by Adam-Hotmail on 10/13/2023.
 */

public interface FMGRSAPI_WorkOrder_Service_DataInterface {
    List<fmgwoorddmdcst__c> getFMGWorkOrderComponentBatchData(Integer batchId);
    List<AggregateResult> getWorkOrderComponents_workOrderIdsData(Integer batchSize);
    List<rstk__woorddmd__c> getWorkOrderComponents_workOrdersItemsData(Set<Id> workOrderIds);
    List<rstk__wocst__c> getFMGWorkOrderComponent_WorkOrdersData(List<Id> Ids);

}