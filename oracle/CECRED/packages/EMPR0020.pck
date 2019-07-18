CREATE OR REPLACE PACKAGE CECRED.EMPR0020 IS
 /* -----------------------------------------------------------------------------------

    Programa: EMPR0020
    Autor   : Fernanda Kelli de Oliveira / AMcom
    Data    : 02/05/2019    ultima Atualizacao: --

    Dados referentes ao programa:

    Objetivo  : Concentrar rotinas referente ao processo do Crédito Consignado

    Alteracoes:

    ..............................................................................*/

  PROCEDURE pc_validar_dtpgto_antecipada(pr_xmllog      IN VARCHAR2              --> XML com informacoes de LOG
                                        ,pr_cdcritic   OUT PLS_INTEGER           --> Codigo da critica
                                        ,pr_dscritic   OUT VARCHAR2              --> Descricao da critica
                                        ,pr_retxml      IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo   OUT VARCHAR2              --> Nome do campo com erro
                                        ,pr_des_erro   OUT VARCHAR2);            --> Erros do processo
                                                                     
  PROCEDURE pc_efetua_debito_conveniada(pr_cdcooper     IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                       ,pr_cdempres     IN crapemp.cdempres%TYPE --> Código da Empresa que receberá o débito
                                       ,pr_cdoperad     IN VARCHAR2              --> Operador da Consulta – Valor 'xxxxx' para Internet
                                       ,pr_cdorigem     IN PLS_INTEGER           --> Aplicação de Origem da chamada do Serviço
                                       ,pr_nrdcaixa     IN INTEGER               --> Código de caixa do canal de atendimento – Valor 'XXXX' para Internet
                                       ,pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE --> Data do movimento atual.
                                       ,pr_vrdebito     IN NUMBER                --> Valor a ser debitado   
                                       ,pr_idpagto      IN NUMBER                --> Identificador de pagamento enviado pelo consumidor
                                       ,pr_dscritic    OUT VARCHAR2              --> Descrição da crítica          
                                       ,pr_retorno      OUT xmltype);   
                                       
  PROCEDURE pc_efetiva_pagto_parc_consig(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                        ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Código da agência
                                        ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Número do caixa
                                        ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> Código do Operador
                                        ,pr_nmdatela    IN VARCHAR2              --> Nome da tela
                                        ,pr_idorigem    IN INTEGER               --> Id do módulo de sistema
                                        ,pr_cdpactra    IN INTEGER               --> P.A. da transação
                                        ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> Número da conta
                                        ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                        ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                        ,pr_flgerlog    IN VARCHAR2              --> Indicador S/N para geração de log
                                        ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                        ,pr_nrparepr    IN INTEGER               --> Número parcelas empréstimo
                                        ,pr_vlparepr    IN NUMBER                --> Valor da parcela emprestimo
                                        ,pr_vlparcel    IN NUMBER                --> valor da parcela
                                        ,pr_dtvencto    IN crappep.dtvencto%TYPE --> Vencimento da parcela
                                        ,pr_cdlcremp    IN crapepr.cdlcremp%TYPE --> Linha de crédito
                                        ,pr_tppagmto    IN VARCHAR2              --> Tipo Pagamento - "D" -Em Dia, "A"- Em Atraso                                        
                                        ,pr_vlrmulta    IN crappep.vlpagmta%TYPE --> Valor da multa
                                        ,pr_vlatraso    IN crappep.vlpagmra %TYPE--> Valor Juros de mora
                                        ,pr_vliofcpl    IN crappep.vliofcpl%TYPE --> Valor do IOF complementar de atraso
                                        ,pr_nrseqava    IN NUMBER DEFAULT 0      --> Pagamento: Sequencia do avalista
                                        ,pr_des_reto    OUT VARCHAR              --> Retorno OK / NOK
                                        ,pr_tab_erro    OUT gene0001.typ_tab_erro);

  PROCEDURE pc_atualiza_tbepr_consig_pagto(pr_cdcooper     IN tbepr_consignado_pagamento.cdcooper%TYPE,
                                           pr_nrdconta     IN tbepr_consignado_pagamento.nrdconta%TYPE,
                                           pr_nrctremp     IN tbepr_consignado_pagamento.nrctremp%TYPE,
                                           pr_nrparepr     IN tbepr_consignado_pagamento.nrparepr%TYPE,
                                           pr_vlparepr     IN tbepr_consignado_pagamento.vlparepr%TYPE,
                                           pr_vlpagpar     IN tbepr_consignado_pagamento.vlpagpar%TYPE,
                                           pr_dtvencto     IN tbepr_consignado_pagamento.dtvencto%TYPE,
                                           pr_instatus     IN tbepr_consignado_pagamento.instatus%TYPE,
                                           pr_cdagenci     IN tbepr_consignado_pagamento.cdagenci%TYPE,
                                           pr_cdbccxlt     IN tbepr_consignado_pagamento.cdbccxlt%TYPE,
                                           pr_cdoperad      IN tbepr_consignado_pagamento.cdoperad%TYPE,
                                           pr_idsequencia  IN OUT tbepr_consignado_pagamento.idsequencia%TYPE,
                                           pr_dscritic    OUT VARCHAR2 );

  FUNCTION fn_ret_status_pagto_consignado (pr_cdcooper    IN tbepr_consignado_pagamento.cdcooper%TYPE,
                                           pr_nrdconta    IN tbepr_consignado_pagamento.nrdconta%TYPE,
                                           pr_nrctremp    IN tbepr_consignado_pagamento.nrctremp%TYPE,
                                           pr_nrparepr    IN tbepr_consignado_pagamento.nrparepr%TYPE,                    
                                           pr_instatus    IN tbepr_consignado_pagamento.instatus%type)  RETURN NUMBER; 
                                            
  PROCEDURE pc_gera_pgto_parc_consig_web(pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                         -- OUT
                                        ,pr_cdcritic OUT PLS_INTEGER                   --> Codigo da critica
                                        ,pr_dscritic OUT VARCHAR2                      --> Descric?o da critica
                                        ,pr_retxml   IN OUT NOCOPY XMLType             --> Arquivo de retorno do XML
                                        ,pr_tpdescto OUT crapepr.tpdescto%type         --> Tipo desconto emprestimo
                                        ,pr_des_erro OUT VARCHAR2);
                                        
  PROCEDURE pc_gera_pgto_parcelas_consig(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                        ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                        ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                        ,pr_cdoperad IN VARCHAR2              --> Código do operador
                                        ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                                        ,pr_idorigem IN INTEGER               --> Id Origem do sistemas
                                        ,pr_cdpactra IN INTEGER               --> P.A. da transação
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da Conta
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Id do titular da conta
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de Movimento
                                        ,pr_flgerlog IN VARCHAR2              --> Gera log S/N
                                        ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Nr. do contrato de emprestimo
                                        ,pr_dtmvtoan IN crapdat.dtmvtoan%TYPE --> Data de movimento do dia anterior
                                        ,pr_totatual IN crapepr.vlemprst%TYPE
                                        ,pr_totpagto IN crapepr.vlemprst%TYPE
                                        ,pr_nrseqava IN NUMBER DEFAULT 0      --> Pagamento: Sequencia do avalista
															   			  ,pr_tab_pgto_parcel IN OUT empr0001.typ_tab_pgto_parcel
                                        ,pr_xmlpagto OUT xmltype
																				,pr_des_reto OUT VARCHAR
                                        ,pr_tab_erro OUT gene0001.typ_tab_erro); 
   
                                           
   PROCEDURE pc_valida_pagto_parc_consig(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Código da agência
                                    ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Número do caixa
                                    ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> Código do Operador
                                    ,pr_nmdatela    IN VARCHAR2 --> Nome da tela
                                    ,pr_idorigem    IN INTEGER --> Id do módulo de sistema
                                    ,pr_cdpactra    IN INTEGER --> P.A. da transação
                                    ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> Número da conta
                                    ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                    ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                    ,pr_flgerlog    IN VARCHAR2 --> Indicador S/N para geração de log
                                    ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                    ,pr_nrparepr    IN INTEGER --> Número parcelas empréstimo
                                    ,pr_vlparepr    IN NUMBER --> Valor da parcela emprestimo
                                    ,pr_tab_crawepr IN empr0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                    ,pr_nrseqava    IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                    ,pr_floperac    IN BOOLEAN
                                    ,pr_des_reto    OUT VARCHAR --> Retorno OK / NOK
                                    ,pr_tab_erro    OUT gene0001.typ_tab_erro); 
                                    
   PROCEDURE pc_valida_pagto_atraso_consig(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                           ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Código da agência
                                           ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Número do caixa
                                           ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> Código do Operador
                                           ,pr_nmdatela    IN VARCHAR2 --> Nome da tela
                                           ,pr_idorigem    IN INTEGER --> Id do módulo de sistema
                                           ,pr_cdpactra    IN INTEGER --> P.A. da transação
                                           ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> Número da conta
                                           ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                           ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                           ,pr_flgerlog    IN VARCHAR2 --> Indicador S/N para geração de log
                                           ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                           ,pr_nrparepr    IN INTEGER --> Número parcelas empréstimo
                                           ,pr_vlpagpar    IN NUMBER --> Valor a pagar parcela
                                           ,pr_tab_crawepr IN empr0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                           ,pr_nrseqava    IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                           ,pr_floperac    IN BOOLEAN
                                           ,pr_des_reto    OUT VARCHAR --> Retorno OK / NOK
                                           ,pr_tab_erro    OUT gene0001.typ_tab_erro);

   PROCEDURE pr_valida_pagto_antec_consig (pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                           ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Código da agência
                                           ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Número do caixa
                                           ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> Código do Operador
                                           ,pr_nmdatela    IN VARCHAR2              --> Nome da tela
                                           ,pr_idorigem    IN INTEGER               --> Id do módulo de sistema
                                           ,pr_cdpactra    IN INTEGER               --> P.A. da transação
                                           ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> Número da conta
                                           ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                           ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                           ,pr_flgerlog    IN VARCHAR2              --> Indicador S/N para geração de log
                                           ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                           ,pr_nrparepr    IN INTEGER               --> Número parcelas empréstimo
                                           ,pr_vlpagpar    IN NUMBER                --> Valor a pagar parcela
                                           ,pr_vlparrec    IN NUMBER                --> valor da parcela recalculado
                                           ,pr_tab_crawepr IN empr0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                           ,pr_nrseqava    IN NUMBER DEFAULT 0       --> Pagamento: Sequencia do avalista
                                           ,pr_floperac    IN BOOLEAN
                                           ,pr_des_reto    OUT VARCHAR               --> Retorno OK / NOK
                                           ,pr_tab_erro    OUT gene0001.typ_tab_erro);
   
  PROCEDURE pc_verifica_parc_ant_consig(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                       ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                       ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                       ,pr_nrparepr IN INTEGER --> Número parcelas empréstimo
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                       ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                       ,pr_dscritic OUT VARCHAR2);
   
   PROCEDURE pc_verifica_parc_antec_consig(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
	 																			  ,pr_nrdconta IN crapepr.nrdconta%TYPE  --> Conta
																				  ,pr_nrctremp IN crapepr.nrctremp%TYPE  --> Contrato
																				  ,pr_nrparepr IN crappep.nrparepr%TYPE  --> Nr. da parcela
																				  ,pr_dtmvtolt IN crapepr.dtmvtolt%TYPE  --> Data de movimento
																				  ,pr_des_reto OUT VARCHAR2              --> Retorno OK/NOK
																				  ,pr_dscritic OUT VARCHAR2);                                        
  PROCEDURE pc_grava_evento_consig_web(pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                       -- OUT
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descric?o da critica
                                      ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                      ,pr_tpdescto OUT crapepr.tpdescto%type --> Tipo desconto emprestimo
                                      ,pr_des_erro OUT VARCHAR2);
  
   PROCEDURE pc_gera_xml_pagamento_consig(pr_cdcooper     IN crapepr.cdcooper%TYPE, -- código da cooperativa
                                          pr_nrdconta     IN crapepr.nrdconta%TYPE, -- Número da conta
                                          pr_nrctremp     IN crapepr.nrctremp%TYPE, -- Número do contrato de emprestimo
                                          pr_xml_parcelas IN VARCHAR2,             -- xml com as parcelas a serem pagas 
                                          pr_tpenvio      IN NUMBER,                -- Tipo de envio (1-INSTALLMENT_SETTLEMENT, 2-REVERSAL_SETTLEMENT,3-CONTRACT_SETTLEMENT, 4-DEFAULTING_INSTALLMENT_SETTLEMENT)
                                          pr_tptransa     IN VARCHAR2,              -- tipo transação (DEBITO, ESTORNO DEBITO)
                                          pr_dsxmlali    OUT XmlType,               -- XML de saida do pagamento
                                          pr_dscritic    OUT VARCHAR2);
  
                                          
   PROCEDURE pc_grava_evento_prop_consig(pr_cdcooper    IN crapepr.cdcooper%TYPE, -- código da cooperativa
                                         pr_nrdconta    IN crapepr.nrdconta%TYPE, -- Número da conta
                                         pr_nrctremp    IN crapepr.nrctremp%TYPE, -- Número do contrato de emprestimo
                                         pr_dscritic   OUT VARCHAR2);
   
   PROCEDURE pc_gera_xml_efet_prop_consig(pr_cdcooper    IN crapepr.cdcooper%TYPE, -- código da cooperativa
                                          pr_nrdconta    IN crapepr.nrdconta%TYPE, -- Número da conta
                                          pr_nrctremp    IN crapepr.nrctremp%TYPE, -- Número do contrato de emprestimo
                                          pr_dsxmlali   OUT XmlType,               -- XML de saida do pagamento
                                          pr_dscritic   OUT VARCHAR2);
                                                                                    
   PROCEDURE  pc_envia_email_erro_int_consig(pr_cdcooper    IN crapepr.cdcooper%TYPE, --Cooperativa
                                              pr_nrdconta    IN crapepr.nrdconta%TYPE, --Conta
                                              pr_nrctremp    IN crapepr.nrctremp%TYPE, --Contrato
                                              pr_nrparepr    IN crappep.nrparepr%TYPE default null, --Parcela (Opcional)
                                              pr_idoperacao  IN NUMBER default null, --ID Operacao (Opcional)
                                              pr_tipoemail   IN VARCHAR2, --Tipo de Email 
                                              pr_msg         IN VARCHAR2, --Mensagem_erro_origem
                                              pr_dscritic    OUT VARCHAR2,
                                              pr_retxml      OUT xmltype
                                               );

   PROCEDURE pc_alt_emp_cooperado_desligado(pr_cdcooper      IN crapepr.cdcooper%TYPE  --> Cooperativa
                                           ,pr_nrdconta      IN crapepr.nrdconta%TYPE  --> Conta
                                           ,pr_flgdesligado  IN VARCHAR2               --> Indica se o cliente foi desligado (1 = Sim / 2 = Nao)
                                           -- campos padrões
                                           ,pr_cdcritic      OUT PLS_INTEGER           --> Codigo da critica
                                           ,pr_dscritic      OUT VARCHAR2              --> Descricao da critica
                                           ,pr_des_erro      OUT VARCHAR2              --> Erros do processo
                                           );  
                                        
  PROCEDURE pc_busca_dados_soa_fis_calcula (-- campos padrões
                                            pr_xmllog             IN VARCHAR2              --> XML com informacoes de LOG
                                           ,pr_cdcritic          OUT PLS_INTEGER           --> Codigo da critica
                                           ,pr_dscritic          OUT VARCHAR2              --> Descricao da critica
                                           ,pr_retxml             IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                           ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                                           ,pr_des_erro          OUT VARCHAR2              --> Erros do processo
                                           );  
                                           
  PROCEDURE prc_log_erro_soa_fis_calcula(-- campos padrões
                                          pr_xmllog             IN VARCHAR2              --> XML com informacoes de LOG
                                         ,pr_cdcritic          OUT PLS_INTEGER           --> Codigo da critica
                                         ,pr_dscritic          OUT VARCHAR2              --> Descricao da critica
                                         ,pr_retxml             IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                                         ,pr_des_erro          OUT VARCHAR2              --> Erros do processo
                                         );                                                                                                                             

  PROCEDURE pc_atualiza_tbepr_consignado(pr_nrdconta         IN tbepr_consignado.nrdconta%TYPE     --> Conta
                                        ,pr_nrctremp         IN tbepr_consignado.nrctremp%TYPE     --> Contrato
                                        ,pr_pejuro_anual     IN tbepr_consignado.pejuro_anual%TYPE --> Percentual da taxa de juros anual
                                        ,pr_pecet_anual      IN tbepr_consignado.pecet_anual%TYPE  --> Percentual CET
                                         -- campos padrões
                                        ,pr_xmllog             IN VARCHAR2              --> XML com informacoes de LOG
                                        ,pr_cdcritic          OUT PLS_INTEGER           --> Codigo da critica
                                        ,pr_dscritic          OUT VARCHAR2              --> Descricao da critica
                                        ,pr_retxml             IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                                        ,pr_des_erro          OUT VARCHAR2              --> Erros do processo
                                        );     
                                                                                      
  PROCEDURE pc_concluir_efetivacao(pr_cdcooper    IN crapepr.cdcooper%TYPE  --> Código da Cooperativa
                                  ,pr_nrdconta    IN crapepr.nrdconta%TYPE  --> Número da conta do cooperado
                                  ,pr_nrctremp    IN crapepr.nrctremp%TYPE  --> Número do Contrato de Empréstimo
                                  ,pr_situacao    IN VARCHAR2               --> Situação do retorno da efetivação (0-Insucesso, 1-Sucesso)
                                  ,pr_msg_erro    IN VARCHAR2 default null  --> Mensagem de Erro ocorrida (Técnica ou Negócio)
                                  ,pr_dscritic    OUT VARCHAR2              --> Descrição da Crítica NULL/'Erro na execução'
                                  ,pr_retorno     OUT VARCHAR2              --> Retorno da Operação OK/NOK
                                  );
                                  
  PROCEDURE pc_pag_parcela_ret_web (pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                     -- OUT
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2              --> Descric?o da critica
                                    ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro                                    
                                    ,pr_des_erro OUT VARCHAR2);            --> Erros do processo
                                    
  PROCEDURE pc_pag_parcela_ret (pr_cdcooper    IN CRAPEPR.CDCOOPER%TYPE DEFAULT 0,
                                pr_nrdconta    IN CRAPEPR.NRDCONTA%TYPE DEFAULT 0,
                                pr_nrctremp    IN CRAPEPR.NRCTREMP%TYPE DEFAULT 0,
                                pr_nrparepr    IN CRAPPEP.NRPAREPR%TYPE DEFAULT 0,                                
                                pr_situacao    IN VARCHAR2, -- CODIGO RETORNO
                                pr_msg_erro    IN VARCHAR2 DEFAULT '',
                                pr_numseqfluxo IN NUMBER, -- ID FIS
                                pr_idsequencia IN TBEPR_CONSIGNADO_PAGAMENTO.IDSEQUENCIA%TYPE DEFAULT 0, -- ID AIMARO
                                pr_saldopmt    IN NUMBER,
                                pr_vlmora      IN NUMBER,
                                pr_vlmulta     IN NUMBER,
                                pr_vliofatraso IN NUMBER , 
                                pr_vldesconto  IN NUMBER, 
                                pr_inparcela   IN INT, --1 Aberto, 2 Liquidada
                                pr_vlsaldodev  IN NUMBER, 
                                pr_cdorigem    IN PLS_INTEGER DEFAULT 1, --AIMARO
                                pr_cdcritic    OUT PLS_INTEGER,                                
                                pr_dscritic    OUT VARCHAR2,
                                pr_retxml      OUT XMLTYPE);
                                
  PROCEDURE pc_efetiva_pag_parcela(pr_rw_cr_tbepr_consig_pag IN tbepr_consignado_pagamento%ROWTYPE
                                   ,pr_numseqfluxo           IN TBEPR_CONSIGNADO_PAGAMENTO.IDSEQUENCIA%TYPE
                                   ,pr_saldopmt              IN NUMBER
                                   ,pr_vlmora                IN NUMBER
                                   ,pr_vlmulta               IN NUMBER
                                   ,pr_vliofatraso           IN NUMBER 
                                   ,pr_vldesconto            IN NUMBER 
                                   ,pr_inparcela             IN INT 
                                   ,pr_vlsaldodev            IN NUMBER 
                                   ,pr_rw_crapdat            IN btch0001.cr_crapdat%ROWTYPE                                          
                                   ,pr_cdcritic              OUT crapcri.cdcritic%TYPE   
                                   ,pr_dscritic              OUT VARCHAR2
                                   );
                                   
  PROCEDURE pc_estorn_pag_parc_ret_web(pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                       -- OUT
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descric?o da critica
                                      ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                      ,pr_tpdescto OUT crapepr.tpdescto%type --> Tipo desconto emprestimo
                                      ,pr_des_erro OUT VARCHAR2);            --> Erros do processo
                                    
  PROCEDURE pc_estorn_pag_parc_ret(pr_cdcooper    IN CRAPEPR.CDCOOPER%TYPE
                                  ,pr_nrdconta    IN CRAPEPR.NRDCONTA%TYPE
                                  ,pr_nrctremp    IN CRAPEPR.NRCTREMP%TYPE
                                  ,pr_situacao    IN VARCHAR2                -->Código do Retorno 
                                  ,pr_msg_erro    IN VARCHAR2 DEFAULT ''     -->Mensagem enviada quando for erro
                                  ,pr_numseqfluxo IN NUMBER                  -->Código interno que identifica o pagamento
                                  ,pr_idsequencia IN TBEPR_CONSIGNADO_PAGAMENTO.IDSEQUENCIA%TYPE DEFAULT 0
                                  ,pr_saldopmt    IN NUMBER                  -->Valor a receber da PMT após o Pagamento
                                  ,pr_vlmora      IN NUMBER                  -->Valor da Mora, caso existe saldo a pagar, somente quando esta em atraso
                                  ,pr_vlmulta     IN NUMBER                  -->Valor da Multa, caso existe saldo a pagar, somente quando esta em atraso 
                                  ,pr_vliofatraso IN NUMBER                  -->Valor do IOF, caso existe saldo a pagar, somente quando esta em atraso
                                  ,pr_vldesconto  IN NUMBER                  -->Valor do desconto, caso existe saldo a pagar, somente quando pagamento for de parcela a vencer
                                  ,pr_vlsaldodev  IN NUMBER                  -->Valor do Saldo devedor do contrato Atualizado D0 
                                  ,pr_cdorigem    IN PLS_INTEGER DEFAULT 1   --'AIMARO'
                                  ,pr_cdcritic    OUT PLS_INTEGER
                                  ,pr_dscritic    OUT VARCHAR2
                                  ,pr_retxml      OUT XMLTYPE) ;
                                
  PROCEDURE pc_efetiva_estorn_pag_parc(pr_rw_cr_tbepr_consig_pag IN tbepr_consignado_pagamento%ROWTYPE
                                      ,pr_saldopmt               IN NUMBER
                                      ,pr_vlmora                 IN NUMBER
                                      ,pr_vlmulta                IN NUMBER
                                      ,pr_vliofatraso            IN NUMBER 
                                      ,pr_vldesconto             IN NUMBER 
                                      ,pr_vlsaldodev             IN NUMBER 
                                      ,pr_rw_crapdat             IN btch0001.cr_crapdat%ROWTYPE                                          
                                      ,pr_cdcritic              OUT crapcri.cdcritic%TYPE   
                                      ,pr_dscritic              OUT VARCHAR2
                                      );
     
  PROCEDURE pc_gera_log(pr_cdcooper  NUMBER DEFAULT 3 --Cooperativa
                        ,pr_des_log  VARCHAR2 --Descrição do log
                        ,pr_tipo     PLS_INTEGER DEFAULT 2 -- Tipo de Log 1 OK, 2 Erro tratado, 3 Erro Não tratado
                        ,pr_cdprogra VARCHAR2 DEFAULT NULL -- Nome do programa 
                        );
     
  PROCEDURE pc_envia_arquivo_conveniada(pr_cdcooper   IN crapcop.cdcooper%TYPE        --> codigo da cooperativa
                                        ,pr_cdcritic   OUT PLS_INTEGER                 --> Código da critica
  				    				        	        ,pr_dscritic   OUT VARCHAR2);                --> Descricao da critica
                                        
  PROCEDURE pc_env_arq_conveniada_job;
  END EMPR0020;
