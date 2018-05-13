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
  pr_flabrechamado IN INTEGER                                    DEFAULT 0,    -- Abre chamado sim/nao
  pr_texto_chamado IN VARCHAR2                                   DEFAULT NULL, -- Texto do chamado
  pr_destinatario_email IN VARCHAR2                              DEFAULT NULL, -- Destinatario do email
  pr_flreincidente IN INTEGER                                    DEFAULT 0,    -- Erro pode reincidir no prog em dias diferentes, devendo abrir chamado
  PR_IDPRGLOG      IN OUT tbgen_prglog.idprglog%type                  -- Identificador unico da tabela (sequence)
  ) IS
  PRAGMA AUTONOMOUS_TRANSACTION;  
BEGIN
  /* .......................................................................................
  Programa : pc_log_programa
  Sistema : Todos
  Autor   : Carlos Henrique/CECRED
  Data    : Março/2017                   Ultima atualizacao: 29/09/2017  

  Objetivo  : Logar execuções, ocorrências, erros ou mensagens dos programas.
              Abrir chamado e enviar e-mail quando necessário.
  
  Alterações: 10/04/2017 - Inclusão do parâmetro pr_nmarlog (Carlos)
              
              17/04/2017 - Tratamento para abrir chamado quando ocorrer algum erro e 
                           tambem enviar o numero do chamado aberto para o analista 
                           responsavel do produto (Lucas Ranghetti #630298)
                           
              04/05/2017 - Verificação para não abrir vários chamados. Parametrização da quantidade
                           de dias para pesquisa de ocorrência de erro com chamado aberto (Carlos)
                           
              24/05/2017 - Incluir validacao para nao dar erro ao armazenar o numero do chamado
                           (Lucas Ranghetti #678334)
                           
              24/07/2017 - Inclusão validação para leitura modulo/ação do banco
                           (Ana Volles - Envolti - Chamado 696499)

              27/07/2017 - Inclusão nvl para validação de PR_IDPRGLOG
                           (Ana Volles - Envolti - Chamado 696499)
                           
              29/09/2017 - Inclusão dos parâmetros cd_prioridade=5 (normal) e 
                           cd_nivel_indisponibilidade=4 (Operação normal) para a abertura de
                           chamados (Carlos)
  .......................................................................................... */
  DECLARE 
  
  vr_idprglog   tbgen_prglog.idprglog%type;
  vr_nrexecucao tbgen_prglog.nrexecucao%type := 1;
  
  vr_cdprograma tbgen_prglog.cdprograma%TYPE := upper(pr_cdprograma);
  vr_dsmensagem tbgen_prglog_ocorrencia.dsmensagem%TYPE := pr_dsmensagem;
  vr_texto_chamado VARCHAR2(5000);
  vr_titulo_chamado VARCHAR2(1000);
  vr_texto_email VARCHAR2(10000);
  vr_chamado VARCHAR2(1000);
  vr_comando VARCHAR2(1000);
  vr_link_softdesk VARCHAR2(500);
  vr_typ_saida     VARCHAR2(4000);
  vr_dscritic VARCHAR2(4000);
  vr_mensagem_chamado VARCHAR2(5000);
  vr_texto_chamado1 VARCHAR2(5000);
  vr_nrchamado NUMBER;
  vr_usuario_sd VARCHAR2(20);
  vr_dtpesquisa DATE := SYSDATE;

  vr_modulo VARCHAR2(100);
  vr_acao   VARCHAR2(100);
  
  exc_saida EXCEPTION;
  
  -- Busca última execução
  CURSOR cr_ultima_execucao IS
    SELECT p.nrexecucao
          ,p.idprglog
      FROM tbgen_prglog p
     WHERE p.cdcooper = pr_cdcooper
       AND p.cdprograma = vr_cdprograma
       AND TRUNC(p.dhinicio) = TRUNC(SYSDATE)
     ORDER BY p.nrexecucao DESC;

  rw_ultima_execucao cr_ultima_execucao%ROWTYPE;
    
  CURSOR cr_tem_chamado(pr_dtpesquisa DATE) IS 
    SELECT 1 indexiste
    FROM tbgen_prglog            p
        ,tbgen_prglog_ocorrencia o
   WHERE p.cdcooper        = pr_cdcooper
     AND p.cdprograma      = vr_cdprograma
     AND TRUNC(p.dhinicio) >= TRUNC(pr_dtpesquisa)
     AND o.cdmensagem = pr_cdmensagem
     AND o.nrchamado IS NOT NULL
     AND p.idprglog = o.idprglog;

  rw_tem_chamado cr_tem_chamado%ROWTYPE;
    
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
        ,o.dsmensagem
        ,o.nrchamado)
      VALUES
        (PR_IDPRGLOG
        ,SYSDATE
        ,pr_tpocorrencia
        ,pr_cdcriticidade
        ,pr_cdmensagem
        ,vr_dsmensagem
        ,vr_nrchamado);
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
      IF nvl(PR_IDPRGLOG,0) = 0 THEN -- Executa apenas na primeira chamada

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
        IF nvl(PR_IDPRGLOG,0) = 0 THEN
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

        --Verifica se o programa que chamou esta rotina informou module
        --Chamado 696499
        IF INSTR(vr_dsmensagem, 'Module', 1, 1) = 0 THEN

           --Inclusão leitura modulo/ação do banco
           DBMS_APPLICATION_INFO.read_module(module_name => vr_modulo, action_name => vr_acao);
           vr_dsmensagem := vr_dsmensagem || ' - Module: ' || vr_modulo ||
                                             ' - Action: ' || vr_acao;
        END IF;

        IF nvl(PR_IDPRGLOG, 0) = 0 THEN
          -- Verifica a última execução do programa no dia
          OPEN cr_ultima_execucao;
          FETCH cr_ultima_execucao INTO rw_ultima_execucao;
          
          -- Se não encontrar a última execuçao, cria tbgen_prglog
          IF cr_ultima_execucao%NOTFOUND THEN

            PR_IDPRGLOG := fn_insert_tbgen_prglog(pr2_dhfim      => SYSDATE,
                                                  pr2_flgsucesso => 0);
          ELSE
            -- Logará ocorrência na última execução do programa
            PR_IDPRGLOG := rw_ultima_execucao.idprglog;
          END IF;
          CLOSE cr_ultima_execucao;

        END IF;

        -- Se eh para abrir chamado
        IF pr_flabrechamado = 1 THEN
          
          /* Se não for reincidente (default 0), pesquisar últimos N dias */
          IF pr_flreincidente = 0 THEN          
            vr_dtpesquisa := vr_dtpesquisa - NVL(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                                                           pr_cdacesso => 'QTD_DIAS_REINCIDENTE'), 30);
          END IF;
          
          rw_tem_chamado.indexiste := 0;          
          OPEN cr_tem_chamado(vr_dtpesquisa);
          FETCH cr_tem_chamado INTO rw_tem_chamado;
          CLOSE cr_tem_chamado;

          -- Se não encontrar chamado, abrir
          IF rw_tem_chamado.indexiste = 0 THEN
            
          -- Buscar caminho do softdesk (homol ou prod)
          IF gene0001.fn_database_name = 'AYLLOSP' THEN
            vr_link_softdesk:= 'https://softdesk.cecred.coop.br';
          ELSE
            vr_link_softdesk:= 'http://softdesktreina.cecred.coop.br';
          END IF;  
        
          -- Substituir acentos
          vr_mensagem_chamado:= gene0007.fn_caract_acento(pr_dsmensagem);
          vr_texto_chamado1:= gene0007.fn_caract_acento(pr_texto_chamado);
          
          -- Usar o utl.escape para substituir caracteres de html para o comando entender
          vr_texto_chamado := utl_url.escape(vr_texto_chamado1) || '<br><br>' || 
                              utl_url.escape(vr_mensagem_chamado);
          vr_titulo_chamado := utl_url.escape('Evento Monitoracao');
          vr_usuario_sd := utl_url.escape('monitor sistemas');
          
          -- Comando para abrir chamado no softdesk
          vr_comando := 'curl -k ' || '"'||vr_link_softdesk||'/modulos/incidente/'
                    || 'api.php?cd_area=2&cd_usuario='||vr_usuario_sd||'&tt_chamado='
                    || vr_titulo_chamado || '&ds_chamado=' || vr_texto_chamado 
                    || '&cd_categoria=586'||'&cd_grupo_solucao=128&cd_servico=57&cd_tipo_chamado=5'
                    || '&cd_prioridade=5&cd_nivel_indisponibilidade=4"'
                    || ' 2> /dev/null';
                    
          --Executar o comando no unix
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => vr_comando
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_chamado);
                               
          BEGIN                  
          -- Irá sempre retornar a saida como: Chamado no Soft desk: numero
          vr_nrchamado:= substr(TRIM(REPLACE(REPLACE(vr_chamado,chr(13),NULL),chr(10),NULL)),23,10);
          EXCEPTION
            WHEN OTHERS THEN
              vr_nrchamado:= 0; -- Ocorreu erro ao abrir o chamado
          END;     
          
          -- Texto do chamado + o chamado aberto
          vr_texto_email:= pr_texto_chamado || pr_dsmensagem ||'<br><br><b>'||'Chamado no Softdesk: '||
                           vr_nrchamado||'.</b>';                   

          -- Por fim, envia o email
          gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprograma
                                    ,pr_des_destino => pr_destinatario_email
                                    ,pr_des_assunto => 'ERRO NA EXECUCAO DO PROGRAMA '|| vr_cdprograma
                                    ,pr_des_corpo   => vr_texto_email
                                    ,pr_des_anexo   => NULL
                                    ,pr_flg_enviar  => 'N'
                                    ,pr_des_erro    => vr_dscritic); 
          END IF;
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
          ,vr_cdprograma
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
