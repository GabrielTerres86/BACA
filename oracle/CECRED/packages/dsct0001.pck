CREATE OR REPLACE PACKAGE CECRED.DSCT0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa:  DSCT0001                       Antiga: generico/procedures/b1wgen0153.p
  --  Autor   : Alisson
  --  Data    : Julho/2013                     Ultima Atualizacao: 16/02/2018
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package para rotinas envolvendo desconto titulos
  --              titulos.
  --
  --  Alteracoes: 17/07/2013 - Conversao Progress para oracle (Alisson - AMcom)
  --
  --              26/02/2016 - Criacao das procedures pc_efetua_baixa_tit_car e
  --                           pc_efetua_baixa_tit_car_job melhoria 116
  --                           (Tiago/Rodrigo).
  --
  --              16/02/2018 - Ref. História KE00726701-36 - Inclusão de Filtro e Parâmetro por Tipo de Pessoa na TAB052
  --                          (Gustavo Sene - GFT)
  ---------------------------------------------------------------------------------------------------------------

  --Tipo de Desconto de Títulos
  TYPE typ_tot_descontos IS RECORD --(b1wgen0030tt.i/tt-tot_descontos)
    (vldscchq NUMBER
    ,qtdscchq INTEGER
    ,vldsctit NUMBER
    ,vllimtit NUMBER
    ,vllimchq NUMBER
    ,qtdsctit INTEGER
    ,vlmaxtit NUMBER
    ,qttotdsc INTEGER
    ,vltotdsc NUMBER);

  --Tipo de Tabela de Desconto de Títulos
  TYPE typ_tab_tot_descontos IS TABLE OF typ_tot_descontos INDEX BY PLS_INTEGER;

  --Tipo de Lancamento Tarifa
  TYPE typ_tot_tarifa IS RECORD
    (cdcooper crapcop.cdcooper%TYPE
    ,nrdconta crapass.nrdconta%TYPE
    ,qtdtarcr INTEGER
    ,qtdtarsr INTEGER);

  --Tipo de Tabela de Lancamento Tarifa
  TYPE typ_tab_tarifa IS TABLE OF typ_tot_tarifa INDEX BY VARCHAR2(13);

  TYPE typ_dados_tarifa IS RECORD
    (cdfvlcop crapcop.cdcooper%TYPE
    ,cdhistor craphis.cdhistor%TYPE
    ,vlrtarif NUMBER
    ,vltottar NUMBER);

  --Tipo de Tabela de Lancamento Tarifa
  TYPE typ_tab_dados_tarifa IS TABLE OF typ_dados_tarifa INDEX BY VARCHAR2(4);

  PROCEDURE pc_efetua_baixa_tit_car(pr_cdcooper    IN crapcop.cdcooper%TYPE      --Codigo Cooperativa
                                   ,pr_cdagenci    IN INTEGER                    --Codigo Agencia
                                   ,pr_nrdcaixa    IN INTEGER                    --Numero Caixa
                                   ,pr_idorigem    IN INTEGER                    --Origem sistema
                                   ,pr_cdoperad    IN VARCHAR2                   --Codigo operador
                                   ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE      --Data Movimento
                                   ,pr_dtmvtoan    IN crapdat.dtmvtoan%TYPE      --Data Movimento Anterior
                                   ,pr_cdcritic    OUT INTEGER                   --Codigo Critica
                                   ,pr_dscritic    OUT VARCHAR2                  --Descricao Critica
                                   ,pr_tab_erro    OUT GENE0001.typ_tab_erro);

  PROCEDURE pc_efetua_baixa_tit_car_job;

  /* Procedure para efetuar a baixa do titulo por pagamento ou vencimento */
  PROCEDURE pc_efetua_baixa_titulo (pr_cdcooper    IN INTEGER --Codigo Cooperativa
                                   ,pr_cdagenci    IN INTEGER --Codigo Agencia
                                   ,pr_nrdcaixa    IN INTEGER --Numero Caixa
                                   ,pr_cdoperad    IN VARCHAR2 --Codigo operador
                                   ,pr_dtmvtolt    IN DATE     --Data Movimento
                                   ,pr_idorigem    IN INTEGER  --Identificador Origem pagamento
                                   ,pr_nrdconta    IN INTEGER  --Numero da conta
                                   ,pr_indbaixa    IN INTEGER  --Indicador Baixa /* 1-Pagamento 2- Vencimento */
                                   ,pr_tab_titulos IN PAGA0001.typ_tab_titulos --Titulos a serem baixados
                                   --,pr_dtintegr    IN DATE         --Data da integração do pagamento
                                   ,pr_cdcritic    OUT INTEGER     --Codigo Critica
                                   ,pr_dscritic    OUT VARCHAR2     --Descricao Critica
                                   ,pr_tab_erro    OUT GENE0001.typ_tab_erro); --Tabela erros

  /* Procedure para efetuar resgate de titulos de um determinado bordero */
  PROCEDURE pc_efetua_resgate_tit_bord (pr_cdcooper    IN craplot.cdcooper%TYPE  --> Codigo Cooperativa
                                       ,pr_cdagenci    IN craplot.cdagenci%TYPE  --> Codigo Agencia
                                       ,pr_nrdcaixa    IN craplot.nrdcaixa%TYPE  --> Numero Caixa
                                       ,pr_cdoperad    IN craplot.cdoperad%TYPE  --> Codigo operador
                                       ,pr_dtmvtolt    IN craplot.dtmvtolt%TYPE  --> Data Movimento
                                       ,pr_dtmvtoan    IN craplot.dtmvtolt%TYPE  --> Data anterior do movimento
                                       ,pr_inproces    IN crapdat.inproces%TYPE  --> Indicador processo
                                       ,pr_dtresgat    IN craplot.dtmvtolt%TYPE  --> Data do resgate
                                       ,pr_idorigem    IN INTEGER                --> Identificador Origem pagamento
                                       ,pr_nrdconta    IN craplcm.nrdconta%TYPE  --> Numero da conta
                                       ,pr_cdbccxlt    IN craplot.cdbccxlt%TYPE  --> codigo do banco
                                       ,pr_nrdolote    IN craplot.nrdolote%TYPE  --> Numero do lote
                                       ,pr_tab_titulos IN PAGA0001.typ_tab_titulos --> Titulos a serem resgatados

                                       ,pr_cdcritic    OUT INTEGER                 --> Codigo Critica
                                       ,pr_dscritic    OUT VARCHAR2                --> Descricao Critica
                                       );

  /* Rotina referente a consulta de avalistas, procuradores e representantes */
  PROCEDURE pc_busca_total_descto_lim(pr_cdcooper IN INTEGER  --Codigo Cooperativa
                                     ,pr_cdagenci IN INTEGER  --Codigo da agencia
                                     ,pr_nrdcaixa IN INTEGER  --Numero do caixa
                                     ,pr_cdoperad IN VARCHAR2 --codigo do operador
                                     ,pr_dtmvtolt IN DATE     --Data do movimento
                                     ,pr_nrdconta IN INTEGER  --Numero da conta
                                     ,pr_idseqttl IN INTEGER  --idseqttl
                                     ,pr_idorigem IN INTEGER  --Codigo da origem
                                     ,pr_nmdatela IN VARCHAR2 --Nome da tela
                                     ,pr_nrctrlim IN VARCHAR2 --Numero do contrato
                                     ,pr_tab_tot_descontos OUT dsct0001.typ_tab_tot_descontos --Tabela Desconto de Títulos
                                     ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2    --> Descrição da crítica
                                     ,pr_tab_erro OUT GENE0001.typ_tab_erro); --Tabela erros

  /* Buscar a soma total de descontos (titulos + cheques)  */
  PROCEDURE pc_busca_total_descontos(pr_cdcooper IN INTEGER        --> Codigo Cooperativa
                                     ,pr_cdagenci IN INTEGER       --> Codigo da agencia
                                     ,pr_nrdcaixa IN INTEGER       --> Numero do caixa
                                     ,pr_cdoperad IN VARCHAR2      --> codigo do operador
                                     ,pr_dtmvtolt IN DATE          --> Data do movimento
                                     ,pr_nrdconta IN INTEGER       --> Numero da conta
                                     ,pr_idseqttl IN INTEGER       --> idseqttl
                                     ,pr_idorigem IN INTEGER       --> Codigo da origem
                                     ,pr_nmdatela IN VARCHAR2      --> Nome da tela
                                     ,pr_flgerlog IN VARCHAR2      --> identificador se deve gerar log S-Sim e N-Nao
                                     ,pr_cdcritic OUT PLS_INTEGER  --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2     --> Descrição da crítica
                                     ,pr_tab_tot_descontos OUT typ_tab_tot_descontos); --Totais de desconto

  /* Procedure para efetuar estorno da baixa do titulo por pagamento - Demetrius Wolff - Mouts */
  PROCEDURE pc_efetua_estorno_baixa_titulo (pr_cdcooper    IN INTEGER --Codigo Cooperativa
                                           ,pr_cdagenci    IN INTEGER --Codigo Agencia
                                           ,pr_nrdcaixa    IN INTEGER --Numero Caixa
                                           ,pr_cdoperad    IN VARCHAR2 --Codigo operador
                                           ,pr_dtmvtolt    IN DATE     --Data Movimento
                                           ,pr_idorigem    IN INTEGER  --Identificador Origem pagamento
                                           ,pr_nrdconta    IN INTEGER  --Numero da conta
                                           ,pr_tab_titulos IN PAGA0001.typ_tab_titulos --Titulos a serem baixados
                                           ,pr_cdcritic    OUT INTEGER     --Codigo Critica
                                           ,pr_dscritic    OUT VARCHAR2     --Descricao Critica
                                           ,pr_tab_erro    OUT GENE0001.typ_tab_erro); --Tabela erros

END  DSCT0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.DSCT0001 AS

  /*---------------------------------------------------------------------------------------------------------------

    Programa :  DSCT0001
    Sistema  : Procedimentos envolvendo desconto titulos
    Sigla    : CRED
    Autor    : Alisson C. Berrido - Amcom
    Data     : Julho/2013.                   Ultima atualizacao: 16/02/2018

   Dados referentes ao programa:

   Frequencia: -----
   Objetivo  : Procedimentos envolvendo desconto titulos

   Alteracoes: 25/03/2015 - Remover o savepoint vr_save_baixa da pc_efetua_baixa_titulo
                            (Douglas - Chamado 267787)

               26/02/2016 - Criacao das procedures pc_efetua_baixa_tit_car e
                            pc_efetua_baixa_tit_car_job melhoria 116
                            (Tiago/Rodrigo).

               25/04/2016 - Ajuste para nao debitar titulos descontados vencidos quando
                            cooperado estiver com acao judicial. (Rafael)

               15/09/2016 - #519903 Criação de log de controle de início, erros e fim de execução
                            do job pc_efetua_baixa_tit_car_job (Carlos)

               11/10/2016 - #497991 Job pc_efetua_baixa_tit_car_job.
                            Validação de dia útil para execução do job. If com a rotina
                            gene0005.fn_valida_dia_util passando sysdate e comparando com sysdate.
                            No sábado como estava com CRAPDAT.INPROCES = 2 a rotina ficava reprogramando
                            final de semana inteiro e executava na segunda-feira por volta de 7h15
                            sendo que o correto é as 11h30 e 17h30 (AJFink)

               25/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur
							(Adriano - P339).

               22/11/2017 - Adicionado regra para não debitar títulos vencidos no primeiro dia util do ano e
                            que venceram no dia útil anterior. (Rafael)

               25/11/2017 - Ajuste para cobrar IOF. (James - P410)

               16/02/2018 - Ref. História KE00726701-36 - Inclusão de Filtro e Parâmetro por Tipo de Pessoa na TAB052
                           (Gustavo Sene - GFT)               
  ---------------------------------------------------------------------------------------------------------------*/
  /* Tipos de Tabelas da Package */

  --Tipo de Tabela de lancamentos de juros dos titulos
  TYPE typ_tab_crawljt IS TABLE OF crapljt%ROWTYPE INDEX BY PLS_INTEGER;

  --Tabela de lancamentos de juros dos titulos
  vr_tab_crawljt typ_tab_crawljt;

  /* Cursores da Package */

  -- Busca do diret¿rio conforme a cooperativa conectada
  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdcooper
          ,crapcop.dsdircop
          ,crapcop.cdbcoctl
          ,crapcop.cdagectl
          ,crapcop.nmrescop
    FROM crapcop crapcop
    WHERE crapcop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Busca dos dados do associado
  CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT crapass.nrdconta
          ,crapass.nmprimtl
          ,crapass.vllimcre
          ,crapass.nrcpfcgc
          ,crapass.inpessoa
          ,crapass.cdcooper
    FROM crapass
    WHERE crapass.cdcooper = pr_cdcooper
    AND   crapass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

  -- Busca os dados de Pessoa Juridica
  CURSOR cr_crapjur(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT natjurid
          ,tpregtrb
      FROM crapjur
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta;
  rw_crapjur cr_crapjur%ROWTYPE;

  --Selecionar erros
  CURSOR cr_craperr (pr_cdcooper IN craperr.cdcooper%type
                    ,pr_cdagenci IN craperr.cdagenci%type
                    ,pr_nrdcaixa IN craperr.nrdcaixa%type) IS
    SELECT craperr.dscritic
    FROM craperr craperr
    WHERE craperr.cdcooper = pr_cdcooper
    AND   craperr.cdagenci = pr_cdagenci
    AND   craperr.nrdcaixa = pr_nrdcaixa;
  rw_craperr cr_craperr%ROWTYPE;

  --Selecionar informacoes dos bancos
  CURSOR cr_crapban (pr_cdbccxlt IN crapban.cdbccxlt%type) IS
    SELECT crapban.nmresbcc
          ,crapban.nmextbcc
    FROM crapban
    WHERE crapban.cdbccxlt = pr_cdbccxlt;
  rw_crapban cr_crapban%ROWTYPE;

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

  --Tipo de Dados para cursor data
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

  /* Procedure para efetuar a liquidacao do bordero */
  PROCEDURE pc_efetua_liquidacao_bordero (pr_cdcooper IN INTEGER --Codigo Cooperativa
                                         ,pr_cdagenci IN INTEGER --Codigo Agencia
                                         ,pr_nrdcaixa IN INTEGER --Numero do Caixa
                                         ,pr_cdoperad IN VARCHAR2 --Codigo Operador
                                         ,pr_dtmvtolt IN DATE     --Data Movimento
                                         ,pr_idorigem IN INTEGER  --Identificador Origem
                                         ,pr_nrdconta IN INTEGER  --Numero da Conta
                                         ,pr_nrborder IN INTEGER  --Numero do Bordero
                                         ,pr_tab_erro OUT GENE0001.typ_tab_erro --Tabela de erros
                                         ,pr_des_erro OUT VARCHAR2 --identificador de erro
                                         ,pr_dscritic OUT VARCHAR2) IS --Descricao do erro
    -- .........................................................................
    --
    --  Programa : pc_efetua_liquidacao_bordero           Antigo: b1wgen0030.p/efetua_liquidacao_bordero
    --  Sistema  : Cred
    --  Sigla    : DSCT0001
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Julho/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para efetuar a liquidacao do bordero
  BEGIN
    DECLARE
      --Selecionar bordero titulo
      CURSOR cr_crapbdt (pr_cdcooper IN crapbdt.cdcooper%TYPE
                        ,pr_nrborder IN crapbdt.nrborder%TYPE) IS
        SELECT crapbdt.cdcooper
              ,crapbdt.nrborder
              ,crapbdt.nrdconta
              ,crapbdt.rowid
        FROM crapbdt
        WHERE crapbdt.cdcooper = pr_cdcooper
        AND   crapbdt.nrborder = pr_nrborder;
      rw_crapbdt cr_crapbdt%ROWTYPE;
      --Selecionar titulos dos borderos
      CURSOR cr_craptdb (pr_cdcooper IN craptdb.cdcooper%type
                        ,pr_nrborder IN craptdb.nrborder%type
                        ,pr_nrdconta IN craptdb.nrdconta%type
                        ,pr_insittit IN craptdb.insittit%type) IS
        SELECT craptdb.cdcooper
        FROM craptdb
        WHERE craptdb.cdcooper = pr_cdcooper
        AND   craptdb.nrborder = pr_nrborder
        AND   craptdb.nrdconta = pr_nrdconta
        AND   craptdb.insittit = pr_insittit;
      rw_craptdb cr_craptdb%ROWTYPE;
      --Variaveis Locais
      vr_contador INTEGER;
      vr_flgliqui BOOLEAN:= TRUE;
      --Variaveis de erro
      vr_des_erro     VARCHAR2(4000);
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Tipo de registro para datas
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      --Tabela de memoria de erros
      vr_tab_erro GENE0001.typ_tab_erro;
      --Variaveis de Excecao
      vr_exc_erro    EXCEPTION;
      vr_exc_proximo EXCEPTION;
    BEGIN
      --Inicializar variaveis erro
      pr_des_erro:= 'OK';
      pr_dscritic:= NULL;
      --Limpar tabela de erros
      pr_tab_erro.DELETE;
      --Inicializar variaveis critica
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
      --Selecionar bordero titulo
      OPEN cr_crapbdt (pr_cdcooper => pr_cdcooper
                      ,pr_nrborder => pr_nrborder);
      --Posicionar no proximo registro
      FETCH cr_crapbdt INTO rw_crapbdt;
      --Se nao encontrar
      IF cr_crapbdt%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapbdt;
        --Mensagem de erro
        vr_dscritic:= 'Bordero nao encontrado.';
        vr_cdcritic:= 0;
        --Gerar erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapbdt;
      --Selecionar titulos dos borderos
      OPEN cr_craptdb (pr_cdcooper => rw_crapbdt.cdcooper
                      ,pr_nrborder => rw_crapbdt.nrborder
                      ,pr_nrdconta => rw_crapbdt.nrdconta
                      ,pr_insittit => 4);
      FETCH cr_craptdb INTO rw_craptdb;
      --Se Encontrou
      IF cr_craptdb%FOUND THEN
        --Liquidado
        vr_flgliqui:= FALSE;
      END IF;
      --Fechar Cursor
      CLOSE cr_craptdb;
      --Se liquidou
      IF vr_flgliqui THEN
        --Atualizar bordero
        BEGIN
          UPDATE crapbdt SET crapbdt.insitbdt = 4
          WHERE crapbdt.ROWID = rw_crapbdt.ROWID;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar tabela crapbdt.'||sqlerrm;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro:= 'NOK';
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_des_erro:= 'NOK';
        pr_dscritic:= 'Erro na rotina DSCT0001.pc_efetua_liquidacao_bordero. '||sqlerrm;
    END;
  END pc_efetua_liquidacao_bordero;

  PROCEDURE pc_efetua_baixa_tit_car(pr_cdcooper    IN crapcop.cdcooper%TYPE      --Codigo Cooperativa
                                   ,pr_cdagenci    IN INTEGER                    --Codigo Agencia
                                   ,pr_nrdcaixa    IN INTEGER                    --Numero Caixa
                                   ,pr_idorigem    IN INTEGER                    --Origem sistema
                                   ,pr_cdoperad    IN VARCHAR2                   --Codigo operador
                                   ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE      --Data Movimento
                                   ,pr_dtmvtoan    IN crapdat.dtmvtoan%TYPE      --Data Movimento Anterior
                                   ,pr_cdcritic    OUT INTEGER                   --Codigo Critica
                                   ,pr_dscritic    OUT VARCHAR2                  --Descricao Critica
                                   ,pr_tab_erro    OUT GENE0001.typ_tab_erro) IS --Tabela erro
  BEGIN
    DECLARE

      -- Cursor sobre os titulos contidos do Bordero de desconto de titulos
      CURSOR cr_craptdb(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                       ,pr_dtrefere IN DATE
                       ,pr_insittit IN craptdb.insittit%TYPE) IS
        SELECT ROWID,
               cdcooper,
               nrdconta,
               nrborder,
               cdbandoc,
               dtvencto,
               dtlibbdt,
               nrcnvcob,
               nrdctabb,
               nrdocmto,
               nrinssac,
               vltitulo,
               vlliquid
          FROM craptdb
         WHERE craptdb.cdcooper  = pr_cdcooper
           AND craptdb.dtvencto >= pr_dtrefere
           AND craptdb.dtvencto  < pr_dtmvtolt
           AND craptdb.insittit  = pr_insittit --4 liberado
           AND craptdb.dtdpagto IS NULL
         ORDER BY cdcooper, nrdconta, dtvencto, nrborder, vltitulo, nrdocmto;

      --Selecionar Bordero de titulos
      CURSOR cr_crapbdt (pr_cdcooper IN crapbdt.cdcooper%type
                        ,pr_nrborder IN crapbdt.nrborder%type) IS
        SELECT crapbdt.txmensal
              ,crapbdt.vltaxiof
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

      --Registro de memoria do tipo lancamento
      rw_craplcm craplcm%ROWTYPE;

  --  vr_cardbtit     INTEGER; --> Parametro de dias carencia cobranca s/ registro
  --  vr_cardbtitcr   INTEGER; --> Parametro de dias carencia cobranca c/ registro

      vr_cardbtitcrpf INTEGER; --> Parametro de dias carencia cobranca c/ registro, pessoa fisica
      vr_cardbtitcrpj INTEGER; --> Parametro de dias carencia cobranca c/ registro, pessoa juridica
      vr_cardbtitpf   INTEGER; --> Parametro de dias carencia cobranca s/ registro, pessoa fisica
      vr_cardbtitpj   INTEGER; --> Parametro de dias carencia cobranca s/ registro, pessoa juridica

      vr_diascare     INTEGER; --> Qtd de dias de carencia
      vr_dtrefere     DATE;    --> Data de referencia para buscar os titulos que vao ser debitados
      vr_dtvcttdb     DATE;    --> Data de vencimento como dia util
      vr_nrseqdig     NUMBER;  --> Nr Sequencia
      vr_dtultdia     DATE;    --> Variavel para armazenar o ultimo dia util do ano
      vr_indice       VARCHAR2(13);
      vr_cdpesqbb     VARCHAR2(1000);
      vr_tab_saldo    EXTR0001.typ_tab_saldos; --> Temp-Table com o saldo do dia

      vr_tab_dados_tar typ_tab_dados_tarifa;

      vr_vlttsrpf     NUMBER;
      vr_vlttsrpj     NUMBER;
      vr_vlttcrpf     NUMBER;
      vr_vlttcrpj     NUMBER;

      vr_dstextab     VARCHAR2(400);
      vr_dsctajud     crapprm.dsvlrprm%TYPE;
      vr_natjurid     crapjur.natjurid%TYPE;
      vr_tpregtrb     crapjur.tpregtrb%TYPE;
      vr_vliofpri     NUMBER(25,2);
      vr_vliofadi     NUMBER(25,2);
      vr_vliofcpl     NUMBER(25,2);
      vr_qtdiaiof     PLS_INTEGER;
      vr_flgimune     PLS_INTEGER;
      vr_dtmvtolt_lcm craplcm.dtmvtolt%TYPE;
      vr_cdagenci_lcm craplcm.cdagenci%TYPE;
      vr_cdbccxlt_lcm craplcm.cdbccxlt%TYPE;
      vr_nrdolote_lcm craplcm.nrdolote%TYPE;
      vr_nrseqdig_lcm craplcm.nrseqdig%TYPE;
      vr_vltaxa_iof_principal NUMBER := 0;

      --vr_seq_tit      PLS_INTEGER := 0;    --> Sequencial do indice vr_ind_tit
      vr_tab_tar      typ_tab_tarifa;

      --Tabela erro
      vr_tab_erro GENE0001.typ_tab_erro;
      --Rowid para a craplat
      vr_rowid_craplat ROWID;


      --Variveis de critica e exceptions
      vr_exc_saida    EXCEPTION;
      vr_exc_erro     EXCEPTION;

      --Variaveis de erro
      vr_des_erro     VARCHAR2(4000);
      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     crapcri.dscritic%TYPE;

      --Busca os valores de tarifa para PF e PJ para os titulos
      PROCEDURE pc_busca_vltarifa_tit(pr_cdcooper  IN  crapcop.cdcooper%TYPE
                                     ,pr_tab_dados OUT typ_tab_dados_tarifa
                                     ,pr_dscritic  OUT crapcri.dscritic%TYPE) IS

          vr_dsmensag     VARCHAR2(100);
          vr_cdpesqbb     VARCHAR2(1000);
          vr_cdbattar     VARCHAR2(1000);
          vr_cdhisest     INTEGER;
          vr_dtdivulg     DATE;
          vr_dtvigenc     DATE;

          vr_vlrtarif     NUMBER;
          vr_cdhistor     INTEGER;
          vr_cdfvlcop     INTEGER;

          vr_cdcritic     crapcri.cdcritic%TYPE;
          vr_dscritic     crapcri.dscritic%TYPE;
          vr_tab_erro     GENE0001.typ_tab_erro;
          vr_exc_erro     EXCEPTION;
      BEGIN

        pr_tab_dados.delete;

        --Sem Registro PF
        vr_cdbattar:= 'DSTTITSRPF';

        /*  Busca valor da tarifa sem registro*/
        TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => pr_cdcooper  --Codigo Cooperativa
                                              ,pr_cdbattar  => vr_cdbattar  --Codigo Tarifa
                                              ,pr_vllanmto  => 1            --Valor Lancamento
                                              ,pr_cdprogra  => NULL         --Codigo Programa
                                              ,pr_cdhistor  => vr_cdhistor  --Codigo Historico
                                              ,pr_cdhisest  => vr_cdhisest  --Historico Estorno
                                              ,pr_vltarifa  => vr_vlrtarif  --Valor tarifa
                                              ,pr_dtdivulg  => vr_dtdivulg  --Data Divulgacao
                                              ,pr_dtvigenc  => vr_dtvigenc  --Data Vigencia
                                              ,pr_cdfvlcop  => vr_cdfvlcop  --Codigo faixa valor cooperativa
                                              ,pr_cdcritic  => vr_cdcritic  --Codigo Critica
                                              ,pr_dscritic  => vr_dscritic  --Descricao Critica
                                              ,pr_tab_erro  => vr_tab_erro); --Tabela erros
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

        pr_tab_dados('SRPF').cdfvlcop := vr_cdfvlcop;
        pr_tab_dados('SRPF').vltottar := 0;
        pr_tab_dados('SRPF').cdhistor := vr_cdhistor;
        pr_tab_dados('SRPF').vlrtarif := vr_vlrtarif;

        --Sem Registro PJ
        vr_cdbattar:= 'DSTTITSRPJ';

        /*  Busca valor da tarifa sem registro*/
        TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => pr_cdcooper  --Codigo Cooperativa
                                              ,pr_cdbattar  => vr_cdbattar  --Codigo Tarifa
                                              ,pr_vllanmto  => 1            --Valor Lancamento
                                              ,pr_cdprogra  => NULL         --Codigo Programa
                                              ,pr_cdhistor  => vr_cdhistor  --Codigo Historico
                                              ,pr_cdhisest  => vr_cdhisest  --Historico Estorno
                                              ,pr_vltarifa  => vr_vlrtarif  --Valor tarifa
                                              ,pr_dtdivulg  => vr_dtdivulg  --Data Divulgacao
                                              ,pr_dtvigenc  => vr_dtvigenc  --Data Vigencia
                                              ,pr_cdfvlcop  => vr_cdfvlcop  --Codigo faixa valor cooperativa
                                              ,pr_cdcritic  => vr_cdcritic  --Codigo Critica
                                              ,pr_dscritic  => vr_dscritic  --Descricao Critica
                                              ,pr_tab_erro  => vr_tab_erro); --Tabela erros
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

        pr_tab_dados('SRPJ').cdfvlcop := vr_cdfvlcop;
        pr_tab_dados('SRPJ').vltottar := 0;
        pr_tab_dados('SRPJ').cdhistor := vr_cdhistor;
        pr_tab_dados('SRPJ').vlrtarif := vr_vlrtarif;


        --Com registro PF
        vr_cdbattar:= 'DSTTITCRPF';

        /*  Busca valor da tarifa sem registro*/
        TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => pr_cdcooper  --Codigo Cooperativa
                                              ,pr_cdbattar  => vr_cdbattar  --Codigo Tarifa
                                              ,pr_vllanmto  => 1            --Valor Lancamento
                                              ,pr_cdprogra  => NULL         --Codigo Programa
                                              ,pr_cdhistor  => vr_cdhistor  --Codigo Historico
                                              ,pr_cdhisest  => vr_cdhisest  --Historico Estorno
                                              ,pr_vltarifa  => vr_vlrtarif  --Valor tarifa
                                              ,pr_dtdivulg  => vr_dtdivulg  --Data Divulgacao
                                              ,pr_dtvigenc  => vr_dtvigenc  --Data Vigencia
                                              ,pr_cdfvlcop  => vr_cdfvlcop  --Codigo faixa valor cooperativa
                                              ,pr_cdcritic  => vr_cdcritic  --Codigo Critica
                                              ,pr_dscritic  => vr_dscritic  --Descricao Critica
                                              ,pr_tab_erro  => vr_tab_erro); --Tabela erros
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

        pr_tab_dados('CRPF').cdfvlcop := vr_cdfvlcop;
        pr_tab_dados('CRPF').vltottar := 0;
        pr_tab_dados('CRPF').cdhistor := vr_cdhistor;
        pr_tab_dados('CRPF').vlrtarif := vr_vlrtarif;


        --Com registro PJ
        vr_cdbattar:= 'DSTTITCRPJ';

        /*  Busca valor da tarifa sem registro*/
        TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => pr_cdcooper  --Codigo Cooperativa
                                              ,pr_cdbattar  => vr_cdbattar  --Codigo Tarifa
                                              ,pr_vllanmto  => 1            --Valor Lancamento
                                              ,pr_cdprogra  => NULL         --Codigo Programa
                                              ,pr_cdhistor  => vr_cdhistor  --Codigo Historico
                                              ,pr_cdhisest  => vr_cdhisest  --Historico Estorno
                                              ,pr_vltarifa  => vr_vlrtarif  --Valor tarifa
                                              ,pr_dtdivulg  => vr_dtdivulg  --Data Divulgacao
                                              ,pr_dtvigenc  => vr_dtvigenc  --Data Vigencia
                                              ,pr_cdfvlcop  => vr_cdfvlcop  --Codigo faixa valor cooperativa
                                              ,pr_cdcritic  => vr_cdcritic  --Codigo Critica
                                              ,pr_dscritic  => vr_dscritic  --Descricao Critica
                                              ,pr_tab_erro  => vr_tab_erro); --Tabela erros
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

        pr_tab_dados('CRPJ').cdfvlcop := vr_cdfvlcop;
        pr_tab_dados('CRPJ').vltottar := 0;
        pr_tab_dados('CRPJ').cdhistor := vr_cdhistor;
        pr_tab_dados('CRPJ').vlrtarif := vr_vlrtarif;

      EXCEPTION
        WHEN vr_exc_erro THEN
          pr_cdcritic:= vr_cdcritic;
          pr_dscritic:= vr_dscritic;

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 /** Sequencia **/
                               ,pr_cdcritic => pr_cdcritic
                               ,pr_dscritic => pr_dscritic
                               ,pr_tab_erro => vr_tab_erro);

          pr_tab_erro := vr_tab_erro;

        WHEN OTHERS THEN
          -- Erro
          pr_cdcritic:= 0;
          pr_dscritic:= 'Erro na rotina DSCT0001.pc_efetua_baixa_titulo. '||sqlerrm;

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 /** Sequencia **/
                               ,pr_cdcritic => pr_cdcritic
                               ,pr_dscritic => pr_dscritic
                               ,pr_tab_erro => vr_tab_erro);

      END pc_busca_vltarifa_tit;

      --Pega maior nrseqdig lcm
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
             AND lcm.nrdolote = 10301
             AND lcm.cdhistor = 591;
        rw_craplcm_seq cr_craplcm_seq%ROWTYPE;
      BEGIN
        OPEN cr_craplcm_seq(pr_cdcooper => pr_cdcooper
                           ,pr_dtmvtolt => pr_dtmvtolt);
        FETCH cr_craplcm_seq INTO rw_craplcm_seq;

        IF cr_craplcm_seq%NOTFOUND THEN
           CLOSE cr_craplcm_seq;
           RETURN 0;
        END IF;

        CLOSE cr_craplcm_seq;
        RETURN rw_craplcm_seq.nrseqdig;
      END;

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
      END;

      --Busca data de referencia para processamento dos titulos
      FUNCTION fn_dtrefere_carencia(pr_cdcooper crapcop.cdcooper%TYPE
                                   ,pr_dtmvtolt crapdat.dtmvtolt%TYPE
                                   ,pr_dtmvtoan crapdat.dtmvtoan%TYPE) RETURN DATE IS
        vr_dtdiauti       DATE;
        vr_dtverifi       DATE;
        vr_dtvalida       DATE;
      BEGIN

        /*Pegar o penultimo dia util do ano passado qdo rodar no primeiro
          dia util deste ano ou processar com dtmvtoan */
        vr_dtdiauti := to_date('0101'||to_char(pr_dtmvtolt,'YYYY'),'ddmmyyyy');
        vr_dtdiauti := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                   pr_dtmvtolt => vr_dtdiauti,
                                                   pr_tipo => 'P', -- Proximo
                                                   pr_feriado => TRUE);

        IF vr_dtdiauti = pr_dtmvtolt THEN
           vr_dtvalida := trunc(pr_dtmvtolt,'RRRR') - 1; -- 31/12/YYYY
           vr_dtverifi := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                      pr_dtmvtolt => vr_dtvalida,
                                                      pr_tipo => 'A', -- Anterior
                                                      pr_feriado => FALSE);

           IF vr_dtvalida = vr_dtverifi THEN
              vr_dtvalida := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                         pr_dtmvtolt => vr_dtvalida - 1,
                                                         pr_tipo => 'A', -- Anterior
                                                         pr_feriado => FALSE);
           ELSE
              vr_dtvalida := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                         pr_dtmvtolt => vr_dtverifi - 1,
                                                         pr_tipo => 'A', -- Anterior
                                                         pr_feriado => FALSE);
           END IF;

        ELSE
           vr_dtvalida := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                      pr_dtmvtolt => pr_dtmvtoan,
                                                      pr_tipo => 'A', -- Anterior
                                                      pr_feriado => FALSE);
        END IF;

        vr_dtvalida := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                   pr_dtmvtolt => vr_dtvalida - 6, --DtReferencia - (max carencia + 1)
                                                   pr_tipo => 'A', -- Anterior
                                                   pr_feriado => TRUE);

        RETURN vr_dtvalida;
      END;


    BEGIN

