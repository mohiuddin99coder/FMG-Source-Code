/**
* @description       : 
* @author            : Sridhar.Bonagiri@etg.digital
* @group             : 
* @last modified on  : 04-21-2023
* @last modified by  : Sridhar.Bonagiri@etg.digital
**/
public class Cls_Batch_OciApiCallouts Implements Queueable,database.allowscallouts{
    public Integer startNumber;
    public Integer endNumber;
    public Cls_Batch_OciApiCallouts(Integer startNumber, Integer endNumber){
        this.startNumber=startNumber;
        this.endNumber=endNumber;
    }
    public void execute(QueueableContext context) {
        list<product2> prdlist = new list<product2>();
        if(!test.isrunningtest()){
                    prdlist = [SELECT Location_external_name__c,StockKeepingUnit,QOH__c,name FROM Product2 WHERE StockKeepingUnit != null and Product_Count__c>:this.startNumber and Product_Count__c<=:this.endNumber ORDER BY StockKeepingUnit];
        }
        else{
            prdlist = [SELECT Location_external_name__c,StockKeepingUnit,QOH__c,name FROM Product2 WHERE StockKeepingUnit != null];
        }
        //system.debug('prdList size -->'+prdlist.size());
        //system.debug('start Range -->'+this.startNumber+' End Range -->'+this.endNumber);
        if(prdlist != NULL && prdlist.size()>0){
            generateAccessTokenMetod(prdlist);
        }
    }
    public void generateAccessTokenMetod(list<product2> prdlist){
        Rest_getAccessTokenWrapper RGW = new Rest_getAccessTokenWrapper();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setEndpoint(System.Label.OCI_Endpoint); //https://account.demandware.com/dw/oauth2/access_token 
        String CLIENT_ID = System.Label.OCI_CLIENT_ID; //347c1dfd-6fc4-41b7-b60b-fec36af987c6   
        String CLIENT_SECRET = System.Label.OCI_CLIENT_SECRET; //jIlM6PDWv46B4USTJBrJyBZuVCO4GIEf   
        Blob headerValue = Blob.valueOf(CLIENT_ID + ':' + CLIENT_SECRET);
        String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
        string tenantGroupId = '3e7150f0-71dc-4d34-9556-badc14940ee2';
        string locationExtName = 'DEV';
        String scope;
        if(tenantGroupId == System.Label.OCI_Tenant_Group_ID){
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
        System.debug('Body ' + response.getBody());
        System.debug('Status ' + response.getStatus());
        System.debug('Status code ' + response.getStatusCode());
        
        string s = response.getBody();
        RGW = (Rest_getAccessTokenWrapper)JSON.deserialize(response.getBody(), Rest_getAccessTokenWrapper.class);
        s = RGW.access_token ;
        system.debug('s ::'+s);
        system.debug('s:::'+response.getBody());
        // Callout to get upload URL
        makePostCallout(s,prdlist);
    }
    
    public void makePostCallout(string accessToken, list<product2> prdlist){
        system.debug('a:: '+accessToken);
        Rest_GetUploadDetails RU = new Rest_GetUploadDetails();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(System.Label.OCI_API_URL+'/inventory/impex/'+System.Label.OCI_API_Version+'/organizations/'+System.Label.OCI_Tenant_Group_ID+'/availability-records/imports');
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json');
        
        string authorizationHeader = 'Bearer '+accessToken;
        system.debug('a ::'+authorizationHeader);
        request.setHeader('Authorization', authorizationHeader); 
        request.setBody('{"fileName": "omnitest.json","fileFormat": "JSON","linkDuration": 60}');
        System.debug('request to string :'+request.toString());
        System.debug('request header Content :'+request.getHeader('Content-Type'));
        System.debug('request header Authorization :'+request.getHeader('Authorization'));
        HttpResponse response = http.send(request);
        
        System.debug('FileStatus:'+response.getStatusCode());
        System.debug('FileBody:'+response.getBody());
        system.debug('::'+response.getStatus());
        if(response.getStatusCode() == 200){
            RU = (Rest_GetUploadDetails)JSON.deserialize(response.getBody(), Rest_GetUploadDetails.class);
            system.debug(RU);
            string getUploadLink = RU.uploadLink;
            string getImportStatusLink = RU.importStatusLink;
            
            if(getUploadLink != NULL){
                string prefixUploadLinkWithCommerceLink = system.Label.OCI_API_URL+getUploadLink;
                string prefixFileStatusLinkWithCommerceLink = system.Label.OCI_API_URL+getImportStatusLink;
                makePostCallformUpload(prefixUploadLinkWithCommerceLink,authorizationHeader,prdlist);
                makeGetStatusFileUpload(prefixFileStatusLinkWithCommerceLink,authorizationHeader);
                
            }
            
        }
        
    }
    
    Public void makePostCallformUpload(string getUploadLink, string authHeader,list<product2> prdlist){
        String fileName = 'omnitest.json';
        String boundary = 'ETG';
        // header
        String header = '--' + boundary + '\nContent-Disposition: form-data; name="file"; filename="' + fileName + '"\nContent-Type: multipart/form-data;'+'\nnon-svg='+True;
        String headerEncoded;
        do
        {
            header += ' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header + '\r\n\r\n'));
        }
        while(headerEncoded.endsWith('='));
        
        // body
        String footer = '--' + boundary + '--';
        String bodyEncoded = EncodingUtil.base64Encode(generateJsonMethod(prdlist));
        
        if (bodyEncoded.endsWith('==')) {
            bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length()-2) + '0K';
        }
        else if(bodyEncoded.endsWith('=')) {
            bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length()-1) + 'N';
            footer = '\n' + footer;           
        }
        else{
            footer = '\r\n' + footer;
        }
        
        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
        Blob bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
        System.debug('bodyBlob.size()' + bodyBlob.size());
        
