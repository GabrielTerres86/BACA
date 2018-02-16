CREATE OR REPLACE PACKAGE CECRED.APLI0004 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : APLI0004
  --  Sistema  : Rotinas referentes a tela INDICE
  --  Sigla    : APLI
  --  Autor    : Jean Michel - CECRED
  --  Data     : Maio - 2014.                   Ultima atualizacao: 16/06/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas refente a tela indice
  --
  -- Alteracoes: 25/05/2015 - Inclusao do tratamento na procedure pc_manter taxa
  --                          de cadastro para tipo de taxa mensal sendo o IPCA,
  --                          agora pode-se cadastrar esta taxa em outro mes.
  --
  --             16/06/2016 - Correcao para o uso correto do indice da CRAPTAB em
  --                          varias procedures desta package.(Carlos Rafael Tanholi).
  --
  ---------------------------------------------------------------------------------------------------------------

  /* Rotina geral da tela INDICE */
  PROCEDURE pc_tela_indice(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / I - Inclur / R - Relatório / T - Cadastro de Taxa)
                          ,pr_cddindex IN crapind.cddindex%TYPE --> Codigo do Index
                          ,pr_nmdindex IN crapind.nmdindex%TYPE --> Nome do Index
                          ,pr_dtperiod IN VARCHAR2              --> Data do Periodo
                          ,pr_idperiod IN crapind.idperiod%TYPE --> Indicador de Periodo
                          ,pr_idexpres IN crapind.idexpres%TYPE --> Indice de Taxa Expressa
                          ,pr_idcadast IN crapind.idcadast%TYPE --> Forma de Cadastro
                          ,pr_dtiniper IN VARCHAR2              --> Data do Inicio do Periodo
                          ,pr_dtfimper IN VARCHAR2              --> Data do Fim do Periodo
                          ,pr_vlrdtaxa IN craptxi.vlrdtaxa%TYPE --> Valor da Taxa
                          ,pr_nriniseq IN INTEGER               --> Registro inicial da listagem
                          ,pr_nrregist IN INTEGER               --> Numero de registros p/ paginacao
                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  /* Rotina geral da tela INDICE */
  PROCEDURE pc_carrega_index(pr_cddindex IN crapind.cddindex%TYPE --> Codigo do Index
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  PROCEDURE pc_cadastra_taxa_cdi_mensal(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                       ,pr_cdianual  IN NUMBER                --> Valor do CDI anual
                                       ,pr_dtperiod  IN craptrd.dtiniper%TYPE --> Data do Periodo
                                       ,pr_dtdiaant  IN DATE                  --> Qtd de Dias Anteriores
                                       ,pr_dtdiapos  IN DATE                  --> Quantidade de Proximos dias
                                       ,pr_flatuant  IN BOOLEAN               --> Verifica se deve atualizar p/ dias anteriores
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo de Erro
                                       ,pr_dscritic OUT VARCHAR2);            --> Descricao de Erro

  PROCEDURE pc_grava_taxa_cdi_mensal(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                    ,pr_cdianual  IN NUMBER                --> Valor do CDI Anual
                                    ,pr_dtiniper  IN craptrd.dtiniper%TYPE --> Data de Inicio do Periodo
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo de Erro
                                    ,pr_dscritic OUT VARCHAR2);          --> Descricao de Erro

  PROCEDURE pc_calcula_poupanca(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                               ,pr_qtddiaut  IN INTEGER               --> Quantidade de dias uteis
                               ,pr_vlmoefix  IN crapmfx.vlmoefix%TYPE --> Valor da Moeda
                               ,pr_txmespop OUT craptrd.txofimes%TYPE --> Taxa do Mes
                               ,pr_txdiapop OUT craptrd.txofidia%TYPE --> Taxa do Dia
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo de Erro
                               ,pr_dscritic OUT VARCHAR2);            --> Descricao de Erro

  -- Validacao de datas
  PROCEDURE pc_valida_data(pr_cddindex IN crapind.cddindex%TYPE --> Codigo do Indexador
                          ,pr_dtperiod IN VARCHAR2              --> Data do Periodo
                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Insercao e atualizacao de taxas
  PROCEDURE pc_manter_taxa(pr_cddopcao IN VARCHAR2              -- Codigo da opcao
                          ,pr_cddindex IN craptxi.cddindex%TYPE --> Codigo do Indexador
                          ,pr_dtperiod IN VARCHAR2              --> Data do Periodo
                          ,pr_vlrdtaxa IN craptxi.vlrdtaxa%TYPE --> Valor da Taxa do Indexador
                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Insercao de DI
  PROCEDURE pc_cadastra_taxa_cdi(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                ,pr_dtmvtolt IN crapmfx.dtmvtolt%TYPE --> Data de Movimentacao
                                ,pr_vlmoefix IN crapmfx.vlmoefix%TYPE --> Valor da Moeda
                                ,pr_tpmoefix IN crapmfx.tpmoefix%TYPE --> Tipo da Moeda
                                ,pr_cdprogra IN crapprg.cdprogra%TYPE --> Programa Chamador
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica

  -- Alteracao de DI
  PROCEDURE pc_altera_taxa_cdi(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                              ,pr_dtmvtolt IN crapmfx.dtmvtolt%TYPE --> Data de Movimentacao
                              ,pr_vlmoefix IN crapmfx.vlmoefix%TYPE --> Valor da Moeda
                              ,pr_tpmoefix IN crapmfx.tpmoefix%TYPE --> Tipo da Moeda
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica

  -- Cadastro de taxa CDI acumulada
  PROCEDURE pc_cadastra_taxa_cdi_acumulado(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                          ,pr_cdianual  IN NUMBER                --> Valor do CDI anual
                                          ,pr_dtperiod  IN craptrd.dtiniper%TYPE --> Data do Periodo
                                          ,pr_dtdiaant  IN DATE                  --> Qtd de Dias Anteriores
                                          ,pr_dtdiapos  IN DATE                  --> Quantidade de Proximos dias
                                          ,pr_flatuant  IN BOOLEAN               --> Verifica se deve atualizar p/ dias anteriores
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo de Erro
                                          ,pr_dscritic OUT VARCHAR2);            --> Descricao de Erro

  -- Calculo de poupanca
  PROCEDURE pc_poupanca(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                       ,pr_dtperiod  IN craptrd.dtiniper%TYPE --> Data do Periodo
                       ,pr_vltaxatr  IN crapmfx.vlmoefix%TYPE --> Valor taxa TR
                       ,pr_vlpoupan OUT crapmfx.vlmoefix%TYPE --> Valor taxa Poupanca
                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo de Erro
                       ,pr_dscritic OUT VARCHAR2);            --> Descricao de Erro

  /* Rotina de calculo de quantidade de dias uteis */
  PROCEDURE pc_calcula_qt_dias_uteis(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                    ,pr_dtperiod IN DATE                  --> Data do Periodo
                                    ,pr_qtdiaute OUT PLS_INTEGER          --> Quantidade de dias uteis
                                    ,pr_dtfimper OUT DATE                 --> Data do fim do periodo
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2 );          --> Descrição da crítica

  /* Atualizar a taxa de Poupança para todas as Cooperativas */                                    
  PROCEDURE pc_atualiza_sol026(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da Cooperativa
                              ,pr_dtperiod IN DATE                   --> Data do Periodo
                              ,pr_vlpoupan IN crapmfx.vlmoefix%TYPE --> Valor taxa Poupanca
                              ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica 
  
  /* Atualiza taxa TR */
  PROCEDURE pc_atualiza_tr(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                          ,pr_dtperiod IN DATE                  --> Data do Periodo
                          ,pr_txrefmes IN NUMBER                --> Valor taxa mes
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica    
  
  /* Atualiza taxas referente a poupanca */
  PROCEDURE pc_atualiza_taxa_poupanca(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                     ,pr_dtmvtolt IN DATE                  --> Data do Periodo
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica

  /* Rotina de consulta de tipo de data do indexador */
  PROCEDURE pc_verifica_tipo_data(pr_cddindex IN crapind.cddindex%TYPE --> Codigo do Indexador
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);
END APLI0004;
/
CREATE OR REPLACE PACKAGE BODY CECRED.APLI0004 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : APLI0004
  --  Sistema  : Rotinas referentes a tela INDICE
  --  Sigla    : APLI
  --  Autor    : Jean Michel - CECRED
  --  Data     : Maio - 2014.                   Ultima atualizacao: 27/09/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas refente a tela indice
  --
  -- Alteracoes: 25/05/2015 - Inclusao do tratamento na procedure pc_manter taxa
  --                          de cadastro para tipo de taxa mensal sendo o IPCA,
  --                          agora pode-se cadastrar esta taxa em outro mes.
  --
  --             16/06/2016 - Correcao para o uso correto do indice da CRAPTAB em
  --                          varias procedures desta package.(Carlos Rafael Tanholi).
  --
  --             27/09/2017 - Inclusão do módulo e ação logado no oracle
  --                        - Inclusão da chamada de procedure em exception others
  --                        - Colocado logs no padrão
  --                          (Ana - Envolti - Chamado 744573)
  ---------------------------------------------------------------------------------------------------------------

  vr_dsmsglog  VARCHAR2(4000); -- Mensagem de log
  vr_idprglog  tbgen_prglog.idprglog%TYPE := 0;
  vr_cdprogra  CONSTANT crapprg.cdprogra%TYPE := 'APLI0004';
  
  -- Selecionar os dados da Cooperativa
  CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
  SELECT cop.cdcooper
        ,cop.nmrescop
        ,cop.nrtelura
        ,cop.cdbcoctl
        ,cop.cdagectl
        ,cop.dsdircop
    FROM crapcop cop
   WHERE (cop.cdcooper = pr_cdcooper OR pr_cdcooper = 0)
     AND cop.flgativo = 1;
  
  /* Cursor generico de calendario */
  CURSOR cr_crapdat(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT dat.dtmvtolt
          ,dat.dtmvtopr
          ,dat.dtmvtoan
          ,dat.inproces
          ,dat.qtdiaute
          ,dat.cdprgant
          ,dat.dtmvtocd
          ,last_day(add_months(dat.dtmvtolt,-1)) dtultdma -- Ult. Dia Mes Ant.
          ,last_day(dat.dtmvtolt)                dtultdia -- Utl. Dia Mes Corr.
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
    
  -- Selecionar os dados de indexadores pelo codigo
  CURSOR cr_crapind_cod(pr_cddindex IN crapind.cddindex%TYPE) IS
    SELECT
      ind.cddindex
     ,ind.nmdindex
     ,ind.idperiod
     ,ind.idcadast
     ,ind.idexpres
    FROM
      crapind ind
    WHERE
      ind.cddindex = pr_cddindex;

  rw_crapind_cod cr_crapind_cod%ROWTYPE;

  /* Rotina referente as acoes da tela INDICE */
  PROCEDURE pc_tela_indice(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / I - Inclur / R - Relatório / T - Cadastro de Taxa)
                          ,pr_cddindex IN crapind.cddindex%TYPE --> Codigo do Index
                          ,pr_nmdindex IN crapind.nmdindex%TYPE --> Nome do Index
                          ,pr_dtperiod IN VARCHAR2              --> Data do Periodo
                          ,pr_idperiod IN crapind.idperiod%TYPE --> Indicador de Periodo
                          ,pr_idexpres IN crapind.idexpres%TYPE --> Indice de Taxa Expressa
                          ,pr_idcadast IN crapind.idcadast%TYPE --> Forma de Cadastro
                          ,pr_dtiniper IN VARCHAR2              --> Data do Inicio do Periodo
                          ,pr_dtfimper IN VARCHAR2              --> Data do Fim do Periodo
                          ,pr_vlrdtaxa IN craptxi.vlrdtaxa%TYPE --> Valor da Taxa
                          ,pr_nriniseq IN INTEGER               --> Registro inicial da listagem
                          ,pr_nrregist IN INTEGER               --> Numero de registros p/ paginaca
                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN

    /* .............................................................................

     Programa: pc_tela_indice
     Sistema : Cartoes de Credito - Cooperativa de Credito
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Maio/14.                    Ultima atualizacao: 27/09/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina geral de CRUD da tela INDICE.

     Observacao: -----

     Alteracoes: 27/09/2017 - Inclusão do módulo e ação logado no oracle
                            - Inclusão da chamada de procedure em exception others
                            - Colocado logs no padrão
                              (Ana - Envolti - Chamado 744573)
     ..............................................................................*/
    DECLARE
    
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Selecionar os dados de indexadores pelo nome
      CURSOR cr_crapind_nom(pr_nmdindex IN crapind.nmdindex%TYPE) IS
        SELECT
          ind.cddindex
         ,ind.nmdindex
         ,ind.idperiod
         ,ind.idcadast
         ,ind.idexpres
        FROM
          crapind ind
        WHERE
          UPPER(ind.nmdindex) = UPPER(pr_nmdindex);

      rw_crapind_nom cr_crapind_nom%ROWTYPE;

      -- Selecionar os dados de indexadores pelo codigo e data da taxa
      CURSOR cr_craptxi(pr_cddindex IN craptxi.cddindex%TYPE
                       ,pr_dtiniper IN craptxi.dtiniper%TYPE) IS
        SELECT
          txi.cddindex
         ,txi.dtiniper
         ,txi.dtfimper
         ,txi.vlrdtaxa
         ,txi.dtcadast
         ,txi.progress_recid
        FROM
          craptxi txi
        WHERE
              txi.cddindex = pr_cddindex  -- Codigo do indexador
          AND txi.dtiniper = pr_dtiniper; -- Data inicial da taxa

      rw_craptxi cr_craptxi%ROWTYPE;

      -- Selecionar os dados de produtos
      CURSOR cr_crapcpc(pr_cddindex IN craptxi.cddindex%TYPE) IS

        SELECT
          cpc.cddindex
         ,cpc.nmprodut
        FROM
          crapcpc cpc
        WHERE
          cpc.cddindex = pr_cddindex;  -- Codigo do indexador

      rw_crapcpc cr_crapcpc%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      vr_tab_erro GENE0001.typ_tab_erro; --> Tabela com erros

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_null      EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_cddindex crapind.cddindex%TYPE;

      vr_dopcaoan VARCHAR2(2)   := '';
      vr_cddopcao VARCHAR2(2)   := '';
      vr_frmcadas VARCHAR2(100) := 'MANUAL,AUTOMATICA';
      vr_txexpres VARCHAR2(100) := 'AO MES,AO ANO';
      vr_periodic VARCHAR2(100) := 'DIARIA,MENSAL,ANUAL';
      vr_mesanter VARCHAR2(2)   := '';
      vr_dsarqsai VARCHAR2(100) := '';
      vr_diretori VARCHAR2(100) := '';
      vr_nmarqpdf VARCHAR2(100) := '';
      
      vr_dtiniper DATE;
      vr_dtfimper DATE;
      vr_auxdtini DATE;
      vr_auxdtfim DATE;

      vr_contador INTEGER := 0; -- Contador p/ posicao no XML
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
      vr_idexpres INTEGER := 0; -- Tipo de Taxa expressa (1-Mes/2-Ano)
      vr_indicmes INTEGER := 0; -- Indicador de mes para opcao "C"

      vr_vlrdtxdi NUMBER(20,8) := 0; -- Valor de taxa diaria
      vr_vlrdtxme NUMBER(20,8) := 0; -- Valor de taxa mensal
      vr_vlrdtxan NUMBER(20,8) := 0; -- Valor de taxa anual
      vr_vlrdtxac NUMBER(20,8) := 0; -- Valor de taxa acumulada
      vr_diautmes INTEGER      := 0; -- Dias Úteis Mês
      vr_flgprodu INTEGER      := 0; -- Indicador se indexador é utilizado por produto

      vr_dscdtxdi VARCHAR2(15) := '';
      vr_dscdtxme VARCHAR2(15) := '';
      vr_dscdtxan VARCHAR2(15) := '';
      vr_dscdtxac VARCHAR2(15) := '';

      vr_flgresgi BOOLEAN := FALSE;
      vr_clobxml CLOB;

      BEGIN
        -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
        GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'APLI0004.pc_tela_indice');
        
        vr_cddopcao := pr_cddopcao;

        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

        IF vr_cdcooper <> 3 AND
           vr_cddopcao NOT IN ('C','R') THEN
          vr_dscritic := 'Alteracao somente pela CENTRAL.';   
          RAISE vr_exc_saida;
        END IF;

        -- Verifica se a cooperativa esta cadastrada
       OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);

       FETCH btch0001.cr_crapdat INTO rw_crapdat;
       -- Se não encontrar
       IF btch0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE btch0001.cr_crapdat;
         -- Montar mensagem de critica
         vr_cdcritic:= 1;
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE btch0001.cr_crapdat;
       END IF;

        IF vr_cddopcao <> 'I' THEN
          OPEN cr_crapind_cod(pr_cddindex);
          FETCH cr_crapind_cod
          INTO rw_crapind_cod;

          -- Se não encontrar
          IF cr_crapind_cod%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_crapind_cod;
            vr_dscritic := 'Indexador Inexistente:'||pr_cddindex;
            RAISE vr_exc_saida;
          ELSE
            -- Fechar o cursor
            CLOSE cr_crapind_cod;
          END IF;
        ELSE

          OPEN cr_crapind_nom(pr_nmdindex);
          FETCH cr_crapind_nom
          INTO rw_crapind_nom;

          -- Se não encontrar
          IF cr_crapind_nom%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_crapind_nom;
          ELSE
            -- Fechar o cursor
            CLOSE cr_crapind_nom;
            vr_dscritic := 'Indexador Existente.';
            RAISE vr_exc_saida;
          END IF;
        END IF;        

        vr_idexpres := rw_crapind_cod.idexpres;

        -- Verifica se datas passadas por parametros
        IF pr_dtiniper <> '0' OR pr_dtfimper <> '0' THEN

          IF LENGTH(pr_dtiniper) > 4 THEN
            vr_dtiniper := to_date('01/' || pr_dtiniper, 'DD/MM/RRRR');
            vr_dtfimper := last_day(to_date('01/' || pr_dtfimper, 'DD/MM/RRRR'));
          ELSE
            vr_dtiniper := to_date('01/01/' || pr_dtiniper, 'DD/MM/RRRR');
            vr_dtfimper := last_day(to_date('01/01/' || pr_dtfimper, 'DD/MM/RRRR'));
          END IF;
          
        END IF;   

        IF vr_cddopcao = 'R' THEN

          -- Recebe opcao que foi passada por parametro
          vr_dopcaoan := vr_cddopcao;
          vr_cddopcao := 'C';          

        END IF;

        -- Verifica o tipo de acao que sera executada
        CASE vr_cddopcao

          WHEN 'A' THEN -- Alteracao
            
            OPEN cr_crapcpc(pr_cddindex => pr_cddindex);

            FETCH cr_crapcpc INTO rw_crapcpc;

            IF cr_crapcpc%NOTFOUND THEN
              vr_flgprodu := 0;
            ELSE
              vr_flgprodu := 1;
            END IF;

            CLOSE cr_crapcpc;

            IF pr_idcadast = 0 THEN
              -- Criar cabeçalho do XML
              pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cddindex', pr_tag_cont => rw_crapind_cod.cddindex, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nmdindex', pr_tag_cont => rw_crapind_cod.nmdindex, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'idperiod', pr_tag_cont => rw_crapind_cod.idperiod, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'idcadast', pr_tag_cont => rw_crapind_cod.idcadast, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'idexpres', pr_tag_cont => rw_crapind_cod.idexpres, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'flgprodu', pr_tag_cont => vr_flgprodu, pr_des_erro => vr_dscritic);

            ELSE

              OPEN cr_crapind_cod(pr_cddindex);
              FETCH cr_crapind_cod
              INTO rw_crapind_cod;

              -- Se não encontrar
              IF cr_crapind_cod%NOTFOUND THEN
                -- Fechar o cursor
                CLOSE cr_crapind_cod;
                vr_dscritic := 'Indexador Inexistente - 1:'||pr_cddindex;
                RAISE vr_exc_saida;
              ELSE
                -- Fechar o cursor
                CLOSE cr_crapind_cod;
              END IF;

              BEGIN
                UPDATE crapind
                SET idperiod = pr_idperiod, idcadast = pr_idcadast, idexpres = pr_idexpres
                WHERE cddindex = pr_cddindex;
              -- Verifica se houve problema na atualizacao do registro
              EXCEPTION
                WHEN OTHERS THEN
                -- Descricao do erro na atualizacao de registros
                vr_dscritic := 'Erro ao atualizar Indexador: idperiod:'||pr_idperiod
                             ||', idcadast:'||pr_idcadast||', idexpres:'||pr_idexpres
                             ||' com cddindex:'||pr_cddindex||'. '||SQLERRM;
                RAISE vr_exc_saida;
              END;
              
              vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') || ' -> Operador: ' || vr_cdoperad;
              vr_dsmsglog := vr_dsmsglog || ' - Alterou indexador: ' || pr_cddindex || ' - ' || rw_crapind_cod.nmdindex;
              
              IF pr_idperiod <> rw_crapind_cod.idperiod THEN
                
                vr_dsmsglog := vr_dsmsglog || ', periodicidade de: ' || gene0002.fn_busca_entrada(pr_postext     => rw_crapind_cod.idperiod
                                                                                                 ,pr_dstext      => vr_periodic
                                                                                                 ,pr_delimitador => ',')
                || ' para: ' || gene0002.fn_busca_entrada(pr_postext => pr_idperiod
                                                         ,pr_dstext      => vr_periodic
                                                         ,pr_delimitador => ',');
              END IF;

              IF pr_idcadast <> rw_crapind_cod.idcadast THEN
                vr_dsmsglog := vr_dsmsglog || ', forma de cadastro de: ' || gene0002.fn_busca_entrada(pr_postext     => rw_crapind_cod.idcadast
                                                                                                     ,pr_dstext      => vr_frmcadas
                                                                                                     ,pr_delimitador => ',')
                || ' para: ' || gene0002.fn_busca_entrada(pr_postext     => pr_idcadast
                                                         ,pr_dstext      => vr_frmcadas
                                                         ,pr_delimitador => ',');
              END IF;

              IF pr_idexpres <> rw_crapind_cod.idexpres THEN
                vr_dsmsglog := vr_dsmsglog || ', taxa expressa de: ' || gene0002.fn_busca_entrada(pr_postext     => rw_crapind_cod.idexpres
                                                                                                 ,pr_dstext      => vr_txexpres
                                                                                                 ,pr_delimitador => ',')
                || ' para: ' || gene0002.fn_busca_entrada(pr_postext     => pr_idexpres
                                                         ,pr_dstext      => vr_txexpres
                                                         ,pr_delimitador => ',');
              END IF;

              vr_dsmsglog := vr_dsmsglog || '.';

            END IF;

          WHEN 'C' THEN -- Consulta
            
            IF vr_dtfimper < vr_dtiniper THEN
              vr_dscritic := 'Data de início deve ser menor que data final.';
              RAISE vr_exc_saida;
            ELSE
              
              IF rw_crapind_cod.idperiod = 1 THEN -- Diario
                IF (vr_dtfimper - vr_dtiniper) > 92 THEN -- 3 Meses
                  vr_dscritic := 'Data do periodo informado nao deve ser maior que 3 meses.';
                  RAISE vr_exc_saida;
                END IF;
              ELSIF rw_crapind_cod.idperiod = 2 THEN -- Mensal
                IF (vr_dtfimper - vr_dtiniper) > 2928 THEN -- 8 anos
                  vr_dscritic := 'Data do periodo informado nao deve ser maior que 8 anos.';
                  RAISE vr_exc_saida;
                END IF;
              END IF;

            END IF;

            -- Criar cabeçalho do XML
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'Dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'index', pr_tag_cont => pr_cddindex || ' - ' || rw_crapind_cod.nmdindex, pr_des_erro => vr_dscritic);
            -- Inicializa valor de mes anterior
            vr_mesanter := 0;

            OPEN cr_crapind_cod(pr_cddindex);
            FETCH cr_crapind_cod
            INTO rw_crapind_cod;

            -- Se não encontrar
            IF cr_crapind_cod%NOTFOUND THEN
              -- Fechar o cursor
              CLOSE cr_crapind_cod;
              vr_dscritic := 'Indexador Inexistente - 2:'||pr_cddindex;
              RAISE vr_exc_saida;
            ELSE
              -- Fechar o cursor
              CLOSE cr_crapind_cod;
            END IF;

            WHILE vr_dtiniper <= vr_dtfimper LOOP
              
              /*IF rw_crapind_cod.idperiod IN(1) THEN
                vr_dtiniper := gene0005.fn_valida_dia_util(pr_cdcooper => vr_cdcooper
                                                          ,pr_dtmvtolt => vr_dtiniper
                                                          ,pr_tipo => 'P');                                          
              END IF;*/
                                          
              IF vr_dtiniper > vr_dtfimper THEN
                CONTINUE;
              END IF;
             
              IF to_char(vr_dtiniper,'mm') <> vr_mesanter THEN
                vr_mesanter := to_char(vr_dtiniper,'mm');
                vr_auxdtini := TO_DATE(TRUNC(vr_dtiniper,'mm'), 'DD/MM/RRRR');
                vr_indicmes := 1;
                vr_vlrdtxac := 0;
              ELSE
                vr_auxdtini := TO_DATE(TRUNC(vr_dtiniper,'mm'), 'DD/MM/RRRR');
                vr_indicmes := 0;
              END IF;
                                      
              -- Consulta no cursor craptxi
              OPEN cr_craptxi(pr_cddindex => pr_cddindex
                             ,pr_dtiniper => vr_dtiniper);

              FETCH cr_craptxi INTO rw_craptxi;

              -- Antes verificar tipo de taxa          
              IF cr_craptxi%NOTFOUND THEN
                CLOSE cr_craptxi;
                vr_dtiniper := vr_dtiniper + 1;
                CONTINUE;
              ELSE
                CLOSE cr_craptxi;
              END IF;               

              -- Verifica quantidade de dias uteis mês
              apli0004.pc_calcula_qt_dias_uteis(pr_cdcooper => vr_cdcooper,
                                                pr_dtperiod => vr_auxdtini,
                                                pr_qtdiaute => vr_diautmes,
                                                pr_dtfimper => vr_auxdtfim,
                                                pr_cdcritic => vr_cdcritic,
                                                pr_dscritic => vr_dscritic);

              -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
              GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0004.pc_tela_indice');

              IF vr_idexpres = 1 THEN -- Taxa expressa ao mês
                vr_vlrdtxme := NVL(rw_craptxi.vlrdtaxa,0);
                vr_vlrdtxan := ROUND((POWER((vr_vlrdtxme / 100) + 1, 12) - 1) * 100, 8);
                vr_vlrdtxdi := ROUND((POWER((vr_vlrdtxan / 100) + 1, 1 / 252) - 1) * 100, 8);
              ELSIF vr_idexpres = 2 THEN -- Taxa expressa ao ano
                vr_vlrdtxan := NVL(rw_craptxi.vlrdtaxa,0);
                vr_vlrdtxme := ROUND((POWER((vr_vlrdtxan / 100) + 1, vr_diautmes / 252) - 1) * 100, 8);
                vr_vlrdtxdi := ROUND((POWER((vr_vlrdtxan / 100) + 1, 1 / 252) - 1) * 100, 8);
                
              END IF;
 
              -- Verifica se é primeiro dia util do mes
              IF vr_indicmes = 1 THEN
                vr_vlrdtxac := vr_vlrdtxac + vr_vlrdtxdi;
              ELSE
                vr_vlrdtxac := ROUND(((((vr_vlrdtxdi / 100) + 1) * ((vr_vlrdtxac / 100) + 1)) - 1) * 100, 8);
              END IF;

              vr_vlrdtxdi := NVL(vr_vlrdtxdi,0);
              vr_vlrdtxme := NVL(vr_vlrdtxme,0);
              vr_vlrdtxan := NVL(vr_vlrdtxan,0);
              vr_vlrdtxac := NVL(vr_vlrdtxac,0);
            
              vr_contador := vr_contador + 1;

              IF ((vr_contador >= pr_nriniseq) AND (vr_contador < (pr_nriniseq + pr_nrregist))) THEN

                vr_dscdtxdi := REPLACE(TO_CHAR(vr_vlrdtxdi,'fm999990d00000000'),'.',',');
                vr_dscdtxme := REPLACE(TO_CHAR(vr_vlrdtxme,'fm999990d00000000'),'.',',');
                vr_dscdtxan := REPLACE(TO_CHAR(vr_vlrdtxan,'fm999990d00000000'),'.',',');
                vr_dscdtxac := REPLACE(TO_CHAR(vr_vlrdtxac,'fm999990d00000000'),'.',',');
                
                gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
                gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtperiod', pr_tag_cont => TO_CHAR(vr_dtiniper,'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
                gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vlrdtxdi', pr_tag_cont => vr_dscdtxdi, pr_des_erro => vr_dscritic);
                gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vlrdtxme', pr_tag_cont => vr_dscdtxme, pr_des_erro => vr_dscritic);
                gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vlrdtxan', pr_tag_cont => vr_dscdtxan, pr_des_erro => vr_dscritic);
                gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vlrdtxac', pr_tag_cont => vr_dscdtxac, pr_des_erro => vr_dscritic);
                vr_auxconta := vr_auxconta + 1;
              END IF;
              
              vr_dtiniper := vr_dtiniper + 1;
              vr_flgresgi := TRUE;

            END LOOP;
            
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'Qtdregis', pr_tag_cont => vr_contador, pr_des_erro => vr_dscritic);

            IF NOT vr_flgresgi THEN
              vr_dscritic := 'Indexador nao cadastrado para o periodo informado.';
              RAISE vr_exc_saida;
            END IF;

            IF vr_dopcaoan = 'R' THEN

              -- Arquivo de impressao
              vr_dsarqsai := dbms_random.string('a',20) || '.lst';

              -- DIRETORIO QUE SERA GERADO O ARQUIVO FINAL
              vr_diretori := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                                  ,pr_cdcooper => vr_cdcooper
                                                  ,pr_nmsubdir => 'rl');

              vr_clobxml := pr_retxml.getclobval();

              -- SOLICITACAO DO RELATORIO
              gene0002.pc_solicita_relato(pr_cdcooper  => vr_cdcooper         --> Cooperativa
                                         ,pr_cdprogra  => 'INDICE'            --> Programa chamador
                                         ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                         ,pr_dsxml     => vr_clobxml          --> Arquivo XML de dados
                                         ,pr_dsxmlnode => '//Root/Dados/inf'  --> Nó do XML para iteração
                                         ,pr_dsjasper  => 'crrl690.jasper'      --> Arquivo de layout do iReport
                                         ,pr_dsparams  => ''                  --> Array de parametros diversos
                                         ,pr_dsarqsaid => vr_diretori || '/' || vr_dsarqsai         --> Path/Nome do arquivo PDF gerado
                                         ,pr_flg_gerar => 'S'                 --> Gerar o arquivo na hora*
                                         ,pr_qtcoluna  => 80                  --> Qtd colunas do relatório (80,132,234)
                                         ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)*
                                         ,pr_nmformul  => '80col'             --> Nome do formulário para impressão
                                         ,pr_nrcopias  => 1                   --> Qtd de cópias
                                         ,pr_des_erro  => vr_dscritic);       --> Saída com erro
                                              
              -- VERIFICA SE OCORREU UMA CRITICA
              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_saida;
              ELSE
                gene0002.pc_envia_arquivo_web(pr_cdcooper => vr_cdcooper   -- Codigo Cooperativa
                                             ,pr_cdagenci => vr_cdagenci   -- Codigo Agencia
                                             ,pr_nrdcaixa => vr_nrdcaixa   -- Numero do Caixa
                                             ,pr_nmarqimp => vr_dsarqsai   -- Nome Arquivo Impressao
                                             ,pr_nmdireto => vr_diretori   -- Nome Diretorio
                                             ,pr_nmarqpdf => vr_nmarqpdf   -- Nome Arquivo PDF
                                             ,pr_des_reto => vr_dscritic   -- Retorno OK/NOK
                                             ,pr_tab_erro => vr_tab_erro); -- Tabela Erros

                IF vr_dscritic = 'NOK' THEN
                  --Se tem erro na tabela 
                  IF vr_tab_erro.count > 0 THEN
                    vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                    vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                  ELSE
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Erro ao executar APLI0004.pc_tela_indice.';  
                  END IF;  
                  --Levantar Excecao
                  RAISE vr_exc_saida;
                END IF;                             
              END IF;

              -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
              GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0004.pc_tela_indice');

              -- Criar cabeçalho do XML
              pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'nmarqpdf', pr_tag_cont => vr_nmarqpdf, pr_des_erro => vr_dscritic);

            END IF;

          WHEN 'I' THEN -- Inclusao

            BEGIN
               INSERT INTO crapind(nmdindex, idperiod, idcadast, idexpres)
                 VALUES(pr_nmdindex, pr_idperiod, pr_idcadast, pr_idexpres)
                 RETURNING crapind.cddindex INTO vr_cddindex;
            -- Verifica se houve problema na insercao de registros
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Erro ao inserir Vinculacao de Transacao: nmdindex:'||pr_nmdindex
                                ||', idperiod:'||pr_idperiod||', idcadast:'||pr_idcadast
                                ||', idexpres:'||pr_idexpres||'. '||SQLERRM;
                RAISE vr_exc_saida;
            END;

            vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') || ' -> Operador: ' || vr_cdoperad;

            vr_dsmsglog := vr_dsmsglog || ' - incluiu novo indexador: codigo: ' || vr_cddindex || ', nome: ' || pr_nmdindex;
            vr_dsmsglog := vr_dsmsglog || ', periodicidade: ' || gene0002.fn_busca_entrada(pr_postext     => pr_idperiod
                                                                                          ,pr_dstext      => vr_periodic
                                                                                          ,pr_delimitador => ',');

            vr_dsmsglog := vr_dsmsglog || ', forma de cadastro: ' || gene0002.fn_busca_entrada(pr_postext => pr_idcadast
                                                                                          ,pr_dstext      => vr_frmcadas
                                                                                          ,pr_delimitador => ',');

            vr_dsmsglog := vr_dsmsglog || ', taxa expressa: ' || gene0002.fn_busca_entrada(pr_postext     => pr_idexpres
                                                                                          ,pr_dstext      => vr_txexpres
                                                                                          ,pr_delimitador => ',') || '.';

          WHEN 'T' THEN -- Cadastro de Taxa de Indexador
            BEGIN

             -- Criar cabeçalho do XML
               pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
               gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
               gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'idperiod', pr_tag_cont => rw_crapind_cod.idperiod, pr_des_erro => vr_dscritic);

            -- Verifica se houve problema na insercao de registros
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na insercao de registros
                vr_dscritic := 'Problema ao inserir Vinculacao de Transacao: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
        END CASE;

        IF vr_dsmsglog IS NOT NULL THEN

          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                    ,pr_cdprograma   => vr_cdprogra
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => 'indice');
        END IF;

        COMMIT;

    EXCEPTION
      WHEN vr_null THEN
        NULL;
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela INDICE: '||SQLERRM;

        --Inclusão na tabela de erros Oracle - Chamado 744573
        CECRED.pc_internal_exception( pr_cdcooper => vr_cdcooper );

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_tela_indice;

  /* Rotina referente a consulta de index cadastrados */
  PROCEDURE pc_carrega_index(pr_cddindex IN crapind.cddindex%TYPE --> Codigo do Index
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN

    /* .............................................................................

     Programa: pc_carrega_index
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Maio/14.                    Ultima atualizacao: 27/09/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta de indexadores cadastrados.

     Observacao: -----

     Alteracoes: 27/09/2017 - Inclusão do módulo e ação logado no oracle
                            - Inclusão da chamada de procedure em exception others
                            - Colocado logs no padrão
                              (Ana - Envolti - Chamado 744573)
     ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_contador INTEGER := 0;

      -- Selecionar as administradoras de cartao
      CURSOR cr_crapind (pr_cddindex IN crapind.cddindex%TYPE) IS
      SELECT
        ind.cddindex,
        ind.nmdindex,
        ind.idperiod,
        ind.idcadast,
        ind.idexpres
      FROM
        crapind ind
      WHERE
        ind.cddindex = pr_cddindex OR pr_cddindex = 0
      ORDER BY
        ind.nmdindex;

       rw_crapind cr_crapind%ROWTYPE;

      BEGIN
        -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
        GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'APLI0004.pc_carrega_index');

        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

        --Busca administradoras de cartao
        OPEN cr_crapind(pr_cddindex);

        LOOP
          FETCH cr_crapind INTO rw_crapind;

          -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
          EXIT WHEN cr_crapind%NOTFOUND;

          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cddindex', pr_tag_cont => rw_crapind.cddindex, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmdindex', pr_tag_cont => rw_crapind.nmdindex, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idperiod', pr_tag_cont => rw_crapind.idperiod, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idcadast', pr_tag_cont => rw_crapind.idcadast, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idexpres', pr_tag_cont => rw_crapind.idexpres, pr_des_erro => vr_dscritic);
          vr_contador := vr_contador + 1;

        END LOOP;
        CLOSE cr_crapind;

        COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_carrega_index: '||SQLERRM;

        --Inclusão na tabela de erros Oracle - Chamado 744573
        CECRED.pc_internal_exception( pr_cdcooper => 3 );

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_carrega_index;

  /* Rotina de cadastro de taxa cdi mensal */
  PROCEDURE pc_cadastra_taxa_cdi_mensal(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                    	 ,pr_cdianual IN NUMBER                 --> Valor da taxa
                                       ,pr_dtperiod IN craptrd.dtiniper%TYPE  --> Data do periodo
                                       ,pr_dtdiaant IN DATE                   --> Dia util anterior
                                       ,pr_dtdiapos IN DATE                   --> Proximo dia util
                                       ,pr_flatuant IN BOOLEAN                --> Verifica se deve atualizar p/ dias anteriores
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo de Erro
                                       ,pr_dscritic OUT VARCHAR2) IS          --> Descricao de Erro

  BEGIN
    /* .............................................................................

    Programa: pc_cadastra_taxa_cdi_mensal        (Antigo: b1wgen0128.p/cadastra_taxa_cdi_mensal)
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : APLI
    Autor   : Desconhecido
    Data    : ##/##/####                        Ultima atualizacao: 27/09/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina de cadastro da taxa de CDI mensal

    Alteracoes: 30/03/2012 - Alterar para cadastrar a cadastra_taxa_cdi_mensal
                             e cadastra_taxa_cdi_acumulado no ultimo dia do
                             mes, caso o ultimo nao for dia util (Ze).

                20/05/2014 - Conversão Progress >> PLSQL (Jean Michel).

                27/09/2017 - Inclusão do módulo e ação logado no oracle
                           - Inclusão da chamada de procedure em exception others
                           - Colocado logs no padrão
                             (Ana - Envolti - Chamado 744573)
    ............................................................................. */
    DECLARE
      vr_exc_saida EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      vr_contador INTEGER := 0;
      vr_contdias INTEGER := 0;
      vr_dtiniper DATE;
      vr_dtultdia DATE;
      -- CURSORES
      CURSOR cr_crapmfx(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapmfx.dtmvtolt%TYPE
                       ,pr_tpmoefix IN crapmfx.tpmoefix%TYPE) IS
      SELECT
        mfx.cdcooper
       ,mfx.dtmvtolt
       ,mfx.tpmoefix
       ,mfx.vlmoefix
       ,ROWID
      FROM
       crapmfx mfx
      WHERE
        mfx.cdcooper = pr_cdcooper  AND -- Codigo da Cooperativa
        mfx.dtmvtolt = pr_dtmvtolt  AND -- Data de Inicio do Periodo
        mfx.tpmoefix = pr_tpmoefix;     -- Tipo da Moeda

       rw_crapmfx cr_crapmfx%ROWTYPE;

    BEGIN
      -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
      GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'APLI0004.pc_cadastra_taxa_cdi_mensal');

      -- Verifica dias anteriores
      IF pr_flatuant THEN -- Certifica se deve atualizar p/ dias ant.

        vr_contador := (pr_dtperiod - pr_dtdiaant);

        IF vr_contador > 1 THEN

         OPEN cr_crapmfx(pr_cdcooper, pr_dtdiaant, 6);
            FETCH cr_crapmfx
            INTO rw_crapmfx;

          -- Se não encontrar insere novo registro
          IF cr_crapmfx%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_crapmfx;
          ELSE
            -- Fechar o cursor
            CLOSE cr_crapmfx;
            vr_contdias := 1;
            LOOP

              EXIT WHEN vr_contdias > vr_contador - 1;

              vr_dtiniper := pr_dtdiaant + vr_contdias;

              apli0004.pc_grava_taxa_cdi_mensal(pr_cdcooper => pr_cdcooper
                                               ,pr_cdianual => rw_crapmfx.vlmoefix
                                               ,pr_dtiniper => vr_dtiniper
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);
              IF vr_dscritic IS NOT NULL THEN
                 RAISE vr_exc_saida;
              END IF;
              -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
              GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0004.pc_cadastra_taxa_cdi_mensal');

              vr_contdias := vr_contdias + 1;
            END LOOP;
          END IF;
        END IF;

        -- Cadastra Taxa para dias posteriores do proprio MES
        -- Caso a viarada do mes for um final de semana

        IF TO_CHAR(pr_dtdiapos,'MM') <> TO_CHAR(pr_dtperiod,'MM') THEN

          vr_dtultdia := trunc(last_day(add_months(pr_dtdiapos, -1 )));
          vr_contador := vr_dtultdia - pr_dtperiod;

          IF vr_contador > 0 THEN

            OPEN cr_crapmfx(pr_cdcooper, pr_dtperiod, 6);
              FETCH cr_crapmfx
              INTO rw_crapmfx;

            -- Se não encontrar insere novo registro
            IF cr_crapmfx%NOTFOUND THEN
              -- Fechar o cursor
              CLOSE cr_crapmfx;
            ELSE
              -- Fechar o cursor
              CLOSE cr_crapmfx;
              vr_contdias := 1;

              LOOP

                EXIT WHEN vr_contdias > vr_contador;

                vr_dtiniper := pr_dtperiod + vr_contdias;

                apli0004.pc_grava_taxa_cdi_mensal(pr_cdcooper => pr_cdcooper
                                                 ,pr_cdianual => rw_crapmfx.vlmoefix
                                                 ,pr_dtiniper => vr_dtiniper
                                                 ,pr_cdcritic => vr_cdcritic
                                                 ,pr_dscritic => vr_dscritic);
                IF vr_dscritic IS NOT NULL THEN
                   RAISE vr_exc_saida;
                END IF;
                -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
                GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0004.pc_cadastra_taxa_cdi_mensal');

                vr_contdias := vr_contdias + 1;
              END LOOP;
            END IF;
          END IF;
        END IF;
      END IF;

      apli0004.pc_grava_taxa_cdi_mensal(pr_cdcooper => pr_cdcooper
                                       ,pr_cdianual => pr_cdianual
                                       ,pr_dtiniper => pr_dtperiod
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro na Rotina apli0004.pc_cadastra_taxa_cdi_mensal ' || pr_cdcooper ||'. Erro: ' || vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na Rotina apli0004.pc_cadastra_taxa_cdi_mensal ' || pr_cdcooper ||'. Erro: '||SQLERRM;

        --Inclusão na tabela de erros Oracle - Chamado 744573
        CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper );

        ROLLBACK;
    END;
  END pc_cadastra_taxa_cdi_mensal;

  /* Rotina de cadastro de taxa cdi mensal */
  PROCEDURE pc_grava_taxa_cdi_mensal(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                    ,pr_cdianual  IN NUMBER                --> Valor do CDI Anual
                                    ,pr_dtiniper  IN craptrd.dtiniper%TYPE --> Data de Inicio do Periodo
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo de Erro
                                    ,pr_dscritic OUT VARCHAR2) IS          --> Descricao de Erro

  BEGIN
    /* .............................................................................

    Programa: pc_grava_taxa_cdi_mensal        (Antigo: b1wgen0128.p/grava_taxa_cdi_mensal)
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : APLI
    Autor   : Desconhecido
    Data    : ##/##/####                        Ultima atualizacao: 27/09/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina de cadastro da taxa de CDI mensal

    Alteracoes: 30/03/2012 - Alterar para cadastrar a cadastra_taxa_cdi_mensal
                             e cadastra_taxa_cdi_acumulado no ultimo dia do
                             mes, caso o ultimo nao for dia util (Ze).

                20/05/2014 - Conversão Progress >> PLSQL (Jean Michel).

                27/09/2017 - Inclusão do módulo e ação logado no oracle
                           - Inclusão da chamada de procedure em exception others
                           - Colocado logs no padrão
                             (Ana - Envolti - Chamado 744573)
    ............................................................................. */
    DECLARE
      -- Variaveis de Excessao
      vr_exc_saida EXCEPTION;
      vr_dscritic VARCHAR2(1000);
      vr_cdcritic INTEGER := 0;

      vr_ind      INTEGER := 0;
      vr_contador INTEGER := 0;
      vr_contaaux INTEGER := 0;
      vr_qtdiaute INTEGER := 0;
      vr_dtfimper DATE;
      vr_vllidtab VARCHAR2(10000);
      vr_vltxadic craptrd.txofimes%TYPE;
      vr_auxrowid ROWID;
      vr_rowidtrd ROWID;
      vr_txmespop NUMBER(25,8) := 0;
      vr_txdiapop NUMBER(25,8) := 0;

      vr_cdimensa NUMBER(25,8) := 0;

      TYPE typ_varchar IS TABLE OF VARCHAR2(100);
      TYPE typ_number IS TABLE OF NUMBER(20,8);
      
      -- Array para guardar o split dos dados contidos na dstextab
      vr_vet_dados gene0002.typ_split;

      vr_taxcdi typ_varchar := typ_varchar();
      vr_taxadi typ_number  := typ_number();
      vr_taxfai typ_number  := typ_number();

      -- CURSORES

      CURSOR cr_crapmfx(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtiniper IN crapmfx.dtmvtolt%TYPE
                       ,pr_tpmoefix IN crapmfx.tpmoefix%TYPE) IS
        SELECT
          mfx.cdcooper
         ,mfx.dtmvtolt
         ,mfx.tpmoefix
         ,mfx.vlmoefix
         ,ROWID
        FROM
         crapmfx mfx
        WHERE
          mfx.cdcooper = pr_cdcooper  AND -- Codigo da Cooperativa
          mfx.dtmvtolt = pr_dtiniper  AND -- Data de Inicio do Periodo
          mfx.tpmoefix = pr_tpmoefix;     -- Tipo da Moeda

         rw_crapmfx cr_crapmfx%ROWTYPE;
         rw_crapmfx_2 cr_crapmfx%ROWTYPE;
         rw_crapmfx_3 cr_crapmfx%ROWTYPE;

     CURSOR cr_craptab(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
       SELECT
         tab.dstextab
        ,tab.tpregist
       FROM
         craptab tab
       WHERE
             tab.cdcooper = pr_cdcooper
         AND UPPER(tab.nmsistem) = 'CRED'
         AND UPPER(tab.tptabela) = 'CONFIG'
         AND UPPER(tab.cdacesso) = 'TXADIAPLIC';

       rw_craptab cr_craptab%ROWTYPE;

     CURSOR cr_craptrd(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_dtiniper IN craptrd.dtiniper%TYPE
                        ,pr_tptaxrda IN craptrd.tptaxrda%TYPE
                        ,pr_incarenc IN craptrd.incarenc%TYPE
                        ,pr_vlfaixas IN craptrd.vlfaixas%TYPE) IS
       SELECT
         trd.cdcooper
        ,trd.dtiniper
        ,trd.tptaxrda
        ,trd.incarenc
        ,trd.vlfaixas
        ,trd.txofimes
        ,trd.txofidia
        ,ROWID
       FROM
         craptrd trd
       WHERE
             trd.cdcooper = pr_cdcooper
         AND trd.dtiniper = pr_dtiniper
         AND trd.tptaxrda = pr_tptaxrda
         AND trd.incarenc = pr_incarenc
         AND trd.vlfaixas = pr_vlfaixas;

       rw_craptrd cr_craptrd%ROWTYPE;

    BEGIN
      -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
      GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'APLI0004.pc_grava_taxa_cdi_mensal');
        
      OPEN cr_crapmfx(pr_cdcooper, pr_dtiniper, 16);
        FETCH cr_crapmfx
        INTO rw_crapmfx;

      -- Se não encontrar insere novo registro
      IF cr_crapmfx%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapmfx;

        BEGIN
          INSERT INTO crapmfx(dtmvtolt, tpmoefix, cdcooper)
            VALUES(pr_dtiniper, 16, pr_cdcooper) RETURNING ROWID INTO vr_auxrowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir registro na CRAPMFX: dtmvtolt:'||pr_dtiniper
                           ||', tpmoefix:16. '||SQLERRM;
            RAISE vr_exc_saida;
        END;

      ELSE
        -- Fechar o cursor
        CLOSE cr_crapmfx;
        vr_auxrowid := rw_crapmfx.rowid;
      END IF;

      apli0004.pc_calcula_qt_dias_uteis(pr_cdcooper, pr_dtiniper, vr_qtdiaute, vr_dtfimper, vr_cdcritic, vr_dscritic);

      -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0004.pc_grava_taxa_cdi_mensal');
        
      vr_contador := 0;

      OPEN cr_craptab(pr_cdcooper);
      LOOP

        FETCH cr_craptab INTO rw_craptab;

        -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
        EXIT WHEN cr_craptab%NOTFOUND;  
        
        IF rw_craptab.dstextab IS NULL OR rw_craptab.dstextab = ' ' THEN
          CONTINUE;
        END IF;                      
        
        vr_vet_dados := gene0002.fn_quebra_string(pr_string  => rw_craptab.dstextab
                                                 ,pr_delimit => ';');
        
        -- Para cada registro encontrado
        FOR vr_ind IN 1..vr_vet_dados.COUNT LOOP
          
          vr_taxcdi.EXTEND;
          vr_taxadi.EXTEND;
          vr_taxfai.EXTEND;

          vr_vllidtab := gene0002.fn_busca_entrada(vr_ind,rw_craptab.dstextab,';');
          
          vr_contador := vr_contador + 1;

          vr_taxcdi(vr_contador) := to_number(rw_craptab.tpregist,'9');
          vr_taxadi(vr_contador) := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(2,vr_vllidtab,'#'));
          vr_taxfai(vr_contador) := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(1,vr_vllidtab,'#'));          
          
        END LOOP;      
        
      END LOOP;

      CLOSE cr_craptab;
      
      vr_contaaux := 1;

      -- GRAVAR O CDI MENSAL NO CRAPMFX (TIPO 16) E NO CRAPTRD
      LOOP

         EXIT WHEN vr_contaaux > vr_contador;

         vr_cdimensa := ROUND(((POWER(1 + (pr_cdianual / 100), vr_qtdiaute / 252) - 1) * 100),8);         

         BEGIN
           UPDATE crapmfx SET vlmoefix = vr_cdimensa WHERE crapmfx.rowid = vr_auxrowid;
         EXCEPTION
           WHEN OTHERS THEN
              -- Descricao do erro na atualizacao de registros
              vr_dscritic := 'Erro ao atualizar registro na CRAPMFX: vlmoefix:'||vr_cdimensa
                             ||' com rowid:'||vr_auxrowid||'. '||SQLERRM;
             RAISE vr_exc_saida;
         END;

         OPEN cr_craptrd(pr_cdcooper, pr_dtiniper, vr_taxcdi(vr_contaaux), 0, vr_taxfai(vr_contaaux));
            FETCH cr_craptrd
            INTO rw_craptrd;

         -- Se não encontrar insere novo registro
         IF cr_craptrd%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_craptrd;

          BEGIN
            INSERT INTO craptrd(tptaxrda, dtiniper, dtfimper, qtdiaute, vlfaixas, incarenc, incalcul, cdcooper)
              VALUES(vr_taxcdi(vr_contaaux), pr_dtiniper, vr_dtfimper, vr_qtdiaute, vr_taxfai(vr_contaaux), 0, 0, pr_cdcooper)
              RETURNING ROWID INTO vr_rowidtrd;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir registro na CRAPTRD: tptaxrda:'||vr_taxcdi(vr_contaaux)
                             ||', dtiniper:'||pr_dtiniper||', dtfimper:'||vr_dtfimper||', qtdiaute:'||vr_qtdiaute
                             ||', vlfaixas:'||vr_taxfai(vr_contaaux)||', incarenc:0, incalcul:0. '||SQLERRM;
              RAISE vr_exc_saida;
          END;

         ELSE
          -- Fechar o cursor
          CLOSE cr_craptrd;
          vr_rowidtrd := rw_craptrd.rowid;
         END IF;

         vr_vltxadic := vr_taxadi(vr_contaaux);
         vr_vltxadic := ROUND(((vr_cdimensa * vr_vltxadic) / 100),6);

         BEGIN
           UPDATE craptrd
           SET    craptrd.txofimes = vr_vltxadic,
                  craptrd.txofidia = ROUND(((POWER(1 + (vr_vltxadic / 100),1 / vr_qtdiaute) - 1) * 100),6)
           WHERE  craptrd.rowid = vr_rowidtrd
           RETURNING  craptrd.txofimes, craptrd.txofidia
           INTO       rw_craptrd.txofimes, rw_craptrd.txofidia;
         EXCEPTION
           WHEN OTHERS THEN
              -- Descricao do erro na atualizacao de registros
              vr_dscritic := 'Erro ao atualizar registro na CRAPTRD: txofimes:'||vr_vltxadic
                             ||', txofidia:'||ROUND(((POWER(1 + (vr_vltxadic / 100),1 / vr_qtdiaute) - 1) * 100),6)
                             ||' com rowid:'||vr_rowidtrd||'. '||SQLERRM;
             RAISE vr_exc_saida;
         END;

         IF vr_taxcdi(vr_contaaux) < 4 THEN

           OPEN cr_crapmfx(pr_cdcooper, pr_dtiniper, 8);
             FETCH cr_crapmfx
             INTO rw_crapmfx_2;

           -- Se não encontrar insere novo registro
           IF cr_crapmfx%NOTFOUND THEN
             -- Fechar o cursor
             CLOSE cr_crapmfx;

             BEGIN
              UPDATE craptrd
              SET    craptrd.vltrapli = vr_cdimensa -- CDI Mensal
              WHERE  craptrd.rowid = vr_rowidtrd;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                -- Descricao do erro na atualizacao de registros
                vr_dscritic := 'Erro ao atualizar registro na CRAPTRD - 1: vltrapli:'||vr_cdimensa
                               ||' com rowid:'||vr_rowidtrd||'. '||SQLERRM;
                RAISE vr_exc_saida;
            END;
           ELSE
             -- Fechar o cursor
             CLOSE cr_crapmfx;

             apli0004.pc_calcula_poupanca(pr_cdcooper => pr_cdcooper
                                         ,pr_qtddiaut => vr_qtdiaute
                                         ,pr_vlmoefix => rw_crapmfx_2.vlmoefix
                                         ,pr_txmespop => vr_txmespop
                                         ,pr_txdiapop => vr_txdiapop
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

              IF vr_dscritic IS NOT NULL THEN
                 RAISE vr_exc_saida;
              END IF;

              -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
              GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0004.pc_grava_taxa_cdi_mensal');

              BEGIN
                UPDATE craptrd
                SET    craptrd.vltrapli = case when rw_craptrd.txofimes < vr_txmespop then rw_crapmfx_2.vlmoefix /* Poupança */ else vr_cdimensa  /* CDI */ end,
                       craptrd.txofimes = case when rw_craptrd.txofimes < vr_txmespop then vr_txmespop /* Poupança */ else rw_craptrd.txofimes end,
                       craptrd.txofidia = case when rw_craptrd.txofidia < vr_txdiapop then vr_txdiapop else rw_craptrd.txofidia end
                WHERE  craptrd.rowid = vr_rowidtrd;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic := 0;
                  -- Descricao do erro na atualizacao de registros
                  vr_dscritic := 'Erro ao atualizar registro na CRAPTRD - 2: txofimes:'||rw_craptrd.txofimes
                  ||', vr_txmespop:'||vr_txmespop||', vlmoefix:'||rw_crapmfx_2.vlmoefix||', vr_cdimensa:'||vr_cdimensa
                  ||', txofidia:'||rw_craptrd.txofidia||',vr_txdiapop:'||vr_txdiapop
                  ||' com rowid:'||vr_rowidtrd||'. '||SQLERRM;
                  RAISE vr_exc_saida;
              END;

           END IF;

         ELSE
           -- Verifica se a Poupanca eh maior que o CDI e se irá utilizar nova regra

           OPEN cr_crapmfx(pr_cdcooper, pr_dtiniper, 20); -- Poupanca Novo Indexador
             FETCH cr_crapmfx
             INTO rw_crapmfx_3;

           -- Se não encontrar insere novo registro
           IF cr_crapmfx%NOTFOUND THEN
             -- Fechar o cursor
             CLOSE cr_crapmfx;

             BEGIN
               UPDATE craptrd
               SET    craptrd.vltrapli = vr_cdimensa -- CDI
               WHERE  craptrd.rowid = vr_rowidtrd;
             EXCEPTION
               WHEN OTHERS THEN
                 vr_cdcritic := 0;
                 -- Descricao do erro na atualizacao de registros
                 vr_dscritic := 'Erro ao atualizar registro na CRAPTRD - 3: vltrapli:'||vr_cdimensa
                                ||' com rowid:'||vr_rowidtrd||'. '||SQLERRM;
                 RAISE vr_exc_saida;
             END;

           ELSE
             -- Fechar o cursor
             CLOSE cr_crapmfx;

             apli0004.pc_calcula_poupanca(pr_cdcooper => pr_cdcooper
                                         ,pr_qtddiaut => vr_qtdiaute
                                         ,pr_vlmoefix => rw_crapmfx_3.vlmoefix
                                         ,pr_txmespop => vr_txmespop
                                         ,pr_txdiapop => vr_txdiapop
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

             IF vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_saida;
             END IF;

             -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
             GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0004.pc_grava_taxa_cdi_mensal');

             BEGIN
               UPDATE craptrd
               SET    craptrd.vltrapli = case when rw_craptrd.txofimes < vr_txmespop then rw_crapmfx_3.vlmoefix /* Poupança */ else vr_cdimensa  /* CDI */ end,
                      craptrd.txofimes = case when rw_craptrd.txofimes < vr_txmespop then vr_txmespop /* Poupança */ else rw_craptrd.txofimes end,
                      craptrd.txofidia = case when rw_craptrd.txofidia < vr_txdiapop then vr_txdiapop else rw_craptrd.txofidia end
               WHERE  craptrd.rowid = vr_rowidtrd;
             EXCEPTION
               WHEN OTHERS THEN
                 vr_cdcritic := 0;
                 -- Descricao do erro na atualizacao de registros
                 vr_dscritic := 'Erro ao atualizar registro na CRAPTRD - 4: txofimes:'||rw_craptrd.txofimes
                 ||', vr_txmespop:'||vr_txmespop||', vlmoefix:'||rw_crapmfx_3.vlmoefix||', vr_cdimensa:'||vr_cdimensa
                 ||', txofidia:'||rw_craptrd.txofidia||',vr_txdiapop:'||vr_txdiapop
                 ||' com rowid:'||vr_rowidtrd||'. '||SQLERRM;
                 RAISE vr_exc_saida;
             END;
           END IF;
         END IF;
         
         vr_contaaux := vr_contaaux + 1;

      END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro na Rotina apli0004.pc_grava_taxa_cdi_mensal ' || pr_cdcooper ||'. Erro: ' || vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na Rotina apli0004.pc_grava_taxa_cdi_mensal ' || pr_cdcooper ||'. Erro: '||SQLERRM;

        --Inclusão na tabela de erros Oracle - Chamado 744573
        CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper );

        ROLLBACK;
    END;
  END pc_grava_taxa_cdi_mensal;

  /* Rotina de calculo de poupanca */
  PROCEDURE pc_calcula_poupanca(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                               ,pr_qtddiaut  IN INTEGER               --> Quantidade de dias uteis
                               ,pr_vlmoefix  IN crapmfx.vlmoefix%TYPE --> Valor da Moeda
                               ,pr_txmespop OUT craptrd.txofimes%TYPE --> Taxa do Mes
                               ,pr_txdiapop OUT craptrd.txofidia%TYPE --> Taxa do Dia
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo de Erro
                               ,pr_dscritic OUT VARCHAR2) IS          --> Descricao de Erro

  BEGIN
    /* .............................................................................

    Programa: pc_calcula_poupanca        (Antigo: b1wgen0128.p/calcula_poupanca)
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : APLI
    Autor   : Desconhecido
    Data    : ##/##/####                        Ultima atualizacao: 27/09/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina de calculo referente a poupanca.

    Alteracoes: 22/05/2014 - Conversão Progress >> PLSQL (Jean Michel).

                27/09/2017 - Inclusão do módulo e ação logado no oracle
                           - Inclusão da chamada de procedure em exception others
                           - Colocado logs no padrão
                             (Ana - Envolti - Chamado 744573)
    ............................................................................. */
    DECLARE
      vr_exc_saida EXCEPTION;

      vr_dscritic VARCHAR2(1000);
      vr_cdcritic INTEGER := 0;

      -- Guardar registro dstextab
      vr_dstextab craptab.dstextab%TYPE;

    BEGIN
      -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
      GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'APLI0004.pc_calcula_poupanca');

      -- Buscar configuração na tabela
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'CONFIG'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'PERCIRRDCA'
                                               ,pr_tpregist => 0);      

      IF (vr_dstextab <> '') or (vr_dstextab IS NOT NULL) THEN  

        pr_txmespop := ROUND(pr_vlmoefix / (1 - (gene0002.fn_char_para_number(gene0002.fn_busca_entrada(2, gene0002.fn_busca_entrada(1, vr_dstextab, ';'), '#')) / 100)),6);
        pr_txdiapop := ROUND(((POWER(1 + (pr_txmespop / 100), 1 / pr_qtddiaut) - 1) * 100),6);

      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro na rotina apli0004.pc_calcula_poupanca. Cooper: ' || pr_cdcooper ||'. Erro: ' || vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina apli0004.pc_calcula_poupanca. Cooper: ' || pr_cdcooper ||'. Erro: '||SQLERRM;

        --Inclusão na tabela de erros Oracle - Chamado 744573
        CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper );

    END;
  END pc_calcula_poupanca;

  /* Rotina de validacao de data dos indexadores*/
  PROCEDURE pc_valida_data(pr_cddindex IN crapind.cddindex%TYPE --> Codigo do Indexador
                          ,pr_dtperiod IN VARCHAR2              --> Data do Periodo
                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

  BEGIN
    /* .............................................................................

    Programa: pc_valida_data
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : 25/06/2014                        Ultima atualizacao: 27/09/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina de validacao de data dos indexadores

    Alteracoes: 27/09/2017 - Inclusão do módulo e ação logado no oracle
                           - Inclusão da chamada de procedure em exception others
                           - Colocado logs no padrão
                             (Ana - Envolti - Chamado 744573)
    ............................................................................. */
    DECLARE
      vr_exc_saida EXCEPTION;

      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      vr_flgexist INTEGER := 0;
      vr_dtperiod DATE;

      vr_tab_erro GENE0001.typ_tab_erro; --> Tabela com erros
      
      rw_crapdat cr_crapdat%ROWTYPE;

      -- CURSORES

      -- Consulta de taxas
      CURSOR cr_craptxi(pr_cddindex IN craptxi.cddindex%TYPE
                       ,pr_dtiniper IN craptxi.dtiniper%TYPE) IS

      SELECT
        txi.cddindex
       ,txi.dtiniper
       ,txi.dtfimper
       ,txi.vlrdtaxa
       ,txi.dtcadast
      FROM
       craptxi txi
      WHERE
            txi.cddindex = pr_cddindex  -- Codigo do Indexador
        AND txi.dtiniper = pr_dtiniper; -- Data de inicio do periodo

      rw_craptxi cr_craptxi%ROWTYPE;

      -- Consulta de indexadores
      CURSOR cr_crapind(pr_cddindex IN craptxi.cddindex%TYPE) IS

      SELECT
        ind.cddindex
       ,ind.nmdindex
       ,ind.idperiod
       ,ind.idexpres
      FROM
        crapind ind
      WHERE
        ind.cddindex = pr_cddindex;  -- Codigo do Indexador

      rw_crapind cr_crapind%ROWTYPE;

    BEGIN
      -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
      GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'APLI0004.pc_valida_data');

      vr_dtperiod := to_date(pr_dtperiod,'dd/mm/yyyy');

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Busca do calendario da Cooperativa
      OPEN cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH cr_crapdat
       INTO rw_crapdat;

      -- Se não encontrar
      IF cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE cr_crapdat;
        -- Chamar rotina de gravacao de erro
        gene0001.pc_gera_erro(pr_cdcooper => vr_cdcooper
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 1 --> Critica 1
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
        -- Levantar excecao
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapdat;
      END IF;

      -- Consulta de indexador
      OPEN cr_crapind(pr_cddindex => pr_cddindex);

      FETCH cr_crapind INTO rw_crapind;

      -- Verifica se registro existe
      IF cr_crapind%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_crapind;

        -- Monta critica
        vr_dscritic := 'Registro de indexador nao encontrado.';
        RAISE vr_exc_saida;
      ELSE
        -- Fecha cursor
        CLOSE cr_crapind;
      END IF;

      -- Consulta de taxa do indexador
      OPEN cr_craptxi(pr_cddindex => pr_cddindex
                     ,pr_dtiniper => vr_dtperiod);

      FETCH cr_craptxi INTO rw_craptxi;

      -- Verifica se registro existe
      IF cr_craptxi%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_craptxi;
      ELSE
        -- Fecha cursor
        CLOSE cr_craptxi;
      END IF;

      IF rw_crapind.idperiod IN (1,2)THEN

        -- Verifica se periodo da taxa e maior que data atual
        IF TRUNC(vr_dtperiod,'MM') < TRUNC(rw_crapdat.dtmvtolt,'MM') AND NVL(rw_craptxi.vlrdtaxa,0) = 0 
           AND pr_cddindex <> 4 THEN
          vr_dscritic := 'Nao e possivel cadastrar taxa do mes anterior.';
          RAISE vr_exc_saida;
        ELSIF TRUNC(vr_dtperiod,'MM') < TRUNC(rw_crapdat.dtmvtolt,'MM') AND NVL(rw_craptxi.vlrdtaxa,0) <> 0 
              AND pr_cddindex <> 4 THEN
          vr_dscritic := 'Nao e possivel alterar taxa do mes anterior.';
          RAISE vr_exc_saida;
        END IF;

      ELSE

        -- Verifica se periodo da taxa e maior que data atual
        IF TO_NUMBER(TO_CHAR(vr_dtperiod,'yyyy')) < to_number(TO_CHAR(rw_crapdat.dtmvtolt,'yyyy')) 
           AND NVL(rw_craptxi.vlrdtaxa,0) = 0 AND pr_cddindex <> 4 THEN
          vr_dscritic := 'Nao e possivel cadastrar taxa do ano anterior.';
          RAISE vr_exc_saida; 
        ELSIF TO_NUMBER(TO_CHAR(vr_dtperiod,'yyyy')) < to_number(TO_CHAR(rw_crapdat.dtmvtolt,'yyyy')) 
           AND NVL(rw_craptxi.vlrdtaxa,0) <> 0 AND pr_cddindex <> 4 THEN
          vr_dscritic := 'Nao e possivel alterar taxa do ano anterior.';
          RAISE vr_exc_saida;
        END IF;

      END IF;

      -- Consulta de taxas de indexadores
      OPEN cr_craptxi(pr_cddindex => pr_cddindex
                     ,pr_dtiniper => vr_dtperiod);

      FETCH cr_craptxi
      INTO rw_craptxi;

      -- Se não encontrar
      IF cr_craptxi%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_craptxi;
        -- Flag indica que registro e inexistente
        vr_flgexist := 0;
      ELSE
        -- Fechar o cursor
        CLOSE cr_craptxi;
        -- Flag indica que registro existe
        vr_flgexist := 1;
      END IF;

      -- Verifica se taxa nao esta cadastrada
      IF vr_flgexist = 0 THEN

        IF pr_cddindex = 2 THEN -- Para cadastrar TR, verifica se já existe a SELIC Meta

          -- Consulta de taxas de indexadores
          OPEN cr_craptxi(pr_cddindex => 3
                         ,pr_dtiniper => vr_dtperiod);

          FETCH cr_craptxi
          INTO rw_craptxi;

          -- Se não encontrar
          IF cr_craptxi%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_craptxi;
            vr_dscritic := 'Para cadastrar TR, primeiro cadastre a SELIC meta para o dia informado.';
            RAISE vr_exc_saida;
          ELSE
            -- Fechar o cursor
            CLOSE cr_craptxi;
          END IF;

        END IF;

        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cddopcao', pr_tag_cont => 0, pr_des_erro => vr_dscritic);
      ELSE
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cddopcao', pr_tag_cont => 1, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vlrdtaxa', pr_tag_cont => TO_CHAR(rw_craptxi.vlrdtaxa,'fm990d00999999'), pr_des_erro => vr_dscritic);
         
      END IF;

    EXCEPTION

      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_valida_data: '||SQLERRM;

        --Inclusão na tabela de erros Oracle - Chamado 744573
        CECRED.pc_internal_exception( pr_cdcooper => vr_cdcooper );

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_valida_data;

  /* Rotina de validacao de data dos indexadores*/
  PROCEDURE pc_manter_taxa(pr_cddopcao IN VARCHAR2              --> Codigo da opcao
                          ,pr_cddindex IN craptxi.cddindex%TYPE --> Codigo do Indexador
                          ,pr_dtperiod IN VARCHAR2              --> Data do Periodo
                          ,pr_vlrdtaxa IN craptxi.vlrdtaxa%TYPE --> Valor da Taxa do Indexador
                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

  BEGIN
    /* .............................................................................

    Programa: pc_manter_taxa
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : 25/06/2014                        Ultima atualizacao: 27/09/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina de cadastro e alteracao de taxas

    Alteracoes: 25/05/2015 - Inclusao do tratamento de cadastro para tipo de taxa
                             mensal sendo o IPCA, agora pode-se cadastrar esta taxa
                             em outro mes.
                
                29/05/2017 - Realizado ajuste para que ao alterar ou cadastrar tarifas
								             do tipo "TR" seja possível atribuir o valor 0(ZERO), conforme
								             solicitado no chamado 615474 (Kelvin)

                27/09/2017 - Inclusão do módulo e ação logado no oracle
                           - Inclusão da chamada de procedure em exception others
                           - Colocado logs no padrão
                             (Ana - Envolti - Chamado 744573)
    ............................................................................. */
    DECLARE
      vr_exc_saida EXCEPTION;

      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_dsmsglog VARCHAR2(1000);

      vr_flgexist INTEGER := 0;
      vr_dtperiod DATE;
      vr_vlpoupan NUMBER(20,8) := 0;
      vr_auxdatap VARCHAR2(10) := '';

      vr_tab_erro GENE0001.typ_tab_erro; --> Tabela com erros
      
      rw_crapcop cr_crapcop%ROWTYPE;
      rw_crapdat cr_crapdat%ROWTYPE;

      -- CURSORES
      CURSOR cr_craptxi(pr_cddindex IN craptxi.cddindex%TYPE
                       ,pr_dtiniper IN craptxi.dtiniper%TYPE) IS

      SELECT
        txi.cddindex
       ,txi.dtiniper
       ,txi.dtfimper
       ,txi.vlrdtaxa
       ,txi.dtcadast
       ,txi.rowid
      FROM
       craptxi txi
      WHERE
            txi.cddindex = pr_cddindex  -- Codigo do Indexador
        AND txi.dtiniper = pr_dtiniper; -- Data de periodo

      rw_craptxi cr_craptxi%ROWTYPE;

      -- Consulta indexadores
      CURSOR cr_crapind(pr_cddindex IN craptxi.cddindex%TYPE) IS

      SELECT
        ind.cddindex
       ,ind.idperiod
      FROM
       crapind ind
      WHERE
            ind.cddindex = pr_cddindex;  -- Codigo do Indexador

      rw_crapind cr_crapind%ROWTYPE;

      CURSOR cr_crapmfx(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtiniper IN crapmfx.dtmvtolt%TYPE
                       ,pr_tpmoefix IN crapmfx.tpmoefix%TYPE) IS

      SELECT
        mfx.cdcooper
       ,mfx.dtmvtolt
       ,mfx.tpmoefix
       ,mfx.progress_recid
      FROM
        crapmfx mfx
      WHERE
            mfx.cdcooper = pr_cdcooper
        AND mfx.dtmvtolt = pr_dtiniper
        AND mfx.tpmoefix = pr_tpmoefix;

      rw_crapmfx cr_crapmfx%ROWTYPE;

    BEGIN
      -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
      GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'APLI0004.pc_manter_taxa');

      vr_dtperiod := to_date(pr_dtperiod,'dd/mm/RRRR');

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Busca do calendario da Cooperativa
      OPEN cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH cr_crapdat
       INTO rw_crapdat;

      -- Se não encontrar
      IF cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE cr_crapdat;
        -- Chamar rotina de gravacao de erro
        gene0001.pc_gera_erro(pr_cdcooper => vr_cdcooper
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 1 --> Critica 1
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
        -- Levantar excecao
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapdat;
      END IF;

      --TR (Caso for TR deixar passar valor zerado SD 615474)
      IF pr_cddindex = 2 THEN
        -- Valida valor de taxa
        IF pr_vlrdtaxa IS NULL THEN
          vr_dscritic := 'Valor da taxa que nao pode ser menor ou igual a zero.';
          RAISE vr_exc_saida;          
        END IF;
      ELSE
        -- Valida valor de taxa
        IF pr_vlrdtaxa <= 0 OR
           pr_vlrdtaxa IS NULL THEN
           vr_dscritic := 'Valor da taxa que nao pode ser menor ou igual a zero.';
           RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Consulta de taxas de indexadores
      OPEN cr_craptxi(pr_cddindex => pr_cddindex
                     ,pr_dtiniper => vr_dtperiod);

      FETCH cr_craptxi
      INTO rw_craptxi;

      -- Se não encontrar
      IF cr_craptxi%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_craptxi;
        -- Flag indica que registro e inexistente
        vr_flgexist := 0;
      ELSE
        -- Fechar o cursor
        CLOSE cr_craptxi;
        -- Flag indica que registro existe
        vr_flgexist := 1;
      END IF;

      -- Consulta indexador para obter informacoes para geracao do log
      OPEN cr_crapind_cod(pr_cddindex);
      FETCH cr_crapind_cod
      INTO rw_crapind_cod;

      -- Se não encontrar
      IF cr_crapind_cod%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapind_cod;
        vr_dscritic := 'Indexador Inexistente - 3:'||pr_cddindex;
        RAISE vr_exc_saida;
      ELSE
        -- Fechar o cursor
        CLOSE cr_crapind_cod;
      END IF;

      -- Verifica a periodicidade do Indexador
      IF rw_crapind_cod.idperiod = 1 THEN -- Diaria
        vr_auxdatap := TO_CHAR(vr_dtperiod,'dd/mm/RRRR');
      ELSIF rw_crapind_cod.idperiod = 2 THEN -- Mensal
        vr_auxdatap := TO_CHAR(vr_dtperiod,'mm/RRRR');   
      ELSIF rw_crapind_cod.idperiod = 3 THEN -- Anual
        vr_auxdatap := TO_CHAR(vr_dtperiod,'RRRR');
      END IF;

      -- Verifica se taxa nao esta cadastrada
      IF vr_flgexist = 0 THEN
        BEGIN
          -- Insere registro
          INSERT INTO craptxi
            (cddindex,dtiniper,dtfimper,vlrdtaxa,dtcadast)
          VALUES
            (pr_cddindex,vr_dtperiod,vr_dtperiod, pr_vlrdtaxa ,rw_crapdat.dtmvtolt);

          -- Monta mensagem de log com atualizacao do registro
          vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') || ' -> Operador: ' || vr_cdoperad;

          vr_dsmsglog := vr_dsmsglog || ' - cadastrou taxa do indexador: ' || pr_cddindex || ' - ' || rw_crapind_cod.nmdindex;

          vr_dsmsglog := vr_dsmsglog || ', periodo: ' || vr_auxdatap;

          vr_dsmsglog := vr_dsmsglog || ', valor: ' || TRIM(REPLACE(TO_CHAR(pr_vlrdtaxa,'fm990d00000000'),'.',',')) || '.';
        
          IF vr_dsmsglog IS NOT NULL THEN

            -- Incluir log de execução.
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                      ,pr_ind_tipo_log => 1
                                      ,pr_des_log      => vr_dsmsglog
                                      ,pr_nmarqlog     => 'indice');
          END IF;

        EXCEPTION
          WHEN OTHERS THEN
            -- Descricao do erro na insercao de registros
            vr_dscritic := 'Erro ao inserir Taxa: cddindex:'||pr_cddindex||', dtiniper:'||vr_dtperiod
                           ||', dtfimper:'||vr_dtperiod||', vlrdtaxa:'||pr_vlrdtaxa
                           ||', dtcadast:'||rw_crapdat.dtmvtolt||'. '||SQLERRM;
            RAISE vr_exc_saida;
        END;
      ELSE

        -- Verifica se o mes da data de cadastro e a data vigente sao iguais, só pode haver alteracao
        -- quando a data de movimentacao for igual a de cadastro da taxa
        IF rw_crapdat.dtmvtolt = rw_craptxi.dtcadast THEN
            
          BEGIN
            UPDATE craptxi
            SET    vlrdtaxa = pr_vlrdtaxa
            WHERE  craptxi.cddindex = pr_cddindex AND
                   craptxi.dtiniper = vr_dtperiod AND
                   craptxi.dtfimper = vr_dtperiod;
            
            -- Consulta indexador para obter informacoes para geracao do log
            OPEN cr_crapind_cod(pr_cddindex);
            FETCH cr_crapind_cod
            INTO rw_crapind_cod;
    
            -- Monta mensagem de log com atualizacao do registro
            vr_dsmsglog := TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') || ' -> Operador: ' || vr_cdoperad;

            vr_dsmsglog := vr_dsmsglog || ' - Alterou taxa do indexador: ' || pr_cddindex || ' - ' || rw_crapind_cod.nmdindex;

            vr_dsmsglog := vr_dsmsglog || ', periodo: ' || vr_auxdatap;

            vr_dsmsglog := vr_dsmsglog || ', valor: ' || TRIM(REPLACE(TO_CHAR(pr_vlrdtaxa,'fm990d00000000'),'.',',')) || '.';
            
            IF vr_dsmsglog IS NOT NULL THEN

              -- Incluir log de execução
              BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                        ,pr_ind_tipo_log => 1
                                        ,pr_des_log      => vr_dsmsglog
                                        ,pr_nmarqlog     => 'indice');
            END IF;

          EXCEPTION
            WHEN OTHERS THEN
              -- Descricao do erro na atualizacao de registros
              vr_dscritic := 'Erro ao atualizar Taxa: vlrdtaxa:'||pr_vlrdtaxa
                             ||' com cddindex:'||pr_cddindex
                             ||', dtiniper:'||vr_dtperiod||', dtfimper:'||vr_dtperiod||'. '||SQLERRM;
              RAISE vr_exc_saida;
          END;
        ELSE
          vr_dscritic := 'Esta taxa nao pode ser alterada. Taxa cadastrada em ' || TO_CHAR(rw_craptxi.dtcadast,'dd/mm/RRRR');
          RAISE vr_exc_saida;
        END IF;
      END IF;

      IF vr_cdcooper <> 3 THEN
        vr_dscritic := 'Cadastro somente pode ser feito pela central.';
        RAISE vr_exc_saida;
      END IF;

      OPEN cr_crapind(pr_cddindex => pr_cddindex);

      FETCH cr_crapind INTO rw_crapind;
      
      IF cr_crapind%NOTFOUND THEN
        CLOSE cr_crapind;
        vr_dscritic := 'Registro de indexador nao encontrado.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapind;
      END IF;

      IF rw_crapind.idperiod IN (1,2)THEN

        -- Verifica se periodo da taxa e maior que data atual
        IF TRUNC(vr_dtperiod,'MM') < TRUNC(rw_crapdat.dtmvtolt,'MM') AND pr_cddindex <> 4THEN
           vr_dscritic := 'Nao e possivel alterar taxa do mes anterior.';
           RAISE vr_exc_saida;
        END IF;

      ELSE

        -- Verifica se periodo da taxa e maior que data atual
        IF to_number(TO_CHAR(vr_dtperiod,'yyyy')) < to_number(TO_CHAR(rw_crapdat.dtmvtolt,'yyyy')) THEN
           vr_dscritic := 'Nao e possivel alterar taxa do ano anterior.';
           RAISE vr_exc_saida;
        END IF;

      END IF;

      IF pr_cddindex = 1 THEN -- Verifica se taxa cadastrada e CDI

         IF pr_cddopcao = 'I' THEN

           apli0004.pc_cadastra_taxa_cdi(pr_cdcooper => vr_cdcooper   --> Codigo da Cooperativa
                                        ,pr_dtmvtolt => vr_dtperiod   --> Data de Movimentacao
                                        ,pr_vlmoefix => pr_vlrdtaxa   --> Valor da Moeda
                                        ,pr_tpmoefix => 6             --> Tipo da Moeda (1-CDI)
                                        ,pr_cdprogra => 'INDICE'      --> Programa Chamador
                                        ,pr_cdcritic => vr_cdcritic   --> Código da crítica
                                        ,pr_dscritic => vr_dscritic); --> Descrição da crítica
                                     
           IF vr_cdcritic IS NOT NULL OR                                     
              vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
           END IF;

         ELSIF pr_cddopcao = 'A' THEN 

           apli0004.pc_altera_taxa_cdi(pr_cdcooper => vr_cdcooper   --> Codigo da Cooperativa
                                      ,pr_dtmvtolt => vr_dtperiod   --> Data de Movimentacao
                                      ,pr_vlmoefix => pr_vlrdtaxa   --> Valor da Moeda
                                      ,pr_tpmoefix => 6             --> Tipo da Moeda (1-CDI)
                                      ,pr_cdcritic => vr_cdcritic   --> Código da crítica
                                      ,pr_dscritic => vr_dscritic); --> Descrição da crítica

           IF vr_cdcritic IS NOT NULL OR                                     
              vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
           END IF;
         END IF;

         -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
         GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0004.pc_manter_taxa');

      ELSIF pr_cddindex = 2 THEN -- Verifica se taxa cadastrada e TR
        IF pr_cddopcao = 'I' THEN
          OPEN cr_crapcop(pr_cdcooper => 0);

          LOOP
            FETCH cr_crapcop INTO rw_crapcop;

            -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
            EXIT WHEN cr_crapcop%NOTFOUND;

            apli0004.pc_poupanca(pr_cdcooper => rw_crapcop.cdcooper
                                ,pr_dtperiod => vr_dtperiod
                                ,pr_vltaxatr => pr_vlrdtaxa
                                ,pr_vlpoupan => vr_vlpoupan
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);

            IF vr_dscritic IS NOT NULL OR vr_cdcritic <> 0 THEN
              RAISE vr_exc_saida;
            END IF; 
              
            apli0004.pc_atualiza_sol026(pr_cdcooper => rw_crapcop.cdcooper
                                       ,pr_dtperiod => vr_dtperiod
                                       ,pr_vlpoupan => vr_vlpoupan
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
            
            IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) <> 0 THEN
              RAISE vr_exc_saida;
            END IF;      

            -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
            GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0004.pc_manter_taxa');
            
            IF rw_crapcop.cdcooper <> 3 THEN
              
              apli0004.pc_atualiza_tr(pr_cdcooper => rw_crapcop.cdcooper
                                     ,pr_dtperiod => vr_dtperiod
                                     ,pr_txrefmes => pr_vlrdtaxa
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
              
              IF vr_dscritic IS NOT NULL OR vr_cdcritic <> 0 THEN
                RAISE vr_exc_saida;
              END IF;

              -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
              GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0004.pc_manter_taxa');

            END IF;
          END LOOP;
          
          CLOSE cr_crapcop;
        ELSE
          OPEN cr_crapcop(pr_cdcooper => 0);

          LOOP
            FETCH cr_crapcop INTO rw_crapcop;

            -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
            EXIT WHEN cr_crapcop%NOTFOUND;
            
            OPEN cr_crapmfx(pr_cdcooper => rw_crapcop.cdcooper
                           ,pr_dtiniper => vr_dtperiod
                           ,pr_tpmoefix => 11);
            
            FETCH cr_crapmfx INTO rw_crapmfx;               

            IF cr_crapmfx%NOTFOUND THEN
              CLOSE cr_crapmfx;
              vr_cdcritic := 347;
              RAISE vr_exc_saida;
              
            ELSE
              CLOSE cr_crapmfx;
              -- Atualiza taxa TR
              BEGIN
                UPDATE crapmfx
                SET    vlmoefix = pr_vlrdtaxa
                WHERE  crapmfx.cdcooper = rw_crapcop.cdcooper
                AND    crapmfx.dtmvtolt = vr_dtperiod
                AND    crapmfx.tpmoefix = 11;

              EXCEPTION
                WHEN OTHERS THEN
                -- Descricao do erro na atualizacao de registros
                vr_dscritic := 'Erro ao atualizar taxa TR: vlmoefix:'||pr_vlrdtaxa
                               ||' com cdcooper:'||rw_crapcop.cdcooper
                               ||', dtmvtolt:'||vr_dtperiod||', tpmoefix:11. '||SQLERRM;
              END;

              apli0004.pc_atualiza_taxa_poupanca(pr_cdcooper => rw_crapcop.cdcooper
                                                ,pr_dtmvtolt => vr_dtperiod
                                                ,pr_cdcritic => pr_cdcritic
                                                ,pr_dscritic => pr_dscritic);
                                                
              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;
 
              -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
              GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0004.pc_manter_taxa');

           END IF;                              

          END LOOP;
          CLOSE cr_crapcop;

        END IF;

      ELSIF pr_cddindex = 3 THEN -- Verifica se taxa cadastrada e Selic Meta

        IF vr_cdcooper <> 3 THEN
          vr_dscritic := 'Cadastro somente pode ser feito pela central.';
          RAISE vr_exc_saida;
        END IF;

        IF pr_cddopcao = 'I' THEN
          
          OPEN cr_crapcop(pr_cdcooper => 0);

          LOOP
            FETCH cr_crapcop INTO rw_crapcop;

            -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
            EXIT WHEN cr_crapcop%NOTFOUND;
            
            BEGIN
              INSERT INTO crapmfx(cdcooper, dtmvtolt, tpmoefix, vlmoefix)
                VALUES(rw_crapcop.cdcooper, vr_dtperiod, 19, pr_vlrdtaxa);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao cadastrar SELIC Meta na cooperativa: cdcooper:'||rw_crapcop.cdcooper
                               ||', dtmvtolt:'||vr_dtperiod||', tpmoefix:19 '||', vlmoefix:'||pr_vlrdtaxa||'. '
                               ||SQLERRM; 
                RAISE vr_exc_saida;   
            END;  
    
          END LOOP;

          CLOSE cr_crapcop;

        ELSIF pr_cddopcao = 'A' THEN 
          
          OPEN cr_crapcop(pr_cdcooper => 0);

          LOOP
            FETCH cr_crapcop INTO rw_crapcop;

            -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
            EXIT WHEN cr_crapcop%NOTFOUND;
            
            BEGIN
              UPDATE crapmfx
                 SET vlmoefix = pr_vlrdtaxa
               WHERE cdcooper = rw_crapcop.cdcooper
                 AND dtmvtolt = vr_dtperiod
                 AND tpmoefix = 19;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na atualizacao de registros
                vr_dscritic := 'Erro ao atualizar SELIC Meta na cooperativa:'||rw_crapcop.cdcooper
                               ||', vlmoefix:'||pr_vlrdtaxa
                               ||' com dtmvtolt:'||vr_dtperiod||', tpmoefix:19. '||SQLERRM;
                RAISE vr_exc_saida;   
            END;  
          END LOOP;
          CLOSE cr_crapcop;

          OPEN cr_crapmfx(pr_cdcooper => vr_cdcooper
                         ,pr_dtiniper => vr_dtperiod
                         ,pr_tpmoefix => 11);
             
          FETCH cr_crapmfx INTO rw_crapmfx;
                           
          IF cr_crapmfx%NOTFOUND THEN
            CLOSE cr_crapmfx;
          ELSE
            CLOSE cr_crapmfx;

            OPEN cr_crapcop(pr_cdcooper => 0);

            LOOP
              FETCH cr_crapcop INTO rw_crapcop;

              -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
              EXIT WHEN cr_crapcop%NOTFOUND;
              
              apli0004.pc_atualiza_taxa_poupanca(pr_cdcooper => rw_crapcop.cdcooper
                                                ,pr_dtmvtolt => vr_dtperiod
                                                ,pr_cdcritic => vr_cdcritic
                                                ,pr_dscritic => vr_dscritic);
                                    
              -- Verifica se ocorreu alguma critica
              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;

              -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
              GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0004.pc_manter_taxa');
            END LOOP;
            CLOSE cr_crapcop;

          END IF;
        END IF;        
      END IF;
      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSIF vr_dscritic IS NOT NULL THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        ELSIF vr_vlpoupan = 0 AND vr_dscritic IS NULL OR NVL(vr_cdcritic,0) = 0 THEN
          pr_cdcritic := 0;
          pr_dscritic := 'ERRO AO INCLUIR A TR - COOP: ' || rw_crapcop.nmrescop;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_manter_taxa: '||SQLERRM || ', ' || vr_dscritic;

        --Inclusão na tabela de erros Oracle - Chamado 744573
        CECRED.pc_internal_exception( pr_cdcooper => vr_cdcooper );

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_manter_taxa;

  /* Rotina de cadastro de taxa */
  PROCEDURE pc_cadastra_taxa_cdi(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                ,pr_dtmvtolt IN crapmfx.dtmvtolt%TYPE --> Data de Movimentacao
                                ,pr_vlmoefix IN crapmfx.vlmoefix%TYPE --> Valor da Moeda
                                ,pr_tpmoefix IN crapmfx.tpmoefix%TYPE --> Tipo da Moeda
                                ,pr_cdprogra IN crapprg.cdprogra%TYPE --> Programa Chamador
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica

  BEGIN
    /* .............................................................................

    Programa: pc_cadastra_taxa_cdi
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : 26/06/2014                        Ultima atualizacao: 27/09/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina de cadastro de taxas

    Alteracoes: 27/09/2017 - Inclusão do módulo e ação logado no oracle
                           - Inclusão da chamada de procedure em exception others
                           - Colocado logs no padrão
                             (Ana - Envolti - Chamado 744573)
    ............................................................................. */
    DECLARE
      vr_exc_saida EXCEPTION;

      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      vr_dtfimper DATE;
      vr_dtmvtolt DATE;
      vr_qtdiaute INTEGER := 0;
      vr_txprodia NUMBER(22,8);
      vr_flatuant BOOLEAN;
      vr_flgderro BOOLEAN := FALSE;
      
      rw_crapcop cr_crapcop%ROWTYPE;
      rw_crapdat cr_crapdat%ROWTYPE;

      -- CURSORES
      CURSOR cr_crapmfx(pr_cdcooper IN crapmfx.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapmfx.dtmvtolt%TYPE
                       ,pr_tpmoefix IN crapmfx.tpmoefix%TYPE) IS

      SELECT
        mfx.cdcooper
       ,mfx.dtmvtolt
       ,mfx.tpmoefix
       ,mfx.rowid
      FROM
       crapmfx mfx
      WHERE
            mfx.cdcooper = pr_cdcooper
        AND mfx.dtmvtolt = pr_dtmvtolt
        AND mfx.tpmoefix = pr_tpmoefix;

      rw_crapmfx cr_crapmfx%ROWTYPE;

      -- CURSORES
      CURSOR cr_crapgen(pr_cdcooper IN crapdtc.cdcooper%TYPE) IS

      SELECT
        dtc.cdcooper
       ,dtc.tpaplica
       ,ftx.vlfaixas
       ,ftx.cdperapl
       ,ftx.perapltx
       ,ftx.perrdttx
      FROM
        crapdtc dtc
       ,crapttx ttx
       ,crapftx ftx
      WHERE
        dtc.cdcooper = pr_cdcooper             AND
        dtc.flgstrdc = 1                       AND
        (dtc.tpaplrdc = 1 OR dtc.tpaplrdc = 2) AND
        ttx.cdcooper = dtc.cdcooper            AND
        ttx.tptaxrdc = dtc.tpaplica            AND
        ftx.cdcooper = dtc.cdcooper            AND
        ftx.tptaxrdc = dtc.tpaplica            AND
        ftx.cdperapl = ttx.cdperapl;

      rw_crapgen cr_crapgen%ROWTYPE;

      CURSOR cr_craptrd(pr_cdcooper IN craptrd.cdcooper%TYPE
                       ,pr_dtiniper IN craptrd.dtiniper%TYPE
                       ,pr_vlfaixas IN craptrd.vlfaixas%TYPE
                       ,pr_cdperapl IN craptrd.cdperapl%TYPE
                       ,pr_tptaxrda IN craptrd.tptaxrda%TYPE) IS

      SELECT
        trd.cdcooper
      FROM
        craptrd trd
      WHERE
        trd.cdcooper = pr_cdcooper AND
        trd.dtiniper = pr_dtiniper AND
        trd.tptaxrda = pr_tptaxrda AND
        trd.incarenc = 0           AND
        trd.vlfaixas = pr_vlfaixas AND
        trd.cdperapl = pr_cdperapl;

      rw_craptrd cr_craptrd%ROWTYPE;

    BEGIN
      -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0004.pc_cadastra_taxa_cdi');

      -- Busca do calendario da Cooperativa
      OPEN cr_crapdat(pr_cdcooper => 3);
      FETCH cr_crapdat
       INTO rw_crapdat;

      -- Se não encontrar
      IF cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE cr_crapdat;
        vr_cdcritic := 1;
        -- Levantar excecao
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapdat;
      END IF;

      IF cr_crapcop%ISOPEN THEN
         close cr_crapcop;
      END IF;
      
      OPEN cr_crapcop(pr_cdcooper => 0);
      LOOP
        FETCH cr_crapcop INTO rw_crapcop;

          -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
          EXIT WHEN cr_crapcop%NOTFOUND;
          
          IF UPPER(pr_cdprogra) = 'CRPS526' THEN

            vr_dscritic := 'TAXRDC AUTOMATICA PARA COOPERATIVA: '||rw_crapcop.nmrescop;
            
            --> Cria log para simples conferencia - Padronização - Chamado 744573
            CECRED.pc_log_programa(pr_dstiplog      => 'E', 
                                   pr_cdprograma    => pr_cdprogra, 
                                   pr_cdcooper      => pr_cdcooper, 
                                   pr_tpexecucao    => 2, --job
                                   pr_tpocorrencia  => 4,
                                   pr_cdcriticidade => 0, --baixa
                                   pr_dsmensagem    => vr_dscritic,                             
                                   pr_idprglog      => vr_idprglog,
                                   pr_nmarqlog      => NULL);
          END IF;

          OPEN cr_crapmfx(pr_cdcooper => rw_crapcop.cdcooper
                         ,pr_dtmvtolt => pr_dtmvtolt
                         ,pr_tpmoefix => pr_tpmoefix);

          FETCH cr_crapmfx INTO rw_crapmfx;

          IF cr_crapmfx%NOTFOUND THEN
            CLOSE cr_crapmfx;
            BEGIN
              INSERT INTO crapmfx(cdcooper, dtmvtolt, vlmoefix, tpmoefix)
                VALUES(rw_crapcop.cdcooper, pr_dtmvtolt, pr_vlmoefix, pr_tpmoefix);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir Taxa - 1: cdcooper:'||rw_crapcop.cdcooper
                               ||', dtmvtolt:'||pr_dtmvtolt||', tpmoefix:'||pr_tpmoefix
                               ||', vlmoefix:'||pr_vlmoefix||'. '||SQLERRM;
                RAISE vr_exc_saida;
            END;

            vr_dtfimper := GENE0005.fn_calc_data(pr_dtmvtolt => pr_dtmvtolt
                                                ,pr_qtmesano => 1
                                                ,pr_tpmesano => 'M'
                                                ,pr_des_erro => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;

            -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
            GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0004.pc_cadastra_taxa_cdi');

            vr_dtmvtolt := pr_dtmvtolt;
            vr_qtdiaute := 0;

            -- Calcula dias uteis entre periodo
            --IF UPPER(pr_cdprogra) <> 'CRPS526' THEN
              WHILE vr_dtmvtolt < vr_dtfimper LOOP
                -- Se não for domingo ou sabado e não for feriado
                IF TO_CHAR(vr_dtmvtolt,'D') NOT IN (1,7) AND
                   NOT FLXF0001.fn_verifica_feriado(rw_crapcop.cdcooper,vr_dtmvtolt) THEN
                  -- incrementar contador
                  vr_qtdiaute := vr_qtdiaute + 1;

                END IF;
                --Incrementar data
                vr_dtmvtolt := vr_dtmvtolt + 1;
              END LOOP;
            --END IF;

            OPEN cr_crapgen(pr_cdcooper => rw_crapcop.cdcooper);
            LOOP
              FETCH cr_crapgen INTO rw_crapgen;

                -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
                EXIT WHEN cr_crapgen%NOTFOUND;

                OPEN cr_craptrd(pr_cdcooper => rw_crapgen.cdcooper
                               ,pr_dtiniper => pr_dtmvtolt
                               ,pr_vlfaixas => rw_crapgen.vlfaixas
                               ,pr_cdperapl => rw_crapgen.cdperapl
                               ,pr_tptaxrda => rw_crapgen.tpaplica);

                FETCH cr_craptrd INTO rw_craptrd;

                IF cr_craptrd %NOTFOUND THEN
                  CLOSE cr_craptrd;

                  BEGIN
                    vr_txprodia := ((POWER((1 + pr_vlmoefix / 100),(1 / 252)) - 1) * 100);

                    INSERT INTO
                      craptrd(cdcooper, dtiniper, qtdiaute, tptaxrda, incarenc, vlfaixas, cdperapl, txprodia, txofidia)
                    VALUES(rw_crapgen.cdcooper, pr_dtmvtolt, vr_qtdiaute, rw_crapgen.tpaplica, 0,
                           rw_crapgen.vlfaixas, rw_crapgen.cdperapl, vr_txprodia,
                           (ROUND((vr_txprodia * rw_crapgen.perapltx / 100),6)));
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao inserir registro na CRAPTRD - 1: cdcooper:'||rw_crapgen.cdcooper
                                     ||', dtiniper:'||pr_dtmvtolt||', qtdiaute:'||vr_qtdiaute
                                     ||', tptaxrda:'||rw_crapgen.tpaplica||', incarenc:0'
                                     ||', vlfaixas:'||rw_crapgen.vlfaixas||', cdperapl:'||rw_crapgen.cdperapl
                                     ||', txprodia:'||vr_txprodia
                                     ||', txofidia:'||(ROUND((vr_txprodia * rw_crapgen.perapltx / 100),6))||'. '
                                     ||SQLERRM;
                      RAISE vr_exc_saida;
                  END;

                  IF rw_crapgen.perrdttx <> 0 THEN
                    BEGIN
                      vr_txprodia := ((POWER((1 + pr_vlmoefix / 100),(1 / 252)) - 1) * 100);

                      INSERT INTO
                        craptrd(cdcooper, dtiniper, qtdiaute, tptaxrda, incarenc, vlfaixas, cdperapl, txprodia, txofidia)
                      VALUES(rw_crapgen.cdcooper, pr_dtmvtolt, vr_qtdiaute, rw_crapgen.tpaplica, 1,
                             rw_crapgen.vlfaixas, rw_crapgen.cdperapl, vr_txprodia,
                             (ROUND((vr_txprodia * rw_crapgen.perrdttx / 100),6)));
                    EXCEPTION
                      WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao inserir registro na CRAPTRD - 2: cdcooper:'||rw_crapgen.cdcooper
                                     ||', dtiniper:'||pr_dtmvtolt||', qtdiaute:'||vr_qtdiaute
                                     ||', tptaxrda:'||rw_crapgen.tpaplica||', incarenc:1'
                                     ||', vlfaixas:'||rw_crapgen.vlfaixas||', cdperapl:'||rw_crapgen.cdperapl
                                     ||', txprodia:'||vr_txprodia
                                     ||', txofidia:'||(ROUND((vr_txprodia * rw_crapgen.perrdttx / 100),6))||'. '
                                     ||SQLERRM;
                        RAISE vr_exc_saida;
                    END;
                  END IF;

                ELSE

                  CLOSE cr_craptrd;
                  CONTINUE;

                END IF;

            END LOOP;
            CLOSE cr_crapgen;
            
            IF UPPER(pr_cdprogra) <> 'CRPS526' THEN
              IF pr_dtmvtolt = rw_crapdat.dtmvtolt THEN
                vr_flatuant := TRUE;
              ELSE
                vr_flatuant := FALSE;
              END IF;
            ELSE
              vr_flatuant := TRUE;
            END IF;

            APLI0004.pc_cadastra_taxa_cdi_mensal(pr_cdcooper => rw_crapcop.cdcooper --> Codigo da cooperativa
                                                ,pr_cdianual => pr_vlmoefix         --> Valor da taxa
                                                ,pr_dtperiod => pr_dtmvtolt         --> Data do periodo
                                                ,pr_dtdiaant => rw_crapdat.dtmvtoan --> Anterior dia util
                                                ,pr_dtdiapos => rw_crapdat.dtmvtopr --> Proximo dia util
                                                ,pr_flatuant => vr_flatuant         --> falta descricao
                                                ,pr_cdcritic => vr_cdcritic         --> Codigo da critica
                                                ,pr_dscritic => vr_dscritic);       --> Descricao de Erro

            IF vr_dscritic IS NOT NULL THEN
              vr_flgderro := TRUE;
              vr_dscritic := 'Erro ao cadastrar o CDI mensal - Cooperativa: ' || rw_crapcop.nmrescop || ', Erro: ' || vr_dscritic;
              RAISE vr_exc_saida;
            END IF;
            
            APLI0004.pc_cadastra_taxa_cdi_acumulado(pr_cdcooper => rw_crapcop.cdcooper --> Codigo da cooperativa
                                                   ,pr_cdianual => pr_vlmoefix         --> Valor da taxa
                                                   ,pr_dtperiod => pr_dtmvtolt         --> Data do periodo
                                                   ,pr_dtdiaant => rw_crapdat.dtmvtoan --> Anterior dia util
                                                   ,pr_dtdiapos => rw_crapdat.dtmvtopr --> Proximo dia util
                                                   ,pr_flatuant => vr_flatuant         --> falta descricao
                                                   ,pr_cdcritic => vr_cdcritic         --> Codigo da critica
                                                   ,pr_dscritic => vr_dscritic);       --> Descricao de Erro
            
            IF vr_dscritic IS NOT NULL THEN
              vr_flgderro := TRUE;
              vr_dscritic := 'Erro ao cadastrar o CDI acumulado - Cooperativa: ' || rw_crapcop.nmrescop || ', Erro: ' || vr_dscritic;
              RAISE vr_exc_saida;
            END IF;  

            -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
            GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0004.pc_cadastra_taxa_cdi');
            
            IF UPPER(pr_cdprogra) = 'CRPS526' THEN
              vr_dscritic := 'TAXRDC CADASTRADA PARA COOPERATIVA: '||rw_crapcop.nmrescop;
                                                            
              -- Cria log informando que as taxas ja estao cadastradas
              CECRED.pc_log_programa(pr_dstiplog      => 'E', 
                                     pr_cdprograma    => pr_cdprogra, 
                                     pr_cdcooper      => pr_cdcooper, 
                                     pr_tpexecucao    => 2, --job
                                     pr_tpocorrencia  => 4,
                                     pr_cdcriticidade => 0, --baixa
                                     pr_dsmensagem    => vr_dscritic,                             
                                     pr_idprglog      => vr_idprglog,
                                     pr_nmarqlog      => NULL);
            END IF;
                                    
         ELSE

           CLOSE cr_crapmfx;
           
           IF UPPER(pr_cdprogra) = 'CRPS526' THEN

              vr_dscritic := 'TAXRDC JA EXISTE PARA COOPERATIVA: '||rw_crapcop.nmrescop;
                                                            
              -- Cria log informando que as taxas ja estao cadastradas
              CECRED.pc_log_programa(pr_dstiplog      => 'E', 
                                     pr_cdprograma    => pr_cdprogra, 
                                     pr_cdcooper      => pr_cdcooper, 
                                     pr_tpexecucao    => 2, --job
                                     pr_tpocorrencia  => 4,
                                     pr_cdcriticidade => 0, --baixa
                                     pr_dsmensagem    => vr_dscritic,                             
                                     pr_idprglog      => vr_idprglog,
                                     pr_nmarqlog      => NULL);
           END IF;  
           CONTINUE;

         END IF;
      END LOOP;
      CLOSE cr_crapcop;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em cadastro de taxa: '||SQLERRM;

        --Inclusão na tabela de erros Oracle - Chamado 744573
        CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper );

        ROLLBACK;
    END;
  END pc_cadastra_taxa_cdi;

  /* Rotina de alteracao de taxa */
  PROCEDURE pc_altera_taxa_cdi(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                              ,pr_dtmvtolt IN crapmfx.dtmvtolt%TYPE --> Data de Movimentacao
                              ,pr_vlmoefix IN crapmfx.vlmoefix%TYPE --> Valor da Moeda
                              ,pr_tpmoefix IN crapmfx.tpmoefix%TYPE --> Tipo da Moeda
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica

  BEGIN
    /* .............................................................................

    Programa: pc_altera_taxa_cdi
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : 26/06/2014                        Ultima atualizacao: 27/09/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina de alteracao de taxa CDI

    Alteracoes: 27/09/2017 - Inclusão do módulo e ação logado no oracle
                           - Inclusão da chamada de procedure em exception others
                           - Colocado logs no padrão
                             (Ana - Envolti - Chamado 744573)
    ............................................................................. */
    DECLARE
      vr_exc_saida EXCEPTION;

      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      vr_incalcul BOOLEAN := TRUE;
      vr_flatuant BOOLEAN;
      
      vr_auxrowid ROWID;

      vr_txprodia crapmfx.vlmoefix%TYPE;

      pr_tab_erro GENE0001.typ_tab_erro;
      
      rw_crapcop cr_crapcop%ROWTYPE;
      rw_crapdat cr_crapdat%ROWTYPE;

      -- CURSORES
      CURSOR cr_crapmfx(pr_cdcooper IN crapmfx.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapmfx.dtmvtolt%TYPE
                       ,pr_tpmoefix IN crapmfx.tpmoefix%TYPE) IS

      SELECT
        mfx.cdcooper
       ,mfx.dtmvtolt
       ,mfx.tpmoefix
       ,mfx.rowid
      FROM
       crapmfx mfx
      WHERE
            mfx.cdcooper = pr_cdcooper
        AND mfx.dtmvtolt = pr_dtmvtolt
        AND mfx.tpmoefix = pr_tpmoefix;

      rw_crapmfx cr_crapmfx%ROWTYPE;

      -- CURSORES
     CURSOR cr_craptrd(pr_cdcooper IN craptrd.cdcooper%TYPE
                      ,pr_dtiniper IN craptrd.dtiniper%TYPE
                      ,pr_tptaxrda IN craptrd.tptaxrda%TYPE
                      ,pr_incalcul IN craptrd.incalcul%TYPE) IS

      SELECT
        trd.cdcooper
       ,trd.dtiniper
       ,trd.tptaxrda
       ,trd.incalcul
       ,trd.vltrapli
      FROM
        craptrd trd
      WHERE
            trd.cdcooper = pr_cdcooper
        AND trd.dtiniper = pr_dtiniper
        AND trd.tptaxrda < pr_tptaxrda
        AND trd.incalcul = pr_incalcul
        AND rownum = 1
      ORDER BY
        trd.rowid ASC;

      rw_craptrd cr_craptrd%ROWTYPE;

    CURSOR cr_crapgen(pr_cdcooper IN craptrd.cdcooper%TYPE) IS

      SELECT 
        ftx.perapltx
       ,ftx.perrdttx
       ,dtc.tpaplica
       ,ttx.cdperapl
       ,ftx.vlfaixas
      FROM
        crapdtc dtc
       ,crapttx ttx
       ,crapftx ftx
      WHERE 
            dtc.cdcooper = pr_cdcooper
        AND ttx.cdcooper = dtc.cdcooper
        AND ftx.cdcooper = dtc.cdcooper
        AND dtc.flgstrdc = 1
        AND (dtc.tpaplrdc = 1
         OR dtc.tpaplrdc = 2)
        AND ttx.tptaxrdc = dtc.tpaplica
        AND ftx.tptaxrdc = dtc.tpaplica
        AND ftx.cdperapl = ttx.cdperapl;

      rw_crapgen cr_crapgen%ROWTYPE;
    
    CURSOR cr_craptrd_II (pr_cdcooper IN craptrd.cdcooper%TYPE
                         ,pr_dtiniper IN craptrd.dtiniper%TYPE
                         ,pr_tptaxrda IN craptrd.tptaxrda%TYPE
                         ,pr_cdperapl IN craptrd.cdperapl%TYPE
                         ,pr_vlfaixas IN craptrd.vlfaixas%TYPE) IS
      SELECT
        trd.incarenc
       ,trd.rowid
      FROM 
        craptrd trd
      WHERE 
            trd.cdcooper = pr_cdcooper
        AND trd.dtiniper = pr_dtiniper
        AND trd.tptaxrda = pr_tptaxrda
        AND trd.cdperapl = pr_cdperapl
        AND trd.vlfaixas = pr_vlfaixas
        AND trd.incalcul = 0;

      rw_craptrd_II cr_craptrd_II%ROWTYPE;  
    BEGIN
      -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
      GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'APLI0004.pc_altera_taxa_cdi');

      -- Busca do calendario da Cooperativa
      OPEN cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapdat
       INTO rw_crapdat;

      -- Se não encontrar
      IF cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE cr_crapdat;
        vr_cdcritic := 1;
        -- Levantar excecao
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapdat;
      END IF;

      OPEN cr_crapcop(pr_cdcooper => 0);

      LOOP
        FETCH cr_crapcop INTO rw_crapcop;

          -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
          EXIT WHEN cr_crapcop%NOTFOUND;

          OPEN cr_crapmfx(pr_cdcooper => rw_crapcop.cdcooper
                         ,pr_dtmvtolt => pr_dtmvtolt
                         ,pr_tpmoefix => pr_tpmoefix);

          FETCH cr_crapmfx INTO rw_crapmfx;

          IF cr_crapmfx%NOTFOUND THEN
            CLOSE cr_crapmfx;
            -- Chamar rotina de gravacao de erro
            gene0001.pc_gera_erro(pr_cdcooper => rw_crapcop.cdcooper
                                 ,pr_cdagenci => 1
                                 ,pr_nrdcaixa => 999
                                 ,pr_nrsequen => 1 --> Fixo
                                 ,pr_cdcritic => 347 --> Critica 347
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);

            RAISE vr_exc_saida;                                   
          ELSE
            CLOSE cr_crapmfx;
            vr_auxrowid := rw_crapmfx.rowid;
          END IF;
          
          OPEN cr_craptrd(pr_cdcooper => rw_crapcop.cdcooper
                         ,pr_dtiniper => pr_dtmvtolt
                         ,pr_tptaxrda => 6
                         ,pr_incalcul => 2);

          FETCH cr_craptrd INTO rw_craptrd;
         
          IF cr_craptrd%NOTFOUND THEN
            CLOSE cr_craptrd;
          ELSE
            CLOSE cr_craptrd;

            IF rw_craptrd.vltrapli <> pr_vlmoefix THEN
              -- Chamar rotina de gravacao de erro
              gene0001.pc_gera_erro(pr_cdcooper => rw_crapcop.cdcooper
                                   ,pr_cdagenci => 1
                                   ,pr_nrdcaixa => 999
                                   ,pr_nrsequen => 1 --> Fixo
                                   ,pr_cdcritic => 424 --> Critica 424
                                   ,pr_dscritic => vr_dscritic
                                   ,pr_tab_erro => pr_tab_erro);

              RAISE vr_exc_saida;
            END IF; 
          END IF;

          OPEN cr_crapgen(pr_cdcooper => rw_crapcop.cdcooper);

          LOOP
            FETCH cr_crapgen INTO rw_crapgen;

            -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
            EXIT WHEN cr_crapgen%NOTFOUND; 

            OPEN cr_craptrd_II (pr_cdcooper => rw_crapcop.cdcooper
                               ,pr_dtiniper => pr_dtmvtolt
                               ,pr_tptaxrda => rw_crapgen.tpaplica
                               ,pr_cdperapl => rw_crapgen.cdperapl
                               ,pr_vlfaixas => rw_crapgen.vlfaixas);
            LOOP
              FETCH cr_craptrd_II INTO rw_craptrd_II;

              -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
              EXIT WHEN cr_craptrd_II%NOTFOUND; 
              
              vr_txprodia := (POWER((1 + pr_vlmoefix / 100), (1 / 252)) - 1) * 100;
              vr_incalcul := FALSE;

              IF rw_craptrd_II.incarenc = 0 THEN
                
                BEGIN
                  UPDATE craptrd
                  SET    craptrd.txprodia = vr_txprodia,
                         craptrd.txofidia = ROUND((vr_txprodia * rw_crapgen.perapltx / 100 ),6)
                  WHERE  craptrd.rowid = rw_craptrd_II.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    -- Descricao do erro na atualizacao de registros
                    vr_dscritic := 'Erro ao atualizar registro na CRAPTRD - 5: txprodia:'||vr_txprodia
                                   ||', txofidia:'||ROUND((vr_txprodia * rw_crapgen.perapltx / 100 ),6)
                                   ||' com rowid:'||rw_craptrd_II.rowid||'. '||SQLERRM;
                    RAISE vr_exc_saida;
                END;  

              ELSIF rw_craptrd_II.incarenc = 1 THEN
                
                BEGIN
                  UPDATE craptrd
                  SET    craptrd.txprodia = vr_txprodia,
                         craptrd.txofidia = ROUND((vr_txprodia * rw_crapgen.perrdttx / 100 ),6)
                  WHERE  craptrd.rowid = rw_craptrd_II.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    -- Descricao do erro na atualizacao de registros
                    vr_dscritic := 'Erro ao atualizar registro na CRAPTRD - 6: txprodia:'||vr_txprodia
                                   ||', txofidia:'||ROUND((vr_txprodia * rw_crapgen.perapltx / 100 ),6)
                                   ||' com rowid:'||rw_craptrd_II.rowid||'. '||SQLERRM;
                    RAISE vr_exc_saida;
                END;  

              END IF;

            END LOOP;
            CLOSE cr_craptrd_II;
            
          END LOOP;
          CLOSE cr_crapgen;

          IF vr_incalcul = FALSE THEN

            BEGIN
              UPDATE crapmfx
              SET    crapmfx.vlmoefix = pr_vlmoefix
              WHERE  crapmfx.rowid = vr_auxrowid;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na atualizacao de registros
                vr_dscritic := 'Erro ao atualizar registro na CRAPMFX - 1: vlmoefix:'||pr_vlmoefix
                               ||' com rowid:'||vr_auxrowid||'. '||SQLERRM;
                RAISE vr_exc_saida;
            END;  
          END IF;             
                        
          IF pr_dtmvtolt = rw_crapdat.dtmvtolt THEN
              vr_flatuant := TRUE;
          ELSE
              vr_flatuant := FALSE;
          END IF;
          
          APLI0004.pc_cadastra_taxa_cdi_mensal(pr_cdcooper => rw_crapcop.cdcooper --> Codigo da cooperativa
                                              ,pr_cdianual => pr_vlmoefix         --> Valor da taxa
                                              ,pr_dtperiod => pr_dtmvtolt         --> Data do periodo
                                              ,pr_dtdiaant => rw_crapdat.dtmvtoan --> Anterior dia util
                                              ,pr_dtdiapos => rw_crapdat.dtmvtopr --> Proximo dia util
                                              ,pr_flatuant => vr_flatuant         --> falta descricao
                                              ,pr_cdcritic => vr_cdcritic         --> Codigo da critica
                                              ,pr_dscritic => vr_dscritic);       --> Descricao de Erro

          IF vr_dscritic IS NOT NULL THEN
            vr_dscritic := 'Erro ao cadastrar o CDI mensal - Cooperativa: ' || rw_crapcop.nmrescop || ', Erro: ' || vr_dscritic;
            RAISE vr_exc_saida;
          END IF;
          
          APLI0004.pc_cadastra_taxa_cdi_acumulado(pr_cdcooper => rw_crapcop.cdcooper --> Codigo da cooperativa
                                                 ,pr_cdianual => pr_vlmoefix         --> Valor da taxa
                                                 ,pr_dtperiod => pr_dtmvtolt         --> Data do periodo
                                                 ,pr_dtdiaant => rw_crapdat.dtmvtoan --> Anterior dia util
                                                 ,pr_dtdiapos => rw_crapdat.dtmvtopr --> Proximo dia util
                                                 ,pr_flatuant => vr_flatuant         --> falta descricao
                                                 ,pr_cdcritic => vr_cdcritic         --> Codigo da critica
                                                 ,pr_dscritic => vr_dscritic);       --> Descricao de Erro
            
          IF vr_dscritic IS NOT NULL THEN
            vr_dscritic := 'Erro ao cadastrar o CDI acumulado - Cooperativa: ' || rw_crapcop.nmrescop || ', Erro: ' || vr_dscritic;
            RAISE vr_exc_saida;
          END IF;
          
          -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
          GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0004.pc_altera_taxa_cdi');
        END LOOP;
        CLOSE cr_crapcop;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em alteracao de taxa: '||SQLERRM;

        --Inclusão na tabela de erros Oracle - Chamado 744573
        CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper );

        ROLLBACK;
    END;
  END pc_altera_taxa_cdi;

  -- Cadastro de taxa CDI acumulada
  PROCEDURE pc_cadastra_taxa_cdi_acumulado(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                          ,pr_cdianual  IN NUMBER               --> Valor do CDI anual
                                          ,pr_dtperiod  IN craptrd.dtiniper%TYPE --> Data do Periodo
                                          ,pr_dtdiaant  IN DATE                  --> Qtd de Dias Anteriores
                                          ,pr_dtdiapos  IN DATE                  --> Quantidade de Proximos dias
                                          ,pr_flatuant  IN BOOLEAN               --> Verifica se deve atualizar p/ dias anteriores
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo de Erro
                                          ,pr_dscritic OUT VARCHAR2) IS          --> Descricao de Erro
  BEGIN

    /* .............................................................................

     Programa: pc_cadastra_taxa_cdi_acumulado
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Junho/14.                    Ultima atualizacao: 27/09/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de cadastro de taxa CDI acumulado.

     Observacao: -----

    Alteracoes: 27/09/2017 - Inclusão do módulo e ação logado no oracle
                           - Inclusão da chamada de procedure em exception others
                           - Colocado logs no padrão
                             (Ana - Envolti - Chamado 744573)
     ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_rowid ROWID;
      vr_dtiniper DATE;
      vr_dtultdia DATE;
      vr_contdias INTEGER := 1;
      vr_contador INTEGER := 0;
      vr_cdidiari NUMBER(20,8) := 0;
      vr_cdiacuml NUMBER(20,8) := 0;
      vr_dtperiod DATE;
      vr_vlmoefix crapmfx.vlmoefix%TYPE;

      -- CURSORES
      CURSOR cr_crapmfx(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Codigo da cooperativa
                       ,pr_dtperiod IN crapmfx.dtmvtolt%TYPE     --> Data do periodo
                       ,pr_tpmoefix IN crapmfx.tpmoefix%TYPE) IS --> Tipo de moeda

      SELECT
       mfx.cdcooper
      ,mfx.dtmvtolt
      ,mfx.tpmoefix
      ,mfx.vlmoefix
      ,mfx.rowid
      FROM
        crapmfx mfx
      WHERE
            mfx.cdcooper = pr_cdcooper
        AND mfx.dtmvtolt = pr_dtperiod 
        AND mfx.tpmoefix = pr_tpmoefix;
      
      rw_crapmfx cr_crapmfx%ROWTYPE;

      BEGIN
        -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
        GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'APLI0004.pc_cadastra_taxa_cdi_acumulado');
        
        -- Calcular CDI Diário
        vr_cdidiari := ROUND(((POWER(1 + (pr_cdianual / 100), 1 / 252) - 1) * 100),8);
        vr_cdiacuml := 0;

        -- Busca registro de taxa
        OPEN cr_crapmfx(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                       ,pr_dtperiod => pr_dtperiod --> Data do periodo
                       ,pr_tpmoefix => 18);        --> Tipo de moeda

        FETCH cr_crapmfx
         INTO rw_crapmfx;

        -- Se não encontrar insere registro
        IF cr_crapmfx%NOTFOUND THEN
          CLOSE cr_crapmfx; 
          BEGIN
            INSERT INTO crapmfx(cdcooper, dtmvtolt, tpmoefix, vlmoefix)
              VALUES(pr_cdcooper, pr_dtperiod, 18, vr_cdidiari) RETURNING ROWID INTO vr_rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir CDI: dtmvtolt:'||pr_dtperiod||', tpmoefix:18'
                             ||', vlmoefix:'||vr_cdidiari||'. '||SQLERRM;
              RAISE vr_exc_saida;  
          END;
        ELSE
          CLOSE cr_crapmfx;
          BEGIN
            UPDATE crapmfx
            SET    vlmoefix = vr_cdidiari
            WHERE  crapmfx.rowid = rw_crapmfx.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              -- Descricao do erro na atualizacao de registros
              vr_dscritic := 'Erro ao atualizar CDI - 1: vlmoefix:'||vr_cdidiari
                             ||' com rowid:'||rw_crapmfx.rowid||'. '||SQLERRM;
            RAISE vr_exc_saida;
          END;
        END IF;

        -- Calcular CDI ACUMULADO -  Gravar o CDI Acumulado no crapmfx (tipo 17)
        
        -- Monta data com primeiro dia do mes            
        vr_dtperiod := to_date('01/'|| to_char(pr_dtperiod,'mm') || '/' || to_char(pr_dtperiod,'yyyy'),'dd/mm/yyyy');

        -- Verificar o primeiro dia útil do mês
        vr_dtperiod := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                  ,pr_dtmvtolt => vr_dtperiod
                                                  ,pr_tipo => 'P');

        -- Quando for o primeiro dia útil do mês, o valor do CDI Acumulado será igual ao valor do CDI Diário
        IF pr_dtperiod = vr_dtperiod THEN
          -- Busca registro de taxa
          OPEN cr_crapmfx(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                         ,pr_dtperiod => vr_dtperiod --> Data do periodo
                         ,pr_tpmoefix => 17);        --> Tipo de moeda

          FETCH cr_crapmfx
           INTO rw_crapmfx;
           
          -- Se não encontrar insere registro
          IF cr_crapmfx%NOTFOUND THEN
            CLOSE cr_crapmfx; 

            BEGIN
              INSERT INTO crapmfx(cdcooper, dtmvtolt, tpmoefix, vlmoefix)
                VALUES(pr_cdcooper, vr_dtperiod, 17, vr_cdidiari) RETURNING ROWID INTO vr_rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir CDI Acumulado: dtmvtolt:'||vr_dtperiod||', tpmoefix:17'
                               ||', vlmoefix:'||vr_cdidiari||'. '||SQLERRM;

                RAISE vr_exc_saida;  
            END;
          ELSE
            CLOSE cr_crapmfx;

            BEGIN
              UPDATE crapmfx
              SET    vlmoefix = vr_cdidiari
              WHERE  crapmfx.rowid = rw_crapmfx.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na atualizacao de registros
                vr_dscritic := 'Erro ao atualizar CDI - 2: vlmoefix:'||vr_cdidiari
                               ||' com rowid:'||rw_crapmfx.rowid||'. '||SQLERRM;
                RAISE vr_exc_saida;
            END;
          END IF;
        ELSE
          -- Para os demais dias do mes - o calculo é acumulado
          -- Verifica dias anteriores
          IF pr_flatuant THEN -- Ver se deve atual. p/ dias ant.
  
            vr_contador := pr_dtperiod - pr_dtdiaant;

            IF vr_contador > 1 THEN
              -- Busca registro de taxa
              OPEN cr_crapmfx(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                             ,pr_dtperiod => pr_dtdiaant --> Data do periodo
                             ,pr_tpmoefix => 17);        --> Tipo de moeda

              FETCH cr_crapmfx
               INTO rw_crapmfx;
               
              -- Se não encontrar insere registro
              IF cr_crapmfx%FOUND THEN
                
                CLOSE cr_crapmfx;
                vr_vlmoefix := rw_crapmfx.vlmoefix;
                vr_contdias := 1;

                LOOP
                  EXIT WHEN vr_contdias > vr_contador - 1;

                  vr_dtiniper := pr_dtdiaant + vr_contdias;
                   
                  -- Busca registro de taxa
                  OPEN cr_crapmfx(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                                 ,pr_dtperiod => vr_dtiniper --> Data do periodo
                                 ,pr_tpmoefix => 17);        --> Tipo de moeda

                  FETCH cr_crapmfx
                    INTO rw_crapmfx;
                                             
                  -- Se não encontrar insere registro
                  IF cr_crapmfx%NOTFOUND THEN               
                    CLOSE cr_crapmfx;                    
                    BEGIN 
                      INSERT INTO crapmfx(cdcooper, dtmvtolt, tpmoefix, vlmoefix)
                        VALUES(pr_cdcooper, vr_dtiniper, 17, vr_vlmoefix);
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_dscritic := 'Erro ao inserir taxa na tabela CRAPMFX - 1: dtmvtolt:'||vr_dtiniper
                                       ||', tpmoefix:17'||', vlmoefix:'||vr_vlmoefix||'. '||SQLERRM;
                        RAISE vr_exc_saida; 
                    END;            
                  ELSE
                    CLOSE cr_crapmfx;
                    BEGIN
                      UPDATE crapmfx
                      SET    vlmoefix = vr_vlmoefix
                      WHERE  crapmfx.rowid = rw_crapmfx.rowid;
                    EXCEPTION
                      WHEN OTHERS THEN
                        -- Descricao do erro na atualizacao de registros
                        vr_dscritic := 'Erro ao atualizar taxa na tabela CRAPMFX - 2: vlmoefix:'||vr_vlmoefix
                                       ||' com rowid:'||rw_crapmfx.rowid||'. '||SQLERRM;
                        RAISE vr_exc_saida; 
                    END;
                  END IF;

                  vr_contdias := vr_contdias + 1;

                END LOOP; 
              ELSE
                CLOSE cr_crapmfx;                
              END IF;                   

            END IF;

          END IF;

          -- Grava o CDI ACUMULADO diariamente
          
          -- Busca registro de taxa
          OPEN cr_crapmfx(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                         ,pr_dtperiod => pr_dtdiaant --> Data do periodo
                         ,pr_tpmoefix => 17);        --> Tipo de moeda

          FETCH cr_crapmfx
           INTO rw_crapmfx;
               
          -- Se não encontrar insere registro
          IF cr_crapmfx%FOUND THEN
            CLOSE cr_crapmfx;
            vr_cdiacuml := ROUND(((((vr_cdidiari / 100) + 1 ) * 
                            ((rw_crapmfx.vlmoefix / 100) + 1)) - 1) * 100, 8);

          ELSE
            CLOSE cr_crapmfx;
            vr_cdiacuml := vr_cdidiari;            
          END IF;
          
          -- Busca registro de taxa
          OPEN cr_crapmfx(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                         ,pr_dtperiod => pr_dtperiod --> Data do periodo
                         ,pr_tpmoefix => 17);        --> Tipo de moeda

          FETCH cr_crapmfx
           INTO rw_crapmfx;
               
          -- Se não encontrar insere registro
          IF cr_crapmfx%NOTFOUND THEN

            CLOSE cr_crapmfx;

            BEGIN
              INSERT INTO crapmfx(cdcooper, dtmvtolt, tpmoefix, vlmoefix)
                VALUES(pr_cdcooper, pr_dtperiod, 17, vr_cdiacuml);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir taxa na tabela CRAPMFX - 2: dtmvtolt:'||pr_dtperiod
                                       ||', tpmoefix:17'||', vlmoefix:'||vr_cdiacuml||'. '||SQLERRM;
                RAISE vr_exc_saida; 
            END;                
          ELSE

            CLOSE cr_crapmfx;

            BEGIN
              UPDATE crapmfx
              SET    vlmoefix = vr_cdiacuml
              WHERE  crapmfx.rowid = rw_crapmfx.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na atualizacao de registros
                vr_dscritic := 'Erro ao atualizar CDI - 3: vlmoefix:'||vr_cdiacuml
                               ||' com rowid:'||rw_crapmfx.rowid||'. '||SQLERRM;
              RAISE vr_exc_saida;
            END;
          END IF;

          IF pr_flatuant THEN  -- Ver se deve atual. p/ dias post.
            -- Cadastra Taxa para dias posteriores do proprio MES, caso a viarada do mes for um final de semana
            IF TO_CHAR(pr_dtdiapos,'mm') <> TO_CHAR(pr_dtperiod,'mm') THEN

              vr_dtultdia := to_date('01/'|| to_char(pr_dtdiapos,'mm') || '/' || to_char(pr_dtdiapos,'yyyy'),'dd/mm/yyyy') - 1;
              vr_contador := (vr_dtultdia - pr_dtperiod);
              
              IF vr_contador > 0 THEN

                -- Busca registro de taxa
                OPEN cr_crapmfx(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                               ,pr_dtperiod => pr_dtperiod --> Data do periodo
                               ,pr_tpmoefix => 17);        --> Tipo de moeda

                FETCH cr_crapmfx
                 INTO rw_crapmfx;
                     
                -- Se não encontrar insere registro
                IF cr_crapmfx%FOUND THEN
                  CLOSE cr_crapmfx;

                  vr_contdias := 1;
                  vr_vlmoefix := rw_crapmfx.vlmoefix;

                  LOOP
                    EXIT WHEN vr_contdias > vr_contador;
                    
                    vr_dtiniper := pr_dtperiod + vr_contdias; 
                    
                    -- Busca registro de taxa
                    OPEN cr_crapmfx(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                                   ,pr_dtperiod => vr_dtiniper --> Data do periodo
                                   ,pr_tpmoefix => 17);        --> Tipo de moeda

                    FETCH cr_crapmfx
                     INTO rw_crapmfx;
                         
                    -- Se não encontrar insere registro
                    IF cr_crapmfx%NOTFOUND THEN
                      CLOSE cr_crapmfx;
                      
                      BEGIN
                        INSERT INTO crapmfx(cdcooper, dtmvtolt, tpmoefix, vlmoefix)
                          VALUES(pr_cdcooper, vr_dtiniper, 17, vr_vlmoefix);
                      EXCEPTION
                        WHEN OTHERS THEN
	                         vr_dscritic := 'Erro ao inserir taxa na tabela CRAPMFX - 3: dtmvtolt:'||vr_dtiniper
                                          ||', tpmoefix:17'||', vlmoefix:'||vr_vlmoefix||'. '||SQLERRM;
                          RAISE vr_exc_saida; 
                      END;
                    ELSE

                      CLOSE cr_crapmfx;

                      BEGIN
                        UPDATE crapmfx
                        SET    vlmoefix = vr_vlmoefix
                        WHERE  crapmfx.rowid = rw_crapmfx.rowid;
                      EXCEPTION
                        WHEN OTHERS THEN
                          -- Descricao do erro na atualizacao de registros
                          vr_dscritic := 'Erro ao atualizar CDI - 4: vlmoefix:'||vr_vlmoefix
                                         ||' com rowid:'||rw_crapmfx.rowid||'. '||SQLERRM;
                        RAISE vr_exc_saida;
                      END;
                    END IF;
                    
                    vr_contdias := vr_contdias + 1;

                  END LOOP;
                ELSE
                  CLOSE cr_crapmfx;                                    
                END IF;

              END IF;
            END IF;
          END IF;                     
        END IF;
        
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_cadastra_taxa_cdi_acumulado: '||SQLERRM;

        --Inclusão na tabela de erros Oracle - Chamado 744573
        CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper );

        ROLLBACK;
    END;
  END pc_cadastra_taxa_cdi_acumulado;

  -- Calculo da poupanca
  PROCEDURE pc_poupanca(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                       ,pr_dtperiod  IN craptrd.dtiniper%TYPE --> Data do Periodo
                       ,pr_vltaxatr  IN crapmfx.vlmoefix%TYPE --> Valor taxa TR
                       ,pr_vlpoupan OUT crapmfx.vlmoefix%TYPE --> Valor taxa Poupanca
                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo de Erro
                       ,pr_dscritic OUT VARCHAR2) IS          --> Descricao de Erro
  BEGIN

    /* .............................................................................

     Programa: pc_poupanca                   Antiga: b1wgen0128.p/poupanca
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Junho/14.                    Ultima atualizacao: 27/09/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de cadastro de taxa poupanca.

     Observacao: -----

     Alteracoes: 27/09/2017 - Inclusão do módulo e ação logado no oracle
                            - Inclusão da chamada de procedure em exception others
                            - Colocado logs no padrão
                              (Ana - Envolti - Chamado 744573)
     ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      vr_txmespop craptrd.txofimes%TYPE := 0;
      vr_txdiapop craptrd.txofidia%TYPE := 0;
      
      vr_vlpoupan NUMBER(20,8) := 0;
      vr_vlpoupnr NUMBER(20,8) := 0;
      vr_taxselic NUMBER(20,8) := 0;
      vr_vlcdimes NUMBER(20,8) := 0;      
      vr_vltxadic NUMBER(20,8) := 0;
      vr_txofimes NUMBER(20,8) := 0;
      vr_txofidia NUMBER(20,8) := 0;

      vr_auxvapli NUMBER(20,8) := 0;
      vr_auxfimes NUMBER(20,8) := 0;
      vr_auxfidia NUMBER(20,8) := 0;

      vr_ind      INTEGER := 0;
      vr_contador INTEGER := 0;
      vr_qtdtxtab INTEGER := 0;
      vr_qtdiaute INTEGER := 0;
      
      vr_dtfimper DATE;

      vr_regexist BOOLEAN := TRUE;

      vr_vllidtab VARCHAR2(1000);
      
      vr_rowidtrd ROWID;
      
      -- Array para guardar o split dos dados contidos na dstextab
      vr_vet_dados gene0002.typ_split;

      TYPE typ_comando IS TABLE OF NUMBER(20,8) INDEX BY PLS_INTEGER;
      
      vr_tptaxcdi typ_comando;
      vr_txadical typ_comando;
      vr_vlfaixas typ_comando;

      -- CURSORES
      CURSOR cr_crapmfx(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Codigo da cooperativa
                       ,pr_dtperiod IN crapmfx.dtmvtolt%TYPE     --> Data do periodo
                       ,pr_tpmoefix IN crapmfx.tpmoefix%TYPE) IS --> Tipo de moeda

      SELECT
       mfx.cdcooper
      ,mfx.dtmvtolt
      ,mfx.tpmoefix
      ,mfx.vlmoefix
      ,mfx.rowid
      FROM
        crapmfx mfx
      WHERE
            mfx.cdcooper = pr_cdcooper
        AND mfx.dtmvtolt = pr_dtperiod 
        AND mfx.tpmoefix = pr_tpmoefix;
      
      rw_crapmfx cr_crapmfx%ROWTYPE;

      CURSOR cr_craptab(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Codigo da cooperativa
                       ,pr_nmsistem IN craptab.nmsistem%TYPE     --> Nome do sistema
                       ,pr_tptabela IN craptab.tptabela%TYPE     --> Tipo de tabela
                       ,pr_cdacesso IN craptab.cdacesso%TYPE) IS --> Codigo de acesso
      
      SELECT
        tab.dstextab
       ,tab.tpregist
      FROM
        craptab tab
      WHERE tab.cdcooper = pr_cdcooper
        AND UPPER(tab.nmsistem) = pr_nmsistem
        AND UPPER(tab.tptabela) = pr_tptabela
        AND UPPER(tab.cdacesso) = pr_cdacesso;
      
      rw_craptab cr_craptab%ROWTYPE;

      CURSOR cr_craptrd(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtperiod IN craptrd.dtiniper%TYPE
                       ,pr_tptaxrda IN craptrd.tptaxrda%TYPE
                       ,pr_incarenc IN craptrd.incarenc%TYPE
                       ,pr_vlfaixas IN craptrd.vlfaixas%TYPE) IS
        SELECT
           ROWID
        FROM
          craptrd trd
        WHERE
              trd.cdcooper = pr_cdcooper
          AND trd.dtiniper = pr_dtperiod
          AND trd.tptaxrda = pr_tptaxrda
          AND trd.incarenc = pr_incarenc
          AND trd.vlfaixas = pr_vlfaixas;

        rw_craptrd cr_craptrd%ROWTYPE;

      BEGIN
        -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
        GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'APLI0004.pc_poupanca');
        
        -- Verifica se taxa SELIC esta cadastrada
        -- Busca registro de taxa
        OPEN cr_crapmfx(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                       ,pr_dtperiod => pr_dtperiod --> Data do periodo
                       ,pr_tpmoefix => 19);        --> Tipo de moeda

        FETCH cr_crapmfx
         INTO rw_crapmfx;

        -- Se não encontrar insere registro
        IF cr_crapmfx%NOTFOUND THEN
          CLOSE cr_crapmfx; 
          vr_dscritic := 'Para cadastrar a TR, primeiro cadastre a SELIC Meta para o dia informado.';
          RAISE vr_exc_saida;            
        ELSE
          CLOSE cr_crapmfx;
          vr_taxselic := rw_crapmfx.vlmoefix;
        END IF;
        
        -- Fim verificacao SELIC

        -- Verifica se taxa TR esta cadastrada

        -- Busca registro de taxa
        OPEN cr_crapmfx(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                       ,pr_dtperiod => pr_dtperiod --> Data do periodo
                       ,pr_tpmoefix => 11);        --> Tipo de moeda

        FETCH cr_crapmfx
         INTO rw_crapmfx;

        -- Se não encontrar insere registro
        IF cr_crapmfx%NOTFOUND THEN
          CLOSE cr_crapmfx; 
          
          BEGIN
          	-- Insere registro de taxa TR
            INSERT INTO crapmfx(cdcooper, dtmvtolt, tpmoefix, vlmoefix)
              VALUES(pr_cdcooper, pr_dtperiod, 11, pr_vltaxatr);
          EXCEPTION
            WHEN OTHERS THEN
               vr_dscritic := 'Erro ao inserir taxa TR: dtmvtolt:'||pr_dtperiod
                              ||', tpmoefix:11'||', vlmoefix:'||pr_vltaxatr||'. '||SQLERRM;
          END;  
          
        ELSE
          CLOSE cr_crapmfx;

          BEGIN
            -- Atualiza registro taxa TR
            UPDATE crapmfx
            SET    vlmoefix = pr_vltaxatr
            WHERE  cdcooper = pr_cdcooper
            AND    dtmvtolt = pr_dtperiod
            AND    tpmoefix = 11;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar taxa TR - 1: '||SQLERRM;
                -- Descricao do erro na atualizacao de registros
                vr_dscritic := 'Erro ao atualizar TR - 1: vlmoefix:'||pr_vltaxatr
                               ||' com dtmvtolt:'||pr_dtperiod
                               ||', tpmoefix:11. '||SQLERRM;
          END; 

        END IF;
        
        -- Fim verificacao TR
         
        -- Atualiza regra antiga da taxa poupanca
        vr_vlpoupan := ROUND((((pr_vltaxatr / 100) + 1) *  ((0.5 / 100) + 1)  - 1) * 100, 8);

        -- Verifica nova regra da taxa poupanca
        IF vr_taxselic > 8.5 THEN
          vr_vlpoupnr := ROUND((((pr_vltaxatr / 100) + 1) * ((0.5 / 100) + 1)  - 1)  * 100, 8);
        ELSE
          vr_vlpoupnr := ROUND((((pr_vltaxatr / 100) + 1) * (POWER(((vr_taxselic / 100) * 0.7) + 1, 1 / 12)) - 1)  * 100, 8);
        END IF;

        -- Busca registro de taxa nova regra poupanca
        OPEN cr_crapmfx(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                       ,pr_dtperiod => pr_dtperiod --> Data do periodo
                       ,pr_tpmoefix => 20);        --> Tipo de moeda (20 -- Taxa Poupança Nova Regra)

        FETCH cr_crapmfx
         INTO rw_crapmfx;

        -- Se não encontrar insere registro
        IF cr_crapmfx%NOTFOUND THEN
          CLOSE cr_crapmfx; 
          
          BEGIN
          	-- Insere registro da taxa poupanca nova regra
            INSERT INTO crapmfx(cdcooper, dtmvtolt, tpmoefix, vlmoefix)
              VALUES(pr_cdcooper, pr_dtperiod, 20, vr_vlpoupnr);
          EXCEPTION
            WHEN OTHERS THEN
               vr_dscritic := 'Erro ao inserir taxa Nova Regra Poupanca: dtmvtolt:'||pr_dtperiod
                              ||', tpmoefix:20'||', vlmoefix:'||vr_vlpoupnr||'. '||SQLERRM;
          END;  
          
        ELSE
          CLOSE cr_crapmfx;

          BEGIN
            -- Atualiza registro da taxa poupanca nova regra
            UPDATE crapmfx
            SET    vlmoefix = vr_vlpoupnr
            WHERE  cdcooper = pr_cdcooper
            AND    dtmvtolt = pr_dtperiod
            AND    tpmoefix = 20;
          EXCEPTION
            WHEN OTHERS THEN
              -- Descricao do erro na atualizacao de registros
              vr_dscritic := 'Erro ao atualizar taxa Nova Regra Poupanca: vlmoefix:'||vr_vlpoupnr
                             ||' com dtmvtolt:'||pr_dtperiod||', tpmoefix:20. '||SQLERRM;
          END; 

        END IF;
        
        -- Busca registro da poupanca
        OPEN cr_crapmfx(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                       ,pr_dtperiod => pr_dtperiod --> Data do periodo
                       ,pr_tpmoefix => 8);        --> Tipo de moeda (8 -- Poupança)

        FETCH cr_crapmfx
         INTO rw_crapmfx;

        -- Se não encontrar insere registro
        IF cr_crapmfx%NOTFOUND THEN
          CLOSE cr_crapmfx; 
          
          BEGIN
            -- Insere novo registro da poupanca regra antiga
            INSERT INTO crapmfx(cdcooper, dtmvtolt, tpmoefix, vlmoefix)
              VALUES(pr_cdcooper, pr_dtperiod, 8, vr_vlpoupan);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir taxa Poupanca: dtmvtolt:'||pr_dtperiod
                             ||', tpmoefix:8'||', vlmoefix:'||vr_vlpoupan||'. '||SQLERRM;
          END;  
          
        ELSE
          CLOSE cr_crapmfx;

          BEGIN
            -- Atualiza registro da poupanca regra antiga
            UPDATE crapmfx
            SET    vlmoefix = vr_vlpoupan
            WHERE  cdcooper = pr_cdcooper
            AND    dtmvtolt = pr_dtperiod
            AND    tpmoefix = 8;
          EXCEPTION
            WHEN OTHERS THEN
              -- Descricao do erro na atualizacao de registros
              vr_dscritic := 'Erro ao atualizar taxa Poupanca: vlmoefix:'||vr_vlpoupan
                             ||' com dtmvtolt:'||pr_dtperiod||', tpmoefix:8. '||SQLERRM;
          END; 

        END IF;

        -- Busca registro da poupanca
        OPEN cr_crapmfx(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                       ,pr_dtperiod => pr_dtperiod --> Data do periodo
                       ,pr_tpmoefix => 16);        --> Tipo de moeda (16 -- CDI Mensal)

        FETCH cr_crapmfx
         INTO rw_crapmfx;

        -- Verifica se registro existe
        IF cr_crapmfx%NOTFOUND THEN
          -- Caso nao exista, somente fecha o cursor
          CLOSE cr_crapmfx; 
          vr_regexist := FALSE;
        ELSE
          -- Fecha o cursor
          CLOSE cr_crapmfx;
          -- Valor CDI mes
          vr_vlcdimes := rw_crapmfx.vlmoefix;
          vr_regexist := TRUE;
        END IF;
        
        vr_contador := 0;

        OPEN cr_craptab(pr_cdcooper => pr_cdcooper    --> Codigo da cooperativa
                       ,pr_nmsistem => 'CRED'         --> Nome do sistema
                       ,pr_tptabela => 'CONFIG'       --> Tipo de tabela
                       ,pr_cdacesso => 'TXADIAPLIC'); --> Codigo de acesso
        
        LOOP
                               
          FETCH cr_craptab INTO rw_craptab;
          
          EXIT WHEN cr_craptab%NOTFOUND;      
          
          IF rw_craptab.dstextab IS NULL OR rw_craptab.dstextab = ' ' THEN
            CONTINUE;
          END IF;
                  
          vr_vet_dados := gene0002.fn_quebra_string(pr_string  => rw_craptab.dstextab
                                                   ,pr_delimit => ';');
        
          -- Para cada registro encontrado
          FOR vr_ind IN 1..vr_vet_dados.COUNT LOOP

            vr_vllidtab := gene0002.fn_busca_entrada(vr_ind,rw_craptab.dstextab,';');
            
            vr_contador := vr_contador + 1;

            vr_tptaxcdi(vr_contador) := to_number(rw_craptab.tpregist,'9');
            vr_txadical(vr_contador) := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(2,vr_vllidtab,'#'));
            vr_vlfaixas(vr_contador) := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(1,vr_vllidtab,'#'));            
          
          END LOOP;          
          
        END LOOP;
        CLOSE cr_craptab;

        -- Calcula Quantidade de Dias Uteis e Retorna a Data
        APLI0004.pc_calcula_qt_dias_uteis(pr_cdcooper => pr_cdcooper   --> Codigo da Cooperativa
                                         ,pr_dtperiod => pr_dtperiod   --> Data do Periodo
                                         ,pr_qtdiaute => vr_qtdiaute   --> Quantidade de dias uteis
                                         ,pr_dtfimper => vr_dtfimper   --> Data do fim do periodo
                                         ,pr_cdcritic => vr_cdcritic   --> Código da crítica
                                         ,pr_dscritic => vr_dscritic); --> Descrição da crítica
                                         
        IF vr_dscritic IS NOT NULL OR
           NVL(vr_cdcritic,0) <> 0 THEN
          RAISE vr_exc_saida;
        END IF; 

        -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0004.pc_poupanca');

        -- Inicializa variavel
        vr_qtdtxtab := 1;

        WHILE vr_qtdtxtab <= vr_contador LOOP
          
          OPEN cr_craptrd(pr_cdcooper => pr_cdcooper
                         ,pr_dtperiod => pr_dtperiod
                         ,pr_tptaxrda => vr_tptaxcdi(vr_qtdtxtab)
                         ,pr_incarenc => 0
                         ,pr_vlfaixas => vr_vlfaixas(vr_qtdtxtab));

          FETCH cr_craptrd INTO rw_craptrd;

          IF cr_craptrd%NOTFOUND THEN
            CLOSE cr_craptrd;
            BEGIN
              INSERT INTO craptrd(tptaxrda, dtiniper, dtfimper, qtdiaute, vlfaixas, incarenc, incalcul, cdcooper)
                VALUES(vr_tptaxcdi(vr_qtdtxtab), pr_dtperiod, vr_dtfimper, vr_qtdiaute, vr_vlfaixas(vr_qtdtxtab), 0, 0, pr_cdcooper)
                RETURNING ROWID INTO vr_rowidtrd;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao inserir registro na CRAPTRD - 3: cdcooper:'||pr_cdcooper
                               ||', dtiniper:'||pr_dtperiod||', dtfimper:'||vr_dtfimper
                               ||', qtdiaute:'||vr_qtdiaute||', tptaxrda:'||vr_tptaxcdi(vr_qtdtxtab)
                               ||', incarenc:0, incalcul:0'||', vlfaixas:'||vr_vlfaixas(vr_qtdtxtab)||'. '||SQLERRM;
                RAISE vr_exc_saida;
            END;

          ELSE      
            vr_rowidtrd := rw_craptrd.rowid;      
            CLOSE cr_craptrd;
          END IF;               
         
          IF vr_tptaxcdi(vr_qtdtxtab) = 4 THEN
           
            pc_calcula_poupanca(pr_cdcooper => pr_cdcooper   --> Codigo da Cooperativa
                               ,pr_qtddiaut => vr_qtdiaute   --> Quantidade de dias uteis
                               ,pr_vlmoefix => vr_vlpoupnr   --> Valor da taxa nova regra poupanca
                               ,pr_txmespop => vr_txmespop   --> Taxa do Mes
                               ,pr_txdiapop => vr_txdiapop   --> Taxa do Dia
                               ,pr_cdcritic => vr_cdcritic   --> Codigo de Erro
                               ,pr_dscritic => vr_dscritic); --> Descricao de Erro
                               
            IF vr_dscritic IS NOT NULL OR
               NVL(vr_cdcritic,0) <> 0 THEN
              RAISE vr_exc_saida;
            END IF;
                   
          ELSE
            pc_calcula_poupanca(pr_cdcooper => pr_cdcooper   --> Codigo da Cooperativa
                               ,pr_qtddiaut => vr_qtdiaute   --> Quantidade de dias uteis
                               ,pr_vlmoefix => vr_vlpoupan   --> Valor da taxa regra antiga poupanca
                               ,pr_txmespop => vr_txmespop   --> Taxa do Mes
                               ,pr_txdiapop => vr_txdiapop   --> Taxa do Dia
                               ,pr_cdcritic => vr_cdcritic   --> Codigo de Erro
                               ,pr_dscritic => vr_dscritic); --> Descricao de Erro
           
            IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) <> 0 THEN
              RAISE vr_exc_saida;
            END IF;
                                       
          END IF;
          -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
          GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0004.pc_poupanca');
          
          -- Calculo do CDI para comparar com a Poupanca
          IF vr_regexist THEN

            vr_vltxadic := vr_txadical(vr_qtdtxtab);
            vr_txofimes := ROUND(((vr_vlcdimes * vr_vltxadic) / 100),6);
            vr_txofidia := ROUND(((POWER(1 + (vr_txofimes / 100),1 / vr_qtdiaute) - 1) * 100),6);
            
            IF vr_txofimes < vr_txmespop THEN
              vr_auxfimes := vr_txmespop;

              IF vr_tptaxcdi(vr_qtdtxtab) = 4 THEN
                vr_auxvapli := vr_vlpoupnr;
              ELSE
                vr_auxvapli := vr_vlpoupan;              
              END IF;

            ELSE
              vr_auxvapli := vr_vlcdimes;
              vr_auxfimes := vr_txofimes;
            END IF;            
            
            IF vr_txofidia < vr_txdiapop THEN
              vr_auxfidia := vr_txdiapop;
            ELSE
              vr_auxfidia := vr_txofidia;
            END IF;

            BEGIN
              UPDATE craptrd
              SET    craptrd.vltrapli = vr_auxvapli
                    ,craptrd.txofimes = vr_auxfimes
                    ,craptrd.txofidia = vr_auxfidia
              WHERE  craptrd.rowid = vr_rowidtrd;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na atualizacao de registros
                vr_dscritic := 'Erro ao atualizar registro na CRAPTRD - 7: vltrapli: '||vr_auxvapli
                               ||', txofimes:'||vr_auxfimes||', txofidia:'||vr_auxfidia
                               ||' com rowid:'||vr_rowidtrd||'. '||SQLERRM;
                RAISE vr_exc_saida;
            END;
    
          ELSE
            IF vr_tptaxcdi(vr_qtdtxtab) = 4 THEN
              vr_auxvapli := vr_vlpoupnr;
            ELSE
              vr_auxvapli := vr_vlpoupan;              
            END IF;
              
            BEGIN
              UPDATE craptrd
              SET    craptrd.vltrapli = vr_auxvapli
                    ,craptrd.txofimes = vr_txmespop
                    ,craptrd.txofidia = vr_txdiapop
              WHERE  craptrd.rowid = vr_rowidtrd;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na atualizacao de registros
                vr_dscritic := 'Erro ao atualizar registro na CRAPTRD - 8: vltrapli: '||vr_auxvapli
                               ||', txofimes:'||vr_txmespop||', txofidia:'||vr_txdiapop
                               ||' com rowid:'||vr_rowidtrd||'. '||SQLERRM;
                RAISE vr_exc_saida;
            END;
          END IF;
          
          vr_qtdtxtab := vr_qtdtxtab + 1;
          
        END LOOP;
        
        pr_vlpoupan := vr_vlpoupan;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em poupanca: '||SQLERRM;

        --Inclusão na tabela de erros Oracle - Chamado 744573
        CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper );

        ROLLBACK;
    END;
  END pc_poupanca;

  /* Rotina de calculo de quantidade de dias uteis */
  PROCEDURE pc_calcula_qt_dias_uteis(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                    ,pr_dtperiod IN DATE                  --> Data do Periodo
                                    ,pr_qtdiaute OUT PLS_INTEGER          --> Quantidade de dias uteis
                                    ,pr_dtfimper OUT DATE                 --> Data do fim do periodo
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2 ) IS        --> Descrição da crítica
                          

  BEGIN
    /* ..............................................................................

    Programa: pc_calcula_qt_dias_uteis (Antiga: b1wgen0128.p - calcula_qt_dias_uteis)
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : 01/07/2014                        Ultima atualizacao: 27/09/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina de calculo de dias uteis

    Alteracoes: 27/09/2017 - Inclusão do módulo e ação logado no oracle
                           - Inclusão da chamada de procedure em exception others
                           - Colocado logs no padrão
                             (Ana - Envolti - Chamado 744573)
    .................................................................................*/
    DECLARE
      vr_exc_saida EXCEPTION;

      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      vr_dtmvtolt DATE;
      vr_qtdiaute PLS_INTEGER := 0;

      vr_tab_erro GENE0001.typ_tab_erro; --> Tabela com erros
      
      rw_crapdat cr_crapdat%ROWTYPE;

      CURSOR cr_crapfer(pr_cdcooper IN crapfer.cdcooper%TYPE
                       ,pr_dtferiad IN crapfer.dtferiad%TYPE) IS
        SELECT
          fer.cdcooper
         ,fer.dtferiad
        FROM
         crapfer fer
        WHERE
         fer.cdcooper = pr_cdcooper AND
         fer.dtferiad = pr_dtferiad;

         rw_crapfer cr_crapfer%ROWTYPE;
    
    BEGIN
      -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
      GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'APLI0004.pc_calcula_qt_dias_uteis');

      -- Busca do calendario da Cooperativa
      OPEN cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapdat
       INTO rw_crapdat;

      -- Se não encontrar
      IF cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE cr_crapdat;
        -- Chamar rotina de gravacao de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 999
                             ,pr_nrdcaixa => 0
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 1 --> Critica 1
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
        -- Levantar excecao
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapdat;
      END IF;

      pr_dtfimper := GENE0005.fn_calc_data(pr_dtmvtolt => pr_dtperiod
                                          ,pr_qtmesano => 1
                                          ,pr_tpmesano => 'M'
                                          ,pr_des_erro => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      vr_dtmvtolt := pr_dtperiod;
      vr_qtdiaute := 0;
      
      WHILE vr_dtmvtolt < pr_dtfimper LOOP

        OPEN cr_crapfer(pr_cdcooper, vr_dtmvtolt);

        FETCH cr_crapfer INTO rw_crapfer;

        -- Se não encontrar
        IF cr_crapfer%NOTFOUND AND TO_CHAR(vr_dtmvtolt, 'D') NOT IN (1,7) THEN
          -- Fechar o cursor
          CLOSE cr_crapfer;
          vr_qtdiaute := vr_qtdiaute + 1;
        ELSE
          -- Fechar o cursor
          CLOSE cr_crapfer;
        END IF;

        vr_dtmvtolt := vr_dtmvtolt + 1;

      END LOOP;

      pr_qtdiaute := vr_qtdiaute;

    EXCEPTION

      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_calcula_qt_dias_uteis: '||SQLERRM;

        --Inclusão na tabela de erros Oracle - Chamado 744573
        CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper );

        ROLLBACK;
    END;
  END pc_calcula_qt_dias_uteis;

  -- Atualizar a taxa de Poupança para todas as Cooperativas
  PROCEDURE pc_atualiza_sol026(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da Cooperativa
                              ,pr_dtperiod IN DATE                   --> Data do Periodo
                              ,pr_vlpoupan IN crapmfx.vlmoefix%TYPE --> Valor taxa Poupanca
                              ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica 
  BEGIN

    /* .............................................................................

     Programa: pc_atualiza_sol026              Antigo: b1wgen0128.p/atualiza_sol026
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Julho/14.                    Ultima atualizacao: 27/09/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de atualizacao de taxa de poupanca

     Observacao: -----

     Alteracoes: 27/09/2017 - Inclusão do módulo e ação logado no oracle
                            - Inclusão da chamada de procedure em exception others
                            - Colocado logs no padrão
                              (Ana - Envolti - Chamado 744573)
     ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      vr_auxdtperi DATE;

      vr_dstextab VARCHAR2(1000);
      vr_dsauxstr VARCHAR2(10);
      vr_tpcalcul PLS_INTEGER := 0;

      vr_contdste PLS_INTEGER := 0;
      vr_contador PLS_INTEGER := 0;

      TYPE arrRegDc IS TABLE OF NUMBER(20,8) INDEX BY PLS_INTEGER;
      vr_txjurcap arrRegDc;
      vr_anttxjur arrRegDc;

      -- Selecionar as administradoras de cartao
      CURSOR cr_craptab (pr_cdcooper IN craptab.cdcooper%TYPE
                        ,pr_nmsistem IN craptab.nmsistem%TYPE
                        ,pr_tptabela IN craptab.tptabela%TYPE
                        ,pr_cdempres IN craptab.cdempres%TYPE
                        ,pr_cdacesso IN craptab.cdacesso%TYPE
                        ,pr_tpregist IN craptab.tpregist%TYPE) IS
      SELECT
        tab.dstextab
       ,tab.rowid
      FROM
        craptab tab
      WHERE
            tab.cdcooper = pr_cdcooper
        AND UPPER(tab.nmsistem) = pr_nmsistem
        AND UPPER(tab.tptabela) = pr_tptabela
        AND tab.cdempres = pr_cdempres
        AND UPPER(tab.cdacesso) = pr_cdacesso
        AND tab.tpregist = pr_tpregist;

       rw_craptab cr_craptab%ROWTYPE;

      BEGIN
        -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
        GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'APLI0004.pc_atualiza_sol026');

        -- Monta data para comparacao
        vr_auxdtperi := to_date('01/' || to_char(pr_dtperiod,'mm') || '/' || to_char(pr_dtperiod,'yyyy'),'dd/mm/yyyy');

        -- Compara data "montada" com data passada por parametro
        IF pr_dtperiod = vr_auxdtperi THEN

          -- Atualizar a taxa de Poupança para todas as Cooperativas
          OPEN cr_craptab (pr_cdcooper => pr_cdcooper
                          ,pr_nmsistem => 'CRED'
                          ,pr_tptabela => 'GENERI'
                          ,pr_cdempres => 0
                          ,pr_cdacesso => 'EXEJUROCAP'
                          ,pr_tpregist => 1);
         
          FETCH cr_craptab INTO rw_craptab;
                          
          IF cr_craptab%NOTFOUND THEN

            CLOSE cr_craptab;                
            vr_dscritic := 'Tabela EXEJUROCAP inexistente.';
            RAISE vr_exc_saida;
 	
          ELSE
          
            CLOSE cr_craptab;
            
          END IF;
          
          vr_dstextab := SUBSTR(rw_craptab.dstextab,5,200);
          vr_tpcalcul := SUBSTR(rw_craptab.dstextab,1,1);

          vr_contador := 0;
          vr_contdste := regexp_count(vr_dstextab, ';' ) + 1;
          
          WHILE vr_contador <= vr_contdste LOOP

            vr_contador := vr_contador + 1;
            
            vr_txjurcap(vr_contador) := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(pr_postext      => vr_contador
                                                                                              ,pr_dstext      => vr_dstextab
                                                                                              ,pr_delimitador => ';'));


            vr_anttxjur(vr_contador) := gene0002.fn_char_para_number(gene0002.fn_busca_entrada(pr_postext     => vr_contador
                                                                                              ,pr_dstext      => vr_dstextab
                                                                                              ,pr_delimitador => ';'));
            
            IF to_char(pr_dtperiod,'mm') = vr_contador THEN
              vr_txjurcap(vr_contador) := pr_vlpoupan;
              vr_anttxjur(vr_contador) := pr_vlpoupan;
            END IF;
                                                      
          END LOOP; -- Fim While

          rw_craptab.dstextab := vr_tpcalcul || SUBSTR(rw_craptab.dstextab,2);
          rw_craptab.dstextab := SUBSTR(rw_craptab.dstextab,1,4);

          vr_contador := 1;

          WHILE vr_contador <= 12 LOOP
            
            IF vr_contador <> 12 THEN 
              vr_dsauxstr := ';';
            ELSE
              vr_dsauxstr := '';
            END IF;

            rw_craptab.dstextab := rw_craptab.dstextab || TRIM(REPLACE(TO_CHAR(vr_txjurcap(vr_contador),'fm000D000000'),'.',',')) || vr_dsauxstr;
            
            vr_contador := vr_contador + 1;

          END LOOP; -- Fim while contador 12
          
          BEGIN
            UPDATE craptab
            SET    craptab.dstextab = rw_craptab.dstextab
            WHERE  craptab.rowid = rw_craptab.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              -- Descricao do erro na atualizacao de registros
              vr_dscritic := 'Erro ao atualizar registro na CRAPTRD: dstextab: '||rw_craptab.dstextab
                             ||' com rowid:'||rw_craptab.rowid||'. '||SQLERRM;
              RAISE vr_exc_saida;
          END;

        END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em atualizar pc_atualiza_sol026: '||SQLERRM;

        --Inclusão na tabela de erros Oracle - Chamado 744573
        CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper );

        ROLLBACK;
    END;
  END pc_atualiza_sol026;

  PROCEDURE pc_atualiza_tr(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                          ,pr_dtperiod IN DATE                  --> Data do Periodo
                          ,pr_txrefmes IN NUMBER                --> Valor taxa mes
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica                     
  BEGIN

    /* .............................................................................

     Programa: pc_atualiza_tr              Antigo: b1wgen0128.p/atualiza_tr
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Julho/14.                    Ultima atualizacao: 27/09/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de atualizacao de taxa TR

     Observacao: -----

     Alteracoes: 27/09/2017 - Inclusão do módulo e ação logado no oracle
                            - Inclusão da chamada de procedure em exception others
                            - Colocado logs no padrão
                              (Ana - Envolti - Chamado 744573)
     ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      vr_auxdtper DATE;
      vr_dtfimper DATE;

      vr_qtdiaute INTEGER := 0;

      vr_txjurfix NUMBER(20,8) := 0;
      vr_txjurvar NUMBER(20,8) := 0;
      vr_txmensal NUMBER(20,8) := 0;
      vr_txminima NUMBER(20,8) := 0;
      vr_txmaxima NUMBER(20,8) := 0;
      vr_txdiaria NUMBER(20,8) := 0;

      -- Selecionar as administradoras de cartao
      CURSOR cr_craptab (pr_cdcooper IN craptab.cdcooper%TYPE
                        ,pr_nmsistem IN craptab.nmsistem%TYPE
                        ,pr_tptabela IN craptab.tptabela%TYPE
                        ,pr_cdempres IN craptab.cdempres%TYPE
                        ,pr_cdacesso IN craptab.cdacesso%TYPE
                        ,pr_tpregist IN craptab.tpregist%TYPE) IS
      SELECT
        tab.dstextab
       ,tab.rowid
      FROM
        craptab tab
      WHERE
            tab.cdcooper = pr_cdcooper
        AND UPPER(tab.nmsistem) = pr_nmsistem
        AND UPPER(tab.tptabela) = pr_tptabela
        AND tab.cdempres = pr_cdempres
        AND UPPER(tab.cdacesso) = pr_cdacesso
        AND tab.tpregist = pr_tpregist;

       rw_craptab cr_craptab%ROWTYPE;

      -- Consulta de linhas de credito rotativo
      CURSOR cr_craplrt (pr_cdcooper IN crapcop.cdcooper%TYPE) IS

      SELECT
        lrt.txjurvar
       ,lrt.txjurfix
       ,lrt.txmensal
       ,lrt.rowid
      FROM
        craplrt lrt
      WHERE
        lrt.cdcooper = pr_cdcooper;

       rw_craplrt cr_craplrt%ROWTYPE;
      
      CURSOR cr_craplcr (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
  
      SELECT
        lcr.cdcooper
       ,lcr.cdlcremp
       ,lcr.txjurfix
       ,lcr.txjurvar
       ,lcr.txminima
       ,lcr.txmaxima
       ,lcr.txmensal
       ,lcr.txdiaria
       ,lcr.rowid
      FROM
        craplcr lcr
      WHERE
        lcr.cdcooper = pr_cdcooper;

       rw_craplcr cr_craplcr%ROWTYPE;

      BEGIN
        -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
        GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'APLI0004.pc_atualiza_tr');
        
        -- Monta data para comparacao
        vr_auxdtper := to_date('01/' || to_char(pr_dtperiod,'mm') || '/' || to_char(pr_dtperiod,'yyyy'),'dd/mm/yyyy');

        -- Compara data "montada" com data passada por parametro
        IF pr_dtperiod = vr_auxdtper AND pr_cdcooper <> 3 THEN
          
          -- CONSULTA DE REGISTROS
          OPEN cr_craptab (pr_cdcooper => pr_cdcooper
                          ,pr_nmsistem => 'CRED'
                          ,pr_tptabela => 'GENERI'
                          ,pr_cdempres => 0
                          ,pr_cdacesso => 'TAXASDOMES'
                          ,pr_tpregist => '1');

          FETCH cr_craptab INTO rw_craptab;

          IF cr_craptab%NOTFOUND THEN

            CLOSE cr_craptab;
            vr_dscritic := 'Tabela TAXASDOMES em uso ou nao existe.';
            RAISE vr_exc_saida;

          ELSE
            CLOSE cr_craptab;
          END IF;
          
          -- Calcula Quantidade de Dias Uteis e Retorna a Data
          APLI0004.pc_calcula_qt_dias_uteis(pr_cdcooper => pr_cdcooper   --> Codigo da Cooperativa
                                           ,pr_dtperiod => pr_dtperiod   --> Data do Periodo
                                           ,pr_qtdiaute => vr_qtdiaute   --> Quantidade de dias uteis
                                           ,pr_dtfimper => vr_dtfimper   --> Data do fim do periodo
                                           ,pr_cdcritic => vr_cdcritic   --> Código da crítica
                                           ,pr_dscritic => vr_dscritic); --> Descrição da crítica
          
          IF pr_dscritic IS NOT NULL OR
             pr_cdcritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
          -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
          GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0004.pc_atualiza_tr');
          
          rw_craptab.dstextab := SUBSTR(rw_craptab.dstextab,1,2) || TRIM(REPLACE(TO_CHAR(pr_txrefmes,'fm000D000000'),'.',',')) || SUBSTR(rw_craptab.dstextab,13);
          rw_craptab.dstextab := SUBSTR(rw_craptab.dstextab,1,24) || TO_CHAR(pr_dtperiod,'ddmmRRRR') || SUBSTR(rw_craptab.dstextab,33);
          rw_craptab.dstextab := SUBSTR(rw_craptab.dstextab,1,33) || TO_CHAR(vr_dtfimper,'ddmmRRRR') || SUBSTR(rw_craptab.dstextab,42);
            
          BEGIN
            UPDATE craptab
            SET    craptab.dstextab = rw_craptab.dstextab
            WHERE  craptab.rowid = rw_craptab.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              -- Descricao do erro na atualizacao de registros
              vr_dscritic := 'Erro ao atualizar registro na CRAPTAB I: dstextab: '||rw_craptab.dstextab
                             ||' com rowid:'||rw_craptab.rowid||'. '||SQLERRM;
              RAISE vr_exc_saida;
          END;

          --Atualizando a taxa de juros para o cheque especial          
          OPEN cr_craplrt(pr_cdcooper => pr_cdcooper);

          LOOP
            FETCH cr_craplrt INTO rw_craplrt;

            EXIT WHEN cr_craplrt%NOTFOUND; 
            
            rw_craplrt.txmensal := ROUND(((pr_txrefmes * (rw_craplrt.txjurvar / 100) + 100) * (1 + (rw_craplrt.txjurfix / 100)) - 100),6);
            
            BEGIN
              UPDATE craplrt
              SET    txmensal = rw_craplrt.txmensal
              WHERE  craplrt.rowid = rw_craplrt.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na atualizacao de registros
                vr_dscritic := 'Erro ao atualizar registro na CRAPLRT: txmensal: '||rw_craplrt.txmensal
                               ||' com rowid:'||rw_craplrt.rowid||'. '||SQLERRM;
            END;
            
          END LOOP;
          
          CLOSE cr_craplrt;
          -- Fim da atualizacao da taxa de juros para chq. especial           
          
          -- Atualizando a taxa de juros para o saque s/bloqueado
          OPEN cr_craptab (pr_cdcooper => pr_cdcooper
                          ,pr_nmsistem => 'CRED'
                          ,pr_tptabela => 'USUARI'
                          ,pr_cdempres => 11
                          ,pr_cdacesso => 'JUROSSAQUE'
                          ,pr_tpregist => '1');

          FETCH cr_craptab INTO rw_craptab;

          IF cr_craptab%NOTFOUND THEN
            CLOSE cr_craptab;
          ELSE
            
            CLOSE cr_craptab;
            
            vr_txjurfix := gene0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,12,06));
            vr_txjurvar := gene0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,19,06));
            vr_txmensal := ROUND(((pr_txrefmes * (vr_txjurvar / 100) + 100) * (1 + (vr_txjurfix / 100)) - 100),6);

            rw_craptab.dstextab := TRIM(REPLACE(TO_CHAR(vr_txmensal,'fm000D000000'),'.',',')) || SUBSTR(rw_craptab.dstextab,11,14);

            BEGIN
              UPDATE craptab
              SET    craptab.dstextab = rw_craptab.dstextab
              WHERE  craptab.rowid = rw_craptab.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na atualizacao de registros
                vr_dscritic := 'Erro ao atualizar registro na CRAPTAB II: dstextab: '||rw_craptab.dstextab
                               ||' com rowid:'||rw_craptab.rowid||'. '||SQLERRM;
                RAISE vr_exc_saida;
            END;

          END IF;
          
          -- Atualizando taxa de juros para os saldos negativos - MULTA
          OPEN cr_craptab (pr_cdcooper => pr_cdcooper
                          ,pr_nmsistem => 'CRED'
                          ,pr_tptabela => 'USUARI'
                          ,pr_cdempres => 11
                          ,pr_cdacesso => 'JUROSNEGAT'
                          ,pr_tpregist => '1');

          FETCH cr_craptab INTO rw_craptab;

          IF cr_craptab%NOTFOUND THEN
            CLOSE cr_craptab;
          ELSE
            
            CLOSE cr_craptab;
            
            vr_txjurfix := gene0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,12,06));
            vr_txjurvar := gene0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,19,06));
                
            vr_txmensal := ROUND(((pr_txrefmes * (vr_txjurvar / 100) + 100) * (1 + (vr_txjurfix / 100)) - 100),6);
            rw_craptab.dstextab := TRIM(REPLACE(TO_CHAR(vr_txmensal,'fm000D000000'),'.',',')) ||  SUBSTR(rw_craptab.dstextab,11,14);

            BEGIN
              UPDATE craptab
              SET    craptab.dstextab = rw_craptab.dstextab
              WHERE  craptab.rowid = rw_craptab.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na atualizacao de registros
                vr_dscritic := 'Erro ao atualizar registro na CRAPTAB III: dstextab: '||rw_craptab.dstextab
                               ||' com rowid:'||rw_craptab.rowid||'. '||SQLERRM;
                RAISE vr_exc_saida;
            END;
          END IF;

          -- Alterando as linhas de credito
          OPEN cr_craplcr(pr_cdcooper => pr_cdcooper);

          LOOP
            FETCH cr_craplcr INTO rw_craplcr;

            EXIT WHEN cr_craplcr%NOTFOUND; 
            
            IF rw_craplcr.cdcooper = 4  AND rw_craplcr.cdlcremp IN(4,5,6) THEN
              CONTINUE;
            END IF;
            
            vr_txjurfix := rw_craplcr.txjurfix;
            vr_txjurvar := rw_craplcr.txjurvar;
            vr_txminima := rw_craplcr.txminima;
            vr_txmaxima := rw_craplcr.txmaxima;

            vr_txmensal := ROUND(((pr_txrefmes * (vr_txjurvar / 100) + 100) * (1 + (vr_txjurfix / 100)) - 100),6);

            IF vr_txminima > vr_txmensal THEN
              vr_txmensal := vr_txminima;
            ELSIF vr_txmaxima > 0 AND
                  vr_txmaxima < vr_txmensal THEN
              vr_txmensal := vr_txmaxima;
            ELSE 
              vr_txmensal := vr_txmensal;
            END IF;
                              
            vr_txdiaria := ROUND(vr_txmensal / 3000,7);

            rw_craplcr.txmensal := vr_txmensal;
            rw_craplcr.txdiaria := vr_txdiaria;
            
            BEGIN
              UPDATE craplcr
              SET    txmensal = rw_craplcr.txmensal,
                     txdiaria = rw_craplcr.txdiaria
              WHERE  craplcr.rowid = rw_craplcr.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na atualizacao de registros
                vr_dscritic := 'Erro ao atualizar registro na CRAPLCR: txmensal: '||rw_craplcr.txmensal
                               ||', txdiaria:'||rw_craplcr.txdiaria
                               ||' com rowid:'||rw_craplcr.rowid||'. '||SQLERRM;
            END;

          END LOOP; -- Fim do LOOP / Atualizar linhas de credito
          CLOSE cr_craplcr;         

        END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em atualizar pc_atualiza_tr: '||SQLERRM;

        --Inclusão na tabela de erros Oracle - Chamado 744573
        CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper );

        ROLLBACK;
    END;
  END pc_atualiza_tr;

  PROCEDURE pc_atualiza_taxa_poupanca(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                     ,pr_dtmvtolt IN DATE                  --> Data do Periodo
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica                  
    BEGIN

    /* .............................................................................

     Programa: pc_atualiza_taxa_poupanca
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Julho/14.                    Ultima atualizacao: 27/09/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de atualizacao de taxas referente a poupanca

     Observacao: -----

     Alteracoes: 27/09/2017 - Inclusão do módulo e ação logado no oracle
                            - Inclusão da chamada de procedure em exception others
                            - Colocado logs no padrão
                              (Ana - Envolti - Chamado 744573)
     ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      vr_vlpoupan NUMBER(20,8) := 0;

      -- CURSORES
      CURSOR cr_crapmfx(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Codigo da cooperativa
                       ,pr_dtperiod IN crapmfx.dtmvtolt%TYPE     --> Data do periodo
                       ,pr_tpmoefix IN crapmfx.tpmoefix%TYPE) IS --> Tipo de moeda

      SELECT
       mfx.cdcooper
      ,mfx.dtmvtolt
      ,mfx.tpmoefix
      ,mfx.vlmoefix
      ,mfx.rowid
      FROM
        crapmfx mfx
      WHERE
            mfx.cdcooper = pr_cdcooper
        AND mfx.dtmvtolt = pr_dtperiod 
        AND mfx.tpmoefix = pr_tpmoefix;
      
      rw_crapmfx cr_crapmfx%ROWTYPE;

      BEGIN
        -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
        GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'APLI0004.pc_atualiza_taxa_poupanca');
        
        OPEN cr_crapmfx(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                       ,pr_dtperiod => pr_dtmvtolt --> Data do periodo
                       ,pr_tpmoefix => 11);        --> Tipo de moeda

        FETCH cr_crapmfx INTO rw_crapmfx;

        IF cr_crapmfx%NOTFOUND THEN
          CLOSE cr_crapmfx;
          vr_dscritic := 'Erro ao consultar taxa na atualizacao da poupanca: TR nao cadastrada. Data: ' || to_char(pr_dtmvtolt,'dd/mm/RRRR');
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_crapmfx;
        END IF; 
       
        apli0004.pc_poupanca(pr_cdcooper => pr_cdcooper
                            ,pr_dtperiod => rw_crapmfx.dtmvtolt
                            ,pr_vltaxatr => rw_crapmfx.vlmoefix
                            ,pr_vlpoupan => vr_vlpoupan
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
                            
        IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) <> 0 THEN
          RAISE vr_exc_saida;
        END IF;


        apli0004.pc_atualiza_sol026(pr_cdcooper => pr_cdcooper
                                   ,pr_dtperiod => pr_dtmvtolt
                                   ,pr_vlpoupan => vr_vlpoupan
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
                                   
        IF vr_dscritic IS NOT NULL OR
           NVL(vr_cdcritic,0) <> 0 THEN
          RAISE vr_exc_saida;
        END IF;

        -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0004.pc_atualiza_taxa_poupanca');

        IF  pr_cdcooper <> 3 THEN
       
           apli0004.pc_atualiza_tr(pr_cdcooper => rw_crapmfx.cdcooper
                                  ,pr_dtperiod => rw_crapmfx.dtmvtolt
                                  ,pr_txrefmes => rw_crapmfx.vlmoefix
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
                               
           IF vr_dscritic IS NOT NULL OR
              NVL(vr_cdcritic,0) <> 0 THEN
             RAISE vr_exc_saida;
           END IF;
           -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
           GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0004.pc_atualiza_taxa_poupanca');

        END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_atualiza_taxa_poupanca: '||SQLERRM;

        --Inclusão na tabela de erros Oracle - Chamado 744573
        CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper );

        ROLLBACK;
    END;
  END pc_atualiza_taxa_poupanca;

  /* Rotina de consulta de tipo de data do indexador */
  PROCEDURE pc_verifica_tipo_data(pr_cddindex IN crapind.cddindex%TYPE --> Codigo do Indexador
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

  BEGIN
    /* .............................................................................

    Programa: pc_verifica_tipo_data
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : 24/11/2014                        Ultima atualizacao: 27/09/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina de consulta de tipo de data do indexador

    Alteracoes: 27/09/2017 - Inclusão do módulo e ação logado no oracle
                           - Inclusão da chamada de procedure em exception others
                           - Colocado logs no padrão
                             (Ana - Envolti - Chamado 744573)
    ............................................................................. */
    DECLARE
      vr_exc_saida EXCEPTION;

      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- CURSORES

      -- Consulta de indexador
      CURSOR cr_crapind(pr_cddindex IN craptxi.cddindex%TYPE) IS

      SELECT
        ind.idperiod
      FROM
       crapind ind
      WHERE
        ind.cddindex = pr_cddindex;  -- Codigo do Indexador

      rw_crapind cr_crapind%ROWTYPE;

    BEGIN
      -- Inclusão do módulo e ação logado - Chamado 744573 - 27/09/2017
      GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => 'APLI0004.pc_verifica_tipo_data');

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Consulta de indexador
      OPEN cr_crapind(pr_cddindex => pr_cddindex);

      FETCH cr_crapind INTO rw_crapind;

      -- Verifica se registro existe
      IF cr_crapind%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_crapind;

        -- Monta critica
        vr_dscritic := 'Registro de indexador nao encontrado.';
        RAISE vr_exc_saida;
      ELSE
        -- Fecha cursor
        CLOSE cr_crapind;
      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

      IF rw_crapind.idperiod IN (1,2)THEN
         gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'tipodata', pr_tag_cont => 0, pr_des_erro => vr_dscritic);
      ELSE
         gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'tipodata', pr_tag_cont => 1, pr_des_erro => vr_dscritic);
      END IF;

    EXCEPTION

      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_verifica_tipo_data: '||SQLERRM;

        --Inclusão na tabela de erros Oracle - Chamado 744573
        CECRED.pc_internal_exception( pr_cdcooper => vr_cdcooper );

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_verifica_tipo_data;

END APLI0004;
/
