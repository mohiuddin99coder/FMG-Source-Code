/**
 * Created by Adam-Hotmail on 10/12/2023.
 */

@IsTest
private class FMG_DRPProcessTest {
    @IsTest
    static void BasicExecutionTest() {
        DataMapInventoryService dataMapInventoryService = new DataMapInventoryService();
        DataMapFMG_DRPProcessData dataMapFMGDRPProcessData= new DataMapFMG_DRPProcessData();
        FMG_Inventory_Service inventoryService = new FMG_Inventory_Service();
        inventoryService.mockDataAccess = dataMapInventoryService;
        FMG_DRPProcess drpprocess = new FMG_DRPProcess();
        drpprocess.dataMock = dataMapFMGDRPProcessData;
        drpprocess.inventoryService = inventoryService;

        List<rstk__ictransreqh__c> inputs = new List<rstk__ictransreqh__c>();
        rstk__ictransreqh__c input = (rstk__ictransreqh__c)json.deserializeStrict('{"Id":"a2IDK000001XLUb2AO"}',rstk__ictransreqh__c.class);
        inputs.add(input);

        test.startTest();
        drpprocess.runBulkInvoke(inputs);
        test.stopTest();



        system.debug('-------------------------fmginvmovesRaw----------------------------');
        Assert.areEqual(1,dataMapFMGDRPProcessData.fmginvmovesRaw.size());
        Assert.areEqual('a1YDK000001ihX72AI',dataMapFMGDRPProcessData.fmginvmovesRaw[0].fmginvmove_icitem__c);
        Assert.areEqual('HC17FF00',dataMapFMGDRPProcessData.fmginvmovesRaw[0].fromlocnum__c);
        Assert.areEqual('a8uDK000000GqOcYAK',dataMapFMGDRPProcessData.fmginvmovesRaw[0].fromsylocid__c);
        Assert.areEqual(1,dataMapFMGDRPProcessData.fmginvmovesRaw[0].qty__c);
        Assert.areEqual('C10',dataMapFMGDRPProcessData.fmginvmovesRaw[0].tolocnum__c);
        Assert.areEqual('a8uDK000000GqVAYA0',dataMapFMGDRPProcessData.fmginvmovesRaw[0].tosylocid__c);
        //System.debug(json.serializePretty(dataMapFMGDRPProcessData.fmginvmovesRaw));


        system.debug('--------------------------transferRequests---------------------------');
        Assert.areEqual(1,dataMapFMGDRPProcessData.transferRequestsRaw.size());
        Assert.areEqual('a8uDK000000GqVAYA0',dataMapFMGDRPProcessData.transferRequestsRaw[0].rstk__ictransreq_tolocid__c);
        Assert.areEqual('C10',dataMapFMGDRPProcessData.transferRequestsRaw[0].rstk__ictransreq_tolocno__c);
        Assert.areEqual('Processed',dataMapFMGDRPProcessData.transferRequestsRaw[0].rstk__ictransreq_status__c);
        Assert.areEqual('AutoTransfer',dataMapFMGDRPProcessData.transferRequestsRaw[0].rstk__ictransreq_frlocno__c);
        Assert.areEqual('a2HDK000001nQFU2A2',dataMapFMGDRPProcessData.transferRequestsRaw[0].Id);
        Assert.areEqual('a8uDK000000GqVAYA0',dataMapFMGDRPProcessData.transferRequestsRaw[0].rstk__ictransreq_frlocid__c);
        //System.debug(json.serializePretty(dataMapFMGDRPProcessData.transferRequestsRaw));


        system.debug('-----------------------executeMovesRaw------------------------------');
        Assert.areEqual(1,dataMapFMGDRPProcessData.executeMovesRaw.size());
        Assert.areEqual('INVLOCLOC',dataMapFMGDRPProcessData.executeMovesRaw[0].rstk__sydata_txnid__c);
        Assert.areEqual('Inventory Transfer',dataMapFMGDRPProcessData.executeMovesRaw[0].rstk__sydata_txntype__c);
        Assert.areEqual(1,dataMapFMGDRPProcessData.executeMovesRaw[0].rstk__sydata_txnqty__c);
        Assert.areEqual(true,dataMapFMGDRPProcessData.executeMovesRaw[0].rstk__sydata_backgroundprocessing__c);
        Assert.areEqual('a8fDK000000KysNYAS',dataMapFMGDRPProcessData.executeMovesRaw[0].rstk__sydata_fromdiv__c);
        Assert.areEqual('a9CDK000000Kz0r2AC',dataMapFMGDRPProcessData.executeMovesRaw[0].rstk__sydata_fromsite__c);
        Assert.areEqual('a3BDK000001cxAN2AY',dataMapFMGDRPProcessData.executeMovesRaw[0].rstk__sydata_fromproj__c);
        Assert.areEqual('a8uDK000000GqOcYAK',dataMapFMGDRPProcessData.executeMovesRaw[0].rstk__sydata_fromlocid__c);
        Assert.areEqual('HC17FF00',dataMapFMGDRPProcessData.executeMovesRaw[0].rstk__sydata_fromlocnum__c);
        Assert.areEqual('a8fDK000000KysNYAS',dataMapFMGDRPProcessData.executeMovesRaw[0].rstk__sydata_todiv__c);
        Assert.areEqual('a9CDK000000Kz0r2AC',dataMapFMGDRPProcessData.executeMovesRaw[0].rstk__sydata_tosite__c);
        Assert.areEqual('a3BDK000001cxAN2AY',dataMapFMGDRPProcessData.executeMovesRaw[0].rstk__sydata_toproj__c);
        Assert.areEqual('a8uDK000000GqVAYA0',dataMapFMGDRPProcessData.executeMovesRaw[0].rstk__sydata_tolocid__c);
        Assert.areEqual('C10',dataMapFMGDRPProcessData.executeMovesRaw[0].rstk__sydata_tolocnum__c);
        Assert.areEqual('a1YDK000001ihX72AI',dataMapFMGDRPProcessData.executeMovesRaw[0].rstk__sydata_icitem__c);



        //System.debug(json.serializePretty(dataMapFMGDRPProcessData.executeMovesRaw));


        system.debug('-----------------------------------------------------');
    }


