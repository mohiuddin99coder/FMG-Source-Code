@isTest
public class Test_Schedule_BatchLeadConversion {
 @isTest 
    public static void testMethodSchedule8(){ 
        Test.startTest(); 
        String cronExp ='0 0 * * * ?'; 
        System.schedule('JobName', cronExp, new Schedule_BatchLeadConversion()); 
        Test.stopTest(); 
    } 
}