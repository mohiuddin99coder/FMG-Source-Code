/**
 * Created by Adam-Hotmail on 10/9/2023.
 */

public interface FMGRSAPI_Orders_Service_DataInterface {
    List<fmgsohdrext__c> getFmgExtendedHeaders(Set<String> ids);
    void updateFmgExtendedHeadersFields(List<fmgsohdrext__c> records);
    List<rstk__sohdr__c> queryOrdersById(List<Id> orderIds);
    List<OrderDeliveryGroupSummary> queryOrderDeliveryGroupSummaryData(List<String> orderNumbers);
    List<rstk__sohdr__c> processOrders_GetOrdersData(Set<Id> orderIds);
    List<rstk__sohdr__c> generateOrderBatch_GetOrdersData();
    List<fmgsohdrext__c> getOrdersByBatchIdData(Integer batchId);
    List<rstk__soship__c> getShippingHeadersData(Set<Id> orderIds);
    List<rstk__soshipline__c> getShippingDemandData(Set<Id> shipperIds);
    List<rstk__soship__c> getOpenShipperHeaderByOrderId(List<Id> orderId);
    void updateShipperHeaders(List<rstk__soship__c> headers);
    List<rstk__socarriervia__c> getShippingInfo(Set<String> carrierCodes, Set<String> shipMethods);
    List<Account> getAccountInfo(Set<Id> accountIds);
}