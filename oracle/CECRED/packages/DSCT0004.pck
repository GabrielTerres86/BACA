CREATE OR REPLACE PACKAGE CECRED.DSCT0004 is
  /* ---------------------------------------------------------------------------------------------------------------
      Programa : DSCT0004
      Sistema  : Internet Banking
      Sigla    : DSCT
      Autor    : Paulo Penteado (GFT) 
      Data     : Maio/2018.

      Dados referentes ao programa:

      Objetivo  : Rotinas referentes aos processos do Internet Banking do Borderô
                  As rotinas com nome finalizado em "_ib" são as chamadas pelo Internet Banking

      Alteracoes: 10/05/2018 Criaçao (Paulo Penteado (GFT))
                  10/10/2018 - Ajuste para mensagem de estouro do parametro da TAB052 na pc_criar_bordero_desc_tit (Andrew Albuquerque - GFT)
                  11/10/2018 - Ajuste para retornar a situação dos títulos na pc_obtem_titulos_resumo_ib e na
                               pc_obtem_detalhes_bordero_ib (Andrew Albuquerque - GFT)

  ---------------------------------------------------------------------------------------------------------------*/

PROCEDURE pc_obtem_borderos_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE           --> Cooperativa
                              ,pr_nrdconta  IN crapass.nrdconta%TYPE           --> Nr. da Conta
                              ,pr_dtmvtini  IN crapdat.dtmvtolt%TYPE           --> Data inicial do periodo
                              ,pr_dtmvtfin  IN crapdat.dtmvtolt%TYPE           --> Data final do periodo
                              ,pr_insitbdt  IN crapbdt.insitbdt%TYPE DEFAULT 0 --> Situação do borderô
                              ,pr_retxml   OUT XMLType                         --> Arquivo de retorno do XML
                              ,pr_dscritic OUT VARCHAR2                        --> Descrição da crítica
                              );

PROCEDURE pc_obtem_titulos_bordero_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da Conta
                                     ,pr_nrinssac  IN crapsab.nrinssac%TYPE --> Filtro de Tela de Inscricao do Pagador
                                     ,pr_dtmvtolt  IN VARCHAR2              --> Filtro de Tela de Data de emissão
                                     ,pr_dtvencto  IN VARCHAR2              --> Filtro de Tela de Data de vencimento
                                     ,pr_nriniseq  IN NUMBER                --> Paginação - Inicio de sequencia
                                     ,pr_nrregist  IN NUMBER                --> Paginação - Número de registros
                                     ,pr_retxml   OUT XMLType               --> Arquivo de retorno do XML
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     );

PROCEDURE pc_obtem_titulos_resumo_ib(pr_cdcooper     IN crapcop.cdcooper%TYPE --> Cooperativa
                                    ,pr_nrdconta     IN crapass.nrdconta%TYPE --> Nr. da Conta
                                    ,pr_cdbandoc_lst IN CLOB                  --> Código do banco
                                    ,pr_nrdctabb_lst IN CLOB                  --> Número da conta base no banco
                                    ,pr_nrcnvcob_lst IN CLOB                  --> Número do convênio de cobrança
                                    ,pr_nrdocmto_lst IN CLOB                  --> Número do documento (boleto)
                                    ,pr_nriniseq     IN NUMBER DEFAULT 0      --> Paginação - Inicio de sequencia
                                    ,pr_nrregist     IN NUMBER DEFAULT 0      --> Paginação - Número de registros
                                    ,pr_retxml      OUT XMLType               --> Arquivo de retorno do XML
                                    ,pr_dscritic    OUT VARCHAR2              --> Descrição da crítica
                                    );
                                    
PROCEDURE pc_finalizar_bordero_dscto_tit(pr_cdcooper     IN crapcop.cdcooper%TYPE --> Cooperativa
                                        ,pr_nrdconta     IN crapass.nrdconta%TYPE --> Nr. da Conta
                                        ,pr_idseqttl     IN crapttl.idseqttl%TYPE --> Número do Titular
                                        ,pr_fltranspend  IN NUMBER                --> Transação pendente 0-Nao 1-Sim
                                        ,pr_cdbandoc_lst	IN CLOB		                --> Código do banco
                                        ,pr_nrdctabb_lst	IN CLOB		                --> Número da conta base no banco
                                        ,pr_nrcnvcob_lst	IN CLOB		                --> Número do convênio de cobrança
                                        ,pr_nrdocmto_lst	IN CLOB		                --> Número do documento (boleto)
                                        ,pr_retxml      OUT CLOB                  --> Arquivo de retorno do XML
                                        ,pr_dscritic    OUT VARCHAR2              --> Descrição da crítica
                                        );

PROCEDURE pc_finalizar_bordero_ib(pr_cdcooper     IN crapcop.cdcooper%TYPE --> Cooperativa
                                 ,pr_nrdconta     IN crapass.nrdconta%TYPE --> Nr. da Conta
                                 ,pr_idseqttl     IN crapttl.idseqttl%TYPE --> Número do Titular
                                 ,pr_tokenib      IN VARCHAR2              -->Token da Transação
                                 ,pr_cdbandoc_lst IN CLOB                  --> Código do banco
                                 ,pr_nrdctabb_lst IN CLOB                  --> Número da conta base no banco
                                 ,pr_nrcnvcob_lst IN CLOB                  --> Número do convênio de cobrança
                                 ,pr_nrdocmto_lst IN CLOB                  --> Número do documento (boleto)
                                 ,pr_retxml      OUT XMLType               --> Arquivo de retorno do XML
                                 ,pr_dscritic    OUT VARCHAR2              --> Descrição da crítica
                                 );

PROCEDURE pc_obtem_detalhes_bordero_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                      ,pr_nrborder  IN crapbdt.nrborder%TYPE --> Numero do bordero
                                      ,pr_nriniseq  IN NUMBER DEFAULT 0      --> Paginação - Inicio de sequencia
                                      ,pr_nrregist  IN NUMBER DEFAULT 0      --> Paginação - Número de registros
                                      ,pr_retxml   OUT XMLType               --> Arquivo de retorno do XML
                                      ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                      );

PROCEDURE pc_imprime_bordero_dsctotit_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                        ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da Conta
                                        ,pr_nrborder  IN crapbdt.nrborder%TYPE --> Numero do bordero
                                        ,pr_retxml   OUT XMLType               --> Arquivo de retorno do XML
                                        ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                        );

END DSCT0004;
/
CREATE OR REPLACE PACKAGE BODY CECRED.DSCT0004 IS
  /* ---------------------------------------------------------------------------------------------------------------
      Programa : DSCT0004
      Sistema  : Internet Banking
      Sigla    : DSCT
      Autor    : Paulo Penteado (GFT) 
      Data     : Maio/2018.

      Dados referentes ao programa:

      Objetivo  : Rotinas referentes aos processos do Internet Banking do Borderô
                  As rotinas com nome finalizado em "_ib" são as chamadas pelo Internet Banking

      Alteracoes: 10/05/2018 Criaçao (Paulo Penteado (GFT))
                  10/10/2018 - Ajuste para mensagem de estouro do parametro da TAB052 na pc_criar_bordero_desc_tit (Andrew Albuquerque - GFT)
                  11/10/2018 - Ajuste para retornar a situação dos títulos na pc_obtem_titulos_resumo_ib e na
                               pc_obtem_detalhes_bordero_ib (Andrew Albuquerque - GFT)
                  18/04/2019 - Ajuste no cursor cr_craptdb_des para não buscar somente os borderôs do contrato de limite ativo e não 
                               permitir que retorno saldo com valor negativo (Paulo Penteado GFT) 

  ---------------------------------------------------------------------------------------------------------------*/
  -- Variáveis para armazenar as informações em XML
  vr_des_xml        CLOB;
  vr_det_xml        CLOB;
  vr_texto_completo VARCHAR2(32600);
  vr_index          PLS_INTEGER;
  vr_qtregist       NUMBER;
  vr_vllimdis       craptdb.vltitulo%TYPE;

  -- Buscar informações do borderô
  CURSOR cr_crapbdt(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                   ,pr_nrborder IN crapbdt.nrborder%TYPE --> Numero do bordero
                   ) IS
  SELECT bdt.nrdconta,
         bdt.insitbdt
    FROM crapbdt bdt
   WHERE bdt.nrborder = pr_nrborder
     AND bdt.cdcooper = pr_cdcooper;
  rw_crapbdt cr_crapbdt%ROWTYPE;
  
  -- Busca contrato de limite de desconto ativo
  CURSOR cr_craplim(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                   ,pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                   ) IS
  SELECT lim.nrctrlim,
         lim.vllimite
    FROM craplim lim
   WHERE lim.insitlim = 2
     AND lim.tpctrlim = 3
     AND lim.nrdconta = pr_nrdconta
     AND lim.cdcooper = pr_cdcooper;
  rw_craplim cr_craplim%ROWTYPE;
  
  --     Buscar o valor de titulos descontados
  CURSOR cr_craptdb_des(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE ) IS
  SELECT SUM(craptdb.vlsldtit) AS vlutiliz
    FROM craptdb
   WHERE craptdb.cdcooper = pr_cdcooper
     AND craptdb.nrdconta = pr_nrdconta
     AND (craptdb.insittit = 4 OR (craptdb.insittit = 2 AND craptdb.dtdpagto = pr_dtmvtolt));
  rw_craptdb_des cr_craptdb_des%ROWTYPE;
  

PROCEDURE pc_inicia_xml IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_inicia_xml
    Sistema  : Internet Banking IB
    Sigla    : DSCT0004
    Autor    : Paulo Penteado (GFT)
    Data     : Maio/2018

    Objetivo  : Rotina para iniciar a escrita do arquivo XML

    Alteração : 14/05/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
BEGIN
  vr_des_xml        := NULL;
  vr_det_xml        := NULL;
  vr_texto_completo := NULL;
  dbms_lob.createtemporary(vr_des_xml, TRUE);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
END;


PROCEDURE pc_escreve_xml( pr_des_dados IN VARCHAR2
                        , pr_fecha_xml IN BOOLEAN DEFAULT FALSE
                        ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_escreve_xml
    Sistema  : Internet Banking IB
    Sigla    : DSCT0004
    Autor    : Paulo Penteado (GFT)
    Data     : Maio/2018

    Objetivo  : Rotina para escrever texto na variável CLOB do XML

    Alteração : 14/05/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
BEGIN
  gene0002.pc_escreve_xml(vr_des_xml
                         ,vr_texto_completo
                         ,pr_des_dados
                         ,pr_fecha_xml );
END;


PROCEDURE pc_finaliza_xml IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_finaliza_xml
    Sistema  : Internet Banking IB
    Sigla    : DSCT0004
    Autor    : Paulo Penteado (GFT)
    Data     : Maio/2018

    Objetivo  : Rotina para finalizar a escrita do arquivo XML, e liberar objetos da memória

    Alteração : 14/05/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
BEGIN
   dbms_lob.close(vr_des_xml);
   dbms_lob.freetemporary(vr_des_xml);
END;

PROCEDURE pc_extrai_dados_xml_libera(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                    ,pr_xml        IN XMLType       --> XML com dados para LOG
                                    ,pr_msgretorno OUT VARCHAR2     --> Mensagem de retorno
                                    ,pr_dscritic   OUT VARCHAR2) IS --> Descrição da crítica
                                    
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_extrai_dados_xml_libera
    Sistema  : Internet Banking IB
    Sigla    : DSCT0004
    Autor    : Paulo Penteado (GFT)
    Data     : Maio/2018

   Objetivo  : Extrair informações dos xml retornado das procedures "_web" que são chamadas no processo do IB

    Alteração : 20/05/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
BEGIN
  pr_msgretorno := TRIM(pr_xml.extract('/root/dados/msgretorno/text()').getstringval());
EXCEPTION
  WHEN OTHERS THEN
    cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);
    
    pr_dscritic := 'Erro em dsct0004.pc_extrai_dados_xml_libera: ' || SQLERRM;
END pc_extrai_dados_xml_libera;


