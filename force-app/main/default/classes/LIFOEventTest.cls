@isTest
public class LIFOEventTest {
    
    private static Integer fakeIdCount = 0;
    private static final String ID_PATTERN = '000000000000';
    
    public static Id generateRecordId(Schema.SObjectType sobject_type)
    {
        String key_prefix = sobject_type.getDescribe().getKeyPrefix();
        fakeIdCount++;
        
        String fake_id_prefix = ID_PATTERN.substring(0, 12 - fakeIdCount.format().length());
        
        return Id.valueOf(key_prefix + fake_id_prefix + fakeIdCount);
    }
    
    static testMethod void testLIFOEventID() 
    {
        Test.startTest();
        LIFO_Processing_Record_PE__e event = new LIFO_Processing_Record_PE__e();
        event.LIFO_Processing_ID__c = generateRecordId(rstk__sydata__c.getSObjectType());
        EventBus.publish(event);
        Test.getEventBus().deliver();
        System.assertNotEquals(event.LIFO_Processing_ID__c, null);
        Test.stopTest();
    }
    
    static testMethod void testLIFOEventNOID() 
    {
        Test.startTest();
        LIFO_Processing_Record_PE__e event = new LIFO_Processing_Record_PE__e();
        EventBus.publish(event);
        Test.getEventBus().deliver();
        System.assertEquals(event.LIFO_Processing_ID__c, null);
        Test.stopTest();
    }

}