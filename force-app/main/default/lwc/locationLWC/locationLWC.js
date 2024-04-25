import { LightningElement, wire, api, track } from 'lwc';
import getChildDetails from '@salesforce/apex/lwcLocationController.getDataTableValues';
import { refreshApex } from '@salesforce/apex';
import { FlowNavigationFinishEvent, FlowAttributeChangeEvent, FlowNavigationBackEvent, FlowNavigationNextEvent, FlowNavigationPauseEvent } from 'lightning/flowSupport';
import { NavigationMixin } from 'lightning/navigation';
let j = 0;
let baseUrlOfOrg= 'https://'+location.host+'/';
const actions = [
    { label: 'View', name: 'view' },
    { label: 'Delete', name: 'delete' }
];
const columns = [{
        label: 'Name',
        fieldName: 'ConName',
        type: 'url',
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
    },
    {
        label: 'Item',
        fieldName: 'ItemName',
        type: 'url',
        typeAttributes: { label: { fieldName: 'itemName' }, target: '_blank' }
    },
    {
        label: 'Quantity',
        fieldName: 'rstk__iclocitem_locqty__c',
        type: 'Number',
    },
    {
        label: 'From Location ID',
        fieldName: 'FromLocID',
        type: 'url',
        typeAttributes: { label: { fieldName: 'fromLocID' }, target: '_blank' }
    },
    {
        label: 'From Location No',
        fieldName: 'rstk__iclocitem_locnum__c',
        type: 'Text'
    }
];

export default class LocationLWC extends LightningElement {
    @track isLoading = false;
    @api myname;
    @api passFromLocID;
    @api passFromLocNo;
    @api fromLocID;
    @api toLocID;
    @api buttonLabel = "New Transfer";
    @track lstAccounts;
    @api myid;
    column = columns;
    @track myViewList;
    @api recordId;
    @api handleShow = false;
    @api myvalue;
    @api purchasename;
    @api itemName;
    @api inventoryName;
    @track isLoading = false;
    consData;
    showModalBox() {
        this.handleShow = true;
    }
    hideModalBox() {
        this.handleShow = false;
    }
    handleChanges(event) {
        this.handleShow = event.detail;
        refreshApex(this.wiredDataResult);
    }
    handleClick() {
        this.isLoading = true;
        refreshApex(this.wiredDataResult);
        this.isLoading = false;
    }
    handleRowAction( event ) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch ( actionName ) {
            case 'view':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        actionName: 'view'
                    }
                });
                break;
            case 'edit':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        objectApiName: 'rstk__iclocitem__c',
                        actionName: 'edit'
                    }
                });
                break;
            case 'delete':
                this.handleDeleteRow(row.Id);
                break;
            default:
        }
    }
    handleDeleteRow(recordIdToDelete){
        this.isLoading = true;
        deleteSelectedAccount({recordIdToDelete:recordIdToDelete})
        .then(result=>{
            this.toastEventFire('Success', 'Record(s) deleted successfully', 'success');
            refreshApex(this.wiredDataResult);
        })
        .catch(error => {
            this.error = error;
        });
    }
    handleSearchChange( event ) {
        this.searchString = event.detail.value;
        console.log( 'Updated Search String is ' + this.searchString );
    }
    @wire(getChildDetails, { passFromLocID: '$passFromLocID', passFromLocNo: '$passFromLocNo'})
    wiredRecordsMethod(result) {
        this.wiredDataResult = result;
        this.isLoading = true;
        if (result.data) {
            console.log('Result'+result);
            let tempConList = [];
            result.data.forEach((record) => {
                let tempConRec = Object.assign({}, record);
                tempConRec.ConName = '/lightning/r/rstk__iclocitem__c/' + tempConRec.Id + '/view';
                tempConRec.ItemName = '/lightning/r/rstk__iclocitem__c/' + tempConRec.rstk__iclocitem_icitem__c + '/view';
                tempConRec.FromLocID = '/lightning/r/rstk__iclocitem__c/' + tempConRec.rstk__iclocitem_locid__c + '/view';
                tempConRec.itemName = tempConRec.rstk__iclocitem_icitem__r.Name;
                tempConRec.fromLocID = tempConRec.rstk__iclocitem_locid__r.Name;
                tempConList.push(tempConRec);
            });
            console.log(this.tempConList);
            this.consData = tempConList;
            console.log(this.consData);
            this.isLoading = false;
        } else if (result.error) {
            this.error = result.error;
        }
    }
    toastEventFire(title,msg,variant){
        const e = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant,
        });
        this.dispatchEvent(e);
    } 
}