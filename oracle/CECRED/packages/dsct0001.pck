CREATE OR REPLACE PACKAGE CECRED.DSCT0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa:  DSCT0001                       Antiga: generico/procedures/b1wgen0153.p
  --  Autor   : Alisson
  --  Data    : Julho/2013                      Ultima Atualizacao: 16/02/2018
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
  --              15/02/2018 - Incluido nome do módulo logado
  --                           No caso de erro de programa gravar tabela especifica de log 
  --                           Ajuste mensagem de erro:
  --                           - Incluindo codigo e eliminando descrições fixas
  --                           - Gravando as informações de entrada de INSERTS, UPDATE e DELETES quando derem erro
  --                          (Belli - Envolti - Chamado 851591)    
  --
  --              16/02/2018 - Ref. História KE00726701-36 - Inclusão de Filtro e Parâmetro por Tipo de Pessoa na TAB052
  --                          (Gustavo Sene - GFT)
  --
  --              11/09/2018 - Fix removendo histórico de lançamento de borderô na pc_abatimento_juros_titulo - (Andrew Albuquerque - GFT)
  --
  ---------------------------------------------------------------------------------------------------------------
 
  -- Constantes
  vr_cdhistor_resgate     CONSTANT craphis.cdhistor%TYPE := 687;
  vr_cdhistordsct_resgcta CONSTANT craphis.cdhistor%TYPE := 2676; --RESGATE C/C
  vr_cdhistordsct_resopcr CONSTANT craphis.cdhistor%TYPE := 2677; --RESGATE Operacao Credito
  vr_cdhistordsct_resbaix CONSTANT craphis.cdhistor%TYPE := 2678; --RESGATE Baixa da carteira
  vr_cdhistordsct_resreap CONSTANT craphis.cdhistor%TYPE := 2679; --RESGATE Baixa rendas a apropriar
 
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

  -- P450 - Regulatório de crédito
  vr_tab_retorno lanc0001.typ_reg_retorno;
  vr_incrineg  INTEGER;
  vr_fldebita  boolean;


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
                                   ,pr_dtintegr    IN DATE         --Data da integração do pagamento - Merge 1 - 15/02/2018 - Chamado 851591
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

  --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
  PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2 DEFAULT 'E' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                                 ,pr_tpocorre IN NUMBER   DEFAULT 2   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                 ,pr_cdcricid IN NUMBER   DEFAULT 2   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                                 ,pr_tpexecuc IN NUMBER   DEFAULT 0   -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                                 ,pr_dscritic IN VARCHAR2 DEFAULT NULL
                                 ,pr_cdcritic IN VARCHAR2 DEFAULT NULL
                                 ,pr_nmrotina IN VARCHAR2 DEFAULT 'DSCT0001'
                                 ,pr_cdcooper IN VARCHAR2 DEFAULT 0
                                 );
                                 
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
                                         ,pr_cdcritic OUT VARCHAR2 --Codigo do erro
                                         ,pr_dscritic OUT VARCHAR2 --Descricao do erro                              
                                         );
                                         
  PROCEDURE pc_abatimento_juros_titulo(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_nrborder  IN crapbdt.nrborder%TYPE --> Numero do bordero
                                      ,pr_cdbandoc  IN craptdb.cdbandoc%TYPE
                                      ,pr_nrdctabb  IN craptdb.nrdctabb%TYPE
                                      ,pr_nrcnvcob  IN craptdb.nrcnvcob%TYPE
                                      ,pr_nrdocmto  IN craptdb.nrdocmto%TYPE
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                      ,pr_cdagenci  IN crapass.cdagenci%TYPE
                                      ,pr_cdoperad  IN VARCHAR2              --> Codigo operador
                                      ,pr_cdorigpg  IN NUMBER DEFAULT 0      --> Código da origem do pagamento  
                                      ,pr_dtdpagto  IN craptdb.dtdpagto%TYPE DEFAULT NULL --> Data de pagamento                                    
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                      );
                                          
END  DSCT0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.DSCT0001 AS

  /*---------------------------------------------------------------------------------------------------------------
  
    Programa :  DSCT0001
    Sistema  : Procedimentos envolvendo desconto titulos
    Sigla    : CRED
    Autor    : Alisson C. Berrido - Amcom
    Data     : Julho/2013.                   Ultima atualizacao: 27/06/2018
  
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
               
               14/02/2018 - Projeto Ligeirinho. Alterado para gravar na tabela de lotes (craplot) somente no final
                            da execução do CRPS509 => INTERNET E TAA. (Fabiano Girardi AMcom)                            

               15/02/2018 - Incluido nome do módulo logado
                            No caso de erro de programa gravar tabela especifica de log 
                            Ajuste mensagem de erro:
                            - Incluindo codigo e eliminando descrições fixas
                            - Gravando as informações de entrada de INSERTS, UPDATE e DELETES quando derem erro
                           (Belli - Envolti - Chamado 851591) 
  

               16/02/2018 - Ref. História KE00726701-36 - Inclusão de Filtro e Parâmetro por Tipo de Pessoa na TAB052
                           (Gustavo Sene - GFT)               
               27/04/2018 - Projeto Ligeirinho. Alterado para gravar o PA do associado na tabela de lotes (craplot)
			                quando chamado pelo CRPS538. (Mário- AMcom)
    
			   04/07/2018 - Projeto Ligeirinho. Ajuste chamado pelo CRPS509 #40089. (Mário- AMcom)
    
               24/05/2018 - Alterado procedure pc_efetua_resgate_tit_bord. Realizar os lançamentos:
                            1) Na conta corrente do cooperado (tabela CRAPLCM)
                               Valor do título descontando juros proporcional (histórico 2676 - RESGATE DE TITULO DESCONTADO)
                            2) Nas movimentações da operação de desconto (tabela tbdsct_lancamento_bordero)
                               Valor líquido do título (histórico 2677 - RESGATE DE TITULO DESCONTADO)
                               Valor bruto do título (histórico 2678 - RESGATE DE TITULO DESCONTADO) --> Baixa da carteira
                               Valor dos juros do título (histórico 2679	- RENDA SOBRE RESGATE DE TÍTULO DESCONTADO)
                            (Paulo Penteado (GFT))
                            
               07/06/2018 - Alterado a procedure pc_efetua_baixa_titulo, onde:
                            1) A rotina atual é chamada somente para os pagamentos de títulos de borderôs inclusos na versão 
                               antiga (crapbdt.flverbor = 0)
                            2) Os pagamentos de títulos de borderôs novos (crapbdt.flverbor = 1) irá chamar a nova rotina de 
                               baixa de título DSCT0003.pc_pagar_titulo
                            Criado a procedure pc_abatiamento_juros_titulo com a mesma funcionalidade do trecho de abatimento 
                            de juros do titulo antigamente escrita da rotina pc_efetua_baixa_titulo. Com isso, essa rtoina 
                            pode ser utilizada na dsct0003 para abatimento de juros das operações de crédito.
                            (Paulo Penteado (GFT)) 
                            
               27/06/2018 - P450 Regulatório de Credito - Substituido o insert na craplcm pela chamada 
                            da rotina lanc0001.pc_gerar_lancamento_conta. (Josiane Stiehler - AMcom)				               
                            
               19/07/2018 - Alterado as procedures pc_efetua_baixa_tit_car e pc_efetua_baixa_titulopara: Para os borderôs inclusos 
                            no sistema antes da nova versão de funcionalidade do bordero, quando houver o pagamento da operação de 
                            desconto, ou seja, do título vencido, através do débito em conta corrente deverá ser atualizada a coluna 
                            “Saldo Devedor” ficando zerada.(Paulo Penteado GFT)
    
               11/09/2018 - Fix removendo histórico de lançamento de borderô na pc_abatimento_juros_titulo - (Andrew Albuquerque - GFT)
    
  ---------------------------------------------------------------------------------------------------------------*/
  /* Tipos de Tabelas da Package */

  --Tipo de Tabela de lancamentos de juros dos titulos
  TYPE typ_crawljt IS RECORD (
    nrdconta crapljt.nrdconta%TYPE,
    nrborder crapljt.nrborder%TYPE,
    nrctrlim crapljt.nrctrlim%TYPE,
    dtrefere crapljt.dtrefere%TYPE,
    dtmvtolt crapljt.dtmvtolt%TYPE,
    vldjuros NUMBER,
    vlrestit crapljt.vlrestit%TYPE,
    cdcooper crapljt.cdcooper%TYPE,
    cdbandoc crapljt.cdbandoc%TYPE,
    nrdctabb crapljt.nrdctabb%TYPE,
    nrcnvcob crapljt.nrcnvcob%TYPE,
    nrdocmto crapljt.nrdocmto%TYPE );

  TYPE typ_tab_crawljt IS TABLE OF typ_crawljt INDEX BY PLS_INTEGER;

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
  
  -- Excluida rw_craperr, cr_craperr rw_crapban e cr_crapban não utilizadas - 15/02/2018 - Chamado 851591

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
                                         ,pr_cdcritic OUT VARCHAR2 --Codigo do erro
                                         ,pr_dscritic OUT VARCHAR2) IS --Descricao do erro
    -- .........................................................................
    --
    --  Programa : pc_efetua_liquidacao_bordero           Antigo: b1wgen0030.p/efetua_liquidacao_bordero
    --  Sistema  : Cred
    --  Sigla    : DSCT0001
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Julho/2013.                   Ultima atualizacao: 15/02/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para efetuar a liquidacao do bordero
    --
    
    /* .....................................................................................
    
         Altualizações:
    
         15/02/2018 - Incluido nome do módulo logado
                      No caso de erro de programa gravar tabela especifica de log 
                      Ajuste mensagem de erro:
                    - Incluindo codigo e eliminando descrições fixas
                    - Gravando as informações de entrada de INSERTS, UPDATE e DELETES quando derem erro
                    (Belli - Envolti - Chamado 851591) 
                    - Inclusão parâmetro pr_cdcritic para retorno do código do erro (utilizado
                      na gravação da tbgen_prglog para cumprir a padronização) 
                    - Retirado agrupamento de parâmetros, pois estva ficando duplicando na gravação
                      da tbgen nas rotinas chamadoras
                      (Ana - Envolti - Chamado 851591 - 19/04/2018)
     ..................................................................................... */
     
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
      vr_flgliqui BOOLEAN:= TRUE;
      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      -- Excluida rw_crapdat, vr_des_erro e vr_contador não utilizadas - 15/02/2018 - Chamado 851591       
      --Tabela de memoria de erros
      vr_tab_erro GENE0001.typ_tab_erro;
      --Variaveis de Excecao
      vr_exc_erro    EXCEPTION;
      vr_exc_proximo EXCEPTION;

    BEGIN
      -- Incluido nome do módulo logado - 15/02/2018 - Chamado 851591
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_liquidacao_bordero');
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
        --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
        vr_cdcritic := 1166; --Bordero nao encontrado.
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
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
            -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);       
            -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
            vr_cdcritic := 1035;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                               ' crapbdt(1):'||
                               ' insitbdt:'  || '4'  ||
                               ', ROWID:'    || rw_crapbdt.ROWID  || 
                               '. '          || sqlerrm; 
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
      END IF;
      -- Limpa nome do módulo logado - 15/02/2018 - Chamado 851591
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
        pr_des_erro:= 'NOK';
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);     
        -- Erro
        pr_des_erro:= 'NOK';
        -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
        pr_cdcritic:= 9999;
        pr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                      'DSCT0001.pc_efetua_liquidacao_bordero. '||sqlerrm||'.';
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
  /* ................................................................................

     Programa: pc_efetua_baixa_tit_car       Antiga: 
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED

     Autor   : Desconhecido
     Data    : --/--/----                        Ultima atualizacao: 19/07/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado
     Objetivo  :  

     Alteracoes: 
  
                15/02/2018 - Incluido nome do módulo logado
                             No caso de erro de programa gravar tabela especifica de log 
                             Ajuste mensagem de erro:
                             - Incluindo codigo e eliminando descrições fixas
                             - Gravando as informações de entrada de INSERTS, UPDATE e DELETES quando derem erro
                             - Incluído tratamento para não duplicar a mensagens na tbgen: vr_ininsoco
                            (Belli - Envolti - Chamado 851591)      
     
                19/07/2018 - Para os borderôs inclusos no sistema antes da nova versão de funcionalidade do bordero, quando houver 
                             o pagamento da operação de desconto, ou seja, do título vencido, através do débito em conta corrente 
                             deverá ser atualizada a coluna “Saldo Devedor” ficando zerada.(Paulo Penteado GFT)
  ..................................................................................*/ 
  BEGIN
    DECLARE
    
      -- Cursor sobre os titulos contidos do Bordero de desconto de titulos
      CURSOR cr_craptdb(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                       ,pr_dtrefere IN DATE
                       ,pr_insittit IN craptdb.insittit%TYPE) IS
        SELECT craptdb.ROWID,
               craptdb.cdcooper,
               craptdb.nrdconta,
               craptdb.nrborder,
               craptdb.cdbandoc,
               craptdb.dtvencto,
               craptdb.dtlibbdt,
               craptdb.nrcnvcob,
               craptdb.nrdctabb,
               craptdb.nrdocmto,
               craptdb.nrinssac,
               craptdb.vltitulo,
               craptdb.vlliquid
          FROM craptdb, crapbdt 
         WHERE craptdb.cdcooper  = pr_cdcooper
           AND craptdb.cdcooper  = crapbdt.cdcooper
           AND craptdb.nrdconta  = crapbdt.nrdconta
           AND craptdb.nrborder  = crapbdt.nrborder
           AND craptdb.dtvencto >= pr_dtrefere
           AND craptdb.dtvencto  < pr_dtmvtolt 
           AND craptdb.insittit  = pr_insittit --4 liberado
           AND craptdb.dtdpagto IS NULL
           AND crapbdt.flverbor = 0 -- somente os titulos de borderôs antigos devem ser considerados
         ORDER BY cdcooper, nrdconta, dtvencto, nrborder, vltitulo, nrdocmto; 
      
      --Selecionar Bordero de titulos
      CURSOR cr_crapbdt (pr_cdcooper IN crapbdt.cdcooper%type
                        ,pr_nrborder IN crapbdt.nrborder%type) IS
        SELECT crapbdt.txmensal
              ,crapbdt.vltaxiof
              ,crapbdt.flverbor
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
      
      
      vr_cardbtit     INTEGER; --> Parametro de dias carencia cobranca c/ registro pessoa fisica ou juridica
      vr_cardbtitcrpf INTEGER; --> Parametro de dias carencia cobranca c/ registro pessoa fisica
      vr_cardbtitcrpj INTEGER; --> Parametro de dias carencia cobranca c/ registro pessoa juridica

      -- Excluida vr_diascare e vr_diascare não utilizadas - 15/02/2018 - Chamado 851591       
      vr_dtrefere     DATE;                --> Data de referencia para buscar os titulos que vao ser debitados
      -- Excluida vr_dtvcttdb não utilizadas - 15/02/2018 - Chamado 851591 
           
      vr_nrseqdig     NUMBER;              --> Nr Sequencia
      vr_dtultdia     DATE;                --> Variavel para armazenar o ultimo dia util do ano
      vr_indice       VARCHAR2(13);
      vr_cdpesqbb     VARCHAR2(1000);
      vr_tab_saldo    EXTR0001.typ_tab_saldos;     --> Temp-Table com o saldo do dia

      vr_tab_dados_tar typ_tab_dados_tarifa;
      
      -- Excluida vr_vlttsrpf, vr_vlttsrpj, vr_vlttcrpf e vr_vlttcrpj não utilizadas - 15/02/2018 - Chamado 851591 
      
      vr_dstextab     craptab.dstextab%TYPE;    
      vr_dsctajud     crapprm.dsvlrprm%TYPE;
      vr_natjurid     crapjur.natjurid%TYPE;
      vr_tpregtrb     crapjur.tpregtrb%TYPE;
      vr_vliofpri     NUMBER(25,2);
      vr_vliofadi     NUMBER(25,2);
      vr_vliofcpl     NUMBER(25,2);
      vr_qtdiaiof     PLS_INTEGER;                          
      vr_flgimune     PLS_INTEGER; -- Merge 1 - 15/02/2018 - Chamado 851591                       
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

      --Agrupa os parametros - 15/02/2018 - Chamado 851591 
      vr_dsparame VARCHAR2(4000);
      --Indicador para gerar critica nas ocorrencias. 1 Insere, 2 Não insere. - 15/02/2018 - Chamado 851591
      vr_ininsoco NUMBER(1) := 1; 

      --Busca os valores de tarifa para PF e PJ para os titulos
      PROCEDURE pc_busca_vltarifa_tit(pr_cdcooper  IN  crapcop.cdcooper%TYPE
                                     ,pr_tab_dados OUT typ_tab_dados_tarifa
                                     ,pr_cdcritic  OUT INTEGER
                                     ,pr_dscritic  OUT crapcri.dscritic%TYPE) IS
          
      -- Excluida vr_dsmensag não utilizada - 15/02/2018 - Chamado 851591 
      -- Excluida vr_cdpesqbb não utilizada - 15/02/2018 - Chamado 851591 
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

        -- Incluido nome do módulo logado - 15/02/2018 - Chamado 851591
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_busca_vltarifa_tit');

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
          -- Trata indicador para gerar critica nas ocorrencias. 2 Não insere - 15/02/2018 - Chamado 851591
          IF NVL(vr_tab_erro.Count,0) > 0 THEN
            vr_ininsoco := 2;
          END IF;                      
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

        -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_busca_vltarifa_tit');

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
          -- Trata indicador para gerar critica nas ocorrencias. 2 Não insere - 15/02/2018 - Chamado 851591
          IF NVL(vr_tab_erro.Count,0) > 0 THEN
            vr_ininsoco := 2;
          END IF;                      
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

        -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_busca_vltarifa_tit');

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
          -- Trata indicador para gerar critica nas ocorrencias. 2 Não insere - 15/02/2018 - Chamado 851591
          IF NVL(vr_tab_erro.Count,0) > 0 THEN
            vr_ininsoco := 2;
          END IF;                      
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

        -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_busca_vltarifa_tit');

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
          -- Trata indicador para gerar critica nas ocorrencias. 2 Não insere - 15/02/2018 - Chamado 851591
          IF NVL(vr_tab_erro.Count,0) > 0 THEN
            vr_ininsoco := 2;
          END IF;                      
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        
        -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_busca_vltarifa_tit');
        
        pr_tab_dados('CRPJ').cdfvlcop := vr_cdfvlcop;
        pr_tab_dados('CRPJ').vltottar := 0;
        pr_tab_dados('CRPJ').cdhistor := vr_cdhistor;
        pr_tab_dados('CRPJ').vlrtarif := vr_vlrtarif;
      
      EXCEPTION
        WHEN vr_exc_erro THEN
          pr_cdcritic:= vr_cdcritic;
          pr_dscritic:= vr_dscritic;

          --Indicador para gerar critica nas ocorrencias. 1 Insere, 2 Não insere. - 15/02/2018 - Chamado 851591                      
          IF vr_ininsoco = 1 THEN
          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 /** Sequencia **/
                               ,pr_cdcritic => pr_cdcritic
                               ,pr_dscritic => pr_dscritic
                               ,pr_tab_erro => vr_tab_erro);
                               
          END IF;                     
          pr_tab_erro := vr_tab_erro;
          IF NVL(vr_tab_erro.Count,0) > 0 THEN
            pr_tab_erro := vr_tab_erro;
          END IF;
          
        WHEN OTHERS THEN     
          -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 

          -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
          pr_cdcritic := 9999;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                      'DSCT0001.pc_busca_vltarifa_tit. ' ||sqlerrm;

          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 /** Sequencia **/
                               ,pr_cdcritic => pr_cdcritic
                               ,pr_dscritic => pr_dscritic
                               ,pr_tab_erro => vr_tab_erro);        
                               
          pr_tab_erro := vr_tab_erro;       
          IF NVL(vr_tab_erro.Count,0) > 0 THEN
            pr_tab_erro := vr_tab_erro;
          END IF;
                               
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
             AND lcm.nrdolote = 10301;
            -- Merge 1 - Excluido AND lcm.cdhistor = 591;  - 15/02/2018 - Chamado 851591
        rw_craplcm_seq cr_craplcm_seq%ROWTYPE;                            
      BEGIN
        -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.fn_busca_nrseqdig');

        OPEN cr_craplcm_seq(pr_cdcooper => pr_cdcooper
                             ,pr_dtmvtolt => pr_dtmvtolt);
        FETCH cr_craplcm_seq INTO rw_craplcm_seq;
        
        IF cr_craplcm_seq%NOTFOUND THEN
           CLOSE cr_craplcm_seq;
           RETURN 0;
        END IF;
        
          CLOSE cr_craplcm_seq;
        -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
        RETURN rw_craplcm_seq.nrseqdig;
      END fn_busca_nrseqdig;                          
      
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
        -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.fn_verifica_cobranca_reg');

        OPEN cr_crapcco(pr_cdcooper => pr_cdcooper
                       ,pr_nrconven => pr_nrcnvcob);
        FETCH cr_crapcco INTO rw_crapcco;
        
        IF cr_crapcco%NOTFOUND THEN
           CLOSE cr_crapcco;
           RETURN FALSE;
        END IF;
        
        CLOSE cr_crapcco;
        -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
        RETURN TRUE;        
      END fn_verifica_cobranca_reg;                                                                        
      
      --Busca data de referencia para processamento dos titulos
      FUNCTION fn_dtrefere_carencia(pr_cdcooper crapcop.cdcooper%TYPE
                                   ,pr_dtmvtolt crapdat.dtmvtolt%TYPE
                                   ,pr_dtmvtoan crapdat.dtmvtoan%TYPE) RETURN DATE IS
        vr_dtdiauti       DATE;
        vr_dtverifi       DATE;
        vr_dtvalida       DATE;
      BEGIN
        
        -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.fn_dtrefere_carencia');

        /*Pegar o penultimo dia util do ano passado qdo rodar no primeiro 
          dia util deste ano ou processar com dtmvtoan */
        vr_dtdiauti := to_date('0101'||to_char(pr_dtmvtolt,'YYYY'),'ddmmyyyy');
        vr_dtdiauti := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                   pr_dtmvtolt => vr_dtdiauti,
                                                   pr_tipo => 'P', -- Proximo
                                                   pr_feriado => TRUE);
                                                     
        -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.fn_dtrefere_carencia');

        IF vr_dtdiauti = pr_dtmvtolt THEN      
           vr_dtvalida := trunc(pr_dtmvtolt,'RRRR') - 1; -- 31/12/YYYY
           vr_dtverifi := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                      pr_dtmvtolt => vr_dtvalida,
                                                      pr_tipo => 'A', -- Anterior
                                                      pr_feriado => FALSE);
                 
          -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
          GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.fn_dtrefere_carencia');

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
          -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
          GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.fn_dtrefere_carencia');
                                                            
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
      
        -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);	               
      
        RETURN vr_dtvalida;
      END fn_dtrefere_carencia;

    BEGIN
      
      -- Incluido nome do módulo logado - 15/02/2018 - Chamado 851591
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_car');
      
      --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591
      vr_dsparame :=  ' pr_cdcooper:'  || pr_cdcooper || 
                      ' ,pr_cdagenci:' || pr_cdagenci || 
                      ' ,pr_nrdcaixa:' || pr_nrdcaixa || 
                      ' ,pr_idorigem:' || pr_idorigem ||
                      ' ,pr_cdoperad:' || pr_cdoperad || 
                      ' ,pr_dtmvtolt:' || pr_dtmvtolt || 
                      ' ,pr_dtmvtoan:' || pr_dtmvtoan;
                      
