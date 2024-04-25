@isTest
public class AccountTriggerTestClass {
  
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
        instance.Is_Active__c=true;
        insert instance;
        
        B2C_CustomerList__c custList = new B2C_CustomerList__c();
        custList.Name = 'FireMountainGems';
        custList.B2C_Instance__c=instance.id;
        custList.API_Url__c='https://sfccstage.firemountain.org';
        insert custList;
        
        Contact con = new Contact();
        con.LastName='Test Contact';
        insert con;
        Account ac = new Account();
     //   ac.PersonContactId=con.Id;
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
        ac.B2C_Customer_No__pc='12345';
        ac.B2C_Disable_Integration__pc=true;
        insert ac;
        
        List<Account> accountList = new List<Account>();
        accountList.add(ac);      
    }
    
    @isTest
    public static void testAccountTrigger(){
        Account a = new Account();
        a.LastName = 'Test';
        a.PersonEmail='Test@test.com';
        a.B2C_Customer_ID__pc='123445';
        a.B2C_Customer_No__pc='12345';
        insert a;
         B2C_Client_ID__c clientID = new B2C_Client_ID__c();
        clientID.Name='36e5d789-b898-498d-bd9e-eaab58bed87d';
        clientID.JWT_Certificate_Name__c='bkcr';
        insert clientID;
        
        B2C_Instance__c instance = new B2C_Instance__c();
        instance.Name = 'Test';
        instance.API_Url__c='https://sfccstage.firemountain.org';
        instance.Is_Active__c=true;
        insert instance;
        
        B2C_CustomerList__c bclist = new B2C_CustomerList__c();
  //      bclist.JWT_Certificate_Name__c='bkcr';
        bclist.API_Url__c='https://utsf.firemountain.org/s/-/dw/data/v21_3/customer_lists/FireMountainGems';
        bclist.B2C_Instance__c = instance.id;
        bclist.Name='FireMountainGems';
        bclist.B2C_Client_ID__c=clientID.id;
 //       bclist.B2C_Client_ID_Value__c='36e5d789-b898-498d-bd9e-eaab58bed87d';
        insert bclist;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CustomerCalloutMock());
        
        Test.stopTest();
    }
    
    @isTest
    public static void testAccountScheduler(){
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
        instance.Is_Active__c=true;
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
        ac.B2C_Customer_No__pc='12345';
        insert ac;
        
        List<Account> accountList = new List<Account>();
        accountList.add(ac);  
     //   List<Account> accountList=[select id,PersonEmail,B2C_CustomerList__pc,LastName,FirstName,BirthMoDay__c from Account where Email__c='a@a.com'];
        SyncAccountsToCC.doChainJob = false;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CustomerCalloutMock());
        SyncAccountsToCC syncAcc = new SyncAccountsToCC(accountList);
        System.enqueueJob(syncAcc);
        Test.stopTest();  
        
    }
    
    @isTest
    public static void createCustomerAddressesForAccounts(){
        List<Account> accountList=[select id,PersonEmail,B2C_CustomerList__pc,LastName,FirstName,BirthMoDay__c from Account where Email__c='a@a.com'];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CustomerCalloutMock());
        CustomerAddressCreationQueue syncCustomerAdd = new CustomerAddressCreationQueue(accountList);
        System.enqueueJob(syncCustomerAdd);
        
        for(Account a : accountList){
            a.BillingStreet='Test Billing';
            a.ShippingStreet='TestShipping';
        }
        update accountList;
        Test.stopTest(); 
    } 
    
    @isTest
    public static void updateRelatedCustomerAddressesTest(){
        B2C_CustomerList__c customerList = [select id,B2C_Instance__c,API_Url__c,Is_Active__c from B2C_CustomerList__c where Name = 'FireMountainGems' LIMIT 1];
        Account ac = new Account();
        ac.Email__c = 'a@a.com';
        ac.B2C_CustomerList__pc=customerList.Id;
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
        ac.B2C_Customer_No__pc='12345';
        insert ac;
        List<Customer_Address__c> updateCustomerAddresses = new List<Customer_Address__c>();
        Customer_Address__c shipAddress  = new Customer_Address__c();
        shipAddress.Name ='Shipping Address';
        shipAddress.Address__Street__s = 'Ship Street';
        shipAddress.Address__City__s = 'Ship City';
        shipAddress.Address__CountryCode__s = 'US';
        shipAddress.Address__PostalCode__s = '94107';
        shipAddress.Address__StateCode__s = 'CA';
        shipAddress.ParentId__c=ac.Id;
        updateCustomerAddresses.add(shipAddress);
        Customer_Address__c billAddress  = new Customer_Address__c();
        billAddress.Name ='Billing Address';
        billAddress.Address__Street__s = 'Bill Street';
        billAddress.Address__City__s = 'Bill City';
        billAddress.Address__CountryCode__s = 'US';
        billAddress.Address__PostalCode__s = '94107';
        billAddress.Address__StateCode__s = 'CA';
        billAddress.ParentId__c=ac.Id;
        updateCustomerAddresses.add(billAddress);
        
        insert updateCustomerAddresses;
        
        List<Account> newAccountList = new List<Account>();
        newAccountList.add(ac);

        List<Account> updateAccountList = new List<Account>();
        updateAccountList = newAccountList;
        for(Account a : updateAccountList){
		 a.BillingStreet='Test Billing';
		 a.ShippingStreet='TestShipping';
		}
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CustomerAddressRestMockClass()); 
        update updateAccountList;
        B2CPersonAccountTriggerHelper.updateRelatedCustomerAddresses(updateAccountList,newAccountList);
        Test.stopTest();
        
    }
}