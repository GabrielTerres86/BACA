CREATE OR REPLACE PACKAGE CECRED.APLI0005 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : APLI0005
  --  Sistema  : Rotinas genericas referente a consultas de saldos em geral de aplicacoes
  --  Sigla    : APLI
  --  Autor    : Jean Michel - CECRED
  --  Data     : Julho - 2014.                   Ultima atualizacao: 04/12/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas de consultas referente a saldo de aplicacoes

  -- Alteracoes: 08/09/2014 - Adicionar o tipo de aplicação no xml de retorno da pc_lista_aplicacoes_car.
  --                         (Douglas - Projeto Captação Internet 2014/2)
  --
  --             09/09/2014 - Adicionar nova procedure pc_valida_solicitacao_resgate
  --                          (Jean Michel - Projeto Captação 2014/2)
  --
  --             13/02/2015 - pc_consulta_resgates_web, Correções de parâmetros e chamadas de procedures
  --                          (Jean Michel).
  --
  --             09/03/2014 - Inclusão do parametro pr_percirrf nas procedures, pc_busca_extrato_aplicacao,
  --                          pc_busca_extrato_aplicacao_car, pc_busca_extrato_aplicacao_web. (Jean Michel)
  --
  --             13/11/2015 - Incluido o comando upper para todos que fazem comparacao com o campo cdoperad
  --                          da tabela crapope (Tiago SD339476)
  --
  --             05/01/2016 - Alteração na chamada da rotina extr0001.pc_obtem_saldo_dia
  --                          para passagem do parâmetro pr_tipo_busca, para melhoria
  --                          de performance.
  --                          Chamado 291693 (Heitor - RKAM)
  --
  --             12/07/2017 - #706116 Melhoria na pc_lista_aplicacoes_web, utilizando pc_escreve_xml no
  --                          lugar de gene0007.pc_insere_tag pois a mesma fica lenta para xmls muito grandes (Carlos)
  --
  --             18/12/2017 - P404 - Inclusão de Garantia de Cobertura das Operações de Crédito (Augusto / Marcos (Supero))
  --
  --             04/01/2018 - Correcao nos campos utilizados para atualizacao da CRAPLOT quando inserida nova aplicacao
  --                          com debito em Conta Investimento.
  --                          Heitor (Mouts) - Chamado 821010.
  --
  --             29/01/2018 - #770327 Criada a rotina pc_lista_demons_apli para a impressão do demonstrativo de
  --                          aplicação com filtro de datas (Carlos)
  --
  --             04/06/2018 - Alterações referente a SM404.
  --
  --             18/07/2018 - Ajuste na procedure pc_solicita_resgate para não permitir o resgate de aplicações enquanto
  --                          o processo batch estiver rodando (Jean Michel)
  --
  --             18/07/2018 - (Proj. 411.2) (CIS Corporate)
  --                          Inclusão do parâmetro pr_idaplpgm nas chamadas
  --                          Inclusão do parâmetro pr_nrctrrpp na procedure pc_cadastra_aplic
  --                          Desconsiderar aplicações programadas na proc. pc_busca_aplicacoes
  --
  --             21/07/2018 - (Proj. 411.2) (CIS Corporate)
  --                          Não desfaz todas as transações em pc_obtem_taxa_modalidade
  --
  --             04/12/2018 - Trocar a chamada da gene0001.pc_gera_log pela gene.0001.pc_gera_log_auto e retirada
  --                          dos commits que estão impactando na rotina diária (Adriano Nagasava - Supero)
  --
  --             16/01/2019 - Revitalizacao (Remocao de lotes) - Pagamentos, Transferencias, Poupanca
  --                   Heitor (Mouts)
  ---------------------------------------------------------------------------------------------------------------

  /* Definição de tabela de memória que compreende as informacoes de carencias dos novos produtos
  referente ao projeto de captação */

  TYPE typ_reg_care IS
    RECORD(cdmodali crapmpc.cdmodali%TYPE
          ,qtdiacar crapmpc.qtdiacar%TYPE
          ,qtdiaprz crapmpc.qtdiaprz%TYPE);

  TYPE typ_tab_care IS
    TABLE OF typ_reg_care
    INDEX BY BINARY_INTEGER;

  /* Vetor para armazenar as informações de carencias */
  vr_tab_care typ_tab_care;

  /* Definição de tabela de memória que compreende as informacoes de taxas, data de carencia e prazos
  dos novos produtos referente ao projeto de captação */

  TYPE typ_reg_taxa IS
    RECORD(txaplica NUMBER(20,8)
          ,nmprodut crapcpc.nmprodut%TYPE
          ,dtvencim DATE
          ,caraplic DATE
          ,qtdiaapl NUMBER(20,8));

  TYPE typ_tab_taxa IS
    TABLE OF typ_reg_taxa
    INDEX BY BINARY_INTEGER;

  /* Vetor para armazenar as informações de carencias */
  vr_tab_taxa typ_tab_taxa;

  -- PL/TABLE que contem os dados de aplicações
  TYPE typ_reg_aplicacao IS
    RECORD(nraplica craprac.nraplica%TYPE
          ,idtippro crapcpc.idtippro%TYPE
          ,cdprodut crapcpc.cdprodut%TYPE
          ,nmprodut crapcpc.nmprodut%TYPE
          ,dsnomenc crapnpc.dsnomenc%TYPE
          ,nmdindex crapind.nmdindex%TYPE
          ,qtdiauti craprac.qtdiaapl%TYPE
          ,dshistor VARCHAR2(100)
          ,nrdocmto craprac.nraplica%TYPE
          ,vlaplica craprac.vlaplica%TYPE
          ,vlsldtot NUMBER
          ,vlsldrgt NUMBER
          ,vlrdirrf NUMBER
          ,percirrf NUMBER
          ,vllanmto NUMBER
          ,cddresga INTEGER
          ,sldresga NUMBER
          ,dtmvtolt craprac.dtmvtolt%TYPE
          ,dtvencto craprac.dtvencto%TYPE
          ,qtdiacar craprac.qtdiacar%TYPE
          ,txaplica craprac.txaplica%TYPE
          ,idblqrgt craprac.idblqrgt%TYPE
          ,indebcre INTEGER
          ,dssitapl VARCHAR2(10)
          ,dsblqrgt VARCHAR2(10)
          ,dsresgat VARCHAR2(3)
          ,dtresgat craprga.dtresgat%TYPE
          ,cdoperad craprac.cdoperad%TYPE
          ,nmoperad crapope.nmoperad%TYPE
          ,idtxfixa crapcpc.idtxfixa%TYPE
          ,idtipapl VARCHAR2(02)
          ,tpaplica INTEGER
          ,qtdiaapl craprac.qtdiaapl%TYPE
          ,dsaplica crapdtc.dsaplica%TYPE
          ,tpaplrdc crapdtc.tpaplrdc%TYPE
          ,dtcarenc DATE);

  TYPE typ_tab_aplicacao IS
    TABLE OF typ_reg_aplicacao
    INDEX BY BINARY_INTEGER;

  -- PLTable que contém os dados de extrato das aplicações de captação
  TYPE typ_reg_extrato IS
    RECORD(dtmvtolt craprac.dtmvtolt%TYPE
          ,cdagenci craplac.cdagenci%TYPE
          ,cdhistor craphis.cdhistor%TYPE
          ,dshistor craphis.dshistor%TYPE
          ,dsextrat craphis.dsextrat%TYPE
          ,nrdocmto craplac.nrdocmto%TYPE
          ,indebcre craphis.indebcre%TYPE
          ,vllanmto craplac.vllanmto%TYPE
          ,vlsldtot NUMBER
          ,txlancto NUMBER
          ,nraplica craplac.nraplica%TYPE);

  TYPE typ_tab_extrato IS
    TABLE OF typ_reg_extrato
    INDEX BY BINARY_INTEGER;

  -- PLTable que contém os dados de resgate de aplicacoes
  TYPE typ_resg_aplica IS
    RECORD(dtresgat craplrg.dtresgat%TYPE
          ,nrdocmto craplrg.nrdocmto%TYPE
          ,tpresgat VARCHAR(50)
          ,dsresgat VARCHAR(50)
          ,nmoperad crapope.nmoperad%TYPE
          ,hrtransa VARCHAR(15)
          ,vllanmto craplrg.vllanmto%TYPE
          ,nraplica craplrg.nraplica%TYPE
          ,dshistor VARCHAR(50)
          ,dtmvtolt craplrg.dtmvtolt%TYPE
          ,dtaplica craprda.dtmvtolt%TYPE
          ,sitresga VARCHAR(2)
          ,idtipapl VARCHAR(1));

  TYPE typ_tab_resg_aplica IS
    TABLE OF typ_resg_aplica
    INDEX BY BINARY_INTEGER;

  -- Rotina referente a consulta de saldos de aplicacao
  PROCEDURE pc_busca_saldo_aplicacoes(pr_cdcooper IN craprac.cdcooper%TYPE           --> Código da Cooperativa
                                     ,pr_cdoperad IN crapope.cdoperad%TYPE           --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE           --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                         --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                     ,pr_nrdconta IN craprac.nrdconta%TYPE           --> Número da Conta
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE           --> Titular da Conta
                                     ,pr_nraplica IN craprac.nraplica%TYPE DEFAULT 0 --> Número da Aplicação / Parâmetro Opcional
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE           --> Data de Movimento
                                     ,pr_cdprodut IN craprac.cdprodut%TYPE DEFAULT 0 --> Código do Produto -–> Parâmetro Opcional
                                     ,pr_idblqrgt IN INTEGER                         --> Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas)
                                     ,pr_idgerlog IN INTEGER                         --> Identificador de Log (0 – Não / 1 – Sim)
                                     ,pr_vlsldtot OUT NUMBER                         --> Saldo Total da Aplicação
                                     ,pr_vlsldrgt OUT NUMBER                         --> Saldo Total para Resgate
                                     ,pr_cdcritic OUT PLS_INTEGER                    --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2);                     --> Descrição da crítica

  -- Rotina referente a consulta de saldos de aplicacao programada
  PROCEDURE pc_busca_saldo_aplic_prog(pr_cdcooper IN craprac.cdcooper%TYPE           --> Código da Cooperativa
                                     ,pr_cdoperad IN crapope.cdoperad%TYPE           --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE           --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                         --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                     ,pr_nrdconta IN craprac.nrdconta%TYPE           --> Número da Conta
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE           --> Titular da Conta
                                     ,pr_nraplica IN craprac.nraplica%TYPE DEFAULT 0 --> Número da Aplicação / Parâmetro Opcional
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE           --> Data de Movimento
                                     ,pr_cdprodut IN craprac.cdprodut%TYPE DEFAULT 0 --> Código do Produto -–> Parâmetro Opcional
                                     ,pr_idblqrgt IN INTEGER                         --> Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas)
                                     ,pr_idgerlog IN INTEGER                         --> Identificador de Log (0 – Não / 1 – Sim)
                                     ,pr_vlsldtot OUT NUMBER                         --> Saldo Total da Aplicação
                                     ,pr_vlsldrgt OUT NUMBER                         --> Saldo Total para Resgate
                                     ,pr_cdcritic OUT PLS_INTEGER                    --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2);                     --> Descrição da crítica

  -- Rotina para consulta de carencias das aplicacoes pelo Ayllos WEB
  PROCEDURE pc_obtem_carencias_web(pr_cdcooper IN craprac.cdcooper%TYPE --> Código da Cooperativa
                                  ,pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Rotina para consulta de carencias das aplicacoes pelo Ayllos Caracter
  PROCEDURE pc_obtem_carencias_car(pr_cdcooper IN  craprac.cdcooper%TYPE --> Código da Cooperativa
                                  ,pr_cdprodut IN  crapcpc.cdprodut%TYPE --> Codigo do Produto
                                  ,pr_clobxmlc OUT CLOB                  --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica

  -- Rotina geral para consulta de carencias das aplicacoes de novos produtos de captacao
  PROCEDURE pc_obtem_carencias(pr_cdcooper IN craprac.cdcooper%TYPE    --> Código da Cooperativa
                              ,pr_cdprodut IN crapcpc.cdprodut%TYPE    --> Codigo do Produto
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Codigo de Critica
                              ,pr_dscritic OUT crapcri.dscritic%TYPE   --> Descricao de Critica
                              ,pr_tab_care OUT APLI0005.typ_tab_care); --> Tabela com dados de carencias

  -- Rotina geral para consulta de taxa de modalidades das aplicacoes
  PROCEDURE pc_obtem_taxa_modalidade(pr_cdcooper IN craprac.cdcooper%TYPE      --> Código da Cooperativa
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE      --> Numero da Conta
                                    ,pr_cdprodut IN crapcpc.cdprodut%TYPE      --> Codigo do Produto
                                    ,pr_vlraplic IN NUMBER                     --> Valor da Aplicacao
                                    ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE      --> Dias de Carencia
                                    ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE      --> Dias de Prazo
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Código da crítica
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE     --> Descrição da crítica
                                    ,pr_tab_taxa OUT APLI0005.typ_tab_taxa);    --> Tabela com dados de prazos, vencimento e taxas

  -- Rotina para consulta de taxa de modalidades das aplicacoes do caracater
  PROCEDURE pc_obtem_taxa_modalidade_car(pr_cdcooper IN craprac.cdcooper%TYPE    --> Código da Cooperativa
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE    --> Numero da Conta
                                        ,pr_cdprodut IN crapcpc.cdprodut%TYPE    --> Codigo do Produto
                                        ,pr_vlraplic IN NUMBER                   --> Valor da Aplicacao
                                        ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE    --> Dias de Carencia
                                        ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE    --> Dias de Prazo
                                        ,pr_txaplica OUT NUMBER                  --> Valor de taxa da aplicacao
                                        ,pr_nmprodut OUT crapcpc.nmprodut%TYPE   --> Nome do Produto
                                        ,pr_dtvencim OUT DATE                    --> Data de vencimento aplicacao
                                        ,pr_caraplic OUT DATE                    --> Data de Carencia Aplicacao
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Código da crítica
                                        ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descrição da crítica

  -- Rotina para consulta de taxa de modalidades das aplicacoes via web
  PROCEDURE pc_obtem_taxa_modalidade_web(pr_cdcooper IN craprac.cdcooper%TYPE  --> Código da Cooperativa
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da Conta
                                        ,pr_cdprodut IN crapcpc.cdprodut%TYPE  --> Codigo do Produto
                                        ,pr_vlraplic IN NUMBER                 --> Valor da Aplicacao
                                        ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE  --> Dias de Carencia
                                        ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE  --> Dias de Prazo
                                        ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da Critica
                                        ,pr_dscritic OUT crapcri.dscritic%TYPE --> Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  -- Rotina para consulta de taxa de modalidades das aplicacoes via web
  PROCEDURE pc_obtem_taxa_modalidade_at(pr_cdcooper IN craprac.cdcooper%TYPE      --> Código da Cooperativa
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE      --> Numero da Conta
                                       ,pr_cdprodut IN crapcpc.cdprodut%TYPE      --> Codigo do Produto
                                       ,pr_vlraplic IN NUMBER                     --> Valor da Aplicacao
                                       ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE      --> Dias de Carencia
                                       ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE      --> Dias de Prazo
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Código da crítica
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE     --> Descrição da crítica
                                       ,pr_tab_taxa OUT APLI0005.typ_tab_taxa);    --> Tabela com dados de prazos, vencimento e taxas



  -- Rotina geral para validacao de cadastros de aplicacoes
  PROCEDURE pc_valida_cad_aplic(pr_cdcooper IN craprac.cdcooper%TYPE      --> Código da Cooperativa
                               ,pr_cdoperad IN crapope.cdoperad%TYPE      --> Código do Operador
                               ,pr_nmdatela IN craptel.nmdatela%TYPE      --> Nome da Tela
                               ,pr_idorigem IN INTEGER                    --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                               ,pr_nrdconta IN craprac.nrdconta%TYPE      --> Número da Conta
                               ,pr_idseqttl IN crapttl.idseqttl%TYPE      --> Titular da Conta
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE      --> Data de Movimento
                               ,pr_cdprodut IN crapcpc.cdprodut%TYPE      --> Código do Produto
                               ,pr_qtdiaapl IN INTEGER                    --> Dias da Aplicação
                               ,pr_dtvencto IN DATE                       --> Data de Vencimento da Aplicação
                               ,pr_qtdiacar IN INTEGER                    --> Carência da Aplicação
                               ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE      --> Prazo da Aplicação (Prazo selecionado na tela)
                               ,pr_vlaplica IN NUMBER                     --> Valor da Aplicação (Valor informado em tela)
                               ,pr_iddebcti IN INTEGER                    --> Identificador de Débito na Conta Investimento (Identificador informado em tela)
                               ,pr_idorirec IN INTEGER                    --> Identificador de Origem do Recurso (Identificador informado em tela)
                               ,pr_idgerlog IN INTEGER                    --> Identificador de Log (Fixo no código, 0 – Não / 1 - Sim)
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Código da crítica
                               ,pr_dscritic OUT crapcri.dscritic%TYPE);    --> Descrição da crítica

  -- Rotina para validacao de cadastros de aplicacoes da web
  PROCEDURE pc_valida_cad_aplic_web(pr_nrdconta IN craprac.nrdconta%TYPE --> Número da Conta
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Titular da Conta
                                   ,pr_dtmvtolt IN VARCHAR2              --> Data de Movimento
                                   ,pr_cdprodut IN crapcpc.cdprodut%TYPE --> Código do Produto
                                   ,pr_qtdiaapl IN INTEGER               --> Dias da Aplicação
                                   ,pr_dtvencto IN VARCHAR2              --> Data de Vencimento da Aplicação
                                   ,pr_qtdiacar IN INTEGER               --> Carência da Aplicação
                                   ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE --> Prazo da Aplicação (Prazo selecionado na tela)
                                   ,pr_vlaplica IN NUMBER                --> Valor da Aplicação (Valor informado em tela)
                                   ,pr_iddebcti IN INTEGER               --> Identificador de Débito na Conta Investimento (Identificador informado em tela)
                                   ,pr_idorirec IN INTEGER               --> Identificador de Origem do Recurso (Identificador informado em tela)
                                   ,pr_idgerlog IN INTEGER               --> Identificador de Log (Fixo no código, 0 – Não / 1 - Sim)
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Rotina geral para validacao da data de vencimento
  PROCEDURE pc_calcula_prazo_aplicacao(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                      ,pr_datcaren IN DATE                  --> Data de Carencia
                                      ,pr_datvenci IN DATE                  --> Data de vencimento
                                      ,pr_diaspraz IN PLS_INTEGER           --> Dias de Carencia
                                      ,pr_qtdiaapl OUT PLS_INTEGER          --> Quantidade de dias da aplicacao
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica

  -- Rotina para validacao da data de vencimento via Ayllos WEB
  PROCEDURE pc_calcula_prazo_aplicacao_web(pr_datcaren IN VARCHAR2           --> Data de Carencia
                                          ,pr_datvenci IN VARCHAR2           --> Data de vencimento
                                          ,pr_diaspraz IN PLS_INTEGER        --> Dias de Carencia
                                          ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2);        --> Erros do processo

  -- Rotina geral para cadastros de aplicacoes
  PROCEDURE pc_cadastra_aplic(pr_cdcooper IN craprac.cdcooper%TYPE    -- Código da Cooperativa
                             ,pr_cdoperad IN crapope.cdoperad%TYPE    -- Código do Operador
                             ,pr_nmdatela IN craptel.nmdatela%TYPE    -- Nome da Tela
                             ,pr_idorigem IN INTEGER                  -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                             ,pr_nrdconta IN craprac.nrdconta%TYPE    -- Número da Conta
                             ,pr_idseqttl IN crapttl.idseqttl%TYPE    -- Titular da Conta
                             ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE    -- Numero de caixa
                             ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE    -- Data de Movimento
                             ,pr_cdprodut IN crapcpc.cdprodut%TYPE    -- Código do Produto (Produto selecionado na tela)
                             ,pr_qtdiaapl IN INTEGER                  -- Dias da Aplicação (Dias informados em tela)
                             ,pr_dtvencto IN DATE                     -- Data de Vencimento da Aplicação (Data informada em tela)
                             ,pr_qtdiacar IN INTEGER                  -- Carência da Aplicação (Carência informada em tela)
                             ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE    -- Prazo da Aplicação (Prazo selecionado na tela)
                             ,pr_vlaplica IN NUMBER                   -- Valor da Aplicação (Valor informado em tela)
                             ,pr_iddebcti IN INTEGER                  -- Identificador de Débito na Conta Investimento (Identificador informado na tela, 0 – Não / 1 - Sim)
                             ,pr_idorirec IN INTEGER                  -- Identificador de Origem do Recurso (Identificador informado em tela)
                             ,pr_idgerlog IN INTEGER                  -- Identificador de Log (Fixo no código, 0 – Não / 1 – Sim)
                             ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE DEFAULT 0 -- Número aplicação programada (Opcional, 0 = Aplicação Não Programada)
                             ,pr_nraplica OUT craprac.nraplica%TYPE        -- Nuemro da aplicacao
                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE   -- Codigo da critica de erro
                             ,pr_dscritic OUT crapcri.dscritic%TYPE); -- Descricao da critica de erro

  -- Rotina para cadastro de aplicacoes da web
  PROCEDURE pc_cadastra_aplic_web(pr_nrdconta IN craprac.nrdconta%TYPE --> Número da Conta
                                 ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Titular da Conta
                                 ,pr_dtmvtolt IN VARCHAR2              --> Data de Movimento
                                 ,pr_cdprodut IN crapcpc.cdprodut%TYPE --> Código do Produto
                                 ,pr_qtdiaapl IN INTEGER               --> Dias da Aplicação
                                 ,pr_dtvencto IN VARCHAR2              --> Data de Vencimento da Aplicação
                                 ,pr_qtdiacar IN INTEGER               --> Carência da Aplicação
                                 ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE --> Prazo da Aplicação (Prazo selecionado na tela)
                                 ,pr_vlaplica IN craprac.vlaplica%TYPE --> Valor da Aplicação (Valor informado em tela)
                                 ,pr_iddebcti IN INTEGER               --> Identificador de Débito na Conta Investimento (Identificador informado em tela)
                                 ,pr_idorirec IN INTEGER               --> Identificador de Origem do Recurso (Identificador informado em tela)
                                 ,pr_idgerlog IN INTEGER               --> Identificador de Log (Fixo no código, 0 – Não / 1 - Sim)
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Rotina geral para cadastros de aplicacoes - Autonomous Transaction
  PROCEDURE pc_cadastra_aplic_at(pr_cdcooper IN craprac.cdcooper%TYPE    -- Código da Cooperativa
                                ,pr_cdoperad IN crapope.cdoperad%TYPE    -- Código do Operador
                                ,pr_nmdatela IN craptel.nmdatela%TYPE    -- Nome da Tela
                                ,pr_idorigem IN INTEGER                  -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                ,pr_nrdconta IN craprac.nrdconta%TYPE    -- Número da Conta
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE    -- Titular da Conta
                                ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE    -- Numero de caixa
                                ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE    -- Data de Movimento
                                ,pr_cdprodut IN crapcpc.cdprodut%TYPE    -- Código do Produto (Produto selecionado na tela)
                                ,pr_qtdiaapl IN INTEGER                  -- Dias da Aplicação (Dias informados em tela)
                                ,pr_dtvencto IN DATE                     -- Data de Vencimento da Aplicação (Data informada em tela)
                                ,pr_qtdiacar IN INTEGER                  -- Carência da Aplicação (Carência informada em tela)
                                ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE    -- Prazo da Aplicação (Prazo selecionado na tela)
                                ,pr_vlaplica IN NUMBER                   -- Valor da Aplicação (Valor informado em tela)
                                ,pr_iddebcti IN INTEGER                  -- Identificador de Débito na Conta Investimento (Identificador informado na tela, 0 – Não / 1 - Sim)
                                ,pr_idorirec IN INTEGER                  -- Identificador de Origem do Recurso (Identificador informado em tela)
                                ,pr_idgerlog IN INTEGER                  -- Identificador de Log (Fixo no código, 0 – Não / 1 – Sim)
                                ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE DEFAULT 0 -- Número aplicação programada (Opcional, 0 = Aplicação Não Programada)
                                ,pr_nraplica OUT craprac.nraplica%TYPE        -- Nuemro da aplicacao
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE   -- Codigo da critica de erro
                                ,pr_dscritic OUT crapcri.dscritic%TYPE); -- Descricao da critica de erro

  -- Rotina geral para excluir aplicacoes
  PROCEDURE pc_exclui_aplicacao(pr_cdcooper IN craprac.cdcooper%TYPE    -- Código da Cooperativa
                               ,pr_cdoperad IN crapope.cdoperad%TYPE    -- Código do Operador
                               ,pr_nmdatela IN craptel.nmdatela%TYPE    -- Nome da Tela
                               ,pr_idorigem IN INTEGER                  -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA)
                               ,pr_nrdconta IN craprac.nrdconta%TYPE    -- Número da Conta
                               ,pr_idseqttl IN crapttl.idseqttl%TYPE    -- Titular da Conta
                               ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE    -- Numero de caixa
                               ,pr_nraplica IN craprac.nraplica%TYPE    -- Código da aplicacao
                               ,pr_idgerlog IN INTEGER                  -- Identificador de LOG (0-Nao grava / 1-Registrar)
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE   -- Codigo da critica de erro
                               ,pr_dscritic OUT crapcri.dscritic%TYPE); -- Descricao da critica de erro

  -- Rotina de exclusao de aplicacoes via WEB
  PROCEDURE pc_exclui_aplicacao_web(pr_nrdconta IN craprac.nrdconta%TYPE --> Número da Conta
                                   ,pr_nraplica IN craprac.nraplica%TYPE --> Número da Aplicacao
                                   ,pr_idgerlog IN INTEGER               --> Identificador de LOG
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Rotina de exclusao de aplicacoes via CARACTER
  PROCEDURE pc_exclui_aplicacao_car(pr_cdcooper IN craprac.cdcooper%TYPE -- Código da Cooperativa
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE -- Código do Operador
                                   ,pr_nmdatela IN craptel.nmdatela%TYPE -- Nome da Tela
                                   ,pr_idorigem IN INTEGER               -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA)
                                   ,pr_nrdconta IN craprac.nrdconta%TYPE -- Número da Conta
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE -- Titular da Conta
                                   ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE -- Numero de caixa
                                   ,pr_nraplica IN craprac.nraplica%TYPE -- Código da aplicacao
                                   ,pr_idgerlog IN INTEGER               -- Identificador de LOG (0-Nao grava / 1-Registrar)
                                   ,pr_cdcritic OUT PLS_INTEGER          -- Código da crítica
                                   ,pr_dscritic OUT VARCHAR2);           -- Descrição da crítica

  PROCEDURE pc_busca_aplicacoes(pr_cdcooper IN craprac.cdcooper%TYPE             --> Código da Cooperativa
                               ,pr_cdoperad IN crapope.cdoperad%TYPE             --> Código do Operador
                               ,pr_nmdatela IN craptel.nmdatela%TYPE             --> Nome da Tela
                               ,pr_idorigem IN INTEGER                           --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                               ,pr_nrdconta IN craprac.nrdconta%TYPE             --> Número da Conta
                               ,pr_idseqttl IN crapttl.idseqttl%TYPE             --> Titular da Conta
                               ,pr_nraplica IN craprac.nraplica%TYPE DEFAULT 0   --> Número da Aplicação - Parâmetro Opcional
                               ,pr_cdprodut IN craprac.cdprodut%TYPE DEFAULT 0   --> Código do Produto – Parâmetro Opcional
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE             --> Data de Movimento
                               ,pr_idconsul IN INTEGER                           --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                               ,pr_idgerlog IN INTEGER                           --> Identificador de Log (0 – Não / 1 – Sim)
                               ,pr_cdcritic OUT INTEGER                          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2                         --> Descrição da crítica
                               ,pr_tab_aplica OUT APLI0005.typ_tab_aplicacao);   --> Tabela  com os dados da aplicação

  PROCEDURE pc_busca_aplicacoes_car(pr_cdcooper IN craprac.cdcooper%TYPE             --> Código da Cooperativa
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE             --> Código do Operador
                                   ,pr_nmdatela IN craptel.nmdatela%TYPE             --> Nome da Tela
                                   ,pr_idorigem IN INTEGER                           --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                   ,pr_nrdconta IN craprac.nrdconta%TYPE             --> Número da Conta
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE             --> Titular da Conta
                                   ,pr_nraplica IN craprac.nraplica%TYPE DEFAULT 0   --> Número da Aplicação - Parâmetro Opcional
                                   ,pr_cdprodut IN craprac.cdprodut%TYPE DEFAULT 0   --> Código do Produto – Parâmetro Opcional
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE             --> Data de Movimento
                                   ,pr_idconsul IN INTEGER                           --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                   ,pr_idgerlog IN INTEGER                           --> Identificador de Log (0 – Não / 1 – Sim)
                                   ,pr_clobxmlc OUT CLOB                             --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER                      --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2);                       --> Descrição da crítica

   PROCEDURE pc_busca_aplicacoes_web(pr_nrdconta IN craprac.nrdconta%TYPE             --> Número da Conta
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE             --> Titular da Conta
                                   ,pr_nraplica IN craprac.nraplica%TYPE DEFAULT 0   --> Número da Aplicação - Parâmetro Opcional
                                   ,pr_cdprodut IN craprac.cdprodut%TYPE DEFAULT 0   --> Código do Produto – Parâmetro Opcional
                                   ,pr_dtmvtolt IN VARCHAR2                          --> Data de Movimento
                                   ,pr_idconsul IN INTEGER                           --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                   ,pr_idgerlog IN INTEGER                           --> Identificador de Log (0 – Não / 1 – Sim)
                                   ,pr_xmllog   IN VARCHAR2                          --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER                      --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2                         --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType                --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2                         --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);                       --> Erros do processo

  -- Procedure para listagem de novas e antigas aplicacoes
  PROCEDURE pc_lista_aplicacoes(pr_cdcooper IN craprac.cdcooper%TYPE            --> Código da Cooperativa
                               ,pr_cdoperad IN crapope.cdoperad%TYPE            --> Código do Operador
                               ,pr_nmdatela IN craptel.nmdatela%TYPE            --> Nome da Tela
                               ,pr_idorigem IN INTEGER                          --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                               ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE            --> Numero do Caixa
                               ,pr_nrdconta IN craprac.nrdconta%TYPE            --> Número da Conta
                               ,pr_idseqttl IN crapttl.idseqttl%TYPE            --> Titular da Conta
                               ,pr_cdagenci IN crapage.cdagenci%TYPE            --> Codigo da Agencia
                               ,pr_cdprogra IN craplog.cdprogra%TYPE            --> Codigo do Programa
                               ,pr_nraplica IN craprac.nraplica%TYPE DEFAULT 0  --> Número da Aplicação - Parâmetro Opcional
                               ,pr_cdprodut IN craprac.cdprodut%TYPE DEFAULT 0  --> Código do Produto – Parâmetro Opcional
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE            --> Data de Movimento
                               ,pr_idconsul IN INTEGER                          --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                               ,pr_idgerlog IN INTEGER                          --> Identificador de Log (0 – Não / 1 – Sim)
                               ,pr_cdcritic OUT INTEGER                         --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2                        --> Descrição da crítica
                               ,pr_saldo_rdca OUT apli0001.typ_tab_saldo_rdca); --> Tabela com os dados da aplicação

  -- Rotina geral para listagem de aplicacoes WEB
  PROCEDURE pc_lista_aplicacoes_web(pr_nrdconta  IN craprac.nrdconta%TYPE           --> Número da Conta
                                   ,pr_idseqttl  IN crapttl.idseqttl%TYPE           --> Titular da Conta
                                   ,pr_nraplica  IN craprac.nraplica%TYPE DEFAULT 0 --> Número da Aplicação - Parâmetro Opcional
                                   ,pr_cdprodut  IN craprac.cdprodut%TYPE DEFAULT 0 --> Código do Produto – Parâmetro Opcional
                                   ,pr_idconsul  IN INTEGER                         --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                   ,pr_idgerlog  IN INTEGER                         --> Identificador de Log (0 – Não / 1 – Sim)
                                   ,pr_xmllog    IN VARCHAR2                        --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER                     --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2                        --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType               --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2                        --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);                      --> Erros do processo

  PROCEDURE pc_lista_demons_apli(pr_cdcooper  IN craprac.cdcooper%TYPE           --> Código da Cooperativa
                                ,pr_cdoperad  IN crapope.cdoperad%TYPE DEFAULT 1 --> Código do Operador
                                ,pr_nmdatela  IN craptel.nmdatela%TYPE           --> Nome da Tela
                                ,pr_idorigem  IN INTEGER                         --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE           --> Numero do Caixa
                                ,pr_nrdconta  IN craprac.nrdconta%TYPE           --> Número da Conta
                                ,pr_idseqttl  IN crapttl.idseqttl%TYPE           --> Titular da Conta
                                ,pr_cdagenci  IN crapage.cdagenci%TYPE           --> Codigo da Agencia
                                ,pr_cdprogra  IN craplog.cdprogra%TYPE           --> Codigo do Programa
                                ,pr_nraplica  IN craprac.nraplica%TYPE DEFAULT 0 --> Número da Aplicação - Parâmetro Opcional
                                ,pr_cdprodut  IN craprac.cdprodut%TYPE DEFAULT 0 --> Código do Produto – Parâmetro Opcional
                                ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE           --> Data de Movimento
                                ,pr_idconsul  IN INTEGER                         --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                ,pr_idgerlog  IN INTEGER                         --> Identificador de Log (0 – Não / 1 – Sim)
                                ,pr_dtinicio  IN DATE
                                ,pr_dtfim     IN DATE
                                ,pr_clobxmlc OUT CLOB                            --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER                     --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_lista_aplicacoes_car(pr_cdcooper  IN craprac.cdcooper%TYPE           --> Código da Cooperativa
                                   ,pr_cdoperad  IN crapope.cdoperad%TYPE DEFAULT 1 --> Código do Operador
                                   ,pr_nmdatela  IN craptel.nmdatela%TYPE           --> Nome da Tela
                                   ,pr_idorigem  IN INTEGER                         --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                   ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE           --> Numero do Caixa
                                   ,pr_nrdconta  IN craprac.nrdconta%TYPE           --> Número da Conta
                                   ,pr_idseqttl  IN crapttl.idseqttl%TYPE           --> Titular da Conta
                                   ,pr_cdagenci  IN crapage.cdagenci%TYPE           --> Codigo da Agencia
                                   ,pr_cdprogra  IN craplog.cdprogra%TYPE           --> Codigo do Programa
                                   ,pr_nraplica  IN craprac.nraplica%TYPE DEFAULT 0 --> Número da Aplicação - Parâmetro Opcional
                                   ,pr_cdprodut  IN craprac.cdprodut%TYPE DEFAULT 0 --> Código do Produto – Parâmetro Opcional
                                   ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE           --> Data de Movimento
                                   ,pr_idconsul  IN INTEGER                         --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                   ,pr_idgerlog  IN INTEGER                         --> Identificador de Log (0 – Não / 1 – Sim)
                                   ,pr_clobxmlc OUT CLOB                            --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER                     --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_val_solicit_resg(pr_cdcooper  IN craprac.cdcooper%TYPE   --> Código da Cooperativa
                               ,pr_cdoperad  IN crapope.cdoperad%TYPE   --> Código do Operador
                               ,pr_nmdatela  IN craptel.nmdatela%TYPE   --> Nome da Tela
                               ,pr_idorigem  IN INTEGER                 --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  )
                               ,pr_nrdconta  IN craprac.nrdconta%TYPE   --> Número da Conta
                               ,pr_idseqttl  IN crapttl.idseqttl%TYPE   --> Titular da Conta
                               ,pr_nraplica  IN craprac.nraplica%TYPE   --> Número da Aplicação
                               ,pr_cdprodut  IN craprac.cdprodut%TYPE   --> Código do Produto
                               ,pr_dtresgat  IN crapdat.dtmvtolt%TYPE   --> Data do Resgate (Data informada em tela)
                               ,pr_vlresgat  IN craprga.vlresgat%TYPE   --> Valor do Resgate (Valor informado em tela)
                               ,pr_idtiprgt  IN craprga.idtiprgt%TYPE   --> Tipo do Resgate (Tipo informado em tela, 1 – Parcial / 2 – Total)
                               ,pr_idrgtcti  IN craprga.idtiprgt%TYPE   --> Resgate na Conta Investimento (Identificador informado em tela, 0 – Não)
                               ,pr_idvldblq  IN INTEGER                 --> Identificador de validação do bloqueio judicial (0 – Não / 1 – Sim)
                               ,pr_idgerlog  IN INTEGER                 --> Identificador de Log (Fixo no código, 0 – Não / 1 - Sim)
                               ,pr_cdopera2  IN crapope.cdoperad%TYPE   --> Operador
                               ,pr_cddsenha  IN crapope.cddsenha%TYPE   --> Senha
                               ,pr_flgsenha  IN INTEGER                 --> Validar senha
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Código da crítica
                               ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descricao da Critica

  PROCEDURE pc_solicita_resgate(pr_cdcooper  IN craprac.cdcooper%TYPE   --> Código da Cooperativa
                               ,pr_cdoperad  IN crapope.cdoperad%TYPE   --> Código do Operador
                               ,pr_nmdatela  IN craptel.nmdatela%TYPE   --> Nome da Tela
                               ,pr_idorigem  IN INTEGER                 --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  )
                               ,pr_nrdconta  IN craprac.nrdconta%TYPE   --> Número da Conta
                               ,pr_idseqttl  IN crapttl.idseqttl%TYPE   --> Titular da Conta
                               ,pr_nraplica  IN craprac.nraplica%TYPE   --> Número da Aplicação
                               ,pr_cdprodut  IN craprac.cdprodut%TYPE   --> Código do Produto
                               ,pr_dtresgat  IN crapdat.dtmvtolt%TYPE   --> Data do Resgate (Data informada em tela)
                               ,pr_vlresgat  IN craprga.vlresgat%TYPE   --> Valor do Resgate (Valor informado em tela)
                               ,pr_idtiprgt  IN craprga.idtiprgt%TYPE   --> Tipo do Resgate (Tipo informado em tela, 1 – Parcial / 2 – Total)
                               ,pr_idrgtcti  IN INTEGER                 --> Resgate na Conta Investimento (Identificador informado em tela, 0 – Não)
                               ,pr_idgerlog  IN INTEGER                 --> Identificador de Log (Fixo no código, 0 – Não / 1 - Sim)
                               ,pr_cdopera2  IN crapope.cdoperad%TYPE   --> Operador
                               ,pr_cddsenha  IN crapope.cddsenha%TYPE   --> Senha
                               ,pr_flgsenha  IN INTEGER                 --> Valida senha
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Código da crítica
                               ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descricao da Critica

  PROCEDURE pc_efetua_resgate(pr_cdcooper  IN craprga.cdcooper%TYPE   --> Código da cooperativa
                             ,pr_nrdconta  IN craprga.nrdconta%TYPE   --> Número da conta –
                             ,pr_nraplica  IN craprga.nraplica%TYPE   --> Número da aplicação
                             ,pr_vlresgat  IN craprga.vlresgat%TYPE   --> Valor do resgate
                             ,pr_idtiprgt  IN craprga.idtiprgt%TYPE   --> Tipo do resgate 1 - Parcial / 2 - Total
                             ,pr_dtresgat  IN crapdat.dtmvtolt%TYPE   --> Data do resgate
                             ,pr_nrseqrgt  IN craprga.nrseqrgt%TYPE   --> Numero de sequencia do resgate
                             ,pr_idrgtcti  IN craprga.idrgtcti%TYPE   --> Indicador de resgate na conta investimento (0-Nao / 1-Sim)
                             ,pr_tpcritic OUT crapcri.cdcritic%TYPE   --> Tipo da crítica (0- Nao aborta Processo/ 1 - Aborta Processo)
                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Código da crítica
                             ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descricao da Critica

  PROCEDURE pc_busca_extrato_aplicacao (pr_cdcooper IN craprac.cdcooper%TYPE,        -- Código da Cooperativa
                                        pr_cdoperad IN crapope.cdoperad%TYPE,        -- Código do Operador
                                        pr_nmdatela IN craptel.nmdatela%TYPE,        -- Nome da Tela
                                        pr_idorigem IN NUMBER,                       -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                        pr_nrdconta IN craprac.nrdconta%TYPE,        -- Número da Conta
                                        pr_idseqttl IN crapttl.idseqttl%TYPE,        -- Titular da Conta
                                        pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,        -- Data de Movimento
                                        pr_nraplica IN craprac.nraplica%TYPE,        -- Número da Aplicação
                                        pr_idlstdhs IN NUMBER,                       -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                        pr_idgerlog IN NUMBER,                       -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                        pr_tab_extrato OUT APLI0005.typ_tab_extrato, -- PLTable com os dados de extrato
                                        pr_vlresgat OUT NUMBER,                      -- Valor de resgate
                                        pr_vlrendim OUT NUMBER,                      -- Valor de rendimento
                                        pr_vldoirrf OUT NUMBER,                      -- Valor do IRRF
                                        pr_txacumul OUT NUMBER,                      -- Valor da taxa acumulado
                                        pr_txacumes OUT NUMBER,                      -- Valor da taxa acumulado mês
                                        pr_percirrf OUT NUMBER,                      -- Valor de aliquota de IR
                                        pr_cdcritic OUT crapcri.cdcritic%TYPE,       -- Código da crítica
                                        pr_dscritic OUT crapcri.dscritic%TYPE);      -- Descrição da crítica

  PROCEDURE pc_busca_extrato_aplicacao_car (pr_cdcooper IN craprac.cdcooper%TYPE,    -- Código da Cooperativa
                                            pr_cdoperad IN crapope.cdoperad%TYPE,    -- Código do Operador
                                            pr_nmdatela IN craptel.nmdatela%TYPE,    -- Nome da Tela
                                            pr_idorigem IN NUMBER,                   -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                            pr_nrdconta IN craprac.nrdconta%TYPE,    -- Número da Conta
                                            pr_idseqttl IN crapttl.idseqttl%TYPE,    -- Titular da Conta
                                            pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,    -- Data de Movimento
                                            pr_nraplica IN craprac.nraplica%TYPE,    -- Número da Aplicação
                                            pr_idlstdhs IN NUMBER,                   -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                            pr_idgerlog IN NUMBER,                   -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                            pr_vlresgat OUT NUMBER,                  -- Valor de resgate
                                            pr_vlrendim OUT NUMBER,                  -- Valor de rendimento
                                            pr_vldoirrf OUT NUMBER,                  -- Valor do IRRF
                                            pr_txacumul OUT NUMBER,                  -- Taxa acumulada durante o período total da aplicação
                                            pr_txacumes OUT NUMBER,                  -- Taxa acumulada durante o mês vigente
                                            pr_percirrf OUT NUMBER,                  -- Valor de aliquota de IR
                                            pr_clobxmlc OUT CLOB,                    -- XML com informações de LOG
                                            pr_cdcritic OUT crapcri.cdcritic%TYPE,   -- Código da crítica
                                            pr_dscritic OUT crapcri.dscritic%TYPE    -- Descrição da crítica
                                            );

  PROCEDURE pc_busca_extrato_aplicacao_web (pr_cdcooper IN craprac.cdcooper%TYPE,    -- Código da Cooperativa
                                            pr_cdoperad IN crapope.cdoperad%TYPE,    -- Código do Operador
                                            pr_nmdatela IN craptel.nmdatela%TYPE,    -- Nome da Tela
                                            pr_idorigem IN NUMBER,                   -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                            pr_nrdconta IN craprac.nrdconta%TYPE,    -- Número da Conta
                                            pr_idseqttl IN crapttl.idseqttl%TYPE,    -- Titular da Conta
                                            pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,    -- Data de Movimento
                                            pr_nraplica IN craprac.nraplica%TYPE,    -- Número da Aplicação
                                            pr_idlstdhs IN NUMBER,                   -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                            pr_idgerlog IN NUMBER,                   -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                            pr_vlresgat OUT NUMBER,                  -- Valor de resgate
                                            pr_vlrendim OUT NUMBER,                  -- Valor de rendimento
                                            pr_vldoirrf OUT NUMBER,                  -- Valor do IRRF
                                            pr_txacumul OUT NUMBER,                  -- Taxa acumulada durante o período total da aplicação
                                            pr_txacumes OUT NUMBER,                  -- Taxa acumulada durante o mês vigente
                                            pr_percirrf OUT NUMBER,                  -- Valor de aliquota de IR
                                            pr_retxml   IN OUT NOCOPY XMLType,       -- Arquivo de retorno do XML
                                            pr_nmdcampo OUT VARCHAR2,                -- Nome do campo com erro
                                            pr_des_erro OUT VARCHAR2,                -- Erros do processo
                                            pr_cdcritic OUT crapcri.cdcritic%TYPE,   -- Código da crítica
                                            pr_dscritic OUT crapcri.dscritic%TYPE    -- Descrição da crítica
                                            );

  PROCEDURE pc_consulta_resgates(pr_cdcooper IN  craprac.cdcooper%TYPE   -- Código da Cooperativa
                                ,pr_nrdconta IN  craprac.nrdconta%TYPE   -- Número da Conta
                                ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE   -- Data de Movimento
                                ,pr_nraplica IN  craprac.nraplica%TYPE   -- Número da Aplicação
                                ,pr_flgcance IN  INTEGER                 -- Indicador se é consulta de Cancelamento ou Proximo
                                ,pr_tab_resg OUT apli0002.typ_tab_resgate_aplicacao  -- Tabela com informacoes sobre resgates
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE   -- Codigo da critica
                                ,pr_dscritic OUT crapcri.dscritic%TYPE); -- Descricao da critica

  PROCEDURE pc_consulta_resgates_car(pr_cdcooper  IN  craprac.cdcooper%TYPE -- Código da Cooperativa
                                    ,pr_cdagenci  IN crapage.cdagenci%TYPE  -- Codigo de agencia
                                    ,pr_nrdcaixa  IN INTEGER                -- Numero de caixa
                                    ,pr_cdoperad  IN VARCHAR2               -- Codigo do cooperado
                                    ,pr_nmdatela  IN VARCHAR2               -- Nome da tela
                                    ,pr_idorigem  IN INTEGER                -- Origem da transacao
                                    ,pr_idseqttl  IN crapttl.idseqttl%TYPE  -- Sequencial do titular
                                    ,pr_nrdconta  IN craprac.nrdconta%TYPE  -- Número da Conta
                                    ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE  -- Data de Movimento
                                    ,pr_nraplica  IN craprac.nraplica%TYPE  -- Numero da Aplicacao
                                    ,pr_flgcance  IN INTEGER                --> Indicador de opcao (Cancelamento/Proximo)
                                    ,pr_flgerlog  IN INTEGER                --> Gravar log
                                    ,pr_clobxmlc OUT CLOB                   -- XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER            -- Código da crítica
                                    ,pr_dscritic OUT VARCHAR2);             -- Descrição da crítica

  PROCEDURE pc_consulta_resgates_web(pr_idseqttl  IN crapttl.idseqttl%TYPE --> Sequencial do titular
                                    ,pr_nrdconta  IN craprac.nrdconta%TYPE --> Número da Conta
                                    ,pr_dtmvtolt  IN VARCHAR2              --> Data de Movimento
                                    ,pr_nraplica  IN craprac.nraplica%TYPE --> Numero da Aplicacao
                                    ,pr_flgcance  IN NUMBER                --> Indicador de opcao (Cancelamento/Proximo)
                                    ,pr_flgerlog  IN NUMBER                --> Gravar log
                                    ,pr_xmllog   IN VARCHAR2                          --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER                      --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2                         --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType                --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2                         --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2
                                    ); --> Descrição da crítica

  PROCEDURE pc_cancela_resgate(pr_cdcooper  IN crapcop.cdcooper%TYPE   -- Codigo da Cooperativa
                              ,pr_cdagenci  IN crapage.cdagenci%TYPE   -- Codigo do PA
                              ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE   -- Numero do caixa
                              ,pr_cdoperad  IN crapope.cdoperad%TYPE   -- Codigo do operador
                              ,pr_nmdatela  IN craptel.nmdatela%TYPE   -- Nome da tela
                              ,pr_idorigem  IN INTEGER                 -- Identificador de sistema de origem
                              ,pr_nrdconta  IN crapass.nrdconta%TYPE   -- Numero da conta
                              ,pr_idseqttl  IN crapttl.idseqttl%TYPE   -- Sequencia do titular
                              ,pr_nraplica  IN craprac.nraplica%TYPE   -- Numero da aplicacao
                              ,pr_nrdocmto  IN INTEGER                 -- Numero do documento
                              ,pr_dtresgat  IN crapdat.dtmvtolt%TYPE   -- Data de resgate
                              ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE   -- Data de movimento atual
                              ,pr_flgerlog  IN INTEGER                 -- Flag para gerar log
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE   -- Codigo da critica
                              ,pr_dscritic OUT crapcri.dscritic%TYPE); -- Descricao da critica

  PROCEDURE pc_cancela_resgate_web(pr_nrdconta IN crapass.nrdconta%TYPE     -- Numero da conta
                                  ,pr_idseqttl IN crapttl.idseqttl%TYPE     -- Sequecia do titular
                                  ,pr_nraplica IN craprac.nraplica%TYPE     -- Numero da aplicacao
                                  ,pr_nrdocmto IN INTEGER                   -- Numero do Documento
                                  ,pr_dtresgat IN VARCHAR2                  -- Data de resgate
                                  ,pr_dtmvtolt IN VARCHAR2                  -- Data de movimento atual
                                  ,pr_xmllog   IN VARCHAR2                  -- XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER              -- Código da crítica
                                  ,pr_dscritic OUT VARCHAR2                 -- Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType        -- Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2                 -- Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);               -- Erros do processo

  PROCEDURE pc_calc_sld_resg_varias(pr_flagauto IN INTEGER                  -- Indicador de Resgate Automatico e Manual
                                   ,pr_cdcooper IN crapcop.cdcooper%TYPE    -- Codigo da cooperativa
                                   ,pr_cdagenci IN crapage.cdagenci%TYPE    -- Codigo do PA
                                   ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE    -- Codigo do Caixa
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE    -- Codigo do Operador
                                   ,pr_nmdatela IN craptel.nmdatela%TYPE    -- Nome da Tela
                                   ,pr_idorigem IN INTEGER                  -- Origem da solicitacao
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE    -- Numero da conta
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE    -- Sequecia do titular
                                   ,pr_nraplica IN craprac.nraplica%TYPE    -- Numero da aplicacao
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE    -- Data de movimento atual
                                   ,pr_cdprogra IN craplog.cdprogra%TYPE    -- Codigo do programa
                                   ,pr_flgerlog IN INTEGER                  -- Flag para gerar log
                                   ,pr_vlsldtot OUT craprac.vlaplica%TYPE   -- Valor de saldo total
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE   -- Codigo da critica
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE); -- Descricao da critica

  PROCEDURE pc_calc_sld_resg_varias_web(pr_flagauto IN INTEGER               --> Indicador de Resgate Automatico e Manual
                                       ,pr_nrdconta IN craprac.nrdconta%TYPE --> Número da Conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Sequecia do titular
                                       ,pr_nraplica IN craprac.nraplica%TYPE --> Número da Aplicação
                                       ,pr_dtmvtolt IN VARCHAR2              --> Data do Resgate (Data informada em tela)
                                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Procedure para listar o resgate de varias aplicacoes de forma manual
  PROCEDURE pc_ret_apl_resg_manu(pr_cdcooper IN crapcop.cdcooper%TYPE              --> Codigo Cooperativa
                                ,pr_cdagenci IN crapass.cdagenci%TYPE              --> Codigo Agencia
                                ,pr_nrdcaixa IN INTEGER                            --> Numero do Caixa
                                ,pr_cdoperad IN VARCHAR2                           --> Codigo do Operador
                                ,pr_nmdatela IN VARCHAR2                           --> Nome da Tela
                                ,pr_idorigem IN INTEGER                            --> Origem
                                ,pr_nrdconta IN crapass.nrdconta%TYPE              --> Número da Conta
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE              --> Sequencia do Titular
                                ,pr_nraplica IN craprda.nraplica%TYPE              --> Número da Aplicação
                                ,pr_dtmvtolt IN DATE                               --> Data de Movimentação
                                ,pr_cdprogra IN VARCHAR2                           --> Codigo do Programa
                                ,pr_flgerlog IN INTEGER                            --> Gerar Log (0-False / 1-True)
                                ,pr_des_reto OUT VARCHAR2                          --> Retorno 'OK'/'NOK'
                                ,pr_tab_dados_resgate OUT APLI0001.typ_tab_resgate --> Tabela de Dados de Resgate
                                ,pr_tab_erro OUT gene0001.typ_tab_erro);           --> Tabela Erros

  -- Procedure para listar o resgate de varias aplicacoes de forma automatica
  PROCEDURE pc_ret_apl_resg_aut(pr_cdcooper IN crapcop.cdcooper%TYPE     -- Codigo da cooperativa
                               ,pr_cdagenci IN crapage.cdagenci%TYPE     -- Codigo do PA
                               ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE     -- Codigo do Caixa
                               ,pr_cdoperad IN crapope.cdoperad%TYPE     -- Codigo do Operador
                               ,pr_nmdatela IN craptel.nmdatela%TYPE     -- Nome da Tela
                               ,pr_idorigem IN INTEGER                   -- Origem da solicitacao
                               ,pr_nrdconta IN crapass.nrdconta%TYPE     -- Numero da conta
                               ,pr_idseqttl IN crapttl.idseqttl%TYPE     -- Sequecia do titular
                               ,pr_nraplica IN craprac.nraplica%TYPE     -- Numero da aplicacao
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE     -- Data de movimento atual
                               ,pr_dtmvtopr IN crapdat.dtmvtolt%TYPE     -- Data de movimento proximo
                               ,pr_dtresgat IN crapdat.dtmvtolt%TYPE     -- Data de resgate
                               ,pr_cdprogra IN craplog.cdprogra%TYPE     -- Codigo do programa
                               ,pr_flgerlog IN INTEGER                   -- Flag para gerar log
                               ,pr_vltotrgt IN OUT craprac.vlaplica%TYPE -- Valor de saldo total
                               ,pr_resposta IN OUT VARCHAR2              -- Inf com dados cliente
                               ,pr_resgates IN OUT VARCHAR2              -- Inf com dados resgate
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE    -- Codigo da critica
                               ,pr_dscritic OUT crapcri.dscritic%TYPE);  -- Descricao da critica

  PROCEDURE pc_ret_apl_resg_aut_web(pr_nrdconta IN crapass.nrdconta%TYPE     -- Numero da conta
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE     -- Sequecia do titular
                                   ,pr_nraplica IN craprac.nraplica%TYPE     -- Numero da aplicacao
                                   ,pr_dtmvtolt IN VARCHAR2                  -- Data de movimento atual
                                   ,pr_dtmvtopr IN VARCHAR2                  -- Data de movimento proximo
                                   ,pr_dtresgat IN VARCHAR2                  -- Data de resgate
                                   ,pr_vltotrgt IN craprac.vlaplica%TYPE     -- Valor de saldo total
                                   ,pr_flgerlog IN INTEGER                   -- Flag para gerar log
                                   ,pr_resposta IN VARCHAR2                  -- Inf com dados de resposta dos clientes
                                   ,pr_resgates IN VARCHAR2                  -- Inf com dados de resgates
                                   ,pr_xmllog   IN VARCHAR2                  -- XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER              -- Código da crítica
                                   ,pr_dscritic OUT VARCHAR2                 -- Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType        -- Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2                 -- Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);               -- Erros do processo

  /* Procedure para validacao de solicitacao de resgate */
  PROCEDURE pc_val_solicit_resgate_web(pr_nrdconta IN craprac.nrdconta%TYPE --> Número da Conta
                                      ,pr_nraplica IN craprac.nraplica%TYPE --> Número da Aplicação
                                      ,pr_dtresgat IN VARCHAR2              --> Data do Resgate (Data informada em tela)
                                      ,pr_vlresgat IN NUMBER               --> Valor do Resgate (Valor informado em tela)
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Sequencial de titular
                                      ,pr_idtiprgt IN INTEGER               --> Tipo do Resgate (Tipo informado em tela, 1 – Parcial / 2 – Total)
                                      ,pr_idrgtcti IN INTEGER               --> Resgate na Conta Investimento (Identificador informado em tela, 0 – Não)
                                      ,pr_idvldblq IN INTEGER               --> Identificador de validação do bloqueio judicial (0 – Não / 1 – Sim)
                                      ,pr_idgerlog IN INTEGER               --> Identificador de Log (Fixo no código, 0 – Não / 1 - Sim)
                                      ,pr_idvalida IN INTEGER               --> Identificador de Validacao (0 – Valida / 1 - Cadastra)
                                      ,pr_cdopera2 IN crapope.cdoperad%TYPE --> Operador
                                      ,pr_cddsenha IN crapope.cddsenha%TYPE --> Senha
                                      ,pr_flgsenha IN INTEGER               --> Valida senha
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  PROCEDURE pc_obtem_resgates_conta(pr_cdcooper     IN crapcop.cdcooper%TYPE        --> Codigo Cooperativa
                                   ,pr_cdagenci     IN crapass.cdagenci%TYPE        --> Codigo Agencia
                                   ,pr_nrdcaixa     IN INTEGER                      --> Numero do Caixa
                                   ,pr_cdoperad     IN crapope.cdoperad%TYPE        --> Codigo do Operador
                                   ,pr_nmdatela     IN VARCHAR2                     --> Nome da Tela
                                   ,pr_idorigem     IN INTEGER                      --> Origem da solicitacao
                                   ,pr_nrdconta     IN craprac.nrdconta%TYPE        --> Número da Conta
                                   ,pr_idseqttl     IN crapttl.idseqttl%TYPE        --> Sequencia do Titular
                                   ,pr_dtmvtolt     IN DATE                         --> Data de Movimentação
                                   ,pr_flgcance     IN INTEGER                      --> Flag de Cancelamento
                                   ,pr_flgerlog     IN INTEGER                      --> Gerar Log (0-False / 1-True)
                                   ,pr_resg_aplica OUT APLI0005.typ_tab_resg_aplica --> Tabela com os dados de resgate de aplicacoes
                                   ,pr_cdcritic    OUT crapcri.cdcritic%TYPE        --> Codigo da critica
                                   ,pr_dscritic    OUT crapcri.dscritic%TYPE);      --> Descricao da critica

  -- Procedure para consulta de proximos resgates via WEB
  PROCEDURE pc_obtem_resg_conta_web(pr_nrdconta IN crapass.nrdconta%TYPE -- Numero da conta
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE -- Sequecia do titular
                                   ,pr_dtmvtolt IN VARCHAR2              -- Data de movimento atual
                                   ,pr_flgcance IN INTEGER               -- Flag de cancelamento
                                   ,pr_flgerlog IN INTEGER               -- Flag de LOG
                                   ,pr_xmllog   IN VARCHAR2              -- XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          -- Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             -- Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    -- Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             -- Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);           -- Erros do processo

  PROCEDURE pc_cadast_varios_resgat_aplica(pr_cdcooper          IN crapcop.cdcooper%TYPE         --> Codigo Cooperativa
                                          ,pr_cdagenci          IN crapass.cdagenci%TYPE         --> Codigo Agencia
                                          ,pr_nrdcaixa          IN INTEGER                       --> Numero do Caixa
                                          ,pr_cdoperad          IN crapope.cdoperad%TYPE         --> Codigo do Operador
                                          ,pr_nmdatela          IN VARCHAR2                      --> Nome da Tela
                                          ,pr_idorigem          IN INTEGER                       --> Origem da solicitacao
                                          ,pr_nrdconta          IN crapass.nrdconta%TYPE         --> Numero da Conta
                                          ,pr_idseqttl          IN crapttl.idseqttl%TYPE         --> Sequencia do Titular
                                          ,pr_dtresgat          IN DATE                          --> Data de resgate
                                          ,pr_flgctain          IN INTEGER                       --> Resgate conta investimento
                                          ,pr_dtmvtolt          IN DATE                          --> Data de movimento
                                          ,pr_dtmvtopr          IN DATE                          --> Proxima data de movimento
                                          ,pr_cdprogra          IN VARCHAR2                      --> Codigo do programa
                                          ,pr_flmensag          IN INTEGER                       --> Flag de mensagem
                                          ,pr_inproces          IN crapdat.inproces%TYPE         --> Indicador do status do sistema
                                          ,pr_flgerlog          IN INTEGER                       --> Gerar Log (0-False / 1-True)
                                          ,pr_tab_resgate       IN APLI0001.typ_tab_resgate      --> PLTable de resgate
                                          ,pr_nrdocmto         OUT VARCHAR2                      --> Numero do documento
                                          ,pr_des_reto         OUT VARCHAR2                      --> Retorno OK/NOK
                                          ,pr_tab_msg_confirma OUT APLI0002.typ_tab_msg_confirma --> PLTable de confirmacao
                                          ,pr_tab_erro         OUT GENE0001.typ_tab_erro);       --> PLTable de erros

  PROCEDURE pc_busca_saldo_total_resgate(pr_cdcooper  IN craprac.cdcooper%TYPE           --> Código da Cooperativa
                                        ,pr_cdoperad  IN crapope.cdoperad%TYPE DEFAULT 1 --> Código do Operador
                                        ,pr_nmdatela  IN craptel.nmdatela%TYPE           --> Nome da Tela
                                        ,pr_idorigem  IN INTEGER                         --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                        ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE           --> Numero do Caixa
                                        ,pr_nrdconta  IN craprac.nrdconta%TYPE           --> Número da Conta
                                        ,pr_idseqttl  IN crapttl.idseqttl%TYPE           --> Titular da Conta
                                        ,pr_cdagenci  IN crapage.cdagenci%TYPE           --> Codigo da Agencia
                                        ,pr_cdprogra  IN craplog.cdprogra%TYPE           --> Codigo do Programa
                                        ,pr_nraplica  IN craprac.nraplica%TYPE DEFAULT 0 --> Número da Aplicação - Parâmetro Opcional
                                        ,pr_cdprodut  IN craprac.cdprodut%TYPE DEFAULT 0 --> Código do Produto – Parâmetro Opcional
                                        ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE           --> Data de Movimento
                                        ,pr_idconsul  IN INTEGER                         --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                        ,pr_idgerlog  IN INTEGER                         --> Identificador de Log (0 – Não / 1 – Sim)
                                        ,pr_vlsldisp OUT craprda.vlsdrdca%TYPE           --> Valor do saldo disponivel para resgate
                                        ,pr_cdcritic OUT PLS_INTEGER                     --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2);

END APLI0005;
/
CREATE OR REPLACE PACKAGE BODY CECRED.APLI0005 IS

  -- Cursor genérico de parametrização
  CURSOR cr_craptab_taxas(pr_cdcooper IN craptab.cdcooper%TYPE
                         ,pr_nmsistem IN craptab.nmsistem%TYPE
                         ,pr_tptabela IN craptab.tptabela%TYPE
                         ,pr_cdempres IN craptab.cdempres%TYPE
                         ,pr_cdacesso IN craptab.cdacesso%TYPE
                         ,pr_dstextab IN craptab.dstextab%TYPE) IS
    SELECT craptab.dstextab
          ,craptab.tpregist
      FROM craptab craptab
     WHERE craptab.cdcooper = pr_cdcooper
       AND UPPER(craptab.nmsistem) = UPPER(pr_nmsistem)
       AND UPPER(craptab.tptabela) = UPPER(pr_tptabela)
       AND craptab.cdempres = pr_cdempres
       AND UPPER(craptab.cdacesso) = UPPER(pr_cdacesso)
       AND craptab.dstextab = pr_dstextab;

  -- Rotina referente a consulta de saldos de aplicacao
  PROCEDURE pc_busca_saldo_aplicacoes(pr_cdcooper IN craprac.cdcooper%TYPE           --> Código da Cooperativa
                                     ,pr_cdoperad IN crapope.cdoperad%TYPE           --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE           --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                         --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                     ,pr_nrdconta IN craprac.nrdconta%TYPE           --> Número da Conta
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE           --> Titular da Conta
                                     ,pr_nraplica IN craprac.nraplica%TYPE DEFAULT 0 --> Número da Aplicação / Parâmetro Opcional
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE           --> Data de Movimento
                                     ,pr_cdprodut IN craprac.cdprodut%TYPE DEFAULT 0 --> Código do Produto -–> Parâmetro Opcional
                                     ,pr_idblqrgt IN INTEGER                         --> Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas)
                                     ,pr_idgerlog IN INTEGER                         --> Identificador de Log (0 – Não / 1 – Sim)
                                     ,pr_vlsldtot OUT NUMBER                         --> Saldo Total da Aplicação
                                     ,pr_vlsldrgt OUT NUMBER                         --> Saldo Total para Resgate
                                     ,pr_cdcritic OUT PLS_INTEGER                    --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS                   --> Descrição da crítica
  BEGIN

    /* .............................................................................

     Programa: pc_busca_saldo_aplicacoes
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Julho/14.                    Ultima atualizacao: 22/07/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a consulta de saldo de aplicacoes.

     Observacao: -----

     Alteracoes:

    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_vlbascal NUMBER := 0; -- Base de Calculo
      vr_vlsldtot NUMBER := 0; -- Saldo Total
      vr_vlsldrgt NUMBER := 0; -- Saldo de Resgate
      vr_vlultren NUMBER := 0; -- Ultimo Rendimento
      vr_vlrentot NUMBER := 0; -- Rendimento Total
      vr_vlrevers NUMBER := 0; -- Valor de Reversão
      vr_vlrdirrf NUMBER := 0; -- Valor de IRRF
      vr_percirrf NUMBER := 0; -- Percentual de IRRF
      vr_auxconta INTEGER := 0; -- Contador de aplicacoes

      --Variáveis locais
      vr_dstransa VARCHAR2(100) := 'Consulta de aplicacao num: ' || pr_nraplica;
      vr_dsorigem VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_nrdrowid ROWID;

      -- Selecionar dados da aplicacao
      CURSOR cr_craprac(pr_cdcooper IN craprac.cdcooper%TYPE --> Código da Cooperativa
                       ,pr_nrdconta IN craprac.nrdconta%TYPE --> Número da Conta
                       ,pr_nraplica IN craprac.nraplica%TYPE --> Número da Aplicação
                       ,pr_cdprodut IN craprac.cdprodut%TYPE --> Codigo do Produto
                       ,pr_idblqrgt IN craprac.idblqrgt%TYPE --> Indice de Bloqueio de Resgate
                       ) IS

        SELECT
          rac.cdcooper
         ,rac.nrdconta
         ,rac.nraplica
         ,rac.dtmvtolt
         ,rac.txaplica
         ,rac.qtdiacar
         ,rac.cdprodut
        FROM
          craprac rac
        WHERE
              rac.cdcooper = pr_cdcooper
          AND rac.nrdconta = pr_nrdconta
          AND (rac.nraplica = pr_nraplica OR pr_nraplica = 0)
          AND (rac.cdprodut = pr_cdprodut OR pr_cdprodut = 0)
          AND rac.nrctrrpp = 0 -- Apenas Aplicações não programadas
          AND rac.idsaqtot = 0
          AND ((rac.idblqrgt >= 0 AND pr_idblqrgt = 1)
           OR (rac.idblqrgt >  0  AND pr_idblqrgt = 2)
           OR (rac.idblqrgt =  0  AND pr_idblqrgt = 3));

      rw_craprac cr_craprac%ROWTYPE;

      -- Selecionar dados de produtos
      CURSOR cr_crapcpc(pr_cdprodut IN crapcpc.cdprodut%TYPE) IS --> Codigo do Produto

        SELECT
          cpc.idtxfixa
         ,cpc.cddindex
         ,cpc.idtippro
        FROM
          crapcpc cpc
        WHERE
          cpc.cdprodut = pr_cdprodut;

      rw_crapcpc cr_crapcpc%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    BEGIN

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;

      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      FOR rw_craprac IN  cr_craprac(pr_cdcooper => pr_cdcooper   --> Código da Cooperativa
                                   ,pr_nrdconta => pr_nrdconta   --> Número da Conta
                                   ,pr_nraplica => pr_nraplica   --> Número da Aplicação
                                   ,pr_cdprodut => pr_cdprodut   --> Codigo do Produto
                                   ,pr_idblqrgt => pr_idblqrgt) --> Indice de Bloqueio de Resgate

      LOOP

        OPEN cr_crapcpc(pr_cdprodut => rw_craprac.cdprodut);

        FETCH cr_crapcpc INTO rw_crapcpc;

        IF cr_crapcpc%NOTFOUND THEN
          CLOSE cr_crapcpc;
          vr_dscritic := 'Erro ao consulta produto APLI0005.pc_busca_saldo_aplicacoes';
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_crapcpc;
        END IF;

        -- Valor de base de calculo
        vr_vlbascal := 0;

        -- Verifica tipo do produto de aplicacao
        IF rw_crapcpc.idtippro = 1 THEN -- Pre-Fixada

          -- Consulta saldo de aplicacao pre
          apli0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => rw_craprac.cdcooper -- Codigo da Cooperativa
                                                 ,pr_nrdconta => rw_craprac.nrdconta -- Conta do Cooperado
                                                 ,pr_nraplica => rw_craprac.nraplica -- Numero da Aplicacao
                                                 ,pr_dtiniapl => rw_craprac.dtmvtolt -- Data de Movimento
                                                 ,pr_txaplica => rw_craprac.txaplica -- Taxa de Aplicacao
                                                 ,pr_idtxfixa => rw_crapcpc.idtxfixa -- Taxa Fixa (0-Nao / 1-Sim)
                                                 ,pr_cddindex => rw_crapcpc.cddindex -- Codigo de Indexador
                                                 ,pr_qtdiacar => rw_craprac.qtdiacar -- Quantidade de Dias de Carencia
                                                 ,pr_idgravir => 0                   -- Imunidade Tributaria
                                                 ,pr_dtinical => rw_craprac.dtmvtolt -- Data de Inicio do Calculo
                                                 ,pr_dtfimcal => pr_dtmvtolt         -- Data de Fim do Calculo
                                                 ,pr_idtipbas => 2                   -- Tipo Base / 2-Total
                                                 ,pr_vlbascal => vr_vlbascal         -- Valor de Base
                                                 ,pr_vlsldtot => vr_vlsldtot         -- Valor de Saldo Total
                                                 ,pr_vlsldrgt => vr_vlsldrgt         -- Valor de Saldo p/ Resgate
                                                 ,pr_vlultren => vr_vlultren         -- Valor do ultimo rendimento
                                                 ,pr_vlrentot => vr_vlrentot         -- Valor de rendimento total
                                                 ,pr_vlrevers => vr_vlrevers         -- Valor de reversao
                                                 ,pr_vlrdirrf => vr_vlrdirrf         -- Valor de IRRF
                                                 ,pr_percirrf => vr_percirrf         -- Percentual de IRRF
                                                 ,pr_cdcritic => vr_cdcritic         -- Codigo de Critica
                                                 ,pr_dscritic => vr_dscritic);       -- Descricao de Critica

        ELSIF rw_crapcpc.idtippro = 2 THEN -- Pos-Fixada

          -- Consulta saldo de aplicacao pos
          apli0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => rw_craprac.cdcooper -- Codigo da Cooperativa
                                                 ,pr_nrdconta => rw_craprac.nrdconta -- Conta do Cooperado
                                                 ,pr_nraplica => rw_craprac.nraplica -- Numero da Aplicacao
                                                 ,pr_dtiniapl => rw_craprac.dtmvtolt -- Data de Movimento
                                                 ,pr_txaplica => rw_craprac.txaplica -- Taxa de Aplicacao
                                                 ,pr_idtxfixa => rw_crapcpc.idtxfixa -- Taxa Fixa (0-Nao / 1-Sim)
                                                 ,pr_cddindex => rw_crapcpc.cddindex -- Codigo de Indexador
                                                 ,pr_qtdiacar => rw_craprac.qtdiacar -- Quantidade de Dias de Carencia
                                                 ,pr_idgravir => 0                   -- Imunidade Tributaria
                                                 ,pr_dtinical => rw_craprac.dtmvtolt -- Data de Inicio do Calculo
                                                 ,pr_dtfimcal => pr_dtmvtolt         -- Data de Fim do Calculo
                                                 ,pr_idtipbas => 2                   -- Tipo Base / 2-Total
                                                 ,pr_vlbascal => vr_vlbascal         -- Valor de Base
                                                 ,pr_vlsldtot => vr_vlsldtot         -- Valor de Saldo Total
                                                 ,pr_vlsldrgt => vr_vlsldrgt         -- Valor de Saldo p/ Resgate
                                                 ,pr_vlultren => vr_vlultren         -- Valor do ultimo rendimento
                                                 ,pr_vlrentot => vr_vlrentot         -- Valor de rendimento total
                                                 ,pr_vlrevers => vr_vlrevers         -- Valor de reversao
                                                 ,pr_vlrdirrf => vr_vlrdirrf         -- Valor de IRRF
                                                 ,pr_percirrf => vr_percirrf         -- Percentual de IRRF
                                                 ,pr_cdcritic => vr_cdcritic         -- Codigo de Critica
                                                 ,pr_dscritic => vr_dscritic);       -- Descricao de Critica
        END IF;

        pr_vlsldtot := NVL(pr_vlsldtot,0) + NVL(vr_vlsldtot,0);
        pr_vlsldrgt := NVL(pr_vlsldrgt,0) + NVL(vr_vlsldrgt,0);

        vr_auxconta := NVL(vr_auxconta,0) + 1;

      END LOOP;

      IF vr_auxconta = 0 THEN
        pr_vlsldtot := 0;
        pr_vlsldrgt := 0;
      END IF;

      -- Verifica se deve gerar log
      IF pr_idgerlog = 1 THEN
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        ROLLBACK;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Verifica se deve gerar log
        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
          COMMIT;
        END IF;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Consulta de Saldo APLI0005.pc_busca_saldo_aplicacoes: ' ||
                       SQLERRM;
        ROLLBACK;
    END;

  END pc_busca_saldo_aplicacoes;

  -- Rotina referente a consulta de saldos de aplicacao
  PROCEDURE pc_busca_saldo_aplic_prog(pr_cdcooper IN craprac.cdcooper%TYPE           --> Código da Cooperativa
                                     ,pr_cdoperad IN crapope.cdoperad%TYPE           --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE           --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                         --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                     ,pr_nrdconta IN craprac.nrdconta%TYPE           --> Número da Conta
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE           --> Titular da Conta
                                     ,pr_nraplica IN craprac.nraplica%TYPE DEFAULT 0 --> Número da Aplicação / Parâmetro Opcional
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE           --> Data de Movimento
                                     ,pr_cdprodut IN craprac.cdprodut%TYPE DEFAULT 0 --> Código do Produto -–> Parâmetro Opcional
                                     ,pr_idblqrgt IN INTEGER                         --> Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas)
                                     ,pr_idgerlog IN INTEGER                         --> Identificador de Log (0 – Não / 1 – Sim)
                                     ,pr_vlsldtot OUT NUMBER                         --> Saldo Total da Aplicação
                                     ,pr_vlsldrgt OUT NUMBER                         --> Saldo Total para Resgate
                                     ,pr_cdcritic OUT PLS_INTEGER                    --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS                   --> Descrição da crítica
  BEGIN

    /* .............................................................................

     Programa: pc_busca_saldo_aplic_prog
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : CIS Corporate
     Data    : Julho/18.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a consulta de saldo de aplicacoes programadas.

     Observacao: -----

     Alteracoes:

    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_vlbascal NUMBER := 0; -- Base de Calculo
      vr_vlsldtot NUMBER := 0; -- Saldo Total
      vr_vlsldrgt NUMBER := 0; -- Saldo de Resgate
      vr_vlultren NUMBER := 0; -- Ultimo Rendimento
      vr_vlrentot NUMBER := 0; -- Rendimento Total
      vr_vlrevers NUMBER := 0; -- Valor de Reversão
      vr_vlrdirrf NUMBER := 0; -- Valor de IRRF
      vr_percirrf NUMBER := 0; -- Percentual de IRRF
      vr_auxconta INTEGER := 0; -- Contador de aplicacoes

      --Variáveis locais
      vr_dstransa VARCHAR2(100) := 'Consulta de aplicacao num: ' || pr_nraplica;
      vr_dsorigem VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_nrdrowid ROWID;

      -- Selecionar dados da aplicacao
      CURSOR cr_craprac(pr_cdcooper IN craprac.cdcooper%TYPE --> Código da Cooperativa
                       ,pr_nrdconta IN craprac.nrdconta%TYPE --> Número da Conta
                       ,pr_nraplica IN craprac.nraplica%TYPE --> Número da Aplicação
                       ,pr_cdprodut IN craprac.cdprodut%TYPE --> Codigo do Produto
                       ,pr_idblqrgt IN craprac.idblqrgt%TYPE --> Indice de Bloqueio de Resgate
                       ) IS

        SELECT
          rac.cdcooper
         ,rac.nrdconta
         ,rac.nraplica
         ,rac.dtmvtolt
         ,rac.txaplica
         ,rac.qtdiacar
         ,rac.cdprodut
        FROM
          craprac rac
        WHERE
              rac.cdcooper = pr_cdcooper
          AND rac.nrdconta = pr_nrdconta
          AND (rac.nraplica = pr_nraplica OR pr_nraplica = 0)
          AND (rac.cdprodut = pr_cdprodut OR pr_cdprodut = 0)
          AND rac.nrctrrpp > 0 -- Apenas Aplicações programadas
          AND rac.idsaqtot = 0
          AND ((rac.idblqrgt >= 0 AND pr_idblqrgt = 1)
           OR (rac.idblqrgt >  0  AND pr_idblqrgt = 2)
           OR (rac.idblqrgt =  0  AND pr_idblqrgt = 3));

      rw_craprac cr_craprac%ROWTYPE;

      -- Selecionar dados de produtos
      CURSOR cr_crapcpc(pr_cdprodut IN crapcpc.cdprodut%TYPE) IS --> Codigo do Produto

        SELECT
          cpc.idtxfixa
         ,cpc.cddindex
         ,cpc.idtippro
        FROM
          crapcpc cpc
        WHERE
          cpc.cdprodut = pr_cdprodut;

      rw_crapcpc cr_crapcpc%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    BEGIN

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;

      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      FOR rw_craprac IN  cr_craprac(pr_cdcooper => pr_cdcooper   --> Código da Cooperativa
                                   ,pr_nrdconta => pr_nrdconta   --> Número da Conta
                                   ,pr_nraplica => pr_nraplica   --> Número da Aplicação
                                   ,pr_cdprodut => pr_cdprodut   --> Codigo do Produto
                                   ,pr_idblqrgt => pr_idblqrgt) --> Indice de Bloqueio de Resgate

      LOOP

        OPEN cr_crapcpc(pr_cdprodut => rw_craprac.cdprodut);

        FETCH cr_crapcpc INTO rw_crapcpc;

        IF cr_crapcpc%NOTFOUND THEN
          CLOSE cr_crapcpc;
          vr_dscritic := 'Erro ao consulta produto APLI0005.pc_busca_saldo_aplic_prog';
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_crapcpc;
        END IF;

        -- Valor de base de calculo
        vr_vlbascal := 0;

        -- Verifica tipo do produto de aplicacao
        IF rw_crapcpc.idtippro = 1 THEN -- Pre-Fixada

          -- Consulta saldo de aplicacao pre
          apli0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => rw_craprac.cdcooper -- Codigo da Cooperativa
                                                 ,pr_nrdconta => rw_craprac.nrdconta -- Conta do Cooperado
                                                 ,pr_nraplica => rw_craprac.nraplica -- Numero da Aplicacao
                                                 ,pr_dtiniapl => rw_craprac.dtmvtolt -- Data de Movimento
                                                 ,pr_txaplica => rw_craprac.txaplica -- Taxa de Aplicacao
                                                 ,pr_idtxfixa => rw_crapcpc.idtxfixa -- Taxa Fixa (0-Nao / 1-Sim)
                                                 ,pr_cddindex => rw_crapcpc.cddindex -- Codigo de Indexador
                                                 ,pr_qtdiacar => rw_craprac.qtdiacar -- Quantidade de Dias de Carencia
                                                 ,pr_idgravir => 0                   -- Imunidade Tributaria
                                                 ,pr_dtinical => rw_craprac.dtmvtolt -- Data de Inicio do Calculo
                                                 ,pr_dtfimcal => pr_dtmvtolt         -- Data de Fim do Calculo
                                                 ,pr_idtipbas => 2                   -- Tipo Base / 2-Total
                                                 ,pr_vlbascal => vr_vlbascal         -- Valor de Base
                                                 ,pr_vlsldtot => vr_vlsldtot         -- Valor de Saldo Total
                                                 ,pr_vlsldrgt => vr_vlsldrgt         -- Valor de Saldo p/ Resgate
                                                 ,pr_vlultren => vr_vlultren         -- Valor do ultimo rendimento
                                                 ,pr_vlrentot => vr_vlrentot         -- Valor de rendimento total
                                                 ,pr_vlrevers => vr_vlrevers         -- Valor de reversao
                                                 ,pr_vlrdirrf => vr_vlrdirrf         -- Valor de IRRF
                                                 ,pr_percirrf => vr_percirrf         -- Percentual de IRRF
                                                 ,pr_cdcritic => vr_cdcritic         -- Codigo de Critica
                                                 ,pr_dscritic => vr_dscritic);       -- Descricao de Critica

        ELSIF rw_crapcpc.idtippro = 2 THEN -- Pos-Fixada

          -- Consulta saldo de aplicacao pos
          apli0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => rw_craprac.cdcooper -- Codigo da Cooperativa
                                                 ,pr_nrdconta => rw_craprac.nrdconta -- Conta do Cooperado
                                                 ,pr_nraplica => rw_craprac.nraplica -- Numero da Aplicacao
                                                 ,pr_dtiniapl => rw_craprac.dtmvtolt -- Data de Movimento
                                                 ,pr_txaplica => rw_craprac.txaplica -- Taxa de Aplicacao
                                                 ,pr_idtxfixa => rw_crapcpc.idtxfixa -- Taxa Fixa (0-Nao / 1-Sim)
                                                 ,pr_cddindex => rw_crapcpc.cddindex -- Codigo de Indexador
                                                 ,pr_qtdiacar => rw_craprac.qtdiacar -- Quantidade de Dias de Carencia
                                                 ,pr_idgravir => 0                   -- Imunidade Tributaria
                                                 ,pr_dtinical => rw_craprac.dtmvtolt -- Data de Inicio do Calculo
                                                 ,pr_dtfimcal => pr_dtmvtolt         -- Data de Fim do Calculo
                                                 ,pr_idtipbas => 2                   -- Tipo Base / 2-Total
                                                 ,pr_vlbascal => vr_vlbascal         -- Valor de Base
                                                 ,pr_vlsldtot => vr_vlsldtot         -- Valor de Saldo Total
                                                 ,pr_vlsldrgt => vr_vlsldrgt         -- Valor de Saldo p/ Resgate
                                                 ,pr_vlultren => vr_vlultren         -- Valor do ultimo rendimento
                                                 ,pr_vlrentot => vr_vlrentot         -- Valor de rendimento total
                                                 ,pr_vlrevers => vr_vlrevers         -- Valor de reversao
                                                 ,pr_vlrdirrf => vr_vlrdirrf         -- Valor de IRRF
                                                 ,pr_percirrf => vr_percirrf         -- Percentual de IRRF
                                                 ,pr_cdcritic => vr_cdcritic         -- Codigo de Critica
                                                 ,pr_dscritic => vr_dscritic);       -- Descricao de Critica
        END IF;

        pr_vlsldtot := NVL(pr_vlsldtot,0) + NVL(vr_vlsldtot,0);
        pr_vlsldrgt := NVL(pr_vlsldrgt,0) + NVL(vr_vlsldrgt,0);

        vr_auxconta := NVL(vr_auxconta,0) + 1;

      END LOOP;

      IF vr_auxconta = 0 THEN
        pr_vlsldtot := 0;
        pr_vlsldrgt := 0;
      END IF;

      -- Verifica se deve gerar log
      IF pr_idgerlog = 1 THEN
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        ROLLBACK;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Verifica se deve gerar log
        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
          COMMIT;
        END IF;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Consulta de Saldo APLI0005.pc_busca_saldo_aplicacoes: ' ||
                       SQLERRM;
        ROLLBACK;
    END;

  END pc_busca_saldo_aplic_prog;

  -- Rotina para consulta de carencias das aplicacoes pelo Ayllos WEB
  PROCEDURE pc_obtem_carencias_web(pr_cdcooper IN craprac.cdcooper%TYPE --> Código da Cooperativa
                                  ,pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN

    /* .............................................................................

     Programa: pc_obtem_carencias_web
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Julho/14.                    Ultima atualizacao: 28/07/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a consulta de carencias de aplicacoes acessados pelo Ayllos WEB.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      --Variáveis locais
      vr_contador PLS_INTEGER := 0;
      vr_auxconta PLS_INTEGER := 0;

      -- Temp Table
      vr_tab_care APLI0005.typ_tab_care;

    BEGIN

      -- Leitura de carencias do produto informado
      APLI0005.pc_obtem_carencias(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                 ,pr_cdprodut => pr_cdprodut   -- Codigo do Produto
                                 ,pr_cdcritic => vr_cdcritic   -- Codigo da Critica
                                 ,pr_dscritic => vr_dscritic   -- Descricao da Critica
                                 ,pr_tab_care => vr_tab_care); -- Tabela com registros de Carencia do produto

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      IF vr_tab_care.count() > 0 THEN
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

        -- Leitura da tabela temporaria para retornar XML para a WEB
        FOR vr_contador IN vr_tab_care.FIRST..vr_tab_care.LAST LOOP

          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'qtdiacar', pr_tag_cont => TO_CHAR(vr_tab_care(vr_contador).qtdiacar), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'qtdiaprz', pr_tag_cont => TO_CHAR(vr_tab_care(vr_contador).qtdiaprz), pr_des_erro => vr_dscritic);

          -- Incrementa contador p/ posicao no XML
          vr_auxconta := vr_auxconta + 1;
        END LOOP;
      ELSE
        vr_dscritic := 'Nao foi encontrada modalidade na política de captacao para o produto selecionado.';
        RAISE vr_exc_saida;
      END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em APLI0005.pc_obtem_carencias_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_obtem_carencias_web;

  -- Rotina para consulta de carencias das aplicacoes pelo Ayllos Caracter
  PROCEDURE pc_obtem_carencias_car(pr_cdcooper IN  craprac.cdcooper%TYPE --> Código da Cooperativa
                                  ,pr_cdprodut IN  crapcpc.cdprodut%TYPE --> Codigo do Produto
                                  ,pr_clobxmlc OUT CLOB                  --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica

  BEGIN

    /* .............................................................................

     Programa: pc_obtem_carencias_car
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Julho/14.                    Ultima atualizacao: 28/07/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a consulta de carencias de aplicacoes.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      --Variáveis locais
      vr_contador PLS_INTEGER := 0;

      -- Temp Table
      vr_tab_care APLI0005.typ_tab_care;

      -- Variaveis de XML
      vr_xml_temp VARCHAR2(32767);

    BEGIN

      -- Leitura de carencias do produto informado
      APLI0005.pc_obtem_carencias(pr_cdcooper => pr_cdcooper   -- Codigo da Cooperativa
                                 ,pr_cdprodut => pr_cdprodut   -- Codigo do Produto
                                 ,pr_cdcritic => vr_cdcritic   -- Codigo da Critica
                                 ,pr_dscritic => vr_dscritic   -- Descricao da Critica
                                 ,pr_tab_care => vr_tab_care); -- Tabela com registros de Carencia do produto

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      IF vr_tab_care.count > 0 THEN

        -- Criar documento XML
        dbms_lob.createtemporary(pr_clobxmlc, TRUE);
        dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);

        -- Insere o cabeçalho do XML
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><raiz>');

        FOR vr_contador IN vr_tab_care.FIRST..vr_tab_care.LAST LOOP

          -- Montar XML com registros de carencia
          gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<carencia>'
                                                    || '<qtdiacar>'||vr_tab_care(vr_contador).qtdiacar||'</qtdiacar>'
                                                    || '<qtdiaprz>'||vr_tab_care(vr_contador).qtdiaprz||'</qtdiaprz>' ||
                                                    '</carencia>');
        END LOOP;

        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</raiz>'
                               ,pr_fecha_xml      => TRUE);

      ELSE
        vr_dscritic := 'Nao foi encontrada modalidade na política de captacao para o produto selecionado.';
        RAISE vr_exc_saida;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        ROLLBACK;

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Consulta de Saldo APLI0005.pc_obtem_carencias_car: ' || SQLERRM;
        ROLLBACK;
    END;

  END pc_obtem_carencias_car;

  -- Rotina geral para consulta de carencias das aplicacoes de novos produtos de captacao
  PROCEDURE pc_obtem_carencias(pr_cdcooper IN craprac.cdcooper%TYPE      --> Código da Cooperativa
                              ,pr_cdprodut IN crapcpc.cdprodut%TYPE      --> Codigo do Produto
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo de Critica
                              ,pr_dscritic OUT crapcri.dscritic%TYPE     --> Descricao de Critica
                              ,pr_tab_care OUT APLI0005.typ_tab_care) IS --> Tabela com dados de carencias
  BEGIN

    /* .............................................................................

     Programa: pc_obtem_carencias
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Julho/14.                    Ultima atualizacao: 30/07/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a consulta de carencias de aplicacoes.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      --Variáveis locais
      vr_ind_care PLS_INTEGER := 0;

      -- Temp Table
      vr_tab_care APLI0005.typ_tab_care;

      -- Selecionar dados de carencia de aplicacao
      CURSOR cr_crapcpc(pr_cdcooper IN craprac.cdcooper%TYPE --> Código da Cooperativa
                       ,pr_cdprodut IN craprac.cdprodut%TYPE --> Codigo do Produto
                       ) IS

      SELECT
        mpc.qtdiacar
       ,mpc.qtdiaprz
      FROM
        crapcpc cpc,
        crapmpc mpc,
        crapdpc dpc
      WHERE
            cpc.cdprodut = pr_cdprodut  -- CODIGO DO PRODUTO
        AND cpc.idsitpro = 1            -- ATIVO
        AND mpc.cdprodut = cpc.cdprodut -- CODIGO DO PRODUTO
        AND dpc.cdcooper = pr_cdcooper  -- CODIGO DA COOPERATIVA
        AND dpc.cdmodali = mpc.cdmodali -- CODIGO DA MODALIDADE
        AND dpc.idsitmod = 1            -- DESBLOQUEADA
      GROUP BY
        mpc.qtdiacar, mpc.qtdiaprz;

      rw_crapcpc cr_crapcpc%ROWTYPE;

    BEGIN

      OPEN cr_crapcpc(pr_cdcooper => pr_cdcooper   --> Código da Cooperativa
                     ,pr_cdprodut => pr_cdprodut); --> Codigo do Produto

      LOOP
        FETCH cr_crapcpc INTO rw_crapcpc;

        EXIT WHEN cr_crapcpc%NOTFOUND;

        -- Buscar qual a quantidade atual de registros no vetor para posicionar na próxima
        vr_ind_care := vr_tab_care.COUNT() + 1;

        -- Criar um registro no vetor de extratos a enviar
        vr_tab_care(vr_ind_care).qtdiacar := rw_crapcpc.qtdiacar;
        vr_tab_care(vr_ind_care).qtdiaprz := rw_crapcpc.qtdiaprz;

      END LOOP;

      CLOSE cr_crapcpc;

      pr_tab_care := vr_tab_care;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Consulta de Saldo APLI0005.pc_obtem_carencias: ' || SQLERRM;
    END;

  END pc_obtem_carencias;

  -- Rotina geral para consulta de taxa de modalidades das aplicacoes
  PROCEDURE pc_obtem_taxa_modalidade(pr_cdcooper IN craprac.cdcooper%TYPE      --> Código da Cooperativa
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE      --> Numero da Conta
                                    ,pr_cdprodut IN crapcpc.cdprodut%TYPE      --> Codigo do Produto
                                    ,pr_vlraplic IN NUMBER                     --> Valor da Aplicacao
                                    ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE      --> Dias de Carencia
                                    ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE      --> Dias de Prazo
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Código da crítica
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE     --> Descrição da crítica
                                    ,pr_tab_taxa OUT APLI0005.typ_tab_taxa) IS --> Tabela com dados de prazos, vencimento e taxas
  BEGIN

    /* .............................................................................

     Programa: pc_obtem_taxa_modalidade
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Julho/14.                    Ultima atualizacao: 02/06/2016

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a consulta de taxas de modalidade de aplicacoes.

     Observacao: -----

     Alteracoes: 02/06/2016 - Ajustado os cursores de leitura da craptab para que seja
                              utilizado o indice da tabela, para otimizar a performace
                              na leitura dos dados (Douglas - Chamado 454248)
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis local
      vr_vlsldacu NUMBER(20,8)  := 0;
      vr_txaplica NUMBER(20,8)  := 0;
      vr_nmprodut VARCHAR2(100) := '';

      vr_percenir NUMBER      := 0;
      vr_qtdfaxir PLS_INTEGER := 0;
      vr_txaplmes CRAPLAP.TXAPLMES%TYPE;

      --Variavel para receber valor data inicio e fim para calculo taxa rdcpos.
      vr_dstextab_rdcpos craptab.dstextab%TYPE;
      vr_dtinitax     DATE;    --> Data de inicio da utilizacao da taxa de poupanca.
      vr_dtfimtax     DATE;    --> Data de fim da utilizacao da taxa de poupanca.

      vr_dtvencim DATE; --> Data de vencimento da aplicacao.
      vr_caraplic DATE; --> Data de carencia da aplicacao.

      ------------------------- ESTRUTURAS DE REGISTRO ---------------------

      -- Temp Table
      vr_tab_taxa APLI0005.typ_tab_taxa;

      -- Variavel usada para montar o indice da tabela de memoria
      vr_index_craplpp VARCHAR2(20);
      vr_index_craplrg VARCHAR2(20);
      vr_index_resgate VARCHAR2(25);

      -- Definicao das tabelas de memoria da apli0001.pc_acumula_aplicacoes
      vr_tab_acumula    APLI0001.typ_tab_acumula_aplic;
      vr_tab_tpregist   APLI0001.typ_tab_tpregist;
      vr_tab_conta_bloq APLI0001.typ_tab_ctablq;
      vr_tab_craplpp    APLI0001.typ_tab_craplpp;
      vr_tab_craplrg    APLI0001.typ_tab_craplpp;
      vr_tab_resgate    APLI0001.typ_tab_resgate;

      -- Erro em chamadas da pc_gera_erro
      vr_des_reto VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;

      -------------------- CURSORES --------------------
      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper
           AND cop.flgativo = 1;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Selecionar dados de carencia de aplicacao
      CURSOR cr_crapmpc(pr_cdcooper IN craprac.cdcooper%TYPE --> Código da Cooperativa
                       ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE --> Dias de Carencia
                       ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE --> Dias de Prazo
                       ,pr_vlsldacu IN NUMBER                --> Saldo Acumulado
                       ,pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
                       ) IS

      SELECT
        cpc.idtxfixa
       ,mpc.cdmodali
       ,mpc.vltxfixa
       ,mpc.vlperren
      FROM
        crapcpc cpc
       ,crapmpc mpc
       ,crapdpc dpc
      WHERE
            cpc.cdprodut  = pr_cdprodut  -- Codigo do Produto
        AND mpc.qtdiacar  = pr_qtdiacar  -- Quantidade de dias de carencia
        AND mpc.qtdiaprz  = pr_qtdiaprz  -- Quantidade de dias de prazo
        AND mpc.vlrfaixa <= pr_vlsldacu  -- Saldo Acumulado
        AND cpc.cdprodut  = mpc.cdprodut -- Codigo do Produto
        AND cpc.idsitpro  = 1            -- Ativo
        AND dpc.cdmodali  = mpc.cdmodali -- Codigo da Modalidade
        AND dpc.cdcooper  = pr_cdcooper  -- Codigo da Cooperatica
        AND dpc.idsitmod  = 1            -- Desbloqueada
      ORDER BY mpc.vlrfaixa DESC;

      rw_crapmpc cr_crapmpc%ROWTYPE;

      -- Consulta de produtos
      CURSOR cr_crapcpc(pr_cdprodut IN crapcpc.cdprodut%TYPE) IS

      SELECT
        cpc.idacumul
       ,cpc.nmprodut
      FROM
        crapcpc cpc
      WHERE
        cpc.cdprodut = pr_cdprodut;

      rw_crapcpc cr_crapcpc%ROWTYPE;

      CURSOR cr_crapnpc(pr_cdprodut IN crapnpc.cdprodut%TYPE
                       ,pr_qtdiacar IN crapnpc.qtmincar%TYPE
                       ,pr_vlsldacu IN crapnpc.vlminapl%TYPE) IS
      SELECT
        npc.cdnomenc
       ,npc.dsnomenc
      FROM
        crapnpc npc
      WHERE
            npc.cdprodut  = pr_cdprodut
        AND npc.qtmincar <= pr_qtdiacar
        AND npc.qtmaxcar >= pr_qtdiacar
        AND npc.vlminapl <= pr_vlsldacu
        AND npc.vlmaxapl >= pr_vlsldacu
        AND npc.idsitnom  = 1;

      rw_crapnpc cr_crapnpc%ROWTYPE;

      -- Consulta referente a dados do cooperado
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT
        ass.nrdconta
       ,ass.cdagenci
      FROM
        crapass ass
      WHERE
            ass.cdcooper = pr_cdcooper
        AND ass.nrdconta = pr_nrdconta;

      rw_crapass cr_crapass%ROWTYPE;

      -- Selecionar quantidade de saques em poupanca nos ultimos 6 meses
      CURSOR cr_craplpp (pr_cdcooper IN craplpp.cdcooper%TYPE
                        ,pr_nrdconta IN craplpp.nrdconta%TYPE
                        ,pr_dtmvtolt IN craplpp.dtmvtolt%TYPE) IS
      SELECT lpp.nrdconta
            ,lpp.nrctrrpp
            ,Count(*) qtlancmto
        FROM craplpp lpp
       WHERE lpp.cdcooper = pr_cdcooper
         AND lpp.nrdconta = pr_nrdconta
         AND lpp.cdhistor IN (158,496)
         AND lpp.dtmvtolt > pr_dtmvtolt
         GROUP BY lpp.nrdconta
                 ,lpp.nrctrrpp;

      rw_craplpp cr_craplpp%ROWTYPE;

      -- Contar a quantidade de resgates das contas
      CURSOR cr_craplrg_saque (pr_cdcooper IN craplrg.cdcooper%TYPE
                              ,pr_nrdconta IN craplrg.nrdconta%TYPE) IS
        SELECT craplrg.nrdconta
              ,craplrg.nraplica
              ,Count(*) qtlancmto
          FROM craplrg craplrg
         WHERE craplrg.cdcooper = pr_cdcooper
           AND craplrg.nrdconta = pr_nrdconta
           AND craplrg.tpaplica = 4
           AND craplrg.inresgat = 0
         GROUP BY craplrg.nrdconta
                 ,craplrg.nraplica;

      --Selecionar informacoes dos lancamentos de resgate
      CURSOR cr_craplrg (pr_cdcooper IN craplrg.cdcooper%TYPE
                        ,pr_nrdconta IN craplrg.nrdconta%TYPE
                        ,pr_dtresgat IN craplrg.dtresgat%TYPE) IS
        SELECT craplrg.nrdconta
              ,craplrg.nraplica
              ,craplrg.tpaplica
              ,craplrg.tpresgat
              ,Nvl(Sum(Nvl(craplrg.vllanmto,0)),0) vllanmto
          FROM craplrg craplrg
         WHERE craplrg.cdcooper  = pr_cdcooper
           AND craplrg.nrdconta  = pr_nrdconta
           AND craplrg.dtresgat <= pr_dtresgat
           AND craplrg.inresgat  = 0
           AND craplrg.tpresgat IN(1,2)
         GROUP BY craplrg.nrdconta
                 ,craplrg.nraplica
                 ,craplrg.tpaplica
                 ,craplrg.tpresgat;

    BEGIN

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      OPEN cr_crapcpc(pr_cdprodut => pr_cdprodut);

      FETCH cr_crapcpc INTO rw_crapcpc;

      IF cr_crapcpc%NOTFOUND THEN
        CLOSE cr_crapcpc;
        vr_dscritic := 'Produto Inexistente';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapcpc;
        vr_nmprodut := rw_crapcpc.nmprodut;
      END IF;

      IF rw_crapcpc.idacumul = 1 THEN

        -- Selecionar informacoes % IR para o calculo
        vr_percenir := GENE0002.fn_char_para_number(TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                                              ,pr_nmsistem => 'CRED'
                                                                              ,pr_tptabela => 'CONFIG'
                                                                              ,pr_cdempres => 0
                                                                              ,pr_cdacesso => 'PERCIRAPLI'
                                                                              ,pr_tpregist => 0));

        -- Verificar as faixas de IR
        APLI0001.pc_busca_faixa_ir_rdca(pr_cdcooper => pr_cdcooper);
        -- Buscar a quantidade de faixas de ir
        vr_qtdfaxir := APLI0001.vr_faixa_ir_rdca.Count;

        -- Carregar tabela de memoria de taxas
        -- Selecionar os tipos de registro da tabela generica
        FOR rw_craptab IN cr_craptab_taxas(pr_cdcooper => pr_cdcooper
                                          ,pr_nmsistem => 'CRED'
                                          ,pr_tptabela => 'GENERI'
                                          ,pr_cdempres => 0
                                          ,pr_cdacesso => 'SOMAPLTAXA'
                                          ,pr_dstextab => 'SIM') LOOP
          -- Atribuir valor para tabela memoria
          vr_tab_tpregist(rw_craptab.tpregist) := rw_craptab.tpregist;
        END LOOP;

        -- Carregar tabela de memoria de contas bloqueadas
        TABE0001.pc_carrega_ctablq(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_tab_cta_bloq => vr_tab_conta_bloq);

        -- Carregar tabela de memoria de lancamentos na poupanca
        FOR rw_craplpp IN cr_craplpp (pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt - 180) LOOP

          IF   rw_craplpp.qtlancmto > 3 THEN
            -- Montar indice para acessar tabela
            vr_index_craplpp := LPad(rw_craplpp.nrdconta,10,'0')||LPad(rw_craplpp.nrctrrpp,10,'0');

            -- Atribuir quantidade encontrada de cada conta ao vetor
            vr_tab_craplpp(vr_index_craplpp) := rw_craplpp.qtlancmto;
          END IF;
        END LOOP;


        -- Carregar tabela de memoria com total de resgates na poupanca
        FOR rw_craplrg IN cr_craplrg_saque (pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta) LOOP
          -- Montar Indice para acesso quantidade lancamentos de resgate
          vr_index_craplrg := LPad(rw_craplrg.nrdconta,10,'0')||LPad(rw_craplrg.nraplica,10,'0');
          -- Popular tabela de memoria
          vr_tab_craplrg(vr_index_craplrg) := rw_craplrg.qtlancmto;
        END LOOP;


        -- Carregar tabela de memória com total resgatado por conta e aplicacao
        FOR rw_craplrg IN cr_craplrg (pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_dtresgat => rw_crapdat.dtmvtopr) LOOP
          -- Montar indice para selecionar total dos resgates na tabela auxiliar
          vr_index_resgate := LPad(rw_craplrg.nrdconta,10,'0')||
                              LPad(rw_craplrg.tpaplica,05,'0')||
                              LPad(rw_craplrg.nraplica,10,'0');
          -- Popular a tabela de memoria com a soma dos lancamentos de resgate
          vr_tab_resgate(vr_index_resgate).tpresgat := rw_craplrg.tpresgat;
          vr_tab_resgate(vr_index_resgate).vllanmto := rw_craplrg.vllanmto;
        END LOOP;

        OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);

        FETCH cr_crapass INTO rw_crapass;

        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          vr_dscritic := 'Cooperado Inexistente.';
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_crapass;
        END IF;

        --Selecionar informacoes da data de inicio e fim da taxa para calculo da APLI0001.pc_provisao_rdc_pos
        vr_dstextab_rdcpos:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                       ,pr_nmsistem => 'CRED'
                                                       ,pr_tptabela => 'USUARI'
                                                       ,pr_cdempres => 11
                                                       ,pr_cdacesso => 'MXRENDIPOS'
                                                       ,pr_tpregist => 1);
        -- Se não encontrar
        IF vr_dstextab_rdcpos IS NULL THEN
          -- Utilizar datas padrão
          vr_dtinitax := to_date('01/01/9999','dd/mm/yyyy');
          vr_dtfimtax := to_date('01/01/9999','dd/mm/yyyy');
        ELSE
          --Atribuir as datas encontradas
          vr_dtinitax := to_date(gene0002.fn_busca_entrada(1, vr_dstextab_rdcpos, ';'), 'DD/MM/RRRR');
          vr_dtfimtax := to_date(gene0002.fn_busca_entrada(2, vr_dstextab_rdcpos, ';'), 'DD/MM/RRRR');
        END IF;

        --Executar rotina para acumular aplicacoes
        APLI0001.pc_acumula_aplicacoes (pr_cdcooper        => pr_cdcooper             --> Cooperativa
                                       ,pr_cdprogra        => 'ATENDA'                --> Nome do programa chamador
                                       ,pr_nrdconta        => rw_crapass.nrdconta     --> Nro da conta da aplicação RDCA
                                       ,pr_nraplica        => 0                       --> Nro da Aplicacao (0=todas)
                                       ,pr_tpaplica        => 0                       --> Tipo de Aplicacao
                                       ,pr_vlaplica        => 0                       --> Valor da Aplicacao
                                       ,pr_cdperapl        => 0                       --> Codigo Periodo Aplicacao
                                       ,pr_percenir        => vr_percenir             --> % IR para Calculo Poupanca
                                       ,pr_qtdfaxir        => vr_qtdfaxir             --> Quantidade de faixas de IR
                                       ,pr_tab_tpregist    => vr_tab_tpregist         --> Tipo de Registro para loop craptab (performance)
                                       ,pr_tab_craptab     => vr_tab_conta_bloq       --> Tipo de tabela de Conta Bloqueada (performance)
                                       ,pr_tab_craplpp     => vr_tab_craplpp          --> Tipo de tabela com lancamento poupanca (performance)
                                       ,pr_tab_craplrg     => vr_tab_craplrg          --> Tipo de tabela com resgates (performance)
                                       ,pr_tab_resgate     => vr_tab_resgate          --> Tabela com a soma dos resgates por conta e aplicacao
                                       ,pr_tab_crapdat     => rw_crapdat              --> Dados da tabela de datas
                                       ,pr_cdagenci_assoc  => rw_crapass.cdagenci     --> Agencia do associado
                                       ,pr_nrdconta_assoc  => rw_crapass.nrdconta     --> Conta do associado
                                       ,pr_dtinitax        => vr_dtinitax             --> Data Inicial da Utilizacao da taxa da poupanca
                                       ,pr_dtfimtax        => vr_dtfimtax             --> Data Final da Utilizacao da taxa da poupanca
                                       ,pr_vlsdrdca        => vr_vlsldacu             --> Valor Saldo Aplicacao (OUT)
                                       ,pr_txaplica        => vr_txaplica             --> Taxa Maxima de Aplicacao (OUT)
                                       ,pr_txaplmes        => vr_txaplmes             --> Taxa Minima de Aplicacao (OUT)
                                       ,pr_retorno         => vr_des_reto             --> Descricao de erro ou sucesso OK/NOK
                                       ,pr_tab_acumula     => vr_tab_acumula          --> Aplicacoes do Associado
                                       ,pr_tab_erro        => vr_tab_erro);

        IF vr_des_reto = 'NOK' THEN
          -- Tenta buscar o erro no vetor de erro
          IF vr_tab_erro.COUNT > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic || ' Conta: '||rw_crapass.nrdconta;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Retorno "NOK" na APLI0005.pc_obtem_taxa_modalidade e sem informacao na pr_tab_erro, Conta: '||pr_nrdconta||' Aplica: 0.';
          END IF;
          -- Levantar Excecao
          RAISE vr_exc_saida;
        END IF;

      END IF;

      vr_vlsldacu := NVL(vr_vlsldacu,0) + NVL(pr_vlraplic,0);

      -- Consulta taxa
      OPEN cr_crapmpc(pr_cdcooper => pr_cdcooper   --> Código da Cooperativa
                     ,pr_qtdiacar => pr_qtdiacar   --> Dias de Carencia
                     ,pr_qtdiaprz => pr_qtdiaprz   --> Dias de Prazo
                     ,pr_vlsldacu => vr_vlsldacu   --> Saldo Acumulado
                     ,pr_cdprodut => pr_cdprodut); --> Codigo do Produto

      FETCH cr_crapmpc INTO rw_crapmpc;

      IF cr_crapmpc%NOTFOUND THEN
        CLOSE cr_crapmpc;
        vr_dscritic := 'Nao foi encontrada modalidade na politica de captacao para o valor informado.';
        RAISE vr_exc_saida;
      ELSE
        -- O primeiro registro deve ser utilizado
        IF rw_crapmpc.idtxfixa = 1 THEN -- Utiliza Taxa Fixa
           vr_txaplica := rw_crapmpc.vltxfixa;
        ELSE
           vr_txaplica := rw_crapmpc.vlperren;
        END IF;

        -- Consulta Nome Comercial
        OPEN cr_crapnpc(pr_cdprodut => pr_cdprodut
                       ,pr_qtdiacar => pr_qtdiacar
                       ,pr_vlsldacu => vr_vlsldacu);

        FETCH cr_crapnpc INTO rw_crapnpc;

        IF cr_crapnpc%NOTFOUND THEN
          CLOSE cr_crapnpc;
        ELSE
          CLOSE cr_crapnpc;
          vr_nmprodut := rw_crapnpc.dsnomenc;
        END IF;

      END IF;

      -- Calcula data de vencimento da aplicacao.
      vr_dtvencim := rw_crapdat.dtmvtolt + pr_qtdiaprz;

      -- Calcula data de carencia da aplicacao;
      vr_caraplic := rw_crapdat.dtmvtolt + pr_qtdiacar;

      -- Criar um registro no vetor de extratos a enviar
      vr_tab_taxa(1).txaplica := vr_txaplica;
      vr_tab_taxa(1).nmprodut := vr_nmprodut;
      vr_tab_taxa(1).dtvencim := vr_dtvencim;
      vr_tab_taxa(1).caraplic := vr_caraplic;
      vr_tab_taxa(1).qtdiaapl := vr_dtvencim - rw_crapdat.dtmvtolt;
      pr_tab_taxa := vr_tab_taxa;

      COMMIT;

    EXCEPTION

      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        ROLLBACK;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Consulta de Carencias APLI0005.pc_obtem_carencias: ' ||
                       SQLERRM;
        ROLLBACK;
    END;

  END pc_obtem_taxa_modalidade;

  -- Rotina geral para consulta de taxa de modalidades das aplicacoes do caracater
  PROCEDURE pc_obtem_taxa_modalidade_car(pr_cdcooper IN craprac.cdcooper%TYPE      --> Código da Cooperativa
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE      --> Numero da Conta
                                        ,pr_cdprodut IN crapcpc.cdprodut%TYPE      --> Codigo do Produto
                                        ,pr_vlraplic IN NUMBER                     --> Valor da Aplicacao
                                        ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE      --> Dias de Carencia
                                        ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE      --> Dias de Prazo
                                        ,pr_txaplica OUT NUMBER                    --> Valor de taxa da aplicacao
                                        ,pr_nmprodut OUT crapcpc.nmprodut%TYPE     --> Nome do Produto
                                        ,pr_dtvencim OUT DATE                      --> Data de vencimento aplicacao
                                        ,pr_caraplic OUT DATE                      --> Data de Carencia Aplicacao
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Código da crítica
                                        ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descrição da crítica
  BEGIN

    /* .............................................................................

     Programa: pc_obtem_taxa_modalidade_car
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Julho/14.                    Ultima atualizacao: 01/08/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a consulta de taxas de modalidade de aplicacoes atraves do caracter.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Temp Table
      vr_tab_taxa APLI0005.typ_tab_taxa;

    BEGIN
      -- Leitura de carencias do produto informado
      APLI0005.pc_obtem_taxa_modalidade(pr_cdcooper => pr_cdcooper   --> Código da Cooperativa
                                       ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                                       ,pr_cdprodut => pr_cdprodut   --> Codigo do Produto
                                       ,pr_vlraplic => pr_vlraplic   --> Valor da Aplicacao
                                       ,pr_qtdiacar => pr_qtdiacar   --> Dias de Carencia
                                       ,pr_qtdiaprz => pr_qtdiaprz   --> Dias de Prazo
                                       ,pr_cdcritic => vr_cdcritic   --> Codigo da Critica
                                       ,pr_dscritic => vr_dscritic   --> Descricao da Critica
                                       ,pr_tab_taxa => vr_tab_taxa); --> Tabela com dados de taxas, prazo e carencia

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Consulta Temp-Table para variaveis de retorno
      pr_txaplica := vr_tab_taxa(1).txaplica;
      pr_nmprodut := vr_tab_taxa(1).nmprodut;
      pr_dtvencim := vr_tab_taxa(1).dtvencim;
      pr_caraplic := vr_tab_taxa(1).caraplic;
      -- pr_qtdiaapl := vr_tab_taxa(1).qtdiaapl;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        ROLLBACK;

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Consulta de Taxa de Modalidade APLI0005.pc_obtem_taxa_modalidade_car: ' || SQLERRM;
        ROLLBACK;
    END;

  END pc_obtem_taxa_modalidade_car;

  -- Rotina geral para consulta de taxa de modalidades das aplicacoes da web
  PROCEDURE pc_obtem_taxa_modalidade_web(pr_cdcooper IN craprac.cdcooper%TYPE  --> Código da Cooperativa
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da Conta
                                        ,pr_cdprodut IN crapcpc.cdprodut%TYPE  --> Codigo do Produto
                                        ,pr_vlraplic IN NUMBER                 --> Valor da Aplicacao
                                        ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE  --> Dias de Carencia
                                        ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE  --> Dias de Prazo
                                        ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da Critica
                                        ,pr_dscritic OUT crapcri.dscritic%TYPE --> Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN

    /* .............................................................................

     Programa: pc_obtem_taxa_modalidade_web
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Julho/14.                    Ultima atualizacao: 01/08/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a consulta de taxas de modalidade de aplicacoes atraves da web.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      --Variáveis locais
      vr_contador PLS_INTEGER := 0;
      vr_auxconta PLS_INTEGER := 0;

      -- Temp Table
      vr_tab_taxa APLI0005.typ_tab_taxa;

    BEGIN

      -- Leitura de carencias do produto informado
      APLI0005.pc_obtem_taxa_modalidade(pr_cdcooper => pr_cdcooper   --> Código da Cooperativa
                                       ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                                       ,pr_cdprodut => pr_cdprodut   --> Codigo do Produto
                                       ,pr_vlraplic => pr_vlraplic   --> Valor da Aplicacao
                                       ,pr_qtdiacar => pr_qtdiacar   --> Dias de Carencia
                                       ,pr_qtdiaprz => pr_qtdiaprz   --> Dias de Prazo
                                       ,pr_cdcritic => vr_cdcritic   --> Codigo da Critica
                                       ,pr_dscritic => vr_dscritic   --> Descricao da Critica
                                       ,pr_tab_taxa => vr_tab_taxa); --> Tabela com dados de taxas, prazo e carencia

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      -- Leitura da tabela temporaria para retornar XML para a WEB
      FOR vr_contador IN vr_tab_taxa.FIRST..vr_tab_taxa.LAST LOOP

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'txaplica', pr_tag_cont => TO_CHAR(vr_tab_taxa(vr_contador).txaplica), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmprodut', pr_tag_cont => TO_CHAR(vr_tab_taxa(vr_contador).nmprodut), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtvencim', pr_tag_cont => TO_CHAR(vr_tab_taxa(vr_contador).dtvencim,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'caraplic', pr_tag_cont => TO_CHAR(vr_tab_taxa(vr_contador).caraplic,'dd/mm/yyyy'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'qtdiaapl', pr_tag_cont => TO_CHAR(vr_tab_taxa(vr_contador).qtdiaapl), pr_des_erro => vr_dscritic);

        -- Incrementa contador p/ posicao no XML
        vr_auxconta := vr_auxconta + 1;

      END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em APLI0005.pc_obtem_taxa_modalidade_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_obtem_taxa_modalidade_web;

  -- Rotina geral para consulta de taxa de modalidades das aplicacoes - Com Autonomous Transactions
  PROCEDURE pc_obtem_taxa_modalidade_at(pr_cdcooper IN craprac.cdcooper%TYPE      --> Código da Cooperativa
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE      --> Numero da Conta
                                    ,pr_cdprodut IN crapcpc.cdprodut%TYPE      --> Codigo do Produto
                                    ,pr_vlraplic IN NUMBER                     --> Valor da Aplicacao
                                    ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE      --> Dias de Carencia
                                    ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE      --> Dias de Prazo
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Código da crítica
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE     --> Descrição da crítica
                                    ,pr_tab_taxa OUT APLI0005.typ_tab_taxa) IS --> Tabela com dados de prazos, vencimento e taxas
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN

    /* .............................................................................

     Programa: pc_obtem_taxa_modalidade_at
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : CIS Corporate
     Data    : Julho/18.                    Ultima atualizacao: 21/07/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a consulta de taxas de modalidade de aplicacoes, com Autonomous Transactions

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/

    BEGIN

      -- Leitura de carencias do produto informado
      APLI0005.pc_obtem_taxa_modalidade(pr_cdcooper => pr_cdcooper   --> Código da Cooperativa
                                       ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                                       ,pr_cdprodut => pr_cdprodut   --> Codigo do Produto
                                       ,pr_vlraplic => pr_vlraplic   --> Valor da Aplicacao
                                       ,pr_qtdiacar => pr_qtdiacar   --> Dias de Carencia
                                       ,pr_qtdiaprz => pr_qtdiaprz   --> Dias de Prazo
                                       ,pr_cdcritic => pr_cdcritic   --> Codigo da Critica
                                       ,pr_dscritic => pr_dscritic   --> Descricao da Critica
                                       ,pr_tab_taxa => pr_tab_taxa); --> Tabela com dados de taxas, prazo e carencia


    END;

  END pc_obtem_taxa_modalidade_at;

  -- Rotina geral para validacao de cadastros de aplicacoes
  PROCEDURE pc_valida_cad_aplic(pr_cdcooper IN craprac.cdcooper%TYPE      --> Código da Cooperativa
                               ,pr_cdoperad IN crapope.cdoperad%TYPE      --> Código do Operador
                               ,pr_nmdatela IN craptel.nmdatela%TYPE      --> Nome da Tela
                               ,pr_idorigem IN INTEGER                    --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                               ,pr_nrdconta IN craprac.nrdconta%TYPE      --> Número da Conta
                               ,pr_idseqttl IN crapttl.idseqttl%TYPE      --> Titular da Conta
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE      --> Data de Movimento
                               ,pr_cdprodut IN crapcpc.cdprodut%TYPE      --> Código do Produto
                               ,pr_qtdiaapl IN INTEGER                    --> Dias da Aplicação
                               ,pr_dtvencto IN DATE                       --> Data de Vencimento da Aplicação
                               ,pr_qtdiacar IN INTEGER                    --> Carência da Aplicação
                               ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE      --> Prazo da Aplicação (Prazo selecionado na tela)
                               ,pr_vlaplica IN NUMBER                     --> Valor da Aplicação (Valor informado em tela)
                               ,pr_iddebcti IN INTEGER                    --> Identificador de Débito na Conta Investimento (Identificador informado em tela)
                               ,pr_idorirec IN INTEGER                    --> Identificador de Origem do Recurso (Identificador informado em tela)
                               ,pr_idgerlog IN INTEGER                    --> Identificador de Log (Fixo no código, 0 – Não / 1 - Sim)
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Código da crítica
                               ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descrição da crítica
  BEGIN

    /* .............................................................................

     Programa: pc_valida_cad_aplic
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Agosto/14.                    Ultima atualizacao: 02/06/2016

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a validacao de informacoes do cadastro de aplicacoes.

     Observacao: -----

     Alteracoes: 02/06/2016 - Ajustado os cursores de leitura da craptab para que seja
                              utilizado o indice da tabela, para otimizar a performace
                              na leitura dos dados (Douglas - Chamado 454248)
    ..............................................................................*/

    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; -- Codigo da critica
      vr_dscritic crapcri.dscritic%TYPE; -- Descricao da critica

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis locais
      vr_vlsldacu NUMBER(20,8) := 0; -- Valor de saldo acumulado
      vr_nrdrowid ROWID;        -- ROWID de retorno do log
      vr_txaplica craplap.txaplica%TYPE; -- Taxa Maxima de Aplicacao
      vr_txaplmes craplap.txaplmes%TYPE; -- Taxa Minima de Aplicacao
      vr_retorno  VARCHAR2(50);          -- Descricao de erro ou sucesso

      -- Variavel usada para montar o indice da tabela de memoria
      vr_index_craplpp VARCHAR2(20);
      vr_index_craplrg VARCHAR2(20);
      vr_index_resgate VARCHAR2(25);

      --Variavel para receber valor data inicio e fim para calculo taxa rdcpos.
      vr_dstextab_rdcpos craptab.dstextab%TYPE;
      vr_dtinitax     DATE;    --> Data de inicio da utilizacao da taxa de poupanca.
      vr_dtfimtax     DATE;    --> Data de fim da utilizacao da taxa de poupanca.

      -- Erro em chamadas da pc_gera_erro
      vr_des_reto VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;
      vr_tab_sald EXTR0001.typ_tab_saldos;

      vr_tab_acumula    APLI0001.typ_tab_acumula_aplic;
      vr_tab_tpregist   APLI0001.typ_tab_tpregist;
      vr_tab_conta_bloq APLI0001.typ_tab_ctablq;
      vr_tab_craplpp    APLI0001.typ_tab_craplpp;
      vr_tab_craplrg    APLI0001.typ_tab_craplpp;
      vr_tab_resgate    APLI0001.typ_tab_resgate;

      vr_percenir NUMBER      := 0;
      vr_qtdfaxir PLS_INTEGER := 0;
      vr_dsorigem VARCHAR2(500) := 'AIMARO,CAIXA,INTERNET,TAA,AIMARO WEB,URA';

      -------------------- CURSORES --------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper
           AND cop.flgativo = 1;

      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Busca dos dados da cooperativa
      CURSOR cr_crapass (pr_cdcooper crapcop.cdcooper%TYPE
                        ,pr_nrdconta crapass.nrdconta%TYPE)IS
        SELECT ass.cdsitdtl
              ,ass.dtelimin
              ,ass.vllimcre
              ,ass.cdagenci
              ,ass.nrdconta
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;

      rw_crapass cr_crapass%ROWTYPE;

      -- Busca dos dados de produtos
      CURSOR cr_crapcpc(pr_cdprodut crapcpc.cdprodut%TYPE)IS
        SELECT cpc.idacumul
              ,cpc.idsitpro
              ,cpc.idtippro
              ,cpc.idtxfixa
          FROM crapcpc cpc
         WHERE cpc.cdprodut = pr_cdprodut;

      rw_crapcpc cr_crapcpc%ROWTYPE;

      -- Consulta de modalidade de produto
      CURSOR cr_crapmpc(pr_qtdiacar IN crapmpc.qtdiacar%TYPE --> Dias de Carencia
                       ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE --> Dias de Prazo
                       ,pr_vlsldacu IN NUMBER                --> Saldo Acumulado
                       ,pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
                       ) IS
        SELECT
          mpc.cdmodali
         ,mpc.vltxfixa
         ,mpc.vlperren
         ,dpc.idsitmod
        FROM
          crapmpc mpc
         ,crapdpc dpc
        WHERE
              mpc.cdprodut  = pr_cdprodut -- Codigo do produto
          AND mpc.qtdiacar  = pr_qtdiacar -- Quantidade de dias de carencia
          AND mpc.qtdiaprz  = pr_qtdiaprz -- Quantidade de dias de prazo
          AND mpc.vlrfaixa <= pr_vlsldacu -- Saldo Acumulado
          AND dpc.cdmodali  = mpc.cdmodali -- Codigo da Modalidade
          AND dpc.cdcooper  = pr_cdcooper  -- Codigo da Cooperatica
        ORDER BY
          mpc.vlrfaixa DESC;

      rw_crapmpc cr_crapmpc%ROWTYPE;

      CURSOR cr_crapmpc_cont(pr_qtdiacar IN crapmpc.qtdiacar%TYPE --> Dias de Carencia
                            ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE --> Dias de Prazo
                            ,pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
                            ) IS
        SELECT COUNT(1) cont
          FROM crapmpc mpc
              ,crapdpc dpc
        WHERE mpc.cdprodut  = pr_cdprodut -- Codigo do produto
          AND mpc.qtdiacar  = pr_qtdiacar -- Quantidade de dias de carencia
          AND mpc.qtdiaprz  = pr_qtdiaprz -- Quantidade de dias de prazo
          AND dpc.cdmodali  = mpc.cdmodali -- Codigo da Modalidade
          AND dpc.cdcooper  = pr_cdcooper  -- Codigo da Cooperatica
          AND dpc.idsitmod  = 1;
      
      rw_crapmpc_cont cr_crapmpc_cont%ROWTYPE;

      -- Consulta saldo de conta investimento
      CURSOR cr_crapsli(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_nrdconta crapsli.nrdconta%TYPE
                       ,pr_dtrefere crapsli.dtrefere%TYPE) IS

        SELECT
          sli.vlsddisp
        FROM
          crapsli sli
        WHERE
              sli.cdcooper = pr_cdcooper  -- Codigo da cooperativa
          AND sli.nrdconta = pr_nrdconta  -- Numero da conta
          AND sli.dtrefere = pr_dtrefere; -- Deve ser o último dia do mês

      rw_crapsli cr_crapsli%ROWTYPE;

      -- Selecionar quantidade de saques em poupanca nos ultimos 6 meses
      CURSOR cr_craplpp (pr_cdcooper IN craplpp.cdcooper%TYPE
                        ,pr_nrdconta IN craplpp.nrdconta%TYPE
                        ,pr_dtmvtolt IN craplpp.dtmvtolt%TYPE) IS
      SELECT lpp.nrdconta
            ,lpp.nrctrrpp
            ,Count(*) qtlancmto
        FROM craplpp lpp
       WHERE lpp.cdcooper = pr_cdcooper
         AND lpp.nrdconta = pr_nrdconta
         AND lpp.cdhistor IN (158,496)
         AND lpp.dtmvtolt > pr_dtmvtolt
         GROUP BY lpp.nrdconta
                 ,lpp.nrctrrpp;

      rw_craplpp cr_craplpp%ROWTYPE;

      -- Contar a quantidade de resgates das contas
      CURSOR cr_craplrg_saque (pr_cdcooper IN craplrg.cdcooper%TYPE
                              ,pr_nrdconta IN craplrg.nrdconta%TYPE) IS
        SELECT craplrg.nrdconta
              ,craplrg.nraplica
              ,Count(*) qtlancmto
          FROM craplrg craplrg
         WHERE craplrg.cdcooper = pr_cdcooper
           AND craplrg.nrdconta = pr_nrdconta
           AND craplrg.tpaplica = 4
           AND craplrg.inresgat = 0
         GROUP BY craplrg.nrdconta
                 ,craplrg.nraplica;

      --Selecionar informacoes dos lancamentos de resgate
      CURSOR cr_craplrg (pr_cdcooper IN craplrg.cdcooper%TYPE
                        ,pr_nrdconta IN craplrg.nrdconta%TYPE
                        ,pr_dtresgat IN craplrg.dtresgat%TYPE) IS
        SELECT craplrg.nrdconta
              ,craplrg.nraplica
              ,craplrg.tpaplica
              ,craplrg.tpresgat
              ,Nvl(Sum(Nvl(craplrg.vllanmto,0)),0) vllanmto
          FROM craplrg craplrg
         WHERE craplrg.cdcooper  = pr_cdcooper
           AND craplrg.nrdconta  = pr_nrdconta
           AND craplrg.dtresgat <= pr_dtresgat
           AND craplrg.inresgat  = 0
           AND craplrg.tpresgat IN(1,2)
         GROUP BY craplrg.nrdconta
                 ,craplrg.nraplica
                 ,craplrg.tpaplica
                 ,craplrg.tpresgat;
    BEGIN

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- As validacoes da situacao da conta, demissao e dos parametros
      -- foram movidos para ca, a fim de reduzir leituras desnecessarias
      -- nas tabelas do sistema, sendo que essas validacoes para o impedem
      -- a validacao inclusao da aplicacao

      -- Verifica prazo informado
      IF pr_qtdiaprz = 0 OR pr_qtdiaprz IS NULL THEN
        vr_dscritic := 'Prazo deve ser informado ou maior que zero.';
        RAISE vr_exc_saida;
      END IF;

      -- Verifica quantidade de dias de aplicacao
      IF pr_qtdiaapl = 0 OR pr_qtdiaapl IS NULL THEN
        vr_dscritic := 'Prazo deve ser informado ou maior que zero.';
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se data de vencimento e nula
      IF pr_dtvencto IS NULL THEN
        vr_dscritic := 'Data de vencimento devera ser informada.';
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se data de vencimento e menor ou igual a data de movimento
      IF pr_dtvencto <= pr_dtmvtolt THEN
        vr_dscritic := 'Data de vencimento devera ser maior que data atual.';
        RAISE vr_exc_saida;
      END IF;

      -- Verifica qtd de dias de aplicacao e prazo
      IF pr_qtdiaapl > pr_qtdiaprz THEN
        vr_dscritic := 'Quantidade de dias da aplicacao nao deve ser maior que o prazo da modalidade.';
        RAISE vr_exc_saida;
      END IF;

      -- Verifica qtd de dias de aplicacao e carencia
      IF pr_qtdiaapl < pr_qtdiacar THEN
        vr_dscritic := 'Quantidade de dias da aplicacao nao deve ser menor que a carencia.';
        RAISE vr_exc_saida;
      END IF;

      -- Pelo batch não deve validar o valor mínimo - tem apliacacao programada com valor de parcela menor que 5 reais.
      IF upper(pr_nmdatela) <> 'CRPS145' THEN
      -- Verifica valor de aplicacao
      IF pr_vlaplica < 5 THEN
        vr_dscritic := 'Valor da aplicacao nao pode ser menor que R$ 5,00.';
        RAISE vr_exc_saida;
      END IF;
      END IF;

      -- Verifica identificador de debito em conta investimento
      IF pr_iddebcti NOT IN(0,1) THEN
        vr_dscritic := 'Identificador de debito em conta investimento invalido.';
        RAISE vr_exc_saida;
      END IF;

      -- Verifica identificador de origem de recurso
      IF pr_idorirec NOT IN(0,1) THEN
        vr_dscritic := 'Identificador de origem de recurso invalido.';
        RAISE vr_exc_saida;
      END IF;

      -- Buscar Conta do Cooperado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);

      FETCH cr_crapass INTO rw_crapass;

      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_dscritic := 'Cooperado Inexistente.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapass;
      END IF;

      -- Verifica se a conta está em prejuizo
      IF rw_crapass.cdsitdtl IN(5, 6, 7, 8) THEN
        vr_cdcritic := 695;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      END IF;

      -- Pelo batch não deve validar titular bloqueado, conforme produto antigo.
      IF upper(pr_nmdatela) <> 'CRPS145' THEN
      -- Verifica se conta esta bloqueada
      IF rw_crapass.cdsitdtl IN(2, 4, 6, 8) THEN
        vr_cdcritic := 95;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      END IF;
	  END IF;

      -- Verifica se cooperado esta eliminado
      IF rw_crapass.dtelimin IS NOT NULL THEN
        vr_cdcritic := 410;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      END IF;

      -- Consulta dados de produtos
      OPEN cr_crapcpc(pr_cdprodut => pr_cdprodut);
      FETCH cr_crapcpc INTO rw_crapcpc;

      -- Verifica se encontrou produtos
      IF cr_crapcpc%NOTFOUND THEN
        CLOSE cr_crapcpc;
        vr_dscritic := 'Produto inexistente.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapcpc;
      END IF;

      -- Verifica se produto esta bloqueado
      IF rw_crapcpc.idsitpro = 2 THEN
        vr_dscritic := 'Produto bloqueado.';
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se produto e pos-fixado e carencia igual a 0
      IF rw_crapcpc.idtippro = 2 AND pr_qtdiacar = 0 THEN
        vr_dscritic := 'Nao e permitido carencia igual a zero para produtos pos-fixado.';
        RAISE vr_exc_saida;
      END IF;

      /* Vamos verificar se existe mais opcoes de modalidades disponiveis,
         caso soh tenha 1, nao precisamos buscar os valores acumulados
         pois nao mudara a modalidade vinculada na aplicacao */
      IF rw_crapcpc.idacumul = 1 THEN
        OPEN cr_crapmpc_cont(pr_cdprodut => pr_cdprodut
                            ,pr_qtdiacar => pr_qtdiacar
                            ,pr_qtdiaprz => pr_qtdiaprz);
        FETCH cr_crapmpc_cont INTO rw_crapmpc_cont;
        IF cr_crapmpc_cont%NOTFOUND THEN
          CLOSE cr_crapmpc_cont;
          -- Caso nao encontre, gera critica
          vr_dscritic := 'Nao foram encontradas modalidades disponiveis para o produto selecionado.';
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_crapmpc_cont;
        END IF;
        IF rw_crapmpc_cont.cont = 1 then
          rw_crapcpc.idacumul := 0;
        END IF;
      END IF;

      IF rw_crapcpc.idacumul = 1 THEN

        -- Selecionar informacoes % IR para o calculo
        vr_percenir := GENE0002.fn_char_para_number(TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                                              ,pr_nmsistem => 'CRED'
                                                                              ,pr_tptabela => 'CONFIG'
                                                                              ,pr_cdempres => 0
                                                                              ,pr_cdacesso => 'PERCIRAPLI'
                                                                              ,pr_tpregist => 0));

        -- Verificar as faixas de IR
        APLI0001.pc_busca_faixa_ir_rdca(pr_cdcooper => pr_cdcooper);
        -- Buscar a quantidade de faixas de ir
        vr_qtdfaxir := APLI0001.vr_faixa_ir_rdca.Count;

        --Selecionar informacoes da data de inicio e fim da taxa para calculo da APLI0001.pc_provisao_rdc_pos
        vr_dstextab_rdcpos:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                       ,pr_nmsistem => 'CRED'
                                                       ,pr_tptabela => 'USUARI'
                                                       ,pr_cdempres => 11
                                                       ,pr_cdacesso => 'MXRENDIPOS'
                                                       ,pr_tpregist => 1);
        -- Se não encontrar
        IF vr_dstextab_rdcpos IS NULL THEN
          -- Utilizar datas padrão
          vr_dtinitax := to_date('01/01/9999','dd/mm/yyyy');
          vr_dtfimtax := to_date('01/01/9999','dd/mm/yyyy');
        ELSE
          --Atribuir as datas encontradas
          vr_dtinitax := to_date(gene0002.fn_busca_entrada(1, vr_dstextab_rdcpos, ';'), 'DD/MM/RRRR');
          vr_dtfimtax := to_date(gene0002.fn_busca_entrada(2, vr_dstextab_rdcpos, ';'), 'DD/MM/RRRR');
        END IF;

        -- Carregar tabela de memoria de taxas
        -- Selecionar os tipos de registro da tabela generica
        FOR rw_craptab IN cr_craptab_taxas(pr_cdcooper => pr_cdcooper
                                          ,pr_nmsistem => 'CRED'
                                          ,pr_tptabela => 'GENERI'
                                          ,pr_cdempres => 0
                                          ,pr_cdacesso => 'SOMAPLTAXA'
                                          ,pr_dstextab => 'SIM') LOOP
          -- Atribuir valor para tabela memoria
          vr_tab_tpregist(rw_craptab.tpregist) := rw_craptab.tpregist;
        END LOOP;

        -- Carregar tabela de memoria de contas bloqueadas
        TABE0001.pc_carrega_ctablq(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_tab_cta_bloq => vr_tab_conta_bloq);

        -- Carregar tabela de memoria de lancamentos na poupanca
        FOR rw_craplpp IN cr_craplpp (pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt - 180) LOOP

          IF   rw_craplpp.qtlancmto > 3 THEN
            -- Montar indice para acessar tabela
            vr_index_craplpp := LPad(rw_craplpp.nrdconta,10,'0')||LPad(rw_craplpp.nrctrrpp,10,'0');

            -- Atribuir quantidade encontrada de cada conta ao vetor
            vr_tab_craplpp(vr_index_craplpp) := rw_craplpp.qtlancmto;
          END IF;
        END LOOP;


        -- Carregar tabela de memoria com total de resgates na poupanca
        FOR rw_craplrg IN cr_craplrg_saque (pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta) LOOP
          -- Montar Indice para acesso quantidade lancamentos de resgate
          vr_index_craplrg := LPad(rw_craplrg.nrdconta,10,'0')||LPad(rw_craplrg.nraplica,10,'0');
          -- Popular tabela de memoria
          vr_tab_craplrg(vr_index_craplrg) := rw_craplrg.qtlancmto;
        END LOOP;


        -- Carregar tabela de memória com total resgatado por conta e aplicacao
        FOR rw_craplrg IN cr_craplrg (pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_dtresgat => rw_crapdat.dtmvtopr) LOOP
          -- Montar indice para selecionar total dos resgates na tabela auxiliar
          vr_index_resgate := LPad(rw_craplrg.nrdconta,10,'0')||
                              LPad(rw_craplrg.tpaplica,05,'0')||
                              LPad(rw_craplrg.nraplica,10,'0');
          -- Popular a tabela de memoria com a soma dos lancamentos de resgate
          vr_tab_resgate(vr_index_resgate).tpresgat := rw_craplrg.tpresgat;
          vr_tab_resgate(vr_index_resgate).vllanmto := rw_craplrg.vllanmto;
        END LOOP;

        --Executar rotina para acumular aplicacoes
        APLI0001.pc_acumula_aplicacoes (pr_cdcooper        => pr_cdcooper             --> Cooperativa
                                       ,pr_cdoperad        => pr_cdoperad             --> Operador
                                       ,pr_cdprogra        => pr_nmdatela             --> Nome do programa chamador
                                       ,pr_nrdconta        => rw_crapass.nrdconta     --> Nro da conta da aplicação RDCA
                                       ,pr_nraplica        => 0                       --> Nro da Aplicacao (0=todas)
                                       ,pr_tpaplica        => 0                       --> Tipo de Aplicacao
                                       ,pr_vlaplica        => 0                       --> Valor da Aplicacao
                                       ,pr_cdperapl        => 0                       --> Codigo Periodo Aplicacao
                                       ,pr_percenir        => vr_percenir             --> % IR para Calculo Poupanca
                                       ,pr_qtdfaxir        => vr_qtdfaxir             --> Quantidade de faixas de IR
                                       ,pr_tab_tpregist    => vr_tab_tpregist         --> Tipo de Registro para loop craptab (performance)
                                       ,pr_tab_craptab     => vr_tab_conta_bloq       --> Tipo de tabela de Conta Bloqueada (performance)
                                       ,pr_tab_craplpp     => vr_tab_craplpp          --> Tipo de tabela com lancamento poupanca (performance)
                                       ,pr_tab_craplrg     => vr_tab_craplrg          --> Tipo de tabela com resgates (performance)
                                       ,pr_tab_resgate     => vr_tab_resgate          --> Tabela com a soma dos resgates por conta e aplicacao
                                       ,pr_tab_crapdat     => rw_crapdat              --> Dados da tabela de datas
                                       ,pr_cdagenci_assoc  => rw_crapass.cdagenci     --> Agencia do associado
                                       ,pr_nrdconta_assoc  => rw_crapass.nrdconta     --> Conta do associado
                                       ,pr_dtinitax        => vr_dtinitax             --> Data Inicial da Utilizacao da taxa da poupanca
                                       ,pr_dtfimtax        => vr_dtfimtax             --> Data Final da Utilizacao da taxa da poupanca
                                       ,pr_vlsdrdca        => vr_vlsldacu             --> Valor Saldo Aplicacao (OUT)
                                       ,pr_txaplica        => vr_txaplica             --> Taxa Maxima de Aplicacao (OUT)
                                       ,pr_txaplmes        => vr_txaplmes             --> Taxa Minima de Aplicacao (OUT)
                                       ,pr_retorno         => vr_retorno              --> Descricao de erro ou sucesso OK/NOK
                                       ,pr_tab_acumula     => vr_tab_acumula          --> Aplicacoes do Associado
                                       ,pr_tab_erro        => vr_tab_erro);           --> Saida com erros


        IF vr_retorno = 'NOK' THEN
          -- Tenta buscar o erro no vetor de erro
          IF vr_tab_erro.COUNT > 0 THEN
            vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic || ' Conta: '||rw_crapass.nrdconta;
          ELSE
            vr_cdcritic:= 0;
            vr_dscritic := 'Retorno "NOK" na APLI0005.pc_valida_cad_aplic e sem informacao na pr_tab_erro, Conta: '||rw_crapass.nrdconta||' Aplica: 0';
          END IF;

          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;

      END IF;

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
          -- Limpar a tabela de erro, pois a exceção vai criar um novo registro
          vr_tab_erro.DELETE;
        ELSE
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao consultar capital.';
        END IF;
        -- Executa a exceção
        RAISE vr_exc_saida;
      END IF;

      -- Soma valor acumulado mais valor da aplicacao atual para obter taxa
      vr_vlsldacu := NVL(vr_vlsldacu,0) + NVL(pr_vlaplica,0);

      -- Consulta de modalidades
      OPEN cr_crapmpc(pr_cdprodut => pr_cdprodut
                     ,pr_qtdiacar => pr_qtdiacar
                     ,pr_qtdiaprz => pr_qtdiaprz
                     ,pr_vlsldacu => vr_vlsldacu);

      FETCH cr_crapmpc INTO rw_crapmpc;

      -- Verifica se modalidade consultada existe
      IF cr_crapmpc%NOTFOUND THEN
        CLOSE cr_crapmpc;
        vr_dscritic := 'Modalidade nao encontrado.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapmpc;
      END IF;

      -- Verificar se a modalidade está bloqueada
      IF rw_crapmpc.idsitmod = 2 THEN
        vr_dscritic := 'Modalidade bloqueada.';
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se produto tem taxa composta e valor da taxa
      IF rw_crapcpc.idtxfixa = 1 AND rw_crapmpc.vltxfixa = 0 THEN
        vr_dscritic := 'Produto de taxa composta, nao e permitido valor de taxa da aplicacao zerada.';
        RAISE vr_exc_saida;
      END IF;

      -- Se for um produto sem taxa fixa, não permitir o cadastro da aplicação se o percentual de remuneração estiver zerado
      IF rw_crapcpc.idtxfixa = 2 AND rw_crapmpc.vlperren = 0 THEN
        vr_dscritic := 'Produto de taxa fixa, nao e permitido valor percentual de remuneracao da aplicacao zerado.';
        RAISE vr_exc_saida;
      END IF;

      -- Verifica valor da aplicacao foi retirado da conta investimento
      IF pr_iddebcti = 1 THEN

        -- Verifica se ha saldo suficiente
        OPEN cr_crapsli(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_dtrefere => last_day(rw_crapdat.dtmvtolt));

        -- Verifica se consulta retornou registros
        IF cr_crapsli%NOTFOUND THEN
          CLOSE cr_crapsli;
          vr_dscritic := 'Registro de saldo nao encontrado';
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_crapsli;
        END IF;

        -- Verifica se existe saldo disponivel
        IF rw_crapsli.vlsddisp < pr_vlaplica THEN
          vr_dscritic := 'Saldo insuficiente';
          RAISE vr_exc_saida;
        END IF;

      END IF;

      -- Verifica se o valor da aplicação for retirado da conta-corrente
      IF pr_iddebcti = 0 THEN

        -- Verifica se o saldo e suficiente
        EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper
                                   ,pr_rw_crapdat => rw_crapdat
                                   ,pr_cdagenci   => 0
                                   ,pr_nrdcaixa   => 0
                                   ,pr_cdoperad   => 0
                                   ,pr_nrdconta   => pr_nrdconta
                                   ,pr_vllimcre   => rw_crapass.vllimcre
                                   ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                   ,pr_flgcrass   => FALSE
                                   ,pr_tipo_busca => 'A' --Chamado 291693 (Heitor - RKAM)
                                   ,pr_des_reto   => vr_des_reto
                                   ,pr_tab_sald   => vr_tab_sald
                                   ,pr_tab_erro   => vr_tab_erro);

        -- Verifica se retornou erro durante a execução
        IF vr_des_reto <> 'OK' THEN
          IF vr_tab_erro.COUNT > 0 THEN
            -- Se existir erro adiciona na crítica
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            -- Limpar a tabela de erro, pois a exceção vai criar um novo registro
            vr_tab_erro.DELETE;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Erro em obter saldo dia.';
          END IF;
          -- Executa a exceção
          RAISE vr_exc_saida;
        END IF;

        -- Verifica se aplicacao maior que o saldo disponivel
        IF pr_vlaplica > (vr_tab_sald(vr_tab_sald.FIRST).vllimcre + vr_tab_sald(vr_tab_sald.FIRST).vlsddisp) THEN
          vr_dscritic := 'Saldo insuficiente em conta corrente.';
          RAISE vr_exc_saida;
        END IF;

      END IF;

    EXCEPTION

      WHEN vr_exc_saida THEN

        IF upper(pr_nmdatela) <> 'CRPS145' THEN
        ROLLBACK;
        END IF;

         -- Se veio apenas o código
        IF vr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          -- Buscar a descrição
          pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        ELSIF pr_dscritic IS NULL AND vr_tab_erro.COUNT > 0 THEN
          -- Se por algum motivo ainda não existe erro na pr_dscritic
          -- mas existe informação na vr_tab_erro
          -- Usamos a descrição do primeiro registro da tabela de erro
          pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Verifica se deve gerar log
        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                              ,pr_dstransa => 'Validacao de Aplicacao. ' || pr_dscritic
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
          /* Comitar apenas se não for via batch */
          IF upper(pr_nmdatela) <> 'CRPS145' THEN
          COMMIT;
        END IF;
        END IF;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Consulta de Saldo APLI0005.pc_valida_cad_aplic: ' || SQLERRM;
        /* Desfazer apenas se não for via batch */
        IF upper(pr_nmdatela) <> 'CRPS145' THEN
        ROLLBACK;
        END IF;


        -- Verifica se deve gerar log
        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                              ,pr_dstransa => 'Validacao de Aplicacao. ' || pr_dscritic
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);

          /* Comitar apenas se não for via batch */
          IF upper(pr_nmdatela) <> 'CRPS145' THEN
          COMMIT;
        END IF;
        END IF;
    END;

  END pc_valida_cad_aplic;

  -- Rotina para validacao de cadastros de aplicacoes da web
  PROCEDURE pc_valida_cad_aplic_web(pr_nrdconta IN craprac.nrdconta%TYPE --> Número da Conta
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Titular da Conta
                                   ,pr_dtmvtolt IN VARCHAR2              --> Data de Movimento
                                   ,pr_cdprodut IN crapcpc.cdprodut%TYPE --> Código do Produto
                                   ,pr_qtdiaapl IN INTEGER               --> Dias da Aplicação
                                   ,pr_dtvencto IN VARCHAR2              --> Data de Vencimento da Aplicação
                                   ,pr_qtdiacar IN INTEGER               --> Carência da Aplicação
                                   ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE --> Prazo da Aplicação (Prazo selecionado na tela)
                                   ,pr_vlaplica IN NUMBER                --> Valor da Aplicação (Valor informado em tela)
                                   ,pr_iddebcti IN INTEGER               --> Identificador de Débito na Conta Investimento (Identificador informado em tela)
                                   ,pr_idorirec IN INTEGER               --> Identificador de Origem do Recurso (Identificador informado em tela)
                                   ,pr_idgerlog IN INTEGER               --> Identificador de Log (Fixo no código, 0 – Não / 1 - Sim)
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN

    /* .............................................................................

     Programa: pc_valida_cad_aplic_web
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Agosto/14.                    Ultima atualizacao: 04/08/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a validacao de informacoes do cadastro de aplicacoes via web.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/

    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis locais
      vr_dtmvtolt DATE;
      vr_dtvencto DATE;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN

      -- Converte data passada por parametro para tipo correto
      vr_dtmvtolt := TO_DATE(pr_dtmvtolt,'dd/mm/yyyy');
      vr_dtvencto := TO_DATE(pr_dtvencto,'dd/mm/yyyy');

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      APLI0005.pc_valida_cad_aplic(pr_cdcooper => vr_cdcooper   --> Código da Cooperativa
                                  ,pr_cdoperad => vr_cdoperad   --> Código do Operador
                                  ,pr_nmdatela => vr_nmdatela   --> Nome da Tela
                                  ,pr_idorigem => vr_idorigem   --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                  ,pr_nrdconta => pr_nrdconta   --> Número da Conta
                                  ,pr_idseqttl => pr_idseqttl   --> Titular da Conta
                                  ,pr_dtmvtolt => vr_dtmvtolt   --> Data de Movimento
                                  ,pr_cdprodut => pr_cdprodut   --> Código do Produto
                                  ,pr_qtdiaapl => pr_qtdiaapl   --> Dias da Aplicação
                                  ,pr_dtvencto => vr_dtvencto   --> Data de Vencimento da Aplicação
                                  ,pr_qtdiacar => pr_qtdiacar   --> Carência da Aplicação
                                  ,pr_qtdiaprz => pr_qtdiaprz   --> Prazo da Aplicação (Prazo selecionado na tela)
                                  ,pr_vlaplica => pr_vlaplica   --> Valor da Aplicação (Valor informado em tela)
                                  ,pr_iddebcti => pr_iddebcti   --> Identificador de Débito na Conta Investimento (Identificador informado em tela)
                                  ,pr_idorirec => pr_idorirec   --> Identificador de Origem do Recurso (Identificador informado em tela)
                                  ,pr_idgerlog => pr_idgerlog   --> Identificador de Log (Fixo no código, 0 – Não / 1 - Sim)
                                  ,pr_cdcritic => vr_cdcritic   --> Codigo da Critica
                                  ,pr_dscritic => vr_dscritic); --> Descricao da Critica

      IF vr_dscritic IS NOT NULL OR
         NVL(vr_cdcritic,0) <> 0 THEN
        RAISE vr_exc_saida;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em APLI0005.pc_valida_cad_aplic_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_valida_cad_aplic_web;

  -- Rotina geral para validacao da data de vencimento
  PROCEDURE pc_calcula_prazo_aplicacao(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                      ,pr_datcaren IN DATE                  --> Data de Carencia
                                      ,pr_datvenci IN DATE                  --> Data de vencimento
                                      ,pr_diaspraz IN PLS_INTEGER           --> Dias de Prazo
                                      ,pr_qtdiaapl OUT PLS_INTEGER          --> Quantidade de dias da aplicacao
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica

  BEGIN

    /* .............................................................................

     Programa: pc_calcula_prazo_aplicacao
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Julho/14.                    Ultima atualizacao: 29/07/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a validacao da data de vencimento da aplicacao informada pelo operador.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    BEGIN

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;

      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Validações da data de vencimento
      IF (pr_datvenci < pr_datcaren) THEN
        vr_dscritic := 'Data de vencimento nao pode ser menor que a data de carencia.';
        RAISE vr_exc_saida;
      ELSIF (pr_datvenci > (rw_crapdat.dtmvtolt + pr_diaspraz)) THEN
        vr_dscritic := 'Data de vencimento nao pode ser maior que o prazo da modalidade.';
        RAISE vr_exc_saida;
      ELSE
        pr_qtdiaapl := (pr_datvenci - rw_crapdat.dtmvtolt);
      END IF;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Calculo de Prazo de Aplicacao APLI0005.pc_calcula_prazo_aplicacao: ' || SQLERRM;

        ROLLBACK;
    END;

  END pc_calcula_prazo_aplicacao;

  -- Rotina para validacao da data de vencimento via Ayllos WEB
  PROCEDURE pc_calcula_prazo_aplicacao_web(pr_datcaren IN VARCHAR2           --> Data de Carencia
                                          ,pr_datvenci IN VARCHAR2           --> Data de vencimento
                                          ,pr_diaspraz IN PLS_INTEGER        --> Dias de Prazo
                                          ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo

  BEGIN

    /* .............................................................................

     Programa: pc_calcula_prazo_aplicacao
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Julho/14.                    Ultima atualizacao: 29/07/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a validacao da data de vencimento da aplicacao informada pelo operador.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis locais
      vr_qtdiaapl PLS_INTEGER := 0; --> Qtd de dias de aplicacao
      vr_datcaren DATE;             --> Data de Carencia
      vr_datvenci DATE;             --> Data de vencimento

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN

      vr_datcaren := TO_DATE(pr_datcaren,'dd/mm/yyyy'); -- Data de Carencia
      vr_datvenci := TO_DATE(pr_datvenci,'dd/mm/yyyy'); -- Data de vencimento

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro na extracao de dados de log
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      APLI0005.pc_calcula_prazo_aplicacao(pr_cdcooper => vr_cdcooper   --> Codigo da cooperativa
                                         ,pr_datcaren => vr_datcaren   --> Data de carencia
                                         ,pr_datvenci => vr_datvenci   --> Data de vencimento
                                         ,pr_diaspraz => pr_diaspraz   --> Quantidade de dias de carencia
                                         ,pr_qtdiaapl => vr_qtdiaapl   --> Quantidade de dias da aplicacao
                                         ,pr_cdcritic => vr_cdcritic   --> Codigo da critica
                                         ,pr_dscritic => vr_dscritic); --> Descricao da critica

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtdiaapl', pr_tag_cont => TO_CHAR(nvl(vr_qtdiaapl,0)), pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Calculo de Prazo de Aplicacao APLI0005.pc_calcula_prazo_aplicacao_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_calcula_prazo_aplicacao_web;

  -- Rotina geral para cadastros de aplicacoes
  PROCEDURE pc_cadastra_aplic(pr_cdcooper IN craprac.cdcooper%TYPE      -- Código da Cooperativa
                             ,pr_cdoperad IN crapope.cdoperad%TYPE      -- Código do Operador
                             ,pr_nmdatela IN craptel.nmdatela%TYPE      -- Nome da Tela
                             ,pr_idorigem IN INTEGER                    -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA)
                             ,pr_nrdconta IN craprac.nrdconta%TYPE      -- Número da Conta
                             ,pr_idseqttl IN crapttl.idseqttl%TYPE      -- Titular da Conta
                             ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE      -- Numero de caixa
                             ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE      -- Data de Movimento
                             ,pr_cdprodut IN crapcpc.cdprodut%TYPE      -- Código do Produto (Produto selecionado na tela)
                             ,pr_qtdiaapl IN INTEGER                    -- Dias da Aplicação (Dias informados em tela)
                             ,pr_dtvencto IN DATE                       -- Data de Vencimento da Aplicação (Data informada em tela)
                             ,pr_qtdiacar IN INTEGER                    -- Carência da Aplicação (Carência informada em tela)
                             ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE      -- Prazo da Aplicação (Prazo selecionado na tela)
                             ,pr_vlaplica IN NUMBER                     -- Valor da Aplicação (Valor informado em tela)
                             ,pr_iddebcti IN INTEGER                    -- Identificador de Débito na Conta Investimento (Identificador informado na tela, 0 – Não / 1 - Sim)
                             ,pr_idorirec IN INTEGER                    -- Identificador de Origem do Recurso (Identificador informado em tela)
                             ,pr_idgerlog IN INTEGER                    -- Identificador de Log (Fixo no código, 0 – Não / 1 – Sim)
                             ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE DEFAULT 0 -- Número aplicação programada (Opcional, 0 = Aplicação Não Programada)
                             ,pr_nraplica OUT craprac.nraplica%TYPE     -- Numero da aplicacao cadastrada
                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE     -- Codigo da critica de erro
                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS -- Descricao da critica de erro
  BEGIN

    /* .............................................................................

     Programa: pc_cadastra_aplic
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Agosto/14.                    Ultima atualizacao: 28/11/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina geral referente ao cadastro de aplicacoes.

     Observacao: -----

     Alteracoes: 02/06/2016 - Ajustado os cursores de leitura da craptab para que seja
                              utilizado o indice da tabela, para otimizar a performace
                              na leitura dos dados (Douglas - Chamado 454248)

                 18/07/2018 - Grava o numero da aplicação programada na CRAPRAC (0 = Aplicação Tradicional)
                              Proj. 411.2 - CIS Corporate)


                 28/11/2018 - Utilizar a o parâmetro pr_dtmvtolt no lugar da crapdat.dtmvtolt
                              Proj. 411.2 - CIS Corporate

    ..............................................................................*/

    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis Erro
      vr_des_erro VARCHAR2(1000);

      -- Variaveis locais
      vr_dtmvtopr DATE;         -- Data do proximo movimento
      vr_retorno  VARCHAR2(3);  -- Tipo de retorno (OK / NOK)
      vr_percenir NUMBER:= 0;   -- Percentual de IR
      vr_qtdfaxir INTEGER:= 0;
      vr_vltotrda craprda.vlsdrdca%TYPE := 0;
      vr_txaplica craplap.txaplica%TYPE;
      vr_txaplmes craplap.txaplmes%TYPE;
      vr_nraplica craprac.nraplica%TYPE;
      vr_cdnomenc craprac.cdnomenc%TYPE;
      vr_tpaplacu VARCHAR2(100);
      vr_cdhistor craplac.cdhistor%TYPE;
      vr_rowidtab ROWID;

      vr_dsinfor1 VARCHAR2(1000);
      vr_dsinfor2 VARCHAR2(1000);
      vr_dsinfor3 VARCHAR2(1000);
      vr_nmextttl crapttl.nmextttl%TYPE;
      vr_nmcidade crapage.nmcidade%TYPE;
      vr_dsprotoc crappro.dsprotoc%TYPE;
      vr_dsorigem VARCHAR2(500) := 'AIMARO,CAIXA,INTERNET,TAA,AIMARO WEB,URA';
      vr_dstransa VARCHAR2(100) := 'Inclusao de aplicacao.';
      vr_nrdrowid ROWID;

      --Variavel para receber valor data inicio e fim para calculo taxa rdcpos.
      vr_dstextab_rdcpos craptab.dstextab%TYPE;
      vr_dtinitax     DATE;     -- Data de inicio da utilizacao da taxa de poupanca.
      vr_dtfimtax     DATE;     -- Data de fim da utilizacao da taxa de poupanca.

      --Definicao das tabelas de memoria da apli0001.pc_acumula_aplicacoes
      vr_tab_acumula    APLI0001.typ_tab_acumula_aplic;
      vr_tab_erro       GENE0001.typ_tab_erro;
      vr_tab_tpregist   APLI0001.typ_tab_tpregist;
      vr_tab_conta_bloq APLI0001.typ_tab_ctablq;
      vr_tab_craplpp    APLI0001.typ_tab_craplpp;
      vr_tab_craplrg    APLI0001.typ_tab_craplpp;
      vr_tab_resgate    APLI0001.typ_tab_resgate;

      --Variavel usada para montar o indice da tabela de memoria
      vr_index_craplpp VARCHAR2(20);
      vr_index_craplrg VARCHAR2(20);
      vr_index_resgate VARCHAR2(25);
      vr_index_acumula INTEGER;

      vr_incrineg      INTEGER; --> Indicador de crítica de negócio para uso com a "pc_gerar_lancamento_conta"
      vr_tab_retorno   LANC0001.typ_reg_retorno;

      -- CURSORES --

      -- Selecionar os dados da Cooperativa
      CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.nrtelura
              ,cop.cdbcoctl
              ,cop.cdagectl
              ,cop.dsdircop
              ,cop.nrctactl
              ,cop.nmextcop
              ,cop.nrdocnpj
        FROM crapcop cop
        WHERE cop.cdcooper = pr_cdcooper
          AND cop.flgativo = 1;

      rw_crapcop cr_crapcop%ROWTYPE;

      --Registro do tipo calendario
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

      -- Consulta referente a dados de produtos
      CURSOR cr_crapcpc (pr_cdprodut crapcpc.cdprodut%TYPE)IS
        SELECT cpc.cdprodut
              ,cpc.nmprodut
              ,cpc.idacumul
              ,cpc.idtippro
              ,cpc.cdhsrgap
              ,cpc.idtxfixa
              ,cpc.cdhsraap
              ,cpc.cdhsnrap
              ,cpc.cdhscacc
              ,ind.nmdindex
          FROM crapcpc cpc,
               crapind ind
         WHERE cpc.cddindex = ind.cddindex
               AND cpc.cdprodut = pr_cdprodut;

      rw_crapcpc cr_crapcpc%ROWTYPE;

      -- Consulta referente a dados de aplicacoes de produtos antigos
      CURSOR cr_craprda(pr_cdcooper IN craprda.cdcooper%TYPE
                       ,pr_nrdconta IN craprda.nrdconta%TYPE
                       ,pr_nraplica IN craprda.nraplica%TYPE)IS

        SELECT rda.cdcooper
              ,rda.nrdconta
              ,rda.nraplica
          FROM craprda rda
         WHERE rda.cdcooper = pr_cdcooper
           AND rda.nrdconta = pr_nrdconta
           AND rda.nraplica = pr_nraplica;

      rw_craprda cr_craprda%ROWTYPE;

      -- Consulta de Lotes
      CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
                       ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                       ,pr_cdagenci IN craplot.cdagenci%TYPE
                       ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                       ,pr_nrdolote IN craplot.nrdolote%TYPE) IS

        SELECT lot.cdcooper
              ,lot.dtmvtolt
              ,lot.cdagenci
              ,lot.cdbccxlt
              ,lot.nrdolote
              ,lot.nrseqdig
              ,lot.qtinfoln
              ,lot.qtcompln
              ,lot.vlinfocr
              ,lot.vlcompcr
              ,lot.vlcompdb
              ,lot.vlinfodb
              ,lot.rowid
          FROM craplot lot
         WHERE lot.cdcooper = pr_cdcooper
           AND lot.dtmvtolt = pr_dtmvtolt
           AND lot.cdagenci = pr_cdagenci
           AND lot.cdbccxlt = pr_cdbccxlt
           AND lot.nrdolote = pr_nrdolote;

      rw_craplot cr_craplot%ROWTYPE;

      -- Consulta referente a nomenclatura de produtos
      CURSOR cr_crapnpc (pr_cdprodut crapnpc.cdprodut%TYPE
                        ,pr_qtdiacar crapnpc.qtmincar%TYPE
                        ,pr_vlsldacu crapnpc.vlminapl%TYPE)IS
      SELECT
        npc.cdnomenc
       ,npc.dsnomenc
      FROM
        crapnpc npc
      WHERE
            npc.cdprodut  = pr_cdprodut
        AND npc.qtmincar <= pr_qtdiacar
        AND npc.qtmaxcar >= pr_qtdiacar
        AND npc.vlminapl <= pr_vlsldacu
        AND npc.vlmaxapl >= pr_vlsldacu
        AND npc.idsitnom  = 1;

      rw_crapnpc cr_crapnpc%ROWTYPE;

      -- Consulta de modalidade de produto
      CURSOR cr_crapmpc(pr_qtdiacar IN crapmpc.qtdiacar%TYPE --> Dias de Carencia
                       ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE --> Dias de Prazo
                       ,pr_vlsldacu IN NUMBER                --> Saldo Acumulado
                       ,pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
                       ) IS
        SELECT
          mpc.cdmodali
         ,mpc.vltxfixa
         ,mpc.vlperren
        FROM
          crapmpc mpc
         ,crapdpc dpc
        WHERE
              mpc.cdprodut  = pr_cdprodut -- Codigo do produto
          AND mpc.qtdiacar  = pr_qtdiacar -- Quantidade de dias de carencia
          AND mpc.qtdiaprz  = pr_qtdiaprz -- Quantidade de dias de prazo
          AND mpc.vlrfaixa <= pr_vlsldacu -- Saldo Acumulado
          AND dpc.cdmodali  = mpc.cdmodali -- Codigo da Modalidade
          AND dpc.cdcooper  = pr_cdcooper  -- Codigo da Cooperatica
          AND dpc.idsitmod  = 1
        ORDER BY
          mpc.vlrfaixa DESC;

      rw_crapmpc cr_crapmpc%ROWTYPE;

      CURSOR cr_crapmpc_cont(pr_qtdiacar IN crapmpc.qtdiacar%TYPE --> Dias de Carencia
                            ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE --> Dias de Prazo
                            ,pr_cdprodut IN crapcpc.cdprodut%TYPE --> Codigo do Produto
                            ) IS
        SELECT COUNT(1) cont
          FROM crapmpc mpc
              ,crapdpc dpc
        WHERE mpc.cdprodut  = pr_cdprodut -- Codigo do produto
          AND mpc.qtdiacar  = pr_qtdiacar -- Quantidade de dias de carencia
          AND mpc.qtdiaprz  = pr_qtdiaprz -- Quantidade de dias de prazo
          AND dpc.cdmodali  = mpc.cdmodali -- Codigo da Modalidade
          AND dpc.cdcooper  = pr_cdcooper  -- Codigo da Cooperatica
          AND dpc.idsitmod  = 1;
      
      rw_crapmpc_cont cr_crapmpc_cont%ROWTYPE;

      --Selecionar informacoes dos associados
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapres.nrdconta%TYPE) IS

        SELECT crapass.cdcooper
              ,crapass.cdagenci
              ,crapass.nrdconta
              ,crapass.nmprimtl
              ,crapass.inpessoa
        FROM crapass crapass
        WHERE  crapass.cdcooper = pr_cdcooper
        AND    crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Cursosr para encontrar a cidade do PA do associado
      CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
      SELECT age.nmcidade
        FROM crapage age
       WHERE age.cdcooper = pr_cdcooper
         AND age.cdagenci = pr_cdagenci;

      --Selecionar informacoes do titular
      CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%type
                        ,pr_nrdconta IN crapttl.nrdconta%type
                        ,pr_idseqttl IN crapttl.idseqttl%type) IS
      SELECT ttl.nmextttl
            ,ttl.nrcpfcgc
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = pr_idseqttl;
      rw_crapttl cr_crapttl%ROWTYPE;

      -- Selecionar quantidade de saques em poupanca nos ultimos 6 meses
      CURSOR cr_craplpp (pr_cdcooper IN craplpp.cdcooper%TYPE
                        ,pr_nrdconta IN craplpp.nrdconta%TYPE
                        ,pr_dtmvtolt IN craplpp.dtmvtolt%TYPE) IS
      SELECT lpp.nrdconta
            ,lpp.nrctrrpp
            ,Count(*) qtlancmto
        FROM craplpp lpp
       WHERE lpp.cdcooper = pr_cdcooper
         AND lpp.nrdconta = pr_nrdconta
         AND lpp.cdhistor IN (158,496)
         AND lpp.dtmvtolt > pr_dtmvtolt
         GROUP BY lpp.nrdconta
                 ,lpp.nrctrrpp;

      rw_craplpp cr_craplpp%ROWTYPE;

      --Contar a quantidade de resgates das contas
      CURSOR cr_craplrg_saque (pr_cdcooper IN craplrg.cdcooper%TYPE
                              ,pr_nrdconta IN craplrg.nrdconta%TYPE) IS

        SELECT craplrg.nrdconta,craplrg.nraplica,Count(*) qtlancmto
        FROM craplrg craplrg
        WHERE craplrg.cdcooper = pr_cdcooper
        AND   craplrg.nrdconta = pr_nrdconta
        AND   craplrg.tpaplica = 4
        AND   craplrg.inresgat = 0
        GROUP BY craplrg.nrdconta
                ,craplrg.nraplica;

      --Selecionar informacoes dos lancamentos de resgate
      CURSOR cr_craplrg (pr_cdcooper IN craplrg.cdcooper%TYPE
                        ,pr_nrdconta IN craplrg.nrdconta%TYPE
                        ,pr_dtresgat IN craplrg.dtresgat%TYPE) IS
        SELECT craplrg.nrdconta
              ,craplrg.nraplica
              ,craplrg.tpaplica
              ,craplrg.tpresgat
              ,Nvl(Sum(Nvl(craplrg.vllanmto,0)),0) vllanmto
        FROM craplrg craplrg
        WHERE craplrg.cdcooper  = pr_cdcooper
        AND   craplrg.nrdconta  = pr_nrdconta
        AND   craplrg.dtresgat <= pr_dtresgat
        AND   craplrg.inresgat  = 0
        AND   craplrg.tpresgat  = 1
        GROUP BY craplrg.nrdconta
                ,craplrg.nraplica
                ,craplrg.tpaplica
                ,craplrg.tpresgat;

      CURSOR cr_crapsli(pr_cdcooper IN crapsli.cdcooper%TYPE
                       ,pr_nrdconta IN crapsli.nrdconta%TYPE
                       ,pr_dtrefere IN crapsli.dtrefere%TYPE) IS
        SELECT
          sli.cdcooper
         ,sli.nrdconta
         ,sli.dtrefere
         ,sli.vlsddisp
         ,sli.rowid
        FROM
          crapsli sli
        WHERE
              sli.cdcooper = pr_cdcooper
          AND sli.nrdconta = pr_nrdconta
          AND sli.dtrefere = pr_dtrefere;

      rw_crapsli cr_crapsli%ROWTYPE;

    BEGIN

      gene0001.pc_informa_acesso(pr_module => 'APLI0005.pc_cadastra_aplic');

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);

      FETCH cr_crapcop INTO rw_crapcop;

      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        vr_cdcritic:= 651;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Verifica se a cooperativa esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);

      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      APLI0005.pc_valida_cad_aplic(pr_cdcooper => pr_cdcooper
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_nmdatela => pr_nmdatela
                                  ,pr_idorigem => pr_idorigem
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_idseqttl => pr_idseqttl
                                  ,pr_dtmvtolt => pr_dtmvtolt
                                  ,pr_cdprodut => pr_cdprodut
                                  ,pr_qtdiaapl => pr_qtdiaapl
                                  ,pr_dtvencto => pr_dtvencto
                                  ,pr_qtdiacar => pr_qtdiacar
                                  ,pr_qtdiaprz => pr_qtdiaprz
                                  ,pr_vlaplica => pr_vlaplica
                                  ,pr_iddebcti => pr_iddebcti
                                  ,pr_idorirec => pr_idorirec
                                  ,pr_idgerlog => pr_idgerlog
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);

      IF NVL(vr_cdcritic,0) <> 0 OR
         vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);

      FETCH cr_crapass INTO rw_crapass;

      -- Verifica se encontrou associado
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_dscritic := 'Cooperado nao cadastrado.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapass;
      END IF;

      -- Consulta dados de produtos
      OPEN cr_crapcpc(pr_cdprodut => pr_cdprodut);

      FETCH cr_crapcpc INTO rw_crapcpc;

      IF cr_crapcpc%NOTFOUND THEN
        CLOSE cr_crapcpc;
        vr_dscritic := 'Produto nao encontrado.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapcpc;
      END IF;

      /* Vamos verificar se existe mais opcoes de modalidades disponiveis,
         caso soh tenha 1, nao precisamos buscar os valores acumulados
         pois nao mudara a modalidade vinculada na aplicacao */
      IF rw_crapcpc.idacumul = 1 THEN
        OPEN cr_crapmpc_cont(pr_cdprodut => pr_cdprodut
                            ,pr_qtdiacar => pr_qtdiacar
                            ,pr_qtdiaprz => pr_qtdiaprz);
        FETCH cr_crapmpc_cont INTO rw_crapmpc_cont;
        IF cr_crapmpc_cont%NOTFOUND THEN
          CLOSE cr_crapmpc_cont;
          -- Caso nao encontre, gera critica
          vr_dscritic := 'Nao foi encontrada modalidades disponiveis na política de captacao para o produto selecionado.';
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_crapmpc_cont;
        END IF;
        IF rw_crapmpc_cont.cont = 1 then
          rw_crapcpc.idacumul := 0;
        END IF;
      END IF;

      -- Verifica cumulatividade do produto para obter o saldo
      IF rw_crapcpc.idacumul = 1 THEN

        -- Carregar tabela de memoria de contas bloqueadas
        TABE0001.pc_carrega_ctablq(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_tab_cta_bloq => vr_tab_conta_bloq);

        --Selecionar informacoes % IR para o calculo da APLI0001.pc_calc_saldo_rpp
        vr_percenir:= GENE0002.fn_char_para_number(TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                                             ,pr_nmsistem => 'CRED'
                                                                             ,pr_tptabela => 'CONFIG'
                                                                             ,pr_cdempres => 0
                                                                             ,pr_cdacesso => 'PERCIRAPLI'
                                                                             ,pr_tpregist => 0));

        --Verificar as faixas de IR
        APLI0001.pc_busca_faixa_ir_rdca (pr_cdcooper => pr_cdcooper);

        --Buscar a quantidade de faixas de ir
        vr_qtdfaxir:= APLI0001.vr_faixa_ir_rdca.Count;

        --Carregar tabela de memoria de taxas
        --Selecionar os tipos de registro da tabela generica
        FOR rw_craptab IN cr_craptab_taxas(pr_cdcooper => pr_cdcooper
                                          ,pr_nmsistem => 'CRED'
                                          ,pr_tptabela => 'GENERI'
                                          ,pr_cdempres => 0
                                          ,pr_cdacesso => 'SOMAPLTAXA'
                                          ,pr_dstextab => 'SIM') LOOP
          --Atribuir valor para tabela memoria
          vr_tab_tpregist(rw_craptab.tpregist):= rw_craptab.tpregist;
        END LOOP;

        -- Carregar tabela de memoria de lancamentos na poupanca
        FOR rw_craplpp IN cr_craplpp (pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_dtmvtolt => pr_dtmvtolt - 180) LOOP

          IF rw_craplpp.qtlancmto > 3 THEN
            -- Montar indice para acessar tabela
            vr_index_craplpp := LPad(rw_craplpp.nrdconta,10,'0')||LPad(rw_craplpp.nrctrrpp,10,'0');

            -- Atribuir quantidade encontrada de cada conta ao vetor
            vr_tab_craplpp(vr_index_craplpp) := rw_craplpp.qtlancmto;
          END IF;
        END LOOP;

        --Carregar tabela de memoria com total de resgates na poupanca
        FOR rw_craplrg IN cr_craplrg_saque (pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta) LOOP
          --Montar Indice para acesso quantidade lancamentos de resgate
          vr_index_craplrg:= LPad(rw_craplrg.nrdconta,10,'0')||LPad(rw_craplrg.nraplica,10,'0');
          --Popular tabela de memoria
          vr_tab_craplrg(vr_index_craplrg):= rw_craplrg.qtlancmto;
        END LOOP;

        --Carregar tabela de memória com total resgatado por conta e aplicacao
        FOR rw_craplrg IN cr_craplrg (pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_dtresgat => vr_dtmvtopr) LOOP

          --Montar indice para selecionar total dos resgates na tabela auxiliar
          vr_index_resgate:= LPad(rw_craplrg.nrdconta,10,'0')||
                             LPad(rw_craplrg.tpaplica,05,'0')||
                             LPad(rw_craplrg.nraplica,10,'0');
          --Popular a tabela de memoria com a soma dos lancamentos de resgate
          vr_tab_resgate(vr_index_resgate).tpresgat := rw_craplrg.tpresgat;
          vr_tab_resgate(vr_index_resgate).vllanmto := rw_craplrg.vllanmto;
        END LOOP;

        --Selecionar informacoes da data de inicio e fim da taxa para calculo da APLI0001.pc_provisao_rdc_pos
        vr_dstextab_rdcpos:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                       ,pr_nmsistem => 'CRED'
                                                       ,pr_tptabela => 'USUARI'
                                                       ,pr_cdempres => 11
                                                       ,pr_cdacesso => 'MXRENDIPOS'
                                                       ,pr_tpregist => 1);
        -- Se não encontrar
        IF vr_dstextab_rdcpos IS NULL THEN
          -- Utilizar datas padrão
          vr_dtinitax := to_date('01/01/9999','dd/mm/yyyy');
          vr_dtfimtax := to_date('01/01/9999','dd/mm/yyyy');
        ELSE
          --Atribuir as datas encontradas
          vr_dtinitax := to_date(gene0002.fn_busca_entrada(1, vr_dstextab_rdcpos, ';'), 'DD/MM/RRRR');
          vr_dtfimtax := to_date(gene0002.fn_busca_entrada(2, vr_dstextab_rdcpos, ';'), 'DD/MM/RRRR');
        END IF;

        apli0001.pc_acumula_aplicacoes(pr_cdcooper => pr_cdcooper
                                      ,pr_cdoperad => pr_cdoperad
                                      ,pr_cdprogra => pr_nmdatela
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nraplica => 0
                                      ,pr_tpaplica => 3
                                      ,pr_vlaplica => 0
                                      ,pr_cdperapl => 0
                                      ,pr_percenir => vr_percenir
                                      ,pr_qtdfaxir => vr_qtdfaxir
                                      ,pr_tab_tpregist => vr_tab_tpregist
                                      ,pr_tab_craptab => vr_tab_conta_bloq
                                      ,pr_tab_craplpp => vr_tab_craplpp
                                      ,pr_tab_craplrg => vr_tab_craplrg
                                      ,pr_tab_resgate => vr_tab_resgate
                                      ,pr_tab_crapdat => rw_crapdat
                                      ,pr_cdagenci_assoc => rw_crapass.cdagenci
                                      ,pr_nrdconta_assoc => rw_crapass.nrdconta
                                      ,pr_dtinitax => vr_dtinitax
                                      ,pr_dtfimtax => vr_dtfimtax
                                      ,pr_vlsdrdca => vr_vltotrda
                                      ,pr_txaplica => vr_txaplica
                                      ,pr_txaplmes => vr_txaplmes
                                      ,pr_retorno => vr_retorno
                                      ,pr_tab_acumula => vr_tab_acumula
                                      ,pr_tab_erro => vr_tab_erro);
        IF vr_retorno = 'NOK' THEN
          -- Tenta buscar o erro no vetor de erro
          IF vr_tab_erro.COUNT > 0 THEN
           vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
           vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '|| rw_crapass.nrdconta;
          ELSE
            vr_cdcritic:= 0;
            vr_dscritic := 'Retorno "NOK" na APLI0005.pc_cadastra_aplic e sem informacao na pr_tab_erro, Conta: '||rw_crapass.nrdconta||' Aplica: 0';
          END IF;
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;

      END IF;

      -- Saldo acumulado para aplicacao
      vr_vltotrda := NVL(vr_vltotrda,0) + NVL(pr_vlaplica,0);

      -- Consulta de nomenclatura
      OPEN cr_crapnpc(pr_cdprodut => pr_cdprodut
                     ,pr_qtdiacar => pr_qtdiacar
                     ,pr_vlsldacu => vr_vltotrda);

      FETCH cr_crapnpc INTO rw_crapnpc;

      -- Verifica se encontrou registro
      IF cr_crapnpc%NOTFOUND THEN
        CLOSE cr_crapnpc;
        vr_cdnomenc := '0';
      ELSE
        CLOSE cr_crapnpc;
        vr_cdnomenc := rw_crapnpc.cdnomenc;
      END IF;

      -- Consulta de modalidade do produto
      OPEN cr_crapmpc(pr_cdprodut => pr_cdprodut
                     ,pr_qtdiacar => pr_qtdiacar
                     ,pr_qtdiaprz => pr_qtdiaprz
                     ,pr_vlsldacu => vr_vltotrda);

      FETCH cr_crapmpc INTO rw_crapmpc;

      -- Verifica se encontrou registro
      IF cr_crapmpc%NOTFOUND THEN
        CLOSE cr_crapmpc;

        -- Caso nao encontre, gera critica
        vr_dscritic := 'Nao foi encontrada modalidade na política de captacao para o produto selecionado.';
        RAISE vr_exc_saida;
      ELSE
        -- Caso encontre, somente fecha o cursor
        CLOSE cr_crapmpc;
      END IF;

      -- Verifica valor da aplicacao foi retirado da conta investimento
      IF pr_iddebcti = 1 THEN

        -- Verifica se ha saldo suficiente
        OPEN cr_crapsli(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_dtrefere => last_day(pr_dtmvtolt));         
        FETCH cr_crapsli INTO rw_crapsli;
        -- Verifica se consulta retornou registros
        IF cr_crapsli%NOTFOUND THEN
          CLOSE cr_crapsli;
          vr_dscritic := 'Registro de saldo nao encontrado';
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_crapsli;
        END IF;

        -- Verifica se existe saldo disponivel
        IF rw_crapsli.vlsddisp < pr_vlaplica THEN
          vr_dscritic := 'Saldo insuficiente';
          RAISE vr_exc_saida;
        END IF;

      END IF;

      LOOP
        -- Verifica qual o proximo valor da sequence
        vr_nraplica := fn_sequence(pr_nmtabela => 'CRAPRAC'
                                  ,pr_nmdcampo => 'NRAPLICA'
                                  ,pr_dsdchave => pr_cdcooper || ';' || pr_nrdconta
                                  ,pr_flgdecre => 'N');

        /* Consulta CRAPRDA para nao existir aplicacoes com o mesmo numero mesmo
        sendo produto antigo e novo */

        OPEN cr_craprda(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nraplica => vr_nraplica);

        FETCH cr_craprda INTO rw_craprda;

        IF cr_craprda%FOUND THEN
          CLOSE cr_craprda;
          CONTINUE;
        ELSE
          CLOSE cr_craprda;
          EXIT;
        END IF;

      END LOOP;

      -- Verifica se taxa é fixa
      IF rw_crapcpc.idtxfixa = 1 THEN
        vr_txaplica := rw_crapmpc.vltxfixa;
      ELSE
        vr_txaplica := rw_crapmpc.vlperren;
      END IF;

      -- Insercao do registro de aplicacao
      BEGIN
        INSERT INTO craprac(
          cdcooper
         ,nrdconta
         ,nraplica
         ,cdprodut
         ,cdnomenc
         ,dtmvtolt
         ,dtvencto
         ,dtatlsld
         ,vlaplica
         ,vlbasapl
         ,vlsldatl
         ,vlslfmes
         ,vlsldacu
         ,qtdiacar
         ,qtdiaprz
         ,qtdiaapl
         ,txaplica
         ,idsaqtot
         ,idblqrgt
         ,idcalorc
         ,nrctrrpp
         ,iddebcti
         ,cdoperad)
        VALUES(
          pr_cdcooper
         ,pr_nrdconta
         ,vr_nraplica
         ,pr_cdprodut
         ,vr_cdnomenc
         ,pr_dtmvtolt
         ,pr_dtvencto
         ,pr_dtmvtolt
         ,pr_vlaplica
         ,pr_vlaplica
         ,pr_vlaplica
         ,pr_vlaplica
         ,vr_vltotrda -- Saldo acumulado
         ,pr_qtdiacar
         ,pr_qtdiaprz
         ,pr_qtdiaapl
         ,vr_txaplica
         ,0           -- Saque Total
         ,0           -- Bloqueio Resgate
         ,0           -- Cálculo Orçamento
         ,pr_nrctrrpp -- Número da aplicação programada
         ,pr_iddebcti
         ,pr_cdoperad) RETURNING nraplica, ROWID INTO vr_nraplica, vr_rowidtab;

      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir registro na CRAPRAC.';
          RAISE vr_exc_saida;
      END;

      pr_nraplica := vr_nraplica;

      -- Consulta primeiro indice da tabela
      vr_index_acumula := vr_tab_acumula.first;

      WHILE vr_index_acumula is not null LOOP

        vr_tpaplacu := UPPER(vr_tab_acumula(vr_index_acumula).tpaplica);

        -- Insert na CRAPCAP
        BEGIN
          INSERT INTO crapcap(
            cdcooper
           ,nrdconta
           ,nraplica
           ,nraplacu
           ,tpaplacu
           ,vlsddapl)
          VALUES(
            pr_cdcooper
           ,pr_nrdconta
           ,vr_nraplica
           ,vr_tab_acumula(vr_index_acumula).nraplica
           ,DECODE(vr_tpaplacu,'PCAPTA',0,'RDCA',3,'RPP',2,'RDCA60',5,'RDCPRE',7,'RDCPOS',8,0)
           ,vr_tab_acumula(vr_index_acumula).vlsdrdca
          );

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir registro na CRAPCAP.';
            RAISE vr_exc_saida;
        END;

        -- Consulta proximo indice
        vr_index_acumula := vr_tab_acumula.next(vr_index_acumula);

      END LOOP;

      OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                     ,pr_dtmvtolt => pr_dtmvtolt
                     ,pr_cdagenci => 1
                     ,pr_cdbccxlt => 100
                     ,pr_nrdolote => 8500);

      FETCH cr_craplot INTO rw_craplot;

      IF cr_craplot%NOTFOUND THEN
        CLOSE cr_craplot;
        BEGIN
          INSERT INTO
            craplot(
              cdcooper
             ,dtmvtolt
             ,cdagenci
             ,cdbccxlt
             ,nrdolote
             ,tplotmov
             ,nrseqdig
             ,qtinfoln
             ,qtcompln
             ,vlinfocr
             ,vlcompcr)
          VALUES(
            pr_cdcooper
           ,pr_dtmvtolt
           ,1
           ,100
           ,8500
           ,9
           ,1
           ,1
           ,1
           ,pr_vlaplica
           ,pr_vlaplica)
          RETURNING
            craplot.dtmvtolt
           ,craplot.cdagenci
           ,craplot.cdbccxlt
           ,craplot.nrdolote
           ,craplot.nrseqdig
          INTO
            rw_craplot.dtmvtolt
           ,rw_craplot.cdagenci
           ,rw_craplot.cdbccxlt
           ,rw_craplot.nrdolote
           ,rw_craplot.nrseqdig;

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir registro na CRAPLOT.';
            RAISE vr_exc_saida;
        END;
      ELSE
        CLOSE cr_craplot;

        BEGIN

          UPDATE
            craplot
          SET
            craplot.tplotmov = 9,
            craplot.nrseqdig = rw_craplot.nrseqdig + 1,
            craplot.qtinfoln = rw_craplot.qtinfoln + 1,
            craplot.qtcompln = rw_craplot.qtcompln + 1,
            craplot.vlinfocr = rw_craplot.vlinfocr + pr_vlaplica,
            craplot.vlcompcr = rw_craplot.vlcompcr + pr_vlaplica
          WHERE
            craplot.rowid = rw_craplot.rowid
          RETURNING
            craplot.dtmvtolt
           ,craplot.cdagenci
           ,craplot.cdbccxlt
           ,craplot.nrdolote
           ,craplot.nrseqdig
          INTO
            rw_craplot.dtmvtolt
           ,rw_craplot.cdagenci
           ,rw_craplot.cdbccxlt
           ,rw_craplot.nrdolote
           ,rw_craplot.nrseqdig;

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar registro na CRAPLOT.';
            RAISE vr_exc_saida;
        END;
      END IF;

      IF pr_idorirec = 0 THEN -- Recurso  Aplicação
        vr_cdhistor := rw_crapcpc.cdhsraap;
      ELSE
        vr_cdhistor := rw_crapcpc.cdhsnrap;
      END IF;

      -- Insercao de registros de Lancamento de aplicacao da captacao
      BEGIN
        INSERT INTO
          craplac(
            cdcooper
           ,dtmvtolt
           ,cdagenci
           ,cdbccxlt
           ,nrdolote
           ,nrdconta
           ,nraplica
           ,nrdocmto
           ,nrseqdig
           ,vllanmto
           ,cdhistor
        )VALUES(
           pr_cdcooper
          ,rw_craplot.dtmvtolt
          ,rw_craplot.cdagenci
          ,rw_craplot.cdbccxlt
          ,rw_craplot.nrdolote
          ,pr_nrdconta
          ,vr_nraplica
          ,rw_craplot.nrseqdig
          ,rw_craplot.nrseqdig
          ,pr_vlaplica
          ,vr_cdhistor);

      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar registro na CRAPLAC.';
          RAISE vr_exc_saida;
      END;
      IF pr_iddebcti = 1 THEN -- Recurso da Conta Investimento

        OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 9900010106);

        FETCH cr_craplot INTO rw_craplot;

        IF cr_craplot%NOTFOUND THEN
          CLOSE cr_craplot;
          BEGIN
            INSERT INTO
              craplot(
                cdcooper
               ,dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,tplotmov
               ,nrseqdig
               ,qtinfoln
               ,qtcompln
               ,vlinfodb
               ,vlcompdb)
            VALUES(
              pr_cdcooper
             ,pr_dtmvtolt
             ,1
             ,100
             ,9900010106 --10106
             ,29
             ,1
             ,1
             ,1
             ,pr_vlaplica
             ,pr_vlaplica)
            RETURNING
              craplot.dtmvtolt
             ,craplot.cdagenci
             ,craplot.cdbccxlt
             ,craplot.nrdolote
             ,craplot.nrseqdig
            INTO
              rw_craplot.dtmvtolt
             ,rw_craplot.cdagenci
             ,rw_craplot.cdbccxlt
             ,rw_craplot.nrdolote
             ,rw_craplot.nrseqdig;

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir registro na CRAPLOT.';
              RAISE vr_exc_saida;
          END;
        ELSE
          CLOSE cr_craplot;

          BEGIN

            UPDATE
              craplot
            SET
              craplot.tplotmov = 29,
              craplot.nrseqdig = rw_craplot.nrseqdig + 1,
              craplot.qtinfoln = rw_craplot.qtinfoln + 1,
              craplot.qtcompln = rw_craplot.qtcompln + 1,
              craplot.vlinfodb = rw_craplot.vlinfodb + pr_vlaplica,
              craplot.vlcompdb = rw_craplot.vlcompdb + pr_vlaplica
            WHERE
              craplot.rowid = rw_craplot.rowid
            RETURNING
              craplot.dtmvtolt
             ,craplot.cdagenci
             ,craplot.cdbccxlt
             ,craplot.nrdolote
             ,craplot.nrseqdig
            INTO
              rw_craplot.dtmvtolt
             ,rw_craplot.cdagenci
             ,rw_craplot.cdbccxlt
             ,rw_craplot.nrdolote
             ,rw_craplot.nrseqdig;

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar registro na CRAPLOT.';
              RAISE vr_exc_saida;
          END;
        END IF;

        -- Insere registro de Lancamento da conta investimento
        BEGIN
          INSERT INTO
            craplci(
              cdcooper
             ,dtmvtolt
             ,cdagenci
             ,cdbccxlt
             ,nrdolote
             ,nrdconta
             ,nrdocmto
             ,nrseqdig
             ,vllanmto
             ,cdhistor
             ,nraplica
           )VALUES(
              pr_cdcooper
             ,rw_craplot.dtmvtolt
             ,rw_craplot.cdagenci
             ,rw_craplot.cdbccxlt
             ,rw_craplot.nrdolote
             ,pr_nrdconta
             ,vr_nraplica
             ,rw_craplot.nrseqdig
             ,pr_vlaplica
             ,491
             ,vr_nraplica);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir registro na CRAPLCI.';
            RAISE vr_exc_saida;
        END;

        -- Verifica se existe registro de lancamento na conta investimento
        OPEN cr_crapsli(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_dtrefere => rw_crapdat.dtultdia);

        FETCH cr_crapsli INTO rw_crapsli;

        -- Verifica se registro de lancamento de conta investimento existe
        IF cr_crapsli%NOTFOUND THEN
          -- Fecha cursor
          CLOSE cr_crapsli;

          -- Inserir registro de saldo da conta investimento
          BEGIN

            INSERT INTO
              crapsli(
                cdcooper
               ,nrdconta
               ,dtrefere
               ,vlsddisp
              ) VALUES(
                pr_cdcooper
               ,pr_nrdconta
               ,rw_crapdat.dtultdia
               ,pr_vlaplica);

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir registro na CRAPSLI.';
              RAISE vr_exc_saida;
          END;

        ELSE
          -- Fecha cursor
          CLOSE cr_crapsli;

          -- Atualiza registro de saldo na conta investimento
          BEGIN

            UPDATE
              crapsli
            SET
              vlsddisp = rw_crapsli.vlsddisp - pr_vlaplica
            WHERE
              crapsli.rowid = rw_crapsli.rowid;

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir registro na CRAPSLI.';
              RAISE vr_exc_saida;
          END;
        END IF;

      ELSE -- Recurso nao proveniente de conta investimento

        -- Débito
        -- Consulta de lote de débito
        OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 9900010104);

        FETCH cr_craplot INTO rw_craplot;

        -- Verifica se registro de lote para debito existe
        IF cr_craplot%NOTFOUND THEN
          -- Fecha cursor
          CLOSE cr_craplot;
          -- Inseri registro de lote para debito
          BEGIN
            INSERT INTO
              craplot(
                cdcooper
               ,dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,tplotmov
               ,nrseqdig
               ,qtinfoln
               ,qtcompln
               ,vlinfodb
               ,vlcompdb) VALUES(
                pr_cdcooper
               ,pr_dtmvtolt
               ,1
               ,100
               ,9900010104 --10104
               ,29
               ,1
               ,1
               ,1
               ,pr_vlaplica
               ,pr_vlaplica) RETURNING
               craplot.dtmvtolt
              ,craplot.cdagenci
              ,craplot.cdbccxlt
              ,craplot.nrdolote
              ,craplot.nrseqdig
              ,craplot.rowid
             INTO
               rw_craplot.dtmvtolt
              ,rw_craplot.cdagenci
              ,rw_craplot.cdbccxlt
              ,rw_craplot.nrdolote
              ,rw_craplot.nrseqdig
              ,rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir registro na CRAPLOT.';
              RAISE vr_exc_saida;
          END;
        ELSE
          -- Fecha cursor
          CLOSE cr_craplot;
          -- Atualiza registro de lote para debito
          BEGIN
            UPDATE
              craplot
            SET
              craplot.tplotmov = 29
             ,craplot.nrseqdig = rw_craplot.nrseqdig + 1
             ,craplot.qtinfoln = rw_craplot.qtinfoln + 1
             ,craplot.qtcompln = rw_craplot.qtcompln + 1
             ,craplot.vlinfodb = rw_craplot.vlinfodb + pr_vlaplica
             ,craplot.vlcompdb = rw_craplot.vlcompdb + pr_vlaplica
            WHERE
              craplot.rowid = rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar registro na CRAPLOT.';
              RAISE vr_exc_saida;
          END;
        END IF;

        -- Inseri registro de lancamento na conta investimento
        BEGIN
          INSERT INTO
            craplci(
              cdcooper
             ,dtmvtolt
             ,cdagenci
             ,cdbccxlt
             ,nrdolote
             ,nrdconta
             ,nrdocmto
             ,nrseqdig
             ,vllanmto
             ,cdhistor
             ,nraplica)
          VALUES(
            pr_cdcooper
           ,pr_dtmvtolt
           ,rw_craplot.cdagenci
           ,rw_craplot.cdbccxlt
           ,rw_craplot.nrdolote
           ,pr_nrdconta
           ,vr_nraplica
           ,rw_craplot.nrseqdig
           ,pr_vlaplica
           ,488
           ,vr_nraplica);

        EXCEPTION

          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir registro de lancamento CRAPLCI.';
            RAISE vr_exc_saida;
        END;
        -- Fim DÉBITo

        -- CRÉDITO
        -- Consulta de lote de credito
        OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 9900010105);

        FETCH cr_craplot INTO rw_craplot;

        -- Verifica se registro de lote para credito existe
        IF cr_craplot%NOTFOUND THEN
          -- Fecha cursor
          CLOSE cr_craplot;
          -- Inseri registro de lote para credito
          BEGIN
            INSERT INTO
              craplot(
                cdcooper
               ,dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,tplotmov
               ,nrseqdig
               ,qtinfoln
               ,qtcompln
               ,vlinfocr
               ,vlcompcr) VALUES(
                pr_cdcooper
               ,pr_dtmvtolt
               ,1
               ,100
               ,9900010105 --10105
               ,29
               ,1
               ,1
               ,1
               ,pr_vlaplica
               ,pr_vlaplica) RETURNING
               craplot.dtmvtolt
              ,craplot.cdagenci
              ,craplot.cdbccxlt
              ,craplot.nrdolote
              ,craplot.nrseqdig
              ,craplot.rowid
             INTO
               rw_craplot.dtmvtolt
              ,rw_craplot.cdagenci
              ,rw_craplot.cdbccxlt
              ,rw_craplot.nrdolote
              ,rw_craplot.nrseqdig
              ,rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir registro na CRAPLOT. ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        ELSE
          -- Fecha cursor
          CLOSE cr_craplot;
          -- Atualiza registro de lote para credito
          BEGIN
            UPDATE
              craplot
            SET
              craplot.tplotmov = 29
             ,craplot.nrseqdig = rw_craplot.nrseqdig + 1
             ,craplot.qtinfoln = rw_craplot.qtinfoln + 1
             ,craplot.qtcompln = rw_craplot.qtcompln + 1
             ,craplot.vlinfocr = rw_craplot.vlinfocr + pr_vlaplica
             ,craplot.vlcompcr = rw_craplot.vlcompcr + pr_vlaplica
            WHERE
              craplot.rowid = rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar registro na CRAPLOT.';
              RAISE vr_exc_saida;
          END;
        END IF;

        -- Verifica o tipo de historico para credito
        IF pr_idorirec = 0 THEN -- Recurso Renovação Aplicação
          vr_cdhistor := rw_crapcpc.cdhsraap;
        ELSE
          vr_cdhistor := rw_crapcpc.cdhsnrap;
        END IF;

        -- Inseri registro de lancamento na conta investimento
        BEGIN
          INSERT INTO
            craplci(
              cdcooper
             ,dtmvtolt
             ,cdagenci
             ,cdbccxlt
             ,nrdolote
             ,nrdconta
             ,nrdocmto
             ,nrseqdig
             ,vllanmto
             ,cdhistor
             ,nraplica)
          VALUES(
            pr_cdcooper
           ,pr_dtmvtolt
           ,rw_craplot.cdagenci
           ,rw_craplot.cdbccxlt
           ,rw_craplot.nrdolote
           ,pr_nrdconta
           ,vr_nraplica
           ,rw_craplot.nrseqdig
           ,pr_vlaplica
           ,vr_cdhistor
           ,vr_nraplica);

        EXCEPTION

          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir registro de lancamento CRAPLCI.';
            RAISE vr_exc_saida;
        END;

        -- Fim CRÉDITO
           LANC0001.pc_gerar_lancamento_conta(
                          pr_cdcooper => pr_cdcooper
                         ,pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => rw_craplot.cdagenci
                       ,pr_cdbccxlt => rw_craplot.cdbccxlt
                       ,pr_nrdolote => rw_craplot.nrdolote
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrdctabb => pr_nrdconta
                         ,pr_nrdocmto => vr_nraplica
                         ,pr_nrseqdig => 0
                         ,pr_dtrefere => pr_dtmvtolt
                         ,pr_vllanmto => pr_vlaplica
                         ,pr_cdhistor => rw_crapcpc.cdhscacc
                         ,pr_nraplica => vr_nraplica
                         -- OUTPUT --
                         ,pr_tab_retorno => vr_tab_retorno
                         ,pr_incrineg => vr_incrineg
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);

            IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
             vr_dscritic := 'Erro ao inserir registro de lancamento de debito.';
               RAISE vr_exc_saida;
            END IF;
      END IF; -- Fim ELSE recurso nao proveniente de conta investimento

      -- Geracao de comprovante

      IF rw_crapass.inpessoa = 1 THEN

        /* Nome do titular que fez a aplicacao */
        OPEN cr_crapttl (pr_cdcooper => rw_crapass.cdcooper
                        ,pr_nrdconta => rw_crapass.nrdconta
                        ,pr_idseqttl => pr_idseqttl);

        --Posicionar no proximo registro
        FETCH cr_crapttl INTO rw_crapttl;

        --Se nao encontrar
        IF cr_crapttl%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapttl;

          vr_cdcritic:= 0;
          vr_dscritic:= 'Titular nao encontrado.';

          -- Gera exceção
          RAISE vr_exc_saida;
        END IF;

        -- Fechar Cursor
        CLOSE cr_crapttl;

        -- Nome titular
        vr_nmextttl:= rw_crapttl.nmextttl;

      ELSE
        vr_nmextttl:= rw_crapass.nmprimtl;
      END IF;

      -- Busca a cidade do PA do associado
      OPEN cr_crapage(pr_cdcooper => rw_crapass.cdcooper
                     ,pr_cdagenci => rw_crapass.cdagenci);

      FETCH cr_crapage INTO vr_nmcidade;

      IF cr_crapage%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapage;

        vr_cdcritic:= 962;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

        -- Gera exceção
        RAISE vr_exc_saida;
      ELSE
        -- Fechar o cursor
        CLOSE cr_crapage;

      END IF;

      vr_dsinfor1:= 'Aplicacao';

      vr_dsinfor2:= vr_nmextttl ||'#' ||
                    'Conta/dv: ' ||pr_nrdconta ||' - '||
                    rw_crapass.nmprimtl||'#'|| gene0002.fn_mask(rw_crapcop.cdagectl,'9999')||
                    ' - '|| rw_crapcop.nmrescop;

      vr_dsinfor3:= 'Data da Aplicacao: '   || TO_CHAR(pr_dtmvtolt,'dd/mm/RRRR')           || '#' ||
                    'Numero da Aplicacao: ' || TO_CHAR(vr_nraplica,'9G999G990')    || '#';

      -- Verifica se taxa é fixa
      IF rw_crapcpc.idtxfixa = 1 THEN
        vr_dsinfor3:= vr_dsinfor3 || 'Taxa Contratada: ' || rw_crapcpc.nmdindex || ' + ' || TO_CHAR(NVL(vr_txaplica, '0'), 'fm990D00') || '%#' ||
                      'Taxa Minima: ' || rw_crapcpc.nmdindex || ' + ' || TO_CHAR(NVL(vr_txaplica, '0'), 'fm990D00') || '%#';
      ELSE
        vr_dsinfor3:= vr_dsinfor3 || 'Taxa Contratada: ' || TO_CHAR(NVL(vr_txaplica, '0'), 'fm990D00') || '% DO ' || rw_crapcpc.nmdindex || '#' ||
                      'Taxa Minima: ' || TO_CHAR(NVL(vr_txaplica, '0'), 'fm990D00') || '% DO ' || rw_crapcpc.nmdindex || '#';
      END IF;

      vr_dsinfor3:= vr_dsinfor3 || 'Vencimento: '          || TO_CHAR(pr_dtvencto,'dd/mm/yyyy')           || '#' ||
                                   'Carencia: '            || TO_CHAR(pr_qtdiacar,'99990') || ' DIA(S)'   || '#' ||
                                   'Data da Carencia: '    || TO_CHAR(pr_dtmvtolt + pr_qtdiacar,'dd/mm/RRRR') || '#' ||
                                   'Cooperativa: '         || UPPER(rw_crapcop.nmextcop) || '#' ||
                                   'CNPJ: '                || TO_CHAR(gene0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj,2)) || '#' ||
                                   UPPER(TRIM(vr_nmcidade)) || ', ' || TO_CHAR(pr_dtmvtolt,'dd') || ' DE ' ||
                                   GENE0001.vr_vet_nmmesano(TO_CHAR(pr_dtmvtolt,'mm')) || ' DE ' ||
                                   TO_CHAR(pr_dtmvtolt,'RRRR') || '#N#' || UPPER(nvl(rw_crapnpc.dsnomenc,rw_crapcpc.nmprodut));

      --Gerar protocolo
      GENE0006.pc_gera_protocolo(pr_cdcooper => pr_cdcooper                         --> Código da cooperativa
                                ,pr_dtmvtolt => pr_dtmvtolt                         --> Data movimento
                                ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS')) --> Hora da transação NOK
                                ,pr_nrdconta => pr_nrdconta                         --> Número da conta
                                ,pr_nrdocmto => vr_nraplica                         --> Número do documento
                                ,pr_nrseqaut => 0                                   --> Número da sequencia
                                ,pr_vllanmto => pr_vlaplica                         --> Valor lançamento
                                ,pr_nrdcaixa => pr_nrdcaixa                                   --> Número do caixa NOK
                                ,pr_gravapro => TRUE                                --> Controle de gravação
                                ,pr_cdtippro => 10                                  --> Código de operação
                                ,pr_dsinfor1 => vr_dsinfor1                         --> Descrição 1
                                ,pr_dsinfor2 => vr_dsinfor2                         --> Descrição 2
                                ,pr_dsinfor3 => vr_dsinfor3                         --> Descrição 3
                                ,pr_dscedent => NULL                                --> Descritivo
                                ,pr_flgagend => FALSE                               --> Controle de agenda
                                ,pr_nrcpfope => 0                                   --> Número de operação
                                ,pr_nrcpfpre => 0                                   --> Número pré operação
                                ,pr_nmprepos => ''                                  --> Nome
                                ,pr_dsprotoc => vr_dsprotoc                         --> Descrição do protocolo
                                ,pr_dscritic => vr_dscritic                         --> Descrição crítica
                                ,pr_des_erro => vr_des_erro);                       --> Descrição dos erros de processo

      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL OR vr_des_erro IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;

      -- Fim geracao de comprovante

      -- Verifica se deve gerar log
      IF pr_idgerlog = 1 THEN
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'NRAPLICA'
                                   ,pr_dsdadant => ''
                                   ,pr_dsdadatu => vr_nraplica);

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'NRDOCMTO'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => vr_nraplica);

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'DTRESGAT'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => TO_CHAR(pr_dtvencto,'dd/MM/RRRR'));

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'VLAPLICA'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_vlaplica);

      END IF;

      /* Comitar apenas se não for via batch */
      IF upper(pr_nmdatela) <> 'CRPS145' THEN
      COMMIT;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        /* Desfazer apenas se não for via batch */
        IF upper(pr_nmdatela) <> 'CRPS145' THEN
        ROLLBACK;
        END IF;

        -- Verifica se deve gerar log
        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => ''
                              ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                              ,pr_dstransa => vr_dstransa || pr_dscritic
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 1 --> TRUE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
          /* Comitar apenas se não for via batch */
          IF upper(pr_nmdatela) <> 'CRPS145' THEN
          COMMIT;
        END IF;
        END IF;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em APLI0005.pc_cadastra_aplic: ' || SQLERRM;

        -- Verifica se deve gerar log
        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => ''
                              ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                              ,pr_dstransa => vr_dstransa || pr_dscritic
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 1 --> TRUE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);

          /* Comitar apenas se não for via batch */
          IF upper(pr_nmdatela) <> 'CRPS145' THEN
          COMMIT;
        END IF;
        END IF;
    END;

  END pc_cadastra_aplic;

  -- Rotina de cadastro de aplicacoes via WEB
  PROCEDURE pc_cadastra_aplic_web(pr_nrdconta IN craprac.nrdconta%TYPE --> Número da Conta
                                 ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Titular da Conta
                                 ,pr_dtmvtolt IN VARCHAR2              --> Data de Movimento
                                 ,pr_cdprodut IN crapcpc.cdprodut%TYPE --> Código do Produto
                                 ,pr_qtdiaapl IN INTEGER               --> Dias da Aplicação
                                 ,pr_dtvencto IN VARCHAR2              --> Data de Vencimento da Aplicação
                                 ,pr_qtdiacar IN INTEGER               --> Carência da Aplicação
                                 ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE --> Prazo da Aplicação (Prazo selecionado na tela)
                                 ,pr_vlaplica IN craprac.vlaplica%TYPE --> Valor da Aplicação (Valor informado em tela)
                                 ,pr_iddebcti IN INTEGER               --> Identificador de Débito na Conta Investimento (Identificador informado em tela)
                                 ,pr_idorirec IN INTEGER               --> Identificador de Origem do Recurso (Identificador informado em tela)
                                 ,pr_idgerlog IN INTEGER               --> Identificador de Log (Fixo no código, 0 – Não / 1 - Sim)
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN

    /* .............................................................................

     Programa: pc_cadastro_aplic_web
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Agosto/14.                    Ultima atualizacao: 04/08/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente ao cadastro de aplicacoes via web.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/

    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis locais
      vr_dtmvtolt DATE;
      vr_dtvencto DATE;
      vr_nraplica craprac.nraplica%TYPE := 0;

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

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
        RAISE vr_exc_saida;
      END IF;

      vr_dtmvtolt := TO_DATE(pr_dtmvtolt,'dd/mm/RRRR');
      vr_dtvencto := TO_DATE(pr_dtvencto,'dd/mm/RRRR');

      -- Efetua o cadastro de aplicacoes
      APLI0005.pc_cadastra_aplic(pr_cdcooper => vr_cdcooper   -- Código da Cooperativa
                                ,pr_cdoperad => vr_cdoperad   -- Código do Operador
                                ,pr_nmdatela => vr_nmdatela   -- Nome da Tela
                                ,pr_idorigem => vr_idorigem   -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA)
                                ,pr_nrdconta => pr_nrdconta   -- Número da Conta
                                ,pr_idseqttl => pr_idseqttl   -- Titular da Conta
                                ,pr_nrdcaixa => vr_nrdcaixa   -- Numero de caixa
                                ,pr_dtmvtolt => vr_dtmvtolt   -- Data de Movimento
                                ,pr_cdprodut => pr_cdprodut   -- Código do Produto (Produto selecionado na tela)
                                ,pr_qtdiaapl => pr_qtdiaapl   -- Dias da Aplicação (Dias informados em tela)
                                ,pr_dtvencto => vr_dtvencto   -- Data de Vencimento da Aplicação (Data informada em tela)
                                ,pr_qtdiacar => pr_qtdiacar   -- Carência da Aplicação (Carência informada em tela)
                                ,pr_qtdiaprz => pr_qtdiaprz   -- Prazo da Aplicação (Prazo selecionado na tela)
                                ,pr_vlaplica => pr_vlaplica   -- Valor da Aplicação (Valor informado em tela)
                                ,pr_iddebcti => pr_iddebcti   -- Identificador de Débito na Conta Investimento (Identificador informado na tela, 0 – Não / 1 - Sim)
                                ,pr_idorirec => pr_idorirec   -- Identificador de Origem do Recurso (Identificador informado em tela)
                                ,pr_idgerlog => pr_idgerlog   -- Identificador de Log (Fixo no código, 0 – Não / 1 – Sim)
                                ,pr_nraplica => vr_nraplica   -- Numero da aplicacao cadastrada
                                ,pr_cdcritic => vr_cdcritic   -- Codigo da critica de erro
                                ,pr_dscritic => vr_dscritic); -- Descricao da critica de erro

      -- Verifica se houve erro recuperando informacoes de log
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Retorna OK para cadastro efetuado com sucesso
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><nraplica>'|| vr_nraplica || '</nraplica></Root>');

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em APLI0005.pc_cadastra_aplic_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_cadastra_aplic_web;

  -- Rotina geral para cadastros de aplicacoes - Autonomous Transaction
  PROCEDURE pc_cadastra_aplic_at(pr_cdcooper IN craprac.cdcooper%TYPE      -- Código da Cooperativa
                             ,pr_cdoperad IN crapope.cdoperad%TYPE      -- Código do Operador
                             ,pr_nmdatela IN craptel.nmdatela%TYPE      -- Nome da Tela
                             ,pr_idorigem IN INTEGER                    -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA)
                             ,pr_nrdconta IN craprac.nrdconta%TYPE      -- Número da Conta
                             ,pr_idseqttl IN crapttl.idseqttl%TYPE      -- Titular da Conta
                             ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE      -- Numero de caixa
                             ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE      -- Data de Movimento
                             ,pr_cdprodut IN crapcpc.cdprodut%TYPE      -- Código do Produto (Produto selecionado na tela)
                             ,pr_qtdiaapl IN INTEGER                    -- Dias da Aplicação (Dias informados em tela)
                             ,pr_dtvencto IN DATE                       -- Data de Vencimento da Aplicação (Data informada em tela)
                             ,pr_qtdiacar IN INTEGER                    -- Carência da Aplicação (Carência informada em tela)
                             ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE      -- Prazo da Aplicação (Prazo selecionado na tela)
                             ,pr_vlaplica IN NUMBER                     -- Valor da Aplicação (Valor informado em tela)
                             ,pr_iddebcti IN INTEGER                    -- Identificador de Débito na Conta Investimento (Identificador informado na tela, 0 – Não / 1 - Sim)
                             ,pr_idorirec IN INTEGER                    -- Identificador de Origem do Recurso (Identificador informado em tela)
                             ,pr_idgerlog IN INTEGER                    -- Identificador de Log (Fixo no código, 0 – Não / 1 – Sim)
                             ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE DEFAULT 0 -- Número aplicação programada (Opcional, 0 = Aplicação Não Programada)
                             ,pr_nraplica OUT craprac.nraplica%TYPE     -- Numero da aplicacao cadastrada
                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE     -- Codigo da critica de erro
                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS -- Descricao da critica de erro
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    /* .............................................................................

     Programa: pc_cadastra_aplic_at
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : CIS Corporate
     Data    : Julho/18.                    Ultima atualizacao: 21/07/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina geral referente ao cadastro de aplicacoes - Autonomous Transaction.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/

    BEGIN
         APLI0005.pc_cadastra_aplic( pr_cdcooper => pr_cdcooper,
                                                 pr_cdoperad => pr_cdoperad,
                                                   pr_nmdatela => pr_nmdatela,
                                                   pr_idorigem => pr_idorigem,
                                                   pr_nrdconta => pr_nrdconta,
                                                   pr_idseqttl => pr_idseqttl,
                                                   pr_nrdcaixa => pr_nrdcaixa,
                                                   pr_dtmvtolt => pr_dtmvtolt,
                                                   pr_cdprodut => pr_cdprodut,
                                                   pr_qtdiaapl => pr_qtdiaapl,
                                                   pr_dtvencto => pr_dtvencto,
                                                   pr_qtdiacar => pr_qtdiacar,
                                                   pr_qtdiaprz => pr_qtdiaprz,
                                                   pr_vlaplica => pr_vlaplica,
                                                   pr_iddebcti => pr_iddebcti,
                                                   pr_idorirec => pr_idorirec,
                                                   pr_idgerlog => pr_idgerlog,
                                                   pr_nrctrrpp => pr_nrctrrpp,
                                                   pr_nraplica => pr_nraplica,
                                                   pr_cdcritic => pr_cdcritic,
                                                   pr_dscritic => pr_dscritic);
    END;
  END pc_cadastra_aplic_at;

  -- Rotina geral para excluir aplicacoes
  PROCEDURE pc_exclui_aplicacao(pr_cdcooper IN craprac.cdcooper%TYPE      -- Código da Cooperativa
                               ,pr_cdoperad IN crapope.cdoperad%TYPE      -- Código do Operador
                               ,pr_nmdatela IN craptel.nmdatela%TYPE      -- Nome da Tela
                               ,pr_idorigem IN INTEGER                    -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA)
                               ,pr_nrdconta IN craprac.nrdconta%TYPE      -- Número da Conta
                               ,pr_idseqttl IN crapttl.idseqttl%TYPE      -- Titular da Conta
                               ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE      -- Numero de caixa
                               ,pr_nraplica IN craprac.nraplica%TYPE      -- Código da aplicacao
                               ,pr_idgerlog IN INTEGER                    -- Identificador de LOG (0-Nao grava / 1-Registrar)
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE     -- Codigo da critica de erro
                               ,pr_dscritic OUT crapcri.dscritic%TYPE) IS -- Descricao da critica de erro
  BEGIN

    /* .............................................................................

     Programa: pc_exclui_aplicacao
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Agosto/14.                    Ultima atualizacao: 12/08/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina geral referente a exclusao de aplicacoes.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/

    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis locais
      vr_dsorigem VARCHAR2(500) := 'AIMARO,CAIXA,INTERNET,TAA,AIMARO WEB,URA';
      vr_dstransa VARCHAR2(100) := 'Exclusao de aplicacao.';
      vr_nrdrowid ROWID;
      vr_dsprotoc crappro.dsprotoc%TYPE := ''; -- Descricao do protocolo

      -- CURSORES --

      -- Selecionar os dados da Cooperativa
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.nrtelura
              ,cop.cdbcoctl
              ,cop.cdagectl
              ,cop.dsdircop
              ,cop.nrctactl
              ,cop.nmextcop
              ,cop.nrdocnpj
        FROM crapcop cop
        WHERE cop.cdcooper = pr_cdcooper
          AND cop.flgativo = 1;

      rw_crapcop cr_crapcop%ROWTYPE;

      --Registro do tipo calendario
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

      CURSOR cr_craprac(pr_cdcooper IN craprac.cdcooper%TYPE
                       ,pr_nrdconta IN craprac.nrdconta%TYPE
                       ,pr_nraplica IN craprac.nraplica%TYPE) IS

        SELECT
          rac.cdcooper
         ,rac.nrdconta
         ,rac.nraplica
         ,rac.vlaplica
         ,rac.iddebcti
         ,rac.dtmvtolt
         ,rac.dtvencto
        FROM
          craprac rac
        WHERE
              rac.cdcooper = pr_cdcooper
          AND rac.nrdconta = pr_nrdconta
          AND rac.nraplica = pr_nraplica;

      rw_craprac cr_craprac%ROWTYPE;

      CURSOR cr_craprda(pr_cdcooper IN craprac.cdcooper%TYPE
                       ,pr_nrdconta IN craprac.nrdconta%TYPE
                       ,pr_nraplica IN craprac.nraplica%TYPE) IS

        SELECT
          rda.cdcooper
         ,rda.nrdconta
         ,rda.nraplica
        FROM
          craprda rda
        WHERE
              rda.cdcooper = pr_cdcooper
          AND rda.nrdconta = pr_nrdconta
          AND rda.nraplica = pr_nraplica;

      rw_craprda cr_craprda%ROWTYPE;

      CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
                       ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                       ,pr_cdagenci IN craplot.cdagenci%TYPE
                       ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                       ,pr_nrdolote IN craplot.nrdolote%TYPE) IS

        SELECT
          lot.cdcooper
         ,lot.qtinfoln
         ,lot.qtcompln
         ,lot.vlinfodb
         ,lot.vlcompdb
         ,lot.vlcompcr
         ,lot.vlinfocr
         ,lot.rowid
        FROM
          craplot lot
        WHERE
              lot.cdcooper = pr_cdcooper
          AND lot.dtmvtolt = pr_dtmvtolt
          AND lot.cdagenci = pr_cdagenci
          AND lot.cdbccxlt = pr_cdbccxlt
          AND lot.nrdolote = pr_nrdolote;

      rw_craplot cr_craplot%ROWTYPE;

    BEGIN

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);

      FETCH cr_crapcop INTO rw_crapcop;

      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        vr_cdcritic:= 651;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Verifica se a cooperativa esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);

      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      -- Consulta aplicacao informada
      OPEN cr_craprac(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nraplica => pr_nraplica);

      FETCH cr_craprac INTO rw_craprac;

      -- Verifica se encontrou registro da aplicacao informada
      IF cr_craprac%NOTFOUND THEN
        CLOSE cr_craprac;

        -- Consulta aplicacao informada
        OPEN cr_craprda(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nraplica => pr_nraplica);

        FETCH cr_craprda INTO rw_craprda;

        -- Verifica se encontrou registro da aplicacao informada
        IF cr_craprda%NOTFOUND THEN
          vr_dscritic := 'Registro de aplicacao na encontrado.';
          CLOSE cr_craprda;
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_craprda;

          apli0002.pc_excluir_nova_aplicacao(pr_cdcooper => pr_cdcooper
                                            ,pr_cdageope => 1
                                            ,pr_nrcxaope => pr_nrdcaixa
                                            ,pr_cdoperad => pr_cdoperad
                                            ,pr_nmdatela => pr_nmdatela
                                            ,pr_idorigem => pr_idorigem
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_idseqttl => pr_idseqttl
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                            ,pr_nraplica => pr_nraplica
                                            ,pr_flgerlog => pr_idgerlog
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

          IF ((vr_dscritic IS NOT NULL AND vr_dscritic <> 'OK') OR
               NVL(vr_cdcritic,0) <> 0)THEN
            RAISE vr_exc_saida;
          END IF;

        END IF;

      ELSE
        CLOSE cr_craprac;

        IF rw_craprac.dtmvtolt <> rw_crapdat.dtmvtolt THEN
          vr_dscritic := 'ATENCAO! So podem ser excluidas aplicacoes feitas na data de HOJE.';
          RAISE vr_exc_saida;
        END IF;

        -- Inicio de tratamento de exclusao do registro de Lancamento de aplicacao da captacao
        BEGIN
          DELETE
            craplac
          WHERE
                craplac.cdcooper = rw_craprac.cdcooper
            AND craplac.nrdconta = rw_craprac.nrdconta
            AND craplac.nraplica = rw_craprac.nraplica;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir registro CRAPLAC. Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Verifica se houve delecao de registro, caso contrario aborta o processo e mostra critica
        IF SQL%ROWCOUNT <= 0 THEN
          -- Descricao da critica que nao houve delecao do registro
          vr_dscritic := 'Registro de exclusao da tabela CRAPLAC nao encontrado.';
          RAISE vr_exc_saida;
        END IF;

        -- Inicio de tratamento de exclusao do registro de Lancamentos da conta investimento
        IF rw_craprac.iddebcti = 1 THEN
          BEGIN
            DELETE
              craplci
            WHERE
                  craplci.cdcooper = rw_craprac.cdcooper
              AND craplci.dtmvtolt = rw_crapdat.dtmvtolt
              AND craplci.cdagenci = 1
              AND craplci.cdbccxlt = 100
              AND craplci.nrdolote = 9900010106
              AND craplci.nrdconta = rw_craprac.nrdconta
              AND craplci.nrdocmto = rw_craprac.nraplica;

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao excluir registro CRAPLCI. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

          -- Verifica se houve delecao de registro, caso contrario aborta o processo e mostra critica
          IF SQL%ROWCOUNT <= 0 THEN
            -- Descricao da critica que nao houve delecao do registro
            vr_dscritic := 'Registro de exclusao da tabela CRAPLCI nao encontrado.';
            RAISE vr_exc_saida;
          END IF;

          -- Atualiza saldo na conta investimento
          BEGIN
            UPDATE
              crapsli
            SET
              crapsli.vlsddisp = crapsli.vlsddisp - rw_craprac.vlaplica
            WHERE
                  crapsli.cdcooper = rw_craprac.cdcooper
              AND crapsli.nrdconta = rw_craprac.nrdconta
              AND crapsli.dtrefere = LAST_DAY(rw_crapdat.dtmvtolt); -- Deve ser o último dia do mês
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar saldo de conta investimento. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

          -- Verifica se houve atualizacao de registro, caso contrario aborta o processo e mostra critica
          IF SQL%ROWCOUNT <= 0 THEN
            -- Descricao da critica que nao houve delecao do registro
            vr_dscritic := 'Registro de exclusao da tabela CRAPSLI nao encontrado.';
            RAISE vr_exc_saida;
          END IF;

          -- Consulta lote
          OPEN cr_craplot(pr_cdcooper => rw_craprac.cdcooper
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         ,pr_cdagenci => 1
                         ,pr_cdbccxlt => 100
                         ,pr_nrdolote => 9900010106);

          FETCH cr_craplot INTO rw_craplot;

          -- Verifica se encontrou registro de lote
          IF cr_craplot%NOTFOUND THEN
            -- Fecha cursor
            CLOSE cr_craplot;
            -- Descricao de critica por nao ter encontrado registro
            vr_dscritic := 'Registro de lote 9900010106 nao encontrado.';
            RAISE vr_exc_saida;
          ELSE
            -- Fecha cursor
            CLOSE cr_craplot;
          END IF;

          -- Verifica se valores ficarao zerados apos a exclusao da aplicacao
          IF rw_craplot.vlcompcr = 0 AND
             rw_craplot.vlinfocr = 0 AND
             rw_craplot.qtcompln - 1 = 0 AND
             rw_craplot.qtinfoln - 1 = 0 AND
             rw_craplot.vlcompdb - rw_craprac.vlaplica = 0 AND
             rw_craplot.vlinfodb - rw_craprac.vlaplica = 0 THEN

            BEGIN
              DELETE FROM craplot WHERE craplot.rowid = rw_craplot.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao deletar regitro de lote 9900010106. Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;

          ELSE

            -- Atualizacao de registro de lote
            BEGIN

              UPDATE
                craplot
              SET
                 craplot.qtinfoln = craplot.qtinfoln - 1
                ,craplot.qtcompln = craplot.qtcompln - 1
                ,craplot.vlinfodb = craplot.vlinfodb - rw_craprac.vlaplica
                ,craplot.vlcompdb = craplot.vlcompdb - rw_craprac.vlaplica
              WHERE
                craplot.rowid = rw_craplot.rowid;

            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar registro de lote 9900010106. Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;

          END IF;
        END IF;
        -- Consulta lote
        OPEN cr_craplot(pr_cdcooper => rw_craprac.cdcooper
                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 8500);

        FETCH cr_craplot INTO rw_craplot;

        -- Verifica se encontrou registro de lote
        IF cr_craplot%NOTFOUND THEN
          -- Fecha cursor
          CLOSE cr_craplot;
          -- Descricao de critica por nao ter encontrado registro
          vr_dscritic := 'Erro ao consultar registro de lote 8500. Erro: ' || SQLERRM;
          RAISE vr_exc_saida;
        ELSE
          -- Fecha cursor
          CLOSE cr_craplot;
        END IF;

        -- Verifica se valores ficarao zerados apos a exclusao da aplicacao
        IF rw_craplot.vlcompcr = 0 AND
           rw_craplot.vlinfocr = 0 AND
           rw_craplot.qtcompln - 1 = 0 AND
           rw_craplot.qtinfoln - 1 = 0 AND
           rw_craplot.vlcompdb - rw_craprac.vlaplica = 0 AND
           rw_craplot.vlinfodb - rw_craprac.vlaplica = 0 THEN

          BEGIN
            DELETE FROM craplot WHERE craplot.rowid = rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao deletar regitro de lote 8500. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

        ELSE

          -- Atualizacao de registro de lote
          BEGIN

            UPDATE
              craplot
            SET
               craplot.qtinfoln = craplot.qtinfoln - 1
              ,craplot.qtcompln = craplot.qtcompln - 1
              ,craplot.vlinfodb = craplot.vlinfodb - rw_craprac.vlaplica
              ,craplot.vlcompdb = craplot.vlcompdb - rw_craprac.vlaplica
            WHERE
              craplot.rowid = rw_craplot.rowid;

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar registro de lote 8500. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

        END IF;

        -- Verifica se a aplicação foi cadastrada com recurso da conta-corrente
        IF rw_craprac.iddebcti = 0 THEN

          -- Exclusao de registros de debito de lancamentos da conta investimento
          BEGIN
            DELETE
              craplci
            WHERE
                  craplci.cdcooper = rw_craprac.cdcooper
              AND craplci.dtmvtolt = rw_crapdat.dtmvtolt
              AND craplci.cdagenci = 1
              AND craplci.cdbccxlt = 100
              AND craplci.nrdolote = 9900010104
              AND craplci.nrdconta = rw_craprac.nrdconta
              AND craplci.nrdocmto = rw_craprac.nraplica;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao deletar registro de lancamento de debito na conta investimento. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

          -- Verifica se houve a exclusao de algum registro, caso contrário exibe critica e aborta o processo
          IF SQL%ROWCOUNT <= 0 THEN
            vr_dscritic := 'Registro de lancamento de debito na conta investimento nao encontrado.';
            RAISE vr_exc_saida;
          END IF;

          -- Exclusao de registros de credito de lancamentos da conta investimento
          BEGIN
            DELETE
              craplci
            WHERE
                  craplci.cdcooper = rw_craprac.cdcooper
              AND craplci.dtmvtolt = rw_crapdat.dtmvtolt
              AND craplci.cdagenci = 1
              AND craplci.cdbccxlt = 100
              AND craplci.nrdolote = 9900010105
              AND craplci.nrdconta = rw_craprac.nrdconta
              AND craplci.nrdocmto = rw_craprac.nraplica;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao deletar registro de lancamento de credito na conta investimento. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

          -- Verifica se houve a exclusao de algum registro, caso contrário exibe critica e aborta o processo
          IF SQL%ROWCOUNT <= 0 THEN
            vr_dscritic := 'Registro de lancamento de credito na conta investimento nao encontrado.';
            RAISE vr_exc_saida;
          END IF;

          -- Exclusao de registros de lancamento
          BEGIN
            DELETE
              craplcm
            WHERE
                  craplcm.cdcooper = rw_craprac.cdcooper
              AND craplcm.dtmvtolt = rw_crapdat.dtmvtolt
              AND craplcm.cdagenci = 1
              AND craplcm.cdbccxlt = 100
              AND craplcm.nrdolote = 8501
              AND craplcm.nrdctabb = rw_craprac.nrdconta
              AND craplcm.nrdocmto = rw_craprac.nraplica;

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao deletar registro de lancamento CRAPLCM. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

          -- Verifica se houve a exclusao de algum registro, caso contrário exibe critica e aborta o processo
          IF SQL%ROWCOUNT <= 0 THEN
            vr_dscritic := 'Registro de lancamento nao encontrado.';
            RAISE vr_exc_saida;
          END IF;

          -- Consulta de lote de debito
          OPEN cr_craplot(pr_cdcooper => rw_craprac.cdcooper
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         ,pr_cdagenci => 1
                         ,pr_cdbccxlt => 100
                         ,pr_nrdolote => 9900010104);

          FETCH cr_craplot INTO rw_craplot;

          -- Verifica se encontrou registro de lote
          IF cr_craplot%NOTFOUND THEN
            -- Fecha cursor
            CLOSE cr_craplot;
            -- Descricao de critica por nao ter encontrado registro
            vr_dscritic := 'Erro ao consultar registro de lote de debito.';
            RAISE vr_exc_saida;
          ELSE
            -- Fecha cursor
            CLOSE cr_craplot;
          END IF;

          -- Verifica se valores ficarao zerados apos a exclusao da aplicacao
          IF NVL(rw_craplot.vlcompcr,0) = 0 AND
             NVL(rw_craplot.vlinfocr,0) = 0 AND
             NVL(rw_craplot.qtcompln,0) - 1 = 0 AND
             NVL(rw_craplot.qtinfoln,0) - 1 = 0 AND
             NVL(rw_craplot.vlcompdb,0) - rw_craprac.vlaplica = 0 AND
             NVL(rw_craplot.vlinfodb,0) - rw_craprac.vlaplica = 0 THEN

            BEGIN
              DELETE FROM craplot WHERE craplot.rowid = rw_craplot.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao deletar regitro de lote de debito. Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;

            -- Verifica se houve a exclusao de algum registro, caso contrário exibe critica e aborta o processo
            IF SQL%ROWCOUNT <= 0 THEN
              vr_dscritic := 'Registro de lote nao encontrado.';
              RAISE vr_exc_saida;
            END IF;

          ELSE
            -- Atualizacao de registro de lote de debito
            BEGIN
              UPDATE
                craplot
              SET
                craplot.qtinfoln = NVL(craplot.qtinfoln,0) - 1,
                craplot.qtcompln = NVL(craplot.qtcompln,0) - 1,
                craplot.vlinfodb = NVL(craplot.vlinfodb,0) - rw_craprac.vlaplica,
                craplot.vlcompdb = NVL(craplot.vlcompdb,0) - rw_craprac.vlaplica
              WHERE
                    craplot.cdcooper = rw_craprac.cdcooper
                AND craplot.dtmvtolt = rw_crapdat.dtmvtolt
                AND craplot.cdagenci = 1
                AND craplot.cdbccxlt = 100
                AND craplot.nrdolote = 9900010104;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar registro de lote de debito. Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
          END IF;

          -- Consulta de lote de credito
          OPEN cr_craplot(pr_cdcooper => rw_craprac.cdcooper
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         ,pr_cdagenci => 1
                         ,pr_cdbccxlt => 100
                         ,pr_nrdolote => 9900010105);

          FETCH cr_craplot INTO rw_craplot;

          -- Verifica se encontrou registro de lote
          IF cr_craplot%NOTFOUND THEN
            -- Fecha cursor
            CLOSE cr_craplot;
            -- Descricao de critica por nao ter encontrado registro
            vr_dscritic := 'Erro ao consultar registro de lote de credito. Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
          ELSE
            -- Fecha cursor
            CLOSE cr_craplot;
          END IF;

          -- Verifica se valores ficarao zerados apos a exclusao da aplicacao
          IF NVL(rw_craplot.vlcompcr,0) = 0 AND
             NVL(rw_craplot.vlinfocr,0) = 0 AND
             NVL(rw_craplot.qtcompln,0) - 1 = 0 AND
             NVL(rw_craplot.qtinfoln,0) - 1 = 0 AND
             NVL(rw_craplot.vlcompdb,0) - rw_craprac.vlaplica = 0 AND
             NVL(rw_craplot.vlinfodb,0) - rw_craprac.vlaplica = 0 THEN

            BEGIN
              DELETE FROM craplot WHERE craplot.rowid = rw_craplot.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao deletar regitro de lote de credito. Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;

            -- Verifica se houve a exclusao de algum registro, caso contrário exibe critica e aborta o processo
            IF SQL%ROWCOUNT <= 0 THEN
              vr_dscritic := 'Registro de lote nao encontrado.';
              RAISE vr_exc_saida;
            END IF;

          ELSE
            -- Atualizacao de registro de lote de credito
            BEGIN
              UPDATE
                craplot
              SET
                craplot.qtinfoln = NVL(craplot.qtinfoln,0) - 1,
                craplot.qtcompln = NVL(craplot.qtcompln,0) - 1,
                craplot.vlinfocr = NVL(craplot.vlinfocr,0) - rw_craprac.vlaplica,
                craplot.vlcompcr = NVL(craplot.vlcompcr,0) - rw_craprac.vlaplica
              WHERE
                    craplot.cdcooper = rw_craprac.cdcooper
                AND craplot.dtmvtolt = rw_crapdat.dtmvtolt
                AND craplot.cdagenci = 1
                AND craplot.cdbccxlt = 100
                AND craplot.nrdolote = 9900010105;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar registro de lote de credito. Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
          END IF;

          -- Consulta de lote de credito
          OPEN cr_craplot(pr_cdcooper => rw_craprac.cdcooper
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         ,pr_cdagenci => 1
                         ,pr_cdbccxlt => 100
                         ,pr_nrdolote => 8501);

          FETCH cr_craplot INTO rw_craplot;

          -- Verifica se encontrou registro de lote
          IF cr_craplot%NOTFOUND THEN
            -- Fecha cursor
            CLOSE cr_craplot;
            -- Descricao de critica por nao ter encontrado registro
            vr_dscritic := 'Erro ao consultar registro de lote 8501. Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
          ELSE
            -- Fecha cursor
            CLOSE cr_craplot;
          END IF;

          -- Verifica se valores ficarao zerados apos a exclusao da aplicacao
          IF NVL(rw_craplot.vlcompcr,0) = 0 AND
             NVL(rw_craplot.vlinfocr,0) = 0 AND
             NVL(rw_craplot.qtcompln,0) - 1 = 0 AND
             NVL(rw_craplot.qtinfoln,0) - 1 = 0 AND
             NVL(rw_craplot.vlcompdb,0) - rw_craprac.vlaplica = 0 AND
             NVL(rw_craplot.vlinfodb,0) - rw_craprac.vlaplica = 0 THEN

            BEGIN
              DELETE FROM craplot WHERE craplot.rowid = rw_craplot.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao deletar regitro de lote 8501. Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;

            -- Verifica se houve a exclusao de algum registro, caso contrário exibe critica e aborta o processo
            IF SQL%ROWCOUNT <= 0 THEN
              vr_dscritic := 'Registro de lote nao encontrado.';
              RAISE vr_exc_saida;
            END IF;

          ELSE
            -- Atualizacao de registro de lote
            BEGIN
              UPDATE
                craplot
              SET
                craplot.qtinfoln = NVL(craplot.qtinfoln,0) - 1,
                craplot.qtcompln = NVL(craplot.qtcompln,0) - 1,
                craplot.vlinfodb = NVL(craplot.vlinfodb,0) - rw_craprac.vlaplica,
                craplot.vlcompdb = NVL(craplot.vlcompdb,0) - rw_craprac.vlaplica
              WHERE
                    craplot.cdcooper = rw_craprac.cdcooper
                AND craplot.dtmvtolt = rw_crapdat.dtmvtolt
                AND craplot.cdagenci = 1
                AND craplot.cdbccxlt = 100
                AND craplot.nrdolote = 8501;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar registro de lote 8501';
                RAISE vr_exc_saida;
            END;
          END IF;

        END IF;

        -- Exclusao do registro de aplicacao da tabela CRAPRAC
        BEGIN
          DELETE FROM
            craprac
          WHERE
                craprac.cdcooper = pr_cdcooper
            AND craprac.nrdconta = pr_nrdconta
            AND craprac.nraplica = pr_nraplica;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao deletar registro de aplicacao. Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Geracao de comprovante da aplicação indicando que a mesma foi cancelada
        GENE0006.pc_estorna_protocolo(pr_cdcooper => pr_cdcooper         -- Codigo da cooperativa
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data de movimento atual
                                     ,pr_nrdconta => pr_nrdconta         -- Numero da conta
                                     ,pr_cdtippro => 10                  -- Tipo de Produto (10/Aplicacao)
                                     ,pr_nrdocmto => rw_craprac.nraplica -- Numero da aplicacao
                                     ,pr_dsprotoc => vr_dsprotoc         -- Descricao do protocolo
                                     ,pr_retorno  => vr_dscritic);       -- Descricao de critica

        -- Verifica se houve critica no estorno
        IF vr_dscritic <> 'OK' THEN
          RAISE vr_exc_saida;
        END IF;

        -- Exclusao dos registros de cumulatividade
        BEGIN
          DELETE FROM
            crapcap
          WHERE
            crapcap.cdcooper = pr_cdcooper AND
            crapcap.nrdconta = pr_nrdconta AND
           (crapcap.nraplica = pr_nraplica OR
            crapcap.nraplacu = pr_nraplica);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao deletar registros de cumulatividade. Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

      END IF;

      -- Verifica se deve gerar log
      IF pr_idgerlog = 1 THEN
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                            ,pr_dstransa => vr_dstransa || ' ' || pr_dscritic
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'NRAPLICA'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_nraplica);

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'NRDOCMTO'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_nraplica);

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'DTRESGAT'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => TO_CHAR(rw_craprac.dtvencto,'dd/MM/RRRR'));
      END IF;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;

        -- Verifica se deve gerar log
        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => ''
                              ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                              ,pr_dstransa => vr_dstransa || ' ' || pr_dscritic
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 1 --> TRUE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);

          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'NRAPLICA'
                                   ,pr_dsdadant => rw_craprac.nraplica
                                   ,pr_dsdadatu => rw_craprac.nraplica);
          COMMIT;
        END IF;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em APLI0005.pc_exclui_aplicacao: ' || SQLERRM;

        -- Verifica se deve gerar log
        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => ''
                              ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                              ,pr_dstransa => vr_dstransa || ' ' || pr_dscritic
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 1 --> TRUE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);

          COMMIT;
        END IF;

    END;

  END pc_exclui_aplicacao;

  PROCEDURE pc_exclui_aplicacao_car(pr_cdcooper IN craprac.cdcooper%TYPE      -- Código da Cooperativa
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE      -- Código do Operador
                                   ,pr_nmdatela IN craptel.nmdatela%TYPE      -- Nome da Tela
                                   ,pr_idorigem IN INTEGER                    -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA)
                                   ,pr_nrdconta IN craprac.nrdconta%TYPE      -- Número da Conta
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE      -- Titular da Conta
                                   ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE      -- Numero de caixa
                                   ,pr_nraplica IN craprac.nraplica%TYPE      -- Código da aplicacao
                                   ,pr_idgerlog IN INTEGER                    -- Identificador de LOG (0-Nao grava / 1-Registrar)
                                   ,pr_cdcritic OUT PLS_INTEGER               -- Código da crítica
                                   ,pr_dscritic OUT VARCHAR2) IS              -- Descrição da crítica

    BEGIN
   /* .............................................................................

     Programa: pc_exclui_aplicacao_car
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Dezembro/14.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a exclusao de aplicacoes de novos produtos feito atraves
                 do Ayllos Caracter.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

    BEGIN

      -- Procedure para excluir aplicação
      APLI0005.pc_exclui_aplicacao(pr_cdcooper => pr_cdcooper
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_nmdatela => pr_nmdatela
                                  ,pr_idorigem => pr_idorigem
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_idseqttl => pr_idseqttl
                                  ,pr_nrdcaixa => pr_nrdcaixa
                                  ,pr_nraplica => pr_nraplica
                                  ,pr_idgerlog => pr_idgerlog
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);

      -- Se retornou alguma critica
      IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na exclusao de aplicacoes APLI0005.pc_exclui_aplicacao_car: ' || SQLERRM;

    END;
  END pc_exclui_aplicacao_car;

  -- Rotina de exclusao de aplicacoes via WEB
  PROCEDURE pc_exclui_aplicacao_web(pr_nrdconta IN craprac.nrdconta%TYPE --> Número da Conta
                                   ,pr_nraplica IN craprac.nraplica%TYPE --> Número da Aplicacao
                                   ,pr_idgerlog IN INTEGER               --> Identificador de LOG
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN

    /* .............................................................................

     Programa: pc_exclui_aplicacao_web
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Agosto/14.                    Ultima atualizacao: 18/08/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a exclusão de aplicacoes via web.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/

    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

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
        RAISE vr_exc_saida;
      END IF;

      -- Efetua o cadastro de aplicacoes
      APLI0005.pc_exclui_aplicacao(pr_cdcooper => vr_cdcooper   -- Código da Cooperativa
                                  ,pr_cdoperad => vr_cdoperad   -- Código do Operador
                                  ,pr_nmdatela => vr_nmdatela   -- Nome da Tela
                                  ,pr_idorigem => vr_idorigem   -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA)
                                  ,pr_nrdconta => pr_nrdconta   -- Número da Conta
                                  ,pr_idseqttl => 1             -- Titular da Conta
                                  ,pr_nrdcaixa => vr_nrdcaixa   -- Numero de caixa
                                  ,pr_nraplica => pr_nraplica   -- Numero da aplicacao
                                  ,pr_idgerlog => pr_idgerlog   -- Identificador de LOG (0-Nao grava / 1-Registrar)
                                  ,pr_cdcritic => vr_cdcritic   -- Codigo da critica de erro
                                  ,pr_dscritic => vr_dscritic); -- Descricao da critica de erro

      -- Verifica se houve erro recuperando informacoes de log
      IF vr_dscritic IS NOT NULL AND
         vr_dscritic <> 'OK' THEN
        RAISE vr_exc_saida;
      END IF;

      -- Retorna OK para cadastro efetuado com sucesso
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><INF>OK</INF></Root>');

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em APLI0005.pc_exclui_aplicacao_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_exclui_aplicacao_web;

  PROCEDURE pc_busca_aplicacoes(pr_cdcooper IN craprac.cdcooper%TYPE             --> Código da Cooperativa
                               ,pr_cdoperad IN crapope.cdoperad%TYPE             --> Código do Operador
                               ,pr_nmdatela IN craptel.nmdatela%TYPE             --> Nome da Tela
                               ,pr_idorigem IN INTEGER                           --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                               ,pr_nrdconta IN craprac.nrdconta%TYPE             --> Número da Conta
                               ,pr_idseqttl IN crapttl.idseqttl%TYPE             --> Titular da Conta
                               ,pr_nraplica IN craprac.nraplica%TYPE DEFAULT 0   --> Número da Aplicação - Parâmetro Opcional
                               ,pr_cdprodut IN craprac.cdprodut%TYPE DEFAULT 0   --> Código do Produto – Parâmetro Opcional
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE             --> Data de Movimento
                               ,pr_idconsul IN INTEGER                           --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                               ,pr_idgerlog IN INTEGER                           --> Identificador de Log (0 – Não / 1 – Sim)
                               ,pr_cdcritic OUT INTEGER                          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2                         --> Descrição da crítica
                               ,pr_tab_aplica OUT APLI0005.typ_tab_aplicacao)--> Tabela com os dados da aplicação
                               IS
   BEGIN
   /* .............................................................................

     Programa: pc_busca_aplicacoes
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Lucas Reinert
     Data    : Agosto/14.                    Ultima atualizacao: 04/12/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de aplicacoes.

     Observacao: -----

     Alteracoes: 18/07/2018 - 1. Desconsiderar as aplicações programadas
                              Proj. 411.2 (Claudio - CIS Corporate)
                 04/12/2018 - Trocar a chamada da gene0001.pc_gera_log pela gene.0001.pc_gera_log_auto e retirada
	                            dos commits que estão impactando na rotina diária (Adriano Nagasava - Supero)															
    ..............................................................................*/

    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_vlbascal NUMBER := 0; -- Base de Calculo
      vr_vlsldtot NUMBER := 0; -- Saldo Total
      vr_vlsldrgt NUMBER := 0; -- Saldo de Resgate
      vr_vlultren NUMBER := 0; -- Ultimo Rendimento
      vr_vlrentot NUMBER := 0; -- Rendimento Total
      vr_vlrevers NUMBER := 0; -- Valor de Reversão
      vr_vlrdirrf NUMBER := 0; -- Valor de IRRF
      vr_percirrf NUMBER := 0; -- Percentual de IRRF

      --Variáveis locais
      vr_dstransa VARCHAR2(100) := 'Busca saldo da aplicacao num: ' || pr_nraplica;
      vr_dsorigem VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_nrdrowid ROWID;

      -- Declaração da tabela que conterá os dados da aplicação
      vr_tab_aplica APLI0005.typ_tab_aplicacao;
      vr_ind_aplica PLS_INTEGER := 0;

      -- Seleciona registro de aplicação de captação
      CURSOR cr_craprac(pr_dtmvtolt_cop IN crapdat.dtmvtolt%TYPE) IS
        SELECT rac.cdprodut
              ,rac.cdcooper
              ,rac.nrdconta
              ,rac.nraplica
              ,rac.cdnomenc
              ,rac.dtmvtolt
              ,rac.txaplica
              ,rac.qtdiacar
              ,rac.vlaplica
              ,rac.vlsldacu
              ,rac.dtvencto
              ,rac.idblqrgt
              ,rac.cdoperad
              ,rac.qtdiaapl
              ,rga.dtresgat
              ,npc.dsnomenc
          FROM craprac rac, craprga rga, crapnpc npc
         WHERE rac.cdcooper = pr_cdcooper AND
               rac.nrdconta = pr_nrdconta AND
               rac.nrctrrpp=0 AND /* Desconsiderar aplicacoes programadas*/
              (pr_nraplica = 0 OR rac.nraplica = pr_nraplica) AND
              (pr_cdprodut = 0 OR rac.cdprodut = pr_cdprodut) AND
              ( /* Encerradas */
               (pr_idconsul = 4 AND rac.idsaqtot > 0)         OR
                /* Todas  */
               (pr_idconsul = 5)                              OR
                /* Disponíveis para resgate */
               (pr_idconsul = 6 AND (rac.idsaqtot = 0         OR
               (rac.idsaqtot = 1 AND rac.dtatlsld = pr_dtmvtolt_cop))) OR
                /* Ativas ou Resgatadas ou Vencidas */
               (rac.idsaqtot = pr_idconsul)
              ) AND
                 rga.cdcooper (+) = rac.cdcooper AND
                 rga.nrdconta (+) = rac.nrdconta AND
                 rga.nraplica (+) = rac.nraplica AND
                 (rga.idresgat (+) = 0 OR
                 (rga.idresgat (+) = 1 AND
                  rga.dtresgat (+) = pr_dtmvtolt_cop AND
                  rga.dtmvtolt (+) = pr_dtmvtolt_cop))
                AND npc.cdnomenc (+) = rac.cdnomenc;

      rw_craprac cr_craprac%ROWTYPE;

      -- Seleciona produto de captação
      CURSOR cr_crapcpc(pr_cdprodut crapcpc.cdprodut%TYPE) IS
        SELECT cpc.cddindex
              ,cpc.idtippro
              ,cpc.idtxfixa
              ,cpc.cdprodut
              ,cpc.nmprodut
                            ,ind.nmdindex
          FROM crapcpc cpc, crapind ind
         WHERE cpc.cdprodut = pr_cdprodut
           AND cpc.cddindex = ind.cddindex;
      rw_crapcpc cr_crapcpc%ROWTYPE;

      -- Seleciona registro de resgate disponível
      CURSOR cr_craprga_disp(pr_cdcooper craprga.cdcooper%TYPE
                            ,pr_nrdconta craprga.nrdconta%TYPE
                            ,pr_nraplica craprga.nraplica%TYPE
                            ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
        SELECT craprga.cdcooper, craprga.nrdconta, craprga.nraplica
          FROM craprga
         WHERE craprga.cdcooper = pr_cdcooper AND
                craprga.nrdconta = pr_nrdconta AND
               craprga.nraplica = pr_nraplica AND
               craprga.idresgat = 1           AND
               craprga.dtresgat = pr_dtmvtolt AND
               craprga.dtmvtolt = pr_dtmvtolt;

      -- Seleciona nomenclaturas comerciais dos produtos de captação
      CURSOR cr_crapnpc(pr_cdnomenc crapnpc.cdnomenc%TYPE) IS
        SELECT npc.dsnomenc
          FROM crapnpc npc
         WHERE npc.cdnomenc = pr_cdnomenc;
      rw_crapnpc cr_crapnpc%ROWTYPE;

      -- Seleciona cadastro de indexadores de remuneração
      CURSOR cr_crapind(pr_cddindex crapind.cddindex%TYPE) IS
        SELECT ind.nmdindex
          FROM crapind ind
         WHERE ind.cddindex = pr_cddindex;
      rw_crapind cr_crapind%ROWTYPE;

      -- Seleciona operador
      CURSOR cr_crapope(pr_cdcooper crapope.cdcooper%TYPE
                       ,pr_cdoperad crapope.cdoperad%TYPE) IS
        SELECT ope.nmoperad
          FROM crapope ope
         WHERE ope.cdcooper = pr_cdcooper
           AND upper(ope.cdoperad) = upper(pr_cdoperad);
      rw_crapope cr_crapope%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    BEGIN

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;

      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Busca nome do operador
      OPEN cr_crapope(pr_cdcooper => pr_cdcooper
                     ,pr_cdoperad => pr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      CLOSE cr_crapope;

      -- Para cada registro de aplicação
      FOR rw_craprac IN cr_craprac(pr_dtmvtolt_cop => rw_crapdat.dtmvtolt) LOOP

        IF pr_idconsul = 6 THEN
          -- Abre cursor para verificar se registro de aplicação está disponível para resgate
          OPEN cr_craprga_disp(pr_cdcooper => rw_craprac.cdcooper
                              ,pr_nrdconta => rw_craprac.nrdconta
                              ,pr_nraplica => rw_craprac.nraplica
                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt);

          -- Se não encontrar registro pula para próximo registro de aplicação de captação
          IF cr_craprga_disp%NOTFOUND THEN
            CLOSE cr_craprga_disp;
            CONTINUE;
          ELSE
            CLOSE cr_craprga_disp;
          END IF;

        END IF;

        -- Busca informações do produto cadastrado
        OPEN cr_crapcpc(rw_craprac.cdprodut);
        FETCH cr_crapcpc INTO rw_crapcpc;

        -- Verifica se informacoes de produtos existe
        IF cr_crapcpc%NOTFOUND THEN
          CLOSE cr_crapcpc;
          vr_dscritic := 'Erro ao consultar produto.';
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_crapcpc;
        END IF;

        vr_vlbascal := rw_craprac.vlsldacu;

        -- Se produto for pré-fixado
        IF rw_crapcpc.idtippro = 1 THEN

          -- Chama procedure para obter saldo atualizado da aplicação
          APLI0006.pc_posicao_saldo_aplicacao_pre
                            (pr_cdcooper => rw_craprac.cdcooper,   --> Código da cooperativa
                             pr_nrdconta => rw_craprac.nrdconta,   --> Nr. da conta
                             pr_nraplica => rw_craprac.nraplica,   --> Nr. da aplicação
                             pr_dtiniapl => rw_craprac.dtmvtolt,   --> Data de inicio da aplicação
                             pr_txaplica => rw_craprac.txaplica,   --> Taxa da aplicação
                             pr_idtxfixa => rw_crapcpc.idtxfixa,   --> Taxa fixa (1 - Sim/ 2 - Não)
                             pr_cddindex => rw_crapcpc.cddindex,   --> Código do indexador
                             pr_qtdiacar => rw_craprac.qtdiacar,   --> Dias de carencia
                             pr_idgravir => 0,                     --> Não gravar imunidade IRRF
                             pr_dtinical => rw_craprac.dtmvtolt,   --> Data inicial cálculo
                             pr_dtfimcal => pr_dtmvtolt,           --> Data final cálculo
                             pr_idtipbas => 2,                     --> Tipo Base - Total
                             pr_vlbascal => vr_vlbascal,           --> Valor Base Cálculo
                             pr_vlsldtot => vr_vlsldtot,           --> Valor saldo total da aplicação
                             pr_vlsldrgt => vr_vlsldrgt,           --> Valor saldo total para resgate
                             pr_vlultren => vr_vlultren,           --> Valor último rendimento
                             pr_vlrentot => vr_vlrentot,           --> Valor rendimento total
                             pr_vlrevers => vr_vlrevers,           --> Valor de reversão
                             pr_vlrdirrf => vr_vlrdirrf,           --> Valor do IRRF
                             pr_percirrf => vr_percirrf,           --> Percentual do IRRF
                             pr_cdcritic => vr_cdcritic,           --> Código da crítica
                             pr_dscritic => vr_dscritic);          --> Descrição da crítica

          -- Se retornou crítica
          IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            vr_dscritic := 'Erro na chamada da procedure APLI0006.pc_posicao_saldo_aplicacao_pre -> '
                           || vr_dscritic;
            RAISE vr_exc_saida;
          END IF;

        -- Se produto for pós-fixado
        ELSIF rw_crapcpc.idtippro = 2 THEN

          -- Chama procedure para obter saldo atualizado da aplicação
          APLI0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => rw_craprac.cdcooper,   --> Código da cooperativa
                                                  pr_nrdconta => rw_craprac.nrdconta,   --> Nr. da conta
                                                  pr_nraplica => rw_craprac.nraplica,   --> Nr. da aplicação
                                                  pr_dtiniapl => rw_craprac.dtmvtolt,   --> Data de inicio da aplicação
                                                  pr_txaplica => rw_craprac.txaplica,   --> Taxa da aplicação
                                                  pr_idtxfixa => rw_crapcpc.idtxfixa,   --> Taxa fixa (1 - Sim/ 2 - Não)
                                                  pr_cddindex => rw_crapcpc.cddindex,   --> Código do indexador
                                                  pr_qtdiacar => rw_craprac.qtdiacar,   --> Dias de carencia
                                                  pr_idgravir => 0,                     --> Não gravar imunidade IRRF
                                                  pr_dtinical => rw_craprac.dtmvtolt,   --> Data inicial cálculo
                                                  pr_dtfimcal => pr_dtmvtolt,           --> Data final cálculo
                                                  pr_idtipbas => 2,                     --> Tipo Base - Total
                                                  pr_vlbascal => vr_vlbascal,           --> Valor Base Cálculo
                                                  pr_vlsldtot => vr_vlsldtot,           --> Valor saldo total da aplicação
                                                  pr_vlsldrgt => vr_vlsldrgt,           --> Valor saldo total para resgate
                                                  pr_vlultren => vr_vlultren,           --> Valor último rendimento
                                                  pr_vlrentot => vr_vlrentot,           --> Valor rendimento total
                                                  pr_vlrevers => vr_vlrevers,           --> Valor de reversão
                                                  pr_vlrdirrf => vr_vlrdirrf,           --> Valor do IRRF
                                                  pr_percirrf => vr_percirrf,           --> Percentual do IRRF
                                                  pr_cdcritic => vr_cdcritic,           --> Código da crítica
                                                  pr_dscritic => vr_dscritic);          --> Descrição da crítica);

          -- Se retornou crítica
          IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            vr_dscritic := 'Erro na chamada da procedure APLI0006.pc_posicao_saldo_aplicacao_pos  -> '
                           || vr_dscritic;
            RAISE vr_exc_saida;
          END IF;

        END IF; -- if rw_crapcpc.idtippro

        -- Buscar qual a quantidade atual de registros na tabela para posicionar na próxima
        vr_ind_aplica := vr_tab_aplica.COUNT() + 1;

        vr_tab_aplica(vr_ind_aplica).nraplica := TRIM(rw_craprac.nraplica);            --> Nr. da aplicação
        vr_tab_aplica(vr_ind_aplica).idtippro := TRIM(rw_crapcpc.idtippro);            --> Tipo do produto
        vr_tab_aplica(vr_ind_aplica).cdprodut := TRIM(rw_craprac.cdprodut);            --> Cód. do produto
        vr_tab_aplica(vr_ind_aplica).nmprodut := TRIM(rw_crapcpc.nmprodut);            --> Nome do produto

        IF rw_craprac.dsnomenc IS NOT NULL THEN
          vr_tab_aplica(vr_ind_aplica).dsnomenc := TRIM(rw_craprac.dsnomenc);          --> Descrição da nomenclatura do produto de captação
        ELSE
          vr_tab_aplica(vr_ind_aplica).dsnomenc := TRIM(rw_crapcpc.nmprodut);          --> Nome do produto
        END IF;

        vr_tab_aplica(vr_ind_aplica).nmdindex := TRIM(rw_crapcpc.nmdindex);            --> Nome do indexador
        vr_tab_aplica(vr_ind_aplica).vlaplica := TRIM(rw_craprac.vlaplica);            --> Valor da aplicação
        vr_tab_aplica(vr_ind_aplica).vlsldtot := TRIM(vr_vlsldtot);                    --> Valor saldo total da aplicação
        vr_tab_aplica(vr_ind_aplica).vlsldrgt := TRIM(vr_vlsldrgt);                    --> Valor saldo total para resgate
        vr_tab_aplica(vr_ind_aplica).vlrdirrf := TRIM(vr_vlrdirrf);                    --> Valor do IRRF
        vr_tab_aplica(vr_ind_aplica).percirrf := TRIM(vr_percirrf);                    --> Percentual do IRRF
        vr_tab_aplica(vr_ind_aplica).dtmvtolt := TRIM(rw_craprac.dtmvtolt);            --> Data de movimento da aplicação
        vr_tab_aplica(vr_ind_aplica).dtvencto := TRIM(rw_craprac.dtvencto);            --> Data de vencimento da aplicação
        vr_tab_aplica(vr_ind_aplica).qtdiacar := TRIM(rw_craprac.qtdiacar);            --> Quantidade de dias da carência da aplicação
        vr_tab_aplica(vr_ind_aplica).txaplica := TRIM(rw_craprac.txaplica);            --> Taxa da aplicação
        vr_tab_aplica(vr_ind_aplica).idblqrgt := TRIM(rw_craprac.idblqrgt);            --> Indicador de bloqueio de resgate (0-Desbloqueada/1-Bloqueada BLQRGT/2-Bloqueada ADTIVI)
        vr_tab_aplica(vr_ind_aplica).qtdiauti := TRIM(rw_craprac.qtdiaapl);            --> Qtd dias de aplicacao
        vr_tab_aplica(vr_ind_aplica).idtxfixa := TRIM(rw_crapcpc.idtxfixa);            --> Produto com taxa fixa (1 - SIM / 2 - NAO)
        vr_tab_aplica(vr_ind_aplica).qtdiaapl := TRIM(rw_craprac.qtdiaapl);            --> Qtd dias de aplicacao

        IF rw_craprac.idblqrgt = 0 THEN
          vr_tab_aplica(vr_ind_aplica).dsblqrgt := TRIM('DISPONÍVEL');                 --> Descrição do indicador de bloque de resgate
        ELSE
          vr_tab_aplica(vr_ind_aplica).dsblqrgt := TRIM('BLOQUEADA');                  --> Descrição do indicador de bloque de resgate
        END IF;

        IF rw_craprac.dtresgat IS NOT NULL THEN
          vr_tab_aplica(vr_ind_aplica).dsresgat := TRIM('SIM');                        --> Solicitação de resgate SIM/NAO
        ELSE
          vr_tab_aplica(vr_ind_aplica).dsresgat := TRIM('NAO');                        --> Solicitação de resgate SIM/NAO
        END IF;

        IF rw_craprac.dtresgat IS NOT NULL THEN
          vr_tab_aplica(vr_ind_aplica).dtresgat := rw_craprac.dtresgat;          --> Data do resgate
        END IF;
        vr_tab_aplica(vr_ind_aplica).cdoperad := TRIM(rw_craprac.cdoperad);            --> Cód. do operador
        vr_tab_aplica(vr_ind_aplica).nmoperad := TRIM(rw_crapope.nmoperad);            --> Nome do operador
        vr_tab_aplica(vr_ind_aplica).idtipapl := TRIM('N');                            --> Identificador de nova aplicacao

      END LOOP; -- FOR rw_craprac

      -- Alimenta parâmetro com a PL/Table gerada
      pr_tab_aplica := vr_tab_aplica;

      -- Gerar log
      IF pr_idgerlog = 1 THEN
          gene0001.pc_gera_log_auto(pr_cdcooper => pr_cdcooper
																	 ,pr_cdoperad => pr_cdoperad
																	 ,pr_dscritic => pr_dscritic
																	 ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
																	 ,pr_dstransa => vr_dstransa
																	 ,pr_dttransa => TRUNC(SYSDATE)
																	 ,pr_flgtrans => 1 --> FALSE
																	 ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
																	 ,pr_idseqttl => pr_idseqttl
																	 ,pr_nmdatela => pr_nmdatela
																	 ,pr_nrdconta => pr_nrdconta
																	 ,pr_nrdrowid => vr_nrdrowid
																	 );
        END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Alimenta parametros com as críticas
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Verifica se deve gerar log
        IF pr_idgerlog = 1 THEN
          gene0001.pc_gera_log_auto(pr_cdcooper => pr_cdcooper
																	 ,pr_cdoperad => pr_cdoperad
																	 ,pr_dscritic => pr_dscritic
																	 ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
																	 ,pr_dstransa => vr_dstransa
																	 ,pr_dttransa => TRUNC(SYSDATE)
																	 ,pr_flgtrans => 0 --> FALSE
																	 ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
																	 ,pr_idseqttl => pr_idseqttl
																	 ,pr_nmdatela => pr_nmdatela
																	 ,pr_nrdconta => pr_nrdconta
																	 ,pr_nrdrowid => vr_nrdrowid
																	 );
        END IF;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na APLI0005.pc_busca_aplicacoes: ' || SQLERRM;

        -- Verifica se deve gerar log
        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => pr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
          COMMIT;
        END IF;
    END;
  END pc_busca_aplicacoes;

  PROCEDURE pc_busca_aplicacoes_car(pr_cdcooper IN craprac.cdcooper%TYPE             --> Código da Cooperativa
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE             --> Código do Operador
                                   ,pr_nmdatela IN craptel.nmdatela%TYPE             --> Nome da Tela
                                   ,pr_idorigem IN INTEGER                           --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                   ,pr_nrdconta IN craprac.nrdconta%TYPE             --> Número da Conta
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE             --> Titular da Conta
                                   ,pr_nraplica IN craprac.nraplica%TYPE DEFAULT 0   --> Número da Aplicação - Parâmetro Opcional
                                   ,pr_cdprodut IN craprac.cdprodut%TYPE DEFAULT 0   --> Código do Produto – Parâmetro Opcional
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE             --> Data de Movimento
                                   ,pr_idconsul IN INTEGER                           --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                   ,pr_idgerlog IN INTEGER                           --> Identificador de Log (0 – Não / 1 – Sim)
                                   ,pr_clobxmlc OUT CLOB                             --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER                      --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2) IS                     --> Descrição da crítica

    BEGIN
   /* .............................................................................

     Programa: pc_busca_aplicacoes_car
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Lucas Reinert
     Data    : Agosto/14.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de aplicacoes para o Ayllos caractere.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Temp Table
      vr_tab_aplica APLI0005.typ_tab_aplicacao;

      -- Variaveis de XML
      vr_xml_temp VARCHAR2(32767);

    BEGIN

      -- Procedure para buscar informações da aplicação
      APLI0005.pc_busca_aplicacoes(pr_cdcooper => pr_cdcooper             --> Código da Cooperativa
                                  ,pr_cdoperad => pr_cdoperad             --> Código do Operador
                                  ,pr_nmdatela => pr_nmdatela             --> Nome da Tela
                                  ,pr_idorigem => pr_idorigem             --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                  ,pr_nrdconta => pr_nrdconta             --> Número da Conta
                                  ,pr_idseqttl => pr_idseqttl             --> Titular da Conta
                                  ,pr_nraplica => pr_nraplica             --> Número da Aplicação - Parâmetro Opcional
                                  ,pr_cdprodut => pr_cdprodut             --> Código do Produto – Parâmetro Opcional
                                  ,pr_dtmvtolt => pr_dtmvtolt             --> Data de Movimento
                                  ,pr_idconsul => pr_idconsul             --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                  ,pr_idgerlog => pr_idgerlog             --> Identificador de Log (0 – Não / 1 – Sim)
                                  ,pr_cdcritic => vr_cdcritic             --> Código da crítica
                                  ,pr_dscritic => vr_dscritic             --> Descrição da crítica
                                  ,pr_tab_aplica => vr_tab_aplica);       --> Tabela com os dados da aplicação

      -- Se retornou alguma critica
      IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Criar documento XML
      dbms_lob.createtemporary(pr_clobxmlc, TRUE);
      dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);

      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><raiz>');

      IF vr_tab_aplica.count() > 0 THEN
        -- Percorre todas as aplicações de captação da conta
        FOR vr_contador IN vr_tab_aplica.FIRST..vr_tab_aplica.LAST LOOP
          -- Montar XML com registros de aplicação
          gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<aplicacao>'
                                                    ||  '<nraplica>' || NVL(vr_tab_aplica(vr_contador).nraplica, 0) ||  '</nraplica>'
                                                    ||  '<idtippro>' || NVL(vr_tab_aplica(vr_contador).idtippro, 0) ||  '</idtippro>'
                                                    ||  '<cdprodut>' || NVL(vr_tab_aplica(vr_contador).cdprodut, 0) ||  '</cdprodut>'
                                                    ||  '<nmprodut>' || NVL(vr_tab_aplica(vr_contador).nmprodut, ' ') ||  '</nmprodut>'
                                                    ||  '<dsnomenc>' || NVL(vr_tab_aplica(vr_contador).dsnomenc, ' ') ||  '</dsnomenc>'
                                                    ||  '<nmdindex>' || NVL(vr_tab_aplica(vr_contador).nmdindex, ' ') ||  '</nmdindex>'
                                                    ||  '<vlaplica>' || NVL(vr_tab_aplica(vr_contador).vlaplica, '0,00') ||  '</vlaplica>'
                                                    ||  '<vlsldtot>' || NVL(vr_tab_aplica(vr_contador).vlsldtot, '0,00') ||  '</vlsldtot>'
                                                    ||  '<vlsldrgt>' || NVL(vr_tab_aplica(vr_contador).vlsldrgt, '0,00') ||  '</vlsldrgt>'
                                                    ||  '<vlrdirrf>' || NVL(vr_tab_aplica(vr_contador).vlrdirrf, '0,00') ||  '</vlrdirrf>'
                                                    ||  '<percirrf>' || NVL(vr_tab_aplica(vr_contador).percirrf, '0,00') ||  '</percirrf>'
                                                    ||  '<dtmvtolt>' || NVL(to_char(vr_tab_aplica(vr_contador).dtmvtolt, 'dd/mm/rrrr'), ' ') ||  '</dtmvtolt>'
                                                    ||  '<dtvencto>' || NVL(to_char(vr_tab_aplica(vr_contador).dtvencto, 'dd/mm/rrrr'), ' ') ||  '</dtvencto>'
                                                    ||  '<qtdiacar>' || NVL(vr_tab_aplica(vr_contador).qtdiacar, 0) ||  '</qtdiacar>'
                                                    ||  '<qtdiaapl>' || NVL(vr_tab_aplica(vr_contador).qtdiaapl, 0) ||  '</qtdiaapl>'
                                                    ||  '<txaplica>' || NVL(vr_tab_aplica(vr_contador).txaplica, '0,00') ||  '</txaplica>'
                                                    ||  '<idblqrgt>' || NVL(vr_tab_aplica(vr_contador).idblqrgt, 0) ||  '</idblqrgt>'
                                                    ||  '<dsblqrgt>' || NVL(vr_tab_aplica(vr_contador).dsblqrgt, ' ') ||  '</dsblqrgt>'
                                                    ||  '<dsresgat>' || NVL(vr_tab_aplica(vr_contador).dsresgat, ' ') ||  '</dsresgat>'
                                                    ||  '<dtresgat>' || NVL(to_char(vr_tab_aplica(vr_contador).dtresgat, 'dd/mm/rrrr'), ' ') ||  '</dtresgat>'
                                                    ||  '<cdoperad>' || NVL(vr_tab_aplica(vr_contador).cdoperad, ' ') ||  '</cdoperad>'
                                                    ||  '<nmoperad>' || NVL(vr_tab_aplica(vr_contador).nmoperad, ' ') ||  '</nmoperad>'
                                                    ||  '<idtxfixa>' || NVL(vr_tab_aplica(vr_contador).idtxfixa, 0) ||  '</idtxfixa>'
                                                    ||  '<idtipapl>' || NVL(vr_tab_aplica(vr_contador).idtipapl, 0) ||  '</idtipapl>'
                                                    || '</aplicacao>');

        END LOOP;
      END IF;
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</raiz>'
                             ,pr_fecha_xml      => TRUE);

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na busca de aplicacoes APLI0005.pc_busca_aplicacoes_car: ' || SQLERRM;

    END;
  END pc_busca_aplicacoes_car;

  PROCEDURE pc_busca_aplicacoes_web(pr_nrdconta IN craprac.nrdconta%TYPE             --> Número da Conta
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE             --> Titular da Conta
                                   ,pr_nraplica IN craprac.nraplica%TYPE DEFAULT 0   --> Número da Aplicação - Parâmetro Opcional
                                   ,pr_cdprodut IN craprac.cdprodut%TYPE DEFAULT 0   --> Código do Produto – Parâmetro Opcional
                                   ,pr_dtmvtolt IN VARCHAR2                          --> Data de Movimento
                                   ,pr_idconsul IN INTEGER                           --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                   ,pr_idgerlog IN INTEGER                           --> Identificador de Log (0 – Não / 1 – Sim)
                                   ,pr_xmllog   IN VARCHAR2                          --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER                      --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2                         --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType                --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2                         --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS                     --> Erros do processo

    BEGIN
   /* .............................................................................

     Programa: pc_busca_aplicacoes_web
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Lucas Reinert
     Data    : Agosto/14.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de aplicacoes para o Ayllos Web.

     Observacao: -----

     Alteracoes:
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      --Variáveis locais
      vr_contador PLS_INTEGER := 0;
      vr_auxconta PLS_INTEGER := 0;

      -- Temp Table
      vr_tab_aplica APLI0005.typ_tab_aplicacao;

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

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
        RAISE vr_exc_saida;
      END IF;

      -- Procedure para buscar informações da aplicação
      APLI0005.pc_busca_aplicacoes(pr_cdcooper => vr_cdcooper             --> Código da Cooperativa
                                  ,pr_cdoperad => vr_cdoperad             --> Código do Operador
                                  ,pr_nmdatela => vr_nmdatela             --> Nome da Tela
                                  ,pr_idorigem => to_number(vr_idorigem)  --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                  ,pr_nrdconta => pr_nrdconta             --> Número da Conta
                                  ,pr_idseqttl => pr_idseqttl             --> Titular da Conta
                                  ,pr_nraplica => pr_nraplica             --> Número da Aplicação - Parâmetro Opcional
                                  ,pr_cdprodut => pr_cdprodut             --> Código do Produto – Parâmetro Opcional
                                  ,pr_dtmvtolt => TO_DATE(pr_dtmvtolt, 'dd/mm/RRRR')    --> Data de Movimento
                                  ,pr_idconsul => pr_idconsul             --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                  ,pr_idgerlog => pr_idgerlog             --> Identificador de Log (0 – Não / 1 – Sim)
                                  ,pr_cdcritic => vr_cdcritic             --> Código da crítica
                                  ,pr_dscritic => vr_dscritic             --> Descrição da crítica
                                  ,pr_tab_aplica => vr_tab_aplica);       --> Tabela com os dados da aplicação

      -- Se retornou alguma critica
      IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      IF vr_tab_aplica.count() > 0 THEN
        -- Percorre todas as aplicações de captação da conta
        FOR vr_contador IN vr_tab_aplica.FIRST..vr_tab_aplica.LAST LOOP
          -- Insere as tags dos campos da PLTABLE de aplicações
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nraplica', pr_tag_cont => TO_CHAR(vr_tab_aplica(vr_contador).nraplica), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'idtippro', pr_tag_cont => TO_CHAR(vr_tab_aplica(vr_contador).idtippro), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdprodut', pr_tag_cont => TO_CHAR(vr_tab_aplica(vr_contador).cdprodut), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmprodut', pr_tag_cont => TO_CHAR(vr_tab_aplica(vr_contador).nmprodut), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dsnomenc', pr_tag_cont => TO_CHAR(vr_tab_aplica(vr_contador).dsnomenc), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmdindex', pr_tag_cont => TO_CHAR(vr_tab_aplica(vr_contador).nmdindex), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vlaplica', pr_tag_cont => TO_CHAR(vr_tab_aplica(vr_contador).vlaplica), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vlsldtot', pr_tag_cont => TO_CHAR(vr_tab_aplica(vr_contador).vlsldtot), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vlsldrgt', pr_tag_cont => TO_CHAR(vr_tab_aplica(vr_contador).vlsldrgt), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vlrdirrf', pr_tag_cont => TO_CHAR(vr_tab_aplica(vr_contador).vlrdirrf), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'percirrf', pr_tag_cont => TO_CHAR(vr_tab_aplica(vr_contador).percirrf), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtmvtolt', pr_tag_cont => TO_CHAR(vr_tab_aplica(vr_contador).dtmvtolt, 'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtvencto', pr_tag_cont => TO_CHAR(vr_tab_aplica(vr_contador).dtvencto, 'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'qtdiacar', pr_tag_cont => TO_CHAR(vr_tab_aplica(vr_contador).qtdiacar), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'qtdiaapl', pr_tag_cont => TO_CHAR(vr_tab_aplica(vr_contador).qtdiaapl), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'txaplica', pr_tag_cont => TO_CHAR(vr_tab_aplica(vr_contador).txaplica), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'idblqrgt', pr_tag_cont => TO_CHAR(vr_tab_aplica(vr_contador).idblqrgt), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dsblqrgt', pr_tag_cont => TO_CHAR(vr_tab_aplica(vr_contador).dsblqrgt), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dsresgat', pr_tag_cont => TO_CHAR(vr_tab_aplica(vr_contador).dsresgat), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtresgat', pr_tag_cont => TO_CHAR(vr_tab_aplica(vr_contador).dtresgat, 'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdoperad', pr_tag_cont => TO_CHAR(vr_tab_aplica(vr_contador).cdoperad), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmoperad', pr_tag_cont => TO_CHAR(vr_tab_aplica(vr_contador).nmoperad), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'idtipapl', pr_tag_cont => TO_CHAR(vr_tab_aplica(vr_contador).idtipapl), pr_des_erro => vr_dscritic);

          -- Incrementa contador p/ posicao no XML
          vr_auxconta := vr_auxconta + 1;
        END LOOP;
      END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na APLI0005.pc_busca_aplicacoes_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    END;


  END pc_busca_aplicacoes_web;

  -- Rotina geral para listagem de aplicacoes
  PROCEDURE pc_lista_aplicacoes(pr_cdcooper    IN craprac.cdcooper%TYPE           --> Código da Cooperativa
                               ,pr_cdoperad    IN crapope.cdoperad%TYPE           --> Código do Operador
                               ,pr_nmdatela    IN craptel.nmdatela%TYPE           --> Nome da Tela
                               ,pr_idorigem    IN INTEGER                         --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                               ,pr_nrdcaixa    IN craplot.nrdcaixa%TYPE           --> Numero do Caixa
                               ,pr_nrdconta    IN craprac.nrdconta%TYPE           --> Número da Conta
                               ,pr_idseqttl    IN crapttl.idseqttl%TYPE           --> Titular da Conta
                               ,pr_cdagenci    IN crapage.cdagenci%TYPE           --> Codigo da Agencia
                               ,pr_cdprogra    IN craplog.cdprogra%TYPE           --> Codigo do Programa
                               ,pr_nraplica    IN craprac.nraplica%TYPE DEFAULT 0 --> Número da Aplicação - Parâmetro Opcional
                               ,pr_cdprodut    IN craprac.cdprodut%TYPE DEFAULT 0 --> Código do Produto – Parâmetro Opcional
                               ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE           --> Data de Movimento
                               ,pr_idconsul    IN INTEGER                         --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                               ,pr_idgerlog    IN INTEGER                         --> Identificador de Log (0 – Não / 1 – Sim)
                               ,pr_cdcritic   OUT INTEGER                         --> Código da crítica
                               ,pr_dscritic   OUT VARCHAR2                        --> Descrição da crítica
                               ,pr_saldo_rdca OUT apli0001.typ_tab_saldo_rdca) IS --> Tabela com os dados da aplicação

   BEGIN
   /* .............................................................................

     Programa: pc_lista_aplicacoes
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Agosto/14.                    Ultima atualizacao: 04/12/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina geral referente a listagem de aplicacoes.

     Observacao: -----

     Alteracoes: 05/01/2015 - Foram adicionados novos campos na PLTABLE montada com
                              o retorno dos dados da pc_busca_aplicacoes.
                              (Carlos Rafael Tanholi - Projeto Novos Produtos de Captacao)

                 14/04/2015 - Foram adicionados novos campos na PLTABLE montada com
                              o retorno dos dados da pc_busca_aplicacoes (DTCARENC)
                              SD 266191 (Kelvin).

                 04/12/2018 - Trocar a chamada da gene0001.pc_gera_log pela gene.0001.pc_gera_log_auto e retirada
	                            dos commits que estão impactando na rotina diária (Adriano Nagasava - Supero)
    ..............................................................................*/

    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Declaração da tabela que conterá os dados da aplicação
      vr_tab_aplica APLI0005.typ_tab_aplicacao;
      vr_ind_aplica_tmp VARCHAR2(25);
      vr_saldo_rdca apli0001.typ_tab_saldo_rdca; --> Tabela para armazenar saldos de aplicacao
      vr_saldo_rdca_tmp apli0001.typ_tab_saldo_rdca_tmp; --> Tabela para armazenar saldos de aplicacao
      vr_tab_erro gene0001.typ_tab_erro;         --> Tabela para armazenar os erros

      vr_ind_tab_rdca BINARY_INTEGER;
      vr_nrdrowid ROWID;
      vr_dstransa VARCHAR2(100) := 'Lista aplicacoes.';
      vr_dsorigem VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_contador PLS_INTEGER;

    BEGIN

      -- Consulta de novas aplicacoes
      APLI0005.pc_busca_aplicacoes(pr_cdcooper   => pr_cdcooper     --> Código da Cooperativa
                                  ,pr_cdoperad   => pr_cdoperad     --> Código do Operador
                                  ,pr_nmdatela   => pr_nmdatela     --> Nome da Tela
                                  ,pr_idorigem   => pr_idorigem     --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                  ,pr_nrdconta   => pr_nrdconta     --> Número da Conta
                                  ,pr_idseqttl   => pr_idseqttl     --> Titular da Conta
                                  ,pr_nraplica   => pr_nraplica     --> Número da Aplicação - Parâmetro Opcional
                                  ,pr_cdprodut   => pr_cdprodut     --> Código do Produto – Parâmetro Opcional
                                  ,pr_dtmvtolt   => pr_dtmvtolt     --> Data de Movimento
                                  ,pr_idconsul   => pr_idconsul     --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                  ,pr_idgerlog   => 0               --> Identificador de Log (0 – Não / 1 – Sim)
                                  ,pr_cdcritic   => vr_cdcritic     --> Código da crítica
                                  ,pr_dscritic   => vr_dscritic     --> Descrição da crítica
                                  ,pr_tab_aplica => vr_tab_aplica); --> Tabela com os dados da aplicação );

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Consulta de aplicacoes antigas
      APLI0001.pc_consulta_aplicacoes(pr_cdcooper   => pr_cdcooper   --> Cooperativa
                                     ,pr_cdagenci   => pr_cdagenci   --> Codigo da agencia
                                     ,pr_nrdcaixa   => pr_nrdcaixa   --> Numero do caixa
                                     ,pr_nrdconta   => pr_nrdconta   --> Conta do associado
                                     ,pr_nraplica   => pr_nraplica   --> Numero da aplicacao
                                     ,pr_tpaplica   => 0             --> Tipo de aplicacao
                                     ,pr_dtinicio   => NULL          --> Data de inicio da aplicacao
                                     ,pr_dtfim      => NULL          --> Data final da aplicacao
                                     ,pr_cdprogra   => pr_cdprogra   --> Codigo do programa chamador da rotina
                                     ,pr_nrorigem   => pr_idorigem   --> Origem da chamada da rotina
                                     ,pr_saldo_rdca => vr_saldo_rdca --> Tipo de tabela com o saldo RDCA
                                     ,pr_des_reto   => vr_dscritic   --> OK ou NOK
                                     ,pr_tab_erro   => vr_tab_erro); --> Tabela com erros

      IF vr_dscritic = 'NOK' THEN

        -- Se existir erro adiciona na crítica
        vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

        RAISE vr_exc_saida;

      END IF;

      -- Montagem do XML com todas as aplicacoes que deverao ser exibidas na tela atenda
      IF vr_tab_aplica.COUNT > 0 THEN
        -- Percorre todas as aplicações de captação da conta
        FOR vr_contador IN vr_tab_aplica.FIRST..vr_tab_aplica.LAST LOOP

          -- Proximo indice da tabela vr_saldo_rdca
          vr_ind_tab_rdca := vr_saldo_rdca.COUNT + 1;

          vr_saldo_rdca(vr_ind_tab_rdca).DTMVTOLT := vr_tab_aplica(vr_contador).DTMVTOLT;
          vr_saldo_rdca(vr_ind_tab_rdca).NRAPLICA := vr_tab_aplica(vr_contador).NRAPLICA;
          vr_saldo_rdca(vr_ind_tab_rdca).QTDIAUTI := vr_tab_aplica(vr_contador).QTDIACAR;
          vr_saldo_rdca(vr_ind_tab_rdca).DSHISTOR := vr_tab_aplica(vr_contador).DSNOMENC;
          vr_saldo_rdca(vr_ind_tab_rdca).VLAPLICA := vr_tab_aplica(vr_contador).VLAPLICA;
          vr_saldo_rdca(vr_ind_tab_rdca).NRDOCMTO := vr_tab_aplica(vr_contador).NRAPLICA;
          vr_saldo_rdca(vr_ind_tab_rdca).DTVENCTO := vr_tab_aplica(vr_contador).DTVENCTO;
          vr_saldo_rdca(vr_ind_tab_rdca).INDEBCRE := SUBSTR(vr_tab_aplica(vr_contador).DSBLQRGT,0,1);
          vr_saldo_rdca(vr_ind_tab_rdca).VLLANMTO := vr_tab_aplica(vr_contador).VLSLDTOT;
          vr_saldo_rdca(vr_ind_tab_rdca).VLSDRDAD := vr_tab_aplica(vr_contador).VLSLDTOT;
          vr_saldo_rdca(vr_ind_tab_rdca).SLDRESGA := vr_tab_aplica(vr_contador).VLSLDRGT;
          vr_saldo_rdca(vr_ind_tab_rdca).VLSLDRGT := vr_tab_aplica(vr_contador).VLSLDRGT;
          vr_saldo_rdca(vr_ind_tab_rdca).CDDRESGA := vr_tab_aplica(vr_contador).DSRESGAT;
          vr_saldo_rdca(vr_ind_tab_rdca).DTRESGAT := vr_tab_aplica(vr_contador).DTRESGAT;
          vr_saldo_rdca(vr_ind_tab_rdca).DSSITAPL := vr_tab_aplica(vr_contador).DSBLQRGT;
          vr_saldo_rdca(vr_ind_tab_rdca).TXAPLMAX := vr_tab_aplica(vr_contador).TXAPLICA;
          vr_saldo_rdca(vr_ind_tab_rdca).TXAPLMIN := vr_tab_aplica(vr_contador).TXAPLICA;
          vr_saldo_rdca(vr_ind_tab_rdca).CDPRODUT := NVL(vr_tab_aplica(vr_contador).CDPRODUT,0);
          vr_saldo_rdca(vr_ind_tab_rdca).NMPRODUT := vr_tab_aplica(vr_contador).NMPRODUT;
          vr_saldo_rdca(vr_ind_tab_rdca).IDTIPAPL := vr_tab_aplica(vr_contador).IDTIPAPL;
          vr_saldo_rdca(vr_ind_tab_rdca).TPAPLICA := vr_tab_aplica(vr_contador).CDPRODUT;
          vr_saldo_rdca(vr_ind_tab_rdca).IDTIPPRO := vr_tab_aplica(vr_contador).IDTIPPRO;
          vr_saldo_rdca(vr_ind_tab_rdca).DTCARENC := vr_tab_aplica(vr_contador).DTMVTOLT + vr_tab_aplica(vr_contador).QTDIACAR;
          -- Campos adicionados para serem usados no INTERNET BANK (extrado de aplicacoes)
          vr_saldo_rdca(vr_ind_tab_rdca).PERCIRRF := vr_tab_aplica(vr_contador).PERCIRRF;
          vr_saldo_rdca(vr_ind_tab_rdca).DSNOMENC := vr_tab_aplica(vr_contador).DSNOMENC;
          vr_saldo_rdca(vr_ind_tab_rdca).QTDIAAPL := vr_tab_aplica(vr_contador).QTDIAAPL;
          vr_saldo_rdca(vr_ind_tab_rdca).IDTXFIXA := vr_tab_aplica(vr_contador).IDTXFIXA;
          vr_saldo_rdca(vr_ind_tab_rdca).NMDINDEX := vr_tab_aplica(vr_contador).NMDINDEX;
          vr_saldo_rdca(vr_ind_tab_rdca).CDOPERAD := vr_tab_aplica(vr_contador).CDOPERAD;
          vr_saldo_rdca(vr_ind_tab_rdca).TPAPLRDC := vr_tab_aplica(vr_contador).TPAPLRDC;
          vr_saldo_rdca(vr_ind_tab_rdca).QTDIACAR := vr_tab_aplica(vr_contador).QTDIACAR;
          vr_saldo_rdca(vr_ind_tab_rdca).IDTXFIXA := vr_tab_aplica(vr_contador).IDTXFIXA;

        END LOOP;
      END IF;

      -- Ordenacao da temp-table pelo num da aplicacao
      IF vr_saldo_rdca.count() > 0 THEN
        FOR vr_contador IN vr_saldo_rdca.FIRST..vr_saldo_rdca.LAST LOOP
          vr_ind_aplica_tmp := TO_CHAR(vr_saldo_rdca(vr_contador).dtmvtolt,'RRRRMMDD') || lpad(vr_saldo_rdca(vr_contador).nraplica,15,'0');
          vr_saldo_rdca_tmp(vr_ind_aplica_tmp) := vr_saldo_rdca(vr_contador);
        END LOOP;
      END IF;

      vr_ind_aplica_tmp := vr_saldo_rdca_tmp.FIRST;
      vr_contador := 0;
      vr_saldo_rdca.delete;

      WHILE vr_ind_aplica_tmp IS NOT NULL LOOP
        vr_saldo_rdca(vr_contador) := vr_saldo_rdca_tmp(vr_ind_aplica_tmp);
        vr_ind_aplica_tmp := vr_saldo_rdca_tmp.next(vr_ind_aplica_tmp);
        vr_contador := vr_contador + 1;
      END LOOP;

      pr_saldo_rdca := vr_saldo_rdca;

      -- Verifica se deve gerar log
      IF pr_idgerlog = 1 THEN
        gene0001.pc_gera_log_auto(pr_cdcooper => pr_cdcooper
																 ,pr_cdoperad => pr_cdoperad
																 ,pr_dscritic => pr_dscritic
																 ,pr_dsorigem => vr_dsorigem
																 ,pr_dstransa => vr_dstransa
																 ,pr_dttransa => TRUNC(SYSDATE)
																 ,pr_flgtrans => 0 --> FALSE
																 ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
																 ,pr_idseqttl => pr_idseqttl
																 ,pr_nmdatela => pr_nmdatela
																 ,pr_nrdconta => pr_nrdconta
																 ,pr_nrdrowid => vr_nrdrowid
																 );
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Alimenta parametros com as críticas
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Verifica se deve gerar log
        IF pr_idgerlog = 1 THEN
          gene0001.pc_gera_log_auto(pr_cdcooper => pr_cdcooper
																	 ,pr_cdoperad => pr_cdoperad
																	 ,pr_dscritic => pr_dscritic
																	 ,pr_dsorigem => vr_dsorigem
																	 ,pr_dstransa => vr_dstransa
																	 ,pr_dttransa => TRUNC(SYSDATE)
																	 ,pr_flgtrans => 0 --> FALSE
																	 ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
																	 ,pr_idseqttl => pr_idseqttl
																	 ,pr_nmdatela => pr_nmdatela
																	 ,pr_nrdconta => pr_nrdconta
																	 ,pr_nrdrowid => vr_nrdrowid
																	 );
        END IF;

      WHEN OTHERS THEN

        -- Verifica se deve gerar log
        IF pr_idgerlog = 1 THEN
          gene0001.pc_gera_log_auto(pr_cdcooper => pr_cdcooper
																	 ,pr_cdoperad => pr_cdoperad
																	 ,pr_dscritic => pr_dscritic
																	 ,pr_dsorigem => vr_dsorigem
																	 ,pr_dstransa => vr_dstransa
																	 ,pr_dttransa => TRUNC(SYSDATE)
																	 ,pr_flgtrans => 0 --> FALSE
																	 ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
																	 ,pr_idseqttl => pr_idseqttl
																	 ,pr_nmdatela => pr_nmdatela
																	 ,pr_nrdconta => pr_nrdconta
																	 ,pr_nrdrowid => vr_nrdrowid
																	 );
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na APLI0005.pc_lista_aplicacoes: ' || SQLERRM;
    END;
  END pc_lista_aplicacoes;

  -- Rotina geral para listagem de aplicacoes WEB
  PROCEDURE pc_lista_aplicacoes_web(pr_nrdconta  IN craprac.nrdconta%TYPE           --> Número da Conta
                                   ,pr_idseqttl  IN crapttl.idseqttl%TYPE           --> Titular da Conta
                                   ,pr_nraplica  IN craprac.nraplica%TYPE DEFAULT 0 --> Número da Aplicação - Parâmetro Opcional
                                   ,pr_cdprodut  IN craprac.cdprodut%TYPE DEFAULT 0 --> Código do Produto – Parâmetro Opcional
                                   ,pr_idconsul  IN INTEGER                         --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                   ,pr_idgerlog  IN INTEGER                         --> Identificador de Log (0 – Não / 1 – Sim)
                                   ,pr_xmllog    IN VARCHAR2                        --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER                     --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2                        --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType               --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2                        --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS                    --> Erros do processo

   BEGIN
   /* .............................................................................

     Programa: pc_lista_aplicacoes_web
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Agosto/14.                    Ultima atualizacao: 14/04/2015

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a listagem de aplicacoes Ayllos WEB.

     Observacao: -----

     Alteracoes: 14/04/2015 - Foram adicionados novos campos para retorno
                             (DTCARENC) SD 266191 (Kelvin).

                 27/11/2017 - Foram adicionados novos campos para retorno
                             (tpaplica). Projeto 404 (Lombardi).
    ..............................................................................*/

    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      vr_saldo_rdca apli0001.typ_tab_saldo_rdca;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Variaveis de XML
      vr_xml_temp VARCHAR2(32767);
      vr_clobxmlc CLOB;

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
        RAISE vr_exc_saida;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;

      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Carrega PL table com aplicacoes da conta
      APLI0005.pc_lista_aplicacoes(pr_cdcooper => vr_cdcooper         --> Código da Cooperativa
                                  ,pr_cdoperad => vr_cdoperad         --> Codigo do Operador
                                  ,pr_nmdatela => vr_nmdatela         --> Nome da tela
                                  ,pr_idorigem => vr_idorigem         --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                  ,pr_nrdcaixa => vr_nrdcaixa         --> Numero do Caixa
                                  ,pr_nrdconta => pr_nrdconta         --> Número da Conta
                                  ,pr_idseqttl => pr_idseqttl         --> Titular da Conta
                                  ,pr_cdagenci => vr_cdagenci         --> Codigo da Agencia
                                  ,pr_cdprogra => vr_nmdatela         --> Codigo do Programa
                                  ,pr_nraplica => pr_nraplica         --> Número da Aplicação - Parâmetro Opcional
                                  ,pr_cdprodut => pr_cdprodut         --> Código do Produto – Parâmetro Opcional
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data de Movimento
                                  ,pr_idconsul => pr_idconsul         --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                  ,pr_idgerlog => pr_idgerlog         --> Identificador de Log (0 – Não / 1 – Sim)
                                  ,pr_cdcritic => vr_cdcritic         --> Código da crítica
                                  ,pr_dscritic => vr_dscritic         --> Descrição da crítica
                                  ,pr_saldo_rdca => vr_saldo_rdca);   --> Tabela com os dados da aplicação

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Criar cabeçalho do XML
      dbms_lob.createtemporary(vr_clobxmlc, TRUE);
      dbms_lob.open(vr_clobxmlc, dbms_lob.lob_readwrite);
      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><Dados>');

      IF vr_saldo_rdca.COUNT() > 0 THEN
        -- Percorre todas as aplicações de captação da conta
        FOR vr_contador IN vr_saldo_rdca.FIRST..vr_saldo_rdca.LAST LOOP

          IF NOT vr_saldo_rdca.exists(vr_contador) THEN
            CONTINUE;
          END IF;

          -- Insere as tags dos campos da PLTABLE de aplicações
          gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     =>
          '<inf>
           <dtmvtolt>' || TO_CHAR(vr_saldo_rdca(vr_contador).dtmvtolt,'dd/mm/RRRR') || '</dtmvtolt>
           <nraplica>' || TO_CHAR(vr_saldo_rdca(vr_contador).nraplica) || '</nraplica>
           <qtdiauti>' || TO_CHAR(vr_saldo_rdca(vr_contador).qtdiauti) || '</qtdiauti>
           <dshistor>' || TO_CHAR(vr_saldo_rdca(vr_contador).dshistor) || '</dshistor>
           <vlaplica>' || TO_CHAR(vr_saldo_rdca(vr_contador).vlaplica) || '</vlaplica>
           <nrdocmto>' || TO_CHAR(vr_saldo_rdca(vr_contador).nrdocmto) || '</nrdocmto>
           <dtvencto>' || TO_CHAR(vr_saldo_rdca(vr_contador).dtvencto,'dd/mm/RRRR') || '</dtvencto>
           <indebcre>' || TO_CHAR(vr_saldo_rdca(vr_contador).indebcre) || '</indebcre>
           <vllanmto>' || TO_CHAR(vr_saldo_rdca(vr_contador).vllanmto) || '</vllanmto>
           <sldresga>' || TO_CHAR(vr_saldo_rdca(vr_contador).sldresga) || '</sldresga>
           <cddresga>' || TO_CHAR(vr_saldo_rdca(vr_contador).cddresga) || '</cddresga>
           <dtresgat>' || TO_CHAR(vr_saldo_rdca(vr_contador).dtresgat,'dd/mm/RRRR') || '</dtresgat>
           <dssitapl>' || TO_CHAR(vr_saldo_rdca(vr_contador).dssitapl) || '</dssitapl>
           <txaplmax>' || TO_CHAR(vr_saldo_rdca(vr_contador).txaplmax,'fm9990D00000000','NLS_NUMERIC_CHARACTERS=,.') || '</txaplmax>
           <txaplmin>' || TO_CHAR(vr_saldo_rdca(vr_contador).txaplmin,'fm9990D00000000','NLS_NUMERIC_CHARACTERS=,.') || '</txaplmin>
           <cdprodut>' || TO_CHAR(vr_saldo_rdca(vr_contador).cdprodut) || '</cdprodut>
           <idtipapl>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).idtipapl),'A') || '</idtipapl>
           <qtdiaapl>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).qtdiaapl),'0') || '</qtdiaapl>
           <dsaplica>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).dsaplica),'')  || '</dsaplica>
           <cdoperad>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).cdoperad),'1') || '</cdoperad>
           <tpaplrdc>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).tpaplrdc),'0') || '</tpaplrdc>
           <qtdiacar>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).qtdiacar),'0') || '</qtdiacar>
           <nmprodut>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).nmprodut),' ') || '</nmprodut>
           <idtxfixa>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).idtxfixa),'0') || '</idtxfixa>
           <percirrf>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).percirrf),'0') || '</percirrf>
           <vlsldrgt>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).vlsldrgt),'0') || '</vlsldrgt>
           <dsnomenc>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).dsnomenc),' ') || '</dsnomenc>
           <idtippro>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).idtippro),'0') || '</idtippro>
           <dtcarenc>' || TO_CHAR(vr_saldo_rdca(vr_contador).dtcarenc,'dd/mm/RRRR') || '</dtcarenc>
           <tpaplica>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).tpaplica),'0') || '</tpaplica>
           </inf>');
        END LOOP;

      END IF;

      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Dados>'
                             ,pr_fecha_xml      => TRUE);

      pr_retxml := XMLType.createXML(vr_clobxmlc);

    EXCEPTION
      WHEN vr_exc_saida THEN

        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN

        cecred.pc_internal_exception(vr_cdcooper, pr_nrdconta);

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em APLI0005.pc_lista_aplicacoes_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_lista_aplicacoes_web;

  -- Rotina geral para listagem de aplicacoes
  PROCEDURE pc_lista_apli_demon(pr_cdcooper    IN craprac.cdcooper%TYPE           --> Código da Cooperativa
                               ,pr_cdoperad    IN crapope.cdoperad%TYPE           --> Código do Operador
                               ,pr_nmdatela    IN craptel.nmdatela%TYPE           --> Nome da Tela
                               ,pr_idorigem    IN INTEGER                         --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                               ,pr_nrdcaixa    IN craplot.nrdcaixa%TYPE           --> Numero do Caixa
                               ,pr_nrdconta    IN craprac.nrdconta%TYPE           --> Número da Conta
                               ,pr_idseqttl    IN crapttl.idseqttl%TYPE           --> Titular da Conta
                               ,pr_cdagenci    IN crapage.cdagenci%TYPE           --> Codigo da Agencia
                               ,pr_cdprogra    IN craplog.cdprogra%TYPE           --> Codigo do Programa
                               ,pr_nraplica    IN craprac.nraplica%TYPE DEFAULT 0 --> Número da Aplicação - Parâmetro Opcional
                               ,pr_cdprodut    IN craprac.cdprodut%TYPE DEFAULT 0 --> Código do Produto – Parâmetro Opcional
                               ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE           --> Data de Movimento
                               ,pr_idconsul    IN INTEGER                         --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                               ,pr_idgerlog    IN INTEGER                         --> Identificador de Log (0 – Não / 1 – Sim)
                               ,pr_dtinicio    IN DATE
                               ,pr_dtfim       IN DATE
                               ,pr_cdcritic   OUT INTEGER                         --> Código da crítica
                               ,pr_dscritic   OUT VARCHAR2                        --> Descrição da crítica
                               ,pr_saldo_rdca OUT apli0001.typ_tab_saldo_rdca) IS --> Tabela com os dados da aplicação

   BEGIN
   /* .............................................................................

     Programa: pc_lista_aplicacoes
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Agosto/14.                    Ultima atualizacao: 14/04/2015

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina geral referente a listagem de aplicacoes.

     Observacao: -----

     Alteracoes: 05/01/2015 - Foram adicionados novos campos na PLTABLE montada com
                              o retorno dos dados da pc_busca_aplicacoes.
                              (Carlos Rafael Tanholi - Projeto Novos Produtos de Captacao)

                 14/04/2015 - Foram adicionados novos campos na PLTABLE montada com
                              o retorno dos dados da pc_busca_aplicacoes (DTCARENC)
                              SD 266191 (Kelvin).
    ..............................................................................*/

    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Declaração da tabela que conterá os dados da aplicação
      vr_tab_aplica APLI0005.typ_tab_aplicacao;
      vr_ind_aplica_tmp VARCHAR2(25);
      vr_saldo_rdca apli0001.typ_tab_saldo_rdca; --> Tabela para armazenar saldos de aplicacao
      vr_saldo_rdca_tmp apli0001.typ_tab_saldo_rdca_tmp; --> Tabela para armazenar saldos de aplicacao
      vr_tab_erro gene0001.typ_tab_erro;         --> Tabela para armazenar os erros

      vr_ind_tab_rdca BINARY_INTEGER;
      vr_nrdrowid ROWID;
      vr_dstransa VARCHAR2(100) := 'Lista aplicacoes.';
      vr_dsorigem VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_contador PLS_INTEGER;

    BEGIN

      -- Consulta de novas aplicacoes
      APLI0005.pc_busca_aplicacoes(pr_cdcooper   => pr_cdcooper     --> Código da Cooperativa
                                  ,pr_cdoperad   => pr_cdoperad     --> Código do Operador
                                  ,pr_nmdatela   => pr_nmdatela     --> Nome da Tela
                                  ,pr_idorigem   => pr_idorigem     --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                  ,pr_nrdconta   => pr_nrdconta     --> Número da Conta
                                  ,pr_idseqttl   => pr_idseqttl     --> Titular da Conta
                                  ,pr_nraplica   => pr_nraplica     --> Número da Aplicação - Parâmetro Opcional
                                  ,pr_cdprodut   => pr_cdprodut     --> Código do Produto – Parâmetro Opcional
                                  ,pr_dtmvtolt   => pr_dtmvtolt     --> Data de Movimento
                                  ,pr_idconsul   => pr_idconsul     --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                  ,pr_idgerlog   => 0               --> Identificador de Log (0 – Não / 1 – Sim)
                                  ,pr_cdcritic   => vr_cdcritic     --> Código da crítica
                                  ,pr_dscritic   => vr_dscritic     --> Descrição da crítica
                                  ,pr_tab_aplica => vr_tab_aplica); --> Tabela com os dados da aplicação );

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Consulta de aplicacoes antigas
      APLI0001.pc_consulta_aplicacoes(pr_cdcooper   => pr_cdcooper   --> Cooperativa
                                     ,pr_cdagenci   => pr_cdagenci   --> Codigo da agencia
                                     ,pr_nrdcaixa   => pr_nrdcaixa   --> Numero do caixa
                                     ,pr_nrdconta   => pr_nrdconta   --> Conta do associado
                                     ,pr_nraplica   => pr_nraplica   --> Numero da aplicacao
                                     ,pr_tpaplica   => 0             --> Tipo de aplicacao
                                     ,pr_dtinicio   => pr_dtinicio   --> Data de inicio da aplicacao
                                     ,pr_dtfim      => pr_dtfim      --> Data final da aplicacao
                                     ,pr_cdprogra   => pr_cdprogra   --> Codigo do programa chamador da rotina
                                     ,pr_nrorigem   => pr_idorigem   --> Origem da chamada da rotina
                                     ,pr_saldo_rdca => vr_saldo_rdca --> Tipo de tabela com o saldo RDCA
                                     ,pr_des_reto   => vr_dscritic   --> OK ou NOK
                                     ,pr_tab_erro   => vr_tab_erro); --> Tabela com erros

      IF vr_dscritic = 'NOK' THEN

        -- Se existir erro adiciona na crítica
        vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

        RAISE vr_exc_saida;

      END IF;

      -- Montagem do XML com todas as aplicacoes que deverao ser exibidas na tela atenda
      IF vr_tab_aplica.COUNT > 0 THEN
        -- Percorre todas as aplicações de captação da conta
        FOR vr_contador IN vr_tab_aplica.FIRST..vr_tab_aplica.LAST LOOP

          -- Proximo indice da tabela vr_saldo_rdca
          vr_ind_tab_rdca := vr_saldo_rdca.COUNT + 1;

          vr_saldo_rdca(vr_ind_tab_rdca).DTMVTOLT := vr_tab_aplica(vr_contador).DTMVTOLT;
          vr_saldo_rdca(vr_ind_tab_rdca).NRAPLICA := vr_tab_aplica(vr_contador).NRAPLICA;
          vr_saldo_rdca(vr_ind_tab_rdca).QTDIAUTI := vr_tab_aplica(vr_contador).QTDIACAR;
          vr_saldo_rdca(vr_ind_tab_rdca).DSHISTOR := vr_tab_aplica(vr_contador).DSNOMENC;
          vr_saldo_rdca(vr_ind_tab_rdca).VLAPLICA := vr_tab_aplica(vr_contador).VLAPLICA;
          vr_saldo_rdca(vr_ind_tab_rdca).NRDOCMTO := vr_tab_aplica(vr_contador).NRAPLICA;
          vr_saldo_rdca(vr_ind_tab_rdca).DTVENCTO := vr_tab_aplica(vr_contador).DTVENCTO;
          vr_saldo_rdca(vr_ind_tab_rdca).INDEBCRE := SUBSTR(vr_tab_aplica(vr_contador).DSBLQRGT,0,1);
          vr_saldo_rdca(vr_ind_tab_rdca).VLLANMTO := vr_tab_aplica(vr_contador).VLSLDTOT;
          vr_saldo_rdca(vr_ind_tab_rdca).VLSDRDAD := vr_tab_aplica(vr_contador).VLSLDTOT;
          vr_saldo_rdca(vr_ind_tab_rdca).SLDRESGA := vr_tab_aplica(vr_contador).VLSLDRGT;
          vr_saldo_rdca(vr_ind_tab_rdca).VLSLDRGT := vr_tab_aplica(vr_contador).VLSLDRGT;
          vr_saldo_rdca(vr_ind_tab_rdca).CDDRESGA := vr_tab_aplica(vr_contador).DSRESGAT;
          vr_saldo_rdca(vr_ind_tab_rdca).DTRESGAT := vr_tab_aplica(vr_contador).DTRESGAT;
          vr_saldo_rdca(vr_ind_tab_rdca).DSSITAPL := vr_tab_aplica(vr_contador).DSBLQRGT;
          vr_saldo_rdca(vr_ind_tab_rdca).TXAPLMAX := vr_tab_aplica(vr_contador).TXAPLICA;
          vr_saldo_rdca(vr_ind_tab_rdca).TXAPLMIN := vr_tab_aplica(vr_contador).TXAPLICA;
          vr_saldo_rdca(vr_ind_tab_rdca).CDPRODUT := NVL(vr_tab_aplica(vr_contador).CDPRODUT,0);
          vr_saldo_rdca(vr_ind_tab_rdca).NMPRODUT := vr_tab_aplica(vr_contador).NMPRODUT;
          vr_saldo_rdca(vr_ind_tab_rdca).IDTIPAPL := vr_tab_aplica(vr_contador).IDTIPAPL;
          vr_saldo_rdca(vr_ind_tab_rdca).TPAPLICA := vr_tab_aplica(vr_contador).CDPRODUT;
          vr_saldo_rdca(vr_ind_tab_rdca).IDTIPPRO := vr_tab_aplica(vr_contador).IDTIPPRO;
          vr_saldo_rdca(vr_ind_tab_rdca).DTCARENC := vr_tab_aplica(vr_contador).DTMVTOLT + vr_tab_aplica(vr_contador).QTDIACAR;
          -- Campos adicionados para serem usados no INTERNET BANK (extrado de aplicacoes)
          vr_saldo_rdca(vr_ind_tab_rdca).PERCIRRF := vr_tab_aplica(vr_contador).PERCIRRF;
          vr_saldo_rdca(vr_ind_tab_rdca).DSNOMENC := vr_tab_aplica(vr_contador).DSNOMENC;
          vr_saldo_rdca(vr_ind_tab_rdca).QTDIAAPL := vr_tab_aplica(vr_contador).QTDIAAPL;
          vr_saldo_rdca(vr_ind_tab_rdca).IDTXFIXA := vr_tab_aplica(vr_contador).IDTXFIXA;
          vr_saldo_rdca(vr_ind_tab_rdca).NMDINDEX := vr_tab_aplica(vr_contador).NMDINDEX;
          vr_saldo_rdca(vr_ind_tab_rdca).CDOPERAD := vr_tab_aplica(vr_contador).CDOPERAD;
          vr_saldo_rdca(vr_ind_tab_rdca).TPAPLRDC := vr_tab_aplica(vr_contador).TPAPLRDC;
          vr_saldo_rdca(vr_ind_tab_rdca).QTDIACAR := vr_tab_aplica(vr_contador).QTDIACAR;
          vr_saldo_rdca(vr_ind_tab_rdca).IDTXFIXA := vr_tab_aplica(vr_contador).IDTXFIXA;

        END LOOP;
      END IF;

      -- Ordenacao da temp-table pelo num da aplicacao
      IF vr_saldo_rdca.count() > 0 THEN
        FOR vr_contador IN vr_saldo_rdca.FIRST..vr_saldo_rdca.LAST LOOP
          vr_ind_aplica_tmp := TO_CHAR(vr_saldo_rdca(vr_contador).dtmvtolt,'RRRRMMDD') || lpad(vr_saldo_rdca(vr_contador).nraplica,15,'0');
          vr_saldo_rdca_tmp(vr_ind_aplica_tmp) := vr_saldo_rdca(vr_contador);
        END LOOP;
      END IF;

      vr_ind_aplica_tmp := vr_saldo_rdca_tmp.FIRST;
      vr_contador := 0;
      vr_saldo_rdca.delete;

      WHILE vr_ind_aplica_tmp IS NOT NULL LOOP
        vr_saldo_rdca(vr_contador) := vr_saldo_rdca_tmp(vr_ind_aplica_tmp);
        vr_ind_aplica_tmp := vr_saldo_rdca_tmp.next(vr_ind_aplica_tmp);
        vr_contador := vr_contador + 1;
      END LOOP;

      pr_saldo_rdca := vr_saldo_rdca;

      -- Verifica se deve gerar log
      IF pr_idgerlog = 1 THEN
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => pr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Alimenta parametros com as críticas
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Verifica se deve gerar log
        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => pr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
          COMMIT;
        END IF;

      WHEN OTHERS THEN

        -- Verifica se deve gerar log
        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => pr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
          COMMIT;
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na APLI0005.pc_lista_aplicacoes: ' || SQLERRM;
    END;
  END pc_lista_apli_demon;

  PROCEDURE pc_lista_demons_apli(pr_cdcooper  IN craprac.cdcooper%TYPE           --> Código da Cooperativa
                                ,pr_cdoperad  IN crapope.cdoperad%TYPE DEFAULT 1 --> Código do Operador
                                ,pr_nmdatela  IN craptel.nmdatela%TYPE           --> Nome da Tela
                                ,pr_idorigem  IN INTEGER                         --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE           --> Numero do Caixa
                                ,pr_nrdconta  IN craprac.nrdconta%TYPE           --> Número da Conta
                                ,pr_idseqttl  IN crapttl.idseqttl%TYPE           --> Titular da Conta
                                ,pr_cdagenci  IN crapage.cdagenci%TYPE           --> Codigo da Agencia
                                ,pr_cdprogra  IN craplog.cdprogra%TYPE           --> Codigo do Programa
                                ,pr_nraplica  IN craprac.nraplica%TYPE DEFAULT 0 --> Número da Aplicação - Parâmetro Opcional
                                ,pr_cdprodut  IN craprac.cdprodut%TYPE DEFAULT 0 --> Código do Produto – Parâmetro Opcional
                                ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE           --> Data de Movimento
                                ,pr_idconsul  IN INTEGER                         --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                ,pr_idgerlog  IN INTEGER                         --> Identificador de Log (0 – Não / 1 – Sim)
                                ,pr_dtinicio  IN DATE
                                ,pr_dtfim     IN DATE
                                ,pr_clobxmlc OUT CLOB                            --> XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER                     --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2) IS                    --> Descrição da crítica
    BEGIN
   /* .............................................................................

     Programa: pc_lista_aplicacoes_car
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Agosto/14.                    Ultima atualizacao: 14/04/2015

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a listagem de aplicacoes para o Ayllos caractere.

     Observacao: -----

     Alteracoes: 08/09/2014 - Adicionar o tipo de aplicação no xml de retorno.
                              (Douglas - Projeto Captação Internet 2014/2)

                 14/04/2015 - Adicionar o tipo de aplicação no xml de retorno
                              (DTCARENC) SD 266191 (Kelvin).
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Temp Table
      vr_saldo_rdca apli0001.typ_tab_saldo_rdca;

      -- Variaveis de XML
      vr_xml_temp VARCHAR2(32767);

      vr_dshistor VARCHAR2(100);
    BEGIN

      -- pc_lista_aplicacoes com pr_dtinicio e pr_dtfim
      APLI0005.pc_lista_apli_demon(pr_cdcooper => pr_cdcooper         --> Código da Cooperativa
                                  ,pr_cdoperad => pr_cdoperad         --> Codigo do Operador
                                  ,pr_nmdatela => pr_nmdatela         --> Nome da tela
                                  ,pr_idorigem => pr_idorigem         --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                  ,pr_nrdcaixa => pr_nrdcaixa         --> Numero do Caixa
                                  ,pr_nrdconta => pr_nrdconta         --> Número da Conta
                                  ,pr_idseqttl => pr_idseqttl         --> Titular da Conta
                                  ,pr_cdagenci => pr_cdagenci         --> Codigo da Agencia
                                  ,pr_cdprogra => pr_nmdatela         --> Codigo do Programa
                                  ,pr_nraplica => pr_nraplica         --> Número da Aplicação - Parâmetro Opcional
                                  ,pr_cdprodut => pr_cdprodut         --> Código do Produto – Parâmetro Opcional
                                  ,pr_dtmvtolt => pr_dtmvtolt         --> Data de Movimento
                                  ,pr_idconsul => pr_idconsul         --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                  ,pr_idgerlog => pr_idgerlog         --> Identificador de Log (0 – Não / 1 – Sim)
                                  ,pr_dtinicio => pr_dtinicio
                                  ,pr_dtfim    => pr_dtfim
                                  ,pr_cdcritic => vr_cdcritic         --> Código da crítica
                                  ,pr_dscritic => vr_dscritic         --> Descrição da crítica
                                  ,pr_saldo_rdca => vr_saldo_rdca);   --> Tabela com os dados da aplicação

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      IF vr_saldo_rdca.count() > 0 THEN
        -- Criar documento XML
        dbms_lob.createtemporary(pr_clobxmlc, TRUE);
        dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);

        -- Insere o cabeçalho do XML
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');

        -- Percorre todas as aplicações de captação da conta
        FOR vr_contador IN vr_saldo_rdca.FIRST..vr_saldo_rdca.LAST LOOP

          IF NOT vr_saldo_rdca.exists(vr_contador) THEN
            CONTINUE;
          END IF;

          vr_dshistor := vr_saldo_rdca(vr_contador).dshistor;
          vr_dshistor := REPLACE(vr_dshistor,'Apl. ','');

          vr_dshistor := SUBSTR(vr_dshistor,1,INSTR(vr_dshistor,':')-1);

          IF vr_dshistor = '0' OR vr_dshistor IS NULL THEN
            vr_dshistor := NVL(vr_saldo_rdca(vr_contador).dshistor,'0');
          END IF;

          -- Montar XML com registros de aplicação
          gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<aplicacao>'
                                                    ||  '<nraplica>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).nraplica),'0') || '</nraplica>'
                                                    ||  '<qtdiauti>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).qtdiauti),'0') || '</qtdiauti>'
                                                    ||  '<dshistor>' || NVL(vr_dshistor,0) || '</dshistor>'
                                                    ||  '<vlaplica>' || NVL(TRIM(TO_CHAR(vr_saldo_rdca(vr_contador).vlaplica,'999g999g9990d00')),'0') || '</vlaplica>'
                                                    ||  '<vlsdrdad>' || NVL(TRIM(TO_CHAR(vr_saldo_rdca(vr_contador).vlsdrdad,'999g999g9990d00')),'0') || '</vlsdrdad>'
                                                    ||  '<nrdocmto>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).nrdocmto),'0') || '</nrdocmto>'
                                                    ||  '<indebcre>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).indebcre),'0') || '</indebcre>'
                                                    ||  '<vllanmto>' || NVL(TRIM(TO_CHAR(vr_saldo_rdca(vr_contador).vllanmto,'999g999g9990d00')),'0') || '</vllanmto>'
                                                    ||  '<qtdiacar>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).qtdiacar),' ') || '</qtdiacar>'
                                                    ||  '<sldresga>' || NVL(TRIM(TO_CHAR(vr_saldo_rdca(vr_contador).sldresga,'999g999g9990d00')),'0') || '</sldresga>'
                                                    ||  '<cddresga>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).cddresga),'0') || '</cddresga>'
                                                    ||  '<dssitapl>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).dssitapl),'0') || '</dssitapl>'
                                                    ||  '<txaplmax>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).txaplmax,'fm9990D00000000'),'0,00') || '</txaplmax>'
                                                    ||  '<txaplmin>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).txaplmin,'fm9990D00000000'),'0,00') || '</txaplmin>'
                                                    ||  '<cdprodut>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).cdprodut),'0') || '</cdprodut>'
                                                    ||  '<dtmvtolt>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).dtmvtolt,'dd/mm/RRRR'),' ') ||  '</dtmvtolt>'
                                                    ||  '<dtvencto>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).dtvencto,'dd/mm/RRRR'),' ') ||  '</dtvencto>'
                                                    ||  '<dtresgat>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).dtresgat,'dd/mm/RRRR'),' ') ||  '</dtresgat>'
                                                    ||  '<tpaplica>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).tpaplica),'0') ||  '</tpaplica>'
                                                    ||  '<idtipapl>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).idtipapl),'A') ||  '</idtipapl>'
                                                    ||  '<nmdindex>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).nmdindex),' ') ||  '</nmdindex>'
                                                    ||  '<qtdiaapl>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).qtdiaapl),' ') || '</qtdiaapl>'
                                                    ||  '<dsaplica>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).dsaplica),' ') || '</dsaplica>'
                                                    ||  '<cdoperad>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).cdoperad),' ') || '</cdoperad>'
                                                    ||  '<tpaplrdc>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).tpaplrdc),' ') || '</tpaplrdc>'
                                                    ||  '<nmprodut>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).nmprodut),' ') || '</nmprodut>'
                                                    ||  '<idtxfixa>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).idtxfixa),' ') || '</idtxfixa>'
                                                    ||  '<percirrf>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).percirrf),' ') || '</percirrf>'
                                                    ||  '<vlsldrgt>' || NVL(TRIM(TO_CHAR(vr_saldo_rdca(vr_contador).vlsldrgt,'999g999g9990d00')),'0') || '</vlsldrgt>'
                                                    ||  '<dsnomenc>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).dsnomenc),' ') || '</dsnomenc>'
                                                    ||  '<idtippro>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).idtippro),' ') || '</idtippro>'
                                                    ||  '<dtcarenc>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).dtcarenc,'dd/mm/RRRR'),' ') ||  '</dtcarenc>'
                                                    || '</aplicacao>');

        END LOOP;

        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</root>'
                               ,pr_fecha_xml      => TRUE);
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na busca de aplicacoes APLI0005.pc_lista_aplicacoes_car: ' || SQLERRM;

    END;
  END pc_lista_demons_apli;

  PROCEDURE pc_lista_aplicacoes_car(pr_cdcooper  IN craprac.cdcooper%TYPE           --> Código da Cooperativa
                                   ,pr_cdoperad  IN crapope.cdoperad%TYPE DEFAULT 1 --> Código do Operador
                                   ,pr_nmdatela  IN craptel.nmdatela%TYPE           --> Nome da Tela
                                   ,pr_idorigem  IN INTEGER                         --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                   ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE           --> Numero do Caixa
                                   ,pr_nrdconta  IN craprac.nrdconta%TYPE           --> Número da Conta
                                   ,pr_idseqttl  IN crapttl.idseqttl%TYPE           --> Titular da Conta
                                   ,pr_cdagenci  IN crapage.cdagenci%TYPE           --> Codigo da Agencia
                                   ,pr_cdprogra  IN craplog.cdprogra%TYPE           --> Codigo do Programa
                                   ,pr_nraplica  IN craprac.nraplica%TYPE DEFAULT 0 --> Número da Aplicação - Parâmetro Opcional
                                   ,pr_cdprodut  IN craprac.cdprodut%TYPE DEFAULT 0 --> Código do Produto – Parâmetro Opcional
                                   ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE           --> Data de Movimento
                                   ,pr_idconsul  IN INTEGER                         --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                   ,pr_idgerlog  IN INTEGER                         --> Identificador de Log (0 – Não / 1 – Sim)
                                   ,pr_clobxmlc OUT CLOB                            --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER                     --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2) IS                    --> Descrição da crítica

    BEGIN
   /* .............................................................................

     Programa: pc_lista_aplicacoes_car
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Agosto/14.                    Ultima atualizacao: 14/04/2015

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a listagem de aplicacoes para o Ayllos caractere.

     Observacao: -----

     Alteracoes: 08/09/2014 - Adicionar o tipo de aplicação no xml de retorno.
                              (Douglas - Projeto Captação Internet 2014/2)

                 14/04/2015 - Adicionar o tipo de aplicação no xml de retorno
                              (DTCARENC) SD 266191 (Kelvin).
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Temp Table
      vr_saldo_rdca apli0001.typ_tab_saldo_rdca;

      -- Variaveis de XML
      vr_xml_temp VARCHAR2(32767);

      vr_dshistor VARCHAR2(100);
    BEGIN

      -- Carrega PL table com aplicacoes da conta
      APLI0005.pc_lista_aplicacoes(pr_cdcooper => pr_cdcooper         --> Código da Cooperativa
                                  ,pr_cdoperad => pr_cdoperad         --> Codigo do Operador
                                  ,pr_nmdatela => pr_nmdatela         --> Nome da tela
                                  ,pr_idorigem => pr_idorigem         --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                  ,pr_nrdcaixa => pr_nrdcaixa         --> Numero do Caixa
                                  ,pr_nrdconta => pr_nrdconta         --> Número da Conta
                                  ,pr_idseqttl => pr_idseqttl         --> Titular da Conta
                                  ,pr_cdagenci => pr_cdagenci         --> Codigo da Agencia
                                  ,pr_cdprogra => pr_nmdatela         --> Codigo do Programa
                                  ,pr_nraplica => pr_nraplica         --> Número da Aplicação - Parâmetro Opcional
                                  ,pr_cdprodut => pr_cdprodut         --> Código do Produto – Parâmetro Opcional
                                  ,pr_dtmvtolt => pr_dtmvtolt         --> Data de Movimento
                                  ,pr_idconsul => pr_idconsul         --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                  ,pr_idgerlog => pr_idgerlog         --> Identificador de Log (0 – Não / 1 – Sim)
                                  ,pr_cdcritic => vr_cdcritic         --> Código da crítica
                                  ,pr_dscritic => vr_dscritic         --> Descrição da crítica
                                  ,pr_saldo_rdca => vr_saldo_rdca);   --> Tabela com os dados da aplicação

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      IF vr_saldo_rdca.count() > 0 THEN
        -- Criar documento XML
        dbms_lob.createtemporary(pr_clobxmlc, TRUE);
        dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);

        -- Insere o cabeçalho do XML
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');


        -- Percorre todas as aplicações de captação da conta
        FOR vr_contador IN vr_saldo_rdca.FIRST..vr_saldo_rdca.LAST LOOP

          IF NOT vr_saldo_rdca.exists(vr_contador) THEN
            CONTINUE;
          END IF;

          vr_dshistor := vr_saldo_rdca(vr_contador).dshistor;
          vr_dshistor := REPLACE(vr_dshistor,'Apl. ','');

          vr_dshistor := SUBSTR(vr_dshistor,1,INSTR(vr_dshistor,':')-1);

          IF vr_dshistor = '0' OR vr_dshistor IS NULL THEN
            vr_dshistor := NVL(vr_saldo_rdca(vr_contador).dshistor,'0');
          END IF;

          -- Montar XML com registros de aplicação
          gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<aplicacao>'
                                                    ||  '<nraplica>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).nraplica),'0') || '</nraplica>'
                                                    ||  '<qtdiauti>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).qtdiauti),'0') || '</qtdiauti>'
                                                    ||  '<dshistor>' || NVL(vr_dshistor,0) || '</dshistor>'
                                                    ||  '<vlaplica>' || NVL(TRIM(TO_CHAR(vr_saldo_rdca(vr_contador).vlaplica,'999g999g9990d00')),'0') || '</vlaplica>'
                                                    ||  '<vlsdrdad>' || NVL(TRIM(TO_CHAR(vr_saldo_rdca(vr_contador).vlsdrdad,'999g999g9990d00')),'0') || '</vlsdrdad>'
                                                    ||  '<nrdocmto>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).nrdocmto),'0') || '</nrdocmto>'
                                                    ||  '<indebcre>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).indebcre),'0') || '</indebcre>'
                                                    ||  '<vllanmto>' || NVL(TRIM(TO_CHAR(vr_saldo_rdca(vr_contador).vllanmto,'999g999g9990d00')),'0') || '</vllanmto>'
                                                    ||  '<qtdiacar>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).qtdiacar),' ') || '</qtdiacar>'
                                                    ||  '<sldresga>' || NVL(TRIM(TO_CHAR(vr_saldo_rdca(vr_contador).sldresga,'999g999g9990d00')),'0') || '</sldresga>'
                                                    ||  '<cddresga>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).cddresga),'0') || '</cddresga>'
                                                    ||  '<dssitapl>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).dssitapl),'0') || '</dssitapl>'
                                                    ||  '<txaplmax>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).txaplmax,'fm9990D00000000'),'0,00') || '</txaplmax>'
                                                    ||  '<txaplmin>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).txaplmin,'fm9990D00000000'),'0,00') || '</txaplmin>'
                                                    ||  '<cdprodut>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).cdprodut),'0') || '</cdprodut>'
                                                    ||  '<dtmvtolt>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).dtmvtolt,'dd/mm/RRRR'),' ') ||  '</dtmvtolt>'
                                                    ||  '<dtvencto>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).dtvencto,'dd/mm/RRRR'),' ') ||  '</dtvencto>'
                                                    ||  '<dtresgat>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).dtresgat,'dd/mm/RRRR'),' ') ||  '</dtresgat>'
                                                    ||  '<tpaplica>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).tpaplica),'0') ||  '</tpaplica>'
                                                    ||  '<idtipapl>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).idtipapl),'A') ||  '</idtipapl>'
                                                    ||  '<nmdindex>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).nmdindex),' ') ||  '</nmdindex>'
                                                    ||  '<qtdiaapl>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).qtdiaapl),' ') || '</qtdiaapl>'
                                                    ||  '<dsaplica>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).dsaplica),' ') || '</dsaplica>'
                                                    ||  '<cdoperad>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).cdoperad),' ') || '</cdoperad>'
                                                    ||  '<tpaplrdc>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).tpaplrdc),' ') || '</tpaplrdc>'
                                                    ||  '<nmprodut>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).nmprodut),' ') || '</nmprodut>'
                                                    ||  '<idtxfixa>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).idtxfixa),' ') || '</idtxfixa>'
                                                    ||  '<percirrf>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).percirrf),' ') || '</percirrf>'
                                                    ||  '<vlsldrgt>' || NVL(TRIM(TO_CHAR(vr_saldo_rdca(vr_contador).vlsldrgt,'999g999g9990d00')),'0') || '</vlsldrgt>'
                                                    ||  '<dsnomenc>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).dsnomenc),' ') || '</dsnomenc>'
                                                    ||  '<idtippro>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).idtippro),' ') || '</idtippro>'
                                                    ||  '<dtcarenc>' || NVL(TO_CHAR(vr_saldo_rdca(vr_contador).dtcarenc,'dd/mm/RRRR'),' ') ||  '</dtcarenc>'
                                                    || '</aplicacao>');

        END LOOP;

        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</root>'
                               ,pr_fecha_xml      => TRUE);
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na busca de aplicacoes APLI0005.pc_lista_aplicacoes_car: ' || SQLERRM;

    END;
  END pc_lista_aplicacoes_car;

  PROCEDURE pc_val_solicit_resg(pr_cdcooper  IN craprac.cdcooper%TYPE     --> Código da Cooperativa
                               ,pr_cdoperad  IN crapope.cdoperad%TYPE     --> Código do Operador
                               ,pr_nmdatela  IN craptel.nmdatela%TYPE     --> Nome da Tela
                               ,pr_idorigem  IN INTEGER                   --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  )
                               ,pr_nrdconta  IN craprac.nrdconta%TYPE     --> Número da Conta
                               ,pr_idseqttl  IN crapttl.idseqttl%TYPE     --> Titular da Conta
                               ,pr_nraplica  IN craprac.nraplica%TYPE     --> Número da Aplicação
                               ,pr_cdprodut  IN craprac.cdprodut%TYPE     --> Código do Produto
                               ,pr_dtresgat  IN crapdat.dtmvtolt%TYPE     --> Data do Resgate (Data informada em tela)
                               ,pr_vlresgat  IN craprga.vlresgat%TYPE     --> Valor do Resgate (Valor informado em tela)
                               ,pr_idtiprgt  IN craprga.idtiprgt%TYPE     --> Tipo do Resgate (Tipo informado em tela, 1 – Parcial / 2 – Total)
                               ,pr_idrgtcti  IN craprga.idtiprgt%TYPE     --> Resgate na Conta Investimento (Identificador informado em tela, 0 – Não)
                               ,pr_idvldblq  IN INTEGER                   --> Identificador de validação do bloqueio judicial (0 – Não / 1 – Sim)
                               ,pr_idgerlog  IN INTEGER                   --> Identificador de Log (Fixo no código, 0 – Não / 1 - Sim)
                               ,pr_cdopera2  IN crapope.cdoperad%TYPE     --> Operador
                               ,pr_cddsenha  IN crapope.cddsenha%TYPE     --> Senha
                               ,pr_flgsenha  IN INTEGER                   --> Validar senha
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Código da crítica
                               ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da Critica

    BEGIN
   /* .............................................................................

     Programa: pc_val_solicit_resg
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Setembro/14.                    Ultima atualizacao: 09/09/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a validacao de solicitacao de resgate de aplicacao.

     Observacao: -----

     Alteracoes: 22/06/2015 - Projeto melhoria alcada captcao - resgate produto novo
                              (Tiago/Gielow).
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000) := '';
      vr_des_reto VARCHAR2(100);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Tabela temporária
      pr_tab_erro gene0001.typ_tab_erro;

      -- Variaveis de valores
      vr_vlbascal NUMBER(20,8) := 0;
      vr_vlsldtot NUMBER(20,8) := 0;
      vr_vlsldrgt NUMBER(20,8) := 0;
      vr_vlultren NUMBER(20,8) := 0;
      vr_vlrentot NUMBER(20,8) := 0;
      vr_vlrevers NUMBER(20,8) := 0;
      vr_vlrdirrf NUMBER(20,8) := 0;
      vr_percirrf NUMBER(20,8) := 0;
      vr_vlsolrgt NUMBER(20,8) := 0;
      vr_vlresgat NUMBER(20,8) := 0;

      -- Variáveis para geracao de log
      vr_dstransa VARCHAR2(100) := 'Validacao de agendamento de resgate. Aplicacao num: ' || pr_nraplica;
      vr_dsorigem VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_nrdrowid ROWID;

      vr_cdoperad crapope.cdoperad%TYPE;

      -- Cursores

      -- Selecionar dados do operador
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE --> Coodigo cooperativa
                       ,pr_cdoperad IN crapope.cdoperad%TYPE --> Codigo operador
                       ) IS
        SELECT ope.vlapvcap
          FROM crapope ope
         WHERE ope.cdcooper = pr_cdcooper
           AND upper(ope.cdoperad) = upper(pr_cdoperad);

      rw_crapope cr_crapope%ROWTYPE;

      -- Selecionar dados de carencia de aplicacao
      CURSOR cr_craprac(pr_cdcooper IN craprac.cdcooper%TYPE --> Código da Cooperativa
                       ,pr_nrdconta IN craprac.nrdconta%TYPE --> Numero da Conta
                       ,pr_nraplica IN craprac.nraplica%TYPE --> Numero da Aplicacao
                       ) IS

      SELECT
        rac.cdcooper
       ,rac.nrdconta
       ,rac.nraplica
       ,rac.dtmvtolt
       ,rac.idblqrgt
       ,rac.vlaplica
       ,rac.cdprodut
       ,rac.txaplica
       ,rac.qtdiacar
       ,rac.dtvencto
      FROM
        craprac rac
      WHERE
            rac.cdcooper = pr_cdcooper  -- Codigo da cooperativa
        AND rac.nrdconta = pr_nrdconta  -- Numero da conta
        AND rac.nraplica = pr_nraplica; -- Numero da aplicacao

      rw_craprac cr_craprac%ROWTYPE;

      -- Selecionar dados de resgates de aplicacoes
      CURSOR cr_craprga(pr_cdcooper IN craprac.cdcooper%TYPE --> Código da cooperativa
                       ,pr_nrdconta IN craprac.nrdconta%TYPE --> Numero da conta
                       ,pr_nraplica IN craprac.nraplica%TYPE --> Numero da aplicacao
                       ) IS

      SELECT
        rga.cdcooper
       ,rga.nrdconta
       ,rga.nraplica
       ,rga.idresgat
       ,rga.vlresgat
       ,rga.idtiprgt
      FROM
        craprga rga
      WHERE
            rga.cdcooper = pr_cdcooper  -- Codigo da cooperativa
        AND rga.nrdconta = pr_nrdconta  -- Numero da conta
        AND (rga.nraplica = pr_nraplica
         OR pr_nraplica = 0);           -- Numero da aplicacao

      rw_craprga cr_craprga%ROWTYPE;

      -- Selecionar dados de produtos
      CURSOR cr_crapcpc(pr_cdprodut IN crapcpc.cdprodut%TYPE) IS --> Código do produto

      SELECT
        cpc.cdprodut
       ,cpc.nmprodut
       ,cpc.idtippro
       ,cpc.idtxfixa
       ,cpc.cddindex
      FROM
        crapcpc cpc
      WHERE
        cpc.cdprodut = pr_cdprodut;  -- Codigo do produto

      rw_crapcpc cr_crapcpc%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    BEGIN

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;

      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Consulta de aplicacao
      OPEN cr_craprac(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nraplica => pr_nraplica);

      FETCH cr_craprac INTO rw_craprac;

      IF cr_craprac%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_craprac;

        vr_cdcritic := 426;

        -- Executa a exceção
        RAISE vr_exc_saida;
      ELSE
        -- Fecha cursor
        CLOSE cr_craprac;
      END IF;

      -- Verifica alcada do operador
      IF pr_idorigem <> 3 THEN

         IF pr_flgsenha = 0 THEN
           vr_cdoperad := pr_cdoperad;
         ELSE
           vr_cdoperad := pr_cdopera2;
         END IF;

        OPEN cr_crapope(pr_cdcooper => pr_cdcooper
                       ,pr_cdoperad => vr_cdoperad);

        FETCH cr_crapope INTO rw_crapope;

        IF cr_crapope%NOTFOUND THEN
          -- Fecha cursor
          CLOSE cr_crapope;

          vr_cdcritic := 67;

          -- Executa a exceção
          RAISE vr_exc_saida;
        ELSE
          -- Fecha cursor
          CLOSE cr_crapope;

          IF pr_vlresgat = 0 AND
             pr_idtiprgt = 2 THEN
             vr_vlresgat := rw_craprac.vlaplica;
          ELSE
             vr_vlresgat := pr_vlresgat;
          END IF;

          apli0002.pc_validar_limite_resgate(pr_cdcooper => pr_cdcooper
                                            ,pr_idorigem => pr_idorigem
                                            ,pr_nmdatela => pr_nmdatela
                                            ,pr_idseqttl => pr_idseqttl
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_vlrrsgat => vr_vlresgat
                                            ,pr_cdoperad => vr_cdoperad
                                            ,pr_cddsenha => pr_cddsenha
                                            ,pr_flgsenha => pr_flgsenha
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

          IF vr_cdcritic > 0 OR
             TRIM(vr_dscritic) IS NOT NULL THEN
             -- Executa a exceção
             RAISE vr_exc_saida;
          END IF;

        END IF;

      END IF;


      -- Verifica data de inclusao de aplicacao
      IF pr_dtresgat = rw_craprac.dtmvtolt THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Aplicacao feita HOJE. Use a opcao EXCLUIR.';

        -- Executa a exceção
        RAISE vr_exc_saida;
      END IF;

      -- Verificar se a aplicação está bloqueada para resgate
      IF rw_craprac.idblqrgt > 0 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Aplicacao bloqueada para resgate.';

        -- Executa a exceção
        RAISE vr_exc_saida;
      END IF;

      -- Verifica resgates de aplicacoes
      OPEN cr_craprga(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nraplica => pr_nraplica);

      FETCH cr_craprga INTO rw_craprga;

      IF cr_craprga%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_craprga;
      ELSE
        -- Fecha cursor
        CLOSE cr_craprga;
        -- Verifica se ja existe agendamento de resgate mas ainda efetivado
        IF rw_craprga.idresgat = 0 AND rw_craprga.idtiprgt = 2 THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Agendamento de resgate TOTAL ja efetuado para esta aplicacao.';

          -- Executa a exceção
          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Verificar se o tipo de resgate é válido
      IF pr_idtiprgt NOT IN(1,2) THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Tipo de resgate invalido.';

        -- Executa a exceção
        RAISE vr_exc_saida;
      END IF;

      -- Não permitir valor de resgate zerado se for um resgate parcial
      IF (pr_idtiprgt = 1 AND pr_vlresgat = 0) THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Valor invalido para resgate parcial.';

        -- Executa a exceção
        RAISE vr_exc_saida;
      END IF;

      -- Consulta de produtos
      OPEN cr_crapcpc(pr_cdprodut => rw_craprac.cdprodut);

      FETCH cr_crapcpc INTO rw_crapcpc;

      -- Verifica se produto existe
      IF cr_crapcpc%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_crapcpc;

        -- Critica referente a produto inexistente
        vr_cdcritic := 0;
        vr_dscritic := 'Produto nao encontrado.';

        -- Executa a exceção
        RAISE vr_exc_saida;
      ELSE
        -- Fecha cursor
        CLOSE cr_crapcpc;
      END IF;

      -- Verifica se agendamento é parcial
      IF pr_idtiprgt = 1 THEN
        FOR rw_craprga IN cr_craprga(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nraplica => pr_nraplica)
        LOOP
          IF rw_craprga.idresgat = 0 THEN
            -- Valor de resgate total de todas os resgates agendados
            vr_vlsolrgt := NVL(vr_vlsolrgt,0) + NVL(rw_craprga.vlresgat,0);
          END IF;
        END LOOP;
      END IF;

      -- Verifica saldo Aplicacao dependendo do tipo
      IF rw_crapcpc.idtippro = 1 THEN

        apli0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => rw_craprac.cdcooper
                                               ,pr_nrdconta => rw_craprac.nrdconta
                                               ,pr_nraplica => rw_craprac.nraplica
                                               ,pr_dtiniapl => rw_craprac.dtmvtolt
                                               ,pr_txaplica => rw_craprac.txaplica
                                               ,pr_idtxfixa => rw_crapcpc.idtxfixa
                                               ,pr_cddindex => rw_crapcpc.cddindex
                                               ,pr_qtdiacar => rw_craprac.qtdiacar
                                               ,pr_idgravir => 0
                                               ,pr_dtinical => rw_craprac.dtmvtolt
                                               ,pr_dtfimcal => rw_crapdat.dtmvtolt
                                               ,pr_idtipbas => 2
                                               ,pr_vlbascal => vr_vlbascal
                                               ,pr_vlsldtot => vr_vlsldtot
                                               ,pr_vlsldrgt => vr_vlsldrgt
                                               ,pr_vlultren => vr_vlultren
                                               ,pr_vlrentot => vr_vlrentot
                                               ,pr_vlrevers => vr_vlrevers
                                               ,pr_vlrdirrf => vr_vlrdirrf
                                               ,pr_percirrf => vr_percirrf
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);

        IF vr_dscritic IS NOT NULL OR
           NVL(vr_cdcritic,0) <> 0 THEN
          -- Executa exceção
          RAISE vr_exc_saida;
        END IF;

      ELSIF rw_crapcpc.idtippro = 2 THEN
        apli0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => rw_craprac.cdcooper
                                               ,pr_nrdconta => rw_craprac.nrdconta
                                               ,pr_nraplica => rw_craprac.nraplica
                                               ,pr_dtiniapl => rw_craprac.dtmvtolt
                                               ,pr_txaplica => rw_craprac.txaplica
                                               ,pr_idtxfixa => rw_crapcpc.idtxfixa
                                               ,pr_cddindex => rw_crapcpc.cddindex
                                               ,pr_qtdiacar => rw_craprac.qtdiacar
                                               ,pr_idgravir => 0
                                               ,pr_dtinical => rw_craprac.dtmvtolt
                                               ,pr_dtfimcal => rw_crapdat.dtmvtolt
                                               ,pr_idtipbas => 2
                                               ,pr_vlbascal => vr_vlbascal
                                               ,pr_vlsldtot => vr_vlsldtot
                                               ,pr_vlsldrgt => vr_vlsldrgt
                                               ,pr_vlultren => vr_vlultren
                                               ,pr_vlrentot => vr_vlrentot
                                               ,pr_vlrevers => vr_vlrevers
                                               ,pr_vlrdirrf => vr_vlrdirrf
                                               ,pr_percirrf => vr_percirrf
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);

        IF vr_dscritic IS NOT NULL OR
           NVL(vr_cdcritic,0) <> 0 THEN
          -- Executa exceção
          RAISE vr_exc_saida;
        END IF;

      END IF;

      /*Resgate parcial*/
      IF pr_idtiprgt = 1 THEN

        -- Não permitir que o resgate parcial seja igual ao valor disponível para resgate
        IF pr_vlresgat = vr_vlsldrgt AND pr_idtiprgt = 1 THEN

          -- Monta msg e cod da critica
          vr_cdcritic := 0;
          vr_dscritic := 'O valor informado e igual ao saldo disponivel para resgate. Solicite um resgate total.';

          -- Executa a exceção
          RAISE vr_exc_saida;
        END IF;

        IF ((vr_vlsldrgt - pr_vlresgat) < 5) THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Saldo da aplicacao nao pode ser inferior a R$ 5,00. Saldo disponivel: R$ ' || to_char((vr_vlsldrgt - pr_vlresgat),'fm99999G990D00','NLS_NUMERIC_CHARACTERS=,.');

          -- Executa a exceção
          RAISE vr_exc_saida;
        END IF;

        IF ((vr_vlsldrgt - vr_vlsolrgt) < pr_vlresgat) THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Saldo da aplicacao nao pode ser inferior a R$ 5,00. Saldo disponivel: R$ ' || to_char((vr_vlsldrgt - pr_vlresgat),'fm99999G990D00','NLS_NUMERIC_CHARACTERS=,.');

          -- Executa a exceção
          RAISE vr_exc_saida;
        END IF;

        IF ((vr_vlsldrgt - vr_vlsolrgt - pr_vlresgat) < 5) THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Saldo da aplicacao nao pode ser inferior a R$ 5,00. Saldo disponivel: R$ ' || to_char((vr_vlsldrgt - vr_vlsolrgt - pr_vlresgat),'fm99999G990D00','NLS_NUMERIC_CHARACTERS=,.');

          -- Executa a exceção
          RAISE vr_exc_saida;
        END IF;

      END IF;

      /*Valores bloqueados judicialmente*/
      IF pr_idvldblq = 1 THEN
        -- Consulta de valores bloqueados
        APLI0002.pc_ver_val_bloqueio_aplica( pr_cdcooper => pr_cdcooper         --> Codigo Cooperativa
                                          ,pr_cdagenci => 1                   --> Codigo Agencia
                                          ,pr_nrdcaixa => 1                   --> Numero do Caixa
                                          ,pr_cdoperad => pr_cdoperad         --> Codigo do Operador
                                          ,pr_nmdatela => pr_nmdatela         --> Nome da Tela
                                          ,pr_idorigem => pr_idorigem         --> Origem
                                          ,pr_nrdconta => pr_nrdconta         --> Número da Conta
                                          ,pr_nraplica => pr_nraplica         --> Número da Aplicação
                                          ,pr_idseqttl => pr_idseqttl         --> Sequencia do Titular
                                          ,pr_cdprogra => pr_nmdatela         --> Codigo do Programa
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data de Movimentação
                                          ,pr_vlresgat => pr_vlresgat         --> Valor de Resgate
                                          ,pr_flgerlog => pr_idgerlog         --> Gerar Log (0-False / 1-True)
                                          ,pr_des_reto => vr_des_reto         --> Retorno 'OK'/'NOK'
                                          ,pr_tab_erro => pr_tab_erro);       --> Tabela Erros

        -- Verifica se retornou erro durante a execução
        IF vr_des_reto <> 'OK' THEN
          IF pr_tab_erro.COUNT > 0 THEN
            -- Se existir erro adiciona na crítica
            vr_cdcritic := pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
            vr_dscritic := pr_tab_erro(pr_tab_erro.FIRST).dscritic;
            -- Limpar a tabela de erro, pois a exceção vai criar um novo registro
            pr_tab_erro.DELETE;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Nao foi possivel consultar valor bloqueado judicialmente.';
          END IF;
          -- Executa a exceção
          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Não permitir resgate para datas anteriores ao dia de movimento
      IF pr_dtresgat < rw_crapdat.dtmvtolt THEN

        -- Monta msg e cod da critica
        vr_cdcritic := 0;
        vr_dscritic := 'Data de resgate nao pode ser menor que a data de movimento.';

        -- Executa a exceção
        RAISE vr_exc_saida;
      END IF;

      -- Não permitir resgates futuros superiores à 90 dias
      IF pr_dtresgat > rw_crapdat.dtmvtolt + 90 THEN

        -- Monta msg e cod da critica
        vr_cdcritic := 0;
        vr_dscritic := 'Data de resgate nao pode ser maior que 90 dias.';

        -- Executa a exceção
        RAISE vr_exc_saida;
      END IF;

      -- Não permitir resgates futuros maior ou igual à data de vencimento da aplicação
      IF pr_dtresgat >= rw_craprac.dtvencto THEN
        -- Monta msg e cod da critica
        vr_cdcritic := 0;
        vr_dscritic := 'Resgates futuros maior ou igual a data de vencimento da aplicacao.';

        -- Executa a exceção
        RAISE vr_exc_saida;
      END IF;

      -- Não permitir resgates futuros em feriados ou finais de semana
      IF TO_CHAR(pr_dtresgat, 'D') IN (1, 7) OR
         flxf0001.fn_verifica_feriado(pr_cdcooper, pr_dtresgat) THEN

        -- Monta msg e cod da critica
        vr_cdcritic := 0;
        vr_dscritic := 'Resgates nao permitido para feriado ou final de semana.';

        -- Executa a exceção
        RAISE vr_exc_saida;

      END IF;

      -- Verifica se resgate sera feito da conta investimento
      IF pr_idrgtcti <> 0 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Nao permitir resgate na conta investimento';

        -- Executa a exceção
        RAISE vr_exc_saida;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;

        -- Geracao de log referente a critica gerada, pode ser consultada na tela VERLOG
        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
          COMMIT;
        END IF;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado no resgate de aplicacoes APLI0005.pc_val_solicit_resg. Erro: ' || SQLERRM;

        ROLLBACK;

        -- Geracao de log referente a critica gerada, pode ser consultada na tela VERLOG
        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
          COMMIT;
        END IF;
    END;

  END pc_val_solicit_resg;

  PROCEDURE pc_solicita_resgate(pr_cdcooper  IN craprac.cdcooper%TYPE     --> Código da Cooperativa
                               ,pr_cdoperad  IN crapope.cdoperad%TYPE     --> Código do Operador
                               ,pr_nmdatela  IN craptel.nmdatela%TYPE     --> Nome da Tela
                               ,pr_idorigem  IN INTEGER                   --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  )
                               ,pr_nrdconta  IN craprac.nrdconta%TYPE     --> Número da Conta
                               ,pr_idseqttl  IN crapttl.idseqttl%TYPE     --> Titular da Conta
                               ,pr_nraplica  IN craprac.nraplica%TYPE     --> Número da Aplicação
                               ,pr_cdprodut  IN craprac.cdprodut%TYPE     --> Código do Produto
                               ,pr_dtresgat  IN crapdat.dtmvtolt%TYPE     --> Data do Resgate (Data informada em tela)
                               ,pr_vlresgat  IN craprga.vlresgat%TYPE     --> Valor do Resgate (Valor informado em tela)
                               ,pr_idtiprgt  IN craprga.idtiprgt%TYPE     --> Tipo do Resgate (Tipo informado em tela, 1 – Parcial / 2 – Total)
                               ,pr_idrgtcti  IN INTEGER                   --> Resgate na Conta Investimento (Identificador informado em tela, 0 – Não)
                               ,pr_idgerlog  IN INTEGER                   --> Identificador de Log (Fixo no código, 0 – Não / 1 - Sim)
                               ,pr_cdopera2  IN crapope.cdoperad%TYPE     --> Operador
                               ,pr_cddsenha  IN crapope.cddsenha%TYPE     --> Senha
                               ,pr_flgsenha  IN INTEGER                   --> Validar senha
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Código da crítica
                               ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da Critica

    BEGIN
   /* .............................................................................

     Programa: pc_solicita_resgate
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Setembro/14.                    Ultima atualizacao: 18/07/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente ao resgate de aplicacao.

     Observacao: -----

     Alteracoes: 18/07/2018 - Ajuste para não permitir o resgate de aplicações enquanto
                              o processo batch estiver rodando (Jean Michel)
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      vr_tpcritic crapcri.cdcritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_nrseqrgt craprga.nrseqrgt%TYPE := 0;

      -- Variáveis para geracao de log
      vr_dstransa VARCHAR2(100) := 'Solicitacao de resgate. Aplicacao num: ' || pr_nraplica;
      vr_dsorigem VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_idtiprgt VARCHAR2(7) := ' ';
      vr_nrdrowid ROWID;

      -- Cursores

      -- Selecionar dados de carencia de aplicacao
      CURSOR cr_craprac(pr_cdcooper IN craprac.cdcooper%TYPE --> Código da Cooperativa
                       ,pr_nrdconta IN craprac.nrdconta%TYPE --> Numero da Conta
                       ,pr_nraplica IN craprac.nraplica%TYPE --> Numero da Aplicacao
                       ) IS

      SELECT
        rac.cdcooper
       ,rac.nrdconta
       ,rac.nraplica
       ,rac.dtmvtolt
       ,rac.idblqrgt
       ,rac.vlaplica
       ,rac.cdprodut
       ,rac.txaplica
       ,rac.qtdiacar
       ,rac.dtvencto
      FROM
        craprac rac
      WHERE
            rac.cdcooper = pr_cdcooper  -- Codigo da cooperativa
        AND rac.nrdconta = pr_nrdconta  -- Numero da conta
        AND rac.nraplica = pr_nraplica; -- Numero da aplicacao

      rw_craprac cr_craprac%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    BEGIN

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;

      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;

        IF rw_crapdat.inproces > 1 THEN

          vr_cdcritic := 972;
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

          -- Levantar excecao
          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Valida resgate de aplicacao
      APLI0005.pc_val_solicit_resg(pr_cdcooper => pr_cdcooper    --> Código da Cooperativa
                                  ,pr_cdoperad => pr_cdoperad    --> Código do Operador
                                  ,pr_nmdatela => pr_nmdatela    --> Nome da Tela
                                  ,pr_idorigem => pr_idorigem    --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  )
                                  ,pr_nrdconta => pr_nrdconta    --> Número da Conta
                                  ,pr_idseqttl => pr_idseqttl    --> Titular da Conta
                                  ,pr_nraplica => pr_nraplica    --> Número da Aplicação
                                  ,pr_cdprodut => pr_cdprodut    --> Código do Produto
                                  ,pr_dtresgat => pr_dtresgat    --> Data do Resgate (Data informada em tela)
                                  ,pr_vlresgat => pr_vlresgat    --> Valor do Resgate (Valor informado em tela)
                                  ,pr_idtiprgt => pr_idtiprgt    --> Tipo do Resgate (Tipo informado em tela, 1 – Parcial / 2 – Total)
                                  ,pr_idrgtcti => pr_idrgtcti    --> Resgate na Conta Investimento (Identificador informado em tela, 0 – Não)
                                  ,pr_idvldblq => 1              --> Identificador de validação do bloqueio judicial (0 – Não / 1 – Sim)
                                  ,pr_idgerlog => 0              --> Identificador de Log (Fixo no código, 0 – Não / 1 - Sim)
                                  ,pr_cdopera2 => pr_cdopera2    --> Operador
                                  ,pr_cddsenha => pr_cddsenha    --> Senha
                                  ,pr_flgsenha => pr_flgsenha    --> Validar senha
                                  ,pr_cdcritic => vr_cdcritic    --> Código da crítica
                                  ,pr_dscritic => vr_dscritic ); --> Descricao da Critica

      -- Verifica se houve erro na validacao de resgate
      IF NVL(vr_cdcritic,0) <> 0 OR
         vr_dscritic IS NOT NULL THEN
        -- Executa exceção
        RAISE vr_exc_saida;
      END IF;

      -- Consulta nova sequencia de resgate
      vr_nrseqrgt := fn_sequence(pr_nmtabela => 'CRAPRGA'
                                ,pr_nmdcampo => 'NRSEQRGT'
                                ,pr_dsdchave => pr_cdcooper || ';' || pr_nrdconta || ';' || pr_nraplica
                                ,pr_flgdecre => 'N');

      -- Insere registro de resgate
      BEGIN
        INSERT INTO
          craprga(
             cdcooper
            ,nrdconta
            ,nraplica
            ,dtresgat
            ,nrseqrgt
            ,vlresgat
            ,idtiprgt
            ,idrgtcti
            ,cdoperad
            ,dtmvtolt
            ,hrtransa
            ,idresgat)
          VALUES(
             pr_cdcooper
            ,pr_nrdconta
            ,pr_nraplica
            ,pr_dtresgat
            ,vr_nrseqrgt
            ,pr_vlresgat
            ,pr_idtiprgt
            ,pr_idrgtcti
            ,pr_cdoperad
            ,rw_crapdat.dtmvtolt
            ,TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
            ,0) RETURNING ROWID INTO vr_nrdrowid;

      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao incluir registro de resgate(CRAPRGA).';
          -- Executa exceção
          RAISE vr_exc_saida;
      END;

      -- Verifica se o resgate é on-line
      IF pr_dtresgat = rw_crapdat.dtmvtolt THEN
        APLI0005.pc_efetua_resgate(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nraplica => pr_nraplica
                                  ,pr_vlresgat => pr_vlresgat
                                  ,pr_idtiprgt => pr_idtiprgt
                                  ,pr_dtresgat => pr_dtresgat
                                  ,pr_nrseqrgt => vr_nrseqrgt
                                  ,pr_idrgtcti => pr_idrgtcti
                                  ,pr_tpcritic => vr_tpcritic
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);

        IF vr_dscritic IS NOT NULL OR
           NVL(vr_cdcritic,0) <> 0 THEN
          -- Executa exceção
          RAISE vr_exc_saida;
        END IF;

      END IF;

      -- Zera valor do rowid
      vr_nrdrowid := NULL;

      -- Verifica se deve gerar log
      IF pr_idgerlog = 1 THEN
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                            ,pr_dstransa => vr_dstransa || ' ' || pr_dscritic
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'NRAPLICA'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_nraplica);

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'NRDOCMTO'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_nraplica);

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'DTRESGAT'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => TO_CHAR(pr_dtresgat,'dd/MM/RRRR'));

        IF pr_idtiprgt = 1 THEN
          vr_idtiprgt := 'PARCIAL';
        ELSE
          vr_idtiprgt := 'TOTAL';
        END IF;

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'IDTIPRGT'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => vr_idtiprgt);

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'VLRESGAT'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => TO_CHAR(pr_vlresgat,'fm9999G990D00'));

      END IF;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        ROLLBACK;

        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
        COMMIT;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado no resgate de aplicacoes APLI0005.pc_solicita_resgate: ' || SQLERRM;

        ROLLBACK;

        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
        COMMIT;

    END;

  END pc_solicita_resgate;

  PROCEDURE pc_efetua_resgate(pr_cdcooper  IN craprga.cdcooper%TYPE     --> Código da cooperativa
                             ,pr_nrdconta  IN craprga.nrdconta%TYPE     --> Número da conta
                             ,pr_nraplica  IN craprga.nraplica%TYPE     --> Número da aplicação
                             ,pr_vlresgat  IN craprga.vlresgat%TYPE     --> Valor do resgate
                             ,pr_idtiprgt  IN craprga.idtiprgt%TYPE     --> Tipo do resgate 1 - Parcial / 2 - Total
                             ,pr_dtresgat  IN crapdat.dtmvtolt%TYPE     --> Data do resgate
                             ,pr_nrseqrgt  IN craprga.nrseqrgt%TYPE     --> Numero de sequencia do resgate
                             ,pr_idrgtcti  IN craprga.idrgtcti%TYPE     --> Indicador de resgate na conta investimento (0-Nao / 1-Sim)
                             ,pr_tpcritic OUT crapcri.cdcritic%TYPE     --> Tipo da crítica (0- Nao aborta Processo/ 1 - Aborta Processo)
                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Código da crítica
                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da Critica

    BEGIN
   /* .............................................................................

     Programa: pc_efetua_resgate
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Setembro/14.                    Ultima atualizacao: 11/09/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a efetivacao do resgate de aplicacao.

     Observacao: -----

     Alteracoes:
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de posicao de saldo
      vr_vlbascal NUMBER(20,8) := 0; -- Valor de base de calculo
      vr_vlsldtot NUMBER(20,8) := 0; -- Valor de saldo total
      vr_vlsldrgt NUMBER(20,8) := 0; -- Valor de saldo de resgate
      vr_vlultren NUMBER(20,8) := 0; -- Valor de ultimo rendimento
      vr_auxulren NUMBER(20,8) := 0; -- Valor de ultimo rendimento
      vr_vlrentot NUMBER(20,8) := 0; -- Valor de rendimento total
      vr_vlrevers NUMBER(20,8) := 0; -- Valor de reversao
      vr_vlrdirrf NUMBER(20,8) := 0; -- Valor de IRRF
      vr_percirrf NUMBER(20,8) := 0; -- Valor percentual de IRRF
      vr_idcalorc NUMBER;

      vr_auxbasca NUMBER(20,8) := 0; -- Valor base calculo auxiliar
      vr_vllanmto NUMBER(20,8) := 0; -- Variavel com valor de lancamento
      vr_vlbasren NUMBER(20,8) := 0; -- Variavel com valor de rendimento

      vr_dtfimcal DATE;         -- Data de fim de calculo de aplicacao
      vr_dtmvtolt DATE;

      -- Variaveis de carencia
      vr_flgaplca BOOLEAN := FALSE; -- Flag aplicacao esta dentro da carencia
      vr_flgprmap BOOLEAN := FALSE; -- Flag aplicacao esta dentro do primeiro mes

      vr_nrdocmto craplci.nrdocmto%TYPE; -- Numero de documento do lancamento

      -- Variaveis de atualizacao de registro de aplicacao
      vr_valresta NUMBER(20,8) := 0;       -- Valor de atualizacao de aplicacao
      vr_datresga DATE         := SYSDATE; -- Data de atualizacao de aplicacao

      vr_incrineg      INTEGER; --> Indicador de crítica de negócio para uso com a "pc_gerar_lancamento_conta"
      vr_tab_retorno   LANC0001.typ_reg_retorno;

      -- Cursores

      -- Selecionar dados de carencia de aplicacao
      CURSOR cr_craprac(pr_cdcooper IN craprac.cdcooper%TYPE     --> Código da Cooperativa
                       ,pr_nrdconta IN craprac.nrdconta%TYPE     --> Numero da Conta
                       ,pr_nraplica IN craprac.nraplica%TYPE) IS --> Numero da Aplicacao

      SELECT
        rac.cdcooper, rac.nrdconta,
        rac.nraplica, rac.cdprodut,
        rac.cdnomenc, rac.dtmvtolt,
        rac.dtvencto, rac.dtatlsld,
        rac.vlaplica, rac.vlbasapl,
        rac.vlsldatl, rac.vlslfmes,
        rac.vlsldacu, rac.qtdiacar,
        rac.qtdiaprz, rac.qtdiaapl,
        rac.txaplica, rac.idsaqtot,
        rac.idblqrgt, rac.idcalorc,
        rac.cdoperad, rac.progress_recid,
        rac.iddebcti, rac.vlbasant,
        rac.vlsldant, rac.dtsldant,
        rac.rowid,
        cpc.nmprodut, cpc.idsitpro,
        cpc.cddindex, cpc.idtippro,
        cpc.idtxfixa, cpc.idacumul,
        cpc.cdhscacc, cpc.cdhsvrcc,
        cpc.cdhsraap, cpc.cdhsnrap,
        cpc.cdhsprap, cpc.cdhsrvap,
        cpc.cdhsrdap, cpc.cdhsirap,
        cpc.cdhsrgap, cpc.cdhsvtap
      FROM
        craprac rac,
        crapcpc cpc
      WHERE
        rac.cdcooper = pr_cdcooper AND
        rac.nrdconta = pr_nrdconta AND
        rac.nraplica = pr_nraplica AND
        cpc.cdprodut = rac.cdprodut;

      rw_craprac cr_craprac%ROWTYPE;

      -- Selecionar dados de lotes
      CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE     --> Código da Cooperativa
                       ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE     --> data de movimento
                       ,pr_cdagenci IN craplot.cdagenci%TYPE     --> Codigo da agencia
                       ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE     --> Codigo do caixa
                       ,pr_nrdolote IN craplot.nrdolote%TYPE     --> Numero do lote
                       ,pr_tplotmov IN craplot.tplotmov%TYPE) IS --> Tipo de movimento


      SELECT
         lot.cdcooper
        ,lot.dtmvtolt
        ,lot.cdagenci
        ,lot.cdbccxlt
        ,lot.nrdolote
        ,lot.tplotmov
        ,lot.nrseqdig
        ,lot.qtinfoln
        ,lot.qtcompln
        ,lot.vlinfocr
        ,lot.vlcompcr
        ,lot.vlinfodb
        ,lot.vlcompdb
        ,lot.rowid
      FROM
        craplot lot
      WHERE
            lot.cdcooper = pr_cdcooper
        AND lot.dtmvtolt = pr_dtmvtolt
        AND lot.cdagenci = pr_cdagenci
        AND lot.cdbccxlt = pr_cdbccxlt
        AND lot.nrdolote = pr_nrdolote
        AND lot.tplotmov = pr_tplotmov;

      rw_craplot cr_craplot%ROWTYPE;
      rw_craplot_II cr_craplot%ROWTYPE;

      -- Selecionar lancamento de credito
      CURSOR cr_craplci(pr_cdcooper IN craplci.cdcooper%TYPE     --> Código da Cooperativa
                       ,pr_dtmvtolt IN craplci.dtmvtolt%TYPE     --> Data de movimento
                       ,pr_cdagenci IN craplci.cdagenci%TYPE     --> Codigo da agencia
                       ,pr_cdbccxlt IN craplci.cdbccxlt%TYPE     --> Codigo do caixa
                       ,pr_nrdolote IN craplci.nrdolote%TYPE     --> Numero do lote
                       ,pr_nrdconta IN craplci.nrdconta%TYPE     --> Numero da conta
                       ,pr_nrdocmto IN craplci.nrdocmto%TYPE) IS --> Numero do documento


      SELECT
        lci.cdcooper
       ,lci.dtmvtolt
       ,lci.cdagenci
       ,lci.cdbccxlt
       ,lci.nrdolote
       ,lci.nrdconta
       ,lci.nrdocmto
      FROM
        craplci lci
      WHERE
             lci.cdcooper = pr_cdcooper
         AND lci.dtmvtolt = pr_dtmvtolt
         AND lci.cdagenci = pr_cdagenci
         AND lci.cdbccxlt = pr_cdbccxlt
         AND lci.nrdolote = pr_nrdolote
         AND lci.nrdconta = pr_nrdconta
         AND lci.nrdocmto = pr_nrdocmto;

      rw_craplci cr_craplci%ROWTYPE;

      -- Selecionar saldo
      CURSOR cr_crapsli(pr_cdcooper IN crapsli.cdcooper%TYPE     --> Código da Cooperativa
                       ,pr_nrdconta IN crapsli.nrdconta%TYPE     --> Numero da conta
                       ,pr_dtrefere IN crapsli.dtrefere%TYPE) IS --> Data de referencia

        SELECT
          sli.cdcooper
         ,sli.nrdconta
         ,sli.dtrefere
         ,sli.vlsddisp
         ,sli.rowid
        FROM
          crapsli sli
        WHERE
              sli.cdcooper = pr_cdcooper
          AND sli.nrdconta = pr_nrdconta
          AND sli.dtrefere = pr_dtrefere;

      rw_crapsli cr_crapsli%ROWTYPE;

      -- Selecionar lancamento
      CURSOR cr_craplcm(pr_cdcooper IN craplcm.cdcooper%TYPE     --> Código da Cooperativa
                       ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE     --> Data de movimento
                       ,pr_cdagenci IN craplcm.cdagenci%TYPE     --> Codigo da agencia
                       ,pr_cdbccxlt IN craplcm.cdbccxlt%TYPE     --> Codigo do caixa
                       ,pr_nrdolote IN craplcm.nrdolote%TYPE     --> Numero do lote
                       ,pr_nrdconta IN craplcm.nrdconta%TYPE     --> Numero da conta
                       ,pr_nrdocmto IN craplcm.nrdocmto%TYPE) IS --> Numero do documento


      SELECT
        lcm.cdcooper
       ,lcm.dtmvtolt
       ,lcm.cdagenci
       ,lcm.cdbccxlt
       ,lcm.nrdolote
       ,lcm.nrdconta
       ,lcm.nrdocmto
      FROM
        craplcm lcm
      WHERE
             lcm.cdcooper = pr_cdcooper
         AND lcm.dtmvtolt = pr_dtmvtolt
         AND lcm.cdagenci = pr_cdagenci
         AND lcm.cdbccxlt = pr_cdbccxlt
         AND lcm.nrdolote = pr_nrdolote
         AND lcm.nrdctabb = pr_nrdconta
         AND lcm.nrdocmto = pr_nrdocmto;

      rw_craplcm cr_craplcm%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      PROCEDURE pc_gera_lancamento(pr_nrdconta IN craprac.nrdconta%TYPE
                                  ,pr_nraplica IN craprac.nraplica%TYPE
                                  ,pr_tplancto IN VARCHAR2
                                  ,pr_cdhistor IN crapcpc.cdhsprap%TYPE
                                  ,pr_vllanmto IN craplot.vlcompdb%TYPE
                                  ,pr_vlrendim IN craplac.vlrendim%TYPE
                                  ,pr_vlbasren IN craplac.vlbasren%TYPE
                                  ,pr_nrseqrgt IN craprga.nrseqrgt%TYPE
                                  ,pr_idrgtcti IN craprga.idrgtcti%TYPE
                                  ,pr_craplot IN OUT cr_craplot%ROWTYPE) IS

        /* .............................................................................
        Programa: pc_gera_lancamento
        Autor   : Jean Michel.
        Data    : 18/09/2014                     Ultima atualizacao:

        Dados referentes ao programa:

        Objetivo   : Procedure criada p/ gerar lancamento

        Parametros : pr_tplancto -- Tipo do lancamento
                     pr_cdhistor -- Codigo do historico
                     pr_vllanmto -- Valor de lancamento
                     pr_vlrendim -- Valor de rendimento
                     pr_vlbasren -- Valor de base de rendimento
                     pr_nrseqrgt -- Numero sequencial de resgate
                     pr_idrgtcti -- Indicador de resgate na conta investimento (0-Nao / 1-Sim)
                     pr_craplot  -- ROWTYPE CONTENDO INFORMACOES ATUALIZADAS DE LOTES

        Premissa   :

        Alteracoes :

        .............................................................................*/

      BEGIN
        DECLARE

        BEGIN

          IF NVL(pr_vllanmto,0) <= 0 THEN
            RETURN;
          END IF;

          IF UPPER(pr_tplancto) IN ('REVERSAO','IRRF','RESGATE') THEN -- Se for um lançamento de débito

            BEGIN

              -- Atualiza registro de lote
              UPDATE
                craplot
              SET
                craplot.cdcooper = pr_craplot.cdcooper
               ,craplot.dtmvtolt = pr_craplot.dtmvtolt
               ,craplot.cdagenci = pr_craplot.cdagenci
               ,craplot.cdbccxlt = pr_craplot.cdbccxlt
               ,craplot.nrdolote = pr_craplot.nrdolote
               ,craplot.tplotmov = pr_craplot.tplotmov
               ,craplot.nrseqdig = (NVL(pr_craplot.nrseqdig,0) + 1)
               ,craplot.qtinfoln = (NVL(pr_craplot.qtinfoln,0) + 1)
               ,craplot.qtcompln = (NVL(pr_craplot.qtcompln,0) + 1)
               ,craplot.vlinfodb = (NVL(craplot.vlinfodb,0) + NVL(pr_vllanmto,0))
               ,craplot.vlcompdb = (NVL(craplot.vlcompdb,0) + NVL(pr_vllanmto,0))
              WHERE
               craplot.rowid = pr_craplot.rowid
              RETURNING
                cdcooper, dtmvtolt, cdagenci, cdbccxlt,
                nrdolote, tplotmov, nrseqdig, qtinfoln, qtcompln,
                vlinfodb, vlcompdb, ROWID
              INTO
                pr_craplot.cdcooper, pr_craplot.dtmvtolt, pr_craplot.cdagenci,
                pr_craplot.cdbccxlt, pr_craplot.nrdolote, pr_craplot.tplotmov,
                pr_craplot.nrseqdig, pr_craplot.qtinfoln, pr_craplot.qtcompln,
                pr_craplot.vlinfodb, pr_craplot.vlcompdb, pr_craplot.ROWID;

            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar lote de ' || UPPER(pr_tplancto) || '. Erro' || SQLERRM;
                pr_tpcritic := 1;
                RAISE vr_exc_saida;
            END;

            BEGIN
              INSERT INTO
                craplac(
                  cdcooper
                 ,dtmvtolt
                 ,cdagenci
                 ,cdbccxlt
                 ,nrdolote
                 ,nrdconta
                 ,nraplica
                 ,nrdocmto
                 ,nrseqdig
                 ,vllanmto
                 ,cdhistor
                 ,nrseqrgt
                 ,vlrendim
                 ,vlbasren)
                VALUES(
                  pr_craplot.cdcooper
                 ,pr_craplot.dtmvtolt
                 ,pr_craplot.cdagenci
                 ,pr_craplot.cdbccxlt
                 ,pr_craplot.nrdolote
                 ,pr_nrdconta
                 ,pr_nraplica
                 ,pr_craplot.nrseqdig
                 ,pr_craplot.nrseqdig
                 ,pr_vllanmto
                 ,pr_cdhistor
                 ,pr_nrseqrgt
                 ,pr_vlrendim
                 ,pr_vlbasren);

            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao inserir registro de lancamento de aplicacao(REVERSAO/IRRF/RESGATE). Erro: ' || SQLERRM;
                pr_tpcritic := 1;
                RAISE vr_exc_saida;
            END;

          ELSIF UPPER(pr_tplancto) IN ('PROVISAO','RENDIMENTO')THEN -- Se for um lançamento de crédito

            BEGIN

              -- Atualiza registro de lote
              UPDATE
                craplot
              SET
                craplot.cdcooper = pr_craplot.cdcooper
               ,craplot.dtmvtolt = pr_craplot.dtmvtolt
               ,craplot.cdagenci = pr_craplot.cdagenci
               ,craplot.cdbccxlt = pr_craplot.cdbccxlt
               ,craplot.nrdolote = pr_craplot.nrdolote
               ,craplot.tplotmov = pr_craplot.tplotmov
               ,craplot.nrseqdig = (NVL(pr_craplot.nrseqdig,0) + 1)
               ,craplot.qtinfoln = (NVL(pr_craplot.qtinfoln,0) + 1)
               ,craplot.qtcompln = (NVL(pr_craplot.qtcompln,0) + 1)
               ,craplot.vlinfocr = (NVL(craplot.vlinfocr,0) + NVL(pr_vllanmto,0))
               ,craplot.vlcompcr = (NVL(craplot.vlcompcr,0) + NVL(pr_vllanmto,0))
              WHERE
                craplot.rowid = pr_craplot.rowid
              RETURNING
                cdcooper, dtmvtolt, cdagenci, cdbccxlt,
                nrdolote, tplotmov, nrseqdig, qtinfoln,
                qtcompln, vlinfocr, vlcompcr, ROWID
              INTO
                pr_craplot.cdcooper, pr_craplot.dtmvtolt, pr_craplot.cdagenci,
                pr_craplot.cdbccxlt, pr_craplot.nrdolote, pr_craplot.tplotmov,
                pr_craplot.nrseqdig, pr_craplot.qtinfoln, pr_craplot.qtcompln,
                pr_craplot.vlinfocr, pr_craplot.vlcompcr, pr_craplot.ROWID;

            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar lote de ' || UPPER(pr_tplancto) || '. Erro' || SQLERRM;
                pr_tpcritic := 1;
                RAISE vr_exc_saida;
            END;

            BEGIN
              INSERT INTO
                craplac(
                  cdcooper
                 ,dtmvtolt
                 ,cdagenci
                 ,cdbccxlt
                 ,nrdolote
                 ,nrdconta
                 ,nraplica
                 ,nrdocmto
                 ,nrseqdig
                 ,vllanmto
                 ,cdhistor
                 ,nrseqrgt
                 ,vlrendim
                 ,vlbasren)
                VALUES(
                  pr_craplot.cdcooper
                 ,pr_craplot.dtmvtolt
                 ,pr_craplot.cdagenci
                 ,pr_craplot.cdbccxlt
                 ,pr_craplot.nrdolote
                 ,pr_nrdconta
                 ,pr_nraplica
                 ,pr_craplot.nrseqdig
                 ,pr_craplot.nrseqdig
                 ,pr_vllanmto
                 ,pr_cdhistor
                 ,pr_nrseqrgt
                 ,pr_vlrendim
                 ,pr_vlbasren);

            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao inserir registro de lancamento de aplicacao(PROVISAO/RENDIMENTO). Erro: ' || SQLERRM;
                pr_tpcritic := 1;
                RAISE vr_exc_saida;
            END;

          END IF; -- Fim do if de verificacao de lancamento

        END;

      END pc_gera_lancamento;

    BEGIN

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;

      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Se for lancamento online data atual, caso contrario pega a proxima data util
      IF pr_dtresgat = rw_crapdat.dtmvtolt THEN
        vr_dtmvtolt := rw_crapdat.dtmvtolt;
      ELSE
        vr_dtmvtolt := rw_crapdat.dtmvtopr;
      END IF;

      -- Verifica se lote já existe
      OPEN cr_craplot(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                     ,pr_dtmvtolt => vr_dtmvtolt --> data de movimento
                     ,pr_cdagenci => 1           --> Codigo da agencia
                     ,pr_cdbccxlt => 100         --> Codigo do caixa
                     ,pr_nrdolote => 8502        --> Numero do lote
                     ,pr_tplotmov => 9);         --> Tipo de movimento

      FETCH cr_craplot INTO rw_craplot_II;

      IF cr_craplot%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_craplot;

        -- Insere registro de lote
        BEGIN
          -- Insere registro de lote
          INSERT INTO
            craplot(
              cdcooper
             ,dtmvtolt
             ,cdagenci
             ,cdbccxlt
             ,nrdolote
             ,tplotmov
             ,nrseqdig
             ,qtinfoln
             ,qtcompln
            )VALUES(
               pr_cdcooper
              ,vr_dtmvtolt
              ,1
              ,100
              ,8502
              ,9
              ,0
              ,0
              ,0)
            RETURNING
              cdcooper, dtmvtolt, cdagenci, cdbccxlt,
              nrdolote, tplotmov, nrseqdig, qtinfoln, qtcompln, ROWID
            INTO
              rw_craplot_II.cdcooper, rw_craplot_II.dtmvtolt, rw_craplot_II.cdagenci,
              rw_craplot_II.cdbccxlt, rw_craplot_II.nrdolote, rw_craplot_II.tplotmov,
              rw_craplot_II.nrseqdig, rw_craplot_II.qtinfoln, rw_craplot_II.qtcompln, rw_craplot_II.rowid;

        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao inserir registro de lote. Erro: ' || SQLERRM;
            pr_tpcritic := 1;
        END;
      ELSE
        CLOSE cr_craplot;
      END IF;

      -- Consulta registros de aplicaacao
      OPEN cr_craprac(pr_cdcooper => pr_cdcooper   -- Codigo da cooperativa
                     ,pr_nrdconta => pr_nrdconta   -- Numero da conta
                     ,pr_nraplica => pr_nraplica); -- Numero da aplicacao

      FETCH cr_craprac INTO rw_craprac;

      IF cr_craprac%NOTFOUND THEN
         -- Fecha cursor
         CLOSE cr_craprac;

         vr_cdcritic := 426;
         pr_tpcritic := 0;
         -- Executa excecao
         RAISE vr_exc_saida;
      ELSE
        -- Fecha cursor
        CLOSE cr_craprac;
      END IF;

      -- Validar se a aplicação ainda está ativa
      IF rw_craprac.idsaqtot <> 0 THEN
        vr_cdcritic := 0;
         vr_dscritic := 'Aplicacao inativa.';
         pr_tpcritic := 0;
         -- Executa excecao
         RAISE vr_exc_saida;
      END IF;

      -- Validar se a aplicação possui saldo
      IF rw_craprac.vlbasapl <= 0 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Saldo insuficiente.';
        pr_tpcritic := 0;
        -- Executa excecao
        RAISE vr_exc_saida;
      END IF;

      -- Validar se a aplicação não está bloqueada para resgate
      IF rw_craprac.idblqrgt <> 0 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Aplicacao bloqueada para resgate.';
        pr_tpcritic := 0;
        -- Executa excecao
        RAISE vr_exc_saida;
      END IF;

      -- Validar se o tipo de resgate é válido (1 - Parcial / 2 - Total)
      IF pr_idtiprgt NOT IN(1,2) THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Tipo de resgate invalido.';
        pr_tpcritic := 0;
        -- Executa excecao
        RAISE vr_exc_saida;
      END IF;

      -- Validar se o valor do resgate é válido quando for parcial
      IF pr_idtiprgt = 1 and pr_vlresgat <= 0 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Valor de resgate parcial invalido.';
        pr_tpcritic := 0;
        -- Executa excecao
        RAISE vr_exc_saida;
      END IF;

      -- Se for lancamento online data atual, caso contrario pega a proxima data util
      IF pr_dtresgat = rw_crapdat.dtmvtolt THEN
        vr_dtfimcal := rw_crapdat.dtmvtolt;
      ELSE
        vr_dtfimcal := rw_crapdat.dtmvtopr;
      END IF;

      -- Verificar se a aplicação está no período de carência
      IF vr_dtfimcal - rw_craprac.dtmvtolt < rw_craprac.qtdiacar THEN

        vr_flgaplca := TRUE; -- Flag aplicacao esta dentro da carencia

        -- Identificar se a aplicação está no primeiro mês da carência
        IF TRUNC(rw_craprac.dtmvtolt,'mm') = TRUNC(vr_dtfimcal,'mm') THEN

          vr_flgprmap := TRUE; -- Flag aplicacao esta dentro do primeiro mes

          -- Zera valor de base de calculo
          vr_vlbascal := 0;

          -- Verifica o tipo de aplicacao PRE ou POS
          IF rw_craprac.idtippro = 1  THEN -- Pré-Fixada
            apli0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => rw_craprac.cdcooper
                                                   ,pr_nrdconta => rw_craprac.nrdconta
                                                   ,pr_nraplica => rw_craprac.nraplica
                                                   ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                   ,pr_txaplica => rw_craprac.txaplica
                                                   ,pr_idtxfixa => rw_craprac.idtxfixa
                                                   ,pr_cddindex => rw_craprac.cddindex
                                                   ,pr_qtdiacar => rw_craprac.qtdiacar
                                                   ,pr_idgravir => 0
                                                   ,pr_dtinical => rw_craprac.dtmvtolt
                                                   ,pr_dtfimcal => vr_dtfimcal
                                                   ,pr_idtipbas => 2
                                                   ,pr_vlbascal => vr_vlbascal
                                                   ,pr_vlsldtot => vr_vlsldtot
                                                   ,pr_vlsldrgt => vr_vlsldrgt
                                                   ,pr_vlultren => vr_vlultren
                                                   ,pr_vlrentot => vr_vlrentot
                                                   ,pr_vlrevers => vr_vlrevers
                                                   ,pr_vlrdirrf => vr_vlrdirrf
                                                   ,pr_percirrf => vr_percirrf
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);

            -- Verifica se houve critica no processamento
            IF vr_dscritic IS NOT NULL OR
               NVL(vr_cdcritic,0) <> 0 THEN
              -- Executa excecao
              pr_tpcritic := 1;
              RAISE vr_exc_saida;
            END IF;
          ELSIF rw_craprac.idtippro = 2  THEN -- Pós-Fixada
            apli0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => rw_craprac.cdcooper
                                                   ,pr_nrdconta => rw_craprac.nrdconta
                                                   ,pr_nraplica => rw_craprac.nraplica
                                                   ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                   ,pr_txaplica => rw_craprac.txaplica
                                                   ,pr_idtxfixa => rw_craprac.idtxfixa
                                                   ,pr_cddindex => rw_craprac.cddindex
                                                   ,pr_qtdiacar => rw_craprac.qtdiacar
                                                   ,pr_idgravir => 0
                                                   ,pr_dtinical => rw_craprac.dtmvtolt
                                                   ,pr_dtfimcal => vr_dtfimcal
                                                   ,pr_idtipbas => 2
                                                   ,pr_vlbascal => vr_vlbascal
                                                   ,pr_vlsldtot => vr_vlsldtot
                                                   ,pr_vlsldrgt => vr_vlsldrgt
                                                   ,pr_vlultren => vr_vlultren
                                                   ,pr_vlrentot => vr_vlrentot
                                                   ,pr_vlrevers => vr_vlrevers
                                                   ,pr_vlrdirrf => vr_vlrdirrf
                                                   ,pr_percirrf => vr_percirrf
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);

            -- Verifica se houve critica no processamento
            IF vr_dscritic IS NOT NULL OR
               NVL(vr_cdcritic,0) <> 0 THEN
              -- Executa excecao
              pr_tpcritic := 1;
              RAISE vr_exc_saida;
            END IF;
          END IF;

           -- Verifica saldo
           IF vr_vlsldrgt >= pr_vlresgat THEN

             IF pr_idtiprgt = 1 THEN -- Parcial
               vr_vllanmto := pr_vlresgat;
               vr_vlbasren := pr_vlresgat;
             ELSIF pr_idtiprgt = 2 THEN -- Total
               vr_vllanmto := vr_vlsldrgt;
               vr_vlbasren := rw_craprac.vlbasapl;
             END IF;

             -- Efetuar o lançamentos
             pc_gera_lancamento(pr_nrdconta => rw_craprac.nrdconta
                               ,pr_nraplica => rw_craprac.nraplica
                               ,pr_tplancto => 'RESGATE'
                               ,pr_cdhistor => rw_craprac.cdhsrgap
                               ,pr_vllanmto => vr_vllanmto
                               ,pr_vlrendim => vr_vlrentot
                               ,pr_vlbasren => vr_vlbasren
                               ,pr_nrseqrgt => pr_nrseqrgt
                               ,pr_idrgtcti => pr_idrgtcti
                               ,pr_craplot  => rw_craplot_II);

           ELSE
             pr_tpcritic := 0;
             vr_cdcritic := 203;
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
             RAISE vr_exc_saida;
           END IF;

        ELSE -- Resgate após primeiro mês da carência

          vr_flgprmap := FALSE; -- Flag aplicacao esta dentro do primeiro mes

          -- Zera valor de base de calculo
          vr_vlbascal := 0;
          vr_vlbasren := 0;
          -- Verifica o tipo de aplicacao PRE ou POS
          IF rw_craprac.idtippro = 1  THEN -- Pré-Fixada
            apli0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => rw_craprac.cdcooper
                                                   ,pr_nrdconta => rw_craprac.nrdconta
                                                   ,pr_nraplica => rw_craprac.nraplica
                                                   ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                   ,pr_txaplica => rw_craprac.txaplica
                                                   ,pr_idtxfixa => rw_craprac.idtxfixa
                                                   ,pr_cddindex => rw_craprac.cddindex
                                                   ,pr_qtdiacar => rw_craprac.qtdiacar
                                                   ,pr_idgravir => 0
                                                   ,pr_dtinical => rw_craprac.dtmvtolt
                                                   ,pr_dtfimcal => vr_dtfimcal
                                                   ,pr_idtipbas => 2
                                                   ,pr_vlbascal => vr_vlbascal
                                                   ,pr_vlsldtot => vr_vlsldtot
                                                   ,pr_vlsldrgt => vr_vlsldrgt
                                                   ,pr_vlultren => vr_vlultren
                                                   ,pr_vlrentot => vr_vlrentot
                                                   ,pr_vlrevers => vr_vlrevers
                                                   ,pr_vlrdirrf => vr_vlrdirrf
                                                   ,pr_percirrf => vr_percirrf
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);

             -- Verifica se houve critica no processamento
             IF vr_dscritic IS NOT NULL OR
               NVL(vr_cdcritic,0) <> 0 THEN
               -- Executa excecao
               pr_tpcritic := 1;
               RAISE vr_exc_saida;
             END IF;
           ELSIF rw_craprac.idtippro = 2  THEN -- Pós-Fixada
             apli0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => rw_craprac.cdcooper
                                                    ,pr_nrdconta => rw_craprac.nrdconta
                                                    ,pr_nraplica => rw_craprac.nraplica
                                                    ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                    ,pr_txaplica => rw_craprac.txaplica
                                                    ,pr_idtxfixa => rw_craprac.idtxfixa
                                                    ,pr_cddindex => rw_craprac.cddindex
                                                    ,pr_qtdiacar => rw_craprac.qtdiacar
                                                    ,pr_idgravir => 0
                                                    ,pr_dtinical => rw_craprac.dtmvtolt
                                                    ,pr_dtfimcal => vr_dtfimcal
                                                    ,pr_idtipbas => 2
                                                    ,pr_vlbascal => vr_vlbascal
                                                    ,pr_vlsldtot => vr_vlsldtot
                                                    ,pr_vlsldrgt => vr_vlsldrgt
                                                    ,pr_vlultren => vr_vlultren
                                                    ,pr_vlrentot => vr_vlrentot
                                                    ,pr_vlrevers => vr_vlrevers
                                                    ,pr_vlrdirrf => vr_vlrdirrf
                                                    ,pr_percirrf => vr_percirrf
                                                    ,pr_cdcritic => vr_cdcritic
                                                    ,pr_dscritic => vr_dscritic);
             -- Verifica se houve critica no processamento
             IF vr_dscritic IS NOT NULL OR
               NVL(vr_cdcritic,0) <> 0 THEN
               -- Executa excecao
               pr_tpcritic := 1;
               RAISE vr_exc_saida;
             END IF;

           END IF; -- Fim verificacao tipo de aplicacao

           -- Verifica se saldo é suficiente
           IF vr_vlsldrgt >= pr_vlresgat THEN

             vr_vllanmto := vr_vlultren; -- Valor de provisao

             -- Efetua lancamento de provisao
             pc_gera_lancamento(pr_nrdconta => rw_craprac.nrdconta
                               ,pr_nraplica => rw_craprac.nraplica
                               ,pr_tplancto => 'PROVISAO'
                               ,pr_cdhistor => rw_craprac.cdhsprap
                               ,pr_vllanmto => vr_vllanmto
                               ,pr_vlrendim => 0
                               ,pr_vlbasren => 0
                               ,pr_nrseqrgt => 0
                               ,pr_idrgtcti => pr_idrgtcti
                               ,pr_craplot  => rw_craplot_II);

             -- Verifica tipo de resgate
             IF pr_idtiprgt = 1 THEN -- Parcial
               -- Valor do resgate
               vr_vlbascal := pr_vlresgat;

               -- Reversao de valor provisionado proporcional
               -- Verifica o tipo de aplicacao PRE ou POS
               IF rw_craprac.idtippro = 1  THEN -- Pré-Fixada
                 apli0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => rw_craprac.cdcooper
                                                        ,pr_nrdconta => rw_craprac.nrdconta
                                                        ,pr_nraplica => rw_craprac.nraplica
                                                        ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                        ,pr_txaplica => rw_craprac.txaplica
                                                        ,pr_idtxfixa => rw_craprac.idtxfixa
                                                        ,pr_cddindex => rw_craprac.cddindex
                                                        ,pr_qtdiacar => rw_craprac.qtdiacar
                                                        ,pr_idgravir => 0
                                                        ,pr_dtinical => rw_craprac.dtmvtolt
                                                        ,pr_dtfimcal => vr_dtfimcal
                                                        ,pr_idtipbas => pr_idtiprgt
                                                        ,pr_vlbascal => vr_vlbascal
                                                        ,pr_vlsldtot => vr_vlsldtot
                                                        ,pr_vlsldrgt => vr_vlsldrgt
                                                        ,pr_vlultren => vr_auxulren
                                                        ,pr_vlrentot => vr_vlrentot
                                                        ,pr_vlrevers => vr_vlrevers
                                                        ,pr_vlrdirrf => vr_vlrdirrf
                                                        ,pr_percirrf => vr_percirrf
                                                        ,pr_cdcritic => vr_cdcritic
                                                        ,pr_dscritic => vr_dscritic);

                 -- Verifica se houve critica no processamento
                 IF vr_dscritic IS NOT NULL OR
                    NVL(vr_cdcritic,0) <> 0 THEN
                   -- Executa excecao
                   pr_tpcritic := 1;
                   RAISE vr_exc_saida;
                 END IF;
               ELSIF rw_craprac.idtippro = 2  THEN -- Pós-Fixada
                 apli0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => rw_craprac.cdcooper
                                                        ,pr_nrdconta => rw_craprac.nrdconta
                                                        ,pr_nraplica => rw_craprac.nraplica
                                                        ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                        ,pr_txaplica => rw_craprac.txaplica
                                                        ,pr_idtxfixa => rw_craprac.idtxfixa
                                                        ,pr_cddindex => rw_craprac.cddindex
                                                        ,pr_qtdiacar => rw_craprac.qtdiacar
                                                        ,pr_idgravir => 0
                                                        ,pr_dtinical => rw_craprac.dtmvtolt
                                                        ,pr_dtfimcal => vr_dtfimcal
                                                        ,pr_idtipbas => pr_idtiprgt
                                                        ,pr_vlbascal => vr_vlbascal
                                                        ,pr_vlsldtot => vr_vlsldtot
                                                        ,pr_vlsldrgt => vr_vlsldrgt
                                                        ,pr_vlultren => vr_auxulren
                                                        ,pr_vlrentot => vr_vlrentot
                                                        ,pr_vlrevers => vr_vlrevers
                                                        ,pr_vlrdirrf => vr_vlrdirrf
                                                        ,pr_percirrf => vr_percirrf
                                                        ,pr_cdcritic => vr_cdcritic
                                                        ,pr_dscritic => vr_dscritic);
                 -- Verifica se houve critica no processamento
                 IF vr_dscritic IS NOT NULL OR
                    NVL(vr_cdcritic,0) <> 0 THEN
                   -- Executa excecao
                   pr_tpcritic := 1;
                   RAISE vr_exc_saida;
                 END IF;

               END IF; -- Fim verificacao tipo de aplicacao
               -- Fim reversao de valor provisionado proporcional

               vr_vllanmto := vr_vlrevers; -- Valor de reversao

               -- Efetua lancamento de reversao
               pc_gera_lancamento(pr_nrdconta => rw_craprac.nrdconta
                                 ,pr_nraplica => rw_craprac.nraplica
                                 ,pr_tplancto => 'REVERSAO'
                                 ,pr_cdhistor => rw_craprac.cdhsrvap
                                 ,pr_vllanmto => vr_vllanmto
                                 ,pr_vlrendim => 0
                                 ,pr_vlbasren => 0
                                 ,pr_nrseqrgt => pr_nrseqrgt
                                 ,pr_idrgtcti => pr_idrgtcti
                                 ,pr_craplot  => rw_craplot_II);

               vr_vllanmto := pr_vlresgat; -- Valor de resgate
               vr_vlbasren := vr_vlbascal;
               vr_vlsldrgt := pr_vlresgat; -- Valor para lancamento do resgate

               -- Lancamento de Resgate
               pc_gera_lancamento(pr_nrdconta => rw_craprac.nrdconta
                                 ,pr_nraplica => rw_craprac.nraplica
                                 ,pr_tplancto => 'RESGATE'
                                 ,pr_cdhistor => rw_craprac.cdhsrgap
                                 ,pr_vllanmto => vr_vllanmto
                                 ,pr_vlrendim => vr_vlrentot
                                 ,pr_vlbasren => vr_vlbasren
                                 ,pr_nrseqrgt => pr_nrseqrgt
                                 ,pr_idrgtcti => pr_idrgtcti
                                 ,pr_craplot  => rw_craplot_II);

             ELSIF pr_idtiprgt = 2 THEN -- Total

               vr_vllanmto := vr_vlsldrgt; -- Valor de resgate
               vr_vlbasren := rw_craprac.vlbasapl;

               -- Lancamento de Resgate
               pc_gera_lancamento(pr_nrdconta => rw_craprac.nrdconta
                                 ,pr_nraplica => rw_craprac.nraplica
                                 ,pr_tplancto => 'RESGATE'
                                 ,pr_cdhistor => rw_craprac.cdhsrgap
                                 ,pr_vllanmto => vr_vllanmto
                                 ,pr_vlrendim => vr_vlrentot
                                 ,pr_vlbasren => vr_vlbasren
                                 ,pr_nrseqrgt => pr_nrseqrgt
                                 ,pr_idrgtcti => pr_idrgtcti
                                 ,pr_craplot  => rw_craplot_II);

               vr_vllanmto := vr_vlrevers; -- Valor de reversao

               -- Efetua lancamento de reversao
               pc_gera_lancamento(pr_nrdconta => rw_craprac.nrdconta
                                 ,pr_nraplica => rw_craprac.nraplica
                                 ,pr_tplancto => 'REVERSAO'
                                 ,pr_cdhistor => rw_craprac.cdhsrvap
                                 ,pr_vllanmto => vr_vllanmto
                                 ,pr_vlrendim => 0
                                 ,pr_vlbasren => 0
                                 ,pr_nrseqrgt => pr_nrseqrgt
                                 ,pr_idrgtcti => pr_idrgtcti
                                 ,pr_craplot  => rw_craplot_II);
             END IF;

           ELSE
             pr_tpcritic := 0;
             vr_cdcritic := 203;
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
             RAISE vr_exc_saida;
           END IF;

        END IF; -- Fim mes de carencia

      ELSE -- Efetivacao de resgate apos carencia

        vr_flgaplca := FALSE; -- Flag aplicacao esta dentro da carencia
        vr_vlbascal := 0;

        -- Verifica tipo de resgate 1 - Parcial / 2 - Total
        IF pr_idtiprgt = 1 THEN -- Resgate Parcial

          -- Verifica o tipo de aplicacao PRE ou POS
          IF rw_craprac.idtippro = 1  THEN -- Pré-Fixada
            apli0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => rw_craprac.cdcooper
                                                   ,pr_nrdconta => rw_craprac.nrdconta
                                                   ,pr_nraplica => rw_craprac.nraplica
                                                   ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                   ,pr_txaplica => rw_craprac.txaplica
                                                   ,pr_idtxfixa => rw_craprac.idtxfixa
                                                   ,pr_cddindex => rw_craprac.cddindex
                                                   ,pr_qtdiacar => rw_craprac.qtdiacar
                                                   ,pr_idgravir => 0
                                                   ,pr_dtinical => rw_craprac.dtmvtolt
                                                   ,pr_dtfimcal => vr_dtfimcal
                                                   ,pr_idtipbas => 2
                                                   ,pr_vlbascal => vr_vlbascal
                                                   ,pr_vlsldtot => vr_vlsldtot
                                                   ,pr_vlsldrgt => vr_vlsldrgt
                                                   ,pr_vlultren => vr_vlultren
                                                   ,pr_vlrentot => vr_vlrentot
                                                   ,pr_vlrevers => vr_vlrevers
                                                   ,pr_vlrdirrf => vr_vlrdirrf
                                                   ,pr_percirrf => vr_percirrf
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);

            -- Verifica se houve critica no processamento
            IF vr_dscritic IS NOT NULL OR
               NVL(vr_cdcritic,0) <> 0 THEN
              -- Executa excecao
              pr_tpcritic := 1;
              RAISE vr_exc_saida;
            END IF;
          ELSIF rw_craprac.idtippro = 2  THEN -- Pós-Fixada
            apli0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => rw_craprac.cdcooper
                                                   ,pr_nrdconta => rw_craprac.nrdconta
                                                   ,pr_nraplica => rw_craprac.nraplica
                                                   ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                   ,pr_txaplica => rw_craprac.txaplica
                                                   ,pr_idtxfixa => rw_craprac.idtxfixa
                                                   ,pr_cddindex => rw_craprac.cddindex
                                                   ,pr_qtdiacar => rw_craprac.qtdiacar
                                                   ,pr_idgravir => 0
                                                   ,pr_dtinical => rw_craprac.dtmvtolt
                                                   ,pr_dtfimcal => vr_dtfimcal
                                                   ,pr_idtipbas => 2
                                                   ,pr_vlbascal => vr_vlbascal
                                                   ,pr_vlsldtot => vr_vlsldtot
                                                   ,pr_vlsldrgt => vr_vlsldrgt
                                                   ,pr_vlultren => vr_vlultren
                                                   ,pr_vlrentot => vr_vlrentot
                                                   ,pr_vlrevers => vr_vlrevers
                                                   ,pr_vlrdirrf => vr_vlrdirrf
                                                   ,pr_percirrf => vr_percirrf
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);

            -- Verifica se houve critica no processamento
            IF vr_dscritic IS NOT NULL OR
               NVL(vr_cdcritic,0) <> 0 THEN
              -- Executa excecao
              pr_tpcritic := 1;
              RAISE vr_exc_saida;
            END IF;

          END IF; -- Fim verificacao tipo de aplicacao

          -- Verifica se saldo é suficiente
          IF vr_vlsldrgt >= pr_vlresgat THEN

            vr_vllanmto := vr_vlultren; -- Valor de provisao
            vr_vlrentot := 0;
            vr_vlbasren := 0;

            -- Efetuar o lançamentos
            pc_gera_lancamento(pr_nrdconta => rw_craprac.nrdconta
                              ,pr_nraplica => rw_craprac.nraplica
                              ,pr_tplancto => 'PROVISAO'
                              ,pr_cdhistor => rw_craprac.cdhsprap
                              ,pr_vllanmto => vr_vllanmto
                              ,pr_vlrendim => vr_vlrentot
                              ,pr_vlbasren => vr_vlbasren
                              ,pr_nrseqrgt => 0
                              ,pr_idrgtcti => pr_idrgtcti
                              ,pr_craplot  => rw_craplot_II);

            -- Verifica tipo da aplicacao para retornar valor de reversao

            -- Calcula valor de base de calculo para resgate
            apli0006.pc_valor_base_resgate(pr_cdcooper => rw_craprac.cdcooper, --> Código da Cooperativa
                                           pr_nrdconta => rw_craprac.nrdconta, --> Conta do Cooperado
                                           pr_idtippro => rw_craprac.idtippro, --> Tipo do Produto da Aplicação
                                           pr_txaplica => rw_craprac.txaplica, --> Taxa da Aplicação
                                           pr_idtxfixa => rw_craprac.idtxfixa, --> Taxa Fixa (1-SIM/2-NAO)
                                           pr_cddindex => rw_craprac.cddindex, --> Código do Indexador
                                           pr_dtinical => rw_craprac.dtmvtolt, --> Data Inicial Cálculo (Fixo na chamada)
                                           pr_dtfimcal => vr_dtfimcal,         --> Data Final Cálculo (Fixo na chamada)
                                           pr_dtmvtolt => rw_crapdat.dtmvtolt, --> Data de Movimento
                                           pr_vlresgat => pr_vlresgat,         --> Valor do Resgate
                                           pr_percirrf => vr_percirrf,         --> Percentual de IRRF
                                           pr_vlbasrgt => vr_vlbascal,         --> Valor Base do Resgate
                                           pr_cdcritic => vr_cdcritic,         --> Código da crítica
                                           pr_dscritic => vr_dscritic);        --> Descrição da crítica

            -- Verifica se houve critica no processamento
            IF vr_dscritic IS NOT NULL OR
               NVL(vr_cdcritic,0) <> 0 THEN
              -- Executa excecao
              pr_tpcritic := 1;
              RAISE vr_exc_saida;
            END IF;

            -- Valor de base para calculo
            vr_auxbasca := vr_vlbascal;

            -- Verifica o tipo de aplicacao PRE ou POS
            IF rw_craprac.idtippro = 1  THEN -- Pré-Fixada
              apli0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => rw_craprac.cdcooper
                                                     ,pr_nrdconta => rw_craprac.nrdconta
                                                     ,pr_nraplica => rw_craprac.nraplica
                                                     ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                     ,pr_txaplica => rw_craprac.txaplica
                                                     ,pr_idtxfixa => rw_craprac.idtxfixa
                                                     ,pr_cddindex => rw_craprac.cddindex
                                                     ,pr_qtdiacar => rw_craprac.qtdiacar
                                                     ,pr_idgravir => 1
                                                     ,pr_dtinical => rw_craprac.dtmvtolt
                                                     ,pr_dtfimcal => vr_dtfimcal
                                                     ,pr_idtipbas => pr_idtiprgt
                                                     ,pr_vlbascal => vr_auxbasca
                                                     ,pr_vlsldtot => vr_vlsldtot
                                                     ,pr_vlsldrgt => vr_vlsldrgt
                                                     ,pr_vlultren => vr_auxulren
                                                     ,pr_vlrentot => vr_vlrentot
                                                     ,pr_vlrevers => vr_vlrevers
                                                     ,pr_vlrdirrf => vr_vlrdirrf
                                                     ,pr_percirrf => vr_percirrf
                                                     ,pr_cdcritic => vr_cdcritic
                                                     ,pr_dscritic => vr_dscritic);

              -- Verifica se houve critica no processamento
              IF vr_dscritic IS NOT NULL OR
                 NVL(vr_cdcritic,0) <> 0 THEN
                -- Executa excecao
                pr_tpcritic := 1;
                RAISE vr_exc_saida;
              END IF;
            ELSIF rw_craprac.idtippro = 2  THEN -- Pós-Fixada
              apli0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => rw_craprac.cdcooper
                                                     ,pr_nrdconta => rw_craprac.nrdconta
                                                     ,pr_nraplica => rw_craprac.nraplica
                                                     ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                     ,pr_txaplica => rw_craprac.txaplica
                                                     ,pr_idtxfixa => rw_craprac.idtxfixa
                                                     ,pr_cddindex => rw_craprac.cddindex
                                                     ,pr_qtdiacar => rw_craprac.qtdiacar
                                                     ,pr_idgravir => 1
                                                     ,pr_dtinical => rw_craprac.dtmvtolt
                                                     ,pr_dtfimcal => vr_dtfimcal
                                                     ,pr_idtipbas => pr_idtiprgt
                                                     ,pr_vlbascal => vr_auxbasca
                                                     ,pr_vlsldtot => vr_vlsldtot
                                                     ,pr_vlsldrgt => vr_vlsldrgt
                                                     ,pr_vlultren => vr_auxulren
                                                     ,pr_vlrentot => vr_vlrentot
                                                     ,pr_vlrevers => vr_vlrevers
                                                     ,pr_vlrdirrf => vr_vlrdirrf
                                                     ,pr_percirrf => vr_percirrf
                                                     ,pr_cdcritic => vr_cdcritic
                                                     ,pr_dscritic => vr_dscritic);

              -- Verifica se houve critica no processamento
              IF vr_dscritic IS NOT NULL OR
                 NVL(vr_cdcritic,0) <> 0 THEN
                -- Executa excecao
                pr_tpcritic := 1;
                RAISE vr_exc_saida;
              END IF;

            END IF; -- Fim verificacao tipo de aplicacao

            vr_vllanmto := vr_vlrentot; -- Valor de Rendimento
            vr_vlbasren := 0;

            -- Efetuar o lançamentos
            pc_gera_lancamento(pr_nrdconta => rw_craprac.nrdconta
                              ,pr_nraplica => rw_craprac.nraplica
                              ,pr_tplancto => 'RENDIMENTO'
                              ,pr_cdhistor => rw_craprac.cdhsrdap
                              ,pr_vllanmto => vr_vllanmto
                              ,pr_vlrendim => 0
                              ,pr_vlbasren => vr_vlbasren
                              ,pr_nrseqrgt => pr_nrseqrgt
                              ,pr_idrgtcti => pr_idrgtcti
                              ,pr_craplot  => rw_craplot_II);

            vr_vllanmto := vr_vlrevers; -- Valor de Reversão
            vr_vlbasren := 0;

            -- Efetuar o lançamentos
            pc_gera_lancamento(pr_nrdconta => rw_craprac.nrdconta
                              ,pr_nraplica => rw_craprac.nraplica
                              ,pr_tplancto => 'REVERSAO'
                              ,pr_cdhistor => rw_craprac.cdhsrvap
                              ,pr_vllanmto => vr_vllanmto
                              ,pr_vlrendim => 0
                              ,pr_vlbasren => vr_vlbasren
                              ,pr_nrseqrgt => pr_nrseqrgt
                              ,pr_idrgtcti => pr_idrgtcti
                              ,pr_craplot  => rw_craplot_II);

            vr_vllanmto := vr_vlrdirrf; -- Valor de IRRF
            vr_vlbasren := 0;

            -- Efetuar o lançamentos
            pc_gera_lancamento(pr_nrdconta => rw_craprac.nrdconta
                              ,pr_nraplica => rw_craprac.nraplica
                              ,pr_tplancto => 'IRRF'
                              ,pr_cdhistor => rw_craprac.cdhsirap
                              ,pr_vllanmto => vr_vllanmto
                              ,pr_vlrendim => 0
                              ,pr_vlbasren => vr_vlbasren
                              ,pr_nrseqrgt => pr_nrseqrgt
                              ,pr_idrgtcti => pr_idrgtcti
                              ,pr_craplot  => rw_craplot_II);

            vr_vllanmto := pr_vlresgat; -- Valor de Resgate
            vr_vlbasren := vr_vlbascal;
            vr_vlsldrgt := pr_vlresgat; -- Valor de lancamento do resgate

            -- Efetuar o lançamentos
            pc_gera_lancamento(pr_nrdconta => rw_craprac.nrdconta
                              ,pr_nraplica => rw_craprac.nraplica
                              ,pr_tplancto => 'RESGATE'
                              ,pr_cdhistor => rw_craprac.cdhsrgap
                              ,pr_vllanmto => vr_vllanmto
                              ,pr_vlrendim => vr_vlrentot
                              ,pr_vlbasren => vr_vlbasren
                              ,pr_nrseqrgt => pr_nrseqrgt
                              ,pr_idrgtcti => pr_idrgtcti
                              ,pr_craplot  => rw_craplot_II);
          ELSE
             pr_tpcritic := 0;
             vr_cdcritic := 203;
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
             RAISE vr_exc_saida;
          END IF;  -- Fim Verifica saldo

        ELSIF pr_idtiprgt = 2 THEN -- Resgate Total

          -- Valor de base de calculo
          vr_vlbascal := 0;

          -- Verifica o tipo de aplicacao PRE ou POS
          IF rw_craprac.idtippro = 1  THEN -- Pré-Fixada
            apli0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => rw_craprac.cdcooper
                                                   ,pr_nrdconta => rw_craprac.nrdconta
                                                   ,pr_nraplica => rw_craprac.nraplica
                                                   ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                   ,pr_txaplica => rw_craprac.txaplica
                                                   ,pr_idtxfixa => rw_craprac.idtxfixa
                                                   ,pr_cddindex => rw_craprac.cddindex
                                                   ,pr_qtdiacar => rw_craprac.qtdiacar
                                                   ,pr_idgravir => 1
                                                   ,pr_dtinical => rw_craprac.dtmvtolt
                                                   ,pr_dtfimcal => vr_dtfimcal
                                                   ,pr_idtipbas => 2
                                                   ,pr_vlbascal => vr_vlbascal
                                                   ,pr_vlsldtot => vr_vlsldtot
                                                   ,pr_vlsldrgt => vr_vlsldrgt
                                                   ,pr_vlultren => vr_vlultren
                                                   ,pr_vlrentot => vr_vlrentot
                                                   ,pr_vlrevers => vr_vlrevers
                                                   ,pr_vlrdirrf => vr_vlrdirrf
                                                   ,pr_percirrf => vr_percirrf
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);

            -- Verifica se houve critica no processamento
            IF vr_dscritic IS NOT NULL OR
               NVL(vr_cdcritic,0) <> 0 THEN
              -- Executa excecao
              pr_tpcritic := 1;
              RAISE vr_exc_saida;
            END IF;

          ELSIF rw_craprac.idtippro = 2  THEN -- Pós-Fixada
            apli0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => rw_craprac.cdcooper
                                                   ,pr_nrdconta => rw_craprac.nrdconta
                                                   ,pr_nraplica => rw_craprac.nraplica
                                                   ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                   ,pr_txaplica => rw_craprac.txaplica
                                                   ,pr_idtxfixa => rw_craprac.idtxfixa
                                                   ,pr_cddindex => rw_craprac.cddindex
                                                   ,pr_qtdiacar => rw_craprac.qtdiacar
                                                   ,pr_idgravir => 1
                                                   ,pr_dtinical => rw_craprac.dtmvtolt
                                                   ,pr_dtfimcal => vr_dtfimcal
                                                   ,pr_idtipbas => 2
                                                   ,pr_vlbascal => vr_vlbascal
                                                   ,pr_vlsldtot => vr_vlsldtot
                                                   ,pr_vlsldrgt => vr_vlsldrgt
                                                   ,pr_vlultren => vr_vlultren
                                                   ,pr_vlrentot => vr_vlrentot
                                                   ,pr_vlrevers => vr_vlrevers
                                                   ,pr_vlrdirrf => vr_vlrdirrf
                                                   ,pr_percirrf => vr_percirrf
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);

            -- Verifica se houve critica no processamento
            IF vr_dscritic IS NOT NULL OR
               NVL(vr_cdcritic,0) <> 0 THEN
              -- Executa excecao
              pr_tpcritic := 1;
              RAISE vr_exc_saida;
            END IF;

          END IF; -- Fim verificacao tipo de aplicacao

          -- Efetua lancamento de provisão
          vr_vllanmto := vr_vlultren; -- Valor de provisão
          vr_vlbasren := 0;

          -- Efetuar o lançamentos
          pc_gera_lancamento(pr_nrdconta => rw_craprac.nrdconta
                            ,pr_nraplica => rw_craprac.nraplica
                            ,pr_tplancto => 'PROVISAO'
                            ,pr_cdhistor => rw_craprac.cdhsprap
                            ,pr_vllanmto => vr_vllanmto
                            ,pr_vlrendim => 0
                            ,pr_vlbasren => vr_vlbasren
                            ,pr_nrseqrgt => 0
                            ,pr_idrgtcti => pr_idrgtcti
                            ,pr_craplot  => rw_craplot_II);

          -- Efetua lancamento de reversão
          vr_vllanmto := vr_vlrevers; -- Valor de reversão
          vr_vlbasren := 0;

          -- Efetuar o lançamento de reversão
          pc_gera_lancamento(pr_nrdconta => rw_craprac.nrdconta
                            ,pr_nraplica => rw_craprac.nraplica
                            ,pr_tplancto => 'REVERSAO'
                            ,pr_cdhistor => rw_craprac.cdhsrvap
                            ,pr_vllanmto => vr_vllanmto
                            ,pr_vlrendim => 0
                            ,pr_vlbasren => vr_vlbasren
                            ,pr_nrseqrgt => pr_nrseqrgt
                            ,pr_idrgtcti => pr_idrgtcti
                            ,pr_craplot  => rw_craplot_II);

          -- Efetua lancamento de resgate
          vr_vllanmto := vr_vlsldrgt; -- Valor de resgate
          vr_vlbasren := rw_craprac.vlbasapl;

          -- Efetuar o lançamento de resgate
          pc_gera_lancamento(pr_nrdconta => rw_craprac.nrdconta
                            ,pr_nraplica => rw_craprac.nraplica
                            ,pr_tplancto => 'RESGATE'
                            ,pr_cdhistor => rw_craprac.cdhsrgap
                            ,pr_vllanmto => vr_vllanmto
                            ,pr_vlrendim => vr_vlrentot
                            ,pr_vlbasren => vr_vlbasren
                            ,pr_nrseqrgt => pr_nrseqrgt
                            ,pr_idrgtcti => pr_idrgtcti
                            ,pr_craplot  => rw_craplot_II);

          -- Efetua lancamento de rendimento
          vr_vllanmto := vr_vlrentot; -- Valor de rendimento
          vr_vlrentot := vr_vlrentot;
          vr_vlbasren := vr_vlbascal;

          -- Efetuar o lançamento de rendimento
          pc_gera_lancamento(pr_nrdconta => rw_craprac.nrdconta
                            ,pr_nraplica => rw_craprac.nraplica
                            ,pr_tplancto => 'RENDIMENTO'
                            ,pr_cdhistor => rw_craprac.cdhsrdap
                            ,pr_vllanmto => vr_vllanmto
                            ,pr_vlrendim => vr_vlrentot
                            ,pr_vlbasren => vr_vlbasren
                            ,pr_nrseqrgt => pr_nrseqrgt
                            ,pr_idrgtcti => pr_idrgtcti
                            ,pr_craplot  => rw_craplot_II);

          -- Efetua lancamento de IRRF
          vr_vllanmto := vr_vlrdirrf; -- Valor de IRRF
          vr_vlrentot := 0;
          vr_vlbasren := 0;

          -- Efetuar o lançamento de IRRF
          pc_gera_lancamento(pr_nrdconta => rw_craprac.nrdconta
                            ,pr_nraplica => rw_craprac.nraplica
                            ,pr_tplancto => 'IRRF'
                            ,pr_cdhistor => rw_craprac.cdhsirap
                            ,pr_vllanmto => vr_vllanmto
                            ,pr_vlrendim => vr_vlrentot
                            ,pr_vlbasren => vr_vlbasren
                            ,pr_nrseqrgt => pr_nrseqrgt
                            ,pr_idrgtcti => pr_idrgtcti
                            ,pr_craplot  => rw_craplot_II);

        END IF;

      END IF; -- Fim verificacao periodo de carencia

      -- Procedimentos de efetivação do resgate - Atualizar posição da aplicação

      -- Quando for o primeiro resgate no dia, os campos abaixo devem ser atualizados nos resgates
      -- parciais e totais, antes da atualização descrita para cada tipo de resgate.
      IF rw_craprac.dtatlsld <> vr_dtmvtolt THEN
        BEGIN
        UPDATE
          craprac
        SET
          craprac.vlbasant = rw_craprac.vlbasapl,
          craprac.vlsldant = rw_craprac.vlsldatl,
          craprac.dtsldant = rw_craprac.dtatlsld
        WHERE
          craprac.rowid = rw_craprac.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar registro de aplicacao. Erro' || SQLERRM;
            pr_tpcritic := 1;
            RAISE vr_exc_saida;
        END;
      END IF;

      -- Verifica tipo de resgate
      IF pr_idtiprgt = 1 THEN -- Resgate Parcial

        -- DUVIDA REFERENTE AO VALOR DE PROVISAO E RENDIMENTO TOTAL
        IF vr_flgaplca AND vr_flgprmap THEN -- Aplicacao dentro da carencia e no primeiro mes
          vr_valresta := rw_craprac.vlsldatl - pr_vlresgat;
          vr_datresga := rw_craprac.dtatlsld;
        ELSIF vr_flgaplca AND NOT vr_flgprmap THEN -- Aplicacao dentro da carencia
          vr_valresta := (rw_craprac.vlsldatl + vr_vlultren) - (pr_vlresgat + vr_vlrevers);
          vr_datresga := vr_dtmvtolt;
        ELSIF NOT vr_flgaplca THEN -- Aplicacao fora da carencia
          vr_valresta := (rw_craprac.vlsldatl + vr_vlultren + vr_vlrentot) - (pr_vlresgat + vr_vlrevers + vr_vlrdirrf);
          vr_datresga := vr_dtmvtolt;
        END IF;

        -- Atualiza registro de aplicacao
        BEGIN

          UPDATE
            craprac
          SET
            craprac.vlsldatl = vr_valresta,                    -- Valor de saldo restante
            craprac.dtatlsld = vr_datresga,                    -- Data de resgate
            craprac.vlbasapl = craprac.vlbasapl - vr_vlbasren  -- Valor de base aplicacao
          WHERE
            craprac.rowid = rw_craprac.rowid;

        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            pr_tpcritic := 1;
            vr_dscritic := 'Erro ao atualizar registro de resgate de aplicacao.';
            RAISE vr_exc_saida;
        END;

        BEGIN
          UPDATE
            craprga
          SET
            craprga.vlresgat = pr_vlresgat
           ,craprga.idresgat = 1
          WHERE
                craprga.cdcooper = pr_cdcooper
            AND craprga.nrdconta = pr_nrdconta
            AND craprga.nraplica = pr_nraplica
            AND craprga.nrseqrgt = pr_nrseqrgt;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            pr_tpcritic := 1;
            vr_dscritic := 'Erro ao atualizar registro de resgate de aplicacao.';
            RAISE vr_exc_saida;
        END;

        -- Valor de resgate
        vr_vlsldrgt := pr_vlresgat;

      ELSIF pr_idtiprgt = 2 THEN -- Resgate Total

        IF pr_dtresgat > rw_crapdat.dtmvtolt AND -- Não é resgate online
          TO_CHAR(rw_crapdat.dtmvtopr,'MM') <> TO_CHAR(rw_crapdat.dtmvtolt,'MM') THEN -- Ultimo dia útil do mes
          vr_idcalorc := 0;
        ELSE
          vr_idcalorc := 1;
        END IF;

        -- Atualiza registro de aplicacao
        BEGIN

          UPDATE
            craprac
          SET
            craprac.idsaqtot = 1,
            craprac.idcalorc = vr_idcalorc,
            craprac.vlbasapl = 0,
            craprac.vlsldatl = 0,
            craprac.dtatlsld = vr_dtmvtolt
          WHERE
            craprac.rowid = rw_craprac.rowid;

        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            pr_tpcritic := 1;
            vr_dscritic := 'Erro ao atualizar registro de resgate de aplicacao.';
            RAISE vr_exc_saida;
        END;

        BEGIN
          UPDATE
            craprga
          SET
            craprga.vlresgat = vr_vlsldrgt
           ,craprga.idresgat = 1
          WHERE
                craprga.cdcooper = pr_cdcooper
            AND craprga.nrdconta = pr_nrdconta
            AND craprga.nraplica = pr_nraplica
            AND craprga.nrseqrgt = pr_nrseqrgt;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            pr_tpcritic := 1;
            vr_dscritic := 'Erro ao atualizar registro de resgate de aplicacao.';
            RAISE vr_exc_saida;
        END;

      END IF;

      -- Verifica se o resgate foi agendado para ser creditado em conta investimento
      IF pr_idrgtcti = 1 THEN

        -- Consulta de lote
        OPEN cr_craplot(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                       ,pr_dtmvtolt => vr_dtmvtolt --> data de movimento
                       ,pr_cdagenci => 1           --> Codigo da agencia
                       ,pr_cdbccxlt => 100         --> Codigo do caixa
                       ,pr_nrdolote => 10113       --> Numero do lote
                       ,pr_tplotmov => 29);        --> Tipo de movimento

        FETCH cr_craplot INTO rw_craplot;

        -- Verifica se registro de lote existe
        IF cr_craplot%NOTFOUND THEN

          -- Fecha cursor
          CLOSE cr_craplot;

          -- Insere registro de lote
          BEGIN
            INSERT INTO
              craplot(
                cdcooper
               ,dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,tplotmov
               ,nrseqdig
               ,qtinfoln
               ,qtcompln
               ,vlinfocr
               ,vlcompcr
              )VALUES(
                 rw_craprac.cdcooper,vr_dtmvtolt
                ,1,100,10113,29,0,0,0,0,0)
                 RETURNING
                   cdcooper,dtmvtolt,cdagenci,cdbccxlt,
                   nrdolote,tplotmov,nrseqdig,qtinfoln,
                   qtcompln,vlinfocr,vlcompcr,ROWID
                 INTO
                   rw_craplot.cdcooper,rw_craplot.dtmvtolt
                  ,rw_craplot.cdagenci,rw_craplot.cdbccxlt
                  ,rw_craplot.nrdolote,rw_craplot.tplotmov
                  ,rw_craplot.nrseqdig,rw_craplot.qtinfoln
                  ,rw_craplot.qtcompln,rw_craplot.vlinfocr
                  ,rw_craplot.vlcompcr,rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              pr_tpcritic := 1;
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao inserir registro de lote. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

        ELSE
          -- Fecha cursor
          CLOSE cr_craplot;
        END IF;

        -- Atualiza registro de lote
        BEGIN

          UPDATE
            craplot
          SET
            craplot.nrseqdig = rw_craplot.nrseqdig + 1,
            craplot.qtinfoln = rw_craplot.qtinfoln + 1,
            craplot.qtcompln = rw_craplot.qtcompln + 1,
            craplot.vlinfocr = rw_craplot.vlinfocr + vr_vlsldrgt,
            craplot.vlcompcr = rw_craplot.vlcompcr + vr_vlsldrgt
          WHERE
            craplot.rowid    = rw_craplot.rowid
          RETURNING
            cdcooper,dtmvtolt,cdagenci,cdbccxlt,
            nrdolote,tplotmov,nrseqdig,qtinfoln,
            qtcompln,vlinfocr,vlcompcr,ROWID
          INTO
            rw_craplot.cdcooper,rw_craplot.dtmvtolt
           ,rw_craplot.cdagenci,rw_craplot.cdbccxlt
           ,rw_craplot.nrdolote,rw_craplot.tplotmov
           ,rw_craplot.nrseqdig,rw_craplot.qtinfoln
           ,rw_craplot.qtcompln,rw_craplot.vlinfocr
           ,rw_craplot.vlcompcr,rw_craplot.rowid;

        EXCEPTION
          WHEN OTHERS THEN
            pr_tpcritic := 1;
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar registro de lote. Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Atualiza numero do documento
        vr_nrdocmto := pr_nraplica;

        -- Verifica numero do documento
        LOOP
          -- Consulta lancamento de credito
          OPEN cr_craplci(pr_cdcooper => rw_craplot.cdcooper --> Código da Cooperativa
                         ,pr_dtmvtolt => rw_craplot.dtmvtolt --> Data de movimento
                         ,pr_cdagenci => rw_craplot.cdagenci --> Codigo da agencia
                         ,pr_cdbccxlt => rw_craplot.cdbccxlt --> Codigo do caixa
                         ,pr_nrdolote => rw_craplot.nrdolote --> Numero do lote
                         ,pr_nrdconta => pr_nrdconta         --> Numero da conta
                         ,pr_nrdocmto => vr_nrdocmto);       --> Numero do documento

          FETCH cr_craplci INTO rw_craplci;

          -- Verifica se encontrou registro
          IF cr_craplci%NOTFOUND THEN
            CLOSE cr_craplci;
            EXIT;
          ELSE
            CLOSE cr_craplci;
            vr_nrdocmto := TO_NUMBER('9' || to_char(vr_nrdocmto));
            CONTINUE;
          END IF;

        END LOOP;

        -- Insere registro de lancamento de credito
        IF vr_vlsldrgt > 0 THEN
          BEGIN

            INSERT INTO craplci(
                cdcooper
               ,dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,nrdconta
               ,nrdocmto
               ,nrseqdig
               ,vllanmto
               ,cdhistor
               ,nraplica)
             VALUES(
               rw_craplot.cdcooper
              ,rw_craplot.dtmvtolt
              ,rw_craplot.cdagenci
              ,rw_craplot.cdbccxlt
              ,rw_craplot.nrdolote
              ,pr_nrdconta
              ,vr_nrdocmto
              ,rw_craplot.nrseqdig
              ,vr_vlsldrgt         -- Valor do resgate
              ,490
              ,pr_nraplica);

          EXCEPTION
            WHEN OTHERS THEN
              pr_tpcritic := 1;
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao inserir registro de credito(CRAPLCI). Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;
        -- Consulta de registro de saldo
        OPEN cr_crapsli(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_dtrefere => rw_crapdat.dtultdia);

        FETCH cr_crapsli INTO rw_crapsli;

        IF cr_crapsli%NOTFOUND THEN
          -- Fecha cursor
          CLOSE cr_crapsli;
          IF vr_vlsldrgt > 0 THEN
            BEGIN
              INSERT INTO
                crapsli(
                  nrdconta
                 ,dtrefere
                 ,vlsddisp
                 ,cdcooper
               )VALUES(
                 pr_nrdconta
                ,rw_crapdat.dtultdia
                ,vr_vlsldrgt
                ,pr_cdcooper);
            EXCEPTION
              WHEN OTHERS THEN
                -- Gera critica
                pr_tpcritic := 1;
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao inserir registro de saldo(CRAPSLI). Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
          END IF;
        ELSE
          -- Fecha cursor
          CLOSE cr_crapsli;

          -- Atualiza resgistro de saldo
          BEGIN
            UPDATE
              crapsli
            SET
              crapsli.vlsddisp = (crapsli.vlsddisp + vr_vlsldrgt)
            WHERE
              crapsli.rowid = rw_crapsli.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              -- Gera critica
              pr_tpcritic := 1;
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar registro de saldo(CRAPSLI). Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

        END IF;

      ELSIF pr_idrgtcti = 0 THEN -- Verifica se o resgate foi agendado para ser creditado em conta-corrente

        -- Registro de debito

        -- Consulta de lote de débito
        OPEN cr_craplot(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                       ,pr_dtmvtolt => vr_dtmvtolt --> data de movimento
                       ,pr_cdagenci => 1           --> Codigo da agencia
                       ,pr_cdbccxlt => 100         --> Codigo do caixa
                       ,pr_nrdolote => 10111       --> Numero do lote
                       ,pr_tplotmov => 29);        --> Tipo de movimento

        FETCH cr_craplot INTO rw_craplot;

        -- Verifica se registro de lote existe
        IF cr_craplot%NOTFOUND THEN

          -- Fecha cursor
          CLOSE cr_craplot;

          -- Insere registro de lote
          BEGIN
            INSERT INTO
              craplot(
                cdcooper
               ,dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,tplotmov
               ,nrseqdig
               ,qtinfoln
               ,qtcompln
               ,vlinfocr
               ,vlcompcr
              )VALUES(
                 rw_craprac.cdcooper,vr_dtmvtolt
                ,1,100,10111,29,0,0,0,0,0)
                 RETURNING
                   cdcooper,dtmvtolt,cdagenci,cdbccxlt,
                   nrdolote,tplotmov,nrseqdig,qtinfoln,
                   qtcompln,vlinfocr,vlcompcr, ROWID
                 INTO
                   rw_craplot.cdcooper,rw_craplot.dtmvtolt
                  ,rw_craplot.cdagenci,rw_craplot.cdbccxlt
                  ,rw_craplot.nrdolote,rw_craplot.tplotmov
                  ,rw_craplot.nrseqdig,rw_craplot.qtinfoln
                  ,rw_craplot.qtcompln,rw_craplot.vlinfocr
                  ,rw_craplot.vlcompcr,rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              pr_tpcritic := 1;
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao inserir registro de lote. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

        ELSE
          -- Fecha cursor
          CLOSE cr_craplot;
        END IF;

        -- Atualiza registro de lote
        BEGIN

          UPDATE
            craplot
          SET
            craplot.nrseqdig = craplot.nrseqdig + 1,
            craplot.qtinfoln = craplot.qtinfoln + 1,
            craplot.qtcompln = craplot.qtcompln + 1,
            craplot.vlinfocr = craplot.vlinfocr + vr_vlsldrgt,
            craplot.vlcompcr = craplot.vlcompcr + vr_vlsldrgt
          WHERE
            craplot.rowid    = rw_craplot.rowid
          RETURNING
            cdcooper, dtmvtolt, cdagenci, cdbccxlt,
            nrdolote, tplotmov, nrseqdig, qtinfoln,
            qtcompln, vlinfocr, vlcompcr, ROWID
          INTO
            rw_craplot.cdcooper, rw_craplot.dtmvtolt, rw_craplot.cdagenci,
            rw_craplot.cdbccxlt, rw_craplot.nrdolote, rw_craplot.tplotmov,
            rw_craplot.nrseqdig, rw_craplot.qtinfoln, rw_craplot.qtcompln,
            rw_craplot.vlinfocr, rw_craplot.vlcompcr, rw_craplot.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            pr_tpcritic := 1;
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar registro de lote de debito. Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Insere registro de lancamento de debito
        IF vr_vlsldrgt > 0 THEN

          -- Atualiza numero do documento
          vr_nrdocmto := pr_nraplica;

          -- Verifica numero do documento
          LOOP
            -- Consulta lancamento de credito
            OPEN cr_craplci(pr_cdcooper => rw_craplot.cdcooper --> Código da Cooperativa
                           ,pr_dtmvtolt => rw_craplot.dtmvtolt --> Data de movimento
                           ,pr_cdagenci => rw_craplot.cdagenci --> Codigo da agencia
                           ,pr_cdbccxlt => rw_craplot.cdbccxlt --> Codigo do caixa
                           ,pr_nrdolote => rw_craplot.nrdolote --> Numero do lote
                           ,pr_nrdconta => pr_nrdconta         --> Numero da conta
                           ,pr_nrdocmto => vr_nrdocmto);       --> Numero do documento

            FETCH cr_craplci INTO rw_craplci;

            -- Verifica se encontrou registro
            IF cr_craplci%NOTFOUND THEN
              CLOSE cr_craplci;
              EXIT;
            ELSE
              CLOSE cr_craplci;
              vr_nrdocmto := TO_NUMBER('9' || to_char(vr_nrdocmto));
              CONTINUE;
            END IF;

          END LOOP;

          BEGIN
            INSERT INTO
              craplci(
                  cdcooper
                 ,dtmvtolt
                 ,cdagenci
                 ,cdbccxlt
                 ,nrdolote
                 ,nrdconta
                 ,nrdocmto
                 ,nrseqdig
                 ,vllanmto
                 ,cdhistor
                 ,nraplica)
               VALUES(
                  rw_craplot.cdcooper
                 ,rw_craplot.dtmvtolt
                 ,rw_craplot.cdagenci
                 ,rw_craplot.cdbccxlt
                 ,rw_craplot.nrdolote
                 ,rw_craprac.nrdconta
                 ,vr_nrdocmto
                 ,rw_craplot.nrseqdig
                 ,vr_vlsldrgt         -- Valor do resgate
                 ,rw_craprac.cdhsrgap
                 ,pr_nraplica);

          EXCEPTION
            WHEN OTHERS THEN
              pr_tpcritic := 1;
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao inserir registro de lancamento de debito. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;
        -- Fim de registro de debito

        -- Registro de credito

        -- Consulta de lote de débito
        OPEN cr_craplot(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                       ,pr_dtmvtolt => vr_dtmvtolt --> data de movimento
                       ,pr_cdagenci => 1           --> Codigo da agencia
                       ,pr_cdbccxlt => 100         --> Codigo do caixa
                       ,pr_nrdolote => 10112       --> Numero do lote
                       ,pr_tplotmov => 29);        --> Tipo de movimento

        FETCH cr_craplot INTO rw_craplot;

        -- Verifica se registro de lote existe
        IF cr_craplot%NOTFOUND THEN

          -- Fecha cursor
          CLOSE cr_craplot;

          -- Insere registro de lote
          BEGIN
            INSERT INTO
              craplot(
                cdcooper
               ,dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,tplotmov
               ,nrseqdig
               ,qtinfoln
               ,qtcompln
               ,vlinfocr
               ,vlcompcr
              )VALUES(
                 rw_craprac.cdcooper,vr_dtmvtolt
                ,1,100,10112,29,0,0,0,0,0)
                 RETURNING
                   cdcooper,dtmvtolt,cdagenci,cdbccxlt
                  ,nrdolote,tplotmov,nrseqdig,qtinfoln
                  ,qtcompln,vlinfocr,vlcompcr,ROWID
                 INTO
                   rw_craplot.cdcooper,rw_craplot.dtmvtolt
                  ,rw_craplot.cdagenci,rw_craplot.cdbccxlt
                  ,rw_craplot.nrdolote,rw_craplot.tplotmov
                  ,rw_craplot.nrseqdig,rw_craplot.qtinfoln
                  ,rw_craplot.qtcompln,rw_craplot.vlinfocr
                  ,rw_craplot.vlcompcr,rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              pr_tpcritic := 1;
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao inserir registro de lote. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

        ELSE
          -- Fecha cursor
          CLOSE cr_craplot;
        END IF;

        -- Atualiza registro de lote
        BEGIN

          UPDATE
            craplot
          SET
            craplot.nrseqdig = craplot.nrseqdig + 1,
            craplot.qtinfoln = craplot.qtinfoln + 1,
            craplot.qtcompln = craplot.qtcompln + 1,
            craplot.vlinfodb = craplot.vlinfodb + vr_vlsldrgt,
            craplot.vlcompdb = craplot.vlcompdb + vr_vlsldrgt
          WHERE
            craplot.rowid    = rw_craplot.rowid
          RETURNING
            cdcooper, dtmvtolt, cdagenci, cdbccxlt,
            nrdolote, tplotmov, nrseqdig, qtinfoln,
            qtcompln, vlinfodb, vlcompdb, ROWID
          INTO
            rw_craplot.cdcooper, rw_craplot.dtmvtolt, rw_craplot.cdagenci,
            rw_craplot.cdbccxlt, rw_craplot.nrdolote, rw_craplot.tplotmov,
            rw_craplot.nrseqdig, rw_craplot.qtinfoln, rw_craplot.qtcompln,
            rw_craplot.vlinfodb, rw_craplot.vlcompdb, rw_craplot.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            pr_tpcritic := 1;
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar registro de lote de credito. Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Insere registro de lancamento de credito
        IF vr_vlsldrgt > 0 THEN

          -- Atualiza numero do documento
          vr_nrdocmto := pr_nraplica;

          -- Verifica numero do documento
          LOOP
            -- Consulta lancamento de credito
            OPEN cr_craplci(pr_cdcooper => rw_craplot.cdcooper --> Código da Cooperativa
                           ,pr_dtmvtolt => rw_craplot.dtmvtolt --> Data de movimento
                           ,pr_cdagenci => rw_craplot.cdagenci --> Codigo da agencia
                           ,pr_cdbccxlt => rw_craplot.cdbccxlt --> Codigo do caixa
                           ,pr_nrdolote => rw_craplot.nrdolote --> Numero do lote
                           ,pr_nrdconta => pr_nrdconta         --> Numero da conta
                           ,pr_nrdocmto => vr_nrdocmto);       --> Numero do documento

            FETCH cr_craplci INTO rw_craplci;

            -- Verifica se encontrou registro
            IF cr_craplci%NOTFOUND THEN
              CLOSE cr_craplci;
              EXIT;
            ELSE
              CLOSE cr_craplci;
              vr_nrdocmto := TO_NUMBER('9' || to_char(vr_nrdocmto));
              CONTINUE;
            END IF;

          END LOOP;

          BEGIN
            INSERT INTO
              craplci(
                  cdcooper
                 ,dtmvtolt
                 ,cdagenci
                 ,cdbccxlt
                 ,nrdolote
                 ,nrdconta
                 ,nrdocmto
                 ,nrseqdig
                 ,vllanmto
                 ,cdhistor
                 ,nraplica)
               VALUES(
                  rw_craplot.cdcooper
                 ,rw_craplot.dtmvtolt
                 ,rw_craplot.cdagenci
                 ,rw_craplot.cdbccxlt
                 ,rw_craplot.nrdolote
                 ,rw_craprac.nrdconta
                 ,vr_nrdocmto
                 ,rw_craplot.nrseqdig
                 ,vr_vlsldrgt         -- Valor do resgate
                 ,489
                 ,pr_nraplica);
          EXCEPTION
            WHEN OTHERS THEN
              pr_tpcritic := 1;
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao inserir registro de lancamento de debito. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;
        END IF;
        -- Fim de registro de credito

        -- Credito em conta corrente

        -- Consulta de lote para lancamento em CC
        OPEN cr_craplot(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                       ,pr_dtmvtolt => vr_dtmvtolt --> data de movimento
                       ,pr_cdagenci => 1           --> Codigo da agencia
                       ,pr_cdbccxlt => 100         --> Codigo do caixa
                       ,pr_nrdolote => 8503        --> Numero do lote
                       ,pr_tplotmov => 1);         --> Tipo de movimento

        FETCH cr_craplot INTO rw_craplot;

        -- Verifica se registro de lote existe
        IF cr_craplot%NOTFOUND THEN

          -- Fecha cursor
          CLOSE cr_craplot;

          -- Insere registro de lote
          BEGIN
            INSERT INTO
              craplot(
                cdcooper
               ,dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,tplotmov
               ,nrseqdig
               ,qtinfoln
               ,qtcompln
               ,vlinfocr
               ,vlcompcr
              )VALUES(
                 rw_craprac.cdcooper,vr_dtmvtolt
                ,1,100,8503,1,0,0,0,0,0)
                 RETURNING
                   cdcooper,dtmvtolt,cdagenci,cdbccxlt,
                   nrdolote,tplotmov,nrseqdig,qtinfoln,
                   qtcompln,vlinfocr,vlcompcr,ROWID
                 INTO
                   rw_craplot.cdcooper,rw_craplot.dtmvtolt
                  ,rw_craplot.cdagenci,rw_craplot.cdbccxlt
                  ,rw_craplot.nrdolote,rw_craplot.tplotmov
                  ,rw_craplot.nrseqdig,rw_craplot.qtinfoln
                  ,rw_craplot.qtcompln,rw_craplot.vlinfocr
                  ,rw_craplot.vlcompcr,rw_craplot.ROWID;
          EXCEPTION
            WHEN OTHERS THEN
              pr_tpcritic := 1;
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao inserir registro de lote. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

        ELSE
          -- Fecha cursor
          CLOSE cr_craplot;
        END IF;

        -- Atualiza registro de lote
        BEGIN

          UPDATE
            craplot
          SET
            craplot.nrseqdig = craplot.nrseqdig + 1,
            craplot.qtinfoln = craplot.qtinfoln + 1,
            craplot.qtcompln = craplot.qtcompln + 1,
            craplot.vlinfocr = craplot.vlinfocr + vr_vlsldrgt,
            craplot.vlcompcr = craplot.vlcompcr + vr_vlsldrgt
          WHERE
            craplot.rowid    = rw_craplot.rowid
          RETURNING
            cdcooper, dtmvtolt, cdagenci, cdbccxlt,
            nrdolote, tplotmov, nrseqdig, qtinfoln,
            qtcompln, vlinfocr, vlcompcr, ROWID
          INTO
            rw_craplot.cdcooper, rw_craplot.dtmvtolt, rw_craplot.cdagenci,
            rw_craplot.cdbccxlt, rw_craplot.nrdolote, rw_craplot.tplotmov,
            rw_craplot.nrseqdig, rw_craplot.qtinfoln, rw_craplot.qtcompln,
            rw_craplot.vlinfocr, rw_craplot.vlcompcr, rw_craplot.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            pr_tpcritic := 1;
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar registro de lote de credito. Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Atualiza numero de documento para consulta
        vr_nrdocmto := pr_nraplica;

        -- Verifica numero do documento
        LOOP
          -- Consulta lancamento de credito
          OPEN cr_craplcm(pr_cdcooper => rw_craplot.cdcooper --> Código da Cooperativa
                         ,pr_dtmvtolt => rw_craplot.dtmvtolt --> Data de movimento
                         ,pr_cdagenci => rw_craplot.cdagenci --> Codigo da agencia
                         ,pr_cdbccxlt => rw_craplot.cdbccxlt --> Codigo do caixa
                         ,pr_nrdolote => rw_craplot.nrdolote --> Numero do lote
                         ,pr_nrdconta => pr_nrdconta         --> Numero da conta
                         ,pr_nrdocmto => vr_nrdocmto);       --> Numero do documento

          FETCH cr_craplcm INTO rw_craplcm;

          -- Verifica se encontrou registro
          IF cr_craplcm%NOTFOUND THEN
            CLOSE cr_craplcm;
            EXIT;
          ELSE
            CLOSE cr_craplcm;
            vr_nrdocmto := TO_NUMBER('9' || to_char(vr_nrdocmto));
            CONTINUE;
          END IF;

        END LOOP;

        -- Insere registro de lancamento
        IF vr_vlsldrgt > 0 THEN
           LANC0001.pc_gerar_lancamento_conta(
                          pr_cdcooper => rw_craplot.cdcooper
                         ,pr_dtmvtolt => rw_craplot.dtmvtolt                         
                         ,pr_cdagenci => rw_craplot.cdagenci
                         ,pr_cdbccxlt => rw_craplot.cdbccxlt
                         ,pr_nrdolote => rw_craplot.nrdolote
                         ,pr_nrdconta => rw_craprac.nrdconta
                         ,pr_nrdctabb => rw_craprac.nrdconta
                         ,pr_nrdocmto => vr_nrdocmto
                         ,pr_nrseqdig => rw_craplot.nrseqdig
                         ,pr_dtrefere => rw_craplot.dtmvtolt
                         ,pr_vllanmto => vr_vlsldrgt         -- Valor do resgate
                         ,pr_cdhistor => rw_craprac.cdhsvrcc
                         ,pr_nraplica => pr_nraplica                        
                         -- OUTPUT --
                         ,pr_tab_retorno => vr_tab_retorno
                         ,pr_incrineg => vr_incrineg
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);

            IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN                
              pr_tpcritic := 1;
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao inserir registro de lancamento de credito. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
            END IF;                                             
        END IF;
        -- Fim credito em conta corrente

      END IF; -- Fim verifica tipo de agendamento

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN

        pr_tpcritic := 1;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado no resgate de aplicacoes APLI0005.pc_efetua_resgate: ' || SQLERRM;
    END;

  END pc_efetua_resgate;

  PROCEDURE pc_busca_extrato_aplicacao (pr_cdcooper IN craprac.cdcooper%TYPE,    -- Código da Cooperativa
                                        pr_cdoperad IN crapope.cdoperad%TYPE,    -- Código do Operador
                                        pr_nmdatela IN craptel.nmdatela%TYPE,    -- Nome da Tela
                                        pr_idorigem IN NUMBER,                   -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                        pr_nrdconta IN craprac.nrdconta%TYPE,    -- Número da Conta
                                        pr_idseqttl IN crapttl.idseqttl%TYPE,    -- Titular da Conta
                                        pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,    -- Data de Movimento
                                        pr_nraplica IN craprac.nraplica%TYPE,    -- Número da Aplicação
                                        pr_idlstdhs IN NUMBER,                   -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                        pr_idgerlog IN NUMBER,                   -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                        pr_tab_extrato OUT APLI0005.typ_tab_extrato, -- PLTable com os dados de extrato
                                        pr_vlresgat OUT NUMBER,                  -- Valor de resgate
                                        pr_vlrendim OUT NUMBER,                  -- Valor de rendimento
                                        pr_vldoirrf OUT NUMBER,                  -- Valor do IRRF
                                        pr_txacumul OUT NUMBER,                  -- Taxa acumulada durante o período total da aplicação
                                        pr_txacumes OUT NUMBER,                  -- Taxa acumulada durante o mês vigente
                                        pr_percirrf OUT NUMBER,                  -- Valor de aliquota de IR
                                        pr_cdcritic OUT crapcri.cdcritic%TYPE,   -- Código da crítica
                                        pr_dscritic OUT crapcri.dscritic%TYPE    -- Descrição da crítica
                                        ) IS
  BEGIN
   /* .............................................................................

     Programa: pc_busca_extrato_aplicacao
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Lucas Reinert
     Data    : Setembro/14.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de extratos das aplicações de captação.

     Observacao: -----

     Alteracoes: 09/03/2014 - Inclusão do parametro pr_percirrf. (Jean Michel)
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variáveis retornadas da procedure IMUT0001.pc_verifica_periodo_imune
      vr_flgimune BOOLEAN;
      vr_dtinicio DATE;
      vr_dttermin DATE;
      vr_dsreturn VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;

      --Variáveis locais
      vr_dstransa VARCHAR2(100) := 'Busca extrato de aplicacao num: ' || pr_nraplica;
      vr_dsorigem VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_nrdrowid ROWID;
      vr_lshistor VARCHAR2(200);
      vr_vlresgat NUMBER;
      vr_vlrendim NUMBER;
      vr_vldoirrf NUMBER;
      vr_vlsldtot NUMBER;
      vr_dshistor craphis.dshistor%TYPE;
      vr_dsextrat craphis.dsextrat%TYPE;
      vr_qtdiasir PLS_INTEGER := 0; -- Qtd de dias para calculo de faixa de IR
      vr_percirrf NUMBER;
      vr_txlancto NUMBER;

      -- PLTable que conterá os dados do extrato
      vr_tab_extrato APLI0005.typ_tab_extrato;
      vr_ind_extrato PLS_INTEGER := 0;

      -- Busca registro de aplicações de captação
      CURSOR cr_craprac(pr_cdcooper IN craprac.cdcooper%TYPE,
                        pr_nrdconta IN craprac.nrdconta%TYPE,
                        pr_nraplica IN craprac.nraplica%TYPE) IS

        SELECT craprac.txaplica,
               craprac.dtmvtolt,
               craprac.qtdiacar,
               crapcpc.idtippro,
               crapcpc.idtxfixa,
               crapcpc.cddindex,
               crapcpc.cdhsraap,
               crapcpc.cdhsnrap,
               crapcpc.cdhsprap,
               crapcpc.cdhsrvap,
               crapcpc.cdhsrdap,
               crapcpc.cdhsirap,
               crapcpc.cdhsrgap,
               crapcpc.cdhsvtap
          FROM craprac,
               crapcpc
         WHERE craprac.cdcooper = pr_cdcooper AND
               craprac.nrdconta = pr_nrdconta AND
               craprac.nraplica = pr_nraplica AND
               crapcpc.cdprodut = craprac.cdprodut;

      rw_craprac cr_craprac%ROWTYPE;

      -- Busca lançamentos de aplicações de captação
      CURSOR cr_craplac(pr_cdcooper IN craplac.cdcooper%TYPE
                       ,pr_nrdconta IN craplac.nrdconta%TYPE
                       ,pr_nraplica IN craplac.nraplica%TYPE
                       ,pr_cdhsprap IN craphis.cdhistor%TYPE
                       ,pr_cdhsrvap IN craphis.cdhistor%TYPE
                       ,pr_cdhsrdap IN craphis.cdhistor%TYPE
                       ,pr_cdhsirap IN craphis.cdhistor%TYPE
                       ,pr_cdhsrgap IN craphis.cdhistor%TYPE) IS
        SELECT lac.vllanmto,
               lac.cdhistor,
               lac.dtmvtolt,
               lac.cdagenci,
               lac.nrdocmto,
               lac.nraplica
          FROM craplac lac
         WHERE lac.cdcooper = pr_cdcooper
           AND lac.nrdconta = pr_nrdconta
           AND lac.nraplica = pr_nraplica
           /*AND to_char(lac.cdhistor) IN ( -- Quebra String em registros separados por ','
                                         SELECT regexp_substr(pr_lshistor,'[^,]+', 1, LEVEL) FROM dual
                                         CONNECT BY regexp_substr(pr_lshistor,'[^,]+', 1, LEVEL) IS NOT NULL
                                        )*/
         ORDER BY lac.dtmvtolt,
                  decode(lac.cdhistor,pr_cdhsprap,1 --PROVISAO
                                     ,pr_cdhsrvap,2 --REVERSAO PRV
                                     ,pr_cdhsrdap,3 --RENDIMENTO
                                     ,pr_cdhsirap,4 --IRRF
                                     ,pr_cdhsrgap,5 --RESGATE
                                     ,0),
                  lac.cdhistor;

      -- Buscar histórico de lançamento das aplicações
      CURSOR cr_craphis(pr_cdcooper IN craphis.cdcooper%TYPE
                       ,pr_cdhistor IN craphis.cdhistor%TYPE) IS
        SELECT his.indebcre,
               his.dshistor,
               his.dsextrat,
               his.cdhistor
          FROM craphis his
         WHERE his.cdcooper = pr_cdcooper
           AND his.cdhistor = pr_cdhistor;
      rw_craphis cr_craphis%ROWTYPE;

    BEGIN

      -- Abre cursor de registro de aplicação de captação
      OPEN cr_craprac(pr_cdcooper => pr_cdcooper,             --> Cooperativa
                      pr_nrdconta => pr_nrdconta,             --> Nr. da conta
                      pr_nraplica => pr_nraplica);            --> Nr. da aplicação
      FETCH cr_craprac INTO rw_craprac;

      -- Se não encontrar registro de aplicação
      IF cr_craprac%NOTFOUND THEN
        -- Alimenta variáveis de crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Aplicacao nao encontrada | Nr. da conta: ' || gene0002.fn_mask_conta(pr_nrdconta) ||
                       ' | Nr. aplicacao: ' || pr_nraplica || ' |';
        CLOSE cr_craprac;
        -- Levanta exception
        RAISE vr_exc_saida;
      END IF;

      CLOSE cr_craprac;

      IF rw_craprac.idtippro = 1 THEN -- Pré-fixada

        -- Buscar as taxas acumuladas da aplicação
        APLI0006.pc_taxa_acumul_aplic_pre(pr_cdcooper => pr_cdcooper,          --> Código da Cooperativa
                                          pr_txaplica => rw_craprac.txaplica,  --> Taxa da Aplicação
                                          pr_idtxfixa => rw_craprac.idtxfixa,  --> Taxa Fixa (1-SIM/2-NAO)
                                          pr_cddindex => rw_craprac.cddindex,  --> Código do Indexador
                                          pr_dtinical => rw_craprac.dtmvtolt,  --> Data Inicial Cálculo (Fixo na chamada)
                                          pr_dtfimcal => pr_dtmvtolt,          --> Data Final Cálculo (Fixo na chamada)
                                          pr_txacumul => pr_txacumul,          --> Taxa acumulada durante o período total da aplicação
                                          pr_txacumes => pr_txacumes,          --> Taxa acumulada durante o mês vigente
                                          pr_cdcritic => vr_cdcritic,          --> Código da crítica
                                          pr_dscritic => vr_dscritic);         --> Descrição da crítica

        IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

      ELSIF  rw_craprac.idtippro = 2 THEN -- Pós-fixada

        -- Buscar as taxas acumuladas da aplicação
        APLI0006.pc_taxa_acumul_aplic_pos(pr_cdcooper => pr_cdcooper,          --> Código da Cooperativa
                                          pr_txaplica => rw_craprac.txaplica,  --> Taxa da Aplicação
                                          pr_idtxfixa => rw_craprac.idtxfixa,  --> Taxa Fixa (1-SIM/2-NAO)
                                          pr_cddindex => rw_craprac.cddindex,  --> Código do Indexador
                                          pr_dtinical => rw_craprac.dtmvtolt,  --> Data Inicial Cálculo (Fixo na chamada)
                                          pr_dtfimcal => pr_dtmvtolt,          --> Data Final Cálculo (Fixo na chamada)
                                          pr_txacumul => pr_txacumul,          --> Taxa acumulada durante o período total da aplicação
                                          pr_txacumes => pr_txacumes,          --> Taxa acumulada durante o mês vigente
                                          pr_cdcritic => vr_cdcritic,          --> Código da crítica
                                          pr_dscritic => vr_dscritic);         --> Descrição da crítica

        IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

      END IF;

      -- Ajuste para valor aparecer correto no progress
      pr_txacumes := ROUND(pr_txacumes * 100,6);
      pr_txacumul := ROUND(pr_txacumul * 100,6);

      -- Se parâmetro pr_idlstdhs for igual 1, listar todos os históricos
      IF pr_idlstdhs = 1 THEN
        vr_lshistor := to_char(rw_craprac.cdhsraap) || ',' || to_char(rw_craprac.cdhsnrap) || ',' ||
                       to_char(rw_craprac.cdhsprap) || ',' || to_char(rw_craprac.cdhsrvap) || ',' ||
                       to_char(rw_craprac.cdhsrdap) || ',' || to_char(rw_craprac.cdhsirap) || ',' ||
                       to_char(rw_craprac.cdhsrgap) || ',' || to_char(rw_craprac.cdhsvtap);
      -- Se parâmetro pr_idlstdhs for igual 0, não listar históricos de reversão e rendimento
      ELSIF pr_idlstdhs = 0 THEN
        vr_lshistor := to_char(rw_craprac.cdhsraap) || ',' || to_char(rw_craprac.cdhsnrap) || ',' ||
                       to_char(rw_craprac.cdhsprap) || ',' || to_char(rw_craprac.cdhsirap) || ',' ||
                       to_char(rw_craprac.cdhsrgap) || ',' || to_char(rw_craprac.cdhsvtap);
      END IF;

      IMUT0001.pc_verifica_periodo_imune(pr_cdcooper  => pr_cdcooper   --> Codigo Cooperativa
                                        ,pr_nrdconta  => pr_nrdconta   --> Numero da Conta
                                        ,pr_flgimune  => vr_flgimune   --> Identificador se é imune
                                        ,pr_dtinicio  => vr_dtinicio   --> Data de inicio da imunidade
                                        ,pr_dttermin  => vr_dttermin   --> Data termino da imunidade
                                        ,pr_dsreturn  => vr_dsreturn   --> Descricao retorno(NOK/OK)
                                        ,pr_tab_erro  => vr_tab_erro); --> Tabela erros

      IF vr_dsreturn = 'NOK' THEN
        --Se tem erro na tabela
        IF vr_tab_erro.count > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao executar IMUT0001.pc_verifica_periodo_imune. Cooperativa: '||pr_cdcooper||' Conta: '||pr_nrdconta;
        END IF;
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;

      -- Verifica a quantidade de dias para saber o IR
      vr_qtdiasir := pr_dtmvtolt - rw_craprac.dtmvtolt;

      -- Consulta faixas de IR
      apli0001.pc_busca_faixa_ir_rdc(pr_cdcooper => pr_cdcooper);

      FOR i IN REVERSE apli0001.vr_faixa_ir_rdc.first .. apli0001.vr_faixa_ir_rdc.last LOOP

        IF vr_qtdiasir > apli0001.vr_faixa_ir_rdc(i).qtdiatab THEN
          vr_percirrf := apli0001.vr_faixa_ir_rdc(i).perirtab;
        END IF;

      END LOOP;

      -- Se não possuir IRRF
      IF (vr_percirrf IS NULL OR vr_percirrf = 0) THEN
        -- Atribuir primeira faixa de irrf
        vr_percirrf := apli0001.vr_faixa_ir_rdc(1).perirtab;
      END IF;

      -- Aliquota de IR
      pr_percirrf := vr_percirrf;

/*
  A ordenacao dos registros deve ser igual ao RDCPOS, conforme 'de-para':
     529 - PROV. RDCPOS - CDHSPRAP
     531 - REVERSAO PRV - CDHSRVAP
     532 - RENDIMENTO   - CDHSRDAP
     533 - IRRF         - CDHSIRAP
     534 - RESG.RDC     - CDHSRGAP
  Para nao termos problemas no registro com a B3 - apli0007.
*/
      -- Para cada registro de lançamento de aplicação de captação
      FOR rw_craplac IN cr_craplac(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nraplica => pr_nraplica
                                  ,pr_cdhsprap => rw_craprac.cdhsprap
                                  ,pr_cdhsrvap => rw_craprac.cdhsrvap
                                  ,pr_cdhsrdap => rw_craprac.cdhsrdap
                                  ,pr_cdhsirap => rw_craprac.cdhsirap
                                  ,pr_cdhsrgap => rw_craprac.cdhsrgap) LOOP

        -- Verificar se o histórico de lançamento está cadastrado na tabela craphis
        OPEN cr_craphis(pr_cdcooper => pr_cdcooper
                       ,pr_cdhistor => rw_craplac.cdhistor);
        FETCH cr_craphis INTO rw_craphis;

        IF cr_craphis%NOTFOUND THEN
          vr_cdcritic := 526; -- Histórico não encontrado
          CLOSE cr_craphis;
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_craphis;

        -- Verifica a quantidade de dias para saber o IR
        vr_qtdiasir := rw_craplac.dtmvtolt - rw_craprac.dtmvtolt;

        -- Consulta faixas de IR
        apli0001.pc_busca_faixa_ir_rdc(pr_cdcooper => pr_cdcooper);

        FOR i IN REVERSE apli0001.vr_faixa_ir_rdc.first .. apli0001.vr_faixa_ir_rdc.last LOOP

          IF vr_qtdiasir > apli0001.vr_faixa_ir_rdc(i).qtdiatab THEN
            vr_percirrf := apli0001.vr_faixa_ir_rdc(i).perirtab;
          END IF;

        END LOOP;

        -- Se não possuir IRRF
        IF (vr_percirrf IS NULL OR vr_percirrf = 0) THEN
          -- Atribuir primeira faixa de irrf
          vr_percirrf := apli0001.vr_faixa_ir_rdc(1).perirtab;
        END IF;

        IF rw_craplac.cdhistor = rw_craprac.cdhsrgap THEN    /* Resgate */
           vr_vlresgat := NVL(vr_vlresgat,0) + rw_craplac.vllanmto;
        ELSIF rw_craplac.cdhistor = rw_craprac.cdhsprap THEN /* Rendimento */
           vr_vlrendim := NVL(vr_vlrendim,0) + rw_craplac.vllanmto;
        ELSIF rw_craplac.cdhistor = rw_craprac.cdhsirap THEN /* IRRF */
           vr_vldoirrf := NVL(vr_vldoirrf,0) + rw_craplac.vllanmto;
        END IF;

        IF rw_craphis.indebcre = 'C' THEN     /* Crédito */
           vr_vlsldtot := NVL(vr_vlsldtot,0) + rw_craplac.vllanmto;
        ELSIF rw_craphis.indebcre = 'D' THEN  /* Débito  */
           vr_vlsldtot := NVL(vr_vlsldtot,0) - rw_craplac.vllanmto;
        ELSE
           vr_cdcritic := 0;
           vr_dscritic := 'Tipo de lancamento invalido';
           RAISE vr_exc_saida;
        END IF;

        -- Atribui a descrição do histórico e extrato para as variáveis
        vr_dshistor := rw_craphis.dshistor;
        vr_dsextrat := rw_craphis.dsextrat;

        IF vr_flgimune = TRUE THEN
          /* Se o cooperado ainda está imune, utiliza a data de movimento */
          IF vr_dttermin IS NULL THEN
            vr_dttermin := pr_dtmvtolt;
          END IF;

          -- Se o cooperado tinha imunidade tributária na data do lançamento do rendimento
          IF rw_craplac.cdhistor  = rw_craprac.cdhsrdap AND
             rw_craplac.dtmvtolt >= vr_dtinicio AND
             rw_craplac.dtmvtolt <= vr_dttermin THEN
            -- O carácter * é apresentado junto a descrição do histórico
            vr_dshistor := vr_dshistor || '*';
            vr_dsextrat := vr_dsextrat || '*';
          END IF;
        END IF;

        IF rw_craplac.cdhistor = rw_craprac.cdhsrdap THEN /* Rendimento */
           vr_txlancto := rw_craprac.txaplica;
        ELSIF rw_craplac.cdhistor = rw_craprac.cdhsirap THEN /* IRRF */
           vr_txlancto := vr_percirrf;
        ELSE /* Demais lançamentos */
           vr_txlancto := 0;
        END IF;

        IF gene0002.fn_existe_valor(vr_lshistor,rw_craplac.cdhistor,',') = 'S' OR
           (rw_craplac.cdhistor = rw_craprac.cdhsrvap AND /* Reversão */
           (rw_craplac.dtmvtolt - rw_craprac.dtmvtolt) < rw_craprac.qtdiacar) THEN

          -- Incrementa indice da PLTable de extrato
          vr_ind_extrato := vr_tab_extrato.count() + 1;

          vr_tab_extrato(vr_ind_extrato).dtmvtolt := rw_craplac.dtmvtolt;
          vr_tab_extrato(vr_ind_extrato).cdagenci := rw_craplac.cdagenci;
          vr_tab_extrato(vr_ind_extrato).cdhistor := rw_craphis.cdhistor;
          vr_tab_extrato(vr_ind_extrato).dshistor := vr_dshistor;
          vr_tab_extrato(vr_ind_extrato).dsextrat := vr_dsextrat;
          vr_tab_extrato(vr_ind_extrato).nrdocmto := rw_craplac.nrdocmto;
          vr_tab_extrato(vr_ind_extrato).indebcre := rw_craphis.indebcre;
          vr_tab_extrato(vr_ind_extrato).vllanmto := rw_craplac.vllanmto;
          vr_tab_extrato(vr_ind_extrato).vlsldtot := vr_vlsldtot;
          vr_tab_extrato(vr_ind_extrato).txlancto := vr_txlancto;
          vr_tab_extrato(vr_ind_extrato).nraplica := rw_craplac.nraplica;
        END IF;

      END LOOP;

      -- Alimenta parâmetros
      pr_vlresgat := vr_vlresgat;
      pr_vlrendim := vr_vlrendim;
      pr_vldoirrf := vr_vldoirrf;
      pr_tab_extrato := vr_tab_extrato;

      -- Gerar log
      IF pr_idgerlog = 1 THEN
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
        COMMIT;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Alimenta parametros com a crítica ocorrida
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        ROLLBACK;

        -- Verifica se deve gerar log
        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
          COMMIT;
        END IF;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado APLI0005.pc_busca_extrato_aplicacoes: ' || SQLERRM;
        ROLLBACK;

        -- Verifica se deve gerar log
        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
          COMMIT;
        END IF;
    END;
  END pc_busca_extrato_aplicacao;

  PROCEDURE pc_busca_extrato_aplicacao_car (pr_cdcooper IN craprac.cdcooper%TYPE,    -- Código da Cooperativa
                                            pr_cdoperad IN crapope.cdoperad%TYPE,    -- Código do Operador
                                            pr_nmdatela IN craptel.nmdatela%TYPE,    -- Nome da Tela
                                            pr_idorigem IN NUMBER,                   -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                            pr_nrdconta IN craprac.nrdconta%TYPE,    -- Número da Conta
                                            pr_idseqttl IN crapttl.idseqttl%TYPE,    -- Titular da Conta
                                            pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,    -- Data de Movimento
                                            pr_nraplica IN craprac.nraplica%TYPE,    -- Número da Aplicação
                                            pr_idlstdhs IN NUMBER,                   -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                            pr_idgerlog IN NUMBER,                   -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                            pr_vlresgat OUT NUMBER,                  -- Valor de resgate
                                            pr_vlrendim OUT NUMBER,                  -- Valor de rendimento
                                            pr_vldoirrf OUT NUMBER,                  -- Valor do IRRF
                                            pr_txacumul OUT NUMBER,                  -- Valor da taxa acumulada
                                            pr_txacumes OUT NUMBER,                  -- Valor da taxa acumulada mes
                                            pr_percirrf OUT NUMBER,                  -- Valor de aliquota de IR
                                            pr_clobxmlc OUT CLOB,                    -- XML com informações de LOG
                                            pr_cdcritic OUT crapcri.cdcritic%TYPE,   -- Código da crítica
                                            pr_dscritic OUT crapcri.dscritic%TYPE    -- Descrição da crítica
                                            ) IS
  BEGIN
   /* .............................................................................

     Programa: pc_busca_extrato_aplicacao_car
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Lucas Reinert
     Data    : Setembro/14.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de extratos das aplicações de captação.

     Observacao: -----

     Alteracoes: 09/03/2014 - Inclusão do parametro pr_percirrf. (Jean Michel)
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Temp Table
       vr_tab_extrato APLI0005.typ_tab_extrato;

      -- Variaveis de XML
      vr_xml_temp VARCHAR2(32767);

      -- Variáveis locais
      vr_vlresgat NUMBER;
      vr_vlrendim NUMBER;
      vr_vldoirrf NUMBER;
      vr_percirrf NUMBER;

    BEGIN

      -- Procedure para buscar informações da aplicação
      APLI0005.pc_busca_extrato_aplicacao(pr_cdcooper => pr_cdcooper,        -- Código da Cooperativa
                                          pr_cdoperad => pr_cdoperad,        -- Código do Operador
                                          pr_nmdatela => pr_nmdatela,        -- Nome da Tela
                                          pr_idorigem => pr_idorigem,        -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                          pr_nrdconta => pr_nrdconta,        -- Número da Conta
                                          pr_idseqttl => pr_idseqttl,        -- Titular da Conta
                                          pr_dtmvtolt => pr_dtmvtolt,        -- Data de Movimento
                                          pr_nraplica => pr_nraplica,        -- Número da Aplicação
                                          pr_idlstdhs => pr_idlstdhs,        -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                          pr_idgerlog => pr_idgerlog,        -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                          pr_tab_extrato => vr_tab_extrato,  -- PLTable com os dados de extrato
                                          pr_vlresgat => vr_vlresgat,        -- Valor de resgate
                                          pr_vlrendim => vr_vlrendim,        -- Valor de rendimento
                                          pr_vldoirrf => vr_vldoirrf,        -- Valor do IRRF
                                          pr_txacumul => pr_txacumul,        -- Valor da taxa acumulada
                                          pr_txacumes => pr_txacumes,        -- Valor da taxa acumulada mes
                                          pr_percirrf => vr_percirrf,        -- Aliquota de IR
                                          pr_cdcritic => vr_cdcritic,        -- Código da crítica
                                          pr_dscritic => vr_dscritic);       -- Descrição da crítica

      -- Se retornou alguma critica
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Alimenta parametros de saída
      pr_vlresgat := vr_vlresgat;
      pr_vlrendim := vr_vlrendim;
      pr_vldoirrf := vr_vldoirrf;
      pr_percirrf := vr_percirrf;

      IF vr_tab_extrato.count() > 0 THEN
        -- Criar documento XML
        dbms_lob.createtemporary(pr_clobxmlc, TRUE);
        dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);

        -- Insere o cabeçalho do XML
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><raiz>');

        -- Percorre todas as aplicações de captação da conta
        FOR vr_contador IN vr_tab_extrato.FIRST..vr_tab_extrato.LAST LOOP

          -- Montar XML com registros de aplicação
          gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<extrato>'
                                                    || '<dtmvtolt>' || to_char(vr_tab_extrato(vr_contador).dtmvtolt, 'dd/mm/yyyy') || '</dtmvtolt>'
                                                    || '<cdagenci>' || nvl(vr_tab_extrato(vr_contador).cdagenci,0) || '</cdagenci>'
                                                    || '<cdhistor>' || nvl(vr_tab_extrato(vr_contador).cdhistor,0) || '</cdhistor>'
                                                    || '<dshistor>' || nvl(vr_tab_extrato(vr_contador).dshistor,' ') || '</dshistor>'
                                                    || '<dsextrat>' || nvl(vr_tab_extrato(vr_contador).dsextrat,' ') || '</dsextrat>'
                                                    || '<nrdocmto>' || nvl(vr_tab_extrato(vr_contador).nrdocmto,0) || '</nrdocmto>'
                                                    || '<indebcre>' || nvl(vr_tab_extrato(vr_contador).indebcre,' ') || '</indebcre>'
                                                    || '<vllanmto>' || nvl(vr_tab_extrato(vr_contador).vllanmto,0) || '</vllanmto>'
                                                    || '<vlsldtot>' || nvl(vr_tab_extrato(vr_contador).vlsldtot,0) || '</vlsldtot>'
                                                    || '<txlancto>' || nvl(vr_tab_extrato(vr_contador).txlancto,0) || '</txlancto>'
                                                    || '<nraplica>' || nvl(vr_tab_extrato(vr_contador).nraplica,0) || '</nraplica>'
                                                    || '</extrato>');
        END LOOP;

        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</raiz>'
                               ,pr_fecha_xml      => TRUE);
      END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na busca de aplicacoes APLI0005.pc_busca_extrato_aplicacao_car: ' || SQLERRM;


    END;
  END pc_busca_extrato_aplicacao_car;

  PROCEDURE pc_busca_extrato_aplicacao_web (pr_cdcooper IN craprac.cdcooper%TYPE,    -- Código da Cooperativa
                                            pr_cdoperad IN crapope.cdoperad%TYPE,    -- Código do Operador
                                            pr_nmdatela IN craptel.nmdatela%TYPE,    -- Nome da Tela
                                            pr_idorigem IN NUMBER,                   -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                            pr_nrdconta IN craprac.nrdconta%TYPE,    -- Número da Conta
                                            pr_idseqttl IN crapttl.idseqttl%TYPE,    -- Titular da Conta
                                            pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,    -- Data de Movimento
                                            pr_nraplica IN craprac.nraplica%TYPE,    -- Número da Aplicação
                                            pr_idlstdhs IN NUMBER,                   -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                            pr_idgerlog IN NUMBER,                   -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                            pr_vlresgat OUT NUMBER,                  -- Valor de resgate
                                            pr_vlrendim OUT NUMBER,                  -- Valor de rendimento
                                            pr_vldoirrf OUT NUMBER,                  -- Valor do IRRF
                                            pr_txacumul OUT NUMBER,                  -- Taxa acumulada durante o período total da aplicação
                                            pr_txacumes OUT NUMBER,                  -- Taxa acumulada durante o mês vigente
                                            pr_percirrf OUT NUMBER,                  -- Valor de aliquota de IR
                                            pr_retxml   IN OUT NOCOPY XMLType,       -- Arquivo de retorno do XML
                                            pr_nmdcampo OUT VARCHAR2,                -- Nome do campo com erro
                                            pr_des_erro OUT VARCHAR2,                -- Erros do processo
                                            pr_cdcritic OUT crapcri.cdcritic%TYPE,   -- Código da crítica
                                            pr_dscritic OUT crapcri.dscritic%TYPE    -- Descrição da crítica
                                            ) IS
  BEGIN
   /* .............................................................................

     Programa: pc_busca_extrato_aplicacao_web
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Lucas Reinert
     Data    : Setembro/14.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de extratos das aplicações de captação.

     Observacao: -----

     Alteracoes: 09/03/2014 - Inclusão do parametro pr_percirrf. (Jean Michel)
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Temp Table
       vr_tab_extrato APLI0005.typ_tab_extrato;

      -- Variáveis locais
      vr_contador PLS_INTEGER := 0;
      vr_auxconta PLS_INTEGER := 0;
      vr_vlresgat NUMBER;
      vr_vlrendim NUMBER;
      vr_vldoirrf NUMBER;
      vr_txacumul NUMBER;
      vr_txacumes NUMBER;
      vr_percirrf NUMBER; -- Valor de aliquota de IR


    BEGIN

      -- Procedure para buscar informações da aplicação
      APLI0005.pc_busca_extrato_aplicacao(pr_cdcooper => pr_cdcooper,        -- Código da Cooperativa
                                          pr_cdoperad => pr_cdoperad,        -- Código do Operador
                                          pr_nmdatela => pr_nmdatela,        -- Nome da Tela
                                          pr_idorigem => pr_idorigem,        -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                          pr_nrdconta => pr_nrdconta,        -- Número da Conta
                                          pr_idseqttl => pr_idseqttl,        -- Titular da Conta
                                          pr_dtmvtolt => pr_dtmvtolt,        -- Data de Movimento
                                          pr_nraplica => pr_nraplica,        -- Número da Aplicação
                                          pr_idlstdhs => pr_idlstdhs,        -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                          pr_idgerlog => pr_idgerlog,        -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                          pr_tab_extrato => vr_tab_extrato,  -- PLTable com os dados de extrato
                                          pr_vlresgat => vr_vlresgat,        -- Valor de resgate
                                          pr_vlrendim => vr_vlrendim,        -- Valor de rendimento
                                          pr_vldoirrf => vr_vldoirrf,        -- Valor do IRRF
                                          pr_txacumul => vr_txacumul,        -- Taxa acumulada durante o período total da aplicação
                                          pr_txacumes => vr_txacumes,        -- Taxa acumulada durante o mês vigente
                                          pr_percirrf => vr_percirrf,         -- Aliquota de IR
                                          pr_cdcritic => vr_cdcritic,        -- Código da crítica
                                          pr_dscritic => vr_dscritic);       -- Descrição da crítica

      -- Se retornou alguma critica
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Alimenta parametros de saída
      pr_vlresgat := vr_vlresgat;
      pr_vlrendim := vr_vlrendim;
      pr_vldoirrf := vr_vldoirrf;
      pr_percirrf := vr_percirrf;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

       -- Percorre todas as aplicações de captação da conta
      FOR vr_contador IN vr_tab_extrato.FIRST..vr_tab_extrato.LAST LOOP
        -- Insere as tags dos campos da PLTABLE de aplicações
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtmvtolt', pr_tag_cont => TO_CHAR(vr_tab_extrato(vr_contador).dtmvtolt), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdagenci', pr_tag_cont => TO_CHAR(vr_tab_extrato(vr_contador).cdagenci), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdhistor', pr_tag_cont => TO_CHAR(vr_tab_extrato(vr_contador).cdhistor), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dshistor', pr_tag_cont => TO_CHAR(vr_tab_extrato(vr_contador).dshistor), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dsextrat', pr_tag_cont => TO_CHAR(vr_tab_extrato(vr_contador).dsextrat), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrdocmto', pr_tag_cont => TO_CHAR(vr_tab_extrato(vr_contador).nrdocmto), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'indebcre', pr_tag_cont => TO_CHAR(vr_tab_extrato(vr_contador).indebcre), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vllanmto', pr_tag_cont => TO_CHAR(vr_tab_extrato(vr_contador).vllanmto), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vlsldtot', pr_tag_cont => TO_CHAR(vr_tab_extrato(vr_contador).vlsldtot), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'txlancto', pr_tag_cont => TO_CHAR(vr_tab_extrato(vr_contador).txlancto), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nraplica', pr_tag_cont => TO_CHAR(vr_tab_extrato(vr_contador).nraplica), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'percirrf', pr_tag_cont => TO_CHAR(vr_percirrf), pr_des_erro => vr_dscritic);

        -- Incrementa contador p/ posicao no XML
        vr_auxconta := vr_auxconta + 1;
      END LOOP;

      -- Insere as tags dos campos da PLTABLE de aplicações
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'percirrf', pr_tag_cont => TO_CHAR(vr_percirrf), pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na APLI0005.pc_busca_extrato_aplicacao_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_busca_extrato_aplicacao_web;

  PROCEDURE pc_consulta_resgates(pr_cdcooper IN  craprac.cdcooper%TYPE     -- Código da Cooperativa
                                ,pr_nrdconta IN  craprac.nrdconta%TYPE     -- Número da Conta
                                ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE     -- Data de Movimento
                                ,pr_nraplica IN  craprac.nraplica%TYPE     -- Número da Aplicação
                                ,pr_flgcance IN  INTEGER                   -- Indicador se é consulta de Cancelamento ou Proximo
                                ,pr_tab_resg OUT apli0002.typ_tab_resgate_aplicacao  -- Tabela com informacoes sobre resgates
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE     -- Codigo da critica
                                ,pr_dscritic OUT crapcri.dscritic%TYPE) IS -- Descricao da critica
  BEGIN
   /* .............................................................................

     Programa: pc_consulta_resgates
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Outubro/14.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a consulta de resgates de aplicacoes

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_tab_resgates apli0002.typ_tab_resgate_aplicacao; -- Tabela com dados de resgates

      vr_codchave INTEGER := 0;

      -- Buscar registros de resgate
      CURSOR cr_craprga(pr_cdcooper IN craprga.cdcooper%TYPE
                       ,pr_nrdconta IN craprga.nrdconta%TYPE
                       ,pr_nraplica IN craprga.nraplica%TYPE
                       ,pr_dtmvtolt IN craprga.dtmvtolt%TYPE
                       ,pr_flgcance IN INTEGER) IS

        SELECT
          rga.nraplica
         ,rga.dtresgat
         ,rga.nrseqrgt
         ,rga.idtiprgt
         ,DECODE(rga.idresgat,0,'NR',1,'RG',3,'ES','CN') AS idresgat
         ,rga.cdoperad
         ,ope.nmoperad
         ,rga.hrtransa
         ,rga.vlresgat
         ,cpc.cdprodut
         ,cpc.nmprodut
        FROM
          craprga rga
         ,crapope ope
         ,craprac rac
         ,crapcpc cpc
        WHERE
              rga.cdcooper  = pr_cdcooper
          AND rga.nrdconta  = pr_nrdconta
          AND (rga.nraplica  = pr_nraplica
           OR pr_nraplica = 0)
          AND ope.cdcooper  = rga.cdcooper
          AND upper(ope.cdoperad)  = upper(rga.cdoperad)
          AND rac.cdcooper = rga.cdcooper
          AND rac.nraplica = rga.nraplica
          AND rac.nrdconta = rga.nrdconta
          AND cpc.cdprodut = rac.cdprodut
          AND (rga.idresgat = 0
           OR (rga.idresgat = 1
          AND rga.dtresgat  = pr_dtmvtolt
          AND rga.dtmvtolt = pr_dtmvtolt
           AND pr_flgcance = 1));

      rw_craprga cr_craprga%ROWTYPE;

      CURSOR cr_craplrg(pr_cdcooper IN craprga.cdcooper%TYPE
                       ,pr_nrdconta IN craprga.nrdconta%TYPE
                       ,pr_nraplica IN craprga.nraplica%TYPE
                       ,pr_dtmvtolt IN craprga.dtmvtolt%TYPE) IS
        SELECT
          DECODE(lrg.tpaplica,3,'RDCA',4,'P.P.',5,'RDCA60','TP ' || lrg.tpaplica) AS tpaplica
         ,DECODE(lrg.inresgat,0,'NR',1,'RG',3,'ES','CN') AS inresgat
         ,ope.nmoperad
         ,lrg.dtresgat
         ,lrg.nraplica
         ,lrg.vllanmto
         ,lrg.nrdocmto
         ,lrg.hrtransa
        FROM
          craplrg lrg
         ,crapope ope
        WHERE
          lrg.cdcooper = pr_cdcooper
          AND lrg.nrdconta = pr_nrdconta
          AND (lrg.nraplica = pr_nraplica
           OR pr_nraplica = 0)
          AND lrg.inresgat IN(0,2)
          AND lrg.cdcooper = ope.cdcooper
          AND upper(lrg.cdoperad) = upper(ope.cdoperad)
        ORDER BY
          lrg.nrdocmto;

      rw_craplrg cr_craplrg%ROWTYPE;

    BEGIN

      -- Consulta registros de resgate novos
      OPEN cr_craprga(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nraplica => pr_nraplica
                     ,pr_dtmvtolt => pr_dtmvtolt
                     ,pr_flgcance => pr_flgcance);

      LOOP

        FETCH cr_craprga INTO rw_craprga;

        -- Sai quando chegar ao fim dos registros
        EXIT WHEN cr_craprga%NOTFOUND;

        -- Insere registros de resgate na TT
        vr_tab_resgates(vr_codchave).dtresgat := rw_craprga.dtresgat;
        vr_tab_resgates(vr_codchave).nrdocmto := rw_craprga.nrseqrgt;
        vr_tab_resgates(vr_codchave).tpresgat := rw_craprga.cdprodut || '-' || rw_craprga.nmprodut;
        vr_tab_resgates(vr_codchave).dsresgat := rw_craprga.idresgat;
        vr_tab_resgates(vr_codchave).nmoperad := rw_craprga.nmoperad;
        vr_tab_resgates(vr_codchave).hrtransa := rw_craprga.hrtransa;
        vr_tab_resgates(vr_codchave).vllanmto := rw_craprga.vlresgat;
        vr_tab_resgates(vr_codchave).nraplica := rw_craprga.nraplica;

        -- Incrementa chave da TT
        vr_codchave := vr_codchave + 1;

      END LOOP;

      -- Consulta registros de resgate novos
      OPEN cr_craplrg(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nraplica => pr_nraplica
                     ,pr_dtmvtolt => pr_dtmvtolt);

      LOOP

        FETCH cr_craplrg INTO rw_craplrg;

        -- Sai quando chegar ao fim dos registros
        EXIT WHEN cr_craplrg%NOTFOUND;

        -- Insere registros de resgate na TT
        vr_tab_resgates(vr_codchave).dtresgat := rw_craplrg.dtresgat;
        vr_tab_resgates(vr_codchave).nrdocmto := rw_craplrg.nrdocmto;
        vr_tab_resgates(vr_codchave).tpresgat := rw_craplrg.tpaplica;
        vr_tab_resgates(vr_codchave).dsresgat := rw_craplrg.inresgat;
        vr_tab_resgates(vr_codchave).nmoperad := rw_craplrg.nmoperad;
        vr_tab_resgates(vr_codchave).hrtransa := rw_craplrg.hrtransa;
        vr_tab_resgates(vr_codchave).vllanmto := rw_craplrg.vllanmto;
        vr_tab_resgates(vr_codchave).nraplica := rw_craplrg.nraplica;

        -- Incrementa chave da TT
        vr_codchave := vr_codchave + 1;

      END LOOP;

      -- Insere dados na variavel de retorno da procedure
      pr_tab_resg := vr_tab_resgates;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Alimenta parametros com a crítica ocorrida
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        -- Alimenta parametros com a crítica ocorrida
        pr_cdcritic := 0;
        pr_dscritic := 'Erro nao tratado na procedure APLI0005.pc_consulta_resgates. Erro: ' || SQLERRM;

    END;

  END pc_consulta_resgates;

  PROCEDURE pc_consulta_resgates_car(pr_cdcooper  IN  craprac.cdcooper%TYPE -- Código da Cooperativa
                                    ,pr_cdagenci  IN crapage.cdagenci%TYPE  -- Codigo de agencia
                                    ,pr_nrdcaixa  IN INTEGER                -- Numero de caixa
                                    ,pr_cdoperad  IN VARCHAR2               -- Codigo do cooperado
                                    ,pr_nmdatela  IN VARCHAR2               -- Nome da tela
                                    ,pr_idorigem  IN INTEGER                -- Origem da transacao
                                    ,pr_idseqttl  IN crapttl.idseqttl%TYPE  -- Sequencial do titular
                                    ,pr_nrdconta  IN craprac.nrdconta%TYPE  -- Número da Conta
                                    ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE  -- Data de Movimento
                                    ,pr_nraplica  IN craprac.nraplica%TYPE  -- Numero da Aplicacao
                                    ,pr_flgcance  IN INTEGER                --> Indicador de opcao (Cancelamento/Proximo)
                                    ,pr_flgerlog  IN INTEGER                --> Gravar log
                                    ,pr_clobxmlc OUT CLOB                   -- XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER            -- Código da crítica
                                    ,pr_dscritic OUT VARCHAR2) IS           -- Descrição da crítica

    BEGIN

    /* .............................................................................

     Programa: pc_consulta_resgates_car
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Outubro/14.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de resgate de aplicacao para o Ayllos caractere.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Temp Table
      vr_tab_resg_nov apli0002.typ_tab_resgate_aplicacao; -- Tabela com dados de resgates de novas aplicacoes
      vr_tab_resg_ant apli0002.typ_tab_resgate_aplicacao; -- Tabela com dados de resgates de antigas aplicacoes

      -- Variaveis de XML
      vr_xml_temp VARCHAR2(32767);


    BEGIN

      -- Procedure para buscar informações de resgates
      APLI0005.pc_consulta_resgates(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_dtmvtolt => pr_dtmvtolt
                                   ,pr_nraplica => pr_nraplica
                                   ,pr_flgcance => pr_flgcance
                                   ,pr_tab_resg => vr_tab_resg_nov
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);

      -- Se retornou alguma critica
      IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Criar documento XML
      dbms_lob.createtemporary(pr_clobxmlc, TRUE);
      dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);

      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><raiz>');

      IF vr_tab_resg_nov.count() > 0 THEN
        -- Percorre todas os resgates de aplicacoes
        FOR vr_contador IN vr_tab_resg_nov.FIRST..vr_tab_resg_nov.LAST LOOP
          -- Montar XML com registros de resgate
          gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<resgate>'
                                                    ||  '<nraplica>' || NVL(vr_tab_resg_nov(vr_contador).nraplica,0) || '</nraplica>'
                                                    ||  '<dtresgat>' || TO_CHAR(vr_tab_resg_nov(vr_contador).dtresgat,'dd/mm/RRRR') || '</dtresgat>'
                                                    ||  '<nrdocmto>' || NVL(vr_tab_resg_nov(vr_contador).nrdocmto,0) || '</nrdocmto>'
                                                    ||  '<tpresgat>' || NVL(vr_tab_resg_nov(vr_contador).tpresgat,0) || '</tpresgat>'
                                                    ||  '<dsresgat>' || NVL(vr_tab_resg_nov(vr_contador).dsresgat,0) || '</dsresgat>'
                                                    ||  '<nmoperad>' || NVL(vr_tab_resg_nov(vr_contador).nmoperad,0) || '</nmoperad>'
                                                    ||  '<hrtransa>' || TO_CHAR(TO_DATE(vr_tab_resg_nov(vr_contador).hrtransa,'sssss'),'hh24:mi:ss') || '</hrtransa>'
                                                    ||  '<vllanmto>' || NVL(vr_tab_resg_nov(vr_contador).vllanmto,0) || '</vllanmto>'
                                                    || '</resgate>');
        END LOOP;
      END IF;

      IF vr_tab_resg_ant.count() > 0 THEN
        -- Percorre todas os resgates de aplicacoes
        FOR vr_contador IN vr_tab_resg_ant.FIRST..vr_tab_resg_ant.LAST LOOP
          -- Montar XML com registros de resgate
          gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<resgate>'
                                                    ||  '<nraplica>' || NVL(vr_tab_resg_ant(vr_contador).nraplica,0) || '</nraplica>'
                                                    ||  '<dtresgat>' || TO_CHAR(vr_tab_resg_ant(vr_contador).dtresgat,'dd/mm/RRRR') || '</dtresgat>'
                                                    ||  '<nrdocmto>' || NVL(vr_tab_resg_ant(vr_contador).nrdocmto,0) || '</nrdocmto>'
                                                    ||  '<tpresgat>' || NVL(vr_tab_resg_ant(vr_contador).tpresgat,0) || '</tpresgat>'
                                                    ||  '<dsresgat>' || NVL(vr_tab_resg_ant(vr_contador).dsresgat,0) || '</dsresgat>'
                                                    ||  '<nmoperad>' || NVL(vr_tab_resg_ant(vr_contador).nmoperad,0) || '</nmoperad>'
                                                    ||  '<hrtransa>' || TO_CHAR(TO_DATE(vr_tab_resg_ant(vr_contador).hrtransa,'sssss'),'hh24:mi:ss') || '</hrtransa>'
                                                    ||  '<vllanmto>' || NVL(vr_tab_resg_ant(vr_contador).vllanmto,0) || '</vllanmto>'
                                                    || '</resgate>');
        END LOOP;
      END IF;

      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</raiz>'
                             ,pr_fecha_xml      => TRUE);

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na consulta de resgates APLI0005.pc_consulta_resgates_car: ' || SQLERRM;

    END;
  END pc_consulta_resgates_car;

  PROCEDURE pc_consulta_resgates_web(pr_idseqttl IN crapttl.idseqttl%TYPE -- Sequencial do titular
                                    ,pr_nrdconta IN craprac.nrdconta%TYPE -- Número da Conta
                                    ,pr_dtmvtolt IN VARCHAR2              -- Data de Movimento
                                    ,pr_nraplica IN craprac.nraplica%TYPE -- Numero da Aplicacao
                                    ,pr_flgcance IN NUMBER                -- Indicador de opcao (Cancelamento/Proximo)
                                    ,pr_flgerlog IN NUMBER                -- Gravar log
                                    ,pr_xmllog   IN VARCHAR2              -- XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          -- Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             -- Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    -- Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             -- Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         -- Descrição da crítica
    BEGIN

    /* .............................................................................

     Programa: pc_consulta_resgates_web
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Lucas Reinert
     Data    : Outubro/14.                    Ultima atualizacao: 13/02/2015

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de resgate de aplicacao para o ambiente web.

     Observacao: -----

     Alteracoes: 13/02/2015 - Correções de parâmetros e chamadas de procedures
                              (Jean Michel).
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Temp Table
      vr_tab_resg_nov apli0002.typ_tab_resgate_aplicacao; -- Tabela com dados de resgates de novas aplicacoes

      -- Variáveis locais
      vr_contador PLS_INTEGER := 0;
      vr_auxconta PLS_INTEGER := 0;
      -- Erro em chamadas da pc_gera_erro

      -- Variaveis locais
      vr_dtmvtolt crapdat.dtmvtolt%TYPE;

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN

      vr_dtmvtolt := TO_DATE(pr_dtmvtolt,'dd/mm/RRRR');

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
        RAISE vr_exc_saida;
      END IF;

      -- Procedure para buscar informações de resgates
      APLI0005.pc_consulta_resgates(pr_cdcooper => vr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_dtmvtolt => vr_dtmvtolt
                                   ,pr_nraplica => pr_nraplica
                                   ,pr_flgcance => pr_flgcance
                                   ,pr_tab_resg => vr_tab_resg_nov
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);

      -- Se retornou alguma critica
      IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

       IF vr_tab_resg_nov.count() > 0 THEN
        -- Percorre todas as aplicações de captação da conta
        FOR vr_contador IN vr_tab_resg_nov.FIRST..vr_tab_resg_nov.LAST LOOP
          -- Insere as tags dos campos da PLTABLE de aplicações
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtresgat', pr_tag_cont => TO_CHAR(vr_tab_resg_nov(vr_contador).dtresgat,'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrdocmto', pr_tag_cont => TO_CHAR(NVL(vr_tab_resg_nov(vr_contador).nrdocmto,0)), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'tpresgat', pr_tag_cont => TO_CHAR(NVL(vr_tab_resg_nov(vr_contador).tpresgat,0)), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dsresgat', pr_tag_cont => TO_CHAR(NVL(vr_tab_resg_nov(vr_contador).dsresgat,0)), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmoperad', pr_tag_cont => TO_CHAR(NVL(vr_tab_resg_nov(vr_contador).nmoperad,0)), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'hrtransa', pr_tag_cont => TO_CHAR(TO_DATE(vr_tab_resg_nov(vr_contador).hrtransa,'sssss'),'hh24:mi:ss'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vllanmto', pr_tag_cont => TO_CHAR(NVL(vr_tab_resg_nov(vr_contador).vllanmto,0)), pr_des_erro => vr_dscritic);
          -- Incrementa contador p/ posicao no XML
          vr_auxconta := vr_auxconta + 1;
        END LOOP;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na APLI0005.pc_consulta_resgates_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    END;
  END pc_consulta_resgates_web;

  PROCEDURE pc_cancela_resgate(pr_cdcooper  IN crapcop.cdcooper%TYPE     -- Codigo da Cooperativa
                              ,pr_cdagenci  IN crapage.cdagenci%TYPE     -- Codigo do PA
                              ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE     -- Numero do caixa
                              ,pr_cdoperad  IN crapope.cdoperad%TYPE     -- Codigo do operador
                              ,pr_nmdatela  IN craptel.nmdatela%TYPE     -- Nome da tela
                              ,pr_idorigem  IN INTEGER                   -- Identificador de sistema de origem
                              ,pr_nrdconta  IN crapass.nrdconta%TYPE     -- Numero da conta
                              ,pr_idseqttl  IN crapttl.idseqttl%TYPE     -- Sequencia do titular
                              ,pr_nraplica  IN craprac.nraplica%TYPE     -- Numero da aplicacao
                              ,pr_nrdocmto  IN INTEGER                   -- Numero do documento
                              ,pr_dtresgat  IN crapdat.dtmvtolt%TYPE     -- Data de resgate
                              ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE     -- Data de movimento atual
                              ,pr_flgerlog  IN INTEGER                   -- Flag para gerar log
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE     -- Codigo da critica
                              ,pr_dscritic OUT crapcri.dscritic%TYPE) IS -- Descricao da critica

    BEGIN

    /* .............................................................................

     Programa: pc_cancela_resgate
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Outubro/14.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente ao cancelamento de resgates de aplicacaoes.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Erro em chamadas da pc_gera_erro
      vr_des_reto VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;
      vr_tab_sald EXTR0001.typ_tab_saldos;

      -- Variaveis locais
      vr_lshistor VARCHAR2(100) := ''; -- Lista de historicos do produto
      vr_idtiprgt VARCHAR2(7) := '';
      vr_nrdrowid ROWID;
      vr_dstransa VARCHAR(200) := 'Cancelamento de resgate';
      -- Cursores

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Leitura de registros de resgates de aplicacao
      CURSOR cr_craprga(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_nrdconta craprga.nrdconta%TYPE
                       ,pr_nraplica craprga.nraplica%TYPE
                       ,pr_dtmvtolt craprga.dtmvtolt%TYPE
                       ,pr_nrdocmto craprga.nrseqrgt%TYPE) IS

        SELECT
          rga.cdcooper
         ,rga.nrdconta
         ,rga.nraplica
         ,rga.nrseqrgt
         ,rga.dtresgat
         ,rga.dtmvtolt
         ,rga.vlresgat
         ,rga.idtiprgt
         ,rga.cdoperad
         ,rga.hrtransa
         ,rga.idresgat
         ,rga.idrgtcti
         ,rga.rowid
        FROM
          craprga rga
        WHERE
              rga.cdcooper = pr_cdcooper
          AND rga.nrdconta = pr_nrdconta
          AND rga.nraplica = pr_nraplica
          AND rga.nrseqrgt = pr_nrdocmto
          AND (rga.idresgat = 0
           OR (rga.idresgat = 1
          AND rga.dtresgat = pr_dtmvtolt
          AND rga.dtmvtolt = pr_dtmvtolt));

      rw_craprga cr_craprga%ROWTYPE;

      -- Leitura de registros de resgates de aplicacao
      CURSOR cr_crapcpc(pr_cdprodut crapcpc.cdprodut%TYPE) IS

        SELECT
          cpc.cdprodut
         ,cpc.nmprodut
         ,cpc.cdhsvrcc
         ,cpc.cdhsrvap
         ,cpc.cdhsrdap
         ,cpc.cdhsirap
         ,cpc.cdhsrgap
         ,cpc.cdhsprap
        FROM
          crapcpc cpc
        WHERE
          cpc.cdprodut = pr_cdprodut;

      rw_crapcpc cr_crapcpc%ROWTYPE;

      -- Consulta de cooperado
      CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                       ,pr_nrdconta crapass.nrdconta%TYPE) IS

        SELECT
          ass.cdcooper
         ,ass.nrdconta
         ,ass.vllimcre
        FROM
          crapass ass
        WHERE
              ass.cdcooper = pr_cdcooper  -- Codigo da cooperativa
          AND ass.nrdconta = pr_nrdconta; -- Numero da conta

      rw_crapass cr_crapass%ROWTYPE;

      -- Consulta de lotes
      CURSOR cr_craplot(pr_cdcooper craplot.cdcooper%TYPE
                       ,pr_dtresgat craplot.dtmvtolt%TYPE
                       ,pr_cdagenci craplot.cdagenci%TYPE
                       ,pr_cdbccxlt craplot.cdbccxlt%TYPE
                       ,pr_nrdolote craplot.nrdolote%TYPE) IS

        SELECT
          lot.qtcompln
         ,lot.qtinfoln
         ,lot.vlcompcr
         ,lot.vlinfocr
         ,lot.vlcompdb
         ,lot.vlinfodb
         ,lot.rowid
        FROM
          craplot lot
        WHERE
              lot.cdcooper = pr_cdcooper
          AND lot.dtmvtolt = pr_dtresgat
          AND lot.cdagenci = pr_cdagenci
          AND lot.cdbccxlt = pr_cdbccxlt
          AND lot.nrdolote = pr_nrdolote;

      rw_craplot cr_craplot%ROWTYPE;

      -- Consulta de lancamentos da conta investimento
      CURSOR cr_craplci(pr_cdcooper craplci.cdcooper%TYPE
                       ,pr_dtmvtolt craplci.dtmvtolt%TYPE
                       ,pr_cdagenci craplci.cdagenci%TYPE
                       ,pr_cdbccxlt craplci.cdbccxlt%TYPE
                       ,pr_nrdolote craplci.nrdolote%TYPE
                       ,pr_nrdconta craplci.vllanmto%TYPE
                       ,pr_nraplica craplci.nraplica%TYPE
                       ,pr_cdhistor craplci.cdhistor%TYPE
                       ,pr_vllanmto craplci.vllanmto%TYPE) IS

        SELECT
          lci.rowid
        FROM
          craplci lci
        WHERE
              lci.cdcooper = pr_cdcooper
          AND lci.dtmvtolt = pr_dtmvtolt
          AND lci.cdagenci = pr_cdagenci
          AND lci.cdbccxlt = pr_cdbccxlt
          AND lci.nrdolote = pr_nrdolote
          AND lci.nrdconta = pr_nrdconta
          AND lci.nraplica = pr_nraplica
          AND lci.cdhistor = pr_cdhistor
          AND lci.vllanmto = pr_vllanmto
        ORDER BY
          lci.nrseqdig DESC;

      rw_craplci cr_craplci%ROWTYPE;

      -- Consulta de lancamentos
      CURSOR cr_craplcm(pr_cdcooper craplcm.cdcooper%TYPE
                       ,pr_dtmvtolt craplcm.dtmvtolt%TYPE
                       ,pr_cdagenci craplcm.cdagenci%TYPE
                       ,pr_cdbccxlt craplcm.cdbccxlt%TYPE
                       ,pr_nrdolote craplcm.nrdolote%TYPE
                       ,pr_nrdctabb craplcm.nrdctabb%TYPE
                       ,pr_nraplica craplcm.nraplica%TYPE
                       ,pr_cdhistor craplcm.cdhistor%TYPE
                       ,pr_vllanmto craplcm.vllanmto%TYPE) IS

        SELECT
          lcm.cdcooper
         ,lcm.dtmvtolt
         ,lcm.cdagenci
         ,lcm.cdbccxlt
         ,lcm.nrdolote
         ,lcm.nrdctabb
         ,lcm.nraplica
         ,lcm.cdhistor
         ,lcm.vllanmto
         ,lcm.rowid
        FROM
          craplcm lcm
        WHERE
              lcm.cdcooper = pr_cdcooper
          AND lcm.dtmvtolt = pr_dtmvtolt
          AND lcm.cdagenci = pr_cdagenci
          AND lcm.cdbccxlt = pr_cdbccxlt
          AND lcm.nrdolote = pr_nrdolote
          AND lcm.nrdctabb = pr_nrdctabb
          AND lcm.nraplica = pr_nraplica
          AND lcm.cdhistor = pr_cdhistor
          AND lcm.vllanmto = pr_vllanmto
        ORDER BY
          lcm.nrseqdig DESC;

      rw_craplcm cr_craplcm%ROWTYPE;

      -- Consulta lancamento de novas aplicacoes
      CURSOR cr_craplac(pr_cdcooper craplac.cdcooper%TYPE
                       ,pr_dtmvtolt craplac.dtmvtolt%TYPE
                       ,pr_cdagenci craplac.cdagenci%TYPE
                       ,pr_cdbccxlt craplac.cdbccxlt%TYPE
                       ,pr_nrdolote craplac.nrdolote%TYPE
                       ,pr_nrdconta craplac.nrdconta%TYPE
                       ,pr_nraplica craplac.nraplica%TYPE
                       ,pr_cdhistor VARCHAR2
                       ,pr_nrseqrgt craplac.nrseqrgt%TYPE) IS

        SELECT
          lac.cdcooper
         ,lac.dtmvtolt
         ,lac.cdagenci
         ,lac.cdbccxlt
         ,lac.nrdolote
         ,lac.nrdconta
         ,lac.nraplica
         ,lac.cdhistor
         ,lac.nrseqrgt
         ,lac.vllanmto
         ,lac.vlbasren
         ,lac.rowid
        FROM
          craplac lac
        WHERE
              lac.cdcooper  = pr_cdcooper
          AND lac.dtmvtolt  = pr_dtmvtolt
          AND lac.cdagenci  = pr_cdagenci
          AND lac.cdbccxlt  = pr_cdbccxlt
          AND lac.nrdolote  = pr_nrdolote
          AND lac.nrdconta  = pr_nrdconta
          AND lac.nraplica  = pr_nraplica
          --AND lac.cdhistor IN (pr_cdhistor)
          AND gene0002.fn_existe_valor(pr_cdhistor,lac.cdhistor,',') = 'S'
          AND lac.nrseqrgt  = pr_nrseqrgt;

      rw_craplac cr_craplac%ROWTYPE;

      -- Consulta de novas aplicacoes
      CURSOR cr_craprac(pr_cdcooper craprac.cdcooper%TYPE
                       ,pr_nrdconta craprac.nrdconta%TYPE
                       ,pr_nraplica craprac.nraplica%TYPE) IS

        SELECT
          rac.cdcooper
         ,rac.nrdconta
         ,rac.nraplica
         ,rac.vlsldatl
         ,rac.vlbasapl
         ,rac.dtsldant
         ,rac.vlsldant
         ,rac.vlbasant
         ,rac.cdprodut
         ,rac.rowid
        FROM
          craprac rac
        WHERE
              rac.cdcooper = pr_cdcooper
          AND rac.nrdconta = pr_nrdconta
          AND rac.nraplica = pr_nraplica;

      rw_craprac cr_craprac%ROWTYPE;

      -- Consulta de historicos
      CURSOR cr_craphis(pr_cdhistor craphis.cdhistor%TYPE) IS

        SELECT
          his.indebcre
        FROM
          craphis his
        WHERE
          cdhistor = pr_cdhistor;

      rw_craphis cr_craphis%ROWTYPE;

      -- Contador de lancamentos de aplicacoes
      CURSOR cr_contlac(pr_cdcooper craplac.cdcooper%TYPE
                       ,pr_dtmvtolt craplac.dtmvtolt%TYPE
                       ,pr_cdagenci craplac.cdagenci%TYPE
                       ,pr_cdbccxlt craplac.cdbccxlt%TYPE
                       ,pr_nrdolote craplac.nrdolote%TYPE
                       ,pr_nrdconta craplac.nrdconta%TYPE
                       ,pr_nraplica craplac.nraplica%TYPE
                       ,pr_cdhistor craplac.cdhistor%TYPE) IS

        SELECT
          COUNT(pr_cdcooper) AS contador
        FROM
          craplac lac
        WHERE
              lac.cdcooper = pr_cdcooper
          AND lac.dtmvtolt = pr_dtresgat
          AND lac.cdagenci = pr_cdagenci
          AND lac.cdbccxlt = pr_cdbccxlt
          AND lac.nrdolote = pr_nrdolote
          AND lac.nrdconta = pr_nrdconta
          AND lac.nraplica = pr_nraplica
          AND lac.cdhistor = pr_cdhistor;

     rw_contlac  cr_contlac%ROWTYPE;

    BEGIN

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;

      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Consulta de cooperado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper   -- Codigo da cooperativa
                     ,pr_nrdconta => pr_nrdconta); -- Numero da conta

      FETCH cr_crapass INTO rw_crapass;

      -- Verifica se encontrou registro de cooperado
      IF cr_crapass%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_crapass;

        vr_cdcritic := 9;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Fecha cursor
        CLOSE cr_crapass;
      END IF;

      -- Consulta de resgate de aplicacao
      OPEN cr_craprga(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nraplica => pr_nraplica
                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                     ,pr_nrdocmto => pr_nrdocmto);

      FETCH cr_craprga INTO rw_craprga;

      -- Verifica se existe registro de resgate
      IF cr_craprga%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_craprga;

        vr_cdcritic := 0;
        vr_dscritic := 'Registro de resgate de aplicacao nao encontrado. Conta: ' || pr_nrdconta || ', Aplic: ' || pr_nraplica;
        RAISE vr_exc_saida;
      ELSE
        -- Fecha cursor
        CLOSE cr_craprga;

        BEGIN

          UPDATE
            craprga
          SET
            craprga.idresgat = 2
           ,craprga.cdoperad = pr_cdoperad
           ,craprga.hrtransa = TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
          WHERE
            craprga.rowid = rw_craprga.rowid;

        EXCEPTION

          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar registro de cancelamento de aplicacao. Erro: ' || SQLERRM;
            RAISE vr_exc_saida;

        END;
      END IF;

      -- Consulta registro de aplicacao
      OPEN cr_craprac(pr_cdcooper => rw_craprga.cdcooper
                     ,pr_nrdconta => rw_craprga.nrdconta
                     ,pr_nraplica => rw_craprga.nraplica);

      FETCH cr_craprac INTO rw_craprac;

      -- Verifica se encontrou registro de aplicacao
      IF cr_craprac%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_craprac;

        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao consultar registro de aplicacao.';
        RAISE vr_exc_saida;
      ELSE
        -- Fecha cursor
        CLOSE cr_craprac;
      END IF;

      -- Consulta registro de produtos
      OPEN cr_crapcpc(pr_cdprodut => rw_craprac.cdprodut);

      FETCH cr_crapcpc INTO rw_crapcpc;

      -- Verifica se encontrou registro de aplicacao
      IF cr_crapcpc%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_craprac;

        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao consultar produto de aplicacao.';
        RAISE vr_exc_saida;
      ELSE
        -- Fecha cursor
        CLOSE cr_crapcpc;
      END IF;

      -- Verifica se é resgate online
      IF rw_craprga.idresgat = 1 AND
         rw_craprga.dtresgat = pr_dtmvtolt AND
         rw_craprga.dtmvtolt = pr_dtmvtolt THEN

        -- Resgate Online

        -- Consulta de saldo do dia
        EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper
                                   ,pr_rw_crapdat => rw_crapdat
                                   ,pr_cdagenci   => pr_cdagenci
                                   ,pr_nrdcaixa   => pr_nrdcaixa
                                   ,pr_cdoperad   => pr_cdoperad
                                   ,pr_nrdconta   => pr_nrdconta
                                   ,pr_vllimcre   => rw_crapass.vllimcre
                                   ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                   ,pr_flgcrass   => FALSE
                                   ,pr_tipo_busca => 'A' --Chamado 291693 (Heitor - RKAM)
                                   ,pr_des_reto   => vr_des_reto
                                   ,pr_tab_sald   => vr_tab_sald
                                   ,pr_tab_erro   => vr_tab_erro);

        IF vr_des_reto = 'NOK' THEN
          -- Tenta buscar o erro no vetor de erro
          IF vr_tab_erro.COUNT > 0 THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Retorno "NOK" na APLI0005.pc_cancela_resgate.'; --63600 + 8400
          END IF;

          -- Levantar Excecao
          RAISE vr_exc_saida;

        END IF;

        -- Verifica se saldo é suficiente
        IF rw_craprga.vlresgat > (vr_tab_sald(vr_tab_sald.FIRST).vllimcre + vr_tab_sald(vr_tab_sald.FIRST).vlsddisp) THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Saldo insuficiente para cancelar o resgate.';
          -- Levantar Excecao
          RAISE vr_exc_saida;
        END IF;

        BEGIN

          UPDATE
            craprga
          SET
            craprga.idresgat = 3
           ,craprga.cdoperad = pr_cdoperad
           ,craprga.hrtransa = TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
          WHERE
            craprga.rowid = rw_craprga.rowid;

        EXCEPTION

          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar registro de cancelamento de aplicacao. Erro: ' || SQLERRM;
            RAISE vr_exc_saida;

        END;

        -- Verifica se o resgate foi creditado na conta investimento
      IF rw_craprga.idrgtcti = 1 THEN

        -- Consulta registro de lote
        OPEN cr_craplot(pr_cdcooper => rw_craprga.cdcooper
                       ,pr_dtresgat => rw_craprga.dtresgat
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 10113);

        FETCH cr_craplot INTO rw_craplot;

        IF cr_craplot%NOTFOUND THEN
          -- Fecha cursor
          CLOSE cr_craplot;

          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao consultar registro de lote. Erro: ' || SQLERRM;
          RAISE vr_exc_saida;
        ELSE
          -- Fecha cursor
          CLOSE cr_craplot;

          -- Atualiza registro de lote
          BEGIN

            UPDATE
              craplot
            SET
              craplot.qtinfoln = craplot.qtinfoln - 1,
              craplot.qtcompln = craplot.qtcompln - 1,
              craplot.vlinfocr = craplot.vlinfocr - rw_craprga.vlresgat,
              craplot.vlcompcr = craplot.vlcompcr - rw_craprga.vlresgat
            WHERE
              craplot.rowid = rw_craplot.rowid
            RETURNING
              qtcompln, qtinfoln, vlcompcr, vlinfocr, vlcompdb, vlinfodb
            INTO
              rw_craplot.qtcompln, rw_craplot.qtinfoln, rw_craplot.vlcompcr,
              rw_craplot.vlinfocr, rw_craplot.vlcompdb, rw_craplot.vlinfodb;

          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar registro de lote. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

          IF rw_craplot.qtcompln = 0 AND rw_craplot.qtinfoln = 0 AND
             rw_craplot.vlcompcr = 0 AND rw_craplot.vlinfocr = 0 AND
             rw_craplot.vlcompdb = 0 AND rw_craplot.vlinfodb = 0 THEN

            -- Deleta registro de lote
            BEGIN
              DELETE FROM craplot WHERE ROWID = rw_craplot.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao excluir registro de lote. Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;

            -- Verifica se houve a exclusao de algum registro, caso contrário exibe critica e aborta o processo
            IF SQL%ROWCOUNT <= 0 THEN
              vr_dscritic := 'Registro de lote nao encontrado.';
              RAISE vr_exc_saida;
            END IF;

          END IF;

          -- Consulta de lancamento na conta investimento
          OPEN cr_craplci(pr_cdcooper => rw_craprga.cdcooper
                         ,pr_dtmvtolt => rw_craprga.dtresgat
                         ,pr_cdagenci => 1
                         ,pr_cdbccxlt => 100
                         ,pr_nrdolote => 10113
                         ,pr_nrdconta => rw_craprga.nrdconta
                         ,pr_nraplica => rw_craprga.nraplica
                         ,pr_cdhistor => 490
                         ,pr_vllanmto => rw_craprga.vlresgat);

          FETCH cr_craplci INTO rw_craplci;

          -- Verifica se registro de conta investimento existe
          IF cr_craplci%NOTFOUND THEN
            -- Fechar cursor
            CLOSE cr_craplci;
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao consultar lancamento de conta investimento.';
            RAISE vr_exc_saida;
          ELSE
            -- Fechar cursor
            CLOSE cr_craplci;

            -- Deleta registro de lancamento de conta investimento
            BEGIN
              DELETE FROM craplci WHERE ROWID = rw_craplci.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao excluir registro de lancamento de Conta Investimento. Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;

            -- Verifica se houve a exclusao de algum registro, caso contrário exibe critica e aborta o processo
            IF SQL%ROWCOUNT <= 0 THEN
              vr_dscritic := 'Registro de Conta Investimento nao encontrado.';
              RAISE vr_exc_saida;
            END IF;
          END IF;

          -- Ajuste do saldo da conta investimento
          BEGIN
            UPDATE
              crapsli
            SET
              crapsli.vlsddisp = crapsli.vlsddisp - rw_craprga.vlresgat
            WHERE
                  crapsli.cdcooper = rw_craprga.cdcooper
              AND crapsli.nrdconta = rw_craprga.nrdconta
              AND crapsli.dtrefere = gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                                ,pr_dtmvtolt => LAST_DAY(rw_craprga.dtresgat)
                                                                ,pr_tipo     => 'A'); -- Deve ser o último dia útil do mês
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar registro de saldo de conta investimento. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

        END IF;

      ELSIF rw_craprga.idrgtcti = 0 THEN -- Verifica se resgate foi creditado na conta-corrente

        -------------- DEBITO ---------------
        -- Consulta registro de lote de debito
        OPEN cr_craplot(pr_cdcooper => rw_craprga.cdcooper
                       ,pr_dtresgat => rw_craprga.dtresgat
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 10111);

        FETCH cr_craplot INTO rw_craplot;

        IF cr_craplot%NOTFOUND THEN
          -- Fecha cursor
          CLOSE cr_craplot;

          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao consultar registro de lote de debito.';
          RAISE vr_exc_saida;
        ELSE
          -- Fecha cursor
          CLOSE cr_craplot;

          BEGIN

            UPDATE
              craplot
            SET
              craplot.qtinfoln = craplot.qtinfoln - 1
             ,craplot.qtcompln = craplot.qtcompln - 1
             ,craplot.vlinfodb = craplot.vlinfodb - rw_craprga.vlresgat
             ,craplot.vlcompdb = craplot.vlcompdb - rw_craprga.vlresgat
            WHERE
              craplot.rowid = rw_craplot.rowid
            RETURNING
              qtcompln, qtinfoln, vlcompcr, vlinfocr, vlcompdb, vlinfodb
            INTO
              rw_craplot.qtcompln, rw_craplot.qtinfoln, rw_craplot.vlcompcr,
              rw_craplot.vlinfocr, rw_craplot.vlcompdb, rw_craplot.vlinfodb;

          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar registro de lote de debito.';
              RAISE vr_exc_saida;
          END;

          IF rw_craplot.qtcompln = 0 AND rw_craplot.qtinfoln = 0 AND
             rw_craplot.vlcompcr = 0 AND rw_craplot.vlinfocr = 0 AND
             rw_craplot.vlcompdb = 0 AND rw_craplot.vlinfodb = 0 THEN

            -- Deleta registro de lote de debito
            BEGIN
              DELETE FROM craplot WHERE ROWID = rw_craplot.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao excluir registro de lote de debito. Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;

            -- Verifica se houve a exclusao de algum registro, caso contrário exibe critica e aborta o processo
            IF SQL%ROWCOUNT <= 0 THEN
              vr_dscritic := 'Registro de lote de debito nao encontrado.';
              RAISE vr_exc_saida;
            END IF;
          END IF;

          -- Consulta de lancamento de debito
          OPEN cr_craplci(pr_cdcooper => rw_craprga.cdcooper
                         ,pr_dtmvtolt => rw_craprga.dtresgat
                         ,pr_cdagenci => 1
                         ,pr_cdbccxlt => 100
                         ,pr_nrdolote => 10111
                         ,pr_nrdconta => rw_craprga.nrdconta
                         ,pr_nraplica => rw_craprga.nraplica
                         ,pr_cdhistor => rw_crapcpc.cdhsrgap
                         ,pr_vllanmto => rw_craprga.vlresgat);

          FETCH cr_craplci INTO rw_craplci;

          -- Verifica se registro de lancamento de debito
          IF cr_craplci%NOTFOUND THEN
            -- Fechar cursor
            CLOSE cr_craplci;
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao consultar lancamento de debito CRAPLCI.';
            RAISE vr_exc_saida;
          ELSE
            -- Fechar cursor
            CLOSE cr_craplci;

            -- Deleta registro de lancamento de debito
            BEGIN
              DELETE FROM craplci WHERE ROWID = rw_craplci.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao excluir registro de lancamento de Debito. Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;

            -- Verifica se houve a exclusao de algum registro, caso contrário exibe critica e aborta o processo
            IF SQL%ROWCOUNT <= 0 THEN
              vr_dscritic := 'Registro de lancamento de debito nao encontrado.';
              RAISE vr_exc_saida;
            END IF;

          END IF;

        END IF;
        -------------- FIM DEBITO ------------

        -------------- CREDITO ---------------
        -- Consulta registro de lote de credito
        OPEN cr_craplot(pr_cdcooper => rw_craprga.cdcooper
                       ,pr_dtresgat => rw_craprga.dtresgat
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 10112);

        FETCH cr_craplot INTO rw_craplot;

        IF cr_craplot%NOTFOUND THEN
          -- Fecha cursor
          CLOSE cr_craplot;

          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao consultar registro de lote de credito. Erro: ' || SQLERRM;
          RAISE vr_exc_saida;
        ELSE
          -- Fecha cursor
          CLOSE cr_craplot;

          BEGIN

            UPDATE
              craplot
            SET
              craplot.qtinfoln = craplot.qtinfoln - 1
             ,craplot.qtcompln = craplot.qtcompln - 1
             ,craplot.vlinfocr = craplot.vlinfocr - rw_craprga.vlresgat
             ,craplot.vlcompcr = craplot.vlcompcr - rw_craprga.vlresgat
            WHERE
              craplot.rowid = rw_craplot.rowid
            RETURNING
              qtcompln, qtinfoln, vlcompcr, vlinfocr, vlcompdb, vlinfodb
            INTO
              rw_craplot.qtcompln, rw_craplot.qtinfoln, rw_craplot.vlcompcr,
              rw_craplot.vlinfocr, rw_craplot.vlcompdb, rw_craplot.vlinfodb;

          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar registro de lote de credito.';
              RAISE vr_exc_saida;
          END;

          IF rw_craplot.qtcompln = 0 AND rw_craplot.qtinfoln = 0 AND
             rw_craplot.vlcompcr = 0 AND rw_craplot.vlinfocr = 0 AND
             rw_craplot.vlcompdb = 0 AND rw_craplot.vlinfodb = 0 THEN

            -- Deleta registro de lote de credito
            BEGIN
              DELETE FROM craplot WHERE ROWID = rw_craplot.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao excluir registro de lote de credito. Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;

            -- Verifica se houve a exclusao de algum registro, caso contrário exibe critica e aborta o processo
            IF SQL%ROWCOUNT <= 0 THEN
              vr_dscritic := 'Registro de lote de credito nao encontrado.';
              RAISE vr_exc_saida;
            END IF;

          END IF;

          -- Consulta de lancamento de credito
          OPEN cr_craplci(pr_cdcooper => rw_craprga.cdcooper
                         ,pr_dtmvtolt => rw_craprga.dtresgat
                         ,pr_cdagenci => 1
                         ,pr_cdbccxlt => 100
                         ,pr_nrdolote => 10112
                         ,pr_nrdconta => rw_craprga.nrdconta
                         ,pr_nraplica => rw_craprga.nraplica
                         ,pr_cdhistor => 489
                         ,pr_vllanmto => rw_craprga.vlresgat);

          FETCH cr_craplci INTO rw_craplci;

          -- Verifica se registro de lancamento de credito
          IF cr_craplci%NOTFOUND THEN
            -- Fechar cursor
            CLOSE cr_craplci;
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao consultar lancamento de Credito CRAPLCI.';
            RAISE vr_exc_saida;
          ELSE
            -- Fechar cursor
            CLOSE cr_craplci;

            -- Deleta registro de lancamento de credito
            BEGIN
              DELETE FROM craplci WHERE ROWID = rw_craplci.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao excluir registro de lancamento de Credito. Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;

            -- Verifica se houve a exclusao de algum registro, caso contrário exibe critica e aborta o processo
            IF SQL%ROWCOUNT <= 0 THEN
              vr_dscritic := 'Registro de lancamento de credito nao encontrado.';
              RAISE vr_exc_saida;
            END IF;

          END IF;

          ------- CONTA-CORRENTE ------------
          -- Consulta registro de lote de lancamento em conta-corrente
          OPEN cr_craplot(pr_cdcooper => rw_craprga.cdcooper
                         ,pr_dtresgat => rw_craprga.dtresgat
                         ,pr_cdagenci => 1
                         ,pr_cdbccxlt => 100
                         ,pr_nrdolote => 8503);

          FETCH cr_craplot INTO rw_craplot;

          IF cr_craplot%NOTFOUND THEN
            -- Fecha cursor
            CLOSE cr_craplot;

            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao consultar registro de lote de credito. Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
          ELSE
            -- Fecha cursor
            CLOSE cr_craplot;

            BEGIN

              UPDATE
                craplot
              SET
                craplot.qtinfoln = craplot.qtinfoln - 1
               ,craplot.qtcompln = craplot.qtcompln - 1
               ,craplot.vlinfocr = craplot.vlinfocr - rw_craprga.vlresgat
               ,craplot.vlcompcr = craplot.vlcompcr - rw_craprga.vlresgat
              WHERE
                craplot.rowid = rw_craplot.rowid
              RETURNING
                qtcompln, qtinfoln, vlcompcr, vlinfocr, vlcompdb, vlinfodb
              INTO
                rw_craplot.qtcompln, rw_craplot.qtinfoln, rw_craplot.vlcompcr,
                rw_craplot.vlinfocr, rw_craplot.vlcompdb, rw_craplot.vlinfodb;

            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar registro de lote de conta-corrente.';
                RAISE vr_exc_saida;
            END;

            IF rw_craplot.qtcompln = 0 AND rw_craplot.qtinfoln = 0 AND
               rw_craplot.vlcompcr = 0 AND rw_craplot.vlinfocr = 0 AND
               rw_craplot.vlcompdb = 0 AND rw_craplot.vlinfodb = 0 THEN

              -- Deleta registro de lote de credito
              BEGIN
                DELETE FROM craplot WHERE ROWID = rw_craplot.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic := 0;
                  vr_dscritic := 'Erro ao excluir registro de lote de conta-corrente. Erro: ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;

              -- Verifica se houve a exclusao de algum registro, caso contrário exibe critica e aborta o processo
              IF SQL%ROWCOUNT <= 0 THEN
                vr_dscritic := 'Registro de lote de conta-corrente nao encontrado.';
                RAISE vr_exc_saida;
              END IF;
              END IF;

              -- Consulta registro de lancamento em conta-corrente
              OPEN cr_craplcm(pr_cdcooper => rw_craprga.cdcooper
                             ,pr_dtmvtolt => rw_craprga.dtresgat
                             ,pr_cdagenci => 1
                             ,pr_cdbccxlt => 100
                             ,pr_nrdolote => 8503
                             ,pr_nrdctabb => rw_craprga.nrdconta
                             ,pr_nraplica => rw_craprga.nraplica
                             ,pr_cdhistor => rw_crapcpc.cdhsvrcc
                             ,pr_vllanmto => rw_craprga.vlresgat);

              FETCH cr_craplcm INTO rw_craplcm;

              -- Verifica se encontrou registro de lancamento
              IF cr_craplcm%NOTFOUND THEN
                -- Fecha cursor
                CLOSE cr_craplcm;
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao consultar registro de lancamento(CRAPLCM).';
                RAISE vr_exc_saida;
              ELSE
                -- Fecha cursor
                CLOSE cr_craplcm;

                BEGIN
                  DELETE FROM craplcm WHERE craplcm.rowid = rw_craplcm.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic := 0;
                    vr_dscritic := 'Erro ao excluir registro de lancamento de credito em conta corrente.';
                    RAISE vr_exc_saida;
                END;

                -- Verifica se houve a exclusao de algum registro, caso contrário exibe critica e aborta o processo
                IF SQL%ROWCOUNT <= 0 THEN
                  vr_dscritic := 'Registro de lancamento de credito em c/c nao encontrado.';
                  RAISE vr_exc_saida;
                END IF;
              END IF;

            END IF;
            ------- FIM CONTA-CORRENTE --------

          END IF;
          -------------- FIM CREDITO ---------------

        END IF; -- Fim verificacao tipo de conta que foi creditado o valor

        -- Agrupa codigo de historicos do produto
        vr_lshistor := rw_crapcpc.cdhsrvap || ',' || rw_crapcpc.cdhsrdap || ',' ||
                       rw_crapcpc.cdhsirap || ',' || rw_crapcpc.cdhsrgap;

        OPEN cr_craplac(pr_cdcooper => rw_craprga.cdcooper
                         ,pr_dtmvtolt => rw_craprga.dtresgat
                         ,pr_cdagenci => 1
                         ,pr_cdbccxlt => 100
                         ,pr_nrdolote => 8502
                         ,pr_nrdconta => rw_craprga.nrdconta
                         ,pr_nraplica => rw_craprga.nraplica
                         ,pr_cdhistor => vr_lshistor
                         ,pr_nrseqrgt => rw_craprga.nrseqrgt);

        LOOP

          FETCH cr_craplac INTO rw_craplac;

          -- Sai do loop quando chegar ao final dos registros
          EXIT WHEN cr_craplac%NOTFOUND;

          -- Consulta de historico
          OPEN cr_craphis(pr_cdhistor => rw_craplac.cdhistor);

          FETCH cr_craphis INTO rw_craphis;

          -- Verifica se encontrou registro de historico
          IF cr_craphis%NOTFOUND THEN
            -- Fecha cursor
            CLOSE cr_craphis;

            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao consultar historico.';
            RAISE vr_exc_saida;
          ELSE
            -- Fecha cursor
            CLOSE cr_craphis;

            -- Consulta de lote
            OPEN cr_craplot(pr_cdcooper => rw_craprga.cdcooper
                           ,pr_dtresgat => rw_craprga.dtresgat
                           ,pr_cdagenci => 1
                           ,pr_cdbccxlt => 100
                           ,pr_nrdolote => 8502);

            FETCH cr_craplot INTO rw_craplot;

            -- Verifica se existe registro de lote de debito
            IF cr_craplot%NOTFOUND THEN
              -- Fecha cursor
              CLOSE cr_craplot;

              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao consultar registro de lote.';

              RAISE vr_exc_saida;
            ELSE
              -- Fecha cursor
              CLOSE cr_craplot;

              -- Verifica tipo de historico
              IF UPPER(rw_craphis.indebcre) = 'C' THEN
                -- Atualiza registro de lote de credito
                BEGIN
                  UPDATE
                    craplot
                  SET
                    craplot.qtinfoln = craplot.qtinfoln - 1
                   ,craplot.qtcompln = craplot.qtcompln - 1
                   ,craplot.vlinfocr = craplot.vlinfocr - rw_craprga.vlresgat
                   ,craplot.vlcompcr = craplot.vlcompcr - rw_craprga.vlresgat
                  WHERE
                    craplot.rowid = rw_craplot.rowid
                  RETURNING
                    qtcompln, qtinfoln, vlcompcr, vlinfocr, vlcompdb, vlinfodb
                  INTO
                    rw_craplot.qtcompln, rw_craplot.qtinfoln, rw_craplot.vlcompcr,
                    rw_craplot.vlinfocr, rw_craplot.vlcompdb, rw_craplot.vlinfodb;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic := 0;
                    vr_dscritic := 'Erro ao atualizar registro de lote de lancamento de debito e credito. Erro: ' || SQLERRM;
                    RAISE vr_exc_saida;
                END;
              ELSE
                -- Atualiza registro de lote de debito
                BEGIN
                  UPDATE
                    craplot
                  SET
                    craplot.qtinfoln = craplot.qtinfoln - 1
                   ,craplot.qtcompln = craplot.qtcompln - 1
                   ,craplot.vlinfodb = craplot.vlinfodb - rw_craprga.vlresgat
                   ,craplot.vlcompdb = craplot.vlcompdb - rw_craprga.vlresgat
                  WHERE
                    craplot.rowid = rw_craplot.rowid
                  RETURNING
                    qtcompln, qtinfoln, vlcompcr, vlinfocr, vlcompdb, vlinfodb
                  INTO
                    rw_craplot.qtcompln, rw_craplot.qtinfoln, rw_craplot.vlcompcr,
                    rw_craplot.vlinfocr, rw_craplot.vlcompdb, rw_craplot.vlinfodb;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic := 0;
                    vr_dscritic := 'Erro ao atualizar registro de lote de lancamento de debito e credito. Erro: ' || SQLERRM;
                    RAISE vr_exc_saida;
                END;
              END IF;

              -- Verifica se valores do lote estao zerados
              IF rw_craplot.qtcompln = 0 AND rw_craplot.qtinfoln = 0 AND rw_craplot.vlcompcr = 0 AND
                 rw_craplot.vlinfocr = 0 AND rw_craplot.vlcompdb = 0 AND rw_craplot.vlinfodb = 0 THEN

                -- Excluir registros de lote
                BEGIN
                  DELETE FROM craplot WHERE craplot.rowid = rw_craplot.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic := 0;
                    vr_dscritic := 'Erro ao excluir registro de lote de debito e credito.';
                    RAISE vr_exc_saida;
                END;

                -- Verifica se houve a exclusao de algum registro, caso contrário exibe critica e aborta o processo
                IF SQL%ROWCOUNT <= 0 THEN
                  vr_dscritic := 'Registro de lote de debito e credito nao encontrado.';
                  RAISE vr_exc_saida;
                END IF;

              END IF;

            END IF;

          END IF;

          -- Exclui registro de lancamento de aplicacao
          BEGIN
            DELETE FROM craplac WHERE craplac.rowid = rw_craplac.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao excluir registro de lancamento de aplicacao. Erro:' || SQLERRM;
              RAISE vr_exc_saida;
          END;

          -- Verifica se houve a exclusao de algum registro, caso contrário exibe critica e aborta o processo
          IF SQL%ROWCOUNT <= 0 THEN
            vr_dscritic := 'Registro de lancamento de aplicacao nao encontrado.';
            RAISE vr_exc_saida;
          END IF;

          -- Ajustar o saldo da aplicação utilizando os valores dos lançamentos eliminados
          IF rw_craplac.cdhistor = rw_crapcpc.cdhsrvap OR
             rw_craplac.cdhistor = rw_crapcpc.cdhsirap OR
             rw_craplac.cdhistor = rw_crapcpc.cdhsrgap THEN

             -- Atualiza registro de saldo atuali da aplicacao
             BEGIN
               UPDATE
                 craprac
               SET
                 craprac.vlsldatl = craprac.vlsldatl + rw_craplac.vllanmto
               WHERE
                 craprac.rowid = rw_craprac.rowid;

             EXCEPTION
               WHEN OTHERS THEN
                 vr_cdcritic := 0;
                 vr_dscritic := 'Erro ao atualizar registro de saldo de aplicacao. Erro: ' || SQLERRM;
                 RAISE vr_exc_saida;
             END;

          ELSIF rw_craplac.cdhistor = rw_crapcpc.cdhsrdap THEN

            -- Atualiza registro de saldo atuali da aplicacao
            BEGIN
              UPDATE
                craprac
              SET
                craprac.vlsldatl = craprac.vlsldatl - rw_craplac.vllanmto
              WHERE
                craprac.rowid = rw_craprac.rowid;

            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar registro de saldo de aplicacao. Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;

          END IF;

          -- Verifica se é historico de resgate
          IF rw_craplac.cdhistor = rw_crapcpc.cdhsrgap THEN
            BEGIN
              UPDATE
                craprac
              SET
                craprac.vlbasapl = craprac.vlbasapl + rw_craplac.vlbasren
              WHERE
                craprac.rowid = rw_craprac.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar registro de aplicacao. Erro: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;

          END IF;

        END LOOP;

        -- Fechar cursor
        CLOSE cr_craplac;

        BEGIN
          UPDATE
            craprac
          SET
            craprac.idsaqtot = 0,
            craprac.idcalorc = 0
          WHERE
            craprac.rowid = rw_craprac.rowid;

        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar registro de saque de aplicacao. Erro: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Verifica quantidade de registros de resgates efetuados
        OPEN cr_contlac(pr_cdcooper => rw_craprga.cdcooper
                       ,pr_dtmvtolt => rw_craprga.dtresgat
                       ,pr_cdagenci => 1
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 8502
                       ,pr_nrdconta => rw_craprga.nrdconta
                       ,pr_nraplica => rw_craprga.nraplica
                       ,pr_cdhistor => rw_crapcpc.cdhsrgap);

        FETCH cr_contlac INTO rw_contlac;

        -- Verifica se encontrou registros
        IF cr_contlac%NOTFOUND THEN
          -- Fecha cursor
          CLOSE cr_contlac;

          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao consultar registros de lancamentos de provisao.';

          RAISE vr_exc_saida;
        ELSE
          -- Fecha cursor
          CLOSE cr_contlac;
        END IF;

        -- Se não existir mais nenhum resgate efetuado no dia, eliminar o lançamento de provisão
        -- e retornar saldo anterior ao lançamento da provisão
        IF rw_contlac.contador = 0 THEN

          BEGIN
            DELETE FROM
              craplac
            WHERE
                  craplac.cdcooper = rw_craprga.cdcooper
              AND craplac.dtmvtolt = rw_craprga.dtresgat
              AND craplac.cdagenci = 1
              AND craplac.cdbccxlt = 100
              AND craplac.nrdolote = 8502
              AND craplac.nrdconta = rw_craprga.nrdconta
              AND craplac.nraplica = rw_craprga.nraplica
              AND craplac.cdhistor = rw_crapcpc.cdhsprap;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao excluir registro de lancamento. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

          -- Atualiza saldos
          BEGIN
            UPDATE
              craprac
            SET
              craprac.vlsldatl = rw_craprac.vlsldant
             ,craprac.vlbasapl = rw_craprac.vlbasant
             ,craprac.dtatlsld = rw_craprac.dtsldant
            WHERE
              craprac.rowid = rw_craprac.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atulizar registro de saldo atual de aplicacao. Erro: ' || SQLERRM;
              RAISE vr_exc_saida;
          END;

        END IF;
      END IF;

      -- Verifica se deve haver gravacao de log
      IF pr_flgerlog = 1 THEN
        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => SUBSTR(pr_cdoperad,1,10)
                            ,pr_dscritic => SUBSTR(vr_dscritic,1,159)
                            ,pr_dsorigem => SUBSTR(gene0001.vr_vet_des_origens(pr_idorigem),1,13)
                            ,pr_dstransa => SUBSTR(vr_dstransa,1,121)
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'NRAPLICA'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_nraplica);

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'NRDOCMTO'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => pr_nraplica);

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'DTRESGAT'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => TO_CHAR(pr_dtresgat,'dd/MM/RRRR'));

        IF rw_craprga.idtiprgt = 1 THEN
          vr_idtiprgt := 'PARCIAL';
        ELSE
          vr_idtiprgt := 'TOTAL';
        END IF;

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'IDTIPRGT'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => vr_idtiprgt);

        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'VLRESGAT'
                                 ,pr_dsdadant => ''
                                 ,pr_dsdadatu => TO_CHAR(rw_craprga.vlresgat,'fm9999G990D00'));
      END IF;

      -- Grava efetivamente as informações no BD
      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        ROLLBACK;

        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => SUBSTR(pr_cdoperad,1,10)
                            ,pr_dscritic => SUBSTR(vr_dscritic,1,159)
                            ,pr_dsorigem => SUBSTR(gene0001.vr_vet_des_origens(pr_idorigem),1,13)
                            ,pr_dstransa => SUBSTR(vr_dstransa,1,121)
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
        COMMIT;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado no cancelamento de resgate APLI0005.pc_cancela_resgate: ' || SQLERRM;

        ROLLBACK;

        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => SUBSTR(pr_cdoperad,1,10)
                            ,pr_dscritic => SUBSTR(vr_dscritic,1,159)
                            ,pr_dsorigem => SUBSTR(gene0001.vr_vet_des_origens(pr_idorigem),1,13)
                            ,pr_dstransa => SUBSTR(vr_dstransa,1,121)
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
        COMMIT;

    END;
  END pc_cancela_resgate;

  /* Procedure para cancelamento de resgate vi WEB */
  PROCEDURE pc_cancela_resgate_web(pr_nrdconta IN crapass.nrdconta%TYPE     -- Numero da conta
                                  ,pr_idseqttl IN crapttl.idseqttl%TYPE     -- Sequecia do titular
                                  ,pr_nraplica IN craprac.nraplica%TYPE     -- Numero da aplicacao
                                  ,pr_nrdocmto IN INTEGER                   -- Numero do Documento
                                  ,pr_dtresgat IN VARCHAR2                  -- Data de resgate
                                  ,pr_dtmvtolt IN VARCHAR2                  -- Data de movimento atual
                                  ,pr_xmllog   IN VARCHAR2                  -- XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER              -- Código da crítica
                                  ,pr_dscritic OUT VARCHAR2                 -- Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType        -- Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2                 -- Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS             -- Erros do processo

   BEGIN
   /* .............................................................................

     Programa: pc_cancela_resgate_web
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Dezembro/14.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente ao cancelamento de resgate.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/

    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      vr_dtmvtolt DATE; -- Data de movimento atual
      vr_dtresgat DATE; -- Data de resgate

    BEGIN

      vr_dtmvtolt := TO_DATE(pr_dtmvtolt,'dd/mm/RRRR');
      vr_dtresgat := TO_DATE(pr_dtresgat,'dd/mm/RRRR');

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
        RAISE vr_exc_saida;
      END IF;

      -- Procedure para cancelar resgate de aplicacao
      APLI0005.pc_cancela_resgate(pr_cdcooper => vr_cdcooper
                                 ,pr_cdagenci => vr_cdagenci
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_cdoperad => vr_cdoperad
                                 ,pr_nmdatela => vr_nmdatela
                                 ,pr_idorigem => vr_idorigem
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_idseqttl => pr_idseqttl
                                 ,pr_nraplica => pr_nraplica
                                 ,pr_nrdocmto => pr_nrdocmto
                                 ,pr_dtresgat => vr_dtresgat
                                 ,pr_dtmvtolt => vr_dtmvtolt
                                 ,pr_flgerlog => 1
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log
      IF vr_dscritic IS NOT NULL OR
         vr_cdcritic <> 0 THEN
        RAISE vr_exc_saida;
      END IF;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>OK</Dados></Root>');

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;


      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em APLI0005.pc_cancela_resgate_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_cancela_resgate_web;

  PROCEDURE pc_calc_sld_resg_varias(pr_flagauto IN INTEGER                    -- Indicador de Resgate Automatico e Manual
                                   ,pr_cdcooper IN crapcop.cdcooper%TYPE      -- Codigo da cooperativa
                                   ,pr_cdagenci IN crapage.cdagenci%TYPE      -- Codigo do PA
                                   ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE      -- Codigo do Caixa
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE      -- Codigo do Operador
                                   ,pr_nmdatela IN craptel.nmdatela%TYPE      -- Nome da Tela
                                   ,pr_idorigem IN INTEGER                    -- Origem da solicitacao
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE      -- Numero da conta
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE      -- Sequecia do titular
                                   ,pr_nraplica IN craprac.nraplica%TYPE      -- Numero da aplicacao
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE      -- Data de movimento atual
                                   ,pr_cdprogra IN craplog.cdprogra%TYPE      -- Codigo do programa
                                   ,pr_flgerlog IN INTEGER                    -- Flag para gerar log
                                   ,pr_vlsldtot OUT craprac.vlaplica%TYPE     -- Valor de saldo total
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE     -- Codigo da critica
                                   ,pr_dscritic OUT crapcri.dscritic%TYPE) IS -- Descricao da critica

    BEGIN

    /* .............................................................................

     Programa: pc_calc_sld_resg_varias          Antiga: (b1wgen0081.p/calcula-saldo-resgate-varias)
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Novembro/14.                    Ultima atualizacao: 04/06/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente ao calculo do saldo de resgate de varias aplicacoes.

     Observacao: -----

     Alteracoes: 04/06/2018 - Ajuste para atender a SM404
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Erro em chamadas da pc_gera_erro
      vr_tab_saldo_rdca APLI0001.typ_tab_saldo_rdca; --> Tabela de Saldo do RDCA
      vr_tab_erro GENE0001.typ_tab_erro;             --> Tabela com erros

      -- Variaveis locais
      vr_nrdrowid ROWID;
      vr_dstransa VARCHAR(200) := 'Consulta saldo de resgate de varias aplicacoes';
      vr_vlbloque_aplica NUMBER := 0;
      vr_vlbloque_poupa NUMBER := 0;
      vr_vlbloque_ambos NUMBER := 0;

      -- Indice da temp-table
      vr_ind NUMBER;
      vr_vlsldtot craprac.vlaplica%TYPE := 0;

      -- Cursores
      CURSOR cr_craplrg(pr_cdcooper craplrg.cdcooper%TYPE
                       ,pr_nrdconta craplrg.nrdconta%TYPE
                       ,pr_nraplica craplrg.nraplica%TYPE
                       ,pr_dtresgat craplrg.dtresgat%TYPE
                       ,pr_inresgat craplrg.inresgat%TYPE) IS
        SELECT
          lrg.cdcooper
         ,lrg.nrdconta
         ,lrg.nraplica
         ,lrg.dtresgat
         ,lrg.inresgat
        FROM
          craplrg lrg
        WHERE
              lrg.cdcooper = pr_cdcooper
          AND lrg.nrdconta = pr_nrdconta
          AND lrg.nraplica = pr_nraplica
          AND lrg.dtresgat = pr_dtresgat
          AND lrg.inresgat = pr_inresgat;

    BEGIN

      -- Limpar as tabelas
      vr_tab_saldo_rdca.DELETE;
      vr_tab_erro.DELETE;

      -- Consulta as informações das aplicações
      APLI0005.pc_lista_aplicacoes(pr_cdcooper => pr_cdcooper
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_nmdatela => pr_nmdatela
                                  ,pr_idorigem => pr_idorigem
                                  ,pr_nrdcaixa => pr_nrdcaixa
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_idseqttl => pr_idseqttl
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_cdprogra => pr_cdprogra
                                  ,pr_nraplica => pr_nraplica
                                  ,pr_cdprodut => 0
                                  ,pr_dtmvtolt => pr_dtmvtolt
                                  ,pr_idconsul => 6
                                  ,pr_idgerlog => 0
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_saldo_rdca => vr_tab_saldo_rdca);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Vai para o primeiro registro
      vr_ind := vr_tab_saldo_rdca.first;

      -- loop sobre a tabela de saldo
      WHILE vr_ind IS NOT NULL LOOP

        -- Somar o valor de resgate
        vr_vlsldtot := vr_vlsldtot + vr_tab_saldo_rdca(vr_ind).sldresga;

        IF pr_flagauto = 1 THEN
          IF vr_tab_saldo_rdca(vr_ind).dsaplica = 'RDCPRE' OR
             vr_tab_saldo_rdca(vr_ind).idtippro = 1 THEN
            vr_vlsldtot := vr_vlsldtot - vr_tab_saldo_rdca(vr_ind).sldresga;
            -- Vai para o proximo registro
            vr_ind := vr_tab_saldo_rdca.next(vr_ind);
            CONTINUE;
          END IF;
        END IF;

        IF TO_DATE(vr_tab_saldo_rdca(vr_ind).dtmvtolt,'dd/mm/RRRR') = pr_dtmvtolt THEN
          vr_vlsldtot := vr_vlsldtot - vr_tab_saldo_rdca(vr_ind).sldresga;
        END IF;

        IF vr_tab_saldo_rdca(vr_ind).dssitapl = 'BLOQUEADA' THEN
          vr_vlsldtot := vr_vlsldtot - vr_tab_saldo_rdca(vr_ind).sldresga;
        END IF;

        IF TO_DATE(vr_tab_saldo_rdca(vr_ind).dtresgat,'dd/mm/RRRR') >= pr_dtmvtolt THEN

          OPEN cr_craplrg(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nraplica => vr_tab_saldo_rdca(vr_ind).nraplica
                         ,pr_dtresgat => vr_tab_saldo_rdca(vr_ind).dtresgat
                         ,pr_inresgat => 0);

          IF cr_craplrg%FOUND THEN
            CLOSE cr_craplrg;
            vr_vlsldtot := vr_vlsldtot - vr_tab_saldo_rdca(vr_ind).sldresga;

          ELSE
            CLOSE cr_craplrg;
          END IF;

        END IF;

        IF vr_tab_saldo_rdca(vr_ind).cddresga = 'SIM'
          AND vr_tab_saldo_rdca(vr_ind).dssitapl <> 'BLOQUEADA' -- SM404
        THEN
          vr_vlsldtot := vr_vlsldtot - vr_tab_saldo_rdca(vr_ind).sldresga;
        END IF;

        -- Vai para o proximo registro
        vr_ind := vr_tab_saldo_rdca.next(vr_ind);

      END LOOP;

      BLOQ0001.pc_retorna_bloqueio_garantia(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_tpctrato => 0
                                           ,pr_nrctaliq => pr_nrdconta -- Conta em que o contrato está em liquidação
                                           ,pr_dsctrliq => '' -- Lista separada em “;”
                                           ,pr_vlbloque_aplica => vr_vlbloque_aplica
                                           ,pr_vlbloque_poupa => vr_vlbloque_poupa
                                           ,pr_vlbloque_ambos => vr_vlbloque_ambos
                                           ,pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      pr_vlsldtot := vr_vlsldtot - vr_vlbloque_aplica;

      -- SM404
      IF nvl(pr_vlsldtot, 0) < 0 THEN
        --
        pr_vlsldtot := 0;
        --
      END IF;


      -- Verifica se deve haver gravacao de log
      IF pr_flgerlog = 1 THEN
        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => SUBSTR(pr_cdoperad,1,10)
                            ,pr_dscritic => SUBSTR(vr_dscritic,1,159)
                            ,pr_dsorigem => SUBSTR(gene0001.vr_vet_des_origens(pr_idorigem),1,13)
                            ,pr_dstransa => SUBSTR(vr_dstransa,1,121)
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        ROLLBACK;

        -- Verifica se deve haver gravacao de log
        IF pr_flgerlog = 1 THEN

          --Executar rotina geracao log
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => SUBSTR(pr_cdoperad,1,10)
                              ,pr_dscritic => SUBSTR(vr_dscritic,1,159)
                              ,pr_dsorigem => SUBSTR(gene0001.vr_vet_des_origens(pr_idorigem),1,13)
                              ,pr_dstransa => SUBSTR(vr_dstransa,1,121)
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);

          COMMIT;

        END IF;

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado no cancelamento de resgate APLI0005.pc_calc_sld_resg_varias: ' || SQLERRM;

        ROLLBACK;

        -- Verifica se deve haver gravacao de log
        IF pr_flgerlog = 1 THEN

          --Executar rotina geracao log
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => SUBSTR(pr_cdoperad,1,10)
                              ,pr_dscritic => SUBSTR(vr_dscritic,1,159)
                              ,pr_dsorigem => SUBSTR(gene0001.vr_vet_des_origens(pr_idorigem),1,13)
                              ,pr_dstransa => SUBSTR(vr_dstransa,1,121)
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);

          COMMIT;

        END IF;

    END;

  END pc_calc_sld_resg_varias;

  PROCEDURE pc_calc_sld_resg_varias_web(pr_flagauto IN INTEGER               --> Indicador de Resgate Automatico e Manual
                                       ,pr_nrdconta IN craprac.nrdconta%TYPE --> Número da Conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Sequecia do titular
                                       ,pr_nraplica IN craprac.nraplica%TYPE --> Número da Aplicação
                                       ,pr_dtmvtolt IN VARCHAR2              --> Data do Resgate (Data informada em tela)
                                       ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

    BEGIN
   /* .............................................................................

     Programa: pc_solicita_resgate_web
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Dezembro/14.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a validacao e cadastro de solicitacao de resgate.

     Observacao: -----

     Alteracoes:
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis locais
      vr_vlsldtot craprac.vlaplica%TYPE := 10; -- Saldo total
      vr_dtmvtolt crapdat.dtmvtolt%TYPE;

    BEGIN

      vr_dtmvtolt := TO_DATE(pr_dtmvtolt,'dd/mm/RRRR');

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
        RAISE vr_exc_saida;
      END IF;

      -- Calcula saldo de resgate de varias aplicacoes
      APLI0005.pc_calc_sld_resg_varias(pr_flagauto => pr_flagauto   --> Indicador de Resgate Automatico e Manual
                                      ,pr_cdcooper => vr_cdcooper   --> Codigo da cooperativa
                                      ,pr_cdagenci => vr_cdagenci   --> Codigo do PA
                                      ,pr_nrdcaixa => vr_nrdcaixa   --> Codigo do Caixa
                                      ,pr_cdoperad => vr_cdoperad   --> Codigo do Operador
                                      ,pr_nmdatela => vr_nmdatela   --> Nome da Tela
                                      ,pr_idorigem => vr_idorigem   --> Origem da solicitacao
                                      ,pr_nrdconta => pr_nrdconta   --> Numero da conta
                                      ,pr_idseqttl => pr_idseqttl   --> Sequecia do titular
                                      ,pr_nraplica => pr_nraplica   --> Numero da aplicacao
                                      ,pr_dtmvtolt => vr_dtmvtolt   --> Data de movimento atual
                                      ,pr_cdprogra => vr_nmdatela   --> Codigo do programa
                                      ,pr_flgerlog => 1             --> Flag para gerar log
                                      ,pr_vlsldtot => vr_vlsldtot   --> Valor de saldo total
                                      ,pr_cdcritic => vr_cdcritic   --> Codigo da critica
                                      ,pr_dscritic => vr_dscritic); --> Descricao da critica

      -- Verifica se houve erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados><vlsldtot>' || vr_vlsldtot || '</vlsldtot></Dados></Root>');

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>1' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na APLI0005.pc_calc_sld_resg_varias_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>2' || pr_dscritic || '</Erro></Root>');

    END;

  END pc_calc_sld_resg_varias_web;

  /* Procedure para listar o resgate de varias aplicacoes de forma manual */
  PROCEDURE pc_ret_apl_resg_manu(pr_cdcooper IN crapcop.cdcooper%TYPE              --> Codigo Cooperativa
                                ,pr_cdagenci IN crapass.cdagenci%TYPE              --> Codigo Agencia
                                ,pr_nrdcaixa IN INTEGER                            --> Numero do Caixa
                                ,pr_cdoperad IN VARCHAR2                           --> Codigo do Operador
                                ,pr_nmdatela IN VARCHAR2                           --> Nome da Tela
                                ,pr_idorigem IN INTEGER                            --> Origem
                                ,pr_nrdconta IN crapass.nrdconta%TYPE              --> Número da Conta
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE              --> Sequencia do Titular
                                ,pr_nraplica IN craprda.nraplica%TYPE              --> Número da Aplicação
                                ,pr_dtmvtolt IN DATE                               --> Data de Movimentação
                                ,pr_cdprogra IN VARCHAR2                           --> Codigo do Programa
                                ,pr_flgerlog IN INTEGER                            --> Gerar Log (0-False / 1-True)
                                ,pr_des_reto OUT VARCHAR2                          --> Retorno 'OK'/'NOK'
                                ,pr_tab_dados_resgate OUT APLI0001.typ_tab_resgate --> Tabela de Dados de Resgate
                                ,pr_tab_erro OUT gene0001.typ_tab_erro) IS         --> Tabela Erros

    /* .......................................................................................
    --
    -- Programa: pc_ret_apl_resg_manu         (Antiga b1wgen0081.retorna-aplicacoes-resgate-manual)
    -- Autor   : Douglas Quisinski
    -- Data    : 29/07/2014                        Ultima atualizacao: 29/07/2014
    --
    -- Dados referentes ao programa:
    --
    -- Objetivo  : Rotina responsavel por listar o resgate de varias aplicacoes de forma manual
    --
    --
    -- Alteracoes: 29/07/2014 - Conversao Progress >> PL/SQL (Oracle). (Douglas - Projeto Captação 2014/2)
    --
    -- .......................................................................................*/
    BEGIN
      DECLARE

        vr_dsorigem VARCHAR2(100);
        --Tabela de saldo de resgate
        vr_tab_saldo_rdca APLI0001.typ_tab_saldo_rdca;

        -- Erro
        vr_cdcritic INTEGER;
        vr_dscritic VARCHAR2(4000);
        -- Exceção
        vr_exc_erro EXCEPTION;
        vr_nrdrowid ROWID;
      BEGIN
        -- Buscar a origem
        vr_dsorigem:= gene0001.vr_vet_des_origens(pr_idorigem);

        -- Consulta de aplicacoes antigas e novas
        APLI0005.pc_lista_aplicacoes(pr_cdcooper   => pr_cdcooper         --> Código da Cooperativa
                                    ,pr_cdoperad   => pr_cdoperad         --> Código do Operador
                                    ,pr_nmdatela   => pr_nmdatela         --> Nome da Tela
                                    ,pr_idorigem   => pr_idorigem         --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                    ,pr_nrdcaixa   => pr_nrdcaixa         --> Numero do Caixa
                                    ,pr_nrdconta   => pr_nrdconta         --> Número da Conta
                                    ,pr_idseqttl   => pr_idseqttl         --> Titular da Conta
                                    ,pr_cdagenci   => pr_cdagenci         --> Codigo da Agencia
                                    ,pr_cdprogra   => pr_cdprogra         --> Codigo do Programa
                                    ,pr_nraplica   => pr_nraplica         --> Número da Aplicação - Parâmetro Opcional
                                    ,pr_cdprodut   => 0                   --> Código do Produto – Parâmetro Opcional
                                    ,pr_dtmvtolt   => pr_dtmvtolt         --> Data de Movimento
                                    ,pr_idconsul   => 6                   --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                    ,pr_idgerlog   => 1                   --> Identificador de Log (0 – Não / 1 – Sim)
                                    ,pr_cdcritic   => vr_cdcritic         --> Código da crítica
                                    ,pr_dscritic   => vr_dscritic         --> Descrição da crítica
                                    ,pr_saldo_rdca => vr_tab_saldo_rdca); --> Tabela com os dados da aplicação

        IF NVL(vr_cdcritic,0) <> 0 OR
          vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Filtrar as aplicações para o resgate manual
        APLI0002.pc_filtra_aplic_resg_manu(pr_cdcooper          => pr_cdcooper          --> Codigo Cooperativa
                                          ,pr_cdagenci          => pr_cdagenci          --> Codigo Agencia
                                          ,pr_nrdcaixa          => pr_nrdcaixa          --> Numero do Caixa
                                          ,pr_nrdconta          => pr_nrdconta          --> Número da Conta
                                          ,pr_dtmvtolt          => pr_dtmvtolt          --> Data de Movimentação
                                          ,pr_tab_saldo_rdca    => vr_tab_saldo_rdca    --> Aplicações a serem verificadas
                                          ,pr_tab_dados_resgate => pr_tab_dados_resgate --> dados para resgate
                                          ,pr_des_reto          => pr_des_reto          --> Retorno
                                          ,pr_tab_erro          => pr_tab_erro);        --> Tabela de Erros

        -- Verificar se ocorreu erro
        IF pr_des_reto = 'NOK' THEN
          IF pr_tab_erro.COUNT > 0 THEN
            -- Utiliza o erro que aconteceu
            vr_cdcritic := pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
            vr_dscritic := pr_tab_erro(pr_tab_erro.FIRST).dscritic;
            -- Limpar a tabela de erro, pois a exceção vai criar um novo registro
            pr_tab_erro.DELETE;
          ELSE
            -- Se não existir erro , utilizar o erro padrão
            vr_cdcritic:= NULL;
            vr_dscritic:= 'Retorno "NOK" na APLI0002.pc_retorna_aplic_rsg_manu e sem informação na pr_tab_erro.';
          END IF;
          RAISE vr_exc_erro;
        END IF;

        pr_des_reto := 'OK';

      EXCEPTION
        WHEN vr_exc_erro THEN

          IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;

          -- Montar mensagem de critica
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          -- Verificar se gera log
          IF  pr_flgerlog = 1 THEN
            GENE0001.pc_gera_log( pr_cdcooper => pr_cdcooper
                                 ,pr_cdoperad => pr_cdoperad
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_dsorigem => vr_dsorigem
                                 ,pr_dstransa => ''
                                 ,pr_dttransa => TRUNC(SYSDATE)
                                 ,pr_flgtrans => 0 --> FALSE
                                 ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                 ,pr_idseqttl => pr_idseqttl
                                 ,pr_nmdatela => pr_nmdatela
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrdrowid => vr_nrdrowid);
          END IF;
          pr_des_reto := 'NOK';

        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao executar APLI0002.pc_retorna_aplic_rsg_manu. ' || sqlerrm;
          -- Montar mensagem de critica
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1
                               ,pr_cdcritic => NULL
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          pr_des_reto := 'NOK';
    END;
  END pc_ret_apl_resg_manu;

  PROCEDURE pc_ret_apl_resg_aut(pr_cdcooper IN crapcop.cdcooper%TYPE      -- Codigo da cooperativa
                               ,pr_cdagenci IN crapage.cdagenci%TYPE      -- Codigo do PA
                               ,pr_nrdcaixa IN craplot.nrdcaixa%TYPE      -- Codigo do Caixa
                               ,pr_cdoperad IN crapope.cdoperad%TYPE      -- Codigo do Operador
                               ,pr_nmdatela IN craptel.nmdatela%TYPE      -- Nome da Tela
                               ,pr_idorigem IN INTEGER                    -- Origem da solicitacao
                               ,pr_nrdconta IN crapass.nrdconta%TYPE      -- Numero da conta
                               ,pr_idseqttl IN crapttl.idseqttl%TYPE      -- Sequecia do titular
                               ,pr_nraplica IN craprac.nraplica%TYPE      -- Numero da aplicacao
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE      -- Data de movimento atual
                               ,pr_dtmvtopr IN crapdat.dtmvtolt%TYPE      -- Data de movimento proximo
                               ,pr_dtresgat IN crapdat.dtmvtolt%TYPE      -- Data de resgate
                               ,pr_cdprogra IN craplog.cdprogra%TYPE      -- Codigo do programa
                               ,pr_flgerlog IN INTEGER                    -- Flag para gerar log
                               ,pr_vltotrgt IN OUT craprac.vlaplica%TYPE  -- Valor de saldo total
                               ,pr_resposta IN OUT VARCHAR2               -- Inf com dados cliente
                               ,pr_resgates IN OUT VARCHAR2               -- Inf com dados resgate
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE     -- Codigo da critica
                               ,pr_dscritic OUT crapcri.dscritic%TYPE) IS -- Descricao da critica

    BEGIN

    /* .............................................................................

     Programa: pc_ret_apl_resg_aut     Antiga:(b1wgen0081.p/retorna-aplicacoes-resgate-automatico)
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Outubro/14.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente ao resgate de varias aplicacaoes.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Erro em chamadas da pc_gera_erro
      vr_des_reto VARCHAR2(20);

      vr_tab_erro GENE0001.typ_tab_erro;
      vr_tab_saldo_rdca apli0001.typ_tab_saldo_rdca;
      vr_tab_dados_resgate APLI0001.typ_tab_resgate;  --> Dados para resgate
      vr_tab_resposta_cliente APLI0002.typ_tab_resposta_cliente;

      -- Variaveis locais
      vr_vltotrgt NUMBER(20,2); -- Valor saldo de resgate
      vr_contador PLS_INTEGER := 0; -- Contador de Registros

      vr_index VARCHAR2(25);

      vr_nrdrowid ROWID;
      vr_dstransa VARCHAR(200) := 'Consulta saldo de resgate de varias aplicacoes';

      vr_resgate_reg GENE0002.typ_split;
      vr_cliente_reg GENE0002.typ_split;

      vr_resgate_dados GENE0002.typ_split;
      vr_cliente_dados GENE0002.typ_split;

      aux_nraplica craprac.nraplica%TYPE;
      aux_dtmvtolt craprac.dtmvtolt%TYPE;
      aux_dshistor craphis.dshistor%TYPE;
      aux_nrdocmto craplcm.nrdocmto%TYPE;
      aux_dtvencto craprac.dtvencto%TYPE;
      aux_sldresga craprac.vlsldacu%TYPE;
      aux_tpresgat craplrg.tpresgat%TYPE;
      aux_vllanmto craplrg.vllanmto%TYPE;
      aux_idtipapl VARCHAR2(1);
      aux_resposta VARCHAR2(1000);

      vr_innivbloq Number := 0;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    BEGIN

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;

      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Valor de resgate
      vr_vltotrgt := pr_vltotrgt;

      /*Insere dados na temp-table*/
      vr_resgate_reg := gene0002.fn_quebra_string(pr_string => pr_resgates,pr_delimit => '|');
      vr_cliente_reg := gene0002.fn_quebra_string(pr_string => pr_resposta,pr_delimit => '|');

      -- Dados de Resgate
      IF NVL(vr_resgate_reg.count(),0) > 0 THEN
        FOR ind_registro IN vr_resgate_reg.FIRST..vr_resgate_reg.LAST LOOP
          vr_resgate_dados := gene0002.fn_quebra_string(pr_string => vr_resgate_reg(ind_registro),pr_delimit => ';');

          FOR ind_dados IN vr_resgate_dados.FIRST..vr_resgate_dados.LAST LOOP

            CASE ind_dados
              WHEN 1 THEN
                aux_nraplica := vr_resgate_dados(ind_dados);
              WHEN 2 THEN
                aux_dtmvtolt := vr_resgate_dados(ind_dados);
              WHEN 3 THEN
                aux_dshistor := vr_resgate_dados(ind_dados);
              WHEN 4 THEN
                aux_nrdocmto := vr_resgate_dados(ind_dados);
              WHEN 5 THEN
                aux_dtvencto := vr_resgate_dados(ind_dados);
              WHEN 6 THEN
                aux_sldresga := vr_resgate_dados(ind_dados);
              WHEN 7 THEN
                aux_vllanmto := vr_resgate_dados(ind_dados);
              WHEN 8 THEN
                aux_tpresgat := vr_resgate_dados(ind_dados);
              WHEN 9 THEN
                aux_idtipapl := vr_resgate_dados(ind_dados);
              ELSE
                NULL;
            END CASE;

          END LOOP;

          vr_tab_dados_resgate(ind_registro).saldo_rdca.nraplica := aux_nraplica;
          vr_tab_dados_resgate(ind_registro).saldo_rdca.dtmvtolt := aux_dtmvtolt;
          vr_tab_dados_resgate(ind_registro).saldo_rdca.dshistor := aux_dshistor;
          vr_tab_dados_resgate(ind_registro).saldo_rdca.nrdocmto := aux_nrdocmto;
          vr_tab_dados_resgate(ind_registro).saldo_rdca.dtvencto := aux_dtvencto;
          vr_tab_dados_resgate(ind_registro).saldo_rdca.sldresga := aux_sldresga;
          vr_tab_dados_resgate(ind_registro).saldo_rdca.idtipapl := aux_idtipapl;
          vr_tab_dados_resgate(ind_registro).vllanmto := aux_vllanmto;
          vr_tab_dados_resgate(ind_registro).tpresgat := aux_tpresgat;

        END LOOP;
      END IF;

      -- Dados de Respostas
      IF NVL(vr_cliente_reg.count(),0) > 0 THEN
        FOR ind_registro IN vr_cliente_reg.FIRST..vr_cliente_reg.LAST LOOP
          vr_cliente_dados := gene0002.fn_quebra_string(pr_string => vr_cliente_reg(ind_registro),pr_delimit => ';');

          FOR ind_dados IN vr_resgate_dados.FIRST..vr_resgate_dados.LAST LOOP

            CASE ind_dados
              WHEN 1 THEN
                aux_nraplica := vr_cliente_dados(ind_dados);
              WHEN 2 THEN
                aux_dtvencto := vr_cliente_dados(ind_dados);
              WHEN 3 THEN
                aux_resposta := vr_cliente_dados(ind_dados);
              ELSE
                NULL;
              END CASE;

          END LOOP;

          vr_tab_resposta_cliente(ind_registro).nraplica := aux_nraplica;
          vr_tab_resposta_cliente(ind_registro).dtvencto := aux_dtvencto;
          vr_tab_resposta_cliente(ind_registro).resposta := aux_resposta;

        END LOOP;
      END IF;

      /* Fim insere dados */

      -- Consulta de aplicacoes antigas e novas
      APLI0005.pc_lista_aplicacoes(pr_cdcooper   => pr_cdcooper         --> Código da Cooperativa
                                  ,pr_cdoperad   => pr_cdoperad         --> Código do Operador
                                  ,pr_nmdatela   => pr_nmdatela         --> Nome da Tela
                                  ,pr_idorigem   => pr_idorigem         --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                  ,pr_nrdcaixa   => pr_nrdcaixa         --> Numero do Caixa
                                  ,pr_nrdconta   => pr_nrdconta         --> Número da Conta
                                  ,pr_idseqttl   => pr_idseqttl         --> Titular da Conta
                                  ,pr_cdagenci   => pr_cdagenci         --> Codigo da Agencia
                                  ,pr_cdprogra   => pr_cdprogra         --> Codigo do Programa
                                  ,pr_nraplica   => pr_nraplica         --> Número da Aplicação - Parâmetro Opcional
                                  ,pr_cdprodut   => 0                   --> Código do Produto – Parâmetro Opcional
                                  ,pr_dtmvtolt   => pr_dtmvtolt         --> Data de Movimento
                                  ,pr_idconsul   => 6                   --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                  ,pr_idgerlog   => 1                   --> Identificador de Log (0 – Não / 1 – Sim)
                                  ,pr_cdcritic   => vr_cdcritic         --> Código da crítica
                                  ,pr_dscritic   => vr_dscritic         --> Descrição da crítica
                                  ,pr_saldo_rdca => vr_tab_saldo_rdca); --> Tabela com os dados da aplicação

      IF NVL(vr_cdcritic,0) <> 0 OR
        vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Se o resgate for oriundo das rotinas crps750 ou crps001
      -- então não faremos validação de bloqueio de garantia, pois
      -- estas rotinas estao solicitando um resgate para cobrir o
      -- propria bloqueio de garantia
      IF UPPER(pr_cdprogra) LIKE 'CRPS750%' OR UPPER(pr_cdprogra) = 'CRPS001' THEN
        vr_innivbloq := 1; --> Checar somente Bloqueio Judicial
      END IF;


      -- obter os valores Bloqueados Judicialmente e Garantia
      apli0002.pc_ver_val_bloqueio_aplica(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_cdoperad => Pr_cdoperad
                               ,pr_nmdatela => pr_nmdatela
                               ,pr_idorigem => pr_idorigem
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nraplica => pr_nraplica
                               ,pr_idseqttl => pr_idseqttl
                               ,pr_cdprogra => pr_cdprogra
                               ,pr_dtmvtolt => pr_dtmvtolt
                               ,pr_vlresgat => pr_vltotrgt
                               ,pr_flgerlog => pr_flgerlog
                               ,pr_innivblq => vr_innivbloq
                               ,pr_des_reto => vr_des_reto
                               ,pr_tab_erro => vr_tab_erro);

      -- Verifica se houve retorno de erros
      IF NVL(vr_des_reto,'OK') = 'NOK' THEN
        -- Se retornou na tab de erros
        IF vr_tab_erro.COUNT() > 0 THEN
          -- Guarda o código e descrição do erro
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          -- Definir o código do erro
          vr_cdcritic := 0;
          vr_dscritic := 'Nao foi possivel cadastrar o resgate.';
        END IF;

        -- Levantar excecao
        RAISE vr_exc_saida;

      END IF;

      -- Procedure para filtrar aplicações para resgate automatico
      APLI0002.pc_filtra_aplic_resg_auto(pr_cdcooper =>             pr_cdcooper             --> Codigo Cooperativa
                                        ,pr_cdagenci =>             pr_cdagenci             --> Codigo Agencia
                                        ,pr_nrdcaixa =>             pr_nrdcaixa             --> Numero do Caixa
                                        ,pr_cdoperad =>             pr_cdoperad             --> Codigo do operado
                                        ,pr_nmdatela =>             pr_nmdatela             --> Nome da tela
                                        ,pr_idorigem =>             pr_idorigem             --> Indicador de origem
                                        ,pr_nrdconta =>             pr_nrdconta             --> Numero da Conta
                                        ,pr_idseqttl =>             pr_idseqttl             --> Indicador de seq do titular
                                        ,pr_tab_saldo_rdca =>       vr_tab_saldo_rdca       --> Aplicações a serem verificadas
                                        ,pr_tpaplica =>             0                       --> Tipo de aplicação - FIXO 3 (RDCA)
                                        ,pr_dtmvtolt =>             rw_crapdat.dtmvtolt     --> Data de movimento
                                        ,pr_dtmvtopr =>             rw_crapdat.dtmvtopr     --> Data do proximo movimento
                                        ,pr_inproces =>             rw_crapdat.inproces     --> indicador de nivel de processo
                                        ,pr_dtresgat =>             pr_dtresgat             --> Data do resgate
                                        ,pr_cdprogra =>             pr_cdprogra             --> Código do programa
                                        ,pr_flgerlog =>             0                       --> Indicador para ger ar log 0-false/1-true
                                        ,pr_tab_dados_resgate =>    vr_tab_dados_resgate    --> Dados para resgate
                                        ,pr_tab_resposta_cliente => vr_tab_resposta_cliente --> Retorna respostas para as aplicações
                                        ,pr_vltotrgt =>             vr_vltotrgt             --> Valor total de resgate
                                        ,pr_tab_erro =>             vr_tab_erro             --> Tabela Erros
                                        ,pr_des_reto =>             vr_des_reto);           --> Retorno OK/NOK

      /*Mudanca*/

      /* Dados de Resgate */
      IF NVL(vr_tab_resposta_cliente.COUNT(),0) > 0 THEN
        vr_contador := 0;
        vr_index := vr_tab_resposta_cliente.FIRST;

        LOOP

          IF vr_contador > 1 THEN
            pr_resposta := pr_resposta || '|' ||
                           TRIM(vr_tab_resposta_cliente(vr_index).nraplica) || ';' ||
                           TRIM(TO_CHAR(vr_tab_resposta_cliente(vr_index).dtvencto,'dd/mm/RRRR')) || ';' ||
                           TRIM(vr_tab_resposta_cliente(vr_index).resposta);
          ELSE
            pr_resposta := TRIM(vr_tab_resposta_cliente(vr_index).nraplica) || ';' ||
                           TRIM(TO_CHAR(vr_tab_resposta_cliente(vr_index).dtvencto,'dd/mm/RRRR')) || ';' ||
                           TRIM(vr_tab_resposta_cliente(vr_index).resposta);

          END IF;

          EXIT WHEN vr_index = vr_tab_resposta_cliente.LAST;

          vr_index := vr_tab_resposta_cliente.NEXT(vr_index);
          vr_contador := vr_contador + 1;

        END LOOP;
      END IF;
      /* Fim Dados de Resgate*/

      /* Dados de Resposta */
      IF NVL(vr_tab_dados_resgate.COUNT(),0) > 0 THEN

        vr_contador := 1;
        vr_index := vr_tab_dados_resgate.FIRST;

        LOOP

          IF vr_contador > 1 THEN
            pr_resgates := pr_resgates || '|' ||
                           TRIM(vr_tab_dados_resgate(vr_index).saldo_rdca.nraplica) || ';' ||
                           TRIM(TO_CHAR(vr_tab_dados_resgate(vr_index).saldo_rdca.dtmvtolt,'dd/mm/RRRR')) || ';' ||
                           TRIM(vr_tab_dados_resgate(vr_index).saldo_rdca.dshistor) || ';' ||
                           TRIM(vr_tab_dados_resgate(vr_index).saldo_rdca.nrdocmto) || ';' ||
                           TRIM(TO_CHAR(vr_tab_dados_resgate(vr_index).saldo_rdca.dtvencto,'dd/mm/RRRR')) || ';' ||
                           TRIM(vr_tab_dados_resgate(vr_index).saldo_rdca.sldresga) || ';' ||
                           TRIM(vr_tab_dados_resgate(vr_index).vllanmto) || ';' ||
                           TRIM(vr_tab_dados_resgate(vr_index).tpresgat) || ';' ||
                           TRIM(vr_tab_dados_resgate(vr_index).saldo_rdca.idtipapl);
          ELSE
            pr_resgates := TRIM(vr_tab_dados_resgate(vr_index).saldo_rdca.nraplica) || ';' ||
                           TRIM(TO_CHAR(vr_tab_dados_resgate(vr_index).saldo_rdca.dtmvtolt,'dd/mm/RRRR')) || ';' ||
                           TRIM(vr_tab_dados_resgate(vr_index).saldo_rdca.dshistor) || ';' ||
                           TRIM(vr_tab_dados_resgate(vr_index).saldo_rdca.nrdocmto) || ';' ||
                           TRIM(TO_CHAR(vr_tab_dados_resgate(vr_index).saldo_rdca.dtvencto,'dd/mm/RRRR')) || ';' ||
                           TRIM(vr_tab_dados_resgate(vr_index).saldo_rdca.sldresga) || ';' ||
                           TRIM(vr_tab_dados_resgate(vr_index).vllanmto) || ';' ||
                           TRIM(vr_tab_dados_resgate(vr_index).tpresgat) || ';' ||
                           TRIM(vr_tab_dados_resgate(vr_index).saldo_rdca.idtipapl);
          END IF;

          EXIT WHEN vr_index = vr_tab_dados_resgate.LAST;

          vr_index := vr_tab_dados_resgate.NEXT(vr_index);
          vr_contador := vr_contador + 1;

        END LOOP;

      END IF;
      /* Fim Dados de Resgate*/

      -- Verificar se retornou erro
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.COUNT() > 0 THEN
          -- Se retornou, buscamos o erro que aconteceu
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          -- Limpar a tabela de erro, pois a exceção vai criar um novo registro
          vr_tab_erro.DELETE;
        ELSE
          -- Se ocorreu erro, mas não existe registro de erro, utiliza erro padrão
          vr_cdcritic := 0;
          vr_dscritic := 'Nao foi possivel listar as aplicacoes.';
        END IF;

        RAISE vr_exc_saida;
      ELSIF vr_des_reto = 'QUESTION' THEN
        RETURN;
      END IF;

      /*Fim Mudanca*/
      -- Verifica se deve haver gravacao de log
      IF pr_flgerlog = 1 THEN
        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => SUBSTR(pr_cdoperad,1,10)
                            ,pr_dscritic => SUBSTR(vr_dscritic,1,159)
                            ,pr_dsorigem => SUBSTR(gene0001.vr_vet_des_origens(pr_idorigem),1,13)
                            ,pr_dstransa => SUBSTR(vr_dstransa,1,121)
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        ROLLBACK;

        -- Verifica se deve haver gravacao de log
        IF pr_flgerlog = 1 THEN

          --Executar rotina geracao log
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => SUBSTR(pr_cdoperad,1,10)
                              ,pr_dscritic => SUBSTR(vr_dscritic,1,159)
                              ,pr_dsorigem => SUBSTR(gene0001.vr_vet_des_origens(pr_idorigem),1,13)
                              ,pr_dstransa => SUBSTR(vr_dstransa,1,121)
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);

          COMMIT;

        END IF;

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado no resgate automatico APLI0005.pc_ret_apl_resg_aut: ' || SQLERRM;

        ROLLBACK;

        -- Verifica se deve haver gravacao de log
        IF pr_flgerlog = 1 THEN

          --Executar rotina geracao log
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => SUBSTR(pr_cdoperad,1,10)
                              ,pr_dscritic => SUBSTR(vr_dscritic,1,159)
                              ,pr_dsorigem => SUBSTR(gene0001.vr_vet_des_origens(pr_idorigem),1,13)
                              ,pr_dstransa => SUBSTR(vr_dstransa,1,121)
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);

          COMMIT;

        END IF;

    END;

  END pc_ret_apl_resg_aut;

  PROCEDURE pc_ret_apl_resg_aut_web(pr_nrdconta IN crapass.nrdconta%TYPE     -- Numero da conta
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE     -- Sequecia do titular
                                   ,pr_nraplica IN craprac.nraplica%TYPE     -- Numero da aplicacao
                                   ,pr_dtmvtolt IN VARCHAR2                  -- Data de movimento atual
                                   ,pr_dtmvtopr IN VARCHAR2                  -- Data de movimento proximo
                                   ,pr_dtresgat IN VARCHAR2                  -- Data de resgate
                                   ,pr_vltotrgt IN craprac.vlaplica%TYPE     -- Valor de saldo total
                                   ,pr_flgerlog IN INTEGER                   -- Flag para gerar log
                                   ,pr_resposta IN VARCHAR2                  -- Inf com dados de resposta dos clientes
                                   ,pr_resgates IN VARCHAR2                  -- Inf com dados de resgates
                                   ,pr_xmllog   IN VARCHAR2                  -- XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER              -- Código da crítica
                                   ,pr_dscritic OUT VARCHAR2                 -- Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType        -- Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2                 -- Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS             -- Erros do processo

   BEGIN
   /* .............................................................................

     Programa: pc_ret_apl_resg_aut_web
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Dezembro/14.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente ao resgate automatico de aplicacoes
                 feito pelo Ayllos WEB.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/

    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      vr_dtmvtolt DATE; -- Data de movimento atual
      vr_dtmvtopr DATE; -- Data do proximo dia de movimento
      vr_dtresgat DATE; -- Data de resgate
      vr_vltotrgt craprac.vlaplica%TYPE := 0; -- Valor de resgate
      vr_resposta VARCHAR2(32000);
      vr_resgates VARCHAR2(32000);

    BEGIN

      vr_dtmvtolt := TO_DATE(pr_dtmvtolt,'dd/mm/RRRR');
      vr_dtmvtopr := TO_DATE(pr_dtmvtopr,'dd/mm/RRRR');
      vr_dtresgat := TO_DATE(pr_dtresgat,'dd/mm/RRRR');
      vr_vltotrgt := pr_vltotrgt;
      vr_resposta := pr_resposta;
      vr_resgates := pr_resgates;

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
        RAISE vr_exc_saida;
      END IF;

      /* Procedure para resgate de aplicacao */
      APLI0005.pc_ret_apl_resg_aut(pr_cdcooper => vr_cdcooper   -- Codigo da cooperativa
                                  ,pr_cdagenci => vr_cdagenci   -- Codigo do PA
                                  ,pr_nrdcaixa => vr_nrdcaixa   -- Codigo do Caixa
                                  ,pr_cdoperad => vr_cdoperad   -- Codigo do Operador
                                  ,pr_nmdatela => vr_nmdatela   -- Nome da Tela
                                  ,pr_idorigem => vr_idorigem   -- Origem da solicitacao
                                  ,pr_nrdconta => pr_nrdconta   -- Numero da conta
                                  ,pr_idseqttl => pr_idseqttl   -- Sequecia do titular
                                  ,pr_nraplica => pr_nraplica   -- Numero da aplicacao
                                  ,pr_dtmvtolt => vr_dtmvtolt   -- Data de movimento atual
                                  ,pr_dtmvtopr => vr_dtmvtopr   -- Data de movimento proximo
                                  ,pr_dtresgat => vr_dtresgat   -- Data de resgate
                                  ,pr_cdprogra => vr_nmdatela   -- Codigo do programa
                                  ,pr_flgerlog => pr_flgerlog   -- Flag para gerar log
                                  ,pr_vltotrgt => vr_vltotrgt   -- Valor de saldo total
                                  ,pr_resposta => vr_resposta   -- Inf com dados cliente
                                  ,pr_resgates => vr_resgates   -- Inf com dados resgate
                                  ,pr_cdcritic => vr_cdcritic   -- Codigo da critica
                                  ,pr_dscritic => vr_dscritic); -- Descricao da critica

      -- Verifica se houve erro recuperando informacoes de log
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>' ||
                                     '<vltotrgt>' || vr_vltotrgt || '</vltotrgt>' ||
                                     '<resposta>' || vr_resposta || '</resposta>' ||
                                     '<resgates>' || vr_resgates || '</resgates>' ||
                                     '</Dados></Root>');
       COMMIT;
    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;


      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em APLI0005.pc_ret_apl_resg_aut_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_ret_apl_resg_aut_web;

  /* Procedure para validacao de solicitacao de resgate */
  PROCEDURE pc_val_solicit_resgate_web(pr_nrdconta IN craprac.nrdconta%TYPE --> Número da Conta
                                      ,pr_nraplica IN craprac.nraplica%TYPE --> Número da Aplicação
                                      ,pr_dtresgat IN VARCHAR2              --> Data do Resgate (Data informada em tela)
                                      ,pr_vlresgat IN NUMBER               --> Valor do Resgate (Valor informado em tela)
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Sequencial de titular
                                      ,pr_idtiprgt IN INTEGER               --> Tipo do Resgate (Tipo informado em tela, 1 – Parcial / 2 – Total)
                                      ,pr_idrgtcti IN INTEGER               --> Resgate na Conta Investimento (Identificador informado em tela, 0 – Não)
                                      ,pr_idvldblq IN INTEGER               --> Identificador de validação do bloqueio judicial (0 – Não / 1 – Sim)
                                      ,pr_idgerlog IN INTEGER               --> Identificador de Log (Fixo no código, 0 – Não / 1 - Sim)
                                      ,pr_idvalida IN INTEGER               --> Identificador de Validacao (0 – Valida / 1 - Cadastra)
                                      ,pr_cdopera2 IN crapope.cdoperad%TYPE --> Operador
                                      ,pr_cddsenha IN crapope.cddsenha%TYPE --> Senha
                                      ,pr_flgsenha IN INTEGER               --> Validar senha (0 - Nao valida/1 - Validar)
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

    BEGIN
   /* .............................................................................

     Programa: pc_solicita_resgate_web
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Dezembro/14.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a validacao e cadastro de solicitacao de resgate.

     Observacao: -----

     Alteracoes:
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis locais
      vr_cdprodut crapcpc.cdprodut%TYPE := 0; -- Codigo do Produto da Aplicacao
      vr_dtresgat DATE;

    BEGIN

      -- Converte data passada como string
      vr_dtresgat := TO_DATE(pr_dtresgat, 'dd/mm/RRRR');

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
        RAISE vr_exc_saida;
      END IF;

      IF pr_idvalida = 0 THEN
        -- Validacao de solicitacao de resgate
        APLI0005.pc_val_solicit_resg(pr_cdcooper => vr_cdcooper
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_nmdatela => vr_nmdatela
                                    ,pr_idorigem => vr_idorigem
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_idseqttl => pr_idseqttl
                                    ,pr_nraplica => pr_nraplica
                                    ,pr_cdprodut => vr_cdprodut
                                    ,pr_dtresgat => vr_dtresgat
                                    ,pr_vlresgat => pr_vlresgat
                                    ,pr_idtiprgt => pr_idtiprgt
                                    ,pr_idrgtcti => pr_idrgtcti
                                    ,pr_idvldblq => pr_idvldblq
                                    ,pr_idgerlog => pr_idgerlog
                                    ,pr_cdopera2 => pr_cdopera2
                                    ,pr_cddsenha => pr_cddsenha
                                    ,pr_flgsenha => pr_flgsenha
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
        -- Verifica se houve critica
        IF vr_dscritic <> 'OK' AND vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

      ELSE
        /* Efetivação da solicitacao de resgate */
        APLI0005.pc_solicita_resgate(pr_cdcooper => vr_cdcooper   --> Código da Cooperativa
                                    ,pr_cdoperad => vr_cdoperad   --> Código do Operador
                                    ,pr_nmdatela => vr_nmdatela   --> Nome da Tela
                                    ,pr_idorigem => vr_idorigem   --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  )
                                    ,pr_nrdconta => pr_nrdconta   --> Número da Conta
                                    ,pr_idseqttl => pr_idseqttl   --> Titular da Conta
                                    ,pr_nraplica => pr_nraplica   --> Número da Aplicação
                                    ,pr_cdprodut => vr_cdprodut   --> Código do Produto
                                    ,pr_dtresgat => vr_dtresgat   --> Data do Resgate (Data informada em tela)
                                    ,pr_vlresgat => pr_vlresgat   --> Valor do Resgate (Valor informado em tela)
                                    ,pr_idtiprgt => pr_idtiprgt   --> Tipo do Resgate (Tipo informado em tela, 1 – Parcial / 2 – Total)
                                    ,pr_idrgtcti => pr_idrgtcti   --> Resgate na Conta Investimento (Identificador informado em tela, 0 – Não)
                                    ,pr_idgerlog => pr_idgerlog   --> Identificador de Log (Fixo no código, 0 – Não / 1 - Sim)
                                    ,pr_cdopera2 => pr_cdopera2
                                    ,pr_cddsenha => pr_cddsenha
                                    ,pr_flgsenha => pr_flgsenha
                                    ,pr_cdcritic => vr_cdcritic   --> Código da crítica
                                    ,pr_dscritic => vr_dscritic); --> Descricao da Critica

        -- Verifica se houve critica
        IF vr_dscritic <> 'OK' AND vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

      END IF;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na APLI0005.pc_val_solicit_resgate_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    END;

  END pc_val_solicit_resgate_web;

  PROCEDURE pc_obtem_resgates_conta(pr_cdcooper     IN crapcop.cdcooper%TYPE        --> Codigo Cooperativa
                                   ,pr_cdagenci     IN crapass.cdagenci%TYPE        --> Codigo Agencia
                                   ,pr_nrdcaixa     IN INTEGER                      --> Numero do Caixa
                                   ,pr_cdoperad     IN crapope.cdoperad%TYPE        --> Codigo do Operador
                                   ,pr_nmdatela     IN VARCHAR2                     --> Nome da Tela
                                   ,pr_idorigem     IN INTEGER                      --> Origem da solicitacao
                                   ,pr_nrdconta     IN craprac.nrdconta%TYPE        --> Número da Conta
                                   ,pr_idseqttl     IN crapttl.idseqttl%TYPE        --> Sequencia do Titular
                                   ,pr_dtmvtolt     IN DATE                         --> Data de Movimentação
                                   ,pr_flgcance     IN INTEGER                      --> Flag de Cancelamento
                                   ,pr_flgerlog     IN INTEGER                      --> Gerar Log (0-False / 1-True)
                                   ,pr_resg_aplica OUT APLI0005.typ_tab_resg_aplica --> Tabela com os dados de resgate de aplicacoes
                                   ,pr_cdcritic    OUT crapcri.cdcritic%TYPE        --> Codigo da critica
                                   ,pr_dscritic    OUT crapcri.dscritic%TYPE) IS    --> Descricao da critica

    BEGIN
   /* .............................................................................

     Programa: pc_obtem_resgates_conta          Antigo(b1wgen0081.p/obtem-resgates-conta)
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Março/15.                    Ultima atualizacao: 01/03/2015

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a listagem de resgates de aplicacoes.

     Observacao: -----

     Alteracoes: 01/03/2015 - Conversao Progress >> PL/SQL (Oracle). (Jean Michel - Projeto Novos Produtos de Captação)
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; -- Descricao da critica
      vr_dscritic VARCHAR2(10000);       -- Codigo da critica

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      --Variáveis locais
      vr_dstransa VARCHAR2(100) := ''; -- Descricao da transacao da procedire
      vr_nrdrowid ROWID;
      vr_dshistor VARCHAR2(50) := ''; -- Descricao do historico
      vr_contador INTEGER := 0;       -- Contador utilizado como indice da TT

      -- Temp Table
      vr_tab_resg_aplica APLI0005.typ_tab_resg_aplica; -- Tem-table com os dados de resgates de aplicacoes

      -- Cursores

      -- Consulta de lancamentos de resgate
      CURSOR cr_craplrg(pr_cdcooper craplrg.cdcooper%TYPE
                       ,pr_nrdconta craplrg.nrdconta%TYPE
                       ,pr_dtmvtolt craplrg.dtmvtolt%TYPE) IS
        SELECT
          lrg.cdcooper AS cdcooper
         ,lrg.nrdconta AS nrdconta
         ,lrg.nraplica AS nraplica
         ,lrg.cdoperad AS cdoperad
         ,lrg.dtresgat AS dtresgat
         ,lrg.nrdocmto AS nrdocmto
         ,DECODE(lrg.inresgat,0,'Nao Resg.',1,'Resgatado',3,'Estornado','Cancelado') AS inresgat
         ,DECODE(lrg.tpresgat,1,'Parcial',2,'Total',3,'Antecipado',4,'Parc. Dia',5,'Total Dia','Antec. Dia') AS tpresgat
         ,lrg.hrtransa AS hrtransa
         ,lrg.vllanmto AS vllanmto
         ,lrg.dtmvtolt AS dtmvtolt
         ,NVL(gene0002.fn_busca_entrada(pr_postext => 1, pr_dstext => ope.nmoperad, pr_delimitador => ' '),'INEXISTENTE') AS nmoperad
         ,dtc.dsaplica AS dsaplica
         ,rda.qtdiauti AS qtdiauti
         ,rda.tpaplica AS tpaplica
         ,rda.vlaplica AS vlaplica
        FROM
          craplrg lrg
         ,crapope ope
         ,craprda rda
         ,crapdtc dtc
        WHERE
              lrg.cdcooper = pr_cdcooper
          AND lrg.nrdconta = pr_nrdconta
          AND lrg.inresgat IN(0,2)
          AND ope.cdcooper = lrg.cdcooper
          AND upper(ope.cdoperad) = upper(lrg.cdoperad)
          AND rda.cdcooper = lrg.cdcooper
          AND rda.nrdconta = lrg.nrdconta
          AND rda.nraplica = lrg.nraplica
          AND dtc.cdcooper = lrg.cdcooper
          AND dtc.tpaplrdc IN (1,2)
          AND dtc.tpaplica = rda.tpaplica
        ORDER BY
          lrg.nrdocmto;

      rw_craplrg craplrg%ROWTYPE;

      -- Buscar registros de resgate
      CURSOR cr_craprga(pr_cdcooper IN craprga.cdcooper%TYPE
                       ,pr_nrdconta IN craprga.nrdconta%TYPE
                       ,pr_nraplica IN craprga.nraplica%TYPE
                       ,pr_dtmvtolt IN craprga.dtmvtolt%TYPE
                       ,pr_flgcance IN INTEGER) IS

        SELECT
          rga.nraplica AS nraplica
         ,rga.dtresgat AS dtresgat
         ,rga.nrseqrgt AS nrseqrgt
         ,DECODE(rga.idtiprgt,1,'Parcial',2,'Total') AS idtiprgt
         ,DECODE(rga.idresgat,0,'Nao Resgatado',1,'Resgatado',2,'Cancelado',3,'Estornado') AS idresgat
         ,rga.cdoperad AS cdoperad
         ,ope.nmoperad AS nmoperad
         ,rga.hrtransa AS hrtransa
         ,rga.vlresgat AS vlresgat
         ,cpc.cdprodut AS cdprodut
         ,rga.dtmvtolt AS dtmvtolt
         ,cpc.nmprodut AS nmprodut
         ,(NVL(npc.dsnomenc,cpc.nmprodut) || '-' || rac.vlaplica) AS dshistor
        FROM
          craprga rga
         ,crapope ope
         ,craprac rac
         ,crapcpc cpc
         ,crapnpc npc
        WHERE
              rga.cdcooper  = pr_cdcooper
          AND rga.nrdconta  = pr_nrdconta
          AND (rga.nraplica = pr_nraplica
           OR pr_nraplica = 0)
          AND ope.cdcooper = rga.cdcooper
          AND upper(ope.cdoperad) = upper(rga.cdoperad)
          AND rac.cdcooper = rga.cdcooper
          AND rac.nraplica = rga.nraplica
          AND rac.nrdconta = rga.nrdconta
          AND cpc.cdprodut = rac.cdprodut
          AND npc.cdnomenc(+) = rac.cdnomenc
          AND (rga.idresgat = 0
           OR (rga.idresgat = 1
          AND rga.dtresgat = pr_dtmvtolt
          AND rga.dtmvtolt = pr_dtmvtolt
           AND pr_flgcance = 1));

      rw_craprga cr_craprga%ROWTYPE;

    BEGIN
      --Limpa temp-table
      vr_tab_resg_aplica.DELETE;

      IF pr_flgerlog = 1 THEN
        vr_dstransa := 'Obtem resgates da conta';
      END IF;

      -- Leitura de lancamentos de resgates solicitados para antigas aplicacoes
      FOR rw_craplrg IN cr_craplrg(pr_cdcooper => pr_cdcooper  --> Código da Cooperativa
                                  ,pr_nrdconta => pr_nrdconta  --> Número da Conta
                                  ,pr_dtmvtolt => pr_dtmvtolt) --> Data de movimento

      LOOP
        IF pr_idorigem IN (1,2) THEN
          IF rw_craplrg.tpaplica = 3 THEN
            vr_dshistor := 'RDCA   ';
          ELSIF rw_craplrg.tpaplica = 5 THEN
            vr_dshistor := 'RDCA60 ';
          ELSE
            IF rw_craplrg.dsaplica = 'RDCPOS'  THEN
              vr_dshistor := 'RDC' || TO_CHAR(rw_craplrg.qtdiauti,'0000');
            ELSE
              vr_dshistor := SUBSTR(rw_craplrg.dsaplica,0,7);
            END IF;
          END IF;

          vr_dshistor := vr_dshistor || TO_CHAR(rw_craplrg.vlaplica,'fm9999G990D00');

        ELSE
          IF rw_craplrg.tpaplica = 3 THEN
            vr_dshistor := 'Apl. RDCA  :';
          ELSE
            IF rw_craplrg.tpaplica = 5 THEN
              vr_dshistor := 'Apl. RDCA60:';
            ELSE
              vr_dshistor := 'Apl. ' || SUBSTR(rw_craplrg.dsaplica,0,6) || ':';
            END IF;
          END IF;
          vr_dshistor := vr_dshistor || TO_CHAR(rw_craplrg.vlaplica,'fm999G999G990D00');

        END IF;

        vr_tab_resg_aplica(vr_contador).dtresgat := rw_craplrg.dtresgat;
        vr_tab_resg_aplica(vr_contador).nrdocmto := rw_craplrg.nrdocmto;
        vr_tab_resg_aplica(vr_contador).tpresgat := rw_craplrg.tpresgat;
        vr_tab_resg_aplica(vr_contador).dsresgat := rw_craplrg.inresgat;
        vr_tab_resg_aplica(vr_contador).nmoperad := rw_craplrg.nmoperad;
        vr_tab_resg_aplica(vr_contador).hrtransa := TO_CHAR(TO_DATE(rw_craplrg.hrtransa,'SSSSS'),'hh24:mi');
        vr_tab_resg_aplica(vr_contador).vllanmto := rw_craplrg.vllanmto;
        vr_tab_resg_aplica(vr_contador).nraplica := rw_craplrg.nraplica;
        vr_tab_resg_aplica(vr_contador).dshistor := vr_dshistor;
        vr_tab_resg_aplica(vr_contador).dtmvtolt := rw_craplrg.dtmvtolt;
        vr_tab_resg_aplica(vr_contador).dtaplica := rw_craplrg.dtmvtolt;
        vr_tab_resg_aplica(vr_contador).idtipapl := 'A';

        -- Incrementa contador do indice da TT
        vr_contador := vr_contador + 1;

      END LOOP;

      -- Leitura de lancamentos de resgates solicitados para novas aplicacoes
      FOR rw_craprga IN cr_craprga(pr_cdcooper => pr_cdcooper  --> Codigo da cooperativa
                                  ,pr_nrdconta => pr_nrdconta  --> Numero da conta
                                  ,pr_nraplica => 0            --> Numero da aplicacao
                                  ,pr_dtmvtolt => pr_dtmvtolt  --> Data de movimento
                                  ,pr_flgcance => pr_flgcance) --> Flag de cancelamento

      LOOP
        vr_tab_resg_aplica(vr_contador).dtresgat := rw_craprga.dtresgat;
        vr_tab_resg_aplica(vr_contador).nrdocmto := rw_craprga.nrseqrgt;
        vr_tab_resg_aplica(vr_contador).tpresgat := rw_craprga.idtiprgt;
        vr_tab_resg_aplica(vr_contador).dsresgat := rw_craprga.idresgat;
        vr_tab_resg_aplica(vr_contador).nmoperad := rw_craprga.nmoperad;
        vr_tab_resg_aplica(vr_contador).hrtransa := TO_CHAR(TO_DATE(rw_craprga.hrtransa,'SSSSS'),'hh24:mi');
        vr_tab_resg_aplica(vr_contador).vllanmto := rw_craprga.vlresgat;
        vr_tab_resg_aplica(vr_contador).nraplica := rw_craprga.nraplica;
        vr_tab_resg_aplica(vr_contador).dshistor := rw_craprga.dshistor;
        vr_tab_resg_aplica(vr_contador).nraplica := rw_craprga.nraplica;
        vr_tab_resg_aplica(vr_contador).dtmvtolt := rw_craprga.dtmvtolt;
        vr_tab_resg_aplica(vr_contador).idtipapl := 'N';

        -- Incrementa contador do indice da TT
        vr_contador := vr_contador + 1;
      END LOOP;

      pr_resg_aplica := vr_tab_resg_aplica;

      -- Verifica se deve haver gravacao de log
      IF pr_flgerlog = 1 THEN
        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => SUBSTR(pr_cdoperad,1,10)
                            ,pr_dscritic => SUBSTR(vr_dscritic,1,159)
                            ,pr_dsorigem => SUBSTR(gene0001.vr_vet_des_origens(pr_idorigem),1,13)
                            ,pr_dstransa => SUBSTR(vr_dstransa,1,121)
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na busca de aplicacoes APLI0005.pc_obtem_resgates_conta. Erro: ' || SQLERRM;

    END;
  END pc_obtem_resgates_conta;

  -- Procedure para consulta de proximos resgates via WEB
  PROCEDURE pc_obtem_resg_conta_web(pr_nrdconta IN crapass.nrdconta%TYPE -- Numero da conta
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE -- Sequecia do titular
                                   ,pr_dtmvtolt IN VARCHAR2              -- Data de movimento atual
                                   ,pr_flgcance IN INTEGER               -- Flag de cancelamento
                                   ,pr_flgerlog IN INTEGER               -- Flag de LOG
                                   ,pr_xmllog   IN VARCHAR2              -- XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          -- Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             -- Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    -- Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             -- Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS         -- Erros do processo

   BEGIN
   /* .............................................................................

     Programa: pc_obtem_resg_conta_web
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Jean Michel
     Data    : Marco/15.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente as consultas de resgates proximas.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/

    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis locais
      vr_dtmvtolt DATE; -- Data de movimento atual
      vr_auxconta INTEGER := 0;

      -- Temp Table
      vr_tab_resg_aplica APLI0005.typ_tab_resg_aplica; -- Tem-table com os dados de resgates de aplicacoes

    BEGIN

      vr_dtmvtolt := TO_DATE(pr_dtmvtolt,'dd/mm/RRRR');

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
        RAISE vr_exc_saida;
      END IF;

      /* Procedure para consulta de proximos resgates de aplicacao */
      APLI0005.pc_obtem_resgates_conta(pr_cdcooper    => vr_cdcooper
                                      ,pr_cdagenci    => vr_cdagenci
                                      ,pr_nrdcaixa    => vr_nrdcaixa
                                      ,pr_cdoperad    => vr_cdoperad
                                      ,pr_nmdatela    => vr_nmdatela
                                      ,pr_idorigem    => vr_idorigem
                                      ,pr_nrdconta    => pr_nrdconta
                                      ,pr_idseqttl    => pr_idseqttl
                                      ,pr_dtmvtolt    => vr_dtmvtolt
                                      ,pr_flgcance    => pr_flgcance
                                      ,pr_flgerlog    => pr_flgerlog
                                      ,pr_resg_aplica => vr_tab_resg_aplica
                                      ,pr_cdcritic    => vr_cdcritic
                                      ,pr_dscritic    => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log
      IF vr_dscritic IS NOT NULL OR
         vr_cdcritic <> 0 THEN
        RAISE vr_exc_saida;
      END IF;

      IF vr_tab_resg_aplica.COUNT() > 0 THEN
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

        -- Leitura da tabela temporaria para retornar XML para a WEB
        FOR vr_contador IN vr_tab_resg_aplica.FIRST..vr_tab_resg_aplica.LAST LOOP

          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtresgat', pr_tag_cont => TO_CHAR(vr_tab_resg_aplica(vr_contador).dtresgat,'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dtmvtolt', pr_tag_cont => TO_CHAR(vr_tab_resg_aplica(vr_contador).dtmvtolt,'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrdocmto', pr_tag_cont => TO_CHAR(vr_tab_resg_aplica(vr_contador).nrdocmto), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'tpresgat', pr_tag_cont => TO_CHAR(vr_tab_resg_aplica(vr_contador).tpresgat), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dsresgat', pr_tag_cont => TO_CHAR(vr_tab_resg_aplica(vr_contador).dsresgat), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmoperad', pr_tag_cont => TO_CHAR(vr_tab_resg_aplica(vr_contador).nmoperad), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'hrtransa', pr_tag_cont => TO_CHAR(vr_tab_resg_aplica(vr_contador).hrtransa), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vllanmto', pr_tag_cont => TO_CHAR(vr_tab_resg_aplica(vr_contador).vllanmto), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nraplica', pr_tag_cont => TO_CHAR(vr_tab_resg_aplica(vr_contador).nraplica), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dshistor', pr_tag_cont => TO_CHAR(vr_tab_resg_aplica(vr_contador).dshistor), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nraplica', pr_tag_cont => TO_CHAR(vr_tab_resg_aplica(vr_contador).nraplica), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'idtipapl', pr_tag_cont => TO_CHAR(vr_tab_resg_aplica(vr_contador).idtipapl), pr_des_erro => vr_dscritic);

          -- Incrementa contador p/ posicao no XML
          vr_auxconta := vr_auxconta + 1;
        END LOOP;
      END IF;

      -- Grava efetivamente as informações no BD
      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;


      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em APLI0005.pc_cancela_resgate_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_obtem_resg_conta_web;

  PROCEDURE pc_cadast_varios_resgat_aplica(pr_cdcooper          IN crapcop.cdcooper%TYPE         --> Codigo Cooperativa
                                          ,pr_cdagenci          IN crapass.cdagenci%TYPE         --> Codigo Agencia
                                          ,pr_nrdcaixa          IN INTEGER                       --> Numero do Caixa
                                          ,pr_cdoperad          IN crapope.cdoperad%TYPE         --> Codigo do Operador
                                          ,pr_nmdatela          IN VARCHAR2                      --> Nome da Tela
                                          ,pr_idorigem          IN INTEGER                       --> Origem da solicitacao
                                          ,pr_nrdconta          IN crapass.nrdconta%TYPE         --> Numero da Conta
                                          ,pr_idseqttl          IN crapttl.idseqttl%TYPE         --> Sequencia do Titular
                                          ,pr_dtresgat          IN DATE                          --> Data de resgate
                                          ,pr_flgctain          IN INTEGER                       --> Resgate conta investimento
                                          ,pr_dtmvtolt          IN DATE                          --> Data de movimento
                                          ,pr_dtmvtopr          IN DATE                          --> Proxima data de movimento
                                          ,pr_cdprogra          IN VARCHAR2                      --> Codigo do programa
                                          ,pr_flmensag          IN INTEGER                       --> Flag de mensagem
                                          ,pr_inproces          IN crapdat.inproces%TYPE         --> Indicador do status do sistema
                                          ,pr_flgerlog          IN INTEGER                       --> Gerar Log (0-False / 1-True)
                                          ,pr_tab_resgate       IN APLI0001.typ_tab_resgate      --> PLTable de resgate
                                          ,pr_nrdocmto         OUT VARCHAR2                      --> Numero do documento
                                          ,pr_des_reto         OUT VARCHAR2                      --> Retorno OK/NOK
                                          ,pr_tab_msg_confirma OUT APLI0002.typ_tab_msg_confirma --> PLTable de confirmacao
                                          ,pr_tab_erro         OUT GENE0001.typ_tab_erro) IS     --> PLTable de erros

  BEGIN

  /* .............................................................................

    Programa: pc_cadast_varios_resgat_aplica          Antigo(b1wgen0081.p/cadastrar-varios-resgates-aplicacao)
    Sistema : Novos Produtos de Captacao
    Sigla   : APLI
    Autor   : Jaison Fernando
    Data    : Dezembro/2017.                    Ultima atualizacao: 04/12/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para cadastrar varios resgates de aplicacao.

    Observacao: -----

    Alteracoes: 04/12/2017 - Conversao Progress >> PL/SQL (Oracle). (Jaison/Marcos Martini - PRJ404)

  ..............................................................................*/

    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis locais
      vr_tpresgat VARCHAR2(1);
      vr_nrdocmto craplcm.nrdocmto%TYPE;
      vr_des_reto VARCHAR2(3);
      vr_nrdrowid ROWID;
      vr_vlresgat NUMBER;

    BEGIN
      -- Inicializa
      vr_cdcritic := 0;
      vr_dscritic := NULL;
      vr_vlresgat := 0;

      -- Se possuir registros
      IF NVL(pr_tab_resgate.COUNT,0) > 0 THEN

        FOR ind_registro IN pr_tab_resgate.FIRST..pr_tab_resgate.LAST LOOP

          IF pr_tab_resgate(ind_registro).saldo_rdca.idtipapl = 'A' THEN

            IF pr_tab_resgate(ind_registro).tpresgat = 1 THEN
              vr_tpresgat := 'P';
              vr_vlresgat := pr_tab_resgate(ind_registro).vllanmto;
            ELSE
              vr_tpresgat := 'T';
              vr_vlresgat := 0;
            END IF;

            -- Efetua o resgate da aplicacao
            APLI0002.pc_cad_resgate_aplica(pr_cdcooper => pr_cdcooper
                                          ,pr_cdagenci => pr_cdagenci
                                          ,pr_nrdcaixa => pr_nrdcaixa
                                          ,pr_cdoperad => pr_cdoperad
                                          ,pr_nmdatela => pr_nmdatela
                                          ,pr_idorigem => pr_idorigem
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_nraplica => pr_tab_resgate(ind_registro).saldo_rdca.nraplica
                                          ,pr_idseqttl => pr_idseqttl
                                          ,pr_cdprogra => pr_cdprogra
                                          ,pr_dtmvtolt => pr_dtmvtolt
                                          ,pr_dtmvtopr => pr_dtmvtopr
                                          ,pr_inproces => pr_inproces
                                          ,pr_vlresgat => vr_vlresgat
                                          ,pr_dtresgat => pr_dtresgat
                                          ,pr_flmensag => pr_flmensag
                                          ,pr_tpresgat => vr_tpresgat
                                          ,pr_flgctain => pr_flgctain
                                          ,pr_flgerlog => pr_flgerlog
                                          ,pr_nrdocmto => vr_nrdocmto
                                          ,pr_des_reto => vr_des_reto
                                          ,pr_tbmsconf => pr_tab_msg_confirma
                                          ,pr_tab_erro => pr_tab_erro);

            -- Se ocorreu erro
            IF vr_des_reto = 'NOK' THEN

              -- Se retornar erro na tabela de erros
              IF pr_tab_erro.COUNT > 0 THEN
                vr_cdcritic := pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
                vr_dscritic := pr_tab_erro(pr_tab_erro.FIRST).dscritic;
                pr_tab_erro.DELETE;
              ELSE
                vr_cdcritic := 0;
                vr_dscritic := 'Nao foi possivel listar as aplicacoes.';
              END IF;

              RAISE vr_exc_erro;
            ELSE

              IF TRIM(pr_nrdocmto) IS NULL THEN
                pr_nrdocmto := vr_nrdocmto;
              ELSE
                pr_nrdocmto := pr_nrdocmto  || ';' || vr_nrdocmto;
              END IF;

            END IF;

          ELSIF pr_flmensag = 0 THEN

            -- Chama solicitacao de resgate
            pc_solicita_resgate(pr_cdcooper => pr_cdcooper
                               ,pr_cdoperad => pr_cdoperad
                               ,pr_nmdatela => pr_nmdatela
                               ,pr_idorigem => pr_idorigem
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_idseqttl => pr_idseqttl
                               ,pr_nraplica => pr_tab_resgate(ind_registro).saldo_rdca.nraplica
                               ,pr_cdprodut => pr_tab_resgate(ind_registro).saldo_rdca.cdprodut
                               ,pr_dtresgat => pr_dtresgat
                               ,pr_vlresgat => vr_vlresgat
                               ,pr_idtiprgt => pr_tab_resgate(ind_registro).tpresgat
                               ,pr_idrgtcti => pr_flgctain
                               ,pr_idgerlog => pr_flgerlog
                               ,pr_cdopera2 => ''
                               ,pr_cddsenha => ''
                               ,pr_flgsenha => 0
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
            -- Se houve erro
            IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;

          END IF;

        END LOOP;

      END IF;

      -- Retorno OK
      pr_des_reto := 'OK';

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Se deve gerar log
        IF pr_flgerlog = 1 THEN
          -- Gerar registro de log
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => NULL
                              ,pr_dstransa => NULL
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;

        -- Chamar rotina de gravacao de erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        -- Retorno com problema
        pr_des_reto := 'NOK';

      WHEN OTHERS THEN
        vr_dscritic := 'Erro na APLI0005.pc_cadast_varios_resgat_aplica. ' || SQLERRM;

        -- Se deve gerar log
        IF pr_flgerlog = 1 THEN
          -- Gerar registro de log
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => NULL
                              ,pr_dstransa => NULL
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;

        -- Chamar rotina de gravacao de erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        -- Retorno com problema
        pr_des_reto := 'NOK';
    END;

  END pc_cadast_varios_resgat_aplica;

  PROCEDURE pc_busca_saldo_total_resgate(pr_cdcooper  IN craprac.cdcooper%TYPE           --> Código da Cooperativa
                                        ,pr_cdoperad  IN crapope.cdoperad%TYPE DEFAULT 1 --> Código do Operador
                                        ,pr_nmdatela  IN craptel.nmdatela%TYPE           --> Nome da Tela
                                        ,pr_idorigem  IN INTEGER                         --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                        ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE           --> Numero do Caixa
                                        ,pr_nrdconta  IN craprac.nrdconta%TYPE           --> Número da Conta
                                        ,pr_idseqttl  IN crapttl.idseqttl%TYPE           --> Titular da Conta
                                        ,pr_cdagenci  IN crapage.cdagenci%TYPE           --> Codigo da Agencia
                                        ,pr_cdprogra  IN craplog.cdprogra%TYPE           --> Codigo do Programa
                                        ,pr_nraplica  IN craprac.nraplica%TYPE DEFAULT 0 --> Número da Aplicação - Parâmetro Opcional
                                        ,pr_cdprodut  IN craprac.cdprodut%TYPE DEFAULT 0 --> Código do Produto – Parâmetro Opcional
                                        ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE           --> Data de Movimento
                                        ,pr_idconsul  IN INTEGER                         --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                        ,pr_idgerlog  IN INTEGER                         --> Identificador de Log (0 – Não / 1 – Sim)
                                        ,pr_vlsldisp OUT craprda.vlsdrdca%TYPE           --> Valor do saldo disponivel para resgate
                                        ,pr_cdcritic OUT PLS_INTEGER                     --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2) IS

  BEGIN
    /* .............................................................................

     Programa: pc_busca_saldo_total_resgate
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : Anderson Fossa
     Data    : Abril/18.                        Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina para busca do saldo total para disponivel para resgate
                 de todas as aplicacoes. Utilizado para operacoes no InternetBank e Mobile.
         Baseado no comportamento do InternetBank15.p

     Observacao: -----
    ..............................................................................*/
   DECLARE
     -- Variável de críticas
     vr_cdcritic crapcri.cdcritic%TYPE;
     vr_dscritic VARCHAR2(10000);

     -- Tratamento de erros
     vr_exc_saida EXCEPTION;

     vr_tab_aplica apli0001.typ_tab_saldo_rdca;

     vr_contador PLS_INTEGER;
     vr_flgstapl PLS_INTEGER;
     vr_dstransa VARCHAR2(100) := 'Busca saldo aplicacao';
     vr_dsorigem VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_idorigem);
   vr_nrdrowid ROWID;
    BEGIN
      pr_vlsldisp := 0;

      -- Carrega PL table com aplicacoes da conta
      APLI0005.pc_lista_aplicacoes(pr_cdcooper => pr_cdcooper         --> Código da Cooperativa
                                  ,pr_cdoperad => pr_cdoperad         --> Codigo do Operador
                                  ,pr_nmdatela => pr_nmdatela         --> Nome da tela
                                  ,pr_idorigem => pr_idorigem         --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                  ,pr_nrdcaixa => pr_nrdcaixa         --> Numero do Caixa
                                  ,pr_nrdconta => pr_nrdconta         --> Número da Conta
                                  ,pr_idseqttl => pr_idseqttl         --> Titular da Conta
                                  ,pr_cdagenci => pr_cdagenci         --> Codigo da Agencia
                                  ,pr_cdprogra => pr_nmdatela         --> Codigo do Programa
                                  ,pr_nraplica => pr_nraplica         --> Número da Aplicação - Parâmetro Opcional
                                  ,pr_cdprodut => pr_cdprodut         --> Código do Produto – Parâmetro Opcional
                                  ,pr_dtmvtolt => pr_dtmvtolt         --> Data de Movimento
                                  ,pr_idconsul => pr_idconsul         --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                  ,pr_idgerlog => pr_idgerlog         --> Identificador de Log (0 – Não / 1 – Sim)
                                  ,pr_cdcritic => vr_cdcritic         --> Código da crítica
                                  ,pr_dscritic => vr_dscritic         --> Descrição da crítica
                                  ,pr_saldo_rdca => vr_tab_aplica);   --> Tabela com os dados da aplicação

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      IF vr_tab_aplica.COUNT > 0 THEN
        -- Percorre todas as aplicações de captação da conta
        FOR vr_contador IN vr_tab_aplica.FIRST..vr_tab_aplica.LAST LOOP

          -- verificar se a aplicacao esta bloqueada
          BLOQ0001.pc_busca_blqrgt(pr_cdcooper => pr_cdcooper                         --> Código da cooperativa
                                  ,pr_cdagenci => pr_cdagenci                         --> Código da agência
                                  ,pr_nrdcaixa => pr_nrdcaixa                         --> Número do caixa
                                  ,pr_cdoperad => pr_cdoperad                         --> Código do operador
                                  ,pr_nrdconta => pr_nrdconta                         --> Número da conta
                                  ,pr_tpaplica => vr_tab_aplica(vr_contador).tpaplica --> Tipo da aplicação
                                  ,pr_nraplica => vr_tab_aplica(vr_contador).nraplica --> Número da aplicação
                                  ,pr_dtmvtolt => pr_dtmvtolt                         --> Data de movimento
                                  ,pr_inprodut => vr_tab_aplica(vr_contador).idtipapl --> Identificador de produto (A= Antigo / N=Novo)
                                  ,pr_flgstapl => vr_flgstapl                         --> Status da aplicação
                                  ,pr_cdcritic => vr_cdcritic                         --> Código do erro
                                  ,pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

          IF vr_flgstapl = 0 OR  /* Se estiver bloqueada ou foi incluida neste mesmo dia */
             pr_dtmvtolt = vr_tab_aplica(vr_contador).dtmvtolt THEN
             /* nao considera como saldo disponivel */
             CONTINUE;
          ELSE
            pr_vlsldisp := pr_vlsldisp + vr_tab_aplica(vr_contador).sldresga;
          END IF;

        END LOOP;
      ELSE
        pr_vlsldisp := 0;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Verifica se deve gerar log
        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => pr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
          COMMIT;
        END IF;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na busca do saldo total para resgate APLI0005.pc_busca_saldo_total_resgate: ' || SQLERRM;

        -- Verifica se deve gerar log
        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => pr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
          COMMIT;
        END IF;

    END;
  END pc_busca_saldo_total_resgate;

END APLI0005;
/
