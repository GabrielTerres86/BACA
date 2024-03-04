BEGIN
  UPDATE cecred.tbgen_batch_jobs a
     SET a.dtprox_execucao = a.dtprox_execucao - (30 / (60 * 24))
        ,a.dscodigo_plsql  = 
'DECLARE
  vr_dscritic VARCHAR2(4000);
BEGIN
  RECUPERACAO.gerarManutFincLancPenJob;

  RECUPERACAO.atualizarContratosCyberJob(pr_dscritic => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
    RETURN;
  END IF;

  CECRED.pc_gera_dados_cyber(pr_dscritic => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
    raise_application_error(-20001, vr_dscritic);
  END IF;
END;'
   WHERE a.nmjob = 'JBCYB_GERA_DADOS_CYBER'
     AND to_char(a.dtprox_execucao, 'HH24:MI') = '09:00';
     
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
