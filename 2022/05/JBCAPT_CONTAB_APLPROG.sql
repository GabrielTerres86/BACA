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

  sys.dbms_scheduler.create_job(job_name        => 'CECRED.JBCAPT_CONTAB_APLPROG'
                               ,job_type        => 'PLSQL_BLOCK'
                               ,job_action      => 'DECLARE ' || CHR(10)
                                                ||  '   vr_cdcritic crapcri.cdcritic%TYPE; ' || CHR(10)
                                                ||  '   vr_dscritic crapcri.dscritic%TYPE; ' || CHR(10)
                                                || 'BEGIN ' || CHR(10)
                                                || '  CECRED.pc_job_contab_aplprog(3,''JBCAPT_CONTAB_APLPROG_3'', vr_cdcritic, vr_dscritic); ' || CHR(10)
                                                || '  IF vr_dscritic IS NOT NULL THEN ' || CHR(10)
                                                || '    RAISE_application_error(-20500,''Erro: ''||vr_dscritic); ' || CHR(10)
                                                || '  END IF;' || CHR(10)
                                                || 'END; '
                               ,start_date      => TO_TIMESTAMP_TZ(to_char('01/06/2022','DD/MM/RRRR')||' 07:00 America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR')                               
                               ,repeat_interval => 'Freq=Monthly;ByDay=MON, TUE, WED, THU, FRI;ByHour=07;ByMinute=00;BySecond=0;BySetpos=1'
                               ,end_date        => to_date(NULL)
                               ,job_class       => 'DEFAULT_JOB_CLASS'
                               ,enabled         => TRUE
                               ,auto_drop       => TRUE
                               ,comments        => 'Rodar programa CECRED.pc_job_contab_aplprog - Responsavel por '||
                                                   'gerar os relatorios de contabilizacao da aplicação programada.');

  COMMIT;
END;
