@isTest
public class Test_Schedule_OciApiCallout {
    @isTest 
    public static void testMethodSchedule8(){ 
        Test.startTest(); 
        String cronExp ='0 48 * * * ?'; 
        System.schedule('JobName', cronExp, new Schedule_OciApiCallouts8()); 
        Test.stopTest(); 
    } 
    
    @isTest 
    public static void testMethodSchedule7(){ 
        Test.startTest(); 
        String cronExp ='0 48 * * * ?'; 
        System.schedule('JobName', cronExp, new Schedule_OciApiCallouts7()); 
        Test.stopTest(); 
    } 
    
    @isTest 
    public static void testMethodSchedule6(){ 
        Test.startTest(); 
        String cronExp ='0 48 * * * ?'; 
        System.schedule('JobName', cronExp, new Schedule_OciApiCallouts6()); 
        Test.stopTest(); 
    } 
    
     @isTest 
    public static void testMethodSchedule5(){ 
        Test.startTest(); 
        String cronExp ='0 48 * * * ?'; 
        System.schedule('JobName', cronExp, new Schedule_OciApiCallouts5()); 
        Test.stopTest(); 
    } 
    
    @isTest 
    public static void testMethodSchedule4(){ 
        Test.startTest(); 
        String cronExp ='0 48 * * * ?'; 
        System.schedule('JobName', cronExp, new Schedule_OciApiCallouts4()); 
        Test.stopTest(); 
    } 
    
    @isTest 
    public static void testMethodSchedule3(){ 
        Test.startTest(); 
        String cronExp ='0 48 * * * ?'; 
        System.schedule('JobName', cronExp, new Schedule_OciApiCallouts3()); 
        Test.stopTest(); 
    } 
    
    @isTest 
    public static void testMethodSchedule2(){ 
        Test.startTest(); 
        String cronExp ='0 48 * * * ?'; 
        System.schedule('JobName', cronExp, new Schedule_OciApiCallouts2()); 
        Test.stopTest(); 
    } 
    
     @isTest 
    public static void testMethodSchedule(){ 
        Test.startTest(); 
        String cronExp ='0 48 * * * ?'; 
        System.schedule('JobName', cronExp, new Schedule_OciApiCallouts()); 
        Test.stopTest(); 
    } 
}