PROCEDURE pc_busca_parametros_dscto_tit(pr_cdcooper         IN  crapcop.cdcooper%TYPE --> Código da Cooperativa
                                       ,pr_nrdconta         IN  crapass.nrdconta%TYPE --> Número da Conta
                                       ,pr_tab_dados_dsctit OUT DSCT0002.typ_tab_dados_dsctit --> Tabela contendo os parametros da cooperativa
                                       ,pr_cdcritic         OUT PLS_INTEGER          --> Codigo da critica
                                       ,pr_dscritic         OUT VARCHAR2             --> Descricao da critica
                                       ) IS
  /*---------------------------------------------------------------------------------------------------------
    Programa : pc_busca_parametros_dscto_tit
    Sistema  : Ayllos
    Sigla    : 
    Autor    : Paulo Penteado (GFT)
    Data     : 13/11/2018

    Objetivo  : Buscar parâmetros de desconto de titulo da TAB052

    Alteração : 13/11/2018 - Criação (Paulo Penteado (GFT))

  ----------------------------------------------------------------------------------------------------------*/
  vr_tab_dados_dsctit  dsct0002.typ_tab_dados_dsctit;
  vr_tab_cecred_dsctit dsct0002.typ_tab_cecred_dsctit;

  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;

  -- Tratamento de erros
  vr_exc_erro EXCEPTION;
  
  CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                   ,pr_nrdconta crapass.nrdconta%TYPE) IS
  SELECT inpessoa
    FROM crapass
   WHERE cdcooper = pr_cdcooper
     AND nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
   
BEGIN
  
  OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                 ,pr_nrdconta => pr_nrdconta);  
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%NOTFOUND THEN
    CLOSE cr_crapass;
    vr_cdcritic := 9; -- 009 - Associado nao cadastrado.
    RAISE vr_exc_erro;
  ELSE
    CLOSE cr_crapass;    
  END IF;

  DSCT0002.pc_busca_parametros_dsctit(pr_cdcooper          => pr_cdcooper
                                     ,pr_cdagenci          => NULL -- sem utilidade
                                     ,pr_nrdcaixa          => NULL -- sem utilidade
                                     ,pr_cdoperad          => NULL -- sem utilidade
                                     ,pr_dtmvtolt          => NULL -- sem utilidade
                                     ,pr_idorigem          => NULL -- sem utilidade
                                     ,pr_tpcobran          => 1                    --> Tipo de Cobrança: 0 = Sem Registro / 1 = Com Registro
                                     ,pr_inpessoa          => rw_crapass.inpessoa  --> Indicador de tipo de pessoa
                                     ,pr_tab_dados_dsctit  => vr_tab_dados_dsctit  --> tabela contendo os parametros da cooperativa
                                     ,pr_tab_cecred_dsctit => vr_tab_cecred_dsctit --> Tabela contendo os parametros da cecred
                                     ,pr_cdcritic          => vr_cdcritic
                                     ,pr_dscritic          => vr_dscritic);

  IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;
  
  pr_tab_dados_dsctit := vr_tab_dados_dsctit;
EXCEPTION
  WHEN vr_exc_erro then
    IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    
    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;

  WHEN OTHERS THEN
    cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);
    
    pr_cdcritic := nvl(vr_cdcritic,0);
    pr_dscritic := 'Erro geral na rotina DSCT0004.pc_busca_parametros_dscto_tit: '||SQLERRM;
END pc_busca_parametros_dscto_tit;


PROCEDURE pc_valida_qtde_maxima_titulo(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_qttitulo  IN NUMBER                --> Quantidade de Titulos
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                      ) IS
  /*---------------------------------------------------------------------------------------------------------
    Programa : pc_valida_qtde_maxima_titulo
    Sistema  : Ayllos
    Sigla    : 
    Autor    : Paulo Penteado (GFT)
    Data     : 14/11/2018

    Objetivo  : Validar que a quandidade de titulos selecionados no borderô não ultrapasse a quantidade máxima permitida para o IB

    Alteração : 14/11/2018 - Criação (Paulo Penteado (GFT))

  ----------------------------------------------------------------------------------------------------------*/
  vr_tab_dados_dsctit  dsct0002.typ_tab_dados_dsctit;

  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;

  -- Tratamento de erros
  vr_exc_erro EXCEPTION;
   
BEGIN
  IF nvl(pr_qttitulo,0) > 0 THEN
    pc_busca_parametros_dscto_tit(pr_cdcooper         => pr_cdcooper
                                 ,pr_nrdconta         => pr_nrdconta
                                 ,pr_tab_dados_dsctit => vr_tab_dados_dsctit
                                 ,pr_cdcritic         => vr_cdcritic
                                 ,pr_dscritic         => vr_dscritic);

    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    IF pr_qttitulo > vr_tab_dados_dsctit(1).qtmxtbib THEN
      vr_dscritic := 'A quantidade dos títulos selecionados para desconto não pode ultrapassar '||vr_tab_dados_dsctit(1).qtmxtbib||' títulos';
      RAISE vr_exc_erro;
    END IF;
  END IF;
  
EXCEPTION
  WHEN vr_exc_erro THEN
    IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    pr_cdcritic := vr_cdcritic;
    pr_dscritic := vr_dscritic;

  WHEN OTHERS THEN
    cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);
    
    pr_cdcritic := nvl(vr_cdcritic,0);
    pr_dscritic := 'Erro geral na rotina DSCT0004.pc_valida_qtde_maxima_titulo: '||SQLERRM;
END pc_valida_qtde_maxima_titulo; 


PROCEDURE pc_calcula_limite_disponivel(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da Conta
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE --> Data de Movimento
                                      ,pr_vllimdis OUT craplim.vllimite%TYPE --> Valor disponivel
                                      ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_calcula_limite_disponivel
    Sistema  : Internet Banking IB
    Sigla    : DSCT0004
    Autor    : Paulo Penteado (GFT)
    Data     : Maio/2018

    Objetivo  : Rotina para calcular o valor disponível para desconto de borderô de títulos

    Alteração : 16/05/2018 - Criação (Paulo Penteado (GFT))
                18/04/2019 - Ajuste no cursor cr_craptdb_des para não buscar somente os borderôs do contrato de limite ativo e não 
                             permitir que retorno saldo com valor negativo (Paulo Penteado GFT) 

  ---------------------------------------------------------------------------------------------------------------------*/
  vr_vllimdis craplim.vllimite%TYPE := 0;
BEGIN
  OPEN cr_craplim(pr_cdcooper => pr_cdcooper
                 ,pr_nrdconta => pr_nrdconta);
  FETCH cr_craplim INTO rw_craplim;
  CLOSE cr_craplim;
  
  OPEN cr_craptdb_des(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_dtmvtolt => pr_dtmvtolt);
  FETCH cr_craptdb_des INTO rw_craptdb_des;
  CLOSE cr_craptdb_des;
  
  vr_vllimdis := nvl(rw_craplim.vllimite,0) - nvl(rw_craptdb_des.vlutiliz,0);
  
  IF vr_vllimdis < 0 THEN
    vr_vllimdis := 0;
  END IF;
  
  pr_vllimdis := vr_vllimdis;
EXCEPTION
  WHEN OTHERS THEN
    cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper); 

END pc_calcula_limite_disponivel;


PROCEDURE pc_obtem_borderos_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE           --> Cooperativa
                              ,pr_nrdconta  IN crapass.nrdconta%TYPE           --> Nr. da Conta
                              ,pr_dtmvtini  IN crapdat.dtmvtolt%TYPE           --> Data inicial do periodo
                              ,pr_dtmvtfin  IN crapdat.dtmvtolt%TYPE           --> Data final do periodo
                              ,pr_insitbdt  IN crapbdt.insitbdt%TYPE DEFAULT 0 --> Situacao do bordero
                              ,pr_retxml   OUT XMLType                         --> Arquivo de retorno do XML
                              ,pr_dscritic OUT VARCHAR2                        --> Descrição da crítica
                              ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_obtem_borderos_ib
    Sistema  : Internet Banking IB
    Sigla    : DSCT0004
    Autor    : Paulo Penteado (GFT)
    Data     : Maio/2018

    Objetivo  : Listar os Borderôs de Desconto de Títulos da cooperativa
    SOA       : Recebiveis.obterListaBorderos

    Alteração : 14/05/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
  vr_tab_dados_dsctit  dsct0002.typ_tab_dados_dsctit;
  
  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  
  vr_qtregist NUMBER;
  
  CURSOR cr_crapbdt(pr_cdcooper IN crapbdt.cdcooper%TYPE
                   ,pr_nrdconta IN crapbdt.nrdconta%TYPE
                   ,pr_dtmvtini IN crapbdt.dtmvtolt%TYPE
                   ,pr_dtmvtfin IN crapbdt.dtmvtolt%TYPE
                   ,pr_insitbdt IN crapbdt.insitbdt%TYPE) IS
  SELECT bdt.dtmvtolt,
         bdt.nrborder,
         (SELECT COUNT(1)
            FROM craptdb tdb
           WHERE tdb.cdcooper = pr_cdcooper
             AND tdb.nrdconta = pr_nrdconta
             AND tdb.nrborder = bdt.nrborder) qttitulo,
         (SELECT SUM(tdb.vltitulo)
            FROM craptdb tdb
           WHERE tdb.cdcooper = pr_cdcooper
             AND tdb.nrdconta = pr_nrdconta
             AND tdb.nrborder = bdt.nrborder) vltitulo,
         (SELECT COUNT(1)
            FROM craptdb tdb
           WHERE tdb.cdcooper = pr_cdcooper
             AND tdb.nrdconta = pr_nrdconta
             AND tdb.nrborder = bdt.nrborder
             AND tdb.insitapr = 1) qttitapr,
         NVL((SELECT SUM(tdb.vltitulo)
               FROM craptdb tdb
              WHERE tdb.cdcooper = pr_cdcooper
                AND tdb.nrdconta = pr_nrdconta
                AND tdb.nrborder = bdt.nrborder
                AND tdb.insitapr = 1),
             0) vltitapr,
         bdt.insitbdt,
         decode(bdt.insitbdt,
                1,
                'EM ESTUDO',
                2,
                'ANALISADO',
                3,
                'LIBERADO',
                4,
                'LIQUIDADO',
                5,
                'REJEITADO',
                'PROBLEMA') dssitbdt,
         COUNT(1) over() qtregist,
         bdt.dtlibbdt
    FROM crapbdt bdt
   WHERE bdt.insitbdt = decode(pr_insitbdt, 0, bdt.insitbdt, pr_insitbdt)
     AND bdt.dtmvtolt BETWEEN pr_dtmvtini AND pr_dtmvtfin
     AND bdt.nrdconta = pr_nrdconta
     AND bdt.cdcooper = pr_cdcooper
   ORDER BY bdt.dtmvtolt DESC,
            bdt.nrborder DESC;
  
  rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;
  
BEGIN
   
  -- Leitura do calendario
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    
  IF BTCH0001.cr_crapdat%NOTFOUND THEN
    vr_cdcritic := 1;
    CLOSE BTCH0001.cr_crapdat;
    RAISE vr_exc_saida;
  ELSE
    CLOSE BTCH0001.cr_crapdat;  
  END IF;
  

  pc_inicia_xml;
  pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?> <Root>');

  OPEN  cr_craplim(pr_cdcooper => pr_cdcooper
                  ,pr_nrdconta => pr_nrdconta);
  FETCH cr_craplim INTO rw_craplim;
  IF cr_craplim%FOUND THEN
  
    -- Fecha Cursor
    CLOSE cr_craplim;

    pc_busca_parametros_dscto_tit(pr_cdcooper         => pr_cdcooper
                                 ,pr_nrdconta         => pr_nrdconta
                                 ,pr_tab_dados_dsctit => vr_tab_dados_dsctit
                                 ,pr_cdcritic         => vr_cdcritic
                                 ,pr_dscritic         => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    FOR rw_crapbdt IN cr_crapbdt(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_dtmvtini => pr_dtmvtini
                                ,pr_dtmvtfin => pr_dtmvtfin
                                ,pr_insitbdt => pr_insitbdt) LOOP
      
      vr_det_xml := vr_det_xml ||
                    '<bordero>' ||
                      '<dtmvtolt>'||to_char(rw_crapbdt.dtmvtolt,'DD/MM/RRRR')||'</dtmvtolt>'||
                      '<nrborder>'||rw_crapbdt.nrborder||'</nrborder>'||
                      '<qttitulo>'||rw_crapbdt.qttitulo||'</qttitulo>'||
                      '<vltitulo>'||trim(to_char(rw_crapbdt.vltitulo,'99999999D99','NLS_NUMERIC_CHARACTERS='',.'''))||'</vltitulo>'||
                      '<qttitapr>'||rw_crapbdt.qttitapr||'</qttitapr>'||
                      '<vltitapr>'||trim(to_char(rw_crapbdt.vltitapr,'99999999D99','NLS_NUMERIC_CHARACTERS='',.'''))||'</vltitapr>'||
                      '<insitbdt>'||rw_crapbdt.insitbdt||'</insitbdt>'||
                      '<dssitbdt>'||rw_crapbdt.dssitbdt||'</dssitbdt>'||
                      '<dtlibbdt>'||to_char(rw_crapbdt.dtlibbdt,'DD/MM/RRRR')||'</dtlibbdt>'||
                    '</bordero>';
                    
      vr_qtregist := vr_qtregist + 1;              
    END LOOP;

          
    pc_escreve_xml('<Dados qtregist="'||nvl(vr_qtregist,0)||'" >');
    pc_escreve_xml('<vlmxassi>'||trim(to_char(vr_tab_dados_dsctit(1).vlmxassi,'99999999D99','NLS_NUMERIC_CHARACTERS='',.'''))||'</vlmxassi>'||
                   '<qtmxtbib>'||vr_tab_dados_dsctit(1).qtmxtbib||'</qtmxtbib>'||
                   '<flglimit>1</flglimit>'||
                   '<nrctrlim>'||rw_craplim.nrctrlim||'</nrctrlim>'||
                   '<inproces>'||rw_crapdat.inproces||'</inproces>');
    pc_escreve_xml('<borderos>');
    pc_escreve_xml(vr_det_xml);
    pc_escreve_xml('</borderos></Dados></Root>', TRUE);
    
  ELSE
    
    -- Fecha Cursor
    CLOSE cr_craplim;
    
    pc_escreve_xml('<Dados qtregist="0" >');
    pc_escreve_xml('<vlmxassi></vlmxassi>'||
                   '<flglimit>2</flglimit>'||
                   '<nrctrlim></nrctrlim>'||
                   '<inproces>'||rw_crapdat.inproces||'</inproces>');
    pc_escreve_xml('<borderos></borderos></Dados></Root>', TRUE);
  END   IF;
   
  pr_retxml  := XMLType.createXML(vr_des_xml);

  pc_finaliza_xml;

EXCEPTION
  WHEN vr_exc_saida THEN
       IF  vr_cdcritic <> 0 THEN
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       END IF;
       pr_dscritic := vr_dscritic;

       pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  WHEN OTHERS THEN
    cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);
    
    pr_dscritic := 'Erro geral na rotina dsct0004.pc_obtem_borderos_ib: '||SQLERRM;

    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
