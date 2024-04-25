public class updateCustomerAddressQueue implements Queueable, Database.AllowsCallouts {
    private List<Customer_Address__c> customerAddressList;
    private List<ID> accIdList;
    public updateCustomerAddressQueue(List<Customer_Address__c> customerAddressList,List<ID> accIdList) {
        this.customerAddressList = customerAddressList;
        this.accIdList = accIdList;
    }
    public void execute(QueueableContext queCont) {
        CustomerAddressTriggerHandler.sendCustomerAddressUpdateRequest(customerAddressList,accIdList);
    }
}