    public class DataMapInventoryService implements FMG_Inventory_IServiceData {

        public DataMapInventoryService(){
            getPickOrderLocationIdsDataRaw = new List<FMG_Configuration__c>();
            FMG_Configuration__c data = (FMG_Configuration__c)json.deserializeStrict('{"Id":"0000000000000004AS","Setting__c":"Create Inventory Move Source Location Ids","Value__c":"26,25","Application__c":"FMG Inventory Service"}',FMG_Configuration__c.class);
            getPickOrderLocationIdsDataRaw.add(data);

            getProductLocationsDataRaw=new List<rstk__icitem__c>();
            rstk__icitem__c icitem =(rstk__icitem__c)json.deserializeStrict('{"Id":"a1YDK000001ihX72AI","rstk__icitem_descr__c":"XTLPAS CRYSTAL AB   BICONE 4MM PK144","rstk__icitem_item__c":"a35DK000001ZjYZYA0","rstk__icitem_wmslocnum__c":"C17","rstk__icitem_wmslocid__c":"a8uDK000000GqVAYA0","rstk__ICLOCITEMs__r":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"rstk__iclocitem__c","url":"/services/data/v59.0/sobjects/rstk__iclocitem__c/a1yDK000001dc7qYAA"},"rstk__iclocitem_icitem__c":"a1YDK000001ihX72AI","Id":"a1yDK000001dc7qYAA","rstk__iclocitem_locqty__c":2216.000000,"rstk__iclocitem_locnum__c":"HC17FF00","rstk__iclocitem_locid__c":"a8uDK000000GqOcYAK","rstk__iclocitem_proj__c":"a3BDK000001cxAN2AY","rstk__iclocitem_locid__r":{"attributes":{"type":"rstk__sylocid__c","url":"/services/data/v59.0/sobjects/rstk__sylocid__c/a8uDK000000GqOcYAK"},"Id":"a8uDK000000GqOcYAK","rstk__sylocid_locid__c":"26","rstk__formula_name__c":"26 (Bunker Bulk)","rstk__sylocid_div__c":"a8fDK000000KysNYAS","rstk__sylocid_site__c":"a9CDK000000Kz0r2AC","rstk__sylocid_div__r":{"attributes":{"type":"rstk__sydiv__c","url":"/services/data/v59.0/sobjects/rstk__sydiv__c/a8fDK000000KysNYAS"},"Id":"a8fDK000000KysNYAS"},"rstk__sylocid_site__r":{"attributes":{"type":"rstk__sysite__c","url":"/services/data/v59.0/sobjects/rstk__sysite__c/a9CDK000000Kz0r2AC"},"Id":"a9CDK000000Kz0r2AC"}},"rstk__iclocitem_proj__r":{"attributes":{"type":"rstk__pjproj__c","url":"/services/data/v59.0/sobjects/rstk__pjproj__c/a3BDK000001cxAN2AY"},"Id":"a3BDK000001cxAN2AY"},"rstk__iclocitem_icitem__r":{"attributes":{"type":"rstk__icitem__c","url":"/services/data/v59.0/sobjects/rstk__icitem__c/a1YDK000001ihX72AI"},"Id":"a1YDK000001ihX72AI","rstk__icitem_descr__c":"XTLPAS CRYSTAL AB   BICONE 4MM PK144","rstk__icitem_item__c":"a35DK000001ZjYZYA0","rstk__icitem_supplymultiplier__c":0,"rstk__icitem_item__r":{"attributes":{"type":"rstk__peitem__c","url":"/services/data/v59.0/sobjects/rstk__peitem__c/a35DK000001ZjYZYA0"},"Id":"a35DK000001ZjYZYA0","rstk__peitem_item__c":"1101CY"}}}]},"rstk__icitem_item__r":{"attributes":{"type":"rstk__peitem__c","url":"/services/data/v59.0/sobjects/rstk__peitem__c/a35DK000001ZjYZYA0"},"Id":"a35DK000001ZjYZYA0","rstk__peitem_item__c":"1101CY"}}',rstk__icitem__c.class);
            getProductLocationsDataRaw.add(icitem);

        }

