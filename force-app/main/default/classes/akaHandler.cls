public class akaHandler {
   public static Set<Id> accountIdSet = new Set<Id>();
     public static Map<Id,AKA__c> accountIdAkaMap = new Map<Id,	AKA__c>();

     //Starting of logic to prevent user to create primary AKA if there is existing primary AKA under the Account
     public static void preventCreatePrimaryAKAOnInsert(List<aka__c> akaList){
     for(AKA__c curr : akaList ){
            if(curr.Primary__c == true && curr.Customer__c!=null){
                accountIdSet.add(curr.Customer__c);
            }
        }
     if(accountIdSet!=null && accountIdSet.size()>0){    
       //Preparation of Map accountIdAkaMap for Existing Primary AKA   
            for(AKA__c prime:[select id,Primary__c,Customer__c from AKA__c Where Customer__c in:accountIdSet and Primary__c=true]){
                accountIdAkaMap.put(prime.Customer__c,prime);
            } 
      for(AKA__c curr : akaList){
                if(curr.Primary__c== true && curr.Customer__c!=null && accountIdAkaMap.get(curr.Customer__c)!=null){
                    
                    curr.addError('You can\'t create more than one primary AKA under account.');
                }
            }
        }   
    }
    
  //Starting of logic to prevent user to update another AKA to primary AKA if there is existing primary AKA under the Account   

   public static void preventPrimaryAkaOnUpdate(Map<Id,AKA__c> AkaNewMap,Map<Id,AKA__c> AkaOldMap){
       for(AKA__c curr : AkaNewMap.values() ){
            if(AkaNewMap.get(curr.Id).Primary__c!=AkaOldMap.get(curr.id).Primary__c && AkaNewMap.get(curr.id).Primary__c== true && AkaNewMap.get(curr.id).Customer__c!=null){
                accountIdSet.add(AkaNewMap.get(curr.Id).Customer__c);
            }
        }
       
         if(accountIdSet!=null && accountIdSet.size()>0){
            //preparation of Map accountIdAkaMap for existing Primary AKA       
            for(AKA__c curr:[select id,Primary__c,Customer__c from AKA__c Where Customer__c in:accountIdSet and Primary__c=true]){
                accountIdAkaMap.put(curr.Customer__c,curr);
            }
            //Validation Starts      
            for(AKA__c curr : AkaNewMap.values() ){
                if(AkaNewMap.get(curr.Id).Primary__c!=AkaOldMap.get(curr.id).Primary__c && AkaNewMap.get(curr.id).Primary__c== true && AkaNewMap.get(curr.id).Customer__c!=null && accountIdAkaMap.get(AkaNewMap.get(curr.Id).Customer__c)!=null ){
                    curr.addError('You can\'t create more than one primary AKA under account.');
                }
            }
        }
       
   }   
}