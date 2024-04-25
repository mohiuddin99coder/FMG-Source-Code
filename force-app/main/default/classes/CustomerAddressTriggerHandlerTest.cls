@isTest
public class CustomerAddressTriggerHandlerTest {
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
    static void testCustomerAddressCreate() {
        B2C_Client_ID__c clientId = new B2C_Client_ID__c();
        clientId.JWT_Certificate_Name__c = 'bkcr';
        clientId.Name='test';
        insert clientId;
        
        B2C_AuthToken__c token = new B2C_AuthToken__c();
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
        insert ac;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CustomerAddressRestMockClass()); 
        
        Customer_Address__c customerAddress  = new Customer_Address__c();
        customerAddress.Name = 'test';
        customerAddress.Address__Street__s='test';
        customerAddress.Address__StateCode__s='NY';
        customerAddress.Address__PostalCode__s='10013';
        customerAddress.Address__CountryCode__s='US';
        customerAddress.Address__City__s='New York';
        customerAddress.ParentId__c=ac.id;
        insert customerAddress;
        
        Customer_Address__c customerAddress1  = new Customer_Address__c();
        customerAddress1.Name = 'test1';
        customerAddress1.Address__Street__s='test';
        customerAddress1.Address__StateCode__s='NY';
        customerAddress1.Address__PostalCode__s='10013';
        customerAddress1.Address__CountryCode__s='US';
        customerAddress1.Address__City__s='New York';
        customerAddress1.ParentId__c=ac.id;
        insert customerAddress1;
        
        customerAddress.Address__Street__s='test1';
        update customerAddress;
        Test.stopTest();
    }
    
    @isTest
    static void testAuthentication(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AuthenticationRestMockClass());
        CustomerAddressTriggerHandler.makeAuthHttpCallout(new HttpRequest());
        Test.stopTest();
    }
}