public class GiftCertificatePaymentCaptrure {
    @InvocableMethod(label='Update Gift Certificate' description='This method is used to Update Gift through OCAPI call' category='OrderSummary')
    Public static void OrderSummaryRelatedOPS(List<List<string>> merchantIDs){
        List<String> merchantIDsList = new List<String>();
        for(List<string> merchantID :merchantIDs){
           merchantIDsList.addAll(merchantID);
        }
        System.debug('merchantIDList:'+merchantIDsList);
        if( merchantIDsList != NULL && !merchantIDsList.isempty()){
            GiftCertificateOCAPI.OCAPIGenerateAccessToken(merchantIDsList);
        }
        
    }
}