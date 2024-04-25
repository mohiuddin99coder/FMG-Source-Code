import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/UploadFilesForJewelryMakingContest.UploadFilesForJewelryMakingContest';
import updateAccount from '@salesforce/apex/UpdateAccountFromJewelryForm.updateAccountInfo';
import CASE_OBJECT from '@salesforce/schema/Case';
import Account_OBJECT from '@salesforce/schema/Account';
import CASE_ACCOUNT_RELATION_FIELD from '@salesforce/schema/Case.AccountId';
import SUBJECT_FIELD from '@salesforce/schema/Case.Subject';
import WHAT_JEWELRY_FIELD from '@salesforce/schema/Case.What_Jewlery_Making_Techniques_were_used__c';
import INTERESTING_INFO_FIELD from '@salesforce/schema/Case.Is_there_any_additional_interesting_info__c';
import VALUE_OF_PIECE_FIELD from '@salesforce/schema/Case.Value_of_the_piece_USD__c';
import WHAT_INSPIRATION_FIELD from '@salesforce/schema/Case.What_was_the_inspiration_for_your_design__c';
import ORIGINAL_PIECE_FIELD from '@salesforce/schema/Case.Are_there_any_original_pieces_from_anoth__c';
import LIST_OF_MATERIALS_FIELD from '@salesforce/schema/Case.A_list_of_materials__c';
import REFERENCES_FIELD from '@salesforce/schema/Case.References__c';
import NAME_OF_PIECE_FIELD from '@salesforce/schema/Case.Name_of_piece_being_submitted__c';
import TIMEFRAME_FIELD from '@salesforce/schema/Case.timeframe__c';
import YEAR_FIELD from '@salesforce/schema/Case.year__c';
import OWNER_FIELD from '@salesforce/schema/Case.OwnerId';
import EMAIL_FIELD from '@salesforce/schema/Case.SuppliedEmail';
import PHONE_FIELD from '@salesforce/schema/Case.SuppliedPhone';
import NAME_FIELD from '@salesforce/schema/Case.SuppliedName';
import ORDER_FIELD from '@salesforce/schema/Case.Account_Order_Number__c';
import COMMENT_FIELD from '@salesforce/schema/Case.Description';
import ORIGIN_FIELD from '@salesforce/schema/Case.Origin';
import TYPE_FIELD from '@salesforce/schema/Case.Type';
import ContestQueueId from '@salesforce/label/c.Contest_Queue_Id';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import COUNTRY_CODE from '@salesforce/schema/Account.BillingCountryCode';
import BILLING_STATE_CODE from '@salesforce/schema/Account.BillingStateCode';
import getAddress from '@salesforce/apex/SearchApiAddressCtrl.getAddress';
import getAddressDetailsByPlaceId from '@salesforce/apex/SearchApiAddressCtrl.getPlaceDetails';

//add more field here 
import { createRecord } from 'lightning/uiRecordApi';

export default class FileUploaderCompLwc extends LightningElement {
    _countries = [];
    _countryToStates = {};

    countryvalue;
    statevalue;
    @track isDropdownOpen = false;

    @wire(getPicklistValues, {
        recordTypeId: '$AccountInfo.data.defaultRecordTypeId',
        fieldApiName: COUNTRY_CODE
    })
    wiredCountires({ data }) {
        const countryList = [{ "attributes": null, "label": "United States", "validFor": [], "value": "US" }, { "attributes": null, "label": "Canada", "validFor": [], "value": "CA" },];
        this._countries = data?.values;
        if (this._countries) {
            for (let i = 0; i < this._countries.length; i++) {
                if (this._countries[i].value != 'US' && this._countries[i].value != 'CA') {
                    countryList.push(this._countries[i]);
                }
            }
        }
        this._countries = countryList;
    }

    @wire(getPicklistValues, { recordTypeId: '$AccountInfo.data.defaultRecordTypeId', fieldApiName: BILLING_STATE_CODE })
    wiredStates({ data }) {
        if (!data) {
            return;
        }

        const validForNumberToCountry = Object.fromEntries(Object.entries(data.controllerValues).map(([key, value]) => [value, key]));
        this._countryToStates = data.values.reduce((accumulatedStates, state) => {
            const countryIsoCode = validForNumberToCountry[state.validFor[0]];
            const stateObj = {
                label: state.label,
                value: state.value
            };
            return { ...accumulatedStates, [countryIsoCode]: [...(accumulatedStates?.[countryIsoCode] || []), stateObj] };
        }, {});
    }

    get countryoptions() {
        return this._countries;
    }

    get stateoptions() {
        const selectedCountryStates = this._countryToStates[this.countryvalue] || [];
        return selectedCountryStates.map(item => ({
            label: item.label,
            value: item.value
        }));
    }

    errorlist = [];
    addressRecommendations = [];
    streetvalue = '';
    addressDetail = {};
    city;
    countryvalue1;
    statevalue1;
    pincode;
    state;

    get hasRecommendations() {
        return (this.addressRecommendations !== null && this.addressRecommendations.length);
    }

    handleWindowClick(event) {
        const dropdown = this.template.querySelector('.slds-dropdown');
        if (dropdown && !dropdown.contains(event.target)) {
            this.isDropdownOpen = false;
        }
    }
    
    handlestreetChange(event) {
        event.preventDefault();
        this.streetvalue = event.target.value;
        let searchText = event.target.value;
        if (searchText) this.getAddressRecommendations(searchText);
        else this.addressRecommendations = [];
    }

