/**
 * Created by inscorea on 8/22/2023.
 */

public with sharing class FMG_Inventory_Classes {
    public class InventoryTransferInput{
        public Id Item;
        public Decimal Qty;
        public Id Div;
        public Id LocId;
        public String LocNo;
        public Id Project;
        public Id Site;
    }
    public class InventoryTransferLocationInfo{
        public Id IclocitemId { get; set; }
        public Decimal Qty { get; set; }

        public String LocationNumber { get; set; }
        public Id LocationId { get; set; }
        public String LocationName { get; set; }

        public String LocationFormulaName { get; set; }
        public Id DivisionId { get; set; }
        public Id SiteId { get; set; }
        public Id ProjectId { get; set; }

        public Id ItemId { get; set; }
        public String Item { get; set; }

        public Decimal SupplyMultiplier { get; set; }
        public Decimal DesiredInventoryOnHand { get; set; }
    }
}