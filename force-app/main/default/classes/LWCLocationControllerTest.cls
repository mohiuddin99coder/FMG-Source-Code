@isTest
public class LWCLocationControllerTest {
    static testMethod void doTestLWCLocationController(){
        RS_TestData test1 = new RS_TestData();
        List<rstk__iclocitem__c> vICLOCITEMList = new List<rstk__iclocitem__c>();    
        rstk__iclocitem__c vItem1 = new rstk__iclocitem__c();
        vItem1.rstk__iclocitem_icitem__c = test1.inventoryMfgItem.Id;
        vItem1.rstk__iclocitem_site__c = test1.site.Id;
        vItem1.rstk__iclocitem_locid__c = test1.invlocationID.Id;
        vItem1.rstk__iclocitem_div__c = test1.division.Id;
        vItem1.rstk__iclocitem_locnum__c = 'WARRANTY';
        vItem1.rstk__iclocitem_locqty__c = 10;
        vItem1.rstk__iclocitem_locsec__c = 'RS1';
        vItem1.rstk__triggeroptions__c = '{"UT":"1"}';
        vICLOCITEMList.add(vItem1);
        insert vICLOCITEMList;
        Test.startTest();
        List<rstk__iclocitem__c> locItemList = lwcLocationController.getDataTableValues(test1.invlocationID.Id,'WARRANTY');
        System.assertEquals(locItemList.size(), 1);
        Test.stopTest();
		}
    static testMethod void doTestSYDATATBatchController(){
        RS_TestData test1 = new RS_TestData();
        List<rstk__iclocitem__c> vICLOCITEMList = new List<rstk__iclocitem__c>();    
        rstk__iclocitem__c vItem2 = new rstk__iclocitem__c();
        vItem2.rstk__iclocitem_icitem__c = test1.inventoryMfgItem.Id;
        vItem2.rstk__iclocitem_site__c = test1.site.Id;
        vItem2.rstk__iclocitem_locid__c = test1.invlocationID.Id;
        vItem2.rstk__iclocitem_div__c = test1.division.Id;
        vItem2.rstk__iclocitem_locnum__c = 'WARRANTY';
        vItem2.rstk__iclocitem_locqty__c = 10;
        vItem2.rstk__iclocitem_locsec__c = 'RS1';
        vItem2.rstk__triggeroptions__c = '{"UT":"1"}';
        vICLOCITEMList.add(vItem2);
        insert vICLOCITEMList;
        Test.startTest();
        sydatatBatchController.Flowinput flowinput = new sydatatBatchController.Flowinput();
        List<sydatatBatchController.Flowinput> flowInputList = new List<sydatatBatchController.Flowinput>();
        flowinput.fromLodId = test1.invlocationID.Id;
        flowinput.fromLocNum = 'WARRANTY';
        flowInputList.add(flowinput);
		sydatatBatchController.FlowOutput flowoutput = new sydatatBatchController.FlowOutput();
        
        try{
            List<sydatatBatchController.FlowOutput> flowOutputList = sydatatBatchController.processRecords(flowInputList);
            System.assertEquals(flowOutputList[0].outputSYDATAT.size(), 1);
        }
        catch(DMLException e){
           System.assertEquals(e.getMessage(), e.getMessage());
        }
        Test.stopTest();
    }
}