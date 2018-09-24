Begin
 EXECUTE IMMEDIATE 
 'ALTER SESSION SET nls_calendar = ''GREGORIAN''
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
 
 sys.dbms_scheduler.drop_job(job_name => 'CECRED.JBGRV_SEM_EFETIVA');
 
 --Incluir o DROP sempre que houver alteração de configuração de um JOB já existente
 sys.dbms_scheduler.create_job(job_name => 'CECRED.JBGRV_SEM_EFETIVA'
                              ,job_type => 'PLSQL_BLOCK'
                              ,job_action => 'begin
                                                cecred.grvm0001.pc_alerta_gravam_sem_efetiva;
                                              exception
                                                when others then                                 
                                                  -- Levantar exceçao
                                                  RAISE_application_error(-20500,''Erro: ''||sqlerrm);
                                              end;'
                              ,start_date => to_timestamp_tz(to_char(sysdate+1,'DD/MM/RRRR')||' 07:30 America/Sao_Paulo','dd/mm/rrrr hh24:mi tzr') --> Executar nesta hora
                              ,repeat_interval => 'freq=daily;interval=1;'
                              ,end_date => to_date(null)
                              ,job_class => 'DEFAULT_JOB_CLASS'
                              ,enabled => true
                              ,auto_drop => true
                              ,comments => 'Programa responsável por gerar e-mail contendo as propostas com veículos alienados e não efetivadas. '
                                        || 'Roda diariamente. Se necessário, pode ser executado fora do processo batch.');
end;