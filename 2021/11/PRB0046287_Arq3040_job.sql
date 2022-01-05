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

  BEGIN
    sys.dbms_scheduler.drop_job(job_name => 'CREDITO.JBEPR_UPDATE_STATUS_CONTRATO');
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  sys.dbms_scheduler.create_job(job_name        => 'CREDITO.JBEPR_UPDATE_STATUS_CONTRATO',
                                job_type        => 'PLSQL_BLOCK',
                                job_action      => 'DECLARE
                                                    BEGIN
														
														UPDATE crapepr pr
														   SET inliquid = 1, vlsdeved = 0
														 WHERE pr.tpemprst = 1
														   AND pr.tpdescto = 2
														   AND pr.inliquid = 0
														   AND NOT EXISTS (SELECT 1 FROM crappep p
														                    WHERE p.cdcooper = pr.cdcooper
														                      AND p.nrdconta = pr.nrdconta
														                      AND p.nrctremp = pr.nrctremp
														                      AND p.inliquid = 0);
														COMMIT;

													EXCEPTION
														WHEN OTHERS THEN
														ROLLBACK;

													END;',
                                start_date      => SYSDATE,
                                repeat_interval => 'FREQ=DAILY;BYHOUR=19',
                                end_date        => to_date(NULL),
                                job_class       => 'DEFAULT_JOB_CLASS',
                                enabled         => TRUE,
                                auto_drop       => FALSE,
                                comments        => '');
END;
/