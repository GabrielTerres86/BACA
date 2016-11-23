CREATE OR REPLACE PACKAGE CECRED.DSCC0001 AS

  /*-------------------------------------------------------------------------------------------------------------
  --
  --  Programa: DSCC0001                        Antiga: generico/procedures/b1wgen0009.p
  --  Autor   : Jaison
  --  Data    : Agosto/2016                     Ultima Atualizacao: 
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package para rotinas envolvendo desconto de cheques.
  --
  --  Alteracoes: 22/08/2016 - Conversao Progress -> Oracle (Jaison/Daniel)
  --  
  --------------------------------------------------------------------------------------------------------------*/

  --> Buscar parametros gerais de desconto de cheque - TAB019
  PROCEDURE pc_busca_parametros_dscchq(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da Cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                      ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> data do movimento 
                                      ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                       --------> OUT <--------
                                      ,pr_tab_dados_dscchq  OUT DSCT0002.typ_tab_dados_dscchq --> Tabela contendo os parametros
                                      ,pr_cdcritic          OUT PLS_INTEGER  --> Codigo da critica
                                      ,pr_dscritic          OUT VARCHAR2);   --> Descricao da critica
  
  -->  Buscar restricoes de um determinado bordero ou cheque  
  PROCEDURE pc_busca_restricoes(pr_cdcooper IN crapabc.cdcooper%TYPE  --> Código da Cooperativa
                               ,pr_nrborder IN crapabc.nrborder%TYPE  --> numero do bordero
                               ,pr_cdcmpchq IN crapabc.cdcmpchq%TYPE  --> Codigo da compensacao impressa no cheque acolhido
                               ,pr_cdbanchq IN crapabc.cdbanchq%TYPE  --> Codigo do banco impresso no cheque acolhido
                               ,pr_cdagechq IN crapabc.cdagechq%TYPE  --> Codigo da agencia impressa no cheque acolhido
                               ,pr_nrctachq IN crapabc.nrctachq%TYPE  --> Numero da conta do cheque acolhido
                               ,pr_nrcheque IN crapabc.nrcheque%TYPE  --> Numero do cheque capturado
                               ,pr_tprestri IN INTEGER                --> Tipo de restricao
                               --------> OUT <--------                                   
                               ,pr_tab_bordero_restri IN OUT NOCOPY DSCT0002.typ_tab_bordero_restri --> retorna restricoes do cheques do bordero
                               ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica
  
  --> Buscar dados de um determinado bordero
  PROCEDURE pc_busca_dados_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                  ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                  ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                  ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                  ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                  ,pr_cddopcao IN VARCHAR2               --> Cod opcao
                                  --------> OUT <--------                                   
                                  ,pr_tab_dados_border OUT DSCT0002.typ_tab_dados_border --> retorna dados do bordero
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica
  
  --> Buscar cheques de um determinado bordero a partir da crapcdb 
  PROCEDURE pc_busca_cheques_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data atual
                                    ,pr_nrborder IN crapbdc.nrborder%TYPE  --> numero do bordero
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                    --------> OUT <--------                                   
                                    ,pr_tab_chq_bordero        OUT DSCT0002.typ_tab_chq_bordero    --> retorna cheques do bordero
                                    ,pr_tab_bordero_restri     OUT DSCT0002.typ_tab_bordero_restri --> retorna restricoes do cheques do bordero
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica
  
  --> Carrega dados com os cheques do bordero
  PROCEDURE pc_carrega_dados_bordero_chq(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                        ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                        ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Numero do contrato de limite
                                        ,pr_nrborder IN crapbdc.nrborder%TYPE  --> Numero do bordero
                                        ,pr_txdiaria IN NUMBER                 --> Taxa diaria
                                        ,pr_txmensal IN NUMBER                 --> Taxa mensa
                                        ,pr_txdanual IN NUMBER                 --> Taxa anual
                                        ,pr_vllimite IN craplim.vllimite%TYPE  --> Valor limite de desconto
                                        ,pr_ddmvtolt IN INTEGER                --> Dia movimento
                                        ,pr_dsmesref IN VARCHAR2               --> Descricao do mes
                                        ,pr_aamvtolt INTEGER                   --> Ano de movimento
                                        ,pr_nmprimtl IN crapass.nmprimtl%TYPE  --> Nome do cooperado
                                        ,pr_nmrescop IN crapcop.nmrescop%TYPE  --> Nome resumido da cooperativa
                                        ,pr_nmextcop IN crapcop.nmextcop%TYPE  --> Nome completo da cooperativa
                                        ,pr_nmcidade IN crapcop.nmcidade%TYPE  --> Nome da cidade
                                        ,pr_nmoperad IN crapope.nmoperad%TYPE  --> Nome do operador
                                        ,pr_dsopecoo IN VARCHAR2               --> Descricao operador coordenador
                                        --------> OUT <--------                                   
                                        ,pr_tab_dados_itens_bordero OUT DSCT0002.typ_tab_dados_itens_bordero --> retorna dados do bordero
                                        ,pr_tab_chq_bordero         OUT DSCT0002.typ_tab_chq_bordero         --> retorna cheques do bordero
                                        ,pr_tab_bordero_restri      OUT DSCT0002.typ_tab_bordero_restri      --> retorna restricoes do cheques do bordero
                                        ,pr_cdcritic                OUT PLS_INTEGER --> Código da crítica
                                        ,pr_dscritic                OUT VARCHAR2);  --> Descrição da crítica

  --> Carregar dados para efetuar a impressao da nota promissoria
  PROCEDURE pc_dados_nota_promissoria(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Código da Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE   --> Código da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE   --> Numero do caixa do operador
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE   --> Código do Operador
                                     ,pr_inpessoa IN crapass.inpessoa%TYPE   --> Tipo de pessoa
                                     ,pr_nrcpfcgc IN VARCHAR2                --> Numero CPF/CNPJ
                                     ,pr_nrctrlim IN INTEGER                 --> Numero do contrato
                                     ,pr_vllimite IN NUMBER                  --> Valor do limite
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE   --> Data do movimento
                                     ,pr_dsemsnot IN VARCHAR2                --> Descricao nota
                                     ,pr_dsmesref IN VARCHAR2                --> Mes de referencia
                                     ,pr_nmrescop IN crapcop.nmrescop%TYPE   --> Nome resumido da cooperativa
                                     ,pr_nmextcop IN crapcop.nmextcop%TYPE   --> Nome extenso da cooperativa
                                     ,pr_nrdocnpj IN crapcop.nrdocnpj%TYPE   --> Numero do CNPJ
                                     ,pr_dsdmoeda IN VARCHAR2                --> Descricao da moeda
                                     ,pr_nmprimtl IN crapass.nmprimtl%TYPE   --> Nome do cooperado
                                      --------> OUT <--------
                                     ,pr_tab_dados_nota_pro  OUT DSCT0002.typ_tab_dados_nota_pro  --> Tabela contendo dados nota promissoria
                                     ,pr_cdcritic            OUT PLS_INTEGER --> Codigo da critica
                                     ,pr_dscritic            OUT VARCHAR2);  --> Descricao da critica
  
  --> Procedure para gerar impressoes do bordero
  PROCEDURE pc_gera_impressao_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_cdagecxa IN crapage.cdagenci%TYPE  --> Código da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdopecxa IN crapope.cdoperad%TYPE  --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE  --> Data do proximo Movimento
                                     ,pr_inproces IN crapdat.inproces%TYPE  --> Indicador do processo 
                                     ,pr_idimpres IN INTEGER                --> Indicador de impressao
                                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                     ,pr_nrborder IN crapbdc.nrborder%TYPE  --> Numero do bordero
                                     ,pr_dsiduser IN VARCHAR2               --> Descricao do id do usuario
                                     ,pr_flgemail IN INTEGER                --> Indicador de envia por email (0-nao, 1-sim)
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     --------> OUT <--------                                   
                                     ,pr_nmarqpdf OUT VARCHAR2              --> Retornar nome do relatorio PDF
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica

  --> Procedure para gerar impressoes
  PROCEDURE pc_gera_impressao(pr_nrdconta   IN crapass.nrdconta%TYPE --> Número da Conta
                             ,pr_idseqttl   IN crapttl.idseqttl%TYPE --> Titular da Conta
                             ,pr_idimpres   IN INTEGER               --> Indicador de impressao
                             ,pr_tpctrlim   IN craplim.tpctrlim%TYPE --> Tipo de contrato de limite(2-Cheque e 3-Titulo)
                             ,pr_nrctrlim   IN craplim.nrctrlim%TYPE --> Contrato
                             ,pr_nrborder   IN crapbdc.nrborder%TYPE --> Numero do bordero
                             ,pr_dsiduser   IN VARCHAR2              --> Descricao do id do usuario
                             ,pr_flgemail   IN INTEGER               --> Indicador de envia por email (0-nao, 1-sim)
                             ,pr_flgerlog   IN INTEGER               --> Indicador se deve gerar log(0-nao, 1-sim)
                             ,pr_xmllog     IN VARCHAR2              --> XML com informacoes de LOG
                             ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                             ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                             ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                             ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                             ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo

END DSCC0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.DSCC0001 AS

 /*-------------------------------------------------------------------------------------------------------------
  --
  --  Programa: DSCC0001                        Antiga: generico/procedures/b1wgen0009.p
  --  Autor   : Jaison
  --  Data    : Agosto/2016                     Ultima Atualizacao: 
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package para rotinas envolvendo desconto de cheques.
  --
  --  Alteracoes: 22/08/2016 - Conversao Progress -> Oracle (Jaison/Daniel)
  --  
  --------------------------------------------------------------------------------------------------------------*/

  --> Buscar parametros gerais de desconto de cheque - TAB019
  PROCEDURE pc_busca_parametros_dscchq(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da Cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                      ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> data do movimento 
                                      ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                       --------> OUT <--------
                                      ,pr_tab_dados_dscchq  OUT DSCT0002.typ_tab_dados_dscchq --> Tabela contendo os parametros
                                      ,pr_cdcritic          OUT PLS_INTEGER  --> Codigo da critica
                                      ,pr_dscritic          OUT VARCHAR2) IS --> Descricao da critica
    /* .........................................................................
    --
    --  Programa : pc_busca_parametros_dscchq           Antigo: b1wgen0009.p/busca_parametros_dscchq
    --  Sistema  : CRED
    --  Sigla    : DSCC0001
    --  Autor    : Jaison
    --  Data     : Agosto/2016                          Ultima atualizacao: 22/08/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para efetuar buscar de parametros gerais de desconto de cheque - TAB019
    --
    --   Alteração : 22/08/2016 - Conversao Progress -> Oracle (Jaison/Daniel)
    -- .........................................................................*/
    
    --------->> VARIAVEIS <<--------
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro        
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;    

    vr_dstextab          craptab.dstextab%TYPE;
    vr_idxdscti          PLS_INTEGER;

  BEGIN
    -- Limpa a PLTABLE
    pr_tab_dados_dscchq.DELETE;

    -- Buscar valores do parametro
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper, 
                                              pr_nmsistem => 'CRED'     , 
                                              pr_tptabela => 'USUARI'   , 
                                              pr_cdempres => 11         , 
                                              pr_cdacesso => 'LIMDESCONT', 
                                              pr_tpregist => 0);

    IF TRIM(vr_dstextab) IS NOT NULL THEN

      vr_idxdscti := pr_tab_dados_dscchq.COUNT() + 1;
      pr_tab_dados_dscchq(vr_idxdscti).vllimite := SUBSTR(vr_dstextab,01,12);
      pr_tab_dados_dscchq(vr_idxdscti).qtdiavig := SUBSTR(vr_dstextab,14,04);
      pr_tab_dados_dscchq(vr_idxdscti).qtrenova := SUBSTR(vr_dstextab,19,02);
      pr_tab_dados_dscchq(vr_idxdscti).qtprzmin := SUBSTR(vr_dstextab,22,03);
      pr_tab_dados_dscchq(vr_idxdscti).qtprzmax := SUBSTR(vr_dstextab,26,03);
      pr_tab_dados_dscchq(vr_idxdscti).pcdmulta := SUBSTR(vr_dstextab,30,10);
      pr_tab_dados_dscchq(vr_idxdscti).vlconchq := SUBSTR(vr_dstextab,41,12);
      pr_tab_dados_dscchq(vr_idxdscti).vlmaxemi := SUBSTR(vr_dstextab,54,12);
      pr_tab_dados_dscchq(vr_idxdscti).pcchqloc := SUBSTR(vr_dstextab,67,03);
      pr_tab_dados_dscchq(vr_idxdscti).pcchqemi := SUBSTR(vr_dstextab,71,03);
      pr_tab_dados_dscchq(vr_idxdscti).qtdiasoc := SUBSTR(vr_dstextab,75,03);
      pr_tab_dados_dscchq(vr_idxdscti).qtdevchq := SUBSTR(vr_dstextab,79,03);
      pr_tab_dados_dscchq(vr_idxdscti).pctolera := SUBSTR(vr_dstextab,83,03);

    ELSE
      vr_cdcritic := 0;
      vr_dscritic := 'Registro de parametros de desconto de cheques nao encontrado.';
      RAISE vr_exc_erro;    
    END IF;

  EXCEPTION    
    WHEN vr_exc_erro THEN
      
      IF NVL(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := REPLACE(REPLACE(vr_dscritic,chr(13)),chr(10));
      END IF;
      
    WHEN OTHERS THEN      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := REPLACE(REPLACE('Nao foi possivel buscar parametros de desconto de cheques: ' || SQLERRM, chr(13)),chr(10));

  END pc_busca_parametros_dscchq;
  
  -->  Buscar restricoes de um determinado bordero ou cheque  
  PROCEDURE pc_busca_restricoes(pr_cdcooper IN crapabc.cdcooper%TYPE  --> Código da Cooperativa
                               ,pr_nrborder IN crapabc.nrborder%TYPE  --> numero do bordero
                               ,pr_cdcmpchq IN crapabc.cdcmpchq%TYPE  --> Codigo da compensacao impressa no cheque acolhido
                               ,pr_cdbanchq IN crapabc.cdbanchq%TYPE  --> Codigo do banco impresso no cheque acolhido
                               ,pr_cdagechq IN crapabc.cdagechq%TYPE  --> Codigo da agencia impressa no cheque acolhido
                               ,pr_nrctachq IN crapabc.nrctachq%TYPE  --> Numero da conta do cheque acolhido
                               ,pr_nrcheque IN crapabc.nrcheque%TYPE  --> Numero do cheque capturado
                               ,pr_tprestri IN INTEGER                --> Tipo de restricao
                               --------> OUT <--------                                   
                               ,pr_tab_bordero_restri IN OUT NOCOPY DSCT0002.typ_tab_bordero_restri --> retorna restricoes do cheques do bordero
                               ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    /* .........................................................................
    --
    --  Programa : pc_busca_restricoes           Antigo:
    --  Sistema  : CRED
    --  Sigla    : DSCC0001
    --  Autor    : Jaison
    --  Data     : Agosto/2016                   Ultima atualizacao: 30/08/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Buscar restricoes de um determinado bordero ou cheque  
    --
    --   Alteração : 30/08/2016 - Conversao Progress -> Oracle (Jaison/Daniel)
    -- .........................................................................*/

    ---------->>> CURSORES <<<---------- 
    --> Buscar restricoes da analise de bordero de cheques
    CURSOR cr_crapabc IS
      SELECT abc.nrborder
            ,abc.nrcheque
            ,abc.dsrestri
            ,abc.flaprcoo
            ,abc.dsdetres
        FROM crapabc abc
       WHERE abc.cdcooper = pr_cdcooper
         AND abc.nrborder = pr_nrborder
         AND abc.cdcmpchq = pr_cdcmpchq
         AND abc.cdbanchq = pr_cdbanchq
         AND abc.cdagechq = pr_cdagechq
         AND abc.nrctachq = pr_nrctachq
         AND abc.nrcheque = pr_nrcheque;

    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    

    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;    
    vr_idxrestr        PLS_INTEGER;

  BEGIN

    --> Buscar restricoes da analise de bordero de cheques
    FOR rw_crapabc IN cr_crapabc LOOP
      vr_idxrestr := pr_tab_bordero_restri.COUNT + 1;
      pr_tab_bordero_restri(vr_idxrestr).nrborder := rw_crapabc.nrborder;
      pr_tab_bordero_restri(vr_idxrestr).nrcheque := rw_crapabc.nrcheque;
      pr_tab_bordero_restri(vr_idxrestr).dsrestri := rw_crapabc.dsrestri;
      pr_tab_bordero_restri(vr_idxrestr).flaprcoo := rw_crapabc.flaprcoo;
      pr_tab_bordero_restri(vr_idxrestr).dsdetres := rw_crapabc.dsdetres;
      pr_tab_bordero_restri(vr_idxrestr).tprestri := pr_tprestri;
    END LOOP;

  EXCEPTION
    WHEN vr_exc_erro THEN

      IF nvl(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := REPLACE(REPLACE('Erro pc_busca_restricoes: ' || SQLERRM, chr(13)),chr(10));

  END pc_busca_restricoes;
  
  --> Buscar dados de um determinado bordero
  PROCEDURE pc_busca_dados_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                  ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                  ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                  ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                  ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                  ,pr_cddopcao IN VARCHAR2               --> Cod opcao
                                  --------> OUT <--------                                   
                                  ,pr_tab_dados_border OUT DSCT0002.typ_tab_dados_border --> retorna dados do bordero
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    /* .........................................................................
    --
    --  Programa : pc_busca_dados_bordero           Antigo: b1wgen0009.p/busca_dados_bordero
    --  Sistema  : CRED
    --  Sigla    : DSCC0001
    --  Autor    : Jaison
    --  Data     : Agosto/2016                      Ultima atualizacao: 29/08/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Buscar dados de um determinado bordero
    --
    --   Alteração : 29/08/2016 - Conversao Progress -> Oracle (Jaison/Daniel)
    -- .........................................................................*/
    
    ---------->>> CURSORES <<<---------- 
    --> Buscar bordero de desconto de cheque
    CURSOR cr_crapbdc IS
      SELECT bdc.insitbdc,
             bdc.cddlinha,
             bdc.dtmvtolt,
             bdc.cdagenci,
             bdc.cdbccxlt,
             bdc.nrdolote,
             bdc.cdoperad,
             bdc.dtlibbdc,
             bdc.cdopelib,
             bdc.nrborder,
             bdc.nrctrlim,
             bdc.txmensal,
             bdc.hrtransa,
             bdc.flgdigit,
             bdc.cdopcolb,
             bdc.cdopcoan
        FROM crapbdc bdc
       WHERE bdc.cdcooper = pr_cdcooper
         AND bdc.nrborder = pr_nrborder;
    rw_crapbdc  cr_crapbdc%ROWTYPE;
    
    --> Buscar Linhas de Desconto
    CURSOR cr_crapldc(pr_cdcooper crapldc.cdcooper%TYPE,
                      pr_cddlinha crapldc.cddlinha%TYPE) IS
      SELECT ldc.cdcooper,
             ldc.txdiaria,
             ldc.txjurmor,
             ldc.dsdlinha
        FROM crapldc ldc
       WHERE ldc.cdcooper = pr_cdcooper
         AND ldc.cddlinha = pr_cddlinha
         AND ldc.tpdescto = 2;
    rw_crapldc cr_crapldc%ROWTYPE;
    
    --> Buscar dados lote
    CURSOR cr_craplot(pr_cdcooper craplot.cdcooper%TYPE,
                      pr_dtmvtolt craplot.dtmvtolt%TYPE,
                      pr_cdagenci craplot.cdagenci%TYPE,
                      pr_cdbccxlt craplot.cdbccxlt%TYPE,
                      pr_nrdolote craplot.nrdolote%TYPE) IS
      SELECT lot.cdcooper,
             lot.qtinfoln,
             lot.vlinfodb,
             lot.vlinfocr,
             lot.qtcompln,
             lot.vlcompdb,
             lot.vlcompcr
        FROM craplot lot
       WHERE lot.cdcooper = pr_cdcooper
         AND lot.dtmvtolt = pr_dtmvtolt
         AND lot.cdagenci = pr_cdagenci
         AND lot.cdbccxlt = pr_cdbccxlt
         AND lot.nrdolote = pr_nrdolote;
    rw_craplot cr_craplot%ROWTYPE;
    
    --> buscar operador
    CURSOR cr_crapope(pr_cdcooper crapope.cdcooper%TYPE,
                      pr_cdoperad crapope.cdoperad%TYPE) IS
      SELECT ope.cdoperad
            ,ope.nmoperad
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND ope.cdoperad = pr_cdoperad;
    rw_crapope cr_crapope%ROWTYPE;
                           
    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    
    vr_idxborde        PLS_INTEGER;
    vr_blnfound        BOOLEAN;
    vr_cdtipdoc        INTEGER;
    vr_cdopecoo        VARCHAR2(100);
    vr_dstextab        craptab.dstextab%TYPE;
    
    
  BEGIN
    -- Limpa a PLTABLE
    pr_tab_dados_border.DELETE;
    
    --> Buscar bordero de desconto de cheque
    OPEN cr_crapbdc;
    FETCH cr_crapbdc INTO rw_crapbdc;
    vr_blnfound := cr_crapbdc%FOUND;
    CLOSE cr_crapbdc;
    -- Se NAO encontrar
    IF NOT vr_blnfound THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Registro de Bordero nao encontrado.';
      RAISE vr_exc_erro;
    END IF;

    IF pr_cddopcao IN ('N','E') THEN
      IF rw_crapbdc.insitbdc > 2 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'O bordero deve estar na situacao EM ESTUDO ou ANALISADO.';
        RAISE vr_exc_erro;
      END IF;
    ELSIF pr_cddopcao = 'L' THEN
      IF rw_crapbdc.insitbdc <> 2 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'O bordero deve estar na situacao ANALISADO.';
        RAISE vr_exc_erro;
      END IF;
    ELSIF pr_cddopcao = 'I' THEN
      IF rw_crapbdc.insitbdc = 1 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'O bordero deve estar na situacao ANALISADO ou LIBERADO.';
        RAISE vr_exc_erro;
      END IF;
    END IF;

    --> Buscar Linhas de Desconto
    OPEN cr_crapldc(pr_cdcooper => pr_cdcooper,
                    pr_cddlinha => rw_crapbdc.cddlinha);
    FETCH cr_crapldc INTO rw_crapldc;
    vr_blnfound := cr_crapldc%FOUND;
    CLOSE cr_crapldc;
    -- Se NAO encontrar
    IF NOT vr_blnfound THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Registro de linha de desconto nao encontrada.';
      RAISE vr_exc_erro;
    END IF;

    --> Documentos computados .........................................
    --> Buscar dados lote
    OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                    pr_dtmvtolt => rw_crapbdc.dtmvtolt,
                    pr_cdagenci => rw_crapbdc.cdagenci,
                    pr_cdbccxlt => rw_crapbdc.cdbccxlt,
                    pr_nrdolote => rw_crapbdc.nrdolote);
    FETCH cr_craplot INTO rw_craplot;
    vr_blnfound := cr_craplot%FOUND;
    CLOSE cr_craplot;
    -- Se NAO encontrar
    IF NOT vr_blnfound THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Registro de Lote nao encontrado.';
      RAISE vr_exc_erro;
    END IF;

    IF pr_cddopcao IN ('L','N') AND
       (rw_craplot.qtinfoln <> rw_craplot.qtcompln   OR
        rw_craplot.vlinfodb <> rw_craplot.vlcompdb   OR
        rw_craplot.vlinfocr <> rw_craplot.vlcompcr)  THEN
      vr_cdcritic := 0;
      vr_dscritic := 'O lote do bordero nao está fechado.';
      RAISE vr_exc_erro;
    END IF;

    vr_idxborde := pr_tab_dados_border.COUNT + 1;

    --> Operadores ...............................................
    --> buscar operador
    OPEN cr_crapope(pr_cdcooper => pr_cdcooper,
                    pr_cdoperad => rw_crapbdc.cdoperad);
    FETCH cr_crapope INTO rw_crapope;
    CLOSE cr_crapope;

    pr_tab_dados_border(vr_idxborde).dsopedig := rw_crapbdc.cdoperad ||'-'||
                                                 NVL(GENE0002.fn_busca_entrada(1,rw_crapope.nmoperad,' '),
                                                     'NAO CADASTRADO');
    IF rw_crapbdc.dtlibbdc IS NOT NULL THEN
      --> buscar operador Que liberou
      OPEN cr_crapope(pr_cdcooper => pr_cdcooper,
                      pr_cdoperad => rw_crapbdc.cdopelib);
      FETCH cr_crapope INTO rw_crapope;
      CLOSE cr_crapope;

      pr_tab_dados_border(vr_idxborde).dsopelib := rw_crapbdc.cdopelib ||'-'||
                                                   NVL(GENE0002.fn_busca_entrada(1,rw_crapope.nmoperad,' '),
                                                       'NAO CADASTRADO');
    END IF;

    vr_dstextab :=  TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper ,
                                               pr_nmsistem => 'CRED'      ,
                                               pr_tptabela => 'GENERI'    ,
                                               pr_cdempres => 00          ,
                                               pr_cdacesso => 'DIGITALIZA',
                                               pr_tpregist => 2);

    IF vr_dstextab IS NULL THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Falta registro na Tabela "DIGITALIZA".';
      RAISE vr_exc_erro;
    END IF;

    vr_cdtipdoc := GENE0002.fn_busca_entrada(pr_postext => 3,
                                             pr_dstext  => vr_dstextab,
                                             pr_delimitador => ';');

    pr_tab_dados_border(vr_idxborde).nrborder := rw_crapbdc.nrborder;
    pr_tab_dados_border(vr_idxborde).nrctrlim := rw_crapbdc.nrctrlim;
    pr_tab_dados_border(vr_idxborde).insitbdc := rw_crapbdc.insitbdc;
    pr_tab_dados_border(vr_idxborde).txmensal := rw_crapbdc.txmensal;
    pr_tab_dados_border(vr_idxborde).dtlibbdc := rw_crapbdc.dtlibbdc;
    pr_tab_dados_border(vr_idxborde).txdiaria := rw_crapldc.txdiaria;
    pr_tab_dados_border(vr_idxborde).txjurmor := rw_crapldc.txjurmor;
    pr_tab_dados_border(vr_idxborde).qtcheque := rw_craplot.qtcompln;
    pr_tab_dados_border(vr_idxborde).vlcheque := rw_craplot.vlcompcr;
    pr_tab_dados_border(vr_idxborde).dspesqui := TO_CHAR(rw_crapbdc.dtmvtolt,'DD/MM/RRRR')   ||'-'||
                                                 TO_CHAR(rw_crapbdc.cdagenci,'fm000')        ||'-'||
                                                 TO_CHAR(rw_crapbdc.cdbccxlt,'fm000')        ||'-'||
                                                 TO_CHAR(rw_crapbdc.nrdolote,'fm000000')     ||'-'||
                                                 TO_CHAR(TO_DATE(rw_crapbdc.hrtransa,'SSSSS'),'HH:MM:SS');
    pr_tab_dados_border(vr_idxborde).dsdlinha := TO_CHAR(rw_crapbdc.cddlinha,'fm000') ||'-'|| rw_crapldc.dsdlinha;
    pr_tab_dados_border(vr_idxborde).flgdigit := rw_crapbdc.flgdigit;
    pr_tab_dados_border(vr_idxborde).cdtipdoc := vr_cdtipdoc;

    -- Verifica se tem operador coordenador de liberacao ou analise
    IF TRIM(rw_crapbdc.cdopcolb) IS NOT NULL THEN
      vr_cdopecoo := rw_crapbdc.cdopcolb;
    ELSE
       IF TRIM(rw_crapbdc.cdopcoan) IS NOT NULL THEN
         vr_cdopecoo := rw_crapbdc.cdopcoan;
       END IF;
    END IF;

    IF TRIM(vr_cdopecoo) IS NOT NULL THEN
      OPEN cr_crapope(pr_cdcooper => pr_cdcooper,
                      pr_cdoperad => vr_cdopecoo);
      FETCH cr_crapope INTO rw_crapope;
      vr_blnfound := cr_crapope%FOUND;
      CLOSE cr_crapope;
      -- Se encontrar
      IF vr_blnfound THEN
        pr_tab_dados_border(vr_idxborde).dsopecoo := vr_cdopecoo || ' - '|| rw_crapope.nmoperad;
      END IF;
    END IF;
     
  EXCEPTION    
    WHEN vr_exc_erro THEN

      IF NVL(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

    WHEN OTHERS THEN      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := REPLACE(REPLACE('Erro pc_busca_dados_bordero: ' || SQLERRM, chr(13)),chr(10));

  END pc_busca_dados_bordero;
  
  --> Buscar cheques de um determinado bordero a partir da crapcdb 
  PROCEDURE pc_busca_cheques_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data atual
                                    ,pr_nrborder IN crapbdc.nrborder%TYPE  --> numero do bordero
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                    --------> OUT <--------                                   
                                    ,pr_tab_chq_bordero     OUT DSCT0002.typ_tab_chq_bordero    --> retorna cheques do bordero
                                    ,pr_tab_bordero_restri  OUT DSCT0002.typ_tab_bordero_restri --> retorna restricoes do cheques do bordero
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    /* .........................................................................
    --
    --  Programa : pc_busca_cheques_bordero           Antigo: b1wgen0009.p/busca_cheques_bordero
    --  Sistema  : CRED
    --  Sigla    : DSCC0001
    --  Autor    : Jaison
    --  Data     : Agosto/2016                        Ultima atualizacao: 30/08/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Buscar cheques de um determinado bordero a partir da crapcdb
    --
    --   Alteração : 30/08/2016 - Conversao Progress -> Oracle (Jaison/Daniel)
    -- .........................................................................*/
    
    ---------->>> CURSORES <<<---------- 

    --> Cheques contidos no bordero 
    CURSOR cr_crapcdb IS
      SELECT /*+ INDEX (cdb crapcdb##crapcdb7) */
             cdb.cdcmpchq,
             cdb.cdbanchq,
             cdb.cdagechq,
             cdb.nrddigc1,
             cdb.nrctachq,
             cdb.nrddigc2,
             cdb.nrcheque,
             cdb.nrddigc3,
             cdb.vlcheque,
             cdb.dtlibera,
             cdb.vlliquid,
             cdb.dtlibbdc,
             cdb.nrcpfcgc
        FROM crapcdb cdb
       WHERE cdb.cdcooper = pr_cdcooper
         AND cdb.nrborder = pr_nrborder
         AND cdb.nrdconta = pr_nrdconta
    ORDER BY cdb.dtlibera,
             cdb.cdbanchq,
             cdb.cdagechq,
             cdb.nrctachq,
             cdb.nrcheque;

    --> Buscar cadastro de emitentes de cheques
    CURSOR cr_crapcec (pr_cdcooper crapcec.cdcooper%TYPE,
                       pr_cdcmpchq crapcec.cdcmpchq%TYPE, 
                       pr_cdbanchq crapcec.cdbanchq%TYPE,
                       pr_cdagechq crapcec.cdagechq%TYPE,
                       pr_nrctachq crapcec.nrctachq%TYPE,
                       pr_nrcpfcgc crapcec.nrcpfcgc%TYPE)IS
      SELECT cec.nrdconta,
             cec.nmcheque,
             cec.nrcpfcgc
        FROM crapcec cec
       WHERE cec.cdcooper = pr_cdcooper
         AND cec.cdcmpchq = pr_cdcmpchq
         AND cec.cdbanchq = pr_cdbanchq
         AND cec.cdagechq = pr_cdagechq
         AND cec.nrctachq = pr_nrctachq
         AND cec.nrcpfcgc = pr_nrcpfcgc;
    rw_crapcec  cr_crapcec%ROWTYPE;

    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    
    vr_idxchequ        PLS_INTEGER;
    vr_blnfound        BOOLEAN;
    vr_rel_dscpfcgc    VARCHAR2(200);
    vr_rel_nmcheque    VARCHAR2(200);
    
  BEGIN
    -- Limpa a PLTABLE
    pr_tab_chq_bordero.DELETE;
    pr_tab_bordero_restri.DELETE;

    --> Cheques contidos no bordero
    FOR rw_crapcdb IN cr_crapcdb LOOP

      -- Buscar cadastro de emitentes de cheques
      OPEN cr_crapcec(pr_cdcooper => pr_cdcooper,
                      pr_cdcmpchq => rw_crapcdb.cdcmpchq,
                      pr_cdbanchq => rw_crapcdb.cdbanchq,
                      pr_cdagechq => rw_crapcdb.cdagechq,
                      pr_nrctachq => rw_crapcdb.nrctachq,
                      pr_nrcpfcgc => rw_crapcdb.nrcpfcgc);
      FETCH cr_crapcec INTO rw_crapcec;
      vr_blnfound := cr_crapcec%FOUND;
      CLOSE cr_crapcec;
      -- Se NAO encontrar
      IF NOT vr_blnfound THEN
        vr_rel_dscpfcgc := 'NAO CADASTRADO';
        vr_rel_nmcheque := 'NAO CADASTRADO';
      ELSE
        vr_rel_dscpfcgc := GENE0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapcec.nrcpfcgc,
                                                     pr_inpessoa => (CASE WHEN rw_crapcec.nrcpfcgc > 11 THEN 2 ELSE 1 END));
        vr_rel_nmcheque := (CASE WHEN NVL(rw_crapcec.nrdconta,0) > 0 THEN '(' || TRIM(GENE0002.fn_mask_conta(rw_crapcec.nrdconta)) || ')' ELSE '' END)
                        || rw_crapcec.nmcheque;
      END IF;

      vr_idxchequ := pr_tab_chq_bordero.COUNT + 1;
      pr_tab_chq_bordero(vr_idxchequ).cdcmpchq := rw_crapcdb.cdcmpchq;
      pr_tab_chq_bordero(vr_idxchequ).cdbanchq := rw_crapcdb.cdbanchq;
      pr_tab_chq_bordero(vr_idxchequ).cdagechq := rw_crapcdb.cdagechq;
      pr_tab_chq_bordero(vr_idxchequ).nrddigc1 := rw_crapcdb.nrddigc1;
      pr_tab_chq_bordero(vr_idxchequ).nrctachq := rw_crapcdb.nrctachq;
      pr_tab_chq_bordero(vr_idxchequ).nrddigc2 := rw_crapcdb.nrddigc2;
      pr_tab_chq_bordero(vr_idxchequ).nrcheque := rw_crapcdb.nrcheque;
      pr_tab_chq_bordero(vr_idxchequ).nrddigc3 := rw_crapcdb.nrddigc3;
      pr_tab_chq_bordero(vr_idxchequ).vlcheque := rw_crapcdb.vlcheque;
      pr_tab_chq_bordero(vr_idxchequ).dscpfcgc := vr_rel_dscpfcgc;
      pr_tab_chq_bordero(vr_idxchequ).dtlibera := rw_crapcdb.dtlibera;
      pr_tab_chq_bordero(vr_idxchequ).nmcheque := vr_rel_nmcheque;
      pr_tab_chq_bordero(vr_idxchequ).vlliquid := rw_crapcdb.vlliquid;
      pr_tab_chq_bordero(vr_idxchequ).dtlibbdc := rw_crapcdb.dtlibbdc;
      pr_tab_chq_bordero(vr_idxchequ).dtmvtolt := pr_dtmvtolt;

      -->  Buscar restricoes de um determinado bordero ou cheque  
      pc_busca_restricoes(pr_cdcooper => pr_cdcooper          --> Código da Cooperativa
                         ,pr_nrborder => pr_nrborder          --> numero do bordero
                         ,pr_cdcmpchq => rw_crapcdb.cdcmpchq  --> Codigo da compensacao impressa no cheque acolhido
                         ,pr_cdbanchq => rw_crapcdb.cdbanchq  --> Codigo do banco impresso no cheque acolhido
                         ,pr_cdagechq => rw_crapcdb.cdagechq  --> Codigo da agencia impressa no cheque acolhido
                         ,pr_nrctachq => rw_crapcdb.nrctachq  --> Numero da conta do cheque acolhido
                         ,pr_nrcheque => rw_crapcdb.nrcheque  --> Numero do cheque capturado
                         ,pr_tprestri => 1                    --> Tipo de restricao
                         --------> OUT <--------                                   
                         ,pr_tab_bordero_restri => pr_tab_bordero_restri --> retorna restricoes do cheques do bordero
                         ,pr_cdcritic           => vr_cdcritic           --> Código da crítica
                         ,pr_dscritic           => vr_dscritic);         --> Descrição da crítica
      IF nvl(vr_cdcritic,0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN 
        RAISE vr_exc_erro; 
      END IF;

    END LOOP;

    -- Restricoes GERAIS
    pc_busca_restricoes(pr_cdcooper => pr_cdcooper  --> Código da Cooperativa
                       ,pr_nrborder => pr_nrborder  --> numero do bordero
                       ,pr_cdcmpchq => 888          --> Codigo da compensacao impressa no cheque acolhido
                       ,pr_cdbanchq => 888          --> Codigo do banco impresso no cheque acolhido
                       ,pr_cdagechq => 8888         --> Codigo da agencia impressa no cheque acolhido
                       ,pr_nrctachq => 8888888888   --> Numero da conta do cheque acolhido
                       ,pr_nrcheque => 888888       --> Numero do cheque capturado
                       ,pr_tprestri => 2            --> Tipo de restricao
                       --------> OUT <--------                                   
                       ,pr_tab_bordero_restri => pr_tab_bordero_restri --> retorna restricoes do cheques do bordero
                       ,pr_cdcritic           => vr_cdcritic           --> Código da crítica
                       ,pr_dscritic           => vr_dscritic);         --> Descrição da crítica
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN 
      RAISE vr_exc_erro; 
    END IF;

  EXCEPTION    
    WHEN vr_exc_erro THEN

      IF nvl(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := REPLACE(REPLACE('Erro pc_busca_cheques_bordero: ' || SQLERRM, chr(13)),chr(10));

  END pc_busca_cheques_bordero;
  
  --> Carrega dados com os cheques do bordero
  PROCEDURE pc_carrega_dados_bordero_chq(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                        ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                        ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Numero do contrato de limite
                                        ,pr_nrborder IN crapbdc.nrborder%TYPE  --> Numero do bordero
                                        ,pr_txdiaria IN NUMBER                 --> Taxa diaria
                                        ,pr_txmensal IN NUMBER                 --> Taxa mensa
                                        ,pr_txdanual IN NUMBER                 --> Taxa anual
                                        ,pr_vllimite IN craplim.vllimite%TYPE  --> Valor limite de desconto
                                        ,pr_ddmvtolt IN INTEGER                --> Dia movimento
                                        ,pr_dsmesref IN VARCHAR2               --> Descricao do mes
                                        ,pr_aamvtolt INTEGER                   --> Ano de movimento
                                        ,pr_nmprimtl IN crapass.nmprimtl%TYPE  --> Nome do cooperado
                                        ,pr_nmrescop IN crapcop.nmrescop%TYPE  --> Nome resumido da cooperativa
                                        ,pr_nmextcop IN crapcop.nmextcop%TYPE  --> Nome completo da cooperativa
                                        ,pr_nmcidade IN crapcop.nmcidade%TYPE  --> Nome da cidade
                                        ,pr_nmoperad IN crapope.nmoperad%TYPE  --> Nome do operador
                                        ,pr_dsopecoo IN VARCHAR2               --> Descricao operador coordenador
                                        --------> OUT <--------                                   
                                        ,pr_tab_dados_itens_bordero OUT DSCT0002.typ_tab_dados_itens_bordero --> retorna dados do bordero
                                        ,pr_tab_chq_bordero         OUT DSCT0002.typ_tab_chq_bordero         --> retorna cheques do bordero
                                        ,pr_tab_bordero_restri      OUT DSCT0002.typ_tab_bordero_restri      --> retorna restricoes do cheques do bordero
                                        ,pr_cdcritic                OUT PLS_INTEGER  --> Código da crítica
                                        ,pr_dscritic                OUT VARCHAR2) IS --> Descrição da crítica
    /* .........................................................................
    --
    --  Programa : pc_carrega_dados_bordero_chq       Antigo: b1wgen0009.p/carrega_dados_bordero_cheques
    --  Sistema  : CRED
    --  Sigla    : DSCC0001
    --  Autor    : Jaison
    --  Data     : Agosto/2016                        Ultima atualizacao: 31/08/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Carrega dados com os cheques do bordero
    --
    --   Alteração : 31/08/2016 - Conversao Progress -> Oracle (Jaison/Daniel)
    -- .........................................................................*/
    
    ---------->>> CURSORES <<<----------
    
    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    
    vr_idxchqbo        PLS_INTEGER;
    
  BEGIN
    -- Limpa a PLTABLE
    pr_tab_dados_itens_bordero.DELETE;
    pr_tab_chq_bordero.DELETE;
    pr_tab_bordero_restri.DELETE;

    --> Buscar cheques de um determinado bordero a partir da crapcdb
    pc_busca_cheques_bordero(pr_cdcooper => pr_cdcooper  --> Código da Cooperativa
                            ,pr_dtmvtolt => pr_dtmvtolt  --> Data atual
                            ,pr_nrborder => pr_nrborder  --> numero do bordero
                            ,pr_nrdconta => pr_nrdconta  --> Número da Conta
                            --------> OUT <--------                                   
                            ,pr_tab_chq_bordero    => pr_tab_chq_bordero    --> retorna titulos do bordero
                            ,pr_tab_bordero_restri => pr_tab_bordero_restri --> retorna restrições do cheques do bordero
                            ,pr_cdcritic           => vr_cdcritic           --> Código da crítica
                            ,pr_dscritic           => vr_dscritic);         --> Descrição da crítica

    IF nvl(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    vr_idxchqbo := pr_tab_dados_itens_bordero.COUNT + 1;
    pr_tab_dados_itens_bordero(vr_idxchqbo).nrdconta := pr_nrdconta;
    pr_tab_dados_itens_bordero(vr_idxchqbo).cdagenci := pr_cdagenci;
    pr_tab_dados_itens_bordero(vr_idxchqbo).nrctrlim := pr_nrctrlim;
    pr_tab_dados_itens_bordero(vr_idxchqbo).nrborder := pr_nrborder;
    pr_tab_dados_itens_bordero(vr_idxchqbo).txdiaria := pr_txdiaria;
    pr_tab_dados_itens_bordero(vr_idxchqbo).txmensal := pr_txmensal;
    pr_tab_dados_itens_bordero(vr_idxchqbo).txdanual := pr_txdanual;
    pr_tab_dados_itens_bordero(vr_idxchqbo).vllimite := pr_vllimite;
    pr_tab_dados_itens_bordero(vr_idxchqbo).ddmvtolt := pr_ddmvtolt;
    pr_tab_dados_itens_bordero(vr_idxchqbo).dsmesref := pr_dsmesref;
    pr_tab_dados_itens_bordero(vr_idxchqbo).aamvtolt := pr_aamvtolt;
    pr_tab_dados_itens_bordero(vr_idxchqbo).nmprimtl := pr_nmprimtl;
    pr_tab_dados_itens_bordero(vr_idxchqbo).nmrescop := pr_nmrescop;
    pr_tab_dados_itens_bordero(vr_idxchqbo).nmextcop := pr_nmextcop;
    pr_tab_dados_itens_bordero(vr_idxchqbo).nmcidade := pr_nmcidade;
    pr_tab_dados_itens_bordero(vr_idxchqbo).nmoperad := pr_nmoperad;
    pr_tab_dados_itens_bordero(vr_idxchqbo).dsopecoo := pr_dsopecoo;

  EXCEPTION
    WHEN vr_exc_erro THEN

      IF nvl(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro pc_busca_titulos_bordero: ' || SQLERRM, chr(13)),chr(10));

  END pc_carrega_dados_bordero_chq;

  --> Carregar dados para efetuar a impressao da nota promissoria
  PROCEDURE pc_dados_nota_promissoria(pr_cdcooper IN crapcop.cdcooper%TYPE    --> Código da Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE    --> Código da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE    --> Numero do caixa do operador
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE    --> Código do Operador
                                     ,pr_inpessoa IN crapass.inpessoa%TYPE    --> Tipo de pessoa
                                     ,pr_nrcpfcgc IN VARCHAR2                 --> Numero CPF/CNPJ
                                     ,pr_nrctrlim IN INTEGER                  --> Numero do contrato
                                     ,pr_vllimite IN NUMBER                   --> Valor do limite
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE    --> Data do movimento
                                     ,pr_dsemsnot IN VARCHAR2                 --> Descricao nota
                                     ,pr_dsmesref IN VARCHAR2                 --> Mes de referencia
                                     ,pr_nmrescop IN crapcop.nmrescop%TYPE    --> Nome resumido da cooperativa
                                     ,pr_nmextcop IN crapcop.nmextcop%TYPE    --> Nome extenso da cooperativa
                                     ,pr_nrdocnpj IN crapcop.nrdocnpj%TYPE    --> Numero do CNPJ
                                     ,pr_dsdmoeda IN VARCHAR2                 --> Descricao da moeda
                                     ,pr_nmprimtl IN crapass.nmprimtl%TYPE    --> Nome do cooperado
                                      --------> OUT <--------
                                     ,pr_tab_dados_nota_pro  OUT DSCT0002.typ_tab_dados_nota_pro  --> Tabela contendo dados nota promissoria
                                     ,pr_cdcritic            OUT PLS_INTEGER  --> Codigo da critica
                                     ,pr_dscritic            OUT VARCHAR2) IS --> Descricao da critica
    /* .........................................................................
    --
    --  Programa : pc_dados_nota_promissoria            Antigo: b1wgen0009.p/carrega_dados_nota_promissoria
    --  Sistema  : CRED
    --  Sigla    : DSCC0001
    --  Autor    : Jaison
    --  Data     : Agosto/2016                          Ultima atualizacao: 22/08/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para carregar dados para efetuar a impressao da nota promissoria
    --
    --   Alteração : 22/08/2016 - Conversao Progress -> Oracle (Jaison/Daniel)
    -- .........................................................................*/
    
    ---------->> CURSORES <<--------
    -- Buscar Dados agencia
    CURSOR cr_crapage(pr_cdcooper crapage.cdcooper%TYPE,
                      pr_cdagenci crapage.cdagenci%TYPE) IS
      SELECT age.nmcidade
        FROM crapage age
       WHERE age.cdcooper = pr_cdcooper
         AND age.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%ROWTYPE;
        
    -- Buscar endereco
    CURSOR cr_crapenc(pr_cdcooper crapenc.cdcooper%TYPE,
                      pr_nrdconta crapenc.nrdconta%TYPE ) IS
      SELECT enc.dsendere,
             enc.nrendere,
             enc.nmbairro,
             enc.nrcepend,
             enc.nmcidade,
             enc.cdufende
        FROM crapenc enc
       WHERE enc.cdcooper = pr_cdcooper
         AND enc.nrdconta = pr_nrdconta
         AND enc.idseqttl = 1
         AND enc.cdseqinc = 1;
    rw_crapenc cr_crapenc%ROWTYPE;

    --------->> VARIAVEIS <<--------
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro        
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;    

    vr_blnfound        BOOLEAN;
    vr_idxnotap        PLS_INTEGER;
    vr_rel_ddmvtolt    INTEGER;
    vr_rel_aamvtolt    INTEGER;
    vr_rel_dsmvtolt    VARCHAR2(200);
    vr_rel_dspreemp    VARCHAR2(200);
    vr_rel_nmcidpac    VARCHAR2(100);

  BEGIN
    -- Limpa a PLTABLE
    pr_tab_dados_nota_pro.DELETE;

    vr_rel_ddmvtolt := TO_CHAR(pr_dtmvtolt,'DD');
    vr_rel_aamvtolt := TO_CHAR(pr_dtmvtolt,'RRRR');

    IF vr_rel_ddmvtolt > 1  THEN
      vr_rel_dsmvtolt := GENE0002.fn_valor_extenso(pr_idtipval => 'I',
                                                   pr_valor    => vr_rel_ddmvtolt)
                      || ' DIAS DO MÊS DE ';
    ELSE
      vr_rel_dsmvtolt := 'PRIMEIRO DIA DO MÊS DE ';
    END IF;
    vr_rel_dsmvtolt := vr_rel_dsmvtolt
                    || GENE0001.vr_vet_nmmesano(TO_CHAR(pr_dtmvtolt,'MM'))
                    || ' DE '
                    || GENE0002.fn_valor_extenso(pr_idtipval => 'I',
                                                 pr_valor    => vr_rel_aamvtolt);

    vr_rel_dspreemp := '('
                    || GENE0002.fn_valor_extenso(pr_idtipval => 'M',
                                                 pr_valor    => TO_CHAR(pr_vllimite))
	                  || ')';

    -- Buscar Dados agencia
    OPEN cr_crapage(pr_cdcooper => pr_cdcooper ,
                    pr_cdagenci => pr_cdagenci);
    FETCH cr_crapage INTO rw_crapage;
    vr_blnfound := cr_crapage%FOUND;
    CLOSE cr_crapage;
    -- Se NAO encontrar
    IF NOT vr_blnfound THEN
      vr_rel_nmcidpac := 'Pagável em ____________________';
    ELSE
      vr_rel_nmcidpac := 'Pagável em ' || rw_crapage.nmcidade;
    END IF;

    -- Buscar endereco
    OPEN cr_crapenc(pr_cdcooper => pr_cdcooper ,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapenc INTO rw_crapenc;
    CLOSE cr_crapenc;

    vr_idxnotap := pr_tab_dados_nota_pro.COUNT() + 1;
    pr_tab_dados_nota_pro(vr_idxnotap).ddmvtolt := vr_rel_ddmvtolt;
    pr_tab_dados_nota_pro(vr_idxnotap).aamvtolt := vr_rel_aamvtolt;
    pr_tab_dados_nota_pro(vr_idxnotap).vlpreemp := pr_vllimite;
    pr_tab_dados_nota_pro(vr_idxnotap).dsctremp := TO_CHAR(GENE0002.fn_mask(pr_nrctrlim,'z.zzz.zz9')) 
                                                || '/001';
    pr_tab_dados_nota_pro(vr_idxnotap).dscpfcgc := (CASE WHEN pr_inpessoa = 1 THEN 'C.P.F. ' ELSE 'CNPJ ' END)
                                                || pr_nrcpfcgc;
    pr_tab_dados_nota_pro(vr_idxnotap).dsmesref := pr_dsmesref;
    pr_tab_dados_nota_pro(vr_idxnotap).dsemsnot := pr_dsemsnot;
    pr_tab_dados_nota_pro(vr_idxnotap).dtvencto := pr_dtmvtolt;
    pr_tab_dados_nota_pro(vr_idxnotap).dsmvtolt := UPPER(vr_rel_dsmvtolt);
    pr_tab_dados_nota_pro(vr_idxnotap).dspreemp := UPPER(vr_rel_dspreemp);
    pr_tab_dados_nota_pro(vr_idxnotap).nmrescop := pr_nmrescop;
    pr_tab_dados_nota_pro(vr_idxnotap).nmextcop := pr_nmextcop;
    pr_tab_dados_nota_pro(vr_idxnotap).nrdocnpj := GENE0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => pr_nrdocnpj,
                                                                             pr_inpessoa => 2);
    pr_tab_dados_nota_pro(vr_idxnotap).dsdmoeda := pr_dsdmoeda;
    pr_tab_dados_nota_pro(vr_idxnotap).nmprimtl := pr_nmprimtl;
    pr_tab_dados_nota_pro(vr_idxnotap).nrdconta := pr_nrdconta;
    pr_tab_dados_nota_pro(vr_idxnotap).nmcidpac := vr_rel_nmcidpac;
    pr_tab_dados_nota_pro(vr_idxnotap).dsendass := rw_crapenc.dsendere
                                                || ' '    || GENE0002.fn_mask(rw_crapenc.nrendere,'zzz.zzz')
                                                || '<br>' || rw_crapenc.nmbairro
                                                || '<br>' || GENE0002.fn_mask(rw_crapenc.nrcepend,'99999.999')
                                                || ' - '  || rw_crapenc.nmcidade
                                                || '/'    || rw_crapenc.cdufende;

  EXCEPTION
    WHEN vr_exc_erro THEN

      IF NVL(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := REPLACE(REPLACE(vr_dscritic,chr(13)),chr(10));
      END IF;

    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := REPLACE(REPLACE('Nao foi possivel buscar dados da nota promissoria: ' || SQLERRM, chr(13)),chr(10));

  END pc_dados_nota_promissoria;
  
  --> Procedure para gerar impressoes do bordero
  PROCEDURE pc_gera_impressao_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_cdagecxa IN crapage.cdagenci%TYPE  --> Código da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdopecxa IN crapope.cdoperad%TYPE  --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE  --> Data do proximo Movimento
                                     ,pr_inproces IN crapdat.inproces%TYPE  --> Indicador do processo 
                                     ,pr_idimpres IN INTEGER                --> Indicador de impressao
                                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                     ,pr_nrborder IN crapbdc.nrborder%TYPE  --> Numero do bordero
                                     ,pr_dsiduser IN VARCHAR2               --> Descricao do id do usuario
                                     ,pr_flgemail IN INTEGER                --> Indicador de envia por email (0-nao, 1-sim)
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     --------> OUT <--------                                   
                                     ,pr_nmarqpdf OUT VARCHAR2              --> Retornar nome do relatorio PDF
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    /* .........................................................................
    --
    --  Programa : pc_gera_impressao_bordero           Antigo: imprimir_pdf_dscchq.php
    --  Sistema  : CRED
    --  Sigla    : DSCC0001
    --  Autor    : Jaison
    --  Data     : Setembro/2016                       Ultima atualizacao: 06/09/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para gerar impressoes do bordero
    --
    --   Alteração : 06/09/2016 - Conversao Progress -> Oracle (Jaison/Daniel)
    -- .........................................................................*/

    ----------->>> CURSORES  <<<--------
    --> Buscar dados do bordero
    CURSOR cr_crapbdc IS
      SELECT *
        FROM crapbdc
       WHERE crapbdc.cdcooper = pr_cdcooper
         AND crapbdc.nrdconta = pr_nrdconta
         AND crapbdc.nrborder = pr_nrborder;
         
    rw_crapbdc cr_crapbdc%ROWTYPE;

    ----------->>> TEMPTABLE <<<--------
    vr_tab_dados_avais         DSCT0002.typ_tab_dados_avais;
    vr_tab_tit_bordero         DSCT0002.typ_tab_tit_bordero;
    vr_tab_chq_bordero         DSCT0002.typ_tab_chq_bordero;  
    vr_tab_bordero_restri      DSCT0002.typ_tab_bordero_restri;
    vr_tab_dados_itens_bordero DSCT0002.typ_tab_dados_itens_bordero;
    vr_tab_sacado_nao_pagou    DSCT0002.typ_tab_sacado_nao_pagou;
    vr_tab_contrato_limite     DSCT0002.typ_tab_contrato_limite;  
    vr_tab_dados_nota_pro      DSCT0002.typ_tab_dados_nota_pro;
    vr_tab_restri_apr_coo      DSCT0002.typ_tab_restri_apr_coo;

    vr_idxborde                PLS_INTEGER;

    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro
    vr_des_reto        VARCHAR2(100);
    vr_tab_erro        GENE0001.typ_tab_erro;
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;

    vr_dsorigem        craplgm.dsorigem%TYPE;
    vr_dstransa        craplgm.dstransa%TYPE;
    vr_nrdrowid        ROWID;

    vr_nmarquiv        Varchar2(200);
    vr_dsdireto        Varchar2(200);
    vr_dscomand        VARCHAR2(4000);
    vr_typsaida        VARCHAR2(100); 

    vr_cdtipdoc        INTEGER;
    vr_cdageqrc        INTEGER;
    vr_dstextab        craptab.dstextab%TYPE;

    vr_qrcode          VARCHAR2(100);
    vr_dstitulo        VARCHAR2(300);
    vr_dsmvtolt        VARCHAR2(300);
    vr_idxrestr        VARCHAR2(100);
    vr_qttotchq        INTEGER;
    vr_vltotchq        NUMBER;
    vr_vltotliq        NUMBER;
    vr_qtrestri        INTEGER;
    vr_vlmedchq        NUMBER;
    vr_qtdiaprz        INTEGER;

    -- Variáveis para armazenar as informações em XML
    vr_des_xml   CLOB;
    vr_txtcompl  VARCHAR2(32600);
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;

  BEGIN
    -- Limpa PLTABLE
    vr_tab_restri_apr_coo.DELETE;

    --> Definir transação
    IF pr_flgerlog = 1 THEN
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa := 'Gerar impressao de bordero de cheque';
    END IF;

    -- Busca dos dados do bordero
    OPEN cr_crapbdc;
    FETCH cr_crapbdc INTO rw_crapbdc;
    
    -- Se NAO encontrar
    IF cr_crapbdc%NOTFOUND THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Nao foi possivel encontrar Bordero.';
      CLOSE cr_crapbdc;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapbdc;

    --> Buscar dados para montar contratos etc para desconto de cheques
    DSCT0002.pc_busca_dados_imp_descont
            (pr_cdcooper => pr_cdcooper  --> Código da Cooperativa
            ,pr_cdagenci => pr_cdagecxa  --> Código da agencia
            ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa do operador
            ,pr_cdoperad => pr_cdopecxa  --> Código do Operador
            ,pr_nmdatela => pr_nmdatela  --> Nome da Tela
            ,pr_idorigem => pr_idorigem  --> Identificador de Origem
            ,pr_tpctrlim => 2            --> Tipo de contrato de limite(2-Cheque e 3-Titulo)
            ,pr_nrdconta => pr_nrdconta  --> Número da Conta
            ,pr_idseqttl => pr_idseqttl  --> Titular da Conta
            ,pr_dtmvtolt => pr_dtmvtolt  --> Data de Movimento
            ,pr_dtmvtopr => pr_dtmvtopr  --> Data do proximo Movimento
            ,pr_inproces => pr_inproces  --> Indicador do processo 
            ,pr_idimpres => pr_idimpres  --> Indicador de impresao
            ,pr_nrctrlim => pr_nrctrlim  --> Contrato
            ,pr_nrborder => pr_nrborder  --> Numero do bordero
            ,pr_flgerlog => 0            --> Indicador se deve gerar log(0-nao, 1-sim)
            ,pr_limorbor => 2            --> Indicador do tipo de dado( 1 - LIMITE DSCCHQ 2 - BORDERO DSCCHQ )                                     
            --------> OUT <--------         
            --> Tabelas nao serao retornadar pois nao foram convetidas parao projeto indexacao(qrcode)                          
            --> pr_tab_emprsts             
            --> pr_tab_proposta_limite    
            --> pr_tab_proposta_bordero     
            ,pr_tab_contrato_limite     => vr_tab_contrato_limite   
            ,pr_tab_dados_avais         => vr_tab_dados_avais       
            ,pr_tab_dados_nota_pro      => vr_tab_dados_nota_pro                          
            ,pr_tab_dados_itens_bordero => vr_tab_dados_itens_bordero
            ,pr_tab_tit_bordero         => vr_tab_tit_bordero     
            ,pr_tab_chq_bordero         => vr_tab_chq_bordero  
            ,pr_tab_bordero_restri      => vr_tab_bordero_restri
            ,pr_tab_sacado_nao_pagou    => vr_tab_sacado_nao_pagou  
            ,pr_cdcritic                => vr_cdcritic              
            ,pr_dscritic                => vr_dscritic);

    IF nvl(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Buscar diretorio da cooperativa
    vr_dsdireto := GENE0001.fn_diretorio( pr_tpdireto => 'C' --> cooper 
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => '/rl');

    vr_nmarquiv := 'crrl519_bordero_'||pr_dsiduser;

    --> Remover arquivo existente   
    vr_dscomand := 'rm '||vr_dsdireto||'/'||vr_nmarquiv||'* 2>/dev/null';

    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomand
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_typsaida = 'ERR' THEN
      vr_dscritic:= 'Nao foi possivel remover arquivos: '||vr_dscomand||'. Erro: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF; 

    --> Montar nome do arquivo
    pr_nmarqpdf := vr_nmarquiv || gene0002.fn_busca_time || '.pdf';

    --> Buscar identificador para digitalização
    vr_dstextab :=  TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper, 
                                               pr_nmsistem => 'CRED'      , 
                                               pr_tptabela => 'GENERI'    , 
                                               pr_cdempres => 00          , 
                                               pr_cdacesso => 'DIGITALIZA', 
                                               pr_tpregist => 2);

    IF TRIM(vr_dstextab) IS NULL THEN
      vr_dscritic := 'Falta registro na Tabela "DIGITALIZA".';
      RAISE vr_exc_erro;
    END IF;

    vr_cdtipdoc :=  gene0002.fn_busca_entrada(pr_postext => 3, 
                                              pr_dstext  => vr_dstextab, 
                                              pr_delimitador => ';');

    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    
    --> Bordero cheques
    IF pr_idimpres = 7 THEN
      --Buscar indice do primeiro registro
      vr_idxborde := vr_tab_dados_itens_bordero.FIRST;
      IF vr_idxborde IS NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Nao foi possivel gerar a impressao.';
        RAISE vr_exc_erro;
      END IF;

      vr_dstitulo := 'BORDERÔ DE DESCONTO DE CHEQUES E TERMO DE CUSTÓDIA';
      vr_dsmvtolt := vr_tab_dados_itens_bordero(vr_idxborde).nmcidade ||', '|| GENE0005.fn_data_extenso(pr_dtmvtolt);
      
      --Incluir no QRcode a agencia onde foi criado o contrato.
      IF nvl(rw_crapbdc.cdageori,0) = 0 THEN
        vr_cdageqrc := vr_tab_dados_itens_bordero(vr_idxborde).cdagenci;
      ELSE
        vr_cdageqrc := rw_crapbdc.cdageori;
      END IF;
      
      vr_qrcode   := pr_cdcooper ||'_'||
                     vr_cdageqrc ||'_'||
                     TRIM(gene0002.fn_mask_conta(   pr_nrdconta)) ||'_'||
                     TRIM(gene0002.fn_mask_contrato(pr_nrborder)) ||'_'||
                     0           ||'_'||
                     0           ||'_'||
                     vr_cdtipdoc;

      --> INICIO
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');

      pc_escreve_xml('<Bordero>'||
                         '<tpctrlim>2</tpctrlim>'||
                         '<nmextcop>'|| vr_tab_dados_itens_bordero(vr_idxborde).nmextcop ||'</nmextcop>'||
                         '<dstitulo>'|| vr_dstitulo ||'</dstitulo>'||
                         '<dsqrcode>'|| vr_qrcode ||'</dsqrcode>'||
                         '<nrdconta>'|| TRIM(GENE0002.fn_mask_conta(pr_nrdconta)) ||'</nrdconta>'||
                         '<nmprimtl>'|| vr_tab_dados_itens_bordero(vr_idxborde).nmprimtl ||'</nmprimtl>'||
                         '<cdagenci>'|| vr_tab_dados_itens_bordero(vr_idxborde).cdagenci ||'</cdagenci>'||
                         '<nrborder>'|| TRIM(GENE0002.fn_mask_contrato(pr_nrborder)) ||'</nrborder>'||
                         '<nrctrlim>'|| TRIM(GENE0002.fn_mask_contrato(pr_nrctrlim)) ||'</nrctrlim>'||
                         '<vllimite>'|| TO_CHAR(vr_tab_dados_itens_bordero(vr_idxborde).vllimite,'fm999G999G999G990D00') ||'</vllimite>'||
                         '<txdanual>'|| TO_CHAR(vr_tab_dados_itens_bordero(vr_idxborde).txdanual,'fm9999g999g990d000000') ||'</txdanual>'||
                         '<txmensal>'|| TO_CHAR(vr_tab_dados_itens_bordero(vr_idxborde).txmensal,'fm9999g999g990d000000') ||'</txmensal>'||
                         '<txdiaria>'|| TO_CHAR(vr_tab_dados_itens_bordero(vr_idxborde).txdiaria,'fm9999g999g990d000000') ||'</txdiaria>'||
                         '<dsmvtolt>'|| vr_dsmvtolt ||'</dsmvtolt>'||  
                         '<nmoperad>'|| vr_tab_dados_itens_bordero(vr_idxborde).nmoperad ||'</nmoperad>'||
                         '<dsopecoo>'|| vr_tab_dados_itens_bordero(vr_idxborde).dsopecoo ||'</dsopecoo>'||
                         '<cheques>');

      FOR idx IN vr_tab_chq_bordero.FIRST..vr_tab_chq_bordero.LAST LOOP
        -- Seta os totais
        vr_qttotchq := NVL(vr_qttotchq,0) + 1;
        vr_vltotchq := NVL(vr_vltotchq,0) + vr_tab_chq_bordero(idx).vlcheque;
        vr_vltotliq := NVL(vr_vltotliq,0) + vr_tab_chq_bordero(idx).vlliquid;

        IF vr_tab_chq_bordero(idx).dtlibbdc IS NOT NULL THEN
          vr_qtdiaprz := vr_tab_chq_bordero(idx).dtlibera - vr_tab_chq_bordero(idx).dtlibbdc;
        ELSE
          vr_qtdiaprz := vr_tab_chq_bordero(idx).dtlibera - vr_tab_chq_bordero(idx).dtmvtolt;
        END IF;

        pc_escreve_xml(      '<cheque>'||
                                 '<dtlibera>'|| TO_CHAR(vr_tab_chq_bordero(idx).dtlibera,'dd/mm/rrrr') ||'</dtlibera>'||
                                 '<cdcmpchq>'|| GENE0002.fn_mask(vr_tab_chq_bordero(idx).cdcmpchq,'999') ||'</cdcmpchq>'||
                                 '<cdbanchq>'|| GENE0002.fn_mask(vr_tab_chq_bordero(idx).cdbanchq,'999') ||'</cdbanchq>'||
                                 '<cdagechq>'|| GENE0002.fn_mask(vr_tab_chq_bordero(idx).cdagechq,'9999') ||'</cdagechq>'||
                                 '<nrctachq>'|| TRIM(GENE0002.fn_mask(vr_tab_chq_bordero(idx).nrctachq,'zzzzzzz.zzz.9')) ||'</nrctachq>'||
                                 '<nrcheque>'|| TRIM(GENE0002.fn_mask(vr_tab_chq_bordero(idx).nrcheque,'zzz.zz9')) ||'</nrcheque>'||
                                 '<vlcheque>'|| TO_CHAR(vr_tab_chq_bordero(idx).vlcheque,'fm999G999G999G990D00') ||'</vlcheque>'||
                                 '<vlliquid>'|| TO_CHAR(vr_tab_chq_bordero(idx).vlliquid,'fm999G999G999G990D00') ||'</vlliquid>'||
                                 '<qtdiaprz>'|| vr_qtdiaprz ||'</qtdiaprz>'||
                                 '<nmcheque>'|| SUBSTR(vr_tab_chq_bordero(idx).nmcheque,0,23) ||'</nmcheque>'||
                                 '<dscpfcgc>'|| vr_tab_chq_bordero(idx).dscpfcgc ||'</dscpfcgc>'||
                                 '<restricoes>');

        -- Percorre as restricoes
        IF vr_tab_bordero_restri.COUNT > 0 THEN
          FOR idx2 IN vr_tab_bordero_restri.FIRST..vr_tab_bordero_restri.LAST LOOP
            -- Se for restricao do cheque em questao
            IF vr_tab_bordero_restri(idx2).nrcheque = vr_tab_chq_bordero(idx).nrcheque THEN
              -- Seta o total
              vr_qtrestri := NVL(vr_qtrestri, 0) + 1;

              pc_escreve_xml(          '<restricao><texto>'|| vr_tab_bordero_restri(idx2).dsrestri ||'</texto></restricao>');
              -- Se foi aprovado pelo coordenador
              IF vr_tab_bordero_restri(idx2).flaprcoo = 1 THEN
                -- Se NAO existir na PLTABLE
                IF NOT vr_tab_restri_apr_coo.EXISTS(vr_tab_bordero_restri(idx2).dsrestri) THEN
                  vr_tab_restri_apr_coo(vr_tab_bordero_restri(idx2).dsrestri) := '';
                END IF;
              END IF;
            END IF;
          END LOOP;
        END IF;

        pc_escreve_xml(          '</restricoes>'||
                             '</cheque>');
      END LOOP;

      -- Calcula a media
      vr_vlmedchq := APLI0001.fn_round(vr_vltotchq / vr_qttotchq, 2);

      pc_escreve_xml(    '</cheques>'||
                         '<totais>'||
                             '<total>'||
                             	   '<qttotchq>'|| vr_qttotchq ||'</qttotchq>'||
                                 '<qtrestri>'|| NVL(vr_qtrestri, 0) ||'</qtrestri>'||
                                 '<vltotchq>'|| TO_CHAR(vr_vltotchq,'fm999G999G999G990D00') ||'</vltotchq>'||
                                 '<vltotliq>'|| TO_CHAR(vr_vltotliq,'fm999G999G999G990D00') ||'</vltotliq>'||
                                 '<vlmedchq>'|| TO_CHAR(vr_vlmedchq,'fm999G999G999G990D00') ||'</vlmedchq>'||
                             '</total>'||
                         '</totais>');

      -- Se possui restricoes aprovadas pelo coordenador
      IF vr_tab_restri_apr_coo.COUNT > 0 THEN
         pc_escreve_xml(  '<restricoes_coord dsopecoo="'|| TRIM(vr_tab_dados_itens_bordero(vr_idxborde).dsopecoo) ||'">');
        vr_idxrestr := vr_tab_restri_apr_coo.FIRST;
        WHILE vr_idxrestr IS NOT NULL LOOP
          pc_escreve_xml(    '<restricao><texto>'|| vr_idxrestr ||'</texto></restricao>');
          vr_idxrestr := vr_tab_restri_apr_coo.NEXT(vr_idxrestr);
        END LOOP;
        pc_escreve_xml(  '</restricoes_coord>');
      END IF;
      
      pc_escreve_xml(  '<restricoes_gerais>');
      -- Percorre as restricoes gerais
      IF vr_tab_bordero_restri.COUNT > 0 THEN
        FOR idx2 IN vr_tab_bordero_restri.FIRST..vr_tab_bordero_restri.LAST LOOP
          IF vr_tab_bordero_restri(idx2).nrcheque = 888888 THEN
            pc_escreve_xml(          '<restricao><texto>'|| vr_tab_bordero_restri(idx2).dsrestri ||'</texto></restricao>');
          END IF;
        END LOOP;
      END IF;
      pc_escreve_xml(  '</restricoes_gerais>');

      pc_escreve_xml( '</Bordero></raiz>',TRUE);

      --> Solicita geracao do PDF
      GENE0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                                 , pr_cdprogra  => 'ATENDA'
                                 , pr_dtmvtolt  => pr_dtmvtolt
                                 , pr_dsxml     => vr_des_xml
                                 , pr_dsxmlnode => '/raiz/Bordero'
                                 , pr_dsjasper  => 'crrl519_bordero.jasper'
                                 , pr_dsparams  => null
                                 , pr_dsarqsaid => vr_dsdireto||'/'||pr_nmarqpdf
                                 , pr_cdrelato => 519
                                 , pr_flg_gerar => 'S'
                                 , pr_qtcoluna  => 132
                                 , pr_sqcabrel  => 1
                                 , pr_flg_impri => 'N'
                                 , pr_nmformul  => ' '
                                 , pr_nrcopias  => 1
                                 , pr_nrvergrl  => 1
                                 , pr_des_erro  => vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
        RAISE vr_exc_erro; -- encerra programa
      END IF;

      IF pr_idorigem = 5 THEN

        -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
        GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => NULL
                                    ,pr_nrdcaixa => NULL
                                    ,pr_nmarqpdf => vr_dsdireto ||'/'||pr_nmarqpdf
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => vr_tab_erro);
        -- Se retornou erro
        IF NVL(vr_des_reto,'OK') <> 'OK' THEN
          IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
            RAISE vr_exc_erro; -- encerra programa
          END IF;
        END IF;

        -- Remover relatorio do diretorio padrao da cooperativa
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => 'rm '||vr_dsdireto ||'/'||pr_nmarqpdf
                             ,pr_typ_saida   => vr_typsaida
                             ,pr_des_saida   => vr_dscritic);
        -- Se retornou erro
        IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
          -- Concatena o erro que veio
          vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
          RAISE vr_exc_erro; -- encerra programa
        END IF;

      END IF; -- pr_idorigem = 5

    END IF; -- pr_idimpres = 7

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF nvl(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := REPLACE(REPLACE(vr_dscritic,chr(13)),chr(10));
      END IF;

      IF pr_flgerlog = 1 THEN
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdopecxa, 
                             pr_dscritic => pr_dscritic, 
                             pr_dsorigem => vr_dsorigem, 
                             pr_dstransa => vr_dstransa, 
                             pr_dttransa => TRUNC(SYSDATE),
                             pr_flgtrans => 0, -- FALSE
                             pr_hrtransa => GENE0002.fn_busca_time,
                             pr_idseqttl => pr_idseqttl, 
                             pr_nmdatela => pr_nmdatela, 
                             pr_nrdconta => pr_nrdconta, 
                             pr_nrdrowid => vr_nrdrowid);

        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                  pr_nmdcampo => 'nrctrlim',
                                  pr_dsdadant => NULL,
                                  pr_dsdadatu => pr_nrctrlim);
      END IF;

    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := REPLACE(REPLACE('Erro pc_gera_impressao_bordero: ' || SQLERRM, chr(13)),chr(10));

      IF pr_flgerlog = 1 THEN
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdopecxa, 
                             pr_dscritic => pr_dscritic, 
                             pr_dsorigem => vr_dsorigem, 
                             pr_dstransa => vr_dstransa, 
                             pr_dttransa => TRUNC(SYSDATE),
                             pr_flgtrans =>  0, -- FALSE
                             pr_hrtransa => GENE0002.fn_busca_time,
                             pr_idseqttl => pr_idseqttl, 
                             pr_nmdatela => pr_nmdatela, 
                             pr_nrdconta => pr_nrdconta, 
                             pr_nrdrowid => vr_nrdrowid);

        GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'nrctrlim', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrlim);
      END IF;

  END pc_gera_impressao_bordero;

  --> Procedure para gerar impressoes
  PROCEDURE pc_gera_impressao(pr_nrdconta   IN crapass.nrdconta%TYPE --> Número da Conta
                             ,pr_idseqttl   IN crapttl.idseqttl%TYPE --> Titular da Conta
                             ,pr_idimpres   IN INTEGER               --> Indicador de impressao
                             ,pr_tpctrlim   IN craplim.tpctrlim%TYPE --> Tipo de contrato de limite(2-Cheque e 3-Titulo)
                             ,pr_nrctrlim   IN craplim.nrctrlim%TYPE --> Contrato
                             ,pr_nrborder   IN crapbdc.nrborder%TYPE --> Numero do bordero
                             ,pr_dsiduser   IN VARCHAR2              --> Descricao do id do usuario
                             ,pr_flgemail   IN INTEGER               --> Indicador de envia por email (0-nao, 1-sim)
                             ,pr_flgerlog   IN INTEGER               --> Indicador se deve gerar log(0-nao, 1-sim)
                             ,pr_xmllog     IN VARCHAR2              --> XML com informacoes de LOG
                             ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                             ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                             ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                             ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                             ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_gera_impressao
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Setembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para chamar as impressoes.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
      -- Cursor da data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

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

      -- Variaveis gerais
      vr_nmarqpdf VARCHAR2(1000);

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_gera_impressao'
                                ,pr_action => NULL);

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

      -- Busca a data do sistema
      OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      --> BORDERO DE CHEQUES
      IF pr_idimpres = 7 THEN

        -- Se for cheque
        IF pr_tpctrlim = 2 THEN
          DSCC0001.pc_gera_impressao_bordero(pr_cdcooper => vr_cdcooper,
                                             pr_cdagecxa => vr_cdagenci,
                                             pr_nrdcaixa => vr_nrdcaixa,
                                             pr_cdopecxa => vr_cdoperad,
                                             pr_nmdatela => vr_nmdatela,
                                             pr_idorigem => vr_idorigem,
                                             pr_nrdconta => pr_nrdconta,
                                             pr_idseqttl => pr_idseqttl,
                                             pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                             pr_dtmvtopr => rw_crapdat.dtmvtopr,
                                             pr_inproces => rw_crapdat.inproces,
                                             pr_idimpres => pr_idimpres,
                                             pr_nrctrlim => pr_nrctrlim,
                                             pr_nrborder => pr_nrborder,
                                             pr_dsiduser => pr_dsiduser,
                                             pr_flgemail => pr_flgemail,
                                             pr_flgerlog => pr_flgerlog,
                                             pr_nmarqpdf => vr_nmarqpdf,
                                             pr_cdcritic => vr_cdcritic,
                                             pr_dscritic => vr_dscritic);
        -- Se for titulo
        ELSIF pr_tpctrlim = 3 THEN
          DSCT0002.pc_gera_impressao_bordero(pr_cdcooper => vr_cdcooper,
                                             pr_cdagecxa => vr_cdagenci,
                                             pr_nrdcaixa => vr_nrdcaixa,
                                             pr_cdopecxa => vr_cdoperad,
                                             pr_nmdatela => vr_nmdatela,
                                             pr_idorigem => vr_idorigem,
                                             pr_nrdconta => pr_nrdconta,
                                             pr_idseqttl => pr_idseqttl,
                                             pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                             pr_dtmvtopr => rw_crapdat.dtmvtopr,
                                             pr_inproces => rw_crapdat.inproces,
                                             pr_idimpres => pr_idimpres,
                                             pr_nrborder => pr_nrborder,
                                             pr_dsiduser => pr_dsiduser,
                                             pr_flgemail => pr_flgemail,
                                             pr_flgerlog => pr_flgerlog,
                                             pr_nmarqpdf => vr_nmarqpdf,
                                             pr_cdcritic => vr_cdcritic,
                                             pr_dscritic => vr_dscritic);
        ELSE
          vr_dscritic := 'Tipo de impressao invalido.';
          RAISE vr_exc_erro;
        END IF;

      --> LIMITE DE DESCONTO
      ELSIF pr_idimpres IN ( 1,       --> COMPLETA 
                             2,       --> CONTRATO 
                             4 ) THEN --> NOTA PROMISSORIA
        DSCT0002.pc_gera_impressao_limite(pr_cdcooper => vr_cdcooper,
                                          pr_cdagecxa => vr_cdagenci,
                                          pr_nrdcaixa => vr_nrdcaixa,
                                          pr_cdopecxa => vr_cdoperad,
                                          pr_nmdatela => vr_nmdatela,
                                          pr_idorigem => vr_idorigem,
                                          pr_tpctrlim => pr_tpctrlim,
                                          pr_nrdconta => pr_nrdconta,
                                          pr_idseqttl => pr_idseqttl,
                                          pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                          pr_dtmvtopr => rw_crapdat.dtmvtopr,
                                          pr_inproces => rw_crapdat.inproces,
                                          pr_idimpres => pr_idimpres,
                                          pr_nrctrlim => pr_nrctrlim,
                                          pr_dsiduser => pr_dsiduser,
                                          pr_flgemail => pr_flgemail,
                                          pr_flgerlog => pr_flgerlog,
                                          pr_nmarqpdf => vr_nmarqpdf,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
      ELSE
        vr_dscritic := 'Tipo de impressao invalido.';
        RAISE vr_exc_erro;
      END IF;

      -- Se retornou erro
      IF NVL(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nmarqpdf'
                            ,pr_tag_cont => vr_nmarqpdf
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CADPAC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_gera_impressao;

END DSCC0001;
/
