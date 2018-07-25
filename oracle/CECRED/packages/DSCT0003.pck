CREATE OR REPLACE PACKAGE CECRED.DSCT0003 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa:  DSCT0003                       Antiga: generico/procedures/b1wgen0030.p
  --  Autor   : Andr� �vila - GFT
  --  Data    : Abril/2018                     Ultima Atualizacao: 10/04/2018
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package para rotinas para atender a An�lise Autom�tica e Libera��o de Border�s
  --
  --
  --  Alteracoes: 10/04/2018 - Conversao Progress para oracle (Andr� �vila - GFT)
  --
  --              10/04/2018 - Criacao da procedure pc_efetua_liberacao_bordero
  --              26/04/2018 - Andrew Albuquerque (GFT) - Adicionar Chamada a Mesa de Checagem e a Esteira de Cr�dito IBRATAN:
  --                           Altera��o nas procedures: pc_altera_status_bordero (gravar opcionalmente campos de status de 
  --                           an�lise e mesa de checagem / pc_restricoes_tit_bordero (valida��es impeditivas movidas para a
  --                           pc_efetua_analise_bordero) / pc_efetua_analise_bordero: adicionado parametro para dizer se 
  --                           realiza analise completa ou apenas a impeditiva; alterada valida��o p�s restri��es, para executar
  --                           apenas quando chamado por an�lise e para enviar para mesa de checagem ou esteira; Valida��o de
  --                           conting�ncia movida para verificar antes de enviar dados para a mesa do ibratan.
  ---------------------------------------------------------------------------------------------------------------

  -- Constantes
  vr_cdhistordsct_iofspriadic    CONSTANT craphis.cdhistor%TYPE := 2320; --IOF S/ DESCONTO DE TITULOS�(PRINCIPAL E ADICIONAL)
  vr_cdhistordsct_iofscomplem    CONSTANT craphis.cdhistor%TYPE := 2321; --IOF S/ DESCONTO DE TITULOS (COMPLEMENTAR)
  vr_cdhistordsct_credito        CONSTANT craphis.cdhistor%TYPE := 2664; --CREDITO DESCONTO DE TITULO
  vr_cdhistordsct_liberacred     CONSTANT craphis.cdhistor%TYPE := 2665; --LIBERACAO DO CREDITO DESCONTO DE TITULO
  vr_cdhistordsct_rendaapropr    CONSTANT craphis.cdhistor%TYPE := 2666; --RENDA A APROPRIAR SOBRE DESCONTO DE TITULO
  vr_cdhistordsct_apropjurrem    CONSTANT craphis.cdhistor%TYPE := 2667; --APROPR. JUROS REMUNERATORIOS DESCONTO DE TITULO
  vr_cdhistordsct_apropjurmra    CONSTANT craphis.cdhistor%TYPE := 2668; --APROPR. JUROS DE MORA DESCONTO DE TITULO
  vr_cdhistordsct_apropjurmta    CONSTANT craphis.cdhistor%TYPE := 2669; --APROPR. MULTA DESCONTO DE TITULO
  vr_cdhistordsct_pgtocc         CONSTANT craphis.cdhistor%TYPE := 2670; --PAGTO DESCONTO DE TITULO (conta cooperado)
  vr_cdhistordsct_pgtoopc        CONSTANT craphis.cdhistor%TYPE := 2671; --PAGTO DESCONTO DE TITULO (operacao credito)
  vr_cdhistordsct_pgtocompe      CONSTANT craphis.cdhistor%TYPE := 2672; --PAGTO DESCONTO TITULO VIA COMPE
  vr_cdhistordsct_pgtocooper     CONSTANT craphis.cdhistor%TYPE := 2673; --PAGTO DESCONTO DE TITULO VIA COOPERATIVA (Caixa/IB/TAA)
  vr_cdhistordsct_pgtoavalcc     CONSTANT craphis.cdhistor%TYPE := 2674; --PAGTO DESCONTO DE TITULO AVAL	(conta cooperado)
  vr_cdhistordsct_pgtoavalopc    CONSTANT craphis.cdhistor%TYPE := 2675; --PAGTO DESCONTO DE TITULO AVAL	(operacao credito)
  vr_cdhistordsct_rendapgtoant   CONSTANT craphis.cdhistor%TYPE := 2680; --RENDA SOBRE PGTO ANTECIPADO DESCONTO DE TITULO (conta cooperado)
  vr_cdhistordsct_pgtomultacc    CONSTANT craphis.cdhistor%TYPE := 2681; --PAGTO DE MULTA SOBRE DESCONTO DE TITULO (conta cooperado)
  vr_cdhistordsct_pgtomultaopc   CONSTANT craphis.cdhistor%TYPE := 2682; --PAGTO DE MULTA SOBRE DESCONTO DE TITULO (operacao credito)
  vr_cdhistordsct_pgtomultaavcc  CONSTANT craphis.cdhistor%TYPE := 2683; --PAGTO DE MULTA SOBRE DESCONTO DE TITULO AVAL (conta cooperado)
  vr_cdhistordsct_pgtomultaavopc CONSTANT craphis.cdhistor%TYPE := 2684; --PAGTO DE MULTA SOBRE DESCONTO DE TITULO AVAL (operacao credito)
  vr_cdhistordsct_pgtojuroscc    CONSTANT craphis.cdhistor%TYPE := 2685; --PAGTO DE JUROS MORA SOBRE DESCONTO DE TITULO (conta cooperado)
  vr_cdhistordsct_pgtojurosopc   CONSTANT craphis.cdhistor%TYPE := 2686; --PAGTO DE JUROS MORA SOBRE DESCONTO DE TITULO (operacao credito)
  vr_cdhistordsct_pgtojurosavcc  CONSTANT craphis.cdhistor%TYPE := 2687; --PAGTO DE JUROS MORA SOBRE DESCONTO DE TITULO AVAL (conta cooperado)
  vr_cdhistordsct_pgtojurosavopc CONSTANT craphis.cdhistor%TYPE := 2688; --PAGTO DE JUROS MORA SOBRE DESCONTO DE TITULO AVAL (operacao credito)

  
  --Tipo de Desconto de T�tulos
  TYPE typ_desconto_titulos IS RECORD --(b1wgen0030.p/tt-desconto_titulos)
      (nrctrlim NUMBER
      ,dtinivig craplim.dtinivig%TYPE
      ,qtdiavig NUMBER
      ,vllimite NUMBER
      ,qtrenova NUMBER
      ,dsdlinha crapldc.dsdlinha%TYPE
      ,vlutiliz NUMBER
      ,qtutiliz NUMBER
      ,cddopcao NUMBER
      ,dtrenova craplim.dtrenova%TYPE
      ,perrenov NUMBER
      ,cddlinha NUMBER
      ,flgstlcr crapldc.flgstlcr%TYPE
      ,vlutilcr NUMBER
      ,qtutilcr NUMBER
      ,vlutilsr NUMBER
      ,qtutilsr NUMBER);
  TYPE typ_tab_desconto_titulos IS TABLE OF typ_desconto_titulos INDEX BY PLS_INTEGER;

  --Tipo para Retorno dos Detalhes de Status Finais do Bordero.
  TYPE typ_retorno_analise IS RECORD
      (cdcooper crapbdt.cdcooper%TYPE
      ,nrborder crapbdt.nrborder%TYPE
      ,nrdconta crapbdt.nrdconta%TYPE
      ,dssitres VARCHAR2(2000));
  TYPE typ_tab_retorno_analise IS TABLE OF typ_retorno_analise INDEX BY PLS_INTEGER;

  /* Tipo que compreende o registro da tab. tempor�ria tt-msg-confirma */
  TYPE typ_reg_msg_confirma IS RECORD(
     inconfir INTEGER
    ,dsmensag VARCHAR2(4000));
  /* Tipo utilizado na pc_efetua_analise_bordero*/
  TYPE typ_tab_msg_confirma IS TABLE OF typ_reg_msg_confirma INDEX BY PLS_INTEGER;

  /*Tabela de retorno dos titulos do bordero*/
  TYPE typ_rec_tit_bordero
       IS RECORD (nrdctabb craptdb.nrdctabb%TYPE,
                  nrcnvcob craptdb.nrcnvcob%TYPE,
                  nrinssac craptdb.nrinssac%TYPE,
                  cdbandoc craptdb.cdbandoc%TYPE,
                  nrdconta craptdb.nrdconta%TYPE,
                  nrdocmto craptdb.nrdocmto%TYPE,
                  dtvencto craptdb.dtvencto%TYPE,
                  dtlibbdt craptdb.dtlibbdt%TYPE,
                  vltitulo craptdb.vltitulo%TYPE,
                  vlliquid craptdb.vlliquid%TYPE,
                  nmsacado crapsab.nmdsacad%TYPE,
                  flgregis crapcob.flgregis%TYPE,
                  insittit craptdb.insittit%TYPE,
                  vlsldtit craptdb.vlsldtit%TYPE,
                  vlmtatit craptdb.vlmtatit%TYPE,
                  vlpagmta craptdb.vlpagmta%TYPE,
                  vlmratit craptdb.vlmratit%TYPE,
                  vlpagmra craptdb.vlpagmra%TYPE,
                  vliofcpl craptdb.vliofcpl%TYPE,
                  vlpagiof craptdb.vlpagiof%TYPE,
                  nrtitulo craptdb.nrtitulo%TYPE,
                  vlpago   NUMBER(25,2),
                  vlmulta  NUMBER(25,2),
                  vlmora   NUMBER(25,2),
                  vliof    NUMBER(25,2),
                  vlpagar  NUMBER(25,2),
                  nrnumlin NUMBER,
                  qttotlin NUMBER
                  );

  TYPE typ_tab_tit_bordero IS TABLE OF typ_rec_tit_bordero
       INDEX BY BINARY_INTEGER;

  TYPE typ_rec_critica 
       IS RECORD (cdcritica tbdsct_criticas.cdcritica%TYPE,
                  dscritica tbdsct_criticas.dscritica%TYPE,
                  tpcritica tbdsct_criticas.tpcritica%TYPE,
                  nrborder crapabt.nrborder%TYPE,
                  nrdconta crapabt.nrdconta%TYPE,
                  cdcooper crapabt.cdcooper%TYPE,
                  cdbandoc crapabt.cdbandoc%TYPE,
                  nrdctabb crapabt.nrdctabb%TYPE,
                  nrcnvcob crapabt.nrcnvcob%TYPE,
                  nrdocmto crapabt.nrdocmto%TYPE,
                  dsdetres crapabt.dsdetres%TYPE
                  );
  TYPE typ_tab_critica IS TABLE OF typ_rec_critica
       INDEX BY BINARY_INTEGER;
                  
                  
  CURSOR cr_tbdsct_criticas (pr_cdcritica IN tbdsct_criticas.cdcritica%TYPE) IS
    SELECT 
      *
    FROM 
      tbdsct_criticas
    WHERE cdcritica = pr_cdcritica;
  rw_tbdsct_criticas cr_tbdsct_criticas%ROWTYPE;
  
  CURSOR cr_crapabt (pr_cdcooper IN crapabt.cdcooper%TYPE,
                 pr_nrborder IN crapabt.nrborder%TYPE,
                 pr_tpcritica IN tbdsct_criticas.tpcritica%TYPE DEFAULT NULL,
                 pr_nrdconta IN crapabt.nrdconta%TYPE DEFAULT NULL,
                 pr_cdbandoc IN crapabt.cdbandoc%TYPE DEFAULT NULL,
                 pr_nrdctabb IN crapabt.nrdctabb%TYPE DEFAULT NULL,
                 pr_nrdocmto IN crapabt.nrdocmto%TYPE DEFAULT NULL,
                 pr_cdcritica IN tbdsct_criticas.cdcritica%TYPE DEFAULT NULL) IS
    SELECT 
      cri.dscritica,
      abt.dsdetres
    FROM 
      crapabt abt
      INNER JOIN tbdsct_criticas cri ON cri.cdcritica = abt.nrseqdig
    WHERE
      abt.cdcooper = pr_cdcooper
      AND abt.nrborder = pr_nrborder
      AND cri.tpcritica = nvl(pr_tpcritica,cri.tpcritica)
      AND cri.cdcritica = nvl(pr_cdcritica,cri.cdcritica)
      AND nvl(abt.nrdconta,0) = nvl(pr_nrdconta,nvl(abt.nrdconta,0))
      AND nvl(abt.cdbandoc,0) = nvl(pr_cdbandoc,nvl(abt.cdbandoc,0))
      AND nvl(abt.nrdctabb,0) = nvl(pr_nrdctabb,nvl(abt.nrdctabb,0))
      AND nvl(abt.nrdocmto,0) = nvl(pr_nrdocmto,nvl(abt.nrdocmto,0))
  ;
  rw_abt cr_crapabt%ROWTYPE;

  FUNCTION fn_ds_critica(pr_cdcritica IN tbdsct_criticas.cdcritica%TYPE) RETURN VARCHAR2;

  FUNCTION fn_busca_situacao_bordero (pr_insitbdt crapbdt.insitbdt%TYPE) RETURN VARCHAR2;
  
  FUNCTION fn_busca_decisao_bordero (pr_insitapr crapbdt.insitapr%TYPE) RETURN VARCHAR2;
  
  -- Funcao de calculo de restricao do CNAE                                  
  FUNCTION fn_calcula_cnae(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa conectada
                           ,pr_nrdconta IN crapass.nrdconta%TYPE   --> Conta do associado
                           ,pr_nrdocmto IN crapcob.nrdocmto%TYPE   --> Numero do documento(Boleto)
                           ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE   --> Numero do convenio de cobranca.
                           ,pr_nrdctabb IN crapcob.nrdctabb%TYPE   --> Numero da conta base no banco.
                           ,pr_cdbandoc IN crapcob.cdbandoc%TYPE   --> Codigo do banco/caixa.
         )RETURN BOOLEAN;
         
  -- Verificar se o bordero est� nas novas funcionalidades ou na antiga         
  FUNCTION fn_virada_bordero (pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN INTEGER;
                             
  -- C�lculo da Liquidez Geral
  FUNCTION fn_calcula_liquidez_geral (pr_nrdconta      IN crapass.nrdconta%type
                                      ,pr_cdcooper     IN crapcop.cdcooper%TYPE
                                      ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE
                                      ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                                      ,pr_qtcarpag     IN NUMBER
                                      )RETURN NUMBER;
          
  -- C�lculo da Concentra��o do t�tulo do pagador
  FUNCTION fn_concentracao_titulo_pagador (pr_cdcooper     IN craptdb.cdcooper%TYPE
                                          ,pr_nrdconta     IN craptdb.nrdconta%TYPE
                                          ,pr_nrinssac     IN crapcob.nrinssac%TYPE
                                          ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE 
                                          ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                                          ,pr_qtcarpag     IN NUMBER
                                          ) RETURN NUMBER;
                                
  -- C�lculo da Liquidez do Pagador
  FUNCTION fn_liquidez_pagador_cedente (pr_cdcooper     IN craptdb.cdcooper%TYPE
                                       ,pr_nrdconta     IN craptdb.nrdconta%TYPE
                                       ,pr_nrinssac     IN crapcob.nrinssac%TYPE
                                       ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE 
                                       ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                                       ,pr_qtcarpag     IN NUMBER
                                        ) RETURN NUMBER;

  FUNCTION fn_cobranca_cobtit(pr_cdcooper IN crapbdt.cdcooper%TYPE --> C�digo da Cooperativa
                             ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                             ) RETURN BOOLEAN;

  PROCEDURE pc_liberar_bordero_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                   ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                   ,pr_confirma IN PLS_INTEGER            --> numero do bordero
                                   --  (OBRIGAT�RIOS E NESSA ORDEM SEMPRE)
                                   ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                   --------> OUT <--------
                                   ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                   ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                   ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                   ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);      --> Erros do processo

  /*Procedure que grava as restri��es de um border� (b1wgen0030.p/grava-restricao-bordero)*/
  PROCEDURE pc_grava_restricao_bordero (pr_nrborder IN crapabt.nrborder%TYPE --> N�mero do Border�
                                       ,pr_cdoperad IN crapabt.cdoperad%TYPE DEFAULT NULL --> Codigo do operador
                                       ,pr_nrdconta IN crapabt.nrdconta%TYPE
                                       ,pr_dsrestri IN crapabt.dsrestri%TYPE --> Descri��o da Restri��o
                                       ,pr_nrseqdig IN crapabt.nrseqdig%TYPE --> Sequ�ncial da Restri��o
                                       ,pr_cdcooper IN crapabt.cdcooper%TYPE --> C�digo da Cooperativa
                                       ,pr_cdbandoc IN crapabt.cdbandoc%TYPE DEFAULT 0
                                       ,pr_nrdctabb IN crapabt.nrdctabb%TYPE DEFAULT 0
                                       ,pr_nrcnvcob IN crapabt.nrcnvcob%TYPE DEFAULT 0
                                       ,pr_nrdocmto IN crapabt.nrdocmto%TYPE DEFAULT 0
                                       ,pr_flaprcoo IN crapabt.flaprcoo%TYPE --> Indicador se foi aprovado pelo coordenador (1 Sim / 0 N�o)
                                       ,pr_dsdetres IN crapabt.dsdetres%TYPE --> Detalhamento da restricao
                                       ,pr_dscritic    OUT VARCHAR2                --> Descricao Critica
                                       );

  /* Retona a qtd. de T�tulos de acordo com alguma ocorrencia (b1wgen0030.p/retorna-titulos-ocorrencia) */
  PROCEDURE pc_ret_qttit_ocorrencia (pr_cdcooper IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                                    ,pr_nrdconta IN craptdb.nrdconta%TYPE --> N�mero da Conta
                                    ,pr_nrinssac IN craptdb.nrinssac%TYPE --> Pagador
                                    ,pr_cdocorre IN crapret.cdocorre%TYPE --> C�digo do Tipo de Ocorr�ncia
                                    ,pr_cdmotivo IN crapret.cdmotivo%TYPE DEFAULT '' --> Cont�m o C�digo do Motivo
                                    ,pr_flgtitde IN boolean DEFAULT FALSE --> Qual Tipo de T�tulo (FALSE= Apenas T�tulos em Border�)
                                    --------> OUT <--------
                                    ,pr_cntqttit OUT PLS_INTEGER          --> Quantidade de T�tulos de Acordo com o Filtro.
                                    );

  /* Buscar dados do Principal (@) da rotina Desconto de Titulos (b1wgen0030.p/busca_dados_dsctit) */
  PROCEDURE pc_busca_dados_dsctit (pr_cdcooper IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                                  ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL --> Codigo do operador
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                  ,pr_idorigem IN INTEGER  --Identificador Origem pagamento
                                  ,pr_nrdconta IN craptdb.nrdconta%TYPE DEFAULT NULL --> N�mero da Conta
                                  ,pr_idseqttl IN INTEGER       --> idseqttl
                                  ,pr_nmdatela IN VARCHAR2      --> Nome da tela
                                  ,pr_flgerlog IN BOOLEAN       --> identificador se deve gerar log
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT INTEGER   --> Codigo Critica
                                  ,pr_dscritic OUT VARCHAR2  --> Descricao Critica
                                  ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela erros
                                  ,pr_tab_dados_dsctit OUT typ_tab_desconto_titulos --> Tabela de Retorno
                                  ,pr_des_reto OUT VARCHAR2
                                  );

  /* Verifica se os titulos ja estao em algum bordero (b1wgen0030.p/valida_titulos_bordero)*/
  PROCEDURE pc_valida_tit_bordero (pr_cdcooper IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                                  ,pr_cdagenci IN crawlim.cdagenci%TYPE --> C�digo da Ag�ncia
                                  ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE
                                  ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                  ,pr_idorigem IN INTEGER  --> Identificador Origem pagamento
                                  ,pr_nrdconta IN craptdb.nrdconta%TYPE DEFAULT NULL --> N�mero da Conta
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE
                                  ,pr_tpvalida IN INTEGER DEFAULT 1 --> 1: An�lise do Border� 2: Inclus�o do Border�.
                                  --------> OUT <--------
                                  ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela Erros
                                  ,pr_des_reto OUT VARCHAR2
                                  );

  /* Procura estri�oes de um border� e cria entradas na  tabela de restri��es quando encontradas (b1wgen0030.p/analisar-titulo-bordero) */
  PROCEDURE pc_restricoes_tit_bordero (pr_cdcooper IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                                      ,pr_cdagenci IN crawlim.cdagenci%TYPE --> C�digo da Ag�ncia
                                      ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE
                                      ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                                      ,pr_nmdatela IN VARCHAR2      --> Nome da tela
                                      ,pr_idorigem IN INTEGER  --> Identificador Origem pagamento
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                      ,pr_nrdconta IN craptdb.nrdconta%TYPE DEFAULT NULL --> N�mero da Conta
                                      ,pr_idseqttl IN INTEGER       --> idseqttl
                                      ,pr_nrborder IN crapbdt.nrborder%TYPE
                                      ,pr_flgerlog IN BOOLEAN       --> identificador se deve gerar log
                                      --------> OUT <--------
                                      ,pr_indrestr IN OUT PLS_INTEGER
                                      ,pr_flsnhcoo OUT BOOLEAN
                                      ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela Erros
                                      ,pr_cdcritic    OUT INTEGER                 --> Codigo Critica
                                      ,pr_dscritic    OUT VARCHAR2                --> Descricao Critica
                                      );

  PROCEDURE pc_envia_esteira (pr_cdcooper IN crapabt.cdcooper%TYPE
                             ,pr_nrdconta IN crapabt.nrdconta%TYPE
                             ,pr_nrborder IN crapabt.nrborder%TYPE
                             ,pr_cdagenci IN crapass.cdagenci%type --> C�digo da Ag�ncia
                             ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                             ,pr_dtmvtolt IN crapbdt.dtmvtolt%TYPE
                             --------- OUT ---------
                             ,pr_cdcritic OUT INTEGER   --> Codigo Critica
                             ,pr_dscritic OUT VARCHAR2  --> Descricao Critica
                             ,pr_des_erro OUT VARCHAR2  --> Erros do processo
                             );

  /* Efetuar a An�lise Completa do Border� */
  PROCEDURE pc_efetua_analise_bordero (pr_cdcooper IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                                      ,pr_cdagenci IN crapass.cdagenci%type --> C�digo da Ag�ncia
                                      ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Numero Caixa
                                      ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                                      ,pr_nmdatela IN craplgm.nmdatela%TYPE --> Nome da tela.
                                      ,pr_idorigem IN VARCHAR2              --> Identificador Origem pagamento
                                      ,pr_nrdconta IN craptdb.nrdconta%TYPE --> N�mero da Conta
                                      ,pr_idseqttl IN INTEGER               --> idseqttl
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                      ,pr_dtmvtopr IN crapdat.dtmvtolt%TYPE --> Proxima data de movimento.
                                      ,pr_inproces IN crapdat.inproces%TYPE --> Indicador processo
                                      ,pr_nrborder IN crapbdt.nrborder%TYPE --> N�mero do Bordero
                                      ,pr_inrotina IN INTEGER DEFAULT 0     --> Indica o tipo de an�lise (0-APENAS IMPEDITIVOS / 1-IMPEDITIVOS+RESTRI��ES COM APROVA��O DE AN�LISE)
                                      ,pr_flgerlog IN BOOLEAN               --> identificador se deve gerar log
                                      ,pr_insborde IN INTEGER DEFAULT 0     --> Indica se a analise esta sendo feito na inser��o apenas para aprovar automatico
                                      --------> OUT <--------
                                      ,pr_indrestr OUT PLS_INTEGER          --> Indica se Gerou Restri��o (0 - Sem Restri��o / 1 - Com restri��o)
                                      ,pr_ind_inpeditivo OUT PLS_INTEGER          --> Indica se o Resultado � Impeditivo para Realizar Libera��o. (0 - Sem Impedimentos / 1 - Com Impedimentos)
                                      ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela Erros
                                      ,pr_tab_retorno_analise OUT typ_tab_retorno_analise --> Detalhes Finais da Analise do Bordero.
                                      ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                      ,pr_dscritic OUT VARCHAR2             --> Descri�ao da cr�tica
                                      );

  PROCEDURE pc_efetua_analise_bordero_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                          ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                           --  (OBRIGAT�RIOS E NESSA ORDEM SEMPRE)
                                          ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                          --------> OUT <--------
                                          ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                          ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                          ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                          ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2);      --> Erros do processo
                                          
  -- Procedure que busca um associado a partir da conta ou cpf/cnpj
  PROCEDURE pc_buscar_associado_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                   ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE  --> N�mero do CPF/CNPJ
                                   ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                   --------> OUT <--------
                                   ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                   ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                   ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                   ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                   );

 -- Procedure para rejeitar um determinado bordero
  PROCEDURE pc_rejeitar_bordero_web (pr_nrdconta  IN crapbdt.nrdconta%TYPE  --> Conta
                                    ,pr_nrborder  IN crapbdt.nrborder%TYPE  --> Bordero

                                    ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                    ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                    ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo
  
  -- Verificar se o bordero est� nas novas funcionalidades ou na antiga
  PROCEDURE pc_virada_bordero (pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                               --------> OUT <--------
                               ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                               ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                               ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                               ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                             );
                                        
  -- Buscar todo os titulos vencidos de um bordero                                        
  PROCEDURE pc_busca_titulos_vencidos_web(pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                    ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                    ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                    --------> OUT <--------
                                    ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                    ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2             --> Erros do processo
                                    );    
  PROCEDURE pc_calcula_possui_saldo (pr_nrdconta  IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                    ,pr_nrborder  IN crapbdt.nrborder%TYPE  --> Numero do bordero   
                                    ,pr_arrtitulo IN VARCHAR2           --> Lista dos titulos
                                    ,pr_xmllog    IN VARCHAR2               --> XML com informa��es de LOG
                                    --------> OUT <--------
                                    ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                    ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                    ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                   );
 PROCEDURE pc_pagar_titulos_vencidos (pr_nrdconta         IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                     ,pr_nrborder         IN crapbdt.nrborder%TYPE  --> Numero do bordero   
                                     ,pr_flavalista       IN VARCHAR2                --> Caso seja pagamento com avalista
                                     ,pr_arrtitulo        IN VARCHAR2               --> Lista dos titulos
                                     ,pr_xmllog           IN VARCHAR2               --> XML com informa��es de LOG
                                     --------> OUT <--------
                                     ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                     ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                     ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                    ) ;

 PROCEDURE pc_inserir_lancamento_bordero(pr_cdcooper  IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE --> N�mero da Conta
                                       ,pr_nrborder  IN crapbdt.nrborder%TYPE --> numero do bordero
                                       ,pr_dtmvtolt  IN craplcm.dtmvtolt%TYPE --> Data do movimento atual
                                       ,pr_cdorigem  IN INTEGER               --> Codigo Origem Lancamento
                                       ,pr_cdhistor  IN craphis.cdhistor%TYPE --> Codigo do historico do lancamento
                                       ,pr_vllanmto  IN tbdsct_lancamento_bordero.vllanmto%TYPE           --> Valor do lancamento
                                       ,pr_cdbandoc  IN tbdsct_lancamento_bordero.cdbandoc%TYPE DEFAULT 0 --> Codigo do banco impresso no boleto
                                       ,pr_nrdctabb  IN tbdsct_lancamento_bordero.nrdctabb%TYPE DEFAULT 0 --> Numero da conta base do titulo
                                       ,pr_nrcnvcob  IN tbdsct_lancamento_bordero.nrcnvcob%TYPE DEFAULT 0 --> Numero do convenio de cobranca
                                       ,pr_nrdocmto  IN tbdsct_lancamento_bordero.nrdocmto%TYPE DEFAULT 0 --> Numero do documento
                                       ,pr_nrtitulo  IN tbdsct_lancamento_bordero.nrtitulo%TYPE DEFAULT 0 --> Numero do titulo do lancamento
                                       ,pr_dscritic OUT VARCHAR2                                          --> Descri��o da cr�tica
                                        );
                                        
 PROCEDURE pc_calcula_liquidez(pr_cdcooper     IN craptdb.cdcooper%TYPE
                            ,pr_nrdconta     IN craptdb.nrdconta%TYPE
                            ,pr_nrinssac     IN crapcob.nrinssac%TYPE DEFAULT NULL 
                            ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE 
                            ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                            ,pr_qtcarpag     IN NUMBER
                            -- OUT --
                            ,pr_pc_cedpag    OUT NUMBER
                            ,pr_qtd_cedpag   OUT NUMBER
                            ,pr_pc_conc      OUT NUMBER
                            ,pr_qtd_conc     OUT NUMBER
                            ,pr_pc_geral     OUT NUMBER
                            ,pr_qtd_geral    OUT NUMBER
                            );
                            
 PROCEDURE pc_calcula_juros_simples_tit(pr_cdcooper  IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                                        ,pr_nrdconta  IN crapass.nrdconta%TYPE --> N�mero da Conta
                                        ,pr_nrborder  IN crapbdt.nrborder%TYPE --> numero do bordero
                                        ,pr_cdbandoc  IN craptdb.cdbandoc%TYPE --> Codigo do banco impresso no boleto
                                        ,pr_nrdctabb  IN craptdb.nrdctabb%TYPE --> Numero da conta base do titulo
                                        ,pr_nrcnvcob  IN craptdb.nrcnvcob%TYPE --> Numero do convenio de cobranca
                                        ,pr_nrdocmto  IN craptdb.nrdocmto%TYPE --> Numero do documento
                                        ,pr_vltitulo  IN craptdb.vltitulo%TYPE --> Valor do titulo
                                        ,pr_dtvencto  IN craptdb.dtvencto%TYPE --> Data vencimento titulo
                                        ,pr_dtmvtolt  IN craplcm.dtmvtolt%TYPE --> Data do movimento atual
                                        ,pr_txmensal  IN crapbdt.txmensal%TYPE --> Taxa mensal
                                        ,pr_vldjuros OUT crapljt.vldjuros%TYPE --> Valor do juros calculado
                                        ,pr_dtrefere OUT DATE                  --> Data de referencia da atualizacao dos juros
                                        ,pr_dscritic OUT VARCHAR2              --> Descri��o da critica
                                        );

 PROCEDURE pc_calcula_atraso_tit(pr_cdcooper    IN crapcop.cdcooper%TYPE      --Codigo Cooperativa
                                ,pr_nrdconta    IN craptdb.nrdconta%TYPE      --N�mero da conta do cooperado
                                ,pr_nrborder    IN craptdb.nrborder%TYPE      --N�mero do border�
                                ,pr_cdbandoc    IN craptdb.cdbandoc%TYPE      --Codigo do banco impresso no boleto
                                ,pr_nrdctabb    IN craptdb.nrdctabb%TYPE      --Numero da conta base do titulo
                                ,pr_nrcnvcob    IN craptdb.nrcnvcob%TYPE      --Numero do convenio de cobranca
                                ,pr_nrdocmto    IN craptdb.nrdocmto%TYPE      --Numero do documento
                                ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE      --Data Movimento
                                ,pr_vlmtatit    OUT NUMBER                    --Valor da multa por atraso
                                ,pr_vlmratit    OUT NUMBER                    --Valor dos juros de mora
                                ,pr_vlioftit    OUT NUMBER                    --Valor do IOF complementar por atraso
                                ,pr_cdcritic    OUT INTEGER                   --Codigo Critica
                                ,pr_dscritic    OUT VARCHAR2);                --Descricao Critica

 PROCEDURE pc_pagar_titulo( pr_cdcooper    IN crapcop.cdcooper%TYPE           --Codigo Cooperativa
                            ,pr_cdagenci    IN INTEGER                         --Codigo Agencia
                            ,pr_nrdcaixa    IN INTEGER                         --Numero Caixa
                            ,pr_idorigem    IN INTEGER                         --Origem sistema
                            ,pr_cdoperad    IN VARCHAR2                        --Codigo operador
                            ,pr_nrdconta    IN craptdb.nrdconta%TYPE           --N�mero da conta do cooperado
                            ,pr_nrborder    IN craptdb.nrborder%TYPE           --N�mero do border�
                            ,pr_cdbandoc    IN craptdb.cdbandoc%TYPE           --Codigo do banco impresso no boleto
                            ,pr_nrdctabb    IN craptdb.nrdctabb%TYPE           --Numero da conta base do titulo
                            ,pr_nrcnvcob    IN craptdb.nrcnvcob%TYPE           --Numero do convenio de cobranca
                            ,pr_nrdocmto    IN craptdb.nrdocmto%TYPE           --Numero do documento
                            ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE           --Data Movimento
                            ,pr_inproces    IN crapdat.inproces%TYPE DEFAULT 1 --Indicador do processo
                            ,pr_cdorigpg    IN NUMBER                DEFAULT 0 --C�digo da origem do processo de pagamento
                            ,pr_indpagto    IN crapcob.indpagto%TYPE DEFAULT 0 --Indica de onde vem o pagamento
                            ,pr_flpgtava    IN NUMBER                DEFAULT 0 --Pagamento efetuado pelo avalista 0-N�o 1-Sim
                            ,pr_vlpagmto    IN OUT NUMBER                      --Valor do pagamento
                            ,pr_cdcritic    OUT INTEGER                        --Codigo Critica
                            ,pr_dscritic    OUT VARCHAR2) ;                   --Descricao Critica
                           
  PROCEDURE pc_efetua_lanc_cc (pr_dtmvtolt  IN craplcm.dtmvtolt%TYPE -- Origem: do lote de libera��o (craplot)
                              ,pr_cdagenci  IN craplcm.cdagenci%TYPE -- Origem: do lote de libera��o (craplot)
                              ,pr_cdbccxlt  IN craplcm.cdbccxlt%TYPE -- Origem: do lote de libera��o (craplot)
                              ,pr_nrdconta  IN craplcm.nrdconta%TYPE -- Origem: nrdconta do Bordero
                              ,pr_vllanmto  IN craplcm.vllanmto%TYPE -- Origem: do c�lculo :aux_vlborder + craptdb.vlliquid da linha 1870.
                              ,pr_cdhistor  IN craphis.cdhistor%TYPE
                              ,pr_cdcooper  IN craplcm.cdcooper%TYPE
                              ,pr_cdoperad  IN crapbdt.cdoperad%TYPE --> Operador
                              ,pr_nrborder  IN crapbdt.nrborder%TYPE -- Origem: Bordero
                              ,pr_cdpactra  IN crapope.cdpactra%TYPE
                              ,pr_nrdocmto  IN craptdb.nrdocmto%TYPE
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> codigo critica
                              ,pr_dscritic OUT VARCHAR2              --> Descricao Critica
                              );                        
   PROCEDURE pc_grava_restricoes_liberacao (pr_cdcooper IN crapbdt.cdcooper%TYPE --> Cooperativa
                                           ,pr_nrdconta IN crapass.nrdconta%TYPE --> N�mero da Conta
                                           ,pr_nrborder IN crapbdt.nrborder%TYPE --> numero do bordero
                                           ,pr_cdoperad IN crapcob.cdoperad%TYPE --> Operador que solicitou a consulta
                                            --------> OUT <--------
                                           ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                           ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                           );                                     

  PROCEDURE pc_processa_liquidacao_cobtit(pr_cdcooper  IN crapcop.cdcooper%TYPE --> C�digo da Cooperativa
                                         ,pr_nrdconta  IN crapass.nrdconta%TYPE --> N�mero da Conta
                                         ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE
                                         ,pr_nrctasac  IN crapcob.nrctasac%TYPE
                                         ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE
                                         ,pr_vlpagmto  IN NUMBER                --> Valor do pagamento
                                         ,pr_indpagto  IN crapcob.indpagto%TYPE --> Indicador pagamento
                                         ,pr_cdoperad  IN crapope.cdoperad%type --> C�digo do Operador
                                         ,pr_cdagenci  IN crapass.cdagenci%type --> Codigo da agencia
                                         ,pr_nrdcaixa  IN craperr.nrdcaixa%type --> Numero Caixa
                                         ,pr_idorigem  IN integer               --> Identificador Origem Chamada
                                         ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                         ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                         );
                                         
  PROCEDURE pc_calcula_restricao_titulo(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa conectada
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE   --> Conta do associado
                                        ,pr_nrdocmto IN crapcob.nrdocmto%TYPE   --> Numero do documento(Boleto)
                                        ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE   --> Numero do convenio de cobranca.
                                        ,pr_nrdctabb IN crapcob.nrdctabb%TYPE   --> Numero da conta base no banco.
                                        ,pr_cdbandoc IN crapcob.cdbandoc%TYPE   --> Codigo do banco/caixa.
                                        ,pr_tab_criticas  IN OUT typ_tab_critica
                                        ,pr_cdcritic    OUT INTEGER                 --> Codigo Critica
                                        ,pr_dscritic    OUT VARCHAR2                --> Descricao Critica
                                      );
                                      
  PROCEDURE pc_calcula_restricao_bordero(pr_cdcooper    IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                                      ,pr_nrdconta      IN craptdb.nrdconta%TYPE DEFAULT NULL --> N�mero da Conta
                                      ,pr_tot_titulos   IN  NUMBER                            --> Quantidade de t�tulos do border�
                                      ,pr_tab_criticas  IN OUT typ_tab_critica
                                      ,pr_cdcritic    OUT INTEGER                 --> Codigo Critica
                                      ,pr_dscritic    OUT VARCHAR2                --> Descricao Critica
                                      );
  
  PROCEDURE pc_calcula_restricao_cedente(pr_cdcooper    IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                                      ,pr_nrdconta      IN craptdb.nrdconta%TYPE DEFAULT NULL --> N�mero da Conta
                                      ,pr_cdagenci IN crawlim.cdagenci%TYPE --> C�digo da Ag�ncia
                                      ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE
                                      ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                                      ,pr_nmdatela IN VARCHAR2      --> Nome da tela
                                      ,pr_idorigem IN INTEGER  --> Identificador Origem pagamento
                                      ,pr_idseqttl IN INTEGER       --> idseqttl
                                      ,pr_tab_criticas IN OUT typ_tab_critica
                                      ,pr_cdcritic    OUT INTEGER                 --> Codigo Critica
                                      ,pr_dscritic    OUT VARCHAR2                --> Descricao Critica
                                      );
                                      
  PROCEDURE pc_calcula_restricao_pagador(pr_cdcooper    IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                                      ,pr_nrdconta      IN craptdb.nrdconta%TYPE --> N�mero da Conta
                                      ,pr_nrinssac      IN craptdb.nrinssac%TYPE --> Pagador
                                      ,pr_nrdocmto      IN crapcob.nrdocmto%TYPE   --> Numero do documento(Boleto)
                                      ,pr_nrcnvcob      IN crapcob.nrcnvcob%TYPE   --> Numero do convenio de cobranca.
                                      ,pr_nrdctabb      IN crapcob.nrdctabb%TYPE   --> Numero da conta base no banco.
                                      ,pr_cdbandoc      IN crapcob.cdbandoc%TYPE   --> Codigo do banco/caixa.
                                      ,pr_tab_criticas  IN OUT typ_tab_critica
                                      ,pr_cdcritic    OUT INTEGER                 --> Codigo Critica
                                      ,pr_dscritic    OUT VARCHAR2                --> Descricao Critica
                                      );
END  DSCT0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.DSCT0003 AS

  /*---------------------------------------------------------------------------------------------------------------

    Programa :  DSCT0003
    Sistema  : Procedimentos envolvendo libera��o de border�s
    Sigla    : CRED
    Autor    : Andr� �vila - GFT
    Data     : Abril/2018.                   Ultima atualizacao: 10/04/2018

   Dados referentes ao programa:

   Frequencia: -----
   Objetivo  : Procedimentos envolvendo libera��o de border�s

   Alteracoes: 10/04/2018 - Desconto de T�tulos KE00726701-185 Border� - Liberar KE00726701-476 (Andr� �vila - GFT)

               26/04/2018 - Andrew Albuquerque (GFT) - Adicionar Chamada a Mesa de Checagem e a Esteira de Cr�dito IBRATAN:
                            Altera��o nas procedures: pc_altera_status_bordero (gravar opcionalmente campos de status de 
                            an�lise e mesa de checagem / pc_restricoes_tit_bordero (valida��es impeditivas movidas para a
                            pc_efetua_analise_bordero) / pc_efetua_analise_bordero: adicionado parametro para dizer se 
                            realiza analise completa ou apenas a impeditiva; alterada valida��o p�s restri��es, para executar
                            apenas quando chamado por an�lise e para enviar para mesa de checagem ou esteira; Valida��o de
                            conting�ncia movida para verificar antes de enviar dados para a mesa do ibratan.
                            
               07/05/2018 - Criadas procedures para fazer a checagem se a cooperativa est� utilizando a vers�o nova ou 
                            a antiga do border� - Luis Fernando (GFT)
               
               14/05/2018 - Criacao da procedure para trazer os titulos vencidos                              - Vitor Shimada Assanuma (GFT)
               16/05/2018 - Criacao das procedures de trazer o saldo e efetuar pagamento dos titulos vencidos - Vitor Shimada Assanuma (GFT)
  ---------------------------------------------------------------------------------------------------------------*/
  -- Cursor gen�rico de calend�rio
  rw_crapdat btch0001.cr_crapdat%rowtype;
  
  -- Vari�veis para armazenar as informa��es em XML
  vr_des_xml         clob;
  vr_texto_completo  varchar2(32600);

  -- Busca dos dados do associado
  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT 0
                   ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE DEFAULT 0) IS
   SELECT crapass.cdcooper
         ,crapass.nrdconta
         ,crapass.inpessoa
         ,crapass.vllimcre
         ,crapass.nmprimtl
         ,crapass.nrcpfcgc
         ,crapass.dtdemiss
         ,crapass.inadimpl
     FROM crapass
    WHERE crapass.cdcooper = pr_cdcooper
      AND crapass.nrdconta = DECODE(pr_nrdconta,0,crapass.nrdconta,pr_nrdconta)
      AND crapass.nrcpfcgc = DECODE(pr_nrcpfcgc,0,crapass.nrcpfcgc,pr_nrcpfcgc);
  rw_crapass cr_crapass%ROWTYPE;


  -- Cursor sobre a tabela de limite de credito
  CURSOR cr_craplim (pr_cdcooper IN craplim.cdcooper%TYPE,
                     pr_nrdconta IN craplim.nrdconta%TYPE) IS
    SELECT craplim.cdcooper
          ,craplim.nrdconta
          ,craplim.cddlinha
          ,craplim.dtfimvig
          ,craplim.dtinivig
          ,craplim.qtdiavig
          ,craplim.vllimite
          ,craplim.qtrenova
          ,craplim.dtrenova
          ,craplim.nrctrlim
      FROM craplim
     WHERE craplim.cdcooper = pr_cdcooper
       AND craplim.nrdconta = pr_nrdconta
       AND craplim.tpctrlim = 3
       AND craplim.insitlim = 2;  /* ATIVO */
  rw_craplim cr_craplim%ROWTYPE;

  --Buscar informacoes de lote
  CURSOR cr_craplot (pr_cdcooper IN craplot.cdcooper%TYPE
                    ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                    ,pr_cdagenci IN craplot.cdagenci%TYPE
                    ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                    ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
    SELECT  craplot.nrdolote
           ,craplot.nrseqdig
           ,craplot.cdbccxlt
           ,craplot.dtmvtolt
           ,craplot.cdagenci
           ,craplot.rowid
    FROM craplot craplot
    WHERE craplot.cdcooper = pr_cdcooper
    AND   craplot.dtmvtolt = pr_dtmvtolt
    AND   craplot.cdagenci = pr_cdagenci
    AND   craplot.cdbccxlt = pr_cdbccxlt
    AND   craplot.nrdolote = pr_nrdolote;
  rw_craplot cr_craplot%ROWTYPE;

  --> verificar se existem criticas ou um critica em espec�fico (pelo nrseqdig) para t�tulos daquele border�.
  CURSOR cr_crapabt_qtde (pr_cdcooper IN crapabt.cdcooper%TYPE
                         ,pr_nrdconta IN crapabt.nrdconta%TYPE
                         ,pr_nrborder IN crapabt.nrborder%TYPE
                         ,pr_nrseqdig IN crapabt.nrseqdig%TYPE DEFAULT -1) IS
    select abt.cdcooper
          ,abt.nrdconta
          ,abt.nrborder
          ,count(dsrestri) as qtdrestri
      from crapabt abt --cr�ticas do border�
     where abt.cdcooper = pr_cdcooper
       and abt.nrdconta = pr_nrdconta
       and abt.nrborder = pr_nrborder
       and abt.nrseqdig = decode(pr_nrseqdig,-1,abt.nrseqdig,pr_nrseqdig)
    group by abt.cdcooper
            ,abt.nrdconta
            ,abt.nrborder;
  rw_crapabt_qtde cr_crapabt_qtde%ROWTYPE;
      
  --> Cursor para registros de T�tulos do Border� com Restri��es ou com outras restri��es que n�o sejam a 9 (CNAE)
  CURSOR cr_craptdb_restri (pr_cdcooper IN crapabt.cdcooper%TYPE
                           ,pr_nrdconta IN crapabt.nrdconta%TYPE
                           ,pr_nrborder IN crapabt.nrborder%TYPE
                           ,pr_nrseqdig IN crapabt.nrseqdig%TYPE DEFAULT -1) IS
    SELECT tdb.nrdconta
          ,tdb.nrborder
          ,tdb.nrdocmto
          ,tdb.insittit
          ,tdb.insitapr
          ,tdb.cdoriapr
          ,tdb.flgenvmc
          ,tdb.insitmch
          ,abt.nrseqdig
          ,abt.dsrestri
          ,tdb.rowid
      FROM craptdb tdb
     INNER JOIN crapabt abt
        ON abt.nrborder = tdb.nrborder
       AND abt.cdcooper = tdb.cdcooper
       AND abt.nrdconta = tdb.nrdconta
       AND abt.nrdocmto = tdb.nrdocmto
     WHERE tdb.cdcooper = pr_cdcooper
       AND tdb.nrdconta = pr_nrdconta
       AND tdb.nrborder = pr_nrborder
       AND (abt.nrseqdig = decode(pr_nrseqdig,-1,abt.nrseqdig,pr_nrseqdig) AND
            abt.nrseqdig <> decode(pr_nrseqdig,9,-1,9));
    rw_craptdb_restri cr_craptdb_restri%ROWTYPE;
    
    
  FUNCTION fn_contigencia_esteira(pr_cdcooper IN crapcop.cdcooper%TYPE
                                 ) RETURN BOOLEAN IS
    /*---------------------------------------------------------------------------------------------------------------------
      Programa : fn_contigencia_esteira
      Sistema  : Ayllos
      Sigla    : DSCT0003
      Autor    : Paulo Penteado (GFT)
      Data     : Abril/2018

      Objetivo  : Procedure para verificar se a esteira est� em conting�ncia

      Altera��o : 28/04/2018 - Cria��o (Paulo Penteado (GFT))

    ---------------------------------------------------------------------------------------------------------------------*/
     vr_flctgest BOOLEAN;
     vr_dscritic VARCHAR2(10000);
     vr_dsmensag VARCHAR2(10000);
  BEGIN
     este0003.pc_verifica_contigenc_esteira(pr_cdcooper => pr_cdcooper
                                           ,pr_flctgest => vr_flctgest
                                           ,pr_dsmensag => vr_dsmensag
                                           ,pr_dscritic => vr_dscritic);

     if  vr_flctgest then
         return true;
     else
         return false;
     end if;
  END fn_contigencia_esteira;
  
  FUNCTION fn_ds_critica(pr_cdcritica IN tbdsct_criticas.cdcritica%TYPE
                                 ) RETURN VARCHAR2 IS
    /*---------------------------------------------------------------------------------------------------------------------
      Programa : fn_ds_critica
      Sistema  : Ayllos
      Sigla    : DSCT0003
      Autor    : Luis Fernando (GFT)
      Data     : Julho/2018

      Objetivo  : Funcao que retorna a descricao de uma critica pelo codigo
    ---------------------------------------------------------------------------------------------------------------------*/
  BEGIN
    OPEN cr_tbdsct_criticas(pr_cdcritica=>pr_cdcritica);
    FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
    IF (cr_tbdsct_criticas%FOUND) THEN
      RETURN rw_tbdsct_criticas.dscritica;
    END IF;
    RETURN '';
  END fn_ds_critica;
    
  FUNCTION fn_virada_bordero (pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN INTEGER IS
    /* .............................................................................
      Programa: fn_virada_bordero
      Sistema : AyllosWeb
      Sigla   : CRED
      Autor   : Luis Fernando (GFT)
      Data    : 07/05/2018                        Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Retorna se a cooperativa esta utilizando o sistema novo de bordero
                                                   
    ............................................................................. */
    CURSOR cr_crapprm IS
      SELECT
        crapprm.dsvlrprm
      FROM 
        crapprm
      WHERE
        crapprm.cdcooper = pr_cdcooper
        AND crapprm.cdacesso = 'FL_VIRADA_BORDERO'
    ;
    rw_crapprm cr_crapprm%ROWTYPE;

  BEGIN
    OPEN cr_crapprm;
    FETCH cr_crapprm INTO rw_crapprm;
    IF cr_crapprm%NOTFOUND THEN
      RETURN 0;
    END IF;
    RETURN rw_crapprm.dsvlrprm;
  END fn_virada_bordero;
  
  FUNCTION fn_busca_situacao_bordero (pr_insitbdt crapbdt.insitbdt%TYPE) RETURN VARCHAR2 IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : fn_busca_situacao_bordero
    Sistema  : CRED
    Sigla    : DSCT0003
    Autor    : Luis Fernando (GFT)
    Data     : Abril/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Fun��o que retorna a descri��o dos status do border�.
  ---------------------------------------------------------------------------------------------------------------------*/
   BEGIN
     RETURN (
       CASE
         WHEN pr_insitbdt=1 THEN 'Em Estudo'
         WHEN pr_insitbdt=2 THEN 'Analisado'
         WHEN pr_insitbdt=3 THEN 'Liberado'
         WHEN pr_insitbdt=4 THEN 'Liquidado'
         WHEN pr_insitbdt=5 THEN 'Rejeitado'
       END
     );
  END fn_busca_situacao_bordero;

  FUNCTION fn_busca_decisao_bordero (pr_insitapr crapbdt.insitapr%TYPE) RETURN VARCHAR2 IS
    /*---------------------------------------------------------------------------------------------------------------------
      Programa : fn_busca_decisao_bordero
      Sistema  : CRED
      Sigla    : DSCT0003
      Autor    : Luis Fernando (GFT)
      Data     : Abril/2018
      Frequencia: Sempre que for chamado
      Objetivo  : Fun��o que retorna a descri��o das decisoes do border�.
    ---------------------------------------------------------------------------------------------------------------------*/
     BEGIN
       RETURN (
         CASE
           WHEN pr_insitapr=0 THEN 'Aguardando An�lise'
           WHEN pr_insitapr=1 THEN 'Aguardando Checagem'
           WHEN pr_insitapr=2 THEN 'Checagem'
           WHEN pr_insitapr=3 THEN 'Aprovado Automaticamente'
           WHEN pr_insitapr=4 THEN 'Aprovado'
           WHEN pr_insitapr=5 THEN 'N�o aprovado'
           WHEN pr_insitapr=6 THEN 'Enviado Esteira'
           WHEN pr_insitapr=7 THEN 'Prazo expirado'
         END
       );

   END fn_busca_decisao_bordero;
   
  FUNCTION fn_calcula_cnae(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa conectada
                          ,pr_nrdconta IN crapass.nrdconta%TYPE   --> Conta do associado
                          ,pr_nrdocmto IN crapcob.nrdocmto%TYPE   --> Numero do documento(Boleto)
                          ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE   --> Numero do convenio de cobranca.
                          ,pr_nrdctabb IN crapcob.nrdctabb%TYPE   --> Numero da conta base no banco.
                          ,pr_cdbandoc IN crapcob.cdbandoc%TYPE   --> Codigo do banco/caixa.
           )RETURN BOOLEAN IS           --> Retonar True ou False se tem ou nao restri��o CNAE
    /* .............................................................................
      Programa: fn_calcula_cnae
      Sistema : AyllosWeb
      Sigla   : CRED
      Autor   : Vitor Shimada Assanuma (GFT)
      Data    : 03/05/2018                        Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Calculo de verifica��o do CNAE por titulo
      Altera��es: 24/05/2018 - Vitor Shimada Assanuma (GFT) - Inclus�o da verifica��o da #TAB052 se o CNAE est� ativo

    ............................................................................. */
     -- Vari�vel de cr�ticas
     vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
     vr_dscritic varchar2(1000);        --> Desc. Erro
        
     -- Cursor do titulo
     CURSOR cr_crapcob IS
          SELECT cob.vltitulo
          FROM crapcob cob
          WHERE
            cob.flgregis > 0
            AND cob.incobran = 0
            AND cob.nrdconta = pr_nrdconta
            AND cob.cdcooper = pr_cdcooper
            AND cob.nrcnvcob = pr_nrcnvcob
            AND cob.cdbandoc = pr_cdbandoc
            AND cob.nrdctabb = pr_nrdctabb
            AND cob.nrdocmto = pr_nrdocmto
     ;rw_crapcob cr_crapcob%rowtype;

     -- Cursor para retornar o valor do CNAE
     CURSOR cr_crapass IS
            SELECT vlmaximo, inpessoa
            FROM crapass ass
            INNER JOIN
                  tbdsct_cdnae cnae
                  ON cnae.cdcooper = ass.cdcooper
                  AND cnae.cdcnae = ass.cdclcnae
            WHERE
                  cnae.vlmaximo > 0
                  AND ass.cdcooper = pr_cdcooper
                  AND ass.nrdconta = pr_nrdconta
     ;rw_crapass cr_crapass%rowtype;

     --Tab052
     pr_tab_dados_dsctit cecred.dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052
     pr_tab_cecred_dsctit cecred.dsct0002.typ_tab_cecred_dsctit; -- retorno da TAB052
       
     BEGIN
       --    Leitura do calend�rio da cooperativa
       OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH btch0001.cr_crapdat into rw_crapdat;
       CLOSE btch0001.cr_crapdat;
       
       --Abertura do CNAE
       OPEN cr_crapass;
       FETCH cr_crapass INTO rw_crapass;
         
       --Abertura do titulo
       OPEN cr_crapcob;
       FETCH cr_crapcob INTO rw_crapcob;
       
       --Caso nao consiga abrir um dos dois retorna FALSE
       IF cr_crapcob%NOTFOUND OR cr_crapass%NOTFOUND THEN
         CLOSE cr_crapass;
         CLOSE cr_crapcob;
         RETURN FALSE;
       END IF;
           
       -- Carregando #TAB052
       dsct0002.pc_busca_parametros_dsctit(pr_cdcooper, --pr_cdcooper,
                                         null, --Agencia de opera��o
                                         null, --N�mero do caixa
                                         null, --Operador
                                         rw_crapdat.dtmvtolt, -- Data da Movimenta��o
                                         null, --Identifica��o de origem
                                         1, --pr_tpcobran: 1-REGISTRADA / 0-N�O REGISTRADA
                                         rw_crapass.inpessoa, --1-PESSOA F�SICA / 2-PESSOA JUR�DICA
                                         pr_tab_dados_dsctit,
                                         pr_tab_cecred_dsctit,
                                         vr_cdcritic,
                                         vr_dscritic);  
                                         
       --Caso o valor do titulo seja maior que o valor maximo do CNAE retorna TRUE e Esteja ativo a op��o de verificar CNAE
       IF ((rw_crapcob.vltitulo > rw_crapass.vlmaximo) AND (pr_tab_dados_dsctit(1).vlmxprat > 0) )THEN
         RETURN TRUE;
       END IF;

       --Retorna FALSE no caso de passar reto
       RETURN FALSE;
  END fn_calcula_cnae;
  

  
  FUNCTION fn_calcula_liquidez_geral (pr_nrdconta     in crapass.nrdconta%TYPE
                                     ,pr_cdcooper     IN crapcop.cdcooper%TYPE
                                     ,pr_dtmvtolt_de  in crapdat.dtmvtolt%type
                                     ,pr_dtmvtolt_ate in crapdat.dtmvtolt%TYPE
                                     ,pr_qtcarpag     in NUMBER
          ) RETURN NUMBER IS
   /*---------------------------------------------------------------------------------------------------------------------
     Programa : fn_calcula_liquidez_geral
     Sistema  : 
     Sigla    : CRED
     Autor    : Vitor Shimada Assanuma (GFT)
     Data     : Maio/2018
     Frequencia: Sempre que for chamado
     Objetivo  : C�lculo da Liquidez Geral
   ---------------------------------------------------------------------------------------------------------------------*/
   /* Calculo da Liquidez:
    Soma do Valor de todos os titulos nao pagos dividido pela soma de todos os titulos daquele emitente (nrdconta)
           dentro de um periodo de tempo da liquidez (Dt.Mov - Dias de Liquidez ATE Dt.Mov) levando em conta os dias de
           carencia na data de vencimento.
    (N�o considerar como t�tulo pago, os liquidados em conta corrente do cedente, ou seja, pagos pelo pr�prio emitente) */
   -- Variaveis de retorno 
   pr_pc_cedpag    NUMBER(25,2);
   pr_qtd_cedpag   NUMBER;
   pr_pc_conc      NUMBER(25,2);
   pr_qtd_conc     NUMBER;
   pr_pc_geral     NUMBER(25,2);
   pr_qtd_geral    NUMBER;
   
   BEGIN       
     pc_calcula_liquidez(pr_cdcooper            
                     ,pr_nrdconta     
                     ,NULL     
                     ,pr_dtmvtolt_de  
                     ,pr_dtmvtolt_ate 
                     ,pr_qtcarpag     
                    -- OUT --
                    ,pr_pc_cedpag    => pr_pc_cedpag
                    ,pr_qtd_cedpag   => pr_qtd_cedpag
                    ,pr_pc_conc      => pr_pc_conc
                    ,pr_qtd_conc     => pr_qtd_conc
                    ,pr_pc_geral     => pr_pc_geral
                    ,pr_qtd_geral    => pr_qtd_geral
                    );
     RETURN pr_pc_geral;
  END fn_calcula_liquidez_geral;
 
  FUNCTION fn_concentracao_titulo_pagador (pr_cdcooper     IN craptdb.cdcooper%TYPE
                                          ,pr_nrdconta     IN craptdb.nrdconta%TYPE
                                          ,pr_nrinssac     IN crapcob.nrinssac%TYPE
                                          ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE 
                                          ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                                          ,pr_qtcarpag     IN NUMBER
                                       ) RETURN NUMBER IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : fn_concentracao_titulo_pagador
    Sistema  : CRED
    Sigla    : CRED
    Autor    : Vitor Shimada Assanuma (GFT)
    Data     : Maio/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Fun��o que retorna a porcentagem de concentracao de titulos daquele pagador em um range de data de liquidez
  ---------------------------------------------------------------------------------------------------------------------*/
   -- Variaveis de retorno 
   pr_pc_cedpag    NUMBER(25,2);
   pr_qtd_cedpag   NUMBER;
   pr_pc_conc      NUMBER(25,2);
   pr_qtd_conc     NUMBER;
   pr_pc_geral     NUMBER(25,2);
   pr_qtd_geral    NUMBER;
   
   BEGIN       
     pc_calcula_liquidez(pr_cdcooper            
                     ,pr_nrdconta     
                     ,pr_nrinssac     
                     ,pr_dtmvtolt_de  
                     ,pr_dtmvtolt_ate 
                     ,pr_qtcarpag     
                    -- OUT --
                    ,pr_pc_cedpag    => pr_pc_cedpag
                    ,pr_qtd_cedpag   => pr_qtd_cedpag
                    ,pr_pc_conc      => pr_pc_conc
                    ,pr_qtd_conc     => pr_qtd_conc
                    ,pr_pc_geral     => pr_pc_geral
                    ,pr_qtd_geral    => pr_qtd_geral
                    );
     RETURN pr_pc_conc;      
   END fn_concentracao_titulo_pagador;
   
   
   FUNCTION fn_liquidez_pagador_cedente (pr_cdcooper     IN craptdb.cdcooper%TYPE
                                        ,pr_nrdconta     IN craptdb.nrdconta%TYPE
                                        ,pr_nrinssac     IN crapcob.nrinssac%TYPE
                                        ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE 
                                        ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                                        ,pr_qtcarpag     IN NUMBER
                                        ) RETURN NUMBER IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : fn_liquidez_pagador_cedente
    Sistema  : CRED
    Sigla    : CRED
    Autor    : Vitor Shimada Assanuma (GFT)
    Data     : Maio/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Fun��o que retorna a porcentagem de liquidez do pagador contra o cedente no range de data
  ---------------------------------------------------------------------------------------------------------------------*/ 
   /* C�LCULO DA CONCENTRACAO DO PAGADOR
    Soma do Valor de todos os titulos nao pagos dividido pela soma de todos os titulos daquele emitente (nrdconta)
       CONTRA aquele pagador (nrinssac) dentro de um periodo de tempo da liquidez (Dt.Mov - Dias de Liquidez ATE Dt.Mov) 
       levando em conta os dias de carencia na data de vencimento.
    (N�o considerar como t�tulo pago, os liquidados em conta corrente do cedente, ou seja, pagos pelo pr�prio emitente) */
    -- Variaveis de retorno 
   pr_pc_cedpag    NUMBER(25,2);
   pr_qtd_cedpag   NUMBER;
   pr_pc_conc      NUMBER(25,2);
   pr_qtd_conc     NUMBER;
   pr_pc_geral     NUMBER(25,2);
   pr_qtd_geral    NUMBER;
   
   BEGIN       
     pc_calcula_liquidez(pr_cdcooper            
                     ,pr_nrdconta     
                     ,pr_nrinssac     
                     ,pr_dtmvtolt_de  
                     ,pr_dtmvtolt_ate 
                     ,pr_qtcarpag     
                    -- OUT --
                    ,pr_pc_cedpag    => pr_pc_cedpag
                    ,pr_qtd_cedpag   => pr_qtd_cedpag
                    ,pr_pc_conc      => pr_pc_conc
                    ,pr_qtd_conc     => pr_qtd_conc
                    ,pr_pc_geral     => pr_pc_geral
                    ,pr_qtd_geral    => pr_qtd_geral
                    );
     RETURN pr_pc_cedpag;
   END fn_liquidez_pagador_cedente;

  FUNCTION fn_cobranca_cobtit(pr_cdcooper IN crapbdt.cdcooper%TYPE --> C�digo da Cooperativa
                             ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                             ) RETURN BOOLEAN IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : fn_cobranca_cobtit
      Sistema  : Ayllos
      Sigla    : DSTC
      Autor    : Paulo Penteado (GFT)
      Data     : Junho/2018
  
      Objetivo  : Retornar se a cobran�a foi realizada pela COBTIT. Para isso compara se o n�mero do conv�nio do 
                  t�tulo � igual ao n�mero do convenio registrado no par�metro.
  
      Altera��o : 10/06/2018 - Cria��o (Paulo Penteado (GFT))
  
    ----------------------------------------------------------------------------------------------------------*/
    vr_nrcnvcob crapcob.nrcnvcob%TYPE;
  BEGIN
    vr_nrcnvcob := gene0001.fn_param_sistema(pr_cdcooper => pr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_cdacesso => 'COBTIT_NRCONVEN');
    RETURN (pr_nrcnvcob = vr_nrcnvcob);
  END fn_cobranca_cobtit;
  
  -- Rotina para escrever texto na vari�vel CLOB do XML
  PROCEDURE pc_escreve_xml( pr_des_dados in varchar2
                          , pr_fecha_xml in boolean default false
                          ) is
  BEGIN
     gene0002.pc_escreve_xml( vr_des_xml
                            , vr_texto_completo
                            , pr_des_dados
                            , pr_fecha_xml );
  END pc_escreve_xml;

  
  /*Procedure que altera os status de um border�*/
  PROCEDURE pc_altera_status_bordero(pr_cdcooper IN crapbdt.cdcooper%TYPE --> C�digo da Cooperativa
                                    ,pr_nrborder IN crapbdt.nrborder%TYPE --> N�mero do Border�
                                    ,pr_nrdconta IN crapbdt.nrdconta%TYPE --> N�mero da conta do cooperado
                                    ,pr_status   IN crapbdt.insitbdt%TYPE DEFAULT -1 --> Situa��o nova do border�
                                    ,pr_insitapr IN crapbdt.insitapr%TYPE DEFAULT -1   -- Situa��o da aprova��o
                                    ,pr_cdopeapr IN crapbdt.cdopeapr%TYPE DEFAULT NULL -- cdoperad que efetuou a aprova��o
                                    ,pr_dtaprova IN crapbdt.dtaprova%TYPE DEFAULT NULL -- data de aprova��o
                                    ,pr_hraprova IN crapbdt.hraprova%TYPE DEFAULT NULL -- hora de aprova��o
                                    ,pr_dtenvmch IN crapbdt.dtaprova%TYPE DEFAULT NULL -- data de envio para mesa de checagem
                                    ,pr_cdoperej IN crapbdt.cdoperej%TYPE DEFAULT NULL -- cdoperad que efetuou a rejei��o
                                    ,pr_dtrejeit IN crapbdt.dtrejeit%TYPE DEFAULT NULL -- data de rejei��o
                                    ,pr_hrrejeit IN crapbdt.hrrejeit%TYPE DEFAULT NULL -- hora de rejei�o
                                    ,pr_dtanabor IN crapbdt.dtanabor%TYPE DEFAULT NULL -- data de analise
                                    ,pr_dscritic OUT PLS_INTEGER          --> Descricao Critica
                                    ) IS
  BEGIN
    BEGIN
      UPDATE crapbdt
         SET crapbdt.insitbdt = decode(pr_status,-1,crapbdt.insitbdt,pr_status)
            ,crapbdt.insitapr = decode(pr_insitapr,-1,crapbdt.insitapr,pr_insitapr)
            ,crapbdt.cdopeapr = nvl(pr_cdopeapr,crapbdt.cdopeapr)
            ,crapbdt.dtaprova = nvl(pr_dtaprova,crapbdt.dtaprova)
            ,crapbdt.hraprova = nvl(pr_hraprova,crapbdt.hraprova)
            ,crapbdt.dtenvmch = nvl(pr_dtenvmch,crapbdt.dtenvmch)
            ,crapbdt.cdoperej = nvl(pr_cdoperej,crapbdt.cdoperej)
            ,crapbdt.dtrejeit = nvl(pr_dtrejeit,crapbdt.dtrejeit)
            ,crapbdt.hrrejeit = nvl(pr_hrrejeit,crapbdt.hrrejeit)
            ,crapbdt.dtanabor = nvl(pr_dtanabor,crapbdt.dtanabor)
       WHERE crapbdt.cdcooper = pr_cdcooper
         AND crapbdt.nrborder = pr_nrborder
         AND crapbdt.nrdconta = pr_nrdconta;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao alterar o registro na crapbdt: '|| sqlerrm;
    END;
  END pc_altera_status_bordero;


PROCEDURE pc_atualizar_bordero_dsct_tit(pr_cdcooper  IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE --> N�mero da Conta
                                       ,pr_nrborder  IN crapbdt.nrborder%TYPE --> numero do bordero
                                       ,pr_dtmvtolt  IN craplcm.dtmvtolt%TYPE --> Data do movimento atual
                                       ,pr_cdoperad  IN craptdb.cdoperad%TYPE --> Operador         
                                       ,pr_cdagenci  IN crapass.cdagenci%TYPE --> C�digo da Ag�ncia
                                       ,pr_vltaxiof  IN crapbdt.vltaxiof%TYPE DEFAULT NULL --> Valor da taxa de IOF complementar
                                       ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                       ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_atualizar_bordero
    Sistema  : CRED
    Sigla    : DSCT0003
    Autor    : Paulo Penteado (GFT)
    Data     : Maio/2018
    
    Objetivo  : Atualizar informa��es do border�

    Altera��o : 24/05/2018 - Cria��o (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
  vr_vltxmult_prm crapbdt.vltxmult%TYPE;

  -- Vari�vel de cr�ticas
  vr_dscritic VARCHAR2(10000);

  -- Tratamento de erros
  vr_exc_erro EXCEPTION;
  
  CURSOR cr_craplim IS
  SELECT lim.cddlinha
        ,ldc.txjurmor
  FROM   crapldc ldc
        ,craplim lim
        ,crapbdt bdt
  WHERE  ldc.tpdescto = 3
  AND    ldc.cddlinha = lim.cddlinha
  AND    ldc.cdcooper = pr_cdcooper
  AND    lim.insitlim = 2
  AND    lim.tpctrlim = 3
  AND    lim.nrctrlim = bdt.nrctrlim
  AND    lim.cdcooper = pr_cdcooper
  AND    bdt.nrborder = pr_nrborder
  AND    bdt.cdcooper = pr_cdcooper;
  rw_craplim cr_craplim%ROWTYPE;

BEGIN
  OPEN  cr_craplim;
  FETCH cr_craplim INTO rw_craplim;
  CLOSE cr_craplim;

  vr_vltxmult_prm := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_cdacesso => 'PERCENTUAL_MULTA_DSCT');

  -- Altera o status do border� para 'LIBERADO'
  pc_altera_status_bordero(pr_cdcooper => pr_cdcooper
                          ,pr_nrborder => pr_nrborder
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_status   => 3 
                          ,pr_dscritic => vr_dscritic );

  IF  vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
  END IF;
    
  BEGIN
    UPDATE crapbdt bdt
    SET    dtlibbdt = pr_dtmvtolt
          ,cdopelib = pr_cdoperad
          ,cdopeori = pr_cdoperad
          ,cdageori = pr_cdagenci
          ,dtinsori = SYSDATE
          ,vltaxiof = nvl(pr_vltaxiof, vltaxiof)
          ,vltxmult = nvl(vr_vltxmult_prm, vltxmult)
          ,vltxmora = nvl(rw_craplim.txjurmor, vltxmora)
    WHERE  bdt.nrborder = pr_nrborder
    AND    bdt.nrdconta = pr_nrdconta
    AND    bdt.cdcooper = pr_cdcooper;
  EXCEPTION
    WHEN OTHERS THEN
         vr_dscritic := 'Erro ao atualizar as informa��es do border� '||pr_nrborder||': '||SQLERRM;
         RAISE vr_exc_erro;
  END; 
EXCEPTION
  WHEN vr_exc_erro THEN
       pr_dscritic := vr_dscritic;

  WHEN OTHERS THEN
       pr_dscritic := 'Erro geral na rotina dsct0003.pc_atualizar_bordero_dsct_tit: '||SQLERRM;

END pc_atualizar_bordero_dsct_tit;


PROCEDURE pc_inserir_lancamento_bordero(pr_cdcooper  IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE --> N�mero da Conta
                                       ,pr_nrborder  IN crapbdt.nrborder%TYPE --> numero do bordero
                                       ,pr_dtmvtolt  IN craplcm.dtmvtolt%TYPE --> Data do movimento atual
                                       ,pr_cdorigem  IN INTEGER               --> Codigo Origem Lancamento
                                       ,pr_cdhistor  IN craphis.cdhistor%TYPE --> Codigo do historico do lancamento
                                       ,pr_vllanmto  IN tbdsct_lancamento_bordero.vllanmto%TYPE           --> Valor do lancamento
                                       ,pr_cdbandoc  IN tbdsct_lancamento_bordero.cdbandoc%TYPE DEFAULT 0 --> Codigo do banco impresso no boleto
                                       ,pr_nrdctabb  IN tbdsct_lancamento_bordero.nrdctabb%TYPE DEFAULT 0 --> Numero da conta base do titulo
                                       ,pr_nrcnvcob  IN tbdsct_lancamento_bordero.nrcnvcob%TYPE DEFAULT 0 --> Numero do convenio de cobranca
                                       ,pr_nrdocmto  IN tbdsct_lancamento_bordero.nrdocmto%TYPE DEFAULT 0 --> Numero do documento
                                       ,pr_nrtitulo  IN tbdsct_lancamento_bordero.nrtitulo%TYPE DEFAULT 0 --> Numero do titulo do lancamento
                                       ,pr_dscritic OUT VARCHAR2                                          --> Descri��o da cr�tica
                                       ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_inserir_lancamento_bordero
    Sistema  : CRED
    Sigla    : DSCT0003
    Autor    : Paulo Penteado (GFT)
    Data     : Maio/2018
    
    Objetivo  : Inserir registros de lancamento do border� na tabela tbdsct_lancamento_bordero

    Altera��o : 24/05/2018 - Cria��o (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
  vr_nrseqdig tbdsct_lancamento_bordero.nrseqdig%TYPE;

  -- Vari�vel de cr�ticas
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);

  -- Tratamento de erros
  vr_exc_erro EXCEPTION;

BEGIN
  SELECT nvl(MAX(nrseqdig),0)+1 
  INTO   vr_nrseqdig
  FROM   tbdsct_lancamento_bordero 
  WHERE  nrtitulo = pr_nrtitulo
  AND    nrborder = pr_nrborder 
  AND    nrdconta = pr_nrdconta
  AND    cdcooper = pr_cdcooper;
  
  BEGIN
    INSERT INTO tbdsct_lancamento_bordero
           (/*01*/ cdcooper
           ,/*02*/ nrdconta
           ,/*03*/ nrborder
           ,/*04*/ nrtitulo --(0 para lancamento exclusivo de bordero)
           ,/*05*/ nrseqdig
           ,/*06*/ cdbandoc --(0 para lancamento exclusivo de bordero)
           ,/*07*/ nrdctabb --(0 para lancamento exclusivo de bordero)
           ,/*08*/ nrcnvcob --(0 para lancamento exclusivo de bordero)
           ,/*09*/ nrdocmto --(0 para lancamento exclusivo de bordero)
           ,/*10*/ dtmvtolt
           ,/*11*/ cdorigem
           ,/*12*/ cdhistor
           ,/*13*/ vllanmto )
    VALUES (/*01*/ pr_cdcooper
           ,/*02*/ pr_nrdconta
           ,/*03*/ pr_nrborder
           ,/*04*/ pr_nrtitulo                        
           ,/*05*/ vr_nrseqdig
           ,/*06*/ pr_cdbandoc
           ,/*07*/ pr_nrdctabb
           ,/*08*/ pr_nrcnvcob
           ,/*09*/ pr_nrdocmto
           ,/*10*/ pr_dtmvtolt
           ,/*11*/ pr_cdorigem
           ,/*12*/ pr_cdhistor
           ,/*13*/ pr_vllanmto );
  EXCEPTION
    WHEN OTHERS THEN
         vr_dscritic := 'Erro ao inserir o lan�amento de border�: '||SQLERRM;
         RAISE vr_exc_erro;
  END; 
EXCEPTION
  WHEN vr_exc_erro THEN
       IF  vr_cdcritic <> 0 THEN
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       END IF;
       pr_dscritic := vr_dscritic;

  WHEN OTHERS THEN
       pr_dscritic := 'Erro geral na rotina dsct0003.pc_inserir_lancamento_bordero: '||SQLERRM;

END pc_inserir_lancamento_bordero;

  
  PROCEDURE pc_valida_bordero (pr_cdcooper IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                               ,pr_nrborder IN crapbdt.nrborder%TYPE --> N�mero do Bordero
                               ,pr_cddeacao IN VARCHAR2      
                               ,pr_dscritic OUT VARCHAR2             --> Descri�ao da cr�tica
                               ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_valida_bordero
    Sistema  : Cred
    Sigla    :
    Autor    : Lucas Lazari (GFT)
    Data     : Abril/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Procedure que realiza valida��es b�sicas do border� para as rotinas de an�lise e libera��o do border�
  ---------------------------------------------------------------------------------------------------------------------*/

   vr_exc_erro exception;
   vr_dscritic VARCHAR2(10000);
          
   --     Selecionar bordero titulo
   CURSOR cr_crapbdt IS
   SELECT crapbdt.cdcooper
         ,crapbdt.nrborder
         ,crapbdt.nrdconta
         ,crapbdt.insitbdt
         ,crapbdt.insitapr
         ,crapbdt.dtenvmch
         ,crapbdt.dtanabor
   FROM   crapbdt
   WHERE  crapbdt.cdcooper = pr_cdcooper
   AND    crapbdt.nrborder = pr_nrborder;
   rw_crapbdt cr_crapbdt%ROWTYPE;                           

  BEGIN
     OPEN  cr_crapbdt;
     FETCH cr_crapbdt INTO rw_crapbdt;
     IF    cr_crapbdt%NOTFOUND THEN
           CLOSE cr_crapbdt;
           vr_dscritic:= 'Registro de Border� N�o Encontrado.';
           RAISE vr_exc_erro;
     ELSE
           /* Situacao do Border� (insitbdt):
                 1-Em Estudo, 2-Analisado, 3-Liberado, 4-Liquidado, 5-Rejeitado'
              Situa��o da Decis�o/Aprova��o (insitapr):
                 0-Aguardando An�lise, 1-Aguardando Checagem, 2-Checagem, 3-Aprovado Automaticamente, 
                 4-Aprovado, 5-N�o aprovado, 6-Enviado Esteira, 7-Prazo expirado' */
     
           IF    pr_cddeacao = 'LIBERAR'  THEN
                 IF  rw_crapbdt.insitbdt <> 2 OR (rw_crapbdt.insitapr NOT IN (3,4)) THEN
                     -- Caso nao tenha sido feito a analise 
                     IF rw_crapbdt.dtanabor IS NULL THEN
                         vr_dscritic := 'Libera��o n�o permitida. O Border� deve ser analisado antes de liberar.';
                         CLOSE cr_crapbdt;
                         RAISE vr_exc_erro;
                     ELSE
                     --  verifica se a esteira est� em contingencia
                     IF  fn_contigencia_esteira(pr_cdcooper) THEN
                         IF  rw_crapbdt.insitbdt <> 1 OR rw_crapbdt.insitapr <> 0 THEN
                             vr_dscritic := 'Libera��o n�o permitida. O Border� deve estar na situa��o EM ESTUDO e decis�o AGUARDANDO AN�LISE.';
                             CLOSE cr_crapbdt;
                             RAISE vr_exc_erro;
                         END IF;
                     ELSE
                       vr_dscritic := 'Libera��o n�o permitida. O Border� deve estar na situa��o ANALISADO e decis�o APROVADO AUTOMATICAMENTO OU APROVADO.';
                       CLOSE cr_crapbdt;
                       RAISE vr_exc_erro;
                     END IF;
                 END IF;
                 END IF;
                 
           ELSIF pr_cddeacao = 'ANALISAR' THEN
                 IF  rw_crapbdt.insitbdt > 2 OR (rw_crapbdt.insitapr IN (2,6,7)) THEN
                     vr_dscritic := 'An�lise n�o permitida. O Border� deve estar na situa��o EM ESTUDO ou ANALISADO.';
                     CLOSE cr_crapbdt;
                     RAISE vr_exc_erro;
                 END IF;

           ELSIF pr_cddeacao = 'REJEITAR' THEN
             IF (fn_contigencia_esteira(pr_cdcooper)) THEN
               IF (rw_crapbdt.insitbdt <> 1) THEN
                   vr_dscritic := 'Rejei��o n�o permitida. O Border� deve estar com a situa��o EM ESTUDO.';
                   CLOSE cr_crapbdt;
                   RAISE vr_exc_erro;
               END IF;
             ELSE
               IF  (rw_crapbdt.insitapr <> 5) THEN
                   vr_dscritic := 'Rejei��o n�o permitida. O Border� deve estar com a decis�o N�O APROVADO.';
                   CLOSE cr_crapbdt;
                   RAISE vr_exc_erro;
               END IF;
             END IF;
           ELSE
                 vr_dscritic := 'Op��o inv�lida informada para o par�metro pr_cddeacao da dsct0003.pc_valida_bordero';
                 CLOSE cr_crapbdt;
                 raise vr_exc_erro;
           END   IF;
     END   IF;
     CLOSE cr_crapbdt;
  EXCEPTION
     WHEN vr_exc_erro then
          pr_dscritic := vr_dscritic;

     WHEN OTHERS THEN
         pr_dscritic := 'Erro dsct0003.pc_valida_bordero: '||SQLERRM;

  END pc_valida_bordero;
  
  PROCEDURE pc_calcula_juros_simples_tit(pr_cdcooper  IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                                        ,pr_nrdconta  IN crapass.nrdconta%TYPE --> N�mero da Conta
                                        ,pr_nrborder  IN crapbdt.nrborder%TYPE --> numero do bordero
                                        ,pr_cdbandoc  IN craptdb.cdbandoc%TYPE --> Codigo do banco impresso no boleto
                                        ,pr_nrdctabb  IN craptdb.nrdctabb%TYPE --> Numero da conta base do titulo
                                        ,pr_nrcnvcob  IN craptdb.nrcnvcob%TYPE --> Numero do convenio de cobranca
                                        ,pr_nrdocmto  IN craptdb.nrdocmto%TYPE --> Numero do documento
                                        ,pr_vltitulo  IN craptdb.vltitulo%TYPE --> Valor do titulo
                                        ,pr_dtvencto  IN craptdb.dtvencto%TYPE --> Data vencimento titulo
                                        ,pr_dtmvtolt  IN craplcm.dtmvtolt%TYPE --> Data do movimento atual
                                        ,pr_txmensal  IN crapbdt.txmensal%TYPE --> Taxa mensal
                                        ,pr_vldjuros OUT crapljt.vldjuros%TYPE --> Valor do juros calculado
                                        ,pr_dtrefere OUT DATE                  --> Data de referencia da atualizacao dos juros
                                        ,pr_dscritic OUT VARCHAR2              --> Descri��o da critica
                                        ) IS
    /*---------------------------------------------------------------------------------------------------------------------
      Programa : pc_calcula_juros_simples_tit
      Sistema  : CRED
      Sigla    : DSCT0003
      Autor    : Fernando Sacchi(GFT) / Paulo Penteado (GFT)
      Data     : Maio/2018
      
      Objetivo  : Calcula o juros do t�tulo do border� para o dia

      Altera��o : 25/05/2018 - Cria��o (Fernando Sacchi(GFT) / Paulo Penteado (GFT))

    ---------------------------------------------------------------------------------------------------------------------*/
    vr_dia      INTEGER;
    vr_qtd_dias NUMBER;
    vr_dtrefere DATE;
    vr_vldjuros crapljt.vldjuros%TYPE;

    -- Vari�vel de cr�ticas
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
    
    CURSOR cr_crapljt(pr_dtrefere crapljt.dtrefere%TYPE) IS
    SELECT ROWID
          ,crapljt.cdcooper
          ,crapljt.nrdconta
          ,crapljt.nrborder
          ,crapljt.dtrefere
          ,crapljt.cdbandoc
          ,crapljt.nrdctabb
          ,crapljt.nrcnvcob
          ,crapljt.nrdocmto
          ,crapljt.vldjuros
    FROM   crapljt
    WHERE  crapljt.dtrefere = vr_dtrefere
    AND    crapljt.nrdocmto = pr_nrdocmto
    AND    crapljt.cdbandoc = pr_cdbandoc
    AND    crapljt.nrdctabb = pr_nrdctabb
    AND    crapljt.nrdconta = pr_nrdconta
    AND    crapljt.cdcooper = pr_cdcooper;
    rw_crapljt cr_crapljt%rowtype;

  BEGIN
    IF  pr_dtmvtolt > pr_dtvencto THEN
        vr_qtd_dias := ccet0001.fn_diff_datas(to_date(pr_dtvencto,'DD/MM/RRRR'), to_date(pr_dtmvtolt,'DD/MM/RRRR'));
    ELSE
        vr_qtd_dias := to_date(pr_dtvencto,'DD/MM/RRRR') -  to_date(pr_dtmvtolt,'DD/MM/RRRR');
    END IF;
    
    vr_vldjuros := 0;
    vr_dtrefere := last_day(pr_dtmvtolt);

    --  Percorre a quantidade de dias baseado na data atual at� o vencimento do t�tulo
    FOR vr_dia IN 0..vr_qtd_dias LOOP

        vr_dtrefere := last_day(pr_dtmvtolt + vr_dia);

        -- Calcula o juros do t�tulo do border� para o dia
        vr_vldjuros := pr_vltitulo * vr_dia * ((pr_txmensal / 100) / 30);
        
        BEGIN
          OPEN  cr_crapljt(vr_dtrefere);
          FETCH cr_crapljt INTO rw_crapljt;
          --    Se j� foi lan�ado juros para este per�odo, atualiza a tabela de lan�amento de juros 
          IF    cr_crapljt%FOUND THEN

                UPDATE crapljt
                SET    crapljt.vldjuros = vr_vldjuros
                WHERE  crapljt.rowid=rw_crapljt.rowid;
            
          --    Caso contr�rio, insere novo registro
          ELSE
                INSERT INTO crapljt
                       (/*01*/ cdcooper
                       ,/*02*/ nrdconta
                       ,/*03*/ nrborder
                       ,/*04*/ dtrefere
                       ,/*05*/ cdbandoc
                       ,/*06*/ nrdctabb
                       ,/*07*/ nrcnvcob
                       ,/*08*/ nrdocmto
                       ,/*09*/ vldjuros)
                VALUES (/*01*/ pr_cdcooper
                       ,/*02*/ pr_nrdconta
                       ,/*03*/ pr_nrborder
                       ,/*04*/ vr_dtrefere
                       ,/*05*/ pr_cdbandoc
                       ,/*06*/ pr_nrdctabb
                       ,/*07*/ pr_nrcnvcob
                       ,/*08*/ pr_nrdocmto
                       ,/*09*/ vr_vldjuros );
          END   IF;
          CLOSE cr_crapljt;
        EXCEPTION
          WHEN OTHERS THEN
               vr_dscritic := 'Erro ao atualizar os juros calculado do t�tulo do border�: '||SQLERRM;
               RAISE vr_exc_erro;
        END; 
    END LOOP;
        
    pr_vldjuros := vr_vldjuros;
    pr_dtrefere := vr_dtrefere;
  EXCEPTION
    WHEN vr_exc_erro THEN
         pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
         pr_dscritic := 'Erro geral na rotina dsct0003.pc_calcula_juros_simples_tit: '||SQLERRM;

  END pc_calcula_juros_simples_tit;  
  
  
  PROCEDURE pc_calcula_valores_bordero (pr_cdcooper IN crapbdt.cdcooper%TYPE
                                       ,pr_nrborder IN crapbdt.nrborder%TYPE
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE 
                                       ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                                       ,pr_dtmvtolt IN VARCHAR2
                                       ,pr_vltotliq OUT NUMBER 
                                       ,pr_vltotbrt OUT NUMBER 
                                       ,pr_vltotjur OUT NUMBER
                                       ,pr_cdcritic OUT PLS_INTEGER
                                       ,pr_dscritic OUT VARCHAR
                                       ) IS
                                       
   /*-------------------------------------------------------------------------------------------------------
     Programa : pc_calcula_valores_bordero        Antigo: b1wgen0030.p/efetua_liber_anali_bordero (Trecho de Libera��o)
     Sistema  : 
     Sigla    : CRED
     Autor    : Lucas Lazari (GFT) 
     Data     : Abril/2018
   
     Objetivo  : Procedure para calcular os valores l�quido e bruto do border�, bem como realizar o lan�amento dos juros

     Alteracoes: 16/04/2018 - Cria��o (Lucas Lazari (GFT))
                 06/06/2018 - Liberacao parcial do bordero, liberando apenas aqueles aprovados ou quando em 
                              contingencia, aprovados e nao analisados.
   ----------------------------------------------------------------------------------------------------------*/

    -- Vari�veis Locais
    vr_vldjuros  number;
    vr_vltotliq number;
    vr_vltotbrt number;
    vr_vltotjur NUMBER;
    vr_dtmvtolt DATE;
    vr_dtrefere DATE;
    
    vr_exc_erro exception;
    vr_des_erro varchar2(4000);
    vr_dscritic varchar2(4000);
    
    -- CURSORES
    CURSOR cr_base_calculo (pr_cdcooper crapbdt.cdcooper%TYPE
                           ,pr_nrborder crapbdt.nrborder%TYPE
                           ,pr_nrdconta crapass.nrdconta%TYPE 
                           ,pr_dtmvtolt craplcm.dtmvtolt%TYPE
                           ,pr_contingencia INTEGER) IS
      SELECT craptdb.nrdconta,
             craptdb.nrborder,
             craptdb.cdcooper,      
             craptdb.dtvencto,
             craptdb.nrdocmto,
             craptdb.vltitulo,
             craptdb.vlliquid,
             craptdb.cdbandoc,
             craptdb.nrdctabb,
             craptdb.nrcnvcob,
             craptdb.rowid
        FROM craptdb 
       WHERE craptdb.cdcooper = pr_cdcooper
         AND craptdb.nrborder = pr_nrborder 
         AND craptdb.nrdconta = pr_nrdconta 
         AND craptdb.insittit = 0
         AND (craptdb.insitapr = 1 OR (craptdb.insitapr = 0 AND pr_contingencia=1))
    ;rw_base_calculo cr_base_calculo%ROWTYPE;
    
    --Selecionar informacoes do titulo
    CURSOR cr_crapcob (pr_cdcooper IN crapcob.cdcooper%TYPE
                      ,pr_cdbandoc IN crapcob.cdbandoc%TYPE
                      ,pr_nrdctabb IN crapcob.nrdctabb%TYPE
                      ,pr_nrdconta IN crapcob.nrdconta%type
                      ,pr_nrcnvcob IN crapcob.nrcnvcob%type
                      ,pr_nrdocmto IN crapcob.nrdocmto%type
                      ,pr_flgregis IN crapcob.flgregis%type) IS
      SELECT crapcob.cdbandoc
            ,crapcob.cdcooper
            ,crapcob.nrcnvcob
            ,crapcob.nrdconta
            ,crapcob.nrdocmto
            ,crapcob.incobran
            ,crapcob.dtretcob
            ,crapcob.ROWID
      FROM crapcob
      WHERE crapcob.cdcooper = pr_cdcooper
      AND   crapcob.cdbandoc = pr_cdbandoc
      AND   crapcob.nrdctabb = pr_nrdctabb
      AND   crapcob.nrdconta = pr_nrdconta
      AND   crapcob.nrcnvcob = pr_nrcnvcob
      AND   crapcob.nrdocmto = pr_nrdocmto
      AND   crapcob.flgregis = pr_flgregis;
    rw_crapcob cr_crapcob%ROWTYPE;
     
    CURSOR cr_crapbdt IS
      SELECT 
           crapbdt.txmensal
      FROM 
           crapbdt
      WHERE 
           crapbdt.nrborder = pr_nrborder
           AND crapbdt.cdcooper = pr_cdcooper
           AND crapbdt.nrdconta = pr_nrdconta;
    rw_crapbdt cr_crapbdt%rowtype;
    
    vr_contingencia INTEGER;
    
    BEGIN
      vr_contingencia := 0;
      vr_dtmvtolt := to_date(pr_dtmvtolt, 'DD/MM/RRRR');
      
      open cr_crapbdt;
      fetch cr_crapbdt into rw_crapbdt;
      
      vr_vltotliq := 0;
      vr_vltotbrt := 0;
      vr_vltotjur := 0;
      IF fn_contigencia_esteira(pr_cdcooper) THEN
        vr_contingencia := 1;
      END IF;
      FOR rw_base_calculo IN
        cr_base_calculo (pr_cdcooper => pr_cdcooper
                        ,pr_nrborder => pr_nrborder
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_dtmvtolt => vr_dtmvtolt
                        ,pr_contingencia => vr_contingencia) 
        LOOP                
        pc_calcula_juros_simples_tit(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrborder => pr_nrborder
                                    ,pr_cdbandoc => rw_base_calculo.cdbandoc
                                    ,pr_nrdctabb => rw_base_calculo.nrdctabb
                                    ,pr_nrcnvcob => rw_base_calculo.nrcnvcob
                                    ,pr_nrdocmto => rw_base_calculo.nrdocmto
                                    ,pr_vltitulo => rw_base_calculo.vltitulo
                                    ,pr_dtvencto => rw_base_calculo.dtvencto
                                    ,pr_dtmvtolt => vr_dtmvtolt
                                    ,pr_txmensal => rw_crapbdt.txmensal
                                    ,pr_vldjuros => vr_vldjuros
                                    ,pr_dtrefere => vr_dtrefere
                                    ,pr_dscritic => vr_dscritic );
          
        -- Aproveita o loop do cursor de t�tulos do border� para atualizar as informa��es no banco
        UPDATE craptdb
        SET    craptdb.vlliquid = ROUND((rw_base_calculo.vltitulo - vr_vldjuros),2),
               craptdb.dtlibbdt = vr_dtmvtolt,
               craptdb.insittit = 4,
               craptdb.insitapr = 1,
               craptdb.vlsldtit = rw_base_calculo.vltitulo
        WHERE  craptdb.rowid = rw_base_calculo.rowid;
          
        -- Busca o registro do t�tulo na crapcob
        OPEN cr_crapcob (pr_cdcooper => pr_cdcooper
                        ,pr_cdbandoc => rw_base_calculo.cdbandoc
                        ,pr_nrdctabb => rw_base_calculo.nrdctabb
                        ,pr_nrdconta => rw_base_calculo.nrdconta
                        ,pr_nrcnvcob => rw_base_calculo.nrcnvcob
                        ,pr_nrdocmto => rw_base_calculo.nrdocmto
                        ,pr_flgregis => 1);
        FETCH cr_crapcob INTO rw_crapcob;
            
        IF cr_crapcob%FOUND THEN
          -- Registra log de cobran�a para o t�tulos  
          PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid   
                                       ,pr_cdoperad => pr_cdoperad   
                                       ,pr_dtmvtolt => pr_dtmvtolt   
                                       ,pr_dsmensag => 'Titulo Descontado - Bordero ' || pr_nrborder
                                       ,pr_des_erro => vr_des_erro   
                                       ,pr_dscritic => vr_dscritic);
            
          IF vr_des_erro = 'NOK' THEN
            RAISE vr_exc_erro;
          END IF;
          close cr_crapcob;
        END IF;
          
        vr_vltotliq := vr_vltotliq + ROUND((rw_base_calculo.vltitulo - vr_vldjuros),2);
        vr_vltotbrt := vr_vltotbrt + rw_base_calculo.vltitulo;
        vr_vltotjur := vr_vltotjur + vr_vldjuros;
          
      END LOOP;
      
      pr_vltotliq := vr_vltotliq;
      pr_vltotbrt := vr_vltotbrt;
      pr_vltotjur := vr_vltotjur;
      
  EXCEPTION
    WHEN vr_exc_erro THEN
         pr_cdcritic := 0;
         pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
         pr_cdcritic := 0;
         pr_dscritic := 'Erro geral na rotina dsct0003.pc_calcula_valores_bordero: '||SQLERRM;

  END pc_calcula_valores_bordero;
  
    
  PROCEDURE pc_calcula_iof_bordero(pr_cdcooper IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE --> N�mero do Bordero
                                  ,pr_nrdconta IN craptdb.nrdconta%TYPE --> N�mero da Conta
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                  ,pr_vltotliq IN NUMBER                --> Valor total l�quido do border�
                                  --------> OUT <--------
                                  ,pr_flgimune OUT PLS_INTEGER           --> Possui imunidade tribut�ria
                                  ,pr_vltotiofpri OUT NUMBER            --> Valor total IOF Principal
                                  ,pr_vltotiofadi OUT NUMBER            --> Valor total IOF Adicional
                                  ,pr_vltotiofcpl OUT NUMBER            --> Valor total IOF Complementar
                                  ,pr_vltxiofatra OUT NUMBER            --> Valor total IOF Atraso
                                  ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2             --> Descri�ao da cr�tica  
                                   ) is
   /*-------------------------------------------------------------------------------------------------------
     Programa : pc_calcula_iof_bordero        Antigo: b1wgen0030.p/efetua_liber_anali_bordero (Trecho de Libera��o)
     Sistema  : 
     Sigla    : CRED
     Autor    : Lucas Lazari (GFT) 
     Data     : Abril/2018
   
     Objetivo  : Procedure para calcular o IOF sobre o border� de desconto de T�tulo

     Alteracoes: 16/04/2018 - Cria��o (Lucas Lazari (GFT))
   ----------------------------------------------------------------------------------------------------------*/
    
    vr_dscritic crapcri.dscritic%TYPE;  
    
    vr_vliofpri              NUMBER;
    vr_vliofadi              NUMBER;
    vr_vliofcpl              NUMBER;
    
    vr_vltotiofpri              NUMBER;
    vr_vltotiofadi              NUMBER;
    vr_vltotiofcpl              NUMBER;
    
      
    --============== CURSORES ==================
    CURSOR cr_craptdb (pr_cdcooper IN craptdb.cdcooper%TYPE
                      ,pr_nrborder IN craptdb.nrborder%TYPE
                      ,pr_nrdconta IN craptdb.nrdconta%TYPE
                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
      SELECT craptdb.dtvencto,
             (craptdb.dtvencto - pr_dtmvtolt) AS qtdiaiof,
             craptdb.cdcooper,
             craptdb.nrdconta,
             craptdb.vlliquid,
             craptdb.rowid
      FROM craptdb
      WHERE craptdb.cdcooper = pr_cdcooper
      AND   craptdb.nrborder = pr_nrborder
      AND   craptdb.nrdconta = pr_nrdconta;


    rw_craptdb cr_craptdb%ROWTYPE;
    
    CURSOR cr_crapjur(pr_cdcooper IN crapjur.cdcooper%TYPE
                     ,pr_nrdconta IN crapjur.nrdconta%TYPE) IS
     SELECT crapjur.natjurid
           ,crapjur.tpregtrb
       FROM crapjur
      WHERE crapjur.cdcooper = pr_cdcooper
        AND crapjur.nrdconta = pr_nrdconta;
    rw_crapjur cr_crapjur%ROWTYPE;
    
    vr_exc_erro exception;
    
  BEGIN
    vr_dscritic := '';
    
    vr_vltotiofpri := 0;            
    vr_vltotiofadi := 0;             
    vr_vltotiofcpl := 0;             
    
    -- busca os dados do associado/cooperado para s� ent�o encontrar seus dados na tabela de par�metros
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    CLOSE cr_crapass;
    
    -- Busca dados de pessoa jur�dica
    OPEN cr_crapjur(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapjur INTO rw_crapjur;
    CLOSE cr_crapjur;
    
    -- Percorre todos os t�tulos do border� para realizar o c�lculo do IOF
    FOR rw_craptdb IN
        cr_craptdb (pr_cdcooper => pr_cdcooper,
                    pr_nrborder => pr_nrborder,
                    pr_nrdconta => pr_nrdconta,
                    pr_dtmvtolt => pr_dtmvtolt) LOOP
      
      TIOF0001.pc_calcula_valor_iof_prg (pr_tpproduto            => 2 
                                        ,pr_tpoperacao           => 1 
                                        ,pr_cdcooper             => pr_cdcooper 
                                        ,pr_nrdconta             => pr_nrdconta 
                                        ,pr_inpessoa             => rw_crapass.inpessoa 
                                        ,pr_natjurid             => rw_crapjur.natjurid 
                                        ,pr_tpregtrb             => rw_crapjur.tpregtrb 
                                        ,pr_dtmvtolt             => pr_dtmvtolt 
                                        ,pr_qtdiaiof             => rw_craptdb.qtdiaiof 
                                        ,pr_vloperacao           => rw_craptdb.vlliquid 
                                        ,pr_vltotalope           => pr_vltotliq 
                                        ,pr_vltaxa_iof_atraso    => '0' 
                                        ,pr_vliofpri             => vr_vliofpri 
                                        ,pr_vliofadi             => vr_vliofadi 
                                        ,pr_vliofcpl             => vr_vliofcpl 
                                        ,pr_vltaxa_iof_principal => pr_vltxiofatra 
                                        ,pr_flgimune             => pr_flgimune 
                                        ,pr_dscritic             => vr_dscritic); 
      
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_erro; 
      END IF;
      
      BEGIN
        UPDATE craptdb tdb
        SET    vliofprc	= vr_vliofpri
              ,vliofadc	= vr_vliofadi
        WHERE  tdb.rowid = rw_craptdb.rowid;
      EXCEPTION
        WHEN OTHERS THEN
             vr_dscritic := 'Erro ao atualizar os valores de IOF do t�tulo do border�: '||SQLERRM;
             RAISE vr_exc_erro;
      END; 
      
      vr_vltotiofpri := vr_vltotiofpri + ROUND(vr_vliofpri,2);            
      vr_vltotiofadi := vr_vltotiofadi + ROUND(vr_vliofadi,2);             
      vr_vltotiofcpl := vr_vltotiofcpl + ROUND(vr_vliofcpl,2);
      
    END LOOP;
    
    pr_vltotiofpri := ROUND(vr_vltotiofpri,2);            
    pr_vltotiofadi := ROUND(vr_vltotiofadi,2);             
    pr_vltotiofcpl := ROUND(vr_vltotiofcpl,2);
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := 0;
        pr_dscritic := vr_dscritic;
    
  END pc_calcula_iof_bordero;
  
  PROCEDURE pc_lanca_iof_bordero (pr_cdcooper IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                                 ,pr_cdagenci IN crapass.cdagenci%type --> C�digo da Ag�ncia
                                 ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                                 ,pr_nrborder IN crapbdt.nrborder%TYPE --> N�mero do Bordero
                                 ,pr_nrdconta IN craptdb.nrdconta%TYPE --> N�mero da Conta
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                 ,pr_vltotliq IN NUMBER                --> Valor total IOF Atraso
                                 ,pr_vltxiofatra OUT NUMBER            --> Valor total IOF Atraso
                                  --------> OUT <--------
                                 ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2             --> Descri�ao da cr�tica  
                                 ) is
   /*-------------------------------------------------------------------------------------------------------
     Programa : pc_lanca_iof_bordero        Antigo: b1wgen0030.p/efetua_liber_anali_bordero (Trecho de Libera��o)
     Sistema  : 
     Sigla    : CRED
     Autor    : Lucas Lazari (GFT) 
     Data     : Abril/2018
   
     Objetivo  : Procedure para lan�ar o IOF sobre o border� de desconto de T�tulo

     Alteracoes: 16/04/2018 - Cria��o (Lucas Lazari (GFT))
   ----------------------------------------------------------------------------------------------------------*/
    
    vr_dscritic crapcri.dscritic%TYPE;  
    vr_nrdolote craplot.nrdolote%TYPE;
    
    vr_vltotiof                  NUMBER;
    vr_rowid                     ROWID;
    vr_flgimune                  INTEGER;
    vr_cdcritic                  PLS_INTEGER;          
    vr_exc_erro                  EXCEPTION;
    
    
    -- Cursor para buscar lote
    CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
                     ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                     ,pr_cdagenci IN craplot.cdagenci%TYPE
                     ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                     ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
      SELECT lot.qtcompln
            ,lot.vlcompcr
            ,lot.qtinfoln
            ,lot.vlinfocr
            ,lot.vlcompdb
            ,lot.vlinfodb
            ,lot.dtmvtolt
            ,lot.cdagenci
            ,lot.cdbccxlt
            ,lot.nrdolote
            ,lot.nrseqdig
            ,lot.tplotmov
            ,lot.ROWID
            ,count(1) over() retorno
        FROM craplot lot
       WHERE lot.cdcooper = pr_cdcooper
         AND lot.dtmvtolt = pr_dtmvtolt
         AND lot.cdagenci = pr_cdagenci
         AND lot.cdbccxlt = pr_cdbccxlt
         AND lot.nrdolote = pr_nrdolote
      FOR UPDATE;
    rw_craplot cr_craplot%ROWTYPE;  
    rw_craplcm craplcm%ROWTYPE;
    
    vr_vltotiofpri NUMBER;            --> Valor total IOF Principal
    vr_vltotiofadi NUMBER;            --> Valor total IOF Adicional
    vr_vltotiofcpl NUMBER;            --> Valor total IOF Complementar
    
    CURSOR cr_crapcot(pr_cdcooper IN crapbdt.cdcooper%TYPE
                     ,pr_nrdconta IN crapbdt.nrdconta%TYPE
                     ) IS 
      SELECT crapcot.vliofapl,
             crapcot.vlbsiapl
      FROM   crapcot
      WHERE  crapcot.cdcooper = pr_cdcooper
      AND    crapcot.nrdconta = pr_nrdconta;
    rw_crapcot cr_crapcot%ROWTYPE;
     
  BEGIN
    vr_dscritic := '';
    
    pc_calcula_iof_bordero(pr_cdcooper    => pr_cdcooper 
                          ,pr_nrborder    => pr_nrborder 
                          ,pr_nrdconta    => pr_nrdconta 
                          ,pr_dtmvtolt    => pr_dtmvtolt 
                          ,pr_vltotliq    => pr_vltotliq
                          ,pr_vltotiofpri => vr_vltotiofpri 
                          ,pr_vltotiofadi => vr_vltotiofadi 
                          ,pr_vltotiofcpl => vr_vltotiofcpl 
                          ,pr_vltxiofatra => pr_vltxiofatra 
                          ,pr_flgimune    => vr_flgimune 
                          ,pr_cdcritic    => vr_cdcritic          
                          ,pr_dscritic    => vr_dscritic);        
   
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    vr_vltotiof := ROUND(vr_vltotiofpri + vr_vltotiofadi,2);
    
    IF vr_vltotiof > 0 THEN
      
      -- Verifica e atualiza o registro de cotas da conta do cooperado
      OPEN cr_crapcot(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta);
      FETCH cr_crapcot INTO rw_crapcot;
      
      --Se n�o encontrar o registro de cotas do usu�rio, lan�a o erro
      IF cr_crapcot%NOTFOUND THEN
        CLOSE cr_crapcot;
        vr_dscritic:= 'Registro crapcot n�o encontrado.';
        RAISE vr_exc_erro;
      ELSE
        --atualiza o registro de cotas da conta do cooperado
        UPDATE crapcot
           SET crapcot.vliofapl = crapcot.vliofapl + vr_vltotiof,
               crapcot.vlbsiapl = crapcot.vlbsiapl + pr_vltotliq
         WHERE crapcot.cdcooper = pr_cdcooper
           AND crapcot.nrdconta = pr_nrdconta;
      END IF;
      
      -- Rotina para criar lote e bordero
      vr_nrdolote := fn_sequence(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRDOLOTE'
                                ,pr_dsdchave => TO_CHAR(pr_cdcooper)|| ';' 
                                             || pr_dtmvtolt || ';'
                                             || TO_CHAR(pr_cdagenci)|| ';'
                                             || '100'); 
    
      --Buscar o lote
      OPEN cr_craplot(pr_cdcooper         
                     ,pr_dtmvtolt
                     ,1
                     ,100
                     ,vr_nrdolote);
        
      FETCH cr_craplot INTO rw_craplot;
      
      -- Gerar erro caso n�o encontre
      IF cr_craplot%NOTFOUND THEN
         -- Fechar cursor pois teremos raise
         CLOSE cr_craplot;
         
         BEGIN
           INSERT INTO craplot
                      (cdcooper
                      ,dtmvtolt
                      ,cdagenci
                      ,cdbccxlt
                      ,nrdolote
                      ,tplotmov
                      ,cdoperad)
               VALUES(pr_cdcooper
                      ,pr_dtmvtolt
                      ,1
                      ,100
                      ,vr_nrdolote
                      ,1
                      ,pr_cdoperad)
            RETURNING dtmvtolt
                      ,cdagenci
                      ,cdbccxlt
                      ,nrdolote                   
                      ,vlinfocr
                      ,vlcompcr
                      ,qtinfoln
                      ,qtcompln
                      ,nrseqdig
                      ,ROWID
                 INTO rw_craplot.dtmvtolt
                      ,rw_craplot.cdagenci
                      ,rw_craplot.cdbccxlt
                      ,rw_craplot.nrdolote
                      ,rw_craplot.vlinfocr
                      ,rw_craplot.vlcompcr
                      ,rw_craplot.qtinfoln
                      ,rw_craplot.qtcompln
                      ,rw_craplot.nrseqdig
                      ,rw_craplot.rowid;
         EXCEPTION
           WHEN OTHERS THEN
             -- Monta critica
             vr_cdcritic := NULL;
             vr_dscritic := 'Erro ao inserir na tabela craplot: ' || SQLERRM;
             
             -- Gera exce��o
             RAISE vr_exc_erro;
             
         END;                            
         
         BEGIN
          UPDATE craplot
             SET craplot.nrseqdig = craplot.nrseqdig + 1
                ,craplot.vlinfodb = craplot.vlinfodb + vr_vltotiof
                ,craplot.vlcompdb = craplot.vlcompdb + vr_vltotiof              
                ,craplot.qtinfoln = craplot.qtinfoln + 1
                ,craplot.qtcompln = craplot.qtcompln + 1
           WHERE craplot.rowid = rw_craplot.rowid
           RETURNING dtmvtolt
                    ,cdagenci
                    ,cdbccxlt
                    ,nrdolote                   
                    ,vlinfocr
                    ,vlcompcr
                    ,qtinfoln
                    ,qtcompln
                    ,nrseqdig
                    ,ROWID
               INTO rw_craplot.dtmvtolt
                    ,rw_craplot.cdagenci
                    ,rw_craplot.cdbccxlt
                    ,rw_craplot.nrdolote
                    ,rw_craplot.vlinfocr
                    ,rw_craplot.vlcompcr
                    ,rw_craplot.qtinfoln
                    ,rw_craplot.qtcompln
                    ,rw_craplot.nrseqdig
                    ,rw_craplot.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            -- Monta critica
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar o Lote!';
            
            -- Gera exce��o
            RAISE vr_exc_erro;
        END;
        
        -- Criar registro na lcm
        BEGIN
          INSERT INTO craplcm
                     (cdcooper
                     ,dtmvtolt
                     ,hrtransa
                     ,cdagenci
                     ,cdbccxlt
                     ,nrdolote
                     ,nrseqdig
                     ,nrdconta
                     ,nrdctabb
                     ,nrdctitg
                     ,nrdocmto
                     ,cdhistor     
                     ,vllanmto
                     ,cdpesqbb)
              VALUES(pr_cdcooper
                    ,rw_craplot.dtmvtolt
                    ,TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                    ,rw_craplot.cdagenci
                    ,rw_craplot.cdbccxlt
                    ,rw_craplot.nrdolote
                    ,rw_craplot.nrseqdig
                    ,pr_nrdconta
                    ,pr_nrdconta
                    ,TO_CHAR(gene0002.fn_mask(pr_nrdconta,'99999999'))
                    ,rw_craplot.nrseqdig
                    ,vr_cdhistordsct_iofspriadic
                    ,vr_vltotiof
                    ,'Bordero ' || pr_nrborder || ' - ' || TO_CHAR(gene0002.fn_mask(pr_vltotliq,'999.999.999999')))
          RETURNING craplcm.ROWID
                   ,craplcm.cdhistor
                   ,craplcm.cdcooper
                   ,craplcm.dtmvtolt
                   ,craplcm.hrtransa
                   ,craplcm.nrdconta
                   ,craplcm.nrdocmto
                   ,craplcm.vllanmto
              INTO  vr_rowid
                   ,rw_craplcm.cdhistor
                   ,rw_craplcm.cdcooper
                   ,rw_craplcm.dtmvtolt
                   ,rw_craplcm.hrtransa
                   ,rw_craplcm.nrdconta
                   ,rw_craplcm.nrdocmto
                   ,rw_craplcm.vllanmto;
        EXCEPTION
          WHEN OTHERS THEN
            -- Monta critica
            vr_cdcritic := NULL;
            vr_dscritic := 'Erro ao inserir na tabela craplcm: ' || SQLERRM;
            
            -- Gera exce��o
            RAISE vr_exc_erro;
            
        END;
         
      ELSE
         -- Apenas fechar o cursor
         CLOSE cr_craplot;
      END IF; 
      
      TIOF0001.pc_insere_iof (pr_cdcooper       => pr_cdcooper 
                             ,pr_nrdconta       => pr_nrdconta
                             ,pr_dtmvtolt       => pr_dtmvtolt
                             ,pr_tpproduto      => 2
                             ,pr_nrcontrato     => pr_nrborder
                             ,pr_dtmvtolt_lcm   => pr_dtmvtolt 
                             ,pr_cdagenci_lcm   => 1 
                             ,pr_cdbccxlt_lcm   => 100 
                             ,pr_nrdolote_lcm   => vr_nrdolote
                             ,pr_nrseqdig_lcm   => rw_craplot.nrseqdig
                             ,pr_vliofpri       => ROUND(vr_vltotiofpri,2)
                             ,pr_vliofadi       => ROUND(vr_vltotiofadi,2)
                             ,pr_vliofcpl       => ROUND(vr_vltotiofcpl,2)
                             ,pr_flgimune       => vr_flgimune 
                             ,pr_cdcritic       => vr_cdcritic 
                             ,pr_dscritic       => vr_dscritic); 
      
        IF vr_dscritic IS NOT NULL THEN
           RAISE vr_exc_erro; 
        END IF;
        
    END IF;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
       IF  vr_cdcritic <> 0 THEN
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
    
  END pc_lanca_iof_bordero;
  
  /*Procedure que grava as restri��es de um border� (b1wgen0030.p/grava-restricao-bordero)*/
  PROCEDURE pc_grava_restricao_bordero (pr_nrborder IN crapabt.nrborder%TYPE --> N�mero do Border�
                                       ,pr_cdoperad IN crapabt.cdoperad%TYPE DEFAULT NULL --> Codigo do operador
                                       ,pr_nrdconta IN crapabt.nrdconta%TYPE
                                       ,pr_dsrestri IN crapabt.dsrestri%TYPE --> Descri��o da Restri��o
                                       ,pr_nrseqdig IN crapabt.nrseqdig%TYPE --> Sequ�ncial da Restri��o
                                       ,pr_cdcooper IN crapabt.cdcooper%TYPE --> C�digo da Cooperativa
                                       ,pr_cdbandoc IN crapabt.cdbandoc%TYPE DEFAULT 0
                                       ,pr_nrdctabb IN crapabt.nrdctabb%TYPE DEFAULT 0
                                       ,pr_nrcnvcob IN crapabt.nrcnvcob%TYPE DEFAULT 0
                                       ,pr_nrdocmto IN crapabt.nrdocmto%TYPE DEFAULT 0
                                       ,pr_flaprcoo IN crapabt.flaprcoo%TYPE --> Indicador se foi aprovado pelo coordenador (1 Sim / 0 N�o)
                                       ,pr_dsdetres IN crapabt.dsdetres%TYPE --> Detalhamento da restricao
                                       ,pr_dscritic    OUT VARCHAR2                --> Descricao Critica
                                       ) is
  BEGIN
    BEGIN
      INSERT INTO cecred.crapabt
            (nrborder
            ,cdoperad
            ,nrdconta
            ,dsrestri
            ,nrseqdig
            ,cdcooper
            ,cdbandoc
            ,nrdctabb
            ,nrcnvcob
            ,nrdocmto
            ,flaprcoo
            ,dsdetres)
          values
            (pr_nrborder
            ,pr_cdoperad
            ,pr_nrdconta
            ,pr_dsrestri
            ,pr_nrseqdig
            ,pr_cdcooper
            ,pr_cdbandoc
            ,pr_nrdctabb
            ,pr_nrcnvcob
            ,pr_nrdocmto
            ,pr_flaprcoo
            ,pr_dsdetres);
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao gravar o registro crapabt: '|| sqlerrm;
    END;
  END pc_grava_restricao_bordero;

  /* Retorna a qtd. de T�tulos de acordo com alguma ocorrencia */
  PROCEDURE pc_ret_qttit_ocorrencia (pr_cdcooper IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                                    ,pr_nrdconta IN craptdb.nrdconta%TYPE --> N�mero da Conta
                                    ,pr_nrinssac IN craptdb.nrinssac%TYPE --> Pagador
                                    ,pr_cdocorre IN crapret.cdocorre%TYPE --> C�digo do Tipo de Ocorr�ncia
                                    ,pr_cdmotivo IN crapret.cdmotivo%TYPE DEFAULT '' --> Cont�m o C�digo do Motivo
                                    ,pr_flgtitde IN boolean DEFAULT FALSE --> Qual Tipo de T�tulo (FALSE= Apenas T�tulos em Border�)
                                     --------> OUT <--------
                                    ,pr_cntqttit OUT PLS_INTEGER          --> Quantidade de T�tulos de Acordo com o Filtro.
                                    ) is
  BEGIN
    -- .........................................................................
    --
    --  Programa : pc_ret_qttit_ocorrencia           Origem no Progress: b1wgen0030.p/retorna-titulos-ocorrencia
    --  Sistema  : Cred
    --  Sigla    :
    --  Autor    : Andrew Albuquerque (GFT)
    --  Data     : Abril/2018.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Retorna a qtd. de T�tulos de acordo com alguma ocorrencia
    DECLARE
      vr_query VARCHAR2(4000);
    BEGIN
      vr_query := 'SELECT COUNT(1) AS QTDE '||CHR(13)||
                  '  FROM cecred.crapcco cco '||CHR(13)||
                  ' INNER JOIN cecred.crapceb ceb '||CHR(13)||
                  '    ON ceb.cdcooper = cco.cdcooper '||CHR(13)||
                  '   AND ceb.nrconven = cco.nrconven '||CHR(13)||
                  ' INNER JOIN cecred.crapcob cob '||CHR(13)||
                  '    ON cob.cdcooper = ceb.cdcooper '||CHR(13)||
                  '   AND cob.cdbandoc = cob.cdbandoc '||CHR(13)||
                  '   AND cob.nrdctabb = cob.nrdctabb '||CHR(13)||
                  '   AND cob.nrdconta = ceb.nrdconta '||CHR(13)||
                  '   AND cob.nrcnvcob = ceb.nrconven '||CHR(13);

      IF pr_flgtitde THEN
        vr_query := vr_query ||
                    ' INNER JOIN cecred.craptdb tdb '||CHR(13)||
                    '    ON tdb.cdcooper = cob.cdcooper '||CHR(13)||
                    '   AND tdb.cdbandoc = cob.cdbandoc '||CHR(13)||
                    '   AND tdb.nrdctabb = cob.nrdctabb  '||CHR(13)||
                    '   AND tdb.nrcnvcob = cob.nrcnvcob  '||CHR(13)||
                    '   AND tdb.nrdconta = cob.nrdconta  '||CHR(13)||
                    '   AND tdb.nrdocmto = cob.nrdocmto '||CHR(13);
      END IF;

      IF NVL(pr_cdocorre,0) > 0 THEN
        vr_query := vr_query ||
                    'INNER JOIN cecred.crapret ret '||CHR(13)||
                    '   ON ret.cdcooper = cob.cdcooper '||CHR(13)||
                    '  AND ret.nrdconta = cob.nrdconta '||CHR(13)||
                    '  AND ret.nrcnvcob = cob.nrcnvcob '||CHR(13)||
                    '  AND ret.nrdocmto = cob.nrdocmto '||CHR(13);
      END IF;

      vr_query := vr_query ||
                  ' WHERE cco.cdcooper = ' || pr_cdcooper ||CHR(13)||
                  '   AND cco.flgregis = 1 '  ||CHR(13); -- 1 registrada
      IF NVL(pr_nrdconta,0) > 0 THEN
        vr_query := vr_query || '   AND ceb.nrdconta =' || pr_nrdconta ||CHR(13);
      END IF;

      IF pr_cdocorre = 9 THEN /* protestado */
        vr_query := vr_query || '   AND cob.incobran = 3' ||CHR(13);
      END IF;

      IF NVL(pr_nrinssac,0) > 0 THEN
        vr_query := vr_query || '   AND cob.nrinssac = ' || pr_nrinssac ||CHR(13);
      END IF;

      IF pr_flgtitde THEN
        vr_query := vr_query || '   AND tdb.insittit = 4 '||CHR(13);
      END IF;

     -- IF pr_cdocorre > 0
     IF NVL(pr_cdocorre,0) > 0  THEN
        vr_query := vr_query || '      AND ret.cdocorre = '|| pr_cdocorre ||CHR(13);
        IF NVL(pr_cdmotivo,0) > 0 THEN
          vr_query := vr_query || '      AND ret.cdmotivo = ''' || pr_cdmotivo || '''';
        END IF;
     END IF;

      -- Ordem para executar de forma imediata o SQL din�mico
      EXECUTE IMMEDIATE vr_query INTO pr_cntqttit;
    END;
  END pc_ret_qttit_ocorrencia;

  /* Buscar dados do Principal (@) da rotina Desconto de Titulos */
  PROCEDURE pc_busca_dados_dsctit (pr_cdcooper IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                                  ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL --> Codigo do operador
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                  ,pr_idorigem IN INTEGER  --Identificador Origem pagamento
                                  ,pr_nrdconta IN craptdb.nrdconta%TYPE DEFAULT NULL --> N�mero da Conta
                                  ,pr_idseqttl IN INTEGER       --> idseqttl
                                  ,pr_nmdatela IN VARCHAR2      --> Nome da tela
                                  ,pr_flgerlog IN BOOLEAN       --> identificador se deve gerar log
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT INTEGER   --> Codigo Critica
                                  ,pr_dscritic OUT VARCHAR2  --> Descricao Critica
                                  ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela erros
                                  ,pr_tab_dados_dsctit OUT typ_tab_desconto_titulos --> Tabela de Retorno
                                  ,pr_des_reto OUT VARCHAR2
                                  ) IS
  BEGIN
    -- .........................................................................
    --
    --  Programa : pc_busca_dados_dsctit           Origem no Progress: b1wgen0030.p/busca_dados_dsctit
    --  Sistema  : Cred
    --  Sigla    :
    --  Autor    : Andrew Albuquerque (GFT)
    --  Data     : Abril/2018.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Buscar dados do Principal (@) da rotina Desconto de Titulos
    DECLARE
      -- Erro em chamadas da pc_ver_capital
      vr_des_reto VARCHAR2(3) DEFAULT 'OK';
      vr_tab_erro GENE0001.typ_tab_erro;

      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Descri��o da origem da chamada
      vr_dsorigem VARCHAR2(10);
      -- Descri��o da transa��o
      vr_dstransa VARCHAR2(100);
      -- rowid tabela de log
      vr_nrdrowid ROWID;

      --Vari�vel Auxiliar de C�lculo de Datas.
      vr_aux_difdays PLS_INTEGER;

      --Cursor para popular o total de Titulos qdo n�o h� registro de Limite, a partir dos Titulos do Border�.
      CURSOR cr_tdbcco (pr_cdcooper IN craptdb.cdcooper%TYPE,
                        pr_nrdconta IN craptdb.nrdconta%TYPE,
                        pr_dtmvtolt IN craptdb.dtdpagto%TYPE) IS
        SELECT SUM(tdb.vltitulo) as vlutiliz,
               COUNT(tdb.vltitulo) as qtutiliz,
               SUM(DECODE(cco.flgregis,1,tdb.vltitulo,0))   as vlutilcr,
               SUM(DECODE(cco.flgregis,1,1,0)) as qtutilcr,
               SUM(DECODE(cco.flgregis,0,tdb.vltitulo,0))   as vlutilsr,
               SUM(DECODE(cco.flgregis,0,1,0)) as qtutilsr
          FROM cecred.craptdb tdb
         INNER JOIN cecred.crapcco cco
            ON cco.cdcooper = tdb.cdcooper
           AND cco.nrconven = tdb.nrcnvcob
         WHERE (tdb.cdcooper = pr_cdcooper AND
                tdb.nrdconta = pr_nrdconta AND
                tdb.insittit =  4
                )
            OR (tdb.cdcooper = pr_cdcooper AND
                tdb.nrdconta = pr_nrdconta   AND
                tdb.insittit = 2 AND
                tdb.dtdpagto = pr_dtmvtolt --trunc(sysdate)
                );
      rw_tdbcco cr_tdbcco%ROWTYPE;

      --Cursor para Linhas de Cr�dito
      CURSOR cr_crapldc (pr_cdcooper IN crapldc.cdcooper%TYPE,
                         pr_cddlinha IN crapldc.cddlinha%TYPE) IS
        SELECT ldc.cddlinha,
               ldc.dsdlinha,
               ldc.flgstlcr
          FROM cecred.crapldc ldc
         WHERE ldc.cdcooper = pr_cdcooper
           AND ldc.cddlinha = pr_cddlinha
           AND ldc.tpdescto = 3
           ;
      rw_crapldc cr_crapldc%ROWTYPE;

    BEGIN
      --Iniciando Variavel
      vr_des_reto := 'OK';

      -- Se foi solicitado LOG
      IF pr_flgerlog THEN
        -- busca informa��es que ser�o aproveitas posteriormente
        vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
        vr_dstransa := 'Consultar a quantidade de T�tulos de acordo com alguma ocorr�ncia.';
      END IF;

      -- Buscar dados de Capital para o Cooperado, Conta, DtMovtolt
      -- Verificar se a cota/capital do cooperado � v�lida
      EXTR0001.pc_ver_capital(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 0
                             ,pr_nrdcaixa => 0
                             ,pr_inproces => rw_crapdat.inproces
                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                             ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                             ,pr_cdprogra => pr_nmdatela
                             ,pr_idorigem => pr_idorigem
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_vllanmto => 0
                             ,pr_des_reto => vr_des_reto
                             ,pr_tab_erro => vr_tab_erro);

      -- Verifica se retornou erro durante a execu��o
      IF vr_des_reto <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          -- Se existir erro adiciona na cr�tica
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
          pr_tab_erro := vr_tab_erro;
          vr_des_reto := 'NOK';
--          pr_des_reto
        ELSE
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao consultar capital.';
          vr_tab_erro(1).cdcritic := vr_cdcritic;
          vr_tab_erro(1).dscritic := vr_dscritic;
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
          vr_des_reto := 'NOK';
        END IF;

        -- Se Solicitou Gera��o de LOG
        IF pr_flgerlog THEN
          -- Chamar gera��o de LOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;
      END IF;

      OPEN cr_craplim (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta);

      FETCH cr_craplim INTO rw_craplim;

      -- Se N�O encontrar registro DE LIMITE
      IF cr_craplim%NOTFOUND THEN
         pr_tab_dados_dsctit(1).nrctrlim := 0;
         pr_tab_dados_dsctit(1).dtinivig := null;
         pr_tab_dados_dsctit(1).qtdiavig := 0;
         pr_tab_dados_dsctit(1).vllimite := 0;
         pr_tab_dados_dsctit(1).qtrenova := 0;
         pr_tab_dados_dsctit(1).dsdlinha := '';
         pr_tab_dados_dsctit(1).vlutiliz := 0;
         pr_tab_dados_dsctit(1).qtutiliz := 0;
         pr_tab_dados_dsctit(1).cddopcao := 2;
         pr_tab_dados_dsctit(1).dtrenova := null;
         pr_tab_dados_dsctit(1).perrenov := null;
         pr_tab_dados_dsctit(1).cddlinha := 0;
         pr_tab_dados_dsctit(1).flgstlcr := null;

         -- somar a partir da craptdb e da crapcco
         OPEN cr_tdbcco(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta,
                        pr_dtmvtolt => pr_dtmvtolt);
         FETCH cr_tdbcco INTO rw_tdbcco;

         IF cr_tdbcco%FOUND THEN
           pr_tab_dados_dsctit(1).vlutilcr := rw_tdbcco.vlutilcr;
           pr_tab_dados_dsctit(1).qtutilcr := rw_tdbcco.qtutilcr;
           pr_tab_dados_dsctit(1).vlutilsr := rw_tdbcco.vlutilsr;
           pr_tab_dados_dsctit(1).qtutilsr := rw_tdbcco.qtutilsr;
           CLOSE cr_tdbcco;
         ELSE
           pr_tab_dados_dsctit(1).vlutilcr := 0;
           pr_tab_dados_dsctit(1).qtutilcr := 0;
           pr_tab_dados_dsctit(1).vlutilsr := 0;
           pr_tab_dados_dsctit(1).qtutilsr := 0;
         END IF;

      ELSE
        -- Procura o Cadastro de Linhas de Desconto
        OPEN cr_crapldc(pr_cdcooper => pr_cdcooper,
                        pr_cddlinha => rw_craplim.cddlinha);
        FETCH cr_crapldc into rw_crapldc;

        IF cr_crapldc%NOTFOUND THEN
          pr_tab_dados_dsctit(1).dsdlinha := rw_craplim.cddlinha || ' - N�O CADASTRADA';
        ELSE
          pr_tab_dados_dsctit(1).dsdlinha := rw_crapldc.cddlinha || ' - ' || rw_crapldc.dsdlinha;
          pr_tab_dados_dsctit(1).cddlinha := rw_crapldc.cddlinha;
          pr_tab_dados_dsctit(1).flgstlcr := rw_crapldc.flgstlcr;
          CLOSE cr_crapldc;
        END IF;

        vr_aux_difdays := rw_craplim.dtfimvig - pr_dtmvtolt;
        IF vr_aux_difdays > 15 OR vr_aux_difdays < -60  THEN
           pr_tab_dados_dsctit(1).perrenov := 0;
        ELSE
           pr_tab_dados_dsctit(1).perrenov := 1;
        END IF;

        pr_tab_dados_dsctit(1).nrctrlim := rw_craplim.nrctrlim;
        pr_tab_dados_dsctit(1).dtinivig := rw_craplim.dtinivig;
        pr_tab_dados_dsctit(1).qtdiavig := rw_craplim.qtdiavig;
        pr_tab_dados_dsctit(1).vllimite := rw_craplim.vllimite;
        pr_tab_dados_dsctit(1).qtrenova := rw_craplim.qtrenova;
        pr_tab_dados_dsctit(1).cddopcao := 1;
        pr_tab_dados_dsctit(1).dtrenova := rw_craplim.dtrenova;

        -- somar a partir da craptdb e da crapcco
        OPEN cr_tdbcco(pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_dtmvtolt => pr_dtmvtolt);
        FETCH cr_tdbcco INTO rw_tdbcco;

        IF cr_tdbcco%FOUND THEN
          pr_tab_dados_dsctit(1).vlutilcr := rw_tdbcco.vlutilcr;
          pr_tab_dados_dsctit(1).qtutilcr := rw_tdbcco.qtutilcr;
          pr_tab_dados_dsctit(1).vlutilsr := rw_tdbcco.vlutilsr;
          pr_tab_dados_dsctit(1).qtutilsr := rw_tdbcco.qtutilsr;
          CLOSE cr_tdbcco;
        ELSE
          pr_tab_dados_dsctit(1).vlutilcr := 0;
          pr_tab_dados_dsctit(1).qtutilcr := 0;
          pr_tab_dados_dsctit(1).vlutilsr := 0;
          pr_tab_dados_dsctit(1).qtutilsr := 0;
        END IF;

        CLOSE cr_craplim;
      END IF;

      IF pr_flgerlog THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdoperad,
                             pr_dscritic => NULL,
                             pr_dsorigem => vr_dsorigem,
                             pr_dstransa => vr_dstransa,
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans => 1,
                             pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS')),
                             pr_idseqttl => pr_idseqttl,
                             pr_nmdatela => pr_nmdatela,
                             pr_nrdconta => pr_nrdconta,
                             pr_nrdrowid => vr_nrdrowid);
      END IF;

      pr_des_reto := vr_des_reto;
    END;
  END pc_busca_dados_dsctit;

  /* Verifica se os titulos ja estao em algum bordero (b1wgen0030.p/valida_titulos_bordero)*/
  PROCEDURE pc_valida_tit_bordero (pr_cdcooper IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                                  ,pr_cdagenci IN crawlim.cdagenci%TYPE --> C�digo da Ag�ncia
                                  ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE
                                  ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                  ,pr_idorigem IN INTEGER  --> Identificador Origem pagamento
                                  ,pr_nrdconta IN craptdb.nrdconta%TYPE DEFAULT NULL --> N�mero da Conta
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE
                                  ,pr_tpvalida IN INTEGER DEFAULT 1 --> 1: An�lise do Border� 2: Inclus�o do Border�.
                                  --------> OUT <--------
                                  ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela Erros
                                  ,pr_des_reto OUT VARCHAR2
                                  ) IS
  BEGIN
    -- .........................................................................
    --
    --  Programa : pc_valida_tit_bordero           Origem no Progress: b1wgen0030.p/valida_titulos_bordero
    --  Sistema  : Cred
    --  Sigla    :
    --  Autor    : Andrew Albuquerque (GFT)
    --  Data     : Abril/2018.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Verifica se os titulos ja estao em algum bordero - APENAS PARA AN�LISE/LIBERA��O.
    DECLARE

      -- Auxiliares para gera��o de erro.
      vr_contador PLS_INTEGER;
      vr_flgtrans BOOLEAN;

      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Cursor de verifica��o dos T�tulos.
      CURSOR cr_verifica_bordero (pr_cdcooper IN craptdb.cdcooper%TYPE,
                                  pr_nrborder IN craptdb.nrborder%TYPE) IS
        SELECT tdbold.nrborder as nrborder_dup,
               tdbold.nrdocmto as nrdocmto_dup,
               tdbold.insitapr AS insitapr_dup
          FROM cecred.craptdb tdban -- titulos de bordero que est�o no bordero que se quer analisar
         INNER JOIN cecred.craptdb tdbold -- titulos deste bordero que est�o em um bordero diferente.
            ON tdbold.cdcooper =  tdban.cdcooper
           AND tdbold.cdbandoc =  tdban.cdbandoc
           AND tdbold.nrdctabb =  tdban.nrdctabb
           AND tdbold.nrcnvcob =  tdban.nrcnvcob
           AND tdbold.nrdconta =  tdban.nrdconta
           AND tdbold.nrborder <> tdban.nrborder
           AND tdbold.nrdocmto =  tdban.nrdocmto
         INNER JOIN cecred.crapbdt bdtold
           ON bdtold.nrborder = tdbold.nrborder
           AND bdtold.cdcooper = tdbold.cdcooper
           AND bdtold.nrdconta = tdbold.nrdconta
         WHERE tdban.cdcooper = pr_cdcooper
           AND tdban.nrborder = pr_nrborder
           AND tdbold.insittit in (0,2,4)
           AND bdtold.insitbdt<>5; -- diferente de reiejtado

      rw_verifica_bordero cr_verifica_bordero%ROWTYPE;
      
    -- Selecionar os titulos do bordero ativo
    CURSOR cr_craptdb IS
      SELECT nrdocmto FROM craptdb WHERE nrborder = pr_nrborder AND cdcooper = pr_cdcooper
    ;rw_craptdb cr_craptdb%ROWTYPE;
    
    fl_nobordero INTEGER;
    BEGIN
      -- Iniciando Vari�veis.
      vr_contador := 0;
      vr_flgtrans := TRUE;
      vr_cdcritic := 0;

      --Limpar tabelas
      pr_tab_erro.DELETE;

      IF pr_tpvalida = 1 THEN

        FOR rw_verifica_bordero IN
            cr_verifica_bordero (pr_cdcooper => pr_cdcooper,
                                 pr_nrborder => pr_nrborder) LOOP
          IF rw_verifica_bordero.insitapr_dup <> 2 THEN
            OPEN cr_craptdb();
              LOOP
                FETCH cr_craptdb INTO rw_craptdb;
                EXIT WHEN cr_craptdb%NOTFOUND;
                fl_nobordero := 0;
                IF (rw_craptdb.nrdocmto = rw_verifica_bordero.nrdocmto_dup) THEN
                  fl_nobordero := 1;
                  EXIT;
                END IF;
              END LOOP;
            CLOSE cr_craptdb;
            IF fl_nobordero = 0 THEN
              vr_contador := vr_contador + 1;
              vr_dscritic := 'T�tulo ' || rw_verifica_bordero.nrdocmto_dup || ' j� incluso no Border� ' || rw_verifica_bordero.nrborder_dup;
              vr_flgtrans := FALSE;

              --Gerar Erro
              GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_nrdcaixa => pr_nrdcaixa
                                   ,pr_nrsequen => vr_contador
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic
                                   ,pr_tab_erro => pr_tab_erro);
            END IF;
          END IF;
        END LOOP;
      END IF;

      IF NOT vr_flgtrans THEN
         pr_des_reto := 'NOK';
      ELSE
         pr_des_reto := 'OK';
      END IF;

    END;
  END pc_valida_tit_bordero;

  PROCEDURE pc_calcula_restricao_bordero(pr_cdcooper    IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                                      ,pr_nrdconta      IN craptdb.nrdconta%TYPE DEFAULT NULL --> N�mero da Conta
                                      ,pr_tot_titulos   IN  NUMBER                            --> Quantidade de t�tulos do border�
                                      ,pr_tab_criticas  IN OUT typ_tab_critica
                                      ,pr_cdcritic    OUT INTEGER                 --> Codigo Critica
                                      ,pr_dscritic    OUT VARCHAR2                --> Descricao Critica
                                      ) IS
   /*-------------------------------------------------------------------------------------------------------
     Programa : pc_calcula_restricao_bordero
     Sistema  : 
     Sigla    : CRED
     Autor    : Luis Fernando (GFT) 
     Data     : Julho/2018
   
     Objetivo  : Procedure calcular se um borderio possui criticas 
   ----------------------------------------------------------------------------------------------------------*/
    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
    vr_dscritic varchar2(1000);        --> Desc. Erro
    -- Tratamento de erros
    vr_exc_erro exception;
      
    vr_index PLS_INTEGER;
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT 
        crapass.inpessoa
      FROM 
        crapass
      WHERE 
        crapass.cdcooper = pr_cdcooper
        AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
        
    vr_tab_dados_dsctit    cecred.dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052 para Cooperativa e Cobran�a Registrada
    vr_tab_cecred_dsctit   cecred.dsct0002.typ_tab_cecred_dsctit;
        
    BEGIN
      -- busca os dados do associado/cooperado para s� ent�o encontrar seus dados na tabela de par�metros
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      CLOSE cr_crapass;
      -- Busca os Par�metros para o Cooperado e Cobran�a Com Registro
      dsct0002.pc_busca_parametros_dsctit(pr_cdcooper, --pr_cdcooper,
                                            NULL, --Agencia de opera��o
                                            NULL, --N�mero do caixa
                                            NULL, --Operador
                                            NULL, -- Data da Movimenta��o
                                            NULL, --Identifica��o de origem
                                            1, --pr_tpcobran: 1-REGISTRADA / 0-N�O REGISTRADA
                                            rw_crapass.inpessoa, --1-PESSOA F�SICA / 2-PESSOA JUR�DICA
                                            vr_tab_dados_dsctit,
                                            vr_tab_cecred_dsctit,
                                            vr_cdcritic,
                                            vr_dscritic);
      IF (vr_tab_dados_dsctit(1).qtmxtbay>0 AND pr_tot_titulos > vr_tab_dados_dsctit(1).qtmxtbay) THEN
        vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
        OPEN cr_tbdsct_criticas (pr_cdcritica=>17);
        FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
        CLOSE cr_tbdsct_criticas;
        pr_tab_criticas(vr_index).cdcritica := 17; --Quantidade de t�tulos por border� excedido
        pr_tab_criticas(vr_index).dscritica := rw_tbdsct_criticas.dscritica;
        pr_tab_criticas(vr_index).tpcritica := rw_tbdsct_criticas.tpcritica;
        pr_tab_criticas(vr_index).nrdconta  := pr_nrdconta;
        pr_tab_criticas(vr_index).cdcooper  := pr_cdcooper;
        pr_tab_criticas(vr_index).dsdetres  := pr_tot_titulos;
      END IF;

      EXCEPTION
        WHEN vr_exc_erro then
             IF  nvl(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
             ELSE
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
             END IF;

        WHEN OTHERS then
             pr_cdcritic := vr_cdcritic;
             pr_dscritic := 'Erro geral na rotina pc_calcula_restricao_bordero: '||SQLERRM;
  END pc_calcula_restricao_bordero;
  
  PROCEDURE pc_calcula_restricao_titulo(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa conectada
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE   --> Conta do associado
                                        ,pr_nrdocmto IN crapcob.nrdocmto%TYPE   --> Numero do documento(Boleto)
                                        ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE   --> Numero do convenio de cobranca.
                                        ,pr_nrdctabb IN crapcob.nrdctabb%TYPE   --> Numero da conta base no banco.
                                        ,pr_cdbandoc IN crapcob.cdbandoc%TYPE   --> Codigo do banco/caixa.
                                        ,pr_tab_criticas  IN OUT typ_tab_critica
                                        ,pr_cdcritic    OUT INTEGER                 --> Codigo Critica
                                        ,pr_dscritic    OUT VARCHAR2                --> Descricao Critica
                                      ) IS
   /*-------------------------------------------------------------------------------------------------------
     Programa : pc_calcula_restricao_titulo
     Sistema  : 
     Sigla    : CRED
     Autor    : Luis Fernando (GFT) 
     Data     : Julho/2018
   
     Objetivo  : Procedure calcular se um titulo possui criticas 
   ----------------------------------------------------------------------------------------------------------*/
    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
    vr_dscritic varchar2(1000);        --> Desc. Erro
    -- Tratamento de erros
    vr_exc_erro exception;
      
   -- Cursor do titulo
    CURSOR cr_crapcob IS
      SELECT cob.flgdprot,cob.flserasa,cob.vltitulo
      FROM crapcob cob
      WHERE
        cob.flgregis > 0
        AND cob.incobran = 0
        AND cob.nrdconta = pr_nrdconta
        AND cob.cdcooper = pr_cdcooper
        AND cob.nrcnvcob = pr_nrcnvcob
        AND cob.cdbandoc = pr_cdbandoc
        AND cob.nrdctabb = pr_nrdctabb
        AND cob.nrdocmto = pr_nrdocmto
    ;
    rw_crapcob cr_crapcob%rowtype;
    vr_index PLS_INTEGER;
        
    BEGIN
      OPEN cr_crapcob;
      FETCH cr_crapcob INTO rw_crapcob;
      CLOSE cr_crapcob;
      
      IF fn_calcula_cnae(pr_cdcooper
                        ,pr_nrdconta
                        ,pr_nrdocmto
                        ,pr_nrcnvcob   
                        ,pr_nrdctabb
                        ,pr_cdbandoc) THEN
        vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
        OPEN cr_tbdsct_criticas (pr_cdcritica=>9);
        FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
        CLOSE cr_tbdsct_criticas;
        pr_tab_criticas(vr_index).cdcritica := 9; -- Valor M�ximo Permitido por CNAE excedido
        pr_tab_criticas(vr_index).dscritica := rw_tbdsct_criticas.dscritica;
        pr_tab_criticas(vr_index).tpcritica := rw_tbdsct_criticas.tpcritica;
        pr_tab_criticas(vr_index).nrdconta  := pr_nrdconta;
        pr_tab_criticas(vr_index).cdcooper  := pr_cdcooper;
        pr_tab_criticas(vr_index).dsdetres  := to_char(rw_crapcob.vltitulo,'fm999g999g990d00', 'NLS_NUMERIC_CHARACTERS = '',.''');
        pr_tab_criticas(vr_index).cdbandoc  := pr_cdbandoc;
        pr_tab_criticas(vr_index).nrdctabb  := pr_nrdctabb;
        pr_tab_criticas(vr_index).nrcnvcob  := pr_nrcnvcob;
        pr_tab_criticas(vr_index).nrdocmto  := pr_nrdocmto;
      END IF;
      /*Verifica se o t�tulo  possui instru��o de protesto e/ou negativa��o*/
      IF (rw_crapcob.flgdprot =0 AND rw_crapcob.flserasa =0) THEN
        vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
        OPEN cr_tbdsct_criticas (pr_cdcritica=>10);
        FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
        CLOSE cr_tbdsct_criticas;
        pr_tab_criticas(vr_index).cdcritica := 10; --Tit. n�o possui instr. de protesto e/ou negativa��o
        pr_tab_criticas(vr_index).dscritica := rw_tbdsct_criticas.dscritica;
        pr_tab_criticas(vr_index).tpcritica := rw_tbdsct_criticas.tpcritica;
        pr_tab_criticas(vr_index).nrdconta  := pr_nrdconta;
        pr_tab_criticas(vr_index).cdcooper  := pr_cdcooper;
        pr_tab_criticas(vr_index).dsdetres  := 1;
        pr_tab_criticas(vr_index).cdbandoc  := pr_cdbandoc;
        pr_tab_criticas(vr_index).nrdctabb  := pr_nrdctabb;
        pr_tab_criticas(vr_index).nrcnvcob  := pr_nrcnvcob;
        pr_tab_criticas(vr_index).nrdocmto  := pr_nrdocmto;
      END IF;
      
      EXCEPTION
        WHEN vr_exc_erro then
             IF  nvl(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
             ELSE
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
             END IF;

        WHEN OTHERS then
             pr_cdcritic := vr_cdcritic;
             pr_dscritic := 'Erro geral na rotina pc_calcula_restricao_titulo: '||SQLERRM;
  END pc_calcula_restricao_titulo;
  
  PROCEDURE pc_calcula_restricao_cedente(pr_cdcooper    IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                                      ,pr_nrdconta      IN craptdb.nrdconta%TYPE DEFAULT NULL --> N�mero da Conta
                                      ,pr_cdagenci IN crawlim.cdagenci%TYPE --> C�digo da Ag�ncia
                                      ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE
                                      ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                                      ,pr_nmdatela IN VARCHAR2      --> Nome da tela
                                      ,pr_idorigem IN INTEGER  --> Identificador Origem pagamento
                                      ,pr_idseqttl IN INTEGER       --> idseqttl
                                      ,pr_tab_criticas IN OUT typ_tab_critica
                                      ,pr_cdcritic    OUT INTEGER                 --> Codigo Critica
                                      ,pr_dscritic    OUT VARCHAR2                --> Descricao Critica
                                      ) IS
   /*-------------------------------------------------------------------------------------------------------
     Programa : pc_calcula_restricao_cedente
     Sistema  : 
     Sigla    : CRED
     Autor    : Luis Fernando (GFT) 
     Data     : Julho/2018
   
     Objetivo  : Procedure calcular se um cedente possui criticas na geracao de borderos
   ----------------------------------------------------------------------------------------------------------*/
    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
    vr_dscritic varchar2(1000);        --> Desc. Erro
    -- Tratamento de erros
    vr_exc_erro exception;
      
    vr_index PLS_INTEGER;
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT 
        crapass.inpessoa
      FROM 
        crapass
      WHERE 
        crapass.cdcooper = pr_cdcooper
        AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
        
    -- cursor para totaliza��es de status dos t�tulos por cooperado e conta
    CURSOR cr_tdbcob_status (pr_cdcooper IN craptdb.cdcooper%TYPE
                            ,pr_nrdconta IN craptdb.nrdconta%TYPE) IS
      SELECT SUM(DECODE(tdb.insittit,2,1,0)) as qttitdsc --Analisado
            ,SUM(DECODE(tdb.insittit,3,1,0)) as naopagos --Liberado
        FROM cecred.craptdb tdb
       WHERE tdb.cdcooper = pr_cdcooper
         AND tdb.nrdconta = pr_nrdconta;
    rw_tdbcob_status cr_tdbcob_status%ROWTYPE;
    
    -- Cursor para Dados de Limite da cooperativa
    CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.vlmaxleg
            ,cop.vlmaxutl
            ,cop.vlcnsscr
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
      
    vr_tab_dados_dsctit    cecred.dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052 para Cooperativa e Cobran�a Registrada
    vr_tab_cecred_dsctit   cecred.dsct0002.typ_tab_cecred_dsctit;
        
    vr_qtprotes PLS_INTEGER := 0;
    vr_pcnaopag craptdb.vltitulo%TYPE := 0;
    vr_qttitdsc PLS_INTEGER := 0; --Analisado
    vr_naopagos PLS_INTEGER := 0; --Liberado
    -- variaveis para tratar restri��es de grupo economico
    vr_flggrupo     INTEGER;
    vr_nrdgrupo     INTEGER;
    vr_dsdrisco     VARCHAR2(2);
    vr_gergrupo     VARCHAR2(1000);
    vr_dsdrisgp     VARCHAR2(1000);
    vr_vlutiliz NUMBER;
    vr_tab_grupo    geco0001.typ_tab_crapgrp;
    vr_vlmaxleg crapcop.vlmaxleg%TYPE;
    vr_vlmaxutl crapcop.vlmaxutl%TYPE;
    vr_vlminscr crapcop.vlcnsscr%TYPE;
    
    vr_liqpagcd   NUMBER(25,2);
    vr_qtd_cedpag NUMBER(25,2);
    pr_pc_conc    NUMBER(25,2);
    vr_qtd_conc   NUMBER(25,2);
    vr_liqgeral   NUMBER(25,2);
    vr_qtd_geral  NUMBER(25,2);
    BEGIN
      -- busca os dados do associado/cooperado para s� ent�o encontrar seus dados na tabela de par�metros
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      CLOSE cr_crapass;
      -- Busca os Par�metros para o Cooperado e Cobran�a Com Registro
      dsct0002.pc_busca_parametros_dsctit(pr_cdcooper, --pr_cdcooper,
                                            NULL, --Agencia de opera��o
                                            NULL, --N�mero do caixa
                                            NULL, --Operador
                                            NULL, -- Data da Movimenta��o
                                            NULL, --Identifica��o de origem
                                            1, --pr_tpcobran: 1-REGISTRADA / 0-N�O REGISTRADA
                                            rw_crapass.inpessoa, --1-PESSOA F�SICA / 2-PESSOA JUR�DICA
                                            vr_tab_dados_dsctit,
                                            vr_tab_cecred_dsctit,
                                            vr_cdcritic,
                                            vr_dscritic);
      /*COME�A AS VALIDA��ES DO CEDENTE*/
      /* Aqui vai a critica 11,12,15,16,13 e 14*/
      /* retorna qtd. total t�tulos protestados do cedente (cooperado) */
      pc_ret_qttit_ocorrencia(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrinssac => 0 -- para o cooperado
                             ,pr_cdocorre => 9
                             ,pr_cdmotivo => 14
                             ,pr_flgtitde => FALSE --> apenas t�tulos em Border�
                             ,pr_cntqttit => vr_qtprotes);
      /* Valida Quantidade de Titulos protestados (carteira cooperado) */
      IF vr_qtprotes > vr_tab_dados_dsctit(1).qtprotes THEN
        vr_index := pr_tab_criticas.count + 1; -- pega o ultimo registro
        OPEN cr_tbdsct_criticas (pr_cdcritica=>11);
        FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
        CLOSE cr_tbdsct_criticas;
        pr_tab_criticas(vr_index).cdcritica := 11; --Quantidade de Titulos protestados (carteira cooperado)
        pr_tab_criticas(vr_index).dscritica := rw_tbdsct_criticas.dscritica;
        pr_tab_criticas(vr_index).tpcritica := rw_tbdsct_criticas.tpcritica;
        pr_tab_criticas(vr_index).nrdconta  := pr_nrdconta;
        pr_tab_criticas(vr_index).cdcooper  := pr_cdcooper;
        pr_tab_criticas(vr_index).dsdetres  := vr_qtprotes;
      END IF;
      
      -- recuperando O valor Total dos T�tulos do Border�, com COB. REGISTRADA e/ou S/ REGISTRO
      FOR rw_tdbcob_status IN cr_tdbcob_status (pr_cdcooper => pr_cdcooper,
                                                pr_nrdconta => pr_nrdconta) LOOP
        vr_qttitdsc := rw_tdbcob_status.qttitdsc+rw_tdbcob_status.naopagos; --total
        vr_naopagos := rw_tdbcob_status.naopagos; --Liberado
      END LOOP;
      IF vr_qttitdsc > 0 THEN
        vr_pcnaopag := ROUND((vr_naopagos * 100) / vr_qttitdsc,2);
      END IF;
      /* Valida Perc. de Titulos n�o Pago Beneficiario */
      IF vr_pcnaopag > vr_tab_dados_dsctit(1).pcnaopag  THEN
        vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
        OPEN cr_tbdsct_criticas (pr_cdcritica=>12);
        FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
        CLOSE cr_tbdsct_criticas;
        pr_tab_criticas(vr_index).cdcritica := 12; --Quantidade de Titulos protestados (carteira cooperado)
        pr_tab_criticas(vr_index).dscritica := rw_tbdsct_criticas.dscritica;
        pr_tab_criticas(vr_index).tpcritica := rw_tbdsct_criticas.tpcritica;
        pr_tab_criticas(vr_index).nrdconta  := pr_nrdconta;
        pr_tab_criticas(vr_index).cdcooper  := pr_cdcooper;
        pr_tab_criticas(vr_index).dsdetres  := to_char(vr_pcnaopag,'fm999g999g990d00', 'NLS_NUMERIC_CHARACTERS = '',.''');
      END IF;
      
      -- Carregar dados de Valores do Cooperado.
      FOR rw_crapcop IN cr_crapcop (pr_cdcooper => pr_cdcooper) LOOP
        vr_vlmaxleg := rw_crapcop.vlmaxleg;
        vr_vlmaxutl := rw_crapcop.vlmaxutl;
        vr_vlminscr := rw_crapcop.vlcnsscr;
      END LOOP;
      -- Verifica se tem grupo economico em formacao
      GECO0001.pc_busca_grupo_associado(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_flggrupo => vr_flggrupo
                                         ,pr_nrdgrupo => vr_nrdgrupo
                                         ,pr_gergrupo => vr_gergrupo
                                         ,pr_dsdrisgp => vr_dsdrisgp);

      --  Se conta pertence a um grupo
      IF  vr_flggrupo = 1 THEN
        geco0001.pc_calc_endivid_grupo(pr_cdcooper  => pr_cdcooper
                                        ,pr_cdagenci  => pr_cdagenci
                                        ,pr_nrdcaixa  => 0
                                        ,pr_cdoperad  => pr_cdoperad
                                        ,pr_nmdatela  => pr_nmdatela
                                        ,pr_idorigem  => 1
                                        ,pr_nrdgrupo  => vr_nrdgrupo
                                        ,pr_tpdecons  => TRUE
                                        ,pr_dsdrisco  => vr_dsdrisco
                                        ,pr_vlendivi  => vr_vlutiliz
                                        ,pr_tab_grupo => vr_tab_grupo
                                        ,pr_cdcritic  => vr_cdcritic
                                        ,pr_dscritic  => vr_dscritic);
        IF  vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      ELSE --  Se conta n�o pertence a um grupo
        gene0005.pc_saldo_utiliza(pr_cdcooper => pr_cdcooper
                                   ,pr_tpdecons    => 2
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_nrdcaixa => pr_nrdcaixa
                                   ,pr_cdoperad => pr_cdoperad
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_idseqttl => pr_idseqttl
                                   ,pr_idorigem => pr_idorigem
                                   ,pr_dsctrliq => 0
                                   ,pr_cdprogra => pr_nmdatela
                                   ,pr_tab_crapdat => rw_crapdat
                                   ,pr_inusatab    => TRUE
                                   ,pr_vlutiliz    => vr_vlutiliz
                                   ,pr_cdcritic    => vr_cdcritic
                                   ,pr_dscritic    => vr_dscritic);
        IF  vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
      IF  vr_vlmaxutl > 0 THEN
        --  Verifica se o valor � maior que o valor maximo utilizado pelo associado nos emprestimos
        IF vr_vlutiliz > vr_vlmaxutl THEN
          vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
          OPEN cr_tbdsct_criticas (pr_cdcritica=>15);
          FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
          CLOSE cr_tbdsct_criticas;
          pr_tab_criticas(vr_index).cdcritica := 15; --Quantidade de Titulos protestados (carteira cooperado)
          pr_tab_criticas(vr_index).dscritica := rw_tbdsct_criticas.dscritica;
          pr_tab_criticas(vr_index).tpcritica := rw_tbdsct_criticas.tpcritica;
          pr_tab_criticas(vr_index).nrdconta  := pr_nrdconta;
          pr_tab_criticas(vr_index).cdcooper  := pr_cdcooper;
          pr_tab_criticas(vr_index).dsdetres  := 'Utilizado R$: ' || to_char(vr_vlutiliz,'fm999g999g990d00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '. Excedido R$: ' ||
                                                  to_char((vr_vlutiliz - vr_vlmaxutl),'fm999g999g990d00', 'NLS_NUMERIC_CHARACTERS = '',.''');
        END IF;
        --  Verifica se o valor � maior que o valor legal a ser emprestado pela cooperativa
        IF vr_vlutiliz > vr_vlmaxleg THEN
          vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
          OPEN cr_tbdsct_criticas (pr_cdcritica=>16);
          FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
          CLOSE cr_tbdsct_criticas;
          pr_tab_criticas(vr_index).cdcritica := 16; --Quantidade de Titulos protestados (carteira cooperado)
          pr_tab_criticas(vr_index).dscritica := rw_tbdsct_criticas.dscritica;
          pr_tab_criticas(vr_index).tpcritica := rw_tbdsct_criticas.tpcritica;
          pr_tab_criticas(vr_index).nrdconta  := pr_nrdconta;
          pr_tab_criticas(vr_index).cdcooper  := pr_cdcooper;
          pr_tab_criticas(vr_index).dsdetres  := 'Utilizado R$: ' || to_char(vr_vlutiliz,'fm999g999g990d00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '. Excedido R$: ' ||
                                                  to_char((vr_vlutiliz - vr_vlmaxleg),'fm999g999g990d00', 'NLS_NUMERIC_CHARACTERS = '',.''');
        END IF;
      END IF;
      
      -- Faz os calculos de liquidez
      pc_calcula_liquidez(pr_cdcooper            
                           ,pr_nrdconta     
                           ,NULL
                           ,rw_crapdat.dtmvtolt - vr_tab_cecred_dsctit(1).qtmesliq*30  
                           ,rw_crapdat.dtmvtolt 
                           ,vr_tab_dados_dsctit(1).cardbtit_c
                           -- OUT --     
                           ,pr_pc_cedpag    => vr_liqpagcd
                           ,pr_qtd_cedpag   => vr_qtd_cedpag
                           ,pr_pc_conc      => pr_pc_conc
                           ,pr_qtd_conc     => vr_qtd_conc
                           ,pr_pc_geral     => vr_liqgeral
                           ,pr_qtd_geral    => vr_qtd_geral);
                           
      -- Verificando o M�nimo de Liquidez de t�tulos Geral do Cedente (Quantidade = #TAB052.qtmintgc)
      IF (vr_qtd_geral < vr_tab_dados_dsctit(1).qtmintgc) THEN -- era pctitemi
        vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
        OPEN cr_tbdsct_criticas (pr_cdcritica=>13);
        FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
        CLOSE cr_tbdsct_criticas;
        pr_tab_criticas(vr_index).cdcritica := 13; --Quantidade de Titulos protestados (carteira cooperado)
        pr_tab_criticas(vr_index).dscritica := rw_tbdsct_criticas.dscritica;
        pr_tab_criticas(vr_index).tpcritica := rw_tbdsct_criticas.tpcritica;
        pr_tab_criticas(vr_index).nrdconta  := pr_nrdconta;
        pr_tab_criticas(vr_index).cdcooper  := pr_cdcooper;
        pr_tab_criticas(vr_index).dsdetres  := (to_char(vr_qtd_geral)||'%');
      END IF;
      -- Verificando o M�nimo de Liquidez de t�tulos Geral do Cedente (Valor = #TAB052.vlmintgc)
      IF (vr_liqgeral < vr_tab_dados_dsctit(1).vlmintgc) THEN -- era pctitemi
        vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
        OPEN cr_tbdsct_criticas (pr_cdcritica=>14);
        FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
        CLOSE cr_tbdsct_criticas;
        pr_tab_criticas(vr_index).cdcritica := 14; --Quantidade de Titulos protestados (carteira cooperado)
        pr_tab_criticas(vr_index).dscritica := rw_tbdsct_criticas.dscritica;
        pr_tab_criticas(vr_index).tpcritica := rw_tbdsct_criticas.tpcritica;
        pr_tab_criticas(vr_index).nrdconta  := pr_nrdconta;
        pr_tab_criticas(vr_index).cdcooper  := pr_cdcooper;
        pr_tab_criticas(vr_index).dsdetres  := (to_char(vr_liqgeral)||'%');
      END IF;
      
      EXCEPTION
        WHEN vr_exc_erro then
             IF  nvl(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
             ELSE
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
             END IF;

        WHEN OTHERS then
             pr_cdcritic := vr_cdcritic;
             pr_dscritic := 'Erro geral na rotina pc_calcula_restricao_cedente: '||SQLERRM;
  END pc_calcula_restricao_cedente;
  
  PROCEDURE pc_calcula_restricao_pagador(pr_cdcooper    IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                                      ,pr_nrdconta      IN craptdb.nrdconta%TYPE --> N�mero da Conta
                                      ,pr_nrinssac      IN craptdb.nrinssac%TYPE --> Pagador
                                      ,pr_nrdocmto      IN crapcob.nrdocmto%TYPE   --> Numero do documento(Boleto)
                                      ,pr_nrcnvcob      IN crapcob.nrcnvcob%TYPE   --> Numero do convenio de cobranca.
                                      ,pr_nrdctabb      IN crapcob.nrdctabb%TYPE   --> Numero da conta base no banco.
                                      ,pr_cdbandoc      IN crapcob.cdbandoc%TYPE   --> Codigo do banco/caixa.
                                      ,pr_tab_criticas  IN OUT typ_tab_critica
                                      ,pr_cdcritic    OUT INTEGER                 --> Codigo Critica
                                      ,pr_dscritic    OUT VARCHAR2                --> Descricao Critica
                                      ) IS
   /*-------------------------------------------------------------------------------------------------------
     Programa : pc_calcula_restricao_pagador
     Sistema  : 
     Sigla    : CRED
     Autor    : Luis Fernando (GFT) 
     Data     : Julho/2018
   
     Objetivo  : Procedure calcular se um pagador possui criticas 
   ----------------------------------------------------------------------------------------------------------*/
    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
    vr_dscritic varchar2(1000);        --> Desc. Erro
    -- Tratamento de erros
    vr_exc_erro exception;
      
    vr_index PLS_INTEGER;
    --  Cr�ticas Pagador (Job - An�lise Di�ria)
    cursor cr_analise_pagador is 
      select *
      from   tbdsct_analise_pagador
      where  cdcooper = pr_cdcooper 
      and    nrdconta = pr_nrdconta 
    AND  nrinssac = pr_nrinssac;
    rw_analise_pagador cr_analise_pagador%rowtype;
        
    BEGIN
      --> CR�TICAS DO PAGADOR (JOB - AN�LISE PAGADOR)
      open  cr_analise_pagador;
      fetch cr_analise_pagador into rw_analise_pagador;
      close cr_analise_pagador;           

      IF rw_analise_pagador.inpossui_criticas > 0 THEN
        -- qtremessa_cartorio -> Cr�tica: Qtd Remessa em Cart�rio acima do permitido. (Ref. TAB052: qtremcrt).
        if rw_analise_pagador.qtremessa_cartorio > 0 then
          vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
          OPEN cr_tbdsct_criticas (pr_cdcritica=>1);
          FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
          CLOSE cr_tbdsct_criticas;
          pr_tab_criticas(vr_index).cdcritica := 1; --Quantidade de t�tulos por border� excedido
          pr_tab_criticas(vr_index).dscritica := rw_tbdsct_criticas.dscritica;
          pr_tab_criticas(vr_index).tpcritica := rw_tbdsct_criticas.tpcritica;
          pr_tab_criticas(vr_index).nrdconta  := pr_nrdconta;
          pr_tab_criticas(vr_index).cdcooper  := pr_cdcooper;
          pr_tab_criticas(vr_index).dsdetres  := to_char(rw_analise_pagador.qtremessa_cartorio);
          pr_tab_criticas(vr_index).cdbandoc  := pr_cdbandoc;
          pr_tab_criticas(vr_index).nrdctabb  := pr_nrdctabb;
          pr_tab_criticas(vr_index).nrcnvcob  := pr_nrcnvcob;
          pr_tab_criticas(vr_index).nrdocmto  := pr_nrdocmto;
        end if;
        -- qttit_protestados -> Cr�tica: Qtd de T�tulos Protestados acima do permitido. (Ref. TAB052: qttitprt).
        if rw_analise_pagador.qttit_protestados > 0 then
          vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
          OPEN cr_tbdsct_criticas (pr_cdcritica=>2);
          FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
          CLOSE cr_tbdsct_criticas;
          pr_tab_criticas(vr_index).cdcritica := 2; --Qtd de T�tulos Protestados acima do permitido.
          pr_tab_criticas(vr_index).dscritica := rw_tbdsct_criticas.dscritica;
          pr_tab_criticas(vr_index).tpcritica := rw_tbdsct_criticas.tpcritica;
          pr_tab_criticas(vr_index).nrdconta  := pr_nrdconta;
          pr_tab_criticas(vr_index).cdcooper  := pr_cdcooper;
          pr_tab_criticas(vr_index).dsdetres  := to_char(rw_analise_pagador.qttit_protestados);
          pr_tab_criticas(vr_index).cdbandoc  := pr_cdbandoc;
          pr_tab_criticas(vr_index).nrdctabb  := pr_nrdctabb;
          pr_tab_criticas(vr_index).nrcnvcob  := pr_nrcnvcob;
          pr_tab_criticas(vr_index).nrdocmto  := pr_nrdocmto;
        end if;
                  
        -- qttit_naopagos -> Cr�tica: Qtd de T�tulos N�o Pagos pelo Pagador acima do permitido. (Ref. TAB052: qtnaopag).
        if rw_analise_pagador.qttit_naopagos > 0 then
          vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
          OPEN cr_tbdsct_criticas (pr_cdcritica=>3);
          FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
          CLOSE cr_tbdsct_criticas;
          pr_tab_criticas(vr_index).cdcritica := 3; --Qtd de T�tulos N�o Pagos pelo Pagador acima do permitido
          pr_tab_criticas(vr_index).dscritica := rw_tbdsct_criticas.dscritica;
          pr_tab_criticas(vr_index).tpcritica := rw_tbdsct_criticas.tpcritica;
          pr_tab_criticas(vr_index).nrdconta  := pr_nrdconta;
          pr_tab_criticas(vr_index).cdcooper  := pr_cdcooper;
          pr_tab_criticas(vr_index).dsdetres  := to_char(rw_analise_pagador.qttit_naopagos);
          pr_tab_criticas(vr_index).cdbandoc  := pr_cdbandoc;
          pr_tab_criticas(vr_index).nrdctabb  := pr_nrdctabb;
          pr_tab_criticas(vr_index).nrcnvcob  := pr_nrcnvcob;
          pr_tab_criticas(vr_index).nrdocmto  := pr_nrdocmto;
        end if;
                  
        -- pemin_liquidez_qt -> Cr�tica: Perc. M�nimo de Liquidez Cedente x Pagador abaixo do permitido (Qtd. de T�tulos).  (Ref. TAB052: qttliqcp).
        if rw_analise_pagador.pemin_liquidez_qt > 0.0 then
          vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
          OPEN cr_tbdsct_criticas (pr_cdcritica=>4);
          FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
          CLOSE cr_tbdsct_criticas;
          pr_tab_criticas(vr_index).cdcritica := 4; -- Perc. M�nimo de Liquidez Cedente x Pagador abaixo do permitido (Qtd. de T�tulos)
          pr_tab_criticas(vr_index).dscritica := rw_tbdsct_criticas.dscritica;
          pr_tab_criticas(vr_index).tpcritica := rw_tbdsct_criticas.tpcritica;
          pr_tab_criticas(vr_index).nrdconta  := pr_nrdconta;
          pr_tab_criticas(vr_index).cdcooper  := pr_cdcooper;
          pr_tab_criticas(vr_index).dsdetres  := to_char(rw_analise_pagador.pemin_liquidez_qt,'fm999g999g990d00', 'NLS_NUMERIC_CHARACTERS = '',.''') ||'%';
          pr_tab_criticas(vr_index).cdbandoc  := pr_cdbandoc;
          pr_tab_criticas(vr_index).nrdctabb  := pr_nrdctabb;
          pr_tab_criticas(vr_index).nrcnvcob  := pr_nrcnvcob;
          pr_tab_criticas(vr_index).nrdocmto  := pr_nrdocmto;
        end if;
                  
        -- pemin_liquidez_vl -> Cr�tica: Perc. M�nimo de Liquidez Cedente x Pagador abaixo do permitido (Valor dos T�tulos).  (Ref. TAB052: vltliqcp).
        if rw_analise_pagador.pemin_liquidez_vl > 0.0 then
          vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
          OPEN cr_tbdsct_criticas (pr_cdcritica=>5);
          FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
          CLOSE cr_tbdsct_criticas;
          pr_tab_criticas(vr_index).cdcritica := 5; -- Perc. M�nimo de Liquidez Cedente x Pagador abaixo do permitido (Valor dos T�tulos)
          pr_tab_criticas(vr_index).dscritica := rw_tbdsct_criticas.dscritica;
          pr_tab_criticas(vr_index).tpcritica := rw_tbdsct_criticas.tpcritica;
          pr_tab_criticas(vr_index).nrdconta  := pr_nrdconta;
          pr_tab_criticas(vr_index).cdcooper  := pr_cdcooper;
          pr_tab_criticas(vr_index).dsdetres  := to_char(rw_analise_pagador.pemin_liquidez_vl,'fm999g999g990d00', 'NLS_NUMERIC_CHARACTERS = '',.''') ||'%';
          pr_tab_criticas(vr_index).cdbandoc  := pr_cdbandoc;
          pr_tab_criticas(vr_index).nrdctabb  := pr_nrdctabb;
          pr_tab_criticas(vr_index).nrcnvcob  := pr_nrcnvcob;
          pr_tab_criticas(vr_index).nrdocmto  := pr_nrdocmto;
        end if;
                 
        -- peconcentr_maxtit -> Cr�tica: Perc. Concentra��o M�xima Permitida de T�tulos excedida. (Ref. TAB052: pcmxctip).
        if rw_analise_pagador.peconcentr_maxtit > 0.0 then
          vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
          OPEN cr_tbdsct_criticas (pr_cdcritica=>6);
          FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
          CLOSE cr_tbdsct_criticas;
          pr_tab_criticas(vr_index).cdcritica := 6; -- Perc. Concentra��o M�xima Permitida de T�tulos excedida
          pr_tab_criticas(vr_index).dscritica := rw_tbdsct_criticas.dscritica;
          pr_tab_criticas(vr_index).tpcritica := rw_tbdsct_criticas.tpcritica;
          pr_tab_criticas(vr_index).nrdconta  := pr_nrdconta;
          pr_tab_criticas(vr_index).cdcooper  := pr_cdcooper;
          pr_tab_criticas(vr_index).dsdetres  := to_char(rw_analise_pagador.peconcentr_maxtit,'fm999g999g990d00', 'NLS_NUMERIC_CHARACTERS = '',.''') ||'%';
          pr_tab_criticas(vr_index).cdbandoc  := pr_cdbandoc;
          pr_tab_criticas(vr_index).nrdctabb  := pr_nrdctabb;
          pr_tab_criticas(vr_index).nrcnvcob  := pr_nrcnvcob;
          pr_tab_criticas(vr_index).nrdocmto  := pr_nrdocmto;
        end if;
                  
        -- inemitente_conjsoc -> Cr�tica: Emitente � C�njuge/S�cio do Pagador (0 = N�o / 1 = Sim). (Ref. TAB052: flemipar).
        if rw_analise_pagador.inemitente_conjsoc > 0 then
          vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
          OPEN cr_tbdsct_criticas (pr_cdcritica=>7);
          FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
          CLOSE cr_tbdsct_criticas;
          pr_tab_criticas(vr_index).cdcritica := 7; -- Emitente � C�njuge/S�cio do Pagador
          pr_tab_criticas(vr_index).dscritica := rw_tbdsct_criticas.dscritica;
          pr_tab_criticas(vr_index).tpcritica := rw_tbdsct_criticas.tpcritica;
          pr_tab_criticas(vr_index).nrdconta  := pr_nrdconta;
          pr_tab_criticas(vr_index).cdcooper  := pr_cdcooper;
          pr_tab_criticas(vr_index).dsdetres  := to_char(rw_analise_pagador.inemitente_conjsoc);
          pr_tab_criticas(vr_index).cdbandoc  := pr_cdbandoc;
          pr_tab_criticas(vr_index).nrdctabb  := pr_nrdctabb;
          pr_tab_criticas(vr_index).nrcnvcob  := pr_nrcnvcob;
          pr_tab_criticas(vr_index).nrdocmto  := pr_nrdocmto;
        end if;
                  
        -- inpossui_titdesc -> Cr�tica: Cooperado possui T�tulos Descontados na Conta deste Pagador  (0 = N�o / 1 = Sim). (Ref. TAB052: flpdctcp).
        if rw_analise_pagador.inpossui_titdesc > 0 then
          vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
          OPEN cr_tbdsct_criticas (pr_cdcritica=>8);
          FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
          CLOSE cr_tbdsct_criticas;
          pr_tab_criticas(vr_index).cdcritica := 8; -- Cooperado possui T�tulos Descontados na Conta deste Pagador
          pr_tab_criticas(vr_index).dscritica := rw_tbdsct_criticas.dscritica;
          pr_tab_criticas(vr_index).tpcritica := rw_tbdsct_criticas.tpcritica;
          pr_tab_criticas(vr_index).nrdconta  := pr_nrdconta;
          pr_tab_criticas(vr_index).cdcooper  := pr_cdcooper;
          pr_tab_criticas(vr_index).dsdetres  := to_char(rw_analise_pagador.inpossui_titdesc);
          pr_tab_criticas(vr_index).cdbandoc  := pr_cdbandoc;
          pr_tab_criticas(vr_index).nrdctabb  := pr_nrdctabb;
          pr_tab_criticas(vr_index).nrcnvcob  := pr_nrcnvcob;
          pr_tab_criticas(vr_index).nrdocmto  := pr_nrdocmto;
        end if;
      END IF;  
      EXCEPTION
        WHEN vr_exc_erro then
             IF  nvl(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
             ELSE
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
             END IF;

        WHEN OTHERS then
             pr_cdcritic := vr_cdcritic;
             pr_dscritic := 'Erro geral na rotina pc_calcula_restricao_pagador: '||SQLERRM;
  END pc_calcula_restricao_pagador;
  
  /* Procura estri�oes de um border� e cria entradas na  tabela de restri��es quando encontradas (b1wgen0030.p/analisar-titulo-bordero)*/
  PROCEDURE pc_restricoes_tit_bordero (pr_cdcooper IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                                      ,pr_cdagenci IN crawlim.cdagenci%TYPE --> C�digo da Ag�ncia
                                      ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE
                                      ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                                      ,pr_nmdatela IN VARCHAR2      --> Nome da tela
                                      ,pr_idorigem IN INTEGER  --> Identificador Origem pagamento
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                      ,pr_nrdconta IN craptdb.nrdconta%TYPE DEFAULT NULL --> N�mero da Conta
                                      ,pr_idseqttl IN INTEGER       --> idseqttl
                                      ,pr_nrborder IN crapbdt.nrborder%TYPE
                                      ,pr_flgerlog IN BOOLEAN       --> identificador se deve gerar log
                                      --------> OUT <--------
                                      ,pr_indrestr IN OUT PLS_INTEGER--> Indica se Gerou Restri��o (0 - Sem Restri��o / 1 - Com restri��o)
                                      ,pr_flsnhcoo OUT BOOLEAN
                                      ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela Erros
                                      ,pr_cdcritic    OUT INTEGER                 --> Codigo Critica
                                      ,pr_dscritic    OUT VARCHAR2                --> Descricao Critica
                                      ) IS
  BEGIN
    -- .........................................................................
    --
    --  Programa : pc_restricoes_tit_bordero           Origem no Progress: b1wgen0030.p/analisar-titulo-bordero
    --  Sistema  : Cred
    --  Sigla    :
    --  Autor    : Andrew Albuquerque (GFT)
    --  Data     : Abril/2018.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procura restri�oes de um border� e cria entradas na  tabela de restri��es quando encontradas
    --   Altera��es: 09/07/2018 - Vitor Shimada Assanuma - Altera��o das mensagens de cr�ticas e inser��o de 2 cr�ticas 
    --                                                   novas de minimo de liquidez
                     
    DECLARE
      -- Auxiliares para gera��o de erro.
      vr_contador PLS_INTEGER;

      -- Informa��es de data do sistema
      rw_crapdat     btch0001.rw_crapdat%TYPE; --> Tipo de registro de datas

      -- Tratamento de erros
      vr_exc_erro exception;

      -- Erro em chamadas
      vr_des_reto VARCHAR2(3) DEFAULT 'OK';

      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
      vr_dscritic varchar2(1000);        --> Desc. Erro


      vr_tab_dados_dsctit_cr cecred.dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052 para Cooperativa e Cobran�a Registrada
      vr_tab_dados_dsctit_sr cecred.dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052 para Cooperativa e Cobran�a Sem Registro
      vr_tab_cecred_dsctit cecred.dsct0002.typ_tab_cecred_dsctit; -- retorno da TAB052 para CECRED

      -- Descri��o da origem da chamada
      vr_dsorigem VARCHAR2(10);
      -- Descri��o da transa��o
      vr_dstransa VARCHAR2(100);
      -- rowid tabela de log
      vr_nrdrowid ROWID;
      
      vr_tab_criticas typ_tab_critica;
      vr_tot_titulos  NUMBER := 0;
      vr_index PLS_INTEGER;
      -- Cursor para o Loop Principal em T�tulos do border� e Dados de Cobran�a
      CURSOR cr_craptdb_cob (pr_cdcooper IN craptdb.cdcooper%TYPE,
                             pr_nrdconta IN craptdb.nrdconta%TYPE,
                             pr_nrborder IN craptdb.nrborder%TYPE) IS
        SELECT tdb.cdcooper
              ,tdb.nrborder
              ,tdb.nrdconta
              ,tdb.nrinssac
              ,tdb.nrdocmto
              ,tdb.nrcnvcob
              ,tdb.nrdctabb
              ,tdb.cdbandoc
              ,tdb.vltitulo
              ,tdb.dtvencto
              ,cob.incobran
              ,cob.flgregis
              ,cob.flgdprot
              ,cob.flserasa
          FROM cecred.craptdb tdb
          LEFT JOIN cecred.crapcob cob
            ON cob.cdcooper = tdb.cdcooper
           AND cob.cdbandoc = tdb.cdbandoc
           AND cob.nrdctabb = tdb.nrdctabb
           AND cob.nrcnvcob = tdb.nrcnvcob
           AND cob.nrdconta = tdb.nrdconta
           AND cob.nrdocmto = tdb.nrdocmto
         WHERE tdb.cdcooper = pr_cdcooper -- 14
           AND tdb.nrborder = pr_nrborder -- 22719 -- 23175
           AND tdb.nrdconta = pr_nrdconta -- 7528  --7250
         ORDER BY tdb.nrseqdig;
      rw_craptdb_cob cr_craptdb_cob%ROWTYPE;

    vr_tab_dados_dsctit   typ_tab_desconto_titulos;
    BEGIN
      --Selecionar dados da data
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
      
      -- Se foi solicitado LOG
      IF pr_flgerlog THEN
        -- busca informa��es que ser�o aproveitas posteriormente
        vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
        vr_dstransa := 'Consultar a qtd. de T�tulos de acordo com alguma ocorrencia.';
      END IF;

      -- iniciando vari�veis
      vr_cdcritic := 0;
      vr_dscritic := '';

      --Limpar tabelas
      pr_tab_erro.DELETE;

      -- busca os dados do associado/cooperado para s� ent�o encontrar seus dados na tabela de par�metros
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;

      IF cr_crapass%FOUND THEN
        -- Busca os Par�metros para o Cooperado e Cobran�a Com Registro
        dsct0002.pc_busca_parametros_dsctit(pr_cdcooper, --pr_cdcooper,
                                            pr_cdagenci, --Agencia de opera��o
                                            pr_nrdcaixa, --N�mero do caixa
                                            pr_cdoperad, --Operador
                                            pr_dtmvtolt, -- Data da Movimenta��o
                                            pr_idorigem, --Identifica��o de origem
                                            1, --pr_tpcobran: 1-REGISTRADA / 0-N�O REGISTRADA
                                            rw_crapass.inpessoa, --1-PESSOA F�SICA / 2-PESSOA JUR�DICA
                                            vr_tab_dados_dsctit_cr,
                                            vr_tab_cecred_dsctit,
                                            vr_cdcritic,
                                            vr_dscritic);

        -- Busca os Par�metros para o Cooperado e Cobran�a Sem Registro
        dsct0002.pc_busca_parametros_dsctit(pr_cdcooper, --pr_cdcooper,
                                            pr_cdagenci, --Agencia de opera��o
                                            pr_nrdcaixa, --N�mero do caixa
                                            pr_cdoperad, --Operador
                                            pr_dtmvtolt, -- Data da Movimenta��o
                                            pr_idorigem, --Identifica��o de origem
                                            0, --pr_tpcobran: 1-REGISTRADA / 0-N�O REGISTRADA
                                            rw_crapass.inpessoa, --1-PESSOA F�SICA / 2-PESSOA JUR�DICA
                                            vr_tab_dados_dsctit_sr,
                                            vr_tab_cecred_dsctit,
                                            vr_cdcritic,
                                            vr_dscritic);
        CLOSE cr_crapass;
      ELSE
         -- se n�o achou o Cooperado, grava cr�tica, gera erro e aborta o processo.;
         vr_cdcritic := 9;
         vr_dscritic := '';
         vr_contador := vr_contador + 1;

         --Gerar Erro
         GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                              ,pr_cdagenci => pr_cdagenci
                              ,pr_nrdcaixa => pr_nrdcaixa
                              ,pr_nrsequen => vr_contador
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic
                              ,pr_tab_erro => pr_tab_erro);
         raise vr_exc_erro;
      END IF;

      -- Buscar os Dados de linha de Desconto de T�tulo, e retornar NOK se n�o encontrar
      -- ou ocorrer outro erro na busca
      pc_busca_dados_dsctit(pr_cdcooper => pr_cdcooper,
                            pr_cdoperad => pr_cdoperad,
                            pr_dtmvtolt => pr_dtmvtolt,
                            pr_idorigem => pr_idorigem,
                            pr_nrdconta => pr_nrdconta,
                            pr_idseqttl => pr_idseqttl,
                            pr_nmdatela => pr_nmdatela,
                            pr_flgerlog => pr_flgerlog,
                            pr_cdcritic => vr_cdcritic,
                            pr_dscritic => vr_dscritic,
                            pr_tab_erro => pr_tab_erro,
                            pr_tab_dados_dsctit => vr_tab_dados_dsctit,
                            pr_des_reto => vr_des_reto);

      IF vr_des_reto = 'NOK' THEN
         RAISE vr_exc_erro;
      END IF;

      -- Elimina todas as restri�oes do border� que est� sendo analisado
      BEGIN
        DELETE FROM crapabt abt
         WHERE abt.cdcooper = pr_cdcooper
           AND abt.nrborder = pr_nrborder;
      END;
      -- Gerando as Restri��es no Border� por Status do Pagamento de Cobra��o para T�tulo desse Border�, se houver.
      FOR rw_craptdb_cob IN cr_craptdb_cob (pr_cdcooper => pr_cdcooper,
                                            pr_nrdconta => pr_nrdconta,
                                            pr_nrborder => pr_nrborder) LOOP
        vr_tot_titulos := vr_tot_titulos + 1;
        
        pc_calcula_restricao_titulo(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdocmto => rw_craptdb_cob.nrdocmto
                          ,pr_nrcnvcob => rw_craptdb_cob.nrcnvcob
                          ,pr_nrdctabb => rw_craptdb_cob.nrdctabb
                          ,pr_cdbandoc => rw_craptdb_cob.cdbandoc
                          ,pr_tab_criticas => vr_tab_criticas
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);
        /* Gera Erro e Grava Log */
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          --Gerar Erro
          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_nrdcaixa => pr_nrdcaixa
                                ,pr_nrsequen => 1
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic
                                ,pr_tab_erro => pr_tab_erro);
          -- Se Solicitou Gera��o de LOG
          IF pr_flgerlog THEN
            -- Chamar gera��o de LOG
            gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                 ,pr_cdoperad => pr_cdoperad
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_dsorigem => vr_dsorigem
                                 ,pr_dstransa => vr_dstransa
                                 ,pr_dttransa => TRUNC(SYSDATE)
                                 ,pr_flgtrans => 0 --> FALSE
                                 ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                                 ,pr_idseqttl => pr_idseqttl
                                 ,pr_nmdatela => pr_nmdatela
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrdrowid => vr_nrdrowid);
          END IF;
        END IF;
      END LOOP; -- fim da gera��o das restri��es
      
      pc_calcula_restricao_bordero(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_tot_titulos => vr_tot_titulos
                                      ,pr_tab_criticas=>vr_tab_criticas
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic
                                      );
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_erro;
      END IF;
          
      pc_calcula_restricao_cedente(pr_cdcooper=>pr_cdcooper
                                      ,pr_nrdconta=>pr_nrdconta
                                      ,pr_cdagenci=>pr_cdagenci
                                      ,pr_nrdcaixa=>pr_nrdcaixa
                                      ,pr_cdoperad=>pr_cdoperad
                                      ,pr_nmdatela=>pr_nmdatela
                                      ,pr_idorigem=>pr_idorigem
                                      ,pr_idseqttl=>pr_idseqttl
                                      ,pr_tab_criticas=>vr_tab_criticas
                                      ,pr_cdcritic=>vr_cdcritic
                                      ,pr_dscritic=>vr_dscritic
                                      );
                                      
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_erro;
      END IF;
      IF (vr_tab_criticas.count > 0) THEN
        pr_indrestr := 1;
        vr_index := vr_tab_criticas.first;
        WHILE vr_index IS NOT NULL LOOP  
          pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_dsrestri => ''
                                       ,pr_nrseqdig => vr_tab_criticas(vr_index).cdcritica
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_cdbandoc => vr_tab_criticas(vr_index).cdbandoc
                                       ,pr_nrdctabb => vr_tab_criticas(vr_index).nrdctabb
                                       ,pr_nrcnvcob => vr_tab_criticas(vr_index).nrcnvcob
                                       ,pr_nrdocmto => vr_tab_criticas(vr_index).nrdocmto
                                       ,pr_flaprcoo => 1
                                       ,pr_dsdetres => vr_tab_criticas(vr_index).dsdetres
                                       ,pr_dscritic => vr_dscritic);
            IF  TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          vr_index := vr_tab_criticas.next(vr_index);
        END LOOP;
      END IF;
  EXCEPTION
     when vr_exc_erro then
          if  nvl(vr_cdcritic,0) <> 0 and trim(vr_dscritic) is null then
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          else
              pr_cdcritic := nvl(vr_cdcritic,0);
              pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
          end if;
    when others then
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := replace(replace('Erro pc_restricoes_tit_bordero: ' || sqlerrm, chr(13)),chr(10));
    END;

  END pc_restricoes_tit_bordero;

  PROCEDURE pc_envia_esteira (pr_cdcooper IN crapabt.cdcooper%TYPE
                             ,pr_nrdconta IN crapabt.nrdconta%TYPE
                             ,pr_nrborder IN crapabt.nrborder%TYPE
                             ,pr_cdagenci IN crapass.cdagenci%type --> C�digo da Ag�ncia
                             ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                             ,pr_dtmvtolt IN crapbdt.dtmvtolt%TYPE
                             --------- OUT ---------
                             ,pr_cdcritic OUT INTEGER   --> Codigo Critica
                             ,pr_dscritic OUT VARCHAR2  --> Descricao Critica
                             ,pr_des_erro OUT VARCHAR2  --> Erros do processo
                             ) IS
  BEGIN
    DECLARE
      -- Vari�veis de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      vr_dsmensag varchar2(32767);
    BEGIN
              -- Busca todos os t�tulos que possuem Restri��o  E QUE N�O S�O CNAE, envia esse border� e seus t�tulos 
              -- para a esteira da IBRATAN, altera o status dos t�tulos do border� e altera o status do border� para enviado para esteira, 
              -- bem como seta seus campos de status de an�lise.
              -- carrega todos os T�tulos Desse Border�
              --Atualiza todos os t�tulos da TDB que nao est�o como REJEITADOS para em an�lise da esteira.
              UPDATE craptdb
                 SET craptdb.insitapr = 0 -- 0-Aguardando An�lise
                    ,craptdb.cdoriapr = 2 -- 2-Esteira IBRATAN
              WHERE cdcooper = pr_cdcooper
                AND nrdconta = pr_nrdconta
                AND nrborder = pr_nrborder
                AND insitapr <> 2; -- Diferente de Rejeitado 
              /*FOR rw_craptdb_restri IN
                cr_craptdb_restri (pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrborder => pr_nrborder) LOOP
                -- aproveita o loop de t�tulos para alterar o status para Enviado para Esteira IBRATAN.
                UPDATE craptdb
                   set craptdb.insitapr = 0 -- 0-Aguardando An�lise
                      ,craptdb.cdoriapr = 2 -- 2-Esteira IBRATAN
                 WHERE craptdb.rowid = rw_craptdb_restri.rowid;
              END LOOP;*/

              -- Altera o Border� setando como enviado para a mesa de checagem.
              pc_altera_status_bordero(pr_cdcooper => pr_cdcooper -- C�digo da Cooperativa
                                      ,pr_nrborder => pr_nrborder -- N�mero do Border�
                                      ,pr_nrdconta => pr_nrdconta -- N�mero da conta do cooperado
                                      ,pr_status   => 1 -- 1-Em Estudo
                                      ,pr_insitapr => 6 -- 6-Enviado Esteira
                                      ,pr_dscritic => vr_dscritic); -- Descricao Critica
              IF vr_dscritic IS NOT NULL THEN
                pr_cdcritic := 0;
                pr_dscritic := vr_dscritic;
              END IF;

              -- FAZ A CHAMADA DE ENVIO PARA A ESTEIRA.
              este0006.pc_enviar_analise_manual(pr_cdcooper  => pr_cdcooper
                                               ,pr_cdagenci => pr_cdagenci
                                               ,pr_cdoperad => pr_cdoperad
                                               ,pr_cdorigem => 1
                                               ,pr_nrdconta => pr_nrdconta
                                               ,pr_nrborder => pr_nrborder
                                               ,pr_dtmvtolt => pr_dtmvtolt
                                               ,pr_nmarquiv => null
                                               ,vr_flgdebug => 'N'
                                               ---- OUT ----
                                               ,pr_dsmensag => vr_dsmensag
                                               ,pr_cdcritic => vr_cdcritic 
                                               ,pr_dscritic => vr_dscritic
                                               ,pr_des_erro => pr_des_erro);
              if  vr_cdcritic > 0  or vr_dscritic is not null then
                  pr_cdcritic := vr_cdcritic;
                  pr_dscritic := vr_dscritic;
              end if;
    END;
  END pc_envia_esteira;
      

  PROCEDURE pc_efetua_analise_bordero (pr_cdcooper IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                                      ,pr_cdagenci IN crapass.cdagenci%type --> C�digo da Ag�ncia
                                      ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Numero Caixa
                                      ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                                      ,pr_nmdatela IN craplgm.nmdatela%TYPE --> Nome da tela.
                                      ,pr_idorigem IN VARCHAR2              --> Identificador Origem pagamento
                                      ,pr_nrdconta IN craptdb.nrdconta%TYPE --> N�mero da Conta
                                      ,pr_idseqttl IN INTEGER               --> idseqttl
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                      ,pr_dtmvtopr IN crapdat.dtmvtolt%TYPE --> Proxima data de movimento.
                                      ,pr_inproces IN crapdat.inproces%TYPE --> Indicador processo
                                      ,pr_nrborder IN crapbdt.nrborder%TYPE --> N�mero do Bordero
                                      ,pr_inrotina IN INTEGER DEFAULT 0     --> Indica o tipo de an�lise (0-APENAS IMPEDITIVOS / 1-IMPEDITIVOS+RESTRI��ES COM APROVA��O DE AN�LISE)
                                      ,pr_flgerlog IN BOOLEAN               --> identificador se deve gerar log
                                      ,pr_insborde IN INTEGER DEFAULT 0     --> Indica se a analise esta sendo feito na inser��o apenas para aprovar automatico
                                      --------> OUT <--------
                                      ,pr_indrestr OUT PLS_INTEGER          --> Indica se Gerou Restri��o (0 - Sem Restri��o / 1 - Com restri��o)
                                      ,pr_ind_inpeditivo OUT PLS_INTEGER          --> Indica se o Resultado � Impeditivo para Realizar Libera��o. (0 - Sem Impedimentos / 1 - Com Impedimentos)
                                      ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela Erros
                                      ,pr_tab_retorno_analise OUT typ_tab_retorno_analise --> Detalhes Finais da Analise do Bordero.
                                      ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                      ,pr_dscritic OUT VARCHAR2             --> Descri�ao da cr�tica
                                      ) IS
  BEGIN
   /*---------------------------------------------------------------------------------------------------------------------
      Programa : pc_efetua_analise_bordero_web
      Sistema  : Cred
      Sigla    :
      Autor    : Andrew Albuquerque (GFT)
      Data     : Abril/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Procedure que que efetua a an�lise do Border�.
      
                  27/04/2018 - Andrew Albuquerque (GFT) - Altera��es para contemplar Mesa de Checagem e Esteira IBRATAN

    ---------------------------------------------------------------------------------------------------------------------*/
    DECLARE

      -- Vari�veis de Uso Local
      vr_dsorigem VARCHAR2(40)  DEFAULT NULL; --> Descri��o da Origem
      vr_dstransa VARCHAR2(100) DEFAULT NULL; --> Descri��o da trasa�ao para log
      vr_dtiniiof DATE;
      vr_dtfimiof DATE;
      vr_txccdiof NUMBER;
      vr_dsoperac VARCHAR2(1000);

      vr_flsnhcoo BOOLEAN;

      vr_indrestr PLS_INTEGER;

      -- Tratamento de erros
      vr_exc_erro exception;
      vr_des_reto VARCHAR2(3) DEFAULT 'OK';
      
      vr_des_erro varchar2(3);

      --Tabela erro
      vr_tab_erro GENE0001.typ_tab_erro;

      -- rowid tabela de log
      vr_nrdrowid ROWID;

      -- Vari�veis de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      
      vr_em_contingencia_ibratan boolean;
      
      
      --============== CURSORES ==================
      -- Cursor para o Loop Principal em T�tulos do border� e Dados de Cobran�a Para valida��es Restritivas
      CURSOR cr_craptdbcob (pr_cdcooper IN craptdb.cdcooper%TYPE,
                            pr_nrdconta IN craptdb.nrdconta%TYPE,
                            pr_nrborder IN craptdb.nrborder%TYPE) IS
        SELECT tdb.cdcooper
              ,tdb.nrborder
              ,tdb.nrdconta
              ,tdb.nrinssac
              ,tdb.nrdocmto
              ,tdb.nrcnvcob
              ,tdb.nrdctabb
              ,tdb.cdbandoc
              ,tdb.vltitulo
              ,tdb.dtvencto
              ,cob.incobran
              ,cob.flgregis
          FROM cecred.craptdb tdb
          LEFT JOIN cecred.crapcob cob
            ON cob.cdcooper = tdb.cdcooper
           AND cob.cdbandoc = tdb.cdbandoc
           AND cob.nrdctabb = tdb.nrdctabb
           AND cob.nrcnvcob = tdb.nrcnvcob
           AND cob.nrdconta = tdb.nrdconta
           AND cob.nrdocmto = tdb.nrdocmto
         WHERE tdb.cdcooper = pr_cdcooper
           AND tdb.nrborder = pr_nrborder
           AND tdb.nrdconta = pr_nrdconta
         ORDER BY tdb.nrseqdig;
      rw_craptdbcob cr_craptdbcob%ROWTYPE;      
      
       --     Selecionar bordero titulo
      CURSOR cr_crapbdt IS
      SELECT crapbdt.cdcooper
             ,crapbdt.nrborder
             ,crapbdt.nrdconta
             ,crapbdt.insitbdt
             ,crapbdt.insitapr
             ,crapbdt.dtenvmch
      FROM   crapbdt
      WHERE  crapbdt.cdcooper = pr_cdcooper
        AND    crapbdt.nrborder = pr_nrborder;
      rw_crapbdt cr_crapbdt%ROWTYPE;   
    
    /*Carrega as criticas do border por titulo*/  
    CURSOR cr_analise_pagador (pr_nrinssac crapsab.nrinssac%TYPE) IS
        SELECT
          inpossui_criticas
        FROM 
          tbdsct_analise_pagador
        WHERE
          cdcooper = pr_cdcooper
          AND nrdconta = pr_nrdconta
          AND nrinssac = pr_nrinssac
        ;
      rw_analise_pagador cr_analise_pagador%ROWTYPE;
      
    /*Carrega as criticas do border*/
    CURSOR cr_check_crapabt IS
      SELECT 
        COUNT(1) AS fl_critica_abt
      FROM 
        crapabt abt
        INNER JOIN tbdsct_criticas cri ON cri.cdcritica=abt.nrseqdig
      WHERE
        abt.cdcooper = pr_cdcooper
        AND abt.nrdconta = pr_nrdconta
        AND abt.nrborder = pr_nrborder
        AND abt.nrdocmto = 0
        AND abt.cdbandoc = 0
        AND abt.nrcnvcob = 0
        AND cri.tpcritica > 0 
    ;
    rw_check_crapabt cr_check_crapabt%ROWTYPE;
    
    CURSOR cr_check_craptdb IS
      SELECT 
        tdb.ROWID AS id,
        (SELECT 
           COUNT(1) 
         FROM 
           crapabt abt 
           INNER JOIN tbdsct_criticas cri ON cri.cdcritica=abt.nrseqdig
         WHERE 
           abt.cdcooper = tdb.cdcooper 
           AND abt.nrborder=tdb.nrborder 
           AND ((abt.nrdconta = tdb.nrdconta 
                   AND abt.nrdocmto=tdb.nrdocmto 
                   AND abt.cdbandoc = tdb.cdbandoc 
                   AND abt.nrcnvcob = tdb.nrcnvcob)
                 OR cri.tpcritica IN (4,2)
                )
           AND cri.tpcritica > 0 
         ) AS fl_critica_abt,
         (SELECT 
            COUNT(1) 
          FROM 
            tbdsct_analise_pagador dap 
          WHERE 
            dap.cdcooper = tdb.cdcooper 
            AND dap.nrdconta = tdb.nrdconta 
            AND dap.nrinssac = tdb.nrinssac 
            AND dap.INPOSSUI_CRITICAS = 1
          ) AS fl_critica_pag
      FROM 
        craptdb tdb
      WHERE
        tdb.cdcooper = pr_cdcooper
        AND tdb.nrdconta = pr_nrdconta
        AND tdb.nrborder = pr_nrborder
    ;
    rw_check_craptdb cr_check_craptdb%ROWTYPE;
    BEGIN
      --Iniciar vari�veis e Par�metros de Retorno
      pr_ind_inpeditivo := 0;
      vr_des_reto := 'OK';
      vr_indrestr := 0;

      --Seta as vari�veis de Descri��o de Origem e descri��o de Transa��o se For gerar Log
      IF pr_flgerlog THEN
        vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
        vr_dstransa := 'Analisar o Border� ' || pr_nrborder || ' de Desconto de T�tulo.';
      END IF;

      --Limpar tabelas
      pr_tab_erro.DELETE;
      
      -- Verifica��es Impeditivas Para T�tulos
      FOR rw_craptdbcob IN cr_craptdbcob (pr_cdcooper => pr_cdcooper,
                                          pr_nrdconta => pr_nrdconta,
                                          pr_nrborder => pr_nrborder) LOOP
        IF rw_craptdbcob.dtvencto <= pr_dtmvtolt THEN
          vr_dscritic := 'H� titulos com data de vencimento igual ou inferior a data do movimento.';
          RAISE vr_exc_erro;
        END IF;

        IF rw_craptdbcob.incobran = 5 THEN
          -- Se o T�tulo j� foi pago por COBRAN�A.
          vr_dscritic := 'H� t�tulos j� pago no Border�.';
          raise vr_exc_erro;
        END IF;

        IF rw_craptdbcob.incobran = 3 THEN
          -- Se o T�tulo j� foi baixado por COBRAN�A.
          vr_dscritic := 'H� T�tulo j� baixado no Border�.';
          raise vr_exc_erro;
        END IF;
        
        /*Verifica se houve restri��es no job di�rio*/
        OPEN cr_analise_pagador (pr_nrinssac=>rw_craptdbcob.nrinssac);
        FETCH cr_analise_pagador INTO rw_analise_pagador;
        IF (rw_analise_pagador.inpossui_criticas=1) THEN
          vr_indrestr := 1;
          pr_indrestr := 1;
        END IF;
        CLOSE cr_analise_pagador;
      END LOOP;
      
      --Verifica se os T�tulos est�o em algum outro bordero
      pc_valida_tit_bordero(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_cdoperad => pr_cdoperad
                           ,pr_dtmvtolt => pr_dtmvtolt
                           ,pr_idorigem => pr_idorigem
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrborder => pr_nrborder
                           ,pr_tpvalida => 1
                           ,pr_tab_erro => pr_tab_erro
                           ,pr_des_reto => vr_des_reto);

      -- Se o T�tulo j� est� em um Border�, Levanta a Exce��o (Impeditivo)
      IF vr_des_reto  <> 'OK' THEN
        --Verifica se Foi Erro de Execu��o ou se o T�tulo Estava mesmo em Outro Border�
        IF (vr_tab_erro.COUNT = 0 AND vr_dscritic IS NOT NULL) THEN
          --Se o Erro foi de Execu��o
          vr_dscritic := 'N�o foi poss�vel validar os t�tulos do Border�.';
        ELSE
          --T�tulos Estavam em Outro Bordero
          vr_dscritic := 'O Cooperado j� recebeu esse T�tulo em um outro Border�';
        END IF;
        RAISE vr_exc_erro;
      END IF;

      -- Busca informacoes de IOF
      GENE0005.pc_busca_iof (pr_cdcooper  => pr_cdcooper
                            ,pr_dtmvtolt  => pr_dtmvtolt
                            ,pr_dtiniiof  => vr_dtiniiof
                            ,pr_dtfimiof  => vr_dtfimiof
                            ,pr_txccdiof  => vr_txccdiof
                            ,pr_cdcritic  => vr_cdcritic
                            ,pr_dscritic  => vr_dscritic);

      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_erro; -- Internamente retorna a Critica 915 - Falta tabela de controle do IOF., semelhante a mensagem tratada do Progress.
      END IF;

      -- Verifica se Existe Registro de Contrato de Limite para o Cooperado e Conta.
      OPEN cr_craplim (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta);

      FETCH cr_craplim INTO rw_craplim;
      -- Se N�O encontrar registro DE LIMITE - Raise Excess�o (IMPEDITIVO)
      IF cr_craplim%NOTFOUND THEN
        vr_dscritic := 'Registro de limites n�o encontrado.';
        CLOSE cr_craplim;
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craplim;
      END IF;

      -- Verifica se Existe o Associado E Realiza as Valida��es sobre o Associado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;

      IF cr_crapass%NOTFOUND THEN
        vr_cdcritic := 9;
        vr_dscritic := '';
        RAISE vr_exc_erro;
      ELSE
        -- Monta a mensagem da operacao para envio no e-mail
        vr_dsoperac := 'Tentativa de liberar/pr�-analisar os border�s ' ||
                       'de descontos de titulos na conta ' || rw_crapass.nrdconta ||
                       ' - CPF/CNPJ ' || GENE0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc,rw_crapass.inpessoa) || '.';
        -- Verificar se a conta esta no cadastro restritivo, Se estiver, sera enviado um e-mail informando a situacao
        CADA0004.pc_alerta_fraude (pr_cdcooper => pr_cdcooper         --> Cooperativa
                                  ,pr_cdagenci => pr_cdagenci         --> PA
                                  ,pr_nrdcaixa => pr_nrdcaixa         --> Nr. do caixa
                                  ,pr_cdoperad => pr_cdoperad         --> Cod. operador
                                  ,pr_nmdatela => pr_nmdatela         --> Nome da tela
                                  ,pr_dtmvtolt => pr_dtmvtolt         --> Data de movimento
                                  ,pr_idorigem => pr_idorigem         --> ID de origem
                                  ,pr_nrcpfcgc => rw_crapass.nrcpfcgc --> Nr. do CPF/CNPJ
                                  ,pr_nrdconta => pr_nrdconta         --> Nr. da conta
                                  ,pr_idseqttl => pr_idseqttl         --> Id de sequencia do titular
                                  ,pr_bloqueia => 1                   --> Flag Bloqueia operacao
                                  ,pr_cdoperac => 5                   --> Cod da operacao
                                  ,pr_dsoperac => vr_dsoperac         --> Desc. da operacao
                                  ,pr_cdcritic => vr_cdcritic         --> Cod. da critica
                                  ,pr_dscritic => vr_dscritic         --> Desc. da critica
                                  ,pr_des_erro => vr_des_reto);       --> Retorno de erro  OK/NOK
        CLOSE cr_crapass;
        -- Se retornou erro
        IF vr_des_reto <> 'OK' THEN
          vr_cdcritic := 0;
          vr_dscritic := vr_dscritic ||' - N�o foi poss�vel verificar o cadastro restritivo.';
          RAISE vr_exc_erro;
        END IF;
      END IF;
        
      -- IN�CIO DA GERA��O DE RESTRI��ES
      IF pr_inrotina = 1 THEN -- (EXECUTAR APENAS QUANDO FOR: 0-APENAS IMPEDITIVOS / 1-IMPEDITIVOS+RESTRI��ES COM APROVA��O DE AN�LISE)
        -- pc_restricoes_tit_bordero
        -- Gera as Restri��es do Border� (CRAPABT)
        pc_restricoes_tit_bordero(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci =>  pr_cdagenci
                                 ,pr_nrdcaixa =>  pr_nrdcaixa
                                 ,pr_cdoperad =>  pr_cdoperad
                                 ,pr_nmdatela =>  pr_nmdatela
                                 ,pr_idorigem =>  pr_idorigem
                                 ,pr_dtmvtolt =>  pr_dtmvtolt
                                 ,pr_nrdconta =>  pr_nrdconta
                                 ,pr_idseqttl =>  pr_idseqttl
                                 ,pr_nrborder =>  pr_nrborder
                                 ,pr_flgerlog =>  pr_flgerlog
                                 ,pr_indrestr =>  vr_indrestr
                                 ,pr_flsnhcoo =>  vr_flsnhcoo
                                 ,pr_tab_erro =>  pr_tab_erro
                                 ,pr_cdcritic =>  vr_cdcritic
                                 ,pr_dscritic =>  vr_dscritic);
                                 
        IF (vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL) THEN
          raise vr_exc_erro;
        END IF;
   
        pr_indrestr := vr_indrestr;
          
        pr_tab_retorno_analise(0).cdcooper := pr_cdcooper;
        pr_tab_retorno_analise(0).nrborder := pr_nrborder;
        pr_tab_retorno_analise(0).nrdconta := pr_nrdconta;
            
        IF vr_indrestr = 0 AND pr_ind_inpeditivo = 0 THEN -- SEM RESTRI��O E SEM IMPEDITIVOS, APROVADO AUTOMATICAMENTE.
          --Verificando se Ocorreram Restri��es, para Gerar Cr�tica se Foi "Aprovado Automaticamente"
          --ou se deve verificar se vai para esteira ou mesa de checagem.
/*          pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                                     ,pr_cdoperad => pr_cdoperad
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_dsrestri => '' 
                                     ,pr_nrseqdig => 21 --Border� Aprovado Automaticamente
                                     ,pr_cdcooper => pr_cdcooper
                                     ,pr_flaprcoo => 1
                                     ,pr_dsdetres => ('Border� ' || pr_nrborder ||' Analisado Sem Restri��es.')
                                     ,pr_dscritic => vr_dscritic);*/
          pr_tab_retorno_analise(0).dssitres := 'Border� Aprovado Automaticamente.';
          
          -- ALTERO STATUS DO BORDER� PARA APROVADO AUTOMATICAMENTE.
          pc_altera_status_bordero(pr_cdcooper => pr_cdcooper
                                  ,pr_nrborder => pr_nrborder
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_status   => 2 -- estou considerando 2 como aprovado automaticamente (aprova��o de an�lise).
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_insitapr => 3
                                  ,pr_dtanabor => pr_dtmvtolt
                                  );
          IF vr_dscritic IS NOT NULL THEN
            pr_tab_retorno_analise.DELETE;
            RAISE vr_exc_erro;
          END IF;
          
          UPDATE 
              craptdb
          SET 
              craptdb.insitapr=1
          WHERE 
              craptdb.nrborder = pr_nrborder
              AND craptdb.cdcooper = pr_cdcooper
              AND craptdb.nrdconta = pr_nrdconta
              AND craptdb.insitapr = 0
          ;
 
        ELSIF vr_indrestr > 0 AND pr_insborde = 0 THEN -- SE POSSUI RESTRI��O, AVALIA SE DEVE MANDAR PARA ESTEIRA OU MESA DE CHECAGEM.
          -- Verifica se Possui Restri��o de CNAE (nrseqdig=9)
          OPEN cr_crapabt_qtde (pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrborder => pr_nrborder
                               ,pr_nrseqdig => 9); -- 9 - nrseqdig de Restri��o de CNAE
          --Posicionar no proximo registro
          FETCH cr_crapabt_qtde INTO rw_crapabt_qtde;
          -- Se encontrou, busca todos os t�tulos que possuem Restri��o de CNAE, altera seus status enviando para 
          -- a Mesa de Checagem, e altera o status do border� para enviado para mesa de checagem, bem como seta seus campos
          -- de status de an�lise.
          OPEN cr_crapbdt;
          FETCH cr_crapbdt INTO rw_crapbdt;
          IF (cr_crapabt_qtde%FOUND AND rw_crapbdt.dtenvmch IS NULL) THEN -- Possui cr�tica de CNAE E N�O passou pela mesa ainda
            -- carrega todos os T�tulos que est�o com Restri��o de CNAE (9)
            FOR rw_craptdb_restri IN
              cr_craptdb_restri (pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrborder => pr_nrborder
                                ,pr_nrseqdig => 9) LOOP
              -- aproveita o loop de t�tulos para fazer o envio para a mesa de checagem.
              UPDATE craptdb
                 set craptdb.insitapr = 0 -- 0-Aguardando An�lise
                    ,craptdb.cdoriapr = 1 -- 1-Mesa de Checagem
                    ,craptdb.flgenvmc = 1 -- 1-Enviado
                    ,craptdb.insitmch = 0 -- 0-Nao realizado
               WHERE craptdb.rowid = rw_craptdb_restri.rowid;
            END LOOP;
                
            pr_tab_retorno_analise(0).dssitres := 'Border� Enviado para Mesa de Checagem.';
            -- Altera o Border� setando como enviado para a mesa de checagem.
            pc_altera_status_bordero(pr_cdcooper => pr_cdcooper -- C�digo da Cooperativa
                                    ,pr_nrborder => pr_nrborder -- N�mero do Border�
                                    ,pr_nrdconta => pr_nrdconta -- N�mero da conta do cooperado
                                    ,pr_status   => 1 -- 1-Em Estudo
                                    ,pr_insitapr => 1 -- 1-Aguardando Checagem
                                    ,pr_dtanabor => pr_dtmvtolt -- Data da analise
                                    ,pr_dtenvmch => pr_dtmvtolt -- Data de envio para mesa de checage
                                    ,pr_dscritic => vr_dscritic); -- Descricao Critica
            IF vr_dscritic IS NOT NULL THEN
              pr_tab_retorno_analise.DELETE;
              CLOSE cr_crapabt_qtde;
              RAISE vr_exc_erro;
            END IF;
            
            -- Verifica se tem cr�ticas para o border�. Se tiver  ele n�o atualiza nenhum t�tulo
            OPEN cr_check_crapabt;
            FETCH cr_check_crapabt INTO rw_check_crapabt;
            CLOSE cr_check_crapabt;
            IF (rw_check_crapabt.fl_critica_abt=0) THEN
              -- Caso tenha criticas mas alguns titulos nao tenham, aprovar os mesmos
              OPEN cr_check_craptdb;
              LOOP
               FETCH cr_check_craptdb INTO rw_check_craptdb;
                 EXIT WHEN cr_check_craptdb%NOTFOUND;
                 IF (rw_check_craptdb.fl_critica_abt=0 AND rw_check_craptdb.fl_critica_pag=0) THEN
                   UPDATE 
                     craptdb
                   SET
                     insitapr = 1
                   WHERE
                     ROWID = rw_check_craptdb.id
                   ;
                 END IF;
              END LOOP;
              CLOSE cr_check_craptdb;
            END IF;
          ELSE -- SE EXISTEM RESTRI��ES E NENHUMA � DE CNAE (9), ENVIAR PARA A ESTEIRA, CASO A ESTEIRA N�O ESTEJA EM CONTING�NCIA.
            CLOSE cr_crapabt_qtde;
            rw_crapabt_qtde := null;

            vr_em_contingencia_ibratan := fn_contigencia_esteira(pr_cdcooper => pr_cdcooper);	
            
            -- awae 25/04/2018 - Caso esteja em conting�ncia, n�o ser� aprovado e nem enviado para esteira, e emite a mensagem de 
            --                   que est� em conting�ncia.
            IF  vr_em_contingencia_ibratan THEN -- Em Conting�ncia
              -- N�o faz a altera��o de Situa��o do Border� para "Aprovado", e retorna mensagem de conting�ncia.
/*              pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_dsrestri => 'An�lise em Conting�ncia, realize an�lise manual.'
                                         ,pr_nrseqdig => 0
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_flaprcoo => 1
                                         ,pr_dsdetres => ''
                                         ,pr_dscritic => vr_dscritic);*/
              pr_tab_retorno_analise(0).dssitres := 'An�lise em conting�ncia, realize an�lise manual.';
            ELSE -- ESTEIRA EST� EM FUNCIONAMENTO, ENVIAR 
              pc_envia_esteira (pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrborder => pr_nrborder
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_cdoperad => pr_cdoperad
                               ,pr_dtmvtolt => pr_dtmvtolt
                               --------- OUT ---------
                               ,pr_cdcritic => vr_cdcritic   --> Codigo Critica
                               ,pr_dscritic => vr_dscritic   --> Descricao Critica
                               ,pr_des_erro => vr_des_erro); --> Erros do processo
              if  vr_cdcritic > 0  or vr_dscritic is not null then
                  raise vr_exc_erro;
              else
                pr_tab_retorno_analise(0).dssitres := 'Border� Enviado para Esteira IBRATAN.';
              end if;
            END IF;
            
            -- Insere data de an�lise
            pc_altera_status_bordero(pr_cdcooper => pr_cdcooper -- C�digo da Cooperativa
                                    ,pr_nrborder => pr_nrborder -- N�mero do Border�
                                    ,pr_nrdconta => pr_nrdconta -- N�mero da conta do cooperado
                                    ,pr_dtanabor => pr_dtmvtolt -- Data da analise
                                    ,pr_dscritic => vr_dscritic); -- Descricao Critica
            IF vr_dscritic IS NOT NULL THEN
              pr_tab_retorno_analise.DELETE;
              CLOSE cr_crapabt_qtde;
              RAISE vr_exc_erro;
            END IF;
            -- Verifica se tem cr�ticas para o border�. Se tiver  ele n�o atualiza nenhum t�tulo
            OPEN cr_check_crapabt;
            FETCH cr_check_crapabt INTO rw_check_crapabt;
            CLOSE cr_check_crapabt;
            IF (rw_check_crapabt.fl_critica_abt=0) THEN
            -- Caso tenha criticas mas alguns titulos nao tenham, aprovar os mesmos
              OPEN cr_check_craptdb;
              LOOP
               FETCH cr_check_craptdb INTO rw_check_craptdb;
                 EXIT WHEN cr_check_craptdb%NOTFOUND;
                 IF (rw_check_craptdb.fl_critica_abt=0 AND rw_check_craptdb.fl_critica_pag=0) THEN
                   UPDATE 
                     craptdb
                   SET
                     insitapr = 1
                   WHERE
                     ROWID = rw_check_craptdb.id
                   ;
                 END IF;
              END LOOP;
              CLOSE cr_check_craptdb;
            END IF;
          END IF;
        END IF;
      ELSE
        pr_indrestr := vr_indrestr;
        -- Verifica se tem cr�ticas para o border�. Se tiver  ele n�o atualiza nenhum t�tulo
        OPEN cr_check_crapabt;
        FETCH cr_check_crapabt INTO rw_check_crapabt;
        CLOSE cr_check_crapabt;
        IF (rw_check_crapabt.fl_critica_abt > 0) THEN
          pr_indrestr := 1;
        END IF;
      END IF; -- FIM DA GERA��O DE RESTRI��ES
    --TRATAMENTO GERAL DE EXCE��ES DE EXECU��O DA PC_EFETUA_ANALISE_BORDERO.
    EXCEPTION
     when vr_exc_erro then
          if  nvl(vr_cdcritic,0) <> 0 and trim(vr_dscritic) is null then
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

              IF vr_tab_erro.count = 0 THEN
                GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_nrdcaixa => pr_nrdcaixa
                                     ,pr_nrsequen => 1 -- Sequencia
                                     ,pr_cdcritic => pr_cdcritic
                                     ,pr_dscritic => pr_dscritic
                                     ,pr_tab_erro => vr_tab_erro);
              END IF;
          else
              pr_cdcritic := nvl(vr_cdcritic,0);
              pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
          end if;
          pr_ind_inpeditivo := 1;

          -- Se Solicitou Gera��o de LOG
          IF pr_flgerlog THEN
            -- Chamar gera��o de LOG
            gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_dscritic => vr_dscritic
                                ,pr_dsorigem => vr_dsorigem
                                ,pr_dstransa => vr_dstransa
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => 0 --> FALSE
                                ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_nmdatela => pr_nmdatela
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);
          END IF;
    WHEN OTHERS THEN
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := replace(replace('Erro pc_efetua_analise_bordero: ' || sqlerrm, chr(13)),chr(10));
         pr_ind_inpeditivo := 1;
    END;
  END pc_efetua_analise_bordero;

  PROCEDURE pc_efetua_analise_bordero_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                          ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                           --  (OBRIGAT�RIOS E NESSA ORDEM SEMPRE)
                                          ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                          --------> OUT <--------
                                          ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                          ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                          ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                          ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                ) IS
 /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_efetua_analise_bordero_web
    Sistema  : Cred
    Sigla    :
    Autor    : Andrew Albuquerque (GFT)
    Data     : Abril/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Procedure que que efetua a an�lise e Aprova��o autom�tica do Border�.

  ---------------------------------------------------------------------------------------------------------------------*/


    /* tratamento de erro */
    vr_exc_erro exception;

    vr_tab_erro         gene0001.typ_tab_erro;

    vr_indrestr PLS_INTEGER;
    vr_ind_inpeditivo PLS_INTEGER;
    
    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);

    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
    vr_dscritic varchar2(1000);        --> Desc. Erro

    vr_tab_retorno_analise typ_tab_retorno_analise;

    -- variaveis de data
    vr_dtmvtopr crapdat.dtmvtolt%TYPE;
    vr_dtmvtolt crapdat.dtmvtolt%TYPE;

      -- rowid tabela de log
      vr_nrdrowid ROWID;

    BEGIN
      pr_nmdcampo := NULL;
      pr_des_erro := 'OK';
      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);


      --Selecionar dados da data
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se encontrar
      IF BTCH0001.cr_crapdat%FOUND THEN
        vr_dtmvtopr:= rw_crapdat.dtmvtopr;
        vr_dtmvtolt:= rw_crapdat.dtmvtolt;
      END IF;
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
      
      pc_valida_bordero(pr_cdcooper => vr_cdcooper
                       ,pr_nrborder => pr_nrborder
                       ,pr_cddeacao => 'ANALISAR'
                       ,pr_dscritic => vr_dscritic);
      
      IF (vr_dscritic IS NOT NULL) THEN
         raise vr_exc_erro;
      END IF;
      
      /*Executar a An�lise do Bordero*/
      pc_efetua_analise_bordero (pr_cdcooper => vr_cdcooper
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_idorigem => vr_idorigem
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_idseqttl => 1
                                ,pr_dtmvtolt => vr_dtmvtolt
                                ,pr_dtmvtopr => vr_dtmvtopr
                                ,pr_inproces => 0
                                ,pr_nrborder => pr_nrborder
                                ,pr_inrotina => 1 -- 1-IMPEDITIVA+RESTRI��ES COM APROVA��O DE AN�LISE
                                ,pr_flgerlog => FALSE
                                ,pr_insborde => 0
                                -- retornos
                                ,pr_indrestr => vr_indrestr
                                ,pr_ind_inpeditivo => vr_ind_inpeditivo
                                ,pr_tab_erro => vr_tab_erro
                                ,pr_tab_retorno_analise => vr_tab_retorno_analise
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic
                                );

      IF (vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL) THEN
         raise vr_exc_erro;
      END IF;
      
      -- Chamar gera��o de LOG
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => vr_dscritic
                        ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                        ,pr_dstransa => 'Bordero n '|| pr_nrborder || ' ' || vr_tab_retorno_analise(0).dssitres
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'ATENDA'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
                        
      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informa�oes do xml
      vr_texto_completo := null;

      /*Passou nas valida��es do bordero, do contrato e listou titulos. Come�a a montar o xml*/
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados>');

      pc_escreve_xml('<analisebordero>'||
                          '<nrborder>' || vr_tab_retorno_analise(0).nrborder || '</nrborder>' ||
                          '<cdcooper>' || vr_tab_retorno_analise(0).cdcooper || '</cdcooper>' ||
                          '<nrdconta>' || vr_tab_retorno_analise(0).nrdconta || '</nrdconta>' ||
                          '<msgretorno>' || vr_tab_retorno_analise(0).dssitres || '</msgretorno>');
      pc_escreve_xml('</analisebordero>');
                    
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a mem�ria alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    exception
      when vr_exc_erro then
           /*  se foi retornado apenas c�digo */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descri�ao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;

           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           /* montar descri�ao de erro n�o tratado */
           pr_dscritic := 'erro n�o tratado na DSCT0003.pc_efetua_analise_bordero_web ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_efetua_analise_bordero_web;

  PROCEDURE pc_busca_tarifa_desc_titulo(pr_cdcooper  in crapepr.cdcooper%type
                                       ,pr_nrdconta  in crapepr.nrdconta%type
                                       ,pr_cdagenci  in craplot.cdagenci%type
                                       ,pr_nrdcaixa  in craperr.nrdcaixa%type
                                       ,pr_vlborder  in craptdb.vltitulo%type
                                       ,pr_vltarifa out number
                                       ,pr_cdfvlcop out integer
                                       ,pr_cdhistor out integer
                                       ,pr_cdcritic out pls_integer
                                       ,pr_dscritic out varchar2
                                       ) is
   /*-------------------------------------------------------------------------------------------------------
     Programa : pc_busca_tarifa_desc_titulo        Antigo: b1wgen0030.p/busca_tarifa_desconto_titulo
     Sistema  : Procedure para buscar tarifa
     Sigla    : CRED
     Autor    : Paulo Penteado (GFT) 
     Data     : Abril/2018
   
     Objetivo  : Procedure para buscar tarifa

     Alteracoes: 15/04/2018 - Cria��o (Paulo Penteado (GFT))

   ----------------------------------------------------------------------------------------------------------*/
   -- Variaveis de Erro
   vr_cdcritic crapcri.cdcritic%type;
   vr_dscritic varchar2(4000);
   vr_tab_erro gene0001.typ_tab_erro;

   -- Variaveis Excecao
   vr_exc_erro exception;
   
   vr_dssigtar varchar2(20);
   vr_cdhisest number;
   vr_dtdivulg date;
   vr_dtvigenc date;
  
  BEGIN
   open  cr_crapass(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
   fetch cr_crapass into rw_crapass;
   if    cr_crapass%notfound then
         close cr_crapass;
         vr_dscritic:= 'Associado nao cadastrado.';
         raise vr_exc_erro;
   end   if;
   close cr_crapass;

   if  rw_crapass.inpessoa = 1 then
       vr_dssigtar := 'DSTBORDEPF';
   else
       vr_dssigtar := 'DSTBORDEPJ';
   end if;
   
   /*  Busca valor da tarifa sem registro*/
   tari0001.pc_carrega_dados_tar_vigente(pr_cdcooper  => pr_cdcooper  --Codigo Cooperativa
                                        ,pr_cdbattar  => vr_dssigtar  --Codigo Tarifa
                                        ,pr_vllanmto  => pr_vlborder  --Valor Lancamento
                                        ,pr_cdprogra  => null         --Codigo Programa
                                        ,pr_cdhistor  => pr_cdhistor  --Codigo Historico
                                        ,pr_cdhisest  => vr_cdhisest  --Historico Estorno
                                        ,pr_vltarifa  => pr_vltarifa  --Valor tarifa
                                        ,pr_dtdivulg  => vr_dtdivulg  --Data Divulgacao
                                        ,pr_dtvigenc  => vr_dtvigenc  --Data Vigencia
                                        ,pr_cdfvlcop  => pr_cdfvlcop  --Codigo faixa valor cooperativa
                                        ,pr_cdcritic  => vr_cdcritic  --Codigo Critica
                                        ,pr_dscritic  => vr_dscritic  --Descricao Critica
                                        ,pr_tab_erro  => vr_tab_erro); --Tabela erros
   
      
   
   if  vr_cdcritic is not null or vr_dscritic is not null then
       if  vr_tab_erro.count > 0 then
           vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
           vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
       else
           vr_cdcritic := 0;
           vr_dscritic := 'N�o foi poss�vel carregar a tarifa.';
       end if;
       raise vr_exc_erro;
   end if;
  
  EXCEPTION
   when vr_exc_erro then
        if  nvl(vr_cdcritic,0) <> 0 and trim(vr_dscritic) is null then
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

            if  vr_tab_erro.count = 0 then
                gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_nrdcaixa => pr_nrdcaixa
                                     ,pr_nrsequen => 1 -- Sequencia
                                     ,pr_cdcritic => pr_cdcritic
                                     ,pr_dscritic => pr_dscritic
                                     ,pr_tab_erro => vr_tab_erro);
            end if;
        else
            pr_cdcritic := nvl(vr_cdcritic,0);
            pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
        end if;

   when others then
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace('Erro na dsct0003.pc_busca_tarifa_desc_titulo: ' || sqlerrm, chr(13)),chr(10));

  END pc_busca_tarifa_desc_titulo;

  PROCEDURE pc_lanca_tarifa_bordero (pr_cdcooper IN crapbdt.cdcooper%TYPE --> C�digo da Cooperativa
                                    ,pr_nrdconta IN crapbdt.nrdconta%TYPE  --> N�mero da Conta
                                    ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                    ,pr_cdagenci IN crapbdt.cdagenci%type --> C�digo da Ag�ncia
                                    ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Numero Caixa
                                    ,pr_cdoperad IN crapbdt.cdoperad%TYPE --> Operador
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                    ,pr_vlborder IN NUMBER                --> Valor do Border�
                                    ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                                    ,pr_idorigem IN VARCHAR2              --> Identificador Origem pagamento
                                    ,pr_dscritic OUT VARCHAR2             --> Descri�ao da cr�tica
                            ) IS
  BEGIN
   /*-------------------------------------------------------------------------------------------------------
     Programa : pc_lanca_tarifa_bordero        Antigo: b1wgen0030.p/efetua_liber_anali_bordero (Trecho de Libera��o)
     Sistema  : Procedure para lan�ar a tarifa de border� de desconto de T�tulo
     Sigla    : CRED
     Autor    : Andrew Albuquerque (GFT) 
     Data     : Abril/2018
   
     Objetivo  : Procedure para lan�ar tarifa

     Alteracoes: 16/04/2018 - Cria��o (Andrew Albuquerque (GFT))
   ----------------------------------------------------------------------------------------------------------*/
    DECLARE
      vr_vltarifa NUMBER;
      vr_cdfvlcop NUMBER;
      vr_cdhistor craphis.cdhistor%TYPE;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_cdpactra crapope.cdpactra%TYPE;
      
      vr_exc_erro exception;
      vr_dscritic VARCHAR2(10000);
      
      vr_qtacobra INTEGER;
      vr_fliseope INTEGER;
      vr_rowid_craplat rowid;
      vr_tab_erro gene0001.typ_tab_erro;
      
      --========== CURSORES ==========--
      CURSOR cr_crapope (pr_cdcooper crapope.cdcooper%TYPE
                       ,pr_cdoperad crapope.cdoperad%TYPE) IS
      SELECT c.cdpactra -- C�digo de Departamento do Operador.
        FROM crapope c
       WHERE c.cdcooper = pr_cdcooper
         AND c.cdoperad = pr_cdoperad;
      rw_crapope cr_crapope%ROWTYPE;
      
    BEGIN
      -- busca o C�digo de Departamento do Operador para utilizar como par�metro interno da procedure.
      vr_cdpactra := 0;
      FOR rw_crapope IN
          cr_crapope (pr_cdcooper => pr_cdcooper,
                      pr_cdoperad => pr_cdoperad) LOOP
        vr_cdpactra := rw_crapope.cdpactra;
      END LOOP;
      
      --Buscar a Tarifa de Desconto para os T�tulos
      pc_busca_tarifa_desc_titulo(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_vlborder=>  pr_vlborder 
                                 ,pr_vltarifa => vr_vltarifa --OUT
                                 ,pr_cdfvlcop => vr_cdfvlcop --OUT
                                 ,pr_cdhistor => vr_cdhistor --OUT
                                 ,pr_cdcritic => vr_cdcritic --OUT
                                 ,pr_dscritic => vr_dscritic); --OUT
                                        
      IF  nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
            
      -- Se encontrou Tarifa, In�cia o Lan�amento das Tarifas.
      IF vr_vltarifa > 0 THEN
        
        TARI0001.pc_verifica_tarifa_operacao(pr_cdcooper => pr_cdcooper
                                            ,pr_cdoperad => pr_cdoperad
                                            ,pr_cdagenci => pr_cdagenci
                                            ,pr_cdbccxlt => pr_cdcooper
                                            ,pr_dtmvtolt => pr_dtmvtolt
                                            ,pr_cdprogra => pr_nmdatela
                                            ,pr_idorigem => pr_idorigem
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_tipotari => 16 -- Tipo de Tarifa
                                            ,pr_tipostaa => 0  -- TIpo TAA
                                            ,pr_qtoperac => 1  -- Quantidade de Opera��es
                                            ,pr_qtacobra => vr_qtacobra -- Quantidade de Opera��es a Serem Cobradas
                                            ,pr_fliseope => vr_fliseope -- Indicador de isencao de tarifa (0 - nao isenta, 1 - isenta) 
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
   
        -- SE N�O � ISENTO DE TARIFA
        IF vr_fliseope <> 1 THEN
          
          -- Criar lan�amento autom�tico da tarifa
          tari0001.pc_cria_lan_auto_tarifa(pr_cdcooper => pr_cdcooper           --> Codigo Cooperativa
                                          ,pr_nrdconta => pr_nrdconta           --> Numero da Conta
                                          ,pr_dtmvtolt => pr_dtmvtolt           --> Data Lancamento
                                          ,pr_cdhistor => vr_cdhistor           --> Codigo Historico
                                          ,pr_vllanaut => vr_vltarifa           --> Valor lancamento automatico
                                          ,pr_cdoperad => pr_cdoperad           --> Codigo Operador
                                          ,pr_cdagenci => 1                     --> Codigo Agencia
                                          ,pr_cdbccxlt => 100                   --> Codigo banco caixa
                                          ,pr_nrdolote => 1900 + vr_cdpactra    --> Numero do lote
                                          ,pr_tpdolote => 1                     --> Tipo do lote (35 - T�tulo)
                                          ,pr_nrdocmto => 0                     --> Numero do documento
                                          ,pr_nrdctabb => pr_nrdconta           --> Numero da conta
                                          ,pr_nrdctitg => gene0002.fn_mask(pr_nrdconta, '99999999') --> Numero da conta integracao
                                          ,pr_cdpesqbb => 'Fato gerador tarifa: ' || pr_nrborder  --> Codigo pesquisa
                                          ,pr_cdbanchq => 0                     --> Codigo Banco Cheque
                                          ,pr_cdagechq => 0                     --> Codigo Agencia Cheque
                                          ,pr_nrctachq => 0                     --> Numero Conta Cheque
                                          ,pr_flgaviso => false                 --> Flag aviso
                                          ,pr_tpdaviso => 0                     --> Tipo aviso
                                          ,pr_cdfvlcop => vr_cdfvlcop           --> Codigo cooperativa
                                          ,pr_inproces => 1                     --> Indicador processo 1 = Online
                                          --
                                          ,pr_rowid_craplat => vr_rowid_craplat --> Rowid do lancamento tarifa
                                          ,pr_tab_erro      => vr_tab_erro      --> Tabela retorno erro
                                          ,pr_cdcritic      => vr_cdcritic      --> Codigo Critica
                                          ,pr_dscritic      => vr_dscritic);    --> Descricao Critica
          
          
          if  vr_cdcritic > 0 or trim(vr_dscritic) is not null then
             if  vr_tab_erro.count() > 0 THEN
                 vr_dscritic:= vr_tab_erro(vr_tab_erro.first).dscritic;
             ELSE
                 vr_dscritic:= 'Erro no Lan�amento da Tarifa de Border� de Desconto de T�tulo';
             end if;
             raise vr_exc_erro;
          END IF;
        END IF;
        
      END IF;
                   
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;      
    END;
  END pc_lanca_tarifa_bordero;
  
  PROCEDURE pc_lanca_credito_bordero(pr_dtmvtolt IN craplcm.dtmvtolt%TYPE -- Origem: do lote de libera��o (craplot)
                                    ,pr_cdagenci IN craplcm.cdagenci%TYPE -- Origem: do lote de libera��o (craplot)
                                    ,pr_cdbccxlt IN craplcm.cdbccxlt%TYPE -- Origem: do lote de libera��o (craplot)
                                    ,pr_nrdconta IN craplcm.nrdconta%TYPE -- Origem: nrdconta do Bordero
                                    ,pr_vllanmto IN craplcm.vllanmto%TYPE -- Origem: do c�lculo :aux_vlborder + craptdb.vlliquid da linha 1870.
                                    ,pr_cdcooper IN craplcm.cdcooper%TYPE
                                    ,pr_cdoperad IN crapbdt.cdoperad%TYPE --> Operador
                                    ,pr_nrborder IN crapbdt.nrborder%TYPE -- Origem: Bordero
                                    ,pr_cdpactra IN crapope.cdpactra%TYPE
                                    ,pr_dscritic    OUT VARCHAR2          --> Descricao Critica
                                    ) IS
  BEGIN

   /*-------------------------------------------------------------------------------------------------------
     Programa : pc_lanca_tarifa_bordero        Antigo: b1wgen0030.p/efetua_liber_anali_bordero (Trecho de Libera��o)
     Sistema  : Procedure para lan�ar cr�dito de desconto de T�tulo
     Sigla    : CRED
     Autor    : Andrew Albuquerque (GFT) 
     Data     : Abril/2018
   
     Objetivo  : Procedure para la�amento de cr�dito de desconto de T�tulo.

     Alteracoes: 16/04/2018 - Cria��o (Andrew Albuquerque (GFT))
   ----------------------------------------------------------------------------------------------------------*/
    DECLARE
        
    vr_nrdolote craplot.nrdolote%TYPE;
      
    -- Vari�vel de cr�ticas
    vr_dscritic VARCHAR2(10000);
      
    vr_exc_erro exception;
    
    vr_rowid    ROWID;
    -- CURSORES
    CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
                     ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                     ,pr_cdagenci IN craplot.cdagenci%TYPE
                     ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                     ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
      SELECT lot.qtcompln
            ,lot.vlcompcr
            ,lot.qtinfoln
            ,lot.vlinfocr
            ,lot.vlcompdb
            ,lot.vlinfodb
            ,lot.dtmvtolt
            ,lot.cdagenci
            ,lot.cdbccxlt
            ,lot.nrdolote
            ,lot.nrseqdig
            ,lot.tplotmov
            ,lot.cdoperad
            ,lot.cdhistor
            ,lot.ROWID
            ,count(1) over() retorno
        FROM craplot lot
       WHERE lot.cdcooper = pr_cdcooper
         AND lot.dtmvtolt = pr_dtmvtolt
         AND lot.cdagenci = pr_cdagenci
         AND lot.cdbccxlt = pr_cdbccxlt
         AND lot.nrdolote = pr_nrdolote
      FOR UPDATE;
    rw_craplot cr_craplot%ROWTYPE;
    
    -- Registros para armazenar dados do lancamento gerado
    rw_craplcm craplcm%ROWTYPE;    
    vr_flg_criou_lot BOOLEAN;
    BEGIN
      vr_flg_criou_lot:=false;
      /*Insere um lote novo*/
      WHILE NOT vr_flg_criou_lot LOOP
        BEGIN
        --vr_nrdolote := 17000 + pr_cdpactra;
        vr_nrdolote := fn_sequence(pr_nmtabela => 'CRAPLOT'
                                  ,pr_nmdcampo => 'NRDOLOTE'
                                  ,pr_dsdchave => TO_CHAR(pr_cdcooper)|| ';' 
                                               || pr_dtmvtolt || ';'
                                               || TO_CHAR(pr_cdagenci)|| ';'
                                               || '100');
        --Buscar o lote
        OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => vr_nrdolote);

        FETCH cr_craplot INTO rw_craplot;

        -- Gerar erro caso n�o encontre
        IF cr_craplot%NOTFOUND THEN
           -- Fechar cursor pois teremos raise
           CLOSE cr_craplot;
           BEGIN
             INSERT INTO craplot
                        (cdcooper
                        ,dtmvtolt
                        ,cdagenci
                        ,cdbccxlt
                        ,nrdolote
                        ,tplotmov
                        ,cdoperad
                        ,cdhistor)
                 VALUES(pr_cdcooper
                        ,pr_dtmvtolt
                        ,1
                        ,100
                        ,vr_nrdolote
                        ,1
                        ,pr_cdoperad
                        ,vr_cdhistordsct_credito)
              RETURNING dtmvtolt
                        ,cdagenci
                        ,cdbccxlt
                        ,nrdolote
                        ,vlinfocr
                        ,vlcompcr
                        ,qtinfoln
                        ,qtcompln
                        ,nrseqdig
                        ,ROWID
                   INTO rw_craplot.dtmvtolt
                        ,rw_craplot.cdagenci
                        ,rw_craplot.cdbccxlt
                        ,rw_craplot.nrdolote
                        ,rw_craplot.vlinfocr
                        ,rw_craplot.vlcompcr
                        ,rw_craplot.qtinfoln
                        ,rw_craplot.qtcompln
                        ,rw_craplot.nrseqdig
                        ,rw_craplot.rowid;
           EXCEPTION
             WHEN OTHERS THEN
               -- Monta critica
               vr_dscritic := 'Erro ao inserir na tabela craplot: ' || SQLERRM;
               -- Gera exce��o
               RAISE vr_exc_erro;

           END;
        ELSE
           -- Apenas fechar o cursor
           CLOSE cr_craplot;
        END IF;
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            CONTINUE;
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao inserir novo lote ' || SQLERRM;
            -- Levanta exce��o
            RAISE vr_exc_erro;
        END;
        vr_flg_criou_lot := TRUE;
      END LOOP;
      BEGIN
        -- Gero o Insert na tabela de Lancamentos em depositos a vista
        INSERT INTO craplcm
               (/*01*/ dtmvtolt
               ,/*02*/ cdagenci
               ,/*03*/ cdbccxlt
               ,/*04*/ nrdolote
               ,/*05*/ nrdconta
               ,/*06*/ nrdocmto
               ,/*07*/ vllanmto
               ,/*08*/ cdhistor
               ,/*09*/ nrseqdig
               ,/*10*/ nrdctabb
               ,/*11*/ nrautdoc 
               ,/*12*/ cdcooper
               ,/*13*/ cdpesqbb)
        VALUES (/*01*/ rw_craplot.dtmvtolt
               ,/*02*/ rw_craplot.cdagenci
               ,/*03*/ rw_craplot.cdbccxlt
               ,/*04*/ rw_craplot.nrdolote
               ,/*05*/ pr_nrdconta
               ,/*06*/ rw_craplot.nrseqdig +1
               ,/*07*/ pr_vllanmto --  do c�lculo :aux_vlborder + craptdb.vlliquid da linha 1870.
               ,/*08*/ vr_cdhistordsct_credito
               ,/*09*/ rw_craplot.nrseqdig +1
               ,/*10*/ pr_nrdconta
               ,/*11*/ 0
               ,/*12*/ pr_cdcooper
               ,/*13*/ 'Desconto do Border� ' || pr_nrborder)
              RETURNING craplcm.ROWID
                       ,craplcm.cdhistor
                       ,craplcm.cdcooper
                       ,craplcm.dtmvtolt
                       ,craplcm.hrtransa
                       ,craplcm.nrdconta
                       ,craplcm.nrdocmto
                       ,craplcm.vllanmto
                  INTO  vr_rowid
                       ,rw_craplcm.cdhistor
                       ,rw_craplcm.cdcooper
                       ,rw_craplcm.dtmvtolt
                       ,rw_craplcm.hrtransa
                       ,rw_craplcm.nrdconta
                       ,rw_craplcm.nrdocmto
                       ,rw_craplcm.vllanmto;
      EXCEPTION
        WHEN OTHERS THEN
          -- Monta critica
          vr_dscritic := 'Erro ao inserir na tabela craplcm: ' || SQLERRM;
          -- Gera exce��o
          RAISE vr_exc_erro;
      END;

      BEGIN
        UPDATE craplot
           SET craplot.nrseqdig = rw_craplcm.nrseqdig
              ,craplot.qtinfoln = craplot.qtinfoln + 1
              ,craplot.qtcompln = craplot.qtcompln + 1
              ,craplot.vlinfocr = craplot.vlinfocr + rw_craplcm.vllanmto
              ,craplot.vlcompcr = craplot.vlcompcr + rw_craplcm.vllanmto
         WHERE craplot.rowid = rw_craplot.rowid
         RETURNING dtmvtolt
                   ,cdagenci
                   ,cdbccxlt
                   ,nrdolote
                   ,vlinfocr
                   ,vlcompcr
                   ,qtinfoln
                   ,qtcompln
                   ,nrseqdig
                   ,ROWID
              INTO rw_craplot.dtmvtolt
                  ,rw_craplot.cdagenci
                  ,rw_craplot.cdbccxlt
                  ,rw_craplot.nrdolote
                  ,rw_craplot.vlinfocr
                  ,rw_craplot.vlcompcr
                  ,rw_craplot.qtinfoln
                  ,rw_craplot.qtcompln
                  ,rw_craplot.nrseqdig
                  ,rw_craplot.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          -- Monta critica
          vr_dscritic := 'Erro ao atualizar o Lote!';

          -- Gera exce��o
          RAISE vr_exc_erro;
      END;
    
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao Realizar Lan�amento de Cr�dito de Desconto de T�tulos: '||' '||vr_dscritic||' '||sqlerrm;
    END;
  END pc_lanca_credito_bordero;
    
  PROCEDURE pc_liberar_bordero (pr_cdcooper IN craptdb.cdcooper%TYPE --> C�digo da Cooperativa
                               ,pr_cdagenci IN crapass.cdagenci%type --> C�digo da Ag�ncia
                               ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Numero Caixa
                               ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                               ,pr_nmdatela IN craplgm.nmdatela%TYPE --> Nome da tela.
                               ,pr_idorigem IN VARCHAR2              --> Identificador Origem pagamento
                               ,pr_nrdconta IN crapass.nrdconta%TYPE --> N�mero da Conta
                               ,pr_idseqttl IN INTEGER               --> idseqttl
                               ,pr_nrborder IN crapbdt.nrborder%TYPE --> numero do bordero
                               ,pr_dtmvtolt IN VARCHAR2              --> Data do movimento
                               ,pr_flgerlog IN BOOLEAN               --> identificador se deve gerar log
                               --------> OUT <--------
                               ,pr_vltotliq OUT NUMBER 
                               ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela Erros
                               ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                               ,pr_dscritic OUT VARCHAR2             --> Descri�ao da cr�tica
                               ) IS
   /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_liberar_bordero
    Sistema  : Cred
    Sigla    :
    Autor    : Lucas Lazari (GFT)
    Data     : Abril/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Procedure que libera o border� de desconto de t�tulos

    Altera��o : ??/04/2018 - Cria��o (Lucas Lazari (GFT))
                24/05/2018 - Adicionado inser��o do lan�amento do bordero. Alterado o c�digo do hist�rico da craplcm de
                             libera��o para o novo c�digo criado pelo contabilidade (Paulo Penteado (GFT)) 
  ---------------------------------------------------------------------------------------------------------------------*/
  
  BEGIN
    DECLARE
    -- Vari�veis de Uso Local
    vr_dsorigem VARCHAR2(40)  DEFAULT NULL; --> Descri��o da Origem
    vr_dstransa VARCHAR2(100) DEFAULT NULL; --> Descri��o da trasa�ao para log

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    --Tabela erro
    vr_tab_erro GENE0001.typ_tab_erro;

    -- rowid tabela de log
    vr_nrdrowid ROWID;

    -- Vari�veis de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
          
    vr_vltotbrt     NUMBER; 
    vr_vltxiofatra  NUMBER; --> Valor total IOF Atraso
    vr_vltotjur     NUMBER;
                             
        
  BEGIN
    
    --Seta as vari�veis de Descri��o de Origem e descri��o de Transa��o se For gerar Log
    IF pr_flgerlog THEN
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa := 'Liberar o Border� ' || pr_nrborder || ' de Desconto de T�tulo.';
    END IF;
    
    pr_tab_erro.DELETE;
    
    -- Calcula os valores do border� (l�quido e bruto)
    pc_calcula_valores_bordero (pr_cdcooper => pr_cdcooper
                               ,pr_nrborder => pr_nrborder
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_cdoperad => pr_cdoperad 
                               ,pr_dtmvtolt => pr_dtmvtolt
                               ,pr_vltotliq => pr_vltotliq
                               ,pr_vltotbrt => vr_vltotbrt
                               ,pr_vltotjur => vr_vltotjur
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               );
    
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Busca e lan�a a tarifa vigente do border� de desconto de t�tulos
    pc_lanca_tarifa_bordero (pr_cdcooper => pr_cdcooper  
                            ,pr_nrdconta => pr_nrdconta   
                            ,pr_nrborder => pr_nrborder  
                            ,pr_cdagenci => pr_cdagenci 
                            ,pr_nrdcaixa => pr_nrdcaixa 
                            ,pr_cdoperad => pr_cdoperad 
                            ,pr_dtmvtolt => pr_dtmvtolt 
                            ,pr_vlborder => vr_vltotbrt
                            ,pr_nmdatela => pr_nmdatela              
                            ,pr_idorigem => pr_idorigem              
                            ,pr_dscritic => vr_dscritic);            
    
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Calcula e lan�a o valor do IOF
    pc_lanca_iof_bordero (pr_cdcooper => pr_cdcooper
                         ,pr_cdagenci => pr_cdagenci
                         ,pr_cdoperad => pr_cdoperad
                         ,pr_nrborder => pr_nrborder
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_dtmvtolt => pr_dtmvtolt
                         ,pr_vltotliq => pr_vltotliq
                         ,pr_vltxiofatra => vr_vltxiofatra
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
    
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 
    
    -- Lan�a o cr�dito do valor l�quido do border� na conta corrente do cooperado
    pc_lanca_credito_bordero(pr_dtmvtolt => pr_dtmvtolt 
                            ,pr_cdagenci => pr_cdagenci 
                            ,pr_cdbccxlt => 100 
                            ,pr_nrdconta => pr_nrdconta 
                            ,pr_vllanmto => pr_vltotliq
                            ,pr_cdcooper => pr_cdcooper 
                            ,pr_cdoperad => pr_cdoperad 
                            ,pr_nrborder => pr_nrborder 
                            ,pr_cdpactra => 0 
                            ,pr_dscritic => vr_dscritic 
                            );
    
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Lan�ar opera��o de desconto, valor bruto do border�
    pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrborder => pr_nrborder
                                 ,pr_dtmvtolt => pr_dtmvtolt
                                 ,pr_cdorigem => 5
                                 ,pr_cdhistor => vr_cdhistordsct_liberacred
                                 ,pr_vllanmto => vr_vltotbrt
                                 ,pr_dscritic => vr_dscritic );
    
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Lan�ar opera��o de desconto, valor do juros calculado
    pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrborder => pr_nrborder
                                 ,pr_dtmvtolt => pr_dtmvtolt
                                 ,pr_cdorigem => 5
                                 ,pr_cdhistor => vr_cdhistordsct_rendaapropr
                                 ,pr_vllanmto => vr_vltotjur
                                 ,pr_dscritic => vr_dscritic );
    
    IF  vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
    END IF;
    
    pc_atualizar_bordero_dsct_tit(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrborder => pr_nrborder
                                 ,pr_dtmvtolt => pr_dtmvtolt
                                 ,pr_cdoperad => pr_cdoperad
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_vltaxiof => vr_vltxiofatra
                                 ,pr_dscritic => vr_dscritic );
    
    IF  vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
    END IF;
    
    COMMIT;
    
    EXCEPTION
     when vr_exc_erro then
          if  nvl(vr_cdcritic,0) <> 0 and trim(vr_dscritic) is null then
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

              IF vr_tab_erro.count = 0 THEN
                GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_nrdcaixa => pr_nrdcaixa
                                     ,pr_nrsequen => 1 -- Sequencia
                                     ,pr_cdcritic => pr_cdcritic
                                     ,pr_dscritic => pr_dscritic
                                     ,pr_tab_erro => vr_tab_erro);
              END IF;
          else
              pr_cdcritic := nvl(vr_cdcritic,0);
              pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
          end if;
          
          -- Se Solicitou Gera��o de LOG
          IF pr_flgerlog THEN
            -- Chamar gera��o de LOG
            gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_dscritic => vr_dscritic
                                ,pr_dsorigem => vr_dsorigem
                                ,pr_dstransa => vr_dstransa
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => 0 --> FALSE
                                ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_nmdatela => pr_nmdatela
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);
          END IF;
          
          ROLLBACK;
    WHEN OTHERS THEN
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := replace(replace('Erro pc_liberar_bordero: ' || sqlerrm, chr(13)),chr(10));
          
         ROLLBACK;
    END;
    
  END pc_liberar_bordero;

  
  PROCEDURE pc_liberar_bordero_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                   ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                   ,pr_confirma IN PLS_INTEGER            --> numero do bordero
                                   ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                   --------> OUT <--------
                                   ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                   ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                   ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                   ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                          ) IS
 /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_liberar_bordero_web
    Sistema  : Cred
    Sigla    :
    Autor    : Lucas Lazari (GFT)
    Data     : Abril/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Procedure que que efetua a an�lise e Aprova��o autom�tica do Border�.
  ---------------------------------------------------------------------------------------------------------------------*/


    /* tratamento de erro */
    vr_exc_erro exception;
    vr_exc_restricao_analise exception;

    vr_tab_erro         gene0001.typ_tab_erro;

    vr_indrestr PLS_INTEGER;
    vr_ind_inpeditivo PLS_INTEGER;
    vr_vltotliq NUMBER;
    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);
    --vr_msgcontingencia varchar2(100);
    vr_msgretorno varchar2(1000);
    
    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
    vr_dscritic varchar2(1000);        --> Desc. Erro

    vr_tab_retorno_analise typ_tab_retorno_analise;

    -- variaveis de data
    vr_dtmvtopr crapdat.dtmvtolt%TYPE;
    vr_dtmvtolt crapdat.dtmvtolt%TYPE;

      -- rowid tabela de log
      vr_nrdrowid ROWID;

--    vr_em_contingencia_ibratan boolean;
    vr_possuicnae  INTEGER;
    vr_enviadomesa INTEGER;
    vr_flsnhcoo BOOLEAN;
    
    BEGIN
      pr_nmdcampo := NULL;
      pr_des_erro := 'OK';
      vr_possuicnae  := 0;
      vr_enviadomesa := 0;
      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);


      --Selecionar dados da data
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se encontrar
      IF BTCH0001.cr_crapdat%FOUND THEN
        vr_dtmvtopr:= rw_crapdat.dtmvtopr;
        vr_dtmvtolt:= rw_crapdat.dtmvtolt;
      END IF;
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
      
      -- Inicia Vari�vel de msg de conting�ncia.
      --vr_msgcontingencia := '';
      vr_msgretorno := '';
      
      -- Valida se a situa��o do border� permite libera��o
      pc_valida_bordero(pr_cdcooper => vr_cdcooper
                       ,pr_nrborder => pr_nrborder
                       ,pr_cddeacao => 'LIBERAR'
                       ,pr_dscritic => vr_dscritic);
      
      IF (vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL) THEN
         raise vr_exc_erro;
      END IF;
      
      -- Analisa o border� para verificar se n�o h� nenhuma cr�tica impeditiva para a libera��o      
      pc_efetua_analise_bordero (pr_cdcooper => vr_cdcooper
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_idorigem => vr_idorigem
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_idseqttl => 1
                                ,pr_dtmvtolt => vr_dtmvtolt
                                ,pr_dtmvtopr => vr_dtmvtopr
                                ,pr_inproces => 0
                                ,pr_nrborder => pr_nrborder
                                ,pr_flgerlog => FALSE
                                ,pr_insborde => 0
                                -- retornos
                                ,pr_indrestr => vr_indrestr
                                ,pr_ind_inpeditivo => vr_ind_inpeditivo
                                ,pr_tab_erro => vr_tab_erro
                                ,pr_tab_retorno_analise => vr_tab_retorno_analise
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic
                                );
                                
      IF (vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL) THEN
         raise vr_exc_erro;
      END IF;                 
        -- Se o border� possui restri��es e o operador est� tentando liberar pela primeira vez, retorna a mensagem abaixo
        IF vr_indrestr = 1 AND pr_confirma = 0 THEN
          vr_msgretorno := 'H� restri��es no border�. Deseja realizar a libera��o mesmo assim?';
        ELSE      
          -- Gera as Restri��es do Border� (CRAPABT)
          pc_restricoes_tit_bordero( pr_cdcooper => vr_cdcooper
                              ,pr_cdagenci =>  vr_cdagenci
                              ,pr_nrdcaixa =>  vr_nrdcaixa
                              ,pr_cdoperad =>  vr_cdoperad
                              ,pr_nmdatela =>  vr_nmdatela
                              ,pr_idorigem =>  vr_idorigem
                              ,pr_dtmvtolt =>  vr_dtmvtolt
                              ,pr_nrdconta =>  pr_nrdconta
                              ,pr_idseqttl =>  1
                              ,pr_nrborder =>  pr_nrborder
                              ,pr_flgerlog =>  FALSE
                              ,pr_indrestr =>  vr_indrestr
                              ,pr_flsnhcoo =>  vr_flsnhcoo
                              ,pr_tab_erro =>  vr_tab_erro
                              ,pr_cdcritic =>  vr_cdcritic
                              ,pr_dscritic =>  vr_dscritic);
                                           
          IF (vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL) THEN
             raise vr_exc_erro;
          END IF;
                                   
          -- Verifica se possui critica CNAE e se j� foi enviado para a mesa de checagem
          SELECT COUNT(*) INTO vr_possuicnae FROM crapabt WHERE cdcooper = vr_cdcooper AND nrborder = pr_nrborder AND nrseqdig = 9; -- CNAE
          SELECT CASE WHEN DTENVMCH IS NULL THEN 0 ELSE 1 END INTO vr_enviadomesa FROM crapbdt WHERE cdcooper = vr_cdcooper AND nrborder = pr_nrborder; -- CNAE
          IF vr_possuicnae > 0 AND vr_enviadomesa = 0 THEN
            vr_dscritic := 'Border� com cr�ticas, aguarde retorno de an�lise da sede.';
            RAISE vr_exc_erro;
          END IF;
          
          -- Caso o operador tenha decidido liberar o border� (com ou sem restri��es) chama a rotina principal de libera��o do border�                        
          pc_liberar_bordero  (pr_cdcooper => vr_cdcooper
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_idorigem => vr_idorigem
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_idseqttl => 1
                              ,pr_nrborder => pr_nrborder
                              ,pr_dtmvtolt => vr_dtmvtolt
                              ,pr_vltotliq => vr_vltotliq
                              ,pr_flgerlog => FALSE
                              ,pr_tab_erro => vr_tab_erro
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic
                              );
                              
          IF (vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL) THEN
             raise vr_exc_erro;
          END IF;   
           
        
          -- Salva a ultima imagem das % de liquidez do bordero na CRAPABT
          pc_grava_restricoes_liberacao(vr_cdcooper, pr_nrdconta, pr_nrborder, vr_cdoperad, vr_cdcritic, vr_dscritic);
                      
          IF (vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL) THEN
             raise vr_exc_erro;
          END IF;  
          
          -- Ajusta a mensagem de confirma��o conforme a exist�ncia de restri��es no border�
          IF vr_indrestr = 1 THEN
             vr_msgretorno := 'Border� liberado COM restri��es! Valor l�quido de R$' || TRIM(to_char(vr_vltotliq, 'FM999G999G999G990D00'));
          ELSE
             vr_msgretorno := 'Border� liberado SEM restri��es! Valor l�quido de R$' || TRIM(to_char(vr_vltotliq, 'FM999G999G999G990D00'));
          END IF;  
          
          -- Atualiza a decis�o do border�
          UPDATE 
             crapbdt
          SET
            insitapr = 4,
            dtaprova = vr_dtmvtolt,
            hraprova = to_char(SYSDATE, 'SSSSS'),
            cdopeapr = vr_cdoperad
          WHERE
            crapbdt.nrborder = pr_nrborder
            AND crapbdt.nrdconta = pr_nrdconta
            AND crapbdt.cdcooper = vr_cdcooper ;  
          
          gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                      ,pr_cdoperad => vr_cdoperad
                      ,pr_dscritic => vr_dscritic
                      ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                      ,pr_dstransa => vr_msgretorno
                      ,pr_dttransa => TRUNC(SYSDATE)
                      ,pr_flgtrans => 1
                      ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                      ,pr_idseqttl => 1
                      ,pr_nmdatela => 'ATENDA'
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      
      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informa�oes do xml
      vr_texto_completo := null;
      
      /*Passou nas valida��es do bordero, do contrato e listou titulos. Come�a a montar o xml*/
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||

                     '<root><dados>');
      
      pc_escreve_xml('<msgretorno>' || vr_msgretorno || '</msgretorno>');
      pc_escreve_xml('<indrestr>' || vr_indrestr || '</indrestr>');
                    
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a mem�ria alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    exception
      when vr_exc_erro then
           /*  se foi retornado apenas c�digo */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descri�ao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;

           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root>' || 
                                             '<Erro>' || pr_dscritic || '</Erro>' || 
                                          '</Root>');
      when others then
           /* montar descri�ao de erro n�o tratado */
           pr_dscritic := 'Erro n�o tratado na dsct0003.pc_liberar_bordero_web ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
   END pc_liberar_bordero_web;
   
   PROCEDURE pc_grava_restricoes_liberacao (pr_cdcooper IN crapbdt.cdcooper%TYPE --> Cooperativa
                                           ,pr_nrdconta IN crapass.nrdconta%TYPE --> N�mero da Conta
                                           ,pr_nrborder IN crapbdt.nrborder%TYPE --> numero do bordero
                                           ,pr_cdoperad IN crapcob.cdoperad%TYPE --> Operador que solicitou a consulta
                                            --------> OUT <--------
                                           ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                           ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                           ) IS
       /*---------------------------------------------------------------------------------------------------------------------
         Programa : pc_grava_restricoes_liberacao
         Sistema  : 
         Sigla    : CRED
         Autor    : Vitor Shimada Assanuma (GFT)
         Data     : 09/06/2018
         Frequencia: Sempre que for chamado
         Objetivo  : Salvar a ultima imagem das restri��es ao liberar um border�
       ---------------------------------------------------------------------------------------------------------------------*/
        -- tratamento de erro
        vr_exc_erro exception;
        
        -- Vari�veis de cr�ticas
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(10000);
    
       -- Cursor gen�rico de calend�rio
       rw_crapdat btch0001.cr_crapdat%ROWTYPE;
       
       -- Titulos (Boletos de Cobran�a)
       cursor cr_crapcob (pr_nrdocmto IN crapcob.nrdocmto%TYPE
                         ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                         ,pr_nrdctabb IN crapcob.nrdctabb%TYPE
                         ,pr_cdbandoc IN crapcob.cdbandoc%TYPE) is
         select cob.cdcooper,
                cob.nrdconta,
                cob.nrinssac,
                cob.nrnosnum,
                cob.cdtpinsc, -- Tipo Pesso do Pagador (0-Nenhum/1-CPF/2-CNPJ)
                cob.nrdocmto,
                cob.nrcnvcob,
                cob.nrdctabb,
                cob.cdbandoc
         from   crapcob cob
         where  cob.cdcooper = pr_cdcooper -- Cooperativa
         and    cob.nrdconta = pr_nrdconta -- Conta
         AND    cob.nrdocmto = pr_nrdocmto
         AND    cob.nrcnvcob = pr_nrcnvcob
         AND    cob.nrdctabb = pr_nrdctabb
         AND    cob.cdbandoc = pr_cdbandoc
         and    cob.incobran=0
       ;rw_crapcob cr_crapcob%rowtype;
       
       -- Pega todos os titulos daquele bordero independente de status
       CURSOR cr_craptdb IS
         SELECT * FROM craptdb t
         WHERE t.nrdconta = pr_nrdconta
           AND t.nrborder = pr_nrborder
           AND t.cdcooper = pr_cdcooper
       ;rw_craptdb cr_craptdb%ROWTYPE;
       
       -- Verifica Conta (Cadastro de associados)
       cursor cr_crapass is
         select inpessoa
         from   crapass
         where  crapass.cdcooper = pr_cdcooper
         and    crapass.nrdconta = pr_nrdconta;
       rw_crapass cr_crapass%rowtype;
    
       -- Retorno da #TAB052
       vr_tab_dados_dsctit    cecred.dsct0002.typ_tab_dados_dsctit;
       vr_tab_cecred_dsctit   cecred.dsct0002.typ_tab_cecred_dsctit;
       
       -- Retorno do calculo de liquidez
       vr_liqpagcd   NUMBER;
       vr_qtd_cedpag NUMBER;
       vr_concpaga   NUMBER;
       vr_qtd_conc   NUMBER;
       vr_liqgeral   NUMBER;
       vr_qtd_geral  NUMBER;
                     
       vr_tab_criticas typ_tab_critica;
       vr_index PLS_INTEGER;
       BEGIN
       -- Leitura do calend�rio da cooperativa
       OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH btch0001.cr_crapdat into rw_crapdat;
       CLOSE btch0001.cr_crapdat;
       
       -- Busca tipo de pessoa
       OPEN cr_crapass;
       FETCH cr_crapass INTO rw_crapass;
       CLOSE cr_crapass;
            
       -- Busca os dados da #TAB052
       DSCT0002.pc_busca_parametros_dsctit(pr_cdcooper          => pr_cdcooper
                                          ,pr_cdagenci          => null -- N�o utiliza dentro da procedure
                                          ,pr_nrdcaixa          => null -- N�o utiliza dentro da procedure
                                          ,pr_cdoperad          => null -- N�o utiliza dentro da procedure
                                          ,pr_dtmvtolt          => null -- N�o utiliza dentro da procedure
                                          ,pr_idorigem          => null -- N�o utiliza dentro da procedure
                                          ,pr_tpcobran          => 1    -- Tipo de Cobran�a: 0 = Sem Registro / 1 = Com Registro
                                          ,pr_inpessoa          => rw_crapass.inpessoa
                                          ,pr_tab_dados_dsctit  => vr_tab_dados_dsctit  --> Tabela contendo os parametros da cooperativa
                                          ,pr_tab_cecred_dsctit => vr_tab_cecred_dsctit --> Tabela contendo os parametros da cecred
                                          ,pr_cdcritic          => vr_cdcritic
                                          ,pr_dscritic          => vr_dscritic);
        
       -- Itera todos os titulos daquele bordero
       OPEN cr_craptdb;
       LOOP
         FETCH cr_craptdb INTO rw_craptdb;
         EXIT WHEN cr_craptdb%NOTFOUND;
         vr_tab_criticas.delete;
         -- Busca na COB o Inssac do pagador daquele titulo
         OPEN cr_crapcob (rw_craptdb.nrdocmto,   -- Conta
                          rw_craptdb.nrcnvcob,   -- Convenio
                          rw_craptdb.nrdctabb,   -- Conta base do banco
                          rw_craptdb.cdbandoc);  -- Codigo do banco            
         FETCH cr_crapcob INTO rw_crapcob;
         CLOSE cr_crapcob;
         
         -- Busca as criticas do Pagador
         pc_calcula_restricao_pagador(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrinssac => rw_craptdb.nrinssac
                          ,pr_cdbandoc => rw_craptdb.cdbandoc
                          ,pr_nrdctabb => rw_craptdb.nrdctabb
                          ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                          ,pr_nrdocmto => rw_craptdb.nrdocmto
                          ,pr_tab_criticas => vr_tab_criticas
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
             RAISE vr_exc_erro;
          END IF;
          /*                                
          pc_calcula_restricao_titulo(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_cdbandoc => rw_craptdb.cdbandoc
                          ,pr_nrdctabb => rw_craptdb.nrdctabb
                          ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                          ,pr_nrdocmto => rw_craptdb.nrdocmto
                          ,pr_tab_criticas => vr_tab_criticas
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);
                          
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
             RAISE vr_exc_erro;
          END IF;*/
          IF (vr_tab_criticas.count > 0) THEN
            vr_index := vr_tab_criticas.first;
            WHILE vr_index IS NOT NULL LOOP  
              pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_dsrestri => ''
                                           ,pr_nrseqdig => vr_tab_criticas(vr_index).cdcritica
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_cdbandoc => vr_tab_criticas(vr_index).cdbandoc
                                           ,pr_nrdctabb => vr_tab_criticas(vr_index).nrdctabb
                                           ,pr_nrcnvcob => vr_tab_criticas(vr_index).nrcnvcob
                                           ,pr_nrdocmto => vr_tab_criticas(vr_index).nrdocmto
                                           ,pr_flaprcoo => 1
                                           ,pr_dsdetres => vr_tab_criticas(vr_index).dsdetres
                                           ,pr_dscritic => vr_dscritic);
                IF  TRIM(vr_dscritic) IS NOT NULL THEN
                  RAISE vr_exc_erro;
                END IF;
              vr_index := vr_tab_criticas.next(vr_index);
            END LOOP;
          END IF;
                    
          dsct0002.pc_atualiza_calculos_pagador ( pr_cdcooper
                                      ,rw_crapcob.nrdconta
                                      ,rw_crapcob.nrinssac
                                      ,rw_crapdat.dtmvtolt - vr_tab_dados_dsctit(1).qtmesliq*30
                                      ,rw_crapdat.dtmvtolt 
                                      ,vr_tab_dados_dsctit(1).cardbtit_c
                                      ,vr_tab_dados_dsctit(1).qttliqcp
                                      ,vr_tab_dados_dsctit(1).vltliqcp
                                      ,vr_tab_dados_dsctit(1).pcmxctip
                                      --------------> OUT <--------------
                                      ,vr_liqpagcd
                                      ,vr_qtd_cedpag
                                      ,vr_concpaga
                                      ,vr_qtd_conc
                                      ,vr_liqgeral
                                      ,vr_qtd_geral
                                      ,vr_cdcritic
                                      ,vr_dscritic
                                      );

         -- Salva as informa��es da CRAPABT => CONCENTRACAO
         pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                         ,pr_cdoperad => pr_cdoperad
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_dsrestri => '' 
                         ,pr_nrseqdig => 18 -- Concentracao
                         ,pr_cdcooper => pr_cdcooper
                         ,pr_flaprcoo => 1
                         ,pr_dsdetres => (TRIM(to_char(vr_concpaga, 'FM999G999G999G990D00'))) -- Concentracao
                         ,pr_nrdocmto => rw_craptdb.nrdocmto   -- Conta
                         ,pr_nrcnvcob => rw_craptdb.nrcnvcob   -- Convenio
                         ,pr_nrdctabb => rw_craptdb.nrdctabb   -- Conta base do banco
                         ,pr_cdbandoc => rw_craptdb.cdbandoc
                         ,pr_dscritic => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
                         
         -- Salva as informa��es da CRAPABT => CEDENTE PAGADOR                     
         pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                         ,pr_cdoperad => pr_cdoperad
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_dsrestri => '' 
                         ,pr_nrseqdig => 19 --Liquidez Cedente Pagador
                         ,pr_cdcooper => pr_cdcooper
                         ,pr_flaprcoo => 1
                         ,pr_dsdetres => (TRIM(to_char(vr_liqpagcd, 'FM999G999G999G990D00'))) -- Porcentagem da Cedente Pagador
                         ,pr_nrdocmto => rw_craptdb.nrdocmto   -- Conta
                         ,pr_nrcnvcob => rw_craptdb.nrcnvcob   -- Convenio
                         ,pr_nrdctabb => rw_craptdb.nrdctabb   -- Conta base do banco
                         ,pr_cdbandoc => rw_craptdb.cdbandoc
                         ,pr_dscritic => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
                         
         -- Salva as informa��es da CRAPABT => LIQUIDEZ GERAL                     
         pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                         ,pr_cdoperad => pr_cdoperad
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_dsrestri => '' 
                         ,pr_nrseqdig => 20
                         ,pr_cdcooper => pr_cdcooper
                         ,pr_flaprcoo => 1
                         ,pr_dsdetres => (TRIM(to_char(vr_liqgeral, 'FM999G999G999G990D00'))) -- Porcentagem da Liquidez Geral
                         ,pr_nrdocmto => rw_craptdb.nrdocmto   -- Conta
                         ,pr_nrcnvcob => rw_craptdb.nrcnvcob   -- Convenio
                         ,pr_nrdctabb => rw_craptdb.nrdctabb   -- Conta base do banco
                         ,pr_cdbandoc => rw_craptdb.cdbandoc
                         ,pr_dscritic => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
      END LOOP;                
      
      EXCEPTION
      when vr_exc_erro THEN
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null THEN
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;

      when others then
           /* montar descri�ao de erro n�o tratado */
           pr_dscritic := 'erro n�o tratado na DSCT0003.pr_grava_restricoes_liberacao ' ||sqlerrm;
   END pc_grava_restricoes_liberacao;
   
   PROCEDURE pc_buscar_associado_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                   ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE  --> N�mero do CPF/CNPJ
                                   ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                   --------> OUT <--------
                                   ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                   ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                   ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                   ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                   ) is
 /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_buscar_associado_web
    Sistema  : Cred
    Sigla    :
    Autor    : Luis Fernando (GFT)
    Data     : Abril/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Procedure que Busca um associado pela conta ou pelo cpf/cnpj
  ---------------------------------------------------------------------------------------------------------------------*/
     -- Tratamento de erros
     vr_exc_erro exception;
     vr_cdcritic number;
     vr_dscritic VARCHAR2(100);
     -- variaveis de entrada vindas no xml
     vr_cdcooper integer;
     vr_cdoperad varchar2(100);
     vr_nmdatela varchar2(100);
     vr_nmeacao  varchar2(100);
     vr_cdagenci varchar2(100);
     vr_nrdcaixa varchar2(100);
     vr_idorigem varchar2(100);                          
     -- Checagem das entradas
     vr_nrdconta crapass.nrdconta%TYPE;
     vr_nrcpfcgc crapass.nrcpfcgc%TYPE;
     
     BEGIN
       pr_nmdcampo := NULL;
       pr_des_erro := 'OK';
       IF (pr_nrdconta IS NULL) THEN
          vr_nrdconta :=0;
       ELSE
          vr_nrdconta := pr_nrdconta;
       END IF;
       IF (pr_nrcpfcgc IS NULL) THEN
          vr_nrcpfcgc :=0;
       ELSE
          vr_nrcpfcgc := pr_nrcpfcgc;
       END IF;
       
       IF (vr_nrdconta=0 AND vr_nrcpfcgc=0) THEN
         vr_dscritic := 'Preencha a Conta ou o CPF/CNPJ';
         raise vr_exc_erro;
       END IF;
       
       gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);
                              
       OPEN cr_crapass (pr_cdcooper => vr_cdcooper,
                        pr_nrdconta => vr_nrdconta,
                        pr_nrcpfcgc => vr_nrcpfcgc
                       );
       FETCH cr_crapass INTO rw_crapass;
       IF (cr_crapass%NOTFOUND) THEN
         vr_dscritic := 'Associado n�o encontrado.';
         RAISE vr_exc_erro;
       END IF;
       
       -- Monta o xml de retorno do associado
       -- inicializar o clob
       vr_des_xml := null;
       dbms_lob.createtemporary(vr_des_xml, true);
       dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
       -- inicilizar as informa�oes do xml
       vr_texto_completo := null;
       
        /*Passou nas valida��es do bordero, do contrato e listou titulos. Come�a a montar o xml*/
       pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                      '<root><dados>');
       pc_escreve_xml('<associado>'||
                           '<nrdconta>' || rw_crapass.nrdconta || '</nrdconta>' ||
                           '<nmprimtl>' || rw_crapass.nmprimtl || '</nmprimtl>' ||
                           '<nrcpfcgc>' || rw_crapass.nrcpfcgc || '</nrcpfcgc>' ||
                      '</associado>');
                     
       pc_escreve_xml ('</dados></root>',true);
       pr_retxml := xmltype.createxml(vr_des_xml);
       exception
         when vr_exc_erro then
         /*  se foi retornado apenas c�digo */
             if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
                 /* buscar a descri�ao */
                 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
             end if;
             /* variavel de erro recebe erro ocorrido */
             pr_cdcritic := nvl(vr_cdcritic,0);
             pr_dscritic := vr_dscritic;

             -- Carregar XML padrao para variavel de retorno
             pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                            '<Root>' || 
                                              '<Erro>' || pr_dscritic || '</Erro>' || 
                                           '</Root>');
        when others then
             /* montar descri�ao de erro n�o tratado */
             pr_dscritic := 'Erro n�o tratado na dsct0003.pc_buscar_associado_web ' ||sqlerrm;
             -- Carregar XML padrao para variavel de retorno
             pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
   END pc_buscar_associado_web;
   
   
   
   PROCEDURE pc_rejeitar_bordero_web(pr_nrdconta  IN crapbdt.nrdconta%TYPE  --> Conta
                               		   ,pr_nrborder  IN crapbdt.nrborder%TYPE  --> Bordero

														         ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
														         ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
														         ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
														         ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
														         ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
														         ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  /* .............................................................................
    Programa: pc_rejeitar_bordero_web
    Sistema : AyllosWeb
    Sigla   : CRED
    Autor   : Andre Avila
    Data    : 27/04/2018                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para rejeitar bordero de desconto de titulos

    Alteracoes: 28/04/2018 - Ajuste para gerar xml. (Andre Avila) 
                                                     
  ............................................................................. */

    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
	
    -- Tratamento de erros
    vr_exc_erro  EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_rowid_log ROWID;
    
    -- Busca dados do bordero
      CURSOR cr_crapbdt (pr_cdcooper IN crapbdt.cdcooper%TYPE
                        ,pr_nrborder IN crapbdt.nrborder%TYPE) IS
        SELECT 
        crapbdt.cdcooper
        ,crapbdt.nrborder
        ,crapbdt.nrdconta
        ,crapbdt.rowid
        ,crapbdt.insitbdt
        ,crapbdt.insitapr
        FROM crapbdt
        WHERE crapbdt.cdcooper = pr_cdcooper
        AND   crapbdt.nrborder = pr_nrborder
        AND   crapbdt.nrdconta = pr_nrdconta;

      rw_crapbdt cr_crapbdt%ROWTYPE;

  BEGIN		
    pr_nmdcampo := NULL;
    pr_des_erro := 'OK';
    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCTO'
                              ,pr_action => NULL);	
	  
		gene0004.pc_extrai_dados(pr_xml      => pr_retxml
														,pr_cdcooper => vr_cdcooper
														,pr_nmdatela => vr_nmdatela
														,pr_nmeacao  => vr_nmeacao
														,pr_cdagenci => vr_cdagenci
														,pr_nrdcaixa => vr_nrdcaixa
														,pr_idorigem => vr_idorigem
														,pr_cdoperad => vr_cdoperad
														,pr_dscritic => vr_dscritic);	  
    
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

	  -- Busca a data do sistema
		OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
		FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
		CLOSE BTCH0001.cr_crapdat;

 		OPEN   cr_crapbdt (vr_cdcooper,pr_nrborder);
		FETCH cr_crapbdt INTO rw_crapbdt;
		

    IF cr_crapbdt%NOTFOUND THEN
      CLOSE cr_crapbdt;
      vr_dscritic := 'Erro Border� nao encontrado.';
      RAISE vr_exc_erro;
    END IF;

  CLOSE cr_crapbdt;

	   pc_valida_bordero(pr_cdcooper => vr_cdcooper
                     ,pr_nrborder => rw_crapbdt.nrborder
                     ,pr_cddeacao => 'REJEITAR'
                     ,pr_dscritic => vr_dscritic );
                                
    IF  vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
    END IF;


    pc_altera_status_bordero(pr_cdcooper => vr_cdcooper
                            ,pr_nrborder => pr_nrborder 
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_status   => 5                          -- estou considerando 5 como rejeitado
                            ,pr_insitapr => 5 
                            ,pr_cdoperej => vr_cdoperad                -- cdoperad que efetuou a rejei��o
                            ,pr_dtrejeit => rw_crapdat.dtmvtolt        -- data de rejei��o
                            ,pr_hrrejeit => to_char(sysdate,'SSSSS')   -- hora de rejei�o
	                          ,pr_dscritic => vr_dscritic                --se houver registro de cr�tica
                            );
                                
    IF  vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
    END IF;
	
    -- Altera a decisao de todos os titulos daquele bordero para NAO APROVADOS 
    UPDATE craptdb SET insittit = 0, insitapr = 2 WHERE nrborder = pr_nrborder AND cdcooper = vr_cdcooper AND nrdconta = pr_nrdconta;
  
    -- Efetua os inserts para apresentacao na tela VERLOG
    gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                        ,pr_dstransa => 'Rejeicao do bordero de Nro.: ' || pr_nrborder
                        ,pr_dttransa => trunc(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => to_char(SYSDATE,'SSSSS')
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'ATENDA'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_rowid_log);
    
		-- Efetuar commit
		COMMIT;

   pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                  '<Root><dsmensag>Bordero rejeitado com sucesso.</dsmensag></Root>');

	EXCEPTION
    WHEN vr_exc_erro THEN
      IF vr_cdcritic <> 0 AND trim(vr_dscritic) IS NULL THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      vr_dscritic := '<![CDATA['||vr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','�');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_efetuar_rejeicao: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','�');
      
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_rejeitar_bordero_web;
  
  
  PROCEDURE pc_virada_bordero (pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                 --------> OUT <--------
                                 ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                 ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                 ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                               ) IS
    /* .............................................................................
      Programa: pc_virada_bordero
      Sistema : AyllosWeb
      Sigla   : CRED
      Autor   : Luis Fernando (GFT)
      Data    : 07/05/2018                        Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Retorna se a cooperativa esta utilizando o sistema novo de bordero
                                                   
    ............................................................................. */
    -- Tratamento de erros
    vr_exc_erro exception;
    vr_cdcritic number;
    vr_dscritic VARCHAR2(100);
    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);
    --Variaveis da procedure
    vr_flgverbor INTEGER;
    BEGIN
      pr_nmdcampo := NULL;
      pr_des_erro := 'OK';
      -- Extrair dados do xml de entrada
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);	 
                              
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                ,pr_action => vr_nmeacao);	
  	   
      vr_flgverbor := fn_virada_bordero(vr_cdcooper);
      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informa�oes do xml
      vr_texto_completo := null;

      /*Passou nas valida��es do bordero, do contrato e listou titulos. Come�a a montar o xml*/
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados>');

      pc_escreve_xml('<cdcooper>' || vr_cdcooper || '</cdcooper>' ||
                     '<flgverbor>' || vr_flgverbor || '</flgverbor>');
                    
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a mem�ria alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    exception
      when vr_exc_erro then
           /*  se foi retornado apenas c�digo */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descri�ao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;

           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           /* montar descri�ao de erro n�o tratado */
           pr_dscritic := 'erro n�o tratado na DSCT0003.pc_virada_bordero ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    
  END pc_virada_bordero;  


 PROCEDURE pc_busca_titulos_vencidos(pr_cdcooper IN crapbdt.cdcooper%TYPE  --> Numero da Cooperativa
                                    ,pr_nrborder IN crapbdt.nrborder%TYPE  --> Numero do bordero 
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de movimentacao   
                                    --------> OUT <--------
                                    ,pr_qtregist          OUT INTEGER              --> Quantidade de registros encontrados
                                    ,pr_tab_tit_bordero   OUT  typ_tab_tit_bordero --> Tabela de retorno
                                    ,pr_cdcritic OUT PLS_INTEGER                   --> C�digo da cr�tica
                                    ,pr_dscritic OUT VARCHAR2                      --> Descri��o da cr�tica  
                               )IS
     /*---------------------------------------------------------------------------------------------------------------------
       Programa : pc_busca_titulos_vencidos
       Sistema  : ATENDA
       Sigla    : CRED
       Autor    : Vitor Shimada Assanuma (GFT) 
       Data     : 11/05/2018
       Frequencia: Sempre que for chamado
       Objetivo  : Buscar Titulos Vencidos para Pagamento
     ---------------------------------------------------------------------------------------------------------------------*/
     
     -- Cursor dos titulos vencidos de um bordero usando a data de movimentacao atual do sistema
     CURSOR cr_craptdb IS
       SELECT  (vltitulo - vlsldtit) AS vlpago
              ,(vlmtatit - vlpagmta) AS vlmulta
              ,(vlmratit - vlpagmra) AS vlmora
              ,(vliofcpl - vlpagiof) AS vliof
              ,(vlsldtit + (vlmtatit - vlpagmta) + (vlmratit - vlpagmra)+ (vliofcpl - vlpagiof)) AS  vlpagar
              ,tdb.*
         FROM craptdb tdb, crapbdt bdt
        WHERE tdb.cdcooper = bdt.cdcooper
          AND tdb.nrdconta = bdt.nrdconta
          AND tdb.nrborder = bdt.nrborder
          AND gene0005.fn_valida_dia_util(pr_cdcooper, tdb.dtvencto) < pr_dtmvtolt
          AND tdb.nrborder = pr_nrborder
          AND tdb.nrdconta = pr_nrdconta
          AND tdb.cdcooper = pr_cdcooper
          AND tdb.insittit = 4  -- liberado
          AND bdt.flverbor = 1; -- bordero liberado na nova vers�o;
     rw_craptdb cr_craptdb%rowtype;
     
     BEGIN
       -- Contador de resultados
       pr_qtregist := 0;
       
       -- Leitura dos titulos do bordero vencidos     
       OPEN cr_craptdb;
       LOOP
         FETCH cr_craptdb INTO rw_craptdb;
         EXIT WHEN cr_craptdb%NOTFOUND;
         
         -- A quantidade e indice dos registros encontrados
         pr_qtregist := pr_tab_tit_bordero.count + 1;
         
         -- Tabela de resultados
         pr_tab_tit_bordero(pr_qtregist).nrdocmto := rw_craptdb.nrdocmto;
         pr_tab_tit_bordero(pr_qtregist).dtvencto := rw_craptdb.dtvencto;
         pr_tab_tit_bordero(pr_qtregist).vltitulo := rw_craptdb.vltitulo;
         pr_tab_tit_bordero(pr_qtregist).insittit := rw_craptdb.insittit;
         pr_tab_tit_bordero(pr_qtregist).nrtitulo := rw_craptdb.nrtitulo; -- Numero sequencial dos titulos dentro de um bordero
         pr_tab_tit_bordero(pr_qtregist).vlpago   := rw_craptdb.vlpago;   -- Valor pago (Vltit - VlSldTit)
         pr_tab_tit_bordero(pr_qtregist).vlsldtit := rw_craptdb.vlsldtit; -- Saldo Devedor
         pr_tab_tit_bordero(pr_qtregist).vlmtatit := rw_craptdb.vlmtatit; -- Valor da Multa
         pr_tab_tit_bordero(pr_qtregist).vlpagmta := rw_craptdb.vlpagmta; -- Valor pago da Multa
         pr_tab_tit_bordero(pr_qtregist).vlmulta  := rw_craptdb.vlmulta;  -- Diferenca do valor com o pago da Multa
         pr_tab_tit_bordero(pr_qtregist).vlmratit := rw_craptdb.vlmratit; -- Valor de Mora
         pr_tab_tit_bordero(pr_qtregist).vlpagmra := rw_craptdb.vlpagmra; -- Valor pago de MOra
         pr_tab_tit_bordero(pr_qtregist).vlmora   := rw_craptdb.vlmora;   -- Diferenca do valor com o pago da Mora
         pr_tab_tit_bordero(pr_qtregist).vliofcpl := rw_craptdb.vliofcpl; -- Valor do IOF Complementar
         pr_tab_tit_bordero(pr_qtregist).vlpagiof := rw_craptdb.vlpagiof; -- Valor pago do IOF Complementar
         pr_tab_tit_bordero(pr_qtregist).vliof    := rw_craptdb.vliof;    -- Diferenca do valor com o pago do IOF
         pr_tab_tit_bordero(pr_qtregist).vlpagar  := rw_craptdb.vlpagar;  -- Soma do saldo com as multas 
       END LOOP;
       CLOSE cr_craptdb;

 EXCEPTION
  WHEN OTHERS THEN
       pr_cdcritic := 0;
       pr_dscritic := 'Erro geral na rotina dsct0003.pc_busca_titulos_vencidos: '||SQLERRM;
 END pc_busca_titulos_vencidos;
 
 
 PROCEDURE pc_busca_titulos_vencidos_web(pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                    ,pr_nrborder IN crapbdt.nrborder%TYPE  --> Numero do bordero           
                                    ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                    --------> OUT <--------
                                    ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                    ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                    ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                    ) IS
     /*---------------------------------------------------------------------------------------------------------------------
       Programa : pc_busca_titulos_vencidos_web
       Sistema  : ATENDA
       Sigla    : CRED
       Autor    : Vitor Shimada Assanuma (GFT) 
       Data     : 11/05/2018
       Frequencia: Sempre que for chamado
       Objetivo  : Buscar Titulos Vencidos para Pagamento
     ---------------------------------------------------------------------------------------------------------------------*/
     -- Vari�vel de cr�ticas
     vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
     vr_dscritic varchar2(1000);        --> Desc. Erro
     
     -- Tratamento de erros
     vr_exc_erro EXCEPTION;
     
     -- variaveis de retorno
     vr_tab_tit_bordero typ_tab_tit_bordero;
     
     -- Variaveis de entrada vindas no XML
     vr_cdcooper INTEGER;
     vr_qtregist INTEGER;
     vr_index    INTEGER;
     vr_cdoperad VARCHAR2(100);
     vr_nmdatela VARCHAR2(100);
     vr_nmeacao  VARCHAR2(100);
     vr_cdagenci VARCHAR2(100);
     vr_nrdcaixa VARCHAR2(100);
     vr_idorigem VARCHAR2(100);
   
     BEGIN 
       pr_nmdcampo := NULL;
       pr_des_erro := 'OK';
       -- Leitura dos dados
       gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

       -- Leitura do calend�rio da cooperativa
       OPEN  btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
       FETCH btch0001.cr_crapdat into rw_crapdat;
       CLOSE btch0001.cr_crapdat;
       
       -- Preenche a tabela com os dados do bordero
       pc_busca_titulos_vencidos(vr_cdcooper
                                ,pr_nrborder
                                ,pr_nrdconta
                                ,rw_crapdat.dtmvtolt --> Data de movimentacao do sistema
                                --------> OUT <--------
                                ,vr_qtregist        --> Quantidade de registros encontrados
                                ,vr_tab_tit_bordero --> Tabela de retorno dos t�tulos encontrados
                                ,vr_cdcritic        --> C�digo da cr�tica
                                ,vr_dscritic        --> Descri��o da cr�tica
                              );
       IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NOT NULL THEN
         RAISE vr_exc_erro;
       END IF;
       -- Inicializar o clob
       vr_des_xml := null;
       dbms_lob.createtemporary(vr_des_xml, true);
       dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      
       -- inicilizar as informa�oes do xml
       pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                             '<root><dados qtregist="' || vr_qtregist ||'" >');
                             
       -- Ler os registros de titulos e incluir no xml
       vr_index := vr_tab_tit_bordero.first;
                             
       -- Leitura dos registros
       WHILE vr_index IS NOT NULL LOOP 
         pc_escreve_xml('<inf>'||
                           '<nrdocmto>' || vr_tab_tit_bordero(vr_index).nrdocmto || '</nrdocmto>' ||
                           '<dtvencto>' || to_char(vr_tab_tit_bordero(vr_index).dtvencto, 'DD/MM/RRRR') || '</dtvencto>' ||
                           '<nrtitulo>' || vr_tab_tit_bordero(vr_index).nrtitulo || '</nrtitulo>' ||
                           '<vltitulo>' || vr_tab_tit_bordero(vr_index).vltitulo || '</vltitulo>' ||
                           '<vlpago>'   || vr_tab_tit_bordero(vr_index).vlpago   || '</vlpago>'   ||
                           '<vlmulta>'  || vr_tab_tit_bordero(vr_index).vlmulta  || '</vlmulta>'  ||
                           '<vlmora>'   || vr_tab_tit_bordero(vr_index).vlmora   || '</vlmora>'   ||
                           '<vliof>'    || vr_tab_tit_bordero(vr_index).vliof    || '</vliof>'    ||
                           '<vlsldtit>' || vr_tab_tit_bordero(vr_index).vlsldtit || '</vlsldtit>' ||
                           '<vlpagar>'  || vr_tab_tit_bordero(vr_index).vlpagar  || '</vlpagar>'  ||
                        '</inf>'
                      );
         vr_index := vr_tab_tit_bordero.next(vr_index);
       END LOOP;
       pc_escreve_xml ('</dados></root>',true);
       pr_retxml := xmltype.createxml(vr_des_xml); 
        
       /* liberando a mem�ria alocada pro clob */
       dbms_lob.close(vr_des_xml);
       dbms_lob.freetemporary(vr_des_xml);         
EXCEPTION
  WHEN vr_exc_erro THEN
       IF  vr_cdcritic <> 0 THEN
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       END IF;
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;

  WHEN OTHERS THEN
       pr_dscritic := 'Erro geral na rotina dsct0003.pc_inserir_lancamento_bordero: '||SQLERRM;        
 END pc_busca_titulos_vencidos_web;
 
 PROCEDURE pc_calcula_possui_saldo (pr_nrdconta     IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                   ,pr_nrborder     IN crapbdt.nrborder%TYPE  --> Numero do bordero   
                                   ,pr_arrtitulo   IN VARCHAR2               --> Lista dos titulos
                                   ,pr_xmllog       IN VARCHAR2               --> XML com informa��es de LOG
                                   --------> OUT <--------
                                   ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                   ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                   ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                   ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                 ) IS
    /*---------------------------------------------------------------------------------------------------------------------
      Programa : pc_calcula_possui_saldo
      Sistema  : 
      Sigla    : CRED
      Autor    : Vitor Shimada Assanuma (GFT)
      Data     : 19/05/2018
      Frequencia: Sempre que for chamado
      Objetivo  : Buscar o Saldo em Conta do cooperado e verificar a alcada do operador
    ---------------------------------------------------------------------------------------------------------------------*/
    -- Vari�vel de cr�ticas
    vr_dscritic varchar2(1000);        --> Desc. Erro
                  
    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
                  
         
    -- Variaveis de entrada vindas no XML
    vr_cdcooper INTEGER;
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_cdoperad VARCHAR2(100);
    
    vr_total    NUMBER(25,2);
    vr_pagar    NUMBER(25,2);
    vr_possui_saldo INTEGER;
    vr_mensagem_ret VARCHAR(100);
    
    -- Variaveis do calculo de saldo
    pr_vllimcre crapass.vllimcre%TYPE;
    pr_des_reto VARCHAR2(5);
    pr_tab_sald EXTR0001.typ_tab_saldos;
    pr_tab_erro GENE0001.typ_tab_erro;
    
    -- Variavel do array dos titulos
    vr_nrtitulo  GENE0002.typ_split;
    vr_index     INTEGER;
    
    -- Cursor para pegar a alcada do operador
    CURSOR cr_crapope(vr_cdcooper IN craplot.cdcooper%TYPE
                     ,vr_cdoperad IN crapope.cdoperad%TYPE
                   ) IS
       SELECT  *
       FROM  crapope ope
       WHERE ope.cdcooper = vr_cdcooper
             AND ope.cdoperad = UPPER(vr_cdoperad)
    ;rw_crapope cr_crapope%rowtype;
    
    BEGIN   
       pr_nmdcampo := NULL;
       pr_des_erro := 'OK';
       -- Variavel de verificacao se possui saldo suficiente para os titulos 
       vr_possui_saldo := 0;       
          
       -- Leitura dos dados
       gene0004.pc_extrai_dados(pr_xml     => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
                              
      -- Leitura do calend�rio da cooperativa
      OPEN  btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat into rw_crapdat;
      CLOSE btch0001.cr_crapdat;
      
      -- Limite da conta
      SELECT vllimcre INTO pr_vllimcre FROM crapass WHERE nrdconta = pr_nrdconta AND cdcooper = vr_cdcooper;
      
       extr0001.pc_obtem_saldo_dia(pr_cdcooper => vr_cdcooper
                              ,pr_rw_crapdat => rw_crapdat
                              ,pr_cdagenci   => vr_cdagenci
                              ,pr_nrdcaixa   => vr_nrdcaixa
                              ,pr_cdoperad   => vr_cdoperad
                              ,pr_nrdconta   => pr_nrdconta
                              ,pr_vllimcre   => pr_vllimcre
                              ,pr_dtrefere   => rw_crapdat.dtmvtolt
                              ,pr_flgcrass   => TRUE
                              ,pr_tipo_busca => 'A' /* I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1 */
                              ,pr_des_reto   => pr_des_reto --> OK ou NOK
                              ,pr_tab_sald   => pr_tab_sald
                              ,pr_tab_erro   => pr_tab_erro);

       -- Quebra a string de numero dos titulos selecionados em um array
       vr_nrtitulo := gene0002.fn_quebra_string(pr_string  => pr_arrtitulo,
                                                 pr_delimit => ',');
                         
       vr_total := 0;
       -- Verifica se foi passado o numero dos titulos e itera eles para pegar a somatoria
       IF vr_nrtitulo.count() > 0 THEN
         vr_index := vr_nrtitulo.first;
         WHILE vr_index IS NOT NULL LOOP
           -- Puxa o valor do titulo
           SELECT (vlsldtit + (vlmtatit - vlpagmta) + (vlmratit - vlpagmra)+ (vliofcpl - vlpagiof)) AS valor INTO vr_pagar FROM craptdb 
           WHERE nrtitulo = vr_nrtitulo(vr_index) AND cdcooper = vr_cdcooper AND nrdconta = pr_nrdconta AND nrborder = pr_nrborder;
           
           -- Somador
           vr_total := vr_total + vr_pagar;
           
           -- Contador
           vr_index := vr_nrtitulo.next(vr_index); 
         END LOOP;
       END IF;
       
       
       -- Caso o saldo + limite seja maior que o custo da soma dos titulos
       IF vr_total <= ( pr_tab_sald(0).vlsddisp + pr_vllimcre ) THEN
          vr_possui_saldo := 1; -- Possui Saldo
            vr_mensagem_ret := 'Utilizando Saldo do Cooperado.';
       ELSE -- Caso nao tenha saldo, verifica a alcada do operador
          OPEN  cr_crapope(vr_cdcooper => vr_cdcooper, vr_cdoperad => vr_cdoperad);
          FETCH cr_crapope into rw_crapope;
          IF vr_total <= rw_crapope.vlpagchq THEN
            vr_possui_saldo := 2; -- Possui Alcada
            vr_mensagem_ret := 'Utilizando alcada do Operador.';
          CLOSE cr_crapope;
          ELSE
            vr_possui_saldo := 0;
            vr_mensagem_ret := 'Saldo e alcada insuficientes.';
          END IF;
       END IF;
       
       -- Inicializar o clob
       vr_des_xml := null;
       dbms_lob.createtemporary(vr_des_xml, true);
       dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      
       -- inicilizar as informa�oes do xml
       pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                             '<root>'||
                                 '<dados>'||
                                     '<inf>'||
                                         '<possui_saldo>' || vr_possui_saldo || '</possui_saldo>'||
                                         '<mensagem>'     || vr_mensagem_ret || '</mensagem>'||
                                     '</inf>'||
                                 '</dados>'||
                             '</root>',true);
       pr_retxml := xmltype.createxml(vr_des_xml); 
        
       /* liberando a mem�ria alocada pro clob */
       dbms_lob.close(vr_des_xml);
       dbms_lob.freetemporary(vr_des_xml);
EXCEPTION
  WHEN vr_exc_erro THEN
       pr_cdcritic := 0;
       pr_dscritic := vr_dscritic;

  WHEN OTHERS THEN
       pr_cdcritic := 0;
       pr_dscritic := 'Erro geral na rotina dsct0003.pc_calcula_possui_saldo: '||SQLERRM;
 END pc_calcula_possui_saldo;

 PROCEDURE pc_pagar_titulos_vencidos (pr_nrdconta         IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                     ,pr_nrborder         IN crapbdt.nrborder%TYPE  --> Numero do bordero   
                                     ,pr_flavalista       IN VARCHAR2               --> Caso seja pagamento com avalista
                                     ,pr_arrtitulo        IN VARCHAR2               --> Lista dos titulos
                                     ,pr_xmllog           IN VARCHAR2               --> XML com informa��es de LOG
                                     --------> OUT <--------
                                     ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                     ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                     ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                    ) IS
     /*---------------------------------------------------------------------------------------------------------------------
       Programa : pc_pagar_titulos_vencidos
       Sistema  : 
       Sigla    : CRED
       Autor    : Vitor Shimada Assanuma (GFT)
       Data     : 19/05/2018
       Frequencia: Sempre que for chamado
       Objetivo  : Efetuar o Pagamento dos Titulos Vencidos

       Altera��o : 19/05/2018 - Cria��o (Vitor Shimada (GFT))

                   20/06/2018 - Substituido o processo de pagamento pela chamada da procedure pc_pagar_titulo (Paulo Penteado (GFT) 
       
     ---------------------------------------------------------------------------------------------------------------------*/
     vr_vlpagmto craptdb.vltitulo%TYPE;
     
     -- Vari�vel de cr�ticas
     vr_cdcritic crapcri.cdcritic%TYPE;
     vr_dscritic crapcri.dscritic%TYPE;
     
     -- Variaveis de entrada vindas no XML
     vr_cdcooper INTEGER;
     vr_nmdatela VARCHAR2(100);
     vr_nmeacao  VARCHAR2(100);
     vr_cdagenci VARCHAR2(100);
     vr_nrdcaixa VARCHAR2(100);
     vr_idorigem VARCHAR2(100);
     vr_cdoperad VARCHAR2(100);

     vr_exc_erro EXCEPTION;
     vr_sql      VARCHAR2(32767);

     type tpy_ref_tdb is ref cursor;
     cr_tab_tdb       tpy_ref_tdb;

     -- Cursor dos titulos para ser preenchido pelo comando SQL dentro do programa
     CURSOR cr_craptdb IS
            SELECT (vlmtatit - vlpagmta) AS vlmulta
                   ,(vlmratit - vlpagmra) AS vlmora
                   ,(vliofcpl - vlpagiof) AS vliof
                   ,craptdb.* 
            FROM craptdb;
     rw_craptdb cr_craptdb%ROWTYPE;     
  BEGIN
    pr_nmdcampo := NULL;
    -- Leitura dos dados
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Busca a data do sistema
    OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;

    -- Busca os titulos selecionados
    vr_sql := 'SELECT   (vlmtatit - vlpagmta) AS vlmulta' ||
                      ',(vlmratit - vlpagmra) AS vlmora'  ||
                      ',(vliofcpl - vlpagiof) AS vliof'   ||
                      ',craptdb.* '||
                 ' FROM craptdb '  ||
                 ' WHERE '||
                   ' craptdb.nrborder = :nrborder ' || 
                   ' AND craptdb.nrdconta =  :nrdconta ' ||
                   ' AND craptdb.cdcooper = :cdcooper ' ||
                   ' AND craptdb.nrtitulo IN ('||pr_arrtitulo||')';
    OPEN  cr_tab_tdb 
    FOR   vr_sql 
    USING pr_nrborder, pr_nrdconta, vr_cdcooper;
    LOOP
          FETCH cr_tab_tdb INTO rw_craptdb;
          EXIT  WHEN cr_tab_tdb%NOTFOUND;
          
          vr_vlpagmto := rw_craptdb.vlsldtit; 
          
          pc_pagar_titulo(pr_cdcooper => vr_cdcooper
                         ,pr_cdagenci => vr_cdagenci
                         ,pr_nrdcaixa => vr_nrdcaixa
                         ,pr_idorigem => vr_idorigem
                         ,pr_cdoperad => vr_cdoperad
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrborder => pr_nrborder
                         ,pr_cdbandoc => rw_craptdb.cdbandoc
                         ,pr_nrdctabb => rw_craptdb.nrdctabb
                         ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                         ,pr_nrdocmto => rw_craptdb.nrdocmto
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         ,pr_inproces => rw_crapdat.inproces
                         ,pr_cdorigpg => 3 --Tela PAGAR
                         ,pr_indpagto => NULL -- n�o se aplica para origem de pagamento 3
                         ,pr_flpgtava => CASE WHEN pr_flavalista = 'false' THEN 0 ELSE 1 END
                         ,pr_vlpagmto => vr_vlpagmto
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);

          -- Condicao para verificar se houve critica                             
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
    END LOOP;
    CLOSE cr_tab_tdb;  

    -- Commita toda a transacao     
    COMMIT;

    -- Caso d� tudo certo, retorna o xml com OK
    pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><dsmensag>1</dsmensag></Root>');
  EXCEPTION
    WHEN vr_exc_erro THEN
         IF  vr_cdcritic <> 0 THEN
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         END IF;
         pr_des_erro := 'NOK';
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := vr_dscritic;
         pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> '||
                                          '<Root><Erro>'||pr_dscritic||'</Erro></Root>');
         ROLLBACK;
    WHEN OTHERS THEN
         pr_des_erro := 'NOK';
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := 'Erro geral na rotina dsct0003.pc_pagar_titulos_vencidos: '||SQLERRM;
         pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> '||
                                          '<Root><Erro>'||pr_dscritic||'</Erro></Root>');
         ROLLBACK;
 END pc_pagar_titulos_vencidos;

 PROCEDURE pc_calcula_liquidez(pr_cdcooper     IN craptdb.cdcooper%TYPE
                            ,pr_nrdconta     IN craptdb.nrdconta%TYPE
                            ,pr_nrinssac     IN crapcob.nrinssac%TYPE DEFAULT NULL 
                            ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE 
                            ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                            ,pr_qtcarpag     IN NUMBER
                            -- OUT --
                            ,pr_pc_cedpag    OUT NUMBER
                            ,pr_qtd_cedpag   OUT NUMBER
                            ,pr_pc_conc      OUT NUMBER
                            ,pr_qtd_conc     OUT NUMBER
                            ,pr_pc_geral     OUT NUMBER
                            ,pr_qtd_geral    OUT NUMBER) IS
   /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_calcula_liquidez
    Sistema  : CRED
    Sigla    : CRED
    Autor    : Vitor Shimada Assanuma (GFT)
    Data     : 24/05/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Procedure para centralizar os calculos de Liquidez retornando a quantidade e porcentagens
    ---------------------------------------------------------------------------------------------------------------------*/
    -- CALCULO DA CONCENTRACAO DO PAGADOR
    CURSOR cr_concentracao IS
      SELECT 
        NVL((SUM(CASE WHEN (tdb.nrinssac=pr_nrinssac) THEN 1 ELSE 0 END)/COUNT(1))*100, 0) AS qtd_conc,
        NVL((SUM(CASE WHEN (tdb.nrinssac=pr_nrinssac) THEN vltitulo ELSE 0 END)/SUM(vltitulo))*100, 0) AS pc_conc
       FROM   craptdb tdb -- Titulos do Bordero
       WHERE 
       (tdb.insittit = 4 OR (tdb.insittit=0 AND tdb.insitapr<>2))
       AND    tdb.cdcooper = pr_cdcooper
       AND    tdb.nrdconta = pr_nrdconta
       --     N�o considerar como t�tulo pago, os liquidados em conta corrente do cedente, ou seja, pagos pelo pr�prio emitente
       AND    NOT EXISTS( SELECT 1
                          FROM   craptit tit
                          WHERE  tit.cdcooper = tdb.cdcooper
                          AND    tit.dtmvtolt = tdb.dtdpagto
                          AND    tdb.nrdconta = substr(upper(tit.dscodbar), 26, 8)
                          AND    tdb.nrcnvcob = substr(upper(tit.dscodbar), 20, 6)
                          AND    tit.cdbandst = 85
                          AND    tit.cdagenci IN (90,91) )
    ;
    rw_concentracao cr_concentracao%ROWTYPE;
    
    -- CALCULO DA LIQUIDEZ CEDENTE PAGADOR
    CURSOR cr_liquidez_pagador IS
      SELECT 
        (SUM(CASE WHEN (cob.dtdpagto IS NOT NULL AND (cob.dtdpagto<=(cob.dtvencto+pr_qtcarpag))) THEN 1 ELSE 0 END)/COUNT(1))*100 AS qtd_cedpag,
        (SUM(CASE WHEN (cob.dtdpagto IS NOT NULL AND (cob.dtdpagto<=(cob.dtvencto+pr_qtcarpag))) THEN vltitulo ELSE 0 END)/SUM(vltitulo))*100 AS pc_cedpag
       FROM   crapcob cob -- Titulos do Bordero
       WHERE cob.dtvencto  BETWEEN pr_dtmvtolt_de AND pr_dtmvtolt_ate -- No intervalo de data da liquidez
--       AND    cob.dtresgat IS NULL 
--       AND    cob.dtlibbdt IS NOT NULL                   -- Somente os titulos que realmente foram descontados
       AND    cob.cdcooper = pr_cdcooper
       AND    cob.nrdconta = pr_nrdconta
       AND    cob.nrinssac = pr_nrinssac
       --     N�o considerar como t�tulo pago, os liquidados em conta corrente do cedente, ou seja, pagos pelo pr�prio emitente
       AND    NOT EXISTS( SELECT 1
                          FROM   craptit tit
                          WHERE  tit.cdcooper = cob.cdcooper
                          AND    tit.dtmvtolt = cob.dtdpagto
                          AND    cob.nrdconta = substr(upper(tit.dscodbar), 26, 8)
                          AND    cob.nrcnvcob = substr(upper(tit.dscodbar), 20, 6)
                          AND    tit.cdbandst = 85
                          AND    tit.cdagenci IN (90,91) )
    ;
    rw_liquidez_pagador cr_liquidez_pagador%ROWTYPE;
    
    -- CALCULO  DA LIQUIDEZ GERAL
    CURSOR cr_liquidez_geral IS
      SELECT 
        (SUM(CASE WHEN (cob.dtdpagto IS NOT NULL AND (cob.dtdpagto<=(cob.dtvencto+pr_qtcarpag))) THEN 1 ELSE 0 END)/COUNT(1))*100 AS qtd_geral,
        (SUM(CASE WHEN (cob.dtdpagto IS NOT NULL AND (cob.dtdpagto<=(cob.dtvencto+pr_qtcarpag))) THEN vltitulo ELSE 0 END)/SUM(vltitulo))*100 AS pc_geral
       FROM   crapcob cob -- Titulos do Bordero
       WHERE cob.dtvencto BETWEEN pr_dtmvtolt_de AND pr_dtmvtolt_ate -- No intervalo de data da liquidez
--       AND    cob.dtresgat IS NULL 
--       AND    cob.dtlibbdt IS NOT NULL                   -- Somente os titulos que realmente foram descontados
       AND    cob.cdcooper = pr_cdcooper
       AND    cob.nrdconta = pr_nrdconta
       --     N�o considerar como t�tulo pago, os liquidados em conta corrente do cedente, ou seja, pagos pelo pr�prio emitente
       AND    NOT EXISTS( SELECT 1
                          FROM   craptit tit
                          WHERE  tit.cdcooper = cob.cdcooper
                          AND    tit.dtmvtolt = cob.dtdpagto
                          AND    cob.nrdconta = substr(upper(tit.dscodbar), 26, 8)
                          AND    cob.nrcnvcob = substr(upper(tit.dscodbar), 20, 6)
                          AND    tit.cdbandst = 85
                          AND    tit.cdagenci IN (90,91) )
    ;
    rw_liquidez_geral cr_liquidez_geral%ROWTYPE;
    
  BEGIN
    IF (pr_nrinssac IS NOT NULL) THEN
      OPEN cr_concentracao;
      FETCH cr_concentracao INTO rw_concentracao;
      CLOSE cr_concentracao;
      pr_pc_conc    := rw_concentracao.pc_conc;
      pr_qtd_conc   := rw_concentracao.qtd_conc;
    
      OPEN cr_liquidez_pagador;
      FETCH cr_liquidez_pagador INTO rw_liquidez_pagador;
      CLOSE cr_liquidez_pagador;
      pr_pc_cedpag  := CASE WHEN nvl(rw_liquidez_pagador.pc_cedpag,0) = 0 THEN 100 ELSE rw_liquidez_pagador.pc_cedpag END;
      pr_qtd_cedpag := CASE WHEN nvl(rw_liquidez_pagador.qtd_cedpag,0) = 0 THEN 100 ELSE rw_liquidez_pagador.qtd_cedpag END;
    ELSE 
      pr_pc_conc    := 0;
      pr_qtd_conc   := 0;
      pr_pc_cedpag  := 0;
      pr_qtd_cedpag := 0;
    END IF;
    
    OPEN cr_liquidez_geral;
    FETCH cr_liquidez_geral INTO rw_liquidez_geral;
    CLOSE cr_liquidez_geral;
    
    pr_pc_geral   := CASE WHEN nvl(rw_liquidez_geral.pc_geral,0) = 0 THEN 100 ELSE rw_liquidez_geral.pc_geral END;
    pr_qtd_geral  := CASE WHEN nvl(rw_liquidez_geral.qtd_geral,0) = 0 THEN 100 ELSE rw_liquidez_geral.qtd_geral END;
 END pc_calcula_liquidez;
  
  PROCEDURE pc_calcula_atraso_tit(pr_cdcooper    IN crapcop.cdcooper%TYPE      --Codigo Cooperativa
                                 ,pr_nrdconta    IN craptdb.nrdconta%TYPE      --N�mero da conta do cooperado
                                 ,pr_nrborder    IN craptdb.nrborder%TYPE      --N�mero do border�
                                 ,pr_cdbandoc    IN craptdb.cdbandoc%TYPE      --Codigo do banco impresso no boleto
                                 ,pr_nrdctabb    IN craptdb.nrdctabb%TYPE      --Numero da conta base do titulo
                                 ,pr_nrcnvcob    IN craptdb.nrcnvcob%TYPE      --Numero do convenio de cobranca
                                 ,pr_nrdocmto    IN craptdb.nrdocmto%TYPE      --Numero do documento
                                 ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE      --Data Movimento
                                 ,pr_vlmtatit    OUT NUMBER                    --Valor da multa por atraso
                                 ,pr_vlmratit    OUT NUMBER                    --Valor dos juros de mora
                                 ,pr_vlioftit    OUT NUMBER                    --Valor do IOF complementar por atraso
                                 ,pr_cdcritic    OUT INTEGER                   --Codigo Critica
                                 ,pr_dscritic    OUT VARCHAR2) IS              --Descricao Critica
                                 
  /* ................................................................................

     Programa: pc_calcula_atraso_tit       Antiga: 
     Sistema : Cr�dito
     Sigla   : CRED

     Autor   : Lucas Lazari (GFT)
     Data    : 24/05/18                        Ultima atualizacao: --/--/----

     Dados referentes ao programa: Calcula os valores de juros, multa e IOF de um t�tulo em atraso

     Frequencia: Sempre que for chamado
     Objetivo  :  

     Alteracoes: 
  ..................................................................................*/ 
  
    /* cursores */
    CURSOR cr_crapbdt (pr_cdcooper IN crapbdt.cdcooper%type
                      ,pr_nrborder IN crapbdt.nrborder%type) IS
      SELECT crapbdt.txmensal
            ,crapbdt.flverbor
            ,crapbdt.vltaxiof
            ,crapbdt.vltxmult
            ,crapbdt.vltxmora 
      FROM crapbdt
      WHERE crapbdt.cdcooper = pr_cdcooper
      AND   crapbdt.nrborder = pr_nrborder;
    rw_crapbdt cr_crapbdt%ROWTYPE;
    
    CURSOR cr_craptdb(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN craptdb.nrdconta%TYPE
                     ,pr_nrborder IN craptdb.nrborder%TYPE
                     ,pr_cdbandoc IN craptdb.cdbandoc%TYPE
                     ,pr_nrdctabb IN craptdb.nrdctabb%TYPE
                     ,pr_nrcnvcob IN craptdb.nrcnvcob%TYPE
                     ,pr_nrdocmto IN craptdb.nrdocmto%TYPE) IS
      SELECT craptdb.dtvencto,
             craptdb.dtlibbdt,
             craptdb.nrtitulo,
             craptdb.vltitulo,
             craptdb.vlliquid,
             craptdb.vlsldtit,
             craptdb.vliofcpl,
             craptdb.vlmtatit,
             craptdb.vlmratit,
             craptdb.vlpagiof,
             craptdb.vlpagmta,
             craptdb.vlpagmra
        FROM craptdb
       WHERE craptdb.cdcooper = pr_cdcooper
         AND craptdb.nrdconta = pr_nrdconta    
         AND craptdb.nrborder = pr_nrborder    
         AND craptdb.cdbandoc = pr_cdbandoc    
         AND craptdb.nrdctabb = pr_nrdctabb    
         AND craptdb.nrcnvcob = pr_nrcnvcob    
         AND craptdb.nrdocmto = pr_nrdocmto
         AND craptdb.insittit = 4;
    rw_craptdb cr_craptdb%ROWTYPE;
    
    -- Sumarizar os juros no desconto do cheque
    CURSOR cr_craptdb_total(pr_cdcooper IN craptdb.cdcooper%TYPE
                           ,pr_nrdconta IN craptdb.nrdconta%TYPE
                           ,pr_nrborder IN craptdb.nrborder%TYPE) IS
      SELECT NVL(SUM(craptdb.vlliquid),0)
        FROM craptdb
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrborder = pr_nrborder;
    vr_vltotal_liquido craptdb.vlliquid%TYPE;
    
    CURSOR cr_crapjur(pr_cdcooper IN crapjur.cdcooper%TYPE
                     ,pr_nrdconta IN crapjur.nrdconta%TYPE) IS
     SELECT crapjur.natjurid
           ,crapjur.tpregtrb
       FROM crapjur
      WHERE crapjur.cdcooper = pr_cdcooper
        AND crapjur.nrdconta = pr_nrdconta;
    rw_crapjur cr_crapjur%ROWTYPE;
    
    CURSOR cr_tbdsct_lancamento_bordero(pr_cdcooper tbdsct_lancamento_bordero.cdcooper%type
                                       ,pr_nrdconta tbdsct_lancamento_bordero.nrdconta%type
                                       ,pr_nrborder tbdsct_lancamento_bordero.nrborder%type
                                       ,pr_nrtitulo tbdsct_lancamento_bordero.nrtitulo%type) IS
      SELECT dtmvtolt
        FROM tbdsct_lancamento_bordero
       WHERE tbdsct_lancamento_bordero.cdcooper = pr_cdcooper
         AND tbdsct_lancamento_bordero.nrdconta = pr_nrdconta
         AND tbdsct_lancamento_bordero.nrborder = pr_nrborder
         AND tbdsct_lancamento_bordero.nrtitulo = pr_nrtitulo
         AND tbdsct_lancamento_bordero.cdhistor IN (2686,2688);
    rw_tbdsct_lancamento_bordero cr_tbdsct_lancamento_bordero%ROWTYPE;
    
    -- cursor gen�rico de calend�rio
    rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;
    
    /* vari�veis locais */
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    vr_txdiaria NUMBER; -- Taxa di�ria de juros de mora
    
    vr_dtmvtolt DATE;
    
    vr_vliofpri NUMBER;
    vr_vliofadi NUMBER;
    vr_vliofcpl NUMBER;
    
    vr_vltxiofatra NUMBER;
    vr_vlsldtit NUMBER;

    vr_flgimune PLS_INTEGER;
    
    /* exce��es */
    vr_exc_erro  EXCEPTION;

  BEGIN
  
    -- Leitura do calendario
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      vr_cdcritic := 1;
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    END IF;
    CLOSE BTCH0001.cr_crapdat;
  
    -- Valida exist�ncia do border� do respectivo t�tulo
    OPEN cr_crapbdt (pr_cdcooper => pr_cdcooper
                    ,pr_nrborder => pr_nrborder);
    FETCH cr_crapbdt INTO rw_crapbdt;
      
    IF cr_crapbdt%NOTFOUND THEN
      CLOSE cr_crapbdt;
      vr_cdcritic := 1166; --Bordero nao encontrado. 
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapbdt;
    
    -- Valida a exist�ncia do t�tulo
    OPEN cr_craptdb (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrborder => pr_nrborder
                    ,pr_cdbandoc => pr_cdbandoc
                    ,pr_nrdctabb => pr_nrdctabb
                    ,pr_nrcnvcob => pr_nrcnvcob
                    ,pr_nrdocmto => pr_nrdocmto);
    FETCH cr_craptdb INTO rw_craptdb;
    
    IF cr_craptdb%NOTFOUND THEN
      CLOSE cr_craptdb;
      vr_cdcritic := 1108; 
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_craptdb;
    
    vr_vltotal_liquido := 0;
    OPEN cr_craptdb_total(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrborder => pr_nrborder);
    FETCH cr_craptdb_total INTO vr_vltotal_liquido;
    CLOSE cr_craptdb_total;
    
    -- busca os dados do associado/cooperado para s� ent�o encontrar seus dados na tabela de par�metros
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    CLOSE cr_crapass;

    -- Busca dados de pessoa jur�dica
    OPEN cr_crapjur(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapjur INTO rw_crapjur;
    CLOSE cr_crapjur;    
    
    -- Calcular multa
    IF rw_craptdb.vlmtatit = 0 THEN
      pr_vlmtatit := ROUND(rw_craptdb.vlsldtit * (rw_crapbdt.vltxmult / 100),2);
    ELSE
      pr_vlmtatit := rw_craptdb.vlmtatit;
    END IF;
          
    -- Calculo da taxa de mora diaria
    vr_txdiaria :=  (POWER((rw_crapbdt.vltxmora / 100) + 1,(1 / 30)) - 1);
    
    vr_vlsldtit := rw_craptdb.vlsldtit;
    pr_vlmratit := rw_craptdb.vlmratit;
    
    -- Se j� houve pagamento de juros, pega a data do �ltimo pagamento de juros como base e acumula os juros do saldo devedor atual
    -- com o valor j� calculado at� ent�o
    vr_dtmvtolt := rw_craptdb.dtvencto;
    
    IF rw_craptdb.vlpagmra > 0 THEN
      FOR rw_tbdsct_lancamento_bordero IN cr_tbdsct_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                                                      ,pr_nrdconta => pr_nrdconta
                                                                      ,pr_nrborder => pr_nrborder
                                                                      ,pr_nrtitulo => rw_craptdb.nrtitulo) LOOP

        IF rw_tbdsct_lancamento_bordero.dtmvtolt > vr_dtmvtolt THEN
          vr_dtmvtolt := rw_tbdsct_lancamento_bordero.dtmvtolt;
        END IF;
    END LOOP;
    
      pr_vlmratit := NVL(rw_craptdb.vlpagmra + ROUND(vr_vlsldtit * vr_txdiaria * (pr_dtmvtolt - vr_dtmvtolt),2),0);
    ELSE
      pr_vlmratit := NVL(ROUND(vr_vlsldtit * vr_txdiaria * (pr_dtmvtolt - rw_craptdb.dtvencto),2),0);
    END IF;

    -- C�lculo do IOF
    TIOF0001.pc_calcula_valor_iof_prg (pr_tpproduto            => 2 -- Desconto de t�tulos
                                      ,pr_tpoperacao           => 2 -- Pagamento em atraso
                                      ,pr_cdcooper             => pr_cdcooper
                                      ,pr_nrdconta             => pr_nrdconta
                                      ,pr_inpessoa             => rw_crapass.inpessoa
                                      ,pr_natjurid             => rw_crapjur.natjurid
                                      ,pr_tpregtrb             => rw_crapjur.tpregtrb
                                      ,pr_dtmvtolt             => rw_crapdat.dtmvtolt
                                      ,pr_qtdiaiof             => (pr_dtmvtolt - rw_craptdb.dtvencto)
                                      ,pr_vloperacao           => rw_craptdb.vlliquid
                                      ,pr_vltotalope           => vr_vltotal_liquido
                                      ,pr_vltaxa_iof_atraso    => NVL(rw_crapbdt.vltaxiof,0)
                                      ,pr_vliofpri             => vr_vliofpri
                                      ,pr_vliofadi             => vr_vliofadi
                                      ,pr_vliofcpl             => vr_vliofcpl
                                      ,pr_vltaxa_iof_principal => vr_vltxiofatra
                                      ,pr_flgimune             => vr_flgimune
                                      ,pr_dscritic             => vr_dscritic);
    
    IF vr_dscritic IS NOT NULL THEN
      vr_dscritic := 'Erro realizar c�lculo do t�tulo em atraso : '||SQLERRM;
      RAISE vr_exc_erro;
    END IF;
    
    pr_vlioftit := NVL(ROUND(vr_vliofcpl, 2),0);
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
  END pc_calcula_atraso_tit;
  
  PROCEDURE pc_pagar_titulo( pr_cdcooper    IN crapcop.cdcooper%TYPE           --Codigo Cooperativa
                            ,pr_cdagenci    IN INTEGER                         --Codigo Agencia
                            ,pr_nrdcaixa    IN INTEGER                         --Numero Caixa
                            ,pr_idorigem    IN INTEGER                         --Origem sistema
                            ,pr_cdoperad    IN VARCHAR2                        --Codigo operador
                            ,pr_nrdconta    IN craptdb.nrdconta%TYPE           --N�mero da conta do cooperado
                            ,pr_nrborder    IN craptdb.nrborder%TYPE           --N�mero do border�
                            ,pr_cdbandoc    IN craptdb.cdbandoc%TYPE           --Codigo do banco impresso no boleto
                            ,pr_nrdctabb    IN craptdb.nrdctabb%TYPE           --Numero da conta base do titulo
                            ,pr_nrcnvcob    IN craptdb.nrcnvcob%TYPE           --Numero do convenio de cobranca
                            ,pr_nrdocmto    IN craptdb.nrdocmto%TYPE           --Numero do documento
                            ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE           --Data Movimento
                            ,pr_inproces    IN crapdat.inproces%TYPE DEFAULT 1 --Indicador do processo
                            ,pr_cdorigpg    IN NUMBER                DEFAULT 0 --C�digo da origem do processo de pagamento
                            ,pr_indpagto    IN crapcob.indpagto%TYPE DEFAULT 0 --Indica de onde vem o pagamento
                            ,pr_flpgtava    IN NUMBER                DEFAULT 0 --Pagamento efetuado pelo avalista 0-N�o 1-Sim
                            ,pr_vlpagmto    IN OUT NUMBER                      --Valor do pagamento
                            ,pr_cdcritic    OUT INTEGER                        --Codigo Critica
                            ,pr_dscritic    OUT VARCHAR2) IS                   --Descricao Critica
                                   
  /* ................................................................................
     Programa: pc_pagar_titulo_cc
     Sistema : Cr�dito
     Sigla   : CRED

     Autor   : Lucas Lazari (GFT)
     Data    : 24/05/18

     Dados referentes ao programa: 
     Frequencia: Sempre que for chamado
     Objetivo  :  Realiza o pagamento de um t�tulo atrav�s da conta corrente

               pr_cdorigpg: C�digo da origem do processo de pagamento
                            0 - Conta-Corrente (Raspada, ...)
                            1 - Pagamento (Baixa de cobran�a de t�tulos, ...)
                            2 - Pagamento COBTIT
                            3 - Tela PAGAR
                            
               pr_indpagto: Indica de onde vem o pagamento
                            0 - COMPE
                            1 - Caixa On-Line 
                            2 - ?????
                            3 - Internet
                            4 - TAA

     Alteracoes: 
  ..................................................................................*/ 
    
    /* CURSORES */
    
    CURSOR cr_crapbdt (pr_cdcooper IN crapbdt.cdcooper%type
                      ,pr_nrborder IN crapbdt.nrborder%type) IS
      SELECT crapbdt.txmensal
            ,crapbdt.flverbor
            ,crapbdt.vltaxiof
            ,crapbdt.vltxmult
            ,crapbdt.vltxmora 
      FROM crapbdt
      WHERE crapbdt.cdcooper = pr_cdcooper
      AND   crapbdt.nrborder = pr_nrborder;
    rw_crapbdt cr_crapbdt%ROWTYPE; 
    
    -- Sumarizar os juros no desconto do cheque
    CURSOR cr_craptdb_total(pr_cdcooper IN craptdb.cdcooper%TYPE
                           ,pr_nrdconta IN craptdb.nrdconta%TYPE
                           ,pr_nrborder IN craptdb.nrborder%TYPE) IS
      SELECT NVL(SUM(craptdb.vlliquid),0)
        FROM craptdb
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrborder = pr_nrborder;
    vr_vltotal_liquido craptdb.vlliquid%TYPE;
    
    CURSOR cr_craptdb(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN craptdb.nrdconta%TYPE
                     ,pr_nrborder IN craptdb.nrborder%TYPE
                     ,pr_cdbandoc IN craptdb.cdbandoc%TYPE
                     ,pr_nrdctabb IN craptdb.nrdctabb%TYPE
                     ,pr_nrcnvcob IN craptdb.nrcnvcob%TYPE
                     ,pr_nrdocmto IN craptdb.nrdocmto%TYPE) IS
      SELECT ROWID,
             craptdb.nrdocmto,
             craptdb.dtvencto,
             craptdb.dtlibbdt,
             craptdb.nrtitulo,
             craptdb.vltitulo,
             craptdb.vlsldtit,
             craptdb.vliofcpl,
             craptdb.vlmtatit,
             craptdb.vlmratit,
             craptdb.vlpagiof,
             craptdb.vlpagmta,
             craptdb.vlpagmra,
             craptdb.vlsldtit + (craptdb.vliofcpl - craptdb.vlpagiof) + (craptdb.vlmtatit - craptdb.vlpagmta) + (craptdb.vlmratit - craptdb.vlpagmra) AS vltitulo_total,
             (craptdb.vliofcpl - craptdb.vlpagiof) AS vliofcpl_restante,
             (craptdb.vlmtatit - craptdb.vlpagmta) AS vlmtatit_restante,
             (craptdb.vlmratit - craptdb.vlpagmra) AS vlmratit_restante
        FROM craptdb
       WHERE craptdb.cdcooper = pr_cdcooper
         AND craptdb.nrdconta = pr_nrdconta    
         AND craptdb.nrborder = pr_nrborder    
         AND craptdb.cdbandoc = pr_cdbandoc    
         AND craptdb.nrdctabb = pr_nrdctabb    
         AND craptdb.nrcnvcob = pr_nrcnvcob    
         AND craptdb.nrdocmto = pr_nrdocmto
         AND craptdb.insittit = 4;
    rw_craptdb cr_craptdb%ROWTYPE;  
    
    CURSOR cr_crapjur(pr_cdcooper IN crapjur.cdcooper%TYPE
                     ,pr_nrdconta IN crapjur.nrdconta%TYPE) IS
     SELECT crapjur.natjurid
           ,crapjur.tpregtrb
       FROM crapjur
      WHERE crapjur.cdcooper = pr_cdcooper
        AND crapjur.nrdconta = pr_nrdconta;
    rw_crapjur cr_crapjur%ROWTYPE;
    
    /* TYPES */
    
    TYPE typ_dados_tarifa IS RECORD 
      (cdfvlcop crapcop.cdcooper%TYPE
      ,cdhistor craphis.cdhistor%TYPE
      ,vlrtarif NUMBER
      ,vltottar NUMBER);
    
    --Tipo de Tabela de Lancamento Tarifa
    --TYPE typ_tab_dados_tarifa IS TABLE OF typ_dados_tarifa INDEX BY VARCHAR2(4);

      
    /* VARI�VEIS LOCAIS */
    
    vr_cdbattar     VARCHAR2(1000);
    vr_cdhisest     INTEGER;
    vr_dtdivulg     DATE;
    vr_dtvigenc     DATE;
    
    vr_rowid_craplat  ROWID;
    
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    vr_tab_erro GENE0001.typ_tab_erro; --Tabela de erros
    vr_des_erro VARCHAR2(10);                                     
    
    vr_vlsldtit NUMBER; -- Saldo devedor atual do t�tulo
    vr_vlpagmto NUMBER; -- Valor dispon�vel para pagamento do t�tulo
    
    vr_flbaixar BOOLEAN; -- Indica se o t�tulo deve sofrer baixa ou n�o
    vr_flraspar BOOLEAN; -- Indica se o processo de raspada deve continuar ou n�o
    
    vr_vliofpri NUMBER; -- Valor do IOF principal
    vr_vliofadi NUMBER; -- Valor do IOF adicional
    vr_vliofcpl NUMBER; -- Valor do IOF complementar
    
    vr_vlpagiof NUMBER; -- Valor pago do IOF complementar
    vr_vlpagmta NUMBER; -- Valor pago da multa
    vr_vlpagmra NUMBER; -- Valor pago dos juros de mora
    vr_vlpagtit NUMBER; -- Valor pago do t�tulo
    
    vr_vlencarg NUMBER;
    
    vr_insittit craptdb.insittit%TYPE;
    vr_dtdebito craptdb.dtdebito%TYPE;
    vr_dtdpagto craptdb.dtdpagto%TYPE;
    
    vr_cdhistor_opc INTEGER; -- Hist�rico de lan�amento do titulo
    
    vr_vltxiofatra NUMBER;
    
    vr_dados_tarifa typ_dados_tarifa;
    
    vr_flgimune PLS_INTEGER;
    
    vr_cdpesqbb     VARCHAR2(1000);
    
    vr_dtmvtolt_lcm craplcm.dtmvtolt%TYPE;
    vr_cdagenci_lcm craplcm.cdagenci%TYPE;
    vr_cdbccxlt_lcm craplcm.cdbccxlt%TYPE;
    vr_nrdolote_lcm craplcm.nrdolote%TYPE;
    vr_nrseqdig_lcm craplcm.nrseqdig%TYPE;
      
    /* EXCE��ES */
    vr_exc_erro  EXCEPTION;
    
    /* FUN��ES */
    
    --Verifica se eh titulo de cobranca com registro
    FUNCTION fn_verifica_cobranca_reg(pr_cdcooper  crapcop.cdcooper%TYPE
                                     ,pr_nrcnvcob  crapcco.nrconven%TYPE) RETURN BOOLEAN IS
      CURSOR cr_crapcco(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_nrconven crapcco.nrconven%TYPE) IS
        SELECT 1
          FROM crapcco cco
         WHERE cco.cdcooper = pr_cdcooper
           AND cco.nrconven = pr_nrconven
           AND cco.flgregis = 1;
      rw_crapcco cr_crapcco%ROWTYPE;                
    BEGIN
      
      OPEN cr_crapcco(pr_cdcooper => pr_cdcooper
                     ,pr_nrconven => pr_nrcnvcob);
      FETCH cr_crapcco INTO rw_crapcco;
        
      IF cr_crapcco%NOTFOUND THEN
         CLOSE cr_crapcco;
         RETURN FALSE;
      END IF;
        
      CLOSE cr_crapcco;
      RETURN TRUE;        
    END fn_verifica_cobranca_reg;
    
    FUNCTION fn_busca_nrseqdig(pr_cdcooper crapcop.cdcooper%TYPE
                              ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) RETURN NUMBER IS                                

      CURSOR cr_craplcm_seq(pr_cdcooper crapcop.cdcooper%TYPE
                           ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
        SELECT NVL(MAX(lcm.nrseqdig),0) nrseqdig
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper
           AND lcm.dtmvtolt = pr_dtmvtolt
           AND lcm.cdagenci = 1
           AND lcm.cdbccxlt = 100
           AND lcm.nrdolote = 10301;
          -- Merge 1 - Excluido AND lcm.cdhistor = 591;  - 15/02/2018 - Chamado 851591
      rw_craplcm_seq cr_craplcm_seq%ROWTYPE;                            
    BEGIN
      -- Retorna nome do m�dulo logado - 15/02/2018 - Chamado 851591
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.fn_busca_nrseqdig');

      OPEN cr_craplcm_seq(pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => pr_dtmvtolt);
      FETCH cr_craplcm_seq INTO rw_craplcm_seq;
        
      IF cr_craplcm_seq%NOTFOUND THEN
         CLOSE cr_craplcm_seq;
         RETURN 0;
      END IF;
        
      CLOSE cr_craplcm_seq;
      -- Retorna nome do m�dulo logado - 15/02/2018 - Chamado 851591
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
      RETURN rw_craplcm_seq.nrseqdig;
    END fn_busca_nrseqdig;
    
  BEGIN
    
    --Verifica se a conta existe
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
      
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9; --Associado n cadastrado: --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;
    
    -- Busca dados de pessoa jur�dica
    OPEN cr_crapjur(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapjur INTO rw_crapjur;
    CLOSE cr_crapjur;
      
    -- Valida a exist�ncia do t�tulo
    OPEN cr_craptdb (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrborder => pr_nrborder
                    ,pr_cdbandoc => pr_cdbandoc
                    ,pr_nrdctabb => pr_nrdctabb
                    ,pr_nrcnvcob => pr_nrcnvcob
                    ,pr_nrdocmto => pr_nrdocmto);
    FETCH cr_craptdb INTO rw_craptdb;
      
    IF cr_craptdb%NOTFOUND THEN
      CLOSE cr_craptdb;
      vr_cdcritic := 1108; 
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_craptdb;
    
    -- Valida exist�ncia do border� do respectivo t�tulo
    OPEN cr_crapbdt (pr_cdcooper => pr_cdcooper
                    ,pr_nrborder => pr_nrborder);
    FETCH cr_crapbdt INTO rw_crapbdt;
        
    IF cr_crapbdt%NOTFOUND THEN
      vr_cdcritic := 1166; --Bordero nao encontrado. Ajuste mensagem de erro - 15/02/2018 - Chamado 851591
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      CLOSE cr_crapbdt;
    RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapbdt;
    
    vr_flbaixar := FALSE;
    
    vr_vlpagmto := pr_vlpagmto;
    
    -- Inicializa as regras de prioridade da raspada
    vr_flraspar := TRUE;
    
    vr_vlpagiof := 0; 
    vr_vlpagmta := 0; 
    vr_vlpagmra := 0; 
    vr_vlsldtit := rw_craptdb.vlsldtit;
    vr_vlpagtit := 0;
    vr_vlencarg := 0;
    
    -- 1) IOF
    
    vr_vltotal_liquido := 0;
    OPEN cr_craptdb_total(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrborder => pr_nrborder);
    FETCH cr_craptdb_total INTO vr_vltotal_liquido;
    CLOSE cr_craptdb_total;
      
    TIOF0001.pc_calcula_valor_iof_prg (pr_tpproduto            => 2 -- Desconto de t�tulos
                                      ,pr_tpoperacao           => 2 -- Pagamento em atraso
                                      ,pr_cdcooper             => pr_cdcooper
                                      ,pr_nrdconta             => pr_nrdconta
                                      ,pr_inpessoa             => rw_crapass.inpessoa
                                      ,pr_natjurid             => rw_crapjur.natjurid
                                      ,pr_tpregtrb             => rw_crapjur.tpregtrb
                                      ,pr_dtmvtolt             => pr_dtmvtolt
                                      ,pr_qtdiaiof             => 0
                                      ,pr_vloperacao           => (rw_craptdb.vlsldtit + rw_craptdb.vlmratit_restante) 
                                      ,pr_vltotalope           => vr_vltotal_liquido
                                      ,pr_vltaxa_iof_atraso    => NVL(rw_crapbdt.vltaxiof,0)
                                      ,pr_vliofpri             => vr_vliofpri
                                      ,pr_vliofadi             => vr_vliofadi
                                      ,pr_vliofcpl             => vr_vliofcpl
                                      ,pr_vltaxa_iof_principal => vr_vltxiofatra
                                      ,pr_flgimune             => vr_flgimune
                                      ,pr_dscritic             => vr_dscritic);
      
    IF vr_dscritic IS NOT NULL THEN
      vr_dscritic := 'Erro realizar c�lculo do IOF em atraso : '||SQLERRM;
      RAISE vr_exc_erro;
    END IF;
      
    IF rw_craptdb.vliofcpl_restante > 0 AND vr_flraspar AND vr_flgimune <= 0 THEN
        
      IF rw_craptdb.vliofcpl_restante > vr_vlpagmto THEN
        vr_vlpagiof := vr_vlpagmto;
        vr_flraspar := FALSE;    
      ELSE
        vr_vlpagiof := rw_craptdb.vliofcpl_restante;
      END IF;
        
      vr_vlencarg := vr_vlencarg + vr_vlpagiof;
        
      -- Realiza o d�bito do IOF complementar na conta corrente do cooperado     
      pc_efetua_lanc_cc(pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_vllanmto => vr_vlpagiof
                       ,pr_cdhistor => vr_cdhistordsct_iofscomplem
                       ,pr_cdcooper => pr_cdcooper
                       ,pr_cdoperad => pr_cdoperad
                       ,pr_nrborder => pr_nrborder
                       ,pr_cdpactra => 0
                       ,pr_nrdocmto => rw_craptdb.nrdocmto
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic);

      -- Condicao para verificar se houve critica                             
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      TIOF0001.pc_insere_iof(pr_cdcooper     => pr_cdcooper
                            ,pr_nrdconta     => pr_nrdconta
                            ,pr_dtmvtolt     => pr_dtmvtolt                              
                            ,pr_tpproduto    => 2   --> Desconto de Titulo
                            ,pr_nrcontrato   => pr_nrborder
                            ,pr_dtmvtolt_lcm => vr_dtmvtolt_lcm
                            ,pr_cdagenci_lcm => vr_cdagenci_lcm
                            ,pr_cdbccxlt_lcm => vr_cdbccxlt_lcm
                            ,pr_nrdolote_lcm => vr_nrdolote_lcm
                            ,pr_nrseqdig_lcm => vr_nrseqdig_lcm
                            ,pr_vliofcpl     => vr_vlpagiof
                            ,pr_flgimune     => vr_flgimune -- Merge 1 - 15/02/2018 - Chamado 851591
                            ,pr_cdcritic     => vr_cdcritic
                            ,pr_dscritic     => vr_dscritic);
                                    
      -- Condicao para verificar se houve critica                             
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;
    
    -- 2) Multa
    IF rw_craptdb.vlmtatit_restante > 0 AND vr_flraspar THEN
      
      IF rw_craptdb.vlmtatit_restante > vr_vlpagmto THEN
        vr_vlpagmta := vr_vlpagmto;
        vr_flraspar := FALSE;    
      ELSE
        vr_vlpagmta := rw_craptdb.vlmtatit_restante;
      END IF;
      
      vr_vlencarg := vr_vlencarg + vr_vlpagmta; 
      
      -- Realiza o d�bito da multa na conta corrente do cooperado 
      pc_efetua_lanc_cc(pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_vllanmto => vr_vlpagmta
                       ,pr_cdhistor => CASE WHEN nvl(pr_flpgtava,0) = 0 THEN 
                                                 vr_cdhistordsct_pgtomultacc 
                                            ELSE vr_cdhistordsct_pgtomultaavcc END
                       ,pr_cdcooper => pr_cdcooper
                       ,pr_cdoperad => pr_cdoperad
                       ,pr_nrborder => pr_nrborder
                       ,pr_cdpactra => 0
                       ,pr_nrdocmto => rw_craptdb.nrdocmto
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic);

      -- Condicao para verificar se houve critica                             
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Lan�ar valor de pagamento da multa nos lan�amentos do border�
      pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrborder => pr_nrborder
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdbandoc => pr_cdbandoc
                                   ,pr_nrdctabb => pr_nrdctabb
                                   ,pr_nrcnvcob => pr_nrcnvcob
                                   ,pr_nrdocmto => pr_nrdocmto
                                   ,pr_nrtitulo => rw_craptdb.nrtitulo
                                   ,pr_cdorigem => 5
                                   ,pr_cdhistor => CASE WHEN nvl(pr_flpgtava,0) = 0 THEN 
                                                             vr_cdhistordsct_pgtomultaopc 
                                                        ELSE vr_cdhistordsct_pgtomultaavopc END
                                   ,pr_vllanmto => vr_vlpagmta
                                   ,pr_dscritic => vr_dscritic );

      -- Condicao para verificar se houve critica                             
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Lan�ar valor de apropria��o da multa nos lan�amentos do border�
      pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrborder => pr_nrborder
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdbandoc => pr_cdbandoc
                                   ,pr_nrdctabb => pr_nrdctabb
                                   ,pr_nrcnvcob => pr_nrcnvcob
                                   ,pr_nrdocmto => pr_nrdocmto
                                   ,pr_nrtitulo => rw_craptdb.nrtitulo
                                   ,pr_cdorigem => 5
                                   ,pr_cdhistor => vr_cdhistordsct_apropjurmta
                                   ,pr_vllanmto => vr_vlpagmta
                                   ,pr_dscritic => vr_dscritic );

      -- Condicao para verificar se houve critica                             
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
    END IF;
    
    -- 3) Juros
    IF rw_craptdb.vlmratit_restante > 0 AND vr_flraspar THEN
      
      IF rw_craptdb.vlmratit_restante > vr_vlpagmto THEN
        vr_vlpagmra := vr_vlpagmto;
        vr_flraspar := FALSE;    
      ELSE
        vr_vlpagmra := rw_craptdb.vlmratit_restante;
      END IF;
      
      vr_vlencarg := vr_vlencarg + vr_vlpagmra; 
      
      -- Lan�a o valor dos juros de mora na conta do cooperado
      pc_efetua_lanc_cc(pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_vllanmto => vr_vlpagmra
                       ,pr_cdhistor => CASE WHEN nvl(pr_flpgtava,0) = 0 THEN 
                                                 vr_cdhistordsct_pgtojuroscc
                                            ELSE vr_cdhistordsct_pgtojurosavcc END
                       ,pr_cdcooper => pr_cdcooper
                       ,pr_cdoperad => pr_cdoperad
                       ,pr_nrborder => pr_nrborder
                       ,pr_cdpactra => 0
                       ,pr_nrdocmto => rw_craptdb.nrdocmto
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic);
      -- Condicao para verificar se houve critica                             
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Lan�ar valor de pagamento dos juros nos lan�amentos do border�
      pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrborder => pr_nrborder
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdbandoc => pr_cdbandoc
                                   ,pr_nrdctabb => pr_nrdctabb
                                   ,pr_nrcnvcob => pr_nrcnvcob
                                   ,pr_nrdocmto => pr_nrdocmto
                                   ,pr_nrtitulo => rw_craptdb.nrtitulo
                                   ,pr_cdorigem => 5
                                   ,pr_cdhistor => CASE WHEN nvl(pr_flpgtava,0) = 0 THEN 
                                                             vr_cdhistordsct_pgtojurosopc
                                                        ELSE vr_cdhistordsct_pgtojurosavopc END
                                   ,pr_vllanmto => vr_vlpagmra
                                   ,pr_dscritic => vr_dscritic );

      -- Condicao para verificar se houve critica                             
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Lan�ar valor de apropria��o dos juros nos lan�amentos do border�
      pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrborder => pr_nrborder
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdbandoc => pr_cdbandoc
                                   ,pr_nrdctabb => pr_nrdctabb
                                   ,pr_nrcnvcob => pr_nrcnvcob
                                   ,pr_nrdocmto => pr_nrdocmto
                                   ,pr_nrtitulo => rw_craptdb.nrtitulo
                                   ,pr_cdorigem => 5
                                   ,pr_cdhistor => vr_cdhistordsct_apropjurmra
                                   ,pr_vllanmto => vr_vlpagmra
                                   ,pr_dscritic => vr_dscritic );

      -- Condicao para verificar se houve critica                             
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
    END IF;
    
    -- 4) Valor do t�tulo
    IF rw_craptdb.vlsldtit > 0 AND vr_flraspar THEN
      -- Tratamentos conforme a origem do pagamento
      -- 0 - Conta-Corrente (Raspada, ...)
      IF pr_cdorigpg = 0 THEN
        vr_cdhistor_opc := vr_cdhistordsct_pgtoopc; -- conta corrente
        vr_dtdebito     := pr_dtmvtolt;
        vr_vlpagmto     := vr_vlpagmto - vr_vlencarg;

      -- 1 - Pagamento (Baixa de cobran�a de t�tulos, ...)
      -- 2 - COBTIT
      ELSIF pr_cdorigpg IN (1,2) THEN 
        -- Pagamento efetuado pelo avalista
        IF pr_flpgtava = 1 THEN
          vr_cdhistor_opc := vr_cdhistordsct_pgtoavalopc;
        ELSE
          IF pr_indpagto = 0 THEN
            vr_cdhistor_opc := vr_cdhistordsct_pgtocompe; -- Compe
          ELSE
            vr_cdhistor_opc := vr_cdhistordsct_pgtocooper; -- Caixa/IB/TAA
          END IF;  
        END IF;
        
        IF pr_cdorigpg = 2 THEN
          vr_vlpagmto := vr_vlpagmto - vr_vlencarg;
        END IF;
        
        vr_dtdpagto := pr_dtmvtolt;
        
      -- 3 - Tela PAGAR
      ELSIF pr_cdorigpg = 3 THEN
        IF pr_flpgtava = 1 THEN
          vr_cdhistor_opc := vr_cdhistordsct_pgtoavalopc;
        ELSE
          vr_cdhistor_opc := vr_cdhistordsct_pgtoopc;
        END IF;
        
        vr_dtdebito := pr_dtmvtolt;

      -- origem de pagamento inv�lida
      ELSE
        vr_cdcritic := 0;
        vr_dscritic := 'Conte�do inv�lido informado para o par�mentro dsct0003.pc_pagar_titulo.pr_cdorigpg';
        RAISE vr_exc_erro;
      END IF;
      
      IF rw_craptdb.vlsldtit > vr_vlpagmto THEN
        vr_vlpagtit := vr_vlpagmto;
        vr_vlsldtit := rw_craptdb.vlsldtit - vr_vlpagmto;
      ELSE
        vr_vlpagtit := rw_craptdb.vlsldtit;
        vr_vlsldtit := 0;
        vr_flbaixar := TRUE; 
      END IF;
      
      vr_vlpagmto := vr_vlpagmto - vr_vlpagtit;
 
      -- 0-Conta-Corrente  2-COBTIT  3-Tela PAGAR     
      IF pr_cdorigpg IN (0,2,3) THEN
        -- Debita o valor do t�tulo se o pagamento vier da conta corrente
        pc_efetua_lanc_cc(pr_dtmvtolt => pr_dtmvtolt
                         ,pr_cdagenci => 1
                         ,pr_cdbccxlt => 100
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_vllanmto => vr_vlpagtit
                         ,pr_cdhistor => CASE WHEN nvl(pr_flpgtava,0) = 0 THEN 
                                                   vr_cdhistordsct_pgtocc
                                              ELSE vr_cdhistordsct_pgtoavalcc END
                         ,pr_cdcooper => pr_cdcooper
                         ,pr_cdoperad => pr_cdoperad
                         ,pr_nrborder => pr_nrborder
                         ,pr_cdpactra => 0
                         ,pr_nrdocmto => rw_craptdb.nrdocmto
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
        -- Condicao para verificar se houve critica                             
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Se o valor pago do boleto for maior que o saldo restante, lan�a o saldo restante como cr�dito na conta corrente do cooperado
      IF vr_vlpagmto > 0 THEN
        pc_efetua_lanc_cc(pr_dtmvtolt => pr_dtmvtolt
                         ,pr_cdagenci => 1
                         ,pr_cdbccxlt => 100
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_vllanmto => (pr_vlpagmto - rw_craptdb.vlsldtit)
                         ,pr_cdhistor => vr_cdhistordsct_credito
                         ,pr_cdcooper => pr_cdcooper
                         ,pr_cdoperad => pr_cdoperad
                         ,pr_nrborder => pr_nrborder
                         ,pr_cdpactra => 0
                         ,pr_nrdocmto => rw_craptdb.nrdocmto
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
        -- Condicao para verificar se houve critica                             
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Se a data de vencimento for maior que a data de pagamento, significa um pagamento adiantado, ent�o 
      -- realizar o lan�amento de estorno na conta do cooperador dos juros cobrados at� o vencimento
      IF rw_craptdb.dtvencto >= pr_dtmvtolt THEN
        dsct0001.pc_abatimento_juros_titulo(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrborder => pr_nrborder
                                           ,pr_cdbandoc => pr_cdbandoc
                                           ,pr_nrdctabb => pr_nrdctabb
                                           ,pr_nrcnvcob => pr_nrcnvcob
                                           ,pr_nrdocmto => pr_nrdocmto
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdagenci => pr_cdagenci
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_cdorigpg => 1 -- operacao de credito
                                           ,pr_dtdpagto => pr_dtmvtolt
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic );
        -- Condicao para verificar se houve critica                             
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
                                   
      -- Lan�ar valor do t�tulo nos lan�amentos do border�
      pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrborder => pr_nrborder
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdbandoc => pr_cdbandoc
                                   ,pr_nrdctabb => pr_nrdctabb
                                   ,pr_nrcnvcob => pr_nrcnvcob
                                   ,pr_nrdocmto => pr_nrdocmto
                                   ,pr_nrtitulo => rw_craptdb.nrtitulo
                                   ,pr_cdorigem => 5
                                   ,pr_cdhistor => vr_cdhistor_opc
                                   ,pr_vllanmto => vr_vlpagtit
                                   ,pr_dscritic => vr_dscritic );
      
    END IF;
    
    pr_vlpagmto := vr_vlpagmto;
    
    -- chama a rotina de baixa do titulo
    IF vr_flbaixar THEN
      IF rw_craptdb.dtvencto >= pr_dtmvtolt THEN
        vr_insittit := 2;
      ELSE
        vr_insittit := 3;
      END IF;
    ELSE
      vr_insittit := 4;
      vr_dtdebito := null;
      vr_dtdpagto := null;
    END IF;
    
    BEGIN
      -- Atualiza as informa��es do t�tulo
      UPDATE craptdb
         SET craptdb.insittit = vr_insittit,
             craptdb.vlpagiof = craptdb.vlpagiof + vr_vlpagiof,
             craptdb.vlpagmta = craptdb.vlpagmta + vr_vlpagmta,
             craptdb.vlpagmra = craptdb.vlpagmra + vr_vlpagmra,
             craptdb.vlsldtit = vr_vlsldtit,
             craptdb.dtdebito = nvl(vr_dtdebito,craptdb.dtdebito),
             craptdb.dtdpagto = nvl(vr_dtdpagto,craptdb.dtdpagto)
       WHERE craptdb.rowid    = rw_craptdb.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar craptdb: '||SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
        RAISE vr_exc_erro;
    END; 
    
    -- se o t�tulo foi baixado
    IF vr_flbaixar THEN
      
      -- Define qual tipo de tarifa a ser cobrada
      IF fn_verifica_cobranca_reg(pr_cdcooper => pr_cdcooper, pr_nrcnvcob => pr_nrcnvcob) THEN
        IF rw_crapass.inpessoa = 1 THEN
          vr_cdbattar:= 'DSTTITCRPF';
        ELSE
          vr_cdbattar:= 'DSTTITCRPJ';
        END IF;    
      ELSE
        IF rw_crapass.inpessoa = 1 THEN
          vr_cdbattar:= 'DSTTITSRPF';
        ELSE
          vr_cdbattar:= 'DSTTITSRPJ';
        END IF;
      END IF;              
      
      /*  Busca valor da tarifa sem registro*/
      TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => pr_cdcooper               --Codigo Cooperativa
                                            ,pr_cdbattar  => vr_cdbattar               --Codigo Tarifa
                                            ,pr_vllanmto  => 1                         --Valor Lancamento
                                            ,pr_cdprogra  => NULL                      --Codigo Programa
                                            ,pr_cdhistor  => vr_dados_tarifa.cdhistor  --Codigo Historico
                                            ,pr_cdhisest  => vr_cdhisest               --Historico Estorno
                                            ,pr_vltarifa  => vr_dados_tarifa.vlrtarif  --Valor tarifa
                                            ,pr_dtdivulg  => vr_dtdivulg               --Data Divulgacao
                                            ,pr_dtvigenc  => vr_dtvigenc               --Data Vigencia
                                            ,pr_cdfvlcop  => vr_dados_tarifa.cdfvlcop  --Codigo faixa valor cooperativa
                                            ,pr_cdcritic  => vr_cdcritic               --Codigo Critica
                                            ,pr_dscritic  => vr_dscritic               --Descricao Critica
                                            ,pr_tab_erro  => vr_tab_erro);             --Tabela erros

      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        vr_dscritic := vr_dscritic||' pr_nrdconta:' || pr_nrdconta || ' ,pr_nrborder:' || pr_nrborder||','; 
        RAISE vr_exc_erro;
      END IF;
      
      IF vr_dados_tarifa.vlrtarif > 0 THEN --Lancamento Tarifa Cobranca Reg PF
         /* Gera Tarifa de titulos descontados */
         TARI0001.pc_cria_lan_auto_tarifa (pr_cdcooper => pr_cdcooper  --Codigo Cooperativa
                                          ,pr_nrdconta => pr_nrdconta  --Numero da Conta
                                          ,pr_dtmvtolt => pr_dtmvtolt          --Data Lancamento
                                          ,pr_cdhistor => vr_dados_tarifa.cdhistor --Codigo Historico
                                          ,pr_vllanaut => vr_dados_tarifa.vlrtarif --Valor lancamento automatico
                                          ,pr_cdoperad => 1          --Codigo Operador
                                          ,pr_cdagenci => 1                    --Codigo Agencia
                                          ,pr_cdbccxlt => 100                  --Codigo banco caixa
                                          ,pr_nrdolote => 8452                 --Numero do lote
                                          ,pr_tpdolote => 1                    --Tipo do lote
                                          ,pr_nrdocmto => 0                    --Numero do documento
                                          ,pr_nrdctabb => pr_nrdconta  --Numero da conta
                                          ,pr_nrdctitg => gene0002.fn_mask(pr_nrdconta,'99999999') --Numero da conta integracao
                                          ,pr_cdpesqbb => vr_cdpesqbb          --Codigo pesquisa
                                          ,pr_cdbanchq => 0                    --Codigo Banco Cheque
                                          ,pr_cdagechq => 0                    --Codigo Agencia Cheque
                                          ,pr_nrctachq => 0                    --Numero Conta Cheque
                                          ,pr_flgaviso => FALSE                --Flag aviso
                                          ,pr_tpdaviso => 0                    --Tipo aviso
                                          ,pr_cdfvlcop => vr_dados_tarifa.cdfvlcop --Codigo cooperativa
                                          ,pr_inproces => pr_inproces  --Indicador processo
                                          ,pr_rowid_craplat => vr_rowid_craplat --Rowid do lancamento tarifa
                                          ,pr_tab_erro => vr_tab_erro          --Tabela retorno erro
                                          ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                          ,pr_dscritic => vr_dscritic);        --Descricao Critica
         --Se ocorreu erro
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           vr_dscritic := vr_dscritic||' pr_nrdconta:' || pr_nrdconta || ' ,pr_nrborder:' || pr_nrborder||','; 
           RAISE vr_exc_erro;
         END IF;
         
       END IF;
      
      -- Verifica se deve liquidar o bordero caso sim Liquida 
      DSCT0001.pc_efetua_liquidacao_bordero (pr_cdcooper => pr_cdcooper  --Codigo Cooperativa
                                            ,pr_cdagenci => pr_cdagenci  --Codigo Agencia
                                            ,pr_nrdcaixa => pr_nrdcaixa  --Numero do Caixa
                                            ,pr_cdoperad => pr_cdoperad  --Codigo Operador
                                            ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                            ,pr_idorigem => pr_idorigem  --Identificador Origem
                                            ,pr_nrdconta => pr_nrdconta  --Numero da Conta
                                            ,pr_nrborder => pr_nrborder  --Numero do Bordero
                                            ,pr_tab_erro => vr_tab_erro   --Tabela de erros
                                            ,pr_des_erro => vr_des_erro   --identificador de erro
                                            ,pr_cdcritic => vr_cdcritic   --C�digo do erro
                                            ,pr_dscritic => vr_dscritic); --Descricao do erro;
    											  
      IF NVL(LENGTH(TRIM(vr_dscritic)),0) > 0 THEN -- Merge 02/05/2018 - Chamado 851591 
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 -- Sequencia
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
      END IF;
    		
      --Se ocorreu erro
      IF vr_des_erro = 'NOK' THEN
        vr_dscritic := vr_dscritic||' pr_nrdconta:' || pr_nrdconta || ' ,pr_nrborder:' || pr_nrborder||','; 
        RAISE vr_exc_erro;
      END IF;
    
    END IF;
    
    COMMIT;
        
    EXCEPTION
      WHEN vr_exc_erro THEN
      vr_cdcritic := NVL(vr_cdcritic, 0);
      IF vr_cdcritic > 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
      END IF;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      -- Efetuar rollback
      ROLLBACK;                            
        
    --END;  
  END pc_pagar_titulo;
  
  PROCEDURE pc_efetua_lanc_cc (pr_dtmvtolt  IN craplcm.dtmvtolt%TYPE -- Origem: do lote de libera��o (craplot)
                              ,pr_cdagenci  IN craplcm.cdagenci%TYPE -- Origem: do lote de libera��o (craplot)
                              ,pr_cdbccxlt  IN craplcm.cdbccxlt%TYPE -- Origem: do lote de libera��o (craplot)
                              ,pr_nrdconta  IN craplcm.nrdconta%TYPE -- Origem: nrdconta do Bordero
                              ,pr_vllanmto  IN craplcm.vllanmto%TYPE -- Origem: do c�lculo :aux_vlborder + craptdb.vlliquid da linha 1870.
                              ,pr_cdhistor  IN craphis.cdhistor%TYPE
                              ,pr_cdcooper  IN craplcm.cdcooper%TYPE
                              ,pr_cdoperad  IN crapbdt.cdoperad%TYPE --> Operador
                              ,pr_nrborder  IN crapbdt.nrborder%TYPE -- Origem: Bordero
                              ,pr_cdpactra  IN crapope.cdpactra%TYPE
                              ,pr_nrdocmto  IN craptdb.nrdocmto%TYPE
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> codigo critica
                              ,pr_dscritic OUT VARCHAR2              --> Descricao Critica
                              ) IS
    /*-------------------------------------------------------------------------------------------------------
      Programa : pc_lanca_tarifa_bordero        Antigo: b1wgen0030.p/efetua_liber_anali_bordero (Trecho de Libera��o)
      Sistema  : Procedure para lan�ar cr�dito de desconto de T�tulo
      Sigla    : CRED
      Autor    : Andrew Albuquerque (GFT) 
      Data     : Abril/2018
     
      Objetivo  : Procedure para la�amento de cr�dito de desconto de T�tulo.

      Alteracoes: 16/04/2018 - Cria��o (Andrew Albuquerque (GFT))
                  23/07/2018 - Inser��o de loop para inserir na LCM
    ----------------------------------------------------------------------------------------------------------*/
    vr_nrdolote craplot.nrdolote%TYPE;
    vr_rowid    ROWID;

    -- Registros para armazenar dados do lancamento gerado
    rw_craplcm craplcm%ROWTYPE;    
      
    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
        
    vr_exc_erro exception;
      
    -- CURSORES
    CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
                     ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                     ,pr_cdagenci IN craplot.cdagenci%TYPE
                     ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                     ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
    SELECT lot.qtcompln
          ,lot.vlcompcr
          ,lot.qtinfoln
          ,lot.vlinfocr
          ,lot.vlcompdb
          ,lot.vlinfodb
          ,lot.dtmvtolt
          ,lot.cdagenci
          ,lot.cdbccxlt
          ,lot.nrdolote
          ,lot.nrseqdig
          ,lot.tplotmov
          ,lot.cdoperad
          ,lot.cdhistor
          ,lot.ROWID
          ,count(1) over() retorno
      FROM craplot lot
     WHERE lot.cdcooper = pr_cdcooper
       AND lot.dtmvtolt = pr_dtmvtolt
       AND lot.cdagenci = pr_cdagenci
       AND lot.cdbccxlt = pr_cdbccxlt
       AND lot.nrdolote = pr_nrdolote
    FOR UPDATE;
    rw_craplot cr_craplot%ROWTYPE;
    vr_flg_criou_lot BOOLEAN;
  BEGIN
    --vr_nrdolote := 17000 + pr_cdpactra;
    /*Insere um lote novo*/
    vr_flg_criou_lot:=false;
    WHILE NOT vr_flg_criou_lot LOOP  
      vr_nrdolote := fn_sequence(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRDOLOTE'
                                ,pr_dsdchave => TO_CHAR(pr_cdcooper)|| ';' 
                                                || pr_dtmvtolt || ';'
                                                || TO_CHAR(pr_cdagenci)|| ';'
                                                || '100');

      /*[PROJETO LIGEIRINHO] Esta fun��o retorna verdadeiro, quando o processo foi iniciado pela rotina:
      PAGA0001.pc_efetua_debitos_paralelo, que � chamada na rotina PC_CRPS509. Tem por finalidade definir
      se grava na tabela CRAPLOT no momento em que esta rodando a esta rotina OU somente no final da execuca��o
      da PC_CRPS509, para evitar o erro de lock da tabela, pois esta gravando a agencia 90,91 ou 1 ao inves de gravar
      a agencia do cooperado*/ 
      IF  NOT paga0001.fn_exec_paralelo THEN
          OPEN  cr_craplot(pr_cdcooper => pr_cdcooper
                          ,pr_dtmvtolt => pr_dtmvtolt
                          ,pr_cdagenci => 1
                          ,pr_cdbccxlt => 100
                          ,pr_nrdolote => vr_nrdolote);
          FETCH cr_craplot INTO rw_craplot;
          IF    cr_craplot%NOTFOUND THEN
                CLOSE cr_craplot;
                BEGIN
                  INSERT INTO craplot
                         (/*01*/ cdcooper
                         ,/*02*/ dtmvtolt
                         ,/*03*/ cdagenci
                         ,/*04*/ cdbccxlt
                         ,/*05*/ nrdolote
                         ,/*06*/ tplotmov
                         ,/*07*/ cdoperad
                         ,/*08*/ cdhistor)
                  VALUES (/*01*/ pr_cdcooper
                         ,/*02*/ pr_dtmvtolt
                         ,/*03*/ 1
                         ,/*04*/ 100
                         ,/*05*/ vr_nrdolote
                         ,/*06*/ 1
                         ,/*07*/ pr_cdoperad
                         ,/*08*/ pr_cdhistor)
                  RETURNING /*01*/ dtmvtolt
                           ,/*02*/ cdagenci
                           ,/*03*/ cdbccxlt
                           ,/*04*/ nrdolote
                           ,/*05*/ vlinfocr
                           ,/*06*/ vlcompcr
                           ,/*07*/ qtinfoln
                           ,/*08*/ qtcompln
                           ,/*09*/ nrseqdig
                           ,/*10*/ ROWID
                  INTO      /*01*/ rw_craplot.dtmvtolt
                           ,/*02*/ rw_craplot.cdagenci
                           ,/*03*/ rw_craplot.cdbccxlt
                           ,/*04*/ rw_craplot.nrdolote
                           ,/*05*/ rw_craplot.vlinfocr
                           ,/*06*/ rw_craplot.vlcompcr
                           ,/*07*/ rw_craplot.qtinfoln
                           ,/*08*/ rw_craplot.qtcompln
                           ,/*09*/ rw_craplot.nrseqdig
                           ,/*10*/ rw_craplot.rowid;
                EXCEPTION
                  WHEN OTHERS THEN                 
                       CLOSE cr_craplot;
                       vr_dscritic := 'Erro ao inserir na tabela craplot: ' || SQLERRM;
                       RAISE vr_exc_erro;
                END;
          ELSE
            CLOSE cr_craplot;  
          END   IF;
          
          rw_craplot.nrseqdig := nvl(rw_craplot.nrseqdig,0) + 1; -- projeto ligeirinho
      ELSE
          paga0001.pc_insere_lote_wrk(pr_cdcooper => pr_cdcooper
                                     ,pr_dtmvtolt => pr_dtmvtolt
                                     ,pr_cdagenci => 1
                                     ,pr_cdbccxlt => 100
                                     ,pr_nrdolote => vr_nrdolote
                                     ,pr_cdoperad => pr_cdoperad
                                     ,pr_nrdcaixa => NULL
                                     ,pr_tplotmov => 1
                                     ,pr_cdhistor => vr_cdhistordsct_credito
                                     ,pr_cdbccxpg => NULL
                                     ,pr_nmrotina => 'DSCT0003.PC_EFETUA_LANC_CC');
          				
          rw_craplot.dtmvtolt := pr_dtmvtolt;                  
          rw_craplot.cdagenci := 1;                   
          rw_craplot.cdbccxlt := 100;                  
          rw_craplot.nrdolote := vr_nrdolote;                   
          rw_craplot.nrseqdig := PAGA0001.fn_seq_parale_craplcm;
      END IF;
       
      BEGIN
        -- Gero o Insert na tabela de Lancamentos em depositos a vista
        INSERT INTO craplcm
               (/*01*/ dtmvtolt
               ,/*02*/ cdagenci
               ,/*03*/ cdbccxlt
               ,/*04*/ nrdolote
               ,/*05*/ nrdconta
               ,/*06*/ nrdocmto
               ,/*07*/ vllanmto
               ,/*08*/ cdhistor
               ,/*09*/ nrseqdig
               ,/*10*/ nrdctabb
               ,/*11*/ nrautdoc 
               ,/*12*/ cdcooper
               ,/*13*/ cdpesqbb)
        VALUES (/*01*/ rw_craplot.dtmvtolt
               ,/*02*/ rw_craplot.cdagenci
               ,/*03*/ rw_craplot.cdbccxlt
               ,/*04*/ rw_craplot.nrdolote
               ,/*05*/ pr_nrdconta
               ,/*06*/ pr_nrdocmto
               ,/*07*/ pr_vllanmto 
               ,/*08*/ pr_cdhistor
               ,/*09*/ vr_nrdolote
               ,/*10*/ pr_nrdconta
               ,/*11*/ 0
               ,/*12*/ pr_cdcooper
               ,/*13*/ 'Desconto de T�tulo do Border� ' || pr_nrborder)
        RETURNING /*01*/ craplcm.ROWID
                 ,/*02*/ craplcm.cdhistor
                 ,/*03*/ craplcm.cdcooper
                 ,/*04*/ craplcm.dtmvtolt
                 ,/*05*/ craplcm.hrtransa
                 ,/*06*/ craplcm.nrdconta
                 ,/*07*/ craplcm.nrdocmto
                 ,/*08*/ craplcm.vllanmto
        INTO      /*01*/ vr_rowid
                 ,/*02*/ rw_craplcm.cdhistor
                 ,/*03*/ rw_craplcm.cdcooper
                 ,/*04*/ rw_craplcm.dtmvtolt
                 ,/*05*/ rw_craplcm.hrtransa
                 ,/*06*/ rw_craplcm.nrdconta
                 ,/*07*/ rw_craplcm.nrdocmto
                 ,/*08*/ rw_craplcm.vllanmto;
      EXCEPTION
        -- Caso nao consiga inserir o LCM por dupkey, refaz toda a transa��o
        WHEN DUP_VAL_ON_INDEX THEN   
             CONTINUE;
        WHEN OTHERS THEN
             CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);      
             vr_cdcritic := 1034;
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                             'craplcm:' ||
                             '  dtmvtolt:'   || pr_dtmvtolt  ||
                             ', cdagenci:'  || '1'      || 
                             ', cdbccxlt:'  || '100'    || 
                             ', nrdolote:'  || rw_craplot.nrdolote ||
                             ', nrdconta:'  || pr_nrdconta  ||
                             ', nrdocmto:'  || rw_craplcm.nrdocmto   || 
                             ', vllanmto:'  || rw_craplcm.vllanmto  ||
                             ', cdhistor:'  || vr_cdhistordsct_pgtomultacc ||
                             ', nrseqdig:'  || rw_craplot.nrseqdig   ||
                             ', nrdctabb:'  || pr_nrdconta  ||
                             ', nrautdoc:'  || '0'          ||
                             ', cdcooper:'  || pr_cdcooper  ||
                             ', cdpesqbb:'  || rw_craplcm.nrdocmto  || 
                             '. ' ||sqlerrm; 
             RAISE vr_exc_erro;
      END;
      vr_flg_criou_lot := TRUE;
    END LOOP;

    /*[PROJETO LIGEIRINHO]*/
    IF  NOT paga0001.fn_exec_paralelo THEN
        BEGIN
          UPDATE craplot
          SET    craplot.nrseqdig = rw_craplcm.nrseqdig
                ,craplot.qtinfoln = craplot.qtinfoln + 1
                ,craplot.qtcompln = craplot.qtcompln + 1
                ,craplot.vlinfocr = craplot.vlinfocr + rw_craplcm.vllanmto
                ,craplot.vlcompcr = craplot.vlcompcr + rw_craplcm.vllanmto
          WHERE  craplot.rowid = rw_craplot.rowid
          RETURNING /*01*/ dtmvtolt
                   ,/*02*/ cdagenci
                   ,/*03*/ cdbccxlt
                   ,/*04*/ nrdolote
                   ,/*05*/ vlinfocr
                   ,/*06*/ vlcompcr
                   ,/*07*/ qtinfoln
                   ,/*08*/ qtcompln
                   ,/*09*/ nrseqdig
                   ,/*10*/ ROWID
          INTO      /*01*/ rw_craplot.dtmvtolt
                   ,/*02*/ rw_craplot.cdagenci
                   ,/*03*/ rw_craplot.cdbccxlt
                   ,/*04*/ rw_craplot.nrdolote
                   ,/*05*/ rw_craplot.vlinfocr
                   ,/*06*/ rw_craplot.vlcompcr
                   ,/*07*/ rw_craplot.qtinfoln
                   ,/*08*/ rw_craplot.qtcompln
                   ,/*09*/ rw_craplot.nrseqdig
                   ,/*10*/ rw_craplot.rowid;
        EXCEPTION
          WHEN OTHERS THEN
               vr_dscritic := 'Erro ao atualizar o Lote!';
               RAISE vr_exc_erro;
        END;
    END IF;
  EXCEPTION 
    WHEN vr_exc_erro THEN
         pr_cdcritic := nvl(vr_cdcritic,0);
         pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
         pr_cdcritic := nvl(vr_cdcritic,0);
         pr_dscritic := 'Erro ao Realizar Lan�amento de Cr�dito de Desconto de T�tulos: '||SQLERRM;
  END pc_efetua_lanc_cc;
  
  PROCEDURE pc_processa_liquidacao_cobtit(pr_cdcooper  IN crapcop.cdcooper%TYPE --> C�digo da Cooperativa
                                         ,pr_nrdconta  IN crapass.nrdconta%TYPE --> N�mero da Conta
                                         ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE
                                         ,pr_nrctasac  IN crapcob.nrctasac%TYPE
                                         ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE
                                         ,pr_vlpagmto  IN NUMBER                --> Valor do pagamento
                                         ,pr_indpagto  IN crapcob.indpagto%TYPE --> Indicador pagamento
                                         ,pr_cdoperad  IN crapope.cdoperad%TYPE --> C�digo do Operador
                                         ,pr_cdagenci  IN crapass.cdagenci%TYPE --> Codigo da agencia
                                         ,pr_nrdcaixa  IN craperr.nrdcaixa%TYPE --> Numero Caixa
                                         ,pr_idorigem  IN INTEGER               --> Identificador Origem Chamada
                                         ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                         ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                         ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_processa_liquidacao_cobtit
      Sistema  : Ayllos
      Sigla    : DSTC
      Autor    : Paulo Penteado (GFT)
      Data     : Junho/2018
  
      Objetivo  : Efetuar a liquida��o de titulos gerados pela cobran�a COBTIT
  
      Altera��o : 10/06/2018 - Cria��o (Paulo Penteado (GFT))
  
    ----------------------------------------------------------------------------------------------------------*/
    TYPE tpy_ref_tdb IS REF CURSOR;
    cr_craptdb       tpy_ref_tdb;
    vr_sql           VARCHAR2(32767);
    
    vr_tab_tit_bordero typ_tab_tit_bordero;
    vr_vlpagmto        NUMBER(25,2);
    vr_vlpagmto_rest   NUMBER(25,2);

    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
  
    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
    
    CURSOR cr_cde IS
    SELECT cde.nrctremp
          ,cde.nrdconta
          ,cde.dsparcelas
          ,cde.nrcpfava
    FROM   tbrecup_cobranca cde
    WHERE  cde.tpproduto    = 3
    AND    cde.nrdconta     = pr_nrctasac
    AND    cde.nrboleto     = pr_nrdocmto
    AND    cde.nrcnvcob     = pr_nrcnvcob
    AND    cde.nrdconta_cob = pr_nrdconta
    AND    cde.cdcooper     = pr_cdcooper;
    rw_cde cr_cde%ROWTYPE;
     
  BEGIN
    --    Verifica se a data esta cadastrada
    OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat into rw_crapdat;
    IF    btch0001.cr_crapdat%NOTFOUND THEN
          CLOSE btch0001.cr_crapdat;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
          RAISE vr_exc_erro;
    END   IF;
    CLOSE btch0001.cr_crapdat;

    OPEN  cr_cde;
    FETCH cr_cde INTO rw_cde;
    IF    cr_cde%FOUND THEN
          CLOSE cr_cde;
          
          vr_vlpagmto      := pr_vlpagmto;
          vr_vlpagmto_rest := vr_vlpagmto;

          vr_sql := 'SELECT tmp.* '|| 
                          ', rownum nrnumlin, count(1) over() qttotlin '||
                    'FROM ( '||
                    'SELECT tdb.cdbandoc, tdb.nrdctabb, tdb.nrcnvcob, tdb.nrdocmto, tdb.nrtitulo '||
                          ',tdb.vlsldtit + (tdb.vliofcpl - tdb.vlpagiof) + (tdb.vlmtatit - tdb.vlpagmta) + (tdb.vlmratit - tdb.vlpagmra) vltitulo_total '||
                    'FROM   craptdb tdb '||
                    'WHERE  tdb.nrborder = :nrborder '||
                    'AND    tdb.nrdconta = :nrdconta '||
                    'AND    tdb.cdcooper = :cdcooper '||
                    'AND    tdb.nrtitulo in ('||rw_cde.dsparcelas||') '||
                    'ORDER  BY tdb.dtvencto ASC, tdb.vlsldtit DESC '||
                    ') tmp';
          
          OPEN  cr_craptdb
          FOR   vr_sql
          USING rw_cde.nrctremp, rw_cde.nrdconta, pr_cdcooper;
          LOOP
            FETCH cr_craptdb INTO vr_tab_tit_bordero(1).cdbandoc
                                 ,vr_tab_tit_bordero(1).nrdctabb
                                 ,vr_tab_tit_bordero(1).nrcnvcob
                                 ,vr_tab_tit_bordero(1).nrdocmto
                                 ,vr_tab_tit_bordero(1).nrtitulo
                                 ,vr_tab_tit_bordero(1).vltitulo
                                 ,vr_tab_tit_bordero(1).nrnumlin
                                 ,vr_tab_tit_bordero(1).qttotlin;
            EXIT  WHEN cr_craptdb%NOTFOUND;
            
            -- verificar se � o �ltimo titulo da lista da COBTIT
            IF vr_tab_tit_bordero(1).nrnumlin = vr_tab_tit_bordero(1).qttotlin THEN
              vr_vlpagmto := vr_vlpagmto_rest;
            ELSE
              vr_vlpagmto_rest := vr_vlpagmto_rest - vr_tab_tit_bordero(1).vltitulo;
              vr_vlpagmto      := vr_tab_tit_bordero(1).vltitulo;
            END IF;
            
            pc_pagar_titulo(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_idorigem => pr_idorigem
                           ,pr_cdoperad => pr_cdoperad
                           ,pr_nrdconta => rw_cde.nrdconta
                           ,pr_nrborder => rw_cde.nrctremp
                           ,pr_cdbandoc => vr_tab_tit_bordero(1).cdbandoc
                           ,pr_nrdctabb => vr_tab_tit_bordero(1).nrdctabb
                           ,pr_nrcnvcob => vr_tab_tit_bordero(1).nrcnvcob
                           ,pr_nrdocmto => vr_tab_tit_bordero(1).nrdocmto
                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                           ,pr_inproces => rw_crapdat.inproces
                           ,pr_cdorigpg => 2 -- COBTIT
                           ,pr_indpagto => pr_indpagto
                           ,pr_flpgtava => CASE WHEN rw_cde.nrcpfava IS NULL THEN 0 ELSE 1 END
                           ,pr_vlpagmto => vr_vlpagmto
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);

            IF NVL(vr_cdcritic,0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END   LOOP;
          CLOSE cr_craptdb;
    END   IF;
  EXCEPTION
    WHEN vr_exc_erro then
         IF  vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := vr_dscritic;
  
    WHEN OTHERS THEN
         pr_cdcritic := nvl(vr_cdcritic,0);
         pr_dscritic := 'Erro geral na rotina DSCT0003.pc_processa_liquidacao_cobtit: '||SQLERRM;
  END pc_processa_liquidacao_cobtit;
  
END DSCT0003;
/
