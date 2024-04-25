global class ScheduleBatch_CDP implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Start the batch job
        CDP_Configuration_Setting__mdt getCDPConfig = [SELECT Id,MasterLabel, DaysAgo__c from CDP_Configuration_Setting__mdt where MasterLabel = 'CDP Config' limit 1];

        UpdatePlatinumAttributesFromCDPBatch cdpbatch = new UpdatePlatinumAttributesFromCDPBatch(integer.valueof(getCDPConfig.DaysAgo__c));
        database.executeBatch(cdpbatch, 20);
    }
}