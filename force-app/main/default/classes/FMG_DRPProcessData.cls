/**
 * Created by Adam-Hotmail on 10/12/2023.
 */

public interface FMG_DRPProcessData {
    List<rstk__ictransreqh__c> getRequestGroupsData(List<rstk__ictransreqh__c> groups);
    List<Map<String, Object>> getPlannedTransferCondensedRecordsData(List<Id> requestIds);
    void createMoves(List<fmginvmove__c> fmginvmoves);
    List<rstk__ictransreq__c> getTransferRequests(List<Id> transferRequestIds);
    void updatePlannedRequests(List<rstk__ictransreq__c> transferRequests);
    void executeMoves(List<rstk__sydatat__c> transfers);
}