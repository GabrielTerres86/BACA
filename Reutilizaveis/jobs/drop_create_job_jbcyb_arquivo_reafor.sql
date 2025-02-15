/*
#551213 Job CYBER_REAFOR_$68960 renomeado para jbcyb_arquivo_reafor.
*/
begin

  sys.dbms_scheduler.drop_job(job_name => 'CECRED.CYBER_REAFOR_$68960');

  sys.dbms_scheduler.create_job(
    job_name            => 'CECRED.jbcyb_arquivo_reafor',
    job_type            => 'PLSQL_BLOCK',
    job_action          => 
'begin
  cybe0002.pc_grava_arquivo_reafor(pr_cdcooper=>3);
end;',
    start_date          => '11/03/2015 18:00:00,000000 AMERICA/SAO_PAULO',
    repeat_interval     => 'Freq=Daily;Interval=1;ByHour=18',
    end_date            => to_date(null),
    job_class           => 'DEFAULT_JOB_CLASS',
    enabled             => true,
    auto_drop           => true,
    comments            => 'Geracao do arquivo da Reabilita��o For�ada');
end;
