-- Created on 20/12/2021 by F0033330
declare 
  -- Local variables here
  vr_cdcooper integer := 1;
  vr_dscritic  VARCHAR2(1000);
  vr_plsql1    VARCHAR2(4000);
  vr_cdprogra  VARCHAR2(100) := 'JBSOBRPIX_1_';
  vr_jobname   VARCHAR2(100);
  vr_exc_saida EXCEPTION;
  
  -- ID para o paralelismo
  vr_idparale  INTEGER := 0;
  -- Qtde parametrizada de Jobs
  vr_qtdjobs   NUMBER  := 15;
  
  PROCEDURE exec_sql(vr_comando IN VARCHAR2) IS
    BEGIN
     EXECUTE IMMEDIATE vr_comando;
    EXCEPTION
      WHEN OTHERS THEN
        cecred.pc_internal_exception;
    END;
      
begin
  
  -- Gerar o ID para o paralelismo
  vr_idparale := gene0001.fn_gera_ID_paralelo;

  -- Se houver algum erro, o id vira zerado
  IF vr_idparale = 0 THEN
     -- Levantar exceção
     vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_ID_paral.';
     RAISE vr_exc_saida;
  END IF;   
  
  FOR mes IN 1..12 LOOP

    vr_plsql1 := 'begin cecred.pc_operacoa_diaria_pix_retro_viacredi(' || vr_cdcooper || ',' || vr_idparale || ',' || mes || ',' || mes || '); end;';
    vr_jobname := vr_cdprogra || mes || '_$';
    
    -- Cadastra o programa paralelo
    gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                              ,pr_idprogra => mes
                              ,pr_des_erro => vr_dscritic);
                              
    -- Testar saida com erro
    if vr_dscritic is not null then
      -- Levantar exceçao
      raise vr_exc_saida;
    end if;                              
    
    -- Faz a chamada ao programa paralelo atraves de JOB
    gene0001.pc_submit_job(pr_cdcooper => 3            --> Código da cooperativa
                          ,pr_cdprogra => vr_cdprogra  --> Código do programa
                          ,pr_dsplsql  => vr_plsql1
                          ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                          ,pr_interva  => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                          ,pr_jobname  => vr_jobname   --> Nome randomico criado
                          ,pr_des_erro => vr_dscritic);
                          
    -- Chama rotina que irá pausar este processo controlador
    -- caso tenhamos excedido a quantidade de JOBS em execuçao
    gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                ,pr_qtdproce => vr_qtdjobs --> Máximo de 10 jobs neste processo
                                ,pr_des_erro => vr_dscritic);

    -- Testar saida com erro
    if  vr_dscritic is not null then
      -- Levantar exceçao
      raise vr_exc_saida;
    end if;                                
  END LOOP;
  
  gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                              ,pr_qtdproce => 0 --> Aguardar a finalização de todos os jobs
                              ,pr_des_erro => vr_dscritic);
  
  exec_sql('drop procedure cecred.pc_operacoa_diaria_pix_retro_viacredi');
  
  COMMIT;
  
  EXCEPTION 
    WHEN OTHERS THEN
      dbms_output.put_line('Erro: ' || SQLERRM || ' - ' || vr_dscritic);
end;
