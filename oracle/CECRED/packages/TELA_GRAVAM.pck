CREATE OR REPLACE PACKAGE CECRED.TELA_GRAVAM AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_GRAVAM                         antigo: /ayllos/fontes/gravam.p
  --  Sistema  : Rotinas genericas referente a tela GRAVAM
  --  Sigla    : CRED
  --  Autor    : Andrei - RKAM
  --  Data     : Maio/2016.                   Ultima atualizacao: 28/07/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Responsavel pelo gerenciamento de GRAVAMES.

  -- Alteracoes: 28/07/2016 - Ajuste devido a criação de uma rotina para solicitação de 
  --                          processamento do arquivos de retorno
  --                         (Adriano - SD  495514)                          
  --
  ---------------------------------------------------------------------------------------------------------------
                               
  /* Rotina para buscar as cooperativas */
  PROCEDURE pc_buscar_cooperativas(pr_flcecred   IN INTEGER            --> 0- Nao traz CECRED / 1 - Traz cecred 
                                  ,pr_flgtodas   IN INTEGER            --> 0- Não traz a opção TODAS / 1 - Traz a opção TODAS  
                                  ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                  ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo
   /* Procedimento para retornar os parâmetros gravados em Sistema */
   PROCEDURE pc_busca_parametros(pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK

  /* Procedimento para retornar os parâmetros gravados em Sistema */
  PROCEDURE pc_gravacao_parametros(pr_nrdiaenv in varchar2 -- Numero Dias Envio apos Liquidação / Cancelamento
                                  ,pr_hrenvi01 in varchar2 -- Horário 1º Envio do dia
                                  ,pr_hrenvi02 in varchar2 -- Horário 2º Envio do dia
                                  ,pr_hrenvi03 in varchar2 -- Horário 3º Envio do dia
                                  ,pr_aprvcord in varchar2 -- Solicitação de Aprovação de Coordenador
                                  ,pr_perccber in varchar2 -- Percentual de valor do Bem X Valor Proposta
                                  ,pr_tipcomun in varchar2 -- Tipo de Comunicação com B3 para Gravames
                                  ,pr_nrdnaoef in varchar2 -- Numero dias após Gravame sem efetivação
                                  ,pr_emlnaoef in varchar2 -- List de emails para aviso Gravame sem efetivacao
                                  
                                  ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                  ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2);        -- Saida OK/NOK     
  
     
  /* Rotina para criar os arquivos de GRAVAMES */                             
  PROCEDURE pc_gera_arquivo(pr_cdcoptel   IN INTEGER            --> 0- Não traz a opção TODAS / 1 - Traz a opção TODAS      
                           ,pr_tparquiv   IN VARCHAR2           --> Tipo do arquivo                      
                           ,pr_cddopcao   IN VARCHAR2           --> Opção da tela
                           ,pr_cddepart   IN VARCHAR2           --> Departamento do operador
                           ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                           ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                           ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                           ,pr_des_erro  OUT VARCHAR2) ;        --> Erros do processo            
  
  PROCEDURE pc_busca_contratos_gravames(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                       ,pr_nrregist IN INTEGER               -- Número de registros
                                       ,pr_nriniseq IN INTEGER               -- Número sequencial 
                                       ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK                                                                         
  
  PROCEDURE pc_busca_pa_associado(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                 ,pr_cddopcao IN VARCHAR2              --Opção
                                 ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2);         --Saida OK/NOK
                                 
  PROCEDURE pc_busca_gravames(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                             ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE --Numero do contrato
                             ,pr_nrregist IN INTEGER               -- Número de registros
                             ,pr_nriniseq IN INTEGER               -- Número sequencial 
                             ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                             ,pr_des_erro OUT VARCHAR2);          --Saida OK/NOK
                             
  /* Procedure para Solicitar o processamento de arquivos de retorno */
  PROCEDURE pc_solic_proces_retorno(pr_cdcoptel   IN INTEGER            --> 0- Não traz a opção TODAS / 1 - Traz a opção TODAS      
                                   ,pr_tparquiv   IN VARCHAR2           --> Tipo do arquivo                      
                                   ,pr_cddopcao   IN VARCHAR2           --> Opção da tela
                                   ,pr_cddepart   IN VARCHAR2           --> Departamento do operador
                                   ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                   ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo                             
                                   
  /* Procedure para Solicitar o processamento de arquivos de retorno */
  PROCEDURE pc_permissao_situacao(pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                 ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo
                                 
  /* Emissão em tela ou relatório do histórico Gravames */                               
  PROCEDURE pc_gravames_imp_relatorio(pr_cddopcao in VARCHAR2               -- Opção
                                     ,pr_tparquiv in VARCHAR2               -- Tipo do arquivo 
                                     ,pr_cdcoptel in crapcop.cdcooper%TYPE  -- Cooperativa selecionada      
                                     ,pr_nrseqlot in crapgrv.nrseqlot%TYPE  -- Numero do lote
                                     ,pr_dtrefere in VARCHAR2               -- Data de referencia
                                     ,pr_dtrefate in VARCHAR2               -- Data de referência final
                                     ,pr_cdagenci in crapass.cdagenci%TYPE  -- Agência
                                     ,pr_nrdconta in crapgrv.nrdconta%TYPE  -- Conta
                                     ,pr_nrctrpro in crapgrv.nrctrpro%TYPE  -- Contrato
                                     ,pr_flcritic in VARCHAR2               -- Somente criticas
                                     ,pr_tipsaida in VARCHAR2               -- Tipo da saída
                                     ,pr_dschassi in VARCHAR2               -- Chassi
                                     ,pr_nrregist IN INTEGER                -- Quantidade de registros
                                     ,pr_nriniseq IN INTEGER                -- Qunatidade inicial
                                     ,pr_xmllog   in VARCHAR2               -- XML com informações de LOG
                                     ,pr_cdcritic out PLS_INTEGER           -- Código da crítica
                                     ,pr_dscritic out VARCHAR2              -- Descrição da crítica
                                     ,pr_retxml   in out nocopy xmltype     -- Arquivo de retorno do XML
                                     ,pr_nmdcampo out VARCHAR2              -- Nome do Campo
                                     ,pr_des_erro out varchar2);            -- Saida OK/NOK
  
  /* Buscar dados para a tela */                                                                                  
  PROCEDURE pc_gravames_consultar_bens(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                      ,pr_cddopcao IN VARCHAR2              --Opção
                                      ,pr_nrctrpro IN crawepr.nrctremp%TYPE --Número do contrato 
                                      ,pr_nrgravam IN crapbpr.nrgravam%TYPE --Número do gravame
                                      ,pr_nrregist IN INTEGER               -- Número de registros
                                      ,pr_nriniseq IN INTEGER               -- Número sequencial 
                                      ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2);          --Saida OK/NOK
                                                                 
                                 
END TELA_GRAVAM;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_GRAVAM AS

/*---------------------------------------------------------------------------------------------------------------
   Programa: TELA_GRAVAM                          antigo: /ayllos/fontes/gravam.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Andrei - RKAM
   Data    : Maio/2016                       Ultima atualizacao: 12/04/2017

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Responsavel pelo gerenciamento de GRAVAMES.

   Alteracoes: 14/07/2016 - Ajuste para agrupar os gravames encontrados (Andrei - RKAM). 
   
               28/07/2016 - Ajuste devido a criação de uma rotina para solicitação de 
                            processamento do arquivos de retorno
                            (Adriano - SD  495514)                          
                                                               
               25/11/2016 - P341 - Automatização BACENJUD - Alterado o parametro PR_DSDEPART 
                            para PR_CDDEPART e as consultas do fonte para utilizar o código 
                            do departamento nas validações (Renato Darosci - Supero)
                                                          
               12/04/2017 - Inclusão da constante ct_nmdatela e correção dos logs, posicionando
                            o nome da tela antes da seta que indica o início da mensagem (Carlos)
                                                          
  ---------------------------------------------------------------------------------------------------------------*/
  
  ct_nmdatela CONSTANT VARCHAR2(6) := 'GRAVAM';
  
  /* Rotina para buscar as cooperativas */
  PROCEDURE pc_buscar_cooperativas(pr_flcecred   IN INTEGER            --> 0- Nao traz CECRED / 1 - Traz cecred 
                                  ,pr_flgtodas   IN INTEGER            --> 0- Não traz a opção TODAS / 1 - Traz a opção TODAS  
                                  ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                  ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo
    /* .............................................................................
    Programa: pc_buscar_cooperativas
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Andrei - RKAM
    Data    : Maio/2016                       Ultima atualizacao:  

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar as cooperativas ativas 

    Alteracoes:                            
    ............................................................................. */
      CURSOR cr_crapcop IS
      SELECT crapcop.cdcooper
            ,crapcop.nmrescop
        FROM crapcop
       WHERE (crapcop.cdcooper <> 3 AND pr_flcecred = 0)
          OR pr_flcecred = 1 
      ORDER BY crapcop.cdcooper;
      
      -- Variaveis de locais
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      --Variaveis de Criticas
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
             
      --Variaveis de Excecoes
      vr_exc_erro  EXCEPTION;
      
    BEGIN
      
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        
        RAISE vr_exc_erro;
          
      END IF; 
      
      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><cooperativas></cooperativas></Root>');
      
      IF pr_flgtodas = 1 AND vr_cdcooper = 3 THEN
        
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                           ,'/Root/cooperativas'
                                           ,XMLTYPE('<cooperativa>'
                                                  ||'  <cdcooper>0</cdcooper>'
                                                  ||'  <nmrescop>TODAS</nmrescop>'
                                                  ||'</cooperativa>'));
                                                  
      END IF;                                                                                                
                                                  
      FOR rw_crapcop IN cr_crapcop LOOP
        
        IF vr_cdcooper <> 3                   AND 
           rw_crapcop.cdcooper <> vr_cdcooper THEN 
        
          continue;
          
        END IF;         
          
        -- Criar nodo filho
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                            ,'/Root/cooperativas'
                                            ,XMLTYPE('<cooperativa>'
                                                   ||'  <cdcooper>'||rw_crapcop.cdcooper||'</cdcooper>'
                                                   ||'  <nmrescop>'||UPPER(rw_crapcop.nmrescop)||'</nmrescop>'
                                                   ||'</cooperativa>'));
      END LOOP;
    
      -- Retorno OK          
      pr_des_erro:= 'OK';
          
    EXCEPTION
      WHEN vr_exc_erro THEN 
                     
        -- Erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        pr_nmdcampo := 'cdcooper';
        pr_des_erro := 'NOK'; 
                  
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
      WHEN OTHERS THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral (TELA_GRAVAM.pc_buscar_cooperativas): ' || SQLERRM;
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        
        
  END pc_buscar_cooperativas;
  
   /* Procedimento para retornar os parâmetros gravados em Sistema para tela GRAVAM */
   PROCEDURE pc_busca_parametros(pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_busca_parametros
    Autor    : Marcos - Envolti
    Data     : Agosto/2018                            Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Busca parâmetros do sistema para retornar a tela PHP

    Alterações :

    -------------------------------------------------------------------------------------------------------------*/

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION;

  BEGIN

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => ct_nmdatela
                              ,pr_action => 'pc_busca_parametros');

    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Se não veio a Cooperativa temos de gerar erro
    IF vr_cdcooper IS NULL THEN
     -- Montar mensagem de critica
     vr_cdcritic:= 651;
      RAISE vr_exc_erro;
    END IF;

    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Raiz/>');

    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Raiz'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'Dados'
      ,pr_tag_cont => NULL
      ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'nrdiaenv'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',vr_cdcooper,'GRAVAM_DIAS_PARA_ENV')
      ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'hrenvi01'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',vr_cdcooper,'GRAVAM_HRENVIO_01')
      ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'hrenvi02'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',vr_cdcooper,'GRAVAM_HRENVIO_02')
      ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'hrenvi03'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',vr_cdcooper,'GRAVAM_HRENVIO_03')
      ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'aprvcord'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',vr_cdcooper,'ADITIV_5_APROVA_COORD')
      ,pr_des_erro => vr_dscritic);      

    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'perccber'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',vr_cdcooper,'ADITIV_5_PERC_MIN_COBERT')
      ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'tipcomun'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',vr_cdcooper,'GRAVAM_TIPO_COMUNICACAO')
      ,pr_des_erro => vr_dscritic);      
      

    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'nrdnaoef'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',vr_cdcooper,'GRAVAM_DIA_AVISO_NAO_EFT')
      ,pr_des_erro => vr_dscritic);   

    GENE0007.pc_insere_tag
      (pr_xml      => pr_retxml
      ,pr_tag_pai  => 'Dados'
      ,pr_posicao  => 0
      ,pr_tag_nova => 'emlnaoef'
      ,pr_tag_cont => gene0001.fn_param_sistema('CRED',vr_cdcooper,'GRAVAM_MAIL_AVIS_NAO_EFT')
      ,pr_des_erro => vr_dscritic);                 

    -- Retorno OK
    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN

      -- Propagar Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := NULL;
      pr_des_erro := 'NOK';

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN

      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_parametros --> '|| SQLERRM;
      pr_des_erro:= 'NOK';

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
  END pc_busca_parametros;

  /* Procedimento para retornar os parâmetros gravados em Sistema */
  PROCEDURE pc_gravacao_parametros(pr_nrdiaenv in varchar2 -- Numero Dias Envio apos Liquidação / Cancelamento
                                  ,pr_hrenvi01 in varchar2 -- Horário 1º Envio do dia
                                  ,pr_hrenvi02 in varchar2 -- Horário 2º Envio do dia
                                  ,pr_hrenvi03 in varchar2 -- Horário 3º Envio do dia
                                  ,pr_aprvcord in varchar2 -- Solicitação de Aprovação de Coordenador
                                  ,pr_perccber in varchar2 -- Percentual de valor do Bem X Valor Proposta
                                  ,pr_tipcomun in varchar2 -- Tipo de Comunicação com B3 para Gravames
                                  ,pr_nrdnaoef in varchar2 -- Numero dias após Gravame sem efetivação
                                  ,pr_emlnaoef in varchar2 -- List de emails para aviso Gravame sem efetivacao
                                  
                                  ,pr_xmllog   IN VARCHAR2           -- XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER       -- Código da crítica
                                  ,pr_dscritic OUT VARCHAR2          -- Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType -- Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2          -- Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2)IS       -- Saida OK/NOK

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_gravacao_parametros
    Autor    : Marcos-Envolti
    Data     : Junho/2018                           Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Gravar parâmetros do sistema conforme preenchimento em tela PHP

    Alterações :

    -------------------------------------------------------------------------------------------------------------*/
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION;
    
    vr_txemails gene0002.typ_split; --> Separação da linha em vetor
    vr_vlemails VARCHAR2(4000); --> Emails válidos
    
  BEGIN
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => ct_nmdatela
                              ,pr_action => 'pc_gravacao_parametros');

    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
    -- Verifica se houve erro recuperando informacoes de log
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Valida tipo de dado e range dos dias para envio
    DECLARE
      vr_numteste NUMBER;
    BEGIN
      vr_numteste := pr_nrdiaenv;
      IF trim(vr_numteste) IS NULL OR vr_numteste < 0 OR vr_numteste > 30 THEN
        RAISE vr_exc_erro;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := gene0007.fn_convert_db_web('Número de dias após liquidação do contrato para envio das baixas é obrigatório! Favor informar um número de 0 a 30 dias!');
        RAISE vr_exc_erro;
    END;  
    
    -- Validar horários para envio
    IF nvl(trim(pr_hrenvi01),'00:00') IN('00:00','--:--') AND nvl(trim(pr_hrenvi02),'00:00') IN('00:00','--:--') AND nvl(trim(pr_hrenvi03),'00:00') IN('00:00','--:--') THEN
      vr_dscritic := gene0007.fn_convert_db_web('Informe pelo menos um Horário(s) dos envios das baixas/cancelamentos:');
      RAISE vr_exc_erro;
    ELSE
      DECLARE
        vr_datteste DATE;
        vr_valteste VARCHAR2(100);
      BEGIN
        -- Validar se é horário válido
        FOR idx IN 1..3 LOOP
          IF idx = 1 THEN
            vr_valteste := pr_hrenvi01;
          ELSIF idx = 2 THEN
            vr_valteste := pr_hrenvi02;
          ELSE
            vr_valteste := pr_hrenvi03;
          END IF;
          -- Somente se existir valor
          IF nvl(trim(vr_valteste),'00:00') NOT IN('00:00','--:--') THEN
            -- Converter para data
            vr_datteste := to_date(to_char(SYSDATE,'ddmmrrrr')||vr_valteste,'ddmmrrrrhh24:mi');
            -- Se chegou aqui é uma data válida
            IF vr_datteste < to_date(to_char(SYSDATE,'ddmmrrrr')||'05:00','ddmmrrrrhh24:mi')
            OR vr_datteste > to_date(to_char(SYSDATE,'ddmmrrrr')||'23:00','ddmmrrrrhh24:mi') THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN 
          vr_dscritic := gene0007.fn_convert_db_web('Horário ['||vr_valteste||'] para envio inválido! Favor informar um horário entre as 05:00 e as 23:00!');
          RAISE vr_exc_erro;
      END;
    END IF;
    
    -- Valida tipo de dado e range dos dias para aviso gravam sem efetivação
    DECLARE
      vr_numteste NUMBER;
    BEGIN
      vr_numteste := pr_nrdnaoef;
      IF trim(vr_numteste) IS NULL OR vr_numteste < 0 OR vr_numteste > 30 THEN
        RAISE vr_exc_erro;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := gene0007.fn_convert_db_web('Número de dias para aviso via e-mail de propostas com gravames e não efetivadas é obrigatório! Favor informar um número de 0 a 30 dias!');
        RAISE vr_exc_erro;
    END;  
    
    -- Validar solicitação de aprovação
    IF trim(pr_aprvcord) NOT IN('N','S','A') THEN
      vr_dscritic := gene0007.fn_convert_db_web('Opção inválida de Solicita senha de coordenação para aditivos!');
      RAISE vr_exc_erro;
    END IF;
    -- Para aprovação "Apenas", temos de validar o percentual
    IF trim(pr_aprvcord) = 'A' THEN
      DECLARE
        vr_numteste NUMBER;
      BEGIN
        vr_numteste := pr_perccber;
        IF trim(vr_numteste) IS NULL OR vr_numteste < 0.01 OR vr_numteste > 200 THEN
          RAISE vr_exc_erro;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := gene0007.fn_convert_db_web('Valor mínimo de porcentagem sobre o saldo devedor inválido! Favor informar um valor percentual entre 0,01 e 200.00!');
          RAISE vr_exc_erro;
      END;       
    END IF;    
    
    -- Validar Tipo de Comunicação
    IF trim(pr_tipcomun) NOT IN('N','S') THEN
      vr_dscritic := gene0007.fn_convert_db_web('Tipo de Comunicação Inválida!');
      RAISE vr_exc_erro;
    END IF;
    
    -- Se temos dias para aviso, é obrigatório informar email
    IF pr_nrdnaoef > 0 THEN     
      -- Separar os emails enviados e tentar validá-los
      vr_txemails := gene0002.fn_quebra_string(replace(pr_emlnaoef,',',';'),';');
      IF vr_txemails.COUNT() > 0 THEN
        FOR vr_idx IN vr_txemails.FIRST..vr_txemails.LAST LOOP
          -- Se o email atual possuir alguma informação
          IF trim(vr_txemails(vr_idx)) IS NOT NULL THEN 
            -- Validar o mesmo
            IF gene0003.fn_valida_email(vr_txemails(vr_idx)) = 1 THEN 
              vr_vlemails := vr_vlemails || lower(vr_txemails(vr_idx))||';';
            ELSE
              -- Gerar erro 
              vr_dscritic := gene0007.fn_convert_db_web('Endereço de email ['||vr_txemails(vr_idx)||'] não é um endereço válido!');
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END LOOP;
      END IF;        
      -- Se não validou pelo menos um email
      IF vr_vlemails IS NULL THEN 
        vr_dscritic := gene0007.fn_convert_db_web('E-mail(s) para enviar relatório de propostas com gravames e não efetivadas deve ser informado! Informe endereços válidos e separados por ponto e vírgula(;), caso seja necessário!');
        RAISE vr_exc_erro;
      END IF;        
    END IF;

    -- Passadas as validações, faremos a gravação
    DECLARE
      vr_nomcampo VARCHAR2(100);
      vr_vlranter VARCHAR2(4000);
      vr_vlrcampo VARCHAR2(4000);
      vr_cdacesso VARCHAR2(24);
      
      -- Pltable para gravar os horários ordenados
      TYPE typ_tab_horarios IS TABLE OF VARCHAR2(5) INDEX BY VARCHAR2(5);
      vr_tab_horarios typ_tab_horarios;
      vr_idx_horarios VARCHAR2(5);
      -- Variaveis para guardar os horários encontratos
      vr_hrenvi01 VARCHAR2(5); 
      vr_hrenvi02 VARCHAR2(5);
      vr_hrenvi03 VARCHAR2(5);
    BEGIN
      -- Posicionar os horários em pltable
      IF nvl(trim(pr_hrenvi01),'00:00') NOT IN('00:00','--:--') THEN
        vr_tab_horarios(pr_hrenvi01) := pr_hrenvi01;
      END IF;
      IF nvl(trim(pr_hrenvi02),'00:00') NOT IN('00:00','--:--') THEN
        vr_tab_horarios(pr_hrenvi02) := pr_hrenvi02;
      END IF;      
      IF nvl(trim(pr_hrenvi03),'00:00') NOT IN('00:00','--:--') THEN
        vr_tab_horarios(pr_hrenvi03) := pr_hrenvi03;
      END IF; 
      -- Varrer a pltable e gravar nas variaveis corretas
      vr_idx_horarios := vr_tab_horarios.first;
      LOOP
        EXIT WHEN vr_idx_horarios IS NULL;
        -- Posicionar
        IF vr_hrenvi01 IS NULL THEN
          vr_hrenvi01 := vr_tab_horarios(vr_idx_horarios);
        ELSIF vr_hrenvi02 IS NULL THEN
          vr_hrenvi02 := vr_tab_horarios(vr_idx_horarios);
        ELSE
          vr_hrenvi03 := vr_tab_horarios(vr_idx_horarios);
        END IF;
        vr_idx_horarios := vr_tab_horarios.next(vr_idx_horarios);
      END LOOP;
      -- Loop para salvar os 9 campos
      FOR vr_idx IN 1..9 LOOP        
        -- Conforme cada posição busca o parametro
        IF vr_idx = 1 THEN
          vr_nomcampo := gene0007.fn_convert_db_web('Número de dias após liquidação do contrato para envio das baixas');
          vr_vlrcampo := pr_nrdiaenv;
          vr_cdacesso := 'GRAVAM_DIAS_PARA_ENV';
        ELSIF vr_idx in(2,3,4) THEN          
          -- Reposicionaremos os horários para que fiquem em ordem
          IF vr_idx = 2 THEN
            -- Usamos o menor
            vr_vlrcampo := vr_hrenvi01;  
          ELSIF vr_idx = 3 THEN
            -- Usaremos o do meio  
            vr_vlrcampo := vr_hrenvi02;  
          ELSE
            -- Usamos o maior
            vr_vlrcampo := vr_hrenvi03;  
          END IF;
          -- Nome é fixo e cdacesso conforme o loop
          vr_nomcampo := gene0007.fn_convert_db_web('Horário(s) dos envios das baixas/cancelamentos');
          vr_cdacesso := 'GRAVAM_HRENVIO_'||to_char(vr_idx-1,'fm00');
        ELSIF vr_idx = 5 THEN
          vr_nomcampo := gene0007.fn_convert_db_web('Solicitar aprovação nos Aditivos de Substituição de Bem');
          vr_vlrcampo := pr_aprvcord;
          vr_cdacesso := 'ADITIV_5_APROVA_COORD';
        ELSIF vr_idx = 6 THEN
          vr_nomcampo := gene0007.fn_convert_db_web('Valor mínimo de porcentagem sobre o saldo devedor');
          vr_vlrcampo := pr_perccber;
          vr_cdacesso := 'ADITIV_5_PERC_MIN_COBERT';
        ELSIF vr_idx = 7 THEN
          vr_nomcampo := gene0007.fn_convert_db_web('Forma de Comunicação');
          vr_vlrcampo := pr_tipcomun;
          vr_cdacesso := 'GRAVAM_TIPO_COMUNICACAO';  
        ELSIF vr_idx = 8 THEN
          vr_nomcampo := gene0007.fn_convert_db_web('Número de dias para aviso via e-mail de propostas com gravames e não efetivadas:');
          vr_vlrcampo := pr_nrdnaoef;
          vr_cdacesso := 'GRAVAM_DIA_AVISO_NAO_EFT'; 
        ELSE
          vr_nomcampo := gene0007.fn_convert_db_web('E-mail(s) para enviar relatório de propostas com gravames e não efetivadas');
          vr_vlrcampo := vr_vlemails;
          vr_cdacesso := 'GRAVAM_MAIL_AVIS_NAO_EFT'; 
        END IF;        
        -- Testar a alteração para gravação e log
        vr_vlranter := gene0001.fn_param_sistema('CRED',vr_cdcooper,vr_cdacesso);
        IF nvl(vr_vlrcampo,' ') <> nvl(vr_vlranter,' ') THEN 
          UPDATE crapprm
             SET dsvlrprm = vr_vlrcampo
           WHERE nmsistem = 'CRED'
             AND cdcooper = vr_cdcooper
             AND cdacesso = vr_cdacesso; 
          IF SQL%ROWCOUNT = 0 THEN   
            INSERT INTO crapprm(nmsistem 
                               ,cdcooper 
                               ,cdacesso 
                               ,dsvlrprm)
                         VALUES('CRED'
                               ,vr_cdcooper
                               ,vr_cdacesso
                               ,vr_vlrcampo);
          END IF;
          -- Gerar LOG
          btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => ct_nmdatela
                                    ,pr_flfinmsg     => 'N'
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                                                     || ' -->  Operador '|| vr_cdoperad || ' - ' 
                                                     || 'Alterou o parâmetro "'||vr_nomcampo||'" de ' || vr_vlranter
                                                     || ' para ' || vr_vlrcampo || '.');
        END IF;   
      END LOOP;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        RAISE vr_exc_erro;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro na gravação dos Parâmetros GRAVAM Campo "'||vr_nomcampo||'" para '||vr_vlrcampo||'. Erro encontrado: '||sqlerrm;
        RAISE vr_exc_erro;
    END;
    
    -- Gravar no banco
    COMMIT;
    -- Retorno OK
    pr_des_erro := 'OK';
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Propagar Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := NULL;
      pr_des_erro := 'NOK';
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      -- Propagar erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_gravacao_parametros --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
  END pc_gravacao_parametros;
  
  
  PROCEDURE pc_gera_arquivo(pr_cdcoptel   IN INTEGER            --> 0- Não traz a opção TODAS / 1 - Traz a opção TODAS      
                           ,pr_tparquiv   IN VARCHAR2           --> Tipo do arquivo                      
                           ,pr_cddopcao   IN VARCHAR2           --> Opção da tela
                           ,pr_cddepart   IN VARCHAR2           --> Departamento do operador
                           ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                           ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                           ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                           ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo
    /* .............................................................................
    Programa: pc_gera_arquivo
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Andrei - RKAM
    Data    : Maio/2016                       Ultima atualizacao:  

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para geração de arquivos de GRAVAMES  

    Alteracoes:                            
    ............................................................................. */
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
  BEGIN
      
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => ct_nmdatela
                              ,pr_action => null); 
                                   
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      
      RAISE vr_exc_erro;
        
    END IF; 
      
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    

    IF  vr_cdcooper <> 3 OR pr_cddepart NOT IN (14,20) THEN 

      -- Montar mensagem de critica
      vr_dscritic := 'Operador sem autorizacao para gerar arquivos!';
      RAISE vr_exc_erro;
      
    END IF;
            
    /* Geração dos arquivos do GRAVAMES */
    GRVM0001.pc_gravames_geracao_arquivo(pr_cdcooper  => vr_cdcooper -- Cooperativa conectada
                                        ,pr_cdcoptel  => pr_cdcoptel -- Opção selecionada na tela
                                        ,pr_tparquiv  => pr_tparquiv -- Tipo do arquivo selecionado na tela
                                        ,pr_dtmvtolt  => rw_crapdat.dtmvtolt   -- Data atual
                                        ,pr_cdcritic  => vr_cdcritic   -- Cod Critica de erro
                                        ,pr_dscritic  => vr_dscritic); -- Des Critica de erro
                                        
    --Se ocorreu um erro
    IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			      
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
                                                  
      RAISE vr_exc_erro;
            
    END IF;       
    
      
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := 'cdcooper';
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                     
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_dstiplog      => 'E'
                                ,pr_cdcriticidade => 2
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') || ' - ' ||
                                                    ct_nmdatela || ' --> ' || vr_cdoperad || ' - ' ||
                                                    'ERRO: ' || vr_dscritic || ' [gravames_geracao_arquivo].');
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_gera_arquivo --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');   
       
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_dstiplog      => 'E'
                                ,pr_cdcriticidade => 2
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') || ' - ' ||
                                                    ct_nmdatela || ' --> ' || vr_cdoperad || ' - ' ||
                                                    'ERRO: ' || vr_dscritic || ' [gravames_geracao_arquivo].');  
        
  END pc_gera_arquivo;
  
  PROCEDURE pc_busca_contratos_gravames(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                       ,pr_nrregist IN INTEGER               -- Número de registros
                                       ,pr_nriniseq IN INTEGER               -- Número sequencial 
                                       ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_contratos_gravames                            antiga: b1wgen0171.gravames_busca_valida_contrato
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                         Ultima atualizacao: 19/10/2018
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca contratos
    
    Alterações : 14/07/2016 - Ajuste para agrupar os contratos encontrados (Andrei - RKAM).
    
                 19/10/2018 - P442 - Troca de checagem fixa por funcão para garantir se bem é alienável (Marcos-Envolti)
    -------------------------------------------------------------------------------------------------------------*/                               
  
    CURSOR cr_propostas(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE)IS
    SELECT crawepr.nrdconta
          ,crapbpr.nrctrpro
      FROM crawepr
          ,craplcr
          ,crapbpr
     WHERE crawepr.cdcooper = pr_cdcooper
       AND crawepr.nrdconta = pr_nrdconta
       AND craplcr.cdcooper = crawepr.cdcooper
       AND craplcr.cdlcremp = crawepr.cdlcremp
       AND craplcr.tpctrato = 2
       AND crapbpr.cdcooper = crawepr.cdcooper
       AND crapbpr.nrdconta = crawepr.nrdconta
       AND crapbpr.tpctrpro = 90
       AND crapbpr.nrctrpro = crawepr.nrctremp
       AND crapbpr.flgalien = 1
       AND grvm0001.fn_valida_categoria_alienavel(crapbpr.dscatbem) = 'S'
       GROUP BY crawepr.nrdconta
               ,crapbpr.nrctrpro;          
                       
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := '';      
    vr_nrregist  INTEGER; 
    vr_qtregist  INTEGER := 0; 
    vr_contador  INTEGER := 0;  
        
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
  BEGIN
    
    vr_nrregist := pr_nrregist;
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => ct_nmdatela
                              ,pr_action => null); 
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
       
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
        
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><Propostas>');     
                           
    --Busca as propostas
    FOR rw_propostas IN cr_propostas(pr_cdcooper => vr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta) LOOP
    
      --Incrementar contador
      vr_qtregist:= nvl(vr_qtregist,0) + 1;
              
      -- controles da paginacao 
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN

        --Proximo
        CONTINUE;  
                  
      END IF; 
              
      IF vr_nrregist >= 1 THEN   
        -- Carrega os dados           
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<proposta>'||  
                                                       '  <nrdconta>' || rw_propostas.nrdconta ||'</nrdconta>'||                                                                                                      
                                                       '  <nrctrpro>' || TRIM(gene0002.fn_mask(rw_propostas.nrctrpro,'zzz.zzz.zzz')) ||'</nrctrpro>'||                                                      
                                                     '</proposta>');
        
        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1;
           
      END IF;         
          
      vr_contador := vr_contador + 1; 
    
    END LOOP;

    IF vr_nrregist = 0 THEN
      
      vr_cdcritic:= 0;
      vr_dscritic:= 'Associado sem Emprestimos tipo Alienacao Fiduciaria!';
      
      RAISE vr_exc_erro;
          
    END IF;
        
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</Propostas></Root>'
                           ,pr_fecha_xml      => TRUE);
     
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);
       
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);  
               
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml          --> XML que irá receber o novo atributo
                             ,pr_tag   => 'Root'             --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
                             
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite); 
    
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_contratos_gravames --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_busca_contratos_gravames;  

  PROCEDURE pc_busca_gravames(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                             ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE --Numero do contrato
                             ,pr_nrregist IN INTEGER               -- Número de registros
                             ,pr_nriniseq IN INTEGER               -- Número sequencial 
                             ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                             ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_gravames                             
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                         Ultima atualizacao: 14/07/2016
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca gravames de um contrato informado
    
    Alterações : 14/07/2016 - Ajuste para agrupar os gravames encontrados (Andrei - RKAM).
    -------------------------------------------------------------------------------------------------------------*/                               
  
    CURSOR cr_crapbpr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE)IS
    SELECT crapbpr.nrdconta          
          ,crapbpr.nrgravam                  
      FROM crapbpr
     WHERE crapbpr.cdcooper = pr_cdcooper
       AND crapbpr.nrdconta = pr_nrdconta
       AND crapbpr.nrctrpro = pr_nrctrpro
       AND crapbpr.flgalien = 1
       GROUP BY crapbpr.nrdconta
               ,crapbpr.nrgravam;          
                       
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := '';      
    vr_nrregist  INTEGER; 
    vr_qtregist  INTEGER := 0; 
    vr_contador  INTEGER := 0;  
        
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
  BEGIN
    
    vr_nrregist := pr_nrregist;
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => ct_nmdatela
                              ,pr_action => null); 
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
       
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
        
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><Propostas>');     
                           
    --Busca os gravames
    FOR rw_crapbpr IN cr_crapbpr(pr_cdcooper => vr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrctrpro => pr_nrctrpro) LOOP
    
      --Incrementar contador
      vr_qtregist:= nvl(vr_qtregist,0) + 1;
              
      -- controles da paginacao 
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN

        --Proximo
        CONTINUE;  
                  
      END IF; 
              
      IF vr_nrregist >= 1 THEN   
        -- Carrega os dados           
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<proposta>'||  
                                                       '  <nrdconta>' || rw_crapbpr.nrdconta ||'</nrdconta>'||                                                                                                      
                                                       '  <nrgravam>' || TRIM(gene0002.fn_mask(rw_crapbpr.nrgravam,'zzz.zzz.zzz')) ||'</nrgravam>'||
                                                     '</proposta>');
        
        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1;
           
      END IF;         
          
      vr_contador := vr_contador + 1; 
    
    END LOOP;

    IF vr_nrregist = 0 THEN
      
      vr_cdcritic:= 0;
      vr_dscritic:= 'Associado sem Emprestimos tipo Alienacao Fiduciaria!';
      
      RAISE vr_exc_erro;
          
    END IF;
        
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</Propostas></Root>'
                           ,pr_fecha_xml      => TRUE);
     
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);
       
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);  
               
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml          --> XML que irá receber o novo atributo
                             ,pr_tag   => 'Root'             --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
                             
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite); 
    
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_gravames --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_busca_gravames;  

  PROCEDURE pc_busca_pa_associado(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                 ,pr_cddopcao IN VARCHAR2              --Opção
                                 ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_pa_associado                            antiga: b1wgen0171.gravames_busca_pa_associado
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                         Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca o pa do associado
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                               
    --Cursor para encontrar a cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdcooper
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    -- Busca dos dados do associado
    CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
     FROM crapass ass
    WHERE ass.cdcooper = pr_cdcooper
      AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := '';      
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
  BEGIN
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => ct_nmdatela
                              ,pr_action => null); 
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    --Busca a cooperativa
    OPEN cr_crapcop(pr_cdcooper => vr_cdcooper);
    
    FETCH cr_crapcop INTO rw_crapcop;    
    
    IF cr_crapcop%NOTFOUND THEN
  
      --Fecha o cursor
      CLOSE cr_crapcop;
      
      vr_cdcritic := 794;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

      RAISE vr_exc_erro;
        
    ELSE
      
      --Fecha o cursor
      CLOSE cr_crapcop;
    
    END IF;
    
    IF pr_nrdconta = 0 THEN
      
      vr_cdcritic := 0;
      vr_dscritic := 'Informar o numero da conta.';

      RAISE vr_exc_erro;
    END IF;
    
    --Busca o associado
    OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
    
    FETCH cr_crapass INTO rw_crapass;    
    
    IF cr_crapass%NOTFOUND THEN
  
      --Fecha o cursor
      CLOSE cr_crapass;
      
      vr_cdcritic := 9;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

      RAISE vr_exc_erro;
        
    ELSE
      
      --Fecha o cursor
      CLOSE cr_crapass;
    
    END IF;
    
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
                        
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><agencia>' || 
                                                 '   <cdagenci>' || rw_crapass.cdagenci || '</cdagenci>' ||
                                                 '</agencia></Root>'
                           ,pr_fecha_xml      => TRUE);
                  
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);   
                                                   
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_pa_associado --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_busca_pa_associado;  
  
  /* Procedure para Solicitar o processamento de arquivos de retorno */
  PROCEDURE pc_solic_proces_retorno(pr_cdcoptel   IN INTEGER            --> 0- Não traz a opção TODAS / 1 - Traz a opção TODAS      
                                   ,pr_tparquiv   IN VARCHAR2           --> Tipo do arquivo                      
                                   ,pr_cddopcao   IN VARCHAR2           --> Opção da tela
                                   ,pr_cddepart   IN VARCHAR2           --> Departamento do operador
                                   ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                   ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo

  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_solic_proces_retorno             
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Adriano Marchi
    Data     : Agosto/2016                           Ultima atualizacao:  
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para solicitar o processamento de arquivos de retorno enviados pela CETIP
  
    Alterações :  
                
  ---------------------------------------------------------------------------------------------------------------*/
    
    -- Cursor para validacao da cooperativa conectada
    CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%type) IS
      SELECT cdcooper
        FROM crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%rowtype;
    
    --> Verificar se o job 
    CURSOR cr_job (pr_job_name VARCHAR2) IS
    SELECT job.job_name
          ,job.next_run_date
      FROM dba_scheduler_jobs job
     WHERE job.owner = 'CECRED'
      AND job.job_name LIKE pr_job_name||'%';
    rw_job cr_job%ROWTYPE;
    
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000); 
    
    --Variaveis Locais
    vr_dsplsql  VARCHAR2(32767);
    vr_jobname  VARCHAR2(1000);
    vr_cdcoptel INTEGER := nvl(pr_cdcoptel,0);
            
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;                                       
    
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => ct_nmdatela
                                ,pr_action => null); 
                                     
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        
        RAISE vr_exc_erro;
          
      END IF; 
        
      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
        
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;        
      
      IF  vr_cdcooper <> 3 OR pr_cddepart NOT IN (14,20) THEN 

        -- Montar mensagem de critica
        vr_dscritic := 'Operador sem autorizacao para gerar arquivos!';
        RAISE vr_exc_erro;
        
      END IF;
      
      IF vr_cdcoptel > 0 THEN
         
        --Busca a cooperativa
        OPEN cr_crapcop(pr_cdcooper => vr_cdcoptel);
        
        FETCH cr_crapcop INTO rw_crapcop;    
        
        IF cr_crapcop%NOTFOUND THEN
      
          --Fecha o cursor
          CLOSE cr_crapcop;
          
          vr_cdcritic := 794;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

          RAISE vr_exc_erro;
            
        ELSE
          
          --Fecha o cursor
          CLOSE cr_crapcop;
        
        END IF;
        
      END IF;
        
      -- Montar o prefixo do código do programa para o jobname
      vr_jobname := 'GRAVAM_PROCARQRET';    
             
      --> Verificar se o job 
      OPEN cr_job (pr_job_name => vr_jobname);
      
      FETCH cr_job INTO rw_job;
      
      IF cr_job%FOUND THEN
        
        CLOSE cr_job;
        
        -- Montar mensagem de critica
        vr_dscritic := 'Processamento dos arquivos ja solicitado.';
        RAISE vr_exc_erro;
      
      ELSE
        
        CLOSE cr_job;
        
        -- Montar o bloco PLSQL que será executado
        vr_dsplsql:= 'DECLARE'||chr(13)
                   || '  vr_cdcritic PLS_INTEGER;'||chr(13)
                   || '  vr_dscritic VARCHAR2(4000);'||chr(13)
                   || '  vr_des_erro VARCHAR2(3);'||chr(13)
                   || '  vr_nmdcampo VARCHAR2(1000);'||chr(13)
                   || 'BEGIN'||chr(13)
                   || '  GRVM0001.pc_gravames_processa_retorno' 
                   || '  (pr_cdcooper => '||vr_cdcooper
                   || '  ,pr_cdcoptel => '||vr_cdcoptel   
                   || '  ,pr_cdoperad => '||chr(39)||vr_cdoperad||chr(39)    
                   || '  ,pr_tparquiv => '||chr(39)||pr_tparquiv||chr(39)   
                   || '  ,pr_dtmvtolt => '||chr(39)||rw_crapdat.dtmvtolt||chr(39) 
                   || '  ,pr_cdcritic => vr_cdcritic'   
                   || '  ,pr_dscritic => vr_dscritic);'||chr(13)    
                   || 'END;';
        
        --Se conseguiu montar o job
        IF vr_jobname IS NOT NULL THEN
          -- Faz a chamada ao programa paralelo atraves de JOB
          gene0001.pc_submit_job(pr_cdcooper  => vr_cdcooper  --> Código da cooperativa
                                ,pr_cdprogra  => ct_nmdatela  --> Código do programa
                                ,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
                                ,pr_dthrexe   => SYSTIMESTAMP --> Executar nesta hora
                                ,pr_interva   => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                                ,pr_jobname   => vr_jobname   --> Nome randomico criado
                                ,pr_des_erro  => vr_dscritic);
          -- Testar saida com erro
          IF vr_dscritic IS NOT NULL THEN
            -- Levantar exceçao
            RAISE vr_exc_erro;
          END IF;
          
        END IF;
           
      END IF;
     
      --Retorno OK
      pr_des_erro:= 'OK';
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        --Desfaz alteracoes
        ROLLBACK;
        
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        --Monta mensagem de erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        --Desfaz alteracoes
        ROLLBACK;
        
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        --Monta mensagem de erro
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro na TELA_GRAVAM.pc_solic_proces_retorno --> '|| SQLERRM;
        
         -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
                                         
  END pc_solic_proces_retorno;

  /* Procedure para Solicitar o processamento de arquivos de retorno */
  PROCEDURE pc_permissao_situacao(pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                 ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo

  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_permissao_situacao             
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Lucas Lombardi
    Data     : Agosto/2016                           Ultima atualizacao:  
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para validar se pode ser alterado a situação do GRAVAMES
  
    Alterações :  
                
  ---------------------------------------------------------------------------------------------------------------*/
    
    CURSOR cr_crapope (pr_cdcooper crapope.cdcooper%TYPE
                      ,pr_cdoperad crapope.cdoperad%TYPE) IS
      SELECT dpo.dsdepart
        FROM crapdpo   dpo
           , crapope   ope
       WHERE dpo.cddepart = ope.cddepart
         AND dpo.cdcooper = ope.cdcooper
         AND ope.cdcooper = pr_cdcooper
         AND ope.cdoperad = pr_cdoperad;
    rw_crapope cr_crapope%ROWTYPE;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000); 
    
    --Variaveis Locais
    vr_dsdepart     VARCHAR2(1000);
    vr_dsdepart_ope VARCHAR2(1000);
    vr_flgfound     BOOLEAN;
    vr_retorno      VARCHAR2(1);
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;                                       
    
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => ct_nmdatela
                                ,pr_action => null); 
                                     
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      
      -- Buscar os departamentos que podem alterar a situação
      vr_dsdepart := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => vr_cdcooper
                                              ,pr_cdacesso => 'DEPTO_SIT_GRAVAMES');
      
      -- Buscar o departamento em que o operador está cadastrado
      OPEN cr_crapope (vr_cdcooper, vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      vr_flgfound := cr_crapope%FOUND;
      CLOSE cr_crapope;
      
      -- Se não encontrar operador gera erro
      IF NOT vr_flgfound THEN
        vr_cdcritic := 67;
        RAISE vr_exc_erro;
      END IF;
      
      vr_dsdepart_ope := rw_crapope.dsdepart;
      
      -- Retorno do XML
      vr_retorno :=  gene0002.fn_existe_valor(vr_dsdepart, vr_dsdepart_ope,',');
      
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>' || vr_retorno || '</Dados></Root>');

      --Retorno OK
      pr_des_erro:= 'OK';
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        --Desfaz alteracoes
        ROLLBACK;
        
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        --Monta mensagem de erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        --Desfaz alteracoes
        ROLLBACK;
        
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        --Monta mensagem de erro
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro na TELA_GRAVAM.pc_solic_proces_retorno --> '|| SQLERRM;
        
         -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
                                         
  END pc_permissao_situacao;

  PROCEDURE pc_gravames_consultar_bens(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                      ,pr_cddopcao IN VARCHAR2              --Opção
                                      ,pr_nrctrpro IN crawepr.nrctremp%TYPE --Número do contrato 
                                      ,pr_nrgravam IN crapbpr.nrgravam%TYPE --Número do gravame
                                      ,pr_nrregist IN INTEGER               -- Número de registros
                                      ,pr_nriniseq IN INTEGER               -- Número sequencial 
                                      ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_gravames_consultar_bens                            antiga: b1wgen0171.gravames_consultar_bens
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                         Ultima atualizacao: 19/10/2018
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca contratos
    
    --   Alteracoes: 29/05/2017 - Padronização das mensagens para a tabela tbgen_prglog,
    --                          - Inclusão dos parâmetros na mensagem na gravação da tabela TBGEN_PRGLOG
    --                          - Chamada da rotina CECRED.pc_internal_exception para inclusão do erro da exception OTHERS
    --                          - Incluir nome do módulo logado em variável
    --                            (Ana - Envolti) - SD: 660356 e 660394
    -- 
    --               19/10/2018 - P442 - Troca de checagem fixa por funcão para garantir se bem é alienável (Marcos-Envolti)
    -------------------------------------------------------------------------------------------------------------*/                               
  
    --Cursor para encontrar os bens
    CURSOR cr_propostas(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE
                       ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE)IS
    select crawepr.nrctremp,
           crapbpr.nrgravam,
           crapbpr.idseqbem,
           crapbpr.dsbemfin,
           crapbpr.vlmerbem,
           crapbpr.tpchassi,
           crapbpr.nrdplaca,
           crapbpr.nranobem,
           crawepr.vlemprst,
           crapbpr.nrcpfbem,
           upper(crapbpr.uflicenc) uflicenc,
           crapbpr.dscatbem,
           crapbpr.dscorbem,
           crapbpr.dschassi,
           crapbpr.ufdplaca,
           crapbpr.nrrenava,
           crapbpr.nrmodbem,
           crawepr.dtmvtolt,
           crapbpr.ufplnovo,
           crapbpr.nrplnovo,
           crapbpr.nrrenovo,
           crapbpr.dtatugrv,
           crapbpr.flblqjud,
           crapbpr.cdsitgrv,
           crapbpr.tpctrpro,
           crapbpr.dsjstbxa,
           crapbpr.dsjstinc,
           crapbpr.dsjuscnc,
           crapbpr.dsjusjud,
           crapbpr.tpinclus,
           row_number() over(partition by crawepr.cdcooper, crawepr.nrdconta, crawepr.nrctremp order by crawepr.cdcooper, crawepr.nrdconta, crawepr.nrctremp) nrseq_bem
      from crawepr,
           craplcr,
           crapbpr
     where crawepr.cdcooper = pr_cdcooper
       and crawepr.nrdconta = pr_nrdconta
       and crawepr.nrctremp = pr_nrctrpro
       and craplcr.cdcooper = crawepr.cdcooper
       and craplcr.cdlcremp = crawepr.cdlcremp
       and craplcr.tpctrato = 2
       and crapbpr.cdcooper = crawepr.cdcooper
       and crapbpr.nrdconta = crawepr.nrdconta
       and crapbpr.tpctrpro = pr_tpctrpro
       and crapbpr.nrctrpro = crawepr.nrctremp
       and crapbpr.flgalien = 1
       and grvm0001.fn_valida_categoria_alienavel(crapbpr.dscatbem) = 'S';
    
    -- Cursor para encontrar o bem
    CURSOR cr_crapbpr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE
                     ,pr_nrgravam IN crapbpr.nrgravam%TYPE) IS
    select crawepr.nrctremp,
           crapbpr.nrgravam,
           crapbpr.idseqbem,
           crapbpr.dsbemfin,
           crapbpr.vlmerbem,
           crapbpr.tpchassi,
           crapbpr.nrdplaca,
           crapbpr.nranobem,
           crawepr.vlemprst,
           crapbpr.nrcpfbem,
           upper(crapbpr.uflicenc) uflicenc,
           crapbpr.dscatbem,
           crapbpr.dscorbem,
           crapbpr.dschassi,
           crapbpr.ufdplaca,
           crapbpr.nrrenava,
           crapbpr.nrmodbem,
           crawepr.dtmvtolt,
           crapbpr.ufplnovo,
           crapbpr.nrplnovo,
           crapbpr.nrrenovo,
           crapbpr.dtatugrv,
           crapbpr.flblqjud,
           crapbpr.cdsitgrv,
           crapbpr.tpctrpro,
           crapbpr.dsjstinc,
           crapbpr.dsjstbxa,
           crapbpr.dsjuscnc,
           crapbpr.dsjusjud,
           crapbpr.tpinclus,
           row_number() over(partition by crawepr.cdcooper, crawepr.nrdconta, crawepr.nrctremp order by crawepr.cdcooper, crawepr.nrdconta, crawepr.nrctremp) nrseq_bem
      from crapbpr,
           crawepr
     where crapbpr.cdcooper = pr_cdcooper
       and crapbpr.nrdconta = pr_nrdconta
       and crapbpr.tpctrpro = 90
       and crapbpr.nrgravam = pr_nrgravam
       and crapbpr.flgalien = 1
       and grvm0001.fn_valida_categoria_alienavel(crapbpr.dscatbem) = 'S'
       and crawepr.cdcooper = crapbpr.cdcooper
       and crawepr.nrdconta = crapbpr.nrdconta
       and crawepr.nrctremp = crapbpr.nrctrpro;
    rw_crapbpr cr_crapbpr%ROWTYPE;
      
    --Cursor para encotrato o contrato de empréstimo 
    CURSOR cr_crapepr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_nrctremp IN crapepr.nrctremp%TYPE)IS
    SELECT crapepr.nrctremp
      FROM crapepr
     WHERE crapepr.cdcooper = pr_cdcooper
       AND crapepr.nrdconta = pr_nrdconta
       AND crapepr.nrctremp = pr_nrctremp;
    rw_crapepr cr_crapepr%ROWTYPE;                      
                     
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto varchar2(4000);

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_nrdplaca crapbpr.nrplnovo%TYPE;
    vr_ufdplaca crapbpr.ufplnovo%TYPE;
    vr_nrrenava crapbpr.nrrenovo%TYPE;
    vr_stsnrcal BOOLEAN;
    vr_inpessoa INTEGER;
    vr_dscpfbem VARCHAR2(30);
    vr_dsjustif crapbpr.dsjstinc%TYPE;
    vr_tpjustif INTEGER := 0;
    vr_tpctrpro crapbpr.tpctrpro%TYPE;
    
    --Variaveis Locais   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := '';      
    vr_nrregist INTEGER; 
    vr_qtregist INTEGER := 0; 
    vr_contador INTEGER := 0;  
    vr_crapepr  VARCHAR2(50);
    vr_dssitgrv VARCHAR2(50);
    
    vr_tab_erro gene0001.typ_tab_erro;
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';
    
  BEGIN
    vr_nrregist := pr_nrregist;
  
    --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_gravames_consultar_bens');
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
       
    grvm0001.pc_valida_alienacao_fiduciaria (pr_cdcooper => vr_cdcooper  -- Código da cooperativa
                                             ,pr_nrdconta => pr_nrdconta   -- Numero da conta do associado
                                             ,pr_nrctrpro => pr_nrctrpro   -- Numero do contrato
                                             ,pr_des_reto => vr_des_reto   -- Retorno Ok ou NOK do procedimento
                                   ,pr_dscritic => vr_dscritic  -- Retorno da descricao da critica do erro
                                   ,pr_tab_erro => vr_tab_erro  -- Retorno da PlTable de erros
                                   );
    --Se ocorreu erro
    IF vr_des_reto <> 'OK' THEN
        
      --Se possui erro
      IF vr_tab_erro.COUNT > 0 THEN
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSIF trim(vr_dscritic) IS NULL THEN 
        vr_cdcritic:= 0;
        vr_dscritic:= 'Nao foi possivel validar alienacao feduciaria.';
      END IF;
        
      --Levantar Excecao  
      RAISE vr_exc_erro;
        
    END IF; 
      
    --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_gravames_consultar_bens');
      
    -- Verificar se já foi efetivado
    OPEN cr_crapepr(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrctremp => pr_nrctrpro);
                     
    FETCH cr_crapepr INTO rw_crapepr;
              
    IF cr_crapepr%FOUND THEN
        
      vr_crapepr := 'possuictr="1"'; 
        
    ELSE
      
      vr_crapepr := 'possuictr="0"'; 
          
    END IF;
      
    --Fechar Cursor
    CLOSE cr_crapepr;
    
    IF pr_cddopcao = 'S' THEN
    
      vr_tpctrpro := 99;
      
    ELSE
      
      vr_tpctrpro := 90;
      
    END IF;
    
    
    IF pr_nrgravam = 0 THEN
      
      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
          
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><Bens ' || vr_crapepr || '>');     
            
      --Busca as propostas
      FOR rw_propostas IN cr_propostas(pr_cdcooper => vr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrctrpro => pr_nrctrpro
                                      ,pr_tpctrpro => vr_tpctrpro) LOOP
      
        --Incrementar contador
        vr_qtregist:= nvl(vr_qtregist,0) + 1;
                
        -- controles da paginacao 
        IF (vr_qtregist < pr_nriniseq) OR
           (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN

          --Proximo
          CONTINUE;  
                    
        END IF; 
                
        IF vr_nrregist >= 1 THEN   
          
          -- 09.3Q Valida Numero de Inscricao
          gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => rw_propostas.nrcpfbem, 
                                      pr_stsnrcal => vr_stsnrcal, 
                                      pr_inpessoa => vr_inpessoa);
                                      
          vr_dscpfbem := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_propostas.nrcpfbem
                                                  ,pr_inpessoa => vr_inpessoa);
         
          
          IF trim(rw_propostas.ufplnovo) IS NOT NULL AND
             trim(rw_propostas.nrplnovo) IS NOT NULL AND
             rw_propostas.nrrenovo > 0               THEN
             
            vr_nrdplaca := rw_propostas.nrplnovo;
            vr_ufdplaca := rw_propostas.ufplnovo;
            vr_nrrenava := rw_propostas.nrrenovo;
            
          ELSE
            
            vr_nrdplaca := rw_propostas.nrdplaca; 
            vr_ufdplaca := rw_propostas.ufdplaca;
            vr_nrrenava := rw_propostas.nrrenava;  
            
          END IF;
          
          vr_dsjustif := NULL;
          IF pr_cddopcao = 'J' THEN
            vr_tpjustif := 4;
            vr_dsjustif := nvl(trim(rw_propostas.dsjusjud),' ');
          ELSE 
            vr_tpjustif := 1;
            -- Há justificativa de inclusão manual?
            IF trim(rw_propostas.dsjstinc) IS NOT NULL THEN
              vr_dsjustif := 'Inclusao Manual: '||rw_propostas.dsjstinc || CHR(13);
            END IF;
            -- Há justificativa de baixa manual?
            IF trim(rw_propostas.dsjstbxa) IS NOT NULL THEN
              vr_dsjustif := vr_dsjustif || 'Baixa Manual: '||rw_propostas.dsjstbxa || CHR(13);
            END IF;
            -- Há justificativa de cancelamento manual?
            IF trim(rw_propostas.dsjuscnc) IS NOT NULL THEN
              vr_dsjustif := vr_dsjustif || 'Canc. Manual: '||rw_propostas.dsjuscnc || CHR(13);
            END IF;
          end if;
          
          -- Buscar a situação do Gravame
          grvm0001.pc_situac_gravame_bem(pr_cdcooper => vr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrctrpro => pr_nrctrpro
                                        ,pr_idseqbem => rw_propostas.idseqbem
                                        ,pr_dssituac => vr_dssitgrv
                                        ,pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
          -- Carrega os dados           
          gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<ben>'||                                                                                                        
                                                         '  <nrseqbem>' || rw_propostas.nrseq_bem ||'</nrseqbem>'||
                                                         '  <idseqbem>' || rw_propostas.idseqbem ||'</idseqbem>'||
                                                         '  <dsseqbem>' || rw_propostas.nrseq_bem || 'º Bem' ||'</dsseqbem>'||
                                                         '  <nrgravam>' || rw_propostas.nrgravam ||'</nrgravam>'||
                                                         '  <tpctrpro>' || rw_propostas.tpctrpro ||'</tpctrpro>'||
                                                         '  <dsbemfin>' || rw_propostas.dsbemfin ||'</dsbemfin>'||
                                                         '  <vlmerbem>' || to_char(rw_propostas.vlmerbem,'fm99999g999g990d00') ||'</vlmerbem>'||
                                                         '  <tpchassi>' || rw_propostas.tpchassi ||'</tpchassi>'||
                                                         '  <nranobem>' || rw_propostas.nranobem ||'</nranobem>'||
                                                         '  <dscpfbem>' || vr_dscpfbem ||'</dscpfbem>'||
                                                         '  <uflicenc>' || rw_propostas.uflicenc ||'</uflicenc>'||
                                                         '  <dscatbem>' || rw_propostas.dscatbem ||'</dscatbem>'||
                                                         '  <dscorbem>' || rw_propostas.dscorbem ||'</dscorbem>'||
                                                         '  <dschassi>' || rw_propostas.dschassi ||'</dschassi>'||
                                                         '  <nrmodbem>' || rw_propostas.nrmodbem ||'</nrmodbem>'||
                                                         '  <cdsitgrv>' || rw_propostas.cdsitgrv ||'</cdsitgrv>'||
                                                         '  <nrdplaca>' || vr_nrdplaca ||'</nrdplaca>'|| 
                                                         '  <ufdplaca>' || vr_ufdplaca ||'</ufdplaca>'|| 
                                                         '  <nrrenava>' || vr_nrrenava ||'</nrrenava>'|| 
                                                         '  <vlctrgrv>' || to_char(rw_propostas.vlemprst,'fm99999g999g990d00') ||'</vlctrgrv>'|| 
                                                         '  <dtoperac>' || to_char(rw_propostas.dtmvtolt,'DD/MM/RRRR') ||'</dtoperac>'|| 
                                                         '  <dtmvtolt>' || to_char(rw_propostas.dtatugrv,'DD/MM/RRRR') ||'</dtmvtolt>'||    
                                                         '  <dsjustif>' || vr_dsjustif ||'</dsjustif>'||        
                                                         '  <tpjustif>' || vr_tpjustif ||'</tpjustif>'||                                                                                                                                                                      
                                                         '  <dsblqjud>' || (CASE rw_propostas.flblqjud
                                                                              WHEN 1 THEN
                                                                                'SIM'
                                                                              ELSE
                                                                                'NAO'
                                                                            END ) ||'</dsblqjud>'||                                                                                                                                                                                                                            
                                                         '  <dssitgrv>' || vr_dssitgrv ||'</dssitgrv>'||                   
                                                         '  <tpinclus>' || rw_propostas.tpinclus ||'</tpinclus>'|| 
                                                       '</ben>');
          
          --Diminuir registros
          vr_nrregist:= nvl(vr_nrregist,0) - 1;
             
        END IF;         
            
        vr_contador := vr_contador + 1; 
      
      END LOOP;
           
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Bens></Root>'
                             ,pr_fecha_xml      => TRUE);
       
      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);
         
      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob);  
                 
      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml          --> XML que irá receber o novo atributo
                               ,pr_tag   => 'Root'             --> Nome da TAG XML
                               ,pr_atrib => 'qtregist'          --> Nome do atributo
                               ,pr_atval => vr_qtregist         --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                                 
                               
      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite); 
      
    ELSE
      
      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
          
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><Bens ' || vr_crapepr || '>');
                             
      --Busca as propostas
      FOR rw_crapbpr IN cr_crapbpr(pr_cdcooper => vr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctrpro => pr_nrctrpro
                                  ,pr_nrgravam => pr_nrgravam) LOOP
      
        --Incrementar contador
        vr_qtregist:= nvl(vr_qtregist,0) + 1;
                
        -- controles da paginacao 
        IF (vr_qtregist < pr_nriniseq) OR
           (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN

          --Proximo
          CONTINUE;  
                    
        END IF; 
                
        IF vr_nrregist >= 1 THEN   
         
          IF trim(rw_crapbpr.ufplnovo) IS NOT NULL AND
             trim(rw_crapbpr.nrplnovo) IS NOT NULL AND
             rw_crapbpr.nrrenovo > 0               THEN
             
            vr_nrdplaca := rw_crapbpr.nrplnovo;
            vr_ufdplaca := rw_crapbpr.ufplnovo;
            vr_nrrenava := rw_crapbpr.nrrenovo;
            
          ELSE
            
            vr_nrdplaca := rw_crapbpr.nrdplaca; 
            vr_ufdplaca := rw_crapbpr.ufdplaca;
            vr_nrrenava := rw_crapbpr.nrrenava;  
            
          END IF;
          
          vr_dsjustif := NULL;
          IF pr_cddopcao = 'J' THEN
            vr_tpjustif := 4;
            vr_dsjustif := nvl(trim(rw_crapbpr.dsjusjud),' ');
          ELSE 
            vr_tpjustif := 1;
            -- Há justificativa de inclusão manual?
            IF trim(rw_crapbpr.dsjstinc) IS NOT NULL THEN
              vr_dsjustif := 'Inclusao Manual: '||rw_crapbpr.dsjstinc || CHR(13);
            END IF;
            -- Há justificativa de baixa manual?
            IF trim(rw_crapbpr.dsjstbxa) IS NOT NULL THEN
              vr_dsjustif := vr_dsjustif || 'Baixa Manual: '||rw_crapbpr.dsjstbxa || CHR(13);
            END IF;
            -- Há justificativa de cancelamento manual?
            IF trim(rw_crapbpr.dsjuscnc) IS NOT NULL THEN
              vr_dsjustif := vr_dsjustif || 'Canc. Manual: '||rw_crapbpr.dsjuscnc || CHR(13);
            END IF;
          END IF;  
            
          -- Buscar a situação do Gravame
          grvm0001.pc_situac_gravame_bem(pr_cdcooper => vr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrctrpro => pr_nrctrpro
                                        ,pr_idseqbem => rw_crapbpr.idseqbem
                                        ,pr_dssituac => vr_dssitgrv
                                        ,pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
          -- Carrega os dados           
          gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<ben>'||                                                                                                        
                                                         '  <nrseqbem>' || rw_crapbpr.nrseq_bem || '</nrseqbem>'||
                                                         '  <idseqbem>' || rw_crapbpr.idseqbem ||'</idseqbem>'||
                                                         '  <dsseqbem>' || rw_crapbpr.nrseq_bem || 'º Bem' ||'</dsseqbem>'||
                                                         '  <nrgravam>' || rw_crapbpr.nrgravam ||'</nrgravam>'||
                                                         '  <tpctrpro>' || rw_crapbpr.tpctrpro ||'</tpctrpro>'||
                                                         '  <dsbemfin>' || rw_crapbpr.dsbemfin ||'</dsbemfin>'||
                                                         '  <vlmerbem>' || to_char(rw_crapbpr.vlmerbem,'fm99999g999g990d00')  ||'</vlmerbem>'||
                                                         '  <tpchassi>' || rw_crapbpr.tpchassi ||'</tpchassi>'||
                                                         '  <nranobem>' || rw_crapbpr.nranobem ||'</nranobem>'||
                                                         '  <uflicenc>' || rw_crapbpr.uflicenc ||'</uflicenc>'||
                                                         '  <dscatbem>' || rw_crapbpr.dscatbem ||'</dscatbem>'||
                                                         '  <dscorbem>' || rw_crapbpr.dscorbem ||'</dscorbem>'||
                                                         '  <dschassi>' || rw_crapbpr.dschassi ||'</dschassi>'||
                                                         '  <nrmodbem>' || rw_crapbpr.nrmodbem ||'</nrmodbem>'||
                                                         '  <cdsitgrv>' || rw_crapbpr.cdsitgrv ||'</cdsitgrv>'||
                                                         '  <nrdplaca>' || vr_nrdplaca ||'</nrdplaca>'|| 
                                                         '  <ufdplaca>' || vr_ufdplaca ||'</ufdplaca>'|| 
                                                         '  <nrrenava>' || vr_nrrenava ||'</nrrenava>'|| 
                                                         '  <vlctrgrv>' || to_char(rw_crapbpr.vlemprst,'fm99999g999g990d00') ||'</vlctrgrv>'||                                                          
                                                         '  <dtoperac>' || to_char(rw_crapbpr.dtmvtolt,'DD/MM/RRRR') ||'</dtoperac>'|| 
                                                         '  <dtmvtolt>' || to_char(rw_crapbpr.dtatugrv,'DD/MM/RRRR') ||'</dtmvtolt>'||  
                                                         '  <dsjustif>' || vr_dsjustif ||'</dsjustif>'||    
                                                         '  <tpjustif>' || vr_tpjustif ||'</tpjustif>'||                                                                                                                                                                     
                                                         '  <dsblqjud>' || (CASE rw_crapbpr.flblqjud
                                                                              WHEN 1 THEN
                                                                                'SIM'
                                                                              ELSE
                                                                                'NAO'
                                                                            END ) ||'</dsblqjud>'||                                                                                                                                                                                                                            
                                                         '  <dssitgrv>' || vr_dssitgrv ||'</dssitgrv>'||                   
                                                         '  <tpinclus>' || rw_crapbpr.tpinclus ||'</tpinclus>'|| 
                                                       '</ben>');
            
          --Diminuir registros
          vr_nrregist:= nvl(vr_nrregist,0) - 1;
           
        END IF;         
            
        vr_contador := vr_contador + 1; 
      
      END LOOP;               
      
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Bens></Root>'
                             ,pr_fecha_xml      => TRUE);
                               
      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);
           
      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob);  
                   
      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml          --> XML que irá receber o novo atributo
                               ,pr_tag   => 'Root'             --> Nome da TAG XML
                               ,pr_atrib => 'qtregist'          --> Nome do atributo
                               ,pr_atval => vr_qtregist         --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                                   
                                 
      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite); 
        
    END IF;
               
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            

      --Inclusão dos parâmetros apenas na exception, para não mostrar na tela - Chamado 660356
      --Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 1 -- Mensagem
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                    'ALERTA: '|| pr_dscritic ||',Cdoperad:'||vr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                    ',Cddopcao:'||pr_cddopcao||',Nrctrpro:'||pr_nrctrpro||
                                                    ',Nrgravam:'||pr_nrgravam||',Nrregist:'||pr_nrregist||
                                                    ',Nriniseq:'||pr_nriniseq);

    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_gravames_consultar_bens --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
      --Padronização - Chamado 660394
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                    'ERRO: '|| pr_dscritic ||',Cdoperad:'||vr_cdoperad||
                                                    ',Cdcooper:'||vr_cdcooper||',Nrdconta:'||pr_nrdconta||
                                                    ',Cddopcao:'||pr_cddopcao||',Nrctrpro:'||pr_nrctrpro||
                                                    ',Nrgravam:'||pr_nrgravam||',Nrregist:'||pr_nrregist||
                                                    ',Nriniseq:'||pr_nriniseq);

      --Inclusão na tabela de erros Oracle
      CECRED.pc_internal_exception( pr_compleme => pr_dscritic );
    
  END pc_gravames_consultar_bens;
  
  PROCEDURE pc_gravames_imp_relatorio(pr_cddopcao in varchar2,              -- Opção
                                      pr_tparquiv in varchar2,              -- Tipo do arquivo 
                                      pr_cdcoptel in crapcop.cdcooper%type, -- Cooperativa selecionada      
                                      pr_nrseqlot in crapgrv.nrseqlot%type, -- Numero do lote
                                      pr_dtrefere in varchar2,              -- Data de referencia
                                      pr_dtrefate in varchar2,              -- Data de referência final
                                      pr_cdagenci in crapass.cdagenci%type, -- Agência
                                      pr_nrdconta in crapgrv.nrdconta%type, -- Conta
                                      pr_nrctrpro in crapgrv.nrctrpro%type, -- Contrato
                                      pr_flcritic in varchar2,
                                      pr_tipsaida in varchar2,              -- Tipo da saída
                                      pr_dschassi in varchar2,
                                      pr_nrregist IN INTEGER,               -- Quantidade de registros
                                      pr_nriniseq IN INTEGER,               -- Qunatidade inicial
                                      pr_xmllog   in varchar2,              -- XML com informações de LOG
                                      pr_cdcritic out pls_integer,          -- Código da crítica
                                      pr_dscritic out varchar2,             -- Descrição da crítica
                                      pr_retxml   in out nocopy xmltype,    -- Arquivo de retorno do XML
                                      pr_nmdcampo out varchar2,             -- Nome do Campo
                                      pr_des_erro out varchar2) IS          -- Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_gravames_imp_relatorio                           antiga: b1wgen0171.gravames_impressao_relatorio
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                         Ultima atualizacao: 29/05/2017
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Realizar a geração do relatório de processamento de GRAVAMES
    
    Alterações : 14/07/2016 - Ajuste para validar a data nula e tratar corretamento
                              o lote a ser enviado para consulta
                              (Andrei - RKAM).

                 22/09/2016 - Ajuste para utilizar upper ao manipular a informação do chassi
                              pois em alguns casos ele foi gravado em minusculo e outros em maisculo
                              (Adriano - SD 527336)

                 29/05/2017 - Ajuste das mensagens: neste caso são todas consideradas tpocorrencia = 4,
                            - Substituição do termo "ERRO" por "ALERTA",
                            - Padronização das mensagens para a tabela tbgen_prglog,
                            - Inclusão dos parâmetros na mensagem na gravação da tabela TBGEN_PRGLOG
                            - Chamada da rotina CECRED.pc_internal_exception para inclusão do erro da exception OTHERS
                            - Incluir nome do módulo logado em variável
                            - Setar nome módulo no início do programa
                              (Ana - Envolti) - SD: 660356 e 660394
    -------------------------------------------------------------------------------------------------------------*/                               
  
    -- Cursor para validacao da cooperativa conectada
    CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%type) IS
    SELECT cdcooper
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%rowtype;
    
    -- Cursor para encontrar o bem
    CURSOR cr_crapgrv(pr_cdcooper IN crapgrv.cdcooper%TYPE
                     ,pr_dtenvgrv IN crapgrv.dtenvgrv%TYPE                     
                     ,pr_dtenvate IN crapgrv.dtenvgrv%TYPE                     
                     ,pr_cdoperac IN crapgrv.cdoperac%TYPE
                     ,pr_nrseqlot IN crapgrv.nrseqlot%TYPE) IS
    SELECT grv.cdcooper
          ,grv.cdoperac
          ,grv.nrdconta
          ,grv.dtenvgrv
          ,grv.dschassi
          ,grv.nrctrpro
          ,grv.tpctrpro
          ,grv.cdretlot
          ,grv.cdretgrv
          ,grv.cdretctr
          ,grv.nrseqlot
          ,grv.dtretgrv
          ,grv.idseqbem
          ,ass.cdagenci
          ,ass.inpessoa
          ,grvm0001.fn_flag_sucesso_gravame(grv.dtretgrv,grv.cdretlot,grv.cdretgrv,grv.cdretctr) desflgsuc
          ,row_number() over (partition By decode(pr_tipsaida,'TELA',' ',grvm0001.fn_flag_sucesso_gravame(grv.dtretgrv,grv.cdretlot,grv.cdretgrv,grv.cdretctr))
                                          ,grv.dtenvgrv 
                                          ,grv.cdcooper 
                                          ,grv.cdoperac 
                                          ,grv.nrseqlot
                                          ,grv.nrdconta
                                          ,grv.nrctrpro
                                          ,grv.idseqbem
                                  order by decode(pr_tipsaida,'TELA',' ',grvm0001.fn_flag_sucesso_gravame(grv.dtretgrv,grv.cdretlot,grv.cdretgrv,grv.cdretctr))
                                          ,grv.dtenvgrv DESC
                                          ,grv.cdcooper 
                                          ,grv.cdoperac 
                                          ,grv.nrseqlot
                                          ,grv.nrdconta
                                          ,grv.nrctrpro
                                          ,grv.idseqbem) nrseqreg          
          ,count(1) over (partition By decode(pr_tipsaida,'TELA',' ',grvm0001.fn_flag_sucesso_gravame(grv.dtretgrv,grv.cdretlot,grv.cdretgrv,grv.cdretctr))
                                      ,grv.dtenvgrv 
                                      ,grv.cdcooper 
                                      ,grv.cdoperac 
                                      ,grv.nrseqlot
                                      ,grv.nrdconta
                                      ,grv.nrctrpro
                                      ,grv.idseqbem) nrtotreg                        
      FROM crapgrv grv
          ,crapass ass
     WHERE (pr_cdcooper = 0 OR grv.cdcooper = pr_cdcooper)
       AND (pr_cdoperac = 0 OR grv.cdoperac = pr_cdoperac)
       AND (pr_nrseqlot = 0 OR grv.nrseqlot = pr_nrseqlot)
       AND grv.dtenvgrv between nvl(pr_dtenvgrv,grv.dtenvgrv) 
                            and nvl(pr_dtenvate,grv.dtenvgrv)
       and (pr_nrdconta = 0 OR grv.nrdconta = pr_nrdconta)
       and (pr_nrctrpro = 0 OR grv.nrctrpro = pr_nrctrpro)
       and (pr_dschassi is NULL OR grv.dschassi = pr_dschassi)
       AND (pr_cdagenci = 0 OR ass.cdagenci = pr_cdagenci)
       AND ass.cdcooper = grv.cdcooper
       AND ass.nrdconta = grv.nrdconta
       -- Somente criticas irá trazer os sem retorno e com erro
       AND (NVL(pr_flcritic,'N') = 'N' OR grvm0001.fn_flag_sucesso_gravame(grv.dtretgrv,grv.cdretlot,grv.cdretgrv,grv.cdretctr) <> 'S')
       ORDER BY -- Quando relatorio precisamos separar as quebras
                decode(pr_tipsaida,'TELA',' ',grvm0001.fn_flag_sucesso_gravame(grv.dtretgrv,grv.cdretlot,grv.cdretgrv,grv.cdretctr)) 
               ,grv.dtenvgrv DESC
               ,grv.cdcooper 
               ,grv.nrseqlot DESC
               ,grv.cdoperac 
               ,grv.nrdconta
               ,grv.nrctrpro
               ,grv.idseqbem ;
               
    -- Cursor para encontrar o bem
    CURSOR cr_crapbpr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_tpctrpro IN crapbpr.tpctrpro%TYPE
                     ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE
                     ,pr_idseqbem IN crapbpr.idseqbem%TYPE) IS
    SELECT crapbpr.dsmarbem
          ,crapbpr.dsbemfin
          ,crapbpr.nrcpfbem
          ,crapbpr.nrgravam
      FROM crapbpr
     WHERE crapbpr.cdcooper = pr_cdcooper
       AND crapbpr.nrdconta = pr_nrdconta
       AND crapbpr.tpctrpro = pr_tpctrpro
       AND crapbpr.nrctrpro = pr_nrctrpro
       AND crapbpr.flgalien = 1
       AND crapbpr.idseqbem = pr_idseqbem;
    rw_crapbpr cr_crapbpr%ROWTYPE;           
    
    -- Tipo de pessoa
    vr_stsnrcal boolean;
    
    -- Codigos de critica           
    CURSOR cr_craprto(pr_cdoperac IN craprto.cdoperac%TYPE
                     ,pr_nrtabela IN craprto.nrtabela%TYPE
                     ,pr_cdretorn IN craprto.cdretorn%TYPE) IS
    SELECT craprto.cdretorn
          ,craprto.dsretorn
      FROM craprto
     WHERE craprto.cdprodut = 1 --Produto gravames
       AND craprto.cdoperac = pr_cdoperac
       AND craprto.nrtabela = pr_nrtabela
       AND craprto.cdretorn = pr_cdretorn;
    rw_craprto cr_craprto%ROWTYPE;
      
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_comando     VARCHAR2(1000);
    vr_typ_saida   VARCHAR2(3);
        
    --Variaveis Locais   
    vr_nmdireto    VARCHAR2(100);
    vr_dstexto     VARCHAR2(32700);      
    vr_clobxml     CLOB;       
    vr_des_reto    VARCHAR2(3);      
    vr_nmarqpdf    VARCHAR2(1000);
    vr_nmarquiv    VARCHAR2(1000);
    vr_dtrefere    DATE;
    vr_dtrefate    DATE;
    vr_cdoperac    INTEGER;
    vr_qtreglot    INTEGER :=0;
    vr_qtsemret    INTEGER :=0;
    vr_qtdregok    INTEGER :=0; 
    vr_qtregnok    INTEGER :=0;
    vr_dsdgrupo    VARCHAR2(100);
    vr_dsoperac    VARCHAR2(20);
    vr_tparquiv    VARCHAR2(1);
    vr_dssituac    VARCHAR2(4000);
    vr_desretor    VARCHAR2(4000);
    
    vr_tab_erro gene0001.typ_tab_erro;
        
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'GRVM0001';
    
    -- Navegação
    vr_contador INTEGER := 0; -- Contador p/ posicao no XML
  
  BEGIN
    --Incluir nome do módulo logado - Chamado 660394
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'GRVM0001.pc_gravames_imp_relatorio');
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
    
    -- Validar existencia da cooperativa informada
    IF pr_cdcoptel <> 0 THEN      
      OPEN cr_crapcop(pr_cdcoptel);      
      FETCH cr_crapcop INTO rw_crapcop;      
      -- Gerar critica 794 se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        vr_cdcritic := 794;
        -- Sair
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapcop;
        -- Continuaremos
      END IF;
    END IF;
    
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);      
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;      
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    BEGIN                                                  
      --Realiza a conversao da data
      vr_dtrefere := to_date(pr_dtrefere,'DD/MM/RRRR'); 
    EXCEPTION
      WHEN OTHERS THEN
        --Monta mensagem de critica
        vr_dscritic := 'Data de referencia invalida.';
        pr_nmdcampo := 'dtrefere';
        --Gera exceção
        RAISE vr_exc_erro;
    END;

    BEGIN                                                  
      --Realiza a conversao da data
      vr_dtrefate := to_date(pr_dtrefate,'DD/MM/RRRR'); 
    EXCEPTION
      WHEN OTHERS THEN
        --Monta mensagem de critica
        vr_dscritic := 'Data final de referencia invalida.';
        pr_nmdcampo := 'dtrefate';
        --Gera exceção
        RAISE vr_exc_erro;
    END;
    
    -- Validar opção informada
    IF pr_tparquiv NOT IN('TODAS','INCLUSAO','BAIXA','CANCELAMENTO') THEN
      vr_cdcritic := 0;
      vr_dscritic := ' Tipo invalido para Geracao do Arquivo! ';
      RAISE vr_exc_erro;
    END IF; 
    
    -- Se não for informado nenhum filtro, não podemos ter um período superior a 30 dias
    IF nvl(pr_nrseqlot,0) = 0 AND nvl(pr_cdagenci,0) = 0
    AND nvl(pr_nrdconta,0) = 0 AND nvl(pr_nrctrpro,0) = 0 AND trim(pr_dschassi) IS NULL 
    AND to_date(pr_dtrefate,'dd/mm/rrrr') - to_date(pr_dtrefere,'dd/mm/rrrr') > 30 THEN
      vr_cdcritic := 0;
      vr_dscritic := ' Favor selecionar um periodo de-ate no maximo 30 dias! ';
      RAISE vr_exc_erro;
    END IF;
    
    -- Buscar o codigo da operação
    CASE pr_tparquiv
      WHEN 'BAIXA'        THEN
        vr_cdoperac := 3;
      WHEN 'CANCELAMENTO' THEN
        vr_cdoperac := 2;
      WHEN 'INCLUSAO'     THEN
        vr_cdoperac := 1;
      ELSE
        vr_cdoperac := 0;
    END CASE;
       
    --Buscar Diretorio Padrao da Cooperativa
    vr_nmdireto:= gene0001.fn_diretorio (pr_tpdireto => 'C' --> Usr/Coop
                                        ,pr_cdcooper => vr_cdcooper
                                        ,pr_nmsubdir => 'rl');
                                       
    --Nome do Arquivo
    vr_nmarquiv:= vr_nmdireto||'/'||'crrl670' || dbms_random.string('X',20) || '.lst';
      
    --Nome do Arquivo PDF
    vr_nmarqpdf:= REPLACE(vr_nmarquiv,'.lst','.pdf');
      
    -- Inicializar as informações do XML de dados para o relatório
    dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

    --Escrever no arquivo XML
    gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
                             '<?xml version="1.0" encoding="UTF-8"?>' || 
                                '<crrl670><gravames>');
    -- Buscar todas as informações
    FOR rw_crapgrv IN cr_crapgrv(pr_cdcooper => pr_cdcoptel
                                ,pr_dtenvgrv => vr_dtrefere
                                ,pr_dtenvate => vr_dtrefate
                                ,pr_cdoperac => vr_cdoperac
                                ,pr_nrseqlot => nvl(pr_nrseqlot,0)) LOOP
      -- Criar grupo somente no primeiro registro do grupo 
      IF rw_crapgrv.nrseqreg = 1 AND pr_tipsaida = 'PDF' THEN
        -- Buscar descrição da situação e já armazenar totais por grupo
        CASE rw_crapgrv.desflgsuc
          WHEN ' ' THEN
            vr_dsdgrupo := 'GRAVAMES SEM RETORNO';
            vr_qtsemret := rw_crapgrv.nrtotreg;
          WHEN 'S' THEN
            vr_dsdgrupo := 'GRAVAMES IMPORTADOS COM SUCESSO';
            vr_qtdregok := rw_crapgrv.nrtotreg;       
          WHEN 'N' THEN
            vr_dsdgrupo := 'GRAVAMES IMPORTADOS COM ERROS';
            vr_qtregnok := rw_crapgrv.nrtotreg;       
        END CASE;
        -- Incrementar totais
        vr_qtreglot := vr_qtreglot + rw_crapgrv.nrtotreg;
        -- Enviar o grupo
        gene0002.pc_escreve_xml(vr_clobxml
                               ,vr_dstexto
                               ,'<situacao titulo="'||vr_dsdgrupo||'">');
      END IF;
      
      -- Buscar dados do bem relacionado ao envio
      OPEN cr_crapbpr(pr_cdcooper => rw_crapgrv.cdcooper
                     ,pr_nrdconta => rw_crapgrv.nrdconta
                     ,pr_tpctrpro => rw_crapgrv.tpctrpro
                     ,pr_nrctrpro => rw_crapgrv.nrctrpro
                     ,pr_idseqbem => rw_crapgrv.idseqbem);                  
      FETCH cr_crapbpr INTO rw_crapbpr;      
      IF cr_crapbpr%NOTFOUND THEN        
        --Padronização - Chamado 660394
        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'gravam.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                     ' - '||vr_cdprogra||' --> '|| 
                                                     'ERRO: Erro na localizacao do Bem [' || 
                                                     'Cop:' || to_char(rw_crapgrv.cdcooper) || 
                                                     'Cta:' || to_char(rw_crapgrv.nrdconta) || 
                                                     'Tip:' || to_char(rw_crapgrv.tpctrpro) || 
                                                     'Ctr:' || to_char(rw_crapgrv.nrctrpro) || 
                                                     'IdBem:' || to_char(rw_crapgrv.idseqbem)||'][BPR]');  
      END IF;
        
      --Fechar o cursor
      CLOSE cr_crapbpr;
      
      -- Traduzir tipo operação
      CASE rw_crapgrv.cdoperac
        WHEN 1 THEN
          vr_dsoperac := 'INCLUSAO';
          vr_tparquiv := 'I';
        WHEN 2 THEN
          vr_dsoperac := 'CANCELAMENTO';
          vr_tparquiv := 'C';        
        WHEN 3 THEN
          vr_dsoperac := 'BAIXA';
          vr_tparquiv := 'B';        
      END CASE;
      
      -- CPF apenas no relatório
      IF pr_tipsaida = 'PDF' THEN    
        -- Buscar tipo de pessoa conforme o CPF do Interveniente
        gene0005.pc_valida_cpf_cnpj(rw_crapbpr.nrcpfbem
                                   ,vr_stsnrcal
                                   ,rw_crapgrv.inpessoa);
      END IF;
      
      -- Contagem de registros
      vr_contador := vr_contador + 1;
      
      -- Para PDF não há contagem de registros
      IF pr_tipsaida = 'PDF' OR pr_nrregist > 0 AND ((vr_contador >= pr_nriniseq) AND (vr_contador < (pr_nriniseq + pr_nrregist))) THEN
      
        --Escrever no arquivo XML
        gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,
                                   '<registro>' ||
                                      '<dsoperac>' || vr_dsoperac || '</dsoperac>' ||
                                      '<cdcooper>' || TRIM(TO_CHAR(rw_crapgrv.cdcooper,'000')) || '</cdcooper>' ||
                                      '<nrseqlot>' || TRIM(TO_CHAR(rw_crapgrv.nrseqlot,'0000000')) || '</nrseqlot>' ||
                                      '<nrdconta>' || TRIM(gene0002.fn_mask(rw_crapgrv.nrdconta,'zzzz.zzz.z'))  || '</nrdconta>');
        -- CPF apenas no relatório
        IF pr_tipsaida = 'PDF' THEN                          
          IF nvl(rw_crapbpr.nrcpfbem,0) = 0 THEN
            gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'<nrcpfcgc> </nrcpfcgc>');
          ELSE   
            gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'<nrcpfcgc>' || trim(gene0002.fn_mask_cpf_cnpj(rw_crapbpr.nrcpfbem,rw_crapgrv.inpessoa)) || '</nrcpfcgc>');
          END IF;  
        END IF;
        
        -- Montar situação conforme o tipo do registro
        IF rw_crapgrv.desflgsuc = ' ' THEN
          vr_dssituac := 'SEM RETORNO';
          vr_desretor := ' ';
        ELSIF rw_crapgrv.desflgsuc = 'S' THEN
          vr_dssituac := 'SUCESSO';
          vr_desretor := 'Nr. Registro: ' || rw_crapbpr.nrgravam;
        ELSE --> Erro
          vr_dssituac := 'CRITICA';
          vr_desretor := NULL;
          -- Buscar erro 
          /** Exibir todos os retornos com erros **/
          IF rw_crapgrv.cdretlot <> 0 THEN
            -- Buscar critica lote
            OPEN cr_craprto(pr_cdoperac => vr_tparquiv
                           ,pr_nrtabela => 1
                           ,pr_cdretorn => rw_crapgrv.cdretlot);            
            FETCH cr_craprto INTO rw_craprto;            
            IF cr_craprto%NOTFOUND THEN
              vr_desretor := 'LOT: ' || trim(to_char(rw_crapgrv.cdretlot,'999')) || ' - SITUACAO NAO CADASTRADA';
            ELSE
              vr_desretor := 'LOT: ' || trim(to_char(rw_craprto.cdretorn,'999')) || ' - ' || rw_craprto.dsretorn;
            END IF;            
            --Fecha o cursor
            CLOSE cr_craprto;                   
          END IF;
		  IF rw_crapgrv.cdretlot = 0 AND (rw_crapgrv.cdretgrv <> 0 AND rw_crapgrv.cdretgrv <> 30) THEN
            -- Buscar critica GRV
            OPEN cr_craprto(pr_cdoperac => vr_tparquiv
                           ,pr_nrtabela => 2
                           ,pr_cdretorn => rw_crapgrv.cdretgrv);
            
            FETCH cr_craprto INTO rw_craprto;
            
            IF trim(vr_desretor) IS NOT null THEN
              vr_desretor := vr_desretor || chr(10) ;  
            END IF;
                    
            IF cr_craprto%NOTFOUND THEN
              vr_desretor := vr_desretor || 'GRV: ' || trim(to_char(rw_crapgrv.cdretgrv,'999')) || ' - SITUACAO NAO CADASTRADA';
            ELSE
              IF rw_crapgrv.cdretctr <> 0 AND 
                 rw_crapgrv.cdretctr <> 90 THEN
                vr_desretor := vr_desretor || 'GRV: ' || trim(to_char(rw_craprto.cdretorn,'999')) || ' - ' || trim(rw_craprto.dsretorn);
              ELSE
                vr_desretor := vr_desretor || 'GRV: ' || trim(to_char(rw_craprto.cdretorn,'999')) || ' - ' || rw_craprto.dsretorn;
              END IF;
              
            END IF;
            
            --Fecha o cursor
            CLOSE cr_craprto;
          END IF;
		  IF rw_crapgrv.cdretlot = 0 AND rw_crapgrv.cdretctr <> 0 AND rw_crapgrv.cdretctr <> 90 THEN
            -- Buscar critica contrato
            OPEN cr_craprto(pr_cdoperac => vr_tparquiv
                           ,pr_nrtabela => 3
                           ,pr_cdretorn => rw_crapgrv.cdretctr);            
            FETCH cr_craprto INTO rw_craprto;            
            IF trim(vr_desretor) IS NOT null THEN
              vr_desretor := vr_desretor || chr(10) ;  
            END IF;                    
            IF cr_craprto%NOTFOUND THEN
              vr_desretor := vr_desretor || 'CTR: ' || trim(to_char(rw_crapgrv.cdretctr,'999')) || ' - SITUACAO NAO CADASTRADA';
            ELSE
              IF rw_crapgrv.cdretgrv <> 0 AND 
                 rw_crapgrv.cdretgrv <> 30 THEN
                vr_desretor := vr_desretor || 'CTR: ' || trim(to_char(rw_craprto.cdretorn,'999')) || ' - ' || trim(rw_craprto.dsretorn);
              ELSE
                vr_desretor := vr_desretor || 'CTR: ' || trim(to_char(rw_craprto.cdretorn,'999')) || ' - ' || rw_craprto.dsretorn;
              END IF;              
            END IF;
            --Fecha o cursor
            CLOSE cr_craprto;
          END IF;
        END IF;
        -- Enviar restante das informações
        gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,                                      
                                      '<cdagenci>' || TRIM(TO_CHAR(rw_crapgrv.cdagenci,'000')) || '</cdagenci>' ||
                                      '<nrctrpro>' || gene0002.fn_mask_contrato(rw_crapgrv.nrctrpro) || '</nrctrpro>' ||
                                      '<dtenvgrv>' || TO_CHAR(rw_crapgrv.dtenvgrv,'dd/mm/rr hh24:mi:ss') || '</dtenvgrv>' ||
                                      '<dtretgrv>' || TO_CHAR(rw_crapgrv.dtretgrv,'dd/mm/rr hh24:mi:ss') || '</dtretgrv>' ||
                                      '<dschassi>' || rw_crapgrv.dschassi || '</dschassi>' ||
                                      '<dsbemfin>' || '<![CDATA['||rw_crapbpr.dsbemfin||']]>' || '</dsbemfin>' ||
                                      '<dssituac>' || vr_dssituac || '</dssituac>' ||
                                      '<desretor>' || '<![CDATA['||vr_desretor ||']]>' || '</desretor>' ||
                                   '</registro>');                            
      END IF; 
      -- Somente para relatório e no ultimo registro
      IF pr_tipsaida = 'PDF' AND rw_crapgrv.nrseqreg = rw_crapgrv.nrtotreg THEN
        -- Enviar a tag de termino do agrupamento de situações
        gene0002.pc_escreve_xml(vr_clobxml
                               ,vr_dstexto
                               ,'</situacao>');
      END IF;
    END LOOP; 
          
    --Escrever no arquivo XML
    gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'</gravames>' ||
                                                  '<sumario>' ||
                                                     '<Qtdregis>' || vr_contador || '</Qtdregis>' ||
                                                     '<qtreglot>' || vr_qtreglot || '</qtreglot>' ||
                                                     '<qtsemret>' || vr_qtsemret || '</qtsemret>' ||
                                                     '<qtdregok>' || vr_qtdregok || '</qtdregok>' ||
                                                     '<qtregnok>' || vr_qtregnok || '</qtregnok>' ||
                                                  '</sumario>');
    --Finaliza TAG Relatorio
    gene0002.pc_escreve_xml(vr_clobxml,vr_dstexto,'</crrl670>',TRUE); 

    if pr_tipsaida = 'PDF' then
      -- Gera relatório crrl657
      gene0002.pc_solicita_relato(pr_cdcooper    => vr_cdcooper    --> Cooperativa conectada
                                   ,pr_cdprogra  => 'GRAVAM'--vr_nmdatela         --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt         --> Data do movimento atual
                                   ,pr_dsxml     => vr_clobxml          --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crrl670/gravames/situacao/registro' --> Nó base do XML para leitura dos dados                                  
                                   ,pr_dsjasper  => 'crrl670.jasper'    --> Arquivo de layout do iReport
                                   ,pr_dsparams  => NULL                --> Sem parâmetros
                                   ,pr_dsarqsaid => vr_nmarqpdf         --> Arquivo final com o path
                                   ,pr_qtcoluna  => 234                  --> Colunas do relatorio
                                   ,pr_flg_gerar => 'S'                 --> Geraçao na hora
                                   ,pr_cdrelato  => '670'               --> Códigod do relatório
                                   ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p) 
                                   ,pr_nmformul  => '234col'            --> Nome do formulário para impressão
                                   ,pr_nrcopias  => 1                   --> Número de cópias
                                   ,pr_sqcabrel  => 1                   --> Qual a seq do cabrel                                                                          
                                   ,pr_des_erro  => vr_dscritic);       --> Saída com erro

      --Se ocorreu erro no relatorio
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF; 

      --Fechar Clob e Liberar Memoria  
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);  
        
       --Efetuar Copia do PDF
      gene0002.pc_efetua_copia_pdf (pr_cdcooper => vr_cdcooper     --> Cooperativa conectada
                                   ,pr_cdagenci => vr_cdagenci     --> Codigo da agencia para erros
                                   ,pr_nrdcaixa => vr_nrdcaixa     --> Codigo do caixa para erros
                                   ,pr_nmarqpdf => vr_nmarqpdf     --> Arquivo PDF  a ser gerado                                 
                                   ,pr_des_reto => vr_des_reto     --> Saída com erro
                                   ,pr_tab_erro => vr_tab_erro);   --> tabela de erros 
                                     
      --Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
          
        --Se possui erro
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Nao foi possivel efetuar a copia do relatorio.';
        END IF;
          
        --Levantar Excecao  
        RAISE vr_exc_erro;
          
      END IF; 

          
      --Se Existir arquivo pdf  
      IF gene0001.fn_exis_arquivo(pr_caminho => vr_nmarqpdf) THEN
          
        --Remover arquivo
        vr_comando:= 'rm '||vr_nmarqpdf||' 2>/dev/null';
          
        --Executar o comando no unix
        GENE0001.pc_OScommand (pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);
                            
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
            
          --Monta mensagem de critica
          vr_dscritic:= 'Nao foi possivel executar comando unix: '||vr_comando;
            
          -- retornando ao programa chamador
          RAISE vr_exc_erro;
            
        END IF;
          
      END IF;
          
      --Se ocorreu erro
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN                                   
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      
      --Retornar nome arquivo impressao e pdf
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
              
      -- Insere atributo na tag Dados com o valor total de agendamentos
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'Dados'             --> Nome da TAG XML
                               ,pr_atrib => 'nmarquiv'          --> Nome do atributo
                               ,pr_atval => substr(vr_nmarqpdf,instr(vr_nmarqpdf,'/',-1)+1)         --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros 
    else
      -- Se não for pra gerar o relatório em PDF, devolve o XML para ser tratado no ayllosweb
      pr_retxml := xmltype.createXML(vr_clobxml);
      --Fechar Clob e Liberar Memoria  
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml);  
    end if;
    
    pr_des_erro := 'OK';  
    
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
                                     
      --Padronização - Chamado 660394
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 1 -- Mensagem
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                    'ALERTA: '|| pr_dscritic ||
                                                    ',Cdcooper:'||vr_cdcooper||',Dtrefere:'||pr_dtrefere||
                                                    ',Cdcoptel:'||pr_cdcoptel||',Nrseqlot:'||pr_nrseqlot||
                                                    ',Tparquiv:'||pr_tparquiv||',Cddopcao:'||pr_cddopcao);
                 
                                           
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_gravames_imp_relatorio --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
      
      --Padronização - Chamado 660394
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - '||vr_cdprogra||' --> '|| 
                                                    'ERRO: '|| pr_dscritic ||
                                                    ',Cdcooper:'||vr_cdcooper||',Dtrefere:'||pr_dtrefere||
                                                    ',Cdcoptel:'||pr_cdcoptel||',Nrseqlot:'||pr_nrseqlot||
                                                    ',Tparquiv:'||pr_tparquiv||',Cddopcao:'||pr_cddopcao);

      --Inclusão na tabela de erros Oracle
      CECRED.pc_internal_exception( pr_compleme => pr_dscritic );
        
  END pc_gravames_imp_relatorio;


END TELA_GRAVAM;
/
