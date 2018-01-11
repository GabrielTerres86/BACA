PL/SQL Developer Test script 3.0
12
begin
  sys.dbms_scheduler.create_job(job_name            => 'CECRED.JBCONAUT_CONTIGENCIA',
                                job_type            => 'PLSQL_BLOCK',
                                job_action          => 'BEGIN SSPC0001.pc_job_conaut_contigencia; END;',
                                start_date          => TO_TIMESTAMP_TZ(to_char(SYSDATE+1,'DD/MM/RRRR')||' 08:00 America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR'),
                                repeat_interval     => 'Freq=minutely;ByDay=Mon, Tue, Wed, Thu, Fri;ByHour=8,9,10,11,12,13,14,15,16,17;BySecond=0;Interval=5',
                                end_date            => to_date(null),
                                job_class           => 'DEFAULT_JOB_CLASS',
                                enabled             => true,
                                auto_drop           => true,
                                comments            => 'Rotina para avisar que a consulta automatizada esta em contigencia');                                
end;
0
0
