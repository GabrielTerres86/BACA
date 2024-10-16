DECLARE
   vr_aux_ambiente    INTEGER       := 3;             
   vr_aux_diretor     VARCHAR2(100) := 'INC0364126';     
   vr_aux_arquivo     VARCHAR2(100) := 'registros';
   vr_handle          UTL_FILE.FILE_TYPE; 
   vr_handle_log      UTL_FILE.FILE_TYPE;
   vr_handle_regs     UTL_FILE.FILE_TYPE;
   vr_nmarq_regs      VARCHAR2(200);
   vr_nmarq_log       VARCHAR2(200);
   vr_nmarq_rollback  VARCHAR2(200);
   rw_crapdat         BTCH0001.cr_crapdat%ROWTYPE;
   vr_des_erro        VARCHAR2(10000); 
   vr_des_linha       VARCHAR2(3000);  
   vr_vet_campos      GENE0002.typ_split; 
   vr_nrcontad        PLS_INTEGER := 0; 
   vr_aux_cdcooper    NUMBER;  
   vr_aux_cddlinha    NUMBER;
   vr_aux_nrborder    NUMBER;
   vr_aux_nrdconta    NUMBER;
   vr_cont_commit     NUMBER(6) := 0;
   vr_cdcritic        crapcri.cdcritic%TYPE;
   vr_dscritic        crapcri.dscritic%TYPE;
   vr_exc_erro        EXCEPTION;
   vr_conta_ambiente  NUMBER;  
     
  TYPE typ_reg_carga IS RECORD(cdcooper  crapbdt.cdcooper%TYPE
                              ,nrdconta  crapbdt.nrdconta%TYPE
                              ,nrborder  crapbdt.nrborder%TYPE);
  TYPE typ_tab_carga IS TABLE OF typ_reg_carga INDEX BY PLS_INTEGER;
  vr_tab_carga typ_tab_carga;
  
  CURSOR cr_conta_ambiente(pr_cdcooper IN crapbdt.cdcooper%TYPE
                          ,pr_nrborder IN crapbdt.nrborder%TYPE) IS
    SELECT bdt.nrdconta
      FROM cecred.crapbdt bdt
     WHERE bdt.cdcooper = pr_cdcooper
       AND bdt.nrborder = pr_nrborder;
  rw_conta_ambiente cr_conta_ambiente%ROWTYPE;
  

  PROCEDURE pc_alterar_prejuizo (pr_cdcooper IN crapcop.cdcooper%TYPE 
                                ,pr_nrdconta IN crapass.nrdconta%TYPE
                                ,pr_nrborder IN crapbdt.nrborder%TYPE    
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE 
                                ,pr_dscritic OUT VARCHAR2) IS
                                    
    vr_cdhistordsct_principal           CONSTANT craphis.cdhistor%TYPE := 2754; 
    vr_cdhistordsct_juros_60_rem        CONSTANT craphis.cdhistor%TYPE := 2755; 
    vr_cdhistordsct_juros_60_mor        CONSTANT craphis.cdhistor%TYPE := 2761; 
    vr_cdhistordsct_multa_atraso        CONSTANT craphis.cdhistor%TYPE := 2764; 
    vr_cdhistordsct_juros_mora          CONSTANT craphis.cdhistor%TYPE := 2765; 
    vr_cdhistordsct_juros_60_mul        CONSTANT craphis.cdhistor%TYPE := 2879; 
    vr_cdhistordsct_aprop_tit           CONSTANT craphis.cdhistor%TYPE := 2667; 
    vr_cdhistordsct_juros_atuali        CONSTANT craphis.cdhistor%TYPE := 2763; 
    vr_cdhistordsct_rec_principal       CONSTANT craphis.cdhistor%TYPE := 2770; 
    vr_cdhistordsct_rec_jur_60          CONSTANT craphis.cdhistor%TYPE := 2771; 
    vr_cdhistordsct_rec_jur_atuali      CONSTANT craphis.cdhistor%TYPE := 2772; 
    vr_cdhistordsct_rec_mult_atras      CONSTANT craphis.cdhistor%TYPE := 2773; 
    vr_cdhistordsct_rec_jur_mora        CONSTANT craphis.cdhistor%TYPE := 2774; 
    vr_cdhistordsct_rec_abono           CONSTANT craphis.cdhistor%TYPE := 2689; 
    vr_cdhistordsct_rec_preju           CONSTANT craphis.cdhistor%TYPE := 2876; 
    vr_cdhistordsct_recup_preju         CONSTANT craphis.cdhistor%TYPE := 2386; 
    vr_cdhistordsct_recup_iof           CONSTANT craphis.cdhistor%TYPE := 2317; 
    vr_cdhistordsct_est_rec_princi      CONSTANT craphis.cdhistor%TYPE := 2387; 
    vr_cdhistordsct_est_principal       CONSTANT craphis.cdhistor%TYPE := 2775; 
    vr_cdhistordsct_est_jur_60          CONSTANT craphis.cdhistor%TYPE := 2776; 
    vr_cdhistordsct_est_jur_prej        CONSTANT craphis.cdhistor%TYPE := 2777; 
    vr_cdhistordsct_est_mult_atras      CONSTANT craphis.cdhistor%TYPE := 2778; 
    vr_cdhistordsct_est_jur_mor         CONSTANT craphis.cdhistor%TYPE := 2779; 
    vr_cdhistordsct_est_abono           CONSTANT craphis.cdhistor%TYPE := 2690; 
    vr_cdhistordsct_est_preju           CONSTANT craphis.cdhistor%TYPE := 2877; 
                                                                    
    CURSOR cr_crapbdt IS
      SELECT
        bdt.rowid AS id,
        bdt.nrborder,
        bdt.nrdconta,
        bdt.cdcooper,
        bdt.inprejuz,
        bdt.dtprejuz,
        bdt.dtlibbdt,
        bdt.insitbdt,
        bdt.qtdirisc,
        bdt.nrinrisc
       FROM cecred.crapbdt bdt
      WHERE bdt.nrborder = pr_nrborder
        AND bdt.cdcooper = pr_cdcooper;
    rw_crapbdt cr_crapbdt%ROWTYPE;


    CURSOR cr_craplim(pr_cdcooper craplim.cdcooper%TYPE
                     ,pr_nrdconta craplim.nrdconta%TYPE) IS
        SELECT l.*
          FROM cecred.craplim l
         WHERE l.insitlim = 3
           AND l.tpctrlim = 3
           AND l.cdcooper = pr_cdcooper
           AND l.nrdconta = pr_nrdconta
           AND ROWNUM = 1
      ORDER BY l.dtcancel DESC;
      rw_craplim  cr_craplim%ROWTYPE;
      
      
    CURSOR cr_lcto_border(pr_cdcooper craplim.cdcooper%TYPE
                         ,pr_nrdconta craplim.nrdconta%TYPE
                         ,pr_nrborder crapbdt.nrborder%TYPE
                         ,pr_dtprejuz crapbdt.dtprejuz%TYPE) IS
        SELECT a.*
          FROM cecred.tbdsct_lancamento_bordero a
         WHERE a.cdcooper = rw_crapbdt.cdcooper
           AND a.nrdconta = rw_crapbdt.nrdconta
           AND a.nrborder = rw_crapbdt.nrborder
           AND a.dtmvtolt = rw_crapbdt.dtprejuz
           AND a.cdhistor IN(vr_cdhistordsct_principal,        
                             vr_cdhistordsct_juros_60_rem,     
                             vr_cdhistordsct_juros_60_mor,    
                             vr_cdhistordsct_multa_atraso,     
                             vr_cdhistordsct_juros_mora,       
                             vr_cdhistordsct_juros_60_mul,     
                             vr_cdhistordsct_aprop_tit,        
                             vr_cdhistordsct_juros_atuali,     
                             vr_cdhistordsct_rec_principal,    
                             vr_cdhistordsct_rec_jur_60,       
                             vr_cdhistordsct_rec_jur_atuali,   
                             vr_cdhistordsct_rec_mult_atras,   
                             vr_cdhistordsct_rec_jur_mora,     
                             vr_cdhistordsct_rec_abono,        
                             vr_cdhistordsct_rec_preju,        
                             vr_cdhistordsct_recup_preju,      
                             vr_cdhistordsct_recup_iof,        
                             vr_cdhistordsct_est_rec_princi,   
                             vr_cdhistordsct_est_principal,    
                             vr_cdhistordsct_est_jur_60,       
                             vr_cdhistordsct_est_jur_prej,    
                             vr_cdhistordsct_est_mult_atras,   
                             vr_cdhistordsct_est_jur_mor,      
                             vr_cdhistordsct_est_abono,        
                             vr_cdhistordsct_est_preju,
                             DSCT0003.vr_cdhistordsct_apropjurmta,
                             DSCT0003.vr_cdhistordsct_apropjurmra);
      
    
     CURSOR cr_craptdb(pr_cdcooper craptdb.cdcooper%TYPE
                      ,pr_nrdconta craptdb.nrdconta%TYPE
                      ,pr_nrborder craptdb.nrborder%TYPE) IS
      SELECT l.*
        FROM cecred.craptdb l
       WHERE l.cdcooper = pr_cdcooper
         AND l.nrdconta = pr_nrdconta
         AND l.nrborder = pr_nrborder
         AND l.insittit = 4;

    rw_crapdat   btch0001.cr_crapdat%ROWTYPE;
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION;

    BEGIN
      
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      IF (btch0001.cr_crapdat%NOTFOUND) THEN
        CLOSE btch0001.cr_crapdat;
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      END IF;
      CLOSE btch0001.cr_crapdat;

      OPEN cr_crapbdt;
      FETCH cr_crapbdt INTO rw_crapbdt;
      IF (cr_crapbdt%NOTFOUND) THEN
        CLOSE cr_crapbdt;
        vr_cdcritic := 1166;
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapbdt;

      IF (rw_crapbdt.inprejuz<>1) THEN
        vr_dscritic := 'Bordero nao esta em prejuizo';
        RAISE vr_exc_erro;
      END IF;
      

      OPEN cr_craplim(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_craplim INTO rw_craplim;

      IF cr_craplim%NOTFOUND THEN
         CLOSE cr_craplim;
         vr_dscritic := 'Contrato não esta cancelado.';
         RAISE vr_exc_erro;
       ELSE
         CLOSE cr_craplim;
       END IF;
       
                
     BEGIN
       DELETE cecred.tbdsct_lancamento_bordero a
        WHERE a.cdcooper = rw_crapbdt.cdcooper
          AND a.nrdconta = rw_crapbdt.nrdconta
          AND a.nrborder = rw_crapbdt.nrborder
          AND a.dtmvtolt = rw_crapbdt.dtprejuz
          AND a.cdhistor IN (vr_cdhistordsct_principal,        
                             vr_cdhistordsct_juros_60_rem,     
                             vr_cdhistordsct_juros_60_mor,    
                             vr_cdhistordsct_multa_atraso,     
                             vr_cdhistordsct_juros_mora,       
                             vr_cdhistordsct_juros_60_mul,     
                             vr_cdhistordsct_aprop_tit,        
                             vr_cdhistordsct_juros_atuali,     
                             vr_cdhistordsct_rec_principal,    
                             vr_cdhistordsct_rec_jur_60,       
                             vr_cdhistordsct_rec_jur_atuali,   
                             vr_cdhistordsct_rec_mult_atras,   
                             vr_cdhistordsct_rec_jur_mora,     
                             vr_cdhistordsct_rec_abono,        
                             vr_cdhistordsct_rec_preju,        
                             vr_cdhistordsct_recup_preju,      
                             vr_cdhistordsct_recup_iof,        
                             vr_cdhistordsct_est_rec_princi,   
                             vr_cdhistordsct_est_principal,    
                             vr_cdhistordsct_est_jur_60,       
                             vr_cdhistordsct_est_jur_prej,    
                             vr_cdhistordsct_est_mult_atras,   
                             vr_cdhistordsct_est_jur_mor,      
                             vr_cdhistordsct_est_abono,        
                             vr_cdhistordsct_est_preju,
                             DSCT0003.vr_cdhistordsct_apropjurmta,
                             DSCT0003.vr_cdhistordsct_apropjurmra);
                         
      
        FOR rw_lcto_border IN cr_lcto_border (pr_cdcooper => rw_crapbdt.cdcooper
                                             ,pr_nrdconta => rw_crapbdt.nrdconta
                                             ,pr_nrborder => rw_crapbdt.nrborder
                                             ,pr_dtprejuz => rw_crapbdt.dtprejuz) LOOP
                                             
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                          ,pr_des_text => 'INSERT INTO tbdsct_lancamento_bordero ' ||
                                                          '(cdcooper ' ||
                                                          ',nrdconta ' ||
                                                          ',nrborder ' ||
                                                          ',nrtitulo ' || 
                                                          ',nrseqdig ' ||
                                                          ',cdbandoc ' || 
                                                          ',nrdctabb ' || 
                                                          ',nrcnvcob ' || 
                                                          ',nrdocmto ' || 
                                                          ',dtmvtolt ' ||
                                                          ',cdorigem ' ||
                                                          ',cdhistor ' ||
                                                          ',vllanmto)' ||
                                                          'VALUES(' || rw_lcto_border.cdcooper ||
                                                                ',' || rw_lcto_border.nrdconta ||
                                                                ',' || rw_lcto_border.nrborder ||
                                                                ',' || rw_lcto_border.nrtitulo ||
                                                                ',' || rw_lcto_border.nrseqdig ||
                                                                ',' || rw_lcto_border.cdbandoc ||
                                                                ',' || rw_lcto_border.nrdctabb ||
                                                                ',' || rw_lcto_border.nrcnvcob ||
                                                                ',' || rw_lcto_border.nrdocmto ||
                                                                ',to_date("' || rw_lcto_border.dtmvtolt || '")' ||
                                                                ',' || rw_lcto_border.cdorigem ||
                                                                ',' || rw_lcto_border.cdhistor ||
                                                                ',' || rw_lcto_border.vllanmto ||
                                                          ';');
        END LOOP;                                                       
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao deletar cecred.tbdsct_lancamento_bordero: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
        
  
     BEGIN
       UPDATE cecred.craptdb
          SET vlprejuz = 0,
              vlsdprej = 0,
              vlttmupr = 0,
              vljrmprj = 0, 
              vlttjmpr = 0, 
              vlpgjmpr = 0,
              vlpgmupr = 0, 
              vlsprjat = 0, 
              vljraprj = 0, 
              vliofprj = 0,
              vliofppr = 0,
              vlpgjrpr = 0 
        WHERE nrborder = rw_crapbdt.nrborder
          AND nrdconta = rw_crapbdt.nrdconta
          AND insittit = 4 
          AND cdcooper = rw_crapbdt.cdcooper;


          FOR rw_craptdb IN cr_craptdb (pr_cdcooper => rw_crapbdt.cdcooper
                                       ,pr_nrdconta => rw_crapbdt.nrdconta
                                       ,pr_nrborder => rw_crapbdt.nrborder) LOOP
                                           
              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                      ,pr_des_text => 'UPDATE cecred.craptdb lim '    ||
                                                      '   SET lim.vlprejuz = ' || rw_craptdb.vlprejuz ||
                                                      '      ,lim.vlsdprej = ' || rw_craptdb.vlsdprej ||
                                                      '      ,lim.vlttmupr = ' || rw_craptdb.vlttmupr ||
                                                      '      ,lim.vljrmprj = ' || rw_craptdb.vljrmprj ||
                                                      '      ,lim.vlttjmpr = ' || rw_craptdb.vlttjmpr ||
                                                      '      ,lim.vlpgjmpr = ' || rw_craptdb.vlpgjmpr ||
                                                      '      ,lim.vlpgmupr = ' || rw_craptdb.vlpgmupr ||
                                                      '      ,lim.vlsprjat = ' || rw_craptdb.vlsprjat ||
                                                      '      ,lim.vljraprj = ' || rw_craptdb.vljraprj ||
                                                      '      ,lim.vliofprj = ' || rw_craptdb.vliofprj ||
                                                      '      ,lim.vliofppr = ' || rw_craptdb.vliofppr ||
                                                      '      ,lim.vlpgjrpr = ' || rw_craptdb.vlpgjrpr ||
                                                      ' WHERE lim.cdcooper = ' || rw_craptdb.cdcooper ||
                                                      '   AND lim.nrdconta = ' || rw_craptdb.nrdconta ||
                                                      '   AND lim.nrctrlim = ' || rw_craptdb.nrborder ||
                                                      ';'); 
          END LOOP;                                                  
     EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar cecred.craptdb: ' || SQLERRM;
          RAISE vr_exc_erro;
     END;
         
      
     BEGIN   
       UPDATE cecred.crapbdt
          SET inprejuz = 0,
              dtprejuz = NULL,
              nrinrisc = 0,
              qtdirisc = 0
          WHERE ROWID = rw_crapbdt.id;
                   
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                        ,pr_des_text => 'UPDATE cecred.crapbdt lim ' ||
                                                        '   SET lim.inprejuz = 1' ||
                                                        '      ,lim.dtprejuz = to_date("' || rw_crapbdt.dtprejuz || '")' ||
                                                        '      ,lim.nrinrisc = 10'||
                                                        '      ,lim.qtdirisc = 0' ||
                                                        ' WHERE lim.cdcooper = '  || rw_crapbdt.cdcooper ||
                                                        '   AND lim.nrdconta = '  || rw_crapbdt.nrdconta ||
                                                        '   AND lim.nrctrlim = '  || rw_crapbdt.nrborder ||
                                                        ';');      
     EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar cecred.crapbdt: ' || SQLERRM;
          RAISE vr_exc_erro;
     END;
      

     BEGIN
       UPDATE cecred.craplim
          SET craplim.insitlim = 2
             ,craplim.dtfimvig = (TRUNC(craplim.dtinivig) + 180)
             ,craplim.dtcancel = NULL
        WHERE craplim.cdcooper = rw_crapbdt.cdcooper
          AND craplim.nrdconta = rw_crapbdt.nrdconta
          AND craplim.insitlim = 3
          AND craplim.tpctrlim = 3
          AND craplim.dtfimvig = rw_crapbdt.dtprejuz
          AND craplim.dtcancel = rw_crapbdt.dtprejuz; 
          
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                        ,pr_des_text => 'UPDATE cecred.craplim lim '    ||
                                                        '   SET lim.insitlim = ' || rw_craplim.insitlim ||
                                                        '      ,lim.dtfimvig = to_date("' || rw_craplim.dtfimvig || '")' ||
                                                        '      ,lim.dtcancel = to_date("' || rw_craplim.dtcancel || '")' ||
                                                        ' WHERE lim.cdcooper = ' || rw_craplim.cdcooper ||
                                                        '   AND lim.nrdconta = ' || rw_craplim.nrdconta ||
                                                        '   AND lim.nrctrlim = ' || rw_craplim.nrctrlim ||
                                                        '   AND lim.tpctrlim = 1'||
                                                        ';');
     EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar cecred.craplim: ' || SQLERRM;
          RAISE vr_exc_erro;
     END;      
    
    
    BEGIN      
       UPDATE cecred.crawlim
          SET crawlim.insitlim = 2
             ,crawlim.dtfimvig = (TRUNC(crawlim.dtinivig) + 180)
        WHERE crawlim.cdcooper = rw_crapbdt.cdcooper
          AND crawlim.nrdconta = rw_crapbdt.nrdconta
          AND crawlim.nrctrlim = rw_craplim.nrctrlim
          AND crawlim.insitlim = 3
          AND crawlim.tpctrlim = 3
          AND crawlim.dtfimvig = rw_crapbdt.dtprejuz
          AND crawlim.dtcancel = rw_crapbdt.dtprejuz; 
          
          
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                        ,pr_des_text => 'UPDATE cecred.crawlim lim '    ||
                                                        '   SET lim.insitlim = 3' ||
                                                        '      ,lim.dtfimvig = to_date("' || rw_crapbdt.dtprejuz || '")' ||
                                                        ' WHERE lim.cdcooper = ' || rw_crapbdt.cdcooper ||
                                                        '   AND lim.nrdconta = ' || rw_crapbdt.nrdconta ||
                                                        '   AND lim.nrctrlim = ' || rw_craplim.nrctrlim ||
                                                        '   AND lim.tpctrlim = 1'||
                                                        ';');
                                                        
     EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar cecred.crawlim: ' || SQLERRM;
          RAISE vr_exc_erro;
     END;         
     
     
     BEGIN       
       UPDATE cecred.crawlim
          SET crawlim.insitlim = 2
             ,crawlim.dtfimvig = (TRUNC(crawlim.dtinivig) + 180)
        WHERE crawlim.cdcooper = rw_crapbdt.cdcooper
          AND crawlim.nrdconta = rw_crapbdt.nrdconta
          AND crawlim.nrctrmnt = rw_craplim.nrctrlim
          AND crawlim.insitlim = 3
          AND crawlim.tpctrlim = 3
          AND crawlim.dtfimvig = rw_crapbdt.dtprejuz
          AND crawlim.dtcancel = rw_crapbdt.dtprejuz; 
          
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                        ,pr_des_text => 'UPDATE cecred.crawlim lim '    ||
                                                        '   SET lim.insitlim = 3' ||
                                                        '      ,lim.dtfimvig = to_date("' || rw_crapbdt.dtprejuz || '")' ||
                                                        ' WHERE lim.cdcooper = ' || rw_crapbdt.cdcooper ||
                                                        '   AND lim.nrdconta = ' || rw_crapbdt.nrdconta ||
                                                        '   AND lim.nrctrmnt = ' || rw_craplim.nrctrlim ||
                                                        '   AND lim.tpctrlim = 3'||
                                                        ';');
                                                        
     EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar cecred.crawlim (nrctrmnt): ' || SQLERRM;
          RAISE vr_exc_erro;
     END;      
     
     
     BEGIN
       UPDATE cecred.crapass
          SET crapass.cdsitdct = NVL(crapass.cdsitdct_original,1)
        WHERE crapass.cdcooper = rw_crapbdt.cdcooper
          AND crapass.nrdconta = rw_crapbdt.nrdconta;
          
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                        ,pr_des_text => 'UPDATE cecred.crapass lim '    ||
                                                        '   SET lim.cdsitdct = 2' ||
                                                        ' WHERE lim.cdcooper = ' || rw_crapbdt.cdcooper ||
                                                        '   AND lim.nrdconta = ' || rw_crapbdt.nrdconta ||
                                                        ';');  
          
     EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar crapass - situacao da conta: ' || SQLERRM;
          RAISE vr_exc_erro;
     END;
     
       
     BEGIN
       UPDATE cecred.crapcrm
          SET crapcrm.cdsitcar = 2
             ,crapcrm.dtcancel = NULL
             ,crapcrm.dttransa = trunc(sysdate)
        WHERE crapcrm.cdcooper = rw_crapbdt.cdcooper
          AND crapcrm.nrdconta = rw_crapbdt.nrdconta
          AND crapcrm.dtcancel = rw_crapbdt.dtprejuz;
          
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                        ,pr_des_text => 'UPDATE cecred.crapcrm lim '    ||
                                                        '   SET lim.cdsitcar = 4' ||
                                                        '      ,lim.dtcancel = to_date("' || rw_crapbdt.dtprejuz || '")' ||
                                                        '      ,lim.dttransa = trunc(sysdate)' ||
                                                        ' WHERE lim.cdcooper = ' || rw_crapbdt.cdcooper ||
                                                        '   AND lim.nrdconta = ' || rw_crapbdt.nrdconta ||
                                                        ';');
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar crapcrm: ' || SQLERRM;
          RAISE vr_exc_erro;
     END;


     BEGIN
        UPDATE cecred.crapsnh
           SET crapsnh.cdsitsnh = 1
              ,crapsnh.dtblutsh = NULL
              ,crapsnh.dtaltsit = rw_crapdat.dtmvtolt
         WHERE crapsnh.cdcooper = rw_crapbdt.cdcooper
           AND crapsnh.nrdconta = rw_crapbdt.nrdconta
           AND crapsnh.cdsitsnh = 2
           AND crapsnh.tpdsenha = 1
           AND crapsnh.idseqttl = 1
           AND crapsnh.dtblutsh = rw_crapbdt.dtprejuz; 
           
           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                         ,pr_des_text => 'UPDATE cecred.crapsnh lim '    ||
                                                         '   SET lim.cdsitsnh = 2' ||
                                                         '      ,lim.dtblutsh = to_date("' || rw_crapbdt.dtprejuz || '")' ||
                                                         '      ,lim.dtaltsit = trunc(sysdate)' ||
                                                         ' WHERE lim.cdcooper = ' || rw_crapbdt.cdcooper ||
                                                         '   AND lim.nrdconta = ' || rw_crapbdt.nrdconta ||
                                                         '   AND lim.tpdsenha = 1' ||
                                                         '   AND lim.idseqttl = 1' ||
                                                         ';');                                                     
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar crapsnh: ' || SQLERRM;
        RAISE vr_exc_erro;
    END; 
     

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
        ROLLBACK;
        pr_cdcritic := 0;
        pr_dscritic := 'Erro não tratado na rotina pc_alterar_prejuizo: ' ||SQLERRM;
  END pc_alterar_prejuizo;
   

