/**
 * Created by anshulagrawal on 2019-03-04.
 */

public with sharing class OwlinAccountLinkScheduler implements Schedulable {

    Integer totalEntitiesToRequest = OwlinEntitiesHandler.getFeatureLicenseCount() - OwlinEntitiesHandler.getLinkedEnities();

    //execute owlin batchable
    public void execute(SchedulableContext sc) {
        //not generating token and requesting entities which are allowed upto limit
       if(totalEntitiesToRequest > 0) Database.ExecuteBatch(new OwlinAccountLinkBatchable('',totalEntitiesToRequest,null), 75);

    }
}