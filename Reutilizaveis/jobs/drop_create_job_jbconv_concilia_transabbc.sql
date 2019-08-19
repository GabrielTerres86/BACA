/*
#551216 Job CONTAB_TRANSABBC_$231966 renomeado para jbconv_concilia_transabbc e frequência de seg-sex (Carlos)
*/
BEGIN
  
  sys.dbms_scheduler.drop_job(job_name => 'CECRED.CONTAB_TRANSABBC_$231966');
  
  sys.dbms_scheduler.create_job(job_name            => 'CECRED.jbconv_concilia_transabbc',
                                job_type            => 'PLSQL_BLOCK',
                                job_action          => 'begin conv0001.pc_busca_concilia_transabbc; end;',
                                start_date          => '26/11/2015 18:00:00,000000 AMERICA/SAO_PAULO',
                                repeat_interval     => 'Freq=HOURLY;Interval=12;ByDay=MON,TUE,WED,THU,FRI',
                                end_date            => to_date(null),
                                job_class           => 'DEFAULT_JOB_CLASS',
                                enabled             => TRUE,
                                auto_drop           => TRUE,
                                comments            => 'Conectar-se ao FTP da Transabbc e efetuar download de três arquivos diariamente.');
end;
