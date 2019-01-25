CREATE OR REPLACE PACKAGE CECRED.APLI0008 AS

  /* ------------------------------------------------------------------------------------
  Programa: APLI0008
  Sistema : Rotinas genericas referente a aplicacao programada
  Sigla   : APLI
  
  Autor   : CIS Corporate
  Data    : Julho/2018                       Ultima atualizacao: 
  
  Dados referentes ao programa:
  
  Frequencia: -----
  Objetivo  : Rotinas genéricas referente às aplicações programadas
              
  Alteracoes:    
  ----------------------------------------------------------------------------------- */

	-- PLTable que contém os dados de extrato das aplicações programadas
	TYPE typ_reg_extrato_apl_prog IS
	  RECORD(dtmvtolt craprac.dtmvtolt%TYPE
		      ,cdagenci craplac.cdagenci%TYPE
					,cdhistor craphis.cdhistor%TYPE
					,dshistor craphis.dshistor%TYPE
          ,aghistor PLS_INTEGER           -- Indica se deve-se agrupar o histórico
					,dsextrat craphis.dsextrat%TYPE
					,nrdocmto craplac.nrdocmto%TYPE
					,indebcre craphis.indebcre%TYPE
					,vllanmto craplac.vllanmto%TYPE
          ,cdbccxlt craplac.cdbccxlt%TYPE
          ,nrdolote craplac.nrdolote%TYPE
					,vlsldtot NUMBER
					,txlancto NUMBER
					,nraplica craplac.nraplica%TYPE);
					
  TYPE typ_tab_extrato_apl_prog IS
    TABLE OF typ_reg_extrato_apl_prog
		INDEX BY BINARY_INTEGER;

  /* Funcao para validar a cooperativa */
  FUNCTION fn_val_cooperativa(pr_cdcooper IN crapcop.cdcooper%TYPE) --> Código da Cooperativa
   RETURN NUMBER;
  /* Funcao para validar a cooperativa */
  FUNCTION fn_val_associado(pr_cdcooper IN crapcop.cdcooper%TYPE, --> Código da Cooperativa
                            pr_nrdconta IN crapass.nrdconta%TYPE) --> Número/Digito Conta) 
   RETURN NUMBER;

  /* Procedure para buscar a aplicacao programada padrão */
  PROCEDURE pc_buscar_apl_prog_padrao(pr_cdprodut OUT pls_integer); --> Código do Produto default (CRAPCPC)

  /* Procedure para buscar a aplicacao programada padrão - Mensageria */
  PROCEDURE pc_buscar_apl_prog_padrao_web(
                                          pr_xmllog   IN VARCHAR2            --> XML com informacoes de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2);         --> Erros do processo

  /* Procedure para incluir uma aplicação programada */
  PROCEDURE pc_incluir_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE       --> Código da cooperativa
                                ,pr_cdagenci IN crapage.cdagenci%TYPE       --> Código da agência
                                ,pr_nrdcaixa IN INTEGER                     --> Número do caixa
                                ,pr_cdoperad IN crapope.cdoperad%TYPE       --> Código do operador
                                ,pr_nmdatela VARCHAR2                       --> Nome da tela
                                ,pr_idorigem IN INTEGER                     --> Código de origem
                                ,pr_nrdconta IN craprpp.nrdconta%TYPE       --> Número da conta
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE       --> Sequêncial do titular   
                                ,pr_dtmvtolt IN craprpp.dtmvtolt%TYPE       --> Data do movimento atual
                                ,pr_cdprodut IN crapcpc.cdprodut%TYPE       --> Código do Produto de Captação
                                ,pr_dtinirpp IN craprpp.dtinirpp%TYPE       --> Data de Inicío da Aplicação Programada
                                ,pr_dtvctopp IN Date                        --> Data de vencimento do fundo (Tela)
                                ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE       --> Carência em dias (Tela)
                                ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE       --> Prazo de vencimento em dias (Tela)
                                ,pr_vlprerpp IN craprpp.vlprerpp%TYPE       --> Valor da parcela
                                ,pr_tpemiext IN craprpp.tpemiext%TYPE       --> Tipo de impressao do extrato (1-individual,2-todas,3-nao emit).
                                ,pr_flgerlog IN INTEGER                     --> Gerar log (0 = Não / 1 = Sim)
                                ,pr_dsfinali IN craprpp.dsfinali%TYPE       --> Finalidade do fundo (proveniente da tela)
                                ,pr_flgteimo IN INTEGER                     --> Teimosinha (0 = Não / 1 = Sim)
                                ,pr_flgdbpar IN INTEGER                     --> Débito Parcial (0 = Não / 1 = Sim)
                                ,pr_nrctrrpp OUT craprpp.nrctrrpp%TYPE      --> Número do Contrato - CRAPRPP
                                ,pr_nraplica OUT craprac.nraplica%TYPE      --> Número da Aplicação - CRAPRAC
                                ,pr_rpprowid OUT ROWID                      --> RowID da tabela CRAPRPP
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Codigo da critica de erro
                                ,pr_dscritic OUT crapcri.dscritic%TYPE);    --> Descricao da critica de erro
 
 /* Procedure para incluir uma aplicação programada  - Mensageria */
  PROCEDURE pc_incluir_apl_prog_web (pr_nrdconta IN craprpp.nrdconta%TYPE   --> Número da conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE   --> Sequêncial do titular   
                                    ,pr_cdprodut IN crapcpc.cdprodut%TYPE   --> Código do Produto de Captação
                                    ,pr_dtmvtolt IN VARCHAR2                --> Data do movimento atual - DD/MM/YYYY
                                    ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE   --> Carência em dias (Tela)
                                    ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE   --> Prazo de vencimento em dias (Tela)
                                    ,pr_dtinirpp IN VARCHAR2                --> Data de Inicío da Aplicação Programada - DD/MM/YYYY
                                    ,pr_dtvctopp IN VARCHAR2                --> Data de vencimento - DD/MM/YYYY (Tela)
                                    ,pr_vlprerpp IN craprpp.vlprerpp%TYPE   --> Valor da parcela
                                    ,pr_tpemiext IN craprpp.tpemiext%TYPE   --> Tipo de impressao do extrato (1-individual,2-todas,3-nao emit).
                                    ,pr_flgerlog IN INTEGER                 --> Gerar log (0 = Não / 1 = Sim)
                                    ,pr_dsfinali IN craprpp.dsfinali%TYPE   --> Finalidade do fundo (proveniente da tela)
                                    ,pr_flgteimo IN INTEGER                 --> Teimosinha (0 = Não / 1 = Sim)
                                    ,pr_flgdbpar IN INTEGER                 --> Débito Parcial (0 = Não / 1 = Sim)
                                    ,pr_xmllog   IN VARCHAR2                --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER            --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2               --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2               --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);             --> Erros do processo
                                                                 
  /* Procedure para calcular diversos valores de uma aplicacao programada a partir da RPP */
   PROCEDURE pc_posicao_saldo_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa
                                       ,pr_cdprogra IN crapres.cdprogra%TYPE     --> Programa que esta executando
                                       ,pr_cdoperad IN craplrg.cdoperad%TYPE     --> Codigo do Operador
                                       ,pr_nrdconta IN craprpp.nrdconta%TYPE     --> Numero da conta da aplicacao
                                       ,pr_idseqttl IN INTEGER                   --> Identificador Sequencial
                                       ,pr_idorigem IN INTEGER                   --> Identificador da Origem
                                       ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE     --> Numero do contrato 
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE     --> Data do movimento atual
                                       ,pr_inrendim IN PLS_INTEGER default 1     --> Carrega o rendimento (pr_vlrebtap) [1 - Sim, 0 - Nao]
                                       ,pr_vlbascal OUT NUMBER                   --> Valor Base Total
                                       ,pr_vlsdtoap OUT NUMBER                   --> Valor de Saldo Total
                                       ,pr_vlsdrgap OUT NUMBER                   --> Valor do saldo disponível para resgate
                                       ,pr_vlrebtap OUT NUMBER                   --> Valor de rendimento bruto total
                                       ,pr_vlrdirrf OUT NUMBER                   --> Valor de IRRF
                                       ,pr_des_erro OUT VARCHAR2);   
                                                                 
  /* Procedure para calcular o saldo de uma aplicacao programada a partir da RPP */
  PROCEDURE pc_calc_saldo_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa
                                   ,pr_cdprogra IN crapres.cdprogra%TYPE     --> Programa que esta executando
                                   ,pr_cdoperad IN craplrg.cdoperad%TYPE     --> Codigo do Operador
                                   ,pr_nrdconta IN craprpp.nrdconta%TYPE     --> Numero da conta da aplicacao
                                   ,pr_idseqttl IN INTEGER                   --> Identificador Sequencial
                                   ,pr_idorigem IN INTEGER                   --> Identificador da Origem
                                   ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE     --> Numero do contrato poupanca
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE     --> Data do movimento atual
                                   ,pr_vlsdrdpp IN OUT craprpp.vlsdrdpp%TYPE --> Valor do saldo da poupanca programada
                                   ,pr_des_erro OUT VARCHAR2) ;              --> Saida com erros;

  /* Procedure para calcular o saldo de uma aplicacao programada a partir da RPP - Mensgeria*/
  PROCEDURE pc_calc_saldo_apl_prog_web (pr_nrdconta IN craprac.nrdconta%TYPE   -- Número da Conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE   -- Titular da Conta
                                       ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE   -- Número da Aplicação Programada.
                                       ,pr_dtmvtolt IN VARCHAR2                -- Data de Movimento Inicial
                                       ,pr_xmllog   IN VARCHAR2                -- XML com informacoes de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER            -- Código da crítica
                                       ,pr_dscritic OUT VARCHAR2               -- Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2               -- Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);              -- Erros do processo

  /* Procedure referente a busca de extratos das aplicações programadas a partira da RPP */                           
  PROCEDURE pc_calc_saldo_ini_apl_prog(pr_cdcooper IN craprac.cdcooper%TYPE                  -- Código da Cooperativa
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE                  -- Código do Operador 
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                      ,pr_idorigem IN NUMBER                                 -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                      ,pr_nrdconta IN craprac.nrdconta%TYPE                  -- Número da Conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE                  -- Titular da Conta
                                      ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE                  -- Número da Aplicação Programada.
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE                  -- Data de Movimento
                                      ,pr_idgerlog IN NUMBER                                 -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                      ,pr_vlsdrdpp OUT NUMBER                                -- Saldo em pr_dtmvtolt-1
                                      ,pr_vlresgat OUT NUMBER                                -- Valor de resgate
                                      ,pr_vlrendim OUT NUMBER                                -- Valor de rendimento
                                      ,pr_vldoirrf OUT NUMBER                                -- Valor do IRRF
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE                 -- Código da crítica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE);               -- Descrição da crítica

  /* Procedure referente a busca de extratos das aplicações programadas a partir da RPP */                           
  PROCEDURE pc_buscar_extrato_apl_prog(pr_cdcooper IN craprac.cdcooper%TYPE                  -- Código da Cooperativa
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE                  -- Código do Operador 
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                      ,pr_idorigem IN NUMBER                                 -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                      ,pr_nrdconta IN craprac.nrdconta%TYPE                  -- Número da Conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE                  -- Titular da Conta
                                      ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE                  -- Número da Aplicação Programada.
                                      ,pr_dtmvtolt_ini IN crapdat.dtmvtolt%TYPE              -- Data de Movimento - Inicio
                                      ,pr_dtmvtolt_fim IN crapdat.dtmvtolt%TYPE              -- Data de Movimento - Fim
                                      ,pr_idlstdhs IN NUMBER                                 -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                      ,pr_idgerlog IN NUMBER                                 -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                      ,pr_tab_extrato OUT apli0008.typ_tab_extrato_apl_prog  -- PLTable com os dados de extrato
                                      ,pr_vlresgat OUT NUMBER                                -- Valor de resgate
                                      ,pr_vlrendim OUT NUMBER                                -- Valor de rendimento
                                      ,pr_vldoirrf OUT NUMBER                                -- Valor do IRRF
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE                 -- Código da crítica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE);               -- Descrição da crítica

  /* Procedure referente a busca de extratos das aplicações programadas a partir da RPP Mensageria */    
  PROCEDURE pc_buscar_extrato_apl_prog_web (pr_nrdconta IN craprac.nrdconta%TYPE   -- Número da Conta
                                           ,pr_idseqttl IN crapttl.idseqttl%TYPE   -- Titular da Conta
                                           ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE   -- Número da Aplicação Programada.
                                           ,pr_dtmvtolt_ini IN VARCHAR2            -- Data de Movimento Inicial
                                           ,pr_dtmvtolt_fim IN VARCHAR2            -- Data de Movimento Fim
                                           ,pr_idlstdhs IN NUMBER                  -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                           ,pr_idgerlog IN NUMBER                  -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                           ,pr_xmllog   IN VARCHAR2                -- XML com informacoes de LOG
                                           ,pr_cdcritic OUT PLS_INTEGER            -- Código da crítica
                                           ,pr_dscritic OUT VARCHAR2               -- Descrição da crítica
                                           ,pr_retxml   IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                           ,pr_nmdcampo OUT VARCHAR2               -- Nome do campo com erro
                                           ,pr_des_erro OUT VARCHAR2);              -- Erros do processo

  /* Procedure referente a busca de extratos das aplicações programadas a partir da RPP Canais */    
  PROCEDURE pc_buscar_extrato_apl_prog_car (pr_cdcooper IN craprac.cdcooper%TYPE                  -- Código da Cooperativa
                                           ,pr_cdoperad IN crapope.cdoperad%TYPE                  -- Código do Operador 
                                           ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                           ,pr_idorigem IN NUMBER   -- Código de Origem
                                           ,pr_nrdconta IN craprac.nrdconta%TYPE   -- Número da Conta
                                           ,pr_idseqttl IN crapttl.idseqttl%TYPE                  -- Titular da Conta
                                           ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE   -- Número da Aplicação Programada.
                                           ,pr_dtmvtolt_ini IN DATE            -- Data de Movimento Inicial
                                           ,pr_dtmvtolt_fim IN DATE            -- Data de Movimento Fim
                                           ,pr_idlstdhs IN NUMBER                  -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                           ,pr_idgerlog IN NUMBER                  -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                           ,pr_xmllog   IN VARCHAR2                -- XML com informacoes de LOG
                                           ,pr_cdcritic OUT PLS_INTEGER            -- Código da crítica
                                           ,pr_dscritic OUT VARCHAR2               -- Descrição da crítica
                                           ,pr_clobxmlc   OUT CLOB                   -- Arquivo de retorno do XML
                                           ,pr_nmdcampo OUT VARCHAR2               -- Nome do campo com erro
                                           ,pr_des_erro OUT VARCHAR2);              -- Erros do processo

  /* Procedure referente geracao de extratos de um título de uma Aplicação Programada */                           
  PROCEDURE pc_gerar_ext_apl_prog_titulo(pr_cdcooper IN craprac.cdcooper%TYPE                  -- Código da Cooperativa
                                        ,pr_cdoperad IN crapope.cdoperad%TYPE                  -- Código do Operador 
                                        ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                        ,pr_idorigem IN NUMBER                                 -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                        ,pr_nrdconta IN craprac.nrdconta%TYPE                  -- Número da Conta
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE                  -- Titular da Conta
                                        ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE                  -- Número da Aplicação Programada.
                                        ,pr_nraplica IN craprac.nraplica%TYPE                  -- Número da Aplicacao
                                        ,pr_dtmvtolt_ini IN crapdat.dtmvtolt%TYPE              -- Data de Movimento - Inicio
                                        ,pr_dtmvtolt_fim IN crapdat.dtmvtolt%TYPE              -- Data de Movimento - Fim
                                        ,pr_idlstdhs IN NUMBER                                 -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                        ,pr_idgerlog IN NUMBER                                 -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                        ,pr_tab_extrato OUT apli0008.typ_tab_extrato_apl_prog  -- PLTable com os dados de extrato
                                        ,pr_vlresgat OUT NUMBER                                -- Valor de resgate
                                        ,pr_vlrendim OUT NUMBER                                -- Valor de rendimento
                                        ,pr_vldoirrf OUT NUMBER                                -- Valor do IRRF 
                                        ,pr_percirrf OUT NUMBER                                -- Valor de aliquota de IR
                                        ,pr_txacumul OUT NUMBER                                -- Taxa acumulada durante o período total da aplicação
                                        ,pr_txacumes OUT NUMBER                                -- Taxa acumulada durante o mês vigente
                                        ,pr_qtdiacar OUT craprac.qtdiacar%TYPE                 -- Qtd. dias carência
                                        ,pr_dtfimcar OUT DATE                                  -- Data fim da carência
                                        ,pr_dtvencto OUT DATE                                  -- Data de vencimento 
                                        ,pr_qtdiaprz OUT craprac.qtdiaprz%TYPE                 -- Quantidade de dias do prazo da modalidade
                                        ,pr_qtdiaapl OUT craprac.qtdiaapl%TYPE                 -- Quantidade de dias da aplicacao
                                        ,pr_txaplica OUT craprac.txaplica%TYPE                 -- Taxa contratada da aplicacao
                                        ,pr_nmdindex OUT crapind.nmdindex%TYPE                 -- Nome do Indice  
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE                 -- Código da crítica
                                        ,pr_dscritic OUT crapcri.dscritic%TYPE);               -- Descrição da crítica
    
  /* Procedure referente a busca de detalhes da RPP a partir do numero de contrato */
  PROCEDURE pc_buscar_detalhe_apl_prog (pr_cdcooper IN craprac.cdcooper%TYPE                  -- Código da Cooperativa
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE                  -- Código do Operador 
                                       ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                       ,pr_idorigem IN NUMBER                                 -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                       ,pr_nrdconta IN craprac.nrdconta%TYPE                  -- Número da Conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE                  -- Titular da Conta
                                       ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE                  -- Número da Aplicação Programada
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE                  -- Data de Movimento
                                       ,pr_tab_dados_rpp OUT apli0001.typ_tab_dados_rpp       -- PLTable com os detalhes;
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE                 -- Código da crítica
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE);               -- Descrição da crítica

  /* Procedure referente a busca de detalhes da RPP a partir do numero de contrato - Mensgeria*/
  PROCEDURE pc_buscar_detalhe_apl_prog_web (pr_nrdconta IN craprac.nrdconta%TYPE   -- Número da Conta
                                           ,pr_idseqttl IN crapttl.idseqttl%TYPE   -- Titular da Conta
                                           ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE   -- Número da Aplicação Programada.
                                           ,pr_dtmvtolt IN VARCHAR2                -- Data de Movimento Inicial
                                           ,pr_xmllog   IN VARCHAR2                -- XML com informacoes de LOG
                                           ,pr_cdcritic OUT PLS_INTEGER            -- Código da crítica
                                           ,pr_dscritic OUT VARCHAR2               -- Descrição da crítica
                                           ,pr_retxml   IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                           ,pr_nmdcampo OUT VARCHAR2               -- Nome do campo com erro
                                           ,pr_des_erro OUT VARCHAR2);              -- Erros do processo

  /* Recuperar lista das poupancas programadas e aplicações programadas */
  PROCEDURE pc_lista_poupanca (pr_cdcooper IN crapcop.cdcooper%TYPE            --> Cooperativa
                              ,pr_cdagenci IN crapage.cdagenci%TYPE            --> Codigo da Agencia
                              ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE            --> Numero do caixa
                              ,pr_cdoperad IN craplrg.cdoperad%TYPE            --> Codigo do Operador
                              ,pr_idorigem IN INTEGER                          --> Identificador da Origem
                              ,pr_nrdconta IN craprda.nrdconta%TYPE            --> Nro da conta da aplicacao RDCA
                              ,pr_idseqttl IN INTEGER                          --> Identificador Sequencial
                              ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE            --> Contrato Poupanca Programada
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE            --> Data do movimento atual
                              ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE            --> Data do proximo movimento
                              ,pr_inproces IN crapdat.inproces%TYPE            --> Indicador de processo
                              ,pr_cdprogra IN crapprg.cdprogra%TYPE            --> Nome do programa chamador
                              ,pr_flgerlog IN BOOLEAN                          --> Flag erro log
                              ,pr_percenir IN NUMBER                           --> % IR para Calculo Poupanca
                              ,pr_tpapprog IN INTEGER default 0                --> Tipo de aplicacao poupanca (1 = Poupanca Antiga, 2 = Aplicações Programadas, 0 = Ambas)
                              ,pr_vlsldrpp OUT NUMBER                          --> Valor saldo total poupanca programada
                              ,pr_retorno  OUT VARCHAR2                        --> Descricao de erro ou sucesso OK/NOK
                              ,pr_tab_dados_rpp OUT APLI0001.typ_tab_dados_rpp --> Poupancas Programadas
                              ,pr_tab_erro      IN OUT NOCOPY GENE0001.typ_tab_erro);  --> Saida com erros;

  /* Recuperar lista das poupancas programadas e aplicações programadas - Mensageria*/
  PROCEDURE pc_lista_poupanca_web (pr_nrdconta IN craprda.nrdconta%TYPE  -- Nro da conta da aplicacao RDCA
                                  ,pr_idseqttl IN INTEGER                -- Identificador Sequencial
                                  ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  -- Contrato Poupanca Programada
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  -- Data do movimento atual
                                  ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE  -- Data do proximo movimento
                                  ,pr_inproces IN crapdat.inproces%TYPE  -- Indicador de processo
                                  ,pr_flgerlog IN INTEGER                -- Flag erro log
                                  ,pr_percenir IN NUMBER                 -- % IR para Calculo Poupanca
                                  ,pr_tpapprog IN INTEGER default 0      -- Tipo de aplicacao poupanca (1 = Poupanca Antiga, 2 = Aplicações Programadas, 0 = Ambas)
                                  ,pr_xmllog   IN VARCHAR2               -- XML com informacoes de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER           -- Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              -- Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType     -- Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2              -- Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);            -- Erros do processo

  /* Recuperar lista das aplicações programadas para o processo na B3 */
  PROCEDURE pc_lista_aplicacoes_progr(pr_cdcooper    IN craprac.cdcooper%TYPE           --> Código da Cooperativa
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
															 ,pr_tpaplica    IN PLS_INTEGER DEFAULT 0           --> Tipo Aplicacao (0 - Todas / 1 - Não PCAPTA (RDC PÓS, PRE e RDCA) / 2 - Apenas PCAPTA)
															 ,pr_cdcritic   OUT INTEGER                         --> Código da crítica
															 ,pr_dscritic   OUT VARCHAR2                        --> Descrição da crítica
															 ,pr_saldo_rdca OUT apli0001.typ_tab_saldo_rdca);   --> Tabela com os dados da aplicação

  /* Recuperar o detalhe das aplicações programadas para o processo na B3 */
	PROCEDURE pc_busca_aplicacoes_prog(pr_cdcooper IN craprac.cdcooper%TYPE             --> Código da Cooperativa
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
				 ,pr_tab_aplica OUT apli0005.typ_tab_aplicacao);   --> Tabela com os dados da aplicação

  /* Processar o detalhe das aplicações programadas no resgate e provisap */