    getAddressRecommendations(searchText) {
        getAddress({ searchString: searchText })
            .then(response => {
                let addressRecommendations = [];
                response.forEach(prediction => {
                    addressRecommendations.push({
                        main_text: prediction.AddComplete,
                        secondary_text: prediction.AddComplete,
                        place_id: prediction.placeId,
                    });
                });
                this.addressRecommendations = addressRecommendations;
                this.isDropdownOpen = true;
            }).catch(error => {
                console.log('error : ' + JSON.stringify(error));
            });
    }

    resetAddress() {
        this.city = '';
        this.countryvalue1 = '';
        this.pincode = '';
        this.statevalue1 = '';
    }

    handleAddressRecommendationSelect(event) {
        event.preventDefault();
        let placeId = event.currentTarget.dataset.value;
        this.addressRecommendations = [];
        this.streetvalue = '';
        this.resetAddress();


        getAddressDetailsByPlaceId({ placeId: placeId })
            .then(response => {

                response = JSON.parse(response);
                console.log('\n\n\n\naddress component keys(address_components) --> ' + JSON.stringify(Object.keys(response.result.address_components)));
                console.log('\n\n\n\naddress component values(address_components) --> ' + JSON.stringify(Object.values(response.result.address_components)));
                this.cityvalue = '';
                this.countryvalue1 = '';
                this.countryvalue = '';
                this.statevalue1 = '';
                this.zippostalvalue = '';
                this.streetvalue = '';
                console.log('address geometry:---->' + response.result.name);
                const geometryname = response.result.name;
                this.streetvalue = this.streetvalue + ' ' + response.result.name;
                response.result.address_components.forEach((address, index) => {

                    console.log('address.short_name-->' + address.long_name);
                    let type = address.types[0];
                    console.log('type-->' + type);
                    switch (type) {
                        case 'locality':
                            this.cityvalue = address.long_name;
                            console.log('city-->' + this.city);
                            break;
                        case 'country':
                            
                            console.log('address-->' + address);
                            console.log('address.long_name country-->' + address.long_name);
                            console.log('this.streetvalue country-->' + this.streetvalue);
                            this.countryvalue1 = address.short_name;
                            this.countryvalue = address.short_name;
                            break;
                        case 'administrative_area_level_1':
                            console.log('address.statevalue1-->' + address.short_name);
                            this.statevalue1 = address.short_name;
                            break;
                        case 'postal_code':
                            console.log('pincode-->');
                            this.zippostalvalue = address.long_name;
                            break;
                        case 'street_number':
                            if (!geometryname.includes(address.long_name)) {
                                this.streetvalue = address.long_name + ' ' + this.streetvalue;
                            }
                            this.addressDetail.streetNumber = address.long_name;
                            console.log('this.addressDetail.streetNumber-->' + this.addressDetail.streetNumber);
                            break;
                        case 'route':
                            console.log('this.addressDetail.route -->' + this.addressDetail.route);
                            if (!geometryname.includes(address.long_name)) {
                                this.streetvalue = this.streetvalue + ' ' + address.long_name;
                            }
                            this.addressDetail.route = address.long_name;
                            console.log('this.addressDetail.route -->' + this.addressDetail.route);
                            break;
                        case 'sublocality_level_2':
                            this.streetvalue = this.streetvalue + ' ' + address.long_name;
                            this.addressDetail.subLocal2 = address.long_name;
                            console.log('this.addressDetail-->' + this.addressDetail);
                            console.log('this.addressDetail.subLocal2-->' + this.addressDetail.subLocal2);

                            break;
                        case 'sublocality_level_3':
                            this.streetvalue = this.streetvalue + ' ' + address.long_name;
                            console.log('this.addressDetail-->' + this.streetvalue);

                            break;
                        case 'sublocality_level_1':
                            if (response.result.name != address.long_name) {
                                this.streetvalue = this.streetvalue + ' ' + address.long_name;
                            }
                            this.addressDetail.subLocal1 = address.long_name;
                            console.log('this.addressDetail.subLocal1-->' + this.addressDetail.subLocal1);
                            break;

                        default:
                            break;
                    }
                });
            })
            .catch(error => {
                console.log('error : ' + JSON.stringify(error));
            });
    }

    @wire(getRecord, { recordId: '$this.relatedRecordId', fields: [CASE_ACCOUNT_RELATION_FIELD] })
    caseRecord;

    @wire(getObjectInfo, { objectApiName: Account_OBJECT })
    AccountInfo;

    fileData
    fileDatalist = [];
    fileData1
    fileDatalist1 = [];
    fileData2
    fileDatalist2 = [];
    checkboxYes
    @track check = false;
    @track releaseFormMessage;
    @track emailvalue = "";
    @track firstnamevalue = "";
    @track lastnamevalue = "";
    @track companynamevalue = "";
    @track websiteurlvalue = "";
    @track cityvalue = "";
    @track zippostalvalue = "";
    @track phonevalue = "";
    @track twitterprofilevalue = "";
    @track pinterestprofilevalue = "";
    @track instagramprofilevalue = "";
    @track facebookprofilevalue = "";
    @track checkboxnotedvalue = undefined;
    @track nameofpiecevalue = "";
    @track likenotedvalue = "";
    @track interestinginfovalue = "";
    @track valueofpiecevalue = "";
    @track inspirationdesignvalue = "";
    @track referencevalue = "";
    @track materiallistvalue = "";
    @track categoryvalue = '';
    @track countryvalue1 = '';
    @track statevalue1 = '';
    @track selectedcountrylabel = "";
    @track selectedstatelabel = "";
    @track inspirationdesignvalue = "";
    @track timeframe = '';
    @track datevalue = '';
    streetvalue = '';
    caseId = '';
    relatedRecordId;