END pc_obtem_borderos_ib;


PROCEDURE pc_obtem_titulos_bordero_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da Conta
                                     ,pr_nrinssac  IN crapsab.nrinssac%TYPE --> Filtro de Tela de Inscricao do Pagador
                                     ,pr_dtmvtolt  IN VARCHAR2              --> Filtro de Tela de Data de emissão
                                     ,pr_dtvencto  IN VARCHAR2              --> Filtro de Tela de Data de vencimento
                                     ,pr_nriniseq  IN NUMBER                --> Paginação - Inicio de sequencia
                                     ,pr_nrregist  IN NUMBER                --> Paginação - Número de registros
                                     ,pr_retxml   OUT XMLType               --> Arquivo de retorno do XML
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_obtem_titulos_bordero_ib
    Sistema  : Internet Banking IB
    Sigla    : DSCT0004
    Autor    : Paulo Penteado (GFT)
    Data     : Maio/2018

    Objetivo  : Listar os títulos da cooperativa aptos de inclusão em um borderô
    SOA       : Recebiveis.obterListaTitulosPorPagador

    Alteração : 14/05/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
  vr_tab_dados_titulos tela_atenda_dscto_tit.typ_tab_dados_titulos;
  vr_dtmvtolt          crapdat.dtmvtolt%TYPE;
  vr_dtvencto          crapcob.dtvencto%TYPE;
  
  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  
  rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;

BEGIN
  
  -- Leitura do calendario
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    
  IF BTCH0001.cr_crapdat%NOTFOUND THEN
    vr_cdcritic := 1;
    CLOSE BTCH0001.cr_crapdat;
    RAISE vr_exc_saida;
  ELSE
    CLOSE BTCH0001.cr_crapdat;  
  END IF;
  
  pc_calcula_limite_disponivel(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                              ,pr_vllimdis => vr_vllimdis);

  vr_dtmvtolt := NULL;
  IF pr_dtmvtolt IS NOT NULL THEN
    vr_dtmvtolt := to_date(pr_dtmvtolt,'DD/MM/RRRR');
  END IF;

  vr_dtvencto := NULL;
  IF pr_dtvencto IS NOT NULL THEN
    vr_dtvencto := to_date(pr_dtvencto, 'DD/MM/RRRR');
  END IF;

  tela_atenda_dscto_tit.pc_buscar_titulos_bordero(pr_cdcooper          => pr_cdcooper
                                                 ,pr_nrdconta          => pr_nrdconta
                                                 ,pr_cdagenci          => NULL -- sem utilidade
                                                 ,pr_nrdcaixa          => NULL -- sem utilidade
                                                 ,pr_cdoperad          => NULL -- sem utilidade
                                                 ,pr_dtmvtolt          => rw_crapdat.dtmvtolt
                                                 ,pr_idorigem          => NULL -- sem utilidade
                                                 ,pr_nrinssac          => pr_nrinssac
                                                 ,pr_vltitulo          => 0 -- filtro
                                                 ,pr_dtvencto          => vr_dtvencto
                                                 ,pr_nrnosnum          => 0 -- filtro
                                                 ,pr_nrctrlim          => NULL -- sem utilidade
                                                 ,pr_insitlim          => NULL -- sem utilidade
                                                 ,pr_tpctrlim          => NULL -- sem utilidade
                                                 ,pr_nrborder          => NULL -- grava na type somente se ainda não estiver nela
                                                 ,pr_dtemissa          => vr_dtmvtolt
                                                 ,pr_nriniseq          => pr_nriniseq
                                                 ,pr_nrregist          => pr_nrregist
                                                 ,pr_qtregist          => vr_qtregist
                                                 ,pr_tab_dados_titulos => vr_tab_dados_titulos
                                                 ,pr_cdcritic          => vr_cdcritic
                                                 ,pr_dscritic          => vr_dscritic);

  IF  nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
  END IF;

  pc_inicia_xml;
  pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                 '<Root><Dados qtregist="' || vr_qtregist ||'" >');
                 
  pc_escreve_xml('<nrctrlim>'||rw_craplim.nrctrlim||'</nrctrlim>'||
                 '<vllimite>'||trim(to_char(rw_craplim.vllimite,'99999999D99','NLS_NUMERIC_CHARACTERS='',.'''))||'</vllimite>'||
                 '<vllimdis>'||trim(to_char(vr_vllimdis,'99999999D99','NLS_NUMERIC_CHARACTERS='',.'''))||'</vllimdis>');
                     
  pc_escreve_xml('<titulos>');
                     
  vr_index := vr_tab_dados_titulos.first;
  WHILE vr_index IS NOT NULL 
  LOOP
    pc_escreve_xml('<titulo>'||
                     '<nrcnvcob>'||vr_tab_dados_titulos(vr_index).nrcnvcob||'</nrcnvcob>'||
                     '<nrborder>'||vr_tab_dados_titulos(vr_index).nrdocmto||'</nrborder>'|| -- numero do boleto na tela
                     '<nmdsacad>'||vr_tab_dados_titulos(vr_index).nmdsacad||'</nmdsacad>'||
                     '<dtvencto>'||to_char(vr_tab_dados_titulos(vr_index).dtvencto,'DD/MM/RRRR')||'</dtvencto>'||
                     '<vltitulo>'||trim(to_char(vr_tab_dados_titulos(vr_index).vltitulo,'99999999D99','NLS_NUMERIC_CHARACTERS='',.'''))||'</vltitulo>'||
                     '<inpreapr>'||CASE WHEN vr_tab_dados_titulos(vr_index).dssituac = 'N' THEN 1 ELSE 0 END||'</inpreapr>'|| 
                     '<cdbandoc>'||vr_tab_dados_titulos(vr_index).cdbandoc||'</cdbandoc>'||
                     '<nrdctabb>'||vr_tab_dados_titulos(vr_index).nrdctabb||'</nrdctabb>'||
                     '<nrdocmto>'||vr_tab_dados_titulos(vr_index).nrdocmto||'</nrdocmto>'||
                   '</titulo>'
                  );
    vr_index := vr_tab_dados_titulos.next(vr_index);
  END LOOP;

  pc_escreve_xml('</titulos></Dados></Root>', TRUE);

  pr_retxml := xmltype.createxml(vr_des_xml);

  pc_finaliza_xml;
EXCEPTION
  WHEN vr_exc_saida THEN
       IF  vr_cdcritic <> 0 THEN
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       END IF;
       pr_dscritic := vr_dscritic;

       pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  WHEN OTHERS THEN
    cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);
    
    pr_dscritic := 'Erro geral na rotina dsct0004.pc_obtem_titulos_bordero_ib: '||SQLERRM;

    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
END pc_obtem_titulos_bordero_ib;


