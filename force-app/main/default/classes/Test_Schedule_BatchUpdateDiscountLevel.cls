@isTest
public class Test_Schedule_BatchUpdateDiscountLevel {
@isTest 
    public static void testMethodScheduleDiscountLevel(){
        Test.startTest();
        String cronExpression = '0 0 0 * * ?';
        System.schedule('JobName', cronExpression, new ScheduleBatch_updateDiscountLevel());
        Test.stopTest(); 
    }
}