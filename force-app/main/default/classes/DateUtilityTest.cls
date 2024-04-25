@isTest
public class DateUtilityTest {
    
    @isTest
    public static void DateUtility(){
        dateTime sunday = System.Now();
        date sundayDate = Date.newInstance(sunday.year(), sunday.month(),sunday.day());
        System.debug(System.Now()-1);
        String AccRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        List<Account> accList = new List<Account>();
        for(integer i=0 ; i < 7 ; i++){
            Account acc = new Account();
            acc.LastName = 'test' + i ;
            acc.Next_84th_Day__c =System.Now() + i; 
            acc.RecordTypeId= AccRecordTypeID ;
            accList.add(acc);
            
        }
        
        insert accList;
        
        Test.startTest();
        
        DateUtility.getDayOfWeek(sunday);
        //System.debug('getDayOfWeek');
        DateUtility.isSaturday(sunday);
        //System.debug('isSaturday');
        DateUtility.isSunday(sunday);
        //System.debug('isSunday');
        DateUtility.isWeekend(sunday);
        // System.debug('isWeekend');
        DateUtility.getNextWeekDay(sunday);
        //System.debug('getNextWeekDay');
        DateUtility.isWeekend(sundayDate);
        DateUtility.populateAccountNextDate(accList);
        Test.stopTest();                  
    }
    
}