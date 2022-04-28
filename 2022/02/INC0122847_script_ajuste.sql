DECLARE

    vr_nrdolote    craplcm.nrdolote%TYPE; 
    vr_cdcritic    crapcri.cdcritic%TYPE;
    vr_dscritic    crapcri.dscritic%TYPE;
    vr_exc_erro    EXCEPTION;
    vr_incrineg    INTEGER;
    vr_tab_retorno LANC0001.typ_reg_retorno;
    rw_crapdat     btch0001.cr_crapdat%rowtype;
                                  
    CURSOR cr_lanc_border IS                     
       SELECT a.cdcooper
             ,a.nrdconta
             ,a.nrdocmto
             ,a.nrborder
             ,c.vltitulo
         FROM tbdsct_lancamento_bordero a
             ,craphis                   b
             ,craptdb                   c
        WHERE a.cdcooper = b.cdcooper
          AND a.cdhistor = b.cdhistor
          AND a.cdcooper = c.cdcooper
          AND a.nrdconta = c.nrdconta
          AND a.nrborder = c.nrborder
          AND a.nrdocmto = c.nrdocmto
          AND a.cdcooper = 9
          AND a.nrdconta = 324922
          AND a.dtmvtolt = TO_DATE('17/01/2022', 'DD/MM/RRRR')
          AND a.cdhistor = 2671
          AND a.nrborder = 139062;
      rw_lanc_border cr_lanc_border%ROWTYPE;
     
BEGIN

       OPEN cr_lanc_border;
       FETCH cr_lanc_border INTO rw_lanc_border;
       
       OPEN  btch0001.cr_crapdat(pr_cdcooper => rw_lanc_border.cdcooper);
       FETCH btch0001.cr_crapdat into rw_crapdat;
       CLOSE btch0001.cr_crapdat;
       
       vr_nrdolote := fn_sequence(pr_nmtabela => 'CRAPLOT'
                                 ,pr_nmdcampo => 'NRDOLOTE'
                                 ,pr_dsdchave => TO_CHAR(rw_lanc_border.cdcooper)|| ';'
                                              || TO_CHAR(rw_crapdat.dtmvtolt, 'DD/MM/RRRR') || ';'
                                              || TO_CHAR('1')|| ';'
                                              || '100');
   
       LANC0001.pc_gerar_lancamento_conta(pr_cdcooper =>rw_lanc_border.cdcooper          
                                         ,pr_dtmvtolt =>rw_crapdat.dtmvtolt   
                                         ,pr_cdagenci =>1     
                                         ,pr_cdbccxlt =>100 
                                         ,pr_nrdolote =>vr_nrdolote   
                                         ,pr_nrdconta =>rw_lanc_border.nrdconta    
                                         ,pr_nrdctabb =>rw_lanc_border.nrdconta
                                         ,pr_nrdocmto =>rw_lanc_border.nrdocmto               
                                         ,pr_cdhistor =>2670
                                         ,pr_nrseqdig =>1
                                         ,pr_vllanmto =>round(rw_lanc_border.vltitulo,2) 
                                         ,pr_cdpesqbb => 'Desconto de Título do Borderô ' || rw_lanc_border.nrborder
                                         ,pr_tab_retorno => vr_tab_retorno
                                         ,pr_incrineg => vr_incrineg
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
   
        IF nvl(vr_cdcritic, 0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
           RAISE vr_exc_erro;
        END IF;

        COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK; 
  WHEN OTHERS THEN
    ROLLBACK;  
END;
