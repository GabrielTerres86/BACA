CREATE OR REPLACE PROCEDURE CECRED.pc_gera_dados_cyber(pr_dscritic OUT VARCHAR2) IS
BEGIN 

/* .............................................................................

  Programa: PC_GERA_DADOS_CYBER
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : 
  Data    : 2017.                                     Ultima atualizacao: 08/08/2018
  Dados referentes ao programa:
    Frequencia: Diaria. Seg-sex, 08h
    Programa Chamador: JBCYB_GERA_DADOS_CYBER

  Alteracoes: 14/11/2017 - Log de trace da exception others e retorno de cr�tica para
                           o programa chamador (Carlos)

              09/01/2018 - #826598 Tratamento para enviar e-mail e abrir chamado quando 
                           ocorrer erro na execu��o do programa pc_crps652 (Carlos)

              16/01/2018 - Quando chegar reagendamento n�o retornar mensagem de erro.
                           A solu��o definitiva ser� em novo chamado e a GENE0004 pode retonar
                           alem do codigo da mensagem um indicador de tipo de mensagem para n�o dar erro.
                           (Envolti - Belli - Chamado 831545)
  
              13/04/2018 - 1 - Tratado Others na gera��o da tabela tbgen erro de sistema
                           2 - Seta Modulo
                           3 - Eliminada mensagem fixas
                           4 - Criada PROCEDURE pc_log para centralizar chamada externa do log
                           5 - Dispare PROCEDURE pc_trata_exec_job para tratar a descri��o de criticas 
                               no sentido de n�o mais utilizar descri��o como condi��o de decis�o
                               Agora com flag de n�o disparar Log pois est� vai criar o log
                           6 - Criado o retorno na gene0004 o pr_intipmsg tipo de mensagem a ser tratada:
                                 1 - Padr�o: Os programas tratam com a regra atual.
                                 2 - Grupo de mensagens para n�o parar o programa: 
                                     Procedures PC_CRPS710 e pc_gera_dados_cyber n�o gera critica.
                                 3 - Grupo de mensagens para n�o parar o programa: 
                                     Procedures pc_job_contab_cessao, PC_CRPS710 e pc_gera_dados_cyber n�o gera critica.    
                          (Envolti - Belli - Chamado REQ0011757 - 13/04/2018)

              23/07/2018 - Projeto Revitaliza��o Sistemas - Busca de quantidade de paralelos e 
                           envio para Paraleliza��o por Coop e Agencia - Andreatta (MOUTs)    


              08/08/2018 - 1 - Estava duplicando log no retorno da crps652 com erro
                           2 - Log do email fora do padr�o -> eliminada a vari�vel vr_dstexto, 
                               ser� utilizada a vr_dscritic para o envio de emails (Alinhado com Carlos)
                          (Ana - Envolti - Chamado REQ0011757)
                           
  .............................................................................. */  

  DECLARE
    
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    vr_cdcooper INTEGER := 3; --CECRED PQ O 652 RODA PRA TODAS COOP A PARTIR DELA 
    vr_dtmvtolt DATE;
    vr_stprogra INTEGER;
    vr_infimsol INTEGER;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_dserro   VARCHAR2(4000);
    -- Excluida variavel vr_tab_erro n�o � utilizada - Chmd REQ0011757 - 13/04/2018  
    vr_exc_erro EXCEPTION;                                      
    
    vr_cdprogra    VARCHAR2(40) := 'CRPS652';
    vr_nomdojob    VARCHAR2(40) := 'JBCYB_GERA_DADOS_CYBER';
    -- Excluida variavel vr_flgerlog n�o � utilizada - Chmd REQ0011757 - 13/04/2018  
    vr_dthoje      DATE := TRUNC(SYSDATE);

    -- Quantidade de JOBS
    vr_qtdejobs NUMBER;

    vr_titulo             VARCHAR2(1000);
    vr_destinatario_email VARCHAR2(500);

    -- Excluida variavel vr_idprglog pois n�o � utilizada - Chmd REQ0011757 - 13/04/2018  
         
    vr_intipmsg   INTEGER := 1; -- pr_intipmsg tipo de mensagem a ser tratada especificamente - Chmd REQ0011757 - 13/04/2018 
    vr_dscrioco VARCHAR2(4000);        -- Variavel para tratar ocorrencia - Chmd REQ0011757 - 13/04/2018 

  --> Controla log proc_batch, para apenas exibir qnd realmente processar informa��o
  PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2 DEFAULT 'E' -- I-in�cio/ F-fim/ O-ocorr�ncia/ E-erro 
                                 ,pr_tpocorre IN NUMBER   DEFAULT 2   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                 ,pr_cdcricid IN NUMBER   DEFAULT 2   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                                 ,pr_tpexecuc IN NUMBER   DEFAULT 2   -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                                 ,pr_dscritic IN VARCHAR2 DEFAULT NULL
                                 ,pr_cdcritic IN VARCHAR2 DEFAULT NULL
                                 ,pr_cdcooper IN VARCHAR2 DEFAULT 3
                                 ,pr_flgsuces IN NUMBER   DEFAULT 1    -- Indicador de sucesso da execu��o  
                                 ,pr_flabrchd IN INTEGER  DEFAULT 0    -- Abre chamado 1 Sim/ 0 N�o
                                 ,pr_textochd IN VARCHAR2 DEFAULT NULL -- Texto do chamado
                                 ,pr_desemail IN VARCHAR2 DEFAULT NULL -- Destinatario do email
                                 ,pr_flreinci IN INTEGER  DEFAULT 0    -- Erro pode reincidir no prog em dias diferentes, devendo abrir chamado
  ) 
  IS
    -- ..........................................................................
    --
    --  Programa : pc_controla_log_batch
    --  Sistema  : Rotina de Log - tabela: tbgen prglog ocorrencia
    --  Sigla    : CYBER
    --  Autor    : Envolti - Belli - Chamado REQ0011757
    --  Data     : 13/04/2018                        Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Chamar a rotina de Log para grava��o de criticas.
    --
    --   Alteracoes: 
    --
    -- .............................................................................
    --
    vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;        
  BEGIN   
    -- Controlar gera��o de log de execu��o dos jobs                                
    CECRED.pc_log_programa(pr_dstiplog      => pr_dstiplog -- I-in�cio/ F-fim/ O-ocorr�ncia/ E-erro 
                          ,pr_tpocorrencia  => pr_tpocorre -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          ,pr_cdcriticidade => pr_cdcricid -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                          ,pr_tpexecucao    => pr_tpexecuc -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                          ,pr_dsmensagem    => pr_dscritic
                          ,pr_cdmensagem    => pr_cdcritic
                          ,pr_cdcooper      => pr_cdcooper 
                          ,pr_flgsucesso    => pr_flgsuces
                          ,pr_flabrechamado => pr_flabrchd -- Abre chamado 1 Sim/ 0 N�o
                          ,pr_texto_chamado => pr_textochd
                          ,pr_destinatario_email => pr_desemail
                          ,pr_flreincidente => pr_flreinci
                          ,pr_cdprograma    => vr_nomdojob
                          ,pr_idprglog      => vr_idprglog
                          );   
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log  
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
  END pc_controla_log_batch;
    
  BEGIN                                                           --- --- --- INICIO DO PROCESSO    
    -- Incluido nome do m�dulo logado - Chmd REQ0011757 - 13/04/2018
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
    
    -- Log de inicio de execucao
    pc_controla_log_batch(pr_dstiplog => 'I');
   
    -- SD#497991
    -- valida��o copiada de TARI0001
    -- Verificar se a data atual � uma data util, se retornar uma data diferente
    -- indica que n�o � um dia util, ent�o deve sair do programa sem executar ou reprogramar
    IF gene0005.fn_valida_dia_util(pr_cdcooper => vr_cdcooper
                                  ,pr_dtmvtolt => vr_dthoje) = vr_dthoje THEN -- SD#497991   
      -- Retorna nome do m�dulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);

      -- Troca da pc_executa_job para pc_trata_exec_job agora trata tipo de critica - Chmd REQ0011757 - 13/04/2018
      -- Indicador se deve gerar log colocado como n�o gerar Log 0 pois esta prc vai gerar - Chmd REQ0011757 - 13/04/2018
      gene0004.pc_trata_exec_job(pr_cdcooper => vr_cdcooper   --> Codigo da cooperativa
                                ,pr_fldiautl => 1   --> Flag se deve validar dia util
                                ,pr_flproces => 1   --> Flag se deve validar se esta no processo
                                ,pr_flrepjob => 1   --> Flag para reprogramar o job
                                ,pr_flgerlog => 0   --> indicador se deve gerar log
                                ,pr_nmprogra => 'pc_gera_dados_cyber' --> Nome do programa que esta sendo executado no job
                                ,pr_intipmsg => vr_intipmsg
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dserro
                                );

      -- se nao retornou critica chama rotina
      IF trim(vr_dserro) IS NULL THEN 
        
        -- Retorna nome do m�dulo logado
        GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);
        
        OPEN btch0001.cr_crapdat(3);
        FETCH btch0001.cr_crapdat  INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;
          
        --Verifica o dia util da cooperativa e caso nao for pula a coop
        vr_dtmvtolt := gene0005.fn_valida_dia_util(pr_cdcooper  => vr_cdcooper
                                                  ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                                  ,pr_tipo      => 'A');                                                    
        IF vr_dtmvtolt <> rw_crapdat.dtmvtolt THEN
           vr_cdcritic := 1213; -- Data da cooperativa diferente da data atual.
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

           --Inclu�da grava��o de log aqui para evitar duplicidade na situa��o de retorno de crps652
           --Log de erro de execucao
           pc_controla_log_batch(pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
           RAISE vr_exc_erro; 
        END IF;              
        -- Retorna nome do m�dulo logado
        GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);                             
         
        -- Buscar quantidade parametrizada de Jobs para este hor�rio
        vr_qtdejobs := gene0001.fn_retorna_qt_paralelo(vr_cdcooper,vr_nomdojob); 
        
        -- Chama rotina que gera dados pro Cyber
        pc_crps652(pr_cdcooper => vr_cdcooper
                  ,pr_cdcoppar => 0
                  ,pr_cdagepar => 0
                  ,pr_idparale => 0
                  ,pr_cdprogra => vr_cdprogra
                  ,pr_qtdejobs => vr_qtdejobs
                  ,pr_stprogra => vr_stprogra
                  ,pr_infimsol => vr_infimsol
                  ,pr_cdcritic => vr_cdcritic 
                  ,pr_dscritic => vr_dscritic);

        IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
           
          -- Abrir chamado
          -- Parte inicial do texto do chamado e do email
          vr_titulo := '<b>Abaixo os erros encontrados no job ' || vr_nomdojob || '</b><br><br>';

          -- Buscar e-mails dos destinatarios do produto cyber
          vr_destinatario_email := gene0001.fn_param_sistema('CRED',vr_cdcooper,'CYBER_RESPONSAVEL');

          -- Dispara rotina de Log - tabela: tbgen prglog ocorrencia
          --substitu�da da vari�vel vr_dstexto (que est� fora dos padr�es) pela dscritic
          pc_controla_log_batch(pr_dscritic => vr_dscritic
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_flgsuces => 0           -- Indicador de sucesso da execu��o
                               ,pr_flabrchd => 1           -- Abrir chamado (Sim=1/Nao=0)
                               ,pr_textochd => vr_titulo
                               ,pr_desemail => vr_destinatario_email
                               ,pr_flreinci => 1           -- Erro pode ocorrer em dias diferentes, devendo abrir chamado
                               ); 
           
           RAISE vr_exc_erro; 
        END IF;
        -- Retorna nome do m�dulo logado
        GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => NULL);  
      
      ELSE
        -- N�o retornar o erro - Chamado 831545 - 16/01/2018
        -- Tratar critica conforme tipo - Chmd REQ0011757 - 13/04/2018
        -- Processo noturno nao finalizado para cooperativa - N�o gera critica
        IF NVL(vr_intipmsg,1) = 1 THEN
          vr_dscritic := vr_dserro;

          --Inclu�da grava��o de log aqui para evitar duplicidade na situa��o de retorno de crps652
          --Log de erro de execucao
          pc_controla_log_batch(pr_cdcritic => nvl(vr_cdcritic,0)
                               ,pr_dscritic => vr_dscritic);
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic := NVL(vr_cdcritic,0);
          -- Buscar a descri��o - Se foi retornado apenas c�digo
          vr_dscrioco := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic) ||
                         ' '  || vr_cdprogra;
          -- Log de erro de execucao
          pc_controla_log_batch(pr_dstiplog => 'O'
                               ,pr_tpocorre => 4
                               ,pr_cdcricid => 0
		                           ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscrioco);
        END IF;
      END IF;

    END IF; 

    -- Log de fim de execucao
    pc_controla_log_batch(pr_dstiplog => 'F');
    
    -- Retorna nome do m�dulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
  EXCEPTION 
    -- Trata Log - Chmd REQ0011757 - 13/04/2018
    WHEN vr_exc_erro THEN  
      vr_cdcritic := NVL(vr_cdcritic,0);
      -- Buscar a descri��o - Se foi retornado apenas c�digo
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic); 

      --Retirada a grava��o do log daqui e inclu�da nas ocorr�ncias para evitar duplicidade
      --Ana - envolti - 08/08/2018
      -- Excluida n�o utilizada GENE0001.pc_gera_erro - Chmd REQ0011757 - 13/04/2018

      ROLLBACK;

    WHEN OTHERS THEN     
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper, 
                                   pr_compleme => vr_dscritic);
      -- Monta mensagens
      vr_cdcritic := 9999; -- 9999 -  Erro nao tratado: 
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                     vr_cdprogra ||
                     '. ' || SQLERRM;

      -- Log de erro de execucao
      pc_controla_log_batch(pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => pr_dscritic);
                     
      -- Excluida n�o utilizada GENE0001.pc_gera_erro - Chmd REQ0011757 - 13/04/2018
                           
      ROLLBACK;                             
        
  END;          
END pc_gera_dados_cyber;
/
