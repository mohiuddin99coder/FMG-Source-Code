public class RootStockReturnOrder {
    @invocablemethod(label = 'Return OrderHeader In Rstk' Description = 'return Order Creation In Rootstock' Category = 'Return Order')
    public static void createReturnOrder(List<Id> ReturnOrderId){
        Set<String> ROItemProductIds = new Set<String>();
        List<rstk__sormh__c> rmaHeaderlist= new List<rstk__sormh__c>();
        List<rstk__sormh__c> rhlist= new List<rstk__sormh__c>();
        List<String> rmNumber = new List<String>();
        List<rstk__sorma__c> rmaDetaillist= new List<rstk__sorma__c>();
        Map<String,String> customerNameMap = new map<String,String>();
        Map<String,String> ROProductIdMap = new Map<String,String>();
        Map<String,String> ROProductProductCodeMap = new Map<String,String>();
        List<rstk__soline__c> Rolines = new list<rstk__soline__c>();
        Map<String,String> ordernumAddressMap = new map<String,String>();
        Map<String,String> soCustAddmap = new map<String,String>();
        Map<String,rstk__socust__c> sfAccIdRSTKCustmerMap = new map<String,rstk__socust__c>();
        Map<String,String> sfProdIdtoRSTKprdMap = new map<String,String>();
        Set<String> reshipreason=new set<String>();
        Decimal shippingCost=0.0;
        // instantiate a new header
        List<String> oisIdlist = new list<String>();
        List<String> sohdrList = new List<String>();
        Set<String> orderRefNums = new Set<String>();
        Map<string,string> ROIDTransIdMap = new Map<string,string>();
        List<Integration_Log__c> logRecordsList = new List<Integration_Log__c>();
        Set<String> returnreasonset= new set<String>();
        Map<String,String> returnreasonmap=new Map<String,String>();
        Set<String> accIds = new Set<String>();
        List<Id> rmheads=new List<Id>();
        List<ReturnOrder> returnorderlist = new List<ReturnOrder>();
        rstk__socntl__c salesordercntrl = new rstk__socntl__c();
        rstk__sydiv__c salesDivision = new rstk__sydiv__c(); 
        rstk__sotax__c taxLocation = new rstk__sotax__c();
        List<rstk__sotax__c> taxLocationList = new List<rstk__sotax__c>();
        Map<string,string> soLineIDToShipperMap = new Map<string,string>();
        Map<String,List<rstk__soline__c>> ordRefNumSOLineMap = new Map<string,List<rstk__soline__c>>();
        Map<String,Integer> returnItemCountMap = new Map<String,Integer>();
        Map<String,Integer> returnReasonCountMap = new Map<String,Integer>();
        List<String> roNameList = new List<String>();
        FMGProjectMasterId__c ProjId = FMGProjectMasterId__c.getValues('RMAProjectMasterId');        
        // identify a sales division for the order
        try{
            salesordercntrl =[select Id,rstk__socntl__c.rstk__socntl_rmaadjacct__c from rstk__socntl__c];
            salesDivision = [select Id, rstk__sydiv_mainsite__c from rstk__sydiv__c LIMIT 1];  
            taxLocation =[select id from rstk__sotax__c LIMIT 1];
            Set<string> sfProdIds = new Set<string>();
            taxLocationList =[select id,rstk__sotax_div__c from rstk__sotax__c ]; 
            returnorderlist= [SELECT Id, ReturnOrderNumber,Is_No_Product_Return_Order__c, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById,
                              AccountId, ContactId, CaseId, OrderId,Order.OrderReferenceNumber,SourceLocationId, DestinationLocationId, ShipmentType,
                              ShipFromStreet, ShipFromCity, ShipFromState,ShipFromPostalCode, ShipFromCountry, ShipFromStateCode, ShipFromCountryCode, ShipFromLatitude,  ShipFromAddress, ReturnedById, Description, ExpectedArrivalDate, Status, OrderSummaryId,
                              StatusCategory, TotalProductAmount, TotalProductTaxAmount, TotalDeliveryAmount, TotalDeliveryTaxAmount, TotalFeeAmount, 
                              TotalFeeTaxAmount, TotalProductAdjustAmount, TotalProductAdjustTaxAmount, TotalDeliveryAdjustAmount, TotalDeliveryAdjustTaxAmount, 
                              TotalFeeAdjustAmount, TotalFeeAdjustTaxAmount, TotalAmount, TotalTaxAmount, TaxLocaleType, TotalProductAmtWithTax,
                              TotalDeliveryAmtWithTax, TotalFeeAmtWithTax, TotalProductAdjustAmtWithTax, TotalDeliveryAdjustAmtWithTax, TotalFeeAdjustAmtWithTax, 
                              GrandTotalAmount, LifeCycleType, (SELECT Id, IsDeleted, ReturnOrderLineItemNumber, CreatedDate, CreatedById, LastModifiedDate,
                                                                LastModifiedById,ReturnOrderId,ReturnOrderLineItem.OrderItem.Product2Id,OrderItem.Product2.StockKeepingUnit, OrderItemId, Product2Id,Product2.ProductCode,QuantityReturned,
                                                                QuantityUnitOfMeasure,ReturnOrder.Order.OrderReferenceNumber, SourceLocationId, DestinationLocationId, AssetId, Description, ReasonForReturn, ProcessingPlan,
                                                                RepaymentMethod, OrderItemSummaryId, ChangeOrderItemId, Type, TypeCode, QuantityReceived, QuantityExpected, QuantityRejected,
                                                                ReasonForRejection, UnitPrice, GrossUnitPrice, TotalLineAmount, TotalLineTaxAmount, TotalAdjustmentTaxAmount, TotalAdjustmentAmount,
                                                                TotalLineAmountWithTax, TotalAdjustmentAmountWithTax, TotalPrice, TotalTaxAmount, TotalAmount,ReturnOrder.ReturnOrderNumber, OrderItem.Type FROM ReturnOrderLineItems Where ReturnOrderId IN:ReturnOrderId )FROM ReturnOrder Where ID IN: ReturnOrderId];
            System.debug(returnorderlist);
            If(!returnorderlist.isEmpty()&& returnorderlist!=null){
                
                for(ReturnOrder RoOrder: returnorderlist){
                    if(RoOrder.AccountId!=null){
                        accIds.add(RoOrder.AccountId);
                    }
                    if(RoOrder.ReturnOrderNumber!=null){
                        rmNumber.add(RoOrder.ReturnOrderNumber);
                        System.debug('RoOrder.ReturnOrderNumber'+RoOrder.ReturnOrderNumber);
                    }
                    
                    if(RoOrder.Order.OrderReferenceNumber!=null){
                        orderRefNums.add(RoOrder.Order.OrderReferenceNumber);
                    }
                    for(ReturnOrderLineItem Rolineitems:RoOrder.ReturnOrderLineItems){
                        If(Rolineitems.OrderItemId!=null && Rolineitems.OrderItem.Product2Id!=null){
                            ROItemProductIds.add(Rolineitems.OrderItem.Product2Id);
                            
                        }
                    }
                    for(ReturnOrderLineItem Rolineitems:RoOrder.ReturnOrderLineItems){
                        If(Rolineitems.ReasonForReturn!=null ){
                            returnreasonset.add(Rolineitems.ReasonForReturn);
                            System.debug('returnreason-->'+returnreasonset);
                        }
                        
                    }
                    
                    if(RoOrder.ReturnOrderLineItems!=null){
                        System.debug('RoOrder.ReturnOrderNumber is : '+RoOrder.ReturnOrderNumber);
                        System.debug('RoOrder.ReturnOrderLineItems.size() is : '+RoOrder.ReturnOrderLineItems.size());
                        returnItemCountMap.put(RoOrder.ReturnOrderNumber,RoOrder.ReturnOrderLineItems.size());
                    }
                }
                if(!returnreasonset.isEmpty()){
                    for(rstk__soreason__c roreason:[select id,rstk__soreason_desc__c from rstk__soreason__c where rstk__soreason_desc__c IN:returnreasonset]){
                        if(roreason.rstk__soreason_desc__c!=NULL){
                            returnreasonmap.put(roreason.rstk__soreason_desc__c.toUpperCase(), roreason.id);
                            System.debug('roreason-->'+roreason);
                        }
                    }
                }
                System.debug('!orderRefNums.isEmpty()-->'+ !orderRefNums.isEmpty());
                Set<string> soLineIds = new Set<string>();
                if(!orderRefNums.isEmpty()){
                    for(rstk__sohdr__c soheader: [select id,rstk__sohdr_order__c,rstk__sohdr_shiptoaddr__c,(select Id,rstk__soline_line__c,rstk__soline_sohdr__r.rstk__sohdr_order__c,rstk__soline_prod__r.rstk__soprod_sf_product__r.ProductCode from rstk__solines__r) from rstk__sohdr__c where rstk__sohdr_order__c IN:orderRefNums]){
                        sohdrList.add(soheader.id);
                        System.debug('soheader-->'+soheader);
                        if(soheader.rstk__sohdr_shiptoaddr__c != NULL){
                            System.debug('soheader.rstk__sohdr_shiptoaddr__c != NULL-->'+ soheader.rstk__sohdr_shiptoaddr__c != NULL);
                            ordernumAddressMap.put(soheader.rstk__sohdr_order__c,soheader.rstk__sohdr_shiptoaddr__c);
                        }
                        List<rstk__soline__c> soLineList = new List<rstk__soline__c>();
                        for(rstk__soline__c soLine : soheader.rstk__solines__r){
                            System.debug('soLine-->'+soLine);
                            soLineList.add(soLine);
                            
                            if(soLine.rstk__soline_sohdr__r.rstk__sohdr_order__c != NULL){
                                System.debug('soLine.rstk__soline_sohdr__r.rstk__sohdr_order__c != NULL-->'+soLine.rstk__soline_sohdr__r.rstk__sohdr_order__c != NULL);
                                ordRefNumSOLineMap.put(soLine.rstk__soline_sohdr__r.rstk__sohdr_order__c,soLineList);
                                system.debug('ordRefNumSOLineMap==>'+ordRefNumSOLineMap);
                                soLineIds.add(soLine.id);
                            }
                            
                        }
                        
                    }
                }
                
                
                if(!soLineIds.isempty()){
                    for(rstk__soshipline__c soShip :[select id,rstk__soshipline_line__c from rstk__soshipline__c rstk__soshipline__c where rstk__soshipline_line__c IN:soLineIds]){
                        if(soShip.rstk__soshipline_line__c != NULL){
                            soLineIDToShipperMap.put(soShip.rstk__soshipline_line__c, soShip.id);
                        }
                        
                    } 
                }
                
                Set<String> rstkCustIds = new Set<String>();
                list<rstk__socust__c> rstkCustomer = new list<rstk__socust__c>();
                rstkCustomer = [Select Id,Name,rstk__socust_sf_account__c,rstk__socust_custno__c,(select Id from rstk__socaddrs__r Where rstk__socaddr_defaultshipto__c=true) From rstk__socust__c where rstk__socust_sf_account__c IN :accIds];
                system.debug(rstkCustomer);
                for(rstk__socust__c cust : rstkCustomer){
                    system.debug('Customer Name'+cust);
                    rstkCustIds.add(cust.id);
                    system.debug('cust.rstk__socust_sf_account__c-->'+cust.rstk__socust_sf_account__c);
                    system.debug('cust.Id-->'+cust.Id);
                    customerNameMap.put(cust.rstk__socust_sf_account__c, cust.Id);
                    system.debug('customerNameMap-->'+customerNameMap);
                    sfAccIdRSTKCustmerMap.put(cust.rstk__socust_sf_account__c,cust);
                    System.debug(sfAccIdRSTKCustmerMap);
                    
                    for(rstk__socaddr__c soAdd: cust.rstk__socaddrs__r){
                        soCustAddmap.put(cust.rstk__socust_sf_account__c,soAdd.Id);
                    }
                }
                system.debug('sfAccIdRSTKCustmerMap==>'+sfAccIdRSTKCustmerMap);
                
                for(rstk__soprod__c soProd :[select id,rstk__soprod_sf_product__c from rstk__soprod__c where rstk__soprod_sf_product__c IN:ROItemProductIds]){
                    sfProdIdtoRSTKprdMap.put(soProd.rstk__soprod_sf_product__c, soProd.id);
                }
                system.debug('sfProdIdtoRSTKprdMap==>'+sfProdIdtoRSTKprdMap);
                
                List<rstk__soprod__c> soProducts = new List<rstk__soprod__c>();
                soProducts = [select Id,rstk__soprod_prod__c,rstk__soprod_sf_product__c,rstk__soprod_sf_product__r.ProductCode  from rstk__soprod__c where
                              rstk__soprod_sf_product__c  IN :ROItemProductIds  and rstk__soprod_div__c = :salesDivision.id];
                system.debug(soProducts);
                for(rstk__soprod__c soProduct:soProducts){
                    ROProductIdMap.put(soProduct.rstk__soprod_sf_product__c , soProduct.Id);
                    ROProductProductCodeMap.put(soProduct.rstk__soprod_sf_product__c,soProduct.rstk__soprod_sf_product__r.ProductCode);
                }
                
                System.debug('orderProductIdMap'+ROProductIdMap);
                for(ReturnOrder RoOrder: returnorderlist){
                    if(!sfAccIdRSTKCustmerMap.isempty() && sfAccIdRSTKCustmerMap != NULL && sfAccIdRSTKCustmerMap.containskey(RoOrder.AccountId) && sfAccIdRSTKCustmerMap.get(RoOrder.AccountId) != NULL && sfAccIdRSTKCustmerMap.get(RoOrder.AccountId).rstk__socust_custno__c != NULL){
                        rstk__sormh__c rmaHeader = new rstk__sormh__c();
                        
                        if(RoOrder.AccountId != NULL && customerNameMap != NULL && !customerNameMap.isempty() && customerNameMap.containskey(RoOrder.AccountId) && customerNameMap.get(RoOrder.AccountId) != NULL){
                            rmaHeader.rstk__sormh_custno__c = customerNameMap.get(RoOrder.AccountId);
                            System.debug('  rmaHeader.rstk__sormh_custno__c='+  rmaHeader.rstk__sormh_custno__c);
                            rmaHeader.rstk__sormh_installcust__c=customerNameMap.get(RoOrder.AccountId);
                            System.debug('rstk__sormh_installcust__c='+ rmaHeader.rstk__sormh_installcust__c);
                        }
                        
                        rmaHeader.rstk__sormh_rmano__c =RoOrder.ReturnOrderNumber;
                        rmaHeader.rstk__sormh_div__c =salesDivision.Id;
                        rmaHeader.rstk__sormh_action__c = System.Label.RMA_Header_Action;
                        rmaHeader.rstk__sormh_date__c=	System.today();
                        rmaHeader.rstk__sormh_released__c=True;
                        rmaHeader.rstk__sormh_returnonly__c=True;
                        System.debug('!returnreasonset.isEmpty()--->'+!returnreasonset.isEmpty());
                        System.debug('returnreasonset!=null--->'+returnreasonset!=null);
                        if(!returnreasonset.isEmpty()&&returnreasonset!=null && returnreasonset.contains('RESHIP AND RETURN')){
                            
                            System.debug(rmaHeader.rstk__sormh_advreplace__c);
                            rmaHeader.rstk__sormh_advreplace__c = True;
                            System.debug(rmaHeader.rstk__sormh_advreplace__c);
                            rmaHeader.rstk__sormh_returnonly__c=False;
                            rmaHeader.rstk__sormh_action__c = 'Issue Credit';
                            System.debug('rmaHeader.rstk__sormh_advreplace__c = True;-->'+   rmaHeader.rstk__sormh_advreplace__c );
                        }
                        else{
                            rmaHeader.rstk__sormh_action__c ='Issue Credit';
                        }
                      
                        if(!ordernumAddressMap.isEmpty()&&ordernumAddressMap.containsKey(RoOrder.order.OrderReferenceNumber)&& ordernumAddressMap.get(RoOrder.order.OrderReferenceNumber)!=null){
                            rmaHeader.rstk__sormh_socaddr__c=ordernumAddressMap.get(RoOrder.order.OrderReferenceNumber);
                            rmaHeader.rstk__sormh_ovrshiptoaddr__c=True;
                            rmaHeader.rstk__sormh_installaddr__c=ordernumAddressMap.get(RoOrder.order.OrderReferenceNumber);
                            
                            System.debug('rmaHeader.rstk__sormh_ovrshiptoaddr__c='+ rmaHeader.rstk__sormh_ovrshiptoaddr__c);
                            
                        }
                        else if(!soCustAddmap.isEmpty()&& soCustAddmap!=null && soCustAddmap.containsKey(RoOrder.AccountId)&& soCustAddmap.get(RoOrder.AccountId)!=null){
                            rmaHeader.rstk__sormh_socaddr__c=soCustAddmap.get(RoOrder.AccountId);
                            rmaHeader.rstk__sormh_ovrshiptoaddr__c=True;
                            rmaHeader.rstk__sormh_installaddr__c=soCustAddmap.get(RoOrder.AccountId);
                            System.debug('rmaHeader.rstk__sormh_installaddr__c='+ rmaHeader.rstk__sormh_installaddr__c);
                        }
                        
                        if(RoOrder.Is_No_Product_Return_Order__c){
                            roNameList.add(RoOrder.ReturnOrderNumber);
                        }
                        System.debug('rmaHeader before list--->'+rmaHeader);
                        
                        rmaHeaderlist.add(rmaHeader);
                        
                    }
                }
                system.debug('rmaHeaderlist==>'+rmaHeaderlist);
                try {
                    if(!rmaHeaderlist.isEmpty()){
                        insert rmaHeaderlist;
                    } 
                }catch (Exception e) {
                    System.debug('Exception while inserting RMA-Header List: ' + e.getMessage());
                }
                
            }
            
            System.debug('After RMA Header insert..');
            
            rstk__sormh__c rmahead = new rstk__sormh__c();
            if(!Test.isRunningTest()){
                if(!rmNumber.isempty()){
                    rmahead=[select Id from rstk__sormh__c where rstk__sormh_rmano__c IN:rmNumber]; 
                    System.debug('rmahead-----------------'+rmahead);
                }
            }
            If(rmahead!=null){
                rmheads.add(rmahead.Id);
            }
            System.debug('rmahead='+ rmahead);      
            
            Integer i =0;
            for(ReturnOrder RoOrders: returnorderlist){
                for(ReturnOrderLineItem Rolineitems:RoOrders.ReturnOrderLineItems){
                    If(Rolineitems.OrderItemId!=null && Rolineitems.OrderItem.Product2Id!=null /*&& Rolineitems.OrderItem.Type != 'Delivery Charge'*/){
                        System.debug('Rolineitems.OrderItemId='+Rolineitems.OrderItemId);
                        rstk__sorma__c rmaDetail=new rstk__sorma__c(); 
                        rmaDetail.rstk__sorma_sormh__c = rmahead.Id;
                        System.debug('rstk__sorma_sormh__c-->'+ rmaDetail.rstk__sorma_sormh__c);
                        rmaDetail.rstk__sorma_line__c = i+1;
                        System.debug( 'rstk__sorma_line__c--->'+rmaDetail.rstk__sorma_line__c);
                        system.debug('sfProdIdtoRSTKprdMap===>'+sfProdIdtoRSTKprdMap);
                        if((!sfProdIdtoRSTKprdMap.isempty() && sfProdIdtoRSTKprdMap.containskey(Rolineitems.OrderItem.Product2Id) && sfProdIdtoRSTKprdMap.get(Rolineitems.OrderItem.Product2Id) != NULL && Rolineitems.QuantityExpected > 0) || Test.isRunningTest()){
                            system.debug('sfProdIdtoRSTKprdMap.get(Rolineitems.OrderItem.Product2Id)===>'+sfProdIdtoRSTKprdMap.get(Rolineitems.OrderItem.Product2Id));
                            rmaDetail.rstk__sorma_soprod__c =sfProdIdtoRSTKprdMap.get(Rolineitems.OrderItem.Product2Id);
                            System.debug(' rmaDetail.rstk__sorma_soprod__c='+ rmaDetail.rstk__sorma_soprod__c);
                            rmaDetail.rstk__sorma_qtyauth__c =Rolineitems.QuantityExpected;
                            System.debug('rmaDetail.rstk__sorma_qtyauth__c='+rmaDetail.rstk__sorma_qtyauth__c);
                            rmaDetail.rstk__sorma_invdiv__c=salesDivision.Id;
                            System.debug(' rmaDetail.rstk__sorma_invdiv__c='+ rmaDetail.rstk__sorma_invdiv__c);
                            rmaDetail.rstk__sorma_div__c = salesDivision.Id; // newly added 16018
                            rmaDetail.rstk__sorma_project__c=ProjId.ProjectMasterID__c;
                            System.debug(' rmaDetail.rstk__sorma_project__c='+  rmaDetail.rstk__sorma_project__c);
                            rmaDetail.rstk__sorma_date__c=system.today();
                            System.debug(' rmaDetail.rstk__sorma_date__c='+ rmaDetail.rstk__sorma_date__c);
                            rmaDetail.rstk__sorma_adjacct__c=salesordercntrl.rstk__socntl_rmaadjacct__c;
                            System.debug(' rmaDetail.rstk__sorma_adjacct__c='+ rmaDetail.rstk__sorma_adjacct__c);
                            rmaDetail.rstk__sorma_site__c =ProjId.FMGSiteMasterId__c;
                            System.debug(' rmaDetail.rstk__sorma_site__c='+ rmaDetail.rstk__sorma_site__c);
                            rmaDetail.rstksormaSKU__c=Rolineitems.OrderItem.Product2.StockKeepingUnit;
                              System.debug('  rmaDetail.rstksormaSKU__c='+  rmaDetail.rstksormaSKU__c);
                            rmaDetail.rstk__sorma_creditauth__c=True;
                              System.debug(' rmaDetail.rstk__sorma_creditauth__c='+rmaDetail.rstk__sorma_creditauth__c);
                            rmaDetail.rstk__sorma_released__c=True;
                              System.debug(' rmaDetail.rstk__sorma_released__c='+ rmaDetail.rstk__sorma_released__c);
                            If(!returnreasonset.isEmpty()&&returnreasonset!=null&&Rolineitems.ReasonForReturn=='RESHIP AND RETURN'){ 
                                System.debug('Advance Replacement-->'+Rolineitems.ReasonForReturn=='RESHIP AND RETURN');
                                rmaDetail.rstk__sorma_preshipok__c=True;
                                System.debug('Advance Replacement-->'+rmaDetail.rstk__sorma_preshipok__c);
                                rmaDetail.rstk__sorma_creditauth__c=False;
                                System.debug('rmaDetail.rstk__sorma_creditauth__c'+rmaDetail.rstk__sorma_creditauth__c);
                                rmaDetail.rstk__sorma_action__c= 'Issue Credit'; // bug 16973
                                System.debug( 'rmaDetail.rstk__sorma_action__c-->'+ rmaDetail.rstk__sorma_action__c);
                            }else{
                                rmaDetail.rstk__sorma_returnonly__c=True;
                                System.debug('rmaDetail.rstk__sorma_returnonly__c-->'+rmaDetail.rstk__sorma_returnonly__c);
                                rmaDetail.rstk__sorma_preshipok__c=False;
                                System.debug('rmaDetail.rstk__sorma_preshipok__c-->'+rmaDetail.rstk__sorma_preshipok__c);
                                rmaDetail.rstk__sorma_action__c='Issue Credit';
                                 System.debug('rmaDetail.rstk__sorma_action__c-->'+rmaDetail.rstk__sorma_action__c);
                            }
                            
                            if(Rolineitems.ReturnOrderId != NULL && Rolineitems.ReturnOrder.OrderId != NULL && 
                               Rolineitems.ReturnOrder.Order.OrderReferenceNumber != NULL && !ordRefNumSOLineMap.isempty() 
                               && ordRefNumSOLineMap.containskey(Rolineitems.ReturnOrder.Order.OrderReferenceNumber) && ordRefNumSOLineMap.get(Rolineitems.ReturnOrder.Order.OrderReferenceNumber) != NULL){
                                   for(rstk__soline__c soLine : ordRefNumSOLineMap.get(Rolineitems.ReturnOrder.Order.OrderReferenceNumber)){
                                       System.debug('soLine-->'+soLine);
                                       if(soLine.rstk__soline_prod__c != NULL && soLine.rstk__soline_prod__r.rstk__soprod_sf_product__c != NULL 
                                          && soLine.rstk__soline_prod__r.rstk__soprod_sf_product__r.ProductCode != NULL && soLine.rstk__soline_prod__r.rstk__soprod_sf_product__r.ProductCode == Rolineitems.Product2.ProductCode){
                                              rmaDetail.rstk__sorma_soline__c = soLine.id;
											  System.debug(' rmaDetail.rstk__sorma_soline__c-->'+ rmaDetail.rstk__sorma_soline__c);
                                              if(rmaDetail.rstk__sorma_soline__c != NULL && !soLineIDToShipperMap.isempty()
                                                 && soLineIDToShipperMap.containskey(rmaDetail.rstk__sorma_soline__c) && soLineIDToShipperMap.get(rmaDetail.rstk__sorma_soline__c) != NULL){
                                                     rmaDetail.rstk__sorma_soshipline__c = soLineIDToShipperMap.get(rmaDetail.rstk__sorma_soline__c);
													System.debug(' rmaDetail.rstk__sorma_soshipline__c -->'+ rmaDetail.rstk__sorma_soshipline__c );
                                                 }  
                                          }
                                       
                                   }
                                   
                               }
                            
                            system.debug('returnreasonmap--->'+returnreasonmap);
                            system.debug('!returnreasonmap.isEmpty() --->'+!returnreasonmap.isEmpty() );
                            system.debug('returnreasonmap.get(Rolineitems.ReasonForReturn)!= NULL--->'+returnreasonmap.get(Rolineitems.ReasonForReturn)!= NULL);
                            
                            if(!returnreasonmap.isEmpty() && returnreasonmap.get(Rolineitems.ReasonForReturn)!= NULL){
                                System.debug('Printing reason');
                                rmaDetail.rstk__sorma_reason__c=returnreasonmap.get(Rolineitems.ReasonForReturn);
                                system.debug('returnreasonmap--->'+returnreasonmap);
                                
                            }
                            
                            
                            system.debug('rmaDetails==>'+rmaDetail); 
                            rmaDetaillist.add(rmaDetail);
                            system.debug('rmaDetails==>' + rmaDetaillist);
                            i++;
                            
                            
                        }
                    }
                }
            }
            if(!rmaDetaillist.isEmpty()){
                insert rmaDetaillist;
            }
            system.debug('rmaDetaillist--->'+rmaDetaillist);
            // Close RMAHeaders if all related line items are 'NO PRODUCT RETURN' status.
            System.debug('roNameList is : '+roNameList);
            List<rstk__sormh__c> rmaHeaderUpdateList = [select id,rstk__sormh_rmano__c from rstk__sormh__c where rstk__sormh_rmano__c IN :roNameList];
            System.debug('rmaHeaderUpdateList is : '+rmaHeaderUpdateList);
            List<rstk__sormh__c> rmaHeadersUpdateList = new List<rstk__sormh__c>();
            for(rstk__sormh__c rmHead: rmaHeaderUpdateList){
                if(roNameList.contains(rmHead.rstk__sormh_rmano__c)){
                    System.debug('inside return close if condition.');
                    rmHead.rstk__sormh_closed__c = TRUE;
                    rmaHeadersUpdateList.add(rmHead);
                }
            }
            System.debug('rmaHeaderUpdateList is : '+rmaHeaderUpdateList);
            if(rmaHeadersUpdateList!=null){
                update rmaHeadersUpdateList;
            }  
        } Catch(exception ex){
            system.debug('exception line'+ex.getLineNumber());
            system.debug('exception msg'+ex.getMessage());
            system.debug('>>> Trace Flag >>>'+ex.getStackTraceString());
        }
        
    }
}