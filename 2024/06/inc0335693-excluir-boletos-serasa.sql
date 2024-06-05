DECLARE

  PROCEDURE atualizarExclusaoBoleto(pr_rowid IN ROWID) IS
  
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
  
    vr_intipret PLS_INTEGER;
    vr_inserasa crapcob.inserasa%TYPE;
    vr_dtretser DATE; 
    vr_dslog    VARCHAR2(500);
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);
    vr_des_erro VARCHAR2(10);
    vr_tab_lcm  PAGA0001.typ_tab_lcm_consolidada;
  
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
    vr_qtboleto_processado NUMBER := 0;
  BEGIN
  
    FOR rw_boleto IN (SELECT cob.rowid idrowid_crapcob
                        FROM cecred.crapcob cob
                       WHERE (cob.cdcooper, cob.cdbandoc, cob.nrdctabb, cob.nrcnvcob, cob.nrdconta,
                              cob.nrdocmto) IN
                             ((1, 85, 101002, 101002, 10558314, 5494)
                             ,(1, 85, 101002, 101002, 11856700, 55)
                             ,(1, 85, 101002, 101002, 11856700, 56)
                             ,(1, 85, 101002, 101002, 11856700, 57)
                             ,(1, 85, 101002, 101002, 8004102, 8578)
                             ,(1, 85, 101002, 101002, 8004102, 8579)
                             ,(1, 85, 101002, 101002, 15285189, 825))) LOOP
    
      atualizarExclusaoBoleto(pr_rowid => rw_boleto.idrowid_crapcob);
    
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