/*#########################Carrega variaveis e parametros iniciais################################################*/
      
      --tabela que guarda a qtd de tit
      --que devem ser tarifados por conta
      vr_tab_tar.delete; 
      
      --Cobranca com registro
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'USUARI'
                                              ,pr_cdempres => 11
                                              ,pr_cdacesso => 'LIMDESCTITCRPF'
                                              ,pr_tpregist => 0);
      --Se nao encontrou
      IF vr_dstextab IS NULL THEN
        --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
        vr_cdcritic := 1165; -- Carencia para desconto de titulo nao encontrada.
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          --Levantar Excecao
          RAISE vr_exc_erro;
      ELSE
        -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_car');
        vr_cardbtitcrpf := TO_NUMBER(gene0002.fn_busca_entrada(pr_postext => 32, pr_dstext => vr_dstextab, pr_delimitador => ';'));
      END IF;

      -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_car');

      --Cobranca sem registro
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'USUARI'
                                              ,pr_cdempres => 11
                                              ,pr_cdacesso => 'LIMDESCTITCRPJ'
                                              ,pr_tpregist => 0);
      --Se nao encontrou
      IF vr_dstextab IS NULL THEN
        --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
        vr_cdcritic := 1165; -- Carencia para desconto de titulo nao encontrada.
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          --Levantar Excecao
          RAISE vr_exc_erro;
      ELSE          
        -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_car');          
        vr_cardbtitcrpj := TO_NUMBER(gene0002.fn_busca_entrada(pr_postext => 32, pr_dstext => vr_dstextab, pr_delimitador => ';'));
      END IF;
      
      -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_car');
      
      --Pega data de referencia que deve buscar os titulos para processamento
      vr_dtrefere := fn_dtrefere_carencia(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_dtmvtoan => pr_dtmvtoan);
                                         
       -- Projeto Ligeirinho -  paralelismo
       -- busca a sequencia para as execuções de paralelismo
       if paga0001.fn_exec_paralelo then
          vr_nrseqdig:= PAGA0001.fn_seq_parale_craplcm; 
       else
      vr_nrseqdig := fn_busca_nrseqdig(pr_cdcooper => pr_cdcooper
                                      ,pr_dtmvtolt => pr_dtmvtolt) + 1;
       end if;
                                      
      -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_car');

      --Selecionar a data do movimento
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver¿ raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
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
      
      -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_car');    
      
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
          -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
          GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_car');
          CONTINUE;
        END IF; 
        
         -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
         GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_car');					  

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
          --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
          vr_cdcritic := 9; --Associado n cadastrado
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
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
         
        if    rw_crapass.inpessoa = 1 then -- Pessoa Física
              vr_cardbtit := vr_cardbtitcrpf;
              
        elsif rw_crapass.inpessoa = 2 then -- Pessoa Jurídica
              vr_cardbtit := vr_cardbtitcrpj;
        end   if;
         
         -- se ainda nao acabou a carencia deve verificar saldo
         -- contar a partir do primeiro dia util qdo a data de vencimento cair no final de semana ou feriado
        --  Cobrança com Registro
         IF (gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                         pr_dtmvtolt => rw_craptdb.dtvencto) + vr_cardbtit) > pr_dtmvtolt THEN  -- verificar cobr reg e sem reg

           -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
           GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_car');	

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
               --O conteúdo das variáveis vr_cdcritic e vr_dscritic não são gravados na tbgen
               --nesse momento porque é utilizado o conteúdo da vr_tab_erro - Chamado 851591
               vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
               vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_craptdb.nrdconta;
               vr_ininsoco:= 2; -- Indicador para gerar critica nas ocorrencias. 2 Não insere - 15/02/2018 - Chamado 851591
             ELSE
               --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
               vr_cdcritic := 9998; -- Retorno "NOK" na extr0001.pc_obtem_saldo_dia e sem informação na pr_tab_erro                              
               vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                              ' EXTR0001.pc_obtem_saldo_dia. Conta: '||rw_crapass.nrdconta||'.';
             END IF;
             
             --continue;
             --Levantar Excecao
             RAISE vr_exc_erro;
           ELSE
             vr_dscritic:= NULL;
           END IF;
           
           -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
           GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_car');	
           
           --Verificar o saldo retornado
           IF vr_tab_saldo.Count = 0 THEN
             --Montar mensagem erro
             --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
             vr_cdcritic := 1072; --Nao foi possivel consultar o saldo para a operacao.
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
             --Levantar Excecao
             RAISE vr_exc_erro;
           END IF;
        
           --Se o saldo nao for suficiente
           IF rw_craptdb.vltitulo > (nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) +
                                     nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0)) THEN
              CONTINUE;                         
           END IF;                                  
           
         END IF;
        /*###################################FIM REGRAS####################################################*/
        --Gravar lancamento
        -- P450 - Regutatório de crédito
        lanc0001.pc_gerar_lancamento_conta(
                    pr_dtmvtolt => pr_dtmvtolt
                   ,pr_cdagenci => 1
                   ,pr_cdbccxlt => 100
                   ,pr_nrdolote => 10301
                   ,pr_nrdconta => rw_craptdb.nrdconta
                   ,pr_nrdctabb => rw_craptdb.nrdconta
                   ,pr_cdpesqbb => rw_craptdb.nrdocmto
                   ,pr_cdcooper => pr_cdcooper
                   ,pr_nrdocmto => NVL(vr_nrseqdig,0) 
                   ,pr_cdhistor => 591
                   ,pr_nrseqdig => NVL(vr_nrseqdig,0)
                   ,pr_vllanmto => rw_craptdb.vltitulo
                   ,pr_nrautdoc => 0
                   -- retorno
                   ,pr_tab_retorno => vr_tab_retorno
                   ,pr_incrineg => vr_incrineg
                   ,pr_cdcritic => vr_cdcritic
                   ,pr_dscritic => vr_dscritic);

        IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
           IF vr_incrineg = 0 THEN -- Erro de sistema/BD
            -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
            -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
            vr_cdcritic := 1034;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                               'craplcm(1):'  ||
                               ' dtmvtolt:'    || pr_dtmvtolt         ||
                               ', cdagenci:'   || '1'                 || 
                               ', cdbccxlt:'   || '100'               || 
                               ', nrdolote:'   || '10301'             ||
                               ', nrdconta:'   || rw_craptdb.nrdconta ||
                               ', nrdocmto:'   || NVL(vr_nrseqdig,0)  || 
                               ', vllanmto:'   || rw_craptdb.vltitulo ||
                               ', cdhistor:'   || '591'               ||
                               ', nrseqdig:'   || NVL(vr_nrseqdig,0)  ||
                               ', nrdctabb:'   || rw_craptdb.nrdconta ||
                               ', nrautdoc:'   || '0'                 ||
                               ', cdcooper:'   || pr_cdcooper         ||
                               ', cdpesqbb:'   || rw_craptdb.nrdocmto || 
                               '. ' ||sqlerrm; 
            RAISE vr_exc_erro;
           ELSE
             CONTINUE;
           END IF;
        END IF;
            
        rw_craplcm.nrseqdig:= NVL(vr_nrseqdig,0);
        rw_craplcm.vllanmto:= rw_craptdb.vltitulo;
        
       -- Projeto Ligeirinho -  paralelismo
       -- busca a sequencia para as execuções de paralelismo
       if paga0001.fn_exec_paralelo then
          vr_nrseqdig:= PAGA0001.fn_seq_parale_craplcm; 
       else
        vr_nrseqdig := vr_nrseqdig + 1; --Proxima sequencia
       end if;
        
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
          --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
          vr_cdcritic := 1166; --Bordero nao encontrado.
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
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
                                     ,pr_flgimune   => vr_flgimune -- Merge 1 - 15/02/2018 - Chamado 851591
									 );

        -- Condicao para verificar se houve critica
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
         -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_car');	
        
        IF (NVL(vr_vliofcpl,0) > 0) AND vr_flgimune <= 0 THEN -- Merge 1 - 15/02/2018 - Chamado 851591
          -- P450 - Regutatório de crédito
          lanc0001.pc_gerar_lancamento_conta(
                    pr_dtmvtolt => pr_dtmvtolt
                   ,pr_cdagenci => 1
                   ,pr_cdbccxlt => 100
                   ,pr_nrdolote => 10301
                   ,pr_nrdconta => rw_craptdb.nrdconta
                   ,pr_nrdctabb => rw_craptdb.nrdconta
                   ,pr_cdpesqbb => rw_craptdb.nrdocmto
                   ,pr_cdcooper => pr_cdcooper
                   ,pr_nrdocmto => NVL(vr_nrseqdig,0) 
                   ,pr_cdhistor => 2321
                   ,pr_nrseqdig => NVL(vr_nrseqdig,0)
                   ,pr_vllanmto => vr_vliofcpl
                   ,pr_nrautdoc => 0
                   -- retorno
                   ,pr_tab_retorno => vr_tab_retorno
                   ,pr_incrineg => vr_incrineg
                   ,pr_cdcritic => vr_cdcritic
                   ,pr_dscritic => vr_dscritic);

          IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
            IF vr_incrineg = 0 THEN -- Erro de sistema/BD
              -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
              CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);      
              -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
              vr_cdcritic := 1034;
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                               'craplcm(2):' ||
                               ' dtmvtolt:'   || pr_dtmvtolt  ||
                               ', cdagenci:'  || '1'      || 
                               ', cdbccxlt:'  || '100'    || 
                               ', nrdolote:'  || '10301'  ||
                               ', nrdconta:'  || rw_craptdb.nrdconta  ||
                               ', nrdocmto:'  || NVL(vr_nrseqdig,0)   || 
                               ', vllanmto:'  || vr_vliofcpl  ||
                               ', cdhistor:'  || '2321'       ||
                               ', nrseqdig:'  || NVL(vr_nrseqdig,0)   ||
                               ', nrdctabb:'  || rw_craptdb.nrdconta  ||
                               ', nrautdoc:'  || '0'          ||
                               ', cdcooper:'  || pr_cdcooper  ||
                               ', cdpesqbb:'  || rw_craptdb.nrdocmto  || 
                               '. ' ||sqlerrm; 
              RAISE vr_exc_erro;
                  ELSE --  vr_incrineg = 1 = Erro de negócio
                    vr_cdcritic := 0;
                    vr_dscritic := 'Lançameno não foi efetuado' ||
                                     'craplcm(2):' ||
                                     ' dtmvtolt:'   || pr_dtmvtolt  ||
                                     ', cdagenci:'  || '1'      || 
                                     ', cdbccxlt:'  || '100'    || 
                                     ', nrdolote:'  || '10301'  ||
                                     ', nrdconta:'  || rw_craptdb.nrdconta  ||
                                     ', nrdocmto:'  || NVL(vr_nrseqdig,0)   || 
                                     ', vllanmto:'  || vr_vliofcpl  ||
                                     ', cdhistor:'  || '2321'       ||
                                     ', nrseqdig:'  || NVL(vr_nrseqdig,0)   ||
                                     ', nrdctabb:'  || rw_craptdb.nrdconta  ||
                                     ', nrautdoc:'  || '0'          ||
                                     ', cdcooper:'  || pr_cdcooper  ||
                                     ', cdpesqbb:'  || rw_craptdb.nrdocmto  || 
                                     '. ';
                    RAISE vr_exc_erro;
                END IF;	
            END IF; 
            vr_dtmvtolt_lcm:= pr_dtmvtolt;
            vr_cdagenci_lcm:= 1;
            vr_cdbccxlt_lcm:= 100;
            vr_nrdolote_lcm:= 10301;
            vr_nrseqdig_lcm:= NVL(vr_nrseqdig,0);

          -- Projeto Ligeirinho -  paralelismo
          -- busca a sequencia para as execuções de paralelismo
          if paga0001.fn_exec_paralelo then
             vr_nrseqdig:= PAGA0001.fn_seq_parale_craplcm; 
          else
          vr_nrseqdig := vr_nrseqdig + 1; --Proxima sequencia
          end if;
        END IF;
        
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
                              ,pr_flgimune     => vr_flgimune -- Merge 1 - 15/02/2018 - Chamado 851591
                              ,pr_cdcritic     => vr_cdcritic
                              ,pr_dscritic     => vr_dscritic);
                                
        -- Condicao para verificar se houve critica                             
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;        
        
        -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_car');	
                
        ------------------------------------------------------------------------------------------
        -- Fim Efetuar o Lancamento de IOF
        ------------------------------------------------------------------------------------------        
        
        /*#########ATUALIZA TDB##################################*/
        --Atualizar situacao titulo
        BEGIN
          UPDATE craptdb 
             SET craptdb.insittit = 3, /* Baixado s/ pagto */
                 craptdb.dtdebito = pr_dtmvtolt,
                 craptdb.vlsldtit = 0
           WHERE craptdb.ROWID = rw_craptdb.ROWID;
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);     
            -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
            vr_cdcritic := 1035;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)  || 
                               ' CRAPTDB(1):' ||
                               ' insittit:'   || '3'  ||
                               ', dtdebito:'  || pr_dtmvtolt  ||
                               ', ROWID:'     || rw_craptdb.ROWID  || 
                               '. '           || sqlerrm||'.'; 
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
                                              ,pr_cdcritic => vr_cdcritic   --Código do erro
                                              ,pr_dscritic => vr_dscritic); --Descricao do erro;

        IF NVL(LENGTH(TRIM(vr_dscritic)),0) > 0 THEN -- Merge 02/05/2018 - Chamado 851591 
          GENE0001.pc_gera_erro(pr_cdcooper => rw_craptdb.cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 /** Sequencia **/
                               ,pr_cdcritic => 0
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => vr_tab_erro);
        END IF;

        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          --Mensagem erro
          --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
          vr_dscritic := vr_dscritic||' pr_nrdconta:' || rw_craptdb.nrdconta ||
                                      ' ,pr_nrborder:' || rw_craptdb.nrborder||','; 
          -- Trata indicador para gerar critica nas ocorrencias. 2 Não insere - 15/02/2018 - Chamado 851591
          IF NVL(vr_tab_erro.Count,0) > 0 THEN
            vr_ininsoco := 2;
          END IF;                      
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        
        -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_car');
         	
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
                           ,pr_cdcritic  => vr_cdcritic
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
           
           -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591            
           vr_cdcritic := 9; --Associado n cadastrado
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           
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
               -- Trata indicador para gerar critica nas ocorrencias. 2 Não insere - 15/02/2018 - Chamado 851591
               IF NVL(vr_tab_erro.Count,0) > 0 THEN
                 vr_ininsoco := 2;
               END IF;                      
                --Levantar Excecao
                RAISE vr_exc_erro;
             END IF;
             
             -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
             GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_car');	
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
               -- Trata indicador para gerar critica nas ocorrencias. 2 Não insere - 15/02/2018 - Chamado 851591
               IF NVL(vr_tab_erro.Count,0) > 0 THEN
                 vr_ininsoco := 2;
               END IF;                      
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
              
             -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
             GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_car');	
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
               -- Trata indicador para gerar critica nas ocorrencias. 2 Não insere - 15/02/2018 - Chamado 851591
               IF NVL(vr_tab_erro.Count,0) > 0 THEN
                 vr_ininsoco := 2;
               END IF;                      
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
              
             -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
             GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_car');	
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
               -- Trata indicador para gerar critica nas ocorrencias. 2 Não insere - 15/02/2018 - Chamado 851591
               IF NVL(vr_tab_erro.Count,0) > 0 THEN
                 vr_ininsoco := 2;
               END IF;                      
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
              
             -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
             GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_car');	
           END IF;   
           
        END IF;
        
        --Proximo indice
        vr_indice := vr_tab_tar.NEXT(vr_indice); 
      
      END LOOP;
      /*#########FIM LANCAR TARIFA TITULO#########################*/     

      COMMIT;

	    -- Merge 1 - 15/02/2018 - Chamado 851591
      IF NVL(vr_cdcritic,0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => NVL(vr_cdcritic,0)
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
      END IF;

      IF NVL(vr_tab_erro.Count,0) > 0 THEN
        pr_tab_erro := vr_tab_erro;
      END IF;

      -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);	

    EXCEPTION
      WHEN vr_exc_saida THEN
        ROLLBACK;
      WHEN vr_exc_erro THEN  
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic ||
                      vr_dsparame;

        --Indicador para gerar critica nas ocorrencias. 1 Insere, 2 Não insere. - 15/02/2018 - Chamado 851591                      
        IF vr_ininsoco = 1 THEN
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => pr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
        END IF;
                             
        IF NVL(vr_tab_erro.Count,0) > 0 THEN
        pr_tab_erro := vr_tab_erro;
        END IF;
                             
        ROLLBACK;
        
      WHEN OTHERS THEN     
        -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);     

        -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
        pr_cdcritic:= 9999;
        pr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)||
                      'DSCT0001.pc_efetua_baixa_tit_car. ' ||sqlerrm||
                      '.'||vr_dsparame;

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => pr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
                             
        -- Merge 1 - 15/02/2018 - Chamado 851591                     
        IF NVL(vr_tab_erro.Count,0) > 0 THEN
        pr_tab_erro := vr_tab_erro;
        END IF;

        ROLLBACK;                             
        
    END;    
  END pc_efetua_baixa_tit_car;

  PROCEDURE pc_efetua_baixa_tit_car_job IS           
  /* ................................................................................

     Programa: pc_efetua_baixa_tit_car_job       Antiga: 
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED

     Autor   : Desconhecido
     Data    : --/--/----                        Ultima atualizacao: 15/02/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado
     Objetivo  :  

     Alteracoes: 
  
                15/02/2018 - Incluido nome do módulo logado
                             No caso de erro de programa gravar tabela especifica de log 
                             Ajuste mensagem de erro:
                             - Incluindo codigo e eliminando descrições fixas
                             - Gravando as informações de entrada de INSERTS, UPDATE e DELETES quando derem erro
                             - Incluído tratamento para não duplicar a mensagens na tbgen: vr_ininsoco
                            (Belli - Envolti - Chamado 851591)      
                             - Retirada variável vr_cdprogra = 'PC_EFETUA_BAIXA_TIT_CAR_JOB'
                               -> não é utilizada.
                             - Inclusão gravação log
                            (Ana - Envolti - Chamado 851591)      
  ..................................................................................*/          
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
                                      
      vr_nomdojob    VARCHAR2(40) := 'JBDSCT_EFETUA_BAIXA_TIT_CAR';
      -- Excluida vr_flgerlog não utilizada - 15/02/2018 - Chamado 851591 
      vr_dthoje      DATE := TRUNC(SYSDATE);

      -- Cooperativa em execução - 15/02/2018 - Chamado 851591       
      vr_cdcooper    crapcop.cdcooper%TYPE := 3;
      --Indicador para gerar critica nas ocorrencias. 1 Insere, 2 Não insere. - 15/02/2018 - Chamado 851591
      vr_ininsoco NUMBER(1) := 1; 

      -- Ajuste de mensagem - 15/02/2018 - Chamado 851591 
      --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
      PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2 DEFAULT 'O', -- 'I' início; 'F' fim; 'E' erro; O - ocorrência
                                      pr_dscritic IN VARCHAR2 DEFAULT NULL,
                                      pr_cdcritic IN VARCHAR2 DEFAULT NULL,
                                      pr_tpocorrencia IN NUMBER DEFAULT 4 --1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                      ) IS
        vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;                                      
      BEGIN
        --> Controlar geração de log de execução dos jobs 
        --> Geração de log                                
        CECRED.pc_log_programa(pr_dstiplog      => pr_dstiplog
                              ,pr_cdprograma    => vr_nomdojob
                              ,pr_cdcooper      => vr_cdcooper
                              ,pr_tpexecucao    => 2 -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                              ,pr_tpocorrencia  => pr_tpocorrencia
                              ,pr_cdmensagem    => pr_cdcritic
                              ,pr_dsmensagem    => pr_dscritic
                              ,pr_idprglog      => vr_idprglog
                              ,pr_cdcriticidade => pr_tpocorrencia
                              );
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log  
          CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);    
      END pc_controla_log_batch;
    
    BEGIN     
      -- Incluido nome do módulo logado - 15/02/2018 - Chamado 851591
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_job');
    
      -- Log de inicio de execucao
      pc_controla_log_batch(pr_dstiplog => 'I');
    
      -- SD#497991
      -- validação copiada de TARI0001
      -- Verificar se a data atual é uma data util, se retornar uma data diferente
      -- indica que não é um dia util, então deve sair do programa sem executar ou reprogramar
      IF gene0005.fn_valida_dia_util(pr_cdcooper => 3
                                    ,pr_dtmvtolt => vr_dthoje) = vr_dthoje THEN -- SD#497991

        -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_job');

        gene0004.pc_executa_job( pr_cdcooper => 3   --> Codigo da cooperativa
                                ,pr_fldiautl => 1   --> Flag se deve validar dia util
                                ,pr_flproces => 1   --> Flag se deve validar se esta no processo
                                ,pr_flrepjob => 1   --> Flag para reprogramar o job
                                ,pr_flgerlog => 1   --> indicador se deve gerar log
                                ,pr_nmprogra => 'DSCT0001.pc_efetua_baixa_tit_car' --> Nome do programa que esta sendo executado no job
                                ,pr_dscritic => vr_dserro);
        -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_job');

        -- se nao retornou critica chama rotina
        IF trim(vr_dserro) IS NULL THEN
        
          FOR rw_crapcop IN cr_crapcop LOOP
           
            -- Cooperativa em execução - 15/02/2018 - Chamado 851591       
            vr_cdcooper := rw_crapcop.cdcooper;
            
            OPEN btch0001.cr_crapdat(rw_crapcop.cdcooper);
            FETCH btch0001.cr_crapdat  INTO rw_crapdat;
            CLOSE btch0001.cr_crapdat;
          
            --Verifica o dia util da cooperativa e caso nao for pula a coop
            vr_dtmvtolt := gene0005.fn_valida_dia_util(pr_cdcooper  => rw_crapcop.cdcooper
                                                      ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                                      ,pr_tipo      => 'A');
                                                    
            IF vr_dtmvtolt <> rw_crapdat.dtmvtolt THEN
              -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
              GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_job');
              CONTINUE;
            END IF;                                          
          
            -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
            GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_job');                                        

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
                 vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                 vr_ininsoco := 2; -- Indicador para gerar critica nas ocorrencias. 2 Não insere - 15/02/2018 - Chamado 851591
              ELSE
                --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                vr_cdcritic := 9998;
                vr_dscritic := vr_cdcritic || ' - ' || vr_dscritic;
              END IF;            
            
              RAISE vr_exc_erro; --grava log
            END IF;
            -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
            GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_job');
          
          END LOOP;
      
        ELSE
          vr_cdcritic := 0;
          vr_dscritic := vr_dserro;

          RAISE vr_exc_erro;  
        END IF;

      END IF; -- SD#497991

      -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_tit_job');

      -- Log de fim de execucao
      pc_controla_log_batch(pr_dstiplog => 'F');

      -- Limpa nome do módulo logado - 15/02/2018 - Chamado 851591
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);

    EXCEPTION
      WHEN vr_exc_erro THEN  
        --Indicador para gerar critica nas ocorrencias. 1 Insere, 2 Não insere. - 15/02/2018 - Chamado 851591                      
        IF vr_ininsoco = 1 THEN
        GENE0001.pc_gera_erro(pr_cdcooper => 3
                             ,pr_cdagenci => 1
                             ,pr_nrdcaixa => 100
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
				END IF;
                             
        -- Merge 1 - 15/02/2018 - Chamado 851591                     
        FOR idx in vr_tab_erro.FIRST .. vr_tab_erro.LAST LOOP
		                             
          vr_cdcritic := vr_tab_erro(idx).cdcritic;
          vr_dscritic := vr_tab_erro(idx).dscritic;

        -- Log de erro de execucao
          pc_controla_log_batch(pr_dstiplog => 'E'
                               ,pr_dscritic => vr_dscritic
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_tpocorrencia => 1
                               );							  
        END LOOP;

        ROLLBACK;
        
        -- Limpa nome do módulo logado - 15/02/2018 - Chamado 851591
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
        
      WHEN OTHERS THEN     
        -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
        CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper); 

        -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                      'DSCT0001.pc_efetua_baixa_tit_car_job. ' ||sqlerrm; 

        GENE0001.pc_gera_erro(pr_cdcooper => vr_cdcooper
                             ,pr_cdagenci => 1
                             ,pr_nrdcaixa => 100
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);

        -- Merge 1 - 15/02/2018 - Chamado 851591                     
        FOR idx in vr_tab_erro.FIRST .. vr_tab_erro.LAST LOOP
		                             
          vr_cdcritic := vr_tab_erro(idx).cdcritic;
          vr_dscritic := vr_tab_erro(idx).dscritic;
        -- Log de erro de execucao
          pc_controla_log_batch(pr_dstiplog => 'E'
                               ,pr_dscritic => vr_dscritic
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_tpocorrencia => 2
                               );							  
        END LOOP;

        ROLLBACK;                             
        
        -- Limpa nome do módulo logado - 15/02/2018 - Chamado 851591
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);                      
        
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
                                   ,pr_dtintegr    IN DATE         --Data da integração do pagamento -- Merge 1 - 15/02/2018 - Chamado 851591
                                   ,pr_cdcritic    OUT INTEGER     --Codigo Critica
                                   ,pr_dscritic    OUT VARCHAR2    --Descricao Critica
                                   ,pr_tab_erro    OUT GENE0001.typ_tab_erro) IS --Tabela erros
    -- .........................................................................
    --
    --  Programa : pc_efetua_baixa_titulo           Antigo: b1wgen0030.p/efetua_baixa_titulo
    --  Sistema  : Cred
    --  Sigla    : DSCT0001
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Julho/2013.                   Ultima atualizacao: 19/07/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para efetuar a baixa do titulo por pagamento ou vencimento
    --
    --   Programas chamadores:
    --             cxon0014.pc_gera_titulos_iptu    - Grava CRAPERR
    --             pc_crps375                       - Grava TBGEN
    --             pc_crps538                       - Grava TBGEN
    --             pc_crps594                       - Grava TBGEN
    --
    --  Alteracoes: 25/03/2015 - Remover o savepoint vr_save_baixa (Douglas - Chamado 267787)
    --             
    --              07/10/2016 - Quando pagamento do título é no mesmo dia da liberação do borderô
    --                           de desconto o valor do juro deve ser devolvido.
    --                           Incluído ELSIF para quando vr_qtdprazo=0  (SD#489111-AJFink)
    --
    --              15/02/2018 - Incluido nome do módulo logado
    --                           No caso de erro de programa gravar tabela especifica de log 
    --                           Ajuste mensagem de erro:
    --                           - Incluindo codigo e eliminando descrições fixas
    --                           - Gravando as informações de entrada de INSERTS, UPDATE e DELETES quando derem erro
    --                           - Incluído tratamento para não duplicar a mensagens na tbgen: vr_ininsoco
    --                          (Belli - Envolti - Chamado 851591) 
    --                           - Inclusão gravação log
    --                          (Ana - Envolti - Chamado 851591)      
    --              07/06/2018 - Alterado a procedure pc_efetua_baixa_titulo, onde:
    --                           1) A rotina atual é chamada somente para os pagamentos de títulos de borderôs inclusos na versão 
    --                              antiga (crapbdt.flverbor = 0)
    --                           2) Os pagamentos de títulos de borderôs novos (crapbdt.flverbor = 1) irá chamar a nova rotina de 
    --                              baixa de título DSCT0003.pc_pagar_titulo
    --                           Adicionado a rotina de abatimento de juros na procedure pc_abatimento_juros_titulo
    --                           (Paulo Penteado (GFT))      
    --
    --              19/07/2018 - Para os borderôs inclusos no sistema antes da nova versão de funcionalidade do bordero, quando houver 
    --                           o pagamento da operação de desconto, ou seja, do título vencido, através do débito em conta corrente 
    --                           deverá ser atualizada a coluna “Saldo Devedor” ficando zerada.(Paulo Penteado GFT)
    --
    --              01/11/2018 - Substituído a procedure dsct0003.pc_pagar_titulo pela dsct0003.pc_pagar_titulo_operacao que contempla a
    --                           a nova maneira de efetuar o pagamento de título de forma que os débitos não estourem a conta do
    --                           do cooperado (Luis Fernando GFT)
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
              ,crapcob.indpagto
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
              ,crapbdt.flverbor
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
      
	   -- Merge 1 - 15/02/2018 - Chamado 851591
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
      -- Excluida vr_contado1 não utilizada - 15/02/2018 - Chamado 851591 
      vr_dtmvtolt     DATE;
      vr_flgdsair     BOOLEAN;
      vr_flg_feriafds BOOLEAN;
      vr_flgcob       BOOLEAN;
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
      -- Excluida vr_index não utilizada - 15/02/2018 - Chamado 851591 
      vr_index_titulo VARCHAR2(20);
   	  vr_natjurid     crapjur.natjurid%TYPE;
      vr_tpregtrb     crapjur.tpregtrb%TYPE;
      vr_vliofpri     NUMBER(25,2);
      vr_vliofadi     NUMBER(25,2);
      vr_vliofcpl     NUMBER(25,2);
      vr_qtdiaiof     PLS_INTEGER;                          
      vr_flgimune     PLS_INTEGER; -- Merge 1 - 15/02/2018 - Chamado 851591                         
      vr_dtmvtolt_lcm craplcm.dtmvtolt%TYPE;
      vr_cdagenci_lcm craplcm.cdagenci%TYPE;
      vr_cdbccxlt_lcm craplcm.cdbccxlt%TYPE;
      vr_nrdolote_lcm craplcm.nrdolote%TYPE;
      vr_nrseqdig_lcm craplcm.nrseqdig%TYPE;
      vr_vltaxa_iof_principal NUMBER := 0;
      vr_cdagenci     crapass.cdagenci%TYPE;
      vr_vlpagmto     NUMBER;

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
      
      --Agrupa os parametros - 15/02/2018 - Chamado 851591 
      vr_dsparame VARCHAR2(4000);
      
    BEGIN
      -- Incluido nome do módulo logado - 15/02/2018 - Chamado 851591
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_titulo');
      
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591
      vr_dsparame :=  ' pr_cdcooper:' || pr_cdcooper || 
                      ', pr_cdagenci:' || pr_cdagenci || 
                      ', pr_nrdcaixa:' || pr_nrdcaixa || 
                      ', pr_cdoperad:' || pr_cdoperad ||
                      ', pr_dtmvtolt:' || pr_dtmvtolt || 
                      ', pr_idorigem:' || pr_idorigem || 
                      ', pr_nrdconta:' || pr_nrdconta || 
                      ', pr_indbaixa:' || pr_indbaixa;

      vr_dscritic:= NULL;
      vr_cdcritic:= 0;

      --Corrige o codigo do PA
      if nvl(pr_cdagenci,0) = 0 then
         vr_cdagenci := 1;
      else
         vr_cdagenci := pr_cdagenci;
      end if;

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
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      IF pr_idorigem = 1 THEN
        vr_dtmvtolt:= rw_crapdat.dtmvtolt;
      ELSE
        vr_dtmvtolt:= pr_dtmvtolt;
      END IF;  
      
      /* Leitura dos titulos para serem baixados */
      vr_index_titulo:= pr_tab_titulos.FIRST;

      WHILE vr_index_titulo IS NOT NULL LOOP
        BEGIN
          --Sair
          vr_flgdsair:= FALSE;
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
            --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
            vr_cdcritic := 1166; --Bordero nao encontrado.
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            -- Excluido GENE0001.pc_gera_erro esta no final da rotina - 15/02/2018 - Chamado 851591 
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          --Fechar Cursor
          CLOSE cr_crapbdt;

          --   Selecionar informacoes Cobranca
          OPEN cr_crapcob (pr_cdcooper => pr_cdcooper
                          ,pr_cdbandoc => pr_tab_titulos(vr_index_titulo).cdbandoc
                          ,pr_nrdctabb => pr_tab_titulos(vr_index_titulo).nrdctabb
                          ,pr_nrdconta => pr_tab_titulos(vr_index_titulo).nrdconta
                          ,pr_nrcnvcob => pr_tab_titulos(vr_index_titulo).nrcnvcob
                          ,pr_nrdocmto => pr_tab_titulos(vr_index_titulo).nrdocmto
                          ,pr_flgregis => 1);
          FETCH cr_crapcob INTO rw_crapcob;
          vr_flgcob := cr_crapcob%FOUND;
          CLOSE cr_crapcob;
          
          -- Efetuar baixa para os titulos da nova versão de funcionalidade do bordero. Se for a nova versão, entra na rotina abaixo e
          -- ao final da execução pula para o próximo título da lista. Se não for a nova versão, não entra na rotina abaixo e continua
          -- a efetivar a baixa conforme a versão antiga da funcionalizada do borderô.
          IF rw_crapbdt.flverbor = 1 THEN
            vr_vlpagmto := pr_tab_titulos(vr_index_titulo).vltitulo;
            dsct0003.pc_pagar_titulo_operacao(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => pr_nrdcaixa
                                    ,pr_idorigem => pr_idorigem
                                    ,pr_cdoperad => pr_cdoperad
                                    ,pr_nrdconta => rw_craptdb.nrdconta
                                    ,pr_nrborder => rw_craptdb.nrborder
                                    ,pr_cdbandoc => rw_craptdb.cdbandoc
                                    ,pr_nrdctabb => rw_craptdb.nrdctabb
                                    ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                    ,pr_nrdocmto => rw_craptdb.nrdocmto
                                    ,pr_dtmvtolt => vr_dtmvtolt
                                    ,pr_inproces => rw_crapdat.inproces
                                    ,pr_indpagto => rw_crapcob.indpagto
                                    ,pr_vlpagmto => vr_vlpagmto
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic );
            -- Condicao para verificar se houve critica                             
            IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
            --Se não der erro no pagamento acima, então ir para o proximo titulo, assim não roda o rotina abaixo
            --que é referente a baixa de titulo de bordero da versão antiga.
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

          -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
          GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_titulo');

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

            -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
            GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_titulo');

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

              -- PJ 450 Regulatório de credito
              -- Verifica se pode ou não fazer o débito/credito
              vr_fldebita := LANC0001.fn_pode_debitar(pr_cdcooper => pr_cdcooper,
                                                      pr_nrdconta => rw_craptdb.nrdconta,
                                                      pr_cdhistor => vr_cdhistor);

              IF vr_fldebita = FALSE THEN   
                 continue;
              END IF;
              
              /*[PROJETO LIGEIRINHO] Esta função retorna verdadeiro, quando o processo foi iniciado pela rotina:
                 PAGA0001.pc_efetua_debitos_paralelo, que é chamada na rotina PC_CRPS509. Tem por finalidade definir
                 se grava na tabela CRAPLOT no momento em que esta rodando a esta rotina OU somente no final da execucação
                 da PC_CRPS509, para evitar o erro de lock da tabela, pois esta gravando a agencia 90,91 ou 1 ao inves de gravar
                 a agencia do cooperado*/
                 
              if not paga0001.fn_exec_paralelo then  
                /* Leitura do lote */
                OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                                ,pr_dtmvtolt => pr_dtmvtolt
                                ,pr_cdagenci => vr_cdagenci   --1 --Substituido (1) para Agencia do Parâmetro  --Paralelismo --AMcom
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
                      ,vr_cdagenci  --1 --Substituido (1) para Agencia do Parâmetro  --Paralelismo --AMcom
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
                      --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                      vr_cdcritic := 59; --Lote ja cadastrado.
                      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                      RAISE vr_exc_erro;
                    WHEN OTHERS THEN
                      -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
                      -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                      vr_cdcritic := 1034;
                      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                               'craplot(1):'   ||
                               ', cdcooper:'    || pr_cdcooper || 
                               ', dtmvtolt:'    || pr_dtmvtolt || 
                               ', cdagenci:'    || '1'         ||
                               ', cdbccxlt:'    || '100'       ||
                               ', nrdolote:'    || '10300'     || 
                               ', cdoperad:'    || pr_cdoperad ||
                               ', tplotmov:'    || '1'         ||
                               ', cdhistor:'    || vr_cdhistor ||
                               '. ' ||sqlerrm; 
                      RAISE vr_exc_erro;
                  END;
                END IF;
                --Fechar Cursor
                IF cr_craplot%ISOPEN THEN
                  CLOSE cr_craplot;
                END IF;
                rw_craplot.nrseqdig:= rw_craplot.nrseqdig + 1; -- projeto ligeirinho
              else
                paga0001.pc_insere_lote_wrk (pr_cdcooper => pr_cdcooper,
                                             pr_dtmvtolt => pr_dtmvtolt,
                                             pr_cdagenci => 1,
                                             pr_cdbccxlt => 100,
                                             pr_nrdolote => 10300,
                                             pr_cdoperad => pr_cdoperad,
                                             pr_nrdcaixa => NULL,
                                             pr_tplotmov => 1,
                                             pr_cdhistor => vr_cdhistor,
                                             pr_cdbccxpg => null,
                                             pr_nmrotina => 'DSCT0001.PC_EFETUA_BAIXA_TITULO');
                
                  rw_craplot.dtmvtolt := pr_dtmvtolt;
                  rw_craplot.cdagenci := 1;
                  rw_craplot.cdbccxlt := 100;
                  rw_craplot.nrdolote := 10300;
                  rw_craplot.nrseqdig := PAGA0001.fn_seq_parale_craplcm; 
              end if;  
              --Gravar lancamento
          -- P450 - Regulatório de crédito
          lanc0001.pc_gerar_lancamento_conta(
                      pr_dtmvtolt => rw_craplot.dtmvtolt
                     ,pr_cdagenci => rw_craplot.cdagenci
                     ,pr_cdbccxlt => rw_craplot.cdbccxlt
                     ,pr_nrdolote => rw_craplot.nrdolote
                     ,pr_nrdconta => rw_craptdb.nrdconta
                     ,pr_nrdctabb => rw_craptdb.nrdconta
                     ,pr_cdpesqbb => rw_craptdb.nrdocmto
                     ,pr_cdcooper => pr_cdcooper
                     ,pr_nrdocmto => Nvl(rw_craplot.nrseqdig,0)
                     ,pr_cdhistor => vr_cdhistor
                     ,pr_nrseqdig => Nvl(rw_craplot.nrseqdig,0)
                     ,pr_vllanmto => rw_craptdb.vltitulo - pr_tab_titulos(vr_index_titulo).vltitulo 
                     ,pr_nrautdoc => 0
                     -- retorno
                     ,pr_tab_retorno => vr_tab_retorno
                     ,pr_incrineg => vr_incrineg
                     ,pr_cdcritic => vr_cdcritic
                     ,pr_dscritic => vr_dscritic);

              IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
                 IF vr_incrineg = 0 THEN -- Erro de sistema/BD
                  -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                  CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);     
                  -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                  vr_cdcritic := 1034;
                  vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                               'craplcm(3):'  ||
                               ' dtmvtolt:'    || rw_craplot.dtmvtolt ||
                               ', cdagenci:'   || rw_craplot.cdagenci ||
                               ', cdbccxlt:'   || rw_craplot.cdbccxlt ||
                               ', nrdolote:'   || rw_craplot.nrdolote ||
                               ', nrdconta:'   || rw_craptdb.nrdconta ||
                               ', nrdocmto:'   || Nvl(rw_craplot.nrseqdig,0) || ' + 1' ||
                               ', vllanmto:'   || rw_craptdb.vltitulo ||' - '|| pr_tab_titulos(vr_index_titulo).vltitulo ||
                               ', cdhistor:'   || vr_cdhistor         ||
                               ', nrseqdig:'   || Nvl(rw_craplot.nrseqdig,0) || ' + 1' ||
                               ', nrdctabb:'   || rw_craptdb.nrdconta ||
                               ', nrautdoc:'   || '0'                 ||
                               ', cdcooper:'   || pr_cdcooper         ||
                               ', cdpesqbb:'   || rw_craptdb.nrdocmto ||
                               '. ' ||sqlerrm; 
                  RAISE vr_exc_erro;
                 END IF;
              END IF;              
              rw_craplcm.nrseqdig := Nvl(rw_craplot.nrseqdig,0);
              rw_craplcm.vllanmto := rw_craptdb.vltitulo - pr_tab_titulos(vr_index_titulo).vltitulo;
             
              /*[PROJETO LIGEIRINHO] Esta função retorna verdadeiro, quando o processo foi iniciado pela rotina:
                 PAGA0001.pc_efetua_debitos_paralelo, que é chamada na rotina PC_CRPS509. Tem por finalidade definir
                 se grava na tabela CRAPLOT no momento em que esta rodando a esta rotina OU somente no final da execucação
                 da PC_CRPS509, para evitar o erro de lock da tabela, pois esta gravando a agencia 90,91 ou 1 ao inves de gravar
                 a agencia do cooperado*/
                 
              if not paga0001.fn_exec_paralelo then  
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
                    -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                    CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);       
                    -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                    vr_cdcritic := 1035;
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)  || 
                                 ' craplot(1):'||
                                 ' qtinfoln:'  || 'Nvl(craplot.qtinfoln,0) + 1' ||
                                 ', qtcompln:' || 'Nvl(craplot.qtcompln,0) + 1'||
                                 ', nrseqdig:' || Nvl(rw_craplcm.nrseqdig,0) ||
                                 ', vlinfocr:' || 'Nvl(craplot.vlinfocr,0) + ' ||rw_craplcm.vllanmto||
                                 ', vlcompcr:' || 'Nvl(craplot.vlcompcr,0) + ' ||rw_craplcm.vllanmto||
                                 ', ROWID:' || rw_craplot.ROWID  || 
                                 '. ' ||sqlerrm; 
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END;
                --Acumular Valor Lancamento
                vr_vllanmto:= nvl(vr_vllanmto,0) + rw_craplcm.vllanmto;
              END IF;

            ELSIF rw_craptdb.vltitulo < pr_tab_titulos(vr_index_titulo).vltitulo THEN

              /* se pagamento a maior */
              --Montar Historico
              IF NOT pr_tab_titulos(vr_index_titulo).flgregis THEN
                vr_cdhistor:= 1100;
              ELSE
                vr_cdhistor:= 1102;
              END IF;
              
              -- PJ 450 Regulatório de credito
              -- Verifica se pode ou não fazer o débito/credito
              vr_fldebita := LANC0001.fn_pode_debitar(pr_cdcooper => pr_cdcooper,
                                                      pr_nrdconta => rw_craptdb.nrdconta,
                                                      pr_cdhistor => vr_cdhistor);

              IF vr_fldebita = FALSE THEN   
                 continue;
              END IF;

              
              /*[PROJETO LIGEIRINHO] Esta função retorna verdadeiro, quando o processo foi iniciado pela rotina:
                 PAGA0001.pc_efetua_debitos_paralelo, que é chamada na rotina PC_CRPS509. Tem por finalidade definir
                 se grava na tabela CRAPLOT no momento em que esta rodando a esta rotina OU somente no final da execucação
                 da PC_CRPS509, para evitar o erro de lock da tabela, pois esta gravando a agencia 90,91 ou 1 ao inves de gravar
                 a agencia do cooperado*/ 
              if not paga0001.fn_exec_paralelo then  
                /* Leitura do lote */
                OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                                ,pr_dtmvtolt => pr_dtmvtolt
                                ,pr_cdagenci => vr_cdagenci  --1  --Substituido (1) para Agencia do Parâmetro --AMcom
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
                      ,vr_cdagenci  --1  --Substituido (1) para Agencia do Parâmetro  --AMcom
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
                      --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                      vr_cdcritic := 59; --Lote ja cadastrado.
                      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                      RAISE vr_exc_erro;
                    WHEN OTHERS THEN
                      -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);     
                      -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                      vr_cdcritic := 1034;
                      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||
                               'craplot(2):' ||
                               ' cdcooper:'   || pr_cdcooper ||
                               ', dtmvtolt:'  || pr_dtmvtolt ||
                               ', cdagenci:'  || '1'     ||
                               ', cdbccxlt:'  || '100'   ||
                               ', nrdolote:'  || '10300' ||
                               ', cdoperad:'  || pr_cdoperad ||
                               ', tplotmov:'  || '1' ||
                               ', cdhistor:'  || vr_cdhistor ||
                               '. ' ||sqlerrm; 
                      RAISE vr_exc_erro;
                  END;
                END IF;
                --Fechar Cursor
                IF cr_craplot%ISOPEN THEN
                  CLOSE cr_craplot;
                END IF;
                rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1; -- projeto ligeirinho
              ELSE
                paga0001.pc_insere_lote_wrk (pr_cdcooper => pr_cdcooper,
                                             pr_dtmvtolt => pr_dtmvtolt,
                                             pr_cdagenci => 1,
                                             pr_cdbccxlt => 100,
                                             pr_nrdolote => 10300,
                                             pr_cdoperad => pr_cdoperad,
                                             pr_nrdcaixa => NULL,
                                             pr_tplotmov => 1,
                                             pr_cdhistor => vr_cdhistor,
                                             pr_cdbccxpg => null,
                                             pr_nmrotina => 'DSCT0001.PC_EFETUA_BAIXA_TITULO');
                            
                rw_craplot.dtmvtolt := pr_dtmvtolt;                  
                rw_craplot.cdagenci := 1;                   
                rw_craplot.cdbccxlt := 100;                  
                rw_craplot.nrdolote := 10300;                   
                rw_craplot.nrseqdig := PAGA0001.fn_seq_parale_craplcm; 
              END IF;
              
              --Gravar lancamento
              -- P450 - Regulatório de crédito
              lanc0001.pc_gerar_lancamento_conta(
                          pr_dtmvtolt => rw_craplot.dtmvtolt
                         ,pr_cdagenci => rw_craplot.cdagenci
                         ,pr_cdbccxlt => rw_craplot.cdbccxlt
                         ,pr_nrdolote => rw_craplot.nrdolote
                         ,pr_nrdconta => rw_craptdb.nrdconta
                         ,pr_nrdctabb => rw_craptdb.nrdconta
                         ,pr_cdpesqbb => rw_craptdb.nrdocmto
                         ,pr_cdcooper => pr_cdcooper
                         ,pr_nrdocmto => Nvl(rw_craplot.nrseqdig,0)
                         ,pr_cdhistor => vr_cdhistor
                         ,pr_nrseqdig => Nvl(rw_craplot.nrseqdig,0)
                         ,pr_vllanmto => pr_tab_titulos(vr_index_titulo).vltitulo - rw_craptdb.vltitulo
                         ,pr_nrautdoc => 0
                         -- retorno
                         ,pr_tab_retorno => vr_tab_retorno
                         ,pr_incrineg => vr_incrineg
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);

              IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
                 IF vr_incrineg = 0 THEN -- Erro de sistema/BD
                  -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                  CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
                  -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                  vr_cdcritic := 1034;
                  vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||
                                   'craplot(3):'||
                                   ' dtmvtolt:'  || rw_craplot.dtmvtolt ||
                                   ', cdagenci:' || rw_craplot.cdagenci ||
                                   ', cdbccxlt:' || rw_craplot.cdbccxlt ||
                                   ', nrdolote:' || rw_craplot.nrdolote ||
                                   ', nrdconta:' || rw_craptdb.nrdconta ||
                                   ', nrdocmto:' || Nvl(rw_craplot.nrseqdig,0) || ' + 1' ||
                                   ', vllanmto:' || pr_tab_titulos(vr_index_titulo).vltitulo ||' - '|| rw_craptdb.vltitulo ||
                                   ', cdhistor:' || vr_cdhistor ||
                                   ', nrseqdig:' || Nvl(rw_craplot.nrseqdig,0) || ' + 1' ||
                                   ', nrdctabb:' || rw_craptdb.nrdconta ||
                                   ', nrautdoc:' || '0' ||
                                   ', cdcooper:' || pr_cdcooper ||
                                   ', cdpesqbb:' || rw_craptdb.nrdocmto ||
                                   '. ' ||sqlerrm; 
                  RAISE vr_exc_erro;
                 END IF;
              END IF;

              rw_craplcm.nrseqdig:= Nvl(rw_craplot.nrseqdig,0);
              rw_craplcm.vllanmto:= pr_tab_titulos(vr_index_titulo).vltitulo - rw_craptdb.vltitulo;          

              /*[PROJETO LIGEIRINHO] Esta função retorna verdadeiro, quando o processo foi iniciado pela rotina:
                 PAGA0001.pc_efetua_debitos_paralelo, que é chamada na rotina PC_CRPS509. Tem por finalidade definir se este update
                 deve ser feito agora ou somente no final. da execução da PC_CRPS509 (chamada da paga0001.pc_atualiz_lote)*/
              if not paga0001.fn_exec_paralelo then
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
                    -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                    CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);     
                    -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                    vr_cdcritic := 1035;
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)  || 
                                 ' craplot(2):'||
                                 ' qtinfoln:'  || 'Nvl(craplot.qtinfoln,0) + 1' ||
                                 ', qtcompln:' || 'Nvl(craplot.qtcompln,0) + 1 '||
                                 ', nrseqdig:' || Nvl(rw_craplcm.nrseqdig,0) ||
                                 ', vlinfocr:' || 'Nvl(craplot.vlinfocr,0) + ' || rw_craplcm.vllanmto ||
                                 ', vlcompcr:' || 'Nvl(craplot.vlcompcr,0) + ' || rw_craplcm.vllanmto ||
                                 ', ROWID:'    || rw_craplot.ROWID  || 
                                 '. ' ||sqlerrm; 
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END;
                
              END IF;
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
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
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
              
		      	  -- Merge 1 - 15/02/2018 - Chamado 851591
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
              vr_qtdiaiof := CASE WHEN rw_crapcob_iof.dtdpagto IS NOT NULL THEN rw_crapcob_iof.dtdpagto ELSE pr_dtintegr END - rw_craptdb.dtvencto;
              
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
                                           ,pr_flgimune   => vr_flgimune -- Merge 1 - 15/02/2018 - Chamado 851591
									       );

              -- Condicao para verificar se houve critica
              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;
                                                    
              -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
              GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_titulo');
			  
              -- PJ 450 Regulatório de credito
              -- Verifica se pode ou não fazer o débito/credito
              vr_fldebita := LANC0001.fn_pode_debitar(pr_cdcooper => pr_cdcooper,
                                                      pr_nrdconta => rw_craptdb.nrdconta,
                                                      pr_cdhistor => 2321);

              IF vr_fldebita = FALSE THEN   
                 continue;
              END IF;

              /*[PROJETO LIGEIRINHO] Esta função retorna verdadeiro, quando o processo foi iniciado pela rotina:
                 PAGA0001.pc_efetua_debitos_paralelo, que é chamada na rotina PC_CRPS509. Tem por finalidade definir
                 se grava na tabela CRAPLOT no momento em que esta rodando a esta rotina OU somente no final da execucação
                 da PC_CRPS509, para evitar o erro de lock da tabela, pois esta gravando a agencia 90,91 ou 1 ao inves de gravar
                 a agencia do cooperado*/
				/* Ajuste quando paralelismo #40089 */
              if not paga0001.fn_exec_paralelo then
                -- Vamos verificar se o valo do IOF complementar é maior que 0
              IF NVL(vr_vliofcpl,0) > 0 AND vr_flgimune <= 0 THEN -- Merge 1 - 15/02/2018 - Chamado 851591
                  /* Leitura do lote */
                  OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                                  ,pr_dtmvtolt => vr_dtmvtolt
                                  ,pr_cdagenci => vr_cdagenci  --1  --Substituido (1) para Agencia do Parâmetro  --AMcom
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
                        ,vr_cdagenci --1  --Substituido (1) para Agencia do Parâmetro --AMcom
                        ,100
                        ,10300
                        ,pr_cdoperad
                        ,01
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
                        --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                        vr_cdcritic := 59; --Lote ja cadastrado.
                        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                        RAISE vr_exc_erro;
                      WHEN OTHERS THEN
                        -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);     
                        -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                        vr_cdcritic := 1034;
                        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                                     'craplot(4):'||
                                     ' cdcooper:'  || pr_cdcooper ||
                                     ', dtmvtolt:' || pr_dtmvtolt ||
                                     ', cdagenci:' || '1'     ||
                                     ', cdbccxlt:' || '100'   ||
                                     ', nrdolote:' || '10300' ||
                                     ', cdoperad:' || pr_cdoperad ||
                                     ', tplotmov:' || '1'    ||
                                     ', cdhistor:' || '2321' ||
                                     '. ' ||sqlerrm; 
                        RAISE vr_exc_erro;
                    END;
                  END IF;
                  --Fechar Cursor
                  IF cr_craplot%ISOPEN THEN
                    CLOSE cr_craplot;
                  END IF;
                  rw_craplot.nrseqdig:= rw_craplot.nrseqdig + 1; -- projeto ligeirinho
                ELSE
                  paga0001.pc_insere_lote_wrk (pr_cdcooper => pr_cdcooper,
                                               pr_dtmvtolt => pr_dtmvtolt,
                                               pr_cdagenci => 1,
                                               pr_cdbccxlt => 100,
                                               pr_nrdolote => 10300,
                                               pr_cdoperad => pr_cdoperad,
                                               pr_nrdcaixa => NULL,
                                               pr_tplotmov => 1,
                                               pr_cdhistor => 2321,
                                               pr_cdbccxpg => null,
                                               pr_nmrotina => 'DSCT0001.PC_EFETUA_BAIXA_TITULO');
                            
                  rw_craplot.dtmvtolt := pr_dtmvtolt;                  
                  rw_craplot.cdagenci := 1;                   
                  rw_craplot.cdbccxlt := 100;                  
                  rw_craplot.nrdolote := 10300;                                     
                  rw_craplot.nrseqdig := PAGA0001.fn_seq_parale_craplcm; 
                END IF;  
                
                --Gravar lancamento
                -- P450 - Regulatório de crédito
                lanc0001.pc_gerar_lancamento_conta(
                            pr_dtmvtolt => rw_craplot.dtmvtolt
                           ,pr_cdagenci => rw_craplot.cdagenci
                           ,pr_cdbccxlt => rw_craplot.cdbccxlt
                           ,pr_nrdolote => rw_craplot.nrdolote
                           ,pr_nrdconta => rw_craptdb.nrdconta
                           ,pr_nrdctabb => rw_craptdb.nrdconta
                           ,pr_cdpesqbb => rw_craptdb.nrdocmto
                           ,pr_cdcooper => pr_cdcooper
                           ,pr_nrdocmto => NVL(rw_craplot.nrseqdig,0) 
                           ,pr_cdhistor => 2321
                           ,pr_nrseqdig => NVL(rw_craplot.nrseqdig,0)
                           ,pr_vllanmto => vr_vliofcpl
                           ,pr_nrautdoc => 0
                           -- retorno
                           ,pr_tab_retorno => vr_tab_retorno
                           ,pr_incrineg => vr_incrineg
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);

                IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
                   IF vr_incrineg = 0 THEN -- Erro de sistema/BD
                    -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                    CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);     
                    -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                    vr_cdcritic := 1034;
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                                   'craplcm(4):'||
                                   ' dtmvtolt:'  || rw_craplot.dtmvtolt ||
                                   ', cdagenci:' || rw_craplot.cdagenci ||
                                   ', cdbccxlt:' || rw_craplot.cdbccxlt ||
                                   ', nrdolote:' || rw_craplot.nrdolote ||
                                   ', nrdconta:' || rw_craptdb.nrdconta ||
                                   ', nrdocmto:' || NVL(rw_craplot.nrseqdig,0) || ' + 1' ||
                                   ', vllanmto:' || vr_vliofcpl ||
                                   ', cdhistor:' || '2321' ||
                                   ', nrseqdig:' || NVL(rw_craplot.nrseqdig,0) || ' + 1' ||
                                   ', nrdctabb:' || rw_craptdb.nrdconta ||
                                   ', nrautdoc:' || '0' ||
                                   ', cdcooper:' || pr_cdcooper ||
                                   ', cdpesqbb:' || rw_craptdb.nrdocmto ||
                                   '. ' ||sqlerrm; 
                    RAISE vr_exc_erro;
                   END IF;
                END IF;    
                vr_dtmvtolt_lcm := rw_craplot.dtmvtolt;
                vr_cdagenci_lcm := rw_craplot.cdagenci;
                vr_cdbccxlt_lcm := rw_craplot.cdbccxlt;
                vr_nrdolote_lcm := rw_craplot.nrdolote;
                vr_nrseqdig_lcm := NVL(rw_craplot.nrseqdig,0);
                rw_craplcm.vllanmto:=  vr_vliofcpl;          

                /*[PROJETO LIGEIRINHO] Esta função retorna verdadeiro, quando o processo foi iniciado pela rotina:
                PAGA0001.pc_efetua_debitos_paralelo, que é chamada na rotina PC_CRPS509. Tem por finalidade definir se este update
       	        deve ser feito agora ou somente no final. da execução da PC_CRPS509 (chamada da paga0001.pc_atualiz_lote)*/
                
                if not paga0001.fn_exec_paralelo then
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
                      -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);     
                      -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                      vr_cdcritic := 1035;
                      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)  || 
                                   'craplot(3):'||
                                   ' qtinfoln:'  || 'Nvl(craplot.qtinfoln,0) + 1'||
                                   ', qtcompln:' || 'Nvl(craplot.qtcompln,0) + 1'||
                                   ', nrseqdig:' ||  Nvl(vr_nrseqdig_lcm,0)      ||
                                   ', vlinfocr:' || 'Nvl(craplot.vlinfocr,0) + ' || rw_craplcm.vllanmto ||
                                   ', vlcompcr:' || 'Nvl(craplot.vlcompcr,0) + ' || rw_craplcm.vllanmto ||
                                   ', ROWID:'    || rw_craplot.ROWID  || 
                                   '. ' ||sqlerrm; 
                      --Levantar Excecao
                      RAISE vr_exc_erro;
                  END;
                END IF;
                
              END IF;
              
              -- Procedure para inserir o valor do IOF
              TIOF0001.pc_insere_iof(pr_cdcooper     => pr_cdcooper
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
                                    ,pr_flgimune     => vr_flgimune -- Merge 1 - 15/02/2018 - Chamado 851591
                                    ,pr_cdcritic     => vr_cdcritic
                                    ,pr_dscritic     => vr_dscritic);
                                      
              -- Condicao para verificar se houve critica                             
              IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF; 
                                                    
              -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
              GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_titulo');
              
              ------------------------------------------------------------------------------------------
              -- Fim Efetuar o Lancamento de IOF
              ------------------------------------------------------------------------------------------                
            END IF;

            --Atualizar situacao titulo
            BEGIN
              UPDATE craptdb 
                 SET craptdb.insittit = 2
                                ,craptdb.dtdpagto = vr_dtmvtolt
                    ,craptdb.vlsldtit = 0
              WHERE craptdb.ROWID = rw_craptdb.ROWID
              RETURNING craptdb.dtdpagto INTO rw_craptdb.dtdpagto;
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
                -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                vr_cdcritic := 1035;
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)   || 
                               'craptdb(2):'||
                               ' insittit:'  || '2' ||
                               ', dtdpagto:' || vr_dtmvtolt ||
                               ', ROWID:'    || rw_craptdb.ROWID  || 
                               '. ' ||sqlerrm; 
                --Levantar Excecao
                RAISE vr_exc_erro;
            END;
          ELSIF pr_indbaixa = 2 THEN
            
            -- PJ 450 Regulatório de credito
            -- Verifica se pode ou não fazer o débito/credito
            vr_fldebita := LANC0001.fn_pode_debitar(pr_cdcooper => pr_cdcooper,
                                                    pr_nrdconta => rw_craptdb.nrdconta,
                                                    pr_cdhistor => 591);

            IF vr_fldebita = FALSE THEN   
               CONTINUE;
            END IF;
          
            /*[PROJETO LIGEIRINHO] Esta função retorna verdadeiro, quando o processo foi iniciado pela rotina:
             PAGA0001.pc_efetua_debitos_paralelo, que é chamada na rotina PC_CRPS509. Tem por finalidade definir
             se grava na tabela CRAPLOT no momento em que esta rodando a esta rotina OU somente no final da execucação
             da PC_CRPS509, para evitar o erro de lock da tabela, pois esta gravando a agencia 90,91 ou 1 ao inves de gravar
             a agencia do cooperado*/

            if not paga0001.fn_exec_paralelo then
              /* Leitura do lote */
              OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                              ,pr_dtmvtolt => pr_dtmvtolt
                              ,pr_cdagenci => vr_cdagenci --1  --Substituido (1) para Agencia do Parâmetro  --AMcom
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
                      ,vr_cdagenci --1  --Substituido (1) para Agencia do Parâmetro  --AMcom
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
                    --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                    vr_cdcritic := 59; --Lote ja cadastrado.
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                    RAISE vr_exc_erro;
                  WHEN OTHERS THEN
                    -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                    CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);      
                    -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                    vr_cdcritic := 1034;
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                                   'craplot(5):'||
                                   ' cdcooper:'  || pr_cdcooper ||
                                   ', dtmvtolt:' || pr_dtmvtolt ||
                                   ', cdagenci:' || '1'     ||
                                   ', cdbccxlt:' || '100'   ||
                                   ', nrdolote:' || '10300' ||
                                   ', cdoperad:' || pr_cdoperad ||
                                   ', tplotmov:' || '1'   ||
                                   ', cdhistor:' || '591' ||
                                   '. ' ||sqlerrm; 
                    RAISE vr_exc_erro;
                END;
              END IF;
              --Fechar Cursor
              IF cr_craplot%ISOPEN THEN
                CLOSE cr_craplot;
              END IF;
              rw_craplot.nrseqdig:= rw_craplot.nrseqdig + 1; -- projeto ligeirinho
            ELSE
              paga0001.pc_insere_lote_wrk (pr_cdcooper => pr_cdcooper,
                                           pr_dtmvtolt => pr_dtmvtolt,
                                           pr_cdagenci => 1,
                                           pr_cdbccxlt => 100,
                                           pr_nrdolote => 10300,
                                           pr_cdoperad => pr_cdoperad,
                                           pr_nrdcaixa => NULL,
                                           pr_tplotmov => 1,
                                           pr_cdhistor => 591,
                                           pr_cdbccxpg => null,
                                           pr_nmrotina => 'DSCT0001.PC_EFETUA_BAIXA_TITULO');
                            
              rw_craplot.dtmvtolt := pr_dtmvtolt;                  
              rw_craplot.cdagenci := 1;                   
              rw_craplot.cdbccxlt := 100;                  
              rw_craplot.nrdolote := 10300;  
              rw_craplot.nrseqdig := PAGA0001.fn_seq_parale_craplcm;                                   
              
            END IF;
            
            --Gravar lancamento
            -- P450 - Regulatório de crédito
            lanc0001.pc_gerar_lancamento_conta(
                        pr_dtmvtolt => rw_craplot.dtmvtolt
                       ,pr_cdagenci => rw_craplot.cdagenci
                       ,pr_cdbccxlt => rw_craplot.cdbccxlt
                       ,pr_nrdolote => rw_craplot.nrdolote
                       ,pr_nrdconta => rw_craptdb.nrdconta
                       ,pr_nrdctabb => rw_craptdb.nrdconta
                       ,pr_cdpesqbb => rw_craptdb.nrdocmto
                       ,pr_cdcooper => pr_cdcooper
                       ,pr_nrdocmto => Nvl(rw_craplot.nrseqdig,0)
                       ,pr_cdhistor => 591
                       ,pr_nrseqdig => Nvl(rw_craplot.nrseqdig,0)
                       ,pr_vllanmto => pr_tab_titulos(vr_index_titulo).vltitulo
                       ,pr_nrautdoc => 0
                       -- retorno
                       ,pr_tab_retorno => vr_tab_retorno
                       ,pr_incrineg => vr_incrineg
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic);

            IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
               IF vr_incrineg = 0 THEN -- Erro de sistema/BD
                -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
                -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                vr_cdcritic := 1034;
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||
                                   'craplcm(5):'||
                                   ' dtmvtolt:'  || rw_craplot.dtmvtolt ||
                                   ', cdagenci:' || rw_craplot.cdagenci ||
                                   ', cdbccxlt:' || rw_craplot.cdbccxlt ||
                                   ', nrdolote:' || rw_craplot.nrdolote ||
                                   ', nrdconta:' || rw_craptdb.nrdconta ||
                                   ', nrdocmto:' || Nvl(rw_craplot.nrseqdig,0) || ' + 1' ||
                                   ', vllanmto:' || pr_tab_titulos(vr_index_titulo).vltitulo ||' - '|| rw_craptdb.vltitulo ||
                                   ', cdhistor:' || '591' ||
                                   ', nrseqdig:' || Nvl(rw_craplot.nrseqdig,0) || ' + 1' ||
                                   ', nrdctabb:' || rw_craptdb.nrdconta ||
                                   ', nrautdoc:' || '0' ||
                                   ', cdcooper:' || pr_cdcooper ||
                                   ', cdpesqbb:' || rw_craptdb.nrdocmto ||
                                   '. ' ||sqlerrm; 
                RAISE vr_exc_erro;
               END IF;
            END IF; 
            rw_craplcm.nrseqdig:= Nvl(rw_craplot.nrseqdig,0);
            rw_craplcm.vllanmto:= pr_tab_titulos(vr_index_titulo).vltitulo;
            
            
            /*[PROJETO LIGEIRINHO] Esta função retorna verdadeiro, quando o processo foi iniciado pela rotina:
              PAGA0001.pc_efetua_debitos_paralelo, que é chamada na rotina PC_CRPS509. Tem por finalidade definir se este update
              deve ser feito agora ou somente no final. da execução da PC_CRPS509 (chamada da paga0001.pc_atualiz_lote)*/
            if not paga0001.fn_exec_paralelo then
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
                  -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                  CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);    
                  -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                  vr_cdcritic := 1035;
                  vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)  || 
                               'craplot(4):'||
                               ' qtinfoln:'  || 'Nvl(craplot.qtinfoln,0) + 1' ||
                               ', qtcompln:' || 'Nvl(craplot.qtcompln,0) + 1' ||
                               ', nrseqdig:' || Nvl(rw_craplcm.nrseqdig,0) ||
                               ', vlinfocr:' || 'Nvl(craplot.vlinfocr,0) + ' || rw_craplcm.vllanmto ||
                               ', vlcompcr:' || 'Nvl(craplot.vlcompcr,0) + ' || rw_craplcm.vllanmto ||
                               ', ROWID:'    || rw_craplot.ROWID  || 
                               '. ' ||sqlerrm; 
                --Levantar Excecao
                RAISE vr_exc_erro;
              END;
            END IF;            
            
            --Atualizar situacao titulo
            BEGIN
              UPDATE craptdb 
                 SET craptdb.insittit = 3 /* Baixado s/ pagto */
                    ,craptdb.vlsldtit = 0
              WHERE craptdb.ROWID = rw_craptdb.ROWID;
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
                -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                vr_cdcritic := 1035;
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 
                               'craptdb(3):'||
                               ' insittit:'  || '3' ||
                               ', ROWID:'    || rw_craptdb.ROWID  || 
                               '. ' ||sqlerrm; 
                --Levantar Excecao
                RAISE vr_exc_erro;
            END;
            IF vr_flgcob THEN
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
                                                    
              -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
              GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_titulo');
            END IF;
          END IF; /* Final da baixa por vencimento */

          -- PJ 450 Regulatório de credito
          -- Verifica se pode ou não fazer o débito/credito
          vr_fldebita := LANC0001.fn_pode_debitar(pr_cdcooper => pr_cdcooper,
                                                  pr_nrdconta => rw_craptdb.nrdconta,
                                                  pr_cdhistor => 597);

          IF vr_fldebita = TRUE THEN
            pc_abatimento_juros_titulo(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => rw_craptdb.nrdconta
                                      ,pr_nrborder => rw_craptdb.nrborder
                                      ,pr_cdbandoc => rw_craptdb.cdbandoc
                                      ,pr_nrdctabb => rw_craptdb.nrdctabb
                                      ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                      ,pr_nrdocmto => rw_craptdb.nrdocmto
                                      ,pr_dtmvtolt => pr_dtmvtolt
                                      ,pr_cdagenci => vr_cdagenci
                                      ,pr_cdoperad => pr_cdoperad
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
            IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;

          /* Verifica se deve liquidar o bordero caso sim Liquida */
          DSCT0001.pc_efetua_liquidacao_bordero (pr_cdcooper => pr_cdcooper  --Codigo Cooperativa
                                                ,pr_cdagenci => vr_cdagenci  --Codigo Agencia
                                                ,pr_nrdcaixa => pr_nrdcaixa  --Numero do Caixa
                                                ,pr_cdoperad => pr_cdoperad  --Codigo Operador
                                                ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                                ,pr_idorigem => pr_idorigem  --Identificador Origem
                                                ,pr_nrdconta => pr_nrdconta  --Numero da Conta
                                                ,pr_nrborder => rw_craptdb.nrborder  --Numero do Bordero
                                                ,pr_tab_erro => vr_tab_erro   --Tabela de erros
                                                ,pr_des_erro => vr_des_erro   --identificador de erro
                                                ,pr_cdcritic => vr_cdcritic   --Código do erro
                                                ,pr_dscritic => vr_dscritic); --Descricao do erro;

 	        -- Merge 1 - 15/02/2018 - Chamado 851591
          IF NVL(LENGTH(TRIM(vr_dscritic)),0) > 0 THEN
            GENE0001.pc_gera_erro(pr_cdcooper => rw_craptdb.cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => 1 /** Sequencia **/
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => vr_tab_erro);
          END IF;

          --Se ocorreu erro
          IF vr_des_erro = 'NOK' THEN
            -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
            --Mensagem erro
            vr_cdcritic:= 1190; -- Erro na liquidacao do bordero
            vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                          ' Bordero:' || rw_craptdb.nrborder ||
                          ', conta:'  || rw_craptdb.nrdconta;
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

          -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
          GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_titulo');

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

            -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
            GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_titulo');

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

            -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
            GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_titulo');

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
                                               ,pr_cdagenci => vr_cdagenci --1      --Codigo Agencia   --Substituido Paralelismo
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
                -- Excluido vr_cdcritic:= 0; - 15/02/2018 - Chamado 851591 
                -- Excluido GENE0001.pc_gera_erro pois o erro ja esta no array - 15/02/2018 - Chamado 851591 
                --Levantar Excecao
                RAISE vr_exc_erro;
              ELSE
                --Marcar que tarifa ja foi cobrada da conta
                vr_tab_conta(pr_tab_titulos(vr_index_titulo).nrdconta):= 0;
                                                    
                -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
                GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_baixa_titulo');
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
            -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
            -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591      
            --Montar Mensagem Erro
            vr_cdcritic := 9999;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                           'Loop principal. '||sqlerrm;
            RAISE vr_exc_erro;
        END;
        --Proximo registro
        vr_index_titulo:= pr_tab_titulos.NEXT(vr_index_titulo);
      END LOOP;
      --Limpar tabela contas
      vr_tab_conta.DELETE;

	    -- Merge 1 - 15/02/2018 - Chamado 851591
      IF NVL(vr_cdcritic,0) > 0 OR trim(vr_dscritic) IS NOT NULL THEN
        vr_dscritic := vr_dscritic ||
                       vr_dsparame;
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => NVL(vr_cdcritic,0)
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
      END IF;

      IF NVL(vr_tab_erro.Count,0) > 0 THEN
        pr_tab_erro := vr_tab_erro;
      END IF;

      -- Limpa nome do módulo logado - 15/02/2018 - Chamado 851591
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;

        -- Se nao tiver gerado a tabela de erro, gera a mesma
        IF vr_tab_erro.count = 0 THEN
          vr_dscritic := vr_dscritic ||
                         vr_dsparame;
          GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 /** Sequencia **/
                               ,pr_cdcritic => pr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => vr_tab_erro);
        END IF;

        --> Geração de log - Ch 851591
         pc_controla_log_batch(pr_dstiplog      => 'E'
                              ,pr_tpocorre      => 1
                              ,pr_cdcricid      => 1
                              ,pr_tpexecuc      => 2
                              ,pr_dscritic      => pr_dscritic
                              ,pr_cdcritic      => pr_cdcritic
                              ,pr_cdcooper      => pr_cdcooper);
                              

        -- Merge 1 - 15/02/2018 - Chamado 851591
        IF NVL(vr_tab_erro.Count,0) > 0 THEN
        pr_tab_erro := vr_tab_erro;
        END IF;

      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        
        -- Erro
        -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
        pr_cdcritic:= 9999;
        pr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)||
                      'DSCT0001.pc_efetua_baixa_titulo. ' ||sqlerrm
                      ||'.' ||vr_dsparame;

        --> Geração de log - Ch 851591
         pc_controla_log_batch(pr_dstiplog      => 'E'
                              ,pr_tpocorre      => 2
                              ,pr_cdcricid      => 2
                              ,pr_tpexecuc      => 2
                              ,pr_dscritic      => pr_dscritic
                              ,pr_cdcritic      => pr_cdcritic
                              ,pr_cdcooper      => pr_cdcooper);

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => pr_dscritic
                             ,pr_tab_erro => vr_tab_erro);

        -- Merge 1 - 15/02/2018 - Chamado 851591
        IF NVL(vr_tab_erro.Count,0) > 0 THEN
        pr_tab_erro := vr_tab_erro;
        END IF;

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
    --  Data     : Maio/2016.                   Ultima atualizacao: 24/05/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para efetuar resgate de titulos de um determinado bordero
    --
    --   Disparador pelo PC_CRPS702 que esta sendo incluido Log via RE0011078.
    --
    --  Alteracoes: 
    --
    --              15/02/2018 - Incluido nome do módulo logado
    --                           No caso de erro de programa gravar tabela especifica de log 
    --                           Ajuste mensagem de erro:
    --                           - Incluindo codigo e eliminando descrições fixas
    --                           - Gravando as informações de entrada de INSERTS, UPDATE e DELETES quando derem erro
    --                           - Incluído tratamento para não duplicar a mensagens na tbgen: vr_ininsoco
    --                          (Belli - Envolti - Chamado 851591) 
    --
    --           24/05/2018 - Alterado procedure pc_efetua_resgate_tit_bord. Realizar os lançamentos:
    --                        1) Na conta corrente do cooperado (tabela CRAPLCM)
    --                           Valor do título descontando juros proporcional (histórico 2676 - RESGATE DE TITULO DESCONTADO)
    --                        2) Nas movimentações da operação de desconto (tabela tbdsct_lancamento_bordero)
    --                           Valor líquido do título (histórico 2677 - RESGATE DE TITULO DESCONTADO)
    --                           Valor bruto do título (histórico 2678 - RESGATE DE TITULO DESCONTADO) --> Baixa da carteira
    --                           Valor dos juros do título (histórico 2679	- RENDA SOBRE RESGATE DE TÍTULO DESCONTADO)
    --                        (Paulo Penteado (GFT))
    --
    --           08/08/2018 - Zerar o saldo devedor quando resgatado.
    --                        (Vitor Shimada Assanuma [GFT])          
    --
    --           11/03/2019 - Correção na rotina de restituição de juros remuneratório cobrado apo´s a data de restage.
    --                        Renomeado variavel rw_crapljt de dentro do loop cr_crapljt2 para rowtype rw_craplj (sem o "t")
    --                        (Paulo Penteado GFT) 
    --
    --           14/03/2019 - Alterado o valor de lançamento do histórico 2677 de resgate na operação de crédito, trocado o valor liquido 
    --                        calculado na liberação do borderô pelo valor liquido calculado no momento do resgate, pois o extrato da
    --                        operação não estava fechando devido a diferença dos juros (Paulo Penteado GFT) 
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
            ,crapbdt.flverbor -- Indicativo da versao das funcionalidades de bordero (0-Versao antiga/1-Versao nova)
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
            ,craptdb.nrtitulo
            ,craptdb.rowid
            -- Exclue coluna - COUNT(*) OVER(PARTITION BY craptdb.cdcooper) qtdreg - 15/02/2018 - Chamado 851591           
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
      vr_cdhistortari INTEGER;
      vr_cdhistorresg craphis.cdhistor%TYPE;
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

      --Agrupa os parametros - 15/02/2018 - Chamado 851591 
      vr_dsparame VARCHAR2(4000);
      
    --------------------------- SUBROTINAS INTERNAS --------------------------  
      
  BEGIN
      
    -- Incluido nome do módulo logado - 15/02/2018 - Chamado 851591
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_resgate_tit_bord');
  
    --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591
    vr_dsparame := ' pr_cdcooper:'  || pr_cdcooper || 
                   ', pr_cdagenci:' || pr_cdagenci || 
                   ', pr_nrdcaixa:' || pr_nrdcaixa || 
                   ', pr_cdoperad:' || pr_cdoperad ||
                   ', pr_dtmvtolt:' || pr_dtmvtolt || 
                   ', pr_dtmvtoan:' || pr_dtmvtoan || 
                   ', pr_inproces:' || pr_inproces || 
                   ', pr_dtresgat:' || pr_dtresgat || 
                   ', pr_idorigem:' || pr_idorigem || 
                   ', pr_nrdconta:' || pr_nrdconta ||
                   ', pr_cdbccxlt:' || pr_cdbccxlt || 
                   ', pr_nrdolote:' || pr_nrdolote;
    
    --> Leitura dos titulos para serem incluidos no Log
    vr_idxtit:= pr_tab_titulos.FIRST;
    WHILE vr_idxtit IS NOT NULL LOOP
      vr_dsparame := vr_dsparame || ', pr_nrdocmto:' || pr_tab_titulos(vr_idxtit).nrdocmto; 
      vr_idxtit:= pr_tab_titulos.NEXT(vr_idxtit);
    END LOOP;
  
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
          -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);     
          -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
          vr_cdcritic := 1171; --Registro de lote esta sendo usado no momento.
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
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
      -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
      vr_cdcritic := 1172; --Registro de lote nao encontrado.
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    --> Verificar tipo do lote  
    ELSIF rw_craplot.tplotmov <> 34 THEN
      -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
      vr_cdcritic := 1173; --Tipo de lote deve ser 34-Descto de titulos.
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
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
          --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
          vr_cdcritic := 1166; --Bordero nao encontrado.
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          CLOSE cr_crapbdt;
          vr_dscritic := NULL;
        END IF;  
        --sair do loop
        EXIT;
        
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);     
          -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
          vr_cdcritic := 1174; --Registro de bordero esta em uso no momento.
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
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
      -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
      vr_cdcritic := 1175; --Bordero deve estar LIBERADO.
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
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
                      
      -- Cursor esta lendo por uma chave UNIQUE então eliminado leitura de mais de um regsitro 
      -- 15/02/2018 - Chamado 851591 
      
      --Se Nao encontrou
      IF cr_craptdb%NOTFOUND THEN
        CLOSE cr_craptdb; 
        --Proximo registro
        vr_idxtit:= pr_tab_titulos.NEXT(vr_idxtit);
        
        -- Salta para o próximo registro - 15/02/2018 - Chamado 851591 
        CONTINUE;
        
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
                                            ,pr_cdhistor  => vr_cdhistortari  --Codigo Historico
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
      
      -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_resgate_tit_bord');
      
      IF vr_vltarres > 0  THEN
        --> Gera Tarifa de resgate
        TARI0001.pc_cria_lan_auto_tarifa (pr_cdcooper => pr_cdcooper          --Codigo Cooperativa
                                         ,pr_nrdconta => rw_craptdb.nrdconta  --Numero da Conta
                                         ,pr_dtmvtolt => pr_dtresgat          --Data Lancamento
                                         ,pr_cdhistor => vr_cdhistortari      --Codigo Historico
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
      
        -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_resgate_tit_bord');
      
      END IF;
      
      --**** RECALCULO DO TITULO(COBRANCA DE JUROS DE RESGATE) ****
      IF  rw_crapbdt.flverbor = 1 THEN
          vr_vlliqori := rw_craptdb.vlliquid;

          dsct0003.pc_calcula_juros_simples_tit(pr_cdcooper => pr_cdcooper
                                               ,pr_nrdconta => rw_craptdb.nrdconta
                                               ,pr_nrborder => rw_craptdb.nrborder
                                               ,pr_cdbandoc => rw_craptdb.cdbandoc
                                               ,pr_nrdctabb => rw_craptdb.nrdctabb
                                               ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                               ,pr_nrdocmto => rw_craptdb.nrdocmto
                                               ,pr_vltitulo => rw_craptdb.vltitulo
                                               ,pr_dtvencto => rw_craptdb.dtvencto
                                               ,pr_dtmvtolt => pr_dtresgat--pr_dtmvtolt
                                               ,pr_txmensal => rw_crapbdt.txmensal
                                               ,pr_vldjuros => vr_vldjuros
                                               ,pr_flresgat => TRUE
                                               ,pr_dtrefere => vr_dtultdat
                                               ,pr_dscritic => vr_dscritic );

          vr_vlliqnov := rw_craptdb.vltitulo - vr_vldjuros; 
          
          -- Lançar operação de desconto, Valor dos juros do título
          dsct0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                                ,pr_nrdconta => rw_craptdb.nrdconta
                                                ,pr_nrborder => rw_craptdb.nrborder
                                                ,pr_dtmvtolt => pr_dtresgat--pr_dtmvtolt
                                                ,pr_cdorigem => 5
                                                ,pr_cdhistor => vr_cdhistordsct_resreap --2679
                                                ,pr_vllanmto => vr_vldjuros
                                                ,pr_cdbandoc => rw_craptdb.cdbandoc
                                                ,pr_nrdctabb => rw_craptdb.nrdctabb
                                                ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                                ,pr_nrdocmto => rw_craptdb.nrdocmto
                                                ,pr_nrtitulo => rw_craptdb.nrtitulo
                                                ,pr_dscritic => vr_dscritic );
          
          IF  vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
          END IF;

          vr_vllanmto := vr_vlliqnov; 

      ELSE
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
              -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
              vr_cdcritic := 1170; --Registro crapljt nao encontrado.
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
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
                    -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                    CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
                    -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                    vr_cdcritic := 1035;
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 
                                   'crapljt(4):'||
                                   ' vlrestit:'  || 'NVL(crapljt.vldjuros,0) - ' || NVL(vr_tab_crawljt(idx).vldjuros,0) ||
                                   ', vldjuros:' || nvl(vr_tab_crawljt(idx).vldjuros,0) ||
                                   ', ROWID:'    || rw_crapljt.ROWID || 
                                   '. ' ||sqlerrm; 
                    --Levantar Excecao
                    RAISE vr_exc_erro;
                END;
              ELSE
                -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                vr_cdcritic := 367; --Erro - Juros negativo:
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||
                               rw_crapljt.vldjuros;
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

      vr_vllanmto := rw_craptdb.vltitulo - (vr_vlliqnov - vr_vlliqori);   

      END IF;
      
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
          WHERE crapljt.ROWID = rw_craplj.ROWID
          RETURNING crapljt.vlrestit INTO rw_craplj.vlrestit;
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
            -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
            vr_cdcritic := 1035;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 
                           'crapljt(5):'||
                           ' vlrestit:'  || 'crapljt.vldjuros' ||
                           ', vldjuros:' || '0' ||
                           ', ROWID:'    || rw_craplj.ROWID || 
                           '. ' ||sqlerrm; 
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
            -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
            vr_cdcritic := 1171; --Registro de lote esta sendo usado no momento.
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
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
                        ,vr_cdhistor_resgate -- cdhistor
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
            -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
            -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
            vr_cdcritic := 1034;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)  ||
                           'craplot(7):'||
                           ' dtmvtolt:'  || pr_dtresgat ||
                           ', cdagenci:' || '1'         ||
                           ', cdbccxlt:' || '100'       ||
                           ', nrdolote:' || '10300'     ||
                           ', tplotmov:' || '1'         ||
                           ', cdoperad:' || pr_cdoperad ||
                           ', cdhistor:' || vr_cdhistor_resgate ||
                           ', cdcooper:' || pr_cdcooper ||
                           '. ' ||sqlerrm; 
            RAISE vr_exc_erro;
        END;      
      END IF;
      
      
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
          -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);    
          -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
          vr_cdcritic := 1035;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 
                           'craplot(6):'||
                           ' nrseqdig:'  || 'nvl(craplot.nrseqdig,0) + 1' ||
                           ', qtinfoln:' || 'nvl(craplot.qtinfoln,0) + 1' ||
                           ', qtcompln:' || 'nvl(craplot.qtcompln,0) + 1' ||
                           ', vlinfodb:' || 'nvl(craplot.vlinfodb,0) + ' || nvl(vr_vllanmto,0) ||
                           ', vlcompdb:' || 'nvl(craplot.vlcompdb,0) + ' || nvl(vr_vllanmto,0) ||
                           ', ROWID:'    || rw_craplot.ROWID || 
                           '. ' ||sqlerrm; 
          RAISE vr_exc_erro;
      END;   
      
      IF  rw_crapbdt.flverbor = 1 THEN
          vr_cdhistorresg := vr_cdhistordsct_resgcta;

          -- Lançar operação de desconto, Valor líquido do título
          dsct0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                                ,pr_nrdconta => rw_craptdb.nrdconta
                                                ,pr_nrborder => rw_craptdb.nrborder
                                                ,pr_dtmvtolt => pr_dtresgat--pr_dtmvtolt
                                                ,pr_cdorigem => 5
                                                ,pr_cdhistor => vr_cdhistordsct_resopcr --2677
                                                ,pr_vllanmto => vr_vlliqnov
                                                ,pr_cdbandoc => rw_craptdb.cdbandoc
                                                ,pr_nrdctabb => rw_craptdb.nrdctabb
                                                ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                                ,pr_nrdocmto => rw_craptdb.nrdocmto
                                                ,pr_nrtitulo => rw_craptdb.nrtitulo
                                                ,pr_dscritic => vr_dscritic );
          
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
          -- Lançar operação de desconto, Valor bruto do título
          dsct0003.pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                                ,pr_nrdconta => rw_craptdb.nrdconta
                                                ,pr_nrborder => rw_craptdb.nrborder
                                                ,pr_dtmvtolt => pr_dtresgat--pr_dtmvtolt
                                                ,pr_cdorigem => 5
                                                ,pr_cdhistor => vr_cdhistordsct_resbaix --2678
                                                ,pr_vllanmto => rw_craptdb.vltitulo
                                                ,pr_cdbandoc => rw_craptdb.cdbandoc
                                                ,pr_nrdctabb => rw_craptdb.nrdctabb
                                                ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                                ,pr_nrdocmto => rw_craptdb.nrdocmto
                                                ,pr_nrtitulo => rw_craptdb.nrtitulo
                                                ,pr_dscritic => vr_dscritic );
          
          IF  vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
          END IF;
      ELSE
          vr_cdhistorresg := vr_cdhistor_resgate;
      END IF;


