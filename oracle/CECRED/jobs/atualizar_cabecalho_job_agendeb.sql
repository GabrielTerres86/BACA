
/*

  Ajustar o job para evitar o problema de horário de verão.

*/
begin
  EXECUTE IMMEDIATE 'ALTER SESSION SET      
    nls_calendar = ''GREGORIAN''     
  nls_comp = ''BINARY''     
    nls_date_format = ''DD-MON-RR''    
  nls_date_language = ''AMERICAN''     
  nls_iso_currency = ''AMERICA''     
  nls_language = ''AMERICAN''     
  nls_length_semantics = ''BYTE''     
  nls_nchar_conv_excp = ''FALSE''     
  nls_numeric_characters = ''.,''     
  nls_sort = ''BINARY''     
  nls_territory = ''AMERICA''     
  nls_time_format = ''HH.MI.SSXFF AM''     
  nls_time_tz_format = ''HH.MI.SSXFF AM TZR''     
  nls_timestamp_format = ''DD-MON-RR HH.MI.SSXFF AM''     
  nls_timestamp_tz_format = ''DD-MON-RR HH.MI.SSXFF AM TZR'''; 

  sys.dbms_scheduler.drop_job(job_name => 'CECRED.jbcompe_agendamento_ted');  

    sys.dbms_scheduler.create_job(job_name          => 'CECRED.jbcompe_agendamento_ted',
                                job_type            => 'PLSQL_BLOCK',
                                job_action          => 'begin cecred.PC_JOB_AGENDEBTED(pr_cdcooper => 3, pr_cdprogra => NULL, pr_dsjobnam => null); end;',
                                start_date          => to_date('25-10/2016 00:00:00', 'dd-mm-yyyy hh24:mi:ss'),
                                repeat_interval     => 'Freq=daily;ByDay=MON, TUE, WED, THU, FRI;ByHour=08;ByMinute=25;BySecond=0',
                                end_date            => to_date(null),
                                job_class           => 'DEFAULT_JOB_CLASS',
                                enabled             => true,
                                auto_drop           => true,
                                comments            => 'Efetuar o debito de agendamento de TED.');
end;

