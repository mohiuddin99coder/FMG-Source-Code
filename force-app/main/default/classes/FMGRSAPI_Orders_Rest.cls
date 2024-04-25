/**
 * Created by Adam-Hotmail on 5/19/2023.
 */

@RestResource(UrlMapping='/fmgrsapi/orders')
global with sharing class FMGRSAPI_Orders_Rest {

    @TestVisible
    static FMGRSAPI_Orders_ServiceInterface ordersService {get;set; }
    static{
        ordersService = (FMGRSAPI_Orders_ServiceInterface)new FMGRSAPI_Orders_Service();
    }

    @HttpGet
    global static void getOrders(){
        Map<String,String> paramsMap = RestContext.request.params;
        RestContext.response.statusCode = 200;
        RestContext.response.headers.put('Content-Type','application/json');
        if(paramsMap.containsKey('Id')){
            if(paramsMap.get('Id').isWhitespace()){
                RestContext.response.responseBody = Blob.valueOf('[]');
                return;
            }
            List<Id> data = paramsMap.get('Id').split(',');

            if(!data.isEmpty()){

                FMGRSAPI_Orders_Service.BatchData results = ordersService.getOrdersById(data);
                String returnBody = JSON.serialize(results,true);
                RestContext.response.responseBody = Blob.valueOf(returnBody);
                if(Test.isRunningTest()){
                    getOrdersTestResponse = results;
                }

                return;
            }
        }

        RestContext.response.responseBody = Blob.valueOf('[]');

    }

    @TestVisible
    private static FMGRSAPI_Orders_Service.BatchData getOrdersTestResponse{get;set;}

    global class UpdateData{
        global String Id{get;set;}
        global Boolean IsEmployee{get;set;}
        global Boolean IsFacility{get;set;}
        global Boolean IsForeign{get;set;}
        global Boolean IsHazardous{get;set;}
        global Boolean IsLightweight{get;set;}
        global Boolean IsOverweight{get;set;}
        global Boolean IsPlatinum{get;set;}
    }

    @HttpPatch
    global static void patchOrders(List<UpdateData> records){

    List<FMGRSAPI_Orders_Service.updateFmgExtendedHeader> processingObjects = new List<FMGRSAPI_Orders_Service.updateFmgExtendedHeader>();
    for(UpdateData record:records){
        FMGRSAPI_Orders_Service.updateFmgExtendedHeader convertedRecord = new FMGRSAPI_Orders_Service.updateFmgExtendedHeader();
        convertedRecord.Id = record.Id;
        convertedRecord.IsEmployee = record.IsEmployee;
        convertedRecord.IsFacility = record.IsFacility;
        convertedRecord.IsForeign = record.IsForeign;
        convertedRecord.IsHazardous = record.IsHazardous;
        convertedRecord.IsLightweight = record.IsLightweight;
        convertedRecord.IsOverweight = record.IsOverweight;
        convertedRecord.IsPlatinum = record.IsPlatinum;
        processingObjects.add(convertedRecord);
    }
        ordersService.updateFmgExtendedHeaderFields(processingObjects);
    }

}