/*#########################Carrega variaveis e parametros iniciais################################################*/

      --tabela que guarda a qtd de tit
      --que devem ser tarifados por conta
      vr_tab_tar.delete;


      -- Cobrança com Registro - Pessoa Física
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'USUARI'
                                              ,pr_cdempres => 11
                                              ,pr_cdacesso => 'LIMDESCTITCRPF'
                                              ,pr_tpregist => 0);
      --Se nao encontrou
      IF vr_dstextab IS NULL THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Carencia para desconto de titulo nao encontrada.';
          --Levantar Excecao
          RAISE vr_exc_erro;
      ELSE
        vr_cardbtitcrpf := TO_NUMBER(gene0002.fn_busca_entrada(pr_postext => 32, pr_dstext => vr_dstextab, pr_delimitador => ';'));
      END IF;
      --

      -- Cobrança com Registro - Pessoa Jurídica
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'USUARI'
                                              ,pr_cdempres => 11
                                              ,pr_cdacesso => 'LIMDESCTITCRPJ'
                                              ,pr_tpregist => 0);
      --Se nao encontrou
      IF vr_dstextab IS NULL THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Carencia para desconto de titulo nao encontrada.';
          --Levantar Excecao
          RAISE vr_exc_erro;
      ELSE
        vr_cardbtitcrpj := TO_NUMBER(gene0002.fn_busca_entrada(pr_postext => 32, pr_dstext => vr_dstextab, pr_delimitador => ';'));
      END IF;
      --

      -- Cobrança sem Registro - Pessoa Física
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'USUARI'
                                              ,pr_cdempres => 11
                                              ,pr_cdacesso => 'LIMDESCTITPF'
                                              ,pr_tpregist => 0);
      --Se nao encontrou
      IF vr_dstextab IS NULL THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Carencia para desconto de titulo nao encontrada.';
          --Levantar Excecao
          RAISE vr_exc_erro;
      ELSE
        vr_cardbtitpf := TO_NUMBER(gene0002.fn_busca_entrada(pr_postext => 32, pr_dstext => vr_dstextab, pr_delimitador => ';'));
      END IF;
      --

      -- Cobrança sem Registro - Pessoa Jurídica
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'USUARI'
                                              ,pr_cdempres => 11
                                              ,pr_cdacesso => 'LIMDESCTITPJ'
                                              ,pr_tpregist => 0);
      --Se nao encontrou
      IF vr_dstextab IS NULL THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Carencia para desconto de titulo nao encontrada.';
          --Levantar Excecao
          RAISE vr_exc_erro;
      ELSE
        vr_cardbtitpj := TO_NUMBER(gene0002.fn_busca_entrada(pr_postext => 32, pr_dstext => vr_dstextab, pr_delimitador => ';'));
      END IF;
      --

      --Pega data de referencia que deve buscar os titulos para processamento
      vr_dtrefere := fn_dtrefere_carencia(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_dtmvtoan => pr_dtmvtoan);

      vr_nrseqdig := fn_busca_nrseqdig(pr_cdcooper => pr_cdcooper
                                      ,pr_dtmvtolt => pr_dtmvtolt) + 1;

      --Selecionar a data do movimento
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se nao encontrar
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
/*######################Fim Carrega variaveis e parametros iniciais###############################################*/

      -- Lista de contas que nao podem debitar na conta corrente, devido a acao judicial
      vr_dsctajud := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                               pr_cdcooper => pr_cdcooper,
                                               pr_cdacesso => 'CONTAS_ACAO_JUDICIAL');

      -- Rotina para achar o ultimo dia útil do ano
      vr_dtultdia := add_months(TRUNC(rw_crapdat.dtmvtoan,'RRRR'),12)-1;
      CASE to_char(vr_dtultdia,'d')
        WHEN '1' THEN vr_dtultdia := vr_dtultdia - 2;
        WHEN '7' THEN vr_dtultdia := vr_dtultdia - 1;
        ELSE vr_dtultdia := add_months(TRUNC(rw_crapdat.dtmvtoan,'RRRR'),12)-1;
      END CASE;

/*######################Loop Principal Pegando os titulos para Processamento######################################*/
      FOR rw_craptdb IN cr_craptdb(pr_cdcooper => pr_cdcooper
                                  ,pr_dtmvtolt => pr_dtmvtolt
                                  ,pr_dtrefere => vr_dtrefere
                                  ,pr_insittit => 4) LOOP

        -- Condicao para verificar se permite incluir as linhas parametrizadas
        IF INSTR(',' || vr_dsctajud || ',',',' || rw_craptdb.nrdconta || ',') > 0 THEN
          CONTINUE;
        END IF;

        /* Caso o titulo venca num feriado ou fim de semana, pula pois sera pego
           no proximo dia util */
        IF gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                       pr_dtmvtolt => rw_craptdb.dtvencto) > rw_crapdat.dtmvtoan THEN
          CONTINUE;
        END IF;

        -- #################################################################################################
        --   REGRA PARA NÃO DEBITAR TÍTULOS VENCIDOS NO PRIMEIRO DIA UTIL DO ANO E QUE VENCERAM NO
        --   DIA UTIL ANTERIOR.
        --   Ex: Boleto com vencto  = 29/12/2017  (ultimo dia útil do ano)
        --       Se o movimento for = 02/01/2018  (primeiro dia util do ano) -- nao debitar --
        --       Se o movimento for = 03/01/2018  (segundo dia util do ano)  -- debitar --
        -- #################################################################################################
        -- se o titulo vencer no último dia útil do ano e também no dia útil anterior,
        -- entao "não" deverá debitar o título
        IF rw_craptdb.dtvencto = vr_dtultdia AND
           rw_craptdb.dtvencto = rw_crapdat.dtmvtoan THEN
           CONTINUE;
        END IF;
        -- #################################################################################################

        --Verifica se a conta existe
        OPEN cr_crapass(pr_cdcooper => rw_craptdb.cdcooper
                       ,pr_nrdconta => rw_craptdb.nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          vr_cdcritic := 9; --Associado n cadastrado
          vr_dscritic := NULL;
          RAISE vr_exc_erro;
        END IF;
        CLOSE cr_crapass;

        vr_natjurid := 0;
        vr_tpregtrb := 0;
        -- Condicao para verificar se eh pessoa juridica
        IF rw_crapass.inpessoa >= 2 THEN
          --Verifica se a conta existe
          OPEN cr_crapjur(pr_cdcooper => rw_craptdb.cdcooper
                         ,pr_nrdconta => rw_craptdb.nrdconta);
          FETCH cr_crapjur INTO rw_crapjur;
          IF cr_crapjur%FOUND THEN
            CLOSE cr_crapjur;
            vr_natjurid := rw_crapjur.natjurid;
            vr_tpregtrb := rw_crapjur.tpregtrb;
          ELSE
            CLOSE cr_crapjur;
          END IF;

        END IF;  --  IF rw_crapass.inpessoa >= 2 THEN

        /*#################################################################################################*/
        /* Aqui tera as regras de carencia do titulo pra ver se deve cobrar ou nao                         */
        /* OBS-Nao usar a tab craplot e gravar na LCM 10301 como lote ficou reservado para esta finalidade */
        /*#################################################################################################*/

        /*1 - se a data vencto mais a carencia for menor ou igual ao dia de hoje cobrar
          o titulo independente de saldo em conta.
          2 - se o titulo esta  vencido e ainda ha saldo devera pagar.
          3 - caso ainda haja saldo continua debitando os titulos que estao no dia de
          vencimento ou ja estao vencidos*/

         -- se ainda nao acabou a carencia deve verificar saldo
         -- contar a partir do primeiro dia util qdo a data de vencimento cair no final de semana ou feriado
         --
         -- Com Registro, Pessoa Física
         IF (gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                         pr_dtmvtolt => rw_craptdb.dtvencto) + vr_cardbtitcrpf) > pr_dtmvtolt THEN

           EXTR0001.pc_obtem_saldo_dia (pr_cdcooper   => pr_cdcooper
                                       ,pr_rw_crapdat => rw_crapdat
                                       ,pr_cdagenci   => pr_cdagenci
                                       ,pr_nrdcaixa   => pr_nrdcaixa
                                       ,pr_cdoperad   => pr_cdoperad
                                       ,pr_nrdconta   => rw_crapass.nrdconta
                                       ,pr_vllimcre   => rw_crapass.vllimcre
                                       ,pr_tipo_busca => 'A' --> tipo de busca(A-dtmvtoan)
                                       ,pr_flgcrass   => FALSE
                                       ,pr_dtrefere   => pr_dtmvtolt
                                       ,pr_des_reto   => vr_dscritic
                                       ,pr_tab_sald   => vr_tab_saldo
                                       ,pr_tab_erro   => vr_tab_erro);
           --Se ocorreu erro
           IF vr_dscritic = 'NOK' THEN
             -- Tenta buscar o erro no vetor de erro
             IF vr_tab_erro.COUNT > 0 THEN
               vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
               vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_craptdb.nrdconta;
             ELSE
               vr_cdcritic:= 0;
               vr_dscritic:= 'Retorno "NOK" na extr0001.pc_obtem_saldo_dia e sem informação na pr_tab_erro, Conta: '||rw_crapass.nrdconta;
             END IF;

             --continue;
             --Levantar Excecao
             RAISE vr_exc_erro;
           ELSE
             vr_dscritic:= NULL;
           END IF;
           --Verificar o saldo retornado

           IF vr_tab_saldo.Count = 0 THEN
             --Montar mensagem erro
             vr_cdcritic:= 0;
             vr_dscritic:= 'Nao foi possivel consultar o saldo para a operacao.';
             --Levantar Excecao
             RAISE vr_exc_erro;
           END IF;

           --Se o saldo nao for suficiente
           IF rw_craptdb.vltitulo > (nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) +
                                     nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0)) THEN
              CONTINUE;
           END IF;

         END IF;
         --

         -- Com Registro, Pessoa Jurídica
         IF (gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                         pr_dtmvtolt => rw_craptdb.dtvencto) + vr_cardbtitcrpj) > pr_dtmvtolt THEN


           EXTR0001.pc_obtem_saldo_dia (pr_cdcooper   => pr_cdcooper
                                       ,pr_rw_crapdat => rw_crapdat
                                       ,pr_cdagenci   => pr_cdagenci
                                       ,pr_nrdcaixa   => pr_nrdcaixa
                                       ,pr_cdoperad   => pr_cdoperad
                                       ,pr_nrdconta   => rw_crapass.nrdconta
                                       ,pr_vllimcre   => rw_crapass.vllimcre
                                       ,pr_tipo_busca => 'A' --> tipo de busca(A-dtmvtoan)
                                       ,pr_flgcrass   => FALSE
                                       ,pr_dtrefere   => pr_dtmvtolt
                                       ,pr_des_reto   => vr_dscritic
                                       ,pr_tab_sald   => vr_tab_saldo
                                       ,pr_tab_erro   => vr_tab_erro);
           --Se ocorreu erro
           IF vr_dscritic = 'NOK' THEN
             -- Tenta buscar o erro no vetor de erro
             IF vr_tab_erro.COUNT > 0 THEN
               vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
               vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_craptdb.nrdconta;
             ELSE
               vr_cdcritic:= 0;
               vr_dscritic:= 'Retorno "NOK" na extr0001.pc_obtem_saldo_dia e sem informação na pr_tab_erro, Conta: '||rw_crapass.nrdconta;
             END IF;

             --continue;
             --Levantar Excecao
             RAISE vr_exc_erro;
           ELSE
             vr_dscritic:= NULL;
           END IF;
           --Verificar o saldo retornado

           IF vr_tab_saldo.Count = 0 THEN
             --Montar mensagem erro
             vr_cdcritic:= 0;
             vr_dscritic:= 'Nao foi possivel consultar o saldo para a operacao.';
             --Levantar Excecao
             RAISE vr_exc_erro;
           END IF;

           --Se o saldo nao for suficiente
           IF rw_craptdb.vltitulo > (nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) +
                                     nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0)) THEN
              CONTINUE;
           END IF;

         END IF;
         --

         -- Sem Registro, Pessoa Física
         IF (gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                         pr_dtmvtolt => rw_craptdb.dtvencto) + vr_cardbtitpf) > pr_dtmvtolt THEN


           EXTR0001.pc_obtem_saldo_dia (pr_cdcooper   => pr_cdcooper
                                       ,pr_rw_crapdat => rw_crapdat
                                       ,pr_cdagenci   => pr_cdagenci
                                       ,pr_nrdcaixa   => pr_nrdcaixa
                                       ,pr_cdoperad   => pr_cdoperad
                                       ,pr_nrdconta   => rw_crapass.nrdconta
                                       ,pr_vllimcre   => rw_crapass.vllimcre
                                       ,pr_tipo_busca => 'A' --> tipo de busca(A-dtmvtoan)
                                       ,pr_flgcrass   => FALSE
                                       ,pr_dtrefere   => pr_dtmvtolt
                                       ,pr_des_reto   => vr_dscritic
                                       ,pr_tab_sald   => vr_tab_saldo
                                       ,pr_tab_erro   => vr_tab_erro);
           --Se ocorreu erro
           IF vr_dscritic = 'NOK' THEN
             -- Tenta buscar o erro no vetor de erro
             IF vr_tab_erro.COUNT > 0 THEN
               vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
               vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_craptdb.nrdconta;
             ELSE
               vr_cdcritic:= 0;
               vr_dscritic:= 'Retorno "NOK" na extr0001.pc_obtem_saldo_dia e sem informação na pr_tab_erro, Conta: '||rw_crapass.nrdconta;
             END IF;

             --continue;
             --Levantar Excecao
             RAISE vr_exc_erro;
           ELSE
             vr_dscritic:= NULL;
           END IF;
           --Verificar o saldo retornado

           IF vr_tab_saldo.Count = 0 THEN
             --Montar mensagem erro
             vr_cdcritic:= 0;
             vr_dscritic:= 'Nao foi possivel consultar o saldo para a operacao.';
             --Levantar Excecao
             RAISE vr_exc_erro;
           END IF;

           --Se o saldo nao for suficiente
           IF rw_craptdb.vltitulo > (nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) +
                                     nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0)) THEN
              CONTINUE;
           END IF;

         END IF;
         --

         -- Sem Registro, Pessoa Jurídica
         IF (gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                         pr_dtmvtolt => rw_craptdb.dtvencto) + vr_cardbtitpj) > pr_dtmvtolt THEN


           EXTR0001.pc_obtem_saldo_dia (pr_cdcooper   => pr_cdcooper
                                       ,pr_rw_crapdat => rw_crapdat
                                       ,pr_cdagenci   => pr_cdagenci
                                       ,pr_nrdcaixa   => pr_nrdcaixa
                                       ,pr_cdoperad   => pr_cdoperad
                                       ,pr_nrdconta   => rw_crapass.nrdconta
                                       ,pr_vllimcre   => rw_crapass.vllimcre
                                       ,pr_tipo_busca => 'A' --> tipo de busca(A-dtmvtoan)
                                       ,pr_flgcrass   => FALSE
                                       ,pr_dtrefere   => pr_dtmvtolt
                                       ,pr_des_reto   => vr_dscritic
                                       ,pr_tab_sald   => vr_tab_saldo
                                       ,pr_tab_erro   => vr_tab_erro);
           --Se ocorreu erro
           IF vr_dscritic = 'NOK' THEN
             -- Tenta buscar o erro no vetor de erro
             IF vr_tab_erro.COUNT > 0 THEN
               vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
               vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_craptdb.nrdconta;
             ELSE
               vr_cdcritic:= 0;
               vr_dscritic:= 'Retorno "NOK" na extr0001.pc_obtem_saldo_dia e sem informação na pr_tab_erro, Conta: '||rw_crapass.nrdconta;
             END IF;

             --continue;
             --Levantar Excecao
             RAISE vr_exc_erro;
           ELSE
             vr_dscritic:= NULL;
           END IF;
           --Verificar o saldo retornado

           IF vr_tab_saldo.Count = 0 THEN
             --Montar mensagem erro
             vr_cdcritic:= 0;
             vr_dscritic:= 'Nao foi possivel consultar o saldo para a operacao.';
             --Levantar Excecao
             RAISE vr_exc_erro;
           END IF;

           --Se o saldo nao for suficiente
           IF rw_craptdb.vltitulo > (nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) +
                                     nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0)) THEN
              CONTINUE;
           END IF;

         END IF;
         --
        /*###################################FIM REGRAS####################################################*/

        --Gravar lancamento
        BEGIN
          INSERT INTO craplcm
              (craplcm.dtmvtolt
              ,craplcm.cdagenci
              ,craplcm.cdbccxlt
              ,craplcm.nrdolote
              ,craplcm.nrdconta
              ,craplcm.nrdocmto
              ,craplcm.vllanmto
              ,craplcm.cdhistor
              ,craplcm.nrseqdig
              ,craplcm.nrdctabb
              ,craplcm.nrautdoc
              ,craplcm.cdcooper
              ,craplcm.cdpesqbb)
          VALUES
              (pr_dtmvtolt --tiago lancamento tem quer ser com dtmvtolt da crapdat
              ,1
              ,100
              ,10301 --Utilizando este nr de lote pois nao cria mais o lote e este nr ficou reservado
              ,rw_craptdb.nrdconta
              ,NVL(vr_nrseqdig,0)
              ,rw_craptdb.vltitulo
              ,591
              ,NVL(vr_nrseqdig,0)
              ,rw_craptdb.nrdconta
              ,0
              ,pr_cdcooper
              ,rw_craptdb.nrdocmto)
          RETURNING craplcm.nrseqdig
                   ,craplcm.vllanmto
          INTO rw_craplcm.nrseqdig
              ,rw_craplcm.vllanmto;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao inserir na tabela de lancamentos. '||sqlerrm;
            RAISE vr_exc_erro;
        END;

        vr_nrseqdig := vr_nrseqdig + 1; --Proxima sequencia

        /*#########BUSCAR BDT BORDERO##################################*/
        --Selecionar Bordero de titulos
        OPEN cr_crapbdt (pr_cdcooper => rw_craptdb.cdcooper
                        ,pr_nrborder => rw_craptdb.nrborder);
        --Posicionar no proximo registro
        FETCH cr_crapbdt INTO rw_crapbdt;
        --Se nao encontrar
        IF cr_crapbdt%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapbdt;
          --Mensagem de erro
          vr_dscritic:= 'Bordero nao encontrado.';
          vr_cdcritic:= 0;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapbdt;
        /*#########FIM BUSCAR BDT BORDERO##################################*/

        ------------------------------------------------------------------------------------------
        -- Inicio Efetuar o Lancamento de IOF
        ------------------------------------------------------------------------------------------
        vr_vltotal_liquido := 0;
        OPEN cr_craptdb_total(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => rw_craptdb.nrdconta
                             ,pr_nrborder => rw_craptdb.nrborder);
        FETCH cr_craptdb_total
          INTO vr_vltotal_liquido;
        CLOSE cr_craptdb_total;

        -- Quantidade de Dias em atraso
        vr_qtdiaiof := pr_dtmvtolt - rw_craptdb.dtvencto;
        /*
        TIOF0001.pc_calcula_valor_iof(pr_tpproduto  => 2 --> Desconto de Titulo
                                     ,pr_tpoperacao => 2 --> Pagamento Em Atraso
                                     ,pr_cdcooper   => pr_cdcooper
                                     ,pr_nrdconta   => rw_craptdb.nrdconta
                                     ,pr_inpessoa   => rw_crapass.inpessoa
                                     ,pr_natjurid   => vr_natjurid
                                     ,pr_tpregtrb   => vr_tpregtrb
                                     ,pr_dtmvtolt   => pr_dtmvtolt
                                     ,pr_qtdiaiof   => vr_qtdiaiof
                                     ,pr_vloperacao => NVL(rw_craptdb.vlliquid,0)
                                     ,pr_vltotalope => vr_vltotal_liquido
                                     ,pr_vltaxa_iof_atraso => NVL(rw_crapbdt.vltaxiof,0)
                                     ,pr_vliofpri   => vr_vliofpri
                                     ,pr_vliofadi   => vr_vliofadi
                                     ,pr_vliofcpl   => vr_vliofcpl
                                     ,pr_vltaxa_iof_principal => vr_vltaxa_iof_principal
                                     ,pr_dscritic   => vr_dscritic
                                     ,pr_flgimune   => vr_flgimune);

        -- Condicao para verificar se houve critica
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;*/

        IF (NVL(vr_vliofcpl,0) > 0) AND vr_flgimune <= 0 THEN
          -- Grava na tabela de lancamentos
          BEGIN
            INSERT INTO craplcm
                (craplcm.dtmvtolt
                ,craplcm.cdagenci
                ,craplcm.cdbccxlt
                ,craplcm.nrdolote
                ,craplcm.nrdconta
                ,craplcm.nrdocmto
                ,craplcm.vllanmto
                ,craplcm.cdhistor
                ,craplcm.nrseqdig
                ,craplcm.nrdctabb
                ,craplcm.nrautdoc
                ,craplcm.cdcooper
                ,craplcm.cdpesqbb)
            VALUES
                (pr_dtmvtolt
                ,1
                ,100
                ,10301
                ,rw_craptdb.nrdconta
                ,NVL(vr_nrseqdig,0)
                ,vr_vliofcpl
                ,2321
                ,NVL(vr_nrseqdig,0)
                ,rw_craptdb.nrdconta
                ,0
                ,pr_cdcooper
                ,rw_craptdb.nrdocmto)
            RETURNING craplcm.dtmvtolt
                     ,craplcm.cdagenci
                     ,craplcm.cdbccxlt
                     ,craplcm.nrdolote
                     ,craplcm.nrseqdig
                 INTO vr_dtmvtolt_lcm
                     ,vr_cdagenci_lcm
                     ,vr_cdbccxlt_lcm
                     ,vr_nrdolote_lcm
                     ,vr_nrseqdig_lcm;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao inserir na tabela de lancamentos. '||sqlerrm;
              RAISE vr_exc_erro;
          END;

          vr_nrseqdig := vr_nrseqdig + 1; --Proxima sequencia
        END IF;
        /*
        TIOF0001.pc_insere_iof(pr_cdcooper     => pr_cdcooper
                              ,pr_nrdconta     => rw_craptdb.nrdconta
                              ,pr_dtmvtolt     => pr_dtmvtolt
                              ,pr_tpproduto    => 2   --> Desconto de Titulo
                              ,pr_nrcontrato   => rw_craptdb.nrborder
                              ,pr_dtmvtolt_lcm => vr_dtmvtolt_lcm
                              ,pr_cdagenci_lcm => vr_cdagenci_lcm
                              ,pr_cdbccxlt_lcm => vr_cdbccxlt_lcm
                              ,pr_nrdolote_lcm => vr_nrdolote_lcm
                              ,pr_nrseqdig_lcm => vr_nrseqdig_lcm
                              ,pr_vliofcpl     => vr_vliofcpl
                              ,pr_flgimune     => vr_flgimune
                              ,pr_cdcritic     => vr_cdcritic
                              ,pr_dscritic     => vr_dscritic);

        -- Condicao para verificar se houve critica
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        */
        ------------------------------------------------------------------------------------------
        -- Fim Efetuar o Lancamento de IOF
        ------------------------------------------------------------------------------------------

        /*#########ATUALIZA TDB##################################*/
        --Atualizar situacao titulo
        BEGIN
          UPDATE craptdb
             SET craptdb.insittit = 3, /* Baixado s/ pagto */
                 craptdb.dtdebito = pr_dtmvtolt
           WHERE craptdb.ROWID = rw_craptdb.ROWID;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar tabela craptdb. '||SQLERRM;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
        /*#########FIM ATUALIZA TDB##################################*/

        /*#########LIQUIDA BORDERO##################################*/
        /* Verifica se deve liquidar o bordero caso sim Liquida */
        DSCT0001.pc_efetua_liquidacao_bordero (pr_cdcooper => rw_craptdb.cdcooper  --Codigo Cooperativa
                                              ,pr_cdagenci => pr_cdagenci  --Codigo Agencia
                                              ,pr_nrdcaixa => pr_nrdcaixa  --Numero do Caixa
                                              ,pr_cdoperad => pr_cdoperad  --Codigo Operador
                                              ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                              ,pr_idorigem => pr_idorigem  --Identificador Origem
                                              ,pr_nrdconta => rw_craptdb.nrdconta  --Numero da Conta
                                              ,pr_nrborder => rw_craptdb.nrborder  --Numero do Bordero
                                              ,pr_tab_erro => vr_tab_erro   --Tabela de erros
                                              ,pr_des_erro => vr_des_erro   --identificador de erro
                                              ,pr_dscritic => vr_dscritic); --Descricao do erro;
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          --Mensagem erro
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro na liquidacao do bordero '||
                        rw_craptdb.nrborder||' conta '||rw_craptdb.nrdconta;

          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        /*#########FIM LIQUIDA BORDERO##################################*/


        /*#########GUARDAR TARIFA TITULO#########################*/
        vr_tab_tar(LPAD(rw_craptdb.cdcooper,3,'0')||LPAD(rw_craptdb.nrdconta,10,'0')).cdcooper := rw_craptdb.cdcooper;
        vr_tab_tar(LPAD(rw_craptdb.cdcooper,3,'0')||LPAD(rw_craptdb.nrdconta,10,'0')).nrdconta := rw_craptdb.nrdconta;

        --verificar se eh cobranca registrada ou nao
        IF fn_verifica_cobranca_reg(pr_cdcooper => rw_craptdb.cdcooper
                                   ,pr_nrcnvcob => rw_craptdb.nrcnvcob) THEN
           vr_tab_tar(LPAD(rw_craptdb.cdcooper,3,'0')||LPAD(rw_craptdb.nrdconta,10,'0')).qtdtarcr :=
           NVL(vr_tab_tar(LPAD(rw_craptdb.cdcooper,3,'0')||LPAD(rw_craptdb.nrdconta,10,'0')).qtdtarcr,0) + 1;
        ELSE
           vr_tab_tar(LPAD(rw_craptdb.cdcooper,3,'0')||LPAD(rw_craptdb.nrdconta,10,'0')).qtdtarsr :=
           NVL(vr_tab_tar(LPAD(rw_craptdb.cdcooper,3,'0')||LPAD(rw_craptdb.nrdconta,10,'0')).qtdtarsr,0) + 1;
        END IF;
        /*#########FIM GUARDAR TARIFA TITULO#########################*/

      END LOOP;