/
CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0020 IS
/* -----------------------------------------------------------------------------------

  Programa: EMPR0020
  Autor   : Fernanda Kelli de Oliveira / AMcom
  Data    : 02/05/2019    ultima Atualizacao: 06/05/2019

  Dados referentes ao programa:

  Objetivo  : Concentrar rotinas referente ao processo do Crédito Consignado

  Alteracoes: 06/05/2019 - P437 Consignado - Inclusão da rotina pc_efetiva_pagto_parc_consig 
                           Josiane Stiehler - AMcom
              14/05/2019 - P437 Consignado - Inclusão da rotina pc_envia_email_erro_int_consig 
                           Jackson Barcellos - AMcom
              16/05/2019 - P437 Consignado - Inclusão da rotina pc_atualiza_tbepr_consignado             
                           Fernanda Kelli de Oliveira - AMcom
              31/05/2019 - P437 - Consignado - Inclusão das rotina pc_grava_evento_prop_consig e
                           pc_gera)xml_efet_prop_consig - Josiane Stiehler - AMcom
..............................................................................*/

  PROCEDURE pc_validar_dtpgto_antecipada (-- campos padrões
                                          pr_xmllog             IN VARCHAR2              --> XML com informacoes de LOG
                                         ,pr_cdcritic          OUT PLS_INTEGER           --> Codigo da critica
                                         ,pr_dscritic          OUT VARCHAR2              --> Descricao da critica
                                         ,pr_retxml             IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                                         ,pr_des_erro          OUT VARCHAR2              --> Erros do processo
                                         )IS
  /*---------------------------------------------------------------------------------------------------------
      Programa : pc_validar_dtpgto_antecipada
      Sistema  : AIMARO
      Sigla    : ATENDA->PRESTAÇÕES->COOPERATIVA
      Autor    : Fernanda Kelli de Oliveira - AMcom Sistemas de Informação
      Data     : 02/05/2019

      Objetivo : Na antecipação de parcelas para empréstimos de Consignado que tenham vínculo com conveniada 
                 cadastrada na tela Consig, o sistema Aimaro deverá validar a data atual de movimento 
                 (a data do dia) para permitir ou não a antecipação de uma parcela.

      Alteração :

  ----------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
       /* Tratamento de erro */
      vr_exc_erro EXCEPTION;

      /* Descrição e código da critica */
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      -- variaveis de entrada vindas no xml
      vr_cdcooper INTEGER;      
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_cdoperad VARCHAR2(100);
      vr_cdempres crapepr.cdempres%TYPE; 
      
      --Variaveis para leitura do XML
      vr_nrdconta         crapepr.nrdconta%type;
      vr_nrctremp         crapepr.nrctremp%type;
      vr_total_parcelas   NUMBER;
      vr_nrparc           NUMBER;
      vr_count            NUMBER;
      vr_dtvencto         VARCHAR2(10);
      vr_dtmvtolt         VARCHAR2(10); 
      
      vr_dsmensag         VARCHAR2(10) := NULL;      
      
      CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%TYPE,
                         pr_nrdconta IN crapepr.nrdconta%TYPE,
                         pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT epr.cdempres
          FROM crapepr epr 
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp
           AND epr.tpdescto = 2  --Tipo de desconto do emprestimo (2 = Desconto em Folha de Pagamento)
           AND epr.tpemprst = 1; --Contem o tipo do emprestimo (1 = Pré-Fixado).
      rw_crapepr cr_crapepr%ROWTYPE;

      CURSOR cr_crappep (pr_cdcooper IN crappep.cdcooper%TYPE,
                         pr_nrdconta IN crappep.nrdconta%TYPE,
                         pr_nrctremp IN crappep.nrctremp%TYPE,
                         pr_nrparc   IN crappep.nrparepr%TYPE) IS
      SELECT to_char(dtvencto,'DD/MM')||'/1900' dtvencto
        FROM crappep 
       WHERE crappep.cdcooper = pr_cdcooper
         AND crappep.Nrdconta = pr_nrdconta
         AND crappep.nrctremp = pr_nrctremp
         AND crappep.nrparepr = pr_nrparc;
      rw_crappep cr_crappep%ROWTYPE;
     
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;     
     
      CURSOR cr_pagto(pr_cdempres IN tbcadast_empresa_consig.cdempres%TYPE,
                      pr_cdcooper IN tbcadast_empresa_consig.cdcooper%TYPE,
                      pr_dtvencto IN varchar2,
                      pr_dtmvtolt IN varchar2) IS
      SELECT COUNT(1) vr_count
        FROM tbcadast_emp_consig_param dts,
             tbcadast_empresa_consig   emp
       WHERE emp.idemprconsig = dts.idemprconsig
         AND emp.cdempres = pr_cdempres
         AND emp.cdcooper = pr_cdcooper
         AND to_date(pr_dtvencto,'DD/MM/RRRR') BETWEEN dts.dtenvioarquivo AND dts.dtvencimento
         AND to_date(pr_dtmvtolt,'DD/MM/RRRR') BETWEEN dts.dtenvioarquivo AND dts.dtvencimento;
      rw_pagto cr_pagto%ROWTYPE;
         
    BEGIN
      
      pr_nmdcampo := NULL;
      pr_des_erro := 'OK';

      -- Extrai os dados vindos do XML pr_retxml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      IF  TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
      END IF;
      
      --Ler o valor das tag's enviadas no XML
      --Nr. Conta
      BEGIN
        vr_nrdconta    := TRIM(pr_retxml.extract('/Root/dto/nrdconta/text()').getstringval());  
      EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE = '-30625' THEN
            vr_dscritic := 'Numero da conta deve ser preenchida.';
            RAISE vr_exc_erro;
          END IF;  
      END;
       
      --Numero do Contrato
      BEGIN
        vr_nrctremp    := TRIM(pr_retxml.extract('/Root/dto/nrctremp/text()').getstringval());  
      EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE = '-30625' THEN
            vr_dscritic := 'Numero do contrato deve ser preenchido.';
            RAISE vr_exc_erro;
          END IF;  
      END;      
            
      --Validar se a empresa possui o Convênio do Consignado
      OPEN cr_crapepr (pr_cdcooper => vr_cdcooper,
                       pr_nrdconta => vr_nrdconta,
                       pr_nrctremp => vr_nrctremp);
      FETCH cr_crapepr 
      INTO rw_crapepr;
        
      IF cr_crapepr%NOTFOUND THEN
         vr_cdempres := NULL;
      ELSE
         vr_cdempres := rw_crapepr.cdempres;
      END IF; 
      CLOSE cr_crapepr;          
      
      IF vr_cdempres IS NULL THEN
        vr_dsmensag := 'N';  -- Não preciva pedir a Senha do Operador
      ELSE
        
        --Total de parcelas
        BEGIN
          vr_total_parcelas    := TRIM(pr_retxml.extract('/Root/dto/total/text()').getstringval());  
        EXCEPTION
          WHEN OTHERS THEN
            IF SQLCODE = '-30625' THEN
              vr_dscritic := 'Total de parcelas deve ser preenchido.';
              RAISE vr_exc_erro;
            END IF;  
        END;
        
        FOR x in 1 .. vr_total_parcelas LOOP
          --Numero da parcela
          BEGIN
            vr_nrparc  := TRIM(pr_retxml.extract('/Root/dto/parcelas/parc_'||x||'/text()').getstringval());
          EXCEPTION
            WHEN OTHERS THEN
              IF SQLCODE = '-30625' THEN
                vr_dscritic := 'Numero da parcela deve ser preenchida.';
                RAISE vr_exc_erro;
              END IF;  
          END;
          
          --Buscar a Data de Vencimento da Parcela
          OPEN cr_crappep (pr_cdcooper => vr_cdcooper,
                           pr_nrdconta => vr_nrdconta,
                           pr_nrctremp => vr_nrctremp,
                           pr_nrparc   => vr_nrparc);
          FETCH cr_crappep 
          INTO rw_crappep;
            
          IF cr_crappep%NOTFOUND THEN
             vr_dscritic := 'Problemas no select de busca da data de vencimento. ' || SQLERRM;
             CLOSE cr_crappep;
             RAISE vr_exc_erro; 
          ELSE
             vr_dtvencto := rw_crappep.dtvencto;
          END IF; 
          CLOSE cr_crappep;
          
          --Buscar a Data de movimento da Cooperativa
          OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
          FETCH btch0001.cr_crapdat 
          INTO rw_crapdat;
          CLOSE btch0001.cr_crapdat;
          vr_dtmvtolt:= to_char(rw_crapdat.dtmvtolt,'DD/MM')||'/1900' ;
          
          --Validar a data de pagamento da parcela
          OPEN cr_pagto (pr_cdempres => vr_cdempres,
                         pr_cdcooper => vr_cdcooper,
                         pr_dtvencto => vr_dtvencto,
                         pr_dtmvtolt => vr_dtmvtolt);
          FETCH cr_pagto 
          INTO rw_pagto;
            
          IF cr_pagto%NOTFOUND THEN
             vr_count:= 0;
          ELSE
             vr_count := rw_pagto.vr_count;
          END IF; 
          CLOSE cr_pagto;
             
          IF vr_count > 0 THEN
            vr_dsmensag := 'S';  --Deve pedir a Senha do Operador
            EXIT WHEN vr_count > 0;
          ELSE
            vr_dsmensag := 'N';  -- Não preciva pedir a Senha do Operador
          END IF;          
        END LOOP;        
      END IF;  
       
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><dsmensag>'||vr_dsmensag||'</dsmensag></Root>');
    
    EXCEPTION
      WHEN vr_exc_erro THEN
         /*  se foi retornado apenas código */
         IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
             /* buscar a descriçao */
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         /* variavel de erro recebe erro ocorrido */
         pr_des_erro := 'NOK';
         pr_cdcritic := nvl(vr_cdcritic,0);
         pr_dscritic := vr_dscritic;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
           pr_des_erro := 'NOK';
         /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na EMPR0020.PC_VALIDAR_DTPGTO_ANTECIPADA ' ||SQLERRM;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;    
  END pc_validar_dtpgto_antecipada;
  
  PROCEDURE pc_efetua_debito_conveniada(pr_cdcooper     IN crapcop.cdcooper%TYPE --> Código da cooperativa
                                       ,pr_cdempres     IN crapemp.cdempres%TYPE --> Código da Empresa que receberá o débito
                                       ,pr_cdoperad     IN VARCHAR2              --> Operador da Consulta – Valor 'xxxxx' para Internet
                                       ,pr_cdorigem     IN PLS_INTEGER           --> Aplicação de Origem da chamada do Serviço
                                       ,pr_nrdcaixa     IN INTEGER               --> Código de caixa do canal de atendimento – Valor 'XXXX' para Internet
                                       ,pr_dtmvtolt     IN crapdat.dtmvtolt%TYPE --> Data do movimento atual.
                                       ,pr_vrdebito     IN NUMBER                --> Valor a ser debitado   
                                       ,pr_idpagto      IN NUMBER                --> Identificador de pagamento enviado pelo consumidor
                                       ,pr_dscritic    OUT VARCHAR2              --> Descrição da crítica          
                                       ,pr_retorno      OUT xmltype) IS
  /*---------------------------------------------------------------------------------------------------------
      Programa : pc_efetua_debito_conveniada
      Sistema  : AIMARO
      Sigla    : 
      Autor    : Fernanda Kelli de Oliveira - AMcom Sistemas de Informação
      Data     : 03/05/2019
  
      Objetivo : Efetuar débito de consignado em conta da conveniada. 
                 Procedure será chamada pelo barramento SOA.

      Alteração:

  ----------------------------------------------------------------------------------------------------------*/
    /* Tratamento de erro */
    vr_exc_erro   EXCEPTION;
    vr_dscritic   VARCHAR2(4000);      
    vr_des_erro   VARCHAR2(10);
    vr_tab_erro   GENE0001.typ_tab_erro;
   
    vr_idsequencia tbepr_consignado_debconveniada.idsequencia%type;  
    vr_instatus    tbepr_consignado_debconveniada.instatus%type;  
    vr_dtmvtolt    crapdat.dtmvtolt%type;
    vr_cdagenci    crapass.cdagenci%type;
    vr_nrdconta    crapass.nrdconta%type;
  
  CURSOR cr_debconv IS
     SELECT debconv.idsequencia,
            debconv.instatus
       FROM cecred.tbepr_consignado_debconveniada debconv
      WHERE debconv.cdcooper = pr_cdcooper
        AND debconv.cdempres = pr_cdempres
        AND debconv.idpagto  = pr_idpagto;
  rw_debconv cr_debconv%ROWTYPE;
  
  CURSOR cr_crapemp IS
    SELECT crapemp.nrdconta               
      FROM crapemp,
           tbcadast_empresa_consig consig
     WHERE crapemp.cdempres = consig.cdempres
       AND crapemp.cdcooper = consig.cdcooper
       AND consig.indautrepassecc = 1 --Autorizar Debito Repasse em C/C. (0 - NÃ£o Autorizado / 1 - Autorizado)
       AND crapemp.cdempres = pr_cdempres
       AND crapemp.cdcooper = pr_cdcooper;
  rw_crapemp cr_crapemp%ROWTYPE;        
  
  CURSOR cr_crapass (pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT crapass.cdagenci
      FROM crapass   
     WHERE crapass.cdcooper = pr_cdcooper
       AND crapass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;   
  
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;     
                     
  BEGIN
    BEGIN      
      pr_dscritic    := null;
      --Verificar se o registro já existe
      vr_idsequencia := null;
      vr_instatus    := null;
     
       OPEN cr_debconv;
      FETCH cr_debconv 
       INTO rw_debconv;
        
      IF cr_debconv%NOTFOUND THEN
         vr_idsequencia := NULL;
      ELSE
        vr_idsequencia := rw_debconv.Idsequencia;
        vr_instatus    := rw_debconv.instatus;
      END IF; 
      CLOSE cr_debconv;
        
      --Inserir os parâmetros de entrada na tabela de controle de pagamento
      IF vr_idsequencia IS NULL THEN
         BEGIN
            vr_instatus := 1; 
            INSERT INTO cecred.tbepr_consignado_debconveniada
              (idsequencia,
               cdcooper,
               cdempres,
               idpagto,
               vrdebito,
               instatus,
               cdoperad,
               dtincreg,
               dtupdreg)
            VALUES
              (cecred.tbepr_consig_debconv_seq.nextval,
               pr_cdcooper,
               pr_cdempres,
               pr_idpagto,
               pr_vrdebito,
               vr_instatus,  --pr_instatus (1-Pendente, 2-Processado, 3-Erro)
               pr_cdoperad,
               sysdate,      --pr_dtincreg - Data de inclusao do registro
               null)        --pr_dtupdreg - Data de alteração do registro
          
            RETURNING tbepr_consignado_debconveniada.idsequencia INTO vr_idsequencia;
            
         EXCEPTION
           WHEN OTHERS THEN
             vr_dscritic := 'Erro no insert da tabela tbepr_consignado_debconveniada. ' || sqlerrm; 
             RAISE vr_exc_erro;    
         END;
      ELSE
        BEGIN
          UPDATE cecred.tbepr_consignado_debconveniada
             SET cdoperad = pr_cdoperad,
                 dtupdreg = sysdate
           WHERE idsequencia = vr_idsequencia;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro no update da tabela tbepr_consignado_debconveniada. ' || sqlerrm;
            RAISE vr_exc_erro;    
        END;       
      END IF;
      
      --Buscar a Data de movimento da Cooperativa
       OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat 
       INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;
      vr_dtmvtolt:= rw_crapdat.dtmvtolt;
     
      vr_nrdconta := NULL; 
       OPEN cr_crapemp;
      FETCH cr_crapemp 
       INTO rw_crapemp;
        
      IF cr_crapemp%NOTFOUND THEN
         vr_nrdconta := NULL;
      ELSE
        vr_nrdconta := rw_crapemp.nrdconta;
      END IF; 
      CLOSE cr_crapemp;
 
      --Caso não tenha conta corrente cadastrada na Cademp, então o sistema Aimaro não fará o débito do repasse.
      IF nvl(vr_nrdconta,0) = 0 THEN
        vr_dscritic := 'Empresa '||pr_cdempres||' nao possui conta-corrente cadastrada. ';
        RAISE vr_exc_erro; 
      ELSE
         --Buscar o codigo da agencia
         vr_cdagenci := NULL;       
          OPEN cr_crapass (pr_nrdconta => vr_nrdconta);
         FETCH cr_crapass 
          INTO rw_crapass;
              
         IF cr_crapass%NOTFOUND THEN
            vr_cdagenci := NULL;
         ELSE
           vr_cdagenci := rw_crapass.cdagenci;
         END IF; 
         CLOSE cr_crapass;
       
         IF nvl(vr_cdagenci,0) = 0 THEN
            vr_dscritic := 'Empresa '||pr_cdempres||' conta-corrente '||vr_nrdconta||' nao possui agencia cadastrada. ';
            RAISE vr_exc_erro; 
         END IF; 
      END IF;
      
      --Se estiver Pendente/Erro de processamento 
      IF vr_instatus in(1,3) THEN  --
        
        /* Lanca em C/C e atualiza o lote */
        empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper      --> Cooperativa conectada
                                      ,pr_dtmvtolt => vr_dtmvtolt      --> Movimento atual
                                      ,pr_cdagenci => vr_cdagenci      --> Código da agência
                                      ,pr_cdbccxlt => 1                --> Número do caixa
                                      ,pr_cdoperad => pr_cdoperad      --> Código do Operador
                                      ,pr_cdpactra => vr_cdagenci      --> P.A. da transação
                                      ,pr_nrdolote => 600014           --> Numero do Lote
                                      ,pr_nrdconta => vr_nrdconta      --> Número da conta
                                      ,pr_cdhistor => 2972             --> Codigo historico
                                      ,pr_vllanmto => pr_vrdebito      --> Valor da parcela emprestimo
                                      ,pr_nrparepr => 0                --> Número parcelas empréstimo
                                      ,pr_nrctremp => 0                --> Número do contrato de empréstimo
                                      ,pr_des_reto => vr_des_erro      --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro);    --> Tabela com possíves erros
        --Se Retornou erro
        IF vr_des_erro <> 'OK' THEN
          --Sair
          vr_dscritic := 'Problema na rotina empr0001.pc_cria_lancamento_cc, empresa '|| pr_cdempres || '. Erro: '|| sqlerrm ;
          RAISE vr_exc_erro;
        ELSE
          BEGIN
            UPDATE cecred.tbepr_consignado_debconveniada T
               SET t.instatus = 2  --Processado
             WHERE idsequencia = vr_idsequencia;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Problema na atualizacao do processamento da empresa '|| pr_cdempres || '. Erro: '|| sqlerrm ;
              RAISE vr_exc_erro;    
          END;  
        END IF;
      END IF;
      
      --Retorno (SUCESSO)
      pr_dscritic:= null;
      vr_dscritic := 'Débito realizado com sucesso!';      
      pr_retorno := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><retorno>'||vr_dscritic||'</retorno></Root>');
      
      COMMIT;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        BEGIN
          UPDATE cecred.tbepr_consignado_debconveniada T
             SET t.instatus = 3  --Erro
           WHERE idsequencia = vr_idsequencia;
           
           COMMIT;
           
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema na atualizacao do processamento da empresa '|| pr_cdempres || '. Erro: '|| sqlerrm ;
            RAISE vr_exc_erro;    
        END;
        --Retorno (NÃO SUCESSO)
        pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><retorno>' || pr_dscritic || '</retorno></Root>');
        pr_dscritic:= 'Erro ao debitar valor solicitado. ' || vr_dscritic;                                         
      WHEN OTHERS THEN
         --Retorno (NÃO SUCESSO)        
        pr_retorno := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><retorno>' || pr_dscritic || '</retorno></Root>');
        pr_dscritic:= 'Erro ao debitar valor solicitado. Erro: ' || sqlerrm;                                         
    END;    
  END pc_efetua_debito_conveniada;                                        
    
  PROCEDURE pc_atualiza_tbepr_consig_pagto(pr_cdcooper     IN tbepr_consignado_pagamento.cdcooper%TYPE,
                                           pr_nrdconta     IN tbepr_consignado_pagamento.nrdconta%TYPE,
                                           pr_nrctremp     IN tbepr_consignado_pagamento.nrctremp%TYPE,
                                           pr_nrparepr     IN tbepr_consignado_pagamento.nrparepr%TYPE,
                                           pr_vlparepr     IN tbepr_consignado_pagamento.vlparepr%TYPE,
                                           pr_vlpagpar     IN tbepr_consignado_pagamento.vlpagpar%TYPE,
                                           pr_dtvencto     IN tbepr_consignado_pagamento.dtvencto%TYPE,
                                           pr_instatus     IN tbepr_consignado_pagamento.instatus%TYPE,
                                           pr_cdagenci     IN tbepr_consignado_pagamento.cdagenci%TYPE,
                                           pr_cdbccxlt     IN tbepr_consignado_pagamento.cdbccxlt%TYPE,
                                           pr_cdoperad     IN tbepr_consignado_pagamento.cdoperad%TYPE,
                                           pr_idsequencia  IN OUT tbepr_consignado_pagamento.idsequencia%TYPE,
                                           pr_dscritic    OUT VARCHAR2 ) IS 
  /*---------------------------------------------------------------------------------------------------------
    Programa : pc_inc_alt_tbepr_consignado_pagamento
    Sistema  : AIMARO
    Sigla    : 
    Autor    : Josiane Stiehler - AMcom
    Data     : 06/05/2019
    
    Objetivo : Inclui ou altera a tabela bepr_consignado_pagamento, 
               para o controle de pagamento enviados a FIS Brasil

    Alteração:

  ----------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
     vr_dscritic  varchar2(2000);
     vr_exc_saida exception;
   
  BEGIN 
    IF pr_idsequencia IS NULL THEN
       BEGIN   
          INSERT INTO tbepr_consignado_pagamento
               (idsequencia,
                cdcooper,
                nrdconta,
                nrctremp,
                nrparepr,
                vlparepr,
                vlpagpar,
                dtvencto,
                instatus,
                dtincreg,
                dtupdreg,
                cdagenci,
                cdbccxlt,
                cdoperad)
            VALUES
               (tbepr_consignado_pagamento_seq.nextval,
                pr_cdcooper,
                pr_nrdconta,
                pr_nrctremp,
                pr_nrparepr,
                pr_vlparepr,
                pr_vlpagpar,
                pr_dtvencto,
                pr_instatus,
                sysdate,
                null,
                pr_cdagenci,
                pr_cdbccxlt,
                pr_cdoperad)
          RETURNING idsequencia
               INTO pr_idsequencia;
       EXCEPTION
         WHEN OTHERS THEN
         vr_dscritic:= 'Erro no insert da tabela tbepr_consignado_pagamento - ' ||sqlerrm;
         RAISE vr_exc_saida;
       END;      
    ELSE
       BEGIN
           UPDATE tbepr_consignado_pagamento
              SET instatus = pr_instatus,
                  dtupdreg = sysdate
            WHERE idsequencia = pr_idsequencia;
       EXCEPTION
         WHEN OTHERS THEN
         vr_dscritic:= 'Erro no updateda tabela tbepr_consignado_pagamento - '||sqlerrm;
         RAISE vr_exc_saida;               
       END;      
     END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN
      pr_dscritic:= vr_dscritic; 
    END;
  END pc_atualiza_tbepr_consig_pagto;
    
  FUNCTION fn_ret_status_pagto_consignado (pr_cdcooper    IN tbepr_consignado_pagamento.cdcooper%TYPE, -- código da cooperativa
                                           pr_nrdconta    IN tbepr_consignado_pagamento.nrdconta%TYPE, -- Número da conta
                                           pr_nrctremp    IN tbepr_consignado_pagamento.nrctremp%TYPE, -- Número do contrato de emprestimo
                                           pr_nrparepr    IN tbepr_consignado_pagamento.nrparepr%TYPE, -- Número da parcela de emprestimo
                                           pr_instatus    IN tbepr_consignado_pagamento.instatus%type) -- Indicador do status do pagamento
  RETURN NUMBER IS
  /*---------------------------------------------------------------------------------------------------------
    Programa : fn_ret_status_pagto_consignado
    Sistema  : AIMARO
    Sigla    : 
    Autor    : Josiane Stiehler - AMcom
    Data     : 06/05/2019
  
    Objetivo : Retorna o status do processamento do pagamento criado no Evento SOA.
               Pagamento que irá ocorrer na FIS Brasil

    Alteração:

  ----------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
      vr_instatus tbepr_consignado_pagamento.instatus%TYPE;

      CURSOR cr_consig_pagto IS      
        SELECT instatus  -- 1- Processando, 2 - Pagamento efetuado FIS, 3- Erro
          FROM tbepr_consignado_pagamento
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND nrparepr = pr_nrparepr
           AND instatus = pr_instatus;
   BEGIN
     vr_instatus:= 0; -- não encontrado
     FOR rw_consig_pagto IN cr_consig_pagto
     LOOP
       vr_instatus:= rw_consig_pagto.instatus;
     END LOOP;
     RETURN (vr_instatus);
    END;
  END fn_ret_status_pagto_consignado;
  
  PROCEDURE pc_efetiva_pagto_parc_consig(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                        ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Código da agência
                                        ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Número do caixa
                                        ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> Código do Operador
                                        ,pr_nmdatela    IN VARCHAR2              --> Nome da tela
                                        ,pr_idorigem    IN INTEGER               --> Id do módulo de sistema
                                        ,pr_cdpactra    IN INTEGER               --> P.A. da transação
                                        ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> Número da conta
                                        ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                        ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                        ,pr_flgerlog    IN VARCHAR2              --> Indicador S/N para geração de log
                                        ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                        ,pr_nrparepr    IN INTEGER               --> Número parcelas empréstimo
                                        ,pr_vlparepr    IN NUMBER                --> Valor da parcela  à pagar
                                        ,pr_vlparcel    IN NUMBER                --> valor que esta sendo pago da parcela
                                        ,pr_dtvencto    IN crappep.dtvencto%TYPE --> Vencimento da parcela
                                        ,pr_cdlcremp    IN crapepr.cdlcremp%TYPE --> Linha de crédito
                                        ,pr_tppagmto    IN VARCHAR2              --> Tipo Pagamento - "D" -Em Dia, "A"- Em Atraso
                                        ,pr_vlrmulta    IN crappep.vlpagmta%TYPE --> Valor da multa
                                        ,pr_vlatraso    IN crappep.vlpagmra %TYPE--> Valor Juros de mora
                                        ,pr_vliofcpl    IN crappep.vliofcpl%TYPE --> Valor do IOF complementar de atraso
                                        ,pr_nrseqava    IN NUMBER DEFAULT 0      --> Pagamento: Sequencia do avalista
                                        ,pr_des_reto    OUT VARCHAR              --> Retorno OK / NOK
                                        ,pr_tab_erro    OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
  
  /*---------------------------------------------------------------------------------------------------------
      Programa : pc_efetiva_pagto_parc_consig
      Sistema  : AIMARO
      Sigla    : 
      Autor    : Josiane Stiehler - AMcom
      Data     : 06/05/2019
  
      Objetivo : Efetiva pagamento da parcela, ou seja grava evento SOA referente ao pagamento
                 para ser enviado a FIS Brasil. 
                 Esta rotina é chamada pelo programa do debitador único (PC_CRPS750_2).
      Alteração:

  ----------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
      -- Cursor de Linha de Credito 
      CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                       ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT craplcr.cdlcremp
              ,craplcr.dsoperac
          FROM craplcr
         WHERE craplcr.cdcooper = pr_cdcooper
               AND craplcr.cdlcremp = pr_cdlcremp;
               
      rw_craplcr cr_craplcr%ROWTYPE;
  
      --Variaveis Locais
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
      vr_nrdrowid ROWID;
      vr_flgtrans BOOLEAN;
      vr_floperac BOOLEAN;
      vr_cdhismul craphis.cdhistor%TYPE;
      vr_cdhisatr craphis.cdhistor%TYPE;
      vr_cdhisiof craphis.cdhistor%TYPE;
      vr_cdhistor craphis.cdhistor%TYPE;
      vr_lotemult craplot.nrdolote%TYPE;
      vr_loteatra craplot.nrdolote%TYPE;
      vr_loteiof  craplot.nrdolote%TYPE;
      vr_nrdolote craplot.nrdolote%TYPE; 
      vr_nrseqdig tbgen_iof_lancamento.nrseqdig_lcm%TYPE;
      vr_idpagamento tbepr_consignado_pagamento.idsequencia%TYPE;
      vr_tipo_pagto  VARCHAR2(500);
      vr_xml_parcela VARCHAR2(1000);
      
      vr_dsxmlali XMLType;
      -- ID Evento SOA
      vr_idevento   tbgen_evento_soa.idevento%type;    

      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_des_erro VARCHAR2(3);
      vr_dscritic VARCHAR2(4000);

      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;

    BEGIN
      --Inicializar variavel erro
      pr_des_reto := 'OK';
      --Marcar que nao ocorreu transacao
      vr_flgtrans := FALSE;

      --Limpar tabela erro
      pr_tab_erro.DELETE;

      --Se escreve erro log
      IF pr_flgerlog = 'S' THEN
        --Buscar Descricao origem
        vr_dsorigem := GENE0001.vr_vet_des_origens(pr_idorigem);
        --Descricao Transacao
        vr_dstransa := 'Efetiva pagamento de parcela consignado';
      END IF;

      BEGIN
        --Criar savepoint para desfazer transacao
        SAVEPOINT savtrans_efetiva_pagto_parcela;
        
        -- Gera evento SOA de pagamento e insere lancamento na C/C somente
        -- o pagamento que não foi enviado ou que já foi pago parcialmente
        IF fn_ret_status_pagto_consignado (pr_cdcooper => pr_cdcooper,
                                           pr_nrdconta => pr_nrdconta,
                                           pr_nrctremp => pr_nrctremp, 
                                           pr_nrparepr => pr_nrparepr,
                                           pr_instatus => 2) IN (0,2) THEN -- 0- não enviado, 2- Pagamento Efetuado na FIS, 3- Erro

           --Selecionar Linha Credito
           OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                          ,pr_cdlcremp => pr_cdlcremp);
           FETCH cr_craplcr
            INTO rw_craplcr;
           --Se nao Encontrou
           IF cr_craplcr%NOTFOUND THEN
              --Fechar Cursor
              CLOSE cr_craplcr;
              vr_cdcritic := 363;
              --Sair
              RAISE vr_exc_saida;
           ELSE
             --Determinar se a Operacao é financiamento
             vr_floperac := rw_craplcr.dsoperac = 'FINANCIAMENTO';
           END IF;
           
           -- verifica se o pagamento é em dia
           IF pr_tppagmto = 'D' THEN 
              IF vr_floperac THEN
                 vr_nrdolote := 600015;
              ELSE
                 vr_nrdolote := 600014;
              END IF;
              vr_cdhistor := 108;
           ELSE -- pagamento em atraso
               IF vr_floperac THEN -- Financiamento
                  -- multa
                  vr_lotemult := 600021; 
                  vr_cdhismul := 1070;
                  -- atraso
                  vr_cdhisatr := 1072;
                  vr_loteatra := 600025;
                  -- IOF
                  vr_cdhisiof:= 2314;
                  vr_loteiof:=  600023;
                  -- pago da parcela
                  vr_cdhistor := 108;
                  vr_nrdolote:=  600015;
               ELSE -- Emprestimo 
                  -- multa
                  vr_lotemult := 600020; 
                  vr_cdhismul := 1060;
                  -- atraso
                  vr_cdhisatr := 1071;
                  vr_loteatra := 600024;
                  -- IOF
                  vr_cdhisiof:= 2313;
                  vr_loteiof:= 600022;
                  -- pago da parcela
                  vr_cdhistor := 108;
                  vr_nrdolote:= 600014;
               END IF;
           END IF;
           
           vr_idpagamento:= null;
           pc_atualiza_tbepr_consig_pagto(pr_cdcooper    => pr_cdcooper, -- codigo da cooperativa
                                          pr_nrdconta    => pr_nrdconta, -- numero da conta
                                          pr_nrctremp    => pr_nrctremp, -- Numero do contrato
                                          pr_nrparepr    => pr_nrparepr, -- Numero da parcela
                                          pr_vlparepr    => pr_vlparepr, -- valor da parcela do emprestimo
                                          pr_vlpagpar    => pr_vlparcel, -- Valor pago da parcela
                                          pr_dtvencto    => pr_dtvencto, -- Vencimento da parcela
                                          pr_instatus    => 1,           -- Status do processamento
                                          pr_cdagenci    => pr_cdagenci, -- Código da agencia
                                          pr_cdbccxlt    => pr_nrdcaixa, -- Número do caixa
                                          pr_cdoperad    => pr_cdoperad, -- Código do Operador
                                          pr_idsequencia => vr_idpagamento, -- identificador do pagamento
                                          pr_dscritic    => vr_dscritic);   -- critica de erro
           -- Tratar saida com erro                          
           IF vr_dscritic IS NOT NULL THEN
              vr_cdcritic:=0;
              RAISE vr_exc_saida;
           END IF;    
         
           -- Verifica se o valor que esta sendo pago é total ou parcial
           -- Compara o valor da parcela (pr_vlparepr) com o valor que esta sendo pago (pr_vlparcel)
           IF  pr_vlparepr = pr_vlparcel THEN  
               vr_tipo_pagto := ' <valor>'||pr_vlparcel||'</valor>' ;
           ELSE                      
               vr_tipo_pagto:= ' <valorParcial>'||pr_vlparcel||'</valorParcial>';
           END IF;
                   
           vr_xml_parcela:= vr_xml_parcela||
                           ' <parcela>
                               <dataEfetivacao>'||to_char(pr_dtmvtolt,'yyyy-mm-dd')||'T'||to_char(sysdate,'hh24:mi:ss')||'</dataEfetivacao> 
                               <dataVencimento>'||to_char(pr_dtvencto,'yyyy-mm-dd')||'</dataVencimento>
                               <identificador>'||vr_idpagamento||'</identificador>'||
                               vr_tipo_pagto|| 
                            '</parcela>';
           
           -- Gera o XML do pagamento a ser gravado no evento SOA
           pc_gera_xml_pagamento_consig(pr_cdcooper     => pr_cdcooper, -- código da cooperativa
                                        pr_nrdconta     => pr_nrdconta, -- Número da conta
                                        pr_nrctremp     => pr_nrctremp, -- Número do contrato de emprestimo
                                        pr_xml_parcelas => vr_xml_parcela, -- xml da parcela
                                        pr_tpenvio      => 1,           -- Tipo de envio (1-INSTALLMENT_SETTLEMENT, 2-REVERSAL_SETTLEMENT,3-CONTRACT_SETTLEMENT, 4-DEFAULTING_INSTALLMENT_SETTLEMENT)
                                        pr_tptransa     =>'DEBITO',     -- tipo transação (DEBITO, ESTORNO DEBITO)
                                        pr_dsxmlali     => vr_dsxmlali, -- XML de saida do pagamento
                                        pr_dscritic     => vr_dscritic); 


           -- Tratar saida com erro                          
           IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
           END IF;                                  
         
           -- gera evento soa para o pagamento de consignado
           soap0003.pc_gerar_evento_soa(pr_cdcooper               => pr_cdcooper
                                       ,pr_nrdconta               => pr_nrdconta
                                       ,pr_nrctrprp               => pr_nrctremp
                                       ,pr_tpevento               => 'PAGTO_DEBITADOR_UNICO'
                                       ,pr_tproduto_evento        => 'CONSIGNADO'
                                       ,pr_tpoperacao             => 'INSERT'
                                       ,pr_dsconteudo_requisicao  => vr_dsxmlali.getClobVal()
                                       ,pr_idevento               => vr_idevento
                                       ,pr_dscritic               => vr_dscritic);
           -- Tratar saida com erro                          
           IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
           END IF;

           -- Lanca em C/C e atualiza o lote 
           empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                          ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                          ,pr_cdagenci => pr_cdagenci --> Código da agência
                                          ,pr_cdbccxlt => 100         --> Número do caixa
                                          ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                          ,pr_cdpactra => pr_cdpactra --> P.A. da transação
                                          ,pr_nrdolote => vr_nrdolote --> Numero do Lote
                                          ,pr_nrdconta => pr_nrdconta --> Número da conta
                                          ,pr_cdhistor => vr_cdhistor --> Codigo historico
                                          ,pr_vllanmto => pr_vlparcel --> Valor da parcela emprestimo
                                          ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                          ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                          ,pr_nrseqava => pr_nrseqava --> Pagamento: Sequencia do avalista
                                          ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                          ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros
           --Se Retornou erro
           IF vr_des_erro <> 'OK' THEN
              --Sair
              RAISE vr_exc_saida;
           END IF;

        
           -- Para os pagamentos em atraso
           -- lançar em c/c  Multa, juros e IOF
           IF pr_tppagmto = 'A' THEN
              ------------------------------
              -- Lançamento de Multa
              ------------------------------
              IF nvl(pr_vlrmulta,0) > 0 then
                 --Lanca em C/C e atualiza o lote 
                 empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                               ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                               ,pr_cdagenci => pr_cdagenci --> Código da agência
                                               ,pr_cdbccxlt => 100 --> Número do caixa
                                               ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                               ,pr_cdpactra => pr_cdpactra --> P.A. da transação
                                               ,pr_nrdolote => vr_lotemult --> Numero do Lote
                                               ,pr_nrdconta => pr_nrdconta --> Número da conta
                                               ,pr_cdhistor => vr_cdhismul --> Codigo historico
                                               ,pr_vllanmto => pr_vlrmulta --> Valor da parcela emprestimo
                                               ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                               ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                               ,pr_nrseqava => pr_nrseqava -- Pagamento: Sequencia do avalista
                                               ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                               ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros
                 --Se Retornou erro
                 IF vr_des_erro <> 'OK' THEN
                    --Sair
                    RAISE vr_exc_saida;
                 END IF;
              END IF;
              
              ---------------------------------
              -- Lançamento de juros de mora 
              ---------------------------------
              IF nvl(pr_vlatraso, 0) > 0  THEN
                 -- AND nvl(vr_vlpagsld, 0) >= 0 THEN
                 -- Debita o pagamento da parcela da C/C 
                 empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                                ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                                ,pr_cdagenci => pr_cdagenci --> Código da agência
                                                ,pr_cdbccxlt => 100 --> Número do caixa
                                                ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                                ,pr_cdpactra => pr_cdpactra --> P.A. da transação
                                                ,pr_nrdolote => vr_loteatra --> Numero do Lote
                                                ,pr_nrdconta => pr_nrdconta --> Número da conta
                                                ,pr_cdhistor => vr_cdhisatr --> Codigo historico
                                                ,pr_vllanmto => pr_vlatraso --> Valor da parcela emprestimo
                                                ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                                ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                                ,pr_nrseqava => pr_nrseqava --> Pagamento: Sequencia do avalista
                                                ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                                ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros
                 --Se Retornou erro
                 IF vr_des_erro <> 'OK' THEN
                    --Sair
                    RAISE vr_exc_saida;
                 END IF;
              END IF;
                
              ----------------------------------------
              -- Lançamento do IOF complementar
              ----------------------------------------
              IF nvl(pr_vliofcpl, 0) > 0 THEN
                 -- AND nvl(vr_vlpagsld, 0) >= 0 THEN
                 -- Debita o valor do IOF complementar atraso da C/C 
                 empr0001.pc_cria_lancamento_cc_chave(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                                      ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                                      ,pr_cdagenci => pr_cdagenci --> Código da agência
                                                      ,pr_cdbccxlt => 100 --> Número do caixa
                                                      ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                                      ,pr_cdpactra => pr_cdpactra --> P.A. da transação
                                                      ,pr_nrdolote => vr_loteiof  --> Numero do Lote
                                                      ,pr_nrdconta => pr_nrdconta --> Número da conta
                                                      ,pr_cdhistor => vr_cdhisiof --> Codigo historico
                                                      ,pr_vllanmto => pr_vliofcpl --> Valor da parcela emprestimo
                                                      ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                                      ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                                      ,pr_nrseqava => pr_nrseqava --> Pagamento: Sequencia do avalista
                                                      ,pr_nrseqdig => vr_nrseqdig
                                                      ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                                      ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros
                 --Se Retornou erro
                 IF vr_des_erro <> 'OK' THEN
                    --Sair
                    RAISE vr_exc_saida;
                 END IF;  
                
                 -- Insere o IOF 
                 tiof0001.pc_insere_iof(pr_cdcooper     => pr_cdcooper
                                       ,pr_nrdconta     => pr_nrdconta
                                       ,pr_dtmvtolt     => pr_dtmvtolt
                                       ,pr_tpproduto    => 1 -- Emprestimo
                                       ,pr_nrcontrato   => pr_nrctremp
                                       ,pr_idlautom     => null
                                       ,pr_dtmvtolt_lcm => pr_dtmvtolt
                                       ,pr_cdagenci_lcm => pr_cdpactra
                                       ,pr_cdbccxlt_lcm => 100
                                       ,pr_nrdolote_lcm => vr_loteiof
                                       ,pr_nrseqdig_lcm => vr_nrseqdig
                                       ,pr_vliofpri     => 0
                                       ,pr_vliofadi     => 0
                                       ,pr_vliofcpl     => pr_vliofcpl
                                       ,pr_flgimune     => 0
                                       ,pr_cdcritic     => vr_cdcritic
                                       ,pr_dscritic     => vr_dscritic);

                 IF vr_dscritic is not null THEN
                    RAISE vr_exc_saida;
                 end if;
              END IF;
           END IF;
        END IF;
        
        --Marcar que ocorreu transacao
        vr_flgtrans := TRUE;

      EXCEPTION
        WHEN vr_exc_saida THEN
          --Desfaz transacoes
          ROLLBACK TO SAVEPOINT savtrans_efetiva_pagto_parcela;
      END;

      --Se nao ocorreu a transacao
      IF NOT vr_flgtrans THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        --Se nao tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN
          -- Gerar rotina de gravação de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        END IF;
      ELSIF pr_flgerlog = 'S' THEN
        -- Se foi solicitado o envio de LOG
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
        -- Retorno OK
        pr_des_reto := 'OK';
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0020.pc_efetiva_pagto_parc_consig ' ||
                       sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_efetiva_pagto_parc_consig;  
  
  PROCEDURE pc_gera_pgto_parc_consig_web(pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                         -- OUT
                                        ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                        ,pr_dscritic OUT VARCHAR2              --> Descric?o da critica
                                        ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                        ,pr_tpdescto OUT crapepr.tpdescto%type --> Tipo desconto emprestimo
                                        ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

  /* .............................................................................

       Programa: pc_gera_pgto_parcelas_consig_web
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Josiane Stiehler (AMcom)
       Data    : 14/06/2019.                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : PJ437 - Consignado
                   Chamada para ayllosWeb(mensageria)
                   Procedure para enviar o pagamento da parcela do emprestimo consignado

       Alteracoes:

    ............................................................................. */

    -------------------------- VARIAVEIS ----------------------
    -- variaveis de retorno
    vr_tab_erro      gene0001.typ_tab_erro;
		vr_des_reto      VARCHAR(4000);
    vr_exc_erro      EXCEPTION;
    
    -- Variaveis de entrada vindas no xml
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

  	-- Descrição e código da critica
		vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic VARCHAR2(4000);

    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    vr_texto_completo  VARCHAR2(32600);
    vr_index           VARCHAR2(100);
    vr_tab_pgto_parcel empr0001.typ_tab_pgto_parcel; --> Tabela com registros de pagamentos
    
    -- Variaveis de parâmetro
    vr_nrdconta crapepr.nrdconta%TYPE;
    vr_cdpactra INTEGER;
    vr_idseqttl crapttl.idseqttl%TYPE;
    vr_dtmvtolt crapepr.dtmvtolt%TYPE;
    vr_flgerlog VARCHAR2(1);
    vr_nrctremp crapepr.nrctremp%TYPE;
    vr_dtmvtoan crapdat.dtmvtoan%TYPE;
    vr_totatual crapepr.vlemprst%TYPE;
    vr_totpagto crapepr.vlemprst%TYPE;
    vr_nrseqava NUMBER DEFAULT 0;
    vr_xmlpagto xmltype;

    -------------------------------  CURSORES  -------------------------------
    CURSOR cr_crapepr (pr_cdcooper crapepr.cdcooper%TYPE,
                       pr_nrdconta crapepr.nrdconta%TYPE,
                       pr_nrctremp crapepr.nrctremp%TYPE) IS
      SELECT epr.tpdescto,
             epr.tpemprst
        FROM crapepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;
    rw_crapepr cr_crapepr%rowtype;

    CURSOR cr_tab_param IS
      SELECT nrdconta, cdpactra, idseqttl, dtmvtolt, flgerlog, nrctremp, dtmvtoan, totatual,totpagto, nrseqava
        FROM   XMLTABLE('Root/dto'
               PASSING pr_retxml
               COLUMNS
                 nrdconta number PATH 'nrdconta', 
                 cdpactra number PATH 'cdpactra',
                 idseqttl number PATH 'idseqttl',
                 dtmvtolt varchar2(30) PATH 'dtmvtolt',
                 flgerlog varchar2(30) PATH 'flgerlog',
                 nrctremp number PATH 'nrctremp',
                 dtmvtoan varchar2(30) PATH 'dtmvtoan',
                 totatual varchar2(30) PATH 'totatual',
                 totpagto varchar2(30) PATH 'totpagto',
                 nrseqava number PATH 'nrseqava'
               ) xt
       WHERE rownum=1;

    CURSOR cr_tab_pagto IS
      SELECT cdcooper, nrdconta, nrctremp, nrparepr, vlpagpar
        FROM   XMLTABLE('Root/dto/Pagamentos/Itens'
               PASSING pr_retxml
               COLUMNS
                 cdcooper number PATH 'cdcooper',
                 nrdconta number PATH 'nrdconta',
                 nrctremp number PATH 'nrctremp',
                 nrparepr number PATH 'nrparepr',
                 vlpagpar varchar2(30) PATH 'vlpagpar'
               ) xt
       WHERE cdcooper IS NOT NULL;


    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;

  BEGIN
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    gene0001.pc_informa_acesso(pr_module => vr_nmdatela,
                               pr_action => vr_nmeacao);

    -- lê o XML para buscar os pagamentos
    vr_index:= 0;
    FOR rw_tab_pagto IN cr_tab_pagto
    LOOP
      vr_index:= vr_index+1;
      vr_tab_pgto_parcel(vr_index).cdcooper:= rw_tab_pagto.cdcooper;
      vr_tab_pgto_parcel(vr_index).nrdconta:= rw_tab_pagto.nrdconta;
      vr_tab_pgto_parcel(vr_index).nrctremp:= rw_tab_pagto.nrctremp;
      vr_tab_pgto_parcel(vr_index).nrparepr:= rw_tab_pagto.nrparepr;
      vr_tab_pgto_parcel(vr_index).vlpagpar:= to_number(replace(rw_tab_pagto.vlpagpar,'.',''));
     
    -- dbms_output.put_line('vr_tab_pgto_parcel(vr_index).nrctremp:'||vr_tab_pgto_parcel(vr_index).nrctremp
    --  ||' - '||vr_tab_pgto_parcel(vr_index).vlpagpar);
    END LOOP;
    
    FOR rw_tab_param IN cr_tab_param
    LOOP
      vr_nrdconta:= rw_tab_param.nrdconta;
      vr_cdpactra:= rw_tab_param.cdpactra;
      vr_idseqttl:= rw_tab_param.idseqttl;
      vr_dtmvtolt:= TO_DATE(rw_tab_param.dtmvtolt,'DD/MM,YYYY');
      IF rw_tab_param.flgerlog = 'TRUE' THEN
         vr_flgerlog:= 'S';
      ELSE
         vr_flgerlog:= 'N';        
      END IF;
      vr_nrctremp:= rw_tab_param.nrctremp;
      vr_dtmvtoan:= TO_DATE(rw_tab_param.dtmvtoan,'DD/MM,YYYY');
      vr_totatual:= to_number(replace(rw_tab_param.totatual,'.',''));
      vr_totpagto:= to_number(replace(rw_tab_param.totpagto,'.',''));
      vr_nrseqava:= rw_tab_param.nrseqava;
    END LOOP;
    -- Verifica se é consignado
    OPEN cr_crapepr (pr_cdcooper => vr_cdcooper,
                     pr_nrdconta => vr_nrdconta,
                     pr_nrctremp => vr_nrctremp);
    FETCH cr_crapepr INTO rw_crapepr;
    CLOSE cr_crapepr;

    -- Se o tpdescto = 2 -- consignado
    IF rw_crapepr.tpemprst = 1 AND 
       rw_crapepr.tpdescto = 2 THEN
       -- Procedure para obter O xml do pagamento
       pc_gera_pgto_parcelas_consig(pr_cdcooper => vr_cdcooper           --> Cooperativa conectada
                                   ,pr_cdagenci => vr_cdagenci           --> Código da agência
                                   ,pr_nrdcaixa => vr_nrdcaixa           --> Número do caixa
                                   ,pr_cdoperad => vr_cdoperad           --> Código do operador
                                   ,pr_nmdatela => vr_nmdatela           --> Nome datela conectada
                                   ,pr_idorigem => vr_idorigem           --> Indicador da origem da chamada
                                   ,pr_cdpactra => vr_cdpactra
                                   ,pr_nrdconta => vr_nrdconta           --> Conta do associado
                                   ,pr_idseqttl => vr_idseqttl           --> Sequencia de titularidade da conta
                                   ,pr_dtmvtolt => vr_dtmvtolt
                                   ,pr_flgerlog => vr_flgerlog
                                   ,pr_nrctremp => vr_nrctremp
                                   ,pr_dtmvtoan => vr_dtmvtoan
                                   ,pr_totatual => vr_totatual
                                   ,pr_totpagto => vr_totpagto
                                   ,pr_nrseqava => vr_nrseqava
                                   ,pr_tab_pgto_parcel => vr_tab_pgto_parcel
                                   ,pr_xmlpagto => vr_xmlpagto
                                   ,pr_des_reto => vr_des_reto           --> Retorno OK / NOK
                                   ,pr_tab_erro => vr_tab_erro);         --> Tabela com possíves erros

            
        IF vr_des_reto = 'NOK' THEN
          IF vr_tab_erro.exists(vr_tab_erro.first) THEN

            vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
            vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          ELSE
            vr_dscritic := 'Não foi possivel obter dados de emprestimos.';
          END IF;
          RAISE vr_exc_erro;
        END IF;
        pr_retxml:= vr_xmlpagto;
    ELSE
      pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="UTF-8"?>'||
                                       '<Root><tpdescto>'||rw_crapepr.tpdescto||'</tpdescto></Root>');  
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

      pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> '||
                                       '<Root><Erro>'||pr_dscritic||'</Erro></Root>');
      --Variavel de erro recebe erro ocorrido
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na empr0001.pc_obtem_dados_empresti_web '||SQLERRM;
      pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> '||
                                       '<Root><Erro>'||pr_dscritic||'</Erro></Root>');
      
  END pc_gera_pgto_parc_consig_web;
  
  
  PROCEDURE pc_gera_pgto_parcelas_consig(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                        ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                        ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                        ,pr_cdoperad IN VARCHAR2              --> Código do operador
                                        ,pr_nmdatela IN VARCHAR2              --> Nome da tela
                                        ,pr_idorigem IN INTEGER               --> Id Origem do sistemas
                                        ,pr_cdpactra IN INTEGER               --> P.A. da transação
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da Conta
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Id do titular da conta
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de Movimento
                                        ,pr_flgerlog IN VARCHAR2              --> Gera log S/N
                                        ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Nr. do contrato de emprestimo
                                        ,pr_dtmvtoan IN crapdat.dtmvtoan%TYPE --> Data de movimento do dia anterior
                                        ,pr_totatual IN crapepr.vlemprst%TYPE
                                        ,pr_totpagto IN crapepr.vlemprst%TYPE
                                        ,pr_nrseqava IN NUMBER DEFAULT 0      --> Pagamento: Sequencia do avalista
															   			  ,pr_tab_pgto_parcel IN OUT empr0001.typ_tab_pgto_parcel
                                        ,pr_xmlpagto OUT xmltype
																				,pr_des_reto OUT VARCHAR
                                        ,pr_tab_erro OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
  BEGIN
    /* .............................................................................

       Programa: pc_gera_pgto_parcelas_consig
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Josiane Stiehler
       Data    : 14/06/2019.                         Ultima atualizacao: 14/06/2019

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : PJ437 - Consignado
                   programa chamado para efetuar pagamento das parcelas do emprestimo consignado,
                   onde o pagamento será efetuado na FIS Brasil, sendo assim retorna o XML do pagamento 
                   para ser enviado a FIS Brasil

       Alteracoes:


    ............................................................................. */
    DECLARE

	    -- Tratamento de erro
			vr_exc_erro EXCEPTION;
		  vr_exc_erro2 EXCEPTION;
      
			-- Descrição e código da critica
			vr_cdcritic crapcri.cdcritic%TYPE;
			vr_dscritic VARCHAR2(4000);
			-- Erro em chamadas da pc_gera_erro
			vr_des_reto VARCHAR(4000);
			vr_tab_erro GENE0001.typ_tab_erro;
      vr_flgativo NUMBER;

      vr_tab_pgto_parcel      empr0001.typ_tab_pgto_parcel; --> Tabela com registros de pagamentos
      vr_tab_pgto_parcel_calc empr0001.typ_tab_pgto_parcel; --> Tabela com registros de pagamentos calculado pelo rotina
      vr_tab_calculado        empr0001.typ_tab_calculado;   --> Tabela com totais calculados
			vr_tab_crawepr          empr0001.typ_tab_crawepr;
      vr_index_crawepr        VARCHAR2(50);

      --Variaveis Locais
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
			vr_nrdrowid ROWID;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Parametro de bloqueio de resgate de valores em c/c
      vr_blqresg_cc VARCHAR2(1);
      vr_ordem_pgto CHAR;
      vr_tab_pgto_parcel_ordenado empr0001.typ_tab_pgto_parcel; --> Tabela com registros de pagamentos

      vr_idpagamento tbepr_consignado_pagamento.idsequencia%TYPE;
      vr_vlatrpag     crapepr.vlemprst%TYPE;
      vr_tipo_pagto   VARCHAR2(300);
      vr_xml_parcela  VARCHAR2(32600);
      vr_dsxmlali     xmltype;
      vr_floperac     BOOLEAN;
      
      ----------------------------- CURSORES ---------------------------

			--Selecionar Detalhes Emprestimo
			CURSOR cr_crawepr_carga(pr_cdcooper IN crapcop.cdcooper%TYPE
														 ,pr_nrdconta IN crappep.nrdconta%TYPE
                             ,pr_nrctremp IN crappep.nrctremp%TYPE) IS
				SELECT crawepr.cdcooper
							,crawepr.nrdconta
							,crawepr.nrctremp
							,crawepr.dtlibera
							,crawepr.tpemprst
              ,crawepr.cdlcremp
					FROM crawepr
				 WHERE crawepr.cdcooper = pr_cdcooper
					 AND crawepr.nrdconta = pr_nrdconta
					 AND crawepr.nrctremp = pr_nrctremp;
			-- Parcelas de emprestimo
			CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE
			                 ,pr_nrdconta IN crappep.nrdconta%TYPE
											 ,pr_nrctremp IN crappep.nrctremp%TYPE
											 ,pr_nrparepr IN crappep.nrparepr%TYPE) IS
				SELECT pep.nrparepr
				      ,pep.dtvencto
							,pep.inliquid
							,pep.nrctremp
					FROM crappep pep
				 WHERE pep.cdcooper = pr_cdcooper
					 AND pep.nrdconta = pr_nrdconta
					 AND pep.nrctremp = pr_nrctremp
					 AND pep.nrparepr = pr_nrparepr;
			rw_crappep cr_crappep%ROWTYPE;

      CURSOR cr_crappep_menor(pr_cdcooper IN crapcop.cdcooper%TYPE
														 ,pr_nrdconta IN crappep.nrdconta%TYPE
                             ,pr_nrctremp IN crappep.nrctremp%TYPE) IS
				SELECT NVL(MIN(crappep.nrparepr),0) nrparepr
					FROM crappep
				 WHERE crappep.cdcooper = pr_cdcooper
					 AND crappep.nrdconta = pr_nrdconta
					 AND crappep.nrctremp = pr_nrctremp
           AND crappep.inliquid = 0; -- Não Liquidado
      rw_crappep_menor cr_crappep_menor%ROWTYPE;

	  -- Cursor para verificar se existe algum boleto em aberto
      CURSOR cr_cde (pr_cdcooper IN crapcob.cdcooper%TYPE
                    ,pr_nrdconta IN crapcob.nrdconta%TYPE
                    ,pr_nrctremp IN crapcob.nrctremp%TYPE) IS
           SELECT cob.nrdocmto,
                  cob.dtvencto,
                  cob.vltitulo
             FROM crapcob cob
            WHERE cob.cdcooper = pr_cdcooper
              AND cob.incobran = 0
              AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac, cob.nrctremp, cob.nrdocmto) IN
                  (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta, nrctremp, nrboleto
                     FROM tbrecup_cobranca cde
                    WHERE cde.cdcooper = pr_cdcooper
                      AND cde.nrdconta = pr_nrdconta
                      AND cde.nrctremp = pr_nrctremp
                      AND cde.tpproduto = 0);
      rw_cde cr_cde%ROWTYPE;

      -- Cursor para verificar se existe algum boleto pago pendente de processamento
      CURSOR cr_ret (pr_cdcooper IN crapcob.cdcooper%TYPE
                    ,pr_nrdconta IN crapcob.nrdconta%TYPE
                    ,pr_nrctremp IN crapcob.nrctremp%TYPE
                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
          SELECT cob.nrdocmto,
                 cob.dtvencto,
                 cob.vltitulo
            FROM crapcob cob, crapret ret
           WHERE cob.cdcooper = pr_cdcooper
             AND cob.incobran = 5
             AND cob.dtdpagto = pr_dtmvtolt
             AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac, cob.nrctremp, cob.nrdocmto) IN
                 (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta, nrctremp, nrboleto
                    FROM tbrecup_cobranca cde
                   WHERE cde.cdcooper = pr_cdcooper
                     AND cde.nrdconta = pr_nrdconta
                     AND cde.nrctremp = pr_nrctremp
                     AND cde.tpproduto = 0)
             AND ret.cdcooper = cob.cdcooper
             AND ret.nrdconta = cob.nrdconta
             AND ret.nrcnvcob = cob.nrcnvcob
             AND ret.nrdocmto = cob.nrdocmto
             AND ret.dtocorre = cob.dtdpagto
             AND ret.cdocorre = 6
             AND ret.flcredit = 0;

      rw_ret cr_ret%ROWTYPE;

    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ass.nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%rowtype;
    
    
    -- Cursor de Linha de Credito 
    CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                     ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
      SELECT craplcr.cdlcremp
            ,craplcr.dsoperac
        FROM craplcr
       WHERE craplcr.cdcooper = pr_cdcooper
         AND craplcr.cdlcremp = pr_cdlcremp;
               
      rw_craplcr cr_craplcr%ROWTYPE;
    
    -- Cursor de Emprestimos 
    CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                     ,pr_nrdconta IN crapepr.nrdconta%TYPE
                     ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
      SELECT crapepr.*
            ,crapepr.rowid
        FROM crapepr
       WHERE crapepr.cdcooper = pr_cdcooper
             AND crapepr.nrdconta = pr_nrdconta
             AND crapepr.nrctremp = pr_nrctremp;
    rw_crapepr cr_crapepr%ROWTYPE;
    
    
    BEGIN

			 IF UPPER(pr_flgerlog) = 'S' THEN
				 vr_dsorigem := GENE0001.vr_vet_des_origens(pr_idorigem);
				 vr_dstransa := 'Gera pagamentos de parcelas';
			 END IF;

		   IF pr_tab_pgto_parcel.count() = 0 THEN
				 -- Atribui crítica
				 vr_cdcritic := 0;
				 vr_dscritic := 'Para efetuar o pagamento selecione a(s) parcela(s).';
				 -- Gera exceção
				 RAISE vr_exc_erro;
			 END IF;

       -- Parametro de bloqueio de resgate de valores em c/c
       -- ref ao pagto de contrato com boleto (Projeto 210)
       vr_blqresg_cc := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                  pr_cdcooper => pr_cdcooper,
                                                  pr_cdacesso => 'COBEMP_BLQ_RESG_CC');

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
				 RAISE vr_exc_erro;
			 END IF;

       /* verificar se existe boleto de contrato em aberto e se pode lancar juros remuneratorios no contrato */
       /* 1º) verificar se o parametro está bloqueado para realizar busca de boleto em aberto */
       /*     e... se o contrato não estiver em um acordo ativo  */
       IF vr_blqresg_cc = 'S' AND vr_flgativo = 0 THEN

          -- inicializar rows de cursores
          rw_cde := NULL;
          rw_ret := NULL;

          /* 2º se permitir, verificar se possui boletos em aberto */
          OPEN cr_cde( pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrctremp => pr_nrctremp);
          FETCH cr_cde INTO rw_cde;
          CLOSE cr_cde;

          /* 3º se existir boleto de contrato em aberto, criticar */
          IF nvl(rw_cde.nrdocmto,0) > 0 THEN
             -- Atribui crítica
             vr_cdcritic := 0;
             vr_dscritic := 'Boleto do contrato ' || to_char(pr_nrctremp) || ' em aberto.' ||
				  		              ' Vencto ' || to_char(rw_cde.dtvencto, 'DD/MM/RRRR') ||
							              ' R$ ' || to_char(rw_cde.vltitulo,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS = '',.''') || '.';
             -- Gera exceção
             RAISE vr_exc_erro;

          ELSE
             /* 4º cursor para verificar se existe boleto pago pendente de processamento */
             OPEN cr_ret( pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrctremp => pr_nrctremp
                         ,pr_dtmvtolt => pr_dtmvtolt);
             FETCH cr_ret INTO rw_ret;
             CLOSE cr_ret;

             /* 6º se existir boleto de contrato pago pendente de processamento, lancar juros */
             IF nvl(rw_ret.nrdocmto,0) > 0 THEN
                -- Atribui crítica
                vr_cdcritic := 0;
                vr_dscritic := 'Boleto do contrato ' || to_char(pr_nrctremp) ||
                               ' esta pago pendente de processamento.' ||
  				  		               ' Vencto ' || to_char(rw_ret.dtvencto, 'DD/MM/RRRR') ||
							                 ' R$ ' || to_char(rw_ret.vltitulo,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS = '',.''') || '.';
                -- Gera exceção
                RAISE vr_exc_erro;
             END IF;

          END IF; -- nvl(rw_cde.nrdocmto,0) > 0

       END IF; -- vr_blqresg_cc = 'S'

			 vr_tab_pgto_parcel := pr_tab_pgto_parcel;

			 FOR rw_crawepr IN cr_crawepr_carga(pr_cdcooper => pr_cdcooper
				                                 ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrctremp => pr_nrctremp) LOOP
				 --Montar Indice
				 vr_index_crawepr := lpad(rw_crawepr.cdcooper, 10, '0') ||
														 lpad(rw_crawepr.nrdconta, 10, '0') ||
														 lpad(rw_crawepr.nrctremp, 10, '0');
				 vr_tab_crawepr(vr_index_crawepr).dtlibera := rw_crawepr.dtlibera;
				 vr_tab_crawepr(vr_index_crawepr).tpemprst := rw_crawepr.tpemprst;
			 END LOOP;

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
          RAISE vr_exc_erro;
       ELSE
          -- Apenas fechar o cursor
          CLOSE btch0001.cr_crapdat;
       END IF;

       -- Buscar dados do associado
       OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta);
       FETCH cr_crapass INTO rw_crapass;
       CLOSE cr_crapass;
       
       OPEN cr_crappep_menor(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrctremp => pr_nrctremp);
       FETCH cr_crappep_menor INTO rw_crappep_menor;

       IF rw_crappep_menor.nrparepr = 0 THEN
          CLOSE cr_crappep_menor;
          -- Atribui críticas
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao Localizar Parcela';
          -- Gera exceção
          RAISE vr_exc_erro;
       ELSE
          CLOSE cr_crappep_menor;
       END IF;

       vr_ordem_pgto := 'D';

       FOR idx IN vr_tab_pgto_parcel.FIRST..vr_tab_pgto_parcel.LAST LOOP

         IF vr_tab_pgto_parcel(idx).nrparepr = rw_crappep_menor.nrparepr THEN
           vr_ordem_pgto := 'C';
           EXIT;
         END IF;

       END LOOP;

       IF vr_ordem_pgto = 'D' THEN

         vr_tab_pgto_parcel_ordenado.DELETE;

         FOR idx IN vr_tab_pgto_parcel.FIRST..vr_tab_pgto_parcel.LAST LOOP
           vr_tab_pgto_parcel_ordenado(9999 - vr_tab_pgto_parcel(idx).nrparepr) := vr_tab_pgto_parcel(idx);
         END LOOP;

         vr_tab_pgto_parcel := vr_tab_pgto_parcel_ordenado;

       END IF;

       FOR idx IN vr_tab_pgto_parcel.FIRST..vr_tab_pgto_parcel.LAST LOOP
         -- Procura parcela do emprestimo
         OPEN cr_crappep(pr_cdcooper => vr_tab_pgto_parcel(idx).cdcooper
                        ,pr_nrdconta => vr_tab_pgto_parcel(idx).nrdconta
                        ,pr_nrctremp => vr_tab_pgto_parcel(idx).nrctremp
                        ,pr_nrparepr => vr_tab_pgto_parcel(idx).nrparepr);
         FETCH cr_crappep INTO rw_crappep;

         IF cr_crappep%NOTFOUND THEN
            CLOSE cr_crappep;
            -- Atribui críticas
            vr_cdcritic := 0;
            vr_dscritic := 'Parcela nao encontrada';
            -- Gera exceção
            RAISE vr_exc_erro;
         ELSE
            CLOSE cr_crappep;
         END IF;
         
         dbms_output.put_line ('Parcela :'||vr_tab_pgto_parcel(idx).nrparepr||' pagto :'||vr_tab_pgto_parcel(idx).vlpagpar);
         
         -- recalcular o valor da parcela
         empr0001.pc_busca_pgto_parcelas(pr_cdcooper => vr_tab_pgto_parcel(idx).cdcooper
                                        ,pr_cdagenci => pr_cdagenci
                                        ,pr_nrdcaixa => pr_nrdcaixa
                                        ,pr_cdoperad => pr_cdoperad
                                        ,pr_nmdatela => pr_nmdatela
                                        ,pr_idorigem => pr_idorigem
                                        ,pr_nrdconta => vr_tab_pgto_parcel(idx).nrdconta
                                        ,pr_idseqttl => pr_idseqttl
                                        ,pr_dtmvtolt => pr_dtmvtolt
                                        ,pr_flgerlog => pr_flgerlog
                                        ,pr_nrctremp => vr_tab_pgto_parcel(idx).nrctremp
                                        ,pr_dtmvtoan => pr_dtmvtoan
                                        ,pr_nrparepr => vr_tab_pgto_parcel(idx).nrparepr
                                        ,pr_des_reto => vr_des_reto
                                        ,pr_tab_erro => pr_tab_erro
                                        ,pr_tab_pgto_parcel => vr_tab_pgto_parcel_calc
                                        ,pr_tab_calculado => vr_tab_calculado);

		   	 -- Se retornou algum erro
			   IF vr_des_reto <> 'OK' THEN
			 	    -- Gera exceção
				  	RAISE vr_exc_erro2;
		     END IF;

         -- Verifica o valor recalculado da parcela
         FOR idx2 IN vr_tab_pgto_parcel_calc.FIRST..vr_tab_pgto_parcel_calc.LAST 
         LOOP
              vr_vlatrpag:=  vr_tab_pgto_parcel_calc(idx2).vlatrpag;
         END LOOP;
         
         -- o pagamento foi enviado a FIS Brasil ou seja esta em processamento
         IF fn_ret_status_pagto_consignado (pr_cdcooper => vr_tab_pgto_parcel(idx).cdcooper,
                                            pr_nrdconta => vr_tab_pgto_parcel(idx).nrdconta,
                                            pr_nrctremp => vr_tab_pgto_parcel(idx).nrctremp, 
                                            pr_nrparepr => vr_tab_pgto_parcel(idx).nrparepr,
                                            pr_instatus => 1) = 1 THEN -- 1- Enviado (processando)

           -- Atribui crítica
           vr_cdcritic := 0;
           vr_dscritic := 'Pagamento da parcela ('||vr_tab_pgto_parcel(idx).nrparepr||') em processamento.';
           -- Gera exceção
           RAISE vr_exc_erro;
         END IF;

         -- o pagamento com erro retornado pela Fis Brasil
         IF fn_ret_status_pagto_consignado (pr_cdcooper => vr_tab_pgto_parcel(idx).cdcooper,
                                            pr_nrdconta => vr_tab_pgto_parcel(idx).nrdconta,
                                            pr_nrctremp => vr_tab_pgto_parcel(idx).nrctremp, 
                                            pr_nrparepr => vr_tab_pgto_parcel(idx).nrparepr,
                                            pr_instatus => 3)  = 3 THEN -- Com erro

           -- Atribui crítica
           vr_cdcritic := 0;
           vr_dscritic := 'Pagamento da parcela ('||vr_tab_pgto_parcel(idx).nrparepr||') com erro.';
           -- Gera exceção
           RAISE vr_exc_erro;
         END IF;

         -- Verifica se tem uma parcela anterior nao liquida e ja vencida
         empr0020.pc_verifica_parc_ant_consig(pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_nrctremp => pr_nrctremp
                                             ,pr_nrparepr => rw_crappep.nrparepr
                                             ,pr_dtmvtolt => pr_dtmvtolt
                                             ,pr_des_reto => vr_des_reto
                                             ,pr_dscritic => vr_dscritic);

         -- Se retornou diferente de OK
         IF vr_des_reto <> 'OK' THEN
           -- Gera exceção
           RAISE vr_exc_erro;
         END IF;

         empr0020.pc_verifica_parc_antec_consig(pr_cdcooper => pr_cdcooper
                                               ,pr_nrdconta => pr_nrdconta
                                               ,pr_nrctremp => pr_nrctremp
                                               ,pr_nrparepr => rw_crappep.nrparepr
                                               ,pr_dtmvtolt => pr_dtmvtolt
                                               ,pr_des_reto => vr_des_reto
                                               ,pr_dscritic => vr_dscritic);

         -- Se retornou diferente de OK
         IF vr_des_reto <> 'OK' THEN
           -- Gera exceção
           RAISE vr_exc_erro;
         END IF; 

         IF rw_crappep.inliquid = 1 THEN
           -- Atribui críticas
           vr_cdcritic := 0;
           vr_dscritic := 'Parcela ja liquidada';
           -- Gera exceção
           RAISE vr_exc_erro;
         END IF;

         --Buscar registro emprestimo
         OPEN cr_crapepr(pr_cdcooper => pr_cdcooper --> Cooperativa
                        ,pr_nrdconta => pr_nrdconta --> Numero da Conta
                        ,pr_nrctremp => pr_nrctremp); --> Numero Contrato
         FETCH cr_crapepr
          INTO rw_crapepr;
         --Se nao Encontrou
         IF cr_crapepr%NOTFOUND THEN
           --Fechar Cursor
           CLOSE cr_crapepr;
           vr_cdcritic := 55;
           RAISE vr_exc_erro2;
         END IF;
         --Fechar Cursor
         CLOSE cr_crapepr;
        
         --Selecionar Linha Credito
         OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                        ,pr_cdlcremp => rw_crapepr.cdlcremp);
         FETCH cr_craplcr
          INTO rw_craplcr;
         --Se nao Encontrou
         IF cr_craplcr%NOTFOUND THEN
            --Fechar Cursor
            CLOSE cr_craplcr;
            vr_cdcritic := 363;
            --Sair
            RAISE vr_exc_erro2;
         ELSE
            --Determinar se a Operacao é financiamento
            vr_floperac := rw_craplcr.dsoperac = 'FINANCIAMENTO';
         END IF;
         CLOSE cr_craplcr;
         
         -- Parcela em dia
         IF rw_crappep.dtvencto >  pr_dtmvtoan AND
            rw_crappep.dtvencto <= pr_dtmvtolt THEN
            pc_valida_pagto_parc_consig(pr_cdcooper => pr_cdcooper
                                      ,pr_cdagenci => pr_cdagenci
                                      ,pr_nrdcaixa => pr_nrdcaixa
                                      ,pr_cdoperad => pr_cdoperad
                                      ,pr_nmdatela => pr_nmdatela
                                      ,pr_idorigem => pr_idorigem
                                      ,pr_cdpactra => pr_cdpactra
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_idseqttl => pr_idseqttl
                                      ,pr_dtmvtolt => pr_dtmvtolt
                                      ,pr_flgerlog => pr_flgerlog
                                      ,pr_nrctremp => rw_crappep.nrctremp
                                      ,pr_nrparepr => rw_crappep.nrparepr
                                      ,pr_vlparepr => vr_tab_pgto_parcel(idx).vlpagpar
                                      ,pr_tab_crawepr => vr_tab_crawepr
                                      ,pr_nrseqava => pr_nrseqava
                                      ,pr_floperac => vr_floperac
                                      ,pr_des_reto => vr_des_reto
                                      ,pr_tab_erro => vr_tab_erro);

            IF vr_des_reto <> 'OK' THEN
              RAISE vr_exc_erro2;
            END IF;

         ELSIF rw_crappep.dtvencto < pr_dtmvtolt THEN -- Parcela vencida

           pc_valida_pagto_atraso_consig(pr_cdcooper => pr_cdcooper
                                        ,pr_cdagenci => pr_cdagenci
                                        ,pr_nrdcaixa => pr_nrdcaixa
                                        ,pr_cdoperad => pr_cdoperad
                                        ,pr_nmdatela => pr_nmdatela
                                        ,pr_idorigem => pr_idorigem
                                        ,pr_cdpactra => pr_cdpactra
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_idseqttl => pr_idseqttl
                                        ,pr_dtmvtolt => pr_dtmvtolt
                                        ,pr_flgerlog => pr_flgerlog
                                        ,pr_nrctremp => rw_crappep.nrctremp
                                        ,pr_nrparepr => rw_crappep.nrparepr
                                        ,pr_vlpagpar => vr_tab_pgto_parcel(idx).vlpagpar
                                        ,pr_tab_crawepr => vr_tab_crawepr
                                        ,pr_nrseqava => pr_nrseqava
                                        ,pr_floperac => vr_floperac
                                        ,pr_des_reto => vr_des_reto
                                        ,pr_tab_erro => vr_tab_erro);

           IF vr_des_reto <> 'OK' THEN
             RAISE vr_exc_erro2;
           END IF;

         ELSIF rw_crappep.dtvencto > pr_dtmvtolt   THEN /* Parcela a Vencer */

           pr_valida_pagto_antec_consig(pr_cdcooper    => pr_cdcooper --> Cooperativa conectada
                                       ,pr_cdagenci    => pr_cdagenci --> Código da agência
                                       ,pr_nrdcaixa    => pr_nrdcaixa --> Número do caixa
                                       ,pr_cdoperad    => pr_cdoperad --> Código do Operador
                                       ,pr_nmdatela    => pr_nmdatela --> Nome da tela
                                       ,pr_idorigem    => pr_idorigem --> Id do módulo de sistema
                                       ,pr_cdpactra    => pr_cdpactra --> P.A. da transação
                                       ,pr_nrdconta    => pr_nrdconta --> Número da conta
                                       ,pr_idseqttl    => pr_idseqttl --> Seq titula
                                       ,pr_dtmvtolt    => pr_dtmvtolt --> Movimento atual
                                       ,pr_flgerlog    => pr_flgerlog --> Indicador S/N para geração de log
                                       ,pr_nrctremp    => rw_crappep.nrctremp --> Número do contrato de empréstimo
                                       ,pr_nrparepr    => rw_crappep.nrparepr --> Número parcelas empréstimo
                                       ,pr_vlpagpar    => vr_tab_pgto_parcel(idx).vlpagpar --> Valor da parcela a pagar
                                       ,pr_vlparrec    => vr_vlatrpag    --> valor da parcela recalculada
                                       ,pr_tab_crawepr => vr_tab_crawepr --> Tabela com Contas e Contratos
                                       ,pr_nrseqava    => pr_nrseqava    --> Pagamento: Sequencia do avalista
                                       ,pr_floperac    => vr_floperac
                                       ,pr_des_reto    => vr_des_reto    --> Retorno OK / NOK
                                       ,pr_tab_erro    => vr_tab_erro);  --> Tabela com possíves erros

           -- Se Retornou erro
           IF vr_des_reto <> 'OK' THEN
             RAISE vr_exc_erro2;
           END IF;

         END IF;

         vr_idpagamento:= null;
         pc_atualiza_tbepr_consig_pagto(pr_cdcooper    => pr_cdcooper, -- codigo da cooperativa
                                        pr_nrdconta    => pr_nrdconta, -- numero da conta
                                        pr_nrctremp    => rw_crappep.nrctremp, -- Numero do contrato
                                        pr_nrparepr    => rw_crappep.nrparepr, -- Numero da parcela
                                        pr_vlparepr    => vr_vlatrpag,         -- valor da parcela do emprestimo
                                        pr_vlpagpar    => vr_tab_pgto_parcel(idx).vlpagpar, -- Valor pago da parcela
                                        pr_dtvencto    => rw_crappep.dtvencto, -- Vencimento da parcela
                                        pr_instatus    => 1,                   -- Status do processamento
                                        pr_cdagenci    => pr_cdagenci,         -- Código da agencia
                                        pr_cdbccxlt    => pr_nrdcaixa,         -- Número do caixa
                                        pr_cdoperad    => pr_cdoperad,          -- Código do Operador
                                        pr_idsequencia => vr_idpagamento,      -- identificador do pagamento
                                        pr_dscritic    => vr_dscritic); -- critica de erro
         -- Tratar saida com erro                          
         IF vr_dscritic IS NOT NULL THEN
            vr_cdcritic:=0;
            RAISE vr_exc_erro;
         END IF;    
             

         -- Verifica se o valor que esta sendo pago é total ou parcial
         -- Compara o valor calculado na tela com o valor da parcela
         IF  vr_tab_pgto_parcel(idx).vlpagpar = vr_vlatrpag THEN  
             vr_tipo_pagto := ' <valor>'||vr_tab_pgto_parcel(idx).vlpagpar||'</valor>' ;
         ELSE                      
             vr_tipo_pagto:= ' <valorParcial>'||vr_tab_pgto_parcel(idx).vlpagpar||'</valorParcial>';
         END IF;
             
         vr_xml_parcela:= vr_xml_parcela||
                         ' <parcela>
                             <dataEfetivacao>'||to_char(pr_dtmvtolt,'yyyy-mm-dd')||'T'||to_char(sysdate,'hh24:mi:ss')||'</dataEfetivacao> 
                             <dataVencimento>'||to_char(rw_crappep.dtvencto,'yyyy-mm-dd')||'</dataVencimento>
                             <identificador>'||vr_idpagamento||'</identificador>'||
                             vr_tipo_pagto|| 
                          '</parcela>';
         -- Indicar que a parcela foi paga
         vr_tab_pgto_parcel(idx).inpagmto := 1;

       END LOOP;
           
       -- Gera o XML do pagamento a ser gravado no evento SOA
       pc_gera_xml_pagamento_consig(pr_cdcooper     => pr_cdcooper, -- código da cooperativa
                                    pr_nrdconta     => pr_nrdconta, -- Número da conta
                                    pr_nrctremp     => pr_nrctremp, -- Número do contrato de emprestimo
                                    pr_xml_parcelas => vr_xml_parcela, -- xml com as parcelas
                                    pr_tpenvio      => 1,             -- tipo de envio 1 - INSTALLMENT_SETTLEMENT
                                    pr_tptransa     => 'DEBITO',      --
                                    pr_dsxmlali  => vr_dsxmlali, -- XML de saida do pagamento
                                    pr_dscritic  => vr_dscritic); 

       -- Tratar saida com erro                          
       IF vr_dscritic IS NOT NULL THEN
          vr_cdcritic:=0;
          RAISE vr_exc_erro;
       END IF;     
         
       -- atualizar tabela no parametro de retorno
       pr_tab_pgto_parcel := vr_tab_pgto_parcel;
       pr_xmlpagto:= vr_dsxmlali;
       
       --Se escreve erro log
       IF pr_flgerlog = 'S' THEN

         gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
				                     ,pr_cdoperad => pr_cdoperad
														 ,pr_dscritic => ''
														 ,pr_dsorigem => vr_dsorigem
														 ,pr_dstransa => vr_dstransa
														 ,pr_dttransa => pr_dtmvtolt
														 ,pr_flgtrans => 1
														 ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate
                                                             ,'SSSSS'))
                             ,pr_idseqttl => pr_idseqttl
                             ,pr_nmdatela => pr_nmdatela
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrdrowid => vr_nrdrowid);
       END IF;

			 -- Retorno OK
			 pr_des_reto := 'OK';
       COMMIT;
       
	     EXCEPTION
	       WHEN vr_exc_erro THEN
           -- atualizar tabela no parametro de retorno
           pr_tab_pgto_parcel := vr_tab_pgto_parcel;

					 -- Retorno não OK
					 pr_des_reto := 'NOK';
					 -- Gerar rotina de gravação de erro
					 gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
																,pr_cdagenci => pr_cdagenci
																,pr_nrdcaixa => pr_nrdcaixa
																,pr_nrsequen => 1 --> Fixo
																,pr_cdcritic => vr_cdcritic
																,pr_dscritic => vr_dscritic
																,pr_tab_erro => pr_tab_erro);
          ROLLBACK;
          
         WHEN vr_exc_erro2 THEN
           -- atualizar tabela no parametro de retorno
           pr_tab_pgto_parcel := vr_tab_pgto_parcel;

           -- Retorno não OK
	         pr_des_reto := 'NOK';
					 -- Copiar o erro já existente na variavel para
					 pr_tab_erro := vr_tab_erro;
           ROLLBACK;
    END;

  END pc_gera_pgto_parcelas_consig;

  PROCEDURE pc_valida_pagto_parc_consig(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                    ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Código da agência
                                    ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Número do caixa
                                    ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> Código do Operador
                                    ,pr_nmdatela    IN VARCHAR2 --> Nome da tela
                                    ,pr_idorigem    IN INTEGER --> Id do módulo de sistema
                                    ,pr_cdpactra    IN INTEGER --> P.A. da transação
                                    ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> Número da conta
                                    ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                    ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                    ,pr_flgerlog    IN VARCHAR2 --> Indicador S/N para geração de log
                                    ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                    ,pr_nrparepr    IN INTEGER --> Número parcelas empréstimo
                                    ,pr_vlparepr    IN NUMBER --> Valor da parcela emprestimo
                                    ,pr_tab_crawepr IN empr0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                    ,pr_nrseqava    IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                    ,pr_floperac    IN BOOLEAN
                                    ,pr_des_reto    OUT VARCHAR --> Retorno OK / NOK
                                    ,pr_tab_erro    OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
  BEGIN
    /* .............................................................................

       Programa: pc_efetiva_pagto_parcela                 
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Josiane Stiehler
       Data    : 14/06/2019                       Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : PJ437 - Consignado
                   Rotina para validar o pagamento da parcela em dia do consignado

       Alteracoes: 

    ............................................................................. */

    DECLARE

      --Variaveis Locais
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
      vr_nrdrowid ROWID;
      vr_flgtrans BOOLEAN;
      vr_cdhistor craphis.cdhistor%TYPE;
      vr_nrdolote craplot.nrdolote%TYPE;

      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_des_erro VARCHAR2(3);
      vr_dscritic VARCHAR2(4000);

      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
			
	    vr_prejuzcc BOOLEAN; -- Indicador de conta corrente em prejuízo

    BEGIN
      --Inicializar variavel erro
      pr_des_reto := 'OK';
      --Marcar que nao ocorreu transacao
      vr_flgtrans := FALSE;

      --Limpar tabela erro
      pr_tab_erro.DELETE;

      --Se escreve erro log
      IF pr_flgerlog = 'S' THEN
        --Buscar Descricao origem
        vr_dsorigem := GENE0001.vr_vet_des_origens(pr_idorigem);
        --Descricao Transacao
        vr_dstransa := 'Efetiva pagamento normal de parcela';
      END IF;

      IF pr_floperac THEN
         vr_nrdolote := 600015;
      ELSE
         vr_nrdolote := 600014;
      END IF;
      vr_cdhistor := 108;

      BEGIN
        --Criar savepoint para desfazer transacao
        SAVEPOINT savtrans_efetiva_pagto_parcela;
        -- Procedure para validar se a parcela esta OK.
        empr0001.pc_valida_pagto_normal_parcela(pr_cdcooper => pr_cdcooper -- Codigo Cooperativa
                                               ,pr_cdagenci => pr_cdagenci -- Codigo Agencia
                                               ,pr_nrdcaixa => pr_nrdcaixa -- Codigo Caixa
                                               ,pr_cdoperad => pr_cdoperad -- Operador
                                               ,pr_nmdatela => pr_nmdatela -- Nome da Tela
                                               ,pr_idorigem => pr_idorigem -- Origem
                                               ,pr_nrdconta => pr_nrdconta -- Numero da Conta
                                               ,pr_idseqttl => pr_idseqttl -- Seq Titular
                                               ,pr_dtmvtolt => pr_dtmvtolt -- Data Emprestimo
                                               ,pr_flgerlog => pr_flgerlog -- Indicador S/N para geração de log
                                               ,pr_nrctremp => pr_nrctremp -- Numero Contrato
                                               ,pr_nrparepr => pr_nrparepr -- Numero da parcela
                                               ,pr_vlpagpar => pr_vlparepr -- Valor da parcela emprestimo
                                               ,pr_tab_erro => pr_tab_erro -- tabela Erros
                                               ,pr_des_reto => vr_des_erro); -- OK/NOK

        --Se ocorreu erro
        IF vr_des_erro <> 'OK' THEN
          --Sair
          RAISE vr_exc_saida;
        END IF;

        -- Verifica se a conta corrente está em prejuízo
        vr_prejuzcc:= PREJ0003.fn_verifica_preju_conta(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);

        IF NOT vr_prejuzcc THEN
            /* Lanca em C/C e atualiza o lote */
            empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                          ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                          ,pr_cdagenci => pr_cdagenci --> Código da agência
                                          ,pr_cdbccxlt => 100 --> Número do caixa
                                          ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                          ,pr_cdpactra => pr_cdpactra --> P.A. da transação
                                          ,pr_nrdolote => vr_nrdolote --> Numero do Lote
                                          ,pr_nrdconta => pr_nrdconta --> Número da conta
                                          ,pr_cdhistor => vr_cdhistor --> Codigo historico
                                          ,pr_vllanmto => pr_vlparepr --> Valor da parcela emprestimo
                                          ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                          ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                          ,pr_nrseqava => pr_nrseqava --> Pagamento: Sequencia do avalista
                                          ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                          ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros
            --Se Retornou erro
            IF vr_des_erro <> 'OK' THEN
              --Sair
              RAISE vr_exc_saida;
            END IF;
				END IF;

        --Marcar que ocorreu transacao
        vr_flgtrans := TRUE;

      EXCEPTION
        WHEN vr_exc_saida THEN
          --Desfaz transacoes
          ROLLBACK TO SAVEPOINT savtrans_efetiva_pagto_parcela;
      END;

      --Se nao ocorreu a transacao
      IF NOT vr_flgtrans THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        --Se nao tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN
          -- Gerar rotina de gravação de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        END IF;
      ELSIF pr_flgerlog = 'S' THEN
        -- Se foi solicitado o envio de LOG
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
        -- Retorno OK
        pr_des_reto := 'OK';
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0020.pc_valida_pagto_parc_consig ' ||
                       sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_valida_pagto_parc_consig;

 PROCEDURE pc_valida_pagto_atraso_consig(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                        ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Código da agência
                                        ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Número do caixa
                                        ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> Código do Operador
                                        ,pr_nmdatela    IN VARCHAR2 --> Nome da tela
                                        ,pr_idorigem    IN INTEGER --> Id do módulo de sistema
                                        ,pr_cdpactra    IN INTEGER --> P.A. da transação
                                        ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> Número da conta
                                        ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                        ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                        ,pr_flgerlog    IN VARCHAR2 --> Indicador S/N para geração de log
                                        ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                        ,pr_nrparepr    IN INTEGER --> Número parcelas empréstimo
                                        ,pr_vlpagpar    IN NUMBER --> Valor a pagar parcela
                                        ,pr_tab_crawepr IN empr0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                        ,pr_nrseqava    IN NUMBER DEFAULT 0 --> Pagamento: Sequencia do avalista
                                        ,pr_floperac    IN BOOLEAN
                                        ,pr_des_reto    OUT VARCHAR --> Retorno OK / NOK
                                        ,pr_tab_erro    OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros
  BEGIN
    /* .............................................................................

       Programa: pc_efetiva_pag_atr_parcel   
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Josiane Stiehler
       Data    : 14/06/2019                        Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : PJ437- Consignado -Rotina para validar pagamento parcela atrasada do consignado

       Alteracoes: 

    ............................................................................. */

    DECLARE

      --Variaveis Locais
      vr_vlrmulta NUMBER;
      vr_vlatraso NUMBER;
      vr_cdhismul NUMBER;
      vr_cdhisatr NUMBER;
      vr_cdhisiof NUMBER;
      vr_cdhisiof_prejdet NUMBER := 0;
      vr_loteatra NUMBER;
      vr_lotemult NUMBER;
      vr_loteiof NUMBER;
      vr_cdhistor craphis.cdhistor%TYPE;
      vr_nrdolote craplot.nrdolote%TYPE;

      vr_flgtrans BOOLEAN;
      vr_vlpagsld NUMBER;
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
      vr_nrdrowid ROWID;
      vr_vliofcpl NUMBER;
      vr_nrseqdig INTEGER;

      --Variaveis Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);

      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
      vr_exc_ok    EXCEPTION;
      vr_des_erro VARCHAR2(4000);
      vr_vlatupar NUMBER;
      vr_vljinpar NUMBER;

      vr_idlancto_prejuizo  tbcc_prejuizo_detalhe.idlancto%TYPE := NULL;
	    vr_prejuzcc BOOLEAN; -- Indicador de conta corrente em prejuízo

      -- Retorna as contas em prejuizo
      CURSOR cr_contaprej (pr_cdcooper  IN tbcc_prejuizo.cdcooper%TYPE
                         , pr_nrdconta  IN tbcc_prejuizo.nrdconta%TYPE) IS
        SELECT tbprj.idprejuizo
          FROM tbcc_prejuizo tbprj
         WHERE tbprj.cdcooper = pr_cdcooper
           AND tbprj.nrdconta = pr_nrdconta
           AND tbprj.dtliquidacao IS NULL;
       rw_contaprej cr_contaprej%ROWTYPE;



    BEGIN
      --Inicializar variavel erro
      pr_des_reto := 'OK';

      --Marcar que nao ocorreu transacao
      vr_flgtrans := FALSE;

      --Limpar tabela erro
      pr_tab_erro.DELETE;

      --Se escreve erro log
      IF pr_flgerlog = 'S' THEN
        --Buscar Descricao origem
        vr_dsorigem := GENE0001.vr_vet_des_origens(pr_idorigem);
        --Descricao Transacao
        vr_dstransa := 'Efetiva pagamento atrasado de parcela';
      END IF;

      IF pr_floperac THEN -- Financiamento
          -- multa
          vr_lotemult := 600021; 
          vr_cdhismul := 1070;
          -- atraso
          vr_cdhisatr := 1072;
          vr_loteatra := 600025;
          -- IOF
          vr_cdhisiof:= 2314;
          vr_loteiof:=  600023;
          -- pago da parcela
          vr_cdhistor := 108;
          vr_nrdolote:=  600015;
      ELSE -- Emprestimo 
          -- multa
          vr_lotemult := 600020; 
          vr_cdhismul := 1060;
          -- atraso
          vr_cdhisatr := 1071;
          vr_loteatra := 600024;
          -- IOF
          vr_cdhisiof:= 2313;
          vr_loteiof:= 600022;
          -- pago da parcela
          vr_cdhistor := 108;
          vr_nrdolote:= 600014;
      END IF;
      
      BEGIN
        --Criar savepoint para desfazer transacao
        SAVEPOINT sav_efetiva_pagto_atr_parcel;
       
        --Validar Pagamento atrasado parcela
        empr0001.pc_valida_pagto_atr_parcel(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                            ,pr_cdagenci => pr_cdagenci --> Código da agência
                                            ,pr_nrdcaixa => pr_nrdcaixa --> Número do caixa
                                            ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                            ,pr_nmdatela => pr_nmdatela --> Nome da tela
                                            ,pr_idorigem => pr_idorigem --> Id do módulo de sistema
                                            ,pr_nrdconta => pr_nrdconta --> Número da conta
                                            ,pr_idseqttl => pr_idseqttl --> Seq titula
                                            ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                            ,pr_flgerlog => pr_flgerlog --> Indicador S/N para geração de log
                                            ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                            ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                            ,pr_vlpagpar => pr_vlpagpar --> Valor a pagar parcela
                                            ,pr_vlpagsld => vr_vlpagsld --> Valor Pago Saldo    
                                            ,pr_vlatupar => vr_vlatupar --> Valor Atual Parcela  
                                            ,pr_vlmtapar => vr_vlrmulta --> Valor Multa Parcela  
                                            ,pr_vljinpar => vr_vljinpar --> Valor Juros parcela  
                                            ,pr_vlmrapar => vr_vlatraso --> Valor Mora           
                                            ,pr_vliofcpl => vr_vliofcpl --> Valor Mora           
                                            ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                            ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros
        --Se ocorreu erro
        IF vr_des_erro <> 'OK' THEN
          pr_des_reto := 'NOK';
          --Sair
          RETURN;
        END IF;

		    -- Verifica se a conta corrente está em prejuízo - Reginaldo/AMcom
		    vr_prejuzcc := PREJ0003.fn_verifica_preju_conta(pr_cdcooper => pr_cdcooper
				                                              , pr_nrdconta => pr_nrdconta);   

        /* Valor da multa */
        IF nvl(vr_vlrmulta, 0) > 0 AND NOT vr_prejuzcc THEN
          /* Lanca em C/C e atualiza o lote */
          empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                        ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                        ,pr_cdagenci => pr_cdagenci --> Código da agência
                                        ,pr_cdbccxlt => 100 --> Número do caixa
                                        ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                        ,pr_cdpactra => pr_cdpactra --> P.A. da transação
                                        ,pr_nrdolote => vr_lotemult --> Numero do Lote
                                        ,pr_nrdconta => pr_nrdconta --> Número da conta
                                        ,pr_cdhistor => vr_cdhismul --> Codigo historico
                                        ,pr_vllanmto => vr_vlrmulta --> Valor da parcela emprestimo
                                        ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                        ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                        ,pr_nrseqava => pr_nrseqava -- Pagamento: Sequencia do avalista
                                        ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                        ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros
          --Se Retornou erro
          IF vr_des_erro <> 'OK' THEN
            --Sair
            RAISE vr_exc_ok;
          END IF;
        END IF;

        /* Pagamento de juros de mora */
        IF nvl(vr_vlatraso, 0) > 0
           AND nvl(vr_vlpagsld, 0) >= 0 AND NOT vr_prejuzcc THEN
          /* Debita o pagamento da parcela da C/C */
          empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                        ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                        ,pr_cdagenci => pr_cdagenci --> Código da agência
                                        ,pr_cdbccxlt => 100 --> Número do caixa
                                        ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                        ,pr_cdpactra => pr_cdpactra --> P.A. da transação
                                        ,pr_nrdolote => vr_loteatra --> Numero do Lote
                                        ,pr_nrdconta => pr_nrdconta --> Número da conta
                                        ,pr_cdhistor => vr_cdhisatr --> Codigo historico
                                        ,pr_vllanmto => vr_vlatraso --> Valor da parcela emprestimo
                                        ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                        ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                        ,pr_nrseqava => pr_nrseqava --> Pagamento: Sequencia do avalista
                                        ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                        ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros
          --Se Retornou erro
          IF vr_des_erro <> 'OK' THEN
            --Sair
            RAISE vr_exc_ok;
          END IF;
        END IF;

        /* Projeto 410 - efetua o debito do IOF complementar de atraso */
        IF nvl(vr_vliofcpl, 0) > 0
           AND nvl(vr_vlpagsld, 0) >= 0 THEN

          IF vr_prejuzcc THEN

            -- Identificar numero do prejuizo da conta
            OPEN cr_contaprej(pr_cdcooper => pr_cdcooper,
                              pr_nrdconta => pr_nrdconta);
            FETCH cr_contaprej INTO rw_contaprej;
            CLOSE cr_contaprej;

            CASE vr_cdhisiof
              WHEN 2314 THEN vr_cdhisiof_prejdet := 2792; --> IOF S/ FINANC
              --> 2313
              ELSE vr_cdhisiof_prejdet := 2791; --> IOF S/EMPREST
            END CASE;

                                            
             -- Incluir lançamento na TBCC_PREJUIZO_DETALHE
            PREJ0003.pc_gera_lcto_extrato_prj(pr_cdcooper   => pr_cdcooper
                                            , pr_nrdconta   => pr_nrdconta
                                            , pr_dtmvtolt   => pr_dtmvtolt
                                            , pr_cdhistor   => vr_cdhisiof_prejdet
                                            , pr_idprejuizo => rw_contaprej.idprejuizo
                                            , pr_vllanmto   => vr_vliofcpl
                                            , pr_nrctremp   => pr_nrctremp
                                            , pr_cdoperad   => pr_cdoperad
                                            , pr_idlancto_prejuizo => vr_idlancto_prejuizo 
                                            , pr_cdcritic   => vr_cdcritic
                                            , pr_dscritic   => vr_dscritic);                                            
                                            
            IF nvl(vr_cdcritic,0) > 0 OR
               TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_ok;
            END IF;
          ELSE

            /* Debita o valor do IOF complementar atraso da C/C */
            empr0001.pc_cria_lancamento_cc_chave(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                                ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                                ,pr_cdagenci => pr_cdagenci --> Código da agência
                                                ,pr_cdbccxlt => 100 --> Número do caixa
                                                ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                                ,pr_cdpactra => pr_cdpactra --> P.A. da transação
                                                ,pr_nrdolote => vr_loteiof  --> Numero do Lote
                                                ,pr_nrdconta => pr_nrdconta --> Número da conta
                                                ,pr_cdhistor => vr_cdhisiof --> Codigo historico
                                                ,pr_vllanmto => vr_vliofcpl --> Valor da parcela emprestimo
                                                ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                                ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                                ,pr_nrseqava => pr_nrseqava --> Pagamento: Sequencia do avalista
                                                ,pr_nrseqdig => vr_nrseqdig
                                                ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                                ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros
            --Se Retornou erro
            IF vr_des_erro <> 'OK' THEN
              --Sair
              RAISE vr_exc_ok;
            END IF;

            -- Insere o IOF 
            tiof0001.pc_insere_iof(pr_cdcooper     => pr_cdcooper
                                  ,pr_nrdconta     => pr_nrdconta
                                  ,pr_dtmvtolt     => pr_dtmvtolt
                                  ,pr_tpproduto    => 1 -- Emprestimo
                                  ,pr_nrcontrato   => pr_nrctremp
                                  ,pr_idlautom     => null
                                  ,pr_dtmvtolt_lcm => pr_dtmvtolt
                                  ,pr_cdagenci_lcm => pr_cdpactra
                                  ,pr_cdbccxlt_lcm => 100
                                  ,pr_nrdolote_lcm => vr_loteiof
                                  ,pr_nrseqdig_lcm => vr_nrseqdig
                                  ,pr_vliofpri     => 0
                                  ,pr_vliofadi     => 0
                                  ,pr_vliofcpl     => vr_vliofcpl
                                  ,pr_flgimune     => 0
                                  ,pr_cdcritic     => vr_cdcritic
                                  ,pr_dscritic     => vr_dscritic);

               IF vr_dscritic is not null THEN
                  RAISE vr_exc_ok;
               end if;
             END IF;
        END IF;

        /* Lancamento de Valor Pago da Parcela */
        IF nvl(vr_vlpagsld, 0) > 0 AND NOT vr_prejuzcc THEN
          /* Debita o pagamento da parcela da C/C */
          empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                        ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                        ,pr_cdagenci => pr_cdagenci --> Código da agência
                                        ,pr_cdbccxlt => 100 --> Número do caixa
                                        ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                        ,pr_cdpactra => pr_cdpactra --> P.A. da transação
                                        ,pr_nrdolote => vr_nrdolote --> Numero do Lote
                                        ,pr_nrdconta => pr_nrdconta --> Número da conta
                                        ,pr_cdhistor => vr_cdhistor --> Codigo historico
                                        ,pr_vllanmto => vr_vlpagsld --> Valor da parcela emprestimo
                                        ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                        ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                        ,pr_nrseqava => pr_nrseqava --> Pagamento: Sequencia do avalista
                                        ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                        ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros
          --Se Retornou erro
          IF vr_des_erro <> 'OK' THEN
            --Sair
            RAISE vr_exc_ok;
          END IF;
        END IF;

          --Marcar transacao como realizada
          vr_flgtrans := TRUE;
      EXCEPTION
        WHEN vr_exc_saida THEN
          --Desfaz transacoes
          ROLLBACK TO SAVEPOINT sav_efetiva_pagto_atr_parcel;
        WHEN vr_exc_ok THEN
          NULL;
      END;

      --Se nao ocorreu a transacao
      IF NOT vr_flgtrans THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        --Se nao tem erro na tabela
        IF pr_tab_erro.COUNT = 0 THEN
          -- Gerar rotina de gravação de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
        END IF;
      ELSIF pr_flgerlog = 'S' THEN
        -- Se foi solicitado o envio de LOG
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => GENE0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
        -- Retorno OK
        pr_des_reto := 'OK';
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na empr0020.pc_valida_pagto_atraso_consig ' ||
                       sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_valida_pagto_atraso_consig;

  PROCEDURE pr_valida_pagto_antec_consig (pr_cdcooper    IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                         ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Código da agência
                                         ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Número do caixa
                                         ,pr_cdoperad    IN crapdev.cdoperad%TYPE --> Código do Operador
                                         ,pr_nmdatela    IN VARCHAR2              --> Nome da tela
                                         ,pr_idorigem    IN INTEGER               --> Id do módulo de sistema
                                         ,pr_cdpactra    IN INTEGER               --> P.A. da transação
                                         ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> Número da conta
                                         ,pr_idseqttl    IN crapttl.idseqttl%TYPE --> Seq titula
                                         ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                         ,pr_flgerlog    IN VARCHAR2              --> Indicador S/N para geração de log
                                         ,pr_nrctremp    IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                         ,pr_nrparepr    IN INTEGER               --> Número parcelas empréstimo
                                         ,pr_vlpagpar    IN NUMBER                --> Valor a pagar parcela
                                         ,pr_vlparrec    IN NUMBER                --> valor da parcela recalculado
                                         ,pr_tab_crawepr IN empr0001.typ_tab_crawepr --Tabela com Contas e Contratos
                                         ,pr_nrseqava    IN NUMBER DEFAULT 0       --> Pagamento: Sequencia do avalista
                                         ,pr_floperac    IN BOOLEAN
                                         ,pr_des_reto    OUT VARCHAR               --> Retorno OK / NOK
                                         ,pr_tab_erro    OUT gene0001.typ_tab_erro) IS --> Tabela com possíves erros

    /* .............................................................................

       Programa: pr_efetiva_pagto_antec_parcela (antigo b1wgen0084a.p --> efetiva_pagamento_antecipado_parcela)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Josiane Stiehler
       14/06/2019                        Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : PJ437- Consignado -Rotina para validar pagamento parcela antecipada do consignado

       Alteracoes: 

    ............................................................................. */

    vr_exc_erro  EXCEPTION;

	  vr_prejuzcc BOOLEAN; -- Indicador de conta corrente em prejuízo
    vr_vlatupar NUMBER;
    vr_des_erro VARCHAR2(4000);
    vr_vldespar NUMBER;
    vr_cdhistor craphis.cdhistor%TYPE;
    vr_nrdolote craplot.nrdolote%TYPE;

    /* Erro em chamadas da pc_gera_erro */
    vr_des_reto VARCHAR2(3);
    vr_tab_erro GENE0001.typ_tab_erro;
    
  BEGIN

    pr_des_reto := 'NOK';

    IF pr_vlparrec > pr_vlpagpar THEN
       pr_des_reto := 'NOK';
       pr_tab_erro(pr_tab_erro.FIRST).dscritic := 'Não pode ser efetuado pagamento parcial de antecipação da parcela.' ;
    END IF;

    IF pr_floperac    THEN
       vr_nrdolote:= 600015;
    ELSE  /* Emprestimo */
      vr_nrdolote:= 600014;
    END IF;
    vr_cdhistor:= 108;

    --Validar pagamento antecipado da parcela
    empr0001.pc_valida_pagto_antec_parc(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                       ,pr_cdagenci => pr_cdagenci --> Código da agência
                                       ,pr_nrdcaixa => pr_nrdcaixa --> Número do caixa
                                       ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                       ,pr_nmdatela => pr_nmdatela --> Nome da tela
                                       ,pr_idorigem => pr_idorigem --> Id do módulo de sistema
                                       ,pr_nrdconta => pr_nrdconta --> Número da conta
                                       ,pr_idseqttl => pr_idseqttl --> Seq titula
                                       ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                       ,pr_flgerlog => pr_flgerlog --> Indicador S/N para geração de log
                                       ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                       ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                       ,pr_vlpagpar => pr_vlpagpar --> Valor da parcela emprestimo
                                       ,pr_vlatupar => vr_vlatupar--> Valor Atual Parcela
                                       ,pr_vldespar => vr_vldespar --> Valor Desconto Parcela
                                       ,pr_des_reto => vr_des_erro --> Retorno OK / NOK
                                       ,pr_tab_erro => pr_tab_erro); --> Tabela com possíves erros
    --Se Retornou erro
    IF vr_des_erro <> 'OK' THEN
      --Sair
      --RAISE vr_exc_saida;
      RAISE vr_exc_erro;
    END IF;

		vr_prejuzcc := PREJ0003.fn_verifica_preju_conta(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);

    IF NOT vr_prejuzcc THEN
    -- Lanca em C/C e atualiza o lote 
    empr0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                   ,pr_dtmvtolt => pr_dtmvtolt --> Movimento atual
                                   ,pr_cdagenci => pr_cdagenci --> Código da agência
                                   ,pr_cdbccxlt => 100         --> Número do caixa
                                   ,pr_cdoperad => pr_cdoperad --> Código do Operador
                                   ,pr_cdpactra => pr_cdpactra --> P.A. da transação
                                   ,pr_nrdolote => vr_nrdolote --> Numero do Lote
                                   ,pr_nrdconta => pr_nrdconta --> Número da conta
                                   ,pr_cdhistor => vr_cdhistor --> Codigo historico
                                   ,pr_vllanmto => pr_vlpagpar --> Valor da parcela emprestimo
                                   ,pr_nrparepr => pr_nrparepr --> Número parcelas empréstimo
                                   ,pr_nrctremp => pr_nrctremp --> Número do contrato de empréstimo
                                   ,pr_nrseqava => pr_nrseqava -- Pagamento: Sequencia do avalista
                                   ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                                   ,pr_tab_erro => vr_tab_erro); --> Tabela com possíves erros
    --Se Retornou erro
    IF vr_des_reto <> 'OK' THEN
      --Sair
      RAISE vr_exc_erro;
    END IF;
		END IF;

    -- Retornar ok para as transações
    pr_des_reto := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_des_reto := vr_des_reto;
      pr_tab_erro := vr_tab_erro;
    WHEN OTHERS THEN
      pr_des_reto := 'NOK';
      pr_tab_erro(pr_tab_erro.FIRST).dscritic := 'Erro empr0020.pr_valida_pagto_antec_consig: '||SQLERRM;
  END pr_valida_pagto_antec_consig;
  
  PROCEDURE pc_verifica_parc_ant_consig(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                       ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                       ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Número do contrato de empréstimo
                                       ,pr_nrparepr IN INTEGER --> Número parcelas empréstimo
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Movimento atual
                                       ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                       ,pr_dscritic OUT VARCHAR2) IS --> Descricao Erro
  BEGIN
    /* .............................................................................

       Programa: pc_verifica_parc_ant_consig
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Josiane Stiehler - AMcom
       Data    : 25/06/2019                        Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : PJ437 - Consignado
                   Rotina para verificar se tem uma parcela do consignado anterior nao liquida e ja vencida

       Alteracoes: 

    ............................................................................. */

    DECLARE
      --Cursores Locais
      CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE
                       ,pr_nrdconta IN crappep.nrdconta%TYPE
                       ,pr_nrctremp IN crappep.nrctremp%TYPE
                       ,pr_nrparepr IN crappep.nrparepr%TYPE
                       ,pr_inliquid IN crappep.inliquid%TYPE
                       ,pr_dtvencto IN crappep.dtvencto%TYPE) IS
        SELECT crappep.cdcooper,
               crappep.nrdconta,
               crappep.nrctremp,
               crappep.nrparepr
          FROM crappep
         WHERE crappep.cdcooper = pr_cdcooper
           AND crappep.nrdconta = pr_nrdconta
           AND crappep.nrctremp = pr_nrctremp
           AND crappep.nrparepr < pr_nrparepr
           AND crappep.inliquid = pr_inliquid
           AND crappep.dtvencto < pr_dtvencto;
      rw_crappep cr_crappep%ROWTYPE;

      CURSOR cr_pagto (pr_cdcooper IN tbepr_consignado_pagamento.cdcooper%TYPE,
                       pr_nrdconta IN tbepr_consignado_pagamento.nrdconta%TYPE,
                       pr_nrctremp IN tbepr_consignado_pagamento.nrctremp%TYPE,
                       pr_nrparepr IN tbepr_consignado_pagamento.nrparepr%TYPE) IS    

      SELECT 1
        FROM(SELECT sum(vlpago) vlpago, sum(vltotal) vltotal
               FROM (SELECT 0                           vlpago,
                            NVL(SUM(NVL(vlparepr,0)),0) vltotal
                       FROM tbepr_consignado_pagamento 
                      WHERE cdcooper = pr_cdcooper
                        AND nrdconta = pr_nrdconta
                        AND nrctremp = pr_nrctremp
                        AND nrparepr = pr_nrparepr
                        AND instatus = 1
                        AND rownum   = 1
                    UNION 
                     SELECT NVL(SUM(NVL(vlpagpar,0)),0) vlpago,
                            0                           vltotal
                       FROM tbepr_consignado_pagamento 
                      WHERE cdcooper = pr_cdcooper
                        AND nrdconta = pr_nrdconta
                        AND nrctremp = pr_nrctremp
                        AND nrparepr = pr_nrparepr
                        AND instatus IN (1,2)))
       WHERE vltotal - vlpago > 0; -- valor pendente de pagamento
     
      rw_pagto cr_pagto%ROWTYPE;

      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;

    BEGIN
      --Inicializar variavel erro
      pr_des_reto := 'OK';
      pr_dscritic := NULL;

      /* Verifica se tem uma parcela anterior nao liquida e ja vencida */
      FOR rw_crappep IN cr_crappep(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctremp => pr_nrctremp
                                  ,pr_nrparepr => pr_nrparepr
                                  ,pr_inliquid => 0
                                  ,pr_dtvencto => pr_dtmvtolt)
      LOOP
         -- verifica se esta em processamento com valor parcial
         OPEN cr_pagto(pr_cdcooper => rw_crappep.cdcooper
                      ,pr_nrdconta => rw_crappep.nrdconta
                      ,pr_nrctremp => rw_crappep.nrctremp
                      ,pr_nrparepr => rw_crappep.nrparepr); 
         FETCH cr_pagto
          INTO rw_pagto;
         IF cr_pagto%FOUND THEN
            --Retornar Mensagem erro
            pr_dscritic := 'Efetuar primeiro o pagamento da parcela em atraso';
            --Retornar Erro
            pr_des_reto := 'NOK';
            EXIT;
         END IF;
         CLOSE cr_pagto;
      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        pr_dscritic := 'Erro não tratado na empr0020.pc_verifica_parc_ant_consig ' ||
                       sqlerrm;
    END;
  END pc_verifica_parc_ant_consig;
  
  PROCEDURE pc_verifica_parc_antec_consig(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
																				 ,pr_nrdconta IN crapepr.nrdconta%TYPE  --> Conta
																				 ,pr_nrctremp IN crapepr.nrctremp%TYPE  --> Contrato
																				 ,pr_nrparepr IN crappep.nrparepr%TYPE  --> Nr. da parcela
																				 ,pr_dtmvtolt IN crapepr.dtmvtolt%TYPE  --> Data de movimento
																				 ,pr_des_reto OUT VARCHAR2              --> Retorno OK/NOK
																				 ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
	BEGIN
	/* .............................................................................

		 Programa: pc_verifica_parc_antec_consig
		 Sistema : Conta-Corrente - Cooperativa de Credito
		 Sigla   : CRED
		 Autor   : Josiane Stiehler
		 Data    : 25/06/2019.                      Ultima atualizacao: 

		 Dados referentes ao programa:

		 Frequencia: Sempre que for chamado.
		 Objetivo  : PJ437 - Consignado
                 Validações da parcela do consignado:
                 -Verifica se tem uma parcela anterior nao liquida e ja vencida
                 -Verifica se as parcelas informadas estão em ordem
                 -Verifica se as parcelas informadas estão em ordem

		 Alteracoes:
	............................................................................. */
		DECLARE

      /* Tratamento de erro */
			vr_exc_saida EXCEPTION;

			/* Descrição e código da critica */
			vr_dscritic VARCHAR2(4000);

      -- Verifica se tem uma parcela anterior nao liquida e ja vencida
		  CURSOR cr_crappep_1 IS
			  SELECT pep.cdcooper,
               pep.nrdconta,
               pep.nrctremp,
               pep.nrparepr
				  FROM crappep pep
				 WHERE pep.cdcooper = pr_cdcooper
				   AND pep.nrdconta = pr_nrdconta
					 AND pep.nrctremp = pr_nrctremp
					 AND pep.nrparepr < pr_nrparepr
					 AND pep.inliquid = 0
					 AND pep.dtvencto < pr_dtmvtolt;
      rw_crappep_1 cr_crappep_1%ROWTYPE;

		  -- Verifica se as parcelas informadas estão em ordem
			CURSOR cr_crappep_2 IS
			  SELECT pep.cdcooper,
               pep.nrdconta,
               pep.nrctremp,
               pep.nrparepr
				  FROM crappep pep
				 WHERE pep.cdcooper = pr_cdcooper
				   AND pep.nrdconta = pr_nrdconta
					 AND pep.nrctremp = pr_nrctremp
					 AND pep.nrparepr > pr_nrparepr
					 AND pep.inliquid = 0;

			rw_crappep_2 cr_crappep_2%ROWTYPE;

		  -- Verifica se as parcelas informadas estão em ordem
			CURSOR cr_crappep_3 IS
			  SELECT pep.cdcooper,
               pep.nrdconta,
               pep.nrctremp,
               pep.nrparepr
				  FROM crappep pep
				 WHERE pep.cdcooper = pr_cdcooper
				   AND pep.nrdconta = pr_nrdconta
					 AND pep.nrctremp = pr_nrctremp
					 AND pep.nrparepr < pr_nrparepr
					 AND pep.inliquid = 0;
           
			rw_crappep_3 cr_crappep_3%ROWTYPE;

      CURSOR cr_pagto (pr_cdcooper IN tbepr_consignado_pagamento.cdcooper%TYPE,
                       pr_nrdconta IN tbepr_consignado_pagamento.nrdconta%TYPE,
                       pr_nrctremp IN tbepr_consignado_pagamento.nrctremp%TYPE,
                       pr_nrparepr IN tbepr_consignado_pagamento.nrparepr%TYPE) IS    

      SELECT 1
        FROM(SELECT sum(vlpago) vlpago, sum(vltotal) vltotal
               FROM (SELECT 0                           vlpago,
                            NVL(SUM(NVL(vlparepr,0)),0) vltotal
                       FROM tbepr_consignado_pagamento 
                      WHERE cdcooper = pr_cdcooper
                        AND nrdconta = pr_nrdconta
                        AND nrctremp = pr_nrctremp
                        AND nrparepr = pr_nrparepr
                        AND instatus = 1
                        AND rownum   = 1
                    UNION 
                     SELECT NVL(SUM(NVL(vlpagpar,0)),0) vlpago,
                            0                           vltotal
                       FROM tbepr_consignado_pagamento 
                      WHERE cdcooper = pr_cdcooper
                        AND nrdconta = pr_nrdconta
                        AND nrctremp = pr_nrctremp
                        AND nrparepr = pr_nrparepr
                        AND instatus IN (1,2)))
       WHERE vltotal - vlpago > 0; -- valor pendente de pagamento

       rw_pagto cr_pagto%ROWTYPE;
       
       vr_pagto2 VARCHAR2(1);
       vr_pagto3 VARCHAR2(1);
		BEGIN
      -- Verifica se tem uma parcela anterior nao liquida e ja vencida
      FOR rw_crappep_1 IN cr_crappep_1
      LOOP
         -- verifica se esta em processamento com valor parcial
         OPEN cr_pagto(pr_cdcooper => rw_crappep_1.cdcooper
                      ,pr_nrdconta => rw_crappep_1.nrdconta
                      ,pr_nrctremp => rw_crappep_1.nrctremp
                      ,pr_nrparepr => rw_crappep_1.nrparepr); 
         FETCH cr_pagto
          INTO rw_pagto;
         IF cr_pagto%FOUND THEN
      			vr_dscritic := 'Efetuar primeiro o pagamento da parcela em atraso';
			    	RAISE vr_exc_saida;
         END IF;
         CLOSE cr_pagto;
			END LOOP;

      vr_pagto2:='N';
      vr_pagto3:='N';
			-- Verifica se as parcelas informadas estão em ordem
      FOR rw_crappep_2 IN cr_crappep_2
      LOOP
        -- verifica se esta em processamento com valor parcial
         OPEN cr_pagto(pr_cdcooper => rw_crappep_2.cdcooper
                      ,pr_nrdconta => rw_crappep_2.nrdconta
                      ,pr_nrctremp => rw_crappep_2.nrctremp
                      ,pr_nrparepr => rw_crappep_2.nrparepr); 
         FETCH cr_pagto
          INTO rw_pagto;
         IF cr_pagto%FOUND THEN
            vr_pagto2:= 'S';
            CLOSE cr_pagto;
            exit;
         END IF;
         CLOSE cr_pagto;
      END LOOP;  
      
      FOR rw_crappep_3 IN cr_crappep_3
      LOOP
         -- verifica se esta em processamento com valor parcial
         OPEN cr_pagto(pr_cdcooper => rw_crappep_3.cdcooper
                      ,pr_nrdconta => rw_crappep_3.nrdconta
                      ,pr_nrctremp => rw_crappep_3.nrctremp
                      ,pr_nrparepr => rw_crappep_3.nrparepr); 
         FETCH cr_pagto
          INTO rw_pagto;
         IF cr_pagto%FOUND THEN
            vr_pagto3:= 'S';
            CLOSE cr_pagto;
            exit;
         END IF;
         CLOSE cr_pagto;
      END LOOP;
      
			IF vr_pagto2='S' AND
         vr_pagto3='S' THEN
    	   vr_dscritic := 'Efetuar o pagamento das parcelas na sequencia crescente ou decrescente';
		     RAISE vr_exc_saida;
      END IF;
			pr_des_reto := 'OK';

		EXCEPTION
      WHEN vr_exc_saida THEN

        IF cr_crappep_2%ISOPEN THEN CLOSE cr_crappep_2; END IF;
        IF cr_crappep_3%ISOPEN THEN CLOSE cr_crappep_3; END IF;

				pr_dscritic := vr_dscritic;
				pr_des_reto := 'NOK';
			WHEN OTHERS THEN

        IF cr_crappep_2%ISOPEN THEN CLOSE cr_crappep_2; END IF;
        IF cr_crappep_3%ISOPEN THEN CLOSE cr_crappep_3; END IF;

				pr_dscritic := 'Erro nao tratado na procedure empr0020.pc_verifica_parc_antec_consig -> ' || SQLERRM;
				pr_des_reto := 'NOK';

		END;
	END pc_verifica_parc_antec_consig;

  PROCEDURE pc_grava_evento_consig_web(pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                       -- OUT
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descric?o da critica
                                      ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                      ,pr_tpdescto OUT crapepr.tpdescto%type --> Tipo desconto emprestimo
                                      ,pr_des_erro OUT VARCHAR2) IS

  BEGIN
  /* .............................................................................
     Programa : pc_grava_evento_consig_web
     Sistema  : AIMARO
     Sigla    : 
     Autor    : Josiane Stiehler - AMcom
     Data     : 29/05/2019                      Última Alteração:
                          
    Objetivo : PJ437 - Consignado
               Grava o XML gerado do pagamento da percela de consignado no evento SOA
    
    Alterações:
                                
  ............................................................................... */
                            
  DECLARE
    -- ID Evento SOA
    vr_idevento   tbgen_evento_soa.idevento%type;    

    --Variaveis Erro
    vr_dscritic VARCHAR2(4000);

    --Variaveis Excecao
    vr_exc_saida EXCEPTION;
    
     -- Variaveis de entrada vindas no xml
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    vr_nrdconta  crapepr.nrdconta%TYPE;
    vr_nrctremp  crapepr.nrctremp%TYPE;
    vr_clob      CLOB;
    
    CURSOR cr_tab_pagto IS
      SELECT pagamento ,numeroContrato, codigoContaSemDigito
        FROM XMLTABLE('Root/dto'
              PASSING pr_retxml
              COLUMNS
                numeroContrato number PATH 'pagamento/convenioCredito/numeroContrato',
                codigoContaSemDigito number PATH 'pagamento/propostaContratoCredito/*/*/codigoContaSemDigito',
                pagamento xmltype path 'pagamento'
               ) xt
       WHERE rownum=1;
    
  BEGIN
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    FOR rw_tab_pagto IN cr_tab_pagto
    LOOP
      vr_nrdconta:= rw_tab_pagto.codigoContaSemDigito;
      vr_nrctremp:= rw_tab_pagto.numeroContrato;
      vr_clob    := rw_tab_pagto.pagamento.getclobval();  
      vr_clob := replace(replace(replace(replace(vr_clob,'</pagamento>',''),'<pagamento>',''),',',''),'.',',');
    END LOOP;

    vr_clob := '<?xml version="1.0" encoding="ISO-8859-1" ?> '||
               '<Root>'||vr_clob||'</Root>';

           
    -- gera evento soa para o pagamento de consignado
    soap0003.pc_gerar_evento_soa(pr_cdcooper               => vr_cdcooper
                                ,pr_nrdconta               => vr_nrdconta
                                ,pr_nrctrprp               => vr_nrctremp
                                ,pr_tpevento               => 'PAGTO_PAGAR'
                                ,pr_tproduto_evento        => 'CONSIGNADO'
                                ,pr_tpoperacao             => 'INSERT'
                                ,pr_dsconteudo_requisicao  => vr_clob
                                ,pr_idevento               => vr_idevento
                                ,pr_dscritic               => vr_dscritic);
    -- Tratar saida com erro                          
    IF vr_dscritic IS NOT NULL THEN
       RAISE vr_exc_saida;
    END IF;
    COMMIT;
   EXCEPTION
     WHEN vr_exc_saida THEN
      pr_dscritic:= vr_dscritic;
      pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> '||
                                       '<Root><Erro>'||pr_dscritic||'</Erro></Root>');
      ROLLBACK;
     WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na empr0020.pc_grava_evento_consig_web ' ||sqlerrm;
      pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> '||
                                       '<Root><Erro>'||pr_dscritic||'</Erro></Root>');
      ROLLBACK;
   END;
  END pc_grava_evento_consig_web;
  
  -- Montar o XML para registro do Gravames somente CDC 
  PROCEDURE pc_gera_xml_pagamento_consig(pr_cdcooper     IN crapepr.cdcooper%TYPE, -- código da cooperativa
                                         pr_nrdconta     IN crapepr.nrdconta%TYPE, -- Número da conta
                                         pr_nrctremp     IN crapepr.nrctremp%TYPE, -- Número do contrato de emprestimo
                                         pr_xml_parcelas IN VARCHAR2,             -- xml com as parcelas a serem pagas 
                                         pr_tpenvio      IN NUMBER,                -- Tipo de envio (1-INSTALLMENT_SETTLEMENT, 2-REVERSAL_SETTLEMENT,3-CONTRACT_SETTLEMENT, 4-DEFAULTING_INSTALLMENT_SETTLEMENT)
                                         pr_tptransa     IN VARCHAR2,              -- tipo transação (DEBITO, ESTORNO DEBITO)
                                         pr_dsxmlali    OUT XmlType,               -- XML de saida do pagamento
                                         pr_dscritic    OUT VARCHAR2) IS --> Descricao Erro

  BEGIN
  /* .............................................................................
   Programa : pc_gera_xml_pagamento
   Sistema  : AIMARO
   Sigla    : 
   Autor    : Josiane Stiehler - AMcom
   Data     : 09/05/2019                      Última Alteração:
                        
   Objetivo : PJ437 - Consignado
              Criação da rotina para gerar o XML do pagamento
   
   Alterações:
                              
  ............................................................................... */
                          
  DECLARE
    -------------- Variáveis e Tipos -------------------
    -- Variaveis locais para retorno de erro
                            
    -- Varchar2 temporário
    vr_dsxmltemp VARCHAR2(32767);

    -- Temporárias para o CLOB
    vr_clobxml CLOB;                   -- CLOB para armazenamento das informações do arquivo
    vr_clobaux VARCHAR2(32767);        -- Var auxiliar para montagem do arquivo
    -- Exceção
    vr_exc_saida exception;
      
    vr_dsinteracao VARCHAR2(200);
    
                          
  BEGIN
    --Inicializar variavel erro
    pr_dscritic := NULL;
      
    -- Inicializar as informações do XML de dados
    dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_clobxml,dbms_lob.lob_readwrite);
                        
    -- Escrever no arquivo XML
    gene0002.pc_escreve_xml(vr_clobxml
                           ,vr_clobaux
                           ,'<?xml version="1.0" encoding="UTF-8"?><Root>');

    IF pr_tpenvio = 1  THEN
       vr_dsinteracao:= 'INSTALLMENT_SETTLEMENT';
    ELSIF  pr_tpenvio = 2 THEN
       vr_dsinteracao:= 'REVERSAL_SETTLEMENT';
    ELSIF  pr_tpenvio = 3 THEN
       vr_dsinteracao:= 'CONTRACT_SETTLEMENT';
    ELSIF  pr_tpenvio = 4 THEN
       vr_dsinteracao:= 'DEFAULTING_INSTALLMENT_SETTLEMENT';
    END IF;    
           
    
    -- Monta XML do pagamento do consignado   
    vr_dsxmltemp:= '<convenioCredito>
                    <cooperativa>
                      <codigo>'||pr_cdcooper||'</codigo>
                    </cooperativa>
                    <numeroContrato>'||pr_nrctremp||'</numeroContrato>
                  </convenioCredito>
                  <propostaContratoCredito>
                    <emitente>
                      <contaCorrente>
                        <codigoContaSemDigito>'||pr_nrdconta||'</codigoContaSemDigito>
                      </contaCorrente>
                    </emitente>
                  </propostaContratoCredito>
                  <lote>
                    <tipoInteracao>
                      <codigo>'||vr_dsinteracao||'</codigo> 
                    </tipoInteracao>
                  </lote>
                  <transacaoContaCorrente>
                    <tipoInteracao>
                      <codigo>'||pr_tptransa||'</codigo>  
                    </tipoInteracao>
                  </transacaoContaCorrente>'||
                  pr_xml_parcelas||
                  '<interacaoGrafica>
                    <dataAcaoUsuario>'||to_char(sysdate,'yyyy-mm-dd')||'T'||to_char(sysdate,'hh24:mi:ss')||'</dataAcaoUsuario>
                  </interacaoGrafica>';

 
    -- Enviar o mesmo ao CLOB
    gene0002.pc_escreve_xml(vr_clobxml
                           ,vr_clobaux
                           ,vr_dsxmltemp); 
    
                      
    -- Finalizar o XML
    gene0002.pc_escreve_xml(vr_clobxml
                           ,vr_clobaux
                           ,'</Root>'
                           ,TRUE);     