procedure pc_calc_app_programada (pr_cdcooper  in crapcop.cdcooper%type,          --> Cooperativa
                              pr_dstextab  in craptab.dstextab%type,          --> Percentual de IR da aplicação
                              pr_cdprogra  in crapprg.cdprogra%type,          --> Programa chamador
                              pr_inproces  in crapdat.inproces%type,          --> Indicador do processo
                              pr_dtmvtolt  in crapdat.dtmvtolt%type,          --> Data do processo
                              pr_dtmvtopr  in crapdat.dtmvtopr%type,          --> Próximo dia útil
                              pr_rpp_rowid in varchar2,                       --> Identificador do registro da tabela CRAPRPP em processamento
                              pr_vlsdrdpp  in out craprpp.vlsdrdpp%type,      --> Saldo da poupança programada
                              pr_cdcritic out crapcri.cdcritic%type,          --> Codigo da crítica de erro
                              pr_des_erro out varchar2);                    --> Descrição do erro encontrado

  -- Rotina para geração do Termo de Adesão de uma aplicação programada  
  PROCEDURE pc_impres_termo_adesao_ap(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Codigo do programa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  --> Contrato
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     ,pr_nmarqpdf OUT VARCHAR2              --> Nome do PDF                           
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica

  -- Rotina para geração do Termo de Adesão de uma aplicação programada  - Mensageria
  PROCEDURE pc_impres_termo_adesao_ap_web (pr_nrdconta IN craprac.nrdconta%TYPE   -- Número da Conta
                                          ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE   -- Número da Aplicação Programada.
                                          ,pr_dtmvtolt IN VARCHAR2                -- Data de Movimento Inicial
                                          ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                          ,pr_xmllog   IN VARCHAR2                -- XML com informacoes de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER            -- Código da crítica
                                          ,pr_dscritic OUT VARCHAR2               -- Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2               -- Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2);             -- Erros do processo

END APLI0008;
/
CREATE OR REPLACE PACKAGE BODY CECRED.APLI0008 AS

  FUNCTION fn_val_cooperativa(pr_cdcooper IN crapcop.cdcooper%TYPE) --> Código da Cooperativa
   RETURN NUMBER IS
    /* .............................................................................
     Programa: fn_val_cooperativa
     Autor   : CIS Corporate
     Data    : 21/07/2018                     Ultima atualizacao:
    
     Dados referentes ao programa:
    
     Objetivo  : Verificar a existencia da cooperativa
     
     Alteracoes :
     
    .............................................................................*/
    vr_coop NUMBER;
  
  Begin
    Begin
      -- Utlizando cursor implicito pois irá retornar no máximo 1 linha
      Select 1 into vr_coop from crapcop Where cdcooper = pr_cdcooper;
    Exception
      When NO_DATA_FOUND Then
        vr_coop := 0;
    End;
    Return vr_coop;
  End fn_val_cooperativa;

  FUNCTION fn_val_associado(pr_cdcooper IN crapcop.cdcooper%TYPE, --> Código da Cooperativa
                            pr_nrdconta IN crapass.nrdconta%TYPE) --> Número/Digito Conta) 
   RETURN NUMBER IS
    /* .............................................................................
     Programa: fn_val_associado
     Autor   : CIS Corporate
     Data    : 21/07/2018                     Ultima atualizacao:
    
     Dados referentes ao programa:
    
     Objetivo  : Verificar a existencia da cooperativa
     
     Alteracoes :
     
    .............................................................................*/
    vr_assoc NUMBER;
  
  Begin
    Begin
      -- Utlizando cursor implicito pois irá retornar no máximo 1 linha
      Select 1
        into vr_assoc
        from crapass
       Where cdcooper = pr_cdcooper
         and nrdconta = pr_nrdconta;
    Exception
      When NO_DATA_FOUND Then
        vr_assoc := 0;
    End;
    Return vr_assoc;
  End fn_val_associado;

  PROCEDURE pc_buscar_apl_prog_padrao(pr_cdprodut OUT pls_integer) --> Código do Produto default (CRAPCPC)
   IS
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_buscar_apl_prog_padrao
    --  Sistema  : Captação (Aplicação Programada)
    --  Sigla    : CRED
    --  Autor    : CIS Corporate
    --  Data     : Março/2018.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: ----
    -- Objetivo  : Recupera aplicacao programada padrão
    --
    -- Alteracoes:
    -- 
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      CURSOR cr_crapprm IS
        Select TO_NUMBER(DSVLRPRM) codprodut
          From crapprm
         Where NMSISTEM = 'CRED'
           AND CDACESSO = 'COD_MIGRACAO_APL_PROG';
      vr_crapprm cr_crapprm%ROWTYPE;
    BEGIN
      OPEN cr_crapprm;
      FETCH cr_crapprm
        INTO vr_crapprm;
      pr_cdprodut := vr_crapprm.codprodut;
      CLOSE cr_crapprm;
    END;
  END pc_buscar_apl_prog_padrao;

  PROCEDURE pc_buscar_apl_prog_padrao_web(
                                          pr_xmllog   IN VARCHAR2            --> XML com informacoes de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2)          --> Erros do processo
   IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_buscar_apl_prog_padrao_web
    --  Sistema  : Captação (Aplicação Programada)
    --  Sigla    : CRED
    --  Autor    : CIS Corporate
    --  Data     : Julho/2018.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: ----
    -- Objetivo  : Recupera aplicacao programada padrão web
    --
    -- Alteracoes:
    -- 
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      vr_cdprodut pls_integer;
    
      -- Variaveis auxiliares
      vr_exc_erro EXCEPTION;
    
    BEGIN
      apli0008.pc_buscar_apl_prog_padrao(pr_cdprodut => vr_cdprodut);
      If vr_cdprodut is null Then
        Raise vr_exc_erro;
      End If;
    
      -- Criar XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><cdprodut>' || vr_cdprodut ||
                                     '</cdprodut></Root>');
    
    Exception
      When others then
        pr_cdcritic := null; -- não será utilizado
        pr_nmdcampo := null; -- não será utilizado
        pr_dscritic := 'Produto padrão para Aplicação Programada não cadastrado';
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
      
    END;
  END pc_buscar_apl_prog_padrao_web;

  PROCEDURE pc_incluir_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE             --> Código da cooperativa
                                ,pr_cdagenci IN crapage.cdagenci%TYPE             --> Código da agência
                                ,pr_nrdcaixa IN INTEGER                           --> Número do caixa
                                ,pr_cdoperad IN crapope.cdoperad%TYPE             --> Código do operador
                                ,pr_nmdatela VARCHAR2                             --> Nome da tela
                                ,pr_idorigem IN INTEGER                           --> Código de origem
                                ,pr_nrdconta IN craprpp.nrdconta%TYPE             --> Número da conta
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE             --> Sequêncial do titular   
                                ,pr_dtmvtolt IN craprpp.dtmvtolt%TYPE             --> Data do movimento atual
                                ,pr_cdprodut IN crapcpc.cdprodut%TYPE             --> Código do Produto de Captação
                                ,pr_dtinirpp IN craprpp.dtinirpp%TYPE             --> Data de Inicío da Aplicação Programada
                                ,pr_dtvctopp IN Date                              --> Data de vencimento (Tela)
                                ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE             --> Carência em dias (Tela)
                                ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE             --> Prazo de vencimento em dias (Tela)
                                ,pr_vlprerpp IN craprpp.vlprerpp%TYPE             --> Valor da parcela
                                ,pr_tpemiext IN craprpp.tpemiext%TYPE             --> Tipo de impressao do extrato (1-individual,2-todas,3-nao emit).
                                ,pr_flgerlog IN INTEGER                           --> Gerar log (0 = Não / 1 = Sim)
                                ,pr_dsfinali IN craprpp.dsfinali%TYPE             --> Finalidade do fundo (proveniente da tela)
                                ,pr_flgteimo IN INTEGER                           --> Teimosinha (0 = Não / 1 = Sim)
                                ,pr_flgdbpar IN INTEGER                           --> Débito Parcial (0 = Não / 1 = Sim)
                                ,pr_nrctrrpp OUT craprpp.nrctrrpp%TYPE            --> Número do Contrato - CRAPRPP
                                ,pr_nraplica OUT craprac.nraplica%TYPE            --> Número da Aplicação - CRAPRAC
                                ,pr_rpprowid OUT ROWID                            --> RowID da tabela CRAPRPP
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE            --> Codigo da critica de erro
                                ,pr_dscritic OUT crapcri.dscritic%TYPE)           --> Descricao da critica de erro

   IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_incluir_apli_progr
    --  Sistema  : Captação (Aplicação Programada)
    --  Sigla    : CRED
    --  Autor    : CIS Corporate
    --  Data     : Julho/2018.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: ----
    -- Objetivo  : Insere novo plano aplicação programada
    --
    -- Alteracoes:
    -- 
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Constantes
    
      cn_cdbccxlt pls_integer := 200;
      cn_nrdolote pls_integer := 1537; -- Num. Lote
      cn_tplotmov pls_integer := 14;
      cn_cdhistor pls_integer := 0;
    
      vr_consist pls_integer := 0;     -- Generica para consistencias
      vr_saldo NUMBER(25,8);      -- Saldo 

      vr_lock_timer date;

      vr_cdsecext    crapass.cdsecext%type; -- Código de Seção
      vr_tmp_craplot cobr0011.cr_craplot%ROWTYPE;
      vr_nrseqdig    craplot.nrseqdig%type; -- Sequencia de digitação
      vr_nrseqted    crapmat.nrseqted%type; -- Recuperar a sequence da conta de apl. programada
    
      -- Variaveis auxiliares
      vr_exc_erro_nrb EXCEPTION; -- Sem rollback
      vr_exc_erro_rb  EXCEPTION; -- Com rollback
    
      -- Cursores
      -- Lotes
      CURSOR cr_craplot(pr_cdcooper crapcop.cdcooper%TYPE,
                        pr_cdagenci craplot.cdagenci%TYPE,
                        pr_dtmvtolt craplot.dtmvtolt%TYPE) IS
        Select 1
          From craplot
         where cdcooper = pr_cdcooper
           and dtmvtolt = pr_dtmvtolt
           and cdagenci = pr_cdagenci
           and cdbccxlt = cn_cdbccxlt -- fixo
           and nrdolote = cn_nrdolote; -- fixo
      rw_craplot cr_craplot%ROWTYPE;

    Begin
      Begin
        -- Verifica se existe a cooperativa
        vr_consist := apli0008.fn_val_cooperativa(pr_cdcooper => pr_cdcooper); -- Cod. Cooperativa
        If vr_consist = 0 Then
          pr_cdcritic := null;
          pr_dscritic := 'Cooperativa não encontrada';
          Raise vr_exc_erro_nrb;
        End If;
        -- Verifica se existe o cooperado e recupera o codigo da secao para onde deve ser enviado o extrato.
        Begin
          -- Utlizando cursor implicito pois irá retornar no máximo 1 linha
          Select cdsecext
            into vr_cdsecext
            from crapass
           Where cdcooper = pr_cdcooper
             and nrdconta = pr_nrdconta;
        Exception
             When NO_DATA_FOUND Then
                  pr_cdcritic := 999;
                  pr_dscritic := 'Associado não encontrado';
                  Raise vr_exc_erro_nrb;
        End;
         
        -- A proc. pc_obtem_taxa_modalidade não é executada novamente, esta já foi invocada na tela

        SAVEPOINT RAC_savepoint;
      
        -- Tratamento do LOTE  
        -- Leitura do lote se o mesmo estiver em lock, tenta por 10 seg. */
        For i in 1 .. 100 Loop
          Begin
            Open cr_craplot(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_dtmvtolt => pr_dtmvtolt);
            Fetch cr_craplot
              Into rw_craplot;
            pr_dscritic := NULL;
            Exit;
          Exception
            When Others Then
              If cr_craplot%ISOPEN Then
                Close cr_craplot;
              End If;
              -- setar critica caso for o ultimo
              If i = 100 THEN
                pr_dscritic := 'Registro de lote em uso';
              End If;
              -- aguardar +- 0,5 seg. antes de tentar novamente
              Select SYSDATE Into vr_lock_timer From Dual;
              Loop
                Exit When vr_lock_timer +(1 / 100000) = SYSDATE;
              End Loop;
          End;
        End Loop;
        If pr_dscritic = 'Registro de lote em uso' Then
          raise vr_exc_erro_nrb;
        End If;

        IF cr_craplot%NOTFOUND THEN
          CLOSE cr_craplot;
          -- Criar o lote
          cobr0011.pc_insere_lote(pr_cdcooper => pr_cdcooper,
                                  pr_dtmvtolt => pr_dtmvtolt,
                                  pr_cdagenci => pr_cdagenci,
                                  pr_cdbccxlt => cn_cdbccxlt,
                                  pr_nrdolote => cn_nrdolote,
                                  pr_cdoperad => pr_cdoperad,
                                  pr_nrdcaixa => pr_nrdcaixa,
                                  pr_tplotmov => cn_tplotmov,
                                  pr_cdhistor => cn_cdhistor,
                                  pr_craplot  => vr_tmp_craplot, -- OUT
                                  pr_dscritic => pr_dscritic     -- OUT
                                  );
          IF pr_dscritic is not null Then
            raise vr_exc_erro_rb;
          END IF;
        ELSE
          CLOSE cr_craplot;
        END IF; -- Not found (Lote encontrado)

        -- Recuperar a sequencia da digitação (chave unica craprpp3)  
        -- Cursor Implicito
        Select max(nrseqdig) + 1
          into vr_nrseqdig
          from craprpp
         where cdcooper = pr_cdcooper
           and dtmvtolt = pr_dtmvtolt
           and cdagenci = pr_cdagenci
           and cdbccxlt = cn_cdbccxlt -- fixo
           and nrdolote = cn_nrdolote; -- fixo
        If vr_nrseqdig is null Then
           vr_nrseqdig := 1;
        End If;

        -- Atualizar CRAPLOT
        Begin
          Update craplot
             Set qtcompln = qtcompln + 1,
                 qtinfoln = qtinfoln + 1,
                 vlcompcr = vlcompcr + pr_vlprerpp,
                 vlinfocr = vlinfocr + pr_vlprerpp
           Where cdcooper = pr_cdcooper
             and dtmvtolt = pr_dtmvtolt
             and cdagenci = pr_cdagenci
             and cdbccxlt = cn_cdbccxlt -- fixo
             and nrdolote = cn_nrdolote -- fixo
             and tplotmov = cn_tplotmov; -- fixo
        Exception
          When Others Then
            pr_dscritic := 'Erro atualizacao CRAPLOT';
            raise vr_exc_erro_rb;
        End;
        
        -- Recuperar próximo número RPP
        vr_nrseqted := cecred.fn_sequence(pr_nmtabela => 'CRAPMAT',
                                           pr_nmdcampo => 'NRRDCAPP',
                                           pr_dsdchave => pr_cdcooper,
                                           pr_flgdecre => 'N');

        -- Efetuar Inclusao na RPP
        Begin
          Insert into craprpp
            (nrctrrpp,         -- Numero da poupanca programada.
             cdsitrpp,         -- Situacao: 0-nao ativo, 1-ativo, 2-suspenso, 3-cancelado, 5-vencido.
             cdcooper,         -- cooperativa
             cdageass,         -- Codigo da agencia do associado.
             cdagenci,         -- Numero do PA.
             tpemiext,         -- Tipo de impressao do extrato (1-individual,2-todas,3-nao emit).
             dtimpcrt,         -- Data de impressao do contrato
             dtcalcul,         -- Proximo dia a ser calculado.      
             dtvctopp,         -- Data de vencimento da poupanca programada.
             cdopeori,         -- Codigo do operador original do registro
             cdageori,         -- Codigo da agencia original do registro
             dtinsori,         -- Data  de criação do registro
             dtiniper,         -- Data de início do periodo.
             dtfimper,         -- Data de fim do periodo.
             dtinirpp,         -- Data de inicio da poupanca programada.
             dtdebito,         -- Data do debito.
             dtiniext,         -- Data de referencia inicial para extrato.
             dtfimext,         -- Data de referencia final para extrato.
             dtsppant,         -- Data de referencia dos lancamentos do ano anterior.
             dtsppext,         -- Data de referencia dos lancamentos p/extrato.
             dtrnirpp,         -- Data de reinicio do debito do plano.
             dtsdppan,         -- Data do saldo anterior.
             flgctain,         -- Conta Investimento
             nrdolote,         -- Numero do lote.
             nrseqdig,         -- Sequencia de digitacao.
             cdbccxlt,         -- Codigo do banco/caixa.
             cdsecext,         -- Codigo da secao para onde deve ser enviado o extrato.
             nrdconta,         -- Numero da conta/dv do associado.
             vlprerpp,         -- Valor da prestacao da poupanca programada.
             indebito,         -- Indicador de debito.
             dtmvtolt,         -- Data do movimento atual.
             cdprodut,         -- Codigo do produto de captacao
             dsfinali,         -- Descricao da finalidade para a aplicacao programada
             flgteimo,         -- Teimosinha
             flgdbpar          -- Débito Parcial
             )         
          Values
            (vr_nrseqted,      -- Numero da poupanca programada.
             1,                -- 1
             pr_cdcooper,
             pr_cdagenci,
             pr_cdagenci,
             pr_tpemiext,      -- Tipo de impressao do extrato - prov. Tela
             null,             -- Data de impressao do contrato             
             null,             -- Proximo dia a ser calculado.     
             pr_dtvctopp,      -- Data de vencimento da poupanca programada. - prov. Tela
             pr_cdoperad,      
             pr_cdagenci,
             to_date(sysdate,'DD/MM/YYYY'), -- Data  de criação do registro
             pr_dtinirpp,      -- Data de início do periodo.
             add_months(pr_dtinirpp,1),      -- Data de fim do periodo.
             pr_dtinirpp,      -- Data de inicio da poupanca programada.
             pr_dtinirpp,      -- Data do debito.  
             pr_dtinirpp,      -- Data de referencia inicial para extrato.
             pr_dtinirpp,      -- Data de referencia final para extrato.
             pr_dtinirpp,      -- Data de referencia dos lancamentos do ano anterior.
             pr_dtinirpp,      -- Data de referencia dos lancamentos p/extrato.
             null,             -- Data de reinicio do debito do plano.
             pr_dtinirpp,      -- Data do saldo anterior.
             1,                -- Conta Investimento - Fixo
             cn_nrdolote,      -- Numero do lote.
             vr_nrseqdig,      -- Sequencia de digitacao.
             cn_cdbccxlt,      -- Codigo do banco/caixa. - Fixo
             vr_cdsecext,      -- Codigo da secao para onde deve ser enviado o extrato.
             pr_nrdconta,      -- Numero da conta/dv do associado.
             pr_vlprerpp,      -- Valor da prestacao da poupanca programada.
             0,                -- Indicador de debito.
             pr_dtmvtolt,      -- Data do movimento atual.
             pr_cdprodut,      -- Código do produto CRAPCPC
             pr_dsfinali,      -- Finalidade do fundo (proveniente da tela)
             pr_flgteimo,      -- Teimosinha (0 = Não / 1 = Sim)
             pr_flgdbpar       -- Débito Parcial (0 = Não / 1 = Sim)
             )
             Returning rowid into pr_rpprowid;
        Exception
          When Others Then
            pr_dscritic := 'Erro insercao craprpp';
            raise vr_exc_erro_rb;
        End;

        pr_nrctrrpp:=vr_nrseqted;
        vr_saldo := 0;
        -- Criar Saldo da Aplicação
        Begin
           Insert into crapspp   
             (cdcooper,          -- Codigo que identifica a Cooperativa.
              nrdconta,          -- Numero da conta/dv do associado.
              nrctrrpp,          -- Numero da poupanca programada.
              dtsldrpp,          -- Data do saldo da poupanca programada.
              vlsldrpp,          -- Saldo da poupanca programada.
              dtmvtolt)          -- Data do movimento.
            Values
             (pr_cdcooper,       -- Codigo que identifica a Cooperativa.
              pr_nrdconta,       -- Numero da conta/dv do associado.
              vr_nrseqted,       -- Numero da poupanca programada.
              pr_dtinirpp,       -- Data do saldo da poupanca programada.
              vr_saldo,          -- Saldo da poupanca programada.
              pr_dtmvtolt        -- Data do movimento.
              );
        Exception
            When Others Then
              pr_dscritic := 'Erro atualizacao CRAPSPP';
              raise vr_exc_erro_rb;
        End;
        -- Se for necessário gerar log
        If  pr_flgerlog = 1 Then
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => ''
                              ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                              ,pr_dstransa => 'Inclusao de Aplicacao Programada'
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 1 --> TRUE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => pr_rpprowid);

          gene0001.pc_gera_log_item(pr_nrdrowid => pr_rpprowid
                                     ,pr_nmdcampo => 'NRAPLICA'
                                     ,pr_dsdadant => ''
                                     ,pr_dsdadatu => pr_nraplica);

          gene0001.pc_gera_log_item(pr_nrdrowid => pr_rpprowid
                                   ,pr_nmdcampo => 'NRDOCMTO'
                                   ,pr_dsdadant => ''
                                   ,pr_dsdadatu => pr_nraplica);

          gene0001.pc_gera_log_item(pr_nrdrowid => pr_rpprowid
                                   ,pr_nmdcampo => 'DTRESGAT'
                                   ,pr_dsdadant => ''
                                   ,pr_dsdadatu => TO_CHAR(pr_dtvctopp,'dd/MM/RRRR'));

        End If;
       Commit;  
      Exception
        When vr_exc_erro_nrb Then
          pr_rpprowid:= null;
        When vr_exc_erro_rb Then
          pr_rpprowid:= null;
          Rollback to RAC_savepoint;
        When Others Then
          pr_rpprowid:= null;
      End;
    End;
  
  END pc_incluir_apl_prog;
 
  PROCEDURE pc_incluir_apl_prog_web (pr_nrdconta IN craprpp.nrdconta%TYPE  --> Número da conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequêncial do titular   
                                    ,pr_cdprodut IN crapcpc.cdprodut%TYPE  --> Código do Produto de Captação
                                    ,pr_dtmvtolt IN VARCHAR2               --> Data do movimento atual - DD/MM/YYYY
                                    ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE  --> Carência em dias (Tela)
                                    ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE  --> Prazo de vencimento em dias (Tela)
                                    ,pr_dtinirpp IN VARCHAR2               --> Data de Inicío da Aplicação Programada - DD/MM/YYYY
                                    ,pr_dtvctopp IN VARCHAR2               --> Data de vencimento - DD/MM/YYYY (Tela)
                                    ,pr_vlprerpp IN craprpp.vlprerpp%TYPE  --> Valor da parcela
                                    ,pr_tpemiext IN craprpp.tpemiext%TYPE  --> Tipo de impressao do extrato (1-individual,2-todas,3-nao emit).
                                    ,pr_flgerlog IN INTEGER                --> Gerar log (0 = Não / 1 = Sim)
                                    ,pr_dsfinali IN craprpp.dsfinali%TYPE  --> Finalidade do fundo (proveniente da tela)
                                    ,pr_flgteimo IN INTEGER                --> Teimosinha (0 = Não / 1 = Sim)
                                    ,pr_flgdbpar IN INTEGER                --> Débito Parcial (0 = Não / 1 = Sim)
                                    ,pr_xmllog   IN VARCHAR2               --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2)             --> Erros do processo
   IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_incluir_apl_prog_web
    --  Sistema  : Captação (Aplicação Programada)
    --  Sigla    : CRED
    --  Autor    : CIS Corporate
    --  Data     : Julho/2018.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: ----
    -- Objetivo  : Insere novo plano aplicação programada 
    --
    -- Alteracoes:
    -- 
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
    
      -- Variaveis auxiliares
      vr_exc_erro EXCEPTION;

      -- Variaveis de entrada
      vr_dtmvtolt Date := TO_DATE(pr_dtmvtolt,'DD/MM/YYYY');  
      vr_dtinirpp Date := TO_DATE (pr_dtinirpp,'DD/MM/YYYY'); 
      vr_dtvctopp Date := TO_DATE(pr_dtvctopp,'DD/MM/YYYY');  

      -- Variaveis de retorno
      vr_nrctrrpp craprpp.nrctrrpp%TYPE;
      vr_nraplica craprac.nraplica%TYPE;
      vr_rpprowid ROWID;

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

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
        RAISE vr_exc_erro;
      END IF;     

      
      -- Efetua a inclusão da Aplicação Programada
      apli0008.pc_incluir_apl_prog(pr_cdcooper => vr_cdcooper,
                                   pr_cdagenci => vr_cdagenci,
                                   pr_nrdcaixa => vr_nrdcaixa,
                                   pr_cdoperad => vr_cdoperad,
                                   pr_nmdatela => vr_nmdatela,
                                   pr_idorigem => vr_idorigem,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_idseqttl => pr_idseqttl,
                                   pr_dtmvtolt => vr_dtmvtolt,
                                   pr_cdprodut => pr_cdprodut,
                                   pr_dtinirpp => vr_dtinirpp,
                                   pr_dtvctopp => vr_dtvctopp,
                                   pr_qtdiacar => pr_qtdiacar,
                                   pr_qtdiaprz => pr_qtdiaprz,
                                   pr_vlprerpp => pr_vlprerpp,
                                   pr_tpemiext => pr_tpemiext,
                                   pr_flgerlog => pr_flgerlog,
                                   pr_dsfinali => pr_dsfinali,
                                   pr_flgteimo => pr_flgteimo,
                                   pr_flgdbpar => pr_flgdbpar,
                                   pr_nrctrrpp => vr_nrctrrpp,
                                   pr_nraplica => vr_nraplica,
                                   pr_rpprowid => vr_rpprowid,
                                   pr_cdcritic => vr_cdcritic,
                                   pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;     
      -- Criar cabeçalho do XML
      dbms_lob.createtemporary(vr_clobxmlc, TRUE); 
      dbms_lob.open(vr_clobxmlc, dbms_lob.lob_readwrite);
      -- Insere o cabeçalho do XML 
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><Dados>');

      gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => 
          '<inf>
           <nrctrrpp>' || TO_CHAR(vr_nrctrrpp) || '</nrctrrpp>
           <nraplica>' || TO_CHAR(vr_nraplica) || '</nraplica>
           <rpprowid>' || vr_rpprowid || '</rpprowid>
           </inf>');

      -- Encerrar a tag raiz 
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '</Dados>' 
                             ,pr_fecha_xml      => TRUE);

      pr_retxml := XMLType.createXML(vr_clobxmlc);
    
    Exception
      When vr_exc_erro Then
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
			  pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        
      When others Then
        pr_cdcritic := null; -- não será utilizado
        pr_dscritic := 'Erro geral em APLI0008.pc_incluir_apl_prog_web: '||SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
      
    END;
  END pc_incluir_apl_prog_web;
 
   PROCEDURE pc_posicao_saldo_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa
                                       ,pr_cdprogra IN crapres.cdprogra%TYPE     --> Programa que esta executando
                                       ,pr_cdoperad IN craplrg.cdoperad%TYPE     --> Codigo do Operador
                                       ,pr_nrdconta IN craprpp.nrdconta%TYPE     --> Numero da conta da aplicacao
                                       ,pr_idseqttl IN INTEGER                   --> Identificador Sequencial
                                       ,pr_idorigem IN INTEGER                   --> Identificador da Origem
                                       ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE     --> Numero do contrato 
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE     --> Data do movimento atual
                                       ,pr_inrendim IN PLS_INTEGER default 1     --> Carrega o rendimento (pr_vlrebtap) [1 - Sim, 0 - Nao]
                                       ,pr_vlbascal OUT NUMBER                   --> Valor Base Total
                                       ,pr_vlsdtoap OUT NUMBER                   --> Valor de Saldo Total
                                       ,pr_vlsdrgap OUT NUMBER                   --> Valor do saldo disponível para resgate
                                       ,pr_vlrebtap OUT NUMBER                   --> Valor de rendimento bruto total
                                       ,pr_vlrdirrf OUT NUMBER                   --> Valor de IRRF
                                       ,pr_des_erro OUT VARCHAR2) IS             --> Saida com erros;
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_posicao_saldo_apl_prog
  --  Sistema  : Captação (Aplicação Programada)
  --  Sigla    : CRED
  --  Autor    : CIS Corporate
  --  Data     : Julho/2018.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: ----
  -- Objetivo  : Procedure para calcular diversos valores de uma aplicacao programada a partir da RPP
  --             Ela é invocada a partir de outras procs. então não revalida cooperativa, cooperado, etc.
  -- Alteracoes:
  --             16/01/2019 - Alterado para receber o parametro flag inrendim indicando se deve buscar
  --             o rendimento, pois o processo pode ser lento e nem sempre sera utilizado (Anderson).
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
     
    -- Recuperar os históricos
    CURSOR cr_crapcpc IS
    SELECT rpp.dtinirpp
          ,cpc.idtippro            
          ,cpc.idtxfixa
          ,cpc.cddindex
          ,cpc.cdhsraap 
          ,cpc.cdhsnrap
          ,cpc.cdhsprap
          ,cpc.cdhsrvap
          ,cpc.cdhsrdap 
          ,cpc.cdhsirap
          ,cpc.cdhsrgap
          ,cpc.cdhsvtap 
     FROM craprpp rpp, crapcpc cpc
    WHERE rpp.cdcooper = pr_cdcooper
      AND rpp.nrdconta = pr_nrdconta
      AND rpp.nrctrrpp = pr_nrctrrpp
      AND rpp.cdprodut = cpc.cdprodut;

      rw_crapcpc cr_crapcpc%ROWTYPE;    
    
      --Selecionar os fundos a partir do numero de contrato de apl. programada
      CURSOR cr_craprac IS
        SELECT rac.nraplica
              ,rac.cdprodut
              ,rac.txaplica 
              ,rac.qtdiacar
              ,rac.dtmvtolt
              ,cpc.idtippro
              ,cpc.idtxfixa
              ,cpc.cddindex 
          FROM craprac rac, crapcpc cpc
         WHERE rac.cdcooper = pr_cdcooper
           AND rac.nrdconta = pr_nrdconta
           AND rac.nrctrrpp = pr_nrctrrpp
           AND rac.cdprodut = cpc.cdprodut;

      rw_craprac cr_craprac%ROWTYPE;
      
      -- Variaveis
      vr_vlsdappr NUMBER(15,2) :=0;
      vr_vlrgappr NUMBER(15,2) :=0;
      vr_vlbascal NUMBER(15,2) :=0;
      vr_vlsldtot NUMBER(15,2) :=0;
      vr_vlsldrgt NUMBER(15,2) :=0;
      vr_vlultren NUMBER(15,2) :=0;
      vr_vlrentot NUMBER(15,2) :=0;
      vr_vlrevers NUMBER(15,2) :=0;
      vr_vlrdirrf NUMBER(15,2) :=0;
      vr_percirrf NUMBER(15,2) :=0;

      vr_vlresgat NUMBER(15,2) :=0;
      vr_vlrendim NUMBER(15,2) :=0;
      
      vr_tab_extrato typ_tab_extrato_apl_prog;

      -- Variaveis de retorno de erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
      vr_exc_erro  EXCEPTION; -- Com rollback
    
    BEGIN
      pr_vlbascal := 0;
      pr_vlsdtoap := 0;
      pr_vlsdrgap := 0;
      pr_vlrebtap := 0;
      pr_vlrdirrf := 0;

      OPEN cr_craprac;
      LOOP
        FETCH cr_craprac
          INTO rw_craprac;
          EXIT WHEN cr_craprac%NOTFOUND;

          BEGIN 
            -- Calcula os juros
            IF rw_craprac.idtippro = 1 THEN 
                -- Consulta saldo de aplicacao pre
                apli0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => pr_cdcooper          -- Codigo da Cooperativa
                                                       ,pr_nrdconta => pr_nrdconta          -- Conta do Cooperado
                                                       ,pr_nraplica => rw_craprac.nraplica  -- Numero da Aplicacao
                                                       ,pr_dtiniapl => rw_craprac.dtmvtolt  -- Data Inicial
                                                       ,pr_txaplica => rw_craprac.txaplica  -- Taxa de Aplicacao
                                                       ,pr_idtxfixa => rw_craprac.idtxfixa  -- Taxa Fixa (0-Nao / 1-Sim)
                                                       ,pr_cddindex => rw_craprac.cddindex  -- Codigo de Indexador
                                                       ,pr_qtdiacar => rw_craprac.qtdiacar  -- Quantidade de Dias de Carencia
                                                       ,pr_idgravir => 0                    -- Imunidade Tributaria
                                                       ,pr_dtinical => rw_craprac.dtmvtolt  -- Data de Inicio do Calculo
                                                       ,pr_dtfimcal => pr_dtmvtolt          -- Data de Fim do Calculo
                                                       ,pr_idtipbas => 2                    -- Tipo Base / 2-Total
                                                       ,pr_vlbascal => vr_vlbascal          -- Valor de Base
                                                       ,pr_vlsldtot => vr_vlsldtot          -- Valor de Saldo Total
                                                       ,pr_vlsldrgt => vr_vlsldrgt          -- Valor de Saldo p/ Resgate
                                                       ,pr_vlultren => vr_vlultren          -- Valor do ultimo rendimento
                                                       ,pr_vlrentot => vr_vlrentot          -- Valor de rendimento total
                                                       ,pr_vlrevers => vr_vlrevers          -- Valor de reversao
                                                       ,pr_vlrdirrf => vr_vlrdirrf          -- Valor de IRRF
                                                       ,pr_percirrf => vr_percirrf          -- Percentual de IRRF
                                                       ,pr_cdcritic => vr_cdcritic          -- Codigo de Critica
                                                       ,pr_dscritic => vr_dscritic);        -- Descricao de Critica
            ELSE 
                -- Consulta saldo de aplicacao pos
                apli0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => pr_cdcooper          -- Codigo da Cooperativa
                                                       ,pr_nrdconta => pr_nrdconta          -- Conta do Cooperado
                                                       ,pr_nraplica => rw_craprac.nraplica  -- Numero da Aplicacao
                                                       ,pr_dtiniapl => rw_craprac.dtmvtolt  -- Data de Movimento
                                                       ,pr_txaplica => rw_craprac.txaplica  -- Taxa de Aplicacao
                                                       ,pr_idtxfixa => rw_craprac.idtxfixa  -- Taxa Fixa (0-Nao / 1-Sim)
                                                       ,pr_cddindex => rw_craprac.cddindex  -- Codigo de Indexador
                                                       ,pr_qtdiacar => rw_craprac.qtdiacar  -- Quantidade de Dias de Carencia
                                                       ,pr_idgravir => 0                    -- Imunidade Tributaria
                                                       ,pr_dtinical => rw_craprac.dtmvtolt  -- Data de Inicio do Calculo
                                                       ,pr_dtfimcal => pr_dtmvtolt          -- Data de Fim do Calculo
                                                       ,pr_idtipbas => 2                    -- Tipo Base / 2-Total
                                                       ,pr_vlbascal => vr_vlbascal          -- Valor de Base
                                                       ,pr_vlsldtot => vr_vlsldtot          -- Valor de Saldo Total
                                                       ,pr_vlsldrgt => vr_vlsldrgt          -- Valor de Saldo p/ Resgate
                                                       ,pr_vlultren => vr_vlultren          -- Valor do ultimo rendimento
                                                       ,pr_vlrentot => vr_vlrentot          -- Valor de rendimento total
                                                       ,pr_vlrevers => vr_vlrevers          -- Valor de reversao
                                                       ,pr_vlrdirrf => vr_vlrdirrf          -- Valor de IRRF
                                                       ,pr_percirrf => vr_percirrf          -- Percentual de IRRF
                                                       ,pr_cdcritic => vr_cdcritic          -- Codigo de Critica
                                                       ,pr_dscritic => vr_dscritic);        -- Descricao de Critica
            END IF;
            IF pr_des_erro is not null THEN
               EXIT;
            END IF;
            pr_vlbascal := pr_vlbascal + vr_vlbascal;  -- Base de Cálculo
            pr_vlsdrgap := pr_vlsdrgap + vr_vlsldrgt;  -- Saldo Resgate
            pr_vlsdtoap := pr_vlsdtoap + vr_vlsldtot;  -- Saldo Total
            pr_vlrdirrf := pr_vlrdirrf + vr_vlrdirrf;  -- Valor IRRF total
          END;
        END LOOP;
      CLOSE cr_craprac;
      -- Recupera informações de datas e históricos. Nao existe a possibilidade de ocorrer um not found aqui
      OPEN cr_crapcpc;
      FETCH cr_crapcpc
          INTO rw_crapcpc;
      CLOSE cr_crapcpc;
      
      /* Se solicitado, busca o rendimento */
      IF pr_inrendim = 1 THEN
      -- Calcula o rendimento bruto total
      pc_buscar_extrato_apl_prog (pr_cdcooper => pr_cdcooper
                                 ,pr_cdoperad => pr_cdoperad
                                 ,pr_nmdatela => pr_cdprogra
                                 ,pr_idorigem => pr_idorigem
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_idseqttl => pr_idseqttl
                                 ,pr_nrctrrpp => pr_nrctrrpp
                                 ,pr_dtmvtolt_ini => rw_crapcpc.dtinirpp
                                 ,pr_dtmvtolt_fim => pr_dtmvtolt
                                 ,pr_idlstdhs => 1
                                 ,pr_idgerlog => 0
                                 ,pr_tab_extrato => vr_tab_extrato
                                 ,pr_vlresgat => vr_vlresgat
                                 ,pr_vlrendim => vr_vlrendim
                                 ,pr_vldoirrf => vr_vlrdirrf
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
        IF pr_des_erro is null and vr_dscritic is null THEN
          IF vr_tab_extrato.count >0 THEN
            FOR vr_idx_extrato in vr_tab_extrato.first .. vr_tab_extrato.last LOOP
                IF vr_tab_extrato(vr_idx_extrato).cdhistor in (rw_crapcpc.cdhsprap,rw_crapcpc.cdhsrdap) THEN -- Provisao do mês e rendimento
                   pr_vlrebtap := pr_vlrebtap + vr_tab_extrato(vr_idx_extrato).vllanmto;  
                ELSIF vr_tab_extrato(vr_idx_extrato).cdhistor in (rw_crapcpc.cdhsirap,rw_crapcpc.cdhsrvap) THEN -- IRRF e Ajuste Previsão
                   pr_vlrebtap := pr_vlrebtap - vr_tab_extrato(vr_idx_extrato).vllanmto;  
                END IF;
            END LOOP;
          END IF;
      END IF;
      END IF;
    END;
  END pc_posicao_saldo_apl_prog;
 
  PROCEDURE pc_calc_saldo_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa
                                   ,pr_cdprogra IN crapres.cdprogra%TYPE     --> Programa que esta executando
                                   ,pr_cdoperad IN craplrg.cdoperad%TYPE     --> Codigo do Operador
                                   ,pr_nrdconta IN craprpp.nrdconta%TYPE     --> Numero da conta da aplicacao
                                   ,pr_idseqttl IN INTEGER                   --> Identificador Sequencial
                                   ,pr_idorigem IN INTEGER                   --> Identificador da Origem
                                   ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE     --> Numero do contrato poupanca
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE     --> Data do movimento atual
                                   ,pr_vlsdrdpp IN OUT craprpp.vlsdrdpp%TYPE  --> Valor do saldo para resgate da poupanca programada
                                   ,pr_des_erro OUT VARCHAR2) IS             --> Saida com erros;
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_calc_saldo_apl_prog
  --  Sistema  : Captação (Aplicação Programada)
  --  Sigla    : CRED
  --  Autor    : CIS Corporate
  --  Data     : Julho/2018.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: ----
  -- Objetivo  : Procedure para calcular o saldo de uma aplicacao programada a partir da RPP
  --             Ela é invocada a partir de outras procs. então não revalida cooperativa, cooperado, etc.
  -- Alteracoes:
  --             16/01/2019 - Alterado para passar a flag inrendim = 0 para nao carregar o rendimento, pois nao 
  --             o campo nao eh nem retornado no output desta procedure (Anderson).
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_vlbascal NUMBER(15,2) :=0;
      vr_vlsdtoap NUMBER(15,2) :=0;
      vr_vlrebtap NUMBER(15,2) :=0;
      vr_vlrdirrf NUMBER(15,2) :=0;
    
    BEGIN
      pc_posicao_saldo_apl_prog(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => pr_cdprogra
                                               ,pr_cdoperad => pr_cdoperad
                                               ,pr_nrdconta => pr_nrdconta
                                               ,pr_idseqttl => pr_idseqttl
                               ,pr_idorigem => pr_idorigem
                               ,pr_nrctrrpp => pr_nrctrrpp
                                               ,pr_dtmvtolt => pr_dtmvtolt
                               ,pr_inrendim => 0             -- Nao precisa carregar rendimento
                               ,pr_vlbascal => vr_vlbascal
                               ,pr_vlsdtoap => vr_vlsdtoap
                               ,pr_vlsdrgap => pr_vlsdrdpp
                               ,pr_vlrebtap => vr_vlrebtap
                               ,pr_vlrdirrf => vr_vlrdirrf
                               ,pr_des_erro => pr_des_erro);


    END;
  END pc_calc_saldo_apl_prog;
  
  PROCEDURE pc_calc_saldo_apl_prog_web (pr_nrdconta IN craprac.nrdconta%TYPE   -- Número da Conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE   -- Titular da Conta
                                       ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE   -- Número da Aplicação Programada.
                                       ,pr_dtmvtolt IN VARCHAR2                -- Data de Movimento Inicial
                                       ,pr_xmllog   IN VARCHAR2                -- XML com informacoes de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER            -- Código da crítica
                                       ,pr_dscritic OUT VARCHAR2               -- Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2               -- Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2)              -- Erros do processo

  IS
  BEGIN
   /* .............................................................................

   Programa: pc_calc_saldo_apl_prog_web
   Sistema : Novos Produtos de Captação - Aplicação Programada
   Sigla   : APLI
   Autor   : CIS Corporate
   Data    : Julho/2018.                    Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Procedure para calcular o saldo de uma aplicacao programada a partir da RPP - Mensageria. 

   Observacao: -----

   Alteracoes: 
  ..............................................................................*/                

  DECLARE
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    -- Variaveis auxiliares
    vr_exc_erro EXCEPTION;

    -- Variaveis de entrada
    vr_dtmvtolt Date := TO_DATE(pr_dtmvtolt,'dd/mm/yyyy');  

    -- Variaveis de retorno
    
    vr_vlsdrdpp NUMBER (15,2) := 0;
    vr_vlbascal NUMBER(15,2) :=0;
    vr_vlsdtoap NUMBER(15,2) :=0;
    vr_vlrebtap NUMBER(15,2) :=0;
    vr_vlrdirrf NUMBER(15,2) :=0;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

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
      RAISE vr_exc_erro;
    END IF;     

    -- Busca as informações da apl. programada
    pc_posicao_saldo_apl_prog(pr_cdcooper => vr_cdcooper
                           ,pr_cdprogra => vr_nmdatela
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_idseqttl => pr_idseqttl
                           ,pr_idorigem => vr_idorigem
                           ,pr_nrctrrpp => pr_nrctrrpp
                           ,pr_dtmvtolt => vr_dtmvtolt
                             ,pr_vlbascal => vr_vlbascal
                             ,pr_vlsdtoap => vr_vlsdtoap
                             ,pr_vlsdrgap => vr_vlsdrdpp
                             ,pr_vlrebtap => vr_vlrebtap        --> Valor de rendimento bruto total
                             ,pr_vlrdirrf => vr_vlrdirrf
                           ,pr_des_erro => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;     
    -- Criar cabeçalho do XML
    dbms_lob.createtemporary(vr_clobxmlc, TRUE); 
    dbms_lob.open(vr_clobxmlc, dbms_lob.lob_readwrite);
    -- Insere o cabeçalho do XML 
    gene0002.pc_escreve_xml (pr_xml            => vr_clobxmlc 
                            ,pr_texto_completo => vr_xml_temp 
                            ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>');
     gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc
                           ,pr_texto_completo => vr_xml_temp 
                           ,pr_texto_novo     => 
                           '<Registro>'||
                           '<vlsdrdpp>'||vr_vlsdrdpp||'</vlsdrdpp>'||
                           '</Registro>'
                           );
    -- Encerrar a tag raiz 
    gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc 
                            ,pr_texto_completo => vr_xml_temp 
                            ,pr_texto_novo     => '</Dados></Root>' 
                            ,pr_fecha_xml      => TRUE);
                                  
    pr_retxml := XMLType.createXML(vr_clobxmlc);

  Exception
    When vr_exc_erro Then
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        
    When others Then
      pr_cdcritic := null; -- não será utilizado
      pr_dscritic := 'Erro geral em APLI0008.pc_calc_saldo_apl_prog_web: '||SQLERRM;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      
  END;

  END pc_calc_saldo_apl_prog_web;
  
  PROCEDURE pc_calc_saldo_ini_apl_prog (pr_cdcooper IN craprac.cdcooper%TYPE                  -- Código da Cooperativa
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE                  -- Código do Operador 
                                       ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                       ,pr_idorigem IN NUMBER                                 -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                       ,pr_nrdconta IN craprac.nrdconta%TYPE                  -- Número da Conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE                  -- Titular da Conta
                                       ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE                  -- Número da Aplicação Programada.
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE                  -- Data de Movimento 
                                       ,pr_idgerlog IN NUMBER                                 -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                       ,pr_vlsdrdpp OUT NUMBER                                -- Saldo em pr_dtmvtolt-1
                                       ,pr_vlresgat OUT NUMBER                                -- Valor de resgate
                                       ,pr_vlrendim OUT NUMBER                                -- Valor de rendimento
                                       ,pr_vldoirrf OUT NUMBER                                -- Valor do IRRF 
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE                 -- Código da crítica
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE                 -- Descrição da crítica
   ) IS
    BEGIN
     /* .............................................................................

     Programa: pc_calc_saldo_ini_apl_prog
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : CIS Corporate
     Data    : Julho/2018.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Calcular o saldo inicial a partir da data da compra, passando por todos os lançamentos

     Observacao: -----

     Alteracoes: 
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
      vr_dstransa VARCHAR2(100) := 'Busca saldo inicial da aplicacao programada contrato #: ' || pr_nrctrrpp;
      vr_dsorigem VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_nrdrowid ROWID;
      vr_vlresgat NUMBER :=0;
      vr_vlrendim NUMBER :=0;
      vr_vldoirrf NUMBER :=0;
      vr_vlsldtot NUMBER :=0;
      vr_qtdiasir PLS_INTEGER := 0; -- Qtd de dias para calculo de faixa de IR
      vr_percirrf NUMBER;
      vr_txlancto NUMBER;
      vr_txacumul NUMBER;
      vr_txacumes NUMBER;
      
        
      -- Busca Aplicações de captação com seus lançamentos
      CURSOR cr_craplac IS
          SELECT 
                 lac.nraplica,
                 rac.dtmvtolt dtmvtolt_rac,
                 lac.dtmvtolt dtmvtolt_lac,
                 rac.txaplica,
                 rac.qtdiacar,
                 cpc.idtippro,            
                 cpc.idtxfixa,
                 cpc.cddindex,
                 cpc.cdhsraap, 
                 cpc.cdhsnrap,
                 cpc.cdhsprap,
                 cpc.cdhsrvap,
                 cpc.cdhsrdap, 
                 cpc.cdhsirap,
                 cpc.cdhsrgap,
                 cpc.cdhsvtap,
                 lac.vllanmto,
                 lac.cdhistor
            FROM craprac rac, craplac lac, crapcpc cpc
           WHERE rac.cdcooper = pr_cdcooper
             AND rac.nrdconta = pr_nrdconta
             AND rac.nrctrrpp = pr_nrctrrpp
             AND rac.cdprodut = cpc.cdprodut
             AND rac.cdcooper = lac.cdcooper
             AND rac.nrdconta = lac.nrdconta
             AND rac.nraplica = lac.nraplica
             AND lac.dtmvtolt <= (pr_dtmvtolt - 1)
           ORDER BY lac.dtmvtolt, lac.cdhistor;
      
      rw_craplac cr_craplac%ROWTYPE;
       
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

       BEGIN -- Principal
           -- Carregada as faixas de IR para uso posterior             
           apli0001.pc_busca_faixa_ir_rdc(pr_cdcooper => pr_cdcooper);

           -- Para cada registro de lançamento de aplicação de captação                                                                    
           FOR rw_craplac IN cr_craplac LOOP
                IF rw_craplac.idtippro = 1 THEN -- Pré-fixada
                    -- Buscar as taxas acumuladas da aplicação
                    apli0006.pc_taxa_acumul_aplic_pre(pr_cdcooper => pr_cdcooper,              --> Código da Cooperativa
                                                      pr_txaplica => rw_craplac.txaplica,      --> Taxa da Aplicação
                                                      pr_idtxfixa => rw_craplac.idtxfixa,      --> Taxa Fixa (1-SIM/2-NAO)
                                                      pr_cddindex => rw_craplac.cddindex,      --> Código do Indexador
                                                      pr_dtinical => rw_craplac.dtmvtolt_rac,  --> Data Inicial Cálculo
                                                      pr_dtfimcal => pr_dtmvtolt,              --> Data Final Cálculo 
                                                      pr_txacumul => vr_txacumul,              --> Taxa acumulada durante o período total da aplicação
                                                      pr_txacumes => vr_txacumes,              --> Taxa acumulada durante o mês vigente
                                                      pr_cdcritic => vr_cdcritic,              --> Código da crítica
                                                      pr_dscritic => vr_dscritic);             --> Descrição da crítica
                ELSIF rw_craplac.idtippro = 2 THEN -- Pós-fixada
                    -- Buscar as taxas acumuladas da aplicação
                    apli0006.pc_taxa_acumul_aplic_pos(pr_cdcooper => pr_cdcooper,              --> Código da Cooperativa
                                                      pr_txaplica => rw_craplac.txaplica,      --> Taxa da Aplicação
                                                      pr_idtxfixa => rw_craplac.idtxfixa,      --> Taxa Fixa (1-SIM/2-NAO)
                                                      pr_cddindex => rw_craplac.cddindex,      --> Código do Indexador
                                                      pr_dtinical => rw_craplac.dtmvtolt_rac,  --> Data Inicial Cálculo 
                                                      pr_dtfimcal => pr_dtmvtolt,              --> Data Final Cálculo 
                                                      pr_txacumul => vr_txacumul,              --> Taxa acumulada durante o período total da aplicação
                                                      pr_txacumes => vr_txacumes,              --> Taxa acumulada durante o mês vigente
                                                      pr_cdcritic => vr_cdcritic,              --> Código da crítica
                                                      pr_dscritic => vr_dscritic);             --> Descrição da crítica
                END IF;
                IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                   RAISE vr_exc_saida;
                END IF;                                   
                IMUT0001.pc_verifica_periodo_imune (pr_cdcooper  => pr_cdcooper   --> Codigo Cooperativa
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
                vr_qtdiasir := pr_dtmvtolt - rw_craplac.dtmvtolt_rac;
                -- Consulta faixas de IR
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

                -- Verificar se o histórico de lançamento está cadastrado na tabela craphis
                OPEN cr_craphis (pr_cdcooper => pr_cdcooper
                                ,pr_cdhistor => rw_craplac.cdhistor);
                FETCH cr_craphis INTO rw_craphis;

                IF cr_craphis%NOTFOUND THEN
                    vr_cdcritic := 526; -- Histórico não encontrado
                    CLOSE cr_craphis;
                    RAISE vr_exc_saida;
                END IF;
                CLOSE cr_craphis;
                        
                -- Verifica a quantidade de dias para saber o IR 
                vr_qtdiasir := rw_craplac.dtmvtolt_lac - rw_craplac.dtmvtolt_rac;
                  
                -- Consulta faixas de IR
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
                IF rw_craplac.cdhistor = rw_craplac.cdhsrgap THEN    /* Resgate */
                     vr_vlresgat := NVL(vr_vlresgat,0) + rw_craplac.vllanmto;
                ELSIF rw_craplac.cdhistor = rw_craplac.cdhsprap THEN /* Rendimento */
                     vr_vlrendim := NVL(vr_vlrendim,0) + rw_craplac.vllanmto;
                ELSIF rw_craplac.cdhistor = rw_craplac.cdhsirap THEN /* IRRF */
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
                IF vr_flgimune = TRUE AND vr_dttermin IS NULL THEN --Se o cooperado ainda está imune, utiliza a data de movimento */
                   vr_dttermin := pr_dtmvtolt;
                END IF;                

                IF rw_craplac.cdhistor = rw_craplac.cdhsrdap THEN /* Rendimento */
                     vr_txlancto := rw_craplac.txaplica;
                ELSIF rw_craplac.cdhistor = rw_craplac.cdhsirap THEN /* IRRF */                     
                     vr_txlancto := vr_percirrf;
                ELSE /* Demais lançamentos */
                     vr_txlancto := 0; 
                END IF;
           END LOOP; -- CRAPLAC
           -- Alimenta parâmetros
           pr_vlsdrdpp := vr_vlsldtot;
           pr_vlresgat := vr_vlresgat;
           pr_vlrendim := vr_vlrendim;
           pr_vldoirrf := vr_vldoirrf;
        
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
                 pr_dscritic := 'Erro nao tratado APLI0008.pc_cal_saldo_ini_apl_prog: ' || SQLERRM;
                 ROLLBACK; 
                 -- Verifica se deve gerar log
                 IF pr_idgerlog = 1 THEN
                    GENE0001.pc_gera_log (pr_cdcooper => pr_cdcooper
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
       END; -- Principal
  END pc_calc_saldo_ini_apl_prog;
   
  PROCEDURE pc_buscar_extrato_apl_prog (pr_cdcooper IN craprac.cdcooper%TYPE                  -- Código da Cooperativa
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE                  -- Código do Operador 
                                       ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                       ,pr_idorigem IN NUMBER                                 -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                       ,pr_nrdconta IN craprac.nrdconta%TYPE                  -- Número da Conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE                  -- Titular da Conta
                                       ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE                  -- Número da Aplicação Programada.
                                       ,pr_dtmvtolt_ini IN crapdat.dtmvtolt%TYPE              -- Data de Movimento - Inicio
                                       ,pr_dtmvtolt_fim IN crapdat.dtmvtolt%TYPE              -- Data de Movimento - Fim
                                       ,pr_idlstdhs IN NUMBER                                 -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                       ,pr_idgerlog IN NUMBER                                 -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                       ,pr_tab_extrato OUT apli0008.typ_tab_extrato_apl_prog  -- PLTable com os dados de extrato
                                       ,pr_vlresgat OUT NUMBER                                -- Valor de resgate
                                       ,pr_vlrendim OUT NUMBER                                -- Valor de rendimento
                                       ,pr_vldoirrf OUT NUMBER                                -- Valor do IRRF 
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE                 -- Código da crítica
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE                 -- Descrição da crítica
   ) IS
    BEGIN
     /* .............................................................................

     Programa: pc_buscar_extrato_apl_prog
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : CIS Corporate
     Data    : Julho/2018.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de extratos das aplicações programadas de forma consolidada.
                 Utilizada na ATENDA
                 Derivada de apli0005.pc_busca_extrato_aplicacao

     Observacao: -----

     Alteracoes: 16/01/2019 - Remocao da chamada das procedures apli0006.pc_taxa_acumul_aplic_pos e _pre
	                          pois seu output nao eh utilizado (Anderson).
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
      vr_dstransa VARCHAR2(100) := 'Busca extrato da aplicacao programada contrato #: ' || pr_nrctrrpp;
      vr_dsorigem VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_nrdrowid ROWID;
      vr_lshistor VARCHAR2(200);            
      vr_vlresgat NUMBER;
      vr_vlresgat_calc NUMBER;
      vr_vlrendim NUMBER;
      vr_vldoirrf NUMBER;
      vr_vlsldtot NUMBER := 0;
      vr_dshistor craphis.dshistor%TYPE;
      vr_dsextrat craphis.dsextrat%TYPE;
      vr_qtdiasir PLS_INTEGER := 0; -- Qtd de dias para calculo de faixa de IR
      vr_percirrf NUMBER;
      vr_txlancto NUMBER;
      
      vr_saldo_imp PLS_INTEGER := 0;   -- Saldo anterior impresso?
      vr_vlsdrdpp_ant NUMBER := 0;     -- Valor Saldo anterior
      
      -- PLTable que conterá os dados do extrato
      vr_tab_extrato_temp apli0008.typ_tab_extrato_apl_prog;
      vr_tab_extrato apli0008.typ_tab_extrato_apl_prog;
      vr_ind_extrato PLS_INTEGER := 0;
        
      -- Busca Aplicações de captação com seus lançamentos
      CURSOR cr_craplac (pr_cdcooper IN craprac.cdcooper%TYPE,
                         pr_nrdconta IN craprac.nrdconta%TYPE,
                         pr_nrctrrpp IN craprac.nrctrrpp%TYPE) IS
          SELECT 
                 lac.nraplica,
                 rac.dtmvtolt dtmvtolt_rac,
                 lac.dtmvtolt dtmvtolt_lac,
                 lac.nrdolote,
                 lac.cdbccxlt,
                 rac.txaplica,
                 rac.qtdiacar,
                 cpc.idtippro,            
                 cpc.idtxfixa,
                 cpc.cddindex,
                 cpc.cdhsraap, 
                 cpc.cdhsnrap,
                 cpc.cdhsprap,
                 cpc.cdhsrvap,
                 cpc.cdhsrdap, 
                 cpc.cdhsirap,
                 cpc.cdhsrgap,
                 cpc.cdhsvtap,
                 lac.vllanmto,
                 lac.cdhistor,
                 lac.cdagenci,
                 lac.nrdocmto
            FROM craprac rac, craplac lac, crapcpc cpc
           WHERE rac.cdcooper = pr_cdcooper
             AND rac.nrdconta = pr_nrdconta
             AND rac.nrctrrpp = pr_nrctrrpp
             AND rac.cdprodut = cpc.cdprodut
             AND rac.cdcooper = lac.cdcooper
             AND rac.nrdconta = lac.nrdconta
             AND rac.nraplica = lac.nraplica
             AND lac.dtmvtolt <= pr_dtmvtolt_fim
           ORDER BY lac.dtmvtolt, lac.cdhistor;
      
      rw_craplac cr_craplac%ROWTYPE;
       
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

       BEGIN -- Principal
           -- Carregada as faixas de IR para uso posterior             
           apli0001.pc_busca_faixa_ir_rdc(pr_cdcooper => pr_cdcooper);

           -- Para cada registro de lançamento de aplicação de captação                                                                    
           FOR rw_craplac IN cr_craplac (pr_cdcooper => pr_cdcooper        --> Cooperativa
                                         ,pr_nrdconta => pr_nrdconta       --> Nr. da conta
                                         ,pr_nrctrrpp => pr_nrctrrpp)      --> Nr. do contrato (RPP)
           LOOP
                -- Se parâmetro pr_idlstdhs for igual 1, listar todos os históricos
                IF pr_idlstdhs = 1 THEN
                    vr_lshistor := to_char(rw_craplac.cdhsraap) || ',' || -- CR. Plano poup
                                   to_char(rw_craplac.cdhsnrap) || ',' || -- CR. Plano poup
                                   to_char(rw_craplac.cdhsprap) || ',' || -- Previsao Mes
                                   to_char(rw_craplac.cdhsrvap) || ',' || -- Reversão
                                   to_char(rw_craplac.cdhsrdap) || ',' || -- Rendimento
                                   to_char(rw_craplac.cdhsirap) || ',' || -- DB.IRRF
                                   to_char(rw_craplac.cdhsrgap) || ',' || -- Resgate
                                   to_char(rw_craplac.cdhsvtap);          -- Resg. RDCPOS
                -- Se parâmetro pr_idlstdhs for igual 0, não listar históricos de reversão e rendimento
                ELSIF pr_idlstdhs = 0 THEN
                    vr_lshistor := to_char(rw_craplac.cdhsraap) || ',' || 
                                   to_char(rw_craplac.cdhsnrap) || ',' || 
                                   to_char(rw_craplac.cdhsprap) || ',' || 
                                   to_char(rw_craplac.cdhsirap) || ',' || 
                                   to_char(rw_craplac.cdhsrgap) || ',' || 
                                   to_char(rw_craplac.cdhsvtap);
                END IF;

                IMUT0001.pc_verifica_periodo_imune (pr_cdcooper  => pr_cdcooper   --> Codigo Cooperativa
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
                vr_qtdiasir := pr_dtmvtolt_fim - rw_craplac.dtmvtolt_rac;
                  
                -- Consulta faixas de IR
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

                -- Verificar se o histórico de lançamento está cadastrado na tabela craphis
                OPEN cr_craphis (pr_cdcooper => pr_cdcooper
                                ,pr_cdhistor => rw_craplac.cdhistor);
                FETCH cr_craphis INTO rw_craphis;

                IF cr_craphis%NOTFOUND THEN
                    vr_cdcritic := 526; -- Histórico não encontrado
                    CLOSE cr_craphis;
                    RAISE vr_exc_saida;
                END IF;
                CLOSE cr_craphis;
                        
                -- Verifica a quantidade de dias para saber o IR -
                vr_qtdiasir := rw_craplac.dtmvtolt_lac - rw_craplac.dtmvtolt_rac;
                  
                -- Consulta faixas de IR
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
                IF rw_craplac.cdhistor = rw_craplac.cdhsrgap THEN    /* Resgate */
                     vr_vlresgat := NVL(vr_vlresgat,0) + rw_craplac.vllanmto;
                ELSIF rw_craplac.cdhistor = rw_craplac.cdhsprap THEN /* Rendimento */
                     vr_vlrendim := NVL(vr_vlrendim,0) + rw_craplac.vllanmto;
                ELSIF rw_craplac.cdhistor = rw_craplac.cdhsirap THEN /* IRRF */
                     vr_vldoirrf := NVL(vr_vldoirrf,0) + rw_craplac.vllanmto;
                END IF;
                IF rw_craphis.indebcre = 'C' THEN     /* Crédito */
                     vr_vlsldtot := NVL(vr_vlsldtot,0) + rw_craplac.vllanmto;
                ELSIF rw_craphis.indebcre = 'D' THEN  /* Débito  */
                      vr_vlsldtot := NVL(vr_vlsldtot,0) - rw_craplac.vllanmto;  
                     /*
                      IF (rw_craplac.cdhistor = rw_craplac.cdhsrvap) -- Reversao
                      AND (rw_craplac.dtmvtolt_lac - rw_craplac.dtmvtolt_rac >=  rw_craplac.qtdiacar) THEN -- Fora do período de carência
                          vr_vlsldtot := NVL(vr_vlsldtot,0) -- Não faz nada
                      ELSE
                          vr_vlsldtot := NVL(vr_vlsldtot,0) - rw_craplac.vllanmto;
                      END IF; */
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
                        vr_dttermin := pr_dtmvtolt_fim;
                    END IF;
                    -- Se o cooperado tinha imunidade tributária na data do lançamento do rendimento
                    IF rw_craplac.cdhistor  = rw_craplac.cdhsrdap AND
                         rw_craplac.dtmvtolt_lac >= vr_dtinicio AND
                         rw_craplac.dtmvtolt_lac <= vr_dttermin THEN
                        -- O carácter * é apresentado junto a descrição do histórico
                        vr_dshistor := vr_dshistor || '*';
                        vr_dsextrat := vr_dsextrat || '*';
                    END IF;
                END IF;                
                IF rw_craplac.cdhistor = rw_craplac.cdhsrdap THEN /* Rendimento */
                     vr_txlancto := rw_craplac.txaplica;
                ELSIF rw_craplac.cdhistor = rw_craplac.cdhsirap THEN /* IRRF */                     
                     vr_txlancto := vr_percirrf;
                ELSE /* Demais lançamentos */
                     vr_txlancto := 0; 
                END IF;
                
                IF gene0002.fn_existe_valor(vr_lshistor,rw_craplac.cdhistor,',') = 'S' THEN
                   IF (vr_saldo_imp=0 AND (rw_craplac.dtmvtolt_lac >= pr_dtmvtolt_ini)) THEN -- Saldo anterior ainda nao foi impresso mas ja pode
                      vr_ind_extrato :=  1;
                      vr_tab_extrato_temp(vr_ind_extrato).dtmvtolt := pr_dtmvtolt_ini;
                      vr_tab_extrato_temp(vr_ind_extrato).cdagenci := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).cdhistor := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).dshistor := 'SALDO ANTERIOR';
                      vr_tab_extrato_temp(vr_ind_extrato).aghistor := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).dsextrat := 'SALDO ANTERIOR';
                      vr_tab_extrato_temp(vr_ind_extrato).nrdocmto := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).indebcre := '';
                      vr_tab_extrato_temp(vr_ind_extrato).vllanmto := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).vlsldtot := vr_vlsdrdpp_ant;
                      vr_tab_extrato_temp(vr_ind_extrato).txlancto := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).nraplica := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).cdbccxlt := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).nrdolote := 0;
                      vr_saldo_imp:=1;
                   END IF;
                   IF vr_saldo_imp=1 THEN 
                      -- Incrementa indice da PLTable de extrato
                      vr_ind_extrato := vr_tab_extrato_temp.count() + 1;
                      vr_tab_extrato_temp(vr_ind_extrato).dtmvtolt := rw_craplac.dtmvtolt_lac;
                      vr_tab_extrato_temp(vr_ind_extrato).cdagenci := rw_craplac.cdagenci;
                      vr_tab_extrato_temp(vr_ind_extrato).cdhistor := rw_craphis.cdhistor;
                      IF rw_craphis.cdhistor IN 
                                             (rw_craplac.cdhsprap
                                             ,rw_craplac.cdhsrgap
                                             ,rw_craplac.cdhsrvap
                                             ,rw_craplac.cdhsrdap
                                             ,rw_craplac.cdhsirap) THEN
                         vr_tab_extrato_temp(vr_ind_extrato).aghistor := 1; -- Acumula
                      ELSE
                         vr_tab_extrato_temp(vr_ind_extrato).aghistor := 0; -- Nao Acumula
                      END IF;
                      vr_tab_extrato_temp(vr_ind_extrato).dshistor := vr_dshistor;
                      vr_tab_extrato_temp(vr_ind_extrato).dsextrat := vr_dsextrat;
                      vr_tab_extrato_temp(vr_ind_extrato).nrdocmto := rw_craplac.nrdocmto;
                      vr_tab_extrato_temp(vr_ind_extrato).indebcre := rw_craphis.indebcre;
                      vr_tab_extrato_temp(vr_ind_extrato).vllanmto := rw_craplac.vllanmto;
                      vr_tab_extrato_temp(vr_ind_extrato).vlsldtot := vr_vlsldtot;
                      vr_tab_extrato_temp(vr_ind_extrato).txlancto := vr_txlancto;
                      vr_tab_extrato_temp(vr_ind_extrato).nraplica := rw_craplac.nraplica;
                      vr_tab_extrato_temp(vr_ind_extrato).cdbccxlt := rw_craplac.cdbccxlt;
                      vr_tab_extrato_temp(vr_ind_extrato).nrdolote := rw_craplac.nrdolote;
                   END IF;
                END IF;
                vr_vlsdrdpp_ant := vr_vlsldtot;
           END LOOP; -- CRAPLAC
           IF vr_tab_extrato_temp.count>0 THEN
               -- Junta as provisões e resgates
               vr_ind_extrato :=  0;
               FOR vr_ind_extrato_temp in vr_tab_extrato_temp.First .. vr_tab_extrato_temp.Last
                 LOOP
                   IF vr_tab_extrato_temp(vr_ind_extrato_temp).aghistor = 1  
                   AND (vr_tab_extrato_temp(vr_ind_extrato_temp).dtmvtolt = vr_tab_extrato(vr_ind_extrato).dtmvtolt)
                   AND (vr_tab_extrato_temp(vr_ind_extrato_temp).cdagenci = vr_tab_extrato(vr_ind_extrato).cdagenci)
                   AND (vr_tab_extrato_temp(vr_ind_extrato_temp).cdhistor = vr_tab_extrato(vr_ind_extrato).cdhistor) THEN -- Acumular
                        vr_tab_extrato(vr_ind_extrato).nrdocmto := null;
                        vr_tab_extrato(vr_ind_extrato).vllanmto := vr_tab_extrato(vr_ind_extrato).vllanmto + vr_tab_extrato_temp(vr_ind_extrato_temp).vllanmto;
                        IF vr_tab_extrato_temp(vr_ind_extrato_temp).indebcre = 'C' THEN
                        vr_tab_extrato(vr_ind_extrato).vlsldtot := vr_tab_extrato(vr_ind_extrato).vlsldtot + vr_tab_extrato_temp(vr_ind_extrato_temp).vllanmto;
                   ELSE
                           vr_tab_extrato(vr_ind_extrato).vlsldtot := vr_tab_extrato(vr_ind_extrato).vlsldtot - vr_tab_extrato_temp(vr_ind_extrato_temp).vllanmto;
                        END IF;
                   ELSE
                      vr_ind_extrato := vr_tab_extrato.count() + 1;
                      vr_tab_extrato(vr_ind_extrato).dtmvtolt := vr_tab_extrato_temp(vr_ind_extrato_temp).dtmvtolt;
                      vr_tab_extrato(vr_ind_extrato).cdagenci := vr_tab_extrato_temp(vr_ind_extrato_temp).cdagenci;
                      vr_tab_extrato(vr_ind_extrato).cdhistor := vr_tab_extrato_temp(vr_ind_extrato_temp).cdhistor;
                      vr_tab_extrato(vr_ind_extrato).dshistor := vr_tab_extrato_temp(vr_ind_extrato_temp).dshistor;
                      vr_tab_extrato(vr_ind_extrato).aghistor := vr_tab_extrato_temp(vr_ind_extrato_temp).aghistor;
                      vr_tab_extrato(vr_ind_extrato).dsextrat := vr_tab_extrato_temp(vr_ind_extrato_temp).dsextrat;
                      vr_tab_extrato(vr_ind_extrato).nrdocmto := vr_tab_extrato_temp(vr_ind_extrato_temp).nrdocmto;
                      vr_tab_extrato(vr_ind_extrato).indebcre := vr_tab_extrato_temp(vr_ind_extrato_temp).indebcre;
                      vr_tab_extrato(vr_ind_extrato).vllanmto := vr_tab_extrato_temp(vr_ind_extrato_temp).vllanmto;
                      vr_tab_extrato(vr_ind_extrato).vlsldtot := vr_tab_extrato_temp(vr_ind_extrato_temp).vlsldtot;
                      vr_tab_extrato(vr_ind_extrato).txlancto := vr_tab_extrato_temp(vr_ind_extrato_temp).txlancto;
                      vr_tab_extrato(vr_ind_extrato).nraplica := vr_tab_extrato_temp(vr_ind_extrato_temp).nraplica;
                      vr_tab_extrato(vr_ind_extrato).cdbccxlt := vr_tab_extrato_temp(vr_ind_extrato_temp).cdbccxlt;
                      vr_tab_extrato(vr_ind_extrato).nrdolote := vr_tab_extrato_temp(vr_ind_extrato_temp).nrdolote;
                   END IF;
               END LOOP;
           END IF;
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
                 pr_dscritic := 'Erro nao tratado APLI0008.pc_buscar_extrato_apl_prog: ' || SQLERRM;
                 ROLLBACK; 
                 -- Verifica se deve gerar log
                 IF pr_idgerlog = 1 THEN
                    GENE0001.pc_gera_log (pr_cdcooper => pr_cdcooper
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
       END; -- Principal
  END pc_buscar_extrato_apl_prog;
  
  PROCEDURE pc_buscar_extrato_apl_prog_web (pr_nrdconta IN craprac.nrdconta%TYPE   -- Número da Conta
                                           ,pr_idseqttl IN crapttl.idseqttl%TYPE   -- Titular da Conta
                                           ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE   -- Número da Aplicação Programada.
                                           ,pr_dtmvtolt_ini IN VARCHAR2            -- Data de Movimento Inicial
                                           ,pr_dtmvtolt_fim IN VARCHAR2            -- Data de Movimento Fim
                                           ,pr_idlstdhs IN NUMBER                  -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                           ,pr_idgerlog IN NUMBER                  -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                           ,pr_xmllog   IN VARCHAR2                -- XML com informacoes de LOG
                                           ,pr_cdcritic OUT PLS_INTEGER            -- Código da crítica
                                           ,pr_dscritic OUT VARCHAR2               -- Descrição da crítica
                                           ,pr_retxml   IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                           ,pr_nmdcampo OUT VARCHAR2               -- Nome do campo com erro
                                           ,pr_des_erro OUT VARCHAR2)              -- Erros do processo


  IS
  BEGIN
   /* .............................................................................

   Programa: pc_buscar_extrato_apl_prog_web
   Sistema : Novos Produtos de Captação
   Sigla   : APLI
   Autor   : CIS Corporate
   Data    : Julho/2018.                    Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Rotina referente a busca de extratos das aplicações programadas. 

   Observacao: -----

   Alteracoes: 
  ..............................................................................*/                

  DECLARE
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    -- Variaveis auxiliares
    vr_exc_erro EXCEPTION;

    -- Variaveis de entrada
    vr_dtmvtolt_ini Date := TO_DATE(pr_dtmvtolt_ini,'DD/MM/YYYY');  
    vr_dtmvtolt_fim Date := TO_DATE(pr_dtmvtolt_fim,'DD/MM/YYYY');  

    -- Variaveis de retorno
    pr_tab_extrato apli0008.typ_tab_extrato_apl_prog;
    vr_vlresgat NUMBER (15,2);
    vr_vlrendim NUMBER (15,2);
    vr_vldoirrf NUMBER (15,2);
    vr_percirrf NUMBER (15,2);

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

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
      RAISE vr_exc_erro;
    END IF;     

    -- Busca o extrato da apl. programada
    pc_buscar_extrato_apl_prog (pr_cdcooper => vr_cdcooper
                               ,pr_cdoperad => vr_cdoperad
                               ,pr_nmdatela => vr_nmdatela
                               ,pr_idorigem => vr_idorigem
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_idseqttl => pr_idseqttl
                               ,pr_nrctrrpp => pr_nrctrrpp
                               ,pr_dtmvtolt_ini => vr_dtmvtolt_ini
                               ,pr_dtmvtolt_fim => vr_dtmvtolt_fim
                               ,pr_idlstdhs => pr_idlstdhs
                               ,pr_idgerlog => pr_idgerlog
                               ,pr_tab_extrato => pr_tab_extrato
                               ,pr_vlresgat => vr_vlresgat
                               ,pr_vlrendim => vr_vlrendim
                               ,pr_vldoirrf => vr_vldoirrf
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;     
    -- Criar cabeçalho do XML
    dbms_lob.createtemporary(vr_clobxmlc, TRUE); 
    dbms_lob.open(vr_clobxmlc, dbms_lob.lob_readwrite);
    -- Insere o cabeçalho do XML 
    gene0002.pc_escreve_xml (pr_xml            => vr_clobxmlc 
                            ,pr_texto_completo => vr_xml_temp 
                            ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>');
      
    IF pr_tab_extrato.count >0 THEN
       FOR ctLinha in pr_tab_extrato.First .. pr_tab_extrato.Last LOOP
           gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc
                                  ,pr_texto_completo => vr_xml_temp 
                                  ,pr_texto_novo     => 
                                  '<Registro>'||
                                  '<dtmvtolt>'||to_char(pr_tab_extrato(ctLinha).dtmvtolt,'dd/mm/yyyy')||'</dtmvtolt>'||
                                  '<dshistor>'||pr_tab_extrato(ctLinha).dshistor||'</dshistor>'||
                                  '<nrdocmto>'||pr_tab_extrato(ctLinha).nrdocmto||'</nrdocmto>'||
                                  '<indebcre>'||pr_tab_extrato(ctLinha).indebcre||'</indebcre>'||
                                  '<vllanmto>'||pr_tab_extrato(ctLinha).vllanmto||'</vllanmto>'||
                                  '<vlsldppr>'||pr_tab_extrato(ctLinha).vlsldtot||'</vlsldppr>'||
                                  '<txaplica>0</txaplica>'||
                                  '<txaplmes>0</txaplmes>'||
                                  '<cdagenci>'||pr_tab_extrato(ctLinha).cdagenci||'</cdagenci>'||
                                  '<cdbccxlt>'||pr_tab_extrato(ctLinha).cdbccxlt||'</cdbccxlt>'||
                                  '<nrdolote>'||pr_tab_extrato(ctLinha).nrdolote||'</nrdolote>'||
                                  '<dsextrat>'||pr_tab_extrato(ctLinha).dsextrat||'</dsextrat>'||
                                  '</Registro>'
                                  );
       END LOOP;
    END IF;
       -- Encerrar a tag raiz 
       gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '</Dados></Root>' 
                               ,pr_fecha_xml      => TRUE);
                                 
       pr_retxml := XMLType.createXML(vr_clobxmlc);

  Exception
    When vr_exc_erro Then
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        
    When others Then
      pr_cdcritic := null; -- não será utilizado
      pr_dscritic := 'Erro geral em APLI0008.pc_buscar_extrato_apl_prog_web: '||SQLERRM;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      
  END;

  END pc_buscar_extrato_apl_prog_web;

  PROCEDURE pc_buscar_extrato_apl_prog_car (pr_cdcooper IN craprac.cdcooper%TYPE                  -- Código da Cooperativa
                                           ,pr_cdoperad IN crapope.cdoperad%TYPE                  -- Código do Operador 
                                           ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                           ,pr_idorigem IN NUMBER   -- Código de Origem
                                           ,pr_nrdconta IN craprac.nrdconta%TYPE   -- Número da Conta
                                           ,pr_idseqttl IN crapttl.idseqttl%TYPE   -- Titular da Conta
                                           ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE   -- Número da Aplicação Programada.
                                           ,pr_dtmvtolt_ini IN DATE            -- Data de Movimento Inicial
                                           ,pr_dtmvtolt_fim IN DATE            -- Data de Movimento Fim
                                           ,pr_idlstdhs IN NUMBER                  -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                           ,pr_idgerlog IN NUMBER                  -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                           ,pr_xmllog   IN VARCHAR2                -- XML com informacoes de LOG
                                           ,pr_cdcritic OUT PLS_INTEGER            -- Código da crítica
                                           ,pr_dscritic OUT VARCHAR2               -- Descrição da crítica
                                           ,pr_clobxmlc   OUT CLOB                   -- Arquivo de retorno do XML
                                           ,pr_nmdcampo OUT VARCHAR2               -- Nome do campo com erro
                                           ,pr_des_erro OUT VARCHAR2)              -- Erros do processo


  IS
  BEGIN
   /* .............................................................................

   Programa: pc_buscar_extrato_apl_prog_car
   Sistema : Novos Produtos de Captação
   Sigla   : APLI
   Autor   : CIS Corporate
   Data    : Julho/2018.                    Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Rotina referente a busca de extratos das aplicações programadas. 

   Observacao: -----

   Alteracoes: 
  ..............................................................................*/                

  DECLARE
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    -- Variaveis auxiliares
    vr_exc_erro EXCEPTION;

    -- Variaveis de retorno
    pr_tab_extrato apli0008.typ_tab_extrato_apl_prog;
    vr_vlresgat NUMBER (15,2);
    vr_vlrendim NUMBER (15,2);
    vr_vldoirrf NUMBER (15,2);
    vr_percirrf NUMBER (15,2);

    -- Variaveis de log
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);

    -- Variaveis de XML 
    vr_xml_temp VARCHAR2(32767);
    
  BEGIN
    -- Busca o extrato da apl. programada
    pc_buscar_extrato_apl_prog (pr_cdcooper => pr_cdcooper
                               ,pr_cdoperad => pr_cdoperad
                               ,pr_nmdatela => pr_nmdatela
                               ,pr_idorigem => pr_idorigem
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_idseqttl => pr_idseqttl
                               ,pr_nrctrrpp => pr_nrctrrpp
                               ,pr_dtmvtolt_ini => pr_dtmvtolt_ini
                               ,pr_dtmvtolt_fim => pr_dtmvtolt_fim
                               ,pr_idlstdhs => 1
                               ,pr_idgerlog => pr_idgerlog
                               ,pr_tab_extrato => pr_tab_extrato
                               ,pr_vlresgat => vr_vlresgat
                               ,pr_vlrendim => vr_vlrendim
                               ,pr_vldoirrf => vr_vldoirrf
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;     
    -- Criar cabeçalho do XML
    dbms_lob.createtemporary(pr_clobxmlc, TRUE); 
    dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);
    -- Insere o cabeçalho do XML 
    gene0002.pc_escreve_xml (pr_xml            => pr_clobxmlc 
                            ,pr_texto_completo => vr_xml_temp 
                            ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>');
      
    IF pr_tab_extrato.count >0 THEN
       FOR ctLinha in pr_tab_extrato.First .. pr_tab_extrato.Last LOOP
           gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                                  ,pr_texto_completo => vr_xml_temp 
                                  ,pr_texto_novo     => 
                                  '<Registro>'||
                                  '<dtmvtolt>'||to_char(pr_tab_extrato(ctLinha).dtmvtolt,'dd/mm/yyyy')||'</dtmvtolt>'||
                                  '<dshistor>'||pr_tab_extrato(ctLinha).dshistor||'</dshistor>'||
                                  '<nrdocmto>'||pr_tab_extrato(ctLinha).nrdocmto||'</nrdocmto>'||
                                  '<indebcre>'||pr_tab_extrato(ctLinha).indebcre||'</indebcre>'||
                                  '<vllanmto>'||pr_tab_extrato(ctLinha).vllanmto||'</vllanmto>'||
                                  '<vlsldppr>'||pr_tab_extrato(ctLinha).vlsldtot||'</vlsldppr>'||
                                  '<txaplica>0</txaplica>'||
                                  '<txaplmes>0</txaplmes>'||
                                  '<cdagenci>'||pr_tab_extrato(ctLinha).cdagenci||'</cdagenci>'||
                                  '<cdbccxlt>'||pr_tab_extrato(ctLinha).cdbccxlt||'</cdbccxlt>'||
                                  '<nrdolote>'||pr_tab_extrato(ctLinha).nrdolote||'</nrdolote>'||
                                  '<dsextrat>'||pr_tab_extrato(ctLinha).dsextrat||'</dsextrat>'||
                                  '</Registro>'
                                  );
       END LOOP;
    END IF;
       -- Encerrar a tag raiz 
       gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '</Dados></Root>' 
                               ,pr_fecha_xml      => TRUE);
                                 
  Exception
    When vr_exc_erro Then
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
        
    When others Then
      pr_cdcritic := null; -- não será utilizado
      pr_dscritic := 'Erro geral em APLI0008.pc_buscar_extrato_apl_prog_web: '||SQLERRM;
      
  END;

  END pc_buscar_extrato_apl_prog_car;

  PROCEDURE pc_gerar_ext_apl_prog_titulo (pr_cdcooper IN craprac.cdcooper%TYPE                  -- Código da Cooperativa
                                         ,pr_cdoperad IN crapope.cdoperad%TYPE                  -- Código do Operador 
                                         ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                         ,pr_idorigem IN NUMBER                                 -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                         ,pr_nrdconta IN craprac.nrdconta%TYPE                  -- Número da Conta
                                         ,pr_idseqttl IN crapttl.idseqttl%TYPE                  -- Titular da Conta
                                         ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE                  -- Número da Aplicação Programada.
                                         ,pr_nraplica IN craprac.nraplica%TYPE                  -- Número da Aplicacao
                                         ,pr_dtmvtolt_ini IN crapdat.dtmvtolt%TYPE              -- Data de Movimento - Inicio
                                         ,pr_dtmvtolt_fim IN crapdat.dtmvtolt%TYPE              -- Data de Movimento - Fim
                                         ,pr_idlstdhs IN NUMBER                                 -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                         ,pr_idgerlog IN NUMBER                                 -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                         ,pr_tab_extrato OUT apli0008.typ_tab_extrato_apl_prog  -- PLTable com os dados de extrato
                                         ,pr_vlresgat OUT NUMBER                                -- Valor de resgate
                                         ,pr_vlrendim OUT NUMBER                                -- Valor de rendimento
                                         ,pr_vldoirrf OUT NUMBER                                -- Valor do IRRF 
                                         ,pr_percirrf OUT NUMBER                                -- Valor de aliquota de IR
                                         ,pr_txacumul OUT NUMBER                                -- Taxa acumulada durante o período total da aplicação
                                         ,pr_txacumes OUT NUMBER                                -- Taxa acumulada durante o mês vigente
                                         ,pr_qtdiacar OUT craprac.qtdiacar%TYPE                 -- Qtd. dias carência
                                         ,pr_dtfimcar OUT DATE                                  -- Data fim da carência
                                         ,pr_dtvencto OUT DATE                                  -- Data de vencimento 
                                         ,pr_qtdiaprz OUT craprac.qtdiaprz%TYPE                 -- Quantidade de dias do prazo da modalidade
                                         ,pr_qtdiaapl OUT craprac.qtdiaapl%TYPE                 -- Quantidade de dias da aplicacao
                                         ,pr_txaplica OUT craprac.txaplica%TYPE                 -- Taxa contratada da aplicacao
                                         ,pr_nmdindex OUT crapind.nmdindex%TYPE                 -- Nome do Indice  
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE                 -- Código da crítica
                                         ,pr_dscritic OUT crapcri.dscritic%TYPE                 -- Descrição da crítica
   
   ) IS
    BEGIN
     /* .............................................................................

     Programa: pc_extrato_apl_prog_titulo
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : CIS Corporate
     Data    : Agposto/2018.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de extratos das aplicações programadas 

     Observacao: -----

     Alteracoes: 
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
      vr_dstransa VARCHAR2(100) := 'Busca extrato da aplicacao programada contrato #: ' || pr_nrctrrpp;
      vr_dsorigem VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_nrdrowid ROWID;
      vr_lshistor VARCHAR2(200);            
      vr_vlresgat NUMBER := 0;
      vr_vlresgat_calc NUMBER := 0;
      vr_vlrendim NUMBER := 0;
      vr_vldoirrf NUMBER := 0;
      vr_vlsldtot NUMBER := 0;
      vr_dshistor craphis.dshistor%TYPE;
      vr_dsextrat craphis.dsextrat%TYPE;
      vr_qtdiasir PLS_INTEGER := 0; -- Qtd de dias para calculo de faixa de IR
      vr_percirrf NUMBER := 0;
      vr_txlancto NUMBER := 0;
      vr_txacumul NUMBER := 0;
      vr_txacumes NUMBER := 0;
      vr_saldo_imp PLS_INTEGER := 0;   -- Saldo anterior impresso?
      vr_vlsdrdpp_ant NUMBER := 0;     -- Valor Saldo anterior
      
      -- PLTable que conterá os dados do extrato
      vr_tab_extrato_temp apli0008.typ_tab_extrato_apl_prog;
      vr_tab_extrato apli0008.typ_tab_extrato_apl_prog;
      vr_ind_extrato PLS_INTEGER := 0;

      -- Busca Detalhes do fundo
      CURSOR cr_craprac IS
          SELECT
              rac.dtmvtolt,
              rac.dtvencto,
              rac.qtdiacar,
              (rac.dtmvtolt+rac.qtdiacar) dtfimcar,
              rac.qtdiaprz,
              rac.qtdiaapl,
              rac.txaplica,
              ind.nmdindex
          FROM
              craprac rac, crapcpc cpc, crapind ind
        WHERE rac.cdcooper=pr_cdcooper
          AND rac.nrdconta=pr_nrdconta 
          AND rac.nrctrrpp=pr_nrctrrpp
          AND rac.nraplica=pr_nraplica
          AND rac.cdprodut=cpc.cdprodut
          AND cpc.cddindex=ind.cddindex;
          
      rw_craprac cr_craprac%ROWTYPE;   

      -- Busca Aplicações de captação com seus lançamentos
      CURSOR cr_craplac IS
          SELECT 
                 lac.nraplica,
                 rac.dtmvtolt dtmvtolt_rac,
                 lac.dtmvtolt dtmvtolt_lac,
                 lac.nrdolote,
                 lac.cdbccxlt,
                 cpc.idtippro,            
                 cpc.idtxfixa,
                 cpc.cddindex,
                 cpc.cdhsraap, 
                 cpc.cdhsnrap,
                 cpc.cdhsprap,
                 cpc.cdhsrvap,
                 cpc.cdhsrdap, 
                 cpc.cdhsirap,
                 cpc.cdhsrgap,
                 cpc.cdhsvtap,
                 lac.vllanmto,
                 lac.cdhistor,
                 lac.cdagenci,
                 lac.nrdocmto
            FROM craprac rac, craplac lac, crapcpc cpc
           WHERE rac.cdcooper = pr_cdcooper
             AND rac.nrdconta = pr_nrdconta
             AND rac.nrctrrpp = pr_nrctrrpp
             AND rac.nraplica = pr_nraplica
             AND rac.cdprodut = cpc.cdprodut
             AND rac.cdcooper = lac.cdcooper
             AND rac.nrdconta = lac.nrdconta
             AND rac.nraplica = lac.nraplica
             AND lac.dtmvtolt <= pr_dtmvtolt_fim
           ORDER BY lac.dtmvtolt, lac.cdhistor;
      
      rw_craplac cr_craplac%ROWTYPE;
       
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

       BEGIN -- Principal
           -- Carrega informações sobre os títulos
           OPEN cr_craprac;
           FETCH cr_craprac INTO rw_craprac;
           IF cr_craprac%NOTFOUND THEN
              CLOSE cr_craprac;
              RAISE vr_exc_saida;
           END IF;
           CLOSE cr_craprac;

           -- Carregada as faixas de IR para uso posterior             
           apli0001.pc_busca_faixa_ir_rdc(pr_cdcooper => pr_cdcooper);

           -- Para cada registro de lançamento de aplicação de captação                                                                    
           FOR rw_craplac IN cr_craplac
           LOOP
                IF rw_craplac.idtippro = 1 THEN -- Pré-fixada
                    -- Buscar as taxas acumuladas da aplicação
                    apli0006.pc_taxa_acumul_aplic_pre(pr_cdcooper => pr_cdcooper,              --> Código da Cooperativa
                                                      pr_txaplica => rw_craprac.txaplica,      --> Taxa da Aplicação
                                                      pr_idtxfixa => rw_craplac.idtxfixa,      --> Taxa Fixa (1-SIM/2-NAO)
                                                      pr_cddindex => rw_craplac.cddindex,      --> Código do Indexador
                                                      pr_dtinical => rw_craplac.dtmvtolt_rac,  --> Data Inicial Cálculo
                                                      pr_dtfimcal => pr_dtmvtolt_fim,          --> Data Final Cálculo 
                                                      pr_txacumul => vr_txacumul,              --> Taxa acumulada durante o período total da aplicação
                                                      pr_txacumes => vr_txacumes,              --> Taxa acumulada durante o mês vigente
                                                      pr_cdcritic => vr_cdcritic,              --> Código da crítica
                                                      pr_dscritic => vr_dscritic);             --> Descrição da crítica
                                                                                                    
                    IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                       RAISE vr_exc_saida;
                    END IF;
                ELSIF rw_craplac.idtippro = 2 THEN -- Pós-fixada
                    -- Buscar as taxas acumuladas da aplicação
                    apli0006.pc_taxa_acumul_aplic_pos(pr_cdcooper => pr_cdcooper,              --> Código da Cooperativa
                                                      pr_txaplica => rw_craprac.txaplica,      --> Taxa da Aplicação
                                                      pr_idtxfixa => rw_craplac.idtxfixa,      --> Taxa Fixa (1-SIM/2-NAO)
                                                      pr_cddindex => rw_craplac.cddindex,      --> Código do Indexador
                                                      pr_dtinical => rw_craplac.dtmvtolt_rac,  --> Data Inicial Cálculo 
                                                      pr_dtfimcal => pr_dtmvtolt_fim,          --> Data Final Cálculo 
                                                      pr_txacumul => vr_txacumul,              --> Taxa acumulada durante o período total da aplicação
                                                      pr_txacumes => vr_txacumes,              --> Taxa acumulada durante o mês vigente
                                                      pr_cdcritic => vr_cdcritic,              --> Código da crítica
                                                      pr_dscritic => vr_dscritic);             --> Descrição da crítica

                    IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                       RAISE vr_exc_saida;
                    END IF;                                   
                END IF;
                -- Se parâmetro pr_idlstdhs for igual 1, listar todos os históricos
                IF pr_idlstdhs = 1 THEN
                    vr_lshistor := to_char(rw_craplac.cdhsraap) || ',' || -- CR. Plano poup
                                   to_char(rw_craplac.cdhsnrap) || ',' || -- CR. Plano poup
                                   to_char(rw_craplac.cdhsprap) || ',' || -- Previsao Mes
                                   to_char(rw_craplac.cdhsrvap) || ',' || -- Reversão
                                   to_char(rw_craplac.cdhsrdap) || ',' || -- Rendimento
                                   to_char(rw_craplac.cdhsirap) || ',' || -- DB.IRRF
                                   to_char(rw_craplac.cdhsrgap) || ',' || -- Resgate
                                   to_char(rw_craplac.cdhsvtap);          -- Resg. RDCPOS
                -- Se parâmetro pr_idlstdhs for igual 0, não listar históricos de reversão e rendimento
                ELSIF pr_idlstdhs = 0 THEN
                    vr_lshistor := to_char(rw_craplac.cdhsraap) || ',' || 
                                   to_char(rw_craplac.cdhsnrap) || ',' || 
                                   to_char(rw_craplac.cdhsprap) || ',' || 
                                   to_char(rw_craplac.cdhsirap) || ',' || 
                                   to_char(rw_craplac.cdhsrgap) || ',' || 
                                   to_char(rw_craplac.cdhsvtap);
                END IF;

                IMUT0001.pc_verifica_periodo_imune (pr_cdcooper  => pr_cdcooper   --> Codigo Cooperativa
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
                vr_qtdiasir := pr_dtmvtolt_fim - rw_craplac.dtmvtolt_rac;
                  
                -- Consulta faixas de IR
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

                -- Verificar se o histórico de lançamento está cadastrado na tabela craphis
                OPEN cr_craphis (pr_cdcooper => pr_cdcooper
                                ,pr_cdhistor => rw_craplac.cdhistor);
                FETCH cr_craphis INTO rw_craphis;

                IF cr_craphis%NOTFOUND THEN
                    vr_cdcritic := 526; -- Histórico não encontrado
                    CLOSE cr_craphis;
                    RAISE vr_exc_saida;
                END IF;
                CLOSE cr_craphis;
                        
                -- Verifica a quantidade de dias para saber o IR -
                vr_qtdiasir := rw_craplac.dtmvtolt_lac - rw_craplac.dtmvtolt_rac;
                  
                -- Consulta faixas de IR
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
                IF rw_craplac.cdhistor = rw_craplac.cdhsrgap THEN    /* Resgate */
                     vr_vlresgat := NVL(vr_vlresgat,0) + rw_craplac.vllanmto;
                ELSIF rw_craplac.cdhistor = rw_craplac.cdhsprap THEN /* Rendimento */
                     vr_vlrendim := NVL(vr_vlrendim,0) + rw_craplac.vllanmto;
                ELSIF rw_craplac.cdhistor = rw_craplac.cdhsirap THEN /* IRRF */
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
                        vr_dttermin := pr_dtmvtolt_fim;
                    END IF;
                    -- Se o cooperado tinha imunidade tributária na data do lançamento do rendimento
                    IF rw_craplac.cdhistor  = rw_craplac.cdhsrdap AND
                         rw_craplac.dtmvtolt_lac >= vr_dtinicio AND
                         rw_craplac.dtmvtolt_lac <= vr_dttermin THEN
                        -- O carácter * é apresentado junto a descrição do histórico
                        vr_dshistor := vr_dshistor || '*';
                        vr_dsextrat := vr_dsextrat || '*';
                    END IF;
                END IF;                
                IF rw_craplac.cdhistor = rw_craplac.cdhsrdap THEN /* Rendimento */
                     vr_txlancto := rw_craprac.txaplica;
                ELSIF rw_craplac.cdhistor = rw_craplac.cdhsirap THEN /* IRRF */                     
                     vr_txlancto := vr_percirrf;
                ELSE /* Demais lançamentos */
                     vr_txlancto := 0; 
                END IF;
                
                IF gene0002.fn_existe_valor(vr_lshistor,rw_craplac.cdhistor,',') = 'S' THEN
                   IF (vr_saldo_imp=0 AND (rw_craplac.dtmvtolt_lac >= pr_dtmvtolt_ini)) THEN -- Saldo anterior ainda nao foi impresso mas ja pode
                      vr_ind_extrato :=  1;
                      vr_tab_extrato_temp(vr_ind_extrato).dtmvtolt := pr_dtmvtolt_ini;
                      vr_tab_extrato_temp(vr_ind_extrato).cdagenci := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).cdhistor := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).dshistor := 'SALDO ANTERIOR';
                      vr_tab_extrato_temp(vr_ind_extrato).aghistor := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).dsextrat := 'SALDO ANTERIOR';
                      vr_tab_extrato_temp(vr_ind_extrato).nrdocmto := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).indebcre := '';
                      vr_tab_extrato_temp(vr_ind_extrato).vllanmto := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).vlsldtot := vr_vlsdrdpp_ant;
                      vr_tab_extrato_temp(vr_ind_extrato).txlancto := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).nraplica := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).cdbccxlt := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).nrdolote := 0;
                      vr_saldo_imp:=1;
                   END IF;
                   IF vr_saldo_imp=1 THEN 
                      -- Incrementa indice da PLTable de extrato
                      vr_ind_extrato := vr_tab_extrato_temp.count() + 1;
                      vr_tab_extrato_temp(vr_ind_extrato).dtmvtolt := rw_craplac.dtmvtolt_lac;
                      vr_tab_extrato_temp(vr_ind_extrato).cdagenci := rw_craplac.cdagenci;
                      vr_tab_extrato_temp(vr_ind_extrato).cdhistor := rw_craphis.cdhistor;
                      vr_tab_extrato_temp(vr_ind_extrato).aghistor := 0; -- Nao Acumula
                      vr_tab_extrato_temp(vr_ind_extrato).dshistor := vr_dshistor;
                      vr_tab_extrato_temp(vr_ind_extrato).dsextrat := vr_dsextrat;
                      vr_tab_extrato_temp(vr_ind_extrato).nrdocmto := rw_craplac.nrdocmto;
                      vr_tab_extrato_temp(vr_ind_extrato).indebcre := rw_craphis.indebcre;
                      vr_tab_extrato_temp(vr_ind_extrato).vllanmto := rw_craplac.vllanmto;
                      vr_tab_extrato_temp(vr_ind_extrato).vlsldtot := vr_vlsldtot;
                      vr_tab_extrato_temp(vr_ind_extrato).txlancto := vr_txlancto;
                      vr_tab_extrato_temp(vr_ind_extrato).nraplica := rw_craplac.nraplica;
                      vr_tab_extrato_temp(vr_ind_extrato).cdbccxlt := rw_craplac.cdbccxlt;
                      vr_tab_extrato_temp(vr_ind_extrato).nrdolote := rw_craplac.nrdolote;
                   END IF;
                END IF;
                vr_vlsdrdpp_ant := vr_vlsldtot;
           END LOOP; -- CRAPLAC
           IF vr_tab_extrato_temp.count>0 THEN
               -- Junta as provisões e resgates
               vr_ind_extrato :=  0;
               FOR vr_ind_extrato_temp in vr_tab_extrato_temp.First .. vr_tab_extrato_temp.Last
                 LOOP
                    vr_ind_extrato := vr_tab_extrato.count() + 1;
                    vr_tab_extrato(vr_ind_extrato).dtmvtolt := vr_tab_extrato_temp(vr_ind_extrato_temp).dtmvtolt;
                    vr_tab_extrato(vr_ind_extrato).cdagenci := vr_tab_extrato_temp(vr_ind_extrato_temp).cdagenci;
                    vr_tab_extrato(vr_ind_extrato).cdhistor := vr_tab_extrato_temp(vr_ind_extrato_temp).cdhistor;
                    vr_tab_extrato(vr_ind_extrato).dshistor := vr_tab_extrato_temp(vr_ind_extrato_temp).dshistor;
                    vr_tab_extrato(vr_ind_extrato).aghistor := vr_tab_extrato_temp(vr_ind_extrato_temp).aghistor;
                    vr_tab_extrato(vr_ind_extrato).dsextrat := vr_tab_extrato_temp(vr_ind_extrato_temp).dsextrat;
                    vr_tab_extrato(vr_ind_extrato).nrdocmto := vr_tab_extrato_temp(vr_ind_extrato_temp).nrdocmto;
                    vr_tab_extrato(vr_ind_extrato).indebcre := vr_tab_extrato_temp(vr_ind_extrato_temp).indebcre;
                    vr_tab_extrato(vr_ind_extrato).vllanmto := vr_tab_extrato_temp(vr_ind_extrato_temp).vllanmto;
                    vr_tab_extrato(vr_ind_extrato).vlsldtot := vr_tab_extrato_temp(vr_ind_extrato_temp).vlsldtot;
                    vr_tab_extrato(vr_ind_extrato).txlancto := vr_tab_extrato_temp(vr_ind_extrato_temp).txlancto;
                    vr_tab_extrato(vr_ind_extrato).nraplica := vr_tab_extrato_temp(vr_ind_extrato_temp).nraplica;
                    vr_tab_extrato(vr_ind_extrato).cdbccxlt := vr_tab_extrato_temp(vr_ind_extrato_temp).cdbccxlt;
                    vr_tab_extrato(vr_ind_extrato).nrdolote := vr_tab_extrato_temp(vr_ind_extrato_temp).nrdolote;
               END LOOP;
           END IF;
           -- Alimenta parâmetros
           pr_vlresgat := vr_vlresgat;
           pr_vlrendim := vr_vlrendim;
           pr_vldoirrf := vr_vldoirrf;
           pr_percirrf := vr_percirrf;
           pr_txacumul := vr_txacumul;
           pr_txacumes := vr_txacumes;  
           pr_qtdiacar := rw_craprac.qtdiacar;
           pr_dtfimcar := rw_craprac.dtfimcar;
           pr_dtvencto := rw_craprac.dtvencto;
           pr_qtdiaprz := rw_craprac.qtdiaprz;
           pr_qtdiaapl := rw_craprac.qtdiaapl;
           pr_txaplica := rw_craprac.txaplica;
           pr_nmdindex := rw_craprac.nmdindex;
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
                 pr_dscritic := 'Erro nao tratado APLI0008.pc_buscar_extrato_apl_prog: ' || SQLERRM;
                 ROLLBACK; 
                 -- Verifica se deve gerar log
                 IF pr_idgerlog = 1 THEN
                    GENE0001.pc_gera_log (pr_cdcooper => pr_cdcooper
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
       END; -- Principal
  END pc_gerar_ext_apl_prog_titulo;
          
  PROCEDURE pc_buscar_detalhe_apl_prog (pr_cdcooper IN craprac.cdcooper%TYPE                  -- Código da Cooperativa
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE                  -- Código do Operador 
                                       ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                       ,pr_idorigem IN NUMBER                                 -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                       ,pr_nrdconta IN craprac.nrdconta%TYPE                  -- Número da Conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE                  -- Titular da Conta
                                       ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE                  -- Número da Aplicação Programada
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE                  -- Data de Movimento
                                       ,pr_tab_dados_rpp OUT apli0001.typ_tab_dados_rpp       -- PLTable com os detalhes;
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE                 -- Código da crítica
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE                 -- Descrição da crítica
   ) IS
    BEGIN
     /* .............................................................................

     Programa: pc_buscar_detalhe_apl_prog
     Sistema : Novos Produtos de Captação - Aplicação Programada
     Sigla   : APLI
     Autor   : CIS Corporate
     Data    : Julho/2018.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de detalhes de uma aplicação programada

     Observacao: -----

     Alteracoes: 
    ..............................................................................*/                
      
      DECLARE
        
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
            
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;      
            
      --Variáveis locais
      vr_vlsdrdpp NUMBER(25,8):=0;
      vr_vlsdtoap NUMBER(25,8):=0;
      vr_vlsdrgap NUMBER(25,8):=0;
      vr_vlrebtap NUMBER(25,8):=0;
      vr_vlrdirrf NUMBER(25,8):=0;
      vr_vlbascal NUMBER(25,8):=0;
      -- PLTable de retorno
      
      vr_tab_dados_rpp APLI0001.typ_tab_dados_rpp;
        
      -- Busca Aplicações de captação com seus lançamentos
      CURSOR cr_craprpp IS
      SELECT 
              nrctrrpp,
              cdagenci,
              nrdolote,
              cdbccxlt,
              dtmvtolt,
              dtvctopp,
              dtdebito,
              Extract(day from dtdebito) indiadeb,
              vlprerpp,
              qtprepag,
              vlprepag,
              vlrgtacu,
              dtinirpp,
              dtrnirpp,
              dtaltrpp,
              dtcancel,
         CASE cdsitrpp 
             WHEN 1 THEN 'Ativa'
             WHEN 2 THEN 'Suspensa'
             WHEN 3 THEN 'Cancelada'
             WHEN 4 THEN 'Cancelada' -- Suspensa e depois cancelada
             WHEN 5 THEN 'Vencida'  
             ELSE null END dssitrpp,
         CASE flgctain
             WHEN 0 THEN 'Sim'
             ELSE 'Nao' END flgctain
        FROM craprpp 
       WHERE cdcooper=pr_cdcooper 
         AND nrdconta=pr_nrdconta
         AND nrctrrpp=pr_nrctrrpp;
      rw_craprpp cr_craprpp%ROWTYPE;
      BEGIN -- Principal
          -- Recupera as informações do último movimento da da Apl. Programada
          OPEN cr_craprpp;
          FETCH cr_craprpp INTO rw_craprpp;
          IF cr_craprpp%NOTFOUND THEN
              vr_dscritic:='Aplicacao Programada nao encontrada';
              CLOSE cr_craprpp;
              RAISE vr_exc_saida;
          END IF;
          CLOSE cr_craprpp;
          -- Calcula o saldo atual

        pc_posicao_saldo_apl_prog(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => pr_nmdatela
                                 ,pr_cdoperad => pr_cdoperad
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_idseqttl => pr_idseqttl
                                 ,pr_idorigem => pr_idorigem
                                 ,pr_nrctrrpp => pr_nrctrrpp
                                 ,pr_dtmvtolt => pr_dtmvtolt
                                 ,pr_vlbascal => vr_vlbascal
                                 ,pr_vlsdtoap => vr_vlsdtoap
                                 ,pr_vlsdrgap => vr_vlsdrdpp
                                 ,pr_vlrebtap => vr_vlrebtap
                                 ,pr_vlrdirrf => vr_vlrdirrf
                                 ,pr_des_erro => vr_dscritic);

          IF vr_dscritic is not null THEN
              RAISE vr_exc_saida;
          END IF;

          vr_tab_dados_rpp(1).nrctrrpp:=rw_craprpp.nrctrrpp;
          vr_tab_dados_rpp(1).cdagenci:=rw_craprpp.cdagenci;
          vr_tab_dados_rpp(1).cdbccxlt:=rw_craprpp.cdbccxlt;
          vr_tab_dados_rpp(1).nrdolote:=rw_craprpp.nrdolote;
          vr_tab_dados_rpp(1).dtmvtolt:=rw_craprpp.dtmvtolt;
          vr_tab_dados_rpp(1).dtvctopp:=rw_craprpp.dtvctopp;
          vr_tab_dados_rpp(1).dtdebito:=rw_craprpp.dtdebito;
          vr_tab_dados_rpp(1).indiadeb:=rw_craprpp.indiadeb;
          vr_tab_dados_rpp(1).vlprerpp:=rw_craprpp.vlprerpp;
          vr_tab_dados_rpp(1).qtprepag:=rw_craprpp.qtprepag;
          vr_tab_dados_rpp(1).vlprepag:=rw_craprpp.vlprepag;
          vr_tab_dados_rpp(1).vlrgtacu:=rw_craprpp.vlrgtacu;
          vr_tab_dados_rpp(1).vlsdrdpp:=vr_vlsdrdpp;
          vr_tab_dados_rpp(1).vljuracu:=vr_vlrebtap;
          vr_tab_dados_rpp(1).dtinirpp:=rw_craprpp.dtinirpp;
          vr_tab_dados_rpp(1).dtrnirpp:=rw_craprpp.dtrnirpp;
          vr_tab_dados_rpp(1).dtaltrpp:=rw_craprpp.dtaltrpp;
          vr_tab_dados_rpp(1).dtcancel:=rw_craprpp.dtcancel;
          vr_tab_dados_rpp(1).dssitrpp:=rw_craprpp.dssitrpp;
          vr_tab_dados_rpp(1).dsctainv:=rw_craprpp.flgctain;

          pr_tab_dados_rpp := vr_tab_dados_rpp;
      EXCEPTION
          WHEN vr_exc_saida THEN
               IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
               END IF;

               -- Alimenta parametros com a crítica ocorrida
               pr_cdcritic := vr_cdcritic;
               pr_dscritic := vr_dscritic;

          WHEN OTHERS THEN
               pr_cdcritic := vr_cdcritic;
               pr_dscritic := 'Erro nao tratado APLI0008.pc_buscar_detalhe_apl_prog: ' || SQLERRM;

      END; -- Principal
  END pc_buscar_detalhe_apl_prog;
  
  PROCEDURE pc_buscar_detalhe_apl_prog_web (pr_nrdconta IN craprac.nrdconta%TYPE   -- Número da Conta
                                           ,pr_idseqttl IN crapttl.idseqttl%TYPE   -- Titular da Conta
                                           ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE   -- Número da Aplicação Programada.
                                           ,pr_dtmvtolt IN VARCHAR2                -- Data de Movimento Inicial
                                           ,pr_xmllog   IN VARCHAR2                -- XML com informacoes de LOG
                                           ,pr_cdcritic OUT PLS_INTEGER            -- Código da crítica
                                           ,pr_dscritic OUT VARCHAR2               -- Descrição da crítica
                                           ,pr_retxml   IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                           ,pr_nmdcampo OUT VARCHAR2               -- Nome do campo com erro
                                           ,pr_des_erro OUT VARCHAR2)              -- Erros do processo

  IS
  BEGIN
   /* .............................................................................

   Programa: pc_buscar_detalhe_apl_prog_web
   Sistema : Novos Produtos de Captação - Aplicação Programada
   Sigla   : APLI
   Autor   : CIS Corporate
   Data    : Julho/2018.                    Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Rotina referente a busca de detalhes de uma aplicação programada - Mensageria. 

   Observacao: -----

   Alteracoes: 
  ..............................................................................*/                

  DECLARE
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    -- Variaveis auxiliares
    vr_exc_erro EXCEPTION;

    -- Variaveis de entrada
    vr_dtmvtolt Date := TO_DATE(pr_dtmvtolt,'dd/mm/yyyy');  

    -- Variaveis de retorno
    vr_tab_dados_rpp APLI0001.typ_tab_dados_rpp;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

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
      RAISE vr_exc_erro;
    END IF;     

    -- Busca as informações da apl. programada
    pc_buscar_detalhe_apl_prog(pr_cdcooper => vr_cdcooper,
                               pr_cdoperad => vr_cdoperad,
                               pr_nmdatela => vr_nmdatela,
                               pr_idorigem => vr_idorigem,
                               pr_nrdconta => pr_nrdconta,
                               pr_idseqttl => pr_idseqttl,
                               pr_nrctrrpp => pr_nrctrrpp,
                               pr_dtmvtolt => vr_dtmvtolt,
                               pr_tab_dados_rpp => vr_tab_dados_rpp,
                               pr_cdcritic => vr_cdcritic,
                               pr_dscritic => vr_dscritic);


    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;     

    IF vr_tab_dados_rpp.count >0 THEN
       -- Criar cabeçalho do XML
       dbms_lob.createtemporary(vr_clobxmlc, TRUE); 
       dbms_lob.open(vr_clobxmlc, dbms_lob.lob_readwrite);
       -- Insere o cabeçalho do XML 
       gene0002.pc_escreve_xml (pr_xml            => vr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>');

       gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc
                              ,pr_texto_completo => vr_xml_temp 
                              ,pr_texto_novo     => 
                              '<Registro>'||
                              '<cdbccxlt>'||vr_tab_dados_rpp(1).cdbccxlt||'</cdbccxlt>'||
                              '<nrdolote>'||vr_tab_dados_rpp(1).nrdolote||'</nrdolote>'||
                              '<dtmvtolt>'||to_char(vr_tab_dados_rpp(1).dtmvtolt,'dd/mm/yyyy')||'</dtmvtolt>'||
                              '<dtvctopp>'||to_char(vr_tab_dados_rpp(1).dtvctopp,'dd/mm/yyyy')||'</dtvctopp>'||
                              '<dtdebito>'||to_char(vr_tab_dados_rpp(1).dtdebito,'dd/mm/yyyy')||'</dtdebito>'||
                              '<indiadeb>'||vr_tab_dados_rpp(1).indiadeb||'</indiadeb>'||
                              '<vlprerpp>'||vr_tab_dados_rpp(1).vlprerpp||'</vlprerpp>'||
                              '<qtprepag>'||vr_tab_dados_rpp(1).qtprepag||'</qtprepag>'||
                              '<vlprepag>'||vr_tab_dados_rpp(1).vlprepag||'</vlprepag>'||
                              '<vlrgtacu>'||vr_tab_dados_rpp(1).vlrgtacu||'</vlrgtacu>'||
                              '<vlsdrdpp>'||vr_tab_dados_rpp(1).vlsdrdpp||'</vlsdrdpp>'||
                              '<vljuracu>'||vr_tab_dados_rpp(1).vljuracu||'</vljuracu>'||
                              '<dtinirpp>'||to_char(vr_tab_dados_rpp(1).dtinirpp,'dd/mm/yyyy')||'</dtinirpp>'||
                              '<dtrnirpp>'||to_char(vr_tab_dados_rpp(1).dtrnirpp,'dd/mm/yyyy')||'</dtrnirpp>'||
                              '<dtaltrpp>'||to_char(vr_tab_dados_rpp(1).dtaltrpp,'dd/mm/yyyy')||'</dtaltrpp>'||
                              '<dtcancel>'||to_char(vr_tab_dados_rpp(1).dtcancel,'dd/mm/yyyy')||'</dtcancel>'||
                              '<dssitrpp>'||vr_tab_dados_rpp(1).dssitrpp||'</dssitrpp>'||
                              '<dsctainv>'||vr_tab_dados_rpp(1).dsctainv||'</dsctainv>'||
                              '</Registro>'
                              );
       -- Encerrar a tag raiz 
       gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '</Dados></Root>' 
                               ,pr_fecha_xml      => TRUE);
                                 
       pr_retxml := XMLType.createXML(vr_clobxmlc);
    END IF;

  Exception
    When vr_exc_erro Then
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        
    When others Then
      pr_cdcritic := null; -- não será utilizado
      pr_dscritic := 'Erro geral em APLI0008.pc_buscar_extrato_apl_prog_web: '||SQLERRM;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      
  END;


  END pc_buscar_detalhe_apl_prog_web;

  /* Recuperar lista das poupancas programadas e aplicações programadas */
  PROCEDURE pc_lista_poupanca (pr_cdcooper IN crapcop.cdcooper%TYPE            --> Cooperativa
                              ,pr_cdagenci IN crapage.cdagenci%TYPE            --> Codigo da Agencia
                              ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE            --> Numero do caixa
                              ,pr_cdoperad IN craplrg.cdoperad%TYPE            --> Codigo do Operador
                              ,pr_idorigem IN INTEGER                          --> Identificador da Origem
                              ,pr_nrdconta IN craprda.nrdconta%TYPE            --> Nro da conta da aplicacao RDCA
                              ,pr_idseqttl IN INTEGER                          --> Identificador Sequencial
                              ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE            --> Contrato Poupanca Programada
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE            --> Data do movimento atual
                              ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE            --> Data do proximo movimento
                              ,pr_inproces IN crapdat.inproces%TYPE            --> Indicador de processo
                              ,pr_cdprogra IN crapprg.cdprogra%TYPE            --> Nome do programa chamador
                              ,pr_flgerlog IN BOOLEAN                          --> Flag erro log
                              ,pr_percenir IN NUMBER                           --> % IR para Calculo Poupanca
                              ,pr_tpapprog IN INTEGER default 0                --> Tipo de aplicacao poupanca (1 = Poupanca Antiga, 2 = Aplicações Programadas, 0 = Ambas)
                              ,pr_vlsldrpp OUT NUMBER                          --> Valor saldo poupanca programada
                              ,pr_retorno  OUT VARCHAR2                        --> Descricao de erro ou sucesso OK/NOK
                              ,pr_tab_dados_rpp OUT APLI0001.typ_tab_dados_rpp --> Poupancas Programadas
                              ,pr_tab_erro      IN OUT NOCOPY GENE0001.typ_tab_erro) IS  --> Saida com erros;
  BEGIN
  /* .............................................................................

   Programa: pc_consulta_pp_ap               
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : CIS Corporate
   Data    : Agosto/2018.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para consultar saldo e demais dados de poupancas programadas e aplicações progamadas. Derivado de pc_consulta_poupanca

   Alteracoes: 
  ............................................................................. */
    DECLARE

      --Selecionar informacoes das poupancas programadas
      CURSOR cr_craprpp IS
        SELECT rpp.nrctrrpp
              ,rpp.nrdconta
              ,rpp.cdagenci
              ,rpp.cdbccxlt
              ,rpp.nrdolote
              ,rpp.dtmvtolt
              ,rpp.dtvctopp
              ,rpp.dtdebito
              ,rpp.vlprerpp
              ,rpp.qtprepag
              ,rpp.vlprepag
              ,rpp.vljuracu
              ,rpp.vlrgtacu
              ,rpp.dtinirpp
              ,rpp.dtrnirpp
              ,rpp.dtaltrpp
              ,rpp.dtcancel
              ,rpp.flgctain
              ,rpp.dtiniper
              ,rpp.dtfimper
              ,rpp.vlabcpmf
              ,rpp.cdsitrpp
              ,rpp.vlsdrdpp
              ,rpp.cdprodut
              ,rpp.ROWID
              ,To_Char((CASE rpp.cdsitrpp
                 WHEN 1 THEN 'Ativa'
                 WHEN 2 THEN 'Suspensa'
                 WHEN 3 THEN 'Cancelada'
                 WHEN 4 THEN 'Cancelada'
                 WHEN 5 THEN 'Vencida'
                 ELSE ''
                END ))  dssitrpp
        FROM craprpp rpp
        WHERE rpp.cdcooper = pr_cdcooper
        AND   rpp.nrdconta = pr_nrdconta
        AND   (pr_nrctrrpp = 0 OR (pr_nrctrrpp > 0 AND rpp.nrctrrpp = pr_nrctrrpp))
        AND   (pr_tpapprog = 0 OR (pr_tpapprog = 1 AND rpp.cdprodut < 1) OR (pr_tpapprog = 2 and rpp.cdprodut >0));
      rw_craprpp cr_craprpp%ROWTYPE;

      --Selecionar informacoes dos saldos da poupanca no aniversario
      CURSOR cr_crapspp (pr_cdcooper IN crapspp.cdcooper%TYPE
                        ,pr_nrdconta IN crapspp.nrdconta%TYPE
                        ,pr_nrctrrpp IN crapspp.nrctrrpp%TYPE) IS
          SELECT MIN(crapspp.dtsldrpp) dtsldrpp
        FROM crapspp crapspp
        WHERE crapspp.cdcooper = pr_cdcooper
        AND   crapspp.nrdconta = pr_nrdconta
             AND crapspp.nrctrrpp = pr_nrctrrpp;
      rw_crapspp cr_crapspp%ROWTYPE;

      --Variaveis Locais
      vr_flgtrans BOOLEAN;
      vr_vlsdrdpp NUMBER(25,8);
      vr_vlrgtrpp NUMBER(25,8);
      vr_qtsaqppr INTEGER;
      vr_dsblqrpp VARCHAR2(3);
      vr_dsresgat VARCHAR2(3);
      vr_dsctainv VARCHAR2(3);
      vr_dsorigem VARCHAR2(40);
      vr_dstransa VARCHAR2(100);
      vr_dsmsgsaq VARCHAR2(4000);

      vr_vlsdappr NUMBER(25,8); -- Saldo total -  aplicacao programada
      vr_vlrgappr NUMBER(25,8);-- Saldo total para resgate - aplicacao programada

      --Variaveis de retorno de erro
      vr_des_erro VARCHAR2(4000);
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);

      --Variaveis de Indice para tabela memoria
      vr_index_tab     NUMBER;
      vr_index_craptab VARCHAR2(20);
      vr_index_craplpp VARCHAR2(20);
      vr_index_craplrg VARCHAR2(20);
      vr_index_resgate VARCHAR2(25);


      -- Rowid para tabela de log
      vr_nrdrowid ROWID;

      --Variaveis de Excecao
      vr_exc_erro EXCEPTION; --ERRO
      vr_exc_pula EXCEPTION; --NEXT
      vr_exc_sair EXCEPTION; --LEAVE

    BEGIN

      --Inicializar controle de erro
      pr_retorno:= 'OK';
      --Limpar tabela de memoria
      pr_tab_erro.DELETE;
      pr_tab_dados_rpp.DELETE;

      --Se for para gerar log
      IF pr_flgerlog  THEN
        --Atribuir Descricao da Origem
        vr_dsorigem:= GENE0001.vr_vet_des_origens(pr_idorigem);
        --Atribuir Descricao da Transacao
        vr_dstransa:= 'Consulta de aplicações programadas';
      END IF;

      --Inicializar variaveis
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
      vr_flgtrans:= TRUE;
      
      -- Verifica se o parâmetro é valido
      if pr_tpapprog not in (0,1,2) THEN
         vr_dscritic := 'Valor invalido para pr_tpapprog';
         RAISE vr_exc_erro;
      END IF;
      --Selecionar informacoes das poupancas programadas
      OPEN cr_craprpp;
      LOOP
        --Posicionar no proximo registro
        FETCH cr_craprpp INTO rw_craprpp;
        --Sair quando nao encontrar mais registros
        EXIT WHEN cr_craprpp%NOTFOUND;

        --Bloco necessario para controle fluxo
        BEGIN
          --Se for vencida e nome da tela for EXTPPR ou ADITIV ou IMPRES ignorar
          IF pr_cdprogra NOT IN ('EXTPPR','ADITIV','IMPRES') AND
             rw_craprpp.cdsitrpp = 5 /* Vencida */  THEN
            RAISE vr_exc_pula;
          END IF;

          -- Incializar o saldo com o valor da tabela
          vr_vlsdrdpp := rw_craprpp.vlsdrdpp;

          -- Verificar se é Poupança programada
          -- As aplicações programadas não serão tratadas linha a linha, mas evitaremos fazer 
          -- chamadas desnecessárias abaixo
          
          If rw_craprpp.cdprodut < 1 Then 
            --Executar rotina para calcular saldo poupanca programada
            apli0001.pc_calc_saldo_rpp (pr_cdcooper => pr_cdcooper
                                       ,pr_cdprogra => pr_cdprogra
                                       ,pr_inproces => pr_inproces
                                       ,pr_percenir => pr_percenir
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrctrrpp => rw_craprpp.nrctrrpp
                                       ,pr_dtiniper => rw_craprpp.dtiniper
                                       ,pr_dtfimper => rw_craprpp.dtfimper
                                       ,pr_vlabcpmf => rw_craprpp.vlabcpmf
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_dtmvtopr => pr_dtmvtopr
                                       ,pr_vlsdrdpp => vr_vlsdrdpp
                                       ,pr_des_erro => vr_des_erro);
                                         
          Else -- Aplicacao Programada
              vr_vlsdrdpp := 0;
              apli0008.pc_calc_saldo_apl_prog(pr_cdcooper => pr_cdcooper
                                             ,pr_cdprogra => pr_cdprogra
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_idseqttl => pr_idseqttl
                                             ,pr_idorigem => pr_idorigem
                                             ,pr_nrctrrpp => rw_craprpp.nrctrrpp
                                             ,pr_dtmvtolt => pr_dtmvtolt
                                             ,pr_vlsdrdpp => vr_vlsdrdpp
                                             ,pr_des_erro => vr_des_erro);
                                             
          End If; -- Aplicacao Programada

          --Se ocorreu erro
          IF vr_des_erro IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
                      
          --Ignorar se o saldo for negativo e a origem nao for AYLLOS/INTRANET
          IF vr_vlsdrdpp < 0 AND pr_idorigem NOT IN (1,5) THEN
            --Levantar excecao para pular registro
            RAISE vr_exc_pula;
          END IF;
          --Valor do Saldo da poupanca recebe atual + calculado
          pr_vlsldrpp:= Nvl(pr_vlsldrpp,0) + Nvl(vr_vlsdrdpp,0);
          --Valor resgatado recebe valor saldo
          vr_vlrgtrpp:= vr_vlsdrdpp;
          --Descricao resgate recebe N
          vr_dsresgat:= 'N';
          --Zerar quantidade sacada poupanca
          vr_qtsaqppr:= 0;
          --Mensagem de saque recebe null
          vr_dsmsgsaq:= NULL;

          --Selecionar saldo poupanca programada no aniversario
          OPEN cr_crapspp (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctrrpp => rw_craprpp.nrctrrpp);
          --Posicionar no proximo registro
          FETCH cr_crapspp INTO rw_crapspp;
          --Se nao encontrar
          IF cr_crapspp%NOTFOUND THEN
            rw_crapspp.dtsldrpp:= NULL;
          END IF;
          --Fechar Cursor
          CLOSE cr_crapspp;

          --Se a conta estiver inativa
          IF rw_craprpp.flgctain = 1 THEN
            vr_dsctainv:= 'Sim';
          ELSE
            vr_dsctainv:= 'Nao';
          END IF;

          --Encontrar o proximo indice para a tabela
          vr_index_tab:= pr_tab_dados_rpp.Count+1;
          --Atualizar informacoes na tabela de memoria
          pr_tab_dados_rpp(vr_index_tab).nrctrrpp:= rw_craprpp.nrctrrpp;
          pr_tab_dados_rpp(vr_index_tab).cdagenci:= rw_craprpp.cdagenci;
          pr_tab_dados_rpp(vr_index_tab).cdbccxlt:= rw_craprpp.cdbccxlt;
          pr_tab_dados_rpp(vr_index_tab).nrdolote:= rw_craprpp.nrdolote;
          pr_tab_dados_rpp(vr_index_tab).dtmvtolt:= rw_craprpp.dtmvtolt;
          pr_tab_dados_rpp(vr_index_tab).dtvctopp:= rw_craprpp.dtvctopp;
          pr_tab_dados_rpp(vr_index_tab).dtdebito:= rw_craprpp.dtdebito;
          pr_tab_dados_rpp(vr_index_tab).indiadeb:= To_Number(To_Char(rw_craprpp.dtdebito,'DD'));
          pr_tab_dados_rpp(vr_index_tab).vlprerpp:= rw_craprpp.vlprerpp;
          pr_tab_dados_rpp(vr_index_tab).qtprepag:= rw_craprpp.qtprepag;
          pr_tab_dados_rpp(vr_index_tab).vlprepag:= rw_craprpp.vlprepag;
          pr_tab_dados_rpp(vr_index_tab).vlsdrdpp:= vr_vlsdrdpp;
          pr_tab_dados_rpp(vr_index_tab).vlrgtrpp:= vr_vlrgtrpp;
          pr_tab_dados_rpp(vr_index_tab).vljuracu:= rw_craprpp.vljuracu;
          pr_tab_dados_rpp(vr_index_tab).vlrgtacu:= rw_craprpp.vlrgtacu;
          pr_tab_dados_rpp(vr_index_tab).dtinirpp:= rw_craprpp.dtinirpp;
          pr_tab_dados_rpp(vr_index_tab).dtrnirpp:= rw_craprpp.dtrnirpp;
          pr_tab_dados_rpp(vr_index_tab).dtaltrpp:= rw_craprpp.dtaltrpp;
          pr_tab_dados_rpp(vr_index_tab).dtcancel:= rw_craprpp.dtcancel;
          pr_tab_dados_rpp(vr_index_tab).dssitrpp:= rw_craprpp.dssitrpp;
          pr_tab_dados_rpp(vr_index_tab).dsblqrpp:= vr_dsblqrpp;
          pr_tab_dados_rpp(vr_index_tab).dsresgat:= vr_dsresgat;
          pr_tab_dados_rpp(vr_index_tab).dsctainv:= vr_dsctainv;
          pr_tab_dados_rpp(vr_index_tab).dsmsgsaq:= vr_dsmsgsaq;
          pr_tab_dados_rpp(vr_index_tab).cdtiparq:= 0;
          pr_tab_dados_rpp(vr_index_tab).dtsldrpp:= rw_crapspp.dtsldrpp;
          pr_tab_dados_rpp(vr_index_tab).cdprodut:= rw_craprpp.cdprodut;          
          pr_tab_dados_rpp(vr_index_tab).nrdrowid:= rw_craprpp.ROWID;
          

        EXCEPTION
          WHEN vr_exc_pula THEN
            --Atribuir TRUE para flag transacao
            vr_flgtrans:= TRUE;
          WHEN vr_exc_sair THEN
            --Atribuir FALSE para flag transacao pois ocorreu erro
            vr_flgtrans:= FALSE;
            --Sair do loop
            EXIT;
          WHEN vr_exc_erro THEN
            --Atribuir FALSE para flag transacao pois ocorreu erro
            vr_flgtrans:= FALSE;
            --Sair do loop
            EXIT;
        END;
      END LOOP;  --cr_craprpp
      --Fechar Cursor
      CLOSE cr_craprpp;

      --Se nao executou loop craprpp corretamente
      IF NOT vr_flgtrans THEN
        --Se nao ocorreu critica
        IF vr_cdcritic = 0 AND vr_dscritic IS NULL THEN
          --Atribuir descricao para a critica
          vr_dscritic:= 'Nao foi possivel consultar as poupancas programadas. Aplicacao: '||rw_craprpp.nrctrrpp;
        END IF;
        --Executar rotina geracao erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        --Se for para gerar log
        IF pr_flgerlog THEN
          --Executar rotina geracao log
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => SubStr(pr_cdoperad,1,10)
                              ,pr_dscritic => SubStr(vr_dscritic,1,159)
                              ,pr_dsorigem => SubStr(vr_dsorigem,1,13)
                              ,pr_dstransa => SubStr(vr_dstransa,1,121)
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => SubStr(pr_cdprogra,1,12)
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;
        --Indicar que ocorreu erro
        pr_retorno:= 'NOK';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Se for para gerar log
      IF pr_flgerlog THEN
        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => NULL
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_cdprogra
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      --Indicar que nao ocorreu erro
      pr_retorno:= 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_retorno := 'NOK';
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_retorno := 'NOK';
        -- Gerar erro montado
        vr_dscritic := 'APLI0001.pc_consulta_poupanca --> Erro não tratado na rotina: '||sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 1
                             ,pr_nrdcaixa => 999
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_lista_poupanca;

  /* Recuperar lista das poupancas programadas e aplicações programadas - Mensageria*/
  PROCEDURE pc_lista_poupanca_web (pr_nrdconta IN craprda.nrdconta%TYPE  -- Nro da conta da aplicacao RDCA
                                  ,pr_idseqttl IN INTEGER                -- Identificador Sequencial
                                  ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  -- Contrato Poupanca Programada
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  -- Data do movimento atual
                                  ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE  -- Data do proximo movimento
                                  ,pr_inproces IN crapdat.inproces%TYPE  -- Indicador de processo
                                  ,pr_flgerlog IN INTEGER                -- Flag erro log
                                  ,pr_percenir IN NUMBER                 -- % IR para Calculo Poupanca
                                  ,pr_tpapprog IN INTEGER default 0      -- Tipo de aplicacao poupanca (1 = Poupanca Antiga, 2 = Aplicações Programadas, 0 = Ambas)
                                  ,pr_xmllog   IN VARCHAR2               -- XML com informacoes de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER           -- Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              -- Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType     -- Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2              -- Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2)             -- Erros do processo
   IS BEGIN
   /* .............................................................................

   Programa: pc_consulta_pp_ap_web
   Sistema : Novos Produtos de Captação - Aplicação Programada
   Sigla   : APLI
   Autor   : CIS Corporate
   Data    : Agosto/2018.                    Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Rotina referente a busca de detalhes de uma aplicação programada - Mensageria. 

   Observacao: -----

   Alteracoes: 
  ..............................................................................*/                

  DECLARE
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    -- Variaveis auxiliares
    vr_exc_erro EXCEPTION;

    -- Variaveis de entrada
    vr_dtmvtolt Date := TO_DATE(pr_dtmvtolt,'dd/mm/yyyy');  

    vr_vlsldrpp NUMBER;
    vr_retorno VARCHAR(10);
    

    -- Variaveis de retorno
    vr_tab_craptab APLI0001.typ_tab_ctablq;
    vr_tab_craplpp APLI0001.typ_tab_craplpp;
    vr_tab_craplrg APLI0001.typ_tab_craplpp;
    vr_tab_resgate APLI0001.typ_tab_resgate;
    vr_tab_dados_rpp APLI0001.typ_tab_dados_rpp;
    vr_tab_erro gene0001.typ_tab_erro;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_tpapprog VARCHAR2(100);
    vr_flgerlog BOOLEAN := FALSE; 
    

    -- Variaveis de XML 
    vr_xml_temp VARCHAR2(32767);
    vr_clobxmlc CLOB;
    vr_texto_novo VARCHAR2(1000);

    
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
      RAISE vr_exc_erro;
    END IF;     
    
    IF pr_flgerlog = 1 THEN
      vr_flgerlog := TRUE;
    END IF;

    -- Busca as informações da apl. programada
    pc_lista_poupanca (pr_cdcooper => vr_cdcooper
                      ,pr_cdagenci => vr_cdagenci
                      ,pr_nrdcaixa => vr_nrdcaixa
                      ,pr_cdoperad => vr_cdoperad
                      ,pr_idorigem => vr_idorigem
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_idseqttl => pr_idseqttl
                      ,pr_nrctrrpp => pr_nrctrrpp
                      ,pr_dtmvtolt => pr_dtmvtolt
                      ,pr_dtmvtopr => pr_dtmvtopr
                      ,pr_inproces => pr_inproces
                      ,pr_cdprogra => vr_nmdatela
                      ,pr_flgerlog => vr_flgerlog
                      ,pr_percenir => pr_percenir
                      ,pr_tpapprog => pr_tpapprog
                      ,pr_vlsldrpp => vr_vlsldrpp
                      ,pr_retorno => vr_retorno
                      ,pr_tab_dados_rpp => vr_tab_dados_rpp
                      ,pr_tab_erro => vr_tab_erro);

    IF vr_retorno='NOK' THEN
       RAISE vr_exc_erro;
    END IF;
    -- Criar cabeçalho do XML
    dbms_lob.createtemporary(vr_clobxmlc, TRUE); 
    dbms_lob.open(vr_clobxmlc, dbms_lob.lob_readwrite);
    -- Insere o cabeçalho do XML 
    gene0002.pc_escreve_xml (pr_xml            => vr_clobxmlc 
                            ,pr_texto_completo => vr_xml_temp 
                            ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados vlsldrpp="'||vr_vlsldrpp||'"');
    
    -- Dados
    IF vr_tab_dados_rpp.count >0 THEN
       FOR i1 in vr_tab_dados_rpp.FIRST..vr_tab_dados_rpp.LAST LOOP
             IF vr_tab_dados_rpp(i1).cdprodut < 0 THEN -- ANTIGO
                vr_tpapprog := 'RPP';
             ELSE
                vr_tpapprog := 'APR';
             END IF; 
             vr_texto_novo := vr_texto_novo ||
                              '<Registro>'||
                              '<nrctrrpp>'||vr_tab_dados_rpp(i1).nrctrrpp||'</nrctrrpp>'||
                              '<cdagenci>'||vr_tab_dados_rpp(i1).cdagenci||'</cdagenci>'||  
                              '<cdbccxlt>'||vr_tab_dados_rpp(i1).cdbccxlt||'</cdbccxlt>'||
                              '<nrdolote>'||vr_tab_dados_rpp(i1).nrdolote||'</nrdolote>'||
                              '<dtmvtolt>'||to_char(vr_tab_dados_rpp(i1).dtmvtolt,'dd/mm/yyyy')||'</dtmvtolt>'||
                              '<dtvctopp>'||to_char(vr_tab_dados_rpp(i1).dtvctopp,'dd/mm/yyyy')||'</dtvctopp>'||
                              '<dtdebito>'||to_char(vr_tab_dados_rpp(i1).dtdebito,'dd/mm/yyyy')||'</dtdebito>'||
                              '<indiadeb>'||vr_tab_dados_rpp(i1).indiadeb||'</indiadeb>'||
                              '<vlprerpp>'||vr_tab_dados_rpp(i1).vlprerpp||'</vlprerpp>'||
                              '<qtprepag>'||vr_tab_dados_rpp(i1).qtprepag||'</qtprepag>'||
                              '<vlprepag>'||vr_tab_dados_rpp(i1).vlprepag||'</vlprepag>'||
                              '<vlsdrdpp>'||vr_tab_dados_rpp(i1).vlsdrdpp||'</vlsdrdpp>'||
                              '<vlrgtrpp>'||vr_tab_dados_rpp(i1).vlrgtrpp||'</vlrgtrpp>'||
                              '<vljuracu>'||vr_tab_dados_rpp(i1).vljuracu||'</vljuracu>'||
                              '<vlrgtacu>'||vr_tab_dados_rpp(i1).vlrgtacu||'</vlrgtacu>'||
                              '<dtinirpp>'||to_char(vr_tab_dados_rpp(i1).dtinirpp,'dd/mm/yyyy')||'</dtinirpp>'||
                              '<dtrnirpp>'||to_char(vr_tab_dados_rpp(i1).dtrnirpp,'dd/mm/yyyy')||'</dtrnirpp>'||
                              '<dtaltrpp>'||to_char(vr_tab_dados_rpp(i1).dtaltrpp,'dd/mm/yyyy')||'</dtaltrpp>'||
                              '<dtcancel>'||to_char(vr_tab_dados_rpp(i1).dtcancel,'dd/mm/yyyy')||'</dtcancel>'||
                              '<dssitrpp>'||vr_tab_dados_rpp(i1).dssitrpp||'</dssitrpp>'||
                              '<dsblqrpp>'||vr_tab_dados_rpp(i1).dsblqrpp||'</dsblqrpp>'||  
                              '<dsresgat/>'||
                              '<dsctainv>'||vr_tab_dados_rpp(i1).dsctainv||'</dsctainv>'||
							                '<dsmsgsaq/>'||
                              '<nrdrowid>0x021406a03236343639360000000000000000000000000000</nrdrowid>'||
                              '<cdprodut>'||vr_tab_dados_rpp(i1).cdprodut||'</cdprodut>'||
                              '</Registro>';

             gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc
                                    ,pr_texto_completo => vr_xml_temp 
                                    ,pr_texto_novo     => vr_texto_novo);
             vr_texto_novo :='';                                                           
       END LOOP;
    END IF;
    -- Encerrar a tag raiz 
    gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc 
                            ,pr_texto_completo => vr_xml_temp 
                            ,pr_texto_novo     => '</Dados></Root>' 
                            ,pr_fecha_xml      => TRUE);
                                 
    pr_retxml := XMLType.createXML(vr_clobxmlc);

  Exception
    When vr_exc_erro Then
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        
    When others Then
      pr_cdcritic := null; -- não será utilizado
      pr_dscritic := 'Erro geral em APLI0008.pc_buscar_extrato_apl_prog_web: '||SQLERRM;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      
  END;
