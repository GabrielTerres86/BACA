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
                    nls_time_tz_format = ''HH.MI.SSXFF AM TZR'' nls_timestamp_format = ''DD-MON-RR HH.MI.SSXFF AM'' nls_timestamp_tz_format = ''DD-MON-RR HH.MI.SSXFF AM TZR''';

  BEGIN
    sys.dbms_scheduler.drop_job(job_name => 'CREDITO.JBCRE_INATIVAR_USUARIOS_CDC');
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  sys.dbms_scheduler.create_job(job_name        => 'CREDITO.JBCRE_INATIVAR_USUARIOS_CDC',
                                job_type        => 'PLSQL_BLOCK',
                                job_action      => 'BEGIN' || chr(13) ||
                                                   '  CREDITO.inativarUsuarioCDCSemAcesso;' ||
                                                   chr(13) || 'END;',
                                start_date      => to_date('10/05/2021 08:00:00',
                                                           'dd/mm/yyyy hh24:mi:ss'),
                                repeat_interval => 'Freq=DAILY;ByDay=MON,TUE,WED,THU,FRI;ByHour=08,00;ByMinute=00;BySecond=0',
                                end_date        => to_date(NULL),
                                job_class       => 'DEFAULT_JOB_CLASS',
                                enabled         => TRUE,
                                auto_drop       => TRUE,
                                comments        => 'Inativação de usuários de convênio CDC sem acesso há mais de 60 dias.');
END;
/