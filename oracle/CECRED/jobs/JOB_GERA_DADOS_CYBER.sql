begin
  sys.dbms_scheduler.create_job(job_name            => 'CECRED.JBCYB_GERA_DADOS_CYBER',
                                job_type            => 'PLSQL_BLOCK',
                                job_action          => 'BEGIN pc_gera_dados_cyber; END;',
                                start_date          => TIMESTAMP '2017-04-10 08:00:00 -3:00',
                                repeat_interval     => 'Freq=daily;ByHour=8;ByMinute=0;BySecond=0',
                                end_date            => to_date(null),
                                job_class           => 'DEFAULT_JOB_CLASS',
                                enabled             => true,
                                auto_drop           => true,
                                comments            => '');
end;
/
