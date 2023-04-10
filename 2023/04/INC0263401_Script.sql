DECLARE
  vr_dscritic VARCHAR2(1000);
BEGIN

  BEGIN
    DELETE FROM tbgen_batch_relatorio_wrk
     WHERE cdcooper = pr_cdcooper
       AND cdprograma = vr_cdprogra
       AND dsrelatorio IN ('CRAPLOT_CET', 'CTRL_ARQ', 'DADOS_ARQ')
       AND dtmvtolt = rw_crapdat.dtmvtolt;
  END;

  BEGIN
    UPDATE tbgen_batch_controle c
       SET insituacao = 2
     WHERE c.cdcooper = 3
       AND c.cdprogra = 'CRPS670'
       AND c.dtmvtolt >= '01/01/2023'
       AND c.nrexecucao = 1
       AND c.tpagrupador = 1
       AND c.insituacao = 1;
  END;

  BEGIN
    UPDATE crapscb
       SET nrseqarq = 2162
          ,dtultint = SYSDATE
     WHERE crapscb.tparquiv = 2;
  END;
  
  COMMIT;

  PC_BANCOOB_RECEBE_ARQUIVO_CEXT(pr_dscritic => vr_dscritic);
  
  IF vr_dscritic IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE(vr_dscritic);
  END IF;
  
  COMMIT;
  
END;
