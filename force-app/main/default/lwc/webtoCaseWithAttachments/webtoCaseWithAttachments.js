import { LightningElement, wire, track } from 'lwc';
//import { ShowToastEvent} from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/FileUploaderClass.uploadFile'
import CASE_OBJECT from '@salesforce/schema/Case';
import SUBJECT_FIELD from '@salesforce/schema/Case.Subject';
import OWNER_FIELD from '@salesforce/schema/Case.OwnerId';
import EMAIL_FIELD from '@salesforce/schema/Case.SuppliedEmail';
import NAME_FIELD from '@salesforce/schema/Case.SuppliedName';
import ORDER_FIELD from '@salesforce/schema/Case.Account_Order_Number__c';
import COMMENT_FIELD from '@salesforce/schema/Case.Description';
import ORIGIN_FIELD from '@salesforce/schema/Case.Origin';
import WebtoCaseQueueId from '@salesforce/label/c.Web_to_Case_Queue_ID';

import Lead_OBJECT from '@salesforce/schema/Lead';
import LastName_FIELD from '@salesforce/schema/Lead.LastName';
import Status_FIELD from '@salesforce/schema/Lead.Status';
import LeadEmail_FIELD from '@salesforce/schema/Lead.Email';
import LeadSource_FIELD from '@salesforce/schema/Lead.LeadSource';
import Additional_Notes_FIELD from '@salesforce/schema/Lead.Additional_Notes__c';
import WebtoLeadQueueId from '@salesforce/label/c.Web_to_Lead_Queue_ID';

//add more field here 
import { createRecord } from 'lightning/uiRecordApi';