/*######################FIM Loop Principal Pegando os titulos para Processamento######################################*/

      /*#########LANCAR TARIFA TITULO#########################*/
      pc_busca_vltarifa_tit(pr_cdcooper  => pr_cdcooper
                           ,pr_tab_dados => vr_tab_dados_tar
                           ,pr_dscritic  => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_erro;
      END IF;

      vr_indice := vr_tab_tar.FIRST;

      WHILE vr_indice IS NOT NULL LOOP


        vr_tab_dados_tar('CRPF').vltottar := 0;
        vr_tab_dados_tar('SRPF').vltottar := 0;
        vr_tab_dados_tar('CRPJ').vltottar := 0;
        vr_tab_dados_tar('SRPJ').vltottar := 0;

        --Verifica se a conta existe
        OPEN cr_crapass(pr_cdcooper => vr_tab_tar(vr_indice).cdcooper
                       ,pr_nrdconta => vr_tab_tar(vr_indice).nrdconta);
        FETCH cr_crapass INTO rw_crapass;

        IF cr_crapass%NOTFOUND THEN
           CLOSE cr_crapass;

           vr_cdcritic := 9; --Associado n cadastrado
           vr_dscritic := NULL;

           RAISE vr_exc_erro;
        END IF;

        CLOSE cr_crapass;


        -- Multiplica a qtd de titulos por suas tarifas correspondentes
        -- dependendo o tipo de pessoa(PF/PJ) e faz lancamento pra CR e SR por conta
        IF rw_crapass.inpessoa = 1 THEN --PF
           --vr_vltottar := vr_vltottar + (vr_tab_tar(vr_indice).qtdtarcr * vr_vlttcrpf) + (vr_tab_tar(vr_indice).qtdtarsr * vr_vlttsrpf);
           vr_tab_dados_tar('CRPF').vltottar := nvl(vr_tab_dados_tar('CRPF').vltottar,0) + (vr_tab_tar(vr_indice).qtdtarcr * vr_tab_dados_tar('CRPF').vlrtarif);

           IF vr_tab_dados_tar('CRPF').vltottar > 0 THEN --Lancamento Tarifa Cobranca Reg PF
             /* Gera Tarifa de titulos descontados */
             TARI0001.pc_cria_lan_auto_tarifa (pr_cdcooper => vr_tab_tar(vr_indice).cdcooper  --Codigo Cooperativa
                                              ,pr_nrdconta => vr_tab_tar(vr_indice).nrdconta  --Numero da Conta
                                              ,pr_dtmvtolt => pr_dtmvtolt          --Data Lancamento
                                              ,pr_cdhistor => vr_tab_dados_tar('CRPF').cdhistor --Codigo Historico
                                              ,pr_vllanaut => vr_tab_dados_tar('CRPF').vltottar --Valor lancamento automatico
                                              ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                              ,pr_cdagenci => 1                    --Codigo Agencia
                                              ,pr_cdbccxlt => 100                  --Codigo banco caixa
                                              ,pr_nrdolote => 8452                 --Numero do lote
                                              ,pr_tpdolote => 1                    --Tipo do lote
                                              ,pr_nrdocmto => 0                    --Numero do documento
                                              ,pr_nrdctabb => vr_tab_tar(vr_indice).nrdconta  --Numero da conta
                                              ,pr_nrdctitg => gene0002.fn_mask(vr_tab_tar(vr_indice).nrdconta,'99999999') --Numero da conta integracao
                                              ,pr_cdpesqbb => vr_cdpesqbb          --Codigo pesquisa
                                              ,pr_cdbanchq => 0                    --Codigo Banco Cheque
                                              ,pr_cdagechq => 0                    --Codigo Agencia Cheque
                                              ,pr_nrctachq => 0                    --Numero Conta Cheque
                                              ,pr_flgaviso => FALSE                --Flag aviso
                                              ,pr_tpdaviso => 0                    --Tipo aviso
                                              ,pr_cdfvlcop => vr_tab_dados_tar('CRPF').cdfvlcop --Codigo cooperativa
                                              ,pr_inproces => rw_crapdat.inproces  --Indicador processo
                                              ,pr_rowid_craplat => vr_rowid_craplat --Rowid do lancamento tarifa
                                              ,pr_tab_erro => vr_tab_erro          --Tabela retorno erro
                                              ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                              ,pr_dscritic => vr_dscritic);        --Descricao Critica
             --Se ocorreu erro
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
             END IF;
           END IF;

           vr_tab_dados_tar('SRPF').vltottar := nvl(vr_tab_dados_tar('SRPF').vltottar,0) + (vr_tab_tar(vr_indice).qtdtarsr * vr_tab_dados_tar('SRPF').vlrtarif);

           IF vr_tab_dados_tar('SRPF').vltottar > 0 THEN --Lancamento Tarifa Cobranca Sem Reg PF
             /* Gera Tarifa de titulos descontados */
             TARI0001.pc_cria_lan_auto_tarifa (pr_cdcooper => vr_tab_tar(vr_indice).cdcooper  --Codigo Cooperativa
                                              ,pr_nrdconta => vr_tab_tar(vr_indice).nrdconta  --Numero da Conta
                                              ,pr_dtmvtolt => pr_dtmvtolt          --Data Lancamento
                                              ,pr_cdhistor => vr_tab_dados_tar('SRPF').cdhistor  --Codigo Historico
                                              ,pr_vllanaut => vr_tab_dados_tar('SRPF').vltottar  --Valor lancamento automatico
                                              ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                              ,pr_cdagenci => 1                    --Codigo Agencia
                                              ,pr_cdbccxlt => 100                  --Codigo banco caixa
                                              ,pr_nrdolote => 8452                 --Numero do lote
                                              ,pr_tpdolote => 1                    --Tipo do lote
                                              ,pr_nrdocmto => 0                    --Numero do documento
                                              ,pr_nrdctabb => vr_tab_tar(vr_indice).nrdconta  --Numero da conta
                                              ,pr_nrdctitg => gene0002.fn_mask(vr_tab_tar(vr_indice).nrdconta,'99999999') --Numero da conta integracao
                                              ,pr_cdpesqbb => vr_cdpesqbb          --Codigo pesquisa
                                              ,pr_cdbanchq => 0                    --Codigo Banco Cheque
                                              ,pr_cdagechq => 0                    --Codigo Agencia Cheque
                                              ,pr_nrctachq => 0                    --Numero Conta Cheque
                                              ,pr_flgaviso => FALSE                --Flag aviso
                                              ,pr_tpdaviso => 0                    --Tipo aviso
                                              ,pr_cdfvlcop => vr_tab_dados_tar('SRPF').cdfvlcop  --Codigo cooperativa
                                              ,pr_inproces => rw_crapdat.inproces  --Indicador processo
                                              ,pr_rowid_craplat => vr_rowid_craplat --Rowid do lancamento tarifa
                                              ,pr_tab_erro => vr_tab_erro          --Tabela retorno erro
                                              ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                              ,pr_dscritic => vr_dscritic);        --Descricao Critica
             --Se ocorreu erro
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
           END IF;


        ELSE --PJ

           --vr_vltottar := vr_vltottar + (vr_tab_tar(vr_indice).qtdtarcr * vr_vlttcrpj) + (vr_tab_tar(vr_indice).qtdtarsr * vr_vlttsrpj);
           vr_tab_dados_tar('CRPJ').vltottar := nvl(vr_tab_dados_tar('CRPJ').vltottar,0) + (vr_tab_tar(vr_indice).qtdtarcr * vr_tab_dados_tar('CRPJ').vlrtarif);

           IF vr_tab_dados_tar('CRPJ').vltottar > 0 THEN --Lancamento Tarifa Cobranca Reg PJ
             /* Gera Tarifa de titulos descontados */
             TARI0001.pc_cria_lan_auto_tarifa (pr_cdcooper => vr_tab_tar(vr_indice).cdcooper  --Codigo Cooperativa
                                              ,pr_nrdconta => vr_tab_tar(vr_indice).nrdconta  --Numero da Conta
                                              ,pr_dtmvtolt => pr_dtmvtolt          --Data Lancamento
                                              ,pr_cdhistor => vr_tab_dados_tar('CRPJ').cdhistor  --Codigo Historico
                                              ,pr_vllanaut => vr_tab_dados_tar('CRPJ').vltottar  --Valor lancamento automatico
                                              ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                              ,pr_cdagenci => 1                    --Codigo Agencia
                                              ,pr_cdbccxlt => 100                  --Codigo banco caixa
                                              ,pr_nrdolote => 8452                 --Numero do lote
                                              ,pr_tpdolote => 1                    --Tipo do lote
                                              ,pr_nrdocmto => 0                    --Numero do documento
                                              ,pr_nrdctabb => vr_tab_tar(vr_indice).nrdconta  --Numero da conta
                                              ,pr_nrdctitg => gene0002.fn_mask(vr_tab_tar(vr_indice).nrdconta,'99999999') --Numero da conta integracao
                                              ,pr_cdpesqbb => vr_cdpesqbb          --Codigo pesquisa
                                              ,pr_cdbanchq => 0                    --Codigo Banco Cheque
                                              ,pr_cdagechq => 0                    --Codigo Agencia Cheque
                                              ,pr_nrctachq => 0                    --Numero Conta Cheque
                                              ,pr_flgaviso => FALSE                --Flag aviso
                                              ,pr_tpdaviso => 0                    --Tipo aviso
                                              ,pr_cdfvlcop => vr_tab_dados_tar('CRPJ').cdfvlcop --Codigo cooperativa
                                              ,pr_inproces => rw_crapdat.inproces  --Indicador processo
                                              ,pr_rowid_craplat => vr_rowid_craplat --Rowid do lancamento tarifa
                                              ,pr_tab_erro => vr_tab_erro          --Tabela retorno erro
                                              ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                              ,pr_dscritic => vr_dscritic);        --Descricao Critica
             --Se ocorreu erro
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
           END IF;

           vr_tab_dados_tar('SRPJ').vltottar := nvl(vr_tab_dados_tar('SRPJ').vltottar,0) + (vr_tab_tar(vr_indice).qtdtarsr * vr_tab_dados_tar('SRPJ').vlrtarif);

           IF vr_tab_dados_tar('SRPJ').vltottar > 0 THEN --Lancamento Tarifa Cobranca Sem Reg PJ
             /* Gera Tarifa de titulos descontados */
             TARI0001.pc_cria_lan_auto_tarifa (pr_cdcooper => vr_tab_tar(vr_indice).cdcooper  --Codigo Cooperativa
                                              ,pr_nrdconta => vr_tab_tar(vr_indice).nrdconta  --Numero da Conta
                                              ,pr_dtmvtolt => pr_dtmvtolt          --Data Lancamento
                                              ,pr_cdhistor => vr_tab_dados_tar('SRPJ').cdhistor --Codigo Historico
                                              ,pr_vllanaut => vr_tab_dados_tar('SRPJ').vltottar --Valor lancamento automatico
                                              ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                              ,pr_cdagenci => 1                    --Codigo Agencia
                                              ,pr_cdbccxlt => 100                  --Codigo banco caixa
                                              ,pr_nrdolote => 8452                 --Numero do lote
                                              ,pr_tpdolote => 1                    --Tipo do lote
                                              ,pr_nrdocmto => 0                    --Numero do documento
                                              ,pr_nrdctabb => vr_tab_tar(vr_indice).nrdconta  --Numero da conta
                                              ,pr_nrdctitg => gene0002.fn_mask(vr_tab_tar(vr_indice).nrdconta,'99999999') --Numero da conta integracao
                                              ,pr_cdpesqbb => vr_cdpesqbb          --Codigo pesquisa
                                              ,pr_cdbanchq => 0                    --Codigo Banco Cheque
                                              ,pr_cdagechq => 0                    --Codigo Agencia Cheque
                                              ,pr_nrctachq => 0                    --Numero Conta Cheque
                                              ,pr_flgaviso => FALSE                --Flag aviso
                                              ,pr_tpdaviso => 0                    --Tipo aviso
                                              ,pr_cdfvlcop => vr_tab_dados_tar('SRPJ').cdfvlcop --Codigo cooperativa
                                              ,pr_inproces => rw_crapdat.inproces  --Indicador processo
                                              ,pr_rowid_craplat => vr_rowid_craplat --Rowid do lancamento tarifa
                                              ,pr_tab_erro => vr_tab_erro          --Tabela retorno erro
                                              ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                              ,pr_dscritic => vr_dscritic);        --Descricao Critica
             --Se ocorreu erro
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
           END IF;

        END IF;

        --Proximo indice
        vr_indice := vr_tab_tar.NEXT(vr_indice);

      END LOOP;
      /*#########FIM LANCAR TARIFA TITULO#########################*/

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        ROLLBACK;
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => pr_dscritic
                             ,pr_tab_erro => vr_tab_erro);

        pr_tab_erro := vr_tab_erro;

        ROLLBACK;

      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina DSCT0001.pc_efetua_baixa_titulo. '||sqlerrm;

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => pr_dscritic
                             ,pr_tab_erro => vr_tab_erro);

        ROLLBACK;

    END;
  END pc_efetua_baixa_tit_car;

  PROCEDURE pc_efetua_baixa_tit_car_job IS
  BEGIN
    DECLARE

      CURSOR cr_crapcop IS
        SELECT cop.cdcooper
          FROM crapcop cop
         WHERE cop.flgativo = 1;

      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      vr_dtmvtolt DATE;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_dserro   VARCHAR2(4000);
      vr_tab_erro  GENE0001.typ_tab_erro;

      vr_exc_erro  EXCEPTION;

      vr_cdprogra    VARCHAR2(40) := 'PC_EFETUA_BAIXA_TIT_CAR_JOB';
      vr_nomdojob    VARCHAR2(40) := 'JBDSCT_EFETUA_BAIXA_TIT_CAR';
      vr_flgerlog    BOOLEAN := FALSE;
      vr_dthoje      DATE := TRUNC(SYSDATE);

      --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
      PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                                      pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
      BEGIN
        --> Controlar geração de log de execução dos jobs
        BTCH0001.pc_log_exec_job( pr_cdcooper  => 3    --> Cooperativa
                                 ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                                 ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                                 ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                                 ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                                 ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
      END pc_controla_log_batch;

    BEGIN

      -- Log de inicio de execucao
      pc_controla_log_batch(pr_dstiplog => 'I');

      -- SD#497991
      -- validação copiada de TARI0001
      -- Verificar se a data atual é uma data util, se retornar uma data diferente
      -- indica que não é um dia util, então deve sair do programa sem executar ou reprogramar
      IF gene0005.fn_valida_dia_util(pr_cdcooper => 3
                                    ,pr_dtmvtolt => vr_dthoje) = vr_dthoje THEN -- SD#497991

        gene0004.pc_executa_job( pr_cdcooper => 3   --> Codigo da cooperativa
                                ,pr_fldiautl => 1   --> Flag se deve validar dia util
                                ,pr_flproces => 1   --> Flag se deve validar se esta no processo
                                ,pr_flrepjob => 1   --> Flag para reprogramar o job
                                ,pr_flgerlog => 1   --> indicador se deve gerar log
                                ,pr_nmprogra => 'DSCT0001.pc_efetua_baixa_tit_car' --> Nome do programa que esta sendo executado no job
                                ,pr_dscritic => vr_dserro);

        -- se nao retornou critica chama rotina
        IF trim(vr_dserro) IS NULL THEN

          FOR rw_crapcop IN cr_crapcop LOOP

            OPEN btch0001.cr_crapdat(rw_crapcop.cdcooper);
            FETCH btch0001.cr_crapdat  INTO rw_crapdat;
            CLOSE btch0001.cr_crapdat;

            --Verifica o dia util da cooperativa e caso nao for pula a coop
            vr_dtmvtolt := gene0005.fn_valida_dia_util(pr_cdcooper  => rw_crapcop.cdcooper
                                                      ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                                      ,pr_tipo      => 'A');

            IF vr_dtmvtolt <> rw_crapdat.dtmvtolt THEN
              CONTINUE;
            END IF;

            DSCT0001.pc_efetua_baixa_tit_car(pr_cdcooper => rw_crapcop.cdcooper,
                                             pr_cdagenci => 1,
                                             pr_nrdcaixa => 100,
                                             pr_idorigem => 1,
                                             pr_cdoperad => 1,
                                             pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                             pr_dtmvtoan => rw_crapdat.dtmvtoan,
                                             pr_cdcritic => vr_cdcritic,
                                             pr_dscritic => vr_dscritic,
                                             pr_tab_erro => vr_tab_erro);

            IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL OR vr_tab_erro.COUNT > 0 THEN

              IF vr_tab_erro.COUNT > 0 THEN
                 vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                 vr_dscritic := 'Coop: ' || rw_crapcop.cdcooper ||
                                ' - ' || vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              END IF;

              RAISE vr_exc_erro;

            END IF;

          END LOOP;

        ELSE
          vr_cdcritic := 0;
          vr_dscritic := vr_dserro;

          RAISE vr_exc_erro;
        END IF;

      END IF; -- SD#497991

      -- Log de fim de execucao
      pc_controla_log_batch(pr_dstiplog => 'F');

    EXCEPTION
      WHEN vr_exc_erro THEN

        GENE0001.pc_gera_erro(pr_cdcooper => 3
                             ,pr_cdagenci => 1
                             ,pr_nrdcaixa => 100
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);

        vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

        -- Log de erro de execucao
        pc_controla_log_batch(pr_dstiplog => 'E',
                              pr_dscritic => vr_dscritic);

        ROLLBACK;

      WHEN OTHERS THEN
        -- Erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro na rotina DSCT0001.pc_efetua_baixa_titulo. '||sqlerrm;

        GENE0001.pc_gera_erro(pr_cdcooper => 3
                             ,pr_cdagenci => 1
                             ,pr_nrdcaixa => 100
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);

        vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

        -- Log de erro de execucao
        pc_controla_log_batch(pr_dstiplog => 'E',
                              pr_dscritic => vr_dscritic);

        ROLLBACK;

    END;
  END pc_efetua_baixa_tit_car_job;

  /* Procedure para efetuar a baixa do titulo por pagamento ou vencimento */
  PROCEDURE pc_efetua_baixa_titulo (pr_cdcooper    IN INTEGER  --Codigo Cooperativa
                                   ,pr_cdagenci    IN INTEGER  --Codigo Agencia
                                   ,pr_nrdcaixa    IN INTEGER  --Numero Caixa
                                   ,pr_cdoperad    IN VARCHAR2 --Codigo operador
                                   ,pr_dtmvtolt    IN DATE     --Data Movimento
                                   ,pr_idorigem    IN INTEGER  --Identificador Origem pagamento
                                   ,pr_nrdconta    IN INTEGER  --Numero da conta
                                   ,pr_indbaixa    IN INTEGER  --Indicador Baixa /* 1-Pagamento 2- Vencimento */
                                   ,pr_tab_titulos IN PAGA0001.typ_tab_titulos --Titulos a serem baixados
                                  -- ,pr_dtintegr    IN DATE     --Data da integração do pagamento
                                   ,pr_cdcritic    OUT INTEGER     --Codigo Critica
                                   ,pr_dscritic    OUT VARCHAR2     --Descricao Critica
                                   ,pr_tab_erro    OUT GENE0001.typ_tab_erro) IS --Tabela erros
    -- .........................................................................
    --
    --  Programa : pc_efetua_baixa_titulo           Antigo: b1wgen0030.p/efetua_baixa_titulo
    --  Sistema  : Cred
    --  Sigla    : DSCT0001
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Julho/2013.                   Ultima atualizacao: 07/10/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para efetuar a baixa do titulo por pagamento ou vencimento
    --
    --  Alteracoes: 25/03/2015 - Remover o savepoint vr_save_baixa (Douglas - Chamado 267787)
    --
    --              07/10/2016 - Quando pagamento do título é no mesmo dia da liberação do borderô
    --                           de desconto o valor do juro deve ser devolvido.
    --                           Incluído ELSIF para quando vr_qtdprazo=0  (SD#489111-AJFink)
    --
    -- .........................................................................

  BEGIN
    DECLARE
      /* Cursores Locais */

      --Selecionar informacoes dos titulos do bordero
      CURSOR cr_craptdb (pr_cdcooper IN craptdb.cdcooper%type
                        ,pr_cdbandoc IN craptdb.cdbandoc%type
                        ,pr_nrdctabb IN craptdb.nrdctabb%type
                        ,pr_nrcnvcob IN craptdb.nrcnvcob%type
                        ,pr_nrdconta IN craptdb.nrdconta%type
                        ,pr_nrdocmto IN craptdb.nrdocmto%type
                        ,pr_insittit IN craptdb.insittit%type) IS
        SELECT craptdb.dtvencto
              ,craptdb.vltitulo
              ,craptdb.nrdconta
              ,craptdb.nrdocmto
              ,craptdb.cdcooper
              ,craptdb.insittit
              ,craptdb.dtdpagto
              ,craptdb.nrborder
              ,craptdb.dtlibbdt
              ,craptdb.cdbandoc
              ,craptdb.nrdctabb
              ,craptdb.nrcnvcob
              ,craptdb.rowid
              ,craptdb.vlliquid
              ,COUNT(*) OVER (PARTITION BY craptdb.cdcooper) qtdreg
        FROM craptdb
        WHERE craptdb.cdcooper = pr_cdcooper
        AND   craptdb.cdbandoc = pr_cdbandoc
        AND   craptdb.nrdctabb = pr_nrdctabb
        AND   craptdb.nrcnvcob = pr_nrcnvcob
        AND   craptdb.nrdconta = pr_nrdconta
        AND   craptdb.nrdocmto = pr_nrdocmto
        AND   craptdb.insittit = pr_insittit;
      rw_craptdb cr_craptdb%ROWTYPE;

      --Selecionar informacoes Cobranca
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
              AND   crapcob.flgregis = pr_flgregis
         ORDER BY crapcob.progress_recid ASC;
      rw_crapcob cr_crapcob%ROWTYPE;

      --Selecionar Bordero de titulos
      CURSOR cr_crapbdt (pr_cdcooper IN crapbdt.cdcooper%type
                        ,pr_nrborder IN crapbdt.nrborder%type) IS
        SELECT crapbdt.txmensal
              ,crapbdt.vltaxiof
        FROM crapbdt
        WHERE crapbdt.cdcooper = pr_cdcooper
        AND   crapbdt.nrborder = pr_nrborder;
      rw_crapbdt cr_crapbdt%ROWTYPE;

      --Selecionar lancamento juros desconto titulo
      CURSOR cr_crapljt (pr_cdcooper IN crapljt.cdcooper%type
                        ,pr_nrdconta IN crapljt.nrdconta%type
                        ,pr_nrborder IN crapljt.nrborder%type
                        ,pr_dtrefere IN crapljt.dtrefere%type
                        ,pr_cdbandoc IN crapljt.cdbandoc%type
                        ,pr_nrdctabb IN crapljt.nrdctabb%type
                        ,pr_nrcnvcob IN crapljt.nrcnvcob%type
                        ,pr_nrdocmto IN crapljt.nrdocmto%TYPE
                        ,pr_tipo     IN INTEGER) IS
        SELECT crapljt.ROWID
              ,crapljt.vldjuros
              ,crapljt.vlrestit
        FROM crapljt
        WHERE crapljt.cdcooper = pr_cdcooper
        AND   crapljt.nrdconta = pr_nrdconta
        AND   crapljt.nrborder = pr_nrborder
        AND   ((pr_tipo = 1 AND crapljt.dtrefere = pr_dtrefere) OR
               (pr_tipo = 2 AND crapljt.dtrefere > pr_dtrefere))
        AND   crapljt.cdbandoc = pr_cdbandoc
        AND   crapljt.nrdctabb = pr_nrdctabb
        AND   crapljt.nrcnvcob = pr_nrcnvcob
        AND   crapljt.nrdocmto = pr_nrdocmto;
      rw_crapljt cr_crapljt%ROWTYPE;

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

      -- Cursor para informações da cobrança do título
      CURSOR cr_crapcob_iof (pr_cdcooper IN craptdb.cdcooper%type
                            ,pr_cdbandoc IN craptdb.cdbandoc%type
                            ,pr_nrdctabb IN craptdb.nrdctabb%type
                            ,pr_nrcnvcob IN craptdb.nrcnvcob%type
                            ,pr_nrdconta IN craptdb.nrdconta%type
                            ,pr_nrdocmto IN craptdb.nrdocmto%type) IS
        SELECT crapcob.dtdpagto,
               crapcob.dtdbaixa
        FROM crapcob
        WHERE crapcob.cdcooper = pr_cdcooper
               AND crapcob.nrdconta = pr_nrdconta
               AND crapcob.nrdocmto = pr_nrdocmto
               AND crapcob.cdbandoc = pr_cdbandoc
               AND crapcob.nrdctabb = pr_nrdctabb
               AND crapcob.nrcnvcob = pr_nrcnvcob;
        rw_crapcob_iof cr_crapcob_iof%ROWTYPE;

      --Variaveis Locais
      vr_vllanmto     NUMBER;
      vr_vldjuros     NUMBER;
      vr_qtdprazo     INTEGER;
      vr_txdiaria     NUMBER;
      vr_contador     INTEGER;
      vr_contado1     INTEGER;
      vr_dtperiod     DATE;
      vr_dtrefjur     DATE;
      vr_vltotjur     NUMBER;
      vr_vltitulo     NUMBER;
      vr_dtultdat     DATE;
      vr_dtmvtolt     DATE;
      vr_flgachou     BOOLEAN;
      vr_flgdsair     BOOLEAN;
      vr_flg_feriafds BOOLEAN;
      vr_dtprvenc     DATE;
      vr_dtferiado    DATE;
      vr_tottitul_cr  INTEGER := 0; /* Qtd. De Tit. Registrados */
      vr_tottitul_sr  INTEGER := 0; /* Qtd. De Tit. S/ Registro */
      vr_vlttitsr     NUMBER;
      vr_vlttitcr     NUMBER;
      vr_inpessoa     INTEGER;
      vr_dsmensag     VARCHAR2(100);
      vr_cdpesqbb     VARCHAR2(1000);
      vr_cdbattar     VARCHAR2(1000);
      vr_cdhisest     INTEGER;
      vr_dtdivulg     DATE;
      vr_dtvigenc     DATE;
      vr_cdhistor     INTEGER;
      vr_cdfvlcop     INTEGER;
      vr_index        VARCHAR2(20);
      vr_index_titulo VARCHAR2(20);
      vr_incrawljt    PLS_INTEGER;
   	  vr_natjurid     crapjur.natjurid%TYPE;
      vr_tpregtrb     crapjur.tpregtrb%TYPE;
      vr_vliofpri     NUMBER(25,2);
      vr_vliofadi     NUMBER(25,2);
      vr_vliofcpl     NUMBER(25,2);
      vr_qtdiaiof     PLS_INTEGER;
      vr_flgimune     PLS_INTEGER;
      vr_dtmvtolt_lcm craplcm.dtmvtolt%TYPE;
      vr_cdagenci_lcm craplcm.cdagenci%TYPE;
      vr_cdbccxlt_lcm craplcm.cdbccxlt%TYPE;
      vr_nrdolote_lcm craplcm.nrdolote%TYPE;
      vr_nrseqdig_lcm craplcm.nrseqdig%TYPE;
      vr_vltaxa_iof_principal NUMBER := 0;

      --Variaveis de erro
      vr_des_erro     VARCHAR2(4000);
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Tipo de registro para datas
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      --Registro de memoria do tipo lancamento
      rw_craplcm craplcm%ROWTYPE;
      --Tabela de memoria de erros
      vr_tab_erro GENE0001.typ_tab_erro;
      --Rowid para a craplat
      vr_rowid_craplat ROWID;
      --Tabela de memoria para contas
      TYPE typ_tab_conta IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
      vr_tab_conta typ_tab_conta;
      --Variaveis de Excecao
      vr_exc_erro    EXCEPTION;
      vr_exc_proximo EXCEPTION;
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      vr_dscritic:= NULL;
      vr_cdcritic:= 0;

      --Limpar tabela contas
      vr_tab_conta.DELETE;
      --Limpar tabela erros
      pr_tab_erro.DELETE;

      --Selecionar a data do movimento
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver¿ raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      /* Leitura dos titulos para serem baixados */
      vr_index_titulo:= pr_tab_titulos.FIRST;
      WHILE vr_index_titulo IS NOT NULL LOOP
        BEGIN
          --Sair
          vr_flgdsair:= FALSE;
          --Zerar valor total juros
          vr_vltotjur:= 0;
          --Selecionar titulos do bordero
          OPEN cr_craptdb (pr_cdcooper => pr_cdcooper
                          ,pr_cdbandoc => pr_tab_titulos(vr_index_titulo).cdbandoc
                          ,pr_nrdctabb => pr_tab_titulos(vr_index_titulo).nrdctabb
                          ,pr_nrcnvcob => pr_tab_titulos(vr_index_titulo).nrcnvcob
                          ,pr_nrdconta => pr_tab_titulos(vr_index_titulo).nrdconta
                          ,pr_nrdocmto => pr_tab_titulos(vr_index_titulo).nrdocmto
                          ,pr_insittit => 4);
          --Posicionar no proximo registro
          FETCH cr_craptdb INTO rw_craptdb;
          --Se Nao encontrou ou encontrou e tem mais de 1
          IF cr_craptdb%NOTFOUND OR
             (cr_craptdb%FOUND AND rw_craptdb.qtdreg > 1) THEN
            --Ignorar Titulo
            vr_flgdsair:= TRUE;
          END IF;
          --Fechar Cursor
          CLOSE cr_craptdb;

          --Se deve sair, proximo registro
          IF vr_flgdsair THEN
            --Levantar Excecao Proximo
            RAISE vr_exc_proximo;
          END IF;

          /*
          Se caso o titulo vier pela COMPE o crps517 soh ira rodar a noite
          para baixar os titulos em descto, e nesse periodo(dia) o
          titulo ser pago, nao deve ser considerado que ele esteja em
          descto de titulos
          */

          --Verificar se eh feriado
          vr_dtferiado:= GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                    ,pr_dtmvtolt => rw_craptdb.dtvencto
                                                    ,pr_tipo     => 'P');

          --Se for diferente eh feriado ou final semana
          vr_flg_feriafds:= Trunc(vr_dtferiado) != Trunc(rw_craptdb.dtvencto);

          --Se for para baixar e o vencimento menor movimento e nao for feriado ou fim semana
          IF pr_indbaixa = 1 AND rw_craptdb.dtvencto < pr_dtmvtolt AND
             NOT vr_flg_feriafds AND pr_idorigem <> 1 /* Ayllos */   THEN
            --Proximo registro
            RAISE vr_exc_proximo;
          END IF;

          /* Pega o proximo dia util apos o vencimento */
          IF pr_idorigem <> 1 THEN
            /* 1o Dia util apos o vencto */

            --Data proximo vencimento recebe vencimento + 1dia
            vr_dtprvenc:= rw_craptdb.dtvencto + 1;
            --Encontrar o proximo dia util apartir do proximo vencimento
            vr_dtprvenc:= GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                     ,pr_dtmvtolt => vr_dtprvenc
                                                     ,pr_tipo     => 'P');

            /*
            Fazer a baixa de desconto de titulo somente se for
            no 1o. dia util apos o vencimento
            caso contrario da NEXT.
            */
            IF vr_flg_feriafds AND    /* venceu em feriado/fds */
               rw_craptdb.dtvencto <= pr_dtmvtolt AND
               Trunc(pr_dtmvtolt) <> Trunc(vr_dtprvenc) THEN
              --Proximo registro
              RAISE vr_exc_proximo;
            END IF;
          END IF;

          /* Total de titulos para gerar a Tarifa */
          IF pr_tab_titulos(vr_index_titulo).flgregis THEN
            vr_tottitul_cr:= Nvl(vr_tottitul_cr,0) + 1;
          ELSE
            vr_tottitul_sr:= Nvl(vr_tottitul_sr,0) + 1;
          END IF;

          --Selecionar Bordero de titulos
          OPEN cr_crapbdt (pr_cdcooper => rw_craptdb.cdcooper
                          ,pr_nrborder => rw_craptdb.nrborder);
          --Posicionar no proximo registro
          FETCH cr_crapbdt INTO rw_crapbdt;
          --Se nao encontrar
          IF cr_crapbdt%NOTFOUND THEN
            --Fechar Cursor
            CLOSE cr_crapbdt;
            --Mensagem de erro
            vr_dscritic:= 'Bordero nao encontrado.';
            vr_cdcritic:= 0;
            --Gerar erro
            GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => 1 /** Sequencia **/
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => vr_tab_erro);
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          --Fechar Cursor
          CLOSE cr_crapbdt;

          /*
          Valor pago eh menor que o titulo (Ex: Desconto de 10%)
          a diferenca eh cobrado o ajuste do titulo
          */
          IF pr_indbaixa = 1 THEN
            /* se pagamento a menor */
            IF rw_craptdb.vltitulo > pr_tab_titulos(vr_index_titulo).vltitulo THEN
              --Montar Historico
              IF NOT pr_tab_titulos(vr_index_titulo).flgregis THEN
                vr_cdhistor:= 590;
              ELSE
                vr_cdhistor:= 1101;
              END IF;

              /* Leitura do lote */
              OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                              ,pr_dtmvtolt => pr_dtmvtolt
                              ,pr_cdagenci => 1
                              ,pr_cdbccxlt => 100
                              ,pr_nrdolote => 10300);
              --Posicionar no proximo registro
              FETCH cr_craplot INTO rw_craplot;
              --Se encontrou registro
              IF cr_craplot%NOTFOUND THEN
                --Fechar Cursor                 --
                CLOSE cr_craplot;
                --Criar lote
                BEGIN
                  INSERT INTO craplot
                    (craplot.cdcooper
                    ,craplot.dtmvtolt
                    ,craplot.cdagenci
                    ,craplot.cdbccxlt
                    ,craplot.nrdolote
                    ,craplot.cdoperad
                    ,craplot.tplotmov
                    ,craplot.cdhistor)
                  VALUES
                    (pr_cdcooper
                    ,pr_dtmvtolt
                    ,1
                    ,100
                    ,10300
                    ,pr_cdoperad
                    ,1
                    ,vr_cdhistor)
                  RETURNING ROWID
                      ,craplot.dtmvtolt
                      ,craplot.cdagenci
                      ,craplot.cdbccxlt
                      ,craplot.nrdolote
                      ,craplot.nrseqdig
                  INTO rw_craplot.ROWID
                      ,rw_craplot.dtmvtolt
                      ,rw_craplot.cdagenci
                      ,rw_craplot.cdbccxlt
                      ,rw_craplot.nrdolote
                      ,rw_craplot.nrseqdig;
                EXCEPTION
                  WHEN Dup_Val_On_Index THEN
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Lote ja cadastrado.';
                    RAISE vr_exc_erro;
                  WHEN OTHERS THEN
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Erro ao inserir na tabela de lotes. '||sqlerrm;
                    RAISE vr_exc_erro;
                END;
              END IF;
              --Fechar Cursor
              IF cr_craplot%ISOPEN THEN
                CLOSE cr_craplot;
              END IF;
              --Gravar lancamento
              BEGIN
                INSERT INTO craplcm
                  (craplcm.dtmvtolt
                  ,craplcm.cdagenci
                  ,craplcm.cdbccxlt
                  ,craplcm.nrdolote
                  ,craplcm.nrdconta
                  ,craplcm.nrdocmto
                  ,craplcm.vllanmto
                  ,craplcm.cdhistor
                  ,craplcm.nrseqdig
                  ,craplcm.nrdctabb
                  ,craplcm.nrautdoc
                  ,craplcm.cdcooper
                  ,craplcm.cdpesqbb)
                VALUES
                  (rw_craplot.dtmvtolt
                  ,rw_craplot.cdagenci
                  ,rw_craplot.cdbccxlt
                  ,rw_craplot.nrdolote
                  ,rw_craptdb.nrdconta
                  ,Nvl(rw_craplot.nrseqdig,0) + 1
                  ,rw_craptdb.vltitulo - pr_tab_titulos(vr_index_titulo).vltitulo
                  ,vr_cdhistor
                  ,Nvl(rw_craplot.nrseqdig,0) + 1
                  ,rw_craptdb.nrdconta
                  ,0
                  ,pr_cdcooper
                  ,rw_craptdb.nrdocmto)
                RETURNING craplcm.nrseqdig
                         ,craplcm.vllanmto
                INTO rw_craplcm.nrseqdig
                    ,rw_craplcm.vllanmto;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Erro ao inserir na tabela de lancamentos. '||sqlerrm;
                  RAISE vr_exc_erro;
              END;
              /* Atualiza o lote na craplot */
              BEGIN
                UPDATE craplot SET craplot.qtinfoln = Nvl(craplot.qtinfoln,0) + 1
                                  ,craplot.qtcompln = Nvl(craplot.qtcompln,0) + 1
                                  ,craplot.nrseqdig = Nvl(rw_craplcm.nrseqdig,0)
                                  ,craplot.vlinfocr = Nvl(craplot.vlinfocr,0) + rw_craplcm.vllanmto
                                  ,craplot.vlcompcr = Nvl(craplot.vlcompcr,0) + rw_craplcm.vllanmto
                WHERE craplot.ROWID = rw_craplot.ROWID
                RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig;
              EXCEPTION
                WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar tabela craplot. '||SQLERRM;
                --Levantar Excecao
                RAISE vr_exc_erro;
              END;
              --Acumular Valor Lancamento
              vr_vllanmto:= nvl(vr_vllanmto,0) + rw_craplcm.vllanmto;

            ELSIF rw_craptdb.vltitulo < pr_tab_titulos(vr_index_titulo).vltitulo THEN

              /* se pagamento a maior */
              --Montar Historico
              IF NOT pr_tab_titulos(vr_index_titulo).flgregis THEN
                vr_cdhistor:= 1100;
              ELSE
                vr_cdhistor:= 1102;
              END IF;

              /* Leitura do lote */
              OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                              ,pr_dtmvtolt => pr_dtmvtolt
                              ,pr_cdagenci => 1
                              ,pr_cdbccxlt => 100
                              ,pr_nrdolote => 10300);
              --Posicionar no proximo registro
              FETCH cr_craplot INTO rw_craplot;
              --Se encontrou registro
              IF cr_craplot%NOTFOUND THEN
                --Fechar Cursor
                CLOSE cr_craplot;
                --Criar lote
                BEGIN
                  INSERT INTO craplot
                    (craplot.cdcooper
                    ,craplot.dtmvtolt
                    ,craplot.cdagenci
                    ,craplot.cdbccxlt
                    ,craplot.nrdolote
                    ,craplot.cdoperad
                    ,craplot.tplotmov
                    ,craplot.cdhistor)
                  VALUES
                    (pr_cdcooper
                    ,pr_dtmvtolt
                    ,1
                    ,100
                    ,10300
                    ,pr_cdoperad
                    ,1
                    ,vr_cdhistor)
                  RETURNING ROWID
                      ,craplot.dtmvtolt
                      ,craplot.cdagenci
                      ,craplot.cdbccxlt
                      ,craplot.nrdolote
                      ,craplot.nrseqdig
                  INTO rw_craplot.ROWID
                      ,rw_craplot.dtmvtolt
                      ,rw_craplot.cdagenci
                      ,rw_craplot.cdbccxlt
                      ,rw_craplot.nrdolote
                      ,rw_craplot.nrseqdig;
                EXCEPTION
                  WHEN Dup_Val_On_Index THEN
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Lote ja cadastrado.';
                    RAISE vr_exc_erro;
                  WHEN OTHERS THEN
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Erro ao inserir na tabela de lotes. '||sqlerrm;
                    RAISE vr_exc_erro;
                END;
              END IF;
              --Fechar Cursor
              IF cr_craplot%ISOPEN THEN
                CLOSE cr_craplot;
              END IF;
              --Gravar lancamento
              BEGIN
                INSERT INTO craplcm
                  (craplcm.dtmvtolt
                  ,craplcm.cdagenci
                  ,craplcm.cdbccxlt
                  ,craplcm.nrdolote
                  ,craplcm.nrdconta
                  ,craplcm.nrdocmto
                  ,craplcm.vllanmto
                  ,craplcm.cdhistor
                  ,craplcm.nrseqdig
                  ,craplcm.nrdctabb
                  ,craplcm.nrautdoc
                  ,craplcm.cdcooper
                  ,craplcm.cdpesqbb)
                VALUES
                  (rw_craplot.dtmvtolt
                  ,rw_craplot.cdagenci
                  ,rw_craplot.cdbccxlt
                  ,rw_craplot.nrdolote
                  ,rw_craptdb.nrdconta
                  ,Nvl(rw_craplot.nrseqdig,0) + 1
                  ,pr_tab_titulos(vr_index_titulo).vltitulo - rw_craptdb.vltitulo
                  ,vr_cdhistor
                  ,Nvl(rw_craplot.nrseqdig,0) + 1
                  ,rw_craptdb.nrdconta
                  ,0
                  ,pr_cdcooper
                  ,rw_craptdb.nrdocmto)
                RETURNING craplcm.nrseqdig
                         ,craplcm.vllanmto
                INTO rw_craplcm.nrseqdig
                    ,rw_craplcm.vllanmto;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Erro ao inserir na tabela de lancamentos. '||sqlerrm;
                  RAISE vr_exc_erro;
              END;
              /* Atualiza o lote na craplot */
              BEGIN
                UPDATE craplot SET craplot.qtinfoln = Nvl(craplot.qtinfoln,0) + 1
                                  ,craplot.qtcompln = Nvl(craplot.qtcompln,0) + 1
                                  ,craplot.nrseqdig = Nvl(rw_craplcm.nrseqdig,0)
                                  ,craplot.vlinfocr = Nvl(craplot.vlinfocr,0) + rw_craplcm.vllanmto
                                  ,craplot.vlcompcr = Nvl(craplot.vlcompcr,0) + rw_craplcm.vllanmto
                WHERE craplot.ROWID = rw_craplot.ROWID
                RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig;
              EXCEPTION
                WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar tabela craplot. '||SQLERRM;
                --Levantar Excecao
                RAISE vr_exc_erro;
              END;
              --Acumular Valor Lancamento
              vr_vllanmto:= nvl(vr_vllanmto,0) + rw_craplcm.vllanmto;
            END IF;
            /* Se for pago via compe (crps375), o sistema lanca com
               dtmvtopr na conta do associado, porem o desconto eh
               liquidado no dia do vencimento.
               Se for pago via caixa on-line ou internet, a liquidacao
               sera no dia informado na chamada desta procedure */

            --Determinar data movimento
            IF pr_idorigem = 1 THEN
              vr_dtmvtolt:= rw_crapdat.dtmvtolt;
            ELSE
              vr_dtmvtolt:= pr_dtmvtolt;
            END IF;

            ----------------------------------------------------------------------------------------------------
            -- Condicao para verificar se o titulo foi pago vencido
            ----------------------------------------------------------------------------------------------------
            IF NOT(rw_craptdb.dtvencto > rw_crapdat.dtmvtoan) AND rw_craptdb.dtvencto < vr_dtmvtolt THEN
              --Verifica se a conta existe
              OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => rw_craptdb.nrdconta);
              FETCH cr_crapass INTO rw_crapass;
              IF cr_crapass%NOTFOUND THEN
                CLOSE cr_crapass;
                vr_cdcritic := 9; --Associado n cadastrado
                vr_dscritic := NULL;
                RAISE vr_exc_erro;
              END IF;
              CLOSE cr_crapass;

              vr_natjurid := 0;
              vr_tpregtrb := 0;
              -- Condicao para verificar se eh pessoa juridica
              IF rw_crapass.inpessoa >= 2 THEN
                --Verifica se a conta existe
                OPEN cr_crapjur(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => rw_craptdb.nrdconta);
                FETCH cr_crapjur INTO rw_crapjur;
                IF cr_crapjur%FOUND THEN
                  CLOSE cr_crapjur;
                  vr_natjurid := rw_crapjur.natjurid;
                  vr_tpregtrb := rw_crapjur.tpregtrb;
                ELSE
                  CLOSE cr_crapjur;
                END IF;
              END IF;  --  IF rw_crapass.inpessoa >= 2 THEN

              ------------------------------------------------------------------------------------------
              -- Inicio Efetuar o Lancamento de IOF
              ------------------------------------------------------------------------------------------
              vr_vltotal_liquido := 0;
              OPEN cr_craptdb_total(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => rw_craptdb.nrdconta
                                   ,pr_nrborder => rw_craptdb.nrborder);
              FETCH cr_craptdb_total
                INTO vr_vltotal_liquido;
              CLOSE cr_craptdb_total;

              -- Quantidade de Dias em atraso
              OPEN cr_crapcob_iof (pr_cdcooper => pr_cdcooper
                                  ,pr_cdbandoc => pr_tab_titulos(vr_index_titulo).cdbandoc
                                  ,pr_nrdctabb => pr_tab_titulos(vr_index_titulo).nrdctabb
                                  ,pr_nrcnvcob => pr_tab_titulos(vr_index_titulo).nrcnvcob
                                  ,pr_nrdconta => pr_tab_titulos(vr_index_titulo).nrdconta
                                  ,pr_nrdocmto => pr_tab_titulos(vr_index_titulo).nrdocmto);
              FETCH cr_crapcob_iof
                INTO rw_crapcob_iof;
              CLOSE cr_crapcob_iof;

              /*vr_qtdiaiof := vr_dtmvtolt - rw_craptdb.dtvencto;*/
              -- Para cálculo dos dias de atraso, usar a data de pagamento do boleto x data de vencimento
              vr_qtdiaiof := CASE WHEN rw_crapcob_iof.dtdpagto IS NOT NULL THEN rw_crapcob_iof.dtdpagto ELSE /*pr_dtintegr*/rw_crapcob_iof.dtdpagto END - rw_craptdb.dtvencto;
              /*
              TIOF0001.pc_calcula_valor_iof(pr_tpproduto  => 2 --> Desconto de Titulo
                                           ,pr_tpoperacao => 2 --> Pagamento Em Atraso
                                           ,pr_cdcooper   => pr_cdcooper
                                           ,pr_nrdconta   => rw_craptdb.nrdconta
                                           ,pr_inpessoa   => rw_crapass.inpessoa
                                           ,pr_natjurid   => vr_natjurid
                                           ,pr_tpregtrb   => vr_tpregtrb
                                           ,pr_dtmvtolt   => vr_dtmvtolt
                                           ,pr_qtdiaiof   => vr_qtdiaiof
                                           ,pr_vloperacao => NVL(rw_craptdb.vlliquid,0)
                                           ,pr_vltotalope => vr_vltotal_liquido
                                           ,pr_vltaxa_iof_atraso => rw_crapbdt.vltaxiof
                                           ,pr_vliofpri   => vr_vliofpri
                                           ,pr_vliofadi   => vr_vliofadi
                                           ,pr_vliofcpl   => vr_vliofcpl
                                           ,pr_vltaxa_iof_principal => vr_vltaxa_iof_principal
                                           ,pr_dscritic   => vr_dscritic
                                           ,pr_flgimune   => vr_flgimune);

              -- Condicao para verificar se houve critica
              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;
              */

              -- Vamos verificar se o valo do IOF complementar é maior que 0
              IF NVL(vr_vliofcpl,0) > 0 AND vr_flgimune <= 0 THEN
                /* Leitura do lote */
                OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                                ,pr_dtmvtolt => vr_dtmvtolt
                                ,pr_cdagenci => 1
                                ,pr_cdbccxlt => 100
                                ,pr_nrdolote => 10300);
                --Posicionar no proximo registro
                FETCH cr_craplot INTO rw_craplot;
                --Se encontrou registro
                IF cr_craplot%NOTFOUND THEN
                  --Fechar Cursor                 --
                  CLOSE cr_craplot;
                  --Criar lote
                  BEGIN
                    INSERT INTO craplot
                      (craplot.cdcooper
                      ,craplot.dtmvtolt
                      ,craplot.cdagenci
                      ,craplot.cdbccxlt
                      ,craplot.nrdolote
                      ,craplot.cdoperad
                      ,craplot.tplotmov
                      ,craplot.cdhistor)
                    VALUES
                      (pr_cdcooper
                      ,pr_dtmvtolt
                      ,1
                      ,100
                      ,10300
                      ,pr_cdoperad
                      ,1
                      ,2321)
                    RETURNING ROWID
                        ,craplot.dtmvtolt
                        ,craplot.cdagenci
                        ,craplot.cdbccxlt
                        ,craplot.nrdolote
                        ,craplot.nrseqdig
                    INTO rw_craplot.ROWID
                        ,rw_craplot.dtmvtolt
                        ,rw_craplot.cdagenci
                        ,rw_craplot.cdbccxlt
                        ,rw_craplot.nrdolote
                        ,rw_craplot.nrseqdig;
                  EXCEPTION
                    WHEN Dup_Val_On_Index THEN
                      vr_cdcritic:= 0;
                      vr_dscritic:= 'Lote ja cadastrado.';
                      RAISE vr_exc_erro;
                    WHEN OTHERS THEN
                      vr_cdcritic:= 0;
                      vr_dscritic:= 'Erro ao inserir na tabela de lotes. '||sqlerrm;
                      RAISE vr_exc_erro;
                  END;
                END IF;
                --Fechar Cursor
                IF cr_craplot%ISOPEN THEN
                  CLOSE cr_craplot;
                END IF;

                -- Grava na tabela de lancamentos
                BEGIN
                  INSERT INTO craplcm
                      (craplcm.dtmvtolt
                      ,craplcm.cdagenci
                      ,craplcm.cdbccxlt
                      ,craplcm.nrdolote
                      ,craplcm.nrdconta
                      ,craplcm.nrdocmto
                      ,craplcm.vllanmto
                      ,craplcm.cdhistor
                      ,craplcm.nrseqdig
                      ,craplcm.nrdctabb
                      ,craplcm.nrautdoc
                      ,craplcm.cdcooper
                      ,craplcm.cdpesqbb)
                  VALUES
                      (rw_craplot.dtmvtolt
                      ,rw_craplot.cdagenci
                      ,rw_craplot.cdbccxlt
                      ,rw_craplot.nrdolote
                      ,rw_craptdb.nrdconta
                      ,NVL(rw_craplot.nrseqdig,0) + 1
                      ,vr_vliofcpl
                      ,2321
                      ,NVL(rw_craplot.nrseqdig,0) + 1
                      ,rw_craptdb.nrdconta
                      ,0
                      ,pr_cdcooper
                      ,rw_craptdb.nrdocmto)
                  RETURNING craplcm.dtmvtolt
                           ,craplcm.cdagenci
                           ,craplcm.cdbccxlt
                           ,craplcm.nrdolote
                           ,craplcm.nrseqdig
                           ,craplcm.vllanmto
                       INTO vr_dtmvtolt_lcm
                           ,vr_cdagenci_lcm
                           ,vr_cdbccxlt_lcm
                           ,vr_nrdolote_lcm
                           ,vr_nrseqdig_lcm
                           ,rw_craplcm.vllanmto;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Erro ao inserir na tabela de lancamentos. '||sqlerrm;
                    RAISE vr_exc_erro;
                END;

                /* Atualiza o lote na craplot */
                BEGIN
                  UPDATE craplot SET craplot.qtinfoln = Nvl(craplot.qtinfoln,0) + 1
                                    ,craplot.qtcompln = Nvl(craplot.qtcompln,0) + 1
                                    ,craplot.nrseqdig = Nvl(vr_nrseqdig_lcm,0)
                                    ,craplot.vlinfocr = Nvl(craplot.vlinfocr,0) + rw_craplcm.vllanmto
                                    ,craplot.vlcompcr = Nvl(craplot.vlcompcr,0) + rw_craplcm.vllanmto
                  WHERE craplot.ROWID = rw_craplot.ROWID;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Erro ao atualizar tabela craplot. '||SQLERRM;
                    --Levantar Excecao
                    RAISE vr_exc_erro;
                END;

              END IF;

              -- Procedure para inserir o valor do IOF
              /*TIOF0001.pc_insere_iof(pr_cdcooper     => pr_cdcooper
                                    ,pr_nrdconta     => rw_craptdb.nrdconta
                                    ,pr_dtmvtolt     => vr_dtmvtolt
                                    ,pr_tpproduto    => 2   --> Desconto de Titulo
                                    ,pr_nrcontrato   => rw_craptdb.nrborder
                                    ,pr_dtmvtolt_lcm => vr_dtmvtolt_lcm
                                    ,pr_cdagenci_lcm => vr_cdagenci_lcm
                                    ,pr_cdbccxlt_lcm => vr_cdbccxlt_lcm
                                    ,pr_nrdolote_lcm => vr_nrdolote_lcm
                                    ,pr_nrseqdig_lcm => vr_nrseqdig_lcm
                                    ,pr_vliofcpl     => vr_vliofcpl
                                    ,pr_flgimune     => vr_flgimune
                                    ,pr_cdcritic     => vr_cdcritic
                                    ,pr_dscritic     => vr_dscritic);

              -- Condicao para verificar se houve critica
              IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;
              */
              ------------------------------------------------------------------------------------------
              -- Fim Efetuar o Lancamento de IOF
              ------------------------------------------------------------------------------------------
            END IF;

            --Atualizar situacao titulo
            BEGIN
              UPDATE craptdb SET craptdb.insittit = 2
                                ,craptdb.dtdpagto = vr_dtmvtolt
              WHERE craptdb.ROWID = rw_craptdb.ROWID
              RETURNING craptdb.dtdpagto INTO rw_craptdb.dtdpagto;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar tabela craptdb. '||SQLERRM;
                --Levantar Excecao
                RAISE vr_exc_erro;
            END;
          ELSIF pr_indbaixa = 2 THEN
            /* Leitura do lote */
            OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdagenci => 1
                            ,pr_cdbccxlt => 100
                            ,pr_nrdolote => 10300);
            --Posicionar no proximo registro
            FETCH cr_craplot INTO rw_craplot;
            --Se encontrou registro
            IF cr_craplot%NOTFOUND THEN
              --Fechar Cursor
              CLOSE cr_craplot;
              --Criar lote
              BEGIN
                INSERT INTO craplot
                    (craplot.cdcooper
                    ,craplot.dtmvtolt
                    ,craplot.cdagenci
                    ,craplot.cdbccxlt
                    ,craplot.nrdolote
                    ,craplot.cdoperad
                    ,craplot.tplotmov
                    ,craplot.cdhistor)
                VALUES
                    (pr_cdcooper
                    ,pr_dtmvtolt
                    ,1
                    ,100
                    ,10300
                    ,pr_cdoperad
                    ,1
                    ,591)
                RETURNING ROWID
                    ,craplot.dtmvtolt
                    ,craplot.cdagenci
                    ,craplot.cdbccxlt
                    ,craplot.nrdolote
                    ,craplot.nrseqdig
                INTO rw_craplot.ROWID
                    ,rw_craplot.dtmvtolt
                    ,rw_craplot.cdagenci
                    ,rw_craplot.cdbccxlt
                    ,rw_craplot.nrdolote
                    ,rw_craplot.nrseqdig;
              EXCEPTION
                WHEN Dup_Val_On_Index THEN
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Lote ja cadastrado.';
                  RAISE vr_exc_erro;
                WHEN OTHERS THEN
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Erro ao inserir na tabela de lotes. '||sqlerrm;
                  RAISE vr_exc_erro;
              END;
            END IF;
            --Fechar Cursor
            IF cr_craplot%ISOPEN THEN
              CLOSE cr_craplot;
            END IF;
            --Gravar lancamento
            BEGIN
              INSERT INTO craplcm
                  (craplcm.dtmvtolt
                  ,craplcm.cdagenci
                  ,craplcm.cdbccxlt
                  ,craplcm.nrdolote
                  ,craplcm.nrdconta
                  ,craplcm.nrdocmto
                  ,craplcm.vllanmto
                  ,craplcm.cdhistor
                  ,craplcm.nrseqdig
                  ,craplcm.nrdctabb
                  ,craplcm.nrautdoc
                  ,craplcm.cdcooper
                  ,craplcm.cdpesqbb)
              VALUES
                  (rw_craplot.dtmvtolt
                  ,rw_craplot.cdagenci
                  ,rw_craplot.cdbccxlt
                  ,rw_craplot.nrdolote
                  ,rw_craptdb.nrdconta
                  ,Nvl(rw_craplot.nrseqdig,0) + 1
                  ,pr_tab_titulos(vr_index_titulo).vltitulo
                  ,591
                  ,Nvl(rw_craplot.nrseqdig,0) + 1
                  ,rw_craptdb.nrdconta
                  ,0
                  ,pr_cdcooper
                  ,rw_craptdb.nrdocmto)
              RETURNING craplcm.nrseqdig
                       ,craplcm.vllanmto
              INTO rw_craplcm.nrseqdig
                  ,rw_craplcm.vllanmto;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao inserir na tabela de lancamentos. '||sqlerrm;
                RAISE vr_exc_erro;
            END;
            /* Atualiza o lote na craplot */
            BEGIN
              UPDATE craplot SET craplot.qtinfoln = Nvl(craplot.qtinfoln,0) + 1
                                ,craplot.qtcompln = Nvl(craplot.qtcompln,0) + 1
                                ,craplot.nrseqdig = Nvl(rw_craplcm.nrseqdig,0)
                                ,craplot.vlinfocr = Nvl(craplot.vlinfocr,0) + rw_craplcm.vllanmto
                                ,craplot.vlcompcr = Nvl(craplot.vlcompcr,0) + rw_craplcm.vllanmto
              WHERE craplot.ROWID = rw_craplot.ROWID
              RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig;
            EXCEPTION
              WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar tabela craplot. '||SQLERRM;
              --Levantar Excecao
              RAISE vr_exc_erro;
            END;

            --Atualizar situacao titulo
            BEGIN
              UPDATE craptdb SET craptdb.insittit = 3 /* Baixado s/ pagto */
              WHERE craptdb.ROWID = rw_craptdb.ROWID;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar tabela craptdb. '||SQLERRM;
                --Levantar Excecao
                RAISE vr_exc_erro;
            END;
            --Selecionar informacoes Cobranca
            OPEN cr_crapcob (pr_cdcooper => pr_cdcooper
                            ,pr_cdbandoc => pr_tab_titulos(vr_index_titulo).cdbandoc
                            ,pr_nrdctabb => pr_tab_titulos(vr_index_titulo).nrdctabb
                            ,pr_nrdconta => pr_tab_titulos(vr_index_titulo).nrdconta
                            ,pr_nrcnvcob => pr_tab_titulos(vr_index_titulo).nrcnvcob
                            ,pr_nrdocmto => pr_tab_titulos(vr_index_titulo).nrdocmto
                            ,pr_flgregis => 1);
            --Posicionar no proximo registro
            FETCH cr_crapcob INTO rw_crapcob;
            --Se nao encontrar
            IF cr_crapcob%FOUND THEN
              --Fechar Cursor
              CLOSE cr_crapcob;
              --Montar Mensagem
              vr_dsmensag:= 'Tit baixado de desconto s/ pagto';
              --Criar log Cobranca
              PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.ROWID --ROWID da Cobranca
                                           ,pr_cdoperad => pr_cdoperad      --Operador
                                           ,pr_dtmvtolt => pr_dtmvtolt      --Data movimento
                                           ,pr_dsmensag => vr_dsmensag      --Descricao Mensagem
                                           ,pr_des_erro => vr_des_erro      --Indicador erro
                                           ,pr_dscritic => vr_dscritic);    --Descricao erro
              --Se ocorreu erro
              IF vr_des_erro = 'NOK' THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
            END IF;
            --Fechar Cursor
            IF cr_crapcob%ISOPEN THEN
              CLOSE cr_crapcob;
            END IF;
          END IF; /* Final da baixa por vencimento */

          /**** ABATIMENTO DE JUROS ****/
          vr_txdiaria:= APLI0001.fn_round((POWER(1 + (rw_crapbdt.txmensal / 100),1 / 30) - 1),7);
          --Quantidade dias prazo
          vr_qtdprazo:= TO_NUMBER(rw_craptdb.dtvencto - rw_craptdb.dtlibbdt) -
                        TO_NUMBER(rw_craptdb.dtvencto - rw_craptdb.dtdpagto);
          --Valor Titulo
          vr_vltitulo:= rw_craptdb.vltitulo;
          --Data Periodo
          vr_dtperiod:= rw_craptdb.dtlibbdt;
          --Zerar valor juros
          vr_vldjuros:= 0;

          /* Houve pagamento antecipado e data de pagamento maior que data de liberação do bordero (vr_qtdprazo>0) */
          IF vr_qtdprazo > 0 AND rw_craptdb.dtdpagto < rw_craptdb.dtvencto  THEN
            --Percorrer todo o prazo
            FOR vr_contador IN 1..vr_qtdprazo LOOP
              --Valor juros
              vr_vldjuros:= APLI0001.fn_round(vr_vltitulo * vr_txdiaria,2);
              --Valor Titulo recebe valor juros
              vr_vltitulo:= vr_vltitulo + vr_vldjuros;
              --Data Periodo
              vr_dtperiod:= vr_dtperiod + 1;
              --data referencia juros
              vr_dtrefjur:= Last_Day(vr_dtperiod);
              --Marcar que nao encontrou
              vr_flgachou:= FALSE;
              --Selecionar Lancamento Juros Desconto Titulo
              FOR idx IN 1..vr_tab_crawljt.Count LOOP
                IF vr_tab_crawljt(idx).cdcooper = rw_craptdb.cdcooper AND
                   vr_tab_crawljt(idx).nrdconta = rw_craptdb.nrdconta AND
                   vr_tab_crawljt(idx).nrborder = rw_craptdb.nrborder AND
                   vr_tab_crawljt(idx).dtrefere = vr_dtrefjur         AND
                   vr_tab_crawljt(idx).cdbandoc = rw_craptdb.cdbandoc AND
                   vr_tab_crawljt(idx).nrdctabb = rw_craptdb.nrdctabb AND
                   vr_tab_crawljt(idx).nrcnvcob = rw_craptdb.nrcnvcob AND
                   vr_tab_crawljt(idx).nrdocmto = rw_craptdb.nrdocmto THEN
                  --Marcar que encontrou
                  vr_flgachou:= TRUE;
                  --Acumular valor juros
                  vr_tab_crawljt(idx).vldjuros:= vr_tab_crawljt(idx).vldjuros + vr_vldjuros;
                END IF;
              END LOOP;
              /*Se nao encontrou cria */
              IF NOT vr_flgachou THEN
                --Selecionar indice
                vr_incrawljt:= vr_tab_crawljt.Count+1;
                --Gravar dados tabela memoria
                vr_tab_crawljt(vr_incrawljt).cdcooper:= rw_craptdb.cdcooper;
                vr_tab_crawljt(vr_incrawljt).nrdconta:= rw_craptdb.nrdconta;
                vr_tab_crawljt(vr_incrawljt).nrborder:= rw_craptdb.nrborder;
                vr_tab_crawljt(vr_incrawljt).dtrefere:= vr_dtrefjur;
                vr_tab_crawljt(vr_incrawljt).cdbandoc:= rw_craptdb.cdbandoc;
                vr_tab_crawljt(vr_incrawljt).nrdctabb:= rw_craptdb.nrdctabb;
                vr_tab_crawljt(vr_incrawljt).nrcnvcob:= rw_craptdb.nrcnvcob;
                vr_tab_crawljt(vr_incrawljt).nrdocmto:= rw_craptdb.nrdocmto;
                vr_tab_crawljt(vr_incrawljt).vldjuros:= vr_vldjuros;
              END IF;
            END LOOP;  --vr_contador IN 1..vr_qtdprazo
            /*  Atualiza registro de provisao de juros ..........  */
            FOR idx IN 1..vr_tab_crawljt.Count LOOP
              --Se for a mesma cooperativa
              IF vr_tab_crawljt(idx).cdcooper = pr_cdcooper THEN
                --Selecionar lancamento juros desconto titulo
                OPEN cr_crapljt (pr_cdcooper => vr_tab_crawljt(idx).cdcooper
                                ,pr_nrdconta => vr_tab_crawljt(idx).nrdconta
                                ,pr_nrborder => vr_tab_crawljt(idx).nrborder
                                ,pr_dtrefere => vr_tab_crawljt(idx).dtrefere
                                ,pr_cdbandoc => vr_tab_crawljt(idx).cdbandoc
                                ,pr_nrdctabb => vr_tab_crawljt(idx).nrdctabb
                                ,pr_nrcnvcob => vr_tab_crawljt(idx).nrcnvcob
                                ,pr_nrdocmto => vr_tab_crawljt(idx).nrdocmto
                                ,pr_tipo     => 1);
                --Posicionar no proximo registro
                FETCH cr_crapljt INTO rw_crapljt;
                --Se nao encontrar
                IF cr_crapljt%NOTFOUND THEN
                  --Fechar Cursor
                  CLOSE cr_crapljt;
                  --Mensagem erro
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Registro crapljt nao encontrado.';
                  --Gerar erro
                  GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                       ,pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
                                       ,pr_nrsequen => 1 /** Sequencia **/
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic
                                       ,pr_tab_erro => vr_tab_erro);
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END IF;
                --Fechar Cursor
                CLOSE cr_crapljt;
                --Se o valor dos juros mudou
                IF rw_crapljt.vldjuros <> vr_tab_crawljt(idx).vldjuros THEN
                  --Se valor juros tabela eh maior encontrado
                  IF  rw_crapljt.vldjuros > vr_tab_crawljt(idx).vldjuros THEN
                    --Atualizar tabela juros
                    BEGIN
                      UPDATE crapljt SET crapljt.vlrestit = NVL(crapljt.vldjuros,0) - NVL(vr_tab_crawljt(idx).vldjuros,0)
                                        ,crapljt.vldjuros = nvl(vr_tab_crawljt(idx).vldjuros,0)
                      WHERE crapljt.ROWID = rw_crapljt.ROWID
                      RETURNING crapljt.vlrestit INTO rw_crapljt.vlrestit;
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_cdcritic:= 0;
                        vr_dscritic:= 'Erro ao atualizar tabela crapljt. '||sqlerrm;
                        --Levantar Excecao
                        RAISE vr_exc_erro;
                    END;
                    /* Juros a ser restituido */
                    vr_vltotjur:= rw_crapljt.vlrestit;
                  ELSE
                    --Mensagem erro
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Erro - Juros negativo: '||rw_crapljt.vldjuros;
                    --Gerar erro
                    GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_nrdcaixa => pr_nrdcaixa
                                         ,pr_nrsequen => 1 /** Sequencia **/
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic
                                         ,pr_tab_erro => vr_tab_erro);
                    --Levantar Excecao
                    RAISE vr_exc_erro;
                  END IF;
                END IF;
                --Data de Referencia
                vr_dtultdat:= vr_tab_crawljt(idx).dtrefere;
                --Excluir registro da tabela memoria
                vr_tab_crawljt.DELETE(idx);
              END IF;
            END LOOP;
          --#489111 início
          /* Houve pagamento antecipado e data de pagamento igual a data de liberação do bordero (vr_qtdprazo=0) */
          ELSIF vr_qtdprazo = 0 AND rw_craptdb.dtdpagto < rw_craptdb.dtvencto  THEN
            --data referencia juros
            vr_dtrefjur:= Last_Day(rw_craptdb.dtdpagto);
            /* Restitui o juro que seria apropriado no mês do pagamento do título */
            FOR rw_crapljt IN cr_crapljt (pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => rw_craptdb.nrdconta
                                         ,pr_nrborder => rw_craptdb.nrborder
                                         ,pr_dtrefere => vr_dtrefjur
                                         ,pr_cdbandoc => rw_craptdb.cdbandoc
                                         ,pr_nrdctabb => rw_craptdb.nrdctabb
                                         ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                         ,pr_nrdocmto => rw_craptdb.nrdocmto
                                         ,pr_tipo     => 1) LOOP
              --Acumular total juros
              vr_vltotjur:= Nvl(vr_vltotjur,0) + Nvl(rw_crapljt.vldjuros,0);
              --Atualizar tabela lancamento juros desconto titulos
              BEGIN
                UPDATE crapljt SET crapljt.vlrestit = crapljt.vldjuros
                                  ,crapljt.vldjuros = 0
                WHERE crapljt.ROWID = rw_crapljt.ROWID;
              EXCEPTION
                WHEN Others THEN
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Erro ao atualizar tabela crapljt(1).'||sqlerrm;
                  --Levantar Excecao
                  RAISE vr_exc_erro;
              END;
            END LOOP;
            --Data de Referencia
            vr_dtultdat:= vr_dtrefjur;
          --#489111 fim
          ELSE
            /* o juros sempre eh referente ao ultimo dia do mes */
            vr_dtultdat:= Last_Day(rw_craptdb.dtdpagto);
          END IF;
          /* Restitui o juro que seria apropriado no(s) periodo(s) seguinte(s) */
          FOR rw_crapljt IN cr_crapljt (pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => rw_craptdb.nrdconta
                                       ,pr_nrborder => rw_craptdb.nrborder
                                       ,pr_dtrefere => vr_dtultdat
                                       ,pr_cdbandoc => rw_craptdb.cdbandoc
                                       ,pr_nrdctabb => rw_craptdb.nrdctabb
                                       ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                       ,pr_nrdocmto => rw_craptdb.nrdocmto
                                       ,pr_tipo     => 2) LOOP
            --Acumular total juros
            vr_vltotjur:= Nvl(vr_vltotjur,0) + Nvl(rw_crapljt.vldjuros,0);
            --Atualizar tabela lancamento juros desconto titulos
            BEGIN
              UPDATE crapljt SET crapljt.vlrestit = crapljt.vldjuros
                                ,crapljt.vldjuros = 0
              WHERE crapljt.ROWID = rw_crapljt.ROWID;
            EXCEPTION
              WHEN Others THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao atualizar tabela crapljt(2).'||sqlerrm;
                --Levantar Excecao
                RAISE vr_exc_erro;
            END;
          END LOOP;
          --Se valor total juros positivo
          IF vr_vltotjur > 0 THEN
            /* Leitura do lote */
            OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdagenci => 1
                            ,pr_cdbccxlt => 100
                            ,pr_nrdolote => 10300);
            --Posicionar no proximo registro
            FETCH cr_craplot INTO rw_craplot;
            --Se encontrou registro
            IF cr_craplot%NOTFOUND THEN
              --Fechar Cursor
              CLOSE cr_craplot;
              --Criar lote
              BEGIN
                INSERT INTO craplot
                    (craplot.cdcooper
                    ,craplot.dtmvtolt
                    ,craplot.cdagenci
                    ,craplot.cdbccxlt
                    ,craplot.nrdolote
                    ,craplot.cdoperad
                    ,craplot.tplotmov
                    ,craplot.cdhistor)
                VALUES
                    (pr_cdcooper
                    ,pr_dtmvtolt
                    ,1
                    ,100
                    ,10300
                    ,pr_cdoperad
                    ,1
                    ,597)
                RETURNING ROWID
                    ,craplot.dtmvtolt
                    ,craplot.cdagenci
                    ,craplot.cdbccxlt
                    ,craplot.nrdolote
                    ,craplot.nrseqdig
                INTO rw_craplot.ROWID
                    ,rw_craplot.dtmvtolt
                    ,rw_craplot.cdagenci
                    ,rw_craplot.cdbccxlt
                    ,rw_craplot.nrdolote
                    ,rw_craplot.nrseqdig;
              EXCEPTION
                WHEN Dup_Val_On_Index THEN
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Lote ja cadastrado.';
                  RAISE vr_exc_erro;
                WHEN OTHERS THEN
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Erro ao inserir na tabela de lotes. '||sqlerrm;
                  RAISE vr_exc_erro;
              END;
            END IF;
            --Fechar Cursor
            IF cr_craplot%ISOPEN THEN
              CLOSE cr_craplot;
            END IF;
            --Gravar lancamento
            BEGIN
              INSERT INTO craplcm
                  (craplcm.dtmvtolt
                  ,craplcm.cdagenci
                  ,craplcm.cdbccxlt
                  ,craplcm.nrdolote
                  ,craplcm.nrdconta
                  ,craplcm.nrdocmto
                  ,craplcm.vllanmto
                  ,craplcm.cdhistor
                  ,craplcm.nrseqdig
                  ,craplcm.nrdctabb
                  ,craplcm.nrautdoc
                  ,craplcm.cdcooper
                  ,craplcm.cdpesqbb)
              VALUES
                  (rw_craplot.dtmvtolt
                  ,rw_craplot.cdagenci
                  ,rw_craplot.cdbccxlt
                  ,rw_craplot.nrdolote
                  ,rw_craptdb.nrdconta
                  ,Nvl(rw_craplot.nrseqdig,0) + 1
                  ,vr_vltotjur
                  ,597
                  ,Nvl(rw_craplot.nrseqdig,0) + 1
                  ,rw_craptdb.nrdconta
                  ,0
                  ,pr_cdcooper
                  ,rw_craptdb.nrdocmto)
              RETURNING craplcm.nrseqdig
                       ,craplcm.vllanmto
              INTO rw_craplcm.nrseqdig
                  ,rw_craplcm.vllanmto;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao inserir na tabela de lancamentos. '||sqlerrm;
                RAISE vr_exc_erro;
            END;
            /* Atualiza o lote na craplot */
            BEGIN
              UPDATE craplot SET craplot.qtinfoln = Nvl(craplot.qtinfoln,0) + 1
                                ,craplot.qtcompln = Nvl(craplot.qtcompln,0) + 1
                                ,craplot.nrseqdig = Nvl(rw_craplcm.nrseqdig,0)
                                ,craplot.vlinfodb = Nvl(craplot.vlinfodb,0) + vr_vltotjur
                                ,craplot.vlcompdb = Nvl(craplot.vlcompdb,0) + vr_vltotjur
              WHERE craplot.ROWID = rw_craplot.ROWID
              RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig;
            EXCEPTION
              WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar tabela craplot. '||SQLERRM;
              --Levantar Excecao
              RAISE vr_exc_erro;
            END;
          END IF;

          /* Verifica se deve liquidar o bordero caso sim Liquida */
          DSCT0001.pc_efetua_liquidacao_bordero (pr_cdcooper => pr_cdcooper  --Codigo Cooperativa
                                                ,pr_cdagenci => pr_cdagenci  --Codigo Agencia
                                                ,pr_nrdcaixa => pr_nrdcaixa  --Numero do Caixa
                                                ,pr_cdoperad => pr_cdoperad  --Codigo Operador
                                                ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                                ,pr_idorigem => pr_idorigem  --Identificador Origem
                                                ,pr_nrdconta => pr_nrdconta  --Numero da Conta
                                                ,pr_nrborder => rw_craptdb.nrborder  --Numero do Bordero
                                                ,pr_tab_erro => vr_tab_erro   --Tabela de erros
                                                ,pr_des_erro => vr_des_erro   --identificador de erro
                                                ,pr_dscritic => vr_dscritic); --Descricao do erro;
          --Se ocorreu erro
          IF vr_des_erro = 'NOK' THEN
            --Mensagem erro
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro na liquidacao do bordero '||
                          rw_craptdb.nrborder||' conta '||rw_craptdb.nrdconta;
            --Gerar erro
            GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => 1 /** Sequencia **/
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => vr_tab_erro);
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;

          /* Gera a tarifa apenas uma vez para a conta */
          IF NOT vr_tab_conta.EXISTS(pr_tab_titulos(vr_index_titulo).nrdconta) THEN

            --Adiciona na tabela de contas ja tarifadas para nao cobrar novamente

            --Inicializar valores
            vr_inpessoa:= 1;
            vr_vlttitsr:= 0;
            vr_vlttitcr:= 0;

            --Selecionar associado
            OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => rw_craptdb.nrdconta);
            --Posicionar no proximo registro
            FETCH cr_crapass INTO rw_crapass;
            --Fechar Cursor
            CLOSE cr_crapass;
            --Se for pessoa fisica
            IF rw_crapass.inpessoa = 1 THEN /* Fisica */
              vr_cdbattar:= 'DSTTITSRPF';
            ELSE
              vr_cdbattar:= 'DSTTITSRPJ';
            END IF;

            /*  Busca valor da tarifa sem registro*/
            TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => pr_cdcooper  --Codigo Cooperativa
                                                  ,pr_cdbattar  => vr_cdbattar  --Codigo Tarifa
                                                  ,pr_vllanmto  => 1            --Valor Lancamento
                                                  ,pr_cdprogra  => NULL         --Codigo Programa
                                                  ,pr_cdhistor  => vr_cdhistor  --Codigo Historico
                                                  ,pr_cdhisest  => vr_cdhisest  --Historico Estorno
                                                  ,pr_vltarifa  => vr_vlttitsr  --Valor tarifa
                                                  ,pr_dtdivulg  => vr_dtdivulg  --Data Divulgacao
                                                  ,pr_dtvigenc  => vr_dtvigenc  --Data Vigencia
                                                  ,pr_cdfvlcop  => vr_cdfvlcop  --Codigo faixa valor cooperativa
                                                  ,pr_cdcritic  => vr_cdcritic  --Codigo Critica
                                                  ,pr_dscritic  => vr_dscritic  --Descricao Critica
                                                  ,pr_tab_erro  => vr_tab_erro); --Tabela erros
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;

            --Se for pessoa fisica
            IF rw_crapass.inpessoa = 1 THEN /* Fisica */
              vr_cdbattar:= 'DSTTITCRPF';
            ELSE
              vr_cdbattar:= 'DSTTITCRPJ';
            END IF;

            /*  Busca valor da tarifa sem registro*/
            TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => pr_cdcooper  --Codigo Cooperativa
                                                  ,pr_cdbattar  => vr_cdbattar  --Codigo Tarifa
                                                  ,pr_vllanmto  => 1            --Valor Lancamento
                                                  ,pr_cdprogra  => NULL         --Codigo Programa
                                                  ,pr_cdhistor  => vr_cdhistor  --Codigo Historico
                                                  ,pr_cdhisest  => vr_cdhisest  --Historico Estorno
                                                  ,pr_vltarifa  => vr_vlttitcr  --Valor tarifa
                                                  ,pr_dtdivulg  => vr_dtdivulg  --Data Divulgacao
                                                  ,pr_dtvigenc  => vr_dtvigenc  --Data Vigencia
                                                  ,pr_cdfvlcop  => vr_cdfvlcop  --Codigo faixa valor cooperativa
                                                  ,pr_cdcritic  => vr_cdcritic  --Codigo Critica
                                                  ,pr_dscritic  => vr_dscritic  --Descricao Critica
                                                  ,pr_tab_erro  => vr_tab_erro); --Tabela erros
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;

            IF (vr_vlttitcr * vr_tottitul_cr) > 0 OR (vr_vlttitsr * vr_tottitul_sr) > 0 THEN
              --Montar Descricao
              IF vr_tottitul_cr > 1 OR vr_tottitul_sr > 1 THEN
                vr_cdpesqbb:= 'Tarifa de titulos descontados';
              ELSE
                vr_cdpesqbb:= rw_craptdb.nrdocmto;
              END IF;
              /* Gera Tarifa de titulos descontados */
              TARI0001.pc_cria_lan_auto_tarifa (pr_cdcooper => pr_cdcooper          --Codigo Cooperativa
                                               ,pr_nrdconta => rw_craptdb.nrdconta  --Numero da Conta
                                               ,pr_dtmvtolt => pr_dtmvtolt          --Data Lancamento
                                               ,pr_cdhistor => vr_cdhistor          --Codigo Historico
                                               ,pr_vllanaut => ((vr_vlttitcr * vr_tottitul_cr) +
                                                                (vr_vlttitsr * vr_tottitul_sr))  --Valor lancamento automatico
                                               ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                               ,pr_cdagenci => 1                    --Codigo Agencia
                                               ,pr_cdbccxlt => 100                  --Codigo banco caixa
                                               ,pr_nrdolote => 8452                 --Numero do lote
                                               ,pr_tpdolote => 1                    --Tipo do lote
                                               ,pr_nrdocmto => 0                    --Numero do documento
                                               ,pr_nrdctabb => rw_craptdb.nrdconta  --Numero da conta
                                               ,pr_nrdctitg => gene0002.fn_mask(rw_craptdb.nrdconta,'99999999') --Numero da conta integracao
                                               ,pr_cdpesqbb => vr_cdpesqbb          --Codigo pesquisa
                                               ,pr_cdbanchq => 0                    --Codigo Banco Cheque
                                               ,pr_cdagechq => 0                    --Codigo Agencia Cheque
                                               ,pr_nrctachq => 0                    --Numero Conta Cheque
                                               ,pr_flgaviso => FALSE                --Flag aviso
                                               ,pr_tpdaviso => 0                    --Tipo aviso
                                               ,pr_cdfvlcop => vr_cdfvlcop          --Codigo cooperativa
                                               ,pr_inproces => rw_crapdat.inproces  --Indicador processo
                                               ,pr_rowid_craplat => vr_rowid_craplat --Rowid do lancamento tarifa
                                               ,pr_tab_erro => vr_tab_erro          --Tabela retorno erro
                                               ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                               ,pr_dscritic => vr_dscritic);        --Descricao Critica
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                vr_cdcritic:= 0;
                --Gerar erro
                GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_nrdcaixa => pr_nrdcaixa
                                     ,pr_nrsequen => 1 /** Sequencia **/
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic
                                     ,pr_tab_erro => vr_tab_erro);
                --Levantar Excecao
                RAISE vr_exc_erro;
              ELSE
                --Marcar que tarifa ja foi cobrada da conta
                vr_tab_conta(pr_tab_titulos(vr_index_titulo).nrdconta):= 0;
              END IF;
              --Zerar total titulos
              vr_tottitul_cr:= 0;
              vr_tottitul_sr:= 0;
            END IF;
          END IF;
        EXCEPTION
          WHEN vr_exc_proximo THEN
            NULL;
          WHEN vr_exc_erro THEN
            RAISE vr_exc_erro;
          WHEN OTHERS THEN
            --Montar Mensagem Erro
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro na rotina DSCT0001.pc_efetua_baixa_titulo. '||sqlerrm;
            RAISE vr_exc_erro;
        END;
        --Proximo registro
        vr_index_titulo:= pr_tab_titulos.NEXT(vr_index_titulo);
      END LOOP;
      --Limpar tabela contas
      vr_tab_conta.DELETE;

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;

        -- Se nao tiver gerado a tabela de erro, gera a mesma
        IF vr_tab_erro.count = 0 THEN
          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 /** Sequencia **/
                               ,pr_cdcritic => pr_cdcritic
                               ,pr_dscritic => pr_dscritic
                               ,pr_tab_erro => vr_tab_erro);
        END IF;

      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina DSCT0001.pc_efetua_baixa_titulo. '||sqlerrm;

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => pr_dscritic
                             ,pr_tab_erro => vr_tab_erro);

    END;
  END pc_efetua_baixa_titulo;

  /* Procedure para efetuar resgate de titulos de um determinado bordero */
  PROCEDURE pc_efetua_resgate_tit_bord (pr_cdcooper    IN craplot.cdcooper%TYPE  --> Codigo Cooperativa
                                       ,pr_cdagenci    IN craplot.cdagenci%TYPE  --> Codigo Agencia
                                       ,pr_nrdcaixa    IN craplot.nrdcaixa%TYPE  --> Numero Caixa
                                       ,pr_cdoperad    IN craplot.cdoperad%TYPE  --> Codigo operador
                                       ,pr_dtmvtolt    IN craplot.dtmvtolt%TYPE  --> Data Movimento
                                       ,pr_dtmvtoan    IN craplot.dtmvtolt%TYPE  --> Data anterior do movimento
                                       ,pr_inproces    IN crapdat.inproces%TYPE  --> Indicador processo
                                       ,pr_dtresgat    IN craplot.dtmvtolt%TYPE  --> Data do resgate
                                       ,pr_idorigem    IN INTEGER                --> Identificador Origem pagamento
                                       ,pr_nrdconta    IN craplcm.nrdconta%TYPE  --> Numero da conta
                                       ,pr_cdbccxlt    IN craplot.cdbccxlt%TYPE  --> codigo do banco
                                       ,pr_nrdolote    IN craplot.nrdolote%TYPE  --> Numero do lote
                                       ,pr_tab_titulos IN PAGA0001.typ_tab_titulos --> Titulos a serem resgatados

                                       ,pr_cdcritic    OUT INTEGER                 --> Codigo Critica
                                       ,pr_dscritic    OUT VARCHAR2                --> Descricao Critica
                                       ) IS
    -- .........................................................................
    --
    --  Programa : pc_efetua_resgate_tit_bord           Antigo: b1wgen0030.p/efetua_resgate_tit_bordero
    --  Sistema  : Cred
    --  Sigla    : DSCT0001
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Maio/2016.                   Ultima atualizacao: 10/05/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para efetuar resgate de titulos de um determinado bordero
    --
    --  Alteracoes:
    --
    -- .........................................................................
    ------------------------------- CURSORES ---------------------------------
    --Buscar informacoes de lote
    CURSOR cr_craplot (pr_cdcooper IN craplot.cdcooper%TYPE
                      ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                      ,pr_cdagenci IN craplot.cdagenci%TYPE
                      ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                      ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
      SELECT craplot.nrdolote
            ,craplot.nrseqdig
            ,craplot.cdbccxlt
            ,craplot.dtmvtolt
            ,craplot.cdagenci
            ,craplot.tplotmov
            ,craplot.cdhistor
            ,craplot.rowid
        FROM craplot craplot
       WHERE craplot.cdcooper = pr_cdcooper
         AND craplot.dtmvtolt = pr_dtmvtolt
         AND craplot.cdagenci = pr_cdagenci
         AND craplot.cdbccxlt = pr_cdbccxlt
         AND craplot.nrdolote = pr_nrdolote
      FOR UPDATE NOWAIT;
    rw_craplot cr_craplot%ROWTYPE;

    --Selecionar bordero titulo
    CURSOR cr_crapbdt (pr_cdcooper IN crapbdt.cdcooper%TYPE
                      ,pr_nrborder IN crapbdt.nrborder%TYPE) IS
      SELECT crapbdt.cdcooper
            ,crapbdt.nrborder
            ,crapbdt.nrdconta
            ,crapbdt.insitbdt
            ,crapbdt.txmensal
            ,crapbdt.dtlibbdt
            ,crapbdt.rowid
        FROM crapbdt
       WHERE crapbdt.cdcooper = pr_cdcooper
         AND crapbdt.nrborder = pr_nrborder
      FOR UPDATE NOWAIT;
    rw_crapbdt cr_crapbdt%ROWTYPE;

    --Selecionar informacoes dos titulos do bordero
    CURSOR cr_craptdb (pr_cdcooper IN craptdb.cdcooper%type
                      ,pr_nrdconta IN craptdb.nrdconta%type
                      ,pr_nrborder IN craptdb.nrborder%TYPE
                      ,pr_cdbandoc IN craptdb.cdbandoc%TYPE
                      ,pr_nrdctabb IN craptdb.nrdctabb%type
                      ,pr_nrcnvcob IN craptdb.nrcnvcob%type
                      ,pr_nrdocmto IN craptdb.nrdocmto%TYPE) IS
      SELECT craptdb.dtvencto
            ,craptdb.vltitulo
            ,craptdb.nrdconta
            ,craptdb.nrdocmto
            ,craptdb.cdcooper
            ,craptdb.insittit
            ,craptdb.dtdpagto
            ,craptdb.nrborder
            ,craptdb.dtlibbdt
            ,craptdb.cdbandoc
            ,craptdb.nrdctabb
            ,craptdb.nrcnvcob
            ,craptdb.vlliquid
            ,craptdb.rowid
            ,COUNT(*) OVER(PARTITION BY craptdb.cdcooper) qtdreg
        FROM craptdb
       WHERE craptdb.cdcooper = pr_cdcooper
         AND craptdb.cdbandoc = pr_cdbandoc
         AND craptdb.nrdctabb = pr_nrdctabb
         AND craptdb.nrcnvcob = pr_nrcnvcob
         AND craptdb.nrdconta = pr_nrdconta
         AND craptdb.nrdocmto = pr_nrdocmto
         AND craptdb.nrborder = pr_nrborder
      FOR UPDATE NOWAIT   ;
    rw_craptdb cr_craptdb%ROWTYPE;

    --Buscar lancamento juros desconto titulo
    CURSOR cr_crapljt (pr_cdcooper IN crapljt.cdcooper%type
                      ,pr_nrdconta IN crapljt.nrdconta%type
                      ,pr_nrborder IN crapljt.nrborder%type
                      ,pr_dtrefere IN crapljt.dtrefere%type
                      ,pr_cdbandoc IN crapljt.cdbandoc%type
                      ,pr_nrdctabb IN crapljt.nrdctabb%type
                      ,pr_nrcnvcob IN crapljt.nrcnvcob%type
                      ,pr_nrdocmto IN crapljt.nrdocmto%TYPE) IS
      SELECT crapljt.ROWID
            ,crapljt.vldjuros
            ,crapljt.vlrestit
        FROM crapljt
       WHERE crapljt.cdcooper = pr_cdcooper
         AND crapljt.nrdconta = pr_nrdconta
         AND crapljt.nrborder = pr_nrborder
         AND crapljt.dtrefere = pr_dtrefere
         AND crapljt.cdbandoc = pr_cdbandoc
         AND crapljt.nrdctabb = pr_nrdctabb
         AND crapljt.nrcnvcob = pr_nrcnvcob
         AND crapljt.nrdocmto = pr_nrdocmto
      FOR UPDATE NOWAIT;

    --Buscar lancamento juros desconto titulo com data de referencia maior que o parametro
    CURSOR cr_crapljt2 (pr_cdcooper IN crapljt.cdcooper%type
                      ,pr_nrdconta IN crapljt.nrdconta%type
                      ,pr_nrborder IN crapljt.nrborder%type
                      ,pr_dtrefere IN crapljt.dtrefere%type
                      ,pr_cdbandoc IN crapljt.cdbandoc%type
                      ,pr_nrdctabb IN crapljt.nrdctabb%type
                      ,pr_nrcnvcob IN crapljt.nrcnvcob%type
                      ,pr_nrdocmto IN crapljt.nrdocmto%TYPE) IS
      SELECT crapljt.ROWID
            ,crapljt.vldjuros
            ,crapljt.vlrestit
        FROM crapljt
       WHERE crapljt.cdcooper = pr_cdcooper
         AND crapljt.nrdconta = pr_nrdconta
         AND crapljt.nrborder = pr_nrborder
         AND crapljt.dtrefere > pr_dtrefere
         AND crapljt.cdbandoc = pr_cdbandoc
         AND crapljt.nrdctabb = pr_nrdctabb
         AND crapljt.nrcnvcob = pr_nrcnvcob
         AND crapljt.nrdocmto = pr_nrdocmto;
    rw_crapljt cr_crapljt%ROWTYPE;

    --Selecionar informacoes Cobranca
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
      AND   crapcob.flgregis = pr_flgregis
      ORDER BY crapcob.progress_recid ASC;
    rw_crapcob cr_crapcob%ROWTYPE;

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

    ------------------------------- VARIAVEIS -------------------------------
      --Variaveis de erro
      vr_des_erro     VARCHAR2(4000);
      vr_exc_erro     EXCEPTION;
      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     VARCHAR2(4000);
      --Tabela de memoria de erros
      vr_tab_erro     GENE0001.typ_tab_erro;

      vr_idxtit       VARCHAR2(20);

      vr_fcraplot     BOOLEAN := FALSE;
      vr_fcrapbdt     BOOLEAN := FALSE;
      vr_fcrapljt     BOOLEAN := FALSE;
      vr_flgachou     BOOLEAN := FALSE;
      vr_txdiaria     NUMBER;
      vr_incrawljt    PLS_INTEGER;
      idx             PLS_INTEGER;

      vr_inpessoa     crapass.inpessoa%TYPE;

      -- Variaveis tarifa
      vr_cdbattar     VARCHAR2(1000);
      vr_cdhisest     INTEGER;
      vr_dtdivulg     DATE;
      vr_dtvigenc     DATE;
      vr_cdhistor     INTEGER;
      vr_cdfvlcop     INTEGER;
      vr_vltarres     NUMBER(32,8);
      vr_rowid_craplat ROWID;

      --Recalculo titulo
      vr_qtdprazo    NUMBER;
      vr_vltitulo    craptdb.vltitulo%TYPE;
      vr_vlliqnov    craptdb.vltitulo%TYPE;
      vr_dtperiod    crapbdt.dtlibbdt%TYPE;
      vr_dtrefjur    crapbdt.dtlibbdt%TYPE;
      vr_vldjuros    NUMBER(38,8) := 0;
      vr_vljurper    NUMBER(38,8) := 0;
      vr_vlliqori    craptdb.vlliquid%TYPE;
      vr_dtultdat    DATE;
      vr_vllanmto    craplcm.vllanmto%TYPE;






    --------------------------- SUBROTINAS INTERNAS --------------------------


  BEGIN

    SAVEPOINT vr_resgate;
    vr_dscritic := NULL;

    --> Lockar a tabela de lote
    FOR i IN 1..10 LOOP
      BEGIN
        --> Busca lote
        OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                        ,pr_dtmvtolt => pr_dtmvtolt
                        ,pr_cdagenci => pr_cdagenci
                        ,pr_cdbccxlt => pr_cdbccxlt
                        ,pr_nrdolote => pr_nrdolote);
        --Posicionar no proximo registro
        FETCH cr_craplot INTO rw_craplot;
        vr_fcraplot := cr_craplot%FOUND;
        CLOSE cr_craplot;

        vr_dscritic := NULL;
        --sair do loop
        EXIT;

      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Registro de lote esta sendo usado no momento.';
          CLOSE cr_craplot;
          dbms_lock.sleep(1);
          continue;
      END;
    END LOOP;

    --> Verificar se saiu do loop com critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    --> Verificar se encontrou o lote
    IF vr_fcraplot = FALSE THEN
      vr_dscritic := 'Registro de lote nao encontrado.';
    --> Verificar tipo do lote
    ELSIF rw_craplot.tplotmov <> 34 THEN
      vr_dscritic := 'Tipo de lote deve ser 34-Descto de titulos.';
    END IF;

    --> Verificar se saiu do loop com critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    --> Lockar a tabela de bordero
    FOR i IN 1..10 LOOP
      BEGIN
        --Selecionar bordero titulo
        OPEN cr_crapbdt (pr_cdcooper => pr_cdcooper
                        ,pr_nrborder => rw_craplot.cdhistor);
        --Posicionar no proximo registro
        FETCH cr_crapbdt INTO rw_crapbdt;
        vr_fcrapbdt := cr_crapbdt%FOUND;
        --Se nao encontrar
        IF cr_crapbdt%NOTFOUND THEN
          CLOSE cr_crapbdt;
          vr_dscritic:= 'Bordero nao encontrado.';
        ELSE
          CLOSE cr_crapbdt;
          vr_dscritic := NULL;
        END IF;
        --sair do loop
        EXIT;

      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Registro de bordero esta em uso no momento.';
          CLOSE cr_crapbdt;
          dbms_lock.sleep(1);
          continue;
      END;
    END LOOP;

    --> Verificar se saiu do loop com critica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    --> Verifica se esta Liberado
    ELSIF rw_crapbdt.insitbdt <> 3  THEN
      vr_dscritic := 'Bordero deve estar LIBERADO.';
      RAISE vr_exc_erro;
    END IF;

    --> Calcular taxa diaria
    vr_txdiaria := apli0001.fn_round((power(1 + (rw_crapbdt.txmensal / 100),1 / 30) - 1),7);

    --> Leitura dos titulos para serem resgatados
    vr_idxtit:= pr_tab_titulos.FIRST;
    WHILE vr_idxtit IS NOT NULL LOOP
      --Buscar titulos do bordero
      OPEN cr_craptdb (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_tab_titulos(vr_idxtit).nrdconta
                      ,pr_nrborder => rw_crapbdt.nrborder
                      ,pr_cdbandoc => pr_tab_titulos(vr_idxtit).cdbandoc
                      ,pr_nrdctabb => pr_tab_titulos(vr_idxtit).nrdctabb
                      ,pr_nrcnvcob => pr_tab_titulos(vr_idxtit).nrcnvcob
                      ,pr_nrdocmto => pr_tab_titulos(vr_idxtit).nrdocmto);
      --Posicionar no proximo registro
      FETCH cr_craptdb INTO rw_craptdb;
      --Se Nao encontrou ou encontrou e tem mais de 1
      IF cr_craptdb%NOTFOUND OR
         (cr_craptdb%FOUND AND rw_craptdb.qtdreg > 1) THEN
        CLOSE cr_craptdb;
        --Proximo registro
        vr_idxtit:= pr_tab_titulos.NEXT(vr_idxtit);
      END IF;
      --Fechar Cursor
      CLOSE cr_craptdb;

      --> Assume como padrao pessoa fisica
      vr_inpessoa := 1;
      vr_vltarres := 0;

      --Busca associado
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_tab_titulos(vr_idxtit).nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%FOUND THEN
        vr_inpessoa := rw_crapass.inpessoa;
      END IF;

      --Fechar Cursor
      CLOSE cr_crapass;
      --Se for pessoa fisica
      IF vr_inpessoa = 1 THEN
        IF  pr_tab_titulos(vr_idxtit).flgregis = TRUE THEN
          vr_cdbattar := 'DSTRESCRPF';
        ELSE
          vr_cdbattar := 'DSTRESSRPF';
        END IF;
      ELSE
        IF  pr_tab_titulos(vr_idxtit).flgregis = TRUE THEN
          vr_cdbattar := 'DSTRESCRPJ';
        ELSE
          vr_cdbattar := 'DSTRESSRPJ';
        END IF;
      END IF;

      --> Busca valor da tarifa
      TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => pr_cdcooper  --Codigo Cooperativa
                                            ,pr_cdbattar  => vr_cdbattar  --Codigo Tarifa
                                            ,pr_vllanmto  => 1            --Valor Lancamento
                                            ,pr_cdprogra  => NULL         --Codigo Programa
                                            ,pr_cdhistor  => vr_cdhistor  --Codigo Historico
                                            ,pr_cdhisest  => vr_cdhisest  --Historico Estorno
                                            ,pr_vltarifa  => vr_vltarres  --Valor tarifa
                                            ,pr_dtdivulg  => vr_dtdivulg  --Data Divulgacao
                                            ,pr_dtvigenc  => vr_dtvigenc  --Data Vigencia
                                            ,pr_cdfvlcop  => vr_cdfvlcop  --Codigo faixa valor cooperativa
                                            ,pr_cdcritic  => vr_cdcritic  --Codigo Critica
                                            ,pr_dscritic  => vr_dscritic  --Descricao Critica
                                            ,pr_tab_erro  => vr_tab_erro); --Tabela erros
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      IF vr_vltarres > 0  THEN
        --> Gera Tarifa de resgate
        TARI0001.pc_cria_lan_auto_tarifa (pr_cdcooper => pr_cdcooper          --Codigo Cooperativa
                                         ,pr_nrdconta => rw_craptdb.nrdconta  --Numero da Conta
                                         ,pr_dtmvtolt => pr_dtresgat          --Data Lancamento
                                         ,pr_cdhistor => vr_cdhistor          --Codigo Historico
                                         ,pr_vllanaut => vr_vltarres          --Valor lancamento automatico
                                         ,pr_cdoperad => pr_cdoperad          --Codigo Operador
                                         ,pr_cdagenci => 1                    --Codigo Agencia
                                         ,pr_cdbccxlt => 100                  --Codigo banco caixa
                                         ,pr_nrdolote => 8452                 --Numero do lote
                                         ,pr_tpdolote => 1                    --Tipo do lote
                                         ,pr_nrdocmto => 0                    --Numero do documento
                                         ,pr_nrdctabb => rw_craptdb.nrdconta  --Numero da conta
                                         ,pr_nrdctitg => gene0002.fn_mask(rw_craptdb.nrdconta,'99999999') --Numero da conta integracao
                                         ,pr_cdpesqbb => 'Fato gerador tarifa:'||rw_craptdb.nrdocmto      --Codigo pesquisa
                                         ,pr_cdbanchq => 0                    --Codigo Banco Cheque
                                         ,pr_cdagechq => 0                    --Codigo Agencia Cheque
                                         ,pr_nrctachq => 0                    --Numero Conta Cheque
                                         ,pr_flgaviso => FALSE                --Flag aviso
                                         ,pr_tpdaviso => 0                    --Tipo aviso
                                         ,pr_cdfvlcop => vr_cdfvlcop          --Codigo cooperativa
                                         ,pr_inproces => pr_inproces          --Indicador processo
                                         ,pr_rowid_craplat => vr_rowid_craplat --Rowid do lancamento tarifa
                                         ,pr_tab_erro => vr_tab_erro          --Tabela retorno erro
                                         ,pr_cdcritic => vr_cdcritic          --Codigo Critica
                                         ,pr_dscritic => vr_dscritic);        --Descricao Critica
        --Se ocorreu erro
        IF nvl(vr_cdcritic,0) > 0 OR
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

      END IF;

      --**** RECALCULO DO TITULO(COBRANCA DE JUROS DE RESGATE) ****
      IF rw_craptdb.dtvencto > pr_dtmvtoan AND
         rw_craptdb.dtvencto < pr_dtresgat THEN
        vr_qtdprazo := rw_craptdb.dtvencto - rw_crapbdt.dtlibbdt;
      ELSE
        vr_qtdprazo := pr_dtresgat - rw_crapbdt.dtlibbdt;
      END IF;

      vr_vltitulo := rw_craptdb.vltitulo;
      vr_dtperiod := rw_crapbdt.dtlibbdt;
      vr_vldjuros := 0;
      vr_vljurper := 0;
      vr_vlliqori := rw_craptdb.vlliquid;
      vr_tab_crawljt.delete;

      /* Restituicao nao no mesmo dia da Liberacao */
      IF vr_qtdprazo > 0 THEN
        FOR vr_contador IN 1..vr_qtdprazo LOOP
          vr_vldjuros := apli0001.fn_round(vr_vltitulo * vr_txdiaria,2);
          vr_vltitulo := vr_vltitulo + vr_vldjuros;
          vr_dtperiod := vr_dtperiod + 1;
          vr_dtrefjur := last_day(vr_dtperiod);

          --Marcar que nao encontrou
          vr_flgachou:= FALSE;
          --Selecionar Lancamento Juros Desconto Titulo
          FOR idx IN 1..vr_tab_crawljt.Count LOOP
            IF vr_tab_crawljt(idx).cdcooper = rw_craptdb.cdcooper AND
               vr_tab_crawljt(idx).nrdconta = rw_craptdb.nrdconta AND
               vr_tab_crawljt(idx).nrborder = rw_craptdb.nrborder AND
               vr_tab_crawljt(idx).dtrefere = vr_dtrefjur         AND
               vr_tab_crawljt(idx).cdbandoc = rw_craptdb.cdbandoc AND
               vr_tab_crawljt(idx).nrdctabb = rw_craptdb.nrdctabb AND
               vr_tab_crawljt(idx).nrcnvcob = rw_craptdb.nrcnvcob AND
               vr_tab_crawljt(idx).nrdocmto = rw_craptdb.nrdocmto THEN
              --Marcar que encontrou
              vr_flgachou:= TRUE;
              --Acumular valor juros
              vr_tab_crawljt(idx).vldjuros:= vr_tab_crawljt(idx).vldjuros + vr_vldjuros;
            END IF;
          END LOOP;

          /*Se nao encontrou cria */
          IF NOT vr_flgachou THEN
            --Selecionar indice
            vr_incrawljt:= vr_tab_crawljt.Count+1;
            --Gravar dados tabela memoria
            vr_tab_crawljt(vr_incrawljt).cdcooper:= rw_craptdb.cdcooper;
            vr_tab_crawljt(vr_incrawljt).nrdconta:= rw_craptdb.nrdconta;
            vr_tab_crawljt(vr_incrawljt).nrborder:= rw_craptdb.nrborder;
            vr_tab_crawljt(vr_incrawljt).dtrefere:= vr_dtrefjur;
            vr_tab_crawljt(vr_incrawljt).cdbandoc:= rw_craptdb.cdbandoc;
            vr_tab_crawljt(vr_incrawljt).nrdctabb:= rw_craptdb.nrdctabb;
            vr_tab_crawljt(vr_incrawljt).nrcnvcob:= rw_craptdb.nrcnvcob;
            vr_tab_crawljt(vr_incrawljt).nrdocmto:= rw_craptdb.nrdocmto;
            vr_tab_crawljt(vr_incrawljt).vldjuros:= vr_vldjuros;
          END IF;
        END LOOP;  --vr_contador IN 1..vr_qtdprazo

        vr_vlliqnov := rw_craptdb.vltitulo - (vr_vltitulo - rw_craptdb.vltitulo);

        --> Atualiza registro de provisao de juros ..........
        FOR idx IN 1..vr_tab_crawljt.Count LOOP
          --Se for a mesma cooperativa
          IF vr_tab_crawljt(idx).cdcooper = pr_cdcooper THEN
            BEGIN
              --Selecionar lancamento juros desconto titulo
              OPEN cr_crapljt (pr_cdcooper => vr_tab_crawljt(idx).cdcooper
                              ,pr_nrdconta => vr_tab_crawljt(idx).nrdconta
                              ,pr_nrborder => vr_tab_crawljt(idx).nrborder
                              ,pr_dtrefere => vr_tab_crawljt(idx).dtrefere
                              ,pr_cdbandoc => vr_tab_crawljt(idx).cdbandoc
                              ,pr_nrdctabb => vr_tab_crawljt(idx).nrdctabb
                              ,pr_nrcnvcob => vr_tab_crawljt(idx).nrcnvcob
                              ,pr_nrdocmto => vr_tab_crawljt(idx).nrdocmto);

              FETCH cr_crapljt INTO rw_crapljt;
              vr_fcrapljt := cr_crapljt%FOUND;
              CLOSE cr_crapljt;
            EXCEPTION
              WHEN OTHERS THEN
                vr_fcrapljt := FALSE;
            END;

            -- Verificar se encontrou o registro
            IF vr_fcrapljt = FALSE THEN
              vr_dscritic := 'Registro crapljt nao encontrado.';
              RAISE vr_exc_erro;
            END IF;

            --Se o valor dos juros mudou
            IF rw_crapljt.vldjuros <> vr_tab_crawljt(idx).vldjuros THEN
              --Se valor juros tabela eh maior encontrado
              IF  rw_crapljt.vldjuros > vr_tab_crawljt(idx).vldjuros THEN
                --Atualizar tabela juros
                BEGIN
                  UPDATE crapljt SET crapljt.vlrestit = NVL(crapljt.vldjuros,0) - NVL(vr_tab_crawljt(idx).vldjuros,0)
                                    ,crapljt.vldjuros = nvl(vr_tab_crawljt(idx).vldjuros,0)
                  WHERE crapljt.ROWID = rw_crapljt.ROWID
                  RETURNING crapljt.vlrestit INTO rw_crapljt.vlrestit;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Erro ao atualizar tabela crapljt. '||sqlerrm;
                    --Levantar Excecao
                    RAISE vr_exc_erro;
                END;
              ELSE
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro - Juros negativo: '||rw_crapljt.vldjuros;
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
            END IF;
            --Data de Referencia
            vr_dtultdat:= vr_tab_crawljt(idx).dtrefere;
            --Excluir registro da tabela memoria
            vr_tab_crawljt.DELETE(idx);
          END IF;
        END LOOP;

      ELSE
        vr_dtultdat := pr_dtresgat;
        vr_vlliqori := rw_craptdb.vlliquid;
        vr_vlliqnov := rw_craptdb.vltitulo;
      END IF;-- Fim IF vr_qtdprazo > 0 THEN

      --Selecionar lancamento juros desconto titulo
      FOR rw_craplj IN cr_crapljt2 ( pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => rw_craptdb.nrdconta
                                    ,pr_nrborder => rw_craptdb.nrborder
                                    ,pr_dtrefere => vr_dtultdat
                                    ,pr_cdbandoc => rw_craptdb.cdbandoc
                                    ,pr_nrdctabb => rw_craptdb.nrdctabb
                                    ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                    ,pr_nrdocmto => rw_craptdb.nrdocmto) LOOP



        --Atualizar tabela juros
        BEGIN
          UPDATE crapljt
             SET crapljt.vlrestit = crapljt.vldjuros
                ,crapljt.vldjuros = 0
          WHERE crapljt.ROWID = rw_crapljt.ROWID
          RETURNING crapljt.vlrestit INTO rw_crapljt.vlrestit;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar tabela crapljt. '||sqlerrm;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
      END LOOP; -- Fim loop rw_craplj

      -->>>  CRIA LANCAMENTO NO CONTA-CORRENTE <<<--

      --> Lockar a tabela de lote
      FOR i IN 1..10 LOOP
        BEGIN
          --> Busca lote
          OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                          ,pr_dtmvtolt => pr_dtresgat
                          ,pr_cdagenci => 1
                          ,pr_cdbccxlt => 100
                          ,pr_nrdolote => 10300);
          --Posicionar no proximo registro
          FETCH cr_craplot INTO rw_craplot;
          vr_fcraplot := cr_craplot%FOUND;
          CLOSE cr_craplot;

          vr_dscritic := NULL;
          --sair do loop
          EXIT;

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Registro de lote esta sendo usado no momento.';
            CLOSE cr_craplot;
            dbms_lock.sleep(1);
            continue;
        END;
      END LOOP;

      --> Verificar se saiu do loop com critica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      --> Verificar se encontrou o lote
      IF vr_fcraplot = FALSE THEN
        BEGIN
          INSERT INTO craplot
                       (dtmvtolt,
                        cdagenci,
                        cdbccxlt,
                        nrdolote,
                        tplotmov,
                        cdoperad,
                        cdhistor,
                        cdcooper)
                 VALUES( pr_dtresgat   -- dtmvtolt
                        ,1             -- cdagenci
                        ,100           -- cdbccxlt
                        ,10300         -- nrdolote
                        ,1             -- tplotmov
                        ,pr_cdoperad   -- cdoperad
                        ,687           -- cdhistor
                        ,pr_cdcooper)  -- cdcooper
               RETURNING craplot.rowid,
                         craplot.dtmvtolt,
                         craplot.cdagenci,
                         craplot.cdbccxlt,
                         craplot.nrdolote
                    INTO rw_craplot.rowid,
                         rw_craplot.dtmvtolt,
                         rw_craplot.cdagenci,
                         rw_craplot.cdbccxlt,
                         rw_craplot.nrdolote;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possivel inserir lote: '||SQLERRM;
            RAISE vr_exc_erro;
        END;
      END IF;

      vr_vllanmto := rw_craptdb.vltitulo - (vr_vlliqnov - vr_vlliqori);

      --> Atualizar lote
      BEGIN
        UPDATE craplot
           SET craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
              ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
              ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
              ,craplot.vlinfodb = nvl(craplot.vlinfodb,0) + nvl(vr_vllanmto,0)
              ,craplot.vlcompdb = nvl(craplot.vlcompdb,0) + nvl(vr_vllanmto,0)
         WHERE craplot.rowid = rw_craplot.rowid
        RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel atualizar lote: '||SQLERRM;
          RAISE vr_exc_erro;
      END;

      --> Cria lancamento da conta do associado ..................
      BEGIN
        INSERT INTO craplcm
                    (dtmvtolt,
                     cdagenci,
                     cdbccxlt,
                     nrdolote,
                     nrdconta,
                     nrdocmto,
                     vllanmto,
                     cdhistor,
                     nrseqdig,
                     nrdctabb,
                     nrautdoc,
                     cdpesqbb,
                     cdcooper)
             VALUES (rw_craplot.dtmvtolt               -- dtmvtolt
                    ,rw_craplot.cdagenci               -- cdagenci
                    ,rw_craplot.cdbccxlt               -- cdbccxlt
                    ,rw_craplot.nrdolote               -- nrdolote
                    ,rw_craptdb.nrdconta               -- nrdconta
                    ,rw_craplot.nrseqdig               -- nrdocmto
                    ,vr_vllanmto                       -- vllanmto
                    ,687                               -- cdhistor
                    ,rw_craplot.nrseqdig               -- nrseqdig
                    ,rw_craptdb.nrdconta               -- nrdctabb
                    ,0                                 -- nrautdoc
                    ,rw_craptdb.nrdocmto               -- cdpesqbb
                    ,pr_cdcooper);                     -- cdcooper

      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel inserir lancamento: '||SQLERRM;
          RAISE vr_exc_erro;
      END;

      --> Atualizar Titulo do Bordero de desconto
      BEGIN
        UPDATE craptdb
           SET craptdb.insittit = 1 --> resgatado
              ,craptdb.dtdpagto = NULL
              ,craptdb.dtresgat = pr_dtresgat
              ,craptdb.cdoperes = pr_cdoperad
              ,craptdb.vlliqres = vr_vlliqnov
         WHERE craptdb.rowid = rw_craptdb.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel atualizar Titulo do Bordero de desconto: '||SQLERRM;
          RAISE vr_exc_erro;
      END;

      --Buscar informacoes Cobranca
      OPEN cr_crapcob (pr_cdcooper => rw_craptdb.cdcooper
                      ,pr_cdbandoc => rw_craptdb.cdbandoc
                      ,pr_nrdctabb => rw_craptdb.nrdctabb
                      ,pr_nrdconta => rw_craptdb.nrdconta
                      ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                      ,pr_nrdocmto => rw_craptdb.nrdocmto
                      ,pr_flgregis => 1);
      FETCH cr_crapcob INTO rw_crapcob;
      --Se nao encontrar
      IF cr_crapcob%FOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcob;

        --Criar log Cobranca
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.ROWID    -- ROWID da Cobranca
                                     ,pr_cdoperad => pr_cdoperad         -- Operador
                                     ,pr_dtmvtolt => pr_dtmvtolt         -- Data movimento
                                     ,pr_dsmensag => 'Titulo Resgatado'  -- Descricao Mensagem
                                     ,pr_des_erro => vr_des_erro         -- Indicador erro
                                     ,pr_dscritic => vr_dscritic);       -- Descricao erro
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
      --Fechar Cursor
      IF cr_crapcob%ISOPEN THEN
        CLOSE cr_crapcob;
      END IF;

      --> Verifica se deve liquidar o bordero caso sim Liquida
      DSCT0001.pc_efetua_liquidacao_bordero (pr_cdcooper => pr_cdcooper  --Codigo Cooperativa
                                            ,pr_cdagenci => pr_cdagenci  --Codigo Agencia
                                            ,pr_nrdcaixa => pr_nrdcaixa  --Numero do Caixa
                                            ,pr_cdoperad => pr_cdoperad  --Codigo Operador
                                            ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                            ,pr_idorigem => pr_idorigem  --Identificador Origem
                                            ,pr_nrdconta => pr_nrdconta  --Numero da Conta
                                            ,pr_nrborder => rw_craptdb.nrborder  --Numero do Bordero
                                            ,pr_tab_erro => vr_tab_erro   --Tabela de erros
                                            ,pr_des_erro => vr_des_erro   --identificador de erro
                                            ,pr_dscritic => vr_dscritic); --Descricao do erro;
      --Se ocorreu erro
      IF vr_des_erro = 'NOK' THEN

        IF vr_dscritic IS NULL THEN
          --Mensagem erro
          vr_dscritic:= 'Erro na liquidacao do bordero '||
                        rw_craptdb.nrborder||' conta '||rw_craptdb.nrdconta;
        END IF;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      --Proximo registro
      vr_idxtit:= pr_tab_titulos.NEXT(vr_idxtit);
    END LOOP;

  EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK TO vr_resgate;
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;

    WHEN OTHERS THEN
      ROLLBACK TO vr_resgate;
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina DSCT0001.pc_efetua_resgate_tit_bord. '||SQLERRM;

  END pc_efetua_resgate_tit_bord;

  /* Rotina referente a consulta de avalistas, procuradores e representantes */
  PROCEDURE pc_busca_total_descto_lim(pr_cdcooper IN INTEGER  --Codigo Cooperativa
                                     ,pr_cdagenci IN INTEGER  --Codigo da agencia
                                     ,pr_nrdcaixa IN INTEGER  --Numero do caixa
                                     ,pr_cdoperad IN VARCHAR2 --codigo do operador
                                     ,pr_dtmvtolt IN DATE     --Data do movimento
                                     ,pr_nrdconta IN INTEGER  --Numero da conta
                                     ,pr_idseqttl IN INTEGER  --idseqttl
                                     ,pr_idorigem IN INTEGER  --Codigo da origem
                                     ,pr_nmdatela IN VARCHAR2 --Nome da tela
                                     ,pr_nrctrlim IN VARCHAR2 --Numero do contrato
                                     ,pr_tab_tot_descontos OUT dsct0001.typ_tab_tot_descontos --Tabela Desconto de Títulos
                                     ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2    --> Descrição da crítica
                                     ,pr_tab_erro OUT GENE0001.typ_tab_erro) IS --Tabela erros
  BEGIN

    /* ................................................................................

     Programa: pc_busca_total_descto_lim       Antiga: b1wgen0030.p/busca_total_descto_lim
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED

     Autor   : Jéssica Laverde Gracino(DB1)
     Data    : 18/06/2015                        Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado
     Objetivo  : Buscar valor total da divida em desconto a partir do numero do craplim

     Alteracoes: 18/06/2015 - Conversao Progress >> Oracle (PLSQL) - Jéssica (DB1)
    ..................................................................................*/
    DECLARE

      -- Borderos de Desconto de Titulos
      CURSOR cr_crapbdt (pr_cdcooper IN crapbdt.cdcooper%TYPE,
                         pr_nrdconta IN craplim.nrdconta%TYPE,
                         pr_nrctrlim IN craplim.nrctrlim%TYPE) IS
        SELECT craptdb.nrctrlim,
               craptdb.nrborder,
               craptdb.nrdconta,
               craptdb.vltitulo,
               crapbdt.dtmvtolt,
               crapbdt.cdagenci,
               crapbdt.cdbccxlt,
               crapbdt.nrdolote,
               craptdb.dtlibbdt,
               craptdb.cdoperad
          FROM crapbdt,
               craptdb
         WHERE craptdb.cdcooper = pr_cdcooper
           AND craptdb.nrdconta = pr_nrdconta
           AND crapbdt.nrctrlim = pr_nrctrlim
           AND (craptdb.cdcooper  = crapbdt.cdcooper
           AND  craptdb.nrdconta  = crapbdt.nrdconta
           AND  craptdb.nrborder  = crapbdt.nrborder
           AND  craptdb.insittit =  4)
            OR (craptdb.cdcooper  = crapbdt.cdcooper
           AND  craptdb.nrdconta  = crapbdt.nrdconta
           AND  craptdb.nrborder  = crapbdt.nrborder
           AND  craptdb.insittit = 2
           AND  craptdb.dtdpagto = rw_crapdat.dtmvtolt);
      rw_crapbdt cr_crapbdt%ROWTYPE;

      -- Cursor sobre a tabela de limite de credito
      CURSOR cr_craplim (pr_cdcooper IN craplim.cdcooper%TYPE,
                         pr_nrdconta IN craplim.nrdconta%TYPE,
                         pr_nrctrlim IN craplim.tpctrlim%TYPE) IS
        SELECT craplim.insitlim
              ,craplim.nrdconta
              ,craplim.nrctrlim
              ,craplim.tpctrlim
              ,craplim.dtinivig
              ,craplim.vllimite
          FROM craplim
         WHERE craplim.cdcooper = pr_cdcooper
           AND craplim.nrdconta = pr_nrdconta
           AND craplim.tpctrlim = 3
           AND craplim.nrctrlim = pr_nrctrlim;
      rw_craplim cr_craplim%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      --Variaveis de Excecao
      vr_exc_erro    EXCEPTION;

      --Tabela de memoria de erros
      vr_tab_erro GENE0001.typ_tab_erro;

      --Variaveis de Indice
      vr_index PLS_INTEGER;

      -- Variaveis de log
      vr_cdcooper      NUMBER;
      vr_cdoperad      VARCHAR2(100);
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);

      BEGIN

        --Inicializar Variaveis
        vr_cdcritic:= 0;
        vr_dscritic:= null;
        vr_index := 0;

        --Limpar tabela dados
        pr_tab_tot_descontos.DELETE;

        OPEN cr_craplim (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta,
                         pr_nrctrlim => pr_nrctrlim);

        FETCH cr_craplim INTO rw_craplim;

        -- Se encontrar registro
        IF cr_craplim%FOUND THEN

          vr_index := vr_index + 1;
          pr_tab_tot_descontos(vr_index).vllimtit := rw_craplim.vllimite;

        ELSE
          CLOSE cr_craplim;
        END IF;

        --CLOSE cr_craplim;


        pr_tab_tot_descontos(vr_index).vldsctit := 0;
        pr_tab_tot_descontos(vr_index).qtdsctit := 0;
        pr_tab_tot_descontos(vr_index).vlmaxtit := 0;
        pr_tab_tot_descontos(vr_index).vltotdsc := 0;
        pr_tab_tot_descontos(vr_index).qttotdsc := 0;

        FOR rw_crapbdt IN cr_crapbdt(pr_cdcooper,
                                     pr_nrdconta,
                                     pr_nrctrlim) LOOP

          pr_tab_tot_descontos(vr_index).vldsctit := pr_tab_tot_descontos(vr_index).vldsctit + rw_crapbdt.vltitulo;
          pr_tab_tot_descontos(vr_index).qtdsctit := pr_tab_tot_descontos(vr_index).qtdsctit + 1;

          IF rw_crapbdt.vltitulo > pr_tab_tot_descontos(vr_index).vlmaxtit THEN
            pr_tab_tot_descontos(vr_index).vlmaxtit := rw_crapbdt.vltitulo;
          ELSE
            pr_tab_tot_descontos(vr_index).vlmaxtit := pr_tab_tot_descontos(vr_index).vlmaxtit;
          END IF;

          pr_tab_tot_descontos(vr_index).vltotdsc := pr_tab_tot_descontos(vr_index).vltotdsc + rw_crapbdt.vltitulo;
          pr_tab_tot_descontos(vr_index).qttotdsc := pr_tab_tot_descontos(vr_index).qttotdsc + 1;

        END LOOP; -- for rw_crapbdt

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;

        -- Se nao tiver gerado a tabela de erro, gera a mesma
        IF vr_tab_erro.count = 0 THEN
          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 /** Sequencia **/
                               ,pr_cdcritic => pr_cdcritic
                               ,pr_dscritic => pr_dscritic
                               ,pr_tab_erro => vr_tab_erro);
        END IF;

      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina DSCT0001.pc_busca_total_descto_lim. '||sqlerrm;

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => pr_dscritic
                             ,pr_tab_erro => vr_tab_erro);

    END;


  END pc_busca_total_descto_lim;

  /* Buscar a soma total de descontos (titulos + cheques)  */
  PROCEDURE pc_busca_total_descontos(pr_cdcooper IN INTEGER        --> Codigo Cooperativa
                                     ,pr_cdagenci IN INTEGER       --> Codigo da agencia
                                     ,pr_nrdcaixa IN INTEGER       --> Numero do caixa
                                     ,pr_cdoperad IN VARCHAR2      --> codigo do operador
                                     ,pr_dtmvtolt IN DATE          --> Data do movimento
                                     ,pr_nrdconta IN INTEGER       --> Numero da conta
                                     ,pr_idseqttl IN INTEGER       --> idseqttl
                                     ,pr_idorigem IN INTEGER       --> Codigo da origem
                                     ,pr_nmdatela IN VARCHAR2      --> Nome da tela
                                     ,pr_flgerlog IN VARCHAR2      --> identificador se deve gerar log S-Sim e N-Nao
                                     ,pr_cdcritic OUT PLS_INTEGER  --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2     --> Descrição da crítica
                                     ,pr_tab_tot_descontos OUT typ_tab_tot_descontos --Totais de desconto
                                     ) IS
    /* ................................................................................

     Programa: pc_busca_total_descontos       Antiga: b1wgen0030.p/busca_total_descontos
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED

     Autor   : Odirlei Busana(AMcom)
     Data    : 16/10/2015                        Ultima atualizacao: 16/10/2015

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado
     Objetivo  : Buscar a soma total de descontos (titulos + cheques)

     Alteracoes: 16/10/2015 - Conversao Progress >> Oracle (PLSQL) - Odirlei(AMcom)
    ..................................................................................*/
    ------------------> CURSORES <------------------

    --> Busca saldo e limite de desconto de cheques
    CURSOR cr_craplim(pr_tpctrlim craplim.tpctrlim%TYPE) IS
    select /*+index_asc (craplim CRAPLIM##CRAPLIM1)*/
           lim.nrdconta
          ,lim.vllimite
    from   craplim lim
    where  lim.insitlim = 2
    and    lim.cdcooper = pr_cdcooper
    and    lim.nrdconta = pr_nrdconta
    and    lim.tpctrlim = pr_tpctrlim
    and    pr_tpctrlim <> 3
    
    union  all
    
    select /*+index_asc (crawlim CRAWLIM##CRAWLIM1)*/
           lim.nrdconta
          ,lim.vllimite
    from   crawlim lim
    where  lim.insitlim = 2
    and    lim.cdcooper = pr_cdcooper
    and    lim.nrdconta = pr_nrdconta
    and    lim.tpctrlim = pr_tpctrlim
    and    pr_tpctrlim  = 3;
    rw_craplim cr_craplim%ROWTYPE;

    --> Busca Cheques contidos do Bordero de desconto de cheques
    CURSOR cr_crapcdb IS
      SELECT crapcdb.nrdconta,
             crapcdb.vlcheque
        FROM crapcdb
       WHERE crapcdb.cdcooper = pr_cdcooper
         AND crapcdb.nrdconta = pr_nrdconta
         AND crapcdb.insitchq = 2
         AND crapcdb.dtlibera > pr_dtmvtolt;

    /*Titulos que estao em desconto liberados ou que foram pagos na data atual*/
    CURSOR cr_craptdb IS
      SELECT craptdb.vltitulo
        FROM craptdb
       WHERE (craptdb.cdcooper = pr_cdcooper AND
              craptdb.nrdconta = pr_nrdconta AND
              craptdb.insittit = 4)
          OR (craptdb.cdcooper = pr_cdcooper AND
              craptdb.nrdconta = pr_nrdconta AND
              craptdb.insittit = 2 AND
              craptdb.dtdpagto = pr_dtmvtolt);

    -------------> VAIAVEIS <-----------
    vr_idx PLS_INTEGER;
    vr_dsorigem VARCHAR2(50);
    vr_dstransa VARCHAR2(200);
    vr_nrdrowid ROWID;

  BEGIN

    IF pr_flgerlog = 'S' THEN
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa := 'Listar ocorrencias.';
    END IF;

    vr_idx := pr_tab_tot_descontos.count + 1;
    pr_tab_tot_descontos(vr_idx).qttotdsc := 0;

    --> Cheques
    --> Busca saldo e limite de desconto de cheques
    OPEN cr_craplim(pr_tpctrlim => 2);
    FETCH cr_craplim INTO rw_craplim;

    IF cr_craplim%FOUND THEN
      pr_tab_tot_descontos(vr_idx).vllimchq := rw_craplim.vllimite;
    END IF;
    CLOSE cr_craplim;

    --> Busca Cheques contidos do Bordero de desconto de cheques
    FOR rw_crapcdb IN cr_crapcdb LOOP

     pr_tab_tot_descontos(vr_idx).vldscchq := nvl(pr_tab_tot_descontos(vr_idx).vldscchq,0) + rw_crapcdb.vlcheque;
     pr_tab_tot_descontos(vr_idx).vltotdsc := nvl(pr_tab_tot_descontos(vr_idx).vltotdsc,0) + rw_crapcdb.vlcheque;
     pr_tab_tot_descontos(vr_idx).qtdscchq := nvl(pr_tab_tot_descontos(vr_idx).qtdscchq,0) + 1;
     pr_tab_tot_descontos(vr_idx).qttotdsc := nvl(pr_tab_tot_descontos(vr_idx).qttotdsc,0) + 1;

    END LOOP;

    --> Titulos
    --> Busca saldo e limite de desconto de titulos
    OPEN cr_craplim(pr_tpctrlim => 3);
    FETCH cr_craplim INTO rw_craplim;

    IF cr_craplim%FOUND THEN
      pr_tab_tot_descontos(vr_idx).vllimtit := rw_craplim.vllimite;
    END IF;
    CLOSE cr_craplim;

    --> Titulos que estao em desconto liberados ou que foram pagos na data atual
    FOR rw_craptdb IN cr_craptdb LOOP
      pr_tab_tot_descontos(vr_idx).vldsctit := nvl(pr_tab_tot_descontos(vr_idx).vldsctit,0) + rw_craptdb.vltitulo;
      pr_tab_tot_descontos(vr_idx).qtdsctit := pr_tab_tot_descontos(vr_idx).qtdsctit + 1;

      IF rw_craptdb.vltitulo > nvl(pr_tab_tot_descontos(vr_idx).vlmaxtit,0)  THEN
        pr_tab_tot_descontos(vr_idx).vlmaxtit := nvl(rw_craptdb.vltitulo,0);
      ELSE
        pr_tab_tot_descontos(vr_idx).vlmaxtit := nvl(pr_tab_tot_descontos(vr_idx).vlmaxtit,0);
      END IF;

      pr_tab_tot_descontos(vr_idx).vltotdsc := nvl(pr_tab_tot_descontos(vr_idx).vltotdsc,0) + rw_craptdb.vltitulo;
      pr_tab_tot_descontos(vr_idx).qttotdsc := nvl(pr_tab_tot_descontos(vr_idx).qttotdsc,0) + 1;

    END LOOP;

    -- Se foi solicitado log
    IF pr_flgerlog = 'S' THEN
      -- Gerar LOG
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => NULL
                          ,pr_dsorigem => vr_dsorigem --> Origem enviada
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => pr_dtmvtolt
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao buscar total de descontos(DST0001): '||SQLERRM;

      -- Se foi solicitado log
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => pr_dscritic
                            ,pr_dsorigem => vr_dsorigem --> Origem enviada
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 0
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;

  END pc_busca_total_descontos;

  /* Procedure para efetuar estorno da baixa do titulo por pagamento - Demetrius Wolff - Mouts */
  PROCEDURE pc_efetua_estorno_baixa_titulo (pr_cdcooper    IN INTEGER --Codigo Cooperativa
                                           ,pr_cdagenci    IN INTEGER --Codigo Agencia
                                           ,pr_nrdcaixa    IN INTEGER --Numero Caixa
                                           ,pr_cdoperad    IN VARCHAR2 --Codigo operador
                                           ,pr_dtmvtolt    IN DATE     --Data Movimento
                                           ,pr_idorigem    IN INTEGER  --Identificador Origem pagamento
                                           ,pr_nrdconta    IN INTEGER  --Numero da conta
                                           ,pr_tab_titulos IN PAGA0001.typ_tab_titulos --Titulos a serem baixados
                                           ,pr_cdcritic    OUT INTEGER     --Codigo Critica
                                           ,pr_dscritic    OUT VARCHAR2     --Descricao Critica
                                           ,pr_tab_erro    OUT GENE0001.typ_tab_erro) IS --Tabela erros
      --Selecionar informacoes dos titulos do bordero
      CURSOR cr_craptdb (pr_cdcooper IN craptdb.cdcooper%type
                        ,pr_cdbandoc IN craptdb.cdbandoc%type
                        ,pr_nrdctabb IN craptdb.nrdctabb%type
                        ,pr_nrcnvcob IN craptdb.nrcnvcob%type
                        ,pr_nrdconta IN craptdb.nrdconta%type
                        ,pr_nrdocmto IN craptdb.nrdocmto%type
                        ,pr_insittit IN craptdb.insittit%type) IS
        SELECT craptdb.dtvencto
              ,craptdb.vltitulo
              ,craptdb.nrdconta
              ,craptdb.nrdocmto
              ,craptdb.cdcooper
              ,craptdb.insittit
              ,craptdb.dtdpagto
              ,craptdb.nrborder
              ,craptdb.dtlibbdt
              ,craptdb.cdbandoc
              ,craptdb.nrdctabb
              ,craptdb.nrcnvcob
              ,craptdb.rowid
              ,COUNT(*) OVER (PARTITION BY craptdb.cdcooper) qtdreg
        FROM craptdb
        WHERE craptdb.cdcooper = pr_cdcooper
        AND   craptdb.cdbandoc = pr_cdbandoc
        AND   craptdb.nrdctabb = pr_nrdctabb
        AND   craptdb.nrcnvcob = pr_nrcnvcob
        AND   craptdb.nrdconta = pr_nrdconta
        AND   craptdb.nrdocmto = pr_nrdocmto
        AND   craptdb.insittit = pr_insittit;
      rw_craptdb cr_craptdb%ROWTYPE;

      CURSOR cr_craplcm (pr_cdcooper IN craplcm.cdcooper%TYPE
                        ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
                        ,pr_cdagenci IN craplcm.cdagenci%TYPE
                        ,pr_cdbccxlt IN craplcm.cdbccxlt%TYPE
                        ,pr_nrdolote IN craplcm.nrdolote%TYPE
                        ,pr_nrdctabb IN craplcm.nrdctabb%TYPE
                        ,pr_cdhistor IN craplcm.cdhistor%TYPE
                        ,pr_cdpesqbb IN craplcm.cdpesqbb%TYPE) IS
        SELECT craplcm.rowid
              ,craplcm.vllanmto
        FROM craplcm craplcm
        WHERE craplcm.cdcooper = pr_cdcooper
        AND   craplcm.dtmvtolt = pr_dtmvtolt
        AND   craplcm.cdagenci = pr_cdagenci
        AND   craplcm.cdbccxlt = pr_cdbccxlt
        AND   craplcm.nrdolote = pr_nrdolote
        AND   craplcm.nrdctabb = pr_nrdctabb
        AND   craplcm.cdhistor = pr_cdhistor
        AND   craplcm.cdpesqbb = pr_cdpesqbb;
      rw_craplcm cr_craplcm%ROWTYPE;

      CURSOR cr_crablcm (pr_cdcooper IN craplcm.cdcooper%TYPE
                        ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
                        ,pr_cdagenci IN craplcm.cdagenci%TYPE
                        ,pr_cdbccxlt IN craplcm.cdbccxlt%TYPE
                        ,pr_nrdolote IN craplcm.nrdolote%TYPE
                        ,pr_nrdctabb IN craplcm.nrdctabb%TYPE
                        ,pr_cdhisto1 IN craplcm.cdhistor%TYPE
                        ,pr_cdhisto2 IN craplcm.cdhistor%TYPE
                        ,pr_cdpesqbb IN craplcm.cdpesqbb%TYPE) IS
        SELECT craplcm.rowid
              ,craplcm.vllanmto
        FROM craplcm
        WHERE craplcm.cdcooper = pr_cdcooper
        AND   craplcm.dtmvtolt = pr_dtmvtolt
        AND   craplcm.cdagenci = pr_cdagenci
        AND   craplcm.cdbccxlt = pr_cdbccxlt
        AND   craplcm.nrdolote = pr_nrdolote
        AND   craplcm.nrdctabb = pr_nrdctabb
        AND   craplcm.cdhistor in (pr_cdhisto1,pr_cdhisto2)
        AND   craplcm.cdpesqbb = pr_cdpesqbb;
      rw_crablcm cr_crablcm%ROWTYPE;

      CURSOR cr_craplot (pr_cdcooper IN craplcm.cdcooper%TYPE
                        ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
                        ,pr_cdagenci IN craplcm.cdagenci%TYPE
                        ,pr_cdbccxlt IN craplcm.cdbccxlt%TYPE
                        ,pr_nrdolote IN craplcm.nrdolote%TYPE) IS
        SELECT craplot.rowid
              ,craplot.qtcompln
        FROM craplot
        WHERE craplot.cdcooper = pr_cdcooper
        AND   craplot.dtmvtolt = pr_dtmvtolt
        AND   craplot.cdagenci = pr_cdagenci
        AND   craplot.cdbccxlt = pr_cdbccxlt
        AND   craplot.nrdolote = pr_nrdolote;
      rw_craplot cr_craplot%ROWTYPE;

      --Selecionar Bordero de titulos
      CURSOR cr_crapbdt (pr_cdcooper IN crapbdt.cdcooper%type
                        ,pr_nrborder IN crapbdt.nrborder%type) IS
        SELECT crapbdt.rowid
        FROM crapbdt
        WHERE crapbdt.cdcooper = pr_cdcooper
        AND   crapbdt.nrborder = pr_nrborder;
      rw_crapbdt cr_crapbdt%ROWTYPE;

      --Selecionar lancamento juros desconto titulo
      CURSOR cr_crapljt (pr_cdcooper IN crapljt.cdcooper%type
                        ,pr_nrdconta IN crapljt.nrdconta%type
                        ,pr_nrborder IN crapljt.nrborder%type
                        ,pr_dtrefere IN crapljt.dtrefere%type
                        ,pr_cdbandoc IN crapljt.cdbandoc%type
                        ,pr_nrdctabb IN crapljt.nrdctabb%type
                        ,pr_nrcnvcob IN crapljt.nrcnvcob%type
                        ,pr_nrdocmto IN crapljt.nrdocmto%TYPE
                        ,pr_tipo     IN INTEGER) IS
        SELECT crapljt.rowid
              ,crapljt.vldjuros
              ,crapljt.vlrestit
        FROM crapljt
        WHERE crapljt.cdcooper = pr_cdcooper
        AND   crapljt.nrdconta = pr_nrdconta
        AND   crapljt.nrborder = pr_nrborder
        AND   ((pr_tipo = 1 AND crapljt.dtrefere = pr_dtrefere) OR
               (pr_tipo = 2 AND crapljt.dtrefere > pr_dtrefere))
        AND   crapljt.cdbandoc = pr_cdbandoc
        AND   crapljt.nrdctabb = pr_nrdctabb
        AND   crapljt.nrcnvcob = pr_nrcnvcob
        AND   crapljt.nrdocmto = pr_nrdocmto;
      rw_crapljt cr_crapljt%ROWTYPE;


      --Variaveis locais
      vr_index_titulo VARCHAR2(20);
      vr_flgdsair     BOOLEAN;
      --Variaveis de erro
      vr_des_erro     VARCHAR2(4000);
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Tipo de registro para datas
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      --Tabela de memoria de erros
      vr_tab_erro GENE0001.typ_tab_erro;
      --Rowid para a craplat
      vr_rowid_craplat ROWID;
      --Tabela de memoria para contas
      TYPE typ_tab_conta IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
      --Variaveis de Excecao
      vr_exc_erro    EXCEPTION;
      vr_exc_proximo EXCEPTION;

  BEGIN

      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      vr_dscritic:= NULL;
      vr_cdcritic:= 0;

      pr_tab_erro.DELETE;

      --Selecionar a data do movimento
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        CLOSE BTCH0001.cr_crapdat;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      /* Leitura dos titulos baixados para serem estornados */
      vr_index_titulo:= pr_tab_titulos.FIRST;
      WHILE vr_index_titulo IS NOT NULL LOOP
        BEGIN
          vr_flgdsair:= FALSE;
          --Selecionar titulos do bordero
          OPEN cr_craptdb (pr_cdcooper => pr_cdcooper
                          ,pr_cdbandoc => pr_tab_titulos(vr_index_titulo).cdbandoc
                          ,pr_nrdctabb => pr_tab_titulos(vr_index_titulo).nrdctabb
                          ,pr_nrcnvcob => pr_tab_titulos(vr_index_titulo).nrcnvcob
                          ,pr_nrdconta => pr_tab_titulos(vr_index_titulo).nrdconta
                          ,pr_nrdocmto => pr_tab_titulos(vr_index_titulo).nrdocmto
                          ,pr_insittit => 2); --pago
          FETCH cr_craptdb INTO rw_craptdb;
          --Se Nao encontrou ou encontrou e tem mais de 1
          IF cr_craptdb%NOTFOUND OR
             (cr_craptdb%FOUND AND rw_craptdb.qtdreg > 1) THEN
            --Ignorar Titulo
            vr_flgdsair:= TRUE;
          END IF;
          CLOSE cr_craptdb;

          IF vr_flgdsair THEN
            RAISE vr_exc_proximo;
          END IF;

          /* procura lcm de ajuste caso tenha acontecido deleta o lcm */
          OPEN cr_craplcm (pr_cdcooper => pr_cdcooper
                          ,pr_dtmvtolt => pr_dtmvtolt
                          ,pr_cdagenci => 1
                          ,pr_cdbccxlt => 100
                          ,pr_nrdolote => 10300
                          ,pr_nrdctabb => pr_nrdconta
                          ,pr_cdhistor => 590
                          ,pr_cdpesqbb => rw_craptdb.nrdocmto);
         FETCH cr_craplcm INTO rw_craplcm;
         IF cr_craplcm%FOUND THEN
           OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                           ,pr_dtmvtolt => pr_dtmvtolt
                           ,pr_cdagenci => 1
                           ,pr_cdbccxlt => 100
                           ,pr_nrdolote => 10300);
           IF cr_craplot%FOUND THEN
             /* Caso o lote tenha sido zerado o mesmo eh removido. */
             IF (rw_craplot.qtcompln - 1) = 0  THEN
               BEGIN
                  DELETE craplot
                   WHERE rowid = rw_craplot.rowid;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Erro ao excluir tabela craplot.'||sqlerrm;
                   --Levantar Excecao
                   RAISE vr_exc_erro;
               END;
             ELSE
               BEGIN
                 UPDATE craplot
                    SET qtcompln = qtcompln - 1
                       ,qtinfoln = qtinfoln - 1
                       ,vlinfocr = vlinfocr - rw_craplcm.vllanmto
                       ,vlcompcr = vlcompcr - rw_craplcm.vllanmto
                 WHERE rowid = rw_craplot.rowid;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Erro ao atualizar tabela craplot.'||sqlerrm;
                   --Levantar Excecao
                   RAISE vr_exc_erro;
               END;
             END IF;
           END IF;
           CLOSE cr_craplot;
           BEGIN
              DELETE craplcm
               WHERE rowid = rw_craplcm.rowid;
           EXCEPTION
             WHEN OTHERS THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'Erro ao excluir tabela craplcm.'||sqlerrm;
               --Levantar Excecao
               RAISE vr_exc_erro;
           END;
         END IF;
         CLOSE cr_craplcm;

         /* Tratamento para estorno de pagamentos a maior - Cob. sem registro */
         OPEN cr_craplcm (pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => pr_dtmvtolt
                         ,pr_cdagenci => 1
                         ,pr_cdbccxlt => 100
                         ,pr_nrdolote => 10300
                         ,pr_nrdctabb => pr_nrdconta
                         ,pr_cdhistor => 1100
                         ,pr_cdpesqbb => rw_craptdb.nrdocmto);
         FETCH cr_craplcm INTO rw_craplcm;
         IF cr_craplcm%FOUND THEN
           OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                           ,pr_dtmvtolt => pr_dtmvtolt
                           ,pr_cdagenci => 1
                           ,pr_cdbccxlt => 100
                           ,pr_nrdolote => 10300);
           IF cr_craplot%FOUND THEN
             /* Caso o lote tenha sido zerado o mesmo eh removido. */
             IF (rw_craplot.qtcompln - 1) = 0  THEN
               BEGIN
                  DELETE craplot
                   WHERE rowid = rw_craplot.rowid;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Erro ao excluir tabela craplot.'||sqlerrm;
                   --Levantar Excecao
                   RAISE vr_exc_erro;
               END;
             ELSE
               BEGIN
                 UPDATE craplot
                    SET qtcompln = qtcompln - 1
                       ,qtinfoln = qtinfoln - 1
                       ,vlinfocr = vlinfocr - rw_craplcm.vllanmto
                       ,vlcompcr = vlcompcr - rw_craplcm.vllanmto
                 WHERE rowid = rw_craplot.rowid;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Erro ao atualizar tabela craplot.'||sqlerrm;
                   --Levantar Excecao
                   RAISE vr_exc_erro;
               END;
             END IF;
           END IF;
           CLOSE cr_craplot;
           BEGIN
              DELETE craplcm
               WHERE rowid = rw_craplcm.rowid;
           EXCEPTION
             WHEN OTHERS THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'Erro ao excluir tabela craplcm.'||sqlerrm;
               --Levantar Excecao
               RAISE vr_exc_erro;
           END;
         END IF;
         CLOSE cr_craplcm;

         /* Tratamento para estorno de pagamentos
                     cdhistor = 1101 a menor - Cob. com registro
                     cdhistor = 1102 a Maior - Cob. com registro */
         OPEN cr_crablcm (pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => pr_dtmvtolt
                         ,pr_cdagenci => 1
                         ,pr_cdbccxlt => 100
                         ,pr_nrdolote => 10300
                         ,pr_nrdctabb => pr_nrdconta
                         ,pr_cdhisto1 => 1101
                         ,pr_cdhisto2 => 1102
                         ,pr_cdpesqbb => to_char(rw_craptdb.nrdocmto));
         FETCH cr_crablcm INTO rw_crablcm;
         IF cr_crablcm%FOUND THEN
           OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                           ,pr_dtmvtolt => pr_dtmvtolt
                           ,pr_cdagenci => 1
                           ,pr_cdbccxlt => 100
                           ,pr_nrdolote => 10300);
           IF cr_craplot%FOUND THEN
             /* Caso o lote tenha sido zerado o mesmo eh removido. */
             IF (rw_craplot.qtcompln - 1) = 0  THEN
               BEGIN
                  DELETE craplot
                   WHERE rowid = rw_craplot.rowid;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Erro ao excluir tabela craplot.'||sqlerrm;
                   --Levantar Excecao
                   RAISE vr_exc_erro;
               END;
             ELSE
               BEGIN
                 UPDATE craplot
                    SET qtcompln = qtcompln - 1
                       ,qtinfoln = qtinfoln - 1
                       ,vlinfocr = vlinfocr - rw_crablcm.vllanmto
                       ,vlcompcr = vlcompcr - rw_crablcm.vllanmto
                 WHERE rowid = rw_craplot.rowid;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Erro ao atualizar tabela craplot.'||sqlerrm;
                   --Levantar Excecao
                   RAISE vr_exc_erro;
               END;
             END IF;
           END IF;
           CLOSE cr_craplot;
           BEGIN
              DELETE craplcm
               WHERE rowid = rw_crablcm.rowid;
           EXCEPTION
             WHEN OTHERS THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'Erro ao excluir tabela craplcm.'||sqlerrm;
               --Levantar Excecao
               RAISE vr_exc_erro;
           END;
         END IF;
         CLOSE cr_crablcm;

         /*
             procura lcm de abatimento de juros
             caso tenha acontecido deleta o lcm
         */
         OPEN cr_craplcm (pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => pr_dtmvtolt
                         ,pr_cdagenci => 1
                         ,pr_cdbccxlt => 100
                         ,pr_nrdolote => 10300
                         ,pr_nrdctabb => pr_nrdconta
                         ,pr_cdhistor => 597
                         ,pr_cdpesqbb => rw_craptdb.nrdocmto);
         FETCH cr_craplcm INTO rw_craplcm;
         IF cr_craplcm%FOUND THEN
           OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                           ,pr_dtmvtolt => pr_dtmvtolt
                           ,pr_cdagenci => 1
                           ,pr_cdbccxlt => 100
                           ,pr_nrdolote => 10300);
           IF cr_craplot%FOUND THEN
             /* Caso o lote tenha sido zerado o mesmo eh removido. */
             IF (rw_craplot.qtcompln - 1) = 0  THEN
               BEGIN
                  DELETE craplot
                   WHERE rowid = rw_craplot.rowid;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Erro ao excluir tabela craplot.'||sqlerrm;
                   RAISE vr_exc_erro;
               END;
             ELSE
               BEGIN
                 UPDATE craplot
                    SET qtcompln = qtcompln - 1
                       ,qtinfoln = qtinfoln - 1
                       ,vlinfocr = vlinfocr - rw_craplcm.vllanmto
                       ,vlcompcr = vlcompcr - rw_craplcm.vllanmto
                 WHERE rowid = rw_craplot.rowid;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Erro ao atualizar tabela craplot.'||sqlerrm;
                   RAISE vr_exc_erro;
               END;
             END IF;
           END IF;
           CLOSE cr_craplot;
           BEGIN
              DELETE craplcm
               WHERE rowid = rw_craplcm.rowid;
           EXCEPTION
             WHEN OTHERS THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'Erro ao excluir tabela craplcm.'||sqlerrm;
               RAISE vr_exc_erro;
           END;
         END IF;
         CLOSE cr_craplcm;

         /* procura lcm de tarifa de pagamento de titulo descontado */
         OPEN cr_craplcm (pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => pr_dtmvtolt
                         ,pr_cdagenci => 1
                         ,pr_cdbccxlt => 100
                         ,pr_nrdolote => 8452
                         ,pr_nrdctabb => pr_nrdconta
                         ,pr_cdhistor => 595
                         ,pr_cdpesqbb => rw_craptdb.nrdocmto);
         FETCH cr_craplcm INTO rw_craplcm;
         IF cr_craplcm%FOUND THEN
           OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                           ,pr_dtmvtolt => pr_dtmvtolt
                           ,pr_cdagenci => 1
                           ,pr_cdbccxlt => 100
                           ,pr_nrdolote => 8452);
           IF cr_craplot%FOUND THEN
             /* Caso o lote tenha sido zerado o mesmo eh removido. */
             IF (rw_craplot.qtcompln - 1) = 0  THEN
               BEGIN
                  DELETE craplot
                   WHERE rowid = rw_craplot.rowid;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Erro ao excluir tabela craplot.'||sqlerrm;
                   RAISE vr_exc_erro;
               END;
             ELSE
               BEGIN
                 UPDATE craplot
                    SET qtcompln = qtcompln - 1
                       ,qtinfoln = qtinfoln - 1
                       ,vlinfocr = vlinfocr - rw_craplcm.vllanmto
                       ,vlcompcr = vlcompcr - rw_craplcm.vllanmto
                 WHERE rowid = rw_craplot.rowid;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Erro ao atualizar tabela craplot.'||sqlerrm;
                   RAISE vr_exc_erro;
               END;
             END IF;
           END IF;
           CLOSE cr_craplot;
           BEGIN
              DELETE craplcm
               WHERE rowid = rw_craplcm.rowid;
           EXCEPTION
             WHEN OTHERS THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'Erro ao excluir tabela craplcm.'||sqlerrm;
               RAISE vr_exc_erro;
           END;
         END IF;
         CLOSE cr_craplcm;

         BEGIN
           UPDATE craptdb
              SET craptdb.insittit = 4
                 ,craptdb.dtdpagto = null
            WHERE craptdb.rowid = rw_craptdb.rowid;
         EXCEPTION
            WHEN OTHERS THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'Erro ao atualizar tabela craptdb.'||sqlerrm;
               RAISE vr_exc_erro;
         END;

         /* Se o bordero estava liquidado volta o status para liberado */
         --Selecionar Bordero de titulos
         OPEN cr_crapbdt (pr_cdcooper => rw_craptdb.cdcooper
                         ,pr_nrborder => rw_craptdb.nrborder);
         FETCH cr_crapbdt INTO rw_crapbdt;
         IF cr_crapbdt%NOTFOUND THEN
           CLOSE cr_crapbdt;
           vr_dscritic:= 'Bordero nao encontrado.';
           vr_cdcritic:= 0;
            RAISE vr_exc_erro;
         ELSE
           BEGIN
             UPDATE crapbdt
                SET insitbdt = 3 /*Liberado*/
              WHERE rowid    = rw_crapbdt.rowid;
           EXCEPTION
              WHEN OTHERS THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'Erro ao atualizar tabela crapbdt.'||sqlerrm;
               RAISE vr_exc_erro;
           END;
         END IF;
         IF cr_crapbdt%ISOPEN THEN
           CLOSE cr_crapbdt;
         END IF;

         /* Corrige os juros que haviam sidos zerados anteriormente */
         BEGIN
           UPDATE crapljt
              SET vldjuros = vldjuros + vlrestit
                 ,vlrestit = 0
            WHERE cdcooper = pr_cdcooper
              AND nrdconta = rw_craptdb.nrdconta
              AND nrborder = rw_craptdb.nrborder
              AND dtrefere > pr_dtmvtolt
              AND cdbandoc = rw_craptdb.cdbandoc
              AND nrdctabb = rw_craptdb.nrdctabb
              AND nrcnvcob = rw_craptdb.nrcnvcob
              AND nrdocmto = rw_craptdb.nrdocmto;
         EXCEPTION
           WHEN OTHERS THEN
             vr_cdcritic:= 0;
             vr_dscritic:= 'Erro ao atualizar tabela crapljt.'||sqlerrm;
             RAISE vr_exc_erro;
         END;

      EXCEPTION
        WHEN vr_exc_proximo THEN
          NULL;
        WHEN vr_exc_erro THEN
          RAISE vr_exc_erro;
        WHEN OTHERS THEN
          --Montar Mensagem Erro
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro na rotina DSCT0001.pc_efetua_estorno_baixa_titulo. '||sqlerrm;
          RAISE vr_exc_erro;
      END;
      --Proximo registro
      vr_index_titulo:= pr_tab_titulos.NEXT(vr_index_titulo);
    END LOOP;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;

      -- Se nao tiver gerado a tabela de erro, gera a mesma
      IF vr_tab_erro.count = 0 THEN
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 -- Sequencia
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => pr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
      END IF;
    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na rotina DSCT0001.pc_efetua_estorno_baixa_titulo. '||sqlerrm;

      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 -- Sequencia
                           ,pr_cdcritic => pr_cdcritic
                           ,pr_dscritic => pr_dscritic
                           ,pr_tab_erro => vr_tab_erro);

  END pc_efetua_estorno_baixa_titulo;
END  DSCT0001;
/
