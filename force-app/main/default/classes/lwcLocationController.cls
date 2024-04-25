public with sharing class lwcLocationController {
    @AuraEnabled(cacheable = true)
    public static List<rstk__iclocitem__c> getDataTableValues(String passFromLocID, String passFromLocNo) {
        List<rstk__iclocitem__c> mylist = [Select Id, Name, rstk__iclocitem_icitem__c, rstk__iclocitem_icitem__r.Name,rstk__iclocitem_locqty__c, rstk__iclocitem_locid__c, rstk__iclocitem_locid__r.Name, rstk__iclocitem_locnum__c from rstk__iclocitem__c where rstk__iclocitem_locid__c=:passFromLocID and rstk__iclocitem_locnum__c=:passFromLocNo AND rstk__iclocitem_locqty__c>0 limit 500];
        return mylist;
	}
}