------------------------------------------------------------
      --Gravar lancamento
      -- P450 - Regulatório de crédito
      lanc0001.pc_gerar_lancamento_conta(
                  pr_dtmvtolt => rw_craplot.dtmvtolt
                 ,pr_cdagenci => rw_craplot.cdagenci
                 ,pr_cdbccxlt => rw_craplot.cdbccxlt
                 ,pr_nrdolote => rw_craplot.nrdolote
                                                ,pr_nrdconta => rw_craptdb.nrdconta
                 ,pr_nrdctabb => rw_craptdb.nrdconta
                 ,pr_cdpesqbb => rw_craptdb.nrdocmto 
                 ,pr_cdcooper => pr_cdcooper
                 ,pr_nrdocmto => rw_craplot.nrseqdig
                 ,pr_cdhistor => vr_cdhistorresg
                 ,pr_nrseqdig => rw_craplot.nrseqdig 
                 ,pr_vllanmto => vr_vllanmto
                 ,pr_nrautdoc => 0
                 -- retorno
                 ,pr_tab_retorno => vr_tab_retorno
                 ,pr_incrineg => vr_incrineg
                 ,pr_cdcritic => pr_cdcritic
                 ,pr_dscritic => pr_dscritic);

      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
         IF vr_incrineg = 0 THEN -- Erro de sistema/BD
          -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);     
          -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
          vr_cdcritic := 1034;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         'craplcm(7):'||
                         ' dtmvtolt:'  || rw_craplot.dtmvtolt ||
                         ', cdagenci:' || rw_craplot.cdagenci ||
                         ', cdbccxlt:' || rw_craplot.cdbccxlt ||
                         ', nrdolote:' || rw_craplot.nrdolote ||
                         ', nrdconta:' || rw_craptdb.nrdconta ||
                         ', nrdocmto:' || rw_craplot.nrseqdig ||
                         ', vllanmto:' || vr_vllanmto         ||
                         ', cdhistor:' || vr_cdhistorresg     ||
                         ', nrseqdig:' || rw_craplot.nrseqdig ||
                         ', nrdctabb:' || rw_craptdb.nrdconta ||
                         ', nrautdoc:' || '0'                 ||
                         ', cdpesqbb:' || rw_craptdb.nrdocmto ||
                         ', cdcooper:' || pr_cdcooper         ||
                         '. ' ||sqlerrm; 
          RAISE vr_exc_erro;
          ELSE --  vr_incrineg = 1 -- Erro de negócio
            vr_cdcritic := 0;
            vr_dscritic := 'Lançamento não foi efetuado - '||
                           'craplcm(7):'||
                           ' dtmvtolt:'  || rw_craplot.dtmvtolt ||
                           ', cdagenci:' || rw_craplot.cdagenci ||
                           ', cdbccxlt:' || rw_craplot.cdbccxlt ||
                           ', nrdolote:' || rw_craplot.nrdolote ||
                           ', nrdconta:' || rw_craptdb.nrdconta ||
                           ', nrdocmto:' || rw_craplot.nrseqdig ||
                           ', vllanmto:' || vr_vllanmto         ||
                           ', cdhistor:' || vr_cdhistorresg     ||
                           ', nrseqdig:' || rw_craplot.nrseqdig ||
                           ', nrdctabb:' || rw_craptdb.nrdconta ||
                           ', nrautdoc:' || '0'                 ||
                           ', cdpesqbb:' || rw_craptdb.nrdocmto ||
                           ', cdcooper:' || pr_cdcooper         ||
                           '. ';
            
            RAISE vr_exc_erro;
         END IF;
      END IF; 
