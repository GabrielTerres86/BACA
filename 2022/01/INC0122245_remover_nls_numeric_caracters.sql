DECLARE

  PROCEDURE cria_agendamento IS
  BEGIN
    sys.dbms_scheduler.create_job(job_name        => 'cecred.JBSEG_INTEGRA_CRED_IMOBILIARIO',
                                  job_type        => 'PLSQL_BLOCK',
                                  job_action      => 'DECLARE
                                                        vr_cdcritic     INTEGER:= 0;
                                                        vr_dscritic     VARCHAR2(4000);
                                                      BEGIN
                                                                                                       
                                                            CECRED.pc_integra_seguro_cred_imobiliario(pr_cdcritic => vr_cdcritic
                                                                                                     ,pr_dscritic => vr_dscritic);
                                                            IF vr_dscritic IS NOT NULL THEN
                                                              raise_application_error(-20001,vr_dscritic);
                                                            END IF;
                                                        
                                                      END;' ,
                                  start_date      => TO_TIMESTAMP_TZ( to_char((trunc(sysdate)),'DD/MM/RRRR')  
                                                                   ||' 07:00 America/Sao_Paulo',
                                                                     'DD/MM/RRRR HH24:MI TZR'),
                                  repeat_interval => 'FREQ=DAILY;BYHOUR=07',
                                  end_date        => to_date(NULL),
                                  job_class       => 'DEFAULT_JOB_CLASS',
                                  enabled         => TRUE,
                                  auto_drop       => TRUE,
                                  comments        => 'Processar solicitação pc_integra_seguro_cred_imobiliario');
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log  
      CECRED.pc_internal_exception;
      raise_application_error(-20000, '3 ERRO: ' || SQLERRM);
  END;

BEGIN

  EXECUTE IMMEDIATE 'ALTER SESSION SET 
  nls_calendar = ''GREGORIAN''
  nls_comp = ''BINARY''
  nls_date_format = ''DD-MON-RRRR''
  nls_date_language = ''AMERICAN''
  nls_iso_currency = ''AMERICA''
  nls_language = ''AMERICAN''
  nls_length_semantics = ''BYTE''
  nls_nchar_conv_excp = ''FALSE''
  nls_numeric_characters = '',.''
  nls_sort = ''BINARY''
  nls_territory = ''AMERICA''
  nls_time_format = ''HH.MI.SSXFF AM''
  nls_time_tz_format = ''HH.MI.SSXFF AM TZR''
  nls_timestamp_format = ''DD-MON-RR HH.MI.SSXFF AM''
  nls_timestamp_tz_format = ''DD-MON-RR HH.MI.SSXFF AM TZR''';

  BEGIN
    sys.dbms_scheduler.drop_job(job_name => 'cecred.JBSEG_INTEGRA_CRED_IMOBILIARIO');
    dbms_output.put_line('Exclusão Ok JBSEG_INTEGRA_CRED_IMOBILIARIO');
    cria_agendamento;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -27475 THEN
        dbms_output.put_line('Não existe JBSEG_INTEGRA_CRED_IMOBILIARIO Ok !');
        cria_agendamento;
      ELSE
        -- No caso de erro de programa gravar tabela especifica de log  
        CECRED.pc_internal_exception;
        raise_application_error(-20001, '2 ERRO: ' || SQLERRM);
      END IF;
  END;

EXCEPTION
  WHEN OTHERS THEN
    -- No caso de erro de programa gravar tabela especifica de log  
    CECRED.pc_internal_exception;
    raise_application_error(-20002, '1 ERRO: ' || SQLERRM);
END;