PROCEDURE pc_obtem_titulos_resumo_ib(pr_cdcooper     IN crapcop.cdcooper%TYPE --> Cooperativa
                                    ,pr_nrdconta     IN crapass.nrdconta%TYPE --> Nr. da Conta
                                    ,pr_cdbandoc_lst	IN CLOB		                --> Código do banco
                                    ,pr_nrdctabb_lst	IN CLOB		                --> Número da conta base no banco
                                    ,pr_nrcnvcob_lst	IN CLOB		                --> Número do convênio de cobrança
                                    ,pr_nrdocmto_lst	IN CLOB		                --> Número do documento (boleto)
                                    ,pr_nriniseq     IN NUMBER DEFAULT 0      --> Paginação - Inicio de sequencia
                                    ,pr_nrregist     IN NUMBER DEFAULT 0      --> Paginação - Número de registros
                                    ,pr_retxml      OUT XMLType               --> Arquivo de retorno do XML
                                    ,pr_dscritic    OUT VARCHAR2              --> Descrição da crítica
                                    ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_obtem_titulos_resumo_ib
    Sistema  : Internet Banking IB
    Sigla    : DSCT0004
    Autor    : Paulo Penteado (GFT)
    Data     : Maio/2018
    
    Importante: O conteúdo dos parâmetros de lista (pr_cdbandoc_lst, pr_nrdctabb_lst, pr_nrcnvcob_lst e pr_nrdocmto_lst) 
                devem ser alimentados na mesma ordem, pois são os valores que identificam a chave do título.
                Lista de valores separados pelo caracter | (pipe)

    Objetivo  : Mostrar um resumo listando os títulos selecionados para inclusão do borderô
    SOA       : Recebiveis.obterTitulosParaDesconto

    Alteração : 14/05/2018 - Criação (Paulo Penteado (GFT))
                11/10/2018 - Ajuste para retornar a situação dos títulos (Andrew Albuquerque - GFT)
                08/11/2018 - Removida verificação de erro da procedure tela_atenda_dscto_tit.pc_solicita_biro_bordero para não estourar erro em tela(Cássia de Oliveira - GFT)

  ---------------------------------------------------------------------------------------------------------------------*/
  vr_tab_cdbandoc gene0002.typ_split;
  vr_tab_nrdctabb gene0002.typ_split;
  vr_tab_nrcnvcob gene0002.typ_split;
  vr_tab_nrdocmto gene0002.typ_split;
  vr_tab_criticas dsct0003.typ_tab_critica;
  vr_tab_criticas_tit dsct0003.typ_tab_critica;
  vr_inpreapr     VARCHAR2(1); -- Indicado Titulo Pré-Aprovado: 0 Não, 1 Sim
  vr_cdbircon     crapbir.cdbircon%TYPE;
  vr_dsbircon     crapbir.dsbircon%TYPE;
  vr_cdmodbir     crapmbr.cdmodbir%TYPE;
  vr_dsmodbir     crapmbr.dsmodbir%TYPE;
  vr_qtpagina     INTEGER; -- contador para controlar a paginacao
  vr_tot_titulos  NUMBER;
  vr_index        NUMBER;
  
  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;

  vr_tab_dados_titulos TELA_ATENDA_DSCTO_TIT.typ_tab_dados_titulos;
  vr_tab_dados_pagador TELA_ATENDA_DSCTO_TIT.typ_tab_dados_pagador;

  CURSOR cr_crapcbd(pr_nrinssac crapcob.nrinssac%TYPE) IS
  SELECT crapcbd.nrconbir,
         crapcbd.nrseqdet
    FROM crapcbd
   WHERE crapcbd.cdcooper = pr_cdcooper
     AND crapcbd.nrdconta = pr_nrdconta
     AND crapcbd.nrcpfcgc = pr_nrinssac
     AND crapcbd.inreterr = 0 -- Nao houve erros
   ORDER BY crapcbd.dtconbir DESC; -- Buscar a consulta mais recente
  rw_crapcbd  cr_crapcbd%ROWTYPE;
  
    
  CURSOR cr_analise_pagador(pr_cdcooper crapsab.cdcooper%TYPE
                           ,pr_nrdconta crapsab.nrdconta%TYPE
                           ,pr_nrinssac crapsab.nrinssac%TYPE)  IS
  SELECT 1
    FROM tbdsct_analise_pagador tap
   WHERE tap.cdcooper = pr_cdcooper
     AND tap.nrdconta = pr_nrdconta
     AND tap.nrinssac = pr_nrinssac;
  rw_analise_pagador cr_analise_pagador%ROWTYPE;
  
  rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;

BEGIN
  vr_tab_cdbandoc := gene0002.fn_quebra_string(pr_cdbandoc_lst,'|');
  vr_tab_nrdctabb := gene0002.fn_quebra_string(pr_nrdctabb_lst,'|');
  vr_tab_nrcnvcob := gene0002.fn_quebra_string(pr_nrcnvcob_lst,'|');
  vr_tab_nrdocmto := gene0002.fn_quebra_string(pr_nrdocmto_lst,'|');

  IF vr_tab_nrdocmto.count() > 0 THEN
    
    pc_valida_qtde_maxima_titulo(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_qttitulo => vr_tab_nrdocmto.count()
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
    IF NVL(vr_cdcritic,0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Leitura do calendario
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      vr_cdcritic := 1;
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_saida;
    ELSE
      CLOSE BTCH0001.cr_crapdat;  
    END IF;
      
    pc_calcula_limite_disponivel(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                ,pr_vllimdis => vr_vllimdis);

    vr_qtpagina    := 1;
    vr_tot_titulos := 0;
    vr_inpreapr    := '0';

    -- Verificar críticas do borderô
    dsct0003.pc_calcula_restricao_bordero(pr_cdcooper     => pr_cdcooper
                                         ,pr_nrdconta     => pr_nrdconta
                                         ,pr_tot_titulos  => vr_tot_titulos
                                         ,pr_tab_criticas => vr_tab_criticas
                                         ,pr_cdcritic     => vr_cdcritic
                                         ,pr_dscritic     => vr_dscritic );

    IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    IF vr_tab_criticas.count = 0 THEN
      -- Verificar crítica do cedente
      dsct0003.pc_calcula_restricao_cedente(pr_cdcooper     => pr_cdcooper
                                           ,pr_nrdconta     => pr_nrdconta
                                           ,pr_cdagenci     => 90
                                           ,pr_nrdcaixa     => 900
                                           ,pr_cdoperad     => 996
                                           ,pr_nmdatela     => 'INTERNETBANK'
                                           ,pr_idorigem     => 3
                                           ,pr_idseqttl     => 1
                                           ,pr_tab_criticas => vr_tab_criticas
                                           ,pr_cdcritic     => vr_cdcritic
                                           ,pr_dscritic     => vr_dscritic );

      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    END IF;
      -- Agrupa os pagadores para fazer solicitação de calculo no biro
      vr_index := vr_tab_nrdocmto.first;
      WHILE vr_index IS NOT NULL
      LOOP
        IF (pr_nriniseq + pr_nrregist) = 0 OR (vr_qtpagina >= pr_nriniseq AND vr_qtpagina < (pr_nriniseq + pr_nrregist)) THEN
          IF tela_atenda_dscto_tit.cr_crapcob%ISOPEN THEN
            CLOSE tela_atenda_dscto_tit.cr_crapcob;
          END IF;
            
          OPEN tela_atenda_dscto_tit.cr_crapcob(pr_cdcooper => pr_cdcooper
                                               ,pr_nrdconta => pr_nrdconta
                                               ,pr_nrdocmto => vr_tab_nrdocmto(vr_index)
                                               ,pr_nrcnvcob => vr_tab_nrcnvcob(vr_index)
                                               ,pr_nrdctabb => vr_tab_nrdctabb(vr_index)
                                               ,pr_cdbandoc => vr_tab_cdbandoc(vr_index) );
          FETCH tela_atenda_dscto_tit.cr_crapcob INTO tela_atenda_dscto_tit.rw_crapcob;
            
          IF tela_atenda_dscto_tit.cr_crapcob%FOUND THEN
            vr_tab_dados_titulos(vr_index).cdcooper := tela_atenda_dscto_tit.rw_crapcob.cdcooper;
            vr_tab_dados_titulos(vr_index).nrdconta := tela_atenda_dscto_tit.rw_crapcob.nrdconta;
            vr_tab_dados_titulos(vr_index).nrctremp := tela_atenda_dscto_tit.rw_crapcob.nrctremp;
            vr_tab_dados_titulos(vr_index).nrcnvcob := tela_atenda_dscto_tit.rw_crapcob.nrcnvcob;
            vr_tab_dados_titulos(vr_index).nrdocmto := tela_atenda_dscto_tit.rw_crapcob.nrdocmto;
            vr_tab_dados_titulos(vr_index).nrinssac := tela_atenda_dscto_tit.rw_crapcob.nrinssac;
            vr_tab_dados_titulos(vr_index).nmdsacad := tela_atenda_dscto_tit.rw_crapcob.nmdsacad;
            vr_tab_dados_titulos(vr_index).dtvencto := tela_atenda_dscto_tit.rw_crapcob.dtvencto;
            vr_tab_dados_titulos(vr_index).dtmvtolt := tela_atenda_dscto_tit.rw_crapcob.dtmvtolt;
            vr_tab_dados_titulos(vr_index).vltitulo := tela_atenda_dscto_tit.rw_crapcob.vltitulo;
            vr_tab_dados_titulos(vr_index).nrnosnum := tela_atenda_dscto_tit.rw_crapcob.nrnosnum;
            vr_tab_dados_titulos(vr_index).flgregis := tela_atenda_dscto_tit.rw_crapcob.flgregis;
            vr_tab_dados_titulos(vr_index).cdtpinsc := tela_atenda_dscto_tit.rw_crapcob.cdtpinsc;
            vr_tab_dados_titulos(vr_index).vldpagto := tela_atenda_dscto_tit.rw_crapcob.vldpagto;
            vr_tab_dados_titulos(vr_index).cdbandoc := tela_atenda_dscto_tit.rw_crapcob.cdbandoc;
            vr_tab_dados_titulos(vr_index).nrdctabb := tela_atenda_dscto_tit.rw_crapcob.nrdctabb;
            vr_tab_dados_titulos(vr_index).dtdpagto := tela_atenda_dscto_tit.rw_crapcob.dtdpagto;
            vr_tab_dados_titulos(vr_index).nrborder := tela_atenda_dscto_tit.rw_crapcob.nrborder;
            vr_tab_dados_titulos(vr_index).dtlibbdt := tela_atenda_dscto_tit.rw_crapcob.dtlibbdt;
            vr_tab_dados_titulos(vr_index).dssittit := tela_atenda_dscto_tit.rw_crapcob.dssittit;
            vr_tab_dados_pagador(tela_atenda_dscto_tit.rw_crapcob.nrinssac).nrinssac := tela_atenda_dscto_tit.rw_crapcob.nrinssac;
            vr_tab_dados_pagador(tela_atenda_dscto_tit.rw_crapcob.nrinssac).nrdconta := tela_atenda_dscto_tit.rw_crapcob.nrdconta;
            vr_tab_dados_pagador(tela_atenda_dscto_tit.rw_crapcob.nrinssac).cdcooper := tela_atenda_dscto_tit.rw_crapcob.cdcooper;
            vr_tab_dados_pagador(tela_atenda_dscto_tit.rw_crapcob.nrinssac).nrcepsac := tela_atenda_dscto_tit.rw_crapcob.nrcepsac;
            vr_tab_dados_pagador(tela_atenda_dscto_tit.rw_crapcob.nrinssac).inpessoa := tela_atenda_dscto_tit.rw_crapcob.cdtpinsc;
            vr_tab_dados_pagador(tela_atenda_dscto_tit.rw_crapcob.nrinssac).vlttitbd := nvl(vr_tab_dados_pagador(tela_atenda_dscto_tit.rw_crapcob.nrinssac).vlttitbd,0) + tela_atenda_dscto_tit.rw_crapcob.vltitulo;
          END IF;
          CLOSE tela_atenda_dscto_tit.cr_crapcob;
        END IF;

        vr_qtpagina := vr_qtpagina +1;
        vr_index := vr_tab_nrdocmto.next(vr_index);
      END LOOP;

      pc_inicia_xml;
      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?> <Root>');

      IF (vr_tab_dados_titulos.count>0) THEN
        
        vr_index := vr_tab_dados_pagador.first;
        WHILE vr_index IS NOT NULL LOOP
          TELA_ATENDA_DSCTO_TIT.pc_solicita_biro_bordero(pr_cdcooper => pr_cdcooper
                                                        ,pr_nrdconta => pr_nrdconta
                                                        ,pr_nrinssac => vr_tab_dados_pagador(vr_index).nrinssac
                                                        ,pr_vlttitbd => vr_tab_dados_pagador(vr_index).vlttitbd
                                                        ,pr_nrctrlim => rw_craplim.nrctrlim
                                                        ,pr_inpessoa => vr_tab_dados_pagador(vr_index).inpessoa
                                                        ,pr_nrcepsac => vr_tab_dados_pagador(vr_index).nrcepsac
                                                        ,pr_cdoperad => 996
                                                        ,pr_cdcritic => vr_cdcritic
                                                        ,pr_dscritic => vr_dscritic);
                                                        
           OPEN  cr_analise_pagador(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrinssac => vr_tab_dados_pagador(vr_index).nrinssac);
           FETCH cr_analise_pagador INTO rw_analise_pagador;
           IF cr_analise_pagador%NOTFOUND THEN  
             CLOSE cr_analise_pagador;
             
             DSCT0002.pc_efetua_analise_pagador(pr_cdcooper => pr_cdcooper
                                               ,pr_nrdconta => pr_nrdconta
                                               ,pr_nrinssac => vr_tab_dados_pagador(vr_index).nrinssac
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);
                                             
             IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
               CLOSE cr_analise_pagador;
               RAISE vr_exc_saida;
             END IF;
           
           ELSE
             CLOSE cr_analise_pagador;  
           END IF;                                           
                                                        
                                                        
          vr_index := vr_tab_dados_pagador.next(vr_index);
        END LOOP;
        
        vr_index := vr_tab_dados_titulos.first;
        WHILE vr_index IS NOT NULL LOOP
          vr_inpreapr := '0';
          vr_tab_criticas_tit.DELETE;
          
          IF vr_tab_criticas.count = 0 THEN
          
            -- Verificar se o Título possui critica
            dsct0003.pc_calcula_restricao_titulo(pr_cdcooper     => pr_cdcooper
                                                ,pr_nrdconta     => pr_nrdconta
                                                ,pr_nrdocmto     => vr_tab_dados_titulos(vr_index).nrdocmto
                                                ,pr_nrcnvcob     => vr_tab_dados_titulos(vr_index).nrcnvcob
                                                ,pr_nrdctabb     => vr_tab_dados_titulos(vr_index).nrdctabb
                                                ,pr_cdbandoc     => vr_tab_dados_titulos(vr_index).cdbandoc
                                                ,pr_tab_criticas => vr_tab_criticas_tit
                                                ,pr_cdcritic     => vr_cdcritic
                                                ,pr_dscritic     => vr_dscritic);

            IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF;

          IF vr_tab_criticas.count = 0 AND vr_tab_criticas_tit.count = 0 THEN
              
            -- Verifica resultado do Biro
            OPEN cr_crapcbd(vr_tab_dados_titulos(vr_index).nrinssac);
            FETCH cr_crapcbd INTO rw_crapcbd;
            IF cr_crapcbd%NOTFOUND THEN
               vr_inpreapr := '0';
               CLOSE cr_crapcbd;
            ELSE
              CLOSE cr_crapcbd;
                
              -- Verifica se existe alguma negativa na consulta do biro. Retorna S ou N
              SSPC0001.pc_verifica_situacao(rw_crapcbd.nrconbir
                                           ,rw_crapcbd.nrseqdet
                                           ,vr_cdbircon
                                           ,vr_dsbircon
                                           ,vr_cdmodbir
                                           ,vr_dsmodbir
                                           ,vr_inpreapr);
              IF vr_inpreapr = 'S' THEN
                vr_inpreapr := '1';
              ELSE
                vr_inpreapr := '0';
              END IF;
            END IF;
              
            IF vr_inpreapr = '0' THEN
              -- Verifica criticas do Pagador, caso não tenha retornado nenhuma crítica/pendencia da consulta do Biro
              DSCT0003.pc_calcula_restricao_pagador(pr_cdcooper     => pr_cdcooper
                                                   ,pr_nrdconta     => pr_nrdconta
                                                   ,pr_nrinssac     => vr_tab_dados_titulos(vr_index).nrinssac
                                                   ,pr_cdbandoc     => vr_tab_dados_titulos(vr_index).cdbandoc
                                                   ,pr_nrdctabb     => vr_tab_dados_titulos(vr_index).nrdctabb
                                                   ,pr_nrcnvcob     => vr_tab_dados_titulos(vr_index).nrcnvcob
                                                   ,pr_nrdocmto     => vr_tab_dados_titulos(vr_index).nrdocmto
                                                   ,pr_tab_criticas => vr_tab_criticas_tit
                                                   ,pr_cdcritic     => vr_cdcritic
                                                   ,pr_dscritic     => vr_dscritic);

              IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;
            END IF;
          END IF;

          IF vr_tab_criticas.count = 0 AND vr_tab_criticas_tit.count = 0 THEN
            vr_inpreapr := '1';
          END IF;

          vr_det_xml := vr_det_xml||
                        '<titulo>'||
                          '<nrcnvcob>'||vr_tab_dados_titulos(vr_index).nrcnvcob||'</nrcnvcob>'||
                          '<nrborder>'||vr_tab_dados_titulos(vr_index).nrdocmto||'</nrborder>'||-- numero do boleto
                          '<nrdocmto>'||vr_tab_dados_titulos(vr_index).nrdocmto||'</nrdocmto>'||-- numero do boleto
                          '<nmdsacad>'||vr_tab_dados_titulos(vr_index).nmdsacad||'</nmdsacad>'||
                          '<dtvencto>'||to_char(vr_tab_dados_titulos(vr_index).dtvencto,'DD/MM/RRRR')||'</dtvencto>'||
                          '<vltitulo>'||trim(to_char(vr_tab_dados_titulos(vr_index).vltitulo,'99999999D99','NLS_NUMERIC_CHARACTERS='',.'''))||'</vltitulo>'||
                          '<inpreapr>'||vr_inpreapr||'</inpreapr>'|| -- Indicado Titulo Pré-Aprovado: 0 Não, 1 Sim
                          '<dssittit>'||vr_tab_dados_titulos(vr_index).dssittit||'</dssittit>'||
                        '</titulo>';
          vr_index := vr_tab_dados_titulos.next(vr_index);
        END LOOP;
      END IF;
          
      pc_escreve_xml('<Dados qtregist="'||nvl(vr_tab_nrdocmto.count,0)||'" >');
      pc_escreve_xml('<nrctrlim>'||rw_craplim.nrctrlim||'</nrctrlim>'||
                     '<vllimite>'||trim(to_char(rw_craplim.vllimite,'99999999D99','NLS_NUMERIC_CHARACTERS='',.'''))||'</vllimite>'||
                     '<vllimdis>'||trim(to_char(vr_vllimdis,'99999999D99','NLS_NUMERIC_CHARACTERS='',.'''))||'</vllimdis>');
      pc_escreve_xml('<titulos>');
      pc_escreve_xml(vr_det_xml);
      pc_escreve_xml('</titulos></Dados></Root>', TRUE);
   
      pr_retxml := XMLType.createXML(vr_des_xml);

      pc_finaliza_xml;
  END IF;
EXCEPTION
  WHEN vr_exc_saida THEN
       IF  vr_cdcritic <> 0 THEN
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       END IF;
       pr_dscritic := vr_dscritic;

       pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  WHEN OTHERS THEN
    cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);
    
    pr_dscritic := 'Erro geral na rotina dsct0004.pc_obtem_titulos_resumo_ib: '||SQLERRM;

    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
END pc_obtem_titulos_resumo_ib;


PROCEDURE pc_gera_trans_pend_dscto_tit(pr_cdcooper          IN crapcop.cdcooper%TYPE --> Cooperativa
                                      ,pr_nrdconta          IN crapass.nrdconta%TYPE --> Nr. da conta
                                      ,pr_idseqttl          IN crapttl.idseqttl%TYPE --> Número do Titular
                                      ,pr_nrcpfope          IN crapopi.nrcpfope%TYPE --> Cpf do Operador
                                      ,pr_nrcpfrep          IN crapopi.nrcpfope%TYPE --> Cpf do Responsavel Legal
                                      ,pr_tab_dados_titulos IN tela_atenda_dscto_tit.typ_tab_dados_titulos --> Titulos para desconto
                                      ,pr_dscritic         OUT VARCHAR2              --> Descrição da crítica
                                      ,pr_dsmensag         OUT VARCHAR2              --> Mensagem
                                      ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_gera_trans_pend_dscto_tit
    Sistema  : Internet Banking IB
    Sigla    : DSCT0004
    Autor    : Paulo Penteado (GFT)
    Data     : Maio/2018

    Objetivo  : Cadastrar desconto nas tabelas de transação pendente

    Alteração : 17/05/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
  vr_qttitulo NUMBER;
  vr_vltitulo NUMBER;
  vr_nrdrowid ROWID;

  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  
  rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;
      
BEGIN
  
  -- Leitura do calendario
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    
  IF BTCH0001.cr_crapdat%NOTFOUND THEN
    vr_cdcritic := 1;
    CLOSE BTCH0001.cr_crapdat;
    RAISE vr_exc_saida;
  ELSE
    CLOSE BTCH0001.cr_crapdat;  
  END IF;
      
  inet0002.pc_cria_trans_pend_dscto_tit(pr_cdcooper          => pr_cdcooper
                                       ,pr_nrdconta          => pr_nrdconta
                                       ,pr_idseqttl          => pr_idseqttl
                                       ,pr_nrcpfrep          => pr_nrcpfrep
                                       ,pr_cdagenci          => 90
                                       ,pr_nrdcaixa          => 900
                                       ,pr_cdoperad          => 996
                                       ,pr_nmdatela          => 'INTERNETBANK'
                                       ,pr_idorigem          => 3
                                       ,pr_nrcpfope          => pr_nrcpfope
                                       ,pr_cdcoptfn          => 0
                                       ,pr_cdagetfn          => 0
                                       ,pr_nrterfin          => 0
                                       ,pr_dtmvtolt          => rw_crapdat.dtmvtolt
                                       ,pr_idastcjt          => 1
                                       ,pr_tab_dados_titulos => pr_tab_dados_titulos
                                       ,pr_cdcritic          => vr_cdcritic
                                       ,pr_dscritic          => vr_dscritic);
      
  IF  nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida; 
  END IF;

  vr_qttitulo := 0;
  vr_vltitulo := 0;
  FOR idx IN pr_tab_dados_titulos.first..pr_tab_dados_titulos.last LOOP
      vr_qttitulo := vr_qttitulo + 1;
      vr_vltitulo := vr_vltitulo + pr_tab_dados_titulos(idx).vltitulo;
  END LOOP;
      
  -- Gerar log
  gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                      ,pr_cdoperad => 996
                      ,pr_dscritic => ' '
                      ,pr_dsorigem => 'INTERNET'
                      ,pr_dstransa => 'Transação pendente de borderô de desconto de título.'
                      ,pr_dttransa => TRUNC(SYSDATE)
                      ,pr_flgtrans => 0 -- TRUE
                      ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                      ,pr_idseqttl => pr_idseqttl
                      ,pr_nmdatela => ' '
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrdrowid => vr_nrdrowid);
      
  gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           ,pr_nmdcampo => 'Valor Total de Títulos'
                           ,pr_dsdadant => NULL
                           ,pr_dsdadatu => to_char(vr_vltitulo,'FM999G999G999G990D00'));
      
  gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           ,pr_nmdcampo => 'Quantidade de Títulos'
                           ,pr_dsdadant => NULL
                           ,pr_dsdadatu => vr_qttitulo);
      
  pr_dsmensag := 'Borderô de desconto de títulos registrado com sucesso. Aguardando aprovação do registro pelos demais responsáveis.';