dbms_output.put_line('xml :'||vr_clobxml);
                            
    -- E converter o CLOB para o XMLType de retorno
    pr_dsxmlali := XmlType.createXML(vr_clobxml);
                      
    --Fechar Clob e Liberar Memoria  
    dbms_lob.close(vr_clobxml);
    dbms_lob.freetemporary(vr_clobxml); 
          
    EXCEPTION
      WHEN OTHERS THEN
        -- Montar descrição de erro não tratado
        pr_dscritic := 'Erro não tratado na empr0020.pc_gera_xml_pagamento_consig ' ||
                       sqlerrm;
    END;
  END pc_gera_xml_pagamento_consig;
      
  -- Envia proposta para FIS Brasil, gravando evento SOA
  PROCEDURE pc_grava_evento_prop_consig(pr_cdcooper    IN crapepr.cdcooper%TYPE, -- código da cooperativa
                                        pr_nrdconta    IN crapepr.nrdconta%TYPE, -- Número da conta
                                        pr_nrctremp    IN crapepr.nrctremp%TYPE, -- Número do contrato de emprestimo
                                        pr_dscritic   OUT VARCHAR2) IS --> Descricao Erro

  BEGIN
  /* .............................................................................
     Programa : pc_grava_evento_prop_consig
     Sistema  : AIMARO
     Sigla    : 
     Autor    : Josiane Stiehler - AMcom
     Data     : 29/05/2019                      Última Alteração:
                          
     Objetivo : PJ437 - Consignado
                 Grava o XML gerado da efetivação da proposta no evento SOA

     Alterações:                                
  ............................................................................... */
                            
  DECLARE
    vr_dsxmlali XMLType;
    -- ID Evento SOA
    vr_idevento   tbgen_evento_soa.idevento%type;    

    --Variaveis Erro
    vr_dscritic VARCHAR2(4000);

    --Variaveis Excecao
    vr_exc_saida EXCEPTION;
      
  BEGIN
    -- Gera o XML do pagamento a ser gravado no evento SOA
    pc_gera_xml_efet_prop_consig(pr_cdcooper  => pr_cdcooper, -- código da cooperativa
                                 pr_nrdconta  => pr_nrdconta, -- Número da conta
                                 pr_nrctremp  => pr_nrctremp, -- Número do contrato de emprestimo
                                 pr_dsxmlali  => vr_dsxmlali, -- XML de saida do pagamento
                                 pr_dscritic  => vr_dscritic); 

     -- Tratar saida com erro                          
     IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
     END IF;                                  
           
      -- gera evento soa para o pagamento de consignado
      soap0003.pc_gerar_evento_soa(pr_cdcooper               => pr_cdcooper
                                  ,pr_nrdconta               => pr_nrdconta
                                  ,pr_nrctrprp               => pr_nrctremp
                                  ,pr_tpevento               => 'EFETIVA_PROPOSTA'
                                  ,pr_tproduto_evento        => 'CONSIGNADO'
                                  ,pr_tpoperacao             => 'INSERT'
                                  ,pr_dsconteudo_requisicao  => vr_dsxmlali.getClobVal()
                                  ,pr_idevento               => vr_idevento
                                  ,pr_dscritic               => vr_dscritic);
     -- Tratar saida com erro                          
     IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
     END IF;

   EXCEPTION
     WHEN vr_exc_saida THEN
      pr_dscritic:= vr_dscritic;
     WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na empr0020.pc_grava_evento_prop_consig ' ||sqlerrm;
   END;
  END pc_grava_evento_prop_consig;
   
     
  -- Montar o XML da efetivação da proposta a ser gravado no evento SOA
  PROCEDURE pc_gera_xml_efet_prop_consig(pr_cdcooper    IN crapepr.cdcooper%TYPE, -- código da cooperativa
                                         pr_nrdconta    IN crapepr.nrdconta%TYPE, -- Número da conta
                                         pr_nrctremp    IN crapepr.nrctremp%TYPE, -- Número do contrato de emprestimo
                                         pr_dsxmlali   OUT XmlType,               -- XML de saida do pagamento
                                         pr_dscritic   OUT VARCHAR2) IS --> Descricao Erro

  BEGIN
  /* .............................................................................
     Programa : pc_gera_xml_efet_prop_consig
     Sistema  : AIMARO
     Sigla    : 
     Autor    : Josiane Stiehler - AMcom
     Data     : 29/05/2019                      Última Alteração:
                          
     Objetivo : PJ437 - Consignado
                 Gera o XML da efetivação da proposta gravando no evento SOA a ser enviada a FIS Brasil
     Alterações:                               
  ............................................................................... */
                            
  DECLARE
    CURSOR cr_crapepr IS
      SELECT decode(epr.idfiniof,1,'true','false') idfiniof,
             epr.cdcooper,
             epr.nrdconta,
             epr.nrctremp,
             epr.qtpreemp,
             epr.txmensal,
             epr.vlemprst,
             epr.vlpreemp,
             epr.vltarifa,
             emp.nrcepend,
             emp.nrendemp,
             emp.cdufdemp,
             emp.cdempres,
             emp.nrdocnpj,
             gene0007.fn_caract_acento (pr_texto    => emp.nmextemp,
                                        pr_insubsti => 1) nmextemp,
             gene0007.fn_caract_acento (pr_texto    => emp.nmcidade,
                                        pr_insubsti => 1) nmcidade,
             gene0007.fn_caract_acento (pr_texto    => emp.nmbairro,
                                        pr_insubsti => 1) nmbairro,
             gene0007.fn_caract_acento (pr_texto    => emp.dsendemp,
                                        pr_insubsti => 1) dsendemp,
             decode(con.tpmodconvenio,1,161, 
                decode(con.tpmodconvenio,2,162, 
                       decode(con.tpmodconvenio,3,163,null))) tpmodconvenio 
        FROM crapepr epr,
             crapemp emp,
             tbcadast_empresa_consig con
       WHERE emp.cdcooper = epr.cdcooper
         AND emp.cdempres = epr.cdempres
         AND emp.cdcooper = con.cdcooper
         AND emp.cdempres = con.cdempres
         AND epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;
    rw_crapepr cr_crapepr%ROWTYPE;
         
    CURSOR cr_tbepr_consig IS
      SELECT con.pecet_anual,
             con.pejuro_anual
        FROM tbepr_consignado con
       WHERE con.cdcooper = pr_cdcooper
         AND con.nrdconta = pr_nrdconta
         AND con.nrctremp = pr_nrctremp;
    rw_tbepr_consig cr_tbepr_consig%ROWTYPE;
            
    CURSOR cr_crawepr IS
      SELECT to_char(epr.dtdpagto,'yyyy/mm/dd') dtdpagto,
             epr.dtdpagto dtdpagto1,
             epr.vliofepr,
             epr.vlemprst
        FROM crawepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;
    rw_crawepr cr_crawepr%ROWTYPE;

    CURSOR cr_crapass (pr_nrdconta IN crapttl.nrdconta%type) IS
      SELECT to_char(ttl.dtnasttl,'yyyy/mm/dd')||'T'||'00:00:00' dtnasttl,
             ttl.nrcpfcgc,
             gene0007.fn_caract_acento (pr_texto    => pas.nmprimtl,
                                        pr_insubsti => 1) nmprimtl,
             ttl.cdnacion,
             ttl.nrdocttl,
             ttl.cdsexotl,
             ttl.nrcadast,
             ttl.cdnatopc,
             ttl.dsnatura,
             enc.dsendere,
             enc.nrendere,
             enc.nmbairro,
             enc.nmcidade,
             enc.cdufende,
             enc.nrcepend,
             enc.tpendass,
             pas.inpessoa
        FROM crapass pas,
             crapttl ttl,
             crapenc enc
       WHERE pas.cdcooper = ttl.cdcooper
         AND pas.nrdconta = ttl.nrdconta
         AND ttl.cdcooper = enc.cdcooper
         AND ttl.nrdconta = enc.nrdconta
         AND ttl.idseqttl = 1
         AND enc.tpendass = 10 -- residencial
         AND pas.cdcooper = pr_cdcooper
         AND pas.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;  
      
   CURSOR cr_crapcop IS
    SELECT cop.cdbcoctl,
           cop.cdagectl
      FROM crapcop cop 
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
 
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;                        
 
   -------------- Variáveis e Tipos -------------------
    vr_dscritic     VARCHAR2(2000);    --> Descrição da crítica
    -- Varchar2 temporário
    vr_dsxmltemp VARCHAR2(32767);
    -- Temporárias para o CLOB
    vr_clobxml CLOB;                   -- CLOB para armazenamento das informações do arquivo
    vr_clobaux VARCHAR2(32767);        -- Var auxiliar para montagem do arquivo
    -- Exception
    vr_exc_saida exception;
    vr_qtcarencia   number;
            
  BEGIN
      --Inicializar variavel erro
      pr_dscritic := NULL;
  
      -- busca data movimento da cooperativa        
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat 
       INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;
        
      --Busca  dados do contrato
      OPEN cr_crapepr;
      FETCH cr_crapepr 
       INTO rw_crapepr;
        
      IF cr_crapepr%NOTFOUND THEN
         vr_dscritic:= 'Contrato não encontrado';
         CLOSE cr_crapepr;
         RAISE vr_exc_saida;
      END IF; 
      CLOSE cr_crapepr;
        
      --Busca  dados do contrato
      OPEN cr_crawepr;
      FETCH cr_crawepr 
       INTO rw_crawepr;
        
      IF cr_crawepr%NOTFOUND THEN
         vr_dscritic:= 'Proposta não encontrado';
         CLOSE cr_crawepr;
         RAISE vr_exc_saida;
      END IF; 
      CLOSE cr_crawepr;
        
      -- dados do contrato
      OPEN cr_tbepr_consig;
      FETCH cr_tbepr_consig 
       INTO rw_tbepr_consig;
         
      IF cr_tbepr_consig%NOTFOUND THEN
         vr_dscritic:= 'CET não encontrado para o contrato: '||pr_nrctremp ;
         CLOSE cr_crapass;
         RAISE vr_exc_saida;
      END IF; 
      CLOSE cr_tbepr_consig;
        
      -- dados do cooperado
      OPEN cr_crapass (pr_nrdconta => rw_crapepr.nrdconta);
      FETCH cr_crapass 
       INTO rw_crapass;
       
      IF cr_crapass%NOTFOUND THEN
         vr_dscritic:= 'Dados do cooperado não encontrado: '||rw_crapepr.nrdconta ;
         CLOSE cr_crapass;
         RAISE vr_exc_saida;
      END IF;   
      CLOSE cr_crapass;  

      -- dados da cooperativa
      OPEN cr_crapcop;
      FETCH cr_crapcop 
        INTO rw_crapcop;
       
      IF cr_crapcop%NOTFOUND THEN
         vr_dscritic:= 'Cooperativa não encontrado: '||pr_cdcooper ;
         CLOSE cr_crapcop;
         RAISE vr_exc_saida;
      END IF;   
      CLOSE cr_crapcop;  

      -- dias de carência
      vr_qtcarencia:= trunc(rw_crawepr.dtdpagto1) - trunc(rw_crapdat.dtmvtolt);
        
      -- Inicializar as informações do XML de dados
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml,dbms_lob.lob_readwrite);
                        
      -- Escrever no arquivo XML
      gene0002.pc_escreve_xml(vr_clobxml
                             ,vr_clobaux
                             ,'<?xml version="1.0" encoding="UTF-8"?><Root>');
                          
      -- Monta XML do pagamento do consignado   
      vr_dsxmltemp:= '<convenioCredito>
                        <cooperativa>
                          <codigo>'||rw_crapepr.cdcooper||'</codigo>
                        </cooperativa>
                        <numeroContrato>'||rw_crapepr.cdempres||'</numeroContrato>
                      </convenioCredito>
                      <configuracaoCredito>
                        <diasCarencia>'||vr_qtcarencia||'</diasCarencia>
                        <financiaIOF>'||rw_crapepr.idfiniof||'</financiaIOF>
                        <financiaTarifa>'||rw_crapepr.idfiniof||'</financiaTarifa>
                      </configuracaoCredito>
                      <propostaContratoCredito>
                        <CETPercentAoAno>'||rw_tbepr_consig.pecet_anual||'</CETPercentAoAno>
                        <dataPrimeiraParcela>'||rw_crawepr.dtdpagto||'</dataPrimeiraParcela>
                        <produto> 
                          <codigo>'||rw_crapepr.tpmodconvenio||'</codigo>
                        </produto>
                        <quantidadeParcelas>'||rw_crapepr.qtpreemp||'</quantidadeParcelas>
                        <taxaJurosRemuneratorios>'||rw_crapepr.txmensal||'</taxaJurosRemuneratorios>
                        <taxaJurosRemuneratoriosAnual>'||rw_tbepr_consig.pejuro_anual||'</taxaJurosRemuneratoriosAnual>
                        <tipoLiberacao>
                           <codigo>6</codigo>'|| --6 - Liberação do Legado
                        '</tipoLiberacao>
                        <tipoLiquidacao>
                          <codigo>4</codigo>
                        </tipoLiquidacao> 
                        <tributoIOFValor>'||rw_crawepr.vliofepr||'</tributoIOFValor>
                        <valor>'||rw_crapepr.vlemprst||'</valor>
                        <valorBase>'||rw_crawepr.vlemprst||'</valorBase> 
                        <dataProposta>'||to_char(sysdate,'yyyy/mm/dd')||'T'||to_char(sysdate,'hh24:mi:ss')||'</dataProposta>
                        <emitente> 
                          <dataNascOuConstituicao>'||rw_crapass.dtnasttl||'</dataNascOuConstituicao>
                          <identificadorReceitaFederal>'||rw_crapass.nrcpfcgc||'</identificadorReceitaFederal>
                          <razaoSocialOuNome>'||rw_crapass.nmprimtl||'</razaoSocialOuNome>
                          <nacionalidade>
                            <codigo>'||rw_crapass.cdnacion||'</codigo>
                          </nacionalidade>
                          <tipo> 
                            <codigo>'||rw_crapass.inpessoa||'</codigo>
                          </tipo>
                          <contaCorrente>
                            <agencia>
                              <codigo>'||rw_crapcop.cdagectl||'</codigo>
                            </agencia>
                            <banco>
                              <codigo>'||rw_crapcop.cdbcoctl||'</codigo>
                            </banco>
                            <codigoConta>'||rw_crapepr.nrdconta||'</codigoConta>
                            <cooperativa>
                              <codigo>'||pr_cdcooper||'</codigo>
                            </cooperativa>
                          </contaCorrente>
                          <numeroTitularidade>'||'1'||'</numeroTitularidade>
                          <pessoaContatoEndereco>
                            <CEP>'||rw_crapass.nrcepend||'</CEP>
                            <cidade>
                              <descricao>'||rw_crapass.nmcidade||'</descricao>
                            </cidade>
                            <nomeBairro>'||rw_crapass.nmbairro||'</nomeBairro>
                            <numeroLogradouro>'||rw_crapass.nrendere||'</numeroLogradouro>
                            <tipoEndereco>
                              <codigo>'||rw_crapass.tpendass||'</codigo>
                            </tipoEndereco>
                            <tipoENomeLogradouro>'||rw_crapass.dsendere||'</tipoENomeLogradouro>
                            <UF>'||rw_crapass.cdufende||'</UF>
                          </pessoaContatoEndereco>
                        </emitente>
                        <identificadorProposta>'||rw_crapepr.nrctremp||'</identificadorProposta>
                        <statusProposta>
                          <codigo>'||'26'||'</codigo>
                        </statusProposta>
                      </propostaContratoCredito>
                      <pessoaDocumento>
                        <identificador>'||rw_crapass.nrdocttl||'</identificador>
                        <tipo>
                          <sigla>'||'CI'||'</sigla>
                        </tipo>
                      </pessoaDocumento>
                      <pessoaFisicaOcupacao>
                        <naturezaOcupacao>
                          <codigo>'||rw_crapass.cdnatopc||'</codigo>
                        </naturezaOcupacao>
                      </pessoaFisicaOcupacao>
                      <pessoaFisicaDetalhamento>
                        <estadoCivil>
                          <codigo>4</codigo> '|| -- Fixo 4 -Solteiro
                       ' </estadoCivil>
                        <sexo>
                          <codigo>'||rw_crapass.cdsexotl||'</codigo>
                        </sexo> 
                      </pessoaFisicaDetalhamento>
                      <pessoaFisicaRendimento>
                        <identificadorRegistroFuncionario>'||rw_crapass.nrcadast||'</identificadorRegistroFuncionario>
                      </pessoaFisicaRendimento>
                      <remuneracaoColaborador>
                        <empregador>
                          <identificadorReceitaFederal>'||rw_crapepr.nrdocnpj||'</identificadorReceitaFederal>
                          <razaoSocialOuNome>'||rw_crapepr.nmextemp||'</razaoSocialOuNome>
                        </empregador>
                      </remuneracaoColaborador>
                      <beneficio />
                      <listaPessoasEndereco>
                        <pessoaEndereco>
                          <parametroConsignado>
                            <tipoPessoaEndereco>'||'EMPREGADOR'||'</tipoPessoaEndereco>
                          </parametroConsignado>
                          <pessoaContatoEndereco>
                            <CEP>'||rw_crapepr.nrcepend||'</CEP>
                            <cidade>
                              <descricao>'||rw_crapepr.nmcidade||'</descricao>
                            </cidade>
                            <nomeBairro>'||rw_crapepr.nmbairro ||'</nomeBairro>
                            <numeroLogradouro>'||rw_crapepr.nrendemp||'</numeroLogradouro>
                            <tipoENomeLogradouro>'||rw_crapepr.dsendemp||'</tipoENomeLogradouro>
                            <UF>'||rw_crapepr.cdufdemp||'</UF>
                          </pessoaContatoEndereco>
                        </pessoaEndereco>
                      </listaPessoasEndereco>
                      <parcela>
                        <valor>'||rw_crapepr.vlpreemp||'</valor>
                      </parcela>
                      <tarifa>
                        <valor>'||rw_crapepr.vltarifa||'</valor>
                      </tarifa>
                      <inadimplencia>
                        <despesasCartorarias>0.0</despesasCartorarias>
                      </inadimplencia>
                      <usuarioDominioCecred>
                        <codigo>'||''||'</codigo>
                      </usuarioDominioCecred>
                      <parametroConsignado> 
                        <codigoFisTabelaJuros>'||'1'||'</codigoFisTabelaJuros>
                        <indicadorContaPrincipal>'||'true'||'</indicadorContaPrincipal> 
                        <naturalidade>'||rw_crapass.dsnatura||'</naturalidade>
                         <dataCalculoLegado>'||to_char(rw_crapdat.dtmvtolt,'yyyy/mm/dd')||' </dataCalculoLegado>
                      </parametroConsignado> '; 
        
      -- Enviar o mesmo ao CLOB
      gene0002.pc_escreve_xml(vr_clobxml
                             ,vr_clobaux
                             ,vr_dsxmltemp);  
                    
                        
      -- Finalizar o XML
      gene0002.pc_escreve_xml(vr_clobxml
                             ,vr_clobaux
                             ,'</Root>'
                             ,TRUE);      
      -- E converter o CLOB para o XMLType de retorno
      pr_dsxmlali := XmlType.createXML(vr_clobxml);
                        
      --Fechar Clob e Liberar Memoria  
      dbms_lob.close(vr_clobxml);
      dbms_lob.freetemporary(vr_clobxml); 
            
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic:=  vr_dscritic;
      WHEN OTHERS THEN
        -- Montar descrição de erro não tratado
        pr_dscritic := 'Erro não tratado na empr0020.pc_gera_xml_pagamento_consig ' ||sqlerrm;
    END;
  END pc_gera_xml_efet_prop_consig;

      
  PROCEDURE  pc_envia_email_erro_int_consig(pr_cdcooper  IN crapepr.cdcooper%TYPE, --Cooperativa
                                            pr_nrdconta    IN crapepr.nrdconta%TYPE, --Conta
                                            pr_nrctremp    IN crapepr.nrctremp%TYPE, --Contrato
                                            pr_nrparepr    IN crappep.nrparepr%TYPE default null, --Parcela (Opcional)
                                            pr_idoperacao  IN NUMBER default null, --ID Operacao (Opcional)
                                            pr_tipoemail   IN VARCHAR2, --Tipo de Email 
                                            pr_msg         IN VARCHAR2, --Mensagem_erro_origem
                                            pr_dscritic    OUT VARCHAR2,
                                            pr_retxml      OUT xmltype
                                            )IS  
                                                                                                         

  BEGIN
    DECLARE       
      vr_email      VARCHAR2(4000) := null ;
      vr_desemail   VARCHAR(4000) := '';
          
      -- Variaveis de Erro
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(4000);
          
      -- Variaveis Excecao
      vr_exc_erro   EXCEPTION;  
          
      CURSOR cr_crapprm IS
        SELECT dsvlrprm 
          FROM crapprm 
         WHERE nmsistem = 'CRED' 
           AND cdcooper = 0 
           AND cdacesso = 'EMAIL_ERR_INT_CONSIG';

      rw_crapprm cr_crapprm%ROWTYPE; 

    BEGIN
       OPEN cr_crapprm;
      FETCH cr_crapprm 
       INTO rw_crapprm;
              
      IF cr_crapprm%NOTFOUND THEN
         vr_email := NULL;
         vr_dscritic:= 'Email não cadastrado na tabela cr_crapprm (EMAIL_ERR_INT_CONSIG)';
         CLOSE cr_crapprm;  
         RAISE vr_exc_erro;
      ELSE
        vr_email := rw_crapprm.dsvlrprm;
      END IF; 
      CLOSE cr_crapprm;  

      vr_desemail := 'Consignado<br>
                      Ocorreu um erro no procedimento <b><i>'||pr_tipoemail||'</i></b>, verifique com urgência.<br><br> 
                          
                      Segue abaixo dados do processo executado:<br>
                      <b>Cooperativa:</b> '||pr_cdcooper||' <br>
                      <b>Conta:</b> '||pr_nrdconta||' <br>
                      <b>Contrato:</b> '||pr_nrctremp||' <br>';
      if pr_nrparepr is not null then
          vr_desemail :=  vr_desemail || '<b>Parcela:</b> '||pr_nrparepr||' <br>';
      end if;
      vr_desemail :=  vr_desemail || '<b>Descrição do erro ocorrido:</b> '||pr_msg||' <br>';
          
      if pr_idoperacao is not null then
          vr_desemail :=  vr_desemail || '<b>Id Operação:</b> '||pr_idoperacao||' <br>';
      end if;
      vr_desemail :=  vr_desemail || '<b>Descrição do erro ocorrido:</b> '||pr_msg||' <br>';
          
      IF ((vr_email is not null ) and (pr_msg is not null)) THEN
        -- Envia email 
         gene0003.pc_solicita_email(pr_cdcooper         => 3
                                    ,pr_cdprogra        => 'EMPR0020'
                                    ,pr_des_destino     => vr_email
                                    ,pr_des_assunto     => 'Consignado - Ocorreu um erro no procedimento '|| pr_tipoemail ||', verifique com urgência. '
                                    ,pr_des_corpo       => vr_desemail
                                    ,pr_des_anexo       => NULL --> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                    ,pr_flg_remove_anex => 'N'  --> Remover os anexos passados
                                    ,pr_flg_remete_coop => 'N'  --> Se o envio sera do e-mail da Cooperativa
                                    ,pr_flg_enviar      => 'S'  --> Enviar o e-mail na hora
                                    ,pr_des_erro        => vr_dscritic);

         -- Se houver erros
         IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
         END IF;  
      END IF;
          
      pr_dscritic := 'OK'; 
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><dsmensag>OK</dsmensag></Root>');
      commit; 
   EXCEPTION
    WHEN vr_exc_erro THEN
       /*  se foi retornado apenas código */
       IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
           /* buscar a descriçao */
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       END IF;
       /* variavel de erro recebe erro ocorrido */
       pr_dscritic := 'NOK';
       -- Carregar XML padrao para variavel de retorno
       pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      /* montar descriçao de erro nao tratado */
      vr_dscritic := 'erro não tratado na empr0020.pc_envia_email_erro_pagam_fis ' ||SQLERRM;
      pr_dscritic := 'NOK';
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                    '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
    END;
  END pc_envia_email_erro_int_consig;
    
  PROCEDURE pc_alt_emp_cooperado_desligado(pr_cdcooper      IN crapepr.cdcooper%TYPE  --> Cooperativa
                                          ,pr_nrdconta      IN crapepr.nrdconta%TYPE  --> Conta
                                          ,pr_flgdesligado  IN VARCHAR2               --> Indica se o cliente foi desligado (1 = Sim / 2 = Nao)
                                          -- campos padrões
                                          ,pr_cdcritic      OUT PLS_INTEGER           --> Codigo da critica
                                          ,pr_dscritic      OUT VARCHAR2              --> Descricao da critica
                                          ,pr_des_erro      OUT VARCHAR2              --> Erros do processo
                                          )IS
  /*---------------------------------------------------------------------------------------------------------
    Programa  : pc_alt_emp_cooperado_desligado
    Sistema   : AIMARO
    Sigla     : 
    Autor     : Fernanda Kelli de Oliveira - AMcom Sistemas de Informação
    Data      : 14/05/2019

    Objetivo  : O sistema Aimaro receberá, via serviço da FIS Brasil, a informação quando cooperado 
                for desligado da Conveniada e esta rotina irá fazer a alteração da empresa para 
                9999 (Desligado Consignado) na conta e nos contratos do cooperado.
                  
                Controle de COMMIT/ROLLBACK será feito pela rotina principal (JOB)

    Alteração :

  ----------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
      
      -- Variáveis auxiliares
      v_cdempres  crapttl.cdempres%type;
      
      CURSOR cr_crapttl IS
       SELECT t.cdempres
        FROM crapttl t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta
         AND t.idseqttl = 1;
      rw_crapttl cr_crapttl%ROWTYPE;
      
    BEGIN
      
      IF pr_flgdesligado IS NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Parâmetro pr_flgdesligado deve ser preenchido. Conta: '||pr_nrdconta|| ' da cooperativa: '||pr_cdcooper;
        RAISE vr_exc_erro;          
      ELSIF pr_flgdesligado = 1 THEN
        --Buscar o Codigo da empresa onde o titular trabalha.       
        OPEN cr_crapttl;
        FETCH cr_crapttl 
        INTO rw_crapttl;
        
        IF cr_crapttl%NOTFOUND THEN
           v_cdempres := null; 
        ELSE
           v_cdempres:= rw_crapttl.cdempres;
        END IF; 
        CLOSE cr_crapttl;
       
        IF v_cdempres IS NOT NULL AND v_cdempres <> 9999 THEN
          --Atualizar a empresa no Cadastro de titulares da conta para 9999 - Desligado Consignado
          --Contas > Comercial > Empresa 
          BEGIN
            UPDATE crapttl t
               SET t.cdempres = 9999 -- Desligado Consignado
             WHERE t.cdcooper = pr_cdcooper
               AND t.nrdconta = pr_nrdconta
               AND t.idseqttl = 1; 
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar a empresa da conta: '||pr_nrdconta|| ' da cooperativa: '||pr_cdcooper|| ' para 9999-Desligado Consignado.';
              RAISE vr_exc_erro;  
          END;
          
          --Atualizar a empresa nos Contratos de Consignado do cooperado e desvincular da empresa.
          BEGIN
           UPDATE crapepr c
              SET c.cdempres = 9999
            WHERE c.cdcooper = pr_cdcooper
              AND c.nrdconta = pr_nrdconta              
              AND c.inliquid = 0           --Contrato não liquidado
              AND c.tpdescto = 2           --Desconto em Folha de Pgto
              AND c.tpemprst = 1           --Empréstimo Pré-Fixado  
              AND c.cdempres is not null 
              AND c.cdempres <> 9999;       --ainda esta vinculada a uma empresa
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar a empresa nos Contratos da conta: '||pr_nrdconta|| ' da cooperativa: '||pr_cdcooper|| ' para 9999-Desligado Consignado.';
              RAISE vr_exc_erro;  
          END;                    
        END IF;  
      END IF;
      
      pr_des_erro := 'OK';
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF  vr_cdcritic <> 0 THEN
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_des_erro := 'NOK';
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        --ROLLBACK;
      WHEN OTHERS THEN
        pr_des_erro := 'NOK';
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina tela_consig.pc_excluir_param_consig_web: '||SQLERRM;        
        --ROLLBACK;     
    END;
  END pc_alt_emp_cooperado_desligado;  
  
  PROCEDURE pc_busca_dados_soa_fis_calcula (-- campos padrões
                                            pr_xmllog             IN VARCHAR2              --> XML com informacoes de LOG
                                           ,pr_cdcritic          OUT PLS_INTEGER           --> Codigo da critica
                                           ,pr_dscritic          OUT VARCHAR2              --> Descricao da critica
                                           ,pr_retxml             IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                           ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                                           ,pr_des_erro          OUT VARCHAR2              --> Erros do processo
                                           ) IS

  /*---------------------------------------------------------------------------------------------------------
    Programa : pc_busca_dados_soa_fis
    Sistema  : AIMARO
    Sigla    : CONSIG
    Autor    : Jackson Barcellos - AMcom Sistemas de Informação
    Data     : 09/05/2019

    Objetivo : Recebe os dados da tela e busca informacoes gerando xml para comunicacao via SOA com a FIS para calcular emprestimo

    Alteração :

  ----------------------------------------------------------------------------------------------------------*/                                   
  BEGIN
    DECLARE

    /* Tratamento de erro */
    vr_exc_erro EXCEPTION;

    /* Descrição e código da critica */
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_des_erro VARCHAR2(10);
    
    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);
    
    --variaveis da tela
    vr_nrdconta number;
    vr_cdlcremp number;
    vr_vlemprst number;
    vr_fintaxas number;
    vr_data_primeira_parcela date;
    vr_quantidade_parcelas number;
    
    --variaveis local
    vr_vlrtarif number;
    vr_tab_erro gene0001.typ_tab_erro;
    vr_dias_carencia number;
    vr_cdempres tbcadast_empresa_consig.cdempres%TYPE; --> codigo da empresa
    vr_taxa_juros number;
    vr_produto number;
    vr_dtmovtov varchar2(40);
    vr_dt_movto date;
        
    -- variáveis para armazenar as informaçoes em xml
    vr_des_xml        clob;
    vr_texto_completo varchar2(32600);

   CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%TYPE,
                      pr_nrdconta IN crapttl.nrdconta%TYPE) IS
    SELECT ttl.cdempres
      INTO vr_cdempres             
      FROM crapttl ttl 
     WHERE ttl.cdcooper = pr_cdcooper
       AND ttl.nrdconta = pr_nrdconta
       AND ttl.idseqttl = 1;
   rw_crapttl cr_crapttl%ROWTYPE;
   
   CURSOR cr_craplcr (pr_cdcooper IN craplcr.cdcooper%TYPE,
                      pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
    SELECT lc.txmensal as taxaJurosRemuneratorios
           ,'16'||lc.tpmodcon as produto_codigo
      FROM craplcr lc
     WHERE lc.cdcooper = pr_cdcooper
       AND lc.cdlcremp = pr_cdlcremp;  
   rw_craplcr cr_craplcr%ROWTYPE;

   rw_crapdat btch0001.cr_crapdat%ROWTYPE;                        
   
    PROCEDURE pc_escreve_xml( pr_des_dados in varchar2
                            , pr_fecha_xml in boolean default false
                            ) is
    BEGIN
        gene0002.pc_escreve_xml( vr_des_xml
                               , vr_texto_completo
                               , pr_des_dados
                               , pr_fecha_xml );
    END;
    
    BEGIN

      pr_nmdcampo := NULL;
      pr_des_erro := 'OK';
      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);

      IF (nvl(vr_cdcritic,0) <> 0 OR
          vr_dscritic IS NOT NULL) THEN
          raise vr_exc_erro;
      END IF;
      
      -- Extraindo os dados do XML que vem da tela 
      BEGIN
        vr_cdlcremp  := TRIM(pr_retxml.extract('/Root/dto/cdlcremp/text()').getstringval());
        vr_vlemprst  := TO_NUMBER(REPLACE(REPLACE(TRIM(pr_retxml.extract('/Root/dto/vlemprst/text()').getstringval()),'.',''),',','.'));
        vr_nrdconta  := TRIM(pr_retxml.extract('/Root/dto/nrdconta/text()').getstringval());
        vr_fintaxas  := TRIM(pr_retxml.extract('/Root/dto/fintaxas/text()').getstringval());
        vr_quantidade_parcelas := TRIM(pr_retxml.extract('/Root/dto/quantidadeparcelas/text()').getstringval());
