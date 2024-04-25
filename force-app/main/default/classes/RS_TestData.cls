/********************************************************************************************************************************************
 * Name             :   RS_TestData
 * Created By       :   HiBiZ Solutions
 * Created Date     :   8/31/2023
 * Purpose          :   Test data provider class for all RS Customizations
 *
 ********************************************************************************************************************************************/
@isTest
public class RS_TestData {
     public rstk__syconfig__c syconfig = new rstk__syconfig__c(); {
        syconfig.rstk__syconfig_purchase__c = true;
        syconfig.rstk__syconfig_divnumbers__c = 10;
        syconfig.rstk__syconfig_solidworksint__c = false;
        syconfig.rstk__syconfig_multidiv__c = true;
        syconfig.rstk__syconfig_sysrevlvl__c = 2.000000;
        syconfig.rstk__syconfig_intrsiteplng__c = true;
        syconfig.rstk__syconfig_numbauthusers__c = 50;
        syconfig.rstk__syconfig_autocadint__c = false;
        syconfig.rstk__syconfig_mrp__c = true;
        syconfig.rstk__syconfig_inventory__c = true;
        syconfig.rstk__syconfig_gradelvl__c = 999;
        //syconfig.rstk__syconfig_ffinvoice__c = false;
        syconfig.rstk__syconfig_sales__c = true;
        syconfig.rstk__syconfig_intrdivplng__c = true;
        syconfig.rstk__syconfig_subcontract__c = true;
        syconfig.rstk__syconfig_disassembly__c = false;
        syconfig.rstk__syconfig_proditem_bom__c = true;
        syconfig.rstk__syconfig_poloader__c = true;
        syconfig.rstk__syconfig_scheduling__c = true;
        syconfig.rstk__syconfig_numbpayusers__c = 25;
        syconfig.rstk__syconfig_workorder__c = true;
        syconfig.rstk__syconfig_arenaint__c = false;
        syconfig.rstk__syconfig_password__c = '123';
        syconfig.rstk__syconfig_intacctxmlid__c = 'intid';
        syconfig.rstk__syconfig_intacctxmlpw__c = 'intpwd';
        //syconfig.rstk__syconfig_financials__c = 'Rootstock';
        //syconfig.rstk__syconfig_authfinusers__c = 50;
        insert syconfig;
    }

    public rstk__sydefault__c sydefault = new rstk__sydefault__c(); {
        sydefault.Name = 'SYDEFAULT';
        sydefault.rstk__externalid__c = 'SYDEFAULT';
        sydefault.rstk__sydefault_addsfaccount__c = false;
        sydefault.rstk__sydefault_autonumbercust__c = true;
        sydefault.rstk__sydefault_noaddrcust__c = true;
        insert sydefault;  
	}
    public rstk__sycurr__c currencySEK = new rstk__sycurr__c(); {
        currencySEK.Name = 'SEK (Svenska Kronor)';
        currencySEK.rstk__externalid__c = 'SEK';
        currencySEK.rstk__sycurr_currency__c = 'SEK';
        currencySEK.rstk__sycurr_desc__c = 'Svenska Kronor';
        currencySEK.rstk__sycurr_exchrate__c = 1;
        insert currencySEK;
    
    }
    
     rstk__sycmp__c company = new rstk__sycmp__c();{
        company.rstk__sycmp_cmpno__c = 'RSTK';
        company.rstk__sycmp_descr__c = 'Rootstock Solutions LLC';
        company.rstk__sycmp_dim1source__c = 'Division';
        company.rstk__sycmp_dim2source__c = 'Organizational Department';
        company.rstk__sycmp_dim3source__c = 'Inventory Item';
        company.rstk__sycmp_dim4source__c = 'Project';
        company.rstk__sycmp_fifoact__c = false;
        company.rstk__sycmp_numdims__c = '4';
        company.rstk__sycmp_engdivind__c = true;
        company.rstk__sycmp_currmethod__c = 'Use Rootstock';
        company.rstk__sycmp_homecurr__c = currencySEK.Id;
        company.rstk__triggeroptions__c = '{"UT":"1"}';
        insert company;
    }
    public rstk__sydiv__c division = new rstk__sydiv__c(); {
        division.rstk__sydiv_div__c = 'RSTK';
        division.rstk__sydiv_descr__c = 'Rootstock Division';
        division.rstk__externalid__c = 'ZXCVB';
        division.rstk__sydiv_cmpno__c = company.Id;
        division.rstk__sydiv_invdivappl__c = true;
        division.rstk__sydiv_itemprojacctsrcind_pl__c = 'Project';
        division.rstk__sydiv_costtype_pl__c = 'Weighted Average Cost';
        division.rstk__sydiv_initpeitemrevstatus_pl__c = 'Implemented';
        division.rstk__sydiv_revformat_pl__c = 'Numeric'; 
        division.rstk__sydiv_multisiteind__c = true;
        division.rstk__triggeroptions__c = '{"UT":"1"}';
        insert division;
        company.rstk__sycmp_engdiv__c = division.Id;
        company.rstk__triggeroptions__c = '{"ST":"1","SAE":"1"}';
        update company;
    }
    
