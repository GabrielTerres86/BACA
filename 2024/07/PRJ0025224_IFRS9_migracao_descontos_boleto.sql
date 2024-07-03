DECLARE

  CURSOR cr_crapcop IS
    SELECT t.cdcooper
      FROM crapcop t
     WHERE t.flgativo = 1;

  CURSOR cr_datafim IS
    SELECT MAX(TRUNC(t.dtlipgto,'MM'))
      FROM cecred.crapcob t
     WHERE t.vldescto > 0;
  
  CURSOR cr_job_exec(pr_job_name IN VARCHAR2) IS
    SELECT COUNT(*) qtde
      FROM dba_scheduler_jobs job
     WHERE job.owner    = 'CECRED'
       AND job.job_name LIKE pr_job_name||'%';
  
  vr_qtlimjob  CONSTANT NUMBER := 20;
  vr_jobname   VARCHAR2(100);
  vr_sql       VARCHAR(1000) := '';
  vr_dscritic  VARCHAR2(4000);
   
  vr_dtiniper  DATE;
  vr_dtfimper  DATE;
  vr_dtproces  DATE;
  vr_qtjobexc  NUMBER;

BEGIN

  vr_dtiniper := ADD_MONTHS(TRUNC(SYSDATE,'MM'),-60);

  OPEN  cr_datafim;
  FETCH cr_datafim INTO vr_dtfimper;
  CLOSE cr_datafim;

  FOR coop IN cr_crapcop LOOP
    FOR ind IN 0..months_between(vr_dtfimper,vr_dtiniper) LOOP

      vr_dtproces := ADD_MONTHS(vr_dtiniper,ind);
      vr_jobname  := 'JBCOBR_DT_'||TRIM(to_char(coop.cdcooper,'00'))||'_'||to_char(vr_dtproces,'MMYY')||'$';

      LOOP
        vr_qtjobexc := 0;
        
        OPEN  cr_job_exec('JBCOBR_DT_');
        FETCH cr_job_exec INTO vr_qtjobexc;
        CLOSE cr_job_exec;
        
        IF NVL(vr_qtjobexc,0) >= vr_qtlimjob THEN
          DBMS_LOCK.SLEEP(seconds => 1);
          CONTINUE;
        ELSE
          EXIT;
        END IF;
        
      END LOOP;

      vr_sql := 'BEGIN
                   COBRANCA.criarRegistroDesconto(pr_cdcooper => '||coop.cdcooper||'
                                                 ,pr_dtmesano => to_date('''||to_char(vr_dtproces,'mm/yyyy')||''',''mm/yyyy''));
                 END;';

      gene0001.pc_submit_job(pr_cdcooper => coop.cdcooper
                            ,pr_cdprogra => 'SCRIPT'
                            ,pr_dsplsql  => vr_sql
                            ,pr_jobname  => vr_jobname
                            ,pr_des_erro => vr_dscritic);

      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'Erro ao criar job '||vr_jobname||': '||vr_dscritic);
      END IF;

    END LOOP;
  END LOOP;

END;
