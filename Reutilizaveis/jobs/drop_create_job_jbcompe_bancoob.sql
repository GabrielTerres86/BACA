-- 19/01/2017 #551192 Padronização dos nomes dos jobs, performance, 
--            inclusão de logs de controle de execução e controle de retorno de críticas (Carlos)
begin

  sys.dbms_scheduler.drop_job(job_name => 'CECRED.CRPS250_252$231989');
  
  sys.dbms_scheduler.create_job(
    job_name            => 'CECRED.jbcompe_bancoob',
    job_type            => 'PLSQL_BLOCK',
    job_action          => 'DECLARE vr_dscritic VARCHAR2(500);
    BEGIN
      cecred.PC_BANCOOB_CHEQUES_DEPOSITOS(pr_cdcooper => 3, pr_dscritic => vr_dscritic); 

      IF vr_dscritic IS NOT NULL THEN
        raise_application_error(-20001, vr_dscritic);
      END IF;
    END;',

    start_date          => '24/02/17 10:00:00,000000 AMERICA/SAO_PAULO',
    repeat_interval     => 'Freq=DAILY; ByHour=10;',
    end_date            => to_date(null),
    job_class           => 'DEFAULT_JOB_CLASS',
    enabled             => true,
    auto_drop           => true,
    comments            => 'Rodar o programa CRPS252 (integração deps. Rel 205)');
end;