public class PhoneTriggerHandler {
    public static Set<Id> accountIdSet = new Set<Id>();
    public static Map<Id,ContactPointPhone> accountIdPhoneMap = new Map<Id,ContactPointPhone>();
    //Starting of logic to prevent user to create primary phone if there is existing primary phone under the Account
    public static void preventCreatePrimaryPhoneOnInsert(List<ContactPointPhone> PhoneList){
        for(ContactPointPhone Phone : PhoneList ){
            if(Phone.IsPrimary && Phone.ParentId!=null){
                accountIdSet.add(Phone.ParentId);
            }
        }
        if(accountIdSet!=null && accountIdSet.size()>0){
            //Preparation of Map AccountIdPhoneMap for Existing Primary Contact   
            for(ContactPointPhone PhoneNum:[select id,IsPrimary,ParentId from ContactPointPhone Where ParentId in:accountIdSet and IsPrimary=true]){
                accountIdPhoneMap.put(PhoneNum.ParentId,PhoneNum);
            } 
            // Validtaion Starts
            for(ContactPointPhone Phone : PhoneList){
                if(Phone.IsPrimary && Phone.ParentId!=null && accountIdPhoneMap.get(Phone.ParentId)!=null){
                    
                    Phone.addError('You can\'t create more than one primary Phone under account.');
                }
                
            }
            
        }
        
    } 
    //Starting of logic to prevent user to update another phone to primary phone if there is existing primary phone under the Account 
    public static void preventPrimaryPhoneOnUpdate(Map<Id,ContactPointPhone> PhoneNewMap,Map<Id,ContactPointPhone> PhoneOldMap){
        for(ContactPointPhone Phone : PhoneNewMap.values() ){
            if(PhoneNewMap.get(Phone.Id).IsPrimary!=PhoneOldMap.get(Phone.id).IsPrimary && PhoneNewMap.get(Phone.id).IsPrimary== true && PhoneNewMap.get(Phone.id).ParentId!=null){
                accountIdSet.add(PhoneNewMap.get(Phone.Id).ParentId);
            }
        }
        
        if(accountIdSet!=null && accountIdSet.size()>0){
            //preparation of Map accountIdPhoneMap for existing Primary phone       
            for(ContactPointPhone PhoneNum:[select id,IsPrimary,ParentId from ContactPointPhone Where ParentId in:accountIdSet and IsPrimary=true]){
                accountIdPhoneMap.put(PhoneNum.ParentId,PhoneNum);
            }
            //Validation Starts      
            for(ContactPointPhone Phone : PhoneNewMap.values() ){
                if(PhoneNewMap.get(Phone.Id).IsPrimary!=PhoneOldMap.get(Phone.id).IsPrimary && PhoneNewMap.get(Phone.id).IsPrimary== true && PhoneNewMap.get(Phone.id).ParentId!=null && accountIdPhoneMap.get(PhoneNewMap.get(Phone.Id).ParentId)!=null ){
                    Phone.addError('You can\'t create more than one primary Phone under account.');
                }
            }
        }
        
    }   
}