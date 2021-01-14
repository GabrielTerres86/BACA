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
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_numeric_characters = ''.,''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_sort = ''BINARY''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_territory = ''AMERICA''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_time_format = ''HH.MI.SSXFF AM''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_time_tz_format = ''HH.MI.SSXFF AM TZR''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_timestamp_format = ''DD-MON-RR HH.MI.SSXFF AM''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET nls_timestamp_tz_format = ''DD-MON-RR HH.MI.SSXFF AM TZR''';
 
  vr_dsplsql := 'declare '||
                'vr_cdcritic number; '||
                'vr_dscritic varchar2(4000); '||                
                'BEGIN CREDITO.GerarArquivoPronampe(pr_cdcritic => vr_cdcritic,'||
                                                  ' pr_dscritic => vr_dscritic ); END;';
                   
  -- Montar o prefixo do código do programa para o jobname
  vr_jobname := 'JBEPR_GERARPRONAMPE_0500';
  -- Faz a chamada ao programa paralelo atraves de JOB
  gene0001.pc_submit_job(pr_cdcooper  => 3 /*CECRED*/         --> Código da cooperativa
                        ,pr_cdprogra  => 'JBEPR_GERARPRONAMPE_0500'--> Código do programa
                        ,pr_dsplsql   => vr_dsplsql           --> Bloco PLSQL a executar
                        ,pr_dthrexe   => TO_TIMESTAMP_TZ('17/08/2020'||' 05:00 America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR')                 --> Executar nesta hora
                        --,pr_interva   => null                                         
                        ,pr_jobname   => vr_jobname      
                        ,pr_des_erro  => vr_dscritic);
  -- Testar saida com erro
  IF vr_dscritic IS NOT NULL THEN
    -- Levantar exceçao
    RAISE_application_error(-20200,'Erro: '||vr_dscritic);
  END IF;
  
  -- Montar o prefixo do código do programa para o jobname
  vr_jobname := 'JBEPR_GERARPRONAMPE_0630';
  -- Faz a chamada ao programa paralelo atraves de JOB
  gene0001.pc_submit_job(pr_cdcooper  => 3 /*CECRED*/         --> Código da cooperativa
                        ,pr_cdprogra  => 'JBEPR_GERARPRONAMPE_0630'--> Código do programa
                        ,pr_dsplsql   => vr_dsplsql           --> Bloco PLSQL a executar
                        ,pr_dthrexe   => TO_TIMESTAMP_TZ('17/08/2020'||' 06:30 America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR')                 --> Executar nesta hora
                        --,pr_interva   => null                                         
                        ,pr_jobname   => vr_jobname      
                        ,pr_des_erro  => vr_dscritic);
  -- Testar saida com erro
  IF vr_dscritic IS NOT NULL THEN
    -- Levantar exceçao
    RAISE_application_error(-20200,'Erro: '||vr_dscritic);
  END IF;  
 
END;