--        vr_data_primeira_parcela   := TO_CHAR(TO_DATE(dataprimeiraparcela,'dd/mm/yyyy'),'yyyy-mm-dd')||'T'||to_char(to_date(vr_datainicio,'dd/mm/yyyy hh24:mi:ss'),'hh24:mi:ss');
--        vr_data_primeira_parcela   := TO_CHAR(TO_DATE(dataprimeiraparcela,'dd/mm/yyyy'),'yyyy-mm-dd');
        vr_data_primeira_parcela   := TO_DATE(TRIM(pr_retxml.extract('/Root/dto/dataprimeiraparcela/text()').getstringval()),'DD/MM/RRRR');

      EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.put_line(SQLERRM);
          IF SQLCODE = '-30625' THEN
            vr_dscritic := 'Erro na leitura dos dados da tela1.';
            RAISE vr_exc_erro;   
          ELSE
            vr_dscritic := sqlerrm||' - Erro na leitura dos dados da tela2.';
            RAISE vr_exc_erro;
          END IF;           
      END;
      
      --Busca Tarifa
      empr0018.pc_consulta_tarifa_emprst(pr_cdcooper => vr_cdcooper
                                        ,pr_cdlcremp => vr_cdlcremp
                                        ,pr_vlemprst => vr_vlemprst
                                        ,pr_nrdconta => vr_nrdconta
                                        ,pr_nrctremp => 0 
                                        ,pr_dscatbem => '' 
                                        --
                                        ,pr_vlrtarif => vr_vlrtarif
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_des_erro => vr_dscritic
                                        ,pr_des_reto => vr_des_erro
                                        ,pr_tab_erro => vr_tab_erro);
                               
      IF vr_des_erro = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Busca codempresa
      OPEN cr_crapttl (pr_cdcooper => vr_cdcooper,
                       pr_nrdconta => vr_nrdconta);
      FETCH cr_crapttl 
      INTO rw_crapttl;
        
      IF cr_crapttl%NOTFOUND THEN
         vr_dscritic := 'Erro ao buscar empresa.';
         CLOSE cr_crapttl;
         RAISE vr_exc_erro;
      ELSE
         vr_cdempres:= rw_crapttl.cdempres;
      END IF; 
      CLOSE cr_crapttl;

      -- Busca juros
      OPEN cr_craplcr (pr_cdcooper => vr_cdcooper,
                       pr_cdlcremp => vr_cdlcremp);
      FETCH cr_craplcr 
      INTO rw_craplcr;
        
      IF cr_craplcr%NOTFOUND THEN
         vr_dscritic := 'Erro ao buscar juros.';
         CLOSE cr_craplcr;
         RAISE vr_exc_erro;
      ELSE
         vr_taxa_juros:= rw_craplcr.taxaJurosRemuneratorios;
         vr_produto   := rw_craplcr.produto_codigo;
      END IF; 
      CLOSE cr_craplcr;
      
      -- busca data movimento da cooperativa        
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat 
       INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;
      vr_dtmovtov:= TO_CHAR(TO_DATE(rw_crapdat.dtmvtolt,'DD/MM/RRRR'),'RRRR-MM-DD')||'T'||to_char(sysdate,'hh24:mi:ss'); 
      vr_dt_movto:= rw_crapdat.dtmvtolt;
      
      --Calcula dias carencia
      BEGIN
	        vr_dias_carencia := vr_data_primeira_parcela - vr_dt_movto;             
      EXCEPTION WHEN OTHERS THEN
            vr_dscritic := 'Erro ao calcular carencia.';
            RAISE vr_exc_erro;
      END;

      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;
      
      -- monta xml
      pc_escreve_xml('<?xml version="1.0"?>');
      pc_escreve_xml('<dto>'||
                      '<convenioCredito>'||
                        '<cooperativa>'||
                          '<codigo>'||vr_cdcooper||'</codigo>'|| --codcooperativa
                        '</cooperativa>'||
                        '<numeroContrato>'||vr_cdempres||'</numeroContrato>'|| --codempresa
                      '</convenioCredito>'||
                      '<configuracaoCredito>'||
                        '<diasCarencia>'||vr_dias_carencia||'</diasCarencia>'|| -- dt1parc - dtmov
                        '<financiaIOF>'||vr_fintaxas||'</financiaIOF>'|| -- param1 enviado via tela
                        '<financiaTarifa>'||vr_fintaxas||'</financiaTarifa>'||  -- param1 enviado via tela
                      '</configuracaoCredito>'||
                      '<credito>'||
                        '<dataPrimeiraParcela>'||TO_CHAR(TO_DATE(vr_data_primeira_parcela,'DD/MM/RRRR'),'RRRR-MM-DD')||'</dataPrimeiraParcela>'||  -- param2 enviado via tela
                        '<produto>'||
                          '<codigo>'||vr_produto||'</codigo>'|| -- 161 privado 162 publico 163 inss
                        '</produto>'||
                        '<quantidadeParcelas>'||vr_quantidade_parcelas||'</quantidadeParcelas>'||  -- param3 enviado via tela
                        '<taxaJurosRemuneratorios>'||trim(to_char(vr_taxa_juros,'99999990D00', 'NLS_NUMERIC_CHARACTERS = ''.,'''))||'</taxaJurosRemuneratorios>'|| --buscar lcredi
                        '<tipoJuros>'||
                          '<codigo>1</codigo>'|| --fixo
                        '</tipoJuros>'||
                        '<tipoLiberacao>'||
                          '<codigo>2</codigo>'|| --fixo
                        '</tipoLiberacao>'||
                        '<tipoLiquidacao>'||
                          '<codigo>4</codigo>'|| --fixo
                        '</tipoLiquidacao>'||
                        '<valorBase>'||trim(to_char(vr_vlemprst,'99999990D00', 'NLS_NUMERIC_CHARACTERS = ''.,'''))||'</valorBase>'||  -- param4 enviado via tela
                      '</credito>'||
                      '<tarifa>'||
                        '<valor>'||trim(to_char(vr_vlrtarif,'99999990D00', 'NLS_NUMERIC_CHARACTERS = ''.,'''))||'</valor>'|| --buscar lcredi
                      '</tarifa>'||
                      '<sistemaTransacao/>'|| --enviar tag em branco
                      '<interacaoGrafica>'||
                        '<dataAcaoUsuario>'||vr_dtmovtov||'</dataAcaoUsuario>'|| --dtmov
                      '</interacaoGrafica>'||
                      '<parametroConsignado>'||
                        '<codigoFisTabelaJuros>1</codigoFisTabelaJuros>'|| -- param5 enviado via tela (codigo lcredi) mudou para 1 fixo
                      '</parametroConsignado>'
                     );
                     
      pc_escreve_xml ('</dto>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    EXCEPTION
      WHEN vr_exc_erro THEN
         /*  se foi retornado apenas código */
         IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
             /* buscar a descriçao */
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         /* variavel de erro recebe erro ocorrido */
         pr_des_erro := 'NOK';
         pr_cdcritic := nvl(vr_cdcritic,0);
         pr_dscritic := vr_dscritic;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
           pr_des_erro := 'NOK';
          /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro não tratado na tela_atenda_simulacao.pc_busca_dados_soa_fis ' ||SQLERRM;
           -- Carregar XML padrao para variavel de retorno
           pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_busca_dados_soa_fis_calcula;
  
  PROCEDURE prc_log_erro_soa_fis_calcula(-- campos padrões
                                          pr_xmllog             IN VARCHAR2              --> XML com informacoes de LOG
                                         ,pr_cdcritic          OUT PLS_INTEGER           --> Codigo da critica
                                         ,pr_dscritic          OUT VARCHAR2              --> Descricao da critica
                                         ,pr_retxml             IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                                         ,pr_des_erro          OUT VARCHAR2              --> Erros do processo
                                         )is

  BEGIN
    DECLARE 
     /* Tratamento de erro */
      vr_exc_erro EXCEPTION;

      /* Descrição e código da critica */
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
    
      --variaveis log
      vr_nrdrowidl rowid;
      vr_dscriticl varchar(1000);
      vr_dstransal varchar(250);
      vr_nrdcontal number;
      vr_json_req varchar2(4000);
      vr_json_res varchar2(4000);
        
      -- variaveis de entrada vindas no xml
      vr_cdcooper number;
      vr_cdoperad varchar2(100);
      vr_nmdatela varchar2(100);
      vr_nmeacao  varchar2(100);
      vr_cdagenci varchar2(100);
      vr_nrdcaixa varchar2(100);
      vr_idorigem varchar2(100);
  
  BEGIN
    pr_nmdcampo := NULL;
    pr_des_erro := 'OK';
    gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                            , pr_cdcooper => vr_cdcooper
                            , pr_nmdatela => vr_nmdatela
                            , pr_nmeacao  => vr_nmeacao
                            , pr_cdagenci => vr_cdagenci
                            , pr_nrdcaixa => vr_nrdcaixa
                            , pr_idorigem => vr_idorigem
                            , pr_cdoperad => vr_cdoperad
                            , pr_dscritic => vr_dscritic);

    IF (nvl(vr_cdcritic,0) <> 0 OR
        vr_dscritic IS NOT NULL) THEN
        raise vr_exc_erro;
    END IF;
      
    vr_nrdcontal  := TRIM(pr_retxml.extract('/Root/dto/nrdconta/text()').getstringval());
    vr_dstransal  := TRIM(pr_retxml.extract('/Root/dto/dstransal/text()').getstringval());
    vr_dscriticl  := TRIM(pr_retxml.extract('/Root/dto/dscriticl/text()').getstringval());
    vr_json_req  := TRIM(pr_retxml.extract('/Root/dto/json_req/text()').getstringval());
    vr_json_res  := TRIM(pr_retxml.extract('/Root/dto/json_res/text()').getstringval());            
    vr_json_req := regexp_replace(vr_json_req, '&'||'quot;', '"');
    vr_json_res := regexp_replace(vr_json_res, '&'||'quot;', '"');
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => vr_dscriticl
                          ,pr_dsorigem => vr_idorigem
                          ,pr_dstransa => vr_dstransal
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => vr_nrdcontal
                          ,pr_nrdrowid => vr_nrdrowidl);
      
    -- Gravar Item do LOG
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowidl
                             ,pr_nmdcampo => 'JSON'
                             ,pr_dsdadant => vr_json_req
                             ,pr_dsdadatu => vr_json_res);
      
    commit;
    pr_cdcritic := 0;
    pr_dscritic := null;    
    -- Existe para satisfazer exigência da interface. 
    pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><dsmensag>OK</dsmensag></Root>');                       
  EXCEPTION
     WHEN vr_exc_erro THEN
        /*  se foi retornado apenas código */
        IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
            /* buscar a descriçao */
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        /* variavel de erro recebe erro ocorrido */
        pr_des_erro := 'NOK';
        pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
         pr_des_erro := 'NOK';
        /* montar descriçao de erro nao tratado */
         pr_dscritic := 'erro não tratado na tela_atenda_simulacao.pc_busca_dados_soa_fis ' ||SQLERRM;
         -- Carregar XML padrao para variavel de retorno
         pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      END;
  END prc_log_erro_soa_fis_calcula;                                       
    
  PROCEDURE pc_atualiza_tbepr_consignado(pr_nrdconta         IN tbepr_consignado.nrdconta%TYPE     --> Conta
                                        ,pr_nrctremp         IN tbepr_consignado.nrctremp%TYPE     --> Contrato
                                        ,pr_pejuro_anual     IN tbepr_consignado.pejuro_anual%TYPE --> Percentual da taxa de juros anual
                                        ,pr_pecet_anual      IN tbepr_consignado.pecet_anual%TYPE  --> Percentual CET
                                         -- campos padrões
                                        ,pr_xmllog             IN VARCHAR2              --> XML com informacoes de LOG
                                        ,pr_cdcritic          OUT PLS_INTEGER           --> Codigo da critica
                                        ,pr_dscritic          OUT VARCHAR2              --> Descricao da critica
                                        ,pr_retxml             IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo          OUT VARCHAR2              --> Nome do campo com erro
                                        ,pr_des_erro          OUT VARCHAR2              --> Erros do processo
                                        ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_atualiza_tbepr_consignado
      Sistema  : AIMARO
      Sigla    : 
      Autor    : Fernanda Kelli - AMcom Sistemas de Informação
      Data     : 16/05/2019

      Objetivo : Inserir/Atualizar as informações passadas como parâmetro na 
                 Tabela 

      Alteração :     
     
    ----------------------------------------------------------------------------------------------------------*/
    BEGIN
    DECLARE
      /* Tratamento de erro */
      vr_exc_erro EXCEPTION;

      /* Descrição e código da critica */
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      -- variaveis de entrada vindas no xml
      vr_cdcooper integer;
      vr_cdoperad varchar2(100);
      vr_nmdatela varchar2(100);
      vr_nmeacao  varchar2(100);
      vr_cdagenci varchar2(100);
      vr_nrdcaixa varchar2(100);
      vr_idorigem varchar2(100);

      -- variáveis para armazenar as informaçoes em xml
      vr_des_xml        clob;
      vr_texto_completo varchar2(32600);
      
      vr_existe number:= 0;
      
      CURSOR cr_consig IS
        SELECT 1 vr_existe
          FROM tbepr_consignado t
         WHERE t.cdcooper = vr_cdcooper
           AND t.nrdconta = pr_nrdconta
           AND t.nrctremp = pr_nrctremp;
      rw_consig cr_consig%ROWTYPE;
      
      procedure pc_escreve_xml( pr_des_dados in varchar2
                              , pr_fecha_xml in boolean default false
                              ) is
      begin
          gene0002.pc_escreve_xml( vr_des_xml
                                 , vr_texto_completo
                                 , pr_des_dados
                                 , pr_fecha_xml );
      end;

    BEGIN
      pr_nmdcampo := NULL;
      pr_des_erro := 'OK';
      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);
                              
      --Verificar se o registro já foi criado
      OPEN cr_consig;
      FETCH cr_consig 
      INTO rw_consig;
        
      IF cr_consig%NOTFOUND THEN
        vr_existe := 0;
      ELSE
         vr_existe := rw_consig.vr_existe;
      END IF; 
      CLOSE cr_consig;

      --Inserir 
      IF vr_existe = 0 THEN
         BEGIN
           INSERT INTO cecred.tbepr_consignado
             (cdcooper,
              nrdconta,
              nrctremp,
              vljura60,
              pejuro_anual,
              pecet_anual)
           values
             (vr_cdcooper,
              pr_nrdconta,
              pr_nrctremp,
              null,
              pr_pejuro_anual,
              pr_pecet_anual);
         EXCEPTION
           WHEN OTHERS THEN
             vr_dscritic := 'Erro no insert na tabela tbepr_consignado. '|| sqlerrm;
             RAISE vr_exc_erro;  
         END;
      ELSE
         BEGIN
           UPDATE tbepr_consignado t
              SET t.pejuro_anual = pr_pejuro_anual,
                  t.pecet_anual  = pr_pecet_anual
            WHERE t.cdcooper = vr_cdcooper
              AND t.nrdconta = pr_nrdconta
              AND t.nrctremp = pr_nrctremp;
         EXCEPTION
           WHEN OTHERS THEN
             vr_dscritic := 'Erro no update na tabela tbepr_consignado. '|| sqlerrm;
             RAISE vr_exc_erro;  
         END;                
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
           /*  se foi retornado apenas código */
           IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           END IF;
           /* variavel de erro recebe erro ocorrido */
           pr_des_erro := 'NOK';
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
             -- Carregar XML padrao para variavel de retorno
              pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
             pr_des_erro := 'NOK';
           /* montar descriçao de erro nao tratado */
             pr_dscritic := 'erro não tratado na empr0020.pc_atualiza_tbepr_consignado. ' ||SQLERRM;
             -- Carregar XML padrao para variavel de retorno
             pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_atualiza_tbepr_consignado;                                           

  PROCEDURE pc_concluir_efetivacao(pr_cdcooper    IN crapepr.cdcooper%TYPE  --> Código da Cooperativa
                                  ,pr_nrdconta    IN crapepr.nrdconta%TYPE  --> Número da conta do cooperado
                                  ,pr_nrctremp    IN crapepr.nrctremp%TYPE  --> Número do Contrato de Empréstimo
                                  ,pr_situacao    IN VARCHAR2               --> Situação do retorno da efetivação (0-Insucesso, 1-Sucesso)
                                  ,pr_msg_erro    IN VARCHAR2 default null  --> Mensagem de Erro ocorrida (Técnica ou Negócio)
                                  ,pr_dscritic    OUT VARCHAR2              --> Descrição da Crítica NULL/'Erro na execução'
                                  ,pr_retorno     OUT VARCHAR2              --> Retorno da Operação OK/NOK
                                  )IS
  /*---------------------------------------------------------------------------------------------------------
      Programa : pc_concluir_efetivacao
      Sistema  : AIMARO
      Sigla    : 
      Autor    : Fernanda Kelli de Oliveira - AMcom Sistemas de Informação
      Data     : 25/06/2019                                 ultima Atualizacao: 

      Objetivo : Receber o retorno da execução do evento SOA (Gravar Proposta – FIS BRASIL). 
                 Esta procedure será chamada em caso de erro ou sucesso na execução de evento do SOA.                  

      Alteração :

  ----------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
          
      /* Variaveis auxiliares */
      vr_rowid_log    rowid;      
      vr_dstransa     craplgm.dstransa%type := null;
      vr_dscritic     craplgm.dscritic%type := null;
     
    BEGIN
      
      --(0-Insucesso, 1-Sucesso)
      IF trim(pr_situacao) = '0' THEN
        vr_dstransa := 'Erro no grava dados de efetivação da proposta no SIV. Nr.: ' || pr_nrctremp || ' Erro: '|| pr_msg_erro ;
        vr_dscritic := pr_msg_erro;
      ELSE
        vr_dstransa := 'Sucesso no grava dados de efetivação da proposta no SIV. Nr.: ' || pr_nrctremp; 
        vr_dscritic := null;         
      END IF;  
            
      -- Efetua os inserts para apresentacao na tela VERLOG
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => '1'
                          ,pr_dscritic => vr_dscritic                          --> Mensagem de Erro ocorrida (Técnica ou Negócio)
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(1)       --> 1 = AIMARO
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => trunc(sysdate)
                          ,pr_flgtrans => pr_situacao                          --> Situação do retorno da efetivação (0-Insucesso, 1-Sucesso)
                          ,pr_hrtransa => gene0002.fn_busca_time 
                          ,pr_idseqttl => 0                                    --> Sequencial do Titular
                          ,pr_nmdatela => 'EMPRESTIMOS'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_rowid_log);  
       
      commit;     
      pr_retorno  := 'OK';  
      pr_dscritic := null;     
   
   EXCEPTION
     WHEN OTHERS THEN
       pr_retorno  := 'NOK';  
       pr_dscritic := 'Erro nao tratado na EMPR0020.pc_concluir_efetivacao: ' || SQLERRM;
       
   END;
  END pc_concluir_efetivacao;  
  
  PROCEDURE pc_pag_parcela_ret_web (pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                     -- OUT
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2              --> Descric?o da critica
                                    ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
    
  BEGIN
   /*---------------------------------------------------------------------------------------------------------
    Programa : pc_pag_parcela_ret_web
    Sistema  : AIMARO
    Sigla    : ATENDA->PRESTAÇÕES->COOPERATIVA
    Autor    : Jackson Barcellos - AMcom Sistemas de Informação
    Data     : 27/06/2019

    Objetivo : Retorno de pagamento consignado (Retorno FIS).
               Chamada pelo AIMARO

    Alteração :

   ----------------------------------------------------------------------------------------------------------*/    
    DECLARE
      -- Variaveis de Erro
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(4000);
      Vr_retxml     XMLTYPE;
      -- Variaveis Excecao
      vr_exc_erro   EXCEPTION;
      
      -- variaveis de entrada vindas no xml
      vr_cdcooper number;
      vr_cdoperad varchar2(100);
      vr_nmdatela varchar2(100);
      vr_nmeacao  varchar2(100);
      vr_cdagenci varchar2(100);
      vr_nrdcaixa varchar2(100);
      vr_idorigem varchar2(100);
      
      vr_nrdconta    number;
      vr_nrctremp    number;
      vr_numseqfluxo number;
      vr_saldopmt    number;
      vr_vlmora      number;
      vr_vliofatraso number;
      vr_vlmulta     number;
      vr_vldesconto  number;
      vr_inparcela   number;
      vr_vlsaldodev  number;
      
      CURSOR cr_tab_ret IS
             SELECT nrdconta
                    ,nrctremp
                    ,numseqfluxo
                    ,saldopmt
                    ,vlmora
                    ,vliofatraso
                    ,vlmulta
                    ,vldesconto
                    ,inparcela
                    ,vlsaldodev
               FROM XMLTABLE('Root/dto'
                    PASSING pr_retxml
                            COLUMNS
                             nrdconta    number PATH 'nrdconta', 
                             nrctremp    number PATH 'nrctremp',
                             numseqfluxo number PATH 'numseqfluxo',
                             saldopmt    number PATH 'saldopmt',
                             vlmora      number PATH 'vlmora',
                             vliofatraso number PATH 'vliofatraso',
                             vlmulta     number PATH 'vlmulta',
                             vldesconto  number PATH 'vldesconto',
                             inparcela   number PATH 'inparcela',
                             vlsaldodev  number PATH 'vlsaldodev'
                    ) xt
       WHERE rownum=1;
    
    BEGIN
    
      gene0004.pc_extrai_dados( pr_xml        => pr_retxml
                                , pr_cdcooper => vr_cdcooper
                                , pr_nmdatela => vr_nmdatela
                                , pr_nmeacao  => vr_nmeacao
                                , pr_cdagenci => vr_cdagenci
                                , pr_nrdcaixa => vr_nrdcaixa
                                , pr_idorigem => vr_idorigem
                                , pr_cdoperad => vr_cdoperad
                                , pr_dscritic => vr_dscritic);
                                
      FOR rw_tab_ret IN cr_tab_ret
        LOOP
          vr_nrdconta    := rw_tab_ret.nrdconta;          
          vr_nrctremp    := rw_tab_ret.nrctremp;
          vr_numseqfluxo := rw_tab_ret.numseqfluxo;
          vr_saldopmt    := rw_tab_ret.saldopmt;
          vr_vlmora      := rw_tab_ret.vlmora;
          vr_vliofatraso := rw_tab_ret.vliofatraso;
          vr_vlmulta     := rw_tab_ret.vlmulta;
          vr_vldesconto  := rw_tab_ret.vldesconto;
          vr_inparcela   := rw_tab_ret.inparcela;
          vr_vlsaldodev  := rw_tab_ret.vlsaldodev;
        END LOOP;                                
                   
      pc_pag_parcela_ret (pr_cdcooper    => vr_cdcooper,
                          pr_nrdconta    => vr_nrdconta,
                          pr_nrctremp    => vr_nrctremp,
                          pr_situacao    => 'OK',
                          pr_msg_erro    => '',
                          pr_numseqfluxo => vr_numseqfluxo, 
                          pr_idsequencia => 0,
                          pr_saldopmt    => vr_saldopmt,
                          pr_vlmora      => vr_vlmora,
                          pr_vlmulta     => vr_vlmulta,
                          pr_vliofatraso => vr_vliofatraso, 
                          pr_vldesconto  => vr_vldesconto, 
                          pr_inparcela   => vr_inparcela, 
                          pr_vlsaldodev  => vr_vlsaldodev,
                          pr_cdorigem    => 1,
                          pr_cdcritic    => vr_cdcritic,
                          pr_dscritic    => vr_dscritic,
                          pr_retxml      => vr_retxml); 
                          
      IF (vr_dscritic = 'NOK') THEN
         vr_dscritic := TRIM(vr_retxml.extract('/Root/erro/text()').getstringval());
         RAISE vr_exc_erro; 
      END IF;
           
    EXCEPTION
    WHEN vr_exc_erro THEN
       IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           pr_dscritic := vr_dscritic;
           pr_des_erro := 'NOK';           
           pr_retxml   := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                            '<Root><erro>' || vr_dscritic || '</erro></Root>');
       ELSE
         pr_dscritic := vr_dscritic;
         pr_des_erro := 'NOK';
         pr_retxml   := vr_retxml;
       END IF;
       
    WHEN OTHERS THEN
      vr_dscritic := 'Erro nao tratado na empr0020.pc_pag_parcela_ret_web ' ||SQLERRM;
      pr_dscritic := vr_dscritic;
      pr_des_erro := 'NOK';
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                    '<Root><erro>' || vr_dscritic || '</erro></Root>');
    END;
     
  END pc_pag_parcela_ret_web;
  
  PROCEDURE pc_pag_parcela_ret (pr_cdcooper    IN CRAPEPR.CDCOOPER%TYPE DEFAULT 0,
                                pr_nrdconta    IN CRAPEPR.NRDCONTA%TYPE DEFAULT 0,
                                pr_nrctremp    IN CRAPEPR.NRCTREMP%TYPE DEFAULT 0,
                                pr_nrparepr    IN CRAPPEP.NRPAREPR%TYPE DEFAULT 0,                                
                                pr_situacao    IN VARCHAR2, -- CODIGO RETORNO
                                pr_msg_erro    IN VARCHAR2 DEFAULT '',
                                pr_numseqfluxo IN NUMBER, -- ID FIS
                                pr_idsequencia IN TBEPR_CONSIGNADO_PAGAMENTO.IDSEQUENCIA%TYPE DEFAULT 0, -- ID AIMARO
                                pr_saldopmt    IN NUMBER,
                                pr_vlmora      IN NUMBER,
                                pr_vlmulta     IN NUMBER,
                                pr_vliofatraso IN NUMBER , 
                                pr_vldesconto  IN NUMBER, 
                                pr_inparcela   IN INT, --1 Aberto, 2 Liquidada
                                pr_vlsaldodev  IN NUMBER, 
                                pr_cdorigem    IN PLS_INTEGER DEFAULT 1, --AIMARO
                                pr_cdcritic    OUT PLS_INTEGER,                                
                                pr_dscritic    OUT VARCHAR2,
                                pr_retxml      OUT XMLTYPE) IS 
  BEGIN
   /*---------------------------------------------------------------------------------------------------------
    Programa : pc_pag_parcela_ret
    Sistema  : AIMARO
    Sigla    : ATENDA->PRESTAÇÕES->COOPERATIVA
    Autor    : Jackson Barcellos - AMcom Sistemas de Informação
    Data     : 27/06/2019

    Objetivo : Retorno de pagamento consignado (Retorno FIS).
               Chamada por Evento/AIMARO

    Alteração :

   ----------------------------------------------------------------------------------------------------------*/    
    DECLARE
    
      -- Variaveis auxiliar 
      rw_crapdat   btch0001.cr_crapdat%ROWTYPE;    
      vr_dtmvtolt  DATE;
      vr_nrdrowid  ROWID;
      -- Variaveis de Erro
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(4000);
      -- Variaveis Excecao
      vr_exc_erro   EXCEPTION;
      
      vr_dsorigem   VARCHAR2(21);
    
      CURSOR cr_tbepr_consignado_pagamento IS
          SELECT idsequencia
                 ,cdcooper
                 ,nrdconta
                 ,nrctremp
                 ,nrparepr
                 ,inorgpgt
                 ,vlparepr
                 ,vlpagpar
                 ,dtvencto
                 ,instatus
                 ,dtincreg
                 ,dtupdreg
                 ,cdagenci
                 ,cdbccxlt
                 ,cdoperad                
            FROM tbepr_consignado_pagamento 
           WHERE idsequencia = pr_numseqfluxo;

        rw_cr_tbepr_consig_pag cr_tbepr_consignado_pagamento%ROWTYPE; 
    
    BEGIN
      
       vr_dsorigem := gene0001.vr_vet_des_origens(pr_cdorigem);
      
       OPEN cr_tbepr_consignado_pagamento;
      FETCH cr_tbepr_consignado_pagamento 
       INTO rw_cr_tbepr_consig_pag;
                    
      IF cr_tbepr_consignado_pagamento%NOTFOUND THEN
         vr_dscritic:= 'Registro nao encontrado!';
         CLOSE cr_tbepr_consignado_pagamento;  
         RAISE vr_exc_erro;
         
      ELSE
        
         --Buscar a Data de movimento da Cooperativa
         OPEN btch0001.cr_crapdat(pr_cdcooper => rw_cr_tbepr_consig_pag.cdcooper);
        FETCH btch0001.cr_crapdat 
         INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;
        vr_dtmvtolt:= rw_crapdat.dtmvtolt;  
      
         IF (pr_situacao = 'ERRO') THEN
             -- Atualizar tabela de controle
             UPDATE tbepr_consignado_pagamento 
                SET dtupdreg = sysdate
                    ,instatus = 3
              WHERE idsequencia = pr_numseqfluxo;
             -- Gravar verlog
             GENE0001.pc_gera_log(pr_cdcooper  => rw_cr_tbepr_consig_pag.cdcooper
                                  ,pr_cdoperad => rw_cr_tbepr_consig_pag.cdoperad
                                  ,pr_dscritic => pr_msg_erro
                                  ,pr_dsorigem => vr_dsorigem
                                  ,pr_dstransa => 'Erro no pagamento da Parcela :'||rw_cr_tbepr_consig_pag.nrparepr||' do contrato: '||
                                                  rw_cr_tbepr_consig_pag.nrctremp||' - '||pr_msg_erro
                                  ,pr_dttransa => TRUNC(SYSDATE)
                                  ,pr_flgtrans => 0
                                  ,pr_hrtransa => gene0002.fn_busca_time
                                  ,pr_idseqttl => 1
                                  ,pr_nmdatela => ' '
                                  ,pr_nrdconta => rw_cr_tbepr_consig_pag.nrdconta
                                  ,pr_nrdrowid => vr_nrdrowid);
            
         ELSE
          
             pc_efetiva_pag_parcela(pr_rw_cr_tbepr_consig_pag => rw_cr_tbepr_consig_pag
                                   ,pr_numseqfluxo           => pr_numseqfluxo
                                   ,pr_saldopmt              => pr_saldopmt
                                   ,pr_vlmora                => pr_vlmora
                                   ,pr_vlmulta               => pr_vlmulta
                                   ,pr_vliofatraso           => pr_vliofatraso
                                   ,pr_vldesconto            => pr_vldesconto
                                   ,pr_inparcela             => pr_inparcela
                                   ,pr_vlsaldodev            => pr_vlsaldodev
                                   ,pr_rw_crapdat            => rw_crapdat                                           
                                   ,pr_cdcritic              => vr_cdcritic
                                   ,pr_dscritic              => vr_dscritic  
                                   );
             
             IF (nvl(vr_cdcritic,0) > 0 or vr_dscritic IS NOT NULL) THEN
                RAISE vr_exc_erro;
             END IF;           
           
            -- Atualizar tabela de controle
            UPDATE tbepr_consignado_pagamento 
               SET dtupdreg = sysdate
                   ,instatus = 2
             WHERE idsequencia = pr_numseqfluxo;
            -- Gravar verlog
             GENE0001.pc_gera_log(pr_cdcooper  => rw_cr_tbepr_consig_pag.cdcooper
                                  ,pr_cdoperad => rw_cr_tbepr_consig_pag.cdoperad
                                  ,pr_dscritic => ''
                                  ,pr_dsorigem => vr_dsorigem
                                  ,pr_dstransa => 'Parcela :'||rw_cr_tbepr_consig_pag.nrparepr||' do contrato: '||
                                                  rw_cr_tbepr_consig_pag.nrctremp||' paga com sucesso.'
                                  ,pr_dttransa => TRUNC(SYSDATE)
                                  ,pr_flgtrans => 1
                                  ,pr_hrtransa => gene0002.fn_busca_time
                                  ,pr_idseqttl => 1
                                  ,pr_nmdatela => ' '
                                  ,pr_nrdconta => rw_cr_tbepr_consig_pag.nrdconta
                                  ,pr_nrdrowid => vr_nrdrowid);
           
         END IF;
                 
         CLOSE cr_tbepr_consignado_pagamento;
         commit;
         pr_cdcritic := nvl(vr_cdcritic,0);
         pr_dscritic := 'OK'; 
         -- Existe para satisfazer exigência da interface. 
         pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><dsmensag>OK</dsmensag></Root>');         
      END IF;   
      
    EXCEPTION
    WHEN vr_exc_erro THEN
       IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       END IF;
       -- Gravar verlog
       GENE0001.pc_gera_log(pr_cdcooper  => pr_cdcooper
                            ,pr_cdoperad => 1
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => 'Erro no pagamento da Parcela :'||nvl(rw_cr_tbepr_consig_pag.nrparepr,0)||' do contrato: '||
                                            nvl(rw_cr_tbepr_consig_pag.nrctremp,0)||' - '||vr_dscritic
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => ' '
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
       commit;
       pr_cdcritic := nvl(vr_cdcritic,0);
       pr_dscritic := 'NOK';
       pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><erro>' || vr_dscritic || '</erro></Root>');
    WHEN OTHERS THEN
      vr_dscritic := 'Erro nao tratado na empr0020.pc_pag_parcela_ret ' ||SQLERRM;
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := 'NOK';
      -- Gravar verlog
       GENE0001.pc_gera_log(pr_cdcooper  => pr_cdcooper
                            ,pr_cdoperad => 1
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => 'Erro no pagamento da Parcela :'||nvl(rw_cr_tbepr_consig_pag.nrparepr,0)||' do contrato: '||
                                            nvl(rw_cr_tbepr_consig_pag.nrctremp,0)||' - '||vr_dscritic
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => ' '
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      commit;
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                    '<Root><erro>' || vr_dscritic || '</erro></Root>');
    END;
  END pc_pag_parcela_ret;    
  
  PROCEDURE pc_efetiva_pag_parcela(pr_rw_cr_tbepr_consig_pag IN tbepr_consignado_pagamento%ROWTYPE
                                   ,pr_numseqfluxo           IN TBEPR_CONSIGNADO_PAGAMENTO.IDSEQUENCIA%TYPE
                                   ,pr_saldopmt              IN NUMBER
                                   ,pr_vlmora                IN NUMBER
                                   ,pr_vlmulta               IN NUMBER
                                   ,pr_vliofatraso           IN NUMBER 
                                   ,pr_vldesconto            IN NUMBER 
                                   ,pr_inparcela             IN INT 
                                   ,pr_vlsaldodev            IN NUMBER 
                                   ,pr_rw_crapdat            IN btch0001.cr_crapdat%ROWTYPE                                          
                                   ,pr_cdcritic              OUT crapcri.cdcritic%TYPE   
                                   ,pr_dscritic              OUT VARCHAR2
                                   ) IS 
  BEGIN 
   /*---------------------------------------------------------------------------------------------------------
    Programa : pc_efetiva_pag_parcela
    Sistema  : AIMARO
    Sigla    : ATENDA->PRESTAÇÕES->COOPERATIVA
    Autor    : Jackson Barcellos - AMcom Sistemas de Informação
    Data     : 27/06/2019

    Objetivo : Retorno de pagamento consignado (Retorno FIS).

    Alteração :

   ----------------------------------------------------------------------------------------------------------*/     
    DECLARE 
      -- Variaveis de Erro
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(4000);
      vr_taberro    gene0001.typ_tab_erro;
      vr_retrating  VARCHAR2(10);
      
      -- Variaveis Excecao
      vr_exc_erro   EXCEPTION;  
            
      vrp_dtultpag DATE;
	    vrp_vldespar NUMBER;					   
      vrp_vlpagpar NUMBER;
      vrp_vlsdvpar NUMBER;
      vrp_inliquid NUMBER;
      vrp_vlsdvatu NUMBER;
      vrp_vljura60 NUMBER;
      vrp_vlsdvsji NUMBER;
      vrp_vlpagmta NUMBER;
      vrp_vlpagmra NUMBER;
      vrp_vlpagiof NUMBER;
      
      vrc_dtultpag DATE;
      vrc_qtprepag NUMBER;
      vrc_vlsdeved NUMBER;
      vrc_qtprecal NUMBER;
      vrc_inliquid NUMBER;
      vrc_dtliquid DATE;
      
      CURSOR cr_crappep (pr_cdcooper IN crappep.cdcooper%TYPE,
                         pr_nrdconta IN crappep.nrdconta%TYPE,
                         pr_nrctremp IN crappep.nrctremp%TYPE,
                         pr_nrparepr IN crappep.nrparepr%TYPE) IS
          SELECT cdcooper
                 ,nrdconta
                 ,nrctremp  
                 ,nrparepr
                 ,vlparepr
                 ,dtultpag
                 ,vlpagpar
                 ,vlsdvpar
						     ,vldespar
                 ,inliquid
                 ,vlsdvatu
                 ,vljura60
                 ,vlsdvsji    
                 ,dtvencto
                 ,vlpagmta
                 ,vlmtapar
                 ,vlpagmra
                 ,vlmrapar
                 ,vlpagiof
                 ,vliofcpl
            FROM crappep
           WHERE cdcooper = pr_cdcooper
                 AND nrdconta = pr_nrdconta
                 AND nrctremp = pr_nrctremp
                 AND nrparepr = pr_nrparepr;

      rw_cr_crappep cr_crappep%ROWTYPE;
        
      CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%TYPE,
                         pr_nrdconta IN crapepr.nrdconta%TYPE,
                         pr_nrctremp IN crapepr.nrctremp%TYPE) IS
          SELECT cdcooper
                 ,nrdconta
                 ,nrctremp
                 ,tpemprst
                 ,dtultpag
                 ,qtprepag
                 ,qtprecal
                 ,inliquid
                 ,dtliquid
            FROM crapepr
           WHERE cdcooper = pr_cdcooper
                 AND nrdconta = pr_nrdconta
                 AND nrctremp = pr_nrctremp;

      rw_cr_crapepr cr_crapepr%ROWTYPE;
                                         
    BEGIN
      -- Abre o cursor de parcelas
      OPEN cr_crappep(pr_cdcooper => pr_rw_cr_tbepr_consig_pag.cdcooper,
                      pr_nrdconta => pr_rw_cr_tbepr_consig_pag.nrdconta,
                      pr_nrctremp => pr_rw_cr_tbepr_consig_pag.nrctremp,
                      pr_nrparepr => pr_rw_cr_tbepr_consig_pag.nrparepr);
      FETCH cr_crappep 
       INTO rw_cr_crappep;
              
      IF cr_crappep%NOTFOUND THEN
         vr_dscritic:= 'Registro nao encontrado(crappep)!';
         CLOSE cr_crappep;  
         RAISE vr_exc_erro;         
      END IF;
      
       -- Abre o cursor de contrato
      OPEN cr_crapepr(pr_cdcooper => pr_rw_cr_tbepr_consig_pag.cdcooper,
                      pr_nrdconta => pr_rw_cr_tbepr_consig_pag.nrdconta,
                      pr_nrctremp => pr_rw_cr_tbepr_consig_pag.nrctremp);
      FETCH cr_crapepr 
       INTO rw_cr_crapepr;
              
      IF cr_crapepr%NOTFOUND THEN
         vr_dscritic:= 'Registro nao encontrado(crapepr)!';
         CLOSE cr_crapepr;  
         RAISE vr_exc_erro;         
      END IF;
      
      --Atualiza os dados
      vrp_dtultpag := pr_rw_crapdat.dtmvtolt;
      vrp_vlpagpar := nvl(rw_cr_crappep.vlpagpar,0) + (rw_cr_crappep.vlparepr - nvl(pr_saldopmt,0));
      vrp_vlsdvpar := pr_saldopmt;
      vrp_vldespar := nvl(rw_cr_crappep.vldespar,0) - pr_vldesconto; 
	    vrp_vlpagmta := nvl(rw_cr_crappep.vlpagmta,0) + (nvl(rw_cr_crappep.vlmtapar,0) - pr_vlmulta);
      vrp_vlpagmra := nvl(rw_cr_crappep.vlpagmra,0) + (nvl(rw_cr_crappep.vlmrapar,0) - pr_vlmora);
      vrp_vlpagiof := nvl(rw_cr_crappep.vlpagiof,0) + (nvl(rw_cr_crappep.vliofcpl,0) - pr_vliofatraso);
      IF (pr_inparcela = 2) THEN
         vrp_inliquid := 1;
         vrp_vlsdvatu := 0;
         vrp_vljura60 := 0;
         vrp_vlsdvsji := 0;
      ELSE
         vrp_vlsdvatu := rw_cr_crappep.vlsdvatu;
         vrp_vljura60 := rw_cr_crappep.vljura60;
         vrp_vlsdvsji := rw_cr_crappep.vlsdvsji;
      END IF;
      
      vrc_dtultpag := pr_rw_crapdat.dtmvtolt;
      vrc_vlsdeved := pr_vlsaldodev;
      IF (vrp_inliquid = 1) THEN 
         vrc_qtprepag := rw_cr_crapepr.qtprepag + 1;
         vrc_qtprecal := rw_cr_crapepr.qtprepag + 1;
      ELSE
         vrc_qtprepag := rw_cr_crapepr.qtprepag;
         vrc_qtprecal := rw_cr_crapepr.qtprepag;         
      END IF;
      IF (pr_vlsaldodev = 0) THEN
         vrc_inliquid := 1;
         vrc_dtliquid := pr_rw_crapdat.dtmvtolt;
      ELSE
         vrc_inliquid := rw_cr_crapepr.inliquid;
         vrc_dtliquid := rw_cr_crapepr.dtliquid;
      END IF;
      
      UPDATE crappep 
         SET dtultpag  = vrp_dtultpag
             ,vlpagpar = vrp_vlpagpar 
             ,vlsdvpar = vrp_vlsdvpar
             ,inliquid = vrp_inliquid
             ,vlsdvatu = vrp_vlsdvatu
             ,vljura60 = vrp_vljura60
             ,vlsdvsji = vrp_vlsdvsji
			       ,vldespar = vrp_vldespar
             ,vlpagmta = vrp_vlpagmta
             ,vlpagmra = vrp_vlpagmra				
	           ,vlpagiof = vrp_vlpagiof
             ,vlmtapar = pr_vlmulta
             ,vlmrapar = pr_vlmora
             ,vliofcpl = pr_vliofatraso           
       WHERE cdcooper = pr_rw_cr_tbepr_consig_pag.cdcooper
             AND nrdconta = pr_rw_cr_tbepr_consig_pag.nrdconta
             AND nrctremp = pr_rw_cr_tbepr_consig_pag.nrctremp
             AND nrparepr = pr_rw_cr_tbepr_consig_pag.nrparepr;

      UPDATE crapepr 
         SET dtultpag  = vrc_dtultpag
             ,qtprepag = vrc_qtprepag 
             ,vlsdeved = vrc_vlsdeved 
             ,qtprecal = vrc_qtprecal 
             ,inliquid = vrc_inliquid 
             ,dtliquid = vrc_dtliquid
       WHERE cdcooper = pr_rw_cr_tbepr_consig_pag.cdcooper
             AND nrdconta = pr_rw_cr_tbepr_consig_pag.nrdconta
             AND nrctremp = pr_rw_cr_tbepr_consig_pag.nrctremp;            
        
      
      -- desativa_rating
      rati0001.pc_desativa_rating(pr_cdcooper   => pr_rw_cr_tbepr_consig_pag.cdcooper     --> Código da Cooperativa
                                 ,pr_cdagenci   => pr_rw_cr_tbepr_consig_pag.cdagenci     --> Código da agência
                                 ,pr_nrdcaixa   => pr_rw_cr_tbepr_consig_pag.cdbccxlt     --> Número do caixa
                                 ,pr_cdoperad   => pr_rw_cr_tbepr_consig_pag.cdoperad     --> Código do operador
                                 ,pr_rw_crapdat => pr_rw_crapdat                          --> Vetor com dados de parâmetro (CRAPDAT)
                                 ,pr_nrdconta   => pr_rw_cr_tbepr_consig_pag.nrdconta     --> Conta do associado
                                 ,pr_tpctrrat   => 90                                     --> Tipo do Rating
                                 ,pr_nrctrrat   => pr_rw_cr_tbepr_consig_pag.nrctremp     --> Número do contrato de Rating
                                 ,pr_flgefeti   => 'YES'                                  --> Flag para efetivação ou não do Rating
                                 ,pr_idseqttl   => 1                                      --> Sequencia de titularidade da conta
                                 ,pr_idorigem   => 1                                      --> Indicador da origem da chamada
                                 ,pr_inusatab   => FALSE                                  --> Indicador de utilização da tabela de juros
                                 ,pr_nmdatela   => ' '                                    --> Nome datela conectada
                                 ,pr_flgerlog   => 'N'                                    --> Gerar log S/N
                                 ,pr_des_reto   => vr_retrating                           --> Retorno OK / NOK
                                 ,pr_tab_erro   => vr_taberro);                           --> Retorno tabela erros
        
    	CLOSE cr_crappep;
      CLOSE cr_crapepr;

      pr_cdcritic := 0;
      pr_dscritic := 'OK' ;
    EXCEPTION
    WHEN vr_exc_erro THEN
       IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       END IF;
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
       vr_dscritic := 'Erro nao tratado na empr0020.pc_efetiva_pag_parcela ' ||SQLERRM;
       pr_cdcritic := 0;
       pr_dscritic := vr_dscritic;
    END;
  END pc_efetiva_pag_parcela;                       
  
  PROCEDURE pc_estorn_pag_parc_ret_web(pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                       -- OUT
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descric?o da critica
                                      ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                      ,pr_tpdescto OUT crapepr.tpdescto%type --> Tipo desconto emprestimo
                                      ,pr_des_erro OUT VARCHAR2)IS           --> Erros do processo
  /*---------------------------------------------------------------------------------------------------------
      Programa : pc_estorn_pag_parc_ret_web
      Sistema  : AIMARO
      Sigla    : 
      Autor    : Fernanda Kelli de Oliveira - AMcom Sistemas de Informação
      Data     : 26/06/2019                                 ultima Atualizacao: 

      Objetivo : Retorno do estorno de pagamento consignado (Retorno FIS).                  
                 Chamada pelo AIMARO
 
      Alteração :

  ----------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
      -- Variaveis de Erro
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(4000);
      -- Variaveis Excecao
      vr_exc_erro   EXCEPTION;
      
      -- variaveis de entrada vindas no xml
      vr_cdcooper number;
      vr_cdoperad varchar2(100);
      vr_nmdatela varchar2(100);
      vr_nmeacao  varchar2(100);
      vr_cdagenci varchar2(100);
      vr_nrdcaixa varchar2(100);
      vr_idorigem varchar2(100);
    
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
      
      pr_cdcritic := 0;
      pr_dscritic := 'OK';
      
    EXCEPTION
      WHEN vr_exc_erro THEN
         IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         pr_dscritic := 'NOK';
         pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><erro>' || vr_dscritic || '</erro></Root>');
      WHEN OTHERS THEN
        vr_dscritic := 'Erro nao tratado na empr0020.pc_estorn_pag_parc_ret_web ' ||SQLERRM;
        pr_dscritic := 'NOK';

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><erro>' || vr_dscritic || '</erro></Root>');
    END;
  END pc_estorn_pag_parc_ret_web;                                     
                                    
  PROCEDURE pc_estorn_pag_parc_ret(pr_cdcooper    IN CRAPEPR.CDCOOPER%TYPE
                                  ,pr_nrdconta    IN CRAPEPR.NRDCONTA%TYPE
                                  ,pr_nrctremp    IN CRAPEPR.NRCTREMP%TYPE
                                  ,pr_situacao    IN VARCHAR2                -->Código do Retorno 
                                  ,pr_msg_erro    IN VARCHAR2 DEFAULT ''     -->Mensagem enviada quando for erro
                                  ,pr_numseqfluxo IN NUMBER                  -->Código interno que identifica o pagamento
                                  ,pr_idsequencia IN TBEPR_CONSIGNADO_PAGAMENTO.IDSEQUENCIA%TYPE DEFAULT 0
                                  ,pr_saldopmt    IN NUMBER                  -->Valor a receber da PMT após o Pagamento
                                  ,pr_vlmora      IN NUMBER                  -->Valor da Mora, caso existe saldo a pagar, somente quando esta em atraso
                                  ,pr_vlmulta     IN NUMBER                  -->Valor da Multa, caso existe saldo a pagar, somente quando esta em atraso 
                                  ,pr_vliofatraso IN NUMBER                  -->Valor do IOF, caso existe saldo a pagar, somente quando esta em atraso
                                  ,pr_vldesconto  IN NUMBER                  -->Valor do desconto, caso existe saldo a pagar, somente quando pagamento for de parcela a vencer
                                  ,pr_vlsaldodev  IN NUMBER                  -->Valor do Saldo devedor do contrato Atualizado D0 
                                  ,pr_cdorigem    IN PLS_INTEGER DEFAULT 1   --'AIMARO'
                                  ,pr_cdcritic    OUT PLS_INTEGER
                                  ,pr_dscritic    OUT VARCHAR2
                                  ,pr_retxml      OUT XMLTYPE) IS
  
  /*---------------------------------------------------------------------------------------------------------
      Programa : pc_estorn_pag_parc_ret
      Sistema  : AIMARO
      Sigla    : 
      Autor    : Fernanda Kelli de Oliveira - AMcom Sistemas de Informação
      Data     : 26/06/2019                                 ultima Atualizacao: 

      Objetivo : Retorno do estorno de pagamento consignado (Retorno FIS). 
                 Chamada por Evento/AIMARO                 

      Alteração :

  ----------------------------------------------------------------------------------------------------------*/
  BEGIN      
    DECLARE
    
      -- Variaveis auxiliar 
      rw_crapdat   btch0001.cr_crapdat%ROWTYPE;    
      vr_dtmvtolt  DATE;
      vr_nrdrowid  ROWID;
      vr_dsorigem   VARCHAR2(21);
      
      -- Variaveis de Erro
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(4000);
      -- Variaveis Excecao
      vr_exc_erro   EXCEPTION;
      
      CURSOR cr_tbepr_consignado_pagamento IS
        SELECT idsequencia
               ,cdcooper
               ,nrdconta
               ,nrctremp
               ,nrparepr
               ,inorgpgt
               ,vlparepr
               ,vlpagpar
               ,dtvencto
               ,instatus
               ,dtincreg
               ,dtupdreg
               ,cdagenci
               ,cdbccxlt
               ,cdoperad                
          FROM tbepr_consignado_pagamento 
         WHERE idsequencia = pr_idsequencia;

      rw_cr_tbepr_consig_pag cr_tbepr_consignado_pagamento%ROWTYPE; 
      
    BEGIN      

      --Buscar o evento na controle de pagamento
      OPEN cr_tbepr_consignado_pagamento;
      FETCH cr_tbepr_consignado_pagamento 
       INTO rw_cr_tbepr_consig_pag;
              
      IF cr_tbepr_consignado_pagamento%NOTFOUND THEN
         vr_dscritic:= 'Registro nao encontrado(tbepr_consignado_pagamento.idsequencia = '||pr_idsequencia ||')';
         CLOSE cr_tbepr_consignado_pagamento;  
         RAISE vr_exc_erro;         
      ELSE
        --Buscar a Data de movimento da Cooperativa
         OPEN btch0001.cr_crapdat(pr_cdcooper => rw_cr_tbepr_consig_pag.cdcooper);
        FETCH btch0001.cr_crapdat 
         INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;
        vr_dtmvtolt:= rw_crapdat.dtmvtolt;
      
        vr_dsorigem := gene0001.vr_vet_des_origens(pr_cdorigem);
        
        IF (pr_situacao = 'ERRO') THEN
             -- Atualizar tabela de controle
             UPDATE tbepr_consignado_pagamento 
                SET dtupdreg = sysdate
                    ,instatus = 3
              WHERE idsequencia = pr_idsequencia;
             -- Gravar verlog
             GENE0001.pc_gera_log(pr_cdcooper  => rw_cr_tbepr_consig_pag.cdcooper
                                  ,pr_cdoperad => rw_cr_tbepr_consig_pag.cdoperad
                                  ,pr_dscritic => pr_msg_erro
                                  ,pr_dsorigem => vr_dsorigem
                                  ,pr_dstransa => 'Erro no estorno do pagamento da parcela :'||rw_cr_tbepr_consig_pag.nrparepr||' do contrato: '||
                                                  rw_cr_tbepr_consig_pag.nrctremp||' - '||pr_msg_erro
                                  ,pr_dttransa => TRUNC(SYSDATE)
                                  ,pr_flgtrans => 0
                                  ,pr_hrtransa => gene0002.fn_busca_time
                                  ,pr_idseqttl => 1
                                  ,pr_nmdatela => ' '
                                  ,pr_nrdconta => rw_cr_tbepr_consig_pag.nrdconta
                                  ,pr_nrdrowid => vr_nrdrowid);
            
         ELSE
          
             pc_efetiva_estorn_pag_parc(pr_rw_cr_tbepr_consig_pag => rw_cr_tbepr_consig_pag
                                       ,pr_saldopmt               => pr_saldopmt
                                       ,pr_vlmora                 => pr_vlmora
                                       ,pr_vlmulta                => pr_vlmulta
                                       ,pr_vliofatraso            => pr_vliofatraso
                                       ,pr_vldesconto             => pr_vldesconto
                                       ,pr_vlsaldodev             => pr_vlsaldodev
                                       ,pr_rw_crapdat             => rw_crapdat                                           
                                       ,pr_cdcritic               => vr_cdcritic
                                       ,pr_dscritic               => vr_dscritic  
                                       );
             
             IF (nvl(vr_cdcritic,0) > 0 or vr_dscritic IS NOT NULL) THEN
                RAISE vr_exc_erro;
             END IF;           
           
            -- Atualizar tabela de controle
            UPDATE tbepr_consignado_pagamento 
               SET dtupdreg = sysdate
                   ,instatus = 2   
             WHERE idsequencia = pr_idsequencia;
            -- Gravar verlog
             GENE0001.pc_gera_log(pr_cdcooper  => rw_cr_tbepr_consig_pag.cdcooper
                                  ,pr_cdoperad => rw_cr_tbepr_consig_pag.cdoperad
                                  ,pr_dscritic => ''
                                  ,pr_dsorigem => vr_dsorigem
                                  ,pr_dstransa => 'Parcela :'||rw_cr_tbepr_consig_pag.nrparepr||' do contrato: '||
                                                  rw_cr_tbepr_consig_pag.nrctremp||' estornada com sucesso.'
                                  ,pr_dttransa => TRUNC(SYSDATE)
                                  ,pr_flgtrans => 1
                                  ,pr_hrtransa => gene0002.fn_busca_time
                                  ,pr_idseqttl => 1
                                  ,pr_nmdatela => ' '
                                  ,pr_nrdconta => rw_cr_tbepr_consig_pag.nrdconta
                                  ,pr_nrdrowid => vr_nrdrowid);
           
         END IF;
                 
         CLOSE cr_tbepr_consignado_pagamento;
         COMMIT;
         pr_cdcritic := nvl(vr_cdcritic,0);
         pr_dscritic := 'OK'; 
         -- Existe para satisfazer exigência da interface. 
         pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><dsmensag>OK</dsmensag></Root>'); 
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
         IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         -- Gravar verlog
         GENE0001.pc_gera_log( pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => 1
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => 'Erro no estorno do pagamento da parcela :'||nvl(rw_cr_tbepr_consig_pag.nrparepr,0)||' do contrato: '||
                                              nvl(rw_cr_tbepr_consig_pag.nrctremp,0)||' - '||vr_dscritic
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0
                              ,pr_hrtransa => gene0002.fn_busca_time
                              ,pr_idseqttl => 1
                              ,pr_nmdatela => ' '
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
         commit;
         pr_cdcritic := nvl(vr_cdcritic,0);
         pr_dscritic := 'NOK';
         pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><erro>' || vr_dscritic || '</erro></Root>');
      WHEN OTHERS THEN
        vr_dscritic := 'Erro nao tratado na empr0020.pc_estorn_pag_parc_ret ' ||SQLERRM;
        pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := 'NOK';
        -- Gravar verlog
         GENE0001.pc_gera_log(pr_cdcooper  => pr_cdcooper
                              ,pr_cdoperad => 1
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => 'Erro no estorno do pagamento da parcela :'||nvl(rw_cr_tbepr_consig_pag.nrparepr,0)||' do contrato: '||
                                              nvl(rw_cr_tbepr_consig_pag.nrctremp,0)||' - '||vr_dscritic
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0
                              ,pr_hrtransa => gene0002.fn_busca_time
                              ,pr_idseqttl => 1
                              ,pr_nmdatela => ' '
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        commit;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><erro>' || vr_dscritic || '</erro></Root>');    
    END;  
  END pc_estorn_pag_parc_ret;                                 
                                
  PROCEDURE pc_efetiva_estorn_pag_parc(pr_rw_cr_tbepr_consig_pag IN tbepr_consignado_pagamento%ROWTYPE
                                      ,pr_saldopmt               IN NUMBER
                                      ,pr_vlmora                 IN NUMBER
                                      ,pr_vlmulta                IN NUMBER
                                      ,pr_vliofatraso            IN NUMBER 
                                      ,pr_vldesconto             IN NUMBER 
                                      ,pr_vlsaldodev             IN NUMBER 
                                      ,pr_rw_crapdat             IN btch0001.cr_crapdat%ROWTYPE                                          
                                      ,pr_cdcritic              OUT crapcri.cdcritic%TYPE   
                                      ,pr_dscritic              OUT VARCHAR2
                                      ) IS
  /*---------------------------------------------------------------------------------------------------------
      Programa : pc_efetiva_estorn_pag_parc
      Sistema  : AIMARO
      Sigla    : 
      Autor    : Fernanda Kelli de Oliveira - AMcom Sistemas de Informação
      Data     : 26/06/2019                                 ultima Atualizacao: 

      Objetivo : Retorno do estorno de pagamento consignado (Retorno FIS).                  

      Alteração :

  ----------------------------------------------------------------------------------------------------------*/
  BEGIN 
    DECLARE 
      -- Variaveis de Erro
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(4000);
      
      -- Variaveis Excecao
      vr_exc_erro   EXCEPTION;  
            
      CURSOR cr_crappep (pr_cdcooper IN crappep.cdcooper%TYPE,
                         pr_nrdconta IN crappep.nrdconta%TYPE,
                         pr_nrctremp IN crappep.nrctremp%TYPE,
                         pr_nrparepr IN crappep.nrparepr%TYPE) IS
          SELECT cdcooper,
                 nrdconta,
                 nrctremp,
                 nrparepr,
                 vlparepr,
                 dtultpag,
                 vlpagpar,
                 vlsdvpar,
                 vldespar,
                 inliquid,
                 vlsdvatu,
                 vljura60,
                 vlsdvsji,
                 dtvencto,
                 vlpagmta,
                 vlmtapar,
                 vlpagmra,
                 vlmrapar,
                 vlpagiof,
                 vliofcpl
            FROM crappep
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND nrctremp = pr_nrctremp
             AND nrparepr = pr_nrparepr;

      rw_cr_crappep cr_crappep%ROWTYPE;
        
      CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%TYPE,
                         pr_nrdconta IN crapepr.nrdconta%TYPE,
                         pr_nrctremp IN crapepr.nrctremp%TYPE) IS
          SELECT cdcooper,
                 nrdconta,
                 nrctremp,
                 tpemprst,
                 dtultpag,
                 qtprepag,
                 qtprecal,
                 inliquid,
                 dtliquid
            FROM crapepr
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND nrctremp = pr_nrctremp;

      rw_cr_crapepr cr_crapepr%ROWTYPE;
      
      CURSOR cr_crappep_dt (pr_cdcooper IN crappep.cdcooper%TYPE,
                            pr_nrdconta IN crappep.nrdconta%TYPE,
                            pr_nrctremp IN crappep.nrctremp%TYPE) IS
          SELECT max(dtultpag) dtultpag
            FROM crappep
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND nrctremp = pr_nrctremp;
      rw_cr_crappep_dt cr_crappep_dt%ROWTYPE;
      
      CURSOR cr_crappep_qt (pr_cdcooper IN crappep.cdcooper%TYPE,
                            pr_nrdconta IN crappep.nrdconta%TYPE,
                            pr_nrctremp IN crappep.nrctremp%TYPE) IS
        SELECT count(inliquid) inliquid
          FROM crappep
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND inliquid = 1; --Parcelas Liquidadas
      rw_cr_crappep_qt cr_crappep_qt%ROWTYPE;       
                                         
    BEGIN
      -- Abre o cursor de parcelas
      OPEN cr_crappep(pr_cdcooper => pr_rw_cr_tbepr_consig_pag.cdcooper,
                      pr_nrdconta => pr_rw_cr_tbepr_consig_pag.nrdconta,
                      pr_nrctremp => pr_rw_cr_tbepr_consig_pag.nrctremp,
                      pr_nrparepr => pr_rw_cr_tbepr_consig_pag.nrparepr);
      FETCH cr_crappep INTO rw_cr_crappep;              
      IF cr_crappep%NOTFOUND THEN
         vr_dscritic:= 'Registro nao encontrado(crappep)!';
         CLOSE cr_crappep;  
         RAISE vr_exc_erro;         
      END IF;
      
       -- Abre o cursor de contrato
      OPEN cr_crapepr(pr_cdcooper => pr_rw_cr_tbepr_consig_pag.cdcooper,
                      pr_nrdconta => pr_rw_cr_tbepr_consig_pag.nrdconta,
                      pr_nrctremp => pr_rw_cr_tbepr_consig_pag.nrctremp);
      FETCH cr_crapepr INTO rw_cr_crapepr;
              
      IF cr_crapepr%NOTFOUND THEN
         vr_dscritic:= 'Registro nao encontrado(crapepr)!';
         CLOSE cr_crapepr;  
         RAISE vr_exc_erro;         
      END IF;
      
      --Buscar a Data do último pagamento 
      OPEN cr_crappep_dt(pr_cdcooper => pr_rw_cr_tbepr_consig_pag.cdcooper,
                         pr_nrdconta => pr_rw_cr_tbepr_consig_pag.nrdconta,
                         pr_nrctremp => pr_rw_cr_tbepr_consig_pag.nrctremp);
      FETCH cr_crappep_dt INTO rw_cr_crappep_dt;              
      IF cr_crappep_dt%NOTFOUND THEN
         vr_dscritic:= 'Registro nao encontrado(crappep)!';
         CLOSE cr_crappep_dt;  
         RAISE vr_exc_erro;         
      END IF;
      
      -- Atualiza os dados da Parcela
      BEGIN
        UPDATE crappep
           SET crappep.vlpagpar = nvl(crappep.vlparepr,0) - nvl(pr_saldopmt,0)   --> Valor pago da parcela = Valor da parcela - saldo dev da parcela
              ,crappep.vlsdvpar = pr_saldopmt                                    --> Contem o valor do saldo devedor da parcela.
              ,crappep.vldespar = nvl(crappep.vldespar,0) - nvl(pr_vldesconto,0) --> Contem o valor do desconto da parcela.
              ,crappep.inliquid = 0                                              --> inliquid = 0-pendente/1-liquidada
              ,crappep.vlpagmra = nvl(crappep.vlpagmra,0) - nvl(pr_vlmora,0)     --> Valor pago da mora.
              ,crappep.vlpagmta = nvl(crappep.vlpagmta,0) - nvl(pr_vlmulta,0)    --> Valor pago da multa.
              ,crappep.vldespar = pr_vldesconto                                  --> Contem o valor do desconto da parcela.                      
              ,crappep.vliofcpl = pr_vliofatraso                                 --> Valor do IOF Complementar de atraso
              ,crappep.vlmrapar = pr_vlmora                                      --> Valor de juros pelo atraso no pagamento da parcela.
              ,crappep.vlmtapar = pr_vlmulta                                     --> Valor da multa por atraso de pagamento da parcela.
              ,crappep.dtultpag = rw_cr_crappep_dt.dtultpag
         WHERE crappep.cdcooper = pr_rw_cr_tbepr_consig_pag.cdcooper
           AND crappep.nrdconta = pr_rw_cr_tbepr_consig_pag.nrdconta
           AND crappep.nrctremp = pr_rw_cr_tbepr_consig_pag.nrctremp
           AND crappep.nrparepr = pr_rw_cr_tbepr_consig_pag.nrparepr;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar o estorno de pgto na tabela crappep. ' || SQLERRM;
          RAISE vr_exc_erro;
      END; 
      
      --Buscar a quantidade de parcelas liquidadas
      OPEN cr_crappep_qt(pr_cdcooper => pr_rw_cr_tbepr_consig_pag.cdcooper,
                         pr_nrdconta => pr_rw_cr_tbepr_consig_pag.nrdconta,
                         pr_nrctremp => pr_rw_cr_tbepr_consig_pag.nrctremp);
      FETCH cr_crappep_qt INTO rw_cr_crappep_qt;              
      IF cr_crappep_qt%NOTFOUND THEN
         vr_dscritic:= 'Registro nao encontrado(crappep)!';
         CLOSE cr_crappep_qt;  
         RAISE vr_exc_erro;         
      END IF;  
  
      -- Atualiza os dados do Emprestimo
      BEGIN
        UPDATE crapepr
           SET crapepr.vlsdeved = pr_vlsaldodev,             --> Valor do saldo devedor do emprestimo.
               crapepr.qtprepag = rw_cr_crappep_qt.inliquid, --> Quantidade de prestacoes pagas.
               crapepr.qtprecal = rw_cr_crappep_qt.inliquid, --> Quantidade de prestacoes calculadas.
               crapepr.dtultest = pr_rw_crapdat.dtmvtolt,    --> Data do ultimo estorno
               crapepr.dtliquid = NULL                       --> Data da liquidacao do contrato 
         WHERE crapepr.cdcooper = pr_rw_cr_tbepr_consig_pag.cdcooper
           AND crapepr.nrdconta = pr_rw_cr_tbepr_consig_pag.nrdconta
           AND crapepr.nrctremp = pr_rw_cr_tbepr_consig_pag.nrctremp;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar o estorno de pgto na tabela crapepr. ' || SQLERRM;
          RAISE vr_exc_erro;
      END; 
         
    	CLOSE cr_crappep;
      CLOSE cr_crapepr;
      CLOSE cr_crappep_dt;

      pr_cdcritic := 0;
      pr_dscritic := 'OK' ;
    EXCEPTION
      WHEN vr_exc_erro THEN
         IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
         vr_dscritic := 'Erro nao tratado na empr0020.pc_efetiva_estorn_pag_parc ' ||SQLERRM;
         pr_cdcritic := 0;
         pr_dscritic := vr_dscritic;
    END;

  END pc_efetiva_estorn_pag_parc;  
                                      
  PROCEDURE pc_gera_log(pr_cdcooper  NUMBER DEFAULT 3
                        ,pr_des_log  VARCHAR2
                        ,pr_tipo     PLS_INTEGER DEFAULT 2
                        ,pr_cdprogra VARCHAR2 DEFAULT NULL
                        ) IS
   ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_gera_log
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : Jackson Barcellos
    --  Data     : Julho/2019.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Gravar log em arquivo
    --
    ---------------------------------------------------------------------------------------------------------------                       
     vr_nmarqlog VARCHAR2(20) DEFAULT 'CONSIGNADO.log';         
  BEGIN
     btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                ,pr_ind_tipo_log => pr_tipo
                                ,pr_tpexecucao   => 2
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_des_log      => TO_CHAR(SYSDATE,'YYYYMMDD HH24:MI:SS') || ' - ' || pr_cdprogra || ' --> ' ||pr_des_log);         
  END pc_gera_log;
  
  PROCEDURE pc_envia_arquivo_conveniada(pr_cdcooper   IN crapcop.cdcooper%TYPE        --> codigo da cooperativa
                                        ,pr_cdcritic   OUT PLS_INTEGER                 --> Código da critica
  				    				        	        ,pr_dscritic   OUT VARCHAR2) IS                --> Descricao da critica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --  Programa : pc_envia_arquivo_conveniada
    --  Sistema  : Ayllos
    --  Sigla    : CRED
    --  Autor    : Jackson Barcellos
    --  Data     : Julho/2019.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Enviar arquivo para conveniada
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      
      -- Cursor generico de calendario
      rw_crapdat     BTCH0001.CR_CRAPDAT%ROWTYPE;
          
      -- Busca as cooperativas
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapcop.nmrescop
          FROM crapcop
         WHERE cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
         
      -- Busca empresas consignado
      CURSOR cr_consig(pr_cdcooper  IN crapass.cdcooper%TYPE
                       ,pr_cdempres IN tbcadast_empresa_consig.cdempres%TYPE
                      ) IS
        SELECT c.dsdemailconsig
               ,c.indalertaemailemp
               ,c.indalertaemailconsig
               ,e.dsdemail
               ,e.nmextemp
               ,e.nrdconta                      
          FROM tbcadast_empresa_consig c
         INNER 
          JOIN crapemp e ON e.cdcooper = c.cdcooper AND e.cdempres = c.cdempres              
         WHERE c.cdcooper = pr_cdcooper
               and c.cdempres = pr_cdempres; 
      rw_consig cr_consig%ROWTYPE;
         
      -- Variaveis     
      vr_vet_arquivos         gene0002.typ_split;               -- Array de arquivos
      vr_ind_linha_arquivo    VARCHAR2(50);
      vr_listadir             VARCHAR2(4000);
      vr_typ_saida            VARCHAR2(4000);
      vr_des_saida            VARCHAR2(4000);
      vr_email                VARCHAR2(4000);
      vr_desemail             CLOB;
      vr_path                 VARCHAR2(4000) DEFAULT '/usr/sistemas/Consignado/';
      vr_cdempres             NUMBER;
      vr_nmarquivo            VARCHAR2(4000);
      
      -- Variaveis de Erro
      vr_cdcritic             crapcri.cdcritic%TYPE;
      vr_dscritic             VARCHAR2(4000);

      -- Variaveis Excecao
      vr_exc_erro             EXCEPTION;
      vr_cdprogra             VARCHAR2(40) DEFAULT 'CONSIG_ENV_ARQ_CONV';
      
    BEGIN
      
      -- Buscar a data do movimento
      OPEN btch0001.cr_crapdat(pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Verificar se existe informacao, e gerar erro caso nao exista
      IF btch0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor
         CLOSE btch0001.cr_crapdat;     
         vr_cdcritic := 1;
          RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      
      -- Condicao para verificar se o processo estah rodando
      IF NVL(rw_crapdat.inproces,0) >= 2 THEN
        -- Sai da procedure
        RETURN;
      END IF;
    
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
      
      -- Busca Arquivos
      vr_path := vr_path||'ailos'||LPAD(pr_cdcooper,3,0)||'/envia';
      --vr_path := vr_path||'ailos/envia';
      gene0001.pc_lista_arquivos(pr_path     => vr_path ,
                                 pr_pesq     => LPAD(pr_cdcooper,4,0) || '%',
                                 pr_listarq  => vr_listadir,
                                 pr_des_erro => vr_dscritic);
                                     
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF; 
            
      -- Separar os arquivos de retorno em um Array
      vr_vet_arquivos := gene0002.fn_quebra_string(pr_string => vr_listadir);
      -- Vamos verificar se possui algum arquivo na pasta para importar
      IF vr_vet_arquivos.COUNT <= 0 THEN
        -- Sai da procedure
        RETURN;
      END IF;
      
      -- Leitura da PL/Table e processamento dos arquivos     
	    FOR vr_ind_linha_arquivo in 1 .. vr_vet_arquivos.COUNT LOOP 
        vr_cdcritic  := 0;
        vr_dscritic  := '';    
        
        vr_nmarquivo := vr_vet_arquivos(vr_ind_linha_arquivo);   
               
          -- Valida layout do nome do arquivo e busca dados da empresa
          IF(to_number(substr(vr_nmarquivo,1,4)) = pr_cdcooper) THEN
            vr_cdempres := to_number(substr(vr_nmarquivo,5,5));            
          ELSE
            vr_dscritic := 'Arquivo inválido.('||vr_nmarquivo||')';
            -- Grava LOG
            pc_gera_log(pr_cdcooper  => pr_cdcooper
                        ,pr_cdprogra => vr_cdprogra
                        ,pr_des_log  => vr_dscritic
                        ,pr_tipo     => 2);
            CONTINUE;
          END IF;
          
           -- Verifica se a empresa consignado esta cadastrada
          OPEN cr_consig(pr_cdcooper  => pr_cdcooper
                         ,pr_cdempres => vr_cdempres
                        );
          FETCH cr_consig INTO rw_consig;
          -- Se nao encontrar
          IF cr_consig%NOTFOUND THEN
            -- Fechar o cursor pois havera raise
            CLOSE cr_consig;
            -- Montar mensagem de critica
            vr_dscritic := 'Empresa não encontrada.('||vr_nmarquivo||')';
            -- Grava LOG
            pc_gera_log(pr_cdcooper  => pr_cdcooper
                        ,pr_cdprogra => vr_cdprogra
                        ,pr_des_log  => vr_dscritic
                        ,pr_tipo     => 2);
            CONTINUE;
          ELSE
            -- Apenas fechar o cursor
            CLOSE cr_consig;
          END IF;
          
          -- Monta destinatario email
          IF (rw_consig.indalertaemailemp = 1 AND rw_consig.dsdemail IS NOT NULL) THEN
             vr_email:= rw_consig.dsdemail;
          END IF;
          IF (rw_consig.indalertaemailconsig = 1 AND rw_consig.dsdemailconsig IS NOT NULL) THEN
             IF vr_email IS NOT NULL THEN
               vr_email := vr_email||','|| rw_consig.dsdemailconsig;
             ELSE
               vr_email := rw_consig.dsdemailconsig;                          
             END IF;
          END IF;
          IF vr_email IS NULL THEN
            -- Montar mensagem de critica
            vr_dscritic := 'Email não encontrado.('||vr_nmarquivo||')';
            -- Grava LOG
            pc_gera_log(pr_cdcooper  => pr_cdcooper
                        ,pr_cdprogra => vr_cdprogra
                        ,pr_des_log  => vr_dscritic
                        ,pr_tipo     => 2);
            CONTINUE;
          END IF;

          -- Monta corpo email 
          vr_desemail := 'Olá Prezada Conveniada '||rw_consig.nmextemp||'.<br><br>';
          vr_desemail := vr_desemail||'Antes de tudo, gostaria de dizer que essa mensagem é automática, com isso, sua resposta deve ser encaminhada a outro endereço de e-mail, ok? <br><br>';
          vr_desemail := vr_desemail||'Estamos enviando arquivo com parcelas do mês de fechamento da última folha, provenientes de operações de crédito Consignado realizadas pelos seus colaboradores com a Cooperativa '||rw_crapcop.nmrescop||'.<br><br>';
          vr_desemail := vr_desemail||'Você pode nos retornar até 1 dia útil antes da data de vencimento das parcelas.<br><br>';
          vr_desemail := vr_desemail||'Caso a Conveniada possua conta na cooperativa, então o valor do repasse será debitado da conta '||rw_consig.nrdconta||' no dia do vencimento das parcelas.<br>';
          vr_desemail := vr_desemail||'Caso a Conveniada não possua conta na cooperativa, então deverá fazer uma TED na conta indicada, até 1 dia útil antes do vencimento das parcelas.<br><br>';
          vr_desemail := vr_desemail||'Após tratar o arquivo de repasse de parcelas, a Conveniada poderá enviá-lo (como anexo) para o e-mail já indicado na formalização do Convênio.<br><br>';
          vr_desemail := vr_desemail||'Por favor, preencha as informações das colunas Status e Valor Pago, conforme situação de cada colaborador, conforme legenda abaixo:<br><br>';
          vr_desemail := vr_desemail||'1. Baixa com Sucesso - para aquelas parcelas que serão pagas/descontadas de forma integral;<br>';
          vr_desemail := vr_desemail||'2. Óbito - neste caso, a parcela não será mais enviada à Conveniada nos próximos meses;<br>';
          vr_desemail := vr_desemail||'3. Desligado - para informar quando colaborador for desligado/exonerado da conveniada. Importante: na coluna "Valor Pago" é necessário enviar a parcela do mês + 30% do valor da rescisão (conforme Lei 10.820/2003), estes valores devem ser somados e enviados como valor único, não é preciso separar. Neste caso, a parcela não será mais enviada à Conveniada nos próximos meses;<br>';
          vr_desemail := vr_desemail||'4. Afastado - quando colaborador está afastado de suas atividades na Conveniada e, por este motivo, a Conveniada não irá fazer desconto na folha e repassar o valor à cooperativa. A parcela será enviada à Conveniada nos meses seguintes, sendo necessário informar nos status quando colaborador retornar às suas atividades;<br>';
          vr_desemail := vr_desemail||'5. Outros - outros motivos que implicam em não descontar o valor integral da parcela do colaborador. Neste caso, a parcela continuará sendo enviada à Conveniada nos meses seguintes.<br><br>';
          vr_desemail := vr_desemail||'<u>Importante:</u> caso não possa responder no prazo indicado, entre em contato com a cooperativa. Caso não o faça, será considerado o pagamento integral de todas as parcelas enviadas.<br><br>';
          vr_desemail := vr_desemail||'Atenciosamente,<br>';
          vr_desemail := vr_desemail||'Sistema Ailos.<br>';
          vr_desemail := vr_desemail||'<br>';
          
          -- Envia email
          gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                    ,pr_cdprogra        => 'EMPR0020'
                                    ,pr_des_destino     => vr_email
                                    ,pr_des_assunto     => 'Consignado - Repasse de parcelas.' 
                                    ,pr_des_corpo       => vr_desemail
                                    ,pr_des_anexo       => vr_path||'/'||vr_nmarquivo --> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                    ,pr_flg_remove_anex => 'N'  --> Remover os anexos passados
                                    ,pr_flg_remete_coop => 'S'  --> Se o envio sera do e-mail da Cooperativa
                                    ,pr_flg_enviar      => 'S'  --> Enviar o e-mail na hora
                                    ,pr_des_erro        => vr_dscritic);

           -- Se houver erros
           IF vr_dscritic IS NOT NULL THEN
             -- Grava LOG
             pc_gera_log(pr_cdcooper  => pr_cdcooper
                        ,pr_cdprogra => vr_cdprogra
                        ,pr_des_log  => 'Erro ao enviar email:('||vr_nmarquivo||') '||vr_dscritic
                        ,pr_tipo     => 2);
             CONTINUE;
           ELSE
             -- Grava LOG
             pc_gera_log(pr_cdcooper  => pr_cdcooper
                        ,pr_cdprogra => vr_cdprogra
                        ,pr_des_log  => 'Email enviado com sucesso('||vr_nmarquivo||').'
                        ,pr_tipo     => 1);
           END IF; 
                      
           -- Move arquivo
           gene0001.pc_mv_arquivo(pr_dsarqori     => vr_path||'/'||vr_nmarquivo
                                  ,pr_dsarqdes    => vr_path||'/enviados/'||vr_nmarquivo
                                  ,pr_typ_saida   => vr_typ_saida
                                  ,pr_des_saida   => vr_des_saida);
           -- Se houver erros                                  
           IF vr_typ_saida = 'ERR' THEN
             vr_dscritic:= vr_des_saida;
             -- Grava LOG
             pc_gera_log(pr_cdcooper  => pr_cdcooper
                        ,pr_cdprogra => vr_cdprogra
                        ,pr_des_log  => 'Erro ao mover arquivo:('||vr_nmarquivo||') '||vr_dscritic
                        ,pr_tipo     => 2);
             CONTINUE;
           END IF;
      END LOOP;
      COMMIT;         
    EXCEPTION
      WHEN vr_exc_erro THEN
        ROLLBACK;
        -- Variavel de erro recebe erro ocorrido
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Grava LOG
        pc_gera_log(pr_cdcooper  => pr_cdcooper
                        ,pr_cdprogra => vr_cdprogra
                        ,pr_des_log  => pr_dscritic
                        ,pr_tipo     => 2);
      WHEN OTHERS THEN
        ROLLBACK;
        -- Descricao do erro
        pr_dscritic := 'Erro nao tratado na EMPR0020.pc_envia_arq_conveniada ' || SQLERRM;
        -- Grava LOG
        pc_gera_log(pr_cdcooper  => pr_cdcooper
                        ,pr_cdprogra => vr_cdprogra
                        ,pr_des_log  => pr_dscritic
                        ,pr_tipo     => 3);
    END;
                           
  END pc_envia_arquivo_conveniada;     
  
  PROCEDURE pc_env_arq_conveniada_job IS
    
  BEGIN
    
     DECLARE
        -- Busca as cooperativas
        CURSOR cr_crapcop IS
          SELECT cdcooper
                ,nmrescop
                ,cdagebcb
            FROM crapcop
           WHERE flgativo = 1
             AND cdcooper <> 3
        ORDER BY cdcooper;
     
     vr_cdcritic   PLS_INTEGER; 
  	 vr_dscritic   VARCHAR2(4000);
     
     BEGIN       
     
      FOR rw_crapcop IN cr_crapcop LOOP
           -- Grava LOG
           pc_gera_log(pr_cdcooper  => rw_crapcop.cdcooper
           	           ,pr_cdprogra => 'PC_ENV_ARQ_CONVENIADA_JOB'
                       ,pr_des_log  => 'Inicio do envio de arquivos para conveinadas da cooperativa ('||rw_crapcop.cdcooper||') '||rw_crapcop.nmrescop
                       ,pr_tipo     => 1);
                       
           pc_envia_arquivo_conveniada(pr_cdcooper  => rw_crapcop.cdcooper
                                       ,pr_cdcritic => vr_cdcritic
  				    				        	       ,pr_dscritic => vr_dscritic);
           -- Grava LOG                            
           pc_gera_log(pr_cdcooper  => rw_crapcop.cdcooper
           	           ,pr_cdprogra => 'PC_ENV_ARQ_CONVENIADA_JOB'
                       ,pr_des_log  => 'Fim do envio de arquivos para conveinadas da cooperativa ('||rw_crapcop.cdcooper||') '||rw_crapcop.nmrescop||' '||vr_dscritic
                       ,pr_tipo     => 1);
      END LOOP;
      COMMIT;
     EXCEPTION WHEN OTHERS THEN
            ROLLBACK;
            -- Grava LOG
            pc_gera_log(pr_cdcooper => 3
                       ,pr_cdprogra => 'PC_ENV_ARQ_CONVENIADA_JOB'
                       ,pr_tipo     => 3
                       ,pr_des_log  => SQLERRM); 
     END;
     
  END pc_env_arq_conveniada_job;
         
                                               
END EMPR0020;
/