     public rstk__sydivaddr__c divAddr = new rstk__sydivaddr__c(); {
        divAddr.rstk__sydivaddr_div__c = division.Id;
        divAddr.rstk__sydivaddr_type__c = 'Shipping Address';
        divAddr.rstk__sydivaddr_street__c = '1 Distribution Center Cir # 200';
        divAddr.rstk__sydivaddr_city__c = 'Littleton';
        divAddr.rstk__sydivaddr_zippostalcode__c = '01460';
        divAddr.rstk__sydivaddr_stateprov__c = 'MA';
        divAddr.rstk__sydivaddr_country__c = 'US';
        divAddr.rstk__triggeroptions__c = '{"UT":"1"}';
        insert divAddr;
        division.rstk__sydiv_primeshipaddr__c = divAddr.Id;
        division.rstk__triggeroptions__c = '{"UT":"1"}';
        update division;
    }
    
    List<rstk__syacc__c> syaccts = new List<rstk__syacc__c>();
    rstk__syacc__c cosAcct1 = new rstk__syacc__c(); {
        cosAcct1.Name = '4018000 (4018000-Keys)';
        cosAcct1.rstk__externalid__c = 'KEYSU_4018000-Keys';
        cosAcct1.rstk__syacc_descr__c = '4018000-Keys Blanks';
        cosAcct1.rstk__syacc_div__c = division.Id;
        cosAcct1.rstk__syacc_gltype_pl__c = 'Cost of Sales';
        cosAcct1.rstk__syacc_glxrefacct_name__c = 'Key Blanks';
        cosAcct1.rstk__syacc_mfgacct__c = '4018000';
        syaccts.add(cosAcct1);
    }
        
        rstk__syacc__c cosAcct2 = new rstk__syacc__c(); {
        cosAcct2.Name = '24801 (Recieved not Invoiced)';
        cosAcct2.rstk__externalid__c = 'KEYSU_24801';
        cosAcct2.rstk__syacc_descr__c = '24801-Keys Blanks';
        cosAcct2.rstk__syacc_div__c = division.Id;
        cosAcct2.rstk__syacc_gltype_pl__c = 'Accrued AP';
        cosAcct2.rstk__syacc_glxrefacct_name__c = 'Key Blanks';
        cosAcct2.rstk__syacc_mfgacct__c = '24801';
        syaccts.add(cosAcct2);
    }
    rstk__syacc__c salesAcct = new rstk__syacc__c(); {
        salesAcct.Name = '300700-Gross Revenue Keys (300700-Gross Revenue Keys)';
        salesAcct.rstk__externalid__c = 'KEYSU_300700-Gross Revenue Keys';
        salesAcct.rstk__syacc_descr__c = '300700-Gross Revenue Keys';
        salesAcct.rstk__syacc_div__c = division.Id;
        salesAcct.rstk__syacc_gltype_pl__c = 'Revenue';
        salesAcct.rstk__syacc_glxrefacct_name__c = 'Gross Revenue Keys';
        salesAcct.rstk__syacc_mfgacct__c = '300700-Gross Revenue Keys';
        syaccts.add(salesAcct);
    }

    public rstk__syacc__c vatPayableAcct = new rstk__syacc__c(); {
        vatPayableAcct.rstk__externalid__c = '20010_212500';
        vatPayableAcct.rstk__syacc_descr__c = 'VAT Payable';
        vatPayableAcct.rstk__syacc_div__c = division.Id;
        vatPayableAcct.rstk__syacc_gltype_pl__c = 'Liability Accounts';
        vatPayableAcct.rstk__syacc_glxrefacct_name__c = '212500 (VAT Payable)';
        vatPayableAcct.rstk__syacc_mfgacct__c = '212500';
        syaccts.add(vatPayableAcct);
    }

