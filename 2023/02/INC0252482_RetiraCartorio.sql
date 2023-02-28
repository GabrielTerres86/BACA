DECLARE
  vr_dserro   VARCHAR2(100);
  vr_dscritic VARCHAR2(4000);
  vr_cdcritic NUMBER;
  vr_excerro EXCEPTION;

  vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
  vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;

  CURSOR cr_crapcob IS
  SELECT cob.rowid
        ,cob.dtvencto
        ,cob.vldescto
        ,cob.vlabatim
        ,cob.flgdprot
    FROM crapcob cob
   WHERE (cdcooper, nrdconta, nrcnvcob, nrdocmto) IN ((1, 9914307, 101002, 8227)) 
     AND cob.insitcrt = 3;

BEGIN

  FOR rw IN cr_crapcob LOOP
  
    UPDATE crapcob
       SET crapcob.insitcrt = 0
          ,crapcob.dtsitcrt = NULL
          ,crapcob.dtbloque = NULL
          ,crapcob.flgdprot = 0
          ,crapcob.qtdiaprt = 0
          ,crapcob.dtlipgto = ADD_MONTHS(crapcob.dtlipgto, -60)
     WHERE ROWID = rw.rowid;
  
    DDDA0001.pc_procedimentos_dda_jd(pr_rowid_cob       => rw.rowid
                                    ,pr_tpoperad        => 'B'
                                    ,pr_tpdbaixa        => '2'
                                    ,pr_dtvencto        => rw.dtvencto
                                    ,pr_vldescto        => rw.vldescto
                                    ,pr_vlabatim        => rw.vlabatim
                                    ,pr_flgdprot        => rw.flgdprot
                                    ,pr_tab_remessa_dda => vr_tab_remessa_dda
                                    ,pr_tab_retorno_dda => vr_tab_retorno_dda
                                    ,pr_cdcritic        => vr_cdcritic
                                    ,pr_dscritic        => vr_dscritic);
    IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_excerro;
    END IF;
  
    paga0001.pc_cria_log_cobranca(pr_idtabcob => rw.rowid
                                 ,pr_cdoperad => '1'
                                 ,pr_dtmvtolt => trunc(SYSDATE)
                                 ,pr_dsmensag => 'Protesto cancelado manualmente'
                                 ,pr_des_erro => vr_dserro
                                 ,pr_dscritic => vr_dscritic);
  
    COMMIT;
  
  END LOOP;

EXCEPTION
  WHEN vr_excerro THEN
    ROLLBACK;
    raise_application_error(-20500, vr_cdcritic || '-' || vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    SISTEMA.excecaoInterna(pr_cdcooper => 3);  
END;
