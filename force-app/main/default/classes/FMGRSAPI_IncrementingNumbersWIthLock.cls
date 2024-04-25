/**
 * Created by inscorea on 6/13/2023.
 */

public with sharing class FMGRSAPI_IncrementingNumbersWIthLock {
    /**
         * @description This value is for the Incrementing number that is generated with new batches
         **/
    @TestVisible
    private String incrementId = null;

    /**
     * This is the default value used if null is passed in on the constructor
     **/
    private static final String defaultIncrementId = 'default';

    /**
     * The sObject that contains the current value
     **/
    private fmgincrement__c BatchId = null;

    /**
     * Indicates if the action needs to be saved before going to the next
     * Default is true so the first execution of getNext will generate a value
     **/
    private Boolean isSaved = true;

    /**
     * @param incrementId The name that is used for looking the given incrementing value
     **/
    public FMGRSAPI_IncrementingNumbersWIthLock(String incrementId){
        if(incrementId == null){
            incrementId = defaultIncrementId;
        }
        this.incrementId = incrementId;
    }

    /**
     * @description Gets the next value to be used. If first time it will start at 0
     **/
    public void getNext(){

        // Gets the next
        List<fmgincrement__c> BatchIds = [SELECT Id, value__c FROM fmgincrement__c WHERE LookupName__c = :incrementId FOR UPDATE ];

        // If there is no record then create one
        if(BatchIds.isEmpty()){
            fmgincrement__c newBatchId = new fmgincrement__c();
            newBatchId.LookupName__c = incrementId;
            newBatchId.value__c = 0;

            insert newBatchId;
            // Do a second pull to make sure there is a lock
            BatchId = [SELECT Id, value__c FROM fmgincrement__c WHERE LookupName__c = :incrementId FOR UPDATE ];
        } else {

            BatchId = BatchIds[0];
            BatchId.value__c = BatchId.value__c+1;
        }

        update BatchId;
    }

    /**
     * @return The current value the system is holding
     **/
    public Integer value{
        get{
            // If getNext is not called the BatchId will be null and if not checked then it will error if it trying to pull the value.
            if(BatchId == null){
                return null;
            }
            return Integer.valueOf(BatchId.value__c);
        }
    }
}