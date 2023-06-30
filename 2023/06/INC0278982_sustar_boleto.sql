DECLARE
  CURSOR cr_boleto IS
    SELECT C.ROWID
          ,c.*
      FROM cecred.crapcob c
     WHERE c.cdcooper = 1
       AND c.nrdconta = 9649522
       AND c.nrdocmto = 100000608;
  rw_boleto cr_boleto%ROWTYPE;

  vr_tab_remessa_dda DDDA0001.typ_tab_remessa_dda;
  vr_tab_retorno_dda DDDA0001.typ_tab_retorno_dda;
  vr_cdcritic        crapcri.cdcritic%TYPE;
  vr_dscritic        VARCHAR2(4000);
  vr_erro EXCEPTION;
BEGIN

  OPEN cr_boleto;
  FETCH cr_boleto
    INTO rw_boleto;
  CLOSE cr_boleto;
  IF rw_boleto.cdcooper IS NOT NULL THEN
    UPDATE cecred.CRAPCOB
       SET crapcob.insitcrt = 4
          ,crapcob.dtsitcrt = TRUNC(SYSDATE)
          ,crapcob.dtbloque = NULL
          ,crapcob.dtlipgto = CASE
                                WHEN ADD_MONTHS(crapcob.dtlipgto, -60) > trunc(SYSDATE) THEN
                                 ADD_MONTHS(crapcob.dtlipgto, -60)
                                ELSE
                                 crapcob.dtlipgto
                              END
     WHERE crapcob.rowid = rw_boleto.rowid;
  
    DDDA0001.pc_procedimentos_dda_jd(pr_rowid_cob       => rw_boleto.rowid
                                    ,pr_tpoperad        => 'A'
                                    ,pr_tpdbaixa        => ''
                                    ,pr_dtvencto        => rw_boleto.dtvencto
                                    ,pr_vldescto        => rw_boleto.vldescto
                                    ,pr_vlabatim        => rw_boleto.vlabatim
                                    ,pr_flgdprot        => rw_boleto.flgdprot
                                    ,pr_tab_remessa_dda => vr_tab_remessa_dda
                                    ,pr_tab_retorno_dda => vr_tab_retorno_dda
                                    ,pr_cdcritic        => vr_cdcritic
                                    ,pr_dscritic        => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_erro;
    END IF;
  END IF;

  COMMIT;

EXCEPTION
  WHEN vr_erro THEN
    ROLLBACK;
    DBMS_OUTPUT.put_line('INC0278982 erro: ' || vr_dscritic);
    RAISE;
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'INC0278982');
    RAISE;  
END;
