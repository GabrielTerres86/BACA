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
  --			  16/12/2016 - Altera��es Referentes ao projeto 300. (Reinert)
  --------------------------------------------------------------------------------------------------------------*/

	TYPE typ_reg_cstdsc IS
		RECORD(dstipchq VARCHAR2(3)
					,cdcooper crapcop.cdcooper%TYPE
					,dtmvtolt DATE
					,dtlibera DATE
					,dtdcaptu DATE
					,cdcmpchq crapcst.cdcmpchq%TYPE
					,cdbanchq crapcst.cdbanchq%TYPE
					,cdagechq crapcst.cdagechq%TYPE
					,nrctachq crapcst.nrctachq%TYPE
					,nrcheque crapcst.nrcheque%TYPE
					,vlcheque crapcst.vlcheque%TYPE
					,inconcil crapdcc.inconcil%TYPE
					,nmcheque crapcec.nmcheque%TYPE
					,nrcpfcgc crapcec.nrcpfcgc%TYPE
					,dsdocmc7 crapcst.dsdocmc7%TYPE
					,dtcustod craphcc.dtcustod%TYPE
					,nrremret craphcc.nrremret%TYPE);
					
	TYPE typ_tab_cstdsc	IS
		TABLE OF typ_reg_cstdsc
		INDEX BY BINARY_INTEGER;					
		
	TYPE typ_reg_ocorrencias IS
	  RECORD(flbloque tbdscc_ocorrencias.flgbloqueio%TYPE
		      ,cdocorre tbdscc_ocorrencias.cdocorre%TYPE
					,dsrestri VARCHAR2(1000)
					,dsdetres VARCHAR2(1000));

	TYPE typ_tab_ocorrencias	IS
		TABLE OF typ_reg_ocorrencias
		INDEX BY BINARY_INTEGER;					
		
  TYPE typ_reg_cheques IS
	  RECORD(cdcooper crapcop.cdcooper%TYPE
		      ,nrdconta crapcdb.nrdconta%TYPE
		      ,nrremret crapcdb.nrremret%TYPE
					,cdagechq crapcdb.cdagechq%TYPE
					,cdagenci crapcdb.cdagenci%TYPE
					,cdbanchq crapcdb.cdbanchq%TYPE
					,cdbccxlt crapcdb.cdbccxlt%TYPE
					,cdcmpchq crapcdb.cdcmpchq%TYPE
					,dsdocmc7 crapcdb.dsdocmc7%TYPE
					,dtlibera crapcdb.dtlibera%TYPE
					,dtmvtolt crapcdb.dtmvtolt%TYPE
					,dtcustod craphcc.dtcustod%TYPE					
					,dtdcaptu crapdcc.dtdcaptu%TYPE
					,nrctachq crapcdb.nrctachq%TYPE
					,nrcheque crapcdb.nrcheque%TYPE
					,nrseqdig crapcdb.nrseqdig%TYPE
					,vlcheque crapcdb.vlcheque%TYPE
					,vlliquid crapcdb.vlliquid%TYPE
					,nrcpfcgc crapcdb.nrcpfcgc%TYPE
					,nmcheque crapcec.nmcheque%TYPE
					,nrseqarq crapdcc.nrseqarq%TYPE
					,flgaprov INTEGER
					,intipchq INTEGER  -- Indicador de tipo de cheque (1 - Novo, 2 - Selecionado)
					,inemiten NUMBER   -- Indicador de emitente (0 - N�o cadastrado, 1 - Cadastrado)
					,dssitana VARCHAR2(1000) -- Descri��o da situa��o da analise
					,insitana NUMBER
					,inchqcop NUMBER
					,nrddigc3 NUMBER
					,nrdolote crapcdb.nrdolote%TYPE
					,insitchq INTEGER
					,ocorrencias typ_tab_ocorrencias);
					
	TYPE typ_tab_cheques IS
	  TABLE OF typ_reg_cheques
		INDEX BY BINARY_INTEGER;
		
	TYPE typ_rec_lim_desconto 
		IS RECORD ( vllimite    NUMBER,
								qtdiavig    INTEGER,
								qtdiavig_c  INTEGER,
								qtprzmin    INTEGER,
								qtprzmin_c  INTEGER,
								qtprzmax    INTEGER,
								txdmulta    NUMBER,
								txdmulta_c  NUMBER,
								vlconchq    NUMBER,
								vlconchq_c  NUMBER,
								vlmaxemi    NUMBER,
								pcchqloc    NUMBER,
								pcchqloc_c  NUMBER,
								pcchqemi    NUMBER,
								pcchqemi_c  NUMBER,
								qtdiasoc    NUMBER,
								qtdiasoc_c  NUMBER,
								qtdevchq    NUMBER,
								qtdevchq_c  NUMBER,
								pctollim    NUMBER,
								vllimite_c  NUMBER,
								vlmaxemi_c  NUMBER,
								qtprzmax_c  NUMBER,
								pctollim_c  NUMBER,
								qtdiasli    NUMBER,
								horalimt    NUMBER,
								minlimit    NUMBER,
								qtdiasli_c  NUMBER,
								horalimt_c  NUMBER,
								minlimit_c  NUMBER,
								Flemipar    INTEGER,  -- Verificar se Emitente � Conjugue do Cooperado
								Flemipar_c  INTEGER,  -- Verificar se Emitente � Conjugue do Cooperado
								Przmxcmp    NUMBER,   -- Prazo M�ximo de Compensa��o
								Przmxcmp_c  NUMBER,   -- Prazo M�ximo de Compensa��o
								Flpjzemi    INTEGER,  -- Verificar Preju�zo do Emitente
								Flpjzemi_c  INTEGER,  -- Verificar Preju�zo do Emitente
								Flemisol    INTEGER,  -- Verificar Emitente x Conta Solicitante
								Flemisol_c  INTEGER,  -- Verificar Emitente x Conta Solicitante
								Prcliqui    INTEGER,  -- Percentual de Liquidez
								Prcliqui_c  INTEGER,  -- Percentual de Liquidez
								Qtmesliq    INTEGER,  -- Qtd. Meses C�lculo Percentual de Liquidez
								Qtmesliq_c  INTEGER,  -- Qtd. Meses C�lculo Percentual de Liquidez                  
								Vlrenlim    NUMBER,   -- Renda x Limite Desconto
								Vlrenlim_c  NUMBER,   -- Renda x Limite Desconto
								Qtmxrede    INTEGER,  -- Qtd. M�xima Redesconto
								Qtmxrede_c  INTEGER,  -- Qtd. M�xima Redesconto
								Fldchqdv    INTEGER,  -- Permitir Desconto Cheque Devolvido
								Fldchqdv_c  INTEGER,  -- Permitir Desconto Cheque Devolvido
								Vlmxassi    NUMBER,   -- Valor M�ximo Dispensa Assinatura
								Vlmxassi_c  NUMBER    -- Valor M�ximo Dispensa Assinatura
								);
                  
  TYPE typ_tab_lim_desconto IS TABLE OF typ_rec_lim_desconto
       INDEX BY PLS_INTEGER;
			 
  PROCEDURE pc_busca_tab_limdescont(  pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa 
                                     ,pr_inpessoa IN NUMBER                --> Tipo de pessoa ( 0 - todos 1-Fisica e 2-Juridica)
                                     ,pr_tab_lim_desconto OUT typ_tab_lim_desconto  --> Temptable com os dados do limite de desconto                                     
                                     ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2);           --> Descri��o da cr�tica
                                     
  
  --> Buscar parametros gerais de desconto de cheque - TAB019
  PROCEDURE pc_busca_parametros_dscchq(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da Cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> C�digo da agencia
                                      ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> C�digo do Operador
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> data do movimento 
                                      ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                      ,pr_inpessoa IN crapass.inpessoa%TYPE  --> Indicador de tipo de pessoa
                                       --------> OUT <--------
                                      ,pr_tab_dados_dscchq  OUT DSCT0002.typ_tab_dados_dscchq --> Tabela contendo os parametros
                                      ,pr_cdcritic          OUT PLS_INTEGER  --> Codigo da critica
                                      ,pr_dscritic          OUT VARCHAR2);   --> Descricao da critica
  
  -->  Buscar restricoes de um determinado bordero ou cheque  
  PROCEDURE pc_busca_restricoes(pr_cdcooper IN crapabc.cdcooper%TYPE  --> C�digo da Cooperativa
                               ,pr_nrborder IN crapabc.nrborder%TYPE  --> numero do bordero
                               ,pr_cdcmpchq IN crapabc.cdcmpchq%TYPE  --> Codigo da compensacao impressa no cheque acolhido
                               ,pr_cdbanchq IN crapabc.cdbanchq%TYPE  --> Codigo do banco impresso no cheque acolhido
                               ,pr_cdagechq IN crapabc.cdagechq%TYPE  --> Codigo da agencia impressa no cheque acolhido
                               ,pr_nrctachq IN crapabc.nrctachq%TYPE  --> Numero da conta do cheque acolhido
                               ,pr_nrcheque IN crapabc.nrcheque%TYPE  --> Numero do cheque capturado
                               ,pr_tprestri IN INTEGER                --> Tipo de restricao
                               --------> OUT <--------                                   
                               ,pr_tab_bordero_restri IN OUT NOCOPY DSCT0002.typ_tab_bordero_restri --> retorna restricoes do cheques do bordero
                               ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                               ,pr_dscritic OUT VARCHAR2);            --> Descri��o da cr�tica
  
  --> Buscar dados de um determinado bordero
  PROCEDURE pc_busca_dados_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE  --> C�digo da Cooperativa
                                  ,pr_cdagenci IN crapage.cdagenci%TYPE  --> C�digo da agencia
                                  ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                  ,pr_cdoperad IN crapope.cdoperad%TYPE  --> C�digo do Operador
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                  ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                  ,pr_cddopcao IN VARCHAR2               --> Cod opcao
                                  --------> OUT <--------                                   
                                  ,pr_tab_dados_border OUT DSCT0002.typ_tab_dados_border --> retorna dados do bordero
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2);            --> Descri��o da cr�tica
  
  --> Buscar cheques de um determinado bordero a partir da crapcdb 
  PROCEDURE pc_busca_cheques_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE  --> C�digo da Cooperativa
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data atual
                                    ,pr_nrborder IN crapbdc.nrborder%TYPE  --> numero do bordero
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                    --------> OUT <--------                                   
                                    ,pr_tab_chq_bordero        OUT DSCT0002.typ_tab_chq_bordero    --> retorna cheques do bordero
                                    ,pr_tab_bordero_restri     OUT DSCT0002.typ_tab_bordero_restri --> retorna restricoes do cheques do bordero
                                    ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                    ,pr_dscritic OUT VARCHAR2);            --> Descri��o da cr�tica
  
  --> Carrega dados com os cheques do bordero
  PROCEDURE pc_carrega_dados_bordero_chq(pr_cdcooper IN crapcop.cdcooper%TYPE  --> C�digo da Cooperativa
                                        ,pr_cdagenci IN crapage.cdagenci%TYPE  --> C�digo da agencia
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
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
                                        ,pr_cdcritic                OUT PLS_INTEGER --> C�digo da cr�tica
                                        ,pr_dscritic                OUT VARCHAR2);  --> Descri��o da cr�tica

  --> Carregar dados para efetuar a impressao da nota promissoria
  PROCEDURE pc_dados_nota_promissoria(pr_cdcooper IN crapcop.cdcooper%TYPE   --> C�digo da Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE   --> C�digo da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE   --> Numero do caixa do operador
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE   --> C�digo do Operador
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
  PROCEDURE pc_gera_impressao_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE  --> C�digo da Cooperativa
                                     ,pr_cdagecxa IN crapage.cdagenci%TYPE  --> C�digo da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdopecxa IN crapope.cdoperad%TYPE  --> C�digo do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
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
                                     ,pr_flgrestr IN INTEGER DEFAULT 1      --> Indicador se deve imprimir restricoes(0-nao, 1-sim)
                                     --------> OUT <--------                                   
                                     ,pr_nmarqpdf OUT VARCHAR2              --> Retornar nome do relatorio PDF
                                     ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2);            --> Descri��o da cr�tica

  --> Procedure para gerar impressoes
  PROCEDURE pc_gera_impressao(pr_nrdconta   IN crapass.nrdconta%TYPE --> N�mero da Conta
                             ,pr_idseqttl   IN crapttl.idseqttl%TYPE --> Titular da Conta
                             ,pr_idimpres   IN INTEGER               --> Indicador de impressao
                             ,pr_tpctrlim   IN craplim.tpctrlim%TYPE --> Tipo de contrato de limite(2-Cheque e 3-Titulo)
                             ,pr_nrctrlim   IN craplim.nrctrlim%TYPE --> Contrato
                             ,pr_nrborder   IN crapbdc.nrborder%TYPE --> Numero do bordero
                             ,pr_dsiduser   IN VARCHAR2              --> Descricao do id do usuario
                             ,pr_flgemail   IN INTEGER               --> Indicador de envia por email (0-nao, 1-sim)
                             ,pr_flgerlog   IN INTEGER               --> Indicador se deve gerar log(0-nao, 1-sim)
                             ,pr_flgrestr   IN INTEGER               --> Indicador se deve imprimir restricoes(0-nao, 1-sim)
                             ,pr_xmllog     IN VARCHAR2              --> XML com informacoes de LOG
                             ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                             ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                             ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                             ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                             ,pr_des_erro  OUT VARCHAR2);            --> Erros do processo

  -- Procedure para buscar cheques em custodia para desconto
  PROCEDURE pc_busca_cheques_dsc_cst(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
		                                ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Conta
																		,pr_cdagenci IN crapage.cdagenci%TYPE  --> C�digo da agencia
																		,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
																		,pr_cdoperad IN crapope.cdoperad%TYPE  --> C�digo do Operador
																		,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> data do movimento 
																		,pr_idorigem IN INTEGER                --> Identificador de Origem
		                                ,pr_nriniseq IN NUMBER                --> Pagina��o - Inicio de sequencia
																		,pr_nrregist IN NUMBER                --> Pagina��o - N�mero de registros																		
																		,pr_qtregist OUT NUMBER
		                                ,pr_tab_cstdsc OUT typ_tab_cstdsc      --> PlTable com dados dos cheques
																		,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
																		,pr_dscritic OUT VARCHAR2);            --> Descricao da critica
														 
  PROCEDURE pc_verifica_emitentes(pr_cdcooper IN crapcop.cdcooper%TYPE
																 ,pr_nrdconta IN crapass.nrdconta%TYPE
																 ,pr_dscheque IN VARCHAR2
																 ,pr_tab_cheques OUT typ_tab_cheques
																 ,pr_cdcritic OUT PLS_INTEGER
																 ,pr_dscritic OUT VARCHAR2);

	PROCEDURE pc_criar_bordero_cheques(pr_cdcooper IN crapcop.cdcooper%TYPE
																		,pr_nrdconta IN crapass.nrdconta%TYPE
																		,pr_cdagenci IN crapass.cdagenci%TYPE
																		,pr_idorigem IN PLS_INTEGER
																		,pr_cdoperad IN VARCHAR2
																		,pr_nrdolote OUT crapbdc.nrdolote%TYPE																		
																		,pr_nrborder OUT crapbdc.nrborder%TYPE
																		,pr_cdcritic OUT PLS_INTEGER
																		,pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_adicionar_cheques_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE
																				,pr_nrdconta IN crapass.nrdconta%TYPE
																				,pr_cdagenci IN crapass.cdagenci%TYPE
																				,pr_idorigem IN PLS_INTEGER
																				,pr_cdoperad IN VARCHAR2
																				,pr_nrborder IN crapbdc.nrborder%TYPE
																				,pr_nrdolote IN crapbdc.nrdolote%TYPE
																				,pr_tab_cheques IN typ_tab_cheques
																				,pr_cdcritic OUT PLS_INTEGER
																				,pr_dscritic OUT VARCHAR2);

	PROCEDURE pc_excluir_cheque_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE
																		 ,pr_nrdconta IN crapass.nrdconta%TYPE
																		 ,pr_cdagenci IN crapass.cdagenci%TYPE
																		 ,pr_idorigem IN PLS_INTEGER
																		 ,pr_cdoperad IN VARCHAR2
																		 ,pr_nrborder IN crapbdc.nrborder%TYPE
																		 ,pr_tab_cheques IN typ_tab_cheques
																		 ,pr_cdcritic OUT PLS_INTEGER
																		 ,pr_dscritic OUT VARCHAR2);

	PROCEDURE pc_busca_cheques_analise(pr_cdcooper IN crapcop.cdcooper%TYPE
																		,pr_nrdconta IN crapass.nrdconta%TYPE
																		,pr_nrborder IN crapbdc.nrborder%TYPE
																		,pr_tab_cheques OUT typ_tab_cheques																		
																		,pr_cdcritic OUT PLS_INTEGER
																		,pr_dscritic OUT VARCHAR2);
																		
  PROCEDURE pc_analisar_bordero_cheques(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
																			 ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da conta
																			 ,pr_cdagenci IN crapass.cdagenci%TYPE  --> Ag�ncia
																			 ,pr_idorigem IN INTEGER                --> Identificador de Origem
																			 ,pr_cdoperad IN crapope.cdoperad%TYPE  --> C�digo do Operador
																			 ,pr_nrborder IN crapabc.nrborder%TYPE  --> numero do bordero
																			 ,pr_tab_cheques IN OUT typ_tab_cheques --> PlTable com dados dos cheques
																			 ,pr_flganali IN INTEGER DEFAULT 1      --> Flag deve atualizar o status para analisado
																			 ,pr_cdcritic OUT PLS_INTEGER           --> C�d. da cr�tica
																			 ,pr_dscritic OUT VARCHAR2);            --> Descri��o da cr�tica																		

	PROCEDURE pc_aprovar_reprovar_chq(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
																	 ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da conta
																	 ,pr_cdagenci IN crapass.cdagenci%TYPE  --> Ag�ncia
																	 ,pr_idorigem IN INTEGER                --> Identificador de Origem
																	 ,pr_cdoperad IN crapope.cdoperad%TYPE  --> C�digo do Operador
																	 ,pr_nrborder IN crapabc.nrborder%TYPE  --> numero do bordero
																	 ,pr_tab_cheques IN typ_tab_cheques     --> PlTable com dados dos cheques
																	 ,pr_cdcritic OUT PLS_INTEGER           --> C�d. da cr�tica
																	 ,pr_dscritic OUT VARCHAR2);            --> Descri��o da cr�tica

  PROCEDURE pc_efetiva_desconto_bordero(pr_cdcooper IN crapcdb.cdcooper%TYPE  --> Cooperativa
		                                   ,pr_nrdconta IN crapcdb.nrdconta%TYPE  --> Nr. da Conta
		                                   ,pr_nrborder IN crapcdb.nrborder%TYPE  --> Nr. Border�
																			 ,pr_cdoperad IN crapcdb.cdopeana%TYPE  --> C�d. operador
																			 ,pr_cdagenci IN crapcdb.cdagenci%TYPE  --> PA
																			 ,pr_cdopcolb IN crapbdc.cdopcolb%TYPE  --> Operador libera��o
																			 ,pr_cdcritic OUT PLS_INTEGER           --> Cr�tica
																			 ,pr_dscritic OUT VARCHAR2);            --> Desc. da cr�tica

	PROCEDURE pc_resgata_cheques_bordero(pr_cdcooper IN crapcdb.cdcooper%TYPE  --> Cooperativa
                                      ,pr_nrdconta IN crapcdb.nrdconta%TYPE  --> Nr. da Conta
                                      ,pr_nrborder IN crapcdb.nrborder%TYPE  --> Nr. Border�
                                      ,pr_cdoperad IN crapcdb.cdopeana%TYPE  --> C�d. operador
																	    ,pr_tab_cheques IN typ_tab_cheques     --> PlTable com dados dos cheques
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Cr�tica
                                      ,pr_dscritic OUT VARCHAR2);            --> Desc. da cr�tica

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

  PROCEDURE pc_busca_tab_limdescont(  pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo da cooperativa 
                                     ,pr_inpessoa IN NUMBER                --> Tipo de pessoa ( 0 - todos 1-Fisica e 2-Juridica)
                                     ,pr_tab_lim_desconto OUT typ_tab_lim_desconto  --> Temptable com os dados do limite de desconto                                     
                                     ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                     ) IS
    /* .............................................................................
    
        Programa: pc_busca_tab_limdescont
        Sistema : CECRED
        Sigla   : DSCC
        Autor   : Odirlei Busana (Amcom)
        Data    : Julho/2016.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Retorna na temptable os dados da tab de limite de desconto
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------   
      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> C�d. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_ini  INTEGER;     
      vr_fim  INTEGER;
      
      vr_cdacesso VARCHAR2(100);
      vr_tab_limdesconto gene0002.typ_split;
      
      
      ---------->> CURSORES <<--------
      CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                       ,pr_cdacesso IN craptab.cdacesso%TYPE) IS
        SELECT tab.dstextab 
          FROM craptab tab
         WHERE tab.cdcooper = pr_cdcooper
           AND upper(tab.nmsistem) = 'CRED'
           AND upper(tab.tptabela) = 'USUARI'
           AND tab.cdempres = 11
           AND upper(tab.cdacesso) = pr_cdacesso
           AND tab.tpregist = 0;
      rw_craptab cr_craptab%ROWTYPE;
    
    
    BEGIN
    
      --> Caso informado inpessoa 0, deve buscar 
      --> de pessoa fisica e juridica
      IF pr_inpessoa = 0 THEN
        vr_ini := 1;
        vr_fim := 2;
      ELSE
        vr_ini := pr_inpessoa;
        vr_fim := pr_inpessoa;
      END IF;   
      
      --> Buscar limites
      FOR vr_inpessoa IN vr_ini..vr_fim LOOP            
      
        IF vr_inpessoa = 1 THEN
          vr_cdacesso := 'LIMDESCONTPF';
        ELSE
          vr_cdacesso := 'LIMDESCONTPJ';
        END IF;
        
        --> Buscar dados de limites de descontos 
        --> conforma a tipo de pessoa
        OPEN cr_craptab (pr_cdcooper => pr_cdcooper
                        ,pr_cdacesso => vr_cdacesso);
        FETCH cr_craptab INTO rw_craptab;    
        -- Se nao encontrar
        IF cr_craptab%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_craptab;
        
          -- Montar mensagem de critica
          vr_cdcritic := 55;
          vr_dscritic := '';
          -- volta para o programa chamador
          RAISE vr_exc_saida;
        
        END IF;    
        -- Fechar o cursor
        CLOSE cr_craptab;
        
        vr_tab_limdesconto := gene0002.fn_quebra_string(rw_craptab.dstextab,' ');
        
        IF vr_tab_limdesconto.count > 0 THEN
          
          -- Ler os dados da linha do limite de desconto 
          FOR i IN vr_tab_limdesconto.first..vr_tab_limdesconto.last LOOP          
            
            CASE i 
              WHEN 1 THEN -- pos 1 - 12
                pr_tab_lim_desconto(vr_inpessoa).vllimite  := to_number(vr_tab_limdesconto(i),'999999990d00','NLS_NUMERIC_CHARACTERS='',.''');
              WHEN 2 THEN -- pos 87 - 12
                pr_tab_lim_desconto(vr_inpessoa).vllimite_c := to_number(vr_tab_limdesconto(i),'999999990d00','NLS_NUMERIC_CHARACTERS='',.''');
              WHEN 3 THEN -- pos 14 - 4
                pr_tab_lim_desconto(vr_inpessoa).qtdiavig   := vr_tab_limdesconto(i);    
                pr_tab_lim_desconto(vr_inpessoa).qtdiavig_c := vr_tab_limdesconto(i);    
              WHEN 4 THEN -- pos 22 - 3
                pr_tab_lim_desconto(vr_inpessoa).qtprzmin   := vr_tab_limdesconto(i);   
                pr_tab_lim_desconto(vr_inpessoa).qtprzmin_c := vr_tab_limdesconto(i);   
              WHEN 5 THEN -- pos 26 - 3
                pr_tab_lim_desconto(vr_inpessoa).qtprzmax := vr_tab_limdesconto(i);     
              WHEN 6 THEN -- pos 113 - 3
                pr_tab_lim_desconto(vr_inpessoa).qtprzmax_c := vr_tab_limdesconto(i);   
              WHEN 7 THEN -- pos 30 - 10
                pr_tab_lim_desconto(vr_inpessoa).txdmulta   := to_number(vr_tab_limdesconto(i),'000d000000','NLS_NUMERIC_CHARACTERS='',.'''); 
                pr_tab_lim_desconto(vr_inpessoa).txdmulta_c := to_number(vr_tab_limdesconto(i),'000d000000','NLS_NUMERIC_CHARACTERS='',.'''); 
              WHEN 8 THEN -- pos 41 - 12
                pr_tab_lim_desconto(vr_inpessoa).vlconchq   := to_number(vr_tab_limdesconto(i),'999999990d00','NLS_NUMERIC_CHARACTERS='',.'''); 
                pr_tab_lim_desconto(vr_inpessoa).vlconchq_c := to_number(vr_tab_limdesconto(i),'999999990d00','NLS_NUMERIC_CHARACTERS='',.'''); 
              WHEN 9 THEN -- pos 54 - 12
                pr_tab_lim_desconto(vr_inpessoa).vlmaxemi   := to_number(vr_tab_limdesconto(i),'999999990d00','NLS_NUMERIC_CHARACTERS='',.'''); 
              WHEN 10 THEN -- pos 101 - 12
                pr_tab_lim_desconto(vr_inpessoa).vlmaxemi_c := to_number(vr_tab_limdesconto(i),'999999990d00','NLS_NUMERIC_CHARACTERS='',.''');                
              WHEN 11 THEN -- pos 67 - 3
                pr_tab_lim_desconto(vr_inpessoa).pcchqloc   := vr_tab_limdesconto(i);   
                pr_tab_lim_desconto(vr_inpessoa).pcchqloc_c := vr_tab_limdesconto(i);   
              WHEN 12 THEN -- pos 71 - 3
                pr_tab_lim_desconto(vr_inpessoa).pcchqemi   := vr_tab_limdesconto(i);   
                pr_tab_lim_desconto(vr_inpessoa).pcchqemi_c := vr_tab_limdesconto(i);        
              WHEN 13 THEN -- pos 75 - 3
                pr_tab_lim_desconto(vr_inpessoa).qtdiasoc   := vr_tab_limdesconto(i);   
                pr_tab_lim_desconto(vr_inpessoa).qtdiasoc_c := vr_tab_limdesconto(i);
              WHEN 14 THEN -- pos 79 - 3
                pr_tab_lim_desconto(vr_inpessoa).qtdevchq   := vr_tab_limdesconto(i);   
                pr_tab_lim_desconto(vr_inpessoa).qtdevchq_c := vr_tab_limdesconto(i); 
              WHEN 15 THEN -- pos 83 - 3
                pr_tab_lim_desconto(vr_inpessoa).pctollim   := vr_tab_limdesconto(i);                               
              WHEN 16 THEN -- pos 117 - 3
                pr_tab_lim_desconto(vr_inpessoa).pctollim_c := vr_tab_limdesconto(i);    
              WHEN 17 THEN -- pos 121 - 2
                pr_tab_lim_desconto(vr_inpessoa).qtdiasli   := vr_tab_limdesconto(i);  
              WHEN 18 THEN -- pos 124 - 5 
                pr_tab_lim_desconto(vr_inpessoa).horalimt   := to_char(to_date(vr_tab_limdesconto(i),'SSSSS'),'HH24');
                pr_tab_lim_desconto(vr_inpessoa).minlimit   := to_char(to_date(vr_tab_limdesconto(i),'SSSSS'),'MI');
              WHEN 19 THEN 
                pr_tab_lim_desconto(vr_inpessoa).qtdiasli_c := vr_tab_limdesconto(i);                              
              WHEN 20 THEN 
                pr_tab_lim_desconto(vr_inpessoa).horalimt_c   := to_char(to_date(vr_tab_limdesconto(i),'SSSSS'),'HH24');
                pr_tab_lim_desconto(vr_inpessoa).minlimit_c   := to_char(to_date(vr_tab_limdesconto(i),'SSSSS'),'MI');  
              WHEN 21 THEN 
                pr_tab_lim_desconto(vr_inpessoa).Flemipar     := vr_tab_limdesconto(i);  
              WHEN 22 THEN 
                pr_tab_lim_desconto(vr_inpessoa).Flemipar_c   := vr_tab_limdesconto(i);  
              WHEN 23 THEN 
                pr_tab_lim_desconto(vr_inpessoa).Przmxcmp     := vr_tab_limdesconto(i);  
              WHEN 24 THEN 
                pr_tab_lim_desconto(vr_inpessoa).Przmxcmp_c   := vr_tab_limdesconto(i);  
              WHEN 25 THEN 
                pr_tab_lim_desconto(vr_inpessoa).Flpjzemi     := vr_tab_limdesconto(i);  
              WHEN 26 THEN 
                pr_tab_lim_desconto(vr_inpessoa).Flpjzemi_c   := vr_tab_limdesconto(i);  
              WHEN 27 THEN 
                pr_tab_lim_desconto(vr_inpessoa).Flemisol     := vr_tab_limdesconto(i);  
              WHEN 28 THEN 
                pr_tab_lim_desconto(vr_inpessoa).Flemisol_c   := vr_tab_limdesconto(i);  
              WHEN 29 THEN 
                pr_tab_lim_desconto(vr_inpessoa).Prcliqui     := vr_tab_limdesconto(i);  
              WHEN 30 THEN 
                pr_tab_lim_desconto(vr_inpessoa).Prcliqui_c   := vr_tab_limdesconto(i);  
              WHEN 31 THEN 
                pr_tab_lim_desconto(vr_inpessoa).Qtmesliq     := vr_tab_limdesconto(i);  
              WHEN 32 THEN 
                pr_tab_lim_desconto(vr_inpessoa).Qtmesliq_c   := vr_tab_limdesconto(i);   
              WHEN 33 THEN 
                pr_tab_lim_desconto(vr_inpessoa).Vlrenlim     := vr_tab_limdesconto(i);  
              WHEN 34 THEN 
                pr_tab_lim_desconto(vr_inpessoa).Vlrenlim_c   := vr_tab_limdesconto(i);  
              WHEN 35 THEN 
                pr_tab_lim_desconto(vr_inpessoa).Qtmxrede     := vr_tab_limdesconto(i);   
              WHEN 36 THEN 
                pr_tab_lim_desconto(vr_inpessoa).Qtmxrede_c   := vr_tab_limdesconto(i);  
              WHEN 37 THEN 
                pr_tab_lim_desconto(vr_inpessoa).Fldchqdv     := vr_tab_limdesconto(i);  
              WHEN 38 THEN 
                pr_tab_lim_desconto(vr_inpessoa).Fldchqdv_c   := vr_tab_limdesconto(i);  
              WHEN 39 THEN 
                pr_tab_lim_desconto(vr_inpessoa).Vlmxassi     := to_number(vr_tab_limdesconto(i),'999999990d00','NLS_NUMERIC_CHARACTERS='',.''');
              WHEN 40 THEN 
                pr_tab_lim_desconto(vr_inpessoa).Vlmxassi_c   := to_number(vr_tab_limdesconto(i),'999999990d00','NLS_NUMERIC_CHARACTERS='',.''');
              ELSE
                NULL;
              END CASE;
          END LOOP;
        
        
        ELSE
          -- Montar mensagem de critica
          vr_dscritic := 'Dados de limite de desconto n�o encontrados';
          -- volta para o programa chamador
          RAISE vr_exc_saida;  
        
        END IF;            
      END LOOP;
      
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro ao buscar limites: ' || SQLERRM;
      
  END pc_busca_tab_limdescont;
  
  --> Buscar parametros gerais de desconto de cheque - TAB019
  PROCEDURE pc_busca_parametros_dscchq(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da Cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> C�digo da agencia
                                      ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE  --> C�digo do Operador
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> data do movimento 
                                      ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                      ,pr_inpessoa IN crapass.inpessoa%TYPE  --> Indicador de tipo de pessoa
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
    --  Data     : Agosto/2016                          Ultima atualizacao: 22/09/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para efetuar buscar de parametros gerais de desconto de cheque - TAB019
    --
    --   Altera��o : 22/08/2016 - Conversao Progress -> Oracle (Jaison/Daniel)
    --
    --               22/09/2016 - Alterado a leitura dos parametros para buscar da nova tab
    --                            segmentada por tipo de pessoa.
    --                            PRJ300 - Desconto de cheque (Odirlei-AMcom)
    -- .........................................................................*/
    
    --------->> VARIAVEIS <<--------
    -- Vari�vel de cr�ticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro        
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;    

    vr_tab_lim_desconto typ_tab_lim_desconto;
    vr_idxdscti         PLS_INTEGER;

  BEGIN
    -- Limpa a PLTABLE
    pr_tab_dados_dscchq.DELETE;

    -- Buscar valores do parametro
    pc_busca_tab_limdescont ( pr_cdcooper => pr_cdcooper    --> Codigo da cooperativa
                               ,pr_inpessoa => pr_inpessoa    --> Tipo de pessoa ( 0 - todos 1-Fisica e 2-Juridica)
                               ,pr_tab_lim_desconto => vr_tab_lim_desconto  --> Temptable com os dados do limite de desconto                                     
                               ,pr_cdcritic => vr_cdcritic    --> C�digo da cr�tica
                               ,pr_dscritic => vr_dscritic);  --> Descri��o da cr�tica                
    
    -- Se retornou alguma cr�tica
    IF TRIM(vr_dscritic) IS NOT NULL OR 
      nvl(vr_cdcritic,0) > 0 THEN
      -- Levanta exce��o
      RAISE vr_exc_erro;
    END IF;

    IF vr_tab_lim_desconto.exists(pr_inpessoa) THEN

      vr_idxdscti := pr_tab_dados_dscchq.COUNT() + 1;
      pr_tab_dados_dscchq(vr_idxdscti).vllimite := vr_tab_lim_desconto(pr_inpessoa).vllimite;
      pr_tab_dados_dscchq(vr_idxdscti).qtdiavig := vr_tab_lim_desconto(pr_inpessoa).qtdiavig;
      pr_tab_dados_dscchq(vr_idxdscti).qtprzmin := vr_tab_lim_desconto(pr_inpessoa).qtprzmin;
      pr_tab_dados_dscchq(vr_idxdscti).qtprzmax := vr_tab_lim_desconto(pr_inpessoa).qtprzmax;
      pr_tab_dados_dscchq(vr_idxdscti).pcdmulta := vr_tab_lim_desconto(pr_inpessoa).txdmulta;
      pr_tab_dados_dscchq(vr_idxdscti).vlconchq := vr_tab_lim_desconto(pr_inpessoa).vlconchq;
      pr_tab_dados_dscchq(vr_idxdscti).vlmaxemi := vr_tab_lim_desconto(pr_inpessoa).vlmaxemi;
      pr_tab_dados_dscchq(vr_idxdscti).pcchqloc := vr_tab_lim_desconto(pr_inpessoa).pcchqloc;
      pr_tab_dados_dscchq(vr_idxdscti).pcchqemi := vr_tab_lim_desconto(pr_inpessoa).pcchqemi;
      pr_tab_dados_dscchq(vr_idxdscti).qtdiasoc := vr_tab_lim_desconto(pr_inpessoa).qtdiasoc;
      pr_tab_dados_dscchq(vr_idxdscti).qtdevchq := vr_tab_lim_desconto(pr_inpessoa).qtdevchq;
      pr_tab_dados_dscchq(vr_idxdscti).pctolera := vr_tab_lim_desconto(pr_inpessoa).pctollim;

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
  PROCEDURE pc_busca_restricoes(pr_cdcooper IN crapabc.cdcooper%TYPE  --> C�digo da Cooperativa
                               ,pr_nrborder IN crapabc.nrborder%TYPE  --> numero do bordero
                               ,pr_cdcmpchq IN crapabc.cdcmpchq%TYPE  --> Codigo da compensacao impressa no cheque acolhido
                               ,pr_cdbanchq IN crapabc.cdbanchq%TYPE  --> Codigo do banco impresso no cheque acolhido
                               ,pr_cdagechq IN crapabc.cdagechq%TYPE  --> Codigo da agencia impressa no cheque acolhido
                               ,pr_nrctachq IN crapabc.nrctachq%TYPE  --> Numero da conta do cheque acolhido
                               ,pr_nrcheque IN crapabc.nrcheque%TYPE  --> Numero do cheque capturado
                               ,pr_tprestri IN INTEGER                --> Tipo de restricao
                               --------> OUT <--------                                   
                               ,pr_tab_bordero_restri IN OUT NOCOPY DSCT0002.typ_tab_bordero_restri --> retorna restricoes do cheques do bordero
                               ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                               ,pr_dscritic OUT VARCHAR2) IS          --> Descri��o da cr�tica
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
    --   Altera��o : 30/08/2016 - Conversao Progress -> Oracle (Jaison/Daniel)
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
    -- Vari�vel de cr�ticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
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
  PROCEDURE pc_busca_dados_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE  --> C�digo da Cooperativa
                                  ,pr_cdagenci IN crapage.cdagenci%TYPE  --> C�digo da agencia
                                  ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                  ,pr_cdoperad IN crapope.cdoperad%TYPE  --> C�digo do Operador
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                  ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                  ,pr_cddopcao IN VARCHAR2               --> Cod opcao
                                  --------> OUT <--------                                   
                                  ,pr_tab_dados_border OUT DSCT0002.typ_tab_dados_border --> retorna dados do bordero
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2) IS          --> Descri��o da cr�tica
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
    --   Altera��o : 29/08/2016 - Conversao Progress -> Oracle (Jaison/Daniel)
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
    -- Vari�vel de cr�ticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
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
        vr_dscritic := 'O bordero deve estar na situacao EM ESTUDO ou ANALISE.';
        RAISE vr_exc_erro;
      END IF;
    ELSIF pr_cddopcao = 'L' THEN
      IF rw_crapbdc.insitbdc <> 2 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'O bordero deve estar na situacao ANALISE.';
        RAISE vr_exc_erro;
      END IF;
    ELSIF pr_cddopcao = 'I' THEN
      IF rw_crapbdc.insitbdc = 1 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'O bordero deve estar na situacao ANALISE ou LIBERADO.';
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
      vr_dscritic := 'O lote do bordero nao est� fechado.';
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
  PROCEDURE pc_busca_cheques_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE  --> C�digo da Cooperativa
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data atual
                                    ,pr_nrborder IN crapbdc.nrborder%TYPE  --> numero do bordero
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                    --------> OUT <--------                                   
                                    ,pr_tab_chq_bordero     OUT DSCT0002.typ_tab_chq_bordero    --> retorna cheques do bordero
                                    ,pr_tab_bordero_restri  OUT DSCT0002.typ_tab_bordero_restri --> retorna restricoes do cheques do bordero
                                    ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                    ,pr_dscritic OUT VARCHAR2) IS          --> Descri��o da cr�tica
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
    --   Altera��o : 30/08/2016 - Conversao Progress -> Oracle (Jaison/Daniel)
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
             cdb.nrcpfcgc,
						 cdb.insitana
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
    
    --> Buscar cadastro do cooperado emitente
    CURSOR cr_crapass (pr_cdagectl crapcop.cdagectl%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT ass.inpessoa
            ,ass.nrcpfcgc
            ,ass.nmprimtl
        FROM crapass ass
            ,crapcop cop
       WHERE cop.cdagectl = pr_cdagectl
         AND ass.cdcooper = cop.cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass  cr_crapass%ROWTYPE;
--> Buscar cadastro do cooperado emitente
    CURSOR cr_crapass_2 (pr_cdagectl crapcop.cdagectl%TYPE,
                         pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT ass.inpessoa
            ,ass.nrcpfcgc
            ,ass.nmprimtl
        FROM crapass ass
            ,crapcop cop
       WHERE cop.cdagectl = pr_cdagectl
         AND ass.cdcooper = cop.cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass_2  cr_crapass_2%ROWTYPE;
  
    --> Buscar primeiro titular da conta
    CURSOR cr_crapttl (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ttl.nmtalttl
            ,ttl.nrcpfcgc
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = 1;
    rw_crapttl  cr_crapttl%ROWTYPE;
    
    --> Busca pessoa juridica
    CURSOR cr_crapjur (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT jur.nmtalttl
        FROM crapjur jur
       WHERE jur.cdcooper = pr_cdcooper
         AND jur.nrdconta = pr_nrdconta;
    rw_crapjur  cr_crapjur%ROWTYPE;
    
    ----------->>> VARIAVEIS <<<--------   
    -- Vari�vel de cr�ticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    
    vr_idxchequ        PLS_INTEGER;
    vr_blnfound        BOOLEAN;
    vr_rel_dscpfcgc    VARCHAR2(200);
    vr_rel_nmcheque    VARCHAR2(200);
		vr_stsnrcal        BOOLEAN;
		vr_inpessoa        NUMBER;
    
  BEGIN
    -- Limpa a PLTABLE
    pr_tab_chq_bordero.DELETE;
    pr_tab_bordero_restri.DELETE;

    --> Cheques contidos no bordero
    FOR rw_crapcdb IN cr_crapcdb LOOP
      -- Se for do sistema CECRED
      -- Se for do sistema CECRED
      IF rw_crapcdb.cdbanchq = 85 THEN
        -- Buscar cadastro do cooperado emitente
        OPEN cr_crapass_2 (pr_cdagectl => rw_crapcdb.cdagechq
                        ,pr_nrdconta => rw_crapcdb.nrctachq);
        FETCH cr_crapass_2 INTO rw_crapass_2;
        vr_blnfound := cr_crapass_2%FOUND;
        CLOSE cr_crapass_2;
        -- Se NAO encontrar
        IF vr_blnfound THEN
          -- Pessoa F�sica
          IF rw_crapass_2.inpessoa = 1 THEN
            OPEN cr_crapttl (pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => rw_crapcdb.nrctachq);
            FETCH cr_crapttl INTO rw_crapttl;
            vr_blnfound := cr_crapttl%FOUND;
            CLOSE cr_crapttl;
            -- Se NAO encontrar
            IF vr_blnfound THEN
              vr_rel_nmcheque := rw_crapttl.nmtalttl;
              vr_rel_dscpfcgc := GENE0002.fn_mask_cpf_cnpj(pr_nrcpfcgc =>rw_crapttl.nrcpfcgc,
                                                           pr_inpessoa => 1);
            ELSE
              vr_rel_dscpfcgc := 'NAO CADASTRADO';
              vr_rel_nmcheque := 'NAO CADASTRADO';
            END IF;
          ELSE -- Pessoa Juridica
            OPEN cr_crapjur (pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => rw_crapcdb.nrctachq);
            FETCH cr_crapjur INTO rw_crapjur;
            vr_blnfound := cr_crapjur%FOUND;
            CLOSE cr_crapjur;
            -- Se NAO encontrar
            IF vr_blnfound THEN
              vr_rel_nmcheque := rw_crapjur.nmtalttl;
              vr_rel_dscpfcgc := GENE0002.fn_mask_cpf_cnpj(pr_nrcpfcgc =>rw_crapass_2.nrcpfcgc,
                                                           pr_inpessoa => 2);
            ELSE
              vr_rel_dscpfcgc := 'NAO CADASTRADO';
              vr_rel_nmcheque := 'NAO CADASTRADO';
            END IF;
          END IF;
        END IF;
      ELSE
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
          -- Validar CPF/CNPJ
          gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => rw_crapcec.nrcpfcgc, 
                                      pr_stsnrcal => vr_stsnrcal, 
                                      pr_inpessoa => vr_inpessoa);
  			
          vr_rel_dscpfcgc := GENE0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapcec.nrcpfcgc,
                                                       pr_inpessoa => vr_inpessoa);
          vr_rel_nmcheque := (CASE WHEN NVL(rw_crapcec.nrdconta,0) > 0 THEN '(' || TRIM(GENE0002.fn_mask_conta(rw_crapcec.nrdconta)) || ')' ELSE '' END)
                          || rw_crapcec.nmcheque;
        END IF;
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
			pr_tab_chq_bordero(vr_idxchequ).insitana := rw_crapcdb.insitana;

      -->  Buscar restricoes de um determinado bordero ou cheque  
      pc_busca_restricoes(pr_cdcooper => pr_cdcooper          --> C�digo da Cooperativa
                         ,pr_nrborder => pr_nrborder          --> numero do bordero
                         ,pr_cdcmpchq => rw_crapcdb.cdcmpchq  --> Codigo da compensacao impressa no cheque acolhido
                         ,pr_cdbanchq => rw_crapcdb.cdbanchq  --> Codigo do banco impresso no cheque acolhido
                         ,pr_cdagechq => rw_crapcdb.cdagechq  --> Codigo da agencia impressa no cheque acolhido
                         ,pr_nrctachq => rw_crapcdb.nrctachq  --> Numero da conta do cheque acolhido
                         ,pr_nrcheque => rw_crapcdb.nrcheque  --> Numero do cheque capturado
                         ,pr_tprestri => 1                    --> Tipo de restricao
                         --------> OUT <--------                                   
                         ,pr_tab_bordero_restri => pr_tab_bordero_restri --> retorna restricoes do cheques do bordero
                         ,pr_cdcritic           => vr_cdcritic           --> C�digo da cr�tica
                         ,pr_dscritic           => vr_dscritic);         --> Descri��o da cr�tica
      IF nvl(vr_cdcritic,0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN 
        RAISE vr_exc_erro; 
      END IF;

    END LOOP;

    -- Restricoes GERAIS
    pc_busca_restricoes(pr_cdcooper => pr_cdcooper  --> C�digo da Cooperativa
                       ,pr_nrborder => pr_nrborder  --> numero do bordero
                       ,pr_cdcmpchq => 888          --> Codigo da compensacao impressa no cheque acolhido
                       ,pr_cdbanchq => 888          --> Codigo do banco impresso no cheque acolhido
                       ,pr_cdagechq => 8888         --> Codigo da agencia impressa no cheque acolhido
                       ,pr_nrctachq => 8888888888   --> Numero da conta do cheque acolhido
                       ,pr_nrcheque => 888888       --> Numero do cheque capturado
                       ,pr_tprestri => 2            --> Tipo de restricao
                       --------> OUT <--------                                   
                       ,pr_tab_bordero_restri => pr_tab_bordero_restri --> retorna restricoes do cheques do bordero
                       ,pr_cdcritic           => vr_cdcritic           --> C�digo da cr�tica
                       ,pr_dscritic           => vr_dscritic);         --> Descri��o da cr�tica
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
  PROCEDURE pc_carrega_dados_bordero_chq(pr_cdcooper IN crapcop.cdcooper%TYPE  --> C�digo da Cooperativa
                                        ,pr_cdagenci IN crapage.cdagenci%TYPE  --> C�digo da agencia
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
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
                                        ,pr_cdcritic                OUT PLS_INTEGER  --> C�digo da cr�tica
                                        ,pr_dscritic                OUT VARCHAR2) IS --> Descri��o da cr�tica
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
    --   Altera��o : 31/08/2016 - Conversao Progress -> Oracle (Jaison/Daniel)
    -- .........................................................................*/
    
    ---------->>> CURSORES <<<----------
    
    ----------->>> VARIAVEIS <<<--------   
    -- Vari�vel de cr�ticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
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
    pc_busca_cheques_bordero(pr_cdcooper => pr_cdcooper  --> C�digo da Cooperativa
                            ,pr_dtmvtolt => pr_dtmvtolt  --> Data atual
                            ,pr_nrborder => pr_nrborder  --> numero do bordero
                            ,pr_nrdconta => pr_nrdconta  --> N�mero da Conta
                            --------> OUT <--------                                   
                            ,pr_tab_chq_bordero    => pr_tab_chq_bordero    --> retorna titulos do bordero
                            ,pr_tab_bordero_restri => pr_tab_bordero_restri --> retorna restri��es do cheques do bordero
                            ,pr_cdcritic           => vr_cdcritic           --> C�digo da cr�tica
                            ,pr_dscritic           => vr_dscritic);         --> Descri��o da cr�tica

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
  PROCEDURE pc_dados_nota_promissoria(pr_cdcooper IN crapcop.cdcooper%TYPE    --> C�digo da Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE    --> C�digo da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE    --> Numero do caixa do operador
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE    --> C�digo do Operador
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
    --   Altera��o : 22/08/2016 - Conversao Progress -> Oracle (Jaison/Daniel)
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
    -- Vari�vel de cr�ticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
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
                      || ' DIAS DO M�S DE ';
    ELSE
      vr_rel_dsmvtolt := 'PRIMEIRO DIA DO M�S DE ';
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
      vr_rel_nmcidpac := 'Pag�vel em ____________________';
    ELSE
      vr_rel_nmcidpac := 'Pag�vel em ' || rw_crapage.nmcidade;
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
  PROCEDURE pc_gera_impressao_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE  --> C�digo da Cooperativa
                                     ,pr_cdagecxa IN crapage.cdagenci%TYPE  --> C�digo da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdopecxa IN crapope.cdoperad%TYPE  --> C�digo do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
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
                                     ,pr_flgrestr IN INTEGER DEFAULT 1      --> Indicador se deve imprimir restricoes(0-nao, 1-sim)
                                     --------> OUT <--------                                   
                                     ,pr_nmarqpdf OUT VARCHAR2              --> Retornar nome do relatorio PDF
                                     ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2) IS          --> Descri��o da cr�tica
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
    --   Altera��o : 06/09/2016 - Conversao Progress -> Oracle (Jaison/Daniel)
    --
    --               23/11/2016 - Tratamento na montagem do XML para alterar caracteres
    --                            nao permitidos no XML(ex. &). (Odirlei-AMcom) 
    --               
    --               22/12/2016 - Alteracao no relatorio de desconto de cheque.
    --                            Projeto 300 (Lombardi)
    --               
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
    
    -- Linha de Desconto
    CURSOR cr_crapldc (pr_cddlinha IN crapldc.cddlinha%TYPE) IS
      SELECT cddlinha
            ,dsdlinha
        FROM crapldc
       WHERE cdcooper = pr_cdcooper
         AND tpdescto = 2
         AND cddlinha = pr_cddlinha;
    rw_crapldc cr_crapldc%ROWTYPE;

    -- Cursor Cadastro de Aditivos Contratuais
    CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE
                     ,pr_nrdconta IN craplim.nrdconta%TYPE
                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE) IS
      SELECT lim.nrdconta
            ,lim.qtrenova
            ,lim.vllimite
            ,NVL(ass.inpessoa,0) inpessoa
            ,lim.nrctrlim
            ,lim.cddlinha
            ,lim.dtinivig
            ,lim.qtdiavig
       FROM craplim lim
           ,crapass ass
      WHERE lim.cdcooper = pr_cdcooper
        AND lim.nrdconta = pr_nrdconta
        AND lim.tpctrlim = 2 -- Desconto de Cheque             
        AND lim.nrctrlim = pr_nrctrlim
        AND ass.cdcooper (+) = lim.cdcooper
        AND ass.nrdconta (+) = lim.nrdconta;
    rw_craplim cr_craplim%ROWTYPE;

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
    -- Vari�vel de cr�ticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
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

    
    vr_lstarifa VARCHAR2(100);
    vr_cdhistor craphis.cdhistor%TYPE;
    vr_cdhisest craphis.cdhistor%TYPE;
    vr_dtdivulg DATE;
    vr_dtvigenc DATE;
    vr_cdfvlcop crapfco.cdfvlcop%TYPE;
    vr_vltarifa crapfco.vltarifa%TYPE;
    vr_vltarbor crapfco.vltarifa%TYPE;
    vr_vltarcus crapfco.vltarifa%TYPE;
    vr_vltarctr crapfco.vltarifa%TYPE;
    vr_cdbattar VARCHAR2(10);
    vr_qtacobra INTEGER;
    vr_fliseope INTEGER;
    vr_txcetano NUMBER;
    vr_txcetmes NUMBER;
    
    -- Vari�veis para armazenar as informa��es em XML
    vr_des_xml   CLOB;
    vr_txtcompl  VARCHAR2(32600);
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na vari�vel CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;

  BEGIN
    -- Limpa PLTABLE
    vr_tab_restri_apr_coo.DELETE;

    --> Definir transa��o
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
            (pr_cdcooper => pr_cdcooper  --> C�digo da Cooperativa
            ,pr_cdagenci => pr_cdagecxa  --> C�digo da agencia
            ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa do operador
            ,pr_cdoperad => pr_cdopecxa  --> C�digo do Operador
            ,pr_nmdatela => pr_nmdatela  --> Nome da Tela
            ,pr_idorigem => pr_idorigem  --> Identificador de Origem
            ,pr_tpctrlim => 2            --> Tipo de contrato de limite(2-Cheque e 3-Titulo)
            ,pr_nrdconta => pr_nrdconta  --> N�mero da Conta
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

    --> Buscar identificador para digitaliza��o
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

      vr_dstitulo := 'BORDER� DE DESCONTO DE CHEQUES E TERMO DE CUST�DIA';
      vr_dsmvtolt := vr_tab_dados_itens_bordero(vr_idxborde).nmcidade ||', '|| GENE0005.fn_data_extenso(pr_dtmvtolt);
      
      --Incluir no QRcode a agencia onde foi criado o contrato.
      IF nvl(rw_crapbdc.cdageori,0) = 0 THEN
        vr_cdageqrc := vr_tab_dados_itens_bordero(vr_idxborde).cdagenci;
      ELSE
        vr_cdageqrc := rw_crapbdc.cdageori;
      END IF;
      
      -- Busca Linha de Desconto
      OPEN cr_crapldc (rw_crapbdc.cddlinha);
      FETCH cr_crapldc INTO rw_crapldc;
      IF cr_crapldc%NOTFOUND THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Linha de desconto n�o encontrada.';
        RAISE vr_exc_erro;
      END IF;
      
      -- Tarifas
      OPEN cr_craplim(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctrlim => rw_crapbdc.nrctrlim);
      FETCH cr_craplim INTO rw_craplim;
      
      IF cr_craplim%NOTFOUND THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Contrato de Limite de credito n�o encontrado.';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_craplim;
      
      -- Se n�o encontrou associado
      IF rw_craplim.inpessoa = 0 THEN
        vr_cdcritic:= 9; 
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic)||
                      gene0002.fn_mask(rw_craplim.nrdconta,'zzzz.zzz.9');
        RAISE vr_exc_erro;
      END IF;
      
      FOR ind IN 1..3 LOOP
        -- Pessoa Fisica
        IF rw_craplim.inpessoa = 1 THEN
          IF ind = 1 THEN
            vr_cdbattar := 'DSCCHQBOPF';
          ELSIF ind = 2 THEN
            vr_cdbattar := 'CUSTDCTOPF';
          ELSIF ind = 3 THEN
            vr_cdbattar := 'DSCCHQCTPF';
          END IF;
        ELSE -- Pessoa Juridica
          IF ind = 1 THEN
            vr_cdbattar := 'DSCCHQBOPJ';
          ELSIF ind = 2 THEN
            vr_cdbattar := 'CUSTDCTOPJ';
          ELSIF ind = 3 THEN
            vr_cdbattar := 'DSCCHQCTPJ';
          END IF;
        END IF;

        -- Busca valor da tarifa
        TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper
                                             ,pr_cdbattar => vr_cdbattar
                                             ,pr_vllanmto => rw_craplim.vllimite
                                             ,pr_cdprogra => 'DSCC0001'
                                             ,pr_cdhistor => vr_cdhistor
                                             ,pr_cdhisest => vr_cdhisest
                                             ,pr_vltarifa => vr_vltarifa
                                             ,pr_dtdivulg => vr_dtdivulg
                                             ,pr_dtvigenc => vr_dtvigenc
                                             ,pr_cdfvlcop => vr_cdfvlcop
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic
                                             ,pr_tab_erro => vr_tab_erro);
                                                            
        -- Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- Se possui erro no vetor
          IF vr_tab_erro.Count() > 0 THEN
            vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic:= 0;
            vr_dscritic:= 'Nao foi possivel carregar a tarifa.';
          END IF;
          RAISE vr_exc_erro;
        END IF;
        
        IF ind = 1 THEN
          vr_vltarbor := vr_vltarifa;
        ELSIF ind = 2 THEN
          vr_vltarcus := vr_vltarifa;
        ELSIF ind = 3 THEN
          vr_vltarctr := vr_vltarifa;
        END IF;
        
      END LOOP;
      
      -- Chamar rorina para calcular o cet
      CCET0001.pc_calculo_cet_limites(pr_cdcooper => pr_cdcooper
                                     ,pr_dtmvtolt => pr_dtmvtolt
                                     ,pr_cdprogra => 'DSCC0001'
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_inpessoa => rw_craplim.inpessoa
                                     ,pr_cdusolcr => 1
                                     ,pr_cdlcremp => rw_craplim.cddlinha
                                     ,pr_tpctrlim => 2
                                     ,pr_nrctrlim => rw_craplim.nrctrlim
                                     ,pr_dtinivig => rw_craplim.dtinivig
                                     ,pr_qtdiavig => rw_craplim.qtdiavig                               
                                     ,pr_vlemprst => rw_craplim.vllimite
                                     ,pr_txmensal => rw_crapbdc.txmensal
                                     ,pr_txcetano => vr_txcetano
                                     ,pr_txcetmes => vr_txcetmes
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
                                     
      IF nvl(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
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
                         '<taxadcet>'||vr_txcetmes||'</taxadcet>'||
                         '<vltarctr>'|| TO_CHAR(vr_vltarctr,'fm999G999G999G990D00')||'</vltarctr>'||
                         '<vltarbor>'|| TO_CHAR(vr_vltarbor,'fm999G999G999G990D00')||'</vltarbor>'||
                         '<vltarcus>'|| TO_CHAR(vr_vltarcus,'fm999G999G999G990D00')||'</vltarcus>'||
                         '<dsperiod>'||'MENSAL'||'</dsperiod>'||
                         '<cddlinha>'|| rw_crapldc.cddlinha ||'</cddlinha>'||
                         '<dsdlinha>'|| rw_crapldc.dsdlinha ||'</dsdlinha>'||
                         '<tpctrlim>2</tpctrlim>'||
                         '<nmextcop>'|| vr_tab_dados_itens_bordero(vr_idxborde).nmextcop ||'</nmextcop>'||
                         '<dstitulo>'|| vr_dstitulo ||'</dstitulo>'||
                         '<dsqrcode>'|| vr_qrcode ||'</dsqrcode>'||
                         '<nrdconta>'|| TRIM(GENE0002.fn_mask_conta(pr_nrdconta)) ||'</nrdconta>'||
                         '<nmprimtl>'|| gene0007.fn_caract_controle(vr_tab_dados_itens_bordero(vr_idxborde).nmprimtl) ||'</nmprimtl>'||
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
                         '<idorigem>'|| pr_idorigem ||'</idorigem>'||
                         '<cheques>');

      FOR idx IN vr_tab_chq_bordero.FIRST..vr_tab_chq_bordero.LAST LOOP
        -- se o border� estiver liberado e o cheque estiver aprovado ou
        -- se o border� estiver em estudo ou an�lise.
        IF rw_crapbdc.insitbdc >= 3 AND vr_tab_chq_bordero(idx).insitana = 1 OR
           rw_crapbdc.insitbdc < 3 THEN
           
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
                                 '<nmcheque>'|| gene0007.fn_caract_controle(SUBSTR(vr_tab_chq_bordero(idx).nmcheque,0,23)) ||'</nmcheque>'||
                                 '<dscpfcgc>'|| vr_tab_chq_bordero(idx).dscpfcgc ||'</dscpfcgc>'||
                                 '<restricoes>');
          IF pr_idorigem <> 3 AND pr_flgrestr = 1 THEN
            -- Percorre as restricoes
            IF vr_tab_bordero_restri.COUNT > 0 THEN
              FOR idx2 IN vr_tab_bordero_restri.FIRST..vr_tab_bordero_restri.LAST LOOP
                -- Se for restricao do cheque em questao
                IF vr_tab_bordero_restri(idx2).nrcheque = vr_tab_chq_bordero(idx).nrcheque THEN
                  -- Seta o total
                  vr_qtrestri := NVL(vr_qtrestri, 0) + 1;

                  pc_escreve_xml(          '<restricao><texto>'|| gene0007.fn_caract_controle(vr_tab_bordero_restri(idx2).dsrestri) ||'</texto></restricao>');
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
          END IF;
          pc_escreve_xml(        '</restricoes>');
          pc_escreve_xml(      '</cheque>');
        END IF;
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
      IF pr_idorigem <> 3 AND pr_flgrestr = 1 THEN
      -- Se possui restricoes aprovadas pelo coordenador
      IF vr_tab_restri_apr_coo.COUNT > 0 THEN
         pc_escreve_xml(  '<restricoes_coord dsopecoo="'|| TRIM(vr_tab_dados_itens_bordero(vr_idxborde).dsopecoo) ||'">');
        vr_idxrestr := vr_tab_restri_apr_coo.FIRST;
        WHILE vr_idxrestr IS NOT NULL LOOP
          pc_escreve_xml(    '<restricao><texto>'|| gene0007.fn_caract_controle(vr_idxrestr) ||'</texto></restricao>');
          vr_idxrestr := vr_tab_restri_apr_coo.NEXT(vr_idxrestr);
        END LOOP;
        pc_escreve_xml(  '</restricoes_coord>');
      END IF;
      
      pc_escreve_xml(  '<restricoes_gerais>');
      -- Percorre as restricoes gerais
      IF vr_tab_bordero_restri.COUNT > 0 THEN
        FOR idx2 IN vr_tab_bordero_restri.FIRST..vr_tab_bordero_restri.LAST LOOP
          IF vr_tab_bordero_restri(idx2).nrcheque = 888888 THEN
            pc_escreve_xml(          '<restricao><texto>'|| gene0007.fn_caract_controle(vr_tab_bordero_restri(idx2).dsrestri) ||'</texto></restricao>');
          END IF;
        END LOOP;
      END IF;
      pc_escreve_xml(  '</restricoes_gerais>');
      END IF;
      pc_escreve_xml( '</Bordero></raiz>',TRUE);

      --> Solicita geracao do PDF
      GENE0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                                 , pr_cdprogra  => 'ATENDA'
                                 , pr_dtmvtolt  => pr_dtmvtolt
                                 , pr_dsxml     => vr_des_xml
                                 , pr_dsxmlnode => '/raiz/Bordero'
                                 , pr_dsjasper  => 'crrl519_bordero_cheques.jasper'
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

      ELSIF pr_idorigem = 3 THEN
        
        GENE0002.pc_efetua_copia_arq_ib(pr_cdcooper => pr_cdcooper
                                       ,pr_nmarqpdf => vr_dsdireto ||'/'|| pr_nmarqpdf
                                       ,pr_des_erro => vr_dscritic);
        -- Testar se houve erro
        IF vr_dscritic IS NOT NULL THEN
          vr_cdcritic := 0;
          -- Gerar excecao
          RAISE vr_exc_erro;
        END IF;

        -- Remove o arquivo XML fisico de envio
        GENE0001.pc_OScommand (pr_typ_comando => 'S'
                              ,pr_des_comando => 'rm '||vr_dsdireto || '/' || vr_nmarquiv||' 2> /dev/null'
                              ,pr_typ_saida   => vr_des_reto
                              ,pr_des_saida   => vr_dscritic);
        -- Se ocorreu erro dar RAISE
        IF vr_des_reto = 'ERR' THEN
          vr_cdcritic := 0;
          RAISE vr_exc_erro;
        END IF;

      END IF; -- pr_idorigem

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
  PROCEDURE pc_gera_impressao(pr_nrdconta   IN crapass.nrdconta%TYPE --> N�mero da Conta
                             ,pr_idseqttl   IN crapttl.idseqttl%TYPE --> Titular da Conta
                             ,pr_idimpres   IN INTEGER               --> Indicador de impressao
                             ,pr_tpctrlim   IN craplim.tpctrlim%TYPE --> Tipo de contrato de limite(2-Cheque e 3-Titulo)
                             ,pr_nrctrlim   IN craplim.nrctrlim%TYPE --> Contrato
                             ,pr_nrborder   IN crapbdc.nrborder%TYPE --> Numero do bordero
                             ,pr_dsiduser   IN VARCHAR2              --> Descricao do id do usuario
                             ,pr_flgemail   IN INTEGER               --> Indicador de envia por email (0-nao, 1-sim)
                             ,pr_flgerlog   IN INTEGER               --> Indicador se deve gerar log(0-nao, 1-sim)
                             ,pr_flgrestr   IN INTEGER               --> Indicador se deve imprimir restricoes(0-nao, 1-sim)
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
                                             pr_flgrestr => pr_flgrestr,
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

  -- Procedure para buscar cheques em custodia para desconto
  PROCEDURE pc_busca_cheques_dsc_cst(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
		                                ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Conta
																		,pr_cdagenci IN crapage.cdagenci%TYPE  --> C�digo da agencia
																		,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
																		,pr_cdoperad IN crapope.cdoperad%TYPE  --> C�digo do Operador
																		,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> data do movimento 
																		,pr_idorigem IN INTEGER                --> Identificador de Origem
		                                ,pr_nriniseq IN NUMBER                --> Pagina��o - Inicio de sequencia
																		,pr_nrregist IN NUMBER                --> Pagina��o - N�mero de registros
																		,pr_qtregist OUT NUMBER
		                                ,pr_tab_cstdsc OUT typ_tab_cstdsc      --> PlTable com dados dos cheques
																		,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
																		,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
  /* .............................................................................

    Programa: pc_busca_cheques_dsc_cst
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Outubro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar cheques em custodia para desconto

    Alteracoes: -----
  ..............................................................................*/
		--------->> VARIAVEIS <<--------
		-- Variaveis de cr�ticas
		vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
		vr_dscritic        VARCHAR2(1000);        --> Desc. Erro        
		-- Tratamento de erros
		vr_exc_erro        EXCEPTION;    
		
		-- Vari�veis auxiliares
		vr_tab_dados_dscchq DSCT0002.typ_tab_dados_dscchq;
		vr_tab_cstdsc typ_tab_cstdsc;
		vr_idx_cstdsc INTEGER;
		vr_dtinilib   DATE; -- Data �nicio do prazo de libera��o
		vr_dtfimlib   DATE; -- Data fim do prazo de libera��o
		vr_qtregist   NUMBER := 0;
		vr_nmcheque   VARCHAR2(200);
    vr_nrcpfcgc   INTEGER;
    vr_blnfound   BOOLEAN;
    
		-- Cheques em custodia para desconto
		CURSOR cr_cstdsc (pr_cdcooper IN crapcop.cdcooper%TYPE
										 ,pr_nrdconta IN crapass.nrdconta%TYPE
										 ,pr_dtinilib IN DATE
										 ,pr_dtfimlib IN DATE) IS
			SELECT x.* 
			  FROM (SELECT tt.*, 
				(SELECT cec.nmcheque 
					FROM crapcec cec 
				 WHERE cec.cdcooper = tt.cdcooper
					 AND cec.cdcmpchq = tt.cdcmpchq
					 AND cec.cdbanchq = tt.cdbanchq
					 AND cec.cdagechq = tt.cdagechq
					 AND cec.nrctachq = tt.nrctachq
					 AND cec.nrdconta = 0) nmcheque,		     
				(SELECT cec.nrcpfcgc
					FROM crapcec cec 
				 WHERE cec.cdcooper = tt.cdcooper
					 AND cec.cdcmpchq = tt.cdcmpchq
					 AND cec.cdbanchq = tt.cdbanchq
					 AND cec.cdagechq = tt.cdagechq
					 AND cec.nrctachq = tt.nrctachq
					 AND cec.nrdconta = 0) nrcpfcgc,
				  rownum rnum,
					COUNT(*) over() qtregist
			 FROM (
			SELECT 'CST' dstipchq
						,cst.cdcooper
						,cst.dtmvtolt
						,cst.dtmvtolt dtcustod
						,cst.dtlibera
						,cst.cdcmpchq
						,cst.cdbanchq
						,cst.cdagechq
						,cst.nrctachq
						,cst.nrcheque
						,cst.vlcheque
						,1 inconcil
						,nvl(cst.dtemissa, cst.dtmvtolt) dtdcaptu
						,cst.dsdocmc7
						,dcc.nrremret
			 FROM crapcst cst
           ,crapdcc dcc
			WHERE cst.cdcooper = pr_cdcooper
				AND cst.nrdconta = pr_nrdconta
        AND cst.insitchq <> 1
				AND cst.dtlibera BETWEEN pr_dtinilib AND pr_dtfimlib
				AND cst.nrborder = 0
        AND dcc.cdcooper = cst.cdcooper
        AND dcc.nrdconta = cst.nrdconta
        AND dcc.intipmvt IN (1,3)
        AND dcc.dtlibera BETWEEN pr_dtinilib AND pr_dtfimlib
        AND dcc.cdcmpchq = cst.cdcmpchq
        AND dcc.cdbanchq = cst.cdbanchq
        AND dcc.cdagechq = cst.cdagechq
        AND dcc.nrctachq = cst.nrctachq
        AND dcc.nrcheque = cst.nrcheque
        AND dcc.nrborder = cst.nrborder
			UNION
			SELECT 'DCC' dstipchq
						,hcc.cdcooper
						,hcc.dtmvtolt
						,hcc.dtcustod
						,dcc.dtlibera
						,dcc.cdcmpchq
						,dcc.cdbanchq
						,dcc.cdagechq
						,dcc.nrctachq
						,dcc.nrcheque
						,dcc.vlcheque
						,dcc.inconcil
						,dcc.dtdcaptu dtdcaptu
						,dcc.dsdocmc7
						,dcc.nrremret
			 FROM crapdcc dcc, craphcc hcc
			WHERE dcc.cdcooper = pr_cdcooper
				AND dcc.nrdconta = pr_nrdconta
				AND dcc.dtlibera BETWEEN pr_dtinilib AND pr_dtfimlib
				AND dcc.nrborder = 0
				AND dcc.nrconven = 1
				AND dcc.intipmvt IN (1,3)
				AND dcc.cdtipmvt = 1
				AND trim(dcc.cdocorre) IS NULL
				AND hcc.cdcooper = dcc.cdcooper
				AND hcc.nrdconta = dcc.nrdconta
				AND hcc.nrremret = dcc.nrremret
				AND hcc.intipmvt = dcc.intipmvt
				AND hcc.dtcustod IS NULL ) tt) x
			WHERE rnum >= pr_nriniseq
			  AND rnum < (pr_nriniseq + pr_nrregist);
	
	  -- Busca cooperado
	  CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE
		                  ,pr_nrdconta IN crapass.cdcooper%TYPE) IS
			SELECT ass.inpessoa
			  FROM crapass ass
			 WHERE ass.cdcooper = pr_cdcooper
			   AND ass.nrdconta = pr_nrdconta;
	  rw_crapass cr_crapass%ROWTYPE;
		
    --> Buscar cadastro do cooperado emitente
    CURSOR cr_crapass_2 (pr_cdagectl crapcop.cdagectl%TYPE,
                         pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT ass.inpessoa
            ,ass.nrcpfcgc
            ,ass.nmprimtl
        FROM crapass ass
            ,crapcop cop
       WHERE cop.cdagectl = pr_cdagectl
         AND ass.cdcooper = cop.cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass_2  cr_crapass_2%ROWTYPE;
  
    --> Buscar primeiro titular da conta
    CURSOR cr_crapttl (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ttl.nmtalttl
            ,ttl.nrcpfcgc
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = 1;
    rw_crapttl  cr_crapttl%ROWTYPE;
    
    --> Busca pessoa juridica
    CURSOR cr_crapjur (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT jur.nmtalttl
        FROM crapjur jur
       WHERE jur.cdcooper = pr_cdcooper
         AND jur.nrdconta = pr_nrdconta;
    rw_crapjur  cr_crapjur%ROWTYPE;
    
		-- Cursor da data
		rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

	BEGIN

		-- Busca a data do sistema
		OPEN  BTCH0001.cr_crapdat(pr_cdcooper);
		FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
		CLOSE BTCH0001.cr_crapdat;

    OPEN cr_crapass(pr_cdcooper => pr_cdcooper
		               ,pr_nrdconta => pr_nrdconta);
		FETCH cr_crapass INTO rw_crapass;
		
		IF cr_crapass%NOTFOUND THEN
			-- Fecha cursor
			CLOSE cr_crapass;
			-- Gerar cr�tica
			vr_cdcritic := 9;
			vr_dscritic := '';
			-- Levanta exce��o
			RAISE vr_exc_erro;
		END IF;
		-- Fecha cursor
		CLOSE cr_crapass;

		--> Buscar parametros gerais de desconto de titulo - TAB052
		DSCC0001.pc_busca_parametros_dscchq (pr_cdcooper => pr_cdcooper          --> C�digo da Cooperativa                                          
																				,pr_cdagenci => pr_cdagenci          --> C�digo da agencia
																				,pr_nrdcaixa => pr_nrdcaixa          --> Numero do caixa do operador
																				,pr_cdoperad => pr_cdoperad          --> C�digo do Operador
																				,pr_dtmvtolt => pr_dtmvtolt          --> Data do movimento
																				,pr_idorigem => pr_idorigem          --> Identificador de Origem 
																				,pr_inpessoa => rw_crapass.inpessoa  --> Tipo de pessoa
                                         --------> OUT <--------          
																				,pr_tab_dados_dscchq => vr_tab_dados_dscchq  --> tabela contendo os parametros da cooperativa
																				,pr_cdcritic         => vr_cdcritic          --> C�digo da cr�tica
																				,pr_dscritic         => vr_dscritic);        --> Descri��o da cr�tica
    
		IF nvl(vr_cdcritic,0) > 0 OR 
			 TRIM(vr_dscritic) IS NOT NULL THEN
			RAISE vr_exc_erro; 
		END IF;
		
    vr_dtinilib := rw_crapdat.dtmvtolt + vr_tab_dados_dscchq(vr_tab_dados_dscchq.first).qtprzmin;
    vr_dtfimlib := rw_crapdat.dtmvtolt + vr_tab_dados_dscchq(vr_tab_dados_dscchq.first).qtprzmax;
		
	  -- Busca dados dos cheques
    FOR rw_cstdsc IN cr_cstdsc(pr_cdcooper => pr_cdcooper
															,pr_nrdconta => pr_nrdconta
															,pr_dtinilib => vr_dtinilib
															,pr_dtfimlib => vr_dtfimlib) LOOP																														
		  
      -- Se for do sistema CECRED
      IF rw_cstdsc.cdbanchq = 85 THEN
        -- Buscar cadastro do cooperado emitente
        OPEN cr_crapass_2 (pr_cdagectl => rw_cstdsc.cdagechq
                        ,pr_nrdconta => rw_cstdsc.nrctachq);
        FETCH cr_crapass_2 INTO rw_crapass_2;
        vr_blnfound := cr_crapass_2%FOUND;
        CLOSE cr_crapass_2;
        -- Se NAO encontrar
        IF vr_blnfound THEN
          -- Pessoa F�sica
          IF rw_crapass_2.inpessoa = 1 THEN
            OPEN cr_crapttl (pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => rw_cstdsc.nrctachq);
            FETCH cr_crapttl INTO rw_crapttl;
            vr_blnfound := cr_crapttl%FOUND;
            CLOSE cr_crapttl;
            -- Se NAO encontrar
            IF vr_blnfound THEN
              vr_nmcheque := rw_crapttl.nmtalttl;
              vr_nrcpfcgc := rw_crapttl.nrcpfcgc;
            END IF;
          ELSE -- Pessoa Juridica
            OPEN cr_crapjur (pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => rw_cstdsc.nrctachq);
            FETCH cr_crapjur INTO rw_crapjur;
            vr_blnfound := cr_crapjur%FOUND;
            CLOSE cr_crapjur;
            -- Se NAO encontrar
            IF vr_blnfound THEN
              vr_nmcheque := rw_crapjur.nmtalttl;
              vr_nrcpfcgc := rw_crapass_2.nrcpfcgc;
            END IF;
          END IF;
        END IF;
      ELSE
        vr_nmcheque := rw_cstdsc.nmcheque;
        vr_nrcpfcgc := rw_cstdsc.nrcpfcgc;
      END IF;
      
      -- Atribui novo valor ao indice
  		vr_idx_cstdsc	:= vr_tab_cstdsc.count + 1;
		  -- Atribui dados � PlTable
			vr_tab_cstdsc(vr_idx_cstdsc).dstipchq := rw_cstdsc.dstipchq;
			vr_tab_cstdsc(vr_idx_cstdsc).cdcooper := rw_cstdsc.cdcooper;
			vr_tab_cstdsc(vr_idx_cstdsc).dtmvtolt := rw_cstdsc.dtmvtolt;
      vr_tab_cstdsc(vr_idx_cstdsc).dtcustod := rw_cstdsc.dtcustod;
			vr_tab_cstdsc(vr_idx_cstdsc).dtlibera := rw_cstdsc.dtlibera;
			vr_tab_cstdsc(vr_idx_cstdsc).cdcmpchq := rw_cstdsc.cdcmpchq;
			vr_tab_cstdsc(vr_idx_cstdsc).cdbanchq := rw_cstdsc.cdbanchq;
			vr_tab_cstdsc(vr_idx_cstdsc).cdagechq := rw_cstdsc.cdagechq;
			vr_tab_cstdsc(vr_idx_cstdsc).nrctachq := rw_cstdsc.nrctachq;
			vr_tab_cstdsc(vr_idx_cstdsc).nrcheque := rw_cstdsc.nrcheque;
			vr_tab_cstdsc(vr_idx_cstdsc).vlcheque := rw_cstdsc.vlcheque;
			vr_tab_cstdsc(vr_idx_cstdsc).inconcil := rw_cstdsc.inconcil;
			vr_tab_cstdsc(vr_idx_cstdsc).nmcheque := vr_nmcheque;
			vr_tab_cstdsc(vr_idx_cstdsc).nrcpfcgc := vr_nrcpfcgc;
			vr_tab_cstdsc(vr_idx_cstdsc).dtdcaptu := rw_cstdsc.dtdcaptu;
			vr_tab_cstdsc(vr_idx_cstdsc).dsdocmc7 := rw_cstdsc.dsdocmc7;
			vr_tab_cstdsc(vr_idx_cstdsc).nrremret := rw_cstdsc.nrremret;
			
			IF vr_qtregist = 0 THEN
				vr_qtregist := rw_cstdsc.qtregist;
			END IF;
	  END LOOP;

    -- Atribui PlTable para parametro
		pr_tab_cstdsc := vr_tab_cstdsc;
		pr_qtregist := vr_qtregist;

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
      pr_dscritic := REPLACE(REPLACE('Nao foi possivel buscar cheques: ' || SQLERRM, chr(13)),chr(10));
	
	END pc_busca_cheques_dsc_cst;
	
  PROCEDURE pc_verifica_emitentes(pr_cdcooper IN crapcop.cdcooper%TYPE
																 ,pr_nrdconta IN crapass.nrdconta%TYPE
																 ,pr_dscheque IN VARCHAR2
																 ,pr_tab_cheques OUT typ_tab_cheques
																 ,pr_cdcritic OUT PLS_INTEGER
																 ,pr_dscritic OUT VARCHAR2) IS 
  /* .............................................................................
    Programa: pc_verifica_emitentes
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Novembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para verificar emitentes dos cheques informados para 
		            inclus�o/altera��o de border�

    Alteracoes: -----
  ..............................................................................*/
  
	-- Vari�veis auxiliares	  	
  vr_ret_cheques      gene0002.typ_split;     
  vr_tab_cheques      typ_tab_cheques;
  vr_index_cheque     NUMBER;
	vr_inemiten NUMBER;

	-- Campos do CMC7
	vr_dsdocmc7 VARCHAR2(45);
	vr_cdbanchq NUMBER; 
	vr_cdagechq NUMBER;
	vr_cdcmpchq NUMBER;
	vr_nrctachq NUMBER;
	vr_nrcheque NUMBER;
	
	-- Busca informa��es do emitente
	CURSOR cr_crapcec (pr_cdcooper IN crapcec.cdcooper%TYPE
										,pr_cdcmpchq IN crapcec.cdcmpchq%TYPE
										,pr_cdbanchq IN crapcec.cdbanchq%TYPE
										,pr_cdagechq IN crapcec.cdagechq%TYPE
										,pr_nrctachq IN crapcec.nrctachq%TYPE) IS
		SELECT cec.nrcpfcgc
					,cec.nmcheque
			FROM crapcec cec
		 WHERE cec.cdcooper = pr_cdcooper
			 AND cec.cdcmpchq = pr_cdcmpchq
			 AND cec.cdbanchq = pr_cdbanchq
			 AND cec.cdagechq = pr_cdagechq
			 AND cec.nrctachq = pr_nrctachq
			 AND cec.nrdconta = 0;
	rw_crapcec cr_crapcec%ROWTYPE;

	BEGIN
		-- Criando um Array com todos os cheques que vieram como parametro
		vr_ret_cheques := gene0002.fn_quebra_string(pr_dscheque, '|');
      			
		-- Percorre todos os cheques para process�-los
		FOR vr_auxcont IN 1..vr_ret_cheques.count LOOP
			-- Buscar o cmc7
			vr_dsdocmc7 := vr_ret_cheques(vr_auxcont);
 			-- Desmontar as informa��es do CMC-7
			-- Banco
			vr_cdbanchq := to_number(SUBSTR(vr_dsdocmc7,01,03)); 
			-- Agencia
			vr_cdagechq := to_number(SUBSTR(vr_dsdocmc7,04,04)); 
			-- Compe
			vr_cdcmpchq := to_number(SUBSTR(vr_dsdocmc7,09,03));
			-- Numero do Cheque
			vr_nrcheque := to_number(SUBSTR(vr_dsdocmc7,12,06));
			-- Conta do Cheque
			IF vr_cdbanchq = 1 THEN
				vr_nrctachq := to_number(SUBSTR(vr_dsdocmc7,22,08));   
			ELSE 
				vr_nrctachq := to_number(SUBSTR(vr_dsdocmc7,20,10)); 
			END IF;
			
			-- Verificar se possui emitente cadastrado
			OPEN cr_crapcec(pr_cdcooper => pr_cdcooper
										 ,pr_cdcmpchq => vr_cdcmpchq
										 ,pr_cdbanchq => vr_cdbanchq
										 ,pr_cdagechq => vr_cdagechq
										 ,pr_nrctachq => vr_nrctachq);
			FETCH cr_crapcec INTO rw_crapcec;
				
			-- Se n�o encontrou emitente 
			IF cr_crapcec%NOTFOUND THEN
				-- Atribui valor 0 - Emitente n�o cadastrado
				vr_inemiten := 0;
			ELSE
				vr_inemiten := 1;					
			END IF;
			
			-- Fechar cursor
			CLOSE cr_crapcec;
			
			-- Carrega as informa��es do cheque para custodiar
			vr_index_cheque := vr_tab_cheques.count + 1;  
			vr_tab_cheques(vr_index_cheque).dsdocmc7 := vr_dsdocmc7;
			vr_tab_cheques(vr_index_cheque).cdcmpchq := vr_cdcmpchq;
			vr_tab_cheques(vr_index_cheque).cdbanchq := vr_cdbanchq;
			vr_tab_cheques(vr_index_cheque).cdagechq := vr_cdagechq;
			vr_tab_cheques(vr_index_cheque).nrctachq := vr_nrctachq;
			vr_tab_cheques(vr_index_cheque).nrcheque := vr_nrcheque;
			vr_tab_cheques(vr_index_cheque).inemiten := vr_inemiten;				

    END LOOP;	
	
	  -- Retorna parametro
	  pr_tab_cheques := vr_tab_cheques;
	
	EXCEPTION    
		WHEN OTHERS THEN      
			pr_cdcritic := 0;
			pr_dscritic := REPLACE(REPLACE('Erro ao verificar emitentes: ' || SQLERRM, chr(13)),chr(10));																		
			-- Efetuar Rollback
			ROLLBACK;		
	END pc_verifica_emitentes;

	PROCEDURE pc_criar_bordero_cheques(pr_cdcooper IN crapcop.cdcooper%TYPE
																		,pr_nrdconta IN crapass.nrdconta%TYPE
																		,pr_cdagenci IN crapass.cdagenci%TYPE
																		,pr_idorigem IN PLS_INTEGER
																		,pr_cdoperad IN VARCHAR2
																		,pr_nrdolote OUT crapbdc.nrdolote%TYPE
																		,pr_nrborder OUT crapbdc.nrborder%TYPE
																		,pr_cdcritic OUT PLS_INTEGER
																		,pr_dscritic OUT VARCHAR2) IS 
  /* .............................................................................

    Programa: pc_criar_bordero_cheques
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Novembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para criar borederos de cheques para desconto

    Alteracoes: -----
  ..............................................................................*/
    --------->> VARIAVEIS <<--------
    -- Vari�vel de cr�ticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro        
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;    
		vr_des_reto        VARCHAR2(3);
	  vr_tab_erro        gene0001.typ_tab_erro;

    -- Vari�veis locais
		vr_nrdolote        NUMBER;
		vr_nrborder        NUMBER;
    vr_cdagenci        crapass.cdagenci%TYPE;
		vr_flg_criou_lot   BOOLEAN;
	
	  -- Busca registro de associado
		CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
										 ,pr_nrdconta IN crapass.cdcooper%TYPE) IS
			SELECT ass.dtdemiss
						,ass.dtelimin
						,ass.cdsitdtl
            ,ass.cdagenci
				FROM crapass ass
			 WHERE ass.cdcooper = pr_cdcooper
				 AND ass.nrdconta = pr_nrdconta;
		rw_crapass cr_crapass%ROWTYPE;
		
		-- Verificar se conta est� bloqueada ou trasnferida de n�mero
		CURSOR cr_craptrf(pr_cdcooper IN crapcop.cdcooper%TYPE
		                 ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
			SELECT trf.nrsconta
			      ,trf.insittrs
			  FROM craptrf trf
			 WHERE trf.cdcooper = pr_cdcooper
			   AND trf.nrdconta = pr_nrdconta
				 AND trf.tptransa = 1;
		rw_craptrf cr_craptrf%ROWTYPE;
										 
		rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
	
	  -- Verificar se existe contrato ativo
	  CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE
		                 ,pr_nrdconta IN craplim.nrdconta%TYPE)	IS
			SELECT lim.dtfimvig
			      ,lim.nrctrlim
						,lim.nrdconta
						,lim.cddlinha
            ,lim.insitblq
				FROM craplim lim
			 WHERE lim.cdcooper = pr_cdcooper
			   AND lim.nrdconta = pr_nrdconta
				 AND lim.tpctrlim = 2
				 AND lim.insitlim = 2;
		rw_craplim cr_craplim%ROWTYPE;
		
		-- Verificar se a linha de desconto est� bloqueada
		CURSOR cr_crapldc(pr_cdcooper IN craplim.cdcooper%TYPE
		                 ,pr_cddlinha IN craplim.cddlinha%TYPE) IS
      SELECT ldc.txmensal,
						 ldc.txdiaria,
						 ldc.txjurmor,
						 ldc.flgstlcr,
						 ldc.cddlinha
		    FROM crapldc ldc
	     WHERE ldc.cdcooper = pr_cdcooper 
			   AND ldc.cddlinha = pr_cddlinha
			   AND ldc.tpdescto = 2;
    rw_crapldc cr_crapldc%ROWTYPE;
		
	BEGIN														
		-- Busca a data do sistema
		OPEN  BTCH0001.cr_crapdat(pr_cdcooper);
		FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
		CLOSE BTCH0001.cr_crapdat;	
	
		-- Busca associado
	  OPEN cr_crapass(pr_cdcooper => pr_cdcooper
		               ,pr_nrdconta => pr_nrdconta);
		FETCH cr_crapass INTO rw_crapass;
		
		-- Se n�o encontrou associado
		IF cr_crapass%NOTFOUND THEN
			-- Fecha cursor
			CLOSE cr_crapass;
			-- Associado n�o cadastrado
			vr_cdcritic := 9;
			vr_dscritic := '';
			-- Levanta exece��o
			RAISE vr_exc_erro;
		END IF;
		-- Fecha cursor
		CLOSE cr_crapass;
    
    -- Verificar se cooperado foi demitido
    IF rw_crapass.dtdemiss IS NOT NULL THEN
			-- Gerar cr�tica
			vr_cdcritic := 0;
			vr_dscritic := 'Associado DEMITIDO, desconto n�o permiitdo';
		END IF;

    -- Verificar se cooperado foi excluido
    IF rw_crapass.dtelimin IS NOT NULL THEN
			-- Gerar cr�ticta
			vr_cdcritic := 410;
			vr_dscritic := '';
			-- Levanta exece��o
			RAISE vr_exc_erro;			
		END IF;
		
		-- Verificar se a conta n�o tem preju�zo
		IF rw_crapass.cdsitdtl IN ('5','6','7','8') THEN
			-- Gerar cr�tica
			vr_cdcritic := 695;
			vr_dscritic := '';
		END IF;
		
    vr_cdagenci := NVL(pr_cdagenci,0);
    IF NVL(pr_cdagenci,0) = 0 THEN
      vr_cdagenci := NVL(rw_crapass.cdagenci,0);
    END IF;    
    
		-- Verificar se a conta est� bloqueada (95) ou transferida de n�mero (156)
		IF rw_crapass.cdsitdtl IN ('2','4','6','8') THEN
		   OPEN cr_craptrf(pr_cdcooper => pr_cdcooper
			                ,pr_nrdconta => pr_nrdconta);
       FETCH cr_craptrf INTO rw_craptrf;
			 
			 IF cr_craptrf%NOTFOUND THEN
				 -- Fecha cursor
				 CLOSE cr_craptrf;
				 -- C�d. cr�tica
				 vr_cdcritic := 95;
				 -- Levanta exce��o
				 RAISE vr_exc_erro;
			 ELSE 
				 -- Fecha cursor
				 CLOSE cr_craptrf;
				 -- C�d. cr�tica
				 vr_cdcritic := 156;
				 vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 156);
				 vr_dscritic := vr_dscritic || ' ' || 
				                gene0002.fn_mask_conta(pr_nrdconta => pr_nrdconta) || 
												' para o n�mero ' || gene0002.fn_mask_conta(pr_nrdconta => rw_craptrf.nrsconta);
				 -- Levanta exce��o
				 RAISE vr_exc_erro;				 
			 END IF;
		END IF;
		-- Verificar cotas capital
		EXTR0001.pc_ver_capital(pr_cdcooper => pr_cdcooper
		                       ,pr_cdagenci => 0
													 ,pr_nrdcaixa => 0
													 ,pr_inproces => rw_crapdat.inproces
													 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
													 ,pr_dtmvtopr => rw_crapdat.dtmvtopr
													 ,pr_cdprogra => 'LANBDCI'
													 ,pr_idorigem => 1
													 ,pr_nrdconta => pr_nrdconta
													 ,pr_vllanmto => 0
													 ,pr_des_reto => vr_des_reto
													 ,pr_tab_erro => vr_tab_erro);
													 
		-- Se ocorreu erro
		IF vr_des_reto <> 'OK' THEN
			IF vr_tab_erro.COUNT > 0 THEN
				vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
				vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '|| pr_nrdconta;
			ELSE
				vr_cdcritic:= 0;
				vr_dscritic:= 'Retorno "NOK" na EXTR0001.pc_ver_capital e sem informa��o na pr_tab_erro, Conta: '|| pr_nrdconta;
			END IF;
			-- Gera exce��o
			RAISE vr_exc_erro;
		END IF;
		
		-- Verificar se contra possui contrato ativo
		OPEN cr_craplim(pr_cdcooper => pr_cdcooper
		               ,pr_nrdconta => pr_nrdconta);
		FETCH cr_craplim INTO rw_craplim;
					
		-- Se n�o encontrou contato ativo
		IF cr_craplim%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_craplim;
			-- Gerar cr�tica
			vr_cdcritic := 0;
			vr_dscritic := 'N�o h� contrato de limite de desconto ATIVO.';
			-- Levanta exece��o
			RAISE vr_exc_erro;
		END IF;
		-- Fechar cursor
		CLOSE cr_craplim;
    
    -- Verifica se contrato venceu		
		IF rw_crapdat.dtmvtolt > rw_craplim.dtfimvig THEN
		  -- Gerar cr�tica
			vr_cdcritic := 0;
			vr_dscritic := 'Contrato de limite est� vencido';
			-- Levantar exce��o
			RAISE vr_exc_erro;
		END IF;
    
    -- Verifica se limite est� bloqueado para inclus�o de novos borderos
    IF rw_craplim.insitblq = 1 THEN
      -- Gerar cr�tica
			vr_cdcritic := 0;
      
      IF pr_idorigem = 3 THEN
			  vr_dscritic := 'Contrato de limite bloqueado. Entre em contato com seu PA.';
      ELSE
        vr_dscritic := 'Contrato de limite bloqueado para inclus�o de novo border�..';
      END IF;
        
			-- Levantar exce��o
			RAISE vr_exc_erro;
    END IF; 
    
    -- Verificar se a linha de desconto est� bloqueada
    OPEN cr_crapldc(pr_cdcooper => pr_cdcooper
		               ,pr_cddlinha => rw_craplim.cddlinha);
		FETCH cr_crapldc INTO rw_crapldc;
			
		-- Se n�o encontrou
		IF cr_crapldc%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_crapldc;
			-- Gerar cr�tica
      vr_cdcritic := 0;
			vr_dscritic := 'Linha de desconto n�o encontrada';
			-- Levanta exce��o
			RAISE vr_exc_erro;
		END IF;		
		-- Fechar cursor
		CLOSE cr_crapldc;
		
	  -- Se est� bloqueada
		IF rw_crapldc.flgstlcr = 0 THEN
			-- Gerar cr�tica
			vr_cdcritic := 0;
			vr_dscritic := 'Linha de desconto ' || rw_crapldc.cddlinha || ' bloqueada';
		END IF;
		
		-- Verificar se conta foi ou ser� transferida				
	  OPEN cr_craptrf(pr_cdcooper => pr_cdcooper
									 ,pr_nrdconta => pr_nrdconta);
	  FETCH cr_craptrf INTO rw_craptrf;
			 
	  IF cr_craptrf%FOUND THEN
			IF rw_craptrf.insittrs = 1 THEN
         -- Gerar cr�tica
				 vr_cdcritic := 0;
				 vr_dscritic := 'Conta transferida para ' || TRIM(gene0002.fn_mask_conta(pr_nrdconta => rw_craptrf.nrsconta));
			ELSE
         -- Gerar cr�tica
				 vr_cdcritic := 0;
				 vr_dscritic := 'Conta a ser transferida para ' || TRIM(gene0002.fn_mask_conta(pr_nrdconta => rw_craptrf.nrsconta));				
			END IF;
		  -- Levanta exce��o
		  RAISE vr_exc_erro;
	  END IF;

		-- Fecha cursor
		CLOSE cr_craptrf;
		
		vr_flg_criou_lot := FALSE;
    
    WHILE NOT vr_flg_criou_lot
    LOOP
      -- Rotina para criar lote e bordero
      vr_nrdolote := fn_sequence(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRDOLOTE'
                                ,pr_dsdchave => TO_CHAR(pr_cdcooper)|| ';' 
                                             || TO_CHAR(rw_crapdat.dtmvtolt, 'DD/MM/RRRR')|| ';'
                                             || TO_CHAR(vr_cdagenci)|| ';'
                                             || '700') + 260000;
  			
      -- Rotina para criar n�mero de bordero por cooperativa
      vr_nrborder := fn_sequence(pr_nmtabela => 'CRAPBDC'
                                ,pr_nmdcampo => 'NRBORDER'
                                ,pr_dsdchave => TO_CHAR(pr_cdcooper));
  															
      BEGIN
        -- Insere registro na craplot
        INSERT INTO craplot (dtmvtolt
                            ,cdagenci
                            ,cdbccxlt
                            ,nrdolote
                            ,qtinfoln
                            ,vlinfodb													
                            ,vlinfocr
                            ,tplotmov
                            ,dtmvtopg
                            ,cdoperad
                            ,cdhistor
                            ,cdbccxpg
                            ,cdcooper													
                            ,qtinfocc
                            ,qtinfoci
                            ,vlinfoci																										
                            ,vlinfocc
                            ,qtinfocs
                            ,vlinfocs)
                      VALUES(rw_crapdat.dtmvtolt
                            ,vr_cdagenci
                            ,700
                            ,vr_nrdolote
                            ,0
                            ,0
                            ,0
                            ,26
                            ,NULL
                            ,pr_cdoperad
                            ,vr_nrborder
                            ,0
                            ,pr_cdcooper
                            ,0
                            ,0
                            ,0
                            ,0
                            ,0
                            ,0);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          CONTINUE;
        WHEN OTHERS THEN
          -- Gera cr�tica
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir novo lote ' || SQLERRM;
          -- Levanta exce��o
          RAISE vr_exc_erro;
      END;
      
      vr_flg_criou_lot := TRUE;
      
    END LOOP;

		BEGIN
			-- Insere registro no crapbdc
      INSERT INTO crapbdc (dtmvtolt
			                    ,cdagenci
													,cdbccxlt
													,nrdolote
													,nrborder
													,cdoperad
													,nrctrlim													
													,nrdconta
													,cddlinha
													,txmensal
													,txdiaria
													,txjurmor
													,insitbdc
													,inoribdc
													,hrtransa
													,cdcooper													
													,cdopeori
													,cdageori
													,dtinsori)
								    VALUES(rw_crapdat.dtmvtolt
										      ,vr_cdagenci
													,700
													,vr_nrdolote
													,vr_nrborder
													,pr_cdoperad
													,rw_craplim.nrctrlim
													,rw_craplim.nrdconta
													,rw_craplim.cddlinha													
													,rw_crapldc.txmensal
													,rw_crapldc.txdiaria
													,rw_crapldc.txjurmor
													,1
													,0
													,to_char(SYSDATE, 'SSSSS')
													,pr_cdcooper
													,pr_cdoperad
													,vr_cdagenci
													,trunc(SYSDATE));
		EXCEPTION
			WHEN OTHERS THEN
				-- Gera cr�tica
				vr_cdcritic := 0;
				vr_dscritic := 'Erro ao inserir novo border� de cheque ' || SQLERRM;
				-- Levanta exce��o
				RAISE vr_exc_erro;
		END;	
		
		-- Atribui parametros
		pr_nrdolote := vr_nrdolote;
		pr_nrborder := vr_nrborder;														
																				 
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
      -- Efetuar rollback
      ROLLBACK;      
    WHEN OTHERS THEN      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := REPLACE(REPLACE('N�o foi poss�vel criar boreder�: ' || SQLERRM, chr(13)),chr(10));																		
			-- Efetuar Rollback
			ROLLBACK;
	END pc_criar_bordero_cheques;

	PROCEDURE pc_adicionar_cheques_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE
																				,pr_nrdconta IN crapass.nrdconta%TYPE
																				,pr_cdagenci IN crapass.cdagenci%TYPE
																				,pr_idorigem IN PLS_INTEGER
																				,pr_cdoperad IN VARCHAR2
																				,pr_nrborder IN crapbdc.nrborder%TYPE
																				,pr_nrdolote IN crapbdc.nrdolote%TYPE
																				,pr_tab_cheques IN typ_tab_cheques
																				,pr_cdcritic OUT PLS_INTEGER
																				,pr_dscritic OUT VARCHAR2) IS 
  /* .............................................................................
    Programa: pc_adicionar_cheques_bordero
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Novembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para adicionar cheques ao boredero de desconto

    Alteracoes: -----
  ..............................................................................*/
	
	-- Vari�vel de cr�ticas
	vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
	vr_dscritic        VARCHAR2(1000);        --> Desc. Erro        
	-- Tratamento de erros
	vr_exc_erro        EXCEPTION;    
  vr_exc_erro_2      EXCEPTION;

	-- Vari�veis auxiliares
	vr_nrdconta_ver_cheque crapass.nrdconta%TYPE;
	vr_dsdaviso VARCHAR2(1000);
	vr_nrcalcul NUMBER;
	vr_nrddigc1 NUMBER;
	vr_nrddigc2 NUMBER;
	vr_nrddigc3 NUMBER;
	vr_fldigit1 BOOLEAN;
	vr_fldigit2 BOOLEAN;
	vr_fldigit3 BOOLEAN;	
	vr_inchqcop INTEGER;
	vr_dscheque VARCHAR2(32726);
	vr_nrseqdig crapcdb.nrseqdig%TYPE := 0;
	vr_nrremret_aux NUMBER := 0;
	vr_nrremret NUMBER := 0;	
	vr_qtcompln NUMBER := 0;
	vr_vlcompdb NUMBER := 0;
	vr_vlcompcr NUMBER := 0;
  vr_dstransa VARCHAR2(200);
  vr_rowid_log ROWID;
  
  -- PlTable com erros de valida��o de cust�dia
  vr_tab_erro_cust cust0001.typ_erro_custodia;
	
	-- Buscar bordero de desconto de cheque
	CURSOR cr_crapbdc(pr_cdcooper IN crapbdc.cdcooper%TYPE
	                 ,pr_nrdconta IN crapbdc.nrdconta%TYPE
									 ,pr_nrborder IN crapbdc.nrborder%TYPE) IS
	  SELECT bdc.insitbdc
					,bdc.nrborder
					,bdc.nrctrlim
					,bdc.nrdolote
					,bdc.cdagenci
					,bdc.cdbccxlt
					,bdc.dtmvtolt
					,rowid
		  FROM crapbdc bdc
		 WHERE bdc.cdcooper = pr_cdcooper
		   AND bdc.nrdconta = pr_nrdconta
			 AND bdc.nrborder = pr_nrborder;
  rw_crapbdc cr_crapbdc%ROWTYPE;			 		
	
	BEGIN
    
		-- Buscar bordero de desconto de cheque
	  OPEN cr_crapbdc(pr_cdcooper => pr_cdcooper
		               ,pr_nrdconta => pr_nrdconta
									 ,pr_nrborder => pr_nrborder);
		FETCH cr_crapbdc INTO rw_crapbdc;
		
		-- Se n�o encontrou
		IF cr_crapbdc%NOTFOUND THEN
			-- Fecha cursor
			CLOSE cr_crapbdc;
			-- Gera cr�tica
			vr_cdcritic := 0;
			vr_dscritic := 'Border� de desconto de cheque n�o encontrado.';
      -- Levanta exce��o 
			RAISE vr_exc_erro;			
		END IF;			
		-- Fecha cursor
		CLOSE cr_crapbdc;
		
		-- Se o bordero j� estiver liberado
		IF rw_crapbdc.insitbdc > 2 THEN
		  -- Gera cr�tica	
			vr_cdcritic := 0;
			vr_dscritic := 'Boletim j� LIBERADO.';
			-- Levanta exce��o
		  RAISE vr_exc_erro;
		END IF;
		
		-- Se o bordero estiver em an�lise
		IF rw_crapbdc.insitbdc = 2 THEN
			BEGIN
				-- Atualizar situa��o para "Em estudo"
        UPDATE crapbdc bdc
				   SET bdc.insitbdc = 1 -- Em estudo
				 WHERE bdc.rowid = rw_crapbdc.rowid;
			EXCEPTION
				WHEN OTHERS THEN
					-- Gerar cr�tica
					vr_cdcritic := 0;
					vr_dscritic := 'Erro ao atualizar situa��o do bordero: ' || SQLERRM;
					-- Levantar exce��o
					RAISE vr_exc_erro;
			END;
		END IF;
		
		-- Iterar sobre os cheques parametrizados para inclus�o no bordero
		FOR idx IN pr_tab_cheques.first..pr_tab_cheques.last LOOP
      
		  -- Verificar Cheque
			CUST0001.pc_ver_cheque(pr_cdcooper => pr_cdcooper
			                      ,pr_nrcustod => pr_nrdconta
														,pr_cdbanchq => pr_tab_cheques(idx).cdbanchq
														,pr_cdagechq => pr_tab_cheques(idx).cdagechq
														,pr_nrctachq => pr_tab_cheques(idx).nrctachq
														,pr_nrcheque => pr_tab_cheques(idx).nrcheque
														,pr_nrddigc3 => 1
														,pr_vlcheque => pr_tab_cheques(idx).vlcheque
														,pr_nrdconta => vr_nrdconta_ver_cheque
														,pr_dsdaviso => vr_dsdaviso
														,pr_cdcritic => vr_cdcritic
														,pr_dscritic => vr_dscritic);
														
			-- Calcula primeiro digito de controle
			vr_nrcalcul := to_number(to_char(pr_tab_cheques(idx).cdcmpchq,'fm000')  ||
										 to_char(pr_tab_cheques(idx).cdbanchq,'fm000')  || 
										 to_char(pr_tab_cheques(idx).cdagechq,'fm0000') || '0');
															   
		  vr_fldigit1 := GENE0005.fn_calc_digito (pr_nrcalcul => vr_nrcalcul);
					 
			vr_nrddigc1 := to_number(SUBSTR(to_char(vr_nrcalcul),LENGTH(to_char(vr_nrcalcul))));
					  
			-- Calcula segundo digito de controle
			vr_nrcalcul := nvl(pr_tab_cheques(idx).nrctachq, 0) * 10;
			vr_fldigit2 := GENE0005.fn_calc_digito (pr_nrcalcul => vr_nrcalcul);
						  
			vr_nrddigc2 := to_number(SUBSTR(to_char(vr_nrcalcul),LENGTH(to_char(vr_nrcalcul))));   

			-- Calcula terceiro digito de controle   
			vr_nrcalcul := nvl(pr_tab_cheques(idx).nrcheque, 0) * 10;                             
			vr_fldigit3 := GENE0005.fn_calc_digito (pr_nrcalcul => vr_nrcalcul);
						  
			vr_nrddigc3 := to_number(SUBSTR(to_char(vr_nrcalcul),LENGTH(to_char(vr_nrcalcul))));  
			IF vr_nrdconta_ver_cheque > 0 THEN
				 vr_inchqcop := 1; -- Cheque de Cooperado da Cooperativa
			ELSE
				 vr_inchqcop := 0; -- Cheque de Terceiro
			END IF;  				   														
										
			-- Se for novo cheque				
			IF pr_tab_cheques(idx).intipchq = 1 THEN
			  -- Montar dscheque	
			  vr_dscheque := to_char(pr_tab_cheques(idx).dtlibera, 'dd/mm/rrrr') || ';' ||
				               to_char(pr_tab_cheques(idx).dtdcaptu, 'dd/mm/rrrr') || ';' ||
											 to_char(pr_tab_cheques(idx).vlcheque)               || ';' ||
											 pr_tab_cheques(idx).dsdocmc7;
				-- Efetua cust�dia
				cust0001.pc_custodia_cheque_manual(pr_cdcooper => pr_cdcooper
				                                  ,pr_nrdconta => pr_nrdconta
																					,pr_dscheque => vr_dscheque
																					,pr_cdoperad => pr_cdoperad
																					,pr_nrborder => pr_nrborder
																					,pr_nrseqarq => idx --> N�mero de sequencia � o �ndice da PlTable
																					,pr_nrremret => vr_nrremret_aux
																					,pr_tab_erro_cust => vr_tab_erro_cust
																					,pr_cdcritic => vr_cdcritic
																					,pr_dscritic => vr_dscritic);
				vr_nrremret := vr_nrremret_aux;
				-- Se teve cr�ticas								
				IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL OR vr_tab_erro_cust.count > 0 THEN
					-- Cheque com cr�tica, levanta exce��o
					RAISE vr_exc_erro;
				END IF;
			ELSE -- Apenas atualiza dcc
				vr_nrremret := pr_tab_cheques(idx).nrremret;
	      BEGIN 
					UPDATE crapdcc dcc SET nrborder = pr_nrborder
					 WHERE dcc.cdcooper = pr_tab_cheques(idx).cdcooper
						 AND dcc.nrdconta = pr_nrdconta
						 AND dcc.nrremret = vr_nrremret
						 AND dcc.intipmvt IN (1,3)
						 AND dcc.cdtipmvt = 1
						 AND dcc.cdcmpchq = pr_tab_cheques(idx).cdcmpchq
						 AND dcc.cdbanchq = pr_tab_cheques(idx).cdbanchq
						 AND dcc.cdagechq = pr_tab_cheques(idx).cdagechq
						 AND dcc.nrctachq = pr_tab_cheques(idx).nrctachq
						 AND dcc.nrcheque = pr_tab_cheques(idx).nrcheque
						 AND dcc.nrborder = 0;
					-- Se atualizou mais de um registro
					IF SQL%ROWCOUNT > 1 THEN
						-- Gerar cr�tica
						vr_cdcritic := 0;
						vr_dscritic := 'Erro ao atualizar detalhe de cust�dia.';
						-- Levantar exce��o
						RAISE vr_exc_erro_2;
					END IF;					 
					
				EXCEPTION
					WHEN vr_exc_erro_2 THEN
						-- Levantar exce��o
						RAISE vr_exc_erro;
					WHEN OTHERS THEN
						-- Gerar cr�tica
						vr_cdcritic := 0;
						vr_dscritic := 'Erro ao atualizar n�mero de bordero de cheque (Detalhe custodia de cheques): ' || SQLERRM;
						-- Levantar exce��o
						RAISE vr_exc_erro;
				END;

			END IF;
      
      vr_nrseqdig := vr_nrseqdig + 1;
      
      BEGIN 
				-- Insere registro na crapcdb
        INSERT INTO crapcdb
				       (nrdconta
							 ,nrdolote
							 ,dtmvtolt
							 ,dtlibera
               ,dtemissa
							 ,cdcmpchq
							 ,cdbanchq
							 ,cdagechq
							 ,nrctachq
							 ,nrcheque
							 ,vlcheque
							 ,cdopedev
							 ,insitchq
							 ,dtdevolu
							 ,dsdocmc7
							 ,nrseqdig
							 ,nrddigc1
							 ,nrddigc2
							 ,nrddigc3
							 ,cdagenci
							 ,cdbccxlt
							 ,cdoperad
							 ,inchqcop
							 ,nrctrlim
							 ,nrborder
							 ,nrcpfcgc
							 ,cdcooper
							 ,insitana
							 ,cdopeana
							 ,dtsitana
							 ,nrremret)
				 VALUES(pr_nrdconta
				       ,pr_nrdolote
				       ,pr_tab_cheques(idx).dtmvtolt
				       ,pr_tab_cheques(idx).dtlibera
               ,pr_tab_cheques(idx).dtdcaptu
							 ,pr_tab_cheques(idx).cdcmpchq
							 ,pr_tab_cheques(idx).cdbanchq
							 ,pr_tab_cheques(idx).cdagechq
							 ,pr_tab_cheques(idx).nrctachq
							 ,pr_tab_cheques(idx).nrcheque
							 ,pr_tab_cheques(idx).vlcheque
							 ,''
							 ,0
							 ,NULL
							 ,gene0002.fn_mask(pr_tab_cheques(idx).dsdocmc7,'<99999999<9999999999>999999999999:')
							 ,vr_nrseqdig
							 ,vr_nrddigc1
							 ,vr_nrddigc2
							 ,vr_nrddigc3
							 ,pr_tab_cheques(idx).cdagenci
							 ,pr_tab_cheques(idx).cdbccxlt
							 ,pr_cdoperad
							 ,vr_inchqcop
							 ,rw_crapbdc.nrctrlim
							 ,rw_crapbdc.nrborder
							 ,pr_tab_cheques(idx).nrcpfcgc
							 ,pr_cdcooper
							 ,0   -- Situa��o da an�lise (0 - Em estudo)
							 ,0
							 ,NULL
							 ,vr_nrremret);
			EXCEPTION
				WHEN OTHERS THEN
					-- Gerar cr�tica
					vr_cdcritic := 0;
					vr_dscritic := 'Erro ao inserir cheque no border� de desconto: ' || SQLERRM;
					-- Levantar exce��o
          RAISE vr_exc_erro;
			END;			
			
			BEGIN
				UPDATE crapcst cst
					 SET cst.nrborder = pr_nrborder
				 WHERE cst.cdcooper = pr_tab_cheques(idx).cdcooper
					 AND cst.nrdconta = pr_nrdconta
					 AND cst.cdcmpchq = pr_tab_cheques(idx).cdcmpchq
					 AND cst.cdbanchq = pr_tab_cheques(idx).cdbanchq
					 AND cst.cdagechq = pr_tab_cheques(idx).cdagechq
					 AND cst.nrctachq = pr_tab_cheques(idx).nrctachq
					 AND cst.nrcheque = pr_tab_cheques(idx).nrcheque
					 AND cst.dtlibera = pr_tab_cheques(idx).dtlibera
					 AND cst.insitchq IN (0,2)
					 AND cst.nrborder = 0;
				-- Se atualizou mais de um registro
				IF SQL%ROWCOUNT > 1 THEN
					-- Gerar cr�tica
					vr_cdcritic := 0;
					vr_dscritic := 'Erro ao atualizar cust�dia.';
					-- Levantar exce��o
					RAISE vr_exc_erro_2;
				END IF;					 
			EXCEPTION
				WHEN vr_exc_erro_2 THEN
					-- Levantar exce��o
					RAISE vr_exc_erro;
				WHEN OTHERS THEN
					-- Gerar cr�tica
					vr_cdcritic := 0;
					vr_dscritic := 'Erro ao atualizar n�mero de bordero de cheque (Custodia de cheques): ' || SQLERRM;
					-- Levantar exce��o
					RAISE vr_exc_erro;
			END;			
			-- Incrementa valores e quantidade de cheques
			vr_qtcompln := vr_qtcompln + 1;
			vr_vlcompcr := vr_vlcompcr + pr_tab_cheques(idx).vlcheque;
			vr_vlcompdb := vr_vlcompdb + pr_tab_cheques(idx).vlcheque;
      
      
      vr_dstransa := 'Inclusao de cheque no bordero Nro.: ' || pr_nrborder;
      
      -- Efetua os inserts para apresentacao na tela VERLOG
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => ' '
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => trunc(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => to_char(SYSDATE,'SSSSS')
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'ATENDA_DESCT'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_rowid_log);
      
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid_log
                               ,pr_nmdcampo => 'Border�'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => pr_nrborder);
      
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid_log
                               ,pr_nmdcampo => 'CMC7'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => gene0002.fn_mask(pr_tab_cheques(idx).dsdocmc7,'<99999999<9999999999>999999999999:'));
                               
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid_log
                               ,pr_nmdcampo => 'Data Boa'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => to_char(pr_tab_cheques(idx).dtlibera,'DD/MM/RRRR'));
                               
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid_log
                               ,pr_nmdcampo => 'Data Emissao'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => to_char(pr_tab_cheques(idx).dtdcaptu,'DD/MM/RRRR'));
                               
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid_log
                               ,pr_nmdcampo => 'Valor'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => pr_tab_cheques(idx).vlcheque);
      
		END LOOP;
    
    -- Atualiza o lote
		UPDATE craplot lot
		   SET lot.qtcompln = lot.qtcompln + vr_qtcompln
			    ,lot.vlcompdb = lot.vlcompdb + vr_vlcompdb
					,lot.vlcompcr = lot.vlcompcr + vr_vlcompcr
			    ,lot.nrseqdig = vr_nrseqdig
          ,lot.vlinfodb = lot.vlinfodb + vr_vlcompdb
          ,lot.vlinfocr = lot.vlinfocr + vr_vlcompcr
          ,lot.qtinfoln = lot.qtinfoln + vr_qtcompln
		 WHERE lot.cdcooper = pr_cdcooper
 			 AND lot.dtmvtolt = rw_crapbdc.dtmvtolt
		   AND lot.nrdolote = rw_crapbdc.nrdolote
			 AND lot.cdagenci = rw_crapbdc.cdagenci
			 AND lot.cdbccxlt = rw_crapbdc.cdbccxlt;
		-- Atualiza Flag de exigencia de assinatura do cooperado
		UPDATE crapbdc bdc
       SET bdc.flgassin = 1
		 WHERE bdc.rowid = rw_crapbdc.rowid;
		
	EXCEPTION    
    WHEN vr_exc_erro THEN      
      IF NVL(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSIF vr_tab_erro_cust.count > 0 THEN
				pr_cdcritic := 0;
				pr_dscritic := 'Cheque ' ||
				               vr_tab_erro_cust(vr_tab_erro_cust.first).dsdocmc7 || 
											 ' apresentou erro. Erro: ' ||
											 vr_tab_erro_cust(vr_tab_erro_cust.first).dscritic;
			ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := REPLACE(REPLACE(vr_dscritic,chr(13)),chr(10));
      END IF;
      -- Efetuar rollback
      ROLLBACK;      
    WHEN OTHERS THEN      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := REPLACE(REPLACE('Nao foi possivel adicionar cheques ao border�: ' || SQLERRM, chr(13)),chr(10));																			
			-- Efetuar Rollback
			ROLLBACK;
	END pc_adicionar_cheques_bordero;		
	
	PROCEDURE pc_excluir_cheque_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE
																		 ,pr_nrdconta IN crapass.nrdconta%TYPE
																		 ,pr_cdagenci IN crapass.cdagenci%TYPE
																		 ,pr_idorigem IN PLS_INTEGER
																		 ,pr_cdoperad IN VARCHAR2
																		 ,pr_nrborder IN crapbdc.nrborder%TYPE
																		 ,pr_tab_cheques IN typ_tab_cheques
																		 ,pr_cdcritic OUT PLS_INTEGER
																		 ,pr_dscritic OUT VARCHAR2) IS 
  /* .............................................................................
    Programa: pc_excluir_cheque_bordero
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Novembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para remover cheques do boredero de desconto

    Alteracoes: -----
  ..............................................................................*/
	-- Vari�vel de cr�ticas
	vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
	vr_dscritic        VARCHAR2(1000);        --> Desc. Erro        
	-- Tratamento de erros
	vr_exc_erro        EXCEPTION;    

  -- Vari�veis auxiliares
	vr_qtcompln  NUMBER := 0;
  vr_vlcompcr  NUMBER := 0;
	vr_vlcompdb  NUMBER := 0;
	vr_vlcompax  NUMBER := 0;
	vr_dstransa  VARCHAR2(200);
  vr_rowid_log ROWID;
  
	-- Buscar bordero de desconto de cheque
	CURSOR cr_crapbdc(pr_cdcooper IN crapbdc.cdcooper%TYPE
	                 ,pr_nrdconta IN crapbdc.nrdconta%TYPE
									 ,pr_nrborder IN crapbdc.nrborder%TYPE) IS
	  SELECT bdc.nrdolote
					,bdc.cdagenci
					,bdc.cdbccxlt
					,bdc.dtmvtolt
					,rowid
		  FROM crapbdc bdc
		 WHERE bdc.cdcooper = pr_cdcooper
		   AND bdc.nrdconta = pr_nrdconta
			 AND bdc.nrborder = pr_nrborder;
  rw_crapbdc cr_crapbdc%ROWTYPE;		
	
  BEGIN
		-- Buscar bordero de desconto de cheque
	  OPEN cr_crapbdc(pr_cdcooper => pr_cdcooper
		               ,pr_nrdconta => pr_nrdconta
									 ,pr_nrborder => pr_nrborder);
		FETCH cr_crapbdc INTO rw_crapbdc;
		
		-- Se n�o encontrou
		IF cr_crapbdc%NOTFOUND THEN
			-- Fecha cursor
			CLOSE cr_crapbdc;
			-- Gera cr�tica
			vr_cdcritic := 0;
			vr_dscritic := 'Border� de desconto de cheque n�o encontrado.';
      -- Levanta exce��o 
			RAISE vr_exc_erro;			
		END IF;			
		-- Fecha cursor
		CLOSE cr_crapbdc;
		
		-- Iterar sobre os cheques parametrizados para inclus�o no bordero
		FOR idx IN pr_tab_cheques.first..pr_tab_cheques.last LOOP

			UPDATE crapdcc dcc SET nrborder = 0 -- zero
			 WHERE dcc.cdcooper = pr_cdcooper
				 AND dcc.nrdconta = pr_nrdconta
				 AND dcc.intipmvt IN (1,3)
				 AND dcc.cdtipmvt = 1
				 AND dcc.cdcmpchq = pr_tab_cheques(idx).cdcmpchq
				 AND dcc.cdbanchq = pr_tab_cheques(idx).cdbanchq
				 AND dcc.cdagechq = pr_tab_cheques(idx).cdagechq
				 AND dcc.nrctachq = pr_tab_cheques(idx).nrctachq
				 AND dcc.nrcheque = pr_tab_cheques(idx).nrcheque
				 AND dcc.nrborder = pr_nrborder;
			
		-- se o cheque estiver em cust�dia (crapcst), atualizar o numero do border� para zero;	
			UPDATE crapcst cst SET nrborder = 0 -- zero
			 WHERE cst.cdcooper = pr_cdcooper
				 AND cst.nrdconta = pr_nrdconta
				 AND cst.cdcmpchq = pr_tab_cheques(idx).cdcmpchq
				 AND cst.cdbanchq = pr_tab_cheques(idx).cdbanchq
				 AND cst.cdagechq = pr_tab_cheques(idx).cdagechq
				 AND cst.nrctachq = pr_tab_cheques(idx).nrctachq
				 AND cst.nrcheque = pr_tab_cheques(idx).nrcheque
				 AND cst.dtlibera = pr_tab_cheques(idx).dtlibera
				 AND cst.insitchq IN (0,2)
				 AND cst.nrborder = pr_nrborder;	
				 
			-- apagar registro do c�lculo de juros do cheque no border�;		   
			DELETE FROM crapljd ljd
			 WHERE ljd.cdcooper = pr_cdcooper
				 AND ljd.nrdconta = pr_nrdconta
				 AND ljd.nrborder = pr_nrborder
				 AND ljd.cdcmpchq = pr_tab_cheques(idx).cdcmpchq   
				 AND ljd.cdbanchq = pr_tab_cheques(idx).cdbanchq   
				 AND ljd.cdagechq = pr_tab_cheques(idx).cdagechq   
				 AND ljd.nrctachq = pr_tab_cheques(idx).nrctachq   
				 AND ljd.nrcheque = pr_tab_cheques(idx).nrcheque;
			   	   
		  -- apagar registro de an�lise dos cheques do border�;
			DELETE FROM crapabc abc
			 WHERE abc.cdcooper = pr_cdcooper
				 AND abc.nrdconta = pr_nrdconta
				 AND abc.nrborder = pr_nrborder
				 AND abc.cdcmpchq = pr_tab_cheques(idx).cdcmpchq
				 AND abc.cdbanchq = pr_tab_cheques(idx).cdbanchq
				 AND abc.cdagechq = pr_tab_cheques(idx).cdagechq
				 AND abc.nrctachq = pr_tab_cheques(idx).nrctachq
				 AND abc.nrcheque = pr_tab_cheques(idx).nrcheque;
				
		  -- apagar registro do cheque no border�;
			DELETE FROM crapcdb cdb
			 WHERE cdb.cdcooper = pr_cdcooper
				 AND cdb.nrdconta = pr_nrdconta
				 AND cdb.nrborder = pr_nrborder			   
				 AND cdb.cdcmpchq = pr_tab_cheques(idx).cdcmpchq
				 AND cdb.cdbanchq = pr_tab_cheques(idx).cdbanchq
				 AND cdb.cdagechq = pr_tab_cheques(idx).cdagechq
				 AND cdb.nrctachq = pr_tab_cheques(idx).nrctachq
				 AND cdb.nrcheque = pr_tab_cheques(idx).nrcheque
				 AND cdb.dtlibera = pr_tab_cheques(idx).dtlibera
				 RETURNING cdb.vlcheque INTO vr_vlcompax;

 			-- Incrementa valores e quantidade de cheques
			vr_qtcompln := vr_qtcompln + 1;
			vr_vlcompcr := vr_vlcompcr + vr_vlcompax;
			vr_vlcompdb := vr_vlcompdb + vr_vlcompax;			
      
      vr_dstransa := 'Exclusao de cheque do bordero Nro.: ' || pr_nrborder;
      
      -- Efetua os inserts para apresentacao na tela VERLOG
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => ' '
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => trunc(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => to_char(SYSDATE,'SSSSS')
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'ATENDA_DESCT'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_rowid_log);
      
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid_log
                               ,pr_nmdcampo => 'Border�'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => pr_nrborder);
      
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid_log
                               ,pr_nmdcampo => 'CMC7'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => pr_tab_cheques(idx).dsdocmc7);
    END LOOP;	
		
		-- Atualiza o lote
		UPDATE craplot lot
		   SET lot.qtcompln = lot.qtcompln - vr_qtcompln
			    ,lot.vlcompdb = lot.vlcompdb - vr_vlcompdb
					,lot.vlcompcr = lot.vlcompcr - vr_vlcompcr
          ,lot.vlinfodb = lot.vlinfodb - vr_vlcompdb
          ,lot.vlinfocr = lot.vlinfocr - vr_vlcompcr
          ,lot.qtinfoln = lot.qtinfoln - vr_qtcompln
		 WHERE lot.cdcooper = pr_cdcooper
 			 AND lot.dtmvtolt = rw_crapbdc.dtmvtolt
		   AND lot.nrdolote = rw_crapbdc.nrdolote
			 AND lot.cdagenci = rw_crapbdc.cdagenci
			 AND lot.cdbccxlt = rw_crapbdc.cdbccxlt;
		
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
      -- Efetuar rollback
      ROLLBACK;      
    WHEN OTHERS THEN      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := REPLACE(REPLACE('Nao foi possivel remover cheques do border�: ' || SQLERRM, chr(13)),chr(10));																			
			-- Efetuar Rollback
			ROLLBACK;
  END pc_excluir_cheque_bordero;
	
	PROCEDURE pc_busca_cheques_analise(pr_cdcooper IN crapcop.cdcooper%TYPE
																		,pr_nrdconta IN crapass.nrdconta%TYPE
																		,pr_nrborder IN crapbdc.nrborder%TYPE
																		,pr_tab_cheques OUT typ_tab_cheques																		
																		,pr_cdcritic OUT PLS_INTEGER
																		,pr_dscritic OUT VARCHAR2) IS 
  /* .............................................................................
    Programa: pc_busca_cheques_analise
    Sistema : Ayllos Web
    Autor   : Lucas Reinert
    Data    : Novembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar cheques para analise

    Alteracoes: -----
  ..............................................................................*/
	-- Vari�vel de cr�ticas
	vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
	vr_dscritic        VARCHAR2(1000);        --> Desc. Erro        
	-- Tratamento de erros
	vr_exc_erro        EXCEPTION;    
	
	-- Vari�veis auxiliares
	vr_tab_cheques  typ_tab_cheques;
	vr_index_cheque NUMBER;
  vr_dtlibera     DATE;
  vr_nrcpfcgc     VARCHAR2(100);
  vr_nmcheque     VARCHAR2(100);
  vr_blnfound     BOOLEAN;
  vr_stsnrcal     BOOLEAN;
  vr_inpessoa     INTEGER;
  
  CURSOR cr_crapbdc (pr_cdcooper IN crapcdb.cdcooper%TYPE
	                 ,pr_nrdconta IN crapcdb.nrdconta%TYPE
									 ,pr_nrborder IN crapcdb.nrborder%TYPE) IS
    SELECT bdc.dtmvtolt
      FROM crapbdc bdc
     WHERE bdc.cdcooper = pr_cdcooper
			 AND bdc.nrdconta = pr_nrdconta
			 AND bdc.nrborder = pr_nrborder;
  rw_crapbdc cr_crapbdc%ROWTYPE;
  
	-- Buscar cheques para analise
	CURSOR cr_crapcdb(pr_cdcooper IN crapcdb.cdcooper%TYPE
	                 ,pr_nrdconta IN crapcdb.nrdconta%TYPE
									 ,pr_nrborder IN crapcdb.nrborder%TYPE) IS
		SELECT cdb.dtlibera	
          ,cdb.dtmvtolt
          ,cdb.dtemissa	
					,cdb.cdcmpchq
					,cdb.cdbanchq
					,cdb.cdagechq
					,cdb.nrctachq
					,cdb.nrcheque
				  ,nvl(cdb.nrcpfcgc, 0) nrcpfcgc
					,cdb.vlcheque
