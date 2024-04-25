@isTest
public class TestScheduleBatch_CDP {
    
    @isTest 
    public static void ScheduleTestMethod(){ 
        Test.startTest(); 
        String cronExp ='0 0 * * * ?'; 
        System.schedule('JobName', cronExp, new ScheduleBatch_CDP()); 
        Test.stopTest(); 
    } 

}