import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowNavigationFinishEvent, FlowAttributeChangeEvent, FlowNavigationBackEvent, FlowNavigationNextEvent, FlowNavigationPauseEvent } from 'lightning/flowSupport';

/*FlowAttributeChangeEvent — Informs the runtime that a component property has changed.
FlowNavigationBackEvent — Requests navigation to the previous screen.
FlowNavigationNextEvent — Requests navigation to the next screen.
FlowNavigationPauseEvent — Requests the flow runtime to pause the flow.
FlowNavigationFinishEvent — Requests the flow runtime to terminate the flow.*/

export default class LWCFLOW extends LightningElement {
    accountName;
    accountNumber;
    phone;
    contact = {};
    autoValidity = {};
    @api SorM;
    @api myValue;
    @api availableActions = [];
    @api
    label; //Label of the button
    @api
    buttonId; //Unique button Id
    @api
    selectedButtonId; //Property that'll store the buttonId
    @api item;
    @api quantity;
    @api fromLocID;
    @api fromLocNo;
    @api toLocID;
    @api toLocNo;
    @api isLoading;
    @api type;
    @api showFromLocNo;
    @api showFromLocID;
    @api showToLocNo;
    @api showToLocID;
    @api showItem;
    @api showQty;
    @api fromDetails;
    @api toDetails;
    @api showButtons;
    @api showFetchButton;
    @api showCheckbox;
    @api checkbox;
    @api showMyButton;
    @api showTransferAllItemButton;
    @api buttonIdTransferAll;
    @api singleButton;
    @api RemainingQty;
    @api AutoCount;
    @api isSpinner;
    @api msgIncoming;
    @api checkAuto;

    connectedCallback(){
        console.log('Inside Connectedcallback');
        //this.template.addEventListener('keydown', this.handleTabPress);
        //this.checkAuto = true;
        this.isSpinner = true;
        if(this.RemainingQty>0){
            this.handleContinueProcessing();
        }
        this.isSpinner = false;
        this.showMyButton = true;
        if(this.showFromLocNo == true &&  this.showFromLocID == true){
            this.fromDetails = true;
        }
        if(this.showToLocNo == true && this.showToLocID == true){
            this.toDetails = true;
        } 
    }
    renderedCallback() {
        console.log('Rendered Callback');
        // Select the input field by its class and focus it
        const inputFields = this.template.querySelectorAll('.myinput');
        console.log('InputFields: ', inputFields);
        if (inputFields.length > 0) {
            inputFields[0].focus();
            console.log(inputFields[0].name);
            console.log('data-index '+ inputFields[0]);
            console.log('Focus::Done');
        }
    }
    
    // disconnectedCallback() {
    //     // Remove the event listener when the component is disconnected
    //     this.template.removeEventListener('keydown', this.handleTabPress);
    // }
    handleKeyDown(event) {
        console.log('Handle Key Down');
        console.log('event.key'+event.key);
        if (event.key === 'Tab') {
            let index = event.target.dataset.index;
            console.log('Index::'+index);
            // const activeElement = document.activeElement;
            // console.log('Tab Pressed', activeElement);
            if (index == 6) {
                console.log('Tab Pressed in To Location No');
                this.handleAutoClick();
            }
        }
    }

    handleCheckChange(event){
        console.log('Checkchange');
        this.checkbox = event.target.checked;
        if(this.checkbox){
            this.showItem = false;
            //this.toDetails = false;
            //this.showMyButton = false;
            this.showButtons = false;
            this.showTransferAllItemButton = true;
        }
        if(!this.checkbox){
            this.showItem = true;
            //this.toDetails = true;
            //this.showMyButton = true;
            this.showButtons = true;
            this.showTransferAllItemButton = false;
        }
    }
    handleCheckbox(event){
        this.checkAuto = event.target.checked;
    }

    handleItemNumberChanged(event) {
        console.log('this.item::'+this.item);
        this.item = event.target.value;
        this.dispatchEvent(new FlowAttributeChangeEvent('item', this.item));
        if(this.buttonId!='transferAllButton'){
            this.handleAutoClick();
        }
        console.log('this.item::'+this.item);
    }
    handleQuantity(event){
        this.quantity = event.target.value;
        this.dispatchEvent(new FlowAttributeChangeEvent('quantity', this.quantity));
        if(this.quantity<=0 && this.quantity != ''){
            this.toastEventFire('Error', 'Quantity Ordered must be greater than Zero','error');
            return false;
        }
        if(this.buttonId!='transferAllButton'){
            this.handleAutoClick();
        }
        console.log('this.item::'+this.quantity);
    }
    handleFromLocationID(event){
        this.fromLocID = event.target.value;
        this.dispatchEvent(new FlowAttributeChangeEvent('fromLocID', this.fromLocID));
        if(this.buttonId!='fetchButton'){
            this.handleAutoClick();
        }
        console.log('this.item::'+this.fromLocID);
    }
    handleFromLocationNo(event){
        this.fromLocNo = event.target.value;
        this.dispatchEvent(new FlowAttributeChangeEvent('fromLocNo', this.fromLocNo));
        if(this.buttonId!='fetchButton'){
            this.handleAutoClick();
        }
        console.log('this.item::'+this.fromLocNo);
    }
    handleToLocationID(event){
        this.toLocID = event.target.value;
        this.dispatchEvent(new FlowAttributeChangeEvent('toLocID', this.toLocID));
        if(this.checkbox!=true){
            this.handleAutoClick();
        }
        console.log('this.item::'+this.toLocID);
    }
    handleToLocationNo(event){
        console.log('To Loc Changed');
        console.log('Changed :: event'+event.key);
        this.toLocNo = event.target.value;
        this.dispatchEvent(new FlowAttributeChangeEvent('toLocNo', this.toLocNo));
        // if(this.checkbox!=true){
        //     this.handleAutoClick();
        // }
        console.log('this.item::'+this.toLocNo);
        // const navigateNextEvent = new FlowNavigationNextEvent();
        // this.dispatchEvent(navigateNextEvent);
    }

