/**
 * Created by inscorea on 1/17/2024.
 */

public with sharing class FMG_MRPExecute {


    @InvocableMethod(Label='FMG MRP Execution')
    public static List<OutputParameters> bulkInvoke(List<InputParameters> inputs){
        List<OutputParameters> outputs = new List<FMG_MRPExecute.OutputParameters>();

        for(InputParameters input: inputs){
            OutputParameters output = invoke(input);
            outputs.add(output);
        }
        return outputs;
    }


    @TestVisible
    private static Map<String,Object> mrpCriteria;

    @TestVisible
    public static Map<String, Object> testResult{get;set;}


    private static OutputParameters invoke(InputParameters input){

        mrpCriteria = new Map<String,Object> ();
        mrpCriteria.put('divisionId',input.DivisionId);
        mrpCriteria.put('mrpPlanOption',input.MrpPlanOption);
        mrpCriteria.put('allProjects',true);
        mrpCriteria.put('netChangeOption',input.NetChangeOption);
        Map<String,Object> resultMap;

        System.Debug('Executing MRP with the following inputs');
        System.debug(JSON.serializePretty(mrpCriteria));
        if(Test.isRunningTest()){
            resultMap = testResult;
        } else {
            resultMap = rstk.RSAPIGateway.callAction('MRPService','Run MRP',mrpCriteria);
        }

        System.Debug('Executing MRP with the following inputs Finished');
        OutputParameters result = new OutputParameters();
        result.success = (Boolean)resultMap.get('success');



        Map<String, Object> subResults = (Map<String, Object>)resultMap.get('result');

        result.message = (String)subResults.get('message');

        if((String)subResults.get('success') == 'true'){
            result.mrplaunchSuccess = true;
        } else {
            result.mrplaunchSuccess = false;
        }

        result.mrplaunchId = (String)subResults.get('mrplaunchId');

        return result;

    }

    /**
     * @description Rough breakdown of the parameters for rstk.MRP.runmrp('FMG', null, null, false);
     **/
    public class InputParameters{

        /**
         * @description first parameter of 'FMG' is going to be the Division Number (text)
         **/
        @InvocableVariable(Required=true)
        public String DivisionId;

        /**
         * @description Options are:
         *  All Items
         *  Only Reorder Point Items
         **/
        @InvocableVariable(Required=true)
        public String MrpPlanOption;


        /**
         * @description  When true, MRP will run in Net Change mode.
         **/
        @InvocableVariable(Required=true)
        public Boolean NetChangeOption;

    }

    /**
     * @description MRP Output
     **/
    public class OutputParameters{

        /**
         * @description The status of the RSAPIGateway request
         **/
        @InvocableVariable
        public Boolean success;

        /**
         * @description Message from the MRP Launch
         **/
        @InvocableVariable
        public String message;

        /**
         * @description mrp Launch Success
         **/
        @InvocableVariable
        public Boolean mrplaunchSuccess;

        /**
         * @description MRP Process Id
         **/
        @InvocableVariable
        public String mrplaunchId;

    }
}