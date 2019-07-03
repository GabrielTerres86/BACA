/*
07/2019 - Consignado envia arquivo conveniada - Jackson Barcellos - AMcom
*/
BEGIN
   
  sys.dbms_scheduler.create_job(
    job_name        => 'CECRED.JBCRD_CONSIG_ENV_ARQ_CONV',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 
'
DECLARE
BEGIN
 CECRED.EMPR0020.pc_env_arq_conveniada_job;  
END;',
    start_date      => TO_TIMESTAMP_TZ(to_date('03/07/2019' ,'DD/MM/RRRR')||' 07:00 America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR'),
    repeat_interval => 'Freq=DAILY;ByDay=Mon,Tue,Wed,Thu,Fri;BYHOUR=08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20;BYMINUTE=05;BYSECOND=0',
    end_date        => to_date(null),
    job_class       => 'DEFAULT_JOB_CLASS',
    enabled         => TRUE,
    auto_drop       => TRUE,
    comments        => 'Rodar rotina do consignado de envio de arquivo via email para conveniada.'
                      );

END;
/*
BEGIN  
  dbms_scheduler.drop_job(job_name => 'CECRED.JBCRD_CONSIG_ENV_ARQ_CONV');
END;  

select * from DBA_SCHEDULER_JOBS where job_name = 'JBCRD_CONSIG_ENV_ARQ_CONV';

select * from DBA_SCHEDULER_JOB_LOG where job_name = 'JBCRD_CONSIG_ENV_ARQ_CONV';
*/