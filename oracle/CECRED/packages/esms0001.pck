CREATE OR REPLACE PACKAGE CECRED.esms0001 AS
  
  PROCEDURE pc_cria_lote_sms(pr_cdproduto   IN tbgen_sms_lote.cdproduto%TYPE
                            ,pr_idtpreme    IN tbgen_sms_lote.idtpreme%TYPE
                            ,pr_dsagrupador IN tbgen_sms_lote.dsagrupador%TYPE DEFAULT NULL
                            ,pr_idlote_sms OUT tbgen_sms_lote.idlote_sms%TYPE
                            ,pr_dscritic   OUT VARCHAR2);
  
  PROCEDURE pc_escreve_sms(pr_idlote_sms  IN tbgen_sms_controle.idlote_sms%TYPE
                          ,pr_cdcooper    IN tbgen_sms_controle.cdcooper%TYPE
                          ,pr_nrdconta    IN tbgen_sms_controle.nrdconta%TYPE
                          ,pr_idseqttl    IN tbgen_sms_controle.idseqttl%TYPE
                          ,pr_dhenvio     IN tbgen_sms_controle.dhenvio_sms%TYPE
                          ,pr_nrddd       IN tbgen_sms_controle.nrddd%TYPE
                          ,pr_nrtelefone  IN tbgen_sms_controle.nrtelefone%TYPE
                          ,pr_cdtarifa    IN tbgen_sms_controle.cdtarifa%TYPE DEFAULT NULL
                          ,pr_dsmensagem  IN tbgen_sms_controle.dsmensagem%TYPE
                          
                          ,pr_idsms      OUT tbgen_sms_controle.idsms%TYPE
                          ,pr_dscritic   OUT VARCHAR2);
  
  PROCEDURE pc_conclui_lote_sms(pr_idlote_sms IN OUT tbgen_sms_controle.idlote_sms%TYPE
                               ,pr_dscritic OUT VARCHAR2);
  
  PROCEDURE pc_dispacha_lotes_sms(pr_dscritic OUT VARCHAR2);
  
  PROCEDURE pc_retorna_lotes_sms(pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_escreve_sms_debaut(pr_cdcooper   IN tbgen_sms_controle.cdcooper%TYPE
                                 ,pr_nrdconta   IN tbgen_sms_controle.nrdconta%TYPE
                                 ,pr_dsmensagem IN tbgen_sms_controle.dsmensagem%TYPE
                                 ,pr_vlfatura   IN craplau.vllanaut%TYPE
                                 ,pr_idmotivo   IN tbgen_motivo.idmotivo%TYPE
                                 ,pr_cdrefere   IN crapatr.cdrefere%TYPE
                                 ,pr_cdhistor   IN crapatr.cdhistor%TYPE
                                 ,pr_idlote_sms IN OUT tbgen_sms_controle.idlote_sms%TYPE
                                 ,pr_dscritic   OUT VARCHAR2);
                                 
  FUNCTION fn_busca_token_zenvia(pr_cdproduto IN NUMBER) RETURN VARCHAR2;

  PROCEDURE pc_atualiza_status_msg_soa (pr_idlotsms   IN tbgen_sms_lote.idlote_sms%TYPE   --> Numero do lote de SMS
                                       ,pr_xmlrequi   IN xmltype);                        --> Xml contendo os retornos dos SMSs enviados

END esms0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.esms0001 AS

  idoperac_envio   CONSTANT VARCHAR2(1)  := 'E';
  idoperac_retorno CONSTANT VARCHAR2(1)  := 'R';
  vr_cdcritic      crapcri.cdcritic%type := 0;
  vr_cdprogra      tbgen_prglog.cdprograma%type := 'ESMS0001';  
  /*---------------------------------------------------------------------------------------------------------------
   Programa: ESMS0001
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
  
   Autor   : Dionathan
   Data    : 14/04/2016                        Ultima atualizacao: 11/02/2019
   
   Objetivo  : Envio de SMS (Package Genérica)
  
   Alteracoes:    
     29/11/2017 - Padronização mensagens (crapcri, pc_gera_log (tbgen))
                - Padronização erros comandos DDL
                - Pc_set_modulo, cecred.pc_internal_exception
                - Tratamento erros others
                 (Ana - Envolti - Chamado 788828)
                 
     11/02/2019 - Ajustar gravacao da vr_dsparame pois estava estourando
                  erro oracle ao acumular no loop (Lucas Ranghetti PRB0040603)
  ---------------------------------------------------------------------------------------------------------------*/

  --> Grava informações para resolver erro de programa/ sistema
  PROCEDURE pc_gera_log(pr_cdcooper      IN PLS_INTEGER           --> Cooperativa
                       ,pr_dstiplog      IN VARCHAR2              --> Tipo Log
                       ,pr_dscritic      IN VARCHAR2 DEFAULT NULL --> Descricao da critica
                       ,pr_cdcriticidade IN tbgen_prglog_ocorrencia.cdcriticidade%type DEFAULT 0
                       ,pr_cdmensagem    IN tbgen_prglog_ocorrencia.cdmensagem%type DEFAULT 0
                       ,pr_ind_tipo_log  IN tbgen_prglog_ocorrencia.tpocorrencia%type DEFAULT 2
                       ,pr_nmarqlog      IN tbgen_prglog.nmarqlog%type DEFAULT NULL) IS
    -----------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_gera_log
    --  Sistema  : Rotina para gravar logs em tabelas
    --  Sigla    : CRED
    --  Autor    : Ana Lúcia E. Volles - Envolti
    --  Data     : Novembro/2017           Ultima atualizacao: 29/11/2017
    --  Chamado  : 788828
    --
    -- Dados referentes ao programa:
    -- Frequencia: Rotina executada em qualquer frequencia.
    -- Objetivo  : Controla gravação de log em tabelas.
    --
    -- Alteracoes:  
    --             
    ------------------------------------------------------------------------------------------------------------   
    vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;
    --
  BEGIN         
    --> Controlar geração de log de execução dos jobs                                
    CECRED.pc_log_programa(pr_dstiplog      => NVL(pr_dstiplog,'E'), 
                           pr_cdcooper      => pr_cdcooper, 
                           pr_tpocorrencia  => pr_ind_tipo_log, 
                           pr_cdprograma    => vr_cdprogra, 
                           pr_tpexecucao    => 2, --job
                           pr_cdcriticidade => pr_cdcriticidade,
                           pr_cdmensagem    => pr_cdmensagem,    
                           pr_dsmensagem    => pr_dscritic,               
                           pr_idprglog      => vr_idprglog,
                           pr_nmarqlog      => pr_nmarqlog);
  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
  END pc_gera_log;

  PROCEDURE pc_cria_lote_sms(pr_cdproduto     IN tbgen_sms_lote.cdproduto%TYPE
                            ,pr_idtpreme      IN tbgen_sms_lote.idtpreme%TYPE
                            ,pr_dsagrupador   IN tbgen_sms_lote.dsagrupador%TYPE DEFAULT NULL
                            ,pr_idlote_sms   OUT tbgen_sms_lote.idlote_sms%TYPE
                            ,pr_dscritic     OUT VARCHAR2) IS
    /*.............................................................................
        Programa: pc_cria_lote_sms
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Dionathan
    Data    : 02/05/2016                    Ultima atualizacao: 29/11/2017
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Criar um novo registro de lote de SMS para envio
    
        Alteracoes:
       29/11/2017 - Padronização mensagens (crapcri, pc_gera_log (tbgen))
                  - Padronização erros comandos DDL
                  - Pc_set_modulo, cecred.pc_internal_exception
                  - Tratamento erros others
                   (Ana - Envolti - Chamado 788828)
    ..............................................................................*/
      
  BEGIN
    -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_cria_lote_sms');
    
    -- Insere um registro novo e retorna o id do lote
    INSERT INTO tbgen_sms_lote x
               (cdproduto
               ,idtpreme
               ,idsituacao
               ,dsagrupador)
        VALUES (pr_cdproduto
               ,pr_idtpreme
               ,'A' -- Aberto
               ,pr_dsagrupador)
     RETURNING idlote_sms
          INTO pr_idlote_sms;
  
    -- Limpa nome do modulo logado - 29/11/2017 - Ch 788828    
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 29/11/2017 - Ch 788828 
      CECRED.pc_internal_exception;

      vr_cdcritic := 1055; --Erro ao criar lote de SMS
      pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' Cdproduto:'||pr_cdproduto
                     ||', idtpreme:'||pr_idtpreme||', idsituacao:A, dsagrupador:'||pr_dsagrupador
                     ||'. '||SQLERRM;

      --Grava tabela de log - Ch 788828
      pc_gera_log(pr_cdcooper      => 3,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(vr_cdcritic,0),
                  pr_ind_tipo_log  => 2);

  END pc_cria_lote_sms;
  
  PROCEDURE pc_escreve_sms(pr_idlote_sms  IN tbgen_sms_controle.idlote_sms%TYPE
                          ,pr_cdcooper    IN tbgen_sms_controle.cdcooper%TYPE
                          ,pr_nrdconta    IN tbgen_sms_controle.nrdconta%TYPE
                          ,pr_idseqttl    IN tbgen_sms_controle.idseqttl%TYPE
                          ,pr_dhenvio     IN tbgen_sms_controle.dhenvio_sms%TYPE
                          ,pr_nrddd       IN tbgen_sms_controle.nrddd%TYPE
                          ,pr_nrtelefone  IN tbgen_sms_controle.nrtelefone%TYPE
                          ,pr_cdtarifa    IN tbgen_sms_controle.cdtarifa%TYPE DEFAULT NULL
                          ,pr_dsmensagem  IN tbgen_sms_controle.dsmensagem%TYPE
                          ,pr_idsms      OUT tbgen_sms_controle.idsms%TYPE
                          ,pr_dscritic   OUT VARCHAR2) IS
  
  /*---------------------------------------------------------------------------------------------------------------
   Programa: ESMS0001
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
  
   Autor   : 
   Data    :                         Ultima atualizacao: 29/11/2017
   
   Objetivo  : Escreve SMS
  
   Alteracoes: 
     29/11/2017 - Padronização mensagens (crapcri, pc_gera_log (tbgen))
                - Padronização erros comandos DDL
                - Pc_set_modulo, cecred.pc_internal_exception
                - Tratamento erros others
                 (Ana - Envolti - Chamado 788828)
  ---------------------------------------------------------------------------------------------------------------*/
  
  BEGIN
    -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_escreve_sms');
    
    INSERT INTO tbgen_sms_controle
               (idlote_sms
               ,idsms
               ,cdcooper
               ,nrdconta
               ,idseqttl
               ,dhenvio_sms
               ,nrddd
               ,nrtelefone
               ,cdtarifa
               ,dsmensagem)
             VALUES
               (pr_idlote_sms
               ,(SELECT NVL(MAX(sms.idsms), 0) + 1
                  FROM tbgen_sms_controle sms
                 WHERE sms.idlote_sms = pr_idlote_sms)
               ,pr_cdcooper
               ,pr_nrdconta
               ,pr_idseqttl
               ,pr_dhenvio
               ,pr_nrddd
               ,pr_nrtelefone
               ,pr_cdtarifa
               ,pr_dsmensagem)
      RETURNING idsms
           INTO pr_idsms;
               
    -- Limpa nome do modulo logado - 29/11/2017 - Ch 788828    
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 29/11/2017 - Ch 788828 
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
  
      vr_cdcritic := 1034;
      pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'SMS no lote '|| pr_idlote_sms 
                     ||'. Cdcooper:'||pr_cdcooper||', nrdconta:'   ||pr_nrdconta
                     ||', idseqttl:'||pr_idseqttl||', dhenvio_sms:'||pr_dhenvio
                     ||', nrddd:'   ||pr_nrddd   ||', nrtelefone:' ||pr_nrtelefone
                     ||', cdtarifa:'||pr_cdtarifa||', dsmensagem:' ||pr_dsmensagem
                     ||'. ' || SQLERRM;

      --Grava tabela de log - Ch 788828
      pc_gera_log(pr_cdcooper      => 3,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(vr_cdcritic,0),
                  pr_ind_tipo_log  => 2);

  END pc_escreve_sms;
  
  PROCEDURE pc_conclui_lote_sms(pr_idlote_sms IN OUT tbgen_sms_controle.idlote_sms%TYPE
                               ,pr_dscritic OUT VARCHAR2) IS
    /*.............................................................................
    
        Programa: pc_dispacha_lote_sms
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Dionathan
        Data    : 14/04/2016                    Ultima atualizacao: 29/11/2017
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para gerar o arquivo de remessa SMS -> ZENVIA
    
        Alteracoes:
          29/11/2017 - Padronização mensagens (crapcri, pc_gera_log (tbgen))
                     - Padronização erros comandos DDL
                     - Pc_set_modulo, cecred.pc_internal_exception
                     - Tratamento erros others
                      (Ana - Envolti - Chamado 788828)
    ..............................................................................*/
    
  BEGIN
    -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_conclui_lote_sms');
    
    UPDATE tbgen_sms_lote lot
       SET lot.idsituacao = 'P' -- Processado
     WHERE lot.idlote_sms = pr_idlote_sms;
     
    pr_idlote_sms := NULL;
    
    -- Limpa nome do modulo logado - 29/11/2017 - Ch 788828    
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 29/11/2017 - Ch 788828 
      CECRED.pc_internal_exception;

      vr_cdcritic := 1056;  --1056 - Erro ao concluir lote de SMS.
      pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' idsituacao:P com idlote_sms:'||pr_idlote_sms
                     ||'. '||SQLERRM;

      --Grava tabela de log - Ch 788828
      pc_gera_log(pr_cdcooper      => 3,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(vr_cdcritic,0),
                  pr_ind_tipo_log  => 2);

  END pc_conclui_lote_sms;
  
  PROCEDURE pc_insere_evento_remessa_sms(pr_idtpreme IN VARCHAR2            --> Tipo da remessa
                                        ,pr_dtmvtolt IN DATE                --> Data da remessa
                                        ,pr_cdesteve IN PLS_INTEGER         --> Estágio do evento
                                        ,pr_flerreve IN PLS_INTEGER         --> Flag de evento de erro
                                        ,pr_dslogeve IN VARCHAR2            --> Log do evento
                                        ,pr_dscritic OUT VARCHAR2) IS       --> Retorno de crítica
  
  /*---------------------------------------------------------------------------------------------------------------
   Programa: ESMS0001
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
  
   Autor   : 
   Data    :                         Ultima atualizacao: 16/05/2018
   
   Objetivo  : 
  
   Alteracoes: 
     29/11/2017 - Padronização mensagens (crapcri, pc_gera_log (tbgen))
                - Padronização erros comandos DDL
                - Pc_set_modulo, cecred.pc_internal_exception
                 (Ana - Envolti - Chamado 788828)
     16/05/2018 - Inclusão e tratamento da exception others
                - Inclusão parâmetros no log
                 (Ana - Envolti - Chamado PRB0040049)
  ---------------------------------------------------------------------------------------------------------------*/
  
  CURSOR cr_crapcrb IS
  SELECT crb.idtpreme
        ,crb.dtmvtolt
    FROM crapcrb crb
   WHERE crb.idtpreme = pr_idtpreme
     AND crb.dtmvtolt = TRUNC(pr_dtmvtolt);
  rw_crapcrb cr_crapcrb%ROWTYPE;
  cr_crapcrb_found BOOLEAN;
  
  vr_dsparame      VARCHAR2(2000);
  
  BEGIN
    -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_insere_evento_remessa_sms');
  
    vr_dsparame := ' - pr_idtpreme:'||pr_idtpreme||
                   ', pr_dtmvtolt:'||pr_dtmvtolt||
                   ', pr_cdesteve:'||pr_cdesteve||
                   ', pr_flerreve:'||pr_flerreve||
                   ', pr_dslogeve:'||pr_dslogeve;
    
  OPEN cr_crapcrb;
  FETCH cr_crapcrb
  INTO rw_crapcrb;
  cr_crapcrb_found := cr_crapcrb%FOUND;
  CLOSE cr_crapcrb;

  -- Cria um registro na CRAPCRB apenas para gerar log
  IF NOT cr_crapcrb_found THEN
    -- Rotina para solicitar o processo de envio / retorno dos arquivos dos Bureaux
    cybe0002.pc_solicita_remessa(pr_dtmvtolt => TRUNC(pr_dtmvtolt)  --> Data da solicitação - Insere apenas 1 registro por dia, por isSO o TRUNC
                                ,pr_idtpreme => pr_idtpreme  --> Tipo da remessa
                                ,pr_dscritic => pr_dscritic); --> Retorno de crítica
      IF pr_dscritic IS NOT NULL THEN
        --Grava tabela de log - Ch 788828
        pc_gera_log(pr_cdcooper      => 3,
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic||vr_dsparame,
                    pr_cdcriticidade => 0,
                    pr_cdmensagem    => nvl(vr_cdcritic,0),
                    pr_ind_tipo_log  => 3);
      END IF;
      -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_insere_evento_remessa_sms');
  
  END IF;

  -- Centralização da gravação dos Eventos da Remessa
  cybe0002.pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme   --> Tipo da remessa
                                   ,pr_dtmvtolt => TRUNC(pr_dtmvtolt) --> Data da remessa
                                   ,pr_nrseqarq => NULL          --> Sequencial do arquivo (Opcional)
                                   ,pr_cdesteve => pr_cdesteve   --> Estágio do evento
                                   ,pr_flerreve => pr_flerreve   --> Flag de evento de erro
                                   ,pr_dslogeve => pr_dslogeve   --> Log do evento
                                   ,pr_dscritic => pr_dscritic); --> Retorno de crítica
  
    IF pr_dscritic IS NOT NULL THEN
      --Grava tabela de log - Ch 788828
      pc_gera_log(pr_cdcooper      => 3,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic||vr_dsparame,
                  pr_cdcriticidade => 0,
                  pr_cdmensagem    => nvl(vr_cdcritic,0),
                  pr_ind_tipo_log  => 3);
    END IF;
  
    -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => NULL);
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 29/11/2017 - Ch 788828 
      CECRED.pc_internal_exception;

      vr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'esms0001.pc_insere_evento_remessa_sms.'||sqlerrm||vr_dsparame;

      --Grava tabela de log - Ch 788828
      pc_gera_log(pr_cdcooper      => 3,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(vr_cdcritic,0),
                  pr_ind_tipo_log  => 2);
    
  END pc_insere_evento_remessa_sms;
  
  FUNCTION fn_nome_arquivo(pr_dtmvtolt   IN tbgen_sms_lote.dtmvtolt%TYPE
                          ,pr_idlote_sms IN tbgen_sms_lote.idlote_sms%TYPE
                          ,pr_idtpreme   IN tbgen_sms_lote.idtpreme%TYPE
                          ,pr_idoperac   IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
  RETURN to_char(pr_dtmvtolt, 'RRRRMMDD_HH24MISS') || '_' ||
                 pr_idlote_sms || '_' ||
                 pr_idtpreme ||
                 CASE pr_idoperac
                   WHEN idoperac_retorno -- Se for retono adiciona "_ret" no fim do nome
                   THEN '_ret'
                   END;
  
  END fn_nome_arquivo;
  
  PROCEDURE pc_processa_arquivo_ftp(pr_nmarquiv IN VARCHAR2              --> Nome arquivo a enviar/ String de busca do arquivo a receber
                                   ,pr_idoperac IN VARCHAR2              --> E - Envio de Arquivo, R - Retorno de arquivo
                                   ,pr_nmdireto IN VARCHAR2              --> Diretório do arquivo a enviar
                                   ,pr_idenvseg IN crapcrb.idtpreme%TYPE --> Indicador de utilizacao de protocolo seguro (SFTP)
                                   ,pr_ftp_site IN VARCHAR2              --> Site de acesso ao FTP
                                   ,pr_ftp_user IN VARCHAR2              --> Usuário para acesso ao FTP
                                   ,pr_ftp_pass IN VARCHAR2              --> Senha para acesso ao FTP
                                   ,pr_ftp_path IN VARCHAR2              --> Pasta no FTP para envio do arquivo
                                   ,pr_dscritic OUT VARCHAR2) IS         --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_envia_arquivo_ftp
    --  Sistema  : AYLLOS
    --  Sigla    : CRED
    --  Autor    : Dionathan Henchel
    --  Data     : Junho/2016                   Ultima atualizacao: 16/05/2018
    --
    -- Dados referentes ao programa: 
    --
    -- Frequencia: -----
    -- Objetivo  : Efetuar envio do arquivo repassado para o FTP enviado como parâmetro
    --
    -- Alteracoes: 
    --    29/11/2017 - Padronização mensagens (crapcri, pc_gera_log (tbgen))
    --               - Padronização erros comandos DDL
    --               - Pc_set_modulo, cecred.pc_internal_exception
    --               - Tratamento erros others
    --                (Ana - Envolti - Chamado 788828)
    --    16/05/2018 - Inclusão parâmetros no log
    --                (Ana - Envolti - Chamado PRB0040049)
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
    
      vr_arquivo_log VARCHAR2(1000); --> Diretório do log do FTP
      vr_script_ftp  VARCHAR2(1000); --> Script FTP
      vr_comand_ftp  VARCHAR2(4000); --> Comando montado do envio ao FTP
      vr_typ_saida   VARCHAR2(3);    --> Saída de erro
      vr_dsparame    VARCHAR2(2000);
    BEGIN
      -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_processa_arquivo_ftp');

      vr_dsparame := ' - pr_nmarquiv:'||pr_nmarquiv||
                     ', pr_idoperac:'||pr_idoperac||
                     ', pr_nmdireto:'||pr_nmdireto||
                     ', pr_idenvseg:'||pr_idenvseg||
                     ', pr_ftp_site:'||pr_ftp_site||
                     ', pr_ftp_user:'||pr_ftp_user||
                     ', pr_ftp_pass:'||pr_ftp_pass||
                     ', pr_ftp_path:'||pr_ftp_path;

      --Chama script específico para conexão de ftp segura
      IF pr_idenvseg = 'S' THEN
        vr_script_ftp := gene0001.fn_param_sistema('CRED',0,'AUTBUR_SCRIPT_SFTP');
      ELSE
        -- Buscar script para conexão FTP
        vr_script_ftp := gene0001.fn_param_sistema('CRED',0,'AUTBUR_SCRIPT_FTP');
      END IF;
      
      -- Gera o diretório do arquivo de log
      vr_arquivo_log := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                               ,pr_cdcooper => 3
                                               ,pr_nmsubdir => '/log') || '/proc_autbur.log'; 

      -- Preparar o comando de conexão e envio ao FTP
      vr_comand_ftp := vr_script_ftp
                    || CASE pr_idoperac WHEN 'E' THEN ' -envia' ELSE ' -recebe' END
                    || ' -srv '          || pr_ftp_site
                    || ' -usr '          || pr_ftp_user
                    || ' -pass '         || pr_ftp_pass
                    || ' -arq '          || CHR(39) || pr_nmarquiv || CHR(39)
                    || ' -dir_local '    || CHR(39) || pr_nmdireto || CHR(39)
                    || ' -dir_remoto '   || CHR(39) || pr_ftp_path || CHR(39)
                    || ' -log ' || vr_arquivo_log;

      -- Chama procedure de envio e recebimento via ftp
      GENE0001.pc_OScommand_Shell(pr_des_comando => vr_comand_ftp
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => pr_dscritic);

      -- Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        RETURN;
      END IF;

      -- Limpa nome do modulo logado - 29/11/2017 - Ch 788828    
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 29/11/2017 - Ch 788828 
        CECRED.pc_internal_exception;

        -- Retorna o erro para a procedure chamadora
        vr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'esms0001.pc_processa_arquivo_ftp. '||SQLERRM||'. '||vr_dsparame;

        --Grava tabela de log mas não pára execução do programa - Ch 788828
        pc_gera_log(pr_cdcooper      => 3,
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic,
                    pr_cdcriticidade => 2,
                    pr_cdmensagem    => nvl(vr_cdcritic,0),
                    pr_ind_tipo_log  => 2);
    END;

  END pc_processa_arquivo_ftp;
  
  PROCEDURE pc_dispacha_lotes_sms(pr_dscritic OUT VARCHAR2) IS
  /*.............................................................................
    
      Programa: pc_dispacha_lotes_sms
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Dionathan
      Data    : 14/04/2016                    Ultima atualizacao: 23/10/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
    
      Objetivo  : Rotina para gerar o arquivo de remessa SMS e enviar para a ZENVIA
    
      Alteracoes: 05/01/2017 - Alteração para que os arquivos gerados gravem o horário correto de 
                               envio, obedecendo o horário cadastrado na tela PARMDA.
                               Corrigido o tipo de layout utilizado. Parametrizado horário limite
                               de envio para as 21:00h. SoftDesk 588454 (Aline).

                29/11/2017 - Padronização mensagens (crapcri, pc_gera_log (tbgen))
                           - Padronização erros comandos DDL
                           - Pc_set_modulo, cecred.pc_internal_exception
                           - Tratamento erros others
                            (Ana - Envolti - Chamado 788828)

                16/05/2018 - Ajuste variáveis vr_dscritic e pr_dscritic
                           - Inclusão parâmetros no log
                            (Ana - Envolti - Chamado PRB0040049)

                23/10/2018 - Inclusão geração arquivos TXT e CFG
                            (Ana - Envolti - Chamado REQ0030877)
  ..............................................................................*/
    
    -- Variável de críticas
    vr_dscritic VARCHAR2(10000);
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Variaveis da procedure
    vr_dhenvio     DATE;
    vr_horalimite  VARCHAR2(10);
    vr_horaatual   VARCHAR2(10);
    vr_horacoop    VARCHAR2(10);
    vr_linha       VARCHAR2(1000);
    vr_dsparame    VARCHAR2(2000);
    
    -- Declarando handle do Arquivo
    vr_nmarquiv    VARCHAR2(100);
    vr_arquivo_rem utl_file.file_type;
    vr_arquivo_cfg utl_file.file_type;
      
    -- Busca os lotes de SMS
    CURSOR cr_lote IS
    SELECT lot.*
          ,pbc.idenvseg
          ,pbc.dssitftp
          ,pbc.dsusrftp
          ,pbc.dspwdftp
          ,pbc.dsdreftp
          ,pbc.dsdirenv
          ,pbc.dsdirret
      FROM tbgen_sms_lote lot
          ,crappbc        pbc
     WHERE lot.idtpreme = pbc.idtpreme
       AND lot.idsituacao = 'P';
    rw_lote cr_lote%ROWTYPE;
    
    -- Busca as mensagens pertencentes ao Lote
    CURSOR cr_sms(pr_idlote_sms IN tbgen_sms_controle.idlote_sms%TYPE) IS
    SELECT sms.*
          ,cop.nmrescop
      FROM tbgen_sms_controle sms
          ,crapcop            cop
     WHERE sms.cdcooper = cop.cdcooper
       AND sms.idlote_sms = pr_idlote_sms;
    rw_sms cr_sms%ROWTYPE;

  BEGIN
    -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_dispacha_lotes_sms');
    
    FOR rw_lote IN cr_lote LOOP
      
      -- Gera o nome do arquivo
      vr_dhenvio := SYSDATE;

      vr_dsparame := ' - pr_dtmvtolt:'||vr_dhenvio||
                     ', pr_idlote_sms:'||rw_lote.idlote_sms||
                     ', pr_idtpreme:'||rw_lote.idtpreme||
                     ', pr_idoperac:'||idoperac_envio;
      
      vr_nmarquiv := fn_nome_arquivo(pr_dtmvtolt   => vr_dhenvio
                                    ,pr_idlote_sms => rw_lote.idlote_sms
                                    ,pr_idtpreme   => rw_lote.idtpreme
                                    ,pr_idoperac   => idoperac_envio); -- Arquivo de envio
      
      --Verifica a hora    
      vr_horalimite := to_char(to_date('21:00', 'hh24:mi'), 'SSSSS');--Horário limite 21:00h
      vr_horaatual  := to_char(to_date(to_char(SYSDATE, 'hh24:mi'), 'hh24:mi'), 'SSSSS');
  
     OPEN cr_sms(pr_idlote_sms => rw_lote.idlote_sms);
     FETCH cr_sms
     INTO rw_sms;
     CLOSE cr_sms;   
      
     vr_horacoop := to_char(to_date(to_char(rw_sms.dhenvio_sms, 'hh24:mi'), 'hh24:mi'), 'SSSSS');

     --Se o horário no momento for menor que a hora parametrizada na cooperativa, envia no horário da cooperativa.
     IF TO_NUMBER(vr_horaatual) < TO_NUMBER(vr_horacoop) THEN
        vr_dhenvio := to_date(to_char(trunc(sysdate), 'DD/MM/YYYY') || ' '  || to_char(rw_sms.dhenvio_sms, 'hh24:mi'), 'DD/MM/YYYY HH24:MI:SS');
     --Se o horário no momento for maior que 21:00h, envia amanhã no horário parametrizado pela cooperativa.   
     ELSE IF TO_NUMBER(vr_horaatual) > TO_NUMBER(vr_horalimite) THEN
             vr_dhenvio := to_date(to_char(trunc(sysdate+1), 'DD/MM/YYYY') || ' '  || to_char(rw_sms.dhenvio_sms, 'hh24:mi'), 'DD/MM/YYYY HH24:MI:SS');
          END IF;
     END IF;


