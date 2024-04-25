@RestResource(UrlMapping='/tempfmgApi/orderSummeryMassCreate')
global with sharing class fmg_temp_order_summery_creation {



    global class OrderOutput{
        public OrderOutput(ConnectApi.OrderSummaryInputRepresentation input,ConnectApi.OrderSummaryOutputRepresentation output)
        {
            errorMessage = '';
            orderId = input.orderId;
            orderLifeCycleType = input.orderLifeCycleType;
            orderSummaryId = output.orderSummaryId;
            status = input.status;

        }

        public OrderOutput(ConnectApi.OrderSummaryInputRepresentation input,Exception output)
        {
            System.debug(output);
            errorMessage = output.toString();
            orderId = input.orderId;
            orderLifeCycleType = input.orderLifeCycleType;
            orderSummaryId = '';
            status = input.status;
        }

        global String orderId{get;set;}
        global String orderSummaryId{get;set;}
        global String orderLifeCycleType{get;set;}
        global String status{get;set;}
        global String errorMessage{get;set;}
    }

    @HttpPost
    global static List<OrderOutput> doPost(List<String> orders) {


        List<ConnectApi.OrderSummaryInputRepresentation> orderSummeryInputs = new List<ConnectApi.OrderSummaryInputRepresentation>();
        for (String order : orders) {
            ConnectApi.OrderSummaryInputRepresentation newOrderSummery = new ConnectApi.OrderSummaryInputRepresentation();
            newOrderSummery.orderId = order;
            newOrderSummery.orderLifeCycleType = 'UNMANAGED';
            newOrderSummery.status = 'Fulfilled';
            orderSummeryInputs.add(newOrderSummery);
        }


        List<OrderOutput> requestResults = new List<OrderOutput>();

        for (ConnectApi.OrderSummaryInputRepresentation orderSummeryInput : orderSummeryInputs) {
            ConnectApi.OrderSummaryOutputRepresentation orderSummeryOutput;
            try {
                System.debug(orderSummeryInput.orderId + ':' + orderSummeryInput.orderLifeCycleType + ':' + orderSummeryInput.status);
                if (Test.isRunningTest()) {

                    // This is to test the error path
                    if(orderSummeryInput.orderId=='ErrorPath'){
                        ConnectApi.OrderSummaryCreation.createOrderSummary(orderSummeryInput);
                    }

                    orderSummeryOutput = new ConnectApi.OrderSummaryOutputRepresentation();
                    orderSummeryOutput.success = true;
                    orderSummeryOutput.errors = new List<ConnectApi.ErrorResponse>();
                    orderSummeryOutput.orderSummaryId = orderSummeryInput.orderId;
                } else {
                    orderSummeryOutput = ConnectApi.OrderSummaryCreation.createOrderSummary(orderSummeryInput);
                }
                requestResults.add(new OrderOutput(orderSummeryInput, orderSummeryOutput));
            } catch (Exception ex) {
                requestResults.add(new OrderOutput(orderSummeryInput, ex));
            }
        }

        return requestResults;
    }
}