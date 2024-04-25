public class Lead28dayshandler {
    public static LeadPreventionDays__c LeadDays = LeadPreventionDays__c.getValues('Prevent Catalog Request'); 
    
    public static integer getDays(){
        Integer LPD =90;
        System.debug('LeadDays @@'+LeadDays);
        System.debug('LeadDays'+LeadDays.No_Of_Days__c);
        
        if(LeadDays.No_Of_Days__c !=Null){
            LPD = Integer.Valueof(LeadDays.No_Of_Days__c);
        }
        return LPD;
    }
    
    public static Map<String, Datetime> getLastLeadByEmailOfCatalog(Set<String> emailAddresses) {
        Map<String, Datetime> lastLeadByEmail = new Map<String, Datetime>();
        List<Lead> existingLeads = [ SELECT Id, Email, CreatedDate FROM Lead WHERE Email IN :emailAddresses AND IsDeleted = false AND 	LeadSource = 'Catalog Request'  ORDER BY CreatedDate ASC];
        System.debug('existingLeads '+existingLeads);
        
        for (Lead L : existingLeads) {
            lastLeadByEmail.put(L.Email, L.CreatedDate);
            System.debug('L.Email, L.CreatedDate '+L.Email+ ' '+L.CreatedDate);
        }
        return lastLeadByEmail;
    }
    
    public static void checkForDuplicatesOfCatalog(List<Lead> newLeads) {
        Integer DaysToPrevent = getDays();
        Map<String,Lead> uniqueLeads= new Map<String,Lead> ();
        
        for (Lead newLead : newLeads) {
            if (!uniqueLeads.containsKey(newLead.Email )){
                uniqueLeads.put(newLead.Email,newLead);  
            } else  {// multiple requests in the same context
                newLead.addError('A Catalog Requested Lead with this email address already exists and cannot be recreated until ' 
                                 + DaysToPrevent	+ ' days have passed since the most recent Lead was created.');
            }  
        }
        
        Map<String, Datetime> lastLeadByEmail = getLastLeadByEmailOfCatalog(uniqueLeads.keySet());
        
        for (String curEmail : uniqueLeads.keyset()) {
            
            Lead curLead= uniqueLeads.get(curEmail);
            Datetime lastLeadDateByEmailCatalog = lastLeadByEmail.get(curLead.Email);
            
            if (lastLeadDateByEmailCatalog != null && System.now()  < lastLeadDateByEmailCatalog.addDays(DaysToPrevent)  ) {
                system.debug('lastLeadDateByEmailCatalog' +lastLeadDateByEmailCatalog.addDays(DaysToPrevent));
                curLead.addError('A Catalog Requested Lead with this email address already exists and cannot be recreated until ' + DaysToPrevent + ' days have passed since the most recent Lead was created.');
            }
            
        }
    }
    
    public static Map<String, Datetime> getLastLeadByEmailOfPlatinum(Set<String> emailAddresses) {
        Map<String, Datetime> lastLeadByEmail = new Map<String, Datetime>();
        List<Lead> existingLeads = [ SELECT Id, Email, CreatedDate FROM Lead WHERE Email IN :emailAddresses AND IsDeleted = false AND 	LeadSource = 'Platinum Program'	  ORDER BY CreatedDate ASC];
        for (Lead L : existingLeads) {
            lastLeadByEmail.put(L.Email, L.CreatedDate);
        }
        return lastLeadByEmail;
    }
    
    
    public static void checkForDuplicatesOfPlatinum(List<Lead> newLeads) {
        Map<String,Lead> uniqueLeads= new Map<String,Lead> ();
        //Set<String> emailAddressesWithCatalogRequest = new Set<String>();
        Integer DaysToPrevent = getDays();
        LeadPreventionDays__c PLdays = LeadPreventionDays__c.getValues('Prevent Platinum Request');
        System.debug('PLdays'+PLdays);
        Integer PLeadDays = 1;
        if(PLdays.No_Of_Days__c != Null){
            PLeadDays = Integer.ValueOf(PLdays.No_Of_Days__c);
        }
        
        System.debug(PLeadDays);
        for (Lead newLead : newLeads) {
            if (!uniqueLeads.containsKey(newLead.Email )){
                uniqueLeads.put(newLead.Email,newLead);
            }else { // multiple requests in the same context
                newLead.addError('A Platinum Requested Lead with this email address already exists and cannot be recreated until '
                                 +  PLeadDays + ' days have passed since the most recent Lead was created.');
            }
        }
        Map<String, Datetime> lastLeadByEmail = getLastLeadByEmailOfPlatinum(uniqueLeads.keySet());
        for (String curEmail : uniqueLeads.keyset()) {
            Lead curLead= uniqueLeads.get(curEmail);
            Datetime lastLeadDateByEmailPlatinum = lastLeadByEmail.get(curLead.Email);
            //Datetime lastLeadDateByEmailCatalog = lastLeadByEmail.get(curLead.Email);
            
            if (lastLeadDateByEmailPlatinum != null && System.now()  < lastLeadDateByEmailPlatinum.addDays(PLeadDays) ) {
                system.debug('lastLeadDateByEmailPlatinum' +lastLeadDateByEmailPlatinum.addDays(PLeadDays));
                curLead.addError('A Platinum Requested Lead with this email address already exists and cannot be recreated until ' +  PLeadDays + ' days have passed since the most recent Lead was created.');
            }
            /*if (lastLeadDateByEmailCatalog != null && System.now() < lastLeadDateByEmailCatalog.addDays(DaysToPrevent)) {
                emailAddressesWithCatalogRequest.add(curLead.Email); 
            }*/
            
        }
    }
}