--teste ana daqui req00
      -- REQ0030877
      -- criar arquivo .cfg
      -- Abre arquivo em modo de escrita (W)
      gene0001.pc_abre_arquivo(pr_nmdireto => rw_lote.dsdirenv --> Diretório do arquivo
                              ,pr_nmarquiv => vr_nmarquiv || '.cfg' --> Nome do arquivo
                              ,pr_tipabert => 'W' --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_arquivo_cfg --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic); --> Erro

      -- gravar linha no arquivo
      gene0001.pc_escr_linha_arquivo(vr_arquivo_cfg
                                    ,'1;' || vr_nmarquiv || '.txt' || CHR(13) || CHR(10) ||
                                     '2;' || 'E' || CHR(13) || CHR(10) ||
                                     '3;' || to_char(vr_dhenvio, 'DD/MM/RRRR;HH24:MI') || CHR(13) || CHR(10) ||
                                     '5;' || rw_lote.dsagrupador || CHR(13) || CHR(10) ||
                                     '6;' || to_char(vr_dhenvio + (60 / 60 / 24), 'DD/MM/RRRR;HH24:MI') || CHR(13) || CHR(10) ||
                                     '7;' || vr_nmarquiv || '_ret.txt' || CHR(13) || CHR(10));
      
      -- criar arquivo .txt
      -- Abre arquivo em modo de escrita (W)
      gene0001.pc_abre_arquivo(pr_nmdireto => rw_lote.dsdirenv --> Diretório do arquivo
                              ,pr_nmarquiv => vr_nmarquiv || '.txt' --> Nome do arquivo
                              ,pr_tipabert => 'W' --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_arquivo_rem --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic); --> Erro
      
      -- Loop que percorre os SMS do lote
      FOR rw_sms IN cr_sms(pr_idlote_sms => rw_lote.idlote_sms) LOOP

        -- Construir a linha do arquivo - LAYOUT E -> ZENVIA
        -- LAYOUT E -> celular;msg;id;remetente;dataEnvio
        vr_linha := '55' || rw_sms.nrddd || rw_sms.nrtelefone || ';' || -- Celular
                    TRIM(RPAD(REPLACE(rw_sms.dsmensagem,';','.'), 160-LENGTH(rw_sms.nmrescop),' ')) || ';' || -- mensagem de texto (deve possuir no maximo 160 caracteres considerando o remetente)
                    rw_sms.idsms || ';' || -- Id interno (Lote/SMS)
                    rw_sms.nmrescop || ';' || -- Remetente
                   -- to_char(rw_sms.dhenvio_sms, 'dd/mm/yyyy hh24:mi:ss') || CHR(13); -- Data do envio
                    to_char(vr_dhenvio, 'DD/MM/RRRR HH24:MI:SS') || CHR(13);
        -- Gravar linha no arquivo                    

        GENE0001.pc_escr_linha_arquivo(vr_arquivo_rem,vr_linha);

      END LOOP; -- Fim do loop que percorre os SMS do lote
