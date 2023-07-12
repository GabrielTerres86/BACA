DECLARE

  pr_cdcooper CECRED.crapcop.cdcooper%TYPE;
  pr_cddbanco CECRED.crapcco.cddbanco%TYPE;
  vr_dtmvtaux CECRED.crapdat.dtmvtoan%TYPE;

  vr_cdprogra      CECRED.crapprg.cdprogra%TYPE;
  vr_idlog_ini_ger CECRED.tbgen_prglog.idprglog%TYPE;
  vr_idprglog      CECRED.tbgen_prglog.idprglog%TYPE;
  vr_idparale      INTEGER;
  vr_idprogra      INTEGER;
  vr_jobname       VARCHAR2(30);
  vr_dsplsql       VARCHAR2(4000);
  vr_qtdjobs       NUMBER;
  vr_nomdojob      VARCHAR2(100);
  vr_qterro        NUMBER;
  rw_crapdat       CECRED.BTCH0001.cr_crapdat%ROWTYPE;

  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_exc_saida EXCEPTION;

  CURSOR cr_crapcop IS
    SELECT cdcooper
          ,cdbcoctl
      FROM CECRED.crapcop
     WHERE cdcooper <> 3
       AND flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;

  PROCEDURE pc_controla_log_programa(pr_dstiplog      IN VARCHAR2
                                    ,pr_tpocorrencia  IN NUMBER DEFAULT NULL
                                    ,pr_dscritic      IN VARCHAR2 DEFAULT NULL
                                    ,pr_cdcritic      IN CECRED.tbgen_prglog_ocorrencia.cdmensagem%TYPE DEFAULT 0
                                    ,pr_cdcooperprog  IN CECRED.crapcop.cdcooper%TYPE DEFAULT pr_cdcooper
                                    ,pr_cdcriticidade IN CECRED.tbgen_prglog_ocorrencia.cdcriticidade%TYPE DEFAULT 2) IS
  BEGIN
    CECRED.pc_log_programa(pr_dstiplog      => pr_dstiplog
                          ,pr_cdprograma    => vr_cdprogra
                          ,pr_cdcooper      => pr_cdcooper
                          ,pr_tpexecucao    => 2
                          ,pr_tpocorrencia  => pr_tpocorrencia
                          ,pr_cdcriticidade => pr_cdcriticidade
                          ,pr_dsmensagem    => pr_dscritic || ', pr_cdcooper:' || pr_cdcooper ||
                                               ', pr_cdcooperprog:' || pr_cdcooperprog
                          ,pr_cdmensagem    => pr_cdcritic
                          ,pr_idprglog      => vr_idprglog);
  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
  END pc_controla_log_programa;

  PROCEDURE pc_prep_retorno_vazio(pr_cdcooper IN CECRED.craprtc.cdcooper%TYPE
                                 ,pr_dtmvtolt IN DATE) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    DECLARE
      CURSOR cr_craprtc(pr_cdcooper IN CECRED.craprtc.cdcooper%TYPE
                       ,pr_nrcnvcob IN CECRED.craprtc.nrcnvcob%TYPE
                       ,pr_nrdconta IN CECRED.craprtc.nrdconta%TYPE
                       ,pr_dtmvtolt IN CECRED.craprtc.dtmvtolt%TYPE) IS
        SELECT craprtc.nrremret
          FROM CECRED.craprtc
         WHERE craprtc.cdcooper = pr_cdcooper
           AND craprtc.nrcnvcob = pr_nrcnvcob
           AND craprtc.nrdconta = pr_nrdconta
           AND craprtc.dtmvtolt = pr_dtmvtolt
           AND craprtc.intipmvt = 2;
      rw_craprtc cr_craprtc%ROWTYPE;
    
      vr_nmarquiv VARCHAR2(100);
      vr_nrremrtc INTEGER;
      vr_cdcritic CECRED.crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_exc_erro EXCEPTION;
      vr_dsparame VARCHAR2(4000);
    BEGIN
    
      CECRED.GENE0001.pc_set_modulo(pr_module => NULL
                                   ,pr_action => 'ARQRETCOB.pc_prep_retorno_vazio');
    
      vr_cdcritic := NULL;
      vr_dscritic := NULL;
    
      vr_dsparame := ' pr_cdcooper:' || pr_cdcooper || ',pr_dtmvtolt:' || pr_dtmvtolt;
    
      vr_nmarquiv := 'cobret' || TO_CHAR(pr_dtmvtolt, 'MMDD');
    
      FOR rw_ceb IN (SELECT ceb.cdcooper
                           ,ceb.nrdconta
                           ,ceb.nrconven
                       FROM CECRED.crapceb ceb
                           ,CECRED.crapcco cco
                      WHERE cco.cdcooper = pr_cdcooper
                        AND cco.cddbanco = 85
                        AND cco.dsorgarq NOT IN ('MIGRACAO', 'INCORPORACAO')
                        AND ceb.cdcooper = cco.cdcooper
                        AND ceb.nrconven = cco.nrconven
                        AND ceb.insitceb = 1
                        AND ceb.inenvcob = 2) LOOP
      
        OPEN cr_craprtc(pr_cdcooper => rw_ceb.cdcooper
                       ,pr_nrcnvcob => rw_ceb.nrconven
                       ,pr_nrdconta => rw_ceb.nrdconta
                       ,pr_dtmvtolt => pr_dtmvtolt);
      
        FETCH cr_craprtc
          INTO rw_craprtc;
      
        IF cr_craprtc%NOTFOUND THEN
        
          CLOSE cr_craprtc;
        
          vr_nrremrtc := CECRED.fn_sequence(pr_nmtabela => 'CRAPRTC'
                                           ,pr_nmdcampo => 'NRREMRET'
                                           ,pr_dsdchave => rw_ceb.cdcooper || ';' || rw_ceb.nrdconta || ';' ||
                                                           rw_ceb.nrconven || ';2');
        
          BEGIN
            INSERT INTO CECRED.craprtc
              (craprtc.cdcooper
              ,craprtc.nrdconta
              ,craprtc.nrcnvcob
              ,craprtc.dtmvtolt
              ,craprtc.nrremret
              ,craprtc.nmarquiv
              ,craprtc.flgproce
              ,craprtc.dtdenvio
              ,craprtc.qtreglot
              ,craprtc.cdoperad
              ,craprtc.dtaltera
              ,craprtc.hrtransa
              ,craprtc.intipmvt)
            VALUES
              (rw_ceb.cdcooper
              ,rw_ceb.nrdconta
              ,rw_ceb.nrconven
              ,pr_dtmvtolt
              ,vr_nrremrtc
              ,vr_nmarquiv
              ,0
              ,NULL
              ,1
              ,'1'
              ,pr_dtmvtolt
              ,CECRED.GENE0002.fn_busca_time
              ,2);
          EXCEPTION
            WHEN OTHERS THEN
            
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            
              vr_cdcritic := 1034;
              vr_dscritic := CECRED.GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                             'CRAPRTC(24):' || ' cdcooper:' || rw_ceb.cdcooper || ', nrdconta:' ||
                             rw_ceb.nrdconta || ', nrcnvcob:' || rw_ceb.nrconven || ', dtmvtolt:' ||
                             pr_dtmvtolt || ', nrremret:' || vr_nrremrtc || ', nmarquiv:' ||
                             vr_nmarquiv || ', flgproce:' || '0' || ', dtdenvio:' || 'NULL' ||
                             ', qtreglot:' || '1' || ', dtaltera:' || pr_dtmvtolt || ', hrtransa:' ||
                             CECRED.GENE0002.fn_busca_time || ', intipmvt:' || '2' || '. ' ||
                             SQLERRM;
            
              RAISE vr_exc_erro;
          END;
        END IF;
      
        IF cr_craprtc%ISOPEN THEN
          CLOSE cr_craprtc;
        END IF;
      
        COMMIT;
      
      END LOOP;
    
      CECRED.GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
    
    EXCEPTION
      WHEN vr_exc_erro THEN
      
        ROLLBACK;
      
        vr_dscritic := vr_dscritic || vr_dsparame;
      
        pc_controla_log_programa(pr_dstiplog      => 'E'
                                ,pr_tpocorrencia  => 3
                                ,pr_dscritic      => vr_dscritic
                                ,pr_cdcritic      => vr_cdcritic
                                ,pr_cdcooperprog  => pr_cdcooper
                                ,pr_cdcriticidade => 1);
      
      WHEN OTHERS THEN
      
        ROLLBACK;
      
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
      
        vr_cdcritic := 9999;
        vr_dscritic := CECRED.GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                       'ARQRETCOB.pc_prep_retorno_vazio. ' || SQLERRM || '.' || vr_dsparame;
    END;
  END pc_prep_retorno_vazio;

  PROCEDURE pc_gera_arq_cooperad_par(pr_cdcooper IN CECRED.crapcop.cdcooper%TYPE
                                    ,pr_cddbanco IN CECRED.crapcco.cddbanco%TYPE
                                    ,pr_cdcritic OUT INTEGER
                                    ,pr_dscritic OUT VARCHAR2) IS
    CURSOR cr_crapcco_ativo(pr_cdcooper IN CECRED.crapcco.cdcooper%TYPE
                           ,pr_cddbanco IN CECRED.crapcco.cddbanco%TYPE
                           ,pr_dtmvtaux IN CECRED.crapdat.dtmvtolt%TYPE
                           ,pr_cdprogra IN CECRED.crapprg.cdprogra%TYPE) IS
      SELECT crapcco.cdcooper
            ,crapcco.nrconven
            ,crapcco.nrdctabb
            ,crapcco.cddbanco
            ,crapcco.cdagenci
            ,crapcco.cdbccxlt
            ,crapcco.nrdolote
            ,crapcco.dsorgarq
            ,crapceb.nrdconta
        FROM CECRED.crapcco
            ,CECRED.crapceb
       WHERE crapcco.cdcooper = pr_cdcooper
         AND crapcco.cddbanco = pr_cddbanco
         AND crapceb.cdcooper = crapcco.cdcooper
         AND crapceb.nrconven = crapcco.nrconven
         AND crapceb.inarqcbr IN (2, 3)
            
         AND EXISTS (SELECT 1
                FROM CECRED.craprtc
               WHERE craprtc.cdcooper = crapcco.cdcooper
                 AND craprtc.nrcnvcob = crapcco.nrconven
                 AND craprtc.nrdconta = crapceb.nrdconta
                 AND craprtc.dtmvtolt = pr_dtmvtaux
                 AND craprtc.intipmvt = 2)
            
         AND NOT EXISTS
       (SELECT 1
                FROM CECRED.tbgen_batch_controle
               WHERE tbgen_batch_controle.cdcooper = pr_cdcooper
                 AND tbgen_batch_controle.cdprogra = pr_cdprogra
                 AND tbgen_batch_controle.tpagrupador = 3
                 AND tbgen_batch_controle.cdagrupador =
                     (lpad(crapcco.nrconven, 10, '0') || lpad(crapceb.nrdconta, 10, '0'))
                 AND tbgen_batch_controle.insituacao = 2
                 AND tbgen_batch_controle.dtmvtolt = pr_dtmvtaux)
            
         AND crapcco.flgregis = 1;
  
  BEGIN
  
    vr_idlog_ini_ger := NULL;
    CECRED.pc_log_programa(pr_dstiplog   => 'I'
                          ,pr_cdprograma => vr_cdprogra
                          ,pr_cdcooper   => pr_cdcooper
                          ,pr_tpexecucao => 2
                          ,pr_idprglog   => vr_idlog_ini_ger);
  
    vr_idparale := CECRED.GENE0001.fn_gera_ID_paralelo;
  
    IF vr_idparale = 0 THEN
      vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_ID_paral.';
      RAISE vr_exc_saida;
    END IF;
  
    FOR rw_crapcco IN cr_crapcco_ativo(pr_cdcooper => pr_cdcooper
                                      ,pr_cddbanco => pr_cddbanco
                                      ,pr_dtmvtaux => vr_dtmvtaux
                                      ,pr_cdprogra => vr_cdprogra) LOOP
    
      vr_cdcritic := 340;
      vr_dscritic := CECRED.GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                     ' de retorno ao cooperado: convenio:' || to_char(rw_crapcco.nrconven);
      pc_controla_log_programa(pr_dstiplog      => 'O'
                              ,pr_tpocorrencia  => 4
                              ,pr_cdcritic      => vr_cdcritic
                              ,pr_dscritic      => vr_dscritic
                              ,pr_cdcriticidade => 0
                              ,pr_cdcooperprog  => pr_cdcooper);
      vr_cdcritic := NULL;
      vr_dscritic := NULL;
    
      vr_idprogra := cr_crapcco_ativo%ROWCOUNT;
      vr_jobname  := vr_cdprogra || '_' || vr_idprogra || '$';
    
      CECRED.GENE0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                       ,pr_idprogra => vr_idprogra
                                       ,pr_des_erro => vr_dscritic);
    
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    
      vr_dsplsql := 'DECLARE' || chr(13) || '  wpr_cdcritic NUMBER;' || chr(13) ||
                    '  wpr_dscritic VARCHAR2(1500);' || chr(13) || 'BEGIN' || chr(13) ||
                    '  CECRED.PAGA0001.pc_gera_arq_cooperad_par ' || '            (' ||
                    rw_crapcco.cdcooper || '            ,' || rw_crapcco.nrconven ||
                    '            ,' || rw_crapcco.nrdconta || '            ,' || vr_idparale ||
                    '            ,' || vr_idprogra || '            ,to_date(''' ||
                    TO_CHAR(vr_dtmvtaux, 'dd/mm/rrrr') || ''',''dd/mm/rrrr'')' ||
                    '            ,1,0' || '            ,' || '''' || vr_cdprogra || '''' ||
                    '            ,wpr_cdcritic, wpr_dscritic);' || chr(13) || 'END;';
    
      CECRED.GENE0001.pc_submit_job(pr_cdcooper => pr_cdcooper
                                   ,pr_cdprogra => vr_cdprogra
                                   ,pr_dsplsql  => vr_dsplsql
                                   ,pr_dthrexe  => SYSTIMESTAMP
                                   ,pr_interva  => NULL
                                   ,pr_jobname  => vr_jobname
                                   ,pr_des_erro => vr_dscritic);
    
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    
      CECRED.gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                         ,pr_qtdproce => vr_qtdjobs
                                         ,pr_des_erro => vr_dscritic);
    
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    
    END LOOP;
  
    CECRED.GENE0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                       ,pr_qtdproce => 0
                                       ,pr_des_erro => vr_dscritic);
  
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    vr_qterro := CECRED.GENE0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper
                                                        ,pr_cdprogra    => vr_cdprogra
                                                        ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                                        ,pr_tpagrupador => 3
                                                        ,pr_nrexecucao  => 1);
    IF vr_qterro > 0 THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Paralelismo possui job executado com erro. Verificar na tabela tbgen_batch_controle e tbgen_prglog';
      RAISE vr_exc_saida;
    END IF;
  
    CECRED.GENE0001.pc_informa_acesso(pr_module => vr_cdprogra, pr_action => NULL);
  
    CECRED.pc_log_programa(pr_dstiplog   => 'F'
                          ,pr_cdprograma => vr_cdprogra
                          ,pr_cdcooper   => pr_cdcooper
                          ,pr_tpexecucao => 2
                          ,pr_idprglog   => vr_idlog_ini_ger
                          ,pr_flgsucesso => 1);
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic || ' pr_cdcooper:' || pr_cdcooper || ', pc_gera_arq_cooperado';
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
    
      pr_cdcritic := 9999;
      pr_dscritic := CECRED.GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                     ' pr_cdcooper:' || pr_cdcooper || ', pc_gera_arq_cooperado - ' || SQLERRM;
  END pc_gera_arq_cooperad_par;

BEGIN

  pr_cdcooper := 3;
  vr_cdprogra := 'ARQRETCOB';
  vr_idprglog := 0;

  pc_controla_log_programa(pr_dstiplog => 'I');

  vr_nomdojob := 'JBCOBRAN_ARQ_COOPERADO';
  vr_qtdjobs  := CECRED.GENE0001.fn_retorna_qt_paralelo(pr_cdcooper, vr_nomdojob);
  vr_dtmvtaux := TO_DATE('06/07/2023', 'DD/MM/YYYY');
  vr_cdcritic := NULL;
  vr_dscritic := NULL;

  FOR rw_crapcop IN cr_crapcop LOOP
  
    pr_cdcooper := rw_crapcop.cdcooper;
    pr_cddbanco := rw_crapcop.cdbcoctl;
    vr_idparale := 0;
    vr_qterro   := 0;
  
    OPEN CECRED.BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH CECRED.BTCH0001.cr_crapdat
      INTO rw_crapdat;
    IF CECRED.BTCH0001.cr_crapdat%NOTFOUND THEN
      CLOSE CECRED.BTCH0001.cr_crapdat;
      vr_cdcritic := 1;
      vr_dscritic := CECRED.GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      CLOSE CECRED.BTCH0001.cr_crapdat;
    END IF;
  
    pc_prep_retorno_vazio(pr_cdcooper => pr_cdcooper, pr_dtmvtolt => vr_dtmvtaux);
  
    pc_gera_arq_cooperad_par(pr_cdcooper => pr_cdcooper
                            ,pr_cddbanco => pr_cddbanco
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
    IF NVL(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
  END LOOP;

  pr_cdcooper := 3;
  pc_controla_log_programa(pr_dstiplog => 'F');

  COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
    vr_cdcritic := NVL(vr_cdcritic, 0);
    vr_dscritic := CECRED.GENE0001.fn_busca_critica(vr_cdcritic, vr_dscritic) || ', pr_cdcooper:' ||
                   pr_cdcooper;
    pc_controla_log_programa(pr_dstiplog      => 'E'
                            ,pr_tpocorrencia  => 2
                            ,pr_cdcritic      => vr_cdcritic
                            ,pr_dscritic      => vr_dscritic
                            ,pr_cdcriticidade => 2
                            ,pr_cdcooperprog  => pr_cdcooper);
    RAISE;
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_cdcooper => pr_cdcooper, pr_compleme => 'ARQRETCOB');
    ROLLBACK;
    vr_cdcritic := 9999;
    vr_dscritic := CECRED.GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || ', pr_cdcooper:' ||
                   pr_cdcooper || ', ARQRETCOB - ' || SQLERRM;
    pc_controla_log_programa(pr_dstiplog      => 'E'
                            ,pr_tpocorrencia  => 2
                            ,pr_cdcritic      => vr_cdcritic
                            ,pr_dscritic      => vr_dscritic
                            ,pr_cdcriticidade => 2
                            ,pr_cdcooperprog  => pr_cdcooper);
    RAISE;
END;
