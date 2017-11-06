/*   Criação do Job para rodar programa Rodar programa CADA0015.pc_processa_pessoa_atlz - Responsavel em buscar 
      dados de pessoa na estrutura de conta e passar para a cadastro unificado de pessoa, roda a cada 1 minuto
      PRJ339 - CRM
      
*/

DECLARE
  vr_dsplsql  VARCHAR2(1500);
  vr_jobname  VARCHAR2(50);
  vr_dscritic VARCHAR2(1000);
BEGIN
  
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_calendar = ''GREGORIAN''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_comp = ''BINARY''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_date_format = ''DD-MON-RR''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_date_language = ''AMERICAN''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_iso_currency = ''AMERICA''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_language = ''AMERICAN''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_length_semantics = ''BYTE''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_nchar_conv_excp = ''FALSE''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_numeric_characters = '',.''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_sort = ''BINARY''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_territory = ''AMERICA''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_time_format = ''HH.MI.SSXFF AM''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_time_tz_format = ''HH.MI.SSXFF AM TZR''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_timestamp_format = ''DD-MON-RR HH.MI.SSXFF AM''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_timestamp_tz_format = ''DD-MON-RR HH.MI.SSXFF AM TZR''';
   


  vr_dsplsql := 'declare '||
                'vr_dscritic varchar2(4000); '||
                'begin CADA0015.pc_processa_pessoa_atlz (pr_dscritic => vr_dscritic); end;';
                   
  -- Montar o prefixo do código do programa para o jobname
  vr_jobname := 'JBCADAST_PROC_PESSOA_ATLZ';
  -- Faz a chamada ao programa paralelo atraves de JOB
  gene0001.pc_submit_job(pr_cdcooper  => 3 /*CECRED*/         --> Código da cooperativa
                        ,pr_cdprogra  => 'JBCADAST_PROC_PESSOA_ATLZ'--> Código do programa
                        ,pr_dsplsql   => vr_dsplsql           --> Bloco PLSQL a executar
                        ,pr_dthrexe   => TO_TIMESTAMP_TZ(to_char(SYSDATE,'DD/MM/RRRR HH24:MI')||' America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR') --> Executar nesta hora                 --> Executar nesta hora
                                         -- configurar para rodar diariamente a cada um minuto
                        ,pr_interva   => 'freq=MINUTELY;BYSECOND=0'                                         
                        ,pr_jobname   => vr_jobname           --> Nome randomico criado
                        ,pr_des_erro  => vr_dscritic);
  -- Testar saida com erro
  IF vr_dscritic IS NOT NULL THEN
    -- Levantar exceçao
    RAISE_application_error(-20200,'Erro: '||vr_dscritic);
  END IF;
  
  dbms_scheduler.set_attribute(name      => 'cecred.'||vr_jobname,
                               attribute => 'comments', 
                               value     => 'Rodar programa CADA0015.pc_processa_pessoa_atlz - Responsavel em buscar '||
                                            'dados de pessoa na estrutura de conta e passar para a cadastro unificado de pessoa, '||
                                            'roda a cada 1 minuto');
  

END;