--teste ana ate aqui req00
      
      -- Fechar os arquivos
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arquivo_cfg);
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arquivo_rem);
      
      -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_dispacha_lotes_sms');

      -- Envia os dois arquivos via FTP (.txt e .cfg)
      FOR i IN 1..2 LOOP
        -- Envio via FTP
        pc_processa_arquivo_ftp(pr_nmarquiv => vr_nmarquiv || CASE i WHEN 1 THEN '.txt' ELSE '.cfg' END --> Nome arquivo a enviar
                               ,pr_idoperac => 'E'                --> Envio de arquivo
                               ,pr_nmdireto => rw_lote.dsdirenv   --> Diretório do arquivo a enviar
                               ,pr_idenvseg => rw_lote.idenvseg   --> Indicador de utilizacao de protocolo seguro (SFTP)
                               ,pr_ftp_site => rw_lote.dssitftp   --> Site de acesso ao FTP
                               ,pr_ftp_user => rw_lote.dsusrftp   --> Usuário para acesso ao FTP
                               ,pr_ftp_pass => rw_lote.dspwdftp   --> Senha para acesso ao FTP
                               ,pr_ftp_path => rw_lote.dsdreftp   --> Pasta no FTP para envio do arquivo
                               ,pr_dscritic => vr_dscritic);      --> Retorno de crítica
        
        --Já gravou tabela de log na pc_processa_arquivo_ftp - Ch 788828
        IF vr_dscritic IS NOT NULL THEN
          EXIT;
        END IF;
      END LOOP;
      
      -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_dispacha_lotes_sms');

      -- Se enviou com sucesso
      IF vr_dscritic IS NULL THEN
        
        BEGIN
          UPDATE tbgen_sms_lote lot
             SET lot.idsituacao = 'E' -- Em espera de Retorno
                ,lot.dtmvtolt = vr_dhenvio
           WHERE lot.idlote_sms = rw_lote.idlote_sms;
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 29/11/2017 - Ch 788828 
            CECRED.pc_internal_exception;
         
            vr_cdcritic := 1035;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'tbgen_sms_lote: '||
                           'idsituacao:E, dtmvtolt:'||vr_dhenvio||
                           ' com idlote_sms:'||rw_lote.idlote_sms||'. '||SQLERRM;

            --Grava tabela de log - Ch 788828
            pc_gera_log(pr_cdcooper      => 3,
                        pr_dstiplog      => 'E',
                        pr_dscritic      => vr_dscritic,
                        pr_cdcriticidade => 0,
                        pr_cdmensagem    => vr_cdcritic,
                        pr_ind_tipo_log  => 3);

            vr_cdcritic := NULL;
            vr_dscritic := NULL;
        END;

        esms0001.pc_insere_evento_remessa_sms(pr_idtpreme => rw_lote.idtpreme --> Bureaux passado
                                             ,pr_dtmvtolt => vr_dhenvio --> Data passada
                                             ,pr_cdesteve => 1                --> Agendamento
                                             ,pr_flerreve => 0                --> Não houve erro
                                             ,pr_dslogeve => 'Arquivo de remessa '||vr_nmarquiv||'.txt  enviada com sucesso em '||to_char(SYSDATE,'dd/mm/yyyy')||' as '||to_char(SYSDATE,'hh24:mi:ss')
                                             ,pr_dscritic => pr_dscritic); --> Retorno de crítica
         
      ELSE -- Se ocorreu erro cancela o lote
      
        BEGIN
        UPDATE tbgen_sms_lote lot
           SET lot.idsituacao = 'C' --Cancelado
         WHERE lot.idlote_sms = rw_lote.idlote_sms;
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 29/11/2017 - Ch 788828 
            CECRED.pc_internal_exception;
         
            vr_cdcritic := 1035;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'tbgen_sms_lote: '||
                           'idsituacao:C com idlote_sms:'||rw_lote.idlote_sms||'. '||SQLERRM;

            --Grava tabela de log - Ch 788828
            pc_gera_log(pr_cdcooper      => 3,
                        pr_dstiplog      => 'E',
                        pr_dscritic      => vr_dscritic,
                        pr_cdcriticidade => 2,
                        pr_cdmensagem    => vr_cdcritic,
                        pr_ind_tipo_log  => 2);

            vr_cdcritic := NULL;
            vr_dscritic := NULL;
        END;
         
        esms0001.pc_insere_evento_remessa_sms(pr_idtpreme => rw_lote.idtpreme --> Bureaux passado
                                             ,pr_dtmvtolt => vr_dhenvio       --> Data passada
                                             ,pr_cdesteve => 9                --> Cancelado
                                             ,pr_flerreve => 1                --> Erro
                                             ,pr_dslogeve => 'Remessa '||rw_lote.idtpreme||' cancelada por movito de erro em '||to_char(SYSDATE,'dd/mm/yyyy')||' as '||to_char(SYSDATE,'hh24:mi:ss')
                                             ,pr_dscritic => pr_dscritic); --> Retorno de crítica
        
        --Se ocorreu erro, já gravou tabela de log dentro da pc_insere_evento_remessa_sms - Ch 788828
      END IF;
      
      -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_dispacha_lotes_sms');

    END LOOP;
     
    -- Limpa nome do modulo logado - 29/11/2017 - Ch 788828    
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 29/11/2017 - Ch 788828 
      CECRED.pc_internal_exception;

      vr_cdcritic := 1057;  --1057 - Erro ao despachar lote de SMS
      pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' '||SQLERRM||vr_dsparame;

      --Grava tabela de log - Ch 788828
      pc_gera_log(pr_cdcooper      => 3,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(vr_cdcritic,0),
                  pr_ind_tipo_log  => 2);

  END pc_dispacha_lotes_sms;
  
  PROCEDURE pc_retorna_lotes_sms(pr_dscritic OUT VARCHAR2) IS
    /*.............................................................................
    
        Programa: pc_retorna_lotes_sms
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Dionathan
        Data    : 14/04/2016                    Ultima atualizacao: 16/05/2018
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para buscar os arquivos de retorno de SMS no ftp da ZENVIA
    
        Alteracoes:
              26/10/2016 - Incluso verificação de existencia do arquivo, antes da abertura
                           do mesmo. Estavam ocorrendo erros no log de produção por tentar
                           abrir arquivos ainda não recebidos. (Renato Darosci - Supero)
                           
              29/11/2017 - Padronização mensagens (crapcri, pc_gera_log (tbgen))
                         - Padronização erros comandos DDL
                         - Pc_set_modulo, cecred.pc_internal_exception
                         - Tratamento erros others
                          (Ana - Envolti - Chamado 788828)
                          
              16/05/2018 - Alterar campo recebido no arquivo paras atualizar status na tabela tbgen_sms_lote
                         - No 1o layout, o status era recebido no 5o campo do arquivo de retorno.
                         - No início de 2017, esse layout foi alterado e o status passou a ser 
                           recebido no 6o campo do arquivo de retorno.
                         - Ajuste variáveis vr_dscritic e pr_dscritic
                         - Inclusão parâmetros no log
                          (Ana - Envolti - Chamado PRB0040049)
    ..............................................................................*/
    
    -- Variável de críticas
    vr_dscritic VARCHAR2(10000);
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Variaveis da procedure
    vr_linha VARCHAR2(1000);
    
    -- Declarando handle do Arquivo
    vr_nmarquiv    VARCHAR2(200);
    vr_arquivo_ret utl_file.file_type;
    vr_nmarqenc    VARCHAR2(4000);        --> Lista de arquivos encontrados
    vr_dsparame    VARCHAR2(2000);
    -- Tabela de String
    vr_tab_string        gene0002.typ_split;
      
    -- Busca os lotes de SMS
    CURSOR cr_lote IS
    SELECT lot.*
          ,pbc.idenvseg
          ,pbc.dssitftp
          ,pbc.dsusrftp
          ,pbc.dspwdftp
          ,pbc.dsdrrftp
          ,pbc.dsdirret
      FROM tbgen_sms_lote lot
          ,crappbc        pbc
     WHERE lot.idtpreme = pbc.idtpreme
       AND lot.idsituacao = 'E'  --Em espera de Retorno
       AND (SYSDATE-lot.dtmvtolt) <= 2; -- No máximo até 2 dias atrás

    rw_lote cr_lote%ROWTYPE;
    
  BEGIN
    -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_retorna_lotes_sms');
    
    FOR rw_lote IN cr_lote LOOP
      
      vr_dsparame := ' - pr_dtmvtolt:'||rw_lote.dtmvtolt||
                     ', pr_idlote_sms:'||rw_lote.idlote_sms||
                     ', pr_idtpreme:'||rw_lote.idtpreme||
                     ', pr_idoperac:'||idoperac_retorno||
                     ', pr_nmdireto:'||rw_lote.dsdirret||
                     ', pr_idenvseg:'||rw_lote.idenvseg||
                     ', pr_ftp_site:'||rw_lote.dssitftp||
                     ', pr_ftp_user:'||rw_lote.dsusrftp||
                     ', pr_ftp_pass:'||rw_lote.dspwdftp||
                     ', pr_ftp_path:'||rw_lote.dsdrrftp;
    
      vr_nmarquiv := fn_nome_arquivo(pr_dtmvtolt   => rw_lote.dtmvtolt
                                    ,pr_idlote_sms => rw_lote.idlote_sms
                                    ,pr_idtpreme   => rw_lote.idtpreme
                                    ,pr_idoperac   => idoperac_retorno) || '.txt'; -- Arquivo de retorno

      --Grava log na rotina chamada
      pc_processa_arquivo_ftp(pr_nmarquiv => vr_nmarquiv      --> Nome arquivo a receber
                             ,pr_idoperac => idoperac_retorno --> Envio de arquivo
                             ,pr_nmdireto => rw_lote.dsdirret||'/temp' --> Diretório do arquivos de retorno
                             ,pr_idenvseg => rw_lote.idenvseg --> Indicador de utilizacao de protocolo seguro (SFTP)
                             ,pr_ftp_site => rw_lote.dssitftp --> Site de acesso ao FTP
                             ,pr_ftp_user => rw_lote.dsusrftp --> Usuário para acesso ao FTP
                             ,pr_ftp_pass => rw_lote.dspwdftp --> Senha para acesso ao FTP
                             ,pr_ftp_path => rw_lote.dsdrrftp --> Pasta no FTP para retorno do arquivo
                             ,pr_dscritic => vr_dscritic);    --> Retorno de crítica

      -- Se ocorreu erro ao receber o arquivo pula para o proximo lote
      IF vr_dscritic IS NOT NULL THEN

        --Já gravou tabela de log na pc_processa_arquivo_ftp - Ch 788828
        esms0001.pc_insere_evento_remessa_sms(pr_idtpreme => rw_lote.idtpreme --> Bureaux passado
                                             ,pr_dtmvtolt => rw_lote.dtmvtolt --> Data passada
                                             ,pr_cdesteve => 9                --> Cancelado
                                             ,pr_flerreve => 1                --> Erro
                                             ,pr_dslogeve => 'Retorno do lote '||vr_nmarquiv||' cancelado por movito de erro em '||to_char(SYSDATE,'dd/mm/yyyy')||' as '||to_char(SYSDATE,'hh24:mi:ss') ||': '||vr_dscritic
                                             ,pr_dscritic => pr_dscritic); --> Retorno de crítica

        --Se ocorreu erro, já gravou tabela de log dentro da pc_insere_evento_remessa_sms - Ch 788828
        vr_cdcritic := NULL;
        vr_dscritic := NULL;
        CONTINUE;
      END IF;
      
      -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_retorna_lotes_sms');

      -- Agora, listamos o arquivo baixado no diretório
      gene0001.pc_lista_arquivos(pr_path     => rw_lote.dsdirret||'/temp' --> Dir busca
                                ,pr_pesq     => vr_nmarquiv   --> Nome do arquivo (Chave de busca)
                                ,pr_listarq  => vr_nmarqenc   --> Arquivo encontrado (Só deve encontrar 1 arquivo, pois a chave de busca já é o nome completo)
                                ,pr_des_erro => pr_dscritic); --> Possível erro
      
      -- Se ocorreu erro pula para o proximo lote
      IF pr_dscritic IS NOT NULL THEN

        --Grava tabela de log mas não pára execução do programa - Ch 788828
        pc_gera_log(pr_cdcooper      => 3,
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic||vr_dsparame,
                    pr_cdcriticidade => 0,
                    pr_cdmensagem    => nvl(vr_cdcritic,0),
                    pr_ind_tipo_log  => 3);

        esms0001.pc_insere_evento_remessa_sms(pr_idtpreme => rw_lote.idtpreme --> Bureaux passado
                                             ,pr_dtmvtolt => rw_lote.dtmvtolt --> Data passada
                                             ,pr_cdesteve => 9                --> Cancelado
                                             ,pr_flerreve => 1                --> Erro
                                             ,pr_dslogeve => 'Retorno do lote '||vr_nmarquiv||' cancelado por movito de erro em '||to_char(SYSDATE,'dd/mm/yyyy')||' as '||to_char(SYSDATE,'hh24:mi:ss') ||': '||vr_dscritic
                                             ,pr_dscritic => pr_dscritic); --> Retorno de crítica

        vr_cdcritic := NULL;
        --Se ocorreu erro, já gravou tabela de log dentro da pc_insere_evento_remessa_sms - Ch 788828
        vr_dscritic := NULL;
        CONTINUE;
      END IF;
      
      -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_retorna_lotes_sms');
      
      -- Deve verificar se o arquivo foi encontrado antes de tentar abrir o mesmo
      -- O arquivo não ser encontrado não caracteriza erro necessariamente, pois pode
      -- ser apenas que ele ainda não tenha sido disponibilizado devido ao horário
      IF vr_nmarqenc IS NULL THEN
        -- Neste caso, deve pular para o próximo
        CONTINUE;
      END IF;

      -- Abrir Arquivo
      gene0001.pc_abre_arquivo(pr_nmdireto => rw_lote.dsdirret||'/temp' --> Diretorio do arquivo
                              ,pr_nmarquiv => vr_nmarquiv      --> Nome do arquivo
                              ,pr_tipabert => 'R'              --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_arquivo_ret   --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);    --> Erro
      
      -- Se ocorreu erro pula para o proximo lote
      IF vr_dscritic IS NOT NULL THEN
        --Grava tabela de log mas não pára execução do programa - Ch 788828
        pc_gera_log(pr_cdcooper      => 3,
                    pr_dstiplog      => 'E',
                    pr_dscritic      => vr_dscritic||vr_dsparame,
                    pr_cdcriticidade => 0,
                    pr_cdmensagem    => nvl(vr_cdcritic,0),
                    pr_ind_tipo_log  => 3);

        vr_cdcritic := NULL;
        vr_dscritic := NULL;

        esms0001.pc_insere_evento_remessa_sms(pr_idtpreme => rw_lote.idtpreme --> Bureaux passado
                                             ,pr_dtmvtolt => rw_lote.dtmvtolt --> Data passada
                                             ,pr_cdesteve => 9                --> Cancelado
                                             ,pr_flerreve => 1                --> Erro
                                             ,pr_dslogeve => 'Retorno do lote '||vr_nmarquiv||' cancelado por movito de erro em '||to_char(SYSDATE,'dd/mm/yyyy')||' as '||to_char(SYSDATE,'hh24:mi:ss') ||': '||vr_dscritic
                                             ,pr_dscritic => pr_dscritic); --> Retorno de crítica

        --Se ocorreu erro, já gravou tabela de log dentro da pc_insere_evento_remessa_sms - Ch 788828
        vr_dscritic := NULL;
        CONTINUE;
      END IF;

      -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_retorna_lotes_sms');

      -- Se o arquivo estiver aberto
      IF utl_file.IS_OPEN(vr_arquivo_ret) THEN
        
        -- Percorrer as linhas do arquivo
        BEGIN
          LOOP
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_arquivo_ret
                                        ,pr_des_text => vr_linha);                                        
            
            -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
            GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_retorna_lotes_sms');

            -- Quebrar Informacoes da String e colocar no vetor
            vr_linha := REPLACE(vr_linha,chr(13),'');          
            vr_tab_string := gene0002.fn_quebra_string(vr_linha,';');
                  
            -- vr_tab_string(3) ISSO AQUI PEGA O IDENTIFICADOR DO SMS
                  
            -- 1 - Agendado
            -- 2 - Enviado
            -- 3 - Entregue
            -- 4 - Nao recebido
            -- 5 - Fora do plano de numeracao
            -- 6 - Blacklist
            -- 7 - Limpeza preditiva
            -- 8 - Erro
            -- 9 - Cancelado
                 
            --Chamado PRB0040049 - Alterar campo recebido no arquivo a ser atualizado na tabela tbgen_sms_controle
            --No 1o layout, o status era recebido no 5o campo do arquivo de retorno.
            --No início de 2017, esse layout foi alterado e o status passou a ser enviado no 6o campo
            BEGIN
              UPDATE tbgen_sms_controle sms
                 SET sms.cdretorno = to_number(vr_tab_string(6)) -- Código do retorno
               WHERE sms.idlote_sms = rw_lote.idlote_sms
                 AND sms.idsms = to_number(vr_tab_string(3));
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 29/11/2017 - Ch 788828 
                CECRED.pc_internal_exception;

                vr_cdcritic := 1035;
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'tbgen_sms_controle. '||
                               'cdretorno:'||vr_tab_string(6)||
                               ' com idlote_sms:'||rw_lote.idlote_sms||
                               ', idsms:'||vr_tab_string(3)||'. '||SQLERRM;

                --Grava tabela de log mas não pára execução do programa - Ch 788828
                pc_gera_log(pr_cdcooper      => 3,
                            pr_dstiplog      => 'E',
                            pr_dscritic      => vr_dscritic,
                            pr_cdcriticidade => 2,
                            pr_cdmensagem    => vr_cdcritic,
                            pr_ind_tipo_log  => 2);

                vr_cdcritic := NULL;
                vr_dscritic := NULL;
            END;
                
          END LOOP; -- loop do arquivo
            
        EXCEPTION
          WHEN no_data_found THEN
            -- Acabou a leitura
            NULL;
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 29/11/2017 - Ch 788828 
            CECRED.pc_internal_exception;

            esms0001.pc_insere_evento_remessa_sms(pr_idtpreme => rw_lote.idtpreme --> Bureaux passado
                                                 ,pr_dtmvtolt => rw_lote.dtmvtolt --> Data passada
                                                 ,pr_cdesteve => 9                --> Cancelado
                                                 ,pr_flerreve => 1                --> Erro
                                                 ,pr_dslogeve => 'Retorno do lote '||vr_nmarquiv||' cancelado por movito de erro em '||to_char(SYSDATE,'dd/mm/yyyy')||' as '||to_char(SYSDATE,'hh24:mi:ss') ||': '||vr_dscritic
                                                 ,pr_dscritic => pr_dscritic); --> Retorno de crítica

            --Se ocorreu erro, já gravou tabela de log dentro da pc_insere_evento_remessa_sms - Ch 788828
            vr_dscritic := NULL;
            CONTINUE;
        END;
            
        -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_retorna_lotes_sms');

        BEGIN            
        UPDATE tbgen_sms_lote lot
           SET lot.idsituacao = 'R'
              ,lot.dhretorno = SYSDATE
         WHERE lot.idlote_sms = rw_lote.idlote_sms;
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 29/11/2017 - Ch 788828 
            CECRED.pc_internal_exception;

            vr_cdcritic := 1035;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbgen_sms_lote. '||
                           'idsituacao:R, dhretorno:'||SYSDATE||
                           ' com idlote_sms:'||rw_lote.idlote_sms||'. '||SQLERRM;

            --Grava tabela de log mas não pára execução do programa - Ch 788828
            pc_gera_log(pr_cdcooper      => 3,
                        pr_dstiplog      => 'E',
                        pr_dscritic      => vr_dscritic,
                        pr_cdcriticidade => 2,
                        pr_cdmensagem    => vr_cdcritic,
                        pr_ind_tipo_log  => 2);

            vr_cdcritic := NULL;
            vr_dscritic := NULL;
        END;
        
        esms0001.pc_insere_evento_remessa_sms(pr_idtpreme => rw_lote.idtpreme --> Bureaux passado
                                             ,pr_dtmvtolt => rw_lote.dtmvtolt --> Data passada
                                             ,pr_cdesteve => 1                --> Agendamento
                                             ,pr_flerreve => 0                --> Não houve erro
                                             ,pr_dslogeve => 'Arquivo de retorno '||vr_nmarquiv||' recebido com sucesso em '||to_char(SYSDATE,'dd/mm/yyyy')||' as '||to_char(SYSDATE,'hh24:mi:ss')
                                             ,pr_dscritic => pr_dscritic); --> Retorno de crítica

        --Se ocorreu erro, já gravou tabela de log dentro da pc_insere_evento_remessa_sms - Ch 788828
      END IF; -- IF arquivo aberto          
            
      -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_retorna_lotes_sms');
            
      -- Se o arquivo estiver aberto
      IF  utl_file.IS_OPEN(vr_arquivo_ret) THEN
        -- Fechar os arquivos
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arquivo_ret);
      END IF;
      
      -- Tira o arquivo retorno da pasta temp
      gene0001.pc_OScommand_Shell('mv ' || rw_lote.dsdirret || '/temp' || '/' || vr_nmarqenc || ' ' ||
                                           rw_lote.dsdirret || '/' || vr_nmarqenc);
      
    END LOOP;
     
    -- Limpa nome do modulo logado - 29/11/2017 - Ch 788828    
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 29/11/2017 - Ch 788828 
      CECRED.pc_internal_exception;

      vr_cdcritic := 1060; --Erro ao processar retorno dos lotes de SMS
      pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' '|| SQLERRM||vr_dsparame;

      --Grava tabela de log - Ch 788828
      pc_gera_log(pr_cdcooper      => 3,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(vr_cdcritic,0),
                  pr_ind_tipo_log  => 2);

  END pc_retorna_lotes_sms;
  
  PROCEDURE pc_escreve_sms_debaut(pr_cdcooper   IN tbgen_sms_controle.cdcooper%TYPE
                                 ,pr_nrdconta   IN tbgen_sms_controle.nrdconta%TYPE
                                 ,pr_dsmensagem IN tbgen_sms_controle.dsmensagem%TYPE
                                 ,pr_vlfatura   IN craplau.vllanaut%TYPE
                                 ,pr_idmotivo   IN tbgen_motivo.idmotivo%TYPE
                                 ,pr_cdrefere   IN crapatr.cdrefere%TYPE
                                 ,pr_cdhistor   IN crapatr.cdhistor%TYPE
                                 ,pr_idlote_sms IN OUT tbgen_sms_controle.idlote_sms%TYPE
                                 ,pr_dscritic   OUT VARCHAR2) IS
  /* ...........................................................................................................

      Programa: pc_processa_retorno_sms
      Sistema : CECRED
      Autor   : Dionathan Henchel
      Data    : Maio/15.                    Ultima atualizacao: 16/05/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina para criar registro de sms para débito automático

      Observacao: -----

      Alteracoes: 
              29/11/2017 - Padronização mensagens (crapcri, pc_gera_log (tbgen))
                         - Padronização erros comandos DDL
                         - Pc_set_modulo, cecred.pc_internal_exception
                         - Tratamento erros others
                         - Correção nome variável vr_cdhistor
                          (Ana - Envolti - Chamado 788828)
              16/05/2018 - Criada exception vr_exc_saida:
                           - Os erros desviavam pra essa exception mas a mesma não existia no programa, 
                           - sendo assim, caía em others e parava a execução
                           - Agora, com a exception tratada: 
                             - Os logs são feitos dentro das rotinas chamadas ou na ocorrência deste programa
                             - Ex.: cdcritic = 1;
                             - Criada a exception apenas para sair do programa e não cair em others
                           - Inclusão parâmetros no log
                          (Ana - Envolti - Chamado PRB0040049)
              19/06/2018 - Será mantida a chamada da rotina TARI0001.pc_carrega_dados_tar_vigente, pois 
                           em conversa com Ranghetti e Lucas, não cobra tarifa por sms, é um pacote que 
                           o cooperado tem de sms. Sendo assim, deve apenas incluir nvl no insert do campo vltarifa 
                           na tabela tbconv_motivo_msg para .
                           Cogitou-se substituir a chamada pela TARI0001.pc_carrega_dados_tarifa_cobr - cancelado.
                           (Ana - Envolti - PRB0040057)
 	 ...........................................................................................................*/																								
    
    vr_idsms tbgen_sms_controle.idsms%TYPE;
    
    vr_cdhistor INTEGER;  --Codigo Historico
    vr_cdhisest NUMBER;   --Historico Estorno
    vr_vltarifa NUMBER;   --Valor tarifa
    vr_dtdivulg DATE;     --Data Divulgacao
    vr_dtvigenc DATE;     --Data Vigencia
    vr_cdfvlcop INTEGER;  --Codigo faixa valor cooperativa
    vr_cdcritic INTEGER;  --Codigo Critica
    vr_dscritic VARCHAR2(4000);  --Descricao Critica
    vr_tab_erro GENE0001.typ_tab_erro; --Tabela erros
    vr_dsparame VARCHAR2(2000);
   
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
      
    CURSOR cr_debaut IS
      SELECT tfc.cdcooper
            ,tfc.nrdconta
            ,tfc.idseqttl
            ,TRUNC(SYSDATE) + (prm.hrenvio_sms / 60 / 60 / 24) dhenvio
            ,tfc.nrdddtfc
            ,tfc.nrtelefo
            ,CASE
               WHEN prm.flgcobra_tarifa = 1 THEN
                DECODE(ass.inpessoa, 1, prm.cdtarifa_pf, prm.cdtarifa_pj)
             END cdtarifa
            ,prm.flgenvia_sms
            ,prm.flgcobra_tarifa
            ,cop.nmrescop
        FROM crapcop         cop
            ,crapass         ass
            ,craptfc         tfc
            ,tbgen_sms_param prm
       WHERE ass.cdcooper = cop.cdcooper
         AND ass.cdcooper = tfc.cdcooper
         AND ass.nrdconta = tfc.nrdconta
         AND prm.cdcooper = tfc.cdcooper
         AND tfc.cdcooper = pr_cdcooper
         AND tfc.nrdconta = pr_nrdconta
         AND tfc.flgacsms = 1;
    rw_debaut cr_debaut%ROWTYPE;
    
    rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
    
    --Rowid lancamento tarifa
    vr_rowid_craplat ROWID;
  
  BEGIN
    -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_escreve_sms_debaut');

    vr_dsparame := ' - pr_cdcooper:' ||pr_cdcooper  ||
                   ', pr_nrdconta:'  ||pr_nrdconta  ||
                   ', pr_dsmensagem:'||pr_dsmensagem||
                   ', pr_vlfatura:'  ||pr_vlfatura  ||
                   ', pr_idmotivo:'  ||pr_idmotivo  ||
                   ', pr_cdrefere:'  ||pr_cdrefere  ||
                   ', pr_cdhistor:'  ||pr_cdhistor  ||
                   ', pr_idlote_sms:'||pr_idlote_sms;
  
    OPEN cr_debaut;
    FETCH cr_debaut
      INTO rw_debaut;
    CLOSE cr_debaut;
    
    -- Se cooperativa não envia sms retorna sem gravar registro de sms
    IF rw_debaut.flgenvia_sms <> 1 THEN
      RETURN;
    END IF;
  
    -- Se telefone estiver vazio retorna sem gravar registro de sms
    IF rw_debaut.nrtelefo IS NULL THEN
      RETURN;
    END IF;

    -- Se ainda não criou lote
    IF pr_idlote_sms IS NULL THEN
      --Grava tbgen_sms_lote
      --Grava log na rotina chamada
      esms0001.pc_cria_lote_sms(pr_cdproduto     => 10 -- Débito Automático 
                               ,pr_idtpreme      => 'SMSDEBAUT'
                               ,pr_idlote_sms    => pr_idlote_sms
                               ,pr_dsagrupador   => rw_debaut.nmrescop
                               ,pr_dscritic      => pr_dscritic);
    
      IF pr_dscritic IS NOT NULL THEN
        --Ja gravou tabela de log dentro da pc_cria_lote_sms - Ch 788828
        RAISE vr_exc_saida;
      END IF;
    END IF;

    -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_escreve_sms_debaut');
  
    --Grava tbgen_sms_controle
    --Grava log na rotina chamada
    esms0001.pc_escreve_sms(pr_idlote_sms => pr_idlote_sms
                           ,pr_cdcooper   => rw_debaut.cdcooper
                           ,pr_nrdconta   => rw_debaut.nrdconta
                           ,pr_idseqttl   => rw_debaut.idseqttl
                           ,pr_dhenvio    => rw_debaut.dhenvio
                           ,pr_nrddd      => rw_debaut.nrdddtfc
                           ,pr_nrtelefone => rw_debaut.nrtelefo
                           ,pr_cdtarifa   => rw_debaut.cdtarifa
                           ,pr_dsmensagem => pr_dsmensagem
                           ,pr_idsms      => vr_idsms
                           ,pr_dscritic   => pr_dscritic);
                           
    IF pr_dscritic IS NOT NULL THEN
      --Já gravou tabela de log dentro pc_escreve_sms - Ch 788828
        RAISE vr_exc_saida;
    END IF;
    
    -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_escreve_sms_debaut');
    
    IF rw_debaut.flgcobra_tarifa = 1 THEN
      -- Busca valor da tarifa - utilizar essa rotina quando, por exemplo, o cooperado, pede para ser
      -- avisado que está sem limite para pagar um debito automático
      TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => rw_debaut.cdcooper  --Codigo Cooperativa
                                            ,pr_cdtarifa  => rw_debaut.cdtarifa  --Codigo Tarifa
                                            ,pr_vllanmto  => 0            --Valor Lancamento
                                            ,pr_cdprogra  => NULL         --Codigo Programa
                                            ,pr_cdhistor  => vr_cdhistor  --Codigo Historico da tarifa
                                            ,pr_cdhisest  => vr_cdhisest  --Historico Estorno
                                            ,pr_vltarifa  => vr_vltarifa  --Valor tarifa
                                            ,pr_dtdivulg  => vr_dtdivulg  --Data Divulgacao
                                            ,pr_dtvigenc  => vr_dtvigenc  --Data Vigencia
                                            ,pr_cdfvlcop  => vr_cdfvlcop  --Codigo faixa valor cooperativa
                                            ,pr_cdcritic  => vr_cdcritic  --Codigo Critica
                                            ,pr_dscritic  => vr_dscritic  --Descricao Critica
                                            ,pr_tab_erro  => vr_tab_erro); --Tabela erros
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Se possui erro no vetor
        IF vr_tab_erro.Count > 0 THEN
          vr_cdcritic:= vr_tab_erro(1).cdcritic;
          pr_dscritic:= vr_tab_erro(1).dscritic;
        ELSE
          vr_cdcritic := 1058; --Nao foi possivel carregar a tarifa
          pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' '||SQLERRM;
        END IF;

        --Grava tabela de log mas não pára execução do programa - Ch 788828
        pc_gera_log(pr_cdcooper      => 3,
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic||vr_dsparame,
                    pr_cdcriticidade => 1,
                    pr_cdmensagem    => nvl(vr_cdcritic,0),
                    pr_ind_tipo_log  => 1);
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
      -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_escreve_sms_debaut');
      
      -- Validar data cooper
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
         CLOSE btch0001.cr_crapdat;
        vr_cdcritic := 1; --Sistema sem data de movimento.
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

        --Grava tabela de log mas não pára execução do programa - Ch 788828
        pc_gera_log(pr_cdcooper      => 3,
                    pr_dstiplog      => 'E',
                    pr_dscritic      => vr_dscritic||'. Cooper:'||pr_cdcooper,
                    pr_cdcriticidade => 1,
                    pr_cdmensagem    => nvl(vr_cdcritic,0),
                    pr_ind_tipo_log  => 1);

        vr_cdcritic := NULL;
        vr_dscritic := NULL;

        RAISE vr_exc_saida;
      ELSE
         CLOSE btch0001.cr_crapdat;
      END IF;
      
      --Inicializar variavel retorno erro
      --Grava craplat - lançamentos de tarifas
      TARI0001.pc_cria_lan_auto_tarifa (pr_cdcooper => rw_debaut.cdcooper  --Codigo Cooperativa
                                       ,pr_nrdconta => rw_debaut.nrdconta  --Numero da Conta
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data Lancamento
                                       ,pr_cdhistor => vr_cdhistor         --Codigo Historico
                                       ,pr_vllanaut => vr_vltarifa         --Valor lancamento automatico
                                       ,pr_cdoperad => 1   		             --Codigo Operador
                                       ,pr_cdagenci => 1                   --Codigo Agencia
                                       ,pr_cdbccxlt => 100                 --Codigo banco caixa
                                       ,pr_nrdolote => 33000               --Numero do lote
                                       ,pr_tpdolote => 1                   --Tipo do lote
                                       ,pr_nrdocmto => 0                   --Numero do documento
                                       ,pr_nrdctabb => pr_nrdconta         --Numero da conta
                                       ,pr_nrdctitg => to_char(pr_nrdconta,'fm00000000') --Conta Integracao   --Numero da conta integracao
                                       ,pr_cdpesqbb => ''                  --Codigo pesquisa
                                       ,pr_cdbanchq => 0                   --Codigo Banco Cheque
                                       ,pr_cdagechq => 0                   --Codigo Agencia Cheque
                                       ,pr_nrctachq => 0                   --Numero Conta Cheque
                                       ,pr_flgaviso => FALSE               --Flag aviso
                                       ,pr_tpdaviso => 0                   --Tipo aviso
                                       ,pr_cdfvlcop => vr_cdfvlcop         --Codigo cooperativa
                                       ,pr_inproces => rw_crapdat.inproces --Indicador processo
                                       ,pr_rowid_craplat => vr_rowid_craplat --Rowid do lancamento tarifa
                                       ,pr_tab_erro => vr_tab_erro         --Tabela retorno erro
                                       ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);       --Descricao Critica
      
      --Chamado 788828 - 29/11/2017
      --Bloco estava após o end if
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Se possui erro no vetor
        IF vr_tab_erro.Count > 0 THEN
            vr_cdcritic:= vr_tab_erro(1).cdcritic;
          pr_dscritic:= vr_tab_erro(1).dscritic;
        ELSE
            vr_cdcritic := 1058; --Nao foi possivel carregar a tarifa
            pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' '||SQLERRM||'. '||vr_dsparame;
        END IF;

        --Grava tabela de log mas não pára execução do programa - Ch 788828
        pc_gera_log(pr_cdcooper      => 3,
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic||vr_dsparame,
                    pr_cdcriticidade => 1,
                    pr_cdmensagem    => nvl(vr_cdcritic,0),
                    pr_ind_tipo_log  => 1);
          --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
      -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_escreve_sms_debaut');
      
    END IF;
    
    --Insere o Motivo da Mensagem (Utilizado no BI)
    --Grava tbconv_motivo_msg
    BEGIN
      INSERT INTO tbconv_motivo_msg mtv
        (mtv.cdcooper
        ,mtv.nrdconta
        ,mtv.cdreferencia
        ,mtv.dhtentativa
        ,mtv.idmotivo
        ,mtv.vlfatura
        ,mtv.vltarifa
        ,mtv.idsms
        ,mtv.cdhistor
        ,mtv.idlote_sms)
      VALUES
        (rw_debaut.cdcooper
        ,rw_debaut.nrdconta
        ,pr_cdrefere
        ,SYSDATE
        ,pr_idmotivo
        ,pr_vlfatura
        ,NVL(vr_vltarifa,0)  --PRB0040057 - 21/06/2018
        ,vr_idsms
        ,pr_cdhistor
        ,pr_idlote_sms);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 29/11/2017 - Ch 788828 
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        vr_cdcritic := 1034;
        pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'motivo da mensagem. '||
                       'Cooper:'||rw_debaut.cdcooper||', nrdconta:'||rw_debaut.nrdconta||
                       ', cdreferencia:'||pr_cdrefere||', dhtentativa:'||SYSDATE||
                       ', idmotivo:'||pr_idmotivo||',vlfatura:'||pr_vlfatura||
                       ', vltarifa:'||vr_vltarifa||', idsms:'||vr_idsms||', cdhistor:'||pr_cdhistor||
                       ', idlote_sms:'||pr_idlote_sms||'. '||SQLERRM;

        --Grava tabela de log mas não pára execução do programa - Ch 788828
        pc_gera_log(pr_cdcooper      => 3,
                    pr_dstiplog      => 'E',
                    pr_dscritic      => pr_dscritic||'. pr_dsmensagem:'||pr_dsmensagem,
                    pr_cdcriticidade => 1,
                    pr_cdmensagem    => nvl(vr_cdcritic,0),
                    pr_ind_tipo_log  => 1);
        RAISE vr_exc_saida;
    END;
  
    -- Limpa nome do modulo logado - 29/11/2017 - Ch 788828    
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
  EXCEPTION
    WHEN vr_exc_saida THEN    
      --Os erros desviavam pra essa exception mas a mesma não existia no programa
      --Agora, os logs são feitos dentro das rotinas chamadas ou na ocorrncia deste programa
      --Ex.: cdcritic = 1;
      --Criada a exception apenas para sair do programa e não cair em others
      NULL;
    WHEN OTHERS THEN    
      -- No caso de erro de programa gravar tabela especifica de log - 29/11/2017 - Ch 788828 
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

      vr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'esms0001.pc_escreve_sms_debaut. '||SQLERRM||'.'||vr_dsparame;

      --Grava tabela de log - Ch 788828
      pc_gera_log(pr_cdcooper      => 3,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => pr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(vr_cdcritic,0),
                  pr_ind_tipo_log  => 2);

  END pc_escreve_sms_debaut;

  FUNCTION fn_busca_token_zenvia(pr_cdproduto IN NUMBER) RETURN VARCHAR2 IS --> Codigo do Produto utilizado para o servico SMS 
    -- ..........................................................................
    --
    --  Programa : fn_busca_token_zenvia
    --  Sigla    : CECRED
    --  Autor    : Anderson Fossa
    --  Data     : Setembro/2017.                   Ultima atualizacao: 
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Rotina para buscar o usuario e senha para envio de SMS atraves da Zenvia
    --
    --  Alteracoes: 
    -- .............................................................................
    vr_cdacesso crapprm.cdacesso%TYPE;
  BEGIN
      vr_cdacesso := 'TOKEN.ZENVIA.'||TO_CHAR(nvl(pr_cdproduto,0));
      RETURN gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                       pr_cdcooper => 0,
                                       pr_cdacesso => vr_cdacesso);
  END fn_busca_token_zenvia;

  --> Rotina para atualizar situação do SMS - chamada SOA
  PROCEDURE pc_atualiza_status_msg_soa ( pr_idlotsms   IN tbgen_sms_lote.idlote_sms%TYPE,  --> Numer do lote de SMS
                                         pr_xmlrequi   IN xmltype) IS                      --> Requeisicao xml
                                  
  /* ............................................................................

       Programa: pc_atualiza_status_m
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Anderson Fossa
       Data    : Setembro/2017                     Ultima atualizacao: 11/02/2019

       Dados referentes ao programa:

       Frequencia: Sempre que chamado
       Objetivo  : Rotina para atualizar situação do SMS - chamada SOA
                   (Baseado na procedure de mesmo nome da COBR0005)

       Alteracoes:
              29/11/2017 - Padronização mensagens (crapcri, pc_gera_log (tbgen))
                         - Padronização erros comandos DDL
                         - Pc_set_modulo, cecred.pc_internal_exception
                         - Tratamento erros others
                          (Ana - Envolti - Chamado 788828)
              16/05/2018 - Inclusão parâmetros no log
                          (Ana - Envolti - Chamado PRB0040049)
                          
              11/02/2019 - Ajustar gravacao da vr_dsparame pois estava estourando
                           erro oracle ao acumular no loop (Lucas Ranghetti PRB0040603)
    ............................................................................ */
    --------------->> CURSORES <<----------------
    -------------->> VARIAVEIS <<----------------
    vr_idsms      INTEGER;
    vr_cdretorn   VARCHAR2(10);
    vr_Detail     VARCHAR2(1000);
    vr_dsparame   VARCHAR2(2000);
    
    vr_dscritic   VARCHAR2(1000);
    vr_exc_erro   EXCEPTION;
    vr_nmarqlog   VARCHAR2(50);
    
    --Variaveis Documentos DOM
    vr_xmldoc     xmldom.DOMDocument;
    vr_lista_nodo xmldom.DOMNodeList;    
    vr_nodo       xmldom.DOMNode;        
    vr_idx        VARCHAR2(500);
    
    vr_tab_campos gene0007.typ_mult_array;
    
  BEGIN
    -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_atualiza_status_msg_soa');

    vr_dsparame := ' - pr_idlotsms:'||pr_idlotsms;
    
    vr_xmldoc:= xmldom.newDOMDocument(pr_xmlrequi); 
    
    ----------------------------------------------------
    --            GRAVAR OS DADOS DO CONTRATO         --
    ----------------------------------------------------      
    --> BUSCAR CONTRATOS DO ACORDO
    -- Listar nós contrado
    vr_lista_nodo:= xmldom.getElementsByTagName(vr_xmldoc,'mensagem');        

    FOR vr_linha IN 0..(xmldom.getLength(vr_lista_nodo)-1) LOOP
      --Buscar Nodo Corrente
      vr_nodo:= xmldom.item(vr_lista_nodo,vr_linha);
      
      gene0007.pc_itera_nodos (pr_nodo       => vr_nodo      --> Xpath do nodo a ser pesquisado
                              ,pr_nivel      => 0            --> Nível que será pesquisado
                              ,pr_list_nodos => vr_tab_campos--> PL Table com os nodos resgatados
                              ,pr_des_erro   => vr_dscritic);
                      
      IF vr_dscritic IS NOT NULL THEN
        --Grava tabela de log - Ch 788828
        pc_gera_log(pr_cdcooper      => 3,
                    pr_dstiplog      => 'E',
                    pr_dscritic      => vr_dscritic||', Lote:'||pr_idlotsms,
                    pr_cdcriticidade => 0,
                    pr_cdmensagem    => nvl(vr_cdcritic,0),
                    pr_ind_tipo_log  => 3,
                    pr_nmarqlog      => vr_nmarqlog);
      END IF;
      -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_atualiza_status_msg_soa');

      vr_idx := vr_tab_campos.first;
      WHILE vr_idx IS NOT NULL LOOP
      
        vr_idsms    := vr_tab_campos(vr_idx)('Id');
        vr_cdretorn := vr_tab_campos(vr_idx)('StatusCode');  
        vr_Detail   := vr_tab_campos(vr_idx)('Detail');
        
        vr_dsparame := 'pr_idlotsms:'  ||pr_idlotsms||
                       ', vr_idsms:'   ||vr_idsms||
                       ', vr_cdretorn:'||vr_cdretorn||
                       ', vr_detail:'  ||vr_detail;
        
        COBR0005.pc_atualiza_status_msg (pr_idlotsms   => pr_idlotsms  --> Numer do lote de SMS
                                        ,pr_idsms      => vr_idsms     --> Identificador do SMS
                                        ,pr_cdretorn   => vr_cdretorn  --> Código de retor
                                        ,pr_dsretorn   => vr_Detail    --> Detalhe do retorno
                                        ,pr_dscritic   => vr_dscritic);
        
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 29/11/2017 - Ch 788828
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'ESMS0001.pc_atualiza_status_msg_soa');
        
        vr_idx := vr_tab_campos.next(vr_idx);
        
      END LOOP;
    END LOOP;            
                                                   
    -- Limpa nome do modulo logado - 29/11/2017 - Ch 788828    
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
  EXCEPTION 
    WHEN vr_exc_erro THEN
      vr_nmarqlog := gene0001.fn_param_sistema( pr_nmsistem => 'CRED', 
                                                pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
    
      --Grava tabela de log - Ch 788828
      pc_gera_log(pr_cdcooper      => 3,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => vr_dscritic||vr_dsparame,
                  pr_cdcriticidade => 1,
                  pr_cdmensagem    => nvl(vr_cdcritic,0),
                  pr_ind_tipo_log  => 1);

    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 29/11/2017 - Ch 788828 
      CECRED.pc_internal_exception;
    
      vr_nmarqlog := gene0001.fn_param_sistema( pr_nmsistem => 'CRED', 
                                                pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
                                                
      vr_cdcritic := 1059;  --Não foi possivel atualizar SMS
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||SQLERRM||vr_dsparame;

      --Grava tabela de log - Ch 788828
      pc_gera_log(pr_cdcooper      => 3,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => vr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => nvl(vr_cdcritic,0),
                  pr_ind_tipo_log  => 2);

  END pc_atualiza_status_msg_soa; 

END esms0001;
/
