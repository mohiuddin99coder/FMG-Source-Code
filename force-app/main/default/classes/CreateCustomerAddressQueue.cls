public class CreateCustomerAddressQueue implements Queueable, Database.AllowsCallouts {
    private List<Customer_Address__c> customerAddressList;
    private List<ID> accIdList;
    public CreateCustomerAddressQueue(List<Customer_Address__c> customerAddressList,List<ID> accIdList) {
        this.customerAddressList = customerAddressList;
        this.accIdList = accIdList;
    }
    public void execute(QueueableContext queCont) {
        CustomerAddressTriggerHandler.sendCustomerAddressCreateRequest(customerAddressList,accIdList);
    }
}