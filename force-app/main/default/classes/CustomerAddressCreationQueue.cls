public class CustomerAddressCreationQueue implements Queueable, Database.AllowsCallouts {
    private List<Account> accountList;
    public CustomerAddressCreationQueue(List<Account> accountList) {
        this.accountList = accountList;
    }
    public void execute(QueueableContext queCont) {
        B2CPersonAccountTriggerHelper.createCustomerAddressesForAccounts(accountList);
    }

}