DECLARE

  CURSOR cr_job (pr_owner    VARCHAR2,
                 pr_job_name VARCHAR2) IS
   SELECT 1
     FROM all_scheduler_jobs j
    WHERE UPPER(j.owner) = UPPER(pr_owner)
      AND UPPER(j.job_name) = UPPER(pr_job_name);

  rw_job cr_job%ROWTYPE;
/*

    PROJETO 475 - Melhorias SPB - Sprint A
	Responsavel por verificar problemas no Envio/Recebimento de mensagens do SPB
	Gerar arquivo com os problemas encontrados para o Nagios apresentar

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


  -- JOB ANTIGO DEVER� SER EXCLU�DO
  OPEN cr_job (pr_owner    => 'CECRED', 
               pr_job_name => 'JBSPB_TRACE_NAGIOS');
  FETCH cr_job INTO rw_job;
  IF cr_job%FOUND THEN
  	sys.dbms_scheduler.drop_job(job_name => 'CECRED.JBSPB_TRACE_NAGIOS');  
  END IF;
  CLOSE cr_job;

  sys.dbms_scheduler.create_job(job_name          => 'CECRED.JBSPB_TRACE_NAGIOS',
                                job_type            => 'PLSQL_BLOCK',
                                job_action          => 'declare
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(1000);
  begin
    -- Call the procedure
    cecred.sspb0004.pc_verifica_fase_mensagem(pr_cdcritic => vr_cdcritic,
                                              pr_dscritic => vr_dscritic);
  END;',
                                start_date          => to_date('17-08-2018 00:00:00', 'dd-mm-yyyy hh24:mi:ss'),
                                repeat_interval     => 'Freq=Minutely;Interval=10;ByDay=Mon, Tue, Wed, Thu, Fri;ByHour=08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18',
                                end_date            => to_date(null),
                                job_class           => 'DEFAULT_JOB_CLASS',
                                enabled             => true,
                                auto_drop           => false,
                                comments            => 'Gerar os problemas de envio/recep��o de mensagens para o JD');
end;
