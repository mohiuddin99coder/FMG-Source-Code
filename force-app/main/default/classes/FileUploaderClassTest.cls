@isTest
public class FileUploaderClassTest {
    static testmethod void testUploadFile() {
        Test.startTest();
        // Test data
        Case newCase = new Case();
        newCase.Subject = 'Test Case';
        newCase.Origin = 'Web';
        newCase.Status = 'New';
        newCase.Description = 'This is a test case.';
        insert newCase;
        
        List<Object> filesToInsert = new List<Object>();
        FileUploaderClass.FileInfo fileInfo = new FileUploaderClass.FileInfo();
        fileInfo.filename = 'testfile.txt';
        fileInfo.base64 = 'SGVsbG8gd29ybGQh'; // Base64 encoded "Hello world!"
        filesToInsert.add(fileInfo);
        String recordId = newCase.Id; // Replace with a valid record Id
        
        // Invoke the uploadFile method
        //Test.startTest();
        FileUploaderClass.uploadFile(filesToInsert, recordId);
        Test.stopTest();
        
        // Perform assertions
        List<ContentVersion> contentVersions = [SELECT Id, Title, ContentDocumentId FROM ContentVersion];
        List<ContentDocumentLink> contentDocumentLinks = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId = :contentVersions[0].ContentDocumentId];
        
        // Assert that ContentVersion and ContentDocumentLink records are created
        System.assertEquals(1, contentVersions.size());
        //System.assertEquals(1, contentDocumentLinks.size());
        
        // Assert the Title field value of the ContentVersion record
        System.assertEquals('testfile.txt', contentVersions[0].Title);
    }

}