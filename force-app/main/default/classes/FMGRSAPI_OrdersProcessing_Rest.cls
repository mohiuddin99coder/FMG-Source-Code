/**
 * Created by Adam-Hotmail on 5/19/2023.
 */

@RestResource(UrlMapping='/fmgrsapi/order/processing')
global with sharing class FMGRSAPI_OrdersProcessing_Rest {
    global class ProcessOrderEvent{
        global Datetime EventTime{get;set;}
        global String OrderEvent{get;set;}
        global Id SalesforceOrderId{get;set;}
        global String Username{get;set;}
        public FMGRSAPI_Orders_Service.ProcessOrderEvent convert(){
            FMGRSAPI_Orders_Service.ProcessOrderEvent returnObject = new FMGRSAPI_Orders_Service.ProcessOrderEvent();
            returnObject.EventTime = EventTime;
            returnObject.OrderEvent = OrderEvent;
            returnObject.SalesforceOrderId = SalesforceOrderId;
            returnObject.Username = Username;

            return returnObject;
        }
    }

    @TestVisible
    static FMGRSAPI_Orders_ServiceInterface ordersService {get;set; }
    static{
        ordersService = (FMGRSAPI_Orders_ServiceInterface)new FMGRSAPI_Orders_Service();
    }

    @HttpPost
    global static List<String> ExecutePost(List<ProcessOrderEvent> orderEvents,Boolean isBackground)
    {
        if(isBackground == null){
            isBackground = true;
        }
        List<FMGRSAPI_Orders_Service.ProcessOrderEvent> convertedOrderEvents = new List<FMGRSAPI_Orders_Service.ProcessOrderEvent>();
        for(ProcessOrderEvent event: orderEvents){
            convertedOrderEvents.add(event.convert());
        }
        return ordersService.processOrders(convertedOrderEvents,isBackground);
    }


}