    @track showSuccessMessage = false;
    @track errorMessage;
    @track pieceValueErrorMessage;
    @track emailErrorMessage;
    @track WebsiteErrorMessage;
    @track nameErrorMessage;
    @track firstNameErrorMessage;
    @track lastNameErrorMessage;
    @track categoryErrorMessage;
    @track streetErrorMessage;
    @track ReferencesErrorMessage;
    @track cityErrorMessage;
    @track countryErrorMessage;
    @track stateErrorMessage;
    @track zipPostalErrorMessage;
    @track phoneErrorMessage;
    @track nameofPieceErrorMessage;
    @track ListOfMaterialErrorMessage;
    @track filesSize = 0;
    @track filesSize1 = 0;
    @track filesSize2 = 0;
    @track displayDiv = false;
    @track isNameEmpty = false;
    @track isNotValidName = false;
    @track isNotValidFirstName = false;
    @track isNotValidLastName = false;
    @track isNotValidStreet = false;
    @track isNotValidreference = false;
    @track isNotValidCity = false;
    @track isNotValidZip = false;
    @track isNotValidPhone = false;
    @track isNotValidNameofPiece = false;
    @track isNotValidListOfMaterial = false;

    @track FilesizeErrorMessage;
    @track FilesizeErrorMessage1;
    @track FilesizeErrorMessage2;
    @track isNotValidEmail = false;

    CheckboxOptions = [
        { label: 'Yes', value: 'true' },
        { label: 'No', value: 'false' },
        // Add more color options as needed
    ];
    get categoryOptions() {
        return [
            { label: 'Wirework & Chainmaille', value: 'Wirework & Chainmaille' },
            { label: 'Metal Clay', value: 'Metal Clay' },
            { label: 'Metalwork', value: 'Metalwork' },
            { label: 'Crystal & Glass', value: 'Crystal & Glass' },
            { label: 'Seed Beads', value: 'Seed Beads' },
        ];
    }

    connectedCallback() {
        // Get the current URL
        window.addEventListener('click', this.handleWindowClick.bind(this));
        const url = window.location.href;
        console.log('URL-------------> ' + url);
        const urlLink = new URL(url);
        const searchParams = new URLSearchParams(urlLink.search);
        this.timeframe = searchParams.get('timeframe');
        this.datevalue = searchParams.get('date');
        const inputDate = new Date(this.timeframe);

        inputDate.setHours(inputDate.getHours() + 8);

        // Format the updated date in ISO 8601 format
        const updatedDateString = inputDate.toISOString();

        console.log('updatedDateString' + updatedDateString);
        this.timeframe = updatedDateString;
        console.log('timeframe-------------> ' + this.timeframe);
        console.log('dateframe-------------> ' + this.datevalue);
    }

    disconnectedCallback() {
        window.removeEventListener('click', this.handleWindowClick.bind(this));
    }




    handlecountryChange(e) {
        this.countryvalue = e.detail.value;
        this.countryvalue1 = e.detail.value;


        // Get the selected country label
        const selectedCountry = this._countries.find(item => item.value === e.detail.value);
        if (selectedCountry) {
            const selectedCountryLabel = selectedCountry.label;
            this.selectedcountrylabel = selectedCountryLabel;
            this.statevalue1 = '';
            console.log('Selected Country Label: ' + selectedCountryLabel);
        }
    }

    handlestateChange(e) {
        this.statevalue = e.detail.value;
        this.statevalue1 = e.detail.value;

        // Get the selected state labeldetail
        const selectedState = this.stateoptions.find(item => item.value === e.detail.value);
        if (selectedState) {
            const selectedStateLabel = selectedState.label;
            this.selectedstatelabel = selectedStateLabel;
            console.log('Selected State Label: ' + selectedStateLabel);
        }
    }


    handlefirstNameChange(event) {
        this.firstnamevalue = event.target.value;
    }
    handlelastNameChange(event) {
        this.lastnamevalue = event.target.value;
    }
    handleCompanyNameChange(event) {
        this.companynamevalue = event.target.value;
    }
    handleWebsiteUrlChange(event) {
        this.websiteurlvalue = event.target.value;
    }
    handlecityChange(event) {
        this.cityvalue = event.target.value;
    }
    handleZipPostalChange(event) {
        this.zippostalvalue = event.target.value;
    }
    handlePhoneChange(event) {
        this.phonevalue = event.target.value;
    }
    handleEmailChange(event) {
        this.emailvalue = event.target.value;
    }
    handleTwitterprofileChange(event) {
        this.twitterprofilevalue = event.target.value;
    }
    handlePinterestProfileChange(event) {
        this.pinterestprofilevalue = event.target.value;
    }
    handleInstagramProfileChange(event) {
        this.instagramprofilevalue = event.target.value;
    }
    handleFacebookProfileChange(event) {
        this.facebookprofilevalue = event.target.value;
    }
    handleNameofPieceChange(event) {
        this.nameofpiecevalue = event.target.value;
    }
    handleChange(event) {
        this.categoryvalue = event.target.value;
    }
    handlelikeNotedChange(event) {
        this.likenotedvalue = event.target.value;
    }
    handleinterestingInfoChange(event) {
        this.interestinginfovalue = event.target.value;
    }
    handleKeyDown(event) {
        const allowedCharacters = [','];

        if (allowedCharacters.includes(event.key)) {
            event.preventDefault();
        }
    }
    handlevalueOfPieceChange(event) {
        this.valueofpiecevalue = event.target.value;
        console.log('this.valueofpiecevalue:' + this.valueofpiecevalue)

    }
    handleInspirationDesignChange(event) {
        this.inspirationdesignvalue = event.target.value;
    }
    handlenotedCheckboxChange(event) {
        this.checkboxnotedvalue = event.target.value;
        console.log('typeof: ' + typeof this.checkboxnotedvalue);
        if (this.checkboxnotedvalue == 'true') {
            this.checkboxYes = true;
        } else {
            this.checkboxYes = false;
        }
        console.log('checkboxVals: ' + this.checkboxnotedvalue);
    }
    handleReferencesChange(event) {
        this.referencevalue = event.target.value;
    }
    handleMaterialListChange(event) {
        this.materiallistvalue = event.target.value;
    }
    handleChangeCheckbox(event) {
        const isChecked = event.target.checked;
        this.check = isChecked;
        console.log('type of check' + typeof isChecked);
        console.log('isChecked:' + isChecked);
    }