    public rstk__syacc__c vatReceivableAcct = new rstk__syacc__c(); {
        vatReceivableAcct.rstk__externalid__c = '20010_112500';
        vatReceivableAcct.rstk__syacc_descr__c = 'VAT Receivable';
        vatReceivableAcct.rstk__syacc_div__c = division.Id;
        vatReceivableAcct.rstk__syacc_gltype_pl__c = 'Liability Accounts';
        vatReceivableAcct.rstk__syacc_glxrefacct_name__c = '112500 (VAT Receivable)';
        vatReceivableAcct.rstk__syacc_mfgacct__c = '112500';
        syaccts.add(vatReceivableAcct);
    }

    public rstk__syacc__c vatClearingAcct = new rstk__syacc__c(); {
        vatClearingAcct.rstk__externalid__c = '20010_212501';
        vatClearingAcct.rstk__syacc_descr__c = 'VAT Clearing';
        vatClearingAcct.rstk__syacc_div__c = division.Id;
        vatClearingAcct.rstk__syacc_gltype_pl__c = 'Liability Accounts';
        vatClearingAcct.rstk__syacc_glxrefacct_name__c = '212501 (VAT Clearing)';
        vatClearingAcct.rstk__syacc_mfgacct__c = '212501';
        syaccts.add(vatClearingAcct);
    }

    public rstk__syacc__c cosAcct = new rstk__syacc__c(); {
        cosAcct.Name = '4018001 (4018001-Keys Blanks)';
        cosAcct.rstk__externalid__c = 'KEYSU_4018001-Keys Blanks';
        cosAcct.rstk__syacc_descr__c = '4018001-Keys Blanks';
        cosAcct.rstk__syacc_div__c = division.Id;
        cosAcct.rstk__syacc_gltype_pl__c = 'Cost of Sales Clearing';
        cosAcct.rstk__syacc_glxrefacct_name__c = 'Key Blanks';
        cosAcct.rstk__syacc_mfgacct__c = '4018001';
        syaccts.add(cosAcct);
        insert syaccts;
        //company.rstk__sycmp_apclracct__c = cosAcct.id;
        //company.rstk__triggeroptions__c = '{"UT":"1"}';
        //update company;
    }
    
    public rstk__syorg__c orgDept = new rstk__syorg__c(); {
        orgDept.rstk__syorg_div__c = division.Id;
        orgDept.rstk__syorg_orgid__c = 'Test Org Dept';
        orgDept.rstk__syorg_descr__c = 'Test Description';
        insert orgDept;
    }    

    public rstk__pocntl__c poControl = new rstk__pocntl__c(); {
        poControl.Name = 'Default';
        poControl.rstk__pocntl_div__c = division.Id;
        poControl.rstk__pocntl_sfapprovpohdr__c = true;
        poControl.rstk__pocntl_pricedecimal__c = 2;
        poControl.rstk__pocntl_dateupdate__c = true;
        poControl.rstk__pocntl_dirmtlrequestorg__c = orgDept.Id;
        insert poControl;
    }

     public rstk__socntl__c socntl = new rstk__socntl__c(); {
        socntl.Name = 'Default';
        socntl.rstk__externalid__c = 'SOCNTL';
        socntl.rstk__socntl_div__c = division.Id;
        socntl.rstk__socntl_projdiv__c = division.Id;
        socntl.rstk__triggeroptions__c = '{"UT":"1"}';
        insert socntl;
    }
    
