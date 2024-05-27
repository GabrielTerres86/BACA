DECLARE
  pr_cdcooper        crapcop.cdcooper%TYPE := 1 ;
  vr_cdcritic        INTEGER:= 0;
  vr_dscritic        VARCHAR2(4000);
  pr_cdcritic        INTEGER:= 0;
  pr_dscritic        VARCHAR2(4000);
  vr_dtmvtolt        DATE;
  vr_dtmvtopr        DATE;
  vr_percenir        NUMBER:= 0;
  vr_qtrenmfx        NUMBER:= 0;
  vr_dtinitax        DATE;
  vr_dtfimtax        DATE;
  vr_qtdfaxir        INTEGER:= 0;
  vr_tab_tpregist    APLI0001.typ_tab_tpregist;
  vr_index_resgate   VARCHAR2(25);
  vr_index_craplrg   VARCHAR2(20);
  vr_tab_craplrg     APLI0001.typ_tab_craplpp;
  vr_dstextab_rdcpos craptab.dstextab%TYPE;
  vr_vlsdextr        CRAPRDA.VLSDEXTR%TYPE;
  vr_vlslfmes        CRAPRDA.VLSLFMES%TYPE;
  vr_cdprogra        CONSTANT crapprg.cdprogra%TYPE := 'SCRIPT175';
  vr_tab_conta_bloq  APLI0001.typ_tab_ctablq;
  vr_tab_craplpp     APLI0001.typ_tab_craplpp;
  vr_index_craplpp   VARCHAR2(20);
  vr_tab_resgate     APLI0001.typ_tab_resgate;
  rw_crapdat         BTCH0001.cr_crapdat%ROWTYPE;
  vr_vltotrda        CRAPRDA.VLSDRDCA%TYPE;
  vr_txaplica        CRAPLAP.TXAPLICA%TYPE;
  vr_txaplmes        CRAPLAP.TXAPLMES%TYPE;
  vr_retorno         VARCHAR2(3);
  vr_tab_acumula     APLI0001.typ_tab_acumula_aplic;
  vr_tab_erro        GENE0001.typ_tab_erro;
  vr_vlsdrdca        NUMBER:= 0;
  vr_rd2_txaplica    NUMBER:= 0;
  vr_exc_erro        EXCEPTION;
  vr_idprglog        NUMBER;
  
  CURSOR cr_craprda (pr_cdcooper IN craprda.cdcooper%TYPE) IS
    SELECT craprda.dtcalcul
          ,craprda.insaqtot
          ,craprda.nrdconta
          ,crapass.inpessoa
          ,crapass.cdagenci
          ,craprda.nraplica
          ,craprda.flgctain
          ,craprda.vlabcpmf
          ,craprda.vlaplica
          ,craprda.vlrgtacu
          ,craprda.qtrgtmfx
          ,craprda.qtaplmfx
          ,craprda.dtmvtolt
          ,craprda.vlabdiof
          ,craprda.vlabiord
          ,craprda.vlslfmes
          ,craprda.cdageass
          ,craprda.vlsdextr
          ,craprda.dtsdfmes
          ,craprda.tpaplica
          ,craprda.rowid
     FROM cecred.craprda craprda
         ,cecred.crapass crapass
    WHERE craprda.cdcooper = crapass.cdcooper
      AND craprda.nrdconta = crapass.nrdconta
      AND craprda.cdcooper = pr_cdcooper
      AND ((craprda.nrdconta = 97933740 AND craprda.nraplica =  167087) OR
           (craprda.nrdconta = 97976750 AND craprda.nraplica in (244856, 188035)));
           
  CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                   ,pr_nmsistem IN craptab.nmsistem%TYPE
                   ,pr_tptabela IN craptab.tptabela%TYPE
                   ,pr_cdempres IN craptab.cdempres%TYPE
                   ,pr_cdacesso IN craptab.cdacesso%TYPE
                   ,pr_dstextab IN craptab.dstextab%TYPE) IS
    SELECT craptab.dstextab
          ,craptab.tpregist
      FROM cecred.craptab craptab
     WHERE craptab.cdcooper = pr_cdcooper
       AND UPPER(craptab.nmsistem) = UPPER(pr_nmsistem)
       AND UPPER(craptab.tptabela) = UPPER(pr_tptabela)
       AND craptab.cdempres = pr_cdempres
       AND UPPER(craptab.cdacesso) = UPPER(pr_cdacesso)
       AND craptab.dstextab = pr_dstextab; 

  CURSOR cr_craplpp (pr_cdcooper IN craplpp.cdcooper%TYPE
                    ,pr_dtmvtolt IN craplpp.dtmvtolt%TYPE) IS
    SELECT lpp.nrdconta
          ,lpp.nrctrrpp
          ,Count(*) qtlancmto
      FROM cecred.craplpp lpp
     WHERE lpp.cdcooper = pr_cdcooper
       AND lpp.cdhistor IN (158,496)
       AND lpp.dtmvtolt > pr_dtmvtolt
       AND lpp.nrdconta in (97933740,97976750)
     GROUP BY lpp.nrdconta,lpp.nrctrrpp
    HAVING Count(*) > 3
     UNION ALL
    SELECT rac.nrdconta
          ,rac.nrctrrpp
          ,Count(*) qtlancmto
      FROM cecred.crapcpc cpc, cecred.craprac rac, cecred.craplac lac
     WHERE rac.cdcooper = pr_cdcooper
       AND rac.nrctrrpp > 0
       AND cpc.cdprodut = rac.cdprodut
       AND rac.cdcooper = lac.cdcooper
       AND rac.nrdconta = lac.nrdconta
       AND rac.nraplica = lac.nraplica 
       AND lac.cdhistor in (cpc.cdhsrgap)
       AND lac.dtmvtolt > pr_dtmvtolt 
       AND lac.nrdconta in (97933740,97976750)      
     GROUP BY rac.nrdconta,rac.nrctrrpp        
    HAVING Count(*) > 3; 
    
  CURSOR cr_craplrg (pr_cdcooper IN craplrg.cdcooper%TYPE
                    ,pr_dtresgat IN craplrg.dtresgat%TYPE) IS
    SELECT craplrg.nrdconta
          ,craplrg.nraplica
          ,craplrg.tpaplica
          ,craplrg.tpresgat
          ,Nvl(Sum(Nvl(craplrg.vllanmto,0)),0) vllanmto
     FROM cecred.craplrg craplrg
    WHERE craplrg.cdcooper  = pr_cdcooper
      AND craplrg.dtresgat <= pr_dtresgat
      AND craplrg.inresgat  = 0
      AND craplrg.tpresgat  = 1
      AND craplrg.nrdconta in (97933740,97976750)
    GROUP BY craplrg.nrdconta
            ,craplrg.nraplica
            ,craplrg.tpaplica
            ,craplrg.tpresgat;  

  CURSOR cr_craplrg_saque (pr_cdcooper IN craplrg.cdcooper%TYPE) IS
    SELECT craplrg.nrdconta,craplrg.nraplica,Count(*) qtlancmto
      FROM cecred.craplrg craplrg
     WHERE craplrg.cdcooper = pr_cdcooper
       AND craplrg.tpaplica = 4
       AND craplrg.inresgat = 0
       AND craplrg.nrdconta in (97933740,97976750)
     GROUP BY craplrg.nrdconta
             ,craplrg.nraplica;                              

  PROCEDURE pc_limpa_tabela IS
    BEGIN
      vr_tab_craplpp.DELETE;
      vr_tab_craplrg.DELETE;
      vr_tab_resgate.DELETE;
      vr_tab_tpregist.DELETE;
      vr_tab_conta_bloq.DELETE;
    EXCEPTION
      WHEN OTHERS THEN
        cecred.pc_internal_exception;        
         vr_dscritic:= 'Erro ao limpar tabelas de memória. Rotina pc_crps175.pc_limpa_tabela. '||sqlerrm;
      RAISE vr_exc_erro;
  END;
       