    openfileUpload(event) {
        try {
            var files = JSON.stringify(event.target.files[0]);
            this.fileDatalist = [];
            this.filesSize = 0;
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
                            this.filesSize = this.filesSize + base64.length;
                            console.log(" all Filessize:" + this.filesSize);
                            if (this.filesSize > 4000000) {
                                this.FilesizeErrorMessage = 'The file sizes should not be more than 4 mb';
                            } else {
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
            this.fileDatalist1 = [];
            this.filesSize1 = 0;
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
                            this.filesSize1 = this.filesSize1 + base64.length;
                            console.log(" all Filessize1:" + this.filesSize1);
                            if (this.filesSize1 > 4000000) {
                                this.FilesizeErrorMessage1 = 'The file sizes should not be more than 4 mb';
                            } else {
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

    openfileUpload2(event) {
        try {
            var files = JSON.stringify(event.target.files[0]);
            this.fileDatalist2 = [];
            this.filesSize2 = 0;
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
                            this.filesSize2 = this.filesSize2 + base64.length;
                            console.log(" all Filessize2:" + this.filesSize2);
                            if (this.filesSize2 > 4000000) {
                                this.FilesizeErrorMessage2 = 'The file sizes should not be more than 4 mb';
                            } else {
                                this.FilesizeErrorMessage2 = '';
                            }

                            this.fileData2 = {
                                'filename': file.name,
                                'base64': base64
                            };
                            this.fileDatalist2.push(this.fileData2);
                        }
                    };
                })(file);

                reader.readAsDataURL(file);
            }
        } catch (error) {
            console.error("Error uploading files:", error);
        }

    }

    handleClick(event) {
        console.log("size of total files1: " + this.filesSize);
        console.log("size of total files2: " + this.filesSize1);
        const isValid = isValidEmail(this.emailvalue);
        console.log(isValid);
        const emailPattern = /[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,7}$/;
        const emailPatternvalue = emailPattern.test(this.emailvalue);
        console.log('phone: ' + emailPatternvalue);

        const piecevaluePattern = /^[0-9]*(\.[0-9]{0,2})?$/;
        const piecevaluePatternvalue = piecevaluePattern.test(this.valueofpiecevalue);
        console.log('phone: ' + piecevaluePatternvalue);

        const websitePattern = /[Hh][Tt][Tt][Pp][Ss]?:\/\/(?:(?:[a-zA-Z\u00a1-\uffff0-9]+-?)*[a-zA-Z\u00a1-\uffff0-9]+)(?:\.(?:[a-zA-Z\u00a1-\uffff0-9]+-?)*[a-zA-Z\u00a1-\uffff0-9]+)*(?:\.(?:[a-zA-Z\u00a1-\uffff]{2,}))(?::\d{2,5})?(?:\/[^\s]*)?/;
        const websitePatternvalue = websitePattern.test(this.websiteurlvalue);
        console.log('website: ' + websitePatternvalue);

        const pattern = /^[\d()\s+\-.]{7,16}$/;
        const phonepatternvalue = pattern.test(this.phonevalue);
        console.log('phone: ' + phonepatternvalue);

        const trimmedfirstnameValue = this.firstnamevalue.trim();
        this.isNotValidFirstName = false;
        if (trimmedfirstnameValue === '') {
            this.isNotValidFirstName = true;
        }
        //
        const trimmedcityValue = this.cityvalue.trim();
        this.isNotValidCity = false;
        if (trimmedcityValue === '') {
            this.isNotValidCity = true;
        }
        const trimmedzipValue = this.zippostalvalue.trim();
        this.isNotValidZip = false;
        if (trimmedzipValue === '') {
            this.isNotValidZip = true;
        }
        const trimmedphoneValue = this.phonevalue.trim();
        this.isNotValidPhone = false;
        if (trimmedphoneValue === '') {
            this.isNotValidPhone = true;
        }

        const trimmednameofpieceValue = this.nameofpiecevalue.trim();
        this.isNotValidNameofPiece = false;
        if (trimmednameofpieceValue === '') {
            this.isNotValidNameofPiece = true;
        }

        const trimmedlastnameValue = this.lastnamevalue.trim();
        this.isNotValidLastName = false;
        if (trimmedlastnameValue === '') {
            this.isNotValidLastName = true;
        }
        const trimmedStreetsValue = this.streetvalue.trim();
        this.isNotValidStreet = false;
        if (trimmedStreetsValue === '') {
            this.isNotValidStreet = true;
        }
        const trimmedreferenceValue = this.referencevalue.trim();
        this.isNotValidreference = false;
        if (trimmedreferenceValue === '') {
            this.isNotValidreference = true;
        }
        const trimmedlistofmaterialValue = this.materiallistvalue.trim();
        this.isNotValidListOfMaterial = false;
        if (trimmedlistofmaterialValue === '') {
            this.isNotValidListOfMaterial = true;
        }
        const trimmedEmailValue = this.emailvalue.trim();
        this.isNotValidEmail = false;
        if (trimmedEmailValue === '') {
            this.isNotValidEmail = true;
        }
        console.log('test1' + this.checkboxnotedvalue === 'false');
        console.log('test2' + this.checkboxnotedvalue);
        console.log('test2' + this.countryvalue1);
        console.log('test2' + this.statevalue1);
        console.log(this.countryvalue1 == 'US');
        console.log(this.statevalue1 != '');
        console.log('country not us and Canada' + this.countryvalue1 != 'US' && this.countryvalue1 != 'CA');
        console.log((this.countryvalue1 == 'US' && this.statevalue1 != '') || this.countryvalue1 != 'US');
        if (this.fileDatalist.length != 0 && this.categoryvalue != '' && this.countryvalue1 != '' && ((this.countryvalue1 == 'US' && this.statevalue1 != '') || (this.countryvalue1 == 'CA' && this.statevalue1 != '') || (this.countryvalue1 != 'US' && this.countryvalue1 != 'CA')) && this.emailvalue != '' && this.streetvalue != '' && this.firstnamevalue != '' && this.cityvalue != '' && this.zippostalvalue != '' && this.phonevalue != '' && phonepatternvalue == true && ((this.valueofpiecevalue != '' && piecevaluePatternvalue == true) || this.valueofpiecevalue == '') && emailPatternvalue == true && this.isNotValidListOfMaterial == false && ((this.websiteurlvalue != '' && websitePatternvalue == true) || this.websiteurlvalue == '') && this.nameofpiecevalue != '' && ((this.checkboxnotedvalue === 'true' && this.isNotValidreference == false) || this.checkboxnotedvalue === 'false' || this.checkboxnotedvalue === undefined) && isValid && this.isNotValidPhone == false && this.isNotValidCity == false && this.isNotValidZip == false && this.isNotValidNameofPiece == false && this.isNotValidFirstName == false && this.isNotValidLastName == false && this.isNotValidStreet == false && this.isNotValidEmail == false && this.filesSize <= 4000000 && this.filesSize1 <= 4000000 && this.filesSize2 <= 4000000 && this.check == true) {
            console.log("Inside if: ");
            this.categoryErrorMessage = '';
            this.emailErrorMessage = '';
            this.WebsiteErrorMessage = '';
            this.releaseFormMessage = '';
            this.nameErrorMessage = '';
            this.pieceValueErrorMessage = '';
            this.firstNameErrorMessage = '';
            this.lastNameErrorMessage = '';
            this.streetErrorMessage = '';
            this.ReferencesErrorMessage = '';
            this.ListOfMaterialErrorMessage = '';
            this.cityErrorMessage = '';
            this.countryErrorMessage = '';
            this.stateErrorMessage = '';
            this.zipPostalErrorMessage = '';
            this.phoneErrorMessage = '';
            this.nameofPieceErrorMessage = '';
            this.FilesizeErrorMessage = '';
            this.FilesizeErrorMessage1 = '';
            this.FilesizeErrorMessage2 = '';
            this.displayDiv = false;
            const fields = {};
            fields[SUBJECT_FIELD.fieldApiName] = this.categoryvalue;//added subject as per Name
            fields[EMAIL_FIELD.fieldApiName] = this.emailvalue;
            fields[PHONE_FIELD.fieldApiName] = this.phonevalue;
            fields[NAME_FIELD.fieldApiName] = this.firstnamevalue + ' ' + this.lastnamevalue;
            fields[WHAT_JEWELRY_FIELD.fieldApiName] = this.likenotedvalue;
            fields[INTERESTING_INFO_FIELD.fieldApiName] = this.interestinginfovalue;
            console.log('Value of peice:' + this.valueofpiecevalue);
            fields[VALUE_OF_PIECE_FIELD.fieldApiName] = this.valueofpiecevalue;
            fields[WHAT_INSPIRATION_FIELD.fieldApiName] = this.inspirationdesignvalue;
            fields[ORIGINAL_PIECE_FIELD.fieldApiName] = this.checkboxnotedvalue;
            console.log('ORIGINAL_PIECE_FIELD:' + this.materiallistvalue);
            console.log('ORIGINAL_PIECE_FIELD:' + typeof this.nameofpiecevalue);
            fields[LIST_OF_MATERIALS_FIELD.fieldApiName] = this.materiallistvalue;
            fields[REFERENCES_FIELD.fieldApiName] = this.referencevalue;
            fields[NAME_OF_PIECE_FIELD.fieldApiName] = this.nameofpiecevalue;
            console.log("this.timeframe: " + this.timeframe);
            if (this.timeframe != null) {
                fields[TIMEFRAME_FIELD.fieldApiName] = this.timeframe;
            }
            if (this.datevalue != null) {
                fields[YEAR_FIELD.fieldApiName] = this.datevalue;
            }
            fields[OWNER_FIELD.fieldApiName] = ContestQueueId;
            fields[ORIGIN_FIELD.fieldApiName] = 'Web';
            fields[TYPE_FIELD.fieldApiName] = 'JewelryForm';
            console.log('ORIGINAL_PIECE_FIELD:' + typeof this.nameofpiecevalue);
            console.log('ORIGINAL_PIECE_FIELD:' + this.nameofpiecevalue);
            console.log('EMAIL_FIELD:' + EMAIL_FIELD);
            console.log('SUBJECT_FIELD:' + SUBJECT_FIELD);
            console.log('NAME_FIELD:' + NAME_FIELD);
            console.log('ORDER_FIELD:' + ORDER_FIELD);
            console.log('COMMENT_FIELD:' + COMMENT_FIELD);

            const caseRecord = { apiName: CASE_OBJECT.objectApiName, fields: fields };
            createRecord(caseRecord)
                .then(result => {
                    const caseId = result.id;
                    if (caseId != null) {
                        this.showSuccessMessage = true;
                        setTimeout(() => {
                            this.showSuccessMessage = false;
                        }, 5000); // 5 seconds

                    }
                    console.log('Caseid====>' + caseId);
                    this.relatedRecordId = caseId;
                    console.log('relatedRecordId====>' + this.relatedRecordId);
                    console.log('fileDatalist====>' + this.fileDatalist.length);

                    uploadFile({ filesToInsert: this.fileDatalist, recordId: caseId, website: this.websiteurlvalue }).then(result1 => {
                        console.log('Success message====>' + result1);
                        this.fileDatalist = null
                        let title = `Files uploaded successfully!!`
                        this.toast(title)
                        this.categoryvalue = '';
                        this.emailvalue = '';
                        this.firstnamevalue = '';
                        this.lastnamevalue = '';
                        this.countryvalue1 = '';
                        this.zippostalvalue = '';
                        this.nameofpiecevalue = '';
                        this.companynamevalue = '';
                        this.likenotedvalue = '';
                        this.checkboxYes = undefined;
                        console.log('checkboxYes' + typeof this.checkboxYes);
                        console.log('checkboxYes' + this.checkboxYes);
                        this.interestinginfovalue = '';
                        this.websiteurlvalue = '';
                        this.twitterprofilevalue = '';
                        this.referencevalue = '';
                        this.pinterestprofilevalue = '';
                        this.instagramprofilevalue = '';
                        this.valueofpiecevalue = '';
                        this.inspirationdesignvalue = '';
                        this.checkboxnotedvalue = undefined;
                        console.log('checkboxnotedvalue' + this.checkboxnotedvalue);
                        console.log('checkboxnotedvalue' + typeof this.checkboxnotedvalue);
                        this.facebookprofilevalue = '';
                        this.materiallistvalue = '';
                        this.statevalue1 = '';
                        this.cityvalue = '';
                        this.zippostalvalue = '';
                        this.phonevalue = '';
                        this.streetvalue = '';
                        this.fileData = '';
                        this.fileDatalist = [];
                        this.filesSize = 0;
                        this.check = false;
                        console.log('this.check1' + this.check);
                        console.log('this.check' + typeof this.check);


                    }).catch(error => {
                        var errorString = JSON.stringify(error);
                        console.log('error message message====>' + errorString);
                    })
                    uploadFile({ filesToInsert: this.fileDatalist1, recordId: caseId }).then(result1 => {
                        console.log('Success message====>' + result1);
                        this.fileDatalist = null
                        let title = `Files uploaded successfully!!`
                        this.toast(title)
                        this.fileData1 = '';
                        this.fileDatalist1 = [];
                        this.filesSize1 = 0;

                    }).catch(error => {
                        var errorString = JSON.stringify(error);
                        console.log('error message message====>');
                    })
                    uploadFile({ filesToInsert: this.fileDatalist2, recordId: caseId }).then(result1 => {
                        console.log('Success message====>' + result1);
                        this.fileDatalist = null
                        let title = `Files uploaded successfully!!`
                        this.toast(title)
                        this.fileData2 = '';
                        this.fileDatalist2 = [];
                        this.filesSize2 = 0;

                    }).catch(error => {
                        var errorString = JSON.stringify(error);
                        console.log('error message message====>');
                    })
                    console.log('This.state: ' + this.statevalue1);
                    console.log('This.country: ' + this.countryvalue1);
                    console.log('This.state: ' + this.selectedstatelabel);
                    console.log('This.country: ' + this.selectedcountrylabel);
                    console.log('This.state: ' + typeof this.statevalue1);
                    console.log('This.country: ' + typeof this.selectedcountrylabel);
                    updateAccount({ recordId: this.relatedRecordId, website: this.websiteurlvalue, street: this.streetvalue, company: this.companynamevalue, city: this.cityvalue, country: this.countryvalue1, countrylabel: this.selectedcountrylabel, state: this.statevalue1, statelabel: this.selectedstatelabel, zip: this.zippostalvalue, phone: this.phonevalue, twitter: this.twitterprofilevalue, pinterest: this.pinterestprofilevalue, instagram: this.instagramprofilevalue, facebook: this.facebookprofilevalue })
                        .then(result => {
                            console.log('result caseID:' + result);
                        })
                        .catch(error => {
                            console.error('Error calling Apex method:', error);
                        });
                    console.log('1 End of created record');
                    displayMessage({ msg: 'Form Submitted Successfully', success: true });
                }
                )
                .catch(error => {
                    console.log("Unable to Submit Form");
                    displayMessage({ msg: 'Unable to Submit Form', success: false });

                })
            console.log('*** end createRecord *** ');
        } else {
            this.errorlist = [];
            this.displayDiv = true;

            if (this.firstnamevalue === '' || this.isNotValidFirstName == true) {
                this.firstNameErrorMessage = 'This field is required and cannot be empty';
                const inputField = this.template.querySelector('.fname'); // Replace with the actual class or id of your input field
        if (inputField) {
            this.errorlist=[inputField] ;
        }
            } else {
                this.firstNameErrorMessage = '';
            }
            if (this.lastnamevalue === '' || this.isNotValidLastName == true) {
                this.lastNameErrorMessage = 'This field is required and cannot be empty';
                const inputField = this.template.querySelector('.lname'); // Replace with the actual class or id of your input field
        if (inputField) {
            this.errorlist= [...this.errorlist , inputField] ;
        }
            } else {
                this.lastNameErrorMessage = '';
            }
            if (websitePatternvalue == false && this.websiteurlvalue != '') {
                this.WebsiteErrorMessage = 'Please enter a valid website.';
                const inputField = this.template.querySelector('.website'); // Replace with the actual class or id of your input field
        if (inputField) {
            this.errorlist= [...this.errorlist , inputField] ;
        }
            }
            else {
                this.WebsiteErrorMessage = '';
            }
            if (this.streetvalue === '' || this.isNotValidStreet == true) {
                this.streetErrorMessage = 'This field is required and cannot be empty';
                const inputField = this.template.querySelector('.street'); // Replace with the actual class or id of your input field
        if (inputField) {
            this.errorlist= [...this.errorlist , inputField] ;
        }
            } else {
                this.streetErrorMessage = '';
            }
            if (this.cityvalue === '' || this.isNotValidCity == true) {
                this.cityErrorMessage = 'This field is required and cannot be empty';
                const inputField = this.template.querySelector('.city'); // Replace with the actual class or id of your input field
        if (inputField) {
            this.errorlist= [...this.errorlist , inputField] ;
        }
            } else {
                this.cityErrorMessage = '';
            }
            if (this.countryvalue1 === '') {
                this.countryErrorMessage = 'This field is required and cannot be empty';
                const inputField = this.template.querySelector('.country'); // Replace with the actual class or id of your input field
        if (inputField) {
            this.errorlist= [...this.errorlist , inputField] ;
        }
            } else {
                this.countryErrorMessage = '';
            }
            if (this.countryvalue1 == 'US' && this.statevalue1 == '') {
                this.stateErrorMessage = 'This field is required If the country is US';
                const inputField = this.template.querySelector('.state'); // Replace with the actual class or id of your input field
        if (inputField) {
            this.errorlist= [...this.errorlist , inputField] ;
        }
            } else if (this.countryvalue1 == 'CA' && this.statevalue1 == '') {
                this.stateErrorMessage = 'This field is required If the country is CA';
                const inputField = this.template.querySelector('.state'); // Replace with the actual class or id of your input field
        if (inputField) {
            this.errorlist= [...this.errorlist , inputField] ;
        }
            } else {
                this.stateErrorMessage = '';
            }
            if (this.zippostalvalue === '' || this.isNotValidZip == true) {
                this.zipPostalErrorMessage = 'This field is required and cannot be empty';
                const inputField = this.template.querySelector('.zipcode'); // Replace with the actual class or id of your input field
        if (inputField) {
            this.errorlist= [...this.errorlist , inputField] ;
        }
            } else {
                this.zipPostalErrorMessage = '';
            } if (this.phonevalue === '' || this.isNotValidPhone == true) {
                this.phoneErrorMessage = 'This field is required and cannot be empty';
                const inputField = this.template.querySelector('.phone'); // Replace with the actual class or id of your input field
        if (inputField) {
            this.errorlist= [...this.errorlist , inputField] ;
        }
            } else if (phonepatternvalue == false) {
                this.phoneErrorMessage = 'Please enter a valid phone number';
                const inputField = this.template.querySelector('.phone'); // Replace with the actual class or id of your input field
        if (inputField) {
            this.errorlist= [...this.errorlist , inputField] ;
        }
            } else {
                this.phoneErrorMessage = '';
            }
            if (this.emailvalue === '' || this.isNotValidEmail == true) {
                this.emailErrorMessage = 'This field is required and cannot be empty';
                const inputField = this.template.querySelector('.emailValidate'); // Replace with the actual class or id of your input field
        if (inputField) {
            this.errorlist= [...this.errorlist , inputField] ;
        }
            } else if (!isValid || emailPatternvalue == false) {
                this.emailErrorMessage = 'You have entered an invalid format.';
                const inputField = this.template.querySelector('.emailValidate'); // Replace with the actual class or id of your input field
        if (inputField) {
            this.errorlist= [...this.errorlist , inputField] ;
        }
            }
            else {
                this.emailErrorMessage = '';
            }
            if (this.nameofpiecevalue === '' || this.isNotValidNameofPiece == true) {
                this.nameofPieceErrorMessage = 'This field is required and cannot be empty';
                const inputField = this.template.querySelector('.nameofpiecevalue'); // Replace with the actual class or id of your input field
        if (inputField) {
            this.errorlist= [...this.errorlist , inputField] ;
        }
            } else {
                this.nameofPieceErrorMessage = '';
            }
            
            if (!this.categoryvalue) {
                this.categoryErrorMessage = 'This field is required and cannot be empty';
                const inputField = this.template.querySelector('.category'); // Replace with the actual class or id of your input field
        if (inputField) {
            this.errorlist= [...this.errorlist , inputField] ;
        }
            } else {
                this.categoryErrorMessage = '';
            }
            if (piecevaluePatternvalue == false && this.valueofpiecevalue != '') {
                this.pieceValueErrorMessage = 'Please enter valid amount.';
                const inputField = this.template.querySelector('.valueofpiecevalue'); // Replace with the actual class or id of your input field
        if (inputField) {
            this.errorlist= [...this.errorlist , inputField] ;
        }
            }
            else {
                this.pieceValueErrorMessage = '';
            }
            if (this.checkboxnotedvalue === 'true' && this.isNotValidreference == true) {
                this.ReferencesErrorMessage = 'This field is required and cannot be empty';
                const inputField = this.template.querySelector('.references'); // Replace with the actual class or id of your input field
        if (inputField) {
            this.errorlist= [...this.errorlist , inputField] ;
        }
            } else {
                this.ReferencesErrorMessage = '';
            }
            if (this.materiallistvalue === '' || this.isNotValidListOfMaterial == true) {
                this.ListOfMaterialErrorMessage = 'This field is required and cannot be empty';
                const inputField = this.template.querySelector('.materiallistvalue'); // Replace with the actual class or id of your input field
        if (inputField) {
            this.errorlist= [...this.errorlist , inputField] ;
        }
            } else {
                this.ListOfMaterialErrorMessage = '';
            }
            
            if (this.filesSize > 4000000) {
                this.FilesizeErrorMessage = 'The file sizes should not be more than 4 mb';
                this.fileDatalist = [];
                const inputField = this.template.querySelector('.browsePhoto1'); // Replace with the actual class or id of your input field
        if (inputField) {
            this.errorlist= [...this.errorlist , inputField] ;
        }
            } else if (this.fileDatalist.length === 0) {
                const inputField = this.template.querySelector('.browsePhoto1'); // Replace with the actual class or id of your input field
        if (inputField) {
            this.errorlist= [...this.errorlist , inputField] ;
        }
            }
            else {
                this.FilesizeErrorMessage = '';
            }
            if (this.filesSize1 > 4000000) {
                this.FilesizeErrorMessage1 = 'The file sizes should not be more than 4 mb';
                this.fileDatalist1 = [];
                const inputField = this.template.querySelector('.browsePhoto2'); // Replace with the actual class or id of your input field
        if (inputField) {
            this.errorlist= [...this.errorlist , inputField] ;
        }
            } else {
                this.FilesizeErrorMessage1 = '';
            }
            if (this.filesSize2 > 4000000) {
                this.FilesizeErrorMessage2 = 'The file sizes should not be more than 4 mb';
                const inputField = this.template.querySelector('.browsePhoto3'); // Replace with the actual class or id of your input field
        if (inputField) {
            this.errorlist= [...this.errorlist , inputField] ;
        }
                this.fileDatalist2 = [];
            } else {
                this.FilesizeErrorMessage2 = '';
            }
            if (this.check == false) {
                this.releaseFormMessage = 'You must agree to the terms and conditions.';
                const inputField = this.template.querySelector('.releaseFormMessage'); // Replace with the actual class or id of your input field
        if (inputField) {
            this.errorlist= [...this.errorlist , inputField] ;
        }
            } else {
                this.releaseFormMessage = '';
            }
            if(this.errorlist.length>0){
                console.log('this.errorlist==>'+this.errorlist);
                console.log('this.errorlist[0]==>'+this.errorlist[0]);
            this.errorlist[0].focus();
        }
            console.log('Inside else loop1');
            console.log(ShowToastEvent.toastVisible);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Required fieds missing',
                    message: 'Enter required fields',
                    variant: 'error',
                    mode: 'pester'
                }),
            );
        }

    }
    toast(title) {
        const toastEvent = new ShowToastEvent({
            title,
            variant: "success"
        })
        this.dispatchEvent(toastEvent)
    }
}

