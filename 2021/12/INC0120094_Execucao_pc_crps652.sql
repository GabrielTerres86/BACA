DECLARE
  vr_dsplsql  VARCHAR2(2000);
  vr_cdcooper NUMBER := 3;
  vr_dthrexec TIMESTAMP;
  vr_jobnames VARCHAR2(200);
  vr_dscritic VARCHAR2(2000);
BEGIN
  vr_dthrexec := TO_TIMESTAMP_TZ(TO_CHAR((SYSDATE + (5 / 24 / 60)), 'DD/MM/RRRR HH24:MI:SS'), 'DD/MM/RRRR HH24:MI:SS TZR');
  vr_jobnames := 'JBCYB_EMERG_CYBER';
  vr_dsplsql  := 'DECLARE
                    vr_stprogra PLS_INTEGER;
                    vr_infimsol PLS_INTEGER;
                    vr_cdcritic crapcri.cdcritic%TYPE;
                    vr_dscritic crapcri.dscritic%TYPE;
                  BEGIN
                    pc_crps652(pr_cdcooper => 3,
                               pr_cdcoppar => 0,
                               pr_cdagepar => 0,
                               pr_idparale => 0,
                               pr_cdprogra => ''CRPS652'',
                               pr_qtdejobs => 10,
                               pr_stprogra => vr_stprogra,
                               pr_infimsol => vr_infimsol,
                               pr_cdcritic => vr_cdcritic,
                               pr_dscritic => vr_dscritic);
                  END;';

  cecred.GENE0001.pc_submit_job(pr_cdcooper => vr_cdcooper,
                                pr_cdprogra => 'CRPS652',
                                pr_dsplsql  => vr_dsplsql,
                                pr_dthrexe  => vr_dthrexec,
                                pr_interva  => NULL,
                                pr_jobname  => vr_jobnames,
                                pr_des_erro => vr_dscritic);
  IF vr_dscritic IS NOT NULL THEN
    raise_application_error(-20500, 'Erro ' || vr_dscritic);  
  END IF;
END;
