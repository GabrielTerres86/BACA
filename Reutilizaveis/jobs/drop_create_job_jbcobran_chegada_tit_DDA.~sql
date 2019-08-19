-- #551192 Melhorias de performance e inclusão de logs de controle de execução (Carlos)
-- 27/03/2017 - Job renomeado para jbcobran_chegada_tit_DDA (Carlos)
begin

  sys.dbms_scheduler.drop_job(job_name => 'CECRED.jcobran_crps612');

  sys.dbms_scheduler.create_job(
    job_name            => 'CECRED.jbcobran_chegada_tit_DDA',
    job_type            => 'PLSQL_BLOCK',
    job_action          => 'DECLARE
      pr_dscritic VARCHAR2(500);
    BEGIN
      cecred.pc_crps612(pr_dscritic => pr_dscritic);

      IF pr_dscritic IS NOT NULL THEN
        raise_application_error(-20001, pr_dscritic);
      END IF;
    END;',
    
    start_date          => '12/01/17 20:00:00,000000 AMERICA/SAO_PAULO',
    repeat_interval     => 'Freq=DAILY; ByHour=20;',
    end_date            => to_date(null),
    job_class           => 'DEFAULT_JOB_CLASS',
    enabled             => true,
    auto_drop           => true,
    comments            => 'Rodar programa CRPS612 - Buscar titulos gerados no DDA diariamente e gerar mensagem de chegada');
end;
