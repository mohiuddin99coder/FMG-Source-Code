public class FMGAccountHandler {
    
    public static task createNewTask(string TaskName, id relatedToId,string tskName){
        
        Task T = new Task();
        T.Subject = TaskName;
        T.WhatId = relatedToId;
        T.ActivityDate = date.today();
        T.Task_Names__c = tskName;
        if(!Test.isRunningTest()){
            FMGProjectMasterId__c ProjId = FMGProjectMasterId__c.getValues('RMAProjectMasterId');
            System.debug('ProjId ProjectMasterId----->'+ProjId.Platinum_Queue_task__c);
            if(T.Subject =='New Platinum Introduction' ){
                T.OwnerId = ProjId.Platinum_Queue_task__c;
            }
        }
        
        return T;
    }
    
    public static void createCatalogActivity(list<account> accList, Map<id, Account> oldAccMap){
        list<task> taskList = new list<task>();
        try{
            if(!accList.isEmpty() && !oldAccMap.isEmpty()) {  
                for(Account a : accList){
                    System.debug('Account: '+ a.Offer_Code__c);
                    if(a.Offer_Code__c != NULL && a.Offer_Code__c != oldAccMap.get(a.Id).Offer_Code__c ){
                        if(a.Catalog_Mailed_Date_from_Marketing_Clo__c != NULL && a.Catalog_Mailed_Date_from_Marketing_Clo__c != oldAccMap.get(a.Id).Catalog_Mailed_Date_from_Marketing_Clo__c){
                            Task t = new Task();
                            string AccName;
                            if(a.firstname != NULL && a.LastName != NULL){
                                AccName = a.firstname+' ' +a.LastName;
                            }else if(a.firstname == NULL && a.LastName != NULL){
                                AccName = a.LastName;
                            }
                            system.debug('AccName :'+AccName);
                            t.Subject = 'Catalog Mailed To : '+AccName;
                            t.Type = 'Catalog Mailed';
                            t.WhatId = a.id;
                            t.ActivityDate = Date.today()+7;
                            t.Catalog_Information__c = 'Offer Code = '+a.Offer_Code__c+' Catalog Mailed Date = '+a.Catalog_Mailed_Date_from_Marketing_Clo__c;
                            taskList.add(t);
                        }
                    }
                }
            } 
            
            insert taskList;
        } catch (Exception e) {
            System.debug('Exception: '+ e);
        }
        
    }
    
    
    // Platinum Field update Implementation
    public static void updatePlatinumFieldUpdate(list<account> newAccountList,list<account> oldAccountList,Map<Id, Account> newMap,  Map<Id, Account> oldAccountMap){
        try {
            if(!newAccountList.isEmpty() && !oldAccountMap.isEmpty()) {
                
                for(Account Acc : newAccountList){
                    if(Acc.Deceased__c != TRUE && Acc.Exclude_From_Platinum__c != TRUE && Acc.Facility__c != TRUE && Acc.Inmate__c != TRUE && Acc.Employee__c != TRUE && Acc.Bad_Credit_Returned_Check__c != TRUE && 
                       ( Acc.Perf365Days__c != oldAccountMap.get(Acc.Id).Perf365Days__c || Acc.PlatinumPriorPeriod__c != oldAccountMap.get(Acc.Id).PlatinumPriorPeriod__c || Acc.PerfCurrPeriodAmt__c != oldAccountMap.get(Acc.Id).PerfCurrPeriodAmt__c ||
                        Acc.Deceased__c != oldAccountMap.get(Acc.Id).Deceased__c ||Acc.Exclude_From_Platinum__c != oldAccountMap.get(Acc.Id).Exclude_From_Platinum__c || Acc.Facility__c != oldAccountMap.get(Acc.Id).Facility__c ||
                        Acc.Inmate__c != oldAccountMap.get(Acc.Id).Inmate__c ||
                        Acc.Employee__c != oldAccountMap.get(Acc.Id).Employee__c || Acc.Bad_Credit_Returned_Check__c != oldAccountMap.get(Acc.Id).Bad_Credit_Returned_Check__c)){
                            system.debug('inside check box false');
                            
                            if(Acc.Type != 'Platinum'){   
                                
                                system.debug('Type not platinum ');
                                
                                if(Acc.Perf365Days__c >= 2000 && Acc.Perf365Days__c <= 2999.99){
                                    system.debug('Inside if 2000');
                                    Acc.Discount__c = 'P4';
                                    Acc.Type = 'Platinum Prospect';
                                    Acc.Discount_Level__c = 'P4';
                                    Acc.Previous_Discount_Level__c = oldAccountMap.get(Acc.Id).Discount_Level__c;
                                }else if(Acc.Perf365Days__c >= 3000 && Acc.Perf365Days__c <=4999.99){
                                    system.debug('inside 3 star if');
                                    Acc.Type = 'Platinum';
                                    Acc.Discount_Level__c = '3 Star';
                                    Acc.Previous_Discount_Level__c = oldAccountMap.get(Acc.Id).Discount_Level__c;
                                    Acc.Discount__c = '5%';
                                    if(Acc.Star_Level_3_Reached_Date__c == null){
                                        Acc.Star_Level_3_Reached_Date__c =System.now();
                                    }
                                }else if(Acc.Perf365Days__c >= 5000 && Acc.Perf365Days__c <=9999.99){
                                    system.debug('inside 4 star if');
                                    Acc.Type = 'Platinum';
                                    Acc.Discount_Level__c = '4 Star';
                                    Acc.Previous_Discount_Level__c = oldAccountMap.get(Acc.Id).Discount_Level__c;
                                    Acc.Discount__c = '10%';
                                    if(Acc.Star_Level_4_Reached_Date__c == null){
                                        Acc.Star_Level_4_Reached_Date__c =System.now();
                                    }
                                }else if(Acc.Perf365Days__c >= 10000){
                                    system.debug('inside 5 star if');
                                    Acc.Type = 'Platinum';
                                    Acc.Discount__c = '15%';
                                    Acc.Discount_Level__c = '5 Star';
                                    Acc.Previous_Discount_Level__c = oldAccountMap.get(Acc.Id).Discount_Level__c;
                                    if(Acc.Star_Level_5_Reached_Date__c == null){
                                        Acc.Star_Level_5_Reached_Date__c =System.now();
                                    }
                                }
                            }
                            decimal total = 0;
                            if(Acc.PlatinumPriorPeriod__c != NULL && Acc.PerfCurrPeriodAmt__c != NULL){
                                total = Acc.PlatinumPriorPeriod__c + Acc.PerfCurrPeriodAmt__c;                            
                            }else if(Acc.PlatinumPriorPeriod__c != NULL && Acc.PerfCurrPeriodAmt__c == NULL){
                                total = Acc.PlatinumPriorPeriod__c;                            
                            }else if(Acc.PlatinumPriorPeriod__c == NULL && Acc.PerfCurrPeriodAmt__c != NULL){
                                total = Acc.PerfCurrPeriodAmt__c;                            
                            }
                            if(Acc.Type == 'Platinum' ){
                                if(total >= 3000 && total <=4999.99 && Acc.Discount_Level__c != '3 Star'&& oldAccountMap.get(Acc.Id).Discount_Level__c != '4 Star' && oldAccountMap.get(Acc.Id).Discount_Level__c != '5 Star'){
                                    system.debug('inside 3 star if');
                                    Acc.Type = 'Platinum';
                                    Acc.Discount_Level__c = '3 Star';
                                    Acc.Previous_Discount_Level__c = oldAccountMap.get(Acc.Id).Discount_Level__c;
                                    Acc.Discount__c = '5%';
                                    if(Acc.Star_Level_3_Reached_Date__c == null){
                                        Acc.Star_Level_3_Reached_Date__c =System.now();
                                    }
                                }
                                else if(total >= 5000 && total <=9999.99 && Acc.Discount_Level__c != '4 Star'&& oldAccountMap.get(Acc.Id).Discount_Level__c != '5 Star'){
                                    Acc.Discount_Level__c = '4 Star';
                                    Acc.Previous_Discount_Level__c = oldAccountMap.get(Acc.Id).Discount_Level__c;
                                    Acc.Discount__c = '10%';
                                    if(Acc.Star_Level_4_Reached_Date__c == null){
                                        Acc.Star_Level_4_Reached_Date__c =System.now();
                                    }
                                }
                                else if(total >= 10000 && Acc.Discount_Level__c != '5 Star'){
                                    Acc.Discount_Level__c = '5 Star';
                                    Acc.Previous_Discount_Level__c = oldAccountMap.get(Acc.Id).Discount_Level__c;
                                    Acc.Discount__c = '15%';
                                    if(Acc.Star_Level_5_Reached_Date__c == null){
                                        Acc.Star_Level_5_Reached_Date__c =System.now();
                                    }
                                }
                            }
                        }
                    else if((Acc.Deceased__c == TRUE && Acc.Deceased__c != oldAccountMap.get(Acc.Id).Deceased__c) ||(Acc.Exclude_From_Platinum__c == TRUE && Acc.Exclude_From_Platinum__c != oldAccountMap.get(Acc.Id).Exclude_From_Platinum__c)  || (Acc.Facility__c == TRUE && Acc.Facility__c != oldAccountMap.get(Acc.Id).Facility__c) || (Acc.Inmate__c == TRUE && Acc.Inmate__c != oldAccountMap.get(Acc.Id).Inmate__c)
                            || (Acc.Employee__c == TRUE && Acc.Employee__c != oldAccountMap.get(Acc.Id).Employee__c)||(Acc.Bad_Credit_Returned_Check__c == TRUE && Acc.Bad_Credit_Returned_Check__c != oldAccountMap.get(Acc.Id).Bad_Credit_Returned_Check__c)){
                                Acc.Discount_Level__c = '';
                                Acc.Previous_Discount_Level__c = '';
                                Acc.Type = '';
                                Acc.Discount__c = '';
                                system.debug('inside check box True');
                            }
                    
                }
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e);
        }
    }
    
    public static void createTasks(list<account> newAccountList,list<account> oldAccountList,Map<Id, Account> newMap,  Map<Id, Account> oldMap){
        date dt = date.today();
        Integer month = dt.month();
        Integer day = dt.day();
        system.debug('outside of method');
        system.debug('Month-->'+month+' day-->'+day);
        if(!newAccountList.isEmpty() && !oldMap.isEmpty()) {
            system.debug('newAccountList: ' + newAccountList);
            system.debug('oldAccountList: ' + oldAccountList);
            createCatalogActivity(newAccountList,oldMap);
            if(month ==6 && day > 30){
                system.debug('inside of if method');
            }else{
                system.debug('inside of else method');
                accountTaskCreation(newAccountList,oldMap);
            }
        }
    }
    public static void accountTaskCreation(list<account> newAccountList, Map<Id, Account> oldAccountMap){
        map<Account, Task> accountTaskMap = new map<Account,Task>();
        list<Account> accountToUpdate = new list<Account>();
        list<task> taskToInsert = new list<task>();
        System.debug('newAccountList is : ' +newAccountList);
        System.debug('oldAccountMap is : ' +oldAccountMap);
        try {
            if(!newAccountList.isEmpty() && !oldAccountMap.isEmpty()) {
                
                for(Account Acc : newAccountList){
                    if (Acc.Deceased__c != TRUE && Acc.Exclude_From_Platinum__c != TRUE && Acc.Facility__c != TRUE && Acc.Inmate__c != TRUE && Acc.Employee__c != TRUE && Acc.Bad_Credit_Returned_Check__c != TRUE &&
                        (Acc.Perf365Days__c >= 2000 && Acc.Perf365Days__c <= 2999.99) && Acc.Type == 'Platinum Prospect' && oldAccountMap.get(Acc.Id).Type != 'Platinum Prospect') {
                            system.debug('Inside if 2000');
                            Task Tsk = createNewTask('New Prospect Contact', Acc.Id, 'New Prospect Contact');
                            taskToInsert.add(Tsk);
                        } else if(Acc.Deceased__c != TRUE && Acc.Exclude_From_Platinum__c != TRUE && Acc.Facility__c != TRUE && Acc.Inmate__c != TRUE && Acc.Employee__c != TRUE && Acc.Bad_Credit_Returned_Check__c != TRUE && 
                                  ( Acc.Perf365Days__c != oldAccountMap.get(Acc.Id).Perf365Days__c || Acc.PlatinumPriorPeriod__c != oldAccountMap.get(Acc.Id).PlatinumPriorPeriod__c || Acc.PerfCurrPeriodAmt__c != oldAccountMap.get(Acc.Id).PerfCurrPeriodAmt__c ||
                                   Acc.Deceased__c != oldAccountMap.get(Acc.Id).Deceased__c ||Acc.Exclude_From_Platinum__c != oldAccountMap.get(Acc.Id).Exclude_From_Platinum__c || Acc.Facility__c != oldAccountMap.get(Acc.Id).Facility__c ||
                                   Acc.Inmate__c != oldAccountMap.get(Acc.Id).Inmate__c ||
                                   Acc.Employee__c != oldAccountMap.get(Acc.Id).Employee__c || Acc.Bad_Credit_Returned_Check__c != oldAccountMap.get(Acc.Id).Bad_Credit_Returned_Check__c)){
                                       system.debug('inside check box false');
                                       
                                       if(Acc.Type == 'Platinum' && oldAccountMap.get(Acc.Id).Type!= 'Platinum'){   
                                           system.debug('Type not platinum ');
                                           if(Acc.Perf365Days__c >= 3000 && Acc.Perf365Days__c <=4999.99){
                                               system.debug('inside 3 star if');
                                               Task Tsk = createNewTask('New Platinum Introduction',Acc.Id,'New Platinum Introduction');
                                               taskToInsert.add(Tsk);
                                           }
                                           else if(Acc.Perf365Days__c >= 5000 && Acc.Perf365Days__c <=9999.99){
                                               system.debug('inside 4 star if');
                                               Task Tsk = createNewTask('New Platinum Introduction',Acc.Id,'New Platinum Introduction');
                                               taskToInsert.add(Tsk);
                                           }
                                           else if(Acc.Perf365Days__c >= 10000){
                                               system.debug('inside 5 star if');
                                               Task Tsk = createNewTask('New Platinum Introduction',Acc.Id,'New Platinum Introduction');
                                               taskToInsert.add(Tsk);
                                           }
                                           
                                       }
                                       decimal total = 0;
                                       if(Acc.PlatinumPriorPeriod__c != NULL && Acc.PerfCurrPeriodAmt__c != NULL){
                                           total = Acc.PlatinumPriorPeriod__c + Acc.PerfCurrPeriodAmt__c;                            
                                       }else if(Acc.PlatinumPriorPeriod__c != NULL && Acc.PerfCurrPeriodAmt__c == NULL){
                                           total = Acc.PlatinumPriorPeriod__c;                            
                                       }else if(Acc.PlatinumPriorPeriod__c == NULL && Acc.PerfCurrPeriodAmt__c != NULL){
                                           total = Acc.PerfCurrPeriodAmt__c;                            
                                       }
                                       if(Acc.Type == 'Platinum' ){
                                           if(total >= 5000 && total <=9999.99 && Acc.Discount_Level__c == '4 Star' && oldAccountMap.get(Acc.Id).Discount_Level__c != '4 Star'){
                                               Task Tsk = createNewTask('New Discount Level',Acc.Id,'New Discount Level');
                                               taskToInsert.add(Tsk);
                                           }
                                           else if(total >= 10000 && Acc.Discount_Level__c == '5 Star' && oldAccountMap.get(Acc.Id).Discount_Level__c != '5 Star'){
                                               Task Tsk = createNewTask('New Discount Level',Acc.Id,'New Discount Level');
                                               taskToInsert.add(Tsk);
                                           }
                                           
                                       }
                                   }
                    
                }
                system.debug('taskToInsert  before-->'+taskToInsert);
                Insert taskToInsert;
                system.debug('taskToInsert after-->'+taskToInsert);
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e);
        }     
    }
    
}