BEGIN
    IF vr_aux_ambiente = 1 THEN 
      vr_nmarq_regs     := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';  
      vr_nmarq_log      := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';      
      vr_nmarq_rollback := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql';       
    ELSIF vr_aux_ambiente = 2 THEN   
      vr_nmarq_regs     := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/evandro/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';     
      vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/evandro/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';     
      vr_nmarq_rollback := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/evandro/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql'; 
    ELSIF vr_aux_ambiente = 3 THEN 
      vr_nmarq_regs     := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';
      vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';      
      vr_nmarq_rollback := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql'; 
    ELSE
      vr_dscritic := 'Erro ao apontar ambiente de execucao.';
      RAISE vr_exc_erro;
    END IF;

    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_log
                            ,pr_tipabert => 'W'              
                            ,pr_utlfileh => vr_handle_log   
                            ,pr_des_erro => vr_des_erro);
    if vr_des_erro is not null then
      vr_dscritic := 'Erro ao abrir arquivo de LOG: ' || vr_des_erro;
      RAISE vr_exc_erro;
    end if;
    
    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_regs
                            ,pr_tipabert => 'R'
                            ,pr_utlfileh => vr_handle_regs
                            ,pr_des_erro => vr_dscritic);                                                                       
      IF vr_dscritic IS NOT NULL THEN 
         vr_dscritic := 'Erro ao abrir o arquivo para leitura: '||vr_nmarq_regs || ' - ' || vr_dscritic;
         RAISE vr_exc_erro;
      END IF;

    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_rollback
                            ,pr_tipabert => 'W'              
                            ,pr_utlfileh => vr_handle   
                            ,pr_des_erro => vr_des_erro);
    if vr_des_erro is not null then
      vr_dscritic := 'Erro ao abrir arquivo de ROLLBACK: ' || vr_des_erro;
      RAISE vr_exc_erro;
    end if; 
      
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Inicio da execucao - ' ||  to_char(SYSDATE, 'HH24:MI:SS') || chr(10) || 'Cooperativa;Conta;Contrato;Erro');
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                  ,pr_des_text => 'BEGIN');                                                                  

  
    LOOP 
      BEGIN
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_handle_regs 
                                    ,pr_des_text => vr_des_linha); 
      
        vr_nrcontad := vr_nrcontad + 1; 
          
        vr_des_linha := REPLACE(REPLACE(vr_des_linha,chr(13),''),chr(10),''); 

        vr_vet_campos := gene0002.fn_quebra_string(TRIM(vr_des_linha),';'); 

        BEGIN
           vr_aux_cdcooper := TO_NUMBER(vr_vet_campos(1));  
           vr_aux_nrdconta := TO_NUMBER(vr_vet_campos(2));
           vr_aux_nrborder := TO_NUMBER(vr_vet_campos(3));
        EXCEPTION
          WHEN OTHERS THEN
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                          ,pr_des_text => 'Erro na leitura da linha: ' || vr_nrcontad || ' => ' || SQLERRM);
              
          CONTINUE;
        END;             

        vr_tab_carga(vr_nrcontad).cdcooper := vr_aux_cdcooper;
        vr_tab_carga(vr_nrcontad).nrdconta := vr_aux_nrdconta;
        vr_tab_carga(vr_nrcontad).nrborder := vr_aux_nrborder;

      EXCEPTION
        WHEN no_data_found THEN
          EXIT;
        WHEN vr_exc_erro THEN
          RAISE vr_exc_erro;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro na leitura da linha '||vr_nrcontad||' => '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END LOOP;


    FOR vr_idx1 IN vr_tab_carga.first .. vr_tab_carga.last LOOP
        IF vr_tab_carga.exists(vr_idx1) THEN
         
         vr_conta_ambiente := '';   
         vr_cont_commit  := vr_cont_commit + 1;
              
         OPEN BTCH0001.cr_crapdat(pr_cdcooper =>  vr_tab_carga(vr_idx1).cdcooper);
         FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
         CLOSE BTCH0001.cr_crapdat;

           
         IF vr_aux_ambiente = 3 THEN 
            vr_conta_ambiente := vr_tab_carga(vr_idx1).nrdconta;
         ELSE  
             OPEN cr_conta_ambiente (pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper
                                    ,pr_nrborder => vr_tab_carga(vr_idx1).nrborder);
             FETCH cr_conta_ambiente INTO rw_conta_ambiente;
             IF cr_conta_ambiente%NOTFOUND THEN
                CLOSE cr_conta_ambiente;
                gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                              ,pr_des_text => 'Coop: ' || vr_tab_carga(vr_idx1).cdcooper ||' - Bordero nao encontrado: ' || vr_tab_carga(vr_idx1).nrborder);
                CONTINUE;
             END IF;
             CLOSE cr_conta_ambiente;
                 
             vr_conta_ambiente := rw_conta_ambiente.nrdconta;
         END IF;

         pc_alterar_prejuizo(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper
                            ,pr_nrdconta => vr_conta_ambiente
                            ,pr_nrborder => vr_tab_carga(vr_idx1).nrborder
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

         IF vr_dscritic IS NOT NULL THEN
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                          ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                          vr_conta_ambiente || ';' || 
                                                          vr_tab_carga(vr_idx1).nrborder || ';' || 
                                                          vr_dscritic);                                                                     
         END IF;
                         
         IF vr_cont_commit = 50 THEN
            vr_cont_commit := 0;
            COMMIT;
         END IF;

        END IF;
    END LOOP;

    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Fim da execucao - ' ||  to_char(SYSDATE, 'HH24:MI:SS'));
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                  ,pr_des_text => 'EXCEPTION' || chr(10) || 'WHEN OTHERS THEN' || chr(10) || 'ROLLBACK;' || chr(10) || 'END;');                                                                                                                        
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);          
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);             

    COMMIT;
EXCEPTION  
  WHEN vr_exc_erro THEN
    dbms_output.put_line('Erro arquivos: ' || vr_dscritic);
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Erro arquivos: ' || vr_dscritic || ' SQLERRM: ' || SQLERRM);      
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
    ROLLBACK;  
  WHEN OTHERS THEN
    dbms_output.put_line('Erro geral: ' || ' SQLERRM: ' || SQLERRM);
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Erro geral: ' || ' SQLERRM: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
    ROLLBACK;
END;
