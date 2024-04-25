public class CustomerAddressTriggerHandler {
    
    public static B2C_AuthToken__c isActiveAuthTokenAvailable(){
        B2C_AuthToken__c activeAuth;
        for(B2C_AuthToken__c record: [SELECT Id,B2C_Client_ID__c,Is_Valid__c,Is_Expired__c,Is_Invalidated__c,B2C_AuthToken__c  FROM B2C_AuthToken__c where Is_Valid__c=true and Is_Expired__c=false and Is_Invalidated__c=false]) {
            activeAuth = record;
        }
        return activeAuth;
    }
    public static String generateAccessToken(){
        Map<String, String> accountManagerConfigSettings;
        String authUrl;
        String audienceUrl;
        String jwt;
        String accessToken;
        JSONParse parsedJSON;
        
        accountManagerConfigSettings = B2CConfigurationManager.getAccountManagerSettings();
        
        B2C_CustomerList__c b2cCustomerList = [SELECT JWT_Certificate_Name__c, API_Url__c, B2C_Instance__c, Id, Name, B2C_Client_ID_Value__c FROM B2C_CustomerList__c where Name='FireMountainGems' LIMIT 1];
        
        
        // Build out the audience and authentication urls
        audienceUrl = accountManagerConfigSettings.get('AccountManagerUrl') + ':' +
            accountManagerConfigSettings.get('AccountManagerPort') +
            accountManagerConfigSettings.get('AccountManagerSuffix');
        
        // Build out the authenticationUrl
        authUrl = accountManagerConfigSettings.get('AccountManagerUrl') +
            accountManagerConfigSettings.get('AccountManagerSuffix');
        
        
        B2C_AuthToken__c authToken = CustomerAddressTriggerHandler.isActiveAuthTokenAvailable();
        if(authToken!=null){
            accessToken = authToken.B2C_AuthToken__c;
            System.debug('accesstoken is : '+accessToken);
            return accessToken;
            
        }else{
            
            jwt = B2CJWTHelper.getJWT(
                accountManagerConfigSettings.get('JWTSFCCAlgorithm'),
                accountManagerConfigSettings.get('JWTSFDCAlgorithm'),
                b2cCustomerList.B2C_Client_ID_Value__c,
                b2cCustomerList.JWT_Certificate_Name__c,
                audienceUrl,
                Integer.valueOf(accountManagerConfigSettings.get('ExpirationInMinutes'))
            );
            
            System.debug('jwt is : '+jwt);
            // Create the AccountManager authRequest -- and include the minted JWT
            HttpRequest req = B2CHttpRequestHelper.getAccountManagerAuthRequest(authUrl, jwt);
            accessToken = makeAuthHttpCallout(req);            
            // Initialize the http request and process-it
            
            return accessToken;
        }
    }
    
    public static String makeAuthHttpCallout(HttpRequest req){
        String accessToken;
        JSONParse parsedJSON;
        Http https = new Http();
        HttpResponse res = https.send(req);
        
        // Parse the JSON so that we can format the body content
        parsedJSON = new JSONParse(res.getBody());
        if(res.getStatusCode() == 200){
            System.debug('inside response');
            accessToken = parsedJSON.get('access_token').getStringValue();
        }else{
            System.debug('Authentication Exception :' +res.getBody());
        }
        return accessToken;
    }
    
    public static Map<Id, Account> getAccountMap(List<ID> accIdList){
        return new Map<Id, Account>([SELECT Id, B2C_Customer_No__pc,FirstName,LastName FROM Account WHERE Id IN : accIdList]);
    }
    
    public static B2C_CRM_Sync_BM_Setting__mdt getB2CCRMBMSettingmdt(){
        return [select id,BM_Endpiont_URL__c from B2C_CRM_Sync_BM_Setting__mdt where MasterLabel='BM EndPoint Settings' LIMIT 1];
    }
    public static void sendCustomerAddressCreateRequest(List<Customer_Address__c> customerAddresses,List<ID> accIdList){
        String accessToken;
        B2C_CRM_Sync_BM_Setting__mdt bmSettings = getB2CCRMBMSettingmdt();
        String EndpointUrl = bmSettings.BM_Endpiont_URL__c;
        Map<Id, Account> objMap = getAccountMap(accIdList);
        
        for(Customer_Address__c customerAddress : customerAddresses){
            String customerNumber=objMap.get(customerAddress.ParentId__c).B2C_Customer_No__pc;
            System.debug('customerAddress is : '+customerAddress);
            System.debug('Parent is : '+customerAddress.ParentId__c);
            System.debug('customerNumber is : '+customerNumber);
            String updatedUrl = EndpointUrl+'/'+ customerNumber +'/addresses';
            System.debug('updatedUrl is : '+updatedUrl);
            String jsonString = jsonRequestBody(customerAddress,objMap.get(customerAddress.ParentId__c).FirstName,objMap.get(customerAddress.ParentId__c).LastName);
            sendCustomerAddressRequest(updatedUrl,jsonString,'POST');
        }
    }
    
    public static void sendCustomerAddressUpdateRequest(List<Customer_Address__c> customerAddresses,List<ID> accIdList){
        String accessToken;
        B2C_CRM_Sync_BM_Setting__mdt bmSettings = getB2CCRMBMSettingmdt();
        String EndpointUrl = bmSettings.BM_Endpiont_URL__c;
        Map<Id, Account> objMap = getAccountMap(accIdList);
        for(Customer_Address__c customerAddress : customerAddresses){
            String customerNumber=objMap.get(customerAddress.ParentId__c).B2C_Customer_No__pc;
            System.debug('customerAddress is : '+customerAddress);
            System.debug('Parent is : '+customerAddress.ParentId__c);
            System.debug('customerNumber is : '+customerNumber);
            String name = EncodingUtil.URLENCODE(customerAddress.Name,'UTF-8').replace('+', '%20');
            String updatedUrl = EndpointUrl+'/'+ customerNumber +'/addresses/'+name;
            System.debug('updatedUrl is : '+updatedUrl);
            String jsonString = jsonRequestBody(customerAddress,objMap.get(customerAddress.ParentId__c).FirstName,objMap.get(customerAddress.ParentId__c).LastName);
            sendCustomerAddressRequest(updatedUrl,jsonString,'PATCH');
            
        }
    }
    
    public static String jsonRequestBody(Customer_Address__c customerAddress,String firstName,String lastName){
        CustomerAddressRequestWrapper custReq = new CustomerAddressRequestWrapper();
        custReq.address_id=customerAddress.Name;
        system.debug('customerAddress.Id >>>'+customerAddress.Id);
        custReq.c_b2ccrm_addressId= customerAddress.id;
        custReq.address1=customerAddress.Address__Street__s;
        custReq.city = customerAddress.Address__City__s;
        custReq.country_code=customerAddress.Address__CountryCode__s;
        custReq.first_name = firstName;
        custReq.last_name = lastName;
        custReq.postal_code = customerAddress.Address__PostalCode__s;
        custReq.state_code = customerAddress.Address__StateCode__s;
        String jsonString = JSON.serialize(custReq);
        System.debug('Json String is : '+jsonString);
        return jsonString;
    }
    
    public static void sendCustomerAddressRequest(String updatedUrl,String jsonString,String method){
        String accessToken = generateAccessToken();
        Http https = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(updatedUrl);
        req.setMethod(method);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setBody(jsonString);
        
        System.debug('json String is : '+jsonString); 
        HttpResponse res = https.send(req);
        if(res.getStatusCode() == 200){
            System.debug('Customer Address Create or Update is Successful');
            
        }else{
            System.debug('Callout Exception :' +res.getBody());
            System.debug('response status code : '+res.getStatusCode());
        }
    }
    
    public static void checkDuplicateAddress(List<Customer_Address__c> customerAddresses,List<ID> accList){
        Map<ID,List<String>> accAddressMap = getAccountAddressMap(accList);
        for(Customer_Address__c custAddress : customerAddresses){
            List<String> addressNames = accAddressMap.get(custAddress.ParentId__c);
            if(addressNames!=null && addressNames.contains(custAddress.Name)){
                custAddress.Name.addError('An address already exists with this name.');
            }
        } 
    }
    
    public static Map<ID,List<String>> getAccountAddressMap(List<ID> accList){
        Map<ID,List<String>> accAddressMap = new Map<ID, List<String>>();
        List<Customer_Address__c> customerAddressList = [select id,ParentId__c,Name from Customer_Address__c where ParentId__c IN :accList];
        for(Customer_Address__c customerAddress : customerAddressList){
            if(!accAddressMap.containskey(customerAddress.ParentId__c)){
                accAddressMap.put(customerAddress.ParentId__c, new List<String>{customerAddress.Name});
            }else{
                List<String> addressNames = accAddressMap.get(customerAddress.ParentId__c);
                addressNames.add(customerAddress.Name);
                accAddressMap.put(customerAddress.ParentId__c,addressNames);
            }
        }
        return accAddressMap;
        
    }
    
    public class CustomerAddressRequestWrapper{
        public String address1 {get;set;} 
        public String address2 {get;set;} 
        public String c_b2ccrm_addressId {get;set;}
        public String address_id {get;set;} 
        public String city {get;set;} 
        public String country_code {get;set;}
        public String first_name {get;set;} 
        public String full_name {get;set;} 
        public String last_name {get;set;}
        public String postal_code {get;set;} 
        public String state_code {get;set;} 
    }
}