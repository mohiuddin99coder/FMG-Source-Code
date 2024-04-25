/**
 * Created by Adam-Hotmail on 10/12/2023.
 */

public interface FMG_Inventory_IServiceData {
    List<FMG_Configuration__c> getPickOrderLocationIdsData();
    List<rstk__icitem__c> getProductLocationsData(Set<Id> products, List<String> locationIds);
}