    public rstk__rtlabgrd__c laborGrade = new rstk__rtlabgrd__c();{
        laborGrade.rstk__rtlabgrd_labgrd__c = 'LABRG1';
        laborGrade.rstk__rtlabgrd_div__c = division.Id;
        laborGrade.rstk__rtlabgrd_hrrate__c = 50;
        laborGrade.rstk__rtlabgrd_descr__c = 'test';
        insert laborGrade;
    }
    public rstk__syusr__c mnfUser = new rstk__syusr__c();{
        mnfUser.rstk__syusr_clockno__c = 777777;
        mnfUser.rstk__syusr_dfltdiv__c = division.Id; 
        mnfUser.rstk__syusr_dfltcmpno__c = company.Id;
        mnfUser.rstk__syusr_lastcmpno__c = company.Id;
        mnfUser.rstk__syusr_lastdiv__c = division.Id;
        mnfUser.rstk__syusr_salesdiv__c = division.Id;
        mnfUser.rstk__syusr_lastsalesdiv__c = division.Id;
        mnfUser.rstk__syusr_hrrate__c = 100; 
        mnfUser.rstk__syusr_labgrd__c = laborGrade.Id;
        mnfUser.rstk__syusr_usrno__c = 777777; 
        mnfUser.rstk__syusr_respbuyerind__c = true;
        mnfUser.rstk__syusr_respengind__c = true; 
        mnfUser.rstk__syusr_respinvind__c = true;
        mnfUser.rstk__syusr_employee__c = UserInfo.getUserId();
        mnfUser.Name = 'Manufacture User';
        insert mnfUser;
    }


    public rstk__pjproj__c dfltProj = new rstk__pjproj__c(); {
        dfltProj.rstk__pjproj_div__c = division.Id;
        dfltProj.rstk__pjproj_proj__c = 'Home';
        dfltProj.rstk__pjproj_sochrgallowind__c = true;
        dfltProj.rstk__pjproj_wochrgallowind__c = false;
        dfltProj.rstk__triggeroptions__c = '{"UT":"1"}';
        insert dfltProj;
        division.rstk__sydiv_dflthomeproj__c = dfltProj.Id;
        update division;
    }
    
     public rstk__sysite__c site = new rstk__sysite__c(); {
        site.rstk__sysite_site__c='STE01';
        site.rstk__sysite_descr__c='STE01 Site';
        site.rstk__sysite_div__c = division.Id;
        site.rstk__triggeroptions__c = '{"UT":"1"}';
        site.Name = 'Main Site';
        site.rstk__sysite_street__c = '4900 Service Road';
        site.rstk__sysite_city__c = 'St. Peters';
        site.rstk__sysite_state__c = 'MO';
        site.rstk__sysite_zip__c = '63376';
        site.rstk__sysite_country__c = 'US';
        site.rstk__sysite_phone__c = '800-225-0249';
        site.rstk__sysite_sylocnum_reqind__c = true;
        insert site;
        division.rstk__sydiv_mainsite__c = site.Id;
        update division;
    }

    public rstk__sylocid__c invlocationID = new rstk__sylocid__c(); {
        invlocationID.rstk__sylocid_descr__c = 'Loca';
        invlocationID.rstk__sylocid_div__c = division.Id;
        invlocationID.rstk__sylocid_locid__c = 'LOC';
        invlocationID.rstk__sylocid_site__c = site.Id;
        invlocationID.rstk__sylocid_backflushlocind__c = false;
        invlocationID.rstk__sylocid_rcvginspind__c = false; 
        invlocationID.rstk__sylocid_loctype_pl__c = 'On Hand';
        invlocationID.rstk__sylocid_dfltavailind__c = false;
        insert invlocationID;
    }

    public rstk__syuom__c uomEA = new rstk__syuom__c(); {
        uomEA.name = 'Each';
        uomEA.rstk__syuom_uom__c = 'EA';
        uomEA.rstk__triggeroptions__c = '{"UT":"1"}';
        insert uomEA;
        sydefault.rstk__sydefault_defuom__c = uomEA.Id;
        update sydefault;
    }

   public rstk__socomm__c prdGroup = new rstk__socomm__c(); {
        prdGroup.Name = 'Stock';
        prdGroup.rstk__externalid__c = 'STOCK';
        prdGroup.rstk__socomm_autopo__c = true;
        prdGroup.rstk__socomm_autopodrop__c = true;
        prdGroup.rstk__socomm_comcod__c = 'STOCK';
        prdGroup.rstk__socomm_descr__c = 'STOCK';
        prdGroup.rstk__socomm_dfltqtyord__c = 1;
        prdGroup.rstk__socomm_div__c = division.Id;
        prdGroup.rstk__socomm_firm__c = true;
        prdGroup.rstk__socomm_nopartials__c = true;
        prdGroup.rstk__socomm_nopickifnorcpt__c = true;
        prdGroup.rstk__socomm_oresp__c = mnfUser.Id;
        prdGroup.rstk__socomm_presp__c = mnfUser.Id;
        prdGroup.rstk__socomm_prodtype__c = 'Stock';
        prdGroup.rstk__socomm_qtydecimal__c = 0;
        prdGroup.rstk__socomm_shipdiv__c = division.Id;
        prdGroup.rstk__socomm_slsuom__c = uomEA.Id;
        prdGroup.rstk__socomm_cosacct__c = cosAcct1.Id;
        prdGroup.rstk__socomm_salesacct__c = salesAcct.Id;
        prdGroup.rstk__socomm_cospendacct__c = cosAcct.id;
        prdGroup.rstk__triggeroptions__c = '{"UT":"1"}';
        insert prdGroup;
    }

