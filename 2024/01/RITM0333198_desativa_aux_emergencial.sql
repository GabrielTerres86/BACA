BEGIN
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
                      
    sys.dbms_scheduler.drop_job(job_name => 'CECRED.JBCC_EMITE_AUX_EMERGENCIAL');
END;
/
