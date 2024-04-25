@isTest
public class Lead28days_Test {

    @isTest
    static void LeadSourceCatalog(){
        
        Trigger_Switch__c onTrigger = new Trigger_Switch__c(Name='Lead Trigger');
        onTrigger.IsActive__c = True ;
        insert onTrigger ;
        
        LeadPreventionDays__c LeadDays = new LeadPreventionDays__c();
        LeadDays.No_Of_Days__c = '95';
        LeadDays.Name = 'Prevent Catalog Request';
        insert LeadDays;
        
        LeadPreventionDays__c PLdays = new LeadPreventionDays__c();
        PLdays.No_Of_Days__c = '30';
        PLdays.Name = 'Prevent Platinum Request';
        insert PLdays;

        
        Lead testLeadOne = new Lead();
        testLeadOne.LastName = 'Test Lead';
        testLeadOne.Email = 'nivi1@gmail.com';
        testLeadOne.Status= 'New';
        testLeadOne.LeadSource = 'Catalog Request';
        testLeadOne.CreatedDate = System.now();
        
        
        Lead testLeadTwo = new Lead();
        testLeadTwo.LastName = 'Test Lead';
        testLeadTwo.Email = 'testLead230@etg.com';
        testLeadTwo.Status= 'New';
        testLeadTwo.LeadSource = 'Catalog Request';
        testLeadTwo.CreatedDate = System.now();
        
        List<Lead> leadList = new List<Lead>{testLeadOne ,testLeadTwo };
        insert leadList ;
            
        Test.startTest();
        
        Lead28dayshandler.checkForDuplicatesOfCatalog(leadList);
            
        Test.stopTest();   
        
        System.assertEquals(2, leadList.size());
              
      }
    
