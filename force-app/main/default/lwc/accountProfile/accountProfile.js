import { LightningElement, api, wire } from 'lwc';
import PHONE_FIELD from '@salesforce/schema/Account.Phone';
import BILLING_STATE from '@salesforce/schema/Account.BillingState';
import BILLING_COUNTRY from '@salesforce/schema/Account.BillingCountry';
//import LIFETIME_AMOUNT from '@salesforce/schema/Account.AnnualRevenue';
import LIFETIME_AMOUNT from '@salesforce/schema/Account.Total_Orders_Amount__c';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Account.Name';

export default class AccountProfile extends LightningElement {
  
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: [NAME_FIELD,BILLING_STATE,BILLING_COUNTRY,LIFETIME_AMOUNT]})
    record;
    get name() {
        if(getFieldValue(this.record.data, NAME_FIELD)){

            const nameParts = getFieldValue(this.record.data, NAME_FIELD).split(' ');
            if (nameParts.length > 1) {
                return nameParts[0][0] + nameParts[nameParts.length - 1][0];
            } else {
                return getFieldValue(this.record.data, NAME_FIELD).substring(0, 2);
            }
        }
        return 'UK';
    }
    get accountName() {
        return this.record.data ? getFieldValue(this.record.data, NAME_FIELD) : 'UnknownCustomer';
    }

    get accountState() {
        if(getFieldValue(this.record.data, BILLING_STATE)!=null && getFieldValue(this.record.data, BILLING_COUNTRY)!=null){
            return getFieldValue(this.record.data, BILLING_STATE)+ ', '+getFieldValue(this.record.data, BILLING_COUNTRY);
        }else if(getFieldValue(this.record.data, BILLING_STATE)!=null){
            return getFieldValue(this.record.data, BILLING_STATE);
        }else if(getFieldValue(this.record.data, BILLING_COUNTRY)!=null){
            return getFieldValue(this.record.data, BILLING_COUNTRY);
        }else{
            return '';
        }
    }
    
    get accountLifetimeAmount() {
        if(getFieldValue(this.record.data, LIFETIME_AMOUNT)){
            return '$'+getFieldValue(this.record.data, LIFETIME_AMOUNT);
        }else{
            return '$0';
        }
    }
    /*
    get accountState() {
        return this.record.data ? getFieldValue(this.record.data, BILLING_STATE) : '';
    }
    get accountCountry() {
        return this.record.data ? getFieldValue(this.record.data, BILLING_COUNTRY) : '';
    }*/
}