/*   Cria��o do Job para rodar CRPS700(INSS)
     todos os dias as 18H
*/
DECLARE
  vr_dsplsql  VARCHAR2(1500);
  vr_jobname  VARCHAR2(50);
  vr_dscritic VARCHAR2(1000);
BEGIN
  
  vr_dsplsql := 'begin			
	    -- Verifica se � fim de semana
			IF to_char(sysdate,''D'') NOT IN (1,7) THEN
				cecred.PC_CRPS700; 
			END IF;      
			end;';
                   
  -- Montar o prefixo do c�digo do programa para o jobname
  vr_jobname := 'PC_CRPS700_DIARIO$';
  -- Faz a chamada ao programa paralelo atraves de JOB
  gene0001.pc_submit_job(pr_cdcooper  => 3 /*CECRED*/               --> C�digo da cooperativa
                        ,pr_cdprogra  => 'PC_CRPS700'				        --> C�digo do programa
                        ,pr_dsplsql   => vr_dsplsql                 --> Bloco PLSQL a executar
                        ,pr_dthrexe   => TO_TIMESTAMP_TZ(to_char(SYSDATE+1,'DD/MM/RRRR')||' 18:00 America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR') --> Executar nesta hora
                                         -- configurar para rodar diariamente as 18h
                        ,pr_interva   => 'freq=daily;byhour=18;byminute=0;bysecond=0;'
                                         --'freq=Daily; interval=1;'  --> Sem intervalo de execu��o da fila, ou seja, apenas 1 vez
                        ,pr_jobname   => vr_jobname                   --> Nome randomico criado
                        ,pr_des_erro  => vr_dscritic);
  -- Testar saida com erro
  IF vr_dscritic IS NOT NULL THEN
    -- Levantar exce�ao
    RAISE_application_error(-25200,'Erro: '||vr_dscritic);
  END IF;

END;
/
