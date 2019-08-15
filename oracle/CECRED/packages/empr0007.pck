CREATE OR REPLACE PACKAGE CECRED.EMPR0007 IS

  ---------------------------------------------------------------------------
  --
  --  Programa : EMPR0007
  --  Sistema  : Rotinas referentes a Portabilidade de Credito
  --  Sigla    : EMPR
  --  Autor    : Lucas Reinert
  --  Data     : Julho - 2015.                   Ultima atualizacao: 07/08/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Portabilidade de Credito
  --
  -- Alteracoes: 27/09/2016 - Inclusao de verificacao de contratos de acordos
  --                          na procedure pc_enviar_boleto, Prj. 302 (Jean Michel).
  --                           
  --             30/03/2017 - Adicionado novo parametro pr_idarquiv na procedure 
  --                          pc_verifica_gerar_boleto para permitir geracao de
  --                          boleto para contratos em prejuizo quando for 
  --                          boletagem massiva. (P210.2 - Lombardi)
  --
  --             27/09/2017 - Ajuste para atender SM 3 do projeto 210.2 (Daniel)
  --            
  --             16/01/2019 - Adicionado novo campo (vlminpos) no record type typ_reg_cobemp.
  --                          (P298.2.2 - Luciano - Supero)
  --  
  --             23/04/2019 - Alterada rotina para envio do boleto por e-mail para
  --                          recuperar o texto da crapprm.
  --                          (P559 - André Clemer - Supero)
  --
  --             05/06/2019 - Removida instrução "NAO ACEITAR PAGAMENTO APOS O VENCIMENTO"
  --                          (P559 - André Clemer - Supero)
  --
  ---------------------------------------------------------------------------

  ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
  --Tipo de Registro para Parametros da cobemp
	TYPE typ_reg_cobemp IS RECORD
		(nrconven       crapprm.dsvlrprm%TYPE
		,nrdconta       crapprm.dsvlrprm%TYPE
		,pzmaxvct       crapprm.dsvlrprm%TYPE
		,pzbxavct       crapprm.dsvlrprm%TYPE
		,vlrminpp       crapprm.dsvlrprm%TYPE
		,vlrmintr       crapprm.dsvlrprm%TYPE
		,vlminpos       crapprm.dsvlrprm%TYPE    
		,dslinha1       crapprm.dsvlrprm%TYPE
		,dslinha2       crapprm.dsvlrprm%TYPE
		,dslinha3       crapprm.dsvlrprm%TYPE
		,dslinha4       crapprm.dsvlrprm%TYPE
		,dstxtsms       crapprm.dsvlrprm%TYPE
		,dstxtema       crapprm.dsvlrprm%TYPE
		,blqemibo       crapprm.dsvlrprm%TYPE
		,qtmaxbol       crapprm.dsvlrprm%TYPE
		,blqrsgcc       crapprm.dsvlrprm%TYPE
		,descprej       crapprm.dsvlrprm%TYPE);

	TYPE typ_reg_cde IS RECORD
		(cdcooper       tbrecup_cobranca.cdcooper%TYPE
		,cdagenci       crapass.cdagenci%TYPE
		,nrctremp       tbrecup_cobranca.nrctremp%TYPE
		,nrdconta       tbrecup_cobranca.nrdconta%TYPE
		,nrcnvcob       tbrecup_cobranca.nrcnvcob%TYPE
		,nrdocmto       tbrecup_cobranca.nrboleto%TYPE
		,dtmvtolt       crapcob.dtmvtolt%TYPE
		,dtvencto       crapcob.dtvencto%TYPE
		,vlboleto       crapcob.vldpagto%TYPE
		,dtdpagto       crapcob.dtdpagto%TYPE
		,vldpagto       crapcob.vldpagto%TYPE
		,dstipenv       VARCHAR2(20)
		,cdopeenv       tbrecup_cobranca.cdoperad_envio%TYPE
		,dtdenvio       tbrecup_cobranca.dhenvio%TYPE
		,dsdenvio       VARCHAR(60)
		,dssituac       VARCHAR(20)
		,dtdbaixa       crapcob.dtdbaixa%TYPE
		,dsdemail       tbrecup_cobranca.dsemail%TYPE
		,dsdtelef       VARCHAR(20)
		,nmpescto       tbrecup_cobranca.nmcontato%TYPE
		,nrctacob       tbrecup_cobranca.nrdconta_cob%TYPE
        ,lindigit       VARCHAR(60)
        ,dsparcel       tbrecup_cobranca.dsparcelas%TYPE
        ,incobran       crapcob.incobran%TYPE);

  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_cde IS TABLE OF typ_reg_cde INDEX BY BINARY_INTEGER;

	PROCEDURE pc_busca_convenios(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
															,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
															,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
															,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
															,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
															,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
															,pr_des_erro OUT VARCHAR2);           --> Erros do processo

	PROCEDURE pc_busca_cobemp (pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
														,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
														,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
														,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
														,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
														,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
														,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  PROCEDURE pc_grava_cobemp(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                           ,pr_nrconven IN crapprm.dsvlrprm%TYPE --> Convênio de cobrança para empréstimo
                           ,pr_nrdconta IN crapprm.dsvlrprm%TYPE --> Conta/DV Beneficiária do Boleto
                           ,pr_prazomax IN crapprm.dsvlrprm%TYPE --> Prazo máximo de vencimento: xx dias út(il/eis)
                           ,pr_prazobxa IN crapprm.dsvlrprm%TYPE --> Prazo de baixa para o boleto após vencimento: xx dias út(il/eis)
                           ,pr_vlrminpp IN crapprm.dsvlrprm%TYPE --> Valor mínimo do boleto – PP
                           ,pr_vlrmintr IN crapprm.dsvlrprm%TYPE --> Valor mínimo do boleto – TR
                           ,pr_vlminpos IN crapprm.dsvlrprm%TYPE --> Valor mínimo do boleto – POS                                                       
                           ,pr_dslinha1 IN crapprm.dsvlrprm%TYPE --> Instruções: Linha 1
                           ,pr_dslinha2 IN crapprm.dsvlrprm%TYPE --> Instruções: Linha 2
                           ,pr_dslinha3 IN crapprm.dsvlrprm%TYPE --> Instruções: Linha 3
                           ,pr_dslinha4 IN crapprm.dsvlrprm%TYPE --> Instruções: Linha 4
                           ,pr_dstxtsms IN crapprm.dsvlrprm%TYPE --> Texto SMS
                           ,pr_dstxtema IN crapprm.dsvlrprm%TYPE --> Texto EMAIL
                           ,pr_blqemiss IN crapprm.dsvlrprm%TYPE --> Bloqueio de emissão de boletos: XX dias para YY emissões consecutivas não pagas
                           ,pr_qtdmaxbl IN crapprm.dsvlrprm%TYPE --> Quantidade máxima de boletos por contrato: XX
                           ,pr_flgblqvl IN crapprm.dsvlrprm%TYPE --> Bloqueio de resgate de valores disponíveis em conta corrente
                           ,pr_descprej IN crapprm.dsvlrprm%TYPE --> Desconto maximo pagamento contrato prejuizo
                           ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2); --> Erros do processo

	-- Procedure de pagamento de boletos de emprestimos
  PROCEDURE pc_pagar_epr_cobranca(pr_cdcooper IN tbrecup_cobranca.cdcooper%TYPE --> Codigo da Cooperativa
                                 ,pr_nrdconta IN tbrecup_cobranca.nrdconta%TYPE --> Numero da conta
                                 ,pr_nrctremp IN tbrecup_cobranca.nrctremp%TYPE --> Numero do contrato
                                 ,pr_nrcnvcob IN tbrecup_cobranca.nrcnvcob%TYPE --> Numero do Convenio
                                 ,pr_nrdocmto IN craplat.nrdocmto %TYPE       --> Numero do Documento
                                 ,pr_vldpagto IN craplcm.vllanmto %TYPE       --> Valor do Pagamento
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE        --> Data do Movimento
                                 ,pr_cdoperad IN crapope.cdoperad%TYPE        --> Codigo do Operador
                                 ,pr_nmtelant IN VARCHAR2                     --> Verificar COMPEFORA                                 
																 ,pr_idorigem IN INTEGER
                                 ,pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2);                  --> Descrição da crítica

  -- procedure para lancar o valor para contratos TR
  PROCEDURE pc_gera_lancamento_epr_tr(pr_cdcooper IN crapcop.cdcooper%TYPE
                                     ,pr_nrdconta IN tbrecup_cobranca.nrdconta%TYPE
                                     ,pr_nrctremp IN tbrecup_cobranca.nrctremp%TYPE
                                     ,pr_vllanmto IN craplcm.vllanmto%TYPE
																		 ,pr_cdoperad IN crapope.cdoperad%TYPE
																		 ,pr_idorigem IN INTEGER
                                     ,pr_nmtelant IN VARCHAR2                     --> Verificar COMPEFORA
                                     ,pr_vltotpag OUT NUMBER                      --> Retorno do valor pago
                                     ,pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2);                  --> Descrição da crítica

  PROCEDURE pc_buscar_boletos_contratos (pr_cdcooper IN crapcop.cdcooper%TYPE                  --> Cooperativa
																				,pr_cdagenci IN crapass.cdagenci%TYPE DEFAULT 0        --> PA
																				,pr_nrctremp IN tbrecup_cobranca.nrctremp%TYPE DEFAULT 0 --> Nr. do Contrato
																				,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT 0        --> Nr. da Conta
																				,pr_dtbaixai IN DATE DEFAULT NULL                      --> Data de baixa inicial
																				,pr_dtbaixaf IN DATE DEFAULT NULL                      --> Data de baixa final
																				,pr_dtemissi IN DATE DEFAULT NULL                      --> Data de emissão inicial
																				,pr_dtemissf IN DATE DEFAULT NULL                      --> Data de emissão final
																				,pr_dtvencti IN DATE DEFAULT NULL                      --> Data de vencimento inicial
																				,pr_dtvenctf IN DATE DEFAULT NULL                      --> Data de vencimento final
																				,pr_dtpagtoi IN DATE DEFAULT NULL                      --> Data de pagamento inicial
																				,pr_dtpagtof IN DATE DEFAULT NULL                      --> Data de pagamento final
																				,pr_cdoperad IN crapope.cdoperad%TYPE                  --> Cód. Operador
																				,pr_cdcritic OUT crapcri.cdcritic%TYPE                 --> Cód. da crítica
																				,pr_dscritic OUT crapcri.dscritic%TYPE                 --> Descrição da crítica
																				,pr_tab_cde  OUT typ_tab_cde);	                       --> Pl/Table com os dados de cobrança de emprestimos

  PROCEDURE pc_enviar_boleto(pr_cdcooper IN tbrecup_cobranca.cdcooper%TYPE              --> Cooperativa
		                        ,pr_nrdconta IN tbrecup_cobranca.nrdconta%TYPE              --> Nr. da Conta
														,pr_nrctremp IN tbrecup_cobranca.nrctremp%TYPE              --> Nr. Contrato
														,pr_nrctacob IN tbrecup_cobranca.nrdconta_cob%TYPE          --> Nr. Conta Cobrança
														,pr_nrcnvcob IN tbrecup_cobranca.nrcnvcob%TYPE              --> Nr. Convenio Cobrança
														,pr_nrdocmto IN tbrecup_cobranca.nrboleto%TYPE              --> Nr. Documento
														,pr_cdoperad IN tbrecup_cobranca.cdoperad_envio%TYPE        --> Cód. Operador
														,pr_nmcontat IN tbrecup_cobranca.nmcontato%TYPE             --> Nome Contato
														,pr_tpdenvio IN tbrecup_cobranca.tpenvio%TYPE               --> Tipo de Envio (1 = EMAIL, 2 = SMS, 3 = IMPRESSAO)
														,pr_nmdatela IN VARCHAR2                                  --> Nome da tela
														,pr_idorigem IN INTEGER                                   --> ID Origem
														,pr_dsdemail IN tbrecup_cobranca.dsemail%TYPE DEFAULT NULL  --> Email
														,pr_indretor IN tbrecup_cobranca.indretorno%TYPE DEFAULT 0  --> Indicador de retorno
														,pr_nrdddsms IN tbrecup_cobranca.nrddd_sms%TYPE DEFAULT 0   --> DDD
														,pr_nrtelsms IN tbrecup_cobranca.nrtel_sms%TYPE DEFAULT 0   --> Telefone
														,pr_cdcritic OUT crapcri.cdcritic%TYPE                    --> Cód. Crítica
														,pr_dscritic OUT crapcri.dscritic%TYPE);                  --> Desc. Crítica

  PROCEDURE pc_enviar_boleto_web(pr_nrdconta IN tbrecup_cobranca.nrdconta%TYPE              --> Nr. da Conta
																,pr_nrctremp IN tbrecup_cobranca.nrctremp%TYPE              --> Nr. Contrato
																,pr_nrctacob IN tbrecup_cobranca.nrdconta_cob%TYPE          --> Nr. Conta Cobrança
																,pr_nrcnvcob IN tbrecup_cobranca.nrcnvcob%TYPE              --> Nr. Convenio Cobrança
																,pr_nrdocmto IN tbrecup_cobranca.nrboleto%TYPE              --> Nr. Documento
																,pr_nmcontat IN tbrecup_cobranca.nmcontato%TYPE             --> Nome Contato
																,pr_tpdenvio IN tbrecup_cobranca.tpenvio%TYPE               --> Tipo de Envio (1 = EMAIL, 2 = SMS, 3 = IMPRESSAO)
																,pr_dsdemail IN tbrecup_cobranca.dsemail%TYPE DEFAULT NULL  --> Email
																,pr_indretor IN tbrecup_cobranca.indretorno%TYPE DEFAULT 0  --> Indicador de retorno
																,pr_nrdddsms IN tbrecup_cobranca.nrddd_sms%TYPE DEFAULT 0   --> DDD
																,pr_nrtelsms IN tbrecup_cobranca.nrtel_sms%TYPE DEFAULT 0   --> Telefone
																,pr_xmllog   IN VARCHAR2                                  --> XML com informações de LOG
																,pr_cdcritic OUT PLS_INTEGER                              --> Código da crítica
																,pr_dscritic OUT VARCHAR2                                 --> Descrição da crítica
																,pr_retxml   IN OUT NOCOPY XMLType                        --> Arquivo de retorno do XML
																,pr_nmdcampo OUT VARCHAR2                                 --> Nome do campo com erro
																,pr_des_erro OUT VARCHAR2);                               --> Erros do processo

  PROCEDURE pc_gera_boleto_contrato (pr_cdcooper IN  crapcob.cdcooper%TYPE --> Código da cooperativa;
																		,pr_nrdconta IN  crapcob.nrdconta%TYPE --> Conta do cooperado do contrato;
																		,pr_nrctremp IN  crapcob.nrctremp%TYPE --> Número do contrato de empréstimo;
																		,pr_dtmvtolt IN  crapcob.dtmvtolt%TYPE --> Data do movimento;
																		,pr_tpparepr IN  NUMBER                --> Tipo de parcela 1 = Parcela Normal, 2 = Total do atraso 3 = Parcial do atraso 4 = Quitação do contrato;
																		,pr_dsparepr IN  VARCHAR2 DEFAULT NULL /* Descrição das parcelas do empréstimo “par1;par2;par...; parN”;
																																							Obs: empréstimo TR => NULL;
																																							Obs2: Quando for ref a várias parcelas do contrato, parcela = NULL;
																																							Obs3: Quando for quitação do contrato, parcela = 999; */
																		,pr_dtvencto IN  crapcob.dtvencto%TYPE --> Vencimento do boleto;
																		,pr_vlparepr IN  crappep.vlparepr%TYPE --> Valor da parcela;
																		,pr_cdoperad IN  crapcob.cdoperad%TYPE --> Código do operador;
																		,pr_nmdatela IN VARCHAR2               --> Nome da tela
														        ,pr_idorigem IN INTEGER                --> ID Origem
                                    ,pr_nrcpfava IN NUMBER DEFAULT 0       --> CPF do avalista
																		,pr_idarquiv IN INTEGER DEFAULT 0      --> Id do arquivo (boletagem Massiva)
                                    ,pr_idboleto IN INTEGER DEFAULT 0      --> Id do boleto no arquivo (boletagem Massiva)
																		,pr_peracres IN NUMBER DEFAULT 0       --> Percentual de Desconto
                                                                        ,pr_perdesco IN NUMBER DEFAULT 0       --> Percentual de Acrescimo
                                                                        ,pr_vldescto IN NUMBER DEFAULT 0       --> Valor do Desconto
                                    ,pr_vldevedor IN NUMBER DEFAULT 0
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código da crítica
																		,pr_dscritic OUT crapcri.dscritic%TYPE --> Descrição da crítica
																		);

	PROCEDURE pc_gera_boleto_contrato_web(pr_nrdconta IN  crapcob.nrdconta%TYPE  --> Nr. da Conta
																			 ,pr_nrctremp IN  crapcob.nrctremp%TYPE  --> Número do contrato de empréstimo;
																			 ,pr_dtmvtolt IN  VARCHAR2               --> Data do movimento;
																			 ,pr_tpparepr IN  NUMBER                 --> Tipo de parcela 1 = Parcela Normal, 2 = Total do atraso 3 = Parcial do atraso 4 = Quitação do contrato;
																			 ,pr_dsparepr IN  VARCHAR2 DEFAULT NULL  /* Descrição das parcelas do empréstimo “par1;par2;par...; parN”;
																																									Obs: empréstimo TR => NULL;
																																									Obs2: Quando for ref a várias parcelas do contrato, parcela = NULL;
																																									Obs3: Quando for quitação do contrato, parcela = 0; */
																			 ,pr_dtvencto IN  VARCHAR2              --> Vencimento do boleto;
																			 ,pr_vlparepr IN  VARCHAR2 --> Valor da parcela;
                                       ,pr_nrcpfava IN  NUMBER                --> CPF do avalista
																			 ,pr_xmllog   IN  VARCHAR2              --> XML com informações de LOG
																			 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																			 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																			 ,pr_retxml   IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
																			 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																			 ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

	PROCEDURE pc_verifica_gerar_boleto (pr_cdcooper IN crapcop.cdcooper%TYPE                   --> Cód. cooperativa
		                                 ,pr_nrctacob IN crapass.nrdconta%TYPE                   --> Nr. da Conta Cob.
		                                 ,pr_nrdconta IN crapass.nrdconta%TYPE                   --> Nr. da Conta
																		 ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE                   --> Nr. do Convênio de Cobrança
																	 	 ,pr_nrctremp IN crapcob.nrctremp%TYPE                   --> Nr. do Contrato
																		 ,pr_idarquiv IN tbrecup_boleto_arq.idarquivo%TYPE DEFAULT 0 --> Nr. do Arquivo (<> 0 = boletagem massiva)
                                     ,pr_cdcritic OUT PLS_INTEGER                            --> Código da crítica
																		 ,pr_dscritic OUT VARCHAR2                               --> Descrição da crítica
																		 ,pr_des_erro OUT VARCHAR2);                             --> Erros do processo

  PROCEDURE pc_inst_baixa_boleto_epr(pr_cdcooper IN crapepr.cdcooper%TYPE         --> Cód. cooperativa
																		,pr_nrdconta IN crapepr.nrdconta%TYPE         --> Nr. da conta
																		,pr_nrctremp IN crapepr.nrctremp%TYPE         --> Nr. contrato de empréstiomo
																		,pr_nrctacob IN crapepr.nrdconta%TYPE         --> Nr. da conta cobrança
																		,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE         --> Nr. convenio
																		,pr_nrdocmto IN crapcob.nrdocmto%TYPE         --> Nr. documento
																		,pr_dtmvtolt IN crapepr.dtmvtolt%TYPE         --> Data de movimento
																		,pr_idorigem IN INTEGER                       --> Id origem
																		,pr_cdoperad IN crapcob.cdoperad%TYPE         --> Cód. operador
																		,pr_nmdatela IN VARCHAR2                      --> Nome da tela
																		,pr_cdcritic OUT crapcri.cdcritic%TYPE        --> Cód. da crítica
																		,pr_dscritic OUT crapcri.dscritic%TYPE);      --> Descrição da crítica
																		
 	PROCEDURE pc_inst_baixa_boleto_epr_web(pr_nrdconta IN crapepr.nrdconta%TYPE  --> Nr. da conta
																				,pr_nrctremp IN crapepr.nrctremp%TYPE  --> Nr. contrato de empréstiomo
																				,pr_nrctacob IN crapepr.nrdconta%TYPE  --> Nr. da conta cobrança
																				,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE  --> Nr. convenio
																				,pr_nrdocmto IN crapcob.nrdocmto%TYPE  --> Nr. documento
																		    ,pr_dtmvtolt IN VARCHAR2               --> Data de movimento
																		    ,pr_dsjustif IN VARCHAR2               --> Justificativa de Baixa
																			  ,pr_xmllog   IN  VARCHAR2              --> XML com informações de LOG
																			  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																			  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																			  ,pr_retxml   IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
																			  ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																			  ,pr_des_erro OUT VARCHAR2);            --> Erros do processo																		
																				
  PROCEDURE pc_obtem_dados_tr(pr_cdcooper IN crapepr.cdcooper%TYPE
		                         ,pr_nrdconta IN crapepr.nrdconta%TYPE
														 ,pr_nrctremp IN crapepr.nrctremp%TYPE
 														 ,pr_dtmvtolt IN crapepr.dtmvtolt%TYPE
														 ,pr_nmdatela IN VARCHAR2
														 ,pr_idorigem IN INTEGER
														 ,pr_cdoperad IN VARCHAR2
														 ,pr_vlsdeved OUT crapepr.vlsdeved%TYPE
														 ,pr_vlatraso OUT crapepr.vlsdeved%TYPE
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica
														 
  PROCEDURE pc_obtem_dados_tr_web(pr_nrdconta IN crapepr.nrdconta%TYPE
																 ,pr_nrctremp IN crapepr.nrctremp%TYPE
																 ,pr_dtmvtolt IN VARCHAR2
																 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																 ,pr_retxml   IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
																 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																 ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  PROCEDURE pc_gera_arq_remessa_sms(pr_cdcooper IN crapcop.cdcooper%TYPE
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                   ,pr_dsretorn OUT VARCHAR2
                                   ,pr_cdcritic OUT PLS_INTEGER
                                   ,pr_dscritic OUT VARCHAR2);                                 
                                   
  PROCEDURE pc_processa_retorno_sms(pr_cdcooper IN crapcop.cdcooper%TYPE
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                   ,pr_dsretorn OUT VARCHAR2
                                   ,pr_cdcritic OUT PLS_INTEGER
                                   ,pr_dscritic OUT VARCHAR2);                                   
																	 
  PROCEDURE pc_gerar_pdf_boletos(pr_cdcooper IN crapass.cdcooper%TYPE --> Cód. cooperativa
		                            ,pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
																,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE --> Nr. do convênio
																,pr_nrdocmto IN crapcob.nrdocmto%TYPE --> Nr docmto
																,pr_cdoperad IN crapope.cdoperad%TYPE --> Cód operador
																,pr_idorigem IN NUMBER                --> Id origem
																,pr_tpdenvio IN tbrecup_cobranca.tpenvio%TYPE DEFAULT 0  --> Tipo de envio
																,pr_dsdemail IN tbrecup_cobranca.dsemail%TYPE DEFAULT '' --> Email
																,pr_nmarqpdf OUT VARCHAR2             --> Nome do arquivo em PDF
																,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
																,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
																,pr_des_erro OUT VARCHAR2);           --> Erros do processo																	 

  PROCEDURE pc_gera_data_pag_tr(pr_cdcooper IN tbrecup_cobranca.cdcooper%TYPE --> Codigo da Cooperativa
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE        --> Data do Movimento
                               ,pr_nrdconta IN tbrecup_cobranca.nrdconta%TYPE --> Numero da conta
                               ,pr_nrctremp IN tbrecup_cobranca.nrctremp%TYPE --> Numero do contrato
                               ,pr_vlpreemp IN crapepr.vlpreemp %TYPE       --> Valor da prestacao
                               ,pr_dtdpagto IN OUT crapepr.dtdpagto%TYPE    --> Data do pagamento
                               ,pr_dtvencto IN crawepr.dtvencto%TYPE        --> Data vencimento
                               ,pr_cdcritic OUT PLS_INTEGER                 --> Codigo da critica
                               ,pr_dscritic OUT VARCHAR2);                --> Descricao da critica

END EMPR0007;
/
CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0007 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : EMPR0007
  --  Sistema  : Rotinas referentes a Portabilidade de Credito
  --  Sigla    : EMPR
  --  Autor    : Lucas Reinert
  --  Data     : Julho - 2015.                   Ultima atualizacao: 29/04/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Portabilidade de Credito
  --
  -- Alteracoes: 29/06/2016 - Adicionar validacao de substr para a leitura da crapass com a 
  --                          crapenc na procedure pc_gera_boleto_contrato (Lucas Ranghetti #456095)
  --
  --             27/09/2016 - Inclusao de verificacao de contratos de acordos
  --                          na procedure pc_enviar_boleto, Prj. 302 (Jean Michel).
  --
  --             28/11/2016 - Adicionado liberação para canais para gerar boleto de quitação de
  --                          emprestimo. (Kelvin SD 535306)
  --
  --             29/11/2016 - P341 - Automatização BACENJUD - Alterado para validar o departamento à partir
  --                          do código e não mais pela descrição (Renato Darosci - Supero)
  --
  --             25/01/2017 - Criacao da pc_gera_data_pag_tr. (Jaison/James)
  --
  --             05/07/2018 - PJ450 Regulatório de Credito - Substituido o Insert na tabela craplcm
  --                          pela chamada da rotina lanc0001.pc_gerar_lancamento_conta. (Josiane Stiehler - AMcom)
  --
  --             07/08/2018  - 9318:Pagamento de Emprestimo  Transferencia para conta
  --                           transitoria quando a origem da tela for BLQPREJU
  --                          -pc_gera_lancamento_epr_tr Rangel Decker (AMcom)
  --
  --             27/12/2018 - Inclusão de tratamento na "pc_pagar_epr_cobranca" para contas corrente em 
  --                          prejuízo (debitar da conta transitória e não da conta corrente).
  --                          P450 - Reginaldo/AMcom
  --
  --             29/04/2019 - Ajuste na procedure "pg_pagar_epr_cobranca" para correção no tratamento de contas em prejuízo
  --                          para debitar corretamente o valor pago da Conta Transitória (Bloqueados Prejuízo).
  --                          450 - Reginaldo/AMcom
  ---------------------------------------------------------------------------

  PROCEDURE pc_busca_convenios(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
	BEGIN
	  /* .............................................................................

      Programa: pc_busca_convenios
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Lucas Reinert
      Data    : Julho/15.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina referente a busca dos convenios de emprestimo

      Observacao: -----

      Alteracoes:
    ..............................................................................*/
		DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variáveis locais
      vr_auxconta PLS_INTEGER := 0;

		  -- Busca os convernios de emprestimo da cooperativa
		  CURSOR cr_crapcco IS
			  SELECT cco.nrconven
				  FROM crapcco cco
				 WHERE cco.cdcooper = pr_cdcooper
				 	 AND cco.dsorgarq = 'EMPRESTIMO'
					 AND cco.cddbanco = 085
					 AND cco.flgregis = 1;

		BEGIN

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      FOR rw_crapcco IN cr_crapcco LOOP
			  -- Insere as tags
				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrconven', pr_tag_cont => TO_CHAR(rw_crapcco.nrconven), pr_des_erro => vr_dscritic);

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

			WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na EMPR0007.pc_busca_convenios: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
		END;
  END pc_busca_convenios;

	PROCEDURE pc_busca_cobemp (pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
														,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
														,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
														,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
														,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
														,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
														,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
	BEGIN
	  /* .............................................................................

      Programa: pc_busca_cobemp
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Lucas Reinert
      Data    : Agosto/15.                    Ultima atualizacao: 07/03/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina referente a busca dos parametros de cobrança de
			            empréstimos

      Observacao: -----

      Alteracoes: 07/03/2017 - Busca do campo descprej. (P210.2 - Jaison/Daniel)
      
                  16/01/2019 - Busca o campo Valor mínimo do boleto – POS (vlminpos). 
                               (P298.2.2 - Luciano - Supero)      
    ..............................................................................*/
		DECLARE
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variáveis locais
      vr_cdcooper crapcop.cdcooper%TYPE := pr_cdcooper;

			-- Pltable com os dados de cobrança de empréstimos
			vr_reg_cobemp typ_reg_cobemp;

		  -- Busca os convernios de emprestimo da cooperativa
		  CURSOR cr_crapprm (pr_cdcooper IN crapcop.cdcooper%TYPE
			                  ,pr_cdacesso IN crapprm.cdacesso%TYPE)IS
			  SELECT prm.dsvlrprm
				  FROM crapprm prm
				 WHERE prm.cdcooper = pr_cdcooper
				 	 AND prm.nmsistem = 'CRED'
					 AND prm.cdacesso = pr_cdacesso;

		BEGIN

    	IF vr_cdcooper <> 0 THEN
				-- Convênio de cobrança para empréstimo
				OPEN cr_crapprm(vr_cdcooper
											 ,'COBEMP_NRCONVEN');
				FETCH cr_crapprm INTO vr_reg_cobemp.nrconven;
				CLOSE cr_crapprm;

				-- Conta/DV Beneficiária do Boleto
				OPEN cr_crapprm(vr_cdcooper
											 ,'COBEMP_NRDCONTA_BNF');
				FETCH cr_crapprm INTO vr_reg_cobemp.nrdconta;
				CLOSE cr_crapprm;
			ELSE
				vr_reg_cobemp.nrconven := '0';
				vr_reg_cobemp.nrdconta := '0';
				vr_cdcooper := 1;
			END IF;

		  -- Prazo máximo de vencimento: xx dias út(il/eis)
		  OPEN cr_crapprm(vr_cdcooper
			               ,'COBEMP_PRZ_MAX_VENCTO');
			FETCH cr_crapprm INTO vr_reg_cobemp.pzmaxvct;
			CLOSE cr_crapprm;

		  -- Prazo de baixa para o boleto após vencimento: xx dias út(il/eis)
		  OPEN cr_crapprm(vr_cdcooper
			               ,'COBEMP_PRZ_BX_VENCTO');
			FETCH cr_crapprm INTO vr_reg_cobemp.pzbxavct;
			CLOSE cr_crapprm;

		  -- Valor mínimo do boleto – PP
		  OPEN cr_crapprm(vr_cdcooper
			               ,'COBEMP_VLR_MIN_PP');
			FETCH cr_crapprm INTO vr_reg_cobemp.vlrminpp;
			CLOSE cr_crapprm;

		  -- Valor mínimo do boleto – TR
		  OPEN cr_crapprm(vr_cdcooper
			               ,'COBEMP_VLR_MIN_TR');
			FETCH cr_crapprm INTO vr_reg_cobemp.vlrmintr;
			CLOSE cr_crapprm;

		  -- Valor mínimo do boleto – POS
		  OPEN cr_crapprm(vr_cdcooper
			               ,'COBEMP_VLR_MIN_POS');
			FETCH cr_crapprm INTO vr_reg_cobemp.vlminpos;
			CLOSE cr_crapprm;

		  -- Desconto Máximo Contrato Prejuízo
		  OPEN cr_crapprm(vr_cdcooper
			               ,'COBEMP_DSC_MAX_PREJU');
			FETCH cr_crapprm INTO vr_reg_cobemp.descprej;
			CLOSE cr_crapprm;

		  -- Instruções: (mensagem dentro do boleto)
			-- Linha 1
		  OPEN cr_crapprm(vr_cdcooper
			               ,'COBEMP_INSTR_LINHA_1');
			FETCH cr_crapprm INTO vr_reg_cobemp.dslinha1;
			CLOSE cr_crapprm;

			-- Linha 2
		  OPEN cr_crapprm(vr_cdcooper
			               ,'COBEMP_INSTR_LINHA_2');
			FETCH cr_crapprm INTO vr_reg_cobemp.dslinha2;
			CLOSE cr_crapprm;

      -- Linha 3
		  OPEN cr_crapprm(vr_cdcooper
			               ,'COBEMP_INSTR_LINHA_3');
			FETCH cr_crapprm INTO vr_reg_cobemp.dslinha3;
			CLOSE cr_crapprm;

      -- Linha 4
		  OPEN cr_crapprm(vr_cdcooper
			               ,'COBEMP_INSTR_LINHA_4');
			FETCH cr_crapprm INTO vr_reg_cobemp.dslinha4;
			CLOSE cr_crapprm;

			-- Texto SMS
		  OPEN cr_crapprm(vr_cdcooper
			               ,'COBEMP_TXT_SMS');
			FETCH cr_crapprm INTO vr_reg_cobemp.dstxtsms;
			CLOSE cr_crapprm;

			-- Texto EMAIL
		  OPEN cr_crapprm(vr_cdcooper
			               ,'COBEMP_TXT_EMAIL');
			FETCH cr_crapprm INTO vr_reg_cobemp.dstxtema;
			CLOSE cr_crapprm;

			-- Bloqueio de emissão de boletos: XX dias para YY emissões consecutivas não pagas
		  OPEN cr_crapprm(vr_cdcooper
			               ,'COBEMP_BLQ_EMI_CONSEC');
			FETCH cr_crapprm INTO vr_reg_cobemp.blqemibo;
			CLOSE cr_crapprm;

			-- Quantidade máxima de boletos por contrato: XX
		  OPEN cr_crapprm(vr_cdcooper
			               ,'COBEMP_QTD_MAX_BOL_EPR');
			FETCH cr_crapprm INTO vr_reg_cobemp.qtmaxbol;
			CLOSE cr_crapprm;

			-- Bloqueio de resgate de valores disponíveis em conta corrente
		  OPEN cr_crapprm(vr_cdcooper
			               ,'COBEMP_BLQ_RESG_CC');
			FETCH cr_crapprm INTO vr_reg_cobemp.blqrsgcc;
			CLOSE cr_crapprm;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

			-- Insere as tags
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'nrconven', pr_tag_cont => vr_reg_cobemp.nrconven, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'nrdconta', pr_tag_cont => vr_reg_cobemp.nrdconta, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'pzmaxvct', pr_tag_cont => vr_reg_cobemp.pzmaxvct, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'pzbxavct', pr_tag_cont => vr_reg_cobemp.pzbxavct, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'vlrminpp', pr_tag_cont => vr_reg_cobemp.vlrminpp, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'vlrmintr', pr_tag_cont => vr_reg_cobemp.vlrmintr, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'vlminpos', pr_tag_cont => vr_reg_cobemp.vlminpos, pr_des_erro => vr_dscritic);      
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'descprej', pr_tag_cont => vr_reg_cobemp.descprej, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'dslinha1', pr_tag_cont => vr_reg_cobemp.dslinha1, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'dslinha2', pr_tag_cont => vr_reg_cobemp.dslinha2, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'dslinha3', pr_tag_cont => vr_reg_cobemp.dslinha3, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'dslinha4', pr_tag_cont => vr_reg_cobemp.dslinha4, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'dstxtsms', pr_tag_cont => vr_reg_cobemp.dstxtsms, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'dstxtema', pr_tag_cont => vr_reg_cobemp.dstxtema, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'blqemibo', pr_tag_cont => vr_reg_cobemp.blqemibo, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtmaxbol', pr_tag_cont => vr_reg_cobemp.qtmaxbol, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'blqrsgcc', pr_tag_cont => vr_reg_cobemp.blqrsgcc, pr_des_erro => vr_dscritic);

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

			WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na EMPR0007.pc_busca_cobemp: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
		END;
	END pc_busca_cobemp;

	PROCEDURE pc_grava_cobemp (pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
		                        ,pr_nrconven IN crapprm.dsvlrprm%TYPE --> Convênio de cobrança para empréstimo
														,pr_nrdconta IN crapprm.dsvlrprm%TYPE --> Conta/DV Beneficiária do Boleto
														,pr_prazomax IN crapprm.dsvlrprm%TYPE --> Prazo máximo de vencimento: xx dias út(il/eis)
														,pr_prazobxa IN crapprm.dsvlrprm%TYPE --> Prazo de baixa para o boleto após vencimento: xx dias út(il/eis)
														,pr_vlrminpp IN crapprm.dsvlrprm%TYPE --> Valor mínimo do boleto – PP
														,pr_vlrmintr IN crapprm.dsvlrprm%TYPE --> Valor mínimo do boleto – TR
														,pr_vlminpos IN crapprm.dsvlrprm%TYPE --> Valor mínimo do boleto – POS                            
														,pr_dslinha1 IN crapprm.dsvlrprm%TYPE --> Instruções: Linha 1
														,pr_dslinha2 IN crapprm.dsvlrprm%TYPE --> Instruções: Linha 2
														,pr_dslinha3 IN crapprm.dsvlrprm%TYPE --> Instruções: Linha 3
														,pr_dslinha4 IN crapprm.dsvlrprm%TYPE --> Instruções: Linha 4
														,pr_dstxtsms IN crapprm.dsvlrprm%TYPE --> Texto SMS
														,pr_dstxtema IN crapprm.dsvlrprm%TYPE --> Texto EMAIL
														,pr_blqemiss IN crapprm.dsvlrprm%TYPE --> Bloqueio de emissão de boletos: XX dias para YY emissões consecutivas não pagas
														,pr_qtdmaxbl IN crapprm.dsvlrprm%TYPE --> Quantidade máxima de boletos por contrato: XX
														,pr_flgblqvl IN crapprm.dsvlrprm%TYPE --> Bloqueio de resgate de valores disponíveis em conta corrente
														,pr_descprej IN crapprm.dsvlrprm%TYPE --> Desconto maximo pagamento contrato prejuizo
														,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
														,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
														,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
														,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
														,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
														,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
	  BEGIN
 	  /* .............................................................................

      Programa: pc_grava_cobemp
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Lucas Reinert
      Data    : Agosto/15.                    Ultima atualizacao: 06/03/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina referente a gravação dos parametros de cobrança de
			            empréstimos

      Observacao: -----

      Alteracoes: 06/03/2017 - Buscar somente as cooperativas ativas e gravacao
                               do COBEMP_DSC_MAX_PREJU e LOG. (P210.2 - Jaison/Daniel)
                               
                  16/01/2019 - Tratamento para o campo Valor mínimo do boleto – POS 
                               (P298.2.2 - Luciano - Supero)                              
    ..............................................................................*/
		DECLARE

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -------------------------------- CURSORES --------------------------------------

		-- Cursor para a tabela de emissão de bloquetos
		CURSOR cr_crapceb IS
			SELECT 1
				FROM crapceb ceb
			 WHERE ceb.cdcooper = pr_cdcooper
				 AND ceb.nrdconta = pr_nrdconta
				 AND ceb.nrconven = pr_nrconven;
		rw_crapceb cr_crapceb%ROWTYPE;


    ----------------------------- SUBROTINAS INTERNAS ---------------------------
    -- Procedure para gravar os itens do LOG
    PROCEDURE pc_item_log(pr_cdcooper IN INTEGER --> Codigo da cooperativa
                         ,pr_cdoperad IN VARCHAR2 --> Codigo do operador
                         ,pr_dsdcampo IN VARCHAR2 --> Descricao do campo
                         ,pr_vldantes IN VARCHAR2 --> Valor antes
                         ,pr_vldepois IN VARCHAR2) IS  --> Valor depois
    BEGIN
      BEGIN
        -- Se for alteracao e nao tem diferenca, retorna
        IF pr_vldantes = pr_vldepois THEN
          RETURN;
        END IF;

        -- Geral LOG
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratado
                                  ,pr_nmarqlog     => 'tab096.log'
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') ||
                                                      ' --> Coop: ' || pr_cdcooper ||
                                                      ' - Operador ' || pr_cdoperad ||
                                                      ' alterou o parametro ' || pr_dsdcampo ||
                                                      ' de ' || pr_vldantes ||
                                                      ' para ' || pr_vldepois || '.');
      END;
    END pc_item_log;

	  -- Procedure para criar/atualizar parametros de cobrança de emprestimo
	  PROCEDURE atualiza_parametro(pr_cdacesso IN crapprm.cdacesso%TYPE
			                          ,pr_dsvlrprm IN crapprm.dsvlrprm%TYPE
                                ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
			BEGIN
			DECLARE

				-- Define cursor de parametros
				CURSOR cr_crapprm IS
					SELECT prm.dsvlrprm
					 FROM crapprm prm
					WHERE prm.cdcooper = pr_cdcooper
						AND prm.nmsistem = 'CRED'
						AND prm.cdacesso = pr_cdacesso;
				rw_crapprm cr_crapprm%ROWTYPE;

				-- Define cursor de parametros
				CURSOR cr_crapprm_todos IS
          SELECT cop.cdcooper,
					       prm.dsvlrprm
           FROM crapcop cop,
            		crapprm prm
          WHERE cop.cdcooper    = prm.cdcooper(+)
					  AND prm.nmsistem(+) = 'CRED'
            AND prm.cdacesso(+) = pr_cdacesso
            AND cop.flgativo = 1
            AND cop.cdcooper <> 3;

			BEGIN
				-- Se cooperativa for 0 então são todas
			  IF pr_cdcooper = 0 THEN
					 -- Percorre a tabela de parametros de todas as cooperativas
	         FOR rw_crapprm_todos IN cr_crapprm_todos LOOP

					     -- Se possuir valor no campo de parametro atualiza
               IF pr_dsvlrprm IS NOT NULL THEN
								 UPDATE crapprm
										SET dsvlrprm = pr_dsvlrprm
									WHERE cdcooper = rw_crapprm_todos.cdcooper
										AND nmsistem = 'CRED'
										AND cdacesso = pr_cdacesso;
               ELSE
                  vr_cdcritic := 0;
                  vr_dscritic := 'Parametro ' || pr_cdacesso || ' nao pode ser nulo.';   
                  RAISE vr_exc_saida;               
							 END IF;

               -- Grava o LOG
               pc_item_log(pr_cdcooper => rw_crapprm_todos.cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dsdcampo => pr_cdacesso
                          ,pr_vldantes => rw_crapprm_todos.dsvlrprm
                          ,pr_vldepois => pr_dsvlrprm);

					 END LOOP;

				ELSE -- Cooperativa especifica

					-- Abre cursor de parametros
					OPEN cr_crapprm;
					FETCH cr_crapprm INTO rw_crapprm;

					-- Se não encontrou cria
					IF cr_crapprm%NOTFOUND THEN
						INSERT INTO crapprm(cdcooper
															 ,nmsistem
															 ,cdacesso
															 ,dsvlrprm)
												 VALUES(pr_cdcooper
															 ,'CRED'
															 ,pr_cdacesso
															 ,pr_dsvlrprm);
					ELSE -- Se encontrou atualiza
						UPDATE crapprm
							 SET dsvlrprm = pr_dsvlrprm
						 WHERE cdcooper = pr_cdcooper
							 AND nmsistem = 'CRED'
							 AND cdacesso = pr_cdacesso;
					END IF;
					-- Fecha cursor
					CLOSE cr_crapprm;

          -- Grava o LOG
          pc_item_log(pr_cdcooper => pr_cdcooper
                     ,pr_cdoperad => pr_cdoperad
                     ,pr_dsdcampo => pr_cdacesso
                     ,pr_vldantes => rw_crapprm.dsvlrprm
                     ,pr_vldepois => pr_dsvlrprm);

				END IF;
			END;
		END atualiza_parametro;

		BEGIN
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

		IF (pr_cdcooper <> 0) THEN
			-- Convênio de cobrança para empréstimo
			IF trim(pr_nrconven) IS NOT NULL THEN
				 atualiza_parametro(pr_cdacesso => 'COBEMP_NRCONVEN'
													 ,pr_dsvlrprm => pr_nrconven
													 ,pr_cdoperad => vr_cdoperad);
			END IF;

			-- Conta/DV Beneficiária do Boleto
			IF trim(pr_nrdconta) IS NOT NULL THEN
				 atualiza_parametro(pr_cdacesso => 'COBEMP_NRDCONTA_BNF'
													 ,pr_dsvlrprm => pr_nrdconta
													 ,pr_cdoperad => vr_cdoperad);
			END IF;
    END IF;
	  -- Prazo máximo de vencimento: xx dias út(il/eis)
 		IF trim(pr_prazomax) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => 'COBEMP_PRZ_MAX_VENCTO'
			                   ,pr_dsvlrprm => pr_prazomax
												 ,pr_cdoperad => vr_cdoperad);
		END IF;

	  -- Prazo máximo de vencimento: xx dias út(il/eis)
 		IF trim(pr_prazobxa) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => 'COBEMP_PRZ_BX_VENCTO'
			                   ,pr_dsvlrprm => pr_prazobxa
												 ,pr_cdoperad => vr_cdoperad);
		END IF;

		-- Valor mínimo do boleto – PP
 		IF trim(pr_vlrminpp) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => 'COBEMP_VLR_MIN_PP'
			                   ,pr_dsvlrprm => pr_vlrminpp
												 ,pr_cdoperad => vr_cdoperad);
		END IF;

		-- Valor mínimo do boleto – TR
 		IF trim(pr_vlrmintr) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => 'COBEMP_VLR_MIN_TR'
			                   ,pr_dsvlrprm => pr_vlrmintr
												 ,pr_cdoperad => vr_cdoperad);
		END IF;

		-- Valor mínimo do boleto – POS
 		IF trim(pr_vlminpos) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => 'COBEMP_VLR_MIN_POS'
			                   ,pr_dsvlrprm => pr_vlminpos
												 ,pr_cdoperad => vr_cdoperad);
		END IF;    

		-- Instruções: Linha 1
 		IF trim(pr_dslinha1) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => 'COBEMP_INSTR_LINHA_1'
			                   ,pr_dsvlrprm => pr_dslinha1
												 ,pr_cdoperad => vr_cdoperad);
		END IF;

		-- Instruções: Linha 2
 		IF trim(pr_dslinha2) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => 'COBEMP_INSTR_LINHA_2'
			                   ,pr_dsvlrprm => pr_dslinha2
												 ,pr_cdoperad => vr_cdoperad);
		END IF;

		-- Instruções: Linha 3
 		IF trim(pr_dslinha3) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => 'COBEMP_INSTR_LINHA_3'
			                   ,pr_dsvlrprm => pr_dslinha3
												 ,pr_cdoperad => vr_cdoperad);
		END IF;

		-- Instruções: Linha 4
 		IF trim(pr_dslinha4) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => 'COBEMP_INSTR_LINHA_4'
			                   ,pr_dsvlrprm => pr_dslinha4
												 ,pr_cdoperad => vr_cdoperad);
		END IF;

		-- Texto SMS
 		IF trim(pr_dstxtsms) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => 'COBEMP_TXT_SMS'
			                   ,pr_dsvlrprm => pr_dstxtsms
												 ,pr_cdoperad => vr_cdoperad);
		END IF;

		-- Texto EMAIL
 		IF trim(pr_dstxtema) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => 'COBEMP_TXT_EMAIL'
			                   ,pr_dsvlrprm => pr_dstxtema
												 ,pr_cdoperad => vr_cdoperad);
		END IF;

		-- Bloqueio de emissão de boletos: XX dias para YY emissões consecutivas não pagas
 		IF trim(pr_blqemiss) <> ';'       AND
			 trim(pr_blqemiss) IS NOT NULL  THEN
       atualiza_parametro(pr_cdacesso => 'COBEMP_BLQ_EMI_CONSEC'
			                   ,pr_dsvlrprm => pr_blqemiss
												 ,pr_cdoperad => vr_cdoperad);
		END IF;

		-- Quantidade máxima de boletos por contrato: XX
 		IF trim(pr_qtdmaxbl) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => 'COBEMP_QTD_MAX_BOL_EPR'
			                   ,pr_dsvlrprm => pr_qtdmaxbl
												 ,pr_cdoperad => vr_cdoperad);
		END IF;

	  -- Quantidade máxima de boletos por contrato: XX
 		IF trim(pr_flgblqvl) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => 'COBEMP_BLQ_RESG_CC'
			                   ,pr_dsvlrprm => pr_flgblqvl
												 ,pr_cdoperad => vr_cdoperad);
		END IF;

		-- Desconto maximo pagamento contrato prejuizo
 		IF trim(pr_descprej) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => 'COBEMP_DSC_MAX_PREJU'
			                   ,pr_dsvlrprm => pr_descprej
												 ,pr_cdoperad => vr_cdoperad);
		END IF;

		IF (pr_cdcooper <> 0) THEN
			-- Verifica se convênio de cobrança existe
			OPEN cr_crapceb;
			FETCH cr_crapceb INTO rw_crapceb;

			IF cr_crapceb%NOTFOUND THEN
				 -- Se não existir, cria
				 INSERT INTO crapceb
										(cdcooper,
										 nrdconta,
										 nrconven,
										 flcooexp,
										 flceeexp,
										 insitceb,
										 dtcadast,
										 inarqcbr,
										 nrcnvceb,
										 flgcruni,
										 flgcebhm)
						 values (pr_cdcooper,
										 pr_nrdconta,
										 pr_nrconven,
										 1,
										 0,
										 1,
										 trunc(SYSDATE),
										 0,
										 0,
										 1,
										 0);
			END IF;
		  -- Fecha cursor
			CLOSE cr_crapceb;
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
			pr_dscritic := 'Erro nao tratado na EMPR0007.pc_grava_cobemp: ' || SQLERRM;

			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;
		END;

  END pc_grava_cobemp;


  -- procedure de pagamento de boletos de emprestimos
  PROCEDURE pc_pagar_epr_cobranca(pr_cdcooper IN tbrecup_cobranca.cdcooper%TYPE --> Codigo da Cooperativa
                                 ,pr_nrdconta IN tbrecup_cobranca.nrdconta%TYPE --> Numero da conta
                                 ,pr_nrctremp IN tbrecup_cobranca.nrctremp%TYPE --> Numero do contrato
                                 ,pr_nrcnvcob IN tbrecup_cobranca.nrcnvcob %TYPE --> Numero do Convenio
                                 ,pr_nrdocmto IN craplat.nrdocmto %TYPE --> Numero do Documento
                                 ,pr_vldpagto IN craplcm.vllanmto %TYPE --> Valor do Pagamento
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE        --> Data do Movimento
                                 ,pr_cdoperad IN crapope.cdoperad%TYPE        --> Codigo do Operador
                                 ,pr_nmtelant IN VARCHAR2                     --> Verificar COMPEFORA
																 ,pr_idorigem IN INTEGER
                                 ,pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2) IS                --> Descrição da crítica
  BEGIN
    /* .............................................................................
      Programa: pc_pagar_epr_cobranca
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Carlos Rafael Tanholi
      Data    : Agosto/15.                    Ultima atualizacao: 29/04/2019

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina referente ao pagamento de boletos de empréstimos

      Observacao: -----

      Alteracoes: 06/06/2016 - Passagem do pr_nmtelant para pc_gera_lancamento_epr_tr.
                               (Jaison/James)

                  11/07/2016 - Ajustado para utilizar as variaveis de critica no programa, 
                               e apenas na exceção adicionar os erros nos parametros de 
                               critica (Douglas - Chamado 463063)
                  
                  24/04/2017 - Ajustado para efetuar abono para contratos de boletagem massiva 
                               e liquidação de prejuízo quando necessário. Projeto 210_2 (Lombardi)
															 
                  27/12/2018 - Inclusão de tratamento para contas corrente em prejuízo (debitar da
                               conta transitória e não da conta corrente).
                               P450 - Reginaldo/AMcom

                  29/04/2019 - Correção no tratamento de contas em prejuízo para debitar corretamente o valor
                               pago da Conta Transitória (Bloqueados Prejuízo).
                               P450 - Reginaldo/AMcom

                  06/02/2019 - Ajustar para efetuar pagamento de emprestimo POS  
                               P298.2.2 - Pos Fixado (Luciano - Supero)

    ..............................................................................*/

    DECLARE

    ------------------------------- VARIAVEIS -------------------------------
		-- Variáveis para o tratamento de erros
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_tab_erro gene0001.typ_tab_erro;
		vr_des_reto VARCHAR2(3);
		
    -- Variáveis TR
    vr_vlsdeved crapepr.vlsdeved%TYPE;
    vr_vlatraso crapepr.vlsdeved%TYPE;
		vr_vlajuste NUMBER(25,2);
    vr_vlabono  NUMBER(25,2);
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
		
		-- Variaveis locais
    vr_dsparcel gene0002.typ_split;
	vr_vldpagto crapepr.vlsdeved%TYPE;    
    vr_vldpagto_aux crapepr.vlsdeved%TYPE;
    vr_vltotpag craplcm.vllanmto%TYPE;
    vr_flgdel   BOOLEAN;
    vr_flgativo PLS_INTEGER;
    vr_vlsdprej NUMBER(25,2);
    
    vr_vlparcel craplcm.vllanmto%TYPE; 
    vr_cdprogra VARCHAR2(10) := 'COBEMP';
    
	vr_prejuzcc BOOLEAN; -- Indicador de conta corrente em prejuízo
    
    -------------------------- TABELAS TEMPORARIAS --------------------------

    vr_tab_pgto_parcel     empr0001.typ_tab_pgto_parcel;
	vr_tab_calculado       empr0001.typ_tab_calculado;
    vr_tab_price           EMPR0011.typ_tab_price;
    vr_tab_parcelas        EMPR0011.typ_tab_parcelas;    
    vr_tab_calculado_pos   EMPR0011.typ_tab_calculado;
    
    vr_index_pos           PLS_INTEGER;

    ------------------------------- CURSORES --------------------------------
		
		-- Cursor para localizar contrato de emprestimo
		CURSOR cr_crapepr IS
			SELECT epr.tpemprst
            ,epr.inliquid
            ,epr.inprejuz
            ,epr.vlprejuz
            ,epr.vlsdprej
            ,epr.vlsprjat
            ,epr.vlpreemp
            ,epr.vlttmupr
            ,epr.vlpgmupr
            ,epr.vlttjmpr
            ,epr.vlpgjmpr
            ,epr.vliofcpl
            ,epr.dtmvtolt
            ,epr.cdlcremp
            ,epr.vlemprst
            ,epr.txmensal
            ,epr.dtdpagto
            ,epr.vlsprojt
            ,epr.qttolatr
            ,wepr.txmensal txmensal_w
            ,wepr.dtdpagto dtdpagto_w
			  FROM crapepr epr
        JOIN crawepr wepr 
          ON wepr.cdcooper = epr.cdcooper
         AND wepr.nrdconta = epr.nrdconta
         AND wepr.nrctremp = epr.nrctremp        
			 WHERE epr.cdcooper = pr_cdcooper
				 AND epr.nrdconta = pr_nrdconta
				 AND epr.nrctremp = pr_nrctremp;
		rw_crapepr cr_crapepr%ROWTYPE;

    -- cursor para filtrar os associados que utilizam o servico de malote
    CURSOR cr_tbrecup_cobranca( pr_cdcooper IN crapcop.cdcooper%TYPE
                             ,pr_nrdconta IN crapass.nrdconta%TYPE
                             ,pr_nrcnvcob IN tbrecup_cobranca.nrcnvcob%TYPE
                             ,pr_nrdocmto IN crapcob.nrdocmto%TYPE
                             ,pr_nrctremp IN crapcob.nrctremp%TYPE ) IS
			SELECT cde.cdcooper
						,cde.nrdconta
						,cde.nrctremp
						,cde.nrcnvcob
						,cde.nrboleto
						,cde.tpparcela
						,cde.dsparcelas dsparcel
						,cob.dsdoccop
						,cob.dtvencto
						,cob.dtdpagto
						,cob.dtdbaixa
						,cob.incobran
						,cob.vltitulo
						,ass.cdagenci
            ,cde.idboleto
				FROM crapcob cob
						,tbrecup_cobranca cde
						,crapass ass
			 WHERE cde.cdcooper = pr_cdcooper
				 AND cde.nrdconta = pr_nrdconta
				 AND cde.nrcnvcob = pr_nrcnvcob
				 AND cde.nrboleto = pr_nrdocmto
         AND cob.cdcooper = cde.cdcooper
         AND cob.nrdconta = cde.nrdconta_cob
         AND cob.nrcnvcob = cde.nrcnvcob
         AND cob.nrdocmto = cde.nrboleto
				 AND ass.cdcooper = cde.cdcooper
				 AND ass.nrdconta = cde.nrdconta
			 ORDER BY cde.nrdconta, cde.nrctremp;
		rw_cde cr_tbrecup_cobranca%ROWTYPE;

    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

    BEGIN
      
      -- Buscar o CRAPDAT da cooperativa
      OPEN  BTCH0001.cr_crapdat(pr_cdcooper); 
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
          
      -- Se não encontrar registro na CRAPDAT
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      END IF;
      CLOSE BTCH0001.cr_crapdat;
      
      OPEN cr_crapepr;
			FETCH cr_crapepr INTO rw_crapepr;
			
			IF cr_crapepr%NOTFOUND THEN			   
				--Fecha cursor
				CLOSE cr_crapepr;
				--Atribui críticas
				vr_cdcritic := 0;
				vr_dscritic := 'Contrato nao encontrado';
				-- Gera exceção
				RAISE vr_exc_saida;
			END IF;
			--Fecha cursor
			CLOSE cr_crapepr;

      OPEN cr_tbrecup_cobranca(pr_cdcooper => pr_cdcooper  --Codigo Cooperativa
														,pr_nrdconta => pr_nrdconta  --Numero da Conta
														,pr_nrcnvcob => pr_nrcnvcob  --Numero Convenio
														,pr_nrctremp => pr_nrctremp  --Numero do contrato de emprestimo
														,pr_nrdocmto => pr_nrdocmto); --Numero do Boleto
      FETCH cr_tbrecup_cobranca INTO rw_cde;			
			
			IF cr_tbrecup_cobranca%NOTFOUND THEN			  
				-- Fecha cursor
				CLOSE cr_tbrecup_cobranca; 
				--Atribui críticas
				vr_cdcritic := 0;
				vr_dscritic := 'Boleto nao encontrado';
				-- Gera exceção
				RAISE vr_exc_saida;
			END IF;
			-- Fecha cursor
			CLOSE cr_tbrecup_cobranca; 
			
			/* se o valor pago for menor, gerar crítica */
     IF pr_vldpagto < rw_cde.vltitulo THEN
        -- Atribui críticas
        vr_cdcritic := 0;
        vr_dscritic := 'Valor pago a menor';
				-- Gera exceção				
        RAISE vr_exc_saida; 
      END IF;

      /* se o boleto estiver baixado, gerar crítica */
      IF rw_cde.incobran = 3 AND rw_cde.dtdbaixa IS NOT NULL THEN
        -- Atribui críticas				
        vr_cdcritic := 0;
        vr_dscritic := 'Boleto baixado';
				-- Gera exceção								
        RAISE vr_exc_saida;
      END IF;

      /* se o boleto estiver vencido, gerar crítica */
      IF rw_cde.dtvencto < rw_cde.dtdpagto THEN
        -- Atribui críticas								
        vr_cdcritic := 0;
        vr_dscritic := 'Boleto vencido';
				-- Gera exceção												
        RAISE vr_exc_saida;
      END IF;

      /* Condicao para verificar se o acordo estah ativo, caso o acordo estiver ativo
         nao podemos efetuar o pagamento de emprestimo  */
      RECP0001.pc_verifica_acordo_ativo(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrctremp => pr_nrctremp
                                       ,pr_cdorigem => 3
                                       ,pr_flgativo => vr_flgativo
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

      IF NVL(vr_flgativo,0) = 1 THEN
        RETURN;
      END IF;
      
			-- Verifica se a conta corrente está em prejuízo (Reginaldo/AMcom)
			vr_prejuzcc := PREJ0003.fn_verifica_preju_conta(pr_cdcooper => pr_cdcooper
			                                              , pr_nrdconta => pr_nrdconta);

      -- Contrato em Prejuizo
      IF rw_crapepr.inprejuz = 1 THEN

        -- Buscar saldo devedor prejuizo
        vr_vlsdprej := rw_crapepr.vlsdprej;
        
        -- Validar se possui valor a ser pago
        -- 5-Saldo Prejuízo/ 6-Parcial Prejuízo/ 7-Saldo Prejuízo Desconto
		-- 4 Quitação do Contrato
        IF rw_cde.tpparcela IN (4,5,7) THEN -- Saldo Prejuizo
        
      	   
          -- Rotina para pagamento de prejuizo
          EMPR9999.pc_pagar_emprestimo_prejuizo(pr_cdcooper => pr_cdcooper
                                               ,pr_nrdconta => pr_nrdconta
                                               ,pr_cdagenci => rw_cde.cdagenci
                                               ,pr_crapdat  => rw_crapdat
                                               ,pr_nrparcel => 0
                                               ,pr_nrctremp => pr_nrctremp
                                               ,pr_tpemprst => rw_crapepr.tpemprst
                                               ,pr_vlprejuz => rw_crapepr.vlprejuz
                                               ,pr_vlsdprej => rw_crapepr.vlsdprej
                                               ,pr_vlsprjat => rw_crapepr.vlsprjat
                                               ,pr_vlpreemp => rw_crapepr.vlpreemp
                                               ,pr_vlttmupr => rw_crapepr.vlttmupr
                                               ,pr_vlpgmupr => rw_crapepr.vlpgmupr
                                               ,pr_vlttjmpr => rw_crapepr.vlttjmpr
                                               ,pr_vlpgjmpr => rw_crapepr.vlpgjmpr
                                               ,pr_cdoperad => pr_cdoperad
                                               ,pr_vlparcel => pr_vldpagto
                                               ,pr_nmtelant => pr_nmtelant
                                               ,pr_vliofcpl => rw_crapepr.vliofcpl
                                               ,pr_vltotpag => vr_vldpagto -- Retorna o valor pr_vltotpag com o valor pago.
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);
      		  -- Se retornar erro da rotina
            IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
              -- Gera exceção
              RAISE vr_exc_saida;
            END IF;

            vr_vldpagto_aux := vr_vldpagto;

            OPEN cr_crapepr;
            FETCH cr_crapepr INTO rw_crapepr;
      			
            IF cr_crapepr%NOTFOUND THEN			   
              --Fecha cursor
              CLOSE cr_crapepr;
              --Atribui críticas
              vr_cdcritic := 0;
              vr_dscritic := 'Contrato nao encontrado';
              -- Gera exceção
              RAISE vr_exc_saida;
            END IF;
          
            --Fecha cursor
            CLOSE cr_crapepr;

            IF rw_crapepr.vlsdprej > 0 THEN
                  
              -- Rotina para gerar abono se necessario
              EMPR9999.pc_pagar_emprestimo_prejuizo(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_cdagenci => rw_cde.cdagenci
                                 ,pr_crapdat  => rw_crapdat
                                 ,pr_nrparcel => 0
                                 ,pr_nrctremp => pr_nrctremp
                                 ,pr_tpemprst => rw_crapepr.tpemprst
                                 ,pr_vlprejuz => rw_crapepr.vlprejuz
                                 ,pr_vlsdprej => rw_crapepr.vlsdprej
                                 ,pr_vlsprjat => rw_crapepr.vlsprjat
                                 ,pr_vlpreemp => rw_crapepr.vlpreemp
                                 ,pr_vlttmupr => rw_crapepr.vlttmupr
                                 ,pr_vlpgmupr => rw_crapepr.vlpgmupr
                                 ,pr_vlttjmpr => rw_crapepr.vlttjmpr
                                 ,pr_vlpgjmpr => rw_crapepr.vlpgjmpr
                                 ,pr_cdoperad => pr_cdoperad
                                 ,pr_vlparcel => pr_vldpagto
                                               ,pr_inliqaco => 'S'
                                               ,pr_nmtelant => pr_nmtelant
                                 ,pr_vliofcpl => rw_crapepr.vliofcpl
                                               ,pr_vltotpag => vr_vldpagto -- Retorna o valor pr_vltotpag com o valor pago.
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);
                               
      		  -- Se retornar erro da rotina
            IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
              -- Gera exceção
              RAISE vr_exc_saida;
            END IF;
            
            vr_vldpagto := vr_vldpagto + vr_vldpagto_aux;

            END IF; 
            
            /*
            -- Se valor pago for maior que o valor do boleto
            IF vr_vldpagto > pr_vldpagto THEN
        		 
              -- Deve gerar abono em CC da diferença do valor pago e o valor do boleto
              vr_vlabono := nvl(vr_vldpagto,0) - pr_vldpagto;
              
              -- gerar abono para liquidação
              IF vr_vlabono > 0 THEN
                -- Gerar abono
                EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper     --> Cooperativa conectada
                                              ,pr_dtmvtolt => pr_dtmvtolt     --> Movimento atual
                                              ,pr_cdagenci => rw_cde.cdagenci --> Código da agência
                                              ,pr_cdbccxlt => 100             --> Número do caixa
                                              ,pr_cdoperad => pr_cdoperad     --> Código do Operador
                                              ,pr_cdpactra => rw_cde.cdagenci --> P.A. da transação
                                              ,pr_nrdolote => 600032          --> Numero do Lote
                                              ,pr_nrdconta => pr_nrdconta     --> Número da conta
                                              ,pr_cdhistor => 2288            --> Codigo historico 2288 - ABONO CONTRATO PREJUIZO
                                              ,pr_vllanmto => vr_vlabono      --> Valor da parcela emprestimo
                                              ,pr_nrparepr => 0               --> Número parcelas empréstimo
                                              ,pr_nrctremp => pr_nrctremp     --> Número do contrato de empréstimo
                                              ,pr_des_reto => vr_des_reto     --> Retorno OK / NOK
                                              ,pr_tab_erro => vr_tab_erro);   --> Tabela com possíves erros
                --Se Retornou erro
                IF vr_des_reto <> 'OK' THEN
                  -- Se possui algum erro na tabela de erros
                  IF vr_tab_erro.count() > 0 THEN
                    -- Atribui críticas às variaveis
                    vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                    vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                  ELSE
                    vr_cdcritic := 0;
                    vr_dscritic := 'Erro ao criar o lancamento de ajuste';
                  END IF;
                  -- Gera exceção
                  RAISE vr_exc_saida;
                END IF;
                -- Valor do lancamento recebe o saldo devedor
                vr_vldpagto := nvl(vr_vlsdeved,0);
              END IF;
              
            END IF;
            */
            
          --END IF;
          
        ELSE
          -- Pagamento Parcial
  
          -- Rotina para pagamento de prejuizo
          EMPR9999.pc_pagar_emprestimo_prejuizo(pr_cdcooper => pr_cdcooper
                                               ,pr_nrdconta => pr_nrdconta
                                               ,pr_cdagenci => rw_cde.cdagenci
                                               ,pr_crapdat => rw_crapdat
                                               ,pr_nrparcel => 0
                                               ,pr_nrctremp => pr_nrctremp
                                               ,pr_tpemprst => rw_crapepr.tpemprst
                                               ,pr_vlprejuz => rw_crapepr.vlprejuz
                                               ,pr_vlsdprej => rw_crapepr.vlsdprej
                                               ,pr_vlsprjat => rw_crapepr.vlsprjat
                                               ,pr_vlpreemp => rw_crapepr.vlpreemp
                                               ,pr_vlttmupr => rw_crapepr.vlttmupr
                                               ,pr_vlpgmupr => rw_crapepr.vlpgmupr
                                               ,pr_vlttjmpr => rw_crapepr.vlttjmpr
                                               ,pr_vlpgjmpr => rw_crapepr.vlpgjmpr
                                               ,pr_cdoperad => pr_cdoperad
                                               ,pr_vlparcel => pr_vldpagto
                                               ,pr_nmtelant => pr_nmtelant
                                               ,pr_vltotpag => vr_vldpagto
                                               ,pr_vliofcpl => rw_crapepr.vliofcpl
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);
          -- Se retornar erro da rotina
          IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
            -- Gera exceção
            RAISE vr_exc_saida;
          END IF;
              
        END IF;
      
        /* se tipo de emprestimo for TR */
      ELSIF rw_crapepr.tpemprst = 0 THEN
          
           pc_obtem_dados_tr(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrctremp => pr_nrctremp
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_nmdatela => 'COBEMP'
                            ,pr_idorigem => pr_idorigem
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_vlsdeved => vr_vlsdeved
                            ,pr_vlatraso => vr_vlatraso
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
                            
           IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
              -- Gera exceção
              RAISE vr_exc_saida;
           END IF;                          

           IF nvl(vr_vlsdeved,0) = 0 THEN
              -- Atribui críticas
             vr_cdcritic := 0;
             vr_dscritic := 'Contrato liquidado';
              -- Gera exceção
              RAISE vr_exc_saida;                        
           END IF;         

           -- se o boleto for para liquidar o contrato, 
           -- entao verificar o saldo devedor com o valor pago 
           IF rw_cde.tpparcela = 4 THEN            
                         
              -- se o valor pago for maior que o saldo devedor,
              -- entao pagar o saldo devedor
              IF pr_vldpagto > nvl(vr_vlsdeved,0) THEN
                 vr_vldpagto := vr_vlsdeved;                   
              ELSE
                IF rw_cde.idboleto > 0 THEN -- Boletagem Massiva
  		            
                  -- Deve gerar abono em CC da diferença do saldo e valor pago
                  vr_vlabono := nvl(vr_vlsdeved,0) - pr_vldpagto;
                  
                  IF vr_vlabono > 0 THEN
                        -- Gerar abono
		            IF NOT vr_prejuzcc THEN
                    EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper     --> Cooperativa conectada
                                                  ,pr_dtmvtolt => pr_dtmvtolt     --> Movimento atual
                                                  ,pr_cdagenci => rw_cde.cdagenci --> Código da agência
                                                  ,pr_cdbccxlt => 100             --> Número do caixa
                                                  ,pr_cdoperad => pr_cdoperad     --> Código do Operador
                                                  ,pr_cdpactra => rw_cde.cdagenci --> P.A. da transação
                                                  ,pr_nrdolote => 600032          --> Numero do Lote
                                                  ,pr_nrdconta => pr_nrdconta     --> Número da conta
                                                  ,pr_cdhistor => 2279            --> Codigo historico 2279 - ABONO EMP/FIN (ABONO EMPRESTIMO/FINANCIAMENTO)
                                                  ,pr_vllanmto => vr_vlabono      --> Valor da parcela emprestimo
                                                  ,pr_nrparepr => 0               --> Número parcelas empréstimo
                                                  ,pr_nrctremp => pr_nrctremp     --> Número do contrato de empréstimo
                                                  ,pr_des_reto => vr_des_reto     --> Retorno OK / NOK
                                                  ,pr_tab_erro => vr_tab_erro);   --> Tabela com possíves erros
                    --Se Retornou erro
                    IF vr_des_reto <> 'OK' THEN
                      -- Se possui algum erro na tabela de erros
                      IF vr_tab_erro.count() > 0 THEN
                        -- Atribui críticas às variaveis
                        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                      ELSE
                        vr_cdcritic := 0;
                        vr_dscritic := 'Erro ao criar o lancamento de ajuste';
                      END IF;
                      -- Gera exceção
                      RAISE vr_exc_saida;
                    END IF;
										ELSE -- Se a conta está em prejuízo
										  -- Lança o crédito de abono na conta transitória (Bloqueado Prejuízo) - Reginaldo/AMcom
										  PREJ0003.pc_gera_cred_cta_prj(pr_cdcooper => pr_cdcooper
											                            , pr_nrdconta => pr_nrdconta
																									, pr_vlrlanc  => vr_vlabono
																									, pr_dtmvtolt => pr_dtmvtolt
																									, pr_cdcritic => vr_cdcritic
																									, pr_dscritic => vr_dscritic);
																									
											IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
											  vr_cdcritic := 0;
											  vr_dscritic := 'Erro ao criar o lancamento de ajuste em Bloqueado Prejuízo (' || vr_dscritic || ')';
													
											  RAISE vr_exc_saida;
											END IF;
											
											-- Lança histórico 2279 no extrato do prejuízo de C/C apenas em caráter informativo - Reginaldo/AMcom
											PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
											                                , pr_nrdconta => pr_nrdconta
											                                , pr_dtmvtolt => pr_dtmvtolt
											                                , pr_cdhistor => 2279
											                                , pr_vllanmto => vr_vlabono
											                                , pr_nrctremp => pr_nrctremp
											                                , pr_cdcritic => vr_cdcritic
											                                , pr_dscritic => vr_dscritic); 
																											
											IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
											  vr_cdcritic := 0;
											  vr_dscritic := 'Erro ao criar o lancamento de ajuste no extrato do prejuizo de C/C.';
													
											  RAISE vr_exc_saida;
											END IF; 
										END IF;
											
                    -- Valor do lancamento recebe o saldo devedor
                    vr_vldpagto := nvl(vr_vlsdeved,0);
                  END IF;
                ELSE
                  -- se for COMPEFORA 
                  IF pr_nmtelant = 'COMPEFORA' THEN
                    vr_vlajuste := vr_vlsdeved - pr_vldpagto;
                    vr_vldpagto := vr_vlsdeved;

                    /* Valor do ajuste */
                    IF nvl(vr_vlajuste, 0) > 0 THEN
										  IF NOT vr_prejuzcc THEN
                      /* Lanca em C/C e atualiza o lote */
                      EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper     --> Cooperativa conectada
                                                    ,pr_dtmvtolt => pr_dtmvtolt     --> Movimento atual
                                                    ,pr_cdagenci => rw_cde.cdagenci --> Código da agência
                                                    ,pr_cdbccxlt => 100             --> Número do caixa
                                                    ,pr_cdoperad => pr_cdoperad     --> Código do Operador
                                                    ,pr_cdpactra => rw_cde.cdagenci --> P.A. da transação
                                                    ,pr_nrdolote => 600032          --> Numero do Lote
                                                    ,pr_nrdconta => pr_nrdconta     --> Número da conta
                                                    ,pr_cdhistor => 2012            --> Codigo historico 2012 - AJUSTE BOLETO
                                                    ,pr_vllanmto => vr_vlajuste     --> Valor da parcela emprestimo
                                                    ,pr_nrparepr => 0               --> Número parcelas empréstimo
                                                    ,pr_nrctremp => pr_nrctremp     --> Número do contrato de empréstimo
                                                    ,pr_des_reto => vr_des_reto     --> Retorno OK / NOK
                                                    ,pr_tab_erro => vr_tab_erro);   --> Tabela com possíves erros
                      --Se Retornou erro
                      IF vr_des_reto <> 'OK' THEN
                        -- Se possui algum erro na tabela de erros
                        IF vr_tab_erro.count() > 0 THEN
                          -- Atribui críticas às variaveis
                          vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                          vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                        ELSE
                          vr_cdcritic := 0;
                          vr_dscritic := 'Erro ao criar o lancamento de ajuste';
                        END IF;
                        -- Gera exceção
                        RAISE vr_exc_saida;
												END IF;
											ELSE
											  -- Lança o crédito de abono na conta transitória (Bloqueado Prejuízo) - Reginaldo/AMcom
												PREJ0003.pc_gera_cred_cta_prj(pr_cdcooper => pr_cdcooper
																										, pr_nrdconta => pr_nrdconta
																										, pr_vlrlanc  => vr_vlajuste
																										, pr_dtmvtolt => pr_dtmvtolt
																										, pr_cdcritic => vr_cdcritic
																										, pr_dscritic => vr_dscritic);
																										
												IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
													vr_cdcritic := 0;
													vr_dscritic := 'Erro ao criar o lancamento de ajuste em Bloqueado Prejuízo (' || vr_dscritic || ')';
														
													RAISE vr_exc_saida;
												END IF;
												
												-- Lança histórico 2279 no extrato do prejuízo de C/C apenas em caráter informativo - Reginaldo/AMcom
												PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
											                                                   , pr_nrdconta => pr_nrdconta
											                                                   , pr_dtmvtolt => pr_dtmvtolt
											                                                   , pr_cdhistor => 2012
											                                                   , pr_vllanmto => vr_vlajuste
											                                                   , pr_nrctremp => pr_nrctremp
											                                                   , pr_cdcritic => vr_cdcritic
											                                                   , pr_dscritic => vr_dscritic); 
																												
												IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
													vr_cdcritic := 0;
													vr_dscritic := 'Erro ao criar o lancamento de ajuste no extrato do prejuizo de C/C.';
														
													RAISE vr_exc_saida;
												END IF; 
                      END IF;
                    END IF;  
                  ELSE
                    vr_vldpagto := pr_vldpagto;
                  END IF;
                END IF;
              END IF;            
           ELSE
              vr_vldpagto := pr_vldpagto;                                     
           END IF;

           pc_gera_lancamento_epr_tr(pr_cdcooper => pr_cdcooper
                                   , pr_nrdconta => pr_nrdconta
                                   , pr_nrctremp => pr_nrctremp
                                   , pr_vllanmto => vr_vldpagto
                                   , pr_cdoperad => pr_cdoperad
                                   , pr_idorigem => pr_idorigem
                                   , pr_nmtelant => pr_nmtelant
                                   , pr_vltotpag => vr_vldpagto --> Retorno do valor total pago
                                   , pr_cdcritic => vr_cdcritic
                                   , pr_dscritic => vr_dscritic);                                 

           IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            -- Gera exceção
            RAISE vr_exc_saida;
           END IF;
          
      /* se tipo de emprestimo for PP */
      ELSIF rw_crapepr.tpemprst = 1 THEN          
                 
          -- se o boleto nao for para liquidar o contrato, entao separar as parcelas 
          IF rw_cde.tpparcela <> 4 THEN 
            -- Separa as parcelas
            vr_dsparcel := gene0002.fn_quebra_string(pr_string => rw_cde.dsparcel);				
            
            -- verificar se existe parcela selecionada na geracao do boleto
            IF vr_dsparcel.count() = 0 OR TRIM(rw_cde.dsparcel) IS NULL THEN
               vr_cdcritic := 0;
               vr_dscritic := 'Erro ao gerar boleto. Parcela(s) nao selecionada(s).';
               RAISE vr_exc_saida;
            END IF;
            
          END IF;
  				
          -- Atribui valor parametrizado para variavel
          vr_vldpagto := pr_vldpagto;

          -- buscar todas as parcelas do contrato
          EMPR0001.pc_busca_pgto_parcelas(pr_cdcooper => pr_cdcooper
                                         ,pr_cdagenci => rw_cde.cdagenci
                                         ,pr_nrdcaixa => 1
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nmdatela => 'COBEMP'
                                         ,pr_idorigem => pr_idorigem
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_idseqttl => 1
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_flgerlog => 'N'
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_dtmvtoan => gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                                                    ,pr_dtmvtolt => pr_dtmvtolt - 1
                                                                                    ,pr_tipo => 'A')
                                         ,pr_nrparepr => 0 -- GENE0002.fn_char_para_number(vr_dsparcel(idx))
                                         ,pr_des_reto => vr_des_reto
                                         ,pr_tab_erro => vr_tab_erro
                                         ,pr_tab_pgto_parcel => vr_tab_pgto_parcel
                                         ,pr_tab_calculado => vr_tab_calculado);
  																				 
          IF vr_des_reto <> 'OK' THEN
            -- Se possui algum erro na tabela de erros
            IF vr_tab_erro.count() > 0 THEN
              -- Atribui críticas às variaveis
              vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
            ELSE
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao consultar pagamento de parcelas';
            END IF;
            -- Gera exceção
            RAISE vr_exc_saida;
          END IF;
          
          -- se o boleto nao for para liquidar o contrato, entao verificar as parcelas que serao pagas 
          IF rw_cde.tpparcela <> 4 THEN
            -- filtrar as parcelas que serao pagas          
            FOR idx2 IN vr_tab_pgto_parcel.first..vr_tab_pgto_parcel.last LOOP        
                      
                vr_flgdel := TRUE;
                  
                FOR idx IN vr_dsparcel.first..vr_dsparcel.last LOOP          
                    
                    IF GENE0002.fn_char_para_number(vr_dsparcel(idx)) = vr_tab_pgto_parcel(idx2).nrparepr THEN
                       vr_flgdel := FALSE;
                       EXIT;
                    END IF;                
                  
                END LOOP;
                  
                IF vr_flgdel OR vr_vldpagto = 0 THEN
                   vr_tab_pgto_parcel.delete(idx2);
                ELSE
                   IF vr_vldpagto >= ROUND(vr_tab_pgto_parcel(idx2).vlatrpag,2) THEN                   
                      vr_tab_pgto_parcel(idx2).vlpagpar := ROUND(vr_tab_pgto_parcel(idx2).vlatrpag,2);
                      vr_vldpagto := ROUND(vr_vldpagto,2) - ROUND(vr_tab_pgto_parcel(idx2).vlatrpag,2);                    
                   ELSE                   
                      /* Quando ocorrer a COMPEFORA (pr_nmtelant = 'COMPEFORA') sistema deverá verificar o valor da diferença */
                      IF pr_nmtelant = 'COMPEFORA' AND rw_cde.tpparcela = 2 AND
                         ROUND(vr_tab_pgto_parcel(idx2).vlatrpag,2) > vr_vldpagto THEN
                         
                         /* vlr do atraso da última parcela utilizada – vlr que sobrou pra liquidar a última parcela utilizada */
                         vr_vlajuste := ROUND(vr_tab_pgto_parcel(idx2).vlatrpag,2) - vr_vldpagto;
                         vr_tab_pgto_parcel(idx2).vlpagpar := ROUND(vr_tab_pgto_parcel(idx2).vlatrpag,2);
                         
                         /* Valor do ajuste */
                         IF nvl(vr_vlajuste, 0) > 0 THEN
												    IF NOT vr_prejuzcc THEN
                            /* Lanca em C/C e atualiza o lote */
                            EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper     --> Cooperativa conectada
                                                          ,pr_dtmvtolt => pr_dtmvtolt     --> Movimento atual
                                                          ,pr_cdagenci => rw_cde.cdagenci --> Código da agência
                                                          ,pr_cdbccxlt => 100             --> Número do caixa
                                                          ,pr_cdoperad => pr_cdoperad     --> Código do Operador
                                                          ,pr_cdpactra => rw_cde.cdagenci --> P.A. da transação
                                                          ,pr_nrdolote => 600032          --> Numero do Lote
                                                          ,pr_nrdconta => pr_nrdconta     --> Número da conta
                                                          ,pr_cdhistor => 2012            --> Codigo historico 2012 - AJUSTE BOLETO
                                                          ,pr_vllanmto => vr_vlajuste     --> Valor da parcela emprestimo
                                                          ,pr_nrparepr => vr_tab_pgto_parcel(idx2).nrparepr --> Número parcelas empréstimo
                                                          ,pr_nrctremp => pr_nrctremp     --> Número do contrato de empréstimo
                                                          ,pr_des_reto => vr_des_reto     --> Retorno OK / NOK
                                                          ,pr_tab_erro => vr_tab_erro);   --> Tabela com possíves erros
                            --Se Retornou erro
                            IF vr_des_reto <> 'OK' THEN
                              -- Se possui algum erro na tabela de erros
                              IF vr_tab_erro.count() > 0 THEN
                                -- Atribui críticas às variaveis
                                vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                                vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                              ELSE
                                vr_cdcritic := 0;
                                vr_dscritic := 'Erro ao criar o lancamento de ajuste';
                              END IF;
                              -- Gera exceção
                              RAISE vr_exc_saida;
                            END IF;
														ELSE
														  -- Lança o crédito de abono na conta transitória (Bloqueado Prejuízo) - Reginaldo/AMcom
															PREJ0003.pc_gera_cred_cta_prj(pr_cdcooper => pr_cdcooper
																													, pr_nrdconta => pr_nrdconta
																													, pr_vlrlanc  => vr_vlajuste
																													, pr_dtmvtolt => pr_dtmvtolt
																													, pr_cdcritic => vr_cdcritic
																													, pr_dscritic => vr_dscritic);
																													
															IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
																vr_cdcritic := 0;
																vr_dscritic := 'Erro ao criar o lancamento de ajuste em Bloqueado Prejuízo (' || vr_dscritic || ')';
																	
																RAISE vr_exc_saida;
                         END IF;
															
															-- Lança histórico 2012 no extrato do prejuízo de C/C apenas em caráter informativo - Reginaldo/AMcom
															PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
																															, pr_nrdconta => pr_nrdconta
																															, pr_dtmvtolt => pr_dtmvtolt
																															, pr_cdhistor => 2012
																															, pr_vllanmto => vr_vlajuste
																															, pr_nrctremp => pr_nrctremp
																															, pr_cdcritic => vr_cdcritic
																															, pr_dscritic => vr_dscritic); 
																															
															IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
																vr_cdcritic := 0;
																vr_dscritic := 'Erro ao criar o lancamento de ajuste no extrato do prejuizo de C/C.';
																	
																RAISE vr_exc_saida;
															END IF;
														END IF;	
                         END IF;
                      ELSE 
                         vr_tab_pgto_parcel(idx2).vlpagpar := ROUND(vr_vldpagto,2);
                      END IF;
                      
                      vr_vldpagto := 0;
                   END IF;
                END IF;
                  
            END LOOP;
            
            -- variavel volta a ser atribuida com o parametro
            vr_vldpagto := pr_vldpagto;
            
          ELSE 
             -- se o boleto for para liquidar o contrato, comparar o valor da parcela com o saldo devedor 
             IF pr_vldpagto < vr_tab_calculado(vr_tab_calculado.FIRST).vlsdeved  THEN
               
               IF rw_cde.idboleto > 0 THEN -- Boletagem Massiva
                 -- Deve gerar abono em CC da diferença do saldo e valor pago
                 vr_vlabono := nvl(vr_tab_calculado(vr_tab_calculado.FIRST).vlsdeved,0) - pr_vldpagto;
                 
                 IF vr_vlabono > 0 THEN
                   -- Gerar abono
									 IF NOT vr_prejuzcc THEN
                   EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper     --> Cooperativa conectada
                                                 ,pr_dtmvtolt => pr_dtmvtolt     --> Movimento atual
                                                 ,pr_cdagenci => rw_cde.cdagenci --> Código da agência
                                                 ,pr_cdbccxlt => 100             --> Número do caixa
                                                 ,pr_cdoperad => pr_cdoperad     --> Código do Operador
                                                 ,pr_cdpactra => rw_cde.cdagenci --> P.A. da transação
                                                 ,pr_nrdolote => 600032          --> Numero do Lote
                                                 ,pr_nrdconta => pr_nrdconta     --> Número da conta
                                                 ,pr_cdhistor => 2279            --> Codigo historico 2279 - ABONO EMP/FIN (ABONO EMPRESTIMO/FINANCIAMENTO)
                                                 ,pr_vllanmto => vr_vlabono      --> Valor da parcela emprestimo
                                                 ,pr_nrparepr => 0               --> Número parcelas empréstimo
                                                 ,pr_nrctremp => pr_nrctremp     --> Número do contrato de empréstimo
                                                 ,pr_des_reto => vr_des_reto     --> Retorno OK / NOK
                                                 ,pr_tab_erro => vr_tab_erro);   --> Tabela com possíves erros
                   --Se Retornou erro
                   IF vr_des_reto <> 'OK' THEN
                     -- Se possui algum erro na tabela de erros
                     IF vr_tab_erro.count() > 0 THEN
                       -- Atribui críticas às variaveis
                       vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                       vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                     ELSE
                       vr_cdcritic := 0;
                       vr_dscritic := 'Erro ao criar o lancamento de ajuste';
                     END IF;
                     -- Gera exceção
                     RAISE vr_exc_saida;
										 END IF;
									 ELSE
									    -- Lança o crédito de abono na conta transitória (Bloqueado Prejuízo) - Reginaldo/AMcom
											PREJ0003.pc_gera_cred_cta_prj(pr_cdcooper => pr_cdcooper
																									, pr_nrdconta => pr_nrdconta
																									, pr_vlrlanc  => vr_vlabono
																									, pr_dtmvtolt => pr_dtmvtolt
																									, pr_cdcritic => vr_cdcritic
																									, pr_dscritic => vr_dscritic);
																													
											IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
												vr_cdcritic := 0;
												vr_dscritic := 'Erro ao criar o lancamento de ajuste em Bloqueado Prejuízo (' || vr_dscritic || ')';
																	
												RAISE vr_exc_saida;
											END IF;
															
											-- Lança histórico 2279 no extrato do prejuízo de C/C apenas em caráter informativo - Reginaldo/AMcom
											PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
																											, pr_nrdconta => pr_nrdconta
																											, pr_dtmvtolt => pr_dtmvtolt
																											, pr_cdhistor => 2279
																											, pr_vllanmto => vr_vlabono
																											, pr_nrctremp => pr_nrctremp
																											, pr_cdcritic => vr_cdcritic
																											, pr_dscritic => vr_dscritic); 
																															
											IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
												vr_cdcritic := 0;
												vr_dscritic := 'Erro ao criar o lancamento de ajuste no extrato do prejuizo de C/C.';
																	
												RAISE vr_exc_saida;
											END IF;
                   END IF;
                   -- Valor do lancamento recebe o saldo devedor
                   vr_vldpagto := nvl(vr_tab_calculado(vr_tab_calculado.FIRST).vlsdeved,0);
                 END IF;
                 
               ELSE
                 -- se for COMPEFORA 
                 IF pr_nmtelant = 'COMPEFORA' THEN
                   vr_vlajuste := vr_tab_calculado(vr_tab_calculado.FIRST).vlsdeved - pr_vldpagto;
                   vr_vldpagto := vr_tab_calculado(vr_tab_calculado.FIRST).vlsdeved;

                   -- lançar o valor do ajuste na conta do cooperado;
                   IF nvl(vr_vlajuste, 0) > 0 THEN
									   IF NOT vr_prejuzcc THEN
                     /* Lanca em C/C e atualiza o lote */
                     EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper     --> Cooperativa conectada
                                                   ,pr_dtmvtolt => pr_dtmvtolt     --> Movimento atual
                                                   ,pr_cdagenci => rw_cde.cdagenci --> Código da agência
                                                   ,pr_cdbccxlt => 100             --> Número do caixa
                                                   ,pr_cdoperad => pr_cdoperad     --> Código do Operador
                                                   ,pr_cdpactra => rw_cde.cdagenci --> P.A. da transação
                                                   ,pr_nrdolote => 600032          --> Numero do Lote
                                                   ,pr_nrdconta => pr_nrdconta     --> Número da conta
                                                   ,pr_cdhistor => 2012            --> Codigo historico 2012 - AJUSTE BOLETO
                                                   ,pr_vllanmto => vr_vlajuste     --> Valor da parcela emprestimo
                                                   ,pr_nrparepr => 0               --> Número parcelas empréstimo
                                                   ,pr_nrctremp => pr_nrctremp     --> Número do contrato de empréstimo
                                                   ,pr_des_reto => vr_des_reto     --> Retorno OK / NOK
                                                   ,pr_tab_erro => vr_tab_erro);   --> Tabela com possíves erros
                     --Se Retornou erro
                     IF vr_des_reto <> 'OK' THEN
                       -- Se possui algum erro na tabela de erros
                       IF vr_tab_erro.count() > 0 THEN
                         -- Atribui críticas às variaveis
                         vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                         vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                       ELSE
                         vr_cdcritic := 0;
                         vr_dscritic := 'Erro ao criar o lancamento de ajuste';
                       END IF;
                       -- Gera exceção
                       RAISE vr_exc_saida;
											 END IF;
										 ELSE
										  -- Lança o crédito de abono na conta transitória (Bloqueado Prejuízo) - Reginaldo/AMcom
											PREJ0003.pc_gera_cred_cta_prj(pr_cdcooper => pr_cdcooper
																									, pr_nrdconta => pr_nrdconta
																									, pr_vlrlanc  => vr_vlajuste
																									, pr_dtmvtolt => pr_dtmvtolt
																									, pr_cdcritic => vr_cdcritic
																									, pr_dscritic => vr_dscritic);
																													
											IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
												vr_cdcritic := 0;
												vr_dscritic := 'Erro ao criar o lancamento de ajuste em Bloqueado Prejuízo (' || vr_dscritic || ')';
																	
												RAISE vr_exc_saida;
											END IF;
															
											-- Lança histórico 2012 no extrato do prejuízo de C/C apenas em caráter informativo - Reginaldo/AMcom
											PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
																											, pr_nrdconta => pr_nrdconta
																											, pr_dtmvtolt => pr_dtmvtolt
																											, pr_cdhistor => 2012
																											, pr_vllanmto => vr_vlajuste
																											, pr_nrctremp => pr_nrctremp
																											, pr_cdcritic => vr_cdcritic
																											, pr_dscritic => vr_dscritic); 
																															
											IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
												vr_cdcritic := 0;
												vr_dscritic := 'Erro ao criar o lancamento de ajuste no extrato do prejuizo de C/C.';
																	
												RAISE vr_exc_saida;
											END IF;
                     END IF;
                   END IF;
                 ELSE
                   vr_cdcritic := 0;
                   vr_dscritic := 'Valor do boleto inferior para liquidar o contrato';
                   RAISE vr_exc_saida;
                 END IF;
               END IF;
             ELSE
                IF pr_vldpagto >= vr_tab_calculado(vr_tab_calculado.FIRST).vlsdeved THEN
                   -- atribuir o valor do saldo a liquidar do contrato
                   vr_vldpagto := vr_tab_calculado(vr_tab_calculado.FIRST).vlsdeved;
                END IF;
             END IF;
          END IF;
            
          /* IMPORTANTE: verificar a lógica em caso de pagto de quitação do contrato */
          empr0001.pc_gera_pagamentos_parcelas(pr_cdcooper => pr_cdcooper
                                              ,pr_cdagenci => rw_cde.cdagenci
                                              ,pr_nrdcaixa => 1
                                              ,pr_cdoperad => pr_cdoperad
                                              ,pr_nmdatela => 'COBEMP'
                                              ,pr_idorigem => pr_idorigem
                                              ,pr_cdpactra => rw_cde.cdagenci
                                              ,pr_nrdconta => pr_nrdconta
                                              ,pr_idseqttl => 1
                                              ,pr_dtmvtolt => pr_dtmvtolt
                                              ,pr_flgerlog => 'N'
                                              ,pr_nrctremp => pr_nrctremp
                                              ,pr_dtmvtoan => gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                                                         ,pr_dtmvtolt => pr_dtmvtolt - 1
                                                                                         ,pr_tipo => 'A')
                                              ,pr_totatual => vr_tab_calculado(vr_tab_calculado.FIRST).vlsdeved
                                              ,pr_totpagto => vr_vldpagto
                                              ,pr_tab_pgto_parcel => vr_tab_pgto_parcel
                                              ,pr_des_reto => vr_des_reto
                                              ,pr_tab_erro => vr_tab_erro);
          IF vr_des_reto <> 'OK' THEN
             -- Se possui algum erro na tabela de erros
             IF vr_tab_erro.count() > 0 THEN
               -- Atribui críticas às variaveis
               vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
               vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
             ELSE
               vr_cdcritic := 0;
               vr_dscritic := 'Erro ao gerar pagamento de parcelas';
             END IF;
             -- Gera exceção
             RAISE vr_exc_saida;
          END IF;          
  																				 
          -- Se está liquidando o contrato
          IF vr_tab_calculado(vr_tab_calculado.FIRST).vlsdeved = vr_vldpagto THEN
            vr_vldpagto:= 0; -- Na liquidação de empréstimo PP o valor já é debitado das Conta Transitória (Bloqueados Prejuízo)
          END IF;
											 
      /* se tipo de emprestimo for POS */
      ELSIF rw_crapepr.tpemprst = 2 THEN          

        -- se o boleto nao for para liquidar o contrato, entao separar as parcelas
        IF rw_cde.tpparcela <> 4 THEN
          -- Separa as parcelas
          vr_dsparcel := gene0002.fn_quebra_string(pr_string => rw_cde.dsparcel);

          -- verificar se existe parcela selecionada na geracao do boleto
          IF vr_dsparcel.count() = 0 OR TRIM(rw_cde.dsparcel) IS NULL THEN
             vr_cdcritic := 0;
             vr_dscritic := 'Erro ao gerar boleto. Parcela(s) nao selecionada(s).';
             RAISE vr_exc_saida;
          END IF;
        END IF;

        -- Atribui valor parametrizado para variavel
        vr_vldpagto := pr_vldpagto;

        -- buscar todas as parcelas do contrato
        EMPR0011.pc_busca_pagto_parc_pos(pr_cdcooper => pr_cdcooper
                                        ,pr_cdprogra => 'COBEMP'
                                        ,pr_dtmvtolt => pr_dtmvtolt
                                        ,pr_dtmvtoan => gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                                                   ,pr_dtmvtolt => pr_dtmvtolt - 1
                                                                                   ,pr_tipo => 'A')
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrctremp => pr_nrctremp
                                        ,pr_dtefetiv => rw_crapepr.dtmvtolt
                                        ,pr_cdlcremp => rw_crapepr.cdlcremp
                                        ,pr_vlemprst => rw_crapepr.vlemprst
                                        ,pr_txmensal => rw_crapepr.txmensal_w
                                        ,pr_dtdpagto => rw_crapepr.dtdpagto_w
                                        ,pr_vlsprojt => rw_crapepr.vlsprojt
                                        ,pr_qttolatr => rw_crapepr.qttolatr
                                        ,pr_tab_parcelas => vr_tab_parcelas
                                        ,pr_tab_calculado => vr_tab_calculado_pos
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);                                         

        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- se o boleto nao for para liquidar o contrato, entao verificar as parcelas que serao pagas
        IF rw_cde.tpparcela <> 4 THEN
          -- filtrar as parcelas que serao pagas
          FOR idx2 IN vr_tab_parcelas.first..vr_tab_parcelas.last LOOP

              vr_flgdel := TRUE;

              FOR idx IN vr_dsparcel.first..vr_dsparcel.last LOOP

                  IF GENE0002.fn_char_para_number(vr_dsparcel(idx)) = vr_tab_parcelas(idx2).nrparepr THEN
                     vr_flgdel := FALSE;
                     EXIT;
                  END IF;

              END LOOP;

              IF vr_flgdel OR vr_vldpagto = 0 THEN
                 vr_tab_parcelas.delete(idx2);
              ELSE
                 IF vr_vldpagto >= ROUND(vr_tab_parcelas(idx2).vlatrpag,2) THEN
                    vr_tab_parcelas(idx2).vlpagpar := ROUND(vr_tab_parcelas(idx2).vlatrpag,2);
                    vr_vldpagto := ROUND(vr_vldpagto,2) - ROUND(vr_tab_parcelas(idx2).vlatrpag,2);
                 ELSE
                    /* Quando ocorrer a COMPEFORA (pr_nmtelant = 'COMPEFORA') sistema deverá verificar o valor da diferença */
                    IF pr_nmtelant = 'COMPEFORA' AND rw_cde.tpparcela = 2 AND
                       ROUND(vr_tab_parcelas(idx2).vlatrpag,2) > vr_vldpagto THEN

                       /* vlr do atraso da última parcela utilizada – vlr que sobrou pra liquidar a última parcela utilizada */
                       vr_vlajuste := ROUND(vr_tab_parcelas(idx2).vlatrpag,2) - vr_vldpagto;
                       vr_tab_parcelas(idx2).vlpagpar := ROUND(vr_tab_parcelas(idx2).vlatrpag,2);

                       /* Valor do ajuste */
                       IF nvl(vr_vlajuste, 0) > 0 THEN
                          /* Lanca em C/C e atualiza o lote */
                          IF NOT vr_prejuzcc THEN
                          EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper     --> Cooperativa conectada
                                                        ,pr_dtmvtolt => pr_dtmvtolt     --> Movimento atual
                                                        ,pr_cdagenci => rw_cde.cdagenci --> Código da agência
                                                        ,pr_cdbccxlt => 100             --> Número do caixa
                                                        ,pr_cdoperad => pr_cdoperad     --> Código do Operador
                                                        ,pr_cdpactra => rw_cde.cdagenci --> P.A. da transação
                                                        ,pr_nrdolote => 600032          --> Numero do Lote
                                                        ,pr_nrdconta => pr_nrdconta     --> Número da conta
                                                        ,pr_cdhistor => 2012            --> Codigo historico 2012 - AJUSTE BOLETO
                                                        ,pr_vllanmto => vr_vlajuste     --> Valor da parcela emprestimo
                                                        ,pr_nrparepr => vr_tab_parcelas(idx2).nrparepr --> Número parcelas empréstimo
                                                        ,pr_nrctremp => pr_nrctremp     --> Número do contrato de empréstimo
                                                        ,pr_des_reto => vr_des_reto     --> Retorno OK / NOK
                                                        ,pr_tab_erro => vr_tab_erro);   --> Tabela com possíves erros
                          --Se Retornou erro
                          IF vr_des_reto <> 'OK' THEN
                            -- Se possui algum erro na tabela de erros
                            IF vr_tab_erro.count() > 0 THEN
                              -- Atribui críticas às variaveis
                              vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                              vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                            ELSE
                              vr_cdcritic := 0;
                              vr_dscritic := 'Erro ao criar o lancamento de ajuste';
                            END IF;
                            -- Gera exceção
                            RAISE vr_exc_saida;
                          END IF;
                          ELSE -- Se a conta está em prejuízo
                            -- Lança o crédito de abono na conta transitória (Bloqueado Prejuízo) - Reginaldo/AMcom
                            PREJ0003.pc_gera_cred_cta_prj(pr_cdcooper => pr_cdcooper
                                                        , pr_nrdconta => pr_nrdconta
                                                        , pr_vlrlanc  => vr_vlajuste
                                                        , pr_dtmvtolt => pr_dtmvtolt
                                                        , pr_cdcritic => vr_cdcritic
                                                        , pr_dscritic => vr_dscritic);
        																									
                            IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                              vr_cdcritic := 0;
                              vr_dscritic := 'Erro ao criar o lancamento de ajuste em Bloqueado Prejuízo (' || vr_dscritic || ')';
        													
                              RAISE vr_exc_saida;
                       END IF;
        											
                            -- Lança histórico 2279 no extrato do prejuízo de C/C apenas em caráter informativo - Reginaldo/AMcom
                            PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                                                            , pr_nrdconta => pr_nrdconta
                                                            , pr_dtmvtolt => pr_dtmvtolt
                                                            , pr_cdhistor => 2279
                                                            , pr_vllanmto => vr_vlajuste
                                                            , pr_nrctremp => pr_nrctremp
                                                            , pr_cdcritic => vr_cdcritic
                                                            , pr_dscritic => vr_dscritic); 
        																											
                            IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                              vr_cdcritic := 0;
                              vr_dscritic := 'Erro ao criar o lancamento de ajuste no extrato do prejuizo de C/C.';
        													
                              RAISE vr_exc_saida;
                            END IF; 
                          END IF;
                       END IF;
                    ELSE
                       vr_tab_parcelas(idx2).vlpagpar := ROUND(vr_vldpagto,2);
                    END IF;

                    vr_vldpagto := 0;
                 END IF;
              END IF;

          END LOOP;

          -- variavel volta a ser atribuida com o parametro
          vr_vldpagto := pr_vldpagto;

        ELSE
           -- se o boleto for para liquidar o contrato, comparar o valor da parcela com o saldo devedor
           IF pr_vldpagto < vr_tab_calculado_pos(vr_tab_calculado_pos.FIRST).vlsdeved  THEN

             IF rw_cde.idboleto > 0 THEN -- Boletagem Massiva
               -- Deve gerar abono em CC da diferença do saldo e valor pago
               vr_vlabono := nvl(vr_tab_calculado_pos(vr_tab_calculado_pos.FIRST).vlsdeved,0) - pr_vldpagto;

               IF vr_vlabono > 0 THEN
                 -- Gerar abono
                 IF NOT vr_prejuzcc THEN
                   EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper     --> Cooperativa conectada
                                                 ,pr_dtmvtolt => pr_dtmvtolt     --> Movimento atual
                                                 ,pr_cdagenci => rw_cde.cdagenci --> Código da agência
                                                 ,pr_cdbccxlt => 100             --> Número do caixa
                                                 ,pr_cdoperad => pr_cdoperad     --> Código do Operador
                                                 ,pr_cdpactra => rw_cde.cdagenci --> P.A. da transação
                                                 ,pr_nrdolote => 600032          --> Numero do Lote
                                                 ,pr_nrdconta => pr_nrdconta     --> Número da conta
                                                 ,pr_cdhistor => 2279            --> Codigo historico 2279 - ABONO EMP/FIN (ABONO EMPRESTIMO/FINANCIAMENTO)
                                                 ,pr_vllanmto => vr_vlabono      --> Valor da parcela emprestimo
                                                 ,pr_nrparepr => 0               --> Número parcelas empréstimo
                                                 ,pr_nrctremp => pr_nrctremp     --> Número do contrato de empréstimo
                                                 ,pr_des_reto => vr_des_reto     --> Retorno OK / NOK
                                                 ,pr_tab_erro => vr_tab_erro);   --> Tabela com possíves erros
                   --Se Retornou erro
                   IF vr_des_reto <> 'OK' THEN
                     -- Se possui algum erro na tabela de erros
                     IF vr_tab_erro.count() > 0 THEN
                       -- Atribui críticas às variaveis
                       vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                       vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                     ELSE
                       vr_cdcritic := 0;
                       vr_dscritic := 'Erro ao criar o lancamento de ajuste';
                     END IF;
                     -- Gera exceção
                     RAISE vr_exc_saida;
                   END IF;
                 ----
                 ELSE
                    -- Lança o crédito de abono na conta transitória (Bloqueado Prejuízo) - Reginaldo/AMcom
                    PREJ0003.pc_gera_cred_cta_prj(pr_cdcooper => pr_cdcooper
                                                , pr_nrdconta => pr_nrdconta
                                                , pr_vlrlanc  => vr_vlabono
                                                , pr_dtmvtolt => pr_dtmvtolt
                                                , pr_cdcritic => vr_cdcritic
                                                , pr_dscritic => vr_dscritic);
                      																										
                    IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                      vr_cdcritic := 0;
                      vr_dscritic := 'Erro ao criar o lancamento de ajuste em Bloqueado Prejuízo (' || vr_dscritic || ')';
                      														
                      RAISE vr_exc_saida;
                    END IF;
                      												
                    -- Lança histórico 2279 no extrato do prejuízo de C/C apenas em caráter informativo - Reginaldo/AMcom
                    PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                                                    , pr_nrdconta => pr_nrdconta
                                                    , pr_dtmvtolt => pr_dtmvtolt
                                                    , pr_cdhistor => 2012
                                                    , pr_vllanmto => vr_vlabono
                                                    , pr_nrctremp => pr_nrctremp
                                                    , pr_cdcritic => vr_cdcritic
                                                    , pr_dscritic => vr_dscritic); 
                      																												
                    IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                      vr_cdcritic := 0;
                      vr_dscritic := 'Erro ao criar o lancamento de ajuste no extrato do prejuizo de C/C.';
                      														
                      RAISE vr_exc_saida;
                    END IF; 
                 END IF;

                 -- Valor do lancamento recebe o saldo devedor
                 vr_vldpagto := nvl(vr_tab_calculado_pos(vr_tab_calculado_pos.FIRST).vlsdeved,0);
               END IF;

             ELSE
               -- se for COMPEFORA
               IF pr_nmtelant = 'COMPEFORA' THEN
                 vr_vlajuste := vr_tab_calculado_pos(vr_tab_calculado_pos.FIRST).vlsdeved - pr_vldpagto;
                 vr_vldpagto := vr_tab_calculado_pos(vr_tab_calculado_pos.FIRST).vlsdeved;

                 -- lançar o valor do ajuste na conta do cooperado;
                 IF nvl(vr_vlajuste, 0) > 0 THEN
                   /* Lanca em C/C e atualiza o lote */
                   IF NOT vr_prejuzcc THEN
                     EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper     --> Cooperativa conectada
                                                   ,pr_dtmvtolt => pr_dtmvtolt     --> Movimento atual
                                                   ,pr_cdagenci => rw_cde.cdagenci --> Código da agência
                                                   ,pr_cdbccxlt => 100             --> Número do caixa
                                                   ,pr_cdoperad => pr_cdoperad     --> Código do Operador
                                                   ,pr_cdpactra => rw_cde.cdagenci --> P.A. da transação
                                                   ,pr_nrdolote => 600032          --> Numero do Lote
                                                   ,pr_nrdconta => pr_nrdconta     --> Número da conta
                                                   ,pr_cdhistor => 2012            --> Codigo historico 2012 - AJUSTE BOLETO
                                                   ,pr_vllanmto => vr_vlajuste     --> Valor da parcela emprestimo
                                                   ,pr_nrparepr => 0               --> Número parcelas empréstimo
                                                   ,pr_nrctremp => pr_nrctremp     --> Número do contrato de empréstimo
                                                   ,pr_des_reto => vr_des_reto     --> Retorno OK / NOK
                                                   ,pr_tab_erro => vr_tab_erro);   --> Tabela com possíves erros
                     --Se Retornou erro
                     IF vr_des_reto <> 'OK' THEN
                       -- Se possui algum erro na tabela de erros
                       IF vr_tab_erro.count() > 0 THEN
                         -- Atribui críticas às variaveis
                         vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                         vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                       ELSE
                         vr_cdcritic := 0;
                         vr_dscritic := 'Erro ao criar o lancamento de ajuste';
                       END IF;
                       -- Gera exceção
                       RAISE vr_exc_saida;
                     END IF;
                   ELSE
                      -- Lança o crédito de abono na conta transitória (Bloqueado Prejuízo) - Reginaldo/AMcom
                      PREJ0003.pc_gera_cred_cta_prj(pr_cdcooper => pr_cdcooper
                                                  , pr_nrdconta => pr_nrdconta
                                                  , pr_vlrlanc  => vr_vlajuste
                                                  , pr_dtmvtolt => pr_dtmvtolt
                                                  , pr_cdcritic => vr_cdcritic
                                                  , pr_dscritic => vr_dscritic);
  																													
                      IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                        vr_cdcritic := 0;
                        vr_dscritic := 'Erro ao criar o lancamento de ajuste em Bloqueado Prejuízo (' || vr_dscritic || ')';
  																	
                        RAISE vr_exc_saida;
                      END IF;
  															
                      -- Lança histórico 2012 no extrato do prejuízo de C/C apenas em caráter informativo - Reginaldo/AMcom
                      PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper => pr_cdcooper
                                                      , pr_nrdconta => pr_nrdconta
                                                      , pr_dtmvtolt => pr_dtmvtolt
                                                      , pr_cdhistor => 2012
                                                      , pr_vllanmto => vr_vlajuste
                                                      , pr_nrctremp => pr_nrctremp
                                                      , pr_cdcritic => vr_cdcritic
                                                      , pr_dscritic => vr_dscritic); 
  																															
                      IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                        vr_cdcritic := 0;
                        vr_dscritic := 'Erro ao criar o lancamento de ajuste no extrato do prejuizo de C/C.';
  																	
                        RAISE vr_exc_saida;
                      END IF;
                   END IF;
                 END IF;
               ELSE
                 vr_cdcritic := 0;
                 vr_dscritic := 'Valor do boleto inferior para liquidar o contrato';
                 RAISE vr_exc_saida;
               END IF;
             END IF;
           ELSE
              IF pr_vldpagto >= vr_tab_calculado_pos(vr_tab_calculado_pos.FIRST).vlsdeved THEN
                 -- atribuir o valor do saldo a liquidar do contrato
                 vr_vldpagto := vr_tab_calculado_pos(vr_tab_calculado_pos.FIRST).vlsdeved;
              END IF;
           END IF;
        END IF;
          
        -----------------------------------------------------------------------------------------------
        -- Efetuar o pagamento das parcelas
        -----------------------------------------------------------------------------------------------
        --
        vr_tab_price.DELETE;
        IF vr_tab_parcelas.COUNT() > 0 THEN
          -- Percorrer todos os registros
          FOR idx IN vr_tab_parcelas.FIRST..vr_tab_parcelas.LAST LOOP
            --       
            vr_vldpagto := vr_vldpagto + (CASE WHEN rw_cde.tpparcela <> 4  THEN vr_tab_parcelas(idx).vlpagpar ELSE vr_tab_parcelas(idx).vlatrpag END);
            EMPR0011.pc_gera_pagto_pos(pr_cdcooper  => pr_cdcooper
                                      ,pr_cdprogra =>  vr_cdprogra
                                      ,pr_dtcalcul  => pr_dtmvtolt
                                      ,pr_flgbatch  => TRUE -- Confirmar
                                      ,pr_nrdconta  => pr_nrdconta 
                                      ,pr_nrctremp  => pr_nrctremp 
                                      ,pr_nrparepr  => vr_tab_parcelas(idx).nrparepr
                                      ,pr_vlpagpar  => (CASE WHEN rw_cde.tpparcela <> 4  THEN vr_tab_parcelas(idx).vlpagpar ELSE vr_tab_parcelas(idx).vlatrpag END)
                                      ,pr_idseqttl  => 1 -- Confirmar
                                      ,pr_cdagenci  => rw_cde.cdagenci
                                      ,pr_cdpactra  => rw_cde.cdagenci
                                      ,pr_nrdcaixa  => 1 -- Confirmar
                                      ,pr_cdoperad  => '1'
                                      ,pr_nrseqava  => 0 -- Fixo
                                      ,pr_idorigem  => 7 -- BATCH
                                      ,pr_nmdatela  => pr_nmtelant
                                      ,pr_tab_price => vr_tab_price
                                      ,pr_cdcritic  => vr_cdcritic
                                      ,pr_dscritic  => vr_dscritic);
                                          
            -- Se houve erro
            IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END LOOP;  
        END IF; -- vr_tab_parcelas.COUNT() > 0
      END IF; -- TR/PP/POS

      -- Se a conta está em prejuízo, lança débito referente ao valor pago na conta transitória - Reginaldo/AMcom
      IF vr_vldpagto > 0 AND vr_prejuzcc THEN
        PREJ0003.pc_gera_debt_cta_prj(pr_cdcooper => pr_cdcooper
                                    , pr_nrdconta => pr_nrdconta
                                    , pr_dtmvtolt => pr_dtmvtolt
                                    , pr_vlrlanc  => vr_vldpagto
                                    , pr_cdcritic => vr_cdcritic
                                    , pr_dscritic => vr_dscritic);

        IF nvl(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          vr_dscritic := 'Erro ao debitar pagamento das parcelas do Bloqueado Prejuizo (' || vr_dscritic || ')';
          RAISE vr_exc_saida;
        END IF;
      END IF;
      
 		EXCEPTION	
		  WHEN vr_exc_saida THEN
				-- Se possui código de crítica e não foi informado a descrição
				IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					 -- Busca descrição da crítica
					 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
				END IF;

				-- Atribui exceção para os parametros de crítica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;

			WHEN OTHERS THEN  				
				-- Atribui exceção para os parametros de crítica				
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := 'Erro nao tratado na EMPR0007.pc_pagar_epr_cobranca: ' || SQLERRM;			

    END;

  END pc_pagar_epr_cobranca;


  -- procedure para lancar o valor para contratos TR
  PROCEDURE pc_gera_lancamento_epr_tr(pr_cdcooper IN crapcop.cdcooper%TYPE
                                     ,pr_nrdconta IN tbrecup_cobranca.nrdconta%TYPE
                                     ,pr_nrctremp IN tbrecup_cobranca.nrctremp%TYPE
                                     ,pr_vllanmto IN craplcm.vllanmto%TYPE
																		 ,pr_cdoperad IN crapope.cdoperad%TYPE
																		 ,pr_idorigem IN INTEGER
                                     ,pr_nmtelant IN VARCHAR2                     --> Verificar COMPEFORA
                                     ,pr_vltotpag OUT NUMBER                      --> Retorno do valor pago
                                     ,pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS                --> Descrição da crítica
  BEGIN
    /* .............................................................................
      Programa: pc_gera_lancamento_epr_tr
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Carlos Rafael Tanholi
      Data    : Agosto/15.                    Ultima atualizacao: 05/07/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina referente ao lancamento do valor para contratos TR

      Observacao: -----

      Alteracoes: 
      
      19/02/2016 - Retirado filtro de data do cursor cr_crapepr. (SD 400794 - Rafael)

	  08/03/2016 - Realizado checkin e checkout novamente pois não foi liberado mês
	               passado. (SD 400794 - Rafael)

      06/06/2016 - Alteracao para chamar pc_leitura_lem_car, criacao do pr_nmtelant
                   e debito do valor do Juros de Mora e Multa. (Jaison/James)

      13/07/2016 - Alterado para utilizar as variveis de quantidade de parcelas calculadas
                   e meses decorridos, ao invés dos campos da tabela. Os campos podem 
                   estar desatualizados no empréstimo TR (Douglas - Chamado 463063)
                   
      19/10/2016 - Deverá avaliar o indicador de pagamentos apenas quando não estiver
                   em um acordo ativo, pois para ACORDOS poderá ocorrer o pagamento de 
                   mais de uma parcela do acordo no mesmo mês ( Renato Darosci - Supero )
                   
      16/01/2017 - Alterado para retornar valor total pago do emprestimo. 
                   PRJ302 - Acordo (Odirlei-AMcom)
                   
      20/01/2017 - Ajuste para permitir efetuar varios pagamentos dentro do mes. (Chamado: 585221)

      24/02/2017 - Contratos do produto TR nao devera cobrar multa e juros de mora
                   quando o contrato estiver com acordo ativo. (Jaison/James)

      05/07/2018 - PJ450 Regulatório de Credito - Substituido o Insert na tabela craplcm
                   pela chamada da rotina lanc0001.pc_gerar_lancamento_conta. (Josiane Stiehler - AMcom)
     07/08/2018  - 9318:Pagamento de Emprestimo  Transferencia para conta
                                 transitoria quando a origem da tela for BLQPREJU  Rangel Decker (AMcom)


    ..............................................................................*/

    DECLARE
		
      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      vr_exc_null EXCEPTION;
      vr_exc_undo EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(4000);
      vr_flgativo   NUMBER; -- Indicar acordo ativo

      -- Erro em chamadas da pc_gera_erro
      vr_des_reto VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;

      -- Variaveis para gravação da craplot
      vr_cdagenci CONSTANT PLS_INTEGER := 1;
      vr_cdbccxlt CONSTANT PLS_INTEGER := 100;

      -- PJ450
      vr_incrineg      INTEGER;
      vr_tab_retorno   LANC0001.typ_reg_retorno;

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Busca o cadastro de linhas de crédito
      CURSOR cr_craplcr(pr_cdlcremp IN craplcr.cdlcremp%TYPE)IS
        SELECT lcr.cdlcremp
              ,lcr.txdiaria
              ,lcr.cdusolcr
          FROM craplcr lcr
         WHERE lcr.cdcooper = pr_cdcooper
				   AND lcr.cdlcremp = pr_cdlcremp;

      -- Buscar o cadastro dos associados da Cooperativa
      CURSOR cr_crapass IS
        SELECT ass.nrdconta
              ,ass.vllimcre
              ,ass.cdagenci
              ,ass.cdsecext
              ,ass.nrramemp
              ,ass.inpessoa
              ,ass.nmprimtl
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
				   AND ass.nrdconta = pr_nrdconta;

      -- Busca das informações de saldo cfme a conta
      CURSOR cr_crapsld IS
        SELECT sld.nrdconta
              ,sld.vlsdblfp
              ,sld.vlsdbloq
              ,sld.vlsdblpr
              ,sld.vlsddisp
              ,sld.vlipmfap
              ,sld.vlipmfpg
              ,sld.vlsdchsl
          FROM crapsld sld
         WHERE sld.cdcooper = pr_cdcooper
				   AND sld.nrdconta = pr_nrdconta;

      -- Busca das informações de históricos de lançamento
      CURSOR cr_craphis IS
        SELECT his.cdhistor
              ,his.inhistor
              ,his.indoipmf
          FROM craphis his
         WHERE cdcooper = pr_cdcooper;
         
      -- Busca os dados da proposta de emprestimo
      CURSOR cr_crawepr IS
        SELECT dtvencto
          FROM crawepr
         WHERE cdcooper = pr_cdcooper
           and nrdconta = pr_nrdconta
           and nrctremp = pr_nrctremp;         
      rw_crawepr cr_crawepr%ROWTYPE;    

      -- Busca dos empréstimos
      CURSOR cr_crapepr IS
        SELECT epr.rowid
              ,epr.nrdconta
              ,epr.nrctremp
              ,epr.inliquid
              ,epr.qtpreemp
              ,epr.qtprecal
              ,epr.vlsdeved
              ,epr.dtmvtolt
              ,epr.inprejuz
              ,epr.txjuremp
              ,epr.vljuracu
              ,epr.dtdpagto
              ,epr.flgpagto
              ,epr.qtmesdec
              ,epr.vlpreemp
              ,epr.cdlcremp
              ,epr.qtprepag
              ,epr.dtultpag
              ,epr.tpdescto
              ,epr.indpagto
              ,epr.cdagenci
              ,epr.cdfinemp
              ,epr.vlemprst
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper          --> Coop conectada
           AND epr.nrdconta = pr_nrdconta          --> Nr. da Conta
					 AND epr.nrctremp = pr_nrctremp          --> Nr. do contrato
           AND epr.inliquid = 0                    --> Somente não liquidados
           AND epr.flgpagto = 0                    --> Débito em conta
           AND epr.tpemprst = 0;                   --> Price
			rw_crapepr cr_crapepr%ROWTYPE;

      -- Busca dos lançamentos de deposito a vista
      CURSOR cr_craplcm IS
        SELECT lcm.nrdconta
              ,lcm.dtrefere
              ,lcm.vllanmto
              ,lcm.dtmvtolt
              ,lcm.cdhistor
              ,ROW_NUMBER () OVER (PARTITION BY lcm.nrdconta, lcm.cdhistor
                                       ORDER BY lcm.nrdconta, lcm.cdhistor) sqatureg
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper
				   AND lcm.nrdconta = pr_nrdconta
           AND lcm.cdhistor <> 289
           AND lcm.dtmvtolt >= rw_crapdat.dtmvtolt --> Superior ou igual a data corrente
         ORDER BY lcm.cdhistor;

      -- Buscar as capas de lote para a cooperativa e data atual
      CURSOR cr_craplot(pr_nrdolote IN craplot.nrdolote%TYPE
                       ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE) IS
        SELECT lot.cdagenci
              ,lot.cdbccxlt
              ,lot.nrdolote
              ,lot.tplotmov
              ,lot.nrseqdig
              ,lot.vlinfodb
              ,lot.vlcompdb
              ,lot.qtinfoln
              ,lot.qtcompln
              ,lot.vlinfocr
              ,lot.vlcompcr
              ,lot.dtmvtolt
              ,rowid
          FROM craplot lot
         WHERE lot.cdcooper = pr_cdcooper
           AND lot.dtmvtolt = pr_dtmvtolt
           AND lot.cdagenci = vr_cdagenci
           AND lot.cdbccxlt = vr_cdbccxlt
           AND lot.nrdolote = pr_nrdolote;
      -- Criaremos um registro para cada tipo de lote utilizado
      rw_craplot_8457 cr_craplot%ROWTYPE; --> Lancamento de prestação de empréstimo
      rw_craplot_8453 cr_craplot%ROWTYPE; --> Lancamento de pagamento de empréstimo na CC

      -- Verificar se já existe outro lançamento para o lote atual
      CURSOR cr_craplem_nrdocmto(pr_dtmvtolt crapdat.dtmvtolt%TYPE
                                ,pr_nrdolote craplot.nrdolote%TYPE
                                ,pr_nrdconta crapepr.nrdconta%TYPE
                                ,pr_nrdocmto craplem.nrdocmto%TYPE) IS
        SELECT count(1)
          FROM craplem
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtmvtolt
           AND cdagenci = vr_cdagenci
           AND cdbccxlt = vr_cdbccxlt
           AND nrdolote = pr_nrdolote
           AND nrdconta = pr_nrdconta
           AND nrdocmto = pr_nrdocmto;
      vr_qtd_lem_nrdocmto NUMBER;

      ------------------------- ESTRUTURAS DE REGISTRO ---------------------

      -- Definição dos lançamentos de deposito a vista
      TYPE typ_reg_craplcm_det IS
        RECORD(dtrefere craplcm.dtrefere%TYPE,
               vllanmto craplcm.vllanmto%TYPE,
               dtmvtolt craplcm.dtmvtolt%TYPE,
               cdhistor craplcm.cdhistor%TYPE,
               sqatureg NUMBER(05));
      TYPE typ_tab_craplcm_det IS
        TABLE OF typ_reg_craplcm_det
          INDEX BY PLS_INTEGER; -- Cod historico || sequencia registro

      TYPE typ_reg_craplcm IS
        RECORD(tab_craplcm typ_tab_craplcm_det);
      TYPE typ_tab_craplcm IS
        TABLE OF typ_reg_craplcm
          INDEX BY PLS_INTEGER; -- Numero da conta
      vr_tab_craplcm typ_tab_craplcm;

      -- Definição de tipo para armazenar informações da linha de crédito
      TYPE typ_reg_craplcr IS
        RECORD(txdiaria craplcr.txdiaria%TYPE
              ,cdusolcr craplcr.cdusolcr%TYPE);
      TYPE typ_tab_craplcr IS
        TABLE OF typ_reg_craplcr
          INDEX BY PLS_INTEGER; -- Cod linha de crédito
      vr_tab_craplcr typ_tab_craplcr;

      -- Definição de tipo para armazenar informações dos associados
      TYPE typ_reg_crapass IS
        RECORD(vllimcre crapass.vllimcre%TYPE
              ,cdagenci crapass.cdagenci%TYPE
              ,cdsecext crapass.cdsecext%TYPE
              ,nrramemp crapass.nrramemp%TYPE
              ,inpessoa crapass.inpessoa%TYPE
              ,nmprimtl crapass.nmprimtl%TYPE);
      TYPE typ_tab_crapass IS
        TABLE OF typ_reg_crapass
          INDEX BY PLS_INTEGER; --> Número da conta
      vr_tab_crapass typ_tab_crapass;

      -- Definição de tipo para armazenar informações dos saldos associados
      TYPE typ_reg_crapsld IS
        RECORD(vlsdblfp crapsld.vlsdblfp%TYPE
              ,vlsdbloq crapsld.vlsdbloq%TYPE
              ,vlsdblpr crapsld.vlsdblpr%TYPE
              ,vlsddisp crapsld.vlsddisp%TYPE
              ,vlsdchsl crapsld.vlsdchsl%TYPE
              ,vlipmfap crapsld.vlipmfap%TYPE
              ,vlipmfpg crapsld.vlipmfpg%TYPE);
      TYPE typ_tab_crapsld IS
        TABLE OF typ_reg_crapsld
          INDEX BY PLS_INTEGER; --> Número da conta
      vr_tab_crapsld typ_tab_crapsld;

      -- Definição de tipo para armazenar as informações de histórico
      TYPE typ_reg_craphis IS
        RECORD(inhistor craphis.inhistor%TYPE
              ,indoipmf craphis.indoipmf%TYPE);
      TYPE typ_tab_craphis IS
        TABLE OF typ_reg_craphis
          INDEX BY PLS_INTEGER; --> Código do histórico
      vr_tab_craphis typ_tab_craphis;

      ----------------------------- VARIAVEIS ------------------------------

      -- Variáveis auxiliares ao processo
      vr_dstextab     craptab.dstextab%TYPE;  --> Busca na craptab
      vr_inusatab     BOOLEAN;                --> Indicador S/N de utilização de tabela de juros
      vr_tab_vlmindeb NUMBER;                 --> Valor mínimo a debitar por prestações de empréstimo
      vr_flgrejei     BOOLEAN;                --> Flag para indicação de empréstimo rejeitado
      vr_msdecatr     crapepr.qtmesdec%TYPE;  --> Meses decorridos do empréstimo
      vr_flgprepg     BOOLEAN;                --> Flag para indicação de prestações antecipadas
      vr_flgpgadt     BOOLEAN;                --> Flag para indicação de pagamentos antecipados
      vr_pgtofora     BOOLEAN;                --> Flag para indicação de pagamento por for
      vr_vlsldtot     NUMBER;                 --> Valor de saldo total
      vr_vlcalcob     NUMBER;                 --> Valor calculado de cobrança
      vr_vlpremes     NUMBER;                 --> Valor da prestação do mês
      vr_prxpagto     DATE;                   --> Data do próximo pagamento
      vr_nrdocmto     craplem.nrdocmto%TYPE;  --> Número do documento para a LEM
      vr_dtdpagto     crapepr.dtdpagto%TYPE;  --> Data do pagamento
      vr_ind_lcm      NUMBER(10);             --> Indice da tabela craplcm
			vr_cdprogra     VARCHAR2(10) := 'COBEMP';
      vr_nrdoclcm     craplcm.nrdocmto%TYPE;

      -- Variáveis para passagem a rotina pc_calcula_lelem
      vr_diapagto     INTEGER;
      vr_qtprepag     crapepr.qtprepag%TYPE;
      vr_vlprepag     craplem.vllanmto%TYPE;
      vr_vljuracu     crapepr.vljuracu%TYPE;
      vr_vljurmes     crapepr.vljurmes%TYPE;
      vr_dtultpag     crapepr.dtultpag%TYPE;
      vr_txdjuros     crapepr.txjuremp%TYPE;
      vr_vldescto     NUMBER(18,6);           --> Valor de desconto das parcelas
      vr_qtprecal crapepr.qtprecal%TYPE;      --> Quantidade de parcelas do empréstimo
      vr_vlsdeved NUMBER(14,2);               --> Saldo devedor do empréstimo			
      vr_qtmesdec crapepr.qtmesdec%TYPE;
      vr_vlpreapg crapepr.vlpreemp%TYPE;
      vr_cdhismul INTEGER;
      vr_vldmulta NUMBER;
      vr_cdhismor INTEGER;
      vr_vljumora NUMBER;

      -- Variáveis de CPMF
      vr_dtinipmf DATE;
      vr_dtfimpmf DATE;
      vr_txcpmfcc NUMBER(12,6);
      vr_txrdcpmf NUMBER(12,6);
      vr_indabono INTEGER;
      vr_dtiniabo DATE;

      -- Variaveis para o CPMF cfme cada histório na craplcm
      vr_inhistor PLS_INTEGER;
      vr_indoipmf PLS_INTEGER;
      vr_txdoipmf NUMBER;

			vr_prejuzcc BOOLEAN; -- Indicador de conta corrente em prejuízo (Reginaldo/AMcom - P450)

      ----------------- SUBROTINAS INTERNAS --------------------

      -- Subrotina para checar a existência de lote cfme tipo passado
      PROCEDURE pc_cria_craplot(pr_dtmvtolt   IN craplot.dtmvtolt%TYPE
                               ,pr_nrdolote   IN craplot.nrdolote%TYPE
                               ,pr_tplotmov   IN craplot.tplotmov%TYPE
                               ,pr_rw_craplot IN OUT NOCOPY cr_craplot%ROWTYPE
                               ,pr_dscritic  OUT VARCHAR2) IS
      BEGIN
        -- Buscar as capas de lote cfme lote passado
        OPEN cr_craplot(pr_nrdolote => pr_nrdolote
                       ,pr_dtmvtolt => pr_dtmvtolt);
        FETCH cr_craplot
         INTO pr_rw_craplot; --> Rowtype passado
        -- Se não tiver encontrado
        IF cr_craplot%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_craplot;
          -- Efetuar a inserção de um novo registro
          BEGIN
            INSERT INTO craplot(cdcooper
                               ,dtmvtolt
                               ,cdagenci
                               ,cdbccxlt
                               ,nrdolote
                               ,tplotmov
                               ,nrseqdig
                               ,vlinfodb
                               ,vlcompdb
                               ,qtinfoln
                               ,qtcompln
                               ,vlinfocr
                               ,vlcompcr
                               ,cdhistor
                               ,tpdmoeda
                               ,cdoperad)
                         VALUES(pr_cdcooper
                               ,pr_dtmvtolt
                               ,vr_cdagenci
                               ,vr_cdbccxlt
                               ,pr_nrdolote --> Cfme enviado
                               ,pr_tplotmov --> Cfme enviado
                               ,0
                               ,0
                               ,0
                               ,0
                               ,0
                               ,0
                               ,0
                               ,0
                               ,1
                               ,'1')
                       RETURNING dtmvtolt
                                ,cdagenci
                                ,cdbccxlt
                                ,nrdolote
                                ,tplotmov
                                ,nrseqdig
                                ,rowid
                            INTO pr_rw_craplot.dtmvtolt
                                ,pr_rw_craplot.cdagenci
                                ,pr_rw_craplot.cdbccxlt
                                ,pr_rw_craplot.nrdolote
                                ,pr_rw_craplot.tplotmov
                                ,pr_rw_craplot.nrseqdig
                                ,pr_rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Erro ao inserir capas de lotes (craplot), lote: '||pr_nrdolote||'. Detalhes: '||sqlerrm;
          END;
        ELSE
          -- apenas fechar o cursor
          CLOSE cr_craplot;
        END IF;
      END;

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
        RAISE vr_exc_erro;
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
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

			-- Verifica se a conta corrente está em prejuízo (Reginaldo/AMcom)
			vr_prejuzcc := PREJ0003.fn_verifica_preju_conta(pr_cdcooper => pr_cdcooper
			                                              , pr_nrdconta => pr_nrdconta);

      -- Procedimento padrão de busca de informações de CPMF
      gene0005.pc_busca_cpmf(pr_cdcooper  => pr_cdcooper
                            ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                            ,pr_dtinipmf  => vr_dtinipmf
                            ,pr_dtfimpmf  => vr_dtfimpmf
                            ,pr_txcpmfcc  => vr_txcpmfcc
                            ,pr_txrdcpmf  => vr_txrdcpmf
                            ,pr_indabono  => vr_indabono
                            ,pr_dtiniabo  => vr_dtiniabo
                            ,pr_cdcritic  => vr_cdcritic
                            ,pr_dscritic  => vr_dscritic);
      -- Se retornou erro
      IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
        -- Gerar raise
        vr_cdcritic := 0;
        RAISE vr_exc_erro;
      END IF;

      ------------------
      -- Verificar se há acordo ativo para o contrato
      RECP0001.pc_verifica_acordo_ativo(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrctremp => pr_nrctremp
                                       ,pr_cdorigem => 3
                                       ,pr_flgativo => vr_flgativo
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
          
      -- Se houve retorno de erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gera exceção
        RAISE vr_exc_undo;
      END IF;
      ------------------
      
      -- Abre cursor do emprestimo
      OPEN cr_crapepr;
			FETCH cr_crapepr INTO rw_crapepr;

      IF cr_crapepr%FOUND THEN
        
        -- Busca os dados da proposta de emprestimo
        OPEN cr_crawepr;
        FETCH cr_crawepr
         INTO rw_crawepr;
        -- Se não encontrar
        IF cr_crawepr%NOTFOUND THEN
          -- Fechar o cursor pois haverá raise
          CLOSE cr_crawepr;
          -- Montar mensagem de critica
          vr_cdcritic := 356;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_undo;
        ELSE
          -- Apenas fechar o cursor
          CLOSE cr_crawepr;
        END IF;      
      
				-- Busca do cadastro de linhas de crédito de empréstimo
				FOR rw_craplcr IN cr_craplcr(rw_crapepr.cdlcremp) LOOP
					-- Guardamos a taxa e o indicador de emissão de boletos
					vr_tab_craplcr(rw_craplcr.cdlcremp).txdiaria := rw_craplcr.txdiaria;
					vr_tab_craplcr(rw_craplcr.cdlcremp).cdusolcr := rw_craplcr.cdusolcr;
				END LOOP;

				-- Busca dos associados da cooperativa
				FOR rw_crapass IN cr_crapass LOOP
					-- Adicionar ao vetor as informações chaveando pela conta
					vr_tab_crapass(rw_crapass.nrdconta).vllimcre := rw_crapass.vllimcre;
					vr_tab_crapass(rw_crapass.nrdconta).cdagenci := rw_crapass.cdagenci;
					vr_tab_crapass(rw_crapass.nrdconta).cdsecext := rw_crapass.cdsecext;
					vr_tab_crapass(rw_crapass.nrdconta).nrramemp := rw_crapass.nrramemp;
					vr_tab_crapass(rw_crapass.nrdconta).nrramemp := rw_crapass.nrramemp;
					vr_tab_crapass(rw_crapass.nrdconta).inpessoa := rw_crapass.inpessoa;
					vr_tab_crapass(rw_crapass.nrdconta).nmprimtl := rw_crapass.nmprimtl;
				END LOOP;

				-- Busca dos lancamentos de deposito a vista
				FOR rw_craplcm IN cr_craplcm LOOP
					-- Adicionar ao vetor as informações chaveando pela conta
					vr_tab_craplcm(rw_craplcm.nrdconta).tab_craplcm(cr_craplcm%ROWCOUNT).dtrefere := rw_craplcm.dtrefere;
					vr_tab_craplcm(rw_craplcm.nrdconta).tab_craplcm(cr_craplcm%ROWCOUNT).vllanmto := rw_craplcm.vllanmto;
					vr_tab_craplcm(rw_craplcm.nrdconta).tab_craplcm(cr_craplcm%ROWCOUNT).dtmvtolt := rw_craplcm.dtmvtolt;
					vr_tab_craplcm(rw_craplcm.nrdconta).tab_craplcm(cr_craplcm%ROWCOUNT).cdhistor := rw_craplcm.cdhistor;
					vr_tab_craplcm(rw_craplcm.nrdconta).tab_craplcm(cr_craplcm%ROWCOUNT).sqatureg := rw_craplcm.sqatureg;
				END LOOP;

				-- Busca das informações de saldo cfme a conta
				FOR rw_crapsld IN cr_crapsld LOOP
					-- Adicionar ao vetor as informações de saldo novamente chaveando pela conta
					vr_tab_crapsld(rw_crapsld.nrdconta).vlsdblfp := rw_crapsld.vlsdblfp;
					vr_tab_crapsld(rw_crapsld.nrdconta).vlsdbloq := rw_crapsld.vlsdbloq;
					vr_tab_crapsld(rw_crapsld.nrdconta).vlsdblpr := rw_crapsld.vlsdblpr;
					vr_tab_crapsld(rw_crapsld.nrdconta).vlsddisp := rw_crapsld.vlsddisp;
					vr_tab_crapsld(rw_crapsld.nrdconta).vlipmfap := rw_crapsld.vlipmfap;
					vr_tab_crapsld(rw_crapsld.nrdconta).vlipmfpg := rw_crapsld.vlipmfpg;
					vr_tab_crapsld(rw_crapsld.nrdconta).vlsdchsl := rw_crapsld.vlsdchsl;
				END LOOP;

				-- Busca do cadastro de histórico
				FOR rw_craphis IN cr_craphis LOOP
					-- Adicionar ao vetor utilizando o histórico como chave
					vr_tab_craphis(rw_craphis.cdhistor).inhistor := rw_craphis.inhistor;
					vr_tab_craphis(rw_craphis.cdhistor).indoipmf := rw_craphis.indoipmf;
				END LOOP;

				-- Leitura do indicador de uso da tabela de taxa de juros
				vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
																								 ,pr_nmsistem => 'CRED'
																								 ,pr_tptabela => 'USUARI'
																								 ,pr_cdempres => 11
																								 ,pr_cdacesso => 'TAXATABELA'
																								 ,pr_tpregist => 0);
				-- Se encontrar
				IF vr_dstextab IS NOT NULL THEN
					-- Se a primeira posição do campo
					-- dstextab for diferente de zero
					IF SUBSTR(vr_dstextab,1,1) != '0' THEN
						-- É porque existe tabela parametrizada
						vr_inusatab := TRUE;
					ELSE
						-- Não existe
						vr_inusatab := FALSE;
					END IF;
				ELSE
					-- Não existe
					vr_inusatab := FALSE;
				END IF;

				-- Valor minimo para debito dos atrasos das prestacoes
				vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
																								 ,pr_nmsistem => 'CRED'
																								 ,pr_tptabela => 'GENERI'
																								 ,pr_cdempres => 0
																								 ,pr_cdacesso => 'VLMINDEBTO'
																								 ,pr_tpregist => 0);
				-- Se houver valor
				IF vr_dstextab IS NOT NULL THEN
					-- Converter o valor do parâmetro para number
					vr_tab_vlmindeb := nvl(gene0002.fn_char_para_number(vr_dstextab),0);
				ELSE
					-- Considerar o valor mínimo como zero
					vr_tab_vlmindeb := 0;
				END IF;

        -- Criar bloco para tratar desvio de fluxo (next record)
        BEGIN
          -- Trava para nao cobrar as parcelas desta conta e contrato pelo motivo de uma acao judicial
          IF pr_cdcooper = 1 AND rw_crapepr.nrdconta = 3044831 AND rw_crapepr.nrctremp = 146922 THEN
            RAISE vr_exc_null;
          END IF;

          -- Se não houver cadastro da linha de crédito do empréstimo
          IF NOT vr_tab_craplcr.EXISTS(rw_crapepr.cdlcremp) THEN
            -- Gerar critica 363
            vr_cdcritic := 363;
            vr_dscritic := gene0001.fn_busca_critica(363) || ' LCR: ' || to_char(rw_crapepr.cdlcremp,'fm9990');
            RAISE vr_exc_undo;
          END IF;

          -- Se está setado para utilizarmos a tabela de juros
          IF vr_inusatab THEN
            -- Iremos buscar a tabela de juros na linha de crédito
            vr_txdjuros := vr_tab_craplcr(rw_crapepr.cdlcremp).txdiaria;
          ELSE
            -- Usar taxa cadastrada no empréstimo
            vr_txdjuros := rw_crapepr.txjuremp;
          END IF;
          -- Inicializar variaveis para o cálculo
          vr_flgrejei := FALSE;
          vr_diapagto := 0;
          vr_qtprepag := NVL(rw_crapepr.qtprepag,0);
          vr_vlprepag := 0;
          vr_vlsdeved := NVL(rw_crapepr.vlsdeved,0);
          vr_vljuracu := NVL(rw_crapepr.vljuracu,0);
          vr_vljurmes := 0;
          vr_dtultpag := rw_crapepr.dtultpag;
          -- Chamar rotina de cálculo externa
          EMPR0001.pc_leitura_lem_car(pr_cdcooper    => pr_cdcooper
                                     ,pr_cdprogra    => vr_cdprogra
                                     ,pr_nrdconta    => rw_crapepr.nrdconta
                                     ,pr_nrctremp    => rw_crapepr.nrctremp
                                     ,pr_dtcalcul    => NULL
                                     ,pr_diapagto    => vr_diapagto
                                     ,pr_txdjuros    => vr_txdjuros
                                     ,pr_qtprecal    => vr_qtprecal
                                     ,pr_qtprepag    => vr_qtprepag
                                     ,pr_vlprepag    => vr_vlprepag
                                     ,pr_vljurmes    => vr_vljurmes
                                     ,pr_vljuracu    => vr_vljuracu
                                     ,pr_vlsdeved    => vr_vlsdeved
                                     ,pr_dtultpag    => vr_dtultpag
                                     ,pr_qtmesdec    => vr_qtmesdec
                                     ,pr_vlpreapg    => vr_vlpreapg
                                     ,pr_cdcritic    => vr_cdcritic
                                     ,pr_dscritic    => vr_dscritic);
          -- Se a rotina retornou com erro
          IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
            -- Gerar exceção
            RAISE vr_exc_undo;
          END IF;
          -- Garantir que o saldo devedor não fique zerado
          IF vr_vlsdeved < 0 THEN
            vr_vlsdeved := 0;
          END IF;

          -- Inicializar variaveis para atualização do empréstimo
          vr_msdecatr := 0;
          vr_flgprepg := FALSE;
          vr_flgpgadt := FALSE;
          vr_pgtofora := FALSE;

          -- Se a parcela vence no mês corrente
          IF trunc(rw_crapdat.dtmvtolt,'mm') = trunc(rw_crapepr.dtdpagto,'mm') THEN
            -- Se ainda não foi pago
            IF rw_crapepr.dtdpagto <= rw_crapdat.dtmvtolt THEN
              -- Incrementar a quantidade de parcelas
              vr_msdecatr := rw_crapepr.qtmesdec + 1;
            ELSE
              -- Consideramos a quantidade já calculadao
              vr_msdecatr := rw_crapepr.qtmesdec;
            END IF;
          -- Se foi paga no mês corrente
          ELSIF trunc(rw_crapdat.dtmvtolt,'mm') = trunc(rw_crapepr.dtmvtolt,'mm') THEN
            -- Se for um contrato do mês
            IF to_char(rw_crapepr.dtdpagto,'mm') = to_char(rw_crapdat.dtmvtolt,'mm') THEN
              -- Devia ter pago a primeira no mes do contrato
              vr_msdecatr := rw_crapepr.qtmesdec + 1;
            ELSE
              -- Paga a primeira somente no mes seguinte
              vr_msdecatr := rw_crapepr.qtmesdec;
            END IF;
          ELSE
            -- Se a parcela vai vencer E foi paga antes da data corrente
            IF rw_crapepr.dtdpagto < rw_crapdat.dtmvtolt AND to_char(rw_crapepr.dtdpagto,'dd') <= to_char(rw_crapdat.dtmvtolt,'dd') THEN
              -- Incrementar a quantidade de parcelas
              vr_msdecatr := rw_crapepr.qtmesdec + 1;
            ELSE
              -- Consideramos a quantidade já calculadao
              vr_msdecatr := rw_crapepr.qtmesdec;
            END IF;
          END IF;

          vr_vldescto := pr_vllanmto;
					
					-- Não permitir antecipação de parcela quando não estiver em acordo ativo
          -- Utilizar o quantidade de meses e parcelas calculadas para saber se esta em atraso
          -- Os campos da tabela podem esta desatualizados
          -- PJ298.2.2 - Pos Fixado - Migracao contratos nao pode fazer
          IF UPPER(pr_nmtelant) <> 'MIGRACAO' THEN
          IF vr_qtprecal > vr_msdecatr AND NVL(vr_flgativo,0) = 0 
					AND NOT vr_prejuzcc THEN
             vr_cdcritic := 0;
						 vr_dscritic := 'Pagamento apenas para parcelas em atraso';
						 RAISE vr_exc_undo;
          END IF;
          END IF;
					
          -- Garantir que o saldo devedor seja inferior ao desconto
          IF vr_vlsdeved < vr_vldescto THEN
            -- Considerar o saldo devedor como desconto
            vr_vldescto := vr_vlsdeved;
          END IF;
					
          -- Verificar se a conta não possui saldo
          IF NOT vr_tab_crapsld.EXISTS(rw_crapepr.nrdconta) THEN
            -- Gerar critica 10
            vr_cdcritic := 10;
            vr_dscritic := gene0001.fn_busca_critica(10) || ' Cta: ' || gene0002.fn_mask_conta(rw_crapepr.nrdconta);
            RAISE vr_exc_undo;
          END IF;

          -- Verificar se a conta não está na crapass
          IF NOT vr_tab_crapass.EXISTS(rw_crapepr.nrdconta) THEN
            -- Gerar critica 251
            vr_cdcritic := 251;
            vr_dscritic := gene0001.fn_busca_critica(251) || ' Cta: ' || gene0002.fn_mask_conta(rw_crapepr.nrdconta);
            RAISE vr_exc_undo;
          END IF;

          -- Calcular o saldo total --
          vr_vlsldtot := NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlsdblfp,0) + NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlsdbloq,0)
                       + NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlsdblpr,0) + NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlsddisp,0)
                       + NVL(vr_tab_crapass(rw_crapepr.nrdconta).vllimcre,0) - NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlipmfap,0) - NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlipmfpg,0);

          -- Calcular o saldo a cobrar --
          vr_vlcalcob := NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlsdblfp,0) + NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlsdbloq,0)
                       + NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlsdblpr,0) + NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlsddisp,0)
                       + NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlsdchsl,0) - NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlipmfap,0)
                       - NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlipmfpg,0);
                       
          -- Desprezar saldo da conta
          vr_vlsldtot := pr_vllanmto;
          vr_vlcalcob := pr_vllanmto;

          -- Se o valor a cobrar ficar negativo
          IF vr_vlcalcob < 0 THEN
            -- Descontar do total o valor absoluto a cobrar aplicando o * de CPMF
            vr_vlsldtot := vr_vlsldtot - (TRUNC((ABS(vr_vlcalcob)  * vr_txcpmfcc),2));
          END IF;

          -- Busca dos lançamentos de deposito a vista
          /*IF vr_tab_craplcm.EXISTS(rw_crapepr.nrdconta) THEN
            vr_ind_lcm := vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm.first;
            WHILE vr_ind_lcm IS NOT NULL LOOP
              -- No primeiro registro do histórico atual
              IF vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).sqatureg = 1 THEN
                -- Verificar se o histórico está cadastrado
                IF NOT vr_tab_craphis.EXISTS(vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor) THEN
                  -- Gerar critica 83 no log
                  btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                            ,pr_ind_tipo_log => 2 -- Erro tratato
                                            ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                             || vr_cdprogra || ' --> '
                                                             || to_char(vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor,'fm9900') || ' ' ||gene0001.fn_busca_critica(83) );
                  -- Limpar as variaveis de controle do cpmf
                  vr_inhistor := 0;
                  vr_indoipmf := 0;
                  vr_txdoipmf := 0;
                ELSE
                  -- Utilizaremos do cadastro do histórico
                  vr_inhistor := vr_tab_craphis(vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor).inhistor;
                  vr_indoipmf := vr_tab_craphis(vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor).indoipmf;
                  vr_txdoipmf := vr_txcpmfcc;
                  -- Se houver abono e o histórico for um dos abaixo:
                  -- CDHISTOR DSHISTOR
                  -- -------- --------------------------------------------------
                  -- 114 DB.APLIC.RDCA
                  -- 127 DB. COTAS
                  -- 160 DB.POUP.PROGR
                  -- 177 DB.APL.RDCA60
                  IF vr_indabono = 0 AND vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor IN(0114,0127,0160,0177) THEN
                    -- Indicar que não há CPMF
                    vr_indoipmf := 1;
                    vr_txdoipmf := 0;
                  END IF;
                END IF;
              END IF;

              -- Se houver abono e a data for inferior a data lançada e o histório estiver na lista abaixo:
              -- CDHISTOR DSHISTOR
              -- -------- --------------------------------------------------
              -- 186 CR.ANTEC.RDCA
              -- 187 CR.ANT.RDCA60
              -- 498 CR.ANTEC.RDCA
              -- 500 CR.ANT.RDCA60
              IF vr_indabono = 0 AND vr_dtiniabo <= vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).dtrefere AND
                 vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor IN(0114,0127,0160,0177) THEN
                -- Descontar do saldo total este lançamento aplicando a taxa de CPMF cadastrada
                vr_vlsldtot := vr_vlsldtot - (TRUNC((vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).vllanmto * vr_txcpmfcc),2));
              END IF;

              -- Se tivermos um lançamento de crédito da data atual --
              IF vr_tab_craphis(vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor).inhistor IN (1,3,4,5) AND rw_crapdat.dtmvtolt = vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).dtmvtolt THEN
                -- Tratamento de CPMF --
                IF vr_indoipmf = 2 THEN
                  -- Acumular ao saldo o valor do lançamento aplicando a taxa de CPMF +1 do teste de histórico acima
                  vr_vlsldtot := vr_vlsldtot + (TRUNC((vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).vllanmto * (1+vr_txdoipmf)),2));
                ELSE
                  -- Apenas acumular o lançamento
                  vr_vlsldtot := vr_vlsldtot + vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).vllanmto;
                END IF;
              -- Senão, se tivermos um lançamento de débito --
              ELSIF vr_tab_craphis(vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor).inhistor IN(11,13,14,15) THEN
                -- Tratamento de CPMF --
                IF vr_indoipmf = 2 THEN
                  -- Diminuir do saldo o valor do lançamento aplicando a taxa de CPMF +1 do teste de histórico acima
                  vr_vlsldtot := vr_vlsldtot - (TRUNC((vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).vllanmto * (1+vr_txdoipmf)),2));
                ELSE
                  -- Apenas diminuir o lançamento
                  vr_vlsldtot := vr_vlsldtot - vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).vllanmto;
                END IF;
              END IF;

              vr_ind_lcm := vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm.next(vr_ind_lcm);
            END LOOP; -- Fim leitura craplcm
          END IF;*/

          -- Armazenar o valor original de desconto
          vr_vlpremes := vr_vldescto;

          -- Se o valor de desconto aplicando a CPMF for maior que o saldo total
          IF TRUNC((vr_vldescto * (1 + vr_txcpmfcc)),2) > vr_vlsldtot THEN
            -- Se houver saldo total
            IF vr_vlsldtot > 0 THEN
              -- Aplicar a taxa de CPMF
              vr_vldescto := TRUNC(vr_vlsldtot * vr_txrdcpmf,2);
            ELSE
              -- Utilizaremos zero
              vr_vldescto := 0;
            END IF;
            -- Se o valor original do desconto for superior ao desconto acima ajustado
            IF vr_vlpremes > vr_vldescto THEN
              -- Indicar que há rejeição
              vr_flgrejei := TRUE;
            END IF;
          END IF;

          -- Se a prestação for superior ou igual ao mínimo de débito e
          -- o valor de desconto inferior ao mínimo de débito e o
          -- saldo devedor superior ao valor de desconto
          IF rw_crapepr.vlpreemp >= vr_tab_vlmindeb AND vr_vldescto < vr_tab_vlmindeb AND vr_vlsdeved > vr_vldescto THEN
            -- Zerar o desconto
            vr_vldescto := 0;
          END IF;

          -- Se o registro ainda não estiver rejeitado
          IF NOT vr_flgrejei THEN
            -- Se o valor de desconto estiver zerado, não houver pagamento por fora e
            -- o valor original de desconto for superior ao desconto atual
            IF vr_vldescto = 0 AND NOT vr_pgtofora AND vr_vlpremes > vr_vldescto THEN
              -- Indicar que já rejeição
              vr_flgrejei := TRUE;
            END IF;
          END IF;

          -- Se estamos em outro mês e temos adiantamento
          IF vr_flgpgadt AND TRUNC(rw_crapepr.dtdpagto,'mm') <> TRUNC(rw_crapdat.dtmvtolt,'mm') THEN
            -- Adicionamos 1 mês a data de pagamento do empréstimo
            rw_crapepr.dtdpagto := gene0005.fn_calc_data(pr_dtmvtolt => rw_crapepr.dtdpagto --> Data do pagamento anterior
                                                        ,pr_qtmesano => 1                   --> +1 mês
                                                        ,pr_tpmesano => 'M'
                                                        ,pr_des_erro => vr_dscritic);
            -- Parar se encontrar erro
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_undo;
            END IF;
          END IF;

          -- Quanto não houver desconto, a data do pagamento for superior a de movimento e estivermos no mesmo mês
          IF vr_vldescto = 0 AND rw_crapepr.dtdpagto > rw_crapdat.dtmvtolt
          AND TRUNC(rw_crapepr.dtdpagto,'mm') = TRUNC(rw_crapdat.dtmvtolt,'mm') THEN
            --atualizar a crapepr pois partirá pro proximo
            BEGIN
              UPDATE crapepr
                 SET dtdpagto = rw_crapepr.dtdpagto
               WHERE rowid = rw_crapepr.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar o emprestimo (CRAPEPR).'
                            || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                            || '. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;
            END;
            -- Processar o próximo empréstimo
            RAISE vr_exc_null;
          END IF;

          -- Se houver desconto E (tipo de empréstimo não for consignado Ou se for pagamento deve ser > dia 10)
          IF vr_vldescto > 0 AND (rw_crapepr.tpdescto = 1 OR to_char(rw_crapdat.dtmvtolt,'dd') > 10) THEN
            -- Testar se já retornado o registro de capas de lote para o 8457
            IF rw_craplot_8457.rowid IS NULL THEN
              -- Chamar rotina para buscá-lo, e se não encontrar, irá criá-lo
              -- PJ298.2.2 - Pos Fixado - Migracao contratos nao pode fazer
              IF UPPER(pr_nmtelant) <> 'MIGRACAO' THEN

              IF NOT vr_prejuzcc THEN
              pc_cria_craplot(pr_dtmvtolt   => rw_crapdat.dtmvtolt
                             ,pr_nrdolote   => 8457
                             ,pr_tplotmov   => 1
                             ,pr_rw_craplot => rw_craplot_8457
                             ,pr_dscritic   => vr_dscritic);
              -- Se houve retorno de erro
              IF vr_dscritic IS NOT NULL THEN
                -- Sair do processo
                RAISE vr_exc_undo;
              END IF;
            END IF;
              END IF; -- PJ298.2.2 migracao
            END IF;

		  -- PJ298.2.2 - Pos Fixado - Migracao contratos nao pode fazer
      IF UPPER(pr_nmtelant) <> 'MIGRACAO' THEN
		  IF NOT vr_prejuzcc THEN

            vr_nrdoclcm := rw_craplot_8457.nrseqdig + 1;
            
            -- PJ450 - Insere Lancamento
            LANC0001.pc_gerar_lancamento_conta(pr_cdcooper => pr_cdcooper
                                              ,pr_dtmvtolt => rw_craplot_8457.dtmvtolt
                                              ,pr_cdagenci => rw_craplot_8457.cdagenci
                                              ,pr_cdbccxlt => rw_craplot_8457.cdbccxlt
                                              ,pr_nrdolote => rw_craplot_8457.nrdolote
                                              ,pr_nrdconta => rw_crapepr.nrdconta
                                              ,pr_nrdctabb => rw_crapepr.nrdconta
                                              ,pr_nrdctitg => to_char(rw_crapepr.nrdconta,'fm00000000')
                                              ,pr_nrdocmto => vr_nrdoclcm
                                              ,pr_cdpesqbb => to_char(rw_crapepr.nrctremp)
                                              ,pr_cdhistor => 108 --  Prest Empr.
                                              ,pr_nrseqdig => vr_nrdoclcm
                                              ,pr_vllanmto => vr_vldescto
                                              ,pr_inprolot => 0                    -- Indica se a procedure deve processar (incluir/atualizar) o LOTE (CRAPLOT)
                                              ,pr_tplotmov => 0                    -- Tipo Movimento
                                              ,pr_cdcritic => vr_cdcritic          -- Codigo Erro
                                              ,pr_dscritic => vr_dscritic          -- Descricao Erro
                                              ,pr_incrineg => vr_incrineg          -- Indicador de crítica de negócio
                                              ,pr_tab_retorno => vr_tab_retorno    -- Registro com dados do retorno
                                              );

            -- Conforme tipo de erro realiza acao diferenciada
            IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
              IF vr_incrineg = 0 THEN -- Erro de sistema/BD
                vr_dscritic := 'Erro ao criar lancamento de sobras para a conta corrente (CRAPLCM) '
                            || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                            || '. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;
            ELSE --vr_incrineg = 1 -- Erro de Negócio
                RAISE vr_exc_undo;
              END If;
            END IF;

            
            -- Atualizar Pl table de conta corrente
            IF vr_tab_craplcm.exists(rw_crapepr.nrdconta) THEN
              vr_ind_lcm := vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm.count + 1;
            ELSE
              vr_ind_lcm := 1;
            END IF;
            vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).dtrefere := NULL;
            vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).vllanmto := vr_vldescto;
            vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).dtmvtolt := rw_craplot_8457.dtmvtolt;
            vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor := 108; --> Prest Empr.
            vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).sqatureg := 1;


            -- Efetuar criação do avisos de débito em conta
            BEGIN
              INSERT INTO crapavs(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdempres
                                 ,cdhistor
                                 ,cdsecext
                                 ,dtdebito
                                 ,dtrefere
                                 ,insitavs
                                 ,nrdconta
                                 ,nrdocmto
                                 ,nrseqdig
                                 ,tpdaviso
                                 ,vldebito
                                 ,vlestdif
                                 ,vllanmto
                                 ,flgproce)
                           VALUES(pr_cdcooper                                  -- cdcooper
                                 ,rw_craplot_8457.dtmvtolt                     -- dtmvtolt
                                 ,vr_tab_crapass(rw_crapepr.nrdconta).cdagenci -- cdagenci
                                 ,0                                            -- cdempres
                                 ,108 -- Mesmo do lançamento                   -- cdhistor
                                 ,vr_tab_crapass(rw_crapepr.nrdconta).cdsecext -- cdsecext
                                 ,rw_craplot_8457.dtmvtolt                     -- dtdebito
                                 ,rw_craplot_8457.dtmvtolt                     -- dtrefere
                                 ,0                                            -- insitavs
                                 ,rw_crapepr.nrdconta                          -- nrdconta
                                 ,vr_nrdoclcm                                  -- nrdocmto
                                 ,vr_nrdoclcm                                  -- nrseqdig
                                 ,2                                            -- tpdaviso
                                 ,0                                            -- vldebito
                                 ,0                                            -- vlestdif
                                 ,vr_vldescto                                  -- vllanmto
                                 ,0); -- false                                 -- flgproce
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao criar aviso de debito em conta corrente (CRAPAVS) '
                            || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                            || '. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;
            END;

            -- Atualizar as informações no lote utilizado
            BEGIN
              UPDATE craplot
                 SET vlinfodb = vlinfodb + vr_vldescto
                    ,vlcompdb = vlcompdb + vr_vldescto
                    ,qtinfoln = qtinfoln + 1
                    ,qtcompln = qtcompln + 1
                    ,nrseqdig = nrseqdig + 1
               WHERE rowid = rw_craplot_8457.rowid
               RETURNING nrseqdig INTO rw_craplot_8457.nrseqdig; -- Atualizamos a sequencia no rowtype
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar capas de lotes (craplot), lote: '||rw_craplot_8457.nrdolote||'. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;
            END;
         END IF; -- Lançamento conta corrente
				 END IF; -- PJ298.2.2 - Migracao
				 
				 --> Armazenar valores
         pr_vltotpag := nvl(pr_vltotpag,0) + nvl(vr_vldescto,0);

            -- Testar se já retornado o registro de capas de lote para o 8453
            IF rw_craplot_8453.rowid IS NULL THEN
              -- Chamar rotina para buscá-lo, e se não encontrar, irá criálo
              pc_cria_craplot(pr_dtmvtolt   => rw_crapdat.dtmvtolt
                             ,pr_nrdolote   => 8453
                             ,pr_tplotmov   => 5
                             ,pr_rw_craplot => rw_craplot_8453
                             ,pr_dscritic   => vr_dscritic);
              -- Se houve retorno de erro
              IF vr_dscritic IS NOT NULL THEN
                -- Sair do processo
                RAISE vr_exc_undo;
              END IF;
            END IF;

            -- Inicializar número auxiliar de documento com o empréstimo
            vr_nrdocmto := nvl(vr_nrdoclcm, rw_crapepr.nrctremp); -- rw_crapepr.nrctremp; -- Renato Darosci - 19/10/2016

            -- Verificar se já existe outro lançamento para este lote
            vr_qtd_lem_nrdocmto := 0;
            OPEN cr_craplem_nrdocmto(pr_dtmvtolt => rw_craplot_8453.dtmvtolt
                                    ,pr_nrdolote => rw_craplot_8453.nrdolote
                                    ,pr_nrdconta => rw_crapepr.nrdconta
                                    ,pr_nrdocmto => vr_nrdocmto);
            FETCH cr_craplem_nrdocmto
             INTO vr_qtd_lem_nrdocmto;
            CLOSE cr_craplem_nrdocmto;
            -- Se encontrou somente um registro (FIND)
            IF vr_qtd_lem_nrdocmto = 1 THEN
              -- Concatenar o número 9 + o contrato do empréstimo já montado
              vr_nrdocmto := '9' || vr_nrdocmto;
            END IF;

            -- Cria lancamento de juros para o emprestimo
            BEGIN
              INSERT INTO craplem(cdcooper
                                 ,dtmvtolt
                                 ,dtpagemp
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,nrdconta
                                 ,nrctremp
                                 ,nrdocmto
                                 ,cdhistor
                                 ,nrseqdig
                                 ,vllanmto
                                 ,txjurepr
                                 ,vlpreemp)
                           VALUES(pr_cdcooper
                                 ,rw_craplot_8453.dtmvtolt
                                 ,rw_craplot_8453.dtmvtolt
                                 ,rw_craplot_8453.cdagenci
                                 ,rw_craplot_8453.cdbccxlt
                                 ,rw_craplot_8453.nrdolote
                                 ,rw_crapepr.nrdconta
                                 ,rw_crapepr.nrctremp
                                 ,vr_nrdocmto
                                 ,95 --> Pg Empr CC
                                 ,rw_craplot_8453.nrseqdig + 1
                                 ,vr_vldescto
                                 ,vr_txdjuros
                                 ,rw_crapepr.vlpreemp);
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao criar lancamento de juros para o emprestimo (CRAPLEM) '
                            || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                            || '. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;
            END;

            -- Atualizar as informações no lote utilizado
            BEGIN
              UPDATE craplot
                 SET vlinfocr = vlinfocr + vr_vldescto
                    ,vlcompcr = vlinfocr + vr_vldescto
                    ,qtinfoln = qtinfoln + 1
                    ,qtcompln = qtcompln + 1
                    ,nrseqdig = nrseqdig + 1
               WHERE rowid = rw_craplot_8453.rowid
               RETURNING nrseqdig INTO rw_craplot_8453.nrseqdig; -- Atualizamos a sequencia no rowtype
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar capas de lotes (craplot), lote: '||rw_craplot_8453.nrdolote||'. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;
            END;

            -- Atualizar informações no rowtype do empréstimo
            -- para atualização única da tabela posteriormente
            rw_crapepr.dtultpag := rw_crapdat.dtmvtolt;
            rw_crapepr.txjuremp := vr_txdjuros;

            -- Caso pagamento seja menor que data atual e NAO esteja ativo
            IF rw_crapepr.dtdpagto < rw_crapdat.dtmvtolt AND 
               NVL(vr_flgativo,0) = 0                    THEN

              -- Procedure para lancar Multa e Juros de Mora para o TR
              EMPR0009.pc_efetiva_pag_atraso_tr(pr_cdcooper => pr_cdcooper
                                               ,pr_cdagenci => vr_tab_crapass(rw_crapepr.nrdconta).cdagenci
                                               ,pr_nrdcaixa => 0
                                               ,pr_cdoperad => pr_cdoperad
                                               ,pr_nmdatela => pr_nmtelant
                                               ,pr_idorigem => pr_idorigem
                                               ,pr_nrdconta => rw_crapepr.nrdconta
                                               ,pr_nrctremp => rw_crapepr.nrctremp
                                               ,pr_vlpreapg => vr_vlpreapg
                                               ,pr_qtmesdec => vr_qtmesdec
                                               ,pr_qtprecal => vr_qtprecal
                                               ,pr_vlpagpar => vr_vldescto
                                               ,pr_cdhismul => vr_cdhismul
                                               ,pr_vldmulta => vr_vldmulta
                                               ,pr_cdhismor => vr_cdhismor
                                               ,pr_vljumora => vr_vljumora
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);
              -- Se houve retorno de erro
              IF vr_dscritic IS NOT NULL THEN
                -- Envio centralizado de log de erro
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                          
                                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                           || pr_nmtelant || ' --> '
                                                           || 'Erro ao debitar multa e juros de mora. '
                                                           || 'Conta: ' || rw_crapepr.nrdconta || ', '
                                                           || 'Contrato: ' || rw_crapepr.nrctremp || '. '
                                                           || 'Critica: ' || vr_dscritic );
                -- Reseta variaveis
                vr_cdcritic := 0;
                vr_dscritic := NULL;
              END IF;
              
              --> Armazenar valores 
              pr_vltotpag := nvl(pr_vltotpag,0) + nvl(vr_vldmulta,0) + nvl(vr_vljumora,0);

            END IF;

          ELSE
            -- Zerar o valor de desconto
            vr_vldescto := 0;
          END IF;

          -- Se o saldo devedor for menor ou igual ao desconto da parcela
          IF vr_vlsdeved <= vr_vldescto THEN
            -- Indicar que o emprestimo está liquidado
            rw_crapepr.inliquid := 1;
            -- Desativar o Rating associado a esta operaçao
            rati0001.pc_desativa_rating(pr_cdcooper   => pr_cdcooper         --> Código da Cooperativa
                                       ,pr_cdagenci   => 0                   --> Código da agência
                                       ,pr_nrdcaixa   => 0                   --> Número do caixa
                                       ,pr_cdoperad   => pr_cdoperad         --> Código do operador
                                       ,pr_rw_crapdat => rw_crapdat          --> Vetor com dados de parâmetro (CRAPDAT)
                                       ,pr_nrdconta   => rw_crapepr.nrdconta --> Conta do associado
                                       ,pr_tpctrrat   => 90                  --> Tipo do Rating (90-Empréstimo)
                                       ,pr_nrctrrat   => rw_crapepr.nrctremp --> Número do contrato de Rating
                                       ,pr_flgefeti   => 'S'                 --> Flag para efetivação ou não do Rating
                                       ,pr_idseqttl   => 1                   --> Sequencia de titularidade da conta
                                       ,pr_idorigem   => 1                   --> Indicador da origem da chamada
                                       ,pr_inusatab   => vr_inusatab         --> Indicador de utilização da tabela de juros
                                       ,pr_nmdatela   => vr_cdprogra         --> Nome datela conectada
                                       ,pr_flgerlog   => 'N'                 --> Gerar log S/N
                                       ,pr_des_reto   => vr_des_reto         --> Retorno OK / NOK
                                       ,pr_tab_erro   => vr_tab_erro);       --> Tabela com possíves erros
														
						-- Se retorno for diferente de OK					 
            IF vr_des_reto <> 'OK' THEN
							-- Atribui críticas
							-- Se possui algum erro na tabela de erros
							IF vr_tab_erro.count() > 0 THEN
								-- Atribui críticas às variaveis
								vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
								vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
							ELSE
								vr_cdcritic := 0;
								vr_dscritic := 'Erro ao desativar o rating da operacao';
							END IF;
							-- Gera exceção
							RAISE vr_exc_undo;
						END IF;

            /** GRAVAMES **/
            GRVM0001.pc_solicita_baixa_automatica(pr_cdcooper => pr_cdcooper          -- Código da cooperativa
                                                 ,pr_nrdconta => rw_crapepr.nrdconta  -- Numero da conta do contrato
                                                 ,pr_nrctrpro => rw_crapepr.nrctremp  -- Numero do contrato
                                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt  -- Data de movimento para baixa
                                                 ,pr_des_reto => vr_des_reto          -- Retorno OK ou NOK
                                                 ,pr_tab_erro => vr_tab_erro          -- Retorno de erros em PlTable
                                                 ,pr_cdcritic => vr_cdcritic          -- Retorno de codigo de critica
                                                 ,pr_dscritic => vr_dscritic);        -- Retorno de descricao de critica

 						-- Se retorno for diferente de OK					 
            IF vr_des_reto <> 'OK' THEN
							-- Gera exceção
							RAISE vr_exc_undo;
						END IF;

          ELSE
            -- Indicar que o emprestimo não está liquidado
            rw_crapepr.inliquid := 0;
          END IF;

          -- Para registros rejeitados
          IF vr_flgrejei THEN

            -- Cria o registro de rejeitos
            BEGIN
              INSERT INTO craprej(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdconta
                                 ,nraplica
                                 ,vllanmto
                                 ,vlsdapli
                                 ,vldaviso
                                 ,cdpesqbb
                                 ,cdcritic)
                           VALUES(pr_cdcooper
                                 ,rw_crapepr.dtdpagto
                                 ,vr_tab_crapass(rw_crapepr.nrdconta).cdagenci
                                 ,171
                                 ,rw_crapepr.nrdconta
                                 ,rw_crapepr.nrctremp
                                 ,vr_vldescto
                                 ,vr_vlsdeved
                                 ,rw_crapepr.vlpreemp
                                 ,to_char(ROUND(vr_vlpremes - vr_vldescto,2),'fm0g000g000d00')
                                 ,171); --> Guardar ou a regularizar
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao criar lancamento de juros para o emprestimo (CRAPLEM) '
                            || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                            || '. Detalhes: '||sqlerrm;
                RAISE vr_exc_undo;
            END;
      
          END IF;

          -- Calcular a data de Pagamento
          pc_gera_data_pag_tr(pr_cdcooper => pr_cdcooper,
                              pr_dtmvtolt => rw_crapdat.dtmvtolt,
                              pr_nrdconta => pr_nrdconta, 
                              pr_nrctremp => pr_nrctremp, 
                              pr_vlpreemp => rw_crapepr.vlpreemp,
                              pr_dtdpagto => rw_crapepr.dtdpagto, 
                              pr_dtvencto => rw_crawepr.dtvencto, 
                              pr_cdcritic => vr_cdcritic, 
                              pr_dscritic => vr_dscritic);

          -- Verificar se houve erro 
          IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_undo;
          END IF;

          -- Finalmente após todo o processamento, é atualizada a tabela de empréstimo CRAPEPR
          BEGIN
            UPDATE crapepr
               SET dtdpagto = rw_crapepr.dtdpagto
                  ,dtultpag = rw_crapepr.dtultpag
                  ,txjuremp = rw_crapepr.txjuremp
                  ,inliquid = rw_crapepr.inliquid
             WHERE rowid = rw_crapepr.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar o emprestimo (CRAPEPR).'
                          || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                          || '. Detalhes: '||sqlerrm;
              RAISE vr_exc_undo;
          END;

        EXCEPTION
          WHEN vr_exc_null THEN
            -- Exception criada para desviar o fluxo para cá e
            -- não processar o restante das instruções após o RAISE
            NULL;
          WHEN vr_exc_undo THEN
            -- Gerar um raise para gerar o log e sair do processo
            RAISE vr_exc_erro;
        END;
      END IF; -- Fim leitura dos empréstimos
			
			EXCEPTION
				WHEN vr_exc_erro THEN
					IF TRIM(vr_dscritic) IS NULL THEN
						vr_dscritic := 'Erro ao efetuar pagamento do emprestimo';
					END IF;
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
					
				WHEN OTHERS THEN					
					pr_cdcritic := 0;
					pr_dscritic := 'Erro ao atualizar o empréstimo (CRAPEPR).'
											|| '- Conta:'||pr_nrdconta || ' CtrEmp:'||pr_nrctremp
											|| '. Detalhes: '||sqlerrm;
			END;


  END pc_gera_lancamento_epr_tr;

  PROCEDURE pc_buscar_boletos_contratos (pr_cdcooper IN crapcop.cdcooper%TYPE                  --> Cooperativa
																				,pr_cdagenci IN crapass.cdagenci%TYPE DEFAULT 0        --> PA
																				,pr_nrctremp IN tbrecup_cobranca.nrctremp%TYPE DEFAULT 0 --> Nr. do Contrato
																				,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT 0        --> Nr. da Conta
																				,pr_dtbaixai IN DATE DEFAULT NULL                      --> Data de baixa inicial
																				,pr_dtbaixaf IN DATE DEFAULT NULL                      --> Data de baixa final
																				,pr_dtemissi IN DATE DEFAULT NULL                      --> Data de emissão inicial
																				,pr_dtemissf IN DATE DEFAULT NULL                      --> Data de emissão final
																				,pr_dtvencti IN DATE DEFAULT NULL                      --> Data de vencimento inicial
																				,pr_dtvenctf IN DATE DEFAULT NULL                      --> Data de vencimento final
																				,pr_dtpagtoi IN DATE DEFAULT NULL                      --> Data de pagamento inicial
																				,pr_dtpagtof IN DATE DEFAULT NULL                      --> Data de pagamento final
																				,pr_cdoperad IN crapope.cdoperad%TYPE                  --> Cód. Operador
																				,pr_cdcritic OUT crapcri.cdcritic%TYPE                 --> Cód. da crítica
																				,pr_dscritic OUT crapcri.dscritic%TYPE                 --> Descrição da crítica
																				,pr_tab_cde  OUT typ_tab_cde) IS		                   --> Pl/Table com os dados de cobrança de emprestimos
		BEGIN
	 	  /* .............................................................................

      Programa: pc_buscar_boletos_contratos
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Lucas Reinert
      Data    : Agosto/15.                    Ultima atualizacao: 03/03/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina referente a busca dos boletos de contratos

      Observacao: -----

      Alteracoes: 03/03/2017 - Busca do campo tbrecup_cobranca.dsparcelas. (P210.2 - Jaison/Daniel)

    ..............................................................................*/
			DECLARE
			----------------------------- VARIAVEIS ---------------------------------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

			vr_ind_cde INTEGER := 0;

      vr_tab_cob cobr0005.typ_tab_cob;

			---------------------------- CURSORES -----------------------------------
			CURSOR cr_crapcob
      IS SELECT cde.cdcooper cdcooper
			         ,ass.cdagenci cdagenci
							 ,cde.nrctremp nrctremp
							 ,cde.nrdconta nrdconta
							 ,cde.nrcnvcob nrcnvcob
							 ,cde.nrboleto nrdocmto
							 ,cob.dtmvtolt dtmvtolt
							 ,cob.dtvencto dtvencto
							 ,cob.vltitulo vlboleto
							 ,cob.dtdpagto dtdpagto
							 ,cob.vldpagto vldpagto
               ,cob.rowid    rowidcob
							 ,decode(cde.tpenvio,1,'EMAIL',2,'SMS',3,'IMPRESSO') dstipenv
							 ,cde.cdoperad_envio cdopeenv
							 ,cde.dhenvio dtdenvio
							 ,decode(cde.tpenvio,0,'PENDENTE',1,cde.dsemail,2,to_char(nrddd_sms) || to_char(nrtel_sms),3,'IMPRESSO') dsdenvio
               ,decode(cob.incobran,0,'ABERTO',3,'BAIXADO',5,'PAGO') dssituac
			         ,cob.dtdbaixa dtdbaixa
							 ,cde.dsemail  dsdemail
							 ,('(' || to_char(cde.nrddd_sms,'000') || ')' || to_char(cde.nrtel_sms, '9999g9999','nls_numeric_characters=.-')) dsdtelef
							 ,cde.nmcontato nmpescto
							 ,cde.nrdconta_cob nrctacob
               ,cde.dsparcelas
               ,cob.incobran
           FROM crapcob cob, tbrecup_cobranca cde, crapass ass
          WHERE cde.cdcooper = pr_cdcooper                            --> Cód. cooperativa
					  AND (pr_cdagenci = 0     OR ass.cdagenci =  pr_cdagenci)  --> PA
						AND (pr_nrdconta = 0     OR cde.nrdconta =  pr_nrdconta)  --> Nr. da Conta
						AND (pr_nrctremp = 0     OR cde.nrctremp =  pr_nrctremp)  --> Nr. Contrato
            AND ( cob.dtdbaixa >= NVL(pr_dtbaixai, to_date('01/01/0001','dd/mm/yyyy')) OR ( cob.dtdbaixa IS NULL AND pr_dtbaixai IS NULL))
            AND ( cob.dtdbaixa <= NVL(pr_dtbaixaf, to_date('31/12/2099','dd/mm/yyyy')) OR ( cob.dtdbaixa IS NULL AND pr_dtbaixaf IS NULL))
            AND ( cob.dtmvtolt >= NVL(pr_dtemissi, to_date('01/01/0001','dd/mm/yyyy')) OR ( cob.dtmvtolt IS NULL AND pr_dtemissi IS NULL))
            AND ( cob.dtmvtolt <= NVL(pr_dtemissf, to_date('31/12/2099','dd/mm/yyyy')) OR ( cob.dtmvtolt IS NULL AND pr_dtemissf IS NULL))
            AND ( cob.dtvencto >= NVL(pr_dtvencti, to_date('01/01/0001','dd/mm/yyyy')) OR ( cob.dtvencto IS NULL AND pr_dtvencti IS NULL))
            AND ( cob.dtvencto <= NVL(pr_dtvenctf, to_date('31/12/2099','dd/mm/yyyy')) OR ( cob.dtvencto IS NULL AND pr_dtvenctf IS NULL))
            AND ( cob.dtdpagto >= NVL(pr_dtpagtoi, to_date('01/01/0001','dd/mm/yyyy')) OR ( cob.dtdpagto IS NULL AND pr_dtpagtoi IS NULL))
            AND ( cob.dtdpagto <= NVL(pr_dtpagtof, to_date('31/12/2099','dd/mm/yyyy')) OR ( cob.dtdpagto IS NULL AND pr_dtpagtof IS NULL))
					  AND cob.cdcooper = cde.cdcooper
            AND cob.nrdconta = cde.nrdconta_cob
            AND cob.nrcnvcob = cde.nrcnvcob
            AND cob.nrdocmto = cde.nrboleto
            AND ass.cdcooper = cde.cdcooper
            AND ass.nrdconta = cde.nrdconta
				  ORDER BY cde.nrdconta,
					         cde.nrctremp;
      rw_crapcob cr_crapcob%ROWTYPE;

			BEGIN

        ---------------------------------- VALIDACOES INICIAIS --------------------------

			  -- Gera exceção se informar data de inicio e não informar data final e vice-versa
				IF pr_dtbaixai IS NOT NULL AND pr_dtbaixaf IS NULL OR
					 pr_dtbaixai IS NULL AND pr_dtbaixaf IS NOT NULL THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Deve ser informado data De e Ate do Campo Data Baixa.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
			  END IF;

			  -- Gera exceção se informar data de inicio e não informar data final e vice-versa
				IF pr_dtemissi IS NOT NULL AND pr_dtemissf IS NULL OR
					 pr_dtemissi IS NULL AND pr_dtemissf IS NOT NULL THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Deve ser informado data De e Ate do Campo Data Emissao.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
			  END IF;

			  -- Gera exceção se informar data de inicio e não informar data final e vice-versa
				IF pr_dtvencti IS NOT NULL AND pr_dtvenctf IS NULL OR
					 pr_dtvencti IS NULL AND pr_dtvenctf IS NOT NULL THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Deve ser informado data De e Ate do Campo Data Vencimento.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
			  END IF;

			  -- Gera exceção se informar data de inicio e não informar data final e vice-versa
				IF pr_dtpagtoi IS NOT NULL AND pr_dtpagtof IS NULL OR
					 pr_dtpagtoi IS NULL AND pr_dtpagtof IS NOT NULL THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Deve ser informado data De e Ate do Campo Data Pagto.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
			  END IF;

				-- Gera exceção se a data inicial informada for maior que a final
			  IF pr_dtbaixai > pr_dtbaixaf THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Baixa inicial deve ser menor ou igual a final.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;

				-- Gera exceção se a data inicial informada for maior que a final
		    IF pr_dtemissi > pr_dtemissf THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Emissao inicial deve ser menor ou igual a final.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;

				-- Gera exceção se a data inicial informada for maior que a final
				IF pr_dtvencti > pr_dtvenctf THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Vencimento inicial deve ser menor ou igual a final.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;

				-- Gera exceção se a data inicial informada for maior que a final
 				IF pr_dtpagtoi > pr_dtpagtof THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Pagto inicial deve ser menor ou igual a final.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;

				-- Gera exceção se a data final ultrapassar 30 dias da data inicial
			  IF (pr_dtbaixaf - pr_dtbaixai) > 30 THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Baixa final nao deve ultrapassar 30 dias da data inicial.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;

				-- Gera exceção se a data final ultrapassar 30 dias da data inicial
			  IF (pr_dtemissf - pr_dtemissi) > 30 THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Emissao final nao deve ultrapassar 30 dias da data inicial.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;

			  -- Gera exceção se a data final ultrapassar 30 dias da data inicial
			  IF (pr_dtvenctf - pr_dtvencti) > 30 THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Vencimento final nao deve ultrapassar 30 dias da data inicial.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;

			  -- Gera exceção se a data final ultrapassar 30 dias da data inicial
			  IF (pr_dtpagtof - pr_dtpagtoi) > 30 THEN
					 -- Monta Crítica
				   vr_cdcritic := 0;
					 vr_dscritic := 'Data Pagto final nao deve ultrapassar 30 dias da data inicial.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;

				IF (pr_cdagenci > 0) AND
					 (pr_dtbaixai IS NULL AND
					  pr_dtemissi IS NULL AND
					  pr_dtvencti IS NULL AND
						pr_dtpagtoi IS NULL) THEN
					-- Monta Crítica
				   vr_cdcritic := 0;
					 vr_dscritic := 'Ao informar o PA, deve ser informado alguma data.';
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;

				-- Abre cursor para atribuir os registros encontrados na PL/Table
				FOR rw_crapcob IN cr_crapcob LOOP
 				  -- Incrementa contador para utilizar como indice da PL/Table
			    vr_ind_cde := vr_ind_cde + 1;

				  pr_tab_cde(vr_ind_cde).cdcooper := rw_crapcob.cdcooper;
					pr_tab_cde(vr_ind_cde).cdagenci := rw_crapcob.cdagenci;
					pr_tab_cde(vr_ind_cde).nrctremp := rw_crapcob.nrctremp;
					pr_tab_cde(vr_ind_cde).nrdconta := rw_crapcob.nrdconta;
					pr_tab_cde(vr_ind_cde).nrcnvcob := rw_crapcob.nrcnvcob;
					pr_tab_cde(vr_ind_cde).nrdocmto := rw_crapcob.nrdocmto;
					pr_tab_cde(vr_ind_cde).dtmvtolt := rw_crapcob.dtmvtolt;
					pr_tab_cde(vr_ind_cde).dtvencto := rw_crapcob.dtvencto;
					pr_tab_cde(vr_ind_cde).vlboleto := rw_crapcob.vlboleto;
					pr_tab_cde(vr_ind_cde).dstipenv := rw_crapcob.dstipenv;
					pr_tab_cde(vr_ind_cde).cdopeenv := rw_crapcob.cdopeenv;
					pr_tab_cde(vr_ind_cde).dtdenvio := rw_crapcob.dtdenvio;
					pr_tab_cde(vr_ind_cde).dsdenvio := rw_crapcob.dsdenvio;
					pr_tab_cde(vr_ind_cde).dssituac := rw_crapcob.dssituac;
					pr_tab_cde(vr_ind_cde).dtdbaixa := rw_crapcob.dtdbaixa;
					pr_tab_cde(vr_ind_cde).dsdemail := rw_crapcob.dsdemail;
					pr_tab_cde(vr_ind_cde).dsdtelef := rw_crapcob.dsdtelef;
					pr_tab_cde(vr_ind_cde).nmpescto := rw_crapcob.nmpescto;
					pr_tab_cde(vr_ind_cde).nrctacob := rw_crapcob.nrctacob;
          pr_tab_cde(vr_ind_cde).dtdpagto := rw_crapcob.dtdpagto;
          pr_tab_cde(vr_ind_cde).vldpagto := rw_crapcob.vldpagto;
          pr_tab_cde(vr_ind_cde).dsparcel := rw_crapcob.dsparcelas;
          pr_tab_cde(vr_ind_cde).incobran := rw_crapcob.incobran;


          cobr0005.pc_buscar_titulo_cobranca(pr_cdcooper => pr_cdcooper
--                                            ,pr_rowidcob => rw_crapcob.rowidcob
                                            ,pr_nrdconta => rw_crapcob.nrctacob
                                            ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                                            ,pr_nrdocmto => rw_crapcob.nrdocmto
                                            ,pr_cdoperad => pr_cdoperad
                                            ,pr_nriniseq => 1
                                            ,pr_nrregist => 1
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic
                                            ,pr_tab_cob  => vr_tab_cob);

          IF pr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_saida;
          END IF;

          IF vr_tab_cob.EXISTS(1) IS NOT NULL THEN
             pr_tab_cde(vr_ind_cde).lindigit := vr_tab_cob(1).lindigit;
          END IF;

				END LOOP;

			EXCEPTION
        WHEN vr_exc_saida THEN
          -- Se possui código de crítica e não foi informado a descrição
          IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
             -- Busca descrição da crítica
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;

          -- Atribui exceção para os parametros de crítica
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;

        WHEN OTHERS THEN
          -- Atribui exceção para os parametros de crítica
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := 'Erro nao tratado na EMPR0007.pc_buscar_boletos_contratos: ' || SQLERRM;

			END;
	END pc_buscar_boletos_contratos;

  PROCEDURE pc_enviar_boleto(pr_cdcooper IN tbrecup_cobranca.cdcooper%TYPE              --> Cooperativa
		                        ,pr_nrdconta IN tbrecup_cobranca.nrdconta%TYPE              --> Nr. da Conta
														,pr_nrctremp IN tbrecup_cobranca.nrctremp%TYPE              --> Nr. Contrato
														,pr_nrctacob IN tbrecup_cobranca.nrdconta_cob%TYPE          --> Nr. Conta Cobrança
														,pr_nrcnvcob IN tbrecup_cobranca.nrcnvcob%TYPE              --> Nr. Convenio Cobrança
														,pr_nrdocmto IN tbrecup_cobranca.nrboleto%TYPE              --> Nr. Documento
														,pr_cdoperad IN tbrecup_cobranca.cdoperad_envio%TYPE        --> Cód. Operador
														,pr_nmcontat IN tbrecup_cobranca.nmcontato%TYPE             --> Nome Contato
														,pr_tpdenvio IN tbrecup_cobranca.tpenvio%TYPE               --> Tipo de Envio (1 = EMAIL, 2 = SMS, 3 = IMPRESSAO)
														,pr_nmdatela IN VARCHAR2                                  --> Nome da tela
														,pr_idorigem IN INTEGER                                   --> ID Origem
														,pr_dsdemail IN tbrecup_cobranca.dsemail%TYPE DEFAULT NULL  --> Email
														,pr_indretor IN tbrecup_cobranca.indretorno%TYPE DEFAULT 0  --> Indicador de retorno
														,pr_nrdddsms IN tbrecup_cobranca.nrddd_sms%TYPE DEFAULT 0   --> DDD
														,pr_nrtelsms IN tbrecup_cobranca.nrtel_sms%TYPE DEFAULT 0   --> Telefone
														,pr_cdcritic OUT crapcri.cdcritic%TYPE                    --> Cód. Crítica
														,pr_dscritic OUT crapcri.dscritic%TYPE) IS                --> Desc. Crítica
	BEGIN
 	  /* .............................................................................

      Programa: pc_enviar_boleto
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Lucas Reinert
      Data    : Agosto/15.                    Ultima atualizacao: 27/09/2016

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina para enviar os boletos por E-mail, SMS e Impressao

      Observacao: 

      Alteracoes: 25/11/2015 - Ajuste no registro da informacao de envio/impressao
                               dos boletos de emprestimo. (Rafael)

                  27/09/2016 - Inclusao de verificacao de contratos de acordo,
                               Prj. 302 (Jean Michel).
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;        --> Cód. Erro
      vr_dscritic VARCHAR2(1000);               --> Desc. Erro
		  vr_des_erro VARCHAR2(3);                  --> Indicador erro

		  -- Tratamento de erros
      vr_exc_update	EXCEPTION;
		  vr_exc_saida EXCEPTION;
      vr_exc_erro EXCEPTION;

			-- Variaveis locais
			vr_dstransa VARCHAR2(1000);
			vr_dsmensag VARCHAR2(1000);
			vr_nrdrowid ROWID;
			vr_dsorigem VARCHAR2(1000) := TRIM(GENE0001.vr_vet_des_origens(pr_idorigem));
			vr_nmarqpdf VARCHAR2(1000);
      vr_flgativo INTEGER := 0;

			-- PL/Table com os dados retornados da COBR0005.pc_buscar_titulo_cobranca
			vr_tab_cob cobr0005.typ_tab_cob;
      
      -- cursores
      CURSOR cr_boleto (pr_cdcooper IN crapcob.cdcooper%TYPE
                ,pr_nrdconta IN crapcob.nrdconta%TYPE
                ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                ,pr_nrdocmto IN crapcob.nrdocmto%TYPE) IS
         SELECT incobran,
                decode(incobran,0,'aberto',3,'baixado',5,'pago') dscobran
           FROM crapcob cob
          WHERE cob.cdcooper = pr_cdcooper
            AND cob.nrdconta = pr_nrdconta
            AND cob.nrcnvcob = pr_nrcnvcob
            AND cob.nrdocmto = pr_nrdocmto;
      rw_boleto cr_boleto%ROWTYPE;                       

		BEGIN
			BEGIN
        
        -- Verifica contratos de acordo
        RECP0001.pc_verifica_acordo_ativo(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_cdorigem => 3
                                         ,pr_flgativo => vr_flgativo
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          -- Gerar exceção
          RAISE vr_exc_erro;
        END IF;
            
        IF vr_flgativo = 1 THEN
          IF pr_tpdenvio = 1 THEN
            vr_dscritic := 'Envio de e-mail nao permitido, emprestimo em acordo.';
          ELSIF pr_tpdenvio = 2 THEN
            vr_dscritic := 'Envio de SMS nao permitido, emprestimo em acordo.';
          ELSIF pr_tpdenvio = 3 THEN
            vr_dscritic := 'Impressao nao permitida, emprestimo em acordo.';    
          END IF;
          -- Gerar exceção
          RAISE vr_exc_erro;
        END IF;
                
        -- verificar estado do boleto antes de imprimir ou enviar boleto        
        OPEN cr_boleto(pr_cdcooper
                      ,pr_nrctacob
                      ,pr_nrcnvcob
                      ,pr_nrdocmto);
        FETCH cr_boleto INTO rw_boleto;
        IF rw_boleto.incobran IN (3,5) THEN
           CLOSE cr_boleto;
           vr_dscritic := 'Nao e permitido imprimir/enviar boleto ' || rw_boleto.dscobran || '.';
           RAISE vr_exc_erro;
        ELSE
           CLOSE cr_boleto;
        END IF;        
        
				CASE pr_tpdenvio
					-- EMAIL
					WHEN 1 THEN
						UPDATE tbrecup_cobranca cde
							 SET cde.dsemail        = pr_dsdemail
									,cde.nmcontato      = pr_nmcontat
						 WHERE cde.cdcooper = pr_cdcooper
							 AND cde.nrdconta = pr_nrdconta
							 AND cde.nrctremp = pr_nrctremp
							 AND cde.nrdconta_cob = pr_nrctacob
							 AND cde.nrcnvcob = pr_nrcnvcob
							 AND cde.nrboleto = pr_nrdocmto;
            
            IF SQL%ROWCOUNT = 0 THEN 
               vr_dscritic := 'Erro ao atualizar boleto. Boleto nao encontrado.';
               RAISE vr_exc_erro;
            END IF;   
               
						vr_dstransa := 'Enviado boleto por e-mail refente ao contrato nr: ' || to_char(pr_nrctremp);
						vr_dsmensag := 'Boleto enviado por e-mail ' || pr_dsdemail;
						
						-- Gerar boleto e enviar por email
						pc_gerar_pdf_boletos(pr_cdcooper => pr_cdcooper
						                    ,pr_nrdconta => pr_nrctacob
																,pr_nrcnvcob => pr_nrcnvcob
																,pr_nrdocmto => pr_nrdocmto
																,pr_cdoperad => pr_cdoperad
																,pr_idorigem => pr_idorigem
																,pr_tpdenvio => pr_tpdenvio
																,pr_dsdemail => pr_dsdemail
																,pr_nmarqpdf => vr_nmarqpdf
																,pr_cdcritic => vr_cdcritic
																,pr_dscritic => vr_dscritic
																,pr_des_erro => vr_des_erro);
						
						-- Se retorno for diferente de OK
						IF vr_des_erro <> 'OK' THEN
							-- Gera exceção
							RAISE vr_exc_erro;
						END IF;
					   
					-- SMS
					WHEN 2 THEN
						UPDATE tbrecup_cobranca cde
							 SET cde.tpenvio        = pr_tpdenvio
									,cde.cdoperad_envio = pr_cdoperad
									,cde.dhenvio        = SYSDATE
									,cde.nrddd_sms      = pr_nrdddsms
									,cde.nrtel_sms      = pr_nrtelsms
									,cde.cdenvio_sms    = GENE0002.fn_char_para_number(fn_sequence('TBEPR_COBRANCA','CDENVIO_SMS',TO_CHAR(pr_cdcooper) ||
																																									 TO_CHAR(SYSDATE, 'RRRR') ||
																																									 TO_CHAR(SYSDATE, 'MM') ||
																																									 TO_CHAR(SYSDATE, 'DD')))
									,cde.nmcontato      = pr_nmcontat
									,cde.indretorno     = pr_indretor
						 WHERE cde.cdcooper = pr_cdcooper
							 AND cde.nrdconta = pr_nrdconta
							 AND cde.nrctremp = pr_nrctremp
							 AND cde.nrdconta_cob = pr_nrctacob
							 AND cde.nrcnvcob = pr_nrcnvcob
							 AND cde.nrboleto = pr_nrdocmto;
						vr_dstransa := 'Enviado boleto por SMS refente ao contrato nr: ' || to_char(pr_nrctremp);
						vr_dsmensag := 'Boleto enviado por SMS (' || to_char(pr_nrdddsms, '000') || ') ' ||
						               to_char(pr_nrtelsms);
					-- IMPRESSAO
					WHEN 3 THEN
 						vr_dstransa := 'Boleto impresso refente ao contrato nr: ' || to_char(pr_nrctremp);
						vr_dsmensag := 'Boleto impresso pela tela ' || pr_nmdatela;
					ELSE
   					-- Levanta exceção
					  RAISE vr_exc_update;
						
				END CASE;

				-- Se nao atualizou nenhum registro
				IF SQL%ROWCOUNT = 0 THEN
					-- Levanta exceção
					RAISE vr_exc_update;
				END IF;

			EXCEPTION
        WHEN vr_exc_erro THEN
					-- Atribui exceção devido a um erro tratado
					vr_cdcritic := 0;
					RAISE vr_exc_saida;
          
			  WHEN vr_exc_update THEN
					-- Atribui exceção caso nao seja atualizado nenhum registro
					vr_cdcritic := 0;
					vr_dscritic := 'Erro ao atualizar tabela tbrecup_cobranca: Dados nao encontrados.';
					RAISE vr_exc_saida;
				WHEN OTHERS THEN
          -- Atribui exceção para os parametros de crítica
          vr_cdcritic := vr_cdcritic;
          vr_dscritic := 'Erro nao tratado ao atualizar tabela tbrecup_cobranca' ||
					               ' na EMPR0007.pc_enviar_boleto: ' || SQLERRM;
					RAISE vr_exc_saida;
			END;

		  -- Gera log na lgm
			gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
				                   pr_cdoperad => pr_cdoperad,
													 pr_dscritic => '',
													 pr_dsorigem => vr_dsorigem,
													 pr_dstransa => vr_dstransa,
													 pr_dttransa => TRUNC(SYSDATE),
													 pr_flgtrans => 1,
													 pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSSSS')),
													 pr_idseqttl => 0,
													 pr_nmdatela => pr_nmdatela,
													 pr_nrdconta => pr_nrdconta,
													 pr_nrdrowid => vr_nrdrowid);

      -- Buscar tabela de boletos de cobrança
      COBR0005.pc_buscar_titulo_cobranca(pr_cdcooper => pr_cdcooper,
																				 pr_nrdconta => pr_nrctacob,
																				 pr_nrcnvcob => pr_nrcnvcob,
																				 pr_nrdocmto => pr_nrdocmto,
										                     pr_cdoperad => pr_cdoperad,
                                         pr_nriniseq => 1,
                                         pr_nrregist => 1,
																				 pr_cdcritic => vr_cdcritic,
																				 pr_dscritic => vr_dscritic,
																				 pr_tab_cob  => vr_tab_cob);

			-- Se retornou alguma crítica
			IF vr_cdcritic <> 0 OR
				 trim(vr_dscritic) IS NOT NULL THEN
				 -- Levanta exceção
			   RAISE vr_exc_saida;
		  END IF;

		  -- Contrato
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Contrato',
																pr_dsdadant => '',
																pr_dsdadatu => vr_tab_cob(1).nrctremp);
			-- Nr. do Boleto
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Nr. do Boleto',
																pr_dsdadant => '',
																pr_dsdadatu => vr_tab_cob(1).nrdocmto);
			-- Vencimento
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Vencimento',
																pr_dsdadant => '',
																pr_dsdadatu => TO_CHAR(vr_tab_cob(1).dtvencto, 'DD/MM/RRRR'));

			-- Valor do Boleto
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Vlr do boleto',
																pr_dsdadant => '',
																pr_dsdadatu => to_char(vr_tab_cob(1).vltitulo, 'fm999g999g990d00', 'NLS_NUMERIC_CHARACTERS = '',.'''));

			-- Linha Digitável
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Linha digitavel',
																pr_dsdadant => '',
																pr_dsdadatu => vr_tab_cob(1).lindigit);


		  -- Gera log de itens
			CASE pr_tpdenvio
				-- Email
				WHEN 1 THEN
					-- E-mail
				  gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																		pr_nmdcampo => 'E-mail',
																		pr_dsdadant => '',
																		pr_dsdadatu => vr_tab_cob(1).dsdemail);
				-- SMS
				WHEN 2 THEN
					-- Telefone
				  gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																		pr_nmdcampo => 'Telefone',
																		pr_dsdadant => '',
																		pr_dsdadatu => '(' || to_char(pr_nrdddsms, '000') || ')' ||
						                                       to_char(pr_nrtelsms, '9999g9999','nls_numeric_characters=.-'));
																									 
			  ELSE
					NULL;

			END CASE;

			-- Cria log de cobrança
			PAGA0001.pc_cria_log_cobranca(pr_idtabcob => vr_tab_cob(1).rowidcob,
			                              pr_cdoperad => pr_cdoperad,
																		pr_dtmvtolt => trunc(SYSDATE),
																		pr_dsmensag => vr_dsmensag,
																		pr_des_erro => vr_des_erro,
																		pr_dscritic => vr_dscritic);

			-- Se retornou algum erro
		  IF vr_des_erro <> 'OK' AND
				 trim(vr_dscritic) IS NOT NULL THEN
				 -- Levanta exceção
				 RAISE vr_exc_saida;
		  END IF;

      COMMIT;

		EXCEPTION
      WHEN vr_exc_saida THEN
				-- Se possui código de crítica e não foi informado a descrição
				IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					 -- Busca descrição da crítica
					 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
				END IF;

				-- Atribui exceção para os parametros de crítica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;

        ROLLBACK;
			WHEN OTHERS THEN
				-- Atribui exceção para os parametros de crítica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := 'Erro nao tratado na EMPR0007.pc_enviar_boleto: ' || SQLERRM;
        ROLLBACK;
		END;

	END pc_enviar_boleto;

	PROCEDURE pc_enviar_boleto_web(pr_nrdconta IN tbrecup_cobranca.nrdconta%TYPE              --> Nr. da Conta
																,pr_nrctremp IN tbrecup_cobranca.nrctremp%TYPE              --> Nr. Contrato
																,pr_nrctacob IN tbrecup_cobranca.nrdconta_cob%TYPE          --> Nr. Conta Cobrança
																,pr_nrcnvcob IN tbrecup_cobranca.nrcnvcob%TYPE              --> Nr. Convenio Cobrança
																,pr_nrdocmto IN tbrecup_cobranca.nrboleto%TYPE              --> Nr. Documento
																,pr_nmcontat IN tbrecup_cobranca.nmcontato%TYPE             --> Nome Contato
																,pr_tpdenvio IN tbrecup_cobranca.tpenvio%TYPE               --> Tipo de Envio (1 = EMAIL, 2 = SMS, 3 = IMPRESSAO)
																,pr_dsdemail IN tbrecup_cobranca.dsemail%TYPE DEFAULT NULL  --> Email
																,pr_indretor IN tbrecup_cobranca.indretorno%TYPE DEFAULT 0  --> Indicador de retorno
																,pr_nrdddsms IN tbrecup_cobranca.nrddd_sms%TYPE DEFAULT 0   --> DDD
																,pr_nrtelsms IN tbrecup_cobranca.nrtel_sms%TYPE DEFAULT 0   --> Telefone
																,pr_xmllog   IN VARCHAR2                                  --> XML com informações de LOG
																,pr_cdcritic OUT PLS_INTEGER                              --> Código da crítica
																,pr_dscritic OUT VARCHAR2                                 --> Descrição da crítica
																,pr_retxml   IN OUT NOCOPY XMLType                        --> Arquivo de retorno do XML
																,pr_nmdcampo OUT VARCHAR2                                 --> Nome do campo com erro
																,pr_des_erro OUT VARCHAR2) IS                             --> Erros do processo
  /* .............................................................................

      Programa: pc_enviar_boleto_web
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Lucas Reinert
      Data    : Agosto/15.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina para enviar os boletos por E-mail, SMS e Impressao para
			            o ambiente web

      Observacao: -----

      Alteracoes:
  ..............................................................................*/
	BEGIN
		DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;        --> Cód. Erro
      vr_dscritic VARCHAR2(1000);               --> Desc. Erro

		  -- Tratamento de erros
		  vr_exc_saida EXCEPTION;


      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

		BEGIN

			pr_des_erro := 'OK';
			-- Extrai dados do xml
			gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
															 pr_cdcooper => vr_cdcooper,
															 pr_nmdatela => vr_nmdatela,
															 pr_nmeacao  => vr_nmeacao,
															 pr_cdagenci => vr_cdagenci,
															 pr_nrdcaixa => vr_nrdcaixa,
															 pr_idorigem => vr_idorigem,
															 pr_cdoperad => vr_cdoperad,
															 pr_dscritic => vr_dscritic);

			-- Se retornou alguma crítica
			IF trim(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

			pc_enviar_boleto(pr_cdcooper => GENE0002.fn_char_para_number(vr_cdcooper),
			                 pr_nrdconta => pr_nrdconta,
                       pr_nrctremp => pr_nrctremp,
                       pr_nrctacob => pr_nrctacob,
                       pr_nrcnvcob => pr_nrcnvcob,
                       pr_nrdocmto => pr_nrdocmto,
                       pr_cdoperad => vr_cdoperad,
                       pr_nmcontat => pr_nmcontat,
                       pr_tpdenvio => pr_tpdenvio,
                       pr_nmdatela => vr_nmdatela,
                       pr_idorigem => GENE0002.fn_char_para_number(vr_idorigem),
                       pr_dsdemail => pr_dsdemail,
                       pr_indretor => pr_indretor,
											 pr_nrdddsms => pr_nrdddsms,
                       pr_nrtelsms => pr_nrtelsms,
											 pr_cdcritic => vr_cdcritic,
											 pr_dscritic => vr_dscritic);

			-- Se retornou alguma crítica
			IF vr_cdcritic <> 0 OR
				 trim(vr_dscritic) IS NOT NULL THEN
				 -- Levanta exceção
			   RAISE vr_exc_saida;
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

			  pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
			  pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
	END pc_enviar_boleto_web;

	PROCEDURE pc_gera_boleto_contrato (pr_cdcooper IN  crapcob.cdcooper%TYPE --> Código da cooperativa;
																		,pr_nrdconta IN  crapcob.nrdconta%TYPE --> Conta do cooperado do contrato;
																		,pr_nrctremp IN  crapcob.nrctremp%TYPE --> Número do contrato de empréstimo;
																		,pr_dtmvtolt IN  crapcob.dtmvtolt%TYPE --> Data do movimento;
																		,pr_tpparepr IN  NUMBER                --> Tipo de parcela 1 = Parcela Normal, 2 = Total do atraso 3 = Parcial do atraso 4 = Quitação do contrato;
																		,pr_dsparepr IN  VARCHAR2 DEFAULT NULL /* Descrição das parcelas do empréstimo “par1,par2,par..., parN”;
																																							Obs: empréstimo TR => NULL;
																																							Obs2: Quando for ref a várias parcelas do contrato, parcela = NULL;
																																							Obs3: Quando for quitação do contrato, parcela = 0; */
																		,pr_dtvencto IN  crapcob.dtvencto%TYPE --> Vencimento do boleto;
																		,pr_vlparepr IN  crappep.vlparepr%TYPE --> Valor da parcela;
																		,pr_cdoperad IN  crapcob.cdoperad%TYPE --> Código do operador;
																		,pr_nmdatela IN VARCHAR2               --> Nome da tela
														        ,pr_idorigem IN INTEGER                --> ID Origem
                                    ,pr_nrcpfava IN NUMBER DEFAULT 0       --> CPF do avalista
																		,pr_idarquiv IN INTEGER DEFAULT 0      --> Id do arquivo (boletagem Massiva)
                                    ,pr_idboleto IN INTEGER DEFAULT 0      --> Id do boleto no arquivo (boletagem Massiva)
																		,pr_peracres IN NUMBER DEFAULT 0       --> Percentual de Desconto
                                    ,pr_perdesco IN NUMBER DEFAULT 0       --> Percentual de Acrescimo
                                    ,pr_vldescto IN NUMBER DEFAULT 0       --> Valor do Desconto
                                    ,pr_vldevedor IN NUMBER DEFAULT 0
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código da crítica
																		,pr_dscritic OUT crapcri.dscritic%TYPE --> Descrição da crítica
																		) IS
	BEGIN
	/* .............................................................................

      Programa: pc_gera_boleto_contrato
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Lucas Reinert
      Data    : Agosto/15.                    Ultima atualizacao: 24/06/2019

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina para gerar boletos de contratos

      Observacao: -----

      Alteracoes: 25/11/2015 - Ajuste na rotina de busca do operador. (Rafael)

                  26/11/2015 - Ajuste na rotina para buscar o valor da critica do pagamento
                               minimo da parcela PP. (Rafael)
                               
                  30/11/2015 - Nao permitir gerar boleto TR com vencimento igual ou superior
                               ao dia da parcela. (Rafael)
                               
                  16/12/2015 - Nao permitir gerar boleto TR com vencimento igual ou superior
                               ao dia da parcela e data do dia inferior a data do debito. (Rafael)
                               
                  29/06/2016 - Adicionar validacao de substr para a leitura da crapass com a 
                               crapenc (Lucas Ranghetti #456095)
                               
                  28/11/2016 - Adicionado liberação para canais para gerar boleto de quitação de
                               emprestimo. (Kelvin SD 535306)

                  02/03/2017 - Inclusao pr_nrcpfava, geracao de boleto para avalista,
                               inclusao das parcelas na OBS para PP
                               e geracao de boleto em prejuizo. (P210.2 - Jaison/Daniel)
                               
                  30/03/2017 - Inclusao do parametro pr_idarquiv e pr_idboleto para
                               incluir na tabela tbrecup_cobranca. (P210.2 - Lombardi)
                               
                  12/12/2017 - Incluso novo parametro pr_vldevedor para gravar na tabela
				               tbrecup_cobranca o valor devedor do emprestimo na geracao do
							   boleto (Daniel SM 210.2) 
                               
                  10/05/2018 - P410 - Ajustes IOF (Marcos-Envolti)             
                               
                  11/06/2018 - Ajuste no insert da tabela crapsab, limitando o numero de caracteres
                               para 40, numero maximo permitido por esta tabela.
							   Chamado PRB0040065 - Gabriel (Mouts).

                  16/01/2019 - Ajuste na rotina para buscar o valor da critica do pagamento
                               minimo da parcela POS e gerar boleto POS. (P298.2.2 - Luciano - Supero)                 
                               
                  31/01/2019 - Boletagem Massiva para POS - não deverá seguir a regra de trava na data de 
                               vencimento do contrato, ou seja, será calculado o valor das parcelas, aplicando 
                               as variações do CDI até a data do processamento da boletagem.
                               (P298.2.2 - Luciano - Supero)                 
                               
                  15/02/2019 - Ajuste na rotina para criticar se o boleto eh para quitacao do contrato e nao 
                               for Canais. (P298.2.2 - Luciano - Supero)               

                  24/06/2019 - Incluido idorigem na geração do boleto.
							   P559 - André Clemer (Supero).

                               
  ..............................................................................*/

		DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
		  vr_des_erro VARCHAR2(3); --> Indicador erro      

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
			vr_des_reto VARCHAR2(3);
			vr_tab_erro gene0001.typ_tab_erro;

      -- Variáveis locais
			vr_nrdconta_cob crapsab.nrdconta%TYPE;
			vr_nrcnvcob crapcob.nrcnvcob%TYPE;
			vr_tab_cob cobr0005.typ_tab_cob;
			vr_dsorigem VARCHAR2(1000) := TRIM(GENE0001.vr_vet_des_origens(pr_idorigem));
			vr_nrdrowid ROWID;
			vr_dsparcel gene0002.typ_split;
      vr_vlparepr crappep.vlparepr%TYPE;
			vr_vltotpag crappep.vlparepr%TYPE := 0;
			vr_vlpagsld crappep.vlparepr%TYPE;
      vr_vlatupar crappep.vlparepr%TYPE;
      vr_vlmtapar crappep.vlparepr%TYPE;
      vr_vljinpar crappep.vlparepr%TYPE;
      vr_vlmrapar crappep.vlparepr%TYPE;
      vr_vliofcpl crappep.vliofcpl%TYPE;
      vr_dstextab craptab.dstextab%TYPE;  --> Busca na craptab		
      vr_vlmindeb crappep.vlparepr%TYPE;	--> Valor mínimo para debito
      
      vr_cdtpinsc crapass.inpessoa%TYPE;
      vr_nrinssac crapass.nrcpfcgc%TYPE;
      vr_nmprimtl crapass.nmprimtl%TYPE;
			vr_dsendere crapenc.dsendere%TYPE;
      vr_nmbairro crapenc.nmbairro%TYPE;
      vr_nrcepend crapenc.nrcepend%TYPE;
      vr_nmcidade crapenc.nmcidade%TYPE;
      vr_cdufende crapenc.cdufende%TYPE;
      vr_nrendere crapenc.nrendere%TYPE;
      vr_complend crapenc.complend%TYPE;
      vr_dtvencto crappep.dtvencto%TYPE;      
      vr_dtmvtoan crapdat.dtmvtoan%TYPE;
      
      vr_percmult NUMBER(25,2);

			-- Variáveis para passagem a rotina pc_calcula_lelem
      vr_vlsdeved crapepr.vlsdeved%TYPE;      --> Saldo devedor do empréstimo
			vr_vlatraso crapepr.vlsdeved%TYPE;      --> Valor atraso do emprestimo

			-- Tabelas retornadas de procedures
			vr_tab_pgto_parcel empr0001.typ_tab_pgto_parcel;
			vr_tab_calculado   empr0001.typ_tab_calculado;
      vr_tab_aval        DSCT0002.typ_tab_dados_avais;
      vr_tab_parcelas_pos  empr0011.typ_tab_parcelas;
			vr_tab_calculado_pos empr0011.typ_tab_calculado;
      
      -- Valores minimos
      vr_vlrmintr craplem.vllanmto%TYPE;
      vr_vlrminpp craplem.vllanmto%TYPE;      
      vr_vlminpos craplem.vllanmto%TYPE;      
      vr_vlrmin_prod craplem.vllanmto%TYPE;      


      
      -- Variavel de informacao do boleto
      vr_dsinform VARCHAR2(400);

			-- Identificar o tipo de emprestimo
			CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
			                 ,pr_nrdconta IN crapepr.nrdconta%TYPE
											 ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
				SELECT crapepr.tpemprst,
               crapepr.inprejuz,
               crapepr.cdfinemp,
               crawepr.txmensal,
               crawepr.cddindex,
               crawepr.dtdpagto,
               crapepr.vlsprojt,
               crapepr.vlemprst,
               crapepr.cdlcremp,
               crapepr.qttolatr,
               crapepr.dtmvtolt,
               crapepr.dtultpag    
				  FROM crapepr  
          JOIN crawepr  
            ON crawepr.cdcooper = crapepr.cdcooper
           AND crawepr.nrdconta = crapepr.nrdconta
           AND crawepr.nrctremp = crapepr.nrctremp
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
           
			rw_crapepr cr_crapepr%ROWTYPE;
	
			-- Busca cpf/cnpj
			CURSOR cr_crapass(pr_cdcooper IN crapsab.cdcooper%TYPE
											 ,pr_nrdconta IN crapsab.nrdconta%TYPE) IS
				SELECT ass.nrcpfcgc nrcpfcgc
              ,ass.inpessoa inpessoa              
              ,SUBSTR(ass.nmprimtl,1,50) nmprimtl
              ,ass.cdagenci cdagenci
              ,enc.dsendere dsendere
              ,enc.nrendere nrendere
              ,enc.nrcepend nrcepend
              ,SUBSTR(enc.complend,1,40) complend
              ,SUBSTR(enc.nmbairro,1,30) nmbairro
              ,enc.nmcidade nmcidade
              ,enc.cdufende cdufende
				  FROM crapass ass
					    ,crapenc enc
				 WHERE ass.cdcooper = pr_cdcooper
				   AND ass.nrdconta = pr_nrdconta
					 AND enc.cdcooper = ass.cdcooper
					 AND enc.nrdconta = ass.nrdconta
					 AND ((enc.tpendass = 10 AND ass.inpessoa = 1)
					 OR   (enc.tpendass = 9  AND ass.inpessoa IN (2,3))); /* Residencial */
		  rw_crapass cr_crapass%ROWTYPE;

			-- Cursor para busca dos sacados cobrança
			CURSOR cr_crapsab (pr_cdcooper IN crapcop.cdcooper%TYPE
												,pr_nrctabnf IN crapsab.nrdconta%TYPE
												,pr_nrinssac IN crapass.nrcpfcgc%TYPE) IS
				SELECT 1
				  FROM crapsab sab
				 WHERE sab.cdcooper = pr_cdcooper
				 	 AND sab.nrdconta = pr_nrctabnf
					 AND sab.nrinssac = pr_nrinssac;
			rw_crapsab cr_crapsab%ROWTYPE;
      
      -- cursor do operador
      CURSOR cr_ope (pr_cdcooper IN crapope.cdcooper%TYPE
                    ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT cddepart
          FROM crapope ope
         WHERE ope.cdcooper = pr_cdcooper
           AND UPPER(ope.cdoperad) = UPPER(pr_cdoperad);
      rw_ope cr_ope%ROWTYPE;

			-- Buscar data vencimento quitação contrato POS
			CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE
			                 ,pr_nrdconta IN crappep.nrdconta%TYPE
											 ,pr_nrctremp IN crappep.nrctremp%TYPE) IS            
        SELECT (pep.dtvencto - 1) dtvencto
          FROM crappep pep
         WHERE pep.cdcooper = pr_cdcooper
           AND pep.nrdconta = pr_nrdconta
           AND pep.nrctremp = pr_nrctremp
           AND pep.dtvencto > pr_dtmvtolt
           AND pep.inliquid = 0
           AND pep.vlpagpar = 0;
			rw_crappep cr_crappep%ROWTYPE;
      
			-- Buscar campo vlpagmta
			CURSOR cr_crappep_pos(pr_cdcooper IN crappep.cdcooper%TYPE
			                     ,pr_nrdconta IN crappep.nrdconta%TYPE
											     ,pr_nrctremp IN crappep.nrctremp%TYPE
                           ,pr_nrparepr IN crappep.nrparepr%TYPE) IS            
        SELECT pep.vlpagmta
              ,pep.dtvencto
          FROM crappep pep
         WHERE pep.cdcooper = pr_cdcooper
           AND pep.nrdconta = pr_nrdconta
           AND pep.nrctremp = pr_nrctremp
           AND pep.inliquid = 0
           AND pep.nrparepr = pr_nrparepr;
			rw_crappep_pos cr_crappep_pos%ROWTYPE;      
      
      -- Cursor da Linha de Crédito
      CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                       ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT perjurmo,
               flgcobmu
          FROM craplcr
         WHERE cdcooper = pr_cdcooper
           AND cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;      
      
      --IOF
      vr_vliofpri NUMBER;
      vr_vliofadi NUMBER;

      vr_vltaxa_iof_principal VARCHAR2(20);
      vr_qtdiaiof NUMBER;
      vr_flgimune PLS_INTEGER;
      vr_dscatbem VARCHAR2(100);
      vr_cdlcremp NUMBER;
	  
	   -- Cursor para bens do contrato: 
      /*Faz o order by dscatbem pois "CASA" e "APARTAMENTO" reduzem as 3 aliquotas de IOF (principal, adicional e complementar) a zero.
      Já "MOTO" reduz apenas as alíquotas de IOF principal e complementar..
      Dessa forma, se tiver um bem que seja CASA ou APARTAMENTO, não precisa mais verificar os outros bens..*/
      CURSOR cr_crapbpr(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS      
        SELECT b.dscatbem, t.cdlcremp
        FROM crapepr t
        INNER JOIN crapbpr b ON b.nrdconta = t.nrdconta AND b.cdcooper = t.cdcooper AND b.nrctrpro = t.nrctremp
        WHERE t.cdcooper = pr_cdcooper
              AND t.nrdconta = pr_nrdconta
              AND t.nrctremp = pr_nrctremp
              AND upper(b.dscatbem) IN ('APARTAMENTO', 'CASA', 'MOTO')
        ORDER BY upper(b.dscatbem) ASC;
      rw_crapbpr cr_crapbpr%ROWTYPE;

		BEGIN           
      
      vr_dtvencto := pr_dtvencto;
      vr_dtmvtoan := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                ,pr_dtmvtolt => vr_dtvencto - 1
                                                ,pr_tipo => 'A');
      
      IF pr_cdoperad <> '1' THEN 
         
         -- verificar se o operador existe
         OPEN cr_ope (pr_cdcooper => pr_cdcooper
                     ,pr_cdoperad => pr_cdoperad);
         FETCH cr_ope INTO rw_ope;
         IF cr_ope%NOTFOUND THEN
            CLOSE cr_ope;
            -- Atribui crítica
            vr_cdcritic := 0;
            vr_dscritic := 'Operador nao encontrado.';
            -- Levanta exceção
            RAISE vr_exc_saida;           
         ELSE
            CLOSE cr_ope;
         END IF;
         
         -- se o boleto eh para quitacao do contrato e nao for da central telefonica, criticar...
         IF pr_tpparepr = 4 AND nvl(rw_ope.cddepart,0) IN (3,5,7) AND pr_idarquiv = 0 THEN   --Adicionado CANAIS (SD 548663)
            -- Atribui crítica
            vr_cdcritic := 0;
            vr_dscritic := 'Quitacao do contrado permitido apenas para operadores de CANAIS.';
            -- Levanta exceção
            RAISE vr_exc_saida;                                
         END IF;
         
      END IF;      
					
			-- Localizar conta do emitente do boleto, neste caso a cooperativa
			vr_nrdconta_cob := GENE0002.fn_char_para_number(gene0001.fn_param_sistema(pr_cdcooper => pr_cdcooper
																										 ,pr_nmsistem => 'CRED'
																										 ,pr_cdacesso => 'COBEMP_NRDCONTA_BNF'));

			-- Localizar convenio de cobrança
			vr_nrcnvcob := gene0001.fn_param_sistema(pr_cdcooper => pr_cdcooper
			                                        ,pr_nmsistem => 'CRED'
																							,pr_cdacesso => 'COBEMP_NRCONVEN');

			-- Busca cpf/cnpj do cooperado
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper
			                ,pr_nrdconta => pr_nrdconta);
			FETCH cr_crapass INTO rw_crapass;
			CLOSE cr_crapass;

			-- Busca tipo do emprestimo
			OPEN cr_crapepr (pr_cdcooper => pr_cdcooper
			                ,pr_nrdconta => pr_nrdconta
											,pr_nrctremp => pr_nrctremp);
			FETCH cr_crapepr INTO rw_crapepr;

      -- Se não encontrar emprestimo
      IF cr_crapepr%NOTFOUND THEN
				-- Fecha cursor
				CLOSE cr_crapepr;
				-- Atribui crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Contrato de emprestimo nao encontrado';
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;
			-- Fecha cursor
			CLOSE cr_crapepr;
      
      -- Buscar os dados da linha de crédito
      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                     ,pr_cdlcremp => rw_crapepr.cdlcremp);
      FETCH cr_craplcr
       INTO rw_craplcr;
      -- Se não encontrar informações
      IF cr_craplcr%NOTFOUND THEN
        -- Fechar o cursor pois teremos raise
        CLOSE cr_craplcr;
        -- Gerar erro com critica 363
        vr_cdcritic := 363;
        RAISE vr_exc_saida;
      END IF;
      -- Apenas fechar o cursor para continuar o processo
      CLOSE cr_craplcr;
      
      -- Verifica se a Linha de Credito Cobra Multa
      IF rw_craplcr.flgcobmu = 1 THEN
         -- Utilizar como % de multa, as 6 primeiras posicoes encontradas
         vr_percmult := GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,1,6));
      ELSE
         vr_percmult := 0;
      END IF; 
      
      -- Obter o % de multa da CECRED - TAB090
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => 3 -- Fixo 3 - Cecred
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'PAREMPCTL'
                                               ,pr_tpregist => 01);
      IF vr_dstextab IS NULL THEN
         vr_cdcritic := 55;
         RAISE vr_exc_saida;
      END IF;
      
      -- se empretimo TR e vencimento igual ou superior a data do debito da parcela, 
      -- e data do dia inferior a data do débito, entao criticar.      
      IF rw_crapepr.tpemprst = 0 AND -- TR
         pr_tpparepr = 2 AND -- Somente para Total do atraso
         to_date(to_char(rw_crapepr.dtdpagto,'DD') ||  '/' || 
                 to_char(vr_dtvencto,'MM/RRRR'),'DD/MM/RRRR') <= vr_dtvencto AND
         pr_dtmvtolt < to_date(to_char(rw_crapepr.dtdpagto,'DD') ||  '/' || 
                               to_char(pr_dtmvtolt,'MM/RRRR'),'DD/MM/RRRR') THEN
				-- Atribui crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Nao e possivel emitir boleto para o vencimento informado - ' || 
                       'parcela a vencer dia ' || to_char(rw_crapepr.dtdpagto,'DD') || '.';
				-- Levanta exceção
				RAISE vr_exc_saida;                 
      END IF;                       
      
      BEGIN
        vr_vlrmintr := to_number(replace(replace(gene0001.fn_param_sistema(pr_cdcooper => pr_cdcooper
                                                                          ,pr_nmsistem => 'CRED'
                                                                          ,pr_cdacesso => 'COBEMP_VLR_MIN_TR'),',',''),'.','')/100);      
      EXCEPTION                                                          
        WHEN OTHERS THEN
          -- Atribui crítica
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao acessar parametro de valor minimo para boleto TR.';
  				-- Levanta exceção
	  			RAISE vr_exc_saida;        
      END;
      
      BEGIN
        vr_vlrminpp := to_number(replace(replace(gene0001.fn_param_sistema(pr_cdcooper => pr_cdcooper
                                                                          ,pr_nmsistem => 'CRED'
                                                                          ,pr_cdacesso => 'COBEMP_VLR_MIN_PP'),',',''),'.','')/100);      
      EXCEPTION                                                          
        WHEN OTHERS THEN
          -- Atribui crítica
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao acessar parametro de valor minimo para boleto PP.';
          -- Levanta exceção
          RAISE vr_exc_saida;        
      END;     
      
      BEGIN
        vr_vlminpos := to_number(replace(replace(gene0001.fn_param_sistema(pr_cdcooper => pr_cdcooper
                                                                          ,pr_nmsistem => 'CRED'
                                                                          ,pr_cdacesso => 'COBEMP_VLR_MIN_POS'),',',''),'.','')/100);
      EXCEPTION
        WHEN OTHERS THEN
          -- Atribui crítica
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao acessar parametro de valor minimo para boleto POS.';
          -- Levanta exceção
          RAISE vr_exc_saida;
      END;
      
      

      -- Verifica se pode gerar o boleto
 		  pc_verifica_gerar_boleto (pr_cdcooper => pr_cdcooper      --> Cód. cooperativa
			                         ,pr_nrctacob => vr_nrdconta_cob  --> Nr. da Conta Cob.
															 ,pr_nrdconta => pr_nrdconta      --> Nr. da Conta
															 ,pr_nrcnvcob => vr_nrcnvcob      --> Nr. do Convênio de Cobrança
															 ,pr_nrctremp => pr_nrctremp      --> Nr. do Contrato
															 ,pr_idarquiv => pr_idarquiv      --> Nr. do arquivo (Boletagem Massiva)
                               ,pr_cdcritic => vr_cdcritic      --> Código da crítica
															 ,pr_dscritic => vr_dscritic      --> Descrição da crítica
															 ,pr_des_erro => vr_des_reto);    --> Erros do processo
							
		  -- Se retorno for diferente de OK								 
		  IF vr_des_reto <> 'OK' THEN
				-- Gerar exceção
				RAISE vr_exc_saida;
			END IF;

      
      -- Novo cálculo de IOF
      vr_dscatbem := NULL;
      vr_cdlcremp := NULL;
      --Verifica o primeiro bem do contrato para saber se tem isenção de alíquota
      OPEN cr_crapbpr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crapbpr INTO rw_crapbpr;
      IF cr_crapbpr%FOUND THEN
        vr_dscatbem := rw_crapbpr.dscatbem;
        vr_cdlcremp := rw_crapbpr.cdlcremp;
      END IF;
      CLOSE cr_crapbpr;
      
      --Dias de atraso
      vr_qtdiaiof := vr_dtvencto - pr_dtmvtolt;
                              
      --Calcula o IOF
      TIOF0001.pc_calcula_valor_iof_epr(pr_tpoperac => 2                                      --> Somente o atraso
                                       ,pr_cdcooper => pr_cdcooper                            --> Código da cooperativa referente ao contrato de empréstimos
                                        ,pr_nrdconta => pr_nrdconta                            --> Número da conta referente ao empréstimo
                                        ,pr_nrctremp => pr_nrctremp                            --> Número do contrato de empréstimo
                                        ,pr_vlemprst => pr_vlparepr                            --> Valor do empréstimo para efeito de cálculo
                                        ,pr_dscatbem => vr_dscatbem                            --> Descrição da categoria do bem, valor default NULO 
                                        ,pr_cdlcremp => vr_cdlcremp                            --> Linha de crédito do empréstimo
                                        ,pr_cdfinemp => rw_crapepr.cdfinemp                    --> Finalidade do empréstimo
                                        ,pr_dtmvtolt => pr_dtmvtolt                            --> Data do movimento
                                        ,pr_qtdiaiof => vr_qtdiaiof                            --> Quantidade de dias em atraso
                                        ,pr_vliofpri => vr_vliofpri                            --> Valor do IOF principal
                                        ,pr_vliofadi => vr_vliofadi                            --> Valor do IOF adicional
                                        ,pr_vliofcpl => vr_vliofcpl                            --> Valor do IOF complementar
                                        ,pr_vltaxa_iof_principal => vr_vltaxa_iof_principal    --> Valor da Taxa do IOF Principal
                                        ,pr_flgimune => vr_flgimune                            --> Possui imunidade tributária
                                        ,pr_dscritic => vr_dscritic);                          --> Descrição da crítica
                                                
      IF NVL(vr_dscritic, ' ') <> ' ' THEN
        RAISE vr_exc_saida;
      END IF;
      
      --Imunidade....
      IF vr_flgimune > 0 THEN
        vr_vliofpri := 0;
        vr_vliofadi := 0;
        vr_vliofcpl := 0;
      ELSE
        vr_vliofcpl := NVL(vr_vliofcpl, 0);
      END IF;
      
      IF rw_crapepr.inprejuz = 1 THEN
        NULL;
        -- Por enquanto não será incluido tratativa validação saldo.
      ELSE
        
 		  -- Emprestimo PP
		  IF rw_crapepr.tpemprst = 1 THEN

			  IF pr_tpparepr <> 4 THEN
					 -- Desmonta as parcelas informadas e atribui ao array
					 vr_dsparcel := gene0002.fn_quebra_string(pr_string => pr_dsparepr);

					 -- Verifica se foi paga a parcela anterior a partir da primeira parcela informada
					 EMPR0001.pc_verifica_parcel_anteriores(pr_cdcooper => pr_cdcooper
																								 ,pr_nrdconta => pr_nrdconta
																								 ,pr_nrctremp => pr_nrctremp
																								 ,pr_nrparepr => GENE0002.fn_char_para_number(vr_dsparcel(1))
																								 ,pr_dtmvtolt => pr_dtmvtolt
																								 ,pr_des_reto => vr_des_reto
																								 ,pr_dscritic => vr_dscritic);

					-- Se retornou alguma crítica
					IF vr_des_reto <> 'OK' AND TRIM(vr_dscritic) IS NOT NULL THEN
						 -- Levanta exceção
						 RAISE vr_exc_saida;
					END IF;

					-- Percorre as parcelas informadas
					FOR idx IN vr_dsparcel.first..vr_dsparcel.last LOOP

						-- Se não for a primeira parcela
						IF idx > vr_dsparcel.first THEN
							/* Verifica se as parcelas estão ordenadas.
								 Número da parcela do ponteiro atual menos a do ponteiro anterior
								 precisa ser 1 para ser ordenado. Exemplo (idx = 7 idx - 1 = 6 | 7 - 6 = 1)*/
							IF (GENE0002.fn_char_para_number(vr_dsparcel(idx)) - GENE0002.fn_char_para_number(vr_dsparcel(idx - 1))) <> 1 THEN
								vr_cdcritic := 0;
								vr_dscritic := 'Parcelas devem ser selecionadas de forma ordenada.';
								RAISE vr_exc_saida;
							END IF;
						END IF;

					END LOOP;
				END IF;

				-- Procedure chamada para buscar o valor calculado da parcela
				EMPR0001.pc_busca_pgto_parcelas(pr_cdcooper => pr_cdcooper
																			 ,pr_cdagenci => rw_crapass.cdagenci
																			 ,pr_nrdcaixa => 1
																			 ,pr_cdoperad => pr_cdoperad
																			 ,pr_nmdatela => pr_nmdatela
																			 ,pr_idorigem => pr_idorigem
																			 ,pr_nrdconta => pr_nrdconta
																			 ,pr_idseqttl => 1
																			 ,pr_dtmvtolt => vr_dtvencto --pr_dtmvtolt
																			 ,pr_flgerlog => 'N'
																			 ,pr_nrctremp => pr_nrctremp
																			 ,pr_dtmvtoan => gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
																																									,pr_dtmvtolt => vr_dtvencto - 1
																																									,pr_tipo => 'A')
																			 ,pr_nrparepr => 0
																			 ,pr_des_reto => vr_des_reto
																			 ,pr_tab_erro => vr_tab_erro
																			 ,pr_tab_pgto_parcel => vr_tab_pgto_parcel
																			 ,pr_tab_calculado => vr_tab_calculado);

				IF vr_des_reto <> 'OK' THEN
					IF vr_tab_erro.count() > 0 THEN
						-- Atribui críticas às variaveis
						vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
						vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
					ELSE
						vr_cdcritic := 0;
						vr_dscritic := 'Erro ao consultar pagamento de parcelas';
					END IF;
					-- Levanta exceção
					RAISE vr_exc_saida;
				END IF;

				-- Se não for quitação do contrato
				IF pr_tpparepr <> 4 THEN
          vr_vlparepr := pr_vlparepr;

					-- Para cada parcela do contrato
					FOR idx IN vr_tab_pgto_parcel.first..vr_tab_pgto_parcel.last LOOP

						-- Se parcela está liquidada procura próxima
						IF vr_tab_pgto_parcel(idx).inliquid = 1 THEN
							CONTINUE;
						END IF;

							-- Percorre as parcelas informadas
							FOR idx2 IN vr_dsparcel.first..vr_dsparcel.last LOOP
								-- Se encontrou parcela informada
								IF (vr_tab_pgto_parcel(idx).nrparepr = vr_dsparcel(idx2)) THEN

								  -- Permitir a geração de boletos apenas para parcelas em atraso
								  IF (vr_tab_pgto_parcel(idx).dtvencto >= vr_dtvencto) THEN
										-- Atribui crítica
										vr_cdcritic := 0;
										vr_dscritic := 'Permitido apenas geracao de boleto para parcelas em atraso.';
										-- Levanta exceção
										RAISE vr_exc_saida;
									END IF;
									-- Incrementa valor total a pagar
									vr_vltotpag := vr_vltotpag + vr_tab_pgto_parcel(idx).vlatrpag;
									-- Verifica se o valor a pagar é o suficiente para pagar a parcela
									IF (vr_vlparepr >= vr_tab_pgto_parcel(idx).vlatrpag) THEN

										-- Decrementa valor da parcela ao valor total de pagamento
										vr_vlparepr := vr_vlparepr - vr_tab_pgto_parcel(idx).vlatrpag;

									ELSE
										-- Se valor total de pagamento não estiver zerado
										IF vr_vlparepr > 0 THEN

											EMPR0001.pc_valida_pagto_atr_parcel(pr_cdcooper => pr_cdcooper
																												 ,pr_cdagenci => rw_crapass.cdagenci
																												 ,pr_nrdcaixa => 1
																												 ,pr_cdoperad => pr_cdoperad
																												 ,pr_nmdatela => pr_nmdatela
																												 ,pr_idorigem => pr_idorigem
																												 ,pr_nrdconta => pr_nrdconta
																												 ,pr_idseqttl => 1
																												 ,pr_dtmvtolt => vr_dtvencto
																												 ,pr_flgerlog => 'N'
																												 ,pr_nrctremp => pr_nrctremp
																												 ,pr_nrparepr => vr_tab_pgto_parcel(idx).nrparepr
																												 ,pr_vlpagpar => vr_vlparepr
																												 ,pr_vlpagsld => vr_vlpagsld
																												 ,pr_vlatupar => vr_vlatupar
																												 ,pr_vlmtapar => vr_vlmtapar
																												 ,pr_vljinpar => vr_vljinpar
																												 ,pr_vlmrapar => vr_vlmrapar
																												 ,pr_vliofcpl => vr_vliofcpl                                                     
																												 ,pr_des_reto => vr_des_reto
																												 ,pr_tab_erro => vr_tab_erro);

											IF vr_des_reto <> 'OK' THEN
												IF vr_tab_erro.count() > 0 THEN
													-- Atribui críticas às variaveis
													vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
													vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                          
                          -- se a critica for do produto, verificar se a critica tbem nao é do valor minimo
                          IF vr_dscritic LIKE 'Valor a pagar deve ser maior ou igual que%' THEN
                             vr_vlrmin_prod := to_number(replace(replace(replace(SUBSTR(vr_dscritic, INSTR(vr_dscritic,'R$'),10),'R$',''),',',''),'.',''))/100;
                             IF nvl(pr_vlparepr,0) < vr_vlrminpp AND pr_tpparepr = 3 AND 
                                vr_vlrminpp > vr_vlrmin_prod THEN
                               -- Atribui crítica
                               vr_cdcritic := 0;
                               vr_dscritic := 'Valor do boleto devera ser maior que o valor minimo de R$ ' || 
                                              to_char(vr_vlrminpp,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS = '',.''') || '.';
                               -- Levanta exceção
                               RAISE vr_exc_saida;                   
                             END IF;                          
                            
                          END IF;
                          
												ELSE
													vr_cdcritic := 0;
													vr_dscritic := 'Erro ao validar pagamento de parcelas';
												END IF;
												-- Levanta exceção
												RAISE vr_exc_saida;
											END IF;

											-- Zera valor informado
											vr_vlparepr := 0;

										ELSE
											-- Se valor total de pagamento está zerado e
											-- alguma parcela informada ainda não foi processada
											vr_cdcritic := 0;
											vr_dscritic := 'Valor total insuficiente para as parcelas selecionadas.';
											-- Levanta exceção
											RAISE vr_exc_saida;
										END IF;
									END IF;

									EXIT;

								END IF;

							END LOOP;

					    EXIT WHEN vr_tab_pgto_parcel(idx).nrparepr = vr_dsparcel(vr_dsparcel.last);

					END LOOP;

					-- Se valor informado for maior que o valor total a pagar pelas parcelas informadas
					IF pr_vlparepr > vr_vltotpag THEN
						-- Atribui crítica
						vr_cdcritic := 0;
						vr_dscritic := 'Valor informado superior ao valor total das parcelas informadas. '
            || to_char(pr_vlparepr,'fm999g999g990d00') || ' - ' || to_char(vr_vltotpag,'fm999g999g990d00');
						-- Gera exceção
						RAISE vr_exc_saida;
					END IF;

				-- Quitação do contrato
				ELSE
          -- Verifica se valor informado para quitação do empréstimo
					-- é diferente ao saldo devedor do contrato
					IF (vr_tab_calculado(vr_tab_calculado.first).vlsdeved <> pr_vlparepr AND pr_idarquiv = 0) THEN
						-- Atribui crítica
          	vr_cdcritic := 0;
						vr_dscritic := 'Valor informado para quitacao do emprestimo diferente do saldo devedor do contrato.';
						-- Levanta exceção
						RAISE vr_exc_saida;
					END IF;
				END IF;
        
 		  -- Emprestimo POS
		  ELSIF rw_crapepr.tpemprst = 2 THEN

			  IF pr_tpparepr <> 4 THEN
					 -- Desmonta as parcelas informadas e atribui ao array
					 vr_dsparcel := gene0002.fn_quebra_string(pr_string => pr_dsparepr);

					 -- Verifica se foi paga a parcela anterior a partir da primeira parcela informada
					 EMPR0001.pc_verifica_parcel_anteriores(pr_cdcooper => pr_cdcooper
																								 ,pr_nrdconta => pr_nrdconta
																								 ,pr_nrctremp => pr_nrctremp
																								 ,pr_nrparepr => GENE0002.fn_char_para_number(vr_dsparcel(1))
																								 ,pr_dtmvtolt => pr_dtmvtolt
																								 ,pr_des_reto => vr_des_reto
																								 ,pr_dscritic => vr_dscritic);

					-- Se retornou alguma crítica
					IF vr_des_reto <> 'OK' AND TRIM(vr_dscritic) IS NOT NULL THEN
						 -- Levanta exceção
						 RAISE vr_exc_saida;
					END IF;

					-- Percorre as parcelas informadas
					FOR idx IN vr_dsparcel.first..vr_dsparcel.last LOOP

						-- Se não for a primeira parcela
						IF idx > vr_dsparcel.first THEN
							/* Verifica se as parcelas estão ordenadas.
								 Número da parcela do ponteiro atual menos a do ponteiro anterior
								 precisa ser 1 para ser ordenado. Exemplo (idx = 7 idx - 1 = 6 | 7 - 6 = 1)*/
							IF (GENE0002.fn_char_para_number(vr_dsparcel(idx)) - GENE0002.fn_char_para_number(vr_dsparcel(idx - 1))) <> 1 THEN
								vr_cdcritic := 0;
								vr_dscritic := 'Parcelas devem ser selecionadas de forma ordenada.';
								RAISE vr_exc_saida;
							END IF;
						END IF;

					END LOOP;
				END IF;

				-- Procedure chamada para buscar o valor calculado da parcela
        EMPR0011.pc_busca_pagto_parc_pos(pr_cdcooper => pr_cdcooper
                                        ,pr_cdprogra => 'COBEMP'
                                        ,pr_dtmvtolt => pr_dtvencto
                                        ,pr_dtmvtoan => vr_dtmvtoan
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrctremp => pr_nrctremp
                                        ,pr_dtefetiv => rw_crapepr.dtmvtolt
                                        ,pr_cdlcremp => rw_crapepr.cdlcremp
                                        ,pr_vlemprst => rw_crapepr.vlemprst
                                        ,pr_txmensal => rw_crapepr.txmensal
                                        ,pr_dtdpagto => rw_crapepr.dtdpagto
                                        ,pr_vlsprojt => rw_crapepr.vlsprojt
                                        ,pr_qttolatr => rw_crapepr.qttolatr
                                        ,pr_tab_parcelas => vr_tab_parcelas_pos
														            ,pr_tab_calculado => vr_tab_calculado_pos
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);

				IF vr_des_reto <> 'OK' THEN
					IF vr_tab_erro.count() > 0 THEN
						-- Atribui críticas às variaveis
						vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
						vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
					ELSE
						vr_cdcritic := 0;
						vr_dscritic := 'Erro ao consultar pagamento de parcelas';
					END IF;
					-- Levanta exceção
					RAISE vr_exc_saida;
				END IF;

				-- Se não for quitação do contrato
				IF pr_tpparepr <> 4 THEN
          vr_vlparepr := pr_vlparepr;

					-- Para cada parcela do contrato
					FOR idx IN vr_tab_parcelas_pos.first..vr_tab_parcelas_pos.last LOOP

						-- Se parcela está liquidada procura próxima
						IF vr_tab_parcelas_pos(idx).inliquid = 1 THEN
							CONTINUE;
						END IF;

							-- Percorre as parcelas informadas
							FOR idx2 IN vr_dsparcel.first..vr_dsparcel.last LOOP
								-- Se encontrou parcela informada
								IF (vr_tab_parcelas_pos(idx).nrparepr = vr_dsparcel(idx2)) THEN

								  -- Permitir a geração de boletos apenas para parcelas em atraso
								  IF (vr_tab_parcelas_pos(idx).dtvencto >= vr_dtvencto) THEN
										-- Atribui crítica
										vr_cdcritic := 0;
										vr_dscritic := 'Permitido apenas geracao de boleto para parcelas em atraso.';
										-- Levanta exceção
										RAISE vr_exc_saida;
									END IF;
									-- Incrementa valor total a pagar
									vr_vltotpag := vr_vltotpag + vr_tab_parcelas_pos(idx).vlatrpag;
									-- Verifica se o valor a pagar é o suficiente para pagar a parcela
									IF (vr_vlparepr >= vr_tab_parcelas_pos(idx).vlatrpag) THEN

										-- Decrementa valor da parcela ao valor total de pagamento
										vr_vlparepr := vr_vlparepr - vr_tab_parcelas_pos(idx).vlatrpag;

									ELSE
										-- Se valor total de pagamento não estiver zerado
										IF vr_vlparepr > 0 THEN
                      
                    -- seleciona campo vlpagmta POS
                       OPEN cr_crappep_pos (pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrctremp => pr_nrctremp
                                           ,pr_nrparepr => vr_tab_parcelas_pos(idx).nrparepr);
                       FETCH cr_crappep_pos INTO rw_crappep_pos;
                       CLOSE cr_crappep_pos;
                    

                          EMPR0011.pc_calcula_atraso_pos_fixado(
                                   pr_cdcooper => pr_cdcooper
                                  ,pr_cdprogra => 'COBEMP'
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctremp => pr_nrctremp
                                  ,pr_cdlcremp => rw_crapepr.cdlcremp
                                  ,pr_dtcalcul => pr_dtvencto
                                  ,pr_vlemprst => rw_crapepr.vlemprst
                                  ,pr_nrparepr => vr_tab_parcelas_pos(idx).nrparepr
                                  ,pr_vlparepr => pr_vlparepr
                                  ,pr_dtvencto => rw_crappep_pos.dtvencto
                                  ,pr_dtultpag => rw_crapepr.dtultpag
                                  ,pr_vlsdvpar => vr_vlatupar
                                  ,pr_perjurmo => rw_craplcr.perjurmo
                                  ,pr_vlpagmta => rw_crappep_pos.vlpagmta
                                  ,pr_percmult => vr_percmult
                                  ,pr_txmensal => rw_crapepr.txmensal
                                  ,pr_qttolatr => rw_crapepr.qttolatr
                                  ,pr_vlmrapar => vr_vlmrapar
                                  ,pr_vlmtapar => vr_vlmtapar
								                  ,pr_vliofcpl => vr_vliofcpl
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
                                          
											IF vr_cdcritic > 0 THEN
                          -- se a critica for do produto, verificar se a critica tbem nao é do valor minimo
                          IF vr_dscritic LIKE 'Valor a pagar deve ser maior ou igual que%' THEN
                             vr_vlrmin_prod := to_number(replace(replace(replace(SUBSTR(vr_dscritic, INSTR(vr_dscritic,'R$'),10),'R$',''),',',''),'.',''))/100;
                             IF nvl(pr_vlparepr,0) < vr_vlminpos AND pr_tpparepr = 3 AND
                                vr_vlminpos > vr_vlrmin_prod THEN
                               -- Atribui crítica
                               vr_cdcritic := 0;
                               vr_dscritic := 'Valor do boleto devera ser maior que o valor minimo de R$ ' ||
                                                 to_char(vr_vlminpos,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS = '',.''') || '.';
                               -- Levanta exceção
                               RAISE vr_exc_saida;
                             END IF;

                          END IF;

											END IF;

											-- Zera valor informado
											vr_vlparepr := 0;

										ELSE
											-- Se valor total de pagamento está zerado e
											-- alguma parcela informada ainda não foi processada
											vr_cdcritic := 0;
											vr_dscritic := 'Valor total insuficiente para as parcelas selecionadas.';
											-- Levanta exceção
											RAISE vr_exc_saida;
										END IF;
									END IF;

									EXIT;

								END IF;

							END LOOP;

					    EXIT WHEN vr_tab_parcelas_pos(idx).nrparepr = vr_dsparcel(vr_dsparcel.last);

					END LOOP;

					-- Se valor informado for maior que o valor total a pagar pelas parcelas informadas
					IF pr_vlparepr > vr_vltotpag THEN
						-- Atribui crítica
						vr_cdcritic := 0;
						vr_dscritic := 'Valor informado superior ao valor total das parcelas informadas. '
            || to_char(pr_vlparepr,'fm999g999g990d00') || ' - ' || to_char(vr_vltotpag,'fm999g999g990d00');
						-- Gera exceção
						RAISE vr_exc_saida;
					END IF;

				-- Quitação do contrato POS
				ELSE                              

				  -- Procedure chamada para buscar o valor calculado da parcela
          EMPR0011.pc_busca_pagto_parc_pos(pr_cdcooper => pr_cdcooper
                                          ,pr_cdprogra => 'COBEMP'
                                          ,pr_dtmvtolt => pr_dtvencto
                                          ,pr_dtmvtoan => vr_dtmvtoan
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_nrctremp => pr_nrctremp
                                          ,pr_dtefetiv => rw_crapepr.dtmvtolt
                                          ,pr_cdlcremp => rw_crapepr.cdlcremp
                                          ,pr_vlemprst => rw_crapepr.vlemprst
                                          ,pr_txmensal => rw_crapepr.txmensal
                                          ,pr_dtdpagto => rw_crapepr.dtdpagto
                                          ,pr_vlsprojt => rw_crapepr.vlsprojt
                                          ,pr_qttolatr => rw_crapepr.qttolatr
                                          ,pr_tab_parcelas => vr_tab_parcelas_pos
														              ,pr_tab_calculado => vr_tab_calculado_pos
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
          
          IF pr_cdoperad <> '1' THEN
            -- verificar se o operador existe
            OPEN cr_ope (pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad);
            FETCH cr_ope INTO rw_ope;
            IF cr_ope%NOTFOUND THEN
              CLOSE cr_ope;
              -- Atribui crítica
              vr_cdcritic := 0;
              vr_dscritic := 'Operador nao encontrado.';
              -- Levanta exceção
              RAISE vr_exc_saida;
            ELSE
              CLOSE cr_ope;
            END IF;

            -- se o boleto eh para quitacao do contrato e nao for da central telefonica, criticar...
            IF pr_tpparepr = 4 AND nvl(rw_ope.cddepart,0) IN (3,5,7) AND pr_idarquiv = 0 THEN   --Adicionado CANAIS (SD 548663)
              -- Atribui crítica
              vr_cdcritic := 0;
              vr_dscritic := 'Quitacao do contrado permitido apenas para operadores de CANAIS.';
              -- Levanta exceção
              RAISE vr_exc_saida;
            END IF;

          END IF;
              
          -- somente validar se nao for boletagem
          IF pr_idarquiv = 0 THEN                          

              IF vr_tab_calculado_pos(vr_tab_calculado_pos.first).vlsdeved <> pr_vlparepr THEN
                -- Atribui crítica
                vr_cdcritic := 0;
                vr_dscritic := 'Valor informado para quitacao do emprestimo diferente do saldo devedor do contrato.';
                -- Levanta exceção
                RAISE vr_exc_saida;
              END IF;
             
            -- verificar data de vencto boleto para quitação de contrato POS
            OPEN cr_crappep (pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrctremp => pr_nrctremp);
            FETCH cr_crappep INTO rw_crappep;
            IF cr_crappep%FOUND THEN
              CLOSE cr_crappep;
              IF vr_dtvencto > rw_crappep.dtvencto then
                -- Atribui crítica
                vr_cdcritic := 0;
                vr_dscritic := 'Nao e possivel emitir boleto para o vencimento informado.';
                -- Levanta exceção
                RAISE vr_exc_saida;
              END IF; 
            ELSE
              CLOSE cr_crappep;
            END IF;  
          END IF; -- pr_idarquiv = 0
        END IF; -- pr_tpparepr <> 4   
                
      -- TR
      ELSE
          pc_obtem_dados_tr(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrctremp => pr_nrctremp
                           ,pr_dtmvtolt => pr_dtmvtolt
                           ,pr_nmdatela => pr_nmdatela
                           ,pr_idorigem => pr_idorigem
                           ,pr_cdoperad => pr_cdoperad
                           ,pr_vlsdeved => vr_vlsdeved
                           ,pr_vlatraso => vr_vlatraso
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
  												 
          -- Se retornou alguma crítica
          IF (vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL) THEN
            -- Gerar exceção
            RAISE vr_exc_saida;
          END IF;

          -- Valor minimo para debito dos atrasos das prestacoes
          vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_tptabela => 'GENERI'
                                                   ,pr_cdempres => 0
                                                   ,pr_cdacesso => 'VLMINDEBTO'
                                                   ,pr_tpregist => 0);
          -- Se houver valor
          IF vr_dstextab IS NOT NULL THEN
            -- Converter o valor do parâmetro para number
            vr_vlmindeb := nvl(gene0002.fn_char_para_number(vr_dstextab),0);
          ELSE
            -- Considerar o valor mínimo como zero
            vr_vlmindeb := 0;
          END IF;

          -- Se o valor informado for menor que o valor mínimo permitido
          IF pr_vlparepr < vr_vlmindeb THEN
            -- Montra crítica
            vr_cdcritic := 0;
            vr_dscritic := 'Valor informado inferior ao mínimo permitido.';
            -- Gera exceção
            RAISE vr_exc_saida;
          END IF;

        END IF;
      
      END IF;
      
      IF rw_crapepr.tpemprst = 0 THEN
         -- checar o valor minimo da parcela somente para pagamentos parciais
         IF nvl(pr_vlparepr,0) < vr_vlrmintr AND pr_tpparepr = 3 THEN
           -- Atribui crítica
           vr_cdcritic := 0;
           vr_dscritic := 'Valor do boleto devera ser maior que o valor minimo de R$ ' || 
                          to_char(vr_vlrmintr,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS = '',.''') || '.';
           -- Levanta exceção
           RAISE vr_exc_saida;                   
         END IF;
      END IF;      
      
      IF rw_crapepr.tpemprst = 1 THEN
         -- checar o valor minimo da parcela somente para pagamentos parciais        
         IF nvl(pr_vlparepr,0) < vr_vlrminpp AND pr_tpparepr = 3 THEN
           -- Atribui crítica
           vr_cdcritic := 0;
           vr_dscritic := 'Valor do boleto devera ser maior que o valor minimo de R$ ' || 
                          to_char(vr_vlrminpp,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS = '',.''') || '.';
           -- Levanta exceção
           RAISE vr_exc_saida;                   
         END IF;
      END IF;

      IF rw_crapepr.tpemprst = 2 THEN
         -- checar o valor minimo da parcela somente para pagamentos parciais
         IF nvl(pr_vlparepr,0) < vr_vlminpos AND pr_tpparepr = 3 THEN
           -- Atribui crítica
           vr_cdcritic := 0;
           vr_dscritic := 'Valor do boleto devera ser maior que o valor minimo de R$ ' ||
                          to_char(vr_vlminpos,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS = '',.''') || '.';
           -- Levanta exceção
           RAISE vr_exc_saida;
         END IF;
      END IF;      

      IF pr_nrcpfava = 0 THEN
        -- Dados do Devedor
        vr_cdtpinsc := rw_crapass.inpessoa;
        vr_nrinssac := rw_crapass.nrcpfcgc;
        vr_nmprimtl := rw_crapass.nmprimtl;
        vr_dsendere := rw_crapass.dsendere;
        vr_nmbairro := rw_crapass.nmbairro;
        vr_nrcepend := rw_crapass.nrcepend;
        vr_nmcidade := rw_crapass.nmcidade;
        vr_cdufende := rw_crapass.cdufende;
        vr_nrendere := rw_crapass.nrendere;
        vr_complend := rw_crapass.complend;
      ELSE
        -- Dados do Avalista
        DSCT0002.pc_lista_avalistas(pr_cdcooper => pr_cdcooper  --> Código da Cooperativa
                                   ,pr_cdagenci => rw_crapass.cdagenci --> Código da agencia
                                   ,pr_nrdcaixa => 1            --> Numero do caixa do operador
                                   ,pr_cdoperad => pr_cdoperad  --> Código do Operador
                                   ,pr_nmdatela => pr_nmdatela  --> Nome da tela
                                   ,pr_idorigem => pr_idorigem  --> Identificador de Origem
                                   ,pr_nrdconta => pr_nrdconta  --> Numero da conta do cooperado
                                   ,pr_idseqttl => 1            --> Sequencial do titular
                                   ,pr_tpctrato => 1            --> Emprestimo  
                                   ,pr_nrctrato => pr_nrctremp  --> Numero do contrato
                                   ,pr_nrctaav1 => 0            --> Numero da conta do primeiro avalista
                                   ,pr_nrctaav2 => 0            --> Numero da conta do segundo avalista
                                    --------> OUT <--------                                   
                                   ,pr_tab_dados_avais   => vr_tab_aval   --> retorna dados do avalista
                                   ,pr_cdcritic          => vr_cdcritic   --> Código da crítica
                                   ,pr_dscritic          => vr_dscritic); --> Descrição da crítica
        
        IF nvl(vr_cdcritic,0) > 0 OR 
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        FOR vr_ind_aval IN vr_tab_aval.FIRST..vr_tab_aval.LAST LOOP

          IF pr_nrcpfava = vr_tab_aval(vr_ind_aval).nrcpfcgc THEN
            vr_cdtpinsc := vr_tab_aval(vr_ind_aval).inpessoa;
            vr_nrinssac := vr_tab_aval(vr_ind_aval).nrcpfcgc;
            vr_nmprimtl := vr_tab_aval(vr_ind_aval).nmdavali;
            vr_dsendere := vr_tab_aval(vr_ind_aval).dsendere;
            vr_nmbairro := vr_tab_aval(vr_ind_aval).dsendcmp;
            vr_nrcepend := vr_tab_aval(vr_ind_aval).nrcepend;
            vr_nmcidade := vr_tab_aval(vr_ind_aval).nmcidade;
            vr_cdufende := vr_tab_aval(vr_ind_aval).cdufresd;
            vr_nrendere := vr_tab_aval(vr_ind_aval).nrendere;
            vr_complend := vr_tab_aval(vr_ind_aval).complend;
            EXIT; -- Sai do loop
          END IF;

        END LOOP;

      END IF;

			-- Verificar se existe o registro na crapsab com os dados do cooperado do empréstimo
			OPEN cr_crapsab (pr_cdcooper => pr_cdcooper
			                ,pr_nrctabnf => vr_nrdconta_cob
											,pr_nrinssac => vr_nrinssac);
			FETCH cr_crapsab INTO rw_crapsab;
		  -- Se não encontrou registro, cria
		  IF cr_crapsab%NOTFOUND THEN
				INSERT INTO crapsab (cdcooper,
				                     nrdconta,
														 nrinssac,
														 cdtpinsc,
														 nmdsacad,
														 dsendsac,
														 nmbaisac,
														 nrcepsac,
														 nmcidsac,
														 cdufsaca,
														 cdoperad,
														 hrtransa,
														 dtmvtolt,
														 nrendsac,
														 complend,
														 cdsitsac)
										 VALUES (pr_cdcooper,
										         vr_nrdconta_cob,
														 vr_nrinssac,
														 vr_cdtpinsc,
														 vr_nmprimtl,
														 vr_dsendere,
                             vr_nmbairro,
                             vr_nrcepend,
                             vr_nmcidade,
                             vr_cdufende,
														 pr_cdoperad,
														 GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSSSS')),
														 pr_dtmvtolt,
														 vr_nrendere,
                                 trim(substr(trim(vr_complend),1,40)),
                             1);

			ELSE
				-- Se encontrou, atualiza dados de endereço
				UPDATE crapsab sab
				   SET sab.dsendsac = vr_dsendere,
					     sab.nmbaisac = vr_nmbairro,
							 sab.nrcepsac = vr_nrcepend,
							 sab.nmcidsac = vr_nmcidade,
							 sab.cdufsaca = vr_cdufende
				 WHERE sab.cdcooper = pr_cdcooper
				 	 AND sab.nrdconta = vr_nrdconta_cob
					 AND sab.nrinssac = vr_nrinssac;


			END IF;

			-- Fecha cursor
			CLOSE cr_crapsab;

      vr_dsinform := gene0001.fn_param_sistema(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_cdacesso => 'COBEMP_INSTR_LINHA_1');

      IF rw_crapepr.tpemprst = 1 AND  -- Price Pre-fixado
         pr_tpparepr <> 4        AND  -- 4 = Quitacao do contrato
         pr_dsparepr IS NOT NULL THEN -- Descricao das parcelas 'par1,par2,parN'
         vr_dsinform := vr_dsinform || '  - PARCELA(S): ' || pr_dsparepr;
      END IF;

      vr_dsinform := vr_dsinform || '_' ||
                     gene0001.fn_param_sistema(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_cdacesso => 'COBEMP_INSTR_LINHA_2') || '_' ||
                     gene0001.fn_param_sistema(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_cdacesso => 'COBEMP_INSTR_LINHA_3') || '_' ||
                     gene0001.fn_param_sistema(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_cdacesso => 'COBEMP_INSTR_LINHA_4');
                                              
      vr_dsinform := REPLACE(vr_dsinform, '#CONTA#', gene0002.fn_mask_conta(pr_nrdconta));
      vr_dsinform := REPLACE(vr_dsinform, '#conta#', gene0002.fn_mask_conta(pr_nrdconta));      
      vr_dsinform := REPLACE(vr_dsinform, '#CONTRATO#', to_char(pr_nrctremp));
      vr_dsinform := REPLACE(vr_dsinform, '#contrato#', to_char(pr_nrctremp));      

		  cobr0005.pc_gerar_titulo_cobranca(pr_cdcooper => pr_cdcooper
																			 ,pr_nrdconta => vr_nrdconta_cob
																			 ,pr_nrcnvcob => vr_nrcnvcob
																			 ,pr_nrctremp => pr_nrctremp
																			 ,pr_inemiten => 2
																			 ,pr_cdbandoc => 085
																			 ,pr_cdcartei => 1
																			 ,pr_cddespec => 1
																			 ,pr_nrctasac => pr_nrdconta
																			 ,pr_cdtpinsc => vr_cdtpinsc
																			 ,pr_nrinssac => vr_nrinssac
																			 ,pr_dtmvtolt => pr_dtmvtolt
																			 ,pr_dtdocmto => pr_dtmvtolt
																			 ,pr_dtvencto => vr_dtvencto
																			 ,pr_cdmensag => 0
																			 ,pr_dsdoccop => to_char(pr_nrctremp)
																			 ,pr_vltitulo => pr_vlparepr
                                       ,pr_dsinform => vr_dsinform
--																			 ,pr_dsinform => 'Boleto ref ao contrato ' || to_char(pr_nrctremp) || '_' ||
--																		 									 'Parcela(s): ' || replace(pr_dsparepr,';',',')
																			 ,pr_cdoperad => 1
																			 ,pr_cdcritic => vr_cdcritic
																			 ,pr_dscritic => vr_dscritic
																			 ,pr_tab_cob  => vr_tab_cob);

			-- Se retornou alguma crítica
			IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				 -- Levanta exceção
				 RAISE vr_exc_saida;
			END IF;

      INSERT INTO tbrecup_cobranca (cdcooper
			                           ,nrdconta
																 ,nrctremp
																 ,nrdconta_cob
																 ,nrcnvcob
																 ,nrboleto
																 ,dsparcelas
																 ,dhtransacao
																 ,tpenvio
																 ,tpparcela
																 ,cdoperad
                                 ,nrcpfava
                                 ,idarquivo
                                 ,idboleto
                                 ,peracrescimo
                                 ,perdesconto
                                 ,vldesconto
                                 ,vldevedor
                                 ,cdcanal)
													VALUES(pr_cdcooper
													      ,pr_nrdconta
																,pr_nrctremp
																,vr_nrdconta_cob
																,vr_nrcnvcob
																,vr_tab_cob(1).nrdocmto
																,pr_dsparepr
																,SYSDATE
																,0
																,pr_tpparepr
																,pr_cdoperad
                                ,pr_nrcpfava
                                ,pr_idarquiv
                                ,pr_idboleto
                                ,pr_peracres
                                ,pr_perdesco
                                ,pr_vldescto
                                ,pr_vldevedor
                                ,pr_idorigem);

		  -- Gera log na lgm
			gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
				                   pr_cdoperad => pr_cdoperad,
													 pr_dscritic => '',
													 pr_dsorigem => vr_dsorigem,
													 pr_dstransa => 'Geracao de boleto contrato',
													 pr_dttransa => TRUNC(SYSDATE),
													 pr_flgtrans => 1,
													 pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSSSS')),
													 pr_idseqttl => 0,
													 pr_nmdatela => pr_nmdatela,
													 pr_nrdconta => pr_nrdconta,
													 pr_nrdrowid => vr_nrdrowid);

		  -- Contrato
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Contrato',
																pr_dsdadant => '',
																pr_dsdadatu => pr_nrctremp);
			-- Tipo de parcela
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Tipo de parcela',
																pr_dsdadant => '',
																pr_dsdadatu => pr_tpparepr);

			IF pr_dsparepr IS NOT NULL THEN
				-- Parcelas
				gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																	pr_nmdcampo => 'Parcelas',
																	pr_dsdadant => '',
																	pr_dsdadatu => pr_dsparepr);
			END IF;

			-- Data do vencimento
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Data do vencimento',
																pr_dsdadant => '',
																pr_dsdadatu => TO_CHAR(vr_dtvencto, 'DD/MM/RRRR'));

			-- Valor do Boleto
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Vlr do boleto',
																pr_dsdadant => '',
																pr_dsdadatu => to_char(pr_vlparepr, 'fm999g999g990d00', 'NLS_NUMERIC_CHARACTERS = '',.'''));

      -- Cria log de cobrança
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => vr_tab_cob(1).rowidcob,
                                    pr_cdoperad => pr_cdoperad,
                                    pr_dtmvtolt => trunc(SYSDATE),
                                    pr_dsmensag => 'Titulo referente ao contrato ' || to_char(pr_nrctremp),
                                    pr_des_erro => vr_des_erro,
                                    pr_dscritic => vr_dscritic);

			-- Commita alterações
			COMMIT;

		EXCEPTION
		  WHEN vr_exc_saida THEN
				-- Se possui código de crítica e não foi informado a descrição
				IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					 -- Busca descrição da crítica
					 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
				END IF;


				-- Atribui exceção para os parametros de crítica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;

        ROLLBACK;
			WHEN OTHERS THEN
				-- Atribui exceção para os parametros de crítica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := 'Erro nao tratado na EMPR0007.pc_gera_boleto_contrato: ' || SQLERRM;
        ROLLBACK;

	  END;

	END pc_gera_boleto_contrato;

	PROCEDURE pc_gera_boleto_contrato_web(pr_nrdconta IN  crapcob.nrdconta%TYPE  --> Nr. da Conta
																			 ,pr_nrctremp IN  crapcob.nrctremp%TYPE  --> Número do contrato de empréstimo;
																			 ,pr_dtmvtolt IN  VARCHAR2               --> Data do movimento;
																			 ,pr_tpparepr IN  NUMBER                 --> Tipo de parcela 1 = Parcela Normal, 2 = Total do atraso 3 = Parcial do atraso 4 = Quitação do contrato;
																			 ,pr_dsparepr IN  VARCHAR2 DEFAULT NULL  /* Descrição das parcelas do empréstimo “par1;par2;par...; parN”;
																																									Obs: empréstimo TR => NULL;
																																									Obs2: Quando for ref a várias parcelas do contrato, parcela = NULL;
																																									Obs3: Quando for quitação do contrato, parcela = 0; */
																			 ,pr_dtvencto IN  VARCHAR2              --> Vencimento do boleto;
																			 ,pr_vlparepr IN  VARCHAR2              --> Valor da parcela;
                                       ,pr_nrcpfava IN  NUMBER                --> CPF do avalista
																			 ,pr_xmllog   IN  VARCHAR2              --> XML com informações de LOG
																			 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																			 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																			 ,pr_retxml   IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
																			 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																			 ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
	/* .............................................................................

      Programa: pc_gera_boleto_contrato_web
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Lucas Reinert
      Data    : Agosto/15.                    Ultima atualizacao: 02/03/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina para gerar boletos de contratos para WEB

      Observacao: -----

      Alteracoes: 02/03/2017 - Inclusao pr_nrcpfava. (P210.2 - Jaison/Daniel)
  ..............................................................................*/
	BEGIN
		DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;        --> Cód. Erro
      vr_dscritic VARCHAR2(1000);               --> Desc. Erro

		  -- Tratamento de erros
		  vr_exc_saida EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

		BEGIN

			pr_des_erro := 'OK';
			-- Extrai dados do xml
			gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
															 pr_cdcooper => vr_cdcooper,
															 pr_nmdatela => vr_nmdatela,
															 pr_nmeacao  => vr_nmeacao,
															 pr_cdagenci => vr_cdagenci,
															 pr_nrdcaixa => vr_nrdcaixa,
															 pr_idorigem => vr_idorigem,
															 pr_cdoperad => vr_cdoperad,
															 pr_dscritic => vr_dscritic);

			-- Se retornou alguma crítica
			IF trim(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

      pc_gera_boleto_contrato (pr_cdcooper => vr_cdcooper
															,pr_nrdconta => pr_nrdconta
															,pr_nrctremp => pr_nrctremp
															,pr_dtmvtolt => to_date(pr_dtmvtolt,'DD/MM,YYYY')
															,pr_tpparepr => GENE0002.fn_char_para_number(pr_tpparepr)
															,pr_dsparepr => pr_dsparepr
															,pr_dtvencto => to_date(pr_dtvencto,'DD/MM,YYYY')
															,pr_vlparepr => GENE0002.fn_char_para_number(pr_vlparepr)
															,pr_cdoperad => vr_cdoperad
															,pr_nmdatela => vr_nmdatela
														  ,pr_idorigem => vr_idorigem
                              ,pr_nrcpfava => pr_nrcpfava
															,pr_cdcritic => vr_cdcritic
											        ,pr_dscritic => vr_dscritic);

			-- Se retornou alguma crítica
			IF vr_cdcritic <> 0 OR
				 trim(vr_dscritic) IS NOT NULL THEN
				 -- Levanta exceção
			   RAISE vr_exc_saida;
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

			  pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
			  pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
	END pc_gera_boleto_contrato_web;
	
	PROCEDURE pc_verifica_gerar_boleto (pr_cdcooper IN crapcop.cdcooper%TYPE                   --> Cód. cooperativa
                                     ,pr_nrctacob IN crapass.nrdconta%TYPE                   --> Nr. da Conta Cob.
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE                   --> Nr. da Conta
																		 ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE                   --> Nr. do Convênio de Cobrança
																	 	 ,pr_nrctremp IN crapcob.nrctremp%TYPE                   --> Nr. do Contrato
																		 ,pr_idarquiv IN tbrecup_boleto_arq.idarquivo%TYPE DEFAULT 0 --> Nr. do Arquivo (<> 0 = boletagem massiva)
                                     ,pr_cdcritic OUT PLS_INTEGER                            --> Código da crítica
																		 ,pr_dscritic OUT VARCHAR2                               --> Descrição da crítica
                                     ,pr_des_erro OUT VARCHAR2) IS                           --> Erros do proc esso
		BEGIN
	 	  /* .............................................................................

      Programa: pc_verifica_gerar_boleto
      Sistema : CECRED
      Sigla   : TELA
      Autor   : Lucas Reinert
      Data    : Agosto/15.                    Ultima atualizacao: 30/03/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina para validação da utilização da rotina "Gerar Boleto"

      Observacao: -----

      Alteracoes: 07/03/2017 - Remocao de regra para nao permitir geracao de boleto
                               para contratos em prejuizo. (P210.2 - Jaison/Daniel)
                               
                  30/03/2017 - Adicionado novo parametro pr_idarquiv para permitir 
                               geracao de boleto para contratos em prejuizo
                               quando for boletagem massiva. (P210.2 - Lombardi)
    ..............................................................................*/
		DECLARE
		  -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; -- Cód. crítica
      vr_dscritic VARCHAR2(10000);       -- Desc. crítica

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

			-- Variaveis locais
			vr_qtmaxbol INTEGER;
			vr_qtbolnpg INTEGER;
      vr_dtconsec DATE;
			vr_blqemico VARCHAR2(10);
			vr_dtultpgt DATE;
		  vr_blqemico_split   gene0002.typ_split;
      vr_inusatab     BOOLEAN;                --> Indicador S/N de utilização de tabela de juros      
      vr_parempct craptab.dstextab%TYPE := '';      			      
      vr_qtregist INTEGER := 0;      
      vr_tab_dados_epr empr0001.typ_tab_dados_epr;
      vr_des_reto VARCHAR2(3);
      vr_tab_erro gene0001.typ_tab_erro;      
      vr_dstextab     craptab.dstextab%TYPE;  --> Busca na craptab      
      vr_digitali craptab.dstextab%TYPE := '';     
      
      -- Variáveis TR
      vr_vlsdeved crapepr.vlsdeved%TYPE;
      vr_vlatraso crapepr.vlsdeved%TYPE;
      
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;      
      
			--------------------------- CURSORES --------------------------------------
			-- Cursor para verificar se existe algum boleto em aberto
			CURSOR cr_crapcob (pr_cdcooper IN crapcob.cdcooper%TYPE
                        ,pr_nrdconta IN crapcob.nrdconta%TYPE
                        ,pr_nrctremp IN crapcob.nrctremp%TYPE) IS
          SELECT 1
            FROM crapcob cob
           WHERE cob.cdcooper = pr_cdcooper
             AND cob.incobran = 0
             AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac, cob.nrctremp, cob.nrdocmto) IN 
                 (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta, nrctremp, nrboleto
                    FROM tbrecup_cobranca cde
                   WHERE cde.cdcooper = pr_cdcooper
                     AND cde.nrdconta = pr_nrdconta
                     AND cde.nrctremp = pr_nrctremp);
			rw_crapcob cr_crapcob%ROWTYPE;
      
			-- Cursor para verificar se existe algum boleto pago pendente de processamento
			CURSOR cr_crapret (pr_cdcooper IN crapcob.cdcooper%TYPE
                        ,pr_nrdconta IN crapcob.nrdconta%TYPE
                        ,pr_nrctremp IN crapcob.nrctremp%TYPE
                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
          SELECT 1
            FROM crapcob cob, crapret ret
           WHERE cob.cdcooper = pr_cdcooper
             AND cob.incobran = 5
             AND cob.dtdpagto = pr_dtmvtolt
             AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac, cob.nrctremp, cob.nrdocmto) IN 
                 (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta, nrctremp, nrboleto
                    FROM tbrecup_cobranca cde
                   WHERE cde.cdcooper = pr_cdcooper
                     AND cde.nrdconta = pr_nrdconta
                     AND cde.nrctremp = pr_nrctremp)
             AND ret.cdcooper = cob.cdcooper
             AND ret.nrdconta = cob.nrdconta
             AND ret.nrcnvcob = cob.nrcnvcob
             AND ret.nrdocmto = cob.nrdocmto
             AND ret.dtocorre = cob.dtdpagto
             AND ret.cdocorre = 6
             AND ret.flcredit = 0;
			rw_crapret cr_crapret%ROWTYPE;      

		  -- Busca os convernios de emprestimo da cooperativa
		  CURSOR cr_crapprm (pr_cdcooper IN crapcop.cdcooper%TYPE
			                  ,pr_cdacesso IN crapprm.cdacesso%TYPE)IS
			  SELECT prm.dsvlrprm
				  FROM crapprm prm
				 WHERE prm.cdcooper = pr_cdcooper
				 	 AND prm.nmsistem = 'CRED'
					 AND prm.cdacesso = pr_cdacesso;

		  -- Buscar a quantidade de boletos nao pagos a partir da última data de pagto
			CURSOR cr_crapcob_bnp (pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_nrdconta IN crapass.nrdconta%TYPE
                            ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT COUNT(*) qtbolbnp,
               MIN(dtdbaixa) dtminbai, 
               MAX(dtdbaixa) dtmaxbai
          FROM crapcob cob
         WHERE cob.cdcooper = pr_cdcooper
           AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac, cob.nrctremp) IN 
               (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta, nrctremp
                  FROM tbrecup_cobranca cde
                 WHERE cde.cdcooper = pr_cdcooper
                   AND cde.nrdconta = pr_nrdconta
                   AND cde.nrctremp = pr_nrctremp)
           AND cob.incobran = 3
           AND cob.dtdbaixa >= nvl(nvl((SELECT MAX(cob.dtdpagto) -- 1) buscar pelo ultimo pagamento
                                      FROM crapcob cob
                                     WHERE cob.cdcooper = pr_cdcooper
                                       AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac, cob.nrctremp) IN 
                                           (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta, nrctremp
                                              FROM tbrecup_cobranca cde
                                             WHERE cde.cdcooper = pr_cdcooper
                                               AND cde.nrdconta = pr_nrdconta
                                               AND cde.nrctremp = pr_nrctremp)                                   
                                       AND cob.dtdpagto IS NOT NULL
                                       AND cob.incobran = 5),
                                       (SELECT MAX(cob.dtdbaixa) -- 2) buscar pela ultima baixa
                                          FROM crapcob cob
                                         WHERE cob.cdcooper = pr_cdcooper
                                           AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac, cob.nrctremp) IN 
                                               (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta, nrctremp
                                                  FROM tbrecup_cobranca cde
                                                 WHERE cde.cdcooper = pr_cdcooper
                                                   AND cde.nrdconta = pr_nrdconta
                                                   AND cde.nrctremp = pr_nrctremp)                                   
                                           AND cob.dtdbaixa IS NOT NULL 
                                           AND cob.incobran = 3)),(SELECT epr.dtmvtolt FROM crapepr epr --3) se nao encontrar nenhum dos dois, entao buscar pela data do emprestimo
                                                                  WHERE epr.cdcooper = pr_cdcooper
                                                                    AND epr.nrdconta = pr_nrdconta
                                                                    AND epr.nrctremp = pr_nrctremp));
      rw_crapcob_bnp cr_crapcob_bnp%ROWTYPE;                                                                         

			-- Cursor para buscar a data do último boleto pago
			CURSOR cr_crapcob_ubp (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
          SELECT MAX(cob.dtdpagto)
            FROM crapcob cob
           WHERE cob.cdcooper = pr_cdcooper
             AND cob.incobran = 5
             AND cob.dtdpagto IS NOT NULL
             AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac, cob.nrctremp) IN 
                 (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta, nrctremp
                    FROM tbrecup_cobranca cde
                   WHERE cde.cdcooper = pr_cdcooper
                     AND cde.nrdconta = pr_nrdconta
                     AND cde.nrctremp = pr_nrctremp);      
                     
      -- cursor Contrato
      CURSOR cr_epr (pr_cdcooper IN crapepr.cdcooper%TYPE
                    ,pr_nrdconta IN crapepr.nrdconta%TYPE
                    ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT epr.inprejuz,
               epr.tpemprst,
               epr.flgpagto,
               epr.dtmvtolt,
               epr.tpdescto
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp;
      rw_epr cr_epr%ROWTYPE;
           
      -- cursor Cyber - ativos
      CURSOR cr_cyb (pr_cdcooper IN crapcyb.cdcooper%TYPE
                    ,pr_nrdconta IN crapcyb.nrdconta%TYPE
                    ,pr_nrctremp IN crapcyb.nrctremp%TYPE) IS
        SELECT 1 flgativo FROM crapcyb cyb
         WHERE cyb.cdcooper = pr_cdcooper
           AND cyb.nrdconta = pr_nrdconta
           AND cyb.nrctremp = pr_nrctremp
           AND cyb.cdorigem IN (2,3)
           AND cyb.dtdbaixa IS NULL;
      rw_cyb cr_cyb%ROWTYPE;
      
      -- cursor Cyber - Judicial, Extrajudicial ou VIP
      CURSOR cr_cyc (pr_cdcooper IN crapcyc.cdcooper%TYPE
                    ,pr_nrdconta IN crapcyc.nrdconta%TYPE
                    ,pr_nrctremp IN crapcyc.nrctremp%TYPE) IS
        SELECT flgjudic,
               flextjud,
               flgehvip 
          FROM crapcyc cyc
         WHERE cyc.cdcooper = pr_cdcooper
           AND cyc.nrdconta = pr_nrdconta
           AND cyc.nrctremp = pr_nrctremp
           AND cyc.cdorigem = 3;
      rw_cyc cr_cyc%ROWTYPE;

		BEGIN
	    -- Verifica se existe algum boleto em aberto
		  OPEN cr_crapcob(pr_cdcooper, pr_nrdconta, pr_nrctremp);
			FETCH cr_crapcob INTO rw_crapcob;

			-- Existe boleto em aberto
			IF cr_crapcob%FOUND THEN
				-- Atribui crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Existe um boleto em aberto para este contrato. Favor aguardar regularizacao.';
        -- Fecha cursor
				CLOSE cr_crapcob;
				-- Levanta exceção
				RAISE vr_exc_saida;
      END IF;
      -- Fecha cursor
			CLOSE cr_crapcob;
      
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_saida;
      END IF;
      CLOSE btch0001.cr_crapdat;      

	    -- Verifica se existe algum boleto pago pendente de processamento
		  OPEN cr_crapret(pr_cdcooper, pr_nrdconta, pr_nrctremp, rw_crapdat.dtmvtolt );
			FETCH cr_crapret INTO rw_crapret;

			-- Existe boleto Pago pendente de processamento
			IF cr_crapret%FOUND THEN
				-- Atribui crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Existe um boleto pago pendente de processamento. Favor aguardar lancamento no proximo dia util.';
        -- Fecha cursor
				CLOSE cr_crapret;
				-- Levanta exceção
				RAISE vr_exc_saida;
      END IF;
      -- Fecha cursor
			CLOSE cr_crapret;      

			-- Busca quantidade máxima de boletos emitidos por contrato da cooperativa
		  OPEN cr_crapprm(pr_cdcooper
			               ,'COBEMP_QTD_MAX_BOL_EPR');
			FETCH cr_crapprm INTO vr_qtmaxbol;
			CLOSE cr_crapprm;

			-- Busca a quantidade de boletos emitidos nao pagos após o último boleto pago do contrato
			OPEN cr_crapcob_bnp(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrctremp => pr_nrctremp);
			FETCH cr_crapcob_bnp INTO rw_crapcob_bnp;
			-- Fecha cursor
			CLOSE cr_crapcob_bnp;

			IF vr_qtmaxbol <= rw_crapcob_bnp.qtbolbnp THEN
				-- Atribui crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Foi atingido a quantidade maxima (' || vr_qtmaxbol || ') de boletos emitidos para este contrato.';
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

 			-- Busca quantidade máxima de boletos emitidos por contrato da cooperativa
		  OPEN cr_crapprm(pr_cdcooper
			               ,'COBEMP_BLQ_EMI_CONSEC');
			FETCH cr_crapprm INTO vr_blqemico;
			CLOSE cr_crapprm;

			-- Divide a String para atribuir os dias e boletos na variavel (XX;YY)
		  vr_blqemico_split := gene0002.fn_quebra_string(pr_string  => vr_blqemico
		                                                 ,pr_delimit => ';');

			-- Busca a data do último boleto pago
			OPEN cr_crapcob_ubp (pr_cdcooper);
			FETCH cr_crapcob_ubp INTO vr_dtultpgt;
      
      OPEN cr_epr (pr_cdcooper => pr_cdcooper
                  ,pr_nrdconta => pr_nrdconta
                  ,pr_nrctremp => pr_nrctremp);
      FETCH cr_epr INTO rw_epr;
      CLOSE cr_epr;      

      vr_dtconsec := nvl(rw_crapcob_bnp.dtmaxbai,rw_epr.dtmvtolt) + TO_NUMBER(vr_blqemico_split(1));
      
      -- Verifica a quantidade de boletos emitidos e não pagos dentro do prazo para emissão de novos boletos
			IF vr_dtconsec > rw_crapdat.dtmvtolt AND
				 to_number(vr_blqemico_split(2)) <= nvl(rw_crapcob_bnp.qtbolbnp,0) THEN
 				-- Atribui crítica
				vr_cdcritic := 0;
        vr_dscritic := 'Favor aguardar ' || to_char(vr_dtconsec - rw_crapdat.dtmvtolt)
				            || ' dias para emissao de um novo boleto.';
				-- Levanta exceção
				RAISE vr_exc_saida;
 		  END IF;

      -- Nao eh permitido gerar boleto para contratos Debito em Folha 
      IF nvl(rw_epr.flgpagto,0) = 1 THEN
        -- Atribui crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Nao e permitido gerar boleto de contratos Debito em Folha.';
        -- Levanta exceção
        RAISE vr_exc_saida;              
      END IF;      
      
      -- Nao eh permitido gerar boleto para contratos Consignados 
      IF nvl(rw_epr.flgpagto,0) = 0 AND 
         nvl(rw_epr.tpdescto,0) = 2 THEN
        -- Atribui crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Nao e permitido gerar boleto de contratos Consignados.';
        -- Levanta exceção
        RAISE vr_exc_saida;              
      END IF;      
      
      -- verificar se o contrato esta ativo no Cyber
      OPEN cr_cyb (pr_cdcooper => pr_cdcooper
                  ,pr_nrdconta => pr_nrdconta
                  ,pr_nrctremp => pr_nrctremp);
      FETCH cr_cyb INTO rw_cyb;
      CLOSE cr_cyb;
      
      IF nvl(rw_cyb.flgativo,0) = 1 THEN
         
         -- verificar que tipo contrato esta no Cyber
         OPEN cr_cyc (pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
         FETCH cr_cyc INTO rw_cyc;

         IF cr_cyc%FOUND THEN
           
            CLOSE cr_cyc;            
            
            IF nvl(rw_cyc.flgjudic,0) = 1 AND pr_idarquiv = 0 THEN
              -- Atribui crítica
              vr_cdcritic := 0;
              vr_dscritic := 'Nao e permitido gerar boleto de contratos em Cobranca Judicial.';
              -- Levanta exceção
              RAISE vr_exc_saida;              
            END IF;
            
            IF nvl(rw_cyc.flextjud,0) = 1 AND pr_idarquiv = 0 THEN
              -- Atribui crítica
              vr_cdcritic := 0;
              vr_dscritic := 'Nao e permitido gerar boleto de contratos em Cobranca Extrajudicial.';
              -- Levanta exceção
              RAISE vr_exc_saida;              
            END IF;
            
            IF nvl(rw_cyc.flgehvip,0) = 1 THEN
              -- Atribui crítica
              vr_cdcritic := 0;
              vr_dscritic := 'Nao e permitido gerar boleto de contratos VIP.';
              -- Levanta exceção
              RAISE vr_exc_saida;              
            END IF;                       
         ELSE
           CLOSE cr_cyc;                             
         END IF;        
      
      END IF;
            
      -- Leitura do indicador de uso da tabela de taxa de juros
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'TAXATABELA'
                                               ,pr_tpregist => 0);
      -- Se encontrar
      IF vr_dstextab IS NOT NULL THEN
        -- Se a primeira posição do campo
        -- dstextab for diferente de zero
        IF SUBSTR(vr_dstextab,1,1) != '0' THEN
          -- É porque existe tabela parametrizada
          vr_inusatab := TRUE;
        ELSE
          -- Não existe
          vr_inusatab := FALSE;
        END IF;
      ELSE
        -- Não existe
        vr_inusatab := FALSE;
      END IF;      
      
      -- Leitura do indicador de uso da tabela de taxa de juros                                                    
      vr_parempct := tabe0001.fn_busca_dstextab(pr_cdcooper => 3 /*Fixo Cecred*/
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'PAREMPCTL'
                                               ,pr_tpregist => 1);       
                                               
			-- busca o tipo de documento GED    
      vr_digitali := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'DIGITALIZA'
                                               ,pr_tpregist => 5);                                               
      
      -- Busca saldo total de emprestimos
      EMPR0001.pc_obtem_dados_empresti(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                      ,pr_cdagenci => 1                   --> Código da agência
                                      ,pr_nrdcaixa => 1                   --> Número do caixa
                                      ,pr_cdoperad => '1'                 --> Código do operador
                                      ,pr_nmdatela => 'COBEMP'            --> Nome datela conectada
                                      ,pr_idorigem => 2                   --> Indicador da origem da chamada
                                      ,pr_nrdconta => pr_nrdconta         --> Conta do associado
                                      ,pr_idseqttl => 1 -- pr_idseqttl         --> Sequencia de titularidade da conta
                                      ,pr_rw_crapdat => rw_crapdat        --> Vetor com dados de parâmetro (CRAPDAT)
                                      ,pr_dtcalcul => NULL                --> Data solicitada do calculo
                                      ,pr_nrctremp => pr_nrctremp         --> Número contrato empréstimo
                                      ,pr_cdprogra => 'COBEMP'            --> Programa conectado
                                      ,pr_inusatab => vr_inusatab         --> Indicador de utilização da tabela
                                      ,pr_flgerlog => 'N'                 --> Gerar log S/N
                                      ,pr_flgcondc => FALSE               --> Mostrar emprestimos liquidados sem prejuizo
                                      ,pr_nmprimtl => ' ' --rw_crapass.nmprimtl --> Nome Primeiro Titular
                                      ,pr_tab_parempctl => vr_parempct    --> Dados tabela parametro
                                      ,pr_tab_digitaliza => vr_digitali   --> Dados tabela parametro
                                      ,pr_nriniseq => 0                   --> Numero inicial paginacao
                                      ,pr_nrregist => 0                   --> Qtd registro por pagina
                                      ,pr_qtregist => vr_qtregist         --> Qtd total de registros
                                      ,pr_tab_dados_epr => vr_tab_dados_epr  --> Saida com os dados do empréstimo
                                      ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro);       --> Tabela com possíves erros

      --Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        --Se tem erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_dscritic:= 'Nao foi possivel concluir a requisicao';
        END IF;
        --Sair com erro
        RAISE vr_exc_saida;
      END IF;

      IF nvl(rw_epr.inprejuz,0) = 0 THEN

        IF nvl(vr_tab_dados_epr(1).vltotpag,0) = 0 THEN
          -- Atribui crítica
          vr_cdcritic := 0;
          vr_dscritic := 'Nao e permitido gerar boleto de contratos em dia.';
          -- Levanta exceção
          RAISE vr_exc_saida;
        END IF;

      ELSE

        IF nvl(vr_tab_dados_epr(1).vlsdprej,0) = 0 THEN
          -- Atribui crítica
          vr_cdcritic := 0;
          vr_dscritic := 'Nao e permitido gerar boleto de contratos em dia.';
          -- Levanta exceção
          RAISE vr_exc_saida; 
        END IF;

      END IF;

			pr_des_erro := 'OK';

		EXCEPTION
			WHEN vr_exc_saida THEN
				-- Se possui código de crítica e não foi informado a descrição
				IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					 -- Busca descrição da crítica
				   vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			  END IF;

        -- Atribui exceção para os parametros de crítica
				pr_des_erro := 'NOK';
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;

			WHEN OTHERS THEN

        -- Atribui exceção para os parametros de crítica
				pr_des_erro := 'NOK';
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := 'Erro nao tratado na EMPR0007.pc_verifica_gerar_boleto: ' || SQLERRM;
		END;
	END pc_verifica_gerar_boleto;

	PROCEDURE pc_inst_baixa_boleto_epr(pr_cdcooper IN crapepr.cdcooper%TYPE         --> Cód. cooperativa
																		,pr_nrdconta IN crapepr.nrdconta%TYPE         --> Nr. da conta
																		,pr_nrctremp IN crapepr.nrctremp%TYPE         --> Nr. contrato de empréstiomo
																		,pr_nrctacob IN crapepr.nrdconta%TYPE         --> Nr. da conta cobrança
																		,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE         --> Nr. convenio
																		,pr_nrdocmto IN crapcob.nrdocmto%TYPE         --> Nr. documento
																		,pr_dtmvtolt IN crapepr.dtmvtolt%TYPE         --> Data de movimento
																		,pr_idorigem IN INTEGER                       --> Id origem
																		,pr_cdoperad IN crapcob.cdoperad%TYPE         --> Cód. operador
																		,pr_nmdatela IN VARCHAR2                      --> Nome da tela
																		,pr_cdcritic OUT crapcri.cdcritic%TYPE        --> Cód. da crítica
																		,pr_dscritic OUT crapcri.dscritic%TYPE) IS    --> Descrição da crítica
	BEGIN																		
	/* .............................................................................

      Programa: pc_inst_baixa_boleto_epr
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Lucas Reinert
      Data    : Setembro/15.                    Ultima atualizacao: 08/12/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina para realizar a instrução de baixa de boleto utilizados 
			            para empréstimo

      Observacao: -----

      Alteracoes: 20/01/2016 - Alterado a chamada da procedure pc_inst_pedido_baixa da 
                               PAGA0001 para COBR0007 (Douglas - Importacao de Arquivo CNAB)

                  08/12/2017 - Inclusão de chamada da npcb0002.pc_libera_sessao_sqlserver_npc
                               (SD#791193 - AJFink)

  ..............................................................................*/																								
		DECLARE
		
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;        --> Cód. Erro
      vr_dscritic VARCHAR2(1000);               --> Desc. Erro
			vr_des_erro VARCHAR(3);                   --> Retorno da procedure
		
		  -- Tratamento de erros
		  vr_exc_saida EXCEPTION;			
			
			-- Pl/Table utilizada na procedure de baixa
			vr_tab_lat_consolidada paga0001.typ_tab_lat_consolidada;

      -- Variáveis locais
			vr_dsorigem VARCHAR2(1000) := TRIM(GENE0001.vr_vet_des_origens(pr_idorigem));
 			vr_dstransa VARCHAR2(1000) := 'Boleto baixado pela tela COBEMP';
			vr_nrdrowid ROWID;
      --------------------------------- CURSORES --------------------------------
      -- Cursor para verificar se operador tem acesso a opção de baixa da tela
			CURSOR cr_crapace IS
			  SELECT 1
				  FROM crapace ace
				 WHERE ace.cdcooper = pr_cdcooper
				   AND UPPER(ace.cdoperad) = UPPER(pr_cdoperad)
           AND UPPER(ace.nmdatela) = 'COBEMP'
					 AND ace.idambace = 2     
					 AND UPPER(ace.cddopcao) = 'B';
			rw_crapace cr_crapace%ROWTYPE;					 					 
			
			-- Cursor para verificar se o boleto está em aberto
			CURSOR cr_crapcob IS
			  SELECT cob.incobran
				      ,cob.dtvencto
							,cob.vltitulo
				      ,cob.rowid
				    ,epr.tpemprst
				    ,cde.cdcanal
				  FROM crapcob cob,
			         tbrecup_cobranca cde,
				     crapepr epr
				 WHERE cob.cdcooper = pr_cdcooper
				   AND cob.nrdconta = pr_nrctacob
					 AND cob.nrcnvcob = pr_nrcnvcob
					 AND cob.nrdocmto = pr_nrdocmto
					 AND cde.cdcooper = cob.cdcooper
					 AND cde.nrdconta_cob = cob.nrdconta
					 AND cde.nrcnvcob = cob.nrcnvcob
				 AND cde.nrboleto = cob.nrdocmto
				 AND epr.cdcooper = cob.cdcooper
				 AND epr.nrdconta = cob.nrctasac
				 AND epr.nrctremp = cob.nrctremp;
			rw_crapcob cr_crapcob%ROWTYPE;

		BEGIN
            IF pr_idorigem = 21 THEN
				vr_dstransa := 'Boleto cancelado atraves do sistema Cyber';
            END IF;

      OPEN cr_crapace;
			FETCH cr_crapace INTO rw_crapace;
			
			IF cr_crapace%NOTFOUND AND pr_cdoperad <> '1' AND pr_idorigem <> 21 THEN
				-- Atribui crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Operacao nao permitida';
				-- Gera exceção
				RAISE vr_exc_saida;
			END IF;
			
			OPEN cr_crapcob;
			FETCH cr_crapcob INTO rw_crapcob;
			
			IF cr_crapcob%FOUND THEN
   			-- Fecha cursor
			  CLOSE cr_crapcob;
        
				IF rw_crapcob.incobran = 3 THEN
   				-- Atribui crítica
					vr_cdcritic := 0;
					vr_dscritic := 'Boleto ja foi baixado.';					
					-- Gera exceção
					RAISE vr_exc_saida;
				ELSIF rw_crapcob.incobran = 5 THEN
   				-- Atribui crítica
					vr_cdcritic := 0;
					vr_dscritic := 'Boleto ja foi liquidado.';
					-- Gera exceção
					RAISE vr_exc_saida;
				END IF;
				
				IF pr_idorigem != 21 AND 
           rw_crapcob.cdcanal <> pr_idorigem AND
				   rw_crapcob.tpemprst IN (0,1)
				THEN
				-- Atribui crítica
					vr_cdcritic := 0;
					vr_dscritic := 'Nao e permitido cancelar boletos que nao foram gerados no Aimaro.';
					-- Gera exceção
					RAISE vr_exc_saida;
				END IF;
				
				-- Efetua baixa
				COBR0007.pc_inst_pedido_baixa(pr_idregcob => rw_crapcob.rowid
				                             ,pr_cdocorre => 0
																		 ,pr_dtmvtolt => pr_dtmvtolt
																		 ,pr_cdoperad => pr_cdoperad
																		 ,pr_nrremass => 0
																		 ,pr_tab_lat_consolidada => vr_tab_lat_consolidada
																		 ,pr_cdcritic => vr_cdcritic
																		 ,pr_dscritic => vr_dscritic);
				-- Se retornou alguma crítica							 
		    IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
					RAISE vr_exc_saida;
				END IF;
				
		    -- Gera log na lgm
			  gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
														 pr_cdoperad => pr_cdoperad,
														 pr_dscritic => '',
														 pr_dsorigem => vr_dsorigem,
														 pr_dstransa => vr_dstransa,
														 pr_dttransa => TRUNC(SYSDATE),
														 pr_flgtrans => 1,
														 pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSSSS')),
														 pr_idseqttl => 0,
														 pr_nmdatela => pr_nmdatela,
														 pr_nrdconta => pr_nrdconta,
														 pr_nrdrowid => vr_nrdrowid);

				-- Gera log de itens
				-- Nr. do contrato														 
				gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																	pr_nmdcampo => 'Contrato',
																	pr_dsdadant => '',
																	pr_dsdadatu => pr_nrctremp);
				-- Nr. do Boleto
				gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																	pr_nmdcampo => 'Nr. do Boleto',
																	pr_dsdadant => '',
																	pr_dsdadatu => pr_nrdocmto);
				-- Vencimento
				gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																	pr_nmdcampo => 'Vencimento',
																	pr_dsdadant => '',
																	pr_dsdadatu => TO_CHAR(rw_crapcob.dtvencto, 'DD/MM/RRRR'));
				-- Valor do Boleto
				gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																	pr_nmdcampo => 'Vlr do boleto',
																	pr_dsdadant => '',
																	pr_dsdadatu => to_char(rw_crapcob.vltitulo, 'fm999g999g990d00', 'NLS_NUMERIC_CHARACTERS = '',.'''));
																	
   			-- Cria log de cobrança
				PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid,
																			pr_cdoperad => pr_cdoperad,
																			pr_dtmvtolt => trunc(SYSDATE),
																			pr_dsmensag => vr_dstransa,
																			pr_des_erro => vr_des_erro,
																			pr_dscritic => vr_dscritic);

				-- Se retornou algum erro
				IF vr_des_erro <> 'OK' AND
					 trim(vr_dscritic) IS NOT NULL THEN
					 -- Levanta exceção
					 RAISE vr_exc_saida;
				END IF;

				COMMIT;
                npcb0002.pc_libera_sessao_sqlserver_npc('EMPR0007_1');
				
			ELSE
				-- Fecha cursor
				CLOSE cr_crapcob;
				-- Atribui crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Boleto nao encontrado';
				-- Gera exceção
				RAISE vr_exc_saida;
			END IF;
			
		EXCEPTION	
		  WHEN vr_exc_saida THEN
      begin
				-- Se possui código de crítica e não foi informado a descrição
				IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					 -- Busca descrição da crítica
					 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
				END IF;

				-- Atribui exceção para os parametros de crítica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;

        ROLLBACK;
        npcb0002.pc_libera_sessao_sqlserver_npc('EMPR0007_2');
      end;
			WHEN OTHERS THEN  				
      begin
				-- Atribui exceção para os parametros de crítica				
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := 'Erro nao tratado na EMPR0007.pc_inst_baixa_boleto_epr: ' || SQLERRM;			
        ROLLBACK;
        npcb0002.pc_libera_sessao_sqlserver_npc('EMPR0007_3');
      end;
		END;						
	END pc_inst_baixa_boleto_epr;
  
	PROCEDURE pc_inst_baixa_boleto_epr_web(pr_nrdconta IN crapepr.nrdconta%TYPE  --> Nr. da conta
																				,pr_nrctremp IN crapepr.nrctremp%TYPE  --> Nr. contrato de empréstiomo
																				,pr_nrctacob IN crapepr.nrdconta%TYPE  --> Nr. da conta cobrança
																				,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE  --> Nr. convenio
																				,pr_nrdocmto IN crapcob.nrdocmto%TYPE  --> Nr. documento
																		    ,pr_dtmvtolt IN VARCHAR2               --> Data de movimento
																		    ,pr_dsjustif IN VARCHAR2               --> Justificativa de Baixa
																			  ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																			  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																			  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																			  ,pr_retxml   IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
																			  ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																			  ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
	/* .............................................................................

      Programa: pc_inst_baixa_boleto_epr_web
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Lucas Reinert
      Data    : Setembro/15.                    Ultima atualizacao: 06/03/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina para realizar a instrução de baixa de boleto utilizados 
			            para empréstimo no ambiente web

      Observacao: -----

      Alteracoes: 06/03/2017 - Gravacao da justificativa de baixa. (P210.2 - Jaison/Daniel)
  ..............................................................................*/																									BEGIN
		DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;        --> Cód. Erro
      vr_dscritic VARCHAR2(1000);               --> Desc. Erro

		  -- Tratamento de erros
		  vr_exc_saida EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- Variaveis Gerais
      vr_dsjustif VARCHAR2(1000);
      
      FUNCTION fn_normalizar(str_in VARCHAR2) RETURN VARCHAR2 IS
         pos           NUMBER(10);
         chars_special VARCHAR2(255);
         chars_normal  VARCHAR2(255);
         str           VARCHAR2(255) := UPPER(str_in);
		BEGIN
         chars_special := 'ÁÀÃÂÉÊÍÓÔÕÚÜÇ.-';
         chars_normal  := 'AAAAEEIOOOUUC  ';
         str           := TRIM(upper(str));
         pos           := length(chars_normal);
         WHILE pos > 0
         LOOP
            str := REPLACE(str,
                           substr(chars_special, pos, 1),
                           substr(chars_normal, pos, 1));
            pos := pos - 1;
         END LOOP;
         str := TRIM(str);
         WHILE regexp_like(str, ' {2,}')
         LOOP
            str := REPLACE(str, '  ', ' ');
         END LOOP;
         pos := length(str);
         WHILE pos > 0
         LOOP
            IF regexp_like(substr(str, pos, 1), '[^A-Z0-9Ç@._ +-]+')
            THEN
               str := concat(substr(str, 1, pos - 1), substr(str, pos + 1));
            END IF;
            pos := pos - 1;
         END LOOP;
         RETURN str;
      END;

		BEGIN

			pr_des_erro := 'OK';
			-- Extrai dados do xml
			gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
															 pr_cdcooper => vr_cdcooper,
															 pr_nmdatela => vr_nmdatela,
															 pr_nmeacao  => vr_nmeacao,
															 pr_cdagenci => vr_cdagenci,
															 pr_nrdcaixa => vr_nrdcaixa,
															 pr_idorigem => vr_idorigem,
															 pr_cdoperad => vr_cdoperad,
															 pr_dscritic => vr_dscritic);

			-- Se retornou alguma crítica
			IF trim(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;

      vr_dsjustif := fn_normalizar(GENE0007.fn_remove_cdata(pr_dsjustif));
      
      IF LENGTH(vr_dsjustif) < 5 THEN
        vr_dscritic := 'Justificativa da Baixa deve ser informada!';
        RAISE vr_exc_saida;
      END IF;

      IF LENGTH(vr_dsjustif) > 200 THEN
        vr_dscritic := 'Justificativa da Baixa deve respeitar o tamanho maximo de 200 caracteres!';
				RAISE vr_exc_saida;
			END IF;

      pc_inst_baixa_boleto_epr(pr_cdcooper => vr_cdcooper
			                        ,pr_nrdconta => pr_nrdconta
															,pr_nrctremp => pr_nrctremp
															,pr_nrctacob => pr_nrctacob
															,pr_nrcnvcob => pr_nrcnvcob
															,pr_nrdocmto => pr_nrdocmto
															,pr_dtmvtolt => to_date(pr_dtmvtolt, 'DD/MM/RRRR')
															,pr_idorigem => GENE0002.fn_char_para_number(vr_idorigem)
															,pr_cdoperad => vr_cdoperad
															,pr_nmdatela => vr_nmdatela
															,pr_cdcritic => vr_cdcritic
															,pr_dscritic => vr_dscritic);

			-- Se retornou alguma crítica
			IF vr_cdcritic <> 0 OR
				 trim(vr_dscritic) IS NOT NULL THEN
				 -- Levanta exceção
			   RAISE vr_exc_saida;
		  END IF;

      -- Atualiza a Justificativa
      BEGIN
        UPDATE tbrecup_cobranca
           SET dsjustifica_baixa = vr_dsjustif
         WHERE cdcooper          = vr_cdcooper
           AND nrdconta          = pr_nrdconta
           AND nrctremp          = pr_nrctremp
           AND nrdconta_cob      = pr_nrctacob
           AND nrcnvcob          = pr_nrcnvcob
           AND nrboleto          = pr_nrdocmto;
	  EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao alterar dados na tabela tbrecup_cobranca: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

	  EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

			  pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
			  pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
	END pc_inst_baixa_boleto_epr_web;

  PROCEDURE pc_obtem_dados_tr(pr_cdcooper IN crapepr.cdcooper%TYPE
		                         ,pr_nrdconta IN crapepr.nrdconta%TYPE
														 ,pr_nrctremp IN crapepr.nrctremp%TYPE
 														 ,pr_dtmvtolt IN crapepr.dtmvtolt%TYPE
														 ,pr_nmdatela IN VARCHAR2
														 ,pr_idorigem IN INTEGER
														 ,pr_cdoperad IN VARCHAR2
														 ,pr_vlsdeved OUT crapepr.vlsdeved%TYPE
														 ,pr_vlatraso OUT crapepr.vlsdeved%TYPE
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crít
														 )IS
	BEGIN
  	/* .............................................................................

      Programa: pc_obtem_dados_tr
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Lucas Reinert
      Data    : Setembro/15.                    Ultima atualizacao: 10/05/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina para obter dados de emprestimo TR

      Observacao: -----

      Alteracoes: 10/05/2018 - P410 - Ajustes IOF (Marcos-Envolti)
  ..............................................................................*/																								
		DECLARE
		  ------------------------------- VARIAVEIS ---------------------------------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
			
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
 			vr_tab_erro gene0001.typ_tab_erro;
			vr_des_reto VARCHAR2(3);
			
      -- Variaveis locais
      vr_dstextab craptab.dstextab%TYPE;  --> Busca na craptab		
      vr_inusatab BOOLEAN;                --> Indicador S/N de utilização de tabela de juros			
      vr_parempct craptab.dstextab%TYPE := '';      			
      vr_digitali craptab.dstextab%TYPE := '';
      vr_qtregist INTEGER := 0;
      vr_tab_dados_epr empr0001.typ_tab_dados_epr;       
      
      --IOF
      vr_vliofpri NUMBER;
      vr_vliofadi NUMBER;
      vr_vliofcpl NUMBER;
      vr_vltaxa_iof_principal VARCHAR2(20);
      vr_qtdiaiof NUMBER;
      vr_flgimune PLS_INTEGER;
      vr_dscatbem VARCHAR2(100);
      vr_cdlcremp NUMBER;
	  
		  ------------------------------- CURSORES ----------------------------------
		
  		-- Busca emprestimos tr
			CURSOR cr_crapepr_tr(pr_cdcooper IN crapepr.cdcooper%TYPE
												  ,pr_nrdconta IN crapepr.nrdconta%TYPE
													,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
				SELECT NVL(epr.qtprepag,0) qtprepag
				      ,NVL(epr.vlsdeved,0) vlsdeved
							,NVL(epr.vljuracu,0) vljuracu
							,epr.dtultpag
							,epr.txjuremp
							,lcr.txdiaria
              ,epr.cdfinemp
				  FROM crapepr epr,
					     craplcr lcr
				 WHERE epr.cdcooper = pr_cdcooper
				   AND epr.nrdconta = pr_nrdconta
					 AND epr.nrctremp = pr_nrctremp
           AND epr.inliquid  = 0 --> Somente não liquidados
--           AND epr.indpagto  = 0 --> Nao pago no mês ainda
           AND epr.flgpagto  = 0 --> Débito em conta
--           AND epr.dtdpagto <= pr_dtmvtolt
           AND lcr.cdcooper = epr.cdcooper
           AND lcr.cdlcremp = epr.cdlcremp;
			rw_crapepr_tr cr_crapepr_tr%ROWTYPE;
			
			CURSOR cr_crapass IS
			  SELECT ass.nmprimtl
				      ,ass.cdagenci
				  FROM crapass ass
				 WHERE ass.cdcooper = pr_cdcooper
				   AND ass.nrdconta = pr_nrdconta;
			rw_crapass cr_crapass%ROWTYPE;
			
      -- Cursor para bens do contrato: 
      /*Faz o order by dscatbem pois "CASA" e "APARTAMENTO" reduzem as 3 aliquotas de IOF (principal, adicional e complementar) a zero.
      Já "MOTO" reduz apenas as alíquotas de IOF principal e complementar..
      Dessa forma, se tiver um bem que seja CASA ou APARTAMENTO, não precisa mais verificar os outros bens..*/
      CURSOR cr_crapbpr(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS      
        SELECT b.dscatbem, t.cdlcremp
        FROM crapepr t
        INNER JOIN crapbpr b ON b.nrdconta = t.nrdconta AND b.cdcooper = t.cdcooper AND b.nrctrpro = t.nrctremp
        WHERE t.cdcooper = pr_cdcooper
              AND t.nrdconta = pr_nrdconta
              AND t.nrctremp = pr_nrctremp
              AND upper(b.dscatbem) IN ('APARTAMENTO', 'CASA', 'MOTO')
        ORDER BY upper(b.dscatbem) ASC;
      rw_crapbpr cr_crapbpr%ROWTYPE;
			
		
		BEGIN
			
 			-- Verifica se a data da cooperativa esta cadastrada
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO btch0001.rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;	
		
		  OPEN cr_crapass;
			FETCH cr_crapass INTO rw_crapass;
			
			-- Se nao encontrar associado
			IF cr_crapass%NOTFOUND THEN
				-- Atribui crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Associado nao cadastrado';
				-- Gera exceção
				RAISE vr_exc_saida;
			END IF;
					
      -- Leitura do indicador de uso da tabela de taxa de juros
			vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
																							 ,pr_nmsistem => 'CRED'
																							 ,pr_tptabela => 'USUARI'
																							 ,pr_cdempres => 11
																							 ,pr_cdacesso => 'TAXATABELA'
																							 ,pr_tpregist => 0);

			-- Se encontrar
			IF vr_dstextab IS NOT NULL THEN
				-- Se a primeira posição do campo
				-- dstextab for diferente de zero
				IF SUBSTR(vr_dstextab,1,1) != '0' THEN
					-- É porque existe tabela parametrizada
					vr_inusatab := TRUE;
				ELSE
					-- Não existe
					vr_inusatab := FALSE;
				END IF;
			ELSE
				-- Não existe
				vr_inusatab := FALSE;
			END IF;

			-- Busca informações do emprestimo
			OPEN cr_crapepr_tr(pr_cdcooper => pr_cdcooper
												,pr_nrdconta => pr_nrdconta
												,pr_nrctremp => pr_nrctremp);
			FETCH cr_crapepr_tr INTO rw_crapepr_tr;

			IF cr_crapepr_tr%NOTFOUND THEN
				-- Fecha cursor
				CLOSE cr_crapepr_tr;
				-- Atribui crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Contrato de emprestimo nao encontrado';
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;
			-- Fecha cursor
			CLOSE cr_crapepr_tr;
			
			-- busca o tipo de documento GED    
      vr_digitali := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'DIGITALIZA'
                                               ,pr_tpregist => 5);
       
      -- Leitura do indicador de uso da tabela de taxa de juros                                                    
      vr_parempct := tabe0001.fn_busca_dstextab(pr_cdcooper => 3 /*Fixo Cecred*/
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'PAREMPCTL'
                                               ,pr_tpregist => 1); 
																		
		  EMPR0001.pc_obtem_dados_empresti(pr_cdcooper => pr_cdcooper
																			,pr_cdagenci => rw_crapass.cdagenci
																			,pr_nrdcaixa => 1 
																			,pr_cdoperad => pr_cdoperad 
																			,pr_nmdatela => pr_nmdatela
																			,pr_idorigem => pr_idorigem
																			,pr_nrdconta => pr_nrdconta
																			,pr_idseqttl => 1
																			,pr_rw_crapdat => btch0001.rw_crapdat
																			,pr_dtcalcul => pr_dtmvtolt
																			,pr_nrctremp => pr_nrctremp
																			,pr_cdprogra => pr_nmdatela
																			,pr_inusatab => vr_inusatab
																			,pr_flgerlog => 'N'
																			,pr_flgcondc => FALSE
																			,pr_nmprimtl => rw_crapass.nmprimtl
																			,pr_tab_parempctl => vr_parempct
																			,pr_tab_digitaliza => vr_digitali
																			,pr_nriniseq => 1 
																			,pr_nrregist => 1 
																			,pr_qtregist => vr_qtregist
																			,pr_tab_dados_epr => vr_tab_dados_epr
																			,pr_des_reto => vr_des_reto
																			,pr_tab_erro => vr_tab_erro);
																				 
			-- Se a rotina retornou com erro
			IF vr_des_reto <> 'OK' THEN
				-- Se possui algum erro na tabela de erros
				IF vr_tab_erro.count() > 0 THEN
					-- Atribui críticas às variaveis
					vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
					vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
				ELSE
					vr_cdcritic := 0;
					vr_dscritic := 'Erro ao obter dados de emprestimo';
				END IF;

				-- Gerar exceção
				RAISE vr_exc_saida;
			END IF;

      pr_vlsdeved := (vr_tab_dados_epr(vr_tab_dados_epr.first).vlsdeved + 
                      vr_tab_dados_epr(vr_tab_dados_epr.first).vlmtapar +
                      vr_tab_dados_epr(vr_tab_dados_epr.first).vlmrapar);   
			pr_vlatraso := vr_tab_dados_epr(vr_tab_dados_epr.first).vltotpag;
      
      
      -- Novo cálculo de IOF
      vr_dscatbem := NULL;
      vr_cdlcremp := NULL;
      --Verifica o primeiro bem do contrato para saber se tem isenção de alíquota
      OPEN cr_crapbpr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crapbpr INTO rw_crapbpr;
      IF cr_crapbpr%FOUND THEN
        vr_dscatbem := rw_crapbpr.dscatbem;
        vr_cdlcremp := rw_crapbpr.cdlcremp;
      END IF;
      CLOSE cr_crapbpr;
      
      --Dias de atraso
      vr_qtdiaiof := vr_tab_dados_epr(vr_tab_dados_epr.first).dtdpagto - pr_dtmvtolt;
                              
      --Calcula o IOF
      TIOF0001.pc_calcula_valor_iof_epr(pr_tpoperac => 2                                      --> Somente o atraso
                                       ,pr_cdcooper => pr_cdcooper                            --> Código da cooperativa referente ao contrato de empréstimos
                                        ,pr_nrdconta => pr_nrdconta                            --> Número da conta referente ao empréstimo
                                        ,pr_nrctremp => pr_nrctremp                            --> Número do contrato de empréstimo
                                        ,pr_vlemprst => pr_vlsdeved                            --> Valor do empréstimo para efeito de cálculo
                                        ,pr_dscatbem => vr_dscatbem                            --> Descrição da categoria do bem, valor default NULO 
                                        ,pr_cdlcremp => vr_cdlcremp                            --> Linha de crédito do empréstimo
                                        ,pr_cdfinemp => rw_crapepr_tr.cdfinemp                 --> Finalidade do empréstimo
                                        ,pr_dtmvtolt => pr_dtmvtolt                            --> Data do movimento
                                        ,pr_qtdiaiof => vr_qtdiaiof                            --> Quantidade de dias em atraso
                                        ,pr_vliofpri => vr_vliofpri                            --> Valor do IOF principal
                                        ,pr_vliofadi => vr_vliofadi                            --> Valor do IOF adicional
                                        ,pr_vliofcpl => vr_vliofcpl                            --> Valor do IOF complementar
                                        ,pr_vltaxa_iof_principal => vr_vltaxa_iof_principal    --> Valor da Taxa do IOF Principal
                                        ,pr_flgimune => vr_flgimune                            --> Possui imunidade tributária
                                        ,pr_dscritic => vr_dscritic);                          --> Descrição da crítica
                                                
      IF NVL(vr_dscritic, ' ') <> ' ' THEN
			   RAISE vr_exc_saida;
			END IF;
			  
			--Imunidade....
      IF vr_flgimune > 0 THEN
        vr_vliofpri := 0;
        vr_vliofadi := 0;
        vr_vliofcpl := 0;
      ELSE
        vr_vliofcpl := NVL(vr_vliofcpl, 0);
      END IF;
      
      pr_vlsdeved := pr_vlsdeved + vr_vliofcpl;
      

		EXCEPTION	
		  WHEN vr_exc_saida THEN
				-- Se possui código de crítica e não foi informado a descrição
				IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					 -- Busca descrição da crítica
					 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
				END IF;

				-- Atribui exceção para os parametros de crítica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;

			WHEN OTHERS THEN  				
				-- Atribui exceção para os parametros de crítica				
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := 'Erro nao tratado na EMPR0007.pc_obtem_dados_tr: ' || SQLERRM;			

		END;					
	END pc_obtem_dados_tr;

  PROCEDURE pc_obtem_dados_tr_web(pr_nrdconta IN crapepr.nrdconta%TYPE
																 ,pr_nrctremp IN crapepr.nrctremp%TYPE
																 ,pr_dtmvtolt IN VARCHAR2
																 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
																 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
																 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
																 ,pr_retxml   IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
																 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
																 ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
	 BEGIN
  	/* .............................................................................

      Programa: pc_obtem_dados_tr_web
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Lucas Reinert
      Data    : Setembro/15.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina para obter dados de emprestimo TR para WEB

      Observacao: -----

      Alteracoes: 
  ..............................................................................*/																								
		DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;        --> Cód. Erro
      vr_dscritic VARCHAR2(1000);               --> Desc. Erro

		  -- Tratamento de erros
		  vr_exc_saida EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
			
			-- Variaveis locais
			vr_vlsdeved crapepr.vlsdeved%TYPE;
			vr_vlatraso crapepr.vlsdeved%TYPE;

		BEGIN

			pr_des_erro := 'OK';
			-- Extrai dados do xml
			gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
															 pr_cdcooper => vr_cdcooper,
															 pr_nmdatela => vr_nmdatela,
															 pr_nmeacao  => vr_nmeacao,
															 pr_cdagenci => vr_cdagenci,
															 pr_nrdcaixa => vr_nrdcaixa,
															 pr_idorigem => vr_idorigem,
															 pr_cdoperad => vr_cdoperad,
															 pr_dscritic => vr_dscritic);

			-- Se retornou alguma crítica
			IF trim(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_saida;
			END IF;
      
			pc_obtem_dados_tr(pr_cdcooper => vr_cdcooper
			                 ,pr_nrdconta => pr_nrdconta
											 ,pr_nrctremp => pr_nrctremp
											 ,pr_dtmvtolt => to_date(pr_dtmvtolt, 'DD/MM/RRRR')
											 ,pr_nmdatela => vr_nmdatela
											 ,pr_idorigem => GENE0002.fn_char_para_number(vr_idorigem)
											 ,pr_cdoperad => vr_cdoperad
											 ,pr_vlsdeved => vr_vlsdeved
											 ,pr_vlatraso => vr_vlatraso
											 ,pr_cdcritic => vr_cdcritic
											 ,pr_dscritic => vr_dscritic);
			
			-- Se retornou alguma crítica
			IF vr_cdcritic <> 0 OR
				 trim(vr_dscritic) IS NOT NULL THEN
				 -- Levanta exceção
			   RAISE vr_exc_saida;
		  END IF;

      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><vlsdeved>' || to_char(vr_vlsdeved) || '</vlsdeved>' ||
																		         '<vlatraso>' || to_char(vr_vlatraso) || '</vlatraso></Root>');                             


	  EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

			  pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
			  pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    END;
	END pc_obtem_dados_tr_web;

  PROCEDURE pc_gera_arq_remessa_sms(pr_cdcooper IN crapcop.cdcooper%TYPE
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                   ,pr_dsretorn OUT VARCHAR2
                                   ,pr_cdcritic OUT PLS_INTEGER
                                   ,pr_dscritic OUT VARCHAR2) IS
  	/* .............................................................................

      Programa: pc_gera_arq_remessa_sms
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Rafael Cechet
      Data    : Setembro/15.                    Ultima atualizacao: 07/03/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina para gerar o arquivo de remessa SMS -> ZENVIA

      Observacao: -----

      Alteracoes: 07/03/2017 - Inclusao dos campos Contrato, Valor e Vencimento. (P210.2 - Jaison/Daniel)
                  03/08/2018 - Alterações para funcionar para COBTIT também - Luis Fernando (GFT)
                   
  ..............................................................................*/																								
  BEGIN

		DECLARE
		  ------------------------------- VARIAVEIS ---------------------------------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic VARCHAR2(10000);
      vr_des_erro VARCHAR2(4000);
			
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
 			vr_tab_erro gene0001.typ_tab_erro;
			vr_des_reto VARCHAR2(3);

      -- Variaveis da procedure
      vr_texto_sms VARCHAR2(4000);
      vr_nmextcop VARCHAR2(100);
      vr_nmprimtl VARCHAR2(100);
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_linha VARCHAR2(1000);
      vr_dhenvio DATE;
      
      -- PL/Table com as informações do boleto
      vr_tab_cob cobr0005.typ_tab_cob;           
      
      -- Declarando handle do Arquivo
      vr_nmarquiv VARCHAR2(100);
      vr_nmdireto VARCHAR2(100);
      vr_arquivo_rem utl_file.file_type;      
      vr_arquivo_cfg utl_file.file_type;            

      -- Traz os registros da COBEMP/COBTIT para serem enviados
      CURSOR cr_cde_sms IS
        SELECT cop.cdcooper,               
               cop.nmrescop,
               cop.cdagectl,
               cde.nrdconta,
               cde.nrdconta_cob,
               cde.nrcnvcob,
               cde.nrctremp,
               cde.nrboleto,
               cde.nrddd_sms, 
               cde.nrtel_sms,
               cde.rowid rowid_cde,
               ass.nmprimtl
          FROM crapcop cop,
               tbrecup_cobranca cde,
               crapass ass
         WHERE cop.cdcooper > 0
           AND cop.cdcooper <> 3
           AND cop.flgativo = 1
           AND cde.cdcooper = cop.cdcooper
           AND cde.dhenvio >= pr_dtmvtolt
           AND cde.tpenvio = 2
           AND cde.indretorno = 0
           AND ass.cdcooper = cde.cdcooper
           AND ass.nrdconta = cde.nrdconta
           ORDER BY cop.cdcooper, cde.nrdconta;
      rw_cde_sms cr_cde_sms%ROWTYPE; 
      -- pega parametro de configuracao da cobemp/cobtit
      CURSOR cr_param_sms IS
        SELECT * FROM crappbc
         WHERE idtpreme = 'COBEMP';
      rw_param_sms cr_param_sms%ROWTYPE;
                                   
      vr_cdprogra    VARCHAR2(40) := 'PC_GERA_ARQ_REMESSA_SMS';
      vr_nomdojob    VARCHAR2(40) := 'JBEPR_COBEMP_BUREAUX';
      vr_flgerlog    BOOLEAN := FALSE;

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
    
      vr_cdcooper := 0;
      
      OPEN cr_param_sms;
      FETCH cr_param_sms INTO rw_param_sms;
      
      IF cr_param_sms%NOTFOUND THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Parametro SMS ZENVIA nao encontrado';
         
        -- logar erro
        vr_flgerlog := TRUE;
        pc_controla_log_batch('E', vr_dscritic);
         RAISE vr_exc_saida;  
      END IF;
      
      CLOSE cr_param_sms;
      
      vr_nmdireto := rw_param_sms.dsdirenv;
      
      OPEN cr_cde_sms;
      
      LOOP     
        
        FETCH cr_cde_sms INTO rw_cde_sms;
        EXIT WHEN cr_cde_sms%NOTFOUND;                
        
        -- logar início da execução
        pc_controla_log_batch('I');
        
        IF vr_cdcooper <> rw_cde_sms.cdcooper THEN
          
           IF vr_cdcooper > 0 THEN
             -- Fechar os arquivos
             GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arquivo_cfg);
             GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arquivo_rem);                     
           END IF;
          
           vr_cdcooper := rw_cde_sms.cdcooper;          
           
           -- variavel para armazenar a data/hora de envio do arquivo
           vr_dhenvio := SYSDATE;

           vr_nmarquiv := to_char(vr_dhenvio,'RRRRMMDD_HH24MISS')  || '_' ||
                          to_char(rw_cde_sms.cdagectl,'fm0000') || '_' ||
                          'COBEMP';
                          
           -- criar arquivo .cfg           
           -- Abre arquivo em modo de escrita (W)
           GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto           --> Diretório do arquivo
                                   ,pr_nmarquiv => vr_nmarquiv || '.cfg' --> Nome do arquivo
                                   ,pr_tipabert => 'W'                   --> Modo de abertura (R,W,A)
                                   ,pr_utlfileh => vr_arquivo_cfg        --> Handle do arquivo aberto
                                   ,pr_des_erro => vr_dscritic);         --> Erro           
                                   
           -- gravar linha no arquivo                    
           GENE0001.pc_escr_linha_arquivo(vr_arquivo_cfg,
                                          '1;' || vr_nmarquiv || '.txt' || chr(13) || chr(10) ||
                                          '2;' || 'D' || chr(13) || chr(10) ||
                                          '3;' || to_char(vr_dhenvio,'DD/MM/RRRR;HH24:MI:SS') || chr(13) || chr(10) ||
                                          '6;' || to_char(vr_dhenvio + (60/60/24),'DD/MM/RRRR;HH24:MI:SS') || chr(13) || chr(10) ||
                                          '7;' || vr_nmarquiv || '_ret.txt' || chr(13) || chr(10)
                                          );
                                   
           -- criar arquivo .rem                      
           -- Abre arquivo em modo de escrita (W)
           GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto           --> Diretório do arquivo
                                   ,pr_nmarquiv => vr_nmarquiv || '.txt' --> Nome do arquivo
                                   ,pr_tipabert => 'W'                   --> Modo de abertura (R,W,A)
                                   ,pr_utlfileh => vr_arquivo_rem        --> Handle do arquivo aberto
                                   ,pr_des_erro => vr_dscritic);         --> Erro           
          
        END IF;        
    
        cecred.cobr0005.pc_buscar_titulo_cobranca(pr_cdcooper => rw_cde_sms.cdcooper
                                                 ,pr_nrdconta => rw_cde_sms.nrdconta_cob
                                                 ,pr_nrcnvcob => rw_cde_sms.nrcnvcob
                                                 ,pr_nrdocmto => rw_cde_sms.nrboleto
                                                 ,pr_cdoperad => '1'
                                                 ,pr_nriniseq => 1
                                                 ,pr_nrregist => 1
                                                 ,pr_cdcritic => vr_cdcritic
                                                 ,pr_dscritic => vr_dscritic
                                                 ,pr_tab_cob  => vr_tab_cob);                                                     
      
        vr_nmprimtl := rw_cde_sms.nmprimtl;
        vr_nmextcop := rw_cde_sms.nmrescop;

        vr_texto_sms:= gene0001.fn_param_sistema(pr_cdcooper => rw_cde_sms.cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_cdacesso => 'COBEMP_TXT_SMS');

        vr_texto_sms := REPLACE(vr_texto_sms,'#Cooperativa#',rw_cde_sms.nmrescop);
        vr_texto_sms := REPLACE(vr_texto_sms,'#Cooperado#',rw_cde_sms.nmprimtl);
        vr_texto_sms := REPLACE(vr_texto_sms,'#LinhaDigitavel#',vr_tab_cob(1).lindigit);
        vr_texto_sms := REPLACE(vr_texto_sms,'#Contrato#',to_char(rw_cde_sms.nrctremp)); -- Emprestimo
        vr_texto_sms := REPLACE(vr_texto_sms,'#Bordero#',to_char(rw_cde_sms.nrctremp)); -- Desconto de titulo
        vr_texto_sms := REPLACE(vr_texto_sms,'#Valor#',vr_tab_cob(1).vltitulo);
        vr_texto_sms := REPLACE(vr_texto_sms,'#Vencimento#',to_char(vr_tab_cob(1).dtvencto,'DD/MM/YYYY'));
        
        -- Texto SMS = 160 caracteres já com o nome do remetente
        vr_texto_sms := substr(vr_texto_sms,1,160-length(rw_cde_sms.nmrescop));

        -- construir a linha do arquivo - LAYOUT D -> ZENVIA
        vr_linha := '55' ||
                    rw_cde_sms.nrddd_sms || 
                    rw_cde_sms.nrtel_sms || 
                    ';' ||
                    vr_texto_sms ||
                    ';' ||
                    to_char(rw_cde_sms.nrcnvcob, 'fm000000') ||
                    to_char(rw_cde_sms.nrdconta_cob, 'fm00000000') ||
                    to_char(rw_cde_sms.nrboleto, 'fm000000000') ||
                    ';' ||
                    rw_cde_sms.nmrescop ||
                    CHR(13);                    
        
        -- gravar linha no arquivo                    
        GENE0001.pc_escr_linha_arquivo(vr_arquivo_rem,vr_linha);                                    
        
        -- Cria log de cobrança
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => vr_tab_cob(1).rowidcob,
                                      pr_cdoperad => '1',
                                      pr_dtmvtolt => trunc(SYSDATE),
                                      pr_dsmensag => 'Linha Digitavel enviado por SMS ZENVIA',
                                      pr_des_erro => vr_des_erro,
                                      pr_dscritic => vr_dscritic);
                                      
        -- atualizar registro de controle que o SMS foi enviado;                                      
        UPDATE tbrecup_cobranca 
           SET indretorno = 2
              ,dtretorno = SYSDATE
         WHERE ROWID = rw_cde_sms.rowid_cde;                                                     
  
      END LOOP;
      
      IF cr_cde_sms%ISOPEN THEN
         CLOSE cr_cde_sms;
      END IF;
      
      IF vr_cdcooper > 0 THEN
        
        -- Fechar os arquivos
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arquivo_cfg);
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arquivo_rem);
        -- solicitar envio de remessa SMS Zenvia
        cybe0002.pc_solicita_remessa(pr_dtmvtolt => vr_dhenvio
                                   , pr_idtpreme => 'COBEMP'
                                   , pr_dscritic => vr_dscritic);
                                   
        IF vr_dscritic IS NOT NULL THEN
                                   
          -- logar erro
          pc_controla_log_batch('E', vr_dscritic);        
           RAISE vr_exc_saida;
        END IF;
        
        COMMIT;        
        
        pr_dsretorn := 'OK';        
      ELSE
        vr_cdcritic := 0;
        vr_dscritic := 'Nao haviam SMS a serem enviados';
        pr_dsretorn := 'NOK';         
        
        -- Gravar no proc_message e sair do programa
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3, 
                                   pr_ind_tipo_log => 2, -- erro tratado 
                                   pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || 'EMPR0007.pc_gera_arq_remessa_sms --> '
                                                      || vr_dscritic, 
                                   pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
        
        
        RAISE vr_exc_saida;        
      END IF;
    
      IF vr_cdcooper > 0 THEN
        -- fim da execução.      
        pc_controla_log_batch('F');
      END IF;
  
		EXCEPTION	
		  WHEN vr_exc_saida THEN
        
        IF cr_cde_sms%ISOPEN THEN
           CLOSE cr_cde_sms;
        END IF;
      
				-- Se possui código de crítica e não foi informado a descrição
				IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					 -- Busca descrição da crítica
					 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
				END IF;

				-- Atribui exceção para os parametros de crítica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;

        ROLLBACK;
        
        pr_dsretorn := 'NOK';
			WHEN OTHERS THEN  				
        
        IF cr_cde_sms%ISOPEN THEN
           CLOSE cr_cde_sms;
        END IF;
      
				-- Atribui exceção para os parametros de crítica				
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := 'Erro nao tratado na EMPR0007.pc_gera_arq_remessa_sms: ' || SQLERRM;			
        
        ROLLBACK;
        
        pr_dsretorn := 'NOK';        
        
        -- fim execução, com erro
        vr_flgerlog := TRUE;
        pc_controla_log_batch('E', to_char(vr_cdcritic) || ' _ '  || pr_dscritic);
		END;					                                                                      
    
  END pc_gera_arq_remessa_sms;  
  
  PROCEDURE pc_processa_retorno_sms(pr_cdcooper IN crapcop.cdcooper%TYPE
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                   ,pr_dsretorn OUT VARCHAR2
                                   ,pr_cdcritic OUT PLS_INTEGER
                                   ,pr_dscritic OUT VARCHAR2) IS
  	/* .............................................................................

      Programa: pc_processa_retorno_sms
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Rafael Cechet
      Data    : Setembro/15.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina para processar arquivo de retorno SMS -> ZENVIA

      Observacao: -----

      Alteracoes: 
  ..............................................................................*/																								
  BEGIN

		DECLARE
		  ------------------------------- VARIAVEIS ---------------------------------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      vr_des_erro VARCHAR2(4000);
			
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_exc_proxarq  EXCEPTION;            
 			vr_tab_erro gene0001.typ_tab_erro;
			vr_des_reto VARCHAR2(3);

      -- Variaveis da procedure
      vr_retorno_sms VARCHAR2(50);
      vr_linha VARCHAR2(500);
      
      -- Tabela de String
      vr_tab_string        gene0002.typ_split;      
      
      -- PL/Table com as informações do boleto
      vr_tab_cob cobr0005.typ_tab_cob;           
      
      -- Declarando handle do Arquivo
      vr_nmarquiv VARCHAR2(100);
      vr_nmdireto VARCHAR2(100);
      vr_arquivo_ret utl_file.file_type;      
      vr_array_arquivo gene0002.typ_split;
      vr_list_arquivos VARCHAR2(10000);
      vr_dsmascar      VARCHAR2(200);
      vr_nmdirslv VARCHAR2(4000);      
      ind PLS_INTEGER;
      
      -- cursores      
      CURSOR cr_cde_sms (pr_nrconven IN crapcco.nrconven%TYPE
                        ,pr_nrdconta IN crapcob.nrdconta%TYPE
                        ,pr_nrboleto IN crapcob.nrdocmto%type) IS
        SELECT cde.cdcooper,
               cde.nrdconta,
               cde.nrdconta_cob,
               cde.nrcnvcob,
               cde.nrboleto,
               cde.rowid rowid_cde
          FROM tbrecup_cobranca cde
              ,crapcco cco
         WHERE cco.nrconven = pr_nrconven
           AND cco.dsorgarq IN ('EMPRESTIMO','DESCONTO DE TITULO')
           AND cde.cdcooper = cco.cdcooper
           AND cde.nrdconta_cob = pr_nrdconta
           AND cde.nrcnvcob = cco.nrconven
           AND cde.nrboleto = pr_nrboleto;
      rw_cde_sms cr_cde_sms%ROWTYPE; 
      
      CURSOR cr_param_sms IS
        SELECT * FROM crappbc
         WHERE idtpreme = 'COBEMP';
      rw_param_sms cr_param_sms%ROWTYPE;
                                   
      vr_cdprogra    VARCHAR2(40) := 'PC_PROCESSA_RETORNO_SMS';
      vr_nomdojob    VARCHAR2(40) := 'JBEPR_COBEMP_BUREAUX';
      vr_flgerlog    BOOLEAN := FALSE;

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
    
      -- Diretorio Salvar
      vr_nmdirslv := gene0001.fn_diretorio(pr_tpdireto => 'C',
                                           pr_cdcooper => 3, /* cecred */
                                           pr_nmsubdir => 'salvar');      
      
      OPEN cr_param_sms;
      FETCH cr_param_sms INTO rw_param_sms;
      
      IF cr_param_sms%NOTFOUND THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Parametro SMS ZENVIA nao encontrado';

        -- logar erro
        vr_flgerlog := TRUE;
        pc_controla_log_batch('E', vr_dscritic);
         RAISE vr_exc_saida;  
      END IF;
      
      CLOSE cr_param_sms;

      vr_dsmascar := '%COBEMP%.txt';
      vr_nmdireto := rw_param_sms.dsdirret;
      
      vr_list_arquivos := NULL;

      -- Retorna a lista dos arquivos do diretório, conforme padrão *cdcooper*.*.rem
      gene0001.pc_lista_arquivos(pr_path     => vr_nmdireto
                                ,pr_pesq     => vr_dsmascar
                                ,pr_listarq  => vr_list_arquivos
                                ,pr_des_erro => vr_dscritic);
      
      -- Verifica se retornou arquivos
      IF vr_list_arquivos IS NOT NULL THEN
         -- Listar os arquivos em um array
         vr_array_arquivo := gene0002.fn_quebra_string(pr_string  => vr_list_arquivos
                                                      ,pr_delimit => ',');
                                                      
         -- Percorrer todos os arquivos encontrados na pasta
         FOR ind IN vr_array_arquivo.FIRST..vr_array_arquivo.LAST LOOP                                                          
           
            pc_controla_log_batch('I');
         
            vr_nmarquiv := vr_array_arquivo(ind);
      
            -- Abrir Arquivo
            gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto            --> Diretorio do arquivo
                                    ,pr_nmarquiv => vr_nmarquiv            --> Nome do arquivo
                                    ,pr_tipabert => 'R'                    --> Modo de abertura (R,W,A)
                                    ,pr_utlfileh => vr_arquivo_ret         --> Handle do arquivo aberto
                                    ,pr_des_erro => vr_des_erro);          --> Erro
                                    
            IF vr_des_erro IS NOT NULL THEN
              vr_dscritic := vr_des_erro;
              
              -- logar erro
              pc_controla_log_batch('E', vr_dscritic);
              
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;

            -- Se o arquivo estiver aberto
            IF  utl_file.IS_OPEN(vr_arquivo_ret) THEN

              -- Percorrer as linhas do arquivo
              BEGIN
                
                LOOP

                  gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_arquivo_ret
                                              ,pr_des_text => vr_linha);                                        

                  -- Quebrar Informacoes da String e colocar no vetor
                  vr_linha := REPLACE(vr_linha,chr(13),'');          
                  vr_tab_string := gene0002.fn_quebra_string(vr_linha,';');
                  
                  OPEN cr_cde_sms(pr_nrconven => to_number(substr(vr_tab_string(3),1,6))
                                 ,pr_nrdconta => to_number(substr(vr_tab_string(3),7,8))
                                 ,pr_nrboleto => to_number(substr(vr_tab_string(3),15,9)));
                                 
                  FETCH cr_cde_sms INTO rw_cde_sms;
                  IF cr_cde_sms%FOUND THEN
                     
                     CLOSE cr_cde_sms;
                                           
                     cecred.cobr0005.pc_buscar_titulo_cobranca(pr_cdcooper => rw_cde_sms.cdcooper
                                                              ,pr_nrdconta => rw_cde_sms.nrdconta_cob
                                                              ,pr_nrcnvcob => rw_cde_sms.nrcnvcob
                                                              ,pr_nrdocmto => rw_cde_sms.nrboleto
                                                              ,pr_cdoperad => '1'
                                                              ,pr_nriniseq => 1
                                                              ,pr_nrregist => 1
                                                              ,pr_cdcritic => vr_cdcritic
                                                              ,pr_dscritic => vr_dscritic
                                                              ,pr_tab_cob  => vr_tab_cob);                                                     
            
                     CASE to_number(vr_tab_string(5))
                          WHEN 1 THEN vr_retorno_sms := 'Agendado';
                          WHEN 2 THEN vr_retorno_sms := 'Enviado';
                          WHEN 3 THEN vr_retorno_sms := 'Entregue';
                          WHEN 4 THEN vr_retorno_sms := 'Nao recebido';
                          WHEN 5 THEN vr_retorno_sms := 'Fora do plano de numeracao';
                          WHEN 6 THEN vr_retorno_sms := 'Blacklist';
                          WHEN 7 THEN vr_retorno_sms := 'Limpeza preditiva';
                          WHEN 8 THEN vr_retorno_sms := 'Erro';
                          WHEN 9 THEN vr_retorno_sms := 'Cancelado';
                     END CASE;
              
                     -- Cria log de cobrança
                     PAGA0001.pc_cria_log_cobranca(pr_idtabcob => vr_tab_cob(1).rowidcob,
                                                   pr_cdoperad => '1',
                                                   pr_dtmvtolt => trunc(SYSDATE),
                                                   pr_dsmensag => 'Retorno Status SMS: ' || vr_retorno_sms,
                                                   pr_des_erro => vr_des_erro,
                                                   pr_dscritic => vr_dscritic);                              
                                                   
                     UPDATE tbrecup_cobranca SET indretorno = to_number(vr_tab_string(5))
                                              ,dtretorno = SYSDATE
                      WHERE ROWID = rw_cde_sms.rowid_cde;
                                                   
                  ELSE
                     CLOSE cr_cde_sms;                         
                  END IF; -- found cde_sms
                  
                END LOOP; -- loop do arquivo
                
              EXCEPTION
                WHEN no_data_found THEN
                  -- Acabou a leitura
                  NULL;
                  
              END; 
              
            END IF; -- IF arquivo aberto          
            
            -- Se o arquivo estiver aberto
            IF  utl_file.IS_OPEN(vr_arquivo_ret) THEN
              -- Fechar os arquivos
              GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arquivo_ret);
            END IF;
            
            -- Mover o arquivo retorno para a pasta /usr/coop/<cooperativa>/salvar
            gene0001.pc_OScommand_Shell('mv ' || vr_nmdireto || '/' || vr_nmarquiv || ' ' ||
                                         vr_nmdirslv || '/' || vr_nmarquiv);
            
            
            COMMIT;
            
         END LOOP;
         
      END IF;
      
      pr_dsretorn := 'OK';
    
      -- fim da execução
      pc_controla_log_batch('F');

		EXCEPTION	
      
		  WHEN vr_exc_saida THEN
        
        IF cr_cde_sms%ISOPEN THEN
           CLOSE cr_cde_sms;
        END IF;
      
				-- Se possui código de crítica e não foi informado a descrição
				IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					 -- Busca descrição da crítica
					 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
				END IF;

				-- Atribui exceção para os parametros de crítica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;

        ROLLBACK;
        
        pr_dsretorn := 'NOK';

			WHEN OTHERS THEN  				
        
        IF cr_cde_sms%ISOPEN THEN
           CLOSE cr_cde_sms;
        END IF;
      
				-- Atribui exceção para os parametros de crítica				
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := 'Erro nao tratado na EMPR0007.pc_processa_retorno_sms: ' || SQLERRM;			
        
        ROLLBACK;
        
        pr_dsretorn := 'NOK';

        -- fim da execução, com erro
        vr_flgerlog := TRUE;
        pc_controla_log_batch('E', pr_dscritic);
		END;					                                                                      
    
  END pc_processa_retorno_sms;   

  PROCEDURE pc_gerar_pdf_boletos(pr_cdcooper IN crapass.cdcooper%TYPE --> Cód. cooperativa
		                            ,pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
																,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE --> Nr. do convênio
																,pr_nrdocmto IN crapcob.nrdocmto%TYPE --> Nr docmto
																,pr_cdoperad IN crapope.cdoperad%TYPE --> Cód operador
																,pr_idorigem IN NUMBER                --> Id origem
																,pr_tpdenvio IN tbrecup_cobranca.tpenvio%TYPE DEFAULT 0  --> Tipo de envio
																,pr_dsdemail IN tbrecup_cobranca.dsemail%TYPE DEFAULT '' --> Email
																,pr_nmarqpdf OUT VARCHAR2             --> Nome do arquivo em PDF
																,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
																,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
																,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
	/* .............................................................................

		Programa: pc_gerar_pdf_boletos
		Sistema : CECRED
		Sigla   : EMPR
		Autor   : Lucas Reinert
		Data    : Outubro/15.                    Ultima atualizacao: 27/09/2016

		Dados referentes ao programa:

		Frequencia: Sempre que for chamado

		Objetivo  : Rotina para gerar a impressao do boleto em pdf

		Observacao: -----

		Alteracoes: 27/09/2016 - Incluida verificacao de contratos de acordo,
                             Prj. 302 (Jean Michel).

                    23/04/2019 - Alterada rotina para envio do boleto por e-mail para
                             recuperar o texto da crapprm.
                             (P559 - André Clemer - Supero)

                    05/06/2019 - Removida instrução "NAO ACEITAR PAGAMENTO APOS O VENCIMENTO"
                             (P559 - André Clemer - Supero)
	..............................................................................*/
		DECLARE
			----------------------------- VARIAVEIS ---------------------------------
			-- Variável de críticas
			vr_cdcritic crapcri.cdcritic%TYPE;
			vr_dscritic VARCHAR2(10000);

			-- Tratamento de erros
			vr_exc_saida EXCEPTION;
			vr_tab_erro  gene0001.typ_tab_erro;

			-- PL/Table com as informações do boleto
			vr_tab_cob cobr0005.typ_tab_cob;

			vr_des_reto VARCHAR2(3);

			-- Variáveis para geração do relatório
			vr_clobxml    CLOB;
			vr_dstextorel VARCHAR2(32600);
			vr_dstexto    VARCHAR2(32600);
			vr_nmdireto   VARCHAR2(1000);
			vr_dsparams   VARCHAR2(1000);
      vr_nmrescop   crapcop.nmrescop%TYPE;
	    
			vr_valords    NUMBER; 
			vr_valorad    NUMBER;

      -- variaveis do email
      vr_dscorema   VARCHAR2(4000); -- corpo do email                 
      vr_texto_email  VARCHAR2(4000);
      vr_des_erro VARCHAR2(4000);
      
       vr_flgativo INTEGER := 0;
			---------------------------- CURSORES -----------------------------------
			CURSOR cr_tbepr_cde(pr_cdcooper crapcop.cdcooper%TYPE
												 ,pr_nrctacob tbrecup_cobranca.nrdconta_cob%TYPE
												 ,pr_nrcnvcob tbrecup_cobranca.nrcnvcob%TYPE
												 ,pr_nrdocmto tbrecup_cobranca.nrboleto%TYPE) IS
				SELECT cde.nrdconta
              ,cde.nrctremp
					FROM tbrecup_cobranca cde
				 WHERE cde.cdcooper = pr_cdcooper
					 AND cde.nrdconta_cob = pr_nrctacob
					 AND cde.nrcnvcob = pr_nrcnvcob
					 AND cde.nrboleto = pr_nrdocmto;				 
	    rw_tbepr_cde cr_tbepr_cde%ROWTYPE;
		BEGIN

			---------------------------------- VALIDACOES INICIAIS --------------------------

				COBR0005.pc_buscar_titulo_cobranca(pr_cdcooper => pr_cdcooper
																					,pr_nrdconta => pr_nrdconta
																					,pr_nrcnvcob => pr_nrcnvcob
																					,pr_nrdocmto => pr_nrdocmto
																					,pr_cdoperad => pr_cdoperad
																					,pr_nriniseq => 1
																					,pr_nrregist => 1
																					,pr_cdcritic => vr_cdcritic
																					,pr_dscritic => vr_dscritic
																					,pr_tab_cob  => vr_tab_cob);

        -- Verifica se retornou alguma crítica
				IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
					 -- Gera exceção
					 RAISE vr_exc_saida;
				END IF;

				IF NOT vr_tab_cob.EXISTS(vr_tab_cob.FIRST) THEN
					 vr_cdcritic := 0;
					 vr_dscritic := 'Dados nao encontrados';
					 RAISE vr_exc_saida;
				END IF;
				
				-- Abre cursor de boleto de cobrança de emprestimo
				OPEN cr_tbepr_cde(pr_cdcooper => pr_cdcooper
				                 ,pr_nrctacob => pr_nrdconta
												 ,pr_nrcnvcob => pr_nrcnvcob
												 ,pr_nrdocmto => pr_nrdocmto);
	      FETCH cr_tbepr_cde INTO rw_tbepr_cde;
				
				-- Se não encontrou boleto de cobrança de emprestimo
				IF cr_tbepr_cde%NOTFOUND THEN
					-- Atribui crítca
					vr_cdcritic := 0;
					vr_dscritic := 'Boleto nao encontrado';
					-- Gera exceção
					RAISE vr_exc_saida;
				END IF;
				
         -- Verifica se retornou alguma crítica
				IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
					 -- Gera exceção
					 RAISE vr_exc_saida;
				END IF;

        -- Verifica contratos de acordo
        RECP0001.pc_verifica_acordo_ativo(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrctremp => rw_tbepr_cde.nrctremp
                                         ,pr_cdorigem => 3
                                         ,pr_flgativo => vr_flgativo
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          -- Gerar exceção
          RAISE vr_exc_saida;
        END IF;
            
        IF vr_flgativo = 1 THEN
          vr_dscritic := 'Geracao do boleto nao permitido, emprestimo em acordo.';
          -- Gerar exceção
          RAISE vr_exc_saida;
        END IF;

				-- Busca do diretório base da cooperativa para a geração de relatórios
				vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'          --> /usr/coop
																						,pr_cdcooper => pr_cdcooper  --> Cooperativa
																						,pr_nmsubdir => 'rl');       --> Utilizaremos o rl

				-- Inicializar as informações do XML de dados para o relatório
				dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
				dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
				--Escrever no arquivo XML
				gene0002.pc_escreve_xml(vr_clobxml, vr_dstextorel,'<?xml version="1.0" encoding="UTF-8"?><Root><Dados>');

				-- Removida instrução (PRJ 559 - Task 22167: Remover trava de instrução)
				vr_tab_cob(vr_tab_cob.FIRST).dsdinst1 := ' ';

				vr_dstexto :=               '<cdcooper>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).cdcooper, '') || '</cdcooper>';
				vr_dstexto := vr_dstexto || '<nrdconta>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nrdconta, '') || '</nrdconta>';
				vr_dstexto := vr_dstexto || '<idseqttl>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).idseqttl, '') || '</idseqttl>';
				vr_dstexto := vr_dstexto || '<nmprimtl>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nmprimtl, '') || '</nmprimtl>';
				vr_dstexto := vr_dstexto || '<incobran>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).incobran, '') || '</incobran>';
				vr_dstexto := vr_dstexto || '<nossonro>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nossonro, '') || '</nossonro>';
				vr_dstexto := vr_dstexto || '<nrctremp>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nrctremp, '') || '</nrctremp>';
				vr_dstexto := vr_dstexto || '<nmdsacad>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nmdsacad, '') || '</nmdsacad>';
				vr_dstexto := vr_dstexto || '<cdbandoc>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).cdbandoc, '') || '</cdbandoc>';
				vr_dstexto := vr_dstexto || '<nmdavali>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nmdavali, '') || '</nmdavali>';
				vr_dstexto := vr_dstexto || '<dsbandig>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsbandig, '') || '</dsbandig>';
				vr_dstexto := vr_dstexto || '<nrinsava>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nrinsava, '') || '</nrinsava>';
				vr_dstexto := vr_dstexto || '<cdtpinav>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).cdtpinav, '') || '</cdtpinav>';
				vr_dstexto := vr_dstexto || '<nrcnvcob>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nrcnvcob, '') || '</nrcnvcob>';
				vr_dstexto := vr_dstexto || '<nrcnvceb>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nrcnvceb, '') || '</nrcnvceb>';
				vr_dstexto := vr_dstexto || '<nrdctabb>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nrdctabb, '') || '</nrdctabb>';
				vr_dstexto := vr_dstexto || '<nrcpfcgc>' || NVL(gene0002.fn_mask_cpf_cnpj(vr_tab_cob(vr_tab_cob.FIRST).nrcpfcgc, vr_tab_cob(vr_tab_cob.FIRST).inpessoa), '') || '</nrcpfcgc>';
				vr_dstexto := vr_dstexto || '<inpessoa>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).inpessoa, '') || '</inpessoa>';
				vr_dstexto := vr_dstexto || '<nrdocmto>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nrdocmto, '') || '</nrdocmto>';
				vr_dstexto := vr_dstexto || '<dtmvtolt>' || NVL(TO_CHAR(vr_tab_cob(vr_tab_cob.FIRST).dtmvtolt, 'DD/MM/RRRR'), '') || '</dtmvtolt>';
				vr_dstexto := vr_dstexto || '<dsdinstr>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsdinstr, '') || '</dsdinstr>';
				vr_dstexto := vr_dstexto || '<dsdinst1>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsdinst1, '') || '</dsdinst1>';
				vr_dstexto := vr_dstexto || '<dsdinst2>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsdinst2, '') || '</dsdinst2>';
				vr_dstexto := vr_dstexto || '<dsdinst3>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsdinst3, '') || '</dsdinst3>';
				vr_dstexto := vr_dstexto || '<dsdinst4>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsdinst4, '') || '</dsdinst4>';
				vr_dstexto := vr_dstexto || '<dsdinst5>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsdinst5, '') || '</dsdinst5>';
				vr_dstexto := vr_dstexto || '<dsinform>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsinform, '') || '</dsinform>';
				vr_dstexto := vr_dstexto || '<dsinfor1>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsinfor1, '') || '</dsinfor1>';
				vr_dstexto := vr_dstexto || '<dsinfor2>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsinfor2, '') || '</dsinfor2>';
				vr_dstexto := vr_dstexto || '<dsinfor3>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsinfor3, '') || '</dsinfor3>';
				vr_dstexto := vr_dstexto || '<dsinfor4>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsinfor4, '') || '</dsinfor4>';
				vr_dstexto := vr_dstexto || '<dsinfor5>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsinfor5, '') || '</dsinfor5>';
				vr_dstexto := vr_dstexto || '<dslocpag>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dslocpag, '') || '</dslocpag>';
				vr_dstexto := vr_dstexto || '<dsavis2v>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsavis2v, '') || '</dsavis2v>';
				vr_dstexto := vr_dstexto || '<dsagebnf>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsagebnf, '') || '</dsagebnf>';
				vr_dstexto := vr_dstexto || '<dspagad1>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dspagad1, '') || '</dspagad1>';
				vr_dstexto := vr_dstexto || '<dspagad2>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dspagad2, '') || '</dspagad2>';
				vr_dstexto := vr_dstexto || '<dspagad3>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dspagad3, '') || '</dspagad3>';
				vr_dstexto := vr_dstexto || '<dssacava>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dssacava, '') || '</dssacava>';
				vr_dstexto := vr_dstexto || '<dsdoccop>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsdoccop, '') || '</dsdoccop>';
				vr_dstexto := vr_dstexto || '<dtvencto>' || NVL(TO_CHAR(vr_tab_cob(vr_tab_cob.FIRST).dtvencto, 'DD/MM/RRRR'), '') || '</dtvencto>';
				vr_dstexto := vr_dstexto || '<vltitulo>' || to_char(NVL(vr_tab_cob(vr_tab_cob.FIRST).vltitulo, 0), 'fm999G999G990D00','NLS_NUMERIC_CHARACTERS = '',.''')  || '</vltitulo>';
				vr_dstexto := vr_dstexto || '<vldescto>' || to_char(NVL(vr_tab_cob(vr_tab_cob.FIRST).vldescto, 0), 'fm999G999G990D00','NLS_NUMERIC_CHARACTERS = '',.''') || '</vldescto>';
				vr_dstexto := vr_dstexto || '<vlabatim>' || to_char(NVL(vr_tab_cob(vr_tab_cob.FIRST).vlabatim, 0), 'fm999G999G990D00','NLS_NUMERIC_CHARACTERS = '',.''') || '</vlabatim>';
			 
        -- Valor Desconto
        vr_valords := NVL(vr_tab_cob(vr_tab_cob.FIRST).vldescto, 0) + NVL(vr_tab_cob(vr_tab_cob.FIRST).vlabatim, 0);
        vr_dstexto := vr_dstexto || '<valordes>' || to_char(NVL(vr_valords, 0), 'fm999G999G990D00','NLS_NUMERIC_CHARACTERS = '',.''') || '</valordes>';
        
        --Valor Adicional
        vr_valorad := NVL(vr_tab_cob(vr_tab_cob.FIRST).vlrmulta, 0) + NVL(vr_tab_cob(vr_tab_cob.FIRST).vlrjuros, 0);
        vr_dstexto := vr_dstexto || '<valoradi>' || to_char(NVL(vr_valorad, 0), 'fm999G999G990D00','NLS_NUMERIC_CHARACTERS = '',.''') || '</valoradi>';
        
				vr_dstexto := vr_dstexto || '<vlrmulta>' || to_char(NVL(vr_tab_cob(vr_tab_cob.FIRST).vlrmulta, 0), 'fm999G999G990D00','NLS_NUMERIC_CHARACTERS = '',.''') || '</vlrmulta>';
				vr_dstexto := vr_dstexto || '<vlrjuros>' || to_char(NVL(vr_tab_cob(vr_tab_cob.FIRST).vlrjuros, 0), 'fm999G999G990D00','NLS_NUMERIC_CHARACTERS = '',.''') || '</vlrjuros>';
				vr_dstexto := vr_dstexto || '<cddespec>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).cddespec, '') || '</cddespec>';
				vr_dstexto := vr_dstexto || '<dsdespec>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsdespec, '') || '</dsdespec>';
				vr_dstexto := vr_dstexto || '<dtdocmto>' || NVL(TO_CHAR(vr_tab_cob(vr_tab_cob.FIRST).dtdocmto, 'DD/MM/RRRR'), '') || '</dtdocmto>';
				vr_dstexto := vr_dstexto || '<cdcartei>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).cdcartei, '') || '</cdcartei>';
				vr_dstexto := vr_dstexto || '<nrvarcar>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nrvarcar, '') || '</nrvarcar>';
				vr_dstexto := vr_dstexto || '<cdagenci>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).cdagenci, '') || '</cdagenci>';
				vr_dstexto := vr_dstexto || '<nrnosnum>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nrnosnum, '') || '</nrnosnum>';
				vr_dstexto := vr_dstexto || '<flgaceit>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).flgaceit, '') || '</flgaceit>';
				vr_dstexto := vr_dstexto || '<agencidv>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).agencidv, '') || '</agencidv>';
				vr_dstexto := vr_dstexto || '<vldocmto>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).vldocmto, '') || '</vldocmto>';
				vr_dstexto := vr_dstexto || '<vlmormul>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).vlmormul, '') || '</vlmormul>';
				vr_dstexto := vr_dstexto || '<dtvctori>' || NVL(TO_CHAR(vr_tab_cob(vr_tab_cob.FIRST).dtvctori, 'DD/MM/RRRR'), '') || '</dtvctori>';
				vr_dstexto := vr_dstexto || '<dscjuros>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dscjuros, '') || '</dscjuros>';
				vr_dstexto := vr_dstexto || '<dscmulta>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dscmulta, '') || '</dscmulta>';
				vr_dstexto := vr_dstexto || '<dscdscto>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dscdscto, '') || '</dscdscto>';
				vr_dstexto := vr_dstexto || '<dsinssac>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsinssac, '') || '</dsinssac>';
				vr_dstexto := vr_dstexto || '<vldesabt>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).vldesabt, '') || '</vldesabt>';
				vr_dstexto := vr_dstexto || '<vljurmul>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).vljurmul, '') || '</vljurmul>';
				vr_dstexto := vr_dstexto || '<inemiten>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).inemiten, '') || '</inemiten>';
				vr_dstexto := vr_dstexto || '<dsemiten>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsemiten, '') || '</dsemiten>';
				vr_dstexto := vr_dstexto || '<dsemitnt>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsemitnt, '') || '</dsemitnt>';
				vr_dstexto := vr_dstexto || '<cdbarras>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).cdbarras, '') || '</cdbarras>';
				vr_dstexto := vr_dstexto || '<lindigit>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).lindigit, '') || '</lindigit>';

				gene0002.pc_escreve_xml(vr_clobxml, vr_dstextorel, vr_dstexto);
				-- Fechar arquivo XML
				gene0002.pc_escreve_xml(vr_clobxml, vr_dstextorel, '</Dados></Root>', TRUE);

				pr_nmarqpdf := 'boleto_' || vr_tab_cob(1).nrdconta
																 || vr_tab_cob(1).nrctremp
                                 || TO_CHAR(SYSDATE,'SSSSS')
																 || '.pdf';

				-- Busca caminho da imagem do logo do boleto da cecred
				vr_dsparams := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
																								,pr_cdcooper => 0
																								,pr_cdacesso => 'IMG_BOLETO_085');

        -- Envia relatório por email
        IF pr_tpdenvio = 1 THEN
          
          -- buscar nome da cooperativa
          SELECT cop.nmrescop INTO vr_nmrescop
            FROM crapcop cop
           WHERE cop.cdcooper = pr_cdcooper;
        
          vr_texto_email := gene0001.fn_param_sistema(pr_cdcooper => vr_tab_cob(vr_tab_cob.FIRST).cdcooper
                                                     ,pr_nmsistem => 'CRED'
                                                     ,pr_cdacesso => 'COBEMP_TXT_EMAIL');

          vr_texto_email := REPLACE(vr_texto_email,'#Cooperativa#',vr_nmrescop);
          vr_texto_email := REPLACE(vr_texto_email,'#Cooperado#',vr_tab_cob(vr_tab_cob.FIRST).dspagad1);
          vr_texto_email := REPLACE(vr_texto_email,'#LinhaDigitavel#',vr_tab_cob(vr_tab_cob.FIRST).lindigit);
          vr_texto_email := REPLACE(vr_texto_email,'#Contrato#',to_char(vr_tab_cob(vr_tab_cob.FIRST).nrctremp)); -- Emprestimo
          vr_texto_email := REPLACE(vr_texto_email,'#Bordero#',to_char(vr_tab_cob(vr_tab_cob.FIRST).nrctremp)); -- Desconto de titulo
          vr_texto_email := REPLACE(vr_texto_email,'#Valor#',vr_tab_cob(vr_tab_cob.FIRST).vltitulo);
          vr_texto_email := REPLACE(vr_texto_email,'#Vencimento#',to_char(vr_tab_cob(vr_tab_cob.FIRST).dtvencto,'DD/MM/YYYY'));
          vr_texto_email := REPLACE(vr_texto_email,'#Email#',pr_dsdemail);
          
          -- corpo do email
          vr_dscorema := '<meta http-equiv="Content-Type" content="text/html;charset=utf-8" >' || vr_texto_email || '</meta>';
					
 					-- Gera impressão do boleto
					gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                   --> Cooperativa conectada
																		 ,pr_cdprogra  => 'COBEMP'                      --> Programa chamador
																		 ,pr_dtmvtolt  => TRUNC(SYSDATE)                --> Data do movimento atual
																		 ,pr_dsxml     => vr_clobxml                    --> Arquivo XML de dados
																		 ,pr_dsxmlnode => '/Root/Dados'                 --> Nó base do XML para leitura dos dados
																		 ,pr_dsjasper  => 'boleto.jasper'               --> Arquivo de layout do iReport
																		 ,pr_dsparams  => 'PR_IMGDLOGO##' || vr_dsparams--> Parametros do boleto
																		 ,pr_dsarqsaid => vr_nmdireto||'/'||pr_nmarqpdf --> Arquivo final com o path
																		 ,pr_qtcoluna  => 132                           --> Colunas do relatorio
																		 ,pr_cdrelato  => '702'                         --> Cód. relatório
                                     ,pr_flg_gerar => 'S'                           --> gerar PDF
 																		 ,pr_dsmailcop  => pr_dsdemail                  --> Email
																		 ,pr_dsassmail => 'Boleto Bancario - AILOS 085' --> Assunto do e-mail que enviará o arquivo
																		 ,pr_dscormail => vr_dscorema                   --> Corpor do email
																		 ,pr_nmformul  => '132col'                      --> Nome do formulário para impressão
																		 ,pr_nrcopias  => 1                             --> Número de cópias
																		 ,pr_des_erro  => vr_dscritic);                 --> Saída com erro
                                     
          IF vr_dscritic IS NOT NULL THEN             
             RAISE vr_exc_saida;
          END IF;
					
				ELSE                  
					
          EMPR0007.pc_enviar_boleto(pr_cdcooper => vr_tab_cob(vr_tab_cob.FIRST).cdcooper
																	 ,pr_nrdconta => rw_tbepr_cde.nrdconta
																	 ,pr_nrctremp => vr_tab_cob(vr_tab_cob.FIRST).nrctremp
																	 ,pr_nrctacob => vr_tab_cob(vr_tab_cob.FIRST).nrdconta
																	 ,pr_nrcnvcob => vr_tab_cob(vr_tab_cob.FIRST).nrcnvcob
																	 ,pr_nrdocmto => vr_tab_cob(vr_tab_cob.FIRST).nrdocmto
																	 ,pr_cdoperad => pr_cdoperad
																	 ,pr_nmcontat => vr_tab_cob(vr_tab_cob.FIRST).nmprimtl
																	 ,pr_tpdenvio => 3 /* IMPRESSAO */
																	 ,pr_nmdatela => 'COBEMP'
																	 ,pr_idorigem => pr_idorigem
																	 ,pr_cdcritic => vr_cdcritic
																	 ,pr_dscritic => vr_dscritic);

					 -- Verifica se retornou alguma crítica
					IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
						 -- Gera exceção
						 RAISE vr_exc_saida;
					END IF;

					-- Gera impressão do boleto
					gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                   --> Cooperativa conectada
																		 ,pr_cdprogra  => 'COBEMP'                      --> Programa chamador
																		 ,pr_dtmvtolt  => TRUNC(SYSDATE)                --> Data do movimento atual
																		 ,pr_dsxml     => vr_clobxml                    --> Arquivo XML de dados
																		 ,pr_dsxmlnode => '/Root/Dados'                 --> Nó base do XML para leitura dos dados
																		 ,pr_dsjasper  => 'boleto.jasper'               --> Arquivo de layout do iReport
																		 ,pr_dsparams  => 'PR_IMGDLOGO##' || vr_dsparams--> Parametros do boleto
																		 ,pr_dsarqsaid => vr_nmdireto||'/'||pr_nmarqpdf --> Arquivo final com o path
																		 ,pr_qtcoluna  => 132                           --> Colunas do relatorio
																		 ,pr_cdrelato  => '702'                         --> Cód. relatório
																		 ,pr_flg_gerar => 'S'                           --> Geraçao na hora
																		 ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
																		 ,pr_nmformul  => '132col'                      --> Nome do formulário para impressão
																		 ,pr_nrcopias  => 1                             --> Número de cópias
																		 ,pr_des_erro  => vr_dscritic);                 --> Saída com erro
																		 
					--Se ocorreu erro no relatorio
					IF vr_dscritic IS NOT NULL THEN
						--Levantar Excecao
						RAISE vr_exc_saida;
					END IF;
					
					gene0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper    --Codigo Cooperativa
																		  ,pr_cdagenci => 1              --Codigo Agencia
																		  ,pr_nrdcaixa => 1
																		  ,pr_nmarqpdf => vr_nmdireto || '/' || pr_nmarqpdf    --Nome Arquivo PDF
                                      ,pr_des_reto => vr_des_reto    --Retorno OK/NOK
																		  ,pr_tab_erro => vr_tab_erro);  --Tabela erro

				  --Se ocorreu erro
				  IF vr_des_reto <> 'OK' THEN
					  --Se tem erro na tabela
						IF vr_tab_erro.COUNT > 0 THEN
							vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
						ELSE
							vr_dscritic:= 'Erro ao enviar arquivo para web.';
						END IF;
					  --Sair
					  RAISE vr_exc_saida;
				  END IF;
												 
					-- Remover relatorio da pasta rl apos gerar
					gene0001.pc_OScommand(pr_typ_comando => 'S'
															 ,pr_des_comando => 'rm ' || vr_nmdireto || '/' ||
																									pr_nmarqpdf
															 ,pr_typ_saida   => vr_des_reto
															 ,pr_des_saida   => vr_dscritic);
					-- Se retornou erro
					IF vr_des_reto = 'ERR'
						 OR vr_dscritic IS NOT null THEN
						-- Concatena o erro que veio
						vr_dscritic := 'Erro ao remover arquivo: ' || vr_dscritic;
						RAISE vr_exc_saida;
					END IF;

        END IF;

				--Fechar Clob e Liberar Memoria
				dbms_lob.close(vr_clobxml);
				dbms_lob.freetemporary(vr_clobxml);

        pr_des_erro := 'OK';

		EXCEPTION
			WHEN vr_exc_saida THEN

				-- Busca descrição da crítica se houver código
				IF vr_cdcritic <> 0 THEN
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				ELSE
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;
				
        pr_des_erro := 'NOK';
				
		WHEN OTHERS THEN

			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela TELA_COBEMP: ' || SQLERRM;
      pr_des_erro := 'NOK';
		END;
	END pc_gerar_pdf_boletos;

  -- Procedure para calcular a data de pagamento para contratos TR
  PROCEDURE pc_gera_data_pag_tr(pr_cdcooper IN tbrecup_cobranca.cdcooper%TYPE --> Codigo da Cooperativa
                               ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE        --> Data do Movimento
                               ,pr_nrdconta IN tbrecup_cobranca.nrdconta%TYPE --> Numero da conta
                               ,pr_nrctremp IN tbrecup_cobranca.nrctremp%TYPE --> Numero do contrato
                               ,pr_vlpreemp IN crapepr.vlpreemp %TYPE       --> Valor da prestacao
                               ,pr_dtdpagto IN OUT crapepr.dtdpagto%TYPE    --> Data do pagamento
                               ,pr_dtvencto IN crawepr.dtvencto%TYPE        --> Data vencimento
                               ,pr_cdcritic OUT PLS_INTEGER                 --> Codigo da critica
                               ,pr_dscritic OUT VARCHAR2) IS                --> Descricao da critica
  BEGIN
    /* .............................................................................
      Programa: pc_gera_data_pag_tr
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Jaison Fernando
      Data    : Janeiro/2017.                    Ultima atualizacao: 

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina referente a geracao da data de pagamento

      Observacao: -----

      Alteracoes: 
    ..............................................................................*/

    DECLARE

    ------------------------------- VARIAVEIS -------------------------------
		-- Variáveis para o tratamento de erros
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
		
		-- Variaveis locais
    vr_dtdpagto DATE;
    vr_vltotpag NUMBER := 0;
    vr_qtprepag INTEGER;
    vr_qtanopag INTEGER;

    -------------------------- TABELAS TEMPORARIAS --------------------------

    ------------------------------- CURSORES --------------------------------
		
		-- Cursor lancamentos de emprestimo
    CURSOR cr_craplem(pr_cdcooper IN craplem.cdcooper%TYPE
                     ,pr_nrdconta IN craplem.nrdconta%TYPE
                     ,pr_nrctremp IN craplem.nrctremp%TYPE) IS
			SELECT craplem.cdhistor
						,craplem.vllanmto
				FROM craplem
			 WHERE craplem.cdcooper = pr_cdcooper
				 AND craplem.nrdconta = pr_nrdconta
				 AND craplem.nrctremp = pr_nrctremp;

    BEGIN

      -- Monta proxima data de pagamento
      vr_dtdpagto := to_date(to_char(pr_dtdpagto,'DD')
                          || to_char(pr_dtvencto,'MM')
                          || to_char(pr_dtvencto,'YYYY'),'ddmmyyyy');

      -- Listagem de lancamentos de emprestimo
      FOR rw_craplem IN cr_craplem(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctremp => pr_nrctremp) LOOP

        IF rw_craplem.cdhistor = 91  OR   -- Pagto LANDPV
           rw_craplem.cdhistor = 92  OR   -- Empr.Consig.Caixa On_line
           rw_craplem.cdhistor = 93  OR   -- Emprestimo Consignado
           rw_craplem.cdhistor = 95  OR   -- Pagto crps120
           rw_craplem.cdhistor = 393 OR   -- Pagto Avalista
           rw_craplem.cdhistor = 353 THEN -- Transf. Cotas
           vr_vltotpag := vr_vltotpag + rw_craplem.vllanmto;
        ELSIF rw_craplem.cdhistor = 88  OR
              rw_craplem.cdhistor = 507 THEN -- Est.Transf.Cot
              vr_vltotpag := vr_vltotpag - rw_craplem.vllanmto;
        END IF;

      END LOOP;

      -- Calcula a quantidade de prestacao
      vr_qtprepag := TRUNC(vr_vltotpag / pr_vlpreemp, 0);

      -- Calcula a nova data de pagamento de acordo com a
      -- quantidade de prestacoes pagas, incluindo o lancamento atual
      vr_qtanopag := TRUNC(vr_qtprepag / 12, 0);
      vr_qtprepag := MOD(vr_qtprepag, 12);
      vr_dtdpagto := GENE0005.fn_calc_data(pr_dtmvtolt => vr_dtdpagto
                                          ,pr_qtmesano => vr_qtprepag
                                          ,pr_tpmesano => 'M'
                                          ,pr_des_erro => vr_dscritic);
      -- Parar se encontrar erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      IF vr_qtanopag > 0 THEN
        vr_dtdpagto := GENE0005.fn_calc_data(pr_dtmvtolt => vr_dtdpagto
                                            ,pr_qtmesano => vr_qtanopag
                                            ,pr_tpmesano => 'A'
                                            ,pr_des_erro => vr_dscritic);
        -- Parar se encontrar erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      END IF;

      IF vr_dtdpagto > pr_dtmvtolt                                   AND
        (to_char(vr_dtdpagto,'MM')   <> to_char(pr_dtmvtolt,'MM')    OR
         to_char(vr_dtdpagto,'YYYY') <> to_char(pr_dtmvtolt,'YYYY')) THEN
        vr_dtdpagto := GENE0005.fn_calc_data(pr_dtmvtolt => to_date(to_char(vr_dtdpagto,'DD')
                                                         || to_char(pr_dtmvtolt,'MM')
                                                         || to_char(pr_dtmvtolt,'YYYY'),'ddmmyyyy')
                                            ,pr_qtmesano => 1
                                            ,pr_tpmesano => 'M'
                                            ,pr_des_erro => vr_dscritic);
         -- Parar se encontrar erro
         IF vr_dscritic IS NOT NULL THEN
           RAISE vr_exc_saida;
         END IF;
       END IF;

       -- Retorna a data
       pr_dtdpagto := vr_dtdpagto;

    EXCEPTION	
		  WHEN vr_exc_saida THEN
				-- Se possui código de crítica e não foi informado a descrição
				IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					 -- Busca descrição da crítica
					 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
				END IF;

				-- Atribui exceção para os parametros de crítica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;

			WHEN OTHERS THEN  				
				-- Atribui exceção para os parametros de crítica				
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := 'Erro nao tratado na EMPR0007.pc_gera_data_pag_tr: ' || SQLERRM;			

    END;

  END pc_gera_data_pag_tr;
  
END EMPR0007;
/
