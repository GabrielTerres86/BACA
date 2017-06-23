/*   Criação do Job para processar arquivo de cessão de credito
     - PRJ343 - Cessao de credito 
*/

DECLARE
  vr_dsplsql  VARCHAR2(1500);
  vr_jobname  VARCHAR2(50);
  vr_dscritic VARCHAR2(1000);
BEGIN
  
  vr_dsplsql := 'begin cecred.pc_crps714(pr_cdcooper => 3); end;';
                   
  -- Montar o prefixo do código do programa para o jobname
  vr_jobname := 'JBCRD_IMPORTA_CESSAO';
  -- Faz a chamada ao programa paralelo atraves de JOB
  gene0001.pc_submit_job(pr_cdcooper  => 3 /*CECRED*/         --> Código da cooperativa
                        ,pr_cdprogra  => 'JBCRD_IMPORTA_CESSAO'--> Código do programa
                        ,pr_dsplsql   => vr_dsplsql           --> Bloco PLSQL a executar
                        ,pr_dthrexe   => TO_TIMESTAMP_TZ(to_char(SYSDATE + 1 ,'DD/MM/RRRR')||' 10:00 America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR') --> Executar nesta hora
                                         -- configurar para rodar diariamente as 10 e 15 horas
                        ,pr_interva   => 'Freq=daily;ByDay=MON, TUE, WED, THU, FRI;ByHour=10,15;ByMinute=00;BySecond=0'
                        ,pr_jobname   => vr_jobname           --> Nome randomico criado
                        ,pr_des_erro  => vr_dscritic);
  -- Testar saida com erro
  IF vr_dscritic IS NOT NULL THEN
    -- Levantar exceçao
    RAISE_application_error(-20200,'Erro: '||vr_dscritic);
  END IF;
  
  dbms_scheduler.set_attribute(name      => 'cecred.'||vr_jobname,
                               attribute => 'comments', 
                               value     => 'Rodar programa CRPS714 - Responsavel em processar arq. de cessao de credito '||
                                            ',roda toda os dias as 10 e 15h.');
  

END;
