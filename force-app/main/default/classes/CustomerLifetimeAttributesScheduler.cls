global class CustomerLifetimeAttributesScheduler  implements Schedulable{
global void execute(SchedulableContext sc)
    {
        Database.executeBatch(new UpdateCustomerLifetimeAttributesBatch(),50);
    }
}