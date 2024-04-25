/**
 * Created by Adam-Hotmail on 6/5/2023.
 */

public with sharing class FMGRSAPI_Orders_Service implements FMGRSAPI_Orders_ServiceInterface,FMGRSAPI_Orders_Service_DataInterface {


    @TestVisible
    private FMGRSAPI_IncrementingNumbersWIthLock batchId = new FMGRSAPI_IncrementingNumbersWIthLock('orderProcessingBatch');

    // for dealing with data level access and Unit test data injection
    @TestVisible
    private FMGRSAPI_Orders_Service_DataInterface dataAccess = this;

    @TestVisible
    private class ProcessOrders_RawOrder{
        public Id Id{get;set;}

        /**
         * @description fmgsohdrext__r.Id
         **/
        public fmgsohdrext__c Batch{get;set;}

        /**
         * @description rstk__solines__r
         **/
        public List<ProcessOrders_RawOrderLine> orderLines{get;set;}

        /**
         * @description rstk__soships__r[Id,rstk__soship_closed__c]
         **/
        public Map<Id,Boolean> ShippingClosed{get;set;}
        public ProcessOrders_RawOrder(){}
        public ProcessOrders_RawOrder(rstk__sohdr__c orderData){
            this.Id = orderData.Id;
            ShippingClosed = new Map<Id, Boolean>();
            orderLines = new List<ProcessOrders_RawOrderLine>();
            if(!orderData.fmgsohdrext__r.isEmpty()){
                this.Batch = orderData.fmgsohdrext__r[0];
            }

            for(rstk__soship__c ship:orderData.rstk__soships__r){
                ShippingClosed.put(ship.Id,ship.rstk__soship_closed__c);
            }

            for(rstk__soline__c line:orderData.rstk__solines__r){
                orderLines.add(new ProcessOrders_RawOrderLine(line));
            }
        }
    }

    @TestVisible
    private class ProcessOrders_RawOrderLine{
        public Id Id{get;set;}

        /**
         * @description rstk__soline_avtoallocpick__c
         **/
        public Decimal QtyAvailableAndPick{get;set;}

        /**
         * @description rstk__soline_avtopack__c
         **/
        public Decimal ToPack {get;set;}
        /**
         * @description rstk__soline_avtoship__c
         **/
        public Decimal ToShip{get;set;}

        /**
         * @description rstk__soline_icitem__r.rstk__icitem_wmslocid__c
         **/
        public Id LocationId{get;set;}

        /**
         * @description rstk__soline_icitem__r.rstk__icitem_wmslocnum__c
         **/
        public String LocationNumber{get;set;}
        public ProcessOrders_RawOrderLine(){}
        public ProcessOrders_RawOrderLine(rstk__soline__c line){
            this.Id = line.Id;
            this.QtyAvailableAndPick = line.rstk__soline_avtoallocpick__c;
            this.ToPack = line.rstk__soline_avtopack__c;
            this.ToShip=line.rstk__soline_avtoship__c;
            this.LocationId=line.rstk__soline_icitem__r.rstk__icitem_wmslocid__c;
            this.LocationNumber=line.rstk__soline_icitem__r.rstk__icitem_wmslocnum__c;
        }
    }


    @TestVisible
    private Map<Id,ProcessOrders_RawOrder> UnitTestProcessOrders_GetOrders {get;set;}

    public List<rstk__sohdr__c> processOrders_GetOrdersData(Set<Id> orderIds){
        List<rstk__sohdr__c> orders = [
                SELECT Id,
                (
                        SELECT Id, rstk__soline_avtoallocpick__c,
                                rstk__soline_avtopack__c, rstk__soline_avtoship__c,
                                rstk__soline_icitem__r.rstk__icitem_wmslocnum__c, rstk__soline_icitem__r.rstk__icitem_wmslocid__c
                        FROM rstk__solines__r
                ),
                (
                        SELECT Id
                        FROM fmgsohdrext__r
                ),
                (
                        SELECT Id, rstk__soship_closed__c
                        FROM rstk__soships__r
                )
                FROM rstk__sohdr__c
                WHERE Id = :orderIds
        ];

        if(ordersServiceDataAccessOverride != null && Test.isRunningTest()){
            orders = ordersServiceDataAccessOverride.processOrders_GetOrdersData(orderIds);
        }

        return orders;
    }

    @TestVisible
    private Map<Id,ProcessOrders_RawOrder> processOrders_GetOrders(Set<Id> orderIds){

        // This is for mocking the output
        if(Test.isRunningTest() && UnitTestProcessOrders_GetOrders != null){
            return UnitTestProcessOrders_GetOrders;
        }

        Map<Id,ProcessOrders_RawOrder> sohdrByIds = new Map<Id, ProcessOrders_RawOrder>();

        List<rstk__sohdr__c> orders = processOrders_GetOrdersData(orderIds);

        for(rstk__sohdr__c order: orders){
            if(!sohdrByIds.containsKey(order.Id)){
                sohdrByIds.put(order.Id,new ProcessOrders_RawOrder(order));
            }
        }

        return sohdrByIds;
    }

    @TestVisible
    private void addNewSyDataPick(ProcessOrderEvent orderEvent,Map<Id,ProcessOrders_RawOrder> sohdrByIds,Map<Id,fmgsohdrext__c> updatefmgsohdr,Map<Id,rstk__sydata__c> pickEvents,Boolean isBackground,Boolean includePack){
        System.debug(LoggingLevel.FINE,'pickEvents: ' + JSON.serializePretty(pickEvents));
        System.debug(LoggingLevel.FINE,'updatefmgsohdr: ' + JSON.serializePretty(updatefmgsohdr));
        // Checks to see if there was a order pulled
        if(sohdrByIds.containsKey(orderEvent.SalesforceOrderId)){
            ProcessOrders_RawOrder sohdr = sohdrByIds.get(orderEvent.SalesforceOrderId);

            System.debug(LoggingLevel.FINE,'sohdr.orderLines: ' + JSON.serializePretty(sohdr));
            // There should always be a header else the correct process was not executed
            if(sohdr.Batch != null) {



                // Updates the fmg sales order header extension
                if(updatefmgsohdr.containsKey(sohdr.Batch.Id)){
                    updatefmgsohdr.get(sohdr.Batch.Id).Time_of_Pick__c = orderEvent.EventTime;
                }else {
                    sohdr.Batch.Time_of_Pick__c = orderEvent.EventTime;
                    updatefmgsohdr.put(sohdr.Batch.Id,sohdr.Batch);
                }
                System.debug(LoggingLevel.FINE,'updatefmgsohdr: ' + JSON.serializePretty(updatefmgsohdr));
                System.debug(LoggingLevel.FINE,'sohdr.orderLines: ' + JSON.serializePretty(sohdr.orderLines));
                //loop thru lines and build the sydata objects
                for (ProcessOrders_RawOrderLine soline : sohdr.orderLines) {

                    if (soline.QtyAvailableAndPick > 0 && !pickEvents.containsKey(soline.Id)) {

                        rstk__sydata__c sydataAction = new rstk__sydata__c();
                        if(includePack){
                            sydataAction.rstk__sydata_txntype__c = 'Sales Order Pick-Pack';
                        } else {
                            sydataAction.rstk__sydata_txntype__c = 'Sales Order Pick(Issue)';
                        }
                        sydataAction.rstk__sydata_txnqty__c = soline.QtyAvailableAndPick;
                        sydataAction.rstk__sydata_soline__c = soline.Id;
                        sydataAction.rstk__sydata_sylocid__c = soline.LocationId;
                        sydataAction.rstk__sydata_locnum__c = soline.LocationNumber;

                        // To process by background thread
                        sydataAction.rstk__sydata_backgroundprocessing__c = isBackground;
                        pickEvents.put(soline.Id, sydataAction);
                    }
                }
            } else {
                System.debug(LoggingLevel.WARN,'Did not process order due to missing the fmgsohdrext - ' + sohdr.Id);
            }
        } else {
            System.debug(LoggingLevel.WARN,'Order was not found - ' + orderEvent.SalesforceOrderId);
        }

        System.debug(LoggingLevel.FINE,'pickEvents: ' + JSON.serializePretty(pickEvents));
        System.debug(LoggingLevel.FINE,'updatefmgsohdr: ' + JSON.serializePretty(updatefmgsohdr));

    }

    @TestVisible
    private void addNewSyDataPack(ProcessOrderEvent orderEvent,Map<Id,ProcessOrders_RawOrder> sohdrByIds,Map<Id,fmgsohdrext__c> updatefmgsohdr,Map<Id,rstk__sydata__c> packEvents,Boolean isBackground){
        // Checks to see if there was a order pulled
        if(sohdrByIds.containsKey(orderEvent.SalesforceOrderId)){
            ProcessOrders_RawOrder sohdr = sohdrByIds.get(orderEvent.SalesforceOrderId);

            // There should always be a header else the correct process was not executed
            if(sohdr.Batch != null) {

                // Updates the fmg sales order header extension
                if(updatefmgsohdr.containsKey(sohdr.Batch.Id)){
                    updatefmgsohdr.get(sohdr.Batch.Id).Time_of_Pack__c = orderEvent.EventTime;
                }else {
                    sohdr.Batch.Time_of_Pack__c = orderEvent.EventTime;
                    updatefmgsohdr.put(sohdr.Batch.Id,sohdr.Batch);
                }

                //loop thru lines and build the sydata objects
                for (ProcessOrders_RawOrderLine soline : sohdr.orderLines) {

                    if (!packEvents.containsKey(soline.Id)) {

                        rstk__sydata__c sydataAction = new rstk__sydata__c();
                        sydataAction.rstk__sydata_txntype__c = 'Sales Order Pack';
                        sydataAction.rstk__sydata_soline__c = soline.Id;

                        // To process by background thread
                        sydataAction.rstk__sydata_backgroundprocessing__c = isBackground;
                        packEvents.put(soline.Id, sydataAction);
                    }
                }
            } else {
                System.debug(LoggingLevel.WARN,'Did not process order due to missing the fmgsohdrext - ' + sohdr.Id);
            }
        } else {
            System.debug(LoggingLevel.WARN,'Order was not found - ' + orderEvent.SalesforceOrderId);
        }
    }

    @TestVisible
    private void addNewSyDataShip(ProcessOrderEvent orderEvent,Map<Id,ProcessOrders_RawOrder> sohdrByIds,Map<Id,fmgsohdrext__c> updatefmgsohdr,Map<Id,rstk__sydata__c> shipEvents,Boolean isBackground,Boolean includeInvoice){
        // Checks to see if there was a order pulled
        if(sohdrByIds.containsKey(orderEvent.SalesforceOrderId)){
            ProcessOrders_RawOrder sohdr = sohdrByIds.get(orderEvent.SalesforceOrderId);

            // There should always be a header else the correct process was not executed
            if(sohdr.Batch != null) {

                // Updates the fmg sales order header extension
                if(updatefmgsohdr.containsKey(sohdr.Batch.Id)){
                    updatefmgsohdr.get(sohdr.Batch.Id).Time_of_Ship__c = orderEvent.EventTime;
                }else {
                    sohdr.Batch.Time_of_Ship__c = orderEvent.EventTime;
                    updatefmgsohdr.put(sohdr.Batch.Id,sohdr.Batch);
                }

                //loop thru lines and build the sydata objects
                for (Id soshipId : sohdr.ShippingClosed.keySet()) {

                    // Checks to see if object for changing is not already created.
                    // Also that the sales order shipper header is not closed
                    if (!shipEvents.containsKey(soshipId) && sohdr.ShippingClosed.get(soshipId) == false) {

                        rstk__sydata__c sydataAction = new rstk__sydata__c();
                        sydataAction.rstk__sydata_txntype__c = 'Sales Order Shipment';
                        sydataAction.rstk__sydata_soship__c = soshipId;

                        // Set to TRUE if the Invoice is to be automatically generated
                        sydataAction.rstk__sydata_spawninv__c = includeInvoice;

                        // To process by background thread
                        sydataAction.rstk__sydata_backgroundprocessing__c = isBackground;
                        shipEvents.put(soshipId, sydataAction);
                    }
                }
            } else {
                System.debug(LoggingLevel.WARN,'Did not process order due to missing the fmgsohdrext - ' + sohdr.Id);
            }
        } else {
            System.debug(LoggingLevel.WARN,'Order was not found - ' + orderEvent.SalesforceOrderId);
        }
    }

    @TestVisible
    private void addNewSyDataInvoice(ProcessOrderEvent orderEvent,Map<Id,ProcessOrders_RawOrder> sohdrByIds,Map<Id,rstk__sydata__c> createInvoiceEvents,Boolean isBackground){
        // Checks to see if there was a order pulled
        if(sohdrByIds.containsKey(orderEvent.SalesforceOrderId)){
            System.debug(LoggingLevel.FINE,'Found Order: ' + orderEvent.SalesforceOrderId);
            ProcessOrders_RawOrder sohdr = sohdrByIds.get(orderEvent.SalesforceOrderId);

            // There should always be a header else the correct process was not executed
            if(sohdr.Batch != null) {

                System.debug(LoggingLevel.FINE,orderEvent.SalesforceOrderId + ' has Batch');
                //loop thru lines and build the sydata objects
                for (Id soshipId : sohdr.ShippingClosed.keySet()) {

                    System.debug(LoggingLevel.FINE,orderEvent.SalesforceOrderId + 'has shipper ' + soshipId);
                    // Checks to see if object for changing is not already created.
                    // Also that the sales order shipper header is closed
                    if (!createInvoiceEvents.containsKey(soshipId) && sohdr.ShippingClosed.get(soshipId) == true) {

                        System.debug(LoggingLevel.FINE,orderEvent.SalesforceOrderId + ' creating sydata ' + soshipId);
                        rstk__sydata__c sydataAction = new rstk__sydata__c();
                        sydataAction.rstk__sydata_txntype__c = 'Create Invoice for Shipper';
                        sydataAction.rstk__sydata_soship__c = soshipId;

                        // To process by background thread
                        sydataAction.rstk__sydata_backgroundprocessing__c = isBackground;
                        createInvoiceEvents.put(soshipId, sydataAction);
                    }
                }
            } else {
                System.debug(LoggingLevel.WARN,'Did not process order due to missing the fmgsohdrext - ' + sohdr.Id);
            }
        } else {
            System.debug(LoggingLevel.WARN,'Order was not found - ' + orderEvent.SalesforceOrderId);
        }
    }


    @TestVisible
    Map<Id,rstk__sydata__c> pickEventsCollection = new  Map<Id,rstk__sydata__c>();
    @TestVisible
    Map<Id,rstk__sydata__c> packEventsCollection = new  Map<Id,rstk__sydata__c>();
    @TestVisible
    Map<Id,rstk__sydata__c> shipEventsCollection = new  Map<Id,rstk__sydata__c>();
    @TestVisible
    Map<Id,rstk__sydata__c> invoiceEventsCollection = new  Map<Id,rstk__sydata__c>();
    @TestVisible
    Map<Id,fmgsohdrext__c> updatefmgsohdrCollection = new Map<Id, fmgsohdrext__c>();

    public List<String> processOrders(List<ProcessOrderEvent> orderEvents,Boolean isBackground){
        List<String> returnCollection = new List<String>();
        Set<Id> orderIds = new Set<Id>();
        Map<Id,ProcessOrders_RawOrder> sohdrByIds = new Map<Id, ProcessOrders_RawOrder>();



        for(ProcessOrderEvent orderEvent:orderEvents){
            orderIds.add(orderEvent.SalesforceOrderId);
        }

        sohdrByIds = processOrders_GetOrders(orderIds);

        System.debug('***************** order Events ******************');
        System.debug(JSON.serializePretty(orderEvents));
        System.debug('***************** sohdr By Ids ******************');
        System.debug(JSON.serializePretty(sohdrByIds));



        for(ProcessOrderEvent orderEvent:orderEvents) {
            switch on orderEvent.OrderEvent {
                when 'Picked' {
                    addNewSyDataPick(orderEvent,sohdrByIds,updatefmgsohdrCollection,pickEventsCollection,isBackground,false);
                }
                when 'Packed' {
                    addNewSyDataPack(orderEvent,sohdrByIds,updatefmgsohdrCollection,packEventsCollection,isBackground);
                }
                when 'Shipped' {
                    addNewSyDataShip(orderEvent,sohdrByIds,updatefmgsohdrCollection,shipEventsCollection,isBackground,false);
                }
                when 'ShippedWithInvoice' {
                    addNewSyDataShip(orderEvent,sohdrByIds,updatefmgsohdrCollection,shipEventsCollection,isBackground,true);
                }
                when 'PickedPacked' {
                    addNewSyDataPick(orderEvent,sohdrByIds,updatefmgsohdrCollection,pickEventsCollection,isBackground,true);
                }
                when 'CreateInvoice' {
                    addNewSyDataInvoice(orderEvent,sohdrByIds,invoiceEventsCollection,isBackground);
                }
                when else {
                    System.debug('Unknown Data');
                    System.debug(JSON.serializePretty(orderEvent));
                }
            }
        }

        // adds sydata records to be picked / Pick-Pack
        if(!pickEventsCollection.isEmpty()){
            System.debug(LoggingLevel.FINE,'***************** Pick Events ******************');
            System.debug(LoggingLevel.FINE,JSON.serializePretty(pickEventsCollection));

            // needs to be skipped on test due to possible missing cross-reference in Unit Test
            if(!Test.isRunningTest()) {
                insert pickEventsCollection.values();
            }

            System.debug(LoggingLevel.FINER,JSON.serializePretty(pickEventsCollection)); // doing after update to have sydata Id
        }

        // adds sydata records to be pack
        if(!packEventsCollection.isEmpty()){
            System.debug(LoggingLevel.FINE,'***************** Pack Events ******************');
            System.debug(LoggingLevel.FINE,JSON.serializePretty(packEventsCollection));

            // needs to be skipped on test due to possible missing cross-reference in Unit Test
            if(!Test.isRunningTest()) {
                insert packEventsCollection.values();
            }

            System.debug(LoggingLevel.FINER,JSON.serializePretty(packEventsCollection)); // doing after update to have sydata Id
        }

        // adds sydata records to be ship
        if(!shipEventsCollection.isEmpty()){
            System.debug(LoggingLevel.FINE,'***************** Ship Events ******************');
            System.debug(LoggingLevel.FINE,JSON.serializePretty(shipEventsCollection));

            // needs to be skipped on test due to possible missing cross-reference in Unit Test
            if(!Test.isRunningTest()){
                insert shipEventsCollection.values();
            }

            System.debug(LoggingLevel.FINER,JSON.serializePretty(shipEventsCollection)); // doing after update to have sydata Id
        }

        // adds sydata records to create invoice
        if(!invoiceEventsCollection.isEmpty()){
            System.debug(LoggingLevel.FINE,'***************** Ship Events ******************');
            System.debug(LoggingLevel.FINE,JSON.serializePretty(invoiceEventsCollection));

            // needs to be skipped on test due to possible missing cross-reference in Unit Test
            if(!Test.isRunningTest()){
                insert invoiceEventsCollection.values();
            }

            System.debug(LoggingLevel.FINER,JSON.serializePretty(invoiceEventsCollection)); // doing after update to have sydata Id
        }

        // Updates the custom sales order header with pick, pack, ship times
        if(!updatefmgsohdrCollection.isEmpty()){
            System.debug(LoggingLevel.FINE,'***************** Custom Header Update ******************');
            System.debug(LoggingLevel.FINE,JSON.serializePretty(updatefmgsohdrCollection));

            // needs to be skipped on test due to possible missing cross-reference in Unit Test
            if(!Test.isRunningTest()) {
                update updatefmgsohdrCollection.values();
            }

            System.debug(LoggingLevel.FINER,JSON.serializePretty(updatefmgsohdrCollection)); // doing after update to have sydata Id
        }

        // adds sydata Id to return collection for lookup of processes later
        for(rstk__sydata__c sydata: pickEventsCollection.values()){
            returnCollection.add(sydata.Id);
        }

        for(rstk__sydata__c sydata: packEventsCollection.values()){
            returnCollection.add(sydata.Id);
        }
        for(rstk__sydata__c sydata: shipEventsCollection.values()){
            returnCollection.add(sydata.Id);
        }
        for(rstk__sydata__c sydata: invoiceEventsCollection.values()){
            returnCollection.add(sydata.Id);
        }
        System.debug(LoggingLevel.FINE,'***************** Sydata Ids ******************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(returnCollection));
        return returnCollection;
    }

    @TestVisible
    private class generateOrderBatch_RawOrderHeader{
        public Id Id{get;set;}
        public String Name{get;set;}
        public Id AccountId{get;set;}
        public generateOrderBatch_RawOrderHeader(){}
        public generateOrderBatch_RawOrderHeader(rstk__sohdr__c sohdr){
            this.Id = sohdr.Id;
            this.Name = sohdr.Name;
            this.AccountId = sohdr.rstk__sohdr_account__r.Id;
        }
    }

    @TestVisible
    List<generateOrderBatch_RawOrderHeader> UnitTestGenerateOrderBatch_GetOrders {get;set;}

    public List<rstk__sohdr__c> generateOrderBatch_GetOrdersData() {
        List<rstk__sohdr__c> records = [SELECT Id, Name,rstk__sohdr_account__r.Id,CreatedDate,
        (
                SELECT Id, rstk__soline_firm__c
                FROM rstk__solines__r
        ),
        (
                SELECT Id, rstk__soapi_processed__c, rstk__soapi_mode__c
                FROM rstk__soapis__r where rstk__soapi_mode__c = 'Add Line'
        )
        FROM rstk__sohdr__c
        WHERE Id NOT IN (
                SELECT fmgsohdrext_sohdr__c
                FROM fmgsohdrext__c
        )
        AND Id NOT IN (
                SELECT rstk__soline_sohdr__c
                FROM rstk__soline__c
                WHERE rstk__soline_firm__c = FALSE
        )
        ORDER BY CreatedDate];

        if(ordersServiceDataAccessOverride != null && Test.isRunningTest()){
            records = ordersServiceDataAccessOverride.generateOrderBatch_GetOrdersData();
        }

        return records;
    }

    /**
     * @param size Total records to return
     *
     * @return orders to be processed
     * @description only orders that have not been processed and all there items are in a firm state. the order that is pulled is from oldest to newest
     **/
    @TestVisible
    private List<generateOrderBatch_RawOrderHeader> generateOrderBatch_GetOrders(Integer size){
        if(Test.isRunningTest() && UnitTestGenerateOrderBatch_GetOrders != null){
            return UnitTestGenerateOrderBatch_GetOrders;
        }
        List<generateOrderBatch_RawOrderHeader> orders = new List<generateOrderBatch_RawOrderHeader>();

        List<rstk__sohdr__c> records = generateOrderBatch_GetOrdersData();


        for(rstk__sohdr__c order:records){
            if(!order.rstk__solines__r.isEmpty() && order.rstk__soapis__r.size() == order.rstk__solines__r.size() ) {
                orders.add(new generateOrderBatch_RawOrderHeader(order));
            }
            if(orders.size()>=size){
                break;
            }
        }
        return orders;
    }

    @TestVisible
    private class generateOrderBatch_RawAccountInformation{
        generateOrderBatch_RawAccountInformation(){
            IsPlatinum = false;
        }
        public Id Id{get;set;}
        public Map<Id,Datetime> orders{get;set;}
        public Id FirstOrder {get;set;}
        public Boolean IsPlatinum{get;set;}
    }


    public List<Account> getAccountInfo(Set<Id> accountIds){
        // Orders Is needed to check for legacy orders
        // rstk__Sales_Orders__pr is the rootstock sales order
        List<Account> baseData = [SELECT Id,
        (
                SELECT Id, OrderReferenceNumber, EffectiveDate
                FROM Orders
                ORDER BY EffectiveDate asc
                LIMIT 1
        ),
        (
                SELECT Id, rstk__sohdr_order__c, rstk__sohdr_dateadded__c
                FROM rstk__Sales_Orders__pr
                ORDER BY rstk__sohdr_dateadded__c asc
                LIMIT 1
        ), Type

        FROM Account WHERE Id = :accountIds
        ];

        return baseData;
    }


    @TestVisible
    private List<generateOrderBatch_RawAccountInformation> generateOrderBatch_GetAccountInformation(Set<Id> accountIds){

        List<generateOrderBatch_RawAccountInformation> accounts = new List<generateOrderBatch_RawAccountInformation>();

        List<Account> baseData = dataAccess.getAccountInfo(accountIds);


        for(Account accountInfo : baseData){

            generateOrderBatch_RawAccountInformation customAccountInfo = new generateOrderBatch_RawAccountInformation();


            customAccountInfo.Id = accountInfo.Id;
            customAccountInfo.orders = new Map<Id, Datetime>();

            if(!accountInfo.rstk__Sales_Orders__pr.isEmpty()) {

                rstk__sohdr__c oldestsohdr = accountInfo.rstk__Sales_Orders__pr[0];
                customAccountInfo.FirstOrder = oldestsohdr.Id;

                // There can be more then one Order in OMS The empty check is just in case there is no OMS Number(Dev and RSPilot)
                if(!accountInfo.Orders.isEmpty()) {

                    Order omsOrder = accountInfo.Orders[0];

                    // Checks to see if the first order number is not the same as the first rootstock number
                    if(omsOrder.OrderReferenceNumber != oldestsohdr.rstk__sohdr_order__c){

                        // Checks to see if the OMS Order is the same age or older to be the first order
                        if(omsOrder.EffectiveDate < oldestsohdr.rstk__sohdr_dateadded__c){

                            customAccountInfo.FirstOrder = omsOrder.Id;
                        }
                    }
                }

                for (rstk__sohdr__c order : accountInfo.rstk__sohdrs__r) {
                    customAccountInfo.orders.put(order.Id, order.rstk__sohdr_dateadded__c);
                }
            }

            customAccountInfo.IsPlatinum = accountInfo.Type == 'Platinum';

            accounts.add(customAccountInfo);
        }

        return accounts;
    }


    public Integer generateOrderBatch(Integer size){
        //Gets the next
        batchId.getNext();
        Set<Id> Accounts = new Set<Id>();


        List<generateOrderBatch_RawOrderHeader> orders = generateOrderBatch_GetOrders(size);



        for(generateOrderBatch_RawOrderHeader sohdr : orders){
            Accounts.add(sohdr.AccountId);
        }

        List<generateOrderBatch_RawAccountInformation> AccountInformation = generateOrderBatch_GetAccountInformation(Accounts);



        Set<Id> firstOrders = new Set<Id>();

        Map<Id,generateOrderBatch_RawAccountInformation> AccountInformationLookup  = new Map<Id, FMGRSAPI_Orders_Service.generateOrderBatch_RawAccountInformation>();

        // Gets all orders that are the first for the User Accounts
        for(generateOrderBatch_RawAccountInformation rawAccountInformation : AccountInformation){
            if(!AccountInformationLookup.containsKey(rawAccountInformation.Id)){
                AccountInformationLookup.put(rawAccountInformation.Id,rawAccountInformation);
            }

            if (rawAccountInformation.FirstOrder != null) {
                firstOrders.add(rawAccountInformation.FirstOrder);
            }
        }

        generateOrderBatch_NewHeaders = new List<fmgsohdrext__c>();



        Integer newBatchId = batchId.value;
        for(generateOrderBatch_RawOrderHeader sohdr : orders){
            fmgsohdrext__c newExtensionHeader = new fmgsohdrext__c(
                    fmgsohdrext_sohdr__c = sohdr.Id,
                    IsFirstOrder__c = firstOrders.contains(sohdr.Id),
                    batchId__c = newBatchId,
                    Name = sohdr.Name,
                    IsPlatinum__c = AccountInformationLookup.get(sohdr.AccountId).IsPlatinum

            );
            generateOrderBatch_NewHeaders.add(newExtensionHeader);
        }

        if(generateOrderBatch_NewHeaders.isEmpty()){
            return -1;
        } else {
            // Would error due to order information is not in the system
            if(!Test.isRunningTest()) {
                insert generateOrderBatch_NewHeaders;
            }
        }


        return newBatchId;
    }

    @TestVisible
    private List<fmgsohdrext__c> generateOrderBatch_NewHeaders{get;set;}

    /**
     * @param orderIds Collection of Order Header Ids
     *
     * @return Collection of orders
     **/
    public BatchData getOrdersById(List<Id> orderIds){
        List<rstk__sohdr__c> orders = queryOrdersById(orderIds);
        List<string> orderNumbers = new List<String>();
        for(rstk__sohdr__c order:orders){
            orderNumbers.add(order.rstk__sohdr_order__c);
        }
        Map<String, OrderDeliveryGroupSummary> orderDeliveryGroupSummarys = queryOrderDeliveryGroupSummarys(orderNumbers);
        BatchData returnObject = formatData(orders,orderDeliveryGroupSummarys);
        return returnObject;
    }


    public List<fmgsohdrext__c> getOrdersByBatchIdData(Integer batchId){
        List<fmgsohdrext__c> records = [SELECT fmgsohdrext_sohdr__c
        FROM fmgsohdrext__c
        WHERE batchId__c = :batchId];

        if(ordersServiceDataAccessOverride != null && Test.isRunningTest()){
            records = ordersServiceDataAccessOverride.getOrdersByBatchIdData(batchId);
        }

        return records;
    }
    /**
     * @param batchId The id of the batch to be pulled
     *
     * @return Collection of orders
     **/
    public BatchData getOrdersByBatchId(Integer batchId ){

        // Pulls all orders from batch
        Set<Id> ids = new Set<Id>();

        List<fmgsohdrext__c> records = getOrdersByBatchIdData(batchId);
        for(fmgsohdrext__c id : records){
            ids.add(id.fmgsohdrext_sohdr__c);
        }


        // get the order information
        BatchData returnObject = getOrdersById(new List<Id>(ids));

        // Set batch Id that was used
        returnObject.BatchId = batchId;
        return returnObject;
    }

    private static BatchData formatData(List<rstk__sohdr__c> orders,Map<String,OrderDeliveryGroupSummary> orderDeliveryGroupSummaryMap){
        BatchData returnBatchData = new BatchData();
        returnBatchData.Orders = new List<OrderInfo>();

        for(rstk__sohdr__c order:orders){
            // Inital Order Creation
            OrderInfo newOrderObject = new OrderInfo();
            newOrderObject.Lines = new List<OrderLineInfo>();
            newOrderObject.Id = order.Id;
            newOrderObject.OrderNumber = order.rstk__sohdr_order__c;

            newOrderObject.CustomerName=order.rstk__sohdr_custno__r.rstk__socust_sf_account_name__c;
            newOrderObject.CustomerNumber=order.rstk__sohdr_custno__r.rstk__socust_custno__c;
            newOrderObject.CustomerId=order.rstk__sohdr_custno__r.Id;

            newOrderObject.Comments=order.Order_Comment__c;


            if(order.No_Catalog_in_Order__c == null){
                newOrderObject.IsNoCatalog = false;
            } else {
                newOrderObject.IsNoCatalog=order.No_Catalog_in_Order__c.toUpperCase().trim() == 'YES';
            }

            if(order.signature_Required__c == null){
                newOrderObject.IsSignatureRequired = false;
            } else {
                newOrderObject.IsSignatureRequired=order.signature_Required__c.toUpperCase().trim() == 'YES';
            }



            newOrderObject.ThirdPartyFedEx = order.rstk__sohdr_account__r.Fed_Ex_Account_Number__c;
            newOrderObject.ThirdPartyUps = order.rstk__sohdr_account__r.UPS_Account_Number__c;

            if(order.Correction_Order__c == null){
                newOrderObject.IsCorrection = false;
            } else {
                newOrderObject.IsCorrection = order.Correction_Order__c.toUpperCase().trim() == 'YES';
            }

            if(order.third_Party_Carrier_Account_Billing__c == null){
                newOrderObject.IsThirdPartyShipping = false;
            } else {
                newOrderObject.IsThirdPartyShipping = order.third_Party_Carrier_Account_Billing__c.toUpperCase().trim() == 'YES';
            }

            newOrderObject.PurchaseOrderNumber = order.PO_Number__c;

            // Set Billing Address
            OrderAddressInfo billToAddress = new OrderAddressInfo();


            if(order.rstk__sohdr_obilltoaddr__c == null) {
                billToAddress.Id = order.rstk__sohdr_billtoaddr__r.Id;

                billToAddress.Address1 = order.rstk__sohdr_billtoaddr__r.rstk__socaddr_address1__c;
                billToAddress.Address2 = order.rstk__sohdr_billtoaddr__r.rstk__socaddr_address2__c;
                billToAddress.Address3 = order.rstk__sohdr_billtoaddr__r.rstk__socaddr_address3__c;

                billToAddress.City = order.rstk__sohdr_billtoaddr__r.rstk__socaddr_city__c;
                billToAddress.Contact = order.rstk__sohdr_billtoaddr__r.rstk__socaddr_contact__r.rstk__socontact_contact__c;
                billToAddress.Country = order.rstk__sohdr_billtoaddr__r.rstk__socaddr_country__c;
                billToAddress.CountryIso = order.rstk__sohdr_billtoaddr__r.rstk__socaddr_isocountry__c;
                billToAddress.CustName = order.rstk__sohdr_billtoaddr__r.rstk__socaddr_name__c;
                billToAddress.CustNo = order.rstk__sohdr_billtoaddr__r.rstk__socaddr_custno__r.rstk__socust_custno__c;
                billToAddress.Email = order.rstk__sohdr_billtoaddr__r.rstk__socaddr_email__c;
                billToAddress.Phone = order.rstk__sohdr_billtoaddr__r.rstk__socaddr_phone__c;
                billToAddress.Zip = order.rstk__sohdr_billtoaddr__r.rstk__socaddr_zip__c;
                billToAddress.State = order.rstk__sohdr_billtoaddr__r.rstk__socaddr_state__c;
                billToAddress.CompanyName = order.rstk__sohdr_billtoaddr__r.rstk__socaddr_custno__r.rstk__socust_sf_account__r.CompanyName__c;
            }
            else {
                billToAddress.Id = order.rstk__sohdr_obilltoaddr__r.Id;


                billToAddress.Address1 = order.rstk__sohdr_obilltoaddr__r.rstk__soaddr_address1__c;
                billToAddress.Address2 = order.rstk__sohdr_obilltoaddr__r.rstk__soaddr_address2__c;
                billToAddress.Address3 = order.rstk__sohdr_obilltoaddr__r.rstk__soaddr_address3__c;

                billToAddress.City = order.rstk__sohdr_obilltoaddr__r.rstk__soaddr_city__c;
                billToAddress.Contact = order.rstk__sohdr_obilltoaddr__r.rstk__soaddr_ovrsocust__r.rstk__socust_contact__c;
                billToAddress.Country = order.rstk__sohdr_obilltoaddr__r.rstk__soaddr_country__c;
                billToAddress.CountryIso = order.rstk__sohdr_obilltoaddr__r.rstk__soaddr_isocountry__c;
                billToAddress.CustName = order.rstk__sohdr_obilltoaddr__r.rstk__soaddr_name__c;
                billToAddress.CustNo = order.rstk__sohdr_obilltoaddr__r.rstk__soaddr_ovrsocust__r.rstk__socust_custno__c;
                billToAddress.Email = order.rstk__sohdr_obilltoaddr__r.rstk__soaddr_email__c;
                billToAddress.Phone = order.rstk__sohdr_obilltoaddr__r.rstk__soaddr_phone__c;
                billToAddress.Zip = order.rstk__sohdr_obilltoaddr__r.rstk__soaddr_zip__c;
                billToAddress.State = order.rstk__sohdr_obilltoaddr__r.rstk__soaddr_state__c;
                billToAddress.CompanyName = order.rstk__sohdr_obilltoaddr__r.rstk__soaddr_ovrsocust__r.rstk__socust_sf_account__r.CompanyName__c;
            }
            newOrderObject.BillTo = billToAddress;

            // Set Ship To Address
            OrderAddressInfo shipToAddress = new OrderAddressInfo();

            if(orderDeliveryGroupSummaryMap.containsKey(order.rstk__sohdr_order__c)){
                orderDeliveryGroupSummary orderDeliveryGroupSummary = orderDeliveryGroupSummaryMap.get(order.rstk__sohdr_order__c);
                shipToAddress.CompanyName = orderDeliveryGroupSummary.Company_Name__c;
            } else {
                shipToAddress.CompanyName = '';
            }



            if(order.rstk__sohdr_oshiptoaddr__c == null) {
                shipToAddress.Id = order.rstk__sohdr_shiptoaddr__r.Id;

                shipToAddress.Address1 = order.rstk__sohdr_shiptoaddr__r.rstk__socaddr_address1__c;
                shipToAddress.Address2 = order.rstk__sohdr_shiptoaddr__r.rstk__socaddr_address2__c;
                shipToAddress.Address3 = order.rstk__sohdr_shiptoaddr__r.rstk__socaddr_address3__c;


                shipToAddress.City = order.rstk__sohdr_shiptoaddr__r.rstk__socaddr_city__c;
                shipToAddress.Contact = order.rstk__sohdr_shiptoaddr__r.rstk__socaddr_contact__r.rstk__socontact_contact__c;
                shipToAddress.Country = order.rstk__sohdr_shiptoaddr__r.rstk__socaddr_country__c;
                shipToAddress.CountryIso = order.rstk__sohdr_shiptoaddr__r.rstk__socaddr_isocountry__c;
                shipToAddress.CustName = order.rstk__sohdr_shiptoaddr__r.rstk__socaddr_name__c;
                shipToAddress.CustNo = order.rstk__sohdr_shiptoaddr__r.rstk__socaddr_custno__r.rstk__socust_custno__c;
                shipToAddress.Email = order.rstk__sohdr_shiptoaddr__r.rstk__socaddr_email__c;
                shipToAddress.Phone = order.rstk__sohdr_shiptoaddr__r.rstk__socaddr_phone__c;
                shipToAddress.Zip = order.rstk__sohdr_shiptoaddr__r.rstk__socaddr_zip__c;
                shipToAddress.State = order.rstk__sohdr_shiptoaddr__r.rstk__socaddr_state__c;
            }
            else {
                shipToAddress.Id = order.rstk__sohdr_oshiptoaddr__r.Id;


                shipToAddress.Address1 = order.rstk__sohdr_oshiptoaddr__r.rstk__soaddr_address1__c;
                shipToAddress.Address2 = order.rstk__sohdr_oshiptoaddr__r.rstk__soaddr_address2__c;
                shipToAddress.Address3 = order.rstk__sohdr_oshiptoaddr__r.rstk__soaddr_address3__c;



                shipToAddress.City = order.rstk__sohdr_oshiptoaddr__r.rstk__soaddr_city__c;
                shipToAddress.Contact = order.rstk__sohdr_oshiptoaddr__r.rstk__soaddr_ovrsocust__r.rstk__socust_contact__c;
                shipToAddress.Country = order.rstk__sohdr_oshiptoaddr__r.rstk__soaddr_country__c;
                shipToAddress.CountryIso = order.rstk__sohdr_oshiptoaddr__r.rstk__soaddr_isocountry__c;
                shipToAddress.CustName = order.rstk__sohdr_oshiptoaddr__r.rstk__soaddr_name__c;
                shipToAddress.CustNo = order.rstk__sohdr_oshiptoaddr__r.rstk__soaddr_ovrsocust__r.rstk__socust_custno__c;
                shipToAddress.Email = order.rstk__sohdr_oshiptoaddr__r.rstk__soaddr_email__c;
                shipToAddress.Phone = order.rstk__sohdr_oshiptoaddr__r.rstk__soaddr_phone__c;
                shipToAddress.Zip = order.rstk__sohdr_oshiptoaddr__r.rstk__soaddr_zip__c;
                shipToAddress.State = order.rstk__sohdr_oshiptoaddr__r.rstk__soaddr_state__c;
            }
            newOrderObject.ShipTo = shipToAddress;

            // Set Carrier
            CarrierInfo carrier = new CarrierInfo();
            carrier.Id =order.rstk__sohdr_sohdrext__r.rstk__sohdrextn_carrier__r.Id;
            carrier.Name = order.rstk__sohdr_sohdrext__r.rstk__sohdrextn_carrier__r.rstk__sycarrier_id__c;
            carrier.Code = order.rstk__sohdr_sohdrext__r.rstk__sohdrextn_carrier__r.rstk__sycarrier_id__c;
            newOrderObject.Carrier = carrier;

            // Set Ship Via
            ShipInfo shipVia = new ShipInfo();
            shipVia.Id =  order.rstk__sohdr_sohdrext__r.rstk__sohdrextn_shipvia__r.Id;
            shipVia.Name = order.rstk__sohdr_sohdrext__r.rstk__sohdrextn_shipvia__r.rstk__syshipviatype_id__c;
            shipVia.Code = order.rstk__sohdr_sohdrext__r.rstk__sohdrextn_shipvia__r.rstk__syshipviatype_id__c;
            newOrderObject.ShipVia = shipVia;

            // Additional Information
            if(order.fmgsohdrext__r.size()>0){
                newOrderObject.IsFirstTimeBuyer = order.fmgsohdrext__r[0].IsFirstOrder__c;
                newOrderObject.Time_of_Pick = order.fmgsohdrext__r[0].Time_of_Pick__c;
                newOrderObject.Time_of_Pack = order.fmgsohdrext__r[0].Time_of_Pick__c;
                newOrderObject.Time_of_Ship = order.fmgsohdrext__r[0].Time_of_Ship__c;
                newOrderObject.IsLightweight = order.fmgsohdrext__r[0].IsLightweight__c;
                newOrderObject.IsForeign = order.fmgsohdrext__r[0].IsForeign__c;
                newOrderObject.BatchId = Integer.valueOf(order.fmgsohdrext__r[0].batchId__c);
            }
            newOrderObject.IsEmployee = order.rstk__sohdr_custno__r.rstk__socust_sf_account__r.Employee__c == true;
            newOrderObject.IsFacility = order.rstk__sohdr_custno__r.rstk__socust_sf_account__r.Facility__c == true;
            newOrderObject.IsPlatinum = order.rstk__sohdr_custno__r.rstk__socust_sf_account__r.Type == 'Platinum';

            // set creation date to best date available
            if(test.isRunningTest() && order.CreatedDate == null){
                newOrderObject.CreationDate = order.rstk__sohdr_orderdate__c;
            } else if(order.rstk__sohdr_orderdate__c < order.CreatedDate.date()){
                newOrderObject.CreationDate = order.rstk__sohdr_orderdate__c;
            } else {
                newOrderObject.CreationDate = order.CreatedDate;
            }

            for(rstk__soline__c line: order.rstk__solines__r) {
                OrderLineInfo orderLine = new OrderLineInfo();

                orderLine.Id = line.Id;
                orderLine.LineNumber = Integer.valueOf(line.rstk__soline_line__c);

                // Product Information
                orderLine.Product = new ProductInfo();
                orderLine.Product.Id = line.rstk__soline_prod__r.Id;
                orderLine.Product.Description = line.rstk__soline_prod__r.rstk__soprod_descr__c;

                // Item Master Information
                orderLine.ItemMaster = new ItemMasterInfo();
                orderLine.ItemMaster.Id = line.rstk__soline_icitem__r.Id;
                orderLine.ItemMaster.Description = line.rstk__soline_icitem__r.rstk__icitem_descr__c;
                orderLine.ItemMaster.Sku = line.rstk__soline_icitem__r.rstk__icitem_item__r.rstk__peitem_item__c;
                orderLine.ItemMaster.LocationNumber = line.rstk__soline_icitem__r.rstk__icitem_wmslocnum__c;
                orderLine.ItemMaster.LocationId = line.rstk__soline_icitem__r.rstk__icitem_wmslocid__r.rstk__sylocid_locid__c;

                orderLine.Price = line.rstk__soline_price__c;
                orderLine.Qty = line.rstk__soline_qtyorder__c;
                orderLine.OriginalQty = line.rstk__soline_origqtyord__c;

                orderLine.ProductGroup = line.rstk__soline_prod__r.rstk__soprod_comcod__r.rstk__externalid__c;
                orderLine.Weight = line.rstk__soline_prod__r.rstk__soprod_weight__c;


                newOrderObject.Lines.add(orderLine);
            }
            returnBatchData.Orders.add(newOrderObject);
        }


        return returnBatchData;
    }

    // All Custom Objects for the given class
    public class OrderInfo {
        public Id Id { get; set; }
        public CarrierInfo Carrier { get; set; }
        public ShipInfo ShipVia { get; set; }
        public OrderAddressInfo BillTo { get; set; }
        public Boolean IsFirstTimeBuyer { get; set; }
        public List<OrderLineInfo> Lines { get; set; }
        public String OrderNumber { get; set; }
        public OrderAddressInfo ShipTo { get; set; }
        public Datetime CreationDate { get; set; }
        public Datetime Time_of_Pick { get; set; }
        public Datetime Time_of_Pack { get; set; }
        public Datetime Time_of_Ship { get; set; }
        public Boolean IsLightweight { get; set; }
        public Boolean IsEmployee { get; set; }
        public Boolean IsFacility { get; set; }
        public Boolean IsForeign { get; set; }
        public Boolean IsThirdPartyShipping { get; set; }
        public Boolean IsPlatinum { get; set; }
        public Integer BatchId { get; set; }
        public String CustomerName { get; set; }
        public String CustomerNumber { get; set; }
        public Id CustomerId { get; set; }
        public String Comments { get; set; }
        public Boolean IsSignatureRequired { get; set; }
        public Boolean IsNoCatalog { get; set; }
        public String ThirdPartyUps { get; set; }
        public String ThirdPartyFedEx { get; set; }
        public Boolean IsCorrection { get; set; }
        public String PurchaseOrderNumber { get; set; }

    }

    public class CarrierInfo{
        public Id Id{get;set;}
        public String Name{get;set;}
        public String Code{get;set;}
    }

    public class ShipInfo{
        public Id Id{get;set;}
        public String Name{get;set;}
        public String Code{get;set;}
    }

    public class ProductInfo{
        public Id Id{get;set;}
        public String Description{get;set;}
    }

    public class ItemMasterInfo{
        public Id Id{get;set;}
        public String Description{get;set;}
        public String Sku{get;set;}
        public String LocationId{get;set;}
        public String LocationNumber{get;set;}
    }
    public class BatchData{
        public Integer BatchId{get;set;}
        public List<OrderInfo> Orders{get;set;}
    }

    public class OrderAddressInfo{
        public Id Id{get;set;}
        public String State{get;set;}
        public String Address1{get;set;}
        public String Address2{get;set;}
        public String Address3{get;set;}
        public String City{get;set;}
        public String Contact{get;set;}
        public String Country{get;set;}
        public String CountryIso{get;set;}
        public string CompanyName{get;set;}
        public String CustName{get;set;}
        public String CustNo{get;set;}
        public String Email{get;set;}
        public String Phone{get;set;}
        public String Zip{get;set;}
    }

    public class OrderLineInfo{
        public Id Id{get;set;}
        public Integer LineNumber{get;set;}
        public ProductInfo Product{get;set;}
        public ItemMasterInfo ItemMaster{get;set;}
        public Decimal Price{get;set;}
        public Decimal Qty{get;set;}
        public Decimal OriginalQty{get;set;}
        public Decimal Weight{get;set;}
        public String ProductGroup{get;set;}

    }

    public class ProcessOrderEvent{
        public Datetime EventTime{get;set;}
        public String OrderEvent{get;set;}
        public Id SalesforceOrderId{get;set;}
        public String Username{get;set;}
        public ProcessOrderEvent(){}
        public ProcessOrderEvent(Datetime eventTime,String orderEvent,Id orderId,String username){
            this.EventTime = eventTime;
            this.OrderEvent = orderEvent;
            this.SalesforceOrderId = orderId;
            this.Username = username;
        }
    }


    public class ShippingContainerItem{
        public Decimal Quantity { get; set; }
        public Id SalesforceOrderLineId { get; set; }
    }

    public class ShippingContainer{
        public List<ShippingContainerItem> Products{get;set;}
        public Id SalesforceOrderId{get;set;}
        public OrderAddressInfo ShipToAddress{get;set;}
        public String ContainerType{get;set;}
        public String CarrierCode{get;set;}
        public String ShipMethod{get;set;}
        public String TrackingNumber{get;set;}
    }

    @TestVisible
    private class RawContainerTypes{
        public Id Id{get;set;}
        public String ContainerType{get;set;}
        public Id Division{get;set;}
        public RawContainerTypes(Id ContainerTypeId,String TypeName,Id Division ){
            this.Id = ContainerTypeId;
            this.ContainerType = TypeName;
            this.Division = Division;
        }


        public RawContainerTypes(rstk__socontype__c data ){
            this.Id = data.Id;
            this.ContainerType = data.rstk__socontype_type__c;
            this.Division = data.rstk__socontype_div__c;
        }
    }

    @TestVisible
    private class RawShipperHeader{
        public Integer ContainerCount{get;set;}
        public Id OrderNumber{get;set;}
        public String Name{get;set;}
        public String Address1{get;set;}
        public String Address2{get;set;}
        public String Address3{get;set;}
        public String City{get;set;}
        public String Country{get;set;}
        public Id Division{get;set;}
        public String Email{get;set;}
        public String Fax{get;set;}
        public Id FOB{get;set;}
        public Id FreightTerm{get;set;}
        public String ISOCountry{get;set;}
        public String ShipToName{get;set;}
        public String Phone{get;set;}
        public Id Id{get;set;}
        public Id ShipMethod{get;set;}
        public Id Customer{get;set;}
        public String State{get;set;}
        public Id Carrier{get;set;}
        public String ZipCode{get;set;}
        public RawShipperHeader(){}
        public RawShipperHeader(rstk__soship__c data){

            Integer lastNumber = 0;

            if(data.rstk__soship_socontainer__r != null){
                for(rstk__socontainer__c container: data.rstk__soship_socontainer__r){
                    String[] splitValue = container.Name.split('-');
                    if(splitValue.size() == 3 && splitValue[splitValue.size()-1].trim().isNumeric()){
                        Integer lastNumberForContainer = Integer.valueOf(splitValue[splitValue.size()-1].trim());
                        if(lastNumber < lastNumberForContainer){
                            lastNumber = lastNumberForContainer;
                        }
                    }
                }
            }
            this.ContainerCount = lastNumber+1;
            this.OrderNumber = data.rstk__soship_order__c;
            this.Name = data.Name;
            this.Address1 = data.rstk__soship_address1__c;
            this.Address2 = data.rstk__soship_address2__c;
            this.Address3 = data.rstk__soship_address3__c;
            this.City = data.rstk__soship_city__c;
            this.Country = data.rstk__soship_country__c;
            this.Division = data.rstk__soship_order__r.rstk__sohdr_div__c;
            this.Email = data.rstk__soship_email__c;
            this.Fax = data.rstk__soship_fax__c;
            this.FOB = data.rstk__soship_fob__c;
            this.FreightTerm = data.rstk__soship_fterms__c;
            this.ISOCountry = data.rstk__soship_isocountry__c;
            this.ShipToName = data.rstk__soship_name__c;
            this.Phone = data.rstk__soship_phone__c;
            this.Id = data.Id;
            this.ShipMethod = data.rstk__soship_shipvia__c;
            this.Customer = data.rstk__soship_custno__c;
            this.State = data.rstk__soship_state__c;
            this.Carrier = data.rstk__soship_carrier__c;
            this.ZipCode = data.rstk__soship_zip__c;
        }
    }

    @TestVisible
    private class RawSalesOrderLineInfo{
        public Id ShipperLine{get;set;}
        public Id ShipperDemand{get;set;}
        public Id SalesOrderLine{get;set;}
        public String ShipperLineName{get;set;}
        public Id ProductId{get;set;}
        public String ProductName{get;set;}

    }



    public List<rstk__soshipline__c> getShippingDemandData(Set<Id> shipperIds){
        List<rstk__soshipline__c> records = [
                SELECT Id,
                (
                        SELECT Id
                        FROM rstk__soshipdmds__r
                ),
                        rstk__soshipline_prod__r.Id, rstk__soshipline_prod__r.rstk__soprod_prod__c,
                        rstk__soshipline_shipper__r.Id, Name, rstk__soshipline_line__r.Id
                FROM rstk__soshipline__c
                WHERE rstk__soshipline_shipper__r.Id IN :shipperIds
        ];

        if(ordersServiceDataAccessOverride != null && Test.isRunningTest()){
            records = ordersServiceDataAccessOverride.getShippingDemandData(shipperIds);
        }

        return records;
    }
    @TestVisible
    private Map<Id,RawSalesOrderLineInfo> getShippingDemand(Set<Id> shipperIds){


        Map<Id,RawSalesOrderLineInfo> returnCollection = new Map<Id, FMGRSAPI_Orders_Service.RawSalesOrderLineInfo>();
        List<rstk__soshipline__c> records = getShippingDemandData(shipperIds);
        System.debug(LoggingLevel.FINEST,'******************** getShippingDemand - shipperIds *************************');
        System.debug(LoggingLevel.FINEST,JSON.serializePretty(shipperIds));

        for(rstk__soshipline__c soShipLine :records){

            System.debug(LoggingLevel.FINEST,'******************** getShippingDemand - soShipLine *************************');
            System.debug(LoggingLevel.FINEST,JSON.serializePretty(soShipLine));

            if(soShipLine.rstk__soshipdmds__r.size()>0) {
                RawSalesOrderLineInfo newLineInfo = new RawSalesOrderLineInfo();
                newLineInfo.ShipperLine = soShipLine.Id;
                newLineInfo.ShipperDemand = soShipLine.rstk__soshipdmds__r[0].Id;
                newLineInfo.SalesOrderLine = soShipLine.rstk__soshipline_line__r.Id;
                newLineInfo.ProductId = soShipLine.rstk__soshipline_prod__r.Id;
                newLineInfo.ProductName = soShipLine.rstk__soshipline_prod__r.rstk__soprod_prod__c;
                newLineInfo.ShipperLineName = soShipLine.Name;
                returnCollection.put(newLineInfo.SalesOrderLine,newLineInfo);
            }


        }

        return returnCollection;
    }



    public List<rstk__soship__c> getShippingHeadersData(Set<Id> orderIds){
        List<rstk__soship__c> records = [SELECT rstk__soship_order__c,Name,
        (
                SELECT Id,Name
                FROM rstk__soship_socontainer__r
        ),
                rstk__soship_address1__c, rstk__soship_address2__c, rstk__soship_address3__c,
                rstk__soship_city__c, rstk__soship_country__c,
                rstk__soship_order__r.rstk__sohdr_div__c, rstk__soship_email__c, rstk__soship_fax__c,
                rstk__soship_fob__c, rstk__soship_fterms__c, rstk__soship_isocountry__c,
                rstk__soship_name__c, rstk__soship_phone__c, Id, rstk__soship_shipvia__c,
                rstk__soship_custno__c, rstk__soship_state__c, rstk__soship_carrier__c,
                rstk__soship_zip__c
        FROM rstk__soship__c
        WHERE rstk__soship_order__c IN :orderIds];

        if(ordersServiceDataAccessOverride != null && Test.isRunningTest()){
            records = ordersServiceDataAccessOverride.getShippingHeadersData(orderIds);
        }

        return records;
    }

    @TestVisible
    private Map<Id,RawShipperHeader> getShippingHeaders(Set<Id> orderIds){



        Map<Id,RawShipperHeader> returnCollection = new Map<Id, FMGRSAPI_Orders_Service.RawShipperHeader>();
        List<rstk__soship__c> records =getShippingHeadersData(orderIds);
        for(rstk__soship__c shipperHeader : records){
            returnCollection.put(shipperHeader.rstk__soship_order__c,new RawShipperHeader(shipperHeader));
        }
        return returnCollection;
    }

    @TestVisible
    private Map<String,RawContainerTypes> MockData_GetContainerTypes{get;set;}

    @TestVisible
    private Map<String,RawContainerTypes> getContainerTypes(){

        if(Test.isRunningTest() && MockData_GetContainerTypes != null){
            return MockData_GetContainerTypes;
        }
        Map<String,RawContainerTypes> containerTypes = new Map<String, RawContainerTypes>();

        for(rstk__socontype__c containerType:[SELECT Id, rstk__socontype_type__c,rstk__socontype_div__c FROM rstk__socontype__c]){
            containerTypes.put(containerType.rstk__socontype_type__c,new RawContainerTypes(containerType));

        }
        return containerTypes;
    }

    private class ShipMethodLookupInfo{
        public Id CarrierCode{get;set;}
        public Id ShipMethod{get;set;}
    }

    private Map<String,Map<string,ShipMethodLookupInfo>> ShipMethodLookupCache = null;
    @TestVisible
    private ShipMethodLookupInfo MockData_lookupShipMethod = null;

    @TestVisible
    private ShipMethodLookupInfo lookupShipMethod(String carrierCode, String shipMethodCode){
        if(Test.isRunningTest() && MockData_lookupShipMethod != null){
            return MockData_lookupShipMethod;
        }

        if(ShipMethodLookupCache == null){
            Map<String,Map<string,ShipMethodLookupInfo>> newShipMethodLookupCache = new Map<String, Map<String, ShipMethodLookupInfo>>();

            for(rstk__socarriervia__c record : [SELECT  rstk__socarriervia_carrier__c,rstk__socarriervia_carrier__r.rstk__sycarrier_id__c,
                    rstk__socarriervia_shipvia__c,rstk__socarriervia_shipvia__r.rstk__syshipviatype_id__c
            FROM rstk__socarriervia__c]){
                if(!newShipMethodLookupCache.containsKey(record.rstk__socarriervia_carrier__r.rstk__sycarrier_id__c)){
                    newShipMethodLookupCache.put(record.rstk__socarriervia_carrier__r.rstk__sycarrier_id__c,
                            new Map<String, ShipMethodLookupInfo>());
                }

                if(!newShipMethodLookupCache.get(record.rstk__socarriervia_carrier__r.rstk__sycarrier_id__c)
                        .containsKey(record.rstk__socarriervia_shipvia__r.rstk__syshipviatype_id__c)){

                    ShipMethodLookupInfo newMethod = new ShipMethodLookupInfo();
                    newMethod.CarrierCode = record.rstk__socarriervia_carrier__c;
                    newMethod.ShipMethod = record.rstk__socarriervia_shipvia__c;

                    newShipMethodLookupCache.get(record.rstk__socarriervia_carrier__r.rstk__sycarrier_id__c)
                            .put(record.rstk__socarriervia_shipvia__r.rstk__syshipviatype_id__c,newMethod);
                }

            }

            ShipMethodLookupCache = newShipMethodLookupCache;
        }



        ShipMethodLookupInfo returnInfo = new ShipMethodLookupInfo();


       if(ShipMethodLookupCache.containsKey(carrierCode)){
           if(ShipMethodLookupCache.get(carrierCode).containsKey(shipMethodCode)){
               ShipMethodLookupInfo info = ShipMethodLookupCache.get(carrierCode).get(shipMethodCode);
               returnInfo.ShipMethod = info.ShipMethod;
               returnInfo.CarrierCode = info.CarrierCode;
           }
       }

        return returnInfo;
    }

    public class NoShippingHeadersException extends Exception{

        public List<Id> invalidOrders = new List<Id>();
    }

    /**
     * @description Checks to see if orders have shipping headers
     * @param orderIds Orders to check
     * @exception NoShippingHeadersException on missing header will throw exception with the badIds
     **/
    public void checkOrdersForShipperHeaders(Set<Id> orderIds){
        System.debug('Executing Check');
        NoShippingHeadersException noShippingHeadersException = new NoShippingHeadersException();
        for(rstk__sohdr__c orderhdr: [SELECT Id,
                                        (
                                            SELECT Id, rstk__soship_closed__c
                                            FROM rstk__soships__r
                                        )
                                FROM rstk__sohdr__c
                                WHERE Id in :orderIds]){
            if(orderhdr.rstk__soships__r.isEmpty()){
                noShippingHeadersException.invalidOrders.add(orderhdr.Id);
            }

        }

        System.debug(noShippingHeadersException);
        if(!noShippingHeadersException.invalidOrders.isEmpty()){
            throw noShippingHeadersException;
        }
    }


    public Map<String,Object> generateContainers(List<ShippingContainer> packages){
        Map<String,Object> extendedInfo = new Map<String, Object>();

        Set<Id> orderIds = new Set<Id>();
        for(ShippingContainer packageData: packages){
            orderIds.add(packageData.SalesforceOrderId);
        }

        // Validate orders before trying to assign containers to them
        checkOrdersForShipperHeaders(orderIds);

        System.debug(LoggingLevel.FINER,'******************** shipperHeaders *************************');
        Map<Id,RawShipperHeader> shipperHeaders = getShippingHeaders(orderIds);
        System.debug(LoggingLevel.FINER,JSON.serializePretty(shipperHeaders));


        System.debug(LoggingLevel.FINER,'******************** shipperHeaderIds *************************');
        Set<Id>shipperHeaderIds = new Set<Id>();
        for(RawShipperHeader shipperHeader: shipperHeaders.values()){
            shipperHeaderIds.add(shipperHeader.Id);
        }

        System.debug(LoggingLevel.FINER,JSON.serializePretty(shipperHeaderIds));


        System.debug(LoggingLevel.FINER,'******************** salesOrderLineShippingDemand *************************');
        Map<Id, RawSalesOrderLineInfo> salesOrderLineShippingDemand = getShippingDemand(shipperHeaderIds);
        System.debug(LoggingLevel.FINER,JSON.serializePretty(salesOrderLineShippingDemand));


        System.debug(LoggingLevel.FINER,'************************ GetContainerTypes ****************************');
        Map<String,RawContainerTypes> containerTypes = getContainerTypes();
        System.debug(LoggingLevel.FINER,JSON.serializePretty(containerTypes));



        GenerateContainers_newContainers = new Map<ShippingContainer,rstk__socontainer__c>();
        for(ShippingContainer packagedData :packages){

            RawShipperHeader soshipInfo = shipperHeaders.get(packagedData.SalesforceOrderId);

            String Name = soshipInfo.Name + '-' + String.valueOf(soshipInfo.ContainerCount).leftPad(2,'0');
            soshipInfo.ContainerCount++;


            rstk__socontainer__c newContainer = new rstk__socontainer__c();

            if(packagedData.ShipToAddress != null){
                newContainer.rstk__socontainer_address1__c = packagedData.ShipToAddress.Address1;
                newContainer.rstk__socontainer_address2__c = packagedData.ShipToAddress.Address2;
                newContainer.rstk__socontainer_address3__c = packagedData.ShipToAddress.Address3;
                newContainer.rstk__socontainer_city__c = packagedData.ShipToAddress.City;
                newContainer.rstk__socontainer_isocountry__c = packagedData.ShipToAddress.CountryIso;
                newContainer.rstk__socontainer_name__c = packagedData.ShipToAddress.CustName;
                newContainer.rstk__socontainer_country__c = packagedData.ShipToAddress.Country;
                newContainer.rstk__socontainer_email__c = packagedData.ShipToAddress.Email;
                newContainer.rstk__socontainer_phone__c = packagedData.ShipToAddress.Phone;
                newContainer.rstk__socontainer_state__c = packagedData.ShipToAddress.State;
                newContainer.rstk__socontainer_zip__c = packagedData.ShipToAddress.Zip;
            } else {
                newContainer.rstk__socontainer_address1__c = soshipInfo.Address1;
                newContainer.rstk__socontainer_address2__c = soshipInfo.Address2;
                newContainer.rstk__socontainer_address3__c = soshipInfo.Address3;
                newContainer.rstk__socontainer_city__c = soshipInfo.City;
                newContainer.rstk__socontainer_isocountry__c = soshipInfo.ISOCountry;
                newContainer.rstk__socontainer_name__c = soshipInfo.ShipToName;
                newContainer.rstk__socontainer_country__c = soshipInfo.Country;
                newContainer.rstk__socontainer_email__c = soshipInfo.Email;
                newContainer.rstk__socontainer_phone__c = soshipInfo.Phone;
                newContainer.rstk__socontainer_state__c = soshipInfo.State;
                newContainer.rstk__socontainer_zip__c = soshipInfo.ZipCode;
            }

            newContainer.rstk__socontainer_div__c = soshipInfo.Division;
            newContainer.rstk__socontainer_fax__c = soshipInfo.Fax;
            newContainer.rstk__socontainer_fob__c = soshipInfo.FOB;
            newContainer.rstk__socontainer_fterms__c = soshipInfo.FreightTerm;
            newContainer.rstk__socontainer_grosswt__c = 0;
            newContainer.rstk__socontainer_netwt__c = 0;
            newContainer.rstk__socontainer_shipper__c = soshipInfo.Id;
            newContainer.rstk__socontainer_socust__c = soshipInfo.Customer;

            ShipMethodLookupInfo shipping = lookupShipMethod(packagedData.CarrierCode,packagedData.ShipMethod);
            if(shipping.ShipMethod != null && shipping.CarrierCode != null){
                newContainer.rstk__socontainer_shipvia__c = shipping.ShipMethod;
                newContainer.rstk__socontainer_sycarrier__c = shipping.CarrierCode;
            } else {
                newContainer.rstk__socontainer_shipvia__c = soshipInfo.ShipMethod;
                newContainer.rstk__socontainer_sycarrier__c = soshipInfo.Carrier;
            }


            if(packagedData.ContainerType!= null && containerTypes.containsKey(packagedData.ContainerType)){
                newContainer.rstk__socontainer_socontype__c = containerTypes.get(packagedData.ContainerType).Id;
            } else {
                newContainer.rstk__socontainer_socontype__c = containerTypes.values()[0].Id;
            }
            newContainer.rstk__socontainer_container__c = Name;
            newContainer.rstk__socontainer_tracking__c = packagedData.TrackingNumber;

            GenerateContainers_newContainers.put(packagedData,newContainer);

        }
        System.debug(LoggingLevel.FINER,'******************** newContainers *************************');
        System.debug(LoggingLevel.FINER,JSON.serializePretty(GenerateContainers_newContainers));
        if(!Test.isRunningTest()) {
            insert GenerateContainers_newContainers.values();
        }


        GenerateContainers_ItemList = new List<rstk__socontainel__c>();
        for(ShippingContainer container: GenerateContainers_newContainers.keySet()){
            if(container.Products != null && !container.Products.isEmpty()){
                for(ShippingContainerItem item: container.Products) {
                    if(salesOrderLineShippingDemand.containsKey(item.SalesforceOrderLineId)){
                        RawSalesOrderLineInfo salesOrderLineInfo = salesOrderLineShippingDemand.get(item.SalesforceOrderLineId);
                        rstk__socontainer__c containerInfo = GenerateContainers_newContainers.get(container);
                        rstk__socontainel__c newItemContainerDetail = new rstk__socontainel__c();

                        // Container Id
                        newItemContainerDetail.rstk__socontainel_socontainer__c = containerInfo.Id;
                        // Name
                        newItemContainerDetail.Name = containerInfo.rstk__socontainer_container__c+'-'+salesOrderLineInfo.ShipperLineName;

                        // Shipper Line [rstk__soshiplines__r.Id]
                        newItemContainerDetail.rstk__socontainel_soshipline__c= salesOrderLineInfo.ShipperLine;

                        // Product [rstk__soshiplines__r.rstk__soshipline_prod__r.Id]
                        newItemContainerDetail.rstk__socontainel_soprod__c=salesOrderLineInfo.ProductId;

                        // Product Component [rstk__soshiplines__r.rstk__soshipline_prod__r.rstk__soprod_prod__c]
                        newItemContainerDetail.rstk__socontainel_component__c=salesOrderLineInfo.ProductName;

                        // Qty
                        newItemContainerDetail.rstk__socontainel_qty__c = item.Quantity;

                        newItemContainerDetail.rstk__socontainel_soshipdmd__c = salesOrderLineInfo.ShipperDemand;
                        newItemContainerDetail.rstk__socontainel_tarewt__c = 0;

                        newItemContainerDetail.rstk__socontainel_netwt__c = 0;

                        GenerateContainers_ItemList.add(newItemContainerDetail);
                    }

                }
            }

        }
        System.debug(LoggingLevel.FINE,'******************** itemList *************************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(GenerateContainers_ItemList));
        if(!GenerateContainers_ItemList.isEmpty() && !Test.isRunningTest()){
            insert GenerateContainers_ItemList;
            update GenerateContainers_newContainers.values();
        }
        System.debug(LoggingLevel.FINE,'******************** itemList *************************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(GenerateContainers_ItemList));
        System.debug(LoggingLevel.FINER,'******************** newContainers *************************');
        System.debug(LoggingLevel.FINER,JSON.serializePretty(GenerateContainers_newContainers));

        return extendedInfo;
    }

    @TestVisible
    private List<rstk__socontainel__c> GenerateContainers_ItemList{get;set;}

    @TestVisible
    private Map<ShippingContainer,rstk__socontainer__c> GenerateContainers_newContainers{get;set;}


    public class ReduceLineQtyResults{
        public List<Id> Ids{get;set;}
        public Boolean ReRun{get;set;}
        public ReduceLineQtyResults(){
            Ids = new List<Id>();
            ReRun = false;
        }
    }

    @TestVisible
    private List<rstk__sydata__c> reduceLineQty_statsChange;

    @TestVisible
    private rstk__soapi__c reduceLineQty_qtyChange;

    @TestVisible
    private List<rstk__sydatat__c> reduceLineQty_transfer;

    public  ReduceLineQtyResults reduceLineQty(Id salesOrderLine, Decimal qty) {

        if(Test.isRunningTest()){
            reduceLineQty_statsChange = new List<rstk__sydata__c>();
            reduceLineQty_transfer = new List<rstk__sydatat__c>();
        }

        ReduceLineQtyResults results = new ReduceLineQtyResults();
        OrderItemReversal orderLineInfo = getOrderLine(salesOrderLine);

        if (qty >= orderLineInfo.Qty) {
            return results;
        }
        System.debug(LoggingLevel.FINE,'********************* orderLineInfo **********************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(orderLineInfo));

        ItemLocation ivcResearch = getIvcResearchLocation();

        orderLineInfo.NewQty = qty;
        System.debug(LoggingLevel.FINE,'********************* ivcResearch **********************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(ivcResearch));


        System.debug(LoggingLevel.FINE,'********************* orderLineInfo **********************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(orderLineInfo));
        if (orderLineInfo.ReversePack > 0) {
            rstk__sydata__c reversePack = new rstk__sydata__c();
            reversePack.rstk__sydata_txntype__c = 'Sales Order Pack Reversal';
            reversePack.rstk__sydata_soline__c = salesOrderLine;
            reversePack.rstk__sydata_txnqty__c = orderLineInfo.ReversePack;

            // Add to Collection for testing else do an insert
            if(Test.isRunningTest()){
                reduceLineQty_statsChange.add(reversePack);
            } else {
                insert reversePack;
            }



            System.debug(LoggingLevel.FINE,'********************* reversePack **********************');
            System.debug(LoggingLevel.FINE,JSON.serializePretty(reversePack));

            results.Ids.add(reversePack.Id);
            results.ReRun = true;
            return results;
        }

        Decimal toReverseIssue = orderLineInfo.ReversePack + orderLineInfo.ReverseIssue;
        System.debug(LoggingLevel.FINE,'********************* toReverseIssue **********************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(toReverseIssue));

        // To reverse all needed Issues
        if (toReverseIssue > 0) {
            for (ItemReversalLocation loc : orderLineInfo.Demands) {
                rstk__sydata__c reversePick = new rstk__sydata__c();
                reversePick.rstk__sydata_txntype__c = 'Sales Order Pick(Issue) Reversal';
                reversePick.rstk__sydata_soline__c = salesOrderLine;

                rstk__sydatat__c transfer = new rstk__sydatat__c();
                transfer.rstk__sydata_txnid__c = 'INVLOCLOC';
                transfer.rstk__sydata_txntype__c = 'Inventory Transfer';
                transfer.rstk__sydata_backgroundprocessing__c = true;

                if (toReverseIssue >= loc.qty) {
                    reversePick.rstk__sydata_txnqty__c = loc.qty;
                    transfer.rstk__sydata_txnqty__c = loc.qty;
                } else {
                    reversePick.rstk__sydata_txnqty__c = toReverseIssue;
                    transfer.rstk__sydata_txnqty__c = toReverseIssue;
                }
                toReverseIssue = toReverseIssue - transfer.rstk__sydata_txnqty__c;

                transfer.rstk__sydata_fromdiv__c = loc.DivisionId;
                transfer.rstk__sydata_fromsite__c = loc.SiteId;
                transfer.rstk__sydata_fromproj__c = loc.ProjectId;
                transfer.rstk__sydata_fromlocid__c = loc.LocId;
                transfer.rstk__sydata_fromlocnum__c = loc.LocNumber;

                transfer.rstk__sydata_todiv__c = ivcResearch.DivisionId;
                transfer.rstk__sydata_tosite__c = ivcResearch.SiteId;
                transfer.rstk__sydata_toproj__c = ivcResearch.ProjectId;
                transfer.rstk__sydata_tolocid__c = ivcResearch.LocId;
                transfer.rstk__sydata_tolocnum__c = ivcResearch.LocNumber;
                transfer.rstk__sydata_icitem__c = orderLineInfo.InventoryProductId;

                reversePick.rstk__sydata_sylocid__c = loc.LocId;
                reversePick.rstk__sydata_locnum__c = loc.LocNumber;


                System.debug(LoggingLevel.FINER,'********************* missingItemTransfer - reverse Issue **********************');
                System.debug(LoggingLevel.FINER,JSON.serializePretty(transfer));
                System.debug(LoggingLevel.FINER,'********************* reversePick **********************');
                System.debug(LoggingLevel.FINER,JSON.serializePretty(reversePick));


                // Add to Collection for testing else do an insert
                if(Test.isRunningTest()){
                    reduceLineQty_statsChange.add(reversePick);
                    reduceLineQty_transfer.add(transfer);
                } else {
                    insert reversePick;
                    insert transfer;
                }


                // Will use this to access for testing
                results.Ids.add(transfer.Id);
                results.Ids.add(reversePick.Id);
                results.ReRun = true;
                return results;
            }

        }

        List<ItemLocation> baseLocation = getItemBaseLocation(orderLineInfo.InventoryProductId);
        System.debug(LoggingLevel.FINE,'********************* Item Base Location **********************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(baseLocation));

        Decimal toRemove = orderLineInfo.UnknownLocationRemove;
        System.debug(LoggingLevel.FINE,'********************* toRemove **********************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(toRemove));

        List<rstk__sydatat__c> compactItemTransfers = new List<rstk__sydatat__c>();
        if (toRemove > 0) {
            for (ItemLocation loc : baseLocation) {
                if (loc.Qty > 0) {
                    rstk__sydatat__c transfer = new rstk__sydatat__c();
                    transfer.rstk__sydata_txnid__c = 'INVLOCLOC';
                    transfer.rstk__sydata_txntype__c = 'Inventory Transfer';
                    transfer.rstk__sydata_backgroundprocessing__c = true;

                    if (toRemove > loc.qty) {
                        transfer.rstk__sydata_txnqty__c = loc.qty;
                    } else {
                        transfer.rstk__sydata_txnqty__c = toRemove;
                    }

                    toRemove = toRemove - transfer.rstk__sydata_txnqty__c;

                    transfer.rstk__sydata_fromdiv__c = loc.DivisionId;
                    transfer.rstk__sydata_fromsite__c = loc.SiteId;
                    transfer.rstk__sydata_fromproj__c = loc.ProjectId;
                    transfer.rstk__sydata_fromlocid__c = loc.LocId;
                    transfer.rstk__sydata_fromlocnum__c = loc.LocNumber;

                    transfer.rstk__sydata_todiv__c = ivcResearch.DivisionId;
                    transfer.rstk__sydata_tosite__c = ivcResearch.SiteId;
                    transfer.rstk__sydata_toproj__c = ivcResearch.ProjectId;
                    transfer.rstk__sydata_tolocid__c = ivcResearch.LocId;
                    transfer.rstk__sydata_tolocnum__c = ivcResearch.LocNumber;
                    transfer.rstk__sydata_icitem__c = orderLineInfo.InventoryProductId;

                    compactItemTransfers.add(transfer);
                    System.debug(LoggingLevel.FINER,'********************* missingItemTransfer - UnknownLocationRemove **********************');
                    System.debug(LoggingLevel.FINER,JSON.serializePretty(transfer));
                }
            }
        }




        // Add to Collection for testing else do an insert
        if(Test.isRunningTest()){
            for(rstk__sydatat__c transfer: compactItemTransfers){
                reduceLineQty_transfer.add(transfer);
            }
        } else {
            insert compactItemTransfers;
        }


        System.debug(LoggingLevel.FINE,'********************* ReduceLineQty_CompactItemTransfers **********************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(compactItemTransfers));



        for (rstk__sydatat__c item : compactItemTransfers) {
            results.Ids.add(item.Id);
        }

        rstk__soapi__c reduceLine = new rstk__soapi__c();
        reduceLine.rstk__soapi_mode__c = 'Change Line';
        reduceLine.rstk__soapi_soline__c = salesOrderLine;
        reduceLine.rstk__soapi_qtyorder__c = qty;
        reduceLine.rstk__soapi_async__c = true;

        // Add to Collection for testing else do an insert
        if(Test.isRunningTest()){
            reduceLineQty_qtyChange = reduceLine;
        } else {
            insert reduceLine;
        }


        System.debug(LoggingLevel.FINE,'********************* reduceLine **********************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(reduceLine));
        results.Ids.add(reduceLine.Id);
        System.debug(LoggingLevel.FINE,'********************* processIds **********************');
        System.debug(LoggingLevel.FINE,JSON.serializePretty(results.Ids));


        return results;
    }

    @TestVisible
    private OrderItemReversal ReduceLineQty_getOrderLine;
    @TestVisible
    private OrderItemReversal getOrderLine(Id id) {
        if(ReduceLineQty_getOrderLine != null && Test.isRunningTest()){
            return ReduceLineQty_getOrderLine;
        }
        rstk__soorddmd__c orderLineInfo = [
                SELECT Id, rstk__soorddmd_soline__c,
                        rstk__soorddmd_soline__r.Name, (
                        SELECT Id, rstk__soorddmdcst_locnum__c, rstk__soorddmdcst_locid__c,
                                rstk__soorddmdcst_qtyiss__c, rstk__soorddmdcst_locid__r.rstk__sylocid_site__c,
                                rstk__soorddmdcst_locid__r.rstk__sylocid_div__c,
                                rstk__soorddmdcst_locid__r.rstk__sylocid_div__r.rstk__sydiv_dflthomeproj__c
                        FROM rstk__soorddmdcsts__r
                ),
                        rstk__soorddmd_soline__r.rstk__soline_sohdr__c, rstk__soorddmd_soline__r.rstk__soline_qtyorder__c,
                        rstk__soorddmd_soline__r.rstk__soline_qtyissue__c, rstk__soorddmd_soline__r.rstk__soline_qtypackage__c,
                        rstk__soorddmd_soline__r.rstk__soline_avtoallocpick__c, rstk__soorddmd_compicitem__c
                FROM rstk__soorddmd__c
                WHERE rstk__soorddmd_soline__c = :id
                LIMIT 1
        ];

        if (orderLineInfo != null) {
            OrderItemReversal record = new OrderItemReversal();
            record.Qty = orderLineInfo.rstk__soorddmd_soline__r.rstk__soline_qtyorder__c;
            record.FirmedAllocated = orderLineInfo.rstk__soorddmd_soline__r.rstk__soline_avtoallocpick__c;
            record.Issued = orderLineInfo.rstk__soorddmd_soline__r.rstk__soline_qtyissue__c;
            record.Packed = orderLineInfo.rstk__soorddmd_soline__r.rstk__soline_qtypackage__c;
            record.InventoryProductId = orderLineInfo.rstk__soorddmd_compicitem__c;
            record.Demands = new List<ItemReversalLocation>();

            if (orderLineInfo.rstk__soorddmdcsts__r != null) {
                for (rstk__soorddmdcst__c demand : orderLineInfo.rstk__soorddmdcsts__r) {
                    ItemReversalLocation location = new ItemReversalLocation();
                    location.DemandId = demand.Id;
                    location.qty = demand.rstk__soorddmdcst_qtyiss__c;
                    location.LocId = demand.rstk__soorddmdcst_locid__c;
                    location.LocNumber = demand.rstk__soorddmdcst_locnum__c;
                    location.SiteId = demand.rstk__soorddmdcst_locid__r.rstk__sylocid_site__c;
                    location.ProjectId = demand.rstk__soorddmdcst_locid__r.rstk__sylocid_div__r.rstk__sydiv_dflthomeproj__c;
                    location.DivisionId = demand.rstk__soorddmdcst_locid__r.rstk__sylocid_div__c;

                    record.Demands.add(location);
                }
            }
            return record;
        }
        return null;
    }

    @TestVisible
    private ItemLocation ReduceLineQty_getIvcResearchLocation;

    @TestVisible
    private ItemLocation getIvcResearchLocation() {
        if(ReduceLineQty_getIvcResearchLocation != null && Test.isRunningTest()){
            return ReduceLineQty_getIvcResearchLocation;
        }

        String locationId = '90';
        String locationNumber = 'IVCRSRCH';

        for(FMG_Configuration__c config : [
                SELECT
                        Id,
                        Setting__c,
                        Value__c,
                        Application__c
                FROM FMG_Configuration__c
                WHERE Application__c = 'FMGRSAPI - IvcResearchLocation']){
            switch on config.Setting__c {
                when 'LocationId'{
                    locationId = config.Value__c;
                }
                when 'LocationNumber'{
                    locationNumber = config.Value__c;
                }
            }
        }


        rstk__sylocid__c locationInfo = [
                SELECT Id, rstk__sylocid_div__c, rstk__sylocid_site__c,
                        rstk__sylocid_div__r.rstk__sydiv_dflthomeproj__c
                FROM rstk__sylocid__c
                WHERE rstk__sylocid_locid__c = :locationId
                LIMIT 1
        ];

        if (locationInfo == null) {
            return null;
        }
        ItemLocation location = new ItemLocation();
        location.DivisionId = locationInfo.rstk__sylocid_div__c;
        location.SiteId = locationInfo.rstk__sylocid_site__c;
        location.ProjectId = locationInfo.rstk__sylocid_div__r.rstk__sydiv_dflthomeproj__c;
        location.LocId = locationInfo.Id;
        location.LocNumber = locationNumber;
        return location;
    }

    @TestVisible
    private List<ItemLocation> ReduceLineQty_getItemBaseLocation;

    @TestVisible
    private List<ItemLocation> getItemBaseLocation(Id itemNumber) {
        if(ReduceLineQty_getItemBaseLocation != null && Test.isRunningTest()){
            return ReduceLineQty_getItemBaseLocation;
        }
        List<ItemLocation> locations = new List<ItemLocation>();
        for (rstk__iclocitem__c locationInfo : [
                SELECT Id, rstk__iclocitem_locnum__c,
                        rstk__iclocitem_locid__r.rstk__sylocid_div__c, rstk__iclocitem_locid__r.rstk__sylocid_site__c,
                        rstk__iclocitem_proj__c, rstk__iclocitem_locqty__c, rstk__iclocitem_locid__c
                FROM rstk__iclocitem__c
                WHERE rstk__iclocitem_locid__c IN (
                        SELECT rstk__icitem_wmslocid__c
                        FROM rstk__icitem__c
                        WHERE Id = :itemNumber
                )
                AND rstk__iclocitem_icitem__c = :itemNumber
                AND rstk__iclocitem_locqty__c > 0
        ]) {
            ItemLocation location = new ItemLocation();
            location.DivisionId = locationInfo.rstk__iclocitem_locid__r.rstk__sylocid_div__c;
            location.SiteId = locationInfo.rstk__iclocitem_locid__r.rstk__sylocid_site__c;
            location.ProjectId = locationInfo.rstk__iclocitem_proj__c;
            location.LocId = locationInfo.rstk__iclocitem_locid__c;
            location.LocNumber = locationInfo.rstk__iclocitem_locnum__c;
            location.Qty = locationInfo.rstk__iclocitem_locqty__c;
            locations.add(location);
        }

        return locations;
    }

    public class ItemReversalLocation{
        public Id DemandId{get;set;}
        public Decimal qty{get;set;}
        public Id LocId{get;set;}
        public String LocNumber{get;set;}
        public Id SiteId{get;set;}
        public Id ProjectId{get;set;}
        public Id DivisionId{get;set;}
    }

    public class OrderItemReversal{
        public List<ItemReversalLocation> Demands{get;set;}
        public Decimal FirmedAllocated{get;set;}
        public Decimal Issued{get;set;}
        public Decimal Packed{get;set;}
        public Decimal Qty{get;set;}
        public Id InventoryProductId{get;set;}
        private Decimal privateNewQty;
        public Decimal NewQty{get{return privateNewQty;}
            set{
                Decimal calculatedIssued = Issued - Packed;
                privateNewQty = value;
                QtyToRemove = Qty - privateNewQty;

                if(QtyToRemove <= FirmedAllocated){
                    ReversePack = 0;
                    ReverseIssue = 0;
                    UnknownLocationRemove = QtyToRemove;
                    return;
                } else {
                    System.debug(LoggingLevel.FINE,'Failed - QtyToRemove('+QtyToRemove+')  <= FirmedAllocated('+FirmedAllocated+') ');
                }

                if(QtyToRemove <= FirmedAllocated + calculatedIssued){
                    ReversePack = 0;
                    ReverseIssue = QtyToRemove - FirmedAllocated;
                    UnknownLocationRemove = FirmedAllocated;
                    return;
                } else {
                    System.debug(LoggingLevel.FINE,'Failed - QtyToRemove('+QtyToRemove+')  <= FirmedAllocated('+FirmedAllocated+')  + calculatedIssued('+calculatedIssued+')');
                }

                if(QtyToRemove <= FirmedAllocated + calculatedIssued + Packed){
                    ReversePack = QtyToRemove - calculatedIssued - FirmedAllocated;
                    ReverseIssue = calculatedIssued;
                    UnknownLocationRemove = FirmedAllocated;
                    return;
                } else {
                    System.debug(LoggingLevel.FINE,'Failed - QtyToRemove('+QtyToRemove+') <= FirmedAllocated('+FirmedAllocated+') + calculatedIssued('+calculatedIssued+') + Packed('+Packed+')');
                }

                
                ExceededMaxRemovalException error = new ExceededMaxRemovalException();
                error.ReversalItem = this;
                throw error;
            }}

        public Decimal ReversePack{get;private set;}
        public Decimal ReverseIssue{get;private set;}
        public Decimal QtyToRemove{get;private set;}
        public Decimal UnknownLocationRemove{get;private set;}
    }


    public class ItemLocation {
        public Id DivisionId { get; set; }
        public Id SiteId { get; set; }
        public Id ProjectId { get; set; }
        public Id LocId { get; set; }
        public String LocNumber { get; set; }
        public Decimal Qty{get;set;}
    }

    public class ExceededMaxRemovalException extends Exception{
        public OrderItemReversal ReversalItem{get;set;}
    }



    public class ShippingHeader{
        public String CarrierCode  { get; set; }
        public String SalesforceOrderId { get; set; }
        public OrderAddressInfo ShippingAddress  { get; set; }
        public String ShipMethod  { get; set; }
        public Decimal VerifiedShippingTax{get;set;}
    }

    public void updateOrderShippingHeaders(List<FMGRSAPI_Orders_Service.ShippingHeader> headers){
        List<Id> orderIds = new List<Id>();
        set<String> carrierCodes = new set<String>();
        set<String> shipMethods = new set<String>();

        System.debug(LoggingLevel.DEBUG,JSON.serializePretty(headers));
        for(FMGRSAPI_Orders_Service.ShippingHeader header:headers){
            orderIds.add(header.SalesforceOrderId);
            carrierCodes.add(header.CarrierCode);
            shipMethods.add(header.ShipMethod);
        }

        // Mapping to get correct carier and ship method
        List<rstk__socarriervia__c> shipInfo = getShippingInfo(carrierCodes,shipMethods);

        //Carrier Code first then the Shipping Method
        Map<string,Map<string,rstk__socarriervia__c>> shipInfoMap = new Map<String, Map<String, rstk__socarriervia__c>>();
        for(rstk__socarriervia__c info: shipInfo){
            if(!shipInfoMap.containsKey(info.rstk__socarriervia_carrier__r.rstk__sycarrier_id__c)){
                shipInfoMap.put(info.rstk__socarriervia_carrier__r.rstk__sycarrier_id__c,new Map<String, rstk__socarriervia__c>());
            }
            if(!shipInfoMap.get(info.rstk__socarriervia_carrier__r.rstk__sycarrier_id__c)
                    .containsKey(info.rstk__socarriervia_shipvia__r.rstk__syshipviatype_id__c)){

                shipInfoMap.get(info.rstk__socarriervia_carrier__r.rstk__sycarrier_id__c).put(info.rstk__socarriervia_shipvia__r.rstk__syshipviatype_id__c,info);
            }
        }

        // Mapping of all Shipping Headers to update
        List<rstk__soship__c> pulledShippingHeaders = getOpenShipperHeaderByOrderId(orderIds);

        Map<Id,rstk__soship__c> mappedShippingHeaders = new Map<Id, rstk__soship__c>();
        for(rstk__soship__c shipperHeader: pulledShippingHeaders){
            mappedShippingHeaders.put(shipperHeader.rstk__soship_order__c,shipperHeader);
        }


        List<rstk__soship__c> headersToUpdate = new List<rstk__soship__c>();
        for(FMGRSAPI_Orders_Service.ShippingHeader header:headers){
            Boolean hasChange = false;
            rstk__soship__c shipperHeader = mappedShippingHeaders.get(header.SalesforceOrderId);
            if(shipperHeader == null){
                System.debug(LoggingLevel.DEBUG,'Header Skipped: ' + header.SalesforceOrderId);
                continue;
            }

            // Shipping Information
            if(header.ShipMethod != null && header.CarrierCode != null){
                if(shipInfoMap.containsKey(header.CarrierCode)){
                    if(shipInfoMap.get(header.CarrierCode).containsKey(header.ShipMethod)){
                        rstk__socarriervia__c shippingInfo = shipInfoMap.get(header.CarrierCode).get(header.ShipMethod);

                        if(shipperHeader.rstk__soship_carrier__c != shippingInfo.rstk__socarriervia_carrier__c){
                            shipperHeader.rstk__soship_carrier__c = shippingInfo.rstk__socarriervia_carrier__c;
                            hasChange=true;
                        }

                        if(shipperHeader.rstk__soship_shipvia__r.Id != shippingInfo.rstk__socarriervia_shipvia__r.Id){
                            shipperHeader.rstk__soship_shipvia__c = shippingInfo.rstk__socarriervia_shipvia__r.Id;
                            hasChange=true;
                        }
                    }
                }
            }

            System.debug(LoggingLevel.DEBUG,'Shipper Header Tax: ' + shipperHeader.rstk__soship_shippingtax__c);
            System.debug(LoggingLevel.DEBUG,'New Shipper Header Tax: ' + header.VerifiedShippingTax);
            if(shipperHeader.rstk__soship_shippingtax__c != header.VerifiedShippingTax){
                shipperHeader.rstk__soship_shippingtax__c = header.VerifiedShippingTax;
                hasChange=true;
            }

            if(shipperHeader.rstk__soship_address1__c != header.ShippingAddress.Address1 && header.ShippingAddress.Address1 != null){
                shipperHeader.rstk__soship_address1__c = header.ShippingAddress.Address1;
                hasChange=true;
            }

            if(shipperHeader.rstk__soship_address2__c != header.ShippingAddress.Address2 && header.ShippingAddress.Address2 != null){
                shipperHeader.rstk__soship_address2__c = header.ShippingAddress.Address2;
                hasChange=true;
            }

            if(shipperHeader.rstk__soship_address3__c != header.ShippingAddress.Address3 && header.ShippingAddress.Address3 != null){
                shipperHeader.rstk__soship_address3__c = header.ShippingAddress.Address3;
                hasChange=true;
            }

            if(shipperHeader.rstk__soship_city__c != header.ShippingAddress.City && header.ShippingAddress.City != null){
                shipperHeader.rstk__soship_city__c = header.ShippingAddress.City;
                hasChange=true;
            }

            if(shipperHeader.rstk__soship_contact__c != header.ShippingAddress.CustName && header.ShippingAddress.CustName != null){
                shipperHeader.rstk__soship_contact__c = header.ShippingAddress.CustName;
                hasChange=true;
            }

            if(shipperHeader.rstk__soship_country__c != header.ShippingAddress.Country && header.ShippingAddress.Country != null){
                shipperHeader.rstk__soship_country__c = header.ShippingAddress.Country;
                hasChange=true;
            }

            if(shipperHeader.rstk__soship_isocountry__c != header.ShippingAddress.CountryIso && header.ShippingAddress.CountryIso != null){
                shipperHeader.rstk__soship_isocountry__c = header.ShippingAddress.CountryIso;
                hasChange=true;
            }

            if(shipperHeader.rstk__soship_email__c != header.ShippingAddress.Email && header.ShippingAddress.Email != null){
                shipperHeader.rstk__soship_email__c = header.ShippingAddress.Email;
                hasChange=true;
            }

            if(shipperHeader.rstk__soship_phone__c != header.ShippingAddress.Phone && header.ShippingAddress.Phone != null){
                shipperHeader.rstk__soship_phone__c = header.ShippingAddress.Phone;
                hasChange=true;
            }

            if(shipperHeader.rstk__soship_zip__c != header.ShippingAddress.Zip && header.ShippingAddress.Zip != null){
                shipperHeader.rstk__soship_zip__c = header.ShippingAddress.Zip;
                hasChange=true;
            }

            if(shipperHeader.rstk__soship_state__c != header.ShippingAddress.State && header.ShippingAddress.State != null){
                shipperHeader.rstk__soship_state__c = header.ShippingAddress.State;
                hasChange=true;
            }

            if(hasChange){
                headersToUpdate.add(shipperHeader);
            }
        }

        if(!headersToUpdate.isEmpty()){
            updateShipperHeaders(headersToUpdate);
        }
    }

    public List<rstk__soship__c> getOpenShipperHeaderByOrderId(List<Id> orderId){
        List<rstk__soship__c> records = [SELECT Id, rstk__soship_order__r.Id, rstk__soship_closed__c,
                rstk__soship_carrier__r.Id, rstk__soship_shipvia__r.Id, rstk__soship_address1__c,
                rstk__soship_address2__c, rstk__soship_address3__c, rstk__soship_city__c,
                rstk__soship_email__c, rstk__soship_phone__c, rstk__soship_zip__c,
                rstk__soship_state__c, rstk__soship_contact__c, rstk__soship_country__c,
                rstk__soship_isocountry__c,rstk__soship_shippingtax__c
        FROM rstk__soship__c
        WHERE rstk__soship_order__c in :orderId AND rstk__soship_closed__c = false];

        if(ordersServiceDataAccessOverride != null && test.isRunningTest()){
            records = ordersServiceDataAccessOverride.getOpenShipperHeaderByOrderId(orderId);
        }

        return records;
    }

    public List<rstk__socarriervia__c> getShippingInfo(set<String> carrierCodes, set<String> shipMethods){
        List<rstk__socarriervia__c> records = [SELECT Id, rstk__socarriervia_carrier__r.Id,
                rstk__socarriervia_carrier__r.rstk__sycarrier_id__c, rstk__socarriervia_shipvia__r.Id,
                rstk__socarriervia_shipvia__r.rstk__syshipviatype_id__c
        FROM rstk__socarriervia__c
        WHERE rstk__socarriervia_carrier__r.rstk__sycarrier_id__c in :carrierCodes
        AND rstk__socarriervia_shipvia__r.rstk__syshipviatype_id__c in :shipMethods];

        if(ordersServiceDataAccessOverride != null && test.isRunningTest()){
            records = ordersServiceDataAccessOverride.getShippingInfo(carrierCodes,shipMethods);
        }

        return records;
    }

    public void updateShipperHeaders(List<rstk__soship__c> headers){
        if(ordersServiceDataAccessOverride != null && test.isRunningTest()){
            ordersServiceDataAccessOverride.updateShipperHeaders(headers);
        } else {
            update headers;
        }

    }

    public class updateFmgExtendedHeader{
        public String Id{get;set;}
        public Boolean IsEmployee{get;set;}
        public Boolean IsFacility{get;set;}
        public Boolean IsForeign{get;set;}
        public Boolean IsHazardous{get;set;}
        public Boolean IsLightweight{get;set;}
        public Boolean IsOverweight{get;set;}
        public Boolean IsPlatinum{get;set;}
    }
    public void updateFmgExtendedHeaderFields(List<updateFmgExtendedHeader> records){
        Map<String,updateFmgExtendedHeader> UpdateData = new Map<String, updateFmgExtendedHeader>();
        for(updateFmgExtendedHeader record :records){
            UpdateData.put(record.Id,record);
        }

        List<fmgsohdrext__c> recordsToUpdate = getFmgExtendedHeaders(UpdateData.keySet());
        List<fmgsohdrext__c> updateCollection = new List<fmgsohdrext__c>();

        for(fmgsohdrext__c record : recordsToUpdate){
            updateFmgExtendedHeader data = UpdateData.get(record.fmgsohdrext_sohdr__c);
            if(data != null){

                Boolean hasUpdate = false;

                if(data.IsEmployee != null){
                    hasUpdate=true;
                    record.IsEmployee__c = data.IsEmployee;
                }
                if(data.IsFacility != null){
                    hasUpdate=true;
                    record.IsFacility__c = data.IsFacility;
                }
                if(data.IsHazardous != null){
                    hasUpdate=true;
                    record.IsHazardous__c = data.IsHazardous;
                }
                if(data.IsLightweight != null){
                    hasUpdate=true;
                    record.IsLightweight__c = data.IsLightweight;
                }
                if(data.IsOverweight != null){
                    hasUpdate=true;
                    record.IsOverweight__c = data.IsOverweight;
                }
                if(data.IsPlatinum != null){
                    hasUpdate=true;
                    record.IsPlatinum__c = data.IsPlatinum;
                }

                if(data.IsForeign != null){
                    hasUpdate=true;
                    record.IsForeign__c = data.IsForeign;
                }

                if(hasUpdate){
                    updateCollection.add(record);
                }

            }
        }

        if(!updateCollection.isEmpty()){
            updateFmgExtendedHeadersFields(updateCollection);
        }
    }


    /******************************************************************************
    * This is for all data access for selecting, updating, upserts and delets
    **/

    @TestVisible
    private FMGRSAPI_Orders_Service_DataInterface ordersServiceDataAccessOverride {get;set; }


    public List<fmgsohdrext__c> getFmgExtendedHeaders(Set<String> ids){
        List<fmgsohdrext__c> records = [SELECT Id, fmgsohdrext_sohdr__c, IsEmployee__c,
                IsFacility__c, IsHazardous__c, IsLightweight__c, IsOverweight__c,
                IsPlatinum__c,IsForeign__c
        FROM fmgsohdrext__c
        WHERE fmgsohdrext_sohdr__c = :ids];

        if(ordersServiceDataAccessOverride != null && Test.isRunningTest()){
            records = ordersServiceDataAccessOverride.getFmgExtendedHeaders(ids);
        }
        return records;
    }

    public void updateFmgExtendedHeadersFields(List<fmgsohdrext__c> records){
        if(ordersServiceDataAccessOverride != null && Test.isRunningTest()){
            ordersServiceDataAccessOverride.updateFmgExtendedHeadersFields(records);
        } else {
            update records;
        }
    }

    public List<rstk__sohdr__c> queryOrdersById(List<Id> orderIds) {
        List<rstk__sohdr__c> orders = [SELECT Id, rstk__sohdr_order__c,
        (
                SELECT Id, Time_of_Pack__c,
                        Time_of_Ship__c,
                        Time_of_Pick__c,
                        IsFirstOrder__c,
                        IsForeign__c,
                        IsLightweight__c,
                        batchId__c
                FROM fmgsohdrext__r
        ),
                rstk__sohdr_account__r.Id,
                rstk__sohdr_account__r.Fed_Ex_Account_Number__c,
                rstk__sohdr_account__r.UPS_Account_Number__c,
                rstk__sohdr_sohdrext__r.rstk__sohdrextn_shipvia__r.Id,
                rstk__sohdr_sohdrext__r.rstk__sohdrextn_shipvia__r.Name,
                rstk__sohdr_sohdrext__r.rstk__sohdrextn_shipvia__r.rstk__syshipviatype_id__c, rstk__sohdr_sohdrext__r.rstk__sohdrextn_carrier__r.Id,
                rstk__sohdr_sohdrext__r.rstk__sohdrextn_carrier__r.rstk__sycarrier_id__c, rstk__sohdr_sohdrext__r.rstk__sohdrextn_carrier__r.Name,
                rstk__sohdr_billtoaddr__r.rstk__socaddr_address1__c, rstk__sohdr_billtoaddr__r.rstk__socaddr_address2__c,
                rstk__sohdr_billtoaddr__r.rstk__socaddr_address3__c, rstk__sohdr_billtoaddr__r.rstk__socaddr_city__c,
                rstk__sohdr_billtoaddr__r.rstk__socaddr_contact__r.rstk__socontact_contact__c, rstk__sohdr_billtoaddr__r.rstk__socaddr_country__c,
                rstk__sohdr_billtoaddr__r.rstk__socaddr_isocountry__c, rstk__sohdr_billtoaddr__r.rstk__socaddr_name__c,
                rstk__sohdr_billtoaddr__r.rstk__socaddr_custno__r.rstk__socust_custno__c, rstk__sohdr_billtoaddr__r.rstk__socaddr_email__c,
                rstk__sohdr_billtoaddr__r.rstk__socaddr_phone__c, rstk__sohdr_billtoaddr__r.rstk__socaddr_zip__c,
                rstk__sohdr_billtoaddr__r.Id, rstk__sohdr_billtoaddr__r.rstk__socaddr_state__c,
                rstk__sohdr_billtoaddr__r.rstk__socaddr_custno__r.rstk__socust_sf_account__r.CompanyName__c,

                rstk__sohdr_obilltoaddr__c,
                rstk__sohdr_obilltoaddr__r.rstk__soaddr_address1__c, rstk__sohdr_obilltoaddr__r.rstk__soaddr_address2__c,
                rstk__sohdr_obilltoaddr__r.rstk__soaddr_address3__c, rstk__sohdr_obilltoaddr__r.rstk__soaddr_city__c,
                rstk__sohdr_obilltoaddr__r.rstk__soaddr_ovrsocust__r.rstk__socust_contact__c, rstk__sohdr_obilltoaddr__r.rstk__soaddr_country__c,
                rstk__sohdr_obilltoaddr__r.rstk__soaddr_isocountry__c, rstk__sohdr_obilltoaddr__r.rstk__soaddr_name__c,
                rstk__sohdr_obilltoaddr__r.rstk__soaddr_ovrsocust__r.rstk__socust_custno__c, rstk__sohdr_obilltoaddr__r.rstk__soaddr_email__c,
                rstk__sohdr_obilltoaddr__r.rstk__soaddr_phone__c, rstk__sohdr_obilltoaddr__r.rstk__soaddr_zip__c,
                rstk__sohdr_obilltoaddr__r.Id, rstk__sohdr_obilltoaddr__r.rstk__soaddr_state__c,
                rstk__sohdr_obilltoaddr__r.rstk__soaddr_ovrsocust__r.rstk__socust_sf_account__r.CompanyName__c,

                rstk__sohdr_shiptoaddr__r.rstk__socaddr_address1__c, rstk__sohdr_shiptoaddr__r.rstk__socaddr_address2__c,
                rstk__sohdr_shiptoaddr__r.rstk__socaddr_address3__c, rstk__sohdr_shiptoaddr__r.rstk__socaddr_city__c,
                rstk__sohdr_shiptoaddr__r.rstk__socaddr_contact__r.rstk__socontact_contact__c, rstk__sohdr_shiptoaddr__r.rstk__socaddr_country__c,
                rstk__sohdr_shiptoaddr__r.rstk__socaddr_isocountry__c, rstk__sohdr_shiptoaddr__r.rstk__socaddr_name__c,
                rstk__sohdr_shiptoaddr__r.rstk__socaddr_custno__r.rstk__socust_custno__c, rstk__sohdr_shiptoaddr__r.rstk__socaddr_email__c,
                rstk__sohdr_shiptoaddr__r.rstk__socaddr_phone__c, rstk__sohdr_shiptoaddr__r.rstk__socaddr_zip__c,
                rstk__sohdr_shiptoaddr__r.Id, rstk__sohdr_shiptoaddr__r.rstk__socaddr_state__c,
                rstk__sohdr_oshiptoaddr__c,
                rstk__sohdr_oshiptoaddr__r.rstk__soaddr_address1__c, rstk__sohdr_oshiptoaddr__r.rstk__soaddr_address2__c,
                rstk__sohdr_oshiptoaddr__r.rstk__soaddr_address3__c, rstk__sohdr_oshiptoaddr__r.rstk__soaddr_city__c,
                rstk__sohdr_oshiptoaddr__r.rstk__soaddr_ovrsocust__r.rstk__socust_contact__c, rstk__sohdr_oshiptoaddr__r.rstk__soaddr_country__c,
                rstk__sohdr_oshiptoaddr__r.rstk__soaddr_isocountry__c, rstk__sohdr_oshiptoaddr__r.rstk__soaddr_name__c,
                rstk__sohdr_oshiptoaddr__r.rstk__soaddr_ovrsocust__r.rstk__socust_custno__c, rstk__sohdr_oshiptoaddr__r.rstk__soaddr_email__c,
                rstk__sohdr_oshiptoaddr__r.rstk__soaddr_phone__c, rstk__sohdr_oshiptoaddr__r.rstk__soaddr_zip__c,
                rstk__sohdr_oshiptoaddr__r.Id, rstk__sohdr_oshiptoaddr__r.rstk__soaddr_state__c,
                CreatedDate, rstk__sohdr_orderdate__c,
        (
                SELECT Id, rstk__soline_line__c, rstk__soline_origqtyord__c,
                        rstk__soline_qtyorder__c, rstk__soline_price__c,
                        rstk__soline_prod__r.rstk__soprod_descr__c, rstk__soline_prod__r.Id, rstk__soline_icitem__r.Id,
                        rstk__soline_icitem__r.rstk__icitem_descr__c,
                        rstk__soline_icitem__r.rstk__icitem_item__r.rstk__peitem_item__c, rstk__soline_weight__c,
                        rstk__soline_prod__r.rstk__soprod_weight__c, rstk__soline_icitem__r.rstk__icitem_wmslocnum__c,
                        rstk__soline_icitem__r.rstk__icitem_wmslocid__r.rstk__sylocid_locid__c,
                        rstk__soline_prod__r.rstk__soprod_comcod__r.rstk__externalid__c
                FROM rstk__solines__r

        ),
                rstk__sohdr_custno__r.rstk__socust_sf_account__r.Employee__c,
                rstk__sohdr_custno__r.rstk__socust_sf_account__r.Facility__c, rstk__sohdr_custno__r.rstk__socust_sf_account__r.Type,
                rstk__sohdr_custno__r.rstk__socust_custno__c,
                rstk__sohdr_custno__r.rstk__socust_sf_account_name__c,
                rstk__sohdr_custno__r.Id,
                Order_Comment__c,
                No_Catalog_in_Order__c,
                signature_Required__c,
                Correction_Order__c,
                PO_Number__c,
                third_Party_Carrier_Account_Billing__c


        FROM rstk__sohdr__c
        WHERE Id = :orderIds];
        if(ordersServiceDataAccessOverride != null && Test.isRunningTest()){
            orders = ordersServiceDataAccessOverride.queryOrdersById(orderIds);
        }

        return orders;
    }

    public  List<OrderDeliveryGroupSummary> queryOrderDeliveryGroupSummaryData(List<String> orderNumbers){
        List<OrderDeliveryGroupSummary> records = [SELECT Id, OrderSummary.OrderNumber,Company_Name__c
        FROM OrderDeliveryGroupSummary where OrderSummary.OrderNumber in :orderNumbers];

        if(ordersServiceDataAccessOverride != null && Test.isRunningTest()){
            records = ordersServiceDataAccessOverride.queryOrderDeliveryGroupSummaryData(orderNumbers);
        }

        return records;
    }
    public Map<String, OrderDeliveryGroupSummary> queryOrderDeliveryGroupSummarys(List<String> orderNumbers) {
        Map<String, OrderDeliveryGroupSummary> orderDeliveryGroupSummarys = new Map<String, OrderDeliveryGroupSummary>();

        List<OrderDeliveryGroupSummary> records = queryOrderDeliveryGroupSummaryData(orderNumbers);

        for(OrderDeliveryGroupSummary record: records){
            orderDeliveryGroupSummarys.put(record.OrderSummary.OrderNumber,record);
        }

        return orderDeliveryGroupSummarys;
    }
}