    handleFetch(){
        this.isLoading = true;
        this.selectedButtonId = this.buttonId; //Setting the buttonId when button is clicked.
        /** Navigating to next screen */
        if (this.availableActions.find(action => action === 'NEXT')) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
        this.isLoading = false;
        this.toastEventFire('Success', 'Fetching Inventory Details...  Please wait...', 'success');
    }

    handleTransferAllItems(){
        this.checkAuto = true;
        this.isLoading = true;
        this.selectedButtonId = this.buttonIdTransferAll; //Setting the buttonId when button is clicked.
        /** Navigating to next screen */
        if (this.availableActions.find(action => action === 'NEXT')) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
        this.isLoading = false;
        this.toastEventFire('Success', "Please confirm to proceed transfer", 'success');
    }

    handleCustomClick() {
        this.isLoading = true;
        this.selectedButtonId = this.buttonId; //Setting the buttonId when button is clicked.
        /** Navigating to next screen */
        if (this.availableActions.find(action => action === 'NEXT')) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
        this.isLoading = false;
        this.toastEventFire('Success', 'Transfer in Progress.  Please wait', 'success');
    }
    handleBack() {
        //this.isLoading = true;
        if (this.availableActions.find((action) => action === "BACK")) {
          const navigateBackEvent = new FlowNavigationBackEvent();
          this.dispatchEvent(navigateBackEvent);
        }
        //this.isLoading = false;
      }
    /*handleReset(event) {
        this.template.querySelectorAll('lightning-input').forEach(element => {
            element.value = null;
        });

        this.accountName = undefined;
        this.accountNumber = undefined;
        this.phone = undefined;
    }*/
    handleAddInventoryDetail(){
        this.isLoading = true;
        //this.selectedButtonId = this.buttonId; //Setting the buttonId when button is clicked.
        /** Navigating to next screen */
        if (this.availableActions.find(action => action === 'NEXT')) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
        this.isLoading = false;
        this.toastEventFire('Success', 'Adding Inventory detail...  Please wait...', 'success');
    }

    handleContinueProcessing(){
        this.toastEventFire('Success', + parseInt(this.msgIncoming)-parseInt(this.RemainingQty)+ ' record(s) processed' + ' out of' +' '+ this.msgIncoming, 'info');
        this.selectedButtonId = this.buttonId;
        this.checkAuto = true;
        this.handleAutoClick();
    }
       
    handleNext() {
        this.isLoading = true;
        if(this.isInputValid()) {
            if (this.availableActions.find((action) => action === "NEXT")) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            //testTheDate();
            this.dispatchEvent(navigateNextEvent);
            }
            this.isLoading = false;
            if(this.myvalue){
                this.isShowModal = false;
                const sampledemoevent = new CustomEvent('sampledemo',{
                    detail: this.fromLocID,
                    details: this.fromLocNo
                });
                this.dispatchEvent(sampledemoevent);
            } 
        }
    }
    handleAutoClick(){
        //Console.log('Enter handleAutoClick()');
        let autoValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        console.log(`Getting Fields to validate:: Auto Clicks Here`);
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                autoValid = false;
            }
            this.autoValidity[inputField.name] = inputField.value;
        });
        //Console.log('autoValid::'+autoValid);
        if(autoValid && this.checkAuto){
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
        else{
            console.log('Missing Clicks...  So, Autoclick is not valid');
        }
    }

    handleGoBack() {
        //this.isLoading = true;
        // navigate to the back screen
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
        //this.isLoading = false;
    }
    toastEventFire(title,msg,variant){
        const e = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant,
        });
        this.dispatchEvent(e);
    } 
    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                this.toastEventFire('error','Please enter all the required fields','error');
                isValid = false;
                //errorMessage = 'Please input all the required fields';
            }
            this.contact[inputField.name] = inputField.value;
        });
        return isValid;
    }
}