------------------------------------------------------------
      
      --> Atualizar Titulo do Bordero de desconto
      BEGIN
        UPDATE craptdb
           SET craptdb.insittit = 1 --> resgatado
              ,craptdb.dtdpagto = NULL
              ,craptdb.dtresgat = pr_dtresgat
              ,craptdb.cdoperes = pr_cdoperad
              ,craptdb.vlliqres = vr_vlliqnov
              ,craptdb.vlsldtit = 0
         WHERE craptdb.rowid = rw_craptdb.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);     
          -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
          vr_cdcritic := 1035;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 
                           'craptdb(4):'||
                           ' insittit:'  || '1' ||
                           ', dtdpagto:' || 'NULL' ||
                           ', dtresgat:' || pr_dtresgat ||
                           ', cdoperes:' || pr_cdoperad ||
                           ', vlliqres:' || vr_vlliqnov ||
                           ', ROWID:'    || rw_craptdb.ROWID || 
                           '. ' ||sqlerrm; 
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
                                                    
        -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_resgate_tit_bord');
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
                                            ,pr_cdcritic => vr_cdcritic   --Código do erro
                                            ,pr_dscritic => vr_dscritic); --Descricao do erro;
      --Se ocorreu erro
      IF vr_des_erro = 'NOK' THEN

        IF vr_dscritic IS NULL THEN
          --Mensagem erro
          vr_cdcritic:= 1227;
          vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                        ' Bordero:' ||rw_craptdb.nrborder ||
                        ', conta:'  ||rw_craptdb.nrdconta;        
        END IF; 
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      
      -- Retorna nome do módulo logado - 15/02/2018 - Chamado 851591
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_resgate_tit_bord');
      
      --Proximo registro
      vr_idxtit:= pr_tab_titulos.NEXT(vr_idxtit);
    END LOOP;
  
    -- Limpa nome do módulo logado - 15/02/2018 - Chamado 851591
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
  
  EXCEPTION
    --Rotina chamada pela procedure pc_crps702 que grava o log na tbgen_prglog_ocorrencia
    WHEN vr_exc_erro THEN
      ROLLBACK TO vr_resgate;
      -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic ||
                     vr_dsparame;

    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);     
      ROLLBACK TO vr_resgate;      
      -- Erro
      -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                     ' DSCT0001.pc_efetua_resgate_tit_bord. '||sqlerrm||'.'||vr_dsparame;

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
     Data    : 18/06/2015                        Ultima atualizacao: 15/02/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado
     Objetivo  : Buscar valor total da divida em desconto a partir do numero do craplim

     Pck disparada por: 
     - AVAL0001.pc_busca_dados_contratos que é dispara pelas AVAL0001.pc_busca_dados_contratos_car 
       e AVAL0001.pc_busca_dados_contratos_web
     Quando acertar a Pck AVAL0001 retornar aqui e eliminar a geração de Log para não duplicar

     Alteracoes: 18/06/2015 - Conversao Progress >> Oracle (PLSQL) - Jéssica (DB1)
     
                 15/02/2018 - Incluido nome do módulo logado
                              No caso de erro de programa gravar tabela especifica de log 
                               Ajuste mensagem de erro:
                               - Incluindo codigo e eliminando descrições fixas
                               - Gravando as informações de entrada de INSERTS, UPDATE e DELETES quando derem erro
                               - Incluído tratamento para não duplicar a mensagens na tbgen: vr_ininsoco
                              (Belli - Envolti - Chamado 851591)
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
           AND ((craptdb.cdcooper  = crapbdt.cdcooper
           AND  craptdb.nrdconta  = crapbdt.nrdconta
           AND  craptdb.nrborder  = crapbdt.nrborder
           AND  craptdb.insittit =  4)
            OR (craptdb.cdcooper  = crapbdt.cdcooper
           AND  craptdb.nrdconta  = crapbdt.nrdconta
           AND  craptdb.nrborder  = crapbdt.nrborder
           AND  craptdb.insittit = 2
           AND  craptdb.dtdpagto = pr_dtmvtolt));
      rw_crapbdt cr_crapbdt%ROWTYPE;
      -- Acerto 1: Entra parenteses para cobrir as clausulas do OR - 15/02/2018 - Chamado 851591
      -- Acerto 2: Excluido rw_crapdat.dtmvtolt e entra pr_dtmvtolt - 15/02/2018 - Chamado 851591

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

      -- Excluida Variaveis vr_cdcritic e vr_dscritic - 15/02/2018 - Chamado 851591 

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      -- Excluida Variavel vr_exc_erro - 15/02/2018 - Chamado 851591 

      --Tabela de memoria de erros
      vr_tab_erro GENE0001.typ_tab_erro;

      --Variaveis de Indice
      vr_index PLS_INTEGER;

      -- Excluida Variaveis vr_cdcooper,vr_cdoperad,vr_nmdatela,vr_nmeacao,vr_cdagenci,vr_nrdcaixa,vr_idorigem
      -- 15/02/2018 - Chamado 851591       
      
      --Agrupa os parametros - 15/02/2018 - Chamado 851591 
      vr_dsparame VARCHAR2(4000);

      BEGIN

        -- Incluido nome do módulo logado - 15/02/2018 - Chamado 851591
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_busca_total_descto_lim');

        --Inicializar Variaveis
        -- Excluida vr_cdcritic - 15/02/2018 - Chamado 851591 
        -- Excluida vr_dscritic - 15/02/2018 - Chamado 851591 
        vr_index := 0;

        --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591
        vr_dsparame := ' pr_cdcooper:' || pr_cdcooper || 
                       ', pr_cdagenci:' || pr_cdagenci || 
                       ', pr_nrdcaixa:' || pr_nrdcaixa || 
                       ', pr_cdoperad:' || pr_cdoperad ||
                       ', pr_dtmvtolt:' || pr_dtmvtolt || 
                       ', pr_nrdconta:' || pr_nrdconta || 
                       ', pr_idseqttl:' || pr_idseqttl || 
                       ', pr_idorigem:' || pr_idorigem || 
                       ', pr_nmdatela:' || pr_nmdatela || 
                       ', pr_nrctrlim:' || pr_nrctrlim ;                                    

        --Limpar tabela dados
        pr_tab_tot_descontos.DELETE;

        --Limpar tabela erros - 15/02/2018 - Chamado 851591
        pr_tab_erro.DELETE;
        
        OPEN cr_craplim (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta,
                         pr_nrctrlim => pr_nrctrlim);

        FETCH cr_craplim INTO rw_craplim;

        -- Se encontrar registro
        IF cr_craplim%FOUND THEN
          vr_index := vr_index + 1;
          pr_tab_tot_descontos(vr_index).vllimtit := rw_craplim.vllimite;
          CLOSE cr_craplim;
        ELSE
          CLOSE cr_craplim;
        END IF;

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

      -- Limpa nome do módulo logado - 15/02/2018 - Chamado 851591
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);

    EXCEPTION
      -- Excluida rotina vr_exc_erro - 15/02/2018 - Chamado 851591
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);     
        -- Erro
        -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                       'DSCT0001.pc_busca_total_descto_lim. '||sqlerrm||'.'||vr_dsparame;
        -- Dispara rotina de Log - tabela: tbgen prglog ocorrencia
        DSCT0001.pc_controla_log_batch(pr_dscritic => pr_dscritic
                                      ,pr_cdcritic => pr_cdcritic
                                      ,pr_cdcooper => pr_cdcooper
                                      ,pr_tpexecuc => CASE 
                                                        WHEN pr_idorigem IN ( 2, 3, 4 , 5 ) -- 2-Caixa on-line, 3-Internet, 4-TAA, 5-Ayllos web  
                                                          THEN 3  -- 3 Online
                                                        WHEN pr_idorigem = 7 -- Processo/Batch 
                                                          THEN 1  -- 1 Batch
                                                        ELSE -- pr_idorigem 0, 1 Ayllos     
                                                          0  -- 0 Outro
                                                      END --0-Outro, 1-Batch, 2-Job, 3-Online
                                      );       

        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 /** Sequencia **/
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => pr_dscritic
                             ,pr_tab_erro => vr_tab_erro);

        IF NVL(vr_tab_erro.Count,0) > 0 THEN
          pr_tab_erro := vr_tab_erro; -- Retorno de tabela de erros - 15/02/2018 - Chamado 851591
        END IF;

    END;
  END pc_busca_total_descto_lim;
  
  /* Buscar a soma total de descontos (titulos + cheques)  */
  PROCEDURE pc_busca_total_descontos( pr_cdcooper IN INTEGER        --> Codigo Cooperativa
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
     Data    : 16/10/2015                        Ultima atualizacao: 15/02/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado
     Objetivo  : Buscar a soma total de descontos (titulos + cheques) 

     Pck dispara por: 
     - cada0004.pc_carrega_dados_atenda que disparado por cada0004.pc_carrega_dados_atenda_web
     - DSCT0002.pc_busca_dados_imp_descont
     Quando acertar a CXON00014 retornar aqui e eliminar a geração de Log para não duplicar


     Alteracoes: 16/10/2015 - Conversao Progress >> Oracle (PLSQL) - Odirlei(AMcom)
     
                 15/02/2018 - Incluido nome do módulo logado
                              No caso de erro de programa gravar tabela especifica de log 
                               Ajuste mensagem de erro:
                               - Incluindo codigo e eliminando descrições fixas
                               - Gravando as informações de entrada de INSERTS, UPDATE e DELETES quando derem erro
                               - Incluído tratamento para não duplicar a mensagens na tbgen: vr_ininsoco
                              (Belli - Envolti - Chamado 851591)
                              
                 18/03/2019 - Ajuste no cursor cr_craptdb para trazer o saldo devedor do título (Paulo Penteado GFT) 
                              
    ..................................................................................*/
    ------------------> CURSORES <------------------

    --> Busca saldo e limite de desconto de cheques 
    CURSOR cr_craplim(pr_tpctrlim craplim.tpctrlim%TYPE) IS
      SELECT /*+index_asc (craplim CRAPLIM##CRAPLIM1)*/
             craplim.nrdconta ,
             craplim.vllimite
        FROM craplim craplim
       WHERE craplim.cdcooper = pr_cdcooper
         AND craplim.nrdconta = pr_nrdconta
         AND craplim.tpctrlim = pr_tpctrlim
         AND craplim.insitlim = 2;
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
      SELECT craptdb.vlsldtit vltitulo
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
      
    --Variaveis de Excecao
    vr_exc_erro    EXCEPTION;      
    --Agrupa os parametros - 15/02/2018 - Chamado 851591 
    vr_dsparame VARCHAR2(4000);
    --Variaveis de erro - 15/02/2018 - Chamado 851591
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
     
  BEGIN
    -- Incluido nome do módulo logado - 15/02/2018 - Chamado 851591
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_busca_total_descontos');
    
    --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591
    vr_dsparame := ' pr_cdcooper:'  || pr_cdcooper || 
                   ', pr_cdagenci:' || pr_cdagenci || 
                   ', pr_nrdcaixa:' || pr_nrdcaixa || 
                   ', pr_cdoperad:' || pr_cdoperad ||
                   ', pr_dtmvtolt:' || pr_dtmvtolt || 
                   ', pr_nrdconta:' || pr_nrdconta || 
                   ', pr_idseqttl:' || pr_idseqttl || 
                   ', pr_idorigem:' || pr_idorigem || 
                   ', pr_nmdatela:' || pr_nmdatela || 
                   ', pr_flgerlog:' || pr_flgerlog ;
  
    IF pr_flgerlog = 'S' THEN
      IF pr_idorigem IS NULL THEN
        vr_cdcritic := 1132;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
        --Levantar Excecao
        RAISE vr_exc_erro;
      ELSE 
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa := 'Listar ocorrencias.';
    END IF;  
    END IF;  
    
    -- Ajuste nulo em ocorrencia não tratado - 15/02/2018 - Chamado 851591 
    vr_idx := 1;
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
    
    -- Limpa nome do módulo logado - 15/02/2018 - Chamado 851591
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
    
  EXCEPTION    
    WHEN vr_exc_erro THEN
      -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic ||
                     vr_dsparame;
      -- Dispara rotina de Log - tabela: tbgen prglog ocorrencia
      DSCT0001.pc_controla_log_batch(pr_dscritic => pr_dscritic
                                    ,pr_cdcritic => pr_cdcritic
                                    ,pr_cdcooper => pr_cdcooper 
                                    ,pr_tpexecuc => CASE 
                                                      WHEN pr_idorigem IN ( 2, 3, 4 , 5 ) -- 2-Caixa on-line, 3-Internet, 4-TAA, 5-Ayllos web  
                                                        THEN 3  -- 3 Online
                                                      WHEN pr_idorigem = 7 -- Processo/Batch 
                                                        THEN 1  -- 1 Batch
                                                      ELSE -- pr_idorigem 0, 1 Ayllos     
                                                        0  -- 0 Outro
                                                    END --0-Outro, 1-Batch, 2-Job, 3-Online
                                    ); 
      -- Se nao tiver gerado a tabela de erro, gera a mesma
      IF pr_flgerlog = 'S' THEN
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
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);           
      -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)||
                     'DSCT0001.pc_busca_total_descontos. ' ||sqlerrm||'.'||vr_dsparame;
      
      -- Dispara rotina de Log - tabela: tbgen prglog ocorrencia
      DSCT0001.pc_controla_log_batch(pr_dscritic => pr_dscritic
                                    ,pr_cdcritic => pr_cdcritic
                                    ,pr_cdcooper => pr_cdcooper
                                    ,pr_tpexecuc => CASE 
                                                      WHEN pr_idorigem IN ( 2, 3, 4 , 5 ) -- 2-Caixa on-line, 3-Internet, 4-TAA, 5-Ayllos web  
                                                        THEN 3  -- 3 Online
                                                      WHEN pr_idorigem = 7 -- Processo/Batch 
                                                        THEN 1  -- 1 Batch
                                                      ELSE -- pr_idorigem 0, 1 Ayllos     
                                                        0  -- 0 Outro
                                                    END --0-Outro, 1-Batch, 2-Job, 3-Online
                                    );       
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
                                           
    /* ................................................................................

     Programa: pc_efetua_estorno_baixa_titulo       Antiga: 
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED

     Autor   : Demetrius Wolff - Mouts
     Data    : 00/00/0000                        Ultima atualizacao: 15/02/2018

     Dados referentes ao programa:

     Frequencia: 
     Objetivo  : 
     
     Observação: Pck dispara pela cxon0014.pc_estorna_titulos_iptu que é dispara pela b2crap15
                 onde é gerada a CRAPERR pela bo-erro1.i.
                 Quando acertar a CXON00014 retornar aqui e eliminar a geração de Log para não duplicar

     Alteraçôes: 15/02/2018 - Incluido nome do módulo logado
                              No caso de erro de programa gravar tabela especifica de log 
                              Ajuste mensagem de erro:
                              - Incluindo codigo e eliminando descrições fixas
                              - Gravando as informações de entrada de INSERTS, UPDATE e DELETES quando derem erro
                              - Incluído tratamento para não duplicar a mensagens na tbgen: vr_ininsoco
                             (Belli - Envolti - Chamado 851591) 
                 
                 04/03/2019 - Inclusão de tratativa de estorno para o produto novo do desconto de títulos (Lucas Lazari  - GFT)

    ..................................................................................*/
    
      --Selecionar informacoes dos titulos do bordero
      CURSOR cr_craptdb (pr_cdcooper IN craptdb.cdcooper%type
                        ,pr_cdbandoc IN craptdb.cdbandoc%type
                        ,pr_nrdctabb IN craptdb.nrdctabb%type
                        ,pr_nrcnvcob IN craptdb.nrcnvcob%type
                        ,pr_nrdconta IN craptdb.nrdconta%type
                        ,pr_nrdocmto IN craptdb.nrdocmto%type
                        --,pr_insittit IN craptdb.insittit%type
                        ) IS
        SELECT tdb.dtvencto
              ,tdb.vltitulo
              ,tdb.nrdconta
              ,tdb.nrdocmto
              ,tdb.cdcooper
              ,tdb.insittit
              ,tdb.dtdpagto
              ,tdb.nrborder
              ,tdb.dtlibbdt
              ,tdb.cdbandoc
              ,tdb.nrdctabb
              ,tdb.nrcnvcob
              ,tdb.rowid
              ,bdt.flverbor
              ,COUNT(*) OVER (PARTITION BY tdb.cdcooper) qtdreg
        FROM craptdb tdb
        INNER JOIN crapbdt bdt ON bdt.cdcooper = tdb.cdcooper AND bdt.nrdconta = tdb.nrdconta AND bdt.nrborder = tdb.nrborder
        WHERE tdb.cdcooper = pr_cdcooper
        AND   tdb.cdbandoc = pr_cdbandoc
        AND   tdb.nrdctabb = pr_nrdctabb
        AND   tdb.nrcnvcob = pr_nrcnvcob
        AND   tdb.nrdconta = pr_nrdconta
        AND   tdb.nrdocmto = pr_nrdocmto
        --AND   tdb.insittit = pr_insittit;
        AND   tdb.dtlibbdt IS NOT NULL -- Verifica se o título foi liberado, independente da situação (Lucas Lazari - GFT)
        AND   tdb.dtresgat IS NULL;    -- Verifica se o título não foi resgatado (Lucas Lazari - GFT)
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

      -- Excluida cr_crapljt não utilizada - 15/02/2018 - Chamado 851591 
      -- Excluida rw_crapljt não utilizada - 15/02/2018 - Chamado 851591 

      --Variaveis locais
      vr_index_titulo VARCHAR2(20);
      vr_flgdsair     BOOLEAN;
      --Variaveis de erro
      -- Excluida vr_des_erro - 15/02/2018 - Chamado 851591  
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Tipo de registro para datas
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      --Tabela de memoria de erros
      vr_tab_erro GENE0001.typ_tab_erro;
      --Rowid para a craplat
      -- Excluida vr_rowid_craplat - 15/02/2018 - Chamado 851591      
      --Tabela de memoria para contas
      -- Excluida TYPE typ_tab_conta IS TABLE OF NUMBER INDEX BY PLS_INTEGER; - 15/02/2018 - Chamado 851591
      
      --Variaveis de Excecao
      vr_exc_erro    EXCEPTION;
      vr_exc_proximo EXCEPTION;

      --Agrupa os parametros - 15/02/2018 - Chamado 851591 
      vr_dsparame VARCHAR2(4000);
      
  BEGIN

     -- Incluido nome do módulo logado - 15/02/2018 - Chamado 851591
     GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'DSCT0001.pc_efetua_estorno_baixa_titulo'); 
    
     --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591
     vr_dsparame := ' pr_cdcooper:' || pr_cdcooper || 
                    ', pr_cdagenci:' || pr_cdagenci || 
                    ', pr_nrdcaixa:' || pr_nrdcaixa || 
                    ', pr_cdoperad:' || pr_cdoperad ||
                    ', pr_dtmvtolt:' || pr_dtmvtolt || 
                    ', pr_idorigem:' || pr_idorigem || 
                    ', pr_nrdconta:' || pr_nrdconta; 

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
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
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
                          --,pr_insittit => 2
                          ); --pago
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

          -- Se o título foi descontado no produto antigo, realiza as tratativas antigas (Lucas Lazari - GFT)
          IF rw_craptdb.flverbor = 0 AND rw_craptdb.insittit = 2 THEN
          
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
                   -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                   CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
                   -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                   vr_cdcritic := 1037;
                   vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                                  'craplot(1): rowid:' || rw_craplot.rowid ||
                                  '. ' ||sqlerrm; 
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
                   -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                   CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
                   -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                   vr_cdcritic := 1035;
                   vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 
                                  'craplot(7):'||
                                  ' qtcompln:'  || 'qtcompln - 1' ||
                                  ', qtinfoln:' || 'qtinfoln - 1' ||
                                  ', vlinfocr:' || 'vlinfocr -  ' || rw_craplcm.vllanmto ||
                                  ', vlcompcr:' || 'vlcompcr -  ' || rw_craplcm.vllanmto ||
                                  ', ROWID:'    || rw_craplot.ROWID || 
                                  '. ' ||sqlerrm; 
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
               -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
               CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
               -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
               vr_cdcritic := 1037;
               vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                              'craplcm(1): rowid:' || rw_craplcm.rowid ||
                              '. ' ||sqlerrm; 
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
                   -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                   CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
                   -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                   vr_cdcritic := 1037;
                   vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                                  'craplot(2): rowid:' || rw_craplot.rowid ||
                                  '. ' ||sqlerrm; 
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
                   -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                   CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
                   -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                   vr_cdcritic := 1035;
                   vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 
                                  'craplot(8):'||
                                  ' qtcompln:'  || 'qtcompln - 1' ||
                                  ', qtinfoln:' || 'qtinfoln - 1' ||
                                  ', vlinfocr:' || 'vlinfocr -  ' || rw_craplcm.vllanmto ||
                                  ', vlcompcr:' || 'vlcompcr -  ' || rw_craplcm.vllanmto ||
                                  ', ROWID:'    || rw_craplot.ROWID || 
                                  '. ' ||sqlerrm; 
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
               -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
               CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
               -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
               vr_cdcritic := 1037;
               vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                              'craplcm(2): rowid:' || rw_craplcm.rowid ||
                              '. ' ||sqlerrm; 
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
                   -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                   CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
                   -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                   vr_cdcritic := 1037;
                   vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                                  'craplot(3): rowid:' || rw_craplot.rowid ||
                                  '. ' ||sqlerrm; 
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
                   -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                   CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
                   -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                   vr_cdcritic := 1035;
                   vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)  || 
                                  'craplot(9):'||
                                  ' qtcompln:'  || 'qtcompln - 1' ||
                                  ', qtinfoln:' || 'qtinfoln - 1' ||
                                  ', vlinfocr:' || 'vlinfocr -  ' || rw_craplcm.vllanmto ||
                                  ', vlcompcr:' || 'vlcompcr -  ' || rw_craplcm.vllanmto ||
                                  ', ROWID:'    || rw_craplot.ROWID || 
                                  '. ' ||sqlerrm; 
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
               -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
               CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
               -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
               vr_cdcritic := 1037;
               vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                              'craplcm(3): rowid:' || rw_crablcm.rowid ||
                              '. ' ||sqlerrm; 
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
                   -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                   CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
                   -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                   vr_cdcritic := 1037;
                   vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                              'craplot(4): rowid:' || rw_craplot.rowid ||
                              '. ' ||sqlerrm; 
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
                   -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                   CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
                   -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                   vr_cdcritic := 1035;
                   vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 
                                  'craplot(10):'||
                                  ' qtcompln:'   || 'qtcompln - 1' ||
                                  ', qtinfoln:'  || 'qtinfoln - 1' ||
                                  ', vlinfocr:'  || 'vlinfocr -  ' || rw_craplcm.vllanmto ||
                                  ', vlcompcr:'  || 'vlcompcr -  ' || rw_craplcm.vllanmto ||
                                  ', ROWID:'     || rw_craplot.ROWID || 
                                  '. ' ||sqlerrm; 
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
               -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
               CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
               -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
               vr_cdcritic := 1037;
               vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                              'craplcm(4): rowid:' || rw_craplcm.rowid ||
                              '. ' ||sqlerrm;
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
                   -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                   CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
                   -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                   vr_cdcritic := 1037;
                   vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                                  'craplot(5): rowid:' || rw_craplot.rowid ||
                                  '. ' ||sqlerrm;
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
                   -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                   CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
                   -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                   vr_cdcritic := 1035;
                   vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 
                                  'craplot(11):'||
                                  ' qtcompln:'   || 'qtcompln - 1' ||
                                  ', qtinfoln:'  || 'qtinfoln - 1' ||
                                  ', vlinfocr:'  || 'vlinfocr -  ' || rw_craplcm.vllanmto ||
                                  ', vlcompcr:'  || 'vlcompcr -  ' || rw_craplcm.vllanmto ||
                                  ', ROWID:'     || rw_craplot.ROWID || 
                                  '. ' ||sqlerrm; 
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
               -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
               CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
               -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
               vr_cdcritic := 1037;
               vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                              'craplcm(5): rowid:' || rw_craplcm.rowid ||
                              '. ' ||sqlerrm;
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
             -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
             CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
             -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
             vr_cdcritic := 1035;
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 
                            'craptdb(4):'||
                            ' insittit:'  || '4' ||
                            ', dtdpagto:' || 'NULL' ||
                            ', ROWID:'    || rw_craptdb.ROWID || 
                            '. ' ||sqlerrm; 
               RAISE vr_exc_erro;
         END;

         /* Se o bordero estava liquidado volta o status para liberado */
         --Selecionar Bordero de titulos
         OPEN cr_crapbdt (pr_cdcooper => rw_craptdb.cdcooper
                         ,pr_nrborder => rw_craptdb.nrborder);
         FETCH cr_crapbdt INTO rw_crapbdt;
         IF cr_crapbdt%NOTFOUND THEN
           CLOSE cr_crapbdt;
           --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
           vr_cdcritic := 1166; --Bordero nao encontrado.
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            RAISE vr_exc_erro;
         ELSE
           BEGIN
             UPDATE crapbdt
                SET insitbdt = 3 /*Liberado*/
              WHERE rowid    = rw_crapbdt.rowid;
           EXCEPTION
              WHEN OTHERS THEN
             -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
             CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
             -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
             vr_cdcritic := 1035;
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)  || 
                            'crapbdt(2):'||
                            ' insitbdt:'  || '3' ||
                            ' ,ROWID:'    || rw_crapbdt.ROWID || 
                            '. ' ||sqlerrm; 
               RAISE vr_exc_erro;
           END;
         END IF;
         IF cr_crapbdt%ISOPEN THEN
           CLOSE cr_crapbdt;
         END IF;

         ELSIF rw_craptdb.flverbor = 1 THEN
           -- chama a rotina de estorno do produto novo
           
           DSCT0005.pc_realiza_estorno_cob(pr_cdcooper => rw_craptdb.cdcooper
                                          ,pr_nrborder => rw_craptdb.nrborder 
                                          ,pr_cdbandoc => rw_craptdb.cdbandoc
                                          ,pr_nrdctabb => rw_craptdb.nrdctabb
                                          ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                          ,pr_nrdconta => rw_craptdb.nrdconta
                                          ,pr_nrdocmto => rw_craptdb.nrdocmto
                                          ,pr_dtmvtolt => pr_dtmvtolt
                                          -- OUT --
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic
                                          );
           
           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
             vr_dscritic := 'Erro na rotina de estorno de cobrança';
             RAISE vr_exc_erro;
           END IF;
         
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
             -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
             CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
             -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
             vr_cdcritic := 1035;
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                            'crapljt(6):'||
                            ' vldjuros:'  || 'vldjuros + vlrestit' ||
                            ', vlrestit:' || '0' || 
                            ', cdcooper:' || pr_cdcooper ||
                            ', nrdconta:' || rw_craptdb.nrdconta ||
                            ', nrborder:' || rw_craptdb.nrborder ||
                            ', dtrefere:' || pr_dtmvtolt ||
                            ', cdbandoc:' || rw_craptdb.cdbandoc ||
                            ', nrdctabb:' || rw_craptdb.nrdctabb ||
                            ', nrcnvcob:' || rw_craptdb.nrcnvcob ||
                            ', nrdocmto:' || rw_craptdb.nrdocmto ||
                            '. ' ||sqlerrm; 
             RAISE vr_exc_erro;
         END;

      EXCEPTION
        WHEN vr_exc_proximo THEN
          NULL;
        WHEN vr_exc_erro THEN
          RAISE vr_exc_erro;
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
          -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591      
          --Montar Mensagem Erro
          vr_cdcritic := 9999;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         'Loop principal. '||sqlerrm;
          RAISE vr_exc_erro;
      END;
      --Proximo registro
      vr_index_titulo:= pr_tab_titulos.NEXT(vr_index_titulo);
    END LOOP;
                                                    
    -- Limpa nome do módulo logado - 15/02/2018 - Chamado 851591
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic ||
                     vr_dsparame; 

      -- Dispara rotina de Log - tabela: tbgen prglog ocorrencia
      DSCT0001.pc_controla_log_batch(pr_dscritic => pr_dscritic
                                    ,pr_cdcritic => pr_cdcritic
                                    ,pr_cdcooper => pr_cdcooper 
                                    ,pr_tpexecuc => CASE 
                                                      WHEN pr_idorigem IN ( 2, 3, 4 , 5 ) -- 2-Caixa on-line, 3-Internet, 4-TAA, 5-Ayllos web  
                                                        THEN 3  -- 3 Online
                                                      WHEN pr_idorigem = 7 -- Processo/Batch 
                                                        THEN 1  -- 1 Batch
                                                      ELSE -- pr_idorigem 0, 1 Ayllos     
                                                        0  -- 0 Outro
                                                    END --0-Outro, 1-Batch, 2-Job, 3-Online
                                    ); 

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
      -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);     
      -- Erro
      -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                     'DSCT0001.pc_efetua_estorno_baixa_titulo. '||sqlerrm||'.'||vr_dsparame;
      -- Dispara rotina de Log - tabela: tbgen prglog ocorrencia
      DSCT0001.pc_controla_log_batch(pr_dscritic => pr_dscritic
                                    ,pr_cdcritic => pr_cdcritic
                                    ,pr_cdcooper => pr_cdcooper 
                                    ,pr_tpexecuc => CASE 
                                                      WHEN pr_idorigem IN ( 2, 3, 4 , 5 ) -- 2-Caixa on-line, 3-Internet, 4-TAA, 5-Ayllos web  
                                                        THEN 3  -- 3 Online
                                                      WHEN pr_idorigem = 7 -- Processo/Batch 
                                                        THEN 1  -- 1 Batch
                                                      ELSE -- pr_idorigem 0, 1 Ayllos     
                                                        0  -- 0 Outro
                                                    END --0-Outro, 1-Batch, 2-Job, 3-Online
                                    ); 

      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 -- Sequencia
                           ,pr_cdcritic => pr_cdcritic
                           ,pr_dscritic => pr_dscritic
                           ,pr_tab_erro => vr_tab_erro);

  END pc_efetua_estorno_baixa_titulo;

  --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
  PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2 DEFAULT 'E' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                                 ,pr_tpocorre IN NUMBER   DEFAULT 2   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                 ,pr_cdcricid IN NUMBER   DEFAULT 2   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                                 ,pr_tpexecuc IN NUMBER   DEFAULT 0   -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                                 ,pr_dscritic IN VARCHAR2 DEFAULT NULL
                                 ,pr_cdcritic IN VARCHAR2 DEFAULT NULL
                                 ,pr_nmrotina IN VARCHAR2 DEFAULT 'DSCT0001'
                                 ,pr_cdcooper IN VARCHAR2 DEFAULT 0
                                 )
  IS

    -- ..........................................................................
    --
    --  Programa : pc_log
    --  Sistema  : Rotina de Log - tabela: tbgen prglog ocorrencia
    --  Sigla    : GENE
    --  Autor    : Envolti - Belli - Chamado 851591
    --  Data     : 15/02/2018                        Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Chamar a rotina de Log para gravação de criticas.
    --
    --   Alteracoes: 
    --
    -- .............................................................................
    --  
    vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;                                      
  BEGIN
    -- Geração de log                                                 
    CECRED.pc_log_programa(pr_dstiplog      => pr_dstiplog -- I-início/ F-fim/ O-ocorrência/ E-erro 
                          ,pr_tpocorrencia  => pr_tpocorre -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          ,pr_cdcriticidade => pr_cdcricid -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                          ,pr_tpexecucao    => pr_tpexecuc -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                          ,pr_dsmensagem    => pr_dscritic
                          ,pr_cdmensagem    => pr_cdcritic
                          ,pr_cdprograma    => pr_nmrotina
                          ,pr_cdcooper      => pr_cdcooper 
                          ,pr_idprglog      => vr_idprglog
                          );   
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log  
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);    
  END pc_controla_log_batch;

  PROCEDURE pc_abatimento_juros_titulo(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_nrborder  IN crapbdt.nrborder%TYPE --> Numero do bordero
                                      ,pr_cdbandoc  IN craptdb.cdbandoc%TYPE
                                      ,pr_nrdctabb  IN craptdb.nrdctabb%TYPE
                                      ,pr_nrcnvcob  IN craptdb.nrcnvcob%TYPE
                                      ,pr_nrdocmto  IN craptdb.nrdocmto%TYPE
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                      ,pr_cdagenci  IN crapass.cdagenci%TYPE
                                      ,pr_cdoperad  IN VARCHAR2              --> Codigo operador
                                      ,pr_cdorigpg  IN NUMBER DEFAULT 0      --> Código da origem do pagamento
                                      ,pr_dtdpagto  IN craptdb.dtdpagto%TYPE DEFAULT NULL --> Data de pagamento
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                      ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_abatimento_juros_titulo
      Sistema  : Ayllos
      Sigla    : DSCT
      Autor    : Paulo Penteado (GFT)
      Data     : Junho/2018
  
      Objetivo  : Efetuar o abatimento de juros do título do borderô
     
               pr_cdorigpg: Código da origem do pagamento 
                            0 - Conta-Corrente
                            1 - Operação de Crédito
  
      Alteração : 09/06/2018 - Criação (Paulo Penteado (GFT))
                  11/09/2018 - Fix removendo histórico de lançamento de borderô - (Andrew Albuquerque - GFT)
  
    ----------------------------------------------------------------------------------------------------------*/
    vr_cdhistor   craphis.cdhistor%TYPE;
    vr_dtperiod   DATE;
    vr_dtrefjur   DATE;
    vr_dtultdat   DATE;
    vr_flgachou   BOOLEAN;
    vr_incrawljt  PLS_INTEGER;
    vr_nrdocmtolt craptdb.nrdocmto%TYPE;
    vr_nrdolote   craplot.nrdolote%TYPE;
    vr_qtdprazo   INTEGER;
    vr_txdiaria   NUMBER;
    vr_vldjuros   NUMBER;
    vr_vltitulo   NUMBER;
    vr_vltotjur   NUMBER;
    
    rw_craplcm craplcm%ROWTYPE;

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
  
    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
      
    --Selecionar Bordero de titulos
    CURSOR cr_crapbdt IS
      SELECT crapbdt.txmensal
            ,crapbdt.vltaxiof
            ,crapbdt.flverbor
      FROM crapbdt
      WHERE crapbdt.cdcooper = pr_cdcooper
      AND   crapbdt.nrborder = pr_nrborder;
    rw_crapbdt cr_crapbdt%ROWTYPE;
    
    CURSOR cr_craptdb IS
      SELECT craptdb.dtvencto
            ,craptdb.vltitulo
            ,craptdb.nrdconta
            ,craptdb.nrdocmto
            ,craptdb.cdcooper
            ,craptdb.insittit
            ,nvl(craptdb.dtdpagto, pr_dtdpagto) dtdpagto
            ,craptdb.nrborder
            ,craptdb.dtlibbdt
            ,craptdb.cdbandoc
            ,craptdb.nrdctabb
            ,craptdb.nrcnvcob
            ,craptdb.rowid
            ,craptdb.vlliquid
            ,craptdb.nrtitulo
            ,COUNT(*) OVER (PARTITION BY craptdb.cdcooper) qtdreg
      FROM craptdb
      WHERE craptdb.cdcooper = pr_cdcooper
      AND   craptdb.cdbandoc = pr_cdbandoc
      AND   craptdb.nrdctabb = pr_nrdctabb
      AND   craptdb.nrcnvcob = pr_nrcnvcob
      AND   craptdb.nrdconta = pr_nrdconta
      AND   craptdb.nrdocmto = pr_nrdocmto
      AND   craptdb.dtresgat IS NULL;
    rw_craptdb cr_craptdb%ROWTYPE;

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
     
  BEGIN
    OPEN  cr_crapbdt;
    FETCH cr_crapbdt INTO rw_crapbdt;
    IF    cr_crapbdt%NOTFOUND THEN
          CLOSE cr_crapbdt;
          vr_cdcritic := 1166; --Bordero nao encontrado.
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_erro;
    END   IF;
    CLOSE cr_crapbdt;
    
    OPEN  cr_craptdb;
    FETCH cr_craptdb INTO rw_craptdb;
    IF    cr_craptdb%NOTFOUND THEN
          CLOSE cr_craptdb;
          vr_cdcritic := 1108; 
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_erro;
    END   IF;
    CLOSE cr_craptdb;

    /**** ABATIMENTO DE JUROS ****/
    --Zerar valor total juros
    vr_vltotjur:= 0;
    IF (rw_crapbdt.flverbor=0) THEN
       vr_txdiaria := APLI0001.fn_round((POWER(1 + (rw_crapbdt.txmensal / 100),1 / 30) - 1),7);
    ELSE
       vr_txdiaria := (rw_crapbdt.txmensal / 100)/30;
    END IF;
    --Quantidade dias prazo
    vr_qtdprazo:= TO_NUMBER(rw_craptdb.dtvencto - rw_craptdb.dtlibbdt) -
                  TO_NUMBER(rw_craptdb.dtvencto - rw_craptdb.dtdpagto);
    IF vr_qtdprazo < 0 THEN
      vr_qtdprazo:= TO_NUMBER(rw_craptdb.dtvencto - rw_craptdb.dtlibbdt) -
                    TO_NUMBER(rw_craptdb.dtdpagto - rw_craptdb.dtvencto);
    END IF;
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
        IF (rw_crapbdt.flverbor=0) THEN
          --Valor Titulo recebe valor juros
          vr_vldjuros:= APLI0001.fn_round(vr_vltitulo * vr_txdiaria,2);
          vr_vltitulo:= vr_vltitulo + vr_vldjuros;
        ELSE
          vr_vldjuros:= vr_vltitulo * vr_txdiaria;
        END IF;
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
        IF (rw_crapbdt.flverbor=1) THEN
          vr_tab_crawljt(idx).vldjuros := APLI0001.fn_round(vr_tab_crawljt(idx).vldjuros,2);
        END IF;
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
            -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
            vr_cdcritic := 1170; --Registro crapljt nao encontrado.
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            -- Excluido GENE0001.pc_gera_erro esta no final da rotina - 15/02/2018 - Chamado 851591 
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
                  -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
                  CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
                  -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
                  vr_cdcritic := 1035;
                  vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)|| 
                                 'crapljt(1):'||
                                 ' vlrestit:'  || 'NVL(crapljt.vldjuros,0) - ' || NVL(vr_tab_crawljt(idx).vldjuros,0) ||
                                 ' ,vldjuros:' || nvl(vr_tab_crawljt(idx).vldjuros,0) ||
                                 ' ,ROWID   :' || rw_crapljt.ROWID  || 
                                 '. ' ||sqlerrm; 
                  --Levantar Excecao
                  RAISE vr_exc_erro;
              END;
              /* Juros a ser restituido */
              vr_vltotjur:= rw_crapljt.vlrestit;
            ELSE
              --Mensagem erro
              -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
              vr_cdcritic := 367; --Erro - Juros negativo:
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||
                             rw_crapljt.vldjuros;
              -- Excluido GENE0001.pc_gera_erro esta no final da rotina - 15/02/2018 - Chamado 851591                      
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
            -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
            -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
            vr_cdcritic := 1035;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)  || 
                           'crapljt(2):'||
                           ' vlrestit:'  || 'crapljt.vldjuros' ||
                           ', vldjuros:' || '0' ||
                           ', ROWID:'    || rw_crapljt.ROWID  || 
                           '. ' ||sqlerrm; 
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
          -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
          -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
          vr_cdcritic := 1035;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)|| 
                         'crapljt(3):'||
                         ' vlrestit:'  || 'crapljt.vldjuros' ||
                         ', vldjuros:' || '0' ||
                         ' ,ROWID:'    || rw_crapljt.ROWID  || 
                         '. ' ||sqlerrm; 
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;
    END LOOP;
    --Se valor total juros positivo
    IF vr_vltotjur > 0 THEN
      -- conta corrente
      IF nvl(pr_cdorigpg,0) = 0 THEN
        vr_cdhistor   := 597;
        vr_nrdolote   := 10300;
        vr_nrdocmtolt := NULL;
      ELSE -- operação de crédito
        vr_cdhistor := dsct0003.vr_cdhistordsct_rendapgtoant;
        vr_nrdolote := fn_sequence(pr_nmtabela => 'CRAPLOT'
                                  ,pr_nmdcampo => 'NRDOLOTE'
                                  ,pr_dsdchave => TO_CHAR(pr_cdcooper)|| ';' 
                                                  || TO_CHAR(pr_dtmvtolt,'DD/MM/RRRR') || ';'
                                                  || TO_CHAR(pr_cdagenci)|| ';'
                                                  || '100');
        vr_nrdocmtolt := rw_craptdb.nrdocmto;
      END IF;
            
      /*[PROJETO LIGEIRINHO] Esta função retorna verdadeiro, quando o processo foi iniciado pela rotina:
      PAGA0001.pc_efetua_debitos_paralelo, que é chamada na rotina PC_CRPS509. Tem por finalidade definir
      se grava na tabela CRAPLOT no momento em que esta rodando a esta rotina OU somente no final da execucação
      da PC_CRPS509, para evitar o erro de lock da tabela, pois esta gravando a agencia 90,91 ou 1 ao inves de gravar
      a agencia do cooperado*/
            
      if not paga0001.fn_exec_paralelo then
        /* Leitura do lote */
        OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                      ,pr_dtmvtolt => pr_dtmvtolt
                        ,pr_cdagenci => pr_cdagenci
                      ,pr_cdbccxlt => 100
                      ,pr_nrdolote => vr_nrdolote);
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
                ,pr_cdagenci
              ,100
              ,vr_nrdolote
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
              --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
              vr_cdcritic := 59; --Lote ja cadastrado.
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
              RAISE vr_exc_erro;
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
              CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
              -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
              vr_cdcritic := 1034;
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                             'craplot(6):'||
                             ' cdcooper:'  || pr_cdcooper ||
                             ', dtmvtolt:' || pr_dtmvtolt ||
                             ', cdagenci:' || '1'         ||
                             ', cdbccxlt:' || '100'       ||
                             ', nrdolote:' || vr_nrdolote ||
                             ', cdoperad:' || pr_cdoperad ||
                             ', tplotmov:' || '1'         ||
                             ', cdhistor:' || vr_cdhistor ||
                             '. ' ||sqlerrm; 
              RAISE vr_exc_erro;
          END;
        END IF;
        --Fechar Cursor
        IF cr_craplot%ISOPEN THEN
          CLOSE cr_craplot;
        END IF;
        rw_craplot.nrseqdig:= rw_craplot.nrseqdig + 1; -- projeto ligeirinho
      ELSE
        paga0001.pc_insere_lote_wrk (pr_cdcooper => pr_cdcooper,
                                     pr_dtmvtolt => pr_dtmvtolt,
                                     pr_cdagenci => 1,
                                     pr_cdbccxlt => 100,
                                     pr_nrdolote => vr_nrdolote,
                                     pr_cdoperad => pr_cdoperad,
                                     pr_nrdcaixa => NULL,
                                     pr_tplotmov => 1,
                                     pr_cdhistor => vr_cdhistor,
                                     pr_cdbccxpg => null,
                                     pr_nmrotina => 'DSCT0001.PC_ABATIMENTO_JUROS_TITULO');
                            
        rw_craplot.dtmvtolt := pr_dtmvtolt;                  
        rw_craplot.cdagenci := 1;                   
        rw_craplot.cdbccxlt := 100;                  
        rw_craplot.nrdolote := vr_nrdolote;  
        rw_craplot.nrseqdig := PAGA0001.fn_seq_parale_craplcm; 
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
            ,nvl(vr_nrdocmtolt, Nvl(rw_craplot.nrseqdig,0))
            ,vr_vltotjur
            ,vr_cdhistor
            ,Nvl(rw_craplot.nrseqdig,0) -- Merge 02/05/2018 - Chamado 851591 
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
          -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
          -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
          vr_cdcritic := 1034;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                             'craplcm(6):'||
                             ' dtmvtolt:'  || rw_craplot.dtmvtolt ||
                             ', cdagenci:' || rw_craplot.cdagenci ||
                             ', cdbccxlt:' || rw_craplot.cdbccxlt ||
                             ', nrdolote:' || rw_craplot.nrdolote ||
                             ', nrdconta:' || rw_craptdb.nrdconta ||
                             ', nrdocmto:' || nvl(vr_nrdocmtolt, Nvl(rw_craplot.nrseqdig,0) || ' + 1') ||
                             ', vllanmto:' || vr_vltotjur ||
                             ', cdhistor:' || vr_cdhistor ||
                             ', nrseqdig:' || Nvl(rw_craplot.nrseqdig,0) || ' + 1' ||
                             ', nrdctabb:' || rw_craptdb.nrdconta ||
                             ', nrautdoc:' || '0' ||
                             ', cdcooper:' || pr_cdcooper ||
                             ', cdpesqbb:' || rw_craptdb.nrdocmto ||
                             '. ' ||sqlerrm; 
          RAISE vr_exc_erro;
      END;
            
      /*[PROJETO LIGEIRINHO] Esta função retorna verdadeiro, quando o processo foi iniciado pela rotina:
      PAGA0001.pc_efetua_debitos_ligeir, que é chamada na rotina PC_CRPS509. Tem por finalidade definir se este update
      deve ser feito agora ou somente no final. da execução da PC_CRPS509 (chamada da paga0001.pc_atualiz_lote)*/
            
      if not paga0001.fn_exec_paralelo then
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
            -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);  
            -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
            vr_cdcritic := 1035;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 
                         'craplot(5):'||
                         ' qtinfoln:'  || 'Nvl(craplot.qtinfoln,0) + 1' ||
                         ', qtcompln:' || 'Nvl(craplot.qtcompln,0) + 1' ||
                         ', nrseqdig:' || Nvl(rw_craplcm.nrseqdig,0) ||
                         ', vlinfodb:' || 'Nvl(craplot.vlinfodb,0) +' || vr_vltotjur ||
                         ', vlcompdb:' || 'Nvl(craplot.vlcompdb,0) +' || vr_vltotjur ||
                         ', ROWID:'    || rw_craplot.ROWID || 
                         '. ' ||sqlerrm; 
          --Levantar Excecao
          RAISE vr_exc_erro;
        END;
      END IF;
    END IF;
  EXCEPTION
    WHEN vr_exc_erro then
         IF  vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := vr_dscritic;
  
    WHEN OTHERS THEN
         pr_cdcritic := nvl(vr_cdcritic,0);
         pr_dscritic := 'Erro nao tratado na rotina DSCT0001.pc_abatimento_juros_titulo: '||SQLERRM;
  END pc_abatimento_juros_titulo;

    
END  DSCT0001;
/
