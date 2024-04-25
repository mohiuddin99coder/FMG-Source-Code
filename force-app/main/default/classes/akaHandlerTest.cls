@isTest
public class akaHandlerTest {
    
    @testSetup
    static void testData(){
        
        Trigger_Switch__c onTrigger = new Trigger_Switch__c(Name='akaTrigger');
        onTrigger.IsActive__c = True ;
        insert onTrigger ;
        
        String AccRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        // Inserting a test Account 
        Account myAccount = new Account();
        myAccount.LastName = 'parent Account';
        myAccount.PersonEmail = 'parent@etg.com';
        myAccount.RecordTypeId= AccRecordTypeID ;
        insert myAccount ;
        
        // Inserting AKA for an Account 
        
        //Primary AKA
        AKA__c firstAKA = new AKA__c();
        firstAKA.Name = 'Primary AKA';
        firstAKA.Customer__c = myAccount.Id ;
        firstAKA.Primary__c = True ;
         insert firstAKA;
        
        //Non-Primary AKA
        AKA__c secondAKA = new AKA__c();
        secondAKA.Name = 'Secondary AKA';
        secondAKA.Customer__c = myAccount.Id ;
        secondAKA.Primary__c = False ;
        insert secondAKA;

    }

    @isTest
    static void checkAkaPrimaryForInsertion(){
       
        List<AKA__c> akaList = [Select Id , Name , Primary__c , Customer__c from AKA__c where Name in ('Primary AKA' ,'Secondary AKA') ];
         
        Test.startTest();
        
        akaHandler.preventCreatePrimaryAKAOnInsert(akaList);
        
        Test.stopTest();
        
        System.assertEquals(2, akaList.size());
        
    }
    
   @isTest
    static void checkAkaPrimaryForUpdate(){

        List<AKA__c> akaList = [Select Id , Name , Customer__c ,Primary__c from AKA__c where Name in ('Primary AKA' ,'Secondary AKA') ];
        System.debug('Aka List ----------> ' + akaList );
        akaList[0].Primary__c = false ;
        akaList[1].Primary__c = true ;
        update akaList[0];
        update akaList[1];
        
        Test.startTest();
        
        System.debug('Prim AKa ---------->' + akaList[0]);
        
        Map<Id,AKA__c> AkaNewMap = new Map<Id,AKA__c>{akaList[0].Id => akaList[0] ,akaList[1].Id =>akaList[1] };
        Map<Id,AKA__c> AkaOldMap = new Map<Id,AKA__c>{akaList[0].Id => akaList[0] ,akaList[1].Id =>akaList[1] };
            
        akaHandler.preventPrimaryAkaOnUpdate(AkaNewMap ,AkaOldMap );
        
        Test.stopTest();
        
        System.assertEquals(2, AkaNewMap.size());
        
    } 
}