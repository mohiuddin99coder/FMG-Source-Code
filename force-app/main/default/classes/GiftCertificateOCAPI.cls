global class GiftCertificateOCAPI {
    @future(callout = true)
    public static void OCAPIGenerateAccessToken(List<String> merchantids){
        system.debug('merchantids'+merchantids);
        List<Integration_Log__c> logRecordsList = new List<Integration_Log__c>();
        Gift_Certificate_OCAPI_Setting__mdt OCAPISettings = Gift_Certificate_OCAPI_Setting__mdt.getinstance('OCAPI_RS_Pilot');
        system.debug(OCAPISettings);
        system.debug(OCAPISettings.Client_id__c);
        system.debug(OCAPISettings.Base_URL__c);
        String bearerToken = '';
        string reqBody = '{ "type" : "guest"}';
        
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint(OCAPISettings.Base_URL__c);
            req.setHeader('x-dw-client-id', OCAPISettings.Client_id__c);
            req.setHeader('Content-Type', OCAPISettings.Content_Type__c);
            req.setBody(reqBody);
            req.setMethod('POST');
            Http http = new Http();
            system.debug('req' +req);
            HttpResponse res = http.send(req);
            if(res.getStatusCode() == 200){
                logRecordsList.add(APICallOutLogsCreation.createIntegrationLogRecord(reqBody,res.getBody(),res.getStatus(),'GiftCertificateOCAPI.OCAPIGenerateAccessToken',req.getEndpoint(),'Success'));
                bearerToken = res.getHeader('Authorization');
                System.debug(req);
                system.debug('res.getStatus--->'+res.getStatus());
                system.debug('res.getBody-->'+res.getBody());
                System.debug('Access token-->'+req.getHeader('Authorization'));
                System.debug('response.headers.get-->'+res.getHeader('Authorization'));
                System.debug(res);
            }
            if(bearerToken != Null ){
                updateGiftCertificate(bearerToken,merchantids);
            }
        }
        catch(exception ex){
            string exMsg = ex.getMessage()+''+ex.getLineNumber()+''+ex.getTypeName();
            logRecordsList.add(APICallOutLogsCreation.createIntegrationLogRecord(reqBody,null,ex.getMessage(),'GiftCertificateOCAPI.OCAPIGenerateAccessToken',OCAPISettings.Base_URL__c,'Failure'));

        }
        
        insert logRecordsList;
    }
    
    Public static void updateGiftCertificate(String bearerToken,List<String> merchantids){
        system.debug('merchantids'+merchantids);
        Gift_Certificate_OCAPI_Setting__mdt OCAPISettings = Gift_Certificate_OCAPI_Setting__mdt.getinstance('OCAPI_RS_Pilot_UpdateGC');
        string reqBody = '{"gift_certificate_code": ""}';
        
        List<Integration_Log__c> logRecordsList = new List<Integration_Log__c>();
        for(String merchantid : merchantids){
            try{
                if(merchantid != Null){
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint(OCAPISettings.Base_URL__c);
                    req.setHeader('x-dw-client-id', OCAPISettings.Client_id__c);
                    req.setHeader('Content-Type', OCAPISettings.Content_Type__c);
                    req.setHeader('x-gc-update-status','true');
                    req.setHeader('x-gc-merchantid',merchantid);
                    req.setHeader('x-gc-trigger-email','true');
                    req.setHeader('Authorization',bearerToken);
                    
                    req.setBody(reqBody);
                    req.setMethod('POST');
                    Http http = new Http();
                    System.debug('Request-->'+req);
                    System.debug('merchantid--->'+merchantid);
                    HttpResponse res = http.send(req);
                    System.debug('Response-->'+res.getBody());
                    
                    String responseData = res.getBody();
                    if(res.getStatusCode() == 200){
                        logRecordsList.add(APICallOutLogsCreation.createIntegrationLogRecord(reqBody,responseData,res.getStatus(),'GiftCertificateOCAPI.updateGiftCertificate',req.getEndpoint(),'Success'));
                    
                    }
                    
                }
            }
            catch(exception ex){
                
                string exMsg = ex.getMessage()+''+ex.getLineNumber()+''+ex.getTypeName();
                logRecordsList.add(APICallOutLogsCreation.createIntegrationLogRecord(reqBody,Null,ex.getMessage(),'GiftCertificateOCAPI.updateGiftCertificate',OCAPISettings.Base_URL__c,'Failure'));            
                
            }
        }
        
        insert logRecordsList;
    }
}