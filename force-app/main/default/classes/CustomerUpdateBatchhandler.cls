public class CustomerUpdateBatchhandler {
    public static Datetime currentDate = System.now();
    public static Integer startHours = 00;
    public static Integer startMinutes = 00;
    public static Integer startSeconds = 00;
    public static Integer endHours = 23;
    public static Integer endMinutes = 59;
    public static Integer endSeconds = 59;
    
    public static void updatePlatinumFields(List<Account> accountList){
        List<ID> accountIdList = new List<ID>();
        if(!accountList.isEmpty()){
            for(Account ac : accountList){
                accountIdList.add(ac.Id);
            }
        }
        updateLast365days(accountList,accountIdList);
        updatePlatinumCurrPeriodAmt(accountList,accountIdList);
        updatePlatinumTotalAmt(accountList,accountIdList);
        updatePlatinumPriorPeriod(accountList,accountIdList);
        System.debug('Final accountList is : '+accountList);
        if(!accountList.isEmpty()){
            update accountList;
        }
    }
    
    public static Map<Id,Decimal> getAccountOrderAmtMap(Datetime saleStartDate,Datetime saleEndDate,List<ID> accountIdList){
        Map<Id,Decimal> acIdOrderMap = new Map<Id,Decimal>();
        for(AggregateResult  objAgr: [SELECT  SUM(TotalAmount) total, AccountId from OrderSummary where CreatedDate>=:saleStartDate and CreatedDate<=:saleEndDate and Status NOT IN('Canceled','Returned') and AccountId IN :accountIdList GROUP BY AccountId]){
            System.debug('Total is : '+objAgr.get('total'));
            System.debug('Account Id is : '+objAgr.get('AccountId'));
            acIdOrderMap.put((ID)objAgr.get('AccountId'),(Decimal)objAgr.get('total'));
        }
        return acIdOrderMap;
    }
    
    public static Map<Id,Decimal> excludeRefund(Datetime saleStartDate,Datetime saleEndDate,Map<Id,Decimal> accIdOrderMap,Set<ID> accountIdSet){
        for(AggregateResult  objAgr:[select SUM(Amount) total,AccountId from Refund where CreatedDate>=:saleStartDate and CreatedDate<=:saleEndDate and Status='Processed' and AccountId IN :accountIdSet GROUP BY AccountId]){
            if(accIdOrderMap.containsKey((ID)objAgr.get('AccountId'))){
                Decimal refAmt = accIdOrderMap.get((ID)objAgr.get('AccountId')) - (Decimal)objAgr.get('total');
                accIdOrderMap.put((ID)objAgr.get('AccountId'),refAmt);
            }
        }
        return accIdOrderMap;
    }
    
    public static Map<Id,Decimal> excludeShipping(Datetime saleStartDate,Datetime saleEndDate,Map<Id,Decimal> accIdOrderMap,Set<ID> accountIdSet){
        for(AggregateResult  objAgr: [select SUM(TotalPrice) total, OrderSummary.AccountId from OrderItemSummary where OrderItemSummary.OrderSummary.AccountId IN :accountIdSet and (ProductCode='Shipping' or Name IN('Shipping','DeliveryFee')) and CreatedDate>=:saleStartDate and CreatedDate<=:saleEndDate and Status NOT IN('Canceled','Returned') GROUP BY OrderSummary.AccountId]){
            System.debug('In  getAccountOrderAmtMap method1: '+objAgr);
            System.debug('Total is : '+objAgr.get('total'));
            System.debug('Account Id is : '+objAgr.get('AccountId'));
            Decimal ShippingAmt = accIdOrderMap.get((ID)objAgr.get('AccountId')) - (Decimal)objAgr.get('total');
            accIdOrderMap.put((ID)objAgr.get('AccountId'),ShippingAmt);
        }
        return accIdOrderMap;
    }
    
    Public static void updateLast365days(List<Account> accountList,List<ID> accountIdList){
        System.debug('updateLast365days accountList : '+accountList);
        System.debug('updateLast365days accountList size : '+accountList.size());
        Datetime priorDate = CustomerUpdateBatchhandler.currentDate-1;
        Datetime saleDate = currentDate.addDays(-366);
        Datetime saleStartDate = Datetime.newInstanceGmt(saleDate.yearGMT(),saleDate.monthGmt(),saleDate.dayGmt(),CustomerUpdateBatchhandler.startHours,CustomerUpdateBatchhandler.startMinutes,CustomerUpdateBatchhandler.startSeconds);
        Datetime saleEndDate = Datetime.newInstanceGmt(priorDate.yearGMT(),priorDate.monthGmt(),priorDate.dayGmt(),CustomerUpdateBatchhandler.endHours,CustomerUpdateBatchhandler.endMinutes,CustomerUpdateBatchhandler.endSeconds);
        System.debug('sale start Date : '+saleStartDate);
        System.debug('saleEndDate is : '+saleEndDate);
        Map<Id,Decimal> accIdOrderAmtMap = new Map<Id,Decimal>();
        //   Map<ID,Decimal> updatedaccIdOrderAmtMap = new Map<ID,Decimal>();
        try{
            accIdOrderAmtMap = getAccountOrderAmtMap(saleStartDate, saleEndDate,accountIdList);
            //    accIdOrderAmtMap = excludeRefund(saleStartDate,saleEndDate,accIdOrderAmtMap,accIdOrderAmtMap.keySet());
            System.debug('updatedaccIdOrderAmtMap before is : '+accIdOrderAmtMap);
            accIdOrderAmtMap = excludeGiftCertificatePurchase(saleStartDate,saleEndDate,accIdOrderAmtMap,accIdOrderAmtMap.keySet());
            System.debug('accIdOrderAmtMap after exluding GC : '+accIdOrderAmtMap);
            accIdOrderAmtMap = excludeShipping(saleStartDate,saleEndDate,accIdOrderAmtMap,accIdOrderAmtMap.keySet());
            System.debug('updatedaccIdOrderAmtMap after exluding Shipping is : '+accIdOrderAmtMap);
            System.debug('accountList is : '+accountList);
            if(!accountList.isEmpty()){
                for(Account ac : accountList){
                    if(accIdOrderAmtMap.containsKey(ac.id)){
                        System.debug('inside if condition...');
                        ac.Perf365Days__c = accIdOrderAmtMap.get(ac.id);
                    }else{
                        System.debug('in last365days else part');
                        ac.Perf365Days__c=0;
                    }
                }
            }
            System.debug('end of try block:');
        }catch(Exception e){
            
            System.debug('Exception Message '+e.getMessage());
        }
    }
    
    public static void updatePlatinumCurrPeriodAmt(List<Account> accountList,List<ID> accountIdList){
        System.debug('updatePlatinumCurrPeriodAmt accountList : '+accountList);
        System.debug('updatePlatinumCurrPeriodAmt accountList size : '+accountList.size());
        Integer currentMonth = CustomerUpdateBatchhandler.currentDate.monthGMT();
        Datetime priorDate = currentDate-1;
        Datetime saleEndDate = Datetime.newInstanceGmt(priorDate.yearGMT(),priorDate.monthGmt(),priorDate.dayGmt(),CustomerUpdateBatchhandler.endHours,CustomerUpdateBatchhandler.endMinutes,CustomerUpdateBatchhandler.endSeconds);
        Map<Id,Decimal> accIdOrderAmtMap = new Map<Id,Decimal>();
        //    Map<ID,Decimal> updatedaccIdOrderAmtMap = new Map<ID,Decimal>();
        Datetime saleStartDate;
        try{
            if(currentMonth>=7){
                saleStartDate = Datetime.newInstanceGmt(currentDate.yearGMT(),7,1,CustomerUpdateBatchhandler.startHours,CustomerUpdateBatchhandler.startMinutes,CustomerUpdateBatchhandler.startSeconds);
            }else{
                saleStartDate = Datetime.newInstanceGMT(currentDate.yearGMT()-1,7,1,CustomerUpdateBatchhandler.startHours,CustomerUpdateBatchhandler.startMinutes,CustomerUpdateBatchhandler.startSeconds);
            }
            accIdOrderAmtMap = getAccountOrderAmtMap(saleStartDate,saleEndDate,accountIdList);
            //    accIdOrderAmtMap = excludeRefund(saleStartDate,saleEndDate,accIdOrderAmtMap,accIdOrderAmtMap.keySet());
            accIdOrderAmtMap = excludeGiftCertificatePurchase(saleStartDate,saleEndDate,accIdOrderAmtMap,accIdOrderAmtMap.keySet());
            accIdOrderAmtMap = excludeShipping(saleStartDate,saleEndDate,accIdOrderAmtMap,accIdOrderAmtMap.keySet());
            if(!accountList.isEmpty()){
                for(Account ac : accountList){
                    if(accIdOrderAmtMap.containsKey(ac.id)){
                        ac.PerfCurrPeriodAmt__c = accIdOrderAmtMap.get(ac.id);
                    }else{
                        System.debug('updatePlatinumCurrPeriodAmt else part');
                        ac.PerfCurrPeriodAmt__c = 0;
                    }
                    
                }
            }
        }catch(Exception e){
            System.debug('Exception Message : '+e.getMessage());
        }
    }
    
    public static void updatePlatinumTotalAmt(List<Account> accountList,List<ID> accountIdList){
        Datetime priorDate = CustomerUpdateBatchhandler.currentDate-1;
        Datetime saleEndDate = Datetime.newInstanceGmt(priorDate.yearGMT(),priorDate.monthGmt(),priorDate.dayGmt(),CustomerUpdateBatchhandler.endHours,CustomerUpdateBatchhandler.endMinutes,CustomerUpdateBatchhandler.endSeconds);
        Integer currentMonth = currentDate.monthGMT();
        Map<Id,Decimal> accIdOrderAmtMap = new Map<Id,Decimal>();
        //     Map<ID,Decimal> updatedaccIdOrderAmtMap = new Map<ID,Decimal>();
        Datetime saleStartDate;
        try{
            if(currentMonth>=7){
                saleStartDate = Datetime.newInstanceGmt(currentDate.yearGMT()-1,7,1,CustomerUpdateBatchhandler.startHours,CustomerUpdateBatchhandler.startMinutes,CustomerUpdateBatchhandler.startSeconds);
            }else{
                saleStartDate = Datetime.newInstanceGMT(currentDate.yearGMT()-2, 7,1,CustomerUpdateBatchhandler.startHours,CustomerUpdateBatchhandler.startMinutes,CustomerUpdateBatchhandler.startSeconds);
            }
            
            accIdOrderAmtMap = getAccountOrderAmtMap(saleStartDate,saleEndDate,accountIdList);
            //       accIdOrderAmtMap = excludeRefund(saleStartDate,saleEndDate,accIdOrderAmtMap,accIdOrderAmtMap.keySet());
            accIdOrderAmtMap = excludeGiftCertificatePurchase(saleStartDate,saleEndDate,accIdOrderAmtMap,accIdOrderAmtMap.keySet());
            accIdOrderAmtMap = excludeShipping(saleStartDate,saleEndDate,accIdOrderAmtMap,accIdOrderAmtMap.keySet());
            if(!accountList.isEmpty()){
                for(Account ac : accountList){
                    if(accIdOrderAmtMap.containsKey(ac.id)){
                        ac.PerfPlanTotalAmt__c = accIdOrderAmtMap.get(ac.id);
                    }else{
                        System.debug('updatePlatinumTotalAmt else part');
                        ac.PerfPlanTotalAmt__c = 0;
                    }
                }
            }
        }catch(Exception e){
            System.debug('Exception Message : '+e.getMessage());
        }
    }
    
    public static void updatePlatinumPriorPeriod(List<Account> accountList,List<ID> accountIdList){
        Integer currentMonth = CustomerUpdateBatchhandler.currentDate.monthGMT();
        Map<Id,Decimal> accIdOrderAmtMap = new Map<Id,Decimal>();
        //  Map<ID,Decimal> updatedaccIdOrderAmtMap = new Map<ID,Decimal>();
        Datetime saleStartDate;
        Datetime saleEndDate;
        
        if(currentMonth>=7){
            saleStartDate = Datetime.newInstanceGmt(currentDate.yearGMT()-1,7,1,CustomerUpdateBatchhandler.startHours,CustomerUpdateBatchhandler.startMinutes,CustomerUpdateBatchhandler.startSeconds);
            saleEndDate = Datetime.newInstanceGmt(currentDate.yearGMT(),7,1,CustomerUpdateBatchhandler.endHours,CustomerUpdateBatchhandler.endMinutes,CustomerUpdateBatchhandler.endSeconds);
        }else{
            saleStartDate = Datetime.newInstanceGMT(currentDate.yearGMT()-2, 7,1,CustomerUpdateBatchhandler.startHours,CustomerUpdateBatchhandler.startMinutes,CustomerUpdateBatchhandler.startSeconds);
            saleEndDate = Datetime.newInstanceGmt(currentDate.yearGMT()-1,7,1,CustomerUpdateBatchhandler.endHours,CustomerUpdateBatchhandler.endMinutes,CustomerUpdateBatchhandler.endSeconds);
        }
        try{
            accIdOrderAmtMap = getAccountOrderAmtMap(saleStartDate,saleEndDate,accountIdList);
            //       accIdOrderAmtMap = excludeRefund(saleStartDate,saleEndDate,accIdOrderAmtMap,accIdOrderAmtMap.keySet());
            accIdOrderAmtMap = excludeGiftCertificatePurchase(saleStartDate,saleEndDate,accIdOrderAmtMap,accIdOrderAmtMap.keySet());
            accIdOrderAmtMap = excludeShipping(saleStartDate,saleEndDate,accIdOrderAmtMap,accIdOrderAmtMap.keySet());
            if(!accountList.isEmpty()){
                for(Account ac : accountList){
                    if(accIdOrderAmtMap.containsKey(ac.id)){
                        ac.PlatinumPriorPeriod__c = accIdOrderAmtMap.get(ac.id);
                    }else{
                        System.debug('updatePlatinumPriorPeriod else part');
                        ac.PlatinumPriorPeriod__c = 0;
                    }
                }
            }
        }catch(Exception e){
            System.debug('Exception Message : '+e.getMessage());
        }
    }
    
    public static Map<Id,Decimal> excludeGiftCertificatePurchase(Datetime saleStartDate,Datetime saleEndDate,Map<Id,Decimal> accIdOrderMap,Set<ID> accountIdSet){
        List<OrderItemSummary> orderItemSumList = new List<OrderItemSummary>();
        
        orderItemSumList = [select id,OrderItemSummary.OrderSummary.AccountId,OrderSummary.Id,TotalAmtWithTax from OrderItemSummary where OrderSummary.AccountId IN :accountIdSet and ProductCode='eGiftCertificate' and CreatedDate>=:saleStartDate and CreatedDate<=:saleEndDate];
        System.debug('orderItemSumList is : '+orderItemSumList);
        System.debug('accIdOrderMap is : '+accIdOrderMap);
        for(OrderItemSummary orderItemSum : orderItemSumList){
            System.debug('OrderSummary.AccountId is : '+orderItemSum.OrderSummary.AccountId);
            if(accIdOrderMap.containsKey(orderItemSum.OrderSummary.AccountId)){
                System.debug('account id in exclude GC : '+orderItemSum.OrderSummary.AccountId);
                System.debug('orderItemSum.TotalAmtWithTax is : '+orderItemSum.TotalAmtWithTax);
                Decimal totalAmt = accIdOrderMap.get(orderItemSum.OrderSummary.AccountId) - (Decimal)orderItemSum.TotalAmtWithTax ;
                
                accIdOrderMap.put(orderItemSum.OrderSummary.AccountId,totalAmt);
            }
        }
        return accIdOrderMap;
    }
}