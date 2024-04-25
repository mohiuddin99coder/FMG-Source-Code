/**
 * Created by inscorea on 4/8/2024.
 */

@IsTest
private class fmg_temp_order_summery_creation_test {
    @IsTest(SeeAllData=true)
    static void executionTest() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/tempfmgApi/orderSummeryMassCreate'; //Request URL
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response= res;

        List<String> orders = new List<String>();

        // These are invalid Id's to prevent creation of an actual order Summery
        orders.add('NonErrorPath');
        orders.add('ErrorPath');

        Test.startTest();
        List<fmg_temp_order_summery_creation.OrderOutput> results = (List<fmg_temp_order_summery_creation.OrderOutput>)fmg_temp_order_summery_creation.doPost(orders);
        Test.stopTest();

        System.assertEquals(2,results.size());
        System.assertEquals('UNMANAGED',results.get(0).orderLifeCycleType);
        System.assertEquals('Fulfilled',results.get(0).status);
    }
}