export default class FileUploaderCompLwc extends LightningElement {
fileData
fileDatalist=[];
fileData1
fileDatalist1=[];
@track emailvalue = "";
namevalue = "";
@track categoryvalue = '';
accountvalue = '';
commentvalue = '';
caseId = '';
@track loggedName = '';
@track loggedEmail = '';
@track caseRecord;
@track isLoading = false;
relatedRecordId;

connectedCallback() {
    // Get the current URL
    const url = window.location.href;
    console.log('URL-------------> '+url);
    const urlLink = new URL(url);
    const searchParams = new URLSearchParams(urlLink.search);
    this.loggedName = searchParams.get('nameparam');
    this.loggedEmail = searchParams.get('emailparam');
    this.namevalue = this.loggedName;
    this.emailvalue = this.loggedEmail;
  }
    
@track showSuccessMessage = false;
@track errorMessage;
@track categoryErrorMessage;
@track emailErrorMessage;
@track nameErrorMessage;
@track QuestionErrorMessage;
@track filesSize = 0;
@track filesSize1 = 0;
@track displayDiv = false;
@track isNameEmpty = false;
@track isNotValidName =false;
@track isNotValidComments =false;
@track FilesizeErrorMessage;
@track FilesizeErrorMessage1;
@track isNotValidEmail =false;
get categoryoptions() {
    return [
            {label: 'Shipping Questions', value: 'Shipping Questions'}, 
            {label: 'General Question', value: 'General Question'},
            {label: 'Order Correction', value: 'Order Correction'},
            {label: 'Where is my order?', value: 'Where is my order'},
            {label: 'Login Questions', value: 'Login Questions'},
            {label: 'Invoice Copy Request', value: 'Invoice Copy Request'},
            {label: 'Suggestions For New Product', value: 'Suggestions For New Product'},
            {label: 'Comments/Feedback', value: 'Comments/Feedback'},
    ];
}
handleEmailChange(event) {
    this.emailvalue = event.target.value;
}
handleAccountChange(event) {
    this.accountvalue = event.target.value;
}
handleNameChange(event) {
    this.namevalue = event.target.value;
}
handleChange(event) {
    this.categoryvalue = event.target.value;
}
handleCommentChange(event) {
    this.commentvalue = event.target.value;
}



openfileUpload(event) {
try {
var files = JSON.stringify(event.target.files[0]);
console.log("files: " + event.target.files[0]);
console.log("filedata1: " + event.target.files[0].name);
console.log("files length: " + event.target.files.length);
this.fileDatalist=[];
this.filesSize=0;
for (let i = 0; i < event.target.files.length; i++) {
    const file = event.target.files[i];
    var reader = new FileReader();

    reader.onload = ((file) => {
    return (event) => {
        var reader1 = JSON.stringify(event.target.result);
        console.log("reader" + i + " " + reader1);

        if (event.target.result) {
        var base64 = event.target.result.split(',')[1];
        console.log(base64.length);
        this.filesSize=this.filesSize+base64.length;
        console.log(" all Filessize:"+ this.filesSize);
        if(this.filesSize>2000000){
            this.FilesizeErrorMessage = 'The file sizes should not be more than 2 mb';
        }else{
            this.FilesizeErrorMessage = '';
        }
        this.fileData = {
            'filename': file.name,
            'base64': base64
        };
        this.fileDatalist.push(this.fileData);
        }
    };
    })(file);

    reader.readAsDataURL(file);
}
} catch (error) {
console.error("Error uploading files:", error);
}

}


openfileUpload1(event) {
    try {
    var files = JSON.stringify(event.target.files[0]);
    console.log("files: " + event.target.files[0]);
    console.log("filedata1: " + event.target.files[0].name);
    console.log("files length: " + event.target.files.length);
    this.fileDatalist1=[];
    this.filesSize1=0;
    for (let i = 0; i < event.target.files.length; i++) {
        const file = event.target.files[i];
        var reader = new FileReader();
    
        reader.onload = ((file) => {
        return (event) => {
            var reader1 = JSON.stringify(event.target.result);
            console.log("reader" + i + " " + reader1);
    
            if (event.target.result) {
            var base64 = event.target.result.split(',')[1];
            console.log(base64.length);
            this.filesSize1=this.filesSize1+base64.length;
            console.log(" all Filessize1:"+ this.filesSize1);
            if(this.filesSize1>2000000){
                this.FilesizeErrorMessage1 = 'The file sizes should not be more than 2 mb';
            }else{
                this.FilesizeErrorMessage1 = '';
            }

            this.fileData1 = {
                'filename': file.name,
                'base64': base64
            };
            this.fileDatalist1.push(this.fileData1);
            }
        };
        })(file);
    
        reader.readAsDataURL(file);
    }
    } catch (error) {
    console.error("Error uploading files:", error);
    }
    
    }

handleClick() {
    try {
    console.log("size of total files1: "+this.filesSize);
    console.log("size of total files2: "+this.filesSize1);
    const isValid = isValidEmail(this.emailvalue);
    console.log(isValid);

    const emailPattern=/[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,7}$/;
    const emailPatternvalue=emailPattern.test(this.emailvalue);
    console.log('phone: '+emailPatternvalue);

    this.isNotValidName=false;
if (this.namevalue && this.namevalue.trim()==='') {
    this.isNotValidName=true;
}
    this.isNotValidComments=false;
if (this.commentvalue && this.commentvalue.trim()==='') {
    this.isNotValidComments=true;
}
    this.isNotValidEmail=false;
if (this.emailvalue && this.emailvalue.trim()==='') {
    this.isNotValidEmail=true;
}


console.log('*** Inside Lead ***');
    if(this.categoryvalue != '' && this.emailvalue != '' && this.namevalue != '' && this.commentvalue !='' && emailPatternvalue==true && isValid && this.isNotValidName==false && this.isNotValidEmail==false&& this.isNotValidComments==false &&this.filesSize<=2000000 &&this.filesSize1<=2000000){
        this.categoryErrorMessage = '';
        this.emailErrorMessage = '';
        this.nameErrorMessage = '';
        this.QuestionErrorMessage = '';
        this.FilesizeErrorMessage ='';
        this.FilesizeErrorMessage1 ='';
        this.displayDiv=false;

        this.isLoading = true;
if (this.categoryvalue == 'Suggestions For New Product'){
    const fields = {};
    console.log('*** Inside Lead ***');
    fields[LastName_FIELD.fieldApiName] = this.namevalue;  
    fields[LeadEmail_FIELD.fieldApiName] = this.emailvalue;    
    fields[Status_FIELD.fieldApiName] = 'New';    
    fields[LeadSource_FIELD.fieldApiName] = 'Other';
    fields[Additional_Notes_FIELD.fieldApiName] = this.commentvalue; 
    fields[OWNER_FIELD.fieldApiName] = WebtoLeadQueueId;
    this.caseRecord = { apiName: Lead_OBJECT.objectApiName, fields: fields };
    console.log('Status_FIELD 2 >>>'+Status_FIELD);
    }
else{
    const fields = {};
    fields[SUBJECT_FIELD.fieldApiName] = this.categoryvalue;//added subject as per Name
    fields[EMAIL_FIELD.fieldApiName] = this.emailvalue;
    fields[NAME_FIELD.fieldApiName] = this.namevalue;
    fields[ORDER_FIELD.fieldApiName] = this.accountvalue;
    fields[OWNER_FIELD.fieldApiName] = WebtoCaseQueueId;
    fields[COMMENT_FIELD.fieldApiName] = this.commentvalue;
    fields[ORIGIN_FIELD.fieldApiName] = 'Web';     
    console.log('EMAIL_FIELD:'+EMAIL_FIELD);
    console.log('SUBJECT_FIELD:'+SUBJECT_FIELD);
    console.log('NAME_FIELD:'+NAME_FIELD);
    console.log('ORDER_FIELD:'+ORDER_FIELD);
    console.log('COMMENT_FIELD:'+COMMENT_FIELD);

    //add more field here 

    this.caseRecord = { apiName: CASE_OBJECT.objectApiName, fields: fields };
}
  
createRecord(this.caseRecord)
.then(result => {

    const caseId = result.id;
    if(caseId !=null){
        
        this.showSuccessMessage = true;
        setTimeout(() => {
            this.showSuccessMessage = false;
        }, 5000); // 5 seconds
    }
    console.log('Caseid====>' + caseId);
            this.relatedRecordId = caseId;
            console.log('relatedRecordId====>' + this.relatedRecordId);
                uploadFile({ filesToInsert:this.fileDatalist, recordId: caseId }).then(result1 => {
                    console.log('Success message====>' + result1);
                    this.fileDatalist = null;
                        this.categoryvalue='';
                        this.emailvalue=this.loggedEmail;
                        this.namevalue=this.loggedName;
                        this.accountvalue='';
                        this.commentvalue='';
                        this.fileData='';
                        this.fileDatalist=[];
                        this.filesSize=0;
                    
                }).catch(error=>{
                    this.isLoading = false;
                    var errorString= JSON.stringify(error);
                    console.error('error message message====>' + errorString);
                })
                uploadFile({ filesToInsert:this.fileDatalist1, recordId: caseId }).then(result1 => {
                    console.log('Success message====>' + result1);
                    this.fileDatalist = null;
                        this.fileData1='';
                        this.fileDatalist1=[];
                        this.filesSize1=0;
                        this.isLoading = false;
                    
                }).catch(error=>{
                    this.isLoading = false;
                    var errorString= JSON.stringify(error);
                    console.error('error message message====>' + errorString);
                })
                console.log('End of created record');
        }
        )
        .catch(error => {
            this.isLoading = false;
            alert('You are unable to create a case for '+ error);
                console.error('error:',error);
        })
    console.log('*** end createRecord *** '); 
}else{
    this.displayDiv=true;
    if(!this.categoryvalue){
        this.categoryErrorMessage = 'This field is required and cannot be empty';
    }else{
        this.categoryErrorMessage = '';
    }
    if(this.emailvalue ==='' ||this.isNotValidEmail==true){
        this.emailErrorMessage = 'This field is required and cannot be empty';
    }else if(!isValid || emailPatternvalue==false){
        this.emailErrorMessage = 'You have entered an invalid format.';
    }
    else{
        this.emailErrorMessage = '';
    }
    if(this.namevalue ==='' || this.namevalue==null || this.isNotValidName==true){
        this.nameErrorMessage = 'This field is required and cannot be empty';
    }else{
        this.nameErrorMessage = '';
    }
    if(this.commentvalue ==='' || this.isNotValidComments==true){
        this.QuestionErrorMessage = 'This field is required and cannot be empty';
    }else{
        this.QuestionErrorMessage = '';
    }
    if(this.filesSize>2000000){
        this.FilesizeErrorMessage = 'The file sizes should not be more than 2 mb';
        this.fileDatalist=[];
    }else{
        this.FilesizeErrorMessage = '';
    }
    if(this.filesSize1>2000000){
        this.FilesizeErrorMessage1 = 'The file sizes should not be more than 2 mb';
        this.fileDatalist1=[];
    }else{
        this.FilesizeErrorMessage1 = '';
    }

    console.log('Inside else loop1');
}
}
catch(error){
    console.error('error====>'+error);
}
}
}

function isValidEmail(email) {
const inputElement = document.createElement('input');
inputElement.type = 'email';
inputElement.value = email;
return inputElement.checkValidity();
}