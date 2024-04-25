public without sharing class UploadFilesForJewelryMakingContest {

    @AuraEnabled
   public static void UploadFilesForJewelryMakingContest(list<Object> filesToInsert, String recordId, String Website) {
    /*Case caseRecord = [SELECT AccountId FROM Case WHERE Id = :recordId];
    //if(caseRecord.AccountId!=null){
    List<Account> accRecord = [SELECT Id, website FROM Account WHERE Id = :caseRecord.AccountId];
    System.debug('AccountId'+accRecord);
    List<Account> acclist=new List<Account>();
    Account accSingleList= new Account();
    if(accRecord.size()>0){
for(Account AList:accRecord){
  System.debug('AccountId'+AList.Id);
AList.Website=Website;
acclist.add(AList);
}
update acclist;
    }*/
 // }
   // update caseRecord;
    System.debug('AccountId'+Website);
         List<ContentVersion> cvlist = new List<ContentVersion>();
         List<ContentDocumentLink> cdllist = new List<ContentDocumentLink>();
   
         for (Object file : filesToInsert) {
           FileInfo fileData = (FileInfo)JSON.deserialize(JSON.serialize(file), FileInfo.class);
           cvlist.add(createContentVersion(fileData.base64, fileData.filename));
         }
         insert cvlist;
         for(ContentVersion cv:cvlist){
           cdllist.add(createContentLink(cv.Id, recordId));
         }
         insert cdllist;
   }
   public class FileInfo {
     public String filename;
     public String base64;
   }
   
   private static ContentVersion createContentVersion(String base64, String filename) {
     ContentVersion cv = new ContentVersion();
     cv.VersionData = EncodingUtil.base64Decode(base64);
     cv.Title = filename;
       String fileExtension = filename.substring(filename.lastIndexOf('.') + 1);
     cv.PathOnClient = 'testdoc.' +fileExtension;
       
       
     try {
       return cv;
     } catch(DMLException e) {
       System.debug(e);
       return null;
     }
   }
   
   private static ContentDocumentLink createContentLink(Id contentVersionId, String recordId) {
     Id ContentDocumentId=[SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersionId].ContentDocumentId;
     System.debug('recordId'+recordId); 
               if (contentVersionId == null || recordId == null) { return null; }
     ContentDocumentLink cdl = new ContentDocumentLink();
     cdl.ContentDocumentId = ContentDocumentId;
     cdl.LinkedEntityId = recordId;
     cdl.ShareType = 'V';
     try {
       //insert cdl;
       return cdl;
     } catch(DMLException e) {
       System.debug(e);
       return null;
     }
   }
   }