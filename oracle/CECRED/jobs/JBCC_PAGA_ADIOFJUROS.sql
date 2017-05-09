/*   Criação do Job para rodar CRPS700(INSS)
     todos os dias as 18H
     
     Alteração:  08/05/2017 - Alterado para rodar apenas de segunda a sexta (Tiago)
                 
                 09/05/2017 - Adicionado drop do job (Tiago)
*/
DECLARE
  vr_dsplsql  VARCHAR2(1500);
  vr_jobname  VARCHAR2(50);
  vr_dscritic VARCHAR2(1000);
BEGIN
  
  vr_dsplsql := 'BEGIN pc_job_paga_adiofjuros; END;';
                   
  -- Montar o prefixo do código do programa para o jobname
  vr_jobname := 'JBCC_PAGA_ADIOFJUROS$';
  
  dbms_scheduler.drop_job(job_name => 'CECRED.'||vr_jobname);
  
  -- Faz a chamada ao programa paralelo atraves de JOB
  gene0001.pc_submit_job(pr_cdcooper  => 3 /*CECRED*/               --> Código da cooperativa
                        ,pr_cdprogra  => 'JBCC_PAGA_ADIOFJUROS'     --> Código do programa
                        ,pr_dsplsql   => vr_dsplsql                 --> Bloco PLSQL a executar
                        ,pr_dthrexe   => TO_TIMESTAMP_TZ(to_char(SYSDATE+1,'DD/MM/RRRR')||' 07:00 America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR') --> Executar nesta hora
                                         -- configurar para rodar diariamente as 18h
                        ,pr_interva   => 'Freq=daily;ByDay=Mon, Tue, Wed, Thu, Fri;ByHour=7,18;ByMinute=00;BySecond=0'
                                         --'freq=Daily; interval=1;'  --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                        ,pr_jobname   => vr_jobname                   --> Nome randomico criado
                        ,pr_des_erro  => vr_dscritic);
  -- Testar saida com erro
  IF vr_dscritic IS NOT NULL THEN
    -- Levantar exceçao
    RAISE_application_error(-20500,'Erro: '||vr_dscritic);
  END IF;

END;
/