EXCEPTION
  WHEN vr_exc_saida THEN
    IF vr_cdcritic <> 0 THEN
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    END IF;
    
    pr_dscritic := vr_dscritic;

  WHEN OTHERS THEN
    cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);
    
    pr_dscritic := 'Erro geral na rotina DSCT0004.pc_gera_trans_pend_dscto_tit: '||SQLERRM;
END pc_gera_trans_pend_dscto_tit;

PROCEDURE pc_libera_bordero_dscto_tit(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da conta
                                     ,pr_nrborder  IN crapbdt.nrborder%TYPE --> Numero do bordero
                                     ,pr_dsmensag OUT VARCHAR2              --> Mensagem
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_libera_bordero_dscto_tit
    Sistema  : Internet Banking IB
    Sigla    : DSCT0004
    Autor    : Paulo Penteado (GFT)
    Data     : Maio/2018

    Objetivo  : Realizar a liberação do borderô de desconto de títulos criado

    Alteração : 20/05/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
  vr_retxml   XMLType;
  vr_nmdcampo VARCHAR2(10000);
  vr_des_erro VARCHAR2(10000);
  
  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
BEGIN
  
  UPDATE crapbdt bdt
     SET insitbdt = 2, --analisado
         insitapr = 3 --aprovado automaticamente
   WHERE bdt.nrborder = pr_nrborder
     AND bdt.cdcooper = pr_cdcooper;

  vr_retxml := xmltype.createxml(
               '<?xml version="1.0" encoding="WINDOWS-1252"?>
                <Root>
                  <params>
                    <nmprogra>TELA_ATENDA_DESCTO</nmprogra>
                    <nmeacao>LIBERAR_BORDERO</nmeacao>
                    <cdcooper>'||pr_cdcooper||'</cdcooper>
                    <cdagenci>0</cdagenci>
                    <nrdcaixa>0</nrdcaixa>
                    <idorigem>3</idorigem>
                    <cdoperad>996</cdoperad>
                  </params>
                </Root>');
  
  -- Realizando a liberação do borderô pela procedure "_web" pois ela também valida impeditivos de criação do borderô
  dsct0003.pc_liberar_bordero_web(pr_nrdconta => pr_nrdconta
                                 ,pr_nrborder => pr_nrborder
                                 ,pr_confirma => 1
                                 ,pr_xmllog   => NULL
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_retxml   => vr_retxml
                                 ,pr_nmdcampo => vr_nmdcampo
                                 ,pr_des_erro => vr_des_erro );

  IF  nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida; 
  END IF;
  
  -- extrair a mensagem de retorno do processo de liberação
  --dbms_output.put_line(vr_retxml.getclobval); 
  pc_extrai_dados_xml_libera(pr_cdcooper   => pr_cdcooper
                            ,pr_xml        => vr_retxml
                            ,pr_msgretorno => pr_dsmensag
                            ,pr_dscritic   => vr_dscritic );

  IF  TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida; 
  END IF;
  
EXCEPTION
  WHEN vr_exc_saida THEN
  IF vr_cdcritic <> 0 THEN
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
  END IF;
         
  pr_dscritic := vr_dscritic;

  WHEN OTHERS THEN
    cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);
    
    pr_dscritic := 'Erro geral na rotina dsct0004.pc_libera_bordero_dscto_tit: '||SQLERRM;
END pc_libera_bordero_dscto_tit;


PROCEDURE pc_criar_bordero_dscto_tit(pr_cdcooper          IN crapcop.cdcooper%TYPE --> Cooperativa
                                    ,pr_nrdconta          IN crapass.nrdconta%TYPE --> Nr. da conta
                                    ,pr_idseqttl          IN crapttl.idseqttl%TYPE --> Número do Titular
                                    ,pr_inmxassi          IN NUMBER                --> Indicador de valor dos titulos excedido o valor maximo da assinatura
                                    ,pr_tab_dados_titulos IN tela_atenda_dscto_tit.typ_tab_dados_titulos --> Titulos para desconto
                                    ,pr_dsmensag         OUT VARCHAR2              --> Mensagem
                                    ,pr_dscritic         OUT VARCHAR2              --> Descrição da crítica
                                    ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_criar_bordero_dscto_tit
    Sistema  : Internet Banking IB
    Sigla    : DSCT0004
    Autor    : Paulo Penteado (GFT)
    Data     : Maio/2018

    Objetivo  : Realizar a criação do borderô de desconto de títulos com os titulos selecionados

    Alteração : 18/05/2018 - Criação (Paulo Penteado (GFT))
                10/10/2018 - Ajuste para mensagem de estouro do parametro da TAB052 (Andrew Albuquerque - GFT)
                19/03/2019 - Alterado o id do protocolo de desconto de titulo do 22 para o 32 (Paulo Penteado GFT)

  ---------------------------------------------------------------------------------------------------------------------*/
  vr_tab_borderos tela_atenda_dscto_tit.typ_tab_borderos;
  vr_qttitulo NUMBER;
  vr_vltitulo NUMBER;
  vr_nrdrowid ROWID;
  vr_desassun VARCHAR2(1000);
  vr_descorpo VARCHAR2(1000);
  vr_nrborder NUMBER;
  vr_nrautdoc craplcm.nrautdoc%type;
  vr_dsprotoc crappro.dsprotoc%TYPE;
  vr_nrdrecid    ROWID;
  vr_historico   INTEGER;
  vr_literal     VARCHAR2(1000);
  vr_flbdtlibera BOOLEAN;
          
  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_des_erro VARCHAR2(1000);
      
  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  
  CURSOR cr_crapage IS
  SELECT age.dsmailbd,
         age.cdagenci
    FROM crapass ass,
         crapage age
   WHERE ass.cdcooper = pr_cdcooper
     AND ass.nrdconta = pr_nrdconta
     AND age.cdcooper = ass.cdcooper
     AND age.cdagenci = ass.cdagenci
     AND TRIM(age.dsmailbd) IS NOT NULL;
  rw_crapage cr_crapage%ROWTYPE;
  
  rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;
  
BEGIN
  
  -- Leitura do calendario
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    
  IF BTCH0001.cr_crapdat%NOTFOUND THEN
    vr_cdcritic := 1;
    CLOSE BTCH0001.cr_crapdat;
    RAISE vr_exc_saida;
  ELSE
    CLOSE BTCH0001.cr_crapdat;  
  END IF;

  TELA_ATENDA_DSCTO_TIT.pc_insere_bordero(pr_cdcooper          => pr_cdcooper
                                         ,pr_nrdconta          => pr_nrdconta
                                         ,pr_tpctrlim          => 3
                                         ,pr_insitlim          => 2 -- Igual valor passado pela tela atenda
                                         ,pr_dtmvtolt          => rw_crapdat.dtmvtolt
                                         ,pr_cdoperad          => 996
                                         ,pr_cdagenci          => 90
                                         ,pr_nrdcaixa          => 900
                                         ,pr_nmdatela          => 'INTERNETBANK'
                                         ,pr_idorigem          => 3
                                         ,pr_idseqttl          => pr_idseqttl
                                         ,pr_dtmvtopr          => rw_crapdat.dtmvtopr
                                         ,pr_inproces          => rw_crapdat.inproces
                                         ,pr_tab_dados_titulos => pr_tab_dados_titulos
                                         ,pr_tab_borderos      => vr_tab_borderos
                                         ,pr_dsmensag          => pr_dsmensag
                                         ,pr_cdcritic          => vr_cdcritic
                                         ,pr_dscritic          => vr_dscritic );

  IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_saida; 
  END IF;

  vr_nrborder := vr_tab_borderos(1).nrborder;
  vr_historico := 0;
  vr_flbdtlibera := FALSE;

  -- Totalizando quantidade de títulos e valor dos títulos no bordero.
  vr_qttitulo := 0;
  vr_vltitulo := 0;
  FOR idx IN pr_tab_dados_titulos.first..pr_tab_dados_titulos.last LOOP
      vr_qttitulo := vr_qttitulo + 1;
      vr_vltitulo := vr_vltitulo + pr_tab_dados_titulos(idx).vltitulo;
  END LOOP;

  -- Se todos os titulos selecionados para o borderô estiverem pré-aprovados e se o valor dos titulos selecionados não exceder o
  -- Valor máximo da dispenda da assinatura da tab052, então aprovar automaticamente e liberar o borderô
  IF vr_tab_borderos(1).flrestricao = 0 AND pr_inmxassi = 0 THEN
    pc_libera_bordero_dscto_tit(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrborder => vr_nrborder
                               ,pr_dsmensag => pr_dsmensag
                               ,pr_dscritic => vr_dscritic);

    IF  TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida; 
    END IF;
    vr_historico := 2665;
    vr_flbdtlibera := TRUE;
  END IF;
  
  -- Grava uma Autenticacao para a transação
  CXON0000.pc_grava_autenticacao (pr_cooper       => pr_cdcooper   --Codigo Cooperativa
                                 ,pr_cod_agencia  => 90              --Codigo Agencia
                                 ,pr_nro_caixa    => 900            --Numero do caixa
                                 ,pr_cod_operador => 996            --Codigo Operador
                                 ,pr_valor        => vr_vltitulo    --Valor da transacao
                                 ,pr_docto        => vr_nrborder    --Numero documento
                                 ,pr_operacao     => TRUE           --Indicador Operacao Debito
                                 ,pr_status       => '1'            --Status da Operacao - Online
                                 ,pr_estorno      => FALSE          --Indicador Estorno
                                 ,pr_histor       => vr_historico   --Historico
                                 ,pr_data_off     => NULL           --Data Transacao
                                 ,pr_sequen_off   => 0              --Sequencia
                                 ,pr_hora_off     => 0              --Hora transacao
                                 ,pr_seq_aut_off  => 0              --Sequencia automatica
                                 ,pr_literal      => vr_literal     --Descricao literal
                                 ,pr_sequencia    => vr_nrautdoc    --Sequencia
                                 ,pr_registro     => vr_nrdrecid    --ROWID do registro
                                 ,pr_cdcritic     => vr_cdcritic    --Código do erro
                                 ,pr_dscritic     => vr_dscritic);  --Descricao do erro
                                 
  IF nvl(vr_cdcritic,0) <> 0 OR trim(vr_dscritic) IS NOT NULL THEN
    vr_cdcritic:= 0;
    vr_dscritic:= 'Erro na autenticação da transação.';
    --Levantar Excecao
    RAISE vr_exc_saida;
  END IF;
  
  -- Insere o protocolo de geração do borderô
  GENE0006.pc_gera_protocolo(pr_cdcooper => pr_cdcooper                         --> Código da cooperativa
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt                 --> Data movimento
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS')) --> Hora da transação
                            ,pr_nrdconta => pr_nrdconta                         --> Número da conta
                            ,pr_nrdocmto => vr_nrborder                         --> Número do documento
                            ,pr_nrseqaut => NVL(vr_nrautdoc,0)                  --> Número da sequencia
                            ,pr_vllanmto => vr_vltitulo                         --> Valor lançamento
                            ,pr_nrdcaixa => 900                                 --> Número do caixa
                            ,pr_gravapro => TRUE                                --> Controle de gravação
                            ,pr_cdtippro => 32                                  --> Código de operação
                            ,pr_dsinfor1 => 'Desconto de Titulo'                --> Descrição 1
                            ,pr_dsinfor2 => vr_qttitulo                         --> Descrição 2
                            ,pr_dsinfor3 => NULL                                --> Descrição 3
                            ,pr_dscedent => NULL                                --> Descritivo
                            ,pr_flgagend => FALSE                               --> Controle de agenda
                            ,pr_nrcpfope => 0                                   --> Número de operação
                            ,pr_nrcpfpre => 0                                   --> Número pré operação
                            ,pr_nmprepos => NULL                                --> Nome
                            ,pr_dsprotoc => vr_dsprotoc                         --> Descrição do protocolo
                            ,pr_dscritic => vr_dscritic                         --> Descrição crítica
                            ,pr_des_erro => vr_des_erro);                       --> Descrição dos erros de processo
  
  IF  TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida; 
  END IF;

  -- Gerar log
  gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                      ,pr_cdoperad => 996
                      ,pr_dscritic => ' '
                      ,pr_dsorigem => 'INTERNET'
                      ,pr_dstransa => 'Inclusão de borderô de desconto de títulos.'
                      ,pr_dttransa => TRUNC(SYSDATE)
                      ,pr_flgtrans => 0 -- TRUE
                      ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                      ,pr_idseqttl => pr_idseqttl
                      ,pr_nmdatela => 'INTERNETBANK'
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrdrowid => vr_nrdrowid);
      
  gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           ,pr_nmdcampo => 'Borderô'
                           ,pr_dsdadant => NULL
                           ,pr_dsdadatu => vr_nrborder);
      
  gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           ,pr_nmdcampo => 'Valor Total de Títulos'
                           ,pr_dsdadant => NULL
                           ,pr_dsdadatu => to_char(vr_vltitulo,'FM999G999G999G990D00'));
      
  gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                           ,pr_nmdcampo => 'Quantidade de Títulos'
                           ,pr_dsdadant => NULL
                           ,pr_dsdadatu => vr_qttitulo);
      
  FOR idx IN pr_tab_dados_titulos.first..pr_tab_dados_titulos.last LOOP
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Convenio '||idx
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => pr_tab_dados_titulos(idx).nrcnvcob);

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Documento '||idx
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => pr_tab_dados_titulos(idx).nrdocmto);

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Nosso Numero '||idx
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => pr_tab_dados_titulos(idx).nrnosnum);
  END LOOP;
      
  -- Enviar e-mail somente se o borderô não foi liberado automaticamente.
  IF vr_flbdtlibera = FALSE THEN
    
    --    Busca e-mail da empresa
    OPEN  cr_crapage;
    FETCH cr_crapage INTO rw_crapage;
    IF cr_crapage%FOUND THEN
       -- Fecha Cursor
       CLOSE cr_crapage;
      
        -- Assunto do E-mail
        vr_desassun := ' Aviso de borderô de títulos: '|| rw_crapage.cdagenci||' - '||pr_nrdconta||
                       ' - '||vr_nrborder||' - ' || to_char(vr_vltitulo,'FM999G999G999G990D00');

        -- Corpo do E-mail
        vr_descorpo := 'PA:'                     ||rw_crapage.cdagenci                    ||'<br>'||
                       'Conta/DV:	'              ||pr_nrdconta                            ||'<br>'||
                       'Número do borderô: '     ||vr_nrborder                            ||'<br>'||
                       'Data/Hora: '             ||to_char(SYSDATE, 'DD/MM/RRRR hh:mi:ss')||'<br>'||
                       'Quantidade de títulos: ' ||vr_qttitulo                            ||'<br>'||
                       'Valor total do borderô: '||to_char(vr_vltitulo,'FM999G999G999G990D00');

        -- Envia E-mail
        gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                  ,pr_flg_remete_coop => 'N'  --> Envio pelo e-mail da Cooperativa
                                  ,pr_cdprogra        => 'DSTC0004'
                                  ,pr_des_destino     => TRIM(rw_crapage.dsmailbd)
                                  ,pr_des_assunto     => vr_desassun
                                  ,pr_des_corpo       => vr_descorpo
                                  ,pr_des_anexo       => NULL --> nao envia anexo
                                  ,pr_flg_remove_anex => 'N'  --> Remover os anexos passados
                                  ,pr_flg_enviar      => 'S'  --> Enviar o e-mail na hora
                                  ,pr_des_erro        => vr_dscritic);
        --  Se houver erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
    ELSE
      -- Fecha Cursor
      CLOSE cr_crapage;      
    END   IF;

  END IF;


  
