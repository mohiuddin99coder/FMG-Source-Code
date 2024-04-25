/**
 * Created by inscorea on 6/13/2023.
 */

@RestResource(UrlMapping='/fmgrsapi/orders/shippingContainers')
global with sharing class FMGRSAPI_OrdersShippingContainers_Rest {

    global class ShippingContainer{
        global Id SalesforceOrderId{get;set;}
        global List<ShippingContainerItem> Products{get;set;}
        global ShippingContainerAddress ShipToAddress{get;set;}
        global String ContainerType{get;set;}
        global String TrackingNumber{get;set;}
        global String CarrierCode{get;set;}
        global String ShipMethod{get;set;}

        public FMGRSAPI_Orders_Service.ShippingContainer getOrderServiceObject(){
            FMGRSAPI_Orders_Service.ShippingContainer newObject = new FMGRSAPI_Orders_Service.ShippingContainer();
            newObject.SalesforceOrderId = this.SalesforceOrderId;
            newObject.ContainerType = this.ContainerType;
            newObject.TrackingNumber = this.TrackingNumber;
            newObject.CarrierCode = this.CarrierCode;
            newObject.ShipMethod = this.ShipMethod;
            if(this.Products != null){
                newObject.Products = new List<FMGRSAPI_Orders_Service.ShippingContainerItem>();
                for(ShippingContainerItem product:Products){
                    newObject.Products.add(product.getOrderServiceObject());
                }
            }
            if(this.ShipToAddress != null){
                newObject.ShipToAddress = this.ShipToAddress.getOrderServiceObject();
            }

            return newObject;
        }
    }

    global class ShippingContainerAddress{
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

    global class ShippingContainerItem{
        global Id SalesforceOrderLineId{get;set;}
        global Integer Quantity { get; set; }
        public FMGRSAPI_Orders_Service.ShippingContainerItem getOrderServiceObject(){
            FMGRSAPI_Orders_Service.ShippingContainerItem newObject = new FMGRSAPI_Orders_Service.ShippingContainerItem();
            newObject.SalesforceOrderLineId = this.SalesforceOrderLineId;
            newObject.Quantity = this.Quantity;
            return newObject;
        }
    }

    @TestVisible
    static FMGRSAPI_Orders_ServiceInterface ordersService {get;set; }
    static{
        ordersService = (FMGRSAPI_Orders_ServiceInterface)new FMGRSAPI_Orders_Service();
    }

    @HttpPost
    global static void doPost(List<ShippingContainer> ShippingContainers){
        System.debug(LoggingLevel.DEBUG, JSON.serializePretty(ShippingContainers));
        RestContext.response.headers.put('Content-Type','application/json');

        try{
            List<FMGRSAPI_Orders_Service.ShippingContainer> convertedShippingContainers = new List<FMGRSAPI_Orders_Service.ShippingContainer>();
            for(ShippingContainer container:ShippingContainers){
                convertedShippingContainers.add(container.getOrderServiceObject());
            }
            RestContext.response.statusCode = 200;
            Map<String, Object> output = ordersService.generateContainers(convertedShippingContainers);
            String jsonOutput = Json.serialize(output);
            RestContext.response.responseBody = Blob.valueOf(jsonOutput);
        }
        catch (FMGRSAPI_Orders_Service.NoShippingHeadersException ex) {
            RestContext.response.statusCode = 500;
            String errorObject = Json.serialize(ex.invalidOrders);
            String inputObject = Json.serialize(ShippingContainers);
            RestContext.response.responseBody = Blob.valueOf('{"Error": "No Valid Shipping Header","BadOrders":' + errorObject +',"Input":'+inputObject+'}');
        }


    }
}