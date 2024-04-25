// @description Trigger on LIFO_Processing_Record_PE__e that sets LIFO_Processing_Record__c.Ready_to_Process__c to True.
//
trigger LIFOEventTrigger on LIFO_Processing_Record_PE__e (after insert) {

    Integer counter = 0;
    
    for (LIFO_Processing_Record_PE__e event : Trigger.New) {
    
      // Increase batch counter
      counter++;
      
      // Only process one event message
        if (counter > 1) {break;}
      
        // Resume after the last successfully processed event message
        // after the trigger stops running. 
        // Exit for loop.
 
      // Process event message.
      LIFO_Processing_Record__c LIFO = new LIFO_Processing_Record__c();
      LIFO.Id = event.LIFO_Processing_ID__c;
      LIFO.Ready_to_Process__c = True;
      
      if(String.isBlank(event.LIFO_Processing_ID__c))
      {
          System.debug('LIFO Id field is empty '+event);
          continue;
      }
      
      update LIFO;
     
      // Set Replay ID after which to resume event processing 
      // in new trigger execution.
      EventBus.TriggerContext.currentContext().setResumeCheckpoint(event.ReplayId);
          
    }
    
}