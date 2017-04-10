CREATE OR REPLACE PROCEDURE CECRED.pc_log_programa(
  PR_DSTIPLOG   IN     VARCHAR2,                               --> Tipo do log: I - início; F - fim; O - ocorrência
  PR_CDPROGRAMA IN     tbgen_prglog.cdprograma%type,           --> Codigo do programa ou do job
  pr_cdcooper   IN     crapcop.cdcooper%type        DEFAULT 3, --> Código da cooperativa
  pr_tpexecucao IN     tbgen_prglog.tpexecucao%type DEFAULT 1, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
  -- Parametros para Ocorrencia
  pr_tpocorrencia  IN tbgen_prglog_ocorrencia.tpocorrencia%type  DEFAULT 4,    -- tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
  pr_cdcriticidade IN tbgen_prglog_ocorrencia.cdcriticidade%type DEFAULT 0,    -- Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
  pr_cdmensagem    IN tbgen_prglog_ocorrencia.cdmensagem%type    DEFAULT 0,    -- cdcritic
  pr_dsmensagem    IN tbgen_prglog_ocorrencia.dsmensagem%type    DEFAULT NULL, -- dscritic       
  pr_flgsucesso    IN tbgen_prglog.flgsucesso%type               DEFAULT 1,    -- Indicador de sucesso da execução
  pr_nmarqlog      IN tbgen_prglog.nmarqlog%TYPE                 DEFAULT NULL, --  Nome do arquivo
  PR_IDPRGLOG      IN OUT tbgen_prglog.idprglog%type                           -- Identificador unico da tabela (sequence)
  ) IS
  PRAGMA AUTONOMOUS_TRANSACTION;  
BEGIN
  /* .......................................................................................
  Programa : pc_log_programa
  Sistema : Todos
  Autor   : Carlos Henrique/CECRED
  Data    : Março/2017                   Ultima atualizacao: 10/04/2017  

  Objetivo  : Logar execuções, ocorrências, erros ou mensagens dos programas.
              Abrir chamado e enviar e-mail quando necessário.
  
  Alterações:

  10/04/2017 - Inclusão do parâmetro pr_nmarlog (Carlos)
  .......................................................................................... */
  DECLARE 
  
  vr_idprglog   tbgen_prglog.idprglog%type;
  vr_nrexecucao tbgen_prglog.nrexecucao%type := 1;
  
  vr_cdprograma tbgen_prglog.cdprograma%TYPE := upper(pr_cdprograma);
  vr_dsmensagem tbgen_prglog_ocorrencia.dsmensagem%TYPE := pr_dsmensagem;
  
  exc_saida EXCEPTION;
  
  -- Busca última execução
  CURSOR cr_ultima_execucao IS
    SELECT p.nrexecucao
          ,p.idprglog
      FROM tbgen_prglog p
     WHERE p.cdcooper = pr_cdcooper
       AND p.cdprograma = pr_cdprograma
       AND TRUNC(p.dhinicio) = TRUNC(SYSDATE)
     ORDER BY p.nrexecucao DESC;

  rw_ultima_execucao cr_ultima_execucao%ROWTYPE;
    
  /* Função para inserir na tabela tbgen_prglog */
  FUNCTION fn_insert_tbgen_prglog(pr2_dhfim      tbgen_prglog.dhfim%type                 DEFAULT NULL,
                                  pr2_flgsucesso tbgen_prglog.flgsucesso%type            DEFAULT 1) 
                                  RETURN tbgen_prglog.idprglog%TYPE IS
  BEGIN   
    BEGIN
      	    
      INSERT INTO cecred.tbgen_prglog p
        (p.cdcooper
        ,p.tpexecucao
        ,p.cdprograma
        ,p.dhinicio
        ,p.dhfim
        ,p.flgsucesso
        ,p.nrexecucao
        ,p.nmarqlog
        )
      VALUES
        (pr_cdcooper
        ,pr_tpexecucao
        ,vr_cdprograma
        ,SYSDATE
        ,pr2_dhfim
        ,pr2_flgsucesso
        ,vr_nrexecucao
        ,pr_nmarqlog
        )
      RETURNING p.idprglog INTO vr_idprglog;
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        cecred.pc_internal_exception;
        COMMIT;
    END;
      
    RETURN vr_idprglog;

  END fn_insert_tbgen_prglog;

  /* Função para inserir na tabela tbgen_prglog_ocorrencia */
  PROCEDURE insert_tbgen_prglog_ocorrencia IS 
  BEGIN   
    BEGIN
      INSERT INTO cecred.tbgen_prglog_ocorrencia o
        (o.idprglog
        ,o.dhocorrencia
        ,o.tpocorrencia
        ,o.cdcriticidade
        ,o.cdmensagem
        ,o.dsmensagem)
      VALUES
        (PR_IDPRGLOG
        ,SYSDATE
        ,pr_tpocorrencia
        ,pr_cdcriticidade
        ,pr_cdmensagem
        ,vr_dsmensagem);
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        cecred.pc_internal_exception;
        COMMIT;
    END;             
  END insert_tbgen_prglog_ocorrencia;

