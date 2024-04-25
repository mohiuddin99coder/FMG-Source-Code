@IsTest
public class UpdateAccountFromJewelryForm_Test {
    @isTest
    static void testUpdateAccountInfo() {
        // Create test data for Case and Account
        Account testAccount = new Account(
            Lastname = 'Test Account',
            Website = 'www.example.com',
            ShippingStreet = '123 Test Street',
            ShippingCity = 'Test City',
            ShippingPostalCode = '12345',
            ShippingCountryCode = 'US',
            ShippingStateCode = 'CA',
            //CompanyName__c = 'Test Company',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );
        insert testAccount;
        System.debug('testAccount==>'+testAccount);
        
        Case testCase = new Case(
            AccountId = testAccount.Id
        );
        insert testCase;
        System.debug('testCase==>'+testCase);
        
        // Create test data for Case and Account1
        Account testAccount1 = new Account(
            Lastname = 'Test Account1',
            Website = 'www.example.com',
            ShippingStreet = '123 Test Street',
            ShippingCity = 'Test City',
            ShippingPostalCode = '12345',
            ShippingCountryCode = 'US',
            ShippingStateCode = 'CA',
            //CompanyName__c = 'New Test Company',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );
        insert testAccount1;
        System.debug('testAccount1==>'+testAccount1);
        
        Case testCase1 = new Case(
            AccountId = testAccount1.Id
        );
        insert testCase1;
        System.debug('testCase1==>'+testCase1);
        
        String newCompany = 'New Test Company';
        Id result1 = UpdateAccountFromJewelryForm.updateAccountInfo(
            testCase1.Id, null, null, newCompany, null, null, null, null, null, null, null, null, null, null, null
        );
        
        // Verify the update of the CompanyName__c field
        Account updatedAccount1 = [SELECT Id, CompanyName__c FROM Account WHERE Id = :testAccount1.Id LIMIT 1];
        System.assertEquals(newCompany, updatedAccount1.CompanyName__c);
        // Call the method to update the account info
        Id recordId = testCase.Id;
        String website = 'www.updated-example.com';
        String street = '456 Updated Street';
        String city = 'Updated City';
        String country = 'US';
        String countryLabel = 'United States';
        String state = 'NY';
        String stateLabel = 'New York';
        String zip = '54321';
        String phone = '123-456-7890';
        String twitter = 'twitter.com/test';
        String pinterest = 'pinterest.com/test';
        String instagram = 'instagram.com/test';
        String facebook = 'facebook.com/test';
        
        Id result = UpdateAccountFromJewelryForm.updateAccountInfo(
            recordId, website, street, null, city, country, countryLabel, state, stateLabel, zip, null, twitter, pinterest, instagram, facebook
        );
        // Verify the update
        Account updatedAccount = [SELECT Id, Website, ShippingStreet, ShippingCity, ShippingPostalCode, ShippingCountryCode, ShippingStateCode, CompanyName__c
                                  FROM Account WHERE Id = :testAccount.Id LIMIT 1];
        System.assertEquals(website, updatedAccount.Website);
        System.assertEquals(street, updatedAccount.ShippingStreet);
        System.assertEquals(city, updatedAccount.ShippingCity);
        System.assertEquals(country, updatedAccount.ShippingCountryCode);
        System.assertEquals(state, updatedAccount.ShippingStateCode);
        System.assertEquals(zip, updatedAccount.ShippingPostalCode);
        System.assertEquals(testAccount.CompanyName__c, updatedAccount.CompanyName__c);
        
        // Call the method to upsert URL records
        Test.startTest();
 
        Map<String, String> urlMap = new Map<String, String>();
        urlMap.put('twitter', 'twitter.com/updated-test');
        urlMap.put('pinterest', 'pinterest.com/updated-test');
        urlMap.put('instagram', 'instagram.com/updated-test');
        urlMap.put('facebook', 'facebook.com/updated-test');
        
        UpdateAccountFromJewelryForm.upsertUrlList(urlMap, testAccount.Id);
        Test.stopTest();
        
        // Verify the upserted URL records
        List<URL__c> urls = [SELECT Id, Title__c, URL__c FROM URL__c WHERE Customer__c = :testAccount.Id];
        System.assertEquals(4, urls.size());
        for (URL__c url : urls) {
            if (url.Title__c == 'twitter') {
                System.assertEquals('twitter.com/updated-test', url.URL__c);
            } else if (url.Title__c == 'pinterest') {
                System.assertEquals('pinterest.com/updated-test', url.URL__c);
            } else if (url.Title__c == 'instagram') {
                System.assertEquals('instagram.com/updated-test', url.URL__c);
            } else if (url.Title__c == 'facebook') {
                System.assertEquals('facebook.com/updated-test', url.URL__c);
            }
        }
    }
}