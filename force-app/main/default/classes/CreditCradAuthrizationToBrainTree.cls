/**************************************
* Class Name   :  CreditCradAuthrizationToBrainTree
* Description  :  This apex class is used to integrate with brain tree from salesforce for opportunity payment.
* Created date :  20/05/2023
* Created by   :  ETG
* 
* **************************************/

global class CreditCradAuthrizationToBrainTree {
    
    @AuraEnabled
    public static ResponseWrapper authrizeCreditCardInfo(Map<String,Object> creditCardData){
        ResponseWrapper resWrapper;
        string finalMessage = '';
        String cardHoldername='';
        String creditCardNumber='';
        String expirationMonth='';
        String expirationYear ='';
        String cvv='';
        Decimal amount= 0;
        string recordId ='';
        Map<String,String> creditCardReposneData = new Map<String,String>();
        system.debug('creditCardData'+creditCardData);
        if(!creditCardData.isempty() && creditCardData != NULL){
            if(creditCardData.get('cardholderName') != NULL ){
                cardHoldername = string.valueOf(creditCardData.get('cardholderName'));
                creditCardReposneData.put('cardholderName',cardHoldername);
            }
            if(creditCardData.get('cardNumber') != NULL ){
                creditCardNumber = string.valueOf(creditCardData.get('cardNumber'));
                creditCardReposneData.put('creditCardNumber',creditCardNumber);
            }
            if(creditCardData.get('expirationMonth') != NULL ){
                expirationMonth = string.valueOf(creditCardData.get('expirationMonth'));
            }
            if(creditCardData.get('expirationYear') != NULL ){
                expirationYear = string.valueOf(creditCardData.get('expirationYear'));
            }
            if(creditCardData.get('cvv') != NULL ){
                cvv = string.valueOf(creditCardData.get('cvv'));
            }
            if(creditCardData.get('advanceAmount') != NULL ){
                expirationYear = string.valueOf(creditCardData.get('expirationYear'));
                String str= String.valueOf(creditCardData.get('advanceAmount'));
                amount   = Decimal.valueOf(str);
            }
            if(creditCardData.get('recordId') != NULL ){
                recordId = string.valueOf(creditCardData.get('recordId'));
            }
            
        }
        
        /*if(Test.isRunningTest()) {
            Map<String,String> Headers = new Map<String, String>();
            Headers.put('Content-Type', 'application/json');
            String tokenizeBody = '{"data":{"tokenizeCreditCard":{"paymentMethod":{"id":"tokencc_bh_bfp2jc_dm8ytm_tvr3kc_wjh4pm_3j7","details":{"brandCode":"VISA","last4":"1111","expirationMonth":"02","expirationYear":"24"}}}},"extensions":{"requestId":"a5d7305e-e2e1-4626-9d3b-c63da51f63d8"}}';
            SingleRequestMock fakeTokenizeCreditCardResp = new SingleRequestMock(200,tokenizeBody,Headers);
            Test.setMock(HttpCalloutMock.class, fakeTokenizeCreditCardResp );
        }*/
        
        try{
            
            BrainTree_API__mdt md= BrainTree_API__mdt.getInstance(FMG_StaticConstant.BrainTreeMetadataName);
            //List<BraintreeTransaction> settledTransactions = md.fetchSettledTransactions();
            System.debug('md.EndPoint_URL__c: '+md.EndPoint_URL__c);
            System.debug('md.PrivateKey__c: '+md.PrivateKey__c);
            System.debug('md.PublicKey__c: '+md.PublicKey__c);
            System.debug('md.Method_Name__c: '+ md.Method_Name__c);
            System.debug('md.Content_Type__c: '+md.Content_Type__c);
            System.debug('md.Braintree_Version__c: '+ md.Braintree_Version__c);
            System.debug('amount: ' + amount);
            
            
            
            HttpRequest req = new HttpRequest();
            String braintreePublicKey = md.PublicKey__c;
            String braintreePrivateKey =md.PrivateKey__c; 
            // String requestBody = '{ "query" : "mutation TokenizeCreditCard($input:TokenizeCreditCardInput!){ tokenizeCreditCard(input:$input){ paymentMethod{ id details { ... on CreditCardDetails{ brandCode last4 expirationMonth expirationYear}} } } }","variables":{ "input":{ "creditCard": { "number":"4111111111111111","expirationMonth":"02","expirationYear":"24","cvv":"abc","cardholderName":"KrishnaCh" } } } }';
            String requestBody = '{ "query" : "mutation TokenizeCreditCard($input:TokenizeCreditCardInput!){ tokenizeCreditCard(input:$input){ paymentMethod{ id details { ... on CreditCardDetails{ brandCode last4 expirationMonth expirationYear}}} } }","variables":{ "input":{ "creditCard": {';
            requestBody = requestBody+ '"number":"'+creditCardNumber+'","expirationMonth":"'+expirationMonth+'","expirationYear":"'+expirationYear+'","cvv":"'+cvv+'","cardholderName":"'+cardHoldername+'"';
            requestBody = requestBody+ '} } } }';
            Blob headerValue = Blob.valueOf(braintreePublicKey + ':' + braintreePrivateKey);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            system.debug('auth-->'+authorizationHeader);
            
            
            req.setHeader('Authorization', authorizationHeader);
            req.setMethod(md.Method_Name__c);
            req.setEndpoint(md.EndPoint_URL__c);
            req.setHeader('Content-Type',md.Content_Type__c);
            req.setHeader('Braintree-Version', md.Braintree_Version__c);
            req.setBody(requestBody);
            system.debug('request-->'+req);
            system.debug('requestBody-->'+requestBody);
            HttpResponse response = new Http().send(req);
            System.debug('response.getStatusCode(): ' + response.getStatusCode());
            
            if(response.getStatusCode() == 200){
                
                resWrapper = (ResponseWrapper)JSON.deserialize(response.getBody(), ResponseWrapper.class);	
                system.debug('resWrapper'+resWrapper);
                if(resWrapper.errors != NULL){
                    //IsError = 'Error Occured';
                    if(resWrapper.errors.size() > 1){
                        system.debug('errors size==>'+resWrapper.errors.size());
                        system.debug('error message==>'+resWrapper.errors[1].message);
                        resWrapper = new ResponseWrapper(resWrapper.errors[1].message,'Payment Failed',null,null);
                        //finalMessage = resWrapper.message;
                    }
                    else if(resWrapper.errors.size()  == 1){
                        system.debug('error message==>'+resWrapper.errors[0].message);
                        resWrapper = new ResponseWrapper(resWrapper.errors[0].message,'Payment Failed',null,null);
                        //finalMessage = resWrapper.message;
                    }
                    
                }
                
                else{
                    if(resWrapper.Data != NULL){
                        String paymentMethodId =  resWrapper.Data.tokenizeCreditCard.paymentMethod.id;
                        system.debug('paymentMethodId==>'+paymentMethodId);
                        
                        creditCardReposneData.put('brandcode',resWrapper.Data.tokenizeCreditCard.paymentMethod.Details.brandCode); 
                        creditCardReposneData.put('last4',resWrapper.Data.tokenizeCreditCard.paymentMethod.Details.last4); 
                        creditCardReposneData.put('expirymonth',resWrapper.Data.tokenizeCreditCard.paymentMethod.Details.expirationMonth); 
                        creditCardReposneData.put('expiryyear',resWrapper.Data.tokenizeCreditCard.paymentMethod.Details.expirationYear); 
                        
                        
                        reswrapper = creditCardAutharization(paymentMethodId,amount,md,recordId,creditCardReposneData);
                        
                        // String trans = resWrapper.Data.chargeCreditCard.transactions.status;
                        //   system.debug('finalMessage1'+trans);
                    }
                    
                }
            }
            else{
                reswrapper = new ResponseWrapper(response.getStatus(),'Payment Failed',null,null);
                System.debug('reswrapper----->' + reswrapper);
                // finalMessage = response.getStatus();
            }
        }
        catch(exception ex){
            // reswrapper = new ResponseWrapper(response.getStatus(),'Payment Failed',null,null);
            // System.debug('reswrapper----->' + reswrapper);
            string errormsg =ex.getMessage();
            errormsg = errormsg+ex.getLineNumber();
            reswrapper = new ResponseWrapper(errormsg,'Payment Failed',null,null);
            //finalMessage = errormsg;
        }
        system.debug('response final'+reswrapper);
        if(reswrapper.message != NULL && !string.isBlank(reswrapper.message) && reswrapper.status != NULL  && recordId != NULL && !string.isBlank(recordId)){
            Opportunity opp =[select id,Payment_Status__c,Advance_Payment__c,Advance_Payment_Received__c,Amount from opportunity where Id =:recordId LIMIT 1];
            if(opp != NULL){
                opp.Payment_Status__c = reswrapper.message;
                system.debug('opp.Advance_Payment__c'+opp.Advance_Payment__c);
                system.debug('paid amount'+amount);
                system.debug('reswrapper.message' + reswrapper.message);
                if(FMG_StaticConstant.SuccessMessage.equalsIgnoreCase(reswrapper.status)){
                    if(reswrapper.status =='Success' && reswrapper.message == 'SUBMITTED_FOR_SETTLEMENT' ){
                        //(reswrapper.message != 'PROCESSOR_DECLINED'|| reswrapper.message != 'FAILED' || reswrapper.message !='AUTHORIZATION_EXPIRED' || reswrapper.message !='GATEWAY_REJECTED' || reswrapper.message !='SETTLEMENT_DECLINED' || reswrapper.message !='VOIDED')){
                        system.debug('resstatus' +reswrapper.status);
                        
                        
                        if(opp.Advance_Payment__c == NULL){
                            opp.Advance_Payment__c = amount;
                            
                        }
                        else{
                            opp.Advance_Payment__c = opp.Advance_Payment__c + amount;
                        }
                    }
                    /* else if(reswrapper.message =='PROCESSOR_DECLINED'){
opp.Advance_Payment__c = 0.00;
opp.Advance_Payment_Received__c = false;
system.debug('resMessage' +reswrapper.message);
system.debug('opp.Advance_Payment__c.' +opp.Advance_Payment__c);
}*/
                }
                
            }
            
            if(opp != NULL){
                update opp;
            }
        }
        system.debug('finalMessage before==>'+reswrapper);
        
        if(reswrapper != NULL){
            
        }
        return reswrapper;
        
    }
    
    public static ResponseWrapper creditCardAutharization(String paymentMethodId,Decimal amount,BrainTree_API__mdt mdt,string oppId,Map<String,String> creditCardReposneData){
        
        if(Test.isRunningTest()) {
            Map<String,String> Headers = new Map<String, String>();
            Headers.put('Content-Type', 'application/json');
            String chargeBody;
            /*if(IsError == 'Error Occured') {
                chargeBody = '{"errors": [{"message": "Validation error of type UnknownType: Unknown type chargePaymentMethod","locations": [{"line": 1,"column": 38}]}],"extensions": {"requestId": "e90c4384-ebbf-4b73-85e1-9e65613fd721"}}';
            } else {
                chargeBody = '{"data":{"chargePaymentMethod":{"transaction":{"id":"dHJhbnNhY3Rpb25fNGN0ZGY2MWo","status":"SUBMITTED_FOR_SETTLEMENT"}}},"extensions":{"requestId":"a1e9c0fe-71e0-4c82-b3ac-96de23dd3062"}}';
            }*/
            chargeBody = '{"data":{"chargePaymentMethod":{"transaction":{"id":"dHJhbnNhY3Rpb25fNGN0ZGY2MWo","status":"SUBMITTED_FOR_SETTLEMENT"}}},"extensions":{"requestId":"a1e9c0fe-71e0-4c82-b3ac-96de23dd3062"}}';
            SingleRequestMock fakeChargePaymentResp = new SingleRequestMock(200,chargeBody,Headers);
            Test.setMock(HttpCalloutMock.class, fakeChargePaymentResp);
            
        }
        
        ResponseWrapper res;
        String message='';
        String sfReferenceId='';
        String transactionId = '';
        String requestBody ='';
        String responseBody ='';
        String legacyId='';
        Map<String,String> staticData =new Map<String,String>();
        staticData.put('Amount', string.valueOf(amount));
        staticData.put('opportunityId', oppId);
        
        if(paymentMethodId != NULL && !string.isBlank(paymentMethodId)){
            try{
                
                HttpRequest req = new HttpRequest();
                String braintreePublicKey = mdt.PublicKey__c;
                String braintreePrivateKey = mdt.PrivateKey__c; 
                
                System.debug('md.EndPoint_URL__c: '+mdt.EndPoint_URL__c);
                System.debug('md.PrivateKey__c: '+mdt.PrivateKey__c);
                System.debug('md.PublicKey__c: '+mdt.PublicKey__c);
                System.debug('md.Method_Name__c: '+ mdt.Method_Name__c);
                System.debug('md.Content_Type__c: '+mdt.Content_Type__c);
                System.debug('md.Braintree_Version__c: '+ mdt.Braintree_Version__c);
                System.debug('amount: ' + amount);
                
                //requestBody = '{ "query": "mutation ChargeCreditCard($input:ChargeCreditCardInput!) { chargeCreditCard(input:$input){ transaction { status id legacyId createdAt amount { value currencyCode} paymentMethodSnapshot {__typename } paymentMethod {id legacyId details {__typename }} merchantId merchantAccountId orderId purchaseOrderNumber channel source customer {id} } } }","variables": {"input":{"paymentMethodId":';
                requestBody = '{ "query": "mutation chargePaymentMethod($input:ChargePaymentMethodInput!) { chargePaymentMethod(input:$input){ transaction { status id legacyId createdAt amount { value currencyCode} paymentMethodSnapshot {__typename  ... on CreditCardDetails {brandCode last4  expirationMonth expirationYear cardholderName} } paymentMethod {id legacyId  details { ... on CreditCardDetails {brandCode bin last4 expirationMonth expirationYear cardholderName }}} merchantId merchantAccountId orderId purchaseOrderNumber channel source customer {id} } } }","variables": {"input":{"paymentMethodId":';
                system.debug('paymentMethodId==>'+paymentMethodId);
                string methodId = '"'+paymentMethodId+'"';
                requestBody = requestBody+ methodId + ',"transaction":{"amount":"'+amount+'"}}}}';
                //requestBody = requestBody+ methodId + ',"options":{"billingAddress":{"addressLine1":"123MainSt","adminArea1":"CA","adminArea2":"SanJose","postalCode":"95086"}},"transaction":{"amount":"1.00"}}}}';
                
                system.debug('requestBody-->'+requestBody);
                Blob headerValue = Blob.valueOf(braintreePublicKey + ':' + braintreePrivateKey);
                String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                system.debug('auth-->'+authorizationHeader);
                
                req.setHeader('Authorization', authorizationHeader);
                req.setMethod(mdt.Method_Name__c);
                req.setEndpoint(mdt.EndPoint_URL__c);
                req.setHeader('Content-Type',mdt.Content_Type__c);
                req.setHeader('Braintree-Version', mdt.Braintree_Version__c);
                req.setBody(requestBody);
                HttpResponse response = new Http().send(req);
                responseBody = response.getBody();
                
                if(response.getStatusCode() == 200){
                    system.debug('response body-->'+response.getBody());
                    res = (ResponseWrapper)JSON.deserialize(response.getBody(), ResponseWrapper.class);
                    
                    if( res.data == null && res.errors.size() >= 1){
                        res = new ResponseWrapper(res.errors[0].message,FMG_StaticConstant.FailedMessage,null,null); 
                        
                    }
                    else if(res.data != null){
                        res = (ResponseWrapper)JSON.deserialize(response.getBody().replace('"transaction":', '"transaction_Z":'), ResponseWrapper.class);
                        
                        transactionId = res.Data.chargePaymentMethod.transaction_Z.id;
                        sfReferenceId = res.extensions.requestId;
                        legacyId = res.Data.chargePaymentMethod.transaction_Z.legacyId;
                        staticData.put('TransactionID', transactionId);
                        if(res.errors != NULL){
                            if(res.errors.size() > 1){
                                res = new ResponseWrapper(res.errors[1].message,FMG_StaticConstant.FailedMessage,null,null);
                            }
                            else if(res.errors.size()  == 1){
                                res = new ResponseWrapper(res.errors[0].message,FMG_StaticConstant.FailedMessage,null,null);
                            }
                        }
                        else{
                            message = res.Data.chargePaymentMethod.transaction_Z.status;
                            if(FMG_StaticConstant.GATEWAY_REJECTED.equalsIgnoreCase(message)){
                                res = new ResponseWrapper(message,FMG_StaticConstant.FailedMessage,null,null);
                            }
                            else{
                                res = new ResponseWrapper(message,FMG_StaticConstant.SuccessMessage,sfReferenceId,legacyId); 
                            }
                            
                        }
                    }
                    
                }
                else{
                    res = (ResponseWrapper)JSON.deserialize(response.getBody().replace('"transaction":', '"transaction_Z":'), ResponseWrapper.class);
                    message = res.Data.chargePaymentMethod.transaction_Z.status;
                    res = new ResponseWrapper(message,FMG_StaticConstant.FailedMessage,null,null);
                }
                
                
            }
            catch(exception ex){
                string errormsg =ex.getMessage();
                errormsg = errormsg+ex.getLineNumber();
                res = new ResponseWrapper(errormsg,FMG_StaticConstant.FailedMessage,null,null);
                System.debug('Exception: '+ res);
            }
        }
        createPayementTranscationsLogs(requestBody,responseBody,res,staticData,creditCardReposneData);
        
        return res;
        
    }
    
    public class ResponseWrapper {
        @AuraEnabled
        public String message;
        @AuraEnabled
        public string status;
        @AuraEnabled
        public string sfRefNumber;
        public string transactionId;
        public Data data;
        public extensions extensions;
        public List<cls_errors> errors;
        
        public ResponseWrapper(String message, string status,string sfRefNumber,string transactionId) {
            this.message = message;
            this.status = status;
            this.sfRefNumber = sfRefNumber;
            this.transactionId = transactionId;
        }
    }
    public class TokenizeCreditCard {
        public PaymentMethod paymentMethod;
    }
    public class cls_errors {
        public String message;
    }
    public class extensions {
        public String requestId;
    }
    
    public class PaymentMethod {
        public String id;
        public Details Details;
    }
    public class Details{
        public String brandCode;
        public String last4;
        public String expirationMonth;
        public String expirationYear;
        
    }
    
    public class Data {
        public TokenizeCreditCard tokenizeCreditCard;
        public chargePaymentMethod chargePaymentMethod;
    }
    
    public class chargePaymentMethod {
        public Transaction_Z transaction_Z {get;set;} // in json: transaction
        
    }
    public class Transaction_Z {
        public String status {get;set;} 
        public String id {get;set;} 
        public String legacyId {get;set;} 
        public Transaction_Z(string status,string id, string legacyId){
            this.status = status;
            this.id = id;
            this.legacyId = legacyId;
        }
    }
	
    //public static String IsError;
    
    public static void createPayementTranscationsLogs(String reqBody,String resBody,ResponseWrapper res,Map<String,String> staticData,Map<String,String> creditCardReposneData){
        system.debug('res==>'+res);
        List<Sobject> opptyRelatedObjs = new List<Sobject>();
        
        try{
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
            
            
            Opportunity_Payment_Summary__c oppPayment = new Opportunity_Payment_Summary__c();
            
            oppPayment.Authorization_Amount__c = Decimal.valueOf(staticData.get('Amount')) ;
            oppPayment.Type__c = creditCardReposneData.get('brandcode');
            oppPayment.Opportunity_Summary__c = staticData.get('opportunityId');
            oppPayment.Full_Name__c = creditCardReposneData.get('cardholderName');
            oppPayment.Name = oppPayment.Type__c + '-'+ creditCardReposneData.get('last4');
            oppPayment.Request__c = reqBody;
            oppPayment.Response__c = resBody;
            oppPayment.GatewayDate__c = system.now();
            oppPayment.Status__c = res.status;
            if(res.message == 'PROCESSOR_DECLINED' || res.message == 'FAILED' ){
                oppPayment.InteractionType__c = FMG_StaticConstant.InteractionType1;
            }
            else{
                oppPayment.InteractionType__c = FMG_StaticConstant.InteractionType;
            }
            //oppPayment.InteractionType__c = FMG_StaticConstant.InteractionType;
            oppPayment.Gateway_Message__c = FMG_StaticConstant.GatewayMessage;
            oppPayment.Gateway_Result_Code_Description__c =  res.message;
            oppPayment.GatewayReferenceNumber__c = staticData.get('TransactionID');
            oppPayment.Gateway_Result_Code__c = '200';
            oppPayment.GatewayResultCode__c ='200';
            oppPayment.SalesforceResultCode__c = res.status;
            oppPayment.Card_Type__c = creditCardReposneData.get('brandcode');
            oppPayment.Card_BIN__c =integer.valueOf(creditCardReposneData.get('last4'));
            oppPayment.Card_Category__c='Credit Card';
            oppPayment.Card_Holder_Name__c= creditCardReposneData.get('cardholderName');
            oppPayment.Card_Last_Four__c = integer.valueOf(creditCardReposneData.get('last4'));
            oppPayment.Last_Payment_Gateway_Message__c =res.message;
            oppPayment.Processing_Mode__c='Salesforce';
            oppPayment.Expiry_Month__c = integer.valueOf(creditCardReposneData.get('expirymonth'));
            oppPayment.Expiry_Year__c =integer.valueOf(creditCardReposneData.get('expiryyear'));
            oppPayment.Display_Card_Number__c =  'XXXX-XXXX-XXXX-' + creditCardReposneData.get('creditCardNumber').right(4); 
            oppPayment.transactionId__c =res.transactionId;
            
            system.debug('oppPayment==>'+oppPayment);
            
            opptyRelatedObjs.add(oppPayment);
            
            insert opptyRelatedObjs;
        }
        catch(exception ex){
            ResponseWrapper resp = new ResponseWrapper(ex.getMessage(),FMG_StaticConstant.FailedMessage,'','');   
        }
    }
    
}