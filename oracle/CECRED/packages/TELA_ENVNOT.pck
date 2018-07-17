CREATE OR REPLACE PACKAGE CECRED.TELA_ENVNOT IS
   
  PROCEDURE pc_obtem_dados_msg_automatica(pr_cdorigem_mensagem IN TBGEN_NOTIF_AUTOMATICA_PRM.CDORIGEM_MENSAGEM%TYPE -- Codigo da origem da mensagem
                                         ,pr_cdmotivo_mensagem IN TBGEN_NOTIF_AUTOMATICA_PRM.CDMOTIVO_MENSAGEM%TYPE -- Codigo do motivo da mensagem
                                         ,pr_xmllog            IN VARCHAR2                                          --> XML com informacoes de LOG
                                         ,pr_cdcritic         OUT PLS_INTEGER                                       --> Codigo da critica
                                         ,pr_dscritic         OUT VARCHAR2                                          --> Descricao da critica
                                         ,pr_retxml        IN OUT NOCOPY xmltype                                    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo         OUT VARCHAR2                                          --> Nome do campo com erro
                                         ,pr_des_erro         OUT VARCHAR2);                                        --> Erros do processo

  PROCEDURE pc_obtem_dados_msg_manual(pr_cdmensagem   IN TBGEN_NOTIF_MANUAL_PRM.CDMENSAGEM%TYPE -- Codigo da mensagem
                                     ,pr_xmllog       IN VARCHAR2                               --> XML com informacoes de LOG
                                     ,pr_cdcritic    OUT PLS_INTEGER                            --> Codigo da critica
                                     ,pr_dscritic    OUT VARCHAR2                               --> Descricao da critica
                                     ,pr_retxml   IN OUT NOCOPY xmltype                         --> Arquivo de retorno do XML
                                     ,pr_nmdcampo    OUT VARCHAR2                               --> Nome do campo com erro
                                     ,pr_des_erro    OUT VARCHAR2);                             --> Erros do processo

  PROCEDURE pc_mantem_msg_automatica(pr_cdorigem_mensagem         IN TBGEN_NOTIF_AUTOMATICA_PRM.CDORIGEM_MENSAGEM%TYPE      -- Codigo da origem da mensagem
                                    ,pr_cdmotivo_mensagem         IN TBGEN_NOTIF_AUTOMATICA_PRM.CDMOTIVO_MENSAGEM%TYPE      -- Codigo do motivo da mensagem
                                    ,pr_dstitulo_mensagem         IN TBGEN_NOTIF_MSG_CADASTRO.DSTITULO_MENSAGEM%TYPE        -- Titulo da mensagem
                                    ,pr_dstexto_mensagem          IN TBGEN_NOTIF_MSG_CADASTRO.DSTEXTO_MENSAGEM%TYPE         -- Texto da mensagem
                                    ,pr_dshtml_mensagem           IN TBGEN_NOTIF_MSG_CADASTRO.DSHTML_MENSAGEM%TYPE          -- Conteudo da notificacao no formato Html
                                    ,pr_inexibe_botao_acao_mobile IN TBGEN_NOTIF_MSG_CADASTRO.INEXIBE_BOTAO_ACAO_MOBILE%TYPE-- Indicador se exibe botao de acao da notificacao no Cecred Mobile
                                    ,pr_dstexto_botao_acao_mobile IN TBGEN_NOTIF_MSG_CADASTRO.DSTEXTO_BOTAO_ACAO_MOBILE%TYPE-- Texto do botao de acao da notificacao no Cecred Mobile
                                    ,pr_idacao_botao_acao_mobile  IN NUMBER                                                 -- A��o do bot�o de a��o do Cecred Mobile. 1 - Abrir Link, 2 - Abrir tela
                                    ,pr_cdmenu_acao_mobile        IN TBGEN_NOTIF_MSG_CADASTRO.CDMENU_ACAO_MOBILE%TYPE       -- Codigo da tela do Cecred Mobile que deve ser aberta ao clicar no botao de acao
                                    ,pr_dslink_acao_mobile        IN TBGEN_NOTIF_MSG_CADASTRO.DSLINK_ACAO_MOBILE%TYPE       -- Link para ser acessado ao clicar no botao de acao no Cecred Mobile
                                    ,pr_dsmensagem_acao_mobile    IN TBGEN_NOTIF_MSG_CADASTRO.DSMENSAGEM_ACAO_MOBILE%TYPE   -- Mensagem de confirmacao que sera exibida ao clicar no botao de acao no Cecred Mobile
                                    ,pr_cdicone                   IN TBGEN_NOTIF_MSG_CADASTRO.CDICONE%TYPE                  -- Codigo do icone da notificacao
                                    ,pr_inexibir_banner           IN TBGEN_NOTIF_MSG_CADASTRO.INEXIBIR_BANNER%TYPE          -- Indicador de exibicao da imagem de banner
                                    ,pr_nmimagem_banner           IN TBGEN_NOTIF_MSG_CADASTRO.NMIMAGEM_BANNER%TYPE          -- Nome da imagem do banner para notificacao nao lida
                                    ,pr_inenviar_push             IN TBGEN_NOTIF_MSG_CADASTRO.INENVIAR_PUSH%TYPE            -- Indicador se envia push notification (0-Nao/ 1-Sim)
                                    -- Par�metros para mensagens autom�ticas
                                    ,pr_inmensagem_ativa     IN TBGEN_NOTIF_AUTOMATICA_PRM.INMENSAGEM_ATIVA%TYPE            -- Indicador se mensagem esta ativa
                                    ,pr_intipo_repeticao     IN NUMBER                                                      -- Tipo de Repeti��o: 1 - Semanal, 2 - Mensal
                                    ,pr_nrdias_semana        IN TBGEN_NOTIF_AUTOMATICA_PRM.NRDIAS_SEMANA%TYPE               -- Numeros dos dias da semana em que deve repetir a mensagem (Separados por virgula)
                                    ,pr_nrsemanas            IN TBGEN_NOTIF_AUTOMATICA_PRM.NRSEMANAS_REPETICAO%TYPE         -- Numero das semanas do m�s em que deve repetir a mensagem (Separadas por virgula)
                                    ,pr_nrdias_mes           IN TBGEN_NOTIF_AUTOMATICA_PRM.NRDIAS_MES%TYPE                  -- Dia(s) do m�s para disparar a mensagem (Separados por virgula)
                                    ,pr_nrmeses              IN TBGEN_NOTIF_AUTOMATICA_PRM.NRMESES_REPETICAO%TYPE           -- Numeros dos meses em que deve repetir a mensagem (Separados por virgula)
                                    ,pr_hrenvio_mensagem     IN VARCHAR2
                                    ,pr_xmllog       IN VARCHAR2                                                            --> XML com informacoes de LOG
                                    ,pr_cdcritic    OUT PLS_INTEGER                                                         --> Codigo da critica
                                    ,pr_dscritic    OUT VARCHAR2                                                            --> Descricao da critica
                                    ,pr_retxml   IN OUT NOCOPY xmltype                                                      --> Arquivo de retorno do XML
                                    ,pr_nmdcampo    OUT VARCHAR2                                                            --> Nome do campo com erro
                                    ,pr_des_erro    OUT VARCHAR2);                                                          --> Erros do processo

  PROCEDURE pc_mantem_msg_manual(pr_cdmensagem                IN TBGEN_NOTIF_MSG_CADASTRO.CDMENSAGEM%TYPE               -- Codigo da a mensagem
                                ,pr_dstitulo_mensagem         IN TBGEN_NOTIF_MSG_CADASTRO.DSTITULO_MENSAGEM%TYPE        -- Titulo da mensagem
                                ,pr_dstexto_mensagem          IN TBGEN_NOTIF_MSG_CADASTRO.DSTEXTO_MENSAGEM%TYPE         -- Texto da mensagem
                                ,pr_dshtml_mensagem           IN TBGEN_NOTIF_MSG_CADASTRO.DSHTML_MENSAGEM%TYPE          -- Conteudo da notificacao no formato Html
                                ,pr_inexibe_botao_acao_mobile IN TBGEN_NOTIF_MSG_CADASTRO.INEXIBE_BOTAO_ACAO_MOBILE%TYPE-- Indicador se exibe botao de acao da notificacao no Cecred Mobile
                                ,pr_dstexto_botao_acao_mobile IN TBGEN_NOTIF_MSG_CADASTRO.DSTEXTO_BOTAO_ACAO_MOBILE%TYPE-- Texto do botao de acao da notificacao no Cecred Mobile
                                ,pr_idacao_botao_acao_mobile  IN NUMBER                                                 -- A��o do bot�o de a��o do Cecred Mobile. 1 - Abrir Link, 2 - Abrir tela
                                ,pr_cdmenu_acao_mobile        IN TBGEN_NOTIF_MSG_CADASTRO.CDMENU_ACAO_MOBILE%TYPE       -- Codigo da tela do Cecred Mobile que deve ser aberta ao clicar no botao de acao
                                ,pr_dslink_acao_mobile        IN TBGEN_NOTIF_MSG_CADASTRO.DSLINK_ACAO_MOBILE%TYPE       -- Link para ser acessado ao clicar no botao de acao no Cecred Mobile
                                ,pr_dsmensagem_acao_mobile    IN TBGEN_NOTIF_MSG_CADASTRO.DSMENSAGEM_ACAO_MOBILE%TYPE   -- Mensagem de confirmacao que sera exibida ao clicar no botao de acao no Cecred Mobile
                                ,pr_cdicone                   IN TBGEN_NOTIF_MSG_CADASTRO.CDICONE%TYPE                  -- Codigo do icone da notificacao
                                ,pr_inexibir_banner           IN TBGEN_NOTIF_MSG_CADASTRO.INEXIBIR_BANNER%TYPE          -- Indicador de exibicao da imagem de banner
                                ,pr_nmimagem_banner           IN TBGEN_NOTIF_MSG_CADASTRO.NMIMAGEM_BANNER%TYPE          -- Nome da imagem do banner para notificacao nao lida
                                ,pr_inenviar_push            IN TBGEN_NOTIF_MSG_CADASTRO.INENVIAR_PUSH%TYPE             -- Indicador se envia push notification (0-Nao/ 1-Sim)
                                -- Par�metros para mensagens manuais
                                ,pr_dtenvio_mensagem      IN VARCHAR2                                                   -- Data do envio da mensagem
                                ,pr_hrenvio_mensagem      IN VARCHAR2                                                   -- Hora do envio da mensagem
                                ,pr_tpfiltro              IN TBGEN_NOTIF_MANUAL_PRM.TPFILTRO%TYPE                       -- Tipo do filtro (1-Filtro manual/ 2-Importacao de arquivo CSV)
                                ,pr_dsfiltro_cooperativas IN TBGEN_NOTIF_MANUAL_PRM.DSFILTRO_COOPERATIVAS%TYPE          -- Filtro de cooperativas: Codigos separados por virgula
                                ,pr_dsfiltro_tipos_conta  IN TBGEN_NOTIF_MANUAL_PRM.DSFILTRO_TIPOS_CONTA%TYPE           -- Filtro de tipo de conta: Tipos separados por virgula
                                ,pr_tpfiltro_mobile       IN TBGEN_NOTIF_MANUAL_PRM.TPFILTRO_MOBILE%TYPE                -- Filtro para usuario do Cecred Mobile (0-Todas as plataformas/ 1-Cooperados sem Mobile/ 2-Android/ 3-IOS)
                                ,pr_nmarquivo_csv         IN VARCHAR                                                    -- Nome do arquivo CSV para envio das notifica��es
                                ,pr_caminho_arq_upload    IN VARCHAR2                                                   -- Caminho do arquivo CSV
                                
                                ,pr_xmllog       IN VARCHAR2                                                            --> XML com informacoes de LOG
                                ,pr_cdcritic    OUT PLS_INTEGER                                                         --> Codigo da critica
                                ,pr_dscritic    OUT VARCHAR2                                                            --> Descricao da critica
                                ,pr_retxml   IN OUT NOCOPY xmltype                                                      --> Arquivo de retorno do XML
                                ,pr_nmdcampo    OUT VARCHAR2                                                            --> Nome do campo com erro
                                ,pr_des_erro    OUT VARCHAR2);                                                           --> Erros do processo

  PROCEDURE pc_lista_mensagens_manuais(pr_xmllog       IN VARCHAR2       --> XML com informacoes de LOG
                                      ,pr_cdcritic    OUT PLS_INTEGER    --> Codigo da critica
                                      ,pr_dscritic    OUT VARCHAR2       --> Descricao da critica
                                      ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                      ,pr_nmdcampo    OUT VARCHAR2       --> Nome do campo com erro
                                      ,pr_des_erro    OUT VARCHAR2);     --> Erros do processo
  
  PROCEDURE pc_cancela_msg_manual(pr_cdmensagem   IN TBGEN_NOTIF_MSG_CADASTRO.CDMENSAGEM%TYPE --> Codigo da a mensagem
                                 ,pr_xmllog       IN VARCHAR2                                 --> XML com informacoes de LOG
                                 ,pr_cdcritic    OUT PLS_INTEGER                              --> Codigo da critica
                                 ,pr_dscritic    OUT VARCHAR2                                 --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY xmltype                           --> Arquivo de retorno do XML
                                 ,pr_nmdcampo    OUT VARCHAR2                                 --> Nome do campo com erro
                                 ,pr_des_erro    OUT VARCHAR2);                               --> Erros do processo

  PROCEDURE pc_busca_origens_mensagens(pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                      ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);           --> Erros do processo  

  PROCEDURE pc_busca_motivos_mensagens(pr_cdorigem_mensagem tbgen_notif_automatica_prm.cdorigem_mensagem%TYPE --> Origem Mensagem
                                      ,pr_xmllog   IN VARCHAR2                                                --> XML com informa��es de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER                                            --> C�digo da cr�tica
                                      ,pr_dscritic OUT VARCHAR2                                               --> Descri��o da cr�tica
                                      ,pr_retxml   IN OUT NOCOPY XMLType                                      --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2                                               --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);                                             --> Erros do processo 

  PROCEDURE pc_busca_icone_notificacao(pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER       --> C�digo da cr�tica
                                      ,pr_dscritic OUT VARCHAR2          --> Descri��o da cr�tica
                                      ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);        --> Erros do processo 

  PROCEDURE pc_busca_telas_mobile(pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER       --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2          --> Descri��o da cr�tica
                                 ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);        --> Erros do processo 
                                 
  PROCEDURE pc_importar_arquivo_notif( pr_arquivo          IN VARCHAR2 --> nome do arquivo de importa��o
                                      ,pr_dirarquivo       IN VARCHAR2 --> nome do diret�rio arquivo de importa��o
                                      ,pr_destinatarios    OUT NOTI0001.typ_destinatarios_notif
																		  ,pr_xmllog           IN VARCHAR2 --> XML com informa��es de LOG
																		  ,pr_cdcritic         OUT PLS_INTEGER --> C�digo da cr�tica
																		  ,pr_dscritic         OUT VARCHAR2 --> Descri��o da cr�tica
																		  ,pr_retxml           IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																		  ,pr_nmdcampo         OUT VARCHAR2 --> Nome do Campo
																		  ,pr_des_erro         OUT VARCHAR2);                               

