global class UpdateCustomerAttributesSheduler implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        Database.executeBatch(new UpdateCustomerAttributesBatch());
        
    }
}