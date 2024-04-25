global class Batch_updateDiscountLevel implements Database.Batchable<sObject> {
    global date dt;
    
    global Batch_updateDiscountLevel(date dt){
        this.dt = dt;
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id,Discount__c,Discount_Level__c,Perf365Days__c,PlatAnniversaryDate__c FROM account WHERE (Discount_Level__c = \'3 Star\' OR Discount_Level__c = \'4 Star\' OR Discount_Level__c = \'5 Star\' OR Discount_Level__c =\'P4\') and PlatAnniversaryDate__c!=null';
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext bc, List<account> scope) {
        system.debug('account list '+scope);
        list<Account> accToUpdate = new list<Account>();
        date startDate = Date.newInstance(dt.year()-1,7,1);
        //date endDate = Date.newInstance(dt.year(),6,30);
        //Integer month = dt.month();
        //Integer day = dt.day();
        //if(month == 6 && day == 30){}
        for(Account a : scope){
            system.debug('inside for loop');
            system.debug('a.PlatAnniversaryDate__c-->'+a.PlatAnniversaryDate__c);
            if(a.PlatAnniversaryDate__c > startDate){
                system.debug('inside if');
                if(a.Perf365Days__c >=3000 && a.Perf365Days__c <= 4999.99){
                    a.Discount__c = '5%';
                    a.Discount_Level__c = '3 Star';
                    accToUpdate.add(a);
                    system.debug('a--> 3star'+a);
                }
                else if(a.Perf365Days__c >=5000 && a.Perf365Days__c <= 9999.99){
                    system.debug('inside else if 1');
                    a.Discount__c = '10%';
                    a.Discount_Level__c = '4 Star';
                    accToUpdate.add(a);
                    system.debug('a--> 4star'+a);
                }
                else if(a.Perf365Days__c >= 2000 && a.Perf365Days__c <= 2999.99){
                    system.debug('inside for loop 2');
                    a.Discount__c = 'P4';
                    a.Type = 'Platinum Prospect';
                    a.Discount_Level__c = 'P4';
                    system.debug('a--> p4star'+a);
                    accToUpdate.add(a);
                }
                else if(a.Perf365Days__c < 2000){
                    system.debug('inside for loop 3');
                    a.Discount__c = '';
                    a.Type = 'Post Platinum';
                    a.Discount_Level__c = '';
                    system.debug('a--> post plat'+a);
                    accToUpdate.add(a);
                    system.debug('Account to update' + accToUpdate);
                }
            }
            
        }
        
        if(accToUpdate.size()>0){
        update accToUpdate;
        system.debug('After update' + accToUpdate);
        }
     
    }
    global void finish(Database.BatchableContext bc) {
        
    }
    
}