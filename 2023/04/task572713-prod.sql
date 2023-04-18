DECLARE

  vr_busca        VARCHAR2(100);
  vr_nrdocmto     craplct.nrdocmto%TYPE;
  vr_tab_retorno  LANC0001.typ_reg_retorno;
  vr_nrseqdig_lot craplot.nrseqdig%TYPE;
  vr_exc_erro     EXCEPTION;
  vr_cdcritic crapcri.cdcritic%TYPE;
  pr_dscritic VARCHAR2(4000);
  vr_dscritic VARCHAR2(4000);
  rw_crapdat    btch0001.cr_crapdat%ROWTYPE;
  pr_cdcritic crapcri.cdcritic%TYPE;
  pr_dtmvtolt DATE;
  vr_incrineg     INTEGER;
  vr_input_file  UTL_FILE.FILE_TYPE;
  vr_idprglog   tbgen_prglog.idprglog%TYPE := 0;
  
  pr_cdcooper NUMBER(2) := 16;
  pr_nrdconta NUMBER(8) := 16461029;
  pr_cdagenci NUMBER(2) := 10;
  pr_vllanmto NUMBER(4,2) := 1.00;
  vr_nrdolote     craplot.nrdolote%TYPE := 800039;

BEGIN
     
  OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;
  pr_dtmvtolt := rw_crapdat.dtmvtolt;
  
  vr_busca := TRIM(to_char(pr_cdcooper)) || ';' ||
              TRIM(to_char(pr_dtmvtolt,'DD/MM/RRRR')) || ';' ||
              TRIM(to_char(pr_cdagenci)) || ';' ||
                   '100;' ||
                    vr_nrdolote || ';' || 
              TRIM(to_char(pr_nrdconta));

  vr_nrdocmto := fn_sequence('CRAPLCT','NRDOCMTO', vr_busca); 
    
  vr_nrseqdig_lot := fn_sequence('CRAPLOT','NRSEQDIG',''||pr_cdcooper||';'||
                                 to_char(pr_dtmvtolt,'DD/MM/RRRR')||';'||
                                 pr_cdagenci||
                                 ';100;'||
                                  vr_nrdolote);      
           
   INSERT INTO cecred.craplct(cdcooper
                             ,cdagenci
                             ,cdbccxlt
                             ,nrdolote
                             ,dtmvtolt
                             ,cdhistor
                             ,nrctrpla
                             ,nrdconta
                             ,nrdocmto
                             ,nrseqdig
                             ,vllanmto)
                      VALUES (pr_cdcooper
                             ,pr_cdagenci
                             ,100
                             ,vr_nrdolote
                             ,pr_dtmvtolt
                             ,2136
                             ,pr_nrdconta
                             ,pr_nrdconta
                             ,vr_nrdocmto
                             ,vr_nrseqdig_lot
                             ,pr_vllanmto);

   cecred.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper =>pr_cdcooper           
                                            ,pr_dtmvtolt =>pr_dtmvtolt 
                                            ,pr_dtrefere =>pr_dtmvtolt    
                                            ,pr_cdagenci =>pr_cdagenci 
                                            ,pr_cdbccxlt =>100                                                                                                              
                                            ,pr_nrdolote =>vr_nrdolote    
                                            ,pr_nrdconta =>pr_nrdconta 
                                            ,pr_nrdctabb => pr_nrdconta                                               
                                            ,pr_nrdctitg => TO_CHAR(cecred.gene0002.fn_mask(pr_nrdconta,'99999999'))                                                 
                                            ,pr_nrdocmto => vr_nrdocmto                                                 
                                            ,pr_cdhistor => 2137 
                                            ,pr_vllanmto =>pr_vllanmto      
                                            ,pr_nrseqdig =>vr_nrseqdig_lot       
                                            ,pr_tab_retorno => vr_tab_retorno
                                            ,pr_incrineg => vr_incrineg
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

    IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;                                                                        
                             
    UPDATE cecred.crapcot
       SET vldcotas = vldcotas - pr_vllanmto
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta;  
       
  COMMIT;                    
  EXCEPTION
  WHEN vr_exc_erro THEN

    IF vr_cdcritic <> 0 THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    ELSE
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    END IF;
    ROLLBACK;    
    CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                          ,pr_dsmensagem    => vr_dscritic             
                          ,pr_cdprograma    => 'INC0265670'
                          ,pr_cdcooper      => pr_cdcooper
                          ,pr_idprglog      => vr_idprglog);                                
  
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'INC0265670');
    ROLLBACK;
END;