BEGIN
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  IF BTCH0001.cr_crapdat%NOTFOUND THEN
    CLOSE BTCH0001.cr_crapdat;
    vr_cdcritic:= 1;
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    RAISE vr_exc_erro;
  ELSE
    CLOSE BTCH0001.cr_crapdat;
    vr_dtmvtolt:= rw_crapdat.dtmvtolt;
    vr_dtmvtopr:= rw_crapdat.dtmvtopr;
  END IF;
  vr_percenir:= GENE0002.fn_char_para_number(TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                                       ,pr_nmsistem => 'CRED'
                                                                       ,pr_tptabela => 'CONFIG'
                                                                       ,pr_cdempres => 0
                                                                       ,pr_cdacesso => 'PERCIRAPLI'
                                                                       ,pr_tpregist => 0));       
  
  FOR rw_craptab IN cr_craptab (pr_cdcooper => pr_cdcooper
                               ,pr_nmsistem => 'CRED'
                               ,pr_tptabela => 'GENERI'
                               ,pr_cdempres => 3
                               ,pr_cdacesso => 'SOMAPLTAXA'
                               ,pr_dstextab => 'SIM') LOOP
    
    vr_tab_tpregist(rw_craptab.tpregist):= rw_craptab.tpregist;
  END LOOP;       
  
  FOR rw_craplpp IN cr_craplpp (pr_cdcooper => pr_cdcooper
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt - 180) LOOP
    vr_index_craplpp:= LPad(rw_craplpp.nrdconta,10,'0')||LPad(rw_craplpp.nrctrrpp,10,'0');
    vr_tab_craplpp(vr_index_craplpp):= rw_craplpp.qtlancmto;
  END LOOP;
  
  cecred.TABE0001.pc_carrega_ctablq(pr_cdcooper => pr_cdcooper
                            ,pr_tab_cta_bloq => vr_tab_conta_bloq);
                            
  FOR rw_craplrg IN cr_craplrg (pr_cdcooper => pr_cdcooper
                               ,pr_dtresgat => vr_dtmvtopr) LOOP
  
    vr_index_resgate:= LPad(rw_craplrg.nrdconta,10,'0')||
                       LPad(rw_craplrg.tpaplica,05,'0')||
                       LPad(rw_craplrg.nraplica,10,'0');
    
    vr_tab_resgate(vr_index_resgate).tpresgat := rw_craplrg.tpresgat;
    vr_tab_resgate(vr_index_resgate).vllanmto := rw_craplrg.vllanmto;
  END LOOP;
  
  FOR rw_craplrg IN cr_craplrg_saque (pr_cdcooper => pr_cdcooper) LOOP
    vr_index_craplrg:= LPad(rw_craplrg.nrdconta,10,'0')||LPad(rw_craplrg.nraplica,10,'0');
    vr_tab_craplrg(vr_index_craplrg):= rw_craplrg.qtlancmto;
  END LOOP;    
            
  vr_dstextab_rdcpos:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => 'MXRENDIPOS'
                                                 ,pr_tpregist => 1);
  IF vr_dstextab_rdcpos IS NULL THEN
    vr_dtinitax := to_date('01/01/9999','dd/mm/yyyy');
    vr_dtfimtax := to_date('01/01/9999','dd/mm/yyyy');
  ELSE
    vr_dtinitax := to_date(gene0002.fn_busca_entrada(1, vr_dstextab_rdcpos, ';'), 'DD/MM/RRRR');
    vr_dtfimtax := to_date(gene0002.fn_busca_entrada(2, vr_dstextab_rdcpos, ';'), 'DD/MM/RRRR');
  END IF;   

  vr_qtdfaxir:= APLI0001.vr_faixa_ir_rdca.Count;           
  
  FOR rw_craprda IN cr_craprda (pr_cdcooper => pr_cdcooper) LOOP

    vr_qtrenmfx:= 0;
    vr_cdcritic:= 0;
    vr_vlsdextr:= 0;
    vr_vlslfmes:= 0;                                         

    cecred.APLI0001.pc_acumula_aplicacoes (pr_cdcooper        => pr_cdcooper            
                                   ,pr_cdprogra        => vr_cdprogra            
                                   ,pr_nrdconta        => rw_craprda.nrdconta    
                                   ,pr_nraplica        => 0                      
                                   ,pr_tpaplica        => 3                      
                                   ,pr_vlaplica        => 0                      
                                   ,pr_cdperapl        => 0                      
                                   ,pr_percenir        => vr_percenir            
                                   ,pr_qtdfaxir        => vr_qtdfaxir            
                                   ,pr_tab_tpregist    => vr_tab_tpregist        
                                   ,pr_tab_craptab     => vr_tab_conta_bloq      
                                   ,pr_tab_craplpp     => vr_tab_craplpp         
                                   ,pr_tab_craplrg     => vr_tab_craplrg         
                                   ,pr_tab_resgate     => vr_tab_resgate         
                                   ,pr_tab_crapdat     => rw_crapdat             
                                   ,pr_cdagenci_assoc  => rw_craprda.cdagenci    
                                   ,pr_nrdconta_assoc  => rw_craprda.nrdconta    
                                   ,pr_dtinitax        => vr_dtinitax            
                                   ,pr_dtfimtax        => vr_dtfimtax            
                                   ,pr_vlsdrdca        => vr_vltotrda            
                                   ,pr_txaplica        => vr_txaplica            
                                   ,pr_txaplmes        => vr_txaplmes            
                                   ,pr_retorno         => vr_retorno             
                                   ,pr_tab_acumula     => vr_tab_acumula         
                                   ,pr_tab_erro        => vr_tab_erro);          
    IF vr_retorno = 'NOK' THEN
      IF vr_tab_erro.COUNT > 0 THEN
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_craprda.nrdconta;
      ELSE
        vr_cdcritic:= 0;
        vr_dscritic := 'Retorno "NOK" na apli0001.pc_acumula_aplicacoes e sem informação na pr_tab_erro, Conta: '||rw_craprda.nrdconta||' Aplica: 0';
      END IF;
      RAISE vr_exc_erro;
    END IF;
           
    IF vr_vltotrda <= 0 THEN
      vr_vltotrda:= 0;
    END IF;      
    
    cecred.APLI0001.pc_calc_provisao_mensal_rdca2 (pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           ,pr_nrdconta => rw_craprda.nrdconta
                                           ,pr_nraplica => rw_craprda.nraplica
                                           ,pr_vltotrda => vr_vltotrda
                                           ,pr_vlsdrdca => vr_vlsdrdca
                                           ,pr_txaplica => vr_rd2_txaplica
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_des_erro => vr_dscritic);

    IF (vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL) AND vr_cdcritic <> 427 THEN
      RAISE vr_exc_erro;
    ELSIF vr_cdcritic = 427 THEN
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                           || vr_cdprogra || ' --> '
                                                           || vr_dscritic );
      vr_dscritic := NULL;
      vr_cdcritic := NULL;
      continue;
    ELSE
      vr_dscritic := vr_dscritic;
      vr_cdcritic := vr_cdcritic;
    END IF;
                   
    rw_craprda.vlabiord:= Nvl(rw_craprda.vlabiord,0) + Nvl(rw_craprda.vlabdiof,0);
                   
    BEGIN
      UPDATE cecred.craprda SET craprda.dtsdfmea = vr_dtmvtolt
                        ,craprda.vlslfmea = Nvl(vr_vlsdrdca,0)
                        ,craprda.vlabiord = rw_craprda.vlabiord
                        ,craprda.vlsdextr = vr_vlsdextr
                        ,craprda.dtsdfmes = vr_dtmvtolt
                        ,craprda.vlslfmes = Nvl(vr_vlsdrdca,0)
                  WHERE craprda.ROWID = rw_craprda.ROWID;
      EXCEPTION
      WHEN OTHERS THEN
        cecred.pc_internal_exception;
        vr_dscritic:= 'Erro ao atualizar a tabela craprda. Rotina pc_crps175: '||SQLERRM;
        RAISE vr_exc_erro;
    END;                                                                         
           
  END LOOP;           
  pc_limpa_tabela;
  COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pc_limpa_tabela;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => pr_dscritic,
                             pr_cdmensagem => 333,
                             pr_cdprograma => vr_cdprogra,
                             pr_cdcooper   => 3,
                             pr_idprglog   => vr_idprglog);
      ROLLBACK;

    WHEN OTHERS THEN
      cecred.pc_internal_exception;
      pc_limpa_tabela;
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => pr_dscritic,
                             pr_cdmensagem => 333,
                             pr_cdprograma => vr_cdprogra,
                             pr_cdcooper   => 3,
                             pr_idprglog   => vr_idprglog);
      ROLLBACK;
END;
