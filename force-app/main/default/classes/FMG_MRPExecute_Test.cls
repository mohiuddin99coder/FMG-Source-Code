/**
 * Created by inscorea on 1/17/2024.
 */

@IsTest
private class FMG_MRPExecute_Test {

    /**
     * @description Basic test for the MRP Execution
     **/
    @IsTest
    static void BasicMrpCreation_Success() {


        System.debug('creating test results object');

        FMG_MRPExecute.InputParameters inputData = new FMG_MRPExecute.InputParameters();

        inputData.NetChangeOption = false;
        inputData.DivisionId = 'a8fDK000000KysNYAS';
        inputData.MrpPlanOption = 'All Items';

        List<FMG_MRPExecute.InputParameters> inputDataList = new List<FMG_MRPExecute.InputParameters>();
        inputDataList.add(inputData);

        Map<String,Object> subResultTestData = new Map<String, Object>();
        subResultTestData.put('success','true');
        subResultTestData.put('message','Run MRP request has been submitted successfully');
        subResultTestData.put('mrplaunchId','a2lDI000000GuP4YAK');
        Map<String,Object> resultTestData = new Map<String, Object>();
        resultTestData.put('result',subResultTestData);
        resultTestData.put('success',true);
        FMG_MRPExecute.testResult = resultTestData;

        Test.startTest();
        List<FMG_MRPExecute.OutputParameters> outputParameters = FMG_MRPExecute.bulkInvoke(inputDataList);
        Test.stopTest();

        // Input Check
        System.assertEquals('a8fDK000000KysNYAS',FMG_MRPExecute.mrpCriteria.get('divisionId'), 'Division Criteria Check');
        System.assertEquals('All Items',FMG_MRPExecute.mrpCriteria.get('mrpPlanOption'), 'mrpPlanOption Check');
        System.assertEquals(false,FMG_MRPExecute.mrpCriteria.get('netChangeOption'), 'Net Change Option Check');

        // Output Check
        System.assertEquals(1,outputParameters.size(),'Result Record Check');
        FMG_MRPExecute.OutputParameters checkOutput = outputParameters[0];

        System.assertEquals(true,checkOutput.success, 'Request Success Check');
        System.assertEquals('Run MRP request has been submitted successfully',checkOutput.message, 'Message Check');
        System.assertEquals('a2lDI000000GuP4YAK',checkOutput.mrplaunchId, 'MRP Launch Id Check');
        System.assertEquals(true,checkOutput.mrplaunchSuccess, 'MRP Launch Success Check');
    }

    /**
        * @description Basic test for the MRP Execution
        **/
    @IsTest
    static void BasicMrpCreation_SubSuccessFalse() {


        System.debug('creating test results object');

        FMG_MRPExecute.InputParameters inputData = new FMG_MRPExecute.InputParameters();

        inputData.NetChangeOption = false;
        inputData.DivisionId = 'a8fDK000000KysNYAS';
        inputData.MrpPlanOption = 'All Items';

        List<FMG_MRPExecute.InputParameters> inputDataList = new List<FMG_MRPExecute.InputParameters>();
        inputDataList.add(inputData);

        Map<String,Object> subResultTestData = new Map<String, Object>();
        subResultTestData.put('success','false');
        subResultTestData.put('message','Run MRP request has been submitted successfully');
        subResultTestData.put('mrplaunchId','a2lDI000000GuP4YAK');
        Map<String,Object> resultTestData = new Map<String, Object>();
        resultTestData.put('result',subResultTestData);
        resultTestData.put('success',true);
        FMG_MRPExecute.testResult = resultTestData;

        Test.startTest();
        List<FMG_MRPExecute.OutputParameters> outputParameters = FMG_MRPExecute.bulkInvoke(inputDataList);
        Test.stopTest();

        // Input Check
        System.assertEquals('a8fDK000000KysNYAS',FMG_MRPExecute.mrpCriteria.get('divisionId'), 'Division Criteria Check');
        System.assertEquals('All Items',FMG_MRPExecute.mrpCriteria.get('mrpPlanOption'), 'mrpPlanOption Check');
        System.assertEquals(false,FMG_MRPExecute.mrpCriteria.get('netChangeOption'), 'Net Change Option Check');

        // Output Check
        System.assertEquals(1,outputParameters.size(),'Result Record Check');
        FMG_MRPExecute.OutputParameters checkOutput = outputParameters[0];

        System.assertEquals(true,checkOutput.success, 'Request Success Check');
        System.assertEquals('Run MRP request has been submitted successfully',checkOutput.message, 'Message Check');
        System.assertEquals('a2lDI000000GuP4YAK',checkOutput.mrplaunchId, 'MRP Launch Id Check');
        System.assertEquals(false,checkOutput.mrplaunchSuccess, 'MRP Launch Success Check');
    }


}