/**
 * Created by inscorea on 6/13/2023.
 */

@IsTest
private class FMGRSAPI_IncrementingNumbersWIthLockTest {
    private static final String testId = 'TestId';


    @IsTest
    static void defaultValueCheck() {
        String value;
        Test.startTest();
        FMGRSAPI_IncrementingNumbersWIthLock batchId = new FMGRSAPI_IncrementingNumbersWIthLock(null);
        value = batchId.incrementId;
        Test.stopTest();
        System.assert('default' == value);
    }
    @IsTest
    static void basicGeneration() {

        List<fmgincrement__c> initialSize; // No Records
        List<fmgincrement__c> endSize; // 1 Record
        Integer val1; // Should be null or Exception??
        Integer val2; // Should be 0
        Integer val3; // Should be 0
        Integer val4; // Should be 1
        Test.startTest();

        initialSize = [SELECT Id FROM fmgincrement__c WHERE LookupName__c = :testId];
        FMGRSAPI_IncrementingNumbersWIthLock batchId = new FMGRSAPI_IncrementingNumbersWIthLock(testId);
        val1 = batchId.value;
        batchId.getNext();
        val2 = batchId.value;
        batchId.getNext();
        val3 = batchId.value;
        batchId.getNext();
        val4 = batchId.value;
        endSize = [SELECT Id FROM fmgincrement__c WHERE LookupName__c = :testId];

        System.debug('initialSize: ' + initialSize);
        System.debug('endSize: ' + endSize);
        System.debug('val1: ' + val1);
        System.debug('val2: ' + val2);
        System.debug('val3: ' + val3);
        System.debug('val4: ' + val4);

        Test.stopTest();
        System.assertEquals(true,initialSize.isEmpty(),'Initial Size Not Empty');
        System.assertNotEquals(0,endSize.size(),'End Size should have data');
        System.assertEquals(null,val1,'val1');
        System.assertEquals(0,val2,'val2');
        System.assertEquals(1,val3,'val3');
        System.assertEquals(2,val4,'val4');
        if(!endSize.isEmpty()){
            delete endSize;
        }
    }
}