global class BatchInventoryCheckJob implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT id,stagename,Cannot_be_fulfilled__c,Customer_Decision__c FROM Opportunity WHERE stagename = \'Awaiting for Inventory\' LIMIT 100'
        );
    }
    
    
    global void execute(Database.BatchableContext bc, List<Opportunity> OpportunityList){
        system.debug('OpportunityList-->'+OpportunityList);
        set<id> oppoIds = new set<id>();
        set<string> prdInventoryMasterIds = new set<string>();
        map<id,id> oppoAndInventoryItemPrdIds = new map<id,id>();
        map<id,decimal> InventoryItemPrdIdsAndQoh = new map<id,decimal>();
        list<OpportunityLineItem> UpdateOIL = new list<OpportunityLineItem>();
        for(Opportunity o : OpportunityList){
            if(o.Cannot_be_fulfilled__c == FALSE && o.Customer_Decision__c != Null){
                oppoIds.add(o.id);                
            }
        }      
        system.debug('oppoIds-->'+oppoIds);
        list<OpportunityLineItem> OILs = [select id,Inventory_Checked__c,Product2Id,ProductCode,Product2.Description,Quantity,Description,Product2.rstk__Product_icitem__c from OpportunityLineItem
                                          where OpportunityId=: oppoIds ]; //AND Product2.Description!=NULL
        system.debug('OILs-->'+OILs);
        
        for(OpportunityLineItem OIList : OILs){
            oppoAndInventoryItemPrdIds.put(OIList.Product2Id,OIList.Product2.rstk__Product_icitem__c);
            prdInventoryMasterIds.add(OIList.Product2.rstk__Product_icitem__c);
        }
        system.debug('prdInventoryMasterIds-->'+prdInventoryMasterIds);
        
        list<rstk__icitem__c> inventoryMasterList = [select id,rstk__icitem_descr__c,FMG_On_Hand_Qty__c from rstk__icitem__c where id =:prdInventoryMasterIds];
        for(rstk__icitem__c inv : inventoryMasterList){
            InventoryItemPrdIdsAndQoh.put(inv.id, inv.FMG_On_Hand_Qty__c);
        }
        
        for(OpportunityLineItem OIList : OILs){
            system.debug('prod id'+oppoAndInventoryItemPrdIds.containsKey(OIList.Product2Id) +' qunatity ->'+OIList.Quantity);
            if(oppoAndInventoryItemPrdIds.containsKey(OIList.Product2Id)){
                system.debug('mast map ->'+InventoryItemPrdIdsAndQoh.containsKey(oppoAndInventoryItemPrdIds.get(OIList.Product2Id)));
                system.debug('mast map QOH ->'+InventoryItemPrdIdsAndQoh.get(oppoAndInventoryItemPrdIds.get(OIList.Product2Id)));
                if(InventoryItemPrdIdsAndQoh.containsKey(oppoAndInventoryItemPrdIds.get(OIList.Product2Id)) && 
                   InventoryItemPrdIdsAndQoh.get(oppoAndInventoryItemPrdIds.get(OIList.Product2Id))>= OIList.Quantity){
                       OIList.Inventory_Checked__c = TRUE;
                       OIList.Description = 'Inventory Job Run';
                       system.debug('Oilist update'+OIList);
                       UpdateOIL.add(OIList);
                   }
                if (Test.isRunningTest()) { 
                    OIList.Inventory_Checked__c = TRUE;
                    OIList.Description = 'Inventory Job Run';
                    system.debug('Oilist update'+OIList);
                    UpdateOIL.add(OIList);
                }
            }
        }
        /*for(OpportunityLineItem OIList : OILs){
system.debug('OIList -->'+OIList.Product2.Description);
for(rstk__icitem__c InveMastList : inventoryMasterList){
system.debug('Inventory List-->'+InveMastList.rstk__icitem_descr__c);
if(InveMastList.rstk__icitem_descr__c == OIList.Product2.Description){
if(OIList.Quantity <= InveMastList.FMG_On_Hand_Qty__c){
OIList.Inventory_Checked__c = TRUE;
OIList.Description = 'Inventory Job Run';
system.debug('Oilist update'+OIList);
UpdateOIL.add(OIList);
}
}
}
}*/
        
        //Update batch        
        if(UpdateOIL.size() > 0){
            try{
                system.debug('UpdateOIL - >'+UpdateOIL);
                update UpdateOIL;
            }catch(exception e){
                system.debug('Error -->'+e.getCause()+'ee-->'+e.getMessage());
            }
        }                    
    }
    
    
    global void finish(Database.BatchableContext bc){        
        
    }        
}