EXCEPTION
  WHEN vr_exc_saida THEN
    IF NVL(vr_cdcritic,0) <> 0 THEN
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    END IF;
    pr_dscritic := vr_dscritic;
    


  WHEN OTHERS THEN
    cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);
    
    pr_dscritic := 'Erro geral na rotina DSCT0004.pc_criar_bordero_dscto_tit: '||SQLERRM;
    

END pc_criar_bordero_dscto_tit;


PROCEDURE pc_finalizar_bordero_dscto_tit(pr_cdcooper     IN crapcop.cdcooper%TYPE --> Cooperativa
                                        ,pr_nrdconta     IN crapass.nrdconta%TYPE --> Nr. da Conta
                                        ,pr_idseqttl     IN crapttl.idseqttl%TYPE --> Número do Titular
                                        ,pr_fltranspend  IN NUMBER                --> Transação pendente 0-Nao 1-Sim
                                        ,pr_cdbandoc_lst	IN CLOB		                --> Código do banco
                                        ,pr_nrdctabb_lst	IN CLOB		                --> Número da conta base no banco
                                        ,pr_nrcnvcob_lst	IN CLOB		                --> Número do convênio de cobrança
                                        ,pr_nrdocmto_lst	IN CLOB		                --> Número do documento (boleto)
                                        ,pr_retxml      OUT CLOB                  --> Arquivo de retorno do XML
                                        ,pr_dscritic    OUT VARCHAR2              --> Descrição da crítica
                                        ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_finalizar_bordero_dscto_tit
    Sistema  : Internet Banking IB
    Sigla    : DSCT0004
    Autor    : Paulo Penteado (GFT)
    Data     : Junho/2018
    
    Importante: O conteúdo dos parâmetros de lista (pr_cdbandoc_lst, pr_nrdctabb_lst, pr_nrcnvcob_lst e pr_nrdocmto_lst) 
                devem ser alimentados na mesma ordem, pois são os valores que identificam a chave do título.
                Lista de valores separados pelo caracter | (pipe)

    Objetivo  : Finalizar o processo de geração do borderô. Criar o borderô com base nos títulos selecionados

    Alteração : 06/06/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
  vr_tab_dados_titulos tela_atenda_dscto_tit.typ_tab_dados_titulos;
  vr_tab_dados_dsctit  DSCT0002.typ_tab_dados_dsctit;
  vr_tab_cdbandoc      gene0002.typ_split;
  vr_tab_nrdctabb      gene0002.typ_split;
  vr_tab_nrcnvcob      gene0002.typ_split;
  vr_tab_nrdocmto      gene0002.typ_split;
  vr_idastcjt          crapass.idastcjt%TYPE;
  vr_nrcpfcgc          crapass.nrcpfcgc%TYPE;
  vr_nmprimtl          crapass.nmprimtl%TYPE;
  vr_flcartma          INTEGER;
  vr_aux               NUMBER;
  vr_vltitulo          craptdb.vltitulo%TYPE;
  vr_inmxassi          NUMBER;

  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);
  vr_dsmensag VARCHAR2(10000);

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
BEGIN
  vr_vltitulo     := 0;
  vr_inmxassi     := 0;
  vr_tab_cdbandoc := gene0002.fn_quebra_string(pr_cdbandoc_lst,'|');
  vr_tab_nrdctabb := gene0002.fn_quebra_string(pr_nrdctabb_lst,'|');
  vr_tab_nrcnvcob := gene0002.fn_quebra_string(pr_nrcnvcob_lst,'|');
  vr_tab_nrdocmto := gene0002.fn_quebra_string(pr_nrdocmto_lst,'|');

  -- Possui documentos para processar
  IF vr_tab_nrdocmto.count() > 0 THEN
    
    pc_valida_qtde_maxima_titulo(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_qttitulo => vr_tab_nrdocmto.count()
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
    IF NVL(vr_cdcritic,0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- percorrer a lista dos parâmetros de entrada e gravar seus valores na lista de titulos
    vr_index := vr_tab_nrdocmto.first;
    WHILE vr_index IS NOT NULL 
    LOOP
          OPEN  tela_atenda_dscto_tit.cr_crapcob(pr_cdcooper => pr_cdcooper
                                                ,pr_nrdconta => pr_nrdconta
                                                ,pr_nrdocmto => vr_tab_nrdocmto(vr_index)
                                                ,pr_nrcnvcob => vr_tab_nrcnvcob(vr_index)
                                                ,pr_nrdctabb => vr_tab_nrdctabb(vr_index)
                                                ,pr_cdbandoc => vr_tab_cdbandoc(vr_index) );
          FETCH tela_atenda_dscto_tit.cr_crapcob INTO tela_atenda_dscto_tit.rw_crapcob;
          IF    tela_atenda_dscto_tit.cr_crapcob%NOTFOUND THEN
                CLOSE tela_atenda_dscto_tit.cr_crapcob;
                vr_dscritic := 'Título de cobrança '||vr_tab_nrdocmto(vr_index)||' não encontrado para conta '||pr_nrdconta||'.';
                RAISE vr_exc_saida;
          END   IF;
          CLOSE tela_atenda_dscto_tit.cr_crapcob;

          vr_tab_dados_titulos(vr_index).nrdctabb := tela_atenda_dscto_tit.rw_crapcob.nrdctabb;
          vr_tab_dados_titulos(vr_index).nrcnvcob := tela_atenda_dscto_tit.rw_crapcob.nrcnvcob;
          vr_tab_dados_titulos(vr_index).nrinssac := tela_atenda_dscto_tit.rw_crapcob.nrinssac;
          vr_tab_dados_titulos(vr_index).cdbandoc := tela_atenda_dscto_tit.rw_crapcob.cdbandoc;
          vr_tab_dados_titulos(vr_index).nrdconta := tela_atenda_dscto_tit.rw_crapcob.nrdconta;
          vr_tab_dados_titulos(vr_index).nrdocmto := tela_atenda_dscto_tit.rw_crapcob.nrdocmto;
          vr_tab_dados_titulos(vr_index).dtvencto := tela_atenda_dscto_tit.rw_crapcob.dtvencto;
          vr_tab_dados_titulos(vr_index).dtlibbdt := tela_atenda_dscto_tit.rw_crapcob.dtlibbdt;
          vr_tab_dados_titulos(vr_index).nrnosnum := tela_atenda_dscto_tit.rw_crapcob.nrnosnum;
          vr_tab_dados_titulos(vr_index).vltitulo := tela_atenda_dscto_tit.rw_crapcob.vltitulo;
          vr_tab_dados_titulos(vr_index).nmdsacad := tela_atenda_dscto_tit.rw_crapcob.nmdsacad;
          vr_tab_dados_titulos(vr_index).dssituac := tela_atenda_dscto_tit.rw_crapcob.dssituac;
          vr_tab_dados_titulos(vr_index).cdcooper := tela_atenda_dscto_tit.rw_crapcob.cdcooper;
          vr_tab_dados_titulos(vr_index).nrctremp := tela_atenda_dscto_tit.rw_crapcob.nrctremp;
          vr_tab_dados_titulos(vr_index).dtmvtolt := tela_atenda_dscto_tit.rw_crapcob.dtmvtolt;
          vr_tab_dados_titulos(vr_index).flgregis := tela_atenda_dscto_tit.rw_crapcob.flgregis;
          vr_tab_dados_titulos(vr_index).cdtpinsc := tela_atenda_dscto_tit.rw_crapcob.cdtpinsc;
          vr_tab_dados_titulos(vr_index).vldpagto := tela_atenda_dscto_tit.rw_crapcob.vldpagto;
          vr_tab_dados_titulos(vr_index).dtdpagto := tela_atenda_dscto_tit.rw_crapcob.dtdpagto;
          vr_tab_dados_titulos(vr_index).nrborder := tela_atenda_dscto_tit.rw_crapcob.nrborder;

          -- Faz calculo de liquidez e concentracao e atualiza as criticas
          DSCT0002.pc_atualiza_calculos_pagador(pr_cdcooper => tela_atenda_dscto_tit.rw_crapcob.cdcooper
                                               ,pr_nrdconta => tela_atenda_dscto_tit.rw_crapcob.nrdconta
                                               ,pr_nrinssac => tela_atenda_dscto_tit.rw_crapcob.nrinssac
                                               ,pr_flforcar => FALSE
                                               --------------> OUT <--------------
                                               ,pr_pc_cedpag  => vr_aux
                                               ,pr_qtd_cedpag => vr_aux
                                               ,pr_pc_conc    => vr_aux
                                               ,pr_qtd_conc   => vr_aux
                                               ,pr_cdcritic   => vr_cdcritic
                                               ,pr_dscritic   => vr_dscritic );

          vr_vltitulo := vr_vltitulo + vr_tab_dados_titulos(vr_index).vltitulo;

          vr_index := vr_tab_nrdocmto.next(vr_index);
    END LOOP;

    pc_busca_parametros_dscto_tit(pr_cdcooper         => pr_cdcooper
                                 ,pr_nrdconta         => pr_nrdconta                                                   
                                 ,pr_tab_dados_dsctit => vr_tab_dados_dsctit
                                 ,pr_cdcritic         => vr_cdcritic
                                 ,pr_dscritic         => vr_dscritic);

    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
      
    -- Verifica se a conta exige assinatura multipla
    INET0002.pc_verifica_rep_assinatura(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_cdorigem => 3
                                       ,pr_idastcjt => vr_idastcjt -- Codigo 1 exige Ass. Conj.
                                       ,pr_nrcpfcgc => vr_nrcpfcgc -- CPF do Rep. Legal
                                       ,pr_nmprimtl => vr_nmprimtl -- Nome do Rep. Legal          
                                       ,pr_flcartma => vr_flcartma -- Cartao Magnetico conjunta, 0 nao, 1 sim
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

    IF  nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida; 
    END IF;
      
    -- Se a soma do valor de todos os títulos do borderô for maior que o parametro VLMXASSI dos parãmetros da TAB052, 
    -- emitir mensagem para realizar a assinatural manual.
    IF vr_vltitulo > vr_tab_dados_dsctit(1).vlmxassi THEN
      vr_inmxassi := 1;
    END IF;

    --  Se precisar de multiplas assinaturas
    IF  (vr_idastcjt = 1) AND (pr_fltranspend = 1) THEN
        -- Cadastra transacao pendente
        pc_gera_trans_pend_dscto_tit(pr_cdcooper          => pr_cdcooper
                                    ,pr_nrdconta          => pr_nrdconta
                                    ,pr_idseqttl          => pr_idseqttl
                                    ,pr_nrcpfope          => 0
                                    ,pr_nrcpfrep          => vr_nrcpfcgc
                                    ,pr_tab_dados_titulos => vr_tab_dados_titulos
                                    ,pr_dscritic          => vr_dscritic
                                    ,pr_dsmensag          => vr_dsmensag);
          
        IF  nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_saida; 
        END IF;
    ELSE
        pc_criar_bordero_dscto_tit(pr_cdcooper          => pr_cdcooper
                                  ,pr_nrdconta          => pr_nrdconta
                                  ,pr_idseqttl          => pr_idseqttl
                                  ,pr_inmxassi          => vr_inmxassi
                                  ,pr_tab_dados_titulos => vr_tab_dados_titulos
                                  ,pr_dsmensag          => vr_dsmensag
                                  ,pr_dscritic          => vr_dscritic );

        IF  TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_saida; 
        END IF;
    END IF;
      
    IF vr_inmxassi = 1 THEN
      vr_dsmensag := vr_dsmensag ||' Valor somente será liberado mediante assinatura do borderô no Posto de Atendimento da Cooperativa.';
    END IF;

    pr_retxml := vr_dsmensag;
    
    COMMIT;

  END IF;
EXCEPTION
  WHEN vr_exc_saida THEN
    IF vr_cdcritic <> 0 THEN
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    END IF;
    
    pr_dscritic := vr_dscritic;
    pr_retxml := pr_dscritic;
    
    ROLLBACK;

  WHEN OTHERS THEN
    cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);
    
    pr_dscritic := 'Erro geral na rotina dsct0004.pc_finalizar_bordero_dscto_tit: '||SQLERRM;
    pr_retxml := pr_dscritic;
    
    ROLLBACK;
    
END pc_finalizar_bordero_dscto_tit;



PROCEDURE pc_finalizar_bordero_ib(pr_cdcooper     IN crapcop.cdcooper%TYPE --> Cooperativa
                                 ,pr_nrdconta     IN crapass.nrdconta%TYPE --> Nr. da Conta
                                 ,pr_idseqttl     IN crapttl.idseqttl%TYPE --> Número do Titular
                                 ,pr_tokenib      IN VARCHAR2              --> Token da Transação
                                 ,pr_cdbandoc_lst	IN CLOB		                --> Código do banco
                                 ,pr_nrdctabb_lst	IN CLOB		                --> Número da conta base no banco
                                 ,pr_nrcnvcob_lst	IN CLOB		                --> Número do convênio de cobrança
                                 ,pr_nrdocmto_lst	IN CLOB		                --> Número do documento (boleto)
                                 ,pr_retxml      OUT XMLType               --> Arquivo de retorno do XML
                                 ,pr_dscritic    OUT VARCHAR2              --> Descrição da crítica
                                 ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_finalizar_bordero_ib
    Sistema  : Internet Banking IB
    Sigla    : DSCT0004
    Autor    : Paulo Penteado (GFT)
    Data     : Maio/2018
    
    Importante: O conteúdo dos parâmetros de lista (pr_cdbandoc_lst, pr_nrdctabb_lst, pr_nrcnvcob_lst e pr_nrdocmto_lst) 
                devem ser alimentados na mesma ordem, pois são os valores que identificam a chave do título.
                Lista de valores separados pelo caracter | (pipe)

    Objetivo  : Finalizar o processo de geração do borderô. Criar o borderô com base nos títulos selecionados
    SOA       : Recebiveis.manterBorderoTitulos

    Alteração : 14/05/2018 - Criação (Paulo Penteado (GFT))
                06/06/2018 - Tranfornado na procedure pc_finalizar_bordero_dscto_tit (Paulo Penteado (GFT)) 

  ---------------------------------------------------------------------------------------------------------------------*/
  vr_retxml CLOB;
  
  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
BEGIN
  -- Efetuar a validação do token informado
  INET0003.pc_utiliza_autenticacao_ib(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_tokenib  => pr_tokenib
                                     ,pr_dscritic => vr_dscritic);

  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF; 

  pc_finalizar_bordero_dscto_tit(pr_cdcooper     => pr_cdcooper
                                ,pr_nrdconta     => pr_nrdconta
                                ,pr_idseqttl     => pr_idseqttl
                                ,pr_fltranspend  => 1
                                ,pr_cdbandoc_lst => pr_cdbandoc_lst
                                ,pr_nrdctabb_lst => pr_nrdctabb_lst
                                ,pr_nrcnvcob_lst => pr_nrcnvcob_lst
                                ,pr_nrdocmto_lst => pr_nrdocmto_lst
                                ,pr_retxml       => vr_retxml
                                ,pr_dscritic     => vr_dscritic );

  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;
      
  pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                 '<Root><dsmensag>'||vr_retxml||'</dsmensag></Root>');

EXCEPTION
  WHEN vr_exc_saida THEN
   IF vr_cdcritic <> 0 THEN
     vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
   END IF;
   
   pr_dscritic := vr_dscritic;

   pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                  '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  WHEN OTHERS THEN
    cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);
    
    pr_dscritic := 'Erro geral na rotina dsct0004.pc_finalizar_bordero_ib: '||SQLERRM;

    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
END pc_finalizar_bordero_ib;


PROCEDURE pc_obtem_detalhes_bordero_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                      ,pr_nrborder  IN crapbdt.nrborder%TYPE --> Numero do bordero
                                      ,pr_nriniseq  IN NUMBER DEFAULT 0      --> Paginação - Inicio de sequencia
                                      ,pr_nrregist  IN NUMBER DEFAULT 0      --> Paginação - Número de registros
                                      ,pr_retxml   OUT XMLType               --> Arquivo de retorno do XML
                                      ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica

  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_obtem_detalhes_bordero_ib
    Sistema  : Internet Banking IB
    Sigla    : DSCT0004
    Autor    : Paulo Penteado (GFT)
    Data     : Maio/2018
    
    Objetivo  : Visualizar detalhes do borderô quando acionado pelo ícone da coluna "Ação" da tela de Consulta
    SOA       : Recebiveis.obterListaTitulosBordero

    Alteração : 14/05/2018 - Criação (Paulo Penteado (GFT))
                11/10/2018 - Ajuste para retornar a situação dos títulos (Andrew Albuquerque - GFT)
  ---------------------------------------------------------------------------------------------------------------------*/
  vr_tab_tit_bordero tela_atenda_dscto_tit.typ_tab_tit_bordero;
  
  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  
  rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;
BEGIN
  
  -- Leitura do calendario
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    
  IF BTCH0001.cr_crapdat%NOTFOUND THEN
    vr_cdcritic := 1;
    CLOSE BTCH0001.cr_crapdat;
    RAISE vr_exc_saida;
  ELSE
    CLOSE BTCH0001.cr_crapdat;  
  END IF;
  
  OPEN cr_crapbdt(pr_cdcooper => pr_cdcooper
                 ,pr_nrborder => pr_nrborder);
  FETCH cr_crapbdt INTO rw_crapbdt;
  IF cr_crapbdt%NOTFOUND THEN
    -- Fecha Cursor
    CLOSE cr_crapbdt;
    vr_dscritic := 'Borderô de desconto de título '||pr_nrborder||' não encontrado.';
    RAISE vr_exc_saida;
  ELSE
    -- Fecha Cursor
    CLOSE cr_crapbdt;
  END IF;  
  
  pc_calcula_limite_disponivel(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => rw_crapbdt.nrdconta
                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                              ,pr_vllimdis => vr_vllimdis);
  
  tela_atenda_dscto_tit.pc_buscar_tit_bordero(pr_cdcooper        => pr_cdcooper
                                             ,pr_nrdconta        => rw_crapbdt.nrdconta
                                             ,pr_cdagenci        => NULL -- sem utilidade
                                             ,pr_nrdcaixa        => NULL -- sem utilidade
                                             ,pr_cdoperad        => NULL -- sem utilidade
                                             ,pr_idorigem        => NULL -- sem utilidade
                                             ,pr_nrborder        => pr_nrborder
                                             ,pr_nriniseq        => pr_nriniseq
                                             ,pr_nrregist        => pr_nrregist
                                             ,pr_qtregist        => vr_qtregist
                                             ,pr_tab_tit_bordero => vr_tab_tit_bordero
                                             ,pr_cdcritic        => vr_cdcritic
                                             ,pr_dscritic        => vr_dscritic );

  IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  pc_inicia_xml;
  pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                 '<Root><Dados qtregist="'|| vr_qtregist ||'" >');
                 
  pc_escreve_xml('<nrctrlim>'||rw_craplim.nrctrlim||'</nrctrlim>'||
                 '<vllimite>'||trim(to_char(rw_craplim.vllimite,'99999999D99','NLS_NUMERIC_CHARACTERS='',.'''))||'</vllimite>'||
                 '<vllimdis>'||trim(to_char(vr_vllimdis,'99999999D99','NLS_NUMERIC_CHARACTERS='',.'''))||'</vllimdis>');
                     
  pc_escreve_xml('<titulos>');
  vr_index := vr_tab_tit_bordero.first;
  WHILE vr_index IS NOT NULL 
  LOOP
        pc_escreve_xml('<titulo>'||
                         '<nrdocmto>'||vr_tab_tit_bordero(vr_index).nrdocmto||'</nrdocmto>'||
                         '<nrcnvcob>'||vr_tab_tit_bordero(vr_index).nrcnvcob||'</nrcnvcob>'||
                         '<nrborder>'||pr_nrborder||'</nrborder>'||
                         '<nmdsacad>'||vr_tab_tit_bordero(vr_index).nmsacado||'</nmdsacad>'||
                         '<dtvencto>'||to_char(vr_tab_tit_bordero(vr_index).dtvencto,'DD/MM/RRRR')||'</dtvencto>'||
                         '<vltitulo>'||trim(to_char(vr_tab_tit_bordero(vr_index).vltitulo,'99999999D99','NLS_NUMERIC_CHARACTERS='',.'''))||'</vltitulo>'||
                         '<inpreapr>'||CASE WHEN vr_tab_tit_bordero(vr_index).dssituac = 'N' THEN 1 ELSE 0 END||'</inpreapr>'||
                         '<insitbdt>'||rw_crapbdt.insitbdt||'</insitbdt>'||
                         '<insittit>'||vr_tab_tit_bordero(vr_index).insittit||'</insittit>'||
                         '<cdcooper>'||pr_cdcooper||'</cdcooper>'||
                         '<nrdconta>'||rw_crapbdt.nrdconta||'</nrdconta>'||
                         '<cdbandoc>'||vr_tab_tit_bordero(vr_index).cdbandoc||'</cdbandoc>'||
                         '<nrdctabb>'||vr_tab_tit_bordero(vr_index).nrdctabb||'</nrdctabb>'||
                         '<dssittit>'||vr_tab_tit_bordero(vr_index).dssittit||'</dssittit>'||
                       '</titulo>'
                      );
        vr_index := vr_tab_tit_bordero.next(vr_index);
  END LOOP;

  pc_escreve_xml('</titulos></Dados></Root>', TRUE);

  pr_retxml := xmltype.createxml(vr_des_xml);

  pc_finaliza_xml;
