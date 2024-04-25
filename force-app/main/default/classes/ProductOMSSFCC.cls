global class ProductOMSSFCC{
@future(callout = true)
public static void generateAccessTokenMetod(List<Id> prodIDs){
       
        Rest_getAccessTokenWrapper RGW = new Rest_getAccessTokenWrapper();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST'); 
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setEndpoint(System.Label.CC_Product_ENDPOINT); //https://account.demandware.com/dw/oauth2/access_token 
        String CLIENT_ID = System.Label.CC_Product_CLIENT_ID; //347c1dfd-6fc4-41b7-b60b-fec36af987c6   
        String CLIENT_SECRET = System.Label.CC_Product_CLIENT_SECRET; //jIlM6PDWv46B4USTJBrJyBZuVCO4GIEf   
        Blob headerValue = Blob.valueOf(CLIENT_ID + ':' + CLIENT_SECRET);
        String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
        string tenantGroupId = 'staging';

        String scope;
        if(tenantGroupId == System.Label.CC_Product_TENANT_GROUP_ID){
           
            scope =EncodingUtil.urlEncode('SALESFORCE_COMMERCE_API:bkcr_stg sfcc.inventory.impex-event-log sfcc.inventory.impex-graphs sfcc.inventory.impex-graphs.rw sfcc.inventory.impex-inventory.rw sfcc.inventory.impex-inventory sfcc.inventory.availability sfcc.inventory.availability.rw sfcc.inventory.reservations sfcc.inventory.reservations.rw sfcc.inventory.admin.rw','UTF-8');
        }
        else{
            scope =EncodingUtil.urlEncode('SALESFORCE_COMMERCE_API:bkcr_prd sfcc.inventory.impex-event-log sfcc.inventory.impex-graphs sfcc.inventory.impex-graphs.rw sfcc.inventory.impex-inventory.rw sfcc.inventory.impex-inventory sfcc.inventory.availability sfcc.inventory.availability.rw sfcc.inventory.reservations sfcc.inventory.reservations.rw sfcc.inventory.admin.rw','UTF-8');
        }
        req.setHeader('Authorization', authorizationHeader);
        System.debug('Authorization ' + authorizationHeader);
        req.setBody('grant_type=client_credentials'+'&scope='+scope);        
        
        Http http = new Http();
        HTTPResponse response = http.send(req);
        System.debug('Response: ' + response);
        
        string token = response.getBody();
        RGW = (Rest_getAccessTokenWrapper)JSON.deserialize(response.getBody(), Rest_getAccessTokenWrapper.class);
        token = RGW.access_token ;
        system.debug('s ::'+token);

        processProductIds(token,prodIDs);
           
      
    }
    
    Public static void processProductIds(String token,List<Id> prodIDs){

        List<Product2> prodList = [Select Id,Name,Description,StockKeepingUnit from Product2 where Id in :prodIDs];
        List<Integration_Log__c> logRecordsList = new List<Integration_Log__c>();

        for ( Product2 prd: prodList)
            upsertProduct(token,prd, logRecordsList);

        //insert logs
        insert logRecordsList;
    }
    
    Public static void upsertProduct(String bearerToken,Product2 pd2,List<Integration_Log__c> logs){
       
        FMG_OCAPI_Setting__mdt FMGOCAPISettings = FMG_OCAPI_Setting__mdt.getinstance('FMG_OCAPI');

        string reqBody = '{"owning_catalog_id": "catMasterFMG","name":"'+pd2.Name +'"}';

        try{
        
            HttpRequest req = new HttpRequest();          
            String ccurl = System.Label.CC_Product_URL;          
            req.setEndpoint(ccurl+pd2.StockKeepingUnit);                    
            req.setHeader('x-dw-client-id', FMGOCAPISettings.Client_id__c);
            req.setHeader('Content-Type', FMGOCAPISettings.Content_Type__c);                    
            req.setHeader('id',pd2.StockKeepingUnit);
            req.setHeader('x-dw-name',pd2.Name);
            req.setHeader('x-dw-Description',pd2.Name);                    
            req.setHeader('catalog_id','catMasterFMG');
            req.setHeader('owning_catalog_id','catMasterFMG');
                    
            req.setHeader('Authorization','Bearer '+bearerToken);
                                     
            req.setBody(reqBody);
            req.setMethod('PUT');
            Http http = new Http();
            //System.debug('Request-->'+req);

            HttpResponse res = http.send(req);
            //System.debug('Response-->'+res.getBody());

            logs.add(APICallOutLogsCreation.createIntegrationLogRecord(reqBody, res.getBody(),res.getStatus(),'FMGOCAPISettings.upsertProduct',req.getEndpoint(),'Success'));        
        }
        catch(exception ex){
                
            string exMsg = ex.getMessage()+''+ex.getLineNumber()+''+ex.getTypeName();
            system.debug(ex.getStackTraceString());
            logs.add(APICallOutLogsCreation.createIntegrationLogRecord(reqBody,Null,ex.getMessage(),'FMGOCAPISettings.upsertProduct',FMGOCAPISettings.Base_URL__c,'Failure'));            
                
        }
        
    }

}