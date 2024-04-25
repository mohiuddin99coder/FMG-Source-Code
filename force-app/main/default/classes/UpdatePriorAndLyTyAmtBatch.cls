global class UpdatePriorAndLyTyAmtBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'select id,Perf365Days__c,PerfCurrPeriodAmt__c,PerfPlanTotalAmt__c,PlatinumPriorPeriod__c from Account';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accountList) {
     //   CustomerUpdateBatchhandler.updatePriorAndLyTyAmt(accountList);
    }
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
}