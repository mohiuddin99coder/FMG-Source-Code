global class UpdatePriorAttributesSheduler implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
       Database.executeBatch(new UpdatePriorAndLyTyAmtBatch());
        
    }
}