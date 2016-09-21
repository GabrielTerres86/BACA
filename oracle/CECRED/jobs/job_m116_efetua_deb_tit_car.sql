begin
  sys.dbms_scheduler.create_job(job_name            => 'CECRED.EFETUA_DEBITO_TIT_CAR',
                                job_type            => 'PLSQL_BLOCK',
                                job_action          => 'BEGIN DSCT0001.pc_efetua_baixa_tit_car_job; END;',
                                start_date          => to_date('17-02-2016 11:30:00', 'dd-mm-yyyy hh24:mi:ss'),
                                repeat_interval     => 'Freq=daily;ByHour=11,17;ByMinute=30;BySecond=0',
                                end_date            => to_date(null),
                                job_class           => 'DEFAULT_JOB_CLASS',
                                enabled             => true,
                                auto_drop           => true,
                                comments            => '');
end;
/