function isValidEmail(email) {
    const inputElement = document.createElement('input');
    inputElement.type = 'email';
    inputElement.value = email;
    return inputElement.checkValidity();
}
function displayMessage(data) {
    console.log('inside dispMsg' + data);
    var status;
    if (data.success) {
        status = 'alert-success';
    } else {
        status = 'alert-danger';
    }

    var emailSignupMessage = document.querySelector('.email-signup-message');

    if (!emailSignupMessage) {
        console.log("!document.querySelector('.email-signup-message')");

        emailSignupMessage = document.createElement('div');
        emailSignupMessage.className = 'email-signup-message';
        emailSignupMessage.style.position = 'fixed';
        emailSignupMessage.style.transform = 'translate(-50%, 0px)';
        emailSignupMessage.style.display = 'flex';
        emailSignupMessage.style.zIndex = '99';
        emailSignupMessage.style.backgroundColor = '#ebfded';
        emailSignupMessage.style.border = '1px solid #afcaaf';
        emailSignupMessage.style.borderRadius = '5px';
        emailSignupMessage.style.padding = '10px';
        emailSignupMessage.style.fontSize = '16px';
        const mq = window.matchMedia("(min-width: 768px)");
        console.log("screen width >>> " + mq);
        if (mq.matches) {
            console.log('Desktop >>> window width is at least 768px');
            emailSignupMessage.style.left = '75%';
            emailSignupMessage.style.top = '92%';
        } else {
            console.log('Mobile >>> window width is less than 768px');
            emailSignupMessage.style.left = '37%';
            emailSignupMessage.style.top = '95%';
        }
        document.body.appendChild(emailSignupMessage);
    }

    var emailSignupAlert = document.createElement('div');
    emailSignupAlert.className = 'email-signup-alert text-center ' + status;
    emailSignupAlert.textContent = data.msg;

    emailSignupMessage.appendChild(emailSignupAlert);
    setTimeout(() => {
        document.querySelector('.email-signup-message').remove();
    }, 10000);
}