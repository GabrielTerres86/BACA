CREATE OR REPLACE PACKAGE CECRED."DSCT0003" AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa:  DSCT0003                       Antiga: generico/procedures/b1wgen0030.p
  --  Autor   : André Ávila - GFT
  --  Data    : Abril/2018                     Ultima Atualizacao: 14/01/2019
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package para rotinas para atender a Análise Automática e Liberação de Borderôs
  --
  --
  --  Alteracoes: 10/04/2018 - Conversao Progress para oracle (André Ávila - GFT)
  --
  --              10/04/2018 - Criacao da procedure pc_efetua_liberacao_bordero
  --              26/04/2018 - Andrew Albuquerque (GFT) - Adicionar Chamada a Mesa de Checagem e a Esteira de Crédito IBRATAN:
  --                           Alteração nas procedures: pc_altera_status_bordero (gravar opcionalmente campos de status de
  --                           análise e mesa de checagem / pc_restricoes_tit_bordero (validações impeditivas movidas para a
  --                           pc_efetua_analise_bordero) / pc_efetua_analise_bordero: adicionado parametro para dizer se
  --                           realiza analise completa ou apenas a impeditiva; alterada validação pós restrições, para executar
  --                           apenas quando chamado por análise e para enviar para mesa de checagem ou esteira; Validação de
  --                           contingência movida para verificar antes de enviar dados para a mesa do ibratan.
  --
  --              24/08/2018 - Adicionar novo histórico de credito para desconto de titulo pago a maior (vr_cdhistordsct_creddscttitpgm).
  --                           Este será usado na pc_pagar_titulo quando o valor pago do boleto for maior que o saldo restante. (Andrew Albuquerque (GFT))
  --
  --              14/09/2018 - Passar a gravar a data de último pagamento realizado no borderô (Andrew Albuquerque (GFT))
  --
  --              18/09/2018 - pc_pagar_titulo: Adicionar nova origem 4 - Acordos. Alterações na procedure para suprir esta origem. (Andrew Albuquerque (GFT))
  --
  --              23/11/2018 - Criada procedure para verificar a situacao do pagador no biro (Luis Fernando - GFT)
  --
  --              14/01/2019 - Incluso nova procedure pc_verifica_impressao (Daniel)
  ---------------------------------------------------------------------------------------------------------------

  -- Constantes
  vr_cdhistordsct_iofspriadic    CONSTANT craphis.cdhistor%TYPE := 2320; --IOF S/ DESCONTO DE TITULOS (PRINCIPAL E ADICIONAL)
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
  vr_cdhistordsct_pgtoavalcc     CONSTANT craphis.cdhistor%TYPE := 2674; --PAGTO DESCONTO DE TITULO AVAL  (conta cooperado)
  vr_cdhistordsct_pgtoavalopc    CONSTANT craphis.cdhistor%TYPE := 2675; --PAGTO DESCONTO DE TITULO AVAL  (operacao credito)
  vr_cdhistordsct_resgatetitdsc  CONSTANT craphis.cdhistor%TYPE := 2678; -- RESGATE DE TÍTULO DESCONTADO
  vr_cdhistordsct_rendapgtoant   CONSTANT craphis.cdhistor%TYPE := 2680; --RENDA SOBRE PGTO ANTECIPADO DESCONTO DE TITULO (conta cooperado)
  vr_cdhistordsct_pgtomultacc    CONSTANT craphis.cdhistor%TYPE := 2681; --PAGTO DE MULTA SOBRE DESCONTO DE TITULO (conta cooperado)
  vr_cdhistordsct_pgtomultaopc   CONSTANT craphis.cdhistor%TYPE := 2682; --PAGTO DE MULTA SOBRE DESCONTO DE TITULO (operacao credito)
  vr_cdhistordsct_pgtomultaavcc  CONSTANT craphis.cdhistor%TYPE := 2683; --PAGTO DE MULTA SOBRE DESCONTO DE TITULO AVAL (conta cooperado)
  vr_cdhistordsct_pgtomultaavopc CONSTANT craphis.cdhistor%TYPE := 2684; --PAGTO DE MULTA SOBRE DESCONTO DE TITULO AVAL (operacao credito)
  vr_cdhistordsct_pgtojuroscc    CONSTANT craphis.cdhistor%TYPE := 2685; --PAGTO DE JUROS MORA SOBRE DESCONTO DE TITULO (conta cooperado)
  vr_cdhistordsct_pgtojurosopc   CONSTANT craphis.cdhistor%TYPE := 2686; --PAGTO DE JUROS MORA SOBRE DESCONTO DE TITULO (operacao credito)
  vr_cdhistordsct_pgtojurosavcc  CONSTANT craphis.cdhistor%TYPE := 2687; --PAGTO DE JUROS MORA SOBRE DESCONTO DE TITULO AVAL (conta cooperado)
  vr_cdhistordsct_pgtojurosavopc CONSTANT craphis.cdhistor%TYPE := 2688; --PAGTO DE JUROS MORA SOBRE DESCONTO DE TITULO AVAL (operacao credito)
  vr_cdhistordsct_credpagmaior   CONSTANT craphis.cdhistor%TYPE := 2758; --CREDITO DESCONTO DE TITULO PAGO A MAIOR (pagamento dentro da cooperativa)
  vr_cdhistordsct_credpagmaiorIF CONSTANT craphis.cdhistor%TYPE := 2790; --CREDITO DESCONTO DE TITULO PAGO A MAIOR (pagamento em outra IF / COMPE)
  vr_cdhistordsct_jratuprejuz    CONSTANT craphis.cdhistor%TYPE := 2763; --JUROS DE ATUALIZAÇÃO PREJUIZO S/DESCONTO DE TITULO
  vr_cdhistordsct_sumjratuprejuz CONSTANT craphis.cdhistor%TYPE := 2798; --SOMATORIO DOS JUROS DE ATUALIZAÇÃO PREJUIZO S/DESCONTO DE TITULO
  vr_cdhistordsct_credabonodscto CONSTANT craphis.cdhistor%TYPE := 2799; --ABONO DESCONTO DE TITULO (BOLETAGEM MASSIVA)
  vr_cdhistordsct_deboppagmaior  CONSTANT craphis.cdhistor%TYPE := 2804; --AJUSTE DE VALOR A MAIOR DO PAGAMENTO
  vr_cdhistordsct_iofcompleoper  CONSTANT craphis.cdhistor%TYPE := 2800; --DEBITO DE IOF COMPLEMENTAR NA OPERACAO
  -- Estorno
  vr_cdhistorlcm_pgto            CONSTANT craphis.cdhistor%TYPE := 2805; -- LCM --  EST.PAGAMENTO ESTORNO DE PAGAMENTO DESCONTO DE TITULO ESTORNO PGTO DESC.TIT  -- Estorno da 2670
  vr_cdhistorlcm_multa           CONSTANT craphis.cdhistor%TYPE := 2806; -- LCM --  EST.MULTA ESTORNO DE PAGAMENTO MULTA DESCONTO DE TITULO ESTORNO MULTA DESC.  -- Estorno da 2681
  vr_cdhistorlcm_juros           CONSTANT craphis.cdhistor%TYPE := 2807; -- LCM --  EST.JUROS ESTORNO DE PAGAMENTO JUROS MORA DESCONTO DE TITULO  ESTORNO JUROS DESC.  -- Estorno da 2685
  vr_cdhistorlcm_pgto_ava        CONSTANT craphis.cdhistor%TYPE := 2808; -- LCM --  EST.PGTO AVAL ESTORNO DE PAGAMENTO DESCONTO DE TITULO AVAL  ESTORNO PGTO DESC.TIT  -- Estorno da 2674
  vr_cdhistorlcm_multa_ava       CONSTANT craphis.cdhistor%TYPE := 2809; -- LCM --  EST.MULTA ESTORNO DE PAGAMENTO MULTA DESCONTO DE TITULO AVAL  ESTORNO MULTA DESC.  -- Estorno da 2683
  vr_cdhistorlcm_juros_ava       CONSTANT craphis.cdhistor%TYPE := 2810; -- LCM --  EST.JUROS ESTORNO DE PGTO JUROS MORA DESCONTO DE TITULO AVAL  ESTORNO JUROS DESC.  -- Estorno da 2687
  vr_cdhistordsct_est_pgto       CONSTANT craphis.cdhistor%TYPE := 2811; -- EST.PAGAMENTO ESTORNO DE PAGAMENTO DESCONTO DE TITULO ESTORNO PGTO DESC.TIT 2671
  vr_cdhistordsct_est_multa      CONSTANT craphis.cdhistor%TYPE := 2812; -- EST. MULTA  ESTORNO DE PAGAMENTO MULTA DESCONTO DE TITULO ESTORNO MULTA DESC. 2682
  vr_cdhistordsct_est_juros      CONSTANT craphis.cdhistor%TYPE := 2813; -- EST.JUROS ESTORNO DE PAGAMENTO JUROS MORA DESCONTO DE TITULO  ESTORNO JUROS DESC. 2686
  vr_cdhistordsct_est_pgto_ava   CONSTANT craphis.cdhistor%TYPE := 2814; -- EST.PGTO AVAL ESTORNO DE PAGAMENTO DESCONTO DE TITULO AVAL  ESTORNO PGTO DESC.TIT 2675
  vr_cdhistordsct_est_multa_ava  CONSTANT craphis.cdhistor%TYPE := 2815; -- EST. MULTA  ESTORNO DE PAGAMENTO MULTA DESCONTO DE TITULO AVAL  ESTORNO MULTA DESC. 2684
  vr_cdhistordsct_est_juros_ava  CONSTANT craphis.cdhistor%TYPE := 2816; -- EST.JUROS ESTORNO DE PGTO JUROS MORA DESCONTO DE TITULO AVAL  ESTORNO JUROS DESC. 2688
  vr_cdhistordsct_est_apro_multa CONSTANT craphis.cdhistor%TYPE := 2880; -- ESTORNO APROPRIACAO DE MULTA - EST.PAGTO
  vr_cdhistordsct_est_apro_juros CONSTANT craphis.cdhistor%TYPE := 2881; -- ESTORNO APROPRIACAO DE JUROS DE MORA - EST.PAGTO

  --Tipo de Desconto de Títulos
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

  /* Tipo que compreende o registro da tab. temporária tt-msg-confirma */
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
                  inprejuz crapbdt.inprejuz%TYPE,
                  vlprejuz NUMBER(25,2),
                  vlpago   NUMBER(25,2),
                  vlmulta  NUMBER(25,2),
                  vlmora   NUMBER(25,2),
                  vliof    NUMBER(25,2),
                  vlpagar  NUMBER(25,2),
                  nrnumlin NUMBER,
                  qttotlin NUMBER,
                  flacordo INTEGER,
                  flgjudic INTEGER,
                  flextjud INTEGER,
                  flgehvip INTEGER,
                  vlorigem NUMBER(25,2)
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
      cri.cdcritica,
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

  FUNCTION fn_busca_situacao_titulo(pr_insittit craptdb.insittit%TYPE
                                   ,pr_flverbor crapbdt.flverbor%TYPE DEFAULT 0) RETURN VARCHAR2;

  -- Funcao de calculo de restricao do CNAE
  FUNCTION fn_calcula_cnae(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa conectada
                           ,pr_nrdconta IN crapass.nrdconta%TYPE   --> Conta do associado
                           ,pr_nrdocmto IN crapcob.nrdocmto%TYPE   --> Numero do documento(Boleto)
                           ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE   --> Numero do convenio de cobranca.
                           ,pr_nrdctabb IN crapcob.nrdctabb%TYPE   --> Numero da conta base no banco.
                           ,pr_cdbandoc IN crapcob.cdbandoc%TYPE   --> Codigo do banco/caixa.
         )RETURN BOOLEAN;

  -- Verificar se o bordero está nas novas funcionalidades ou na antiga
  FUNCTION fn_virada_bordero (pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN INTEGER;


  -- Verificar qual a versão do borderô
  FUNCTION fn_versao_bordero (pr_cdcooper IN crapcop.cdcooper%TYPE
                             ,pr_nrborder IN crapbdt.nrborder%TYPE
                             ) RETURN INTEGER;

  -- Cálculo da Liquidez Geral
  FUNCTION fn_calcula_liquidez_geral (pr_nrdconta      IN crapass.nrdconta%type
                                      ,pr_cdcooper     IN crapcop.cdcooper%TYPE
                                      ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE
                                      ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                                      ,pr_qtcarpag     IN NUMBER
                                      ,pr_qtmitdcl     IN INTEGER
                                      ,pr_vlmintcl     IN NUMBER
                                      )RETURN NUMBER;

  -- Cálculo da Concentração do título do pagador
  FUNCTION fn_concentracao_titulo_pagador (pr_cdcooper     IN craptdb.cdcooper%TYPE
                                          ,pr_nrdconta     IN craptdb.nrdconta%TYPE
                                          ,pr_nrinssac     IN crapcob.nrinssac%TYPE
                                          ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE
                                          ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                                          ,pr_qtcarpag     IN NUMBER
                                          ,pr_qtmitdcl     IN INTEGER
                                          ,pr_vlmintcl     IN NUMBER
                                          ) RETURN NUMBER;

  -- Cálculo da Liquidez do Pagador
  FUNCTION fn_liquidez_pagador_cedente (pr_cdcooper     IN craptdb.cdcooper%TYPE
                                       ,pr_nrdconta     IN craptdb.nrdconta%TYPE
                                       ,pr_nrinssac     IN crapcob.nrinssac%TYPE
                                       ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE
                                       ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                                       ,pr_qtcarpag     IN NUMBER
                                       ,pr_qtmitdcl     IN INTEGER
                                       ,pr_vlmintcl     IN NUMBER
                                        ) RETURN NUMBER;

  FUNCTION fn_cobranca_cobtit(pr_cdcooper IN crapbdt.cdcooper%TYPE --> Código da Cooperativa
                             ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                             ) RETURN BOOLEAN;


  FUNCTION fn_retorna_rating(pr_dsinrisc NUMBER) RETURN VARCHAR2 ;

  FUNCTION fn_spc_serasa (pr_cdcooper crapcbd.cdcooper%TYPE, pr_nrdconta crapcbd.nrdconta%TYPE, pr_nrcpfcgc crapcbd.nrcpfcgc%TYPE) RETURN VARCHAR2;

  PROCEDURE pc_liberar_bordero_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                   ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                   ,pr_confirma IN PLS_INTEGER            --> numero do bordero
                                   --  (OBRIGATÓRIOS E NESSA ORDEM SEMPRE)
                                   ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                   --------> OUT <--------
                                   ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                   ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);      --> Erros do processo

  /*Procedure que grava as restrições de um borderô (b1wgen0030.p/grava-restricao-bordero)*/
  PROCEDURE pc_grava_restricao_bordero (pr_nrborder IN crapabt.nrborder%TYPE --> Número do Borderô
                                       ,pr_cdoperad IN crapabt.cdoperad%TYPE DEFAULT NULL --> Codigo do operador
                                       ,pr_nrdconta IN crapabt.nrdconta%TYPE
                                       ,pr_dsrestri IN crapabt.dsrestri%TYPE --> Descrição da Restrição
                                       ,pr_nrseqdig IN crapabt.nrseqdig%TYPE --> Sequêncial da Restrição
                                       ,pr_cdcooper IN crapabt.cdcooper%TYPE --> Código da Cooperativa
                                       ,pr_cdbandoc IN crapabt.cdbandoc%TYPE DEFAULT 0
                                       ,pr_nrdctabb IN crapabt.nrdctabb%TYPE DEFAULT 0
                                       ,pr_nrcnvcob IN crapabt.nrcnvcob%TYPE DEFAULT 0
                                       ,pr_nrdocmto IN crapabt.nrdocmto%TYPE DEFAULT 0
                                       ,pr_flaprcoo IN crapabt.flaprcoo%TYPE --> Indicador se foi aprovado pelo coordenador (1 Sim / 0 Não)
                                       ,pr_dsdetres IN crapabt.dsdetres%TYPE --> Detalhamento da restricao
                                       ,pr_dscritic    OUT VARCHAR2                --> Descricao Critica
                                       );

  /* Retona a qtd. de Títulos de acordo com alguma ocorrencia (b1wgen0030.p/retorna-titulos-ocorrencia) */
  PROCEDURE pc_ret_qttit_ocorrencia (pr_cdcooper IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                    ,pr_nrdconta IN craptdb.nrdconta%TYPE --> Número da Conta
                                    ,pr_nrinssac IN craptdb.nrinssac%TYPE --> Pagador
                                    ,pr_cdocorre IN crapret.cdocorre%TYPE --> Código do Tipo de Ocorrência
                                    ,pr_cdmotivo IN crapret.cdmotivo%TYPE DEFAULT '' --> Contém o Código do Motivo
                                    ,pr_flgtitde IN boolean DEFAULT FALSE --> Qual Tipo de Tìtulo (FALSE= Apenas Títulos em Borderô)
                                    --------> OUT <--------
                                    ,pr_cntqttit OUT PLS_INTEGER          --> Quantidade de Tìtulos de Acordo com o Filtro.
                                    );

  /* Buscar dados do Principal (@) da rotina Desconto de Titulos (b1wgen0030.p/busca_dados_dsctit) */
  PROCEDURE pc_busca_dados_dsctit (pr_cdcooper IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                  ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL --> Codigo do operador
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                  ,pr_idorigem IN INTEGER  --Identificador Origem pagamento
                                  ,pr_nrdconta IN craptdb.nrdconta%TYPE DEFAULT NULL --> Número da Conta
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
  PROCEDURE pc_valida_tit_bordero (pr_cdcooper IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                  ,pr_cdagenci IN crawlim.cdagenci%TYPE --> Código da Agência
                                  ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE
                                  ,pr_nrdconta IN craptdb.nrdconta%TYPE --> Número da Conta
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE
                                  ,pr_tpvalida IN INTEGER DEFAULT 1 --> 1: Análise do Borderô 2: Inclusão do Borderô.
                                  --------> OUT <--------
                                  ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela Erros
                                  ,pr_des_reto OUT VARCHAR2
                                  );

  /* Procura estriçoes de um borderô e cria entradas na  tabela de restrições quando encontradas (b1wgen0030.p/analisar-titulo-bordero) */
  PROCEDURE pc_restricoes_tit_bordero (pr_cdcooper IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_cdagenci IN crawlim.cdagenci%TYPE --> Código da Agência
                                      ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE
                                      ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                                      ,pr_nmdatela IN VARCHAR2      --> Nome da tela
                                      ,pr_idorigem IN INTEGER  --> Identificador Origem pagamento
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                      ,pr_nrdconta IN craptdb.nrdconta%TYPE DEFAULT NULL --> Número da Conta
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
                             ,pr_cdagenci IN crapass.cdagenci%type --> Código da Agência
                             ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                             ,pr_dtmvtolt IN crapbdt.dtmvtolt%TYPE
                             --------- OUT ---------
                             ,pr_cdcritic OUT INTEGER   --> Codigo Critica
                             ,pr_dscritic OUT VARCHAR2  --> Descricao Critica
                             ,pr_des_erro OUT VARCHAR2  --> Erros do processo
                             );

  /* Efetuar a Análise Completa do Borderô */
  PROCEDURE pc_efetua_analise_bordero (pr_cdcooper IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_cdagenci IN crapass.cdagenci%type --> Código da Agência
                                      ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Numero Caixa
                                      ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                                      ,pr_nmdatela IN craplgm.nmdatela%TYPE --> Nome da tela.
                                      ,pr_idorigem IN VARCHAR2              --> Identificador Origem pagamento
                                      ,pr_nrdconta IN craptdb.nrdconta%TYPE --> Número da Conta
                                      ,pr_idseqttl IN INTEGER               --> idseqttl
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                      ,pr_dtmvtopr IN crapdat.dtmvtolt%TYPE --> Proxima data de movimento.
                                      ,pr_inproces IN crapdat.inproces%TYPE --> Indicador processo
                                      ,pr_nrborder IN crapbdt.nrborder%TYPE --> Número do Bordero
                                      ,pr_inrotina IN INTEGER DEFAULT 0     --> Indica o tipo de análise (0-APENAS IMPEDITIVOS / 1-IMPEDITIVOS+RESTRIÇÕES COM APROVAÇÃO DE ANÁLISE)
                                      ,pr_flgerlog IN BOOLEAN               --> identificador se deve gerar log
                                      ,pr_insborde IN INTEGER DEFAULT 0     --> Indica se a analise esta sendo feito na inserção apenas para aprovar automatico
                                      --------> OUT <--------
                                      ,pr_indrestr OUT PLS_INTEGER          --> Indica se Gerou Restrição (0 - Sem Restrição / 1 - Com restrição)
                                      ,pr_ind_inpeditivo OUT PLS_INTEGER          --> Indica se o Resultado é Impeditivo para Realizar Liberação. (0 - Sem Impedimentos / 1 - Com Impedimentos)
                                      ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela Erros
                                      ,pr_tab_retorno_analise OUT typ_tab_retorno_analise --> Detalhes Finais da Analise do Bordero.
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descriçao da crítica
                                      );

  PROCEDURE pc_efetua_analise_bordero_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                          ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                           --  (OBRIGATÓRIOS E NESSA ORDEM SEMPRE)
                                          ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                          --------> OUT <--------
                                          ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                          ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2);      --> Erros do processo

  -- Procedure que busca um associado a partir da conta ou cpf/cnpj
  PROCEDURE pc_buscar_associado_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                   ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE  --> Número do CPF/CNPJ
                                   ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                   --------> OUT <--------
                                   ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
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

  -- Verificar se o bordero está nas novas funcionalidades ou na antiga
  PROCEDURE pc_virada_bordero (pr_nrborder  IN crapbdt.nrborder%TYPE DEFAULT 0
                              ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                               --------> OUT <--------
                               ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                               ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                             );

  -- Buscar todo os titulos vencidos de um bordero
  PROCEDURE pc_busca_titulos_vencidos_web(pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                    ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                    ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                    --------> OUT <--------
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2             --> Erros do processo
                                    );
  PROCEDURE pc_calcula_possui_saldo (pr_nrdconta  IN crapass.nrdconta%TYPE  --> Número da Conta
                                    ,pr_nrborder  IN crapbdt.nrborder%TYPE  --> Numero do bordero
                                    ,pr_arrtitulo IN VARCHAR2           --> Lista dos titulos
                                    ,pr_xmllog    IN VARCHAR2               --> XML com informações de LOG
                                    --------> OUT <--------
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                    ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                   );
 PROCEDURE pc_pagar_titulos_vencidos (pr_nrdconta         IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_nrborder         IN crapbdt.nrborder%TYPE  --> Numero do bordero
                                     ,pr_flavalista       IN VARCHAR2                --> Caso seja pagamento com avalista
                                     ,pr_arrtitulo        IN VARCHAR2               --> Lista dos titulos
                                     ,pr_xmllog           IN VARCHAR2               --> XML com informações de LOG
                                     --------> OUT <--------
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                     ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                    ) ;

 PROCEDURE pc_inserir_lancamento_bordero(pr_cdcooper  IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
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
                                       ,pr_dscritic OUT VARCHAR2                                          --> Descrição da crítica
                                        );

 PROCEDURE pc_calcula_liquidez_geral(pr_cdcooper     IN craptdb.cdcooper%TYPE
                            ,pr_nrdconta     IN craptdb.nrdconta%TYPE
                            ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE
                            ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                            ,pr_qtcarpag     IN NUMBER
                            ,pr_qtmitdcl     IN INTEGER  DEFAULT 0
                            ,pr_vlmintcl     IN NUMBER   DEFAULT 0
                            -- OUT --
                            ,pr_pc_geral     OUT NUMBER
                            ,pr_qtd_geral    OUT NUMBER);

 PROCEDURE pc_calcula_liquidez_pagador(pr_cdcooper     IN craptdb.cdcooper%TYPE
                            ,pr_nrdconta     IN craptdb.nrdconta%TYPE
                            ,pr_nrinssac     IN crapcob.nrinssac%TYPE DEFAULT NULL
                            ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE
                            ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                            ,pr_qtcarpag     IN NUMBER
                            ,pr_qtmitdcl     IN INTEGER  DEFAULT 0
                            ,pr_vlmintcl     IN NUMBER   DEFAULT 0
                            -- OUT --
                            ,pr_pc_cedpag    OUT NUMBER
                            ,pr_qtd_cedpag   OUT NUMBER);

 PROCEDURE pc_calcula_concentracao(pr_cdcooper     IN craptdb.cdcooper%TYPE
                            ,pr_nrdconta     IN craptdb.nrdconta%TYPE
                            ,pr_nrinssac     IN crapcob.nrinssac%TYPE DEFAULT NULL
                            ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE
                            ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                            ,pr_qtcarpag     IN NUMBER
                            ,pr_qtmitdcl     IN INTEGER  DEFAULT 0
                            ,pr_vlmintcl     IN NUMBER   DEFAULT 0
                            -- OUT --
                            ,pr_pc_conc      OUT NUMBER
                            ,pr_qtd_conc     OUT NUMBER);

 PROCEDURE pc_calcula_juros_simples_tit(pr_cdcooper  IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                        ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                        ,pr_nrborder  IN crapbdt.nrborder%TYPE --> numero do bordero
                                        ,pr_cdbandoc  IN craptdb.cdbandoc%TYPE --> Codigo do banco impresso no boleto
                                        ,pr_nrdctabb  IN craptdb.nrdctabb%TYPE --> Numero da conta base do titulo
                                        ,pr_nrcnvcob  IN craptdb.nrcnvcob%TYPE --> Numero do convenio de cobranca
                                        ,pr_nrdocmto  IN craptdb.nrdocmto%TYPE --> Numero do documento
                                        ,pr_vltitulo  IN craptdb.vltitulo%TYPE --> Valor do titulo
                                        ,pr_dtvencto  IN craptdb.dtvencto%TYPE --> Data vencimento titulo
                                        ,pr_dtmvtolt  IN craplcm.dtmvtolt%TYPE --> Data do movimento atual
                                        ,pr_txmensal  IN crapbdt.txmensal%TYPE --> Taxa mensal
                                        ,pr_flresgat  IN BOOLEAN DEFAULT FALSE --> Define se a rotina está sendo rodada para resgate
                                        ,pr_vldjuros OUT crapljt.vldjuros%TYPE --> Valor do juros calculado
                                        ,pr_dtrefere OUT DATE                  --> Data de referencia da atualizacao dos juros
                                        ,pr_dscritic OUT VARCHAR2              --> Descrição da critica
                                        );

 PROCEDURE pc_calcula_atraso_tit(pr_cdcooper    IN crapcop.cdcooper%TYPE      --Codigo Cooperativa
                                ,pr_nrdconta    IN craptdb.nrdconta%TYPE      --Número da conta do cooperado
                                ,pr_nrborder    IN craptdb.nrborder%TYPE      --Número do borderô
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

  PROCEDURE pc_calcula_juros60_tit(pr_cdcooper  IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                  ,pr_nrdconta  IN craptdb.nrdconta%TYPE --Número da conta do cooperado
                                  ,pr_nrborder  IN craptdb.nrborder%TYPE --Número do borderô
                                  ,pr_cdbandoc  IN craptdb.cdbandoc%TYPE --Codigo do banco impresso no boleto
                                  ,pr_nrdctabb  IN craptdb.nrdctabb%TYPE --Numero da conta base do titulo
                                  ,pr_nrcnvcob  IN craptdb.nrcnvcob%TYPE --Numero do convenio de cobranca
                                  ,pr_nrdocmto  IN craptdb.nrdocmto%TYPE --Numero do documento
                                  ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --Data Movimento
                                  ,pr_vljura60 OUT craptdb.vljura60%TYPE --Valor do juros 60
                                  ,pr_vljrre60 OUT craptdb.vljura60%TYPE --Valor do juros remuneratorio 60
                                  ,pr_cdcritic OUT PLS_INTEGER           --Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2              --Descricao da critica
                                  );

 PROCEDURE pc_pagar_titulo( pr_cdcooper    IN crapcop.cdcooper%TYPE           --Codigo Cooperativa
                            ,pr_cdagenci    IN INTEGER                         --Codigo Agencia
                            ,pr_nrdcaixa    IN INTEGER                         --Numero Caixa
                            ,pr_idorigem    IN INTEGER                         --Origem sistema
                            ,pr_cdoperad    IN VARCHAR2                        --Codigo operador
                            ,pr_nrdconta    IN craptdb.nrdconta%TYPE           --Número da conta do cooperado
                            ,pr_nrborder    IN craptdb.nrborder%TYPE           --Número do borderô
                            ,pr_cdbandoc    IN craptdb.cdbandoc%TYPE           --Codigo do banco impresso no boleto
                            ,pr_nrdctabb    IN craptdb.nrdctabb%TYPE           --Numero da conta base do titulo
                            ,pr_nrcnvcob    IN craptdb.nrcnvcob%TYPE           --Numero do convenio de cobranca
                            ,pr_nrdocmto    IN craptdb.nrdocmto%TYPE           --Numero do documento
                            ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE           --Data Movimento
                            ,pr_inproces    IN crapdat.inproces%TYPE DEFAULT 1 --Indicador do processo
                            ,pr_cdorigpg    IN NUMBER                DEFAULT 0 --Código da origem do processo de pagamento
                            ,pr_indpagto    IN crapcob.indpagto%TYPE DEFAULT 0 --Indica de onde vem o pagamento
                            ,pr_flpgtava    IN NUMBER                DEFAULT 0 --Pagamento efetuado pelo avalista 0-Não 1-Sim
                            ,pr_vlpagmto    IN OUT NUMBER                      --Valor do pagamento
                            ,pr_cdcritic    OUT INTEGER                        --Codigo Critica
                            ,pr_dscritic    OUT VARCHAR2) ;                   --Descricao Critica

  PROCEDURE pc_efetua_lanc_cc (pr_dtmvtolt  IN craplcm.dtmvtolt%TYPE -- Origem: do lote de liberação (craplot)
                              ,pr_cdagenci  IN craplcm.cdagenci%TYPE -- Origem: do lote de liberação (craplot)
                              ,pr_cdbccxlt  IN craplcm.cdbccxlt%TYPE -- Origem: do lote de liberação (craplot)
                              ,pr_nrdconta  IN craplcm.nrdconta%TYPE -- Origem: nrdconta do Bordero
                              ,pr_vllanmto  IN craplcm.vllanmto%TYPE -- Origem: do cálculo :aux_vlborder + craptdb.vlliquid da linha 1870.
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
                                           ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                                           ,pr_nrborder IN crapbdt.nrborder%TYPE --> numero do bordero
                                           ,pr_cdoperad IN crapcob.cdoperad%TYPE --> Operador que solicitou a consulta
                                            --------> OUT <--------
                                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                           );

  PROCEDURE pc_processa_liquidacao_cobtit(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                         ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                         ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE
                                         ,pr_nrctasac  IN crapcob.nrctasac%TYPE
                                         ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE
                                         ,pr_vlpagmto  IN NUMBER                --> Valor do pagamento
                                         ,pr_indpagto  IN crapcob.indpagto%TYPE --> Indicador pagamento
                                         ,pr_cdoperad  IN crapope.cdoperad%type --> Código do Operador
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

  PROCEDURE pc_calcula_restricao_bordero(pr_cdcooper    IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_nrdconta      IN craptdb.nrdconta%TYPE DEFAULT NULL --> Número da Conta
                                      ,pr_tot_titulos   IN  NUMBER                            --> Quantidade de títulos do borderô
                                      ,pr_tab_criticas  IN OUT typ_tab_critica
                                      ,pr_cdcritic    OUT INTEGER                 --> Codigo Critica
                                      ,pr_dscritic    OUT VARCHAR2                --> Descricao Critica
                                      );

  PROCEDURE pc_calcula_restricao_cedente(pr_cdcooper    IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_nrdconta      IN craptdb.nrdconta%TYPE DEFAULT NULL --> Número da Conta
                                      ,pr_cdagenci IN crawlim.cdagenci%TYPE --> Código da Agência
                                      ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE
                                      ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                                      ,pr_nmdatela IN VARCHAR2      --> Nome da tela
                                      ,pr_idorigem IN INTEGER  --> Identificador Origem pagamento
                                      ,pr_idseqttl IN INTEGER       --> idseqttl
                                      ,pr_tab_criticas IN OUT typ_tab_critica
                                      ,pr_cdcritic    OUT INTEGER                 --> Codigo Critica
                                      ,pr_dscritic    OUT VARCHAR2                --> Descricao Critica
                                      );

  PROCEDURE pc_calcula_restricao_pagador(pr_cdcooper    IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_nrdconta      IN craptdb.nrdconta%TYPE --> Número da Conta
                                      ,pr_nrinssac      IN craptdb.nrinssac%TYPE --> Pagador
                                      ,pr_nrdocmto      IN crapcob.nrdocmto%TYPE   --> Numero do documento(Boleto)
                                      ,pr_nrcnvcob      IN crapcob.nrcnvcob%TYPE   --> Numero do convenio de cobranca.
                                      ,pr_nrdctabb      IN crapcob.nrdctabb%TYPE   --> Numero da conta base no banco.
                                      ,pr_cdbandoc      IN crapcob.cdbandoc%TYPE   --> Codigo do banco/caixa.
                                      ,pr_tab_criticas  IN OUT typ_tab_critica
                                      ,pr_cdcritic    OUT INTEGER                 --> Codigo Critica
                                      ,pr_dscritic    OUT VARCHAR2                --> Descricao Critica
                                      );

  PROCEDURE pc_expira_bordero (pr_cdcooper    IN crapbdt.cdcooper%TYPE --> Cooperativa
                              ,pr_nrborder    IN crapbdt.nrborder%TYPE --> numero do bordero
                              --------> OUT <--------
                              ,pr_cdcritic OUT PLS_INTEGER             --> código da crítica
                              ,pr_dscritic OUT VARCHAR2                --> descrição da crítica
                              );

  PROCEDURE pc_expira_borderos_coop (pr_cdcooper    IN crapbdt.cdcooper%TYPE DEFAULT 0 --> Cooperativa
                                     --------> OUT <--------
                                    ,pr_cdcritic OUT PLS_INTEGER                       --> código da crítica
                                    ,pr_dscritic OUT VARCHAR2                          --> descrição da crítica
                                    );

  PROCEDURE pc_calcula_risco_bordero(pr_cdcooper IN crapbdt.cdcooper%TYPE
                                     ,pr_nrborder IN crapbdt.nrborder%TYPE
                                     --------> OUT <--------
                                     ,pr_dsinrisc OUT VARCHAR2                    --> Risco
                                     ,pr_cdcritic OUT PLS_INTEGER                 --> código da crítica
                                     ,pr_dscritic OUT VARCHAR2                    --> descrição da crítica
                                     );

  PROCEDURE pc_busca_dados_prejuizo_web (pr_nrdconta    IN crapass.nrdconta%TYPE --> conta do associado
                              ,pr_nrborder    IN crapbdt.nrborder%TYPE --> numero do bordero
                                        ,pr_xmllog      IN VARCHAR2              --> xml com informações de log
                              --------> OUT <--------
                              ,pr_cdcritic OUT PLS_INTEGER             --> código da crítica
                              ,pr_dscritic OUT VARCHAR2                --> descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY xmltype       --> arquivo de retorno do xml
                                        ,pr_nmdcampo OUT VARCHAR2                --> nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2                --> erros do processo
                              );

  PROCEDURE pc_calcula_saldo_prejuizo_web (pr_nrdconta     IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_nrborder     IN crapbdt.nrborder%TYPE  --> Numero do bordero
                                     ,pr_vlaboorj     IN NUMBER                 --> Valor do abono
                                     ,pr_vlpagmto     IN NUMBER                 --> Valor do pagamento
                                     ,pr_xmllog       IN VARCHAR2               --> XML com informações de LOG
                                     --------> OUT <--------
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                     ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                   );

  PROCEDURE pc_pagar_prejuizo_web (pr_nrdconta    IN crapass.nrdconta%TYPE --> conta do associado
                                       ,pr_nrborder    IN crapbdt.nrborder%TYPE --> numero do bordero
                                       ,pr_vlaboorj     IN NUMBER                 --> Valor do abono
                                       ,pr_vlpagmto     IN NUMBER                 --> Valor do pagamento
                                       ,pr_xmllog      IN VARCHAR2              --> xml com informações de log
                                     --------> OUT <--------
                                    ,pr_cdcritic OUT PLS_INTEGER                       --> código da crítica
                                    ,pr_dscritic OUT VARCHAR2                          --> descrição da crítica
                                       ,pr_retxml      IN OUT NOCOPY xmltype      --> arquivo de retorno do xml
                                       ,pr_nmdcampo   OUT VARCHAR2                --> nome do campo com erro
                                       ,pr_des_erro   OUT VARCHAR2                --> erros do processo
                                    );

  PROCEDURE pc_buscar_borderos_liberados (pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da Conta
                                         ,pr_nrctremp  IN craptdb.nrborder%TYPE DEFAULT 0--> Numero do bordero
                                         ,pr_nrborder  IN craptdb.nrborder%TYPE DEFAULT 0 --> Numero do bordero
                                         ,pr_xmllog        IN VARCHAR2             --> XML com informações de LOG
                                         ,pr_cdcritic     OUT PLS_INTEGER          --> Código da crítica
                                         ,pr_dscritic     OUT VARCHAR2             --> Descrição da crítica
                                         ,pr_retxml        IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                                         ,pr_nmdcampo     OUT VARCHAR2             --> Nome do campo com erro
                                         ,pr_des_erro     OUT VARCHAR2
                                        );

PROCEDURE pc_verifica_impressao (pr_nrdconta  IN craplim.nrdconta%TYPE,
                              pr_nrctrlim  IN craplim.nrctrlim%TYPE
                              ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                              --------> OUT <--------
                              ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                              ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                              );

  PROCEDURE pc_lanc_jratu_mensal(pr_cdcooper IN crapbdt.cdcooper%TYPE
                                ,pr_cdagenci IN crapass.cdagenci%TYPE DEFAULT NULL
                                ,pr_dtmvtolt IN crapbdt.dtmvtolt%TYPE
                                ,pr_nrborder IN crapbdt.nrborder%TYPE DEFAULT 0
                                ,pr_nrdconta IN crapbdt.nrdconta%TYPE DEFAULT 0
                              --------> OUT <--------
                                ,pr_cdcritic OUT PLS_INTEGER                 --> código da crítica
                                ,pr_dscritic OUT VARCHAR2                    --> descrição da crítica
                              );

  PROCEDURE pc_pagar_titulo_operacao ( pr_cdcooper    IN crapcop.cdcooper%TYPE           --Codigo Cooperativa
                            ,pr_cdagenci    IN INTEGER                         --Codigo Agencia
                            ,pr_nrdcaixa    IN INTEGER                         --Numero Caixa
                            ,pr_idorigem    IN INTEGER                         --Origem sistema
                            ,pr_cdoperad    IN VARCHAR2                        --Codigo operador
                            ,pr_nrdconta    IN craptdb.nrdconta%TYPE           --Número da conta do cooperado
                            ,pr_nrborder    IN craptdb.nrborder%TYPE           --Número do borderô
                            ,pr_cdbandoc    IN craptdb.cdbandoc%TYPE           --Codigo do banco impresso no boleto
                            ,pr_nrdctabb    IN craptdb.nrdctabb%TYPE           --Numero da conta base do titulo
                            ,pr_nrcnvcob    IN craptdb.nrcnvcob%TYPE           --Numero do convenio de cobranca
                            ,pr_nrdocmto    IN craptdb.nrdocmto%TYPE           --Numero do documento
                            ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE           --Data Movimento
                            ,pr_inproces    IN crapdat.inproces%TYPE DEFAULT 1 --Indicador do processo
                            ,pr_indpagto    IN crapcob.indpagto%TYPE DEFAULT 0 --Indica de onde vem o pagamento
                            ,pr_vlpagmto    IN OUT NUMBER                      --Valor do pagamento
                            ,pr_cdcritic    OUT INTEGER                        --Codigo Critica
                            ,pr_dscritic    OUT VARCHAR2);

  PROCEDURE pc_retorna_liquidez_geral(pr_cdcooper     IN craptdb.cdcooper%TYPE
                            ,pr_nrdconta     IN craptdb.nrdconta%TYPE
                            ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE
                            ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                            ,pr_qtcarpag     IN NUMBER
                            ,pr_qtmitdcl     IN INTEGER  DEFAULT 0
                            ,pr_vlmintcl     IN NUMBER   DEFAULT 0
                            -- OUT --
                            ,pr_pc_geral     OUT NUMBER
                            ,pr_qtd_geral    OUT NUMBER);

  PROCEDURE pc_verifica_contrato_bodero (pr_nrdconta  IN craplim.nrdconta%TYPE,
                              pr_nrctrlim  IN craplim.nrctrlim%TYPE
                              ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                              --------> OUT <--------
                              ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                              ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                              );

 PROCEDURE pc_verifica_bordero_ib (pr_nrdconta  IN crapbdt.nrdconta%TYPE,
                                    pr_nrborder  IN crapbdt.nrctrlim%TYPE
                                    ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                    --------> OUT <--------
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                    ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                    );

END  DSCT0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED."DSCT0003" AS

  /*---------------------------------------------------------------------------------------------------------------

    Programa :  DSCT0003
    Sistema  : Procedimentos envolvendo liberação de borderôs
    Sigla    : CRED
    Autor    : André Ávila - GFT
    Data     : Abril/2018.                   Ultima atualizacao: 18/09/2018

   Dados referentes ao programa:

   Frequencia: -----
   Objetivo  : Procedimentos envolvendo liberação de borderôs

   Alteracoes: 10/04/2018 - Desconto de Títulos KE00726701-185 Borderô - Liberar KE00726701-476 (André Ávila - GFT)

               26/04/2018 - Andrew Albuquerque (GFT) - Adicionar Chamada a Mesa de Checagem e a Esteira de Crédito IBRATAN:
                            Alteração nas procedures: pc_altera_status_bordero (gravar opcionalmente campos de status de
                            análise e mesa de checagem / pc_restricoes_tit_bordero (validações impeditivas movidas para a
                            pc_efetua_analise_bordero) / pc_efetua_analise_bordero: adicionado parametro para dizer se
                            realiza analise completa ou apenas a impeditiva; alterada validação pós restrições, para executar
                            apenas quando chamado por análise e para enviar para mesa de checagem ou esteira; Validação de
                            contingência movida para verificar antes de enviar dados para a mesa do ibratan.

               07/05/2018 - Criadas procedures para fazer a checagem se a cooperativa está utilizando a versão nova ou
                            a antiga do borderô - Luis Fernando (GFT)

               14/05/2018 - Criacao da procedure para trazer os titulos vencidos                              - Vitor Shimada Assanuma (GFT)
               16/05/2018 - Criacao das procedures de trazer o saldo e efetuar pagamento dos titulos vencidos - Vitor Shimada Assanuma (GFT)
               24/08/2018 - Adicionar novo histórico de credito para desconto de titulo pago a maior (vr_cdhistordsct_creddscttitpgm).
                            Este será usado na pc_pagar_titulo quando o valor pago do boleto for maior que o saldo restante. (Andrew Albuquerque (GFT))
               14/09/2018 - Passar a gravar a data de último pagamento realizado no borderô (Andrew Albuquerque (GFT))
               18/09/2018 - pc_pagar_titulo: Adicionar nova origem 4 - Acordos. Alterações na procedure para suprir esta origem. (Andrew Albuquerque (GFT))
               23/01/2019 - Ajuste na pc_lanca_credito_bordero (Daniel)
               11/02/2019 - Alteração para REJEITAR em outras situações diferente de Liberado e Liquidado - Cássia de Oliveira (GFT)
               15/05/2019 - Alteração para efetivar o Rating em pc_liberar_bordero_web - Mário (AMcom)
  ---------------------------------------------------------------------------------------------------------------*/
  -- Cursor genérico de calendário
  rw_crapdat btch0001.cr_crapdat%rowtype;

  -- Variáveis para armazenar as informações em XML
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

  --> verificar se existem criticas ou um critica em específico (pelo nrseqdig) para títulos daquele borderô.
  CURSOR cr_crapabt_qtde (pr_cdcooper IN crapabt.cdcooper%TYPE
                         ,pr_nrdconta IN crapabt.nrdconta%TYPE
                         ,pr_nrborder IN crapabt.nrborder%TYPE
                         ,pr_nrseqdig IN crapabt.nrseqdig%TYPE DEFAULT -1) IS
    select abt.cdcooper
          ,abt.nrdconta
          ,abt.nrborder
          ,count(dsrestri) as qtdrestri
      from crapabt abt --críticas do borderô
     where abt.cdcooper = pr_cdcooper
       and abt.nrdconta = pr_nrdconta
       and abt.nrborder = pr_nrborder
       and abt.nrseqdig = decode(pr_nrseqdig,-1,abt.nrseqdig,pr_nrseqdig)
    group by abt.cdcooper
            ,abt.nrdconta
            ,abt.nrborder;
  rw_crapabt_qtde cr_crapabt_qtde%ROWTYPE;

  --> Cursor para registros de Títulos do Borderô com Restrições ou com outras restrições que não sejam a 9 (CNAE)
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

      Objetivo  : Procedure para verificar se a esteira está em contingência

      Alteração : 28/04/2018 - Criação (Paulo Penteado (GFT))

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
      CLOSE cr_tbdsct_criticas;
      RETURN rw_tbdsct_criticas.dscritica;
    END IF;
    CLOSE cr_tbdsct_criticas;
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
    SELECT crapprm.dsvlrprm
      FROM crapprm
     WHERE crapprm.cdcooper = pr_cdcooper
       AND crapprm.cdacesso = 'FL_VIRADA_BORDERO';
    rw_crapprm cr_crapprm%ROWTYPE;

  BEGIN
    OPEN cr_crapprm;
    FETCH cr_crapprm INTO rw_crapprm;
    IF cr_crapprm%NOTFOUND THEN
      RETURN 0;
    END IF;
    RETURN rw_crapprm.dsvlrprm;
  END fn_virada_bordero;

  -- Verificar qual a versão do borderô
  FUNCTION fn_versao_bordero (pr_cdcooper IN crapcop.cdcooper%TYPE
                             ,pr_nrborder IN crapbdt.nrborder%TYPE
                             ) RETURN INTEGER IS
  /* .............................................................................
    Programa: fn_versao_bordero
    Sistema : AyllosWeb
    Sigla   : CRED
    Autor   : Vitor Shimada Assanuma (GFT)
    Data    : 30/07/2018                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Retorna se o borderô está na versão nova ou antiga.

  ............................................................................. */
  CURSOR cr_crapbdt IS
  SELECT flverbor
    FROM crapbdt
   WHERE crapbdt.cdcooper = pr_cdcooper
     AND crapbdt.nrborder = DECODE(pr_nrborder, 0, crapbdt.nrborder, pr_nrborder);
  rw_crapbdt cr_crapbdt%ROWTYPE;

  BEGIN
    OPEN cr_crapbdt;
    FETCH cr_crapbdt INTO rw_crapbdt;
    IF cr_crapbdt%NOTFOUND THEN
      RETURN 0;
    END IF;
    RETURN rw_crapbdt.flverbor;
  END fn_versao_bordero;

  FUNCTION fn_busca_situacao_bordero (pr_insitbdt crapbdt.insitbdt%TYPE) RETURN VARCHAR2 IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : fn_busca_situacao_bordero
    Sistema  : CRED
    Sigla    : DSCT0003
    Autor    : Luis Fernando (GFT)
    Data     : Abril/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Função que retorna a descrição dos status do borderô.
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
      Objetivo  : Função que retorna a descrição das decisoes do borderô.
    ---------------------------------------------------------------------------------------------------------------------*/
     BEGIN
       RETURN (
         CASE
           WHEN pr_insitapr=0 THEN 'Aguardando Análise'
           WHEN pr_insitapr=1 THEN 'Aguardando Checagem'
           WHEN pr_insitapr=2 THEN 'Checagem'
           WHEN pr_insitapr=3 THEN 'Aprovado Automaticamente'
           WHEN pr_insitapr=4 THEN 'Aprovado'
           WHEN pr_insitapr=5 THEN 'Não aprovado'
           WHEN pr_insitapr=6 THEN 'Enviado Esteira'
           WHEN pr_insitapr=7 THEN 'Prazo expirado'
         END
       );

   END fn_busca_decisao_bordero;

  FUNCTION fn_busca_situacao_titulo(pr_insittit craptdb.insittit%TYPE
                                   ,pr_flverbor crapbdt.flverbor%TYPE DEFAULT 0) RETURN VARCHAR2 IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : fn_busca_situacao_titulo
    Sistema  : CRED
    Sigla    : DSCT0003
    Autor    : Vitor Shimada Assanuma (GFT)
    Data     : Agosto/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Função que retorna a descrição da situação do título

    Alteração : 19/09/2018 - Adicionado parametro pr_flverbor (Paulo Penteado (GFT))
  ---------------------------------------------------------------------------------------------------------------------*/
   BEGIN
     RETURN (
       CASE
         WHEN pr_insittit=0 THEN
           CASE WHEN nvl(pr_flverbor,0) = 0 THEN 'Não processado'
                ELSE 'Pendente'
           END
         WHEN pr_insittit=1 THEN 'Resgatado'
         WHEN pr_insittit=2 THEN
           CASE WHEN nvl(pr_flverbor,0) = 0 THEN 'Processado'
                ELSE 'Pago'
           END
         WHEN pr_insittit=3 THEN 'Pago após vencimento'
         WHEN pr_insittit=4 THEN 'Liberado'
       END
     );
  END fn_busca_situacao_titulo;

  FUNCTION fn_calcula_cnae(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa conectada
                          ,pr_nrdconta IN crapass.nrdconta%TYPE   --> Conta do associado
                          ,pr_nrdocmto IN crapcob.nrdocmto%TYPE   --> Numero do documento(Boleto)
                          ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE   --> Numero do convenio de cobranca.
                          ,pr_nrdctabb IN crapcob.nrdctabb%TYPE   --> Numero da conta base no banco.
                          ,pr_cdbandoc IN crapcob.cdbandoc%TYPE   --> Codigo do banco/caixa.
           )RETURN BOOLEAN IS           --> Retonar True ou False se tem ou nao restrição CNAE
    /* .............................................................................
      Programa: fn_calcula_cnae
      Sistema : AyllosWeb
      Sigla   : CRED
      Autor   : Vitor Shimada Assanuma (GFT)
      Data    : 03/05/2018                        Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Calculo de verificação do CNAE por titulo
      Alterações: 24/05/2018 - Vitor Shimada Assanuma (GFT) - Inclusão da verificação da #TAB052 se o CNAE está ativo

    ............................................................................. */
     -- Variável de críticas
     vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
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
     SELECT vlmaximo,
            inpessoa
       FROM crapass ass
      INNER JOIN tbdsct_cdnae cnae
         ON cnae.cdcooper = ass.cdcooper
        AND cnae.cdcnae = ass.cdclcnae
      WHERE cnae.vlmaximo > 0
        AND ass.cdcooper = pr_cdcooper
        AND ass.nrdconta = pr_nrdconta;
     rw_crapass cr_crapass%ROWTYPE;

     --Tab052
     pr_tab_dados_dsctit dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052
     pr_tab_cecred_dsctit dsct0002.typ_tab_cecred_dsctit; -- retorno da TAB052

     BEGIN
       --    Leitura do calendário da cooperativa
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
                                         null, --Agencia de operação
                                         null, --Número do caixa
                                         null, --Operador
                                         rw_crapdat.dtmvtolt, -- Data da Movimentação
                                         null, --Identificação de origem
                                         1, --pr_tpcobran: 1-REGISTRADA / 0-NÃO REGISTRADA
                                         rw_crapass.inpessoa, --1-PESSOA FÍSICA / 2-PESSOA JURÍDICA
                                         pr_tab_dados_dsctit,
                                         pr_tab_cecred_dsctit,
                                         vr_cdcritic,
                                         vr_dscritic);

       --Caso o valor do titulo seja maior que o valor maximo do CNAE retorna TRUE e Esteja ativo a opção de verificar CNAE
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
                                     ,pr_qtmitdcl     IN INTEGER
                                     ,pr_vlmintcl     IN NUMBER
          ) RETURN NUMBER IS
   /*---------------------------------------------------------------------------------------------------------------------
     Programa : fn_calcula_liquidez_geral
     Sistema  :
     Sigla    : CRED
     Autor    : Vitor Shimada Assanuma (GFT)
     Data     : Maio/2018
     Frequencia: Sempre que for chamado
     Objetivo  : Cálculo da Liquidez Geral
     Alteracao :
               24/01/2019 - Trocada para nova funcao de liquidez geral - Luis Fernando (GFT)
   ---------------------------------------------------------------------------------------------------------------------*/
   /* Calculo da Liquidez:
    Soma do Valor de todos os titulos nao pagos dividido pela soma de todos os titulos daquele emitente (nrdconta)
           dentro de um periodo de tempo da liquidez (Dt.Mov - Dias de Liquidez ATE Dt.Mov) levando em conta os dias de
           carencia na data de vencimento.
    (Não considerar como título pago, os liquidados em conta corrente do cedente, ou seja, pagos pelo próprio emitente) */
   -- Variaveis de retorno
   pr_pc_geral     NUMBER(25,2);
   pr_qtd_geral    NUMBER;

   BEGIN
     pc_calcula_liquidez_geral(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_dtmvtolt_de => pr_dtmvtolt_de
                     ,pr_dtmvtolt_ate => pr_dtmvtolt_ate
                     ,pr_qtcarpag => pr_qtcarpag
                     ,pr_qtmitdcl => pr_qtmitdcl
                     ,pr_vlmintcl => pr_vlmintcl
                    -- OUT --
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
                                          ,pr_qtmitdcl     IN INTEGER
                                          ,pr_vlmintcl     IN NUMBER
                                       ) RETURN NUMBER IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : fn_concentracao_titulo_pagador
    Sistema  : CRED
    Sigla    : CRED
    Autor    : Vitor Shimada Assanuma (GFT)
    Data     : Maio/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Função que retorna a porcentagem de concentracao de titulos daquele pagador em um range de data de liquidez
     Alteracao :
               24/01/2019 - Trocada para nova funcao de concentracao - Luis Fernando (GFT)
  ---------------------------------------------------------------------------------------------------------------------*/
   -- Variaveis de retorno
   pr_pc_conc      NUMBER(25,2);
   pr_qtd_conc     NUMBER;

   BEGIN
     pc_calcula_concentracao(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrinssac => pr_nrinssac
                     ,pr_dtmvtolt_de => pr_dtmvtolt_de
                     ,pr_dtmvtolt_ate => pr_dtmvtolt_ate
                     ,pr_qtcarpag => pr_qtcarpag
                     ,pr_qtmitdcl => pr_qtmitdcl
                     ,pr_vlmintcl => pr_vlmintcl
                    -- OUT --
                    ,pr_pc_conc      => pr_pc_conc
                    ,pr_qtd_conc     => pr_qtd_conc
                    );
     RETURN pr_pc_conc;
   END fn_concentracao_titulo_pagador;


   FUNCTION fn_liquidez_pagador_cedente (pr_cdcooper     IN craptdb.cdcooper%TYPE
                                        ,pr_nrdconta     IN craptdb.nrdconta%TYPE
                                        ,pr_nrinssac     IN crapcob.nrinssac%TYPE
                                        ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE
                                        ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                                        ,pr_qtcarpag     IN NUMBER
                                        ,pr_qtmitdcl     IN INTEGER
                                        ,pr_vlmintcl     IN NUMBER
                                        ) RETURN NUMBER IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : fn_liquidez_pagador_cedente
    Sistema  : CRED
    Sigla    : CRED
    Autor    : Vitor Shimada Assanuma (GFT)
    Data     : Maio/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Função que retorna a porcentagem de liquidez do pagador contra o cedente no range de data
     Alteracao :
               24/01/2019 - Trocada para nova funcao de liquidez geral - Luis Fernando (GFT)
  ---------------------------------------------------------------------------------------------------------------------*/
   /* CÁLCULO DA CONCENTRACAO DO PAGADOR
    Soma do Valor de todos os titulos nao pagos dividido pela soma de todos os titulos daquele emitente (nrdconta)
       CONTRA aquele pagador (nrinssac) dentro de um periodo de tempo da liquidez (Dt.Mov - Dias de Liquidez ATE Dt.Mov)
       levando em conta os dias de carencia na data de vencimento.
    (Não considerar como título pago, os liquidados em conta corrente do cedente, ou seja, pagos pelo próprio emitente) */
    -- Variaveis de retorno
   pr_pc_cedpag    NUMBER(25,2);
   pr_qtd_cedpag   NUMBER;

   BEGIN
     pc_calcula_liquidez_pagador(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrinssac => pr_nrinssac
                     ,pr_dtmvtolt_de => pr_dtmvtolt_de
                     ,pr_dtmvtolt_ate => pr_dtmvtolt_ate
                     ,pr_qtcarpag => pr_qtcarpag
                     ,pr_qtmitdcl => pr_qtmitdcl
                     ,pr_vlmintcl => pr_vlmintcl
                    -- OUT --
                    ,pr_pc_cedpag    => pr_pc_cedpag
                    ,pr_qtd_cedpag   => pr_qtd_cedpag
                    );
     RETURN pr_pc_cedpag;
   END fn_liquidez_pagador_cedente;

  FUNCTION fn_cobranca_cobtit(pr_cdcooper IN crapbdt.cdcooper%TYPE --> Código da Cooperativa
                             ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                             ) RETURN BOOLEAN IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : fn_cobranca_cobtit
      Sistema  : Ayllos
      Sigla    : DSTC
      Autor    : Paulo Penteado (GFT)
      Data     : Junho/2018

      Objetivo  : Retornar se a cobrança foi realizada pela COBTIT. Para isso compara se o número do convênio do
                  título é igual ao número do convenio registrado no parâmetro.

      Alteração : 10/06/2018 - Criação (Paulo Penteado (GFT))

    ----------------------------------------------------------------------------------------------------------*/
    vr_nrcnvcob crapcob.nrcnvcob%TYPE;
  BEGIN
    vr_nrcnvcob := gene0001.fn_param_sistema(pr_cdcooper => pr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_cdacesso => 'COBTIT_NRCONVEN');
    RETURN (pr_nrcnvcob = vr_nrcnvcob);
  END fn_cobranca_cobtit;

  -- Rotina para escrever texto na variável CLOB do XML
  PROCEDURE pc_escreve_xml( pr_des_dados in varchar2
                          , pr_fecha_xml in boolean default false
                          ) is
  BEGIN
     gene0002.pc_escreve_xml( vr_des_xml
                            , vr_texto_completo
                            , pr_des_dados
                            , pr_fecha_xml );
  END pc_escreve_xml;

  FUNCTION fn_retorna_rating(pr_dsinrisc NUMBER) RETURN VARCHAR2 IS
    BEGIN
      /*
      A -> normal ou até atrasar 14 dias
      B -> atraso de 15 a 30 dias
      C -> atraso de 31 a 60 dias
      D -> atraso de 61 a 90 dias
      E -> atraso de 91 a 120 dias
      F -> atraso de 121 a 150 dias
      G -> atraso de 151 a 180 dias
      H -> atraso de 180 dias
      HH -> Prejuizo
      */
      RETURN CASE pr_dsinrisc
                  WHEN 2 THEN 'A'
                  WHEN 3 THEN 'B'
                  WHEN 4 THEN 'C'
                  WHEN 5 THEN 'D'
                  WHEN 6 THEN 'E'
                  WHEN 7 THEN 'F'
                  WHEN 8 THEN 'G'
                  WHEN 9 THEN 'H'
                  ELSE 'HH'
             END;
  END fn_retorna_rating;

  FUNCTION fn_spc_serasa (pr_cdcooper crapcbd.cdcooper%TYPE, pr_nrdconta crapcbd.nrdconta%TYPE, pr_nrcpfcgc crapcbd.nrcpfcgc%TYPE) RETURN VARCHAR2 IS

    /*---------------------------------------------------------------------------------------------------------
      Programa : fn_spc_serasa
      Sistema  : Ayllos
      Sigla    : DSTC
      Autor    : Luis Fernando (GFT)
      Data     : Novembro/2018

      Objetivo  : Retorna se um pagador está com algum alerta em spc/serasa
    ----------------------------------------------------------------------------------------------------------*/
    CURSOR cr_crapcbd IS
      SELECT crapcbd.nrconbir,
             crapcbd.nrseqdet
        FROM crapcbd
       WHERE crapcbd.cdcooper = pr_cdcooper
         AND crapcbd.nrdconta = pr_nrdconta
         AND crapcbd.nrcpfcgc = pr_nrcpfcgc
         AND crapcbd.inreterr = 0  -- Nao houve erros
       ORDER BY crapcbd.dtconbir DESC; -- Buscar a consuilta mais recente
    rw_crapcbd  cr_crapcbd%rowtype;

    -- Variaveis para verificar criticas e situacao
    vr_ibratan char(1);
    --vr_situacao char(1);
    --vr_nrinssac crapcob.nrinssac%TYPE;
    vr_cdbircon crapbir.cdbircon%TYPE;
    vr_dsbircon crapbir.dsbircon%TYPE;
    vr_cdmodbir crapmbr.cdmodbir%TYPE;
    vr_dsmodbir crapmbr.dsmodbir%TYPE;

    BEGIN
      OPEN cr_crapcbd;
      FETCH cr_crapcbd into rw_crapcbd;
      IF (cr_crapcbd%NOTFOUND) THEN
       CLOSE cr_crapcbd;
       vr_ibratan := 'A';
      ELSE
        --vr_ibratan = S se tiver restricao, N se nao tiver
        SSPC0001.pc_verifica_situacao(rw_crapcbd.nrconbir,rw_crapcbd.nrseqdet,vr_cdbircon,vr_dsbircon,vr_cdmodbir,vr_dsmodbir,vr_ibratan);
      END IF;
      RETURN vr_ibratan;
  END fn_spc_serasa;

  /*Procedure que altera os status de um borderô*/
  PROCEDURE pc_altera_status_bordero(pr_cdcooper IN crapbdt.cdcooper%TYPE --> Código da Cooperativa
                                    ,pr_nrborder IN crapbdt.nrborder%TYPE --> Número do Borderô
                                    ,pr_nrdconta IN crapbdt.nrdconta%TYPE --> Número da conta do cooperado
                                    ,pr_status   IN crapbdt.insitbdt%TYPE DEFAULT -1 --> Situação nova do borderô
                                    ,pr_insitapr IN crapbdt.insitapr%TYPE DEFAULT -1   -- Situação da aprovação
                                    ,pr_cdopeapr IN crapbdt.cdopeapr%TYPE DEFAULT NULL -- cdoperad que efetuou a aprovação
                                    ,pr_dtaprova IN crapbdt.dtaprova%TYPE DEFAULT NULL -- data de aprovação
                                    ,pr_hraprova IN crapbdt.hraprova%TYPE DEFAULT NULL -- hora de aprovação
                                    ,pr_dtenvmch IN crapbdt.dtaprova%TYPE DEFAULT NULL -- data de envio para mesa de checagem
                                    ,pr_cdoperej IN crapbdt.cdoperej%TYPE DEFAULT NULL -- cdoperad que efetuou a rejeição
                                    ,pr_dtrejeit IN crapbdt.dtrejeit%TYPE DEFAULT NULL -- data de rejeição
                                    ,pr_hrrejeit IN crapbdt.hrrejeit%TYPE DEFAULT NULL -- hora de rejeião
                                    ,pr_dtanabor IN crapbdt.dtanabor%TYPE DEFAULT NULL -- data de analise
                                    ,pr_cdoperad IN crapbdt.cdoperad%TYPE DEFAULT NULL -- operador
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
            ,crapbdt.cdoperad = nvl(pr_cdoperad,crapbdt.cdoperad)
       WHERE crapbdt.cdcooper = pr_cdcooper
         AND crapbdt.nrborder = pr_nrborder
         AND crapbdt.nrdconta = pr_nrdconta;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao alterar o registro na crapbdt: '|| sqlerrm;
    END;
  END pc_altera_status_bordero;


PROCEDURE pc_atualizar_bordero_dsct_tit(pr_cdcooper  IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                       ,pr_nrborder  IN crapbdt.nrborder%TYPE --> numero do bordero
                                       ,pr_dtmvtolt  IN craplcm.dtmvtolt%TYPE --> Data do movimento atual
                                       ,pr_cdoperad  IN craptdb.cdoperad%TYPE --> Operador
                                       ,pr_cdagenci  IN crapass.cdagenci%TYPE --> Código da Agência
                                       ,pr_vltaxiof  IN crapbdt.vltaxiof%TYPE DEFAULT NULL --> Valor da taxa de IOF complementar
                                       ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                       ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_atualizar_bordero
    Sistema  : CRED
    Sigla    : DSCT0003
    Autor    : Paulo Penteado (GFT)
    Data     : Maio/2018

    Objetivo  : Atualizar informações do borderô

    Alteração : 24/05/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
  vr_vltxmult_prm crapbdt.vltxmult%TYPE;

  -- Variável de críticas
  vr_dscritic VARCHAR2(10000);

  vr_contas crapprm.dsvlrprm%TYPE;

  -- Tratamento de erros
  vr_exc_erro EXCEPTION;

  CURSOR cr_craplim IS
  SELECT lim.cddlinha,
         ldc.txjurmor
    FROM crapldc ldc,
         craplim lim,
         crapbdt bdt
   WHERE ldc.tpdescto = 3
     AND ldc.cddlinha = lim.cddlinha
     AND ldc.cdcooper = lim.cdcooper
     AND lim.insitlim = 2
     AND lim.tpctrlim = 3
     AND lim.nrctrlim = bdt.nrctrlim
     AND lim.nrdconta = bdt.nrdconta
     AND lim.cdcooper = bdt.cdcooper
     AND bdt.nrborder = pr_nrborder
     AND bdt.cdcooper = pr_cdcooper;
  rw_craplim cr_craplim%ROWTYPE;

BEGIN

  GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'COBR0007.pc_atualizar_bordero_dsct_tit');

  -- Busca Taxa
  OPEN  cr_craplim;
  FETCH cr_craplim INTO rw_craplim;
  CLOSE cr_craplim;

  vr_vltxmult_prm := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_cdacesso => 'PERCENTUAL_MULTA_DSCT');


  IF gene0001.fn_param_sistema('CRED',pr_cdcooper,'ZERAR_MULTA_DSCT') IS NOT NULL THEN

    vr_contas := gene0001.fn_param_sistema('CRED',pr_cdcooper,'ZERAR_MULTA_DSCT');

    -- Condicao para verificar se deve zerar multa
    IF ((INSTR(',' || vr_contas || ',',',' || pr_nrdconta || ',') > 0)) THEN
      vr_vltxmult_prm := 0;
    END IF;

  END IF;


  -- Altera o status do borderô para 'LIBERADO'
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
         vr_dscritic := 'Erro ao atualizar as informações do borderô '||pr_nrborder||': '||SQLERRM;
         RAISE vr_exc_erro;
  END;
EXCEPTION
  WHEN vr_exc_erro THEN
       pr_dscritic := vr_dscritic;

  WHEN OTHERS THEN
    CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
       pr_dscritic := 'Erro geral na rotina dsct0003.pc_atualizar_bordero_dsct_tit: '||SQLERRM;

END pc_atualizar_bordero_dsct_tit;


PROCEDURE pc_inserir_lancamento_bordero(pr_cdcooper  IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
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
                                       ,pr_dscritic OUT VARCHAR2                                          --> Descrição da crítica
                                       ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_inserir_lancamento_bordero
    Sistema  : CRED
    Sigla    : DSCT0003
    Autor    : Paulo Penteado (GFT)
    Data     : Maio/2018

    Objetivo  : Inserir registros de lancamento do borderô na tabela tbdsct_lancamento_bordero

    Alteração : 24/05/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
  vr_nrseqdig tbdsct_lancamento_bordero.nrseqdig%TYPE;

  -- Variável de críticas
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
    IF round(pr_vllanmto,2) > 0 THEN
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
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
         vr_dscritic := 'Erro ao inserir o lançamento de borderô: '||SQLERRM;
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


  PROCEDURE pc_valida_bordero (pr_cdcooper IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                               ,pr_nrborder IN crapbdt.nrborder%TYPE --> Número do Bordero
                               ,pr_cddeacao IN VARCHAR2
                               ,pr_dscritic OUT VARCHAR2             --> Descriçao da crítica
                               ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_valida_bordero
    Sistema  : Cred
    Sigla    :
    Autor    : Lucas Lazari (GFT)
    Data     : Abril/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Procedure que realiza validações básicas do borderô para as rotinas de análise e liberação do borderô

    Alteração : 11/02/2019 - Alteração para REJEITAR em outras situações diferente de Liberado e Liquidado - Cássia de Oliveira (GFT)
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
         ,crapbdt.inprejuz
         ,crapbdt.dtliqprj
   FROM   crapbdt
   WHERE  crapbdt.cdcooper = pr_cdcooper
   AND    crapbdt.nrborder = pr_nrborder;
   rw_crapbdt cr_crapbdt%ROWTYPE;

  BEGIN
     OPEN  cr_crapbdt;
     FETCH cr_crapbdt INTO rw_crapbdt;
     IF    cr_crapbdt%NOTFOUND THEN
           CLOSE cr_crapbdt;
           vr_dscritic:= 'Registro de Borderô Não Encontrado.';
           RAISE vr_exc_erro;
     ELSE
           /* Situacao do Borderô (insitbdt):
                 1-Em Estudo, 2-Analisado, 3-Liberado, 4-Liquidado, 5-Rejeitado'
              Situação da Decisão/Aprovação (insitapr):
                 0-Aguardando Análise, 1-Aguardando Checagem, 2-Checagem, 3-Aprovado Automaticamente,
                 4-Aprovado, 5-Não aprovado, 6-Enviado Esteira, 7-Prazo expirado' */

           IF    pr_cddeacao = 'LIBERAR'  THEN
                 IF  rw_crapbdt.insitbdt <> 2 OR (rw_crapbdt.insitapr NOT IN (3,4)) THEN
                     -- Caso nao tenha sido feito a analise
                     IF rw_crapbdt.dtanabor IS NULL THEN
                         vr_dscritic := 'Liberação não permitida. O Borderô deve ser analisado antes de liberar.';
                         CLOSE cr_crapbdt;
                         RAISE vr_exc_erro;
                     ELSE
                     --  verifica se a esteira está em contingencia
                     IF  fn_contigencia_esteira(pr_cdcooper) THEN
                         IF  rw_crapbdt.insitbdt <> 1 OR rw_crapbdt.insitapr <> 0 THEN
                             vr_dscritic := 'Liberação não permitida. O Borderô deve estar na situação EM ESTUDO e decisão AGUARDANDO ANÁLISE.';
                             CLOSE cr_crapbdt;
                             RAISE vr_exc_erro;
                         END IF;
                     ELSE
                       vr_dscritic := 'Liberação não permitida. O Borderô deve estar na situação ANALISADO e decisão APROVADO AUTOMATICAMENTO OU APROVADO.';
                       CLOSE cr_crapbdt;
                       RAISE vr_exc_erro;
                     END IF;
                 END IF;
                 END IF;

           ELSIF pr_cddeacao = 'ANALISAR' THEN
                 IF  rw_crapbdt.insitbdt > 2 OR (rw_crapbdt.insitapr IN (2,6,7)) THEN
                     vr_dscritic := 'Análise não permitida. O Borderô deve estar na situação EM ESTUDO ou ANALISADO.';
                     CLOSE cr_crapbdt;
                     RAISE vr_exc_erro;
                 END IF;

           ELSIF pr_cddeacao = 'REJEITAR' THEN
             IF (fn_contigencia_esteira(pr_cdcooper)) THEN
               IF (rw_crapbdt.insitbdt NOT IN (1, 2)) THEN
                   vr_dscritic := 'Rejeição não permitida. O Borderô deve estar com a situação EM ESTUDO ou ANALISADO.';
                   CLOSE cr_crapbdt;
                   RAISE vr_exc_erro;
               END IF;
             END IF;
           ELSIF pr_cddeacao = 'PREJUIZO' THEN
             IF rw_crapbdt.inprejuz <> 1 THEN
                vr_dscritic := 'O Borderô não está em Prejuizo.';
                CLOSE cr_crapbdt;
                RAISE vr_exc_erro;
             /*ELSIF   rw_crapbdt.dtliqprj IS NOT NULL THEN
               vr_dscritic := 'O Borderô já está Liquidado.';
               CLOSE cr_crapbdt;
               RAISE vr_exc_erro;*/
             END IF;
           ELSE
                 vr_dscritic := 'Opção inválida informada para o parâmetro pr_cddeacao da dsct0003.pc_valida_bordero';
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

  PROCEDURE pc_calcula_juros_simples_tit(pr_cdcooper  IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                        ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                        ,pr_nrborder  IN crapbdt.nrborder%TYPE --> numero do bordero
                                        ,pr_cdbandoc  IN craptdb.cdbandoc%TYPE --> Codigo do banco impresso no boleto
                                        ,pr_nrdctabb  IN craptdb.nrdctabb%TYPE --> Numero da conta base do titulo
                                        ,pr_nrcnvcob  IN craptdb.nrcnvcob%TYPE --> Numero do convenio de cobranca
                                        ,pr_nrdocmto  IN craptdb.nrdocmto%TYPE --> Numero do documento
                                        ,pr_vltitulo  IN craptdb.vltitulo%TYPE --> Valor do titulo
                                        ,pr_dtvencto  IN craptdb.dtvencto%TYPE --> Data vencimento titulo
                                        ,pr_dtmvtolt  IN craplcm.dtmvtolt%TYPE --> Data do movimento atual
                                        ,pr_txmensal  IN crapbdt.txmensal%TYPE --> Taxa mensal
                                        ,pr_flresgat  IN BOOLEAN DEFAULT FALSE --> Define se a rotina está sendo rodada para resgate
                                        ,pr_vldjuros OUT crapljt.vldjuros%TYPE --> Valor do juros calculado
                                        ,pr_dtrefere OUT DATE                  --> Data de referencia da atualizacao dos juros
                                        ,pr_dscritic OUT VARCHAR2              --> Descrição da critica
                                        ) IS
    /*---------------------------------------------------------------------------------------------------------------------
      Programa : pc_calcula_juros_simples_tit
      Sistema  : CRED
      Sigla    : DSCT0003
      Autor    : Fernando Sacchi(GFT) / Paulo Penteado (GFT)
      Data     : Maio/2018

      Objetivo  : Calcula o juros do título do borderô para o dia

      Alteração : 25/05/2018 - Criação (Fernando Sacchi(GFT) / Paulo Penteado (GFT))
                  15/08/2018 - Corrigido lancamento da ltj e refeita a formula de calculo - Luis Fernando (GFT)
    ---------------------------------------------------------------------------------------------------------------------*/
    vr_dia      INTEGER;
    vr_qtd_dias NUMBER;
    vr_dtrefere DATE;
    vr_dtcalcul DATE;
    vr_vldjuros crapljt.vldjuros%TYPE;
    vr_jurosdia NUMBER;
    -- Variável de críticas
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
    AND    crapljt.cdcooper = pr_cdcooper
    AND    crapljt.nrborder = pr_nrborder;
    rw_crapljt cr_crapljt%rowtype;

  BEGIN
    IF  pr_dtmvtolt > pr_dtvencto THEN
        vr_qtd_dias := ccet0001.fn_diff_datas(pr_dtvencto, pr_dtmvtolt);
    ELSE
        vr_qtd_dias := pr_dtvencto -  pr_dtmvtolt;
    END IF;

    --  Percorre a quantidade de dias baseado na data atual até o vencimento do título
    vr_vldjuros := 0;
    pr_vldjuros := 0;
    vr_dtrefere := last_day(pr_dtmvtolt);
    vr_dtcalcul := pr_dtmvtolt;
    vr_jurosdia := ((pr_txmensal / 100) / 30);

--    vr_qtd_dias := pr_dtmvtolt - pr_dtvencto;

    WHILE (vr_qtd_dias > 0) LOOP
      vr_dtcalcul := vr_dtcalcul+1;
      vr_dtrefere := last_day(vr_dtcalcul);
      IF (vr_dtcalcul+vr_qtd_dias) > vr_dtrefere THEN             -- se a ultima data calculada + os dias restantes de juros são maior que a data de referencia
        vr_dia := vr_dtrefere - (vr_dtcalcul-1);                      -- calcula quantos dias terão juros naquele mes
        vr_dtcalcul := vr_dtrefere;                             -- coloca o proximo dia de calculo de juros para o proximo dia da referencia
        vr_qtd_dias := vr_qtd_dias - vr_dia;                       -- tira quantos dias de juros foram calculados do total
      ELSE
        vr_dia := vr_qtd_dias;                                    --
        vr_dtcalcul := vr_dtrefere;
        vr_qtd_dias := 0;
      END IF;

      vr_vldjuros := apli0001.fn_round(pr_vltitulo * vr_dia * vr_jurosdia,2);        -- calcula o juros em cima dos dias

        BEGIN
          OPEN  cr_crapljt(vr_dtrefere);
          FETCH cr_crapljt INTO rw_crapljt;
          --    Se já foi lançado juros para este período, atualiza a tabela de lançamento de juros
          IF    cr_crapljt%FOUND THEN
              IF (pr_flresgat) THEN
                UPDATE crapljt
                SET    crapljt.vlrestit = vr_vldjuros,
                       crapljt.vldjuros = crapljt.vldjuros-vr_vldjuros
                WHERE  crapljt.rowid=rw_crapljt.rowid;
              ELSE
                UPDATE crapljt
                SET    crapljt.vldjuros = vr_vldjuros
                WHERE  crapljt.rowid=rw_crapljt.rowid;
              END IF;

          --    Caso contrário, insere novo registro
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
                     ,/*09*/ vldjuros
                     ,/*10*/ dtmvtolt)
                VALUES (/*01*/ pr_cdcooper
                       ,/*02*/ pr_nrdconta
                       ,/*03*/ pr_nrborder
                       ,/*04*/ vr_dtrefere
                       ,/*05*/ pr_cdbandoc
                       ,/*06*/ pr_nrdctabb
                       ,/*07*/ pr_nrcnvcob
                       ,/*08*/ pr_nrdocmto
                     ,/*09*/ vr_vldjuros
                     ,/*10*/ pr_dtmvtolt );
          END   IF;
          CLOSE cr_crapljt;
        pr_vldjuros := pr_vldjuros + vr_vldjuros;
        EXCEPTION
          WHEN OTHERS THEN
               vr_dscritic := 'Erro ao atualizar os juros calculado do título do borderô: '||SQLERRM;
               RAISE vr_exc_erro;
        END;
    END LOOP;

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
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                       ,pr_vltotliq OUT NUMBER
                                       ,pr_vltotbrt OUT NUMBER
                                       ,pr_vltotjur OUT NUMBER
                                       ,pr_cdcritic OUT PLS_INTEGER
                                       ,pr_dscritic OUT VARCHAR
                                       ) IS

   /*-------------------------------------------------------------------------------------------------------
     Programa : pc_calcula_valores_bordero        Antigo: b1wgen0030.p/efetua_liber_anali_bordero (Trecho de Liberação)
     Sistema  :
     Sigla    : CRED
     Autor    : Lucas Lazari (GFT)
     Data     : Abril/2018

     Objetivo  : Procedure para calcular os valores líquido e bruto do borderô, bem como realizar o lançamento dos juros

     Alteracoes: 16/04/2018 - Criação (Lucas Lazari (GFT))
                 06/06/2018 - Liberacao parcial do bordero, liberando apenas aqueles aprovados ou quando em
                              contingencia, aprovados e nao analisados.
   ----------------------------------------------------------------------------------------------------------*/

    -- Variáveis Locais
    vr_vldjuros  number;
    vr_vltotliq number;
    vr_vltotbrt number;
    vr_vltotjur NUMBER;
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
         AND (craptdb.insitapr = 1 OR (craptdb.insitapr = 0 AND pr_contingencia = 1));
    rw_base_calculo cr_base_calculo%ROWTYPE;

    --Selecionar informacoes do titulo
    CURSOR cr_crapcob (pr_cdcooper IN crapcob.cdcooper%TYPE
                      ,pr_cdbandoc IN crapcob.cdbandoc%TYPE
                      ,pr_nrdctabb IN crapcob.nrdctabb%TYPE
                      ,pr_nrdconta IN crapcob.nrdconta%type
                      ,pr_nrcnvcob IN crapcob.nrcnvcob%type
                      ,pr_nrdocmto IN crapcob.nrdocmto%type
                      ,pr_flgregis IN crapcob.flgregis%type) IS
    SELECT crapcob.cdbandoc,
           crapcob.cdcooper,
           crapcob.nrcnvcob,
           crapcob.nrdconta,
           crapcob.nrdocmto,
           crapcob.incobran,
           crapcob.dtretcob,
           crapcob.ROWID
      FROM crapcob
     WHERE crapcob.cdcooper = pr_cdcooper
       AND crapcob.cdbandoc = pr_cdbandoc
       AND crapcob.nrdctabb = pr_nrdctabb
       AND crapcob.nrdconta = pr_nrdconta
       AND crapcob.nrcnvcob = pr_nrcnvcob
       AND crapcob.nrdocmto = pr_nrdocmto
       AND crapcob.flgregis = pr_flgregis;
    rw_crapcob cr_crapcob%ROWTYPE;

    CURSOR cr_crapbdt IS
      SELECT crapbdt.txmensal
        FROM crapbdt
       WHERE crapbdt.nrborder = pr_nrborder
         AND crapbdt.cdcooper = pr_cdcooper
         AND crapbdt.nrdconta = pr_nrdconta;
    rw_crapbdt cr_crapbdt%rowtype;

    vr_contingencia INTEGER;

    BEGIN

      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'DSCT0003.pc_calcula_valores_bordero');

      vr_contingencia := 0;

      open cr_crapbdt;
      fetch cr_crapbdt into rw_crapbdt;
      CLOSE cr_crapbdt;

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
                        ,pr_dtmvtolt => pr_dtmvtolt
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
                                    ,pr_dtmvtolt => pr_dtmvtolt
                                    ,pr_txmensal => rw_crapbdt.txmensal
                                    ,pr_vldjuros => vr_vldjuros
                                    ,pr_dtrefere => vr_dtrefere
                                    ,pr_dscritic => vr_dscritic );

        -- Aproveita o loop do cursor de títulos do borderô para atualizar as informações no banco
        UPDATE craptdb
        SET    craptdb.vlliquid = ROUND((rw_base_calculo.vltitulo - vr_vldjuros),2),
               craptdb.dtlibbdt = pr_dtmvtolt,
               craptdb.insittit = 4,
               craptdb.insitapr = 1,
               craptdb.vlsldtit = rw_base_calculo.vltitulo
        WHERE  craptdb.rowid = rw_base_calculo.rowid;

        -- Busca o registro do título na crapcob
        OPEN cr_crapcob (pr_cdcooper => pr_cdcooper
                        ,pr_cdbandoc => rw_base_calculo.cdbandoc
                        ,pr_nrdctabb => rw_base_calculo.nrdctabb
                        ,pr_nrdconta => rw_base_calculo.nrdconta
                        ,pr_nrcnvcob => rw_base_calculo.nrcnvcob
                        ,pr_nrdocmto => rw_base_calculo.nrdocmto
                        ,pr_flgregis => 1);
        FETCH cr_crapcob INTO rw_crapcob;

        IF cr_crapcob%FOUND THEN
          CLOSE cr_crapcob;
          -- Registra log de cobrança para o títulos
          PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_dsmensag => 'Boleto Descontado - Bordero ' || pr_nrborder
                                       ,pr_des_erro => vr_des_erro
                                       ,pr_dscritic => vr_dscritic);

          IF vr_des_erro = 'NOK' THEN
            RAISE vr_exc_erro;
          END IF;
        ELSE
          CLOSE cr_crapcob;
          vr_dscritic := 'Título não encontrado';
          RAISE vr_exc_erro;
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

         CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

         pr_cdcritic := 0;
         pr_dscritic := 'Erro geral na rotina dsct0003.pc_calcula_valores_bordero: '||SQLERRM;

  END pc_calcula_valores_bordero;


  PROCEDURE pc_calcula_iof_bordero(pr_cdcooper IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE --> Número do Bordero
                                  ,pr_nrdconta IN craptdb.nrdconta%TYPE --> Número da Conta
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                  ,pr_vltotliq IN NUMBER                --> Valor total líquido do borderô
                                  --------> OUT <--------
                                  ,pr_flgimune OUT PLS_INTEGER           --> Possui imunidade tributária
                                  ,pr_vltotiofpri OUT NUMBER            --> Valor total IOF Principal
                                  ,pr_vltotiofadi OUT NUMBER            --> Valor total IOF Adicional
                                  ,pr_vltotiofcpl OUT NUMBER            --> Valor total IOF Complementar
                                  ,pr_vltxiofatra OUT NUMBER            --> Valor total IOF Atraso
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descriçao da crítica
                                   ) is
   /*-------------------------------------------------------------------------------------------------------
     Programa : pc_calcula_iof_bordero        Antigo: b1wgen0030.p/efetua_liber_anali_bordero (Trecho de Liberação)
     Sistema  :
     Sigla    : CRED
     Autor    : Lucas Lazari (GFT)
     Data     : Abril/2018

     Objetivo  : Procedure para calcular o IOF sobre o borderô de desconto de Tìtulo

     Alteracoes: 16/04/2018 - Criação (Lucas Lazari (GFT))
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
     SELECT crapjur.natjurid,
            crapjur.tpregtrb
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

    -- busca os dados do associado/cooperado para só então encontrar seus dados na tabela de parâmetros
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    CLOSE cr_crapass;

    -- Busca dados de pessoa jurídica
    OPEN cr_crapjur(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapjur INTO rw_crapjur;
    CLOSE cr_crapjur;

    -- Percorre todos os títulos do borderô para realizar o cálculo do IOF
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
        SET    vliofprc  = vr_vliofpri
              ,vliofadc  = vr_vliofadi
        WHERE  tdb.rowid = rw_craptdb.rowid;
      EXCEPTION
        WHEN OTHERS THEN
             vr_dscritic := 'Erro ao atualizar os valores de IOF do título do borderô: '||SQLERRM;
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

  PROCEDURE pc_lanca_iof_bordero (pr_cdcooper IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                 ,pr_cdagenci IN crapass.cdagenci%type --> Código da Agência
                                 ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                                 ,pr_nrborder IN crapbdt.nrborder%TYPE --> Número do Bordero
                                 ,pr_nrdconta IN craptdb.nrdconta%TYPE --> Número da Conta
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                 ,pr_vltotliq IN NUMBER                --> Valor total IOF Atraso
                                 ,pr_vltxiofatra OUT NUMBER            --> Valor total IOF Atraso
                                  --------> OUT <--------
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descriçao da crítica
                                 ) is
   /*-------------------------------------------------------------------------------------------------------
     Programa : pc_lanca_iof_bordero        Antigo: b1wgen0030.p/efetua_liber_anali_bordero (Trecho de Liberação)
     Sistema  :
     Sigla    : CRED
     Autor    : Lucas Lazari (GFT)
     Data     : Abril/2018

     Objetivo  : Procedure para lançar o IOF sobre o borderô de desconto de Tìtulo

     Alteracoes: 16/04/2018 - Criação (Lucas Lazari (GFT))
   ----------------------------------------------------------------------------------------------------------*/

    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_nrdolote craplot.nrdolote%TYPE;

    vr_vltotiof                  NUMBER;
    vr_flgimune                  INTEGER;
    vr_cdcritic                  PLS_INTEGER;
    vr_exc_erro                  EXCEPTION;

    vr_flg_criou_lot             BOOLEAN;

    vr_nrseqdig                  NUMBER;

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

    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'DSCT0003.pc_lanca_iof_bordero');

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

    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    vr_vltotiof := ROUND(vr_vltotiofpri + vr_vltotiofadi,2);

    IF vr_vltotiof > 0 THEN

      -- Verifica e atualiza o registro de cotas da conta do cooperado
      OPEN cr_crapcot(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta);
      FETCH cr_crapcot INTO rw_crapcot;

      --Se não encontrar o registro de cotas do usuário, lança o erro
      IF cr_crapcot%NOTFOUND THEN
        -- Fecha Cursor
        CLOSE cr_crapcot;

        vr_dscritic:= 'Registro crapcot não encontrado.';
        RAISE vr_exc_erro;
      ELSE
        -- Fecha cursor
        CLOSE cr_crapcot;

        -- Atualiza o registro de cotas da conta do cooperado
        UPDATE crapcot
           SET crapcot.vliofapl = crapcot.vliofapl + vr_vltotiof,
               crapcot.vlbsiapl = crapcot.vlbsiapl + pr_vltotliq
         WHERE crapcot.cdcooper = pr_cdcooper
           AND crapcot.nrdconta = pr_nrdconta;
      END IF;

      vr_flg_criou_lot := FALSE;

      -- Insere um lote novo
      WHILE NOT vr_flg_criou_lot LOOP

        -- Rotina para criar lote
      vr_nrdolote := fn_sequence(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRDOLOTE'
                                ,pr_dsdchave => TO_CHAR(pr_cdcooper)|| ';'
                                             || TO_CHAR(pr_dtmvtolt, 'DD/MM/RRRR') || ';'
                                             || TO_CHAR(pr_cdagenci)|| ';'
                                             || '100');

         BEGIN
           INSERT INTO craplot
            (cdcooper,
             dtmvtolt,
             cdagenci,
             cdbccxlt,
             nrdolote,
             tplotmov,
             cdoperad)
          VALUES
            (pr_cdcooper,
             pr_dtmvtolt,
             pr_cdagenci,
             100,
             vr_nrdolote,
             1,
             pr_cdoperad)
          RETURNING nrseqdig, ROWID INTO rw_craplot.nrseqdig, rw_craplot.rowid;
         EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            CONTINUE;
           WHEN OTHERS THEN
            -- Gera crítica
             vr_dscritic := 'Erro ao inserir novo lote IOF (1) ' || SQLERRM;
            -- Levanta exceção
             RAISE vr_exc_erro;
         END;

        vr_flg_criou_lot := TRUE;

      END LOOP;

        -- Criar registro na lcm
        BEGIN
        vr_nrseqdig := NVL(rw_craplot.nrseqdig,0) + 1;

          INSERT INTO craplcm
                   (/*01*/ cdcooper
                   ,/*02*/ dtmvtolt
                   ,/*03*/ hrtransa
                   ,/*04*/ cdagenci
                   ,/*05*/ cdbccxlt
                   ,/*06*/ nrdolote
                   ,/*07*/ nrseqdig
                   ,/*08*/ nrdconta
                   ,/*09*/ nrdctabb
                   ,/*10*/ nrdctitg
                   ,/*11*/ nrdocmto
                   ,/*12*/ cdhistor
                   ,/*13*/ vllanmto
                   ,/*14*/ cdpesqbb)
            VALUES(/*01*/ pr_cdcooper
                  ,/*02*/ pr_dtmvtolt
                  ,/*03*/ TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                  ,/*04*/ pr_cdagenci
                  ,/*05*/ 100
                  ,/*06*/ vr_nrdolote
                  ,/*07*/ vr_nrseqdig
                  ,/*08*/ pr_nrdconta
                  ,/*09*/ pr_nrdconta
                  ,/*10*/ TO_CHAR(gene0002.fn_mask(pr_nrdconta,'99999999'))
                  ,/*11*/ vr_nrseqdig
                  ,/*12*/ vr_cdhistordsct_iofspriadic
                  ,/*13*/ vr_vltotiof
                  ,/*14*/ 'Bordero ' || pr_nrborder || ' - ' || TO_CHAR(gene0002.fn_mask(pr_vltotliq,'999.999.999999')));
        EXCEPTION
          WHEN OTHERS THEN
            -- Monta critica
            vr_cdcritic := 0;
          vr_dscritic := 'Erro no Lancamento de IOF (2): ' || SQLERRM;
          -- Gera exceção
          RAISE vr_exc_erro;
      END;

      BEGIN
        UPDATE craplot
           SET craplot.nrseqdig = NVL(craplot.nrseqdig,0) + 1
              ,craplot.qtinfoln = NVL(craplot.qtinfoln,0) + 1
              ,craplot.qtcompln = NVL(craplot.qtcompln,0) + 1
              ,craplot.vlinfocr = NVL(craplot.vlinfocr,0) + vr_vltotiof
              ,craplot.vlcompcr = NVL(craplot.vlcompcr,0) + vr_vltotiof
         WHERE craplot.rowid = rw_craplot.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          -- Monta critica
          vr_dscritic := 'Erro ao atualizar o Lote IOF (3): ' || SQLERRM;
            -- Gera exceção
            RAISE vr_exc_erro;
        END;

      TIOF0001.pc_insere_iof (pr_cdcooper       => pr_cdcooper
                             ,pr_nrdconta       => pr_nrdconta
                             ,pr_dtmvtolt       => pr_dtmvtolt
                             ,pr_tpproduto      => 2
                             ,pr_nrcontrato     => pr_nrborder
                             ,pr_dtmvtolt_lcm   => pr_dtmvtolt
                             ,pr_cdagenci_lcm   => NVL(pr_cdagenci,0)
                             ,pr_cdbccxlt_lcm   => 100
                             ,pr_nrdolote_lcm   => vr_nrdolote
                             ,pr_nrseqdig_lcm   => rw_craplot.nrseqdig
                             ,pr_vliofpri       => ROUND(vr_vltotiofpri,2)
                             ,pr_vliofadi       => ROUND(vr_vltotiofadi,2)
                             ,pr_vliofcpl       => ROUND(vr_vltotiofcpl,2)
                             ,pr_flgimune       => vr_flgimune
                             ,pr_cdcritic       => vr_cdcritic
                             ,pr_dscritic       => vr_dscritic);

        IF ( vr_cdcritic > 0 OR vr_dscritic IS NOT NULL ) THEN
           RAISE vr_exc_erro;
        END IF;

    END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
       IF  NVL(vr_cdcritic,0) <> 0 THEN
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        -- Erro
        pr_dscritic := 'Erro na rotina DSCT0003.pc_lanca_iof_bordero ' || SQLERRM;

  END pc_lanca_iof_bordero;

  /*Procedure que grava as restrições de um borderô (b1wgen0030.p/grava-restricao-bordero)*/
  PROCEDURE pc_grava_restricao_bordero (pr_nrborder IN crapabt.nrborder%TYPE --> Número do Borderô
                                       ,pr_cdoperad IN crapabt.cdoperad%TYPE DEFAULT NULL --> Codigo do operador
                                       ,pr_nrdconta IN crapabt.nrdconta%TYPE
                                       ,pr_dsrestri IN crapabt.dsrestri%TYPE --> Descrição da Restrição
                                       ,pr_nrseqdig IN crapabt.nrseqdig%TYPE --> Sequêncial da Restrição
                                       ,pr_cdcooper IN crapabt.cdcooper%TYPE --> Código da Cooperativa
                                       ,pr_cdbandoc IN crapabt.cdbandoc%TYPE DEFAULT 0
                                       ,pr_nrdctabb IN crapabt.nrdctabb%TYPE DEFAULT 0
                                       ,pr_nrcnvcob IN crapabt.nrcnvcob%TYPE DEFAULT 0
                                       ,pr_nrdocmto IN crapabt.nrdocmto%TYPE DEFAULT 0
                                       ,pr_flaprcoo IN crapabt.flaprcoo%TYPE --> Indicador se foi aprovado pelo coordenador (1 Sim / 0 Não)
                                       ,pr_dsdetres IN crapabt.dsdetres%TYPE --> Detalhamento da restricao
                                       ,pr_dscritic    OUT VARCHAR2                --> Descricao Critica
                                       ) is
  BEGIN
    BEGIN
      INSERT INTO crapabt
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
            ,NVL(pr_dsdetres,' '));
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao gravar o registro crapabt: '|| sqlerrm;
    END;
  END pc_grava_restricao_bordero;

  /* Retorna a qtd. de Títulos de acordo com alguma ocorrencia */
  PROCEDURE pc_ret_qttit_ocorrencia (pr_cdcooper IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                    ,pr_nrdconta IN craptdb.nrdconta%TYPE --> Número da Conta
                                    ,pr_nrinssac IN craptdb.nrinssac%TYPE --> Pagador
                                    ,pr_cdocorre IN crapret.cdocorre%TYPE --> Código do Tipo de Ocorrência
                                    ,pr_cdmotivo IN crapret.cdmotivo%TYPE DEFAULT '' --> Contém o Código do Motivo
                                    ,pr_flgtitde IN boolean DEFAULT FALSE --> Qual Tipo de Tìtulo (FALSE= Apenas Títulos em Borderô)
                                     --------> OUT <--------
                                    ,pr_cntqttit OUT PLS_INTEGER          --> Quantidade de Tìtulos de Acordo com o Filtro.
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
    --   Objetivo  : Retorna a qtd. de Títulos de acordo com alguma ocorrencia
    DECLARE
      vr_query VARCHAR2(4000);
    BEGIN
      vr_query := 'SELECT COUNT(1) AS QTDE '||CHR(13)||
                  '  FROM crapcco cco '||CHR(13)||
                  ' INNER JOIN crapceb ceb '||CHR(13)||
                  '    ON ceb.cdcooper = cco.cdcooper '||CHR(13)||
                  '   AND ceb.nrconven = cco.nrconven '||CHR(13)||
                  ' INNER JOIN crapcob cob '||CHR(13)||
                  '    ON cob.cdcooper = ceb.cdcooper '||CHR(13)||
                  '   AND cob.cdbandoc = cob.cdbandoc '||CHR(13)||
                  '   AND cob.nrdctabb = cob.nrdctabb '||CHR(13)||
                  '   AND cob.nrdconta = ceb.nrdconta '||CHR(13)||
                  '   AND cob.nrcnvcob = ceb.nrconven '||CHR(13);

      IF pr_flgtitde THEN
        vr_query := vr_query ||
                    ' INNER JOIN craptdb tdb '||CHR(13)||
                    '    ON tdb.cdcooper = cob.cdcooper '||CHR(13)||
                    '   AND tdb.cdbandoc = cob.cdbandoc '||CHR(13)||
                    '   AND tdb.nrdctabb = cob.nrdctabb  '||CHR(13)||
                    '   AND tdb.nrcnvcob = cob.nrcnvcob  '||CHR(13)||
                    '   AND tdb.nrdconta = cob.nrdconta  '||CHR(13)||
                    '   AND tdb.nrdocmto = cob.nrdocmto '||CHR(13);
      END IF;

      IF NVL(pr_cdocorre,0) > 0 THEN
        vr_query := vr_query ||
                    'INNER JOIN crapret ret '||CHR(13)||
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

      -- Ordem para executar de forma imediata o SQL dinâmico
      EXECUTE IMMEDIATE vr_query INTO pr_cntqttit;
    END;
  END pc_ret_qttit_ocorrencia;

  /* Buscar dados do Principal (@) da rotina Desconto de Titulos */
  PROCEDURE pc_busca_dados_dsctit (pr_cdcooper IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                  ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL --> Codigo do operador
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                  ,pr_idorigem IN INTEGER  --Identificador Origem pagamento
                                  ,pr_nrdconta IN craptdb.nrdconta%TYPE DEFAULT NULL --> Número da Conta
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

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Descrição da origem da chamada
      vr_dsorigem VARCHAR2(10);
      -- Descrição da transação
      vr_dstransa VARCHAR2(100);
      -- rowid tabela de log
      vr_nrdrowid ROWID;

      --Variável Auxiliar de Cálculo de Datas.
      vr_aux_difdays PLS_INTEGER;

      --Cursor para popular o total de Titulos qdo não há registro de Limite, a partir dos Titulos do Borderô.
      CURSOR cr_tdbcco (pr_cdcooper IN craptdb.cdcooper%TYPE,
                        pr_nrdconta IN craptdb.nrdconta%TYPE,
                        pr_dtmvtolt IN craptdb.dtdpagto%TYPE) IS
        SELECT SUM(tdb.vltitulo) AS vlutiliz,
               COUNT(tdb.vltitulo) AS qtutiliz,
               SUM(DECODE(cco.flgregis, 1, tdb.vltitulo, 0)) AS vlutilcr,
               SUM(DECODE(cco.flgregis, 1, 1, 0)) AS qtutilcr,
               SUM(DECODE(cco.flgregis, 0, tdb.vltitulo, 0)) AS vlutilsr,
               SUM(DECODE(cco.flgregis, 0, 1, 0)) AS qtutilsr
          FROM craptdb tdb
         INNER JOIN crapcco cco
            ON cco.cdcooper = tdb.cdcooper
           AND cco.nrconven = tdb.nrcnvcob
         WHERE (tdb.cdcooper = pr_cdcooper AND tdb.nrdconta = pr_nrdconta AND tdb.insittit = 4)
            OR (tdb.cdcooper = pr_cdcooper AND tdb.nrdconta = pr_nrdconta AND tdb.insittit = 2 AND
                tdb.dtdpagto = pr_dtmvtolt --trunc(sysdate)
                );
      rw_tdbcco cr_tdbcco%ROWTYPE;

      --Cursor para Linhas de Crédito
      CURSOR cr_crapldc (pr_cdcooper IN crapldc.cdcooper%TYPE,
                         pr_cddlinha IN crapldc.cddlinha%TYPE) IS
        SELECT ldc.cddlinha,
               ldc.dsdlinha,
               ldc.flgstlcr
          FROM crapldc ldc
         WHERE ldc.cdcooper = pr_cdcooper
           AND ldc.cddlinha = pr_cddlinha
           AND ldc.tpdescto = 3;
      rw_crapldc cr_crapldc%ROWTYPE;

    BEGIN
      --Iniciando Variavel
      vr_des_reto := 'OK';

      -- Se foi solicitado LOG
      IF pr_flgerlog THEN
        -- busca informações que serão aproveitas posteriormente
        vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
        vr_dstransa := 'Consultar a quantidade de Títulos de acordo com alguma ocorrência.';
      END IF;

      -- Buscar dados de Capital para o Cooperado, Conta, DtMovtolt
      -- Verificar se a cota/capital do cooperado é válida
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

      -- Verifica se retornou erro durante a execução
      IF vr_des_reto <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          -- Se existir erro adiciona na crítica
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

        -- Se Solicitou Geração de LOG
        IF pr_flgerlog THEN
          -- Chamar geração de LOG
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

      -- Se NÃO encontrar registro DE LIMITE
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
          pr_tab_dados_dsctit(1).dsdlinha := rw_craplim.cddlinha || ' - NÃO CADASTRADA';
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
  PROCEDURE pc_valida_tit_bordero (pr_cdcooper IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                  ,pr_cdagenci IN crawlim.cdagenci%TYPE --> Código da Agência
                                  ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE
                                  ,pr_nrdconta IN craptdb.nrdconta%TYPE --> Número da Conta
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE
                                  ,pr_tpvalida IN INTEGER DEFAULT 1 --> 1: Análise do Borderô 2: Inclusão do Borderô.
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
    --   Objetivo  : Verifica se os titulos ja estao em algum bordero - APENAS PARA ANÁLISE/LIBERAÇÃO.
    DECLARE

      -- Auxiliares para geração de erro.
      vr_contador PLS_INTEGER;
      vr_flgtrans BOOLEAN;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Cursor de verificação dos Títulos.
      CURSOR cr_verifica_bordero (pr_cdcooper IN craptdb.cdcooper%TYPE,
                                  pr_nrdconta IN craptdb.nrdconta%TYPE,
                                  pr_nrborder IN craptdb.nrborder%TYPE) IS
        SELECT tdbold.nrborder AS nrborder_dup,
               tdbold.nrdocmto AS nrdocmto_dup,
               tdbold.insitapr AS insitapr_dup
          FROM craptdb tdban -- titulos de bordero que estão no bordero que se quer analisar
         INNER JOIN craptdb tdbold -- titulos deste bordero que estão em um bordero diferente.
            ON tdbold.cdcooper =  tdban.cdcooper
           AND tdbold.cdbandoc =  tdban.cdbandoc
           AND tdbold.nrdctabb =  tdban.nrdctabb
           AND tdbold.nrcnvcob =  tdban.nrcnvcob
           AND tdbold.nrdconta =  tdban.nrdconta
           AND tdbold.nrborder <> tdban.nrborder
           AND tdbold.nrdocmto =  tdban.nrdocmto
         INNER JOIN crapbdt bdtold
           ON bdtold.nrborder = tdbold.nrborder
           AND bdtold.cdcooper = tdbold.cdcooper
           AND bdtold.nrdconta = tdbold.nrdconta
         WHERE tdban.cdcooper = pr_cdcooper
           AND tdban.nrborder = pr_nrborder
           AND tdban.nrdconta = pr_nrdconta
           AND tdbold.insittit IN (0, 2, 4)
           AND bdtold.insitbdt<>5; -- diferente de reiejtado

      rw_verifica_bordero cr_verifica_bordero%ROWTYPE;

    -- Selecionar os titulos do bordero ativo
    CURSOR cr_craptdb IS
    SELECT nrdocmto
      FROM craptdb
     WHERE nrborder = pr_nrborder
       AND nrdconta = pr_nrdconta
       AND cdcooper = pr_cdcooper;
    rw_craptdb cr_craptdb%ROWTYPE;

    fl_nobordero INTEGER;
    BEGIN
      -- Iniciando Variáveis.
      vr_contador := 0;
      vr_flgtrans := TRUE;
      vr_cdcritic := 0;

      --Limpar tabelas
      pr_tab_erro.DELETE;

      IF pr_tpvalida = 1 THEN

        FOR rw_verifica_bordero IN
            cr_verifica_bordero (pr_cdcooper => pr_cdcooper,
                                 pr_nrdconta => pr_nrdconta,
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
              vr_dscritic := 'Título ' || rw_verifica_bordero.nrdocmto_dup || ' já incluso no Borderô ' || rw_verifica_bordero.nrborder_dup;
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

  PROCEDURE pc_calcula_restricao_bordero(pr_cdcooper    IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_nrdconta      IN craptdb.nrdconta%TYPE DEFAULT NULL --> Número da Conta
                                      ,pr_tot_titulos   IN  NUMBER                            --> Quantidade de títulos do borderô
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
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
    vr_dscritic varchar2(1000);        --> Desc. Erro
    -- Tratamento de erros
    vr_exc_erro exception;

    vr_index PLS_INTEGER;
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapass.inpessoa
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    vr_tab_dados_dsctit    dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052 para Cooperativa e Cobrança Registrada
    vr_tab_cecred_dsctit   dsct0002.typ_tab_cecred_dsctit;

    BEGIN
      -- busca os dados do associado/cooperado para só então encontrar seus dados na tabela de parâmetros
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      CLOSE cr_crapass;
      -- Busca os Parâmetros para o Cooperado e Cobrança Com Registro
      dsct0002.pc_busca_parametros_dsctit(pr_cdcooper, --pr_cdcooper,
                                            NULL, --Agencia de operação
                                            NULL, --Número do caixa
                                            NULL, --Operador
                                            NULL, -- Data da Movimentação
                                            NULL, --Identificação de origem
                                            1, --pr_tpcobran: 1-REGISTRADA / 0-NÃO REGISTRADA
                                            rw_crapass.inpessoa, --1-PESSOA FÍSICA / 2-PESSOA JURÍDICA
                                            vr_tab_dados_dsctit,
                                            vr_tab_cecred_dsctit,
                                            vr_cdcritic,
                                            vr_dscritic);
      IF (vr_tab_dados_dsctit(1).qtmxtbay>0 AND pr_tot_titulos > vr_tab_dados_dsctit(1).qtmxtbay) THEN
        vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
        OPEN cr_tbdsct_criticas (pr_cdcritica=>17);
        FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
        CLOSE cr_tbdsct_criticas;
        pr_tab_criticas(vr_index).cdcritica := 17; --Quantidade de títulos por borderô excedido
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
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
    vr_dscritic varchar2(1000);        --> Desc. Erro
    -- Tratamento de erros
    vr_exc_erro exception;

   -- Cursor do titulo
    CURSOR cr_crapcob IS
    SELECT cob.flgdprot,
           cob.flserasa,
           cob.vltitulo
      FROM crapcob cob
     WHERE cob.flgregis > 0
       AND cob.incobran = 0
       AND cob.nrdconta = pr_nrdconta
       AND cob.cdcooper = pr_cdcooper
       AND cob.nrcnvcob = pr_nrcnvcob
       AND cob.cdbandoc = pr_cdbandoc
       AND cob.nrdctabb = pr_nrdctabb
       AND cob.nrdocmto = pr_nrdocmto;
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
        pr_tab_criticas(vr_index).cdcritica := 9; -- Valor Máximo Permitido por CNAE excedido
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
      /*Verifica se o título  possui instrução de protesto e/ou negativação*/
      IF (rw_crapcob.flgdprot =0 AND rw_crapcob.flserasa =0) THEN
        vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
        OPEN cr_tbdsct_criticas (pr_cdcritica=>10);
        FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
        CLOSE cr_tbdsct_criticas;
        pr_tab_criticas(vr_index).cdcritica := 10; --Tit. não possui instr. de protesto e/ou negativação
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

  PROCEDURE pc_calcula_restricao_cedente(pr_cdcooper    IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_nrdconta      IN craptdb.nrdconta%TYPE DEFAULT NULL --> Número da Conta
                                      ,pr_cdagenci IN crawlim.cdagenci%TYPE --> Código da Agência
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
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
    vr_dscritic varchar2(1000);        --> Desc. Erro
    -- Tratamento de erros
    vr_exc_erro exception;

    vr_index PLS_INTEGER;
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapass.inpessoa
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- cursor para totalizações de status dos títulos por cooperado e conta
    CURSOR cr_tdbcob_status (pr_cdcooper IN craptdb.cdcooper%TYPE
                            ,pr_nrdconta IN craptdb.nrdconta%TYPE) IS
      SELECT SUM(DECODE(tdb.insittit,2,1,0)) as qttitdsc --Analisado
            ,SUM(DECODE(tdb.insittit,3,1,0)) as naopagos --Liberado
        FROM craptdb tdb
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

    vr_tab_dados_dsctit    dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052 para Cooperativa e Cobrança Registrada
    vr_tab_cecred_dsctit   dsct0002.typ_tab_cecred_dsctit;

    vr_qtprotes PLS_INTEGER := 0;
    vr_pcnaopag craptdb.vltitulo%TYPE := 0;
    vr_qttitdsc PLS_INTEGER := 0; --Analisado
    vr_naopagos PLS_INTEGER := 0; --Liberado
    -- variaveis para tratar restrições de grupo economico
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

    vr_liqgeral   NUMBER(25,2);
    vr_qtd_geral  NUMBER(25,2);
    BEGIN
      --    Leitura do calendário da cooperativa
      OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat into rw_crapdat;
      CLOSE btch0001.cr_crapdat;
      -- busca os dados do associado/cooperado para só então encontrar seus dados na tabela de parâmetros
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      CLOSE cr_crapass;
      -- Busca os Parâmetros para o Cooperado e Cobrança Com Registro
      dsct0002.pc_busca_parametros_dsctit(pr_cdcooper, --pr_cdcooper,
                                            NULL, --Agencia de operação
                                            NULL, --Número do caixa
                                            NULL, --Operador
                                            NULL, -- Data da Movimentação
                                            NULL, --Identificação de origem
                                            1, --pr_tpcobran: 1-REGISTRADA / 0-NÃO REGISTRADA
                                            rw_crapass.inpessoa, --1-PESSOA FÍSICA / 2-PESSOA JURÍDICA
                                            vr_tab_dados_dsctit,
                                            vr_tab_cecred_dsctit,
                                            vr_cdcritic,
                                            vr_dscritic);
      /*COMEÇA AS VALIDAÇÕES DO CEDENTE*/
      /* Aqui vai a critica 11,12,15,16,13 e 14*/
      /* retorna qtd. total títulos protestados do cedente (cooperado) */
      pc_ret_qttit_ocorrencia(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrinssac => 0 -- para o cooperado
                             ,pr_cdocorre => 9
                             ,pr_cdmotivo => 14
                             ,pr_flgtitde => FALSE --> apenas títulos em Borderô
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

      -- recuperando O valor Total dos Títulos do Borderô, com COB. REGISTRADA e/ou S/ REGISTRO
      FOR rw_tdbcob_status IN cr_tdbcob_status (pr_cdcooper => pr_cdcooper,
                                                pr_nrdconta => pr_nrdconta) LOOP
        vr_qttitdsc := rw_tdbcob_status.qttitdsc+rw_tdbcob_status.naopagos; --total
        vr_naopagos := rw_tdbcob_status.naopagos; --Liberado
      END LOOP;
      IF vr_qttitdsc > 0 THEN
        vr_pcnaopag := ROUND((vr_naopagos * 100) / vr_qttitdsc,2);
      END IF;
      /* Valida Perc. de Titulos não Pago Beneficiario */
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
      ELSE --  Se conta não pertence a um grupo
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
        --  Verifica se o valor é maior que o valor maximo utilizado pelo associado nos emprestimos
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
        --  Verifica se o valor é maior que o valor legal a ser emprestado pela cooperativa
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
      pc_retorna_liquidez_geral(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_dtmvtolt_de =>  rw_crapdat.dtmvtolt - vr_tab_dados_dsctit(1).qtmesliq*30
                           ,pr_dtmvtolt_ate => rw_crapdat.dtmvtolt
                           ,pr_qtcarpag => vr_tab_dados_dsctit(1).cardbtit_c
                           ,pr_qtmitdcl => vr_tab_dados_dsctit(1).qtmitdcl
                           ,pr_vlmintcl => vr_tab_dados_dsctit(1).vlmintcl
                           -- OUT --
                           ,pr_pc_geral     => vr_liqgeral
                           ,pr_qtd_geral    => vr_qtd_geral);

      -- Verificando o Mínimo de Liquidez de títulos Geral do Cedente (Quantidade = #TAB052.qtmintgc)
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
      -- Verificando o Mínimo de Liquidez de títulos Geral do Cedente (Valor = #TAB052.vlmintgc)
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

  PROCEDURE pc_calcula_restricao_pagador(pr_cdcooper    IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_nrdconta      IN craptdb.nrdconta%TYPE --> Número da Conta
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
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
    vr_dscritic varchar2(1000);        --> Desc. Erro
    -- Tratamento de erros
    vr_exc_erro exception;

    vr_index PLS_INTEGER;
    --  Críticas Pagador (Job - Análise Diária)
    CURSOR cr_analise_pagador is
    SELECT *
      FROM tbdsct_analise_pagador
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrinssac = pr_nrinssac;
    rw_analise_pagador cr_analise_pagador%rowtype;

    BEGIN
      --> CRÍTICAS DO PAGADOR (JOB - ANÁLISE PAGADOR)
      open  cr_analise_pagador;
      fetch cr_analise_pagador into rw_analise_pagador;
      close cr_analise_pagador;

      IF rw_analise_pagador.inpossui_criticas > 0 THEN
        -- qtremessa_cartorio -> Crítica: Qtd Remessa em Cartório acima do permitido. (Ref. TAB052: qtremcrt).
        if rw_analise_pagador.qtremessa_cartorio > 0 then
          vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
          OPEN cr_tbdsct_criticas (pr_cdcritica=>1);
          FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
          CLOSE cr_tbdsct_criticas;
          pr_tab_criticas(vr_index).cdcritica := 1; --Quantidade de títulos por borderô excedido
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
        -- qttit_protestados -> Crítica: Qtd de Títulos Protestados acima do permitido. (Ref. TAB052: qttitprt).
        if rw_analise_pagador.qttit_protestados > 0 then
          vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
          OPEN cr_tbdsct_criticas (pr_cdcritica=>2);
          FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
          CLOSE cr_tbdsct_criticas;
          pr_tab_criticas(vr_index).cdcritica := 2; --Qtd de Títulos Protestados acima do permitido.
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

        -- qttit_naopagos -> Crítica: Qtd de Títulos Não Pagos pelo Pagador acima do permitido. (Ref. TAB052: qtnaopag).
        if rw_analise_pagador.qttit_naopagos > 0 then
          vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
          OPEN cr_tbdsct_criticas (pr_cdcritica=>3);
          FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
          CLOSE cr_tbdsct_criticas;
          pr_tab_criticas(vr_index).cdcritica := 3; --Qtd de Títulos Não Pagos pelo Pagador acima do permitido
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

        -- pemin_liquidez_qt -> Crítica: Perc. Mínimo de Liquidez Cedente x Pagador abaixo do permitido (Qtd. de Títulos).  (Ref. TAB052: qttliqcp).
        if rw_analise_pagador.pemin_liquidez_qt > 0.0 then
          vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
          OPEN cr_tbdsct_criticas (pr_cdcritica=>4);
          FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
          CLOSE cr_tbdsct_criticas;
          pr_tab_criticas(vr_index).cdcritica := 4; -- Perc. Mínimo de Liquidez Cedente x Pagador abaixo do permitido (Qtd. de Títulos)
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

        -- pemin_liquidez_vl -> Crítica: Perc. Mínimo de Liquidez Cedente x Pagador abaixo do permitido (Valor dos Títulos).  (Ref. TAB052: vltliqcp).
        if rw_analise_pagador.pemin_liquidez_vl > 0.0 then
          vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
          OPEN cr_tbdsct_criticas (pr_cdcritica=>5);
          FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
          CLOSE cr_tbdsct_criticas;
          pr_tab_criticas(vr_index).cdcritica := 5; -- Perc. Mínimo de Liquidez Cedente x Pagador abaixo do permitido (Valor dos Títulos)
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

        -- peconcentr_maxtit -> Crítica: Perc. Concentração Máxima Permitida de Títulos excedida. (Ref. TAB052: pcmxctip).
        if rw_analise_pagador.peconcentr_maxtit > 0.0 then
          vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
          OPEN cr_tbdsct_criticas (pr_cdcritica=>6);
          FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
          CLOSE cr_tbdsct_criticas;
          pr_tab_criticas(vr_index).cdcritica := 6; -- Perc. Concentração Máxima Permitida de Títulos excedida
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

        -- inemitente_conjsoc -> Crítica: Emitente é Cônjuge/Sócio do Pagador (0 = Não / 1 = Sim). (Ref. TAB052: flemipar).
        if rw_analise_pagador.inemitente_conjsoc > 0 then
          vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
          OPEN cr_tbdsct_criticas (pr_cdcritica=>7);
          FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
          CLOSE cr_tbdsct_criticas;
          pr_tab_criticas(vr_index).cdcritica := 7; -- Emitente é Cônjuge/Sócio do Pagador
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

        -- inpossui_titdesc -> Crítica: Cooperado possui Títulos Descontados na Conta deste Pagador  (0 = Não / 1 = Sim). (Ref. TAB052: flpdctcp).
        if rw_analise_pagador.inpossui_titdesc > 0 then
          vr_index := pr_tab_criticas.count + 1  ; -- pega o ultimo registro
          OPEN cr_tbdsct_criticas (pr_cdcritica=>8);
          FETCH cr_tbdsct_criticas INTO rw_tbdsct_criticas;
          CLOSE cr_tbdsct_criticas;
          pr_tab_criticas(vr_index).cdcritica := 8; -- Cooperado possui Títulos Descontados na Conta deste Pagador
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

  /* Procura estriçoes de um borderô e cria entradas na  tabela de restrições quando encontradas (b1wgen0030.p/analisar-titulo-bordero)*/
  PROCEDURE pc_restricoes_tit_bordero (pr_cdcooper IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_cdagenci IN crawlim.cdagenci%TYPE --> Código da Agência
                                      ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE
                                      ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                                      ,pr_nmdatela IN VARCHAR2      --> Nome da tela
                                      ,pr_idorigem IN INTEGER  --> Identificador Origem pagamento
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                      ,pr_nrdconta IN craptdb.nrdconta%TYPE DEFAULT NULL --> Número da Conta
                                      ,pr_idseqttl IN INTEGER       --> idseqttl
                                      ,pr_nrborder IN crapbdt.nrborder%TYPE
                                      ,pr_flgerlog IN BOOLEAN       --> identificador se deve gerar log
                                      --------> OUT <--------
                                      ,pr_indrestr IN OUT PLS_INTEGER--> Indica se Gerou Restrição (0 - Sem Restrição / 1 - Com restrição)
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
    --   Objetivo  : Procura restriçoes de um borderô e cria entradas na  tabela de restrições quando encontradas
    --   Alterações: 09/07/2018 - Vitor Shimada Assanuma - Alteração das mensagens de críticas e inserção de 2 críticas
    --                                                   novas de minimo de liquidez

    DECLARE
      -- Auxiliares para geração de erro.
      vr_contador PLS_INTEGER;


      -- Tratamento de erros
      vr_exc_erro exception;

      -- Erro em chamadas
      vr_des_reto VARCHAR2(3) DEFAULT 'OK';

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
      vr_dscritic varchar2(1000);        --> Desc. Erro


      vr_tab_dados_dsctit_cr dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052 para Cooperativa e Cobrança Registrada
      vr_tab_dados_dsctit_sr dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052 para Cooperativa e Cobrança Sem Registro
      vr_tab_cecred_dsctit dsct0002.typ_tab_cecred_dsctit; -- retorno da TAB052 para CECRED

      -- Descrição da origem da chamada
      vr_dsorigem VARCHAR2(10);
      -- Descrição da transação
      vr_dstransa VARCHAR2(100);
      -- rowid tabela de log
      vr_nrdrowid ROWID;

      vr_tab_criticas typ_tab_critica;
      vr_tot_titulos  NUMBER := 0;
      vr_index PLS_INTEGER;
      -- Cursor para o Loop Principal em Títulos do borderô e Dados de Cobrança
      CURSOR cr_craptdb_cob (pr_cdcooper IN craptdb.cdcooper%TYPE,
                             pr_nrdconta IN craptdb.nrdconta%TYPE,
                             pr_nrborder IN craptdb.nrborder%TYPE) IS
        SELECT tdb.cdcooper,
               tdb.nrborder,
               tdb.nrdconta,
               tdb.nrinssac,
               tdb.nrdocmto,
               tdb.nrcnvcob,
               tdb.nrdctabb,
               tdb.cdbandoc,
               tdb.vltitulo,
               tdb.dtvencto,
               cob.incobran,
               cob.flgregis,
               cob.flgdprot,
               cob.flserasa
          FROM craptdb tdb
          LEFT JOIN crapcob cob
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
      rw_craptdb_cob cr_craptdb_cob%ROWTYPE;

    vr_tab_dados_dsctit   typ_tab_desconto_titulos;
    BEGIN


      -- Se foi solicitado LOG
      IF pr_flgerlog THEN
        -- busca informações que serão aproveitas posteriormente
        vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
        vr_dstransa := 'Consultar a qtd. de Títulos de acordo com alguma ocorrencia.';
      END IF;

      -- iniciando variáveis
      vr_cdcritic := 0;
      vr_dscritic := '';

      --Limpar tabelas
      pr_tab_erro.DELETE;

      -- busca os dados do associado/cooperado para só então encontrar seus dados na tabela de parâmetros
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;

      IF cr_crapass%FOUND THEN
        -- Busca os Parâmetros para o Cooperado e Cobrança Com Registro
        dsct0002.pc_busca_parametros_dsctit(pr_cdcooper, --pr_cdcooper,
                                            pr_cdagenci, --Agencia de operação
                                            pr_nrdcaixa, --Número do caixa
                                            pr_cdoperad, --Operador
                                            pr_dtmvtolt, -- Data da Movimentação
                                            pr_idorigem, --Identificação de origem
                                            1, --pr_tpcobran: 1-REGISTRADA / 0-NÃO REGISTRADA
                                            rw_crapass.inpessoa, --1-PESSOA FÍSICA / 2-PESSOA JURÍDICA
                                            vr_tab_dados_dsctit_cr,
                                            vr_tab_cecred_dsctit,
                                            vr_cdcritic,
                                            vr_dscritic);

        -- Busca os Parâmetros para o Cooperado e Cobrança Sem Registro
        dsct0002.pc_busca_parametros_dsctit(pr_cdcooper, --pr_cdcooper,
                                            pr_cdagenci, --Agencia de operação
                                            pr_nrdcaixa, --Número do caixa
                                            pr_cdoperad, --Operador
                                            pr_dtmvtolt, -- Data da Movimentação
                                            pr_idorigem, --Identificação de origem
                                            0, --pr_tpcobran: 1-REGISTRADA / 0-NÃO REGISTRADA
                                            rw_crapass.inpessoa, --1-PESSOA FÍSICA / 2-PESSOA JURÍDICA
                                            vr_tab_dados_dsctit_sr,
                                            vr_tab_cecred_dsctit,
                                            vr_cdcritic,
                                            vr_dscritic);
        CLOSE cr_crapass;
      ELSE
         -- se não achou o Cooperado, grava crítica, gera erro e aborta o processo.;
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

      -- Buscar os Dados de linha de Desconto de Tìtulo, e retornar NOK se não encontrar
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

      -- Elimina todas as restriçoes do borderô que está sendo analisado
      BEGIN
        DELETE FROM crapabt abt
         WHERE abt.cdcooper = pr_cdcooper
           AND abt.nrborder = pr_nrborder;
      END;
      -- Gerando as Restrições no Borderô por Status do Pagamento de Cobração para Tìtulo desse Borderô, se houver.
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
          -- Se Solicitou Geração de LOG
          IF pr_flgerlog THEN
            -- Chamar geração de LOG
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
      END LOOP; -- fim da geração das restrições

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
     WHEN vr_exc_erro THEN
          IF  nvl(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS null THEN
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          ELSE
              pr_cdcritic := nvl(vr_cdcritic,0);
              pr_dscritic := REPLACE(REPLACE(vr_dscritic,chr(13)),chr(10));
          END IF;
    WHEN OTHERS THEN
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := REPLACE(REPLACE('Erro pc_restricoes_tit_bordero: ' || SQLERRM, chr(13)),chr(10));
    END;

  END pc_restricoes_tit_bordero;

  PROCEDURE pc_envia_esteira (pr_cdcooper IN crapabt.cdcooper%TYPE
                             ,pr_nrdconta IN crapabt.nrdconta%TYPE
                             ,pr_nrborder IN crapabt.nrborder%TYPE
                             ,pr_cdagenci IN crapass.cdagenci%type --> Código da Agência
                             ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                             ,pr_dtmvtolt IN crapbdt.dtmvtolt%TYPE
                             --------- OUT ---------
                             ,pr_cdcritic OUT INTEGER   --> Codigo Critica
                             ,pr_dscritic OUT VARCHAR2  --> Descricao Critica
                             ,pr_des_erro OUT VARCHAR2  --> Erros do processo
                             ) IS
  BEGIN
    DECLARE
      -- Variáveis de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      vr_dsmensag varchar2(32767);
    BEGIN
              -- Busca todos os títulos que possuem Restrição  E QUE NÃO SÃO CNAE, envia esse borderô e seus títulos
              -- para a esteira da IBRATAN, altera o status dos títulos do borderô e altera o status do borderô para enviado para esteira,
              -- bem como seta seus campos de status de análise.
              -- carrega todos os Títulos Desse Borderô
              --Atualiza todos os títulos da TDB que nao estão como REJEITADOS para em análise da esteira.
              UPDATE craptdb
                 SET craptdb.insitapr = 0 -- 0-Aguardando Análise
                    ,craptdb.cdoriapr = 2 -- 2-Esteira IBRATAN
              WHERE cdcooper = pr_cdcooper
                AND nrdconta = pr_nrdconta
                AND nrborder = pr_nrborder
                AND flgenvmc = 1
                AND insitapr <> 2; -- Diferente de Rejeitado

              -- Altera o Borderô setando como enviado para a mesa de checagem.
              pc_altera_status_bordero(pr_cdcooper => pr_cdcooper -- Código da Cooperativa
                                      ,pr_nrborder => pr_nrborder -- Número do Borderô
                                      ,pr_nrdconta => pr_nrdconta -- Número da conta do cooperado
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


  PROCEDURE pc_efetua_analise_bordero (pr_cdcooper IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_cdagenci IN crapass.cdagenci%type --> Código da Agência
                                      ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Numero Caixa
                                      ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                                      ,pr_nmdatela IN craplgm.nmdatela%TYPE --> Nome da tela.
                                      ,pr_idorigem IN VARCHAR2              --> Identificador Origem pagamento
                                      ,pr_nrdconta IN craptdb.nrdconta%TYPE --> Número da Conta
                                      ,pr_idseqttl IN INTEGER               --> idseqttl
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                      ,pr_dtmvtopr IN crapdat.dtmvtolt%TYPE --> Proxima data de movimento.
                                      ,pr_inproces IN crapdat.inproces%TYPE --> Indicador processo
                                      ,pr_nrborder IN crapbdt.nrborder%TYPE --> Número do Bordero
                                      ,pr_inrotina IN INTEGER DEFAULT 0     --> Indica o tipo de análise (0-APENAS IMPEDITIVOS / 1-IMPEDITIVOS+RESTRIÇÕES COM APROVAÇÃO DE ANÁLISE)
                                      ,pr_flgerlog IN BOOLEAN               --> identificador se deve gerar log
                                      ,pr_insborde IN INTEGER DEFAULT 0     --> Indica se a analise esta sendo feito na inserção apenas para aprovar automatico
                                      --------> OUT <--------
                                      ,pr_indrestr OUT PLS_INTEGER          --> Indica se Gerou Restrição (0 - Sem Restrição / 1 - Com restrição)
                                      ,pr_ind_inpeditivo OUT PLS_INTEGER          --> Indica se o Resultado é Impeditivo para Realizar Liberação. (0 - Sem Impedimentos / 1 - Com Impedimentos)
                                      ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela Erros
                                      ,pr_tab_retorno_analise OUT typ_tab_retorno_analise --> Detalhes Finais da Analise do Bordero.
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descriçao da crítica
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
      Objetivo  : Procedure que que efetua a análise do Borderô.
      Alterações:
                  27/04/2018 - Andrew Albuquerque (GFT) - Alterações para contemplar Mesa de Checagem e Esteira IBRATAN
         15/08/2018 - Vitor Shimada Assanuma (GFT) - Colocar validação se o borderô em análise está no contrato ativo.
         06/02/2019 - Cássia de Oliveira (GFT) - Correção para não enviar para a imbratam caso esteja na mesa de checagem

    ---------------------------------------------------------------------------------------------------------------------*/
    DECLARE

      -- Variáveis de Uso Local
      vr_dsorigem VARCHAR2(40)  DEFAULT NULL; --> Descrição da Origem
      vr_dstransa VARCHAR2(100) DEFAULT NULL; --> Descrição da trasaçao para log
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

      -- Variáveis de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      vr_em_contingencia_ibratan boolean;
      vr_ignora_numero NUMBER;

      --============== CURSORES ==================
      -- Cursor para o Loop Principal em Títulos do borderô e Dados de Cobrança Para validações Restritivas
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
          FROM craptdb tdb
          LEFT JOIN crapcob cob
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
      SELECT crapbdt.cdcooper,
             crapbdt.nrborder,
             crapbdt.nrdconta,
             crapbdt.insitbdt,
             crapbdt.insitapr,
             crapbdt.dtenvmch,
             crapbdt.nrctrlim
        FROM crapbdt
       WHERE crapbdt.cdcooper = pr_cdcooper
         AND crapbdt.nrborder = pr_nrborder;
      rw_crapbdt cr_crapbdt%ROWTYPE;

    /*Carrega as criticas do border por titulo*/
    CURSOR cr_analise_pagador (pr_nrinssac crapsab.nrinssac%TYPE) IS
        SELECT inpossui_criticas
          FROM tbdsct_analise_pagador
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrinssac = pr_nrinssac;
      rw_analise_pagador cr_analise_pagador%ROWTYPE;

    /*Carrega as criticas do border*/
    CURSOR cr_check_crapabt IS
    SELECT COUNT(1) AS fl_critica_abt
      FROM crapabt abt
     INNER JOIN tbdsct_criticas cri
        ON cri.cdcritica = abt.nrseqdig
     WHERE abt.cdcooper = pr_cdcooper
       AND abt.nrdconta = pr_nrdconta
       AND abt.nrborder = pr_nrborder
       AND abt.nrdocmto = 0
       AND abt.cdbandoc = 0
       AND abt.nrcnvcob = 0
       AND cri.tpcritica > 0;
    rw_check_crapabt cr_check_crapabt%ROWTYPE;

    /*Carrega as criticas do border*/
    CURSOR cr_check_crapabt_restricao IS
    SELECT COUNT(1) AS fl_critica_abt
      FROM crapabt abt
     INNER JOIN tbdsct_criticas cri
        ON cri.cdcritica = abt.nrseqdig
     WHERE abt.cdcooper = pr_cdcooper
       AND abt.nrdconta = pr_nrdconta
       AND abt.nrborder = pr_nrborder
       AND cri.tpcritica > 0;
    rw_check_crapabt_restricao cr_check_crapabt_restricao%ROWTYPE;

    CURSOR cr_check_craptdb IS
    SELECT tdb.ROWID AS id,
           (SELECT COUNT(1)
              FROM crapabt abt
             INNER JOIN tbdsct_criticas cri
                ON cri.cdcritica = abt.nrseqdig
             WHERE abt.cdcooper = tdb.cdcooper
               AND abt.nrborder=tdb.nrborder
               AND ((abt.nrdconta = tdb.nrdconta AND abt.nrdocmto = tdb.nrdocmto AND
                   abt.cdbandoc = tdb.cdbandoc AND abt.nrcnvcob = tdb.nrcnvcob) OR
                   cri.tpcritica IN (4, 2))
               AND cri.tpcritica > 0) AS fl_critica_abt,
           (SELECT COUNT(1)
              FROM tbdsct_analise_pagador dap
             WHERE dap.cdcooper = tdb.cdcooper
               AND dap.nrdconta = tdb.nrdconta
               AND dap.nrinssac = tdb.nrinssac
               AND dap.INPOSSUI_CRITICAS = 1) AS fl_critica_pag,
           CASE
             WHEN DSCT0003.fn_spc_serasa(pr_cdcooper => tdb.cdcooper,
                                         pr_nrdconta => tdb.nrdconta,
                                         pr_nrcpfcgc => tdb.nrinssac) = 'S' THEN
              1
             ELSE
              0
         END fl_critica_biro
      FROM craptdb tdb
     WHERE tdb.cdcooper = pr_cdcooper
       AND tdb.nrdconta = pr_nrdconta
       AND tdb.nrborder = pr_nrborder;
    rw_check_craptdb cr_check_craptdb%ROWTYPE;

    -- Retorno da #TAB052
    vr_tab_dados_dsctit    dsct0002.typ_tab_dados_dsctit;
    vr_tab_cecred_dsctit   dsct0002.typ_tab_cecred_dsctit;
    vr_tab_dados_limite    TELA_ATENDA_DSCTO_TIT.typ_tab_dados_limite;          --> retorna dos dados do contrato

    BEGIN
      /*Busca dados do contrato ativo*/
      TELA_ATENDA_DSCTO_TIT.pc_busca_dados_limite (pr_nrdconta
                                     ,pr_cdcooper
                                     ,3 -- desconto de titulo
                                     ,2 -- apenas ativo
                                     ,pr_dtmvtolt
                                     --------> OUT <--------
                                     ,vr_tab_dados_limite
                                     ,vr_cdcritic
                                     ,vr_dscritic
                            );
      IF (vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL) THEN
         RAISE vr_exc_erro;
      END IF;

      /*Dados do Bordero*/
      OPEN cr_crapbdt;
      FETCH cr_crapbdt INTO rw_crapbdt;
      IF (cr_crapbdt%NOTFOUND) THEN
        CLOSE cr_crapbdt;
        vr_dscritic := 'Borderô inválido';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapbdt;
      IF (rw_crapbdt.nrctrlim<>vr_tab_dados_limite(0).nrctrlim) THEN
        vr_dscritic := 'O contrato deste borderô não se encontra mais ativo.';
        RAISE vr_exc_erro;
      END IF;

      IF rw_crapbdt.insitapr IN (1,2) THEN
        vr_dscritic := 'Borderô em análise na mesa de checagem.';
        RAISE vr_exc_erro;
      END IF;
      --Iniciar variáveis e Parâmetros de Retorno
      pr_ind_inpeditivo := 0;
      vr_des_reto := 'OK';
      vr_indrestr := 0;

      --Seta as variáveis de Descrição de Origem e descrição de Transação se For gerar Log
      IF pr_flgerlog THEN
        vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
        vr_dstransa := 'Analisar o Borderô ' || pr_nrborder || ' de Desconto de Título.';
      END IF;

      -- Verifica se Existe o Associado E Realiza as Validações sobre o Associado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;

      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_cdcritic := 9;
        vr_dscritic := '';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapass;
      --Limpar tabelas
      pr_tab_erro.DELETE;

      --Selecionar dados da data
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;
      -- Busca os dados da #TAB052
      DSCT0002.pc_busca_parametros_dsctit(pr_cdcooper          => pr_cdcooper
                                        ,pr_cdagenci          => null -- Não utiliza dentro da procedure
                                        ,pr_nrdcaixa          => null -- Não utiliza dentro da procedure
                                        ,pr_cdoperad          => null -- Não utiliza dentro da procedure
                                        ,pr_dtmvtolt          => null -- Não utiliza dentro da procedure
                                        ,pr_idorigem          => null -- Não utiliza dentro da procedure
                                        ,pr_tpcobran          => 1    -- Tipo de Cobrança: 0 = Sem Registro / 1 = Com Registro
                                        ,pr_inpessoa          => rw_crapass.inpessoa
                                        ,pr_tab_dados_dsctit  => vr_tab_dados_dsctit  --> Tabela contendo os parametros da cooperativa
                                        ,pr_tab_cecred_dsctit => vr_tab_cecred_dsctit --> Tabela contendo os parametros da cecred
                                        ,pr_cdcritic          => vr_cdcritic
                                        ,pr_dscritic          => vr_dscritic);

      -- Verificações Impeditivas Para Títulos
      FOR rw_craptdbcob IN cr_craptdbcob (pr_cdcooper => pr_cdcooper,
                                          pr_nrdconta => pr_nrdconta,
                                          pr_nrborder => pr_nrborder) LOOP
        IF rw_craptdbcob.dtvencto < pr_dtmvtolt THEN
          vr_dscritic := 'Há titulos com data de vencimento igual ou inferior a data do movimento.';
          RAISE vr_exc_erro;
        END IF;

        IF rw_craptdbcob.incobran = 5 THEN
          -- Se o Tìtulo já foi pago por COBRANÇA.
          vr_dscritic := 'Há títulos já pagos no Borderô.';
          raise vr_exc_erro;
        END IF;

        IF rw_craptdbcob.incobran = 3 THEN
          -- Se o Tìtulo já foi baixado por COBRANÇA.
          vr_dscritic := 'Há Títulos já baixados no Borderô.';
          raise vr_exc_erro;
        END IF;

        --Faz calculo de liquidez e concentracao e atualiza as criticas
        DSCT0002.pc_atualiza_calculos_pagador(pr_cdcooper => pr_cdcooper
                                                ,pr_nrdconta     => pr_nrdconta
                                                ,pr_nrinssac     => rw_craptdbcob.nrinssac
                                                ,pr_dtmvtolt_de  => rw_crapdat.dtmvtolt - vr_tab_dados_dsctit(1).qtmesliq*30
                                                ,pr_dtmvtolt_ate => rw_crapdat.dtmvtolt
                                                ,pr_qtcarpag     => vr_tab_dados_dsctit(1).cardbtit_c
                                                ,pr_qtmitdcl     => vr_tab_dados_dsctit(1).qtmitdcl
                                                ,pr_vlmintcl     => vr_tab_dados_dsctit(1).vlmintcl
                                                ,pr_flforcar     => FALSE
                                               --------------> OUT <--------------
                                               ,pr_pc_cedpag    => vr_ignora_numero
                                               ,pr_qtd_cedpag   => vr_ignora_numero
                                               ,pr_pc_conc      => vr_ignora_numero
                                               ,pr_qtd_conc     => vr_ignora_numero
                                               ,pr_cdcritic     => vr_cdcritic
                                               ,pr_dscritic     => vr_dscritic
                              );
        --Verifica se houve restrições no job diário
        OPEN cr_analise_pagador (pr_nrinssac=>rw_craptdbcob.nrinssac);
        FETCH cr_analise_pagador INTO rw_analise_pagador;
        IF (rw_analise_pagador.inpossui_criticas=1) THEN
          vr_indrestr := 1;
          pr_indrestr := 1;
        END IF;
        CLOSE cr_analise_pagador;

        IF (DSCT0003.fn_spc_serasa(pr_cdcooper=>pr_cdcooper,pr_nrdconta=>pr_nrdconta,pr_nrcpfcgc =>rw_craptdbcob.nrinssac) = 'S') THEN
          vr_indrestr := 1;
          pr_indrestr := 1;
        END IF;
      END LOOP;

      --Verifica se os Títulos estão em algum outro bordero
      pc_valida_tit_bordero(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrborder => pr_nrborder
                           ,pr_tpvalida => 1
                           ,pr_tab_erro => pr_tab_erro
                           ,pr_des_reto => vr_des_reto);

      -- Se o Tìtulo já está em um Borderô, Levanta a Exceção (Impeditivo)
      IF vr_des_reto  <> 'OK' THEN
        --Verifica se Foi Erro de Execução ou se o Título Estava mesmo em Outro Borderô
        IF (vr_tab_erro.COUNT = 0 AND vr_dscritic IS NOT NULL) THEN
          --Se o Erro foi de Execução
          vr_dscritic := 'Não foi possível validar os títulos do Borderô.';
        ELSE
          --Títulos Estavam em Outro Bordero
          vr_dscritic := 'O Cooperado já recebeu esse Título em um outro Borderô';
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
      -- Se NÃO encontrar registro DE LIMITE - Raise Excessão (IMPEDITIVO)
      IF cr_craplim%NOTFOUND THEN
        vr_dscritic := 'Registro de limites não encontrado.';
        CLOSE cr_craplim;
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craplim;
      END IF;

      -- Monta a mensagem da operacao para envio no e-mail
      vr_dsoperac := 'Tentativa de liberar/pré-analisar os borderôs ' ||
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
      -- Se retornou erro
      IF vr_des_reto <> 'OK' THEN
        vr_cdcritic := 0;
        vr_dscritic := vr_dscritic ||' - Não foi possível verificar o cadastro restritivo.';
        RAISE vr_exc_erro;
      END IF;

      -- INÍCIO DA GERAÇÃO DE RESTRIÇÕES
      IF pr_inrotina = 1 THEN -- (EXECUTAR APENAS QUANDO FOR: 0-APENAS IMPEDITIVOS / 1-IMPEDITIVOS+RESTRIÇÕES COM APROVAÇÃO DE ANÁLISE)
        -- pc_restricoes_tit_bordero
        -- Gera as Restrições do Borderô (CRAPABT)
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

        IF vr_indrestr = 0 AND pr_ind_inpeditivo = 0 THEN -- SEM RESTRIÇÃO E SEM IMPEDITIVOS, APROVADO AUTOMATICAMENTE.
          --Verificando se Ocorreram Restrições, para Gerar Crítica se Foi "Aprovado Automaticamente"
          --ou se deve verificar se vai para esteira ou mesa de checagem.
          pr_tab_retorno_analise(0).dssitres := 'Borderô Aprovado Automaticamente.';

          -- ALTERO STATUS DO BORDERÔ PARA APROVADO AUTOMATICAMENTE.
          pc_altera_status_bordero(pr_cdcooper => pr_cdcooper
                                  ,pr_nrborder => pr_nrborder
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_status   => 2 -- estou considerando 2 como aprovado automaticamente (aprovação de análise).
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_insitapr => 3
                                  ,pr_dtanabor => pr_dtmvtolt
                                  );
          IF vr_dscritic IS NOT NULL THEN
            pr_tab_retorno_analise.DELETE;
            RAISE vr_exc_erro;
          END IF;

          UPDATE craptdb
             SET craptdb.insitapr = 1
           WHERE craptdb.nrborder = pr_nrborder
             AND craptdb.cdcooper = pr_cdcooper
             AND craptdb.nrdconta = pr_nrdconta
             AND craptdb.insitapr = 0;

        ELSIF vr_indrestr > 0 AND pr_insborde = 0 THEN -- SE POSSUI RESTRIÇÃO, AVALIA SE DEVE MANDAR PARA ESTEIRA OU MESA DE CHECAGEM.
          -- Verifica se Possui Restrição de CNAE (nrseqdig=9)
          OPEN cr_crapabt_qtde (pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrborder => pr_nrborder
                               ,pr_nrseqdig => 9); -- 9 - nrseqdig de Restrição de CNAE
          --Posicionar no proximo registro
          FETCH cr_crapabt_qtde INTO rw_crapabt_qtde;
          -- Se encontrou, busca todos os títulos que possuem Restrição de CNAE, altera seus status enviando para
          -- a Mesa de Checagem, e altera o status do borderô para enviado para mesa de checagem, bem como seta seus campos
          -- de status de análise.
          IF (cr_crapabt_qtde%FOUND AND rw_crapbdt.dtenvmch IS NULL) THEN -- Possui crítica de CNAE E NÃO passou pela mesa ainda
            -- carrega todos os Títulos que estão com Restrição de CNAE (9)
            FOR rw_craptdb_restri IN
              cr_craptdb_restri (pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrborder => pr_nrborder
                                ,pr_nrseqdig => 9) LOOP
              -- aproveita o loop de títulos para fazer o envio para a mesa de checagem.
              UPDATE craptdb
                 set craptdb.insitapr = 0 -- 0-Aguardando Análise
                    ,craptdb.cdoriapr = 1 -- 1-Mesa de Checagem
                    ,craptdb.flgenvmc = 1 -- 1-Enviado
                    ,craptdb.insitmch = 0 -- 0-Nao realizado
               WHERE craptdb.rowid = rw_craptdb_restri.rowid;
            END LOOP;

            pr_tab_retorno_analise(0).dssitres := 'Borderô Enviado para Mesa de Checagem.';
            -- Altera o Borderô setando como enviado para a mesa de checagem.
            pc_altera_status_bordero(pr_cdcooper => pr_cdcooper -- Código da Cooperativa
                                    ,pr_nrborder => pr_nrborder -- Número do Borderô
                                    ,pr_nrdconta => pr_nrdconta -- Número da conta do cooperado
                                    ,pr_cdoperad => pr_cdoperad
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

            -- Verifica se tem críticas para o borderô. Se tiver  ele não atualiza nenhum título
            OPEN cr_check_crapabt;
            FETCH cr_check_crapabt INTO rw_check_crapabt;
            CLOSE cr_check_crapabt;
            IF (rw_check_crapabt.fl_critica_abt=0) THEN
              -- Caso tenha criticas mas alguns titulos nao tenham, aprovar os mesmos
              OPEN cr_check_craptdb;
              LOOP
               FETCH cr_check_craptdb INTO rw_check_craptdb;
                 EXIT WHEN cr_check_craptdb%NOTFOUND;
                 IF (rw_check_craptdb.fl_critica_abt = 0 AND rw_check_craptdb.fl_critica_pag = 0 AND rw_check_craptdb.fl_critica_biro = 0) THEN
                   UPDATE craptdb
                      SET insitapr = 1
                    WHERE ROWID = rw_check_craptdb.id;
                 END IF;
              END LOOP;
              CLOSE cr_check_craptdb;
            END IF;
          ELSE -- SE EXISTEM RESTRIÇÕES E NENHUMA É DE CNAE (9), ENVIAR PARA A ESTEIRA, CASO A ESTEIRA NÃO ESTEJA EM CONTINGÊNCIA.
            CLOSE cr_crapabt_qtde;
            rw_crapabt_qtde := null;

            vr_em_contingencia_ibratan := fn_contigencia_esteira(pr_cdcooper => pr_cdcooper);

            -- awae 25/04/2018 - Caso esteja em contingência, não será aprovado e nem enviado para esteira, e emite a mensagem de
            --                   que está em contingência.
            IF  vr_em_contingencia_ibratan THEN -- Em Contingência
              pr_tab_retorno_analise(0).dssitres := 'Análise em contingência, realize análise manual.';
            ELSE -- ESTEIRA ESTÁ EM FUNCIONAMENTO, ENVIAR
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
                pr_tab_retorno_analise(0).dssitres := 'Borderô Enviado para Esteira IBRATAN.';
              end if;
            END IF;

            -- Insere data de análise
            pc_altera_status_bordero(pr_cdcooper => pr_cdcooper -- Código da Cooperativa
                                    ,pr_nrborder => pr_nrborder -- Número do Borderô
                                    ,pr_nrdconta => pr_nrdconta -- Número da conta do cooperado
                                    ,pr_dtanabor => pr_dtmvtolt -- Data da analise
                                    ,pr_dscritic => vr_dscritic); -- Descricao Critica
            IF vr_dscritic IS NOT NULL THEN
              pr_tab_retorno_analise.DELETE;
              CLOSE cr_crapabt_qtde;
              RAISE vr_exc_erro;
            END IF;
            -- Verifica se tem críticas para o borderô. Se tiver  ele não atualiza nenhum título
            OPEN cr_check_crapabt;
            FETCH cr_check_crapabt INTO rw_check_crapabt;
            CLOSE cr_check_crapabt;
            IF (rw_check_crapabt.fl_critica_abt=0) THEN
            -- Caso tenha criticas mas alguns titulos nao tenham, aprovar os mesmos
              OPEN cr_check_craptdb;
              LOOP
               FETCH cr_check_craptdb INTO rw_check_craptdb;
                 EXIT WHEN cr_check_craptdb%NOTFOUND;
                 IF (rw_check_craptdb.fl_critica_abt = 0 AND rw_check_craptdb.fl_critica_pag = 0 AND rw_check_craptdb.fl_critica_biro = 0) THEN
                   UPDATE craptdb
                      SET insitapr = 1
                    WHERE ROWID = rw_check_craptdb.id;
                 END IF;
              END LOOP;
              CLOSE cr_check_craptdb;
            END IF;
          END IF;
        END IF;
      ELSE
        pr_indrestr := vr_indrestr;
        -- Verifica se tem críticas para o borderô. Se tiver  ele não atualiza nenhum título
        OPEN cr_check_crapabt_restricao;
        FETCH cr_check_crapabt_restricao INTO rw_check_crapabt_restricao;
        CLOSE cr_check_crapabt_restricao;
        IF (rw_check_crapabt_restricao.fl_critica_abt > 0) THEN
          pr_indrestr := 1;
        END IF;
      END IF; -- FIM DA GERAÇÃO DE RESTRIÇÕES
    --TRATAMENTO GERAL DE EXCEÇÕES DE EXECUÇÃO DA PC_EFETUA_ANALISE_BORDERO.
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

          -- Se Solicitou Geração de LOG
          IF pr_flgerlog THEN
            -- Chamar geração de LOG
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

  PROCEDURE pc_efetua_analise_bordero_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                          ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                           --  (OBRIGATÓRIOS E NESSA ORDEM SEMPRE)
                                          ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                          --------> OUT <--------
                                          ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
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
    Objetivo  : Procedure que que efetua a análise e Aprovação automática do Borderô.

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

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
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
         RAISE vr_exc_erro;
      END IF;

      -- Executar a Análise do Bordero
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
                                ,pr_inrotina => 1 -- 1-IMPEDITIVA+RESTRIÇÕES COM APROVAÇÃO DE ANÁLISE
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

      -- Chamar geração de LOG
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
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;

      -- Passou nas validações do bordero, do contrato e listou titulos. Começa a montar o xml
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

      -- liberando a memória alocada pro clob
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    exception
      when vr_exc_erro then
           --  se foi retornado apenas código
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               -- buscar a descriçao
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           -- variavel de erro recebe erro ocorrido
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;

           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           -- montar descriçao de erro não tratado
           pr_dscritic := 'erro não tratado na DSCT0003.pc_efetua_analise_bordero_web ' ||sqlerrm;
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

     Alteracoes: 15/04/2018 - Criação (Paulo Penteado (GFT))

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
           vr_dscritic := 'Não foi possível carregar a tarifa.';
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

  PROCEDURE pc_lanca_tarifa_bordero (pr_cdcooper IN crapbdt.cdcooper%TYPE --> Código da Cooperativa
                                    ,pr_nrdconta IN crapbdt.nrdconta%TYPE  --> Número da Conta
                                    ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                    ,pr_cdagenci IN crapbdt.cdagenci%type --> Código da Agência
                                    ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Numero Caixa
                                    ,pr_cdoperad IN crapbdt.cdoperad%TYPE --> Operador
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                    ,pr_vlborder IN NUMBER                --> Valor do Borderô
                                    ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                                    ,pr_idorigem IN VARCHAR2              --> Identificador Origem pagamento
                                    ,pr_dscritic OUT VARCHAR2             --> Descriçao da crítica
                            ) IS
  BEGIN
   /*-------------------------------------------------------------------------------------------------------
     Programa : pc_lanca_tarifa_bordero        Antigo: b1wgen0030.p/efetua_liber_anali_bordero (Trecho de Liberação)
     Sistema  : Procedure para lançar a tarifa de borderô de desconto de Tìtulo
     Sigla    : CRED
     Autor    : Andrew Albuquerque (GFT)
     Data     : Abril/2018

     Objetivo  : Procedure para lançar tarifa

     Alteracoes: 16/04/2018 - Criação (Andrew Albuquerque (GFT))
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
      SELECT c.cdpactra -- Código de Departamento do Operador.
        FROM crapope c
       WHERE c.cdcooper = pr_cdcooper
         AND c.cdoperad = pr_cdoperad;
      rw_crapope cr_crapope%ROWTYPE;

    BEGIN

      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'DSCT0003.pc_lanca_tarifa_bordero');

      -- busca o Código de Departamento do Operador para utilizar como parâmetro interno da procedure.
      vr_cdpactra := 0;
      FOR rw_crapope IN
          cr_crapope (pr_cdcooper => pr_cdcooper,
                      pr_cdoperad => pr_cdoperad) LOOP
        vr_cdpactra := rw_crapope.cdpactra;
      END LOOP;

      --Buscar a Tarifa de Desconto para os Títulos
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

      -- Se encontrou Tarifa, Inícia o Lançamento das Tarifas.
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
                                            ,pr_qtoperac => 1  -- Quantidade de Operações
                                            ,pr_qtacobra => vr_qtacobra -- Quantidade de Operações a Serem Cobradas
                                            ,pr_fliseope => vr_fliseope -- Indicador de isencao de tarifa (0 - nao isenta, 1 - isenta)
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

        -- SE NÃO É ISENTO DE TARIFA
        IF vr_fliseope <> 1 THEN

          -- Criar lançamento automático da tarifa
          tari0001.pc_cria_lan_auto_tarifa(pr_cdcooper => pr_cdcooper           --> Codigo Cooperativa
                                          ,pr_nrdconta => pr_nrdconta           --> Numero da Conta
                                          ,pr_dtmvtolt => pr_dtmvtolt           --> Data Lancamento
                                          ,pr_cdhistor => vr_cdhistor           --> Codigo Historico
                                          ,pr_vllanaut => vr_vltarifa           --> Valor lancamento automatico
                                          ,pr_cdoperad => pr_cdoperad           --> Codigo Operador
                                          ,pr_cdagenci => pr_cdagenci           --> Codigo Agencia
                                          ,pr_cdbccxlt => 100                   --> Codigo banco caixa
                                          ,pr_nrdolote => 1900 + vr_cdpactra    --> Numero do lote
                                          ,pr_tpdolote => 1                     --> Tipo do lote (35 - Título)
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


          IF  NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL then
             IF  vr_tab_erro.count() > 0 THEN
                 vr_dscritic:= vr_tab_erro(vr_tab_erro.first).dscritic;
             ELSE
                 vr_dscritic:= 'Erro no Lançamento da Tarifa de Borderô de Desconto de Título';
             END IF;

             RAISE vr_exc_erro;
          END IF;
        END IF;

      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN

         IF  nvl(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
             pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         ELSE
        pr_dscritic := vr_dscritic;
         END IF;


      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        pr_dscritic := 'Erro no Lançamento da Tarifa de Borderô de Desconto de Título' || SQLERRM;

    END;
  END pc_lanca_tarifa_bordero;

  PROCEDURE pc_lanca_credito_bordero(pr_dtmvtolt IN craplcm.dtmvtolt%TYPE -- Origem: do lote de liberação (craplot)
                                    ,pr_cdagenci IN craplcm.cdagenci%TYPE -- Origem: do lote de liberação (craplot)
                                    ,pr_cdbccxlt IN craplcm.cdbccxlt%TYPE -- Origem: do lote de liberação (craplot)
                                    ,pr_nrdconta IN craplcm.nrdconta%TYPE -- Origem: nrdconta do Bordero
                                    ,pr_vllanmto IN craplcm.vllanmto%TYPE -- Origem: do cálculo :aux_vlborder + craptdb.vlliquid da linha 1870.
                                    ,pr_cdcooper IN craplcm.cdcooper%TYPE
                                    ,pr_cdoperad IN crapbdt.cdoperad%TYPE --> Operador
                                    ,pr_nrborder IN crapbdt.nrborder%TYPE -- Origem: Bordero
                                    ,pr_lcmrowid OUT ROWID   --> ROWID da inserção da LCM
                                    ,pr_dscritic    OUT VARCHAR2          --> Descricao Critica
                                    ) IS
  BEGIN

   /*-------------------------------------------------------------------------------------------------------
     Programa : pc_lanca_credito_bordero        Antigo: b1wgen0030.p/efetua_liber_anali_bordero (Trecho de Liberação)
     Sistema  : Procedure para lançar crédito de desconto de Título
     Sigla    : CRED
     Autor    : Andrew Albuquerque (GFT)
     Data     : Abril/2018

     Objetivo  : Procedure para laçamento de crédito de desconto de Título.

     Alteracoes: 16/04/2018 - Criação (Andrew Albuquerque (GFT))
                 05/02/2019 - Adicionado tratativa de confirmação de inserção na tabela craplot e craplcm (Cássia de Oliveira - GFT)
                 21/03/2019 - Adicionado uma verificação na prm CHECK_CREDITO_DSCT_TIT antes de fazer a tratativa de confirmação do insert
                              corretamente na craplot e craplcm (Paulo Penteado GFT / Daniel Zimmermann)
                 14/05/2019 - Adicionado contador para limitar o numero de tentativas de inserção da craplot. (Vitor S. Assanuma - GFT)
   ----------------------------------------------------------------------------------------------------------*/
    DECLARE

    vr_nrdolote craplot.nrdolote%TYPE;

    vr_nrseqdig craplot.nrseqdig%TYPE;

    -- Variável de críticas
    vr_dscritic VARCHAR2(10000);

    vr_exc_erro exception;

    rw_craplot cr_craplot%ROWTYPE;

    vr_flg_criou_lot BOOLEAN;

    vr_tentativas_lot INTEGER;

    BEGIN

      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'DSCT0003.pc_lanca_credito_bordero');

      vr_flg_criou_lot:=FALSE;
      vr_tentativas_lot := 0;
      -- Insere um lote novo
      WHILE NOT vr_flg_criou_lot LOOP

        vr_nrdolote := fn_sequence(pr_nmtabela => 'CRAPLOT'
                                  ,pr_nmdcampo => 'NRDOLOTE'
                                  ,pr_dsdchave => TO_CHAR(pr_cdcooper)|| ';'
                                               || TO_CHAR(pr_dtmvtolt, 'DD/MM/RRRR') || ';'
                                               || TO_CHAR(pr_cdagenci)|| ';'
                                               || '100');

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
                        ,pr_cdagenci
                        ,100
                        ,vr_nrdolote
                        ,1
                        ,pr_cdoperad
                        ,vr_cdhistordsct_credito)
          RETURNING nrseqdig
                        ,ROWID
               INTO rw_craplot.nrseqdig
                        ,rw_craplot.rowid;
           EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            --Incrementa em um a tentativa, caso passe de 10 tentativas, chama exceção, senão tenta novamente
            vr_tentativas_lot := vr_tentativas_lot + 1;
            IF (vr_tentativas_lot > 10) THEN
              vr_dscritic := 'Erro ao inserir novo lote (1), tentativas excedidas ' || SQLERRM;
              RAISE vr_exc_erro;
            END IF;

            CONTINUE;
          WHEN OTHERS THEN
            -- Gera crítica
            vr_dscritic := 'Erro ao inserir novo lote (1) ' || SQLERRM;
            -- Levanta exceção
            RAISE vr_exc_erro;
        END;

        vr_flg_criou_lot := TRUE;

      END LOOP;


      BEGIN
        vr_nrseqdig := NVL(rw_craplot.nrseqdig,0) + 1;
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
        VALUES (/*01*/ pr_dtmvtolt
               ,/*02*/ pr_cdagenci
               ,/*03*/ 100
               ,/*04*/ vr_nrdolote
               ,/*05*/ pr_nrdconta
               ,/*06*/ vr_nrseqdig
               ,/*07*/ pr_vllanmto --  do cálculo :aux_vlborder + craptdb.vlliquid da linha 1870.
               ,/*08*/ vr_cdhistordsct_credito
               ,/*09*/ vr_nrseqdig
               ,/*10*/ pr_nrdconta
               ,/*11*/ 0
               ,/*12*/ pr_cdcooper
               ,/*13*/ 'Desconto do Borderô ' || pr_nrborder)
        RETURNING ROWID INTO pr_lcmrowid;
      EXCEPTION
        WHEN OTHERS THEN
          -- Monta critica
          vr_dscritic := 'Erro Lancamento de Credito (2): ' || SQLERRM;
          -- Gera exceção
          RAISE vr_exc_erro;
      END;

      BEGIN
        UPDATE craplot
           SET craplot.nrseqdig = NVL(craplot.nrseqdig,0) + 1
              ,craplot.qtinfoln = NVL(craplot.qtinfoln,0) + 1
              ,craplot.qtcompln = NVL(craplot.qtcompln,0) + 1
              ,craplot.vlinfocr = NVL(craplot.vlinfocr,0) + pr_vllanmto
              ,craplot.vlcompcr = NVL(craplot.vlcompcr,0) + pr_vllanmto
         WHERE craplot.rowid = rw_craplot.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          -- Monta critica
          vr_dscritic := 'Erro ao atualizar o Lote (3): ' || SQLERRM;
          -- Gera exceção
          RAISE vr_exc_erro;
      END;

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);

        pr_dscritic := 'Erro Lancamento de Credito (4): ' || SQLERRM;
    END;
  END pc_lanca_credito_bordero;

  PROCEDURE pc_liberar_bordero (pr_cdcooper IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                               ,pr_cdagenci IN crapass.cdagenci%type --> Código da Agência
                               ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Numero Caixa
                               ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                               ,pr_nmdatela IN craplgm.nmdatela%TYPE --> Nome da tela.
                               ,pr_idorigem IN VARCHAR2              --> Identificador Origem pagamento
                               ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                               ,pr_nrborder IN crapbdt.nrborder%TYPE --> numero do bordero
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                               ,pr_flgerlog IN BOOLEAN               --> identificador se deve gerar log
                               --------> OUT <--------
                               ,pr_vltotliq OUT NUMBER
                               ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela Erros
                               ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descriçao da crítica
                               ) IS
   /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_liberar_bordero
    Sistema  : Cred
    Sigla    :
    Autor    : Lucas Lazari (GFT)
    Data     : Abril/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Procedure que libera o borderô de desconto de títulos

    Alteração : ??/04/2018 - Criação (Lucas Lazari (GFT))
                24/05/2018 - Adicionado inserção do lançamento do bordero. Alterado o código do histórico da craplcm de
                             liberação para o novo código criado pelo contabilidade (Paulo Penteado (GFT))
                05/02/2019 - Adicionado logs mais detalhados (Cássia de Oliveira - GFT)
                15/05/2019 - Adicionado verificação se a LCM foi gerada com sucesso ou não (Vitor S. Assanuma - GFT)
  ---------------------------------------------------------------------------------------------------------------------*/

  BEGIN
    DECLARE

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    --Tabela erro
    vr_tab_erro GENE0001.typ_tab_erro;

    -- rowid tabela de log
    vr_nrdrowid ROWID;

    -- Variáveis de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    vr_vltotbrt     NUMBER;
    vr_vltxiofatra  NUMBER; --> Valor total IOF Atraso
    vr_vltotjur     NUMBER;
    vr_lcmrowid     ROWID;

  BEGIN

    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'DSCT0003.pc_liberar_bordero');

    --Seta as variáveis de Descrição de Origem e descrição de Transação se For gerar Log
    IF pr_flgerlog THEN
      -- Chamar geração de LOG
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                          ,pr_dstransa => 'Liberação do Bordero ' || pr_nrborder || ' de Desconto de Título.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'ATENDA'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    END IF;

    pr_tab_erro.DELETE;

    -- Calcula os valores do borderô (líquido e bruto)
    pc_calcula_valores_bordero (pr_cdcooper => pr_cdcooper
                               ,pr_nrborder => pr_nrborder
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_cdoperad => pr_cdoperad
                               ,pr_dtmvtolt => pr_dtmvtolt
                               ,pr_vltotliq => pr_vltotliq
                               ,pr_vltotbrt => vr_vltotbrt
                               ,pr_vltotjur => vr_vltotjur
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);

    IF (vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL) THEN
      RAISE vr_exc_erro;
    END IF;


    IF pr_flgerlog THEN
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Liberação Bordero'
                               ,pr_dsdadant => ''
                               ,pr_dsdadatu => 'Calcula os valores do borderô (líquido e bruto) ' ||
                                vr_dscritic);
    END IF;

    -- Busca e lança a tarifa vigente do borderô de desconto de títulos
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

    IF pr_flgerlog THEN
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Liberação Bordero'
                               ,pr_dsdadant => ''
                               ,pr_dsdadatu => 'Busca e lança a tarifa vigente do borderô de desconto de títulos ' ||
                                vr_dscritic);
    END IF;

    -- Calcula e lança o valor do IOF
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

    IF (vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL) THEN
      RAISE vr_exc_erro;
    END IF;

    IF pr_flgerlog THEN
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Liberação Bordero'
                               ,pr_dsdadant => ''
                               ,pr_dsdadatu => 'Calcula e lança o valor do IOF ' ||
                                vr_dscritic);
    END IF;



    -- Lança o crédito do valor líquido do borderô na conta corrente do cooperado
    pc_lanca_credito_bordero(pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdagenci => pr_cdagenci
                            ,pr_cdbccxlt => 100
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_vllanmto => pr_vltotliq
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_nrborder => pr_nrborder
                            ,pr_lcmrowid => vr_lcmrowid
                            ,pr_dscritic => vr_dscritic );

    -- Verifica se foi gerado uma ROWID para a inserção da lcm
    IF vr_lcmrowid IS NULL THEN
      vr_dscritic := 'Erro ao lançar crédito na conta corrente do cooperado, lcm não gerada.';
    END IF;

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    IF pr_flgerlog THEN
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Liberação Bordero'
                               ,pr_dsdadant => ''
                               ,pr_dsdadatu => 'Lança o crédito do valor líquido do borderô na conta corrente do cooperado ' ||vr_dscritic);
    END IF;



    -- Lançar operação de desconto, valor bruto do borderô
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

    IF pr_flgerlog THEN
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Liberação Bordero'
                               ,pr_dsdadant => ''
                               ,pr_dsdadatu => 'Lançar operação de desconto, valor bruto do borderô ' ||
                                vr_dscritic);
    END IF;

    -- Lançar operação de desconto, valor do juros calculado
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

    IF pr_flgerlog THEN
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Liberação Bordero'
                               ,pr_dsdadant => ''
                               ,pr_dsdadatu => 'Lançar operação de desconto, valor do juros calculado ' ||
                                vr_dscritic);
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

    IF pr_flgerlog THEN
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Liberação Bordero'
                               ,pr_dsdadant => ''
                               ,pr_dsdadatu => 'Atualiza Bordero ' ||
                                vr_dscritic);
    END IF;


    EXCEPTION
     WHEN vr_exc_erro THEN

          IF  NVL(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
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
          ELSE
              pr_cdcritic := NVL(vr_cdcritic,0);
              pr_dscritic := REPLACE(REPLACE(vr_dscritic,chr(13)),chr(10));
          END IF;

    WHEN OTHERS THEN

         cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);

         pr_cdcritic := vr_cdcritic;
         pr_dscritic := REPLACE(REPLACE('Erro pc_liberar_bordero: ' || SQLERRM, chr(13)),chr(10));

    END;

  END pc_liberar_bordero;


  PROCEDURE pc_liberar_bordero_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                   ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                   ,pr_confirma IN PLS_INTEGER            --> numero do bordero
                                   ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                   --------> OUT <--------
                                   ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
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
    Objetivo  : Procedure que que efetua a análise e Aprovação automática do Borderô.
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

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
    vr_dscritic varchar2(1000);        --> Desc. Erro

    vr_tab_retorno_analise typ_tab_retorno_analise;

    -- Variaveis auxiliares
    vr_flgfound     BOOLEAN;
    vr_vlendivid    craplim.vllimite%TYPE; -- Valor do Endividamento do Cooperado
    vr_vllimrating  craplim.vllimite%TYPE; -- Valor do Parametro Rating (Limite) TAB056
    -- rowid tabela de log
    vr_nrdrowid ROWID;

    vr_possuicnae  INTEGER;
    vr_enviadomesa INTEGER;
    vr_flsnhcoo BOOLEAN;

    -- Retorna dos dados do contrato
    vr_tab_dados_limite  TELA_ATENDA_DSCTO_TIT.typ_tab_dados_limite;

    -- Selecionar bordero titulo
    CURSOR cr_crapbdt (pr_cdcooper crapbdt.cdcooper%TYPE,
                       pr_nrborder crapbdt.nrborder%TYPE) IS
    SELECT crapbdt.cdcooper,
           crapbdt.nrborder,
           crapbdt.nrdconta,
           crapbdt.insitbdt,
           crapbdt.insitapr,
           crapbdt.dtenvmch,
           crapbdt.nrctrlim
      FROM crapbdt
     WHERE crapbdt.cdcooper = pr_cdcooper
       AND crapbdt.nrborder = pr_nrborder;
    rw_crapbdt cr_crapbdt%ROWTYPE;

    -- Informações de data do sistema
    rw_crapdat  btch0001.rw_crapdat%TYPE;

    -- Verifica Conta
    CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT dtelimin
            ,cdsitdtl
            ,cdagenci
           ,nrcpfcnpj_base
       FROM crapass
      WHERE crapass.cdcooper = pr_cdcooper
        AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    vr_habrat VARCHAR2(1) := 'N'; -- P450 - Paramentro para Habilitar Novo Ratin (S/N)

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

      vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                             pr_cdcooper => vr_cdcooper,
                                             pr_cdacesso => 'HABILITA_RATING_NOVO');

      --Selecionar dados da data
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      -- Verifica se existe a conta
      OPEN cr_crapass (vr_cdcooper, pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      vr_flgfound := cr_crapass%FOUND;
      CLOSE cr_crapass;
      -- Se nao existir
      IF NOT vr_flgfound THEN
        vr_cdcritic := 9;
        RAISE vr_exc_erro;
      END IF;

       -- Busca dados do contrato ativo
      TELA_ATENDA_DSCTO_TIT.pc_busca_dados_limite(pr_nrdconta
                                                 ,vr_cdcooper
                                                 ,3 -- desconto de titulo
                                                 ,2 -- apenas ativo
                                                 ,rw_crapdat.dtmvtolt
                                                 --------> OUT <--------
                                                 ,vr_tab_dados_limite
                                                 ,vr_cdcritic
                                                 ,vr_dscritic);
      IF (vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL) THEN
         RAISE vr_exc_erro;
      END IF;

      -- Dados do Bordero
      OPEN cr_crapbdt(pr_cdcooper => vr_cdcooper
                     ,pr_nrborder => pr_nrborder);
      FETCH cr_crapbdt INTO rw_crapbdt;

      IF (cr_crapbdt%NOTFOUND) THEN
        CLOSE cr_crapbdt;
        vr_dscritic := 'Borderô inválido';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapbdt;
      END IF;

      IF (rw_crapbdt.nrctrlim<>vr_tab_dados_limite(0).nrctrlim) THEN
        vr_dscritic := 'O contrato deste borderô não se encontra mais ativo.';
        RAISE vr_exc_erro;
      END IF;

      -- Inicia Variável de msg de contingência.
      --vr_msgcontingencia := '';
      vr_msgretorno := '';

      -- Valida se a situação do borderô permite liberação
      pc_valida_bordero(pr_cdcooper => vr_cdcooper
                       ,pr_nrborder => pr_nrborder
                       ,pr_cddeacao => 'LIBERAR'
                       ,pr_dscritic => vr_dscritic);

      IF (vr_dscritic IS NOT NULL) THEN
         RAISE vr_exc_erro;
      END IF;

      -- Analisa o borderô para verificar se não há nenhuma crítica impeditiva para a liberação
      pc_efetua_analise_bordero (pr_cdcooper => vr_cdcooper
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_idorigem => vr_idorigem
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_idseqttl => 1
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                ,pr_dtmvtopr => rw_crapdat.dtmvtopr
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
                                ,pr_dscritic => vr_dscritic);

      IF (vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL) THEN
         RAISE vr_exc_erro;
      END IF;

        -- Se o borderô possui restrições e o operador está tentando liberar pela primeira vez, retorna a mensagem abaixo
        IF vr_indrestr = 1 AND pr_confirma = 0 THEN
          vr_msgretorno := 'Há restrições no borderô. Deseja realizar a liberação mesmo assim?';
        ELSE
          -- Gera as Restrições do Borderô (CRAPABT)
          pc_restricoes_tit_bordero( pr_cdcooper => vr_cdcooper
                              ,pr_cdagenci =>  vr_cdagenci
                              ,pr_nrdcaixa =>  vr_nrdcaixa
                              ,pr_cdoperad =>  vr_cdoperad
                              ,pr_nmdatela =>  vr_nmdatela
                              ,pr_idorigem =>  vr_idorigem
                              ,pr_dtmvtolt =>  rw_crapdat.dtmvtolt
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
           RAISE vr_exc_erro;
          END IF;

          -- Verifica se possui critica CNAE e se já foi enviado para a mesa de checagem
        SELECT COUNT(*)
          INTO vr_possuicnae
          FROM crapabt
         WHERE cdcooper = vr_cdcooper
           AND nrborder = pr_nrborder
           AND nrseqdig = 9; -- CNAE

        SELECT CASE
                 WHEN dtenvmch IS NULL THEN
                  0
                 ELSE
                  1
               END
          INTO vr_enviadomesa
          FROM crapbdt
         WHERE cdcooper = vr_cdcooper
           AND nrborder = pr_nrborder; -- CNAE

          IF vr_possuicnae > 0 AND vr_enviadomesa = 0 THEN
            vr_dscritic := 'Borderô com críticas, aguarde retorno de análise da sede.';
            RAISE vr_exc_erro;
          END IF;

          -- Caso o operador tenha decidido liberar o borderô (com ou sem restrições) chama a rotina principal de liberação do borderô
          pc_liberar_bordero  (pr_cdcooper => vr_cdcooper
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_idorigem => vr_idorigem
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrborder => pr_nrborder
                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                              ,pr_vltotliq => vr_vltotliq
                              ,pr_flgerlog => FALSE
                              ,pr_tab_erro => vr_tab_erro
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

          IF (vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL) THEN
           RAISE vr_exc_erro;
          END IF;


          -- Salva a ultima imagem das % de liquidez do bordero na CRAPABT
          pc_grava_restricoes_liberacao(pr_cdcooper => vr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrborder => pr_nrborder
                                       ,pr_cdoperad => vr_cdoperad
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);


          IF (vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL) THEN
           RAISE vr_exc_erro;
          END IF;

          -- Ajusta a mensagem de confirmação conforme a existência de restrições no borderô
          IF vr_indrestr = 1 THEN
             vr_msgretorno := 'Borderô liberado COM restrições! Valor líquido de R$' || TRIM(to_char(vr_vltotliq, 'FM999G999G999G990D00'));
          ELSE
             vr_msgretorno := 'Borderô liberado SEM restrições! Valor líquido de R$' || TRIM(to_char(vr_vltotliq, 'FM999G999G999G990D00'));
          END IF;

          -- Atualiza a decisão do borderô
          UPDATE crapbdt
             SET insitapr = 4,
                 dtaprova = rw_crapdat.dtmvtolt,
                 hraprova = to_char(SYSDATE, 'SSSSS'),
                 cdopeapr = vr_cdoperad
           WHERE crapbdt.nrborder = pr_nrborder
             AND crapbdt.nrdconta = pr_nrdconta
             AND crapbdt.cdcooper = vr_cdcooper;

          -- P450 SPT13 - alteracao para habilitar rating novo
          IF (vr_cdcooper <> 3 AND vr_habrat = 'S') THEN
            -- Buscar Valor Endividamento e Valor Limite Rating (TAB056)
            RATI0003.pc_busca_endivid_param(pr_cdcooper => vr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_vlendivi => vr_vlendivid
                                           ,pr_vlrating => vr_vllimrating
                                           ,pr_dscritic => vr_dscritic);
            IF TRIM(vr_dscritic) IS NOT NULL THEN
               RAISE vr_exc_erro;
            END IF;

            -- Se Endividamento + Contrato atual > Parametro Rating (TAB056)
            IF (vr_vlendivid > vr_vllimrating)  THEN

              -- Gravar o Rating da operação, efetivando-o
              rati0003.pc_grava_rating_operacao(pr_cdcooper          => vr_cdcooper
                                               ,pr_nrdconta          => pr_nrdconta
                                               ,pr_tpctrato          => 3
                                               ,pr_nrctrato          => rw_crapbdt.nrctrlim
                                               ,pr_dtrating          => rw_crapdat.dtmvtolt
                                               ,pr_strating          => 4
                                               --Variáveis para gravar o histórico
                                               ,pr_cdoperad          => vr_cdoperad
                                               ,pr_dtmvtolt          => rw_crapdat.dtmvtolt
                                               ,pr_valor             => NULL  --pr_vllimite
                                               ,pr_rating_sugerido   => NULL
                                               ,pr_justificativa     => 'Efetivação do rating'
                                               ,pr_tpoperacao_rating => 2
                                               ,pr_nrcpfcnpj_base    => rw_crapass.nrcpfcnpj_base
--                                             --Variáveis de crítica
                                               ,pr_cdcritic          => vr_cdcritic
                                               ,pr_dscritic          => vr_dscritic);

              IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;
            END IF;

            rati0003.pc_grava_rating_bordero(pr_cdcooper => vr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_nrctro   => rw_crapbdt.nrctrlim
                                            ,pr_tpctrato => 2
                                            ,pr_nrborder => pr_nrborder
                                            ,pr_cdoperad => vr_cdoperad
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
            IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;

          END IF;
    -- P450 SPT13 - alteracao para habilitar rating novo

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
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;

      -- Passou nas validações do bordero, do contrato e listou titulos. Começa a montar o xml
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||

                     '<root><dados>');

      pc_escreve_xml('<msgretorno>' || vr_msgretorno || '</msgretorno>');
      pc_escreve_xml('<indrestr>' || vr_indrestr || '</indrestr>');

      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      -- liberando a memória alocada pro clob
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    EXCEPTION
      WHEN vr_exc_erro THEN
           -- se foi retornado apenas código
           IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
               -- buscar a descriçao
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           END IF;
           -- variavel de erro recebe erro ocorrido
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;

           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root>' ||
                                             '<Erro>' || pr_dscritic || '</Erro>' ||
                                          '</Root>');
            ROLLBACK;
      WHEN OTHERS THEN
           -- montar descriçao de erro não tratado
           pr_dscritic := 'Erro não tratado na dsct0003.pc_liberar_bordero_web ' ||SQLERRM;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
           ROLLBACK;
   END pc_liberar_bordero_web;

   PROCEDURE pc_grava_restricoes_liberacao (pr_cdcooper IN crapbdt.cdcooper%TYPE --> Cooperativa
                                           ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                                           ,pr_nrborder IN crapbdt.nrborder%TYPE --> numero do bordero
                                           ,pr_cdoperad IN crapcob.cdoperad%TYPE --> Operador que solicitou a consulta
                                            --------> OUT <--------
                                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                           ) IS
       /*---------------------------------------------------------------------------------------------------------------------
         Programa : pc_grava_restricoes_liberacao
         Sistema  :
         Sigla    : CRED
         Autor    : Vitor Shimada Assanuma (GFT)
         Data     : 09/06/2018
         Frequencia: Sempre que for chamado
         Objetivo  : Salvar a ultima imagem das restrições ao liberar um borderô
       ---------------------------------------------------------------------------------------------------------------------*/
        -- tratamento de erro
        vr_exc_erro exception;

        -- Variáveis de críticas
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic VARCHAR2(10000);

       -- Cursor genérico de calendário
       rw_crapdat btch0001.cr_crapdat%ROWTYPE;

       -- Titulos (Boletos de Cobrança)
       CURSOR cr_crapcob (pr_nrdocmto IN crapcob.nrdocmto%TYPE
                         ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                         ,pr_nrdctabb IN crapcob.nrdctabb%TYPE
                         ,pr_cdbandoc IN crapcob.cdbandoc%TYPE) is
       SELECT cob.cdcooper,
              cob.nrdconta,
              cob.nrinssac,
              cob.nrnosnum,
              cob.cdtpinsc, -- Tipo Pesso do Pagador (0-Nenhum/1-CPF/2-CNPJ)
              cob.nrdocmto,
              cob.nrcnvcob,
              cob.nrdctabb,
              cob.cdbandoc
         FROM crapcob cob
        WHERE cob.cdcooper = pr_cdcooper -- Cooperativa
          AND cob.nrdconta = pr_nrdconta -- Conta
          AND cob.nrdocmto = pr_nrdocmto
          AND cob.nrcnvcob = pr_nrcnvcob
          AND cob.nrdctabb = pr_nrdctabb
          AND cob.cdbandoc = pr_cdbandoc
          AND cob.incobran = 0;
       rw_crapcob cr_crapcob%ROWTYPE;

       -- Pega todos os titulos daquele bordero independente de status
       CURSOR cr_craptdb IS
       SELECT *
         FROM craptdb t
        WHERE t.nrdconta = pr_nrdconta
          AND t.nrborder = pr_nrborder
          AND t.cdcooper = pr_cdcooper;
       rw_craptdb cr_craptdb%ROWTYPE;

       -- Verifica Conta (Cadastro de associados)
       CURSOR cr_crapass IS
       SELECT inpessoa
         FROM crapass
        WHERE crapass.cdcooper = pr_cdcooper
          AND crapass.nrdconta = pr_nrdconta;
       rw_crapass cr_crapass%ROWTYPE;

       -- Retorno da #TAB052
       vr_tab_dados_dsctit    dsct0002.typ_tab_dados_dsctit;
       vr_tab_cecred_dsctit   dsct0002.typ_tab_cecred_dsctit;

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
       -- Leitura do calendário da cooperativa
       OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH btch0001.cr_crapdat into rw_crapdat;
       CLOSE btch0001.cr_crapdat;

       -- Busca tipo de pessoa
       OPEN cr_crapass;
       FETCH cr_crapass INTO rw_crapass;
       CLOSE cr_crapass;

       -- Busca os dados da #TAB052
       DSCT0002.pc_busca_parametros_dsctit(pr_cdcooper          => pr_cdcooper
                                          ,pr_cdagenci          => null -- Não utiliza dentro da procedure
                                          ,pr_nrdcaixa          => null -- Não utiliza dentro da procedure
                                          ,pr_cdoperad          => null -- Não utiliza dentro da procedure
                                          ,pr_dtmvtolt          => null -- Não utiliza dentro da procedure
                                          ,pr_idorigem          => null -- Não utiliza dentro da procedure
                                          ,pr_tpcobran          => 1    -- Tipo de Cobrança: 0 = Sem Registro / 1 = Com Registro
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

          dsct0002.pc_atualiza_calculos_pagador (pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => rw_crapcob.nrdconta
                                      ,pr_nrinssac => rw_crapcob.nrinssac
                                      ,pr_dtmvtolt_de => rw_crapdat.dtmvtolt - vr_tab_dados_dsctit(1).qtmesliq*30
                                      ,pr_dtmvtolt_ate => rw_crapdat.dtmvtolt
                                      ,pr_qtcarpag => vr_tab_dados_dsctit(1).cardbtit_c
                                      ,pr_qttliqcp => vr_tab_dados_dsctit(1).qttliqcp
                                      ,pr_vltliqcp => vr_tab_dados_dsctit(1).vltliqcp
                                      ,pr_pcmxctip => vr_tab_dados_dsctit(1).pcmxctip
                                      ,pr_qtmitdcl => vr_tab_dados_dsctit(1).qtmitdcl
                                      ,pr_vlmintcl => vr_tab_dados_dsctit(1).vlmintcl
                                      ,pr_flforcar => FALSE
                                      --------------> OUT <--------------
                                      ,pr_pc_cedpag  => vr_liqpagcd
                                      ,pr_qtd_cedpag => vr_qtd_cedpag
                                      ,pr_pc_conc    => vr_concpaga
                                      ,pr_qtd_conc   => vr_qtd_conc
                                      ,pr_cdcritic   => vr_cdcritic
                                      ,pr_dscritic   => vr_dscritic
                                      );

         -- Salva as informações da CRAPABT => CONCENTRACAO
         pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                         ,pr_cdoperad => pr_cdoperad
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_dsrestri => ''
                         ,pr_nrseqdig => 18 -- Concentracao
                         ,pr_cdcooper => pr_cdcooper
                         ,pr_flaprcoo => 1
                         ,pr_dsdetres => (TRIM(to_char(NVL(vr_concpaga,0), 'FM999G999G999G990D00'))) -- Concentracao
                         ,pr_nrdocmto => rw_craptdb.nrdocmto   -- Conta
                         ,pr_nrcnvcob => rw_craptdb.nrcnvcob   -- Convenio
                         ,pr_nrdctabb => rw_craptdb.nrdctabb   -- Conta base do banco
                         ,pr_cdbandoc => rw_craptdb.cdbandoc
                         ,pr_dscritic => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;

         -- Salva as informações da CRAPABT => CEDENTE PAGADOR
         pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                         ,pr_cdoperad => pr_cdoperad
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_dsrestri => ''
                         ,pr_nrseqdig => 19 --Liquidez Cedente Pagador
                         ,pr_cdcooper => pr_cdcooper
                         ,pr_flaprcoo => 1
                         ,pr_dsdetres => (TRIM(to_char(NVL(vr_liqpagcd,0), 'FM999G999G999G990D00'))) -- Porcentagem da Cedente Pagador
                         ,pr_nrdocmto => rw_craptdb.nrdocmto   -- Conta
                         ,pr_nrcnvcob => rw_craptdb.nrcnvcob   -- Convenio
                         ,pr_nrdctabb => rw_craptdb.nrdctabb   -- Conta base do banco
                         ,pr_cdbandoc => rw_craptdb.cdbandoc
                         ,pr_dscritic => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;

        -- Faz os calculos de liquidez
        pc_retorna_liquidez_geral(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_dtmvtolt_de =>  rw_crapdat.dtmvtolt - vr_tab_dados_dsctit(1).qtmesliq*30
                           ,pr_dtmvtolt_ate => rw_crapdat.dtmvtolt
                           ,pr_qtcarpag => vr_tab_dados_dsctit(1).cardbtit_c
                           ,pr_qtmitdcl => vr_tab_dados_dsctit(1).qtmitdcl
                           ,pr_vlmintcl => vr_tab_dados_dsctit(1).vlmintcl
                           -- OUT --
                           ,pr_pc_geral     => vr_liqgeral
                           ,pr_qtd_geral    => vr_qtd_geral);

         -- Salva as informações da CRAPABT => LIQUIDEZ GERAL
         pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                         ,pr_cdoperad => pr_cdoperad
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_dsrestri => ''
                         ,pr_nrseqdig => 20
                         ,pr_cdcooper => pr_cdcooper
                         ,pr_flaprcoo => 1
                         ,pr_dsdetres => (TRIM(to_char(NVL(vr_liqgeral,0), 'FM999G999G999G990D00'))) -- Porcentagem da Liquidez Geral
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
           /* montar descriçao de erro não tratado */
           pr_dscritic := 'erro não tratado na DSCT0003.pr_grava_restricoes_liberacao ' ||sqlerrm;
   END pc_grava_restricoes_liberacao;

   PROCEDURE pc_buscar_associado_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                   ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE  --> Número do CPF/CNPJ
                                   ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                   --------> OUT <--------
                                   ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
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
         vr_dscritic := 'Associado não encontrado.';
         RAISE vr_exc_erro;
       END IF;

       -- Monta o xml de retorno do associado
       -- inicializar o clob
       vr_des_xml := null;
       dbms_lob.createtemporary(vr_des_xml, true);
       dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
       -- inicilizar as informaçoes do xml
       vr_texto_completo := null;

        /*Passou nas validações do bordero, do contrato e listou titulos. Começa a montar o xml*/
       pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                      '<root><dados>');
       pc_escreve_xml('<associado>'||
                           '<nrdconta>' || rw_crapass.nrdconta || '</nrdconta>' ||
                           '<nmprimtl>' || rw_crapass.nmprimtl || '</nmprimtl>' ||
                           '<nrcpfcgc>' || rw_crapass.nrcpfcgc || '</nrcpfcgc>' ||
                      '</associado>');

       pc_escreve_xml ('</dados></root>',true);
       pr_retxml := xmltype.createxml(vr_des_xml);
       EXCEPTION
         when vr_exc_erro then
             -- se foi retornado apenas código
             if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
                 -- buscar a descriçao
                 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
             end if;
             -- variavel de erro recebe erro ocorrido
             pr_cdcritic := nvl(vr_cdcritic,0);
             pr_dscritic := vr_dscritic;

             -- Carregar XML padrao para variavel de retorno
             pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                            '<Root>' ||
                                              '<Erro>' || pr_dscritic || '</Erro>' ||
                                           '</Root>');
        when others then
             -- montar descriçao de erro não tratado
             pr_dscritic := 'Erro não tratado na dsct0003.pc_buscar_associado_web ' ||sqlerrm;
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
                15/02/2019 - Interromper o fluxo da proposta na ibratan o borderô for rejeitado (Paulo Penteado GFT)
        07/03/2019 - Alterado para cancelar proposta em caso de aprovação (Cássia de Oliveira - GFT)
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
      SELECT crapbdt.cdcooper,
             crapbdt.nrborder,
             crapbdt.nrdconta,
             crapbdt.rowid,
             crapbdt.insitbdt,
             crapbdt.insitapr
        FROM crapbdt
       WHERE crapbdt.cdcooper = pr_cdcooper
         AND crapbdt.nrborder = pr_nrborder
         AND crapbdt.nrdconta = pr_nrdconta;
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
      vr_dscritic := 'Erro Borderô nao encontrado.';
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
                            ,pr_cdoperej => vr_cdoperad                -- cdoperad que efetuou a rejeição
                            ,pr_dtrejeit => rw_crapdat.dtmvtolt        -- data de rejeição
                            ,pr_hrrejeit => to_char(sysdate,'SSSSS')   -- hora de rejeião
                            ,pr_dscritic => vr_dscritic                --se houver registro de crítica
                            );

    IF  vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
    END IF;

    -- Altera a decisao de todos os titulos daquele bordero para NAO APROVADOS
    UPDATE craptdb
       SET insittit = 0,
           insitapr = 2
     WHERE nrborder = pr_nrborder
       AND cdcooper = vr_cdcooper
       AND nrdconta = pr_nrdconta;

    IF rw_crapbdt.insitapr NOT IN (3, 4) THEN -- Se não foi aprovado interrompe, se sim cancela
      ESTE0006.pc_interrompe_proposta_bdt_est(pr_cdcooper => vr_cdcooper
                                             ,pr_cdagenci => vr_cdagenci
                                             ,pr_cdoperad => vr_cdoperad
                                             ,pr_cdorigem => vr_idorigem
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_nrborder => pr_nrborder
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
    ELSE
      ESTE0006.pc_cancela_proposta_bdt_est(pr_cdcooper => vr_cdcooper
                                               ,pr_cdagenci => vr_cdagenci
                                               ,pr_cdoperad => vr_cdoperad
                                               ,pr_cdorigem => vr_idorigem
                                               ,pr_nrdconta => pr_nrdconta
                                               ,pr_nrborder => pr_nrborder
                                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);
    END IF;


    IF NVL(vr_cdcritic,0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

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
      pr_dscritic := REPLACE(REPLACE(REPLACE(vr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_efetuar_rejeicao: ' || SQLERRM;
      pr_dscritic := '<![CDATA['||pr_dscritic||']]>';
      pr_dscritic := REPLACE(REPLACE(REPLACE(pr_dscritic,chr(13),' '),chr(10),' '),'''','´');

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_rejeitar_bordero_web;


  PROCEDURE pc_virada_bordero (pr_nrborder  IN crapbdt.nrborder%TYPE DEFAULT 0
                              ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                              --------> OUT <--------
                              ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
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
      Alterações:
       - 30/07/2018 - Vitor Shimada Assanuma (GFT): Inserção da verificação da versão do borderô

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
    vr_flgnewbor INTEGER;
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


      -- Flag de versão da cooperativa
      vr_flgverbor := fn_virada_bordero(vr_cdcooper);

      -- Flag se o borderô está na versão nova
      vr_flgnewbor := fn_versao_bordero(vr_cdcooper, pr_nrborder);

      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;

      /*Passou nas validações do bordero, do contrato e listou titulos. Começa a montar o xml*/
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados>');

      pc_escreve_xml('<cdcooper>'  || vr_cdcooper  || '</cdcooper>'   ||
                     '<flgverbor>' || vr_flgverbor || '</flgverbor>'  ||
                     '<flgnewbor>' || vr_flgnewbor || '</flgnewbor>'
                    );

      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    exception
      when vr_exc_erro then
           /*  se foi retornado apenas código */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;

           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           /* montar descriçao de erro não tratado */
           pr_dscritic := 'erro não tratado na DSCT0003.pc_virada_bordero ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_virada_bordero;


 PROCEDURE pc_busca_titulos_vencidos(pr_cdcooper IN crapbdt.cdcooper%TYPE  --> Numero da Cooperativa
                                    ,pr_nrborder IN crapbdt.nrborder%TYPE  --> Numero do bordero
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de movimentacao
                                    --------> OUT <--------
                                    ,pr_qtregist          OUT INTEGER              --> Quantidade de registros encontrados
                                    ,pr_tab_tit_bordero   OUT  typ_tab_tit_bordero --> Tabela de retorno
                                    ,pr_cdcritic OUT PLS_INTEGER                   --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2                      --> Descrição da crítica
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
       SELECT (vltitulo - vlsldtit) AS vlpago,
              (vlmtatit - vlpagmta) AS vlmulta,
              (vlmratit - vlpagmra) AS vlmora,
              (vliofcpl - vlpagiof) AS vliof,
              (vlsldtit + (vlmtatit - vlpagmta) + (vlmratit - vlpagmra) + (vliofcpl - vlpagiof)) AS vlpagar,
              tdb.*
         FROM craptdb tdb,
              crapbdt bdt
        WHERE tdb.cdcooper = bdt.cdcooper
          AND tdb.nrdconta = bdt.nrdconta
          AND tdb.nrborder = bdt.nrborder
          AND gene0005.fn_valida_dia_util(pr_cdcooper, tdb.dtvencto) < pr_dtmvtolt
          AND tdb.nrborder = pr_nrborder
          AND tdb.nrdconta = pr_nrdconta
          AND tdb.cdcooper = pr_cdcooper
          AND tdb.insittit = 4  -- liberado
          AND bdt.flverbor = 1; -- bordero liberado na nova versão;
     rw_craptdb cr_craptdb%rowtype;


     -- Cursor de verificar se o titulo está em acordo
     CURSOR cr_crapaco (pr_nrtitulo craptdb.nrtitulo%TYPE)IS
     SELECT COUNT(1) AS qtd_acordo
       FROM tbdsct_titulo_cyber ttc
      INNER JOIN tbrecup_acordo_contrato tac
         ON ttc.nrctrdsc = tac.nrctremp
      INNER JOIN tbrecup_acordo ta
         ON tac.nracordo = ta.nracordo
        AND ta.cdcooper = ttc.cdcooper
      WHERE ttc.cdcooper = pr_cdcooper
        AND ttc.nrdconta = pr_nrdconta
        AND ttc.nrborder = pr_nrborder
        AND ttc.nrtitulo = pr_nrtitulo
        AND tac.cdorigem = 4   -- Desconto de Títulos
        AND ta.cdsituacao <> 3; -- Diferente de Cancelado
     rw_crapaco cr_crapaco%ROWTYPE;

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

         -- Pesquisa na tabela de acordo para verificar se aquele titulo está em acordo
         OPEN cr_crapaco(rw_craptdb.nrtitulo);
         FETCH cr_crapaco INTO rw_crapaco;
         IF rw_crapaco.qtd_acordo = 0 THEN
           pr_tab_tit_bordero(pr_qtregist).flacordo := 0;
         ELSE
           pr_tab_tit_bordero(pr_qtregist).flacordo := 1;
         END IF;
         CLOSE cr_crapaco;


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


 PROCEDURE pc_busca_titulos_vencidos_web(pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                    ,pr_nrborder IN crapbdt.nrborder%TYPE  --> Numero do bordero
                                    ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                    --------> OUT <--------
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
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
     -- Variável de críticas
     vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
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

       -- Leitura do calendário da cooperativa
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
                                ,vr_tab_tit_bordero --> Tabela de retorno dos títulos encontrados
                                ,vr_cdcritic        --> Código da crítica
                                ,vr_dscritic        --> Descrição da crítica
                              );
       IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NOT NULL THEN
         RAISE vr_exc_erro;
       END IF;
       -- Inicializar o clob
       vr_des_xml := null;
       dbms_lob.createtemporary(vr_des_xml, true);
       dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

       -- inicilizar as informaçoes do xml
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
                           '<flacordo>' || vr_tab_tit_bordero(vr_index).flacordo || '</flacordo>'  ||
                           '<dsacordo>' || CASE WHEN vr_tab_tit_bordero(vr_index).flacordo = 1 THEN 'Sim'  ELSE 'Não' END|| '</dsacordo>'  ||
                        '</inf>'
                      );
         vr_index := vr_tab_tit_bordero.next(vr_index);
       END LOOP;
       pc_escreve_xml ('</dados></root>',true);
       pr_retxml := xmltype.createxml(vr_des_xml);

       -- liberando a memória alocada pro clob
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

 PROCEDURE pc_calcula_possui_saldo (pr_nrdconta     IN crapass.nrdconta%TYPE  --> Número da Conta
                                   ,pr_nrborder     IN crapbdt.nrborder%TYPE  --> Numero do bordero
                                   ,pr_arrtitulo   IN VARCHAR2               --> Lista dos titulos
                                   ,pr_xmllog       IN VARCHAR2               --> XML com informações de LOG
                                   --------> OUT <--------
                                   ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
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
    -- Variável de críticas
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
       SELECT *
        FROM crapope ope
       WHERE ope.cdcooper = vr_cdcooper
         AND UPPER(ope.cdoperad) = UPPER(vr_cdoperad);
    rw_crapope cr_crapope%ROWTYPE;

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

      -- Leitura do calendário da cooperativa
      OPEN  btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat into rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      -- Limite da conta
      SELECT NVL(vllimcre,0)
        INTO pr_vllimcre
        FROM crapass
       WHERE nrdconta = pr_nrdconta
         AND cdcooper = vr_cdcooper;

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
          CLOSE cr_crapope;
          IF vr_total <= rw_crapope.vlpagchq THEN
            vr_possui_saldo := 2; -- Possui Alcada
            vr_mensagem_ret := 'Utilizando alcada do Operador.';
          ELSE
            vr_possui_saldo := 0;
            vr_mensagem_ret := 'Saldo e alcada insuficientes.';
          END IF;
       END IF;

       -- Inicializar o clob
       vr_des_xml := null;
       dbms_lob.createtemporary(vr_des_xml, true);
       dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

       -- inicilizar as informaçoes do xml
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

       /* liberando a memória alocada pro clob */
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

 PROCEDURE pc_calcula_saldo_prejuizo_web (pr_nrdconta     IN crapass.nrdconta%TYPE  --> Número da Conta
                                   ,pr_nrborder     IN crapbdt.nrborder%TYPE  --> Numero do bordero
                                   ,pr_vlaboorj     IN NUMBER                 --> Valor do abono
                                   ,pr_vlpagmto     IN NUMBER                 --> Valor do pagamento
                                   ,pr_xmllog       IN VARCHAR2               --> XML com informações de LOG
                                   --------> OUT <--------
                                   ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                   ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                 ) IS
    /*---------------------------------------------------------------------------------------------------------------------
      Programa : pc_calcula_saldo_prejuizo_web
      Sistema  :
      Sigla    : CRED
      Autor    : Luis Fernando (GFT)
      Data     : 06/09/2018
      Frequencia: Sempre que for chamado
      Objetivo  : Buscar o Saldo em Conta do cooperado e verificar a alcada do operador para calculo de prejuizo
    ---------------------------------------------------------------------------------------------------------------------*/
    -- Variável de críticas
    vr_cdcritic INTEGER;
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

    vr_possui_saldo INTEGER;
    vr_mensagem_ret VARCHAR(100);

    BEGIN
       pr_nmdcampo := NULL;
       pr_des_erro := 'OK';
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

      PREJ0005.pc_calcula_saldo_prejuizo(pr_cdcooper => vr_cdcooper
                                ,pr_nrborder => pr_nrborder
                                ,pr_vlaboorj => pr_vlaboorj
                                ,pr_vlpagmto => pr_vlpagmto
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                -- OUT --
                                ,pr_possui_saldo => vr_possui_saldo
                                ,pr_mensagem_ret => vr_mensagem_ret
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic
                                );

      -- Condicao para verificar se houve critica
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
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

      -- liberando a memória alocada pro clob
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
EXCEPTION
      when vr_exc_erro then
           --  se foi retornado apenas código
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               -- buscar a descriçao
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           -- variavel de erro recebe erro ocorrido
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;

           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           -- montar descriçao de erro não tratado
           pr_dscritic := 'erro não tratado na DSCT0003.pc_calcula_saldo_prejuizo_web ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
 END pc_calcula_saldo_prejuizo_web;

 PROCEDURE pc_pagar_titulos_vencidos (pr_nrdconta         IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_nrborder         IN crapbdt.nrborder%TYPE  --> Numero do bordero
                                     ,pr_flavalista       IN VARCHAR2               --> Caso seja pagamento com avalista
                                     ,pr_arrtitulo        IN VARCHAR2               --> Lista dos titulos
                                     ,pr_xmllog           IN VARCHAR2               --> XML com informações de LOG
                                     --------> OUT <--------
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
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

       Alteração : 19/05/2018 - Criação (Vitor Shimada (GFT))
                   20/06/2018 - Substituido o processo de pagamento pela chamada da procedure pc_pagar_titulo (Paulo Penteado (GFT)
                   15/08/2018 - Alteração no select para trazer apenas os campos utilizados (Vitor Shimada Assanuma (GFT))
                   17/09/2018 - Verificação se algum dos titulos selecionados está em acordo (Vitor S. Assanuma (GFT))
                   19/09/2018 - Alteração do select para regex (Vitor S. Assanuma (GFT))
                   05/10/2018 - Inserção do registro na VERLOG (Vitor S. Assanuma (GFT))
     ---------------------------------------------------------------------------------------------------------------------*/
     vr_vlpagmto craptdb.vltitulo%TYPE;

     -- Variável de críticas
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
     --vr_sql      VARCHAR2(32767);
     --vr_sql_acordo VARCHAR2(32767);

     --TYPE tpy_ref_tdb IS REF CURSOR;
     --cr_tab_tdb       tpy_ref_tdb;
     vr_rowid_log ROWID;

     --TYPE tpy_ref_acordo IS REF CURSOR;
     --cr_tab_acordo    tpy_ref_acordo;

     -- Cursor dos titulos para ser preenchido pelo comando SQL dentro do programa
     CURSOR cr_craptdb (pr_cdcooper craptdb.cdcooper%TYPE) IS
            SELECT (vlmtatit - vlpagmta) AS vlmulta,
                   (vlmratit - vlpagmra) AS vlmora,
                   (vliofcpl - vlpagiof) AS vliof,
                   craptdb.cdbandoc,
                   craptdb.nrdctabb,
                   craptdb.nrcnvcob,
                   craptdb.nrdocmto,
                   craptdb.vlsldtit
              FROM craptdb
             WHERE craptdb.nrborder = pr_nrborder
               AND craptdb.nrdconta = pr_nrdconta
               AND craptdb.cdcooper = vr_cdcooper
               AND craptdb.nrtitulo IN
                   (SELECT to_number(regexp_substr(pr_arrtitulo, '[^,]+', 1, LEVEL))
                      FROM dual
                    CONNECT BY regexp_substr(pr_arrtitulo, '[^,]+', 1, LEVEL) IS NOT NULL);
     rw_craptdb cr_craptdb%ROWTYPE;

     -- Cursor de acordos
     CURSOR cr_crapaco (pr_cdcooper craptdb.cdcooper%TYPE) IS
       SELECT COUNT(tac.nracordo) AS qtdacordo
         FROM craptdb tdb
        INNER JOIN tbdsct_titulo_cyber ttc
           ON tdb.cdcooper = ttc.cdcooper
          AND tdb.nrdconta = ttc.nrdconta
          AND tdb.nrborder = ttc.nrborder
          AND tdb.nrtitulo = ttc.nrtitulo
        INNER JOIN tbrecup_acordo_contrato tac
           ON ttc.nrctrdsc = tac.nrctremp
        INNER JOIN tbrecup_acordo ta
           ON tac.nracordo = ta.nracordo
          AND ttc.cdcooper = ta.cdcooper
          AND ta.nrdconta = ttc.nrdconta
        WHERE tac.cdorigem   = 4 -- Desconto de Títulos
          AND ta.cdsituacao <> 3 -- Acordo não está cancelado
          AND tdb.cdcooper   = pr_cdcooper
          AND tdb.nrdconta   = pr_nrdconta
          AND tdb.nrborder   = pr_nrborder
          AND tdb.nrtitulo IN
              (SELECT to_number(regexp_substr(pr_arrtitulo, '[^,]+', 1, LEVEL))
                 FROM dual
                                    CONNECT BY regexp_substr(pr_arrtitulo, '[^,]+', 1, LEVEL) IS NOT NULL);
     rw_crapaco cr_crapaco%ROWTYPE;

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

    -- Verifica se algum titulo selecionado está em Acordo
    OPEN cr_crapaco(vr_cdcooper);
    FETCH cr_crapaco INTO rw_crapaco;
    IF  rw_crapaco.qtdacordo > 0 THEN
      CLOSE cr_crapaco;
      vr_dscritic := 'Os títulos selecionados para pagamento pertencem a um acordo';
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapaco;

    -- Busca os titulos selecionados
    FOR rw_craptdb IN  cr_craptdb(vr_cdcooper) LOOP

          vr_vlpagmto := rw_craptdb.vlsldtit + rw_craptdb.vlmulta + rw_craptdb.vlmora + rw_craptdb.vliof;

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
                         ,pr_indpagto => NULL -- não se aplica para origem de pagamento 3
                         ,pr_flpgtava => CASE WHEN pr_flavalista = 'false' THEN 0 ELSE 1 END
                         ,pr_vlpagmto => vr_vlpagmto
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);

          -- Condicao para verificar se houve critica
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;

          -- Efetua os inserts para apresentacao na tela VERLOG
          gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                        ,pr_dstransa => 'Pagamento do Bordero Nr.: ' || pr_nrborder || ' Nr.Doc: ' || rw_craptdb.nrdocmto
                        ,pr_dttransa => trunc(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => to_char(SYSDATE,'SSSSS')
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'ATENDA'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_rowid_log);
    END LOOP;

    -- Commita toda a transacao
    COMMIT;

    -- Caso dê tudo certo, retorna o xml com OK
    pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><dsmensag>1</dsmensag></Root>');
  EXCEPTION
    WHEN vr_exc_erro THEN
        -- Efetua os inserts para apresentacao na tela VERLOG
        gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                        ,pr_dstransa => 'Erro ao pagar Bordero Nr.: ' || pr_nrborder
                        ,pr_dttransa => trunc(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => to_char(SYSDATE,'SSSSS')
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'ATENDA'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_rowid_log);
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
        -- Efetua os inserts para apresentacao na tela VERLOG
        gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                        ,pr_dstransa => 'Erro ao pagar Bordero Nr.: ' || pr_nrborder
                        ,pr_dttransa => trunc(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => to_char(SYSDATE,'SSSSS')
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'ATENDA'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_rowid_log);
         pr_des_erro := 'NOK';
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := 'Erro geral na rotina dsct0003.pc_pagar_titulos_vencidos: '||SQLERRM;
         pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> '||
                                          '<Root><Erro>'||pr_dscritic||'</Erro></Root>');
         ROLLBACK;
 END pc_pagar_titulos_vencidos;

 PROCEDURE pc_calcula_liquidez_geral(pr_cdcooper     IN craptdb.cdcooper%TYPE
                            ,pr_nrdconta     IN craptdb.nrdconta%TYPE
                            ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE
                            ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                            ,pr_qtcarpag     IN NUMBER
                            ,pr_qtmitdcl     IN INTEGER  DEFAULT 0
                            ,pr_vlmintcl     IN NUMBER   DEFAULT 0
                            -- OUT --
                            ,pr_pc_geral     OUT NUMBER
                            ,pr_qtd_geral    OUT NUMBER) IS
   /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_calcula_liquidez_geral
    Sistema  : CRED
    Sigla    : CRED
    Autor    : Vitor Shimada Assanuma (GFT)
    Data     : 24/05/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Procedure para centralizar os calculos de Liquidez retornando a quantidade e porcentagens
    Alterações:
              Alterado a regra do calculo de liquidez cedente pagador para quando não ache titulos seja 100% - Vitor Shimada Assanuma (GFT)
              Adicionado minimo de titulos e valor minimo do titulo para calculo da liquidez - Luis Fernando (GFT)
              Alterado o nome para funcionar apenas a liquidez geral - Luis Fernando (GFT)
    ---------------------------------------------------------------------------------------------------------------------*/
    -- CALCULO  DA LIQUIDEZ GERAL
    CURSOR cr_liquidez_geral IS
      SELECT COUNT(1) AS qtd_titulos,
           (SUM(CASE
                  WHEN (dtdpagto IS NOT NULL AND nrdconta_tit IS NULL AND
                       (dtdpagto <= (dtvencto + pr_qtcarpag))) THEN
                   1
                  ELSE
                   0
                END) / COUNT(1)) * 100 AS qtd_geral,
           (SUM(CASE
                  WHEN (dtdpagto IS NOT NULL AND nrdconta_tit IS NULL AND
                       (dtdpagto <= (dtvencto + pr_qtcarpag))) THEN
                   vltitulo
                  ELSE
                   0
                END) / SUM(vltitulo)) * 100 AS pc_geral
      FROM (SELECT cob.dtdpagto,
                   tit.nrdconta nrdconta_tit,
                   cob.dtvencto,
                   cob.vltitulo
              FROM crapcob cob -- Titulos do Bordero
             INNER JOIN crapceb ceb
                ON cob.cdcooper = ceb.cdcooper
               AND cob.nrdconta = ceb.nrdconta
               AND cob.nrcnvcob = ceb.nrconven
              LEFT JOIN craptit tit
                ON tit.cdcooper = cob.cdcooper
               AND tit.dtmvtolt = cob.dtdpagto
               AND tit.nrdconta = cob.nrdconta
               AND cob.nrdconta = substr(upper(tit.dscodbar), 26, 8)
               AND cob.nrcnvcob = substr(upper(tit.dscodbar), 20, 6)
               AND cob.nrdocmto = substr(upper(tit.dscodbar), 34, 9)
               AND tit.cdbandst = 85
               AND tit.cdagenci IN (90,91)
             WHERE cob.dtvencto  BETWEEN pr_dtmvtolt_de AND pr_dtmvtolt_ate -- No intervalo de data da liquidez
               AND cob.cdcooper = pr_cdcooper
               AND cob.nrdconta = pr_nrdconta
               AND cob.vltitulo >= nvl(pr_vlmintcl,0)
               AND cob.cdbanpag = 85
            UNION ALL
            SELECT cob.dtdpagto,
                   NULL nrdconta_tit,
                   cob.dtvencto,
                   cob.vltitulo
              FROM crapcob cob -- Titulos do Bordero
             INNER JOIN crapceb ceb
                ON cob.cdcooper = ceb.cdcooper
               AND cob.nrdconta = ceb.nrdconta
               AND cob.nrcnvcob = ceb.nrconven
             WHERE cob.dtvencto BETWEEN pr_dtmvtolt_de AND pr_dtmvtolt_ate -- No intervalo de data da liquidez
               AND cob.cdcooper = pr_cdcooper
               AND cob.nrdconta = pr_nrdconta
               AND cob.vltitulo >= nvl(pr_vlmintcl,0)
               AND cob.cdbanpag <> 85);
    rw_liquidez_geral cr_liquidez_geral%ROWTYPE;

  BEGIN
    OPEN cr_liquidez_geral;
    FETCH cr_liquidez_geral INTO rw_liquidez_geral;
    CLOSE cr_liquidez_geral;

    IF (rw_liquidez_geral.qtd_titulos < pr_qtmitdcl OR (nvl(rw_liquidez_geral.pc_geral,0) = 0 AND rw_liquidez_geral.qtd_titulos = 0)) THEN
      pr_pc_geral  := 100;
      pr_qtd_geral := 100;
    ELSE
      pr_pc_geral  := rw_liquidez_geral.pc_geral;
      pr_qtd_geral :=  rw_liquidez_geral.qtd_geral;
    END IF;
 END pc_calcula_liquidez_geral;

 PROCEDURE pc_calcula_liquidez_pagador(pr_cdcooper     IN craptdb.cdcooper%TYPE
                            ,pr_nrdconta     IN craptdb.nrdconta%TYPE
                            ,pr_nrinssac     IN crapcob.nrinssac%TYPE DEFAULT NULL
                            ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE
                            ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                            ,pr_qtcarpag     IN NUMBER
                            ,pr_qtmitdcl     IN INTEGER  DEFAULT 0
                            ,pr_vlmintcl     IN NUMBER   DEFAULT 0
                            -- OUT --
                            ,pr_pc_cedpag    OUT NUMBER
                            ,pr_qtd_cedpag   OUT NUMBER) IS
   /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_calcula_liquidez_pagador
    Sistema  : CRED
    Sigla    : CRED
    Autor    : Luis Fernando (GFT)
    Data     : 24/01/2019
    Frequencia: Sempre que for chamado
    Objetivo  : Procedure criada para tarzer a liquidez do pagador em relação ao cedente
    Alterações:
    ---------------------------------------------------------------------------------------------------------------------*/
    -- CALCULO DA LIQUIDEZ CEDENTE PAGADOR
    CURSOR cr_liquidez_pagador IS
      SELECT COUNT(1) AS qtd_titulos,
           (SUM(CASE
                  WHEN (dtdpagto IS NOT NULL AND nrdconta_tit IS NULL AND
                       (dtdpagto <= (dtvencto + pr_qtcarpag))) THEN
                   1
                  ELSE
                   0
                END) / COUNT(1)) * 100 AS qtd_cedpag,
           (SUM(CASE
                  WHEN (dtdpagto IS NOT NULL AND nrdconta_tit IS NULL AND
                       (dtdpagto <= (dtvencto + pr_qtcarpag))) THEN
                   vltitulo
                  ELSE
                   0
                END) / SUM(vltitulo)) * 100 AS pc_cedpag
      FROM (SELECT cob.dtdpagto,
                   tit.nrdconta nrdconta_tit,
                   cob.dtvencto,
                   cob.vltitulo
              FROM crapcob cob -- Titulos do Bordero
             INNER JOIN crapceb ceb
                ON cob.cdcooper = ceb.cdcooper
               AND cob.nrdconta = ceb.nrdconta
               AND cob.nrcnvcob = ceb.nrconven
              LEFT JOIN craptit tit
                ON tit.cdcooper = cob.cdcooper
               AND tit.dtmvtolt = cob.dtdpagto
               AND tit.nrdconta = cob.nrdconta
               AND cob.nrdconta = substr(upper(tit.dscodbar), 26, 8)
               AND cob.nrcnvcob = substr(upper(tit.dscodbar), 20, 6)
               AND cob.nrdocmto = substr(upper(tit.dscodbar), 34, 9)
               AND tit.cdbandst = 85
               AND tit.cdagenci IN (90,91)
             WHERE cob.dtvencto  BETWEEN pr_dtmvtolt_de AND pr_dtmvtolt_ate -- No intervalo de data da liquidez
               AND cob.cdcooper = pr_cdcooper
               AND cob.nrdconta = pr_nrdconta
               AND cob.nrinssac = pr_nrinssac
               AND cob.vltitulo >= nvl(pr_vlmintcl,0)
               AND cob.cdbanpag = 85
            UNION ALL
            SELECT cob.dtdpagto,
                   NULL nrdconta_tit,
                   cob.dtvencto,
                   cob.vltitulo
              FROM crapcob cob -- Titulos do Bordero
             INNER JOIN crapceb ceb
                ON cob.cdcooper = ceb.cdcooper
               AND cob.nrdconta = ceb.nrdconta
               AND cob.nrcnvcob = ceb.nrconven
             WHERE cob.dtvencto BETWEEN pr_dtmvtolt_de AND pr_dtmvtolt_ate -- No intervalo de data da liquidez
               AND cob.cdcooper = pr_cdcooper
               AND cob.nrdconta = pr_nrdconta
               AND cob.nrinssac = pr_nrinssac
               AND cob.vltitulo >= nvl(pr_vlmintcl,0)
               AND cob.cdbanpag <> 85);
    rw_liquidez_pagador cr_liquidez_pagador%ROWTYPE;

  BEGIN
    IF (pr_nrinssac IS NOT NULL) THEN
      OPEN cr_liquidez_pagador;
      FETCH cr_liquidez_pagador INTO rw_liquidez_pagador;
      CLOSE cr_liquidez_pagador;
      IF (rw_liquidez_pagador.qtd_titulos < pr_qtmitdcl OR (nvl(rw_liquidez_pagador.pc_cedpag,0) = 0 AND rw_liquidez_pagador.qtd_titulos = 0)) THEN
        pr_pc_cedpag  := 100;
        pr_qtd_cedpag := 100;
      ELSE
        pr_pc_cedpag  := rw_liquidez_pagador.pc_cedpag;
        pr_qtd_cedpag :=  rw_liquidez_pagador.qtd_cedpag;
      END IF;
    ELSE
      pr_pc_cedpag  := 0;
      pr_qtd_cedpag := 0;
    END IF;

 END pc_calcula_liquidez_pagador;

 PROCEDURE pc_calcula_concentracao(pr_cdcooper     IN craptdb.cdcooper%TYPE
                            ,pr_nrdconta     IN craptdb.nrdconta%TYPE
                            ,pr_nrinssac     IN crapcob.nrinssac%TYPE DEFAULT NULL
                            ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE
                            ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                            ,pr_qtcarpag     IN NUMBER
                            ,pr_qtmitdcl     IN INTEGER  DEFAULT 0
                            ,pr_vlmintcl     IN NUMBER   DEFAULT 0
                            -- OUT --
                            ,pr_pc_conc      OUT NUMBER
                            ,pr_qtd_conc     OUT NUMBER) IS
   /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_calcula_concentracao
    Sistema  : CRED
    Sigla    : CRED
    Autor    : Luis Fernando (GFT)
    Data     : 24/01/2019
    Frequencia: Sempre que for chamado
    Objetivo  : Procedure criada para tarzer a concentracao do pagador em relação ao cedente
    Alterações:
    ---------------------------------------------------------------------------------------------------------------------*/
    -- CALCULO DA CONCENTRACAO DO PAGADOR
    CURSOR cr_concentracao IS
    SELECT NVL((SUM(CASE
                      WHEN (tdb.nrinssac = pr_nrinssac) THEN
                       1
                      ELSE
                       0
                    END) / COUNT(1)) * 100,
               0) AS qtd_conc,
           NVL((SUM(CASE
                      WHEN (tdb.nrinssac = pr_nrinssac) THEN
                       vltitulo
                      ELSE
                       0
                    END) / SUM(vltitulo)) * 100,
               0) AS pc_conc
      FROM craptdb tdb -- Titulos do Bordero
     WHERE (tdb.insittit = 4 OR (tdb.insittit = 0 AND tdb.insitapr <> 2))
       AND tdb.cdcooper = pr_cdcooper
       AND tdb.nrdconta = pr_nrdconta
       --     Não considerar como título pago, os liquidados em conta corrente do cedente, ou seja, pagos pelo próprio emitente
       AND NOT EXISTS(SELECT 1
              FROM craptit tit
             WHERE tit.cdcooper = tdb.cdcooper
               AND tit.dtmvtolt = tdb.dtdpagto
               AND tdb.nrdconta = substr(upper(tit.dscodbar), 26, 8)
               AND tdb.nrcnvcob = substr(upper(tit.dscodbar), 20, 6)
               AND tit.cdbandst = 85
               AND tit.cdagenci IN (90, 91));
    rw_concentracao cr_concentracao%ROWTYPE;

  BEGIN
    IF (pr_nrinssac IS NOT NULL) THEN
      OPEN cr_concentracao;
      FETCH cr_concentracao INTO rw_concentracao;
      CLOSE cr_concentracao;
      pr_pc_conc    := rw_concentracao.pc_conc;
      pr_qtd_conc   := rw_concentracao.qtd_conc;
    ELSE
      pr_pc_conc    := 0;
      pr_qtd_conc   := 0;
    END IF;

 END pc_calcula_concentracao;

  PROCEDURE pc_calcula_atraso_tit(pr_cdcooper    IN crapcop.cdcooper%TYPE      --Codigo Cooperativa
                                 ,pr_nrdconta    IN craptdb.nrdconta%TYPE      --Número da conta do cooperado
                                 ,pr_nrborder    IN craptdb.nrborder%TYPE      --Número do borderô
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
     Sistema : Crédito
     Sigla   : CRED

     Autor   : Lucas Lazari (GFT)
     Data    : 24/05/18                        Ultima atualizacao: --/--/----

     Dados referentes ao programa: Calcula os valores de juros, multa e IOF de um título em atraso

     Frequencia: Sempre que for chamado
     Objetivo  :

     Alteracoes: 16/11/2018 - Adicionado tratativa para não trazer lançamentos estornados - Cássia de Oliveira (GFT)
                 20/11/2018 - Corrigido para arrumar o calculo de juros de mora usando campos novos ao inves dos lancamentos
                 07/03/2019 - Inserção de dias de carência para não calcular juros - Vitor S. Assanuma (GFT)
                 14/03/2019 - Inserção da data parametro para o novo calculo de juros - Vitor S. Assanuma
                 21/03/2019 - Ajuste para não considerar os dias de carência do calculo de juros para a data de ultimo
                              pagamento dtultpag (Lucas Lazari GFT)
                 21/03/2019 - Ajuste para não considerar os dias da carência para a cobrança do IOF, pois o mesmo deve ser
                              cobrado a partir do dia de vencimento (Paulo Penteado GFT)
  ..................................................................................*/

    -- Cursores
    CURSOR cr_crapbdt (pr_cdcooper IN crapbdt.cdcooper%type
                      ,pr_nrborder IN crapbdt.nrborder%type) IS
    SELECT crapbdt.txmensal,
           crapbdt.flverbor,
           crapbdt.vltaxiof,
           crapbdt.vltxmult,
           crapbdt.vltxmora
      FROM crapbdt
     WHERE crapbdt.cdcooper = pr_cdcooper
       AND crapbdt.nrborder = pr_nrborder;
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
             craptdb.vlpagmra,
             craptdb.nrdocmto,
             craptdb.cdbandoc,
             craptdb.nrdctabb,
             craptdb.nrcnvcob,
             craptdb.vlultmra,
             craptdb.dtultpag
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
    SELECT crapjur.natjurid,
           crapjur.tpregtrb
       FROM crapjur
      WHERE crapjur.cdcooper = pr_cdcooper
        AND crapjur.nrdconta = pr_nrdconta;
    rw_crapjur cr_crapjur%ROWTYPE;


    -- cursor genérico de calendário
    rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;

    -- variáveis locais
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    vr_txdiaria NUMBER; -- Taxa diária de juros de mora

    vr_dtmvtolt DATE;
    vr_valormora NUMBER;
    --vr_valorsaldo NUMBER;

    vr_vliofpri NUMBER;
    vr_vliofadi NUMBER;
    vr_vliofcpl NUMBER;

    vr_vltxiofatra NUMBER;
    vr_vlsldtit NUMBER;

    vr_flgimune PLS_INTEGER;

    -- exceções
    vr_exc_erro  EXCEPTION;

    -- Retorno da #TAB052
    vr_tab_dados_dsctit    dsct0002.typ_tab_dados_dsctit;
    vr_tab_cecred_dsctit   dsct0002.typ_tab_cecred_dsctit;

    -- Valor da data parametro para verificar se calcula carencia
    vr_dt_param_carencia DATE;
    vr_dt_calc_carencia crapprm.dsvlrprm%TYPE;
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

    -- Valida existência do borderô do respectivo título
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

    -- Valida a existência do título
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

    -- Busca tipo de pessoa
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_cdcritic := 9;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;

    -- Busca os dados da #TAB052
    DSCT0002.pc_busca_parametros_dsctit(pr_cdcooper          => pr_cdcooper
                                       ,pr_cdagenci          => null -- Não utiliza dentro da procedure
                                       ,pr_nrdcaixa          => null -- Não utiliza dentro da procedure
                                       ,pr_cdoperad          => null -- Não utiliza dentro da procedure
                                       ,pr_dtmvtolt          => null -- Não utiliza dentro da procedure
                                       ,pr_idorigem          => null -- Não utiliza dentro da procedure
                                       ,pr_tpcobran          => 1    -- Tipo de Cobrança: 0 = Sem Registro / 1 = Com Registro
                                       ,pr_inpessoa          => rw_crapass.inpessoa
                                       ,pr_tab_dados_dsctit  => vr_tab_dados_dsctit  --> Tabela contendo os parametros da cooperativa
                                       ,pr_tab_cecred_dsctit => vr_tab_cecred_dsctit --> Tabela contendo os parametros da cecred
                                       ,pr_cdcritic          => vr_cdcritic
                                       ,pr_dscritic          => vr_dscritic);
    IF ((NVL(vr_cdcritic, 0) > 0) OR (vr_dscritic IS NOT NULL)) THEN
      RAISE vr_exc_erro;
    END IF;

    -- Busca na tabela de parametros a data
    vr_dt_calc_carencia := gene0001.fn_param_sistema(pr_cdcooper => 0
                                                     ,pr_nmsistem => 'CRED'
                                                     ,pr_cdacesso => 'DT_CALC_CARENCIA');
    -- Caso não ache o parametro ou a data do titulo seja menor que a data parametro, não se aplica os dias de carência.
    IF vr_dt_calc_carencia IS NULL THEN
      vr_tab_dados_dsctit(1).cardbtit_c := 0;
    ELSE
      vr_dt_param_carencia := to_date(vr_dt_calc_carencia,'DD/MM/RRRR');
      IF rw_craptdb.dtvencto <= vr_dt_param_carencia THEN
      vr_tab_dados_dsctit(1).cardbtit_c := 0;
    END IF;
    END IF;

    -- Não calcular juros caso esteja na carência
    IF gene0005.fn_valida_dia_util(pr_cdcooper, rw_craptdb.dtvencto + vr_tab_dados_dsctit(1).cardbtit_c) >= pr_dtmvtolt THEN
      pr_vlmtatit := 0;
      pr_vlmratit := 0;
    ELSE
    vr_vltotal_liquido := 0;
    OPEN cr_craptdb_total(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrborder => pr_nrborder);
    FETCH cr_craptdb_total INTO vr_vltotal_liquido;
    CLOSE cr_craptdb_total;


    -- Busca dados de pessoa jurídica
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

    vr_valormora  := 0;
    IF (vr_vlsldtit > 0) THEN
        -- Verifica se houve algum pagamento parcial do saldo. Não deve considerar o período de carência para data do ultimo pagamento
        vr_dtmvtolt := (rw_craptdb.dtvencto + vr_tab_dados_dsctit(1).cardbtit_c);
        IF rw_craptdb.dtultpag IS NOT NULL AND rw_craptdb.vlultmra > 0 THEN -- houve algum pagamento do saldo parcial
          vr_dtmvtolt   := rw_craptdb.dtultpag;
          vr_valormora  := rw_craptdb.vlultmra;
    END IF;
        -- Contemplar o tempo de carencia para não calcular os juros daquele período
        vr_valormora  := vr_valormora + NVL(ROUND(vr_vlsldtit * (pr_dtmvtolt - vr_dtmvtolt) * vr_txdiaria,2),0);
    END IF;

    pr_vlmratit := vr_valormora;
    END IF;

    -- Calculo de atraso do IOF
    IF gene0005.fn_valida_dia_util(pr_cdcooper, rw_craptdb.dtvencto) >= pr_dtmvtolt THEN
      pr_vlioftit := 0;
    ELSE
    -- Cálculo do IOF
    TIOF0001.pc_calcula_valor_iof_prg (pr_tpproduto            => 2 -- Desconto de títulos
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
        vr_dscritic := 'Erro realizar cálculo de IOF do título em atraso : '||SQLERRM;
      RAISE vr_exc_erro;
    END IF;

    pr_vlioftit := NVL(ROUND(vr_vliofcpl, 2),0);
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

  END pc_calcula_atraso_tit;


  PROCEDURE pc_calcula_juros60_tit(pr_cdcooper  IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                  ,pr_nrdconta  IN craptdb.nrdconta%TYPE --Número da conta do cooperado
                                  ,pr_nrborder  IN craptdb.nrborder%TYPE --Número do borderô
                                  ,pr_cdbandoc  IN craptdb.cdbandoc%TYPE --Codigo do banco impresso no boleto
                                  ,pr_nrdctabb  IN craptdb.nrdctabb%TYPE --Numero da conta base do titulo
                                  ,pr_nrcnvcob  IN craptdb.nrcnvcob%TYPE --Numero do convenio de cobranca
                                  ,pr_nrdocmto  IN craptdb.nrdocmto%TYPE --Numero do documento
                                  ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --Data Movimento
                                  ,pr_vljura60 OUT craptdb.vljura60%TYPE --Valor do juros 60
                                  ,pr_vljrre60 OUT craptdb.vljura60%TYPE --Valor do juros remuneratorio 60
                                  ,pr_cdcritic OUT PLS_INTEGER           --Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2              --Descricao da critica
                                  ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_calcula_juros60_tit
      Sistema  : Ayllos
      Sigla    :
      Autor    : Paulo Penteado (GFT)
      Data     : 07/12/2018

      Objetivo  : Realiza o cálculo dos juros + 60 de mora do título

      Alteração : 07/12/2018 - Criação (Paulo Penteado (GFT))

    ----------------------------------------------------------------------------------------------------------*/

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    CURSOR cr_craptdb IS
    SELECT tdb.dtvencto,
           tdb.vlsldtit,
           (SELECT MIN(mvenc.dtvencto)
              FROM craptdb mvenc
             WHERE mvenc.insittit = 4
               AND mvenc.cdcooper = tdb.cdcooper
               AND mvenc.nrborder = tdb.nrborder
               AND mvenc.nrdconta = tdb.nrdconta
             GROUP BY mvenc.nrborder) maisvencido,
           (POWER((bdt.vltxmora / 100) + 1, (1 / 30)) - 1) txdiariamora
      FROM crapbdt bdt,
           craptdb tdb
     WHERE bdt.cdcooper = tdb.cdcooper
       AND bdt.nrborder = tdb.nrborder
       AND tdb.cdcooper = pr_cdcooper
       AND tdb.nrdconta = pr_nrdconta
       AND tdb.nrborder = pr_nrborder
       AND tdb.cdbandoc = pr_cdbandoc
       AND tdb.nrdctabb = pr_nrdctabb
       AND tdb.nrcnvcob = pr_nrcnvcob
       AND tdb.nrdocmto = pr_nrdocmto;
    rw_craptdb cr_craptdb%ROWTYPE;

    CURSOR cr_jurrem60 IS
    SELECT ((x.dtvencto - x.dtvenmin60 +1) * x.txdiaria * x.vltitulo) vljurrem60
      FROM (SELECT UNIQUE tdb.dtvencto,
                   tdv.dtvenmin,
                   (tdv.dtvenmin + 60) dtvenmin60,
                   ((bdt.txmensal / 100) / 30) txdiaria,
                   tdb.vltitulo
              FROM craptdb tdb
             INNER JOIN (SELECT cdcooper,
                               nrdconta,
                               nrborder,
                               MIN(dtvencto) dtvenmin
                          FROM craptdb
                         WHERE (dtvencto +60) < pr_dtmvtolt
                           AND insittit = 4
                           AND nrborder = pr_nrborder
                           AND cdcooper = pr_cdcooper
                           AND nrdconta = pr_nrdconta
                         GROUP BY cdcooper,
                                  nrdconta,
                                  nrborder) tdv
                ON tdb.cdcooper = tdv.cdcooper
               AND tdb.nrborder = tdv.nrborder
               AND tdb.nrdconta = tdv.nrdconta
             INNER JOIN crapbdt bdt
                ON bdt.nrborder = tdb.nrborder
               AND bdt.cdcooper = tdb.cdcooper
               AND bdt.flverbor = 1
             INNER JOIN crapass ass
                ON bdt.nrdconta = ass.nrdconta
               AND bdt.cdcooper = ass.cdcooper
             WHERE tdb.dtvencto >= (tdv.dtvenmin+60)
               AND tdb.cdcooper = pr_cdcooper
               AND tdb.nrdconta = pr_nrdconta
               AND tdb.nrborder = pr_nrborder
               AND tdb.nrdocmto = pr_nrdocmto
               AND tdb.cdbandoc = pr_cdbandoc
               AND tdb.nrdctabb = pr_nrdctabb
               AND tdb.nrcnvcob = pr_nrcnvcob) x;
  rw_jurrem60 cr_jurrem60%ROWTYPE;

  BEGIN
    OPEN cr_craptdb;
    FETCH cr_craptdb INTO rw_craptdb;
    IF cr_craptdb%NOTFOUND THEN
      CLOSE cr_craptdb;
      vr_cdcritic := 1108;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_craptdb;

    pr_vljura60 := 0;
    pr_vljrre60 := 0;

    -- Verifica se o título está vencido a mais de 60 dias
    IF (rw_craptdb.maisvencido + 60) <= pr_dtmvtolt AND (rw_craptdb.dtvencto <= pr_dtmvtolt) THEN
      IF (ccet0001.fn_diff_datas(rw_craptdb.dtvencto, rw_craptdb.maisvencido) >= 60) THEN
          pr_vljura60 := ROUND(rw_craptdb.vlsldtit * rw_craptdb.txdiariamora * (pr_dtmvtolt - (rw_craptdb.dtvencto)),2);
      ELSE
          pr_vljura60 := ROUND(rw_craptdb.vlsldtit * rw_craptdb.txdiariamora * (pr_dtmvtolt - (rw_craptdb.maisvencido + 59)),2);
      END IF;
    END IF;

    OPEN cr_jurrem60;
    FETCH cr_jurrem60 INTO rw_jurrem60;
    IF cr_jurrem60%FOUND THEN
      pr_vljrre60 := rw_jurrem60.vljurrem60;
    END IF;
    CLOSE cr_jurrem60;

  EXCEPTION
    WHEN vr_exc_erro then
      IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := 'Erro geral na rotina .pc_calcula_juros60_tit: '||SQLERRM;
  END pc_calcula_juros60_tit;


  PROCEDURE pc_pagar_titulo_operacao ( pr_cdcooper    IN crapcop.cdcooper%TYPE           --Codigo Cooperativa
                            ,pr_cdagenci    IN INTEGER                         --Codigo Agencia
                            ,pr_nrdcaixa    IN INTEGER                         --Numero Caixa
                            ,pr_idorigem    IN INTEGER                         --Origem sistema
                            ,pr_cdoperad    IN VARCHAR2                        --Codigo operador
                            ,pr_nrdconta    IN craptdb.nrdconta%TYPE           --Número da conta do cooperado
                            ,pr_nrborder    IN craptdb.nrborder%TYPE           --Número do borderô
                            ,pr_cdbandoc    IN craptdb.cdbandoc%TYPE           --Codigo do banco impresso no boleto
                            ,pr_nrdctabb    IN craptdb.nrdctabb%TYPE           --Numero da conta base do titulo
                            ,pr_nrcnvcob    IN craptdb.nrcnvcob%TYPE           --Numero do convenio de cobranca
                            ,pr_nrdocmto    IN craptdb.nrdocmto%TYPE           --Numero do documento
                            ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE           --Data Movimento
                            ,pr_inproces    IN crapdat.inproces%TYPE DEFAULT 1 --Indicador do processo
                            ,pr_indpagto    IN crapcob.indpagto%TYPE DEFAULT 0 --Indica de onde vem o pagamento
                            ,pr_vlpagmto    IN OUT NUMBER                      --Valor do pagamento
                            ,pr_cdcritic    OUT INTEGER                        --Codigo Critica
                            ,pr_dscritic    OUT VARCHAR2) IS

  /* ................................................................................
     Programa: pc_pagar_titulo_operacao
     Sistema : Crédito
     Sigla   : CRED

     Autor   : Luis Fernando (GFT)
     Data    : 01/11/2018

     Dados referentes ao programa:
     Frequencia: Sempre que for chamado
     Objetivo  :  Realiza o pagamento de um título através do processamento de importacao da 538

     Alterações:
                 27/11/2018 - Adicionado pagamento de juros60 para futuras contabilizacoes de prejuizo (Luis Fernando - GFT)
  ..................................................................................*/

    -- CURSORES
    CURSOR cr_crapbdt (pr_cdcooper IN crapbdt.cdcooper%type
                      ,pr_nrborder IN crapbdt.nrborder%type) IS
      SELECT crapbdt.txmensal,
             crapbdt.flverbor,
             crapbdt.vltaxiof,
             crapbdt.vltxmult,
             crapbdt.vltxmora,
             crapbdt.inprejuz
        FROM crapbdt
       WHERE crapbdt.cdcooper = pr_cdcooper
         AND crapbdt.nrborder = pr_nrborder;
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
             craptdb.vlsldtit + (craptdb.vliofcpl - craptdb.vlpagiof) +
             (craptdb.vlmtatit - craptdb.vlpagmta) + (craptdb.vlmratit - craptdb.vlpagmra) AS vltitulo_total,
             (craptdb.vliofcpl - craptdb.vlpagiof) AS vliofcpl_restante,
             (craptdb.vlmtatit - craptdb.vlpagmta) AS vlmtatit_restante,
             (craptdb.vlmratit - craptdb.vlpagmra) AS vlmratit_restante,
             (craptdb.vljura60 - craptdb.vlpgjm60) AS vljura60_restante
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

    CURSOR cr_lancboraprop(pr_cdcooper IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                          ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                          ,pr_nrborder IN crapbdt.nrborder%TYPE --> numero do bordero
                          ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE --> Data do movimento atual
                          ,pr_cdhistor IN craphis.cdhistor%TYPE --> Codigo do historico do lancamento
                          ,pr_cdbandoc IN craptdb.cdbandoc%TYPE --> Codigo do banco impresso no boleto
                          ,pr_nrdctabb IN craptdb.nrdctabb%TYPE --> Numero da conta base do titulo
                          ,pr_nrcnvcob IN craptdb.nrcnvcob%TYPE --> Numero do convenio de cobranca
                          ,pr_nrdocmto IN craptdb.nrdocmto%TYPE --> Numero do documento
                          ) IS
    SELECT SUM(lcb.vllanmto) vllanmto
      FROM tbdsct_lancamento_bordero lcb
     WHERE lcb.cdcooper = pr_cdcooper
       AND lcb.nrdconta = pr_nrdconta
       AND lcb.nrborder = pr_nrborder
       AND lcb.cdbandoc = pr_cdbandoc
       AND lcb.nrdctabb = pr_nrdctabb
       AND lcb.nrcnvcob = pr_nrcnvcob
       AND lcb.nrdocmto = pr_nrdocmto
       AND lcb.cdhistor = pr_cdhistor
       AND lcb.dtmvtolt <= pr_dtmvtolt;
    rw_lancboraprop cr_lancboraprop%ROWTYPE;

    -- TYPES
    TYPE typ_dados_tarifa IS RECORD
      (cdfvlcop crapcop.cdcooper%TYPE
      ,cdhistor craphis.cdhistor%TYPE
      ,vlrtarif NUMBER
      ,vltottar NUMBER);

    -- VARIÁVEIS LOCAIS
    vr_cdbattar     VARCHAR2(1000);
    vr_cdhisest     INTEGER;
    vr_dtdivulg     DATE;
    vr_dtvigenc     DATE;

    vr_rowid_craplat  ROWID;

    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    vr_tab_erro GENE0001.typ_tab_erro; --Tabela de erros
    vr_des_erro VARCHAR2(10);

    vr_vlsldtit NUMBER; -- Saldo devedor atual do título
    vr_vlpagmto NUMBER; -- Valor disponível para pagamento do título

    vr_flbaixar BOOLEAN; -- Indica se o título deve sofrer baixa ou não
    --vr_flraspar BOOLEAN; -- Indica se o processo de raspada deve continuar ou não

    vr_vliofpri NUMBER; -- Valor do IOF principal
    vr_vliofadi NUMBER; -- Valor do IOF adicional
    vr_vliofcpl NUMBER; -- Valor do IOF complementar

    vr_vlpagiof NUMBER; -- Valor pago do IOF complementar
    vr_vlpagmta NUMBER; -- Valor pago da multa
    vr_vlpagmra NUMBER; -- Valor pago dos juros de mora
    vr_vlpagtit NUMBER; -- Valor pago do título
    vr_vlpagm60 NUMBER; -- Valor pago do juros 60

    vr_insittit craptdb.insittit%TYPE;
    --vr_dtdebito craptdb.dtdebito%TYPE;
    vr_dtdpagto craptdb.dtdpagto%TYPE;

    vr_cdhistor_opc INTEGER; -- Histórico de lançamento do titulo

    vr_vltxiofatra NUMBER;

    vr_dados_tarifa typ_dados_tarifa;

    vr_flgimune PLS_INTEGER;

    --vr_cdpesqbb     VARCHAR2(1000);

    vr_dtmvtolt_lcm craplcm.dtmvtolt%TYPE;
    vr_cdagenci_lcm craplcm.cdagenci%TYPE;
    vr_cdbccxlt_lcm craplcm.cdbccxlt%TYPE;
    vr_nrdolote_lcm craplcm.nrdolote%TYPE;
    --vr_nrseqdig_lcm craplcm.nrseqdig%TYPE;

    -- EXCEÇÕES
    vr_exc_erro  EXCEPTION;

    /* FUNÇÕES */

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

    -- Busca dados de pessoa jurídica
    OPEN cr_crapjur(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapjur INTO rw_crapjur;
    CLOSE cr_crapjur;

    -- Valida a existência do título
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

    -- Valida existência do borderô do respectivo título
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

    vr_vlpagiof := 0;
    vr_vlpagmta := 0;
    vr_vlpagmra := 0;
    vr_vlsldtit := rw_craptdb.vlsldtit;
    vr_vlpagtit := 0;
    vr_vlpagm60 := 0;

    -- 0) Crédito na operação
    IF pr_indpagto = 0 THEN
      vr_cdhistor_opc := vr_cdhistordsct_pgtocompe; -- Compe
    ELSE
      vr_cdhistor_opc := vr_cdhistordsct_pgtocooper; -- Caixa/IB/TAA
    END IF;

    -- Adiciona o crédito do pagamento na operação
    -- Lançar valor total do crédito do da operação título nos lançamentos do borderô
    pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrborder => pr_nrborder
                                 ,pr_dtmvtolt => pr_dtmvtolt
                                 ,pr_cdbandoc => pr_cdbandoc
                                 ,pr_nrdctabb => pr_nrdctabb
                                 ,pr_nrcnvcob => pr_nrcnvcob
                                 ,pr_nrdocmto => pr_nrdocmto
                                 ,pr_nrtitulo => rw_craptdb.nrtitulo
                                 ,pr_cdorigem => pr_idorigem
                                 ,pr_cdhistor => vr_cdhistor_opc
                                 ,pr_vllanmto => vr_vlpagmto
                                 ,pr_dscritic => vr_dscritic );
    -- Condicao para verificar se houve critica
    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- 1) IOF

    vr_vltotal_liquido := 0;
    OPEN cr_craptdb_total(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrborder => pr_nrborder);
    FETCH cr_craptdb_total INTO vr_vltotal_liquido;
    CLOSE cr_craptdb_total;

    TIOF0001.pc_calcula_valor_iof_prg (pr_tpproduto            => 2 -- Desconto de títulos
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
      vr_dscritic := 'Erro realizar cálculo do IOF em atraso : '||SQLERRM;
      RAISE vr_exc_erro;
    END IF;

    IF rw_craptdb.vliofcpl_restante > 0 AND vr_vlpagmto > 0 AND vr_flgimune <= 0 THEN
      IF rw_craptdb.vliofcpl_restante > vr_vlpagmto THEN
        vr_vlpagiof := vr_vlpagmto;
        --vr_flraspar := FALSE;
      ELSE
        vr_vlpagiof := rw_craptdb.vliofcpl_restante;
      END IF;

      vr_vlpagmto := vr_vlpagmto - vr_vlpagiof;

      -- Lançar valor da operação do IOF
      pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrborder => pr_nrborder
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdbandoc => pr_cdbandoc
                                   ,pr_nrdctabb => pr_nrdctabb
                                   ,pr_nrcnvcob => pr_nrcnvcob
                                   ,pr_nrdocmto => pr_nrdocmto
                                   ,pr_nrtitulo => rw_craptdb.nrtitulo
                                   ,pr_cdorigem => pr_idorigem
                                   ,pr_cdhistor => vr_cdhistordsct_iofcompleoper
                                   ,pr_vllanmto => vr_vlpagiof
                                   ,pr_dscritic => vr_dscritic );

      -- Insere dados do iof para o BI
      TIOF0001.pc_insere_iof(pr_cdcooper     => pr_cdcooper
                            ,pr_nrdconta     => pr_nrdconta
                            ,pr_dtmvtolt     => pr_dtmvtolt
                            ,pr_tpproduto    => 2   --> Desconto de Titulo
                            ,pr_nrcontrato   => pr_nrborder
                            ,pr_dtmvtolt_lcm => vr_dtmvtolt_lcm
                            ,pr_cdagenci_lcm => vr_cdagenci_lcm
                            ,pr_cdbccxlt_lcm => vr_cdbccxlt_lcm
                            ,pr_nrdolote_lcm => vr_nrdolote_lcm
                            ,pr_nrseqdig_lcm => rw_craptdb.nrtitulo
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
    IF rw_craptdb.vlmtatit_restante > 0 AND vr_vlpagmto > 0 THEN
      IF rw_craptdb.vlmtatit_restante > vr_vlpagmto THEN
        vr_vlpagmta := vr_vlpagmto;
      ELSE
        vr_vlpagmta := rw_craptdb.vlmtatit_restante;
      END IF;

      vr_vlpagmto := vr_vlpagmto - vr_vlpagmta;

      -- Lançar valor de apropriação da multa nos lançamentos do borderô
      pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrborder => pr_nrborder
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdbandoc => pr_cdbandoc
                                   ,pr_nrdctabb => pr_nrdctabb
                                   ,pr_nrcnvcob => pr_nrcnvcob
                                   ,pr_nrdocmto => pr_nrdocmto
                                   ,pr_nrtitulo => rw_craptdb.nrtitulo
                                   ,pr_cdorigem => pr_idorigem
                                   ,pr_cdhistor => vr_cdhistordsct_apropjurmta
                                   ,pr_vllanmto => vr_vlpagmta
                                   ,pr_dscritic => vr_dscritic );

      -- Condicao para verificar se houve critica
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;

    -- 3) Juros
    IF rw_craptdb.vlmratit_restante > 0 AND vr_vlpagmto > 0 THEN
      --Faz o pagamento do juros 60 (apenas no campo) para fazer a diferenciacao contabil em prejuizo
      --vljura60
      IF (rw_craptdb.vljura60_restante > vr_vlpagmto) THEN
        vr_vlpagm60 := vr_vlpagmto;
      ELSE
        vr_vlpagm60 := rw_craptdb.vljura60_restante;
      END IF;
      vr_vlpagmto := vr_vlpagmto - vr_vlpagm60;

      rw_craptdb.vlmratit_restante := rw_craptdb.vlmratit_restante - vr_vlpagm60;

      IF rw_craptdb.vlmratit_restante > vr_vlpagmto THEN
        vr_vlpagmra := vr_vlpagmto;
      ELSE
        vr_vlpagmra := rw_craptdb.vlmratit_restante;
      END IF;

      vr_vlpagmto := vr_vlpagmto - vr_vlpagmra;

      OPEN cr_lancboraprop(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrborder => pr_nrborder
                          ,pr_dtmvtolt => pr_dtmvtolt
                          ,pr_cdhistor => DSCT0003.vr_cdhistordsct_apropjurmra
                          ,pr_cdbandoc => pr_cdbandoc
                          ,pr_nrdctabb => pr_nrdctabb
                          ,pr_nrcnvcob => pr_nrcnvcob
                          ,pr_nrdocmto => pr_nrdocmto
                          );
      FETCH cr_lancboraprop INTO rw_lancboraprop;
      CLOSE cr_lancboraprop;

      -- Lançar valor de apropriação dos juros nos lançamentos do borderô
      pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrborder => pr_nrborder
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdbandoc => pr_cdbandoc
                                   ,pr_nrdctabb => pr_nrdctabb
                                   ,pr_nrcnvcob => pr_nrcnvcob
                                   ,pr_nrdocmto => pr_nrdocmto
                                   ,pr_nrtitulo => rw_craptdb.nrtitulo
                                   ,pr_cdorigem => pr_idorigem
                                   ,pr_cdhistor => vr_cdhistordsct_apropjurmra
                                   ,pr_vllanmto => (rw_craptdb.vlmratit - nvl(rw_lancboraprop.vllanmto,0))
                                   ,pr_dscritic => vr_dscritic );

      -- Condicao para verificar se houve critica
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END IF;

    -- 4) Valor do título
    IF rw_craptdb.vlsldtit > 0 AND vr_vlpagmto > 0 THEN
      IF rw_craptdb.vlsldtit > vr_vlpagmto THEN
        vr_vlpagtit := vr_vlpagmto;
        vr_vlsldtit := rw_craptdb.vlsldtit - vr_vlpagmto;
      ELSE
        vr_vlpagtit := rw_craptdb.vlsldtit;
        vr_vlsldtit := 0;
        vr_flbaixar := TRUE;
      END IF;

      vr_vlpagmto := vr_vlpagmto - vr_vlpagtit;

      -- Se a data de vencimento for maior que a data de pagamento, significa um pagamento adiantado, então
      -- realizar o lançamento de estorno na conta do cooperador dos juros cobrados até o vencimento
      IF rw_craptdb.dtvencto >= pr_dtmvtolt AND vr_flbaixar THEN
        dsct0001.pc_abatimento_juros_titulo(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrborder => pr_nrborder
                                           ,pr_cdbandoc => pr_cdbandoc
                                           ,pr_nrdctabb => pr_nrdctabb
                                           ,pr_nrcnvcob => pr_nrcnvcob
                                           ,pr_nrdocmto => pr_nrdocmto
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdagenci => pr_cdagenci -- apenas para o produto novo
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
    END IF;

    -- se o valor pago do boleto for maior que o saldo restante,
    IF (vr_vlpagmto > 0) THEN
      -- Faz o débito na operação do crédito que foi dado para o cooperado
      pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrborder => pr_nrborder
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdbandoc => pr_cdbandoc
                                   ,pr_nrdctabb => pr_nrdctabb
                                   ,pr_nrcnvcob => pr_nrcnvcob
                                   ,pr_nrdocmto => pr_nrdocmto
                                   ,pr_nrtitulo => rw_craptdb.nrtitulo
                                   ,pr_cdorigem => pr_idorigem
                                   ,pr_cdhistor => vr_cdhistordsct_deboppagmaior
                                   ,pr_vllanmto => vr_vlpagmto
                                   ,pr_dscritic => vr_dscritic );
      -- Condicao para verificar se houve critica
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- então lançar o saldo restante como crédito na conta corrente do cooperado
      pc_efetua_lanc_cc(pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => pr_cdagenci
                       ,pr_cdbccxlt => 100
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_vllanmto => vr_vlpagmto
                       ,pr_cdhistor => vr_cdhistordsct_credpagmaior
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

    pr_vlpagmto := vr_vlpagmto;

    -- chama a rotina de baixa do titulo
    vr_dtdpagto := null;
    IF vr_flbaixar THEN
        vr_insittit := 2;
        vr_dtdpagto := pr_dtmvtolt;
    ELSE
      vr_insittit := 4;
    END IF;

    BEGIN
      -- Atualiza as informações do título
      UPDATE craptdb
         SET craptdb.insittit = vr_insittit,
             craptdb.vlpagiof = craptdb.vlpagiof + vr_vlpagiof,
             craptdb.vlpagmta = craptdb.vlpagmta + vr_vlpagmta,
             craptdb.vlpagmra = craptdb.vlpagmra + vr_vlpagmra + vr_vlpagm60,
             craptdb.vlsldtit = vr_vlsldtit,
             craptdb.dtdpagto = nvl(vr_dtdpagto,craptdb.dtdpagto),
             craptdb.vlultmra = craptdb.vlmratit,
             craptdb.dtultpag = pr_dtmvtolt,
             craptdb.vlpgjm60 = craptdb.vlpgjm60 + vr_vlpagm60
       WHERE craptdb.rowid    = rw_craptdb.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar craptdb: '||SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
        RAISE vr_exc_erro;
    END;

    BEGIN
      -- Atualiza as informações do borderô
      UPDATE crapbdt bdt
         SET bdt.dtultpag = pr_dtmvtolt
       WHERE bdt.cdcooper = pr_cdcooper
         AND bdt.nrdconta = pr_nrdconta
         AND bdt.nrborder = pr_nrborder;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar craptdb: '||SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
        RAISE vr_exc_erro;
    END;

    -- se o título foi baixado
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
                                          ,pr_cdagenci => pr_cdagenci          --Codigo Agencia
                                          ,pr_cdbccxlt => 100                  --Codigo banco caixa
                                          ,pr_nrdolote => 8452                 --Numero do lote
                                          ,pr_tpdolote => 1                    --Tipo do lote
                                          ,pr_nrdocmto => 0                    --Numero do documento
                                          ,pr_nrdctabb => pr_nrdconta  --Numero da conta
                                          ,pr_nrdctitg => gene0002.fn_mask(pr_nrdconta,'99999999') --Numero da conta integracao
                                          ,pr_cdpesqbb => pr_nrdocmto          --Codigo pesquisa
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
                                            ,pr_cdcritic => vr_cdcritic   --Código do erro
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

    EXCEPTION
      WHEN vr_exc_erro THEN
      vr_cdcritic := NVL(vr_cdcritic, 0);
      IF vr_cdcritic > 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
      END IF;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;

    --END;
  END pc_pagar_titulo_operacao;

  PROCEDURE pc_pagar_titulo( pr_cdcooper    IN crapcop.cdcooper%TYPE           --Codigo Cooperativa
                            ,pr_cdagenci    IN INTEGER                         --Codigo Agencia
                            ,pr_nrdcaixa    IN INTEGER                         --Numero Caixa
                            ,pr_idorigem    IN INTEGER                         --Origem sistema
                            ,pr_cdoperad    IN VARCHAR2                        --Codigo operador
                            ,pr_nrdconta    IN craptdb.nrdconta%TYPE           --Número da conta do cooperado
                            ,pr_nrborder    IN craptdb.nrborder%TYPE           --Número do borderô
                            ,pr_cdbandoc    IN craptdb.cdbandoc%TYPE           --Codigo do banco impresso no boleto
                            ,pr_nrdctabb    IN craptdb.nrdctabb%TYPE           --Numero da conta base do titulo
                            ,pr_nrcnvcob    IN craptdb.nrcnvcob%TYPE           --Numero do convenio de cobranca
                            ,pr_nrdocmto    IN craptdb.nrdocmto%TYPE           --Numero do documento
                            ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE           --Data Movimento
                            ,pr_inproces    IN crapdat.inproces%TYPE DEFAULT 1 --Indicador do processo
                            ,pr_cdorigpg    IN NUMBER                DEFAULT 0 --Código da origem do processo de pagamento
                            ,pr_indpagto    IN crapcob.indpagto%TYPE DEFAULT 0 --Indica de onde vem o pagamento
                            ,pr_flpgtava    IN NUMBER                DEFAULT 0 --Pagamento efetuado pelo avalista 0-Não 1-Sim
                            ,pr_vlpagmto    IN OUT NUMBER                      --Valor do pagamento
                            ,pr_cdcritic    OUT INTEGER                        --Codigo Critica
                            ,pr_dscritic    OUT VARCHAR2) IS                   --Descricao Critica

  /* ................................................................................
     Programa: pc_pagar_titulo
     Sistema : Crédito
     Sigla   : CRED

     Autor   : Lucas Lazari (GFT)
     Data    : 24/05/18

     Dados referentes ao programa:
     Frequencia: Sempre que for chamado
     Objetivo  :  Realiza o pagamento de um título através da conta corrente

               pr_cdorigpg: Código da origem do processo de pagamento
                            0 - Conta-Corrente (Raspada, ...)
                            1 - Pagamento (Baixa de cobrança de títulos, ...)
                            2 - Pagamento COBTIT
                            3 - Tela PAGAR
                            4 - Sistema de Acordos
                            5 - Pagamento Boletagem Massiva

               pr_indpagto: Indica de onde vem o pagamento
                            0 - COMPE
                            1 - Caixa On-Line
                            2 - ?????
                            3 - Internet
                            4 - TAA

     Alterações: 24/08/2018 - Adicionar novo histórico de credito para desconto de titulo pago a maior
                              (vr_cdhistordsct_creddscttitpgm). Este será usado na pc_pagar_titulo quando
                              o valor pago do boleto for maior que o saldo restante. (Andrew Albuquerque (GFT))
                 14/09/2018 - Passar a gravar a data de último pagamento realizado no borderô (Andrew Albuquerque (GFT))
                 18/09/2018 - Adicionar nova origem 4 - Acordos. Alterações na procedure para suprir esta origem. (Andrew Albuquerque (GFT))
                 19/09/2018 - Alterado a regra de alimentação dos campos insittit, dtdpagto e dtdebito para considerar o código da origem do
                              processamento do pagamento pr_cdorigpg (Paulo Penteado GFT)
                 22/10/2018 - Retirado o lançamento do saldo remanescente na CC quando COBTIT (Vitor S. Assanuma - GFT)
                 27/11/2018 - Adicionado pagamento de juros60 para futuras contabilizacoes de prejuizo (Luis Fernando - GFT)
                 16/03/2019 - Corrige tratativa para valor de abono (Cássia de Oliveira - GFT)
  ..................................................................................*/

    /* CURSORES */

    CURSOR cr_crapbdt (pr_cdcooper IN crapbdt.cdcooper%type
                      ,pr_nrborder IN crapbdt.nrborder%type) IS
      SELECT crapbdt.txmensal
            ,crapbdt.flverbor
            ,crapbdt.vltaxiof
            ,crapbdt.vltxmult
            ,crapbdt.vltxmora
            ,crapbdt.inprejuz
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
             craptdb.vlsldtit + (craptdb.vliofcpl - craptdb.vlpagiof) +
             (craptdb.vlmtatit - craptdb.vlpagmta) + (craptdb.vlmratit - craptdb.vlpagmra) AS vltitulo_total,
             (craptdb.vliofcpl - craptdb.vlpagiof) AS vliofcpl_restante,
             (craptdb.vlmtatit - craptdb.vlpagmta) AS vlmtatit_restante,
             (craptdb.vlmratit - craptdb.vlpagmra) AS vlmratit_restante,
             (craptdb.vljura60 - craptdb.vlpgjm60) AS vljura60_restante
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


    CURSOR cr_lancboraprop(pr_cdcooper IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                          ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                          ,pr_nrborder IN crapbdt.nrborder%TYPE --> numero do bordero
                          ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE --> Data do movimento atual
                          ,pr_cdhistor IN craphis.cdhistor%TYPE --> Codigo do historico do lancamento
                          ,pr_cdbandoc IN craptdb.cdbandoc%TYPE --> Codigo do banco impresso no boleto
                          ,pr_nrdctabb IN craptdb.nrdctabb%TYPE --> Numero da conta base do titulo
                          ,pr_nrcnvcob IN craptdb.nrcnvcob%TYPE --> Numero do convenio de cobranca
                          ,pr_nrdocmto IN craptdb.nrdocmto%TYPE --> Numero do documento
                          ) IS
    SELECT SUM(lcb.vllanmto) vllanmto
      FROM tbdsct_lancamento_bordero lcb
     WHERE lcb.cdcooper = pr_cdcooper
       AND lcb.nrdconta = pr_nrdconta
       AND lcb.nrborder = pr_nrborder
       AND lcb.cdbandoc = pr_cdbandoc
       AND lcb.nrdctabb = pr_nrdctabb
       AND lcb.nrcnvcob = pr_nrcnvcob
       AND lcb.nrdocmto = pr_nrdocmto
       AND lcb.cdhistor = pr_cdhistor
       AND lcb.dtmvtolt <= pr_dtmvtolt;
    rw_lancboraprop cr_lancboraprop%ROWTYPE;

    -- TYPES
    TYPE typ_dados_tarifa IS RECORD
      (cdfvlcop crapcop.cdcooper%TYPE
      ,cdhistor craphis.cdhistor%TYPE
      ,vlrtarif NUMBER
      ,vltottar NUMBER);

    --Tipo de Tabela de Lancamento Tarifa
    --TYPE typ_tab_dados_tarifa IS TABLE OF typ_dados_tarifa INDEX BY VARCHAR2(4);


    -- VARIÁVEIS LOCAIS
    vr_cdbattar     VARCHAR2(1000);
    vr_cdhisest     INTEGER;
    vr_dtdivulg     DATE;
    vr_dtvigenc     DATE;

    vr_rowid_craplat  ROWID;

    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    vr_tab_erro GENE0001.typ_tab_erro; --Tabela de erros
    vr_des_erro VARCHAR2(10);

    vr_vlsldtit NUMBER; -- Saldo devedor atual do título
    vr_vlpagmto NUMBER; -- Valor disponível para pagamento do título

    vr_flbaixar BOOLEAN; -- Indica se o título deve sofrer baixa ou não
    vr_flraspar BOOLEAN; -- Indica se o processo de raspada deve continuar ou não

    vr_vliofpri NUMBER; -- Valor do IOF principal
    vr_vliofadi NUMBER; -- Valor do IOF adicional
    vr_vliofcpl NUMBER; -- Valor do IOF complementar

    vr_vlpagiof NUMBER; -- Valor pago do IOF complementar
    vr_vlpagmta NUMBER; -- Valor pago da multa
    vr_vlpagmra NUMBER; -- Valor pago dos juros de mora
    vr_vlpagtit NUMBER; -- Valor pago do título
    vr_vlpagm60 NUMBER; -- Valor pago do juros 60
    --vr_vlabatcc NUMBER; -- Valor de abatimento a ser creditado na conta do cooperado

    vr_insittit craptdb.insittit%TYPE;
    vr_dtdebito craptdb.dtdebito%TYPE;
    vr_dtdpagto craptdb.dtdpagto%TYPE;

    vr_cdhistor_opc INTEGER; -- Histórico de lançamento do titulo

    vr_vltxiofatra NUMBER;

    vr_dados_tarifa typ_dados_tarifa;

    vr_flgimune PLS_INTEGER;

    vr_cdpesqbb     VARCHAR2(1000);

    vr_dtmvtolt_lcm craplcm.dtmvtolt%TYPE;
    vr_cdagenci_lcm craplcm.cdagenci%TYPE;
    vr_cdbccxlt_lcm craplcm.cdbccxlt%TYPE;
    vr_nrdolote_lcm craplcm.nrdolote%TYPE;
    --vr_nrseqdig_lcm craplcm.nrseqdig%TYPE;

    -- EXCEÇÕES
    vr_exc_erro  EXCEPTION;

    -- FUNÇÕES

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

    -- Busca dados de pessoa jurídica
    OPEN cr_crapjur(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapjur INTO rw_crapjur;
    CLOSE cr_crapjur;

    -- Valida a existência do título
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

    -- Valida existência do borderô do respectivo título
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
    vr_vlpagm60 := 0;

    -- Faz lançamento de abono se tiver
    -- Se for boletagem massiva e o valor do titulo for maior que o valor do pagamento
    IF pr_cdorigpg = 5 AND NVL(rw_craptdb.vltitulo_total - pr_vlpagmto,0) > 0 THEN
      pc_efetua_lanc_cc(pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => pr_cdagenci
                       ,pr_cdbccxlt => 100
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_vllanmto => NVL(rw_craptdb.vltitulo_total - pr_vlpagmto,0)
                       ,pr_cdhistor => vr_cdhistordsct_credabonodscto
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
      -- Atualiza valor disponivel para pagamento
      vr_vlpagmto := rw_craptdb.vltitulo_total;
    END IF;

    -- 1) IOF

    vr_vltotal_liquido := 0;
    OPEN cr_craptdb_total(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrborder => pr_nrborder);
    FETCH cr_craptdb_total INTO vr_vltotal_liquido;
    CLOSE cr_craptdb_total;

    TIOF0001.pc_calcula_valor_iof_prg (pr_tpproduto            => 2 -- Desconto de títulos
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
      vr_dscritic := 'Erro realizar cálculo do IOF em atraso : '||SQLERRM;
      RAISE vr_exc_erro;
    END IF;

    IF rw_craptdb.vliofcpl_restante > 0 AND vr_flraspar AND vr_flgimune <= 0 THEN

      IF rw_craptdb.vliofcpl_restante > vr_vlpagmto THEN
        vr_vlpagiof := vr_vlpagmto;
        vr_flraspar := FALSE;
      ELSE
        vr_vlpagiof := rw_craptdb.vliofcpl_restante;
      END IF;

      vr_vlpagmto := vr_vlpagmto - vr_vlpagiof;

      -- Realiza o débito do IOF complementar na conta corrente do cooperado
      pc_efetua_lanc_cc(pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => pr_cdagenci
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
                            ,pr_nrseqdig_lcm => rw_craptdb.nrtitulo
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

      vr_vlpagmto := vr_vlpagmto - vr_vlpagmta;

      -- Realiza o débito da multa na conta corrente do cooperado
      pc_efetua_lanc_cc(pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => pr_cdagenci
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

      -- Lançar valor de pagamento da multa nos lançamentos do borderô
      pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrborder => pr_nrborder
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdbandoc => pr_cdbandoc
                                   ,pr_nrdctabb => pr_nrdctabb
                                   ,pr_nrcnvcob => pr_nrcnvcob
                                   ,pr_nrdocmto => pr_nrdocmto
                                   ,pr_nrtitulo => rw_craptdb.nrtitulo
                                   ,pr_cdorigem => pr_idorigem
                                   ,pr_cdhistor => CASE WHEN nvl(pr_flpgtava,0) = 0 THEN
                                                             vr_cdhistordsct_pgtomultaopc
                                                        ELSE vr_cdhistordsct_pgtomultaavopc END
                                   ,pr_vllanmto => vr_vlpagmta
                                   ,pr_dscritic => vr_dscritic );

      -- Condicao para verificar se houve critica
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Lançar valor de apropriação da multa nos lançamentos do borderô
      pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrborder => pr_nrborder
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdbandoc => pr_cdbandoc
                                   ,pr_nrdctabb => pr_nrdctabb
                                   ,pr_nrcnvcob => pr_nrcnvcob
                                   ,pr_nrdocmto => pr_nrdocmto
                                   ,pr_nrtitulo => rw_craptdb.nrtitulo
                                   ,pr_cdorigem => pr_idorigem
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
      --Faz o pagamento do juros 60 (apenas no campo) para fazer a diferenciacao contabil em prejuizo
      --vljura60
      IF (rw_craptdb.vljura60_restante > vr_vlpagmto) THEN
        vr_vlpagm60 := vr_vlpagmto;
        vr_flraspar := FALSE;
      ELSE
        vr_vlpagm60 := rw_craptdb.vljura60_restante;
      END IF;
      vr_vlpagmto := vr_vlpagmto - vr_vlpagm60;

      rw_craptdb.vlmratit_restante := rw_craptdb.vlmratit_restante - vr_vlpagm60;

      IF rw_craptdb.vlmratit_restante > vr_vlpagmto THEN
        vr_vlpagmra := vr_vlpagmto;
        vr_flraspar := FALSE;
      ELSE
        vr_vlpagmra := rw_craptdb.vlmratit_restante;
      END IF;

      vr_vlpagmto := vr_vlpagmto - vr_vlpagmra;

      -- Lança o valor dos juros de mora na conta do cooperado
      pc_efetua_lanc_cc(pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => pr_cdagenci
                       ,pr_cdbccxlt => 100
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_vllanmto => (vr_vlpagmra + vr_vlpagm60) -- A mora é sempre tratada como um valor só
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

      -- Lançar valor de pagamento dos juros nos lançamentos do borderô
      pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrborder => pr_nrborder
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdbandoc => pr_cdbandoc
                                   ,pr_nrdctabb => pr_nrdctabb
                                   ,pr_nrcnvcob => pr_nrcnvcob
                                   ,pr_nrdocmto => pr_nrdocmto
                                   ,pr_nrtitulo => rw_craptdb.nrtitulo
                                   ,pr_cdorigem => pr_idorigem
                                   ,pr_cdhistor => CASE WHEN nvl(pr_flpgtava,0) = 0 THEN
                                                             vr_cdhistordsct_pgtojurosopc
                                                        ELSE vr_cdhistordsct_pgtojurosavopc END
                                   ,pr_vllanmto => (vr_vlpagmra + vr_vlpagm60)
                                   ,pr_dscritic => vr_dscritic );

      -- Condicao para verificar se houve critica
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      OPEN cr_lancboraprop(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrborder => pr_nrborder
                          ,pr_dtmvtolt => pr_dtmvtolt
                          ,pr_cdhistor => DSCT0003.vr_cdhistordsct_apropjurmra
                          ,pr_cdbandoc => pr_cdbandoc
                          ,pr_nrdctabb => pr_nrdctabb
                          ,pr_nrcnvcob => pr_nrcnvcob
                          ,pr_nrdocmto => pr_nrdocmto
                          );
      FETCH cr_lancboraprop INTO rw_lancboraprop;
      CLOSE cr_lancboraprop;

      -- Lançar valor de apropriação dos juros nos lançamentos do borderô
      pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrborder => pr_nrborder
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdbandoc => pr_cdbandoc
                                   ,pr_nrdctabb => pr_nrdctabb
                                   ,pr_nrcnvcob => pr_nrcnvcob
                                   ,pr_nrdocmto => pr_nrdocmto
                                   ,pr_nrtitulo => rw_craptdb.nrtitulo
                                   ,pr_cdorigem => pr_idorigem
                                   ,pr_cdhistor => vr_cdhistordsct_apropjurmra
                                   ,pr_vllanmto => (rw_craptdb.vlmratit - nvl(rw_lancboraprop.vllanmto,0))
                                   ,pr_dscritic => vr_dscritic );

      -- Condicao para verificar se houve critica
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    END IF;

    -- 4) Valor do título
    IF rw_craptdb.vlsldtit > 0 AND vr_flraspar THEN
      -- Tratamentos conforme a origem do pagamento
      -- 0 - Conta-Corrente (Raspada, ...)
      IF pr_cdorigpg IN (0,4) THEN
        vr_cdhistor_opc := vr_cdhistordsct_pgtoopc; -- conta corrente

      -- 1 - Pagamento (Baixa de cobrança de títulos, ...)
      ELSIF pr_cdorigpg IN (1,5) THEN
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

        IF pr_cdorigpg = 1 THEN
          vr_vlpagmto := pr_vlpagmto;
        END IF;

      -- 3 - Tela PAGAR, 2 - COBTIT
      ELSIF pr_cdorigpg IN (2,3) THEN
        IF pr_flpgtava = 1 THEN
          vr_cdhistor_opc := vr_cdhistordsct_pgtoavalopc;
        ELSE
          vr_cdhistor_opc := vr_cdhistordsct_pgtoopc;
        END IF;

      -- origem de pagamento inválida
      ELSE
        vr_cdcritic := 0;
        vr_dscritic := 'Conteúdo inválido informado para o parâmentro dsct0003.pc_pagar_titulo.pr_cdorigpg';
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

      -- 0-Conta-Corrente  2-COBTIT  3-Tela PAGAR - 4-Sistema de Acordos
      IF pr_cdorigpg IN (0,2,3,4,5) THEN
        -- Debita o valor do título se o pagamento vier da conta corrente
        pc_efetua_lanc_cc(pr_dtmvtolt => pr_dtmvtolt
                         ,pr_cdagenci => pr_cdagenci
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

      -- Se a data de vencimento for maior que a data de pagamento, significa um pagamento adiantado, então
      -- realizar o lançamento de estorno na conta do cooperador dos juros cobrados até o vencimento
      IF rw_craptdb.dtvencto >= pr_dtmvtolt AND vr_flbaixar THEN
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

      -- Lançar valor do título nos lançamentos do borderô
      pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrborder => pr_nrborder
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_cdbandoc => pr_cdbandoc
                                   ,pr_nrdctabb => pr_nrdctabb
                                   ,pr_nrcnvcob => pr_nrcnvcob
                                   ,pr_nrdocmto => pr_nrdocmto
                                   ,pr_nrtitulo => rw_craptdb.nrtitulo
                                   ,pr_cdorigem => pr_idorigem
                                   ,pr_cdhistor => vr_cdhistor_opc
                                   ,pr_vllanmto => vr_vlpagtit
                                   ,pr_dscritic => vr_dscritic );

    END IF;

    pr_vlpagmto := vr_vlpagmto;

    -- chama a rotina de baixa do titulo
      vr_dtdebito := null;
      vr_dtdpagto := null;
    IF vr_flbaixar THEN
      IF pr_cdorigpg = 1 THEN
        vr_insittit := 2;
        vr_dtdpagto := pr_dtmvtolt;
      ELSE
        IF pr_idorigem = 7 THEN -- raspada
          IF (pr_dtmvtolt = rw_craptdb.dtvencto) THEN
            vr_insittit := 2;
            vr_dtdpagto := pr_dtmvtolt;
          ELSE
            vr_insittit := 3;
            vr_dtdebito := pr_dtmvtolt;
          END IF;
        ELSE
        vr_insittit := 3;
        vr_dtdebito := pr_dtmvtolt;
      END IF;
      END IF;
    ELSE
      vr_insittit := 4;
    END IF;

    BEGIN
      -- Atualiza as informações do título
      UPDATE craptdb
         SET craptdb.insittit = vr_insittit,
             craptdb.vlpagiof = craptdb.vlpagiof + vr_vlpagiof,
             craptdb.vlpagmta = craptdb.vlpagmta + vr_vlpagmta,
             craptdb.vlpagmra = craptdb.vlpagmra + vr_vlpagmra + vr_vlpagm60,
             craptdb.vlsldtit = vr_vlsldtit,
             craptdb.dtdebito = nvl(vr_dtdebito,craptdb.dtdebito),
             craptdb.dtdpagto = nvl(vr_dtdpagto,craptdb.dtdpagto),
             craptdb.vlultmra = craptdb.vlmratit,
             craptdb.dtultpag = pr_dtmvtolt,
             craptdb.vlpgjm60 = craptdb.vlpgjm60 + vr_vlpagm60
       WHERE craptdb.rowid    = rw_craptdb.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar craptdb: '||SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
        RAISE vr_exc_erro;
    END;

    BEGIN
      -- Atualiza as informações do borderô
      UPDATE crapbdt bdt
         SET bdt.dtultpag = pr_dtmvtolt
       WHERE bdt.cdcooper = pr_cdcooper
         AND bdt.nrdconta = pr_nrdconta
         AND bdt.nrborder = pr_nrborder;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar craptdb: '||SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
        RAISE vr_exc_erro;
    END;

    -- se o título foi baixado
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

      --  Busca valor da tarifa sem registro
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
         -- Gera Tarifa de titulos descontados
         TARI0001.pc_cria_lan_auto_tarifa (pr_cdcooper => pr_cdcooper  --Codigo Cooperativa
                                          ,pr_nrdconta => pr_nrdconta  --Numero da Conta
                                          ,pr_dtmvtolt => pr_dtmvtolt          --Data Lancamento
                                          ,pr_cdhistor => vr_dados_tarifa.cdhistor --Codigo Historico
                                          ,pr_vllanaut => vr_dados_tarifa.vlrtarif --Valor lancamento automatico
                                          ,pr_cdoperad => 1          --Codigo Operador
                                          ,pr_cdagenci => pr_cdagenci          --Codigo Agencia
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
                                            ,pr_cdcritic => vr_cdcritic   --Código do erro
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

    EXCEPTION
      WHEN vr_exc_erro THEN
      vr_cdcritic := NVL(vr_cdcritic, 0);
      IF vr_cdcritic > 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
      END IF;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;

    --END;
  END pc_pagar_titulo;

  PROCEDURE pc_efetua_lanc_cc (pr_dtmvtolt  IN craplcm.dtmvtolt%TYPE -- Origem: do lote de liberação (craplot)
                              ,pr_cdagenci  IN craplcm.cdagenci%TYPE -- Origem: do lote de liberação (craplot)
                              ,pr_cdbccxlt  IN craplcm.cdbccxlt%TYPE -- Origem: do lote de liberação (craplot)
                              ,pr_nrdconta  IN craplcm.nrdconta%TYPE -- Origem: nrdconta do Bordero
                              ,pr_vllanmto  IN craplcm.vllanmto%TYPE -- Origem: do cálculo :aux_vlborder + craptdb.vlliquid da linha 1870.
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
      Programa : pc_efetua_lanc_cc        Antigo: b1wgen0030.p/efetua_liber_anali_bordero (Trecho de Liberação)
      Sistema  : Procedure para lançar crédito de desconto de Título
      Sigla    : CRED
      Autor    : Andrew Albuquerque (GFT)
      Data     : Abril/2018

      Objetivo  : Procedure para laçamento de crédito de desconto de Título.

      Alteracoes: 16/04/2018 - Criação (Andrew Albuquerque (GFT))
                  23/07/2018 - Inserção de loop para inserir na LCM
    ----------------------------------------------------------------------------------------------------------*/
    vr_nrdolote craplot.nrdolote%TYPE;
    vr_flg_criou_lot BOOLEAN;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    vr_exc_erro EXCEPTION;

    vr_nrseqdig NUMBER;

  BEGIN
    vr_flg_criou_lot := FALSE;

    WHILE NOT vr_flg_criou_lot LOOP

      vr_nrdolote := fn_sequence(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRDOLOTE'
                                ,pr_dsdchave => TO_CHAR(pr_cdcooper)|| ';'
                                             || TO_CHAR(pr_dtmvtolt, 'DD/MM/RRRR') || ';'
                                                || TO_CHAR(pr_cdagenci)|| ';'
                                                || '100');

      -- [PROJETO LIGEIRINHO] Esta função retorna verdadeiro, quando o processo foi iniciado pela rotina:
      -- PAGA0001.pc_efetua_debitos_paralelo, que é chamada na rotina PC_CRPS509. Tem por finalidade definir
      -- se grava na tabela CRAPLOT no momento em que esta rodando a esta rotina OU somente no final da execucação
      -- da PC_CRPS509, para evitar o erro de lock da tabela, pois esta gravando a agencia 90,91 ou 1 ao inves de gravar
      -- a agencia do cooperado
      IF  NOT paga0001.fn_exec_paralelo THEN

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
                 ,/*03*/ pr_cdagenci
                 ,/*04*/ 100
                 ,/*05*/ vr_nrdolote
                 ,/*06*/ 1
                 ,/*07*/ pr_cdoperad
                 ,/*08*/ pr_cdhistor)
          RETURNING nrseqdig, ROWID INTO rw_craplot.nrseqdig, rw_craplot.rowid;
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            CONTINUE;
          WHEN OTHERS THEN
            -- Gera crítica
            vr_dscritic := 'Erro ao inserir novo lote CC (1) ' || SQLERRM;
            -- Levanta exceção
            RAISE vr_exc_erro;
        END;

          vr_nrseqdig := NVL(rw_craplot.nrseqdig,0) + 1;

      ELSE
          paga0001.pc_insere_lote_wrk(pr_cdcooper => pr_cdcooper
                                     ,pr_dtmvtolt => pr_dtmvtolt
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_cdbccxlt => 100
                                     ,pr_nrdolote => vr_nrdolote
                                     ,pr_cdoperad => pr_cdoperad
                                     ,pr_nrdcaixa => NULL
                                     ,pr_tplotmov => 1
                                     ,pr_cdhistor => pr_cdhistor
                                     ,pr_cdbccxpg => NULL
                                     ,pr_nmrotina => 'DSCT0003.PC_EFETUA_LANC_CC');

          vr_nrseqdig := PAGA0001.fn_seq_parale_craplcm;
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
        VALUES (/*01*/ pr_dtmvtolt
               ,/*02*/ pr_cdagenci
               ,/*03*/ 100
               ,/*04*/ vr_nrdolote
               ,/*05*/ pr_nrdconta
               ,/*06*/ pr_nrdocmto
               ,/*07*/ pr_vllanmto
               ,/*08*/ pr_cdhistor
               ,/*09*/ vr_nrseqdig
               ,/*10*/ pr_nrdconta
               ,/*11*/ 0
               ,/*12*/ pr_cdcooper
               ,/*13*/ 'Desconto de Título do Borderô ' || pr_nrborder);
      EXCEPTION
        -- Caso nao consiga inserir o LCM por dupkey, refaz toda a transação
        WHEN DUP_VAL_ON_INDEX THEN
             CONTINUE;
        WHEN OTHERS THEN
             CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
             vr_cdcritic := 1034;
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                             'craplcm:' ||
                             ', dtmvtolt:'  || pr_dtmvtolt  ||
                             ', cdagenci:'  || pr_cdagenci  ||
                             ', cdbccxlt:'  || '100'        ||
                             ', nrdolote:'  || vr_nrdolote  ||
                             ', nrdconta:'  || pr_nrdconta  ||
                             ', nrdocmto:'  || pr_nrdocmto  ||
                             ', vllanmto:'  || pr_vllanmto  ||
                             ', cdhistor:'  || pr_cdhistor  ||
                             ', nrseqdig:'  || vr_nrseqdig  ||
                             ', nrdctabb:'  || pr_nrdconta  ||
                             ', nrautdoc:'  || '0'          ||
                             ', cdcooper:'  || pr_cdcooper  ||
                             ', cdpesqbb:'  || pr_nrdocmto  ||
                             '. ' ||sqlerrm;
             RAISE vr_exc_erro;
      END;
      vr_flg_criou_lot := TRUE;
    END LOOP;

    -- [PROJETO LIGEIRINHO]
    IF  NOT paga0001.fn_exec_paralelo THEN
        BEGIN
          UPDATE craplot
          SET    craplot.nrseqdig = vr_nrseqdig
                ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                ,craplot.vlinfocr = nvl(craplot.vlinfocr,0) + pr_vllanmto
                ,craplot.vlcompcr = nvl(craplot.vlcompcr,0) + pr_vllanmto
          WHERE  craplot.rowid = rw_craplot.rowid;
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
         pr_dscritic := 'Erro geral na rotina DSCT0003.pc_efetua_lanc_cc: ' || SQLERRM;
  END pc_efetua_lanc_cc;

  PROCEDURE pc_processa_liquidacao_cobtit(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                         ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                         ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE
                                         ,pr_nrctasac  IN crapcob.nrctasac%TYPE
                                         ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE
                                         ,pr_vlpagmto  IN NUMBER                --> Valor do pagamento
                                         ,pr_indpagto  IN crapcob.indpagto%TYPE --> Indicador pagamento
                                         ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Código do Operador
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

      Objetivo  : Efetuar a liquidação de titulos gerados pela cobrança COBTIT

      Alteração : 10/06/2018 - Criação (Paulo Penteado (GFT))
                  16/10/2018 - Alteração para verificar se o borderô está em prejuízo e retirar os titulos em acordo (Vitor S. Assanuma (GFT))

    ----------------------------------------------------------------------------------------------------------*/
    TYPE tpy_ref_tdb IS REF CURSOR;
    cr_craptdb       tpy_ref_tdb;
    vr_sql           VARCHAR2(32767);

    vr_tab_tit_bordero typ_tab_tit_bordero;
    vr_vlpagmto        NUMBER(25,2);
    vr_vlpagmto_rest   NUMBER(25,2);
    vr_vlabono         NUMBER(25,2);
    vr_liquidou        INTEGER;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    vr_cdorigpg NUMBER; -- Indica se foi emitido pela COBTIT ou pela Boletagem Massiva

    CURSOR cr_cde IS
    SELECT cde.nrctremp,
           cde.nrdconta,
           cde.dsparcelas,
           cde.nrcpfava,
           cde.vldesconto,
           cde.tpparcela,
           cde.idarquivo
      FROM tbrecup_cobranca cde
     WHERE cde.tpproduto = 3
       AND cde.nrdconta = pr_nrctasac
       AND cde.nrboleto = pr_nrdocmto
       AND cde.nrcnvcob = pr_nrcnvcob
       AND cde.nrdconta_cob = pr_nrdconta
       AND cde.cdcooper = pr_cdcooper;
    rw_cde cr_cde%ROWTYPE;

    -- Cursor para verificar se está em prejuízo.
    CURSOR cr_crapbdt (pr_cdcooper crapbdt.cdcooper%TYPE
                      ,pr_nrborder crapbdt.nrborder%TYPE) IS
      SELECT bdt.inprejuz,
             bdt.nrborder,
             bdt.cdcooper,
             nvl(SUM(tdb.vlsdprej + (tdb.vlttjmpr - tdb.vlpgjmpr) + (tdb.vlttmupr - tdb.vlpgmupr) +
                     (tdb.vljraprj - tdb.vlpgjrpr) + (tdb.vliofprj - tdb.vliofppr)),
                 0) AS vl_prejuz
        FROM crapbdt bdt
        LEFT JOIN craptdb tdb
          ON bdt.cdcooper = tdb.cdcooper
     AND bdt.nrborder = tdb.nrborder
     AND bdt.nrdconta = tdb.nrdconta
     AND tdb.insittit = 4
       WHERE bdt.cdcooper = pr_cdcooper
         AND bdt.nrborder = pr_nrborder
       GROUP BY bdt.inprejuz,
                bdt.nrborder,
                bdt.cdcooper;
    rw_crapbdt cr_crapbdt%ROWTYPE;
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

          -- Se o boleto possui um IDARQUIVO preenchido, significa que ele foi emitido pela boletagem massiva
          IF rw_cde.idarquivo <> 0 THEN
            vr_cdorigpg := 5; -- Boletagem massiva
          ELSE
            vr_cdorigpg := 2; -- COBTIT
          END IF;

          -- Verifica se o borderô está em prejuízo
          OPEN cr_crapbdt(pr_cdcooper, rw_cde.nrctremp);
          FETCH cr_crapbdt INTO rw_crapbdt;
          IF    cr_crapbdt%NOTFOUND THEN
            CLOSE cr_crapbdt;
            vr_dscritic := 'Borderô não encontrado.';
            RAISE vr_exc_erro;
          END IF;
          CLOSE cr_crapbdt;

          -- Caso não esteja, segue o fluxo de pagamento título a título.
          IF rw_crapbdt.inprejuz = 0 THEN
          vr_sql := 'SELECT tmp.* '||
                          ', rownum nrnumlin, count(1) over() qttotlin '||
                    'FROM ( '||
                    'SELECT tdb.cdbandoc, tdb.nrdctabb, tdb.nrcnvcob, tdb.nrdocmto, tdb.nrtitulo '||
                          ',tdb.vlsldtit + (tdb.vliofcpl - tdb.vlpagiof) + (tdb.vlmtatit - tdb.vlpagmta) + (tdb.vlmratit - tdb.vlpagmra) vltitulo_total '||
                    'FROM   craptdb tdb '||
                      ' LEFT JOIN crapbdt bdt                 ON bdt.cdcooper = tdb.cdcooper AND bdt.nrborder = tdb.nrborder ' ||
                      ' LEFT JOIN tbdsct_titulo_cyber ttc     ON ttc.cdcooper = tdb.cdcooper AND ttc.nrdconta = tdb.nrdconta AND ttc.nrborder = tdb.nrborder AND ttc.nrtitulo = tdb.nrtitulo ' ||
                      ' LEFT JOIN tbrecup_acordo_contrato tac ON ttc.nrctrdsc = tac.nrctremp AND tac.cdorigem = 4 ' ||
                      ' LEFT JOIN tbrecup_acordo ta           ON tac.nracordo = ta.nracordo  AND ta.cdcooper = ttc.cdcooper AND ta.nrdconta = ttc.nrdconta AND ta.cdsituacao <> 3 ' ||
                    'WHERE  tdb.nrborder = :nrborder '||
                    'AND    tdb.nrdconta = :nrdconta '||
                    'AND    tdb.cdcooper = :cdcooper '||
                    'AND    tdb.nrtitulo in ('||rw_cde.dsparcelas||') '||
                      'AND    ta.nracordo IS NULL ' ||
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

            -- verificar se é o último titulo da lista da COBTIT
            IF vr_tab_tit_bordero(1).nrnumlin = vr_tab_tit_bordero(1).qttotlin THEN
              vr_vlpagmto := vr_vlpagmto_rest;
            ELSE
              vr_vlpagmto_rest := vr_vlpagmto_rest - vr_tab_tit_bordero(1).vltitulo;
              vr_vlpagmto      := vr_tab_tit_bordero(1).vltitulo;
            END IF;
              IF vr_tab_tit_bordero(1).vltitulo > 0 THEN
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
                               ,pr_cdorigpg => vr_cdorigpg -- COBTIT/Boletagem Massiva
                           ,pr_indpagto => pr_indpagto
                           ,pr_flpgtava => CASE WHEN rw_cde.nrcpfava IS NULL THEN 0 ELSE 1 END
                           ,pr_vlpagmto => vr_vlpagmto
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);

            IF NVL(vr_cdcritic,0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
              END IF;
          END   LOOP;
          CLOSE cr_craptdb;
          ELSE
            IF (rw_crapbdt.vl_prejuz > 0) THEN
              -- Caso seja TOTAL ou PARCIAL, não há abono
              vr_vlabono  := 0;

              IF rw_cde.tpparcela = 7 THEN
              -- Valor de abono é o valor de prejuizo menos o de pagamento
              vr_vlabono  := rw_crapbdt.vl_prejuz - vr_vlpagmto;

              -- Valor de pagamento para liquidar o prejuízo
              vr_vlpagmto := rw_crapbdt.vl_prejuz - vr_vlabono;
              END IF;

              PREJ0005.pc_pagar_bordero_prejuizo(pr_cdcooper => pr_cdcooper
                                                ,pr_nrborder => rw_cde.nrctremp
                                                ,pr_vlaboorj => vr_vlabono
                                                ,pr_vlpagmto => vr_vlpagmto
                                                ,pr_cdoperad => pr_cdoperad
                                                ,pr_cdagenci => pr_cdagenci
                                                ,pr_nrdcaixa => pr_nrdcaixa
                                                ,pr_cdorigem => 2 -- COBTIT
                                                -- OUT --
                                                ,pr_liquidou => vr_liquidou
                                                ,pr_cdcritic => vr_cdcritic
                                                ,pr_dscritic => vr_dscritic);
               IF NVL(vr_cdcritic,0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
                 RAISE vr_exc_erro;
               END IF;
            END IF;
          END IF;
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

  PROCEDURE pc_expira_bordero (pr_cdcooper    IN crapbdt.cdcooper%TYPE --> Cooperativa
                              ,pr_nrborder    IN crapbdt.nrborder%TYPE --> numero do bordero
                              --------> OUT <--------
                              ,pr_cdcritic OUT PLS_INTEGER             --> código da crítica
                              ,pr_dscritic OUT VARCHAR2                --> descrição da crítica
                              ) IS
      /*---------------------------------------------------------------------------------------------------------------------
        Programa  : pc_expira_bordero
        Sistema   :
        Sigla     : CRED
        Autor     : Vitor Shimada Assanuma (GFT)
        Data      : 18/08/2018
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para expirar um bordero específico.
      ---------------------------------------------------------------------------------------------------------------------*/
      -- Tratamento de erro
      vr_exc_erro EXCEPTION;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%type; --> cód. erro
      vr_dscritic varchar2(1000);        --> desc. erro

      -- Retorno da TAB052 para Cooperativa e Cobrança Registrada
      vr_tab_dados_dsctit    dsct0002.typ_tab_dados_dsctit;
      vr_tab_cecred_dsctit   dsct0002.typ_tab_cecred_dsctit;

      -- Busca o bordero
      CURSOR cr_crapbdt IS
      SELECT bdt.cdcooper,
             bdt.nrdconta,
             bdt.nrborder,
             GREATEST(nvl(bdt.dtanabor, bdt.dtmvtolt),
                      nvl(bdt.dtenvmch, bdt.dtmvtolt),
                      nvl(bdt.dtaprova, bdt.dtmvtolt)) AS dtalteracao
        FROM crapbdt bdt
       WHERE bdt.cdcooper = pr_cdcooper
         AND bdt.nrborder = pr_nrborder
         AND bdt.insitbdt < 3; -- Em estudo e Analisado
      rw_crapbdt cr_crapbdt%ROWTYPE;

      -- Busca o tipo de pessoa
      CURSOR cr_crapass(pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapass.inpessoa
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      BEGIN
        -- Leitura do calendário da cooperativa
        OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH btch0001.cr_crapdat into rw_crapdat;
        CLOSE btch0001.cr_crapdat;

        -- Abre o cursor da BDT para buscar o bordero
        OPEN cr_crapbdt;
        FETCH cr_crapbdt INTO rw_crapbdt;

        -- Valida o bordero
        IF cr_crapbdt%NOTFOUND THEN
          CLOSE cr_crapbdt;
          vr_dscritic := 'Borderô não encontrado.';
          RAISE vr_exc_erro;
        END IF;
        CLOSE cr_crapbdt;

        -- Abre o cursor para ir buscar o tipo da conta PF/PJ
        OPEN cr_crapass(rw_crapbdt.nrdconta);
        FETCH cr_crapass INTO rw_crapass;

        -- Valida o Associado
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          vr_dscritic := 'Associado não encontrado.';
          RAISE vr_exc_erro;
        END IF;
        CLOSE cr_crapass;

        -- Busca os Parâmetros para o Cooperado e Cobrança Com Registro
        DSCT0002.pc_busca_parametros_dsctit(pr_cdcooper,         -- Cooperativa
                                            NULL,                -- Agencia de operação
                                            NULL,                -- Número do caixa
                                            NULL,                -- Operador
                                            NULL,                -- Data da Movimentação
                                            NULL,                -- Identificação de origem
                                            1,                   -- Tipo de Cobrança: 1: REGISTRADA / 0: NÃO REGISTRADA
                                            rw_crapass.inpessoa, -- 1: PESSOA FÍSICA / 2: PESSOA JURÍDICA
                                            -- OUT --
                                            vr_tab_dados_dsctit,
                                            vr_tab_cecred_dsctit,
                                            vr_cdcritic,
                                            vr_dscritic);
        IF ((NVL(vr_cdcritic, 0) > 0) OR (vr_dscritic IS NOT NULL)) THEN
          RAISE vr_exc_erro;
        END IF;

        -- Caso a data da ultima alteração do bordero + qtd. dias de expiração for menor que a data de movimento, expira.
        IF (to_date(to_char(rw_crapbdt.dtalteracao + vr_tab_dados_dsctit(1).qtdiexbo, 'DD/MM/RRRR'),'DD/MM/RRRR') < rw_crapdat.dtmvtolt)THEN
          -- Atualiza o bordero com REJEITADO e PRAZO EXPIRADO
          pc_altera_status_bordero(pr_cdcooper => rw_crapbdt.cdcooper
                                  ,pr_nrborder => rw_crapbdt.nrborder
                                  ,pr_nrdconta => rw_crapbdt.nrdconta
                                  ,pr_status   => 5                          -- Rejeitado
                                  ,pr_insitapr => 7                          -- Prazo Expirado
                                  ,pr_dtrejeit => rw_crapdat.dtmvtolt        -- Data de rejeição
                                  ,pr_hrrejeit => to_char(sysdate,'SSSSS')   -- Hora de rejeião
                                  ,pr_dscritic => vr_dscritic                -- Se houver registro de crítica
                                  );
          IF (vr_dscritic IS NOT NULL) THEN
              RAISE vr_exc_erro;
          END IF;

          -- Altera a decisao de todos os titulos daquele bordero para NAO APROVADOS
          BEGIN
            UPDATE craptdb
               SET insittit = 0,
                   insitapr = 2
             WHERE nrborder = rw_crapbdt.nrborder
               AND cdcooper = rw_crapbdt.cdcooper
               AND nrdconta = rw_crapbdt.nrdconta;
            COMMIT;
          EXCEPTION
            WHEN OTHERS THEN
              ROLLBACK;
              vr_dscritic := 'Erro ao atualizar a craptdb, bordero: '|| rw_crapbdt.nrborder || ' em DSCT0003.pc_expira_bordero'||SQLERRM;
              RAISE vr_exc_erro;
          END;
        END IF;
      EXCEPTION
        WHEN vr_exc_erro THEN
             -- Se foi retornado apenas código busca a descrição
             IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
                 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
             END IF;
             -- Variavel de erro recebe erro ocorrido
             pr_cdcritic := nvl(vr_cdcritic,0);
             pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
             pr_dscritic := 'Erro nao tratado na DSCT0003.pc_expira_bordero ' ||SQLERRM;
  END pc_expira_bordero;

 PROCEDURE pc_expira_borderos_coop (pr_cdcooper    IN crapbdt.cdcooper%TYPE DEFAULT 0 --> Cooperativa
                                   --------> OUT <--------
                                   ,pr_cdcritic OUT PLS_INTEGER                       --> código da crítica
                                   ,pr_dscritic OUT VARCHAR2                          --> descrição da crítica
                                   ) IS
      /*---------------------------------------------------------------------------------------------------------------------
        Programa  : pc_expira_borderos_coop
        Sistema   :
        Sigla     : CRED
        Autor     : Vitor Shimada Assanuma (GFT)
        Data      : 18/08/2018
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para expirar os borderos de uma cooperativa
      ---------------------------------------------------------------------------------------------------------------------*/
      -- Tratamento de erro
      vr_exc_erro EXCEPTION;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%type; --> cód. erro
      vr_dscritic varchar2(1000);        --> desc. erro

      -- Busca o bordero, caso nao seja passado cdcooper, pega de todas as cooperativas.
      CURSOR cr_crapbdt IS
      SELECT bdt.cdcooper,
             bdt.nrborder
        FROM crapbdt bdt
       WHERE bdt.cdcooper = decode(pr_cdcooper, 0, bdt.cdcooper, pr_cdcooper)  -- Caso seja passado a coop
         AND bdt.cdcooper IN (SELECT cdcooper
                                FROM crapcop
                               WHERE flgativo = 1) -- Somente cooperativas ativas
         AND bdt.insitbdt < 3; -- Em estudo e Analisado
      rw_crapbdt cr_crapbdt%ROWTYPE;

      BEGIN
        -- Abre o cursor da BDT para buscar o bordero
        OPEN cr_crapbdt;
        LOOP
          FETCH cr_crapbdt INTO rw_crapbdt;
          EXIT WHEN cr_crapbdt%NOTFOUND;
          -- Chama a rotina de expirar bordero
          pc_expira_bordero(pr_cdcooper => rw_crapbdt.cdcooper
                           ,pr_nrborder => rw_crapbdt.nrborder
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);

          -- Valida a procedure de expirar o bordero
          IF ((NVL(vr_cdcritic, 0) > 0) OR (vr_dscritic IS NOT NULL)) THEN
            RAISE vr_exc_erro;
          END IF;
        END LOOP;
        CLOSE cr_crapbdt;
      EXCEPTION
        WHEN vr_exc_erro THEN
             -- Se foi retornado apenas código busca a descrição
             IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
                 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
             END IF;
             -- Variavel de erro recebe erro ocorrido
             pr_cdcritic := nvl(vr_cdcritic,0);
             pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
             pr_dscritic := 'Erro nao tratado na DSCT0003.pc_expira_borderos_coop ' ||SQLERRM;
  END pc_expira_borderos_coop;

  PROCEDURE pc_calcula_risco_bordero(pr_cdcooper IN crapbdt.cdcooper%TYPE
                                     ,pr_nrborder IN crapbdt.nrborder%TYPE
                                     --------> OUT <--------
                                     ,pr_dsinrisc OUT VARCHAR2                    --> Risco
                                     ,pr_cdcritic OUT PLS_INTEGER                 --> código da crítica
                                     ,pr_dscritic OUT VARCHAR2                    --> descrição da crítica
                                     ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa  : pc_calcula_risco_bordero
    Sistema   :
    Sigla     : CRED
    Autor     : Luis Fernando (GFT)
    Data      : 22/08/2018
    Frequencia: Rotina diária da central de risco
    Objetivo  : Atualizar o risco do borderô conforme as datas
  ---------------------------------------------------------------------------------------------------------------------*/

    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%type;
    vr_dscritic varchar2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
    -- Variaveis para o calculo
    vr_inrisccalculado number := 2; -- começa como A
    vr_riscoatual      number := 2; -- começa como A
    vr_dias            number := 0; -- dias do vencimento até a data de movimento
    vr_qtrisccalculado NUMBER := 0;

    CURSOR cr_crapbdt IS
    SELECT bdt.rowid AS id,
           bdt.nrborder,
           bdt.nrinrisc,
           bdt.qtdirisc,
           bdt.insitbdt,
           bdt.dtmvtolt,
           bdt.nrdconta,
           bdt.inprejuz,
           bdt.dtprejuz
      FROM crapbdt bdt
     WHERE bdt.nrborder = pr_nrborder
       AND bdt.cdcooper = pr_cdcooper;
    rw_crapbdt cr_crapbdt%ROWTYPE;

    CURSOR cr_craptdb (pr_nrdconta crapbdt.nrdconta%type) IS
    SELECT tdb.dtvencto,
           tdb.dtlibbdt,
           tdb.insittit
      FROM craptdb tdb
     WHERE tdb.cdcooper = pr_cdcooper
       AND tdb.nrborder = pr_nrborder
       AND tdb.nrdconta = pr_nrdconta
       AND tdb.insittit = 4; -- apenas liberados
    rw_craptdb cr_craptdb%ROWTYPE;
    BEGIN
      --    Leitura do calendário da cooperativa
      OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat into rw_crapdat;
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        vr_cdcritic := 1;
        CLOSE BTCH0001.cr_crapdat;
        RAISE vr_exc_erro;
      END IF;
      CLOSE BTCH0001.cr_crapdat;

      OPEN cr_crapbdt;
      FETCH cr_crapbdt INTO rw_crapbdt;
      IF (cr_crapbdt%NOTFOUND) THEN
        CLOSE cr_crapbdt;
        vr_cdcritic := 1166; -- Bordero nao encontrado
        raise vr_exc_erro;
      END IF;
      CLOSE cr_crapbdt;

      IF (rw_crapbdt.insitbdt <> 3) THEN
        vr_cdcritic := 1175; -- Bordero deve estar LIBERADO
        raise vr_exc_erro;
      END IF;

      IF (rw_crapbdt.inprejuz = 1) THEN
        rw_crapbdt.qtdirisc := rw_crapdat.dtmvtolt-rw_crapbdt.dtprejuz;
        rw_crapbdt.nrinrisc := 10;
      ELSE
      OPEN cr_craptdb (pr_nrdconta=>rw_crapbdt.nrdconta);
      LOOP FETCH cr_craptdb INTO rw_craptdb;
        EXIT WHEN cr_craptdb%NOTFOUND;
        vr_dias := rw_crapdat.dtmvtolt-rw_craptdb.dtvencto;
        vr_riscoatual :=CASE
                          WHEN (vr_dias < 15) THEN 2
                          WHEN (vr_dias < 31) THEN 3
                          WHEN (vr_dias < 61) THEN 4
                          WHEN (vr_dias < 91) THEN 5
                          WHEN (vr_dias < 121) THEN 6
                          WHEN (vr_dias < 151) THEN 7
                          WHEN (vr_dias < 181) THEN 8
                          ELSE 9
                        END;
        -- Calcula o pior risco dos títulos e guarda para o bordero
        IF (vr_riscoatual>vr_inrisccalculado) THEN
          vr_inrisccalculado := vr_riscoatual;
        END IF;
        IF (vr_qtrisccalculado<vr_dias) THEN
          vr_qtrisccalculado := vr_dias;
        END IF;
      END LOOP;
      CLOSE cr_craptdb;
      vr_qtrisccalculado := ABS(vr_qtrisccalculado);
      rw_crapbdt.nrinrisc := vr_inrisccalculado;
      rw_crapbdt.qtdirisc := CASE
                        WHEN (vr_inrisccalculado = 2) THEN rw_crapdat.dtmvtolt - rw_crapbdt.dtmvtolt
                        WHEN (vr_inrisccalculado = 3) THEN vr_qtrisccalculado-15 -- entre 15 e 31
                        WHEN (vr_inrisccalculado = 4) THEN vr_qtrisccalculado-30 -- entre 31 e 60
                        WHEN (vr_inrisccalculado = 5) THEN vr_qtrisccalculado-60 -- entre 61 e 90
                        WHEN (vr_inrisccalculado = 6) THEN vr_qtrisccalculado-90 -- entre 91 e 120
                        WHEN (vr_inrisccalculado = 7) THEN vr_qtrisccalculado-120 -- entre 121 e 150
                        WHEN (vr_inrisccalculado = 8) THEN vr_qtrisccalculado-150 -- entre 151 e 180
                        ELSE  vr_qtrisccalculado-181 -- a partir de 181 dias
                      END ;
      END IF;

      UPDATE crapbdt
         SET nrinrisc = rw_crapbdt.nrinrisc,
             qtdirisc = rw_crapbdt.qtdirisc
       WHERE ROWID = rw_crapbdt.id;
      pr_dsinrisc := rw_crapbdt.nrinrisc;
      EXCEPTION
        WHEN vr_exc_erro THEN
          -- Se foi retornado apenas código busca a descrição
          IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          -- Variavel de erro recebe erro ocorrido
          pr_cdcritic := nvl(vr_cdcritic,0);
          pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
          pr_dscritic := 'Erro nao tratado na DSCT0003.pc_calcula_risco_bordero ' ||SQLERRM;
  END pc_calcula_risco_bordero;

  PROCEDURE pc_busca_dados_prejuizo_web (pr_nrdconta    IN crapass.nrdconta%TYPE --> conta do associado
                                        ,pr_nrborder    IN crapbdt.nrborder%TYPE --> numero do bordero
                                        ,pr_xmllog      IN VARCHAR2              --> xml com informações de log
                                        --------> OUT <--------
                                        ,pr_cdcritic OUT PLS_INTEGER             --> código da crítica
                                        ,pr_dscritic OUT VARCHAR2                --> descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY xmltype       --> arquivo de retorno do xml
                                        ,pr_nmdcampo OUT VARCHAR2                --> nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2                --> erros do processo
                                        ) IS
    /*---------------------------------------------------------------------------------------------------------------------
      Programa : pc_busca_dados_prejuizo_web
      Sistema  :
      Sigla    : CRED
      Autor    : Vitor Shimada Assanuma (GFT)
      Data     : 24/08/2018
      Frequencia: Sempre que for chamado
      Objetivo  : Buscar os valores de prejuizo do bordero e titulos
       - 20/09/2018 - Inclusão do campo de acordo (Vitor S. Assanuma - GFT)
    ---------------------------------------------------------------------------------------------------------------------*/
    -- Tratamento de erro
    vr_exc_erro EXCEPTION;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> cód. erro
    vr_dscritic VARCHAR2(1000);        --> desc. erro

    -- Variaveis de entrada vindas no xml
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Retorno da tabela de prejuizo
    vr_tab_prej PREJ0005.typ_tab_preju;

    BEGIN
      pr_des_erro := 'OK';
      pr_nmdcampo := NULL;

      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);

      -- Verifica se o Bordero está em prejuizo
      pc_valida_bordero(pr_cdcooper => vr_cdcooper
                       ,pr_nrborder => pr_nrborder
                       ,pr_cddeacao => 'PREJUIZO'
                       ,pr_dscritic => vr_dscritic);
      IF (vr_dscritic IS NOT NULL) THEN
         RAISE vr_exc_erro;
      END IF;

      -- Busca as informações do bordero em prejuizo
      PREJ0005.pc_busca_dados_prejuizo(pr_cdcooper => vr_cdcooper
                             ,pr_nrborder => pr_nrborder
                             -- OUT --
                             ,pr_tab_prej => vr_tab_prej
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
      IF (vr_dscritic IS NOT NULL) THEN
         raise vr_exc_erro;
      END IF;

      -- Caso todo o valor do prejuizo esteja em acordo e o prejuizo ainda não foi liquidado
      IF vr_tab_prej(0).vlsldatu = vr_tab_prej(0).vlsldaco AND vr_tab_prej(0).dtliqprj IS NULL THEN
        vr_dscritic := 'Todos os títulos em aberto do borderô selecionado estão em acordo!';
        RAISE vr_exc_erro;
      END IF;

      vr_tab_prej(0).vlsldatu := vr_tab_prej(0).vlsldatu - vr_tab_prej(0).vlsldaco;

      -- Inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- inicilizar as informaçoes do xml
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                            '<root><dados>');
      pc_escreve_xml('<dtliqprj>' || to_char(vr_tab_prej(0).dtliqprj, 'DD/MM/RRRR') || '</dtliqprj>' ||
                     '<dtprejuz>' || to_char(vr_tab_prej(0).dtprejuz, 'DD/MM/RRRR') || '</dtprejuz>' ||
                     '<inprejuz>' || vr_tab_prej(0).inprejuz                        || '</inprejuz>' ||
                     '<diasatrs>' || vr_tab_prej(0).diasatrs                        || '</diasatrs>' ||
                     '<vlaboprj>' || to_char(vr_tab_prej(0).vlaboprj, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''')  || '</vlaboprj>' ||
                     '<qtdirisc>' || vr_tab_prej(0).qtdirisc                        || '</qtdirisc>' ||
                     '<nrdconta>' || vr_tab_prej(0).nrdconta                        || '</nrdconta>' ||
                     '<toprejuz>' || to_char(vr_tab_prej(0).toprejuz, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</toprejuz>' ||
                     '<tosdprej>' || to_char(vr_tab_prej(0).tosdprej, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</tosdprej>' ||
                     '<tojrmprj>' || to_char(vr_tab_prej(0).tojrmprj, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</tojrmprj>' ||
                     '<tojraprj>' || to_char(vr_tab_prej(0).tojraprj, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</tojraprj>' ||
                     '<topgjrpr>' || to_char(vr_tab_prej(0).topgjrpr, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</topgjrpr>' ||
                     '<tottjmpr>' || to_char(vr_tab_prej(0).tottjmpr, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</tottjmpr>' ||
                     '<topgjmpr>' || to_char(vr_tab_prej(0).topgjmpr, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</topgjmpr>' ||
                     '<tottmupr>' || to_char(vr_tab_prej(0).tottmupr, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</tottmupr>' ||
                     '<topgmupr>' || to_char(vr_tab_prej(0).topgmupr, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</topgmupr>' ||
                     '<toiofprj>' || to_char(vr_tab_prej(0).toiofprj, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</toiofprj>' ||
                     '<toiofppr>' || to_char(vr_tab_prej(0).toiofppr, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</toiofppr>' ||
                     '<vlsldatu>' || to_char(vr_tab_prej(0).vlsldatu, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</vlsldatu>' ||
                     '<vlsldaco>' || to_char(vr_tab_prej(0).vlsldaco, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</vlsldaco>' ||
                     '<tovlpago>' || to_char(vr_tab_prej(0).tovlpago, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</tovlpago>' ||
                     '<totjur60>' || to_char(vr_tab_prej(0).totjur60, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</totjur60>'||
                     '<totpgm60>' || to_char(vr_tab_prej(0).totpgm60, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</totpgm60>'
                    );
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      -- liberando a memória alocada pro clob
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro := 'NOK';
        -- Se foi retornado apenas código busca a descrição
        IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Variavel de erro recebe erro ocorrido
        pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_des_erro := 'NOK';
        -- Montar descriçao de erro nao tratado
        pr_dscritic := 'erro nao tratado na tela.pc_busca_dados_prejuizo_web ' ||sqlerrm;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_busca_dados_prejuizo_web;

  PROCEDURE pc_pagar_prejuizo_web (pr_nrdconta    IN crapass.nrdconta%TYPE --> conta do associado
                                       ,pr_nrborder    IN crapbdt.nrborder%TYPE --> numero do bordero
                                       ,pr_vlaboorj     IN NUMBER                 --> Valor do abono
                                       ,pr_vlpagmto     IN NUMBER                 --> Valor do pagamento
                                       ,pr_xmllog      IN VARCHAR2              --> xml com informações de log
                                       --------> OUT <--------
                                       ,pr_cdcritic   OUT PLS_INTEGER             --> código da crítica
                                       ,pr_dscritic   OUT VARCHAR2                --> descrição da crítica
                                       ,pr_retxml      IN OUT NOCOPY xmltype      --> arquivo de retorno do xml
                                       ,pr_nmdcampo   OUT VARCHAR2                --> nome do campo com erro
                                       ,pr_des_erro   OUT VARCHAR2                --> erros do processo
                                     ) IS
      /*---------------------------------------------------------------------------------------------------------------------
        Programa : pc_pagar_prejuizo_web
        Sistema  :
        Sigla    : CRED
        Autor    : Luis Fernando (GFT)
        Data     : 14/09/2018
        Frequencia: Sempre que for chamado
        Objetivo  : Realizar o pagamento manual do bordero em prejuizo
      ---------------------------------------------------------------------------------------------------------------------*/
      -- Tratamento de erro
      vr_exc_erro EXCEPTION;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> cód. erro
      vr_dscritic varchar2(1000);        --> desc. erro

      -- Variaveis de entrada vindas no XML
      vr_cdcooper INTEGER;
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_cdoperad VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      vr_liquidou INTEGER;
      vr_mensagem VARCHAR2(100);
      BEGIN
        -- Tratativa de Erros
        pr_des_erro := 'OK';
        pr_nmdcampo := NULL;

        -- Extração dos dados
        gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                                , pr_cdcooper => vr_cdcooper
                                , pr_nmdatela => vr_nmdatela
                                , pr_nmeacao  => vr_nmeacao
                                , pr_cdagenci => vr_cdagenci
                                , pr_nrdcaixa => vr_nrdcaixa
                                , pr_idorigem => vr_idorigem
                                , pr_cdoperad => vr_cdoperad
                                , pr_dscritic => vr_dscritic);

        PREJ0005.pc_pagar_bordero_prejuizo(pr_cdcooper => vr_cdcooper
                                           ,pr_nrborder => pr_nrborder
                                           ,pr_vlaboorj => pr_vlaboorj
                                           ,pr_vlpagmto => pr_vlpagmto
                                           ,pr_cdoperad => vr_cdoperad
                                           ,pr_cdagenci => vr_cdagenci
                                           ,pr_nrdcaixa => vr_nrdcaixa
                                           ,pr_liquidou => vr_liquidou
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        vr_mensagem := 'Prejuizo parcialmente pago com sucesso';

        IF (vr_liquidou = 1) THEN
          vr_mensagem := 'Prejuizo liquidado com sucesso';
        END IF;

        -- Inicializar o clob
        vr_des_xml := null;
        dbms_lob.createtemporary(vr_des_xml, true);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

        -- Inicilizar as informaçoes do XML
        pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                            '<root>
                              <dados>'||vr_mensagem||'</dados>
                            </root>',true);
        pr_retxml := xmltype.createxml(vr_des_xml);

        -- Liberando a memória alocada pro clob
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
      EXCEPTION
        WHEN vr_exc_erro THEN
          pr_des_erro := 'NOK';
          -- Se foi retornado apenas código busca a descrição
          IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          -- Variavel de erro recebe erro ocorrido
          pr_cdcritic := nvl(vr_cdcritic,0);
          pr_dscritic := vr_dscritic;

          -- Carregar XML padrao para variavel de retorno
           pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                          '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
          pr_des_erro := 'NOK';
          -- Montar descriçao de erro nao tratado
          pr_dscritic := 'erro nao tratado na tela.pc_pagar_prejuizo_web ' ||sqlerrm;
          -- Carregar XML padrao para variavel de retorno
          pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_pagar_prejuizo_web;

  PROCEDURE pc_buscar_borderos_liberados (pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da Conta
                                         ,pr_nrctremp  IN craptdb.nrborder%TYPE DEFAULT 0 --> Numero do bordero
                                         ,pr_nrborder  IN craptdb.nrborder%TYPE DEFAULT 0 --> Numero do bordero
                                         ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                         ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                         ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2) IS         --> Erros do processo
    /*---------------------------------------------------------------------------------------------------------------------
      Programa : pc_buscar_borderos_liberados
      Sistema  :
      Sigla    : CRED
      Autor    : Vitor Shimada Assanuma (GFT)
      Data     : 26/05/2018
      Frequencia: Sempre que for chamado
      Objetivo  : Trazer todo os borderôs liberados de uma determinada conta
      Alterações:
        - 14/11/2018 - Vitor S Assanuma: Inserção de numero do borderô
    ---------------------------------------------------------------------------------------------------------------------*/
    -- Exceção
    vr_exc_erro  EXCEPTION;

    -- Variáveis de erro
    --vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    -- Variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);

    -- Varivaveis locais
    vr_nrborder crapbdt.nrborder%TYPE;

    -- Cursor dos titulos
    CURSOR cr_craptdb (pr_cdcooper craptdb.cdcooper%TYPE
                      ,vr_nrborder craptdb.nrborder%TYPE) IS
    SELECT tdb.nrdconta,
           tdb.nrborder,
           tdb.dtlibbdt,
           SUM(vltitulo) AS vltottit,
           COUNT(1) AS qttottit
      FROM craptdb tdb
     WHERE tdb.nrdconta = pr_nrdconta
       AND tdb.cdcooper = pr_cdcooper
       AND tdb.dtlibbdt IS NOT NULL -- Liberado
       AND tdb.nrborder = DECODE(vr_nrborder, 0, tdb.nrborder, vr_nrborder)
     GROUP BY tdb.nrdconta,
              tdb.nrborder,
              tdb.dtlibbdt
     ORDER BY dtlibbdt DESC;
    rw_craptdb cr_craptdb%ROWTYPE;

    BEGIN
       -- Verifica qual foi preenchido
       IF nvl(pr_nrborder, 0) = 0 THEN
         vr_nrborder := pr_nrctremp;
       ELSE
         vr_nrborder := pr_nrborder;
       END IF;
       -- Leitura dos dados
       gene0004.pc_extrai_dados(pr_xml       => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><borderos></borderos></Root>');

      -- Abertura do cursor dos titulos
      OPEN  cr_craptdb(vr_cdcooper, nvl(vr_nrborder, 0));
      LOOP
        FETCH cr_craptdb INTO rw_craptdb;
        EXIT WHEN cr_craptdb%NOTFOUND;
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                            ,'/Root/borderos'
                                            ,XMLTYPE('<bordero>'
                                                   ||'  <nrdconta>' || rw_craptdb.nrdconta                          ||'</nrdconta>'
                                                   ||'  <nrborder>' || rw_craptdb.nrborder                          ||'</nrborder>'
                                                   ||'  <dtlibbdt>' || to_char(rw_craptdb.dtlibbdt,'dd/mm/rrrr')    ||'</dtlibbdt>'
                                                   ||'  <vltottit>' || TO_CHAR(rw_craptdb.vltottit,'999G999G990D00')||'</vltottit>'
                                                   ||'  <qttottit>' || rw_craptdb.qttottit||'</qttottit>'
                                                   ||'</bordero>'));
      END LOOP;

      -- Fecha cursor
      CLOSE cr_craptdb;

  END pc_buscar_borderos_liberados;


  PROCEDURE pc_lanc_jratu_mensal(pr_cdcooper IN crapbdt.cdcooper%TYPE
                                ,pr_cdagenci IN crapass.cdagenci%TYPE DEFAULT NULL
                                ,pr_dtmvtolt IN crapbdt.dtmvtolt%TYPE
                                ,pr_nrborder IN crapbdt.nrborder%TYPE DEFAULT 0
                                ,pr_nrdconta IN crapbdt.nrdconta%TYPE DEFAULT 0
                                 --------> OUT <--------
                                ,pr_cdcritic OUT PLS_INTEGER                 --> código da crítica
                                ,pr_dscritic OUT VARCHAR2                    --> descrição da crítica
                                ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa  : pc_lanc_jratu_mensal
    Sistema   :
    Sigla     : CRED
    Autor     : Vitor S Assanuma (GFT)
    Data      : 25/10/2018
    Frequencia: Rotina mensal
    Objetivo  : Lançamento do juros de atualização mensal
    Alterações:
     - 28/11/2018 - Vitor S Assanuma: Alterado a forma de cálculo dos juros para pegar os valores da TDB e não mais dos lançamentos.
  ---------------------------------------------------------------------------------------------------------------------*/
    -- Variavel de criticas
    --vr_cdcritic crapcri.cdcritic%type;
    vr_dscritic varchar2(10000);

    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Valor do lançamento
    vl_juros_atualizacao NUMBER(25,2);

    -- Cursor para buscar os lançamentos do borderô dos meses anteriores
    CURSOR cr_tblancbord_ant(pr_cdcooper IN crapbdt.cdcooper%TYPE
                            ,pr_nrdconta IN crapbdt.nrdconta%TYPE
                            ,pr_nrborder IN crapbdt.nrborder%TYPE) IS
      SELECT NVL(SUM(vllanmto), 0) AS vl_total
        FROM tbdsct_lancamento_bordero tlb
       WHERE tlb.cdcooper  = pr_cdcooper
         AND tlb.nrborder  = pr_nrborder
         AND tlb.nrdconta = pr_nrdconta
         AND tlb.cdhistor  = DSCT0003.vr_cdhistordsct_sumjratuprejuz; -- SOMATÓRIO MENSAL DOS JUROS DE ATUALIZAÇÃO
    rw_tblancbord_ant cr_tblancbord_ant%ROWTYPE;

    -- Cursor de borderôs liberados
    CURSOR cr_craptdb_lib (pr_cdcooper craptdb.cdcooper%TYPE) IS
     SELECT bdt.nrdconta,
            bdt.nrborder,
            SUM(tdb.vljraprj - tdb.vlpgjrpr) AS vljuros_atualizacao -- Saldo do juros de atualizacao
       FROM craptdb tdb,
            crapbdt bdt,
            crapass ass
      WHERE tdb.cdcooper = bdt.cdcooper
        AND tdb.nrborder = bdt.nrborder
        AND tdb.nrdconta = bdt.nrdconta
        AND tdb.dtlibbdt IS NOT NULL -- Liberado
        AND bdt.cdcooper = pr_cdcooper
        AND bdt.nrborder = DECODE(pr_nrborder, 0, bdt.nrborder, pr_nrborder)
        AND bdt.nrdconta = DECODE(pr_nrdconta, 0, bdt.nrdconta, pr_nrdconta)
        AND bdt.flverbor = 1
        AND bdt.inprejuz = 1
        AND bdt.dtliqprj IS NULL
        AND bdt.dtlibbdt IS NOT NULL
        AND ass.cdcooper = bdt.cdcooper
        AND ass.nrdconta = bdt.nrdconta
        AND ass.cdagenci = NVL(pr_cdagenci, ass.cdagenci)
      GROUP BY bdt.nrdconta,
               bdt.nrborder;


  BEGIN

    -- Buscar todos os borderôs liberados

    FOR rw_craptdb_lib IN cr_craptdb_lib(pr_cdcooper => pr_cdcooper) LOOP

      -- Cursor para pegar todos os lançamentos com histórico 2798 anteriores
      OPEN cr_tblancbord_ant(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => rw_craptdb_lib.nrdconta
                            ,pr_nrborder => rw_craptdb_lib.nrborder);
      FETCH cr_tblancbord_ant INTO rw_tblancbord_ant;
      CLOSE cr_tblancbord_ant;

      -- A diferença entre o somatório dos meses anteriores para o mês atual:
      vl_juros_atualizacao := rw_craptdb_lib.vljuros_atualizacao - rw_tblancbord_ant.vl_total;

      IF vl_juros_atualizacao > 0 THEN
        -- Lança os juros de atualização mensal na operação de desconto de titulos
        DSCT0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                              ,pr_nrdconta => rw_craptdb_lib.nrdconta
                                              ,pr_nrborder => rw_craptdb_lib.nrborder
                                              ,pr_dtmvtolt => pr_dtmvtolt
                                              ,pr_cdorigem => 7 -- batch
                                              ,pr_cdhistor => DSCT0003.vr_cdhistordsct_sumjratuprejuz
                                              ,pr_vllanmto => vl_juros_atualizacao
                                              ,pr_dscritic => vr_dscritic );

        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;

    END LOOP;


  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na rotina DSCT0003.pc_lanca_juros_atualizacao_mensal: '||SQLERRM;
  END pc_lanc_jratu_mensal;

  PROCEDURE pc_retorna_liquidez_geral(pr_cdcooper     IN craptdb.cdcooper%TYPE
                            ,pr_nrdconta     IN craptdb.nrdconta%TYPE
                            ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE
                            ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                            ,pr_qtcarpag     IN NUMBER
                            ,pr_qtmitdcl     IN INTEGER  DEFAULT 0
                            ,pr_vlmintcl     IN NUMBER   DEFAULT 0
                            -- OUT --
                            ,pr_pc_geral     OUT NUMBER
                            ,pr_qtd_geral    OUT NUMBER) IS

     /*---------------------------------------------------------------------------------------------------------------------
        Programa : pc_retorna_liquidez_geral
        Sistema  :
        Sigla    : CRED
        Autor    : Luis Fernando (GFT)
        Data     : 24/01/2019
        Frequencia: Sempre que for chamado
        Objetivo  : Verifica se a liquidez geral esta calculada, se nao calcula
      ---------------------------------------------------------------------------------------------------------------------*/
      -- Tratamento de erro
      vr_exc_erro EXCEPTION;

      -- Variável de críticas
      --vr_cdcritic crapcri.cdcritic%TYPE; --> Código de Erro
      --vr_dscritic VARCHAR2(1000);        --> Descrição de Erro

      CURSOR cr_liquidez_geral IS
        SELECT vl_liquidez_geral,
               qt_liquidez_geral,
               dtmvtolt
          FROM tbdsct_liquidez_geral
         WHERE nrdconta = pr_nrdconta
           AND cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtmvtolt_ate;
      rw_liquidez_geral cr_liquidez_geral%ROWTYPE;

      BEGIN
        OPEN cr_liquidez_geral;
        FETCH cr_liquidez_geral INTO rw_liquidez_geral;
        IF (cr_liquidez_geral%NOTFOUND) THEN
          -- calcula liquidez
          pc_calcula_liquidez_geral(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_dtmvtolt_de => pr_dtmvtolt_de
                     ,pr_dtmvtolt_ate => pr_dtmvtolt_ate
                     ,pr_qtcarpag => pr_qtcarpag
                     ,pr_qtmitdcl => pr_qtmitdcl
                     ,pr_vlmintcl => pr_vlmintcl
                    -- OUT --
                    ,pr_pc_geral     => pr_pc_geral
                    ,pr_qtd_geral    => pr_qtd_geral
                    );

          INSERT INTO tbdsct_liquidez_geral
            (cdcooper,
             nrdconta,
             dtmvtolt,
             vl_liquidez_geral,
             qt_liquidez_geral)
          VALUES
            (pr_cdcooper,
             pr_nrdconta,
             pr_dtmvtolt_ate,
             pr_pc_geral,
             pr_qtd_geral);

        ELSE
          -- utiliza liquidez já calculada
          pr_pc_geral  := rw_liquidez_geral.vl_liquidez_geral;
          pr_qtd_geral := rw_liquidez_geral.qt_liquidez_geral;
        END IF;

        CLOSE cr_liquidez_geral;

  END pc_retorna_liquidez_geral;

  PROCEDURE pc_retorna_liquidez_pagador(pr_cdcooper     IN craptdb.cdcooper%TYPE
                            ,pr_nrdconta     IN craptdb.nrdconta%TYPE
                            ,pr_nrinssac     IN crapcob.nrinssac%TYPE DEFAULT NULL
                            ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE
                            ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                            ,pr_qtcarpag     IN NUMBER
                            ,pr_qtmitdcl     IN INTEGER  DEFAULT 0
                            ,pr_vlmintcl     IN NUMBER   DEFAULT 0
                            -- OUT --
                            ,pr_pc_cedpag    OUT NUMBER
                            ,pr_qtd_cedpag   OUT NUMBER) IS

     /*---------------------------------------------------------------------------------------------------------------------
        Programa : pc_retorna_liquidez_geral
        Sistema  :
        Sigla    : CRED
        Autor    : Luis Fernando (GFT)
        Data     : 24/01/2019
        Frequencia: Sempre que for chamado
        Objetivo  : Verifica se a liquidez do pagador esta calculada, se nao calcula
      ---------------------------------------------------------------------------------------------------------------------*/
      -- Tratamento de erro
      vr_exc_erro EXCEPTION;

      -- Variável de críticas
      --vr_cdcritic crapcri.cdcritic%TYPE; --> Código de Erro
      --vr_dscritic VARCHAR2(1000);        --> Descrição de Erro

    CURSOR cr_analise_pagador IS
    SELECT perc_liquidez_qt,
           perc_liquidez_vl
      FROM tbdsct_analise_pagador
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrinssac = pr_nrinssac;
    rw_analise_pagador cr_analise_pagador%ROWTYPE;

    BEGIN
      OPEN cr_analise_pagador;
      FETCH cr_analise_pagador INTO rw_analise_pagador;
      IF (cr_analise_pagador%NOTFOUND) THEN
        -- calcula liquidez
        pc_calcula_liquidez_pagador(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrinssac => pr_nrinssac
                   ,pr_dtmvtolt_de => pr_dtmvtolt_de
                   ,pr_dtmvtolt_ate => pr_dtmvtolt_ate
                   ,pr_qtcarpag => pr_qtcarpag
                   ,pr_qtmitdcl => pr_qtmitdcl
                   ,pr_vlmintcl => pr_vlmintcl
                  -- OUT --
                  ,pr_pc_cedpag     => pr_pc_cedpag
                  ,pr_qtd_cedpag    => pr_qtd_cedpag
                  );
      ELSE
        -- utiliza liquidez já calculada
        pr_pc_cedpag  := rw_analise_pagador.perc_liquidez_vl;
        pr_qtd_cedpag := rw_analise_pagador.perc_liquidez_qt;
      END IF;

      CLOSE cr_analise_pagador;
    END pc_retorna_liquidez_pagador;

PROCEDURE pc_verifica_impressao (pr_nrdconta  IN craplim.nrdconta%TYPE,
                              pr_nrctrlim  IN craplim.nrctrlim%TYPE
                              ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                              --------> OUT <--------
                              ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                              ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                              ) IS
    /* .............................................................................
      Programa: pc_verifica_impressao
      Sistema : AyllosWeb
      Sigla   : CRED
      Autor   : Daniel Zimmermann
      Data    : 07/12/2018                        Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Retorna se pode ser efetuada a impressão da proposta de limite de desconto
      Alterações:


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

    CURSOR cr_rating_novo(pr_cdcooper IN crawlim.cdcooper%TYPE
                            ,pr_nrdconta IN crawlim.nrdconta%TYPE
                            ,pr_nrctrlim IN crawlim.nrctrlim%TYPE) IS
      SELECT oper.inrisco_rating_autom 
        FROM tbrisco_operacoes oper
       WHERE oper.cdcooper = pr_cdcooper
         AND oper.nrdconta = pr_nrdconta
         AND oper.nrctremp = pr_nrctrlim
         AND oper.tpctrato = 3; 
    rw_rating_novo cr_rating_novo%ROWTYPE;

    CURSOR cr_crawlim(pr_cdcooper IN crawlim.cdcooper%TYPE
                     ,pr_nrdconta IN crawlim.nrdconta%TYPE
                     ,pr_nrctrlim IN crawlim.nrctrlim%TYPE) IS
    SELECT lim.nrinfcad,
           lim.nrgarope,
           lim.nrliquid,
           lim.nrpatlvr,
           lim.nrperger
      FROM crawlim lim
     WHERE lim.cdcooper = pr_cdcooper
       AND lim.nrdconta = pr_nrdconta
       AND lim.nrctrlim = pr_nrctrlim
       AND lim.tpctrlim = 3
--       AND lim.nrgarope > 0
       AND lim.nrliquid > 0;
    rw_crawlim cr_crawlim%ROWTYPE;
    vr_habrat VARCHAR2(1) := 'N'; -- P450 - Paramentro para Habilitar Novo Ratin (S/N)

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

      vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                             pr_cdcooper => vr_cdcooper, 
                                             pr_cdacesso => 'HABILITA_RATING_NOVO');


      OPEN cr_crawlim(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctrlim => pr_nrctrlim);
      FETCH cr_crawlim INTO rw_crawlim;

      IF cr_crawlim%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crawlim;
        vr_dscritic := 'Não permitido impressão da Proposta. Necessario efetuar analise.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crawlim;
      END IF;

/*
      IF (vr_cdcooper <> 3 AND vr_habrat = 'S') THEN
        OPEN cr_rating_novo(pr_cdcooper => vr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrctrlim => pr_nrctrlim);
        FETCH cr_rating_novo INTO rw_rating_novo;
        IF cr_rating_novo%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_rating_novo;
          vr_dscritic := 'Não há Rating. Necessario efetuar analise.';
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_rating_novo;
          IF NVL(rw_rating_novo.inrisco_rating_autom, 0) = 0 THEN
            vr_dscritic := 'Rating inválido. Necessario efetuar analise.';
            RAISE vr_exc_erro;
          END IF;
        END IF;
      END IF;
*/

      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;

      -- Passou nas validações do bordero, do contrato e listou titulos. Começa a montar o xml
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados>');

      pc_escreve_xml('<cdcooper>'  || vr_cdcooper  || '</cdcooper>');

      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      -- liberando a memória alocada pro clob
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    exception
      when vr_exc_erro then
           --  se foi retornado apenas código
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               -- buscar a descriçao
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           -- variavel de erro recebe erro ocorrido
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;

           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           -- montar descriçao de erro não tratado
           pr_dscritic := 'erro não tratado na DSCT0003.pc_verifica_impressao ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_verifica_impressao;

  PROCEDURE pc_verifica_contrato_bodero (pr_nrdconta  IN craplim.nrdconta%TYPE,
                              pr_nrctrlim  IN craplim.nrctrlim%TYPE
                              ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                              --------> OUT <--------
                              ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                              ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                              ) IS
    /* .............................................................................
      Programa: pc_verifica_contrato_bodero
      Sistema : AyllosWeb
      Sigla   : CRED
      Autor   : Cássia de Oliveira (GFT)
      Data    : 20/02/2019                        Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Verifica se há brdero diferente de liberado para este contrato
      Alterações:


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
    vr_fltembdt VARCHAR(1);

    CURSOR cr_crapbdt(pr_cdcooper IN crapprp.cdcooper%TYPE) IS
      SELECT (1)
        FROM crapbdt
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrlim = pr_nrctrlim
         AND insitbdt < 3;
    rw_crapbdt cr_crapbdt%ROWTYPE;


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


      OPEN cr_crapbdt(pr_cdcooper => vr_cdcooper);
      FETCH cr_crapbdt INTO rw_crapbdt;

      IF cr_crapbdt%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapbdt;
        vr_fltembdt := 0;
      ELSE
        CLOSE cr_crapbdt;
        vr_fltembdt := 1;
      END IF;


      -- Inicializar o clob
       vr_des_xml := null;
       dbms_lob.createtemporary(vr_des_xml, true);
       dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

       -- inicilizar as informaçoes do xml
       pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                             '<root><dados>');

       pc_escreve_xml('<fltembdt>' || vr_fltembdt || '</fltembdt>');

       pc_escreve_xml ('</dados></root>',true);
       pr_retxml := xmltype.createxml(vr_des_xml);

       /* liberando a memória alocada pro clob */
       dbms_lob.close(vr_des_xml);
       dbms_lob.freetemporary(vr_des_xml);


    exception
      when vr_exc_erro then
           /*  se foi retornado apenas código */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;

           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           /* montar descriçao de erro não tratado */
           pr_dscritic := 'erro não tratado na DSCT0003.pc_verifica_contrato_bodero ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_verifica_contrato_bodero;

  PROCEDURE pc_verifica_bordero_ib (pr_nrdconta  IN crapbdt.nrdconta%TYPE,
                                    pr_nrborder  IN crapbdt.nrctrlim%TYPE
                                    ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                    --------> OUT <--------
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                    ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                    ) IS
    /* .............................................................................
      Programa: pc_verifica_impressao
      Sistema : AyllosWeb
      Sigla   : CRED
      Autor   : Daniel Zimmermann
      Data    : 27/06/2019                        Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Retorna se deve solicitar assinatura do cooperado na liberação do bordero de desconto.
      Alterações:


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

    vr_msgretorno VARCHAR2(100);

    vr_tab_dados_dsctit  dsct0002.typ_tab_dados_dsctit;
    vr_tab_cecred_dsctit dsct0002.typ_tab_cecred_dsctit;

    CURSOR cr_crapbdt(pr_cdcooper IN crapbdt.cdcooper%TYPE
                     ,pr_nrdconta IN crapbdt.nrdconta%TYPE
                     ,pr_nrborder IN crapbdt.nrborder%TYPE) IS
    SELECT ass.inpessoa,
           bdt.cdoperad
      FROM crapbdt bdt,
           crapass ass
     WHERE bdt.cdcooper = pr_cdcooper
       AND bdt.nrdconta = pr_nrdconta
       AND bdt.nrborder = pr_nrborder
       AND ass.cdcooper = bdt.cdcooper
       AND ass.nrdconta = bdt.nrdconta;
    rw_crapbdt cr_crapbdt%ROWTYPE;

    CURSOR cr_craptdb(pr_cdcooper IN crapbdt.cdcooper%TYPE
                     ,pr_nrdconta IN crapbdt.nrdconta%TYPE
                     ,pr_nrborder IN crapbdt.nrborder%TYPE) IS
    SELECT bdt.nrborder, SUM(tdb.vltitulo) vltitulo
      FROM crapbdt bdt,
           craptdb tdb
     WHERE bdt.cdcooper = pr_cdcooper
       AND bdt.nrdconta = pr_nrdconta
       AND bdt.nrborder = pr_nrborder
       AND tdb.cdcooper = bdt.cdcooper
       AND tdb.nrdconta = bdt.nrdconta
       AND tdb.nrborder = bdt.nrborder
       AND tdb.insitapr = 1 -- Aprovado
       GROUP BY bdt.nrborder;
    rw_craptdb cr_craptdb%ROWTYPE;

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


      OPEN cr_crapbdt(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrborder => pr_nrborder);
      FETCH cr_crapbdt INTO rw_crapbdt;

      IF cr_crapbdt%NOTFOUND THEN
          -- Fechar o cursor
        CLOSE cr_crapbdt;
          vr_dscritic := 'Não permitido liberação. Bordero não localizado.';
          RAISE vr_exc_erro;
        ELSE
        CLOSE cr_crapbdt;
        END IF;

       OPEN cr_craptdb(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrborder => pr_nrborder);
      FETCH cr_craptdb INTO rw_craptdb;

      IF cr_craptdb%NOTFOUND THEN
          -- Fechar o cursor
        CLOSE cr_craptdb;
          vr_dscritic := 'Bordero não possui titulos aprovados. Liberação não permitida.';
          RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craptdb;
      END IF;


        DSCT0002.pc_busca_parametros_dsctit(pr_cdcooper    => vr_cdcooper
                                     ,pr_cdagenci          => NULL -- sem utilidade
                                     ,pr_nrdcaixa          => NULL -- sem utilidade
                                     ,pr_cdoperad          => NULL -- sem utilidade
                                     ,pr_dtmvtolt          => NULL -- sem utilidade
                                     ,pr_idorigem          => NULL -- sem utilidade
                                     ,pr_tpcobran          => 1                    --> Tipo de Cobrança: 0 = Sem Registro / 1 = Com Registro
                                     ,pr_inpessoa          => rw_crapbdt.inpessoa  --> Indicador de tipo de pessoa
                                     ,pr_tab_dados_dsctit  => vr_tab_dados_dsctit  --> tabela contendo os parametros da cooperativa
                                     ,pr_tab_cecred_dsctit => vr_tab_cecred_dsctit --> Tabela contendo os parametros da cecred
                                     ,pr_cdcritic          => vr_cdcritic
                                     ,pr_dscritic          => vr_dscritic);


    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    vr_msgretorno := 'liberarBorderoDscTit(0);';

    -- Se a soma do valor de todos os títulos do borderô for maior que o parametro VLMXASSI dos parãmetros da TAB052,
    -- emitir mensagem para realizar a assinatural manual.
    IF ( rw_craptdb.vltitulo > vr_tab_dados_dsctit(1).vlmxassi ) AND rw_crapbdt.cdoperad = '996' THEN
      vr_msgretorno := 'confirmaBorderoIB();';
    END IF;

      -- inicializar o clob
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := NULL;

      -- Passou nas validações do bordero, do contrato e listou titulos. Começa a montar o xml
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados>');

      pc_escreve_xml('<msgretorno>'  || vr_msgretorno  || '</msgretorno>');

      pc_escreve_xml ('</dados></root>',TRUE);
      pr_retxml := xmltype.createxml(vr_des_xml);

      -- liberando a memória alocada pro clob
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    EXCEPTION
      when vr_exc_erro then
           --  se foi retornado apenas código
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               -- buscar a descriçao
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           -- variavel de erro recebe erro ocorrido
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;

           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           -- montar descriçao de erro não tratado
           pr_dscritic := 'Erro não tratado na DSCT0003.pc_verifica_bordero_ib ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_verifica_bordero_ib;
END DSCT0003;
/
