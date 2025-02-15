-- 24/03/2017 - #551231 Padroniza��o do nome do job e inclus�o dos logs de controle de in�cio, erro e fim de execu��o (Carlos)
BEGIN
  sys.dbms_scheduler.drop_job(job_name => 'CECRED.EVENTOPROGRID$');

  sys.dbms_scheduler.create_job(
    job_name        => 'CECRED.jbpgd_email_evento',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'declare 
      vr_dscritic VARCHAR2(1000); 
      BEGIN
        PROGRID.PRGD0001.pc_envia_email_evento_local(pr_dscritic => vr_dscritic);
        
        IF vr_dscritic IS NOT NULL THEN
          raise_application_error(-20001, vr_dscritic);
        END IF;
      END;',
    start_date      => '24/03/2017 01:00:00,000000 AMERICA/SAO_PAULO',
    repeat_interval => 'Freq=DAILY;ByHour=01;ByMinute=00;BySecond=0',
    end_date        => to_date(null),
    job_class       => 'DEFAULT_JOB_CLASS',
    enabled         => TRUE,
    auto_drop       => TRUE,
    comments        => 'Rodar programa para envio de notifica��es de eventos locais. Roda diariamente as 01:00h');

END;
