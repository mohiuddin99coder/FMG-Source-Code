public class DateUtility {
    public static Integer NEXT_CHECKING_DAY = 84;
    
    public static String getDayOfWeek(dateTime inputDate){
        return inputDate.format('u');
    }
    public static Boolean isSaturday(dateTime inputDate){
        return (getDayOfWeek(inputDate)=='6')? true:false; 
    }
    public static Boolean isSunday(dateTime inputDate){
        return (getDayOfWeek(inputDate)=='7')? true:false;
    }
    public static Boolean isWeekend(Datetime inputDate){
        if(isSaturday(inputDate) || isSunday(inputDate)){
            return true;
        }
        return false;
    }
    public static Datetime getNextWeekDay(Datetime inputDate){
        if(isSaturday(inputDate)){
            return inputDate.addDays(2);
        }
        else if(isSunday(inputDate)){
            return inputDate.addDays(1);
        }
        return inputDate;
    }
    public static Boolean isWeekend(date inputDate){
        return isWeekend(Datetime.newInstance(inputDate.year(), inputDate.month(),inputDate.day()));
    }
    
    @InvocableMethod(label='populate Account Records with Next date' description='Returns the list of account Records with next Date populated' category='Account')
  public static List<Account> populateAccountNextDate(List<Account> accountList) {
      system.debug('% '+accountList);
      for(Account acc : accountList){
          system.debug('% '+acc);
          Datetime currentValue = acc.Next_84th_Day__c;
          dateTime futureValue = currentValue.addDays(NEXT_CHECKING_DAY);
          //dateTime futureValue = currentValue.addminutes(1);
          
          if(isWeekend(futureValue)){
              acc.Next_84th_Day__c = getNextWeekDay(futureValue);
          }else{
              system.debug('futureValue '+futureValue);
              acc.Next_84th_Day__c = futureValue;
          }
      }
      update accountList;
    return accountList;
  }
}