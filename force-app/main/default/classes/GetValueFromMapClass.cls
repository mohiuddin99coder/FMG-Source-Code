public class GetValueFromMapClass {

    @InvocableMethod(label='Get Value from a Map key')
    public static GetValueOutputs[] getValue(GetValueInputs[] input) {
        system.debug(input);
        GetValueOutputs[] result = new GetValueOutputs[]{};
        for(FlowMapClass MapVar: input[0].flowMap) {
            if(MapVar.InventoryMasterId == input[0].key) {           // Comparing input Key & Map Key
                GetValueOutputs MapValue = new GetValueOutputs();
                MapValue.IsFOLineItemExist = MapVar.FOLineItem;
                MapValue.FOLineItemId = MapVar.FOLineItemId;
                MapValue.FOLineItemTax = MapVar.FOLineItemTax;
                result.add(MapValue);
            }
        }
        return result;
    }
    
    public class GetValueInputs {
        @InvocableVariable(label='Key' required=true)
        public string key;
        
        @InvocableVariable(label='Map' required=true)
        public FlowMapClass[] flowMap;
    }
    
    public class GetValueOutputs {
        @InvocableVariable(label='Value' required=true)
        public string IsFOLineItemExist;
        
        @InvocableVariable(label='Value' required=true)
        public string FOLineItemId;
        
        @InvocableVariable(label='Value' required=true)
        public Decimal FOLineItemTax;
    }
}