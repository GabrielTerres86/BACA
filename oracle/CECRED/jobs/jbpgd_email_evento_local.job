-- 14/06/2017 - #551231 Padronização do nome do job e inclusão dos logs de controle de início, erro e fim de execução (Carlos)
-- 05/09/2017 - #551231 Alterado o owner do job para PROGRID (Carlos)
BEGIN

  sys.dbms_scheduler.drop_job(job_name => 'CECRED.EVENTOPROGRID$');
    
  sys.dbms_scheduler.create_job(
    job_name        => 'PROGRID.jbpgd_email_evento_local',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'declare 
      vr_dscritic VARCHAR2(1000); 
      BEGIN
        PROGRID.PRGD0001.pc_envia_email_evento_local(pr_dscritic => vr_dscritic);
        
        IF vr_dscritic IS NOT NULL THEN
          raise_application_error(-20001, vr_dscritic);
        END IF;
      END;',
    start_date      => '19/09/2017 01:00:00,000000 AMERICA/SAO_PAULO',
    repeat_interval => 'Freq=DAILY;ByHour=01;ByDay=MON,TUE,WED,THU,FRI',
    end_date        => to_date(null),
    job_class       => 'DEFAULT_JOB_CLASS',
    enabled         => TRUE,
    auto_drop       => TRUE,
    comments        => 'Rodar programa para envio de notificações de eventos locais. Roda diariamente as 01:00h');

END;
