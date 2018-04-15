CREATE OR REPLACE PACKAGE CECRED.DSCT0003 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa:  DSCT0003                       Antiga: generico/procedures/b1wgen0030.p
  --  Autor   : André Ávila - GFT
  --  Data    : Abril/2018                     Ultima Atualizacao: 10/04/2018
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package para rotinas de Liberação de Borderôs.
  --
  --
  --  Alteracoes: 10/04/2018 - Conversao Progress para oracle (André Ávila - GFT)
  --
  --              10/04/2018 - Criacao da procedure pc_efetua_liberacao_bordero
  --
  ---------------------------------------------------------------------------------------------------------------


  -- Author  : T0031818
  -- Created : 10/04/2018 09:05:29
  -- Purpose : Procedures para atender a Análise Automática e Liberação de Borderôs

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

  /* Procedure para efetuar liberação de titulos de um determinado bordero */
  PROCEDURE pc_liberar_bordero (pr_cdopcoan IN crapbdt.cdopcoan%TYPE --> Codigo do operador de coordenador de analise
                                ,pr_cdopcolb IN crapbdt.cdopcolb%TYPE --> Codigo do operador de coordenador de liberacao
                                ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                                ,pr_idorigem IN INTEGER               --> Identificador Origem pagamento
                                ,pr_nrdconta IN craptdb.nrdconta%TYPE --> Número da Conta
                                ,pr_idseqttl IN INTEGER               --> idseqttl
                                ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                ,pr_dtmvtopr IN crapdat.dtmvtolt%TYPE --> Proxima data de movimento.
                                ,pr_inproces IN crapdat.inproces%TYPE --> Indicador processo
                                ,pr_nrborder IN crapbdt.nrborder%TYPE --> Número do Bordero
                                ,pr_cddopcao IN crapace.cddopcao%TYPE --> Codigo da opcao de acesso a tela.
                                ,pr_inconfir IN PLS_INTEGER           --> Controle de confirmação
                                ,pr_inconfi2 IN PLS_INTEGER           --> Controle de confirmação
                                ,pr_inconfi3 IN PLS_INTEGER           --> Controle de confirmação
                                ,pr_inconfi4 IN PLS_INTEGER           --> Controle de confirmação
                                ,pr_inconfi5 IN PLS_INTEGER           --> Controle de confirmação
                                ,pr_inconfi6 IN PLS_INTEGER           --> Controle de confirmação
                                ,pr_flgerlog IN BOOLEAN               --> identificador se deve gerar log
                                --------> OUT <--------
                                ,pr_indrestr OUT PLS_INTEGER          --> Indica se Gerou Restrição (0 - Sem Restrição / 1 - Com restrição)
                                ,pr_ind_inpeditivo OUT PLS_INTEGER          --> Indica se o Resultado é Impeditivo para Realizar Liberação. (0 - Sem Impedimentos / 1 - Com Impedimentos)
                                ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela Erros
                                ,pr_tab_msg_confirma    OUT typ_tab_msg_confirma
                                ,pr_tab_grupo           OUT GECO0001.typ_reg_crapgrp
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descriçao da crítica
                                );

  PROCEDURE pc_liberar_bordero_web (pr_cdopcoan IN crapbdt.cdopcoan%TYPE  --> Codigo do operador de coordenador de analise
                                    ,pr_cdopcolb IN crapbdt.cdopcolb%TYPE  --> Codigo do operador de coordenador de liberacao
                                    ,pr_nrdconta IN craptdb.nrdconta%TYPE  --> Número da Conta
                                    ,pr_idseqttl IN INTEGER                --> idseqttl
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                    ,pr_dtmvtopr IN crapdat.dtmvtolt%TYPE  --> Proxima data de movimento.
                                    ,pr_inproces IN crapdat.inproces%TYPE  --> Indicador processo
                                    ,pr_nrborder IN crapbdt.nrborder%TYPE  --> Número do Bordero
                                    ,pr_inconfir IN PLS_INTEGER            --> Controle de confirmação
                                    ,pr_inconfi2 IN PLS_INTEGER            --> Controle de confirmação
                                    ,pr_inconfi3 IN PLS_INTEGER            --> Controle de confirmação
                                    ,pr_inconfi4 IN PLS_INTEGER            --> Controle de confirmação
                                    ,pr_inconfi5 IN PLS_INTEGER            --> Controle de confirmação
                                    ,pr_inconfi6 IN PLS_INTEGER            --> Controle de confirmação
                                    ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                    --------> OUT <--------
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype     --> arquivo de retorno do xml
                                    ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

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
                                  ,pr_cdagenci IN craplim.cdagenci%TYPE --> Código da Agência
                                  ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE
                                  ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                  ,pr_idorigem IN INTEGER  --> Identificador Origem pagamento
                                  ,pr_nrdconta IN craptdb.nrdconta%TYPE DEFAULT NULL --> Número da Conta
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE
                                  ,pr_tpvalida IN INTEGER DEFAULT 1 --> 1: Análise do Borderô 2: Inclusão do Borderô.
                                  --------> OUT <--------
                                  ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela Erros
                                  ,pr_des_reto OUT VARCHAR2
                                  );

  /* Procura estriçoes de um borderô e cria entradas na  tabela de restrições quando encontradas (b1wgen0030.p/analisar-titulo-bordero) */
  PROCEDURE pc_restricoes_tit_bordero (pr_cdcooper IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_cdagenci IN craplim.cdagenci%TYPE --> Código da Agência
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
                                      ,pr_des_reto OUT VARCHAR2
                                      ,pr_cdcritic    OUT INTEGER                 --> Codigo Critica
                                      ,pr_dscritic    OUT VARCHAR2                --> Descricao Critica
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
                                      ,pr_flgerlog IN BOOLEAN               --> identificador se deve gerar log
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
END  DSCT0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.DSCT0003 AS

  /*---------------------------------------------------------------------------------------------------------------

    Programa :  DSCT0003
    Sistema  : Procedimentos envolvendo liberação de borderôs
    Sigla    : CRED
    Autor    : André Ávila - GFT
    Data     : Abril/2018.                   Ultima atualizacao: 10/04/2018

   Dados referentes ao programa:

   Frequencia: -----
   Objetivo  : Procedimentos envolvendo liberação de borderôs

   Alteracoes: 10/04/2018 - Desconto de Títulos KE00726701-185 Borderô - Liberar KE00726701-476 (André Ávila - GFT)

  ---------------------------------------------------------------------------------------------------------------*/

  -- Variáveis para armazenar as informações em XML
  vr_des_xml         clob;
  vr_texto_completo  varchar2(32600);
  vr_index           pls_integer;

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





  /* Procedure para efetuar liberação de titulos de um determinado borderô */

  PROCEDURE pc_liberar_bordero (pr_cdopcoan IN crapbdt.cdopcoan%TYPE --> Codigo do operador de coordenador de analise
                                ,pr_cdopcolb IN crapbdt.cdopcolb%TYPE --> Codigo do operador de coordenador de liberacao
                                ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                                ,pr_idorigem IN INTEGER               --> Identificador Origem pagamento
                                ,pr_nrdconta IN craptdb.nrdconta%TYPE --> Número da Conta
                                ,pr_idseqttl IN INTEGER               --> idseqttl
                                ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                ,pr_dtmvtopr IN crapdat.dtmvtolt%TYPE --> Proxima data de movimento.
                                ,pr_inproces IN crapdat.inproces%TYPE --> Indicador processo
                                ,pr_nrborder IN crapbdt.nrborder%TYPE --> Número do Borderô
                                ,pr_cddopcao IN crapace.cddopcao%TYPE --> Codigo da opcao de acesso a tela.
                                ,pr_inconfir IN PLS_INTEGER           --> Controle de confirmação
                                ,pr_inconfi2 IN PLS_INTEGER           --> Controle de confirmação
                                ,pr_inconfi3 IN PLS_INTEGER           --> Controle de confirmação
                                ,pr_inconfi4 IN PLS_INTEGER           --> Controle de confirmação
                                ,pr_inconfi5 IN PLS_INTEGER           --> Controle de confirmação
                                ,pr_inconfi6 IN PLS_INTEGER           --> Controle de confirmação
                                ,pr_flgerlog IN BOOLEAN               --> identificador se deve gerar log
                                --------> OUT <--------
                                ,pr_indrestr OUT PLS_INTEGER          --> Indica se Gerou Restrição (0 - Sem Restrição / 1 - Com restrição)
                                ,pr_ind_inpeditivo OUT PLS_INTEGER          --> Indica se o Resultado é Impeditivo para Realizar Liberação. (0 - Sem Impedimentos / 1 - Com Impedimentos)
                                ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela Erros
                                ,pr_tab_msg_confirma    OUT typ_tab_msg_confirma
                                ,pr_tab_grupo           OUT GECO0001.typ_reg_crapgrp
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descriçao da crítica
                                ) IS

   BEGIN
     NULL;
   END pc_liberar_bordero;

  PROCEDURE pc_liberar_bordero_web (pr_cdopcoan IN crapbdt.cdopcoan%TYPE  --> Codigo do operador de coordenador de analise
                                    ,pr_cdopcolb IN crapbdt.cdopcolb%TYPE  --> Codigo do operador de coordenador de liberacao
                                    ,pr_nrdconta IN craptdb.nrdconta%TYPE  --> Número da Conta
                                    ,pr_idseqttl IN INTEGER                --> idseqttl
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                    ,pr_dtmvtopr IN crapdat.dtmvtolt%TYPE  --> Proxima data de movimento.
                                    ,pr_inproces IN crapdat.inproces%TYPE  --> Indicador processo
                                    ,pr_nrborder IN crapbdt.nrborder%TYPE  --> Número do Borderô
                                    ,pr_inconfir IN PLS_INTEGER            --> Controle de confirmação
                                    ,pr_inconfi2 IN PLS_INTEGER            --> Controle de confirmação
                                    ,pr_inconfi3 IN PLS_INTEGER            --> Controle de confirmação
                                    ,pr_inconfi4 IN PLS_INTEGER            --> Controle de confirmação
                                    ,pr_inconfi5 IN PLS_INTEGER            --> Controle de confirmação
                                    ,pr_inconfi6 IN PLS_INTEGER            --> Controle de confirmação
                                    ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                    --------> OUT <--------
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype     --> arquivo de retorno do xml
                                    ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS


    -- pr_tab_dados_limite  typ_tab_dados_limite;          --> retorna dos dados

    /* tratamento de erro */
    vr_exc_erro exception;

    vr_tab_erro         gene0001.typ_tab_erro;
    vr_qtregist         number;
    vr_des_reto varchar2(3);

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

    BEGIN
      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);
       /*
       pc_busca_dados_limite (pr_nrdconta,
                              vr_cdcooper,
                              pr_tpctrlim,
                              pr_insitlim,
                              pr_dtmvtolt,
                              ----OUT----
                              pr_tab_dados_limite,
                              vr_cdcritic,
                              vr_dscritic
                             );
      */


      IF (nvl(vr_cdcritic,0) <> 0 OR  vr_dscritic IS NOT NULL) THEN
        raise vr_exc_erro;
      END IF;
      /*
      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;

      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados >');

      -- ler o resultado da busca do contrato de limite e incluir no xml
      pc_escreve_xml('<inf>'||
                        '<dtpropos>' || to_char(pr_tab_dados_limite(0).dtpropos,'dd/mm/rrrr') || '</dtpropos>' ||
                        '<dtinivig>' || to_char(pr_tab_dados_limite(0).dtinivig,'dd/mm/rrrr') || '</dtinivig>' ||
                        '<nrctrlim>' || pr_tab_dados_limite(0).nrctrlim || '</nrctrlim>' ||
                        '<vllimite>' || pr_tab_dados_limite(0).vllimite || '</vllimite>' ||
                        '<qtdiavig>' || pr_tab_dados_limite(0).qtdiavig || '</qtdiavig>' ||
                        '<cddlinha>' || pr_tab_dados_limite(0).cddlinha || '</cddlinha>' ||
                        '<tpctrlim>' || pr_tab_dados_limite(0).tpctrlim || '</tpctrlim>' ||
                        '<vlutiliz>' || pr_tab_dados_limite(0).vlutiliz || '</vlutiliz>' ||
                        '<qtutiliz>' || pr_tab_dados_limite(0).qtutiliz || '</qtutiliz>' ||
                        '<dtfimvig>' || to_char(pr_tab_dados_limite(0).dtfimvig,'dd/mm/rrrr') || '</dtfimvig>' ||
                        '<pctolera>' || pr_tab_dados_limite(0).pctolera || '</pctolera>' ||
                     '</inf>'
                    );
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      --dbms_lob.close(vr_des_xml);
      --dbms_lob.freetemporary(vr_des_xml);

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
           pr_dscritic := 'erro não tratado na tela_atenda_dscto_tit.pc_liberar_bordero_web ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
           pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
   END pc_liberar_bordero_web;

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

  /*Procedure que grava a aprovação de um borderô*/
  PROCEDURE pc_altera_status_bordero(pr_cdcooper IN crapbdt.cdcooper%TYPE --> Código da Cooperativa
                                    ,pr_nrborder IN crapbdt.nrborder%TYPE --> Número do Borderô
                                    ,pr_nrdconta IN crapbdt.nrdconta%TYPE
                                    ,pr_status   IN crapbdt.insitbdt%TYPE -- estou considerando 5 como aprovado automaticamente.
                                    ,pr_dscritic    OUT PLS_INTEGER                --> Descricao Critica
                                    ) IS
  BEGIN
    BEGIN
      UPDATE crapbdt
         SET crapbdt.insitbdt = pr_status
       WHERE crapbdt.cdcooper = pr_cdcooper
         AND crapbdt.nrborder = pr_nrborder
         AND crapbdt.nrdconta = pr_nrdconta;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao alterar o registro na crapbdt: '|| sqlerrm;
    END;
  END pc_altera_status_bordero;

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
      vr_query := '';

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

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      --Variável Auxiliar de Cálculo de Datas.
      vr_aux_difdays PLS_INTEGER;

      --Cursor para popular o total de Titulos qdo não há registro de Limite, a partir dos Titulos do Borderô.
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

      --Cursor para Linhas de Crédito
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

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

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
                                  ,pr_cdagenci IN craplim.cdagenci%TYPE --> Código da Agência
                                  ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE
                                  ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                  ,pr_idorigem IN INTEGER  --> Identificador Origem pagamento
                                  ,pr_nrdconta IN craptdb.nrdconta%TYPE DEFAULT NULL --> Número da Conta
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
                                  pr_nrborder IN craptdb.nrborder%TYPE) IS
        SELECT tdbold.nrborder as nrborder_dup,
               tdbold.nrdocmto as nrdocmto_dup
          FROM cecred.craptdb tdban -- titulos de bordero que estão no bordero que se quer analisar
         INNER JOIN cecred.craptdb tdbold -- titulos deste bordero que estão em um bordero diferente.
            ON tdbold.cdcooper =  tdban.cdcooper
           AND tdbold.cdbandoc =  tdban.cdbandoc
           AND tdbold.nrdctabb =  tdban.nrdctabb
           AND tdbold.nrcnvcob =  tdban.nrcnvcob
           AND tdbold.nrdconta =  tdban.nrdconta
           AND tdbold.nrborder <> tdban.nrborder
           AND tdbold.nrdocmto =  tdban.nrdocmto
         WHERE tdban.cdcooper = pr_cdcooper
           AND tdban.nrborder = pr_nrborder
           AND tdbold.insittit in (0,2,4);

      rw_verifica_bordero cr_verifica_bordero%ROWTYPE;


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
                                 pr_nrborder => pr_nrborder) LOOP
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
        END LOOP;
      END IF;

      -- USADO NA INCLUSÃO (NÃO É PARTE DO ESCOPO DESTA ESTÓRIA, NÃO ESTOU TRAZENDO PARA CÁ.
      --IF pr_tpvalida = 2 THEN
         -- TO DO
      --END IF;

      IF NOT vr_flgtrans THEN
         pr_des_reto := 'NOK';
      ELSE
         pr_des_reto := 'OK';
      END IF;

    END;
  END pc_valida_tit_bordero;

  /* Procura estriçoes de um borderô e cria entradas na  tabela de restrições quando encontradas (b1wgen0030.p/analisar-titulo-bordero)*/
  PROCEDURE pc_restricoes_tit_bordero (pr_cdcooper IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_cdagenci IN craplim.cdagenci%TYPE --> Código da Agência
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
                                      ,pr_des_reto OUT VARCHAR2
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
    DECLARE
      -- Auxiliares para geração de erro.
      vr_contador PLS_INTEGER;
      vr_flgtrans BOOLEAN;

      -- Informações de data do sistema
      rw_crapdat     btch0001.rw_crapdat%TYPE; --> Tipo de registro de datas

      -- Tratamento de erros
      vr_exc_erro exception;

      -- Erro em chamadas
      vr_des_reto VARCHAR2(3) DEFAULT 'OK';

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
      vr_dscritic varchar2(1000);        --> Desc. Erro

      -- Variáveis Para Validação com Valor do Titulo x TAB052
      vr_vltotbdt_cr craptdb.vltitulo%TYPE DEFAULT 0;
      vr_vltotbdt_sr craptdb.vltitulo%TYPE DEFAULT 0;
      vr_vltotsac_cr craptdb.vltitulo%TYPE DEFAULT 0;
      vr_vltotsac_sr craptdb.vltitulo%TYPE DEFAULT 0;
      vr_vlcontit    craptdb.vltitulo%TYPE DEFAULT 0;

      vr_qttitdsc_cr PLS_INTEGER DEFAULT 0; --Analisado
      vr_naopagos_cr PLS_INTEGER DEFAULT 0; --Liberado
      vr_qttitdsc_sr PLS_INTEGER DEFAULT 0; --Analisado
      vr_naopagos_sr PLS_INTEGER DEFAULT 0; --Liberado

      vr_pcnaopag_cr craptdb.vltitulo%TYPE DEFAULT 0;
      vr_pcnaopag_sr craptdb.vltitulo%TYPE DEFAULT 0;

      -- Auxiliares para Quantidade de Tìtulos Não Pagos por Pagador
      vr_qtnaopag_cr PLS_INTEGER DEFAULT 0;
      vr_qtnaopag_sr PLS_INTEGER DEFAULT 0;


      vr_cntqttit PLS_INTEGER DEFAULT 0;
      vr_qtprotes_cr PLS_INTEGER DEFAULT 0;

      vr_tab_dados_dsctit_cr cecred.dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052 para Cooperativa e Cobrança Registrada
      vr_tab_dados_dsctit_sr cecred.dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052 para Cooperativa e Cobrança Sem Registro
      vr_tab_cecred_dsctit cecred.dsct0002.typ_tab_cecred_dsctit; -- retorno da TAB052 para CECRED

      -- Variáveis auxiliares para as Restrições de Borderô
      vr_nrseqdig crapabt.nrseqdig%TYPE;
      vr_dsrestri crapabt.dsrestri%TYPE;
      vr_dsdetres crapabt.dsdetres%TYPE;

      -- Descrição da origem da chamada
      vr_dsorigem VARCHAR2(10);
      -- Descrição da transação
      vr_dstransa VARCHAR2(100);
      -- rowid tabela de log
      vr_nrdrowid ROWID;

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

      -- Calcular valor Total dos Títulos de Um Bordero com COB. REGISTRADA e S/ REGISTRO
      CURSOR cr_tdbcob_total (pr_cdcooper IN craptdb.cdcooper%TYPE
                             ,pr_nrdconta IN craptdb.nrdconta%TYPE
                             ,pr_nrborder IN craptdb.nrborder%TYPE
                             ,pr_nrinssac IN craptdb.nrinssac%TYPE DEFAULT 0) IS
        SELECT SUM(DECODE(cob.flgregis,1,tdb.vltitulo,0))   as vltottit_cr,
               SUM(DECODE(cob.flgregis,0,tdb.vltitulo,0))   as vltottit_sr
          FROM cecred.craptdb tdb
         INNER JOIN cecred.crapcob cob
            ON cob.cdcooper = tdb.cdcooper
           AND cob.cdbandoc = tdb.cdbandoc
           AND cob.nrdctabb = tdb.nrdctabb
           AND cob.nrcnvcob = tdb.nrcnvcob
           AND cob.nrdconta = tdb.nrdconta
           AND cob.nrdocmto = tdb.nrdocmto
         WHERE tdb.cdcooper = pr_cdcooper
           AND tdb.nrdconta = pr_nrdconta
           AND tdb.nrborder = pr_nrborder
           AND tdb.nrinssac = DECODE(pr_nrinssac,0,tdb.nrinssac,pr_nrinssac)
           AND tdb.insittit = 0;
      rw_tdbcob_total cr_tdbcob_total%ROWTYPE;

      -- cursor para totalizações de status dos títulos por cooperado e conta
      CURSOR cr_tdbcob_status (pr_cdcooper IN craptdb.cdcooper%TYPE
                              ,pr_nrdconta IN craptdb.nrdconta%TYPE) IS
        SELECT SUM(DECODE(cob.flgregis,1,DECODE(tdb.insittit,2,1,0),0)) as qttitdsc_cr --Analisado
              ,SUM(DECODE(cob.flgregis,1,DECODE(tdb.insittit,3,1,0),0)) as naopagos_cr --Liberado
              ,SUM(DECODE(cob.flgregis,0,DECODE(tdb.insittit,2,1,0),0)) as qttitdsc_sr --Analisado
              ,SUM(DECODE(cob.flgregis,0,DECODE(tdb.insittit,3,1,0),0)) as naopagos_sr --Liberado
          FROM cecred.craptdb tdb
         INNER JOIN cecred.crapcob cob
            ON cob.cdcooper = tdb.cdcooper
           AND cob.cdbandoc = tdb.cdbandoc
           AND cob.nrdctabb = tdb.nrdctabb
           AND cob.nrcnvcob = tdb.nrcnvcob
           AND cob.nrdconta = tdb.nrdconta
           AND cob.nrdocmto = tdb.nrdocmto
         WHERE tdb.cdcooper = pr_cdcooper
           AND tdb.nrdconta = pr_nrdconta;
      rw_tdbcob_status cr_tdbcob_status%ROWTYPE;

      -- Soma Quantidade de Títulos Não pagos por Pagador Neste Borderô
      CURSOR cr_naopagos_pagador (pr_cdcooper IN craptdb.cdcooper%TYPE
                                 ,pr_nrdconta IN craptdb.nrdconta%TYPE
                                 ,pr_nrmespsq IN PLS_INTEGER) IS
        SELECT count(tdb.nrdocmto) as qtde_titulos
              ,SUM(DECODE(cob.flgregis,1,1,0)) as qtnaopag_cr -- COM REGISTRO
              ,SUM(DECODE(cob.flgregis,0,1,0)) as qtnaopag_sr -- SEM REGISTR
          FROM craptdb tdb
         INNER JOIN cecred.crapcob cob
            ON cob.cdcooper = tdb.cdcooper
           AND cob.cdbandoc = tdb.cdbandoc
           AND cob.nrdctabb = tdb.nrdctabb
           AND cob.nrcnvcob = tdb.nrcnvcob
           AND cob.nrdconta = tdb.nrdconta
           AND cob.nrdocmto = tdb.nrdocmto
         WHERE tdb.cdcooper = pr_cdcooper
           AND tdb.nrborder = pr_nrborder --2598 --22719 -- 23175
           AND tdb.nrdconta = pr_nrdconta  --7250
           AND tdb.insittit = 3
           AND tdb.dtvencto > trunc(sysdate) - (80*30);
      rw_naopagos_pagador cr_naopagos_pagador%ROWTYPE;


      -- Cursor para o Loop Principal em Títulos do borderô e Dados de Cobrança
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

      -- Cursor para Dados de Limite do Cooperado
      CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT cop.vlmaxleg
              ,cop.vlmaxutl
              ,cop.vlcnsscr
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

    -- Obter Cód. CNAE para o Cedente dos Títulos do Bordero
    CURSOR cr_cnae (pr_cdcooper IN craptdb.cdcooper%TYPE,
                             pr_nrdconta IN craptdb.nrdconta%TYPE,
                             pr_nrborder IN craptdb.nrborder%TYPE) IS
    SELECT cob.cdbandoc
          ,cob.nrdctabb
          ,cob.nrcnvcob
          ,cob.nrdocmto
      FROM crapass ass
     INNER JOIN tbdsct_cdnae cnae
        ON cnae.cdcooper = ass.cdcooper
       AND cnae.cdcnae   = ass.cdclcnae
     INNER JOIN craptdb tdb
        ON tdb.cdcooper = ass.cdcooper
       AND tdb.nrdconta = ass.nrdconta
     INNER JOIN crapcob cob
        ON cob.cdcooper = tdb.cdcooper
       AND cob.cdbandoc = tdb.cdbandoc
       AND cob.nrdctabb = tdb.nrdctabb
       AND cob.nrdconta = tdb.nrdconta
       AND cob.nrcnvcob = tdb.nrcnvcob
       AND cob.nrdocmto = tdb.nrdocmto
     WHERE tdb.vltitulo   > cnae.vlmaximo
       AND cnae.vlmaximo > 0
       AND cob.flgregis   = 1
       AND tdb.cdcooper = pr_cdcooper
       AND tdb.nrborder = pr_nrborder --24053
       AND tdb.nrdconta = pr_nrdconta;
    rw_cnae cr_cnae%ROWTYPE;

      -- Tipo para o retorno da busca de linha de desconto dos títulos
      vr_tab_dados_dsctit typ_tab_desconto_titulos;
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
      vr_flgtrans := TRUE;

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
         vr_flgtrans := FALSE;

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
         pr_des_reto := 'NOK';
      END IF;

      -- recuperando O valor Total dos Títulos do Bordero, com COB. REGISTRADA e/ou S/ REGISTRO
      FOR rw_tdbcob_total IN cr_tdbcob_total (pr_cdcooper => pr_cdcooper,
                                              pr_nrdconta => pr_nrdconta,
                                              pr_nrborder => pr_nrborder) LOOP
        vr_vltotbdt_cr := rw_tdbcob_total.vltottit_cr;
        vr_vltotbdt_sr := rw_tdbcob_total.vltottit_sr;
      END LOOP;

      -- Elimina todas as restriçoes do borderô que está sendo analisado
      BEGIN
        DELETE FROM crapabt abt
         WHERE abt.cdcooper = pr_cdcooper
           AND abt.nrborder = pr_nrborder;
      END;

      --  INVALORMAX_CNAE    : Valor Máximo Permitido por CNAE excedido (0 = Não / 1 = Sim). (Ref. TAB052: vlmxprat)
      IF  vr_tab_dados_dsctit_cr (1).vlmxprat = 1 then
        OPEN cr_cnae(pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrborder => pr_nrborder);

        FETCH cr_cnae INTO rw_cnae;
        IF cr_cnae%FOUND THEN
            vr_dsrestri := 'Valor Máximo Permitido por CNAE excedido';
            vr_nrseqdig := 59;
            -- Se existem restrições, grava na tabela de Críticas/Restrições do Borderô
          IF vr_dsrestri IS NOT NULL AND vr_nrseqdig > 0 then
            pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_dsrestri => vr_dsrestri
                                       ,pr_nrseqdig => vr_nrseqdig
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_cdbandoc => rw_cnae.cdbandoc
                                       ,pr_nrdctabb => rw_cnae.nrdctabb
                                       ,pr_nrcnvcob => rw_cnae.nrcnvcob
                                       ,pr_nrdocmto => rw_cnae.nrdocmto
                                       ,pr_flaprcoo => 0
                                       ,pr_dsdetres => ' '
                                       ,pr_dscritic => vr_dscritic);
            CLOSE cr_cnae; 
            vr_flgtrans := FALSE;
            vr_nrseqdig := 0;
            vr_dsrestri := '';
            IF  TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END IF;
      END IF;

      -- Gerando as Restrições no Borderô por Status do Pagamento de Cobração para Tìtulo desse Borderô, se houver.
      FOR rw_craptdb_cob IN cr_craptdb_cob (pr_cdcooper => pr_cdcooper,
                                            pr_nrdconta => pr_nrdconta,
                                            pr_nrborder => pr_nrborder) LOOP
        -- a cada título, é zerada a sequência pois podem haver N restrições para o mesmo título.
        vr_nrseqdig := 0;
        vr_dsrestri := '';
        
        IF rw_craptdb_cob.dtvencto <= pr_dtmvtolt THEN
          vr_dscritic := 'Ha titulos com data de liberacao igual ou inferior a data do movimento.';
          vr_flgtrans := FALSE;
          RAISE vr_exc_erro;
          
        END IF;

        IF rw_craptdb_cob.incobran = 5 THEN
          -- Se o Tìtulo já foi pago por COBRANÇA.
          vr_dsrestri := 'Titulo ja foi pago.';
          IF rw_craptdb_cob.flgregis = 1 THEN
            vr_nrseqdig := 55;
          ELSE
            vr_nrseqdig := 5;
          END IF;
        END IF;

        IF rw_craptdb_cob.incobran = 3 THEN
          -- Se o Tìtulo já foi baixado por COBRANÇA.
          vr_dsrestri := 'Titulo baixado.';
          IF rw_craptdb_cob.flgregis = 1 THEN
            vr_nrseqdig := 53;
          ELSE
            vr_nrseqdig := 3;
          END IF;
        END IF;

         -- Se existem restrições, grava na tabela de Críticas/Restrições do Borderô
         IF vr_dsrestri IS NOT NULL AND vr_nrseqdig > 0 then
           pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                                      ,pr_cdoperad => pr_cdoperad
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_dsrestri => vr_dsrestri
                                      ,pr_nrseqdig => vr_nrseqdig
                                      ,pr_cdcooper => pr_cdcooper
                                      ,pr_cdbandoc => rw_craptdb_cob.cdbandoc
                                      ,pr_nrdctabb => rw_craptdb_cob.nrdctabb
                                      ,pr_nrcnvcob => rw_craptdb_cob.nrcnvcob
                                      ,pr_nrdocmto => rw_craptdb_cob.nrdocmto
                                      ,pr_flaprcoo => 0
                                      ,pr_dsdetres => ' '
                                      ,pr_dscritic => vr_dscritic);
           vr_flgtrans := FALSE;
           vr_nrseqdig := 0;
           vr_dsrestri := '';
           IF  TRIM(vr_dscritic) IS NOT NULL THEN
               RAISE vr_exc_erro;
           END IF;
         END IF;

         -- recuperando O valor Total dos Títulos do Borderô, com COB. REGISTRADA e/ou S/ REGISTRO
         FOR rw_tdbcob_total IN cr_tdbcob_total (pr_cdcooper => pr_cdcooper
                                                ,pr_nrdconta => pr_nrdconta
                                                ,pr_nrborder => pr_nrborder
                                                ,pr_nrinssac => rw_craptdb_cob.nrinssac) LOOP
           vr_vltotsac_cr := rw_tdbcob_total.vltottit_cr;
           vr_vltotsac_sr := rw_tdbcob_total.vltottit_sr;
         END LOOP;

         -- Verificando Restrição de "Percentual de Titulo do Pagador Excedido no Borderô.
         IF ((vr_vltotsac_cr / vr_vltotbdt_cr) *100) > vr_tab_dados_dsctit_cr(1).pcmxctip OR
            ((vr_vltotsac_sr / vr_vltotbdt_sr) *100) > vr_tab_dados_dsctit_sr(1).pcmxctip THEN -- era pctitemi
           vr_dsrestri := 'Percentual de titulo do pagador excedido no Borderô.';
           IF rw_craptdb_cob.flgregis = 1 THEN
             vr_nrseqdig := 52;
           ELSE
             vr_nrseqdig := 2;
           END IF;
         -- Se existem restrições, grava na tabela de Críticas/Restrições do Borderô
         IF vr_dsrestri IS NOT NULL AND vr_nrseqdig > 0 then
             pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                                        ,pr_cdoperad => pr_cdoperad
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_dsrestri => vr_dsrestri
                                        ,pr_nrseqdig => vr_nrseqdig
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_cdbandoc => rw_craptdb_cob.cdbandoc
                                        ,pr_nrdctabb => rw_craptdb_cob.nrdctabb
                                        ,pr_nrcnvcob => rw_craptdb_cob.nrcnvcob
                                        ,pr_nrdocmto => rw_craptdb_cob.nrdocmto
                                        ,pr_flaprcoo => 0
                                        ,pr_dsdetres => ' '
                                        ,pr_dscritic => vr_dscritic);
             vr_flgtrans := FALSE;
             vr_nrseqdig := 0;
             vr_dsrestri := '';
             IF  TRIM(vr_dscritic) IS NOT NULL THEN
                 RAISE vr_exc_erro;
             END IF;
           END IF;
         END IF;

         -- Restricao referente a consulta de CPF/CNPJ do Sacado
         IF rw_craptdb_cob.flgregis = 1 THEN -- se é COM REGISTRO
           vr_vlcontit := vr_tab_dados_dsctit_cr(1).vlconsul; -- valor que exige a consulta do CPF/CNPJ do Pagador
         ELSE -- SEM REGISTRO
           vr_vlcontit := vr_tab_dados_dsctit_sr(1).vlconsul; -- valor que exige a consulta do CPF/CNPJ do Pagador
         END IF;

         -- Se o Valor do Titulo for Maior que o Parametro da TAB052, gera restrição
         IF rw_craptdb_cob.vltitulo >  vr_vlcontit THEN
           vr_dsrestri := 'Consultar o CPF/CNPJ do pagador.';
           IF rw_craptdb_cob.flgregis = 1 THEN
             vr_nrseqdig := 54;
           ELSE
             vr_nrseqdig := 4;
           END IF;
           -- Se existem restrições, grava na tabela de Críticas/Restrições do Borderô
         IF vr_dsrestri IS NOT NULL AND vr_nrseqdig > 0 then
             pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                                        ,pr_cdoperad => pr_cdoperad
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_dsrestri => vr_dsrestri
                                        ,pr_nrseqdig => vr_nrseqdig
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_cdbandoc => rw_craptdb_cob.cdbandoc
                                        ,pr_nrdctabb => rw_craptdb_cob.nrdctabb
                                        ,pr_nrcnvcob => rw_craptdb_cob.nrcnvcob
                                        ,pr_nrdocmto => rw_craptdb_cob.nrdocmto
                                        ,pr_flaprcoo => 0
                                        ,pr_dsdetres => ' '
                                        ,pr_dscritic => vr_dscritic);
             vr_flgtrans := FALSE;
             vr_nrseqdig := 0;
             vr_dsrestri := '';
             IF  TRIM(vr_dscritic) IS NOT NULL THEN
                 RAISE vr_exc_erro;
             END IF;
           END IF;
         END IF;

         -- Se o Pagador Consta do SPC.
         FOR rw_crapass IN cr_crapass(pr_cdcooper => pr_cdcooper,
                                      pr_nrcpfcgc => rw_craptdb_cob.nrinssac)
         LOOP
           IF rw_crapass.dtdemiss is null THEN -- a análise é apenas sobre os associados que não foram demitidos.
             IF rw_crapass.inadimpl = 1 THEN -- 1 Inadimplente -- 0 Adimplente
               vr_dsrestri := 'Consultar o CPF/CNPJ do pagador.';
               IF rw_craptdb_cob.flgregis = 1 THEN
                 vr_nrseqdig := 57;
               ELSE
                 vr_nrseqdig := 7;
               END IF;
               -- Se existem restrições, grava na tabela de Críticas/Restrições do Borderô
               IF vr_dsrestri IS NOT NULL AND vr_nrseqdig > 0 then
                 pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                                            ,pr_cdoperad => pr_cdoperad
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_dsrestri => vr_dsrestri
                                            ,pr_nrseqdig => vr_nrseqdig
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_cdbandoc => rw_craptdb_cob.cdbandoc
                                            ,pr_nrdctabb => rw_craptdb_cob.nrdctabb
                                            ,pr_nrcnvcob => rw_craptdb_cob.nrcnvcob
                                            ,pr_nrdocmto => rw_craptdb_cob.nrdocmto
                                            ,pr_flaprcoo => 0
                                            ,pr_dsdetres => ' '
                                            ,pr_dscritic => vr_dscritic);
                 vr_flgtrans := FALSE;
                 vr_nrseqdig := 0;
                 vr_dsrestri := '';
                 IF  TRIM(vr_dscritic) IS NOT NULL THEN
                     RAISE vr_exc_erro;
                 END IF;
               END IF;
             END IF;
           END IF;
         END LOOP;

         -- Validações Esclusivas para Títulos com Cobrança Registrada, referentes
         --  a num. de títulos protestados e remetidos ao cartório.
         IF rw_craptdb_cob.flgregis = 1 THEN

            /* Se nrm. de tít. protest. desse sacado for maior ou igual do que param. da TAB052 gera restrição*/
            vr_cntqttit := 0;
            pc_ret_qttit_ocorrencia(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrinssac => rw_craptdb_cob.nrinssac
                                   ,pr_cdocorre => 9
                                   ,pr_cdmotivo => 14
                                   ,pr_flgtitde => False --> apenas títulos em Borderô
                                   ,pr_cntqttit => vr_cntqttit);
            IF (vr_cntqttit >= vr_tab_dados_dsctit_cr(1).qttitprt) AND
               (vr_tab_dados_dsctit_cr(1).qttitprt > 0) THEN
              vr_dsrestri := 'Pagador com titulos protestados acima do permitido.';
              vr_nrseqdig := 91;
              pr_indrestr := 1;
              pr_flsnhcoo := TRUE;
              -- Se existem restrições, grava na tabela de Críticas/Restrições do Borderô
              IF vr_dsrestri IS NOT NULL AND vr_nrseqdig > 0 then
                pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_dsrestri => vr_dsrestri
                                           ,pr_nrseqdig => vr_nrseqdig
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_cdbandoc => rw_craptdb_cob.cdbandoc
                                           ,pr_nrdctabb => rw_craptdb_cob.nrdctabb
                                           ,pr_nrcnvcob => rw_craptdb_cob.nrcnvcob
                                           ,pr_nrdocmto => rw_craptdb_cob.nrdocmto
                                           ,pr_flaprcoo => 1
                                           ,pr_dsdetres => vr_cntqttit
                                           ,pr_dscritic => vr_dscritic);
                vr_flgtrans := FALSE;
                vr_nrseqdig := 0;
                vr_dsrestri := '';
                IF  TRIM(vr_dscritic) IS NOT NULL THEN
                  RAISE vr_exc_erro;
                END IF;
              END IF;
            END IF;

            /* Se nrm. de tít. rem. ao cartorio desse sacado for maior do que param. da TAB052 */
            vr_cntqttit := 0;
            pc_ret_qttit_ocorrencia(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrinssac => rw_craptdb_cob.nrinssac
                                   ,pr_cdocorre => 23
                                   ,pr_cdmotivo => 0
                                   ,pr_flgtitde => False --> apenas títulos em Bordero
                                   ,pr_cntqttit => vr_cntqttit);
            IF (vr_cntqttit >= vr_tab_dados_dsctit_cr(1).qtremcrt) AND
               (vr_tab_dados_dsctit_cr(1).qtremcrt > 0) THEN
              vr_dsrestri := 'Pagador com titulos em cartorio acima do permitido.';
              vr_nrseqdig := 90;
              pr_indrestr := 1;
              pr_flsnhcoo := TRUE;
              -- Se existem restrições, grava na tabela de Críticas/Restrições do Borderô
              IF vr_dsrestri IS NOT NULL AND vr_nrseqdig > 0 then
                pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_dsrestri => vr_dsrestri
                                           ,pr_nrseqdig => vr_nrseqdig
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_cdbandoc => rw_craptdb_cob.cdbandoc
                                           ,pr_nrdctabb => rw_craptdb_cob.nrdctabb
                                           ,pr_nrcnvcob => rw_craptdb_cob.nrcnvcob
                                           ,pr_nrdocmto => rw_craptdb_cob.nrdocmto
                                           ,pr_flaprcoo => 1
                                           ,pr_dsdetres => vr_cntqttit
                                           ,pr_dscritic => vr_dscritic);
                vr_flgtrans := FALSE;
                vr_nrseqdig := 0;
                vr_dsrestri := '';
                IF  TRIM(vr_dscritic) IS NOT NULL THEN
                  RAISE vr_exc_erro;
                END IF;
              END IF;
            END IF;
         END IF; --Fim das Validações Esclusivas para Títulos com Cobrança Registrada

         /* Gera Erro e Grava Log */
         IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic <> '' THEN
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

      -- recuperando O valor Total dos Títulos do Borderô, com COB. REGISTRADA e/ou S/ REGISTRO
      FOR rw_tdbcob_status IN cr_tdbcob_status (pr_cdcooper => pr_cdcooper,
                                                pr_nrdconta => pr_nrdconta) LOOP
        vr_qttitdsc_cr := rw_tdbcob_status.qttitdsc_cr; --Analisado
        vr_naopagos_cr := rw_tdbcob_status.naopagos_cr; --Liberado
        vr_qttitdsc_sr := rw_tdbcob_status.qttitdsc_sr; --Analisado
        vr_naopagos_sr := rw_tdbcob_status.naopagos_sr; --Liberado
      END LOOP;

      /* retorna qtd. total títulos protestados do cedente (cooperado) */
      pc_ret_qttit_ocorrencia(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrinssac => 0 -- para o cooperado
                             ,pr_cdocorre => 9
                             ,pr_cdmotivo => 14
                             ,pr_flgtitde => FALSE --> apenas títulos em Borderô
                             ,pr_cntqttit => vr_qtprotes_cr);

      /* Carrega as quantidades de Títulos Não Pagos por Pagador */
      vr_qtnaopag_cr := 0;
      vr_qtnaopag_sr := 0;
      FOR rw_naopagos_pagador IN cr_naopagos_pagador (pr_cdcooper => pr_cdcooper
                                                     ,pr_nrdconta => pr_nrdconta
                                                     ,pr_nrmespsq => vr_tab_dados_dsctit_sr(1).nrmespsq
                                                      ) LOOP
        vr_qtnaopag_cr := rw_naopagos_pagador.qtnaopag_cr;
        vr_qtnaopag_sr := rw_naopagos_pagador.qtnaopag_sr;
      END LOOP;

      /* Valor medio por titulo descontado  para Cobrança Registrada*/
      IF vr_qttitdsc_cr > 0 THEN
        vr_pcnaopag_cr := ROUND((vr_naopagos_cr * 100) / vr_qttitdsc_cr,2);
      END IF;

      /* Valor medio por titulo descontado  para Cobrança Não Registrada*/
      IF vr_qttitdsc_sr > 0 THEN
        vr_pcnaopag_sr := ROUND((vr_naopagos_sr * 100) / vr_qttitdsc_sr,2);
      END IF;

      --APENAS VERIFICA SE HÁ ALGUM REGISTRO NA CRAPTDB - Se nesse meio tempo não foi apagado.
      OPEN cr_craptdb_cob (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrborder => pr_nrborder);
      FETCH cr_craptdb_cob INTO rw_craptdb_cob;

      IF cr_craptdb_cob%FOUND THEN

        /* Valida Quantidade de Titulos protestados (carteira cooperado) */
        IF vr_qtprotes_cr > vr_tab_dados_dsctit_cr(1).qtprotes THEN
          vr_dsrestri := 'Cooperado com titulos protestados acima do permitido.';
          vr_nrseqdig := 12;
          pr_indrestr := 1;
          pr_flsnhcoo := TRUE;
          -- Se existem restrições, grava na tabela de Críticas/Restrições do Borderô
          IF vr_dsrestri IS NOT NULL AND vr_nrseqdig > 0 then
            pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_dsrestri => vr_dsrestri
                                       ,pr_nrseqdig => vr_nrseqdig
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_flaprcoo => 1
                                       ,pr_dsdetres => vr_qtprotes_cr
                                       ,pr_dscritic => vr_dscritic);
            vr_flgtrans := FALSE;
            vr_nrseqdig := 0;
            vr_dsrestri := '';
            IF  TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END IF;

        /* Valida Qtde de Titulos não Pago Pagador */
        IF vr_qtnaopag_cr > vr_tab_dados_dsctit_cr(1).qtnaopag OR
           vr_qtnaopag_sr > vr_tab_dados_dsctit_sr(1).qtnaopag THEN
          vr_dsrestri := 'Pagador com titulos não pagos acima do permitido.';
          vr_dsdetres := 'Com Registro: ' || vr_qtnaopag_cr || '. Sem Registro: ' || vr_qtnaopag_sr;
          vr_nrseqdig := 10;
          pr_indrestr := 1;
          pr_flsnhcoo := TRUE;
          -- Se existem restrições, grava na tabela de Críticas/Restrições do Borderô
          IF vr_dsrestri IS NOT NULL AND vr_nrseqdig > 0 then
            pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_dsrestri => vr_dsrestri
                                       ,pr_nrseqdig => vr_nrseqdig
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_flaprcoo => 1
                                       ,pr_dsdetres => vr_dsdetres
                                       ,pr_dscritic => vr_dscritic);
            vr_flgtrans := FALSE;
            vr_nrseqdig := 0;
            vr_dsrestri := '';
            IF  TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END IF;

        /* Valida Perc. de Titulos não Pago Beneficiario */
        IF vr_pcnaopag_cr > vr_tab_dados_dsctit_cr(1).pcnaopag OR
           vr_qtnaopag_sr > vr_tab_dados_dsctit_sr(1).pcnaopag THEN
          vr_dsrestri := 'Cooperado com titulos não pagos acima do permitido.';
          vr_dsdetres := 'Com Registro: ' || vr_pcnaopag_cr || '. Sem Registro: ' || vr_pcnaopag_sr;
          vr_nrseqdig := 11;
          pr_indrestr := 1;
          pr_flsnhcoo := TRUE;
          -- Se existem restrições, grava na tabela de Críticas/Restrições do Borderô
          IF vr_dsrestri IS NOT NULL AND vr_nrseqdig > 0 then
            pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_dsrestri => vr_dsrestri
                                       ,pr_nrseqdig => vr_nrseqdig
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_flaprcoo => 1
                                       ,pr_dsdetres => vr_dsdetres
                                       ,pr_dscritic => vr_dscritic);
            vr_flgtrans := FALSE;
            vr_nrseqdig := 0;
            vr_dsrestri := '';
            IF  TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END IF;

        CLOSE cr_craptdb_cob;
      END IF;

      -- se retornar restrição
      IF pr_indrestr = 1 THEN

        -- Carregar dados de Valores do Cooperado.
        vr_vlmaxleg := 0;
        vr_vlmaxutl := 0;
        vr_vlminscr := 0;

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

          IF  vr_vlmaxutl > 0 THEN

            --  Verifica se o valor é maior que o valor maximo utilizado pelo associado nos emprestimos
            IF vr_vlutiliz > vr_vlmaxutl THEN
              vr_dsrestri := 'Valores utilizados excedidos.';
              vr_dsdetres := 'Utilizado R$: ' || to_char(vr_vlutiliz,'999G999G990D00') || '. Excedido R$: ' ||
                                                 to_char((vr_vlutiliz - vr_vlmaxutl),'999G999G990D00');
              vr_nrseqdig := 13;
              pr_indrestr := 1;
              pr_flsnhcoo := TRUE;
              -- Se existem restrições, grava na tabela de Críticas/Restrições do Borderô
              IF vr_dsrestri IS NOT NULL AND vr_nrseqdig > 0 then
                pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_dsrestri => vr_dsrestri
                                           ,pr_nrseqdig => vr_nrseqdig
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_flaprcoo => 1
                                           ,pr_dsdetres => vr_dsdetres
                                           ,pr_dscritic => vr_dscritic);
                vr_flgtrans := FALSE;
                vr_nrseqdig := 0;
                vr_dsrestri := '';
                IF  TRIM(vr_dscritic) IS NOT NULL THEN
                  RAISE vr_exc_erro;
                END IF;
              END IF;
            END IF;

            --  Verifica se o valor é maior que o valor legal a ser emprestado pela cooperativa
            IF vr_vlutiliz > vr_vlmaxleg THEN
              vr_dsrestri := 'Valor Legal Excedido.';
              vr_dsdetres := 'Utilizado R$: ' || to_char(vr_vlutiliz,'999G999G990D00') || '. Excedido R$: ' ||
                                                 to_char((vr_vlutiliz - vr_vlmaxleg),'999G999G990D00');
              vr_nrseqdig := 14;
              pr_indrestr := 1;
              pr_flsnhcoo := TRUE;
              -- Se existem restrições, grava na tabela de Críticas/Restrições do Borderô
              IF vr_dsrestri IS NOT NULL AND vr_nrseqdig > 0 then
                pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_dsrestri => vr_dsrestri
                                           ,pr_nrseqdig => vr_nrseqdig
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_flaprcoo => 1
                                           ,pr_dsdetres => vr_dsdetres
                                           ,pr_dscritic => vr_dscritic);
                vr_flgtrans := FALSE;
                vr_nrseqdig := 0;
                vr_dsrestri := '';

                vr_dscritic := '';
                vr_cdcritic := 79;

                IF  TRIM(vr_dscritic) IS NOT NULL THEN
                  RAISE vr_exc_erro;
                END IF;
              END IF;
            END IF;

            --  Verifica se o valor é maior que o valor da consulta SCR
            IF  vr_vlutiliz > vr_vlminscr THEN
              vr_dsrestri := 'Efetue consulta no SCR.';
              vr_dsdetres := ' ';
              vr_nrseqdig := 15;
              pr_indrestr := 1;
              pr_flsnhcoo := TRUE;
              -- Se existem restrições, grava na tabela de Críticas/Restrições do Borderô
              IF vr_dsrestri IS NOT NULL AND vr_nrseqdig > 0 then
                pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_dsrestri => vr_dsrestri
                                           ,pr_nrseqdig => vr_nrseqdig
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_flaprcoo => 1
                                           ,pr_dsdetres => vr_dsdetres
                                           ,pr_dscritic => vr_dscritic);
                vr_flgtrans := FALSE;
                vr_nrseqdig := 0;
                vr_dsrestri := '';

                vr_dscritic := '';
                vr_cdcritic := 79;

                IF  TRIM(vr_dscritic) IS NOT NULL THEN
                  RAISE vr_exc_erro;
                END IF;
              END IF;
            END IF;
          END IF; -- fim vr_vlmaxutl > 0
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

          IF  vr_vlmaxutl > 0 THEN
            IF vr_vlutiliz > vr_vlmaxutl THEN
              vr_dsrestri := 'Valores utilizados excedidos.';
              vr_dsdetres := 'Utilizado R$: ' || to_char(vr_vlutiliz,'999G999G990D00') || '. Excedido R$: ' ||
                                                 to_char((vr_vlutiliz - vr_vlmaxutl),'999G999G990D00');
              vr_nrseqdig := 13;
              pr_indrestr := 1;
              pr_flsnhcoo := TRUE;
              -- Se existem restrições, grava na tabela de Críticas/Restrições do Borderô
              IF vr_dsrestri IS NOT NULL AND vr_nrseqdig > 0 then
                pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_dsrestri => vr_dsrestri
                                           ,pr_nrseqdig => vr_nrseqdig
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_flaprcoo => 1
                                           ,pr_dsdetres => vr_dsdetres
                                           ,pr_dscritic => vr_dscritic);
                vr_flgtrans := FALSE;
                vr_nrseqdig := 0;
                vr_dsrestri := '';
                IF  TRIM(vr_dscritic) IS NOT NULL THEN
                  RAISE vr_exc_erro;
                END IF;
              END IF;
            END IF;

            IF vr_vlutiliz > vr_vlmaxleg THEN
              vr_dsrestri := 'Valor Legal Excedido.';
              vr_dsdetres := 'Utilizado R$: ' || to_char(vr_vlutiliz,'999G999G990D00') || '. Excedido R$: ' ||
                                                 to_char((vr_vlutiliz - vr_vlmaxleg),'999G999G990D00');
              vr_nrseqdig := 14;
              pr_indrestr := 1;
              pr_flsnhcoo := TRUE;
              -- Se existem restrições, grava na tabela de Críticas/Restrições do Borderô
              IF vr_dsrestri IS NOT NULL AND vr_nrseqdig > 0 then
                pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_dsrestri => vr_dsrestri
                                           ,pr_nrseqdig => vr_nrseqdig
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_flaprcoo => 1
                                           ,pr_dsdetres => vr_dsdetres
                                           ,pr_dscritic => vr_dscritic);
                vr_flgtrans := FALSE;
                vr_nrseqdig := 0;
                vr_dsrestri := '';

                vr_dscritic := '';
                vr_cdcritic := 79;

                IF  TRIM(vr_dscritic) IS NOT NULL THEN
                  RAISE vr_exc_erro;
                END IF;
              END IF;
            END IF;

            --  Verifica se o valor é maior que o valor da consulta SCR
            IF  vr_vlutiliz > vr_vlminscr THEN
              vr_dsrestri := 'Efetue consulta no SCR.';
              vr_dsdetres := ' ';
              vr_nrseqdig := 15;
              pr_indrestr := 1;
              pr_flsnhcoo := TRUE;
              -- Se existem restrições, grava na tabela de Críticas/Restrições do Borderô
              IF vr_dsrestri IS NOT NULL AND vr_nrseqdig > 0 then
                pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_dsrestri => vr_dsrestri
                                           ,pr_nrseqdig => vr_nrseqdig
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_flaprcoo => 1
                                           ,pr_dsdetres => vr_dsdetres
                                           ,pr_dscritic => vr_dscritic);
                vr_flgtrans := FALSE;
                vr_nrseqdig := 0;
                vr_dsrestri := '';

                vr_dscritic := '';
                vr_cdcritic := 79;

                IF  TRIM(vr_dscritic) IS NOT NULL THEN
                  RAISE vr_exc_erro;
                END IF;
              END IF;
            END IF;
          END IF;
        END IF;
      END IF; -- fim das validações se gerar restrição.

      IF NOT vr_flgtrans THEN
         pr_des_reto := 'NOK';
      ELSE
         pr_des_reto := 'OK';
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
          pr_des_reto := 'NOK';
    when others then
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := replace(replace('Erro pc_restricoes_tit_bordero: ' || sqlerrm, chr(13)),chr(10));
         pr_des_reto := 'NOK';
    END;

  END pc_restricoes_tit_bordero;

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
                                      ,pr_flgerlog IN BOOLEAN               --> identificador se deve gerar log
                                      --------> OUT <--------
                                      ,pr_indrestr OUT PLS_INTEGER          --> Indica se Gerou Restrição (0 - Sem Restrição / 1 - Com restrição)
                                      ,pr_ind_inpeditivo OUT PLS_INTEGER          --> Indica se o Resultado é Impeditivo para Realizar Liberação. (0 - Sem Impedimentos / 1 - Com Impedimentos)
                                      ,pr_tab_erro OUT GENE0001.typ_tab_erro --> Tabela Erros
                                      ,pr_tab_retorno_analise OUT typ_tab_retorno_analise --> Detalhes Finais da Analise do Bordero.
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descriçao da crítica
                                      ) IS
  BEGIN
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

      --Tabela erro
      vr_tab_erro GENE0001.typ_tab_erro;

      -- rowid tabela de log
      vr_nrdrowid ROWID;

      -- Variáveis de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      --============== CURSORES ==================
      CURSOR cr_crapbdt (pr_cdcooper IN crapbdt.cdcooper%TYPE
                        ,pr_nrborder IN crapbdt.nrborder%TYPE) IS
        SELECT crapbdt.cdcooper
              ,crapbdt.nrborder
              ,crapbdt.nrdconta
              ,crapbdt.insitbdt
              ,crapbdt.rowid
        FROM crapbdt
        WHERE crapbdt.cdcooper = pr_cdcooper
        AND   crapbdt.nrborder = pr_nrborder;
      rw_crapbdt cr_crapbdt%ROWTYPE;

    BEGIN
      --Iniciar variáveis e Parâmetros de Retorno
      pr_ind_inpeditivo := 0;
      vr_des_reto := 'OK';
      vr_indrestr := 0;

      --Seta as variáveis de Descrição de Origem e descrição de Transação se For gerar Log
      IF pr_flgerlog THEN
        vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
        vr_dstransa := 'Analisar o Borderô ' || pr_nrborder || ' de Desconto de Título.';
      END IF;

      --Limpar tabelas
      pr_tab_erro.DELETE;

      --Selecionar bordero titulo
      OPEN cr_crapbdt (pr_cdcooper => pr_cdcooper
                      ,pr_nrborder => pr_nrborder);
      --Posicionar no proximo registro
      FETCH cr_crapbdt INTO rw_crapbdt;
      --Se não encontrar
      IF cr_crapbdt%NOTFOUND THEN
        CLOSE cr_crapbdt;
        vr_dscritic:= 'Registro de Borderô Não Encontrado.';
        pr_ind_inpeditivo := 1;
        RAISE vr_exc_erro;
      ELSE
        -- Verifica situação do Bordero
        if rw_crapbdt.insitbdt > 2  THEN
           vr_dscritic := 'O Borderô deve estar na situação EM ESTUDO ou ANALISADO.';
           CLOSE cr_crapbdt;
           pr_ind_inpeditivo := 1;
           raise vr_exc_erro;
        ELSE
           vr_dscritic := NULL;
           CLOSE cr_crapbdt;
        END IF;
      END IF;

      --> Verificar se saiu do loop com critica
      IF vr_dscritic IS NOT NULL THEN
        pr_ind_inpeditivo := 1;
        RAISE vr_exc_erro;
      END IF;

      --Verifica se os Títulos estão em algum outro bordero
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

      -- Se o Tìtulo já está em um Borderô, Levanta a Exceção (Impeditivo)
      IF vr_des_reto  <> 'OK' THEN
        --Verifica se Foi Erro de Execução ou se o Título Estava mesmo em Outro Borderô
        IF vr_tab_erro.COUNT = 0 THEN
          --Se o Erro foi de Execução
          vr_dscritic := 'Nao foi possível validar o Borderô.';
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
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craplim;
      END IF;

      -- Verifica se Existe o Associado E Realiza as Validações sobre o Associado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;

      IF cr_crapass%NOTFOUND THEN
        vr_cdcritic := 9;
        vr_dscritic := '';
        RAISE vr_exc_erro;
      ELSE
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
        CLOSE cr_crapass;
        -- Se retornou erro
        IF vr_des_reto <> 'OK' THEN
          vr_cdcritic := 0;
          vr_dscritic := vr_dscritic ||' - Não foi possível verificar o cadastro restritivo.';
          RAISE vr_exc_erro;
        END IF;
      END IF;

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
                               ,pr_des_reto =>  vr_des_reto
                               ,pr_cdcritic =>  vr_cdcritic
                               ,pr_dscritic =>  vr_dscritic);
                               
       IF (vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL) THEN
         raise vr_exc_erro;
       END IF;

       pr_indrestr := vr_indrestr;

       --Verificando se Ocorreram Restrições, para Gerar Crítica se Foi "Aprovado Automaticamente Com Restrições",
       --ou "Aprovado Automaticamente Sem Restrições".
       IF vr_indrestr = 0 THEN -- SEM RESTRIÇÃO E SEM IMPEDITIVOS, APROVADO AUTOMATICAMENTE.
         pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                                    ,pr_cdoperad => pr_cdoperad
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_dsrestri => 'Borderô Aprovado Automaticamente.'
                                    ,pr_nrseqdig => 88
                                    ,pr_cdcooper => pr_cdcooper
                                    ,pr_flaprcoo => 1
                                    ,pr_dsdetres => ('Bordero' || pr_nrborder ||' Analisado Sem Restrições.')
                                    ,pr_dscritic => vr_dscritic);
         pr_tab_retorno_analise(0).dssitres := 'Borderô Aprovado Automaticamente.';
       END IF;

       pr_tab_retorno_analise(0).cdcooper := pr_cdcooper;
       pr_tab_retorno_analise(0).nrborder := pr_nrborder;
       pr_tab_retorno_analise(0).nrdconta := pr_nrdconta;

       IF vr_indrestr > 0 THEN -- COM RESTRIÇÃO E SEM IMPEDITIVOS, APROVADO AUTOMATICAMENTE.
         pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                                    ,pr_cdoperad => pr_cdoperad
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_dsrestri => 'Borderô Aprovado Automaticamente.'
                                    ,pr_nrseqdig => 88
                                    ,pr_cdcooper => pr_cdcooper
                                    ,pr_flaprcoo => 1
                                    ,pr_dsdetres => ('Bordero' || pr_nrborder || ' Analisado Com Restrições.')
                                    ,pr_dscritic => vr_dscritic);
         pr_tab_retorno_analise(0).dssitres := 'Borderô Aprovado Automaticamente. Análise Com Restrições';
       END IF;

       -- Apenas me certiciando que não ocorreram erros impeditivos que não passaram para a vr_exc_erro.
       IF pr_ind_inpeditivo = 0 THEN
         pc_altera_status_bordero(pr_cdcooper => pr_cdcooper
                                 ,pr_nrborder => pr_nrborder
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_status   => 2 -- estou considerando 5 como aprovado automaticamente.
                                 ,pr_dscritic => vr_dscritic
                                 );
         IF vr_dscritic IS NOT NULL THEN
           pr_tab_retorno_analise.DELETE;
           RAISE vr_exc_erro;
         END IF;
       END IF;





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
    vr_msgcontingencia varchar2(100);

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
    vr_dscritic varchar2(1000);        --> Desc. Erro

    vr_tab_retorno_analise typ_tab_retorno_analise;

    -- variaveis de data
    vr_dtmvtopr crapdat.dtmvtolt%TYPE;
    vr_dtmvtolt crapdat.dtmvtolt%TYPE;

    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    vr_em_contingencia_ibratan boolean;

    BEGIN
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
      
      -- Inicia Variável de msg de contingência.
      vr_msgcontingencia := '';

      /*Executar a Análise do Bordero*/
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

      -- Verificar se a esteira e/ou motor estão em contigencia e armazenar na variavel
      vr_em_contingencia_ibratan := tela_atenda_dscto_tit.fn_em_contingencia_ibratan(pr_cdcooper => vr_cdcooper);

      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;

      IF  vr_em_contingencia_ibratan THEN -- Em Contingência
        vr_msgcontingencia := 'Análise em contingência, consulta aos birôs não realizada. ' || CHR(13);
      END IF;
      
      /*Passou nas validações do bordero, do contrato e listou titulos. Começa a montar o xml*/
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados>');

      pc_escreve_xml('<analisebordero>'||
                          '<nrborder>' || vr_tab_retorno_analise(0).nrborder || '</nrborder>' ||
                          '<cdcooper>' || vr_tab_retorno_analise(0).cdcooper || '</cdcooper>' ||
                          '<nrdconta>' || vr_tab_retorno_analise(0).nrdconta || '</nrdconta>' ||
                          '<msgretorno>' || vr_msgcontingencia || vr_tab_retorno_analise(0).dssitres || '</msgretorno>' ||
                    '</analisebordero>');
                    
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
           pr_dscritic := 'erro não tratado na tela_titcto.pc_buscar_dados_bordero_web ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_efetua_analise_bordero_web;

END DSCT0003;
/
