/**
 * Created by Adam-Hotmail on 10/12/2023.
 */

public with sharing class FMG_DRPProcess implements FMG_DRPProcessData {

    // static reference so that the flow has access to none static methods
    @TestVisible
    private static FMG_DRPProcess fmgDrpProcess = new FMG_DRPProcess();

    // Method for use in a flow as a custom action
    @InvocableMethod(Label='FMG Planned Location Transfer Groups Execution' Category='FMG')
    public static void bulkInvoke(List<rstk__ictransreqh__c> inputs) {
        fmgDrpProcess.runBulkInvoke(inputs);
    }

    // The action that is being used to process the data
    public void runBulkInvoke(List<rstk__ictransreqh__c> inputs) {

        if (inputs.isEmpty()) {
            return;
        }

        List<Id> requests = getRequestGroups(inputs);
        processDRPRequestOnUpdate(requests);
    }


    @TestVisible
    private void  processDRPRequestOnUpdate(List<Id> requests){

        List<FMG_Inventory_Classes.InventoryTransferInput> items = getConsolidatedTransferRequests(requests);
        List<rstk__sydatat__c> transfers;
        transfers = inventoryService.generateTransfers(items);
        executeMoves(transfers);

        // Loops thru all moves and creates the objects for the internal system to pull
        List<fmginvmove__c> inventoryMoves = new List<fmginvmove__c>();

        for(rstk__sydatat__c record: transfers){

            fmginvmove__c newFMGTransfer = new fmginvmove__c();
            newFMGTransfer.fmginvmove_icitem__c = record.rstk__sydata_icitem__c;
            newFMGTransfer.fmginvmove_sydatat__c = record.Id;
            newFMGTransfer.fromlocnum__c = record.rstk__sydata_fromlocnum__c;
            newFMGTransfer.fromsylocid__c = record.rstk__sydata_fromlocid__c;
            newFMGTransfer.qty__c = record.rstk__sydata_txnqty__c;
            newFMGTransfer.tolocnum__c = record.rstk__sydata_tolocnum__c;
            newFMGTransfer.tosylocid__c = record.rstk__sydata_tolocid__c;
            newFMGTransfer.fromlocnum__c = record.rstk__sydata_fromlocnum__c;
            inventoryMoves.add(newFMGTransfer);
        }

        createMoves(inventoryMoves);

        List<rstk__ictransreq__c> transferRequestToUpdate = getTransferRequests(requests);
        for(rstk__ictransreq__c transferRequest: transferRequestToUpdate){
            transferRequest.rstk__ictransreq_frlocid__c=transferRequest.rstk__ictransreq_tolocid__c;
            transferRequest.rstk__ictransreq_frlocno__c='AutoTransfer';
            transferRequest.rstk__ictransreq_status__c = 'Processed';
        }
        updatePlannedRequests(transferRequestToUpdate);
    }

    public void executeMoves(List<rstk__sydatat__c> transfers){

        // To use the data mock object for storing changes
        // By doing this checking outputs can be done thru the mock object
        if(dataMock != null && Test.isRunningTest()){
            dataMock.executeMoves(transfers);
        } else {
            insert transfers;
        }
    }

    public List<rstk__ictransreq__c> getTransferRequests(List<Id> transferRequestIds){
        List<rstk__ictransreq__c> records = [SELECT Id,rstk__ictransreq_status__c,rstk__ictransreq_tolocid__c,rstk__ictransreq_tolocno__c FROM rstk__ictransreq__c WHERE Id = :transferRequestIds];

        // This it to override the results of the SOQL Query for testing
        if(dataMock != null && Test.isRunningTest()){
            records = dataMock.getTransferRequests(transferRequestIds);
        }
        return records;
    }

    public void updatePlannedRequests(List<rstk__ictransreq__c> transferRequests){

        // To use the data mock object for storing changes
        // By doing this checking outputs can be done thru the mock object
        if(dataMock != null && Test.isRunningTest()){
            dataMock.updatePlannedRequests(transferRequests);
        } else {
            update transferRequests;
        }
    }

    public void createMoves(List<fmginvmove__c> fmginvmoves){

        // To use the data mock object for storing changes
        // By doing this checking outputs can be done thru the mock object
        if(dataMock != null && Test.isRunningTest()){
            dataMock.createMoves(fmginvmoves);
        } else {
            insert fmginvmoves;
        }
    }

    @TestVisible
    private FMG_DRPProcessData dataMock{get;set;}

    @TestVisible
    private FMG_Inventory_IService inventoryService = new FMG_Inventory_Service();

    public List<rstk__ictransreqh__c> getRequestGroupsData(List<rstk__ictransreqh__c> groups){

        List<Id> lookupIds = new List<Id>();
        for(rstk__ictransreqh__c ictransreqh: groups){
            lookupIds.add(ictransreqh.Id);
        }

        List<rstk__ictransreqh__c> records = [SELECT Id,
        (
                SELECT Id, rstk__ictransreq_status__c
                FROM rstk__ictransreqs__r
        )
        FROM rstk__ictransreqh__c
        WHERE Id = :lookupIds];

        // This it to overide the results of the SOQL Query for testing
        if(dataMock != null && Test.isRunningTest()){
            records =  dataMock.getRequestGroupsData(groups);
        }
        return records;
    }

    public List<Map<String, Object>> getPlannedTransferCondensedRecordsData(List<Id> requestIds){

        List<Map<String, Object>> records = new List<Map<String, Object>>();

        for(AggregateResult record : [SELECT
                rstk__ictransreq_tosite__c site,
                rstk__ictransreq_toproject__c project,
                rstk__ictransreq_tolocno__c locnum,
                rstk__ictransreq_tolocid__c locid,
                rstk__ictransreq_tolocid__r.rstk__sylocid_div__c div,
                SUM(rstk__ictransreq_origqty__c) qty,
                rstk__ictransreq_item__c item,
                rstk__ictransreq_ictransreqh__c rg
        FROM rstk__ictransreq__c
        WHERE Id = :requestIds
        GROUP BY rstk__ictransreq_item__c, rstk__ictransreq_ictransreqh__c,
                rstk__ictransreq_tosite__c, rstk__ictransreq_toproject__c,
                rstk__ictransreq_tolocno__c, rstk__ictransreq_tolocid__c,
                rstk__ictransreq_tolocid__r.rstk__sylocid_div__c]){
            records.add(record.getPopulatedFieldsAsMap());
        }

        // This it to override the results of the SOQL Query for testing
        if(dataMock != null && Test.isRunningTest()){
            records =  dataMock.getPlannedTransferCondensedRecordsData(requestIds);
        }

        return records;
    }

    @TestVisible
    private List<FMG_Inventory_Classes.InventoryTransferInput> getConsolidatedTransferRequests(List<Id> requests){
        List<FMG_Inventory_Classes.InventoryTransferInput> items = new List<FMG_Inventory_Classes.InventoryTransferInput>();
        List<Map<String, Object>> records = getPlannedTransferCondensedRecordsData(requests);
        for(Map<String, Object> record:records){
            FMG_Inventory_Classes.InventoryTransferInput item = new FMG_Inventory_Classes.InventoryTransferInput();
            item.Item = (Id)record.get('item');
            item.Qty = (Decimal)record.get('qty');
            item.Div = (Id)record.get('div');
            item.LocId = (Id)record.get('locid');
            item.LocNo = (String)record.get('locnum');
            item.Project = (Id)record.get('project');
            item.Site = (Id)record.get('site');
            items.add(item);
        }

        return items;
    }

    @TestVisible
    private List<Id> getRequestGroups(List<rstk__ictransreqh__c> groups){
        List<rstk__ictransreqh__c> requestGroupData = getRequestGroupsData(groups);
        List<Id> requests = new List<Id>();
        for(rstk__ictransreqh__c requestGroup: requestGroupData){
            for(rstk__ictransreq__c request : requestGroup.rstk__ictransreqs__r){
                if(request.rstk__ictransreq_status__c == 'Planned'){
                    requests.add(request.Id);
                }
            }
        }

        return requests;
    }
}