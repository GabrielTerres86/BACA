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

  sys.dbms_scheduler.drop_job(job_name => 'CECRED.RECIPR$'); 





  sys.dbms_scheduler.create_job(job_name            => 'CECRED.RECIPR$',
                                job_type            => 'PLSQL_BLOCK',
                                job_action          => 'DECLARE
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
	  vr_cdcritic PLS_INTEGER;
      vr_dscritic VARCHAR2(4000);

    BEGIN
      /* Buscar data atual */
      OPEN btch0001.cr_crapdat(3); /* Central */
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;
      /* Somente se o dia atual for util e igual ao calendario */
      IF TRUNC(SYSDATE) = rw_crapdat.dtmvtolt AND rw_crapdat.inproces = 1 THEN
        --cecred.rcip0001.pc_remove_recipro_sem_uso;
        cecred.rcip0001.pc_expira_reciproci_prevista(pr_cdcritic => vr_cdcritic,pr_dscritic => vr_dscritic);
      END IF;
	  
	  IF vr_dscritic IS NOT NULL THEN
    -- Levantar exceçao
		RAISE_application_error(-20500,''Erro: ''||vr_dscritic);
      END IF;

	  
    END;',
                                start_date          => to_date('15-02-2019 08:00:00', 'dd-mm-yyyy hh24:mi:ss'),
                                repeat_interval     => 'Freq=daily;ByHour=08,11,14',
                                end_date            => to_date(null),
                                job_class           => 'DEFAULT_JOB_CLASS',
                                enabled             => false,
                                auto_drop           => true,
                                comments            => '');
end;
/