    public rstk__icconclass__c icconclass = new rstk__icconclass__c(); {
        icconclass.rstk__icconclass_class__c = 'Default Container';
        icconclass.rstk__icconclass_prefix__c = 'DC';
        icconclass.rstk__icconclass_desc__c = 'Default Container Class';
        icconclass.rstk__icconclass_div__c = division.Id;
        insert icconclass;
    }

    public rstk__iccomcod__c commodity = new rstk__iccomcod__c(); {
        commodity.rstk__iccomcod_comcod__c = 'COMMCODE1';
        commodity.rstk__iccomcod_descr__c = 'COMMCODE1';
        commodity.rstk__iccomcod_div__c = division.Id;
        commodity.rstk__iccomcod_engstatus_pl__c = 'Active';
        commodity.rstk__iccomcod_engtype_pl__c = 'Standard';
        commodity.rstk__iccomcod_src_pl__c = 'Manufactured';
        commodity.rstk__iccomcod_dfltenguom__c = uomEA.Id;
        commodity.rstk__iccomcod_dfltinvuom__c = uomEA.Id;
        commodity.rstk__iccomcod_dfltpuruom_po__c = uomEA.Id;
        commodity.rstk__iccomcod_dflttracklot_pl__c = 'No';
        commodity.rstk__iccomcod_dflttracksrl_pl__c = 'No';
        commodity.rstk__iccomcod_mrpplanpol_pl__c = 'Lot for Lot';
        commodity.rstk__iccomcod_mrppolqty__c = 1; 
        commodity.rstk__iccomcod_mrpminqty__c = 0;
        commodity.rstk__iccomcod_mrpmaxqty__c = 0;
        commodity.rstk__iccomcod_abc__c = 'B';
        commodity.rstk__iccomcod_buydiv__c = division.Id;
        commodity.rstk__iccomcod_fifoind__c = false;
        commodity.rstk__iccomcod_dfltshlflifedays__c = 120;
        commodity.rstk__iccomcod_ltfrmwo__c = 1;
        commodity.rstk__iccomcod_ltmfgwopick__c = 1;
        commodity.rstk__iccomcod_ltmfgwoshopflr__c = 5;
        commodity.rstk__iccomcod_ltrcvinsp__c = 1;
        commodity.rstk__iccomcod_qtydecimal__c = 0;
        commodity.rstk__iccomcod_qtydecimal_po__c = 0;
        commodity.rstk__iccomcod_reclass__c = false;
        commodity.rstk__iccomcod_sspolqty__c = 0;
        commodity.rstk__iccomcod_respeng__c = mnfUser.Id;
        commodity.rstk__iccomcod_respinv__c = mnfUser.Id;
        commodity.rstk__triggeroptions__c = '{"UT":"1"}';
        commodity.rstk__iccomcod_dfltconclass__c = icconclass.Id;
        insert commodity;
        division.rstk__sydiv_iccomcod__c = commodity.Id;
        update division;
    }