        String targetURL = getUploadLink ;
        string authorizationHeader = authHeader;
        //system.debug('fileName :: '+fileName);
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', authorizationHeader); 
        req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
        req.setMethod('POST');
        req.setEndpoint(targetURL);
        req.setBodyAsBlob(bodyBlob);
        req.setHeader('Content-Length', String.valueof(req.getBodyAsBlob().size()));
        //system.debug('req :: '+req.getBody());
        system.debug('req url :: '+req.getEndpoint());
        Http http = new Http();
        
        HttpResponse response = http.send(req);
        System.debug('status Code:: '+response.getStatusCode());
        System.debug('res Body : '+response.getBody());
    }
    
    Public void makeGetStatusFileUpload(string getFileStatusLink, string authHeader){
        String targetURL = getFileStatusLink ;
        String separationString = 'ETG';
        string authorizationHeader = authHeader;
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', authorizationHeader); 
        req.setMethod('GET');
        req.setEndpoint(targetURL);
        //system.debug('req :: '+req.getBody());
        system.debug('req url :: '+req.getEndpoint());
        Http http = new Http();
        
        HttpResponse response = http.send(req);
        System.debug('status Code:: '+response.getStatusCode());
        System.debug('res Body : '+response.getBody());
        
        
        
       }
    
    
    
    public static String getUUID()
    {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        //system.debug(guid);
        return guid;
    }
    
    
    public Blob generateJsonMethod(list<product2> prdlist){
        JSONGenerator gen = JSON.createGenerator(true);
        for( Product2 prd : prdlist){
                                 if(prd.name == '6544BS'){
                                     system.debug('prd -->'+prd);
                                 }
                                 gen.writeStartObject();
                                 if(prd.Location_external_name__c != NULL){
                                     gen.writeStringField('location', prd.Location_external_name__c);
                                 }
                                 gen.writeStringField('mode', 'UPDATE');
                                 gen.writeEndObject();
                                 gen.writeStartObject();
                                 string uuid = getUUID();
                                 if(uuid != NULL){
                                     gen.writeStringField('recordId',uuid);
                                 }
                                 if(prd.QOH__c != NULL){
                                     gen.writeNumberField('onHand', prd.QOH__c);
                                 }
                                 if(prd.StockKeepingUnit != NULL){
                                     gen.writeStringField('sku', string.valueOf(prd.StockKeepingUnit));
                                 }
                                 gen.writeDateTimeField('effectiveDate', system.now());
                                 gen.writeEndObject();
                             }
        
        String jsonData = gen.getAsString();
        jsonData = jsonData.replace(' ', '');
        jsonData = jsonData.replace('\n','');
       // System.debug('jsonData::' + jsonData);
        jsonData = jsonData.replace('}{','}\n{');        
       // System.debug('jsonData**' + jsonData);
        
        //Blob body = blob.valueOf(jsonData);
        return blob.valueOf(jsonData);
    }
}