@isTest
public class B2CPersonAccountTriggerHelperTest {
    @testSetup
    static void createData(){
        B2C_Client_ID__c clientId = new B2C_Client_ID__c();
        clientId.JWT_Certificate_Name__c = 'bkcr';
        clientId.Name='test';
        insert clientId;
        
        B2C_AuthToken__c token = new B2C_AuthToken__c();
        //      token.Is_Valid__c = true;
        //      token.Is_Expired__c = false;
        token.B2C_AuthToken__c = '12345';
        token.Is_Invalidated__c = false;
        token.B2C_Client_ID__c=clientId.Id;
        insert token;
        
        B2C_Instance__c instance = new B2C_Instance__c();
        instance.Name = 'Test';
        instance.API_Url__c='https://sfccstage.firemountain.org';
        insert instance;
        
        B2C_CustomerList__c custList = new B2C_CustomerList__c();
        custList.Name = 'FireMountainGems';
        custList.B2C_Instance__c=instance.id;
        custList.API_Url__c='https://sfccstage.firemountain.org';
        insert custList;
        
        Account ac = new Account();
        ac.Email__c = 'a@a.com';
        ac.B2C_CustomerList__pc=custList.Id;
        ac.LastName='lastname';
        ac.FirstName='firstname';
        ac.BirthMoDay__c='0101';
        ac.BillingStreet='Billing Street';
        ac.BillingCity='B City';
        ac.BillingStateCode='CA';
        ac.BillingPostalCode='94107';
        ac.BillingCountryCode ='US';
        ac.ShippingStreet='Shipping Street';
        ac.ShippingCity='S City';
        ac.ShippingStateCode='CA';
        ac.ShippingPostalCode='94107';
        ac.ShippingCountryCode='US';
        insert ac;
        
        List<Account> accountList = new List<Account>();
        accountList.add(ac);      
    }
    
    @IsTest
    static void testProcessTrigger() {
     //   List<Account> accountList=[select id,PersonContactId,Phone,CompanyName__c,Type,RecordTypeId,RecordType.Name,Email__c,PersonEmail,B2C_CustomerList__pc,LastName,FirstName,BirthMoDay__c from Account where Email__c='a@a.com'];
        B2C_Client_ID__c clientId = new B2C_Client_ID__c();
        clientId.JWT_Certificate_Name__c = 'bkcr';
        clientId.Name='test';
        insert clientId;
        
        B2C_AuthToken__c token = new B2C_AuthToken__c();
        //      token.Is_Valid__c = true;
        //      token.Is_Expired__c = false;
        token.B2C_AuthToken__c = '12345';
        token.Is_Invalidated__c = false;
        token.B2C_Client_ID__c=clientId.Id;
        insert token;
        
        B2C_Instance__c instance = new B2C_Instance__c();
        instance.Name = 'Test';
        instance.API_Url__c='https://sfccstage.firemountain.org';
        insert instance;
        
        B2C_CustomerList__c custList = new B2C_CustomerList__c();
        custList.Name = 'FireMountainGems';
        custList.B2C_Instance__c=instance.id;
        custList.API_Url__c='https://sfccstage.firemountain.org';
        insert custList;
        
        Account ac = new Account();
        ac.Email__c = 'a@a.com';
        ac.B2C_CustomerList__pc=custList.Id;
        ac.LastName='lastname';
        ac.FirstName='firstname';
        ac.BirthMoDay__c='0101';
        ac.BillingStreet='Billing Street';
        ac.BillingCity='B City';
        ac.BillingStateCode='CA';
        ac.BillingPostalCode='94107';
        ac.BillingCountryCode ='US';
        ac.ShippingStreet='Shipping Street';
        ac.ShippingCity='S City';
        ac.ShippingStateCode='CA';
        ac.ShippingPostalCode='94107';
        ac.ShippingCountryCode='US';
        ac.Type='Inquirer';
        insert ac;
        System.debug('account id is test class : ' +ac.Id);
        List<Account> accountList = new List<Account>();
        accountList.add(ac);  
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PersonAccountRestMockClass()); 
        B2CPersonAccountTriggerHelper.processAccounts(accountList);
        Test.stopTest();
    }
  /*  
    @isTest
    static void testUpdateTrigger(){
       // List<Account> accountList=[select id,PersonContactId,CompanyName__c,Phone,Type,RecordTypeId,RecordType.Name,PersonEmail,Email__c,B2C_CustomerList__pc,LastName,FirstName,BirthMoDay__c,BillingCity,ShippingCity from Account where Email__c='a@a.com'];
        B2C_Client_ID__c clientId = new B2C_Client_ID__c();
        clientId.JWT_Certificate_Name__c = 'bkcr';
        clientId.Name='test';
        insert clientId;
        
        B2C_AuthToken__c token = new B2C_AuthToken__c();
        //      token.Is_Valid__c = true;
        //      token.Is_Expired__c = false;
        token.B2C_AuthToken__c = '12345';
        token.Is_Invalidated__c = false;
        token.B2C_Client_ID__c=clientId.Id;
        insert token;
        
        B2C_Instance__c instance = new B2C_Instance__c();
        instance.Name = 'Test';
        instance.API_Url__c='https://sfccstage.firemountain.org';
        insert instance;
        
        B2C_CustomerList__c custList = new B2C_CustomerList__c();
        custList.Name = 'FireMountainGems';
        custList.B2C_Instance__c=instance.id;
        custList.API_Url__c='https://sfccstage.firemountain.org';
        insert custList;
        
        Account ac = new Account();
        ac.Email__c = 'b@a.com';
        ac.B2C_CustomerList__pc=custList.Id;
        ac.LastName='lastname';
        ac.FirstName='firstname';
        ac.BirthMoDay__c='0101';
        ac.BillingStreet='Billing Street';
        ac.BillingCity='B City';
        ac.BillingStateCode='CA';
        ac.BillingPostalCode='94107';
        ac.BillingCountryCode ='US';
        ac.ShippingStreet='Shipping Street';
        ac.ShippingCity='S City';
        ac.ShippingStateCode='CA';
        ac.ShippingPostalCode='94107';
        ac.ShippingCountryCode='US';
        insert ac;
        
        List<Account> accountList = new List<Account>();
        accountList.add(ac);  
        
        Test.startTest();
        for(Account a: accountList){
            a.BillingCity='Test Billing';
            a.ShippingCity='test shipping city';
        }
        update accountList;
        Test.setMock(HttpCalloutMock.class, new PersonAccountRestMockClass()); 
        B2CPersonAccountTriggerHelper.processAccounts(accountList);
        Test.stopTest();
    } */
}