/*				  ,(SELECT LISTAGG(oco.dsocorre, ';') WITHIN GROUP (ORDER BY oco.cdocorre) 
					    FROM crapabc abc, TBDSCC_OCORRENCIAS oco
						 WHERE abc.cdcooper = cdb.cdcooper
							 AND abc.nrdconta = cdb.nrdconta
							 AND abc.nrborder = cdb.nrborder
							 AND abc.cdcmpchq = cdb.cdcmpchq
							 AND abc.cdbanchq = cdb.cdbanchq
							 AND abc.cdagechq = cdb.cdagechq
							 AND abc.nrctachq = cdb.nrctachq
							 AND abc.nrcheque = cdb.nrcheque
							 AND oco.cdocorre = abc.cdocorre) dscritica*/
					,DECODE(cdb.insitana, 1, 'Aprovado', 'Reporvado') dssitana
					,cdb.insitana
					,cdb.dsdocmc7
					,dcc.nrremret
			FROM crapcdb cdb
				  ,crapbdc bdc
				  ,craplim lim
					,crapdcc dcc
		 WHERE cdb.cdcooper = pr_cdcooper
			 AND cdb.nrdconta = pr_nrdconta
			 AND cdb.nrborder = pr_nrborder
			 AND bdc.cdcooper = cdb.cdcooper
			 AND bdc.nrdconta = cdb.nrdconta
			 AND bdc.nrborder = cdb.nrborder
			 AND lim.cdcooper = bdc.cdcooper
			 AND lim.nrdconta = bdc.nrdconta
			 AND lim.nrctrlim = bdc.nrctrlim
			 AND dcc.cdcooper = cdb.cdcooper
			 AND dcc.nrdconta = cdb.nrdconta
			 AND dcc.cdcmpchq = cdb.cdcmpchq
			 AND dcc.cdbanchq = cdb.cdbanchq
			 AND dcc.cdagechq = cdb.cdagechq
			 AND dcc.nrctachq = cdb.nrctachq
			 AND dcc.nrcheque = cdb.nrcheque
			 AND dcc.nrborder = cdb.nrborder;
       
  --> Buscar cadastro do cooperado emitente
  CURSOR cr_crapass (pr_cdagectl IN crapcop.cdagectl%TYPE,
                     pr_nrdconta IN crapass.nrdconta%TYPE)IS
    SELECT ass.inpessoa
          ,ass.cdcooper
          ,ass.nrcpfcgc
      FROM crapass ass
          ,crapcop cop
     WHERE cop.cdagectl = pr_cdagectl
       AND ass.cdcooper = cop.cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass  cr_crapass%ROWTYPE;
  
  --> Buscar primeiro titular da conta
  CURSOR cr_crapttl (pr_cdcooper IN crapcop.cdcooper%TYPE
                    ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ttl.nmtalttl
          ,ttl.nrcpfcgc
      FROM crapttl ttl
     WHERE ttl.cdcooper = pr_cdcooper
       AND ttl.nrdconta = pr_nrdconta
       AND ttl.idseqttl = 1;
  rw_crapttl  cr_crapttl%ROWTYPE;
  
  --> Busca pessoa juridica
  CURSOR cr_crapjur (pr_cdcooper IN crapcop.cdcooper%TYPE
                    ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT jur.nmtalttl
      FROM crapjur jur
     WHERE jur.cdcooper = pr_cdcooper
       AND jur.nrdconta = pr_nrdconta;
  rw_crapjur  cr_crapjur%ROWTYPE;

	-- Buscar cheques para analise
	CURSOR cr_crapcec(pr_cdcooper IN crapcec.cdcooper%TYPE
                   ,pr_nrcpfcgc IN crapcec.nrcpfcgc%TYPE
                   ,pr_cdcmpchq IN crapcec.cdcmpchq%TYPE
                   ,pr_cdbanchq IN crapcec.cdbanchq%TYPE
                   ,pr_cdagechq IN crapcec.cdagechq%TYPE
                   ,pr_nrctachq IN crapcec.nrctachq%TYPE) IS
		SELECT cec.nmcheque
					,cec.nrcpfcgc
			FROM crapcec cec
		 WHERE cec.cdcooper = pr_cdcooper
			 AND cec.nrcpfcgc = pr_nrcpfcgc
			 AND cec.cdcmpchq = pr_cdcmpchq
       AND cec.cdbanchq = pr_cdbanchq
			 AND cec.cdagechq = pr_cdagechq
       AND cec.nrctachq = pr_nrctachq
			 AND cec.nrdconta = 0;
  rw_crapcec cr_crapcec%ROWTYPE;
  
  BEGIN
	  
    -- Buscar data parametro de referencia para calculo de juros
		vr_dtlibera := to_date(GENE0001.fn_param_sistema (pr_cdcooper => 0
                                                     ,pr_nmsistem => 'CRED'
                                                     ,pr_cdacesso => 'DT_BLOQ_ARQ_DSC_CHQ')
                          ,'DD/MM/RRRR');
    
    OPEN cr_crapbdc(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrborder => pr_nrborder);
    FETCH cr_crapbdc INTO rw_crapbdc;
    IF cr_crapbdc%NOTFOUND THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Border� n�o encontrado.';
      RAISE vr_exc_erro;
    END IF;
    
    IF vr_dtlibera > rw_crapbdc.dtmvtolt THEN
      vr_cdcritic := 0;
      vr_dscritic := 'N�o � poss�vel analisar borderos gerados antes do dia \"' ||
                     vr_dtlibera || '\".';
      RAISE vr_exc_erro;
    END IF;
    
	  -- Percorrer todos os cheques para analise
	  FOR rw_crapcdb IN cr_crapcdb(pr_cdcooper => pr_cdcooper
			                          ,pr_nrdconta => pr_nrdconta
																,pr_nrborder => pr_nrborder) LOOP
      -- Se for do sistema CECRED
      IF rw_crapcdb.cdbanchq = 85 THEN
        -- Buscar cadastro do cooperado emitente
        OPEN cr_crapass (pr_cdagectl => rw_crapcdb.cdagechq
                        ,pr_nrdconta => rw_crapcdb.nrctachq);
        FETCH cr_crapass INTO rw_crapass;
        vr_blnfound := cr_crapass%FOUND;
        CLOSE cr_crapass;
        -- Se NAO encontrar
        IF NOT vr_blnfound THEN
          vr_nmcheque := 'NAO CADASTRADO';
          vr_nrcpfcgc := 0; --'NAO CADASTRADO';
        ELSE
          -- Pessoa F�sica
          IF rw_crapass.inpessoa = 1 THEN
            OPEN cr_crapttl (pr_cdcooper => rw_crapass.cdcooper
                            ,pr_nrdconta => rw_crapcdb.nrctachq);
            FETCH cr_crapttl INTO rw_crapttl;
            vr_blnfound := cr_crapttl%FOUND;
            CLOSE cr_crapttl;
            -- Se NAO encontrar
            IF NOT vr_blnfound THEN
              vr_nmcheque := 'NAO CADASTRADO';
              vr_nrcpfcgc := 0; -- 'NAO CADASTRADO';
            ELSE
              vr_nmcheque := rw_crapttl.nmtalttl;
              vr_nrcpfcgc := rw_crapttl.nrcpfcgc;
            END IF;
          ELSE -- Pessoa Juridica
            OPEN cr_crapjur (pr_cdcooper => rw_crapass.cdcooper
                            ,pr_nrdconta => rw_crapcdb.nrctachq);
            FETCH cr_crapjur INTO rw_crapjur;
            vr_blnfound := cr_crapjur%FOUND;
            CLOSE cr_crapjur;
            -- Se NAO encontrar
            IF NOT vr_blnfound THEN
              vr_nmcheque := 'NAO CADASTRADO';
              vr_nrcpfcgc := 0; --'NAO CADASTRADO';
            ELSE
              vr_nmcheque := rw_crapjur.nmtalttl;
              vr_nrcpfcgc := rw_crapass.nrcpfcgc;
            END IF;
          END IF;
        END IF;
      ELSE
        -- Buscar cadastro de emitentes de cheques
        OPEN cr_crapcec(pr_cdcooper => pr_cdcooper
                       ,pr_nrcpfcgc => rw_crapcdb.nrcpfcgc
                       ,pr_cdcmpchq => rw_crapcdb.cdcmpchq
                       ,pr_cdbanchq => rw_crapcdb.cdbanchq
                       ,pr_cdagechq => rw_crapcdb.cdagechq
                       ,pr_nrctachq => rw_crapcdb.nrctachq);
        FETCH cr_crapcec INTO rw_crapcec;
        vr_blnfound := cr_crapcec%FOUND;
        CLOSE cr_crapcec;
        -- Se NAO encontrar
        IF NOT vr_blnfound THEN
          vr_nmcheque := 'NAO CADASTRADO';
          vr_nrcpfcgc := rw_crapcdb.nrcpfcgc; -- 'NAO CADASTRADO';
        ELSE
          -- Validar CPF/CNPJ
          gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => rw_crapcec.nrcpfcgc, 
                                      pr_stsnrcal => vr_stsnrcal, 
                                      pr_inpessoa => vr_inpessoa);
  			
          vr_nrcpfcgc := rw_crapcec.nrcpfcgc;
          vr_nmcheque := rw_crapcec.nmcheque;
        END IF;
      END IF;
      
      -- Alimentar PlTable com dados do cheque
			vr_index_cheque := vr_tab_cheques.count;
			vr_tab_cheques(vr_index_cheque).dtlibera := rw_crapcdb.dtlibera;
		  vr_tab_cheques(vr_index_cheque).dtmvtolt := rw_crapcdb.dtmvtolt;
			vr_tab_cheques(vr_index_cheque).dtdcaptu := rw_crapcdb.dtemissa;
			vr_tab_cheques(vr_index_cheque).cdcmpchq := rw_crapcdb.cdcmpchq;
			vr_tab_cheques(vr_index_cheque).cdbanchq := rw_crapcdb.cdbanchq;			
			vr_tab_cheques(vr_index_cheque).cdagechq := rw_crapcdb.cdagechq;
			vr_tab_cheques(vr_index_cheque).nrctachq := rw_crapcdb.nrctachq;
			vr_tab_cheques(vr_index_cheque).nrcheque := rw_crapcdb.nrcheque;
			vr_tab_cheques(vr_index_cheque).nrcpfcgc := vr_nrcpfcgc;
			vr_tab_cheques(vr_index_cheque).nmcheque := vr_nmcheque;
			vr_tab_cheques(vr_index_cheque).vlcheque := rw_crapcdb.vlcheque;
			vr_tab_cheques(vr_index_cheque).dssitana := rw_crapcdb.dssitana;
			vr_tab_cheques(vr_index_cheque).insitana := rw_crapcdb.insitana;
			vr_tab_cheques(vr_index_cheque).dsdocmc7 := rw_crapcdb.dsdocmc7;
			vr_tab_cheques(vr_index_cheque).nrremret := rw_crapcdb.nrremret;
			
		END LOOP;
		
		-- Retornar cheques
		pr_tab_cheques := vr_tab_cheques;
		
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
      -- Efetuar rollback
      ROLLBACK;      
    WHEN OTHERS THEN      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := REPLACE(REPLACE('Nao foi possivel remover cheques do border�: ' || SQLERRM, chr(13)),chr(10));																			
			-- Efetuar Rollback
			ROLLBACK;				 
	END pc_busca_cheques_analise;
	
	PROCEDURE pc_calcular_rendas_faturamento(pr_cdcooper IN crapcop.cdcooper%TYPE
																					,pr_nrdconta IN crapass.nrdconta%TYPE
																					,pr_vlrendim OUT NUMBER
																					,pr_cdcritic OUT PLS_INTEGER
																					,pr_dscritic OUT VARCHAR2) IS
  /* .............................................................................
    Programa: pc_calcular_rendas_faturamento
    Sistema : CECRED
    Autor   : Lucas Reinert
    Data    : Dezembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar rendas/faturamento

    Alteracoes: -----
  ..............................................................................*/																			 
	-- Vari�veis para controle de erros
	vr_cdcritic PLS_INTEGER;
	vr_dscritic VARCHAR2(4000);
  vr_exc_erro EXCEPTION;
	
	-- Vari�veis auxiliares
  vr_vet_nrcpfcgc     gene0002.typ_split;          -- Array contendo os CPF titulares
  vr_flgconta         BOOLEAN;                     -- Verifica se conjuge eh titular tambem
  vr_cdagenci         NUMBER(5);                   -- P.A do cooperado
  vr_inpessoa         NUMBER(1);                   -- Tipo de pessoa do cooperado
  vr_vlrendim         NUMBER(20,2);                -- Valor do rendimento
  vr_anomes           NUMBER(6);                   -- Numero contendo o ano e mes de faturamento
  vr_vlfatmes         NUMBER(20,2);                -- Valor do faturamento do mes
  vr_vlfatano         NUMBER(20,2);                -- Valor do faturamento anual
  vr_lscpfcgc         VARCHAR2(100);               -- Verificador de conjuge na ttl

  -- Cursor com os cooperados
  CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
	                  ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
          ,ass.inpessoa
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;

  -- Cursor com os titulares da conta
  CURSOR cr_crapttl (pr_cdcooper IN crapass.cdcooper%TYPE
	                  ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ttl.idseqttl
          ,ttl.vldrendi##1 + ttl.vldrendi##2 + ttl.vldrendi##3 + ttl.vldrendi##4 + ttl.vldrendi##5 + ttl.vldrendi##6 vldrendi
          ,ttl.vlsalari
          ,ttl.nrcpfcgc
      FROM crapttl ttl
     WHERE ttl.cdcooper = pr_cdcooper
       AND ttl.nrdconta = pr_nrdconta;

  -- Cursor para obter tabela das pessoas juridicas
  CURSOR cr_crapjur (pr_cdcooper IN crapass.cdcooper%TYPE
	                  ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT jur.vlfatano
     FROM crapjur jur
    WHERE jur.cdcooper = pr_cdcooper
      AND jur.nrdconta = pr_nrdconta;
			
  -- Busca o ano e m�s mais recente (anoftbru e mesftbru), depois busca o valor correspondente ao mesmo m�s (vlrftbru).
  -- Dados financeiros dos cooperados pessoa jur�dica.
  CURSOR cr_crapjfn (pr_cdcooper IN crapass.cdcooper%TYPE
	                  ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT anomes,
           decode(anomes,
                  anomes1, valor1,
                  anomes2, valor2,
                  anomes3, valor3,
                  anomes4, valor4,
                  anomes5, valor5,
                  anomes6, valor6,
                  anomes7, valor7,
                  anomes8, valor8,
                  anomes9, valor9,
                  anomes10, valor10,
                  anomes11, valor11,
                  anomes12, valor12)
           vlfatmes
      FROM (SELECT greatest (anomes1, anomes2, anomes3, anomes4, anomes5, anomes6, anomes7, anomes8, anomes9, anomes10, anomes11, anomes12) anomes,
                   anomes1, valor1,
                   anomes2, valor2,
                   anomes3, valor3,
                   anomes4, valor4,
                   anomes5, valor5,
                   anomes6, valor6,
                   anomes7, valor7,
                   anomes8, valor8,
                   anomes9, valor9,
                   anomes10, valor10,
                   anomes11, valor11,
                   anomes12, valor12
              FROM (SELECT vlrftbru##1 valor1,
                           decode(vlrftbru##1,
                                  0, 0,
                                  lpad(anoftbru##1, 4, '0') || lpad(mesftbru##1, 2, '0')) anomes1,
                           vlrftbru##2 valor2,
                           decode(vlrftbru##2,
                                  0, 0,
                                  lpad(anoftbru##2, 4, '0') || lpad(mesftbru##2, 2, '0')) anomes2,
                           vlrftbru##3 valor3,
                           decode(vlrftbru##3,
                                  0, 0,
                                  lpad(anoftbru##3, 4, '0') || lpad(mesftbru##3, 2, '0')) anomes3,
                           vlrftbru##4 valor4,
                           decode(vlrftbru##4,
                                  0, 0,
                                  lpad(anoftbru##4, 4, '0') || lpad(mesftbru##4, 2, '0')) anomes4,
                           vlrftbru##5 valor5,
                           decode(vlrftbru##5,
                                  0, 0,
                                  lpad(anoftbru##5, 4, '0') || lpad(mesftbru##5, 2, '0')) anomes5,
                           vlrftbru##6 valor6,
                           decode(vlrftbru##6,
                                  0, 0,
                                  lpad(anoftbru##6, 4, '0') || lpad(mesftbru##6, 2, '0')) anomes6,
                           vlrftbru##7 valor7,
                           decode(vlrftbru##7,
                                  0, 0,
                                  lpad(anoftbru##7, 4, '0') || lpad(mesftbru##7, 2, '0')) anomes7,
                           vlrftbru##8 valor8,
                         decode(vlrftbru##8,
                                0, 0,
                                lpad(anoftbru##8, 4, '0') || lpad(mesftbru##8, 2, '0')) anomes8,
                         vlrftbru##9 valor9,
                         decode(vlrftbru##9,
                                0, 0,
                                lpad(anoftbru##9, 4, '0') || lpad(mesftbru##9, 2, '0')) anomes9,
                         vlrftbru##10 valor10,
                         decode(vlrftbru##10,
                                0, 0,
                                lpad(anoftbru##10, 4, '0') || lpad(mesftbru##10, 2, '0')) anomes10,
                         vlrftbru##11 valor11,
                         decode(vlrftbru##11,
                                0, 0,
                                lpad(anoftbru##11, 4, '0') || lpad(mesftbru##11, 2, '0')) anomes11,
                         vlrftbru##12 valor12,
                         decode(vlrftbru##12,
                                0, 0,
                                lpad(anoftbru##12, 4, '0') || lpad(mesftbru##12, 2, '0')) anomes12
                    FROM crapjfn
                   WHERE cdcooper = pr_cdcooper
                     AND nrdconta = pr_nrdconta));

  -- Cursor com os dados do conjuge do cooperado
  CURSOR cr_crapcje (pr_cdcooper IN crapass.cdcooper%TYPE
	                  ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT cje.nrcpfcjg
          ,cje.vlsalari
      FROM crapcje cje
     WHERE cje.cdcooper = pr_cdcooper
       AND cje.nrdconta = pr_nrdconta;			
			 
  -- Dados da data da cooperativa logada
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;			 
				
	BEGIN
		-- Obter dados da data da cooperativa
		OPEN btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);
		FETCH btch0001.cr_crapdat INTO rw_crapdat;

		-- Se nao exisitir a data da cooperativa, obter critica e jogar para o log
		IF btch0001.cr_crapdat%NOTFOUND  THEN
			vr_cdcritic := 1;
			CLOSE btch0001.cr_crapdat;
			RAISE vr_exc_erro;
		END IF;

    CLOSE btch0001.cr_crapdat;

		-- Obtem o cooperado do lancamento
		OPEN cr_crapass (pr_cdcooper => pr_cdcooper
										,pr_nrdconta => pr_nrdconta);
		-- Salvar o PA e o tipo de pessoa
		FETCH cr_crapass INTO vr_cdagenci, vr_inpessoa;

		-- Desconsiderar e ir para o proximo se nao achar
		IF cr_crapass%NOTFOUND  THEN
			-- Fechar cursor
			CLOSE cr_crapass;
			-- Gerar cr�tica
			vr_cdcritic := 9;
			vr_dscritic := '';
			-- Levantar exce��o
			RAISE vr_exc_erro;
		END IF;
		-- Fechar cursor
		CLOSE cr_crapass;

		-- Limpar rendimento e lista de titulares
		vr_vlrendim := 0;
		vr_lscpfcgc := NULL;
		vr_flgconta := FALSE;

		-- Se pessoa fisica
		IF vr_inpessoa = 1 THEN

			-- Somar os rendimentos e juntar os CPF dos titulares
			FOR rw_crapttl IN cr_crapttl (pr_cdcooper => pr_cdcooper
																	 ,pr_nrdconta => pr_nrdconta) LOOP

				-- Somar o salario ao rendimento
				vr_vlrendim := vr_vlrendim + rw_crapttl.vldrendi + rw_crapttl.vlsalari;

				-- Guardar os CPF dos titulares
				IF  vr_lscpfcgc IS NULL  THEN
					vr_lscpfcgc := rw_crapttl.nrcpfcgc;
				ELSE
					vr_lscpfcgc := vr_lscpfcgc || ',' || rw_crapttl.nrcpfcgc;
				END IF;

			END LOOP;

			-- Separar os CPF em um array
			vr_vet_nrcpfcgc := gene0002.fn_quebra_string (pr_string  => vr_lscpfcgc
																									 ,pr_delimit => ',');

			-- Somar os rendimentos do conjuge mas desconsiderar os que sao titulares
			FOR rw_crapcje IN cr_crapcje (pr_cdcooper => pr_cdcooper
				                           ,pr_nrdconta => pr_nrdconta) LOOP

				-- Percorrer os CPFs dos titulares para verificar que nenhum deles seja o conjuge em questao
				FOR vr_ind IN 1 .. vr_vet_nrcpfcgc.COUNT LOOP

					-- Se o Conjuge tambem � titular, desconsiderar
					IF  rw_crapcje.nrcpfcjg = vr_vet_nrcpfcgc(vr_ind)  THEN
						vr_flgconta := TRUE;
						EXIT;
					END IF;

				END LOOP;

				-- Se o conjuge nao � titular, somar o salario
				IF  NOT vr_flgconta  THEN
					vr_vlrendim := vr_vlrendim + rw_crapcje.vlsalari;
				END IF;

			END LOOP;
		-- Se pessoa juridica
		ELSE
			-- Obter o ultimo periodo e valor do faturamento mensal
			OPEN cr_crapjfn (pr_cdcooper => pr_cdcooper
			                ,pr_nrdconta => pr_nrdconta);
			FETCH cr_crapjfn INTO vr_anomes, vr_vlfatmes;
      -- Fechar cursor
			CLOSE cr_crapjfn;

			-- Obter o faturamento anual da pessoa juridica
			OPEN cr_crapjur (pr_cdcooper => pr_cdcooper
			                ,pr_nrdconta => pr_nrdconta);
			FETCH cr_crapjur INTO vr_vlfatano;

			CLOSE cr_crapjur;

			-- Se a media do faturamento do ano for maior que o faturamento do
			-- ultimo mes, entao considerar esta media.
			IF  vr_vlfatano / 12 > vr_vlfatmes  THEN
				vr_vlrendim := vr_vlfatano / 12;
			ELSE -- Senao considerar o rendimento do ultimo faturamento
				vr_vlrendim := vr_vlfatmes;
			END IF;

		END IF;
		
		-- Atribui valor de rendimento ao parametro
		pr_vlrendim := vr_vlrendim;

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
      -- Efetuar rollback
      ROLLBACK;      
    WHEN OTHERS THEN      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := REPLACE(REPLACE('Nao foi possivel remover cheques do border�: ' || SQLERRM, chr(13)),chr(10));																			
			-- Efetuar Rollback
			ROLLBACK;				 
	END pc_calcular_rendas_faturamento;
	
	PROCEDURE pc_analisar_bordero_cheques(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
																			 ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da conta
																			 ,pr_cdagenci IN crapass.cdagenci%TYPE  --> Ag�ncia
																			 ,pr_idorigem IN INTEGER                --> Identificador de Origem
																			 ,pr_cdoperad IN crapope.cdoperad%TYPE  --> C�digo do Operador
																			 ,pr_nrborder IN crapabc.nrborder%TYPE  --> numero do bordero
																			 ,pr_tab_cheques IN OUT typ_tab_cheques --> PlTable com dados dos cheques
																			 ,pr_flganali IN INTEGER DEFAULT 1      --> Flag deve atualizar o status para analisado
																			 ,pr_cdcritic OUT PLS_INTEGER           --> C�d. da cr�tica
																			 ,pr_dscritic OUT VARCHAR2) IS          --> Descri��o da cr�tica
  /* .............................................................................
    Programa: pc_analisar_bordero_cheques
    Sistema : CECRED
    Autor   : Lucas Reinert
    Data    : Novembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para analisar cheques do bordero

    Alteracoes: -----
  ..............................................................................*/																			 
	-- Vari�vel de cr�ticas
	vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
	vr_dscritic        VARCHAR2(1000);        --> Desc. Erro        
	-- Tratamento de erros
	vr_exc_erro        EXCEPTION;    
	-- PlTable
	vr_tab_ocorrencias typ_tab_ocorrencias;
	vr_idx_ocorre PLS_INTEGER;
	vr_tab_lim_desconto typ_tab_lim_desconto;
	
	-- Vari�veis auxiliares
	vr_nrdconta_ver_cheque NUMBER;    -- Nr. da conta utilizada no retorno da procedure ver_cheque
	vr_dsdaviso VARCHAR2(1000);       -- Descri��o do aviso
	vr_inpessoa NUMBER;               -- Indicador de pessoa
	vr_dtprzmin DATE;                 -- Data prazo m�nimo
	vr_dtprzmax DATE;                 -- Data prazo m�ximo
	vr_dtdialim DATE;                 -- Data limite para desconto
	vr_qtredesc NUMBER;               -- Qtd de cheques redescontados
	vr_qtdevchq NUMBER;               -- Qtd de cheques devolvidos do emitente
	vr_qtdevchq_ass NUMBER;           -- Qtd de cheques devolvidos do emitente ao cooperado
	vr_vltotdev NUMBER;               -- Valor total devolvido
	vr_vltotdsc NUMBER;               -- Valor total desconto
	vr_vlperliq NUMBER;               -- Valor percentual de liquidez
	vr_vlrendim NUMBER;               -- Valor de rendimento do cooperado
	vr_przmxcmp NUMBER;               -- Data prazo m�ximo
	
    vr_nrcpfcgc NUMBER;
	
	-- Buscar todas as ocorrencias cadastradas
	CURSOR cr_ocorrencias IS
	  SELECT oco.flgbloqueio
		      ,oco.cdocorre 
					,oco.dsocorre
		  FROM tbdscc_ocorrencias oco;
	
	-- Buscar informa��es do associado		
	CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
	                 ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
		SELECT ass.inpessoa
		      ,ass.nrcpfcgc
					,substr(to_char(ass.nrcpfcgc),1,LENGTH(ass.nrcpfcgc)-6) raizcnpj
		  FROM crapass ass
		 WHERE ass.cdcooper = pr_cdcooper
		   AND ass.nrdconta = pr_nrdconta;			  
  rw_crapass cr_crapass%ROWTYPE;									
	
	-- Buscar �ltimo dia do ano
	CURSOR cr_dtultdia IS
	  SELECT add_months(TRUNC(SYSDATE, 'YYYY'), 12) - 1 dtultdia
		  FROM dual;
	
	 -- Verificar se o cheque n�o est� em outro border�
	 CURSOR cr_crapcdb(pr_cdcooper IN crapcdb.cdcooper%TYPE
	                  ,pr_cdcmpchq IN crapcdb.cdcmpchq%TYPE
										,pr_cdbanchq IN crapcdb.cdbanchq%TYPE
										,pr_cdagechq IN crapcdb.cdagechq%TYPE
										,pr_nrctachq IN crapcdb.nrctachq%TYPE
										,pr_nrcheque IN crapcdb.nrcheque%TYPE
										,pr_nrborder IN crapcdb.nrborder%TYPE
										,pr_dtmvtolt IN crapcdb.dtmvtolt%TYPE) IS
		 SELECT cdb.nrdconta
		       ,cdb.nrborder
		   FROM crapcdb cdb
		  WHERE cdb.cdcooper = pr_cdcooper
		    AND cdb.cdcmpchq = pr_cdcmpchq 
		    AND cdb.cdbanchq = pr_cdbanchq 
		    AND cdb.cdagechq = pr_cdagechq 
		    AND cdb.nrctachq = pr_nrctachq 
		    AND cdb.nrcheque = pr_nrcheque 
			  AND cdb.nrborder <> pr_nrborder
			  AND cdb.dtlibera >= pr_dtmvtolt
		    AND cdb.dtdevolu IS NULL
        AND cdb.dtlibbdc IS NOT NULL;
	rw_crapcdb cr_crapcdb%ROWTYPE;
	
	-- Buscar cadastro de emitentes de cheques
	CURSOR cr_crapcec (pr_cdcooper IN crapcec.cdcooper%TYPE,
										 pr_cdcmpchq IN crapcec.cdcmpchq%TYPE, 
										 pr_cdbanchq IN crapcec.cdbanchq%TYPE,
										 pr_cdagechq IN crapcec.cdagechq%TYPE,
										 pr_nrctachq IN crapcec.nrctachq%TYPE,
										 pr_nrcpfcgc IN crapcec.nrcpfcgc%TYPE)IS
		SELECT cec.nrcpfcgc
          ,substr(to_char(cec.nrcpfcgc),1,LENGTH(cec.nrcpfcgc)-6) raizcnpj
			FROM crapcec cec
		 WHERE cec.cdcooper = pr_cdcooper
			 AND cec.cdcmpchq = pr_cdcmpchq
			 AND cec.cdbanchq = pr_cdbanchq
			 AND cec.cdagechq = pr_cdagechq
			 AND cec.nrctachq = pr_nrctachq
			 AND cec.nrdconta = 0
			 AND cec.nrcpfcgc = pr_nrcpfcgc;
	rw_crapcec  cr_crapcec%ROWTYPE;

  -- Verificar se o emitente � titular da conta
  CURSOR cr_crapttl(pr_cdcooper IN crapttl.cdcooper%TYPE
	                 ,pr_nrdconta IN crapttl.nrdconta%TYPE
									 ,pr_nrcpfcgc IN crapttl.nrcpfcgc%TYPE) IS
		SELECT 1
		  FROM crapttl ttl
		 WHERE ttl.cdcooper = pr_cdcooper
		   AND ttl.nrdconta = pr_nrdconta
			 AND ttl.nrcpfcgc = pr_nrcpfcgc;
	rw_crapttl cr_crapttl%ROWTYPE;
	
	-- Verificar se o emitente � conjuge do titular da conta
	CURSOR cr_crapcje(pr_cdcooper IN crapttl.cdcooper%TYPE
	                 ,pr_nrdconta IN crapttl.nrdconta%TYPE
                   ,pr_nrctacje IN crapcje.nrctacje%TYPE
									 ,pr_nrcpfcgc IN crapttl.nrcpfcgc%TYPE) IS
	  SELECT 1
		  FROM crapcje cje
		 WHERE cje.cdcooper = pr_cdcooper
		   AND cje.nrdconta = pr_nrdconta
       AND (cje.nrctacje = pr_nrctacje
			  OR cje.nrcpfcjg = pr_nrcpfcgc);
	rw_crapcje cr_crapcje%ROWTYPE;
	
  CURSOR cr_crapavt(pr_cdcooper IN crapttl.cdcooper%TYPE
	                 ,pr_nrdconta IN crapttl.nrdconta%TYPE
                   ,pr_nrdctato IN crapavt.nrdctato%TYPE
									 ,pr_nrcpfcgc IN crapttl.nrcpfcgc%TYPE) IS
    SELECT 1
      FROM crapavt avt
     WHERE avt.cdcooper = pr_cdcooper
       AND avt.nrdconta = pr_nrdconta
       AND (avt.nrdctato = pr_nrdctato
        OR avt.nrcpfcgc = pr_nrcpfcgc)
       AND avt.tpctrato = 6
       AND avt.dsproftl = 'SOCIO/PROPRIETARIO';
	rw_crapavt cr_crapavt%ROWTYPE;
  
	-- Verificar se o emitente possui preju�zo
	CURSOR cr_crapepr_prj(pr_cdcooper IN crapass.cdcooper%TYPE
	                     ,pr_nrdconta IN crapass.nrcpfcgc%TYPE) IS
		SELECT 1
		  FROM crapepr epr
     WHERE epr.cdcooper = pr_cdcooper
		   AND epr.nrdconta = pr_nrdconta
       AND epr.inliquid = 1
       AND epr.inprejuz = 1
       AND epr.vlsdprej > 0; 
	rw_crapepr_prj cr_crapepr_prj%ROWTYPE;
	
	-- Verificar se o emitente possui borderos de desconto de cheque com cheques do cooperado
	-- que est� descontando
	CURSOR cr_crapcdb_emi(pr_cdcooper IN crapcdb.cdcooper%TYPE
	                     ,pr_nrdconta IN crapcdb.nrdconta%TYPE
											 ,pr_nrborder IN crapcdb.nrborder%TYPE
	                     ,pr_dtmvtolt IN crapcdb.dtlibera%TYPE) IS
		SELECT 1
		  FROM crapcdb cdb
		 WHERE cdb.cdcooper = pr_cdcooper
			 AND cdb.nrdconta = pr_nrdconta
			 AND cdb.nrborder = pr_nrborder
			 AND cdb.cdbanchq = 85
			 AND cdb.inchqcop = 1
			 AND cdb.nrctachq IN (SELECT cdb2.nrdconta FROM crapcdb cdb2
														 WHERE cdb2.cdcooper = cdb.cdcooper
															 AND cdb2.nrdconta = cdb.nrctachq
															 AND cdb2.dtlibera >= pr_dtmvtolt
															 AND cdb2.cdbanchq = 85
															 AND cdb2.inchqcop = 1 
															 AND cdb2.nrctachq = cdb.nrdconta);
  rw_crapcdb_emi cr_crapcdb_emi%ROWTYPE;
	
	-- Verificar quantidade de vezes que o cheque foi redescontado
  CURSOR cr_qtd_redesconto (pr_cdcooper IN crapcdb.cdcooper%TYPE
	                         ,pr_cdcmpchq IN crapcdb.cdcmpchq%TYPE
													 ,pr_cdbanchq IN crapcdb.cdbanchq%TYPE
													 ,pr_cdagechq IN crapcdb.cdagechq%TYPE
													 ,pr_nrctachq IN crapcdb.nrctachq%TYPE
													 ,pr_nrcheque IN crapcdb.nrcheque%TYPE
													 ,pr_nrborder IN crapcdb.nrborder%TYPE) IS	
		 SELECT COUNT(*)
		   FROM crapcdb cdb
		  WHERE cdb.cdcooper = pr_cdcooper
		    AND cdb.cdcmpchq = pr_cdcmpchq
		    AND cdb.cdbanchq = pr_cdbanchq
		    AND cdb.cdagechq = pr_cdagechq
		    AND cdb.nrctachq = pr_nrctachq
		    AND cdb.nrcheque = pr_nrcheque
			  AND cdb.nrborder <> pr_nrborder
			  AND cdb.insitchq IN (1,2);

  -- Somar quantidade de cheques devolvidos do emitente
  CURSOR cr_qtchqdev_emi(pr_cdcooper IN crapcec.cdcooper%TYPE
	                      ,pr_nrcpfcgc IN crapcec.nrcpfcgc%TYPE) IS
	  SELECT nvl(SUM(cec.qtchqdev),0)
		  FROM crapcec cec
		 WHERE cec.cdcooper = pr_cdcooper
		   AND cec.nrcpfcgc = pr_nrcpfcgc
		   AND cec.nrdconta = 0;
	
	-- Verificar se cooperado possui cheques devolvidos do emitente do cheque
	CURSOR cr_qtchqdev_emi_ass(pr_cdcooper IN craplcm.cdcooper%TYPE
	                          ,pr_nrdconta IN craplcm.nrdconta%TYPE
	                          ,pr_cdcmpchq IN crapcdb.cdcmpchq%TYPE
													  ,pr_cdbanchq IN crapcdb.cdbanchq%TYPE
													  ,pr_cdagechq IN crapcdb.cdagechq%TYPE
													  ,pr_nrctachq IN crapcdb.nrctachq%TYPE
													  ,pr_nrcheque IN crapcdb.nrcheque%TYPE) IS	
		SELECT COUNT(*) 
			FROM craplcm lcm
		 WHERE lcm.cdcooper = pr_cdcooper
			 AND lcm.nrdconta = pr_nrdconta
			 AND lcm.cdcmpchq = pr_cdcmpchq
			 AND lcm.cdbanchq = pr_cdbanchq
			 AND lcm.cdagechq = pr_cdagechq
			 AND lcm.nrctachq = pr_nrctachq
			 AND lcm.nrdocmto IN (pr_nrcheque, pr_nrcheque + 1000000)
			 AND lcm.cdhistor IN (24,27,399,351,657);			
			 
  -- Verificar se o cheque ainda est� pendente de entrega
	CURSOR cr_crapdcc(pr_cdcooper IN crapdcc.cdcooper%TYPE
									 ,pr_nrdconta IN crapdcc.nrdconta%TYPE
									 ,pr_cdcmpchq IN crapdcc.cdcmpchq%TYPE
									 ,pr_cdbanchq IN crapdcc.cdbanchq%TYPE
									 ,pr_cdagechq IN crapdcc.cdagechq%TYPE
									 ,pr_nrctachq IN crapdcc.nrctachq%TYPE
									 ,pr_nrcheque IN crapdcc.nrcheque%TYPE
									 ,pr_nrborder IN crapdcc.nrborder%TYPE
									 ,pr_nrremret in crapdcc.nrremret%TYPE) IS	
	  SELECT 1
		  FROM crapdcc dcc
			    ,craphcc hcc
		 WHERE dcc.cdcooper = pr_cdcooper
		   AND dcc.cdcmpchq = pr_cdcmpchq 
		   AND dcc.cdbanchq = pr_cdbanchq 
		   AND dcc.cdagechq = pr_cdagechq 
		   AND dcc.nrctachq = pr_nrctachq 
		   AND dcc.nrcheque = pr_nrcheque 
			 AND dcc.nrborder = pr_nrborder
			 AND dcc.nrremret = pr_nrremret
			 AND dcc.intipmvt IN (1,3)
			 AND dcc.cdtipmvt = 1
			 AND hcc.cdcooper = dcc.cdcooper
			 AND hcc.nrdconta = dcc.nrdconta
			 AND hcc.nrremret = dcc.nrremret
			 AND hcc.intipmvt = dcc.intipmvt
 			 AND (dcc.inconcil = 0
			  OR  hcc.dtcustod IS NULL);
  rw_crapdcc cr_crapdcc%ROWTYPE;
	
  -- Verificar se j� existe a ocorr�ncia gravada na crapabc	
	CURSOR cr_crapabc(pr_cdcooper IN crapabc.cdcooper%TYPE
	                 ,pr_nrdconta IN crapabc.nrdconta%TYPE
									 ,pr_nrborder IN crapabc.nrborder%TYPE
									 ,pr_cdcmpchq IN crapabc.cdcmpchq%TYPE
									 ,pr_cdbanchq IN crapabc.cdbanchq%TYPE
									 ,pr_cdagechq IN crapabc.cdagechq%TYPE
									 ,pr_nrctachq IN crapabc.nrctachq%TYPE
									 ,pr_nrcheque IN crapabc.nrcheque%TYPE
									 ,pr_cdocorre IN crapabc.cdocorre%TYPE) IS
		SELECT 1 
		  FROM crapabc abc
		 WHERE abc.cdcooper = pr_cdcooper
			 AND abc.nrdconta = pr_nrdconta
			 AND abc.nrborder = pr_nrborder
			 AND abc.cdcmpchq = pr_cdcmpchq 
			 AND abc.cdbanchq = pr_cdbanchq 
			 AND abc.cdagechq = pr_cdagechq 
			 AND abc.nrctachq = pr_nrctachq 
			 AND abc.nrcheque = pr_nrcheque 
			 AND abc.cdocorre = pr_cdocorre;				 
  rw_crapabc cr_crapabc%ROWTYPE;

  -- Buscar valor total devolvido
	CURSOR cr_craplcm_dev(pr_cdcooper IN craplcm.cdcooper%TYPE
	                     ,pr_nrdconta IN craplcm.nrdconta%TYPE
											 ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
											 ,pr_qtmesliq IN INTEGER) IS
		SELECT nvl(SUM(lcm.vllanmto),0)
		  FROM craplcm lcm
		 WHERE lcm.cdcooper = pr_cdcooper
		   AND lcm.nrdconta = pr_nrdconta
			 AND lcm.dtmvtolt >= add_months(pr_dtmvtolt, (pr_qtmesliq * -1))
			 AND lcm.cdhistor = 399;
			 
  -- Buscar valor total descontado
	CURSOR cr_crapcdb_dsc(pr_cdcooper IN craplcm.cdcooper%TYPE
	                     ,pr_nrdconta IN craplcm.nrdconta%TYPE
											 ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
											 ,pr_qtmesliq IN INTEGER) IS
		SELECT nvl(SUM(cdb.vlcheque),0)
		  FROM crapcdb cdb
		 WHERE cdb.cdcooper = pr_cdcooper
		   AND cdb.nrdconta = pr_nrdconta
			 AND cdb.dtmvtolt >= add_months(pr_dtmvtolt, (pr_qtmesliq * -1))
			 AND cdb.insitchq > 0;
			 
	-- Buscar limite de desconto de cheque
	CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE
	                 ,pr_nrdconta IN craplim.nrdconta%TYPE) IS
		SELECT lim.vllimite
		  FROM craplim lim
		 WHERE lim.cdcooper = pr_cdcooper
		   AND lim.nrdconta = pr_nrdconta
			 AND lim.tpctrlim = 2
		   AND lim.insitlim = 2;
	rw_craplim cr_craplim%ROWTYPE;
	
	-- Buscar informa��es do border�
	CURSOR cr_crapbdc(pr_cdcooper IN crapbdc.cdcooper%TYPE
	                 ,pr_nrdconta IN crapbdc.nrdconta%TYPE
									 ,pr_nrborder IN crapbdc.nrborder%TYPE) IS
		SELECT bdc.dhdassin
		      ,bdc.flgassin
			FROM crapbdc bdc
		 WHERE bdc.cdcooper = pr_cdcooper
		   AND bdc.nrdconta = pr_nrdconta
			 AND bdc.nrborder = pr_nrborder;
	rw_crapbdc cr_crapbdc%ROWTYPE;
  
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
	
  PROCEDURE pc_gerar_ocorrencia_chq(pr_tab_cheques IN OUT typ_tab_cheques
		                               ,pr_idx_cheques IN NUMBER
																	 ,pr_cdocorre IN crapabc.cdocorre%TYPE
																	 ,pr_dsrestri IN crapabc.dsrestri%TYPE DEFAULT NULL 
																	 ,pr_dsdetres IN  crapabc.dsdetres%TYPE DEFAULT NULL) IS
		BEGIN
		pr_tab_cheques(pr_idx_cheques).ocorrencias(pr_cdocorre).flbloque := vr_tab_ocorrencias(pr_cdocorre).flbloque;
		pr_tab_cheques(pr_idx_cheques).ocorrencias(pr_cdocorre).cdocorre := pr_cdocorre;
		pr_tab_cheques(pr_idx_cheques).ocorrencias(pr_cdocorre).dsrestri := CASE WHEN pr_dsrestri IS NULL THEN 
		                                                                      vr_tab_ocorrencias(pr_cdocorre).dsrestri
																																				ELSE
																																					pr_dsrestri
																																				END;
		pr_tab_cheques(pr_idx_cheques).ocorrencias(pr_cdocorre).dsdetres := CASE WHEN pr_dsdetres IS NULL THEN 
		                                                                      ' '
																																				ELSE
																																					pr_dsdetres
																																				END;		
		
		-- ao criar registro de ocorr�ncia, verificar se a ocorr�ncia gera bloqueio na an�lise;
		IF vr_tab_ocorrencias(pr_cdocorre).flbloque = 1 THEN
			pr_tab_cheques(pr_idx_cheques).flgaprov := 1;
		END IF;		
		
		EXCEPTION
			WHEN OTHERS THEN
				vr_cdcritic := 0;
				vr_dscritic := 'Erro ao gerar ocorr�ncia para o cheque: ' || SQLERRM;
				RAISE vr_exc_erro;		
  END pc_gerar_ocorrencia_chq;

  PROCEDURE pc_gerar_ocorrencia_bordero(pr_cdocorre IN crapabc.cdocorre%TYPE
																			 ,pr_dsrestri IN crapabc.dsrestri%TYPE
																			 ,pr_dsdetres IN crapabc.dsdetres%TYPE) IS
																			 
  BEGIN
		INSERT INTO crapabc 			
						 (cdcooper, 
							nrdconta, 
							nrborder, 
							cdcmpchq, 
							cdbanchq, 
							cdagechq, 
							nrctachq, 
							nrcheque, 
							cdocorre,							
							dsrestri,
							dsdetres,
							flaprcoo,
							cdoperad)
			VALUES (pr_cdcooper, 
							pr_nrdconta, 
							pr_nrborder, 
							0, -- cdcmpchq, 
							0, -- cdbanchq, 
							0, -- cdagechq, 
							0, -- nrctachq, 
							0, -- nrcheque, 
							pr_cdocorre,					
							pr_dsrestri,
							NVL(pr_dsdetres,' '),
							0,
							pr_cdoperad);
							
	EXCEPTION
		WHEN OTHERS THEN
			vr_cdcritic := 0;
			vr_dscritic := 'Erro ao gerar ocorr�ncia para o border�: ' || SQLERRM;
			RAISE vr_exc_erro;
  END pc_gerar_ocorrencia_bordero;
	
  PROCEDURE pc_limpar_ocorrencias_bordero IS
																			 
  BEGIN
    
		DELETE 
      FROM crapabc
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrborder = pr_nrborder;
       							
	EXCEPTION
		WHEN OTHERS THEN
			vr_cdcritic := 0;
			vr_dscritic := 'Erro ao limpar ocorr�ncias do border�: ' || SQLERRM;
			RAISE vr_exc_erro;
  END pc_limpar_ocorrencias_bordero;
	
	FUNCTION fn_busca_ocorre(pr_cdcritic IN PLS_INTEGER) RETURN INTEGER IS
	BEGIN
		-- Retorno ver_cheque -> ocorr�ncias de desconto de cheque
		CASE pr_cdcritic
			WHEN 9 THEN
				RETURN 27; -- Conta do Cheque Inv�lida;
			WHEN 97 THEN
				RETURN 28; -- Cheque ja compensado;
			WHEN 121 THEN
				RETURN 29; -- Cheque do custodiante;
			WHEN 108 THEN
				RETURN 30; -- Talon�rio n�o emitido;
			WHEN 109 THEN
				RETURN 31; -- Talon�rio n�o retirado;
			WHEN 96 THEN
				RETURN 32; -- Cheque com contra-ordem;
			WHEN 101 THEN
				RETURN 33; -- Cheque com contra-ordem;
			WHEN 320 THEN
				RETURN 34; -- Cheque cancelado;
			WHEN 646 THEN
				RETURN 35; -- Cheque transfer�ncia (TB);
			WHEN 286 THEN
				RETURN 36; -- Cheque sal�rio n�o existe;
			WHEN 91 THEN
				RETURN 37; -- Valor do cheque errado;
			WHEN 950 THEN
				RETURN 38; -- Cheque cst/descto em outra IF;
			WHEN 95 THEN
				RETURN 39; -- Conta bloqueada/exclu�da;
			WHEN 410 THEN
				RETURN 40; -- Conta bloqueada/exclu�da;
			ELSE
				RETURN 99; -- Erro Valida��o;
		END CASE;
	END fn_busca_ocorre;
	
  BEGIN	
		-- Busca a data do sistema
		OPEN  BTCH0001.cr_crapdat(pr_cdcooper);
		FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
		CLOSE BTCH0001.cr_crapdat;
				
		-- Criar record com todas as ocorrencias de an�lise; (TBDSCC_OCORRENCIAS);
		FOR rw_ocorrencias IN cr_ocorrencias LOOP
			vr_tab_ocorrencias(rw_ocorrencias.cdocorre).flbloque := rw_ocorrencias.flgbloqueio;
			vr_tab_ocorrencias(rw_ocorrencias.cdocorre).dsrestri := rw_ocorrencias.dsocorre;
		END LOOP;	
		
    -- Limpa os registros de ocorrencias no border�
    pc_limpar_ocorrencias_bordero;
    
		-- Buscar associado
		OPEN cr_crapass(pr_cdcooper => pr_cdcooper
		               ,pr_nrdconta => pr_nrdconta);
		FETCH cr_crapass INTO rw_crapass;

    -- Associado n�o encontrado				
		IF cr_crapass%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_crapass;
			-- Gerar cr�ticas
			vr_cdcritic := 9;
			-- Levantar exce��o
			RAISE vr_exc_erro;
		END IF;
		
		-- Fechar cursor
		CLOSE cr_crapass;

    -- Atribuir indicador de pessoa a variavel
    vr_inpessoa := rw_crapass.inpessoa;

    -- Buscar informa��es de limite de desconto		
		pc_busca_tab_limdescont(pr_cdcooper => pr_cdcooper
		                       ,pr_inpessoa => vr_inpessoa
													 ,pr_tab_lim_desconto => vr_tab_lim_desconto
													 ,pr_cdcritic => vr_cdcritic
													 ,pr_dscritic => vr_dscritic);
		
		-- Se houve cr�tica
		IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			-- Levantar exce��o
			RAISE vr_exc_erro;
		END IF;
		
		-- Busca pr�ximo dia �til
		vr_dtprzmin := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
																						  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
																						  ,pr_tipo => 'P');
    -- Atribui prazo m�ximo
    vr_dtprzmax := rw_crapdat.dtmvtolt + vr_tab_lim_desconto(vr_inpessoa).qtprzmax;
		
    vr_przmxcmp := vr_tab_lim_desconto(vr_inpessoa).Przmxcmp;
		
		-- Busca �ltimo dia do ano
		OPEN cr_dtultdia;
		FETCH cr_dtultdia INTO vr_dtdialim;
		CLOSE cr_dtultdia;
		
		-- Busca data limite
		vr_dtdialim := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
																						  ,pr_dtmvtolt => vr_dtdialim
																						  ,pr_tipo => 'A');

		-- Se n�o encontrar nenhum registro na PlTable
		IF pr_tab_cheques.count = 0 THEN
			-- Gerar cr�tica
			vr_cdcritic := 0;
			vr_dscritic := 'Cheques para an�lise n�o encontrados.';
			-- Levanta exce��o
			RAISE vr_exc_erro;
		END IF;
		-- Percorrer todos os cheques do bordero
    FOR vr_index IN pr_tab_cheques.first..pr_tab_cheques.last LOOP
			
		  -- Verificar Cheque
			CUST0001.pc_ver_cheque(pr_cdcooper => pr_cdcooper
			                      ,pr_nrcustod => pr_nrdconta
														,pr_cdbanchq => pr_tab_cheques(vr_index).cdbanchq
														,pr_cdagechq => pr_tab_cheques(vr_index).cdagechq
														,pr_nrctachq => pr_tab_cheques(vr_index).nrctachq
														,pr_nrcheque => pr_tab_cheques(vr_index).nrcheque
														,pr_nrddigc3 => 1
														,pr_vlcheque => pr_tab_cheques(vr_index).vlcheque
														,pr_nrdconta => vr_nrdconta_ver_cheque
														,pr_dsdaviso => vr_dsdaviso
														,pr_cdcritic => vr_cdcritic
														,pr_dscritic => vr_dscritic);
														
			-- Se retornou c�digo da cr�tica
			IF vr_cdcritic > 0 OR trim(vr_dscritic) IS NOT NULL THEN
	      -- Gerar ocorrencia #cdocorre - Cr�tica retornada da ver_cheque
				pc_gerar_ocorrencia_chq(pr_tab_cheques => pr_tab_cheques
				                       ,pr_idx_cheques => vr_index
															 ,pr_cdocorre => fn_busca_ocorre(vr_cdcritic)
															 ,pr_dsrestri => NULL
															 ,pr_dsdetres => vr_dscritic);
			END IF;
													
		  -- Verificar prazo m�nimo excedido
	    IF pr_tab_cheques(vr_index).dtlibera <= vr_dtprzmin THEN
		    -- Gerar ocorrencia 5 - Data de liberacao fora do limite
				pc_gerar_ocorrencia_chq(pr_tab_cheques => pr_tab_cheques
				                       ,pr_idx_cheques => vr_index
															 ,pr_cdocorre => 5
															 ,pr_dsrestri => 'Prazo minimo excedido'
															 ,pr_dsdetres =>  to_char(vr_tab_lim_desconto(vr_inpessoa).qtprzmin) || ' dias.');
			END IF;
			
			-- Verificar prazo m�ximo excedido
			IF pr_tab_cheques(vr_index).dtlibera >= vr_dtprzmax THEN
		    -- Gerar ocorrencia 5 - Data de liberacao fora do limite
				pc_gerar_ocorrencia_chq(pr_tab_cheques => pr_tab_cheques
				                       ,pr_idx_cheques => vr_index
															 ,pr_cdocorre => 5
															 ,pr_dsrestri => 'Prazo m�ximo excedido'
															 ,pr_dsdetres =>  to_char(vr_tab_lim_desconto(vr_inpessoa).qtprzmax) || ' dias.');
			END IF;
		
      -- Prazo m�ximo de compensa��o excedido
      IF (pr_tab_cheques(vr_index).dtlibera - nvl(pr_tab_cheques(vr_index).dtdcaptu, pr_tab_cheques(vr_index).dtmvtolt)) > vr_przmxcmp THEN
		    -- Gerar ocorrencia 5 - Data de liberacao fora do limite
				pc_gerar_ocorrencia_chq(pr_tab_cheques => pr_tab_cheques
				                       ,pr_idx_cheques => vr_index
															 ,pr_cdocorre => 12
															 ,pr_dsrestri => NULL
															 ,pr_dsdetres => NULL);
			END IF;
			
		  -- N�o permite data de pagamento para o �ltimo dia do ano
		  IF pr_tab_cheques(vr_index).dtlibera = vr_dtdialim THEN
         -- Gerar ocorrencia 16 - Data de liberacao ultimo dia do ano
			   pc_gerar_ocorrencia_chq(pr_tab_cheques => pr_tab_cheques
				                       ,pr_idx_cheques => vr_index
															 ,pr_cdocorre => 16
															 ,pr_dsrestri => NULL
															 ,pr_dsdetres => NULL);
			END IF;
			
			-- N�o permitir a inclus�o de cheques para os bancos 012, 231, 353, 356, 409 e 479
			IF substr(pr_tab_cheques(vr_index).dsdocmc7,01,03) IN ('012','231','353','356','409','479') THEN
		     -- Gerar ocorrencia 17 - Banco nao permitido
				 pc_gerar_ocorrencia_chq(pr_tab_cheques => pr_tab_cheques
																,pr_idx_cheques => vr_index
																,pr_cdocorre => 17
																,pr_dsrestri => NULL
																,pr_dsdetres => substr(pr_tab_cheques(vr_index).dsdocmc7,01,03));

			END IF;
			
			-- Verificar se o cheque � fraudado
      CHEQ0001.pc_ver_fraude_chq_extern(pr_cdcooper => pr_tab_cheques(vr_index).cdcooper
			                                 ,pr_cdprogra => 'DSCC0001'
																			 ,pr_cdbanco =>  pr_tab_cheques(vr_index).cdbanchq
																			 ,pr_nrcheque => pr_tab_cheques(vr_index).nrcheque
																			 ,pr_nrctachq => pr_tab_cheques(vr_index).nrctachq
																			 ,pr_cdoperad => pr_cdoperad
																			 ,pr_cdagenci => pr_cdagenci
																			 ,pr_des_erro => vr_dscritic);
																			 
      -- Se retornou cr�tica
			IF TRIM(vr_dscritic) IS NOT NULL THEN
	      -- Gerar ocorrencia 18 - Cheque fraudado
				pc_gerar_ocorrencia_chq(pr_tab_cheques => pr_tab_cheques
															 ,pr_idx_cheques => vr_index
															 ,pr_cdocorre => 18
															 ,pr_dsrestri => NULL
															 ,pr_dsdetres => NULL);
			END IF;
			
			-- Verificar se cheque foi inserido mais de uma vez na collection
			<<verfica_chq_bordero>>
			FOR vr_index_2 IN pr_tab_cheques.first..pr_tab_cheques.last LOOP
				IF vr_index <> vr_index_2 THEN
					-- Se cheque j� existe no border�
					IF pr_tab_cheques(vr_index).cdcmpchq = pr_tab_cheques(vr_index_2).cdcmpchq AND
						 pr_tab_cheques(vr_index).cdbanchq = pr_tab_cheques(vr_index_2).cdbanchq AND
						 pr_tab_cheques(vr_index).cdagechq = pr_tab_cheques(vr_index_2).cdagechq AND
						 pr_tab_cheques(vr_index).nrctachq = pr_tab_cheques(vr_index_2).nrctachq AND
						 pr_tab_cheques(vr_index).nrcheque = pr_tab_cheques(vr_index_2).nrcheque THEN
					   -- Gerar ocorrencia 20 -- Cheque j� existe no border�
						 pc_gerar_ocorrencia_chq(pr_tab_cheques => pr_tab_cheques
																		,pr_idx_cheques => vr_index
																		,pr_cdocorre => 20
																		,pr_dsrestri => NULL
																		,pr_dsdetres => NULL);
						 EXIT verfica_chq_bordero;
				  END IF;
				END IF;
			END LOOP verfica_chq_bordero;
 
      -- Verificar se cheque est� em outro border�
      OPEN cr_crapcdb(pr_cdcooper => pr_cdcooper
			               ,pr_cdcmpchq => pr_tab_cheques(vr_index).cdcmpchq
										 ,pr_cdbanchq => pr_tab_cheques(vr_index).cdbanchq
										 ,pr_cdagechq => pr_tab_cheques(vr_index).cdagechq
										 ,pr_nrctachq => pr_tab_cheques(vr_index).nrctachq
										 ,pr_nrcheque => pr_tab_cheques(vr_index).nrcheque
										 ,pr_nrborder => pr_nrborder
                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
			FETCH cr_crapcdb INTO rw_crapcdb;
			
			-- Se encontrou est� em outro border�
			IF cr_crapcdb%FOUND THEN
				-- Gerar ocorrencia 21 - Cheque j� est� em desconto
				pc_gerar_ocorrencia_chq(pr_tab_cheques => pr_tab_cheques
															 ,pr_idx_cheques => vr_index
															 ,pr_cdocorre => 21
															 ,pr_dsrestri => NULL
															 ,pr_dsdetres => 'Conta: ' || rw_crapcdb.nrdconta || 
															                 ' - Border�: ' || rw_crapcdb.nrborder );
			END IF;
			-- Fechar cursor
			CLOSE cr_crapcdb;
			
      IF pr_tab_cheques(vr_index).cdbanchq <> 85 THEN
			
			-- Buscar emitente do cheque
			OPEN cr_crapcec(pr_cdcooper => pr_cdcooper
			               ,pr_cdcmpchq => pr_tab_cheques(vr_index).cdcmpchq
						   ,pr_cdbanchq => pr_tab_cheques(vr_index).cdbanchq
						   ,pr_cdagechq => pr_tab_cheques(vr_index).cdagechq
						   ,pr_nrctachq => pr_tab_cheques(vr_index).nrctachq
						   ,pr_nrcpfcgc => pr_tab_cheques(vr_index).nrcpfcgc);
			FETCH cr_crapcec INTO rw_crapcec;
			
			-- Se n�o encontrar emitente
        IF cr_crapcec%NOTFOUND THEN
          
          -- Fechar cursor
			    CLOSE cr_crapcec;
          
          -- Variavel auxiliar
          vr_nrcpfcgc := 0;
          
			  -- Gerar ocorrencia 22 - Emitente n�o cadastrado
				pc_gerar_ocorrencia_chq(pr_tab_cheques => pr_tab_cheques
															 ,pr_idx_cheques => vr_index
															 ,pr_cdocorre => 22
															 ,pr_dsrestri => NULL
															 ,pr_dsdetres => NULL);
        ELSE
          
			-- Fechar cursor
			CLOSE cr_crapcec;
          
          -- Variavel auxiliar
          vr_nrcpfcgc := rw_crapcec.nrcpfcgc; 
			    
			-- CPF/CNPJ do emitente � o mesmo do cooperado
	    IF rw_crapcec.nrcpfcgc = rw_crapass.nrcpfcgc THEN
				-- Gerar ocorrencia 23 - Cheque possui CPF/CNPJ do cooperado
				pc_gerar_ocorrencia_chq(pr_tab_cheques => pr_tab_cheques
															 ,pr_idx_cheques => vr_index
															 ,pr_cdocorre => 23
															 ,pr_dsrestri => NULL
															 ,pr_dsdetres => NULL);
			END IF;		
          	
      -- Se n�o for pf
			IF rw_crapass.inpessoa <> 1 THEN
				-- Verificar se a raiz do CNPJ do cheque � o mesmo do cooperado
				IF rw_crapass.raizcnpj = rw_crapcec.raizcnpj THEN
					-- Gerar ocorrencia 23 - Cheque possui CPF/CNPJ do cooperado
					pc_gerar_ocorrencia_chq(pr_tab_cheques => pr_tab_cheques
																 ,pr_idx_cheques => vr_index
																 ,pr_cdocorre => 23
																 ,pr_dsrestri => NULL
																 ,pr_dsdetres => NULL);
					
				END IF;
        
        -- Verificar se Emitente � Conjugue do Cooperado
        IF vr_tab_lim_desconto(vr_inpessoa).flemipar = 1 THEN
          -- Verificar se o emitente � conjuge de algum titular da conta
          OPEN cr_crapavt(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrdctato => pr_tab_cheques(vr_index).nrctachq
                         ,pr_nrcpfcgc => rw_crapcec.nrcpfcgc);
          FETCH cr_crapavt INTO rw_crapavt;
  					
          -- Se encontrou
          IF cr_crapavt%FOUND THEN
            -- Gerar ocorrencia 11 - Emitente � s�cio do cooperado
            pc_gerar_ocorrencia_chq(pr_tab_cheques => pr_tab_cheques
                                   ,pr_idx_cheques => vr_index
                                   ,pr_cdocorre => 11
                                   ,pr_dsrestri => NULL
                                   ,pr_dsdetres => NULL);

          END IF;
          -- Fechar cursor
          CLOSE cr_crapavt;
        END IF;
        
			ELSE
        -- Verificar CPF/CNPJ se o emitente � algum titular da conta
				OPEN cr_crapttl(pr_cdcooper => pr_cdcooper
				               ,pr_nrdconta => pr_nrdconta
											 ,pr_nrcpfcgc => rw_crapcec.nrcpfcgc);
				FETCH cr_crapttl INTO rw_crapttl;
				
				-- Se encontrou
				IF cr_crapttl%FOUND THEN
					-- Gerar ocorrencia 24 - Emitente � segundo/terceiro titular
					pc_gerar_ocorrencia_chq(pr_tab_cheques => pr_tab_cheques
																 ,pr_idx_cheques => vr_index
																 ,pr_cdocorre => 24
																 ,pr_dsrestri => NULL
																 ,pr_dsdetres => NULL);

				END IF;
				-- Fechar cursor
				CLOSE cr_crapttl;
				-- Verificar se Emitente � Conjugue do Cooperado
				IF vr_tab_lim_desconto(vr_inpessoa).flemipar = 1 THEN
					-- Verificar se o emitente � conjuge de algum titular da conta
					OPEN cr_crapcje(pr_cdcooper => pr_cdcooper
												 ,pr_nrdconta => pr_nrdconta
                         ,pr_nrctacje => pr_tab_cheques(vr_index).nrctachq
												 ,pr_nrcpfcgc => rw_crapcec.nrcpfcgc);
					FETCH cr_crapcje INTO rw_crapcje;
					
					-- Se encontrou
					IF cr_crapcje%FOUND THEN
						-- Gerar ocorrencia 25 - Emitente � conjuge
						pc_gerar_ocorrencia_chq(pr_tab_cheques => pr_tab_cheques
																	 ,pr_idx_cheques => vr_index
																	 ,pr_cdocorre => 25
																	 ,pr_dsrestri => NULL
																	 ,pr_dsdetres => NULL);

					END IF;
					-- Fechar cursor
					CLOSE cr_crapcje;
				END IF;
			END IF;
			
        END IF;  
          
			END IF;
			
			-- Se � necess�rio verificar prejuizo de emitente na cooperativa
			IF vr_tab_lim_desconto(vr_inpessoa).Flpjzemi = 1 THEN
				-- Se for cheque da CECRED
				IF pr_tab_cheques(vr_index).cdbanchq = 85 THEN
					-- Verificar se emitente possui prejuizo na cooperativa
					OPEN cr_crapepr_prj(pr_cdcooper => pr_cdcooper
														 ,pr_nrdconta => pr_tab_cheques(vr_index).nrctachq);
					FETCH cr_crapepr_prj INTO rw_crapepr_prj;
					-- Se encontrou
					IF cr_crapepr_prj%FOUND THEN
						-- Gerar ocorrencia 13 - Cooperado possui preju�zo
						pc_gerar_ocorrencia_chq(pr_tab_cheques => pr_tab_cheques
																	 ,pr_idx_cheques => vr_index
																	 ,pr_cdocorre => 13
																	 ,pr_dsrestri => NULL
																	 ,pr_dsdetres => NULL);
					END IF;
					-- Fechar cursor
					CLOSE cr_crapepr_prj;
				END IF;
			END IF;
			
			-- Se � necess�rio verificar Emitente x Conta Solicitante
			IF vr_tab_lim_desconto(vr_inpessoa).Flemisol = 1 THEN
				-- Se for cheque da CECRED
				IF pr_tab_cheques(vr_index).cdbanchq = 85 THEN
					/* Verificar se o emitente de cheque possui border�s de desconto de cheque
 				     com cheques do cooperado que est� descontando */
          OPEN cr_crapcdb_emi(pr_cdcooper => pr_cdcooper
					                   ,pr_nrdconta => pr_nrdconta
														 ,pr_nrborder => pr_nrborder
					                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
					FETCH cr_crapcdb_emi INTO rw_crapcdb_emi;
					-- Se encontrou
					IF cr_crapcdb_emi%FOUND THEN
						-- Gerar ocorr�ncia 14 - Cooperado possui cheques descontados na conta do emitente
						pc_gerar_ocorrencia_chq(pr_tab_cheques => pr_tab_cheques
																	 ,pr_idx_cheques => vr_index
																	 ,pr_cdocorre => 14
																	 ,pr_dsrestri => NULL
																	 ,pr_dsdetres => NULL);

					END IF;
					-- Fechar cursor
					CLOSE cr_crapcdb_emi;
        END IF;				
			END IF;
			
			-- Verificar quantidade de vezes que o cheque foi redescontado
			OPEN cr_qtd_redesconto(pr_cdcooper => pr_cdcooper
														,pr_cdcmpchq => pr_tab_cheques(vr_index).cdcmpchq
														,pr_cdbanchq => pr_tab_cheques(vr_index).cdbanchq
														,pr_cdagechq => pr_tab_cheques(vr_index).cdagechq
														,pr_nrctachq => pr_tab_cheques(vr_index).nrctachq
														,pr_nrcheque => pr_tab_cheques(vr_index).nrcheque
														,pr_nrborder => pr_nrborder);
			FETCH cr_qtd_redesconto INTO vr_qtredesc;
			-- Fechar cursor
			CLOSE cr_qtd_redesconto;
			
			-- Se a quantidade de vezes for maior que a parametrizada
			IF vr_qtredesc > vr_tab_lim_desconto(vr_inpessoa).Qtmxrede THEN
				-- Gerar ocorr�ncia 15 - Cheque redescontado v�rias vezes
				pc_gerar_ocorrencia_chq(pr_tab_cheques => pr_tab_cheques
															 ,pr_idx_cheques => vr_index
															 ,pr_cdocorre => 15
															 ,pr_dsrestri => NULL
															 ,pr_dsdetres => vr_qtredesc);
			END IF;

      -- Se parametro permite descontar um ou mais cheques devolvidos
      IF vr_tab_lim_desconto(vr_inpessoa).qtdevchq > 0 THEN
				-- Verificar quantidade de cheques devolvidos do emitente
				OPEN cr_qtchqdev_emi(pr_cdcooper => pr_cdcooper
				                    ,pr_nrcpfcgc => vr_nrcpfcgc);
				FETCH cr_qtchqdev_emi INTO vr_qtdevchq;
				-- Fechar cursor
				CLOSE cr_qtchqdev_emi;
				
				-- Se a quantidade de cheques devolvidos pelo emitente for maior que a permitida
				IF vr_qtdevchq > vr_tab_lim_desconto(vr_inpessoa).qtdevchq THEN
					-- Gerar ocorr�ncia 6 - Qtd maxima de cheques devolvidos por emitente excedido
					pc_gerar_ocorrencia_chq(pr_tab_cheques => pr_tab_cheques
															   ,pr_idx_cheques => vr_index
															   ,pr_cdocorre => 6
															   ,pr_dsrestri => NULL
															   ,pr_dsdetres => vr_qtdevchq);
				END IF;
				
				-- Se permite desconto de cheques devolvidos do cooperado
				IF vr_tab_lim_desconto(vr_inpessoa).fldchqdv = 1 AND
					 vr_qtdevchq > 0 THEN
					 -- Verificar se cooperado possui cheques do emitente com hist�rico de devolu��o de cheque
					 OPEN cr_qtchqdev_emi_ass(pr_cdcooper => pr_cdcooper
					                         ,pr_nrdconta => pr_nrdconta
																	 ,pr_cdcmpchq => pr_tab_cheques(vr_index).cdcmpchq
																	 ,pr_cdbanchq => pr_tab_cheques(vr_index).cdbanchq
																	 ,pr_cdagechq => pr_tab_cheques(vr_index).cdagechq
																	 ,pr_nrctachq => pr_tab_cheques(vr_index).nrctachq
																	 ,pr_nrcheque => pr_tab_cheques(vr_index).nrcheque);
          FETCH cr_qtchqdev_emi_ass INTO vr_qtdevchq_ass;
          -- Fechar cursor
					CLOSE cr_qtchqdev_emi_ass;
					
					-- Se houver algum registro na conta do cooperado
					IF vr_qtdevchq_ass > 0 THEN
						-- Gerar ocorr�ncia 19 - Cheque tem ocorrencia de devolu��o;
						pc_gerar_ocorrencia_chq(pr_tab_cheques => pr_tab_cheques
																	 ,pr_idx_cheques => vr_index
																	 ,pr_cdocorre => 19
																	 ,pr_dsrestri => NULL
																	 ,pr_dsdetres => vr_qtdevchq_ass);
						
					END IF;
				END IF;
			END IF;
			
			-- Verificar se o cheque ainda est� pendente de entrega
			OPEN cr_crapdcc(pr_cdcooper => pr_cdcooper
										 ,pr_nrdconta => pr_nrdconta
										 ,pr_cdcmpchq => pr_tab_cheques(vr_index).cdcmpchq
										 ,pr_cdbanchq => pr_tab_cheques(vr_index).cdbanchq
										 ,pr_cdagechq => pr_tab_cheques(vr_index).cdagechq
										 ,pr_nrctachq => pr_tab_cheques(vr_index).nrctachq
										 ,pr_nrcheque => pr_tab_cheques(vr_index).nrcheque
										 ,pr_nrborder => pr_nrborder
										 ,pr_nrremret => pr_tab_cheques(vr_index).nrremret);
			FETCH cr_crapdcc INTO rw_crapdcc;
			
			-- Se existir registro � porque o cheque ainda est� pendente de entrega
			IF cr_crapdcc%FOUND THEN
				-- Gerar ocorr�ncia 26 - Cheque pendente de entrega
				pc_gerar_ocorrencia_chq(pr_tab_cheques => pr_tab_cheques
															 ,pr_idx_cheques => vr_index
															 ,pr_cdocorre => 26
															 ,pr_dsrestri => NULL
															 ,pr_dsdetres => NULL);
				
			END IF;
			-- Fechar cursor
			CLOSE cr_crapdcc;
			
			IF pr_tab_cheques(vr_index).ocorrencias.count > 0 THEN
				vr_idx_ocorre := pr_tab_cheques(vr_index).ocorrencias.FIRST;
				LOOP
			  
				  EXIT WHEN vr_idx_ocorre IS NULL;
					/* Antes de gravar as ocorrencias de an�lise na crapabc, 
						 verificar se j� existe a ocorr�ncia gravada na crapabc */
					OPEN cr_crapabc(pr_cdcooper => pr_cdcooper
												 ,pr_nrdconta => pr_nrdconta
												 ,pr_nrborder => pr_nrborder
												 ,pr_cdcmpchq => pr_tab_cheques(vr_index).cdcmpchq
												 ,pr_cdbanchq => pr_tab_cheques(vr_index).cdbanchq
												 ,pr_cdagechq => pr_tab_cheques(vr_index).cdagechq
												 ,pr_nrctachq => pr_tab_cheques(vr_index).nrctachq
												 ,pr_nrcheque => pr_tab_cheques(vr_index).nrcheque
												 ,pr_cdocorre => pr_tab_cheques(vr_index).ocorrencias(vr_idx_ocorre).cdocorre);
					FETCH cr_crapabc INTO rw_crapabc;
					
					-- Se j� existir, atualizar campos
					IF cr_crapabc%FOUND THEN
						BEGIN 
							UPDATE crapabc abc 
								 SET abc.dsrestri = pr_tab_cheques(vr_index).ocorrencias(vr_idx_ocorre).dsrestri
										,abc.dsdetres = pr_tab_cheques(vr_index).ocorrencias(vr_idx_ocorre).dsdetres
										,abc.cdocorre = pr_tab_cheques(vr_index).ocorrencias(vr_idx_ocorre).cdocorre
										,abc.cdoperad = pr_cdoperad
							 WHERE abc.cdcooper = pr_cdcooper
								 AND abc.nrdconta = pr_nrdconta
								 AND abc.nrborder = pr_nrborder
								 AND abc.cdcmpchq = pr_tab_cheques(vr_index).cdcmpchq 
								 AND abc.cdbanchq = pr_tab_cheques(vr_index).cdbanchq 
								 AND abc.cdagechq = pr_tab_cheques(vr_index).cdagechq 
								 AND abc.nrctachq = pr_tab_cheques(vr_index).nrctachq 
								 AND abc.nrcheque = pr_tab_cheques(vr_index).nrcheque 
								 AND abc.cdocorre = pr_tab_cheques(vr_index).ocorrencias(vr_idx_ocorre).cdocorre;
						EXCEPTION
							WHEN OTHERS THEN
								vr_cdcritic := 0;
								vr_dscritic := 'Erro ao atualizar ocorr�ncia para o border�: ' || SQLERRM;
								RAISE vr_exc_erro;
						END;				 
					ELSE -- Criar o registro na crapabc
						BEGIN 
							INSERT INTO crapabc (			
									cdcooper, 
									nrdconta, 
									nrborder, 
									cdcmpchq, 
									cdbanchq, 
									cdagechq, 
									nrctachq, 
									nrcheque, 
									cdocorre,							
									dsrestri,
									dsdetres,
									flaprcoo,
									cdoperad)
							VALUES (/*** chave da crapabc ***/
									pr_cdcooper, 
									pr_nrdconta, 
									pr_nrborder, 
									pr_tab_cheques(vr_index).cdcmpchq, 
									pr_tab_cheques(vr_index).cdbanchq, 
									pr_tab_cheques(vr_index).cdagechq, 
									pr_tab_cheques(vr_index).nrctachq, 
									pr_tab_cheques(vr_index).nrcheque, 
									pr_tab_cheques(vr_index).ocorrencias(vr_idx_ocorre).cdocorre,					
									pr_tab_cheques(vr_index).ocorrencias(vr_idx_ocorre).dsrestri,
									pr_tab_cheques(vr_index).ocorrencias(vr_idx_ocorre).dsdetres,
									0,
									pr_cdoperad);
						EXCEPTION
							WHEN OTHERS THEN
								vr_cdcritic := 0;
								vr_dscritic := 'Erro ao inserir ocorr�ncia para o border�: ' || SQLERRM;
								RAISE vr_exc_erro;								
						END;
					END IF;
					-- Fechar cursor
					CLOSE cr_crapabc;
					-- Busca pr�ximo indice
	        vr_idx_ocorre := pr_tab_cheques(vr_index).ocorrencias.next(vr_idx_ocorre);
				END LOOP;
      END IF;
		END LOOP;		
		/* Antes de gravar as ocorrencias de an�lise do border�, 
	     devemos limpar as ocorr�ncias geradas na �ltima analise */
	  DELETE FROM crapabc abc
	   WHERE abc.cdcooper = pr_cdcooper
		   AND abc.nrdconta = pr_nrdconta
		   AND abc.nrborder = pr_nrborder
		   AND abc.cdcmpchq = 0
		   AND abc.cdbanchq = 0
		   AND abc.cdagechq = 0
		   AND abc.nrctachq = 0
		   AND abc.nrcheque = 0;
	
	  -- Calcular valor total de cheques devolvidos
		OPEN cr_craplcm_dev(pr_cdcooper => pr_cdcooper
		                   ,pr_nrdconta => pr_nrdconta
											 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
											 ,pr_qtmesliq => vr_tab_lim_desconto(vr_inpessoa).Qtmesliq);
    FETCH cr_craplcm_dev INTO vr_vltotdev;
		-- Fechar cursor
		CLOSE cr_craplcm_dev;
		
		-- Calcular valor total de cheques descontados
		OPEN cr_crapcdb_dsc(pr_cdcooper => pr_cdcooper
		                   ,pr_nrdconta => pr_nrdconta
											 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
											 ,pr_qtmesliq => vr_tab_lim_desconto(vr_inpessoa).Qtmesliq);
		FETCH cr_crapcdb_dsc INTO vr_vltotdsc;
		-- Fechar cursor
		CLOSE cr_crapcdb_dsc;
		
		-- Se n�o possui nenhum valor devolvido e descontado
		IF vr_vltotdev = 0 AND
			 vr_vltotdsc = 0 THEN
			vr_vlperliq := 100; -- Consideramos 100% de liquidez
		-- Se possui somente valor devolvido
		ELSIF vr_vltotdsc = 0 THEN
			vr_vlperliq := 0;   -- Consideramos 0% de liquidez
		-- Sen�o, efetuar c�lculo do percentual de liquidez
		ELSE
			vr_vlperliq := 100 - ((vr_vltotdev / vr_vltotdsc) * 100);
		END IF;
		
		-- Se o percentual de liquidez de desconto de cheque do cooperado for menor que o parametrizado
		IF vr_vlperliq < vr_tab_lim_desconto(vr_inpessoa).Prcliqui THEN
			-- Gerar ocorr�ncia no border� 89 - Percentual de liquidez inferior ao parametrizado
			pc_gerar_ocorrencia_bordero(pr_cdocorre => 89
																 ,pr_dsrestri => NULL
																 ,pr_dsdetres => ROUND(vr_vlperliq, 2));
		END IF;
		
		-- Buscar rendas do cooperado
		pc_calcular_rendas_faturamento(pr_cdcooper => pr_cdcooper
																	,pr_nrdconta => pr_nrdconta
																	,pr_vlrendim => vr_vlrendim
																	,pr_cdcritic => vr_cdcritic
																	,pr_dscritic => vr_dscritic);
		
		-- Se houve alguma cr�tica
		IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			-- Levantar exce��o
			RAISE vr_exc_erro;
		END IF;
		
	  -- Se o valor do par�metro pr_vlrendim for igual a "zero"
	  IF vr_vlrendim = 0 THEN
			-- Gerar ocorr�ncia no border� 91 - Cooperado sem rendas/faturamento cadastrado
			pc_gerar_ocorrencia_bordero(pr_cdocorre => 91
																 ,pr_dsrestri => NULL
																 ,pr_dsdetres => NULL);
      vr_cdcritic := 0;
     	vr_dscritic := 'Cooperado sem rendas/faturamento cadastrado. Verifique tela CONTAS.';
			-- Levantar exce��o
			RAISE vr_exc_erro;
		END IF;
	
	  -- Buscar valor de limite de desconto de cheque do contrato ativo
	  OPEN cr_craplim(pr_cdcooper => pr_cdcooper
		               ,pr_nrdconta => pr_nrdconta);
		FETCH cr_craplim INTO rw_craplim;
		
		-- Se n�o encontrou contrato
		IF cr_craplim%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_craplim;
			-- Gerar cr�tica
			vr_cdcritic := 0;
			vr_dscritic := 'Contrato de limite ativo n�o encontrado.';
			-- Levantar exce��o
			RAISE vr_exc_erro;
		END IF;
		-- Fechar cursor
		CLOSE cr_craplim;
		
    IF vr_vlrendim > 0 THEN
		-- Se o valor do limite for maior que X vezes o valor de rendimento
		IF round((rw_craplim.vllimite / vr_vlrendim),2) > vr_tab_lim_desconto(vr_inpessoa).Vlrenlim THEN
			-- Gerar ocorr�ncia no border� 90 - Limite muitas vezes superior aos rendimentos;
			pc_gerar_ocorrencia_bordero(pr_cdocorre => 90
																 ,pr_dsrestri => NULL
																 ,pr_dsdetres => round((rw_craplim.vllimite / vr_vlrendim),2));
		END IF;
	END IF;	
		
		-- Busca informa��es do bordero
    OPEN cr_crapbdc(pr_cdcooper => pr_cdcooper
		               ,pr_nrdconta => pr_nrdconta
									 ,pr_nrborder => pr_nrborder);
		FETCH cr_crapbdc INTO rw_crapbdc;
		
		-- Se n�o encontrou
		IF cr_crapbdc%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_crapbdc;
			-- Gerar cr�tica
			vr_cdcritic := 0;
			vr_dscritic := 'Border� n�o encontrado.';
			-- Levantar exce��o
			RAISE vr_exc_erro;
		END IF;
		-- Fechar cursor
		CLOSE cr_crapbdc;
		IF pr_flganali = 1 THEN
		-- atualizar o status do border� para "Em an�lise";
		UPDATE crapbdc SET insitbdc = 2
		 WHERE cdcooper = pr_cdcooper
			 AND nrdconta = pr_nrdconta
			 AND nrborder = pr_nrborder
			 AND insitbdc = 1;
		END IF;
		-- Efetuar commit
		COMMIT;
		
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
      -- Efetuar rollback
      ROLLBACK;      
    WHEN OTHERS THEN      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := REPLACE(REPLACE('Nao foi possivel analisar os cheques do border�: ' || SQLERRM, chr(13)),chr(10));																			
			-- Efetuar Rollback
			ROLLBACK;				 																			 
  END pc_analisar_bordero_cheques;
	
	PROCEDURE pc_calcular_bordero_cheques(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
																			 ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da conta
																			 ,pr_nrborder IN crapabc.nrborder%TYPE  --> numero do bordero
																			 ,pr_tab_cheques IN OUT typ_tab_cheques --> PlTable com dados dos cheques
																			 ,pr_cdcritic OUT PLS_INTEGER           --> C�d. da cr�tica
																			 ,pr_dscritic OUT VARCHAR2) IS          --> Descri��o da cr�tica
  /* .............................................................................
    Programa: pc_calcular_bordero_cheques
    Sistema : CECRED
    Autor   : Lucas Reinert
    Data    : Dezembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para c�lculo de juros da opera��o do border� (juros simples)

    Alteracoes: -----
  ..............................................................................*/																			 
	-- Vari�vel de cr�ticas
	vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
	vr_dscritic        VARCHAR2(1000);        --> Desc. Erro        
	-- Tratamento de erros
	vr_exc_erro        EXCEPTION;    
	
	-- Vari�veis auxiliares
	vr_txmensal crapbdc.txmensal%TYPE;
  vr_dtlibera DATE;
	vr_dtauxili DATE;
	vr_vlcheque NUMBER;
	vr_vltotjur NUMBER;
	vr_vldjuros NUMBER;
	vr_qtddias NUMBER;
	
  -- Cursor da data
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

  -- Buscar border� de desconto de cheque
  CURSOR cr_crapbdc(pr_cdcooper IN crapbdc.cdcooper%TYPE
	                 ,pr_nrdconta IN crapbdc.nrdconta%TYPE
									 ,pr_nrborder IN crapbdc.nrborder%TYPE) IS
	  SELECT bdc.txmensal
		      ,bdc.nrctrlim
		  FROM crapbdc bdc
		 WHERE bdc.cdcooper = pr_cdcooper
		   AND bdc.nrdconta = pr_nrdconta
			 AND bdc.nrborder = pr_nrborder;
	rw_crapbdc cr_crapbdc%ROWTYPE;
	
	BEGIN
		
		-- Busca a data do sistema
		OPEN  BTCH0001.cr_crapdat(pr_cdcooper);
		FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
		CLOSE BTCH0001.cr_crapdat;
	  
    IF pr_tab_cheques.count <= 0 THEN
      vr_cdcritic := 0;
			vr_dscritic := 'N�o h� cheques aprovados para este border�.';
      RAISE vr_exc_erro;
    END IF;
    
	  -- Iterar cheques parametrizados
	  FOR vr_index IN pr_tab_cheques.first..pr_tab_cheques.last LOOP
		  -- Apagar os registros da tabela de juros dos cheques descontados
		  DELETE FROM crapljd ljd
		   WHERE ljd.cdcooper = pr_cdcooper
			   AND ljd.nrdconta = pr_nrdconta
			   AND ljd.nrborder = pr_nrborder
			   AND ljd.cdcmpchq = pr_tab_cheques(vr_index).cdcmpchq   
			   AND ljd.cdbanchq = pr_tab_cheques(vr_index).cdbanchq   
			   AND ljd.cdagechq = pr_tab_cheques(vr_index).cdagechq   
			   AND ljd.nrctachq = pr_tab_cheques(vr_index).nrctachq   
			   AND ljd.nrcheque = pr_tab_cheques(vr_index).nrcheque;
			 
	  END LOOP;
		
		-- Buscar border� de desconto de cheque
		OPEN cr_crapbdc(pr_cdcooper => pr_cdcooper
		               ,pr_nrdconta => pr_nrdconta
									 ,pr_nrborder => pr_nrborder);
		FETCH cr_crapbdc INTO rw_crapbdc;
		
		-- Se n�o encontrou border�
		IF cr_crapbdc%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_crapbdc;
			-- Gerar cr�tica
			vr_cdcritic := 0;
			vr_dscritic := 'Border� n�o encontrado.';
      RAISE vr_exc_erro;
		END IF;
		-- Fechar cursor
		CLOSE cr_crapbdc;

    -- Atribuir taxa mensal do border�
		vr_txmensal := rw_crapbdc.txmensal;
		
	  -- Iterar cheques parametrizados
 	  FOR vr_index IN pr_tab_cheques.first..pr_tab_cheques.last LOOP
		  -- Filtrar os cheques aprovados	
			IF pr_tab_cheques(vr_index).flgaprov = 0 THEN
				CONTINUE;
			END IF;
			
      vr_vlcheque := pr_tab_cheques(vr_index).vlcheque;
			vr_dtlibera := pr_tab_cheques(vr_index).dtlibera;
			vr_dtauxili := last_day(rw_crapdat.dtmvtolt);
			vr_vltotjur := 0;
			
			LOOP
			  vr_qtddias := 0;
				
				-- Se data auxliar for maior que a de libera��o do cheque
				IF vr_dtauxili >= vr_dtlibera THEN
					-- Verificar se m�s da data de libera��o � o mesmo da data auxiliar
					IF TRUNC(vr_dtauxili, 'MM') = TRUNC(rw_crapdat.dtmvtolt, 'MM') THEN
						vr_qtddias := vr_dtlibera - rw_crapdat.dtmvtolt;
					ELSE 
						vr_qtddias := vr_dtlibera - trunc(vr_dtauxili,'MM') + 1;
					END IF;
				ELSE
					-- Verificar se m�s da data atual � o mesmo da data auxiliar
					IF TRUNC(vr_dtauxili, 'MM') = TRUNC(rw_crapdat.dtmvtolt, 'MM') THEN
						vr_qtddias := vr_dtauxili - rw_crapdat.dtmvtolt;
					ELSE 
						vr_qtddias := vr_dtauxili - TRUNC(vr_dtauxili,'MM') + 1;
					END IF;
				END IF;
				
				vr_vldjuros := vr_vlcheque * vr_qtddias * ((vr_txmensal / 100) / 30);
				vr_vltotjur := nvl(vr_vltotjur,0) + vr_vldjuros;
				
				BEGIN
					INSERT INTO crapljd
								(cdcooper
								,nrdconta
								,nrborder
								,nrctrlim
								,dtrefere
								,dtmvtolt
								,vldjuros
								,cdcmpchq
								,cdbanchq
								,cdagechq
								,nrctachq
								,nrcheque)
					VALUES(pr_cdcooper
					      ,pr_nrdconta
					      ,pr_nrborder
								,rw_crapbdc.nrctrlim
								,vr_dtauxili
								,rw_crapdat.dtmvtolt
								,vr_vldjuros
								,pr_tab_cheques(vr_index).cdcmpchq
								,pr_tab_cheques(vr_index).cdbanchq
								,pr_tab_cheques(vr_index).cdagechq
								,pr_tab_cheques(vr_index).nrctachq
								,pr_tab_cheques(vr_index).nrcheque);
				EXCEPTION
					WHEN OTHERS THEN      
						-- Gerar cr�tica
						vr_cdcritic := 0;
						vr_dscritic := REPLACE(REPLACE('Erro ao inserir lan�amento de juros de desconto de cheques: ' || SQLERRM, chr(13)),chr(10));																			
						-- Levantar exce��o
						RAISE vr_exc_erro;
				END;
				
				-- O c�lculo � proporcional m�s a m�s
				vr_dtauxili := add_months(vr_dtauxili, 1);
				
				EXIT WHEN TRUNC(vr_dtauxili, 'MM') > vr_dtlibera;
				
			END LOOP;
			
	    -- No final do c�lculo, atualizar o valor l�quido do cheque
		  pr_tab_cheques(vr_index).vlliquid := vr_vlcheque - vr_vltotjur;
			
		END LOOP;

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
      -- Efetuar rollback
      ROLLBACK;      
    WHEN OTHERS THEN      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := REPLACE(REPLACE('Nao foi possivel calcular os juros do border�: ' || SQLERRM, chr(13)),chr(10));																			
			-- Efetuar Rollback
			ROLLBACK;				 																			 
	END pc_calcular_bordero_cheques;
	
	PROCEDURE pc_calcular_bordero_composto(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
																			  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da conta
																			  ,pr_nrborder IN crapabc.nrborder%TYPE  --> numero do bordero
																				,pr_cdoperad IN crapope.cdoperad%TYPE  --> Operador
																			  ,pr_tab_cheques IN typ_reg_cheques     --> PlTable com dados dos cheques
																			  ,pr_cdcritic OUT PLS_INTEGER           --> C�d. da cr�tica
																			  ,pr_dscritic OUT VARCHAR2) IS          --> Descri��o da cr�tica
  /* .............................................................................
    Programa: pc_calcular_bordero_composto
    Sistema : CECRED
    Autor   : Lucas Reinert
    Data    : Dezembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para c�lculo de juros da opera��o do border� (juros simples)

    Alteracoes: -----
  ..............................................................................*/																			 
	-- Vari�vel de cr�ticas
	vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
	vr_dscritic        VARCHAR2(1000);        --> Desc. Erro        
	-- Tratamento de erros
	vr_exc_erro        EXCEPTION;    
	
	-- Vari�veis auxiliares
	vr_txmensal crapbdc.txmensal%TYPE;
	vr_txdiaria NUMBER;
	vr_vlcheque NUMBER;
	vr_vltotjur NUMBER;
	vr_vldjuros NUMBER;
	vr_qtdprazo NUMBER;
	vr_dtperiod DATE;
	vr_dtrefjur DATE;
	vr_vlliqori NUMBER;
  vr_vlliqnov NUMBER;
	vr_nrseqdig NUMBER;
	vr_vllanmto NUMBER;
	
  -- Cursor da data
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

  -- Buscar border� de desconto de cheque
  CURSOR cr_crapbdc(pr_cdcooper IN crapbdc.cdcooper%TYPE
	                 ,pr_nrdconta IN crapbdc.nrdconta%TYPE
									 ,pr_nrborder IN crapbdc.nrborder%TYPE) IS
	  SELECT bdc.txmensal
		      ,bdc.nrctrlim
					,bdc.dtlibbdc
		  FROM crapbdc bdc
		 WHERE bdc.cdcooper = pr_cdcooper
		   AND bdc.nrdconta = pr_nrdconta
			 AND bdc.nrborder = pr_nrborder;
	rw_crapbdc cr_crapbdc%ROWTYPE;
	
	-- Buscar registro de juros
	CURSOR cr_crapljd(pr_cdcooper IN crapljd.cdcooper%TYPE
	                 ,pr_nrdconta IN crapljd.nrdconta%TYPE
									 ,pr_nrborder IN crapljd.nrborder%TYPE
									 ,pr_dtmvtolt IN crapljd.dtmvtolt%TYPE
									 ,pr_dtrefere IN crapljd.dtrefere%TYPE
									 ,pr_cdcmpchq IN crapljd.cdcmpchq%TYPE
									 ,pr_cdbanchq IN crapljd.cdbanchq%TYPE
									 ,pr_cdagechq IN crapljd.cdagechq%TYPE
									 ,pr_nrctachq IN crapljd.nrctachq%TYPE
									 ,pr_nrcheque IN crapljd.nrcheque%TYPE) IS
	  SELECT ljd.vldjuros
		      ,ljd.rowid
		  FROM crapljd ljd
		 WHERE ljd.cdcooper = pr_cdcooper
		   AND ljd.nrdconta = pr_nrdconta
			 AND ljd.nrborder = pr_nrborder
			 AND ljd.dtmvtolt = pr_dtmvtolt
			 AND ljd.dtrefere = pr_dtrefere
			 AND ljd.cdcmpchq = pr_cdcmpchq
			 AND ljd.cdbanchq = pr_cdbanchq
			 AND ljd.cdagechq = pr_cdagechq
			 AND ljd.nrctachq = pr_nrctachq
			 AND ljd.nrcheque = pr_nrcheque;
    rw_crapljd cr_crapljd%ROWTYPE;
		
	-- Buscar informa��es do lote
	CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
	                 ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE) IS 
		SELECT lot.dtmvtolt
		      ,lot.cdagenci
					,lot.cdbccxlt
					,lot.nrdolote
					,lot.nrseqdig
					,lot.qtinfoln
					,lot.qtcompln
					,lot.vlinfocr
					,lot.vlcompcr
					,lot.rowid
		  FROM craplot lot
		 WHERE lot.cdcooper = pr_cdcooper
		   AND lot.dtmvtolt = pr_dtmvtolt
			 AND lot.cdagenci = 1
			 AND lot.cdbccxlt = 100
			 AND lot.nrdolote = 8477;
  rw_craplot cr_craplot%ROWTYPE;
			
	BEGIN
		
		-- Busca a data do sistema
		OPEN  BTCH0001.cr_crapdat(pr_cdcooper);
		FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
		CLOSE BTCH0001.cr_crapdat;
		
		-- Buscar border� de desconto de cheque
		OPEN cr_crapbdc(pr_cdcooper => pr_cdcooper
		               ,pr_nrdconta => pr_nrdconta
									 ,pr_nrborder => pr_nrborder);
		FETCH cr_crapbdc INTO rw_crapbdc;
		
		-- Se n�o encontrou border�
		IF cr_crapbdc%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_crapbdc;
			-- Gerar cr�tica
			vr_cdcritic := 0;
			vr_dscritic := 'Border� n�o encontrado.';
		END IF;
		-- Fechar cursor
		CLOSE cr_crapbdc;

    -- Atribuir taxa mensal do border�
		vr_txmensal := rw_crapbdc.txmensal;
		vr_txdiaria := ROUND((POWER(1 + (vr_txmensal / 100),1 / 30) - 1),7);
		vr_dtperiod := rw_crapbdc.dtlibbdc;		
		vr_qtdprazo := rw_crapdat.dtmvtolt - vr_dtperiod;
					
		-- Restitui��o n�o pode ser no mesmo dia da libera��o
		IF vr_qtdprazo > 0 THEN

			-- Pegar as informa��es do cheque			
			vr_vlcheque := pr_tab_cheques.vlcheque;
			vr_vltotjur := 0;
			vr_vlliqori := pr_tab_cheques.vlliquid;
					
			FOR vr_contador IN 1..vr_qtdprazo LOOP
				-- Efetuar c�lculos de juros di�rios
				vr_vldjuros := round(pr_tab_cheques.vlcheque * vr_txdiaria);
				vr_vltotjur := vr_vltotjur + vr_vldjuros;					
				vr_vlcheque := vr_vlcheque + vr_vldjuros;
				vr_dtperiod := vr_dtperiod + 1;
				vr_dtrefjur := last_day(vr_dtperiod);
				
				-- Buscar registro da ljd
				OPEN cr_crapljd(pr_cdcooper => pr_cdcooper
											 ,pr_nrdconta => pr_nrdconta
											 ,pr_nrborder => pr_nrborder
											 ,pr_dtmvtolt => rw_crapbdc.dtlibbdc
											 ,pr_dtrefere => vr_dtrefjur
											 ,pr_cdcmpchq => pr_tab_cheques.cdcmpchq
											 ,pr_cdbanchq => pr_tab_cheques.cdbanchq
											 ,pr_cdagechq => pr_tab_cheques.cdagechq
											 ,pr_nrctachq => pr_tab_cheques.nrctachq
											 ,pr_nrcheque => pr_tab_cheques.nrcheque);
				FETCH cr_crapljd INTO rw_crapljd;
						
				-- Se n�o encontrar
				IF cr_crapljd%NOTFOUND THEN
					-- Fechar cursor
					CLOSE cr_crapljd;
					-- Gerar cr�tica
					vr_cdcritic := 79;
					RAISE vr_exc_erro;
				END IF;
				-- Fechar cursor
				CLOSE cr_crapljd;
						
				-- Se o valor de juros for maior que o valor recalculado
				IF rw_crapljd.vldjuros > vr_vltotjur THEN
					BEGIN
						UPDATE crapljd ljd
							 SET ljd.vlrestit = rw_crapljd.vldjuros - vr_vltotjur
									,ljd.vldjuros = vr_vltotjur
						 WHERE ljd.rowid = rw_crapljd.rowid;
					EXCEPTION
						WHEN OTHERS THEN      
							vr_cdcritic := 0;
							vr_dscritic := REPLACE(REPLACE('Erro ao atualizar registro na crapljd: ' || SQLERRM, chr(13)),chr(10));																			
							-- Levanta exce��o
							RAISE vr_exc_erro;
					END;
				END IF;
									
			END LOOP;
				
			-- No final do c�lculo, atualizar o valor l�quido do cheque
			vr_vlliqnov := pr_tab_cheques.vlcheque - (vr_vlcheque - pr_tab_cheques.vlcheque);
					
		ELSE
			vr_vlliqori := pr_tab_cheques.vlliquid;
			vr_vlliqnov := pr_tab_cheques.vlcheque;
		END IF;		
			
		BEGIN
			-- Atualizar registro da crapljd
			UPDATE crapljd ljd
				 SET ljd.vlrestit = ljd.vldjuros
						,ljd.vldjuros = 0
			 WHERE ljd.cdcooper = pr_cdcooper
				 AND ljd.nrdconta = pr_nrdconta
				 AND ljd.nrborder = pr_nrborder
				 AND ljd.dtmvtolt = rw_crapbdc.dtlibbdc
				 AND ljd.dtrefere > vr_dtrefjur
				 AND ljd.cdcmpchq = pr_tab_cheques.cdcmpchq
				 AND ljd.cdbanchq = pr_tab_cheques.cdbanchq
				 AND ljd.cdagechq = pr_tab_cheques.cdagechq
				 AND ljd.nrctachq = pr_tab_cheques.nrctachq
				 AND ljd.nrcheque = pr_tab_cheques.nrcheque;					 
		EXCEPTION
			WHEN OTHERS THEN      
				vr_cdcritic := 0;
				vr_dscritic := REPLACE(REPLACE('Erro ao atualizar registro na crapljd: ' || SQLERRM, chr(13)),chr(10));																			
				-- Levanta exce��o
				RAISE vr_exc_erro;
		END;
			
		-- Buscar lote
		OPEN cr_craplot(pr_cdcooper => pr_cdcooper
									 ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
		FETCH cr_craplot INTO rw_craplot;
			
		IF cr_craplot%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_craplot;
			BEGIN
				-- Se n�o existir lote, criar
				INSERT INTO craplot
							 (dtmvtolt
							 ,cdagenci
							 ,cdbccxlt
							 ,nrdolote
							 ,tplotmov
							 ,cdoperad
							 ,cdhistor
							 ,cdcooper)
				 VALUES(rw_crapdat.dtmvtolt
							 ,1
							 ,100
							 ,8477
							 ,1
							 ,pr_cdoperad
							 ,271
							 ,pr_cdcooper);
			EXCEPTION
				WHEN OTHERS THEN      
					-- Gerar cr�tica
					vr_cdcritic := 0;
					vr_dscritic := REPLACE(REPLACE('Erro ao criar novo lote: ' || SQLERRM, chr(13)),chr(10));																			
					-- Levantar exce��o
					RAISE vr_exc_erro;				
			END;
			-- Buscar lote
			OPEN cr_craplot(pr_cdcooper => pr_cdcooper
										 ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
			FETCH cr_craplot INTO rw_craplot;
			-- Fechar cursor
			CLOSE cr_craplot;
		END IF;
			
		BEGIN
			-- Criar lan�amento de desconto de bordero
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
							,nrdctitg
							,nrautdoc
							,cdcooper
							,cdpesqbb
							,cdbanchq
							,cdagechq
							,nrctachq)
				VALUES(rw_craplot.dtmvtolt
							,rw_craplot.cdagenci
							,rw_craplot.cdbccxlt
							,rw_craplot.nrdolote
							,pr_nrdconta
							,rw_craplot.nrseqdig + 1
							,pr_tab_cheques.vlcheque - (vr_vlliqnov - vr_vlliqori)
							,271
							,rw_craplot.nrseqdig + 1
							,pr_nrdconta
							,to_char(pr_nrdconta, 'fm00000000')
							,0
							,pr_cdcooper
							,'Resgate de cheque descontado ' || pr_tab_cheques.dsdocmc7 
								|| ' Bordero ' || to_char(pr_nrborder, 'fm999g999g990')
							,pr_tab_cheques.cdbanchq
							,pr_tab_cheques.cdagechq
							,pr_tab_cheques.nrctachq)
			RETURNING nrseqdig, vllanmto INTO vr_nrseqdig , vr_vllanmto;
		EXCEPTION
			WHEN OTHERS THEN      
				-- Gerar cr�tica
				vr_cdcritic := 0;
				vr_dscritic := REPLACE(REPLACE('Erro ao criar novo lan�amento: ' || SQLERRM, chr(13)),chr(10));																			
				-- Levantar exce��o
				RAISE vr_exc_erro;				
		END;
				
		BEGIN 
			-- Atualizar valores do lote				
			UPDATE craplot lot
				 SET lot.nrseqdig = vr_nrseqdig
						,lot.qtinfoln = lot.qtinfoln + 1
						,lot.qtcompln = lot.qtcompln + 1
						,lot.vlinfodb = lot.vlinfodb + vr_vllanmto
						,lot.vlcompdb = lot.vlcompdb + vr_vllanmto
			WHERE lot.rowid = rw_craplot.rowid;
		EXCEPTION
			WHEN OTHERS THEN      
				-- Gerar cr�tica
				vr_cdcritic := 0;
				vr_dscritic := REPLACE(REPLACE('Erro ao atualizar valores do lote: ' || SQLERRM, chr(13)),chr(10));																			
				-- Levantar exce��o
				RAISE vr_exc_erro;								
		END;
		
		BEGIN
			UPDATE crapcdb cdb
				 SET cdb.vlliqdev = vr_vlliqnov
			 WHERE cdb.cdcooper = pr_cdcooper
				 AND cdb.nrdconta = pr_nrdconta
				 AND cdb.nrborder = pr_nrborder
				 AND cdb.cdcmpchq = pr_tab_cheques.cdcmpchq
				 AND cdb.cdbanchq = pr_tab_cheques.cdbanchq
				 AND cdb.cdagechq = pr_tab_cheques.cdagechq
				 AND cdb.nrctachq = pr_tab_cheques.nrctachq
				 AND cdb.nrcheque = pr_tab_cheques.nrcheque;
		EXCEPTION
			WHEN OTHERS THEN      
				-- Gerar cr�tica
				vr_cdcritic := 0;
				vr_dscritic := REPLACE(REPLACE('Erro ao atualizar valor l�quido do cheque do bordero: ' || SQLERRM, chr(13)),chr(10));																			
				-- Levantar exce��o
				RAISE vr_exc_erro;												
		END;	
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
      -- Efetuar rollback
      ROLLBACK;      
    WHEN OTHERS THEN      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := REPLACE(REPLACE('Nao foi possivel calcular os juros do border�: ' || SQLERRM, chr(13)),chr(10));																			
			-- Efetuar Rollback
			ROLLBACK;				 																			 
	END pc_calcular_bordero_composto;

	PROCEDURE pc_calcular_bordero_simples(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
																			 ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da conta
																			 ,pr_nrborder IN crapabc.nrborder%TYPE  --> numero do bordero
																			 ,pr_cdoperad IN crapope.cdoperad%TYPE
																			 ,pr_tab_cheques IN typ_reg_cheques --> PlTable com dados dos cheques
																			 ,pr_cdcritic OUT PLS_INTEGER           --> C�d. da cr�tica
																			 ,pr_dscritic OUT VARCHAR2) IS          --> Descri��o da cr�tica
  /* .............................................................................
    Programa: pc_calcular_bordero_simples
    Sistema : CECRED
    Autor   : Lucas Reinert
    Data    : Dezembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para c�lculo de juros de resgate do border� (juros simples)

    Alteracoes: -----
  ..............................................................................*/																			 
	-- Vari�vel de cr�ticas
	vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
	vr_dscritic        VARCHAR2(1000);        --> Desc. Erro        
	-- Tratamento de erros
	vr_exc_erro        EXCEPTION;    
	
	-- Vari�veis auxiliares
	vr_txmensal crapbdc.txmensal%TYPE;
  vr_dtresgat DATE;
	vr_dtauxili DATE;
	vr_dtrefjur DATE;
	vr_vlcheque NUMBER;
	vr_vltotjur NUMBER;
	vr_vldjuros NUMBER;
	vr_qtdiares NUMBER;
	vr_vlliquid NUMBER;
	vr_nrseqdig NUMBER;
	vr_vllanmto NUMBER;
	
  -- Cursor da data
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

  -- Buscar border� de desconto de cheque
  CURSOR cr_crapbdc(pr_cdcooper IN crapbdc.cdcooper%TYPE
	                 ,pr_nrdconta IN crapbdc.nrdconta%TYPE
									 ,pr_nrborder IN crapbdc.nrborder%TYPE) IS
	  SELECT bdc.txmensal
		      ,bdc.nrctrlim
					,bdc.dtlibbdc
		  FROM crapbdc bdc
		 WHERE bdc.cdcooper = pr_cdcooper
		   AND bdc.nrdconta = pr_nrdconta
			 AND bdc.nrborder = pr_nrborder;
	rw_crapbdc cr_crapbdc%ROWTYPE;
	
		-- Buscar registro de juros
	CURSOR cr_crapljd(pr_cdcooper IN crapljd.cdcooper%TYPE
	                 ,pr_nrdconta IN crapljd.nrdconta%TYPE
									 ,pr_nrborder IN crapljd.nrborder%TYPE
									 ,pr_dtmvtolt IN crapljd.dtmvtolt%TYPE
									 ,pr_dtrefere IN crapljd.dtrefere%TYPE
									 ,pr_cdcmpchq IN crapljd.cdcmpchq%TYPE
									 ,pr_cdbanchq IN crapljd.cdbanchq%TYPE
									 ,pr_cdagechq IN crapljd.cdagechq%TYPE
									 ,pr_nrctachq IN crapljd.nrctachq%TYPE
									 ,pr_nrcheque IN crapljd.nrcheque%TYPE) IS
	  SELECT ljd.vldjuros
		      ,ljd.rowid
		  FROM crapljd ljd
		 WHERE ljd.cdcooper = pr_cdcooper
		   AND ljd.nrdconta = pr_nrdconta
			 AND ljd.nrborder = pr_nrborder
			 AND ljd.dtmvtolt = pr_dtmvtolt
			 AND ljd.dtrefere = pr_dtrefere
			 AND ljd.cdcmpchq = pr_cdcmpchq
			 AND ljd.cdbanchq = pr_cdbanchq
			 AND ljd.cdagechq = pr_cdagechq
			 AND ljd.nrctachq = pr_nrctachq
			 AND ljd.nrcheque = pr_nrcheque;
    rw_crapljd cr_crapljd%ROWTYPE;
		
	-- Buscar informa��es do lote
	CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
	                 ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE) IS 
		SELECT lot.dtmvtolt
		      ,lot.cdagenci
					,lot.cdbccxlt
					,lot.nrdolote
					,lot.nrseqdig
					,lot.qtinfoln
					,lot.qtcompln
					,lot.vlinfocr
					,lot.vlcompcr
					,lot.rowid
		  FROM craplot lot
		 WHERE lot.cdcooper = pr_cdcooper
		   AND lot.dtmvtolt = pr_dtmvtolt
			 AND lot.cdagenci = 1
			 AND lot.cdbccxlt = 100
			 AND lot.nrdolote = 8477;
  rw_craplot cr_craplot%ROWTYPE;
	
	BEGIN
		
		-- Busca a data do sistema
		OPEN  BTCH0001.cr_crapdat(pr_cdcooper);
		FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
		CLOSE BTCH0001.cr_crapdat;
		
		-- Buscar border� de desconto de cheque
		OPEN cr_crapbdc(pr_cdcooper => pr_cdcooper
		               ,pr_nrdconta => pr_nrdconta
									 ,pr_nrborder => pr_nrborder);
		FETCH cr_crapbdc INTO rw_crapbdc;
		
		-- Se n�o encontrou border�
		IF cr_crapbdc%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_crapbdc;
			-- Gerar cr�tica
			vr_cdcritic := 0;
			vr_dscritic := 'Border� n�o encontrado.';
		END IF;
		-- Fechar cursor
		CLOSE cr_crapbdc;

    -- Atribuir taxa mensal do border�
		vr_txmensal := rw_crapbdc.txmensal;
					
		vr_vlcheque := pr_tab_cheques.vlcheque;
		vr_dtresgat := pr_tab_cheques.dtlibera;
		vr_dtauxili := last_day(rw_crapdat.dtmvtolt);
		vr_vltotjur := 0;
			
		LOOP
			vr_qtdiares := 0;
				
			-- Se data auxliar for maior que a de libera��o do cheque
			IF vr_dtauxili >= vr_dtresgat THEN
				-- Verificar se m�s da data de libera��o � o mesmo da data auxiliar
				IF TRUNC(vr_dtauxili, 'MM') = TRUNC(rw_crapdat.dtmvtolt, 'MM') THEN
					vr_qtdiares := vr_dtresgat - rw_crapdat.dtmvtolt;
				ELSE 
					vr_qtdiares := vr_dtresgat - trunc(vr_dtauxili,'MM') + 1;
				END IF;
			ELSE
				-- Verificar se m�s da data atual � o mesmo da data auxiliar
				IF TRUNC(vr_dtauxili, 'MM') = TRUNC(rw_crapdat.dtmvtolt, 'MM') THEN
					vr_qtdiares := vr_dtauxili - rw_crapdat.dtmvtolt;
				ELSE 
					vr_qtdiares := vr_dtauxili - TRUNC(vr_dtauxili,'MM') + 1;
				END IF;
			END IF;
				
			vr_vldjuros := vr_vlcheque * vr_qtdiares * ((vr_txmensal / 100) / 30);
			vr_vltotjur := nvl(vr_vltotjur,0) + vr_vldjuros;
								
			-- Buscar registro da ljd
			OPEN cr_crapljd(pr_cdcooper => pr_cdcooper
										 ,pr_nrdconta => pr_nrdconta
										 ,pr_nrborder => pr_nrborder
										 ,pr_dtmvtolt => rw_crapbdc.dtlibbdc
										 ,pr_dtrefere => vr_dtauxili
										 ,pr_cdcmpchq => pr_tab_cheques.cdcmpchq
										 ,pr_cdbanchq => pr_tab_cheques.cdbanchq
										 ,pr_cdagechq => pr_tab_cheques.cdagechq
										 ,pr_nrctachq => pr_tab_cheques.nrctachq
										 ,pr_nrcheque => pr_tab_cheques.nrcheque);
			FETCH cr_crapljd INTO rw_crapljd;
					
			-- Se n�o encontrar
			IF cr_crapljd%NOTFOUND THEN
				-- Fechar cursor
				CLOSE cr_crapljd;
				-- Gerar cr�tica
				vr_cdcritic := 79;
				RAISE vr_exc_erro;
			END IF;
			-- Fechar cursor
			CLOSE cr_crapljd;
					
			-- Se o valor de juros for maior que o valor recalculado
			IF rw_crapljd.vldjuros > vr_vltotjur THEN
				BEGIN
					UPDATE crapljd ljd
						 SET ljd.vlrestit = rw_crapljd.vldjuros - vr_vltotjur
								,ljd.vldjuros = vr_vltotjur
					 WHERE ljd.rowid = rw_crapljd.rowid;
				EXCEPTION
					WHEN OTHERS THEN      
						vr_cdcritic := 0;
						vr_dscritic := REPLACE(REPLACE('Erro ao atualizar registro na crapljd: ' || SQLERRM, chr(13)),chr(10));																			
						-- Levanta exce��o
						RAISE vr_exc_erro;
				END;
			END IF;			
			
			-- O c�lculo � proporcional m�s a m�s
			vr_dtauxili := add_months(vr_dtauxili, 1);
			vr_dtrefjur := last_day(vr_dtauxili);
			
			EXIT WHEN TRUNC(vr_dtauxili, 'MM') > vr_dtresgat;
				
		END LOOP;
			
		-- No final do c�lculo, atualizar o valor l�quido do cheque
    vr_vlliquid := vr_vlcheque - vr_vltotjur;
		
		BEGIN
			-- Atualizar registro da crapljd
			UPDATE crapljd ljd
				 SET ljd.vlrestit = ljd.vldjuros
						,ljd.vldjuros = 0
			 WHERE ljd.cdcooper = pr_cdcooper
				 AND ljd.nrdconta = pr_nrdconta
				 AND ljd.nrborder = pr_nrborder
				 AND ljd.dtmvtolt = rw_crapbdc.dtlibbdc
				 AND ljd.dtrefere > vr_dtrefjur
				 AND ljd.cdcmpchq = pr_tab_cheques.cdcmpchq
				 AND ljd.cdbanchq = pr_tab_cheques.cdbanchq
				 AND ljd.cdagechq = pr_tab_cheques.cdagechq
				 AND ljd.nrctachq = pr_tab_cheques.nrctachq
				 AND ljd.nrcheque = pr_tab_cheques.nrcheque;					 
		EXCEPTION
			WHEN OTHERS THEN      
				vr_cdcritic := 0;
				vr_dscritic := REPLACE(REPLACE('Erro ao atualizar registro na crapljd: ' || SQLERRM, chr(13)),chr(10));																			
				-- Levanta exce��o
				RAISE vr_exc_erro;
		END;
			
		-- Buscar lote
		OPEN cr_craplot(pr_cdcooper => pr_cdcooper
									 ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
		FETCH cr_craplot INTO rw_craplot;
			
		IF cr_craplot%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_craplot;
			BEGIN
				-- Se n�o existir lote, criar
				INSERT INTO craplot
							 (dtmvtolt
							 ,cdagenci
							 ,cdbccxlt
							 ,nrdolote
							 ,tplotmov
							 ,cdoperad
							 ,cdhistor
							 ,cdcooper)
				 VALUES(rw_crapdat.dtmvtolt
							 ,1
							 ,100
							 ,8477
							 ,1
							 ,pr_cdoperad
							 ,271
							 ,pr_cdcooper);
			EXCEPTION
				WHEN OTHERS THEN      
					-- Gerar cr�tica
					vr_cdcritic := 0;
					vr_dscritic := REPLACE(REPLACE('Erro ao criar novo lote: ' || SQLERRM, chr(13)),chr(10));																			
					-- Levantar exce��o
					RAISE vr_exc_erro;				
			END;
			-- Buscar lote
			OPEN cr_craplot(pr_cdcooper => pr_cdcooper
										 ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
			FETCH cr_craplot INTO rw_craplot;
			-- Fechar cursor
			CLOSE cr_craplot;
		END IF;
			
		BEGIN
			-- Criar lan�amento de desconto de bordero
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
							,nrdctitg
							,nrautdoc
							,cdcooper
							,cdpesqbb
							,cdbanchq
							,cdagechq
							,nrctachq)
				VALUES(rw_craplot.dtmvtolt
							,rw_craplot.cdagenci
							,rw_craplot.cdbccxlt
							,rw_craplot.nrdolote
							,pr_nrdconta
							,rw_craplot.nrseqdig + 1
							,vr_vlliquid
							,271
							,rw_craplot.nrseqdig + 1
							,pr_nrdconta
							,to_char(pr_nrdconta, 'fm00000000')
							,0
							,pr_cdcooper
							,'Resgate de cheque descontado ' || pr_tab_cheques.dsdocmc7 
								|| ' Bordero ' || to_char(pr_nrborder, 'fm999g999g990')
							,pr_tab_cheques.cdbanchq
							,pr_tab_cheques.cdagechq
							,pr_tab_cheques.nrctachq)
			RETURNING nrseqdig, vllanmto INTO vr_nrseqdig , vr_vllanmto;
		EXCEPTION
			WHEN OTHERS THEN      
				-- Gerar cr�tica
				vr_cdcritic := 0;
				vr_dscritic := REPLACE(REPLACE('Erro ao criar novo lan�amento: ' || SQLERRM, chr(13)),chr(10));																			
				-- Levantar exce��o
				RAISE vr_exc_erro;				
		END;
				
		BEGIN 
			-- Atualizar valores do lote				
			UPDATE craplot lot
				 SET lot.nrseqdig = vr_nrseqdig
						,lot.qtinfoln = lot.qtinfoln + 1
						,lot.qtcompln = lot.qtcompln + 1
						,lot.vlinfodb = lot.vlinfodb + vr_vllanmto
						,lot.vlcompdb = lot.vlcompdb + vr_vllanmto
			WHERE lot.rowid = rw_craplot.rowid;
		EXCEPTION
			WHEN OTHERS THEN      
				-- Gerar cr�tica
				vr_cdcritic := 0;
				vr_dscritic := REPLACE(REPLACE('Erro ao atualizar valores do lote: ' || SQLERRM, chr(13)),chr(10));																			
				-- Levantar exce��o
				RAISE vr_exc_erro;								
		END;
		
		BEGIN
			UPDATE crapcdb cdb
				 SET cdb.vlliqdev = vr_vlliquid
			 WHERE cdb.cdcooper = pr_cdcooper
				 AND cdb.nrdconta = pr_nrdconta
				 AND cdb.nrborder = pr_nrborder
				 AND cdb.cdcmpchq = pr_tab_cheques.cdcmpchq
				 AND cdb.cdbanchq = pr_tab_cheques.cdbanchq
				 AND cdb.cdagechq = pr_tab_cheques.cdagechq
				 AND cdb.nrctachq = pr_tab_cheques.nrctachq
				 AND cdb.nrcheque = pr_tab_cheques.nrcheque;
		EXCEPTION
			WHEN OTHERS THEN      
				-- Gerar cr�tica
				vr_cdcritic := 0;
				vr_dscritic := REPLACE(REPLACE('Erro ao atualizar valor l�quido do cheque do bordero: ' || SQLERRM, chr(13)),chr(10));																			
				-- Levantar exce��o
				RAISE vr_exc_erro;												
		END;	

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
      -- Efetuar rollback
      ROLLBACK;      
    WHEN OTHERS THEN      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := REPLACE(REPLACE('Nao foi possivel calcular os juros do border�: ' || SQLERRM, chr(13)),chr(10));																			
			-- Efetuar Rollback
			ROLLBACK;				 																			 
	END pc_calcular_bordero_simples;
	
	PROCEDURE pc_aprovar_reprovar_chq(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
																	 ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da conta
																	 ,pr_cdagenci IN crapass.cdagenci%TYPE  --> Ag�ncia
																	 ,pr_idorigem IN INTEGER                --> Identificador de Origem
																	 ,pr_cdoperad IN crapope.cdoperad%TYPE  --> C�digo do Operador
																	 ,pr_nrborder IN crapabc.nrborder%TYPE  --> numero do bordero
																	 ,pr_tab_cheques IN typ_tab_cheques     --> PlTable com dados dos cheques
																	 ,pr_cdcritic OUT PLS_INTEGER           --> C�d. da cr�tica
																	 ,pr_dscritic OUT VARCHAR2) IS          --> Descri��o da cr�tica
  /* .............................................................................
    Programa: pc_aprovar_reprovar_chq
    Sistema : CECRED
    Autor   : Lucas Reinert
    Data    : Dezembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para aprovar/reprovar cheques do border�

    Alteracoes: -----
  ..............................................................................*/																			 
	-- Vari�vel de cr�ticas
	vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
	vr_dscritic        VARCHAR2(1000);        --> Desc. Erro        
	-- Tratamento de erros
	vr_exc_erro        EXCEPTION;    
	
	-- PlTable com dados dos cheques
	vr_tab_cheques typ_tab_cheques := pr_tab_cheques;
	vr_idx_ocorre PLS_INTEGER;
	BEGIN
    -- Analisar os cheques novamente
		dscc0001.pc_analisar_bordero_cheques(pr_cdcooper => pr_cdcooper
		                                    ,pr_nrdconta => pr_nrdconta
																				,pr_cdagenci => pr_cdagenci
																				,pr_idorigem => pr_idorigem
																				,pr_cdoperad => pr_cdoperad
																				,pr_nrborder => pr_nrborder
																				,pr_tab_cheques => vr_tab_cheques
																				,pr_cdcritic => vr_cdcritic
																				,pr_dscritic => vr_dscritic);
		-- Se retornou alguma cr�tica
		IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			RAISE vr_exc_erro;
		END IF;
		
		-- Se n�o retornou nenhum registro
		IF vr_tab_cheques.count = 0 THEN
			-- Gerar cr�tica
			vr_cdcritic := 0;
			vr_dscritic := 'Cheques para aprova��o n�o encontrados.';
		END IF;
		
		FOR vr_index IN vr_tab_cheques.first..vr_tab_cheques.last LOOP		
			-- Se o cheque foi marcado para ser aprovado
			IF vr_tab_cheques(vr_index).flgaprov = 1 THEN
				-- Verificar se existem ocorr�ncias para o cheque
				IF vr_tab_cheques(vr_index).ocorrencias.count > 0 THEN
					-- Capturar indice da primeira ocorrencia
					vr_idx_ocorre := vr_tab_cheques(vr_index).ocorrencias.first;
					-- Iterar ocorrencias do cheque
					LOOP
						EXIT WHEN vr_idx_ocorre IS NULL;
						-- Se ocorr�ncia bloqueia a opera��o
						IF vr_tab_cheques(vr_index).ocorrencias(vr_idx_ocorre).flbloque = 1 THEN
							vr_tab_cheques(vr_index).flgaprov := 2; -- 2 - Reprovado
							EXIT; -- ir para o pr�ximo cheque;
						END IF;					
						-- Buscar pr�xima ocorr�ncia
						vr_idx_ocorre := vr_tab_cheques(vr_index).ocorrencias.next(vr_idx_ocorre);
					END LOOP;
				END IF;
			ELSE
				-- Cheques n�o selecionados para aprova��o ser�o reprovados
				vr_tab_cheques(vr_index).flgaprov := 2; 
			END IF;
			
			BEGIN
				-- Atualizar a situa��o do cheque descontado
			 UPDATE crapcdb cdb
				  SET cdb.insitana = vr_tab_cheques(vr_index).flgaprov
						 ,cdb.cdopeana = pr_cdoperad
						 ,cdb.dtsitana = TRUNC(SYSDATE)
				WHERE cdb.cdcooper = pr_cdcooper
				  AND cdb.nrdconta = pr_nrdconta
					AND cdb.nrborder = pr_nrborder
					AND cdb.cdcmpchq = vr_tab_cheques(vr_index).cdcmpchq
					AND cdb.cdbanchq = vr_tab_cheques(vr_index).cdbanchq
					AND cdb.cdagechq = vr_tab_cheques(vr_index).cdagechq
					AND cdb.nrctachq = vr_tab_cheques(vr_index).nrctachq
					AND cdb.nrcheque = vr_tab_cheques(vr_index).nrcheque;
			EXCEPTION
				WHEN OTHERS THEN      
					-- Gerar cr�tica
					vr_cdcritic := 0;
					vr_dscritic := REPLACE(REPLACE('Erro ao atualizar situa��o da an�lise do cheque: ' || SQLERRM, chr(13)),chr(10));																			
					-- Levantar exce��o
					RAISE vr_exc_erro;				
			END;
			-- Reprovado
			IF vr_tab_cheques(vr_index).flgaprov = 2 THEN				
				BEGIN
			    -- Se o cheque estiver reprovado, ent�o apagar os juros dele
		      DELETE FROM crapljd ljd
		       WHERE ljd.cdcooper = pr_cdcooper
						 AND ljd.nrdconta = pr_nrdconta
						 AND ljd.nrborder = pr_nrborder
						 AND ljd.cdcmpchq = vr_tab_cheques(vr_index).cdcmpchq   
						 AND ljd.cdbanchq = vr_tab_cheques(vr_index).cdbanchq   
						 AND ljd.cdagechq = vr_tab_cheques(vr_index).cdagechq   
						 AND ljd.nrctachq = vr_tab_cheques(vr_index).nrctachq   
						 AND ljd.nrcheque = vr_tab_cheques(vr_index).nrcheque;

				EXCEPTION
					WHEN OTHERS THEN      
						-- Gerar cr�tica
						vr_cdcritic := 0;
						vr_dscritic := REPLACE(REPLACE('Erro ao excluir lan�amento de juros de desconto de cheques: ' || SQLERRM, chr(13)),chr(10));																			
						-- Levantar exce��o
						RAISE vr_exc_erro;
				END;
			END IF;
		END LOOP;
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
      -- Efetuar rollback
      ROLLBACK;      
    WHEN OTHERS THEN      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := REPLACE(REPLACE('Nao foi possivel aprovar/reprovar os cheques do border�: ' || SQLERRM, chr(13)),chr(10));																			
			-- Efetuar Rollback
			ROLLBACK;				 																			 
	END pc_aprovar_reprovar_chq;
	
	PROCEDURE pc_efetiva_desconto_bordero(pr_cdcooper IN crapcdb.cdcooper%TYPE  --> Cooperativa
                                       ,pr_nrdconta IN crapcdb.nrdconta%TYPE  --> Nr. da Conta
                                       ,pr_nrborder IN crapcdb.nrborder%TYPE  --> Nr. Border�
                                       ,pr_cdoperad IN crapcdb.cdopeana%TYPE  --> C�d. operador
                                       ,pr_cdagenci IN crapcdb.cdagenci%TYPE  --> PA
                                       ,pr_cdopcolb IN crapbdc.cdopcolb%TYPE  --> Operador libera��o
                                       ,pr_cdcritic OUT PLS_INTEGER           --> Cr�tica
                                       ,pr_dscritic OUT VARCHAR2) IS          --> Desc. da cr�tica
  /* .............................................................................
    Programa: pc_efetiva_desconto_bordero
    Sistema : CECRED
    Autor   : Lucas Reinert
    Data    : Dezembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para liberar (ou efetivar) a opera��o de desconto de cheques. 
		            Este procedimento realiza a finaliza��o da opera��o de desconto de 
								cheque, onde � creditado o valor l�quido da opera��o na conta do 
								cooperado, como tamb�m os encargos (IOF e tarifa (se houver)).

    Alteracoes: -----
  ..............................................................................*/																			 
	-- Vari�vel de cr�ticas
	vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
	vr_dscritic        VARCHAR2(1000);        --> Desc. Erro        
	-- Tratamento de erros
	vr_exc_erro        EXCEPTION;    
																			 
	-- Vari�veis auxiliares
	vr_index_cheque     PLS_INTEGER;
	vr_tab_cheques      typ_tab_cheques;
	vr_nrdocmto         NUMBER;
  vr_vlborder         NUMBER;
	vr_nrseqdig         NUMBER;
  vr_dtiniiof         DATE;
	vr_dtfimiof         DATE;
  vr_txccdiof         NUMBER;
	vr_flgimune         BOOLEAN;
	vr_dsreturn         VARCHAR2(10);
  vr_tab_erro         gene0001.typ_tab_erro;
	vr_cdpactra         NUMBER;
  vr_nrdrowid         ROWID;
	vr_vllanmto         NUMBER;
	vr_tab_lim_desconto typ_tab_lim_desconto;
  vr_dsdmensg         VARCHAR2(300);
  
  -- Buscar Cooperativa
  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT nmrescop
      FROM crapcop
     WHERE cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  
	-- Buscar border� de desconto
	CURSOR cr_crapbdc(pr_cdcooper IN crapbdc.cdcooper%TYPE
	                 ,pr_nrdconta IN crapbdc.nrdconta%TYPE
									 ,pr_nrborder IN crapbdc.nrborder%TYPE) IS
		SELECT bdc.insitbdc
		      ,bdc.flgassin
					,bdc.dhdassin
					,bdc.cdopeasi
		  FROM crapbdc bdc
		 WHERE bdc.cdcooper = pr_cdcooper
		   AND bdc.nrdconta = pr_nrdconta
			 AND bdc.nrborder = pr_nrborder;
	rw_crapbdc cr_crapbdc%ROWTYPE;
	
	-- Buscar cheques do border�
	CURSOR cr_crapcdb(pr_cdcooper IN crapcdb.cdcooper%TYPE
	                 ,pr_nrdconta IN crapcdb.nrdconta%TYPE
									 ,pr_nrborder IN crapcdb.nrborder%TYPE) IS
		SELECT cdb.dtlibera
          ,cdb.cdcmpchq
          ,cdb.cdbanchq
          ,cdb.cdagechq
          ,cdb.nrctachq
          ,cdb.nrcheque
          ,cdb.vlcheque
          ,cdb.insitana
          ,cdb.dsdocmc7
          ,cdb.nrremret
          ,cdb.inchqcop
          ,cdb.nrddigc3
          ,cdb.dtmvtolt
          ,cdb.cdagenci
          ,cdb.nrdolote
          ,cdb.nrseqdig
          ,cdb.cdbccxlt
		  FROM crapcdb cdb
		 WHERE cdb.cdcooper = pr_cdcooper
		   AND cdb.nrdconta = pr_nrdconta
			 AND cdb.nrborder = pr_nrborder
			 AND cdb.insitana = 1;
			 
	-- Buscar cust�dia de cheque
	CURSOR cr_crapcst(pr_cdcooper IN crapcst.cdcooper%TYPE
	                 ,pr_nrdconta IN crapcst.nrdconta%TYPE
									 ,pr_nrborder IN crapcst.nrborder%TYPE
									 ,pr_cdcmpchq IN crapcst.cdcmpchq%TYPE
									 ,pr_cdbanchq IN crapcst.cdbanchq%TYPE
									 ,pr_cdagechq IN crapcst.cdagechq%TYPE
									 ,pr_nrctachq IN crapcst.nrctachq%TYPE
									 ,pr_nrcheque IN crapcst.nrcheque%TYPE) IS
    SELECT cst.dtmvtolt
		      ,cst.cdagenci
					,cst.cdbccxlt
					,cst.nrdolote
					,cst.nrctachq
		  FROM crapcst cst
		 WHERE cst.cdcooper = pr_cdcooper
			 AND cst.nrdconta = pr_nrdconta
			 AND cst.nrborder = pr_nrborder
			 AND cst.cdcmpchq = pr_cdcmpchq
			 AND cst.cdbanchq = pr_cdbanchq
			 AND cst.cdagechq = pr_cdagechq
			 AND cst.nrctachq = pr_nrctachq
			 AND cst.nrcheque = pr_nrcheque;								 
	rw_crapcst cr_crapcst%ROWTYPE;
	
	-- Buscar informa��es do lote
	CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
	                 ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE) IS 
		SELECT lot.dtmvtolt
		      ,lot.cdagenci
					,lot.cdbccxlt
					,lot.nrdolote
					,lot.nrseqdig
					,lot.qtinfoln
					,lot.qtcompln
					,lot.vlinfocr
					,lot.vlcompcr
					,lot.rowid
		  FROM craplot lot
		 WHERE lot.cdcooper = pr_cdcooper
		   AND lot.dtmvtolt = pr_dtmvtolt
			 AND lot.cdagenci = 1
			 AND lot.cdbccxlt = 100
			 AND lot.nrdolote = 8477;
  rw_craplot cr_craplot%ROWTYPE;
	
	-- Verificar se o lan�amento j� existe
	CURSOR cr_craplcm(pr_cdcooper IN craplcm.cdcooper%TYPE
	                 ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
	                 ,pr_cdagenci IN craplcm.cdagenci%TYPE
									 ,pr_cdbccxlt IN craplcm.cdbccxlt%TYPE
									 ,pr_nrdolote IN craplcm.nrdolote%TYPE
									 ,pr_nrdconta IN craplcm.nrdconta%TYPE
									 ,pr_nrborder IN craplcm.nrdocmto%TYPE) IS
		SELECT 1
		  FROM craplcm lcm
		 WHERE lcm.cdcooper = pr_cdcooper
		   AND lcm.dtmvtolt = pr_dtmvtolt
			 AND lcm.cdagenci = pr_cdagenci
			 AND lcm.cdbccxlt = pr_cdbccxlt
			 AND lcm.nrdolote = pr_nrdolote
			 AND lcm.nrdctabb = pr_nrdconta
			 AND lcm.nrdocmto = pr_nrborder;
	rw_craplcm cr_craplcm%ROWTYPE;
	
	-- Buscar o PA de trabalho do operador para compor n�mero do lote
	CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
	                 ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
		SELECT ope.cdpactra
		  FROM crapope ope
		 WHERE ope.cdcooper = pr_cdcooper
		   AND ope.cdoperad = pr_cdoperad;
	rw_crapope cr_crapope%ROWTYPE;
	
	-- Buscar o Lote do IOF
	CURSOR cr_craplot_iof(pr_cdcooper IN craplot.cdcooper%TYPE
											 ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
											 ,pr_cdpactra IN crapope.cdpactra%TYPE) IS
		SELECT lot.nrseqdig
		      ,lot.rowid
		  FROM craplot lot
		 WHERE lot.cdcooper = pr_cdcooper
		   AND lot.dtmvtolt = pr_dtmvtolt
			 AND lot.cdagenci = 1
			 AND lot.cdbccxlt = 100
			 AND lot.nrdolote = 19000 + pr_cdpactra;
	rw_craplot_iof cr_craplot_iof%ROWTYPE;
	
	-- Buscar cotas para o IOF
	CURSOR cr_crapcot(pr_cdcooper IN crapcot.cdcooper%TYPE
	                 ,pr_nrdconta IN crapcot.nrdconta%TYPE) IS
	  SELECT cot.ROWID
		  FROM crapcot cot
		 WHERE cot.cdcooper = pr_cdcooper
		   AND cot.nrdconta = pr_nrdconta;
  rw_crapcot cr_crapcot%ROWTYPE;			 
	
  -- Buscar valor de limite dispon�vel
  CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE
                   ,pr_nrdconta IN craplim.nrdconta%TYPE
                   ,pr_dtmvtolt IN DATE
									 ,pr_nrborder IN craplcm.nrdocmto%TYPE) IS
    SELECT vllimite
          ,(nvl((SELECT SUM(vlcheque) FROM crapcdb
            WHERE cdcooper = pr_cdcooper
              AND nrdconta = pr_nrdconta
              AND dtlibbdc IS NOT NULL
              AND dtlibera > pr_dtmvtolt
              AND insitchq IN (0,2)
              AND insitana = 1), 0)  + 
            nvl((SELECT SUM(vlcheque) FROM crapcdb
            WHERE cdcooper = pr_cdcooper
              AND nrdconta = pr_nrdconta
              AND nrborder = pr_nrborder
              AND insitchq = 0
              AND insitana = 1), 0)
            )
            vltotchq,
            nrctrlim
     FROM craplim 
    WHERE cdcooper = pr_cdcooper
      AND nrdconta = pr_nrdconta
      AND insitlim = 2 
      AND tpctrlim = 2;									 
  rw_craplim cr_craplim%ROWTYPE;
  
  -- Buscar valor de limite dispon�vel
  CURSOR cr_crapass(pr_cdcooper IN craplim.cdcooper%TYPE
                   ,pr_nrdconta IN craplim.nrdconta%TYPE) IS
    SELECT inpessoa
      FROM crapass
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta; 
  rw_crapass cr_crapass%ROWTYPE;
  
  -- Verificar se o cheque ainda est� pendente de entrega
	CURSOR cr_crapdcc(pr_cdcooper IN crapdcc.cdcooper%TYPE
									 ,pr_nrdconta IN crapdcc.nrdconta%TYPE
									 ,pr_nrborder IN crapdcc.nrborder%TYPE) IS	
	  SELECT 1
      FROM crapdcc dcc
          ,craphcc hcc
          ,crapcdb cdb
     WHERE dcc.cdcooper = pr_cdcooper
       AND dcc.nrdconta = pr_nrdconta
       AND dcc.nrborder = pr_nrborder
       AND dcc.intipmvt IN (1,3)
       AND dcc.cdtipmvt = 1
       AND hcc.cdcooper = dcc.cdcooper
       AND hcc.nrdconta = dcc.nrdconta
       AND hcc.nrremret = dcc.nrremret
       AND hcc.intipmvt = dcc.intipmvt
       AND (dcc.inconcil = 0
        OR  hcc.dtcustod IS NULL)
       AND cdb.cdcooper = dcc.cdcooper
       AND cdb.nrdconta = dcc.nrdconta
       AND cdb.nrborder = dcc.nrborder
       AND cdb.cdcmpchq = dcc.cdcmpchq
       AND cdb.cdbanchq = dcc.cdbanchq
       AND cdb.cdagechq = dcc.cdagechq
       AND cdb.nrctachq = dcc.nrctachq
       AND cdb.nrcheque = dcc.nrcheque
       AND cdb.insitana = 1;
  rw_crapdcc cr_crapdcc%ROWTYPE;
  
	rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  BEGIN
		-- Busca a data do sistema
		OPEN  BTCH0001.cr_crapdat(pr_cdcooper);
		FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
		CLOSE BTCH0001.cr_crapdat;
  
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper
		               ,pr_nrdconta => pr_nrdconta);
		FETCH cr_crapass INTO rw_crapass;
		
		IF cr_crapass%NOTFOUND THEN
			-- Fecha cursor
			CLOSE cr_crapass;
			-- Gerar cr�tica
			vr_cdcritic := 9;
			vr_dscritic := '';
			-- Levanta exce��o
			RAISE vr_exc_erro;
		END IF;
    
	  -- Buscar border� de desconto
    OPEN cr_crapbdc(pr_cdcooper => pr_cdcooper
		               ,pr_nrdconta => pr_nrdconta
									 ,pr_nrborder => pr_nrborder);
		FETCH cr_crapbdc INTO rw_crapbdc;
	
	  -- Se n�o encontrou border�
	  IF cr_crapbdc%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_crapbdc;
			-- Gerar cr�tica
			vr_cdcritic := 0;
			vr_dscritic := 'Border� de desconto de cheque n�o encontrado.';
			-- Levanta exce��o
			RAISE vr_exc_erro;
		END IF;
	
	  -- Se border� j� foi liberado
	  IF rw_crapbdc.insitbdc > 2 THEN
			-- Gerar cr�tica
			vr_cdcritic := 0;
			vr_dscritic := 'Border� j� foi liberado.';
			-- Levantar exce��o
			RAISE vr_exc_erro;
		END IF;
		
    -- Buscar valores do parametro
    pc_busca_tab_limdescont (pr_cdcooper => pr_cdcooper                --> Codigo da cooperativa
                            ,pr_inpessoa => rw_crapass.inpessoa        --> Tipo de pessoa ( 0 - todos 1-Fisica e 2-Juridica)
                            ,pr_tab_lim_desconto => vr_tab_lim_desconto--> Temptable com os dados do limite de desconto                                     
                            ,pr_cdcritic => vr_cdcritic                --> C�digo da cr�tica
                            ,pr_dscritic => vr_dscritic);              --> Descri��o da cr�tica                
    
    -- Se retornou alguma cr�tica
    IF TRIM(vr_dscritic) IS NOT NULL OR 
      nvl(vr_cdcritic,0) > 0 THEN
      -- Levanta exce��o
      RAISE vr_exc_erro;
    END IF;
    
		OPEN cr_craplim (pr_cdcooper => pr_cdcooper
		                ,pr_nrdconta => pr_nrdconta
									  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                    ,pr_nrborder => pr_nrborder);
		FETCH cr_craplim INTO rw_craplim;
		
		IF cr_craplim%NOTFOUND THEN
			-- Fecha cursor
			CLOSE cr_craplim;
			-- Atribui cr�tica
			vr_cdcritic := 0;
			vr_dscritic := 'Cooperado n�o possui limite de desconto de cheque ativo.';
			-- Levanta exce��o
			RAISE vr_exc_erro;
		END IF;
		-- Fecha cursor
		CLOSE cr_craplim;
    
    IF vr_tab_lim_desconto.exists(rw_crapass.inpessoa) THEN
      IF rw_craplim.vltotchq > (rw_craplim.vllimite + (rw_craplim.vllimite * (vr_tab_lim_desconto(rw_crapass.inpessoa).pctollim / 100))) THEN
        -- Atribui cr�tica
        vr_cdcritic := 0;
        vr_dscritic := 'Valor limite de desconto de cheque excedido.';
        -- Levanta exce��o
        RAISE vr_exc_erro;
      END IF;
    ELSE
      vr_cdcritic := 0;
      vr_dscritic := 'Registro de parametros de desconto de cheques nao encontrado.';
      RAISE vr_exc_erro;    
    END IF;
    
    -- Verificar se o cheque ainda est� pendente de entrega
    OPEN cr_crapdcc(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrborder => pr_nrborder);
    FETCH cr_crapdcc INTO rw_crapdcc;
      
    -- Se existir registro � porque o cheque ainda est� pendente de entrega
    IF cr_crapdcc%FOUND THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Border� possui cheque(s) aprovado(s) pendentes de entrega. Libera��o n�o permitida.';
      RAISE vr_exc_erro;      
    END IF;
    -- Fechar cursor
    CLOSE cr_crapdcc;
    
    -- Percorrer todos os cheques do bordero
    FOR rw_crapcdb IN cr_crapcdb(pr_cdcooper => pr_cdcooper
			                          ,pr_nrdconta => pr_nrdconta
																,pr_nrborder => pr_nrborder) LOOP
      
			-- Alimentar PlTable com dados do cheque
			vr_index_cheque := vr_tab_cheques.count;
			vr_tab_cheques(vr_index_cheque).dtlibera := rw_crapcdb.dtlibera;
			vr_tab_cheques(vr_index_cheque).cdcmpchq := rw_crapcdb.cdcmpchq;
			vr_tab_cheques(vr_index_cheque).cdbanchq := rw_crapcdb.cdbanchq;			
			vr_tab_cheques(vr_index_cheque).cdagechq := rw_crapcdb.cdagechq;
			vr_tab_cheques(vr_index_cheque).nrctachq := rw_crapcdb.nrctachq;
			vr_tab_cheques(vr_index_cheque).nrcheque := rw_crapcdb.nrcheque;
			vr_tab_cheques(vr_index_cheque).vlcheque := rw_crapcdb.vlcheque;
			vr_tab_cheques(vr_index_cheque).insitana := rw_crapcdb.insitana;
			vr_tab_cheques(vr_index_cheque).dsdocmc7 := rw_crapcdb.dsdocmc7;
			vr_tab_cheques(vr_index_cheque).nrremret := rw_crapcdb.nrremret;
			vr_tab_cheques(vr_index_cheque).inchqcop := rw_crapcdb.inchqcop;
      vr_tab_cheques(vr_index_cheque).nrddigc3 := rw_crapcdb.nrddigc3;
			vr_tab_cheques(vr_index_cheque).dtmvtolt := rw_crapcdb.dtmvtolt;
			vr_tab_cheques(vr_index_cheque).cdagenci := rw_crapcdb.cdagenci;
			vr_tab_cheques(vr_index_cheque).nrdolote := rw_crapcdb.nrdolote;
			vr_tab_cheques(vr_index_cheque).nrseqdig := rw_crapcdb.nrseqdig;			
			vr_tab_cheques(vr_index_cheque).cdbccxlt := rw_crapcdb.cdbccxlt;
		
    END LOOP;																

		-- Realizar os c�lculos de juros
		pc_calcular_bordero_cheques(pr_cdcooper => pr_cdcooper
															 ,pr_nrdconta => pr_nrdconta
															 ,pr_nrborder => pr_nrborder
															 ,pr_tab_cheques => vr_tab_cheques
															 ,pr_cdcritic => vr_cdcritic
															 ,pr_dscritic => vr_dscritic);
															 
		-- Se retornou alguma cr�tica										 
		IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			-- Levantar exce��o
			RAISE vr_exc_erro;
		END IF;
						
		-- Iterar sobre os cheques aprovados						
		FOR vr_idx_cheque IN vr_tab_cheques.first..vr_tab_cheques.last LOOP
			-- Se o cheque for da cooperativa
			IF vr_tab_cheques(vr_idx_cheque).inchqcop = 1 THEN
				-- Criar nrdocmto
	      vr_nrdocmto := to_number(to_char(vr_tab_cheques(vr_idx_cheque).nrcheque,'fm000000') ||
					             to_char(vr_tab_cheques(vr_idx_cheque).nrddigc3,'fm0'));
				
				BEGIN
					-- Inserir lan�amento automatico
					INSERT INTO craplau
					       (dtmvtolt
								 ,cdagenci
								 ,cdbccxlt
								 ,nrdolote
								 ,nrdconta
								 ,nrdocmto
								 ,vllanaut
								 ,cdhistor
								 ,nrseqdig
								 ,nrdctabb
								 ,cdbccxpg
								 ,dtmvtopg
								 ,tpdvalor
								 ,insitlau
								 ,cdcritic
								 ,nrcrcard
								 ,nrseqlan
								 ,cdcooper
								 ,cdseqtel)
					 VALUES(vr_tab_cheques(vr_idx_cheque).dtmvtolt
					       ,vr_tab_cheques(vr_idx_cheque).cdagenci
								 ,vr_tab_cheques(vr_idx_cheque).cdbccxlt
								 ,vr_tab_cheques(vr_idx_cheque).nrdolote
								 ,pr_nrdconta
								 ,vr_nrdocmto
								 ,vr_tab_cheques(vr_idx_cheque).vlcheque
								 ,521
								 ,vr_tab_cheques(vr_idx_cheque).nrseqdig
								 ,vr_tab_cheques(vr_idx_cheque).nrctachq
								 ,011
								 ,vr_tab_cheques(vr_idx_cheque).dtlibera
								 ,1
								 ,1
								 ,0
								 ,0
								 ,0
								 ,pr_cdcooper
								 ,(to_char(vr_tab_cheques(vr_idx_cheque).dtmvtolt, 'DD/MM/RRRR') || ' ' ||
									to_char(vr_tab_cheques(vr_idx_cheque).cdagenci, 'fm000') 		  || ' ' ||
									to_char(vr_tab_cheques(vr_idx_cheque).cdbccxlt, 'fm000') 		  || ' ' ||
									to_char(vr_tab_cheques(vr_idx_cheque).nrdolote, 'fm000000')   || ' ' ||
									to_char(vr_tab_cheques(vr_idx_cheque).cdcmpchq, 'fm000') 		  || ' ' ||
									to_char(vr_tab_cheques(vr_idx_cheque).cdbanchq, 'fm000') 		  || ' ' ||
									to_char(vr_tab_cheques(vr_idx_cheque).cdagechq, 'fm0000') 	  || ' ' ||
									to_char(vr_tab_cheques(vr_idx_cheque).nrctachq, 'fm00000000') || ' ' ||
									to_char(vr_tab_cheques(vr_idx_cheque).nrcheque, 'fm000000')));
				EXCEPTION
					WHEN OTHERS THEN      
						-- Gerar cr�tica
						vr_cdcritic := 0;
						vr_dscritic := REPLACE(REPLACE('Erro ao inserir lan�amento autom�tico: ' || SQLERRM, chr(13)),chr(10));																			
						-- Levantar exce��o
						RAISE vr_exc_erro;
				END;
				-- Buscar cust�dia
				OPEN cr_crapcst(pr_cdcooper => pr_cdcooper
				               ,pr_nrdconta => pr_nrdconta
											 ,pr_nrborder => pr_nrborder
											 ,pr_cdcmpchq => vr_tab_cheques(vr_idx_cheque).cdcmpchq
											 ,pr_cdbanchq => vr_tab_cheques(vr_idx_cheque).cdbanchq
											 ,pr_cdagechq => vr_tab_cheques(vr_idx_cheque).cdagechq
											 ,pr_nrctachq => vr_tab_cheques(vr_idx_cheque).nrctachq
											 ,pr_nrcheque => vr_tab_cheques(vr_idx_cheque).nrcheque);
				FETCH cr_crapcst INTO rw_crapcst;
				
				-- Se n�o encontrou
				IF cr_crapcst%NOTFOUND THEN
					-- Fechar cursor
					CLOSE cr_crapcst;
					-- Gerar cr�tica
					vr_cdcritic := 0;
					vr_dscritic := 'Cust�dia de cheque n�o encontrada.';
					-- Levantar exce��o
					RAISE vr_exc_erro;
				END IF;
				-- Fechar cursor
				CLOSE cr_crapcst;
				
				BEGIN
					-- Atualizar lan�amento autom�tico de custodia
					UPDATE craplau lau
					   SET lau.dtdebito = rw_crapdat.dtmvtolt
						    ,lau.insitlau = 3  -- Cancelar
					 WHERE lau.cdcooper = pr_cdcooper
             AND lau.dtmvtolt = rw_crapcst.dtmvtolt
			       AND lau.cdagenci = rw_crapcst.cdagenci
			       AND lau.cdbccxlt = rw_crapcst.cdbccxlt 
			       AND lau.nrdolote = rw_crapcst.nrdolote
			       AND lau.nrdctabb = rw_crapcst.nrctachq
			       AND lau.nrdocmto = vr_nrdocmto;
				EXCEPTION
					WHEN OTHERS THEN      
						-- Gerar cr�tica
						vr_cdcritic := 0;
						vr_dscritic := REPLACE(REPLACE('Erro ao atualizar lan�amento autom�tico: ' || SQLERRM, chr(13)),chr(10));																			
						-- Levantar exce��o
						RAISE vr_exc_erro;				  	
				END;
			END IF;
			
			BEGIN			
				-- Atualizar cheque do border�
				UPDATE crapcdb cdb 
				   SET cdb.vlliquid = vr_tab_cheques(vr_idx_cheque).vlliquid
				     , cdb.insitchq = 2
				     , cdb.dtlibbdc = rw_crapdat.dtmvtolt
				 WHERE cdb.cdcooper = pr_cdcooper
				   AND cdb.nrdconta = pr_nrdconta
					 AND cdb.nrborder = pr_nrborder
					 AND cdb.cdcmpchq = vr_tab_cheques(vr_idx_cheque).cdcmpchq
					 AND cdb.cdbanchq = vr_tab_cheques(vr_idx_cheque).cdbanchq
					 AND cdb.cdagechq = vr_tab_cheques(vr_idx_cheque).cdagechq
					 AND cdb.nrctachq = vr_tab_cheques(vr_idx_cheque).nrctachq
					 AND cdb.nrcheque = vr_tab_cheques(vr_idx_cheque).nrcheque;
	    EXCEPTION
				WHEN OTHERS THEN      
					-- Gerar cr�tica
					vr_cdcritic := 0;
					vr_dscritic := REPLACE(REPLACE('Erro ao atualizar cheque do border�: ' || SQLERRM, chr(13)),chr(10));																			
					-- Levantar exce��o
					RAISE vr_exc_erro;				  	
			END;			
			-- Guardar o valor total liquido do border� para lan�ar na conta do cooperado
			vr_vlborder := nvl(vr_vlborder,0) + vr_tab_cheques(vr_idx_cheque).vlliquid;
		END LOOP;
		
		-- Tira vinculo da dcc e cst com o border�
		BEGIN
      UPDATE crapdcc dcc
         SET dcc.nrborder = 0
       WHERE dcc.cdcooper = pr_cdcooper
         AND dcc.nrdconta = pr_nrdconta
         AND dcc.nrborder = pr_nrborder
         AND EXISTS(SELECT 1 
                      FROM crapcdb cdb
                    WHERE cdb.cdcooper = dcc.cdcooper 
                      AND cdb.nrdconta = dcc.nrdconta
                      AND cdb.nrborder = dcc.nrborder
                      AND cdb.cdcmpchq = dcc.cdcmpchq
                      AND cdb.cdbanchq = dcc.cdbanchq
                      AND cdb.cdagechq = dcc.cdagechq
                      AND cdb.nrctachq = dcc.nrctachq
                      AND cdb.nrcheque = dcc.nrcheque
                      AND cdb.insitana = 2);
      
      UPDATE crapcst cst
         SET cst.nrborder = 0
       WHERE cst.cdcooper = pr_cdcooper
         AND cst.nrdconta = pr_nrdconta
         AND cst.nrborder = pr_nrborder
         AND EXISTS(SELECT 1 
                      FROM crapcdb cdb
                    WHERE cdb.cdcooper = cst.cdcooper 
                      AND cdb.nrdconta = cst.nrdconta
                      AND cdb.nrborder = cst.nrborder
                      AND cdb.cdcmpchq = cst.cdcmpchq
                      AND cdb.cdbanchq = cst.cdbanchq
                      AND cdb.cdagechq = cst.cdagechq
                      AND cdb.nrctachq = cst.nrctachq
                      AND cdb.nrcheque = cst.nrcheque
                      AND cdb.insitana = 2);
    EXCEPTION
      WHEN OTHERS THEN
        -- Gerar cr�tica
				vr_cdcritic := 0;
				vr_dscritic := REPLACE(REPLACE('Erro ao desvincular cheques reprovados com o border� de desconto: ' || SQLERRM, chr(13)),chr(10));																			
				-- Levantar exce��o
				RAISE vr_exc_erro;
    END;
    
		BEGIN
			-- Atualizar border� de desconto de cheque
			UPDATE crapbdc bdc
			   SET bdc.insitbdc = 3 /*  Liberado  */
				    ,bdc.cdopeori = pr_cdoperad 
				    ,bdc.cdageori = pr_cdagenci
				    ,bdc.dtinsori = trunc(SYSDATE)
				    ,bdc.dtlibbdc = rw_crapdat.dtmvtolt
				    ,bdc.cdopelib = pr_cdoperad
				    ,bdc.cdopcolb = pr_cdopcolb /* Operador Coordenador liberacao */
						,bdc.dhdassin = CASE WHEN bdc.flgassin = 1 AND TRIM(bdc.dhdassin) IS NULL THEN trunc(SYSDATE) ELSE NULL END
 						,bdc.cdopeasi = CASE WHEN bdc.flgassin = 1 AND TRIM(bdc.cdopeasi) IS NULL THEN pr_cdoperad ELSE NULL END
 		   WHERE bdc.cdcooper = pr_cdcooper 
		     AND bdc.nrdconta = pr_nrdconta
		     AND bdc.nrborder = pr_nrborder;
				 
		EXCEPTION
			WHEN OTHERS THEN      
				-- Gerar cr�tica
				vr_cdcritic := 0;
				vr_dscritic := REPLACE(REPLACE('Erro ao atualizar border� de desconto de cheque: ' || SQLERRM, chr(13)),chr(10));																			
				-- Levantar exce��o
				RAISE vr_exc_erro;
		END;
		
		-- Buscar lote
		OPEN cr_craplot(pr_cdcooper => pr_cdcooper
		               ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
		FETCH cr_craplot INTO rw_craplot;
		
		IF cr_craplot%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_craplot;
      BEGIN
				-- Se n�o existir lote, criar
				INSERT INTO craplot
				       (dtmvtolt
							 ,cdagenci
							 ,cdbccxlt
							 ,nrdolote
							 ,tplotmov
							 ,cdoperad
							 ,cdhistor
							 ,cdcooper)
				 VALUES(rw_crapdat.dtmvtolt
				       ,1
							 ,100
							 ,8477
							 ,1
							 ,pr_cdoperad
							 ,270
							 ,pr_cdcooper);
			EXCEPTION
				WHEN OTHERS THEN      
					-- Gerar cr�tica
					vr_cdcritic := 0;
					vr_dscritic := REPLACE(REPLACE('Erro ao criar novo lote: ' || SQLERRM, chr(13)),chr(10));																			
					-- Levantar exce��o
					RAISE vr_exc_erro;				
			END;
			-- Buscar lote
			OPEN cr_craplot(pr_cdcooper => pr_cdcooper
										 ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
			FETCH cr_craplot INTO rw_craplot;
			-- Fechar cursor
			CLOSE cr_craplot;
		END IF;
		
		-- Verificar se lan�amento j� existe
		OPEN cr_craplcm(pr_cdcooper => pr_cdcooper
	                 ,pr_dtmvtolt => rw_craplot.dtmvtolt
	                 ,pr_cdagenci => rw_craplot.cdagenci
									 ,pr_cdbccxlt => rw_craplot.cdbccxlt
									 ,pr_nrdolote => rw_craplot.nrdolote
									 ,pr_nrdconta => pr_nrdconta
									 ,pr_nrborder => pr_nrborder);
		FETCH cr_craplcm INTO rw_craplcm;
		-- Se n�o encontrou
		IF cr_craplcm%NOTFOUND THEN
			BEGIN
				-- Criar lan�amento de desconto de bordero
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
								,nrdctitg
								,nrautdoc
								,cdcooper
								,cdpesqbb)
				  VALUES(rw_craplot.dtmvtolt
					      ,rw_craplot.cdagenci
								,rw_craplot.cdbccxlt
								,rw_craplot.nrdolote
								,pr_nrdconta
								,pr_nrborder
								,vr_vlborder
								,270
								,rw_craplot.nrseqdig + 1
								,pr_nrdconta
								,to_char(pr_nrdconta, 'fm00000000')
								,0
								,pr_cdcooper
								,'Desconto do bordero ' || to_char(pr_nrborder, 'fm999g999g990'))
				RETURNING nrseqdig INTO vr_nrseqdig;
			EXCEPTION
				WHEN OTHERS THEN      
					-- Gerar cr�tica
					vr_cdcritic := 0;
					vr_dscritic := REPLACE(REPLACE('Erro ao criar novo lan�amento: ' || SQLERRM, chr(13)),chr(10));																			
					-- Levantar exce��o
					RAISE vr_exc_erro;				
			END;
			
			BEGIN 
			  -- Atualizar valores do lote				
			  UPDATE craplot lot
				   SET lot.nrseqdig = vr_nrseqdig
					    ,lot.qtinfoln = lot.qtinfoln + 1
							,lot.qtcompln = lot.qtcompln + 1
							,lot.vlinfocr = lot.vlinfocr + vr_vlborder
							,lot.vlcompcr = lot.vlcompcr + vr_vlborder
				WHERE lot.rowid = rw_craplot.rowid;
			EXCEPTION
				WHEN OTHERS THEN      
					-- Gerar cr�tica
					vr_cdcritic := 0;
					vr_dscritic := REPLACE(REPLACE('Erro ao atualizar valores do lote: ' || SQLERRM, chr(13)),chr(10));																			
					-- Levantar exce��o
					RAISE vr_exc_erro;								
			END;
		END IF;
		
		-- Busca taxa de IOF
		GENE0005.pc_busca_iof(pr_cdcooper => pr_cdcooper
		                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
												 ,pr_dtiniiof => vr_dtiniiof
												 ,pr_dtfimiof => vr_dtfimiof
												 ,pr_txccdiof => vr_txccdiof
												 ,pr_cdcritic => vr_cdcritic
												 ,pr_dscritic => vr_dscritic);
												 
		-- Se retornou alguma cr�tica ao buscar IOF
		IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			RAISE vr_exc_erro;
		END IF;
    -- Verificar se possui imunidade tribut�ria		
		IMUT0001.pc_verifica_imunidade_trib(pr_cdcooper => pr_cdcooper
		                                   ,pr_nrdconta => pr_nrdconta
																			 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
																			 ,pr_flgrvvlr => TRUE
																			 ,pr_cdinsenc => 3
																			 ,pr_vlinsenc => ROUND((vr_vlborder * vr_txccdiof), 2)
																			 ,pr_flgimune => vr_flgimune
																			 ,pr_dsreturn => vr_dsreturn
																			 ,pr_tab_erro => vr_tab_erro);
		-- Se retornou algum erro
    IF vr_tab_erro.count > 0 AND vr_dsreturn = 'NOK' THEN
			-- Atribuir cr�ticas
			vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
			vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;			
			-- Levantar exce��o
			RAISE vr_exc_erro;
		END IF;
		
		-- Se for imune de tributa��o
		IF vr_flgimune = FALSE THEN
			-- Buscar PA do operador
			OPEN cr_crapope(pr_cdcooper => pr_cdcooper
			               ,pr_cdoperad => pr_cdoperad);
			FETCH cr_crapope INTO rw_crapope;
			
			-- Se n�o encontrar
			IF cr_crapope%NOTFOUND THEN
				vr_cdpactra := 0;
			ELSE
				vr_cdpactra := rw_crapope.cdpactra;
			END IF;
			-- Fechar cursor
			CLOSE cr_crapope;
			
			-- Buscar lote do IOF
			OPEN cr_craplot_iof(pr_cdcooper => pr_cdcooper
												 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
												 ,pr_cdpactra => vr_cdpactra);
			FETCH cr_craplot_iof INTO rw_craplot_iof;
			
			-- Se n�o encontrou IOF
			IF cr_craplot_iof%NOTFOUND THEN
				BEGIN
          INSERT INTO craplot(dtmvtolt
					                   ,cdagenci
														 ,cdbccxlt
														 ,nrdolote
														 ,tplotmov
														 ,cdcooper)
											 VALUES(rw_crapdat.dtmvtolt
											       ,1
														 ,100
														 ,(19000 + vr_cdpactra)
														 ,1
														 ,pr_cdcooper)
				  RETURNING nrseqdig, ROWID INTO vr_nrseqdig, vr_nrdrowid;
				EXCEPTION
					WHEN OTHERS THEN      
						-- Gerar cr�tica
						vr_cdcritic := 0;
						vr_dscritic := REPLACE(REPLACE('Erro ao inserir lote (IOF): ' || SQLERRM, chr(13)),chr(10));																			
						-- Levantar exce��o
						RAISE vr_exc_erro;
				END;
			ELSE
				-- Se encontrou, atribui valores �s vari�veis
				vr_nrseqdig := rw_craplot_iof.nrseqdig;
				vr_nrdrowid := rw_craplot_iof.rowid;
			END IF;
			-- Fechar cursor
			CLOSE cr_craplot_iof;
			
			-- Cria lan�amento na craplcm refente ao IOF
			BEGIN
				INSERT INTO craplcm(dtmvtolt
													 ,cdagenci
													 ,cdbccxlt
													 ,nrdolote
													 ,nrdconta
													 ,nrdctabb
													 ,nrdctitg
													 ,nrdocmto
													 ,cdhistor
													 ,nrseqdig
													 ,cdpesqbb
													 ,vllanmto
													 ,cdcooper)
										 VALUES(rw_crapdat.dtmvtolt
										       ,1
													 ,100
													 ,(19000 + vr_cdpactra)
													 ,pr_nrdconta
													 ,pr_nrdconta
													 ,to_char(pr_nrdconta, 'fm00000000')
													 ,pr_nrborder
													 ,324
													 ,(vr_nrseqdig + 1)
													 ,to_char(vr_vlborder, 'fm000g000g000d00')
													 ,ROUND((vr_vlborder * vr_txccdiof), 2)
													 ,pr_cdcooper)
					RETURNING vllanmto INTO vr_vllanmto;
				EXCEPTION
					WHEN OTHERS THEN      
						-- Gerar cr�tica
						vr_cdcritic := 0;
						vr_dscritic := REPLACE(REPLACE('Erro ao criar novo lan�amento (IOF): ' || SQLERRM, chr(13)),chr(10));																			
						-- Levantar exce��o
						RAISE vr_exc_erro;
			END;			
			-- Atualizar valores da craplot refente ao IOF			
			BEGIN
			  UPDATE craplot lot
				   SET lot.vlinfodb = lot.vlinfodb + vr_vllanmto 
					    ,lot.vlcompdb = lot.vlcompdb + vr_vllanmto 
							,lot.qtinfoln = lot.qtinfoln + 1
							,lot.qtcompln = lot.qtinfoln + 1
							,lot.nrseqdig = lot.nrseqdig + 1
				 WHERE lot.rowid = vr_nrdrowid;
				
			EXCEPTION
				WHEN OTHERS THEN      
					-- Gerar cr�tica
					vr_cdcritic := 0;
					vr_dscritic := REPLACE(REPLACE('Erro ao atualizar lote (IOF): ' || SQLERRM, chr(13)),chr(10));																			
					-- Levantar exce��o
					RAISE vr_exc_erro;
			END;
			-- Buscar cota de IOF
	    OPEN cr_crapcot(pr_cdcooper => pr_cdcooper
			               ,pr_nrdconta => pr_nrdconta);
			FETCH cr_crapcot INTO rw_crapcot;
			
			-- Se n�o encontrou registro
			IF cr_crapcot%NOTFOUND THEN
				-- Fechar cursor
				CLOSE cr_crapcot;
				-- Gerar cr�tica
				vr_cdcritic := 0;
				vr_dscritic := 'Registro de cota de IOF n�o encontrado';
				-- Levantar exce��o
				RAISE vr_exc_erro;
			END IF;
			
			BEGIN
				-- Atualizar valores das cotas
			  UPDATE crapcot cot
				   SET cot.vliofapl = cot.vliofapl + vr_vllanmto
					    ,cot.vlbsiapl = cot.vlbsiapl + vr_vlborder
				 WHERE cot.rowid = rw_crapcot.rowid;
			EXCEPTION
				WHEN OTHERS THEN      
					-- Gerar cr�tica
					vr_cdcritic := 0;
					vr_dscritic := REPLACE(REPLACE('Erro ao atualizar valores das cotas de IOF: ' || SQLERRM, chr(13)),chr(10));																			
					-- Levantar exce��o
					RAISE vr_exc_erro;				
			END;
		END IF;
    
    OPEN cr_crapcop(pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    IF cr_crapcop%NOTFOUND THEN
      vr_cdcritic := 651;
      RAISE vr_exc_erro;
    END IF;
    
    vr_dsdmensg := 'Seu border� de desconto de cheque n� ' || pr_nrborder || 
                   ' foi liberado.' || '\n' ||
                   ' Em caso de d�vidas, favor dirigir-se ao seu PA de relacionamento.';

    -- Insere na tabela de mensagens (CRAPMSG)
    GENE0003.pc_gerar_mensagem(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_idseqttl => 0 /* Titular */
                              ,pr_cdprogra => 'DESCTO' /* Programa */
                              ,pr_inpriori => 0
                              ,pr_dsdmensg => vr_dsdmensg /* corpo da mensagem */
                              ,pr_dsdassun => 'Border� de Desconto de Cheque Liberado' /* Assunto */
                              ,pr_dsdremet => rw_crapcop.nmrescop 
                              ,pr_dsdplchv => 'Desconto de Cheque'
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_cdcadmsg => 0
                              ,pr_dscritic => vr_dscritic);
    
    -- Se ocorrer erro
    IF vr_dscritic IS NOT NULL THEN
      vr_cdcritic := 0;
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
      -- Efetuar rollback
      ROLLBACK;      
    WHEN OTHERS THEN      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := REPLACE(REPLACE('Nao foi possivel efetivar o border� de desconto de cheque: ' || SQLERRM, chr(13)),chr(10));																			
			-- Efetuar Rollback
			ROLLBACK;				 																			 
	END pc_efetiva_desconto_bordero;
	
	PROCEDURE pc_resgata_cheques_bordero(pr_cdcooper IN crapcdb.cdcooper%TYPE  --> Cooperativa
                                      ,pr_nrdconta IN crapcdb.nrdconta%TYPE  --> Nr. da Conta
                                      ,pr_nrborder IN crapcdb.nrborder%TYPE  --> Nr. Border�
                                      ,pr_cdoperad IN crapcdb.cdopeana%TYPE  --> C�d. operador
																	    ,pr_tab_cheques IN typ_tab_cheques     --> PlTable com dados dos cheques
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Cr�tica
                                      ,pr_dscritic OUT VARCHAR2) IS          --> Desc. da cr�tica
  /* .............................................................................
    Programa: pc_resgata_cheques_bordero
    Sistema : CECRED
    Autor   : Lucas Reinert
    Data    : Dezembro/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para resgatar os cheques do bordero.

    Alteracoes: -----
  ..............................................................................*/																			 
	-- Vari�vel de cr�ticas
	vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
	vr_dscritic        VARCHAR2(1000);        --> Desc. Erro        
	-- Tratamento de erros
	vr_exc_erro        EXCEPTION;    
	
	-- Vari�veis auxiliares
	vr_dstextab craptab.dstextab%TYPE;
	vr_qtdiasut INTEGER;
	vr_qtdiasli INTEGER;
	vr_hrlimite INTEGER;
	vr_nrdocmto NUMBER;
	vr_dtjurtab DATE;
	vr_tab_resgate_erro cust0001.typ_erro_resgate;
	
	rw_crapdat btch0001.cr_crapdat%ROWTYPE;
	
	-- Buscar border�
	CURSOR cr_crapbdc(pr_cdcooper IN crapbdc.cdcooper%TYPE
	                 ,pr_nrdconta IN crapbdc.nrdconta%TYPE
									 ,pr_nrborder IN crapbdc.nrborder%TYPE) IS 
	  SELECT bdc.insitbdc
		      ,bdc.dtlibbdc
		  FROM crapbdc bdc
		 WHERE bdc.cdcooper = pr_cdcooper
		   AND bdc.nrdconta = pr_nrdconta
			 AND bdc.nrborder = pr_nrborder;
	rw_crapbdc cr_crapbdc%ROWTYPE;
		
	-- Buscar cheques do bordero
	CURSOR cr_crapcdb(pr_cdcooper IN crapcdb.cdcooper%TYPE
	                 ,pr_cdcmpchq IN crapcdb.cdcmpchq%TYPE
									 ,pr_cdbanchq IN crapcdb.cdbanchq%TYPE
									 ,pr_cdagechq IN crapcdb.cdagechq%TYPE
									 ,pr_nrctachq IN crapcdb.nrctachq%TYPE
									 ,pr_nrcheque in crapcdb.nrcheque%TYPE
									 ,pr_dtdevolu IN crapcdb.dtdevolu%TYPE) IS
		SELECT 1
		  FROM crapcdb cdb
		 WHERE cdb.cdcooper = pr_cdcooper
		   AND cdb.cdcmpchq = pr_cdcmpchq
			 AND cdb.cdbanchq = pr_cdbanchq
			 AND cdb.cdagechq = pr_cdagechq
			 AND cdb.nrctachq = pr_nrctachq
			 AND cdb.nrcheque = pr_nrcheque
			 AND cdb.dtdevolu = pr_dtdevolu;
		rw_crapcdb cr_crapcdb%ROWTYPE;
		
		-- Busca cheques custodiados ainda n�o resgatados			
		CURSOR cr_crapcst(pr_cdcooper IN crapcop.cdcooper%TYPE
										 ,pr_dsdocmc7 IN VARCHAR2) IS
			SELECT 1
				FROM crapcst cst
			 WHERE cst.cdcooper = pr_cdcooper
				 AND cst.nrdconta = pr_nrdconta
				 AND UPPER(cst.dsdocmc7) = UPPER(pr_dsdocmc7)
				 AND cst.dtdevolu IS NULL
				 AND cst.insitchq = 0;
		rw_crapcst cr_crapcst%ROWTYPE;

	BEGIN
		-- Busca a data do sistema
		OPEN  BTCH0001.cr_crapdat(pr_cdcooper);
		FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
		CLOSE BTCH0001.cr_crapdat;
	
		-- Busca dstextab
		vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
		                                         ,pr_nmsistem => 'CRED'
																						 ,pr_tptabela => 'USUARI'
																						 ,pr_cdempres => 11
																						 ,pr_cdacesso => 'BLQRESGCHQ'
																						 ,pr_tpregist => 00);
		-- Se tab bloqueia resgate de cheque																			 
    IF vr_dstextab = 'S' THEN
			-- Gerar cr�tica
			vr_cdcritic := 959;
			-- Levantar exce��o
			RAISE vr_exc_erro;
		END IF;
		
		-- Buscar border�
		OPEN cr_crapbdc(pr_cdcooper => pr_cdcooper
		               ,pr_nrdconta => pr_nrdconta
									 ,pr_nrborder => pr_nrborder);
		FETCH cr_crapbdc INTO rw_crapbdc;
		
		-- Se n�o encontrou border�
		IF cr_crapbdc%NOTFOUND THEN
			-- Fechar cursor
			CLOSE cr_crapbdc;
			-- Gerar cr�tica
			vr_cdcritic := 0;
			vr_dscritic := 'Border� n�o encontrado.';
			-- Levantar exce��o
			RAISE vr_exc_erro;
		END IF;
		-- Fechar cursor
		CLOSE cr_crapbdc;
		
		-- Se n�o estiver liberado
		IF rw_crapbdc.insitbdc <> 3 THEN
			-- Fechar cursor
			CLOSE cr_crapbdc;
			-- Gerar cr�tica
			vr_cdcritic := 0;
			vr_dscritic := 'Border� deve estar liberado.';
			-- Levantar exce��o
			RAISE vr_exc_erro;			
		END IF;
						
		-- Buscar data parametro de referencia para calculo de juros
		vr_dtjurtab :=	to_date(GENE0001.fn_param_sistema (pr_cdcooper => 0
                                                     ,pr_nmsistem => 'CRED'
                                                     ,pr_cdacesso => 'DT_BLOQ_ARQ_DSC_CHQ')
                           ,'DD/MM/RRRR');
		
		IF vr_dtjurtab IS NULL THEN
			-- Gerar cr�tica
			vr_cdcritic := 0;
			vr_dscritic := 'Par�metro de refer�ncia de c�lculo de juros n�o encontrado.';
			-- Levantar exce��o
			RAISE vr_exc_erro;
		END IF;
		
		-- Busca dstextab
		vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
		                                         ,pr_nmsistem => 'CRED'
																						 ,pr_tptabela => 'USUARI'
																						 ,pr_cdempres => 11
																						 ,pr_cdacesso => 'LIMDESCONT'
																						 ,pr_tpregist => 00);

    FOR vr_index IN pr_tab_cheques.first..pr_tab_cheques.last LOOP
			
			IF vr_dstextab IS NOT NULL THEN
				-- Calculoar a quantidade de dias �teis
				vr_qtdiasut := gene0005.fn_calc_qtd_dias_uteis(pr_cdcooper => pr_cdcooper
																											,pr_dtinical => rw_crapdat.dtmvtolt
																											,pr_dtfimcal => pr_tab_cheques(vr_index).dtlibera);

			  vr_qtdiasli := to_number(substr(vr_dstextab, 121,02)); -- Quantidade de dias limite
				vr_hrlimite := to_number(substr(vr_dstextab, 124,05)); -- Hora limite
				
				-- Expirou data limite para resgate de cheque
				IF vr_qtdiasut < vr_qtdiasli THEN
					-- Gerar cr�tica
				  vr_cdcritic := 960;	
					-- Levantar exce��o
					RAISE vr_exc_erro;
				ELSIF vr_qtdiasut = vr_qtdiasli THEN
					-- Expirou data e hora limite para resgate de cheque
					IF to_char(SYSDATE, 'SSSSS') > vr_hrlimite THEN
						-- Gerar cr�tica
						vr_cdcritic := 960;	
						-- Levantar exce��o
						RAISE vr_exc_erro;					
					END IF;
				END IF;
			END IF;
			
			-- J� resgatado
			IF pr_tab_cheques(vr_index).insitchq = 1 THEN
				-- Gerar cr�tica
			  vr_cdcritic := 672;
				-- Levantar exce��o
				RAISE vr_exc_erro;
			-- Processado em dias anteriores
			ELSIF pr_tab_cheques(vr_index).insitchq = 2 AND
			      pr_tab_cheques(vr_index).dtlibera <= rw_crapdat.dtmvtolt THEN
				-- Gerar cr�tica
			  vr_cdcritic := 670;
				-- Levantar exce��o
				RAISE vr_exc_erro;
			END IF;
			
			-- Verificar se cheque j� foi resgatado hoje
			OPEN cr_crapcdb(pr_cdcooper => pr_cdcooper
			               ,pr_cdcmpchq => pr_tab_cheques(vr_index).cdcmpchq
										 ,pr_cdbanchq => pr_tab_cheques(vr_index).cdbanchq
										 ,pr_cdagechq => pr_tab_cheques(vr_index).cdagechq
										 ,pr_nrctachq => pr_tab_cheques(vr_index).nrctachq
										 ,pr_nrcheque => pr_tab_cheques(vr_index).nrcheque
										 ,pr_dtdevolu => rw_crapdat.dtmvtolt);
			FETCH cr_crapcdb INTO rw_crapcdb;
			
			-- Se encontrou
			IF cr_crapcdb%FOUND THEN
				-- Fechar cursor
				CLOSE cr_crapcdb;
				-- Gerar cr�tica
				vr_cdcritic := 673;
				-- Levantar exece��o
				RAISE vr_exc_erro;
			END IF;
			-- Fechar cursor
			CLOSE cr_crapcdb;

      vr_nrdocmto := to_number(to_char(pr_tab_cheques(vr_index).nrcheque, 'fm000000')
			                      || to_char(pr_tab_cheques(vr_index).nrddigc3, 'fm0'));
														
			IF pr_tab_cheques(vr_index).insitchq = 2 THEN -- Cheque j� descontado
			  -- Resgatar cheque com data de Liberacao inferior a D-2  
				IF pr_tab_cheques(vr_index).dtlibera <= rw_crapdat.dtmvtopr THEN
				  -- Gerar cr�tica
				  vr_cdcritic := 677;
				  -- Levantar exce��o
				  RAISE vr_exc_erro;
				END IF;
				 
				IF pr_tab_cheques(vr_index).dtlibera > rw_crapdat.dtmvtolt THEN
          IF vr_dtjurtab >= rw_crapbdc.dtlibbdc THEN
						-- Utilizar o modo de c�lculo novo (juros simples)
		        pc_calcular_bordero_simples(pr_cdcooper => pr_cdcooper --> Cooperativa
																			 ,pr_nrdconta => pr_nrdconta --> N�mero da conta
																			 ,pr_nrborder => pr_nrborder --> numero do bordero
																			 ,pr_cdoperad => pr_cdoperad --> Operador
																			 ,pr_tab_cheques => pr_tab_cheques(vr_index)     --> PlTable com dados dos cheques
																			 ,pr_cdcritic => vr_cdcritic --> C�d. da cr�tica
																			 ,pr_dscritic => vr_dscritic); --> Desc. da cr�tica
																			 
						IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
						  -- Levantar exce��o
						  RAISE vr_exc_erro;
						END IF;																			 
				  ELSE
						-- Utilizar o modo de c�lculo antigo (juros composto)
						pc_calcular_bordero_composto(pr_cdcooper => pr_cdcooper --> Cooperativa
																				,pr_nrdconta => pr_nrdconta --> N�mero da conta
																				,pr_nrborder => pr_nrborder --> numero do bordero
																			  ,pr_cdoperad => pr_cdoperad --> Operador
																				,pr_tab_cheques => pr_tab_cheques(vr_index)     --> PlTable com dados dos cheques
																				,pr_cdcritic => vr_cdcritic --> C�d. da cr�tica
																				,pr_dscritic => vr_dscritic); --> Desc. da cr�tica
																				
						IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
						  -- Levantar exce��o
						  RAISE vr_exc_erro;
						END IF;
					END IF;
					-- Se for cheque da cooperativa
					IF pr_tab_cheques(vr_index).inchqcop = 1 THEN
						BEGIN
							-- Atualiza lan�amento automatico
							UPDATE craplau lau
								 SET lau.dtdebito = rw_crapdat.dtmvtolt
										,lau.insitlau = 3
							 WHERE lau.cdcooper = pr_cdcooper
								 AND lau.dtmvtolt = pr_tab_cheques(vr_index).dtmvtolt
								 AND lau.cdagenci = pr_tab_cheques(vr_index).cdagenci
								 AND lau.cdbccxlt = pr_tab_cheques(vr_index).cdbccxlt 
								 AND lau.nrdolote = pr_tab_cheques(vr_index).nrdolote
								 AND lau.nrdctabb = pr_tab_cheques(vr_index).nrctachq
								 AND lau.nrdocmto = vr_nrdocmto;
            EXCEPTION
							WHEN OTHERS THEN
								-- Gerar cr�tica
								vr_cdcritic := 0;
								vr_dscritic := 'Erro ao atualizar lan�amento autom�tico ' || SQLERRM;
								-- Levantar exce��o
								RAISE vr_exc_erro;
						END;
          END IF;					
				END IF;
				-- Atualizar informa��es do cheque no border�
				UPDATE crapcdb cdb
					 SET cdb.dtdevolu = rw_crapdat.dtmvtolt
							,cdb.cdopedev = pr_cdoperad
							,cdb.insitchq = 1
				 WHERE cdb.cdcooper = pr_cdcooper
				   AND cdb.nrdconta = pr_nrdconta
					 AND cdb.nrborder = pr_nrborder
					 AND cdb.cdcmpchq = pr_tab_cheques(vr_index).cdcmpchq
					 AND cdb.cdbanchq = pr_tab_cheques(vr_index).cdbanchq
					 AND cdb.cdagechq = pr_tab_cheques(vr_index).cdagechq
					 AND cdb.nrctachq = pr_tab_cheques(vr_index).nrctachq
					 AND cdb.nrcheque = pr_tab_cheques(vr_index).nrcheque;
				 
				-- Verificar se cust�dia j� foi processada e cheque ainda n�o foi devolvido
				OPEN cr_crapcst(pr_cdcooper => pr_cdcooper
				               ,pr_dsdocmc7 => pr_tab_cheques(vr_index).dsdocmc7);
				FETCH cr_crapcst INTO rw_crapcst;
				
				IF cr_crapcst%FOUND THEN
					-- Resgatar cheque de cust�dia
					cust0001.pc_efetua_resgate_custodia(pr_cdcooper => pr_cdcooper
																						 ,pr_nrdconta => pr_nrdconta
																						 ,pr_dscheque => pr_tab_cheques(vr_index).dsdocmc7
																						 ,pr_cdoperad => pr_cdoperad
																						 ,pr_tab_erro_resg => vr_tab_resgate_erro
																						 ,pr_cdcritic => vr_cdcritic
																						 ,pr_dscritic => vr_dscritic);
					-- Se retornou alguma cr�tica
					IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
						-- Fechar cursor
				    CLOSE cr_crapcst;
						-- Levantar exce��o
						RAISE vr_exc_erro;
					END IF;
        END IF;	
				-- Fechar cursor
				CLOSE cr_crapcst;
			ELSE
				-- Gerar cr�tica
				vr_cdcritic := 79;
				-- Levantar exce��o
				RAISE vr_exc_erro;
			END IF;
		END LOOP;
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
      -- Efetuar rollback
      ROLLBACK;      
    WHEN OTHERS THEN      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := REPLACE(REPLACE('Nao foi possivel efetivar o border� de desconto de cheque: ' || SQLERRM, chr(13)),chr(10));																			
			-- Efetuar Rollback
			ROLLBACK;				 																			 		
	END pc_resgata_cheques_bordero;
END DSCC0001;
/
