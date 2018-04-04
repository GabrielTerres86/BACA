/*   Criação do Job para rodar a Remoção de Cobertura Sem Vinculo
     todos os sabados as 10H
*/
DECLARE
  vr_dsplsql  VARCHAR2(1500);
  vr_jobname  VARCHAR2(50);
  vr_dscritic VARCHAR2(1000);

BEGIN

  vr_dsplsql := 'BEGIN '|| CHR(10)
             || ' CECRED.bloq0001.pc_remove_cobertura_sem_vinc; '|| CHR(10)
             || 'END; ';

  -- Montar o prefixo do codigo do programa para o jobname
  vr_jobname := 'JBGAR_LIMPEZA$';

  -- Faz a chamada ao programa paralelo atraves de JOB
  GENE0001.pc_submit_job(pr_cdcooper => 3 /*CECRED*/               --> Código da cooperativa
                        ,pr_cdprogra => 'JBGAR_LIMPEZA'            --> Código do programa
                        ,pr_dsplsql  => vr_dsplsql                 --> Bloco PLSQL a executar
                        ,pr_dthrexe  => TO_TIMESTAMP_TZ(to_char(SYSDATE + 4,'DD/MM/RRRR')||' 10:00 America/Sao_Paulo','DD/MM/RRRR HH24:MI TZR') --> Executar no proximo sabado
                                        --> configurar para rodar Semanalmente as 10:00
                        ,pr_interva  => 'FREQ=WEEKLY; BYDAY=SAT;byhour=10;byminute=00;' 
                        ,pr_jobname  => vr_jobname                 --> Nome randomico criado
                        ,pr_des_erro => vr_dscritic);

  -- Testar saida com erro
  IF vr_dscritic IS NOT NULL THEN
    -- Levantar exceçao
    RAISE_application_error(-20200,'Erro: '||vr_dscritic);
  END IF;

END;