    public rstk__iccomcod__c purcommodity = new rstk__iccomcod__c(); {
        purcommodity.rstk__iccomcod_comcod__c = 'COMMCODE2';
        purcommodity.rstk__iccomcod_descr__c = 'COMMCODE2';
        purcommodity.rstk__iccomcod_div__c = division.Id;
        purcommodity.rstk__iccomcod_engstatus_pl__c = 'Active';
        purcommodity.rstk__iccomcod_engtype_pl__c = 'Standard';
        purcommodity.rstk__iccomcod_src_pl__c = 'Purchased';
        purcommodity.rstk__iccomcod_dfltenguom__c = uomEA.Id;
        purcommodity.rstk__iccomcod_dfltinvuom__c = uomEA.Id;
        purcommodity.rstk__iccomcod_dfltpuruom_po__c = uomEA.Id;
        purcommodity.rstk__iccomcod_dflttracklot_pl__c = 'No';
        purcommodity.rstk__iccomcod_dflttracksrl_pl__c = 'No';
        purcommodity.rstk__iccomcod_mrpplanpol_pl__c = 'Lot for Lot';
        purcommodity.rstk__iccomcod_mrppolqty__c = 1; 
        purcommodity.rstk__iccomcod_mrpminqty__c = 0;
        purcommodity.rstk__iccomcod_mrpmaxqty__c = 0;
        purcommodity.rstk__iccomcod_abc__c = 'B';
        purcommodity.rstk__iccomcod_buydiv__c = division.Id;
        purcommodity.rstk__iccomcod_fifoind__c = false;
        purcommodity.rstk__iccomcod_dfltshlflifedays__c = 120;
        purcommodity.rstk__iccomcod_ltfrmwo__c = 1;
        purcommodity.rstk__iccomcod_ltmfgwopick__c = 1;
        purcommodity.rstk__iccomcod_ltmfgwoshopflr__c = 5;
        purcommodity.rstk__iccomcod_ltrcvinsp__c = 1;
        purcommodity.rstk__iccomcod_qtydecimal__c = 0;
        purcommodity.rstk__iccomcod_qtydecimal_po__c = 0;
        purcommodity.rstk__iccomcod_reclass__c = false;
        purcommodity.rstk__iccomcod_sspolqty__c = 0;
        purcommodity.rstk__iccomcod_respeng__c = mnfUser.Id;
        purcommodity.rstk__iccomcod_respinv__c = mnfUser.Id;
        purcommodity.rstk__triggeroptions__c = '{"UT":"1"}';
        purcommodity.rstk__iccomcod_dfltconclass__c = icconclass.Id;
        insert purcommodity;
    }

    public rstk__pocomcod__c pocommidity = new rstk__pocomcod__c();{
        pocommidity.rstk__pocomcod_div__c = division.Id;
        pocommidity.rstk__pocomcod_comcod__c = 'Default';
        pocommidity.rstk__pocomcod_desc__c = 'Test PO Commidity Code';
        pocommidity.rstk__pocomcod_respbuyer__c = mnfUser.Id;
        pocommidity.rstk__pocomcod_dfltpuruom__c = uomEA.Id;
        insert pocommidity;
    }

   public rstk__peitem__c enggMfgItem = new rstk__peitem__c(); {
        enggMfgItem.rstk__peitem_item__c = 'M-101';
        enggMfgItem.rstk__peitem_descr__c = 'Mfg Item';
        enggMfgItem.rstk__peitem_div__c = division.Id;
        enggMfgItem.rstk__peitem_invdiv__c = division.Id;
        enggMfgItem.rstk__peitem_enguom__c = uomEA.Id;
        enggMfgItem.rstk__peitem_iccomcod__c = commodity.Id;
        enggMfgItem.rstk__peitem_src_pl__c = 'Manufactured';
        enggMfgItem.rstk__peitem_status_pl__c = 'Active';
        enggMfgItem.rstk__peitem_type_pl__c = 'Standard';
        enggMfgItem.rstk__peitem_tracklot_pl__c = 'no';
        enggMfgItem.rstk__peitem_tracksrl_pl__c = 'Yes';
        enggMfgItem.rstk__triggeroptions__c = '{"UT":"1"}';
        insert enggMfgItem;
    }
    
    public rstk__peitem__c enggPurItem = new rstk__peitem__c(); {
        enggPurItem.rstk__peitem_item__c = 'P-101';
        enggPurItem.rstk__peitem_descr__c = 'Purchased Item';
        enggPurItem.rstk__peitem_div__c = division.Id;
        enggPurItem.rstk__peitem_invdiv__c = division.Id;
        enggPurItem.rstk__peitem_enguom__c = uomEA.Id;
        enggPurItem.rstk__peitem_iccomcod__c = purcommodity.Id;
        enggPurItem.rstk__peitem_src_pl__c = 'Purchased';
        enggPurItem.rstk__peitem_status_pl__c = 'Active';
        enggPurItem.rstk__peitem_type_pl__c = 'Standard';
        enggPurItem.rstk__peitem_tracklot_pl__c = 'no';
        enggPurItem.rstk__peitem_tracksrl_pl__c = 'no';
        enggPurItem.rstk__triggeroptions__c = '{"UT":"1"}';
        insert enggPurItem;
    }

