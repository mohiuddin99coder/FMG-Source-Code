@isTest
public class Test_Schedule_InventoryCheck {
 @isTest 
    public static void testMethodSchedule8(){ 
        Test.startTest(); 
        String cronExp ='0 0 * * * ?'; 
        System.schedule('JobName', cronExp, new Schedule_InventoryCheck()); 
        Test.stopTest(); 
    } 
}