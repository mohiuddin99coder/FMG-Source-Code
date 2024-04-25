global class BatchDeleteProcessedLeads implements Database.Batchable<sObject>{
global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id , CreatedDate FROM Lead WHERE Mapped_to_Existing_Account__c = true and CreatedDate < N_DAYS_AGO:30 LIMIT 9999' ;
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<Lead> scope) {
        try {
            if(scope.size()>0) {
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