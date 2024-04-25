@IsTest
private class Test_Batch_updateDiscountLevel {
    @IsTest
    static void testBatchUpdateDiscountLevel() {
        // Test data setup
        List<Account> accounts = new List<Account>();
        //Method 1
            Account acc = new Account(
                FirstName = 'Test',
                Lastname = 'Account',
                //Recordtypeid = '012DK000001aUjLYAU',
                Recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
                Discount_Level__c = '3 Star', // You can change the Discount_Level__c value as needed for other test cases.
                Perf365Days__c = 3500, // Set the desired Perf365Days__c value for the test case.
                PlatAnniversaryDate__c = Date.newInstance(2023, 1, 1) // Set the desired PlatAnniversaryDate__c value for the test case.
            );
            accounts.add(acc);
        
        //Method 2
        Account acc1= new Account(
                FirstName = 'Test1',
                Lastname = 'Account1',
                //Recordtypeid = '012DK000001aUjLYAU',
                Recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
                Discount_Level__c = '4 Star',
                Perf365Days__c = 5000, //Set the desired Perf365Days__c value for the test case.
                PlatAnniversaryDate__c = Date.newInstance(2023, 1, 1) // Set the desired PlatAnniversaryDate__c value for the test case.
            );
            accounts.add(acc1);
        
        //Method 3
        Account acc2=new Account(
                FirstName = 'Test2',
                Lastname = 'Account2',
               // Recordtypeid = '012DK000001aUjLYAU',
               Recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            Discount_Level__c='P4',
                Perf365Days__c = 2000, //Set the desired Perf365Days__c value for the test case.
                PlatAnniversaryDate__c = Date.newInstance(2023, 1, 1) // Set the desired PlatAnniversaryDate__c value for the test case.
            );
            accounts.add(acc2);
        
        //Method 4
        Account acc3 = New Account(
                FirstName = 'Test3',
                Lastname = 'Account3',
                //Recordtypeid = '012DK000001aUjLYAU',
                Recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
             Discount_Level__c='P4',
            	Perf365Days__c = 1500,//Set the desired Perf365Days__c value for the test case.
                PlatAnniversaryDate__c = Date.newInstance(2023, 1, 1) // Set the desired PlatAnniversaryDate__c value for the test case.
            );
            accounts.add(acc3);
         Account acc4 = New Account(
                FirstName = 'Test4',
                Lastname = 'Account3',
               // Recordtypeid = '012DK000001aUjLYAU',
               Recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
             Discount_Level__c='P4',
            	Perf365Days__c = 500,//Set the desired Perf365Days__c value for the test case.
                PlatAnniversaryDate__c = Date.newInstance(2023, 1, 1) // Set the desired PlatAnniversaryDate__c value for the test case.
            );
            accounts.add(acc4);
        
        insert accounts;
        system.debug('accounts created in test'+accounts);
		
				
        Test.startTest();
        // Execute the batch job
        Date dt = Date.newInstance(2023, 7, 1); // Replace with the desired date for the test case.
        Batch_updateDiscountLevel batch = new Batch_updateDiscountLevel(dt);
        Database.executeBatch(batch, 200); // Adjust the batch size as needed.
        Test.stopTest();

        // Verify the results
        List<Account> updatedAccounts = [SELECT Id, Name, Discount_Level__c, Perf365Days__c, Discount__c, Type FROM Account WHERE Id IN :accounts];
        System.assertEquals(accounts.size(), updatedAccounts.size());
        
    }
     
     
}