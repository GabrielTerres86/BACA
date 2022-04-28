DECLARE
  CURSOR cr_job(pr_owner    VARCHAR2
               ,pr_job_name VARCHAR2) IS
    SELECT j.job_name
      FROM all_scheduler_jobs j
     WHERE UPPER(j.owner) = UPPER(pr_owner)
       AND UPPER(j.job_name) = UPPER(pr_job_name);

  rw_job      cr_job%ROWTYPE;
  vr_owner    VARCHAR2(100) := 'RECUPERACAO';
  vr_job_name VARCHAR2(100) := 'JBRECUP_MANUT_FINANC_PEND';
BEGIN
  OPEN cr_job(pr_owner => vr_owner, pr_job_name => vr_job_name);
  FETCH cr_job
    INTO rw_job;
  IF cr_job%FOUND THEN
    sys.dbms_scheduler.drop_job(job_name => vr_owner || '.' || vr_job_name);
  END IF;
  CLOSE cr_job;

  UPDATE tbgen_batch_jobs a
     SET a.dtprox_execucao = a.dtprox_execucao - (30 / (60 * 24))
        ,a.dscodigo_plsql  = 
'DECLARE
  vr_dscritic VARCHAR2(4000);
BEGIN
  RECUPERACAO.gerarManutFincLancPenJob;
    
  CECRED.pc_gera_dados_cyber(pr_dscritic => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
    raise_application_error(-20001,vr_dscritic);
  END IF;
END;'
   WHERE a.nmjob = 'JBCYB_GERA_DADOS_CYBER'
     AND to_char(a.dtprox_execucao, 'HH24:MI') = '09:30';
     
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
/
