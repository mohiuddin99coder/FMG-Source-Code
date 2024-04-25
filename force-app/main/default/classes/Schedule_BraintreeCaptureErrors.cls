public class Schedule_BraintreeCaptureErrors implements Schedulable {

    public Map<Id,Id> FOandBGIdsMap;

    public Schedule_BraintreeCaptureErrors(Map<Id,Id> inputMap){
        FOandBGIdsMap = inputMap;
    }

    public void execute(SchedulableContext SC) {
        BraintreeCaptureErrors(FOandBGIdsMap);
    }

    public void BraintreeCaptureErrors(Map<Id,Id> FOandBGIdsMap) {
        system.debug('Inside BraintreeCaptureErrors Method');
        System.debug('FOandBGIdsMap: ' + FOandBGIdsMap);
        system.debug('FOId: '+ FOandBGIdsMap.keySet());
        system.debug('BGId: '+ FOandBGIdsMap.values());

        List<BackgroundOperation> BackgroundOperationList;
        if(!Test.isRunningTest()) {
            BackgroundOperationList = [SELECT Id,Status FROM BackgroundOperation WHERE Id IN:FOandBGIdsMap.keySet() AND Status = 'Error'];
        } else {
            BackgroundOperationList = [SELECT Id,Status FROM BackgroundOperation WHERE Id IN:FOandBGIdsMap.keySet()];
        }
        system.debug('BackgroundOperationList :'+BackgroundOperationList);
        If(!BackgroundOperationList.IsEmpty()){
            system.debug('BackgroundOperationList: '+ BackgroundOperationList);

            Map<Id,Id> FOandOrderSumIdsMap = new Map<Id,Id>();
            for (FulfillmentOrder FO : [Select Id,OrderSummaryId from FulfillmentOrder where Id = :FOandBGIdsMap.values()]){
                FOandOrderSumIdsMap.put(FO.Id,FO.OrderSummaryId);
            }

            for(BackgroundOperation BckGOp :BackgroundOperationList) {
                    ProcessException Processexption = new ProcessException();
                    Processexption.AttachedToId = FOandBGIdsMap.get(BckGOp.Id);
                    Processexption.Category = 'Payment';
                    Processexption.Status = 'New';
                    Processexption.Priority = 'High';
                    Processexption.Severity = 'High';
                    Processexption.OrderSummaryId = FOandOrderSumIdsMap.get(FOandBGIdsMap.get(BckGOp.Id));
                    Processexption.Message = 'Amount Capture Failed';
                    system.debug('Processexption: '+ Processexption);
                    insert Processexption;
            }
        }
    }

    
}