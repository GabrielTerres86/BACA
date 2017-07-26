
DECLARE
  vr_dsplsql  VARCHAR2(1500);
  vr_jobname  VARCHAR2(50);
  vr_dscritic VARCHAR2(1000);
BEGIN
  
  vr_dsplsql := 'declare '||
                'vr_cdcritic integer; '||
                'vr_dscritic varchar2(4000); '||
                'begin EXPURGO.EXPU0001.pc_processar_expurgo (pr_cdcritic  => vr_cdcritic,
                                                                pr_dscritic  => vr_dscritic ); end;';
                   
  -- Montar o prefixo do código do programa para o jobname
  vr_jobname := 'EXPURGO.JBHST_EXPURGO';
  -- Faz a chamada ao programa paralelo atraves de JOB
  gene0001.pc_submit_job(pr_cdcooper  => 3 /*CECRED*/         --> Código da cooperativa
                        ,pr_cdprogra  => 'JBHST_EXPURGO'      --> Código do programa
                        ,pr_dsplsql   => vr_dsplsql           --> Bloco PLSQL a executar
                        ,pr_dthrexe   => TO_TIMESTAMP_TZ(to_char(SYSDATE + 1 ,'DD/MM/RRRR')||' 20:00 America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR') --> Executar nesta hora                 --> Executar nesta hora
                                         -- configurar para rodar diariamente a cada uma hora entre 08 às 19
                        ,pr_interva   => 'Freq=daily;ByHour=20;ByMinute=00;BySecond=0'
                        ,pr_jobname   => vr_jobname           --> Nome randomico criado
                        ,pr_des_erro  => vr_dscritic);
  -- Testar saida com erro
  IF vr_dscritic IS NOT NULL THEN
    -- Levantar exceçao
    RAISE_application_error(-20200,'Erro: '||vr_dscritic);
  END IF;  

END;
