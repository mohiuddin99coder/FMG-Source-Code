trigger PreventionOf28daysOfLeadCreation on Lead (before insert) {
    Trigger_Switch__c LT =Trigger_Switch__c.getValues('Lead Trigger'); 
    if(LT != null && LT.IsActive__c == True){   
        if(Trigger.isInsert && Trigger.isBefore){
            
            List<Lead> catalogLeads= new List<Lead>();
            List<Lead> platinumLeads= new List<Lead>();
            
            for ( Lead l : Trigger.New){
                if (l.LeadSource =='Catalog Request')
                    catalogLeads.add(l);
                else if ( l.LeadSource =='Platinum Program')
                    platinumLeads.add(l);
            }
            
            //process catalog leads
            if (catalogLeads.size() >0)
            	Lead28dayshandler.checkForDuplicatesOfCatalog(catalogLeads);
            // process platinum leads
            if (platinumLeads.size() >0)
            	Lead28dayshandler.checkForDuplicatesOfPlatinum(platinumLeads);
            
        }  
    }
    
}