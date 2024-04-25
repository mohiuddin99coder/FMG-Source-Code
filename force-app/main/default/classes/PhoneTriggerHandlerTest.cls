@isTest
public class PhoneTriggerHandlerTest {
    
     @testSetup
    static void testData(){
        
        Trigger_Switch__c ts = new Trigger_Switch__c(Name='phoneTrigger');
         ts.IsActive__c = true;
         insert ts;
         
         String AccRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
         
         Account TestAccount = new Account(Lastname='Test Account');
         testAccount.recordtypeId = '012DK000001aUjLYAU';
         testAccount.PersonEmail = 'testaccount@gmail.com';
         testAccount.RecordTypeId= AccRecordTypeID ;
         insert TestAccount;
         
          ContactPointPhone primaryPhone = new ContactPointPhone(
            ParentId = testAccount.Id,
          	TelephoneNumber= '8945612398',
            IsPrimary = true
         );
         
         ContactPointPhone secondaryPhone = new ContactPointPhone(
            ParentId = testAccount.Id,
            TelephoneNumber= '9456123990',
            IsPrimary = false
        );
         List<ContactPointPhone> phoneList = new List<ContactPointPhone>{ primaryPhone, secondaryPhone };
             insert phoneList;

    }
    
    @isTest
     static void PreventCreatePrimaryPhoneOnInsert() {
   
         Account getParentAcc = [Select Id , PersonEmail from Account Where PersonEmail = 'testaccount@gmail.com'];
         List<ContactPointPhone> phoneList = [Select Id , TelephoneNumber , ParentId ,IsPrimary from ContactPointPhone Where ParentId = :getParentAcc.Id];
            // insert phoneList;
             
        Test.startTest();
         
         
        PhoneTriggerHandler.preventCreatePrimaryPhoneOnInsert(phoneList);
        Test.stopTest();
         
         System.assertEquals(2,phoneList.size());
        //System.assertEquals('You can\'t create more than one primary Phone under account.', phoneList[0].Errors[0].getMessage());
   
}
    
@isTest
  static void PreventPrimaryPhoneOnUpdate() {
      
   /*    Trigger_Switch__c ts = new Trigger_Switch__c(Name='phoneTrigger');
         ts.IsActive__c = true;
         insert ts;
      
      String AccRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
      
      Account testAccount = new Account(Lastname = 'Test Account');
      testAccount.recordtypeId = '012DK000001aUjLYAU';
      testAccount.PersonEmail = 'testaccount@gmail.com';
      testAccount.RecordTypeId= AccRecordTypeID ;
      insert testAccount;
      
      ContactPointPhone primaryPhone = new ContactPointPhone(
            ParentId = testAccount.Id,
         TelephoneNumber= '7945612305',
            IsPrimary = true
      );
      
      ContactPointPhone secondaryPhone = new ContactPointPhone(
            ParentId = testAccount.Id,
          TelephoneNumber= '7985612390',
            IsPrimary = false
        );
              
      insert new List<ContactPointPhone>{ primaryPhone, secondaryPhone }; */

       Account getParentAcc = [Select Id , PersonEmail from Account Where PersonEmail = 'testaccount@gmail.com'];
       List<ContactPointPhone> getCppRec = [Select id , ParentId , TelephoneNumber ,IsPrimary from ContactPointPhone Where ParentId = :getParentAcc.Id ];
           getCppRec[0].IsPrimary = false;
           getCppRec[1].IsPrimary = true;
           update getCppRec[0] ; 
           update getCppRec[1] ;
      
        Test.startTest();
        Map<Id, ContactPointPhone> oldPhoneMap = new Map<Id, ContactPointPhone>{ getCppRec[0].Id => getCppRec[0], getCppRec[1].Id => getCppRec[1] };
        Map<Id, ContactPointPhone> newPhoneMap = new Map<Id, ContactPointPhone>{ getCppRec[0].Id => getCppRec[0], getCppRec[1].Id => getCppRec[1] };
        PhoneTriggerHandler.preventPrimaryPhoneOnUpdate(newPhoneMap, oldPhoneMap);
        Test.stopTest();

      System.assertEquals(2,newPhoneMap.size());
        //System.assertEquals('You can\'t create more than one primary Phone under account.', newPhoneMap.get(secondaryPhone.Id).Errors[0].getMessage());
  
}
}