EXCEPTION
  WHEN vr_exc_saida THEN
  IF  vr_cdcritic <> 0 THEN
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
  END IF;
  
  pr_dscritic := vr_dscritic;

  pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                            '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  WHEN OTHERS THEN
    cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
  
    pr_dscritic := 'Erro geral na rotina dsct0004.pc_obtem_detalhes_bordero_ib: '||SQLERRM;

    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                  '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
END pc_obtem_detalhes_bordero_ib;


PROCEDURE pc_imprime_bordero_dsctotit_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                        ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da Conta
                                        ,pr_nrborder  IN crapbdt.nrborder%TYPE --> Numero do bordero
                                        ,pr_retxml   OUT XMLType               --> Arquivo de retorno do XML
                                        ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                        ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_obtem_detalhes_bordero_ib
    Sistema  : Internet Banking IB
    Sigla    : DSCT0004
    Autor    : Paulo Penteado (GFT)
    Data     : Maio/2018
    
    Objetivo  : Imprimir informações do borderô quando acionado pelo ícone da coluna "Ação" da tela de Consulta
    SOA       : Recebiveis.obterImpressaoBordero

    Alteração : 14/05/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
  vr_dsdireto VARCHAR2(1000);
  vr_nmarqpdf VARCHAR2(1000);
  vr_dssrvarq VARCHAR2(1000);
  vr_dsdirarq VARCHAR2(1000);

  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000);

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  
  rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;
