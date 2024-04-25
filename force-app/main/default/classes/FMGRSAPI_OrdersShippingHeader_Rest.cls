/**
 * Created by Adam-Hotmail on 10/12/2023.
 */

@RestResource(UrlMapping='/fmgrsapi/orders/shippingHeader')
global with sharing class FMGRSAPI_OrdersShippingHeader_Rest {

    global class ShipperHeader{
        global String CarrierCode  { get; set; }
        global String SalesforceOrderId { get; set; }
        global ShippingAddress ShippingAddress  { get; set; }
        global String ShipMethod  { get; set; }
        public FMGRSAPI_Orders_Service.ShippingHeader getOrderServiceObject() {
            FMGRSAPI_Orders_Service.ShippingHeader newObject = new FMGRSAPI_Orders_Service.ShippingHeader();
            newObject.CarrierCode = CarrierCode;
            newObject.SalesforceOrderId = SalesforceOrderId;
            newObject.ShippingAddress = ShippingAddress.getOrderServiceObject();
            newObject.ShipMethod = ShipMethod;

            return newObject;
        }

    }

    global class ShippingAddress{
        global String AddressLine1 { get; set; }
        global String AddressLine2 { get; set; }
        global String AddressLine3 { get; set; }
        global String City { get; set; }
        global String ContactName { get; set; }
        global String CompanyName { get; set; }
        global String Country { get; set; }
        global String CountryIso { get; set; }
        global String CustomerName { get; set; }
        global String CustomerNumber { get; set; }
        global String Email { get; set; }
        global String Phone { get; set; }
        global String PostalCode { get; set; }
        global String SalesforceAddressId { get; set; }
        global String State { get; set; }

        public FMGRSAPI_Orders_Service.OrderAddressInfo getOrderServiceObject(){
            FMGRSAPI_Orders_Service.OrderAddressInfo newObject = new FMGRSAPI_Orders_Service.OrderAddressInfo();

            newObject.Address1 = this.AddressLine1;
            newObject.Address2 = this.AddressLine2;
            newObject.Address3 = this.AddressLine3;
            newObject.City = this.City;
            newObject.Contact = this.ContactName;
            newObject.CompanyName = this.CompanyName;
            newObject.Country = this.Country;
            newObject.CountryIso = this.CountryIso;
            newObject.CustName = this.CustomerName;
            newObject.CustNo = this.CustomerNumber;
            newObject.Email = this.Email;
            newObject.Phone = this.Phone;
            newObject.Zip = this.PostalCode;
            newObject.Id = this.SalesforceAddressId;
            newObject.State = this.State;

            return newObject;
        }
    }

    @TestVisible
    static FMGRSAPI_Orders_ServiceInterface ordersService {get;set; }
    static{
        ordersService = (FMGRSAPI_Orders_ServiceInterface)new FMGRSAPI_Orders_Service();
    }

    @HttpPost
    global static void doPost(List<ShipperHeader> shipperHeaders) {
        System.debug(LoggingLevel.DEBUG, JSON.serializePretty(shipperHeaders));


        List<FMGRSAPI_Orders_Service.ShippingHeader> convertedShippingContainers = new List<FMGRSAPI_Orders_Service.ShippingHeader>();
        for(ShipperHeader container:shipperHeaders){
            convertedShippingContainers.add(container.getOrderServiceObject());
        }
        ordersService.updateOrderShippingHeaders(convertedShippingContainers);
        RestContext.response.statusCode = 200;

    }
}