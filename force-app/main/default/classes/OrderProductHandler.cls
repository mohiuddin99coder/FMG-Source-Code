public class OrderProductHandler {
    public static void beforeInsertTrigger(list<OrderItem> OrderItemList){
        updateOrderDeliveryGroup(OrderItemList);
    }
    
    public static void updateOrderDeliveryGroup(list<OrderItem> OrderItemList){
        Set<id> OrderIdSet = getOrderId(OrderItemList);
        system.debug('OrderIdSet :'+OrderIdSet);
        Map<Id,Id> orderToOrderDeliveryGroupMap = getOrderDeliveryGroup(OrderIdSet);
        system.debug('orderToOrderDeliveryGroupMap :'+orderToOrderDeliveryGroupMap);
        map<string,string> OrderDeliveryMethodMap = new map<string,string>();
        //this list will hold the OI whose odg need to be created
        List<OrderItem> tempOrderItemList = new List<OrderItem>();
        for(OrderItem oi: OrderItemList){
            if(orderToOrderDeliveryGroupMap.containsKey(oi.OrderId) && orderToOrderDeliveryGroupMap.get(oi.OrderId)!= null){
                // odg alredy exists
                oi = populateOrderItemWithDeliveryMethod(oi,orderToOrderDeliveryGroupMap.get(oi.OrderId));
                System.debug('inside if condition oi value : '+oi);
            }else{
                System.debug(oi.Order_Shipping_Method__c);
                //odg not exists
                tempOrderItemList.add(oi);
                if(oi.Order_Shipping_Method__c != NULL){
                    OrderDeliveryMethodMap.put(oi.OrderId,oi.Order_Shipping_Method__c);
                }
            }
        }
        system.debug('OrderDeliveryMethodMap'+OrderDeliveryMethodMap);
        Map<String, Id> ODMMap = getOrderDeliveryMethod(OrderDeliveryMethodMap.values());
        system.debug('ODMMap :'+ODMMap);
        Set<Id> orderIdSetForNewODG = new Set<Id>();
        List<OrderDeliveryGroup> ODGList = createOrderDeliveryGroup(tempOrderItemList, OrderDeliveryMethodMap, ODMMap);
        if(ODGList!=null && ODGList.size()>0){
            for(OrderDeliveryGroup odg : ODGList){
                orderIdSetForNewODG.add(odg.OrderId);
                orderToOrderDeliveryGroupMap.put(odg.OrderId,odg.Id);
            }
            system.debug('orderItemSize'+tempOrderItemList.size());
            for(OrderItem oi: tempOrderItemList){
                if(orderToOrderDeliveryGroupMap.containsKey(oi.OrderId) && orderToOrderDeliveryGroupMap.get(oi.OrderId)!= null){
                    // updating with newly created ODG
                    oi = populateOrderItemWithDeliveryMethod(oi,orderToOrderDeliveryGroupMap.get(oi.OrderId));
                }
            }
            // now need to update the OLD OrderItems
            updateOrderItemWithDeliveryGroup(orderIdSetForNewODG,orderToOrderDeliveryGroupMap);
        }
        system.debug(orderToOrderDeliveryGroupMap);
    }
    public static void updateOrderItemWithDeliveryGroup(Set<Id> orderIdSet, Map<Id,Id> orderToOrderDeliveryGroupMap){
        list<OrderItem> ExistingOrderItemList = [select id,OrderDeliveryGroupId,OrderId,Type from OrderItem where OrderId=:OrderIdSet AND OrderDeliveryGroupId=NULL];
        for(OrderItem oi: ExistingOrderItemList){
            system.debug(orderToOrderDeliveryGroupMap.containsKey(oi.OrderId));
            if(orderToOrderDeliveryGroupMap.containsKey(oi.OrderId) && orderToOrderDeliveryGroupMap.get(oi.OrderId)!= null){
                // updating with newly created ODG
                oi = populateOrderItemWithDeliveryMethod(oi,orderToOrderDeliveryGroupMap.get(oi.OrderId));
            }
        }
        if(ExistingOrderItemList.size()>0){
            update ExistingOrderItemList;
        }
    }
    public static Set<Id> getOrderId(list<OrderItem> OrderItemList){
        Set<id> OrderIdSet = new Set<id>();
        for(OrderItem OI : OrderItemList){
            if(String.isNotBlank(OI.Order_Shipping_Method__c)){
                OrderIdSet.add(OI.OrderId);
            }
        }
        return OrderIdSet;
    }
    public static Map<Id,Id> getOrderDeliveryGroup(Set<Id> orderIdSet){
        Map<Id,Id> orderToOrderDeliveryGroupMap = new Map<Id,Id>();
        
        for(OrderDeliveryGroup odg: [select id,OrderId from OrderDeliveryGroup where OrderId=:orderIdSet]){
            orderToOrderDeliveryGroupMap.put(odg.OrderId, odg.Id);
            System.debug('odg id----->' + odg.Id);
        }
        for(Id orderId : orderIdSet){
            if(!orderToOrderDeliveryGroupMap.containsKey(orderId)){
                orderToOrderDeliveryGroupMap.put(orderId, null);
            }
        }
        return orderToOrderDeliveryGroupMap;
    }
    public static OrderItem populateOrderItemWithDeliveryMethod(OrderItem orderItem,Id OrderDeliveryGroupId){
        if(OrderDeliveryGroupId != null){
            orderItem.OrderDeliveryGroupId = OrderDeliveryGroupId;
        }
        if(orderItem.type == NULL){
            orderItem.Type ='Order Product';
        }
        return orderItem;
    }
    public static map<string, id> getOrderDeliveryMethod(List<String> deliveryMethodList){
        map<string, id> ODMMap = new map<string,id>();
       // map<id, string> odmToProdCode = new map<string,id>();

        map<id, string> prodMap = new map<id,string>();
        List<String> ProdList = new List<String>();
        list<product2> proList = [select id,productcode ,name from product2 where productcode=:deliveryMethodList];
        for(Product2 cur : proList){
            ProdList.add(cur.Id);
            prodMap.put(cur.Id,cur.ProductCode);
        }
        list<OrderDeliveryMethod> ODMlist = [select id,productId ,name from OrderDeliveryMethod where productId=:ProdList];
        System.debug('ODMlist----->' + ODMlist);
        
      /*  for(OrderDeliveryMethod OD : ODMlist){
            System.debug('productId----->' + OD.productId);
            ProdList.add(OD.productId);
        } */
        
     /*   System.debug('ProdList----->' + ProdList);
        Product2[] ODMProd = [SELECT Id, ProductCode From Product2 WHERE Id IN :ProdList];
        for(Product2 cur : proList){
            prodMap.put(cur.Id,cur.ProductCode);
        }*/
        System.debug('prodMap----->' + prodMap); 
        
     /*   for(OrderDeliveryMethod OD : ODMlist){
            odmToProdCode.put(OD.id ,prodMap.get(OD.productId) );
        }*/
        for(OrderDeliveryMethod OD : ODMlist){
            System.debug('prodcodeMap----->' + prodMap.get(OD.productId));
            ODMMap.put(prodMap.get(OD.productId),OD.id);
        }
        
        System.debug('ODMMap--->'+ ODMMap) ;
        
        return ODMMap;
    }
    public static List<OrderDeliveryGroup> createOrderDeliveryGroup(list<OrderItem> OrderItemList, map<string,string> OrderDeliveryMethodMap, map<string, id> ODMMap){
        List<OrderDeliveryGroup> OrderDeliveryGroupList = new List<OrderDeliveryGroup>();
        set<id> OrderIDs = new set<id>();
        for(OrderItem OI : OrderItemList){
            
            if(OrderDeliveryMethodMap.containsKey(OI.OrderId) && !(OrderIDs.contains(OI.OrderId))){
                OrderIDs.add(OI.OrderId);
                OrderDeliveryGroup ODG = new OrderDeliveryGroup();
                if(OI.Order_Shipping_City__c != NULL){
                    ODG.DeliverToCity = OI.Order_Shipping_City__c;
                }
                if(OI.Order_Shipping_Country_Code__c != NULL){
                    ODG.DeliverToCountry = OI.Order_Shipping_Country_Code__c;
                }
                system.debug('Order Account Name'+OI.Orders_Account_Name__c);
                if(String.isNotBlank(OI.Orders_Account_Name__c)){
                    ODG.DeliverToName = OI.Orders_Account_Name__c;
                }
                else{
                    ODG.DeliverToName = 'Tst Order Delivier Name';
                }
                
                if(OI.Order_Shipping_Zip_Postal_Code__c !=NULL){
                    ODG.DeliverToPostalCode = OI.Order_Shipping_Zip_Postal_Code__c ;
                }	
                if(OI.Order_Shipping_State_Code__c != NULL){
                    ODG.DeliverToState = OI.Order_Shipping_State_Code__c;
                }
                if(OI.Order_Shipping_Street__c != NULL){
                    ODG.DeliverToStreet = OI.Order_Shipping_Street__c;
                }
                //if(OI.Shipping_Total_Amount__c != Null) {
                //    ODG.TotalLineAmount = OI.Shipping_Total_Amount__c;
                // }
                ODG.EmailAddress = OI.Order_Account_Email_Address__c;
                ODG.OrderId = OI.OrderId;
                if(OI.Order_Shipping_Phone_number__c != NULL){
                    ODG.PhoneNumber =OI.Order_Shipping_Phone_number__c;
                }
                if(ODMMap.containsKey(OI.Order_Shipping_Method__c) && ODMMap.get(OI.Order_Shipping_Method__c) != NULL){
                    ODG.OrderDeliveryMethodId = ODMMap.get(OI.Order_Shipping_Method__c);
                    OrderDeliveryGroupList.add(ODG);
                }
            }
        }
        system.debug('OrderDeliveryGroupList-->'+OrderDeliveryGroupList);
        if(OrderDeliveryGroupList.size()>0){
            insert OrderDeliveryGroupList;
        }
        return OrderDeliveryGroupList;
    }
}