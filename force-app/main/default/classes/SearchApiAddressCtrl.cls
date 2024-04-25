public class SearchApiAddressCtrl {
    @AuraEnabled
    Public Static list<SuggestionWrapper> getAddress(String searchString){
        if(String.isNotBlank(searchString)){
            List<SuggestionWrapper> suggestions=new List<SuggestionWrapper>();
            searchString = EncodingUtil.urlEncode(searchString, 'UTF-8');
            Http http = new Http();
            HttpRequest Request = new HttpRequest();
            Request.setMethod('GET');
            //Request.setEndPoint('https://maps.googleapis.com/maps/api/place/autocomplete/json?input='+searchString+'&key=AIzaSyCBhTrQNiISPeCjUIwlLn_ZlN-M9yunoUI');
            Request.setEndPoint('https://maps.googleapis.com/maps/api/place/autocomplete/json?input='+searchString+'&key=AIzaSyBzxA2B1QIRoAwpMmoR72KCDQNh_kLI5pY');
           // Request.setEndpoint('https://api.opencagedata.com/geocode/v1/json?q=URI-ENCODED-PLACENAME&key=b6ed6f97e9314a38b1f9e5efa4d9834b');
            HttpResponse Response = http.send(Request);
            if(Response.getStatusCode()==200){
                JSON2ApexSuggestion Json2Apex= parseSuggestion(Response.getbody());
                string CompleteAddress = '';
                List<String> completeaddressList = new List<String>();
                system.debug('Response.getbody() >>>'+Response.getbody());
                if(Json2Apex.predictions != null){
                    for(JSON2ApexSuggestion.predictions Prediction : Json2Apex.predictions){
                        if(string.isNotBlank(Prediction.description)){
                            CompleteAddress = Prediction.description;
                            CompleteAddress = CompleteAddress.replaceAll(',', ' ');
                            suggestions.add(new SuggestionWrapper(CompleteAddress,Prediction.place_id));
                        }
                    }
                }
                return suggestions;  
            }
             
        }
        return null;
    }
     
    @AuraEnabled
    public static string getPlaceDetails(String placeId) {
        if(String.isNotBlank(placeId)){
            String strURL = 'https://maps.googleapis.com/maps/api/place/details/json?'
                + 'placeid=' + EncodingUtil.urlEncode(placeId, 'UTF-8')
                + '&key=AIzaSyBzxA2B1QIRoAwpMmoR72KCDQNh_kLI5pY'; 
           // String strURL ='https://api.opencagedata.com/geocode/v1/json?q=URI-ENCODED-PLACENAME&key=b6ed6f97e9314a38b1f9e5efa4d9834b';
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            req.setMethod('GET');
            req.setEndpoint(strURL);
            req.setTimeout(120000);
            res = h.send(req); 
            String responseBody = res.getBody(); 
            system.debug('responseBody---'+responseBody);
           // system.debug('responseBody---'+responseBody.address_components);
            return responseBody; 
        }else{
            return null;
        }
         
    }
     
    public class SuggestionWrapper{
        @AuraEnabled
        public String AddComplete{get;set;}
        @AuraEnabled
        public String placeId{get;set;}
         
        public SuggestionWrapper(string AddComplete,String placeId){
            this.AddComplete = AddComplete;
            this.placeId = placeId;
        }
    }        
         
    public static JSON2ApexSuggestion parseSuggestion(String json) {
        return (JSON2ApexSuggestion) System.JSON.deserialize(json, JSON2ApexSuggestion.class);
    }
}