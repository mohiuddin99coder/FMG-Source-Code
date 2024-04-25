Public class BraintreeCaptureErrorClass {
    @InvocableMethod(label='Capture Braintree Errors')
    public Static void braintreeCaptureError(createListInputs[] inputLists) {
    Map<Id,Id> FulfillmentandBackgroundIdsMap = new Map<Id,Id>();
        for(Integer i = 0; i < inputLists[0].BGIds.size(); i++) {
            FulfillmentandBackgroundIdsMap.put(inputLists[0].BGIds.get(i), inputLists[0].FOIds.get(i));
            System.debug('FulfillmentIDs'+ inputLists[0].FOIds.get(i));
            System.debug('BackgroundoperationIDs'+inputLists[0].BGIds.get(i));
        }
        if(FulfillmentandBackgroundIdsMap.size()>0) {

            System.debug('FulfillmentandBackgroundIdsMap: '+FulfillmentandBackgroundIdsMap);
            BraintreeCaptureError__c DelayTime = BraintreeCaptureError__c.getValues('Schedule Time');
            system.debug(DelayTime.Delay_For_Payment_Capture_Check__c);
            Integer DelayForPaymentCapture = (Integer)DelayTime.Delay_For_Payment_Capture_Check__c;

            Datetime currentTime = Datetime.now();
            Datetime scheduledTime = currentTime.addMinutes(DelayForPaymentCapture);
            String scheduleName = 'Schedule BraintreeCaptureErrors (FOId: '+inputLists[0].FOIds[0]+')';
            String cronExpression = '0 '+scheduledTime.minute()+' '+scheduledTime.hour()+' '+scheduledTime.day()+' '+scheduledTime.month()+' ? '+ scheduledTime.year();
            system.debug('cronExpression: '+cronExpression);
            system.schedule(scheduleName, cronExpression, new Schedule_BraintreeCaptureErrors(FulfillmentandBackgroundIdsMap));
        }
    }
    
    public class createListInputs {
        @InvocableVariable(label='Fulfillment Order Id' required=true)
        public Id[] FOIds;
        
        @InvocableVariable(label='Background Operation Id' required= true)
        public Id[] BGIds;
    }
}