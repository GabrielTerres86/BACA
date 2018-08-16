Begin   EXECUTE IMMEDIATE 'ALTER SESSION SET      
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
 
  sys.dbms_scheduler.drop_job(job_name => 'CECRED.JBEPR_MULT_JUR_TR');               --Incluir o DROP sempre que houver alteração de configuração de um JOB já existente 
 
  sys.dbms_scheduler.create_job( 
   job_name            => 'CECRED.JBGEN_EFETIVA_LCTO_PENDENTE', 
   job_type            => 'PLSQL_BLOCK', 
   job_action          => 'begin TELA_LAUTOM.pc_efetiva_lcto_pendente_job; end;',
   start_date          => to_date('27-07-2016 11:00:00', 'dd-mm-yyyy hh24:mi:ss'),
   repeat_interval => 'FREQ=DAILY;BYHOUR=11,17', 
   end_date            => null,                    
   job_class           => 'DEFAULT_JOB_CLASS',                    
   enabled             => true,                    
   auto_drop           => true,                    
   comments            => ''
   ); 
end;
/ 