BEGIN
  
  -- Leitura do calendario
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    
  IF BTCH0001.cr_crapdat%NOTFOUND THEN
    vr_cdcritic := 1;
    CLOSE BTCH0001.cr_crapdat;
    RAISE vr_exc_saida;
  ELSE
    CLOSE BTCH0001.cr_crapdat;  
  END IF;
  
  OPEN  cr_crapbdt(pr_cdcooper => pr_cdcooper
                  ,pr_nrborder => pr_nrborder);
  FETCH cr_crapbdt INTO rw_crapbdt;
  IF    cr_crapbdt%NOTFOUND THEN
        CLOSE cr_crapbdt;
        vr_dscritic := 'Borderô de desconto de título '||pr_nrborder||' não encontrado.';
        RAISE vr_exc_saida;
  END   IF;
  CLOSE cr_crapbdt;

  DSCT0002.pc_gera_impressao_bordero(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagecxa => 0
                                    ,pr_nrdcaixa => 0
                                    ,pr_cdopecxa => 996
                                    ,pr_nmdatela => ''
                                    ,pr_idorigem => 3
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_idseqttl => 1
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                    ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                                    ,pr_inproces => rw_crapdat.inproces
                                    ,pr_idimpres => 7
                                    ,pr_nrborder => pr_nrborder
                                    ,pr_dsiduser => to_char(pr_nrdconta)
                                    ,pr_flgemail => 0
                                    ,pr_flgerlog => 0
                                    ,pr_flgrestr => 0
                                    ,pr_nmarqpdf => vr_nmarqpdf
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);

  IF  nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_saida;
  END IF;

  IF  vr_nmarqpdf IS NOT NULL THEN
      -- Buscar diretorio da cooperativa
      vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C' --> cooper 
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/rl');
  
      gene0002.pc_copia_arq_para_download(pr_cdcooper => pr_cdcooper
                                         ,pr_dsdirecp => vr_dsdireto||'/'
                                         ,pr_nmarqucp => vr_nmarqpdf
                                         ,pr_flgcopia => 0
                                         ,pr_dssrvarq => vr_dssrvarq
                                         ,pr_dsdirarq => vr_dsdirarq
                                         ,pr_des_erro => vr_dscritic);

      IF  TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_saida;
      END IF;
  END IF;

  pc_inicia_xml;
  pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>');
  pc_escreve_xml('<nmarqpdf>'||vr_nmarqpdf||'</nmarqpdf>'||
                 '<dsdirarq>'||vr_dsdirarq||'</dsdirarq>'||
                 '<dssrvarq>'||vr_dssrvarq||'</dssrvarq>');
  pc_escreve_xml('</Dados></Root>', TRUE);

  pr_retxml := xmltype.createxml(vr_des_xml);

  pc_finaliza_xml;

EXCEPTION
  WHEN vr_exc_saida THEN
       IF  vr_cdcritic <> 0 THEN
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       END IF;
       pr_dscritic := vr_dscritic;

       pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  WHEN OTHERS THEN
       cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);  
  
       pr_dscritic := 'Erro geral na rotina dsct0004.pc_imprime_bordero_dsctotit_ib: '||SQLERRM;

       pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
END pc_imprime_bordero_dsctotit_ib;


END DSCT0004;
/
