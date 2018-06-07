CREATE OR REPLACE PACKAGE CECRED.DSCT0003 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa:  DSCT0003                       Antiga: generico/procedures/b1wgen0030.p
  --  Autor   : André Ávila - GFT
  --  Data    : Abril/2018                     Ultima Atualizacao: 10/04/2018
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
  ---------------------------------------------------------------------------------------------------------------

  -- Constantes
  vr_cdhistor_credito_dscto_tit CONSTANT craphis.cdhistor%TYPE := 2664; --CREDITO DESCONTO DE TITULO
  vr_cdhistor_liberac_dscto_tit CONSTANT craphis.cdhistor%TYPE := 2665; --LIBERACAO DO CREDITO DESCONTO DE TITULO
  vr_cdhistor_rendapr_dscto_tit CONSTANT craphis.cdhistor%TYPE := 2666; --RENDA A APROPRIAR SOBRE DESCONTO DE TITULO
  
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
                  vlpago   NUMBER(25,2),
                  vlmulta  NUMBER(25,2),
                  vlmora   NUMBER(25,2),
                  vliof    NUMBER(25,2),
                  vlpagar  NUMBER(25,2)
                  );

  TYPE typ_tab_tit_bordero IS TABLE OF typ_rec_tit_bordero
       INDEX BY BINARY_INTEGER;


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
         
  -- Verificar se o bordero está nas novas funcionalidades ou na antiga         
  FUNCTION fn_virada_bordero (pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN INTEGER;
                             
  -- Cálculo da Liquidez Geral
  FUNCTION fn_calcula_liquidez_geral (pr_nrdconta      IN crapass.nrdconta%type
                                      ,pr_cdcooper     IN crapcop.cdcooper%TYPE
                                      ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE
                                      ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                                      ,pr_qtcarpag     IN NUMBER
                                      )RETURN NUMBER;
          
  -- Cálculo da Concentração do título do pagador
  FUNCTION fn_concentracao_titulo_pagador (pr_cdcooper     IN craptdb.cdcooper%TYPE
                                          ,pr_nrdconta     IN craptdb.nrdconta%TYPE
                                          ,pr_nrinssac     IN crapcob.nrinssac%TYPE
                                          ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE 
                                          ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                                          ,pr_qtcarpag     IN NUMBER
                                          ) RETURN NUMBER;
                                
  -- Cálculo da Liquidez do Pagador
  FUNCTION fn_liquidez_pagador_cedente (pr_cdcooper     IN craptdb.cdcooper%TYPE
                                       ,pr_nrdconta     IN craptdb.nrdconta%TYPE
                                       ,pr_nrinssac     IN crapcob.nrinssac%TYPE
                                       ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE 
                                       ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                                       ,pr_qtcarpag     IN NUMBER
                                        ) RETURN NUMBER;

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
                                      ,pr_des_reto OUT VARCHAR2
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
  PROCEDURE pc_virada_bordero (pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
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
                                        
 PROCEDURE pc_calcula_liquidez(pr_cdcooper     IN craptdb.cdcooper%TYPE
                            ,pr_nrdconta     IN craptdb.nrdconta%TYPE
                            ,pr_nrinssac     IN crapcob.nrinssac%TYPE
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
                                        ,pr_vldjuros OUT crapljt.vldjuros%TYPE --> Valor do juros calculado
                                        ,pr_dtrefere OUT DATE                  --> Data de referencia da atualizacao dos juros
                                        ,pr_dscritic OUT VARCHAR2              --> Descrição da critica
                                        );
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
  ---------------------------------------------------------------------------------------------------------------*/

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
      
  --> Cursor para registros de Títulos do Borderô com Restrições ou com outras restrições que não sejam a 59 (CNAE)
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
            abt.nrseqdig <> decode(pr_nrseqdig,59,-1,59));
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

     -- Cursor genérico de calendário
     rw_crapdat btch0001.cr_crapdat%rowtype;
          
      --Tab052
     pr_tab_dados_dsctit cecred.dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052
     pr_tab_cecred_dsctit cecred.dsct0002.typ_tab_cecred_dsctit; -- retorno da TAB052
       
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
          ) RETURN NUMBER IS
   /*---------------------------------------------------------------------------------------------------------------------
     Programa : fn_calcula_liquidez_geral
     Sistema  : 
     Sigla    : CRED
     Autor    : Vitor Shimada Assanuma (GFT)
     Data     : Maio/2018
     Frequencia: Sempre que for chamado
     Objetivo  : Cálculo da Liquidez Geral
   ---------------------------------------------------------------------------------------------------------------------*/
   /* Calculo da Liquidez:
    Soma do Valor de todos os titulos nao pagos dividido pela soma de todos os titulos daquele emitente (nrdconta)
           dentro de um periodo de tempo da liquidez (Dt.Mov - Dias de Liquidez ATE Dt.Mov) levando em conta os dias de
           carencia na data de vencimento.
    (Não considerar como título pago, os liquidados em conta corrente do cedente, ou seja, pagos pelo próprio emitente) */
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
    Objetivo  : Função que retorna a porcentagem de concentracao de titulos daquele pagador em um range de data de liquidez
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
                     ,NULL     
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
    Objetivo  : Função que retorna a porcentagem de liquidez do pagador contra o cedente no range de data
  ---------------------------------------------------------------------------------------------------------------------*/ 
   /* CÁLCULO DA CONCENTRACAO DO PAGADOR
    Soma do Valor de todos os titulos nao pagos dividido pela soma de todos os titulos daquele emitente (nrdconta)
       CONTRA aquele pagador (nrinssac) dentro de um periodo de tempo da liquidez (Dt.Mov - Dias de Liquidez ATE Dt.Mov) 
       levando em conta os dias de carencia na data de vencimento.
    (Não considerar como título pago, os liquidados em conta corrente do cedente, ou seja, pagos pelo próprio emitente) */
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
                 
           ELSIF pr_cddeacao = 'ANALISAR' THEN
                 IF  rw_crapbdt.insitbdt > 2 OR (rw_crapbdt.insitapr IN (2,6,7)) THEN
                     vr_dscritic := 'Análise não permitida. O Borderô deve estar na situação EM ESTUDO ou ANALISADO.';
                     CLOSE cr_crapbdt;
                     RAISE vr_exc_erro;
                 END IF;

           ELSIF pr_cddeacao = 'REJEITAR' THEN
                 IF  rw_crapbdt.insitbdt <> 1 OR (rw_crapbdt.insitapr <> 5 AND (rw_crapbdt.insitapr<>0 OR rw_crapbdt.dtenvmch IS NULL)) THEN
                     vr_dscritic := 'Rejeição não permitida. O Borderô deve estar na situação EM ESTUDO e decisão NÃO APROVADO.';
                     CLOSE cr_crapbdt;
                     RAISE vr_exc_erro;
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

    ---------------------------------------------------------------------------------------------------------------------*/
    vr_dia      INTEGER;
    vr_qtd_dias NUMBER;
    vr_dtrefere DATE;
    vr_vldjuros crapljt.vldjuros%TYPE;

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
    WHERE  crapljt.dtrefere = pr_dtrefere
    AND    crapljt.nrdocmto = pr_nrdocmto
    AND    crapljt.cdbandoc = pr_cdbandoc
    AND    crapljt.nrdctabb = pr_nrdctabb
    AND    crapljt.nrdconta = pr_nrdconta
    AND    crapljt.cdcooper = pr_cdcooper;
    rw_crapljt cr_crapljt%rowtype;

  BEGIN
    vr_qtd_dias := ccet0001.fn_diff_datas(to_date(pr_dtvencto,'DD/MM/RRRR'), to_date(pr_dtmvtolt,'DD/MM/RRRR'));
    vr_vldjuros := 0;
    vr_dtrefere := last_day(pr_dtmvtolt);

    --  Percorre a quantidade de dias baseado na data atual até o vencimento do título
    FOR vr_dia IN 0..vr_qtd_dias LOOP

        vr_dtrefere := last_day(pr_dtmvtolt + vr_dia);

        -- Calcula o juros do título do borderô para o dia
        vr_vldjuros := pr_vltitulo * vr_dia * ((pr_txmensal / 100) / 30);
        
        BEGIN
          OPEN  cr_crapljt(vr_dtrefere);
          FETCH cr_crapljt INTO rw_crapljt;
          --    Se já foi lançado juros para este período, atualiza a tabela de lançamento de juros 
          IF    cr_crapljt%FOUND THEN

                UPDATE crapljt
                SET    crapljt.vldjuros = vr_vldjuros
                WHERE  crapljt.rowid=rw_crapljt.rowid;
            
          --    Caso contrário, insere novo registro
          ELSE
                INSERT INTO crapljt
                       (cdcooper
                       ,nrdconta
                       ,nrborder
                       ,dtrefere
                       ,cdbandoc
                       ,nrdctabb
                       ,nrcnvcob
                       ,nrdocmto
                       ,vldjuros)
                VALUES (pr_cdcooper
                       ,pr_nrdconta
                       ,pr_nrborder
                       ,vr_dtrefere
                       ,pr_cdbandoc
                       ,pr_nrdctabb
                       ,pr_nrcnvcob
                       ,pr_nrdocmto
                       ,vr_vldjuros );
          END   IF;
          CLOSE cr_crapljt;
        EXCEPTION
          WHEN OTHERS THEN
               vr_dscritic := 'Erro ao atualizar os juros calculado do título do borderô: '||SQLERRM;
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
     Programa : pc_calcula_valores_bordero        Antigo: b1wgen0030.p/efetua_liber_anali_bordero (Trecho de Liberação)
     Sistema  : 
     Sigla    : CRED
     Autor    : Lucas Lazari (GFT) 
     Data     : Abril/2018
   
     Objetivo  : Procedure para calcular os valores líquido e bruto do borderô, bem como realizar o lançamento dos juros

     Alteracoes: 16/04/2018 - Criação (Lucas Lazari (GFT))
   ----------------------------------------------------------------------------------------------------------*/
                                     
  BEGIN
    DECLARE
    -- Variáveis Locais
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
                           ,pr_dtmvtolt craplcm.dtmvtolt%TYPE) IS
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
         AND craptdb.insittit = 0;
    rw_base_calculo cr_base_calculo%ROWTYPE;
    
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
    
    BEGIN
      
      vr_dtmvtolt := to_date(pr_dtmvtolt, 'DD/MM/RRRR');
      
      open cr_crapbdt;
      fetch cr_crapbdt into rw_crapbdt;
      
      vr_vltotliq := 0;
      vr_vltotbrt := 0;
      vr_vltotjur := 0;
      FOR rw_base_calculo IN
        cr_base_calculo (pr_cdcooper => pr_cdcooper
                        ,pr_nrborder => pr_nrborder
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_dtmvtolt => vr_dtmvtolt) LOOP
                        
        pc_calcula_juros_simples_tit(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrborder
                                    ,pr_nrborder => pr_nrdconta
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
          
        -- Aproveita o loop do cursor de títulos do borderô para atualizar as informações no banco
        UPDATE craptdb
        SET    craptdb.vlliquid = ROUND((rw_base_calculo.vltitulo - vr_vldjuros),2),
               craptdb.dtlibbdt = vr_dtmvtolt,
               craptdb.insittit = 4,
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
          -- Registra log de cobrança para o títulos  
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
      
    END;
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
        SET    vliofprc	= vr_vliofpri
              ,vliofadc	= vr_vliofadi
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
      
      --Se não encontrar o registro de cotas do usuário, lança o erro
      IF cr_crapcot%NOTFOUND THEN
        CLOSE cr_crapcot;
        vr_dscritic:= 'Registro crapcot não encontrado.';
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
      
      -- Gerar erro caso não encontre
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
             
             -- Gera exceção
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
            
            -- Gera exceção
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
                    ,2320
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
            
            -- Gera exceção
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
        pr_dscritic := vr_dscritic;
    
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
                                  ,pr_cdagenci IN crawlim.cdagenci%TYPE --> Código da Agência
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
         INNER JOIN cecred.crapbdt bdtold
           ON bdtold.nrborder = tdbold.nrborder
           AND bdtold.cdcooper = tdbold.cdcooper
           AND bdtold.nrdconta = tdbold.nrdconta
         WHERE tdban.cdcooper = pr_cdcooper
           AND tdban.nrborder = pr_nrborder
           AND tdbold.insittit in (0,2,4)
           AND bdtold.insitbdt<>5; -- diferente de reiejtado

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
--        EXECUTE IMMEDIATE('DELETE FROM crapabt abt WHERE abt.cdcooper = '|| pr_cdcooper||' AND abt.nrborder = '||pr_nrborder);
        DELETE FROM crapabt abt
         WHERE abt.cdcooper = pr_cdcooper
           AND abt.nrborder = pr_nrborder;
      END;

      --  INVALORMAX_CNAE    : Valor Máximo Permitido por CNAE excedido (0 = Não / 1 = Sim). (Ref. TAB052: vlmxprat)
      IF  vr_tab_dados_dsctit_cr (1).vlmxprat = 1 then
        OPEN cr_cnae(pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrborder => pr_nrborder);
        LOOP
        FETCH cr_cnae INTO rw_cnae;
            -- Caso não ache um proximo registro, da EXIT
            IF cr_cnae%FOUND THEN
              -- Caso nao tenha restricoes sai do loop
              IF NOT fn_calcula_cnae(pr_cdcooper
                                ,pr_nrdconta
                                ,rw_cnae.nrdocmto
                                ,rw_cnae.nrcnvcob   
                                ,rw_cnae.nrdctabb
                                ,rw_cnae.cdbandoc
                 )THEN EXIT;
              ELSE
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
                  vr_flgtrans := FALSE;
                  vr_nrseqdig := 0;
                  vr_dsrestri := '';
                END IF;
                IF  TRIM(vr_dscritic) IS NOT NULL THEN
                  RAISE vr_exc_erro;
                END IF;
              END IF;
            ELSE
              EXIT;
            END IF;
        END LOOP;
        CLOSE cr_cnae; 
      END IF;

      -- Gerando as Restrições no Borderô por Status do Pagamento de Cobração para Tìtulo desse Borderô, se houver.
      FOR rw_craptdb_cob IN cr_craptdb_cob (pr_cdcooper => pr_cdcooper,
                                            pr_nrdconta => pr_nrdconta,
                                            pr_nrborder => pr_nrborder) LOOP
        -- a cada título, é zerada a sequência pois podem haver N restrições para o mesmo título.
        vr_nrseqdig := 0;
        vr_dsrestri := '';
        
        /* Andrew Albuquerque (GFT) 26/04/2018 - Estas validação são impeditivas e foram movidas para a pc_efetua_analise_bordero
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
          vr_dscritic := 'Título já foi pago.';
          raise vr_exc_erro;
        END IF;

        IF rw_craptdb_cob.incobran = 3 THEN
          -- Se o Tìtulo já foi baixado por COBRANÇA.
          vr_dsrestri := 'Titulo baixado.';
          IF rw_craptdb_cob.flgregis = 1 THEN
            vr_nrseqdig := 53;
          ELSE
            vr_nrseqdig := 3;
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
          vr_dscritic := 'Título baixado.';
          raise vr_exc_erro;
        END IF;*/

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
            (vr_vltotsac_sr > 0 AND ((vr_vltotsac_sr / vr_vltotbdt_sr) *100) > vr_tab_dados_dsctit_sr(1).pcmxctip) THEN -- era pctitemi
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
          vr_dsrestri := 'Coop com titulos protestados acima do permitido.';
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
          vr_dsrestri := 'Coop com titulos não pagos acima do permitido.';
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
              FOR rw_craptdb_restri IN
                cr_craptdb_restri (pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrborder => pr_nrborder) LOOP
                -- aproveita o loop de títulos para alterar o status para Enviado para Esteira IBRATAN.
                UPDATE craptdb
                   set craptdb.insitapr = 0 -- 0-Aguardando Análise
                      ,craptdb.cdoriapr = 2 -- 2-Esteira IBRATAN
                 WHERE craptdb.rowid = rw_craptdb_restri.rowid;
              END LOOP;

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
      
                  27/04/2018 - Andrew Albuquerque (GFT) - Alterações para contemplar Mesa de Checagem e Esteira IBRATAN

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
      
      vr_datacorte crapprm.dsvlrprm%TYPE;
      
      vr_em_contingencia_ibratan boolean;
      
      
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

      CURSOR cr_crapprm (pr_cdcooper IN crapprm.cdcooper%TYPE) IS
      SELECT c.dsvlrprm
        FROM crapprm c
       WHERE c.nmsistem = 'CRED'
         AND c.cdcooper = pr_cdcooper
         AND c.cdacesso = 'DT_CALC_JUR_SIMP_BORD';
      rw_crapprm cr_crapprm%ROWTYPE;
      
      CURSOR cr_datacorte (pr_cdcooper IN craptdb.cdcooper%TYPE
                          ,pr_nrborder IN craptdb.nrborder%TYPE
                          ,pr_nrdconta IN craptdb.nrdconta%TYPE
                          ,pr_datacorte IN VARCHAR2) IS
      SELECT DISTINCT 1 AS QTDE
        FROM CRAPBDT T
       WHERE T.CDCOOPER = pr_cdcooper
         AND T.NRBORDER = pr_nrborder
         AND T.NRDCONTA = pr_nrdconta
         AND T.DTMVTOLT < to_date(pr_datacorte,'dd/mm/rrrr');
      rw_datacorte cr_datacorte%ROWTYPE;
      
      
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
      
      vr_datacorte := '';
            
      -- Verifica Se existe algum título no borderô com data de corte abaixo da data de inicio do processo novo.
      vr_dscritic := '';
      OPEN cr_crapprm (pr_cdcooper => pr_cdcooper);
      FETCH cr_crapprm INTO rw_crapprm;
      -- Se existir o Parametro, faz a validação.
      IF cr_crapprm%FOUND THEN
        vr_datacorte := rw_crapprm.dsvlrprm;
        OPEN cr_datacorte (pr_cdcooper => pr_cdcooper
                          ,pr_nrborder => pr_nrborder
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_datacorte => vr_datacorte);
        FETCH cr_datacorte INTO rw_datacorte;
        IF cr_datacorte%FOUND THEN
          vr_dscritic := 'Operação não permitida - borderô incluído no processo antigo.';
          CLOSE cr_datacorte;
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_datacorte;
        END IF;        
        CLOSE cr_crapprm;
      ELSE
        CLOSE cr_crapprm;
      END IF;
      
      -- Verificações Impeditivas Para Títulos
      FOR rw_craptdbcob IN cr_craptdbcob (pr_cdcooper => pr_cdcooper,
                                          pr_nrdconta => pr_nrdconta,
                                          pr_nrborder => pr_nrborder) LOOP
        IF rw_craptdbcob.dtvencto <= pr_dtmvtolt THEN
          vr_dscritic := 'Há titulos com data de liberacao igual ou inferior a data do movimento.';
          RAISE vr_exc_erro;
        END IF;

        IF rw_craptdbcob.incobran = 5 THEN
          -- Se o Tìtulo já foi pago por COBRANÇA.
          vr_dscritic := 'Há títulos já pago no Borderô.';
          raise vr_exc_erro;
        END IF;

        IF rw_craptdbcob.incobran = 3 THEN
          -- Se o Tìtulo já foi baixado por COBRANÇA.
          vr_dscritic := 'Há Título já baixado no Borderô.';
          raise vr_exc_erro;
        END IF;
      END LOOP;
      
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
                                 ,pr_des_reto =>  vr_des_reto
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
          
          -- ALTERO STATUS DO BORDERÔ PARA APROVADO AUTOMATICAMENTE.
          pc_altera_status_bordero(pr_cdcooper => pr_cdcooper
                                  ,pr_nrborder => pr_nrborder
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_status   => 2 -- estou considerando 2 como aprovado automaticamente (aprovação de análise).
                                  ,pr_dscritic => vr_dscritic
                                  ,pr_insitapr => 3
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
 
        ELSIF vr_indrestr > 0 THEN -- SE POSSUI RESTRIÇÃO, AVALIA SE DEVE MANDAR PARA ESTEIRA OU MESA DE CHECAGEM.
          -- Verifica se Possui Restrição de CNAE (nrseqdig=59)
          OPEN cr_crapabt_qtde (pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrborder => pr_nrborder
                               ,pr_nrseqdig => 59); -- 59 - nrseqdig de Restrição de CNAE
          --Posicionar no proximo registro
          FETCH cr_crapabt_qtde INTO rw_crapabt_qtde;
          -- Se encontrou, busca todos os títulos que possuem Restrição de CNAE, altera seus status enviando para 
          -- a Mesa de Checagem, e altera o status do borderô para enviado para mesa de checagem, bem como seta seus campos
          -- de status de análise.
          OPEN cr_crapbdt;
          FETCH cr_crapbdt INTO rw_crapbdt;
          IF (cr_crapabt_qtde%FOUND AND rw_crapbdt.dtenvmch IS NULL) THEN -- Possui crítica de CNAE E NÃO passou pela mesa ainda
            -- carrega todos os Títulos que estão com Restrição de CNAE (59)
            FOR rw_craptdb_restri IN
              cr_craptdb_restri (pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrborder => pr_nrborder
                                ,pr_nrseqdig => 59) LOOP
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
                                    ,pr_status   => 1 -- 1-Em Estudo
                                    ,pr_insitapr => 1 -- 1-Aguardando Checagem
                                    ,pr_dtenvmch => pr_dtmvtolt
                                    ,pr_dscritic => vr_dscritic); -- Descricao Critica
            IF vr_dscritic IS NOT NULL THEN
              pr_tab_retorno_analise.DELETE;
              CLOSE cr_crapabt_qtde;
              RAISE vr_exc_erro;
            END IF;
          ELSE -- SE EXISTEM RESTRIÇÕES E NENHUMA É DE CNAE (59), ENVIAR PARA A ESTEIRA, CASO A ESTEIRA NÃO ESTEJA EM CONTINGÊNCIA.
            CLOSE cr_crapabt_qtde;
            rw_crapabt_qtde := null;

            vr_em_contingencia_ibratan := tela_atenda_dscto_tit.fn_em_contingencia_ibratan(pr_cdcooper => pr_cdcooper);	
            
            -- awae 25/04/2018 - Caso esteja em contingência, não será aprovado e nem enviado para esteira, e emite a mensagem de 
            --                   que está em contingência.
            IF  vr_em_contingencia_ibratan THEN -- Em Contingência
              -- Não faz a alteração de Situação do Borderô para "Aprovado", e retorna mensagem de contingência.
              pc_grava_restricao_bordero (pr_nrborder => pr_nrborder
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_dsrestri => 'Análise em Contingência, realize análise manual.'
                                         ,pr_nrseqdig => 0
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_flaprcoo => 1
                                         ,pr_dsdetres => ''
                                         ,pr_dscritic => vr_dscritic);
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
          END IF;
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

    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

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
      
      pc_valida_bordero(pr_cdcooper => vr_cdcooper
                       ,pr_nrborder => pr_nrborder
                       ,pr_cddeacao => 'ANALISAR'
                       ,pr_dscritic => vr_dscritic);
      
      IF (vr_dscritic IS NOT NULL) THEN
         raise vr_exc_erro;
      END IF;
      
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
                                ,pr_inrotina => 1 -- 1-IMPEDITIVA+RESTRIÇÕES COM APROVAÇÃO DE ANÁLISE
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

      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;

      /*Passou nas validações do bordero, do contrato e listou titulos. Começa a montar o xml*/
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
                                          ,pr_cdagenci => 1                     --> Codigo Agencia
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
          
          
          if  vr_cdcritic > 0 or trim(vr_dscritic) is not null then
             if  vr_tab_erro.count() > 0 THEN
                 vr_dscritic:= vr_tab_erro(vr_tab_erro.first).dscritic;
             ELSE
                 vr_dscritic:= 'Erro no Lançamento da Tarifa de Borderô de Desconto de Título';
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
  
  PROCEDURE pc_lanca_credito_bordero(pr_dtmvtolt IN craplcm.dtmvtolt%TYPE -- Origem: do lote de liberação (craplot)
                                    ,pr_cdagenci IN craplcm.cdagenci%TYPE -- Origem: do lote de liberação (craplot)
                                    ,pr_cdbccxlt IN craplcm.cdbccxlt%TYPE -- Origem: do lote de liberação (craplot)
                                    ,pr_nrdconta IN craplcm.nrdconta%TYPE -- Origem: nrdconta do Bordero
                                    ,pr_vllanmto IN craplcm.vllanmto%TYPE -- Origem: do cálculo :aux_vlborder + craptdb.vlliquid da linha 1870.
                                    ,pr_cdcooper IN craplcm.cdcooper%TYPE
                                    ,pr_cdoperad IN crapbdt.cdoperad%TYPE --> Operador
                                    ,pr_nrborder IN crapbdt.nrborder%TYPE -- Origem: Bordero
                                    ,pr_cdpactra IN crapope.cdpactra%TYPE
                                    ,pr_dscritic    OUT VARCHAR2          --> Descricao Critica
                                    ) IS
  BEGIN

   /*-------------------------------------------------------------------------------------------------------
     Programa : pc_lanca_tarifa_bordero        Antigo: b1wgen0030.p/efetua_liber_anali_bordero (Trecho de Liberação)
     Sistema  : Procedure para lançar crédito de desconto de Título
     Sigla    : CRED
     Autor    : Andrew Albuquerque (GFT) 
     Data     : Abril/2018
   
     Objetivo  : Procedure para laçamento de crédito de desconto de Título.

     Alteracoes: 16/04/2018 - Criação (Andrew Albuquerque (GFT))
   ----------------------------------------------------------------------------------------------------------*/
    DECLARE
        
    vr_nrdolote craplot.nrdolote%TYPE;
      
    -- Variável de críticas
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

      -- Gerar erro caso não encontre
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
                      ,vr_cdhistor_credito_dscto_tit)
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
             -- Gera exceção
             RAISE vr_exc_erro;

         END;
      ELSE
         -- Apenas fechar o cursor
         CLOSE cr_craplot;
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
               ,/*06*/ rw_craplot.nrseqdig +1
               ,/*07*/ pr_vllanmto --  do cálculo :aux_vlborder + craptdb.vlliquid da linha 1870.
               ,/*08*/ vr_cdhistor_credito_dscto_tit
               ,/*09*/ rw_craplot.nrseqdig +1
               ,/*10*/ pr_nrdconta
               ,/*11*/ 0
               ,/*12*/ pr_cdcooper
               ,/*13*/ 'Desconto do Borderô ' || pr_nrborder)
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
          -- Gera exceção
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

          -- Gera exceção
          RAISE vr_exc_erro;
      END;
    
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao Realizar Lançamento de Crédito de Desconto de Títulos: '||' '||vr_dscritic||' '||sqlerrm;
    END;
  END pc_lanca_credito_bordero;
    
  PROCEDURE pc_liberar_bordero (pr_cdcooper IN craptdb.cdcooper%TYPE --> Código da Cooperativa
                               ,pr_cdagenci IN crapass.cdagenci%type --> Código da Agência
                               ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Numero Caixa
                               ,pr_cdoperad IN craptdb.cdoperad%TYPE --> Operador
                               ,pr_nmdatela IN craplgm.nmdatela%TYPE --> Nome da tela.
                               ,pr_idorigem IN VARCHAR2              --> Identificador Origem pagamento
                               ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                               ,pr_idseqttl IN INTEGER               --> idseqttl
                               ,pr_nrborder IN crapbdt.nrborder%TYPE --> numero do bordero
                               ,pr_dtmvtolt IN VARCHAR2              --> Data do movimento
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
  ---------------------------------------------------------------------------------------------------------------------*/
  
  BEGIN
    DECLARE
    -- Variáveis de Uso Local
    vr_dsorigem VARCHAR2(40)  DEFAULT NULL; --> Descrição da Origem
    vr_dstransa VARCHAR2(100) DEFAULT NULL; --> Descrição da trasaçao para log

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
                             
        
  BEGIN
    
    --Seta as variáveis de Descrição de Origem e descrição de Transação se For gerar Log
    IF pr_flgerlog THEN
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa := 'Liberar o Borderô ' || pr_nrborder || ' de Desconto de Título.';
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
                               ,pr_dscritic => vr_dscritic
                               );
    
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
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
    
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
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
                            ,pr_cdpactra => 0 
                            ,pr_dscritic => vr_dscritic 
                            );
    
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Lançar operação de desconto, valor bruto do borderô
    pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrborder => pr_nrborder
                                 ,pr_dtmvtolt => pr_dtmvtolt
                                 ,pr_cdorigem => 5
                                 ,pr_cdhistor => vr_cdhistor_liberac_dscto_tit
                                 ,pr_vllanmto => vr_vltotbrt
                                 ,pr_dscritic => vr_dscritic );
    
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- Lançar operação de desconto, valor do juros calculado
    pc_inserir_lancamento_bordero(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrborder => pr_nrborder
                                 ,pr_dtmvtolt => pr_dtmvtolt
                                 ,pr_cdorigem => 5
                                 ,pr_cdhistor => vr_cdhistor_rendapr_dscto_tit
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
          
          ROLLBACK;
    WHEN OTHERS THEN
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := replace(replace('Erro pc_liberar_bordero: ' || sqlerrm, chr(13)),chr(10));
          
         ROLLBACK;
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

    -- variaveis de data
    vr_dtmvtopr crapdat.dtmvtolt%TYPE;
    vr_dtmvtolt crapdat.dtmvtolt%TYPE;

    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

--    vr_em_contingencia_ibratan boolean;
    
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
      --vr_msgcontingencia := '';
      vr_msgretorno := '';
      
      -- Valida se a situação do borderô permite liberação
      pc_valida_bordero(pr_cdcooper => vr_cdcooper
                       ,pr_nrborder => pr_nrborder
                       ,pr_cddeacao => 'LIBERAR'
                       ,pr_dscritic => vr_dscritic);
      
      IF (vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL) THEN
         raise vr_exc_erro;
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
      
      -- Se o borderô possui restrições e o operador está tentando liberar pela primeira vez, retorna a mensagem abaixo
      IF vr_indrestr = 1 AND pr_confirma = 0 THEN
        vr_msgretorno := 'Há restrições no borderô. Deseja realizar a liberação mesmo assim?';
      ELSE    
        
        -- Caso o operador tenha decidido liberar o borderô (com ou sem restrições) chama a rotina principal de liberação do borderô                        
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
        
        -- Ajusta a mensagem de confirmação conforme a existência de restrições no borderô
        IF vr_indrestr = 1 THEN
           vr_msgretorno := 'Borderô liberado COM restrições! Valor líquido de R$' || TRIM(to_char(vr_vltotliq, 'FM999G999G999G990D00'));
        ELSE
           vr_msgretorno := 'Borderô liberado SEM restrições! Valor líquido de R$' || TRIM(to_char(vr_vltotliq, 'FM999G999G999G990D00'));
        END IF;  
        
        /*
        -- Verificar se a esteira e/ou motor estão em contigencia e armazenar na variavel
        vr_em_contingencia_ibratan := tela_atenda_dscto_tit.fn_em_contingencia_ibratan(pr_cdcooper => vr_cdcooper);
        
        IF  vr_em_contingencia_ibratan THEN -- Em Contingência
          vr_msgcontingencia := 'Análise em contingência, consulta aos birôs não realizada. ' || CHR(13);
        END IF;
      */  
      END IF;
      
      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;
      
      /*Passou nas validações do bordero, do contrato e listou titulos. Começa a montar o xml*/
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||

                     '<root><dados>');
      
      pc_escreve_xml('<msgretorno>' || vr_msgretorno || '</msgretorno>');
      pc_escreve_xml('<indrestr>' || vr_indrestr || '</indrestr>');
                    
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
                                           '<Root>' || 
                                             '<Erro>' || pr_dscritic || '</Erro>' || 
                                          '</Root>');
      when others then
           /* montar descriçao de erro não tratado */
           pr_dscritic := 'Erro não tratado na dsct0003.pc_liberar_bordero_web ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
   END pc_liberar_bordero_web;
   
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
     
     BEGIN
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
                                            '<Root>' || 
                                              '<Erro>' || pr_dscritic || '</Erro>' || 
                                           '</Root>');
        when others then
             /* montar descriçao de erro não tratado */
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

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  BEGIN		
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
                            ,pr_cdoperej => vr_cdoperad                -- cdoperad que efetuou a rejeição
                            ,pr_dtrejeit => rw_crapdat.dtmvtolt        -- data de rejeição
                            ,pr_hrrejeit => to_char(sysdate,'SSSSS')   -- hora de rejeião
	                          ,pr_dscritic => vr_dscritic                --se houver registro de crítica
                            );
                                
    IF  vr_dscritic IS NOT NULL THEN
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
  
  
  PROCEDURE pc_virada_bordero (pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
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
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;

      /*Passou nas validações do bordero, do contrato e listou titulos. Começa a montar o xml*/
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados>');

      pc_escreve_xml('<cdcooper>' || vr_cdcooper || '</cdcooper>' ||
                     '<flgverbor>' || vr_flgverbor || '</flgverbor>');
                    
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
       SELECT  (vltitulo - vlsldtit) AS vlpago
              ,(vlmtatit - vlpagmta) AS vlmulta
              ,(vlmratit - vlpagmra) AS vlmora
              ,(vliofcpl - vlpagiof) AS vliof
              ,(vlsldtit + (vlmtatit - vlpagmta) + (vlmratit - vlpagmra)+ (vliofcpl - vlpagiof)) AS  vlpagar
              ,tdb.*
       FROM  craptdb tdb
       WHERE    tdb.dtresgat IS NULL      -- Nao resgatado
         AND    tdb.dtlibbdt IS NOT NULL
         AND    tdb.dtdpagto IS NULL      -- Nao pago
         AND    tdb.dtvencto < (pr_dtmvtolt+360) --Adicionado 360 apenas para teste, remover
         AND    tdb.nrborder = pr_nrborder
         AND    tdb.nrdconta = pr_nrdconta
         AND    tdb.cdcooper = pr_cdcooper
       ;
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
     
     -- Cursor genérico de calendário
     rw_crapdat btch0001.cr_crapdat%rowtype;
     
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
                        '</inf>'
                      );
         vr_index := vr_tab_tit_bordero.next(vr_index);
       END LOOP;
       pc_escreve_xml ('</dados></root>',true);
       pr_retxml := xmltype.createxml(vr_des_xml); 
        
       /* liberando a memória alocada pro clob */
       dbms_lob.close(vr_des_xml);
       dbms_lob.freetemporary(vr_des_xml);         
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
                  
     -- Cursor genérico de calendário
     rw_crapdat btch0001.cr_crapdat%ROWTYPE;
         
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
                              
      -- Leitura do calendário da cooperativa
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
       
       
       -- Caso o saldo seja maior que o custo da soma dos titulos
       IF vr_total <= pr_tab_sald(0).vlsddisp THEN
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
 END pc_calcula_possui_saldo;

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
     ---------------------------------------------------------------------------------------------------------------------*/
     -- Variável de críticas
     vr_dscritic varchar2(1000);        --> Desc. Erro
          
     -- Cursor genérico de calendário
     rw_crapdat btch0001.cr_crapdat%rowtype;
     
     -- Variaveis de entrada vindas no XML
     vr_cdcooper INTEGER;
     vr_nmdatela VARCHAR2(100);
     vr_nmeacao  VARCHAR2(100);
     vr_cdagenci VARCHAR2(100);
     vr_nrdcaixa VARCHAR2(100);
     vr_idorigem VARCHAR2(100);
     vr_cdoperad VARCHAR2(100);
     
     
     vr_nrdolote craplot.nrdolote%TYPE;      
     vr_exc_erro EXCEPTION;
     vr_rowid    ROWID;
     vr_sql      VARCHAR2(32767);
     
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
     
     -- Cursor dos titulos para ser preenchido pelo comando SQL dentro do programa
     CURSOR cr_craptdb IS
            SELECT (vlsldtit + (vlmtatit - vlpagmta) + (vlmratit - vlpagmra)+ (vliofcpl - vlpagiof)) AS valor,
                   craptdb.* 
            FROM craptdb
     ;rw_craptdb cr_craptdb%ROWTYPE;
     
     -- Historicos
     arr_hist               dbms_sql.varchar2_table;
     arr_hist_lanc_bordero  dbms_sql.varchar2_table;
     
     -- Registros para armazenar dados do lancamento gerado
     rw_craplcm craplcm%ROWTYPE;    
     
     -- Variavel do array dos titulos
     vr_index     INTEGER;
     vr_index2    INTEGER;
     
     type tpy_ref_tdb is ref cursor;
     cr_tab_tdb       tpy_ref_tdb;
     
     BEGIN
        -- Caso seja pagamento com avalista muda as insercoes
        IF pr_flavalista = 'false' THEN
          -- Historico dos cooperados SEM avalista
          arr_hist(0) := 2681; -- PAGTO DE MULTA SOBRE DESCONTO DE TITULO
          arr_hist(1) := 2685; -- PAGTO DE JUROS MORA SOBRE DESCONTO DE TITULO
          arr_hist(2) := 2670; -- PAGTO DESCONTO DE TITULO
          arr_hist(3) := 2321; -- Valor do IOF complementar atraso       
          
          -- Historico dos Descontos SEM avalista
          arr_hist_lanc_bordero(0) := 2682; -- PAGTO DE MULTA SOBRE DESCONTO DE TITULO
          arr_hist_lanc_bordero(1) := 2686; -- PAGTO DE JUROS MORA SOBRE DESCONTO DE TITULO
          arr_hist_lanc_bordero(2) := 2671; -- PAGTO DESCONTO DE TITULO
        ELSE  
          -- Historico dos cooperados COM avalista
          arr_hist(0) := 2683; -- PAGTO DE MULTA SOBRE DESCONTO DE TITULO AVAL
          arr_hist(1) := 2687; -- AGTO DE JUROS MORA SOBRE DESCONTO DE TITULO AVAL
          arr_hist(2) := 2674; -- PAGTO DESCONTO DE TITULO AVAL
          arr_hist(3) := 2321; -- Valor do IOF complementar atraso
            
          -- Historico dos Descontos COM avalista
          arr_hist_lanc_bordero(0) := 2684; -- PAGTO DE MULTA SOBRE DESCONTO DE TITULO AVAL
          arr_hist_lanc_bordero(1) := 2688; -- PAGTO DE JUROS MORA SOBRE DESCONTO DE TITULO AVAL
          arr_hist_lanc_bordero(2) := 2675; -- PAGTO DESCONTO DE TITULO AVAL
        END IF;

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
        vr_sql := 'SELECT (vlsldtit + (vlmtatit - vlpagmta) + (vlmratit - vlpagmra)+ (vliofcpl - vlpagiof)) AS valor,' ||
                          ' craptdb.* '||
                     ' FROM craptdb '||
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
          EXIT WHEN cr_tab_tdb%NOTFOUND;    
              vr_index := 0;
              FOR vr_index IN 0..arr_hist_lanc_bordero.count-1 LOOP
                  pc_inserir_lancamento_bordero(pr_cdcooper => vr_cdcooper
                                               ,pr_nrdconta => pr_nrdconta
                                               ,pr_nrborder => pr_nrborder
                                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                               ,pr_cdorigem => 5
                                               ,pr_cdhistor => arr_hist_lanc_bordero(vr_index)
                                               ,pr_vllanmto => rw_craptdb.valor
                                               ,pr_cdbandoc => rw_craptdb.cdbandoc
                                               ,pr_nrdctabb => rw_craptdb.nrdctabb
                                               ,pr_nrcnvcob => rw_craptdb.nrcnvcob
                                               ,pr_nrdocmto => rw_craptdb.nrdocmto
                                               ,pr_nrtitulo => rw_craptdb.nrtitulo
                                               ,pr_dscritic => vr_dscritic );
                  IF  TRIM(vr_dscritic) IS NOT NULL THEN
                      RAISE vr_exc_erro;
                  END IF;
                END LOOP;     
                
                -- Loop por todos os historicos que irao ser inseridos n craplcm
                vr_index2 := 0;          
                FOR vr_index2 IN 0..arr_hist.count-1 LOOP   
                  -- Cria o numero do lote
                  vr_nrdolote := fn_sequence(pr_nmtabela => 'CRAPLOT'
                                            ,pr_nmdcampo => 'NRDOLOTE'
                                            ,pr_dsdchave => TO_CHAR(vr_cdcooper)|| ';' 
                                             || rw_crapdat.dtmvtolt || ';'
                                             || TO_CHAR(vr_cdagenci)|| ';'
                                             || '100');
                                                 
                  
                  --Buscar o lote
                  OPEN cr_craplot(pr_cdcooper => vr_cdcooper
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                 ,pr_cdagenci => 1
                                 ,pr_cdbccxlt => 100 -- Ver o numero
                                 ,pr_nrdolote => vr_nrdolote);

                  FETCH cr_craplot INTO rw_craplot;

                  -- Gerar erro caso não encontre
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
                               VALUES(vr_cdcooper
                                      ,rw_crapdat.dtmvtolt
                                      ,1
                                      ,100
                                      ,vr_nrdolote
                                      ,1
                                      ,vr_cdoperad
                                      ,arr_hist(vr_index)) -- Numero do historico
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
                             -- Gera exceção
                             RAISE vr_exc_erro;
                         END;
                    ELSE
                       -- Apenas fechar o cursor
                       CLOSE cr_craplot;
                    END IF;  
                    
                   -- Gero o Insert na tabela de Lancamentos em depositos a vista
                   BEGIN
                      INSERT INTO craplcm
                             (dtmvtolt
                             ,cdagenci
                             ,cdbccxlt
                             ,nrdolote
                             ,nrdconta
                             ,nrdocmto
                             ,vllanmto
                             ,cdhistor
                             ,nrseqdig
                             ,nrdctabb
                             ,nrautdoc 
                             ,cdcooper
                             ,cdpesqbb) 
                      VALUES (rw_craplot.dtmvtolt
                             ,rw_craplot.cdagenci
                             ,rw_craplot.cdbccxlt
                             ,rw_craplot.nrdolote
                             ,pr_nrdconta
                             ,rw_craplot.nrseqdig + 1
                             ,rw_craptdb.valor --  VALOR PAGO DA SOMA DOS TITULOS
                             ,arr_hist(vr_index2)
                             ,rw_craplot.nrseqdig + 1
                             ,pr_nrdconta
                             ,0
                             ,vr_cdcooper
                             ,'Pagamento de titulos em atraso bordero/titulo: ' || pr_nrborder || '/' || rw_craptdb.nrtitulo)
                            RETURNING craplcm.ROWID
                                     ,craplcm.cdhistor
                                     ,craplcm.cdcooper
                                     ,craplcm.dtmvtolt
                                     ,craplcm.hrtransa
                                     ,craplcm.nrdconta
                                     ,craplcm.nrdocmto
                                     ,craplcm.vllanmto
                                     ,craplcm.nrseqdig
                                INTO  vr_rowid 
                                     ,rw_craplcm.cdhistor
                                     ,rw_craplcm.cdcooper
                                     ,rw_craplcm.dtmvtolt
                                     ,rw_craplcm.hrtransa
                                     ,rw_craplcm.nrdconta
                                     ,rw_craplcm.nrdocmto
                                     ,rw_craplcm.vllanmto
                                     ,rw_craplcm.nrseqdig;
                    EXCEPTION
                      WHEN OTHERS THEN
                        -- Monta critica
                        vr_dscritic := 'Erro ao inserir na tabela craplcm: ' || SQLERRM;
                        -- Gera exceção
                        RAISE vr_exc_erro;
                    END;

                    -- Upda te da craplot
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

                        -- Gera exceção
                        RAISE vr_exc_erro;
                    END;
                END LOOP;
                
                -- Atualiza a situaco do titulo
                BEGIN
                   UPDATE craptdb
                   SET
                      INSITTIT  = 3                     -- Baixado s/ pagamento
                      ,dtdpagto = rw_crapdat.dtmvtolt   -- Data de movimentacao 
                   WHERE
                      nrborder     = pr_nrborder
                      AND nrdconta = pr_nrdconta
                      AND nrtitulo = rw_craptdb.nrtitulo;
                EXCEPTION
                   WHEN OTHERS THEN
                     -- Monta Critica
                     vr_dscritic := 'Erro ao atualizar o titulo! ' || rw_craptdb.nrtitulo;
                     
                     -- Gera exceção
                     RAISE vr_exc_erro;
                 END;
        END LOOP;
        CLOSE cr_tab_tdb;     
               
        -- Commita toda a transacao     
        COMMIT;
        -- Caso dê tudo certo, retorna o xml com OK
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                  '<Root><dsmensag>'||1||'</dsmensag></Root>');
                                  
        -- Excecoes                                  
        EXCEPTION 
          WHEN vr_exc_erro THEN
              -- Carregar XML padrao para variavel de retorno
              pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
      
                 
 END pc_pagar_titulos_vencidos;

 PROCEDURE pc_calcula_liquidez(pr_cdcooper     IN craptdb.cdcooper%TYPE
                            ,pr_nrdconta     IN craptdb.nrdconta%TYPE
                            ,pr_nrinssac     IN crapcob.nrinssac%TYPE
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
	  CURSOR cr_craptdb(pr_cdcooper      IN craptdb.cdcooper%TYPE
                  ,pr_nrdconta     IN craptdb.nrdconta%TYPE
                  ,pr_nrinssac     IN crapcob.nrinssac%TYPE
                  ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE 
                  ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                  ,pr_qtcarpag     IN NUMBER)  IS
      SELECT 
           -- CALCULO DA CONCENTRACAO CEDENTE PAGADOR
         NVL(SUM(CASE WHEN (tdb.nrinssac = DECODE(pr_nrinssac, NULL, tdb.nrinssac, pr_nrinssac))
                       AND (tdb.nrdconta = DECODE(pr_nrdconta, NULL, tdb.nrdconta, pr_nrdconta))
                       AND (dtdpagto IS NOT NULL) 
                 THEN 1 ELSE 0 END)
             /NULLIF(SUM(CASE WHEN (tdb.nrinssac = DECODE(pr_nrinssac, NULL, tdb.nrinssac, pr_nrinssac))
                               AND (tdb.nrdconta = DECODE(pr_nrdconta, NULL, tdb.nrdconta, pr_nrdconta)) 
                         THEN 1 ELSE 0 END)
              ,0)
         ,0)*100 AS qtd_cedpag
            
         ,NVL(SUM(CASE WHEN (tdb.nrinssac = DECODE(pr_nrinssac, NULL, tdb.nrinssac, pr_nrinssac))
                        AND (tdb.nrdconta = DECODE(pr_nrdconta, NULL, tdb.nrdconta, pr_nrdconta))
                        AND (dtdpagto IS NOT NULL) 
                  THEN vltitulo ELSE 0 END)
              /NULLIF(SUM(CASE WHEN (tdb.nrinssac = DECODE(pr_nrinssac, NULL, tdb.nrinssac, pr_nrinssac))
                                AND (tdb.nrdconta = DECODE(pr_nrdconta, NULL, tdb.nrdconta, pr_nrdconta)) 
                          THEN vltitulo ELSE 0 END), 0)
          ,0)*100 AS pc_cedpag

          -- CALCULO DA CONCENTRACAO DO PAGADOR
         ,NVL(SUM(CASE WHEN (tdb.nrinssac = DECODE(pr_nrinssac, NULL, tdb.nrinssac, pr_nrinssac))
                        AND (dtdpagto IS NOT NULL) 
                  THEN 1 ELSE 0 END)
              /NULLIF(SUM(CASE WHEN (tdb.nrinssac = DECODE(pr_nrinssac, NULL, tdb.nrinssac, pr_nrinssac)) 
                          THEN 1 ELSE 0 END), 0)
         ,0)*100 AS qtd_conc
          
         ,NVL(SUM(CASE WHEN (tdb.nrinssac = DECODE(pr_nrinssac, NULL, tdb.nrinssac, pr_nrinssac))
                        AND (dtdpagto IS NOT NULL) 
                  THEN vltitulo ELSE 0 END)
             /NULLIF(SUM(CASE WHEN (tdb.nrinssac = DECODE(pr_nrinssac, NULL, tdb.nrinssac, pr_nrinssac)) 
                         THEN vltitulo ELSE 0 END), 0)
          ,0)*100 AS pc_conc

          -- CALCULO  DA LIQUIDEZ GERAL
        ,NVL(SUM(CASE WHEN (tdb.nrdconta = DECODE(pr_nrdconta, NULL, tdb.nrdconta, pr_nrdconta))
                       AND (dtdpagto IS NOT NULL) 
                 THEN 1 ELSE 0 END)
             /NULLIF(SUM(CASE WHEN (tdb.nrdconta = DECODE(pr_nrdconta, NULL, tdb.nrdconta, pr_nrdconta)) 
                         THEN 1 ELSE 0 END), 0)
         ,0)*100 AS qtd_geral
          
         ,NVL(SUM(CASE WHEN (tdb.nrdconta = DECODE(pr_nrdconta, NULL, tdb.nrdconta, pr_nrdconta))
                        AND (dtdpagto IS NOT NULL) 
                  THEN vltitulo ELSE 0 END)
             /NULLIF(SUM(CASE WHEN (tdb.nrdconta = DECODE(pr_nrdconta, NULL, tdb.nrdconta, pr_nrdconta)) 
                         THEN vltitulo ELSE 0 END), 0)
         ,0)*100 AS pc_geral
       FROM   craptdb tdb -- Titulos do Bordero
             ,crapbdt dbt -- Bordero de Titulos
       WHERE (tdb.dtvencto + pr_qtcarpag) BETWEEN pr_dtmvtolt_de AND pr_dtmvtolt_ate -- No intervalo de data da liquidez
       AND    tdb.dtresgat IS NULL 
       AND    tdb.dtlibbdt IS NOT NULL                   -- Somente os titulos que realmente foram descontados
       AND    tdb.nrborder = dbt.nrborder
       AND    tdb.nrdconta = dbt.nrdconta
       AND    tdb.cdcooper = dbt.cdcooper
       AND    dbt.cdcooper = pr_cdcooper
       AND ((tdb.nrinssac = DECODE(pr_nrinssac, NULL, tdb.nrinssac, pr_nrinssac) )
         OR (tdb.nrdconta = DECODE(pr_nrdconta, NULL, tdb.nrdconta, pr_nrdconta) ))
       --     Não considerar como título pago, os liquidados em conta corrente do cedente, ou seja, pagos pelo próprio emitente
       AND    NOT EXISTS( SELECT 1
                          FROM   craptit tit
                          WHERE  tit.cdcooper = tdb.cdcooper
                          AND    tit.dtmvtolt = tdb.dtdpagto
                          AND    tdb.nrdconta = substr(upper(tit.dscodbar), 26, 8)
                          AND    tdb.nrcnvcob = substr(upper(tit.dscodbar), 20, 6)
                          AND    tit.cdbandst = 85
                          AND    tit.cdagenci IN (90,91) );
    rw_craptdb cr_craptdb%ROWTYPE;
	BEGIN
    OPEN cr_craptdb(pr_cdcooper, pr_nrdconta, pr_nrinssac, pr_dtmvtolt_de, pr_dtmvtolt_ate, pr_qtcarpag);
    FETCH cr_craptdb INTO rw_craptdb;
    
    pr_pc_cedpag  := rw_craptdb.pc_cedpag;
    pr_qtd_cedpag := rw_craptdb.qtd_cedpag;

    pr_pc_conc    := rw_craptdb.pc_conc;
    pr_qtd_conc   := rw_craptdb.qtd_conc;

    pr_pc_geral   := rw_craptdb.pc_geral;
    pr_qtd_geral  := rw_craptdb.qtd_geral;
    CLOSE cr_craptdb;
 END pc_calcula_liquidez;
  
END DSCT0003;
/
