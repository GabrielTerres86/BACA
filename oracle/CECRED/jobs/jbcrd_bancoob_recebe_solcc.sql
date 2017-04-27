/*   Criação do Job para rodar CRPS672(CCR3)
     todos os dias as 07:30H
*/
DECLARE
  vr_dsplsql  VARCHAR2(1500);
  vr_jobname  VARCHAR2(50);
  vr_dscritic VARCHAR2(1000);
BEGIN
  
  vr_dsplsql := 'BEGIN PC_BANCOOB_RECEBE_ARQ_SOLCC; END;';
                   
  -- Montar o prefixo do código do programa para o jobname
  vr_jobname := UPPER('jbcrd_bancoob_recebe_solcc');
  -- Faz a chamada ao programa paralelo atraves de JOB
  gene0001.pc_submit_job(pr_cdcooper  => 3 /*CECRED*/                 --> Código da cooperativa
                        ,pr_cdprogra  => vr_jobname                   --> Código do programa
                        ,pr_dsplsql   => vr_dsplsql                   --> Bloco PLSQL a executar
                        ,pr_dthrexe   => TO_TIMESTAMP_TZ(to_char(SYSDATE+1,'DD/MM/RRRR')||' 07:30 America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR') --> Executar nesta hora
                                         -- configurar para rodar diariamente as 07:00h
                        ,pr_interva   => 'Freq=daily;ByHour=7;ByMinute=30;BySecond=0'
                                         --'freq=Daily; interval=1;'  --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                        ,pr_jobname   => vr_jobname                   --> Nome randomico criado
                        ,pr_des_erro  => vr_dscritic);
                        
  -- Testar saida com erro
  IF vr_dscritic IS NOT NULL THEN
    -- Levantar exceçao
    RAISE_application_error(-20500,'Erro: '||vr_dscritic);
  END IF;

END;

