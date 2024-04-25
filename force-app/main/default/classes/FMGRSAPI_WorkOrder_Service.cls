public with sharing class FMGRSAPI_WorkOrder_Service implements FMGRSAPI_WorkOrder_ServiceInterface,FMGRSAPI_WorkOrder_Service_DataInterface{



    @TestVisible
    private FMGRSAPI_IncrementingNumbersWIthLock batchId = new FMGRSAPI_IncrementingNumbersWIthLock('WorkOrderProcessingBatch');


    public class WorkOrderBatch{
        public Integer BatchId { get; set; }
        public List<WorkOrder> WorkOrders{get;set;}
    }

    public class WorkOrder{
        public List<WorkOrderComponent> WorkOrderComponent{get;set;}
        public String WorkOrderNumber{get;set;}
        public Id WorkOrderId{get;set;}
    }

    public class WorkOrderComponent{
        public List<Location> Locations { get; set; }
        public String ProductSku { get; set; }
        public String ProductDescription { get; set; }
        public Decimal Quantity { get; set; }
        public Id WorkOrderComponentId { get; set; }
        public String ProductId { get; set; }
        public List<WorkOrderStatus> Status{get;set;}
        public Decimal BatchId{get;set;}
    }

    public class WorkOrderStatus{
        public Id SyData{get;set;}
        public String IssueStatus{get;set;}
        public String IssueStatusMessage{get;set;}
        public String TransactionType{get;set;}
    }

    /**
     * @AUTHOR Adam Inscore
     * @DESCRIPTION Custom object for the given class as parameters
     **/
    public class Location{
        public Location(Id locationSFID,String locationId, String locationNumber,Decimal qty){
            this.LocationNumber = locationNumber;
            this.LocationId = locationId;
            this.Quantity = qty;
            this.LocationSFID = locationSFID;
            this.SyData = SyData;
        }
        public Location(Id locationSFID,String locationId, String locationNumber,Decimal qty,Id workOrderComponentDetailId,Id syData){
            this.LocationNumber = locationNumber;
            this.LocationId = locationId;
            this.Quantity = qty;
            this.WorkOrderComponentDetailId = workOrderComponentDetailId;
            this.LocationSFID = locationSFID;
            this.SyData = syData;
        }
        public Id LocationSFID{get;set;}
        public String LocationId{get;set;}
        public String LocationNumber{get;set;}
        public Decimal Quantity { get; set; }
        public Id WorkOrderComponentDetailId{get;set;}
        public Id SyData{get;set;}
    }



    /**
     * @description This is Unit test data for the function getMissingWorkOrderComponentDetail
     **/
    @TestVisible
    private List<RawWorkOrderComponentDetail> UnitTestGetMissingWorkOrderComponentDetail{get;set;}

    /**
     * @description This is to allow pulling of all missing components and also allow unit test data to be injected
     * @param missingData Ids of all of the missing component information that was expected
     *
     * @return Collection of all of the missing components
     **/
    @TestVisible
    private List<RawWorkOrderComponentDetail> getMissingWorkOrderComponentDetail(List<Id> missingData){
        if(Test.isRunningTest() && UnitTestGetMissingWorkOrderComponentDetail != null){
            System.debug('Running  test collection');
            return UnitTestGetMissingWorkOrderComponentDetail;
        }
        List<RawWorkOrderComponentDetail> returnCollection = new List<FMGRSAPI_WorkOrder_Service.RawWorkOrderComponentDetail>();
        for(rstk__woorddmd__c woc :[SELECT Id,
        (
                SELECT Id, rstk__woorddmdcst_locnum__c, rstk__woorddmdcst_locid__r.Id,
                        rstk__woorddmdcst_locid__r.rstk__sylocid_locid__c, rstk__woorddmdcst_qtyiss__c
                FROM rstk__woorddmdcsts__r
        )
        FROM rstk__woorddmd__c
        WHERE Id = :missingData]) {
            for (rstk__woorddmdcst__c locInfo : woc.rstk__woorddmdcsts__r) {
                returnCollection.add(new RawWorkOrderComponentDetail(woc.Id,locInfo));
            }
        }


        System.debug('Called getMissingWorkOrderComponentDetail:');
        System.debug('Input:');
        System.debug('missingData: ' );
        System.debug(JSON.serialize(missingData));
        System.debug('Output:');
        System.debug(JSON.serialize(returnCollection));

        System.debug('Called getMissingWorkOrderComponentDetail with the following return:');
        System.debug(JSON.serialize(returnCollection));
        return returnCollection;
    }

    /**
     * @description This is a formatted version fo the Work Order Component Detail(rstk__woorddmdcst__c)
     **/
    @TestVisible
    private class RawWorkOrderComponentDetail{
        public RawWorkOrderComponentDetail(){}
        public RawWorkOrderComponentDetail(Id componentId,rstk__woorddmdcst__c componentDetail){
            this.WorkOrderComponentId = componentId;
            this.WorkOrderComponentDetailId = componentDetail.Id;
            this.LocationNumber = componentDetail.rstk__woorddmdcst_locnum__c;
            this.LocationId = componentDetail.rstk__woorddmdcst_locid__r.Id;
            this.LocationIdString = componentDetail.rstk__woorddmdcst_locid__r.rstk__sylocid_locid__c;
            this.QtyIssued = componentDetail.rstk__woorddmdcst_qtyiss__c;
            this.RawData = componentDetail;
        }
        public Id WorkOrderComponentId{get;set;}
        public Id WorkOrderComponentDetailId{get;set;}
        public String LocationNumber{get;set;}
        public Id LocationId{get;set;}
        public String LocationIdString{get;set;}
        public Decimal QtyIssued{get;set;}
        public rstk__woorddmdcst__c RawData{get;set;}
    }





    /**
     * @description This is an override for unit test to take control of the getWorkOrderComponents
     **/
    @TestVisible
    private List<RawWorkOrderComponent> UnitTestGetWorkOrderComponents{get;set;}

    public List<AggregateResult> getWorkOrderComponents_workOrderIdsData(Integer batchSize){

        List<AggregateResult> records = [
                SELECT rstk__woorddmd_ordno__r.Id
                FROM rstk__woorddmd__c
                WHERE Id NOT IN (
                        SELECT fmgwoorddmdcst_woorddmd__c
                        FROM fmgwoorddmdcst__c
                )
                AND rstk__woorddmd_ordno__r.rstk__wocst_ordsts__c = '5'
                AND rstk__woorddmd_backflushpol_pl__c = 'No Backflushing'
                GROUP BY rstk__woorddmd_ordno__r.Id
                ORDER BY MIN(CreatedDate)
                LIMIT :batchSize
        ];
        if(MockData != null && test.isRunningTest()){
            records = MockData.getWorkOrderComponents_workOrderIdsData(batchSize);
        }
        return records;
    }
    public List<rstk__woorddmd__c> getWorkOrderComponents_workOrdersItemsData(Set<Id> workOrderIds){
        List<rstk__woorddmd__c> records = [
                SELECT Id, rstk__woorddmd_qtyoutstdg__c, rstk__woorddmd_desc__c,
                        rstk__woorddmd_compitem__r.rstk__icitem_item__r.rstk__peitem_item__c,
                        rstk__woorddmd_compitem__r.Id,
                        rstk__woorddmd_ordno__r.Id,
                        rstk__woorddmd_ordno__r.Name,
                        rstk__woorddmd_ordno__r.rstk__wocst_ordsts__c,
                        rstk__woorddmd_ordno__r.rstk__wocst_ordno__c,
                        rstk__woorddmd_qtyreq__c
                FROM rstk__woorddmd__c
                WHERE rstk__woorddmd_ordno__r.Id = :workOrderIds
                AND rstk__woorddmd_backflushpol_pl__c = 'No Backflushing'
                ORDER BY CreatedDate DESC
        ];
        if(MockData != null && test.isRunningTest()){
            records = MockData.getWorkOrderComponents_workOrdersItemsData(workOrderIds);
        }
        return records;
    }

    /**
     * @param batchSize the number of work orders to be pulled
     *
     * @return collection of work order components that need to be processed
     **/
    @TestVisible
    private List<RawWorkOrderComponent> getWorkOrderComponents(Integer batchSize){

        if(Test.isRunningTest() && UnitTestGetWorkOrderComponents != null){
            return UnitTestGetWorkOrderComponents;
        }

        Set<Id> workOrderIds = new Set<Id>();
        List<AggregateResult> ordersToPull =  getWorkOrderComponents_workOrderIdsData(batchSize) ;

        for(AggregateResult wo: ordersToPull) {
            workOrderIds.add(wo.Id);
        }

        List<RawWorkOrderComponent> workOrdersComponents = new List<RawWorkOrderComponent>();
        List<rstk__woorddmd__c> workOrdersItemsRecords = getWorkOrderComponents_workOrdersItemsData(workOrderIds);
        for (rstk__woorddmd__c workOrdersItems : workOrdersItemsRecords) {
            RawWorkOrderComponent workOrderComponent = new RawWorkOrderComponent(workOrdersItems);
            workOrdersComponents.add(workOrderComponent);
        }

        System.debug('Called getWorkOrderComponents:');
        System.debug('Input:');
        System.debug('batchSize: ' + batchSize );
        System.debug('Output:');
        System.debug(JSON.serialize(workOrdersComponents));

        return workOrdersComponents;
    }

    /**
     * @description A simplified version the the Work order component with the extra information
     **/
    @TestVisible
    private class RawWorkOrderComponent {
        public RawWorkOrderComponent(){}
        public RawWorkOrderComponent(rstk__woorddmd__c woorddmd) {
            ComponentId = woorddmd.Id;
            Qty = woorddmd.rstk__woorddmd_qtyoutstdg__c;
            ItemDescription = woorddmd.rstk__woorddmd_desc__c;
            InventoryItem = woorddmd.rstk__woorddmd_compitem__r.Id;
            Item = woorddmd.rstk__woorddmd_compitem__r.rstk__icitem_item__r.rstk__peitem_item__c;
            WorkOrderId = woorddmd.rstk__woorddmd_ordno__r.Id;
            WorkOrder = woorddmd.rstk__woorddmd_ordno__r.rstk__wocst_ordno__c;
            QtyRequested = woorddmd.rstk__woorddmd_qtyreq__c;
            Found = false;
            Generated = false;
        }

        public Id ComponentId { get; set; }
        public Decimal Qty { get; set; }
        public Decimal QtyRequested { get; set; }
        public String ItemDescription { get; set; }
        public Id InventoryItem { get; set; }
        public String Item { get; set; }
        public Id WorkOrderId { get; set; }
        public String WorkOrder { get; set; }
        public Boolean Found {get;set;}
        public Boolean Generated{get;set;}
    }



    @TestVisible
    private FMGRSAPI_WorkOrder_Service_DataInterface MockData{get;set;}

    /**
    * @description This is an override for unit test to take control of the WorkOrderComponentBatchData
    **/
    @TestVisible
    private List<RawFmgWorkOrderComponentDetail> UnitTestGetFMGWorkOrderComponentBatch;

    public List<fmgwoorddmdcst__c> getFMGWorkOrderComponentBatchData(Integer batchId){
        List<fmgwoorddmdcst__c> records = [
                SELECT Id, batchId__c,
                        fmgwoorddmdcst_woorddmd__r.Id,
                        fmgwoorddmdcst_woorddmd__r.rstk__woorddmd_ordno__r.Id,
                        fmgwoorddmdcst_woorddmd__r.rstk__woorddmd_ordno__r.rstk__wocst_ordno__c,
                        fmgwoorddmdcst_woorddmd__r.rstk__woorddmd_desc__c,
                        fmgwoorddmdcst_woorddmd__r.rstk__woorddmd_qtyreq__c,
                        fmgwoorddmdcst_woorddmd__r.rstk__woorddmd_compitem__r.rstk__icitem_item__r.rstk__peitem_item__c,
                        fmgwoorddmdcst_woorddmd__r.rstk__woorddmd_compitem__r.Id,
                        fmgwoorddmdcst_woorddmdcst__c,
                        fmgwoorddmdcst_woorddmdcst__r.rstk__woorddmdcst_locnum__c,
                        fmgwoorddmdcst_woorddmdcst__r.rstk__woorddmdcst_locid__r.Id,
                        fmgwoorddmdcst_woorddmdcst__r.rstk__woorddmdcst_locid__r.rstk__sylocid_locid__c,
                        fmgwoorddmdcst_woorddmdcst__r.rstk__woorddmdcst_qtyiss__c,
                        fmgwoorddmdcst_sydata__c,
                        fmgwoorddmdcst_sydata__r.rstk__sydata_message__c,
                        fmgwoorddmdcst_sydata__r.rstk__sydata_process__c,
                        fmgwoorddmdcst_sydata__r.rstk__sydata_txntype__c
                FROM fmgwoorddmdcst__c
                WHERE batchId__c = :batchId
        ];
        if(MockData != null && test.isRunningTest()){
            records = MockData.getFMGWorkOrderComponentBatchData(batchId);
        }

        return records;
    }
    /**
     * @description Used to pull re-pull information from a batch
     * @param batchId Batch Id that is used to pull the information from the FMG Work Order Component Detail
     *
     * @return collection of work order components
     **/
    @TestVisible
    private List<RawFmgWorkOrderComponentDetail> getFMGWorkOrderComponentBatch(Integer batchId){

/*
        if(Test.isRunningTest() && UnitTestGetFMGWorkOrderComponentBatch != null){
            return UnitTestGetFMGWorkOrderComponentBatch;
        }
*/

        List<RawFmgWorkOrderComponentDetail> rawFmgWorkOrderComponentDetails = new List<RawFmgWorkOrderComponentDetail>();
        List<fmgwoorddmdcst__c> records = getFMGWorkOrderComponentBatchData(batchId);
        for(fmgwoorddmdcst__c data: records) {
            rawFmgWorkOrderComponentDetails.add(new RawFmgWorkOrderComponentDetail(data));
        }

        System.debug('Called getFMGWorkOrderComponentBatch:');
        System.debug('Input:');
        System.debug('batchId: ' + batchId );
        System.debug('Output:');
        System.debug(JSON.serialize(rawFmgWorkOrderComponentDetails));
        return rawFmgWorkOrderComponentDetails;
    }

    public List<rstk__wocst__c> getFMGWorkOrderComponent_WorkOrdersData(List<Id> Ids){

        List<rstk__wocst__c> records = [
                SELECT Id,rstk__wocst_ordno__c,
                (
                        SELECT Id,
                                rstk__woorddmd_desc__c,
                                rstk__woorddmd_qtyreq__c,
                                rstk__woorddmd_compitem__r.rstk__icitem_item__r.rstk__peitem_item__c,
                                rstk__woorddmd_compitem__r.Id,
                                rstk__woorddmd_ordno__c
                        FROM rstk__WOORDDMDs__r
                        WHERE rstk__woorddmd_backflushpol_pl__c = 'No Backflushing'
                ),
                (
                        SELECT Id,
                                rstk__woorddmdcst_locnum__c,
                                rstk__woorddmdcst_locid__r.Id,
                                rstk__woorddmdcst_locid__r.rstk__sylocid_locid__c,
                                rstk__woorddmdcst_qtyiss__c,
                                rstk__woorddmdcst_woorddmd__c
                        FROM rstk__woorddmdcsts__r
                ),
                (
                        SELECT Id, batchId__c,fmgwoorddmdcst_sydata__c,
                                fmgwoorddmdcst_sydata__r.rstk__sydata_message__c, fmgwoorddmdcst_sydata__r.rstk__sydata_process__c,
                                fmgwoorddmdcst_sydata__r.rstk__sydata_txntype__c, fmgwoorddmdcst_woorddmd__c, fmgwoorddmdcst_woorddmdcst__c,fmgwoorddmdcst_wocst__c
                        FROM fmgwoorddmdcst_wocst__r
                )
                FROM rstk__wocst__c
                WHERE Id = :Ids
        ];
        if(MockData != null && test.isRunningTest()){
            records = MockData.getFMGWorkOrderComponent_WorkOrdersData(Ids);
        }
        return records;
    }

    /**
     * @description Pulls all work orders specified by there id's and returns any information. There can be more then 1 record for each work order
     * @param Ids The list of work order Ids to be pulled
     *
     * @return Collection of all work orders and details pulled
     **/
    @TestVisible
    private List<WorkOrder> getFMGWorkOrderComponent(List<Id> Ids){


        List<FMGRSAPI_WorkOrder_Service.RawFmgWorkOrderComponentDetail> rawFmgWorkOrderComponentDetails = new List<FMGRSAPI_WorkOrder_Service.RawFmgWorkOrderComponentDetail>();
        List<rstk__wocst__c> WorkOrdersData = getFMGWorkOrderComponent_WorkOrdersData(Ids);
        for(rstk__wocst__c data: WorkOrdersData) {
            System.debug(LoggingLevel.FINE,'*********************** Work Order ********************************');
            System.debug(LoggingLevel.FINE,JSON.serializePretty(data));


            Set<Id> processedWorkOrders = new Set<Id>();
            Set<Id> processedWorkOrdersComponent = new Set<Id>();
            Set<Id> processedWorkOrdersComponentDetail = new Set<Id>();

            Map<Id,rstk__woorddmd__c> workOrderComponents = new Map<Id, rstk__woorddmd__c>();
            Map<Id,rstk__woorddmdcst__c> workOrderComponentDetails = new Map<Id, rstk__woorddmdcst__c>();

            for(rstk__woorddmd__c workOrderComponent: data.rstk__WOORDDMDs__r){
                workOrderComponents.put(workOrderComponent.Id,workOrderComponent);
            }
            System.debug(LoggingLevel.FINE,'*********************** workOrderComponents ********************************');
            System.debug(LoggingLevel.FINE,JSON.serializePretty(workOrderComponents));


            for(rstk__woorddmdcst__c workOrderComponentDetail: data.rstk__woorddmdcsts__r){
                workOrderComponentDetails.put(workOrderComponentDetail.Id,workOrderComponentDetail);

            }


            // Generate for all that have had a batch process done
            for(fmgwoorddmdcst__c fmgComponent: data.fmgwoorddmdcst_wocst__r) {



                System.debug(LoggingLevel.FINE,'*********************** fmgComponent ********************************');
                System.debug(LoggingLevel.FINE,JSON.serializePretty(fmgComponent));

                FMGRSAPI_WorkOrder_Service.RawFmgWorkOrderComponentDetail rawData = new FMGRSAPI_WorkOrder_Service.RawFmgWorkOrderComponentDetail();
                rawData.SalesforceId = fmgComponent.Id;
                rawData.BatchId = fmgComponent.batchId__c;

                rstk__woorddmd__c component = workOrderComponents.get(fmgComponent.fmgwoorddmdcst_woorddmd__c);
                rawData.WorkOrderComponentId=component.Id;
                rawData.WorkOrderNumberId=data.Id;
                rawData.OrderNumber=data.rstk__wocst_ordno__c;
                rawData.ItemDescription=component.rstk__woorddmd_desc__c;
                if(component.rstk__woorddmd_qtyreq__c!= null) {
                    rawData.QtyRequested = component.rstk__woorddmd_qtyreq__c.round(System.RoundingMode.UP);
                }
                rawData.ItemNumber=component.rstk__woorddmd_compitem__r.rstk__icitem_item__r.rstk__peitem_item__c;
                rawData.ComponentItemId=component.rstk__woorddmd_compitem__r.Id;


                if(workOrderComponentDetails.containsKey(fmgComponent.fmgwoorddmdcst_woorddmdcst__c)){
                    rstk__woorddmdcst__c workOrderComponentDetail = workOrderComponentDetails.get(fmgComponent.fmgwoorddmdcst_woorddmdcst__c);
                    rawData.WorkOrderComponentDetailId=workOrderComponentDetail.Id;
                    rawData.FromLocation=workOrderComponentDetail.rstk__woorddmdcst_locnum__c;
                    rawData.FromLocationIdId=workOrderComponentDetail.rstk__woorddmdcst_locid__r.Id;
                    rawData.FromLocationId=workOrderComponentDetail.rstk__woorddmdcst_locid__r.rstk__sylocid_locid__c;
                    if(workOrderComponentDetail.rstk__woorddmdcst_qtyiss__c!= null) {
                        rawData.QtyIssued = workOrderComponentDetail.rstk__woorddmdcst_qtyiss__c.round(System.RoundingMode.UP);
                    }
                }



                rawData.SyDataId=fmgComponent.fmgwoorddmdcst_sydata__c;
                rawData.ErrorMessage=fmgComponent.fmgwoorddmdcst_sydata__r.rstk__sydata_message__c;
                rawData.ProcessingIndicator=fmgComponent.fmgwoorddmdcst_sydata__r.rstk__sydata_process__c;
                rawData.TransactionType=fmgComponent.fmgwoorddmdcst_sydata__r.rstk__sydata_txntype__c;

                rawFmgWorkOrderComponentDetails.add(rawData);
                processedWorkOrders.add(fmgComponent.fmgwoorddmdcst_wocst__c);
                processedWorkOrdersComponent.add(fmgComponent.fmgwoorddmdcst_woorddmd__c);
                processedWorkOrdersComponentDetail.add(fmgComponent.fmgwoorddmdcst_woorddmdcst__c);
            }

            // Process all Work Order Component Detail that do not exists in the FMG Table

            for(rstk__woorddmdcst__c woorddmdcst:data.rstk__woorddmdcsts__r){
                if(processedWorkOrdersComponentDetail.contains(woorddmdcst.Id)){
                    continue;
                }

                FMGRSAPI_WorkOrder_Service.RawFmgWorkOrderComponentDetail rawData = new FMGRSAPI_WorkOrder_Service.RawFmgWorkOrderComponentDetail();
                rawData.BatchId = -1;

                rstk__woorddmd__c component = workOrderComponents.get(woorddmdcst.rstk__woorddmdcst_woorddmd__c);
                rawData.WorkOrderComponentId=component.Id;
                rawData.WorkOrderNumberId=data.Id;
                rawData.OrderNumber=data.rstk__wocst_ordno__c;
                rawData.ItemDescription=component.rstk__woorddmd_desc__c;

                if(component.rstk__woorddmd_qtyreq__c != null) {
                    rawData.QtyRequested = component.rstk__woorddmd_qtyreq__c.round(System.RoundingMode.UP);
                }
                rawData.ItemNumber=component.rstk__woorddmd_compitem__r.rstk__icitem_item__r.rstk__peitem_item__c;
                rawData.ComponentItemId=component.rstk__woorddmd_compitem__r.Id;


                rawData.WorkOrderComponentDetailId=woorddmdcst.Id;
                rawData.FromLocation=woorddmdcst.rstk__woorddmdcst_locnum__c;
                rawData.FromLocationIdId=woorddmdcst.rstk__woorddmdcst_locid__r.Id;
                rawData.FromLocationId=woorddmdcst.rstk__woorddmdcst_locid__r.rstk__sylocid_locid__c;
                if(woorddmdcst.rstk__woorddmdcst_qtyiss__c != null) {
                    rawData.QtyIssued = woorddmdcst.rstk__woorddmdcst_qtyiss__c.round(System.RoundingMode.UP);
                }


                rawFmgWorkOrderComponentDetails.add(rawData);
                processedWorkOrders.add(component.rstk__woorddmd_ordno__c);
                processedWorkOrdersComponent.add(woorddmdcst.rstk__woorddmdcst_woorddmd__c);
            }

            // Process all Work Order Component that do not have Detail and exists in the FMG Table
            for(rstk__woorddmd__c woorddmd:data.rstk__WOORDDMDs__r){
                if(processedWorkOrdersComponent.contains(woorddmd.Id)){
                    continue;
                }

                FMGRSAPI_WorkOrder_Service.RawFmgWorkOrderComponentDetail rawData = new FMGRSAPI_WorkOrder_Service.RawFmgWorkOrderComponentDetail();
                rawData.BatchId = -1;


                rawData.WorkOrderComponentId=woorddmd.Id;
                rawData.WorkOrderNumberId=data.Id;
                rawData.OrderNumber=data.rstk__wocst_ordno__c;
                rawData.ItemDescription=woorddmd.rstk__woorddmd_desc__c;
                if(woorddmd.rstk__woorddmd_qtyreq__c!= null) {
                    rawData.QtyRequested = woorddmd.rstk__woorddmd_qtyreq__c.round(System.RoundingMode.UP);
                }
                rawData.ItemNumber=woorddmd.rstk__woorddmd_compitem__r.rstk__icitem_item__r.rstk__peitem_item__c;
                rawData.ComponentItemId=woorddmd.rstk__woorddmd_compitem__r.Id;

                rawFmgWorkOrderComponentDetails.add(rawData);
                processedWorkOrders.add(woorddmd.rstk__woorddmd_ordno__c);

            }
            // Add Remaining work orders
            if(!processedWorkOrders.contains(data.Id)){
                FMGRSAPI_WorkOrder_Service.RawFmgWorkOrderComponentDetail rawData = new FMGRSAPI_WorkOrder_Service.RawFmgWorkOrderComponentDetail();
                rawData.BatchId = -1;

                rawData.WorkOrderNumberId=data.Id;
                rawData.OrderNumber=data.rstk__wocst_ordno__c;

                rawFmgWorkOrderComponentDetails.add(rawData);
            }

        }
        System.debug(LoggingLevel.FINE,'***************** rawFmgWorkOrderComponentDetails *****************************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(rawFmgWorkOrderComponentDetails));

        // This is called for information on the fmg work order object and store the value for outputting the info
        List<FMGRSAPI_WorkOrder_Service.WorkOrder> workOrders = getWorkOrderData(rawFmgWorkOrderComponentDetails);

        System.debug(LoggingLevel.FINE,'***************** workOrders *****************************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(workOrders));

        return workOrders;
    }

    /**
     * @description A simplified version of the FMG Work Order Component Detail (fmgwoorddmdcst__c)
     **/
    @TestVisible
    private class RawFmgWorkOrderComponentDetail {
        public RawFmgWorkOrderComponentDetail(){}
        public RawFmgWorkOrderComponentDetail(fmgwoorddmdcst__c data){
            SalesforceId = data.Id;
            BatchId = data.batchId__c;
            WorkOrderComponentId = data.fmgwoorddmdcst_woorddmd__r.Id;
            WorkOrderNumberId = data.fmgwoorddmdcst_woorddmd__r.rstk__woorddmd_ordno__r.Id;
            OrderNumber = data.fmgwoorddmdcst_woorddmd__r.rstk__woorddmd_ordno__r.rstk__wocst_ordno__c;
            ItemDescription = data.fmgwoorddmdcst_woorddmd__r.rstk__woorddmd_desc__c;
            if(data.fmgwoorddmdcst_woorddmd__r.rstk__woorddmd_qtyreq__c != null) {
                QtyRequested = data.fmgwoorddmdcst_woorddmd__r.rstk__woorddmd_qtyreq__c.round(System.RoundingMode.UP);
            }
            ItemNumber = data.fmgwoorddmdcst_woorddmd__r.rstk__woorddmd_compitem__r.rstk__icitem_item__r.rstk__peitem_item__c;
            ComponentItemId = data.fmgwoorddmdcst_woorddmd__r.rstk__woorddmd_compitem__r.Id;
            WorkOrderComponentDetailId = data.fmgwoorddmdcst_woorddmdcst__c;
            FromLocation = data.fmgwoorddmdcst_woorddmdcst__r.rstk__woorddmdcst_locnum__c;
            FromLocationIdId = data.fmgwoorddmdcst_woorddmdcst__r.rstk__woorddmdcst_locid__r.Id;
            FromLocationId = data.fmgwoorddmdcst_woorddmdcst__r.rstk__woorddmdcst_locid__r.rstk__sylocid_locid__c;
            if(data.fmgwoorddmdcst_woorddmdcst__r.rstk__woorddmdcst_qtyiss__c != null){
                QtyIssued = data.fmgwoorddmdcst_woorddmdcst__r.rstk__woorddmdcst_qtyiss__c.round(System.RoundingMode.UP);
            }
            SyDataId = data.fmgwoorddmdcst_sydata__c;
            ErrorMessage = data.fmgwoorddmdcst_sydata__r.rstk__sydata_message__c;
            ProcessingIndicator = data.fmgwoorddmdcst_sydata__r.rstk__sydata_process__c;
            TransactionType = data.fmgwoorddmdcst_sydata__r.rstk__sydata_txntype__c;
            rawObject = data;
        }

        public Id SalesforceId{get;set;}
        public Decimal BatchId{get;set;}
        public Id WorkOrderComponentId{get;set;}
        public Id WorkOrderNumberId{get;set;}
        public String OrderNumber{get;set;}
        public String ItemDescription{get;set;}
        //fmgwoorddmdcst_woorddmd__r.rstk__woorddmd_qtyreq__c
        public Decimal QtyRequested{get;set;}
        //fmgwoorddmdcst_woorddmd__r.rstk__woorddmd_compitem__r.Id
        public Id ComponentItemId{get;set;}
        //fmgwoorddmdcst_woorddmd__r.rstk__woorddmd_compitem__r.rstk__icitem_item__r.rstk__peitem_item__c
        public String ItemNumber{get;set;}
        //fmgwoorddmdcst_woorddmdcst__c
        public Id WorkOrderComponentDetailId{get;set;}
        //fmgwoorddmdcst_woorddmdcst__r.rstk__woorddmdcst_locnum__c
        public String FromLocation{get;set;}
        //fmgwoorddmdcst_woorddmdcst__r.rstk__woorddmdcst_locid__r.Id
        public Id FromLocationIdId{get;set;}
        //fmgwoorddmdcst_woorddmdcst__r.rstk__woorddmdcst_locid__r.rstk__sylocid_locid__c
        public String FromLocationId{get;set;}
        //fmgwoorddmdcst_woorddmdcst__r.rstk__woorddmdcst_qtyiss__c
        public Decimal QtyIssued{get;set;}
        //fmgwoorddmdcst_sydata__c
        public Id SyDataId{get;set;}
        //fmgwoorddmdcst_sydata__r.rstk__sydata_message__c
        public String ErrorMessage{get;set;}
        //fmgwoorddmdcst_sydata__r.rstk__sydata_process__c
        public String ProcessingIndicator{get;set;}
        //fmgwoorddmdcst_sydata__r.rstk__sydata_txntype__c
        public String TransactionType{get;set;}
        //fmgwoorddmdcst__c
        public fmgwoorddmdcst__c rawObject{get;set;}
    }



    /**
     * @param locations Collection of all location
     * @description Will sort all of the locations per item
     **/
    @TestVisible
    private void sortProductQty(Map<String, Map<String, Map<String, FMGRSAPI_Inventory_Service.LocationInfo>>> locations) {
        for (String locId : locations.keySet()) {
            for (String itemName : locations.get(locId).keySet()) {
                List<FMGRSAPI_Inventory_Service.LocationInfo> fixedOrder = locations.get(locId).get(itemName).values();
                locations.get(locId).get(itemName).clear();
                fixedOrder.sort();
                for (FMGRSAPI_Inventory_Service.LocationInfo locationInfo : fixedOrder) {
                    locations.get(locId).get(itemName).put(locationInfo.LocationNumber, locationInfo);
                }
            }
        }
    }

    /**
     * @param pickList Pick list of items that are going to be picked
     *
     * @return Collection of SYDATA objects to be Issued
     **/
    @TestVisible
    private  List<rstk__sydata__c> generateSyDataIssue(Map<Id,WorkOrderComponent> pickList){
        List<rstk__sydata__c> issueObjects = new List<rstk__sydata__c>();

        for(WorkOrderComponent component:pickList.values()){
            for(Location loc:component.Locations) {
                rstk__sydata__c issueObject = new rstk__sydata__c();
                issueObject.rstk__sydata_txntype__c = 'WO Issue';
                issueObject.rstk__sydata_txnqty__c = loc.Quantity;
                issueObject.rstk__sydata_backgroundprocessing__c=true;
                issueObject.rstk__sydata_woorddmd__c = component.WorkOrderComponentId;
                issueObject.rstk__sydata_sylocid__c = loc.LocationSFID;
                issueObject.rstk__sydata_locnum__c = loc.LocationNumber;
                issueObjects.add(issueObject);

            }
        }
        return issueObjects;
    }



    /**
     * @param workOrderComponent Component information that is going to be picked
     *
     * @return The Object that will be passed out that is going to be pulled
     **/
    @TestVisible
    private  WorkOrderComponent generatePickObject(RawWorkOrderComponent workOrderComponent){
        // Create work order pick
        WorkOrderComponent pickComponent = new WorkOrderComponent();
        pickComponent.Locations = new List<Location>();



        pickComponent.ProductSku = workOrderComponent.Item;
        pickComponent.ProductDescription = workOrderComponent.ItemDescription;
        pickComponent.WorkOrderComponentId = workOrderComponent.ComponentId;
        pickComponent.ProductId = workOrderComponent.InventoryItem;
        pickComponent.Quantity = workOrderComponent.QtyRequested;

        return pickComponent;
    }





    private List<String> pickOrderLocationIds = null;
    private List<String> getPickOrderLocationIds(){
        if(pickOrderLocationIds != null){
            return pickOrderLocationIds;
        }

        FMG_Configuration__c[] locationIds = [
        SELECT
                Id,
                Setting__c,
                Value__c,
                Application__c
        FROM FMG_Configuration__c
        WHERE Application__c = 'FMGRSAPI - Work Order Settings' AND
              Setting__c = 'Generate Pick Order Location Ids' LIMIT 1];
        if(locationIds.isEmpty()){
            pickOrderLocationIds = new List<String>{'26','25','P1'};
        } else {
            pickOrderLocationIds = locationIds[0].Value__c.split(',');
        }

        return pickOrderLocationIds;
    }




    private void setPick(RawWorkOrderComponent workOrderComponent,List<FMGRSAPI_Inventory_Service.PickLocation> foundPicks,Map<Id,WorkOrderComponent> pickList,Map<String,Map<String,Map<String,FMGRSAPI_Inventory_Service.LocationInfo>>> locations){
        WorkOrderComponent pickComponent;

        if(pickList.containsKey(workOrderComponent.ComponentId)){
            pickComponent = pickList.get(workOrderComponent.ComponentId);
        } else {
            pickComponent = new WorkOrderComponent();
            pickComponent.Locations = new List<FMGRSAPI_WorkOrder_Service.Location>();
            pickComponent.ProductSku = workOrderComponent.Item;
            pickComponent.ProductDescription = workOrderComponent.ItemDescription;
            pickComponent.WorkOrderComponentId = workOrderComponent.ComponentId;
            pickComponent.ProductId = workOrderComponent.InventoryItem;
            pickComponent.Quantity = workOrderComponent.QtyRequested;
            pickList.put(workOrderComponent.ComponentId,pickComponent);
        }


        // Adds in pick locations
        for(FMGRSAPI_Inventory_Service.PickLocation pick:foundPicks){
            pickComponent.Locations.add(new Location(pick.LocationId,pick.LocationName,pick.LocationNumber,pick.Qty));
            FMGRSAPI_Inventory_Service.LocationInfo rawInfo = locations.get(pick.LocationName).get(workOrderComponent.Item).get(pick.LocationNumber);
            rawInfo.Qty = rawInfo.Qty - pick.Qty;
        }
        workOrderComponent.Found = true;
        workOrderComponent.Generated=true;
        sortProductQty(locations);

    }

    @TestVisible
    private FMGRSAPI_Inventory_Service inventoryService = new FMGRSAPI_Inventory_Service();

    /**
     * @description Finds all work orders that are in a status of 5 and have not been loaded yet
     * @param batchSize Size of the batch that needs to be generated
     *
     * @return the Batch Id that was generated
     **/
    public Integer generateWorkOrderBatch(Integer batchSize){

        batchId.getNext();


        // Get all Work order Components
        Set<String> ItemList = new Set<String>();
        Map<Id,Id> workOrderComponentToWorkOrder = new Map<Id, Id>();

        List<RawWorkOrderComponent> workOrdersComponents = getWorkOrderComponents(batchSize);
        for(RawWorkOrderComponent workOrdersComponent:workOrdersComponents){
            ItemList.add(workOrdersComponent.Item);
            workOrderComponentToWorkOrder.put(workOrdersComponent.ComponentId,workOrdersComponent.WorkOrderId);
        }

        //Map<String, Map<String, Map<String, RawLocationInfo>>> locations = getProductLocations(ItemList);
        Map<Id,WorkOrderComponent> pickList = new Map<Id,WorkOrderComponent>();

        // No Split attempt


        List<String> pickLocationIdOrder = getPickOrderLocationIds();

        Map<String,Map<String,Map<String,FMGRSAPI_Inventory_Service.LocationInfo>>> locations = inventoryService.getProductLocations(ItemList,pickLocationIdOrder);

        List<FMGRSAPI_Inventory_Service.PickLocation> foundPicks;

        for(RawWorkOrderComponent workOrderComponent:workOrdersComponents){

            foundPicks = inventoryService.getPickLocations(workOrderComponent.Item,workOrderComponent.Qty,locations,pickLocationIdOrder,false,false,false);
            if(foundPicks.isEmpty()){
                foundPicks = inventoryService.getPickLocations(workOrderComponent.Item,workOrderComponent.Qty,locations,pickLocationIdOrder,true,false,false);
                if(foundPicks.isEmpty()){
                    foundPicks = inventoryService.getPickLocations(workOrderComponent.Item,workOrderComponent.Qty,locations,pickLocationIdOrder,true,true,false);
                }
            }

            if(!foundPicks.isEmpty()){
                setPick(workOrderComponent,foundPicks,pickList,locations);
            }
        }

        // Add picks that have no product location found
        for(RawWorkOrderComponent workOrderComponent: workOrdersComponents) {
            if(!workOrderComponent.Generated){
                // Create work order pick
                WorkOrderComponent pickComponent = generatePickObject(workOrderComponent);
                pickList.put(workOrderComponent.ComponentId,pickComponent);

                // To Indicate that the work order had it's pick list generated
                workOrderComponent.Generated = true;
            }
        }

        System.debug(LoggingLevel.FINE,'******************** Pick Information  ***********************');
        System.debug(LoggingLevel.FINE, pickList);



        System.debug('Issues to Generate(' +pickList.size() + '): ' );
        System.debug(pickList );
        List<rstk__sydata__c> issues = generateSyDataIssue(pickList);
        System.debug('Issues Created:' );
        System.debug(issues );
        //If there is no records there is nothing to do and should exit without updating the batch Id Incrementer
        if(pickList.isEmpty()){
            return null;
        }
        if(!issues.isEmpty() && !Test.isRunningTest()){
            insert issues;
        }

        Integer newBatchId = batchId.value;
        List<fmgwoorddmdcst__c> customlookupInfo = new List<fmgwoorddmdcst__c>();
        for(rstk__sydata__c sydata: issues){
            fmgwoorddmdcst__c workingObject = new fmgwoorddmdcst__c();
            workingObject.fmgwoorddmdcst_woorddmd__c = sydata.rstk__sydata_woorddmd__c;
            if(workOrderComponentToWorkOrder.containsKey(workingObject.fmgwoorddmdcst_woorddmd__c)){
                workingObject.fmgwoorddmdcst_wocst__c = workOrderComponentToWorkOrder.get(workingObject.fmgwoorddmdcst_woorddmd__c);
            }
            workingObject.fmgwoorddmdcst_sydata__c = sydata.Id;
            workingObject.batchId__c = newBatchId;
            customlookupInfo.add(workingObject);
        }

        for(WorkOrderComponent component: pickList.values()){
            if(component.Locations == null || component.Locations.size() == 0){
                fmgwoorddmdcst__c workingObject = new fmgwoorddmdcst__c();
                workingObject.fmgwoorddmdcst_woorddmd__c = component.WorkOrderComponentId;
                if(workOrderComponentToWorkOrder.containsKey(workingObject.fmgwoorddmdcst_woorddmd__c)){
                    workingObject.fmgwoorddmdcst_wocst__c = workOrderComponentToWorkOrder.get(workingObject.fmgwoorddmdcst_woorddmd__c);
                }
                workingObject.batchId__c = newBatchId;
                customlookupInfo.add(workingObject);
            }
        }



        System.debug('*********************Picks********************************');
        System.debug(pickList);
        System.debug('*********************SyData********************************');
        System.debug(customlookupInfo);
        System.debug('*********************Custome Extended********************************');
        System.debug(issues);



        if(!customlookupInfo.isEmpty()) {
            if(Test.isRunningTest()){
                UnitTestPickList = pickList;
                UnitTestCustomLookupInfo= customlookupInfo;
                UnitTestIssued = issues;
            } else {
                insert customlookupInfo;
            }

            return newBatchId;
        }

        return null;
    }

    @TestVisible
    private Map<Id,WorkOrderComponent> UnitTestPickList{get;set;}

    @TestVisible
    private List<fmgwoorddmdcst__c> UnitTestCustomLookupInfo{get;set;}

    @TestVisible
    private List<rstk__sydata__c> UnitTestIssued{get;set;}



    /**
     * @param batchId The batch id to pull
     *
     * @return collection of all picks from the batch and any statuses available for the batch
     **/
    public WorkOrderBatch getBatchData(Integer batchId){


        List<RawFmgWorkOrderComponentDetail> rawFmgWorkOrderComponentDetails = getFMGWorkOrderComponentBatch(batchId);

        WorkOrderBatch returnBatch = new WorkOrderBatch();
        returnBatch.BatchId = batchId;
        returnBatch.WorkOrders = getWorkOrderData(rawFmgWorkOrderComponentDetails);

        return returnBatch;

    }

    /**
     * @description Pulls a collection of work orders by there Ids
     * @param workOrderIds List of work order Ids to be pulled
     *
     * @return Collection of all work orders/conponenets
     **/
    public List<WorkOrder> getWorkOrders(List<Id> workOrderIds){

        // Pulls all of the work order details / picks for the requested batch Id
        List<WorkOrder> workOrders = getFMGWorkOrderComponent(workOrderIds);

        return workOrders;
    }


    /**
     * @description collection of all components that need to be converted into WorkOrder Objects and updates information in the custom sObject
     *
     * @param rawFmgWorkOrderComponentDetails The collection of raw data to be processed
     *
     * @return returns the formatted data
     **/
    public List<WorkOrder> getWorkOrderData(List<RawFmgWorkOrderComponentDetail> rawFmgWorkOrderComponentDetails){

        Map<Id,WorkOrder> workOrderMap = new Map<Id, WorkOrder>();
        Map<Id,WorkOrderComponent> workOrderComponentMap = new Map<Id, WorkOrderComponent>();
        Map<Id,RawFmgWorkOrderComponentDetail> batchData = new Map<Id, RawFmgWorkOrderComponentDetail>();
        List<Id> locationsUsed = new List<Id>();
        List<Id> missingData = new List<Id>();
        Map<Id,List<RawWorkOrderComponentDetail>> updateRecords = new Map<Id, List<RawWorkOrderComponentDetail>>();


        // Loops thru all raw work order information to generate formatted data
        for(RawFmgWorkOrderComponentDetail data: rawFmgWorkOrderComponentDetails){
            batchData.put(data.SalesforceId,data);

            // Checks to see if the was created and if it was not create a new one and add it into the collection
            if(!workOrderMap.containsKey(data.WorkOrderNumberId)){
                WorkOrder newObject = new WorkOrder();
                newObject.WorkOrderId = data.WorkOrderNumberId;
                newObject.WorkOrderNumber = data.OrderNumber;
                newObject.WorkOrderComponent = new List<WorkOrderComponent>();
                workOrderMap.put(data.WorkOrderNumberId,newObject);
            }

            // Checks to see if there was a work order component created if it was not then it will create a new one
            if(!workOrderComponentMap.containsKey(data.WorkOrderComponentId)){
                WorkOrderComponent newObject = new WorkOrderComponent();
                newObject.BatchId = data.BatchId;
                newObject.WorkOrderComponentId = data.WorkOrderComponentId;
                newObject.ProductDescription = data.ItemDescription;
                newObject.Status = new List<WorkOrderStatus>(); // = data.Processing_Indicator__c;
                newObject.ProductSku = data.ItemNumber;
                newObject.ProductId = data.ComponentItemId;
                newObject.Quantity = data.QtyRequested;
                newObject.Locations = new List<Location>();

                workOrderMap.get(data.WorkOrderNumberId).WorkOrderComponent.add(newObject);
                workOrderComponentMap.put(newObject.WorkOrderComponentId,newObject);
            }

            // Checks to see if there is any syData that needs to be set else there is no information to use
            if(data.SyDataId != null){

                WorkOrderStatus status = new WorkOrderStatus();
                status.IssueStatus = data.ProcessingIndicator;
                status.IssueStatusMessage = data.ErrorMessage;
                status.SyData = data.SyDataId;
                status.TransactionType = data.TransactionType;

                workOrderComponentMap.get(data.WorkOrderComponentId).Status.add(status);
            }

            // Adds to a collection for finding the missing component details or adds a new location to the workOrder Componenet
            if(data.WorkOrderComponentDetailId == null){
                missingData.add(data.WorkOrderComponentId);
            } else {
                Location newloc = new Location(
                        data.FromLocationIdId,
                        data.FromLocationId,
                        data.FromLocation,
                        data.QtyIssued,
                        data.WorkOrderComponentDetailId,
                        data.SyDataId
                );
                workOrderComponentMap.get(data.WorkOrderComponentId).Locations.add(newloc);
                locationsUsed.add(data.WorkOrderComponentDetailId);
            }

        }

        // Finds the missing data
        List<RawWorkOrderComponentDetail> missingWorkOrderComponentDetail = getMissingWorkOrderComponentDetail(missingData);


        // Loops thru the missing data and adds it into the work orders that where missing it
        for (RawWorkOrderComponentDetail wocd : missingWorkOrderComponentDetail) {

            if (!locationsUsed.contains(wocd.WorkOrderComponentDetailId)) {
                Location newloc = new Location(
                        wocd.LocationId,
                        wocd.LocationIdString,
                        wocd.LocationNumber,
                        wocd.QtyIssued,
                        wocd.WorkOrderComponentDetailId,
                        null);

                workOrderComponentMap.get(wocd.WorkOrderComponentId).Locations.add(newloc);
                locationsUsed.add(wocd.WorkOrderComponentDetailId);


                if (!updateRecords.containsKey(wocd.WorkOrderComponentId)) {
                    updateRecords.put(wocd.WorkOrderComponentId, new List<RawWorkOrderComponentDetail>());
                }
                updateRecords.get(wocd.WorkOrderComponentId).add(wocd);
            }
        }


        List<fmgwoorddmdcst__c> updates = new List<fmgwoorddmdcst__c>();

        // Loops thru the FMG Work Order Component Details and assigns any missing record information
        for(RawFmgWorkOrderComponentDetail toUpdate:batchData.values()){

            // If this is a Unit test the data is not populated for an update
            if(!Test.isRunningTest()) {
                if (toUpdate.rawObject.fmgwoorddmdcst_woorddmdcst__c == null) {
                    if (updateRecords.containsKey(toUpdate.rawObject.fmgwoorddmdcst_woorddmd__c)) {
                        RawWorkOrderComponentDetail info = updateRecords.get(toUpdate.rawObject.fmgwoorddmdcst_woorddmd__c)[0];
                        toUpdate.rawObject.fmgwoorddmdcst_woorddmdcst__c = info.WorkOrderComponentDetailId;
                        updates.add(toUpdate.rawObject);
                        updateRecords.get(toUpdate.rawObject.fmgwoorddmdcst_woorddmd__c).remove(0);
                    }
                }
            }

        }


        // Checks to see if there where any updates that needed to be executed
        if(!updates.isEmpty()){
            System.debug('Updated: ' +updates.size());
            update updates;
        }

        return workOrderMap.values();
    }
}