END pc_lista_poupanca_web;

procedure pc_calc_app_programada (pr_cdcooper  in crapcop.cdcooper%type,          --> Cooperativa
                              pr_dstextab  in craptab.dstextab%type,          --> Percentual de IR da aplicação
                              pr_cdprogra  in crapprg.cdprogra%type,          --> Programa chamador
                              pr_inproces  in crapdat.inproces%type,          --> Indicador do processo
                              pr_dtmvtolt  in crapdat.dtmvtolt%type,          --> Data do processo
                              pr_dtmvtopr  in crapdat.dtmvtopr%type,          --> Próximo dia útil
                              pr_rpp_rowid in varchar2,                       --> Identificador do registro da tabela CRAPRPP em processamento
                              pr_vlsdrdpp  in out craprpp.vlsdrdpp%type,      --> Saldo da poupança programada
                              pr_cdcritic out crapcri.cdcritic%type,          --> Codigo da crítica de erro
                              pr_des_erro out varchar2) is                    --> Descrição do erro encontrado
/* ...........................................................................

   Programa: APLI0008.PC_CALC_APP_PROGRAMADA
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : CIS Corporate
   Data    : Julho/2018.                       Ultima atualizacao: 19/08/2018

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina de calculo do RPP  -- Deve ser chamada de dentro de um
               FOR EACH ou DO WHILE e com label TRANS_POUP.

                                   
                                                      
................................................................................................... */
    -- Variaveis para auxiliar nos calculos
    vr_exc_erro         EXCEPTION;
    vr_des_erro         varchar2(4000);
    vr_tab_erro GENE0001.typ_tab_erro;
    
    vr_percenir         number(8,4);
    vr_vlrentot         number(25,8);
    vr_vlrendim         number(25,8);
    vr_vlajuste         number(25,8);
    vr_vlajuste_cr      number(25,8);
    vr_vlajuste_db      number(25,8);
    vr_vlsdrdpp         number(25,8);
    vr_vllan150         craplpp.vllanmto%type;
    vr_vllan152         craplpp.vllanmto%type;
    vr_vllan158         craplpp.vllanmto%type;
    vr_vllan925         craplpp.vllanmto%type;
    vr_vlprovis         number(25,8);
    vr_txaplica         number(25,8);
    vr_txaplmes         number(25,8);
    vr_vlrirrpp         number(25,8);
    vr_dtcalcul         craprpp.dtiniper%type;
    vr_dtrefere         craprpp.dtfimper%type;
    vr_dtultdia         craprpp.dtfimper%type;
    vr_dtmvtolt         crapdat.dtmvtolt%type;
    vr_qtmesext         craprpp.qtmesext%type;
    vr_dtdolote         date;
    vr_nrdolote         number(4);
    vr_cdhistor         number(3);
    vr_cdagenci         craplot.cdagenci%type := 1;
    vr_cdbccxlt         craplot.cdbccxlt%type := 100;
    vr_nrseqdig         craplot.nrseqdig%type;
    vr_cdprogra         VARCHAR2(20);
    vr_flgimune         boolean;
    vr_flggrvir         boolean;
    vr_des_reto         varchar2(10);
    vr_tptaxrda         craptrd.tptaxrda%type;

    --Variáveis acumulo lote
    vr_vlinfocr         craplot.vlinfocr%type := 0;
    vr_vlcompcr         craplot.vlcompcr%type := 0; 
    vr_vlinfodb         craplot.vlinfodb%type := 0;
    vr_vlcompdb         craplot.vlcompcr%type := 0;     
    vr_qtinfoln         craplot.vlcompdb%type := 0;
    vr_qtcompln         craplot.qtcompln%type := 0;    


    -- Informações da poupança programada
    cursor cr_craprpp (pr_rowid in varchar2) is
      select /*+ NOPARALLEL */
             craprpp.vlsdrdpp,
             craprpp.dtiniper,
             craprpp.dtfimper,
             craprpp.vlabcpmf,
             craprpp.qtmesext,
             craprpp.nrdconta,
             craprpp.nrctrrpp,
             craprpp.vlabdiof,
             craprpp.dtmvtolt,
             craprpp.cdprodut
        from craprpp
       where craprpp.rowid = pr_rowid;
    rw_craprpp     cr_craprpp%rowtype;

    -- Taxas de RDCA
    cursor cr_craptrd (pr_cdcooper craptrd.cdcooper%type,
                       pr_dtiniper craptrd.dtiniper%type,
                       pr_vlsdrdpp craptrd.vlfaixas%type,
                       pr_tptaxrda craptrd.tptaxrda%type) is
      select craptrd.rowid,
             craptrd.txofidia,
             craptrd.txofimes,
             craptrd.txprodia,
             craptrd.dtfimper
        from craptrd
       where craptrd.cdcooper  = pr_cdcooper
         and craptrd.dtiniper  = pr_dtiniper
         and craptrd.tptaxrda  = pr_tptaxrda
         and craptrd.incarenc  = 0
         and craptrd.vlfaixas <= pr_vlsdrdpp
       order by craptrd.vlfaixas desc; --find first

    rw_craptrd   cr_craptrd%rowtype;
    -- Taxas de RDCA (sem considerar faixa)
    cursor cr_craptrd2 is
      select dtfimper
        from craptrd
       where craptrd.cdcooper = pr_cdcooper
         and craptrd.dtiniper = rw_craprpp.dtfimper
         and craptrd.tptaxrda = 2
         and craptrd.incarenc = 0
         and craptrd.vlfaixas = 0;
    rw_craptrd2    cr_craptrd2%rowtype;
    -- Cotas e recursos
    cursor cr_crapcot is
      select crapcot.rowid
        from crapcot
       where crapcot.cdcooper = pr_cdcooper
         and crapcot.nrdconta = rw_craprpp.nrdconta;
    rw_crapcot     cr_crapcot%rowtype;

  BEGIN
    vr_cdprogra := pr_cdprogra;

    -- Buscar informações da poupança programada
    open cr_craprpp (pr_rpp_rowid);
      fetch cr_craprpp into rw_craprpp;
    close cr_craprpp;
    --
    vr_percenir := gene0002.fn_char_para_number(pr_dstextab);
    vr_vlrentot := 0;
    vr_vlrendim := 0;
    vr_vlajuste := 0;
    vr_vllan150 := 0;
    vr_vllan152 := 0;
    vr_vllan158 := 0;
    vr_vllan925 := 0;
    vr_vlprovis := 0;
    vr_txaplica := 0;
    vr_txaplmes := 0;
    vr_vlrirrpp := 0;
    vr_dtcalcul := rw_craprpp.dtiniper;
    vr_dtrefere := rw_craprpp.dtfimper;
    vr_vlsdrdpp := rw_craprpp.vlsdrdpp;

    -- Define qual data deve utilizar como último dia
    IF vr_cdprogra = 'CRPS147' then
      vr_dtultdia := last_day(add_months(pr_dtmvtolt, -1));
    else
      vr_dtultdia := last_day(add_months(pr_dtmvtopr, -1));
    end if;

    -- Define qual data deve utilizar como data do movimento
    if pr_inproces > 2 THEN /* BATCH */ 
      IF vr_cdprogra = 'CRPS147' then /* MENSAL */
        -- Cálculo até o dia do movimento
        vr_dtmvtolt := pr_dtmvtolt + 1;
      end if;
    else /* ONLINE */
      IF vr_cdprogra = 'CRPS156' then /* RESGATE */
        -- Cálculo até o dia do resgate
        vr_dtmvtolt := pr_dtmvtopr;
      end if;
    end if;

        apli0008.pc_calc_saldo_apl_prog (pr_cdcooper => pr_cdcooper
                                        ,pr_cdprogra => pr_cdprogra
                                        ,pr_cdoperad => '1'
                                        ,pr_nrdconta => rw_craprpp.nrdconta
                                        ,pr_idseqttl => 1
                                        ,pr_idorigem => 5
                                        ,pr_nrctrrpp => rw_craprpp.nrctrrpp
                                        ,pr_dtmvtolt => pr_dtmvtolt
                                        ,pr_vlsdrdpp => vr_vlsdrdpp
                                        ,pr_des_erro => pr_des_erro);

         if pr_des_erro is not null then
           raise vr_exc_erro;
         end if;

    if vr_vlsdrdpp < 0 or  vr_vlsdrdpp is null then
      vr_vlsdrdpp := 0;
    end if;
    --

    if pr_inproces > 2 and /* BATCH */
       vr_cdprogra in ('CRPS147') then

      /********************************************************************/
      /** Em maio de 2012 o novo calculo foi liberado para utilizacao,   **/
      /** portanto poupancas cadastradas a partir desta data poderiam    **/
      /** ser remuneradas conforme a nova regra, porem, em nosso sistema **/
      /** a nova regra sera utilizada somentepara poupancas cadastradas  **/
      /** apos a liberacao do projeto de novoindexador de poupanca,      **/
      /** pois o passado anterior a liberacaoja foi contratado com a     **/
      /** regra antiga                                                   **/
      /********************************************************************/

      -- Compara da de liberacao do projeto de novo indexador da poupanca
      IF rw_craprpp.dtmvtolt >= to_date('01/07/2014','dd/mm/yyyy') then
        vr_tptaxrda := 4; /*Novo Indexador poupanca - Lei 12.703*/
      ELSE
        vr_tptaxrda := 2; /*Regra Antiga*/
      end IF;

      -- Escolhe a taxa a utilizar
      open cr_craptrd (pr_cdcooper => pr_cdcooper,
                       pr_dtiniper => rw_craprpp.dtiniper,
                       pr_vlsdrdpp => vr_vlsdrdpp,
                       pr_tptaxrda => vr_tptaxrda);
        fetch cr_craptrd into rw_craptrd;
        if cr_craptrd%notfound then
          pr_cdcritic := 347;
          vr_des_erro := gene0001.fn_busca_critica(347)||
                         ' Data: '||to_char(rw_craprpp.dtiniper, 'dd/mm/yyyy')||
                         ' NrCtrRpp: '||to_char(rw_craprpp.nrctrrpp, 'fm999g999g990')||
                         ' Faixa: '||to_char(vr_vlsdrdpp, 'fm999g999g990d00');
          raise vr_exc_erro;
        end if;
      close cr_craptrd;
      if rw_craptrd.txofidia > 0 then
        vr_txaplica := (rw_craptrd.txofidia / 100);
        vr_txaplmes := rw_craptrd.txofimes;
      elsif rw_craptrd.txprodia > 0 then
        vr_txaplica := (rw_craptrd.txprodia / 100);
        vr_txaplmes := 0;
      else
        vr_des_erro := gene0001.fn_busca_critica(427)||
                       ' Data: '||to_char(rw_craprpp.dtiniper, 'dd/mm/yyyy');
        raise vr_exc_erro;
      end if;

      -- Para os programas CRPS147 e 148, foi realizado o upate no próprio crps, visto que teríamos problemas no paralelismo           
      if vr_cdprogra IN('CRPS148','CRPS147') then
        begin

          apli0001.pc_insere_tab_wrk(pr_cdcooper     => pr_cdcooper 
                                    ,pr_nrdconta     => rw_craprpp.nrdconta
                                    ,pr_cdprogra     => vr_cdprogra
                                    ,pr_dsrelatorio  => 'CRAPTRD'
                                    ,pr_dtmvtolt     => pr_dtmvtolt
                                    ,pr_dschave      => rw_craptrd.rowid
                                    ,pr_dsinformacao => null 
                                    ,pr_dscritic     => vr_des_erro);          
        
          if vr_des_erro is not null then
            raise vr_exc_erro; 
    end if;

        exception
          when others then
            vr_des_erro := 'Erro ao chamar procedure apli0001.pc_insere_tab_wrk: '||sqlerrm;
            raise vr_exc_erro;              
        end;
      else
      -- Atualiza o indicador de cálculo
      begin
        update craptrd
             set incalcul = 1
         where rowid = rw_craptrd.rowid;
      exception
        when others then
          vr_des_erro := 'Erro ao atualizar indicador de calculo na craptrd: '||sqlerrm;
          raise vr_exc_erro;
      end;
    end if;
    end if;

    --
    if pr_inproces > 2 and
       vr_cdprogra in ('CRPS147', 'CRPS148') and
       vr_dtcalcul < vr_dtmvtolt and
       vr_vlsdrdpp > 0 then
      -- Acrescenta o rendimento para o período VR_DTCALCUL ate VR_DTMVTOLT
      while vr_dtcalcul < vr_dtmvtolt loop
        -- Busca o próximo dia útil
        vr_dtcalcul := gene0005.fn_valida_dia_util(pr_cdcooper,
                                                   vr_dtcalcul);
        if vr_dtcalcul >= vr_dtmvtolt then
          exit;
        end if;
        -- Incrementa os valores
        vr_vlrendim := trunc(vr_vlsdrdpp * vr_txaplica, 8);
        vr_vlsdrdpp := vr_vlsdrdpp + vr_vlrendim;
        vr_vlrentot := vr_vlrentot + vr_vlrendim;
        if vr_dtcalcul <= vr_dtultdia then
          vr_vlprovis := vr_vlprovis + vr_vlrendim;
        end if;
        -- Próxima data
        vr_dtcalcul := vr_dtcalcul + 1;
      end loop;  /* Fim do WHILE */
    end if;

    /*  Arredondamento dos valores calculados  */
    vr_vlsdrdpp := APLI0001.fn_round(vr_vlsdrdpp,2);
    vr_vlrentot := APLI0001.fn_round(vr_vlrentot,2);
    vr_vlprovis := APLI0001.fn_round(vr_vlprovis,2);
    vr_vlrirrpp := trunc((vr_vlrentot * vr_percenir / 100),2);

    /* Tratamento para Imunidade Tributaria */
    IF pr_inproces > 2  AND upper(pr_cdprogra) = 'CRPS148'   THEN
      vr_flggrvir := TRUE;
    ELSE
      vr_flggrvir := FALSE;
    END IF;

    /* Procedure para verificar imunidade tributaria e inserir valor de insenção */
    IMUT0001.pc_verifica_imunidade_trib(  pr_cdcooper  => pr_cdcooper  --> Codigo Cooperativa
                                         ,pr_nrdconta  => rw_craprpp.nrdconta  --> Numero da Conta
                                         ,pr_dtmvtolt  => pr_dtmvtolt  --> Data movimento
                                         ,pr_flgrvvlr  => vr_flggrvir  --> Identificador se deve gravar valor
                                         ,pr_cdinsenc  => 5            --> Codigo da insenção
                                         ,pr_vlinsenc  => TRUNC((vr_vlrentot *
                                                                 vr_percenir / 100),2)--> Valor insento
                                         ,pr_flgimune  => vr_flgimune  --> Identificador se é imune
                                         ,pr_dsreturn  => vr_des_reto  --> Descricao Critica
                                         ,pr_tab_erro  => vr_tab_erro);--> Tabela erros

    -- Se retornar alguma mensagem de erro
    IF vr_tab_erro.COUNT() > 0 THEN
      -- Mostrar mensagem de log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || pr_cdprogra || ' --> '
                                                 || vr_tab_erro(vr_tab_erro.FIRST).dscritic);

      -- Limpeza dos erros
      vr_tab_erro.DELETE;
    END IF;

    IF vr_flgimune THEN
      vr_vlrirrpp := 0;
    ELSE
      vr_vlrirrpp := trunc((vr_vlrentot * vr_percenir / 100),2);
    END IF;

    -- Ajusta o saldo da poupança programada
    if pr_inproces = 1 and
       vr_flgimune = false then
      vr_vlsdrdpp := vr_vlsdrdpp - trunc((rw_craprpp.vlabcpmf * vr_percenir / 100), 2);
      if vr_vlsdrdpp < 0 then
        vr_vlsdrdpp := 0;
      end if;
    end if;
    -- Atualiza a variável de retorno
    pr_vlsdrdpp := vr_vlsdrdpp;
    --
    if pr_inproces > 2 then
        vr_dtdolote := pr_dtmvtolt;
        vr_nrdolote := 8383;

        -- Busca a taxa RDCA
        open cr_craptrd2;
          fetch cr_craptrd2 into rw_craptrd2;
          if cr_craptrd2%notfound then
            close cr_craptrd2;
            vr_des_erro := gene0001.fn_busca_critica(347)||
                           ' Data: '||to_char(rw_craprpp.dtfimper, 'dd/mm/yyyy')||
                           ' Conta: '||to_char(rw_craprpp.nrdconta, '9999G999D0')||
                           ' NrCtrRpp: '||to_char(rw_craprpp.nrctrrpp, '999g999');
            raise vr_exc_erro;
          end if;
        close cr_craptrd2;
        --
        vr_qtmesext := rw_craprpp.qtmesext + 1;
        if vr_qtmesext = 4 then
          vr_qtmesext := 1;
        end if;
        if to_char(rw_craprpp.dtfimper, 'mm') = '12' then
          vr_qtmesext := 3;
        end if;
        -- Atualiza poupança programada
        begin
          update craprpp
             set craprpp.qtmesext = vr_qtmesext,
                 craprpp.dtiniext = decode(vr_qtmesext,
                                           1, craprpp.dtfimext,
                                           craprpp.dtiniext),
                 craprpp.dtsdppan = decode(vr_qtmesext,
                                           1, craprpp.dtiniper,
                                           craprpp.dtsdppan),
                 craprpp.vlsdppan = decode(vr_qtmesext,
                                           1, craprpp.vlsdrdpp,
                                           craprpp.vlsdppan),
                 craprpp.incalmes = 0,
                 indebito = 0,
                 craprpp.dtfimext = craprpp.dtfimper,
                 craprpp.dtiniper = craprpp.dtfimper,
                 craprpp.dtfimper = rw_craptrd2.dtfimper,
                 craprpp.vlsdrdpp = pr_vlsdrdpp - vr_vlrirrpp,
                 craprpp.dtcalcul = pr_dtmvtopr
           where craprpp.rowid = pr_rpp_rowid;
        exception
          when others then
            vr_des_erro := 'Erro ao atualizar informações da poupança programada: '||sqlerrm;
            raise vr_exc_erro;
        end;
        --
        vr_dtdolote := pr_dtmvtopr;
        vr_nrdolote := 8384;
        --vamos informar a agêcia executada no paralelismo
        --e montar a chave para buscar o nrseqdig por ela.
        --
        if rw_craprpp.vlabcpmf > 0 then
          begin
            -- Atualiza o saldo da poupança programada
            update craprpp
               set craprpp.vlsdrdpp = craprpp.vlsdrdpp - trunc((craprpp.vlabcpmf * vr_percenir / 100),2)
             where craprpp.rowid = pr_rpp_rowid;
          exception
            when others then
              vr_des_erro := 'Erro ao atualizar saldo da poupança programada: '||sqlerrm;
              raise vr_exc_erro;
          end;
        end if;
        -- Lê novamente as informações da craprpp para recuperar os valores atualizados
        open cr_craprpp (pr_rpp_rowid);
          fetch cr_craprpp into rw_craprpp;
        close cr_craprpp;
        --
        begin
          update crapspp
             set crapspp.vlsldrpp = rw_craprpp.vlsdrdpp,
                 crapspp.dtmvtolt = pr_dtmvtolt
           where crapspp.cdcooper = pr_cdcooper
             and crapspp.nrdconta = rw_craprpp.nrdconta
             and crapspp.nrctrrpp = rw_craprpp.nrctrrpp
             and crapspp.dtsldrpp = rw_craprpp.dtiniper;
          --
          if sql%rowcount = 0 then
            -- Não encontrou registro para atualizar, portanto deve incluir um novo
            begin
              insert into crapspp (cdcooper,
                                   nrdconta,
                                   nrctrrpp,
                                   dtsldrpp,
                                   vlsldrpp,
                                   dtmvtolt)
              values (pr_cdcooper,
                      rw_craprpp.nrdconta,
                      rw_craprpp.nrctrrpp,
                      rw_craprpp.dtiniper,
                      rw_craprpp.vlsdrdpp,
                      pr_dtmvtolt);
            exception
              when others then
                vr_des_erro := 'Erro ao inserir saldo da poupança programada no aniversario: '||sqlerrm;
                raise vr_exc_erro;
            end;
          end if;
        exception
          when vr_exc_erro then
            raise vr_exc_erro;
          when others then
            vr_des_erro := 'Erro ao atualizar saldo da poupança programada no aniversario: '||sqlerrm;
            raise vr_exc_erro;
        end;
      end if;
      --
      IF vr_cdprogra = 'CRPS147' then
        vr_vlrentot := vr_vlrentot - vr_vlprovis;
      end if;
      --
      if vr_vlrentot > 0 then
        if vr_cdprogra NOT IN('CRPS147','CRPS148') then
        -- Atualizar o tipo do lote
        begin
          update craplot
             set craplot.tplotmov = 14
           where craplot.cdcooper = pr_cdcooper
             and craplot.dtmvtolt = vr_dtdolote
             and craplot.cdagenci = vr_cdagenci
             and craplot.cdbccxlt = vr_cdbccxlt
             and craplot.nrdolote = vr_nrdolote
          returning craplot.nrseqdig into vr_nrseqdig;
        exception
          when others then
              vr_des_erro := 'Erro ao verificar informações da capa de lote: '||sqlerrm;
            raise vr_exc_erro;
        end;
        
        if sql%rowcount = 0 then
          begin
            insert into craplot (dtmvtolt,
                                 cdagenci,
                                 cdbccxlt,
                                 nrdolote,
                                 tplotmov,
                                 cdcooper)
            values (vr_dtdolote,
                    vr_cdagenci,
                    vr_cdbccxlt,
                    vr_nrdolote,
                    14,
                    pr_cdcooper)
             returning 0 into vr_nrseqdig;
          exception
            when others then
              vr_des_erro := 'Erro ao inserir informações da capa de lote: '||sqlerrm;
              raise vr_exc_erro;
          end;
        end if;
        
        end if;
       
        --Se for CRPS147 E 148 utilizar chave do lote 8384 para adicionar os lançamentos.
        --Tratado de forma diferente devido paralelismo
        IF vr_cdprogra = 'CRPS147' THEN
          vr_nrseqdig := CRAPLOT_8383_SEQ.NEXTVAL;
        ELSIF vr_cdprogra = 'CRPS148' THEN   
          vr_nrseqdig := CRAPLOT_8384_SEQ.NEXTVAL;
        else 
          vr_nrseqdig := vr_nrseqdig +1;  
        end if;

        -- Atualiza a capa do lote
        if vr_cdprogra IN('CRPS147','CRPS148') then
          
          vr_vlinfocr := vr_vlinfocr + nvl(vr_vlrentot, 0); 
          vr_vlcompcr := vr_vlcompcr + nvl(vr_vlrentot, 0);   
          vr_qtinfoln := vr_qtinfoln + 1;    
          vr_qtcompln := vr_qtcompln + 1;        
      
        else
        begin
          update craplot
             set craplot.vlinfocr = nvl(craplot.vlinfocr, 0) + nvl(vr_vlrentot, 0),
                 craplot.vlcompcr = nvl(craplot.vlcompcr, 0) + nvl(vr_vlrentot, 0),
                 craplot.qtinfoln = nvl(craplot.qtinfoln, 0) + 1,
                 craplot.qtcompln = nvl(craplot.qtcompln, 0) + 1,
                   craplot.nrseqdig = vr_nrseqdig
           where craplot.cdcooper = pr_cdcooper
             and craplot.dtmvtolt = vr_dtdolote
             and craplot.cdagenci = vr_cdagenci
             and craplot.cdbccxlt = vr_cdbccxlt
             and craplot.nrdolote = vr_nrdolote
          returning nrseqdig into vr_nrseqdig;
        exception
          when others then
            vr_des_erro := 'Erro ao atualizar a capa de lote (2): '||sqlerrm;
            raise vr_exc_erro;
        end;
        end if;
        --
      
      IF vr_cdprogra = 'CRPS147' and
         (vr_vlrentot > 0 or
          rw_craprpp.vlabdiof > 0 or
          vr_vlrirrpp > 0) then
        -- Busca as informações de cotas e recursos
        open cr_crapcot;
          fetch cr_crapcot into rw_crapcot;
          if cr_crapcot%notfound then
            close cr_crapcot;
            pr_cdcritic := 169;
            vr_des_erro := gene0001.fn_busca_critica(169)||
                           ' Conta: '||to_char(rw_craprpp.nrdconta, '9999G999D0');
            raise vr_exc_erro;
          end if;
        close cr_crapcot;
        --
        if vr_vlrentot > 0 then
          -- Atualiza os juros acumulados da poupança programada
          begin
            update craprpp
               set craprpp.vljuracu = craprpp.vljuracu + vr_vlrentot
             where craprpp.rowid = pr_rpp_rowid;
          exception
            when others then
              vr_des_erro := 'Erro ao atualizar os juros acumulados da poupança programada: '||sqlerrm;
              raise vr_exc_erro;
          end;
          -- Atualiza cotas e recursos (somente os campos correspondentes ao mês de referência)
          begin
            update crapcot
               set crapcot.vlrenrpp = crapcot.vlrenrpp + vr_vlrentot,
                   crapcot.vlrenrpp_ir##1 = crapcot.vlrenrpp_ir##1 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '01', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##1 = crapcot.vlrentot##1 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '01', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##2 = crapcot.vlrenrpp_ir##2 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '02', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##2 = crapcot.vlrentot##2 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '02', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##3 = crapcot.vlrenrpp_ir##3 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '03', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##3 = crapcot.vlrentot##3 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '03', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##4 = crapcot.vlrenrpp_ir##4 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '04', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##4 = crapcot.vlrentot##4 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '04', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##5 = crapcot.vlrenrpp_ir##5 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '05', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##5 = crapcot.vlrentot##5 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '05', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##6 = crapcot.vlrenrpp_ir##6 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '06', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##6 = crapcot.vlrentot##6 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '06', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##7 = crapcot.vlrenrpp_ir##7 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '07', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##7 = crapcot.vlrentot##7 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '07', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##8 = crapcot.vlrenrpp_ir##8 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '08', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##8 = crapcot.vlrentot##8 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '08', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##9 = crapcot.vlrenrpp_ir##9 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '09', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##9 = crapcot.vlrentot##9 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '09', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##10 = crapcot.vlrenrpp_ir##10 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '10', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##10 = crapcot.vlrentot##10 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '10', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##11 = crapcot.vlrenrpp_ir##11 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '11', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##11 = crapcot.vlrentot##11 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '11', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##12 = crapcot.vlrenrpp_ir##12 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '12', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##12 = crapcot.vlrentot##12 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '12', vr_vlrentot,
                                                                      0)
             where crapcot.rowid = rw_crapcot.rowid;
          exception
            when others then
              vr_des_erro := 'Erro ao atualizar cotas e recursos (1): '||sqlerrm;
              raise vr_exc_erro;
          end;
        end if;
        --
        if rw_craprpp.vlabdiof > 0 then
          -- Atualiza os campos correspondentes ao mês de referência
          begin
            update crapcot
               set crapcot.vlabiopp = crapcot.vlabiopp + rw_craprpp.vlabdiof,
                   crapcot.vlrentot##1 = crapcot.vlrentot##1 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '01', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##2 = crapcot.vlrentot##2 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '02', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##3 = crapcot.vlrentot##3 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '03', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##4 = crapcot.vlrentot##4 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '04', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##5 = crapcot.vlrentot##5 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '05', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##6 = crapcot.vlrentot##6 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '06', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##7 = crapcot.vlrentot##7 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '07', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##8 = crapcot.vlrentot##8 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '08', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##9 = crapcot.vlrentot##9 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '09', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##10 = crapcot.vlrentot##10 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '10', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##11 = crapcot.vlrentot##11 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '11', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##12 = crapcot.vlrentot##12 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '12', rw_craprpp.vlabdiof,
                                                                      0)
             where crapcot.rowid = rw_crapcot.rowid;
          exception
            when others then
              vr_des_erro := 'Erro ao atualizar cotas e recursos (2): '||sqlerrm;
              raise vr_exc_erro;
          end;
          -- Zerar o abono de IOF
          begin
            update craprpp
               set craprpp.vlabdiof = 0
             where craprpp.rowid = pr_rpp_rowid;
          exception
            when others then
              vr_des_erro := 'Erro ao zerar o abono de IOF na poupança programada: '||sqlerrm;
              raise vr_exc_erro;
          end;
        end if;
        --
        if vr_vlrentot - vr_vlprovis > 0 then
          vr_vlinfocr := vr_vlinfocr + nvl(vr_vlrentot - vr_vlprovis, 0); 
          vr_vlcompcr := vr_vlcompcr + nvl(vr_vlrentot - vr_vlprovis, 0);   
          vr_qtinfoln := vr_qtinfoln + 1;    
          vr_qtcompln := vr_qtcompln + 1; 
        end if;
      end if;
      --
      
      IF vr_cdprogra = 'CRPS147' and
         rw_craprpp.vlabcpmf > 0 then

        vr_vlinfocr := vr_vlinfocr + nvl(rw_craprpp.vlabcpmf, 0); 
        vr_vlcompcr := vr_vlcompcr + nvl(rw_craprpp.vlabcpmf, 0);   
        vr_qtinfoln := vr_qtinfoln + 1;    
        vr_qtcompln := vr_qtcompln + 1; 
        
        /* IR sobre o abono de cpmf na poupança */
        if trunc((rw_craprpp.vlabcpmf * vr_percenir / 100),2) > 0 then
          
          vr_vlinfocr := vr_vlinfocr + nvl(trunc((rw_craprpp.vlabcpmf * vr_percenir / 100),2), 0); 
          vr_vlcompcr := vr_vlcompcr + nvl(trunc((rw_craprpp.vlabcpmf * vr_percenir / 100),2), 0);   
          vr_qtinfoln := vr_qtinfoln + 1;    
          vr_qtcompln := vr_qtcompln + 1; 
          
          -- Zera o abono de cpfm na poupança programada
          begin
            update craprpp
               set vlabcpmf = 0
             where rowid = pr_rpp_rowid;
          exception
            when others then
              vr_des_erro := 'Erro ao zerar o abono de cpmf na poupança programada: '||sqlerrm;
              raise vr_exc_erro;
          end;
        end if;
      end if;
      --
      if vr_cdprogra in ('CRPS147', 'CRPS148') then
        /* Ajuste */
        vr_vlajuste := vr_vlprovis - vr_vllan152;
        --
        if vr_vlajuste <> 0 then
          -- Define qual histórico será utilizado
          if vr_vlajuste > 0 then
            vr_vlajuste_cr := abs(vr_vlajuste);
            vr_vlajuste_db := 0;
          else
            vr_vlajuste_cr := 0;
            vr_vlajuste_db := abs(vr_vlajuste);
          end if;

            vr_vlinfocr := vr_vlinfocr + nvl(vr_vlajuste_cr, 0); 
            vr_vlcompcr := vr_vlcompcr + nvl(vr_vlajuste_cr, 0);  
            vr_vlinfodb := vr_vlinfodb + nvl(vr_vlajuste_db, 0); 
            vr_vlcompdb := vr_vlcompdb + nvl(vr_vlajuste_db, 0);  
            vr_qtinfoln := vr_qtinfoln + 1;    
            vr_qtcompln := vr_qtcompln + 1; 
            
        end if;
      end if;
    end if;
    
    --Trata geração de informações para a capa do lote quando chamado pelos CRPS147 E CRPS148
    if pr_cdprogra IN('CRPS147','CRPS148') then

      if vr_vlinfocr > 0 or 
         vr_vlcompcr > 0 or 
         vr_vlinfodb > 0 or 
         vr_vlcompdb > 0 or 
         vr_qtinfoln > 0 or 
         vr_qtcompln > 0 then 
        
        --Rotina para inserir em tabela de trabalho para atualização da crplot no CRPS148
        apli0001.pc_insere_tab_wrk(pr_cdcooper     => pr_cdcooper
                                  ,pr_nrdconta     => rw_craprpp.nrdconta
                                  ,pr_cdprogra     => pr_cdprogra
                                  ,pr_dsrelatorio  => 'CRAPLOT' 
                                  ,pr_dtmvtolt     => pr_dtmvtolt
                                  ,pr_dschave      => vr_nrseqdig                                  
                                  ,pr_dsinformacao => ';'||vr_vlinfocr||';'||     
                                                           vr_vlcompcr||';'||
                                                           vr_vlinfodb||';'||
                                                           vr_vlcompdb||';'||
                                                           vr_qtinfoln||';'||
                                                           vr_qtcompln||';'
                                  ,pr_dscritic     => vr_des_erro);
       
      
        if vr_des_erro is not null then
          raise vr_exc_erro; 
        end if;                                  

      end if;

    end if;

  exception
    when vr_exc_erro THEN
      pr_cdcritic := nvl(pr_cdcritic,0);
      pr_des_erro := vr_des_erro;
    when others then
      pr_cdcritic := 0;
      pr_des_erro := 'Erro ao fazer o cálculo da aplicação programada para a conta '||rw_craprpp.nrdconta||': '||sqlerrm;
