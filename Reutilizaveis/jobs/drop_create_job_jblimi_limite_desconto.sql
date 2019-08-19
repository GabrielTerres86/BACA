-- #551221 Job CRPS517$543434 renomeado para jblimi_crps517 (Carlos)
-- 07/04/2017 - Alterado o nome do job, de jblimi_crps517 para jbdsct_limite_desconto (Carlos)
BEGIN
  
  sys.dbms_scheduler.drop_job(job_name => 'CECRED.jblimi_crps517');

  sys.dbms_scheduler.create_job(
      job_name            => 'CECRED.jbdsct_limite_desconto',
      job_type            => 'PLSQL_BLOCK',
      job_action          => 'begin cecred.pc_crps517(pr_cdcooper => 3); end;',
      start_date          => '26/11/2015 18:00:00,000000 AMERICA/SAO_PAULO',
      repeat_interval     => 'Freq=DAILY;ByDay=MON,TUE,WED,THU,FRI;ByHour=18;ByMinute=0;BySecond=0',
      end_date            => to_date(null),
      job_class           => 'DEFAULT_JOB_CLASS',
      enabled             => TRUE,
      auto_drop           => TRUE,
      comments            => 'Controlar vigencia dos contratos de limite e o debito de titulos em desconto que atingiram a data de vencimento. 
                              Roda todo dia util as 18:00h.');
end;