        @isTest
        static void LeadSourcePlatinum(){
            
        Trigger_Switch__c onTrigger = new Trigger_Switch__c(Name='Lead Trigger');
        onTrigger.IsActive__c = True ;
        insert onTrigger ;
            
        LeadPreventionDays__c LeadDays = new LeadPreventionDays__c();
        LeadDays.No_Of_Days__c = '95';
        LeadDays.Name = 'Prevent Catalog Request';
        insert LeadDays;
        
        LeadPreventionDays__c PLdays = new LeadPreventionDays__c();
        PLdays.No_Of_Days__c = '30';
        PLdays.Name = 'Prevent Platinum Request';
        insert PLdays;

        Lead testLeadOne = new Lead();
        testLeadOne.LastName = 'Test Lead';
        testLeadOne.Email = 'nivi1@gmail.com';
        testLeadOne.Phone = '9876543210';    
        testLeadOne.Status= 'New';
        testLeadOne.LeadSource = 'Platinum Program';
        testLeadOne.Platinum_Catalog_Requested__c = True ;
        testLeadOne.CreatedDate = System.now();
        
        Lead testLeadTwo = new Lead();
        testLeadTwo.LastName = 'Test Lead';
        testLeadTwo.Email = 'testLead2500@etg.com';
        testLeadTwo.Status= 'New';
        testLeadTwo.LeadSource = 'Platinum Program';
        testLeadOne.Platinum_Catalog_Requested__c = True ;
        testLeadTwo.CreatedDate = System.now();
        
        List<Lead> leadList = new List<Lead>{testLeadOne ,testLeadTwo };
        insert leadList ;   
         
        
            
        Test.startTest();
        
        Lead28dayshandler.checkForDuplicatesOfPlatinum(leadList);
       
        Test.stopTest();
                    
        System.assertEquals(2, leadList.size());      
        //System.assertEquals('A Catalog Requested Lead with this email address already exists and cannot be recreated until 28 days have passed since the most recent Lead was created.', leadList[0].Errors[0].getMessage());    
        }     
   /*@isTest
    static void LeadSourceCatalogAddresses(){
        
        Trigger_Switch__c onTrigger = new Trigger_Switch__c(Name='Lead Trigger');
        onTrigger.IsActive__c = True ;
        insert onTrigger ;
       
        
        Lead TestDuplicateCatalogAddress = new Lead();
        TestDuplicateCatalogAddress.LastName = 'Test Lead Heritage';
        TestDuplicateCatalogAddress.Email = 'heritageroad@example.com';
        TestDuplicateCatalogAddress.Status = 'New';
        TestDuplicateCatalogAddress.LeadSource = 'Catalog Request';
        TestDuplicateCatalogAddress.CreatedDate = System.now();
        TestDuplicateCatalogAddress.Street = ' 2241 Heritage Road';
        TestDuplicateCatalogAddress.City = 'Terrell';
        TestDuplicateCatalogAddress.StateCode = 'CA';
        TestDuplicateCatalogAddress.PostalCode = '75160';
        TestDuplicateCatalogAddress.CountryCode = 'US';
        TestDuplicateCatalogAddress.APT_Suite__c = '0001';
        insert TestDuplicateCatalogAddress;
        
        try{
       Lead TestDuplicateCatalogAddress1 = new Lead();
       TestDuplicateCatalogAddress1.LastName = 'Test Lead Heritage';
        TestDuplicateCatalogAddress1.Email = 'secondheritageroad@example.com';
        TestDuplicateCatalogAddress1.Status = 'New';
        TestDuplicateCatalogAddress1.LeadSource = 'Catalog Request';
        TestDuplicateCatalogAddress1.CreatedDate = System.now();
        TestDuplicateCatalogAddress1.Street = ' 2241 Heritage Road';
        TestDuplicateCatalogAddress1.City = 'Terrell';
        TestDuplicateCatalogAddress1.StateCode = 'CA';
        TestDuplicateCatalogAddress1.PostalCode = '75160';
        TestDuplicateCatalogAddress1.CountryCode = 'US';
        TestDuplicateCatalogAddress1.APT_Suite__c = '0001';
        insert TestDuplicateCatalogAddress1;
        }catch(exception e){
            System.debug(e.getMessage());
        }
        
      }
    @isTest
    static void LeadSourcePlatinumAddresses(){
        
        Trigger_Switch__c onTrigger = new Trigger_Switch__c(Name='Lead Trigger');
        onTrigger.IsActive__c = True ;
        insert onTrigger ;
       
        
        Lead TestDuplicatePlatinumAddress = new Lead();
        TestDuplicatePlatinumAddress.LastName = 'Test Lead Heritage';
        TestDuplicatePlatinumAddress.Email = 'tesleadheritage@example.com';
        TestDuplicatePlatinumAddress.Status = 'New';
        TestDuplicatePlatinumAddress.LeadSource = 'Platinum Program';
        TestDuplicatePlatinumAddress.CreatedDate = System.now();
        TestDuplicatePlatinumAddress.Street = ' 2241 Heritage Road';
        TestDuplicatePlatinumAddress.City = 'Terrell';
        TestDuplicatePlatinumAddress.StateCode = 'CA';
        TestDuplicatePlatinumAddress.PostalCode = '75160';
        TestDuplicatePlatinumAddress.CountryCode = 'US';
        TestDuplicatePlatinumAddress.APT_Suite__c = '000';
        TestDuplicatePlatinumAddress.Phone = '9876543210';
        TestDuplicatePlatinumAddress.Platinum_Catalog_Requested__c = true;
        TestDuplicatePlatinumAddress.Catalog_Status__c = 'Requested';
        TestDuplicatePlatinumAddress.Catalog_Requested__c = true;
        insert TestDuplicatePlatinumAddress;
        try{
        Lead TestDuplicatePlatinumAddress1 = new Lead();
        TestDuplicatePlatinumAddress1.LastName = 'Test Lead Heritage';
        TestDuplicatePlatinumAddress1.Email = 'tesleadheritage@example.com';
        TestDuplicatePlatinumAddress1.Status = 'New';
        TestDuplicatePlatinumAddress1.LeadSource = 'Platinum Program';
        TestDuplicatePlatinumAddress1.CreatedDate = System.now();
        TestDuplicatePlatinumAddress1.Street = ' 2241 Heritage Road';
        TestDuplicatePlatinumAddress1.City = 'Terrell';
        TestDuplicatePlatinumAddress1.StateCode = 'CA';
        TestDuplicatePlatinumAddress1.PostalCode = '75160';
        TestDuplicatePlatinumAddress1.CountryCode = 'US';
        TestDuplicatePlatinumAddress1.APT_Suite__c = '000';
        TestDuplicatePlatinumAddress1.Phone = '9876543210';
        TestDuplicatePlatinumAddress1.Preferred_Contact_Method__c = 'Phone';    
        TestDuplicatePlatinumAddress1.Platinum_Catalog_Requested__c = true;
        TestDuplicatePlatinumAddress1.Catalog_Status__c = 'Requested';
        TestDuplicatePlatinumAddress1.Catalog_Requested__c = true;
        insert TestDuplicatePlatinumAddress1;
        }catch(exception e){
            System.debug(e.getMessage());
        }
       
      }*/
    
}