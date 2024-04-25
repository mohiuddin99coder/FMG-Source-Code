public class getSFDCProducttoSFCC {
    @InvocableMethod(label='Update Products in SFCC' description='This method is used to Upsert Products in SFCC' category='Product')
    Public static void getProductdetails(List<Product2> productList){
        
        List<id> productIds = new List<id>();
        Integer count=0;
        Integer batchsize = 75; 
        
        FMG_OCAPI_Setting__mdt FMGOCAPISettings = FMG_OCAPI_Setting__mdt.getinstance('FMG_OCAPI');
        if(FMGOCAPISettings.Product_Size__c != Null){
            batchsize = Integer.ValueOf(FMGOCAPISettings.Product_Size__c);
        }
        
        for ( product2 prd : productList){
            productIds.add(prd.id);
            if ( count++ > batchsize){
                System.debug('Processing batch -- productList size: '+productIds.size());
                ProductOMSSFCC.generateAccessTokenMetod(productIds);
                count = 0; //reset count
                productIds.clear() ; // reset list
            }
        }
        System.debug('Processing last batch -- productList size: '+productIds.size());
        if (productIds.size() > 0) // any remaining items
            ProductOMSSFCC.generateAccessTokenMetod(productIds);
    }
}