    public rstk__icitem__c inventoryMfgItem = new rstk__icitem__c(); {
        inventoryMfgItem.rstk__icitem_item__c = enggMfgItem.Id;
        inventoryMfgItem.rstk__icitem_div__c = division.Id;
        inventoryMfgItem.rstk__icitem_engdivovr__c = division.Id;
        inventoryMfgItem.rstk__icitem_buydiv__c = division.Id;
        inventoryMfgItem.rstk__icitem_disncmlocid__c = invlocationID.Id;
        inventoryMfgItem.rstk__icitem_disncmlocidind__c = true;
        inventoryMfgItem.rstk__icitem_disncmlocnum__c = 'T__L';
        inventoryMfgItem.rstk__icitem_iccomcod__c = commodity.Id;
        inventoryMfgItem.rstk__icitem_rcptlocid__c = invlocationID.Id;
        inventoryMfgItem.rstk__icitem_rcptlocidind__c = true;
        inventoryMfgItem.rstk__icitem_rcptlocnum__c = 'T__L';
        inventoryMfgItem.rstk__icitem_disscraplocid__c = invlocationID.Id;
        inventoryMfgItem.rstk__icitem_disscraplocidind__c = true;
        inventoryMfgItem.rstk__icitem_disscraplocnum__c = 'T__L';
        inventoryMfgItem.rstk__icitem_disgoodlocid__c = invlocationID.Id;
        inventoryMfgItem.rstk__icitem_disgoodlocidind__c = true;
        inventoryMfgItem.rstk__icitem_disgoodlocnum__c = 'T__L';
        inventoryMfgItem.rstk__icitem_invuom__c = uomEA.Id;
        inventoryMfgItem.rstk__icitem_src_pl__c = 'Manufactured';
        inventoryMfgItem.rstk__icitem_descr__c = 'Manufactured INVENTORY ITEM';
        inventoryMfgItem.rstk__triggeroptions__c = '{"UT":"1"}';
        insert inventoryMfgItem;
    }

    public rstk__icitem__c inventoryPurItem = new rstk__icitem__c(); {
        inventoryPurItem.rstk__icitem_item__c = enggPurItem.Id;
        inventoryPurItem.rstk__icitem_div__c = division.Id;
        inventoryPurItem.rstk__icitem_engdivovr__c = division.Id;
        inventoryPurItem.rstk__icitem_buydiv__c = division.Id;
        inventoryPurItem.rstk__icitem_disncmlocid__c = invlocationID.Id;
        inventoryPurItem.rstk__icitem_disncmlocidind__c = true;
        inventoryPurItem.rstk__icitem_disncmlocnum__c = 'T__L';
        inventoryPurItem.rstk__icitem_iccomcod__c = purcommodity.Id;
        inventoryPurItem.rstk__icitem_rcptlocid__c = invlocationID.Id;
        inventoryPurItem.rstk__icitem_rcptlocidind__c = true;
        inventoryPurItem.rstk__icitem_rcptlocnum__c = 'T__L';
        inventoryPurItem.rstk__icitem_disscraplocid__c = invlocationID.Id;
        inventoryPurItem.rstk__icitem_disscraplocidind__c = true;
        inventoryPurItem.rstk__icitem_disscraplocnum__c = 'T__L';
        inventoryPurItem.rstk__icitem_disgoodlocid__c = invlocationID.Id;
        inventoryPurItem.rstk__icitem_disgoodlocidind__c = true;
        inventoryPurItem.rstk__icitem_disgoodlocnum__c = 'T__L';
        inventoryPurItem.rstk__icitem_invuom__c = uomEA.Id;
        inventoryPurItem.rstk__icitem_src_pl__c = 'Purchased';
        inventoryPurItem.rstk__icitem_descr__c = 'Purchased INVENTORY ITEM';
        inventoryPurItem.rstk__triggeroptions__c = '{"UT":"1"}';
        insert inventoryPurItem;
    }

