@IsTest
public class FMGAccountHandlerTest {
    
    @isTest
    public static void testUpdateCustomerTypeAndTaskCreation() {
        
        Trigger_Switch__c onTrigger = new Trigger_Switch__c(Name='FMGAccountTrigger');
        onTrigger.IsActive__c = True ;
        insert onTrigger ;

        
        // Create Test Data
        Account[] newAccountsList = new List<Account>();
        Account[] oldAccountsList = new List<Account>();
        Map<Id, Account> newMap = new Map<Id,Account>();
        Map<Id, Account> oldMap = new Map<Id,Account>();
        
        // Create Old Accounts
        for(Integer i = 1; i<=8; i++) {
            Account acc = new Account();
            if(i == 2) {
                acc.LastName = 'OldFMGTestAccount' + i;
            } else {
                acc.FirstName = 'OldFMGTest';
                acc.LastName = 'Account' + i;
            }
            acc.PersonEmail = 'fmgtestaccountold'+i+'@etggs.com';
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            oldAccountsList.add(acc);
        }
        System.debug('AccountList : ' + newAccountsList);
        if(!oldAccountsList.isEmpty()) {
            Insert oldAccountsList;
        }
        
        // Create New Accounts
        for(Integer i = 1; i<=8; i++) {
            Account acc = new Account();
            if(i == 2) {
                acc.LastName = 'FMGTestAccount' + i;
            } else {
                acc.FirstName = 'FMGTest';
                acc.LastName = 'Account' + i;
            }
            acc.PersonEmail = 'fmgtestaccount'+i+'@etggs.com';
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            newAccountsList.add(acc);
        }
        System.debug('AccountList : ' + newAccountsList);
        if(!newAccountsList.isEmpty()) {
            Insert newAccountsList;
        }
        
        // Mapping Id with their Accounts
        if(!newAccountsList.isEmpty()) {
            for(Account acc : newAccountsList) {
                newMap.put(acc.Id, acc);
            }  
        }
        if(!oldAccountsList.isEmpty()) {
            for(Account acc : oldAccountsList) {
                oldMap.put(acc.Id, acc);
            }
        }
        System.debug('New Map List : ' + newMap);
        System.debug('Old Map List : ' + oldMap);
        
        Integer i = 1;
        if(!newAccountsList.isEmpty()) {
            for(Account acc : newAccountsList) {
                acc.Catalog_Mailed_Date_from_Marketing_Clo__c = DateTime.newInstance(2023, 11, 1);
                acc.Offer_Code__c = '123'+i;
                if(acc.PersonEmail == 'fmgtestaccount1@etggs.com') {
                    acc.PerfCurrPeriodAmt__c = 5000;
                } else if (acc.PersonEmail == 'fmgtestaccount2@etggs.com') {
                    acc.PlatinumPriorPeriod__c = 7000;
                } else if (acc.PersonEmail == 'fmgtestaccount3@etggs.com') {
                    acc.PlatinumPriorPeriod__c = 7000;
                    acc.PerfCurrPeriodAmt__c = 5000;
                } else if (acc.PersonEmail == 'fmgtestaccount4@etggs.com') {
                    acc.Perf365Days__c = 2000;
                } else if (acc.PersonEmail == 'fmgtestaccount5@etggs.com') {
                    acc.Perf365Days__c = 3000;
                }  else if (acc.PersonEmail == 'fmgtestaccount6@etggs.com') {
                    acc.Perf365Days__c = 4000;
                }  else if (acc.PersonEmail == 'fmgtestaccount7@etggs.com') {
                    acc.Perf365Days__c = 5000;
                }  else if (acc.PersonEmail == 'fmgtestaccount8@etggs.com') {
                    acc.Perf365Days__c = 10000;
                }
                i++;
            }
            
            Update newAccountsList;
        }
        
        
        
        if(!newAccountsList.isEmpty()) {
            for(Account acc : newAccountsList) {
                if(acc.PersonEmail == 'fmgtestaccount1@etggs.com') {
                    acc.Perf365Days__c = 3000;
                } else if (acc.PersonEmail == 'fmgtestaccount2@etggs.com') {
                    acc.Perf365Days__c = 4000;
                } else if (acc.PersonEmail == 'fmgtestaccount3@etggs.com') {
                    acc.Perf365Days__c = 5000;
                } else if (acc.PersonEmail == 'fmgtestaccount4@etggs.com') {
                    acc.Deceased__c = True;
                }
            }
            
            Update newAccountsList;
        }
        
        if(!newAccountsList.isEmpty() && !oldAccountsList.isEmpty() && !newMap.isEmpty() && !oldMap.isEmpty()) {
            Test.startTest();
            FMGAccountHandler.updatePlatinumFieldUpdate(newAccountsList, oldAccountsList, newMap, oldMap);
            Test.stopTest();  
        }
        
    }
}