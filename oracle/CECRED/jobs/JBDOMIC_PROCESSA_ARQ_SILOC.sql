begin
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_calendar = ''GREGORIAN''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_comp = ''BINARY''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_date_format = ''DD-MON-RR''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_date_language = ''AMERICAN''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_iso_currency = ''AMERICA''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_language = ''AMERICAN''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_length_semantics = ''BYTE''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_nchar_conv_excp = ''FALSE''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_numeric_characters = ''.,''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_sort = ''BINARY''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_territory = ''AMERICA''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_time_format = ''HH.MI.SSXFF AM''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_time_tz_format = ''HH.MI.SSXFF AM TZR''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_timestamp_format = ''DD-MON-RR HH.MI.SSXFF AM''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_timestamp_tz_format = ''DD-MON-RR HH.MI.SSXFF AM TZR'''; 
 
  sys.dbms_scheduler.create_job(job_name            => 'CECRED.JBDOMIC_PROCESSA_ARQ_SILOC',
                                job_type            => 'PLSQL_BLOCK',
                                job_action          => 'declare 
  vr_dscritic varchar(2000);
  vr_cdcritic number;
  vr_dtprocessoexec date := to_date(null);
begin
  cecred.ccrd0006.pc_executa_processo(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic, pr_dtprocessoexec => vr_dtprocessoexec);
end;',
                                start_date          => to_date('01-09-2017 12:00:00', 'dd-mm-yyyy hh24:mi:ss'),
                                repeat_interval     => 'Freq=MINUTELY;Interval=30;ByDay=MON, TUE, WED, THU, FRI',
                                end_date            => to_date(null),
                                job_class           => 'DEFAULT_JOB_CLASS',
                                enabled             => true,
                                auto_drop           => true,
                                comments            => '');
end;
