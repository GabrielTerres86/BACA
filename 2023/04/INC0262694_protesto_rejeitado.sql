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
     WHERE cob.cdcooper = 1
       AND (cob.nrdconta, cob.nrcnvcob, cob.nrdocmto) IN ((11303697,101004,927)
                                                         ,(11303697,101004,930))
       AND incobran = 0;

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
  
    paga0001.pc_cria_log_cobranca(pr_idtabcob => rw.rowid
                                 ,pr_cdoperad => '1'
                                 ,pr_dtmvtolt => trunc(SYSDATE)
                                 ,pr_dsmensag => 'Instr de protesto cancelada. Valor superior ao suportado.'
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
