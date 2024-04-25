public class B2CPersonAccountTriggerHelper {
    
    public static void makeCustomerHttpCallout(ID id,String jsonReqBody,String recordTypeId){
        System.debug('inside future callout..');
        B2C_CRM_Sync_BM_Setting__mdt bmSettings = CustomerAddressTriggerHandler.getB2CCRMBMSettingmdt();
        String EndpointUrl = bmSettings.BM_Endpiont_URL__c;
        String accessToken = CustomerAddressTriggerHandler.generateAccessToken();
        CreateCustomerResponseWrapper responseWrap = new CreateCustomerResponseWrapper();
        Http https = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(EndpointUrl);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setHeader('Authorization', 'Bearer ' + accessToken); 
        req.setBody(jsonReqBody);
        HttpResponse res = https.send(req);
        System.debug('response body is : '+res.getBody());
        if(res.getStatusCode() == 200){
            System.debug('Success');
            responseWrap = (CreateCustomerResponseWrapper)Json.deserialize(res.getBody(), CreateCustomerResponseWrapper.class);
            System.debug('responseWrap is : '+responseWrap);
            if(!Test.isRunningTest() && recordTypeId != Label.Business_Account_RecordTypeID){
                Account ac = new Account();
                ac.id=id;
                ac.B2C_Customer_ID__pc = responseWrap.customer_id;
                ac.B2C_Customer_No__pc = responseWrap.customer_no;
                update ac;
            }
        }else{
            System.debug('Failed : '+res.getBody());
        }
        
    }
    
    public static void callQueueableClass(List<Account> accountList){
        System.enqueueJob(new SyncAccountsToCC(accountList));
    }
    
    public static void processAccounts(List<Account> accountList){
        List<Account> processList = new List<Account>();
        List<Account> businessAccList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        for(Account acc : accountList){
            System.debug('record type name is : '+acc.RecordType.Name);
            if(acc.RecordTypeId == Label.Business_Account_RecordTypeID){
                businessAccList.add(acc);
            }
        }
        System.debug('businessAccList is : '+businessAccList);
        if(accountList !=null){
            for(Account a : accountList){
                if(a.Type != 'Customer - Direct'){
                    processList.add(a);
                }
            }
        }
        System.debug('processList is : '+processList);
        System.debug('accountList is : '+accountList);
        for(Account ac : processList){
            makeCustomerHttpCallout(ac.Id,jsonRequestBody(ac),ac.RecordTypeId);
        }
    }
    
    public static void updateCustomerList(List<Account> accountList){
        B2C_CustomerList__c[] customerList = [SELECT Id, Name FROM B2C_CustomerList__c where Name='FireMountainGems' LIMIT 1];
        System.debug('customerList is : '+customerList);
        System.debug('accountList is  : '+accountList);
        for(Account acc : accountList){
            if(acc.B2C_CustomerList__pc==null && customerList.size()>0){
                acc.B2C_CustomerList__pc=customerList[0].Id;
            }
        }
    }
    
    public static String jsonRequestBody(Account account){
        System.debug('account is : '+account);
        
        Credentials creds = new Credentials();
        if(account.PersonEmail!=null){
            creds.login=account.PersonEmail;
        }else{
            creds.login=account.Email__c;
        }
        creds.enabled=true;
        CreateAccountWrapperClass accWrapper = new CreateAccountWrapperClass();
        if(account.PersonEmail!=null){
            accWrapper.email=account.PersonEmail;
        }else{
            accWrapper.email=account.Email__c;
        }
        accWrapper.first_name = account.FirstName;
        if(account.LastName!=null){
            accWrapper.last_name = account.LastName;
        }else{
            accWrapper.last_name = account.CompanyName__c;
            accWrapper.company_name = account.CompanyName__c;
        }
        if(account.CompanyName__c!=null){
            accWrapper.company_name = account.CompanyName__c;
        }
        if(account.RecordTypeId != Label.Business_Account_RecordTypeID){
            accWrapper.c_b2ccrm_accountId=account.Id;
        }
        accWrapper.c_b2ccrm_contactId=account.PersonContactId;
        accWrapper.phone_home=account.Phone;
        accWrapper.c_b2ccrm_sync_accountType=account.Type;
        accWrapper.c_b2ccrm_sync_discountLevel=account.Discount_Level__c;
        accWrapper.c_b2ccrm_gsk = account.GSK__c;
        accWrapper.c_b2ccrm_distributor = account.Distributor__c;
        accWrapper.c_b2ccrm_teacher = account.Teacher__c;
        accWrapper.c_b2ccrm_employee = account.Employee__c;
        accWrapper.c_b2ccrm_facility = account.Facility__c;
        accWrapper.c_b2ccrm_inmate = account.Inmate__c;
        accWrapper.c_b2ccrm_sync_platinumStatus = account.Platinum_Status__c;
        if(account.BirthMoDay__c!=null){
            String mmdd = account.BirthMoDay__c;
            String month = mmdd.substring(0, 2);
            String day = mmdd.substring(2, 4);
            Integer y = Date.Today().Year();
            String birthday = String.valueof(y)+'-'+month+'-'+day;
            System.debug('birthday is : '+birthday);
            accWrapper.birthday=birthday;
        }
        accWrapper.credentials=creds;
        System.debug('json is : '+JSON.serialize(accWrapper));
        return JSON.serialize(accWrapper);
    }
    
    public static void createCustomerAddressesForAccounts(List<Account> accountList){
        List<Customer_Address__c> customerList = new List<Customer_Address__c>();
        Map<ID,String> shippingCustomers = new Map<ID,String>();
        Map<ID,String> billingCustomers = new Map<ID,String>();
        List<ID> acIdList = new List<ID>();
        for(Account a : accountList){
            acIdList.add(a.Id);
        }
        System.debug('acList is : '+acIdList);
        customerList = [select id,Name,ParentId__c from Customer_Address__c where ParentId__c IN :acIdList];
        System.debug('customerList is @@@@### : '+customerList);
        if(customerList!=null && !customerList.isEmpty()){
            for(Customer_Address__c customer : customerList){
                if(customer.Name==Label.Shipping_Address){
                    System.debug('Updated inside if Shipping Address....');
                    shippingCustomers.put(customer.ParentId__c,Label.Shipping_Address);
                }else if(customer.Name==Label.Billing_Address){
                    System.debug('Updated inside Billing else Address....');
                    billingCustomers.put(customer.ParentId__c,Label.Billing_Address);
                }
            }
        }
        System.debug('Updated acIdList is : '+acIdList);
        System.debug('shippingCustomers map is : '+shippingCustomers);
        System.debug('billingCustomers map is : '+billingCustomers);
        List<Account> updateaccountList = [select id,BillingStreet,BillingCity,BillingStateCode,BillingPostalCode,BillingCountryCode,ShippingStreet,ShippingCity,ShippingStateCode,ShippingPostalCode,ShippingCountryCode from Account where ID IN :acIdList];
        System.debug('updateaccountList is : '+updateaccountList);
        List<Customer_Address__c> customerAddresses = new List<Customer_Address__c>();
        for(Account ac : updateaccountList){
            System.debug('account ac is : '+ac);
            System.debug('!billingCustomers.containsKey(ac.id) : '+!billingCustomers.containsKey(ac.id));
            System.debug('!shippingCustomers.containsKey(ac.id) : '+!shippingCustomers.containsKey(ac.id));
            if((ac.BillingStreet!=null || ac.BillingCity!=null || ac.BillingStateCode!=null || ac.BillingPostalCode!=null || ac.BillingCountryCode!=null) && !billingCustomers.containsKey(ac.id)){
                System.debug('inside billing Condition Check');
                Customer_Address__c billingAddress = new Customer_Address__c();
                billingAddress.Name=Label.Billing_Address;
                billingAddress.Address__Street__s  = ac.BillingStreet;
                billingAddress.Address__City__s = ac.BillingCity;
                billingAddress.Address__StateCode__s = ac.BillingStateCode;
                billingAddress.Address__PostalCode__s = ac.BillingPostalCode;
                billingAddress.Address__CountryCode__s = ac.BillingCountryCode;
                billingAddress.ParentId__c = ac.Id;
                customerAddresses.add(billingAddress);
            }
            if((ac.ShippingStreet!=null || ac.ShippingCity!=null || ac.ShippingStateCode!=null || ac.ShippingPostalCode!=null || ac.ShippingCountryCode!=null) && !shippingCustomers.containsKey(ac.id)){
                System.debug('inside Shipping Condition Check');
                Customer_Address__c shippingAddress = new Customer_Address__c();
                shippingAddress.Name=Label.Shipping_Address;
                shippingAddress.Address__Street__s  = ac.ShippingStreet;
                shippingAddress.Address__City__s = ac.ShippingCity;
                shippingAddress.Address__StateCode__s = ac.ShippingStateCode;
                shippingAddress.Address__PostalCode__s = ac.ShippingPostalCode;
                shippingAddress.Address__CountryCode__s = ac.ShippingCountryCode;
                ShippingAddress.ParentId__c = ac.Id;
                customerAddresses.add(shippingAddress);
            }
        }
        try{
            if(customerAddresses!=null && !customerAddresses.isEmpty()){
                insert customerAddresses;
            }
        }catch(Exception e){
            System.debug('An exception occurred: ' + e.getMessage());
        }
    }
    
    public static void updateRelatedCustomerAddresses(List<Account> triggerNew,List<Account> triggerOld){
        System.debug('updateRelatedCustomerAddresses executed.');
        List<Account> newPersonAccounts;
        List<Account> oldPersonAccounts;
        Account newPersonAccount;
        Account oldPersonAccount;
        newPersonAccounts = triggerNew;
        oldPersonAccounts = triggerOld;
        List<Account> CustomerAddressUpdate = new List<Account>();
        List<Account> CreateCustomerAddressForAccount = new List<Account>();
        List<ID> accIdList = new List<ID>();
        List<ID> acList = new List<ID>();
        List<Customer_Address__c> customerList = new List<Customer_Address__c>();
        Map<ID,String> shipCustomers = new Map<ID,String>();
        Map<ID,String> billCustomers = new Map<ID,String>();
        for(Account a : newPersonAccounts){
            acList.add(a.id);
        }
        System.debug('acList is : '+acList);
        customerList = [select id,Name,ParentId__c from Customer_Address__c where ParentId__c IN :acList];
        System.debug('customerList is @@@@ : '+customerList);
        if(customerList!=null && !customerList.isEmpty()){
            for(Customer_Address__c customer : customerList){
                if(customer.Name==Label.Shipping_Address){
                    System.debug('inside if Shipping Address....');
                    shipCustomers.put(customer.ParentId__c,Label.Shipping_Address);
                    
                }else if(customer.Name==Label.Billing_Address){
                    System.debug('inside Billing else Address....');
                    billCustomers.put(customer.ParentId__c,Label.Billing_Address);
                }
            }
        }
        List<Customer_Address__c> updateCustomerAddresses = new List<Customer_Address__c>();
        Map<ID,Account> accountMap = new Map<ID,Account>();
        for (Integer accountIndex = 0; accountIndex < newPersonAccounts.size(); accountIndex++) {
            System.debug('inside for loop....');              
            // Create a reference to the current new / old PersonAccount being processed
            newPersonAccount = newPersonAccounts.get(accountIndex);
            oldPersonAccount = oldPersonAccounts.get(accountIndex);
            //Shipping and Billing Address Update Checkbox
            System.debug('newPersonAccount.BillingStreet is : '+newPersonAccount.BillingStreet);
            System.debug('oldPersonAccount.BillingStreet is : '+oldPersonAccount.BillingStreet);
            System.debug('newPersonAccount.BillingCity is : '+newPersonAccount.BillingCity);
            System.debug('oldPersonAccount.BillingCity is : '+oldPersonAccount.BillingCity);
            System.debug('newPersonAccount.BillingStateCode is : '+newPersonAccount.BillingStateCode);
            System.debug('oldPersonAccount.BillingStateCode is : '+oldPersonAccount.BillingStateCode);
            System.debug('newPersonAccount.BillingPostalCode is : '+newPersonAccount.BillingPostalCode);
            System.debug('oldPersonAccount.BillingPostalCode is : '+oldPersonAccount.BillingPostalCode);
            System.debug('newPersonAccount.BillingCountryCode is : '+newPersonAccount.BillingCountryCode);
            System.debug('oldPersonAccount.BillingCountryCode is : '+oldPersonAccount.BillingCountryCode);
            
            System.debug('newPersonAccount.ShippingStreet is : '+newPersonAccount.ShippingStreet);
            System.debug('oldPersonAccount.ShippingStreet is : '+oldPersonAccount.ShippingStreet);
            System.debug('newPersonAccount.ShippingCity is : '+newPersonAccount.ShippingCity);
            System.debug('oldPersonAccount.ShippingCity is : '+oldPersonAccount.ShippingCity);
            System.debug('newPersonAccount.ShippingStateCode is : '+newPersonAccount.ShippingStateCode);
            System.debug('oldPersonAccount.ShippingStateCode is : '+oldPersonAccount.ShippingStateCode);
            System.debug('newPersonAccount.ShippingPostalCode is : '+newPersonAccount.ShippingPostalCode);
            System.debug('oldPersonAccount.ShippingPostalCode is : '+oldPersonAccount.ShippingPostalCode);
            System.debug('newPersonAccount.ShippingCountryCode is : '+newPersonAccount.ShippingCountryCode);
            System.debug('oldPersonAccount.ShippingCountryCode is : '+oldPersonAccount.ShippingCountryCode);
            if((newPersonAccount.BillingStreet!=oldPersonAccount.BillingStreet && oldPersonAccount.BillingStreet!=null) || (newPersonAccount.BillingCity!=oldPersonAccount.BillingCity && oldPersonAccount.BillingCity!=null) || (newPersonAccount.BillingStateCode!=oldPersonAccount.BillingStateCode && oldPersonAccount.BillingStateCode!=null) || (newPersonAccount.BillingPostalCode!=oldPersonAccount.BillingPostalCode && oldPersonAccount.BillingPostalCode!=null) || (newPersonAccount.BillingCountryCode!=oldPersonAccount.BillingCountryCode && oldPersonAccount.BillingCountryCode!=null)){
                System.debug('inside first update if condition');
                CustomerAddressUpdate.add(newPersonAccount);
                accIdList.add(newPersonAccount.Id);
                accountMap.put(newPersonAccount.Id,newPersonAccount);
            }
            if((newPersonAccount.ShippingStreet!=oldPersonAccount.ShippingStreet && oldPersonAccount.ShippingStreet!=null) || (newPersonAccount.ShippingCity!=oldPersonAccount.ShippingCity && oldPersonAccount.ShippingCity!=null) || (newPersonAccount.ShippingStateCode!=oldPersonAccount.ShippingStateCode && oldPersonAccount.ShippingStateCode!=null) || (newPersonAccount.ShippingPostalCode!=oldPersonAccount.ShippingPostalCode && oldPersonAccount.ShippingPostalCode!=null) || (newPersonAccount.ShippingCountryCode!=oldPersonAccount.ShippingCountryCode && oldPersonAccount.ShippingCountryCode!=null)){
                System.debug('inside second update if condition');
                CustomerAddressUpdate.add(newPersonAccount);
                accIdList.add(newPersonAccount.Id);
                accountMap.put(newPersonAccount.Id,newPersonAccount);
            } 
            if((newPersonAccount.BillingStreet!=null && oldPersonAccount.BillingStreet==null) && (newPersonAccount.BillingCity!=null && oldPersonAccount.BillingCity==null) && (newPersonAccount.BillingStateCode!=null && oldPersonAccount.BillingStateCode==null) && (newPersonAccount.BillingPostalCode!=null && oldPersonAccount.BillingPostalCode==null) && (newPersonAccount.BillingCountryCode!=null && oldPersonAccount.BillingCountryCode==null) && !billCustomers.containsKey(newPersonAccount.id)){
                System.debug('inside first create if condition');
                CreateCustomerAddressForAccount.add(newPersonAccount);
            }
            if((newPersonAccount.ShippingStreet!=null && oldPersonAccount.ShippingStreet==null) && (newPersonAccount.ShippingCity!=null && oldPersonAccount.ShippingCity==null) && (newPersonAccount.ShippingStateCode!=null && oldPersonAccount.ShippingStateCode==null) && (newPersonAccount.ShippingPostalCode!=null && oldPersonAccount.ShippingPostalCode==null) && (newPersonAccount.ShippingCountryCode!=null && oldPersonAccount.ShippingCountryCode==null) && !shipCustomers.containsKey(newPersonAccount.id)){
                System.debug('inside second create if condition');
                CreateCustomerAddressForAccount.add(newPersonAccount);
            }
        }
        if(CreateCustomerAddressForAccount!=null && !CreateCustomerAddressForAccount.isEmpty()){
            System.debug('CreateCustomerAddressForAccount is : '+CreateCustomerAddressForAccount);
            createCustomerAddressesForAccounts(CreateCustomerAddressForAccount);		
        }
        List<Customer_Address__c> customerAddressList = [select id,Name,Address__Street__s,Address__City__s,Address__CountryCode__s,Address__PostalCode__s,Address__StateCode__s,ParentId__c from Customer_Address__c where ParentId__c IN :accIdList];
        System.debug('customerAddressList is : '+customerAddressList);
        for(Customer_Address__c customerAddress : customerAddressList){
            if(accountMap.containsKey(customerAddress.ParentId__c)){
                Account ac = accountMap.get(customerAddress.ParentId__c);
                if(customerAddress.Name ==Label.Shipping_Address){
                    Customer_Address__c shipAddress  = new Customer_Address__c();
                    shipAddress.id = customerAddress.id;
                    shipAddress.Address__Street__s = ac.ShippingStreet;
                    shipAddress.Address__City__s = ac.ShippingCity;
                    shipAddress.Address__CountryCode__s = ac.ShippingCountryCode;
                    shipAddress.Address__PostalCode__s = ac.ShippingPostalCode;
                    shipAddress.Address__StateCode__s = ac.ShippingStateCode;
                    updateCustomerAddresses.add(shipAddress);
                }else if(customerAddress.Name ==Label.Billing_Address){
                    Customer_Address__c billAddress  = new Customer_Address__c();
                    billAddress.id = customerAddress.id;
                    billAddress.Address__Street__s = ac.BillingStreet;
                    billAddress.Address__City__s = ac.BillingCity;
                    billAddress.Address__CountryCode__s = ac.BillingCountryCode;
                    billAddress.Address__PostalCode__s = ac.BillingPostalCode;
                    billAddress.Address__StateCode__s = ac.BillingStateCode;
                    updateCustomerAddresses.add(billAddress);
                }
            }
        }
        System.debug('updateCustomerAddresses are :'+updateCustomerAddresses);
        try{
            if(updateCustomerAddresses!=null && !updateCustomerAddresses.isEmpty()){
                update updateCustomerAddresses;
            }
        }catch(exception e){
            System.debug('An exception occurred: ' + e.getMessage());
        }            
    }
    public class CreateAccountWrapperClass {
        
        public Credentials credentials;
        public String email;
        public String first_name;
        public String last_name;
        public String c_b2ccrm_accountId;
        public String c_b2ccrm_contactId;
        public String phone_home;
        public String c_b2ccrm_sync_accountType;
        public String c_b2ccrm_sync_discountLevel;
        public String birthday;
        public String company_name;
        public String c_b2ccrm_gsk;
        public Boolean c_b2ccrm_distributor;
        public Boolean c_b2ccrm_teacher;
        public Boolean c_b2ccrm_employee;
        public Boolean c_b2ccrm_facility;
        public Boolean c_b2ccrm_inmate;
        public String c_b2ccrm_sync_platinumStatus;
        
    }
    public class Credentials {
        public Boolean enabled;
        public String login;
    }
    public class CreateCustomerResponseWrapper{	
        public String creation_date;	
        public Credentials credentials;
        public String customer_id;	
        public String customer_no;	
        public String email;	
        public String first_name;	
        public String last_login_time;	
        public String last_modified;
        public String last_name;
        public String last_visit_time;	
        public String phone_home;
        public String previous_login_time;
        public String previous_visit_time;
        public String c_b2ccrm_accountId;
        public String c_b2ccrm_contactId;
        public List<String> c_b2ccrm_syncResponseText;
        public String c_b2ccrm_syncStatus;
        public String c_braintreeCustomerId;
        
    }
}