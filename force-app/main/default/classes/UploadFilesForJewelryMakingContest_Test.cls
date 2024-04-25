@isTest
public class UploadFilesForJewelryMakingContest_Test {
    @isTest
    static void testUploadFilesForJewelryMakingContest() {
        // Create test data
        Case testCase = new Case(Subject = 'Test Case', Status = 'New');
        insert testCase;
        
        Account testAccount = new Account(Lastname = 'Test Account', Website = 'www.example.com',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId());
        insert testAccount;
        
        // Create mock file data
        String fileName = 'testfile.txt';
        Blob fileBlob = Blob.valueOf('Test file content');
        String fileBase64 = EncodingUtil.base64Encode(fileBlob);
        
        List<UploadFilesForJewelryMakingContest.FileInfo> filesToInsert = new List<UploadFilesForJewelryMakingContest.FileInfo>();
        UploadFilesForJewelryMakingContest.FileInfo fileInfo = new UploadFilesForJewelryMakingContest.FileInfo();
        fileInfo.filename = fileName;
        fileInfo.base64 = fileBase64;
        filesToInsert.add(fileInfo);
                    
        // Call the test method
        Test.startTest();
        UploadFilesForJewelryMakingContest.UploadFilesForJewelryMakingContest(filesToInsert, testCase.Id, testAccount.Website);
        Test.stopTest();
        
        // Example Assertion for ContentVersion records
        List<ContentVersion> contentVersions = [SELECT Id, Title, PathOnClient, ContentDocumentId FROM ContentVersion];
        System.assertEquals(1, contentVersions.size());
        ContentVersion cv = contentVersions[0];
        System.assertEquals(fileName, cv.Title);
        
        // Example Assertion for ContentDocumentLink records
        List<ContentDocumentLink> contentDocumentLinks = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :testCase.Id];
        System.assertEquals(1, contentDocumentLinks.size());
        ContentDocumentLink cdl = contentDocumentLinks[0];
        System.assertEquals(cv.ContentDocumentId, cdl.ContentDocumentId);
        System.assertEquals(testCase.Id, cdl.LinkedEntityId);
    }
}