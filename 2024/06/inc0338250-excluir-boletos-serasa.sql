DECLARE

  PROCEDURE atualizarExclusaoBoleto(pr_rowid    IN ROWID
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
  
    CURSOR cr_crapcob IS
      SELECT a.inserasa
            ,a.cdcooper
            ,a.cdbandoc
            ,a.nrdctabb
            ,a.nrcnvcob
            ,a.nrdconta
            ,a.nrdocmto
            ,b.cdagenci
            ,b.cdbccxlt
            ,b.nrdolote
            ,b.nrconven
            ,a.dtretser
            ,a.dtvencto
            ,c.dtmvtolt
        FROM cecred.crapdat c
            ,cecred.crapcco b
            ,cecred.crapcob a
       WHERE a.ROWID = pr_rowid
         AND c.cdcooper = a.cdcooper
         AND b.cdcooper = a.cdcooper
         AND b.nrconven = a.nrcnvcob;
    rw_crapcob cr_crapcob%ROWTYPE;
  
    CURSOR cr_dtlipgto(pr_rowid    ROWID
                      ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
      SELECT cob.dtvencto
            ,cob.vldescto
            ,cob.vlabatim
            ,cob.flgdprot
        FROM crapcob cob
       WHERE cob.dtlipgto < pr_dtmvtolt
         AND cob.incobran = 0
         AND cob.rowid = pr_rowid;
    rw_dtlipgto cr_dtlipgto%ROWTYPE;
  
    CURSOR cr_ultimaSituacaoSerasa(pr_cdcooper crapcob.cdcooper%TYPE
                                  ,pr_nrdconta crapcob.nrdconta%TYPE
                                  ,pr_cdbandoc crapcob.cdbandoc%TYPE
                                  ,pr_nrdctabb crapcob.nrdctabb%TYPE
                                  ,pr_nrcnvcob crapcob.nrcnvcob%TYPE
                                  ,pr_nrdocmto crapcob.nrdocmto%TYPE) IS
      WITH UltimoSequencial AS
       (SELECT NVL(MAX(nrsequencia), 0) nrsequencia
          FROM CECRED.tbcobran_his_neg_serasa
         WHERE cdcooper = pr_cdcooper
           AND cdbandoc = pr_cdbandoc
           AND nrdctabb = pr_nrdctabb
           AND nrcnvcob = pr_nrcnvcob
           AND nrdconta = pr_nrdconta
           AND nrdocmto = pr_nrdocmto),
      UltimaSituacao AS
       (SELECT inserasa
          FROM CECRED.tbcobran_his_neg_serasa
         INNER JOIN UltimoSequencial
            ON tbcobran_his_neg_serasa.nrsequencia = UltimoSequencial.nrsequencia
         WHERE tbcobran_his_neg_serasa.cdcooper = pr_cdcooper
           AND tbcobran_his_neg_serasa.cdbandoc = pr_cdbandoc
           AND tbcobran_his_neg_serasa.nrdctabb = pr_nrdctabb
           AND tbcobran_his_neg_serasa.nrcnvcob = pr_nrcnvcob
           AND tbcobran_his_neg_serasa.nrdconta = pr_nrdconta
           AND tbcobran_his_neg_serasa.nrdocmto = pr_nrdocmto)
      SELECT inserasa FROM UltimaSituacao;
    rw_ultimaSituacaoSerasa cr_ultimaSituacaoSerasa%ROWTYPE;
  
    CURSOR cr_dtvencto(pr_rowid ROWID) IS
      SELECT cob.dtvencto
            ,cob.vldescto
            ,cob.vlabatim
            ,cob.flgdprot
        FROM crapcob cob
       WHERE cob.rowid = pr_rowid
         AND cob.incobran = 0;
    rw_dtvencto cr_dtvencto%ROWTYPE;
  
    vr_intipret            PLS_INTEGER;
    vr_inserasa            crapcob.inserasa%TYPE;
    vr_dtretser            DATE;
    vr_dslog               VARCHAR2(500);
    vr_cdcritic            NUMBER := 0;
    vr_dscritic            VARCHAR2(4000);
    vr_des_erro            VARCHAR2(10);
    vr_tab_lcm             PAGA0001.typ_tab_lcm_consolidada;
    vr_tab_lat_consolidada PAGA0001.typ_tab_lat_consolidada;
  
    vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
    vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;
  
    vr_exc_saida EXCEPTION;
  
  BEGIN
  
    OPEN cr_crapcob;
    FETCH cr_crapcob
      INTO rw_crapcob;
    IF cr_crapcob%NOTFOUND THEN
      raise_application_error(-20001, 'cr_crapcob - Boleto nao encontrado');
    END IF;
    CLOSE cr_crapcob;
  
    vr_intipret := 2;
    vr_inserasa := 0;
    vr_dtretser := NULL;
    vr_dslog    := 'Exclusão do cancelamento de negativacao do boleto - Serasa';
  
    IF vr_intipret = 2 AND vr_inserasa = 0 THEN
      UPDATE cecred.crapcob
         SET flserasa = 0
            ,qtdianeg = 0
       WHERE ROWID = pr_rowid;
    END IF;
  
    IF (NOT (vr_intipret = 1)) OR vr_inserasa = 6 THEN
      BEGIN
        UPDATE crapcob
           SET inserasa = vr_inserasa
              ,dtretser = vr_dtretser
         WHERE ROWID = pr_rowid;
      
        OPEN cr_ultimaSituacaoSerasa(pr_cdcooper => rw_crapcob.cdcooper
                                    ,pr_nrdconta => rw_crapcob.nrdconta
                                    ,pr_cdbandoc => rw_crapcob.cdbandoc
                                    ,pr_nrdctabb => rw_crapcob.nrdctabb
                                    ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                                    ,pr_nrdocmto => rw_crapcob.nrdocmto);
        FETCH cr_ultimaSituacaoSerasa
          INTO rw_ultimaSituacaoSerasa;
        CLOSE cr_ultimaSituacaoSerasa;
      
        IF vr_inserasa IN (0, 6) AND NVL(rw_ultimaSituacaoSerasa.inserasa, -1) NOT IN (0, 6) THEN
          BEGIN
          
            UPDATE crapcob SET dtlipgto = ADD_MONTHS(dtlipgto, -60) WHERE ROWID = pr_rowid;
          
            OPEN cr_dtlipgto(pr_dtmvtolt => pr_dtmvtolt, pr_rowid => pr_rowid);
            FETCH cr_dtlipgto
              INTO rw_dtlipgto;
          
            IF cr_dtlipgto%FOUND THEN
              COBR0007.pc_inst_pedido_baixa_decurso(pr_cdcooper            => rw_crapcob.cdcooper
                                                   ,pr_nrdconta            => rw_crapcob.nrdconta
                                                   ,pr_nrcnvcob            => rw_crapcob.nrcnvcob
                                                   ,pr_nrdocmto            => rw_crapcob.nrdocmto
                                                   ,pr_cdocorre            => 2
                                                   ,pr_dtmvtolt            => pr_dtmvtolt
                                                   ,pr_cdoperad            => '1'
                                                   ,pr_nrremass            => 0
                                                   ,pr_tab_lat_consolidada => vr_tab_lat_consolidada
                                                   ,pr_cdcritic            => vr_cdcritic
                                                   ,pr_dscritic            => vr_dscritic);
              vr_cdcritic := NULL;
              vr_dscritic := NULL;
              PAGA0001.pc_efetua_lancto_tarifas_lat(pr_cdcooper            => rw_crapcob.cdcooper
                                                   ,pr_dtmvtolt            => pr_dtmvtolt
                                                   ,pr_tab_lat_consolidada => vr_tab_lat_consolidada
                                                   ,pr_cdcritic            => vr_cdcritic
                                                   ,pr_dscritic            => vr_dscritic);
              vr_cdcritic := NULL;
              vr_dscritic := NULL;
            
            ELSE
              OPEN cr_dtvencto(pr_rowid => pr_rowid);
              FETCH cr_dtvencto
                INTO rw_dtvencto;
              IF cr_dtvencto%FOUND THEN
                DDDA0001.pc_procedimentos_dda_jd(pr_rowid_cob       => pr_rowid
                                                ,pr_tpoperad        => 'A'
                                                ,pr_tpdbaixa        => ' '
                                                ,pr_dtvencto        => rw_dtvencto.dtvencto
                                                ,pr_vldescto        => rw_dtvencto.vldescto
                                                ,pr_vlabatim        => rw_dtvencto.vlabatim
                                                ,pr_flgdprot        => rw_dtvencto.flgdprot
                                                ,pr_tab_remessa_dda => vr_tab_remessa_dda
                                                ,pr_tab_retorno_dda => vr_tab_retorno_dda
                                                ,pr_cdcritic        => vr_cdcritic
                                                ,pr_dscritic        => vr_dscritic);
                vr_cdcritic := NULL;
                vr_dscritic := NULL;
              END IF;
              CLOSE cr_dtvencto;
            END IF;
            CLOSE cr_dtlipgto;
          
          EXCEPTION
            WHEN OTHERS THEN
              pc_internal_exception(PR_COMPLEME => '2 - instrucao dtlipgto serasa - crapcob.rowid = ' ||
                                                   pr_rowid);
          END;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao alterar CRAPCOB: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
    
      BEGIN
        INSERT INTO tbcobran_his_neg_serasa
          (cdcooper
          ,cdbandoc
          ,nrdctabb
          ,nrcnvcob
          ,nrdconta
          ,nrdocmto
          ,nrsequencia
          ,dhhistorico
          ,inserasa
          ,dtretser
          ,cdoperad)
        VALUES
          (rw_crapcob.cdcooper
          ,rw_crapcob.cdbandoc
          ,rw_crapcob.nrdctabb
          ,rw_crapcob.nrcnvcob
          ,rw_crapcob.nrdconta
          ,rw_crapcob.nrdocmto
          ,(SELECT nvl(MAX(nrsequencia), 0) + 1
             FROM tbcobran_his_neg_serasa
            WHERE cdcooper = rw_crapcob.cdcooper
              AND cdbandoc = rw_crapcob.cdbandoc
              AND nrdctabb = rw_crapcob.nrdctabb
              AND nrcnvcob = rw_crapcob.nrcnvcob
              AND nrdconta = rw_crapcob.nrdconta
              AND nrdocmto = rw_crapcob.nrdocmto)
          ,SYSDATE
          ,vr_inserasa
          ,vr_dtretser
          ,'1');
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na tbcobran_his_neg_serasa: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
    END IF;
  
    paga0001.pc_cria_log_cobranca(pr_idtabcob => pr_rowid
                                 ,pr_cdoperad => '1'
                                 ,pr_dtmvtolt => trunc(SYSDATE)
                                 ,pr_dsmensag => SUBSTR(vr_dslog, 1, 109)
                                 ,pr_des_erro => vr_des_erro
                                 ,pr_dscritic => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      raise_application_error(-20001, 'paga0001.pc_cria_log_cobranca:' || vr_dscritic);
    END IF;
  
    vr_tab_lcm.delete;
  
    IF vr_intipret = 2 THEN
    
      COBR0006.pc_prep_retorno_cooper_90(pr_idregcob => pr_rowid
                                        ,pr_cdocorre => 94
                                        ,pr_cdmotivo => 'S2'
                                        ,pr_vltarifa => 0
                                        ,pr_cdbcoctl => 0
                                        ,pr_cdagectl => 0
                                        ,pr_dtmvtolt => rw_crapcob.dtmvtolt
                                        ,pr_cdoperad => '1'
                                        ,pr_nrremass => 0
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
    
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      
        raise_application_error(-20001
                               ,'COBR0006.pc_prep_retorno_cooper_90:' || vr_cdcritic || '-' ||
                                vr_dscritic);
      END IF;
    
      PAGA0001.pc_prep_tt_lcm_consolidada(pr_idtabcob            => pr_rowid
                                         ,pr_cdocorre            => 94
                                         ,pr_tplancto            => 'T'
                                         ,pr_vltarifa            => 0
                                         ,pr_cdhistor            => 0
                                         ,pr_cdmotivo            => 'S2'
                                         ,pr_tab_lcm_consolidada => vr_tab_lcm
                                         ,pr_cdcritic            => vr_cdcritic
                                         ,pr_dscritic            => vr_dscritic);
    
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      
        raise_application_error(-20001
                               ,'PAGA0001.pc_prep_tt_lcm_consolidada:' || vr_cdcritic || '-' ||
                                vr_dscritic);
      END IF;
    END IF;
  
    IF vr_tab_lcm.exists(vr_tab_lcm.first) THEN
      PAGA0001.pc_realiza_lancto_cooperado(pr_cdcooper            => rw_crapcob.cdcooper
                                          ,pr_dtmvtolt            => rw_crapcob.dtmvtolt
                                          ,pr_cdagenci            => rw_crapcob.cdagenci
                                          ,pr_cdbccxlt            => rw_crapcob.cdbccxlt
                                          ,pr_nrdolote            => rw_crapcob.nrdolote
                                          ,pr_cdpesqbb            => rw_crapcob.nrconven
                                          ,pr_cdcritic            => vr_cdcritic
                                          ,pr_dscritic            => vr_dscritic
                                          ,pr_tab_lcm_consolidada => vr_tab_lcm);
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        raise_application_error(-20001
                               ,'PAGA0001.pc_realiza_lancto_cooperado:' || vr_cdcritic || '-' ||
                                vr_dscritic);
      END IF;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      SISTEMA.excecaoInterna(pr_compleme => 'INC0335693 atualizarExclusaoBoleto:(' || pr_rowid || ')');
      RAISE;
  END atualizarExclusaoBoleto;

BEGIN

  DECLARE
    rw_crapdat             btch0001.cr_crapdat%ROWTYPE;
    vr_qtboleto_processado NUMBER := 0;
  BEGIN
  
    OPEN btch0001.cr_crapdat(3);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
  
    FOR rw_boleto IN (SELECT cob.rowid idrowid_crapcob
                        FROM cecred.crapcob cob
                       WHERE (cob.cdcooper, cob.cdbandoc, cob.nrdctabb, cob.nrcnvcob, cob.nrdconta,
                              cob.nrdocmto) IN
                             ((6, 85, 105001, 105001, 249114, 8),
                             (2, 85, 102002, 102002, 633470, 3280))) LOOP
    
      atualizarExclusaoBoleto(pr_rowid    => rw_boleto.idrowid_crapcob
                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
    
      vr_qtboleto_processado := vr_qtboleto_processado + 1;
    
    END LOOP;
  
    IF vr_qtboleto_processado = 0 THEN
      raise_application_error(-20001, 'Nenhum boleto processado');
    END IF;
  
    COMMIT;
  
  END;

EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'INC0335693 Geral');
    ROLLBACK;
    RAISE;
END;
