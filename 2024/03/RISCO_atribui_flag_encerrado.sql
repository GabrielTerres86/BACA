declare 


  vr_cdcritic       PLS_INTEGER;
  vr_dscritic       VARCHAR2(4000);
  vr_dscritic_aux   VARCHAR2(400);
  vr_dtrefere       crapdat.dtmvtoan%TYPE;
  vr_exc_erro       EXCEPTION;


  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.flgativo = 1
       AND cop.cdcooper IN (1,2,5,6,7,8,9,10,11,12,13,14,16)
     ORDER BY cop.cdcooper DESC;
    rw_crapcop cr_crapcop%ROWTYPE;

  CURSOR cr_crapdat(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT dat.dtmvtolt
          ,dat.dtmvtopr
          ,dat.dtmvtoan
          ,dat.inproces
          ,dat.qtdiaute
          ,dat.cdprgant
          ,dat.dtmvtocd
          ,dat.dtultdia
          ,trunc(dat.dtmvtolt,'mm')                 dtinimes
          ,trunc(add_months(dat.dtmvtolt, 1), 'mm') dtpridms
          ,last_day(add_months(dat.dtmvtolt,-1))    dtultdma
          ,ROWID
          ,dat.dtmvcentral
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
  rw_crapdat cr_crapdat%ROWTYPE;

  CURSOR cr_dtrisco(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
    SELECT MAX(c.dtbase) dtbase
      FROM CREDITO.Tbepr_Imob_Imp_Arq_Risco   c        
     WHERE c.cdcooper = pr_cdcooper
       AND c.dtbase  <= pr_dtmvtolt;
  rw_dtrisco cr_dtrisco%ROWTYPE;


  PROCEDURE pc_encerrar_contratos(pr_cdcooper IN crapcop.cdcooper%TYPE
                                 ,pr_dtbase   IN CREDITO.tbepr_imob_imp_arq_risco.dtbase%TYPE DEFAULT NULL                                
                                 ,pr_cdcritic OUT PLS_INTEGER  
                                 ,pr_dscritic OUT VARCHAR2
                                 ) IS 

        rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    CURSOR cr_encerracontratos(pr_cdcooper crapcop.cdcooper%TYPE
                              ,pr_dtrating crapdat.dtmvtolt%TYPE
                              ,pr_dtmvtolt crapdat.dtmvtolt%TYPE
                              ,pr_dtbase   CREDITO.tbepr_imob_imp_arq_risco.dtbase%TYPE                                 
                              ) IS
      SELECT 
             epr.cdcooper       cdcooper
            ,epr.nrdconta       nrdconta
            ,epr.nrctremp       nrctrato
            ,opr.tpctrato       tpctrato
            ,epr.inliquid       tpsituacao
            ,opr.flintegrar_sas
            ,opr.flencerrado
            ,opr.rowid          row_id
        FROM crapepr epr, tbrisco_operacoes opr
       WHERE epr.cdcooper = opr.cdcooper
         AND epr.nrdconta = opr.nrdconta
         AND epr.nrctremp = opr.nrctremp
         AND opr.cdcooper = pr_cdcooper
         AND opr.tpctrato = 90   
         AND epr.inliquid = 1     
         AND opr.flencerrado = 0
         AND ((epr.cdfinemp = 68 AND
               epr.dtmvtolt < to_date(pr_dtrating, 'DD/MM/yyyy')) OR
             epr.cdfinemp <> 68)
      UNION ALL
      
      
      SELECT 
             epr.cdcooper       cdcooper
            ,epr.nrdconta       nrdconta
            ,epr.nrctremp       nrctrato
            ,opr.tpctrato       tpctrato
            ,epr.inliquid       tpsituacao
            ,opr.flintegrar_sas
            ,opr.flencerrado
            ,opr.rowid          row_id
        FROM crapepr epr, tbrisco_operacoes opr
       WHERE epr.cdcooper = opr.cdcooper
         AND epr.nrdconta = opr.nrdconta
         AND epr.nrctremp = opr.nrctremp
         AND opr.cdcooper = pr_cdcooper
         AND opr.tpctrato = 90   
         AND epr.inliquid = 1    
         AND opr.flencerrado = 0
         AND epr.cdfinemp = 68   
         AND epr.dtmvtolt >= to_date(pr_dtrating, 'DD/MM/yyyy')  
         AND NOT EXISTS (SELECT 1    
                           FROM crapcpa              cpa
                               ,tbepr_carga_pre_aprv pre
                          WHERE pre.cdcooper           = cpa.cdcooper
                            AND pre.idcarga            = cpa.iddcarga
                            AND pre.cdcooper           = opr.cdcooper
                            AND cpa.nrcpfcnpj_base     = opr.nrcpfcnpj_base
                            AND pre.flgcarga_bloqueada = 0 
                            AND pre.indsituacao_carga  = 2 
                            AND nvl(pre.dtfinal_vigencia, pr_dtmvtolt) >= pr_dtmvtolt 
                        )
      UNION ALL

      SELECT 
             lim.cdcooper       cdcooper
            ,lim.nrdconta       nrdconta
            ,lim.nrctrlim       nrctrato
            ,opr.tpctrato       tpctrato
            ,lim.insitlim       tpsituacao
            ,opr.flintegrar_sas
            ,opr.flencerrado
            ,opr.rowid          row_id
        FROM craplim lim, tbrisco_operacoes opr
       WHERE lim.cdcooper = pr_cdcooper
         AND lim.cdcooper = opr.cdcooper
         AND lim.nrdconta = opr.nrdconta
         AND lim.nrctrlim = opr.nrctremp
         AND lim.tpctrlim = opr.tpctrato
         AND opr.flencerrado = 0
         AND opr.flintegrar_sas = 1
         AND ((opr.tpctrato IN (2, 3) AND lim.insitlim >= 3) OR
              (opr.tpctrato = 1       AND lim.insitlim = 3)
             )
      UNION ALL
      SELECT opr.cdcooper       cdcooper
            ,ass.nrdconta       nrdconta
            ,opr.nrctremp       nrctrato
            ,opr.tpctrato       tpctrato
            ,1                  tpsituacao 
            ,opr.flintegrar_sas
            ,opr.flencerrado
            ,opr.rowid          row_id
        FROM tbrisco_operacoes opr, crapass ass
       WHERE opr.cdcooper = pr_cdcooper
         AND opr.tpctrato = 68
         AND opr.flencerrado = 0
         AND ass.cdcooper = opr.cdcooper
         AND ass.nrcpfcgc = opr.nrcpfcnpj_base
         AND NOT EXISTS (SELECT 1  
                           FROM crapepr epr
                          WHERE epr.cdcooper = opr.cdcooper
                            AND epr.nrdconta = ass.nrdconta
                            AND epr.inliquid = 0    
                            AND epr.cdfinemp = 68   
                            AND epr.dtmvtolt >= to_date(pr_dtrating, 'DD/MM/yyyy')  
                        )
         AND NOT EXISTS (SELECT 1
                           FROM crapcpa              cpa
                               ,tbepr_carga_pre_aprv pre
                          WHERE pre.cdcooper           = cpa.cdcooper
                            AND pre.idcarga            = cpa.iddcarga
                            AND pre.cdcooper           = opr.cdcooper
                            AND cpa.nrcpfcnpj_base     = opr.nrcpfcnpj_base
                            AND pre.flgcarga_bloqueada = 0 
                            AND pre.indsituacao_carga  = 2 
                            AND nvl(pre.dtfinal_vigencia, to_date(pr_dtmvtolt, 'DD/MM/yyyy')) >= to_date(pr_dtmvtolt, 'DD/MM/yyyy') 
                        )
      UNION ALL
      SELECT opr.cdcooper       cdcooper
            ,opr.nrdconta       nrdconta
            ,opr.nrctremp       nrctrato
            ,opr.tpctrato       tpctrato
            ,0                  tpsituacao
            ,opr.flintegrar_sas
            ,case when dtvencto_rating < (select dtmvtolt from crapdat where cdcooper = opr.cdcooper ) then 1  else opr.flencerrado end as flencerrado
            ,opr.rowid          row_id
        FROM tbrisco_operacoes opr
       WHERE opr.cdcooper = pr_cdcooper
         AND opr.tpctrato = 11          
         AND opr.flencerrado = 0
      UNION ALL
      
      SELECT 
             imo.cdcooper       cdcooper
            ,imo.nrdconta       nrdconta
            ,imo.nrctremp       nrctrato
            ,opr.tpctrato       tpctrato
            ,0 tpsituacao 
            ,opr.flintegrar_sas
            ,opr.flencerrado
            ,opr.rowid          row_id
        FROM CREDITO.Tbepr_Contrato_Imobiliario imo
            ,CREDITO.Tbepr_Imob_Imp_Arq_Risco   ris
            ,tbrisco_operacoes opr
       WHERE imo.cdcooper = opr.cdcooper
         AND imo.nrdconta = opr.nrdconta
         AND imo.nrctremp = opr.nrctremp
         AND opr.flencerrado = 0
         AND imo.tipo_registro = 2 
         AND imo.data_assinatura IS NOT NULL 
         AND opr.cdcooper = pr_cdcooper
         AND opr.tpctrato = 93   
         AND imo.cdcooper = ris.cdcooper
         AND imo.nrdconta = ris.nrdconta
         AND imo.nrctremp = ris.contrt
         AND ris.dtbase   = pr_dtbase       
         AND NVL(ris.tp_inf,0) BETWEEN 301 AND 399 
         ;         
    rw_encerracontratos cr_encerracontratos%ROWTYPE;

    
    CURSOR cr_ris_adp (pr_cdcooper crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapris.nrdconta%TYPE
                      ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
      SELECT r.dtinictr 
            ,r.qtdriclq
        FROM crapris r
       WHERE r.cdcooper = pr_cdcooper
         AND r.nrdconta = pr_nrdconta
         AND r.dtrefere = pr_dtrefere
         AND r.nrctremp = pr_nrdconta 
         AND r.cdmodali = 101; 
    rw_ris_adp      cr_ris_adp%ROWTYPE;

    
    vr_dt_corte_refor_rating DATE;
    vr_modelo_rating         tbrat_param_geral.tpmodelo_rating%TYPE;

    
    vr_exc_erro     EXCEPTION;
    vr_cdcritic     PLS_INTEGER;
    vr_dscritic     VARCHAR2(4000);
    vr_dscritic_aux VARCHAR2(400);

    vr_nrdrowid     ROWID;
    vr_dsproduto    VARCHAR2(3);
    vr_dtrefere     DATE;                   

    
  BEGIN
    pr_cdcritic := 0;
    pr_dscritic := NULL;

    vr_dt_corte_refor_rating := to_date(gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                                  pr_cdcooper => 0,
                                                                  pr_cdacesso => 'DT_CORTE_REFOR_RATING'),'dd/mm/rrrr');
    IF vr_dt_corte_refor_rating IS NULL THEN
      
      vr_dt_corte_refor_rating := to_date('13/09/2019', 'dd/mm/yyyy');
    END IF;

    
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    
    IF btch0001.cr_crapdat%NOTFOUND THEN
      
      vr_dscritic := gene0001.fn_busca_critica(1);
      CLOSE btch0001.cr_crapdat;
      RAISE vr_exc_erro;
    END IF;
    
    CLOSE btch0001.cr_crapdat;


    sistema.Gravarlogprograma(pr_cdcooper      => 3
                             ,pr_ind_tipo_log  => 4
                             ,pr_des_log       => 'SCRIPT_ENCERRAR_CTR' || ' ==> Inicio da execucao: ' || 'SCRIPT_ENCERRAR_CTR'
                             ,pr_cdprograma    => 'SCRIPT_ENCERRAR_CTR'
                             ,pr_tpexecucao    => 1);

    
    FOR rw_encerracontratos IN cr_encerracontratos(pr_cdcooper => pr_cdcooper
                                                  ,pr_dtrating => vr_dt_corte_refor_rating
                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                  ,pr_dtbase   => pr_dtbase) LOOP

      
      IF rw_encerracontratos.tpctrato IN (90,93) THEN
        BEGIN
          UPDATE tbrisco_operacoes t
             SET t.flencerrado    = 1   
                ,t.flintegrar_sas = 0   
                ,t.dhalteracao    = SYSDATE
                ,t.dhtransmissao  = NULL
           WHERE ROWID = rw_encerracontratos.row_id;
        EXCEPTION
          WHEN OTHERS THEN
            
            gene0001.pc_gera_log(pr_cdcooper => rw_encerracontratos.cdcooper,
                                 pr_cdoperad => '1',
                                 pr_dscritic => 'Erro BACA ao atualizar Rating flag SAS/Encerrado (EMP). ' || SQLERRM,
                                 pr_dsorigem => 'LOTE',
                                 pr_dstransa => 'Processa BACA Rating Operacoes flag SAS/Encerrado (EMP)',
                                 pr_dttransa => trunc(SYSDATE),
                                 pr_flgtrans => 1, 
                                 pr_hrtransa => gene0002.fn_busca_time,
                                 pr_idseqttl => 1,
                                 pr_nmdatela => 'RATING',
                                 pr_nrdconta => rw_encerracontratos.nrdconta,
                                 pr_nrdrowid => vr_nrdrowid);
        END;
        COMMIT;

      
      ELSIF rw_encerracontratos.tpctrato IN (2, 3) THEN
        
        IF rw_encerracontratos.tpctrato = 2 THEN
          vr_dsproduto := 'CHQ';
        ELSE
          vr_dsproduto := 'TIT';
        END IF;

        
        IF RATI0003.fn_valida_limite_chq_tit(pr_cdcooper => rw_encerracontratos.cdcooper,
                                    pr_nrdconta => rw_encerracontratos.nrdconta,
                                    pr_nrctremp => rw_encerracontratos.nrctrato,
                                    pr_tpctrato => rw_encerracontratos.tpctrato,
                                    pr_dtrefere => rw_crapdat.dtmvtolt) = 0 THEN
          
          BEGIN
            UPDATE tbrisco_operacoes t
               SET t.flencerrado    = 1   
                  ,t.flintegrar_sas = 0   
                  ,t.dhalteracao    = SYSDATE
                  ,t.dhtransmissao  = NULL
             WHERE ROWID = rw_encerracontratos.row_id;
          EXCEPTION
            WHEN OTHERS THEN
              
              gene0001.pc_gera_log(pr_cdcooper => rw_encerracontratos.cdcooper,
                                   pr_cdoperad => '1',
                                   pr_dscritic => 'Erro BACA ao atualizar Rating flag SAS/Encerrado ('||
                                                   vr_dsproduto
                                                  || ').' || SQLERRM,
                                   pr_dsorigem => 'LOTE',
                                   pr_dstransa => 'Processa BACA Rating Operacoes flag SAS/Encerrado  ('||
                                                   vr_dsproduto
                                                  || ').',
                                   pr_dttransa => trunc(SYSDATE),
                                   pr_flgtrans => 1, 
                                   pr_hrtransa => gene0002.fn_busca_time,
                                   pr_idseqttl => 1,
                                   pr_nmdatela => 'RATING',
                                   pr_nrdconta => rw_encerracontratos.nrdconta,
                                   pr_nrdrowid => vr_nrdrowid);
          END;
          COMMIT;

        END IF;

      
      ELSIF rw_encerracontratos.tpctrato = 1 THEN
        
        BEGIN
          UPDATE tbrisco_operacoes t
             SET t.flencerrado    = 1   
                ,t.flintegrar_sas = 0   
                ,t.dhalteracao    = SYSDATE
                ,t.dhtransmissao  = NULL
           WHERE ROWID = rw_encerracontratos.row_id;
        EXCEPTION
          WHEN OTHERS THEN
            
            gene0001.pc_gera_log(pr_cdcooper => rw_encerracontratos.cdcooper,
                                 pr_cdoperad => '1',
                                 pr_dscritic => 'Erro BACA ao atualizar Rating flag SAS/Encerrado (LIM). ' || SQLERRM,
                                 pr_dsorigem => 'LOTE',
                                 pr_dstransa => 'Processa BACA Rating Operacoes flag SAS/Encerrado (LIM)',
                                 pr_dttransa => trunc(SYSDATE),
                                 pr_flgtrans => 1, 
                                 pr_hrtransa => gene0002.fn_busca_time,
                                 pr_idseqttl => 1,
                                 pr_nmdatela => 'RATING',
                                 pr_nrdconta => rw_encerracontratos.nrdconta,
                                 pr_nrdrowid => vr_nrdrowid);
        END;
        COMMIT;
      
      ELSIF rw_encerracontratos.tpctrato = 11 THEN

        
        OPEN cr_ris_adp (pr_cdcooper => rw_encerracontratos.cdcooper
                        ,pr_nrdconta => rw_encerracontratos.nrdconta
                        ,pr_dtrefere => rw_crapdat.dtmvcentral);
        FETCH cr_ris_adp INTO rw_ris_adp;

        IF cr_ris_adp%NOTFOUND THEN 
          CLOSE cr_ris_adp;

          BEGIN
            UPDATE tbrisco_operacoes t
               SET t.flencerrado    = 1   
                  ,t.flintegrar_sas = 0   
                  ,t.dhalteracao    = SYSDATE
                  ,t.dhtransmissao  = NULL
             WHERE ROWID = rw_encerracontratos.row_id;
          EXCEPTION
            WHEN OTHERS THEN
              
              gene0001.pc_gera_log(pr_cdcooper => rw_encerracontratos.cdcooper,
                                   pr_cdoperad => '1',
                                   pr_dscritic => 'Erro BACA ao atualizar Rating flag SAS/Encerrado (ADP). ' || SQLERRM,
                                   pr_dsorigem => 'LOTE',
                                   pr_dstransa => 'Processa BACA Rating Operacoes flag SAS/Encerrado (ADP)',
                                   pr_dttransa => trunc(SYSDATE),
                                   pr_flgtrans => 1, 
                                   pr_hrtransa => gene0002.fn_busca_time,
                                   pr_idseqttl => 1,
                                   pr_nmdatela => 'RATING',
                                   pr_nrdconta => rw_encerracontratos.nrdconta,
                                   pr_nrdrowid => vr_nrdrowid);
          END;
          COMMIT;
        ELSE
          CLOSE cr_ris_adp;
        END IF;

         
      ELSE
        
        BEGIN
          UPDATE tbrisco_operacoes t
             SET t.flintegrar_sas = 0   
                ,t.dhalteracao    = SYSDATE
                ,t.dhtransmissao  = NULL
           WHERE ROWID = rw_encerracontratos.row_id;
        EXCEPTION
          WHEN OTHERS THEN
            
            gene0001.pc_gera_log(pr_cdcooper => rw_encerracontratos.cdcooper,
                                 pr_cdoperad => '1',
                                 pr_dscritic => 'Erro BACA ao atualizar Rating flag SAS/Encerrado (PRE). ' || SQLERRM,
                                 pr_dsorigem => 'LOTE',
                                 pr_dstransa => 'Processa BACA Rating Operacoes flag SAS/Encerrado (PRE)',
                                 pr_dttransa => trunc(SYSDATE),
                                 pr_flgtrans => 1, 
                                 pr_hrtransa => gene0002.fn_busca_time,
                                 pr_idseqttl => 1,
                                 pr_nmdatela => 'RATING',
                                 pr_nrdconta => rw_encerracontratos.nrdconta,
                                 pr_nrdrowid => vr_nrdrowid);
        END;
        COMMIT;

      END IF;

      sistema.Gravarlogprograma(pr_cdcooper      => 3
                               ,pr_ind_tipo_log  => 4
                               ,pr_des_log       => 'SCRIPT_ENCERRAR_CTR' || 'COP: ' || rw_encerracontratos.cdcooper ||
                                                                             ' CTA: '|| rw_encerracontratos.nrdconta ||
                                                                             ' CTR: ' || rw_encerracontratos.nrctrato ||
                                                                             ' TIP: ' || rw_encerracontratos.tpctrato ||
                                                                             ' rwoid: ' || rw_encerracontratos.row_id
                               ,pr_cdprograma    => 'SCRIPT_ENCERRAR_CTR'
                               ,pr_tpexecucao    => 1);

    END LOOP;

  EXCEPTION
    WHEN vr_exc_erro THEN
      vr_dscritic := vr_dscritic_aux || vr_dscritic;
      ROLLBACK;
    WHEN OTHERS THEN
      vr_dscritic := vr_dscritic_aux || 'Erro BACA rotina Encerrar Contratos[BACA] ' || SQLERRM;
      ROLLBACK;
  END pc_encerrar_contratos;


  BEGIN
    

      FOR rw_crapcop IN cr_crapcop LOOP

        OPEN  cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
        FETCH cr_crapdat INTO rw_crapdat;

        IF cr_crapdat%NOTFOUND THEN
          CLOSE cr_crapdat;

          vr_dscritic:= 'Erro: '||vr_dscritic;

          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_crapdat;
        END IF;

        OPEN  cr_dtrisco(pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
        FETCH cr_dtrisco INTO rw_dtrisco;
        CLOSE cr_dtrisco;
   
        IF TRIM(rw_dtrisco.dtbase) IS NULL THEN
          rw_dtrisco.dtbase := TRUNC(rw_crapdat.dtmvtolt,'MM');
        END IF;


        pc_encerrar_contratos(pr_cdcooper => rw_crapcop.cdcooper
                             ,pr_dtbase   => rw_dtrisco.dtbase
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic );
        IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          vr_dscritic := 'Erro: ' || vr_dscritic;
          RAISE vr_exc_erro;
        END IF;
        COMMIT;

    END LOOP;

    sistema.Gravarlogprograma(pr_cdcooper      => 3
                             ,pr_ind_tipo_log  => 4
                             ,pr_des_log       => 'SCRIPT_ENCERRAR_CTR' || ' ==> Termino da execucao: ' || 'SCRIPT_ENCERRAR_CTR'
                             ,pr_cdprograma    => 'SCRIPT_ENCERRAR_CTR'
                             ,pr_tpexecucao    => 1);


  EXCEPTION
    WHEN vr_exc_erro THEN
       vr_dscritic := vr_dscritic_aux || vr_dscritic;
    raise_application_error(-20000, vr_dscritic);
       ROLLBACK;
    WHEN OTHERS THEN
       vr_dscritic:= vr_dscritic_aux || 'Erro na rotina pc_atualizar_rating_sas '||SQLERRM;
       raise_application_error(-20000, vr_dscritic);

       ROLLBACK;


end;
