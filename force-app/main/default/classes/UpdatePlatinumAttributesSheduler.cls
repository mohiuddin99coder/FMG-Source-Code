global class UpdatePlatinumAttributesSheduler implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
       Database.executeBatch(new UpdatePlatinumFieldsBatch());
        
    }
}