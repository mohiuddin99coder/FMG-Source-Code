global class Batch_ReleaseReservationAtLocationGroup implements Database.Batchable<sObject> {

    // Query Active products
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        if(Test.isRunningTest()){    
            String query1 = 'SELECT Id, Name, ProductCode, StockKeepingUnit FROM Product2 where isActive = True LIMIT 1 ';                
        return Database.getQueryLocator(query1);
            }
        String query = 'SELECT Id, Name, ProductCode, StockKeepingUnit FROM Product2 where isActive = True and Family!=\'Shipping\' and StockKeepingUnit!= null Order By CreatedDate';        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Product2> Productlist) {
        // if no products return
        if (ProductList.size() <= 0 ) return;

        // List to Store Skus
        List<String> skus = new List<String>();
        for(Product2 prd : ProductList) {
              skus.add(prd.StockKeepingUnit);
        }

        // get LocationGroup name
        String locationGroup = [SELECT LG_ExternalRef__c FROM OCILocationGroup__c].LG_ExternalRef__c;
        System.debug('locationGroup ' + locationGroup);

        // get Reservations at Location Group Level
        Map<String, Decimal> grpLevelReservations = getReservations(skus, locationGroup);

        // Release Reservations
        if (grpLevelReservations.Size() > 0) {
            ReleaseReservation(grpLevelReservations, locationGroup);
        }
    }

    global void finish(Database.BatchableContext BC) {        
    }

    public void ReleaseReservation(Map<String, Decimal> grpLevelReservations, String locationGroup) {

        List<ConnectApi.OCIReleaseReservationSingleInputRepresentation> lstSIP =  new List<ConnectApi.OCIReleaseReservationSingleInputRepresentation>();  
        ConnectApi.OCIReleaseReservationSingleInputRepresentation singleInputRep = new ConnectApi.OCIReleaseReservationSingleInputRepresentation();
        ConnectApi.OCIReleaseReservationInputRepresentation releaseInputRep = new ConnectApi.OCIReleaseReservationInputRepresentation();

        for(String sku : grpLevelReservations.keyset()) { 
            Decimal qty = grpLevelReservations.get(sku);
            if(qty > 0) {
               lstSIP.clear();
               singleInputRep.actionRequestId = sku + String.valueOf(Datetime.now());
               singleInputRep.locationGroupIdentifier = locationGroup;
               singleInputRep.quantity = qty.doubleValue();
               singleInputRep.stockKeepingUnit = sku;
               System.debug('Releasing at LG:' + singleInputRep);
               lstSIP.add(singleInputRep);  
               releaseInputRep.releaseRecords = lstSIP;
               ConnectApi.OCIReleaseReservationOutputRepresentation output = ConnectApi.OmnichannelInventoryService.releaseReservation(releaseInputRep);
               System.debug('Release Output===' + output); 
            }
               System.debug('stockKeepingUnit ' +  sku  + ' qty ' + qty) ;

        }
    }

    public Map<String, Decimal> getReservations(List<String> skus, String locationGroup) {
        Map<String, Decimal> skuQuantityMap = new Map<String, Decimal>();        
        try {
            ConnectApi.OCIGetInventoryAvailabilityInputRepresentation ociGetAvailability = new ConnectApi.OCIGetInventoryAvailabilityInputRepresentation();
            ociGetAvailability.stockKeepingUnits = skus;
            ociGetAvailability.locationGroupIdentifiers = new List<String>{locationGroup};
            ConnectApi.OCIGetInventoryAvailabilityOutputRepresentation ociGetOutput = ConnectApi.OmnichannelInventoryService.getInventoryAvailability(ociGetAvailability);
            System.debug(ociGetOutput);
            
            ConnectApi.OCILocationGroupAvailabilityOutputRepresentation locgrpAvail = ociGetOutput.locationGroups[0];
            for (ConnectApi.OCIInventoryRecordOutputRepresentation invOutRec : locgrpAvail.inventoryRecords ) {
                if(invOutRec.reserved > 0){
                skuQuantityMap.put(invOutRec.stockKeepingUnit, invOutRec.reserved);
                }
            }   
            System.debug('skuQuantityMap ' + skuQuantityMap);
            return skuQuantityMap; 
        } catch(Exception ex) {
            System.debug('exception line' + ex.getLineNumber());
            System.debug('exception msg' + ex.getMessage());
            System.debug('exception msg' + ex.getStackTraceString());
            Integration_Log__c IG = new Integration_Log__c();
            IG.Process_Name__c = 'Batch_ReleaseReservationAtLocationGroup.getReservations';
            IG.Remarks__c = ex.getLineNumber() + ' ' +ex.getMessage();
            IG.Record_Id_List__c = skus.toString() ;
            Insert IG; 
            return skuQuantityMap;
        }
    } 
}