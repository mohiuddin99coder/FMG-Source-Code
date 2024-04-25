import { LightningElement, track, wire,api } from 'lwc';
//import validataeCreditCardDetails from '@salesforce/apex/UpdatePayment.updateDetails';
import validataeCreditCardDetails from '@salesforce/apex/CreditCradAuthrizationToBrainTree.authrizeCreditCardInfo';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import AMOUNTDUE from '@salesforce/schema/Opportunity.Amount_Due__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class CreditCardForm extends LightningElement {
@api recordId;
@track Amount = '';
@track isLoading = false;
@track isDisable = false;
@track isCardNumberMatchCheck = false;
@track isCVVMatchCheck = false;
@track isExpireDateMatchCheck = false;
@track AmountDue = '';

@wire(getRecord, { recordId: '$recordId', fields: [AMOUNTDUE]})
record;
get amountDue() {
    this.AmountDue =getFieldValue(this.record.data, AMOUNTDUE);
    return this.record.data ? getFieldValue(this.record.data, AMOUNTDUE) : '';
    }
//@track showForm = false;
@track cardholderName = '';
@track cardNumber = '';
@track expirationMonth = '';
@track expirationYear = '';
@track expirationDate = '';
@track cvv = '';
@track advanceAmount = '';
//@track isBlankCheck =true ;

handleCardNameChange(event){
this.cardholderName = event.target.value;
}

handleCardNumberChange(event) {
this.cardNumber = event.target.value;
}

handleExpirationChange(event) {
    let inputValue = event.target.value;
    // Remove any non-digit characters from the input
    let numericValue = inputValue.replace(/\D/g, '');
    // Add slash after two digits
    if (numericValue.length >= 2) {
        numericValue = numericValue.substring(0, 2) + '/' + numericValue.substring(2);
    }
    // Update the input value
    event.target.value = numericValue;
    this.expirationDate = event.target.value;
    }

handleCvvChange(event) {
this.cvv = event.target.value;
}

handleAdvanceAmount(event) {
this.advanceAmount = event.target.value;
}

/*handleCancel(){
this.showForm = false;
}*/

handleSubmit() {
    console.log('Expiredate Regxcheck',/^(0[1-9]|1[0-2])\/?([0-9]{2})$/.test(this.expirationDate));
    console.log('CVV Regxcheck',/\d{3,4}/.test(this.cvv));
    if(/\d{4}-?\d{4}-?\d{4}-?\d{4}/.test(this.cardNumber)){
        this.isCardNumberMatchCheck=true;
    }
    if(/\d{3,4}/.test(this.cvv)){
        this.isCVVMatchCheck=true;
    }
    if(/^(0[1-9]|1[0-2])\/?([0-9]{2})$/.test(this.expirationDate)){
        this.isExpireDateMatchCheck=true;
    }


if(this.cardholderName !='' && this.cardNumber != '' &&  this.expirationDate != '' && this.cvv !='' && this.advanceAmount !='' && this.isCardNumberMatchCheck==true && this.isCVVMatchCheck==true && this.isExpireDateMatchCheck==true ){ 
    //this.isLoading = true;
console.log('holder name',this.cardholderName);
console.log('number', this.cardNumber);
console.log('Expirydate',this.expirationDate);
const chars = this.expirationDate.split("/");
this.expirationMonth = chars[0];
this.expirationYear = chars[1];
console.log('month',this.expirationMonth);
console.log('year',this.expirationYear);
console.log('cvv',this.cvv);
console.log('Amount Due',this.AmountDue);
console.log('Advance amount',this.advanceAmount);

const currentYear = new Date().getFullYear();
const lastTwoDigits = currentYear % 100;
console.log('lastTwoDigits',lastTwoDigits);
const currentDate = new Date();
    const currentMonth = currentDate.getMonth() + 1;
    console.log('currentMonth:'+currentMonth);
    const expmonth=Number(this.expirationMonth);
    console.log('expmonth:'+expmonth);
    console.log('this.expirationYear>lastTwoDigits',this.expirationYear>lastTwoDigits);
    console.log('this.expirationMonth>=currentMonth',expmonth>=currentMonth);
    console.log('this.expirationYear==lastTwoDigits',this.expirationYear==lastTwoDigits);
    console.log('Inside expire if'+(this.expirationYear>lastTwoDigits ||(expmonth>=currentMonth && this.expirationYear==lastTwoDigits)));
if(this.expirationYear>lastTwoDigits ||(expmonth>=currentMonth && this.expirationYear==lastTwoDigits)){
    console.log('Inside expire if');
const creditCardData = {
cardholderName: this.cardholderName,
cardNumber: this.cardNumber,
expirationMonth: this.expirationMonth,
expirationYear: this.expirationYear,
cvv: this.cvv,
//amount:this.Amount,
recordId:this.recordId,
amountDue:this.AmountDue,
advanceAmount:this.advanceAmount
};
console.log('Inside expire if');
console.log("Condition:",this.advanceAmount <= this.AmountDue);
if(this.advanceAmount <= this.AmountDue && this.advanceAmount >0){
    var inputCmp = this.template.querySelector('.advanceAmount');
    inputCmp.setCustomValidity("");
    inputCmp.reportValidity();
this.isLoading = true;
this.isDisable = true;
validataeCreditCardDetails({ creditCardData})
.then(result => {
    
console.log('Credit card details processed successfully:',result);
var status = result.status.toString();
if(status==="Success"){
    this.isLoading = false;
    this.isDisable = false;
this.dispatchEvent(
new ShowToastEvent({
    message: result.message,
    variant: 'Success'
}),
);
this.dispatchEvent(new CloseActionScreenEvent());
}
if(status==="Payment Failed"){
    this.isLoading = false;
    this.isDisable = false;
this.dispatchEvent(
    new ShowToastEvent({
        message: result.message,
        variant: 'error',
        duration: 10
    }),
    );
}

})
.catch(error => {
// Handle error response from server
console.error('Error processing credit card details:', error);
});
}else{
    var inputCmp = this.template.querySelector('.advanceAmount');
    inputCmp.setCustomValidity("Advance Amount should not be Zero or greater than the Amount Due");
    inputCmp.reportValidity();
}
}else{
    console.log('Inside expire else toast');
    this.dispatchEvent(
        new ShowToastEvent({
            message: 'Please enter a valid expiration date',
            variant: 'error',
            duration: 10
        }),
        );
}
}else{
console.log('In Else loop');
this.dispatchEvent(
new ShowToastEvent({
    title: 'Required fields missing',
    message: 'Please enter all the required fields Correctly',
    variant: 'error',
    duration: 10
}),
);
}

}
closeAction(){
this.dispatchEvent(new CloseActionScreenEvent());
}
}