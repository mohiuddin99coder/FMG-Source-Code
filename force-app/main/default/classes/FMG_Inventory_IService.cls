/**
 * Created by inscorea on 8/22/2023.
 */

public interface FMG_Inventory_IService {
    List<rstk__sydatat__c> generateTransfers(List<FMG_Inventory_Classes.InventoryTransferInput> items);
    List<rstk__sydatat__c> generateTransfers(List<FMG_Inventory_Classes.InventoryTransferInput> items,List<String> locationNames);
    List<rstk__sydatat__c> generateTransfers(List<FMG_Inventory_Classes.InventoryTransferInput> items,List<String> locationNames, List<FMG_Inventory_Classes.InventoryTransferLocationInfo> locationData );
}