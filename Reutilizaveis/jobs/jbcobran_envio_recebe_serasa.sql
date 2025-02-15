/*
30/03/2017 - #551229 Job ENVIO_SERASA exclu�do para a cria��o dos jobs JBCOBRAN_ENVIO_SERASA e JBCOBRAN_RECEBE_SERASA.
             Log de in�cio, fim e erros na execu��o dos jobs. (Carlos) 
*/
BEGIN

  sys.dbms_scheduler.drop_job(job_name => 'CECRED.ENVIO_SERASA');

  -- Create 
  sys.dbms_scheduler.create_job(
    job_name            => 'CECRED.JBCOBRAN_ENVIO_SERASA',
    job_type            => 'PLSQL_BLOCK',
    job_action          => 'DECLARE
    ww_dscritic VARCHAR2(500);
    ww_cdcritic crapcri.cdcritic%TYPE;
    BEGIN
      PC_CRPS330(ww_cdcritic, ww_dscritic);
      
      IF ww_dscritic IS NOT NULL THEN
        raise_application_error(-20001,ww_dscritic);
      END IF;
    END;',
    start_date          => '30/03/2017 18:00:00,000000 AMERICA/SAO_PAULO',
    repeat_interval     => 'Freq=Daily;Interval=1;ByHour=18;ByDay=MON,TUE,WED,THU,FRI',
    end_date            => to_date(null),
    job_class           => 'DEFAULT_JOB_CLASS',
    enabled             => true,
    auto_drop           => true,
    comments            => 'Envio de negativa��es para o SERASA');

  -- Create
  sys.dbms_scheduler.create_job(
    job_name            => 'CECRED.JBCOBRAN_RECEBE_SERASA',
    job_type            => 'PLSQL_BLOCK',
    job_action          => 'DECLARE
    ww_dscritic VARCHAR2(500);
    ww_cdcritic crapcri.cdcritic%TYPE;
    BEGIN
      PC_CRPS331(ww_cdcritic, ww_dscritic);

      IF ww_dscritic IS NOT NULL THEN
        raise_application_error(-20002,ww_dscritic);
      END IF;
    END;',
    start_date          => '30/03/2017 18:15:00,000000 AMERICA/SAO_PAULO',
    repeat_interval     => 'Freq=Daily;Interval=1;ByHour=18;ByMinute=15',
    end_date            => to_date(null),
    job_class           => 'DEFAULT_JOB_CLASS',
    enabled             => true,
    auto_drop           => true,
    comments            => 'Recebimento de negativa��es do SERASA');
END;
