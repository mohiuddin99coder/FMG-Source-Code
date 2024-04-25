/**
 * Created by Adam-Hotmail on 6/7/2023.
 */

public interface FMGRSAPI_Inventory_ServiceInterface {
    List<Id> createInventoryMoves(List<Id> orderIds);
    List<Id> moveItems(List<FMGRSAPI_Inventory_Service.InventoryMoveRequest> moveEvents,Boolean isBackground);
}