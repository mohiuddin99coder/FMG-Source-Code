public class FulfillmentOrderTaxMapClass {
    
    @InvocableMethod(label='Create FO & InventoryMaster LineItemIds Map')
    public static CreateMapOutputs[] createMap(CreateMapInputs[] input) {
        
        system.debug('Input: '+input);
        
        // Defining Variables
        FlowMapClass[] MapCollection = new List<FlowMapClass>();
        Map<String,String> MapProdAndInvMasterIds = new Map<String,String>();
        Id[] Product2Ids = new List<Id>();
        
        // Collect FulfillmentOrderLineItem Related Product2 Ids
        for(FulfillmentOrderLineItem FOlineItem :input[0].FOLineItems) {
            Product2Ids.add(FOlineItem.Product2Id);
        }
        
        // Map Product2 Ids & Inventory Master Ids
        if(Product2Ids.size() > 0) {
            for(Product2 prod :[SELECT Id, rstk__Product_icitem__c FROM Product2 WHERE Id=:Product2Ids]) {
               MapProdAndInvMasterIds.put(prod.Id,prod.rstk__Product_icitem__c); 
            }
        }
        
        for(FulfillmentOrderLineItem FOlineItem : input[0].FOLineItems) {
            FlowMapClass subMap = new FlowMapClass();
            
            // Assing Flow Map Variables
            subMap.FOLineItemId = FOlineItem.Id;
            subMap.InventoryMasterId = MapProdAndInvMasterIds.get(FOlineItem.Product2Id); // Key
            subMap.FOLineItem = 'FulfillmentOrderLineItem Exist';
            subMap.FOLineItemTax = FOlineItem.TotalTaxAmount;
            
            MapCollection.add(subMap);
            system.debug('MapCollection: '+ MapCollection);
        }
        
        // Create Map Output
        CreateMapOutputs[] result = new List<CreateMapOutputs>();
        
        CreateMapOutputs MapOutput = new CreateMapOutputs();
        MapOutput.flowMap = MapCollection;

        result.add(MapOutput);
        
        system.debug('Result: '+result);
        return result;
    }
    
    public class CreateMapInputs {
        @InvocableVariable(label='List of FOLineItems' required=true)
        public FulfillmentOrderLineItem[] FOLineItems;
    }
    
    public class CreateMapOutputs {
        @InvocableVariable(label='Map')
        public FlowMapClass[] flowMap;
    }

}