        List<FMG_Configuration__c> getPickOrderLocationIdsDataRaw{get;set;}
        public List<FMG_Configuration__c> getPickOrderLocationIdsData() {
            return getPickOrderLocationIdsDataRaw;
        }

        public List<rstk__icitem__c> getProductLocationsDataRaw{get;set;}
        public List<rstk__icitem__c> getProductLocationsData(Set<Id> products, List<String> locationIds) {
            return getProductLocationsDataRaw;
        }
    }


    public class DataMapFMG_DRPProcessData implements FMG_DRPProcessData {

        public DataMapFMG_DRPProcessData(){

            getRequestGroupsDataRaw = new List<rstk__ictransreqh__c>();
            rstk__ictransreqh__c transferGroup = (rstk__ictransreqh__c)json.deserializeStrict('{"Id":"a2IDK000001XLUb2AO","rstk__ictransreqs__r":{"totalSize":1,"done":true,"records":[{"rstk__ictransreq_ictransreqh__c":"a2IDK000001XLUb2AO","Id":"a2HDK000001nQFU2A2","rstk__ictransreq_status__c":"Planned"}]}}',rstk__ictransreqh__c.class);
            getRequestGroupsDataRaw.add(transferGroup);

            getPlannedTransferCondensedRecordsDataRaw = new List<Map<String, Object>>();
            String plannedTransferCondensedJson ='[{"site":"a9CDK000000Kz0r2AC","project":"a3BDK000001cxAN2AY","locnum":"C10","locid":"a8uDK000000GqVAYA0","div":"a8fDK000000KysNYAS","qty":1.0,"item":"a1YDK000001ihX72AI","rg":"a2IDK000001XLUb2AO"}]';
            for(object record : (List<Object>)JSON.deserializeUntyped(plannedTransferCondensedJson)){
                getPlannedTransferCondensedRecordsDataRaw.add((Map<String, Object>)record);
            }


            getTransferRequestsRaw = new List<rstk__ictransreq__c>();
            rstk__ictransreq__c transferRequest = (rstk__ictransreq__c)json.deserializeStrict('{"Id":"a2HDK000001nQFU2A2","rstk__ictransreq_status__c":"Processed","rstk__ictransreq_tolocid__c":"a8uDK000000GqVAYA0","rstk__ictransreq_tolocno__c":"C10"}',rstk__ictransreq__c.class);
            getTransferRequestsRaw.add(transferRequest);

        }
        public List<rstk__ictransreqh__c> getRequestGroupsDataRaw{get;set;}
        public List<rstk__ictransreqh__c> getRequestGroupsData(List<rstk__ictransreqh__c> groups) {
            return getRequestGroupsDataRaw;
        }

        public List<Map<String, Object>> getPlannedTransferCondensedRecordsDataRaw{get;set;}
        public List<Map<String, Object>> getPlannedTransferCondensedRecordsData(List<Id> requestIds) {
            return getPlannedTransferCondensedRecordsDataRaw;
        }


        public List<fmginvmove__c> fmginvmovesRaw{get;set;}
        public void createMoves(List<fmginvmove__c> fmginvmoves) {
            fmginvmovesRaw=fmginvmoves;
        }

        public List<rstk__ictransreq__c> getTransferRequestsRaw{get;set;}
        public List<rstk__ictransreq__c> getTransferRequests(List<Id> transferRequestIds) {
            return getTransferRequestsRaw;
        }

        public List<rstk__ictransreq__c> transferRequestsRaw{get;set;}
        public void updatePlannedRequests(List<rstk__ictransreq__c> transferRequests) {
            transferRequestsRaw = transferRequests;
        }

        public List<rstk__sydatat__c> executeMovesRaw{get;set;}
        public void executeMoves(List<rstk__sydatat__c> transfers) {
            executeMovesRaw = transfers;
        }
    }
}