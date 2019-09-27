/*
07/2019 - Consignado envia arquivo conveniada - Jackson Barcellos - AMcom
*/
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

	--sys.dbms_scheduler.drop_job(job_name => 'CECRED.JBCRED_CONSIG_ENV_ARQ_CONV');
   
  sys.dbms_scheduler.create_job(
    job_name        => 'CECRED.JBCRED_CONSIG_ENV_ARQ_CONV',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 
'
DECLARE
BEGIN
 CECRED.EMPR0020.pc_env_arq_conveniada_job;  
EXCEPTION WHEN OTHERS THEN
  RAISE_application_error(-20500,''Erro no Job EMPR0020.pc_env_arq_conveniada_job'');
END;',
    start_date      => TO_TIMESTAMP_TZ(to_date('03/07/2019' ,'DD/MM/RRRR')||' 07:00 America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR'),
    repeat_interval => 'Freq=DAILY;ByDay=Mon,Tue,Wed,Thu,Fri;BYHOUR=08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20;BYMINUTE=05;BYSECOND=0',
    end_date        => to_date(null),
    job_class       => 'DEFAULT_JOB_CLASS',
    enabled         => TRUE,
    auto_drop       => TRUE,
    comments        => 'Rodar rotina do consignado de envio de arquivo via email para conveniada.'
                      );

END;
/