END pc_calc_app_programada;

  PROCEDURE pc_lista_aplicacoes_progr (pr_cdcooper    IN craprac.cdcooper%TYPE           --> Código da Cooperativa
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
                                      ,pr_tpaplica    IN PLS_INTEGER DEFAULT 0           --> Tipo Aplicacao (0 - Todas / 1 - Não PCAPTA (RDC PÓS, PRE e RDCA) / 2 - Apenas PCAPTA)
                                                             ,pr_cdcritic   OUT INTEGER                         --> Código da crítica
                                                             ,pr_dscritic   OUT VARCHAR2                        --> Descrição da crítica
                                                             ,pr_saldo_rdca OUT apli0001.typ_tab_saldo_rdca) IS --> Tabela com os dados da aplicação

   BEGIN                                                             
     /* .............................................................................

     Programa: pc_lista_aplicacoes_progr
     Sistema : Novos Produtos de Aplicação Programadas
     Sigla   : APLI
     Autor   : CIS Corporate
     Data    : Agosto/18.                    Ultima atualizacao: 22/08/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina geral referente a listagem de aplicacoes.

     Observacao: -----

    ..............................................................................*/                                                
        
        DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
            
            -- Declaração da tabela que conterá os dados da aplicação
            vr_tab_aplica apli0005.typ_tab_aplicacao;
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

          /* 0 - Todas ou 2 - PCAPTA */
          IF pr_tpaplica IN (0,2) THEN
      -- Consulta de novas aplicacoes
      apli0008.pc_busca_aplicacoes_prog(pr_cdcooper   => pr_cdcooper     --> Código da Cooperativa
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
          END IF;

          /* 0 - Todas ou 1 - Não PCAPTA */
          IF pr_tpaplica IN (0,1) THEN
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
        pr_dscritic := 'Erro nao tratado na APLI0008.pc_lista_aplicacoes: ' || SQLERRM;

        END;
    END pc_lista_aplicacoes_progr;

    PROCEDURE pc_busca_aplicacoes_prog(pr_cdcooper IN craprac.cdcooper%TYPE             --> Código da Cooperativa
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
                                                             ,pr_tab_aplica OUT apli0005.typ_tab_aplicacao)--> Tabela com os dados da aplicação
                                                             IS  
   BEGIN                                                             
     /* .............................................................................

     Programa: pc_busca_aplicacoes_prog
     Sistema : Novos Produtos de Aplicação Programada
     Sigla   : APLI
     Autor   : CIS
     Data    : Agosto/18.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de aplicacoes programadas.

     Observacao: -----
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
            vr_tab_aplica apli0005.typ_tab_aplicacao;
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
                  vr_tab_aplica(vr_ind_aplica).dsblqrgt := TRIM('DISPONIVEL');                 --> Descrição do indicador de bloque de resgate
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
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
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
                              ,pr_nrdrowid => vr_nrdrowid);
                  COMMIT;
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
                              ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
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
    END pc_busca_aplicacoes_prog;

  PROCEDURE pc_impres_termo_adesao_ap(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Codigo do programa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  --> Contrato
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     ,pr_nmarqpdf OUT VARCHAR2              --> Nome do PDF                           
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    /* .............................................................................

     Programa: pc_impres_termo_adesao_ap
     Sistema : Rotinas referentes à aplicação programada
     Sigla   : CRED
     Autor   : CIS Corporate
     Data    : Agosto/2018.                    

     Dados referentes ao programa:

     Frequencia:
     Objetivo  : Rotina para geração do Termo de Adesão de uma Aplicação programada
     Alteracoes: 
     
    ..............................................................................*/
    
    ---- Cursores
    
     CURSOR cr_info IS
     SELECT
        cop.nmcidade, 
        cop.cdufdcop,
        ass.cdagenci, -- numero da PA
        ass.nmprimtl,
        ass.nrcpfcgc,
        rpp.dtmvtolt,
        rpp.vlprerpp,
        Extract(day from rpp.dtdebito) indiadeb
     FROM 
        crapcop cop, 
        crapass ass, 
        craprpp rpp, 
        crapcpc cpc
  WHERE ass.cdcooper = pr_cdcooper
    AND ass.nrdconta = pr_nrdconta
    AND rpp.nrctrrpp = pr_nrctrrpp
    AND ass.cdcooper = cop.cdcooper
    AND ass.cdcooper = rpp.cdcooper
    AND ass.nrdconta = rpp.nrdconta
    AND rpp.cdprodut = cpc.cdprodut;
    
    rw_info cr_info%ROWTYPE;
    
    -- RG
    CURSOR cr_rg IS
    SELECT nrdocttl 
      FROM crapttl 
     WHERE tpdocttl = 'CI'
      AND cdcooper = pr_cdcooper
      AND nrdconta = pr_nrdconta;
    rw_rg cr_rg%ROWTYPE;

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

    vr_idseqttl        crapttl.idseqttl%TYPE;
    
    vr_dsdireto        VARCHAR2(4000);
    vr_nmendter        VARCHAR2(4000);     
    vr_dscomand        VARCHAR2(4000);
    vr_typsaida        VARCHAR2(100);    
    
    vr_rg varchar2(20);
        
    vr_dsmailcop VARCHAR2(4000);
    vr_dsassmail VARCHAR2(200);
    vr_dscormail VARCHAR2(50);

    vr_cpfcgc VARCHAR2 (30);    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml   CLOB;
    vr_txtcompl  VARCHAR2(32600);
    
    l_offset     NUMBER:=0;
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;
    
  BEGIN    
    --> Definir transação
    IF pr_flgerlog = 1 THEN
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
    END IF; 
    
    --Buscar diretorio da cooperativa
    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', --> cooper 
                                         pr_cdcooper => pr_cdcooper);
                                         
    vr_nmendter := vr_dsdireto ||'/rl/taap001';
    
    vr_dscomand := 'rm '||vr_nmendter||'* 2>/dev/null';
    
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
    pr_nmarqpdf := 'taap001'|| gene0002.fn_busca_time || '.pdf';

    --> Buscar dados para impressao do Termo de Adesão 
    OPEN cr_info;
    FETCH cr_info INTO rw_info;
    IF cr_info%NOTFOUND THEN
        vr_dscritic:='Aplicacao programada nao encontrada.';
        CLOSE cr_info;
        RAISE vr_exc_erro;
    END IF;
    CLOSE cr_info;

    -- Busca rg
    OPEN cr_rg;
    FETCH cr_rg INTO rw_rg;
    IF cr_rg%FOUND THEN
       vr_rg := rw_rg.nrdocttl;
    END IF;
    CLOSE cr_rg;

    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    
    vr_txtcompl := NULL;
    IF length(rw_info.nrcpfcgc)=11 THEN -- CPF 
        vr_cpfcgc := regexp_replace(rw_info.nrcpfcgc, '([0-9]{3})([0-9]{3})([0-9]{3})([0-9]{2})', '\1.\2.\3-\4');
    ELSE -- CNPJ
        vr_cpfcgc := regexp_replace(lpad(rw_info.nrcpfcgc,14,0), '([0-9]{2})([0-9]{3})([0-9]{3})([0-9]{4})([0-9]{2})', '\1.\2.\3/\4-\5') ;      
    END IF;
    
    --> INICIO
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>'); 
    
    pc_escreve_xml('<nrctrrpp>'     || to_char(pr_nrctrrpp,'fm99g999g990','NLS_NUMERIC_CHARACTERS=,.') ||'</nrctrrpp>'||
                   '<nomeCompleto>' || rw_info.nmprimtl     ||'</nomeCompleto>'||     
                   '<contaCorrente>'|| to_char(pr_nrdconta,'fm9g999g999g0','NLS_NUMERIC_CHARACTERS=,.') ||'</contaCorrente>'||     
                   '<cpf>'          || vr_cpfcgc     ||'</cpf>'||
                   '<valorParcela>' || to_char(rw_info.vlprerpp,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.') ||'</valorParcela>'||
                   '<identidade>'   || vr_rg                ||'</identidade>'|| 
                   '<postoAtendimento>'||rw_info.cdagenci   ||'</postoAtendimento>'||
                   '<cidade>'       || rw_info.nmcidade     ||'</cidade>'||
                   '<uf>'           || rw_info.cdufdcop     ||'</uf>'||
                   '<dataInicio>'   || to_char(rw_info.dtmvtolt,'dd/mm/yyyy') ||'</dataInicio>'||
                   '<diaDebito>'    || rw_info.indiadeb     ||'</diaDebito>');    
    --> Descarregar buffer    
    pc_escreve_xml(' ',TRUE); 
    
    --> Descarregar buffer    
    pc_escreve_xml('</raiz>',TRUE); 
    
   loop exit when l_offset > dbms_lob.getlength(vr_des_xml);
   l_offset := l_offset + 255;
   end loop;
    
    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                               , pr_cdprogra  => pr_cdprogra
                               , pr_dtmvtolt  => pr_dtmvtolt
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => '/raiz'
                               , pr_dsjasper  => 'termo_adesao_appr.jasper'
                               , pr_dsparams  => null
                               , pr_dsarqsaid => vr_dsdireto ||'/rl/'||pr_nmarqpdf
                               , pr_flg_gerar => 'S'
                               , pr_qtcoluna  => 234
                               , pr_cdrelato  => 280
                               , pr_sqcabrel  => 1
                               , pr_flg_impri => 'N'
                               , pr_nmformul  => ' '
                               , pr_nrcopias  => 1
                               , pr_nrvergrl  => 1
                               , pr_dsextmail => NULL
                               , pr_dsmailcop => vr_dsmailcop
                               , pr_dsassmail => vr_dsassmail
                               , pr_dscormail => vr_dscormail
                               , pr_des_erro  => vr_dscritic);
    
    IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
      RAISE vr_exc_erro; -- encerra programa
    END IF;        
    
    IF pr_idorigem = 5 THEN
      -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
      GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => NULL
                                  ,pr_nrdcaixa => NULL
                                  ,pr_nmarqpdf => vr_dsdireto ||'/rl/'||pr_nmarqpdf
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
      gene0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm '||vr_dsdireto ||'/rl/'||pr_nmarqpdf
                           ,pr_typ_saida   => vr_typsaida
                           ,pr_des_saida   => vr_dscritic);
      -- Se retornou erro
      IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_erro; -- encerra programa
      END IF;
    END IF;        
    
    --> Gerar log de sucesso
    IF pr_flgerlog = 1 THEN
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                           pr_cdoperad => pr_cdoperad, 
                           pr_dscritic => NULL, 
                           pr_dsorigem => vr_dsorigem, 
                           pr_dstransa => vr_dstransa, 
                           pr_dttransa => trunc(SYSDATE),
                           pr_flgtrans =>  1, -- True
                           pr_hrtransa => gene0002.fn_busca_time, 
                           pr_idseqttl => vr_idseqttl, 
                           pr_nmdatela => pr_nmdatela, 
                           pr_nrdconta => pr_nrdconta, 
                           pr_nrdrowid => vr_nrdrowid);
                             
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                pr_nmdcampo => 'nrctrrpp', 
                                pr_dsdadant => NULL, 
                                pr_dsdadatu => pr_nrctrrpp);
    END IF;
    
    COMMIT;
    
  EXCEPTION    
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
      END IF;
      
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdoperad, 
                             pr_dscritic => pr_dscritic, 
                             pr_dsorigem => vr_dsorigem, 
                             pr_dstransa => vr_dstransa, 
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans =>  0, --FALSE
                             pr_hrtransa => gene0002.fn_busca_time, 
                             pr_idseqttl => vr_idseqttl, 
                             pr_nmdatela => pr_nmdatela, 
                             pr_nrdconta => pr_nrdconta, 
                             pr_nrdrowid => vr_nrdrowid);
                             
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'nrctrrpp', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrrpp);
      END IF;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro ao gerar impressao do termo de adesao: ' || SQLERRM, chr(13)),chr(10));   
  
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdoperad, 
                             pr_dscritic => pr_dscritic, 
                             pr_dsorigem => vr_dsorigem, 
                             pr_dstransa => vr_dstransa, 
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans =>  0, --FALSE
                             pr_hrtransa => gene0002.fn_busca_time, 
                             pr_idseqttl => vr_idseqttl, 
                             pr_nmdatela => pr_nmdatela, 
                             pr_nrdconta => pr_nrdconta, 
                             pr_nrdrowid => vr_nrdrowid);
                             
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'nrctrrpp', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrrpp);
      END IF; 
      
  END pc_impres_termo_adesao_ap;

  PROCEDURE pc_impres_termo_adesao_ap_web (pr_nrdconta IN craprac.nrdconta%TYPE   -- Número da Conta
                                          ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE   -- Número da Aplicação Programada.
                                          ,pr_dtmvtolt IN VARCHAR2                -- Data de Movimento Inicial
                                          ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                          ,pr_xmllog   IN VARCHAR2                -- XML com informacoes de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER            -- Código da crítica
                                          ,pr_dscritic OUT VARCHAR2               -- Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2               -- Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2)              -- Erros do processo

  IS
  BEGIN
    /* .............................................................................

     Programa: pc_impres_termo_adesao_ap_web
     Sistema : Rotinas referentes à aplicação programada
     Sigla   : CRED
     Autor   : CIS Corporate
     Data    : Agosto/2018.                    

     Dados referentes ao programa:

     Frequencia:
     Objetivo  : Rotina para geração do Termo de Adesão de uma Aplicação programada - Mensageria
     Alteracoes: 
     
    ..............................................................................*/

  DECLARE
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    vr_nmarqpdf VARCHAR2(100);
    
    -- Variaveis auxiliares
    vr_exc_erro EXCEPTION;

    -- Variaveis de entrada
    vr_dtmvtolt Date := TO_DATE(pr_dtmvtolt,'dd/mm/yyyy');  

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

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
      RAISE vr_exc_erro;
    END IF;     

    -- Imprime o termo
    pc_impres_termo_adesao_ap (pr_cdcooper => vr_cdcooper
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdprogra => 'ATENDA'
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_dtmvtolt => vr_dtmvtolt
                              ,pr_nrctrrpp => pr_nrctrrpp
                              ,pr_flgerlog => pr_flgerlog
                              ,pr_nmarqpdf => vr_nmarqpdf
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;     

     -- Criar cabeçalho do XML
     dbms_lob.createtemporary(vr_clobxmlc, TRUE); 
     dbms_lob.open(vr_clobxmlc, dbms_lob.lob_readwrite);
     -- Insere o cabeçalho do XML 
     gene0002.pc_escreve_xml (pr_xml            => vr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>');

     gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc
                            ,pr_texto_completo => vr_xml_temp 
                            ,pr_texto_novo     => 
                            '<Registro>'||
                            '<nmarqpdf>'||vr_nmarqpdf||'</nmarqpdf>'||
                            '</Registro>'
                            );
     -- Encerrar a tag raiz 
     gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '</Dados></Root>' 
                             ,pr_fecha_xml      => TRUE);
                                 
     pr_retxml := XMLType.createXML(vr_clobxmlc);

  Exception
    When vr_exc_erro Then
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        
    When others Then
      pr_cdcritic := null; -- não será utilizado
      pr_dscritic := 'Erro geral em APLI0008.pc_buscar_extrato_apl_prog_web: '||SQLERRM;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      
  END;


  END pc_impres_termo_adesao_ap_web;

END APLI0008; 
/
