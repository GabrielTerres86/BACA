PL/SQL Developer Test script 3.0
98
/* ritm0093428 Criação de jobs para apagar os registros de 04/2018 a 05/2020 da tabela tbgen_batch_relatorio_wrk, utilizada para os relatórios de programas que rodam em paralelo. 
Total de registros a serem excluídos: 74.969.546 (Carlos) */
declare  
  intervalo number := 0;--tempo em minutos para o próximo job
  
  PROCEDURE pc_cria_job (pr_comando varchar2, pr_intervalo number) IS
  BEGIN
    sys.dbms_scheduler.create_job(job_name   => dbms_scheduler.generate_job_name('JBDEL_REL_WRK'),
                                  job_type   => 'PLSQL_BLOCK',
                                  job_action => 'begin ' || pr_comando ||
                                 ' commit;
                                   exception when others then cecred.pc_internal_exception;
                                  end;',
                                  start_date => sysdate + (intervalo/24/60),
                                  job_class => 'DEFAULT_JOB_CLASS', enabled => true, auto_drop => true);
    intervalo := intervalo + pr_intervalo;
  END pc_cria_job;
  
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

--CRPS280 viacredi 28121128
  pc_cria_job('delete tbgen_batch_relatorio_wrk WHERE cdprograma = ''CRPS280'' and dtmvtolt between 
               to_date(''01/04/2018'',''dd/mm/rrrr'') and to_date(''30/06/2018'',''dd/mm/rrrr'') AND cdcooper = 1;',3);
  pc_cria_job('delete tbgen_batch_relatorio_wrk WHERE cdprograma = ''CRPS280'' and dtmvtolt between 
               to_date(''01/07/2018'',''dd/mm/rrrr'') and to_date(''30/09/2018'',''dd/mm/rrrr'') AND cdcooper = 1;',3);
  pc_cria_job('delete tbgen_batch_relatorio_wrk WHERE cdprograma = ''CRPS280'' and dtmvtolt between 
               to_date(''01/10/2018'',''dd/mm/rrrr'') and to_date(''31/12/2018'',''dd/mm/rrrr'') AND cdcooper = 1;',3);    
  pc_cria_job('delete tbgen_batch_relatorio_wrk WHERE cdprograma = ''CRPS280'' and dtmvtolt between 
               to_date(''01/01/2019'',''dd/mm/rrrr'') and to_date(''31/03/2019'',''dd/mm/rrrr'') AND cdcooper = 1;',3);
  pc_cria_job('delete tbgen_batch_relatorio_wrk WHERE cdprograma = ''CRPS280'' and dtmvtolt between 
               to_date(''01/04/2019'',''dd/mm/rrrr'') and to_date(''30/06/2019'',''dd/mm/rrrr'') AND cdcooper = 1;',3);
  pc_cria_job('delete tbgen_batch_relatorio_wrk WHERE cdprograma = ''CRPS280'' and dtmvtolt between 
               to_date(''01/07/2019'',''dd/mm/rrrr'') and to_date(''30/09/2019'',''dd/mm/rrrr'') AND cdcooper = 1;',3);
  pc_cria_job('delete tbgen_batch_relatorio_wrk WHERE cdprograma = ''CRPS280'' and dtmvtolt between 
               to_date(''01/10/2019'',''dd/mm/rrrr'') and to_date(''31/12/2019'',''dd/mm/rrrr'') AND cdcooper = 1;',3);  
  pc_cria_job('delete tbgen_batch_relatorio_wrk WHERE cdprograma = ''CRPS280'' and dtmvtolt between 
               to_date(''01/01/2020'',''dd/mm/rrrr'') and to_date(''31/03/2020'',''dd/mm/rrrr'') AND cdcooper = 1;',3);
  pc_cria_job('delete tbgen_batch_relatorio_wrk WHERE cdprograma = ''CRPS280'' and dtmvtolt between 
               to_date(''01/04/2020'',''dd/mm/rrrr'') and to_date(''31/05/2020'',''dd/mm/rrrr'') AND cdcooper = 1;',3);

--CRPS652 ailos 31592823
  pc_cria_job('delete tbgen_batch_relatorio_wrk WHERE cdprograma = ''CRPS652'' and dtmvtolt between 
               to_date(''01/04/2018'',''dd/mm/rrrr'') and to_date(''30/06/2018'',''dd/mm/rrrr'') AND cdcooper = 3;',3);
  pc_cria_job('delete tbgen_batch_relatorio_wrk WHERE cdprograma = ''CRPS652'' and dtmvtolt between 
               to_date(''01/07/2018'',''dd/mm/rrrr'') and to_date(''30/09/2018'',''dd/mm/rrrr'') AND cdcooper = 3;',3);
  pc_cria_job('delete tbgen_batch_relatorio_wrk WHERE cdprograma = ''CRPS652'' and dtmvtolt between 
               to_date(''01/10/2018'',''dd/mm/rrrr'') and to_date(''31/12/2018'',''dd/mm/rrrr'') AND cdcooper = 3;',3);
  pc_cria_job('delete tbgen_batch_relatorio_wrk WHERE cdprograma = ''CRPS652'' and dtmvtolt between 
               to_date(''01/01/2019'',''dd/mm/rrrr'') and to_date(''31/03/2019'',''dd/mm/rrrr'') AND cdcooper = 3;',3);
  pc_cria_job('delete tbgen_batch_relatorio_wrk WHERE cdprograma = ''CRPS652'' and dtmvtolt between 
               to_date(''01/04/2019'',''dd/mm/rrrr'') and to_date(''30/06/2019'',''dd/mm/rrrr'') AND cdcooper = 3;',3);
  pc_cria_job('delete tbgen_batch_relatorio_wrk WHERE cdprograma = ''CRPS652'' and dtmvtolt between 
               to_date(''01/07/2019'',''dd/mm/rrrr'') and to_date(''30/09/2019'',''dd/mm/rrrr'') AND cdcooper = 3;',3);  
  pc_cria_job('delete tbgen_batch_relatorio_wrk WHERE cdprograma = ''CRPS652'' and dtmvtolt between 
               to_date(''01/10/2019'',''dd/mm/rrrr'') and to_date(''31/12/2019'',''dd/mm/rrrr'') AND cdcooper = 3;',3);  
  pc_cria_job('delete tbgen_batch_relatorio_wrk WHERE cdprograma = ''CRPS652'' and dtmvtolt between 
               to_date(''01/01/2020'',''dd/mm/rrrr'') and to_date(''31/03/2020'',''dd/mm/rrrr'') AND cdcooper = 3;',3);
  pc_cria_job('delete tbgen_batch_relatorio_wrk WHERE cdprograma = ''CRPS652'' and dtmvtolt between 
               to_date(''01/04/2020'',''dd/mm/rrrr'') and to_date(''31/05/2020'',''dd/mm/rrrr'') AND cdcooper = 3;',3);

--CRPS670 2390082
  pc_cria_job('delete tbgen_batch_relatorio_wrk WHERE cdprograma = ''CRPS670'' and dtmvtolt between 
               to_date(''01/10/2018'',''dd/mm/rrrr'') and to_date(''31/12/2018'',''dd/mm/rrrr'');',2);
  pc_cria_job('delete tbgen_batch_relatorio_wrk WHERE cdprograma = ''CRPS670'' and dtmvtolt between 
               to_date(''01/01/2019'',''dd/mm/rrrr'') and to_date(''31/12/2019'',''dd/mm/rrrr'');',5);
  pc_cria_job('delete tbgen_batch_relatorio_wrk WHERE cdprograma = ''CRPS670'' and dtmvtolt between 
               to_date(''01/01/2020'',''dd/mm/rrrr'') and to_date(''31/05/2020'',''dd/mm/rrrr'');',2);

--CRPS148 3231710
  pc_cria_job('delete tbgen_batch_relatorio_wrk WHERE cdprograma = ''CRPS148'' and dtmvtolt between 
               to_date(''01/01/2019'',''dd/mm/rrrr'') and to_date(''30/06/2019'',''dd/mm/rrrr'');',4);
  pc_cria_job('delete tbgen_batch_relatorio_wrk WHERE cdprograma = ''CRPS148'' and dtmvtolt between 
               to_date(''01/07/2019'',''dd/mm/rrrr'') and to_date(''31/12/2019'',''dd/mm/rrrr'');',3);

--CRPS010 9633803
  pc_cria_job('delete tbgen_batch_relatorio_wrk WHERE cdprograma = ''CRPS010'' and dtmvtolt between
               to_date(''01/07/2018'',''dd/mm/rrrr'') and to_date(''31/08/2018'',''dd/mm/rrrr'');',20);

--Total: 74.969.546 registros

end;
0
0
