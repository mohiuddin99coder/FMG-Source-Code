public class RootStockCreateSalesOrder {
    @invocablemethod(label = 'Sales OrderHeader In Rstk' Description = 'Sales Order Creation In Rootstock' Category = 'Sales Order')
    Public static void createSalesOrder(List<Id> FulfillmentOrderId){
        Set<String> orderItemProductIds = new Set<String>();
        // Set<String> orderProductIds = new Set<String>();
        Map<String,String> customerNameMap = new map<String,String>();
        List<rstk__soline__c> solines = new list<rstk__soline__c>();
        Map<String,String> customerIdAddressMap = new map<String,String>();
        Map<String,rstk__socust__c> sfAccIdRSTKCustmerMap = new map<String,rstk__socust__c>();
        Map<String,String> sfProdIdtoRSTKprdMap = new map<String,String>();
        Map<String,String> productcodeOSIDmap = new map<String,String>();
        Map<String,String> shippingMethodMap = new map<String,String>();
        Map<String,String> shippingCarrierMap = new map<String,String>();
        Map<String,String> shipMethodByCarrierIDMap = new map<String,String>();
        Set<String> productCodes =new Set<String>();
        // instantiate a new header
        List<rstk__sohdr__c> sohdrList = new List<rstk__sohdr__c>();
        Set<String> orderSummaryIds = new Set<String>();
        Set<String> shipemthodIds = new Set<String>();
        Map<string,string> orderSummaryIDTransIdMap = new Map<string,string>();
        List<Integration_Log__c> logRecordsList = new List<Integration_Log__c>();
        
        Set<String> accIds = new Set<String>();
        
        // identify a sales division for the order
        try{
            rstk__sydiv__c salesDivision = [select Id, rstk__sydiv_mainsite__c from rstk__sydiv__c LIMIT 1];  
            rstk__sotax__c taxLocation =[select id from rstk__sotax__c LIMIT 1];
            List<rstk__sotax__c> taxLocationList =[select id,rstk__sotax_div__c from rstk__sotax__c ]; 
            List<FulfillmentOrder> fulfillmentOrderLst = [Select Id,Status,TotalDeliveryAmount,FulfillmentOrderNumber,OrderSummary.OriginalOrder.signatureRequired__c,GrandTotalAmount,AccountId,Account.Name,OrderSummaryId,OrderSummary.Is_Special_Order__c, OrderSummary.openAccountCredit__c,OrderSummary.OriginalOrder.OrderReferenceNumber,OrderSummary.OriginalOrder.OrderComment__c,OrderSummary.OriginalOrder.PONumber__c,OrderSummary.OriginalOrder.noCatalogInOrder__c,
                                                          OrderSummary.OriginalOrder.isCorrectionOrder__c,FulfilledToCountryCode,OrderSummary.OriginalOrder.Order_Notes__c,OrderSummary.OriginalOrder.thirdPartyCarrierAccountBilling__c,FulfilledToName,FulfilledToCity,FulfilledToCountry,FulfilledToEmailAddress,FulfilledToPhone,FulfilledToPostalCode,FulfilledToState,FulfilledToStreet,
                                                          (Select Id,Type,FulfillmentOrderId,Quantity,OrderItemId,OrderItem.Product2Id,OrderItem.Product2.ProductCode,OriginalQuantity,
                                                           TypeCode,UnitPrice,TotalLineAmount,TotalPrice,TotalAdjustmentAmount,TotalLineTaxAmount,
                                                           TotalAdjustmentTaxAmount,TotalTaxAmount,GrossUnitPrice,TotalLineAmountWithTax,
                                                           TotalAdjustmentAmountWithTax,TotalAmount from FulfillmentOrderLineItems where FulfillmentOrderId IN :FulfillmentOrderId) 
                                                          ,TotalDeliveryAmtWithTax,TotalDeliveryAdjustAmtWithTax from FulfillmentOrder where ID IN :FulfillmentOrderId];
            system.debug('FulfillmentOrderlst' +fulfillmentOrderLst);
            
            
            // populate division, order number, date
            
            if(!fulfillmentOrderLst.IsEmpty() && fulfillmentOrderLst != NULL){
                
                
                for(FulfillmentOrder foOrder :fulfillmentOrderLst){
                    if(foOrder.AccountId!=null){
                        accIds.add(foOrder.AccountId);
                    }
                    orderSummaryIds.add(foOrder.OrderSummaryId);
                    
                    for(FulfillmentOrderLineItem foLineItems :foOrder.FulfillmentOrderLineItems){
                        system.debug('foLineItems.Type==>'+foLineItems.TypeCode);
                        
                        // if(foLineItems.OrderItemId !=null  && foLineItems.OrderItem.Product2Id != NULL && foLineItems.TypeCode != 'Charge'){
                        if(foLineItems.OrderItemId !=null  && foLineItems.OrderItem.Product2Id != NULL){
                            system.debug('foLineItems.OrderItem.Product2Id ==>'+foLineItems.OrderItem.Product2Id );
                            orderItemProductIds.add(foLineItems.OrderItem.Product2Id);
                        }
                        /*if(foLineItems.OrderItemId !=null  && foLineItems.OrderItem.Product2Id != NULL && foLineItems.TypeCode =='Charge'){
system.debug('shippingCost inside charge==>'+shippingCost);
shippingCost = foLineItems.TotalAmount;  total amount with tax
}*/
                    }
                }
                for(OrderitemSummary orderitemsum:[select Id,ProductCode,Product2.Id,Type,OrderSummaryId from OrderItemSummary where OrderSummaryId IN:orderSummaryIds AND Type='Delivery Charge']){
                    System.debug('orderitemsum='+ orderitemsum);
                    productcodeOSIDmap.put(orderitemsum.OrderSummaryId, orderitemsum.ProductCode);
                    productCodes.add(orderitemsum.ProductCode);
                    System.debug('productcodeOSIDmap='+productcodeOSIDmap);
                }
                
                for(rstk__syshipviatype__c shippingMethod:[select id,Name,rstk__syshipviatype_id__c from rstk__syshipviatype__c where rstk__syshipviatype_id__c IN:productCodes]){
                    shippingMethodMap.put(shippingMethod.rstk__syshipviatype_id__c,shippingMethod.Id);
                    shipemthodIds.add(shippingMethod.Id);
                    System.debug('shippingMethodMap='+shippingMethodMap);
                }

                for(rstk__socarriervia__c shipByCarrier :[select id,rstk__socarriervia_carrier__c,rstk__socarriervia_shipvia__c from rstk__socarriervia__c where rstk__socarriervia_shipvia__c IN :shipemthodIds]){
                    shipMethodByCarrierIDMap.put(shipByCarrier.rstk__socarriervia_shipvia__c, shipByCarrier.rstk__socarriervia_carrier__c);
                }
                system.debug('shipMethodByCarrierIDMap==>'+shipMethodByCarrierIDMap);
                
                OrderPaymentSummary[] OrdPaymentSummaries = [SELECT id,OrderSummaryId,Type,CapturedAmount,OrderSummary.Is_Special_Order__c,OrderSummary.openAccountChequeNumber__c,
                                                            OrderSummary.openAccountCredit__c,Transaction_Id__c,Special_Order_Transaction_Id__c,AuthorizationAmount,
                                                            (SELECT id,GatewayRefNumber FROM PaymentAuthorizations WHERE GatewayRefNumber != NULL) 
                                                            FROM OrderPaymentSummary WHERE OrderSummaryId IN:orderSummaryIds];
                for(OrderPaymentSummary orPaymentSum : OrdPaymentSummaries){
                    if(orPaymentSum.OrderSummary.Is_Special_Order__c){
                        orderSummaryIDTransIdMap.put(orPaymentSum.OrderSummaryId,orPaymentSum.Special_Order_Transaction_Id__c);
                    }else{
                        for(PaymentAuthorization payAuth : orPaymentSum.PaymentAuthorizations){
                            orderSummaryIDTransIdMap.put(orPaymentSum.OrderSummaryId,payAuth.GatewayRefNumber);
                        }
                    }
                    /*if(orPaymentSum.Type == 'Unknown' && orPaymentSum.OrderSummary.openAccountCredit__c == false && orPaymentSum.OrderSummary.openAccountChequeNumber__c == NULL ){  // add new logic for gc redemption
                        System.debug('Inside Is Gc');
                        isGCRedeem = true;
                        gcauthorizedAmount = orPaymentSum.CapturedAmount;
                        system.debug('gcauthorized amount' + gcauthorizedAmount);
                    }*/
                }
                
                Set<String> rstkCustIds = new Set<String>();
                list<rstk__socust__c> rstkCustomer = [Select Id,Name,rstk__socust_sf_account__c,rstk__socust_custno__c From rstk__socust__c where rstk__socust_sf_account__c IN :accIds];
                system.debug(rstkCustomer);
                for(rstk__socust__c cust : rstkCustomer){
                    system.debug('Customer Name'+cust);
                    rstkCustIds.add(cust.id);
                    customerNameMap.put(cust.rstk__socust_sf_account__c, cust.Id);
                    sfAccIdRSTKCustmerMap.put(cust.rstk__socust_sf_account__c,cust);
                }
                system.debug('sfAccIdRSTKCustmerMap==>'+sfAccIdRSTKCustmerMap);
                
                for(rstk__soprod__c soProd :[select id,rstk__soprod_sf_product__c from rstk__soprod__c where rstk__soprod_sf_product__c IN:orderItemProductIds]){
                    sfProdIdtoRSTKprdMap.put(soProd.rstk__soprod_sf_product__c, soProd.id);
                }
                system.debug('sfProdIdtoRSTKprdMap==>'+sfProdIdtoRSTKprdMap);
                
                system.debug('fulfillmentOrderLst=>'+fulfillmentOrderLst);
                
                for(FulfillmentOrder foOrder :fulfillmentOrderLst){
                    system.debug('foOrder status==>'+foOrder.Status);
                    system.debug('sfAccIdRSTKCustmerMap==>'+sfAccIdRSTKCustmerMap);
                    if(!sfAccIdRSTKCustmerMap.isempty() && sfAccIdRSTKCustmerMap != NULL && sfAccIdRSTKCustmerMap.containskey(foOrder.AccountId) && sfAccIdRSTKCustmerMap.get(foOrder.AccountId) != NULL && sfAccIdRSTKCustmerMap.get(foOrder.AccountId).rstk__socust_custno__c != NULL){
                        rstk__soapi__c soHeader = new rstk__soapi__c();
                        
                        if(foOrder.AccountId != NULL && customerNameMap != NULL && !customerNameMap.isempty() && customerNameMap.containskey(foOrder.AccountId) && customerNameMap.get(foOrder.AccountId) != NULL){
                            soHeader.rstk__soapi_socust__c = customerNameMap.get(foOrder.AccountId);
                        }
                        soHeader.rstk__soapi_mode__c = 'Add Header';
                        soHeader.rstk__soapi_firm__c = true; //added new firming
                       soHeader.rstk__soapi_async__c = true;
                        //Start: below if condition is for Gift certificate to close SalesOrder Headers.
                        // GC SO Header are disabled in Rootstock
                        /*  if(foOrder.Status =='Fulfilled'){
system.debug('fo order is GC');
// 
// soHeader.rstk__soapi_closeorder__c =true;
//   soHeader.rstk__soapi_upgroup__c = foOrder.OrderSummary.OriginalOrder.OrderReferenceNumber+'- GC';
//   soHeader.rstk__soapi_orderno__c =foOrder.OrderSummary.OriginalOrder.OrderReferenceNumber+'- GC';
system.debug('fo order upload group GC===>'+soHeader.rstk__soapi_upgroup__c );
} */
                        system.debug('fo order is Normal');
                        if(foOrder.OrderSummary.Is_Special_Order__c && foOrder.GrandTotalAmount!=null && foOrder.GrandTotalAmount!=0){
                            soHeader.rstk__soapi_upgroup__c = foOrder.OrderSummary.OriginalOrder.OrderReferenceNumber;
                            soHeader.rstk__soapi_orderno__c = foOrder.OrderSummary.OriginalOrder.OrderReferenceNumber;
                            System.debug('!productcodeOSIDmap.isempty()-->'+!productcodeOSIDmap.isempty());
                            System.debug('productcodeOSIDmap.containskey(foOrder.OrderSummaryId)-->'+productcodeOSIDmap.containskey(foOrder.OrderSummaryId));
                            System.debug('productcodeOSIDmap.get(foOrder.OrderSummaryId) != NULL-->'+productcodeOSIDmap.get(foOrder.OrderSummaryId) != NULL);
                            System.debug('!shippingMethodMap.isempty() -->'+!shippingMethodMap.isempty() );
                            System.debug('shippingMethodMap.containskey(productcodeOSIDmap.get(foOrder.OrderSummaryId))-->'+shippingMethodMap.containskey(productcodeOSIDmap.get(foOrder.OrderSummaryId)));
                            System.debug('shippingMethodMap.get(productcodeOSIDmap.get(foOrder.OrderSummaryId)) != NULL-->'+shippingMethodMap.get(productcodeOSIDmap.get(foOrder.OrderSummaryId)) != NULL); 
                        }
                        else if(foOrder.GrandTotalAmount!=null && foOrder.GrandTotalAmount!=0){
                            soHeader.rstk__soapi_upgroup__c = foOrder.OrderSummary.OriginalOrder.OrderReferenceNumber;
                            soHeader.rstk__soapi_orderno__c =foOrder.OrderSummary.OriginalOrder.OrderReferenceNumber;
                            system.debug('fo order upload group Normal==>'+soHeader.rstk__soapi_upgroup__c );
                        }else {
                            String prefix = Label.ReshipOrderPrefix;    
                            soHeader.rstk__soapi_upgroup__c = prefix + foOrder.FulfillmentOrderNumber;
                            soHeader.rstk__soapi_orderno__c = prefix + foOrder.FulfillmentOrderNumber;
                            soHeader.Order_Summary__c = foOrder.OrderSummary.OriginalOrder.OrderReferenceNumber;
                        }
                        
                        //End 
                        
                        //Fulfilment_Order_ID__c
                        soHeader.rstk__soapi_customer__c=sfAccIdRSTKCustmerMap.get(foOrder.AccountId).rstk__socust_custno__c;
                        // soHeader.rstk__soapi_isocountry__c='US';
                        soHeader.rstk__soapi_email__c =foOrder.FulfilledToEmailAddress;
                        soHeader.rstk__soapi_conmethod__c='Email';
                        soHeader.rstk__soapi_taxloc__c =taxLocation.id; 
                        System.debug(' soHeader.rstk__soapi_taxloc__c-->'+ soHeader.rstk__soapi_taxloc__c);
                        System.debug(' taxLocation.id-->'+taxLocation.id);
                        soHeader.rstk__soapi_addstaddrovr__c =true;
                        soHeader.Order_Comment__c=foOrder.OrderSummary.OriginalOrder.Order_Notes__c;
                        soHeader.rstk__soapi_stname__c =foOrder.FulfilledToName;
                        soHeader.rstk__soapi_address1__c =foOrder.FulfilledToStreet;
                        //if street address contains special character ,then break it down into two lines
                        deliveryAddress__c address= deliveryAddress__c.getInstance();
                        String special = null;
                        if ( address != null ) 
                            special = address.addressline1__c;
                        System.debug('special-->'+special);
                        System.debug('foOrder.FulfilledToStreet!=null-->'+foOrder.FulfilledToStreet!=null);
                        System.debug('special != null-->'+special != null);
                        //    System.debug('foOrder.FulfilledToStreet.contains(special)-->'+foOrder.FulfilledToStreet.contains(special));
                        if(foOrder.FulfilledToStreet!=null && special != null && foOrder.FulfilledToStreet.contains(special) ){
                            String[] street=foOrder.FulfilledToStreet.split(special);
                            //  System.debug('street-->'+street);
                            if(street.size()>1){
                                soHeader.rstk__soapi_address1__c =street[0];
                                soHeader.rstk__soapi_address2__c =street[1];
                            }      
                        }   
                        
                        soHeader.signature_Required__c  = foOrder.OrderSummary.OriginalOrder.signatureRequired__c;//signature required
                        soHeader.No_Catalog_in_Order__c= foOrder.OrderSummary.OriginalOrder.noCatalogInOrder__c;
                        soHeader.Correction_Order__c=foOrder.OrderSummary.OriginalOrder.isCorrectionOrder__c;
                        soHeader.third_Party_Carrier_Account_Billing__c=foOrder.OrderSummary.OriginalOrder.thirdPartyCarrierAccountBilling__c;
                        soHeader.PO_Number__c=foOrder.OrderSummary.OriginalOrder.PONumber__c;
                        soHeader.rstk__soapi_extcomment__c=foOrder.OrderSummary.OriginalOrder.OrderComment__c;//comments related bug fix.    
                        soHeader.rstk__soapi_updatecustfields__c = true;//custom field update for signature required     
                        // soHeader.rstk__soapi_address2__c ='wave rock';
                        soHeader.rstk__soapi_city__c =foOrder.FulfilledToCity;
                        soHeader.rstk__soapi_state__c =foOrder.FulfilledToState;
                        soHeader.rstk__soapi_country__c =foOrder.FulfilledToCountry;
                        soHeader.rstk__soapi_zip__c =foOrder.FulfilledToPostalCode;
                        soHeader.rstk__soapi_email__c=foOrder.FulfilledToEmailAddress;
                        soHeader.rstk__soapi_phone__c=foOrder.FulfilledToPhone;
                        soHeader.rstk__soapi_isocountry__c = foOrder.FulfilledToCountryCode;
                        //system.debug('shippingCost==>'+shippingCost);
                        // soHeader.rstk__soapi_hdfreighatamt__c = shippingCost;
                        // soHeader.rstk__soapi_hdfreighatamt__c = foOrder.TotalDeliveryAmtWithTax + foOrder.TotalDeliveryAdjustAmtWithTax ;
                         //soHeader.rstk__soapi_hdfreighatamt__c = foOrder.TotalDeliveryAmount + foOrder.TotalDeliveryAdjustAmount ; 
                        //soHeader.rstk__soapi_updatecustfields__c = true;
                        
                        System.debug('shippingMethodMap.containskey(productcodeOSIDmap.get(foOrder.OrderSummaryId))='+shippingMethodMap.containskey(productcodeOSIDmap.get(foOrder.OrderSummaryId)));
                        System.debug('shippingMethodMap.containskey(productcodeOSIDmap.get(foOrder.OrderSummaryId))='+shippingMethodMap.containskey(productcodeOSIDmap.get(foOrder.OrderSummaryId)));
                        
                        if(!productcodeOSIDmap.isempty() && foOrder.OrderSummaryId != NULL && productcodeOSIDmap.containskey(foOrder.OrderSummaryId) && productcodeOSIDmap.get(foOrder.OrderSummaryId) != NULL
                        && !shippingMethodMap.isempty() && shippingMethodMap.containskey(productcodeOSIDmap.get(foOrder.OrderSummaryId)) 
                        && shippingMethodMap.get(productcodeOSIDmap.get(foOrder.OrderSummaryId)) != NULL){
                            soHeader.rstk__soapi_shipvia__c=shippingMethodMap.get(productcodeOSIDmap.get(foOrder.OrderSummaryId));
                        }

                        //carrier logic
                        system.debug('shipMethodByCarrierIDMap==>'+shipMethodByCarrierIDMap);
                        system.debug('soHeader.rstk__soapi_shipvia__c==>'+soHeader.rstk__soapi_shipvia__c);
                        system.debug('shipMethodByCarrierIDMap11==>'+shipMethodByCarrierIDMap.get(soHeader.rstk__soapi_shipvia__c));
                        if(!shipMethodByCarrierIDMap.isEmpty() && shipMethodByCarrierIDMap.containsKey(soHeader.rstk__soapi_shipvia__c) && shipMethodByCarrierIDMap.get(soHeader.rstk__soapi_shipvia__c) != NULL){
                            soHeader.rstk__soapi_carrier__c=shipMethodByCarrierIDMap.get(soHeader.rstk__soapi_shipvia__c);

                        }
                        System.debug('shippingCarrierMap='+ soHeader.rstk__soapi_carrier__c);
                        System.debug('shippingCarrierMap='+soHeader.rstk__soapi_shipvia__c);
                        // soHeader.rstk__soapi_upgroup__c = foOrder.OrderSummary.OriginalOrder.OrderReferenceNumber;
                        //below code is for pre-auth not for special orders
                        system.debug('orderSummaryIDTransIdMap.isempty()'+orderSummaryIDTransIdMap.isempty());
                        if(!orderSummaryIDTransIdMap.isempty() && !string.isblank(orderSummaryIDTransIdMap.get(foOrder.OrderSummaryId)) ){    
                            soHeader.rstk__soapi_ordpayamt__c  = foOrder.GrandTotalAmount; 
                            soHeader.rstk__soapi_ordpayid__c = orderSummaryIDTransIdMap.get(foOrder.OrderSummaryId);
                            //soHeader.rstk__soapi_ordpreauth__c = True;//need to uncomment
                            soHeader.rstk__soapi_clearccardorder__c = True;
                        }
                        
                        system.debug('soHeader  SOAPI==>'+soHeader);
                        insert soHeader;
                        
                        system.debug('header SOAPI==>'+soHeader.id);
                        
                        
                        
                        Set<string> headerIds = new set<string>();
                        headerIds.add(soHeader.id);
                        //string orderNumber = soHeader.rstk__soapi_orderno__c;
                        rstk__soapi__c soh = new rstk__soapi__c();
                        soh = [select id,rstk__soapi_orderno__c,rstk__soapi_socust__c,rstk__soapi_customer__c,rstk__soapi_sohdr__c from rstk__soapi__c where Id =: soHeader.id ];
                        
                        system.debug('header soh==>'+soh.id);   
                        
                        List<rstk__soapi__c> soLinesList = new List<rstk__soapi__c>();
                        for(FulfillmentOrderLineItem foLineItem :foOrder.FulfillmentOrderLineItems){
                            system.debug('header foLineItem==>'+foLineItem.id);   
                            
                            if(sfProdIdtoRSTKprdMap != NULL && !sfProdIdtoRSTKprdMap.isempty() && sfProdIdtoRSTKprdMap.containskey(foLineItem.OrderItem.Product2Id) && sfProdIdtoRSTKprdMap.get(foLineItem.OrderItem.Product2Id) != NULL ){
                                system.debug('header foLineItem inside normal==>'+foLineItem.id); 
                                rstk__soapi__c soLine = new rstk__soapi__c();
                                
                                soLine.rstk__soapi_mode__c = 'Add Line';
                                soLine.rstk__soapi_upgroup__c =soh.rstk__soapi_orderno__c;
                                // soLine.rstk__soapi_socust__c =soh.rstk__soapi_socust__c;
                                // soLine.rstk__soapi_customer__c=soh.rstk__soapi_customer__c;
                                soLine.rstk__soapi_sohdr__c = soh.rstk__soapi_sohdr__c;
                                soLine.rstk__soapi_qtyorder__c =foLineItem.Quantity;
                                // Decimal preTaxTotal = foLineItem.TotalPrice/foLineItem.Quantity;  pretax total
                                // soLine.rstk__soapi_price__c = preTaxTotal;// foLineItem.UnitPrice;
                                system.debug('soLine.rstk__soapi_price__c'+soLine.rstk__soapi_price__c);
                                // Double tax = double.valueOf(foLineItem.TotalLineTaxAmount);  line subtotal tax 
                                //soLine.rstk__soapi_taxamount__c = tax; 
                                //soLine.rstk__soapi_taxoverride__c =true;
                                system.debug('soLine.rstk__soapi_taxamount__c====>'+soLine.rstk__soapi_taxamount__c);
                                system.debug('so prod==>'+sfProdIdtoRSTKprdMap.get(foLineItem.OrderItem.Product2Id));
                                soLine.rstk__soapi_soprod__c =sfProdIdtoRSTKprdMap.get(foLineItem.OrderItem.Product2Id);
                                //soLine.rstk__soapi_product__c=foLineItem.OrderItem.Product2.ProductCode;
                                soLine.rstk__soapi_taxloc__c =taxLocation.id;
                                soLine.rstk__soapi_async__c = True;
                                soLine.rstk__soapi_firm__c = true; //added new firming
                                //soLine.rstk__soapi_price__c = (foLineItem.TotalPrice/foLineItem.Quantity).setScale(2);  
                                soLine.rstk__soapi_price__c = (foLineItem.TotalPrice/foLineItem.Quantity); // 15930 & 15975,rounding is cauising 01-29-2024
                                soLinesList.add(soLine);
                                System.debug('soline is : '+soLine);
                                //     insert soLine;
                                
                            }
                        }
                        String sh= soh.rstk__soapi_orderno__c;
                        for(OrderPaymentSummary orPaymentSum : OrdPaymentSummaries){
                            if(orPaymentSum.OrderSummaryId == foOrder.OrderSummaryId &&
                                orPaymentSum.Type == 'Unknown' && 
                                orPaymentSum.OrderSummary.openAccountCredit__c == false && 
                                orPaymentSum.OrderSummary.openAccountChequeNumber__c == NULL &&
                                !sh.startsWithIgnoreCase(System.Label.ReshipOrderPrefix)) {

                                rstk__soprod__c gcProduct = [Select Id from rstk__soprod__c where rstk__soprod_sf_product__r.name = 'GC REDEEM' LIMIT 1];
                                rstk__soapi__c soLine = new rstk__soapi__c();
                            
                                soLine.rstk__soapi_mode__c = 'Add Line';
                                soLine.rstk__soapi_upgroup__c =soh.rstk__soapi_orderno__c;
                                // soLine.rstk__soapi_socust__c =soh.rstk__soapi_socust__c;
                                // soLine.rstk__soapi_customer__c=soh.rstk__soapi_customer__c;
                                soLine.rstk__soapi_sohdr__c = soh.rstk__soapi_sohdr__c;
                                soLine.rstk__soapi_qtyorder__c = 1;
                                soLine.rstk__soapi_price__c = -orPaymentSum.CapturedAmount;
                                system.debug('soLine.rstk__soapi_price__c -->' + soLine.rstk__soapi_price__c);
                                soLine.rstk__soapi_soprod__c = gcProduct.Id;
                                soLine.rstk__soapi_taxloc__c =taxLocation.id;
                                soLine.rstk__soapi_async__c = True;
                                soLine.rstk__soapi_firm__c = true;
                                soLinesList.add(soLine);
                            }
                        }
                        if(soLinesList != NULL && !soLinesList.isempty()){
                            insert soLinesList; 
                        }
                        
                        system.debug('header SOAPI==>'+soLinesList);
                        
                        
                        //change header for pre-auth
                        if((!orderSummaryIDTransIdMap.isempty() &&orderSummaryIDTransIdMap.containskey(foOrder.OrderSummaryId) && !string.isblank(orderSummaryIDTransIdMap.get(foOrder.OrderSummaryId))) && soh.rstk__soapi_sohdr__c != NULL && foOrder.GrandTotalAmount > 0){ 
                            rstk__soapi__c soChangeHeader = new rstk__soapi__c();
                            soChangeHeader.rstk__soapi_mode__c = 'Change Header';
                            soChangeHeader.rstk__soapi_sohdr__c =soh.rstk__soapi_sohdr__c;
                            soChangeHeader.rstk__soapi_ordpayamt__c  = foOrder.GrandTotalAmount;
                            soChangeHeader.rstk__soapi_ordpayid__c = orderSummaryIDTransIdMap.get(foOrder.OrderSummaryId) ;
                            soChangeHeader.rstk__soapi_ordpreauth__c = true;
                            soChangeHeader.rstk__soapi_firm__c = true;//firmed status check
                            insert soChangeHeader;
                        }                        
                    }
                }
            }
        }
        catch(exception ex){
            //string exp ='';
            system.debug('exception line'+ex.getLineNumber());
            system.debug('exception msg'+ex.getMessage());
            system.debug('exception msg'+ex.getStackTraceString());
            string exMsg = ex.getMessage()+''+ex.getLineNumber()+''+ex.getTypeName();
            logRecordsList.add(APICallOutLogsCreation.createIntegrationLogRecord(orderSummaryIds,null,Null,exMsg,'RootStockCreateSalesOrder.createSalesOrder','Failure',null));            
            
            
        }
        insert logRecordsList;
    }
}