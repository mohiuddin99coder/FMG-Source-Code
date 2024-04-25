public class updateCustomerLifetimeAttributesHandler {
    public static Datetime currentDate = System.now();
    public static Integer startHours = 00;
    public static Integer startMinutes = 00;
    public static Integer startSeconds = 00;
    public static Integer endHours = 23;
    public static Integer endMinutes = 59;
    public static Integer endSeconds = 59;
     
    public static void updateCustomerLifetimeAttributes(List<Account> accountList){
        List<ID> accountIdList = new List<ID>();
        if(!accountList.isEmpty()){
            for(Account ac : accountList){
                accountIdList.add(ac.Id);
            }
        }
        updateAllTotalOrderAmount(accountList,accountIdList);
        updateTotalOrderCount(accountList,accountIdList);
        updateLifetimeWithGC(accountList,accountIdList);
        
        System.debug('Final accountList is : '+accountList);
        if(!accountList.isEmpty()){
update accountList;
}
    }
    
    Public static void updateAllTotalOrderAmount(List<Account> accountList,List<ID> accountIdList){
        System.debug('updateLast365days accountList : '+accountList);
        System.debug('updateLast365days accountList size : '+accountList.size());
        Datetime priorDate = updateCustomerLifetimeAttributesHandler.currentDate-1;
        String startDate = Label.LegacyOrderDate;
        DateTime saleDate = DateTime.valueOf(startDate);
        Datetime saleStartDate = Datetime.newInstanceGmt(saleDate.yearGMT(),saleDate.monthGmt(),saleDate.dayGmt(),updateCustomerLifetimeAttributesHandler.startHours,updateCustomerLifetimeAttributesHandler.startMinutes,updateCustomerLifetimeAttributesHandler.startSeconds);
        Datetime saleEndDate = Datetime.newInstanceGmt(priorDate.yearGMT(),priorDate.monthGmt(),priorDate.dayGmt(),updateCustomerLifetimeAttributesHandler.endHours,updateCustomerLifetimeAttributesHandler.endMinutes,updateCustomerLifetimeAttributesHandler.endSeconds);
        System.debug('sale start Date : '+saleStartDate);
        System.debug('saleEndDate is : '+saleEndDate);
        Map<Id,Decimal> accIdOrderAmtMap = new Map<Id,Decimal>();
        Map<ID,Decimal> updatedaccIdOrderAmtMap = new Map<ID,Decimal>();
        try{
            accIdOrderAmtMap = getAccountOrderAmtMap(saleStartDate, saleEndDate,accountIdList);
            System.debug('accIdOrderAmtMap before is : '+accIdOrderAmtMap);
            accIdOrderAmtMap = excludeRefund(saleStartDate,saleEndDate,accIdOrderAmtMap,accountIdList);
            System.debug('accIdOrderAmtMap1 before is : '+accIdOrderAmtMap);
            updatedaccIdOrderAmtMap = excludeShipping(saleStartDate,saleEndDate,accIdOrderAmtMap,accountIdList);
            System.debug('updatedaccIdOrderAmtMap before is : '+updatedaccIdOrderAmtMap);
            System.debug('accountList is : '+accountList);
            if(!accountList.isEmpty()){
                for(Account ac : accountList){
                    System.debug('inside if condition...'+ac.id);
                    if(updatedaccIdOrderAmtMap.containsKey(ac.id)){
                        System.debug('inside if condition...');
                        ac.Total_Orders_Amount__c = updatedaccIdOrderAmtMap.get(ac.id);
                        System.debug('Total_Orders_Amount__c is : '+ac.Total_Orders_Amount__c);
                    }else{
                        System.debug('in last365days else part');
                        ac.Total_Orders_Amount__c=0;
                    }
                }
            }
            System.debug('end of try block:');
        }catch(Exception e){
            
            System.debug('Exception Message '+e.getMessage());
        }
    }
    
    //Update Order Count in Account
    Public static void updateTotalOrderCount(List<Account> accountList,List<ID> accountIdList){
        System.debug('updateLast365days accountList : '+accountList);
        System.debug('updateLast365days accountList size : '+accountList.size());
        Datetime priorDate = updateCustomerLifetimeAttributesHandler.currentDate-1;
        String startDate = Label.LegacyOrderDate;
        DateTime saleDate = DateTime.valueOf(startDate);
        Datetime saleStartDate = Datetime.newInstanceGmt(saleDate.yearGMT(),saleDate.monthGmt(),saleDate.dayGmt(),updateCustomerLifetimeAttributesHandler.startHours,updateCustomerLifetimeAttributesHandler.startMinutes,updateCustomerLifetimeAttributesHandler.startSeconds);
        Datetime saleEndDate = Datetime.newInstanceGmt(priorDate.yearGMT(),priorDate.monthGmt(),priorDate.dayGmt(),updateCustomerLifetimeAttributesHandler.endHours,updateCustomerLifetimeAttributesHandler.endMinutes,updateCustomerLifetimeAttributesHandler.endSeconds);
        System.debug('sale start Date : '+saleStartDate);
        System.debug('saleEndDate is : '+saleEndDate);
        Map<Id,Integer> accIdOrderAmtMap = new Map<Id,Integer>();
        Map<ID,Decimal> updatedaccIdOrderAmtMap = new Map<ID,Decimal>();
        try{
            accIdOrderAmtMap = getOrderCount(saleStartDate, saleEndDate,accountIdList);
            System.debug('updatedaccIdOrderAmtMap before is : '+accIdOrderAmtMap);
            System.debug('accountList is : '+accountList);
            if(!accountList.isEmpty()){
                for(Account ac : accountList){
                    System.debug('inside if condition...'+ac.id);
                    if(accIdOrderAmtMap.containsKey(ac.id)){
                        System.debug('inside if condition...');
                        ac.Life_Time_Order_Count__c = accIdOrderAmtMap.get(ac.id);
                        System.debug('Life_Time_Order_Count__c is : '+ac.Life_Time_Order_Count__c);
                    }else{
                        System.debug('in last365days else part');
                        ac.Life_Time_Order_Count__c=0;
                    }
                }
            }
            System.debug('end of try block:');
        }catch(Exception e){
            
            System.debug('Exception Message '+e.getMessage());
        }
    }
    
    //Updating Lifetime with GC account value
    Public static void updateLifetimeWithGC(List<Account> accountList,List<ID> accountIdList){
        System.debug('updateLast365days accountList : '+accountList);
        System.debug('updateLast365days accountList size : '+accountList.size());
        Datetime priorDate = updateCustomerLifetimeAttributesHandler.currentDate-1;
        String startDate = Label.LegacyOrderDate;
        DateTime saleDate = DateTime.valueOf(startDate);
        Datetime saleStartDate = Datetime.newInstanceGmt(saleDate.yearGMT(),saleDate.monthGmt(),saleDate.dayGmt(),updateCustomerLifetimeAttributesHandler.startHours,updateCustomerLifetimeAttributesHandler.startMinutes,updateCustomerLifetimeAttributesHandler.startSeconds);
        Datetime saleEndDate = Datetime.newInstanceGmt(priorDate.yearGMT(),priorDate.monthGmt(),priorDate.dayGmt(),updateCustomerLifetimeAttributesHandler.endHours,updateCustomerLifetimeAttributesHandler.endMinutes,updateCustomerLifetimeAttributesHandler.endSeconds);
        System.debug('sale start Date : '+saleStartDate);
        System.debug('saleEndDate is : '+saleEndDate);
        Map<Id,Decimal> accIdOrderAmtMap = new Map<Id,Decimal>();
        Map<ID,Decimal> updatedaccIdOrderAmtMap = new Map<ID,Decimal>();
        try{
            accIdOrderAmtMap = getLifetimeGCamount(saleStartDate, saleEndDate,accountIdList);
            System.debug('updatedaccIdOrderAmtMap before is : '+accIdOrderAmtMap);
            System.debug('accountList is : '+accountList);
            if(!accountList.isEmpty()){
                for(Account ac : accountList){
                    System.debug('inside if condition...'+ac.id);
                    if(accIdOrderAmtMap.containsKey(ac.id)){
                        System.debug('inside if condition...');
                        ac.Total_Gift_Certificate_Amount__c = accIdOrderAmtMap.get(ac.id);
                        System.debug('Total_Gift_Certificate_Amount__c is : '+ac.Total_Gift_Certificate_Amount__c);
                    }else{
                        System.debug('in last365days else part');
                        ac.Total_Gift_Certificate_Amount__c=0;
                        System.debug('Total_Gift_Certificate_Amount__c is : '+ac.Total_Gift_Certificate_Amount__c);
                    }
                }
            }
            System.debug('end of try block:');
        }catch(Exception e){
            
            System.debug('Exception Message '+e.getMessage());
        }
    }
    
    public static Map<Id,Decimal> excludeShipping(Datetime saleStartDate,Datetime saleEndDate,Map<Id,Decimal> accIdOrderMap,List<ID> accountIdList){
        for(AggregateResult  objAgr: [select SUM(UnitPrice) total, OrderSummary.AccountId from OrderItemSummary where OrderItemSummary.OrderSummary.AccountId IN :accountIdList and (ProductCode='Shipping' or Name IN('Shipping','DeliveryFee')) and Status NOT IN('Canceled','Returned') and CreatedDate>=:saleStartDate and CreatedDate<=:saleEndDate GROUP BY OrderSummary.AccountId]){
            System.debug('In  getAccountOrderAmtMap method1: '+objAgr);
            System.debug('Total is : '+objAgr.get('total'));
            System.debug('Account Id is : '+objAgr.get('AccountId'));
            Decimal ShippingAmt = accIdOrderMap.get((ID)objAgr.get('AccountId')) - (Decimal)objAgr.get('total');
                accIdOrderMap.put((ID)objAgr.get('AccountId'),ShippingAmt);
        }
        return accIdOrderMap;
    }
    
    public static Map<Id,Decimal> getLifetimeGCamount(Datetime saleStartDate,Datetime saleEndDate,List<ID> accountIdList){
        Map<Id,Decimal> acIdOrderMap = new Map<Id,Decimal>();
        for(AggregateResult  objAgr: [select SUM(AdjustedLineAmtWithTax) total, OrderSummary.AccountId from OrderItemSummary where OrderItemSummary.OrderSummary.AccountId IN :accountIdList and ProductCode='eGiftCertificate' and CreatedDate>=:saleStartDate and CreatedDate<=:saleEndDate GROUP BY OrderSummary.AccountId]){
            System.debug('Total is : '+objAgr.get('total'));
            System.debug('Account Id is : '+objAgr.get('AccountId'));
            acIdOrderMap.put((ID)objAgr.get('AccountId'),(Decimal)objAgr.get('total'));
        }
        return acIdOrderMap;
    }
    
    public static Map<Id,Integer> getOrderCount(Datetime saleStartDate,Datetime saleEndDate,List<ID> accountIdList){
        Map<Id,Integer> acIdOrderMap = new Map<Id,Integer>();
        for(AggregateResult  objAgr: [SELECT  COUNT(Id) recordCount, AccountId from OrderSummary where CreatedDate>=:saleStartDate and CreatedDate<=:saleEndDate and Status NOT IN('Canceled','Returned') and AccountId IN :accountIdList GROUP BY AccountId]){
            System.debug('Total is : '+objAgr.get('recordCount'));
            System.debug('Account Id is : '+objAgr.get('AccountId'));
            acIdOrderMap.put((ID)objAgr.get('AccountId'),(Integer)objAgr.get('recordCount'));
        }
        return acIdOrderMap;
    }
    
    public static Map<Id,Decimal> getAccountOrderAmtMap(Datetime saleStartDate,Datetime saleEndDate,List<ID> accountIdList){
        System.debug('accountIdList : '+accountIdList);
        System.debug('Total is : '+[SELECT  SUM(TotalAmount) total, AccountId from OrderSummary where CreatedDate>=:saleStartDate and CreatedDate<=:saleEndDate and Status NOT IN('Canceled','Returned') and AccountId IN :accountIdList GROUP BY AccountId]);
        Map<Id,Decimal> acIdOrderMap = new Map<Id,Decimal>();
        for(AggregateResult  objAgr: [SELECT  SUM(TotalAmount) total, AccountId from OrderSummary where CreatedDate>=:saleStartDate and CreatedDate<=:saleEndDate and Status NOT IN('Canceled','Returned') and AccountId IN :accountIdList GROUP BY AccountId]){
            System.debug('Total is : '+objAgr.get('total'));
            System.debug('Account Id is : '+objAgr.get('AccountId'));
            acIdOrderMap.put((ID)objAgr.get('AccountId'),(Decimal)objAgr.get('total'));
        }
        return acIdOrderMap;
    }
    
    public static Map<Id,Decimal> excludeRefund(Datetime saleStartDate,Datetime saleEndDate,Map<Id,Decimal> accIdOrderMap,List<ID> accountIdList){
        for(AggregateResult  objAgr:[select SUM(Amount) total,AccountId from Refund where CreatedDate>=:saleStartDate and CreatedDate<=:saleEndDate and Status='Processed' and AccountId IN :accountIdList GROUP BY AccountId]){
            if(accIdOrderMap.containsKey((ID)objAgr.get('AccountId'))){
                Decimal refAmt = accIdOrderMap.get((ID)objAgr.get('AccountId')) - (Decimal)objAgr.get('total');
                accIdOrderMap.put((ID)objAgr.get('AccountId'),refAmt);
            }
        }
        return accIdOrderMap;
    }
}