-- Início do programa ======================================================================
  BEGIN
  /* I - início de execução de um programa
     F - fim de execução
     O ou E - ocorrência ou erro na execução
     PI / PF - início e fim de programa do processo */
  CASE 
    ----Início----------------------------------------------------------
    WHEN upper(pr_dstiplog) = 'I' THEN
      IF PR_IDPRGLOG = 0 THEN -- Executa apenas na primeira chamada

        -- Verifica a última execução do programa no dia
        OPEN cr_ultima_execucao;
        FETCH cr_ultima_execucao INTO rw_ultima_execucao;
          
        -- Se encontrar, incrementa o nr da execução
        IF cr_ultima_execucao%FOUND THEN
          vr_nrexecucao := rw_ultima_execucao.nrexecucao + 1;
        END IF;
          
        CLOSE cr_ultima_execucao; 
        
        PR_IDPRGLOG := fn_insert_tbgen_prglog();
      END IF;
    ----Fim-------------------------------------------------------------
    WHEN upper(pr_dstiplog) = 'F' THEN
      BEGIN 
        IF PR_IDPRGLOG = 0 THEN
          -- Verifica a última execução do programa no dia
          OPEN cr_ultima_execucao;
          FETCH cr_ultima_execucao INTO rw_ultima_execucao;
          
          IF cr_ultima_execucao%FOUND THEN
            -- Atualiza o fim da execução do programa
            UPDATE tbgen_prglog p
               SET p.dhfim      = SYSDATE
                  ,p.flgsucesso = pr_flgsucesso
             WHERE p.idprglog = rw_ultima_execucao.idprglog;
          ELSE
            -- Se não encontrar a última execuçao, cria tbgen_prglog
            PR_IDPRGLOG := fn_insert_tbgen_prglog(pr2_dhfim      => SYSDATE,
                                                  pr2_flgsucesso => 0);
          END IF;
          CLOSE cr_ultima_execucao;
        ELSE
          UPDATE tbgen_prglog p
             SET p.dhfim      = SYSDATE
                ,p.flgsucesso = pr_flgsucesso
           WHERE p.idprglog = PR_IDPRGLOG;
        END IF;

        COMMIT;        
      EXCEPTION
        WHEN OTHERS THEN
          cecred.pc_internal_exception;
          COMMIT;      
      END;
    ----Ocorrência/Erro-------------------------------------------------
    WHEN upper(pr_dstiplog) = 'O' OR upper(pr_dstiplog) = 'E' THEN
      BEGIN           
        
        IF nvl(PR_IDPRGLOG, 0) = 0 THEN
          -- Verifica a última execução do programa no dia
          OPEN cr_ultima_execucao;
          FETCH cr_ultima_execucao INTO rw_ultima_execucao;
          
          -- Se não encontrar a última execuçao, cria tbgen_prglog
          IF cr_ultima_execucao%NOTFOUND THEN
            
            IF (instr(lower(pr_cdprograma), '.log', 1) > 0) THEN
              vr_cdprograma := pr_cdprograma;              
            ELSE 
              vr_cdprograma := 'LOG_BATCH';
              vr_dsmensagem := 'Crítica fora do padrão: ' || pr_dsmensagem;
            END IF;

            PR_IDPRGLOG := fn_insert_tbgen_prglog(pr2_dhfim      => SYSDATE,
                                                  pr2_flgsucesso => 0);
          ELSE
            -- Logará ocorrência na última execução do programa
            PR_IDPRGLOG := rw_ultima_execucao.idprglog;
          END IF;
          CLOSE cr_ultima_execucao;

        END IF;

        -- Cria a ocorrência
        insert_tbgen_prglog_ocorrencia;
        
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          cecred.pc_internal_exception;
          COMMIT;      
      END;      
    ----Processo batch início------------------------------------------------
    WHEN upper(pr_dstiplog) = 'PI' THEN 
      BEGIN       
        
        -- Verifica a última execução do programa no dia
        OPEN cr_ultima_execucao;
        FETCH cr_ultima_execucao INTO rw_ultima_execucao;
        
        -- Se encontrar, incrementa o nr da execução
        IF cr_ultima_execucao%FOUND THEN
          vr_nrexecucao := rw_ultima_execucao.nrexecucao + 1;
        END IF;
        
        CLOSE cr_ultima_execucao;      
        
        INSERT INTO cecred.tbgen_prglog p
          (p.cdcooper
          ,p.tpexecucao
          ,p.cdprograma
          ,p.nrexecucao
          ,p.dhinicio
          ,p.flgsucesso)
        VALUES
          (pr_cdcooper
          ,1 --tpexecucao Batch
          ,pr_cdprograma
          ,vr_nrexecucao
          ,SYSDATE
          ,1)
        RETURNING p.idprglog INTO vr_idprglog;
          
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          cecred.pc_internal_exception;
          COMMIT;
      END;
    ----Processo batch fim-------------------------------------------------
    WHEN upper(pr_dstiplog) = 'PF' THEN 
      BEGIN
        
        -- Verifica a última execução do programa no dia
        OPEN cr_ultima_execucao;
        FETCH cr_ultima_execucao INTO rw_ultima_execucao;

        IF cr_ultima_execucao%FOUND THEN
          CLOSE cr_ultima_execucao;
          BEGIN
            UPDATE tbgen_prglog p
               SET p.dhfim = SYSDATE
             WHERE p.idprglog = rw_ultima_execucao.idprglog;
          EXCEPTION
            WHEN OTHERS THEN
              cecred.pc_internal_exception;
          END;
        ELSE
          CLOSE cr_ultima_execucao;
          RAISE exc_saida;
        END IF;
      
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          cecred.pc_internal_exception;
          COMMIT;
      END;
    ELSE -- fim das opções do CASE
      NULL;    
  END CASE;    

  EXCEPTION  
    WHEN exc_saida THEN
      NULL;
    WHEN OTHERS THEN
      cecred.pc_internal_exception;
  END;
END pc_log_programa;
/
