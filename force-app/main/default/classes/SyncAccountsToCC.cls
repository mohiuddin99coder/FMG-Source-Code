public class SyncAccountsToCC implements Queueable, Database.AllowsCallouts  {
    @testVisible
    private static Boolean doChainJob = true;
    private List<Account> accountList;
    public SyncAccountsToCC(List<Account> accountList) {
        this.accountList = accountList;
    }
    public void execute(QueueableContext queCont) {
        
        B2CPersonAccountTriggerHelper.processAccounts(accountList);
        if(doChainJob){
        System.enqueueJob(new CustomerAddressCreationQueue(accountList));
        }
    }
}