END TELA_ENVNOT;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ENVNOT IS

  NMDATELA CONSTANT VARCHAR2(6) := 'ENVNOT';
  
  DESCRICAOVARIAVEISUNIVERSAIS CONSTANT VARCHAR2(32000) := 
  '<br/>#numeroconta - N�mero da conta do cooperado (Ex.: 99.999-0)' ||
  '<br/>#nomecompleto - Contas PF: Nome completo do titular, Contas PJ: Raz�o social (Ex.: JO�O DA SILVA, ou GOOGLE BRASIL INTERNET LTDA)' ||
  '<br/>#nomeresumido - Contas PF: Primeiro nome do titular, Contas PJ: nome fantasia (Ex.: JO�O, ou GOOGLE)' ||
  '<br/>#cpfcnpj - CPF ou CNPJ da conta do cooperado (Ex.: 099.999.999-01)' ||
  '<br/>#siglacoop - Sigla da cooperativa (Ex.: AILOS)' ||
  '<br/>#nomecoop - Nome completo da cooperativa (Ex.: COOPERATIVA CENTRAL DE CR�DITO URBANO)';
     
  --Retorna 1 se OK, ou 0 se NOK
  FUNCTION fn_valida_cadastro_mensagem(pr_cdtipo_mensagem           IN TBGEN_NOTIF_MSG_ORIGEM.CDTIPO_MENSAGEM%TYPE          -- Codigo do tipo da mensagem
                                      ,pr_dstitulo_mensagem         IN TBGEN_NOTIF_MSG_CADASTRO.DSTITULO_MENSAGEM%TYPE        -- Titulo da mensagem
                                      ,pr_dstexto_mensagem          IN TBGEN_NOTIF_MSG_CADASTRO.DSTEXTO_MENSAGEM%TYPE         -- Texto da mensagem
                                      ,pr_dshtml_mensagem           IN TBGEN_NOTIF_MSG_CADASTRO.DSHTML_MENSAGEM%TYPE          -- Conteudo da notificacao no formato Html
                                      ,pr_dsvariaveis_disponiveis    IN VARCHAR2                                               -- Descri��o das vari�veis dispon�veis
                                      ,pr_inexibe_botao_acao_mobile IN TBGEN_NOTIF_MSG_CADASTRO.INEXIBE_BOTAO_ACAO_MOBILE%TYPE-- Indicador se exibe botao de acao da notificacao no Cecred Mobile
                                      ,pr_dstexto_botao_acao_mobile IN TBGEN_NOTIF_MSG_CADASTRO.DSTEXTO_BOTAO_ACAO_MOBILE%TYPE-- Texto do botao de acao da notificacao no Cecred Mobile
                                      ,pr_idacao_botao_acao_mobile  IN NUMBER                                                 -- A��o do bot�o de a��o do Cecred Mobile. 1 - Abrir Link, 2 - Abrir tela
                                      ,pr_cdmenu_acao_mobile        IN TBGEN_NOTIF_MSG_CADASTRO.CDMENU_ACAO_MOBILE%TYPE       -- Codigo da tela do Cecred Mobile que deve ser aberta ao clicar no botao de acao
                                      ,pr_dslink_acao_mobile        IN TBGEN_NOTIF_MSG_CADASTRO.DSLINK_ACAO_MOBILE%TYPE       -- Link para ser acessado ao clicar no botao de acao no Cecred Mobile
                                      ,pr_cdicone                   IN TBGEN_NOTIF_MSG_CADASTRO.CDICONE%TYPE                  -- Codigo do icone da notificacao
                                      ,pr_inexibir_banner           IN TBGEN_NOTIF_MSG_CADASTRO.INEXIBIR_BANNER%TYPE          -- Indicador de exibicao da imagem de banner
                                      ,pr_nmimagem_banner           IN TBGEN_NOTIF_MSG_CADASTRO.NMIMAGEM_BANNER%TYPE          -- Nome da imagem do banner para notificacao nao lida
                                      -- Par�metros para mensagens autom�ticas
                                      ,pr_intipo_repeticao     IN NUMBER                                             DEFAULT NULL -- Tipo de Repeti��o: 1 - Semanal, 2 - Mensal
                                      ,pr_nrdias_semana       IN TBGEN_NOTIF_AUTOMATICA_PRM.NRDIAS_SEMANA%TYPE       DEFAULT NULL -- Numeros dos dias da semana em que deve repetir a mensagem (Separados por virgula)
                                      ,pr_nrsemanas_repeticao IN TBGEN_NOTIF_AUTOMATICA_PRM.NRSEMANAS_REPETICAO%TYPE DEFAULT NULL -- Numero das semanas do m�s em que deve repetir a mensagem (Separadas por virgula)
                                      ,pr_nrdias_mes          IN TBGEN_NOTIF_AUTOMATICA_PRM.NRDIAS_MES%TYPE          DEFAULT NULL -- Dia(s) do m�s para disparar a mensagem (Separados por virgula)
                                      ,pr_nrmeses_repeticao   IN TBGEN_NOTIF_AUTOMATICA_PRM.NRMESES_REPETICAO%TYPE   DEFAULT NULL -- Numeros dos meses em que deve repetir a mensagem (Separados por virgula)
                                      ,pr_hrenvio_mensagem    IN VARCHAR2                                            DEFAULT NULL -- Hora do envio da mensagem
                                      -- Par�metros para mensagens manuais
                                      ,pr_dhenvio_mensagem      IN TBGEN_NOTIF_MANUAL_PRM.DHENVIO_MENSAGEM%TYPE      DEFAULT NULL -- Data e hora do envio da mensagem
                                      ,pr_tpfiltro              IN TBGEN_NOTIF_MANUAL_PRM.TPFILTRO%TYPE              DEFAULT NULL -- Tipo do filtro (1-Filtro manual/ 2-Importacao de arquivo CSV)
                                      ,pr_dsfiltro_cooperativas IN TBGEN_NOTIF_MANUAL_PRM.DSFILTRO_COOPERATIVAS%TYPE DEFAULT NULL -- Filtro de cooperativas: Codigos separados por virgula
                                      ,pr_dsfiltro_tipos_conta  IN TBGEN_NOTIF_MANUAL_PRM.DSFILTRO_TIPOS_CONTA%TYPE  DEFAULT NULL -- Filtro de tipos de conta: Codigos separados por virgula
                                      -- RETORNO
                                      ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                      ,pr_dscritic OUT VARCHAR2 -- Mensagem de retorno de critica da valida��o
                                      ) RETURN NUMBER IS
                                      
    CURSOR cr_var_inexistentes IS
    SELECT listagg(variavel, ', ') WITHIN GROUP (ORDER BY rownum) variaveis
      FROM (SELECT regexp_replace(regexp_substr(pr_dstexto_mensagem||' '||pr_dshtml_mensagem,'#\w+',1,LEVEL),'#\d+$') variavel -- Replace para tirar os c�digos html que usam #. Ex: Ap�strofo = &#39;
              FROM dual
            CONNECT BY LEVEL <= regexp_count(pr_dstexto_mensagem||' '||pr_dshtml_mensagem, '[^#]+'))
     WHERE variavel IS NOT NULL
       AND pr_dsvariaveis_disponiveis NOT LIKE '%' || variavel || ' %';
    vr_var_inexistentes VARCHAR2(1000);

    vr_nrdias_semana		    TBGEN_NOTIF_AUTOMATICA_PRM.NRDIAS_SEMANA%TYPE;
    vr_nrsemanas_repeticao  TBGEN_NOTIF_AUTOMATICA_PRM.NRSEMANAS_REPETICAO%TYPE;
    vr_nrdias_mes           TBGEN_NOTIF_AUTOMATICA_PRM.NRDIAS_MES%TYPE;
    vr_nrmeses_repeticao    TBGEN_NOTIF_AUTOMATICA_PRM.NRMESES_REPETICAO%TYPE;

    vr_dsfiltro_cooperativas TBGEN_NOTIF_MANUAL_PRM.DSFILTRO_COOPERATIVAS%TYPE;
    vr_dsfiltro_tipos_conta TBGEN_NOTIF_MANUAL_PRM.DSFILTRO_TIPOS_CONTA%TYPE;

    vr_exc_erro EXCEPTION;

  BEGIN
    
    /*VALIDA OS CAMPOS OBRIGAT�RIOS*/
    IF pr_dstitulo_mensagem IS NULL THEN
      pr_dscritic:= 'T�tulo � obrigat�rio';
    ELSIF pr_cdicone IS NULL THEN
      pr_dscritic:= '�cone � obrigat�rio';
    ELSIF pr_dstexto_mensagem IS NULL THEN
      pr_dscritic:= 'Mensagem � obrigat�ria';
    ELSIF pr_inexibir_banner = 1 AND pr_nmimagem_banner IS NULL THEN
      pr_dscritic:= 'Exibir Banner est� ativo mas nenhuma imagem foi selecionada';
    ELSIF pr_dshtml_mensagem IS NULL THEN
      pr_dscritic:= 'Conte�do � obrigat�rio';
    ELSIF pr_inexibe_botao_acao_mobile = 1 THEN -- Valida��es refetentes ao bot�o de a��o
      IF pr_dstexto_botao_acao_mobile IS NULL THEN
      pr_dscritic:= 'O texto do bot�o de a��o do Ailos Mobile � obrigat�rio';
      ELSIF pr_idacao_botao_acao_mobile = 1 AND pr_dslink_acao_mobile IS NULL THEN
      pr_dscritic:= 'URL do bot�o de a��o � obrigat�rio';
      ELSIF pr_idacao_botao_acao_mobile = 2 AND pr_cdmenu_acao_mobile IS NULL THEN
      pr_dscritic:= 'Tela do Ailos Mobile do bot�o de a��o � obrigat�ria';
      END IF;
    END IF;
    
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    /*VALIDA AS MENSAGENS AUTOM�TICAS RECORRENTES (Tipo: Servi�os)*/
    IF (pr_cdtipo_mensagem = 1) THEN -- Servi�os
      --Limpa as virgulas e espa�os dos par�metros de lista
      vr_nrdias_semana := REPLACE(REPLACE(pr_nrdias_semana,',',''),' ','');
      vr_nrsemanas_repeticao := REPLACE(REPLACE(pr_nrsemanas_repeticao,',',''),' ','');
      vr_nrdias_mes := REPLACE(REPLACE(pr_nrdias_mes,',',''),' ','');
      vr_nrmeses_repeticao := REPLACE(REPLACE(pr_nrmeses_repeticao,',',''),' ','');
      
      IF pr_intipo_repeticao <> 1 AND pr_intipo_repeticao <> 2 THEN -- Se n�o for selecionado nenhum tipo de recorr�ncia
        pr_dscritic:= '� obrigat�rio escolher um tipo de recorr�ncia: Por m�s ou por semana';
      ELSIF pr_intipo_repeticao = 1 AND (vr_nrdias_semana IS NULL OR vr_nrsemanas_repeticao IS NULL) THEN -- Se for semana
        pr_dscritic:= 'Para ativar a recorr�ncia por semana � necess�rio informar os dias e as semanas em que deve ocorrer os envios da mensagem';
      ELSIF pr_intipo_repeticao = 2 AND (vr_nrdias_mes IS NULL OR vr_nrmeses_repeticao IS NULL) THEN -- Se for m�s
        pr_dscritic:= 'Para ativar a recorr�ncia por m�s � necess�rio informar os dias e os meses em que deve ocorrer os envios da mensagem';
      END IF;
      
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
    /*VALIDA AS MENSAGENS MANUAIS (Tipo: Avisos)*/
    ELSIF (pr_cdtipo_mensagem = 3) THEN -- Avisos
      --Limpa as virgulas e espa�os dos par�metros de lista
      vr_dsfiltro_cooperativas := REPLACE(REPLACE(pr_dsfiltro_cooperativas,',',''),' ','');
      vr_dsfiltro_tipos_conta := REPLACE(REPLACE(pr_dsfiltro_tipos_conta,',',''),' ','');
      
      IF pr_dhenvio_mensagem IS NULL THEN 
        pr_dscritic:= 'Data do envio da mensagem � obrigat�ria';
      ELSIF pr_hrenvio_mensagem IS NULL THEN
        pr_dscritic:= 'Hora do envio da mensagem � obrigat�ria';
      ELSIF TRUNC(pr_dhenvio_mensagem) < TRUNC(SYSDATE) THEN
        pr_dscritic:= 'Data do envio da mensagem j� passou';
      ELSIF pr_dhenvio_mensagem < SYSDATE THEN
        pr_dscritic:= 'Hora do envio da mensagem j� passou';
      ELSIF pr_tpfiltro <> 1 AND pr_tpfiltro <> 2 THEN
        pr_dscritic:= '� necess�rio escolher um tipo de filtro';
      ELSIF pr_tpfiltro = 2 AND TRUNC(pr_dhenvio_mensagem) <> TRUNC(SYSDATE) THEN -- Arquivo csv s� pode ser importado para mensagens enviadas no dia, pq seus dados s�o est�ticos
        pr_dscritic:= 'Arquivo .csv s� pode ser importado para mensagens enviadas no mesmo dia';
      ELSIF (vr_dsfiltro_cooperativas IS NULL OR vr_dsfiltro_cooperativas = 0) AND pr_tpfiltro = 1 THEN
        pr_dscritic:= '� necess�rio selecionar ao menos uma cooperativa';
      ELSIF (vr_dsfiltro_tipos_conta IS NULL OR vr_dsfiltro_tipos_conta = 0) AND pr_tpfiltro = 1 THEN
        pr_dscritic:= '� necess�rio selecionar ao menos um tipo de conta';
      END IF;
      
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    
    END IF;
    
    -- Depois de tudo, valida se o html possui variaveis inexistentes
    OPEN cr_var_inexistentes;
    FETCH cr_var_inexistentes
    INTO vr_var_inexistentes;
    CLOSE cr_var_inexistentes;
    
    IF vr_var_inexistentes IS NOT NULL THEN
      pr_dscritic:= 'Vari�vel inexistente: ' || vr_var_inexistentes;
      RAISE vr_exc_erro;
    END IF;
    
    

    --Se passou por todas as valida��es
    RETURN 1;
    
  EXCEPTION
    WHEN OTHERS THEN
         RETURN 0;
  END fn_valida_cadastro_mensagem;

  PROCEDURE pc_obtem_dados_msg_automatica(pr_cdorigem_mensagem IN TBGEN_NOTIF_AUTOMATICA_PRM.CDORIGEM_MENSAGEM%TYPE      -- Codigo da origem da mensagem
                                         ,pr_cdmotivo_mensagem IN TBGEN_NOTIF_AUTOMATICA_PRM.CDMOTIVO_MENSAGEM%TYPE      -- Codigo do motivo da mensagem
                                         ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                                         ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                                         ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                                         ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                         ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                                         ,pr_des_erro    OUT VARCHAR2) IS --> Erros do processo
    
    -- Cursor para obter os dados da Mensagem autom�tica
    CURSOR cr_mensagem IS
    SELECT aut.cdmotivo_mensagem
          ,aut.cdorigem_mensagem
          ,aut.cdmensagem
          ,aut.dsmotivo_mensagem
          ,aut.dsvariaveis_mensagem || DESCRICAOVARIAVEISUNIVERSAIS dsvariaveis_mensagem
          ,aut.inmensagem_ativa
          ,aut.intipo_repeticao
          ,aut.nrdias_semana
          ,aut.nrsemanas_repeticao
          ,aut.nrdias_mes
          ,aut.nrmeses_repeticao
          ,TO_CHAR(TRUNC(SYSDATE)+(aut.hrenvio_mensagem/60/60/24),'HH24:MI') hrenvio_mensagem
          ,msg.dstitulo_mensagem
          ,msg.dstexto_mensagem
          ,msg.dshtml_mensagem
          ,NVL(msg.inexibe_botao_acao_mobile,0) inexibe_botao_acao_mobile
          ,msg.dstexto_botao_acao_mobile
          ,DECODE(msg.cdmenu_acao_mobile,NULL,1,2) idacao_botao_acao_mobile
          ,NVL(msg.cdmenu_acao_mobile,0) cdmenu_acao_mobile
          ,msg.dslink_acao_mobile
          ,msg.dsmensagem_acao_mobile
          ,msg.dsparam_acao_mobile
          ,msg.cdicone
          ,(SELECT prm.valor || ico.nmimagem_naolida
              FROM tbgen_notif_icone ico
                  ,parametromobile prm
             WHERE ico.cdicone = msg.cdicone
               AND prm.nome = 'UrlImagensIconesNotificacao') urlimagem_icone
          ,NVL(msg.inexibir_banner,0) inexibir_banner
          ,NVL2(msg.nmimagem_banner,
               (SELECT prm.valor
                  FROM parametromobile prm
                 WHERE prm.nome = 'UrlImagensBannersNotificacao') || msg.nmimagem_banner, NULL) urlimagem_banner
          ,msg.nmimagem_banner
          ,NVL(msg.inenviar_push,0) inenviar_push
          ,ori.cdtipo_mensagem
      FROM tbgen_notif_automatica_prm aut
          ,tbgen_notif_msg_cadastro   msg
          ,tbgen_notif_msg_origem ori
     WHERE aut.cdmensagem = msg.cdmensagem
       AND aut.cdorigem_mensagem = pr_cdorigem_mensagem
       AND aut.cdmotivo_mensagem = pr_cdmotivo_mensagem
       AND ori.cdorigem_mensagem = aut.cdorigem_mensagem;
    
    CURSOR cr_urlservimg IS
    SELECT prm.valor
      FROM parametromobile prm
     WHERE prm.nome = 'UrlImagensBannersNotificacao';
    vr_urlservimg VARCHAR2(1000);
    
    rw_mensagem cr_mensagem%ROWTYPE;
    cr_mensagem_found BOOLEAN := FALSE;
    
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
  BEGIN
    
    -- Extrai os dados vindos do XML
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    -- Obt�m os dados da mensagem
    OPEN cr_mensagem;
    FETCH cr_mensagem
    INTO rw_mensagem;
    cr_mensagem_found := cr_mensagem%FOUND;
    CLOSE cr_mensagem;
    
    IF NOT cr_mensagem_found THEN
      vr_dscritic := 'Registro de Mensagem n�o encontrado';
      RAISE vr_exc_erro;
    END IF;
    
    -- Obt�m a URL do servidor de imagens
    OPEN cr_urlservimg;
    FETCH cr_urlservimg
    INTO vr_urlservimg;
    CLOSE cr_urlservimg;
    
    -- Gera o XML
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'mensagem', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'cdorigem_mensagem', pr_tag_cont => rw_mensagem.cdorigem_mensagem, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'cdmotivo_mensagem', pr_tag_cont => rw_mensagem.cdmotivo_mensagem, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'cdmensagem', pr_tag_cont => rw_mensagem.cdmensagem, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'dsmotivo_mensagem', pr_tag_cont => rw_mensagem.dsmotivo_mensagem, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'dsvariaveis_mensagem', pr_tag_cont => rw_mensagem.dsvariaveis_mensagem, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'dstitulo_mensagem', pr_tag_cont => rw_mensagem.dstitulo_mensagem, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'inmensagem_ativa', pr_tag_cont => rw_mensagem.inmensagem_ativa, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'inenviar_push', pr_tag_cont => rw_mensagem.inenviar_push, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'cdicone', pr_tag_cont => rw_mensagem.cdicone, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'urlimagem_icone', pr_tag_cont => rw_mensagem.urlimagem_icone, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'dstexto_mensagem', pr_tag_cont =>rw_mensagem.dstexto_mensagem, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'inexibir_banner', pr_tag_cont => rw_mensagem.inexibir_banner, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'urlimagem_banner', pr_tag_cont => rw_mensagem.urlimagem_banner, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'nmimagem_banner', pr_tag_cont => rw_mensagem.nmimagem_banner, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'dshtml_mensagem', pr_tag_cont =>rw_mensagem.dshtml_mensagem, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'inexibe_botao_acao_mobile', pr_tag_cont => rw_mensagem.inexibe_botao_acao_mobile, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'dstexto_botao_acao_mobile', pr_tag_cont => rw_mensagem.dstexto_botao_acao_mobile, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'idacao_botao_acao_mobile', pr_tag_cont => rw_mensagem.idacao_botao_acao_mobile, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'cdmenu_acao_mobile', pr_tag_cont => rw_mensagem.cdmenu_acao_mobile, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'dslink_acao_mobile', pr_tag_cont => rw_mensagem.dslink_acao_mobile, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'dsmensagem_acao_mobile', pr_tag_cont => rw_mensagem.dsmensagem_acao_mobile, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'hrenvio_mensagem', pr_tag_cont => rw_mensagem.hrenvio_mensagem, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'intipo_repeticao', pr_tag_cont => rw_mensagem.intipo_repeticao, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'nrdias_semana', pr_tag_cont => rw_mensagem.nrdias_semana, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'nrsemanas_repeticao', pr_tag_cont => rw_mensagem.nrsemanas_repeticao, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'nrdias_mes', pr_tag_cont => rw_mensagem.nrdias_mes, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'nrmeses_repeticao', pr_tag_cont => rw_mensagem.nrmeses_repeticao, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'cdtipo_mensagem', pr_tag_cont => rw_mensagem.cdtipo_mensagem, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'dsurl_sevidor_imagem', pr_tag_cont => vr_urlservimg, pr_des_erro => vr_dscritic);

  EXCEPTION
    WHEN OTHERS THEN
      IF vr_cdcritic <> 0 THEN -- Tenta pegar a exception pelo CDCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSIF vr_dscritic IS NOT NULL THEN -- Tenta pegar a exception pelo DSCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      ELSE  -- Sen�o, Dispara a EXCEPTION padr�o
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela '|| NMDATELA ||': ' || SQLERRM;
      END IF;

      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_obtem_dados_msg_automatica;

  PROCEDURE pc_obtem_dados_msg_manual(pr_cdmensagem   IN TBGEN_NOTIF_MANUAL_PRM.CDMENSAGEM%TYPE -- Codigo da mensagem
                                     ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                                     ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                                     ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                                     ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro    OUT VARCHAR2) IS --> Erros do processo
    
    -- Cursor para obter os dados da Mensagem autom�tica
    CURSOR cr_mensagem IS
    SELECT man.cdmensagem
          ,TRUNC(man.dhenvio_mensagem) dtenvio_mensagem
          ,TO_CHAR(man.dhenvio_mensagem,'HH24:MI') hrenvio_mensagem
          ,man.cdsituacao_mensagem
          ,NVL(man.tpfiltro,1) tpfiltro
          ,man.dsfiltro_cooperativas
          ,man.dsfiltro_tipos_conta
          ,NVL(man.tpfiltro_mobile,1) tpfiltro_mobile
          ,msg.dstitulo_mensagem 
          ,msg.dstexto_mensagem
          ,msg.dshtml_mensagem
          ,NVL(msg.inexibe_botao_acao_mobile,0) inexibe_botao_acao_mobile
          ,msg.dstexto_botao_acao_mobile
          ,NVL(msg.cdmenu_acao_mobile,1) idacao_botao_acao_mobile
          ,NVL(msg.cdmenu_acao_mobile,0) cdmenu_acao_mobile
          ,msg.dslink_acao_mobile
          ,msg.dsmensagem_acao_mobile
          ,msg.dsparam_acao_mobile
          ,msg.cdicone
          ,(SELECT prm.valor || ico.nmimagem_naolida
              FROM tbgen_notif_icone ico
                  ,parametromobile prm
             WHERE ico.cdicone = msg.cdicone
               AND prm.nome = 'UrlImagensIconesNotificacao') urlimagem_icone
          ,NVL(msg.inexibir_banner,0) inexibir_banner
          ,NVL2(msg.nmimagem_banner,
               (SELECT prm.valor
                  FROM parametromobile prm
                 WHERE prm.nome = 'UrlImagensBannersNotificacao') || msg.nmimagem_banner, NULL) urlimagem_banner 
          ,msg.nmimagem_banner
          ,NVL(msg.inenviar_push,0) inenviar_push
      FROM tbgen_notif_manual_prm   man
          ,tbgen_notif_msg_cadastro msg
     WHERE man.cdmensagem = msg.cdmensagem
       AND man.cdmensagem = pr_cdmensagem;
    rw_mensagem cr_mensagem%ROWTYPE;
    cr_mensagem_found BOOLEAN := FALSE;
    
    --Lista as cooperativas separadas por virgula
    CURSOR cr_cooperativas IS
    SELECT listagg(cop.cdcooper, ',') WITHIN GROUP(ORDER BY cop.cdcooper) cdcoopers
      FROM crapcop cop
     WHERE cop.flgativo = 1;
    vr_cooperativas VARCHAR2(100);
    
    --Obt�m a url do servidor de imagem
    CURSOR cr_urlservimg IS
    SELECT prm.valor
      FROM parametromobile prm
     WHERE prm.nome = 'UrlImagensBannersNotificacao';
    vr_urlservimg VARCHAR2(1000);
    
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
  BEGIN
    
    -- Extrai os dados vindos do XML
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    -- Se possuir o c�digo da mensagem, busca os dados na base
    IF pr_cdmensagem > 0 THEN
      -- Obt�m os dados da mensagem
      OPEN cr_mensagem;
      FETCH cr_mensagem
      INTO rw_mensagem;
      cr_mensagem_found := cr_mensagem%FOUND;
      CLOSE cr_mensagem;
      
      IF NOT cr_mensagem_found THEN
        vr_dscritic := 'Registro de Mensagem n�o encontrado';
        RAISE vr_exc_erro;
      END IF;
      
    -- Se estiver vazio, busca os valores padr�o
    ELSE
       
       --Obtem a lista das coops
       OPEN cr_cooperativas;
       FETCH cr_cooperativas
       INTO vr_cooperativas;
       CLOSE cr_cooperativas;
       
       -- Seta os valores default
       rw_mensagem.cdmensagem := 0;
       rw_mensagem.inenviar_push := 1;
       rw_mensagem.inexibir_banner := 0;
       rw_mensagem.inexibe_botao_acao_mobile := 0;
       rw_mensagem.idacao_botao_acao_mobile := 0;
       rw_mensagem.tpfiltro := 1;
       rw_mensagem.dsfiltro_cooperativas := vr_cooperativas;
       rw_mensagem.dsfiltro_tipos_conta := '1,2';
       rw_mensagem.tpfiltro_mobile := 0;
       rw_mensagem.idacao_botao_acao_mobile := 0;
       rw_mensagem.cdmenu_acao_mobile := 0;
    END IF;
    
    -- Obt�m a URL do servidor de imagens
    OPEN cr_urlservimg;
    FETCH cr_urlservimg
    INTO vr_urlservimg;
    CLOSE cr_urlservimg;
    
    -- Gera o XML
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'mensagem', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'cdmensagem', pr_tag_cont => rw_mensagem.cdmensagem, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'dsvariaveis_mensagem', pr_tag_cont => DESCRICAOVARIAVEISUNIVERSAIS, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'dstitulo_mensagem', pr_tag_cont => rw_mensagem.dstitulo_mensagem, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'inenviar_push', pr_tag_cont => rw_mensagem.inenviar_push, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'cdicone', pr_tag_cont => rw_mensagem.cdicone, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'urlimagem_icone', pr_tag_cont => rw_mensagem.urlimagem_icone, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'dstexto_mensagem', pr_tag_cont => rw_mensagem.dstexto_mensagem, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'inexibir_banner', pr_tag_cont => rw_mensagem.inexibir_banner, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'urlimagem_banner', pr_tag_cont => rw_mensagem.urlimagem_banner, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'nmimagem_banner', pr_tag_cont => rw_mensagem.nmimagem_banner, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'dshtml_mensagem', pr_tag_cont => rw_mensagem.dshtml_mensagem, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'inexibe_botao_acao_mobile', pr_tag_cont => rw_mensagem.inexibe_botao_acao_mobile, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'dstexto_botao_acao_mobile', pr_tag_cont => rw_mensagem.dstexto_botao_acao_mobile, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'idacao_botao_acao_mobile', pr_tag_cont => NVL(rw_mensagem.idacao_botao_acao_mobile,'0'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'cdmenu_acao_mobile', pr_tag_cont => NVL(rw_mensagem.cdmenu_acao_mobile,'0'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'dslink_acao_mobile', pr_tag_cont => rw_mensagem.dslink_acao_mobile, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'dsmensagem_acao_mobile', pr_tag_cont => rw_mensagem.dsmensagem_acao_mobile, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'dtenvio_mensagem', pr_tag_cont => TO_CHAR(rw_mensagem.dtenvio_mensagem,'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'hrenvio_mensagem', pr_tag_cont => rw_mensagem.hrenvio_mensagem, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'cdsituacao_mensagem', pr_tag_cont => rw_mensagem.cdsituacao_mensagem, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'tpfiltro', pr_tag_cont => rw_mensagem.tpfiltro, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'dsfiltro_cooperativas', pr_tag_cont => rw_mensagem.dsfiltro_cooperativas, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'dsfiltro_tipos_conta', pr_tag_cont => rw_mensagem.dsfiltro_tipos_conta, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'tpfiltro_mobile', pr_tag_cont => rw_mensagem.tpfiltro_mobile, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => 0, pr_tag_nova => 'dsurl_sevidor_imagem', pr_tag_cont => vr_urlservimg, pr_des_erro => vr_dscritic);

  EXCEPTION
    WHEN OTHERS THEN
      IF vr_cdcritic <> 0 THEN -- Tenta pegar a exception pelo CDCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSIF vr_dscritic IS NOT NULL THEN -- Tenta pegar a exception pelo DSCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      ELSE  -- Sen�o, Dispara a EXCEPTION padr�o
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela '|| NMDATELA ||': ' || SQLERRM;
      END IF;

      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_obtem_dados_msg_manual;

  PROCEDURE pc_mantem_msg_automatica(pr_cdorigem_mensagem         IN TBGEN_NOTIF_AUTOMATICA_PRM.CDORIGEM_MENSAGEM%TYPE      -- Codigo da origem da mensagem
                                    ,pr_cdmotivo_mensagem         IN TBGEN_NOTIF_AUTOMATICA_PRM.CDMOTIVO_MENSAGEM%TYPE      -- Codigo do motivo da mensagem
                                    ,pr_dstitulo_mensagem         IN TBGEN_NOTIF_MSG_CADASTRO.DSTITULO_MENSAGEM%TYPE        -- Titulo da mensagem
                                    ,pr_dstexto_mensagem          IN TBGEN_NOTIF_MSG_CADASTRO.DSTEXTO_MENSAGEM%TYPE         -- Texto da mensagem
                                    ,pr_dshtml_mensagem           IN TBGEN_NOTIF_MSG_CADASTRO.DSHTML_MENSAGEM%TYPE          -- Conteudo da notificacao no formato Html
                                    ,pr_inexibe_botao_acao_mobile IN TBGEN_NOTIF_MSG_CADASTRO.INEXIBE_BOTAO_ACAO_MOBILE%TYPE-- Indicador se exibe botao de acao da notificacao no Cecred Mobile
                                    ,pr_dstexto_botao_acao_mobile IN TBGEN_NOTIF_MSG_CADASTRO.DSTEXTO_BOTAO_ACAO_MOBILE%TYPE-- Texto do botao de acao da notificacao no Cecred Mobile
                                    ,pr_idacao_botao_acao_mobile  IN NUMBER                                                 -- A��o do bot�o de a��o do Cecred Mobile. 1 - Abrir Link, 2 - Abrir tela
                                    ,pr_cdmenu_acao_mobile        IN TBGEN_NOTIF_MSG_CADASTRO.CDMENU_ACAO_MOBILE%TYPE       -- Codigo da tela do Cecred Mobile que deve ser aberta ao clicar no botao de acao
                                    ,pr_dslink_acao_mobile        IN TBGEN_NOTIF_MSG_CADASTRO.DSLINK_ACAO_MOBILE%TYPE       -- Link para ser acessado ao clicar no botao de acao no Cecred Mobile
                                    ,pr_dsmensagem_acao_mobile    IN TBGEN_NOTIF_MSG_CADASTRO.DSMENSAGEM_ACAO_MOBILE%TYPE   -- Mensagem de confirmacao que sera exibida ao clicar no botao de acao no Cecred Mobile
                                    ,pr_cdicone                   IN TBGEN_NOTIF_MSG_CADASTRO.CDICONE%TYPE                  -- Codigo do icone da notificacao
                                    ,pr_inexibir_banner           IN TBGEN_NOTIF_MSG_CADASTRO.INEXIBIR_BANNER%TYPE          -- Indicador de exibicao da imagem de banner
                                    ,pr_nmimagem_banner           IN TBGEN_NOTIF_MSG_CADASTRO.NMIMAGEM_BANNER%TYPE          -- Nome da imagem do banner para notificacao nao lida
                                    ,pr_inenviar_push             IN TBGEN_NOTIF_MSG_CADASTRO.INENVIAR_PUSH%TYPE           -- Indicador se envia push notification (0-Nao/ 1-Sim)
                                    -- Par�metros para mensagens autom�ticas
                                    ,pr_inmensagem_ativa     IN TBGEN_NOTIF_AUTOMATICA_PRM.INMENSAGEM_ATIVA%TYPE    -- Indicador se mensagem esta ativa
                                    ,pr_intipo_repeticao     IN NUMBER                                              -- Tipo de Repeti��o: 1 - Semanal, 2 - Mensal
                                    ,pr_nrdias_semana        IN TBGEN_NOTIF_AUTOMATICA_PRM.NRDIAS_SEMANA%TYPE       -- Numeros dos dias da semana em que deve repetir a mensagem (Separados por virgula)
                                    ,pr_nrsemanas            IN TBGEN_NOTIF_AUTOMATICA_PRM.NRSEMANAS_REPETICAO%TYPE -- Numero das semanas do m�s em que deve repetir a mensagem (Separadas por virgula)
                                    ,pr_nrdias_mes           IN TBGEN_NOTIF_AUTOMATICA_PRM.NRDIAS_MES%TYPE          -- Dia(s) do m�s para disparar a mensagem (Separados por virgula)
                                    ,pr_nrmeses              IN TBGEN_NOTIF_AUTOMATICA_PRM.NRMESES_REPETICAO%TYPE   -- Numeros dos meses em que deve repetir a mensagem (Separados por virgula)
                                    ,pr_hrenvio_mensagem     IN VARCHAR2
                                    
                                    ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                                    ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                                    ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                                    ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro    OUT VARCHAR2) IS --> Erros do processo

    --Vari�veis
    vr_cdmensagem tbgen_notif_msg_cadastro.cdorigem_mensagem%TYPE;
    vr_validacao NUMBER:= 0;
    ex_erro EXCEPTION;

     -- Cursor para trazer o c�digo da mensagem cadastrada para o motivo recebido por par�metro
     CURSOR cr_mensagem IS
     SELECT aut.cdorigem_mensagem
           ,aut.cdmotivo_mensagem
           ,aut.cdmensagem
           ,ori.cdtipo_mensagem
           ,aut.dsvariaveis_mensagem
         /* [TODO] Verificar com o Julio/Klock sobre a gera��o de logs de altera��es
         
        SE FOR DEFINIDO PRA USAR A PACKAGE
           FAZER O DECODE ABAIXO PARA TODOS OS PARAMETROS (EXCETO PK)
           ,DECODE(aut.inmensagem_ativa            ,pr_inmensagem_ativa,0,1) alt_inmensagem_ativa
           
           */
       FROM tbgen_notif_automatica_prm aut
           ,tbgen_notif_msg_cadastro   msg
           ,tbgen_notif_msg_origem     ori
      WHERE aut.cdmensagem = msg.cdmensagem
        AND aut.cdorigem_mensagem = ori.cdorigem_mensagem
        AND aut.cdorigem_mensagem = pr_cdorigem_mensagem
        AND aut.cdmotivo_mensagem = pr_cdmotivo_mensagem;

    rw_mensagem cr_mensagem%ROWTYPE;
    cr_mensagem_found BOOLEAN := FALSE;

    vr_dshtml_mensagem tbgen_notif_msg_cadastro.dshtml_mensagem%TYPE;
    
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

  BEGIN
    
    -- Extrai os dados vindos do XML
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    -- Obt�m o c�digo da mensagem
    OPEN cr_mensagem;
    FETCH cr_mensagem
    INTO rw_mensagem;
    cr_mensagem_found := cr_mensagem%FOUND;
    CLOSE cr_mensagem;
    
    IF NOT cr_mensagem_found THEN
      vr_dscritic := 'Registro de Mensagem n�o encontrado. ' || pr_cdorigem_mensagem || ',' || pr_cdmotivo_mensagem;
      RAISE ex_erro;
    END IF;
    
    vr_dshtml_mensagem := SUBSTR(pr_dshtml_mensagem,10,LENGTH(pr_dshtml_mensagem)-12);

    -- Valida os dados da mensagem
    vr_validacao := TELA_ENVNOT.fn_valida_cadastro_mensagem (pr_cdtipo_mensagem => rw_mensagem.cdtipo_mensagem
                                                            ,pr_dstitulo_mensagem => pr_dstitulo_mensagem
                                                            ,pr_dstexto_mensagem => pr_dstexto_mensagem
                                                            ,pr_dshtml_mensagem => vr_dshtml_mensagem
                                                            ,pr_dsvariaveis_disponiveis => rw_mensagem.dsvariaveis_mensagem || DESCRICAOVARIAVEISUNIVERSAIS
                                                            ,pr_inexibe_botao_acao_mobile => pr_inexibe_botao_acao_mobile
                                                            ,pr_dstexto_botao_acao_mobile => pr_dstexto_botao_acao_mobile
                                                            ,pr_idacao_botao_acao_mobile => pr_idacao_botao_acao_mobile
                                                            ,pr_cdmenu_acao_mobile => pr_cdmenu_acao_mobile
                                                            ,pr_dslink_acao_mobile => pr_dslink_acao_mobile
                                                            ,pr_cdicone => pr_cdicone
                                                            ,pr_inexibir_banner => pr_inexibir_banner
                                                            ,pr_nmimagem_banner => pr_nmimagem_banner
                                                            ,pr_intipo_repeticao => pr_intipo_repeticao
                                                            ,pr_nrdias_semana => pr_nrdias_semana
                                                            ,pr_nrsemanas_repeticao => pr_nrsemanas
                                                            ,pr_nrdias_mes => pr_nrdias_mes
                                                            ,pr_nrmeses_repeticao => pr_nrmeses
                                                            ,pr_hrenvio_mensagem => pr_hrenvio_mensagem
                                                            ,pr_nmdcampo => pr_nmdcampo
                                                            ,pr_dscritic => vr_dscritic);
    
    IF vr_validacao = 0 THEN
      RAISE ex_erro;
    END IF;
    
    -- Insere uma nova mensagem (e atualiza o parametro das autom�ticas)
    INSERT INTO tbgen_notif_msg_cadastro msg
             (msg.cdmensagem
             ,msg.cdorigem_mensagem
             ,msg.dstitulo_mensagem
             ,msg.cdicone
             ,msg.dstexto_mensagem
             ,msg.dshtml_mensagem
             ,msg.inenviar_push
             ,msg.inexibir_banner
             ,msg.nmimagem_banner
             ,msg.inexibe_botao_acao_mobile
             ,msg.dstexto_botao_acao_mobile
             ,msg.dslink_acao_mobile
             ,msg.cdmenu_acao_mobile
             ,msg.dsmensagem_acao_mobile)
       VALUES
             ((SELECT NVL(MAX(seq.cdmensagem),0)+1 FROM tbgen_notif_msg_cadastro seq)
             ,pr_cdorigem_mensagem
             ,pr_dstitulo_mensagem
             ,pr_cdicone
             ,pr_dstexto_mensagem
             ,vr_dshtml_mensagem
             ,pr_inenviar_push
             ,pr_inexibir_banner
             ,pr_nmimagem_banner
             ,pr_inexibe_botao_acao_mobile
             ,pr_dstexto_botao_acao_mobile
             ,DECODE(pr_idacao_botao_acao_mobile,1,pr_dslink_acao_mobile,NULL) --dslink_acao_mobile
             ,DECODE(pr_idacao_botao_acao_mobile,2,pr_cdmenu_acao_mobile,NULL) --cdmenu_acao_mobile
             ,pr_dsmensagem_acao_mobile)
     RETURNING msg.cdmensagem INTO vr_cdmensagem;
    
    --Atualiza o registro de Mensagem
    /*UPDATE tbgen_notif_msg_cadastro msg
       SET msg.dstitulo_mensagem 		     = pr_dstitulo_mensagem
          ,msg.cdicone 				           = pr_cdicone
          ,msg.inenviar_push 		         = pr_inenviar_push
          ,msg.dstexto_mensagem 		     = pr_dstexto_mensagem
          ,msg.inexibir_banner 		       = pr_inexibir_banner
          ,msg.nmimagem_banner 		       = pr_nmimagem_banner
          ,msg.dshtml_mensagem		       = vr_dshtml_mensagem
          ,msg.inexibe_botao_acao_mobile = pr_inexibe_botao_acao_mobile
          ,msg.dstexto_botao_acao_mobile = pr_dstexto_botao_acao_mobile
          ,msg.dslink_acao_mobile 	     = DECODE(pr_idacao_botao_acao_mobile,1,pr_dslink_acao_mobile,NULL)
          ,msg.cdmenu_acao_mobile 	     = DECODE(pr_idacao_botao_acao_mobile,2,pr_cdmenu_acao_mobile,NULL)
          ,msg.dsmensagem_acao_mobile	   = pr_dsmensagem_acao_mobile
     WHERE msg.cdmensagem = rw_mensagem.cdmensagem;*/
    
    --Atualiza o registro de Mensagem Autom�tica
    UPDATE tbgen_notif_automatica_prm aut
       SET aut.cdmensagem          = vr_cdmensagem
          ,aut.inmensagem_ativa    = pr_inmensagem_ativa
          ,aut.intipo_repeticao    = pr_intipo_repeticao
          ,aut.nrdias_semana       = pr_nrdias_semana
          ,aut.nrsemanas_repeticao = pr_nrsemanas
          ,aut.nrdias_mes          = pr_nrdias_mes
          ,aut.nrmeses_repeticao   = pr_nrmeses
          ,aut.hrenvio_mensagem    = TO_CHAR(TO_DATE(pr_hrenvio_mensagem,'HH24:MI'),'SSSSS')
     WHERE aut.cdorigem_mensagem = pr_cdorigem_mensagem
       AND aut.cdmotivo_mensagem = pr_cdmotivo_mensagem;

  EXCEPTION
    WHEN OTHERS THEN
      IF vr_cdcritic <> 0 THEN -- Tenta pegar a exception pelo CDCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSIF vr_dscritic IS NOT NULL THEN -- Tenta pegar a exception pelo DSCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      ELSE  -- Sen�o, Dispara a EXCEPTION padr�o
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela '|| NMDATELA ||': ' || SQLERRM;
      END IF;

      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_mantem_msg_automatica;

  PROCEDURE pc_mantem_msg_manual(pr_cdmensagem                IN TBGEN_NOTIF_MSG_CADASTRO.CDMENSAGEM%TYPE               -- Codigo da a mensagem
                                ,pr_dstitulo_mensagem         IN TBGEN_NOTIF_MSG_CADASTRO.DSTITULO_MENSAGEM%TYPE        -- Titulo da mensagem
                                ,pr_dstexto_mensagem          IN TBGEN_NOTIF_MSG_CADASTRO.DSTEXTO_MENSAGEM%TYPE         -- Texto da mensagem
                                ,pr_dshtml_mensagem           IN TBGEN_NOTIF_MSG_CADASTRO.DSHTML_MENSAGEM%TYPE          -- Conteudo da notificacao no formato Html
                                ,pr_inexibe_botao_acao_mobile IN TBGEN_NOTIF_MSG_CADASTRO.INEXIBE_BOTAO_ACAO_MOBILE%TYPE-- Indicador se exibe botao de acao da notificacao no Cecred Mobile
                                ,pr_dstexto_botao_acao_mobile IN TBGEN_NOTIF_MSG_CADASTRO.DSTEXTO_BOTAO_ACAO_MOBILE%TYPE-- Texto do botao de acao da notificacao no Cecred Mobile
                                ,pr_idacao_botao_acao_mobile  IN NUMBER                                                 -- A��o do bot�o de a��o do Cecred Mobile. 1 - Abrir Link, 2 - Abrir tela
                                ,pr_cdmenu_acao_mobile        IN TBGEN_NOTIF_MSG_CADASTRO.CDMENU_ACAO_MOBILE%TYPE       -- Codigo da tela do Cecred Mobile que deve ser aberta ao clicar no botao de acao
                                ,pr_dslink_acao_mobile        IN TBGEN_NOTIF_MSG_CADASTRO.DSLINK_ACAO_MOBILE%TYPE       -- Link para ser acessado ao clicar no botao de acao no Cecred Mobile
                                ,pr_dsmensagem_acao_mobile    IN TBGEN_NOTIF_MSG_CADASTRO.DSMENSAGEM_ACAO_MOBILE%TYPE   -- Mensagem de confirmacao que sera exibida ao clicar no botao de acao no Cecred Mobile
                                ,pr_cdicone                   IN TBGEN_NOTIF_MSG_CADASTRO.CDICONE%TYPE                  -- Codigo do icone da notificacao
                                ,pr_inexibir_banner           IN TBGEN_NOTIF_MSG_CADASTRO.INEXIBIR_BANNER%TYPE          -- Indicador de exibicao da imagem de banner
                                ,pr_nmimagem_banner           IN TBGEN_NOTIF_MSG_CADASTRO.NMIMAGEM_BANNER%TYPE          -- Nome da imagem do banner para notificacao nao lida
                                ,pr_inenviar_push            IN TBGEN_NOTIF_MSG_CADASTRO.INENVIAR_PUSH%TYPE           -- Indicador se envia push notification (0-Nao/ 1-Sim)
                                -- Par�metros para mensagens manuais
                                ,pr_dtenvio_mensagem      IN VARCHAR2                                         -- Data do envio da mensagem
                                ,pr_hrenvio_mensagem      IN VARCHAR2                                         -- Hora do envio da mensagem
                                ,pr_tpfiltro              IN TBGEN_NOTIF_MANUAL_PRM.TPFILTRO%TYPE             -- Tipo do filtro (1-Filtro manual/ 2-Importacao de arquivo CSV)
                                ,pr_dsfiltro_cooperativas IN TBGEN_NOTIF_MANUAL_PRM.DSFILTRO_COOPERATIVAS%TYPE-- Filtro de cooperativas: Codigos separados por virgula
                                ,pr_dsfiltro_tipos_conta  IN TBGEN_NOTIF_MANUAL_PRM.DSFILTRO_TIPOS_CONTA%TYPE -- Filtro de tipo de conta: Tipos separados por virgula
                                ,pr_tpfiltro_mobile       IN TBGEN_NOTIF_MANUAL_PRM.TPFILTRO_MOBILE%TYPE      -- Filtro para usuario do Cecred Mobile (0-Todas as plataformas/ 1-Cooperados sem Mobile/ 2-Android/ 3-IOS)
                                ,pr_nmarquivo_csv         IN VARCHAR                                          -- Nome do arquivo CSV para envio das notifica��es
                                ,pr_caminho_arq_upload    IN VARCHAR2                                         -- Caminho do arquivo CSV
                                
                                ,pr_xmllog       IN VARCHAR2                                                  --> XML com informacoes de LOG
                                ,pr_cdcritic    OUT PLS_INTEGER                                               --> Codigo da critica
                                ,pr_dscritic    OUT VARCHAR2                                                  --> Descricao da critica
                                ,pr_retxml   IN OUT NOCOPY xmltype                                            --> Arquivo de retorno do XML
                                ,pr_nmdcampo    OUT VARCHAR2                                                  --> Nome do campo com erro
                                ,pr_des_erro    OUT VARCHAR2) IS                                              --> Erros do processo
    -- Constantes
    TIPO_AVISOS tbgen_notif_msg_tipo.cdtipo_mensagem%TYPE := 3; -- Origem: Avisos (Notifica��o manual)
    ORIGEM_AVISOS tbgen_notif_msg_cadastro.cdorigem_mensagem%TYPE := 1; -- Tipo: Avisos (Notifica��o manual)
    SITUACAO_PENDENTE tbgen_notif_manual_prm.cdsituacao_mensagem%TYPE := 1; -- Situa��o: Pendente
    
    -- Cursor para buscar a situa��o da mensagem
    CURSOR cr_situacao_mensagem IS
     SELECT man.cdsituacao_mensagem
           ,man.dhenvio_mensagem
       FROM tbgen_notif_manual_prm     man
           ,tbgen_notif_msg_cadastro   msg
      WHERE man.cdmensagem = msg.cdmensagem
        AND man.cdmensagem = pr_cdmensagem;
    rw_situacao_mensagem cr_situacao_mensagem%ROWTYPE;
    cr_situacao_mensagem_found BOOLEAN := FALSE;
    
    --Vari�veis
    vr_cdmensagem tbgen_notif_msg_cadastro.cdorigem_mensagem%TYPE;
    vr_dhenvio_mensagem tbgen_notif_manual_prm.dhenvio_mensagem%TYPE;
    vr_dshtml_mensagem tbgen_notif_msg_cadastro.dshtml_mensagem%TYPE;
    vr_dsxml_destinatarios CLOB;
    vr_dsfiltro_cooperativas tbgen_notif_manual_prm.dsfiltro_cooperativas%TYPE;
    vr_validacao NUMBER:= 0;
    vr_inalterou_dhenvio NUMBER := 0;
    ex_erro EXCEPTION;
    
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Procedure para percorrer o arquivo CSV importado e agendar as notifica��es. Executa apenas se pr_tpfiltro = 2 (Importa��o de CSV)
    PROCEDURE pc_cria_notificacoes_csv(pr_nmarquivo_csv         IN VARCHAR                                          -- Nome do arquivo CSV para envio das notifica��es
                                      ,pr_caminho_arq_upload    IN VARCHAR2
                                      ,pr_cdmensagem            IN tbgen_notif_manual_prm.cdmensagem%TYPE
                                      ,pr_inalterou_dhenvio     IN NUMBER  -- Indicador se o usu�rio alterou a data do envio
                                      ,pr_dhenvio               IN tbgen_notif_manual_prm.dhenvio_mensagem%TYPE
                                      ,pr_xmllog                IN VARCHAR2 --> XML com informa��es de LOG
																		  ,pr_cdcritic              OUT PLS_INTEGER --> C�digo da cr�tica
																		  ,pr_dscritic              OUT VARCHAR2 --> Descri��o da cr�tica
																		  ,pr_retxml                IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																		  ,pr_nmdcampo              OUT VARCHAR2 --> Nome do Campo
																		  ,pr_des_erro              OUT VARCHAR2) IS

      vr_destinatarios NOTI0001.typ_destinatarios_notif;
    BEGIN
      
      -- Se deve entrou um xml gera as notificacoes (apaga as anticas se houver)
      IF pr_nmarquivo_csv IS NOT NULL AND pr_caminho_arq_upload IS NOT NULL THEN
        
        -- Delete Notifica��es e Pushs para n�o duplicar registros (quando o usu�rio importou um CSV, e depois importou outro CSV para substitur o anterior)
        DELETE FROM tbgen_notif_push push WHERE push.cdnotificacao IN (SELECT noti.cdnotificacao FROM tbgen_notificacao noti WHERE noti.cdmensagem = pr_cdmensagem);
        DELETE FROM tbgen_notificacao noti WHERE noti.cdmensagem = pr_cdmensagem;
        
        -- Carrega os destinat�rios para a tabela de importa��o
        pc_importar_arquivo_notif(pr_arquivo    => pr_nmarquivo_csv
                                 ,pr_dirarquivo => pr_caminho_arq_upload
                                 ,pr_destinatarios => vr_destinatarios
                                 ,pr_xmllog     => pr_xmllog
                                 ,pr_cdcritic   => pr_cdcritic
                                 ,pr_dscritic   => pr_dscritic
                                 ,pr_retxml     => pr_retxml
                                 ,pr_nmdcampo   => pr_nmdcampo
                                 ,pr_des_erro   => pr_des_erro);
                                        
        -- Cria as notifica��es para os destinat�rios que est�o no CSV
        NOTI0001.pc_cria_notificacoes(pr_cdmensagem    => pr_cdmensagem    
                                     ,pr_dhenvio       => pr_dhenvio
                                     ,pr_destinatarios => vr_destinatarios);
        
      -- Se n�o recebeu XML e a data foi alterada, ent�o atualiza as datas das notifica��es que j� foram geradas antes...
      ELSIF pr_inalterou_dhenvio = 1 THEN
         UPDATE tbgen_notificacao noti
            SET noti.dhenvio = pr_dhenvio
          WHERE noti.cdmensagem = pr_cdmensagem;
          
          -- Atualiza a data de envio dos lotes de push desta notifica��o
          UPDATE tbgen_notif_lote_push lote
            SET lote.dhagendamento = pr_dhenvio
          WHERE lote.cdlote_push IN (SELECT DISTINCT push.cdlote_push
                                       FROM tbgen_notif_push push
                                           ,tbgen_notificacao noti
                                      WHERE noti.cdnotificacao = push.cdnotificacao
                                        AND noti.cdmensagem = pr_cdmensagem);
      END IF;
    
    END pc_cria_notificacoes_csv;

  BEGIN
    
    -- Extrai os dados vindos do XML
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    -- Obt�m a data + hora
    vr_dhenvio_mensagem := TRUNC(TO_DATE(pr_dtenvio_mensagem,'dd/mm/RRRR')) +
                           (TO_NUMBER(TO_CHAR(TO_DATE(pr_hrenvio_mensagem,'HH24:MI'),'SSSSS'))/60/60/24);
    
    -- Remove o CDATA dos XMLs
    vr_dshtml_mensagem := SUBSTR(pr_dshtml_mensagem,10,LENGTH(pr_dshtml_mensagem)-12);
    --vr_dsxml_destinatarios := SUBSTR(pr_dsxml_destinatarios,10,LENGTH(pr_dsxml_destinatarios)-12);
    
    
    -- Se for UPDATE de registro existente, ent�o valida o pr_cdmensagem
    IF pr_cdmensagem <> 0 THEN
      
      -- Valida pela situa��o se ainda pode alterar (S� pode alterar se estiver PENDENTE)
      OPEN cr_situacao_mensagem;
      FETCH cr_situacao_mensagem
      INTO rw_situacao_mensagem;
      cr_situacao_mensagem_found := cr_situacao_mensagem%FOUND;
      CLOSE cr_situacao_mensagem;
    
      -- Se n�o encontrou
      IF NOT cr_situacao_mensagem_found THEN
        vr_dscritic := 'Registro de Mensagem n�o encontrado';
        RAISE ex_erro;
      -- Se n�o estiver PENDENTE ou j� foi enviada
      ELSIF rw_situacao_mensagem.cdsituacao_mensagem <> SITUACAO_PENDENTE OR rw_situacao_mensagem.dhenvio_mensagem <= SYSDATE THEN
        vr_dscritic := 'Esta mensagem n�o pode mais ser alterada';
        RAISE ex_erro;
      END IF;
      
      -- Verifica se o usu�rio alterou a data
      vr_inalterou_dhenvio := CASE WHEN rw_situacao_mensagem.dhenvio_mensagem <> vr_dhenvio_mensagem THEN 1 ELSE 0 END;
      
    END IF;
    
    -- Se for um operador de cooperativa, ignora o filtro de cooperativas e trava a coop atual
    IF vr_cdcooper <> 3 THEN
      vr_dsfiltro_cooperativas := vr_cdcooper;
    ELSE
      vr_dsfiltro_cooperativas := pr_dsfiltro_cooperativas;
    END IF;
    
    -- Valida os dados da mensagem
    vr_validacao := TELA_ENVNOT.fn_valida_cadastro_mensagem (pr_cdtipo_mensagem => TIPO_AVISOS -- Avisos (fixo)
                                                            ,pr_dstitulo_mensagem => pr_dstitulo_mensagem
                                                            ,pr_dstexto_mensagem => pr_dstexto_mensagem
                                                            ,pr_dshtml_mensagem => vr_dshtml_mensagem
                                                            ,pr_dsvariaveis_disponiveis => DESCRICAOVARIAVEISUNIVERSAIS
                                                            ,pr_inexibe_botao_acao_mobile => pr_inexibe_botao_acao_mobile
                                                            ,pr_dstexto_botao_acao_mobile => pr_dstexto_botao_acao_mobile
                                                            ,pr_idacao_botao_acao_mobile => pr_idacao_botao_acao_mobile
                                                            ,pr_cdmenu_acao_mobile => pr_cdmenu_acao_mobile
                                                            ,pr_dslink_acao_mobile => pr_dslink_acao_mobile
                                                            ,pr_cdicone => pr_cdicone
                                                            ,pr_inexibir_banner => pr_inexibir_banner
                                                            ,pr_nmimagem_banner => pr_nmimagem_banner
                                                            ,pr_dhenvio_mensagem => vr_dhenvio_mensagem
                                                            ,pr_hrenvio_mensagem => pr_hrenvio_mensagem
                                                            ,pr_tpfiltro => pr_tpfiltro
                                                            ,pr_dsfiltro_cooperativas => vr_dsfiltro_cooperativas
                                                            ,pr_dsfiltro_tipos_conta => pr_dsfiltro_tipos_conta
                                                            ,pr_nmdcampo => pr_nmdcampo
                                                            ,pr_dscritic => vr_dscritic);
                                                            
    IF vr_validacao = 0 THEN
        RAISE vr_exc_erro;
    END IF;
    
    vr_cdmensagem := NVL(pr_cdmensagem,0);
    
    -- Se for INSERT de uma nova mensagem
    IF vr_cdmensagem = 0 THEN
      BEGIN 
      INSERT INTO tbgen_notif_msg_cadastro msg
                 (msg.cdmensagem
                 ,msg.cdorigem_mensagem
                 ,msg.dstitulo_mensagem
                 ,msg.cdicone
                 ,msg.dstexto_mensagem
                 ,msg.dshtml_mensagem
                 ,msg.inenviar_push
                 ,msg.inexibir_banner
                 ,msg.nmimagem_banner
                 ,msg.inexibe_botao_acao_mobile
                 ,msg.dstexto_botao_acao_mobile
                 ,msg.dslink_acao_mobile
                 ,msg.cdmenu_acao_mobile
                 ,msg.dsmensagem_acao_mobile)
           VALUES
                 ((SELECT NVL(MAX(seq.cdmensagem),0)+1 FROM tbgen_notif_msg_cadastro seq)
                 ,ORIGEM_AVISOS -- cdorigem_mensagem
                 ,pr_dstitulo_mensagem
                 ,pr_cdicone
                 ,pr_dstexto_mensagem
                 ,vr_dshtml_mensagem
                 ,pr_inenviar_push
                 ,pr_inexibir_banner
                 ,pr_nmimagem_banner
                 ,pr_inexibe_botao_acao_mobile
                 ,pr_dstexto_botao_acao_mobile
                 ,DECODE(pr_idacao_botao_acao_mobile,1,pr_dslink_acao_mobile,NULL) --dslink_acao_mobile
                 ,DECODE(pr_idacao_botao_acao_mobile,2,pr_cdmenu_acao_mobile,NULL) --cdmenu_acao_mobile
                 ,pr_dsmensagem_acao_mobile)
         RETURNING msg.cdmensagem INTO vr_cdmensagem;
       EXCEPTION
         WHEN OTHERS THEN
           vr_dscritic := 'Erro ao inserir registro(TBGEN_NOTIF_MSG_CADASTRO) - ' || vr_cdmensagem || '. Erro: ' || SQLERRM;
           RAISE;
       END;   

      BEGIN       
        INSERT INTO tbgen_notif_manual_prm man
                    (man.cdmensagem
                    ,man.cdcooper
                    ,man.cdoperad
                    ,man.dhcadastro_mensagem
                    ,man.dhenvio_mensagem
                    ,man.cdsituacao_mensagem
                    ,man.tpfiltro
                    ,man.dsfiltro_cooperativas
                    ,man.dsfiltro_tipos_conta
                    ,man.tpfiltro_mobile
                    ,man.nmarquivo_csv
                    ) VALUES
                    (vr_cdmensagem
                    ,vr_cdcooper
                    ,vr_cdoperad
                    ,SYSDATE --dhcadastro_mensagem
                    ,vr_dhenvio_mensagem
                    ,1 -- Situa��o Ativa
                    ,pr_tpfiltro
                    ,vr_dsfiltro_cooperativas
                    ,pr_dsfiltro_tipos_conta
                    ,pr_tpfiltro_mobile
                    ,pr_nmarquivo_csv
                    );
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir registro(TBGEN_NOTIF_MANUAL_PRM). Erro: ' || SQLERRM;
          RAISE;
      END;
    ELSE  -- Se for UPDATE de registro existente
      
      BEGIN
        --Atualiza o registro de Mensagem
        UPDATE tbgen_notif_msg_cadastro msg
           SET msg.dstitulo_mensagem 		     = pr_dstitulo_mensagem
              ,msg.cdicone 				           = pr_cdicone
              ,msg.inenviar_push 		         = pr_inenviar_push
              ,msg.dstexto_mensagem 		     = pr_dstexto_mensagem
              ,msg.inexibir_banner 		       = pr_inexibir_banner
              ,msg.nmimagem_banner 		       = pr_nmimagem_banner
              ,msg.dshtml_mensagem		       = vr_dshtml_mensagem
              ,msg.inexibe_botao_acao_mobile = pr_inexibe_botao_acao_mobile
              ,msg.dstexto_botao_acao_mobile = pr_dstexto_botao_acao_mobile
              ,msg.dslink_acao_mobile 	     = DECODE(pr_idacao_botao_acao_mobile,1,pr_dslink_acao_mobile,NULL) --dslink_acao_mobile
              ,msg.cdmenu_acao_mobile 	     = DECODE(pr_idacao_botao_acao_mobile,2,pr_cdmenu_acao_mobile,NULL) --cdmenu_acao_mobile
              ,msg.dsmensagem_acao_mobile	   = pr_dsmensagem_acao_mobile
         WHERE msg.cdmensagem = vr_cdmensagem;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar registro(TBGEN_NOTIF_MSG_CADASTRO). Erro: ' || SQLERRM;
          RAISE;
      END;
      
      BEGIN
        --Atualiza o registro de Mensagem manual
        UPDATE tbgen_notif_manual_prm man
          SET man.cdcooper                = vr_cdcooper
             ,man.cdoperad                = vr_cdoperad
             ,man.dhenvio_mensagem        = vr_dhenvio_mensagem
             ,man.tpfiltro                = pr_tpfiltro
             ,man.dsfiltro_cooperativas   = vr_dsfiltro_cooperativas
             ,man.dsfiltro_tipos_conta    = pr_dsfiltro_tipos_conta
             ,man.tpfiltro_mobile         = pr_tpfiltro_mobile
             ,man.nmarquivo_csv		        = pr_nmarquivo_csv
        WHERE man.cdmensagem = vr_cdmensagem;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar registro(TBGEN_NOTIF_MANUAL_PRM). Erro: ' || SQLERRM;
          RAISE;
      END;
    END IF;
    
    -- Se foi importa��o de CSV, ent�o cria/altera os agendamentos das notifica��es
    IF pr_tpfiltro = 2 THEN
      pc_cria_notificacoes_csv(pr_nmarquivo_csv       => pr_nmarquivo_csv                     
                              ,pr_caminho_arq_upload  => pr_caminho_arq_upload
                              ,pr_cdmensagem          => vr_cdmensagem
                              ,pr_inalterou_dhenvio   => vr_inalterou_dhenvio
                              ,pr_dhenvio             => vr_dhenvio_mensagem
                              ,pr_xmllog              => pr_xmllog
                              ,pr_cdcritic            => pr_cdcritic
                              ,pr_dscritic            => pr_dscritic
                              ,pr_retxml              => pr_retxml
                              ,pr_nmdcampo            => pr_nmdcampo
                              ,pr_des_erro            => pr_des_erro);
    ELSE -- Se n�o for CSV, apaga os registros das notifica��es (para n�o ficar lixo caso o usu�rio importar um CSV e depois alterar o tpfiltro)
      DELETE FROM tbgen_notificacao noti WHERE noti.cdmensagem = vr_cdmensagem;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF vr_cdcritic <> 0 THEN -- Tenta pegar a exception pelo CDCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSIF vr_dscritic IS NOT NULL THEN -- Tenta pegar a exception pelo DSCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      ELSE  -- Sen�o, Dispara a EXCEPTION padr�o
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela '|| NMDATELA ||' (Manual): ' || SQLERRM;
      END IF;

      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_mantem_msg_manual;

  PROCEDURE pc_lista_mensagens_manuais(pr_xmllog       IN VARCHAR2       --> XML com informacoes de LOG
                                      ,pr_cdcritic    OUT PLS_INTEGER    --> Codigo da critica
                                      ,pr_dscritic    OUT VARCHAR2       --> Descricao da critica
                                      ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                      ,pr_nmdcampo    OUT VARCHAR2       --> Nome do campo com erro
                                      ,pr_des_erro    OUT VARCHAR2) IS   --> Erros do processo
    
    -- Cursor para obter os dados da Mensagem autom�tica
    CURSOR cr_mensagens(pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT man.cdmensagem
          ,TO_CHAR(man.dhenvio_mensagem,'dd/mm/yyyy') || ' - ' || TO_CHAR(man.dhenvio_mensagem,'HH24:MI') dhenvio_mensagem
          ,msg.dstitulo_mensagem
          ,man.cdsituacao_mensagem
          ,(SELECT sit.dssituacao_mensagem
              FROM tbgen_notif_msg_situacao sit
             WHERE sit.cdsituacao_mensagem = man.cdsituacao_mensagem) dssituacao_mensagem
          ,man.cdcooper
          ,man.cdoperad
          ,(SELECT ope.nmoperad
              FROM crapope ope
             WHERE ope.cdcooper = man.cdcooper
               AND UPPER(ope.cdoperad) = UPPER(man.cdoperad)) nmoperad
          ,(SELECT COUNT(*) FROM tbgen_notificacao ntf WHERE ntf.cdmensagem = msg.cdmensagem) qtenviados
          ,(SELECT COUNT(*) FROM tbgen_notificacao ntf WHERE ntf.cdmensagem = msg.cdmensagem AND ntf.dhleitura IS NOT NULL) qtlidos
      FROM tbgen_notif_manual_prm   man
          ,tbgen_notif_msg_cadastro msg
     WHERE man.cdmensagem = msg.cdmensagem
       AND man.cdcooper = pr_cdcooper -- S� enxerga as mensagens cadastradas pela mesma cooperativa
     ORDER BY man.dhcadastro_mensagem DESC;
    
    -- Vari�veis
    vr_contador NUMBER(10);
    
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
  BEGIN
    
    -- Extrai os dados vindos do XML
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'mensagens', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    
    -- Obt�m os dados das mensagens
    vr_contador := 0;
    FOR rw_mensagem IN cr_mensagens(vr_cdcooper) LOOP
      -- Gera o XML
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagens', pr_posicao => 0, pr_tag_nova => 'mensagem', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => vr_contador, pr_tag_nova => 'cdmensagem', pr_tag_cont => rw_mensagem.cdmensagem, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => vr_contador, pr_tag_nova => 'dhenvio_mensagem', pr_tag_cont => rw_mensagem.dhenvio_mensagem, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => vr_contador, pr_tag_nova => 'dstitulo_mensagem', pr_tag_cont => rw_mensagem.dstitulo_mensagem, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => vr_contador, pr_tag_nova => 'cdsituacao_mensagem', pr_tag_cont => rw_mensagem.cdsituacao_mensagem, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => vr_contador, pr_tag_nova => 'dssituacao_mensagem', pr_tag_cont => rw_mensagem.dssituacao_mensagem, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => vr_contador, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_mensagem.cdcooper, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad', pr_tag_cont => rw_mensagem.cdoperad, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => vr_contador, pr_tag_nova => 'nmoperad', pr_tag_cont => rw_mensagem.nmoperad, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => vr_contador, pr_tag_nova => 'qtenviados', pr_tag_cont => rw_mensagem.qtenviados, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'mensagem', pr_posicao => vr_contador, pr_tag_nova => 'qtlidos', pr_tag_cont => rw_mensagem.qtlidos, pr_des_erro => vr_dscritic);
      vr_contador := vr_contador+1;
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      IF vr_cdcritic <> 0 THEN -- Tenta pegar a exception pelo CDCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSIF vr_dscritic IS NOT NULL THEN -- Tenta pegar a exception pelo DSCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      ELSE  -- Sen�o, Dispara a EXCEPTION padr�o
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela '|| NMDATELA ||': ' || SQLERRM;
      END IF;

      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_lista_mensagens_manuais;

  PROCEDURE pc_cancela_msg_manual(pr_cdmensagem   IN TBGEN_NOTIF_MSG_CADASTRO.CDMENSAGEM%TYPE --> Codigo da a mensagem
                                 ,pr_xmllog       IN VARCHAR2                                 --> XML com informacoes de LOG
                                 ,pr_cdcritic    OUT PLS_INTEGER                              --> Codigo da critica
                                 ,pr_dscritic    OUT VARCHAR2                                 --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY xmltype                           --> Arquivo de retorno do XML
                                 ,pr_nmdcampo    OUT VARCHAR2                                 --> Nome do campo com erro
                                 ,pr_des_erro    OUT VARCHAR2) IS                             --> Erros do processo
    -- Constantes
    SITUACAO_PENDENTE tbgen_notif_manual_prm.cdsituacao_mensagem%TYPE := 1; -- Situa��o: Pendente
    SITUACAO_CANCELADA tbgen_notif_manual_prm.cdsituacao_mensagem%TYPE := 3; -- Situa��o: Cancelada
    
    -- Cursor para buscar a situa��o da mensagem
    CURSOR cr_situacao_mensagem(pr_cdcooper crapcop.cdcooper%TYPE) IS
     SELECT man.cdsituacao_mensagem
       FROM tbgen_notif_manual_prm     man
           ,tbgen_notif_msg_cadastro   msg
      WHERE man.cdmensagem = msg.cdmensagem
        AND man.cdcooper = pr_cdcooper
        AND man.cdmensagem = pr_cdmensagem;
    rw_situacao_mensagem cr_situacao_mensagem%ROWTYPE;
    cr_situacao_mensagem_found BOOLEAN := FALSE;
    
    --Vari�veis
    ex_erro EXCEPTION;
    
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

  BEGIN
    
    -- Extrai os dados vindos do XML
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    -- Valida pela situa��o se ainda pode alterar (S� pode alterar se estiver PENDENTE)
    OPEN cr_situacao_mensagem(pr_cdcooper => vr_cdcooper);
    FETCH cr_situacao_mensagem
    INTO rw_situacao_mensagem;
    cr_situacao_mensagem_found := cr_situacao_mensagem%FOUND;
    CLOSE cr_situacao_mensagem;
    
    IF NOT cr_situacao_mensagem_found THEN
      vr_dscritic := 'Registro de Mensagem n�o encontrado';
      RAISE ex_erro;
    ELSIF rw_situacao_mensagem.cdsituacao_mensagem = SITUACAO_CANCELADA THEN -- Se estiver CANCELADA
      vr_dscritic := 'Esta mensagem j� foi cancelada';
      RAISE ex_erro;
    ELSIF rw_situacao_mensagem.cdsituacao_mensagem <> SITUACAO_PENDENTE THEN -- Se n�o estiver PENDENTE
      vr_dscritic := 'Esta mensagem n�o pode mais ser cancelada';
      RAISE ex_erro;
    END IF;
    
    --Atualiza o registro de Mensagem manual
    UPDATE tbgen_notif_manual_prm man
       SET man.cdsituacao_mensagem = 3 -- CANCELADO
     WHERE man.cdmensagem = pr_cdmensagem;
     
    --Se for filtro por CSV, apaga os pushes e notifica��es j� geradas no momento do carregamento do CSV
    --(quando o usu�rio importou um CSV, e depois importou outro CSV para substitur o anterior)
    DELETE FROM tbgen_notif_push push WHERE push.cdnotificacao IN (SELECT noti.cdnotificacao FROM tbgen_notificacao noti WHERE noti.cdmensagem = pr_cdmensagem);
    DELETE FROM tbgen_notificacao noti WHERE noti.cdmensagem = pr_cdmensagem;

  EXCEPTION
    WHEN OTHERS THEN
      IF vr_cdcritic <> 0 THEN -- Tenta pegar a exception pelo CDCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSIF vr_dscritic IS NOT NULL THEN -- Tenta pegar a exception pelo DSCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      ELSE  -- Sen�o, Dispara a EXCEPTION padr�o
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela '|| NMDATELA ||': ' || SQLERRM;
      END IF;

      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_cancela_msg_manual;

  PROCEDURE pc_busca_origens_mensagens(pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                      ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                      ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo 
    
    -- Cursor para buscar a situa��o da mensagem
    CURSOR cr_tbgen_notif_msg_origem IS
     SELECT ori.cdorigem_mensagem AS cdorigem_mensagem
           ,ori.dsorigem_mensagem AS dsorigem_mensagem
           ,ori.cdtipo_mensagem   AS cdtipo_mensagem
           ,tip.dstipo_mensagem   AS dstipo_mensagem
       FROM tbgen_notif_msg_origem ori
           ,tbgen_notif_msg_tipo   tip
      WHERE ori.cdtipo_mensagem = tip.cdtipo_mensagem
        AND tip.cdtipo_mensagem IN (1,2) -- Servi�os e Transa��es (Envios autom�ticos)
        ORDER BY dsorigem_mensagem;

    rw_tbgen_notif_msg_origem cr_tbgen_notif_msg_origem%ROWTYPE;
     
    --Vari�veis
    ex_erro EXCEPTION;
    
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_contador INTEGER := 0;

  BEGIN
    
    -- Extrai os dados vindos do XML
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'origens', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    FOR rw_tbgen_notif_msg_origem IN cr_tbgen_notif_msg_origem LOOP

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'origens', pr_posicao => 0, pr_tag_nova => 'origem', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'origem', pr_posicao => vr_contador, pr_tag_nova => 'cdorigem_mensagem', pr_tag_cont => rw_tbgen_notif_msg_origem.cdorigem_mensagem, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'origem', pr_posicao => vr_contador, pr_tag_nova => 'dsorigem_mensagem', pr_tag_cont => rw_tbgen_notif_msg_origem.dsorigem_mensagem, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'origem', pr_posicao => vr_contador, pr_tag_nova => 'cdtipo_mensagem',   pr_tag_cont => rw_tbgen_notif_msg_origem.cdtipo_mensagem, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'origem', pr_posicao => vr_contador, pr_tag_nova => 'dstipo_mensagem',   pr_tag_cont => rw_tbgen_notif_msg_origem.dstipo_mensagem, pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
            
    END LOOP;    

  EXCEPTION
    WHEN OTHERS THEN
      IF vr_cdcritic <> 0 THEN -- Tenta pegar a exception pelo CDCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSIF vr_dscritic IS NOT NULL THEN -- Tenta pegar a exception pelo DSCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      ELSE  -- Sen�o, Dispara a EXCEPTION padr�o
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela '|| NMDATELA ||': ' || SQLERRM;
      END IF;

      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_busca_origens_mensagens;

  PROCEDURE pc_busca_motivos_mensagens(pr_cdorigem_mensagem tbgen_notif_automatica_prm.cdorigem_mensagem%TYPE --> Origem Mensagem
                                      ,pr_xmllog   IN VARCHAR2                                                --> XML com informa��es de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER                                            --> C�digo da cr�tica
                                      ,pr_dscritic OUT VARCHAR2                                               --> Descri��o da cr�tica
                                      ,pr_retxml   IN OUT NOCOPY XMLType                                      --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2                                               --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS                                           --> Erros do processo 
    
    -- Cursor para buscar a situa��o da mensagem
    CURSOR cr_tbgen_notif_automatica_prm IS
     SELECT aut.cdmotivo_mensagem
           ,aut.dsmotivo_mensagem
      FROM tbgen_notif_automatica_prm aut
     WHERE aut.cdorigem_mensagem = pr_cdorigem_mensagem
     ORDER BY aut.cdmotivo_mensagem;

    rw_tbgen_notif_automatica_prm cr_tbgen_notif_automatica_prm%ROWTYPE;
     
    --Vari�veis
    ex_erro EXCEPTION;
    
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_contador INTEGER := 0;

  BEGIN
    
    -- Extrai os dados vindos do XML
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'motivos', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    FOR rw_tbgen_notif_automatica_prm IN cr_tbgen_notif_automatica_prm LOOP

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'motivos', pr_posicao => 0, pr_tag_nova => 'motivo', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'motivo', pr_posicao => vr_contador, pr_tag_nova => 'cdmotivo_mensagem', pr_tag_cont => rw_tbgen_notif_automatica_prm.cdmotivo_mensagem, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'motivo', pr_posicao => vr_contador, pr_tag_nova => 'dsmotivo_mensagem', pr_tag_cont => rw_tbgen_notif_automatica_prm.dsmotivo_mensagem, pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
         
    END LOOP;    

  EXCEPTION
    WHEN OTHERS THEN
      IF vr_cdcritic <> 0 THEN -- Tenta pegar a exception pelo CDCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSIF vr_dscritic IS NOT NULL THEN -- Tenta pegar a exception pelo DSCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      ELSE  -- Sen�o, Dispara a EXCEPTION padr�o
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela '|| NMDATELA ||': ' || SQLERRM;
      END IF;

      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_busca_motivos_mensagens;

  PROCEDURE pc_busca_icone_notificacao(pr_xmllog   IN VARCHAR2                                                --> XML com informa��es de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER                                            --> C�digo da cr�tica
                                      ,pr_dscritic OUT VARCHAR2                                               --> Descri��o da cr�tica
                                      ,pr_retxml   IN OUT NOCOPY XMLType                                      --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2                                               --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS                                           --> Erros do processo 
    
    -- Cursor para buscar a situa��o da mensagem
    CURSOR cr_tbgen_notif_icone IS
     SELECT ico.cdicone
           ,ico.nmicone
           ,(SELECT prm.valor
              FROM parametromobile prm
             WHERE prm.nome = 'UrlImagensIconesNotificacao') || ico.nmimagem_naolida AS urlimagem_icone
       FROM tbgen_notif_icone ico;

    rw_tbgen_notif_icone cr_tbgen_notif_icone%ROWTYPE;
     
    --Vari�veis
    ex_erro EXCEPTION;
    
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_contador INTEGER := 0;

  BEGIN
    
    -- Extrai os dados vindos do XML
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'icones', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    FOR rw_tbgen_notif_icone IN cr_tbgen_notif_icone LOOP

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'icones', pr_posicao => 0, pr_tag_nova => 'icone', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'icone', pr_posicao => vr_contador, pr_tag_nova => 'cdicone', pr_tag_cont => rw_tbgen_notif_icone.cdicone, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'icone', pr_posicao => vr_contador, pr_tag_nova => 'nmicone', pr_tag_cont => rw_tbgen_notif_icone.nmicone, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'icone', pr_posicao => vr_contador, pr_tag_nova => 'urlimagem_icone', pr_tag_cont => rw_tbgen_notif_icone.urlimagem_icone, pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
            
    END LOOP;    

  EXCEPTION
    WHEN OTHERS THEN
      IF vr_cdcritic <> 0 THEN -- Tenta pegar a exception pelo CDCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSIF vr_dscritic IS NOT NULL THEN -- Tenta pegar a exception pelo DSCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      ELSE  -- Sen�o, Dispara a EXCEPTION padr�o
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela '|| NMDATELA ||': ' || SQLERRM;
      END IF;

      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_busca_icone_notificacao;

  PROCEDURE pc_busca_telas_mobile(pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER       --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2          --> Descri��o da cr�tica
                                 ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo 
    
    -- Cursor para buscar a situa��o da mensagem
    CURSOR cr_menumobile IS
     SELECT menumobileid
           ,nome
      FROM (SELECT m.menumobileid
                  ,ltrim(sys_connect_by_path(m.nome, ' -> '), ' -> ') nome
                  ,sys_connect_by_path(LPAD(m.sequencia, 3, '0'), '-') seq
              FROM (SELECT menumobileid
                          ,nome
                          ,menupaiid
                          ,sequencia
                      FROM menumobile
                     WHERE versaomaximaapp IS NULL) m
             START WITH m.menupaiid IS NULL
            CONNECT BY PRIOR m.menumobileid = m.menupaiid
             ORDER BY seq);

    rw_menumobile cr_menumobile%ROWTYPE;
     
    --Vari�veis
    ex_erro EXCEPTION;
    
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_contador INTEGER := 0;

  BEGIN
    
    -- Extrai os dados vindos do XML
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'telas', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    FOR rw_menumobile IN cr_menumobile LOOP

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'telas', pr_posicao => 0, pr_tag_nova => 'tela', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'tela', pr_posicao => vr_contador, pr_tag_nova => 'menumobileid', pr_tag_cont => rw_menumobile.menumobileid, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'tela', pr_posicao => vr_contador, pr_tag_nova => 'nome', pr_tag_cont => rw_menumobile.nome, pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
            
    END LOOP;    

  EXCEPTION
    WHEN OTHERS THEN
      IF vr_cdcritic <> 0 THEN -- Tenta pegar a exception pelo CDCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSIF vr_dscritic IS NOT NULL THEN -- Tenta pegar a exception pelo DSCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      ELSE  -- Sen�o, Dispara a EXCEPTION padr�o
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela '|| NMDATELA ||': ' || SQLERRM;
      END IF;

      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_busca_telas_mobile;
  
  PROCEDURE pc_importar_arquivo_notif( pr_arquivo          IN VARCHAR2 --> nome do arquivo de importa��o
                                      ,pr_dirarquivo       IN VARCHAR2 --> nome do diret�rio arquivo de importa��o
                                      ,pr_destinatarios    OUT NOTI0001.typ_destinatarios_notif
																		  ,pr_xmllog           IN VARCHAR2 --> XML com informa��es de LOG
																		  ,pr_cdcritic         OUT PLS_INTEGER --> C�digo da cr�tica
																		  ,pr_dscritic         OUT VARCHAR2 --> Descri��o da cr�tica
																		  ,pr_retxml           IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																		  ,pr_nmdcampo         OUT VARCHAR2 --> Nome do Campo
																		  ,pr_des_erro         OUT VARCHAR2) IS --> Saida OK/NOK
		
      CURSOR cr_destinatarios (pr_cdcooper NUMBER
                              ,pr_nrdconta NUMBER
                              ,pr_idseqttl NUMBER) IS
      SELECT usr.cdcooper
            ,usr.nrdconta
            ,usr.idseqttl
            ,NULL dsvariaveis
        FROM vw_usuarios_internet usr
       WHERE usr.cdcooper = pr_cdcooper
         AND usr.nrdconta = pr_nrdconta
         AND (usr.idseqttl = pr_idseqttl OR NVL(pr_idseqttl, 0) = 0);
  
      vr_nm_arquivo VARCHAR(2000);
				
      -- Vari�vel de cr�ticas
      vr_dscritic VARCHAR2(10000);
      vr_typ_said VARCHAR2(50);
				
      -- Variaveis padrao
      vr_cdcooper NUMBER:=3;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_dsdireto VARCHAR2(250);
				
      vr_linha_arq VARCHAR2(2000);
      vr_des_erro  VARCHAR2(2000);
      vr_dsorigem  VARCHAR2(20);
      vr_nrdrowid  ROWID;
				
      --Manipula��o do texto do arquivo
      vr_tabtexto gene0002.typ_split;
				
      --Vari�veis do split            
      vr_cdcooper_arq     NUMBER;
      vr_nrdconta_arq     NUMBER;
      vr_seqtitular_arq   NUMBER;      
      vr_erros            NUMBER := 0;
      vr_registros        NUMBER := 0;
      vr_registros_inexis NUMBER := 0;
				
      vr_handle_arq utl_file.file_type;
				
      --Controle de erro
      vr_exc_erro         EXCEPTION;
      vr_exc_erro_negocio EXCEPTION;
				
      separador VARCHAR2(1) := ';';
       
      vr_table_import_notif   NOTI0001.typ_destinatarios_notif;
                   
  BEGIN
    
      IF pr_arquivo IS NULL OR pr_dirarquivo IS NULL THEN
         vr_dscritic := 'Caminho do arquivo e nome s�o obrigat�rios! ';
         RAISE vr_exc_erro;
      END if;
				
      vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                          ,pr_cdcooper => vr_cdcooper
                                          ,pr_nmsubdir => 'upload');
      -- Realizar a c�pia do arquivo
      GENE0001.pc_OScommand_Shell(gene0001.fn_param_sistema('CRED',0,'SCRIPT_RECEBE_ARQUIVOS')||' '||pr_dirarquivo||pr_arquivo||' N'
                                 ,pr_typ_saida   => vr_typ_said
                                 ,pr_des_saida   => vr_des_erro);
                                                         
      -- Testar erro
      IF vr_typ_said = 'ERR' THEN
          -- O comando shell executou com erro, gerar log e sair do processo
          vr_dscritic := 'Erro realizar o upload do arquivo: ' || vr_des_erro;
          --Gera log
          GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => NVL(pr_dscritic, ' ') || vr_dscritic,
                               pr_dsorigem => vr_dsorigem,
                               pr_dstransa => NMDATELA||' - Importa��o cadastros cooperados',
                               pr_dttransa => TRUNC(SYSDATE),
                               --> ERRO/FALSE
                               pr_flgtrans => 0,
                               pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS')),
                               pr_idseqttl => 1,
                               pr_nmdatela => vr_nmdatela,
                               pr_nrdconta => 0,
                               pr_nrdrowid => vr_nrdrowid);
          RAISE vr_exc_erro;
      END IF;
            
      vr_nm_arquivo := vr_dsdireto||'/'||pr_arquivo;
      --vr_nm_arquivo := pr_arquivo;
            
      IF NOT GENE0001.fn_exis_arquivo(pr_caminho => vr_nm_arquivo) THEN
          -- Retorno de erro
          vr_dscritic := 'Erro no upload do arquivo: '||vr_des_erro;
						
          --Gera log
          GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => NVL(pr_dscritic, ' ') || vr_dscritic,
                               pr_dsorigem => vr_dsorigem,
                               pr_dstransa => NMDATELA||' - Importa��o cadastros cooperados',
                               pr_dttransa => TRUNC(SYSDATE),
                               --> ERRO/FALSE
                               pr_flgtrans => 0,
                               pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS')),
                               pr_idseqttl => 1,
                               pr_nmdatela => vr_nmdatela,
                               pr_nrdconta => 0,
                               pr_nrdrowid => vr_nrdrowid);
          --Levanta excess�o
          RAISE vr_exc_erro;
      END IF;
								
      --Abre o arquivo de sa�da 
      gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nm_arquivo,
                               pr_tipabert => 'R',
                               pr_utlfileh => vr_handle_arq,
                               pr_des_erro => vr_des_erro);
				
      IF vr_des_erro IS NOT NULL THEN
          vr_dscritic := 'Erro abertura arquivo de importa��o! ' || vr_des_erro || ' ' ||
                         SQLERRM;
          RAISE vr_exc_erro;
      END IF;   
    
      --Tudo certo at� aqui, importa o arquivo
      LOOP
          BEGIN
              --L� a linha do arquivo
              gene0001.pc_le_linha_arquivo(vr_handle_arq, vr_linha_arq);
              vr_linha_arq := TRIM(vr_linha_arq);
              vr_linha_arq := REPLACE(REPLACE(vr_linha_arq,chr(10),''),CHR(13),'');
              vr_linha_arq := vr_linha_arq||separador;
                                                   
              IF NVL(vr_linha_arq,' ') <> ' ' THEN								
                  --Explode no texto
                  vr_tabtexto := gene0002.fn_quebra_string(vr_linha_arq, separador);
								
                  --Vari�veis que ser�o usadas na atualiza��o
                  vr_cdcooper_arq   := to_number(vr_tabtexto(1));
                  vr_nrdconta_arq   := to_number(vr_tabtexto(2));
                  vr_seqtitular_arq := to_number(vr_tabtexto(3));
                  
              END IF;
              
              -- Usa o Bulk collect para agilizar a busca dos titulares, mas depois insere os registro individualmente a pr_destinatarios
              OPEN cr_destinatarios(pr_cdcooper => vr_cdcooper_arq
                                   ,pr_nrdconta => vr_nrdconta_arq
                                   ,pr_idseqttl => vr_seqtitular_arq);
             FETCH cr_destinatarios BULK COLLECT
              INTO vr_table_import_notif;
             CLOSE cr_destinatarios;
             
             FOR i IN 1 .. vr_table_import_notif.COUNT
             LOOP
                vr_registros := vr_registros +1;
                pr_destinatarios(vr_registros) := vr_table_import_notif(i);
             END LOOP;
                     
          EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    --Fecha o arquivo se n�o tem mais linhas para ler
                    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_arq); --> Handle do arquivo aberto
                    EXIT;
          END;
      END LOOP;
            
      IF (vr_erros + vr_registros_inexis) > 0 THEN
          -- Retorno n�o OK          
          pr_des_erro := 'NOK';
          -- Erro
          pr_cdcritic := 0;
          pr_dscritic := 'Arquivo foi processado, por�m com erros de preenchimento. Linhas processadas: ' || vr_registros || 
                         '. Erros preenchimento: ' || vr_erros || '. Contas inexistentes: ' || vr_registros_inexis || 
                         '. Para maiores informa��es, consulte o log.';
                    
          GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => pr_dscritic,
                               pr_dsorigem => vr_dsorigem,
                               pr_dstransa => NMDATELA||' - Importa��o cadastros cooperados',
                               pr_dttransa => TRUNC(SYSDATE),
                               --> ERRO/FALSE
                               pr_flgtrans => 0,
                               pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS')),
                               pr_idseqttl => 1,
                               pr_nmdatela => vr_nmdatela,
                               pr_nrdconta => 0,
                               pr_nrdrowid => vr_nrdrowid);
								
          -- Existe para satisfazer exig�ncia da interface. 
          pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic || '-' ||
                                         pr_dscritic || '</Erro></Root>');
      END IF;
				
  EXCEPTION
    WHEN vr_exc_erro_negocio THEN
        ROLLBACK;
        --Log
        GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => nvl(vr_dscritic,' ') || SQLERRM,
                             pr_dsorigem => vr_dsorigem,
                             pr_dstransa => NMDATELA||' - Importa��o cadastros cooperados',
                             pr_dttransa => TRUNC(SYSDATE),
                             --> ERRO/FALSE
                             pr_flgtrans => 0,
                             pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE, 'SSSSS')),
                             pr_idseqttl => 1,
                             pr_nmdatela => vr_nmdatela,
                             pr_nrdconta => 0,
                             pr_nrdrowid => vr_nrdrowid);
        COMMIT;
						
        -- Retorno n�o OK          
        pr_des_erro := 'NOK';
        -- Erro
        pr_dscritic := vr_dscritic;
						
        -- Existe para satisfazer exig�ncia da interface. 
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic || '-' || pr_dscritic ||
                                       '</Erro></Root>');
    WHEN vr_exc_erro THEN
        ROLLBACK;
        -- Retorno n�o OK          
        pr_des_erro := 'NOK';
        -- Erro
        pr_dscritic := vr_dscritic;
						
        -- Existe para satisfazer exig�ncia da interface. 
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic || '-' || pr_dscritic ||
                                       '</Erro></Root>');
    WHEN OTHERS THEN
        ROLLBACK;
        -- Retorno n�o OK
        pr_des_erro := 'NOK';
						
        -- Erro
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na TELA_ENVNOT.PC_IMPORTAR_ARQUIVO_NOTIF --> Veririque se o arquivo est� em formato correto. ' || SQLERRM;
						
        -- Existe para satisfazer exig�ncia da interface. 
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic || '-' || pr_dscritic ||
                                       '</Erro></Root>');
				
  END pc_importar_arquivo_notif;
  
END TELA_ENVNOT;
/
