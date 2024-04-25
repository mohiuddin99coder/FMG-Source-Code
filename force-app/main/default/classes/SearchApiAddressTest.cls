@isTest
public class SearchApiAddressTest{
    
    public static testmethod void testunit2(){
        Contact connew=new Contact();
        connew.LastName = 'TEstRec';
        connew.MailingCountry='United States';
        connew.MailingCity='Texas';
        connew.MailingState='California';
        connew.MailingPostalCode='123466';
            insert connew;
        
        string searchtext= '72OrangeStreet';
        string PlaceID= 'dsbfkfssk';
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SearchApiAddressCtrlTest());
        SearchApiAddressCtrl.getAddress(searchtext);
        SearchApiAddressCtrl.getPlaceDetails(PlaceID);
        test.stopTest();
        
    }
}