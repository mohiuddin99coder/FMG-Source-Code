public without sharing class UpdateAccountFromJewelryForm {
    @AuraEnabled
    public static Id updateAccountInfo(String recordId, String website, String street, string company, String city, string country,string countryLabel,string state, string stateLabel,string zip, String phone, string twitter, string pinterest, string instagram, string facebook) {
    try {
        // Retrieve the Case record and check if it's associated with an Account
        Case myCase = [SELECT AccountId FROM Case WHERE Id = :recordId LIMIT 1];
        
        if (myCase != null && myCase.AccountId != null) {
            // Retrieve the associated Account record
            Account myAccount = [SELECT Id, Website, ShippingStreet,ShippingCity,ShippingPostalCode,ShippingCountry,ShippingCountryCode,ShippingState,ShippingStateCode,CompanyName__c  FROM Account WHERE Id = :myCase.AccountId LIMIT 1];
            
            if (myAccount != null) {
                if(!String.isBlank(website)){
                    myAccount.Website = website;
                }
                if(!String.isBlank(company)){
                    myAccount.CompanyName__c=company;
                }
                myAccount.ShippingStreet=street;
                myAccount.ShippingCity=city;
                myAccount.ShippingCountryCode = country;
                myAccount.ShippingStateCode = state;
                /*//if (!String.isBlank(country)) {
                    myAccount.ShippingCountry = countryLabel;
                    myAccount.ShippingCountryCode = country;
                //}
                    myAccount.ShippingState = stateLabel;
                    myAccount.ShippingStateCode = state;*/
                //myAccount.ShippingCountryCode=country;
                //myAccount.ShippingCountry=countryLabel;
                //myAccount.ShippingState=state;
                //myAccount.ShippingState=state;
                myAccount.ShippingPostalCode=zip;
                //myAccount.Phone=phone;
                update myAccount;
            }
            
        }
        /*List<String> urlList=new List<String>();
        urlList.add(twitter);
        urlList.add(pinterest);
        urlList.add(instagram);
        urlList.add(facebook);
        UpdateAccountFromJewelryForm.insertUrlList(urlList, myCase.AccountId);*/

        Map<String, String> urlMap = new Map<String, String>();
            urlMap.put('twitter', twitter);
            urlMap.put('pinterest', pinterest);
            urlMap.put('instagram', instagram);
            urlMap.put('facebook', facebook);
            UpdateAccountFromJewelryForm.upsertUrlList(urlMap, myCase.AccountId);
        
    } catch (Exception e) {
        // Handle any exceptions that might occur during the process
        System.debug('Error updating Account website: ' + e.getMessage());
    }
    return recordId;
}


public static void upsertUrlList(Map<String, String> urlMap, Id AccId) {
    List<URL__c> existingUrls = [SELECT Id, Title__c FROM URL__c WHERE Customer__c = :AccId];

    List<URL__c> urlList = new List<URL__c>();
    for (String urlTitle : urlMap.keySet()) {
        String urlValue = urlMap.get(urlTitle);

        // Check if an existing record with the same title exists
        URL__c existingUrl = findUrlByTitle(existingUrls, urlTitle);
        if (existingUrl != null) {
            // If an existing record is found, update it
            if (!String.isBlank(urlValue)) {
            existingUrl.URL__c = urlValue;
            urlList.add(existingUrl);
            }
        } else {
            // If no existing record found, create a new one
            if (!String.isBlank(urlValue)) {
                URL__c newUrl = new URL__c();
                newUrl.Title__c = urlTitle;
                newUrl.URL__c = urlValue;
                newUrl.Customer__c = AccId;
                urlList.add(newUrl);
            }
        }
    }
    if (!urlList.isEmpty()) {
        upsert urlList;
    }
}

// Helper method to find the URL__c record by title from the existingUrls list
private static URL__c findUrlByTitle(List<URL__c> urlList, String title) {
    for (URL__c url : urlList) {
        if (url.Title__c.equalsIgnoreCase(title)) {
            return url;
        }
    }
    return null;
}
/*public static void  insertUrlList(List<String> urlList, Id AccId){
    List<URL__c> listofURL=new List<URL__c>();
    for (String url : urlList) {
        if(!String.isBlank(url)){
            URL__c profileURL=new URL__c();
            profileURL.URL__c=url;
            profileURL.Customer__c=AccId;
            listofURL.add(profileURL);
        }
    }
    insert listofURL;
}*/
}