global class BatchDeleteIntegrationLog implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, CreatedDate FROM Integration_Log__c WHERE CreatedDate < N_DAYS_AGO:30 LIMIT 9999';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Integration_Log__c> scope) {
        try {
            if(scope.size()>0) {
                system.debug('Integration Logs: ' + scope);
                delete scope;
            }
        }catch (Exception e) {
            // Handle exceptions and log errors
            System.debug('Error deleting leads: ' + e.getMessage());
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        // Additional finish logic if needed
    }
}