    public rstk__poitem__c poItem = new rstk__poitem__c(); {
        poItem.rstk__poitem_div__c = division.Id;
        poItem.rstk__poitem_desc__c = 'Test Purchase Item description';
        poItem.rstk__poitem_comcod__c = pocommidity.Id;
        poItem.rstk__poitem_puruom__c = uomEA.Id;
        poItem.rstk__poitem_item__c = inventoryPurItem.Id;
        poItem.rstk__poitem_type__c = 'Purchased';
        poItem.rstk__triggeroptions__c = '{"UT":"1"}';
        insert poItem;
    }

    public rstk__syterms__c terms = new rstk__syterms__c(); {
        terms.rstk__syterms_id__c = 'NET30';
        terms.rstk__externalid__c = 'NET30';
        terms.rstk__syterms_apdiscbasemethod__c = 'Based on Invoice Date';
        terms.rstk__syterms_descr__c = 'Net 30 Days';
        terms.rstk__syterms_dueindays__c = 30;
        terms.rstk__triggeroptions__c = '{"UT":"1"}';
        insert terms;
    }
    
    public rstk__sycarrier__c carrier = new rstk__sycarrier__c(); {
        carrier.rstk__externalid__c = 'FED';
        carrier.rstk__sycarrier_descr__c = 'Fedex';
        carrier.rstk__sycarrier_id__c = 'FED';
        carrier.rstk__triggeroptions__c = '{"UT":"1"}';
        insert carrier;
    }

    public rstk__syfob__c fob = new rstk__syfob__c(); {
        fob.rstk__externalid__c = 'Hand_Deliver';
        fob.rstk__syfob_descr__c = 'Delivery by hand';
        fob.rstk__syfob_id__c = 'Hand_Deliver';
        fob.rstk__triggeroptions__c = '{"UT":"1"}';
        insert fob;
    }

    public rstk__syfrghtrm__c frghtTerm = new rstk__syfrghtrm__c(); {
        frghtTerm.Name = 'N30 (Net amount due in 30 days)';
        frghtTerm.rstk__externalid__c = 'N30';
        frghtTerm.rstk__syfrghtrm_descr__c = 'Net amount due in 30 days';
        frghtTerm.rstk__syfrghtrm_id__c = 'N30';
        frghtTerm.rstk__syfrghtrm_usecustcarr__c = false;
        frghtTerm.rstk__triggeroptions__c = '{"UT":"1"}';
        insert frghtTerm;
    }

    public rstk__syshipviatype__c shipVia = new rstk__syshipviatype__c(); {
        shipVia.Name = 'Hand (Hand Delivery)';
        shipVia.rstk__externalid__c = 'Hand';
        shipVia.rstk__syshipviatype_descr__c = 'Hand Delivery';
        shipVia.rstk__syshipviatype_id__c = 'Hand';
        shipVia.rstk__triggeroptions__c = '{"UT":"1"}';
        insert shipVia;
    }
    
    rstk__socarriervia__c socarriervia = new rstk__socarriervia__c(); {
        socarriervia.rstk__socarriervia_carrier__c = carrier.Id;
        socarriervia.rstk__socarriervia_shipvia__c = shipVia.Id;
        insert socarriervia;
    }
    
        public rstk__sydata__c POAPSydata = new rstk__sydata__c();{
        POAPSydata.rstk__sydata_backgroundprocessing__c = True;
        POAPSydata.rstk__sydata_batchinvoiceamount__c = 100;
        POAPSydata.rstk__sydata_batchinvoicenumber__c = '123456';
        POAPSydata.rstk__sydata_batchnumber__c = '1001';
        POAPSydata.rstk__sydata_duedate__c = Date.today();
        POAPSydata.rstk__sydata_batchinvoicedate__c = Date.today();
        POAPSydata.rstk__sydata_process__c = 'Hold';
        POAPSydata.rstk__sydata_txntype__c = 'PO AP Match Using Detail';
        POAPSydata.rstk__sydata_sydiv__c = division.Id;
        POAPSydata.rstk__sydata_sysite__c = site.Id;
        POAPSydata.rstk__triggeroptions__c = '{"UT":"1"}';
        
        insert POAPSydata;
        }
    
    public rstk__icitemsrl__c srlitem = new rstk__icitemsrl__c();{
        srlitem.rstk__icitemsrl_item__c = inventoryMfgItem.Id;
        srlitem.rstk__icitemsrl_srlno__c = 'RS1';
        srlitem.rstk__triggeroptions__c = '{"UT":"1"}';
         srlitem.rstk__icitemsrl_div__c = division.Id;
         insert srlitem;

    	}
}