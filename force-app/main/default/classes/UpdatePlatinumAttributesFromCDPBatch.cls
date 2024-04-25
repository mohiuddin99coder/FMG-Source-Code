global class UpdatePlatinumAttributesFromCDPBatch implements Database.Batchable<sObject> {
    public string strQueryFilter='';
    public integer strDaysAgo=0;
    
    global UpdatePlatinumAttributesFromCDPBatch(integer daysAgo){
        this.strDaysAgo = daysAgo;
    }
    
    global UpdatePlatinumAttributesFromCDPBatch(string strFilterQuery){
        this.strQueryFilter = strFilterQuery;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        string query = 'select PersonContactId from Account ';
        if (strQueryFilter =='') {
            query = query + 'where PersonContactId != null AND Id IN (select AccountID from Ordersummary where LastModifiedDate = N_DAYS_AGO:'+strDaysAgo+')';
        }else{ //use query that is passed in.
            query= query + this.strQueryFilter;
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> AccountList) {
        List<Account> updatedAccountList = new List<Account>();
        system.debug('Processing Account List Size :'+AccountList.size());
        
        for(Account acclist : AccountList){
            System.debug('Account ID is : ' +acclist.Id + '  PersonContactId Is : ' +acclist.PersonContactId);
            
            String filter = '[IndividualId__c='+acclist.PersonContactId+']';
            String inputString ='';
            
            ConnectApi.CdpQueryOutput result ;
            if(!Test.isRunningTest()){
                try {
                    result = ConnectApi.CdpQuery.queryCalculatedInsights('Sales_Performance_Insights_for_CRM__cio', null, null, 'last365DaysPerfAmount__c DESC', filter, 1, 0);
                } catch (Exception ex){
                    System.debug('Exception on CDPquery:' + ex );
                    System.debug('Stack trace: ' + ex.getStackTraceString()); 
                    continue;
                }
                System.debug('Result from CDPQuery----->'+result);
                if(result != null && result.data != null && result.data.size() > 0){
                    inputString = String.valueOf(result.data[0]);
                    System.debug('String value is : ' +inputString);
                    inputString =  inputString.replaceAll('\\{|\\}', '');
                    System.debug('inputString is : '+inputString);
                    inputString = inputString.replaceAll('=', '":"').replaceAll(', ', '","');
                    inputString = '{"' + inputString + '"}'; 
                }else{ //CDP Query did not return any results
                    System.debug('No Results for CDP Query for Account:'+acclist.Id);
                    continue; // process next account id , if any
                }
            }else{ //running tests
                inputString = getMockInputString();                
            }
            
            System.debug('InputString for Deserialization----->'+inputString);
            try{
                if(inputString != null){
                    Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(inputString);
                    System.debug('jsonMap is : '+jsonMap);
                    
                    // Access the value associated with "last365DaysPerfAmount__c"
                    Account a = new Account();
                    if(jsonMap != null){
                        if(Decimal.valueOf(String.valueOf(jsonMap.get('last365DaysPerfAmount__c'))) != null){
                            a.Perf365Days__c = Decimal.valueOf(String.valueOf(jsonMap.get('last365DaysPerfAmount__c')));
                        }
                        if(Decimal.valueOf(String.valueOf(jsonMap.get('PlatinumPeriodTotalAmount__c'))) != null){
                            a.PerfCurrPeriodAmt__c = Decimal.valueOf(String.valueOf(jsonMap.get('PlatinumPeriodTotalAmount__c')));
                        }
                        if(Decimal.valueOf(String.valueOf(jsonMap.get('PlatinumTotalProgram__c'))) != null){
                            a.PerfPlanTotalAmt__c = Decimal.valueOf(String.valueOf(jsonMap.get('PlatinumTotalProgram__c')));
                        }
                        if(Decimal.valueOf(String.valueOf(jsonMap.get('PlatinumPriorPeriodTotalAmount__c'))) != null){
                            a.PlatinumPriorPeriod__c = Decimal.valueOf(String.valueOf(jsonMap.get('PlatinumPriorPeriodTotalAmount__c')));
                        }
                        if(Decimal.valueOf(String.valueOf(jsonMap.get('LifetimeCountOrders__c'))) != null){
                            a.Life_Time_Order_Count__c = Decimal.valueOf(String.valueOf(jsonMap.get('LifetimeCountOrders__c')));
                        }
                        if(Decimal.valueOf(String.valueOf(jsonMap.get('GCCTotalAmount__c'))) != null){
                            a.Total_Gift_Certificate_Amount__c = Decimal.valueOf(String.valueOf(jsonMap.get('GCCTotalAmount__c')));
                        }
                        if(Decimal.valueOf(String.valueOf(jsonMap.get('LifetimePerfAmount__c'))) != null){
                            a.Total_Orders_Amount__c = Decimal.valueOf(String.valueOf(jsonMap.get('LifetimePerfAmount__c')));
                        }
                        a.id = acclist.id;
                        
                        updatedAccountList.add(a);
                    } // if jsonmap
                } // if inputstring 
            } catch(Exception e){  // something went wrong with deserialize or transformation
                System.debug('Message: '+e.getMessage());
                System.debug('Cause: ' + e.getCause());    
                System.debug('Line number: ' + e.getLineNumber());    
                System.debug('Stack trace: ' + e.getStackTraceString()); 
                continue;
            }  
            
        } // end of for loop for all accounts
        
        System.debug('updatedAccountList is : '+updatedAccountList);
        if(updatedAccountList.size() > 0){
            Database.update(updatedAccountList);
            system.debug('After updatedAccountList :'+updatedAccountList.size());
        }
    }
    
    global String getMockInputString(){
        String inputString = '{' +
            ' "last365DaysPerfAmount__c" : "4000",' +
            ' "PlatinumPeriodTotalAmount__c" : "200",' +
            ' "LifeTimeCountOrders__c" : "200",' +
            ' "LifetimeWithGCAmount__c" : "2050",' +
            ' "PlatinumPriorPeriodTotalAmount__c" : "3200",' +
            ' "LifetimeTotalAmount__c" : "2090",' +
            ' "PlatinumTotalProgram__c" : "2000",' +
            ' "LifetimeCountOrders__c" : "2000",' +
            ' "GCCTotalAmount__c" : "1500",' +
            ' "LifetimePerfAmount__c" : "1000"' +
            '}';
        return inputString;
    }
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
}