-- #551199 Melhorias e padronizações do job e crps778
-- 27/03/2017 - Alterado o nome do job para jbcobran_integracao_ftp (Carlos)
begin

  sys.dbms_scheduler.drop_job(job_name => 'CECRED.jbcobran_crps778');

  sys.dbms_scheduler.create_job(
    job_name            => 'CECRED.jbcobran_integracao_ftp',
    job_type            => 'PLSQL_BLOCK',
    job_action          => 'DECLARE
      pr_dscritic VARCHAR2(500);
    BEGIN
      -- Call the procedure
      cecred.pc_crps778(pr_dscritic => pr_dscritic);

      -- Tratamento de crítica
      IF pr_dscritic IS NOT NULL THEN
        raise_application_error(-20001, pr_dscritic);
      END IF;

    END;',

    start_date          => '11/01/17 08:00:00,000000 AMERICA/SAO_PAULO',
    repeat_interval     => 'Freq=DAILY; Interval=1; BYDAY=MON,TUE,WED,THU,FRI; BYHOUR=8,9,10,11,12,13,14,15,16,17,18,19',
    end_date            => to_date(null),
    job_class           => 'DEFAULT_JOB_CLASS',
    enabled             => true,
    auto_drop           => true,
    comments            => 'Rodar programa CRPS778 - Responsavel por efetuar a geracao de boletos de cobranca via CNAB');
end;
