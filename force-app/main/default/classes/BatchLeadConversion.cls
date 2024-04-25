global class BatchLeadConversion implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id, Email, Country, City, PostalCode, State, Street,owner.name,	CheckScheduleJobCompleted__c,Mapped_to_Existing_Account__c,Catalog_Mailed_Date__c,Catalog_Offer_Code_Sent__c,Catalog_Mailed__c,Catalog_Requested__c,Catalog_Requested_Date__c,APT_Suite__c,Catalog_Mailed_Date1__c,Estimated_In_Home_Date__c,Catalog_Status__c FROM Lead WHERE (Catalog_Status__c = \'Mailed\' OR Catalog_Status__c = \'Vendor Error\')  AND LeadSource = \'Catalog Request\'AND CheckScheduleJobCompleted__c = False  AND Status != \'Qualified\' AND Estimated_In_Home_Date__c != Null LIMIT 100');
        
    }
    
    
    global void execute(Database.BatchableContext bc, List<Lead> scope) {
        system.debug('Lead list '+scope);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 5];
        
        
        
        set<String> LdEmails = new set<String>();
        for (Lead ld : scope){
            system.debug('ld--->'+ld);
            LdEmails.add(ld.Email);                
            
        }    
        map<string, Account> accountEmailIdsMap = new map<string, Account>();
        list<account> lstAccount = [select id,PersonEmail,type,BillingCountry,BillingCity,BillingPostalCode,BillingState,BillingStreet,
                                    BillingAddress,Postal_Address_Invalid__c,Shippingcountry,ShippingCity,ShippingPostalCode,ShippingState,
                                    ShippingStreet,APT_Suite__c,Catalog_Mailed__c,Catalog_Requested__c,Catalog_Request_Date__c,Catalog_mailed_Date__c
                                    from account where PersonEmail=:LdEmails];
        system.debug('lol');
        for(account acc : lstAccount){
            accountEmailIdsMap.put(acc.PersonEmail, acc);   
        }
        List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
        list<account> updateAccount = new list<account>();
        list<task> taskList = new list<task>();
        List<Lead> LeadsToUpdate = new List<Lead>();
        Lead[] updateLead = new List<Lead>();
        Lead[] updateLeadMappedToExisting = new List<Lead>();
        system.debug('Before loop');
        for (Lead ld : scope){
            system.debug('Inside loop');
            if(accountEmailIdsMap.containsKey(ld.Email) && ld.CheckScheduleJobCompleted__c == False){
                system.debug('Inside If');
                system.debug('ALREADY ACCOUNT EXISTED FOR THIS MAIL'+ accountEmailIdsMap.get(ld.Email).BillingCountry);
                if(ld.Country != null ){                
                    accountEmailIdsMap.get(ld.Email).BillingCountry = ld.Country;
                    accountEmailIdsMap.get(ld.Email).Shippingcountry = ld.Country;
                }
                
                if(ld.City != null){
                    accountEmailIdsMap.get(ld.Email).BillingCity = ld.City;   
                    accountEmailIdsMap.get(ld.Email).ShippingCity = ld.City;
                }
                
                if(ld.PostalCode != null){
                    accountEmailIdsMap.get(ld.Email).BillingPostalCode = ld.PostalCode;
                    accountEmailIdsMap.get(ld.Email).ShippingPostalCode = ld.PostalCode;
                }
                
                if(ld.State != null){
                    accountEmailIdsMap.get(ld.Email).BillingState = ld.State;
                    accountEmailIdsMap.get(ld.Email).ShippingState = ld.State;
                }
                
                if(ld.Street != null){
                    accountEmailIdsMap.get(ld.Email).BillingStreet = ld.Street;
                    accountEmailIdsMap.get(ld.Email).ShippingStreet =ld.Street;
                }
                
                if(ld.APT_Suite__c != null){
                    accountEmailIdsMap.get(ld.Email).APT_Suite__c =ld.APT_Suite__c;
                }
                
                accountEmailIdsMap.get(ld.Email).Postal_Address_Invalid__c = false;
                
                if(ld.Catalog_Mailed__c != null){
                    accountEmailIdsMap.get(ld.Email).Catalog_Mailed__c = ld.Catalog_Mailed__c;
                }
                
                if(ld.Catalog_Requested__c != null){
                    accountEmailIdsMap.get(ld.Email).Catalog_Requested__c = ld.Catalog_Requested__c;
                }
                
                if(ld.Estimated_In_Home_Date__c != null){
                    accountEmailIdsMap.get(ld.Email).Catalog_Request_Date__c = ld.Estimated_In_Home_Date__c;
                }
                
                if(ld.Catalog_Mailed_Date1__c != null){
                    accountEmailIdsMap.get(ld.Email).Catalog_mailed_Date__c =ld.Catalog_Mailed_Date1__c;
                }
                
                updateAccount.add(accountEmailIdsMap.get(ld.Email));
                
                Task t = new Task();
                t.Subject = 'Catalog Mailed';
                t.Type = 'Catalog Mailed';
                datetime ldt = ld.Catalog_Mailed_Date__c;
                if(ldt != null){
                    Date d = ldt.date();
                    string s1 = 'Catalog Mailed Date = '+ date.newinstance(ldt.year(), ldt.month(), ldt.day()) +'  '+ 'Offer Code ='+ld.Catalog_Offer_Code_Sent__c;   
                    String s2 = s1.replace('00:00:00', '');
                    
                    t.Catalog_Information__c = s2;
                    
                }
                
                //t.Description = 'Catalog Mailed Date : '+s1+' Offer Code : '+ld.Catalog_Offer_Code_Sent__c;
                t.WhatId = accountEmailIdsMap.get(ld.Email).id;
                t.ActivityDate = Date.today()+7;
                if(ld.Catalog_Status__c == 'Mailed'){
                   System.debug('inside if:'+ld.Catalog_Status__c);
                    taskList.add(t); 
                }
               
                system.debug('taskList-->'+taskList);
                ld.CheckScheduleJobCompleted__c = True;
                ld.Mapped_to_Existing_Account__c = True;
                LeadsToUpdate.add(ld);
                //updateLeadMappedToExisting.add(ld);
                
            }else if(!(accountEmailIdsMap.containsKey(ld.Email))){
                system.debug('NEW ACCOUNT CREATE');
                Database.LeadConvert leadConvert =new Database.LeadConvert();
                leadConvert.setLeadId(ld.Id);
                LeadConvert.setConvertedStatus(convertStatus.MasterLabel);
                // Bug- 14842- Leads: Catalog requests are creating opportunities.
                LeadConvert.setDoNotCreateOpportunity(true);
                leadConverts.add(leadConvert);
                ld.CheckScheduleJobCompleted__c = True;
                LeadsToUpdate.add(ld);
            }
        }
        /*for(Lead Ld : [select id,CheckScheduleJobCompleted__c from lead where id=:LeadsToUpdate]) {
            ld.CheckScheduleJobCompleted__c = True;
            updateLead.add(ld);
        }
        for(Lead l : updateLeadMappedToExisting){
            l.Mapped_to_Existing_Account__c = TRUE;
        }*/
        system.debug('updateAccount -->'+updateAccount);
        if(updateAccount.size() > 0 ) {
            update updateAccount;
        }
        
        
        if(!leadConverts.isEmpty()){
            try{
                List<Database.LeadConvertResult> results = Database.convertLead(leadConverts);                
            }catch(Exception e){
                system.debug('Exception while converting');
            }
        }
        
        if(taskList.size()>0){
            insert taskList;
        }
        if(LeadsToUpdate.size() > 0 ) {
            update LeadsToUpdate;
        }
        /*if(updateLeadMappedToExisting.size()>0){
            update updateLeadMappedToExisting;
        }*/
        
    }
    global void finish(Database.BatchableContext bc) {
        
    }
    
}