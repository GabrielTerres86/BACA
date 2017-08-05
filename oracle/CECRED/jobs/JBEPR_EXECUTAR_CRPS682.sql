begin
  sys.dbms_scheduler.create_job(job_name            => 'CECRED.JBEPR_EXECUTAR_CRPS682',
                                job_type            => 'PLSQL_BLOCK',
                                job_action          => 'declare
 vr_cdcritic PLS_INTEGER;
 vr_dscritic VARCHAR2(4000);
begin
  empr0002.pc_executar_crps682(pr_cdcritic => vr_cdcritic,pr_dscritic => vr_dscritic);
end;',
                                start_date          => to_date('17-07-2017 20:00:00', 'dd-mm-yyyy hh24:mi:ss'),
                                repeat_interval     => 'Freq=DAILY;ByDay=SUN;ByHour=14;ByMinute=0;BySecond=0',								                       
                                end_date            => to_date(null),
                                job_class           => 'DEFAULT_JOB_CLASS',
                                enabled             => true,
                                auto_drop           => true,
                                comments            => '');
end;
/
