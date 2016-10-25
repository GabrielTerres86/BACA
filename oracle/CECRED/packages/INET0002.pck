CREATE OR REPLACE PACKAGE CECRED.INET0002 AS

/*..............................................................................

    Programa: INET0002                         
    Autor   : Jorge Hamaguchi / Jean Deschamps
    Data    : Novembro/2015                      Ultima Atualizacao: 02/09/2016

    Dados referentes ao programa:

    Objetivo  : BO para controlar operacoes de Multiplas Assinaturas PJ.

    Alteracoes: 24/11/2015 - Inclusao da procedure pc_inicia_senha_ass_conj para o
                             PRJ. Assinatura Conjunta (Jean Michel).

			    25/04/2016 - Remocao de caracteres invalidos no nome da agencia 
							 conforme solicitado no chamado 429584 (Kelvin)
    
						    24/03/2016 - Adicionados parâmetros para geraçao de LOG na 'PC_CRIA_TRANS_PEND_TRANSF'
                            (Lucas Lunelli - PROJ290 Cartao CECRED no CaixaOnline)
    
                20/06/2016 - Correcao para o uso da function fn_busca_dstextab da TABE0001 em 
                             varias procedures desta package.(Carlos Rafael Tanholi). 
                
                18/07/2016 - Criação da procedure pc_cria_trans_pend_darf_das para o
                             Prj. 338, Pagamento de DARF e DAS (Jean Michel) 

                02/09/2016 - Ajustes na procedure pc_busca_trans_pend, SD 514239 (Jean Michel).

..............................................................................*/

  --Tipo de Registro para limites transacoes pendentes
  TYPE typ_reg_limite_pend IS
    RECORD (tipodtra NUMBER --Tipo de Transacao
           ,hrinipag VARCHAR2(5)
           ,hrfimpag VARCHAR2(5));

  --Tipo de tabela de memoria para limites transacoes pendentes
  TYPE typ_tab_limite_pend IS TABLE OF typ_reg_limite_pend INDEX BY PLS_INTEGER;

  -- PL/TABLE que contem os dados de pagamentos de DARF/DAS
	TYPE typ_reg_darf_das IS
	  RECORD(cdtransacao_pendente	tbpagto_darf_das_trans_pend.cdtransacao_pendente%TYPE
          ,cdcooper             tbpagto_darf_das_trans_pend.cdcooper%TYPE
          ,nrdconta             tbpagto_darf_das_trans_pend.nrdconta%TYPE
          ,tppagamento          tbpagto_darf_das_trans_pend.tppagamento%TYPE
          ,tpcaptura            tbpagto_darf_das_trans_pend.tpcaptura%TYPE
          ,dsidentif_pagto      tbpagto_darf_das_trans_pend.dsidentif_pagto%TYPE
          ,dsnome_fone          tbpagto_darf_das_trans_pend.dsnome_fone%TYPE
          ,dscod_barras         tbpagto_darf_das_trans_pend.dscod_barras%TYPE
          ,dslinha_digitavel    tbpagto_darf_das_trans_pend.dslinha_digitavel%TYPE
          ,dtapuracao           tbpagto_darf_das_trans_pend.dtapuracao%TYPE
          ,nrcpfcgc             tbpagto_darf_das_trans_pend.nrcpfcgc%TYPE
          ,cdtributo            tbpagto_darf_das_trans_pend.cdtributo%TYPE
          ,nrrefere             tbpagto_darf_das_trans_pend.nrrefere%TYPE
          ,vlprincipal          tbpagto_darf_das_trans_pend.vlprincipal%TYPE
          ,vlmulta              tbpagto_darf_das_trans_pend.vlmulta%TYPE
          ,vljuros              tbpagto_darf_das_trans_pend.vljuros%TYPE
          ,vlreceita_bruta      tbpagto_darf_das_trans_pend.vlreceita_bruta%TYPE
          ,vlpercentual         tbpagto_darf_das_trans_pend.vlpercentual%TYPE
          ,dtvencto             tbpagto_darf_das_trans_pend.dtvencto%TYPE
          ,tpleitura_docto      tbpagto_darf_das_trans_pend.tpleitura_docto%TYPE
          ,vlpagamento          tbpagto_darf_das_trans_pend.vlpagamento%TYPE
          ,dtdebito             tbpagto_darf_das_trans_pend.dtdebito%TYPE
          ,idagendamento        tbpagto_darf_das_trans_pend.idagendamento%TYPE
          ,idrowid              VARCHAR2(200));
					
  TYPE typ_tab_darf_das IS
	  TABLE OF typ_reg_darf_das
		INDEX BY BINARY_INTEGER;

  /* Procedure para  identificar se a operação de autoatendimento 
     foi executada por uma conta PJ que exija ura conjunta*/
  PROCEDURE pc_verifica_rep_assinatura (pr_cdcooper IN crapcop.cdcooper%type  --Codigo Cooperativa
                                       ,pr_nrdconta IN crapass.nrdconta%type  --Conta do Associado
                                       ,pr_idseqttl IN crapttl.idseqttl%type  --Titularidade do Associado
                                       ,pr_cdorigem IN INTEGER                --Codigo Origem
                                       ,pr_idastcjt OUT crapass.idastcjt%TYPE --Codigo 1 exige Ass. Conj.
                                       ,pr_nrcpfcgc OUT crapass.nrcpfcgc%TYPE --CPF do Rep. Legal
                                       ,pr_nmprimtl OUT crapass.nmprimtl%TYPE --Nome do Rep. Legal
                                       ,pr_flcartma OUT INTEGER               --Cartao Magnetico conjunta, 0 nao, 1 sim
                                       ,pr_cdcritic OUT INTEGER    --Codigo do erro
                                       ,pr_dscritic OUT VARCHAR2); --Descricao do erro

  PROCEDURE pc_inicia_senha_ass_conj(pr_cdcooper IN crappod.cdcooper%TYPE -- Codigo Cooperativa
                                    ,pr_nrdconta IN crappod.nrdconta%TYPE -- Numero da conta
                                    ,pr_nrcpfpro IN crappod.nrcpfpro%TYPE -- Numero do CPF do Procurador
                                    ,pr_cdoperad IN crapope.cdoperad%TYPE -- Codigo do Operador
                                    ,pr_cdcritic   OUT INTEGER            -- Codigo do erro
                                    ,pr_dscritic   OUT VARCHAR2);         -- Descricao do erro
																		
	PROCEDURE pc_verifica_validade_procurac(pr_cdcooper IN crapcop.cdcooper%TYPE  -- Código cooperativa
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE  -- Nr. da Conta
                                         ,pr_inpessoa IN crapass.inpessoa%TYPE  -- PF/PJ
                                         ,pr_idseqttl IN crapttl.idseqttl%TYPE  -- Sequencia do titular
                                         ,pr_nrcpfcgc IN crapavt.nrcpfcgc%TYPE  -- Nr. CPF/CNPJ
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE -- Cód. Crítica
                                         ,pr_dscritic OUT VARCHAR2);            -- Descrição da crítica
  
  --> Rotina responsavel pela criacao de registros de aprovacao
  PROCEDURE pc_cria_aprova_transpend(pr_cdagenci    IN crapage.cdagenci%TYPE                        --> Codigo do PA
                                    ,pr_nrdcaixa    IN craplot.nrdcaixa%TYPE                        --> Numero do Caixa
                                    ,pr_cdoperad    IN crapope.cdoperad%TYPE                        --> Codigo do Operados
                                    ,pr_nmdatela    IN craptel.nmdatela%TYPE                        --> Nome da Tela
                                    ,pr_idorigem    IN INTEGER                                      --> Origem da solicitacao
                                    ,pr_idseqttl    IN crapttl.idseqttl%TYPE                        --> Sequencial de Titular               
                                    ,pr_cdcooper    IN crapcop.cdcooper%TYPE                        --> Codigo da cooperativa
                                    ,pr_nrdconta    IN crapass.nrdconta%TYPE                        --> Numero da conta    
                                    ,pr_nrcpfrep    IN tbgen_trans_pend.nrcpf_representante%TYPE    --> Numero do cpf do representante legal
                                    ,pr_dtmvtolt    IN DATE                                         --> Data do movimento     
                                    ,pr_cdtiptra    IN INTEGER                                      --> Codigo do tipo de transação    
                                    ,pr_cdtranpe    IN tbfolha_trans_pend.cdtransacao_pendente%TYPE --> Codigo tipo da transacao
                                    ,pr_tab_crapavt IN CADA0001.typ_tab_crapavt_58                  --> Tabela de procuradore
                                    ,pr_cdcritic  OUT INTEGER                                       --> Codigo da critica
                                    ,pr_dscritic  OUT VARCHAR2);                                    --> Descrição da crítica       

                                         
  /* Antiga proc. exclui_transacoes da BO16*/
  PROCEDURE pc_exclui_trans_pend (pr_cdcooper IN crapcop.cdcooper%TYPE  --Codigo Cooperativa
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE  --Conta do Associado
                                 ,pr_nrdcaixa IN INTEGER                --Numero do caixa
                                 ,pr_cdagenci IN INTEGER                --Numero da agencia
                                 ,pr_cdoperad IN VARCHAR2               --Numero do operador
                                 ,pr_dtmvtolt IN DATE                   --Data da operacao
                                 ,pr_cdorigem IN INTEGER                --Codigo Origem
                                 ,pr_nmdatela IN VARCHAR2               --Nome da tela
                                 ,pr_cdditens IN VARCHAR2               --Itens
                                 ,pr_nrcpfope IN NUMBER                 --CPF do operador
                                 ,pr_flgerlog IN INTEGER                --Flag de log
                                 ,pr_cdcritic OUT INTEGER               --Codigo do erro
                                 ,pr_dscritic OUT VARCHAR2);            --Descricao do erro

  -- Procedimentos para criaco de mensagens referente a Assinatura Conjunta                                 
  PROCEDURE pc_cria_msgs_trans (pr_cdcooper IN crapcop.cdcooper%TYPE                      -- Codigo Cooperativa
                               ,pr_nrdconta IN crapass.nrdconta%TYPE                      -- Conta do Associado
                               ,pr_nrdcaixa IN INTEGER                                    -- Numero do caixa
                               ,pr_cdagenci IN INTEGER                                    -- Numero da agencia
                               ,pr_cdoperad IN VARCHAR2                                   -- Numero do operador
                               ,pr_dtmvtolt IN DATE                                       -- Data da operacao
                               ,pr_cdorigem IN INTEGER                                    -- Codigo Origem
                               ,pr_nmdatela IN VARCHAR2                                   -- Nome da tela
                               ,pr_cdtranpe IN tbgen_trans_pend.cdtransacao_pendente%TYPE -- Codigo da Transacao Principal
                               ,pr_tptransa IN INTEGER                                    -- Tipo de Transacao
                               ,pr_dsdmensg OUT VARCHAR2							                    -- Descricao da mensagem
                               ,pr_cdcritic OUT INTEGER                                   -- Codigo do erro
                               ,pr_dscritic OUT VARCHAR2);                                -- Descricao do erro
    
  /* Antiga proc. exclui_transacoes da BO16*/
  PROCEDURE pc_reprova_trans_pend (pr_cdcooper IN crapcop.cdcooper%TYPE  --Codigo Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --Conta do Associado
                                  ,pr_nrdcaixa IN INTEGER                --Numero do caixa
                                  ,pr_cdagenci IN INTEGER                --Numero da agencia
                                  ,pr_cdoperad IN VARCHAR2               --Numero do operador
                                  ,pr_dtmvtolt IN DATE                   --Data da operacao
                                  ,pr_cdorigem IN INTEGER                --Codigo Origem
                                  ,pr_nmdatela IN VARCHAR2               --Nome da tela
                                  ,pr_cdditens IN VARCHAR2               --Itens
                                  ,pr_nrcpfope IN NUMBER                 --CPF do operador
                                  ,pr_idseqttl IN NUMBER 				 --Sequencial de Titularidade
                                  ,pr_flgerlog IN INTEGER                --Flag de log
                                  ,pr_cdcritic OUT INTEGER               --Codigo do erro
                                  ,pr_dscritic OUT VARCHAR2);            --Descricao do erro                                 

  -- Procedure para validacao de representantes legais por transacao
  PROCEDURE pc_valid_repre_legal_trans(pr_cdcooper  IN crapsnh.cdcooper%TYPE
                                      ,pr_nrdconta  IN crapsnh.nrdconta%TYPE
                                      ,pr_idseqttl  IN crapsnh.idseqttl%TYPE
                                      ,pr_flvldrep  IN INTEGER
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE);

  -- Procedure de criacao de transacao de pagamentos
  PROCEDURE pc_cria_trans_pend_pagto(pr_cdagenci  IN crapage.cdagenci%TYPE                     --> Codigo do PA
                                    ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                     --> Numero do Caixa
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE                     --> Codigo do Operados
                                    ,pr_nmdatela  IN craptel.nmdatela%TYPE                     --> Nome da Tela
                                    ,pr_idorigem  IN INTEGER                                   --> Origem da solicitacao
                                    ,pr_idseqttl  IN crapttl.idseqttl%TYPE                     --> Sequencial de Titular            
                                    ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                     --> Numero do cpf do operador juridico
                                    ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                     --> Numero do cpf do representante legal
                                    ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE            --> Cooperativa do Terminal
                                    ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE            --> Agencia do Terminal
                                    ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE            --> Numero do Terminal Financeiro
                                    ,pr_dtmvtolt  IN DATE                                      --> Data do movimento     
                                    ,pr_cdcooper  IN tbpagto_trans_pend.cdcooper%TYPE          --> Codigo da cooperativa
                                    ,pr_nrdconta  IN tbpagto_trans_pend.nrdconta%TYPE          --> Numero da Conta
                                    ,pr_idtippag  IN tbpagto_trans_pend.tppagamento%TYPE       --> Identificacao do tipo de pagamento (1 – Convenio / 2 – Titulo)
                                    ,pr_vllanmto  IN tbpagto_trans_pend.vlpagamento%TYPE       --> Valor do pagamento
                                    ,pr_dtmvtopg  IN tbpagto_trans_pend.dtdebito%TYPE          --> Data do debito
                                    ,pr_idagenda  IN tbpagto_trans_pend.idagendamento%TYPE     --> Indica se o pagamento foi agendado (1 – Online / 2 – Agendamento)
                                    ,pr_dscedent  IN tbpagto_trans_pend.dscedente%TYPE         --> Descricao do cedente do documento
                                    ,pr_dscodbar  IN tbpagto_trans_pend.dscodigo_barras%TYPE   --> Descricao do codigo de barras
                                    ,pr_dslindig  IN tbpagto_trans_pend.dslinha_digitavel%TYPE --> Descricao da linha digitavel
                                    ,pr_vlrdocto  IN tbpagto_trans_pend.vldocumento%TYPE       --> Valor do documento
                                    ,pr_dtvencto  IN tbpagto_trans_pend.dtvencimento%TYPE      --> Data de vencimento do documento
                                    ,pr_tpcptdoc  IN tbpagto_trans_pend.tpcaptura%TYPE         --> Tipo de captura do documento
                                    ,pr_idtitdda  IN tbpagto_trans_pend.idtitulo_dda%TYPE      --> Identificador do titulo no DDA
                                    ,pr_idastcjt  IN crapass.idastcjt%TYPE                     --> Indicador de Assinatura Conjunta
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE                     --> Codigo de Critica
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE);                   --> Descricao de Critica

  -- Procedure de criacao de transacao de TED
  PROCEDURE pc_cria_trans_pend_ted(pr_cdagenci  IN crapage.cdagenci%TYPE                         --> Codigo do PA
                                  ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                         --> Numero do Caixa
                                  ,pr_cdoperad  IN crapope.cdoperad%TYPE                         --> Codigo do Operados
                                  ,pr_nmdatela  IN craptel.nmdatela%TYPE                         --> Nome da Tela
                                  ,pr_idorigem  IN INTEGER                                       --> Origem da solicitacao
                                  ,pr_idseqttl  IN crapttl.idseqttl%TYPE                         --> Sequencial de Titular            
                                  ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                         --> Numero do cpf do operador juridico
                                  ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                         --> Numero do cpf do representante legal
                                  ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE                --> Cooperativa do Terminal
                                  ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE                --> Agencia do Terminal
                                  ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE                --> Numero do Terminal Financeiro
                                  ,pr_dtmvtolt  IN DATE                                          --> Data do movimento     
                                  ,pr_cdcooper  IN tbspb_trans_pend.cdcooper%TYPE                --> Codigo da cooperativa
                                  ,pr_nrdconta  IN tbspb_trans_pend.nrdconta%TYPE                --> Numero da Conta
                                  ,pr_vllanmto  IN tbspb_trans_pend.vlted%TYPE                   --> Valor de Lancamento
                                  ,pr_nrcpfcnpj IN tbspb_trans_pend.nrcpfcnpj_favorecido%TYPE    --> CPF/CNPJ do Favorecido
                                  ,pr_nmtitula  IN tbspb_trans_pend.nmtitula_favorecido%TYPE     --> Nome to Titular Favorecido
                                  ,pr_tppessoa  IN tbspb_trans_pend.tppessoa_favorecido%TYPE     --> Tipo de pessoa do Favorecido
                                  ,pr_tpconta   IN tbspb_trans_pend.tpconta_favorecido%TYPE      --> Tipo da conta do Favorecido
                                  ,pr_dtmvtopg  IN tbspb_trans_pend.dtdebito%TYPE                --> Data do Pagamento
                                  ,pr_idagenda  IN tbspb_trans_pend.idagendamento%TYPE           --> Indicador de agendamento
                                  ,pr_cddbanco  IN tbspb_trans_pend.cdbanco_favorecido%TYPE      --> Codigo do banco
                                  ,pr_cdageban  IN tbspb_trans_pend.cdagencia_favorecido%TYPE    --> Codigo da agencia bancaria
                                  ,pr_nrctadst  IN tbspb_trans_pend.nrconta_favorecido%TYPE      --> Conta de destino
                                  ,pr_cdfinali  IN tbspb_trans_pend.cdfinalidade%TYPE            --> Codigo da finalidade
                                  ,pr_dstransf  IN tbspb_trans_pend.dscodigo_identificador%TYPE  --> Descricao da transferencia
                                  ,pr_dshistor  IN tbspb_trans_pend.dshistorico%TYPE             --> Descricao do historico
                                  ,pr_nrispbif  IN tbspb_trans_pend.nrispb_banco_favorecido%TYPE --> Codigo unico do banco
                                  ,pr_idastcjt  IN crapass.idastcjt%TYPE                         --> Indicador de Assinatura Conjunta
                                  ,pr_lsdatagd  IN VARCHAR2
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE                         --> Codigo de Critica
                                  ,pr_dscritic OUT crapcri.dscritic%TYPE);                       --> Descricao de Critica
  

  -- Procedure de criacao de transacao de transferencia
  PROCEDURE pc_cria_trans_pend_transf(pr_cdtiptra  IN INTEGER                                         --> Tipo da Transacao
                                     ,pr_cdagenci  IN crapage.cdagenci%TYPE                           --> Codigo do PA
                                     ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                           --> Numero do Caixa
                                     ,pr_cdoperad  IN crapope.cdoperad%TYPE                           --> Codigo do Operados
                                     ,pr_nmdatela  IN craptel.nmdatela%TYPE                           --> Nome da Tela
                                     ,pr_idorigem  IN INTEGER                                         --> Origem da solicitacao
                                     ,pr_idseqttl  IN crapttl.idseqttl%TYPE                           --> Sequencial de Titular               
                                     ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                           --> Numero do cpf do operador juridico
                                     ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                           --> Numero do cpf do representante legal
                                     ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE                  --> Cooperativa do Terminal
                                     ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE                  --> Agencia do Terminal
                                     ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE                  --> Numero do Terminal Financeiro
                                     ,pr_dtmvtolt  IN DATE                                            --> Data do movimento     
                                     ,pr_cdcooper  IN tbtransf_trans_pend.cdcooper%TYPE               --> Codigo da cooperativa
                                     ,pr_nrdconta  IN tbtransf_trans_pend.nrdconta%TYPE               --> Numero da Conta
                                     ,pr_vllanmto  IN tbtransf_trans_pend.vltransferencia%TYPE        --> Valor de Lancamento
                                     ,pr_dtmvtopg  IN tbtransf_trans_pend.dtdebito%TYPE               --> Data do Pagamento
                                     ,pr_idagenda  IN tbtransf_trans_pend.idagendamento%TYPE          --> Indicador de agendamento
                                     ,pr_cdageban  IN tbtransf_trans_pend.cdagencia_coop_destino%TYPE --> Codigo da agencia bancaria
                                     ,pr_nrctadst  IN tbtransf_trans_pend.nrconta_destino%TYPE        --> Conta de destino
                                     ,pr_lsdatagd  IN VARCHAR2                                        --> Lista de datas para agendamento
                                     ,pr_idastcjt  IN crapass.idastcjt%TYPE                           --> Indicador de Assinatura Conjunta
									 ,pr_flmobile  IN tbtransf_trans_pend.indmobile%TYPE              --> Indicador Mobile
									 ,pr_idtipcar  IN tbtransf_trans_pend.indtipo_cartao%TYPE         --> Indicador Tipo Cartão Utilizado
									 ,pr_nrcartao  IN tbtransf_trans_pend.nrcartao%TYPE               --> Numero Cartao
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE                           --> Codigo de Critica
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE);                         --> Descricao de Critica  

  -- Procedure de criacao de transacao de credito pré-aprovado
  PROCEDURE pc_cria_trans_pend_credito(pr_cdagenci  IN crapage.cdagenci%TYPE                   --> Codigo do PA
                                      ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                   --> Numero do Caixa
                                      ,pr_cdoperad  IN crapope.cdoperad%TYPE                   --> Codigo do Operados
                                      ,pr_nmdatela  IN craptel.nmdatela%TYPE                   --> Nome da Tela
                                      ,pr_idorigem  IN INTEGER                                 --> Origem da solicitacao
                                      ,pr_idseqttl  IN crapttl.idseqttl%TYPE                   --> Sequencial de Titular               
                                      ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                   --> Numero do cpf do operador juridico
                                      ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                   --> Numero do cpf do representante legal
                                      ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE          --> Cooperativa do Terminal
                                      ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE          --> Agencia do Terminal
                                      ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE          --> Numero do Terminal Financeiro
                                      ,pr_dtmvtolt  IN DATE                                    --> Data do movimento     
                                      ,pr_cdcooper  IN tbtransf_trans_pend.cdcooper%TYPE       --> Codigo da cooperativa
                                      ,pr_nrdconta  IN tbtransf_trans_pend.nrdconta%TYPE       --> Numero da Conta
                                      ,pr_vlemprst  IN tbepr_trans_pend.vlemprestimo%TYPE      --> Valor do emprestimo
                                      ,pr_qtpreemp  IN tbepr_trans_pend.nrparcelas%TYPE        --> Numero de parcelas
                                      ,pr_vlpreemp  IN tbepr_trans_pend.vlparcela%TYPE         --> Valor da parcela
                                      ,pr_dtdpagto  IN tbepr_trans_pend.dtprimeiro_vencto%TYPE --> Data de vencimento da primeira parcela	
                                      ,pr_percetop  IN tbepr_trans_pend.vlpercentual_cet%TYPE  --> Valor percentual do CET
                                      ,pr_vlrtarif  IN tbepr_trans_pend.vltarifa%TYPE          --> Valor da tarifa do emprestimo
                                      ,pr_txmensal  IN tbepr_trans_pend.vltaxa_mensal%TYPE     --> Valor da taxa mensal de juros
                                      ,pr_vltariof  IN tbepr_trans_pend.vliof%TYPE             --> Valor de IOF
                                      ,pr_vltaxiof  IN tbepr_trans_pend.vlpercentual_iof%TYPE  --> Valor percentual do IOF
                                      ,pr_idastcjt  IN crapass.idastcjt%TYPE                   --> Indicador de Assinatura Conjunta
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE                   --> Codigo de Critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE);                 --> Descricao de Critica

  -- Procedure de criacao de transacao de aplicacoes
  PROCEDURE pc_cria_trans_pend_aplica(pr_cdagenci  IN crapage.cdagenci%TYPE                        --> Codigo do PA
                                     ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                        --> Numero do Caixa
                                     ,pr_cdoperad  IN crapope.cdoperad%TYPE                        --> Codigo do Operados
                                     ,pr_nmdatela  IN craptel.nmdatela%TYPE                        --> Nome da Tela
                                     ,pr_idorigem  IN INTEGER                                      --> Origem da solicitacao
                                     ,pr_idseqttl  IN crapttl.idseqttl%TYPE                        --> Sequencial de Titular               
                                     ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                        --> Numero do cpf do operador juridico
                                     ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                        --> Numero do cpf do representante legal
                                     ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE               --> Cooperativa do Terminal
                                     ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE               --> Agencia do Terminal
                                     ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE               --> Numero do Terminal Financeiro
                                     ,pr_dtmvtolt  IN DATE                                         --> Data do movimento     
                                     ,pr_cdcooper  IN tbtransf_trans_pend.cdcooper%TYPE            --> Codigo da cooperativa
                                     ,pr_nrdconta  IN tbtransf_trans_pend.nrdconta%TYPE            --> Numero da Conta
                                     ,pr_idoperac  IN tbcapt_trans_pend.tpoperacao%TYPE            --> Identifica tipo da operacao (1 – Cancelamento Aplicacao / 2 – Resgate / 3 – Agendamento Resgate / 4 – Cancelamento Total Agendamento / 5 – Cancelamento Item Agendamento)
                                     ,pr_idtipapl  IN tbcapt_trans_pend.tpaplicacao%TYPE           --> Tipo da aplicacao (A – Antigos Produtos / N – Novos Produtos)
                                     ,pr_nraplica  IN tbcapt_trans_pend.nraplicacao%TYPE           --> Numero da aplicacao
                                     ,pr_cdprodut  IN tbcapt_trans_pend.cdproduto_aplicacao%TYPE   --> Codigo do produto da aplicacao
                                     ,pr_tpresgat  IN tbcapt_trans_pend.tpresgate%TYPE             --> Indicador do tipo de resgate (1 – Parcial / 2 – Total)
                                     ,pr_vlresgat  IN tbcapt_trans_pend.vlresgate%TYPE             --> Valor do resgate
                                     ,pr_nrdocmto  IN tbcapt_trans_pend.nrdocto_agendamento%TYPE   --> Numero de documento do agendamento
                                     ,pr_idtipage  IN tbcapt_trans_pend.tpagendamento%TYPE         --> Identifica o tipo de agendamento (0 – Aplicacao / 1 – Resgate)
                                     ,pr_idperage  IN tbcapt_trans_pend.idperiodo_agendamento%TYPE --> Identifica a periodicidade do agendamento (0 – Unico / 1 – Mensal)
                                     ,pr_qtmesage  IN tbcapt_trans_pend.qtmeses_agendamento%TYPE   --> Quantidade de meses do agendamento
                                     ,pr_dtdiaage  IN tbcapt_trans_pend.nrdia_agendamento%TYPE     --> Dia em que o agendamento deve ser efetivado
                                     ,pr_dtiniage  IN tbcapt_trans_pend.dtinicio_agendamento%TYPE  --> Data de inicio do agendamento
                                     ,pr_idastcjt  IN crapass.idastcjt%TYPE                        --> Indicador de Assinatura Conjunta
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE                        --> Codigo de Critica
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE);                      --> Descricao de Critica

  -- Procedure de criacao de transacao de debitos automaticos
  PROCEDURE pc_cria_trans_pend_deb_aut(pr_cdagenci  IN crapage.cdagenci%TYPE                      --> Codigo do PA
                                      ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                      --> Numero do Caixa
                                      ,pr_cdoperad  IN crapope.cdoperad%TYPE                      --> Codigo do Operados
                                      ,pr_nmdatela  IN craptel.nmdatela%TYPE                      --> Nome da Tela
                                      ,pr_idorigem  IN INTEGER                                    --> Origem da solicitacao
                                      ,pr_idseqttl  IN crapttl.idseqttl%TYPE                      --> Sequencial de Titular               
                                      ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do operador juridico
                                      ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do representante legal
                                      ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE             --> Cooperativa do Terminal
                                      ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE             --> Agencia do Terminal
                                      ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE             --> Numero do Terminal Financeiro
                                      ,pr_dtmvtolt  IN DATE                                       --> Data do movimento     
                                      ,pr_cdcooper  IN tbtransf_trans_pend.cdcooper%TYPE          --> Codigo da cooperativa
                                      ,pr_nrdconta  IN tbtransf_trans_pend.nrdconta%TYPE          --> Numero da Conta
                                      ,pr_idoperac  IN tbconv_trans_pend.tpoperacao%TYPE          --> Identifica tipo da operacao (1 – Autorizacao Debito Automatico / 2 – Bloqueio Debito Automatico / 3 – Desbloqueio Debito Automatico)
                                      ,pr_cdhisdeb  IN tbconv_trans_pend.cdhist_convenio%TYPE     --> Codigo do historico do convenio
                                      ,pr_idconsum  IN tbconv_trans_pend.iddebito_automatico%TYPE --> Identificacao do debito automatico
                                      ,pr_dshisext  IN tbconv_trans_pend.dshist_debito%TYPE       --> Descricao complementar do historico do debito
                                      ,pr_vlmaxdeb  IN tbconv_trans_pend.vlmaximo_debito%TYPE     --> Valor maximo do debito
                                      ,pr_cdempcon  IN tbconv_trans_pend.cdconven%TYPE            --> Codigo do convenio
                                      ,pr_cdsegmto  IN tbconv_trans_pend.cdsegmento_conven%TYPE   --> Codigo do segmento do convenio
                                      ,pr_dtmvtopg  IN tbconv_trans_pend.dtdebito_fatura%TYPE     --> Data de debito automatico da fatura
                                      ,pr_nrdocmto  IN tbconv_trans_pend.nrdocumento_fatura%TYPE  --> Numero do documento da fatura
                                      ,pr_idastcjt  IN crapass.idastcjt%TYPE                      --> Indicador de Assinatura Conjunta
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE                      --> Codigo de Critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE);                    --> Descricao de Critica

  -- Procedure de criacao de transacao de folha de pagamento
  PROCEDURE pc_cria_trans_pend_folha(pr_cdagenci  IN crapage.cdagenci%TYPE                      --> Codigo do PA
                                    ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                      --> Numero do Caixa
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE                      --> Codigo do Operados
                                    ,pr_nmdatela  IN craptel.nmdatela%TYPE                      --> Nome da Tela
                                    ,pr_idorigem  IN INTEGER                                    --> Origem da solicitacao
                                    ,pr_idseqttl  IN crapttl.idseqttl%TYPE                      --> Sequencial de Titular               
                                    ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do operador juridico
                                    ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do representante legal
                                    ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE             --> Cooperativa do Terminal
                                    ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE             --> Agencia do Terminal
                                    ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE             --> Numero do Terminal Financeiro
                                    ,pr_dtmvtolt  IN DATE                                       --> Data do movimento     
                                    ,pr_cdcooper  IN tbtransf_trans_pend.cdcooper%TYPE          --> Codigo da cooperativa
                                    ,pr_nrdconta  IN tbtransf_trans_pend.nrdconta%TYPE          --> Numero da Conta
                                    ,pr_flsolest  IN tbfolha_trans_pend.idestouro%TYPE          --> Indicador de solicitacao de estouro de conta (0 – Nao / 1 – Sim)
                                    ,pr_indrowid  IN VARCHAR2                                   --> Lista de ROWIDS
                                    ,pr_idastcjt  IN crapass.idastcjt%TYPE                      --> Indicador de Assinatura Conjunta
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE                      --> Codigo de Critica
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE);                    --> Descricao de Critica
	
	--> Rotina para criação de transação pendente de pacote de tarifas															
  PROCEDURE pc_cria_trans_pend_pacote_tar (pr_cdagenci  IN crapage.cdagenci%TYPE                      --> Codigo do PA
																					,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                      --> Numero do Caixa
																					,pr_cdoperad  IN crapope.cdoperad%TYPE                      --> Codigo do Operados
																					,pr_nmdatela  IN craptel.nmdatela%TYPE                      --> Nome da Tela
																					,pr_idorigem  IN INTEGER                                    --> Origem da solicitacao
																					,pr_idseqttl  IN crapttl.idseqttl%TYPE                      --> Sequencial de Titular               
																					,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do operador juridico
																					,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do representante legal
																					,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE             --> Cooperativa do Terminal
																					,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE             --> Agencia do Terminal
																					,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE             --> Numero do Terminal Financeiro
																					,pr_dtmvtolt  IN DATE                                       --> Data do movimento     
																					,pr_cdcooper  IN tbtarif_pacote_trans_pend.cdcooper%TYPE    --> Codigo da cooperativa
																					,pr_nrdconta  IN tbtarif_pacote_trans_pend.nrdconta%TYPE    --> Numero da Conta
																					,pr_cdpacote  IN tbtarif_pacote_trans_pend.cdpacote%TYPE    --> Cód. pacote de tarifas
																					,pr_dtvigenc  IN tbtarif_pacote_trans_pend.dtinicio_vigencia%TYPE--> Data de inicio de vigencia
																					,pr_dtdiadbt  IN tbtarif_pacote_trans_pend.nrdiadebito%TYPE     --> Dia débito
																					,pr_vlpacote  IN tbtarif_pacote_trans_pend.vlpacote%TYPE
																					,pr_idastcjt  IN crapass.idastcjt%TYPE                      --> Indicador de Assinatura Conjunta
																					,pr_cdcritic OUT crapcri.cdcritic%TYPE                      --> Codigo de Critica
																					,pr_dscritic OUT crapcri.dscritic%TYPE);                    --> Descricao de Critica																		
  
  --> Rotina responsavel por controlar criação do registro de transação de operador juridico(craptoj)
  PROCEDURE pc_cria_transacao_operador(pr_cdagenci   IN crapage.cdagenci%TYPE                        --> Codigo do PA
                                      ,pr_nrdcaixa   IN craplot.nrdcaixa%TYPE                        --> Numero do Caixa
                                      ,pr_cdoperad   IN crapope.cdoperad%TYPE                        --> Codigo do Operados
                                      ,pr_nmdatela   IN craptel.nmdatela%TYPE                        --> Nome da Tela
                                      ,pr_idorigem   IN INTEGER                                      --> Origem da solicitacao
                                      ,pr_idseqttl   IN crapttl.idseqttl%TYPE                        --> Sequencial de Titular               
                                      ,pr_cdcooper   IN crapcop.cdcooper%TYPE                        --> Codigo da cooperativa
                                      ,pr_nrdconta   IN crapass.nrdconta%TYPE                        --> Numero da conta    
                                      ,pr_nrcpfope   IN crapopi.nrcpfope%TYPE                        --> Numero do cpf do operador juridico
                                      ,pr_nrcpfrep   IN tbgen_trans_pend.nrcpf_representante%TYPE    --> Numero do cpf do representante legal
                                      ,pr_cdcoptfn   IN tbgen_trans_pend.cdcoptfn%TYPE               --> Cooperativa do Terminal
                                      ,pr_cdagetfn   IN tbgen_trans_pend.cdagetfn%TYPE               --> Agencia do Terminal
                                      ,pr_nrterfin   IN tbgen_trans_pend.nrterfin%TYPE               --> Numero do Terminal Financeiro
                                      ,pr_dtmvtolt   IN DATE                                         --> Data do movimento     
                                      ,pr_cdtiptra   IN INTEGER                                      --> Codigo do tipo de transação    
                                      ,pr_idastcjt   IN crapass.idastcjt%TYPE                        --> Indicador de Assinatura Conjunta
                                      ,pr_tab_crapavt OUT CADA0001.typ_tab_crapavt_58 
                                      ,pr_cdtranpe  OUT tbfolha_trans_pend.cdtransacao_pendente%TYPE --> Codigo tipo da transacao
                                      ,pr_dscritic  OUT VARCHAR2);                                   --> Descrição da crítica       
  
  -- Rotina para obter o horario limite das aprovacoes de transacoes pendentes
  PROCEDURE pc_horario_trans_pend( pr_cdcooper  IN crapsnh.cdcooper%TYPE
                                  ,pr_cdagenci  IN crapass.cdagenci%TYPE
                                  ,pr_cdoperad  IN crapope.cdoperad%TYPE
                                  ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE
                                  ,pr_nmdatela  IN craptel.nmdatela%TYPE
                                  ,pr_idorigem  IN INTEGER
                                  ,pr_tab_limite_pend OUT INET0002.typ_tab_limite_pend --Tabelas de retorno de horarios limite transacoes pendente
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                  ,pr_dscritic OUT crapcri.dscritic%TYPE);
                                  
  --> Rotina responsavel pela consulta de ROWID 
  PROCEDURE pc_obtem_rowid_folha(pr_cdcooper  IN crappfp.cdcooper%TYPE   --> Codigo da cooperativa
                                ,pr_cdempres  IN crappfp.cdempres%TYPE   --> Codigo da empresa
                                ,pr_nrseqpag  IN crappfp.nrseqpag%TYPE   --> Sequencia de folha de pagamento
                                ,pr_rowidpag OUT VARCHAR2                --> ROWID da folha de pagamento
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Codigo de Critica
                                ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descricao de Critica

  --> Rotina responsavel pela Busca de Informacoes das Transacoes Pendentes 
  PROCEDURE pc_busca_trans_pend(pr_cdcooper IN  crapcop.cdcooper%TYPE --> Código da Cooperativa
                               ,pr_nrdconta IN  crapass.nrdconta%TYPE --> Numero conta
                               ,pr_idseqttl IN  crapsnh.idseqttl%TYPE --> Titularidade 
                               ,pr_nrcpfope IN  crapsnh.nrcpfcgc%TYPE --> CPF operador
                               ,pr_cdagenci IN  crapage.cdagenci%TYPE --> Numero PA
                               ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE --> Data Movimentacao
                               ,pr_cdorigem IN  INTEGER               --> Id de origem
                               ,pr_insittra IN  INTEGER               --> Id de situacao da transacao
                               ,pr_dtiniper IN  DATE                  --> Data Inicio
                               ,pr_dtfimper IN  DATE                  --> Data final
                               ,pr_nrregist IN  INTEGER               --> Numero da qtd de registros da pagina
                               ,pr_nriniseq IN  INTEGER               --> Numero do registro inicial
                               ,pr_clobxmlc OUT CLOB                  --> XML com informações
                               ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2);            --> Descricao da crítica

  --> Rotina responsavel pela criacao de transacoes pendentes de DARF/DAS
  PROCEDURE pc_cria_trans_pend_darf_das(pr_cdcooper  IN crapcop.cdcooper%TYPE                 --> Código da cooperativa
                                       ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                 --> Numero do Caixa
                                       ,pr_cdoperad  IN crapope.cdoperad%TYPE                 --> Codigo do Operados
                                       ,pr_nmdatela  IN craptel.nmdatela%TYPE                 --> Nome da Tela
                                       ,pr_cdagenci  IN crapage.cdagenci%TYPE                 --> Código do PA
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE                 --> Número da conta
                                       ,pr_idseqttl  IN crapttl.idseqttl%TYPE                 --> Sequencial de titularidade
                                       ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                 --> Numero do cpf do representante legal
                                       ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE        --> Cooperativa do Terminal
                                       ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE        --> Agencia do Terminal
                                       ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE        --> Numero do Terminal Financeiro
                                       ,pr_nrcpfope  IN NUMBER								                --> CPF do operador PJ
                                       ,pr_idorigem  IN INTEGER							                  --> Canal de origem da operação
                                       ,pr_dtmvtolt  IN DATE                                  --> Data de Movimento Atual
                                       ,pr_tpdaguia  IN INTEGER							                  --> Tipo da guia (1 – DARF / 2 – DAS)
                                       ,pr_tpcaptur  IN INTEGER							                  --> Tipo de captura da guia (1 – Código Barras / 2 – Manual)
                                       ,pr_lindigi1  IN NUMBER							                  --> Primeiro campo da linha digitável da guia
                                       ,pr_lindigi2  IN NUMBER							                  --> Segundo campo da linha digitável da guia
                                       ,pr_lindigi3  IN NUMBER							                  --> Terceiro campo da linha digitável da guia
                                       ,pr_lindigi4  IN NUMBER 							                  --> Quarto campo da linha digitável da guia
                                       ,pr_cdbarras  IN VARCHAR2 						                  --> Código de barras da guia
                                       ,pr_dsidepag  IN VARCHAR2 						                  --> Descrição da identificação do pagamento
                                       ,pr_vlrtotal  IN NUMBER 							                  --> Valor total do pagamento da guia
                                       ,pr_dsnomfon  IN VARCHAR2 						                  --> Nome e telefone da guia
                                       ,pr_dtapurac  IN DATE 								                  --> Período de apuração da guia
                                       ,pr_nrcpfcgc  IN VARCHAR2 						                  --> CPF/CNPJ da guia
                                       ,pr_cdtribut  IN VARCHAR2 						                  --> Código de tributação da guia
                                       ,pr_nrrefere  IN VARCHAR2 						                  --> Número de referência da guia
                                       ,pr_dtvencto  IN DATE 								                  --> Data de vencimento da guia
                                       ,pr_vlrprinc  IN NUMBER 							                  --> Valor principal da guia
                                       ,pr_vlrmulta  IN NUMBER 							                  --> Valor da multa da guia
                                       ,pr_vlrjuros  IN NUMBER 							                  --> Valor dos juros da guia
                                       ,pr_vlrecbru  IN NUMBER 							                  --> Valor da receita bruta acumulada da guia
                                       ,pr_vlpercen  IN NUMBER 							                  --> Valor do percentual da guia
                                       ,pr_dtagenda  IN DATE 								                  --> Data de agendamento
                                       ,pr_idastcjt  IN crapass.idastcjt%TYPE                 --> Indicador de Assinatura Conjunta
                                       ,pr_idagenda  IN tbpagto_trans_pend.idagendamento%TYPE --> Indica se o pagamento foi agendado (1 – Online / 2 – Agendamento)
                                       ,pr_tpleitur  IN NUMBER                                --> Tipo da leitura do documento (1 – Leitora de Código de Barras / 2 - Manual)
                                       ,pr_cdcritic OUT INTEGER 						                  --> Código do erro
                                       ,pr_dscritic OUT VARCHAR2);      	                    --> Descriçao do erro

  PROCEDURE pc_busca_darf_das_car(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                 ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do Operador
                                 ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da Tela
                                 ,pr_idorigem IN INTEGER               --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                                 ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Titular da Conta
                                 ,pr_cdtrapen IN VARCHAR2              --> Codigo da Transacao
																 ,pr_clobxmlc OUT CLOB                 --> XML com informações de LOG
																 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
																 ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica

                                 
END INET0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.INET0002 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : INET0002
  --  Sistema  : Procedimentos Multiplas Assinaturas PJ
  --  Sigla    : CRED
  --  Autor    : Jorge Hamaguchi / Jean Deschamps
  --  Data     : Novembro/2015.                   Ultima atualizacao: 02/09/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos Multiplas Assinaturas PJ
  --
  -- Alteracoes: 24/11/2015 - Inclusao da procedure pc_inicia_senha_ass_conj para o
  --                          PRJ. Assinatura Conjunta (Jean Michel).
  --  
  --             16/02/2016 - Inclusao do parametro conta na chamada da
  --                          FOLH0001.fn_valor_tarifa_folha. (Jaison/Marcos)
  --  
  --    	       24/03/2016 - Adicionados parâmetros para geraçao de LOG na 'PC_CRIA_TRANS_PEND_TRANSF'
  --                          (Lucas Lunelli - PROJ290 Cartao CECRED no CaixaOnline)
  --
  --             20/06/2016 - Correcao para o uso da function fn_busca_dstextabem da TABE0001 em 
  --                          varias procedures desta package.(Carlos Rafael Tanholi).   
  --
  --             21/06/2016 - Ajuste para incluir alterações perdidas na realização de merge entre versões
  -- 					               (Adriano).
  --
  --             18/07/2016 - Criação da procedure pc_cria_trans_pend_darf_das para o
  --                          Prj. 338, Pagamento de DARF e DAS (Jean Michel)    
  --
  --             02/09/2016 - Ajustes na procedure pc_busca_trans_pend, SD 514239 (Jean Michel).                  	
                          

  ---------------------------------------------------------------------------------------------------------------

  
  /* Procedure para verificar horario permitido para transacoes */
  PROCEDURE pc_verifica_rep_assinatura (pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE --Conta do Associado
                                       ,pr_idseqttl IN crapttl.idseqttl%type  --Titularidade do Associado
                                       ,pr_cdorigem IN INTEGER                --Codigo Origem
                                       ,pr_idastcjt OUT crapass.idastcjt%TYPE --Codigo 1 exige Ass. Conj.
                                       ,pr_nrcpfcgc OUT crapass.nrcpfcgc%TYPE --CPF do Rep. Legal
                                       ,pr_nmprimtl OUT crapass.nmprimtl%TYPE --Nome do Rep. Legal          
                                       ,pr_flcartma OUT INTEGER               --Cartao Magnetico conjunta, 0 nao, 1 sim
                                       ,pr_cdcritic OUT INTEGER      --Codigo do erro
                                       ,pr_dscritic OUT VARCHAR2) IS --Descricao do erro
    
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_verifica_representante_assinatura
  --  Sistema  : Procedimentos para verificar o representando da assinatura
  --  Sigla    : CRED
  --  Autor    : Jorge Hamaguchi
  --  Data     : Novembro/2015.                   Ultima atualizacao: 00/00/0000
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para verificar o representando da assinatura
  --
  -- Alteração : 
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_nrdconta crapass.nrdconta%TYPE;
      vr_nmprintl crapass.nmprimtl%TYPE;
      vr_idastcjt crapass.idastcjt%TYPE;
      vr_nrcpfcgc crapass.nrcpfcgc%TYPE;
      vr_dtvalida crapavt.dtvalida%TYPE;
      
      --Variaveis de Erro
      vr_cdcritic crapcri.cdcritic%type;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
      
      
      /* Busca dos dados do associado */
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.idastcjt
              ,crapass.nmprimtl
              ,crapass.nrcpfppt
         FROM  crapass
         WHERE crapass.cdcooper = pr_cdcooper
         AND   crapass.nrdconta = pr_nrdconta;
      
      --Selecionar informacoes de senhas
      CURSOR cr_crapsnh (pr_cdcooper IN crapsnh.cdcooper%type
                        ,pr_nrdconta IN crapsnh.nrdconta%type
                        ,pr_idseqttl IN crapsnh.idseqttl%TYPE) IS
        SELECT crapsnh.nrcpfcgc
        FROM   crapsnh
        WHERE  crapsnh.cdcooper = pr_cdcooper
        AND    crapsnh.nrdconta = pr_nrdconta
        AND    crapsnh.idseqttl = pr_idseqttl
        AND    crapsnh.tpdsenha = 1; --Internet
      
      /* Busca do nome do representante/procurador */
      CURSOR cr_crapavt(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_nrcpfcgc IN crapsnh.nrcpfcgc%TYPE) IS
        SELECT crapavt.nrdctato,
               crapavt.nmdavali,
               crapavt.dtvalida
        FROM   crapavt
        WHERE  crapavt.cdcooper = pr_cdcooper
        AND    crapavt.nrdconta = pr_nrdconta
        AND    crapavt.nrcpfcgc = pr_nrcpfcgc
        AND    crapavt.tpctrato = 6; -- Juridico
      
      /* Busca se preposto do cartao magnetico eh responsavel pelo assinatura conjunta */
      CURSOR cr_crappod(pr_cdcooper IN crappod.cdcooper%TYPE
                       ,pr_nrdconta IN crappod.nrdconta%TYPE
                       ,pr_nrcpfcgc IN crappod.nrcpfpro%TYPE) IS
        SELECT crappod.nrdconta 
        FROM   crappod 
        WHERE  crappod.cdcooper = pr_cdcooper
        AND    crappod.nrdconta = pr_nrdconta
        AND    crappod.nrcpfpro = pr_nrcpfcgc
        AND    crappod.cddpoder = 10
        AND    crappod.flgconju = 1;
      
    ------------------------------------------------------
    -------------- INICIO BLOCO PRINCIPAL ----------------
    ------------------------------------------------------      
    BEGIN
      --Inicializar varaivel retorno erro
      vr_cdcritic:= NULL;
      vr_dscritic:= NULL;
      pr_flcartma:= 0;
      
      --Consulta se exige assinatura multipla na conta principal
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO pr_idastcjt --parametro de interesse
                           ,vr_nmprintl
                           ,pr_nrcpfcgc;
      --Se nao encontrou 
      IF cr_crapass%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapass;
          vr_cdcritic:= 0;
          vr_dscritic:= 'Registro do cooperado nao encontrado.';
          --Levantar Excecao
          RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapass;
      
      IF pr_cdorigem <> 4 THEN
          pr_nrcpfcgc := 0;      
      
		  IF (pr_idastcjt = 1 AND pr_idseqttl > 1) OR 
			 (pr_idastcjt = 0) THEN 

			 --Consulta do cpf do representante na crapsnh
			 OPEN cr_crapsnh(pr_cdcooper => pr_cdcooper
							,pr_nrdconta => pr_nrdconta
							,pr_idseqttl => pr_idseqttl);
			 FETCH cr_crapsnh INTO pr_nrcpfcgc;
			 --Se nao encontrou 
			 IF cr_crapsnh%NOTFOUND THEN
				--Fechar Cursor
				CLOSE cr_crapsnh;
				vr_cdcritic:= 0;
				vr_dscritic:= 'Registro de senha nao encontrado.';
				--Levantar Excecao
				RAISE vr_exc_erro;
      END IF;
			 --Fechar Cursor
			 CLOSE cr_crapsnh;
		  END IF;
      END IF;
	  
      IF pr_nrcpfcgc > 0 THEN
        --Consulta do nome
        OPEN cr_crapavt(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrcpfcgc => pr_nrcpfcgc);
        FETCH cr_crapavt INTO vr_nrdconta
                             ,pr_nmprimtl
                             ,vr_dtvalida;
        --Se nao encontrou 
        IF cr_crapavt%NOTFOUND THEN
            --Fechar Cursor
            CLOSE cr_crapavt;
            vr_cdcritic:= 0;
            vr_dscritic:= 'Registro do Representante nao encontrado.';
            --Levantar Excecao
            RAISE vr_exc_erro;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapavt;      
        
        --Se tiver conta, busca nome da crapass
        IF  vr_nrdconta > 0 THEN
            OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => vr_nrdconta);
            FETCH cr_crapass INTO vr_idastcjt
                                 ,pr_nmprimtl
                                 ,vr_nrcpfcgc;
            --Se nao encontrou 
            IF cr_crapass%NOTFOUND THEN
                --Fechar Cursor
                CLOSE cr_crapass;
                vr_cdcritic:= 0;
                vr_dscritic:= 'Registro do cooperado nao encontrado.2';
                --Levantar Excecao
                RAISE vr_exc_erro;
            END IF;
            --Fechar Cursor
            CLOSE cr_crapass;
        END IF;
        
        --Se for origem TAA, verificar preposto do cartao magnetico 
        IF pr_cdorigem = 4 THEN
			     OPEN cr_crappod(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrcpfcgc => pr_nrcpfcgc);
           FETCH cr_crappod INTO vr_nrdconta;
           --Se encontrou 
           IF cr_crappod%FOUND THEN
                --Atribui flga de cartao mag.
                pr_flcartma := 1;
                --Fechar Cursor
                CLOSE cr_crappod;
                --Verifica validade da atividade do representante
                IF vr_dtvalida < SYSDATE THEN
                   vr_dscritic := 'Operacao indisponivel. A vigencia da procuracao ou atividade de socio esta vencida.';
                   RAISE vr_exc_erro;
                END IF;
           ELSE
                --Fechar Cursor
                CLOSE cr_crappod;
           END IF;
        END IF;
           
      END IF; --IF pr_nrcpfcgc > 0 
      
    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina INET0002.pc_verifica_rep_assinatura. '||SQLERRM;
    END;
  END pc_verifica_rep_assinatura;
  
  PROCEDURE pc_inicia_senha_ass_conj(pr_cdcooper IN crappod.cdcooper%TYPE -- Codigo Cooperativa
                                    ,pr_nrdconta IN crappod.nrdconta%TYPE -- Numero da conta
                                    ,pr_nrcpfpro IN crappod.nrcpfpro%TYPE -- Numero do CPF do Procurador
                                    ,pr_cdoperad IN crapope.cdoperad%TYPE -- Codigo do Operador
                                    ,pr_cdcritic   OUT INTEGER            -- Codigo do erro
                                    ,pr_dscritic   OUT VARCHAR2) IS       -- Descricao do erro

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_inicia_senha_ass_conj           Antigo:
  --  Sistema  : Procedimentos para inicializar o registro de senha de acesso à Internet
  --  Sigla    : CRED
  --  Autor    : Jean Michel
  --  Data     : Novembro/2015.                   Ultima atualizacao: 24/11/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Chamada para ser utilizada no Progress -
  --             Procedure para para inicializar o registro de senha de acesso à Internet
  --
  -- Alteracoes:
  --
  --
  ---------------------------------------------------------------------------------------------------------------
  -------------------------> CURSORES <-------------------------
  BEGIN
  DECLARE  
  -- Selecionar senhas
  CURSOR cr_crapsnh (pr_cdcooper IN crapsnh.cdcooper%TYPE
                    ,pr_nrdconta IN crapsnh.nrdconta%TYPE
                    ,pr_nrcpfpro IN crapsnh.nrcpfcgc%TYPE) IS
    SELECT crapsnh.idseqttl
      FROM crapsnh
     WHERE crapsnh.cdcooper = pr_cdcooper AND
           crapsnh.nrdconta = pr_nrdconta AND
           crapsnh.tpdsenha = 1 /* INTERNET */  AND
           crapsnh.nrcpfcgc = pr_nrcpfpro;

  rw_crapsnh cr_crapsnh%ROWTYPE;

  -- Selecionar maximo idseqttl de senhas
  CURSOR cr_crapsnh_max(pr_cdcooper IN crapsnh.cdcooper%TYPE
                       ,pr_nrdconta IN crapsnh.nrdconta%TYPE
                       ,pr_tpdsenha IN crapsnh.tpdsenha%TYPE) IS

    SELECT /*+index_desc (crapsnh CRAPSNH##CRAPSNH1)*/ 
           crapsnh.idseqttl
          ,ROWID 
      FROM crapsnh
      WHERE crapsnh.cdcooper = pr_cdcooper
        AND crapsnh.nrdconta = pr_nrdconta
        AND crapsnh.tpdsenha = pr_tpdsenha;

  rw_crapsnh_max cr_crapsnh_max%ROWTYPE;
  
  -------------------------> VARIAVEIS <-------------------------    
  
    vr_cdcritic crapcri.cdcritic%TYPE;  
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_saida EXCEPTION;
    vr_idseqttl crapsnh.idseqttl%TYPE;

  BEGIN

    OPEN cr_crapsnh(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta 
                   ,pr_nrcpfpro => pr_nrcpfpro);
    
    FETCH cr_crapsnh INTO rw_crapsnh;

    --Se nao encontrou
    IF cr_crapsnh%NOTFOUND THEN
      -- Fecha cursor
      CLOSE cr_crapsnh;

      OPEN cr_crapsnh_max(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta 
                         ,pr_tpdsenha => 1);

      FETCH cr_crapsnh_max INTO rw_crapsnh_max;

      IF cr_crapsnh_max%NOTFOUND OR NVL(rw_crapsnh_max.idseqttl,0) = 0 THEN        
        -- Iniciar com sequência 2(idseqttl) devido ao registro de letras de cartão magnético
        vr_idseqttl := 2;
      ELSE
        vr_idseqttl := rw_crapsnh_max.idseqttl + 1;
      END IF;

      -- Fecha cursor
      CLOSE cr_crapsnh_max;

      BEGIN
        INSERT INTO
          crapsnh(
               cdcooper
              ,nrdconta
              ,tpdsenha
              ,idseqttl
              ,cdsitsnh
              ,cdoperad
              ,nrcpfcgc)
             VALUES(
               pr_cdcooper
              ,pr_nrdconta
              ,1
              ,vr_idseqttl
              ,0
              ,pr_cdoperad
              ,pr_nrcpfpro);
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao incluir registro de senha(CRAPSNH). Erro: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
    ELSE
      -- Fecha cursor
      CLOSE cr_crapsnh;  
    END IF;

   EXCEPTION
    WHEN vr_exc_saida THEN
      IF NVL(vr_cdcritic,0) > 0 THEN    
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral em PC_INICIA_SENHA_ASS_CONJ. Erro: ' || SQLERRM;
   END;         
  END pc_inicia_senha_ass_conj; 

  PROCEDURE pc_verifica_validade_procurac(pr_cdcooper IN crapcop.cdcooper%TYPE  -- Código cooperativa
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE  -- Nr. da Conta
                                         ,pr_inpessoa IN crapass.inpessoa%TYPE  -- PF/PJ
                                         ,pr_idseqttl IN crapttl.idseqttl%TYPE  -- Sequencia do titular
                                         ,pr_nrcpfcgc IN crapavt.nrcpfcgc%TYPE  -- Nr. CPF/CNPJ
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE -- Cód. Crítica
                                         ,pr_dscritic OUT VARCHAR2) IS          -- Descrição da crítica
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_verifica_validade_procurac
  --  Sistema  : INET0002
  --  Sigla    : CRED
  --  Autor    : Lucas Reinert
  --  Data     : Novembro/2015.                   Ultima atualizacao: 00/00/0000
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para verificar a validade da procuração
  --
  -- Alteração : 
  --
  ---------------------------------------------------------------------------------------------------------------
	BEGIN
  DECLARE
	
  vr_qtmespro NUMBER;
	vr_dsdmensg VARCHAR2(32000) := ' ';
	
	-- Tratamento de críticas
	vr_dscritic crapcri.dscritic%TYPE;
	vr_cdcritic crapcri.cdcritic%type;
	vr_exc_saida EXCEPTION;	
	
  -- Guardar registro dstextab
  vr_dstextab craptab.dstextab%TYPE;
	
	rw_crapdat btch0001.cr_crapdat%ROWTYPE;
	
	CURSOR cr_crapavt IS
    SELECT avt.idmsgvct
		      ,avt.dtvalida
					,avt.ROWID
		  FROM crapavt avt
		 WHERE avt.cdcooper = pr_cdcooper
		   AND avt.nrdconta = pr_nrdconta
			 AND avt.tpctrato = 6
			 AND avt.nrcpfcgc = pr_nrcpfcgc;
	rw_crapavt cr_crapavt%ROWTYPE;
	
	-- Busca quantidade de meses para o vencimento da procuração
	CURSOR cr_craptab IS
		SELECT gene0002.fn_busca_entrada(pr_postext => 29
																		,pr_dstext => tab.dstextab
																		,pr_delimitador => ';')
		FROM craptab tab																
	 WHERE tab.cdcooper = pr_cdcooper AND
				 tab.nmsistem = 'CRED'       AND
				 tab.tptabela = 'GENERI'     AND
				 tab.cdempres = 0            AND
				 tab.cdacesso = 'LIMINTERNT' AND
				 tab.tpregist = pr_inpessoa;
				 
	-- Busca nome do titular
	CURSOR cr_crapass IS
	  SELECT ass.nmprimtl
		  FROM crapass ass
		 WHERE ass.cdcooper = pr_cdcooper
		   AND ass.nrdconta = pr_nrdconta;
	rw_crapass cr_crapass%ROWTYPE;
	
	-- Buscar nome da cooperativa
	CURSOR cr_crapcop IS
	  SELECT cop.nmrescop
		  FROM crapcop cop
		 WHERE cop.cdcooper = pr_cdcooper;
	rw_crapcop cr_crapcop%ROWTYPE;
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
	
		-- Busca parametro de quantidade de meses para o vencimento da procuração
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'GENERI'
                                             ,pr_cdempres => 0
                                             ,pr_cdacesso => 'LIMINTERNT'
                                             ,pr_tpregist => pr_inpessoa);       
                                             
    vr_qtmespro := gene0002.fn_busca_entrada(pr_postext => 29
    																		    ,pr_dstext => vr_dstextab
																		        ,pr_delimitador => ';');  				

		-- Busca representante
		OPEN cr_crapavt;
		FETCH cr_crapavt INTO rw_crapavt;
				
		IF cr_crapavt%FOUND THEN
      CLOSE cr_crapavt;
			-- Verifica se a mensagem ainda não foi gerada
			IF rw_crapavt.idmsgvct = 0 THEN
				-- Se a procuração vencerá
				IF rw_crapdat.dtmvtolt > add_months(rw_crapavt.dtvalida, - vr_qtmespro) THEN
						   
					 OPEN cr_crapass;
					 FETCH cr_crapass INTO rw_crapass;		 
           CLOSE cr_crapass;

					 OPEN cr_crapcop;
					 FETCH cr_crapcop INTO rw_crapcop;
					 CLOSE cr_crapcop;
	
					 vr_dsdmensg := 'Atenção, ' || TO_CHAR(rw_crapass.nmprimtl) || '!'  ||
													'<br><br>Informamos que sua atividade como sócio(a) ou procuração possui data de '  ||
													'vencimento para <b>' || to_char(rw_crapavt.dtvalida, 'dd/mm/rrrr') || '</b>.<br><br>' ||
													'A partir do vencimento as operações que exigem assinatura eletrônica '     ||
													'serão bloqueadas.';
					 -- Gerar mensagem
					 gene0003.pc_gerar_mensagem(pr_cdcooper => pr_cdcooper
																		 ,pr_nrdconta => pr_nrdconta
																		 ,pr_idseqttl => pr_idseqttl
																		 ,pr_cdprogra => 'INET0002'
																		 ,pr_inpriori => 0
																		 ,pr_dsdmensg => vr_dsdmensg
																		 ,pr_dsdassun => 'Vencimento Representação/Procuração'
																		 ,pr_dsdremet => rw_crapcop.nmrescop
																		 ,pr_dsdplchv => 'Vencimento Procuração'
																		 ,pr_cdoperad => 1
																		 ,pr_cdcadmsg => 0
																		 ,pr_dscritic => vr_dscritic);
																				 
						IF vr_dscritic IS NOT NULL THEN
							RAISE vr_exc_saida;
              CLOSE cr_crapavt;
						END IF;
				      
					 -- Indicar que mensagem já foi gerada
					 UPDATE crapavt
             SET crapavt.idmsgvct = 1
					   WHERE crapavt.rowid = rw_crapavt.rowid;							 
				END IF;
		  END IF;
    ELSE
      CLOSE cr_crapavt;  
		END IF;	 
		
		COMMIT;
	
	 EXCEPTION
		WHEN vr_exc_saida THEN
      
      pr_cdcritic := vr_cdcritic;
			IF vr_cdcritic <> 0 THEN
			   pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
			ELSE	
			   pr_dscritic := vr_dscritic;
		  END IF;
		WHEN OTHERS THEN
      pr_dscritic := 'Erro geral em PC_VERIFICA_VALIDADE_PROCURAC. Erro: ' || SQLERRM;
   END;
	END pc_verifica_validade_procurac;

  /* Procedure para excluir transacoes pendentes */
  PROCEDURE pc_exclui_trans_pend (pr_cdcooper IN crapcop.cdcooper%TYPE  --Codigo Cooperativa
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE  --Conta do Associado
                                 ,pr_nrdcaixa IN INTEGER                --Numero do caixa
                                 ,pr_cdagenci IN INTEGER                --Numero da agencia
                                 ,pr_cdoperad IN VARCHAR2               --Numero do operador
                                 ,pr_dtmvtolt IN DATE                   --Data da operacao
                                 ,pr_cdorigem IN INTEGER                --Codigo Origem
                                 ,pr_nmdatela IN VARCHAR2               --Nome da tela
                                 ,pr_cdditens IN VARCHAR2               --Itens
                                 ,pr_nrcpfope IN NUMBER                 --CPF do operador
                                 ,pr_flgerlog IN INTEGER                --Flag de log
                                 ,pr_cdcritic OUT INTEGER               --Codigo do erro
                                 ,pr_dscritic OUT VARCHAR2) IS          --Descricao do erro
    
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_exclui_trans_pend
  --  Sistema  : Procedimentos para excluir transacoes pendentes
  --  Sigla    : CRED
  --  Autor    : Jorge Hamaguchi
  --  Data     : Novembro/2015.                   Ultima atualizacao: 00/00/0000
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para excluir transacoes pendentes
  --
  -- Alteração : 
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_dsorigem VARCHAR2(50);
      vr_dstransa VARCHAR2(100);
      vr_idastcjt NUMBER;
      vr_nrcpfcgc NUMBER(14);
      vr_nrdctato crapavt.nrdctato%TYPE;
      vr_nmprimtl crapass.nmprimtl%TYPE;
      vr_cddoitem tbgen_trans_pend.cdtransacao_pendente%TYPE;
      -- Array para guardar o split dos dados contidos na dstextab
      vr_cdditens gene0002.typ_split;
      vr_auxditem gene0002.typ_split;
      -- Rowid tabela de log
      vr_nrdrowid ROWID;
      
      --Variaveis de Erro
      vr_cdcritic crapcri.cdcritic%type;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
  
      /* Busca dos dados do associado */
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.idastcjt,
               crapass.nmprimtl
        FROM   crapass
        WHERE  crapass.cdcooper = pr_cdcooper
        AND    crapass.nrdconta = pr_nrdconta;
      
      --Selecionar informacoes de senhas
      CURSOR cr_crapsnh (pr_cdcooper IN crapsnh.cdcooper%TYPE
                        ,pr_nrdconta IN crapsnh.nrdconta%TYPE) IS
        SELECT crapsnh.nrcpfcgc
        FROM   crapsnh
        WHERE  crapsnh.cdcooper = pr_cdcooper
        AND    crapsnh.nrdconta = pr_nrdconta
        AND    crapsnh.idseqttl = 1
        AND    crapsnh.tpdsenha = 1; --Internet
              
      /* Busca do nome do representante/procurador */
      CURSOR cr_crapavt(pr_cdcooper IN crapavt.cdcooper%TYPE
                       ,pr_nrdconta IN crapavt.nrdconta%TYPE
                       ,pr_nrcpfcgc IN crapavt.nrcpfcgc%TYPE) IS
        SELECT crapavt.nrdctato,
               crapavt.nmdavali
        FROM   crapavt
        WHERE  crapavt.cdcooper = pr_cdcooper
        AND    crapavt.nrdconta = pr_nrdconta
        AND    crapavt.nrcpfcgc = pr_nrcpfcgc
        AND    crapavt.tpctrato = 6; -- Juridico
      
      CURSOR cr_tbgen_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
        SELECT tbgen_trans_pend.nrcpf_operador,
               tbgen_trans_pend.idsituacao_transacao,
               tbgen_trans_pend.cdtransacao_pendente
        FROM   tbgen_trans_pend 
        WHERE  tbgen_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbgen_trans_pend cr_tbgen_trans_pend%ROWTYPE;
    ------------------------------------------------------
    -------------- INICIO BLOCO PRINCIPAL ----------------
    ------------------------------------------------------      
    BEGIN
      --Inicializar varaivel retorno erro
      vr_cdcritic:= NULL;
      vr_dscritic:= NULL;
      
      IF pr_flgerlog = 1 THEN
        -- Buscar a origem
        vr_dsorigem:= gene0001.vr_vet_des_origens(pr_cdorigem);
        -- Buscar Transacao
        vr_dstransa:= 'Excluir transacoes de operadores de conta.';
      END IF;
      
      /* Dados da conta */
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO vr_idastcjt,
                            vr_nmprimtl;
      --Se nao encontrou 
      IF cr_crapass%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapass;
          vr_cdcritic:= 0;
          vr_dscritic:= 'Registro do cooperado nao encontrado.';
          --Levantar Excecao
          RAISE vr_exc_erro;
      ELSE
          --Fechar Cursor
          CLOSE cr_crapass;
      END IF;
      
      --Se conta nao exige assinatura multipla
      IF vr_idastcjt = 0 THEN
         --Consulta do cpf do representante na crapsnh
         OPEN cr_crapsnh(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta);
         FETCH cr_crapsnh INTO vr_nrcpfcgc;
         --Se nao encontrou 
         IF cr_crapsnh%NOTFOUND THEN
             --Fechar Cursor
             CLOSE cr_crapsnh;
             vr_cdcritic:= 0;
             vr_dscritic:= 'Registro de senha nao encontrado.';
             --Levantar Excecao
             RAISE vr_exc_erro;
         ELSE
             --Fechar Cursor
             CLOSE cr_crapsnh;
         END IF;  
      
         --Consulta do nome do Preposto
         OPEN cr_crapavt(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrcpfcgc => vr_nrcpfcgc);
         FETCH cr_crapavt INTO vr_nrdctato
                              ,vr_nmprimtl;
         --Se nao encontrou 
         IF cr_crapavt%NOTFOUND THEN
            --Fechar Cursor
              CLOSE cr_crapavt;
             vr_cdcritic:= 0;
             vr_dscritic:= 'Necessario habilitar um preposto.';
             --Levantar Excecao
             RAISE vr_exc_erro;
         ELSE                             
             --Fechar Cursor
             CLOSE cr_crapavt;      
         END IF;
      END IF;  
      
         
      vr_cdditens := GENE0002.fn_quebra_string(pr_string  => pr_cdditens, 
                                               pr_delimit => '/');
      
      FOR i IN vr_cdditens.FIRST..vr_cdditens.LAST LOOP
         vr_auxditem := GENE0002.fn_quebra_string(pr_string  => vr_cdditens(i), 
                                                  pr_delimit => '|');
         vr_auxditem := GENE0002.fn_quebra_string(pr_string  => vr_auxditem(1), 
                                                  pr_delimit => ',');
         vr_cddoitem := TO_NUMBER(vr_auxditem(3));
         OPEN cr_tbgen_trans_pend(pr_cddoitem => vr_cddoitem);
         FETCH cr_tbgen_trans_pend INTO rw_tbgen_trans_pend;   
         
         IF cr_tbgen_trans_pend%FOUND THEN
            CLOSE cr_tbgen_trans_pend;
            -- Operador nao pode excluir transacao de outro operador.
            IF pr_nrcpfope > 0 AND rw_tbgen_trans_pend.nrcpf_operador <> pr_nrcpfope THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'Transacao nao pode ser excluida pelo operador.';
               --Levantar Excecao
               RAISE vr_exc_erro;
            END IF;
			
			      IF rw_tbgen_trans_pend.idsituacao_transacao <> 1 THEN
			         vr_cdcritic:= 0;
               vr_dscritic:= 'Somente Transacoes pendentes podem ser excluidas.';
               --Levantar Excecao
               RAISE vr_exc_erro;
		        END IF;
            
            IF vr_nrdctato > 0 THEN
              OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => vr_nrdctato);
              FETCH cr_crapass INTO vr_idastcjt,
                                    vr_nmprimtl;
              --Se nao encontrou 
              IF cr_crapass%NOTFOUND THEN
                  --Fechar Cursor
                  CLOSE cr_crapass;
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Registro do cooperado nao encontrado.';
                  --Levantar Excecao
                  RAISE vr_exc_erro;
              ELSE 
                  --Fechar Cursor
                  CLOSE cr_crapass;
              END IF;
            END IF;
            
            UPDATE tbgen_trans_pend SET 
                   tbgen_trans_pend.idsituacao_transacao = 3, /* Excluída */
                   tbgen_trans_pend.dtalteracao_situacao = trunc(SYSDATE)
             WHERE tbgen_trans_pend.cdtransacao_pendente = vr_cddoitem;
            
            /* Alimentar dados do preposto somente se ele efetuar a exclusao */
            IF  pr_nrcpfope = 0  THEN
                UPDATE tbgen_trans_pend SET 
                       tbgen_trans_pend.nrcpf_representante  = vr_nrcpfcgc
                 WHERE tbgen_trans_pend.cdtransacao_pendente = vr_cddoitem;
            END IF;
         ELSE
            CLOSE cr_tbgen_trans_pend;
         END IF;
      END LOOP;
      
      IF  pr_flgerlog = 1 THEN
          
          FOR i IN vr_cdditens.FIRST..vr_cdditens.LAST LOOP
              vr_auxditem := GENE0002.fn_quebra_string(pr_string  => vr_cdditens(i), 
                                                       pr_delimit => '|');
              vr_auxditem := GENE0002.fn_quebra_string(pr_string  => vr_auxditem(1), 
                                                       pr_delimit => ',');
              vr_cddoitem := TO_NUMBER(vr_auxditem(3));
              
              OPEN cr_tbgen_trans_pend(pr_cddoitem => vr_cddoitem);
              FETCH cr_tbgen_trans_pend INTO rw_tbgen_trans_pend;
              
              IF cr_tbgen_trans_pend%FOUND THEN
                CLOSE cr_tbgen_trans_pend;
                gene0001.pc_gera_log( pr_cdcooper => pr_cdcooper
                                     ,pr_cdoperad => pr_cdoperad 
                                     ,pr_dscritic => ''         
                                     ,pr_dsorigem => vr_dsorigem
                                     ,pr_dstransa => vr_dstransa
                                     ,pr_dttransa => pr_dtmvtolt
                                     ,pr_flgtrans => 1
                                     ,pr_hrtransa => gene0002.fn_busca_time
                                     ,pr_idseqttl => 1
                                     ,pr_nmdatela => pr_nmdatela
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrdrowid => vr_nrdrowid);
                               
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                          pr_nmdcampo => 'Codigo da Transacao Pendente', 
                                          pr_dsdadant => '', 
                                          pr_dsdadatu => TO_CHAR( rw_tbgen_trans_pend.cdtransacao_pendente));
                
                IF vr_idastcjt = 0 THEN
                  gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                            pr_nmdcampo => 'Nome do Preposto', 
                                            pr_dsdadant => '', 
                                            pr_dsdadatu => vr_nmprimtl);
                                            
                  gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                            pr_nmdcampo => 'CPF do Preposto', 
                                            pr_dsdadant => '', 
                                            pr_dsdadatu => TO_CHAR( vr_nrcpfcgc));
                END IF;
              ELSE
                CLOSE cr_tbgen_trans_pend;                             
              END IF;
          END LOOP;
      END IF;
      
      COMMIT;
      
    EXCEPTION
       WHEN vr_exc_erro THEN
            pr_cdcritic:= vr_cdcritic;
            pr_dscritic:= vr_dscritic;
		        ROLLBACK;
       WHEN OTHERS THEN
            pr_cdcritic:= 0;
            pr_dscritic:= 'Erro na rotina INET0002.pc_verifica_rep_assinatura. '||SQLERRM;
		        ROLLBACK;
    END;
  END pc_exclui_trans_pend;

  --> Rotina responsavel pela criacao de registros de aprovacao
  PROCEDURE pc_cria_aprova_transpend(pr_cdagenci    IN crapage.cdagenci%TYPE                        --> Codigo do PA
                                    ,pr_nrdcaixa    IN craplot.nrdcaixa%TYPE                        --> Numero do Caixa
                                    ,pr_cdoperad    IN crapope.cdoperad%TYPE                        --> Codigo do Operados
                                    ,pr_nmdatela    IN craptel.nmdatela%TYPE                        --> Nome da Tela
                                    ,pr_idorigem    IN INTEGER                                      --> Origem da solicitacao
                                    ,pr_idseqttl    IN crapttl.idseqttl%TYPE                        --> Sequencial de Titular               
                                    ,pr_cdcooper    IN crapcop.cdcooper%TYPE                        --> Codigo da cooperativa
                                    ,pr_nrdconta    IN crapass.nrdconta%TYPE                        --> Numero da conta    
                                    ,pr_nrcpfrep    IN tbgen_trans_pend.nrcpf_representante%TYPE    --> Numero do cpf do representante legal
                                    ,pr_dtmvtolt    IN DATE                                         --> Data do movimento     
                                    ,pr_cdtiptra    IN INTEGER                                      --> Codigo do tipo de transação    
                                    ,pr_cdtranpe    IN tbfolha_trans_pend.cdtransacao_pendente%TYPE --> Codigo tipo da transacao
                                    ,pr_tab_crapavt IN CADA0001.typ_tab_crapavt_58                  --> Tabela de procuradore
                                    ,pr_cdcritic  OUT INTEGER                                       --> Codigo da critica
                                    ,pr_dscritic  OUT VARCHAR2) IS                                  --> Descrição da crítica       

     /* .............................................................................

      Programa: pc_cria_aprova_transpend
      Sistema : Rotinas acessadas pelas telas de cadastros Web
      Sigla   : INET
      Autor   : Jean Michel
      Data    : Dezembro/2015.                  Ultima atualizacao: 22/12/2015

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina responsavel pela criacao de registros de aprovacao.
      Observacao: -----

      Alteracoes:      
     ..............................................................................*/ 
     ----------------> CURSORES <-----------------
      -- Buscar nome da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
   
      CURSOR cr_crapass IS
      SELECT
        ass.idastcjt
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    
    rw_crapass cr_crapass%ROWTYPE;

    CURSOR cr_crapsnh(pr_nrcpfcgc IN crapsnh.nrcpfcgc%TYPE) IS
      SELECT
        snh.idseqttl
        FROM crapsnh snh
       WHERE snh.cdcooper = pr_cdcooper
         AND snh.nrdconta = pr_nrdconta
         AND snh.nrcpfcgc = pr_nrcpfcgc
         AND snh.tpdsenha = 1;
    
    rw_crapsnh cr_crapsnh%ROWTYPE;

     ----------------> VARIAVEIS <-----------------
     vr_exc_saida EXCEPTION;
     vr_cdcritic  crapcri.cdcritic%TYPE; -- Codigo de erro
     vr_dscritic  crapcri.dscritic%TYPE; -- Retorno de Erro
     vr_dsdmensg  VARCHAR2(4000);
     vr_idsitapr  INTEGER; -- Situacao de Aprovacao
     vr_ind       INTEGER;
   BEGIN

    --Dados da Cooperativa
    OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
    
    --Se nao encontrou 
    IF cr_crapcop%NOTFOUND THEN 
       --Fechar Cursor
       CLOSE cr_crapcop;   
       
       vr_cdcritic:= 0;
       vr_dscritic:= 'Cooperativa nao encontrada.';
       --Levantar Excecao
       RAISE vr_exc_saida;
    END IF;
    
    --Fechar Cursor
    CLOSE cr_crapcop; 

    /*********/
    --Dados da Cooperativa
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;
    
    --Se nao encontrou 
    IF cr_crapass%NOTFOUND THEN 
       --Fechar Cursor
       CLOSE cr_crapass;   
       
       vr_cdcritic:= 0;
       vr_dscritic:= 'Cooperado nao encontrada.';
       --Levantar Excecao
       RAISE vr_exc_saida;
    END IF;
    
    --Fechar Cursor
    CLOSE cr_crapass;

    FOR vr_ind IN pr_tab_crapavt.FIRST..pr_tab_crapavt.LAST LOOP

      IF pr_tab_crapavt(vr_ind).idrspleg <> 1 THEN
        CONTINUE;
      END IF;

      vr_idsitapr := 1; -- PENDENTE  

      IF rw_crapass.idastcjt = 1 AND pr_nrcpfrep = pr_tab_crapavt(vr_ind).nrcpfcgc THEN
         vr_idsitapr := 2; -- APROVADA
      END IF;
   
      BEGIN
       UPDATE tbgen_aprova_trans_pend
         SET idsituacao_aprov = vr_idsitapr
       WHERE
             cdtransacao_pendente = pr_cdtranpe
         AND nrcpf_responsavel_aprov = pr_tab_crapavt(vr_ind).nrcpfcgc;

       IF SQL%ROWCOUNT = 0 THEN
         BEGIN
          INSERT INTO 
             tbgen_aprova_trans_pend(
                cdtransacao_pendente
               ,cdcooper
               ,nrdconta
               ,nrcpf_responsavel_aprov
               ,dtalteracao_situacao
               ,hralteracao_situacao
               ,idsituacao_aprov)
            VALUES(
                pr_cdtranpe
               ,pr_cdcooper
               ,pr_nrdconta
               ,pr_tab_crapavt(vr_ind).nrcpfcgc
               ,TRUNC(SYSDATE)
               ,GENE0002.fn_busca_time()
               ,vr_idsitapr);
         EXCEPTION
           WHEN OTHERS THEN
             vr_dscritic := 'Erro ao incluir registro na tabela TBGEN_APROVA_TRANS_PEND. Erro: ' || SQLERRM;
             RAISE vr_exc_saida;
         END;  
       END IF;   
      EXCEPTION
       WHEN OTHERS THEN
         vr_dscritic := 'Erro ao atualizar registro de aprovacao TBGEN_APROVA_TRANS_PEND. Erro: ' || SQLERRM;
         RAISE vr_exc_saida; 
      END;     
 
      IF vr_idsitapr = 1 AND rw_crapass.idastcjt = 1 THEN
        pc_cria_msgs_trans (pr_cdcooper => pr_cdcooper   -- Codigo Cooperativa
                           ,pr_nrdconta => pr_nrdconta   -- Conta do Associado
                           ,pr_nrdcaixa => pr_nrdcaixa   -- Numero do caixa
                           ,pr_cdagenci => pr_cdagenci   -- Numero da agencia
                           ,pr_cdoperad => pr_cdoperad   -- Numero do operador
                           ,pr_dtmvtolt => pr_dtmvtolt   -- Data da operacao
                           ,pr_cdorigem => pr_idorigem   -- Codigo Origem
                           ,pr_nmdatela => pr_nmdatela   -- Nome da tela
                           ,pr_cdtranpe => pr_cdtranpe   -- Codigo da Transacao Principal
                           ,pr_tptransa => pr_cdtiptra   -- Tipo de Transacao
                           ,pr_dsdmensg => vr_dsdmensg	 -- Descricao da mensagem
                           ,pr_cdcritic => vr_cdcritic   -- Codigo do erro
                           ,pr_dscritic => vr_dscritic); -- Descricao do erro
                  
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic is NOT NULL THEN
           RAISE vr_exc_saida;
        END IF;

        vr_dsdmensg := 'Atenção, ' || pr_tab_crapavt(vr_ind).nmdavali || '!<br><br>Informamos que a seguinte transação está pendente de aprovação:<br><br>' || vr_dsdmensg;

        --Sequencial do titular
        OPEN cr_crapsnh(pr_nrcpfcgc => pr_tab_crapavt(vr_ind).nrcpfcgc);
        FETCH cr_crapsnh INTO rw_crapsnh;
        
        --Se nao encontrou 
        IF cr_crapsnh%NOTFOUND THEN 
           --Fechar Cursor
           CLOSE cr_crapsnh;   
           
           vr_cdcritic:= 0;
           vr_dscritic:= 'Registro de senha nao encontrado.';
           --Levantar Excecao
           RAISE vr_exc_saida;
        END IF;

        --Fechar Cursor
        CLOSE cr_crapsnh;

        -- Gerar mensagem
        gene0003.pc_gerar_mensagem(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_idseqttl => rw_crapsnh.idseqttl
                                  ,pr_cdprogra => pr_nmdatela
                                  ,pr_inpriori => 0
                                  ,pr_dsdmensg => vr_dsdmensg
                                  ,pr_dsdassun => 'Transação pendente'
                                  ,pr_dsdremet => rw_crapcop.nmrescop
                                  ,pr_dsdplchv => 'Transação pendente'
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_cdcadmsg => 0
                                  ,pr_dscritic => vr_dscritic);

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF; 
      END IF;
    END LOOP; 	
     
   EXCEPTION
     WHEN vr_exc_saida THEN
       pr_cdcritic := vr_cdcritic;

       IF vr_cdcritic <> 0 THEN
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       ELSE      
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
       END IF;
         
       ROLLBACK;
     WHEN OTHERS THEN
       pr_dscritic := 'Erro no procedimento INET0002.pc_cria_aprova_transpend: ' || SQLERRM;      
   END pc_cria_aprova_transpend; 

  -- Procedimentos para criaco de mensagens referente a Assinatura Conjunta
  PROCEDURE pc_cria_msgs_trans (pr_cdcooper  IN crapcop.cdcooper%TYPE                      -- Codigo Cooperativa
                               ,pr_nrdconta  IN crapass.nrdconta%TYPE                      -- Conta do Associado
                               ,pr_nrdcaixa  IN INTEGER                                    -- Numero do caixa
                               ,pr_cdagenci  IN INTEGER                                    -- Numero da agencia
                               ,pr_cdoperad  IN VARCHAR2                                   -- Numero do operador
                               ,pr_dtmvtolt  IN DATE                                       -- Data da operacao
                               ,pr_cdorigem  IN INTEGER                                    -- Codigo Origem
                               ,pr_nmdatela  IN VARCHAR2                                   -- Nome da tela
                               ,pr_cdtranpe  IN tbgen_trans_pend.cdtransacao_pendente%TYPE -- Codigo da Transacao Principal
                               ,pr_tptransa  IN INTEGER                                    -- Tipo de Transacao
                               ,pr_dsdmensg OUT VARCHAR2							                     -- Descricao da mensagem
                               ,pr_cdcritic OUT INTEGER                                    -- Codigo do erro
                               ,pr_dscritic OUT VARCHAR2) IS                               -- Descricao do erro
    
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_cria_msgs_trans
  --  Sistema  : Procedimentos para criaco de mensagens referente a Assinatura Conjunta
  --  Sigla    : CRED
  --  Autor    : Jean Michel
  --  Data     : Dezembro/2015.                   Ultima atualizacao: 19/07/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para criar mensagens transacoes pendentes
  --
  -- Alteração : 25/02/2016 - Remover obrigatoriedade de crapcti nas TEDs (Marcos-Supero)
  --
  --             19/07/2016 - Inclusao da opcao de pagamento de DARF/DAS (Jean Michel)
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      -- Cursores
      
      -- Busca dos dados do associado 
      CURSOR cr_crapcop(pr_cdagectl IN crapcop.cdagectl%TYPE) IS
      SELECT crapcop.cdcooper
      FROM   crapcop
      WHERE  crapcop.cdagectl = pr_cdagectl;      

      -- Busca dos dados do associado 
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapass.idastcjt,
             crapass.nmprimtl
      FROM   crapass
      WHERE  crapass.cdcooper = pr_cdcooper
      AND    crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;      

      --Cursor (Pai) Transacoes Pendentes
      CURSOR cr_tbgen_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbgen_trans_pend.cdcooper
            ,tbgen_trans_pend.dtmvtolt
      FROM   tbgen_trans_pend 
      WHERE  tbgen_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbgen_trans_pend cr_tbgen_trans_pend%ROWTYPE;
  	    	  
      --Tipo Transacao 1,3,5 (Transferencia)
      CURSOR cr_tbtransf_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbtransf_trans_pend.cdagencia_coop_destino 
            ,tbtransf_trans_pend.nrconta_destino
            ,tbtransf_trans_pend.idagendamento
            ,tbtransf_trans_pend.vltransferencia
            ,tbtransf_trans_pend.dtdebito
      FROM   tbtransf_trans_pend 
      WHERE  tbtransf_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbtransf_trans_pend cr_tbtransf_trans_pend%ROWTYPE;
  	  
      --Tipo Transacao 2 (Pagamento)
      CURSOR cr_tbpagto_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbpagto_trans_pend.tppagamento
            ,tbpagto_trans_pend.dscedente
            ,tbpagto_trans_pend.idagendamento
            ,tbpagto_trans_pend.vlpagamento
            ,tbpagto_trans_pend.dtdebito
      FROM   tbpagto_trans_pend 
      WHERE  tbpagto_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbpagto_trans_pend cr_tbpagto_trans_pend%ROWTYPE;
  	  
      --Tipo Transacao 4 (TED)
      CURSOR cr_tbspb_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbspb_trans_pend.cdcooper 
            ,tbspb_trans_pend.nrdconta
            ,tbspb_trans_pend.cdbanco_favorecido
            ,tbspb_trans_pend.cdagencia_favorecido
            ,tbspb_trans_pend.nrconta_favorecido
            ,tbspb_trans_pend.dtdebito
            ,tbspb_trans_pend.vlted
            ,tbspb_trans_pend.nmtitula_favorecido
            ,tbspb_trans_pend.idagendamento
      FROM   tbspb_trans_pend 
      WHERE  tbspb_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbspb_trans_pend cr_tbspb_trans_pend%ROWTYPE;
  	  
      --Tipo Transacao 6 (Credito Pre-Aprovado)
      CURSOR cr_tbepr_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbepr_trans_pend.cdcooper
            ,tbepr_trans_pend.vlemprestimo
            ,tbepr_trans_pend.dtprimeiro_vencto
      FROM   tbepr_trans_pend 
      WHERE  tbepr_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbepr_trans_pend cr_tbepr_trans_pend%ROWTYPE;
  	  
      --Tipo Transacao 7 (Aplicacao)
      CURSOR cr_tbcapt_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbcapt_trans_pend.tpoperacao
            ,tbcapt_trans_pend.tpaplicacao
            ,tbcapt_trans_pend.nraplicacao
            ,tbcapt_trans_pend.vlresgate
            ,tbcapt_trans_pend.dtinicio_agendamento
            ,tbcapt_trans_pend.nrdia_agendamento
            ,tbcapt_trans_pend.qtmeses_agendamento
            ,tbcapt_trans_pend.nrdocto_agendamento
            ,tbcapt_trans_pend.tpagendamento
            ,tbcapt_trans_pend.idperiodo_agendamento
            ,tbcapt_trans_pend.tpresgate
      FROM   tbcapt_trans_pend 
      WHERE  tbcapt_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbcapt_trans_pend cr_tbcapt_trans_pend%ROWTYPE;
  	
      --Tipo Transacao 8 (Debito Automatico)
      CURSOR cr_tbconv_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbconv_trans_pend.cdcooper
            ,tbconv_trans_pend.tpoperacao
            ,tbconv_trans_pend.cdsegmento_conven
            ,tbconv_trans_pend.cdconven
            ,tbconv_trans_pend.cdhist_convenio
            ,tbconv_trans_pend.nrdocumento_fatura
            ,tbconv_trans_pend.dtdebito_fatura
      FROM   tbconv_trans_pend 
      WHERE  tbconv_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbconv_trans_pend cr_tbconv_trans_pend%ROWTYPE;
      	  
      --Tipo Transacao 9 (Folha de Pagamento)
      CURSOR cr_tbfolha_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbfolha_trans_pend.vlfolha
            ,tbfolha_trans_pend.dtdebito
      FROM   tbfolha_trans_pend 
      WHERE  tbfolha_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbfolha_trans_pend cr_tbfolha_trans_pend%ROWTYPE;
      
      --Tipo Transacao 11 (DARF/DAS)
      CURSOR cr_tbpagto_darf_das_trans_pend(pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbpagto_darf_das_trans_pend.tppagamento
            ,tbpagto_darf_das_trans_pend.dsidentif_pagto
            ,tbpagto_darf_das_trans_pend.idagendamento
            ,tbpagto_darf_das_trans_pend.dtdebito
            ,tbpagto_darf_das_trans_pend.vlpagamento
      FROM   tbpagto_darf_das_trans_pend
      WHERE  tbpagto_darf_das_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbpagto_darf_das_trans_pend cr_tbpagto_darf_das_trans_pend%ROWTYPE;

      --Cadastro de Transferencias pela Internet.
      CURSOR cr_crapcti( pr_cdcooper IN crapcti.cdcooper%TYPE,
                         pr_nrdconta IN crapcti.nrdconta%TYPE,
                         pr_cddbanco IN crapcti.cddbanco%TYPE,
                         pr_cdageban IN crapcti.cdageban%TYPE,
                         pr_nrctatrf IN crapcti.nrctatrf%TYPE) IS  
      SELECT crapcti.nmtitula 
      FROM   crapcti
      WHERE  crapcti.cdcooper = pr_cdcooper
      AND    crapcti.nrdconta = pr_nrdconta
      AND	   crapcti.cddbanco = pr_cddbanco
      AND	   crapcti.cdageban = pr_cdageban 
      AND	   crapcti.nrctatrf = pr_nrctatrf;

      --Cadastro de convenios.
      CURSOR cr_crapcon( pr_cdcooper IN crapcon.cdcooper%TYPE,
                         pr_cdsegmto IN crapcon.cdsegmto%TYPE,
                         pr_cdempcon IN crapcon.cdempcon%TYPE) IS
      SELECT crapcon.nmrescon 
      FROM   crapcon
      WHERE  crapcon.cdcooper = pr_cdcooper 
      AND    crapcon.cdsegmto = pr_cdsegmto 
      AND    crapcon.cdempcon = pr_cdempcon;

      -- Consulta autorizacao de debitos
      CURSOR cr_autodeb(pr_cdcooper IN crapatr.cdcooper%TYPE,
                       pr_nrdconta IN crapatr.nrdconta%TYPE,
                       pr_cdhistor IN crapatr.cdhistor%TYPE,
                       pr_cdrefere IN crapatr.cdrefere%TYPE,
                       pr_dtmvtopg IN craplau.dtmvtopg%TYPE) IS
        SELECT crapcon.nmrescon, craplau.vllanaut 
        FROM   crapatr, crapcon, craplau
        WHERE  crapatr.cdcooper = pr_cdcooper 
        AND    crapatr.nrdconta = pr_nrdconta 
        AND    crapatr.cdhistor = pr_cdhistor 
        AND    crapatr.cdrefere = pr_cdrefere
        AND    crapatr.tpautori <> 0 
        AND    crapcon.cdcooper = crapatr.cdcooper 
        AND    crapcon.cdsegmto = crapatr.cdsegmto 
        AND    crapcon.cdempcon = crapatr.cdempcon 
        AND    craplau.cdcooper = crapatr.cdcooper 
        AND    craplau.nrdconta = crapatr.nrdconta 
        AND    craplau.cdhistor = crapatr.cdhistor 
        AND    craplau.nrdocmto = crapatr.cdrefere 
        AND    craplau.dtmvtopg = pr_dtmvtopg
        AND    craplau.insitlau = 1;
				
			-- Cursor para buscar a transação de adesão de pacote de tarifa pendente
			CURSOR cr_pactar IS
			  SELECT tpend.cdpacote
				      ,tpac.dspacote
				  FROM tbtarif_pacote_trans_pend tpend
					    ,tbtarif_pacotes tpac
				 WHERE tpend.cdtransacao_pendente = pr_cdtranpe			
				   AND tpac.cdpacote = tpend.cdpacote;
			rw_pactar cr_pactar%ROWTYPE;

      --Variaveis Locais
      vr_idastcjt crapass.idastcjt%TYPE;
      vr_nmprimtl crapass.nmprimtl%TYPE;
      vr_nmtitula crapass.nmprimtl%TYPE;
      vr_nrdolote craplot.nrdolote%TYPE;     
      vr_cdhistor craplot.cdhistor%TYPE;
      vr_nrindice NUMBER;
      vr_nmrescon crapcon.nmrescon%TYPE;
      vr_vllanaut craplau.vllanaut%TYPE;
      vr_tab_agen APLI0002.typ_tab_agen; 
      vr_tab_agen_det APLI0002.typ_tab_agen_det; 
      vr_dsdtefet VARCHAR2(20);
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_vlresgat VARCHAR2(100);      
      vr_saldo_rdca APLI0001.typ_tab_saldo_rdca; --Tabela para o saldo da aplicação

      --Variaveis de Erro
      vr_cdcritic crapcri.cdcritic%type;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
  
    ------------------------------------------------------
    -------------- INICIO BLOCO PRINCIPAL ----------------
    ------------------------------------------------------      
    BEGIN
      
      -- Dados da conta
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO vr_idastcjt,
                            vr_nmprimtl;
      
	    --Se nao encontrou 
      IF cr_crapass%NOTFOUND THEN 
         --Fechar Cursor
         CLOSE cr_crapass;   
         
         vr_cdcritic:= 0;
         vr_dscritic:= 'Registro do cooperado nao encontrado.';
         --Levantar Excecao
         RAISE vr_exc_erro;
      END IF;

      --Fechar Cursor
      CLOSE cr_crapass;
      
      OPEN cr_tbgen_trans_pend(pr_cddoitem => pr_cdtranpe);
      FETCH cr_tbgen_trans_pend INTO rw_tbgen_trans_pend;
                  
      IF cr_tbgen_trans_pend%NOTFOUND THEN
          CLOSE cr_tbgen_trans_pend;
          vr_cdcritic:= 0;
          vr_dscritic:= 'Registro de transacao pendente nao encontrado.';
          --Levantar Excecao
          RAISE vr_exc_erro;      
      ELSE
          CLOSE cr_tbgen_trans_pend;
      END IF;
                          
			-- Tipos de transacoes
			CASE 
					WHEN pr_tptransa IN(1,3,5) THEN --Transferencia
							 OPEN cr_tbtransf_trans_pend(pr_cddoitem => pr_cdtranpe);
							 FETCH cr_tbtransf_trans_pend INTO rw_tbtransf_trans_pend;
							 IF cr_tbtransf_trans_pend%NOTFOUND THEN
                  --Fechar Cursor
								 CLOSE cr_tbtransf_trans_pend;
									vr_cdcritic:= 0;
									vr_dscritic:= 'Registro de ' || 
																(CASE WHEN pr_tptransa = 3 THEN 'Credito Salario' ELSE 'Transferencia' END) ||
																'pendente nao encontrado.';
									--Levantar Excecao
									RAISE vr_exc_erro;
               ELSE
                  --Fechar Cursor
							    CLOSE cr_tbtransf_trans_pend;
							 END IF;
               
               OPEN cr_crapcop(pr_cdagectl => rw_tbtransf_trans_pend.cdagencia_coop_destino);
               FETCH cr_crapcop INTO vr_cdcooper;
                
               --Se nao encontrou 
               IF cr_crapcop%NOTFOUND THEN 
                  --Fechar Cursor
                  CLOSE cr_crapcop;   
                  
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Registro da cooperativa destino nao encontrado.';
                  --Levantar Excecao
                  RAISE vr_exc_erro;
               ELSE
                  --Fechar Cursor
                  CLOSE cr_crapcop;
               END IF;
               
               OPEN cr_crapass (pr_cdcooper => vr_cdcooper
                               ,pr_nrdconta => rw_tbtransf_trans_pend.nrconta_destino);
               FETCH cr_crapass INTO rw_crapass;
               IF cr_crapass %NOTFOUND THEN
                  --Fechar Cursor
                  CLOSE cr_crapass;
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Conta destino nao encontrado.';
                  --Levantar Excecao
                  RAISE vr_exc_erro;
               ELSE
                  --Fechar Cursor
                  CLOSE cr_crapass;
               END IF;
               
							 pr_dsdmensg := pr_dsdmensg || (CASE WHEN pr_tptransa = 3 THEN '<b>Crédito de Salário' ELSE '<b>Transferência' END) || '</b> para ';
               pr_dsdmensg := pr_dsdmensg || '<b>' || TO_CHAR(rw_tbtransf_trans_pend.cdagencia_coop_destino,'0000') || '</b>';
               pr_dsdmensg := pr_dsdmensg || '|' || '<b>' || TO_CHAR(rw_tbtransf_trans_pend.nrconta_destino) || '</b> - <b>';
   						 pr_dsdmensg := pr_dsdmensg || TO_CHAR(SUBSTR(rw_crapass.nmprimtl,1,20)) || '</b>';
							 pr_dsdmensg := pr_dsdmensg || (CASE WHEN rw_tbtransf_trans_pend.idagendamento = 1 THEN ' com débito em ' ELSE ' agendado para ' END);
							 pr_dsdmensg := pr_dsdmensg || '<b>' || TO_CHAR(rw_tbtransf_trans_pend.dtdebito,'DD/MM/RRRR') || '</b>' || ' no valor de <b>R$ ';
 							 pr_dsdmensg := pr_dsdmensg || TO_CHAR(TO_CHAR(rw_tbtransf_trans_pend.vltransferencia),'fm999g999g990d00') || '</b>.<br>';
					
					WHEN pr_tptransa = 2 THEN --Pagamento
							 OPEN cr_tbpagto_trans_pend(pr_cddoitem => pr_cdtranpe);
							 FETCH cr_tbpagto_trans_pend INTO rw_tbpagto_trans_pend;
							 IF cr_tbpagto_trans_pend%NOTFOUND THEN
                  --Fechar Cursor
                  CLOSE cr_tbpagto_trans_pend;      
									vr_cdcritic:= 0;
									vr_dscritic:= 'Registro de Pagamento pendente nao encontrado.';
									--Levantar Excecao
									RAISE vr_exc_erro;
               ELSE
                  --Fechar Cursor
							    CLOSE cr_tbpagto_trans_pend;
							 END IF;

							 pr_dsdmensg := pr_dsdmensg || 
															'<b>Pagamento de ' ||
															(CASE WHEN rw_tbpagto_trans_pend.tppagamento = 1 THEN 'Convênio' ELSE 'Título' END) || '</b> de ' ||
															'<b>' || rw_tbpagto_trans_pend.dscedente || '</b>' ||
															(CASE WHEN rw_tbpagto_trans_pend.idagendamento = 1 THEN ' com débito em ' ELSE ' agendado para ' END) ||
															'<b>' || TO_CHAR(rw_tbpagto_trans_pend.dtdebito,'DD/MM/RRRR') || '</b>' || ' no valor de <b>R$ ' ||
															TO_CHAR(rw_tbpagto_trans_pend.vlpagamento,'fm999g999g990d00') || '</b>.<br>';
					
					WHEN pr_tptransa = 4 THEN --TED
							 OPEN cr_tbspb_trans_pend(pr_cddoitem => pr_cdtranpe);
							 FETCH cr_tbspb_trans_pend INTO rw_tbspb_trans_pend;				
							IF cr_tbspb_trans_pend%NOTFOUND THEN
                 --Fechar Cursor
                 CLOSE cr_tbspb_trans_pend;
								 vr_cdcritic:= 0;
								 vr_dscritic:= 'Registro de TED pendente nao encontrado.';
								 --Levantar Excecao
								 RAISE vr_exc_erro;
              ELSE
                 --Fechar Cursor
							   CLOSE cr_tbspb_trans_pend;
							END IF;
						
							OPEN cr_crapcti(pr_cdcooper => rw_tbspb_trans_pend.cdcooper,
															pr_nrdconta => rw_tbspb_trans_pend.nrdconta,
															pr_cddbanco => rw_tbspb_trans_pend.cdbanco_favorecido,
															pr_cdageban => rw_tbspb_trans_pend.cdagencia_favorecido,
															pr_nrctatrf => rw_tbspb_trans_pend.nrconta_favorecido);
							FETCH cr_crapcti INTO vr_nmtitula;	
							IF cr_crapcti%NOTFOUND THEN
                 --Fechar Cursor
                 CLOSE cr_crapcti;

								 vr_cdcritic:= 0;
								 vr_dscritic:= 'Registro de Cadastro de transferencias nao encontrado.';
								 --Levantar Excecao
								 RAISE vr_exc_erro;
              ELSE
                 --Fechar Cursor
							   CLOSE cr_crapcti;
							END IF;

							pr_dsdmensg := pr_dsdmensg ||
														 '<b>TED</b> para <b>' ||
														 TO_CHAR(rw_tbspb_trans_pend.nrconta_favorecido) || ' - ' ||
														 SUBSTR(vr_nmtitula,1,20) || '</b> ' || 
                             (CASE WHEN rw_tbspb_trans_pend.idagendamento = 1 THEN
                                ' com débito em ' 
                              ELSE
                                ' agendado para ' END) ||
														 '<b>' || TO_CHAR(rw_tbspb_trans_pend.dtdebito,'DD/MM/RRRR') || 
                             '</b> no valor de <b>R$ ' ||
														 TO_CHAR(rw_tbspb_trans_pend.vlted,'fm999g999g990d00') || '</b>.<br>';
					
					WHEN pr_tptransa = 6 THEN --Credito Pre-Aprovado
							 OPEN cr_tbepr_trans_pend(pr_cddoitem => pr_cdtranpe);
							 FETCH cr_tbepr_trans_pend INTO rw_tbepr_trans_pend;
							 IF cr_tbepr_trans_pend%NOTFOUND THEN
                  --Fechar Cursor
                  CLOSE cr_tbepr_trans_pend;
									vr_cdcritic:= 0;
									vr_dscritic:= 'Registro de Credito Pre-Aprovado pendente nao encontrado.';
									--Levantar Excecao
									RAISE vr_exc_erro;
               ELSE
                  --Fechar Cursor
							    CLOSE cr_tbepr_trans_pend;
							 END IF;
               
							 pr_dsdmensg := pr_dsdmensg ||
															'<b>Crédito Pré-Aprovado</b> no valor de <b>R$ ' ||
															TO_CHAR(rw_tbepr_trans_pend.vlemprestimo,'fm999g999g990d00') || '</b> com débito em <b>' ||
															TO_CHAR(rw_tbgen_trans_pend.dtmvtolt,'DD/MM/RRRR') || '</b>.<br>';
					
					WHEN pr_tptransa = 7 THEN --Aplicacao
							 OPEN cr_tbcapt_trans_pend(pr_cddoitem => pr_cdtranpe);
							 FETCH cr_tbcapt_trans_pend INTO rw_tbcapt_trans_pend;
							 IF cr_tbcapt_trans_pend%NOTFOUND THEN
                  --Fechar Cursor
                  CLOSE cr_tbcapt_trans_pend;
									vr_cdcritic:= 0;
									vr_dscritic:= 'Registro de Aplicacao pendente nao encontrado.';
									--Levantar Excecao
									RAISE vr_exc_erro;
               ELSE
                  --Fechar Cursor
							    CLOSE cr_tbcapt_trans_pend;
							 END IF;
	
							 CASE
									 WHEN rw_tbcapt_trans_pend.tpoperacao = 1 THEN --Cancelamento Aplicacao
												pr_dsdmensg := pr_dsdmensg ||
																			 '<b>Cancelamento da Aplicação número <b>' || TO_CHAR(rw_tbcapt_trans_pend.nraplicacao) || '</b>.';

									 WHEN rw_tbcapt_trans_pend.tpoperacao = 2 THEN --Resgate
                        IF rw_tbcapt_trans_pend.tpresgate = 2 THEN
                           apli0005.pc_lista_aplicacoes(pr_cdcooper => pr_cdcooper
                                                       ,pr_cdoperad => pr_cdoperad
                                                       ,pr_nmdatela => pr_nmdatela
                                                       ,pr_idorigem => pr_cdorigem
                                                       ,pr_nrdcaixa => pr_nrdcaixa
                                                       ,pr_nrdconta => pr_nrdconta
                                                       ,pr_idseqttl => 1
                                                       ,pr_cdagenci => pr_cdagenci
                                                       ,pr_cdprogra => pr_nmdatela
                                                       ,pr_nraplica => rw_tbcapt_trans_pend.nraplicacao
                                                       ,pr_cdprodut => 0
                                                       ,pr_dtmvtolt => pr_dtmvtolt 
                                                       ,pr_idconsul => 2 
                                                       ,pr_idgerlog => 0
                                                       ,pr_cdcritic => vr_cdcritic
                                                       ,pr_dscritic => vr_dscritic
                                                       ,pr_saldo_rdca => vr_saldo_rdca);
                                                       
                           vr_nrindice := vr_saldo_rdca.FIRST; 
                          
                           WHILE vr_nrindice IS NOT NULL LOOP                                                          
                             vr_vlresgat := TO_CHAR(vr_saldo_rdca(vr_nrindice).sldresga,'fm999g999g990d00');
                             EXIT;
                           END LOOP;
                        ELSE
                           vr_vlresgat := TO_CHAR(rw_tbcapt_trans_pend.vlresgate,'fm999g999g990d00');
                        END IF;
                        
												pr_dsdmensg := pr_dsdmensg ||
																			 '<b>Resgate</b> no valor de <b>R$ ' || 
																			 vr_vlresgat || 
																			 '</b> da aplicacao numero <b>' ||
                                       TO_CHAR(rw_tbcapt_trans_pend.nraplicacao) || '</b> com credito em ' || 
																			 TO_CHAR(rw_tbgen_trans_pend.dtmvtolt,'DD/MM/RRRR') || '</b>.<br>';

									 WHEN rw_tbcapt_trans_pend.tpoperacao = 3 THEN --Agendamento Resgate

                        IF rw_tbcapt_trans_pend.idperiodo_agendamento = 0 THEN
                           pr_dsdmensg := pr_dsdmensg || 'Resgate no valor de <b>R$ ' || TO_CHAR(rw_tbcapt_trans_pend.vlresgate,'fm999g999g990d00') ||
                                          '</b> agendado para <b>' || TO_CHAR(rw_tbcapt_trans_pend.dtinicio_agendamento,'DD/MM/RRRR') || '</b>.';
                        ELSIF rw_tbcapt_trans_pend.idperiodo_agendamento = 1 THEN
                           vr_dsdtefet := TO_CHAR(TO_DATE(LPAD(NVL(rw_tbcapt_trans_pend.nrdia_agendamento,1),2,0) || '/' || to_CHAR(pr_dtmvtolt,'mm/RRRR'),'dd/mm/RRRR'),'DD/MM/RRRR');
                                             
                           IF (TO_DATE(LPAD(NVL(rw_tbcapt_trans_pend.nrdia_agendamento,1),2,0) || '/' || to_CHAR(pr_dtmvtolt,'mm/RRRR'),'dd/mm/RRRR')) <= pr_dtmvtolt THEN 
                              vr_dsdtefet := TO_CHAR(TO_DATE(LPAD(NVL(rw_tbcapt_trans_pend.nrdia_agendamento,1),2,0) || '/' || to_CHAR(ADD_MONTHS(pr_dtmvtolt,1),'mm/RRRR'),'dd/mm/RRRR'),'DD/MM/RRRR');
                           END IF;
                            
                           pr_dsdmensg := pr_dsdmensg ||
																			 '<b>Resgate</b> no valor de <b>R$ ' || 
																			 TO_CHAR(rw_tbcapt_trans_pend.vlresgate,'fm999g999g990d00') || 
																			 '</b> agendado para crédito no <b>dia ' ||
																			 TO_CHAR(rw_tbcapt_trans_pend.nrdia_agendamento,'00') || '</b> durante <b>' ||
																			 TO_CHAR(rw_tbcapt_trans_pend.qtmeses_agendamento,'99') || ' meses</b> ' ||
																			 'iniciando em <b>' || vr_dsdtefet || '</b>.<br>';

                        END IF;                        
									 WHEN rw_tbcapt_trans_pend.tpoperacao = 4 THEN --Cancelamento Total Agendamento
												APLI0002.pc_consulta_agendamento(pr_cdcooper => pr_cdcooper
																												,pr_flgtipar => 2 -- Todos Agendamentos 
																												,pr_nrdconta => pr_nrdconta 
																												,pr_idseqttl => 0 -- Todos Titulares 
																												,pr_nrctraar => rw_tbcapt_trans_pend.nrdocto_agendamento 
																												,pr_cdcritic => vr_cdcritic 
																												,pr_dscritic => vr_dscritic
																												,pr_tab_agen => vr_tab_agen);                      
			
												vr_nrindice := vr_tab_agen.FIRST;
                          
                        WHILE vr_nrindice IS NOT NULL LOOP
														--Aplicacao
														IF vr_tab_agen(vr_nrindice).flgtipar = 0 THEN
                               IF vr_tab_agen(vr_nrindice).flgtipin = 1 THEN -- Mensal
                                   pr_dsdmensg := pr_dsdmensg ||
                                                  '<b>Cancelamento de Nova Aplicação</b> no valor de <b>R$ ' ||
                                                  TO_CHAR(vr_tab_agen(vr_nrindice).vlparaar,'fm999g999g990d00') ||
                                                  '</b> agendada para o <b>dia ' || 
                                                  TO_CHAR(vr_tab_agen(vr_nrindice).dtdiaaar,'00') || '</b> durante <b>' ||
                                                  TO_CHAR(vr_tab_agen(vr_nrindice).qtmesaar) || ' meses</b> iniciando em <b>' ||
                                                  TO_CHAR(vr_tab_agen(vr_nrindice).dtiniaar,'DD/MM/RRRR') || '</b>.<br>';	
                               ELSE -- Único
                                   pr_dsdmensg := pr_dsdmensg ||
                                                  '<b>Cancelamento de Nova Aplicação</b> no valor de <b>R$ ' ||
                                                  TO_CHAR(vr_tab_agen(vr_nrindice).vlparaar,'fm999g999g990d00') ||
                                                  '</b> agendada para <b>dia ' ||                                                  
                                                  TO_CHAR(vr_tab_agen(vr_nrindice).dtiniaar,'DD/MM/RRRR') || '</b>.<br>';	
                               END IF;
														ELSE --Resgate
                               IF vr_tab_agen(vr_nrindice).flgtipin = 1 THEN -- Mensal
                                   pr_dsdmensg := pr_dsdmensg ||
                                                  '<b>Cancelamento de Resgate</b> no valor de <b>R$ ' ||
                                                  TO_CHAR(vr_tab_agen(vr_nrindice).vlparaar,'fm999g999g990d00') ||
                                                  '</b> agendado para crédito no <b>dia ' || 
                                                  TO_CHAR(vr_tab_agen(vr_nrindice).dtdiaaar,'00') || '</b> durante <b>' ||
                                                  TO_CHAR(vr_tab_agen(vr_nrindice).qtmesaar) || ' meses</b> iniciando em <b>' ||
                                                  TO_CHAR(vr_tab_agen(vr_nrindice).dtiniaar,'DD/MM/RRRR') || '</b>.<br>';
                               ELSE -- Único
                                   pr_dsdmensg := pr_dsdmensg ||
                                                  '<b>Cancelamento de Resgate</b> no valor de <b>R$ ' ||
                                                  TO_CHAR(vr_tab_agen(vr_nrindice).vlparaar,'fm999g999g990d00') ||
                                                  '</b> agendado para crédito em <b>' ||                                                   
                                                  TO_CHAR(vr_tab_agen(vr_nrindice).dtiniaar,'DD/MM/RRRR') || '</b>.<br>';                                 
                               END IF;
														END IF;
                          EXIT;
												END LOOP;
									 WHEN rw_tbcapt_trans_pend.tpoperacao = 5 THEN --Cancelamento Item Agendamento
												--aplicacao
												IF rw_tbcapt_trans_pend.tpagendamento = 0 THEN
													 vr_nrdolote := 32001;
													 vr_cdhistor := 527;
												ELSE --resgate
													 vr_nrdolote := 32002;
													 vr_cdhistor := 530;
												END IF;
												
												APLI0002.pc_consulta_det_agendmto(pr_cdcooper => pr_cdcooper
																												 ,pr_nrdocmto => substr(to_char(rw_tbcapt_trans_pend.nrdocto_agendamento),6,10)
																												 ,pr_nrdolote => vr_nrdolote
																												 ,pr_nrdconta => pr_nrdconta
																												 ,pr_cdhistor => vr_cdhistor
																												 ,pr_cdcritic => vr_cdcritic
																												 ,pr_dscritic => vr_dscritic
																												 ,pr_tab_agen_det => vr_tab_agen_det);
												IF NVL(vr_cdcritic,0) <> 0 OR
													 vr_dscritic IS NOT NULL THEN
													 RAISE vr_exc_erro;
												END IF;			

												vr_nrindice := vr_tab_agen_det.FIRST;                        
                          
                        WHILE vr_nrindice IS NOT NULL LOOP
                          IF vr_tab_agen_det(vr_nrindice).nrdocmto <> rw_tbcapt_trans_pend.nrdocto_agendamento THEN
                             vr_nrindice := vr_tab_agen_det.NEXT(vr_nrindice);
                             CONTINUE;
                          END IF;
                             
                          --Aplicacao
                          IF rw_tbcapt_trans_pend.tpagendamento = 0 THEN
                             pr_dsdmensg := pr_dsdmensg ||
                                            '<b>Cancelamento de Nova Aplicação</b> no valor de <b>R$ ' || 
                                            TO_CHAR(vr_tab_agen_det(vr_nrindice).vllanaut,'fm999g999g990d00') || 
                                            '</b> agendada para <b>' || TO_CHAR(vr_tab_agen_det(vr_nrindice).dtmvtopg,'DD/MM/RRRR') || '</b>.<br>';
                          ELSE --Resgate
                             pr_dsdmensg := pr_dsdmensg || 
                                            '<b>Cancelamento de Resgate</b> no valor de <b>R$ ' || 
                                            TO_CHAR(vr_tab_agen_det(vr_nrindice).vllanaut,'fm999g999g990d00') || 
                                            '</b> agendado para <b>' || TO_CHAR(vr_tab_agen_det(vr_nrindice).dtmvtopg,'DD/MM/RRRR') || '</b>.<br>';
												  END IF;
                          EXIT;
                        END LOOP;

							 END CASE; -- END CASE
	
					WHEN pr_tptransa = 8 THEN --Debito Automatico
							 OPEN cr_tbconv_trans_pend(pr_cddoitem => pr_cdtranpe);
							 FETCH cr_tbconv_trans_pend INTO rw_tbconv_trans_pend;
							 IF cr_tbconv_trans_pend%NOTFOUND THEN
                  --Fechar Cursor
                  CLOSE cr_tbconv_trans_pend;
									vr_cdcritic:= 0;
									vr_dscritic:= 'Registro Debito Automatico nao encontrado.';
									--Levantar Excecao
									RAISE vr_exc_erro;
               ELSE
                  --Fechar Cursor
							    CLOSE cr_tbconv_trans_pend;
							 END IF;
	
							 CASE 
									 WHEN rw_tbconv_trans_pend.tpoperacao = 1 THEN --Autorizacao Debito Automatico
												OPEN cr_crapcon(pr_cdcooper => pr_cdcooper,
																				pr_cdsegmto => rw_tbconv_trans_pend.cdsegmento_conven,
																				pr_cdempcon => rw_tbconv_trans_pend.cdconven);
												FETCH cr_crapcon INTO vr_nmrescon;
												
												IF cr_crapcon%NOTFOUND THEN
                           --Fechar Cursor
                           CLOSE cr_crapcon;

													 vr_cdcritic:= 0;
													 vr_dscritic:= 'Registro Empresa conveniada nao encontrado.';
													 --Levantar Excecao
													 RAISE vr_exc_erro;
												END IF;

                        --Fechar Cursor
												CLOSE cr_crapcon;

												pr_dsdmensg := pr_dsdmensg ||
																			 '<b>Autorização de Débito Automático</b> para faturas da <b>' || vr_nmrescon || '</b>.<br>';
									 WHEN rw_tbconv_trans_pend.tpoperacao = 2 OR   --Bloqueio Debito Automatico
												rw_tbconv_trans_pend.tpoperacao = 3 THEN --Desbloqueio Debito Automatico
												OPEN cr_autodeb(pr_cdcooper => pr_cdcooper,
																				pr_nrdconta => pr_nrdconta,
																				pr_cdhistor => rw_tbconv_trans_pend.cdhist_convenio,
																				pr_cdrefere => rw_tbconv_trans_pend.nrdocumento_fatura,
                                        pr_dtmvtopg => rw_tbconv_trans_pend.dtdebito_fatura);
												FETCH cr_autodeb INTO vr_nmrescon,
																							vr_vllanaut;
												
												IF cr_autodeb%NOTFOUND THEN
                           --Fechar Cursor
                           CLOSE cr_autodeb;

													 vr_cdcritic:= 0;
													 vr_dscritic:= 'Registro Bloqueio/Desbloqueio Debito Automatico nao encontrado.';
													 --Levantar Excecao
													 RAISE vr_exc_erro;
												END IF;

                        --Fechar Cursor
												CLOSE cr_autodeb;

												pr_dsdmensg := pr_dsdmensg ||
																			 (CASE WHEN rw_tbconv_trans_pend.tpoperacao = 2 THEN '<b>Bloqueio' ELSE '<b>Desbloqueio' END) ||
																			 '</b> de lançamento de <b>Débito Automático</b> da <b>' || vr_nmrescon || 
																			 '</b> no valor de <b>R$ ' || TO_CHAR(vr_vllanaut,'fm999g999g990d00') || 
																			 '</b> agendado para <b>' || 
																			 TO_CHAR(rw_tbconv_trans_pend.dtdebito_fatura,'DD/MM/RRRR') || '</b>.<br>';
							 END CASE; --End Case
					WHEN pr_tptransa = 9 THEN --Folha Pagamento
							 OPEN cr_tbfolha_trans_pend(pr_cddoitem => pr_cdtranpe);
							 FETCH cr_tbfolha_trans_pend INTO rw_tbfolha_trans_pend; 
							 IF cr_tbfolha_trans_pend%NOTFOUND THEN
                  --Fechar Cursor
                  CLOSE cr_tbfolha_trans_pend;
									vr_cdcritic:= 0;
									vr_dscritic:= 'Registro de Folha Pagamento pendente nao encontrado.';
									--Levantar Excecao
									RAISE vr_exc_erro;
               ELSE
                  --Fechar Cursor
							    CLOSE cr_tbfolha_trans_pend;
							 END IF;

							 pr_dsdmensg := pr_dsdmensg ||
															'<b>Folha de Pagamento</b> no valor total de <b>R$ ' ||
															TO_CHAR(rw_tbfolha_trans_pend.vlfolha,'fm999g999g990d00') || 
															'</b> com débito programado para <b>' || 
															TO_CHAR(rw_tbfolha_trans_pend.dtdebito,'DD/MM/RRRR') || '</b>.<br>';
WHEN pr_tptransa = 10 THEN --Pacote de tarifas
						OPEN cr_pactar;
						FETCH cr_pactar INTO rw_pactar;
								 
						IF cr_pactar%NOTFOUND THEN
							-- Fecha cursor
							CLOSE cr_pactar;
							vr_cdcritic := 0;
							vr_dscritic := 'Registro de Adesao de servico nao encontrado.';
							-- Levantar exceção
							RAISE vr_exc_erro;
						ELSE
							-- Fecha cursor
							CLOSE cr_pactar;							
						END IF;
						pr_dsdmensg := pr_dsdmensg ||
													    '<b>Adesão do Serviço Cooperativo</b> ' ||
															TO_CHAR(rw_pactar.cdpacote,'fm999') || ' - ' ||
                              rw_pactar.dspacote || '.<br>';
						

          WHEN pr_tptransa = 11 THEN -- Pagamento DARF/DAS
							 OPEN cr_tbpagto_darf_das_trans_pend(pr_cddoitem => pr_cdtranpe);
							 FETCH cr_tbpagto_darf_das_trans_pend INTO rw_tbpagto_darf_das_trans_pend;
							 IF cr_tbpagto_darf_das_trans_pend%NOTFOUND THEN
                  --Fechar Cursor
                  CLOSE cr_tbpagto_darf_das_trans_pend;      
									vr_cdcritic:= 0;
									vr_dscritic:= 'Registro de Pagamento de DARF/DAS pendente nao encontrado.';
									--Levantar Excecao
									RAISE vr_exc_erro;
               ELSE
                  --Fechar Cursor
							    CLOSE cr_tbpagto_darf_das_trans_pend;
							 END IF;

							 pr_dsdmensg := pr_dsdmensg || 
															'<b>Pagamento de ' ||
															(CASE WHEN rw_tbpagto_darf_das_trans_pend.tppagamento = 1 THEN 'DARF' ELSE 'DAS' END) || '</b>' ||
															(CASE WHEN rw_tbpagto_darf_das_trans_pend.dsidentif_pagto IS NOT NULL THEN
                               ' para ' || '<b>' || rw_tbpagto_darf_das_trans_pend.dsidentif_pagto || '</b>' ELSE '' END) ||
															(CASE WHEN rw_tbpagto_darf_das_trans_pend.idagendamento = 1 THEN ' com débito em ' ELSE ' agendado para ' END) ||
															'<b>' || TO_CHAR(rw_tbpagto_darf_das_trans_pend.dtdebito,'DD/MM/RRRR') || '</b>' || ' no valor de <b>R$ ' ||
															TO_CHAR(rw_tbpagto_darf_das_trans_pend.vlpagamento,'fm999g999g990d00') || '</b>.<br>';
					
			END CASE; -- End  Case
			      
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE	
         pr_cdcritic := 0;
         pr_dscritic := vr_dscritic;
        END IF;	
        
      WHEN OTHERS THEN
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina INET0002.pc_cria_msgs_trans. '||SQLERRM;
        
    END;
  END pc_cria_msgs_trans;

  /* Procedure para reprovar transacoes pendentes */
  PROCEDURE pc_reprova_trans_pend (pr_cdcooper IN crapcop.cdcooper%TYPE  --Codigo Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --Conta do Associado
                                  ,pr_nrdcaixa IN INTEGER                --Numero do caixa
                                  ,pr_cdagenci IN INTEGER                --Numero da agencia
                                  ,pr_cdoperad IN VARCHAR2               --Numero do operador
                                  ,pr_dtmvtolt IN DATE                   --Data da operacao
                                  ,pr_cdorigem IN INTEGER                --Codigo Origem
                                  ,pr_nmdatela IN VARCHAR2               --Nome da tela
                                  ,pr_cdditens IN VARCHAR2               --Itens
                                  ,pr_nrcpfope IN NUMBER                 --CPF do operador
                                  ,pr_idseqttl IN NUMBER                 --Sequencial de Titularidade
                                  ,pr_flgerlog IN INTEGER                --Flag de log
                                  ,pr_cdcritic OUT INTEGER               --Codigo do erro
                                  ,pr_dscritic OUT VARCHAR2) IS          --Descricao do erro
    
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_reprova_trans_pend
  --  Sistema  : Procedimentos para reprovar transacoes pendentes
  --  Sigla    : CRED
  --  Autor    : Jorge Hamaguchi
  --  Data     : Dezembro/2015.                   Ultima atualizacao: 00/00/0000
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para reprovar transacao pendente
  --
  -- Alteração : 
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
  DECLARE
    
    --Variaveis Locais
	  vr_nmrescop crapcop.nmrescop%TYPE;
	  vr_idseqttl crapsnh.idseqttl%TYPE;
    vr_dsorigem VARCHAR2(50);
    vr_dstransa VARCHAR2(100);
    vr_idastcjt NUMBER;
    vr_nrcpfcgc NUMBER(14);
    vr_nrdctato crapavt.nrdctato%TYPE;
    vr_nmprimtl crapass.nmprimtl%TYPE;
	  vr_dtvalida crapavt.dtvalida%TYPE;
	  vr_tptransa NUMBER(2);
    vr_cddoitem tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_dsdmensg VARCHAR2(32000) := ' ';
    vr_ncctarep crapavt.nrdctato%TYPE;
    vr_auxnumbe NUMBER;
    
    -- Array para guardar o split dos dados contidos na dstextab
    vr_cdditens gene0002.typ_split;
    vr_auxditem gene0002.typ_split;
    -- Rowid tabela de log
    vr_nrdrowid ROWID;
	  
    --Variaveis de Erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
		
	  -- Buscar nome da cooperativa
	  CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
		SELECT cop.nmrescop
		FROM   crapcop cop
		WHERE  cop.cdcooper = pr_cdcooper;	
		
    -- Busca dos dados do associado 
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT crapass.idastcjt,
           crapass.nmprimtl
    FROM   crapass
    WHERE  crapass.cdcooper = pr_cdcooper
    AND    crapass.nrdconta = pr_nrdconta;
    
    --Selecionar informacoes de senhas
    CURSOR cr_crapsnh (pr_cdcooper IN crapsnh.cdcooper%TYPE
                      ,pr_nrdconta IN crapsnh.nrdconta%TYPE
				              ,pr_idseqttl IN crapsnh.idseqttl%TYPE) IS
    SELECT crapsnh.nrcpfcgc
    FROM   crapsnh
    WHERE  crapsnh.cdcooper = pr_cdcooper
    AND    crapsnh.nrdconta = pr_nrdconta
    AND    crapsnh.idseqttl = pr_idseqttl
    AND    crapsnh.tpdsenha = 1; --Internet
		
	  --Selecionar informacoes de senhas
    CURSOR cr_crapsnh2 (pr_cdcooper IN crapsnh.cdcooper%TYPE
                       ,pr_nrdconta IN crapsnh.nrdconta%TYPE
                       ,pr_nrcpfcgc IN crapsnh.nrcpfcgc%TYPE) IS
    SELECT crapsnh.idseqttl
    FROM   crapsnh
    WHERE  crapsnh.cdcooper = pr_cdcooper
    AND    crapsnh.nrdconta = pr_nrdconta
    AND    crapsnh.nrcpfcgc = pr_nrcpfcgc
    AND    crapsnh.tpdsenha = 1; --Internet
              
    -- Busca do nome do representante/procurador
    CURSOR cr_crapavt(pr_cdcooper IN crapavt.cdcooper%TYPE
                     ,pr_nrdconta IN crapavt.nrdconta%TYPE
                     ,pr_nrcpfcgc IN crapavt.nrcpfcgc%TYPE) IS
    SELECT crapavt.nrdctato,
           crapavt.nmdavali,
           crapavt.dtvalida
    FROM   crapavt
    WHERE  crapavt.cdcooper = pr_cdcooper
    AND    crapavt.nrdconta = pr_nrdconta
    AND    crapavt.nrcpfcgc = pr_nrcpfcgc
    AND    crapavt.tpctrato = 6; -- Juridico
	  
	  --Cursor (Pai) Transacoes Pendentes
	  CURSOR cr_tbgen_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
    SELECT tbgen_trans_pend.cdtransacao_pendente,
           tbgen_trans_pend.tptransacao
    FROM   tbgen_trans_pend 
    WHERE  tbgen_trans_pend.cdtransacao_pendente = pr_cddoitem;
    rw_tbgen_trans_pend cr_tbgen_trans_pend%ROWTYPE;
	  
	  --Cursor de aprovacao
    CURSOR cr_tbgen_aprova_trans_pend( pr_cddoitem IN tbgen_aprova_trans_pend.cdtransacao_pendente%TYPE,
                                       pr_nrcpfcgc IN tbgen_aprova_trans_pend.nrcpf_responsavel_aprov%TYPE,
                                       pr_inoutros IN NUMBER) IS  
    SELECT tbgen_aprova_trans_pend.nrdconta,
           tbgen_aprova_trans_pend.nrcpf_responsavel_aprov 
    FROM   tbgen_aprova_trans_pend
    WHERE  tbgen_aprova_trans_pend.cdtransacao_pendente    = pr_cddoitem
    AND    ((pr_inoutros = 0 AND tbgen_aprova_trans_pend.nrcpf_responsavel_aprov = pr_nrcpfcgc) OR
            (pr_inoutros = 1 AND tbgen_aprova_trans_pend.nrcpf_responsavel_aprov <> pr_nrcpfcgc));
    rw_tbgen_aprova_trans_pend cr_tbgen_aprova_trans_pend%ROWTYPE;
	      	  
	  ------------------------------------------------------
	
    -------------- INICIO BLOCO PRINCIPAL ----------------
    ------------------------------------------------------      
    
	BEGIN
      --Inicializar varaivel retorno erro
      vr_cdcritic:= NULL;
      vr_dscritic:= NULL;
      
      IF pr_flgerlog = 1 THEN
         -- Buscar a origem
         vr_dsorigem:= gene0001.vr_vet_des_origens(pr_cdorigem);
         -- Buscar Transacao
         vr_dstransa:= 'Reprovar transacoes pendentes de operadores de conta.';
      END IF;
      
	    --Dados da Cooperativa
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO vr_nmrescop;
      
	    --Se nao encontrou 
      IF cr_crapcop%NOTFOUND THEN    
          --Fechar Cursor
          CLOSE cr_crapcop;
          vr_cdcritic:= 0;
          vr_dscritic:= 'Cooperativa nao encontrada.';
          --Levantar Excecao
          RAISE vr_exc_erro;
      END IF;
	  
      --Fechar Cursor
      CLOSE cr_crapcop;

      -- Dados da conta
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO vr_idastcjt,
                            vr_nmprimtl;
      
	    --Se nao encontrou 
      IF cr_crapass%NOTFOUND THEN    
        --Fechar Cursor
        CLOSE cr_crapass;
          vr_cdcritic:= 0;
          vr_dscritic:= 'Registro do cooperado nao encontrado.';
          --Levantar Excecao
          RAISE vr_exc_erro;
      END IF;
      
      --Fechar Cursor
      CLOSE cr_crapass;

      --Consulta do cpf do representante na crapsnh
      OPEN cr_crapsnh(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
			               ,pr_idseqttl => pr_idseqttl);
      FETCH cr_crapsnh INTO vr_nrcpfcgc;
      
	    --Se nao encontrou 
      IF cr_crapsnh%NOTFOUND THEN  
        --Fechar Cursor
        CLOSE cr_crapsnh;  
          vr_cdcritic:= 0;
          vr_dscritic:= 'Registro de senha nao encontrado.';
          --Levantar Excecao
          RAISE vr_exc_erro;
      END IF;
      
      --Fechar Cursor
      CLOSE cr_crapsnh;

      --Se conta exige assinatura multipla
      IF vr_idastcjt = 1 THEN
         --Consulta do nome do Representante
         OPEN cr_crapavt(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrcpfcgc => vr_nrcpfcgc);
         FETCH cr_crapavt INTO vr_nrdctato
                              ,vr_nmprimtl
				                      ,vr_dtvalida;
         
		     --Se nao encontrou 
         IF cr_crapavt%NOTFOUND THEN    
            --Fechar Cursor
            CLOSE cr_crapavt;
            vr_cdcritic:= 0;
            vr_dscritic:= 'Dados do Representante nao encontrado.';
            --Levantar Excecao
            RAISE vr_exc_erro;
         END IF;                             
        
         --Fechar Cursor
         CLOSE cr_crapavt;

         -- Valida data de vigencia do representante 
         IF vr_dtvalida < TRUNC(SYSDATE) THEN
			      vr_cdcritic:= 0;
            vr_dscritic:= 'Operacao indisponivel. A vigencia da procuracao ou atividade de socio esta vencida.';
            --Levantar Excecao
            RAISE vr_exc_erro;
		     END IF;
      END IF;
	  
      vr_cdditens := GENE0002.fn_quebra_string(pr_string  => pr_cdditens, 
                                               pr_delimit => '/');
      
      FOR i IN vr_cdditens.FIRST..vr_cdditens.LAST LOOP
         vr_auxditem := GENE0002.fn_quebra_string(pr_string  => vr_cdditens(i), 
                                                  pr_delimit => '|');
         vr_auxditem := GENE0002.fn_quebra_string(pr_string  => vr_auxditem(1), 
                                                  pr_delimit => ',');
         vr_cddoitem := TO_NUMBER(vr_auxditem(3));
         OPEN cr_tbgen_trans_pend(pr_cddoitem => vr_cddoitem);
         FETCH cr_tbgen_trans_pend INTO rw_tbgen_trans_pend;
                  
         IF cr_tbgen_trans_pend%FOUND THEN
           
            --Fechar Cursor
            CLOSE cr_tbgen_trans_pend;

            OPEN cr_tbgen_aprova_trans_pend(pr_cddoitem => vr_cddoitem,
                                            pr_nrcpfcgc => vr_nrcpfcgc,
                                            pr_inoutros => 0); -- buscar registro do cpf informado
            FETCH cr_tbgen_aprova_trans_pend INTO rw_tbgen_aprova_trans_pend;
			      
			      IF cr_tbgen_aprova_trans_pend%NOTFOUND THEN	
               --Fechar Cursor
               CLOSE cr_tbgen_aprova_trans_pend;
               vr_cdcritic:= 0;
               vr_dscritic:= 'Transacao nao pode ser reprovada pelo representante legal.';
               --Levantar Excecao
               RAISE vr_exc_erro;
			      END IF;
			
            --Fechar Cursor
            CLOSE cr_tbgen_aprova_trans_pend;

			      BEGIN
               --Atualiza para reprovada a transacao
               UPDATE tbgen_trans_pend 
               SET	   tbgen_trans_pend.idsituacao_transacao = 6, -- Reprovada
                       tbgen_trans_pend.dtalteracao_situacao = TRUNC(SYSDATE)
               WHERE   tbgen_trans_pend.cdtransacao_pendente = vr_cddoitem;
            EXCEPTION
               WHEN OTHERS THEN
                    pr_cdcritic:= 0;
                    pr_dscritic:= 'Erro na rotina INET0002.pc_verifica_rep_assinatura. '||SQLERRM;
                    --Levantar Excecao
                    RAISE vr_exc_erro;
            END;
			
            BEGIN
               --Atualiza registro de aprovacao do responsavel legal 
               UPDATE tbgen_aprova_trans_pend
               SET    tbgen_aprova_trans_pend.idsituacao_aprov = 3 -- Reprovada
                     ,tbgen_aprova_trans_pend.dtalteracao_situacao = TRUNC(SYSDATE)
                     ,tbgen_aprova_trans_pend.hralteracao_situacao = gene0002.fn_busca_time
               WHERE  tbgen_aprova_trans_pend.cdtransacao_pendente = vr_cddoitem
               AND    tbgen_aprova_trans_pend.nrcpf_responsavel_aprov = vr_nrcpfcgc;
            EXCEPTION
               WHEN OTHERS THEN
                    pr_cdcritic:= 0;
                    pr_dscritic:= 'Erro na rotina INET0002.pc_verifica_rep_assinatura. '||SQLERRM;
                    --Levantar Excecao
                    RAISE vr_exc_erro;
            END;
			
			      FOR rw_tbgen_aprova_trans_pend IN cr_tbgen_aprova_trans_pend (pr_cddoitem  => vr_cddoitem
                                                                         ,pr_nrcpfcgc  => vr_nrcpfcgc
                                                                         ,pr_inoutros  => 1) LOOP --trazer todos menos o cpf informado
				        OPEN cr_crapavt(pr_cdcooper => pr_cdcooper
							                 ,pr_nrdconta => pr_nrdconta
                               ,pr_nrcpfcgc => rw_tbgen_aprova_trans_pend.nrcpf_responsavel_aprov);
				        FETCH cr_crapavt INTO vr_ncctarep,
									                    vr_nmprimtl,
                                      vr_dtvalida;
                
                --Se nao encontrou 
                IF cr_crapavt%NOTFOUND THEN
                   --Fechar Cursor
                   CLOSE cr_crapavt;
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Registro do representante nao encontrado.';
                   --Levantar Excecao
					         RAISE vr_exc_erro;
				        END IF;				
                --Fechar Cursor
                CLOSE cr_crapavt;              
                
                IF vr_ncctarep > 0 THEN
                   OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => vr_ncctarep);
                   FETCH cr_crapass INTO vr_auxnumbe,
                                         vr_nmprimtl;
                   --Se nao encontrou 
                   IF cr_crapass%NOTFOUND THEN
                      --Fechar Cursor
                      CLOSE cr_crapass;
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Registro do cooperado nao encontrado.';
                       --Levantar Excecao
                       RAISE vr_exc_erro;
                   END IF; 
                   --Fechar Cursor
                   CLOSE cr_crapass;
                END IF;
                
                --Consulta do idseqttl do representante na crapsnh
                OPEN cr_crapsnh2(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => rw_tbgen_aprova_trans_pend.nrdconta
                                ,pr_nrcpfcgc => rw_tbgen_aprova_trans_pend.nrcpf_responsavel_aprov);
                FETCH cr_crapsnh2 INTO vr_idseqttl;
                
                --Se nao encontrou 
                IF cr_crapsnh2%NOTFOUND THEN  
                   --Fechar Cursor
                   CLOSE cr_crapsnh2;  
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Registro de senha nao encontrado.(2)';
                   --Levantar Excecao
                   RAISE vr_exc_erro;
                END IF;
				
                --Fechar Cursor
                CLOSE cr_crapsnh2;

				        vr_tptransa := rw_tbgen_trans_pend.tptransacao;
				
				        -- Criacao de mensagens de transacao
                INET0002.pc_cria_msgs_trans (pr_cdcooper => pr_cdcooper   -- Codigo Cooperativa
                                            ,pr_nrdconta => pr_nrdconta   -- Conta do Associado
                                            ,pr_nrdcaixa => pr_nrdcaixa   -- Numero do caixa
                                            ,pr_cdagenci => pr_cdagenci   -- Numero da agencia
                                            ,pr_cdoperad => pr_cdoperad   -- Numero do operador
                                            ,pr_dtmvtolt => pr_dtmvtolt   -- Data da operacao
                                            ,pr_cdorigem => pr_cdorigem   -- Codigo Origem
                                            ,pr_nmdatela => pr_nmdatela   -- Nome da tela
                                            ,pr_cdtranpe => vr_cddoitem   -- Codigo da Transacao Principal
                                            ,pr_tptransa => vr_tptransa   -- Tipo de Transacao
                                            ,pr_dsdmensg => vr_dsdmensg		-- Descricao da mensagem
                                            ,pr_cdcritic => vr_cdcritic   -- Codigo do erro
                                            ,pr_dscritic => vr_dscritic); -- Descricao do erro
    
                vr_dsdmensg := 'Atenção, ' || vr_nmprimtl || '!<br><br>' ||
                               'Informamos que a seguinte transação foi reprovada:<br><br>' || vr_dsdmensg;
                            
				        -- Gerar mensagem
				        gene0003.pc_gerar_mensagem(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => rw_tbgen_aprova_trans_pend.nrdconta
                                          ,pr_idseqttl => vr_idseqttl
                                          ,pr_cdprogra => 'INET0002'
                                          ,pr_inpriori => 0
                                          ,pr_dsdmensg => vr_dsdmensg
                                          ,pr_dsdassun => 'Transação reprovada'
                                          ,pr_dsdremet => vr_nmrescop
                                          ,pr_dsdplchv => 'Transação reprovada'
                                          ,pr_cdoperad => 1
                                          ,pr_cdcadmsg => 0
                                          ,pr_dscritic => vr_dscritic);
			
			      END LOOP;
			      
			      --Geracao de log 
			      IF  pr_flgerlog = 1 THEN
          
				        gene0001.pc_gera_log( pr_cdcooper => pr_cdcooper
                                     ,pr_cdoperad => pr_cdoperad 
                                     ,pr_dscritic => ''         
                                     ,pr_dsorigem => vr_dsorigem
                                     ,pr_dstransa => vr_dstransa
                                     ,pr_dttransa => pr_dtmvtolt
                                     ,pr_flgtrans => 1
                                     ,pr_hrtransa => gene0002.fn_busca_time
                                     ,pr_idseqttl => 1
                                     ,pr_nmdatela => pr_nmdatela
                                     ,pr_nrdconta => pr_nrdconta
				     		 	                   ,pr_nrdrowid => vr_nrdrowid);
							 
				        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                          pr_nmdcampo => 'Codigo da Transacao Pendente', 
                                          pr_dsdadant => '', 
                                          pr_dsdadatu => TO_CHAR( rw_tbgen_trans_pend.cdtransacao_pendente));
			  
			          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                          pr_nmdcampo => 'Nome do Representante', 
                                          pr_dsdadant => '', 
                                          pr_dsdadatu => vr_nmprimtl);
										
			          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                          pr_nmdcampo => 'CPF do Representante', 
                                          pr_dsdadant => '', 
                                          pr_dsdadatu => TO_CHAR( vr_nrcpfcgc));
			      
            END IF;  --IF  pr_flgerlog = 1 THEN
         ELSE
            --Fechar Cursor
            CLOSE cr_tbgen_trans_pend;
         END IF; --IF cr_tbgen_trans_pend%FOUND THEN
         
      END LOOP;
      
      COMMIT;
      
  EXCEPTION
      WHEN vr_exc_erro THEN
		       IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
			        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
		       END IF;
           pr_cdcritic:= vr_cdcritic;
           pr_dscritic:= vr_dscritic;
		       ROLLBACK;
      WHEN OTHERS THEN
           pr_cdcritic:= 0;
           pr_dscritic:= 'Erro na rotina INET0002.pc_verifica_rep_assinatura. '||SQLERRM;
		       ROLLBACK;
  END;
           
  END pc_reprova_trans_pend;
  
  
  -- Procedure para validacao de representantes legais por transacao
  PROCEDURE pc_valid_repre_legal_trans(pr_cdcooper  IN crapsnh.cdcooper%TYPE
                                      ,pr_nrdconta  IN crapsnh.nrdconta%TYPE
                                      ,pr_idseqttl  IN crapsnh.idseqttl%TYPE
                                      ,pr_flvldrep  IN INTEGER
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_valid_repre_legal_trans
  --  Sistema  : Procedimentos para valicao de representantes legais
  --  Sigla    : CRED
  --  Autor    : Jean Michel
  --  Data     : Dezembro/2015.                   Ultima atualizacao: 08/12/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para validacao de representantes legais
  --
  -- Alteração : 
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
  
  DECLARE  
    -- Cursores
    -- Informacoes sobre a conta
    CURSOR cr_crapass IS
      SELECT
        ass.idastcjt
       ,ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    
    rw_crapass cr_crapass%ROWTYPE;
    
    -- Consulta de poderes
    CURSOR cr_crappod(pr_nrcpfcgc IN crappod.nrcpfpro%TYPE) IS
      SELECT pod.nrdconta
        FROM crappod pod 
       WHERE pod.cdcooper = pr_cdcooper
         AND pod.nrdconta = pr_nrdconta
         AND pod.nrcpfpro = pr_nrcpfcgc
         AND pod.cddpoder = 10
         AND pod.flgconju = 1;

    rw_crappod cr_crappod%ROWTYPE;

    -- Consulta quantidade de responsaveis com poderes de assinatura conjunta
    CURSOR cr_crappod_cont IS
      SELECT COUNT(pod.nrdconta) AS contador
        FROM crappod pod 
       WHERE pod.cdcooper = pr_cdcooper
         AND pod.nrdconta = pr_nrdconta
         AND pod.cddpoder = 10
         AND pod.flgconju = 1;

    rw_crappod_cont cr_crappod_cont%ROWTYPE;
     
    -- Consulta registro de senha para INTERNET
    CURSOR cr_crapsnh IS
      SELECT snh.nrcpfcgc
        FROM crapsnh snh
       WHERE snh.cdcooper = pr_cdcooper
         AND snh.nrdconta = pr_nrdconta
         AND snh.idseqttl = pr_idseqttl
         AND snh.tpdsenha = 1;

    rw_crapsnh cr_crapsnh%ROWTYPE;

    -- Consulta registro de validade de procuracao
    CURSOR cr_crapavt(pr_nrcpfcgc IN crapavt.nrcpfcgc%TYPE) IS
    SELECT avt.dtvalida
		  FROM crapavt avt
		 WHERE avt.cdcooper = pr_cdcooper
		   AND avt.nrdconta = pr_nrdconta
			 AND avt.tpctrato = 6
			 AND avt.nrcpfcgc = pr_nrcpfcgc;

	  rw_crapavt cr_crapavt%ROWTYPE;

    -- Variáveis
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_exec_saida EXCEPTION;
    
  BEGIN
   
  -- Consulta conta 
  OPEN cr_crapass;

  FETCH cr_crapass INTO rw_crapass;

  IF cr_crapass%NOTFOUND THEN
    vr_cdcritic := 9;
    CLOSE cr_crapass;
  ELSE
    CLOSE cr_crapass;
  END IF;

  -- Verifica se conta requer assinatura conjunta
  IF rw_crapass.idastcjt = 1 THEN
    OPEN cr_crappod_cont;
    
    FETCH cr_crappod_cont INTO rw_crappod_cont;
    CLOSE cr_crappod_cont;

    -- Verifica quantidade de procuradores da conta
    IF rw_crappod_cont.contador >= 2 THEN
      IF pr_flvldrep = 1 THEN 
        OPEN cr_crapsnh;

        FETCH cr_crapsnh INTO rw_crapsnh;

        -- Verifica se procurador tem acesso
        IF cr_crapsnh%NOTFOUND THEN
          -- Fecha Cursor
          CLOSE cr_crapsnh;
          vr_dscritic := 'Transacao deve ser registrada por um representante legal.';
          RAISE vr_exec_saida;
        ELSE
          -- Fecha Cursor
          CLOSE cr_crapsnh;
        END IF;

        -- Verifica se procurador tem poder de assinatura conjunta
        OPEN cr_crappod(pr_nrcpfcgc => rw_crapsnh.nrcpfcgc);

        FETCH cr_crappod INTO rw_crappod;

        IF cr_crappod%NOTFOUND THEN
          -- Fecha Cursor
          CLOSE cr_crappod;
          -- Critica por responsavel nao ter poderes de assinatura conjunta
          vr_dscritic := 'Operação disponível somente para representantes legais.';
          RAISE vr_exec_saida;
        ELSE
          CLOSE cr_crappod;
        END IF;

        -- Consulta registro 
        OPEN cr_crapavt(pr_nrcpfcgc => rw_crapsnh.nrcpfcgc);

        FETCH cr_crapavt INTO rw_crapavt;

        -- Verifica registro de procurador
        IF cr_crapavt%NOTFOUND THEN
          -- Fecha Cursor
          CLOSE cr_crapavt;
        ELSE
          -- Fecha Cursor
          CLOSE cr_crapavt;
          
          IF rw_crapavt.dtvalida < SYSDATE THEN
            vr_dscritic := 'Operacao indisponivel. A vigencia da procuracao ou atividade de socio esta vencida.';
            RAISE vr_exec_saida;
          END IF;
        END IF;
      END IF;
    ELSE
      vr_dscritic := 'A conta deve possuir no minimo 2 representantes legais habilitados.';
      RAISE vr_exec_saida;
    END IF;
    
  END IF;

  EXCEPTION
    WHEN vr_exec_saida THEN
      pr_cdcritic := vr_cdcritic;
      
      IF vr_cdcritic <> 0 THEN
         pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE	
         pr_dscritic := vr_dscritic;
      END IF;
        
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na procedure pc_valid_repre_legal_trans. Erro: '|| SQLERRM; 
      ROLLBACK; 
  END;    
  END pc_valid_repre_legal_trans;

  -- Procedure de criacao de transacao de pagamentos
  PROCEDURE pc_cria_trans_pend_pagto(pr_cdagenci  IN crapage.cdagenci%TYPE                     --> Codigo do PA
                                    ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                     --> Numero do Caixa
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE                     --> Codigo do Operados
                                    ,pr_nmdatela  IN craptel.nmdatela%TYPE                     --> Nome da Tela
                                    ,pr_idorigem  IN INTEGER                                   --> Origem da solicitacao
                                    ,pr_idseqttl  IN crapttl.idseqttl%TYPE                     --> Sequencial de Titular            
                                    ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                     --> Numero do cpf do operador juridico
                                    ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                     --> Numero do cpf do representante legal
                                    ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE            --> Cooperativa do Terminal
                                    ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE            --> Agencia do Terminal
                                    ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE            --> Numero do Terminal Financeiro
                                    ,pr_dtmvtolt  IN DATE                                      --> Data do movimento     
                                    ,pr_cdcooper  IN tbpagto_trans_pend.cdcooper%TYPE          --> Codigo da cooperativa
                                    ,pr_nrdconta  IN tbpagto_trans_pend.nrdconta%TYPE          --> Numero da Conta
                                    ,pr_idtippag  IN tbpagto_trans_pend.tppagamento%TYPE       --> Identificacao do tipo de pagamento (1 – Convenio / 2 – Titulo)
                                    ,pr_vllanmto  IN tbpagto_trans_pend.vlpagamento%TYPE       --> Valor do pagamento
                                    ,pr_dtmvtopg  IN tbpagto_trans_pend.dtdebito%TYPE          --> Data do debito
                                    ,pr_idagenda  IN tbpagto_trans_pend.idagendamento%TYPE     --> Indica se o pagamento foi agendado (1 – Online / 2 – Agendamento)
                                    ,pr_dscedent  IN tbpagto_trans_pend.dscedente%TYPE         --> Descricao do cedente do documento
                                    ,pr_dscodbar  IN tbpagto_trans_pend.dscodigo_barras%TYPE   --> Descricao do codigo de barras
                                    ,pr_dslindig  IN tbpagto_trans_pend.dslinha_digitavel%TYPE --> Descricao da linha digitavel
                                    ,pr_vlrdocto  IN tbpagto_trans_pend.vldocumento%TYPE       --> Valor do documento
                                    ,pr_dtvencto  IN tbpagto_trans_pend.dtvencimento%TYPE      --> Data de vencimento do documento
                                    ,pr_tpcptdoc  IN tbpagto_trans_pend.tpcaptura%TYPE         --> Tipo de captura do documento
                                    ,pr_idtitdda  IN tbpagto_trans_pend.idtitulo_dda%TYPE      --> Identificador do titulo no DDA
                                    ,pr_idastcjt  IN crapass.idastcjt%TYPE                     --> Indicador de Assinatura Conjunta
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE                     --> Codigo de Critica
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE) IS                 --> Descricao de Critica
  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_cria_trans_pend_pagto
    --  Sistema  : Procedure de criacao de transacao de pagamentos
    --  Sigla    : CRED
    --  Autor    : Jean Michel
    --  Data     : Dezembro/2015.                   Ultima atualizacao: 03/12/2015
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure de criacao de transacao de pagamentos
    --
    -- Alteração : 
    --
    ---------------------------------------------------------------------------------------------------------------
    BEGIN
      DECLARE
      -- Variáveis
      vr_cdcritic crapcri.cdcritic%TYPE := 0;
      vr_dscritic crapcri.dscritic%TYPE := '';
      vr_exec_saida EXCEPTION;
      vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
      vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas    

    BEGIN
    
    INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nmdatela => pr_nmdatela
                                       ,pr_idorigem => pr_idorigem
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrcpfope => pr_nrcpfope
                                       ,pr_nrcpfrep => pr_nrcpfrep
                                       ,pr_cdcoptfn => pr_cdcoptfn
                                       ,pr_cdagetfn => pr_cdagetfn
                                       ,pr_nrterfin => pr_nrterfin
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdtiptra => 2
                                       ,pr_idastcjt => pr_idastcjt
                                       ,pr_tab_crapavt => vr_tab_crapavt
                                       ,pr_cdtranpe => vr_cdtranpe
                                       ,pr_dscritic => vr_dscritic);
                                         
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exec_saida;
    END IF;

    BEGIN
      INSERT INTO
        tbpagto_trans_pend(
           cdtransacao_pendente 
          ,cdcooper              
          ,nrdconta             
          ,tppagamento          
          ,vlpagamento          
          ,dtdebito             
          ,idagendamento        
          ,dscedente            
          ,dscodigo_barras      
          ,dslinha_digitavel    
          ,vldocumento          
          ,dtvencimento         
          ,tpcaptura            
          ,idtitulo_dda)
        VALUES(
           vr_cdtranpe
          ,pr_cdcooper
          ,pr_nrdconta
          ,pr_idtippag
          ,pr_vllanmto
          ,pr_dtmvtopg
          ,pr_idagenda
          ,pr_dscedent
          ,pr_dscodbar
          ,pr_dslindig
          ,pr_vlrdocto
          ,pr_dtvencto
          ,pr_tpcptdoc
          ,pr_idtitdda);
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao incluir registro tbpagto_trans_pend. Erro: ' || SQLERRM;
    END;

    pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                            ,pr_nrdcaixa => pr_nrdcaixa
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_idorigem => pr_idorigem
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrcpfrep => pr_nrcpfrep
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdtiptra => 2 
                            ,pr_tab_crapavt => vr_tab_crapavt
                            ,pr_cdtranpe => vr_cdtranpe
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
       RAISE vr_exec_saida;
    END IF;

    COMMIT;

  EXCEPTION
    WHEN vr_exec_saida THEN
      pr_cdcritic := vr_cdcritic;
      
      IF vr_cdcritic <> 0 THEN
         pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE	
         pr_dscritic := vr_dscritic;
      END IF;
        
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na procedure pc_cria_trans_pend_pagto. Erro: '|| SQLERRM; 
      ROLLBACK; 
  END;
  END pc_cria_trans_pend_pagto;

  -- Procedure de criacao de transacao de TED
  PROCEDURE pc_cria_trans_pend_ted(pr_cdagenci  IN crapage.cdagenci%TYPE                         --> Codigo do PA
                                  ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                         --> Numero do Caixa
                                  ,pr_cdoperad  IN crapope.cdoperad%TYPE                         --> Codigo do Operados
                                  ,pr_nmdatela  IN craptel.nmdatela%TYPE                         --> Nome da Tela
                                  ,pr_idorigem  IN INTEGER                                       --> Origem da solicitacao
                                  ,pr_idseqttl  IN crapttl.idseqttl%TYPE                         --> Sequencial de Titular            
                                  ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                         --> Numero do cpf do operador juridico
                                  ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                         --> Numero do cpf do representante legal
                                  ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE                --> Cooperativa do Terminal
                                  ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE                --> Agencia do Terminal
                                  ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE                --> Numero do Terminal Financeiro
                                  ,pr_dtmvtolt  IN DATE                                          --> Data do movimento     
                                  ,pr_cdcooper  IN tbspb_trans_pend.cdcooper%TYPE                --> Codigo da cooperativa
                                  ,pr_nrdconta  IN tbspb_trans_pend.nrdconta%TYPE                --> Numero da Conta
                                  ,pr_vllanmto  IN tbspb_trans_pend.vlted%TYPE                   --> Valor de Lancamento
                                  ,pr_nrcpfcnpj IN tbspb_trans_pend.nrcpfcnpj_favorecido%TYPE    --> CPF/CNPJ do Favorecido
                                  ,pr_nmtitula  IN tbspb_trans_pend.nmtitula_favorecido%TYPE     --> Nome to Titular Favorecido
                                  ,pr_tppessoa  IN tbspb_trans_pend.tppessoa_favorecido%TYPE     --> Tipo de pessoa do Favorecido
                                  ,pr_tpconta   IN tbspb_trans_pend.tpconta_favorecido%TYPE      --> Tipo da conta do Favorecido
                                  ,pr_dtmvtopg  IN tbspb_trans_pend.dtdebito%TYPE                --> Data do Pagamento
                                  ,pr_idagenda  IN tbspb_trans_pend.idagendamento%TYPE           --> Indicador de agendamento
                                  ,pr_cddbanco  IN tbspb_trans_pend.cdbanco_favorecido%TYPE      --> Codigo do banco
                                  ,pr_cdageban  IN tbspb_trans_pend.cdagencia_favorecido%TYPE    --> Codigo da agencia bancaria
                                  ,pr_nrctadst  IN tbspb_trans_pend.nrconta_favorecido%TYPE      --> Conta de destino
                                  ,pr_cdfinali  IN tbspb_trans_pend.cdfinalidade%TYPE            --> Codigo da finalidade
                                  ,pr_dstransf  IN tbspb_trans_pend.dscodigo_identificador%TYPE  --> Descricao da transferencia
                                  ,pr_dshistor  IN tbspb_trans_pend.dshistorico%TYPE             --> Descricao do historico
                                  ,pr_nrispbif  IN tbspb_trans_pend.nrispb_banco_favorecido%TYPE --> Codigo unico do banco
                                  ,pr_idastcjt  IN crapass.idastcjt%TYPE                         --> Indicador de Assinatura Conjunta
                                  ,pr_lsdatagd  IN VARCHAR2
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE                         --> Codigo de Critica
                                  ,pr_dscritic OUT crapcri.dscritic%TYPE) IS                     --> Descricao de Critica
  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_cria_trans_pend_ted
    --  Sistema  : Procedure de criacao de transacao de TED
    --  Sigla    : CRED
    --  Autor    : Jean Michel
    --  Data     : Dezembro/2015.                   Ultima atualizacao: 25/02/2016
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedure de criacao de transacao de TED
    --
    -- Alteração : 25/02/2016 - Receber e gravar novos campos das transacoes TED (Marcos-Supero)
    --
    ---------------------------------------------------------------------------------------------------------------
                                     
    -- Variáveis
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_exec_saida EXCEPTION;
    vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas 
    vr_tab_lsdatagd gene0002.typ_split;
    vr_idagenda INTEGER := 0;
    vr_dtmvtopg DATE;    
    
  BEGIN

    IF pr_idagenda > 1 THEN
      vr_idagenda := 2;
    ELSE
      vr_idagenda := pr_idagenda;
    END IF;

    -- Verificar se possui mais de uma data de agendamento
    IF instr(pr_lsdatagd,',') > 0  THEN
      
      -- quebrar string 
      vr_tab_lsdatagd := gene0002.fn_quebra_string(pr_string => pr_lsdatagd, 
                                                   pr_delimit => ',');
          
      -- Varrer loop de datas
      FOR i IN vr_tab_lsdatagd.first..vr_tab_lsdatagd.last LOOP
      
        vr_dtmvtopg := to_date(vr_tab_lsdatagd(i),'DD/MM/RRRR');
        
        INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                           ,pr_nrdcaixa => pr_nrdcaixa
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nmdatela => pr_nmdatela
                                           ,pr_idorigem => pr_idorigem
                                           ,pr_idseqttl => pr_idseqttl
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrcpfope => pr_nrcpfope
                                           ,pr_nrcpfrep => pr_nrcpfrep
                                           ,pr_cdcoptfn => pr_cdcoptfn
                                           ,pr_cdagetfn => pr_cdagetfn
                                           ,pr_nrterfin => pr_nrterfin
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdtiptra => 4
                                           ,pr_idastcjt => pr_idastcjt
                                           ,pr_tab_crapavt => vr_tab_crapavt
                                           ,pr_cdtranpe => vr_cdtranpe
                                           ,pr_dscritic => vr_dscritic);
                                       
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exec_saida;
        END IF;

        BEGIN
          INSERT INTO
            tbspb_trans_pend(
               cdtransacao_pendente
              ,cdcooper               
              ,nrdconta               
              ,vlted                  
              ,dtdebito               
              ,idagendamento          
              ,cdbanco_favorecido     
              ,cdagencia_favorecido   
              ,nrconta_favorecido     
              ,cdfinalidade           
              ,dscodigo_identificador 
              ,dshistorico            
              ,nrispb_banco_favorecido
              ,nrcpfcnpj_favorecido
              ,nmtitula_favorecido 
              ,tppessoa_favorecido 
              ,tpconta_favorecido)
            VALUES(
               vr_cdtranpe
              ,pr_cdcooper
              ,pr_nrdconta
              ,pr_vllanmto
              ,vr_dtmvtopg
              ,pr_idagenda
              ,pr_cddbanco
              ,pr_cdageban
              ,pr_nrctadst
              ,pr_cdfinali
              ,pr_dstransf
              ,pr_dshistor
              ,pr_nrispbif
              ,pr_nrcpfcnpj
              ,pr_nmtitula
              ,pr_tppessoa
              ,pr_tpconta);
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao incluir registro tbspb_trans_pend. Erro: ' || SQLERRM;
        END;

        pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                                ,pr_nrdcaixa => pr_nrdcaixa
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_nmdatela => pr_nmdatela
                                ,pr_idorigem => pr_idorigem
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrcpfrep => pr_nrcpfrep
                                ,pr_dtmvtolt => pr_dtmvtolt
                                ,pr_cdtiptra => 4 
                                ,pr_tab_crapavt => vr_tab_crapavt
                                ,pr_cdtranpe => vr_cdtranpe
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);

        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
           RAISE vr_exec_saida;
        END IF;
      END LOOP;

    ELSE
      
      INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                           ,pr_nrdcaixa => pr_nrdcaixa
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nmdatela => pr_nmdatela
                                           ,pr_idorigem => pr_idorigem
                                           ,pr_idseqttl => pr_idseqttl
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrcpfope => pr_nrcpfope
                                           ,pr_nrcpfrep => pr_nrcpfrep
                                           ,pr_cdcoptfn => pr_cdcoptfn
                                           ,pr_cdagetfn => pr_cdagetfn
                                           ,pr_nrterfin => pr_nrterfin
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdtiptra => 4
                                           ,pr_idastcjt => pr_idastcjt
                                           ,pr_tab_crapavt => vr_tab_crapavt
                                           ,pr_cdtranpe => vr_cdtranpe
                                           ,pr_dscritic => vr_dscritic);
                                           
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exec_saida;
        END IF;

        BEGIN
          INSERT INTO
            tbspb_trans_pend(
               cdtransacao_pendente
              ,cdcooper               
              ,nrdconta               
              ,vlted                  
              ,dtdebito               
              ,idagendamento          
              ,cdbanco_favorecido     
              ,cdagencia_favorecido   
              ,nrconta_favorecido     
              ,cdfinalidade           
              ,dscodigo_identificador 
              ,dshistorico            
              ,nrispb_banco_favorecido
              ,nrcpfcnpj_favorecido
              ,nmtitula_favorecido 
              ,tppessoa_favorecido 
              ,tpconta_favorecido)
            VALUES(
               vr_cdtranpe
              ,pr_cdcooper
              ,pr_nrdconta
              ,pr_vllanmto
              ,pr_dtmvtopg
              ,vr_idagenda
              ,pr_cddbanco
              ,pr_cdageban
              ,pr_nrctadst
              ,pr_cdfinali
              ,pr_dstransf
              ,pr_dshistor
              ,pr_nrispbif
              ,pr_nrcpfcnpj
              ,pr_nmtitula
              ,pr_tppessoa
              ,pr_tpconta);
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao incluir registro tbspb_trans_pend. Erro: ' || SQLERRM;
        END;

        pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                                ,pr_nrdcaixa => pr_nrdcaixa
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_nmdatela => pr_nmdatela
                                ,pr_idorigem => pr_idorigem
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrcpfrep => pr_nrcpfrep
                                ,pr_dtmvtolt => pr_dtmvtolt
                                ,pr_cdtiptra => 4 
                                ,pr_tab_crapavt => vr_tab_crapavt
                                ,pr_cdtranpe => vr_cdtranpe
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);

        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
           RAISE vr_exec_saida;
        END IF;
    
    END IF;      
      
    COMMIT;

  EXCEPTION
    WHEN vr_exec_saida THEN
      pr_cdcritic := vr_cdcritic;
      
      IF vr_cdcritic <> 0 THEN
         pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE	
         pr_dscritic := vr_dscritic;
      END IF;
        
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na procedure pc_cria_trans_pend_ted. Erro: '|| SQLERRM; 
      ROLLBACK; 
  END pc_cria_trans_pend_ted;

  -- Procedure de criacao de transacao de transferencia
  PROCEDURE pc_cria_trans_pend_transf(pr_cdtiptra  IN INTEGER                                         --> Tipo da Transacao
                                     ,pr_cdagenci  IN crapage.cdagenci%TYPE                           --> Codigo do PA
                                     ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                           --> Numero do Caixa
                                     ,pr_cdoperad  IN crapope.cdoperad%TYPE                           --> Codigo do Operados
                                     ,pr_nmdatela  IN craptel.nmdatela%TYPE                           --> Nome da Tela
                                     ,pr_idorigem  IN INTEGER                                         --> Origem da solicitacao
                                     ,pr_idseqttl  IN crapttl.idseqttl%TYPE                           --> Sequencial de Titular               
                                     ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                           --> Numero do cpf do operador juridico
                                     ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                           --> Numero do cpf do representante legal
                                     ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE                  --> Cooperativa do Terminal
                                     ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE                  --> Agencia do Terminal
                                     ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE                  --> Numero do Terminal Financeiro
                                     ,pr_dtmvtolt  IN DATE                                            --> Data do movimento     
                                     ,pr_cdcooper  IN tbtransf_trans_pend.cdcooper%TYPE               --> Codigo da cooperativa
                                     ,pr_nrdconta  IN tbtransf_trans_pend.nrdconta%TYPE               --> Numero da Conta
                                     ,pr_vllanmto  IN tbtransf_trans_pend.vltransferencia%TYPE        --> Valor de Lancamento
                                     ,pr_dtmvtopg  IN tbtransf_trans_pend.dtdebito%TYPE               --> Data do Pagamento
                                     ,pr_idagenda  IN tbtransf_trans_pend.idagendamento%TYPE          --> Indicador de agendamento
                                     ,pr_cdageban  IN tbtransf_trans_pend.cdagencia_coop_destino%TYPE --> Codigo da agencia bancaria
                                     ,pr_nrctadst  IN tbtransf_trans_pend.nrconta_destino%TYPE        --> Conta de destino
                                     ,pr_lsdatagd  IN VARCHAR2                                        --> Lista de datas para agendamento
                                     ,pr_idastcjt  IN crapass.idastcjt%TYPE                           --> Indicador de Assinatura Conjunta
 									                   ,pr_flmobile  IN tbtransf_trans_pend.indmobile%TYPE              --> Indicador Mobile
									                   ,pr_idtipcar  IN tbtransf_trans_pend.indtipo_cartao%TYPE         --> Indicador Tipo Cartão Utilizado
									                   ,pr_nrcartao  IN tbtransf_trans_pend.nrcartao%TYPE               --> Numero Cartao
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE                           --> Codigo de Critica
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE) IS                       --> Descricao de Critica
  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_cria_trans_pend_transf
    --  Sistema  : Procedimentos de criacao de transacao de transferencia
    --  Sigla    : CRED
    --  Autor    : Jean Michel
    --  Data     : Dezembro/2015.                   Ultima atualizacao: 03/12/2015
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedimentos de criacao de transacao de transferencia
    --
    -- Alteração : 
    --
    ---------------------------------------------------------------------------------------------------------------
    
    -- Variáveis
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_exec_saida EXCEPTION;
    vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_dtmvtopg DATE;
    vr_tab_lsdatagd gene0002.typ_split;
    vr_idagenda INTEGER := 0;
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas
  BEGIN
   
    IF pr_idagenda > 1 THEN
      vr_idagenda := 2;
    ELSE
      vr_idagenda := pr_idagenda;
    END IF;

    -- Verificar se possui mais de uma data de agendamento
    IF instr(pr_lsdatagd,',') > 0  THEN
      
      -- quebrar string 
      vr_tab_lsdatagd := gene0002.fn_quebra_string(pr_string => pr_lsdatagd, 
                                                   pr_delimit => ',');
          
      -- Varrer loop de datas
      FOR i IN vr_tab_lsdatagd.first..vr_tab_lsdatagd.last LOOP
      
        vr_dtmvtopg := to_date(vr_tab_lsdatagd(i),'DD/MM/RRRR');

        INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                           ,pr_nrdcaixa => pr_nrdcaixa
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nmdatela => pr_nmdatela
                                           ,pr_idorigem => pr_idorigem
                                           ,pr_idseqttl => pr_idseqttl
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrcpfope => pr_nrcpfope
                                           ,pr_nrcpfrep => pr_nrcpfrep
                                           ,pr_cdcoptfn => pr_cdcoptfn
                                           ,pr_cdagetfn => pr_cdagetfn
                                           ,pr_nrterfin => pr_nrterfin
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_cdtiptra => pr_cdtiptra
                                           ,pr_idastcjt => pr_idastcjt
                                           ,pr_tab_crapavt => vr_tab_crapavt
                                           ,pr_cdtranpe => vr_cdtranpe
                                           ,pr_dscritic => vr_dscritic);
                                       
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exec_saida;
        END IF;

        BEGIN
          INSERT INTO
            tbtransf_trans_pend(
               cdtransacao_pendente  
              ,cdcooper              
              ,nrdconta              
              ,vltransferencia       
              ,dtdebito              
              ,idagendamento         
              ,cdagencia_coop_destino 
              ,nrconta_destino
			        ,indmobile
			        ,indtipo_cartao
			        ,nrcartao)
            VALUES(
               vr_cdtranpe          
              ,pr_cdcooper
              ,pr_nrdconta
              ,pr_vllanmto
              ,vr_dtmvtopg
              ,vr_idagenda
              ,pr_cdageban
              ,pr_nrctadst
			        ,pr_flmobile
			        ,pr_idtipcar
			        ,pr_nrcartao);
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao incluir registro tbtransf_trans_pend. Erro: ' || SQLERRM;
        END;

        pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                            ,pr_nrdcaixa => pr_nrdcaixa
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_idorigem => pr_idorigem
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrcpfrep => pr_nrcpfrep
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdtiptra => pr_cdtiptra
                            ,pr_tab_crapavt => vr_tab_crapavt
                            ,pr_cdtranpe => vr_cdtranpe
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
           RAISE vr_exec_saida;
        END IF;

      END LOOP;

    ELSE -- se existir somente um registro para criar
      INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                         ,pr_nrdcaixa => pr_nrdcaixa
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nmdatela => pr_nmdatela
                                         ,pr_idorigem => pr_idorigem
                                         ,pr_idseqttl => pr_idseqttl
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrcpfope => pr_nrcpfope
                                         ,pr_nrcpfrep => pr_nrcpfrep
                                         ,pr_cdcoptfn => pr_cdcoptfn
                                         ,pr_cdagetfn => pr_cdagetfn
                                         ,pr_nrterfin => pr_nrterfin
                                         ,pr_dtmvtolt => pr_dtmvtolt
                                         ,pr_cdtiptra => pr_cdtiptra
                                         ,pr_idastcjt => pr_idastcjt
                                         ,pr_tab_crapavt => vr_tab_crapavt
                                         ,pr_cdtranpe => vr_cdtranpe
                                         ,pr_dscritic => vr_dscritic);
                                       
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exec_saida;
      END IF;

      BEGIN
        INSERT INTO
          tbtransf_trans_pend(
             cdtransacao_pendente  
            ,cdcooper              
            ,nrdconta              
            ,vltransferencia       
            ,dtdebito              
            ,idagendamento         
            ,cdagencia_coop_destino 
            ,nrconta_destino
			      ,indmobile
			      ,indtipo_cartao
			      ,nrcartao)
          VALUES(
             vr_cdtranpe          
            ,pr_cdcooper
            ,pr_nrdconta
            ,pr_vllanmto
            ,pr_dtmvtopg
            ,vr_idagenda
            ,pr_cdageban
            ,pr_nrctadst
			      ,pr_flmobile
			      ,pr_idtipcar
			      ,pr_nrcartao);
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao incluir registro tbtransf_trans_pend. Erro: ' || SQLERRM;
      END;
      
      pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                            ,pr_nrdcaixa => pr_nrdcaixa
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_idorigem => pr_idorigem
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrcpfrep => pr_nrcpfrep
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdtiptra => pr_cdtiptra
                            ,pr_tab_crapavt => vr_tab_crapavt
                            ,pr_cdtranpe => vr_cdtranpe
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
         RAISE vr_exec_saida;
      END IF;

    END IF;

    COMMIT;

  EXCEPTION
    WHEN vr_exec_saida THEN
      pr_cdcritic := vr_cdcritic;
      
      IF vr_cdcritic <> 0 THEN
         pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE	
         pr_dscritic := vr_dscritic;
      END IF;
        
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na procedure pc_cria_trans_pend_transf. Erro: '|| SQLERRM; 
      ROLLBACK; 
  END pc_cria_trans_pend_transf;

  -- Procedure de criacao de transacao de credito pré-aprovado
  PROCEDURE pc_cria_trans_pend_credito(pr_cdagenci  IN crapage.cdagenci%TYPE                   --> Codigo do PA
                                      ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                   --> Numero do Caixa
                                      ,pr_cdoperad  IN crapope.cdoperad%TYPE                   --> Codigo do Operados
                                      ,pr_nmdatela  IN craptel.nmdatela%TYPE                   --> Nome da Tela
                                      ,pr_idorigem  IN INTEGER                                 --> Origem da solicitacao
                                      ,pr_idseqttl  IN crapttl.idseqttl%TYPE                   --> Sequencial de Titular               
                                      ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                   --> Numero do cpf do operador juridico
                                      ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                   --> Numero do cpf do representante legal
                                      ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE          --> Cooperativa do Terminal
                                      ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE          --> Agencia do Terminal
                                      ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE          --> Numero do Terminal Financeiro
                                      ,pr_dtmvtolt  IN DATE                                    --> Data do movimento     
                                      ,pr_cdcooper  IN tbtransf_trans_pend.cdcooper%TYPE       --> Codigo da cooperativa
                                      ,pr_nrdconta  IN tbtransf_trans_pend.nrdconta%TYPE       --> Numero da Conta
                                      ,pr_vlemprst  IN tbepr_trans_pend.vlemprestimo%TYPE      --> Valor do emprestimo
                                      ,pr_qtpreemp  IN tbepr_trans_pend.nrparcelas%TYPE        --> Numero de parcelas
                                      ,pr_vlpreemp  IN tbepr_trans_pend.vlparcela%TYPE         --> Valor da parcela
                                      ,pr_dtdpagto  IN tbepr_trans_pend.dtprimeiro_vencto%TYPE --> Data de vencimento da primeira parcela	
                                      ,pr_percetop  IN tbepr_trans_pend.vlpercentual_cet%TYPE  --> Valor percentual do CET
                                      ,pr_vlrtarif  IN tbepr_trans_pend.vltarifa%TYPE          --> Valor da tarifa do emprestimo
                                      ,pr_txmensal  IN tbepr_trans_pend.vltaxa_mensal%TYPE     --> Valor da taxa mensal de juros
                                      ,pr_vltariof  IN tbepr_trans_pend.vliof%TYPE             --> Valor de IOF
                                      ,pr_vltaxiof  IN tbepr_trans_pend.vlpercentual_iof%TYPE  --> Valor percentual do IOF
                                      ,pr_idastcjt  IN crapass.idastcjt%TYPE                   --> Indicador de Assinatura Conjunta
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE                   --> Codigo de Critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE) IS               --> Descricao de Critica
  
    -- Variáveis
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_exec_saida EXCEPTION;
    vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas
  BEGIN
    
    INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nmdatela => pr_nmdatela
                                       ,pr_idorigem => pr_idorigem
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrcpfope => pr_nrcpfope
                                       ,pr_nrcpfrep => pr_nrcpfrep
                                       ,pr_cdcoptfn => pr_cdcoptfn
                                       ,pr_cdagetfn => pr_cdagetfn
                                       ,pr_nrterfin => pr_nrterfin
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdtiptra => 6
                                       ,pr_idastcjt => pr_idastcjt
                                       ,pr_tab_crapavt => vr_tab_crapavt
                                       ,pr_cdtranpe => vr_cdtranpe
                                       ,pr_dscritic => vr_dscritic);
                                         
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exec_saida;
    END IF;

    BEGIN
      INSERT INTO
        tbepr_trans_pend(
           cdtransacao_pendente 
          ,cdcooper              
          ,nrdconta             
          ,vlemprestimo         
          ,nrparcelas           
          ,vlparcela            
          ,dtprimeiro_vencto       
          ,vlpercentual_cet     
          ,vltarifa             
          ,vltaxa_mensal        
          ,vliof                
          ,vlpercentual_iof)
        VALUES(
           vr_cdtranpe
          ,pr_cdcooper
          ,pr_nrdconta
          ,pr_vlemprst
          ,pr_qtpreemp
          ,pr_vlpreemp
          ,pr_dtdpagto
          ,pr_percetop
          ,pr_vlrtarif
          ,pr_txmensal
          ,pr_vltariof
          ,pr_vltaxiof);
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao incluir registro tbepr_trans_pend. Erro: ' || SQLERRM;
    END;
    
    pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                            ,pr_nrdcaixa => pr_nrdcaixa
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_idorigem => pr_idorigem
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrcpfrep => pr_nrcpfrep
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdtiptra => 6
                            ,pr_tab_crapavt => vr_tab_crapavt
                            ,pr_cdtranpe => vr_cdtranpe
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
       RAISE vr_exec_saida;
    END IF;

    COMMIT;

  EXCEPTION
    WHEN vr_exec_saida THEN
      pr_cdcritic := vr_cdcritic;
      
      IF vr_cdcritic <> 0 THEN
         pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE	
         pr_dscritic := vr_dscritic;
      END IF;
        
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na procedure pc_cria_trans_pend_credito. Erro: '|| SQLERRM; 
      ROLLBACK; 
  END pc_cria_trans_pend_credito;

  -- Procedure de criacao de transacao de aplicacoes
  PROCEDURE pc_cria_trans_pend_aplica(pr_cdagenci  IN crapage.cdagenci%TYPE                        --> Codigo do PA
                                     ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                        --> Numero do Caixa
                                     ,pr_cdoperad  IN crapope.cdoperad%TYPE                        --> Codigo do Operados
                                     ,pr_nmdatela  IN craptel.nmdatela%TYPE                        --> Nome da Tela
                                     ,pr_idorigem  IN INTEGER                                      --> Origem da solicitacao
                                     ,pr_idseqttl  IN crapttl.idseqttl%TYPE                        --> Sequencial de Titular               
                                     ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                        --> Numero do cpf do operador juridico
                                     ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                        --> Numero do cpf do representante legal
                                     ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE               --> Cooperativa do Terminal
                                     ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE               --> Agencia do Terminal
                                     ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE               --> Numero do Terminal Financeiro
                                     ,pr_dtmvtolt  IN DATE                                         --> Data do movimento     
                                     ,pr_cdcooper  IN tbtransf_trans_pend.cdcooper%TYPE            --> Codigo da cooperativa
                                     ,pr_nrdconta  IN tbtransf_trans_pend.nrdconta%TYPE            --> Numero da Conta
                                     ,pr_idoperac  IN tbcapt_trans_pend.tpoperacao%TYPE            --> Identifica tipo da operacao (1 – Cancelamento Aplicacao / 2 – Resgate / 3 – Agendamento Resgate / 4 – Cancelamento Total Agendamento / 5 – Cancelamento Item Agendamento)
                                     ,pr_idtipapl  IN tbcapt_trans_pend.tpaplicacao%TYPE           --> Tipo da aplicacao (A – Antigos Produtos / N – Novos Produtos)
                                     ,pr_nraplica  IN tbcapt_trans_pend.nraplicacao%TYPE           --> Numero da aplicacao
                                     ,pr_cdprodut  IN tbcapt_trans_pend.cdproduto_aplicacao%TYPE   --> Codigo do produto da aplicacao
                                     ,pr_tpresgat  IN tbcapt_trans_pend.tpresgate%TYPE             --> Indicador do tipo de resgate (1 – Parcial / 2 – Total)
                                     ,pr_vlresgat  IN tbcapt_trans_pend.vlresgate%TYPE             --> Valor do resgate
                                     ,pr_nrdocmto  IN tbcapt_trans_pend.nrdocto_agendamento%TYPE   --> Numero de documento do agendamento
                                     ,pr_idtipage  IN tbcapt_trans_pend.tpagendamento%TYPE         --> Identifica o tipo de agendamento (0 – Aplicacao / 1 – Resgate)
                                     ,pr_idperage  IN tbcapt_trans_pend.idperiodo_agendamento%TYPE --> Identifica a periodicidade do agendamento (0 – Unico / 1 – Mensal)
                                     ,pr_qtmesage  IN tbcapt_trans_pend.qtmeses_agendamento%TYPE   --> Quantidade de meses do agendamento
                                     ,pr_dtdiaage  IN tbcapt_trans_pend.nrdia_agendamento%TYPE     --> Dia em que o agendamento deve ser efetivado
                                     ,pr_dtiniage  IN tbcapt_trans_pend.dtinicio_agendamento%TYPE  --> Data de inicio do agendamento
                                     ,pr_idastcjt  IN crapass.idastcjt%TYPE                        --> Indicador de Assinatura Conjunta
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE                        --> Codigo de Critica
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE) IS                    --> Descricao de Critica
  
    -- Variáveis
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_exec_saida EXCEPTION;
    vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas
  BEGIN
    
    INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nmdatela => pr_nmdatela
                                       ,pr_idorigem => pr_idorigem
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrcpfope => pr_nrcpfope
                                       ,pr_nrcpfrep => pr_nrcpfrep
                                       ,pr_cdcoptfn => pr_cdcoptfn
                                       ,pr_cdagetfn => pr_cdagetfn
                                       ,pr_nrterfin => pr_nrterfin
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdtiptra => 7
                                       ,pr_idastcjt => pr_idastcjt
                                       ,pr_tab_crapavt => vr_tab_crapavt
                                       ,pr_cdtranpe => vr_cdtranpe
                                       ,pr_dscritic => vr_dscritic);
                                         
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exec_saida;
    END IF;

    BEGIN
      INSERT INTO
        tbcapt_trans_pend(
           cdtransacao_pendente  
          ,cdcooper                   
          ,nrdconta                  
          ,tpoperacao                
          ,tpaplicacao               
          ,nraplicacao               
          ,cdproduto_aplicacao         
          ,tpresgate                 
          ,vlresgate                 
          ,nrdocto_agendamento       
          ,tpagendamento             
          ,idperiodo_agendamento
          ,qtmeses_agendamento  
          ,nrdia_agendamento    
          ,dtinicio_agendamento)
        VALUES(
           vr_cdtranpe
          ,pr_cdcooper
          ,pr_nrdconta
          ,pr_idoperac
          ,pr_idtipapl
          ,pr_nraplica
          ,pr_cdprodut
          ,pr_tpresgat
          ,pr_vlresgat
          ,pr_nrdocmto
          ,pr_idtipage
          ,pr_idperage
          ,pr_qtmesage
          ,pr_dtdiaage
          ,pr_dtiniage);
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao incluir registro tbcapt_trans_pend. Erro: ' || SQLERRM;
    END;
    
    pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                            ,pr_nrdcaixa => pr_nrdcaixa
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_idorigem => pr_idorigem
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrcpfrep => pr_nrcpfrep
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdtiptra => 7
                            ,pr_tab_crapavt => vr_tab_crapavt
                            ,pr_cdtranpe => vr_cdtranpe
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
       RAISE vr_exec_saida;
    END IF;

    COMMIT;

  EXCEPTION
    WHEN vr_exec_saida THEN
      pr_cdcritic := vr_cdcritic;
      
      IF vr_cdcritic <> 0 THEN
         pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE	
         pr_dscritic := vr_dscritic;
      END IF;
        
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na procedure pc_cria_trans_pend_aplica. Erro: '|| SQLERRM; 
      ROLLBACK; 
  END pc_cria_trans_pend_aplica;

  -- Procedure de criacao de transacao de debitos automaticos
  PROCEDURE pc_cria_trans_pend_deb_aut(pr_cdagenci  IN crapage.cdagenci%TYPE                      --> Codigo do PA
                                      ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                      --> Numero do Caixa
                                      ,pr_cdoperad  IN crapope.cdoperad%TYPE                      --> Codigo do Operados
                                      ,pr_nmdatela  IN craptel.nmdatela%TYPE                      --> Nome da Tela
                                      ,pr_idorigem  IN INTEGER                                    --> Origem da solicitacao
                                      ,pr_idseqttl  IN crapttl.idseqttl%TYPE                      --> Sequencial de Titular               
                                      ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do operador juridico
                                      ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do representante legal
                                      ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE             --> Cooperativa do Terminal
                                      ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE             --> Agencia do Terminal
                                      ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE             --> Numero do Terminal Financeiro
                                      ,pr_dtmvtolt  IN DATE                                       --> Data do movimento     
                                      ,pr_cdcooper  IN tbtransf_trans_pend.cdcooper%TYPE          --> Codigo da cooperativa
                                      ,pr_nrdconta  IN tbtransf_trans_pend.nrdconta%TYPE          --> Numero da Conta
                                      ,pr_idoperac  IN tbconv_trans_pend.tpoperacao%TYPE          --> Identifica tipo da operacao (1 – Autorizacao Debito Automatico / 2 – Bloqueio Debito Automatico / 3 – Desbloqueio Debito Automatico)
                                      ,pr_cdhisdeb  IN tbconv_trans_pend.cdhist_convenio%TYPE     --> Codigo do historico do convenio
                                      ,pr_idconsum  IN tbconv_trans_pend.iddebito_automatico%TYPE --> Identificacao do debito automatico
                                      ,pr_dshisext  IN tbconv_trans_pend.dshist_debito%TYPE       --> Descricao complementar do historico do debito
                                      ,pr_vlmaxdeb  IN tbconv_trans_pend.vlmaximo_debito%TYPE     --> Valor maximo do debito
                                      ,pr_cdempcon  IN tbconv_trans_pend.cdconven%TYPE            --> Codigo do convenio
                                      ,pr_cdsegmto  IN tbconv_trans_pend.cdsegmento_conven%TYPE   --> Codigo do segmento do convenio
                                      ,pr_dtmvtopg  IN tbconv_trans_pend.dtdebito_fatura%TYPE     --> Data de debito automatico da fatura
                                      ,pr_nrdocmto  IN tbconv_trans_pend.nrdocumento_fatura%TYPE  --> Numero do documento da fatura
                                      ,pr_idastcjt  IN crapass.idastcjt%TYPE                      --> Indicador de Assinatura Conjunta
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE                      --> Codigo de Critica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE) IS                  --> Descricao de Critica
  
    -- Variáveis
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_exec_saida EXCEPTION;
    vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas
  BEGIN
    
    INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nmdatela => pr_nmdatela
                                       ,pr_idorigem => pr_idorigem
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrcpfope => pr_nrcpfope
                                       ,pr_nrcpfrep => pr_nrcpfrep
                                       ,pr_cdcoptfn => pr_cdcoptfn
                                       ,pr_cdagetfn => pr_cdagetfn
                                       ,pr_nrterfin => pr_nrterfin
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdtiptra => 8
                                       ,pr_idastcjt => pr_idastcjt
                                       ,pr_tab_crapavt => vr_tab_crapavt
                                       ,pr_cdtranpe => vr_cdtranpe
                                       ,pr_dscritic => vr_dscritic);
                                         
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exec_saida;
    END IF;

    BEGIN
      INSERT INTO
        tbconv_trans_pend(
           cdtransacao_pendente   
          ,cdcooper                    
          ,nrdconta                   
          ,tpoperacao                 
          ,cdhist_convenio            
          ,iddebito_automatico        
          ,dshist_debito                
          ,vlmaximo_debito            
          ,cdconven                   
          ,cdsegmento_conven          
          ,dtdebito_fatura            
          ,nrdocumento_fatura )
        VALUES(
           vr_cdtranpe
          ,pr_cdcooper
          ,pr_nrdconta
          ,pr_idoperac
          ,pr_cdhisdeb
          ,pr_idconsum
          ,pr_dshisext
          ,pr_vlmaxdeb
          ,pr_cdempcon
          ,pr_cdsegmto
          ,pr_dtmvtopg
          ,pr_nrdocmto);
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao incluir registro tbconv_trans_pend. Erro: ' || SQLERRM;
    END;
   
    pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                            ,pr_nrdcaixa => pr_nrdcaixa
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_idorigem => pr_idorigem
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrcpfrep => pr_nrcpfrep
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdtiptra => 8
                            ,pr_tab_crapavt => vr_tab_crapavt
                            ,pr_cdtranpe => vr_cdtranpe
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
       RAISE vr_exec_saida;
    END IF;

    COMMIT;

  EXCEPTION
    WHEN vr_exec_saida THEN
      pr_cdcritic := vr_cdcritic;
      
      IF vr_cdcritic <> 0 THEN
         pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE	
         pr_dscritic := vr_dscritic;
      END IF;
        
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na procedure pc_cria_trans_pend_deb_aut. Erro: '|| SQLERRM; 
      ROLLBACK; 
  END pc_cria_trans_pend_deb_aut;

  -- Procedure de criacao de transacao de folha de pagamento
  PROCEDURE pc_cria_trans_pend_folha(pr_cdagenci  IN crapage.cdagenci%TYPE                      --> Codigo do PA
                                    ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                      --> Numero do Caixa
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE                      --> Codigo do Operados
                                    ,pr_nmdatela  IN craptel.nmdatela%TYPE                      --> Nome da Tela
                                    ,pr_idorigem  IN INTEGER                                    --> Origem da solicitacao
                                    ,pr_idseqttl  IN crapttl.idseqttl%TYPE                      --> Sequencial de Titular               
                                    ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do operador juridico
                                    ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do representante legal
                                    ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE             --> Cooperativa do Terminal
                                    ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE             --> Agencia do Terminal
                                    ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE             --> Numero do Terminal Financeiro
                                    ,pr_dtmvtolt  IN DATE                                       --> Data do movimento     
                                    ,pr_cdcooper  IN tbtransf_trans_pend.cdcooper%TYPE          --> Codigo da cooperativa
                                    ,pr_nrdconta  IN tbtransf_trans_pend.nrdconta%TYPE          --> Numero da Conta
                                    ,pr_flsolest  IN tbfolha_trans_pend.idestouro%TYPE          --> Indicador de solicitacao de estouro de conta (0 – Nao / 1 – Sim)
                                    ,pr_indrowid  IN VARCHAR2                                   --> Lista de ROWIDS
                                    ,pr_idastcjt  IN crapass.idastcjt%TYPE                      --> Indicador de Assinatura Conjunta
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE                      --> Codigo de Critica
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE) IS                  --> Descricao de Critica
  
    -- Busca o valor da tarifa
    CURSOR cr_pfp_cfp(pr_rowid VARCHAR2) IS
       SELECT pfp.dtdebito
             ,pfp.vltarapr
             ,pfp.idopdebi
             ,pfp.vllctpag
             ,pfp.qtlctpag
             ,pfp.nrseqpag
             ,pfp.cdempres
             ,folh0001.fn_valor_tarifa_folha(pr_cdcooper,emp.nrdconta,emp.cdcontar,pfp.idopdebi,pfp.vllctpag) vltarifa
         FROM crapemp emp
             ,crappfp pfp
        WHERE pfp.rowid    = pr_rowid
          AND pfp.cdcooper = emp.cdcooper
          AND pfp.cdempres = emp.cdempres;
    rw_pfp_cfp cr_pfp_cfp%ROWTYPE;
    
    -- Variáveis
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_exec_saida EXCEPTION;
    vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_indrowid GENE0002.typ_split;
    vr_rowid    VARCHAR2(50);
    vr_dtdebpfp crappfp.dtdebito%TYPE;
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas
  BEGIN
    
    -- Quebra a string contendo o rowid separado por virgula
    vr_indrowid := gene0002.fn_quebra_string(pr_string => pr_indrowid, pr_delimit => ',');

    -- Para cada registro selecionado, faremos as validacoes necessarias
    FOR vr_index IN 1..vr_indrowid.COUNT() LOOP
      -- ROWID do pagamento
      vr_rowid := vr_indrowid(vr_index);

      -- Busca o valor da tarifa e a data de debito
      OPEN  cr_pfp_cfp(pr_rowid => vr_rowid);
      FETCH cr_pfp_cfp INTO rw_pfp_cfp;
      CLOSE cr_pfp_cfp;

      -- Caso seja a primeira vez guarda a data de debito
      IF vr_dtdebpfp IS NULL THEN
        vr_dtdebpfp := rw_pfp_cfp.dtdebito;
      END IF;

      INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nmdatela => pr_nmdatela
                                       ,pr_idorigem => pr_idorigem
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrcpfope => pr_nrcpfope
                                       ,pr_nrcpfrep => pr_nrcpfrep
                                       ,pr_cdcoptfn => pr_cdcoptfn
                                       ,pr_cdagetfn => pr_cdagetfn
                                       ,pr_nrterfin => pr_nrterfin
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdtiptra => 9
                                       ,pr_idastcjt => pr_idastcjt
                                       ,pr_tab_crapavt => vr_tab_crapavt
                                       ,pr_cdtranpe => vr_cdtranpe
                                       ,pr_dscritic => vr_dscritic);
                                         
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exec_saida;
      END IF;

      BEGIN
        INSERT INTO
          tbfolha_trans_pend(
             cdtransacao_pendente   
            ,cdcooper                     
            ,nrdconta                    
            ,cdempres                    
            ,nrsequencia_folha           
            ,idestouro                   
            ,vlfolha                       
            ,nrlanctos                   
            ,dtdebito                    
            ,vltarifa                    
            ,idopcao_debito)
          VALUES(
             vr_cdtranpe
            ,pr_cdcooper
            ,pr_nrdconta
            ,rw_pfp_cfp.cdempres
            ,rw_pfp_cfp.nrseqpag
            ,pr_flsolest
            ,rw_pfp_cfp.vllctpag
            ,rw_pfp_cfp.qtlctpag
            ,rw_pfp_cfp.dtdebito
            ,rw_pfp_cfp.vltarapr
            ,rw_pfp_cfp.idopdebi);

      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao incluir registro tbfolha_trans_pend. Erro: ' || SQLERRM;
      END;  
      
      pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                              ,pr_nrdcaixa => pr_nrdcaixa
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_idorigem => pr_idorigem
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrcpfrep => pr_nrcpfrep
                              ,pr_dtmvtolt => pr_dtmvtolt
                              ,pr_cdtiptra => 9
                              ,pr_tab_crapavt => vr_tab_crapavt
                              ,pr_cdtranpe => vr_cdtranpe
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
         RAISE vr_exec_saida;
      END IF;
      
    END LOOP; -- vr_indrowid
 
    COMMIT;

  EXCEPTION
    WHEN vr_exec_saida THEN
      pr_cdcritic := vr_cdcritic;
      
      IF vr_cdcritic <> 0 THEN
         pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE	
         pr_dscritic := vr_dscritic;
      END IF;
        
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na procedure pc_cria_trans_pend_folha. Erro: '|| SQLERRM; 
      ROLLBACK; 
  END pc_cria_trans_pend_folha;

   PROCEDURE pc_cria_trans_pend_pacote_tar (pr_cdagenci  IN crapage.cdagenci%TYPE                      --> Codigo do PA
																					,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                      --> Numero do Caixa
																					,pr_cdoperad  IN crapope.cdoperad%TYPE                      --> Codigo do Operados
																					,pr_nmdatela  IN craptel.nmdatela%TYPE                      --> Nome da Tela
																					,pr_idorigem  IN INTEGER                                    --> Origem da solicitacao
																					,pr_idseqttl  IN crapttl.idseqttl%TYPE                      --> Sequencial de Titular               
																					,pr_nrcpfope  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do operador juridico
																					,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                      --> Numero do cpf do representante legal
																					,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE             --> Cooperativa do Terminal
																					,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE             --> Agencia do Terminal
																					,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE             --> Numero do Terminal Financeiro
																					,pr_dtmvtolt  IN DATE                                       --> Data do movimento     
																					,pr_cdcooper  IN tbtarif_pacote_trans_pend.cdcooper%TYPE    --> Codigo da cooperativa
																					,pr_nrdconta  IN tbtarif_pacote_trans_pend.nrdconta%TYPE    --> Numero da Conta
																					,pr_cdpacote  IN tbtarif_pacote_trans_pend.cdpacote%TYPE    --> Cód. pacote de tarifas
																					,pr_dtvigenc  IN tbtarif_pacote_trans_pend.dtinicio_vigencia%TYPE--> Data de inicio de vigencia
																					,pr_dtdiadbt  IN tbtarif_pacote_trans_pend.nrdiadebito%TYPE     --> Dia débito
																					,pr_vlpacote  IN tbtarif_pacote_trans_pend.vlpacote%TYPE
																					,pr_idastcjt  IN crapass.idastcjt%TYPE                      --> Indicador de Assinatura Conjunta
																					,pr_cdcritic OUT crapcri.cdcritic%TYPE                      --> Codigo de Critica
																					,pr_dscritic OUT crapcri.dscritic%TYPE) IS                  --> Descricao de Critica
  
    -- Variáveis
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_exec_saida EXCEPTION;
    vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas
  BEGIN
    
    INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nmdatela => pr_nmdatela
                                       ,pr_idorigem => pr_idorigem
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrcpfope => pr_nrcpfope
                                       ,pr_nrcpfrep => pr_nrcpfrep
                                       ,pr_cdcoptfn => pr_cdcoptfn
                                       ,pr_cdagetfn => pr_cdagetfn
                                       ,pr_nrterfin => pr_nrterfin
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdtiptra => 10
                                       ,pr_idastcjt => pr_idastcjt
                                       ,pr_tab_crapavt => vr_tab_crapavt
                                       ,pr_cdtranpe => vr_cdtranpe
                                       ,pr_dscritic => vr_dscritic);
                                         
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exec_saida;
    END IF;

    BEGIN
      INSERT INTO
        tbtarif_pacote_trans_pend(cdtransacao_pendente
                          			 ,cdcooper
				                         ,nrdconta
																 ,cdpacote
																 ,nrdiadebito
																 ,dtinicio_vigencia,
																  vlpacote)
        VALUES(vr_cdtranpe
							,pr_cdcooper
							,pr_nrdconta
							,pr_cdpacote
							,pr_dtdiadbt
							,pr_dtvigenc
							,pr_vlpacote);
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao incluir registro tbtarif_pacote_trans_pend. Erro: ' || SQLERRM;
    END;
   
    pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                            ,pr_nrdcaixa => pr_nrdcaixa
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_idorigem => pr_idorigem
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrcpfrep => pr_nrcpfrep
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdtiptra => 10
                            ,pr_tab_crapavt => vr_tab_crapavt
                            ,pr_cdtranpe => vr_cdtranpe
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
       RAISE vr_exec_saida;
    END IF;

    COMMIT;
		
  EXCEPTION
    WHEN vr_exec_saida THEN
      pr_cdcritic := vr_cdcritic;
      
      IF vr_cdcritic <> 0 THEN
         pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE	
         pr_dscritic := vr_dscritic;
      END IF;
        
      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral na procedure pc_cria_trans_pend_pacote_tar. Erro: '|| SQLERRM; 
      ROLLBACK; 		
	END pc_cria_trans_pend_pacote_tar;

  --> Rotina responsavel por controlar criação do registro de transação de operador juridico(craptoj)
  PROCEDURE pc_cria_transacao_operador(pr_cdagenci   IN crapage.cdagenci%TYPE                        --> Codigo do PA
                                      ,pr_nrdcaixa   IN craplot.nrdcaixa%TYPE                        --> Numero do Caixa
                                      ,pr_cdoperad   IN crapope.cdoperad%TYPE                        --> Codigo do Operados
                                      ,pr_nmdatela   IN craptel.nmdatela%TYPE                        --> Nome da Tela
                                      ,pr_idorigem   IN INTEGER                                      --> Origem da solicitacao
                                      ,pr_idseqttl   IN crapttl.idseqttl%TYPE                        --> Sequencial de Titular               
                                      ,pr_cdcooper   IN crapcop.cdcooper%TYPE                        --> Codigo da cooperativa
                                      ,pr_nrdconta   IN crapass.nrdconta%TYPE                        --> Numero da conta    
                                      ,pr_nrcpfope   IN crapopi.nrcpfope%TYPE                        --> Numero do cpf do operador juridico
                                      ,pr_nrcpfrep   IN tbgen_trans_pend.nrcpf_representante%TYPE    --> Numero do cpf do representante legal
                                      ,pr_cdcoptfn   IN tbgen_trans_pend.cdcoptfn%TYPE               --> Cooperativa do Terminal
                                      ,pr_cdagetfn   IN tbgen_trans_pend.cdagetfn%TYPE               --> Agencia do Terminal
                                      ,pr_nrterfin   IN tbgen_trans_pend.nrterfin%TYPE               --> Numero do Terminal Financeiro
                                      ,pr_dtmvtolt   IN DATE                                         --> Data do movimento     
                                      ,pr_cdtiptra   IN INTEGER                                      --> Codigo do tipo de transação    
                                      ,pr_idastcjt   IN crapass.idastcjt%TYPE                        --> Indicador de Assinatura Conjunta
                                      ,pr_tab_crapavt OUT CADA0001.typ_tab_crapavt_58 
                                      ,pr_cdtranpe  OUT tbfolha_trans_pend.cdtransacao_pendente%TYPE --> Codigo tipo da transacao
                                      ,pr_dscritic  OUT VARCHAR2) IS                                 --> Descrição da crítica       

    /* .............................................................................

     Programa: pc_cria_transacao_operador (Antiga: b1wgen0016.cria_transacao_operador)
     Sistema : Rotinas acessadas pelas telas de cadastros Web
     Sigla   : CADA
     Autor   : Odirlei Busana - AMcom
     Data    : Maio/2015.                  Ultima atualizacao: 03/12/2015

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina responsavel por controlar criação do registro de transação de operador juridico(craptoj)
     Observacao: -----

     Alteracoes: 07/05/2015 - Conversão Progress -> Oracle (Odirlei-AMcom)
        
                 05/08/2015 - Adição do parametro pr_idtitdda (Douglas - Chamado 291387)

                 03/12/2015 - Alteração para o projeto de Ass. Conjunta  (Jean Michel).
     
    ..............................................................................*/ 
    ----------------> CURSORES <-----------------
       
    -- Buscar nome da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
   
    ----------------> VARIAVEIS <-----------------
    vr_exc_saida EXCEPTION;
    vr_idsituac  INTEGER;  
    vr_ind       INTEGER;
    vr_contaresp INTEGER := 0;
    vr_cdcritic crapcri.cdcritic%TYPE; -- Codigo de erro
    vr_dscritic crapcri.dscritic%TYPE; -- Retorno de Erro
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; --Tabela Avalistas
    vr_tab_bens CADA0001.typ_tab_bens;          --Tabela bens
    vr_tab_erro gene0001.typ_tab_erro;          --Tabela Erro
   
  BEGIN
      
    --Dados da Cooperativa
    OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
    
    --Se nao encontrou 
    IF cr_crapcop%NOTFOUND THEN 
       --Fechar Cursor
       CLOSE cr_crapcop;   
       
       vr_cdcritic:= 0;
       vr_dscritic:= 'Cooperativa nao encontrada.';
       --Levantar Excecao
       RAISE vr_exc_saida;
    END IF;
    
    --Fechar Cursor
    CLOSE cr_crapcop;   
          
    CADA0001.pc_busca_dados_58(pr_cdcooper => pr_cdcooper
                              ,pr_cdagenci => pr_cdagenci
                              ,pr_nrdcaixa => pr_nrdcaixa
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_idorigem => pr_idorigem
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_idseqttl => 0
                              ,pr_flgerlog => FALSE
                              ,pr_cddopcao => 'C'
                              ,pr_nrdctato => 0
                              ,pr_nrcpfcto => 0
                              ,pr_nrdrowid => NULL
                              ,pr_tab_crapavt => vr_tab_crapavt
                              ,pr_tab_bens => vr_tab_bens
                              ,pr_tab_erro => vr_tab_erro
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR 
       vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Verifica se existem representantes legais para conta
    IF vr_tab_crapavt.COUNT() <= 0 THEN
      vr_dscritic := 'Nao existem responsaveis legais para a conta informada.';
      RAISE vr_exc_saida;
    END IF; 

    -- Inicializa variavel
    vr_contaresp := 0;

    IF vr_tab_crapavt.COUNT() > 0 THEN
      -- Leitura de registros de avalistas, representantes e procuradores
      FOR i IN vr_tab_crapavt.FIRST..vr_tab_crapavt.LAST LOOP
        -- Verifica se ha representante legal
        IF vr_tab_crapavt(i).idrspleg = 1 THEN
          vr_contaresp := vr_contaresp + 1;
        END IF;
      END LOOP;
    END IF;
    IF vr_contaresp = 0 THEN
      vr_dscritic := 'Conta exige cadastramento de responsavel legal.';
      RAISE vr_exc_saida;
    END IF;

    vr_ind := vr_tab_crapavt.FIRST;
    WHILE vr_ind IS NOT NULL LOOP
      -- Operação realizada por responsável da assinatura conjunta
      IF pr_nrcpfrep = vr_tab_crapavt(vr_ind).nrcpfcgc AND
         vr_tab_crapavt(vr_ind).idrspleg = 1 THEN
        vr_idsituac := 5; -- Parcialmente Aprovada
        EXIT;
      ELSE -- Operação realizada por operador 
        vr_idsituac := 1; -- Pendente
      END IF;
      vr_ind := vr_tab_crapavt.NEXT(vr_ind);
    END LOOP;

    BEGIN
      INSERT INTO tbgen_trans_pend(
         cdcooper              
        ,nrdconta              
        ,nrcpf_operador        
        ,nrcpf_representante   
        ,dtmvtolt              
        ,dtregistro_transacao  
        ,hrregistro_transacao  
        ,idorigem_transacao    
        ,tptransacao           
        ,idassinatura_conjunta 
        ,idsituacao_transacao  
        ,cdcoptfn              
        ,cdagetfn              
        ,nrterfin)
      VALUES(
         pr_cdcooper          
        ,pr_nrdconta
        ,pr_nrcpfope
        ,pr_nrcpfrep
        ,pr_dtmvtolt
        ,TRUNC(SYSDATE)
        ,GENE0002.fn_busca_time
        ,pr_idorigem
        ,pr_cdtiptra
        ,NVL(pr_idastcjt,0)
        ,vr_idsituac
        ,pr_cdcoptfn
        ,pr_cdagetfn
        ,pr_nrterfin)RETURNING cdtransacao_pendente INTO pr_cdtranpe;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir registro TBGEN_TRANS_PEND. Erro: ' || SQLERRM;
        RAISE vr_exc_saida;
    END;

    pr_tab_crapavt := vr_tab_crapavt;
          
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF vr_cdcritic <> 0 THEN
         pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE	
         pr_dscritic := vr_dscritic;
      END IF;
        
      ROLLBACK;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro no procedimento INET0002.pc_cria_transacao_operador: ' || SQLERRM;      
  END pc_cria_transacao_operador;
  
  
  PROCEDURE pc_horario_trans_pend( pr_cdcooper  IN crapsnh.cdcooper%TYPE
                                  ,pr_cdagenci  IN crapass.cdagenci%TYPE
                                  ,pr_cdoperad  IN crapope.cdoperad%TYPE
                                  ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE
                                  ,pr_nmdatela  IN craptel.nmdatela%TYPE
                                  ,pr_idorigem  IN INTEGER
                                  ,pr_tab_limite_pend OUT INET0002.typ_tab_limite_pend --Tabelas de retorno de horarios limite transacoes pendente
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                  ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_horario_trans_pend
  --  Sistema  : Procedimentos para obter horario limite de aprovacao das transacoes pendentes
  --  Sigla    : CRED
  --  Autor    : Jorge Hamaguchi
  --  Data     : Dezembro/2015.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para obter horario limite de aprovacao de transacao pendente
  --             1 - Transferencia
  --             2 - Pagamento
  --             3 - Cobranca
  --             4 - TED
  --             5 - Intercooperativa
  --             6 - VR Boleto
  --             7 - Credito Pre-Aprovado
  --             8 - Aplicacao
  --            11 - Debito Auto Facil
  --            12 - Folha Pagamento (Agenda)
  --            13 - Folha Pagamento (Portabilidade)              
  --            14 - Folha Pagamento (Solicitacao Estouro Conta)
  --            15 - Pagamento de tributos federais DARF/DAS
  -- Alteração : 
  --
  ---------------------------------------------------------------------------------------------------------------

    --Variaveis Locais
    vr_hrlimini INTEGER; --horario inicio
    vr_hrlimfim INTEGER; --horario fim
    vr_hrlimage VARCHAR2(5); --horario folha agendamento
    vr_hrlimptb VARCHAR2(5); --horario folha portabilidade
    vr_hrlimsol VARCHAR2(5); --horario folha solicitacao Estouro
    vr_index_limite INTEGER;
    vr_index_limite_pend INTEGER;
    vr_dstextab craptab.dstextab%TYPE;
    --Tabela de memória de limites de horario
    vr_tab_limite INET0001.typ_tab_limite;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
  BEGIN
      --Inicializar retorno erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    --Limpar tabela de memória
    vr_tab_limite.DELETE;
    pr_tab_limite_pend.DELETE;

    --Buscar Horario Operacao
    INET0001.pc_horario_operacao (pr_cdcooper => pr_cdcooper  --Código Cooperativa
                                 ,pr_cdagenci => pr_cdagenci  --Agencia do Associado
                                 ,pr_tpoperac => 0            --Tipo de Operacao (0=todos)
                                 ,pr_inpessoa => 2            --Tipo de Pessoa
                                 ,pr_tab_limite => vr_tab_limite --Tabelas de retorno de horarios limite
                                 ,pr_cdcritic => vr_cdcritic    --Código do erro
                                 ,pr_dscritic => vr_dscritic);  --Descricao do erro
    --Se ocorreu erro
    IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      --levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    --Se encontrou limites
    vr_index_limite:= vr_tab_limite.FIRST;
    WHILE vr_index_limite IS NOT NULL LOOP
      --Criar registro para tabela limite horarios transacoes pendentes
      vr_index_limite_pend:= vr_tab_limite(vr_index_limite).idtpdpag;
      IF vr_index_limite_pend = 6 THEN --se for Limite de VRBoleto, entao tipodtra = 2 (pagamento)
        pr_tab_limite_pend(vr_index_limite_pend).tipodtra:= 2; 
      ELSIF vr_index_limite_pend = 11 THEN --se for Limite de Debito Automatico, entao tipodtra = 8
        pr_tab_limite_pend(vr_index_limite_pend).tipodtra:= 8;
      ELSIF vr_index_limite_pend = 10 THEN --se for DARF/DAS, entao tipodtra = 8
        pr_tab_limite_pend(vr_index_limite_pend).tipodtra:= 11;
      ELSE
        pr_tab_limite_pend(vr_index_limite_pend).tipodtra:= vr_index_limite;          
      END IF;

      pr_tab_limite_pend(vr_index_limite_pend).hrinipag:= vr_tab_limite(vr_index_limite).hrinipag;
      pr_tab_limite_pend(vr_index_limite_pend).hrfimpag:= vr_tab_limite(vr_index_limite).hrfimpag;
      --Encontrar proximo registro
      vr_index_limite:= vr_tab_limite.NEXT(vr_index_limite);
    END LOOP;

    --Selecionar Horarios Limites Credito Pre-Aprovado
    vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'GENERI'
                                            ,pr_cdempres => 0
                                            ,pr_cdacesso => 'HRCTRPREAPROV'
                                            ,pr_tpregist => pr_cdagenci);
    --Se nao encontrou
    IF TRIM(vr_dstextab) IS NULL THEN 
      vr_cdcritic:= 0;
      vr_dscritic := 'Tabela (HRCTRPREAPROV) nao cadastrada.';
      --levantar Excecao
      RAISE vr_exc_erro;
    ELSE    
      --Criar registro para tabela limite horarios
      vr_index_limite_pend:= 7; --Credito Pre-Aprovado
      pr_tab_limite_pend(vr_index_limite_pend).tipodtra:= 6; --Tipo de transacao  
      pr_tab_limite_pend(vr_index_limite_pend).hrinipag:= GENE0002.fn_converte_time_data(gene0002.fn_busca_entrada(1,vr_dstextab,' '));
      pr_tab_limite_pend(vr_index_limite_pend).hrfimpag:= GENE0002.fn_converte_time_data(gene0002.fn_busca_entrada(2,vr_dstextab,' '));
    END IF;
      
    --Selecionar Horarios Limites Aplicacao 
    APLI0002.pc_horario_limite( pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_cdoperad => pr_cdoperad
                               ,pr_nmdatela => pr_nmdatela
                               ,pr_idorigem => pr_idorigem               
                               ,pr_tpvalida => 0 -- Não Valida horario
                               ,pr_hrlimini => vr_hrlimini
                               ,pr_hrlimfim => vr_hrlimfim
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
    -- Se ocorreu erro
    IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
      --levantar Excecao
      RAISE vr_exc_erro;
    ELSE                 
      --Criar registro para tabela limite horarios
      vr_index_limite_pend:= 8; --Aplicacao
      pr_tab_limite_pend(vr_index_limite_pend).tipodtra:= 7; --Tipo de transacao
      pr_tab_limite_pend(vr_index_limite_pend).hrinipag:= GENE0002.fn_converte_time_data(vr_hrlimini);
      pr_tab_limite_pend(vr_index_limite_pend).hrfimpag:= GENE0002.fn_converte_time_data(vr_hrlimfim);
    END IF;
      
    --Selecionar Horarios Limites Folha de Pagamento 
    FOLH0002.pc_hrlimite(  pr_cdcooper => pr_cdcooper --> Codigo da Cooperativa
                          ,pr_hrlimage => vr_hrlimage --> Horario limite agenda
                          ,pr_hrlimptb => vr_hrlimptb --> Horario limite portabilidade
                          ,pr_hrlimsol => vr_hrlimsol --> Horario limite solicitacao Estouro conta
                          ,pr_cdcritic => vr_cdcritic --> Codigo da critica
                          ,pr_dscritic => vr_dscritic); --> Descricao da critica 
    -- Se ocorreu erro
    IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
      --levantar Excecao
      RAISE vr_exc_erro;
    ELSE
      --Criar registro para tabela limite horarios
      vr_index_limite_pend:= 12; --Folha Pagamento Agenda
      pr_tab_limite_pend(vr_index_limite_pend).tipodtra:= 9; --Tipo de transacao
      pr_tab_limite_pend(vr_index_limite_pend).hrinipag:= '0';
      pr_tab_limite_pend(vr_index_limite_pend).hrfimpag:= vr_hrlimage;
        
      --Criar registro para tabela limite horarios
      vr_index_limite_pend:= 13; --Folha Pagamento Portabilidade
      pr_tab_limite_pend(vr_index_limite_pend).tipodtra:= 9; --Tipo de transacao
      pr_tab_limite_pend(vr_index_limite_pend).hrinipag:= '0';
      pr_tab_limite_pend(vr_index_limite_pend).hrfimpag:= vr_hrlimptb;

      --Criar registro para tabela limite horarios
      vr_index_limite_pend:= 14; --Folha Pagamento Solicitacao Estouro de conta
      pr_tab_limite_pend(vr_index_limite_pend).tipodtra:= 9; --Tipo de transacao
      pr_tab_limite_pend(vr_index_limite_pend).hrinipag:= '0';
      pr_tab_limite_pend(vr_index_limite_pend).hrfimpag:= vr_hrlimsol;

    END IF;
  EXCEPTION
      WHEN vr_exc_erro THEN
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
    WHEN OTHERS THEN
      -- Erro
      pr_dscritic:= 'Erro na rotina INET002.pc_horario_trans_pend. '||sqlerrm; 
  END pc_horario_trans_pend;                                

  --> Rotina responsavel pela consulta de ROWID 
  PROCEDURE pc_obtem_rowid_folha(pr_cdcooper  IN crappfp.cdcooper%TYPE     --> Codigo da cooperativa
                                ,pr_cdempres  IN crappfp.cdempres%TYPE     --> Codigo da empresa
                                ,pr_nrseqpag  IN crappfp.nrseqpag%TYPE     --> Sequencia de folha de pagamento
                                ,pr_rowidpag OUT VARCHAR2                  --> ROWID da folha de pagamento
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo de Critica
                                ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao de Critica

     /* .............................................................................

      Programa: pc_obtem_rowid_folha
      Sistema : Rotinas acessadas pelas telas de cadastros Web
      Sigla   : INET
      Autor   : Jean Michel
      Data    : Dezembro/2015.                  Ultima atualizacao: 17/12/2015

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina responsavel pela consulta de ROWID de folhas de pagamento.
      Observacao: -----

      Alteracoes:      
     ..............................................................................*/ 
     ----------------> CURSORES <-----------------
    
     -- Buscar nome da cooperativa
     CURSOR cr_crappfp IS
       SELECT crappfp.rowid
         FROM crappfp 
        WHERE crappfp.cdcooper = pr_cdcooper
          AND crappfp.cdempres = pr_cdempres
          AND crappfp.nrseqpag = pr_nrseqpag;

     rw_crappfp cr_crappfp%ROWTYPE;
    
     ----------------> VARIAVEIS <-----------------
     vr_exc_saida EXCEPTION;
     vr_cdcritic crapcri.cdcritic%TYPE; -- Codigo de erro
     vr_dscritic crapcri.dscritic%TYPE; -- Retorno de Erro
    
   BEGIN
       
     OPEN cr_crappfp;

     FETCH cr_crappfp INTO rw_crappfp;

     IF cr_crappfp%NOTFOUND THEN
       CLOSE cr_crappfp;
       vr_dscritic := 'Registro de folha de pagamento inexistente.';
       RAISE vr_exc_saida;
     ELSE
       CLOSE cr_crappfp;
       pr_rowidpag := TO_CHAR(rw_crappfp.rowid);
     END IF;   
     
   EXCEPTION
     WHEN vr_exc_saida THEN
       IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       ELSE      
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
       END IF;
         
       ROLLBACK;
     WHEN OTHERS THEN
       pr_dscritic := 'Erro no procedimento INET0002.pc_obtem_rowid_folha: ' || SQLERRM;      
   END pc_obtem_rowid_folha; 
         
   PROCEDURE pc_busca_trans_pend(pr_cdcooper IN  crapcop.cdcooper%TYPE --> Código da Cooperativa
                                ,pr_nrdconta IN  crapass.nrdconta%TYPE --> Numero conta
                                ,pr_idseqttl IN  crapsnh.idseqttl%TYPE --> Sequencia de Titularidade
                                ,pr_nrcpfope IN  crapsnh.nrcpfcgc%TYPE --> CPF operador
                                ,pr_cdagenci IN  crapage.cdagenci%TYPE --> Numero PA
                                ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE --> Data Movimentacao
                                ,pr_cdorigem IN  INTEGER               --> Id de origem
                                ,pr_insittra IN  INTEGER               --> Id de situacao da transacao
                                ,pr_dtiniper IN  DATE                  --> Data Inicio
                                ,pr_dtfimper IN  DATE                  --> Data final
                                ,pr_nrregist IN  INTEGER               --> Numero da qtd de registros da pagina
                                ,pr_nriniseq IN  INTEGER               --> Numero do registro inicial
                                ,pr_clobxmlc OUT CLOB                  --> XML com informações
                                ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica

  BEGIN

    /* .............................................................................

     Programa: pc_busca_trans_pend
     Sistema : Transacoes Pendentes
     Sigla   : INET
     Autor   : Jorge Hamaguchi
     Data    : Dezembro/2015.                  Ultima atualizacao: 02/09/2016

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina para buscar Transacoes pendentes.

     Observacao: -----

     Alteração : 25/02/2016 - Remover obrigatoriedade de crapcti nas TEDs (Marcos-Supero)
     
				         21/06/2016 - Ajuste para incluir alterações perdidas na realização de merge entre versões
							               (Adriano).
                             
                 29/06/2016 - Utilizar rotina generico para busca registro na craptab
                              (Adriano).             

                 19/07/2016 - Ajustes para o Prj. 338 - Pagamento de DARF/DAS (Jean Michel).             

	             04/08/2016 - Ajustes realizado na tela conforme solicitado no chamado
                              442860 (Kelvin).

                 02/09/2016 - Ajustada para retornar os aprovadores da transação que
                              está sendo consultada., SD 514239 (Jean Michel).                          
    ..............................................................................*/
    DECLARE
     
      -- Buscar nome da cooperativa
      CURSOR cr_crapcop(pr_cdagectl IN crapcop.cdagectl%TYPE) IS
      SELECT cop.cdcooper,
             cop.nmrescop
      FROM   crapcop cop
      WHERE  cop.cdagectl = pr_cdagectl;
    
      rw_crapcop cr_crapcop%ROWTYPE;

      /* Busca dos dados do associado */
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapass.idastcjt,
             crapass.nmprimtl
      FROM   crapass
      WHERE  crapass.cdcooper = pr_cdcooper
      AND    crapass.nrdconta = pr_nrdconta;
      rw_crapass  cr_crapass%ROWTYPE;
      rw_crapass2 cr_crapass%ROWTYPE;
      
      --Selecionar informacoes de senhas
      CURSOR cr_crapsnh (pr_cdcooper IN crapsnh.cdcooper%TYPE
                        ,pr_nrdconta IN crapsnh.nrdconta%TYPE
                        ,pr_idseqttl IN crapsnh.idseqttl%TYPE) IS
      SELECT crapsnh.nrcpfcgc
      FROM   crapsnh
      WHERE  crapsnh.cdcooper = pr_cdcooper
      AND    crapsnh.nrdconta = pr_nrdconta
      AND    crapsnh.idseqttl = pr_idseqttl
      AND    crapsnh.tpdsenha = 1; --Internet
      
      --Selecionar primeira senha tiva
      CURSOR cr_crapsnh_seq (pr_cdcooper IN crapsnh.cdcooper%TYPE
                            ,pr_nrdconta IN crapsnh.nrdconta%TYPE) IS
      SELECT crapsnh.idseqttl
      FROM   crapsnh
      WHERE  crapsnh.cdcooper = pr_cdcooper
      AND    crapsnh.nrdconta = pr_nrdconta
      AND    crapsnh.cdsitsnh = 1
      AND    crapsnh.tpdsenha = 1; --Internet
              
      /* Busca do nome do representante/procurador */
      CURSOR cr_crapavt(pr_cdcooper IN crapavt.cdcooper%TYPE
                       ,pr_nrdconta IN crapavt.nrdconta%TYPE
                       ,pr_nrcpfcgc IN crapavt.nrcpfcgc%TYPE) IS
      SELECT crapavt.nrdctato,
             crapavt.nmdavali
      FROM   crapavt
      WHERE  crapavt.cdcooper = pr_cdcooper
      AND    crapavt.nrdconta = pr_nrdconta
      AND    crapavt.nrcpfcgc = pr_nrcpfcgc
      AND    crapavt.tpctrato = 6; -- Juridico
        
      CURSOR cr_tbgen_trans_pend (pr_cdcooper IN tbgen_trans_pend.cdcooper%TYPE
                                 ,pr_nrdconta IN tbgen_trans_pend.nrdconta%TYPE
                                 ,pr_dtiniper IN tbgen_trans_pend.dtregistro_transacao%TYPE
                                 ,pr_dtfimper IN tbgen_trans_pend.dtregistro_transacao%TYPE
                                 ,pr_insittra IN tbgen_trans_pend.idsituacao_transacao%TYPE) IS
        SELECT dados.nrdconta nrdconta
              ,dados.tptransacao tptransacao
              ,dados.cdtransacao_pendente cdtransacao_pendente
              ,dados.dtregistro_transacao dtregistro_transacao
              ,dados.hrregistro_transacao hrregistro_transacao
              ,dados.idorigem_transacao idorigem_transacao
              ,dados.dtmvtolt dtmvtolt
              ,dados.idsituacao_transacao idsituacao_transacao
              ,dados.dtalteracao_situacao dtalteracao_situacao
              ,dados.dscritica dscritica
              ,dados.dtcritica dtcritica
              ,dados.nrcpf_representante nrcpf_representante
              ,dados.nrcpf_operador nrcpf_operador
              ,nvl(dados.ord1,0) + nvl(dados.ord2,0) + nvl(dados.ord3,0) + nvl(dados.ord4,0) + 
               nvl(dados.ord5,0) + nvl(dados.ord6,0) + nvl(dados.ord7,0) + nvl(dados.ord8,0) orderby
          FROM (SELECT gtp.nrdconta nrdconta
                      ,gtp.tptransacao tptransacao
                      ,gtp.cdtransacao_pendente cdtransacao_pendente
                      ,gtp.dtregistro_transacao dtregistro_transacao
                      ,gtp.hrregistro_transacao hrregistro_transacao
                      ,gtp.idorigem_transacao idorigem_transacao
                      ,gtp.dtmvtolt dtmvtolt
                      ,gtp.idsituacao_transacao idsituacao_transacao
                      ,gtp.dtalteracao_situacao dtalteracao_situacao
                      ,gtp.dscritica dscritica
                      ,gtp.dtcritica dtcritica
                      ,gtp.nrcpf_representante nrcpf_representante
                      ,gtp.nrcpf_operador nrcpf_operador
                      ,(SELECT DECODE(ttp.idagendamento,1,1,0)
                          FROM tbtransf_trans_pend ttp
                         WHERE ttp.cdtransacao_pendente = gtp.cdtransacao_pendente) ord1
                      ,(SELECT DECODE(ptp.idagendamento,1,1,0)
                          FROM tbpagto_trans_pend ptp
                         WHERE ptp.cdtransacao_pendente = gtp.cdtransacao_pendente) ord2    
                      ,(SELECT DECODE(stp.idagendamento,1,1,0)
                          FROM tbspb_trans_pend stp
                         WHERE stp.cdtransacao_pendente = gtp.cdtransacao_pendente) ord3   
                      ,(SELECT 1
                          FROM tbepr_trans_pend etp
                         WHERE etp.cdtransacao_pendente = gtp.cdtransacao_pendente) ord4    
                      ,(SELECT DECODE(ctp.tpoperacao,1,1,0)
                          FROM tbcapt_trans_pend ctp
                         WHERE ctp.cdtransacao_pendente = gtp.cdtransacao_pendente) ord5    
                      ,(SELECT DECODE(ctp.tpoperacao,2,1,0)
                          FROM tbcapt_trans_pend ctp
                         WHERE ctp.cdtransacao_pendente = gtp.cdtransacao_pendente) ord6      
                      ,(SELECT 1
                          FROM tbconv_trans_pend vtp
                         WHERE vtp.cdtransacao_pendente = gtp.cdtransacao_pendente) ord7 
                      ,(SELECT 1
                          FROM tbtarif_pacote_trans_pend tptp
                         WHERE tptp.cdtransacao_pendente = gtp.cdtransacao_pendente) ord8  
                  FROM tbgen_trans_pend gtp
                 WHERE gtp.cdcooper = pr_cdcooper
                   AND gtp.nrdconta = pr_nrdconta
                   AND gtp.idsituacao_transacao <> 2
                   AND ((pr_insittra = 15 AND (gtp.idsituacao_transacao = 1 OR /*Pendente*/ gtp.idsituacao_transacao = 5))
                                OR (gtp.idsituacao_transacao = DECODE(pr_insittra,0,gtp.idsituacao_transacao,pr_insittra)))
                 ORDER BY ord1) dados
                ORDER BY orderby DESC
                        ,dados.tptransacao;                                 
      rw_tbgen_trans_pend cr_tbgen_trans_pend%ROWTYPE;  
        
      --Tipo Transacao 1,3,5 (Transferencia)
      CURSOR cr_tbtransf_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbtransf_trans_pend.cdagencia_coop_destino 
            ,tbtransf_trans_pend.nrconta_destino
            ,tbtransf_trans_pend.idagendamento
            ,tbtransf_trans_pend.vltransferencia
            ,tbtransf_trans_pend.dtdebito
      FROM   tbtransf_trans_pend 
      WHERE  tbtransf_trans_pend.cdtransacao_pendente = pr_cddoitem
        AND  tbtransf_trans_pend.dtdebito BETWEEN pr_dtiniper AND pr_dtfimper;
      rw_tbtransf_trans_pend cr_tbtransf_trans_pend%ROWTYPE;
  	  
      --Tipo Transacao 2 (Pagamento)
      CURSOR cr_tbpagto_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbpagto_trans_pend.tppagamento
            ,tbpagto_trans_pend.dscedente
            ,tbpagto_trans_pend.idagendamento
            ,tbpagto_trans_pend.vlpagamento
            ,tbpagto_trans_pend.dtdebito
            ,tbpagto_trans_pend.dscodigo_barras
            ,tbpagto_trans_pend.dslinha_digitavel
            ,tbpagto_trans_pend.dtvencimento
            ,tbpagto_trans_pend.vldocumento
            ,tbpagto_trans_pend.idtitulo_dda
      FROM   tbpagto_trans_pend 
      WHERE  tbpagto_trans_pend.cdtransacao_pendente = pr_cddoitem
        AND  tbpagto_trans_pend.dtdebito BETWEEN pr_dtiniper AND pr_dtfimper;
      rw_tbpagto_trans_pend cr_tbpagto_trans_pend%ROWTYPE;
  	  
      --Tipo Transacao 4 (TED)
      CURSOR cr_tbspb_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbspb_trans_pend.cdcooper 
            ,tbspb_trans_pend.nrdconta
            ,tbspb_trans_pend.cdbanco_favorecido
            ,tbspb_trans_pend.cdagencia_favorecido
            ,tbspb_trans_pend.nrconta_favorecido
            ,tbspb_trans_pend.dtdebito
            ,tbspb_trans_pend.vlted
            ,tbspb_trans_pend.idagendamento
            ,tbspb_trans_pend.nrispb_banco_favorecido
            ,tbspb_trans_pend.dshistorico
            ,tbspb_trans_pend.dscodigo_identificador
            ,tbspb_trans_pend.cdfinalidade
            ,tbspb_trans_pend.nrcpfcnpj_favorecido
            ,tbspb_trans_pend.nmtitula_favorecido
      FROM   tbspb_trans_pend 
      WHERE  tbspb_trans_pend.cdtransacao_pendente = pr_cddoitem
        AND  tbspb_trans_pend.dtdebito BETWEEN pr_dtiniper AND pr_dtfimper;
      rw_tbspb_trans_pend cr_tbspb_trans_pend%ROWTYPE;
  	  
      --Tipo Transacao 6 (Credito Pre-Aprovado)
      CURSOR cr_tbepr_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbepr_trans_pend.cdcooper
            ,tbepr_trans_pend.vlemprestimo
            ,tbepr_trans_pend.dtprimeiro_vencto
            ,tbepr_trans_pend.nrparcelas
            ,tbepr_trans_pend.vlparcela
            ,tbepr_trans_pend.vlpercentual_cet
            ,tbepr_trans_pend.vltarifa
            ,tbepr_trans_pend.vltaxa_mensal
            ,tbepr_trans_pend.vliof
            ,tbepr_trans_pend.vlpercentual_iof
      FROM   tbepr_trans_pend 
      WHERE  tbepr_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbepr_trans_pend cr_tbepr_trans_pend%ROWTYPE;
  	  
      --Tipo Transacao 7 (Aplicacao)
      CURSOR cr_tbcapt_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbcapt_trans_pend.tpoperacao
            ,tbcapt_trans_pend.tpaplicacao
            ,tbcapt_trans_pend.nraplicacao
            ,tbcapt_trans_pend.vlresgate
            ,tbcapt_trans_pend.dtinicio_agendamento
            ,tbcapt_trans_pend.nrdia_agendamento
            ,tbcapt_trans_pend.qtmeses_agendamento
            ,tbcapt_trans_pend.nrdocto_agendamento
            ,tbcapt_trans_pend.tpagendamento
            ,tbcapt_trans_pend.tpresgate
            ,tbcapt_trans_pend.idperiodo_agendamento
      FROM   tbcapt_trans_pend 
      WHERE  tbcapt_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbcapt_trans_pend cr_tbcapt_trans_pend%ROWTYPE;
  	
      --Tipo Transacao 8 (Debito Automatico)
      CURSOR cr_tbconv_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbconv_trans_pend.cdcooper
            ,tbconv_trans_pend.tpoperacao
            ,tbconv_trans_pend.cdsegmento_conven
            ,tbconv_trans_pend.cdconven
            ,tbconv_trans_pend.cdhist_convenio
            ,tbconv_trans_pend.nrdocumento_fatura
            ,tbconv_trans_pend.dtdebito_fatura
            ,tbconv_trans_pend.iddebito_automatico
            ,tbconv_trans_pend.dshist_debito
            ,tbconv_trans_pend.vlmaximo_debito
      FROM   tbconv_trans_pend 
      WHERE  tbconv_trans_pend.cdtransacao_pendente = pr_cddoitem
        AND  tbconv_trans_pend.dtdebito_fatura BETWEEN pr_dtiniper AND pr_dtfimper;
      rw_tbconv_trans_pend cr_tbconv_trans_pend%ROWTYPE;
      	  
      --Tipo Transacao 9 (Folha de Pagamento)
      CURSOR cr_tbfolha_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbfolha_trans_pend.vlfolha
            ,tbfolha_trans_pend.dtdebito
            ,tbfolha_trans_pend.nrlanctos
            ,tbfolha_trans_pend.idestouro
            ,tbfolha_trans_pend.vltarifa
      FROM   tbfolha_trans_pend 
      WHERE  tbfolha_trans_pend.cdtransacao_pendente = pr_cddoitem
        AND  tbfolha_trans_pend.dtdebito BETWEEN pr_dtiniper AND pr_dtfimper;
      rw_tbfolha_trans_pend cr_tbfolha_trans_pend%ROWTYPE;

      --Tipo Transacao 10 - Cursor para buscar a transação de adesão de pacote de tarifa pendente
			CURSOR cr_pactar (pr_cdtranpe IN tbtarif_pacote_trans_pend.cdtransacao_pendente%TYPE)IS
			  SELECT tpend.vlpacote
				      ,tpend.dtinicio_vigencia dtinivig
				      ,(tpac.cdpacote || ' - ' || tpac.dspacote) dspacote
							,tpend.nrdiadebito dtdiadeb
				  FROM tbtarif_pacote_trans_pend tpend
					    ,tbtarif_pacotes tpac
				 WHERE tpend.cdtransacao_pendente = pr_cdtranpe			
				   AND tpac.cdpacote = tpend.cdpacote;
			rw_pactar cr_pactar%ROWTYPE;

      --Tipo Transacao 11 (DARF/DAS)
      CURSOR cr_tbpagto_darf_das_trans_pend( pr_cddoitem IN tbgen_trans_pend.cdtransacao_pendente%TYPE) IS  
      SELECT tbpagto_darf_das_trans_pend.*
      FROM   tbpagto_darf_das_trans_pend
      WHERE  tbpagto_darf_das_trans_pend.cdtransacao_pendente = pr_cddoitem;
      rw_tbpagto_darf_das_trans_pend cr_tbpagto_darf_das_trans_pend%ROWTYPE;
           
      --Cadastro de Transferencias pela Internet.
      CURSOR cr_crapcti( pr_cdcooper IN crapcti.cdcooper%TYPE,
                         pr_nrdconta IN crapcti.nrdconta%TYPE,
                         pr_cddbanco IN crapcti.cddbanco%TYPE,
                         pr_cdageban IN crapcti.cdageban%TYPE,
                         pr_nrctatrf IN crapcti.nrctatrf%TYPE) IS  
      SELECT crapcti.nmtitula, crapcti.nrcpfcgc 
      FROM   crapcti
      WHERE  crapcti.cdcooper = pr_cdcooper
      AND    crapcti.nrdconta = pr_nrdconta
      AND	   crapcti.cddbanco = pr_cddbanco
      AND	   crapcti.cdageban = pr_cdageban 
      AND	   crapcti.nrctatrf = pr_nrctatrf;
      rw_crapcti cr_crapcti%ROWTYPE;
      
      CURSOR cr_craprda (pr_cdcooper IN craprda.cdcooper%TYPE
                        ,pr_nrdconta IN craprda.nrdconta%TYPE
                        ,pr_nraplica IN craprda.nraplica%TYPE) IS
      SELECT craprda.vlaplica 
      FROM   craprda 
      WHERE  craprda.cdcooper = pr_cdcooper 
      AND    craprda.nrdconta = pr_nrdconta 
      AND    craprda.nraplica = pr_nraplica;
      
      CURSOR cr_crapopi (pr_cdcooper IN crapopi.cdcooper%TYPE
                        ,pr_nrdconta IN crapopi.nrdconta%TYPE
                        ,pr_nrcpfope IN crapopi.nrcpfope%TYPE) IS
      SELECT crapopi.nmoperad 
      FROM   crapopi
      WHERE  crapopi.cdcooper = pr_cdcooper 
      AND    crapopi.nrdconta = pr_nrdconta 
      AND    crapopi.nrcpfope = pr_nrcpfope;
      
      --Cadastro de convenios.
      CURSOR cr_crapcon( pr_cdcooper IN crapcon.cdcooper%TYPE,
                         pr_cdsegmto IN crapcon.cdsegmto%TYPE,
                         pr_cdempcon IN crapcon.cdempcon%TYPE) IS
      SELECT crapcon.nmrescon 
      FROM   crapcon
      WHERE  crapcon.cdcooper = pr_cdcooper 
      AND    crapcon.cdsegmto = pr_cdsegmto 
      AND    crapcon.cdempcon = pr_cdempcon;
      
      -- Consulta autorizacao de debitos
      CURSOR cr_autodeb(pr_cdcooper IN crapatr.cdcooper%TYPE,
                       pr_nrdconta IN crapatr.nrdconta%TYPE,
                       pr_cdhistor IN crapatr.cdhistor%TYPE,
                       pr_cdrefere IN crapatr.cdrefere%TYPE,
                       pr_dtmvtopg IN craplau.dtmvtopg%TYPE) IS
      SELECT crapcon.nmrescon, craplau.vllanaut 
      FROM   crapatr, crapcon, craplau
      WHERE  crapatr.cdcooper = pr_cdcooper 
      AND    crapatr.nrdconta = pr_nrdconta 
      AND    crapatr.cdhistor = pr_cdhistor 
      AND    crapatr.cdrefere = pr_cdrefere
      AND    crapatr.tpautori <> 0 
      AND    crapcon.cdcooper = crapatr.cdcooper 
      AND    crapcon.cdsegmto = crapatr.cdsegmto 
      AND    crapcon.cdempcon = crapatr.cdempcon 
      AND    craplau.cdcooper = crapatr.cdcooper 
      AND    craplau.nrdconta = crapatr.nrdconta 
      AND    craplau.cdhistor = crapatr.cdhistor 
      AND    craplau.nrdocmto = crapatr.cdrefere 
      AND    craplau.dtmvtopg = pr_dtmvtopg
      AND    craplau.insitlau = 1;
      
      CURSOR cr_crapban1 (pr_cdbccxlt IN crapban.cdbccxlt%TYPE) IS
      SELECT crapban.cdbccxlt,
             crapban.nmextbcc
      FROM   crapban
      WHERE  crapban.cdbccxlt = pr_cdbccxlt;
      
      CURSOR cr_crapban2 (pr_nrispbif IN crapban.cdbccxlt%TYPE) IS
      SELECT crapban.cdbccxlt,
             crapban.nmextbcc
      FROM   crapban
      WHERE  crapban.nrispbif = pr_nrispbif;
      
      CURSOR cr_crapagb (pr_cddbanco IN crapagb.cddbanco%TYPE 
                        ,pr_cdageban IN crapagb.cdageban%TYPE) IS
      SELECT gene0007.fn_caract_acento(crapagb.nmageban,1) nmageban 
      FROM   crapagb
      WHERE  crapagb.cddbanco = pr_cddbanco 
      AND    crapagb.cdageban = pr_cdageban;
      
      CURSOR cr_tbaprova(pr_cdtransa IN tbgen_aprova_trans_pend.cdtransacao_pendente%TYPE
                        ,pr_nrcpfope IN tbgen_aprova_trans_pend.nrcpf_responsavel_aprov%TYPE) IS
        SELECT cdtransacao_pendente
          FROM tbgen_aprova_trans_pend
         WHERE cdtransacao_pendente = pr_cdtransa
           AND nrcpf_responsavel_aprov = pr_nrcpfope;

      rw_tbaprova cr_tbaprova%ROWTYPE;     

      CURSOR cr_tbaprova_rep(pr_cdtransa IN tbgen_aprova_trans_pend.cdtransacao_pendente%TYPE) IS
        SELECT apr.cdtransacao_pendente
              ,apr.nrcpf_responsavel_aprov AS cpf_responsavel
              ,DECODE(apr.idsituacao_aprov,1,'Pendente',2,'Aprovada',3,'Reprovada',4,'Expirada','Sem Situacao') AS situacao
          FROM tbgen_aprova_trans_pend apr
         WHERE cdtransacao_pendente = pr_cdtransa;

      rw_tbaprova_rep cr_tbaprova_rep%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      --Variáveis locais
      vr_idastcjt NUMBER := 0;
      vr_nrcpfcgc NUMBER(14) := 0;
      vr_nrdctato crapavt.nrdctato%TYPE;
      vr_nmprimtl crapass.nmprimtl%TYPE;
      vr_dstransa VARCHAR2(500);
      vr_indiacao NUMBER := 0;
      vr_tptranpe NUMBER := 0;
      vr_cdtranpe NUMBER := 0;
      vr_dsvltran VARCHAR2(20);
      vr_dsdtefet VARCHAR2(20);
      vr_dsdescri VARCHAR2(100);
      vr_dstptran VARCHAR2(100);
      vr_dsagenda VARCHAR2(10);
      vr_nrindice NUMBER := 0;
      vr_nmagenda VARCHAR2(100);
      vr_dttranpe VARCHAR2(10);
      vr_hrtranpe VARCHAR2(8);
      vr_dsoritra VARCHAR2(50);
      vr_dtmvttra VARCHAR2(10);
      vr_dssittra VARCHAR2(50);
      vr_dtreptra VARCHAR2(10);
      vr_dtexctra VARCHAR2(10);
      vr_dtexptra VARCHAR2(10);
      vr_dscritra VARCHAR2(500);
      vr_dtvalida VARCHAR2(10);
      vr_vlaplica NUMBER(10,2) := 0;
      vr_nrdolote NUMBER := 0;
      vr_cdhistor NUMBER := 0;
      vr_nmrescon VARCHAR2(500);
      vr_vllanaut NUMBER(10,2) := 0;
      vr_nmextbcc crapban.nmextbcc%TYPE;
      vr_cddbanco NUMBER := 0;
      vr_nrdocmto VARCHAR2(100);
      vr_qttotpen NUMBER := 0;
      vr_vlasomar NUMBER(10,2) := 0;
      vr_vltotpen NUMBER(10,2) := 0;
      vr_dtaltera VARCHAR2(10);
      vr_idseqttl crapsnh.idseqttl%TYPE; 
      vr_labnmage VARCHAR2(100);
      
      --Pagamento
      vr_cdcopdes VARCHAR2(100);
      vr_nrcondes VARCHAR2(100);
      vr_dtdebito VARCHAR2(100);
      vr_nmcednte VARCHAR2(100);
      vr_nrcodbar VARCHAR2(100);
      vr_dslindig VARCHAR2(100);
      vr_dtvencto VARCHAR2(100);
      vr_vldocmto varCHAR2(100);
      vr_identdda varCHAR2(100);
      
      --TED
      vr_nmbanfav VARCHAR2(100);
      vr_nmdoispb VARCHAR2(100);
      vr_nmagenci VARCHAR2(100);
      vr_nrctafav VARCHAR2(100);
      vr_nomdofav VARCHAR2(100);
      vr_cpfcgcfv VARCHAR2(100);
      vr_dsfindad VARCHAR2(100);
      vr_dshistco VARCHAR2(100);
      vr_cdidenti VARCHAR2(100);
      vr_dtdodebi VARCHAR2(100);
      vr_dsagenci VARCHAR2(100);
      
      --Credito Pre-Aprovado
      vr_qtdparce VARCHAR2(100);
      vr_vldparce VARCHAR2(100);
      vr_dtpriven VARCHAR2(100);
      vr_vlpercet VARCHAR2(100);
      vr_vltarifa VARCHAR2(100);
      vr_vltaxmen VARCHAR2(100);
      vr_vlrdoiof VARCHAR2(100);
      vr_vlperiof VARCHAR2(100);
      
      --Aplicacao
      vr_tpopeapl VARCHAR2(100);
      vr_nraplica VARCHAR2(100);
      vl_dtaplica VARCHAR2(100);
      vr_nmdprodu VARCHAR2(100);
      vr_carencia VARCHAR2(100);
      vr_dtcarenc VARCHAR2(100);
      vr_dtrdavct VARCHAR2(100);
      
      --Aplicacao (tipo 2 - resgate)
      vr_sldresga VARCHAR2(100);
      vr_dtresgat VARCHAR2(100);
      vr_vlresgat VARCHAR2(100);
      vr_tpresgat VARCHAR2(100);
      
      --Aplicacao (tipo 3 - Agenda resgate)
      vr_flageuni VARCHAR2(100);
      vr_nrdiacre VARCHAR2(100);
      vr_qtdmeses VARCHAR2(100);
      
      --Aplicacao (tipo 4 - Cancelamento Total)
      vr_tpagenda VARCHAR2(100);
      vr_docagend VARCHAR2(100);
      vr_dtdiacre VARCHAR2(100);
      vr_qtdiacar VARCHAR2(100);
      vr_dtacrenc VARCHAR2(100);
      vr_dtagevct VARCHAR2(100);
      vr_dtdiaaar VARCHAR2(100);
      vr_qtmesaar VARCHAR2(100);
       
      --Debito Automatico       
      vr_tpopconv NUMBER := 0;
      vr_iddebaut VARCHAR2(100);
      vr_dshistor VARCHAR2(100);
      vr_vlmaxdeb VARCHAR2(100);
      vr_dtdebfat VARCHAR2(100);
      vr_nrdocfat VARCHAR2(100);
      
      --Folha de Pagamento
      vr_nrqtlnac VARCHAR2(100);
      vr_solestou VARCHAR2(100);

      -- Pacote de tarifas
			vr_dspacote VARCHAR2(100);
			vr_vlpacote VARCHAR2(100);
			vr_dtdiadeb VARCHAR2(100);
			vr_dtinivig VARCHAR2(100);

      --DARF/DAS
      vr_tpcaptura INTEGER := 0;
      vr_dstipcapt VARCHAR2(50);
      vr_dsnomfone VARCHAR2(50);
      vr_dscod_barras tbpagto_darf_das_trans_pend.dscod_barras%TYPE;
      vr_dslinha_digitavel tbpagto_darf_das_trans_pend.dslinha_digitavel%TYPE;
      vr_dtapuracao tbpagto_darf_das_trans_pend.dtapuracao%TYPE;           -- Período de Apuração
      vr_cdtributo tbpagto_darf_das_trans_pend.cdtributo%TYPE;             -- Código da Receita
      vr_nrrefere tbpagto_darf_das_trans_pend.nrrefere%TYPE;               -- Número de Referência (retornar se estiver preenchido)
      vr_vlprincipal tbpagto_darf_das_trans_pend.vlprincipal%TYPE;         -- Valor do Principal
      vr_vlmulta tbpagto_darf_das_trans_pend.vlmulta%TYPE;                 -- Valor da Multa
      vr_vljuros tbpagto_darf_das_trans_pend.vljuros%TYPE;                 -- Valor dos Juros
      vr_vlrtotal tbpagto_darf_das_trans_pend.vlmulta%TYPE;                -- Valor Total
      vr_vlreceita_bruta tbpagto_darf_das_trans_pend.vlreceita_bruta%TYPE; -- Receita Bruta Acumulada  (retornar se estiver preenchido)
      vr_vlpercentual tbpagto_darf_das_trans_pend.vlpercentual%TYPE;       -- Percentual (retornar se estiver preenchido)
      vr_idagendamento tbpagto_darf_das_trans_pend.idagendamento%TYPE;     -- Indicador de Agendamento     

      --Variavel de indice
      vr_ind NUMBER := 0;
      
      vr_tab_limite_pend INET0002.typ_tab_limite_pend;
      vr_tab_internet    INET0001.typ_tab_internet;
      vr_tab_agen        APLI0002.typ_tab_agen; 
      vr_tab_agen_det    APLI0002.typ_tab_agen_det;
      vr_tab_crapavt     CADA0001.typ_tab_crapavt_58; --Tabela Avalistas
      vr_tab_bens        CADA0001.typ_tab_bens;       --Tabela bens
      vr_tab_erro        GENE0001.typ_tab_erro;       --Tabela Erro
      vr_saldo_rdca      APLI0001.typ_tab_saldo_rdca; --Tabela para o saldo da aplicação
      vr_tab_convenios   PAGA0002.typ_tab_convenios;  --Tabela Convenios aceitos
      
      -- Variaveis de XML 
      vr_xml_auxi VARCHAR2(32767);
      vr_xml_temp VARCHAR2(32767);
      
    ----------------------------------------------------------------  
    ---------------------- INICIO DO PROGRAMA ----------------------  
    ----------------------------------------------------------------
    
    BEGIN

      -- Dados da conta
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      --Se nao encontrou 
      IF cr_crapass%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapass;
          vr_cdcritic:= 0;
          vr_dscritic:= 'Registro do cooperado nao encontrado.';
          --Levantar Excecao
          RAISE vr_exc_erro;
      ELSE
          --Fechar Cursor
          CLOSE cr_crapass;  
      END IF;
      
      vr_idastcjt := rw_crapass.idastcjt;
      vr_nmprimtl := rw_crapass.nmprimtl;
      vr_idseqttl := pr_idseqttl;
      
      --Se conta nao exige assinatura multipla, verificar preposto
      IF vr_idastcjt = 0 THEN
        --Consulta do cpf do representante na crapsnh
        OPEN cr_crapsnh(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_idseqttl => 1);
        FETCH cr_crapsnh INTO vr_nrcpfcgc;
        --Se nao encontrou 
        IF cr_crapsnh%NOTFOUND THEN
            --Fechar Cursor
            CLOSE cr_crapsnh;
            vr_cdcritic:= 0;
            vr_dscritic:= 'Registro de senha nao encontrado.';
            --Levantar Excecao
            RAISE vr_exc_erro;
        ELSE
            --Fechar Cursor
            CLOSE cr_crapsnh;
        END IF;
        
        --Consulta do nome do Preposto
        OPEN cr_crapavt(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrcpfcgc => vr_nrcpfcgc);
        FETCH cr_crapavt INTO vr_nrdctato
                             ,vr_nmprimtl;
        --Se nao encontrou 
        IF cr_crapavt%NOTFOUND THEN
            --Fechar Cursor
            CLOSE cr_crapavt;
            vr_cdcritic:= 0;
            vr_dscritic:= 'Necessario habilitar um preposto.';
            --Levantar Excecao
            RAISE vr_exc_erro;
        ELSE                             
            --Fechar Cursor
            CLOSE cr_crapavt;      
        END IF;
      ELSE --Se conta exige assinatura multipla
        IF pr_nrcpfope = 0 THEN
          --Consulta do cpf do representante na crapsnh
          OPEN cr_crapsnh(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_idseqttl => pr_idseqttl);
          FETCH cr_crapsnh INTO vr_nrcpfcgc;
          --Se nao encontrou 
          IF cr_crapsnh%NOTFOUND THEN
              --Fechar Cursor
              CLOSE cr_crapsnh;
              vr_cdcritic:= 0;
              vr_dscritic:= 'Registro de senha nao encontrado.';
              --Levantar Excecao
              RAISE vr_exc_erro;
          ELSE
              --Fechar Cursor
              CLOSE cr_crapsnh;
          END IF;
        ELSE
           --Consulta primeiro registro de senha ativo
          OPEN cr_crapsnh_seq(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta);
          FETCH cr_crapsnh_seq INTO vr_idseqttl;
          CLOSE cr_crapsnh_seq;
        END IF;
        
      END IF;
      
      PAGA0001.pc_atualiza_trans_nao_efetiv(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_cdagenci => pr_cdagenci
                                           ,pr_dtmvtolt => pr_dtmvtolt
                                           ,pr_dstransa => vr_dstransa
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
                                           
                                           
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;                                        
      
      -------------------------------------------------------------------------------
      ------------------------------  Criacao do XML --------------------------------
      -------------------------------------------------------------------------------
      
      -- Criar documento XML
      dbms_lob.createtemporary(pr_clobxmlc, TRUE); 
      dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);       

      -- Insere o cabeçalho do XML 
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '<raiz>'); 
      
      --Montar Tag Xml de Informativo
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '<dstransa>'||vr_dstransa||'</dstransa>');
      
      --Limpar Tabela Memoria de Horarios
      vr_tab_limite_pend.DELETE;
      
      --Buscar Horario Operacao
      INET0002.pc_horario_trans_pend (pr_cdcooper => pr_cdcooper  --Código Cooperativa
                                     ,pr_cdagenci => pr_cdagenci  --Agencia do Associado
                                     ,pr_cdoperad => '996'        --Operador
                                     ,pr_nrdcaixa => 900          --Nr do caixa
                                     ,pr_nmdatela => 'INTERNETBANK' --Nome da tela
                                     ,pr_idorigem => 3            --Id de Origem
                                     ,pr_tab_limite_pend => vr_tab_limite_pend --Tabelas de retorno de horarios limite
                                     ,pr_cdcritic => vr_cdcritic    --Código do erro
                                     ,pr_dscritic => vr_dscritic);  --Descricao do erro
                                   
      --Se ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      
      --Montar Tag Xml de Horarios
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '<horarios>'); 
      
      vr_ind := vr_tab_limite_pend.FIRST;
      WHILE vr_ind IS NOT NULL LOOP
         
         gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                                ,pr_texto_completo => vr_xml_temp 
                                ,pr_texto_novo     => '<horario>'
                                                   ||   '<idtiphor>'||vr_ind||'</idtiphor>'
                                                   ||   '<idtiptra>'||nvl(vr_tab_limite_pend(vr_ind).tipodtra,0)||'</idtiptra>'
                                                   ||   '<hrinipag>'||nvl(vr_tab_limite_pend(vr_ind).hrinipag,' ')||'</hrinipag>'
                                                   ||   '<hrfimpag>'||nvl(vr_tab_limite_pend(vr_ind).hrfimpag,' ')||'</hrfimpag>'
                                                   || '</horario>'); 
         vr_ind := vr_tab_limite_pend.NEXT(vr_ind);
      END LOOP;
      
      --Fecha Tag de Horarios
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '</horarios>'); 
      
      --Limpar Tabela Memoria de Limites
      vr_tab_internet.DELETE;
 
      --Buscar Limites  
      INET0001.pc_busca_limites(pr_cdcooper     => pr_cdcooper   --Codigo Cooperativa
                               ,pr_nrdconta     => pr_nrdconta   --Numero da conta
                               ,pr_idseqttl     => vr_idseqttl   --Seq de Titularidade
                               ,pr_flglimdp     => FALSE         --Indicador limite deposito
                               ,pr_dtmvtopg     => pr_dtmvtolt   --Data do proximo pagamento
                               ,pr_flgctrag     => FALSE         --Indicador validacoes
                               ,pr_dsorigem     => gene0001.vr_vet_des_origens(pr_cdorigem)
                               ,pr_tab_internet => vr_tab_internet --Tabelas de retorno de limites
                               ,pr_cdcritic     => vr_cdcritic   --Codigo do erro
                               ,pr_dscritic     => vr_dscritic); --Descricao do erro 
                                     
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
         --Levantar Excecao
         RAISE vr_exc_erro;
      END IF;                                                                   
      
            --Montar Tag Xml de Limites
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '<limites>'); 
      
      vr_ind := vr_tab_internet.FIRST;
      WHILE vr_ind IS NOT NULL LOOP
         
         gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                                ,pr_texto_completo => vr_xml_temp 
                                ,pr_texto_novo     => '<limite>' 
                                                   ||   '<idseqttl>'||nvl(vr_tab_internet(vr_ind).idseqttl,0)||'</idseqttl>'
                                                   ||   '<vllimweb>'||TO_CHAR(nvl(vr_tab_internet(vr_ind).vllimweb,0),'fm999g999g990d00')||'</vllimweb>'
                                                   ||   '<vllimpgo>'||TO_CHAR(nvl(vr_tab_internet(vr_ind).vllimpgo,0),'fm999g999g990d00')||'</vllimpgo>'
                                                   ||   '<vllimtrf>'||TO_CHAR(nvl(vr_tab_internet(vr_ind).vllimtrf,0),'fm999g999g990d00')||'</vllimtrf>'
                                                   ||   '<vllimted>'||TO_CHAR(nvl(vr_tab_internet(vr_ind).vllimted,0),'fm999g999g990d00')||'</vllimted>'
                                                   ||   '<vllimvrb>'||TO_CHAR(nvl(vr_tab_internet(vr_ind).vllimvrb,0),'fm999g999g990d00')||'</vllimvrb>'
                                                   ||   '<vlutlweb>'||TO_CHAR(nvl(vr_tab_internet(vr_ind).vlutlweb,0),'fm999g999g990d00')||'</vlutlweb>'
                                                   ||   '<vlutlpgo>'||TO_CHAR(nvl(vr_tab_internet(vr_ind).vlutlpgo,0),'fm999g999g990d00')||'</vlutlpgo>'
                                                   ||   '<vlutltrf>'||TO_CHAR(nvl(vr_tab_internet(vr_ind).vlutltrf,0),'fm999g999g990d00')||'</vlutltrf>'
                                                   ||   '<vlutlted>'||TO_CHAR(nvl(vr_tab_internet(vr_ind).vlutlted,0),'fm999g999g990d00')||'</vlutlted>'
                                                   ||   '<vldspweb>'||TO_CHAR(nvl(vr_tab_internet(vr_ind).vldspweb,0),'fm999g999g990d00')||'</vldspweb>'
                                                   ||   '<vldsppgo>'||TO_CHAR(nvl(vr_tab_internet(vr_ind).vldsppgo,0),'fm999g999g990d00')||'</vldsppgo>'
                                                   ||   '<vldsptrf>'||TO_CHAR(nvl(vr_tab_internet(vr_ind).vldsptrf,0),'fm999g999g990d00')||'</vldsptrf>'
                                                   ||   '<vldspted>'||TO_CHAR(nvl(vr_tab_internet(vr_ind).vldspted,0),'fm999g999g990d00')||'</vldspted>'
                                                   ||   '<vlwebcop>'||TO_CHAR(nvl(vr_tab_internet(vr_ind).vlwebcop,0),'fm999g999g990d00')||'</vlwebcop>'
                                                   ||   '<vlpgocop>'||TO_CHAR(nvl(vr_tab_internet(vr_ind).vlpgocop,0),'fm999g999g990d00')||'</vlpgocop>'
                                                   ||   '<vltrfcop>'||TO_CHAR(nvl(vr_tab_internet(vr_ind).vltrfcop,0),'fm999g999g990d00')||'</vltrfcop>'
                                                   ||   '<vltedcop>'||TO_CHAR(nvl(vr_tab_internet(vr_ind).vltedcop,0),'fm999g999g990d00')||'</vltedcop>'
                                                   ||   '<vlvrbcop>'||TO_CHAR(nvl(vr_tab_internet(vr_ind).vlvrbcop,0),'fm999g999g990d00')||'</vlvrbcop>'
                                                   || '</limite>'); 
         vr_ind := vr_tab_internet.NEXT(vr_ind);
      END LOOP;
      
      --Fecha Tag de Horarios
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '</limites>'); 
                             
      --Limpar Tabela Memoria de Convenios
      vr_tab_convenios.DELETE;
      
      --Buscar Horario Operacao
      PAGA0002.pc_convenios_aceitos  (pr_cdcooper => pr_cdcooper  --Código Cooperativa
                                     ,pr_tab_convenios => vr_tab_convenios --Tabelas de retorno de horarios limite
                                     ,pr_cdcritic => vr_cdcritic    --Código do erro
                                     ,pr_dscritic => vr_dscritic);  --Descricao do erro
                                   
      --Se ocorreu erro
      IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        --levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      
      --Montar Tag Xml de Horarios
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '<convenios>'); 
      
      vr_ind := vr_tab_convenios.FIRST;
      WHILE vr_ind IS NOT NULL LOOP
         
         gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                                ,pr_texto_completo => vr_xml_temp 
                                ,pr_texto_novo     => '<convenio>'
                                                   ||   '<nmextcon>'||nvl(vr_tab_convenios(vr_ind).nmextcon,' ')||'</nmextcon>'
                                                   ||   '<nmrescon>'||nvl(vr_tab_convenios(vr_ind).nmrescon,' ')||'</nmrescon>'
                                                   ||   '<cdempcon>'||nvl(vr_tab_convenios(vr_ind).cdempcon,0)||'</cdempcon>'
                                                   ||   '<cdsegmto>'||nvl(vr_tab_convenios(vr_ind).cdsegmto,0)||'</cdsegmto>'
                                                   ||   '<hhoraini>'||nvl(vr_tab_convenios(vr_ind).hhoraini,' ')||'</hhoraini>'
                                                   ||   '<hhorafim>'||nvl(vr_tab_convenios(vr_ind).hhorafim,' ')||'</hhorafim>'
                                                   ||   '<hhoracan>'||nvl(vr_tab_convenios(vr_ind).hhoracan,' ')||'</hhoracan>'
                                                   || '</convenio>'); 
         vr_ind := vr_tab_convenios.NEXT(vr_ind);
      END LOOP;
      
      --Fecha Tag de Horarios
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '</convenios>');                       
      
      --Montar Tag Xml das transacoes pendentes
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '<transacoes>');
      
      --------------------------------------------------------------------------------------
      --Buscar transacoes pendentes (pai)
      --------------------------------------------------------------------------------------
      --Limpar Tabela Memoria
      vr_tab_crapavt.DELETE;
            
      CADA0001.pc_busca_dados_58(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_nrdcaixa => 900
                                ,pr_cdoperad => '996'
                                ,pr_nmdatela => 'INTERNETBANK'
                                ,pr_idorigem => 3
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_idseqttl => 0
                                ,pr_flgerlog => FALSE
                                ,pr_cddopcao => 'C'
                                ,pr_nrdctato => 0
                                ,pr_nrcpfcto => 0
                                ,pr_nrdrowid => NULL
                                ,pr_tab_crapavt => vr_tab_crapavt
                                ,pr_tab_bens => vr_tab_bens
                                ,pr_tab_erro => vr_tab_erro
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);

      IF NVL(vr_cdcritic,0) > 0 OR 
         vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Verifica se existem representantes legais para conta
      IF vr_tab_crapavt.COUNT() <= 0 THEN
        vr_dscritic := 'Nao existem responsaveis legais para a conta informada.';
        RAISE vr_exc_erro;
      END IF; 

      FOR rw_tbgen_trans_pend IN cr_tbgen_trans_pend (pr_cdcooper => pr_cdcooper
                                                     ,pr_nrdconta => pr_nrdconta
                                                     ,pr_dtiniper => pr_dtiniper
                                                     ,pr_dtfimper => pr_dtfimper
                                                     ,pr_insittra => pr_insittra) LOOP
         
         --Controle de paginacao
         vr_qttotpen := vr_qttotpen + 1;
         IF ((vr_qttotpen <= pr_nriniseq) OR
             (vr_qttotpen > (pr_nriniseq + pr_nrregist))) THEN
            CONTINUE;
         END IF;
         
         --Zerando Variaveis
         vr_indiacao := 0;   vr_cddbanco := 0;   vr_vlasomar := 0;   vr_vlaplica := 0;   vr_vllanaut := 0;
         vr_cdcopdes := ' '; vr_nrcondes := ' '; vr_dtdebito := ' '; vr_nmcednte := ' '; vr_nrcodbar := ' ';
         vr_dslindig := ' '; vr_dtvencto := ' '; vr_vldocmto := ' '; vr_identdda := ' '; vr_labnmage := ' '; 
         vr_nmextbcc := ' '; vr_dsfindad := ' '; vr_nmbanfav := ' '; vr_nmdoispb := ' '; vr_nmagenci := ' '; 
         vr_nrctafav := ' '; vr_nomdofav := ' '; vr_cpfcgcfv := ' '; vr_dshistco := ' '; vr_cdidenti := ' '; 
         vr_dtdodebi := ' '; vr_qtdparce := ' '; vr_vldparce := ' '; vr_dtpriven := ' '; vr_vlpercet := ' '; 
         vr_vltarifa := ' '; vr_vltaxmen := ' '; vr_vlrdoiof := ' '; vr_vlperiof := ' '; vr_tpopeapl := ' '; 
         vr_nraplica := ' '; vr_tpagenda := ' '; vr_docagend := ' '; vr_flageuni := ' '; vr_nrdiacre := ' '; 
         vr_qtdmeses := ' '; vl_dtaplica := ' '; vr_nmdprodu := ' '; vr_carencia := ' '; 
         vr_dtcarenc := ' '; vr_dtrdavct := ' '; vr_sldresga := ' '; vr_dtresgat := ' '; vr_vlresgat := ' '; 
         vr_tpresgat := ' '; vr_dtdiacre := ' '; vr_qtdiacar := ' '; vr_dtacrenc := ' '; vr_dtdiaaar := ' ';
         vr_qtmesaar := ' '; vr_dtagevct := ' '; vr_nmrescon := ' '; vr_iddebaut := ' '; vr_dshistor := ' '; 
         vr_vlmaxdeb := ' '; vr_dtdebfat := ' '; vr_nrdocfat := ' '; vr_nrqtlnac := ' '; 
         vr_solestou := ' '; vr_xml_auxi := ' '; vr_dtmvttra := ' '; vr_nmagenda := ' ';
         vr_tpcaptura := 0; vr_dstipcapt := ''; vr_dsnomfone := ''; vr_dscod_barras := ''; vr_dslinha_digitavel := '';
         vr_dtapuracao := null; vr_cdtributo := 0; vr_nrrefere := 0; vr_vlprincipal := 0; vr_vlmulta := 0; vr_vljuros := 0;
         vr_vlrtotal := 0; vr_vlreceita_bruta := 0; vr_vlpercentual := 0; vr_idagendamento := 0; 

         --Atribuicao de variaveis genericas
         vr_tptranpe := rw_tbgen_trans_pend.tptransacao;
         vr_cdtranpe := rw_tbgen_trans_pend.cdtransacao_pendente;
         vr_dttranpe := TO_CHAR(rw_tbgen_trans_pend.dtregistro_transacao,'DD/MM/RRRR');
         vr_hrtranpe := TO_CHAR(to_date(rw_tbgen_trans_pend.hrregistro_transacao,'sssss'),'hh24:mi:ss');
         vr_dsoritra := gene0001.vr_vet_des_origens(rw_tbgen_trans_pend.idorigem_transacao);
         vr_dtmvttra := TO_CHAR(rw_tbgen_trans_pend.dtmvtolt,'DD/MM/RRRR');
         vr_dssittra := CASE WHEN rw_tbgen_trans_pend.idsituacao_transacao = 1 THEN 'Pendente'
                             WHEN rw_tbgen_trans_pend.idsituacao_transacao = 2 THEN 'Aprovada'
                             WHEN rw_tbgen_trans_pend.idsituacao_transacao = 3 THEN 'Excluida'
                             WHEN rw_tbgen_trans_pend.idsituacao_transacao = 4 THEN 'Expirada'
                             WHEN rw_tbgen_trans_pend.idsituacao_transacao = 5 THEN 'Parcialmente Aprovada'
                             WHEN rw_tbgen_trans_pend.idsituacao_transacao = 6 THEN 'Reprovada'
                        END;
         vr_dtaltera := TO_CHAR(rw_tbgen_trans_pend.dtalteracao_situacao,'DD/MM/RRRR');
         vr_dtreptra := CASE WHEN rw_tbgen_trans_pend.idsituacao_transacao = 6 THEN rw_tbgen_trans_pend.dtalteracao_situacao END;
         vr_dtexctra := CASE WHEN rw_tbgen_trans_pend.idsituacao_transacao = 3 THEN rw_tbgen_trans_pend.dtalteracao_situacao END;
         vr_dtexptra := CASE WHEN rw_tbgen_trans_pend.idsituacao_transacao = 4 THEN rw_tbgen_trans_pend.dtalteracao_situacao END;
         vr_dscritra := rw_tbgen_trans_pend.dscritica;
         vr_dtvalida := TO_CHAR(rw_tbgen_trans_pend.dtcritica,'DD/MM/RRRR');
         vr_labnmage := CASE WHEN rw_tbgen_trans_pend.nrcpf_operador > 0 THEN 'Operador' ELSE 'Representante' END;
         
         IF rw_tbgen_trans_pend.nrcpf_operador > 0 THEN
            OPEN cr_crapopi (pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrcpfope => rw_tbgen_trans_pend.nrcpf_operador);
            FETCH cr_crapopi INTO vr_nmagenda;
            --Se nao encontrou 
            IF cr_crapopi%NOTFOUND THEN
                --Fechar Cursor
                CLOSE cr_crapopi;
                vr_nmagenda := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_tbgen_trans_pend.nrcpf_operador
                                                        ,pr_inpessoa => 1);
            ELSE                             
                --Fechar Cursor
                CLOSE cr_crapopi;
                vr_nmagenda := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_tbgen_trans_pend.nrcpf_operador
                                                        ,pr_inpessoa => 1) || ' - ' || vr_nmagenda;                
            END IF;
         ELSE -- Consultar Representante
            
            --Limpar Tabela Memoria
            vr_tab_crapavt.DELETE;
            
            CADA0001.pc_busca_dados_58(pr_cdcooper => pr_cdcooper
                                      ,pr_cdagenci => pr_cdagenci
                                      ,pr_nrdcaixa => 900
                                      ,pr_cdoperad => '996'
                                      ,pr_nmdatela => 'INTERNETBANK'
                                      ,pr_idorigem => 3
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_idseqttl => 0
                                      ,pr_flgerlog => FALSE
                                      ,pr_cddopcao => 'C'
                                      ,pr_nrdctato => 0
                                      ,pr_nrcpfcto => 0
                                      ,pr_nrdrowid => NULL
                                      ,pr_tab_crapavt => vr_tab_crapavt
                                      ,pr_tab_bens => vr_tab_bens
                                      ,pr_tab_erro => vr_tab_erro
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);

            IF NVL(vr_cdcritic,0) > 0 OR 
               vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;

            -- Verifica se existem representantes legais para conta
            IF vr_tab_crapavt.COUNT() <= 0 THEN
              vr_dscritic := 'Nao existem responsaveis legais para a conta informada.';
              RAISE vr_exc_erro;
            END IF; 

            vr_ind := vr_tab_crapavt.FIRST;
            WHILE vr_ind IS NOT NULL LOOP
              -- Operação realizada por responsável da assinatura conjunta
              IF vr_tab_crapavt(vr_ind).nrcpfcgc = rw_tbgen_trans_pend.nrcpf_representante THEN
                vr_nmagenda := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_crapavt(vr_ind).nrcpfcgc
                                                        ,pr_inpessoa => 1) 
                               || ' - ' || vr_tab_crapavt(vr_ind).nmdavali;
                EXIT;
              END IF;
              vr_ind := vr_tab_crapavt.NEXT(vr_ind);
            END LOOP;
         END IF; 
         
         IF vr_nmagenda IS NULL THEN
            vr_nmagenda := CASE WHEN rw_tbgen_trans_pend.nrcpf_operador > 0 THEN 
                                gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_tbgen_trans_pend.nrcpf_operador
                                                         ,pr_inpessoa => 1)
                           ELSE gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_tbgen_trans_pend.nrcpf_representante
                                                         ,pr_inpessoa => 1)
                           END;
         END IF;
         
         --Controle de operacao (indica 1 que pode alterar)
         IF rw_tbgen_trans_pend.idsituacao_transacao = 1 OR   --Pendente
            rw_tbgen_trans_pend.idsituacao_transacao = 5 THEN --Parcialmente Aprovada
           IF pr_nrcpfope > 0 THEN --Consulta efetuada por operador PJ
             IF rw_tbgen_trans_pend.idsituacao_transacao = 1     AND
                rw_tbgen_trans_pend.nrcpf_operador = pr_nrcpfope THEN
                vr_indiacao := 1;
             END IF;
           ELSE
               OPEN cr_tbaprova(pr_cdtransa => vr_cdtranpe
                               ,pr_nrcpfope => vr_nrcpfcgc);

               FETCH cr_tbaprova INTO rw_tbaprova;                                    

               IF cr_tbaprova%FOUND THEN
                  vr_indiacao := 1;
               END IF;

               CLOSE cr_tbaprova;
           END IF; 
         END IF;         
         
         --Case para cada tipo de transacao (filhos)                                           
         CASE 
            WHEN vr_tptranpe = 1 OR --Transferencias
                 vr_tptranpe = 3 OR
                 vr_tptranpe = 5 THEN
                 
                 OPEN cr_tbtransf_trans_pend(pr_cddoitem => vr_cdtranpe);
                 FETCH cr_tbtransf_trans_pend INTO rw_tbtransf_trans_pend;
                 IF cr_tbtransf_trans_pend%NOTFOUND THEN
                    --Fechar Cursor
                    CLOSE cr_tbtransf_trans_pend;
                    CONTINUE;
                 ELSE
                    --Fechar Cursor
                    CLOSE cr_tbtransf_trans_pend;
                    
                    --Controle de paginacao
                    vr_qttotpen := vr_qttotpen + 1;
                    IF ((vr_qttotpen <= pr_nriniseq) OR
                       (vr_qttotpen > (pr_nriniseq + pr_nrregist))) THEN
                       CONTINUE;
                    END IF;

                 END IF;
                 
                 OPEN cr_crapcop (pr_cdagectl => rw_tbtransf_trans_pend.cdagencia_coop_destino);
                 FETCH cr_crapcop INTO rw_crapcop;

                 IF cr_crapcop %NOTFOUND THEN
                    --Fechar Cursor
                    CLOSE cr_crapcop;
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Cooperativa destino nao encontrada.';
                    --Levantar Excecao
                    RAISE vr_exc_erro;
                 ELSE
                    --Fechar Cursor
                    CLOSE cr_crapcop;
                 END IF;

                 OPEN cr_crapass (pr_cdcooper => rw_crapcop.cdcooper
                                 ,pr_nrdconta => rw_tbtransf_trans_pend.nrconta_destino);
                 FETCH cr_crapass INTO rw_crapass2;
                 IF cr_crapass %NOTFOUND THEN
                    --Fechar Cursor
                    CLOSE cr_crapass;
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Conta destino nao encontrado.';
                    --Levantar Excecao
                    RAISE vr_exc_erro;
                 ELSE
                    --Fechar Cursor
                    CLOSE cr_crapass;
                 END IF;
                                  
                 --Valor a somar
                 vr_vlasomar := rw_tbtransf_trans_pend.vltransferencia;
                 
                 --Variaveis do resumo
                 vr_dsvltran := TO_CHAR(rw_tbtransf_trans_pend.vltransferencia,'fm999g999g990d00'); -- Valor
                 vr_dsdtefet := CASE WHEN rw_tbtransf_trans_pend.idagendamento = 1 THEN 'Nesta Data' ELSE TO_CHAR(rw_tbtransf_trans_pend.dtdebito,'DD/MM/RRRR') END; -- Data Efetivacao
                 vr_dsdescri := rw_tbtransf_trans_pend.cdagencia_coop_destino || '/' || rw_tbtransf_trans_pend.nrconta_destino || '-' || SUBSTR(rw_crapass2.nmprimtl,1,20); -- Descricao
                 vr_dstptran := CASE WHEN rw_tbgen_trans_pend.tptransacao = 3 THEN 'Crédito de Salário' ELSE 'Transferência' END; -- Tipo de Transacao
                 vr_dsagenda := CASE WHEN rw_tbtransf_trans_pend.idagendamento = 1 THEN 'NÃO' ELSE 'SIM' END; -- Agendamento
                 
                 --Variaveis especificas
                 vr_cdcopdes := TO_CHAR(rw_tbtransf_trans_pend.cdagencia_coop_destino) || '-' || rw_crapcop.nmrescop;
                 vr_nrcondes := TO_CHAR(rw_tbtransf_trans_pend.nrconta_destino) || '-' || SUBSTR(rw_crapass2.nmprimtl,1,20);
                 vr_dtdebito := TO_CHAR(rw_tbtransf_trans_pend.dtdebito,'DD/MM/RRRR');

            WHEN vr_tptranpe = 2 THEN --Pagamento
                 
                 OPEN cr_tbpagto_trans_pend(pr_cddoitem => vr_cdtranpe);
                 FETCH cr_tbpagto_trans_pend INTO rw_tbpagto_trans_pend;
                 IF cr_tbpagto_trans_pend%NOTFOUND THEN
                    --Fechar Cursor
                    CLOSE cr_tbpagto_trans_pend;
                    CONTINUE;
                 ELSE
                    --Fechar Cursor
                    CLOSE cr_tbpagto_trans_pend;
                   
                    --Controle de paginação
                    vr_qttotpen := vr_qttotpen + 1;
                    IF ((vr_qttotpen <= pr_nriniseq) OR
                       (vr_qttotpen > (pr_nriniseq + pr_nrregist))) THEN
                       CONTINUE;
                    END IF;
                 END IF;
                 
                 --Valor a somar
                 vr_vlasomar := rw_tbpagto_trans_pend.vlpagamento;
                 
                 --Variaveis do resumo
                 vr_dsvltran := TO_CHAR(rw_tbpagto_trans_pend.vlpagamento,'fm999g999g990d00'); -- Valor
                 vr_dsdtefet := CASE WHEN rw_tbpagto_trans_pend.idagendamento = 1 THEN 'Nesta Data' ELSE TO_CHAR(rw_tbpagto_trans_pend.dtdebito,'DD/MM/RRRR') END; -- Data Efetivacao
                 vr_dsdescri := rw_tbpagto_trans_pend.dscedente; -- Descricao
                 vr_dstptran := CASE WHEN rw_tbpagto_trans_pend.tppagamento = 1 THEN 'Pagamento de Convênio' ELSE 'Pagamento de Boletos Diversos' END; -- Tipo de Transacao
                 vr_dsagenda := CASE WHEN rw_tbpagto_trans_pend.idagendamento = 1 THEN 'NÃO' ELSE 'SIM' END; -- Agendamento
                 
                 --Variaveis especificas
                 vr_nmcednte := rw_tbpagto_trans_pend.dscedente;
                 vr_nrcodbar := rw_tbpagto_trans_pend.dscodigo_barras;
                 vr_dslindig := rw_tbpagto_trans_pend.dslinha_digitavel;
                 vr_dtvencto := TO_CHAR(rw_tbpagto_trans_pend.dtvencimento,'DD/MM/RRRR');
                 vr_vldocmto := TO_CHAR(rw_tbpagto_trans_pend.vldocumento,'fm999g999g990d00');
                 vr_dtdebito := TO_CHAR(rw_tbpagto_trans_pend.dtdebito,'DD/MM/RRRR');
                 vr_identdda := CASE WHEN rw_tbpagto_trans_pend.idtitulo_dda = 0 THEN 'NÃO' ELSE 'SIM' END;
                 
            WHEN vr_tptranpe = 4 THEN --TED
                 
                 OPEN cr_tbspb_trans_pend(pr_cddoitem => vr_cdtranpe);
                 FETCH cr_tbspb_trans_pend INTO rw_tbspb_trans_pend;
                 IF cr_tbspb_trans_pend%NOTFOUND THEN
                    --Fechar Cursor
                    CLOSE cr_tbspb_trans_pend;
                    CONTINUE;
                 ELSE
                    --Fechar Cursor
                    CLOSE cr_tbspb_trans_pend;

                    --Controle de paginação
                    vr_qttotpen := vr_qttotpen + 1;
                    IF ((vr_qttotpen <= pr_nriniseq) OR
                       (vr_qttotpen > (pr_nriniseq + pr_nrregist))) THEN
                       CONTINUE;
                    END IF;
                 END IF;
                 
                 --Cadastro de Transferencias pela Internet
                 OPEN cr_crapcti( pr_cdcooper => rw_tbspb_trans_pend.cdcooper,
                                  pr_nrdconta => rw_tbspb_trans_pend.nrdconta,
                                  pr_cddbanco => rw_tbspb_trans_pend.cdbanco_favorecido,
                                  pr_cdageban => rw_tbspb_trans_pend.cdagencia_favorecido,
                                  pr_nrctatrf => rw_tbspb_trans_pend.nrconta_favorecido);
                 FETCH cr_crapcti INTO rw_crapcti;	
                 IF cr_crapcti%NOTFOUND THEN
                    --Fechar Cursor
                    CLOSE cr_crapcti;

                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Registro de Cadastro de transferencias nao encontrado.';
                    --Levantar Excecao
                    RAISE vr_exc_erro;
                 ELSE
                    --Fechar Cursor
                    CLOSE cr_crapcti;
                 END IF;
                 
                 --Buscar nome do banco favorecido
                 IF rw_tbspb_trans_pend.nrispb_banco_favorecido = 0 THEN
                    OPEN cr_crapban1 (pr_cdbccxlt => rw_tbspb_trans_pend.cdbanco_favorecido);
                    FETCH cr_crapban1 INTO vr_cddbanco,
                                           vr_nmextbcc;
                    --Fechar Cursor
                    CLOSE cr_crapban1;
                 ELSE 
                    OPEN cr_crapban2 (pr_nrispbif => rw_tbspb_trans_pend.nrispb_banco_favorecido);
                    FETCH cr_crapban2 INTO vr_cddbanco,
                                           vr_nmextbcc;
                    --Fechar Cursor
                    CLOSE cr_crapban2;
                 END IF;
                 
                 IF vr_nmextbcc IS NULL OR vr_nmextbcc = ' ' THEN
                    vr_nmextbcc := 'BANCO NAO CADASTRADO';
                 END IF;
                 
                 --Buscar Finalidade
                 vr_dsfindad := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_tbspb_trans_pend.cdcooper
                                                          ,pr_nmsistem => 'CRED'
                                                          ,pr_tptabela => 'GENERI'
                                                          ,pr_cdempres => 0
                                                          ,pr_cdacesso => 'FINTRFTEDS'
                                                          ,pr_tpregist => rw_tbspb_trans_pend.cdfinalidade);  
                  
                 IF vr_dsfindad IS NULL THEN
                   vr_dsfindad := 'FINALIDADE NAO CADASTRADA';
                 END IF;
                 
                 --Buscar Agencia
                 OPEN cr_crapagb( pr_cddbanco => vr_cddbanco ,
                                  pr_cdageban => rw_tbspb_trans_pend.cdagencia_favorecido);
                 FETCH cr_crapagb INTO vr_dsagenci;	
                 IF cr_crapagb%NOTFOUND THEN
                    --Fechar Cursor
                    CLOSE cr_crapagb;
                    vr_dsagenci := 'AGENCIA NAO CADASTRADA';
                 ELSE
                    --Fechar Cursor
                    CLOSE cr_crapagb;
                 END IF;
                 
                 --Valor a somar
                 vr_vlasomar := rw_tbspb_trans_pend.vlted;
                 
                 --Variaveis de resumo
                 vr_dsvltran := TO_CHAR(rw_tbspb_trans_pend.vlted,'fm999g999g990d00'); -- Valor
                 vr_dsdtefet := CASE WHEN rw_tbspb_trans_pend.idagendamento = 1 THEN 'Nesta Data' ELSE TO_CHAR(rw_tbspb_trans_pend.dtdebito,'DD/MM/RRRR') END; -- Data Efetivacao
                 vr_dsdescri := TO_CHAR(rw_tbspb_trans_pend.nrconta_favorecido) || ' - ' || SUBSTR(rw_crapcti.nmtitula,1,20); -- Descricao
                 vr_dstptran := 'TED'; -- Tipo de Transacao
                 vr_dsagenda := CASE WHEN rw_tbspb_trans_pend.idagendamento = 1 THEN 'NÃO' ELSE 'SIM' END; -- Agendamento
                 
                 --Variaveis especificas
                 vr_nmbanfav := rw_tbspb_trans_pend.cdbanco_favorecido || '-' || vr_nmextbcc; --Banco Favorecido
                 vr_nmdoispb := rw_tbspb_trans_pend.nrispb_banco_favorecido || '-' || vr_nmextbcc; --ISPB
                 vr_nmagenci := rw_tbspb_trans_pend.cdagencia_favorecido || '-' || vr_dsagenci; --Agencia do Favorecido
                 vr_nrctafav := rw_tbspb_trans_pend.nrconta_favorecido; --Conta do Favorecido
                 vr_nomdofav := rw_crapcti.nmtitula; --Nome do Favorecido
                 vr_cpfcgcfv := rw_crapcti.nrcpfcgc; --CPF/CNPJ do Favorecido
                 vr_dshistco := rw_tbspb_trans_pend.dshistorico; --Historico Complementar
                 vr_cdidenti := rw_tbspb_trans_pend.dscodigo_identificador; --Codigo Identificador
                 vr_dtdodebi := TO_CHAR(rw_tbspb_trans_pend.dtdebito,'DD/MM/RRRR'); --Debito Em
                 
            WHEN vr_tptranpe = 6 THEN --Credito Pre-Aprovado
                 
                 OPEN cr_tbepr_trans_pend(pr_cddoitem => vr_cdtranpe);
                 FETCH cr_tbepr_trans_pend INTO rw_tbepr_trans_pend;
                 IF cr_tbepr_trans_pend%NOTFOUND THEN
                    --Fechar Cursor
                    CLOSE cr_tbepr_trans_pend;
                    CONTINUE;
                 ELSE
                    --Fechar Cursor
                    CLOSE cr_tbepr_trans_pend;
                    
                    --Controle de paginação
                    vr_qttotpen := vr_qttotpen + 1;
                    IF ((vr_qttotpen <= pr_nriniseq) OR
                       (vr_qttotpen > (pr_nriniseq + pr_nrregist))) THEN
                       CONTINUE;
                    END IF;
                 END IF;
                 
                 --Valor a somar
                 vr_vlasomar := rw_tbepr_trans_pend.vlemprestimo;
                 
                 --Variaveis resumo
                 vr_dsvltran := TO_CHAR(rw_tbepr_trans_pend.vlemprestimo,'fm999g999g990d00'); -- Valor
                 vr_dsdtefet := 'Nesta Data'; -- Data Efetivacao
                 vr_dsdescri := 'CRÉDITO PRÉ-APROVADO - ' || TO_CHAR(rw_tbepr_trans_pend.nrparcelas) || ' vezes de R$ ' || TO_CHAR(rw_tbepr_trans_pend.vlparcela,'fm999g999g990d00'); -- Descricao
                 vr_dstptran := 'Crédito Pré-Aprovado'; -- Tipo de Transacao
                 vr_dsagenda := 'NÃO'; -- Agendamento
                 
                 --Variaveis especificas
                 vr_qtdparce := rw_tbepr_trans_pend.nrparcelas; --Quantidade de Parcelas
                 vr_vldparce := TO_CHAR(rw_tbepr_trans_pend.vlparcela,'fm999g999g990d00'); --Valor da Parcela
                 vr_dtpriven := TO_CHAR(rw_tbepr_trans_pend.dtprimeiro_vencto,'DD/MM/RRRR'); --Primeiro Vencimento
                 vr_vlpercet := TO_CHAR(rw_tbepr_trans_pend.vlpercentual_cet,'fm999g999g990d00'); --CET
                 vr_vltarifa := TO_CHAR(rw_tbepr_trans_pend.vltarifa,'fm999g999g990d00'); --Tarifa
                 vr_vltaxmen := TO_CHAR(rw_tbepr_trans_pend.vltaxa_mensal,'fm999g999g990d00'); --Taxa Mensal
                 vr_vlrdoiof := TO_CHAR(rw_tbepr_trans_pend.vliof,'fm999g999g990d00'); --IOF
                 vr_vlperiof := TO_CHAR(rw_tbepr_trans_pend.vlpercentual_iof,'fm999g999g990d0000'); --Percentual IOF
                 
            WHEN vr_tptranpe = 7 THEN --Aplicacao
                 
                 OPEN cr_tbcapt_trans_pend(pr_cddoitem => vr_cdtranpe);
                 FETCH cr_tbcapt_trans_pend INTO rw_tbcapt_trans_pend;
                 IF cr_tbcapt_trans_pend%NOTFOUND THEN
                    --Fechar Cursor
                    CLOSE cr_tbcapt_trans_pend;
                    CONTINUE;
                 ELSE
                    --Fechar Cursor
                    CLOSE cr_tbcapt_trans_pend;
                    
                    --Controle de paginação
                    vr_qttotpen := vr_qttotpen + 1;
                    IF ((vr_qttotpen <= pr_nriniseq) OR
                       (vr_qttotpen > (pr_nriniseq + pr_nrregist))) THEN
                       CONTINUE;
                    END IF;
                 END IF;
                 
                 vr_tpopeapl := rw_tbcapt_trans_pend.tpoperacao; -- Tipo de Operacao (da Aplicacao)
                 vr_nraplica := rw_tbcapt_trans_pend.nraplicacao; --Número da Aplicacao
                 vr_tpagenda := rw_tbcapt_trans_pend.tpagendamento; --Tipo do Agendamento: 
                 vr_docagend := rw_tbcapt_trans_pend.nrdocto_agendamento; --Documento Agendamento
                 vr_flageuni := rw_tbcapt_trans_pend.idperiodo_agendamento; --Agendamento (0) unico ou (1) mensal
                 vr_nrdiacre := rw_tbcapt_trans_pend.nrdia_agendamento; --Creditar no dia
                 vr_qtdmeses := rw_tbcapt_trans_pend.qtmeses_agendamento; --Qtd meses agendado
                 
                 CASE
                     WHEN rw_tbcapt_trans_pend.tpoperacao = 1 THEN --Cancelamento Aplicacao
                          OPEN cr_craprda(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nraplica => rw_tbcapt_trans_pend.nraplicacao);
                          FETCH cr_craprda INTO vr_vlaplica;
                          IF cr_craprda%NOTFOUND THEN
                             --Fechar Cursor
                             CLOSE cr_craprda;
                          ELSE
                             --Fechar Cursor
                             CLOSE cr_craprda;
                                                    
                             apli0005.pc_lista_aplicacoes ( pr_cdcooper => pr_cdcooper
                                                           ,pr_cdoperad => 900
                                                           ,pr_nmdatela => 'INTERNETBANK'
                                                           ,pr_idorigem => 3
                                                           ,pr_nrdcaixa => '996'
                                                           ,pr_nrdconta => pr_nrdconta
                                                           ,pr_idseqttl => 1
                                                           ,pr_cdagenci => 90
                                                           ,pr_cdprogra => 'INTERNETBANK'
                                                           ,pr_nraplica => rw_tbcapt_trans_pend.nraplicacao
                                                           ,pr_cdprodut => 0
                                                           ,pr_dtmvtolt => pr_dtmvtolt 
                                                           ,pr_idconsul => 2 
                                                           ,pr_idgerlog => 0
                                                           ,pr_cdcritic => vr_cdcritic
                                                           ,pr_dscritic => vr_dscritic
                                                           ,pr_saldo_rdca => vr_saldo_rdca);                             
                          END IF;    
                          
                          --Valor a somar
                          vr_vlasomar := vr_vlaplica;
                          
                          vr_dsvltran := TO_CHAR(vr_vlaplica,'fm999g999g990d00'); -- Valor
                          vr_dsdtefet := 'Nesta Data'; -- Data Efetivacao
                          vr_dsdescri := 'CANCELAMENTO APLICACAO NR. ' || TO_CHAR(rw_tbcapt_trans_pend.nraplicacao); -- Descricao
                          vr_dstptran := 'Cancelamento Aplicação'; -- Tipo de Transacao
                          vr_dsagenda := 'NÃO'; -- Agendamento
                          
                          -- Vai para o primeiro registro
                          vr_ind := vr_saldo_rdca.FIRST; 
                          WHILE vr_ind IS NOT NULL LOOP
                             vl_dtaplica := TO_CHAR(vr_saldo_rdca(vr_ind).dtmvtolt,'DD/MM/RRRR'); --Data da Aplicacao
                             vr_nmdprodu := vr_saldo_rdca(vr_ind).dshistor; --Nome do Produto
                             vr_carencia := vr_saldo_rdca(vr_ind).qtdiacar; --Carencia
                             vr_dtcarenc := TO_CHAR(vr_saldo_rdca(vr_ind).dtcarenc,'DD/MM/RRRR'); --Data da Carencia
                             vr_dtrdavct := TO_CHAR(vr_saldo_rdca(vr_ind).dtvencto,'DD/MM/RRRR'); --Data de Vencimento
                             EXIT;
                          END LOOP;
                          
                     WHEN rw_tbcapt_trans_pend.tpoperacao = 2 THEN --Resgate
                          
                          apli0005.pc_lista_aplicacoes(pr_cdcooper => pr_cdcooper
                                                      ,pr_cdoperad => '996'
                                                      ,pr_nmdatela => 'INTERNETBANK'
                                                      ,pr_idorigem => 3
                                                      ,pr_nrdcaixa => 900
                                                      ,pr_nrdconta => pr_nrdconta
                                                      ,pr_idseqttl => 1
                                                      ,pr_cdagenci => 90
                                                      ,pr_cdprogra => 'INTERNETBANK'
                                                      ,pr_nraplica => rw_tbcapt_trans_pend.nraplicacao
                                                      ,pr_cdprodut => 0
                                                      ,pr_dtmvtolt => pr_dtmvtolt 
                                                      ,pr_idconsul => 2 
                                                      ,pr_idgerlog => 0
                                                      ,pr_cdcritic => vr_cdcritic
                                                      ,pr_dscritic => vr_dscritic
                                                      ,pr_saldo_rdca => vr_saldo_rdca);
                                                           
                          --Valor a somar
                          vr_vlasomar := rw_tbcapt_trans_pend.vlresgate;
                                         
                          vr_dsdtefet := 'Nesta Data'; -- Data Efetivacao
                          vr_dsdescri := 'RESGATE ' || (CASE WHEN rw_tbcapt_trans_pend.tpresgate = 1 THEN 'PARCIAL' ELSE 'TOTAL' END) || ' NA APLICACAO NR. ' || TO_CHAR(rw_tbcapt_trans_pend.nraplicacao);-- Descricao
                          vr_dstptran := 'Resgate de Aplicação'; -- Tipo de Transacao
                          vr_dsagenda := 'NÃO'; -- Agendamento
                          
                          -- Vai para o primeiro registro
                          vr_ind := vr_saldo_rdca.FIRST; 
                          
                          WHILE vr_ind IS NOT NULL LOOP
                             vr_nmdprodu := vr_saldo_rdca(vr_ind).dshistor; --Nome do Produto
                             vr_dtrdavct := TO_CHAR(vr_saldo_rdca(vr_ind).dtvencto,'DD/MM/RRRR'); --Data de Vencimento
                             vr_sldresga := TO_CHAR(vr_saldo_rdca(vr_ind).sldresga,'fm999g999g990d00'); --Saldo Resgate
                             vr_vlresgat := CASE WHEN rw_tbcapt_trans_pend.tpresgate = 1 THEN TO_CHAR(rw_tbcapt_trans_pend.vlresgate,'fm999g999g990d00') ELSE vr_sldresga END; --Valor do Resgate
                             EXIT;
                          END LOOP;
                          
                          vr_dsvltran := vr_vlresgat; -- Valor
                          vr_dtresgat := TO_CHAR(rw_tbgen_trans_pend.dtmvtolt,'DD/MM/RRRR'); --Data do Resgate                          
                          vr_tpresgat := CASE WHEN rw_tbcapt_trans_pend.tpresgate = 1 THEN 'PARCIAL' ELSE 'TOTAL' END; --Tipo do Resgate
                          
                     WHEN rw_tbcapt_trans_pend.tpoperacao = 3 THEN --Agendamento Resgate
                          
                          --Valor a somar

                          vr_vlasomar := rw_tbcapt_trans_pend.vlresgate;
                          
                          vr_dsvltran := TO_CHAR(rw_tbcapt_trans_pend.vlresgate,'fm999g999g990d00'); -- Valor
                          --vr_dsdtefet := TO_CHAR(rw_tbcapt_trans_pend.dtinicio_agendamento,'DD/MM/RRRR'); -- Data Efetivacao
               
                          IF rw_tbcapt_trans_pend.idperiodo_agendamento = 0 THEN
                            vr_dsdtefet := TO_CHAR(rw_tbcapt_trans_pend.dtinicio_agendamento,'DD/MM/RRRR');                    
                          ELSE
                            vr_dsdtefet := TO_CHAR(TO_DATE(LPAD(NVL(rw_tbcapt_trans_pend.nrdia_agendamento,1),2,0) || '/' || to_CHAR(pr_dtmvtolt,'mm/RRRR'),'dd/mm/RRRR'),'DD/MM/RRRR');
                                             
                            IF (TO_DATE(LPAD(NVL(rw_tbcapt_trans_pend.nrdia_agendamento,1),2,0) || '/' || to_CHAR(pr_dtmvtolt,'mm/RRRR'),'dd/mm/RRRR')) <= pr_dtmvtolt THEN 
                               vr_dsdtefet := TO_CHAR(TO_DATE(LPAD(NVL(rw_tbcapt_trans_pend.nrdia_agendamento,1),2,0) || '/' || to_CHAR(ADD_MONTHS(pr_dtmvtolt,1),'mm/RRRR'),'dd/mm/RRRR'),'DD/MM/RRRR');
                            END IF;                    
                          END IF;

                          IF to_date(vr_dsdtefet,'dd/mm/rrrr') NOT BETWEEN pr_dtiniper AND pr_dtfimper THEN
                            CONTINUE;                                                               
                          END IF;
                          
                          vr_dsdescri := 'RESGATE COM AGENDAMENTO ' || (CASE WHEN rw_tbcapt_trans_pend.idperiodo_agendamento = 0 THEN 'ÚNICO' ELSE 'MENSAL' END);-- Descricao
                          vr_dstptran := 'Agendamento de Resgate'; -- Tipo de Transacao
                          vr_dsagenda := 'SIM'; -- Agendamento                       
                          
                     WHEN rw_tbcapt_trans_pend.tpoperacao = 4 THEN --Cancelamento Total Agendamento
                          APLI0002.pc_consulta_agendamento(pr_cdcooper => pr_cdcooper
                                                          ,pr_flgtipar => 2 -- Todos Agendamentos 
                                                          ,pr_nrdconta => pr_nrdconta 
                                                          ,pr_idseqttl => 0 -- Todos Titulares 
                                                          ,pr_nrctraar => rw_tbcapt_trans_pend.nrdocto_agendamento 
                                                          ,pr_cdcritic => vr_cdcritic 
                                                          ,pr_dscritic => vr_dscritic
                                                          ,pr_tab_agen => vr_tab_agen);                                                         
                                                   			                  
                          vr_nrindice := vr_tab_agen.FIRST;
                          
                          WHILE vr_nrindice IS NOT NULL LOOP
                              IF vr_tab_agen(vr_nrindice).flgtipar = 0 THEN --Aplicacao
                                 vr_dsdescri := 'CANCELAR APLICACAO COM AGENDAMENTO ' || (CASE WHEN vr_tab_agen(vr_nrindice).flgtipin = 0 THEN 'ÚNICO' ELSE 'MENSAL' END);-- Descricao
                                 vr_dstptran := 'Cancelamento Agendamento Aplicação'; -- Tipo de Transacao
                                 vr_dsagenda := 'SIM'; -- Agendamento
                              ELSE --Resgate
                                 vr_dsdescri := 'CANCELAR RESGATE COM AGENDAMENTO ' || (CASE WHEN vr_tab_agen(vr_nrindice).flgtipin = 0 THEN 'ÚNICO' ELSE 'MENSAL' END);-- Descricao
                                 vr_dstptran := 'Cancelamento Agendamento Resgate'; -- Tipo de Transacao
                                 vr_dsagenda := 'SIM'; -- Agendamento
                              END IF;                                
                          
                              --Valor a somar
                              vr_vlasomar := vr_tab_agen(vr_nrindice).vlparaar;
                              vr_flageuni := vr_tab_agen(vr_nrindice).flgtipin;
                              vr_tpagenda := vr_tab_agen(vr_nrindice).flgtipar;
                              vr_nrdiacre := vr_tab_agen(vr_nrindice).dtdiaaar;
                              vr_dsvltran := TO_CHAR(vr_tab_agen(vr_nrindice).vlparaar,'fm999g999g990d00'); -- Valor
                              vr_dsdtefet := TO_CHAR(vr_tab_agen(vr_nrindice).dtiniaar,'DD/MM/RRRR'); -- Data Efetivacao                              
                              vr_qtdmeses := vr_tab_agen(vr_nrindice).qtmesaar; --Durante
                              
                              EXIT;
                          END LOOP; 

                          IF to_date(vr_dsdtefet,'dd/mm/rrrr') NOT BETWEEN pr_dtiniper AND pr_dtfimper THEN
                            CONTINUE;                                                               
                          END IF;                    
                          
                     WHEN rw_tbcapt_trans_pend.tpoperacao = 5 THEN --Cancelamento Item Agendamento
                          --aplicacao
                          IF rw_tbcapt_trans_pend.tpagendamento = 0 THEN
                             vr_nrdolote := 32001;
                             vr_cdhistor := 527;
                          ELSE --resgate
                             vr_nrdolote := 32002;
                             vr_cdhistor := 530;
                          END IF;
  												
                          --separar o nrdocmto, pois vem concatenado com nrdolote || nrdocmto 
                          vr_nrdocmto := SUBSTR(rw_tbcapt_trans_pend.nrdocto_agendamento,6,10);
                          
                          APLI0002.pc_consulta_det_agendmto(pr_cdcooper => pr_cdcooper
                                                           ,pr_nrdocmto => vr_nrdocmto
                                                           ,pr_nrdolote => vr_nrdolote
                                                           ,pr_nrdconta => pr_nrdconta
                                                           ,pr_cdhistor => vr_cdhistor
                                                           ,pr_cdcritic => vr_cdcritic
                                                           ,pr_dscritic => vr_dscritic
                                                           ,pr_tab_agen_det => vr_tab_agen_det);
                          
                          IF rw_tbcapt_trans_pend.tpagendamento = 0 THEN
                            vr_dsdescri := 'CANCELAR AGENDAMENTO APLICAÇÃO';-- Descricao
                            vr_dstptran := 'Cancelamento Agendamento Aplicação'; -- Tipo de Transacao
                            vr_dsagenda := 'SIM'; -- Agendamento
                               
                          ELSE --Resgate
                            vr_dsdescri := 'CANCELAR AGENDAMENTO RESGATE';-- Descricao
                            vr_dstptran := 'Cancelamento Agendamento Resgate'; -- Tipo de Transacao
                            vr_dsagenda := 'SIM'; -- Agendamento                               
                          END IF;
                             
                          vr_nrindice := vr_tab_agen_det.FIRST;
                          
                          WHILE vr_nrindice IS NOT NULL LOOP
                             
                             IF vr_tab_agen_det(vr_nrindice).nrdocmto <> rw_tbcapt_trans_pend.nrdocto_agendamento THEN
                                vr_nrindice := vr_tab_agen_det.NEXT(vr_nrindice);
                                CONTINUE;
                             END IF;
                              
                             --Valor a somar
                             vr_vlasomar := vr_tab_agen_det(vr_nrindice).vllanaut; 
                                
                             vr_dsvltran := TO_CHAR(vr_tab_agen_det(vr_nrindice).vllanaut,'fm999g999g990d00'); -- Valor do aplicacao
                             vr_dsdtefet := TO_CHAR(vr_tab_agen_det(vr_nrindice).dtmvtopg,'DD/MM/RRRR'); -- Data efetivacao                               
                             
                             EXIT;
                          END LOOP;  
                          
                          IF to_date(vr_dsdtefet,'dd/mm/rrrr') NOT BETWEEN pr_dtiniper AND pr_dtfimper THEN
                            CONTINUE;                                                               
                          END IF;   
                          
                 END CASE; -- END CASE
               
            WHEN vr_tptranpe = 8 THEN --Debito Automatico
                 
                 OPEN cr_tbconv_trans_pend(pr_cddoitem => vr_cdtranpe);
                 FETCH cr_tbconv_trans_pend INTO rw_tbconv_trans_pend;
                 IF cr_tbconv_trans_pend%NOTFOUND THEN
                    --Fechar Cursor
                    CLOSE cr_tbconv_trans_pend;
                    CONTINUE;
                 ELSE
                    --Fechar Cursor
                    CLOSE cr_tbconv_trans_pend;
                    
                    --Controle de paginação
                    vr_qttotpen := vr_qttotpen + 1;
                    IF ((vr_qttotpen <= pr_nriniseq) OR
                       (vr_qttotpen > (pr_nriniseq + pr_nrregist))) THEN
                       CONTINUE;
                    END IF;
                 END IF;
                 
                 vr_tpopconv := rw_tbconv_trans_pend.tpoperacao;
                 
                 IF rw_tbconv_trans_pend.tpoperacao = 1 THEN --Autorizacao Debito Automatico
                    OPEN cr_crapcon(pr_cdcooper => pr_cdcooper,
                                    pr_cdsegmto => rw_tbconv_trans_pend.cdsegmento_conven,
                                    pr_cdempcon => rw_tbconv_trans_pend.cdconven);
                    FETCH cr_crapcon INTO vr_nmrescon;
                    IF cr_crapcon%NOTFOUND THEN
                       --Fechar Cursor
                       CLOSE cr_crapcon;
                       vr_nmrescon := 'EMPRESA CONVENIADA NAO CADASTRADA';  
                    ELSE
                       --Fechar Cursor
                       CLOSE cr_crapcon;
                    END IF;
                    
                    --Valor a somar
                    vr_vlasomar := 0;
                    
                    vr_dsvltran := ' '; -- Valor
                    vr_dsdtefet := 'Nesta Data'; -- Data Efetivacao
                    vr_dsdescri := 'DEBITO AUTOMATICO - ' || vr_nmrescon;-- Descricao
                    vr_dstptran := 'Autorização Débito Automático'; -- Tipo de Transacao
                    vr_dsagenda := 'NÃO'; -- Agendamento
                        
                    vr_iddebaut := rw_tbconv_trans_pend.iddebito_automatico; --Identificação do Consumidor: 
                    vr_dshistor := rw_tbconv_trans_pend.dshist_debito; --Histórico Complementar
                    vr_vlmaxdeb := TO_CHAR(rw_tbconv_trans_pend.vlmaximo_debito,'fm999g999g990d00'); --Limite Máximo Para Débito
												
								ELSIF rw_tbconv_trans_pend.tpoperacao = 2 OR   --Bloqueio Debito Automatico
								      rw_tbconv_trans_pend.tpoperacao = 3 THEN --Desbloqueio Debito Automatico
                    OPEN cr_autodeb(pr_cdcooper => pr_cdcooper,
                                    pr_nrdconta => pr_nrdconta,
                                    pr_cdhistor => rw_tbconv_trans_pend.cdhist_convenio,
                                    pr_cdrefere => rw_tbconv_trans_pend.nrdocumento_fatura,
                                    pr_dtmvtopg => rw_tbconv_trans_pend.dtdebito_fatura);
                    FETCH cr_autodeb INTO vr_nmrescon,
                                          vr_vllanaut;
                    IF cr_autodeb%NOTFOUND THEN
                       --Fechar Cursor
                       CLOSE cr_autodeb;
                       
                       vr_vllanaut := 0;
                       vr_nmrescon := '';                       
                    ELSE
                       --Fechar Cursor
                       CLOSE cr_autodeb;
                       
                       vr_nmrescon := ' - ' || vr_nmrescon;
                    END IF;
                        
                    --Valor a somar
                    vr_vlasomar := vr_vllanaut;                        
                    
                    vr_dsvltran := TO_CHAR(vr_vllanaut,'fm999g999g990d00'); -- Valor
                    vr_dsdtefet := TO_CHAR(rw_tbconv_trans_pend.dtdebito_fatura,'DD/MM/RRRR'); -- Data Efetivacao
                    vr_dsdescri := (CASE WHEN rw_tbconv_trans_pend.tpoperacao = 2 THEN 'BLOQUEIO' ELSE 'DESBLOQUEIO' END) || ' DEBITO AUTOMATICO ' || vr_nmrescon;-- Descricao
                    vr_dstptran := (CASE WHEN rw_tbconv_trans_pend.tpoperacao = 2 THEN 'Bloqueio' ELSE 'Desbloqueio' END) || ' Débito Automático'; -- Tipo de Transacao
                    vr_dsagenda := 'NÃO'; -- Agendamento
                          
                    vr_dtdebfat := TO_CHAR(rw_tbconv_trans_pend.dtdebito_fatura,'DD/MM/RRRR'); --Data do Débito
                    vr_nrdocfat := rw_tbconv_trans_pend.nrdocumento_fatura; --Documento do Débito                    
							  END IF;
                 
            WHEN vr_tptranpe = 9 THEN --Folha de Pagamento
                 
                 OPEN cr_tbfolha_trans_pend(pr_cddoitem => vr_cdtranpe);
                 FETCH cr_tbfolha_trans_pend INTO rw_tbfolha_trans_pend;
                 IF cr_tbfolha_trans_pend%NOTFOUND THEN
                    --Fechar Cursor
                    CLOSE cr_tbfolha_trans_pend;
                    CONTINUE;
                 ELSE
                    --Fechar Cursor
                    CLOSE cr_tbfolha_trans_pend;
                    
                    --Controle de paginação
                    vr_qttotpen := vr_qttotpen + 1;
                    IF ((vr_qttotpen <= pr_nriniseq) OR
                       (vr_qttotpen > (pr_nriniseq + pr_nrregist))) THEN
                       CONTINUE;
                    END IF;
                 END IF;
                 
                 --Valor a somar
                 vr_vlasomar := rw_tbfolha_trans_pend.vlfolha;
                    
                 vr_dsvltran := TO_CHAR(rw_tbfolha_trans_pend.vlfolha,'fm999g999g990d00'); -- Valor
                 vr_dsdtefet := TO_CHAR(rw_tbfolha_trans_pend.dtdebito,'DD/MM/RRRR'); -- Data Efetivacao
                 vr_dsdescri := 'FOLHA DE PAGAMENTO';-- Descricao
                 vr_dstptran := 'Folha de Pagamento'; -- Tipo de Transacao
                 vr_dsagenda := 'NÃO'; -- Agendamento
                 
                 vr_nrqtlnac := rw_tbfolha_trans_pend.nrlanctos; --Quantidade de Lançamentos
                 vr_solestou := CASE WHEN rw_tbfolha_trans_pend.idestouro = 0 THEN 'NÃO' ELSE 'SIM' END; --Solicitado Estouro
                 vr_vltarifa := TO_CHAR(rw_tbfolha_trans_pend.vltarifa,'fm999g999g990d00'); --Valor da Tarifa

            WHEN vr_tptranpe = 10 THEN --Pacote de tarifas
							
						     OPEN cr_pactar(vr_cdtranpe);
								 FETCH cr_pactar INTO rw_pactar;
								 
								 IF cr_pactar%NOTFOUND THEN
                    --Fechar Cursor
                    CLOSE cr_pactar;
                    CONTINUE;
                 ELSE
                    --Fechar Cursor
                    CLOSE cr_pactar;
                    
                    --Controle de paginação
                    vr_qttotpen := vr_qttotpen + 1;
                    IF ((vr_qttotpen <= pr_nriniseq) OR
                       (vr_qttotpen > (pr_nriniseq + pr_nrregist))) THEN
                       CONTINUE;
                    END IF;
                 END IF;
						
								 vr_vlasomar := 0;
								 vr_dsvltran := ' '; -- Valor
								 vr_dsdtefet := 'Mes atual'; -- Data Efetivacao
								 vr_dsdescri := 'SERVIÇOS COOPERATIVOS'; -- Descricao
								 vr_dstptran := 'Adesão de Serviços Cooperativos'; -- Tipo de Transacao
								 vr_dsagenda := 'NÃO'; -- Agendamento
								 
								 vr_vlpacote := to_char(rw_pactar.vlpacote,'fm999g999g990d00');
								 vr_dspacote := rw_pactar.dspacote;
								 vr_dtinivig := to_char(rw_pactar.dtinivig, 'dd/mm/rrrr');
								 vr_dtdiadeb := rw_pactar.dtdiadeb;     
            
            WHEN vr_tptranpe = 11 THEN -- DARF/DAS                 
               OPEN cr_tbpagto_darf_das_trans_pend (pr_cddoitem => vr_cdtranpe);
               FETCH cr_tbpagto_darf_das_trans_pend INTO rw_tbpagto_darf_das_trans_pend;
               IF cr_tbpagto_darf_das_trans_pend%NOTFOUND THEN
                  --Fechar Cursor
                  CLOSE cr_tbpagto_darf_das_trans_pend;
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Registro de Pagamento DARF/DAS pendente nao encontrado.';
                  --Levantar Excecao
                  RAISE vr_exc_erro;
               ELSE
                  --Fechar Cursor
                  CLOSE cr_tbpagto_darf_das_trans_pend;
               END IF;

               -- Tipo de Captura (1 => Código de Barras / 2 => Manual)
               vr_tpcaptura := rw_tbpagto_darf_das_trans_pend.tpcaptura;
               vr_dstipcapt := (CASE WHEN vr_tpcaptura = 1 THEN 'Com Código de Barras' ELSE 'Sem Código de Barras' END);
               -- DADOS DO RESUMO
               vr_cdtranpe := rw_tbpagto_darf_das_trans_pend.cdtransacao_pendente;                -- Código Único da Transação
               vr_dsdtefet := TO_CHAR(rw_tbpagto_darf_das_trans_pend.dtdebito,'dd/MM/RRRR');      -- Data de Efetivação (retornar termo 'Nesta Data' para efetivação online ou a data do agendamento)
               vr_dsvltran := rw_tbpagto_darf_das_trans_pend.vlpagamento;                         -- Valor (retornar valor total do pagamento)
               vr_dsdescri := (CASE
                                WHEN rw_tbpagto_darf_das_trans_pend.dsidentif_pagto IS NULL THEN 
                                  (CASE WHEN rw_tbpagto_darf_das_trans_pend.tppagamento = 1 
                                    THEN 'Pagamento de DARF' ELSE 'Pagamento de DAS' END) 
                                      ELSE rw_tbpagto_darf_das_trans_pend.dsidentif_pagto END) ;  -- Descrição
               vr_tptranpe := rw_tbpagto_darf_das_trans_pend.tppagamento;                         -- Código do Tipo da Transação
               vr_dstptran := (CASE WHEN rw_tbpagto_darf_das_trans_pend.tppagamento = 1 THEN
                                'Pagamento de DARF' ELSE 'Pagamento de DAS' END);                 -- Tipo da Transação
               vr_dsagenda := (CASE WHEN rw_tbpagto_darf_das_trans_pend.IDAGENDAMENTO = 1 THEN
                               'NAO' ELSE 'SIM' END);                                             -- Indicador de Agendamento
               vr_dsnomfone := rw_tbpagto_darf_das_trans_pend.dsnome_fone;
                 
               --DADOS ESPECIFICOS
               IF vr_tpcaptura = 1 THEN
                 vr_dslinha_digitavel := rw_tbpagto_darf_das_trans_pend.dscod_barras; -- Código de Barras
                 vr_dscod_barras := rw_tbpagto_darf_das_trans_pend.dslinha_digitavel; -- Linha Digitável
               ELSIF vr_tpcaptura = 2 THEN 
                 vr_dtapuracao      := rw_tbpagto_darf_das_trans_pend.dtapuracao;
                 vr_nrcpfcgc        := rw_tbpagto_darf_das_trans_pend.nrcpfcgc;
                 vr_cdtributo       := NVL(rw_tbpagto_darf_das_trans_pend.cdtributo,0);
                 vr_nrrefere        := NVL(rw_tbpagto_darf_das_trans_pend.nrrefere,0);
                 vr_dtvencto        := rw_tbpagto_darf_das_trans_pend.dtvencto;
                 vr_vlprincipal     := NVL(rw_tbpagto_darf_das_trans_pend.vlprincipal,0);
                 vr_vlmulta         := NVL(rw_tbpagto_darf_das_trans_pend.vlmulta,0);
                 vr_vljuros         := NVL(rw_tbpagto_darf_das_trans_pend.vljuros,0);
                 vr_vlreceita_bruta := NVL(rw_tbpagto_darf_das_trans_pend.vlreceita_bruta,0);
                 vr_vlpercentual    := NVL(rw_tbpagto_darf_das_trans_pend.vlpercentual,0);
               END IF; 
               vr_vlrtotal        := (NVL(rw_tbpagto_darf_das_trans_pend.vlprincipal,0) + NVL(rw_tbpagto_darf_das_trans_pend.vlmulta,0) + NVL(rw_tbpagto_darf_das_trans_pend.vljuros,0));
               vr_dtdebito        := rw_tbpagto_darf_das_trans_pend.dtdebito;
               vr_idagendamento   := NVL(rw_tbpagto_darf_das_trans_pend.idagendamento,0); 
               vr_vlasomar        := vr_vlrtotal;            
            ELSE
                vr_dscritic := 'Tipo de transação não encontrado.';
                --Levantar Excecao
                RAISE vr_exc_erro;
         END CASE; --case     
         
         --Soma Total da pagina
         vr_vltotpen := vr_vltotpen + vr_vlasomar;
         
         gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                                ,pr_texto_completo => vr_xml_temp 
                                ,pr_texto_novo     => '<transacao>');
         --Resumo da transacao
         gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                                ,pr_texto_completo => vr_xml_temp 
                                ,pr_texto_novo     => '<dados_resumo>'
                                                   || '   <codigo_transacao>'   ||vr_cdtranpe||'</codigo_transacao>'
                                                   || '   <data_efetivacao>'    ||vr_dsdtefet||'</data_efetivacao>'
                                                   || '   <valor_transacao>'    ||vr_dsvltran||'</valor_transacao>'
                                                   || '   <descricao_transacao>'||vr_dsdescri||'</descricao_transacao>'
                                                   || '   <id_tipo_transacao>'  ||vr_tptranpe||'</id_tipo_transacao>'
                                                   || '   <tipo_transacao>'     ||vr_dstptran||'</tipo_transacao>'
                                                   || '   <agendamento>'        ||vr_dsagenda||'</agendamento>'
                                                   || '   <situacao_transacao>' ||vr_dssittra||'</situacao_transacao>'
                                                   || '   <data_alteracao_sit>' ||vr_dtaltera||'</data_alteracao_sit>'
                                                   || '   <pode_alterar>'       ||vr_indiacao||'</pode_alterar>'
                                                   || '</dados_resumo>');
         
         --Detalhes da Transacao
         vr_xml_auxi := '<dados_detalhe>';
         
         --Dados genericos
         vr_xml_auxi := vr_xml_auxi
         || '   <dados_campo><label>'||vr_labnmage||'</label><valor>'   ||vr_nmagenda||'</valor></dados_campo>'
         || '   <dados_campo><label>Data da Transação</label><valor>'   ||vr_dttranpe||'</valor></dados_campo>'
         || '   <dados_campo><label>Hora da Transação</label><valor>'   ||vr_hrtranpe||'</valor></dados_campo>'
         || '   <dados_campo><label>Data de Movimentação</label><valor>'||vr_dtmvttra||'</valor></dados_campo>'
         || '   <dados_campo><label>Situação</label><valor>'            ||vr_dssittra||'</valor></dados_campo>'
         || '   <dados_campo><label>Tipo de Transação</label><valor>'   ||vr_dstptran||'</valor></dados_campo>'
         || '   <dados_campo><label>Origem da Transação</label><valor>' ||vr_dsoritra||'</valor></dados_campo>'
         || CASE WHEN TRIM(vr_dtreptra) IS NOT NULL THEN '<dados_campo><label>Data da Reprovação</label><valor>'  ||vr_dtreptra||'</valor></dados_campo>' ELSE ' ' END
         || CASE WHEN TRIM(vr_dtexctra) IS NOT NULL THEN '<dados_campo><label>Data da Exclusão</label><valor>'    ||vr_dtexctra||'</valor></dados_campo>' ELSE ' ' END
         || CASE WHEN TRIM(vr_dtexptra) IS NOT NULL THEN '<dados_campo><label>Data de Expiração</label><valor>'   ||vr_dtexptra||'</valor></dados_campo>' ELSE ' ' END
         || CASE WHEN TRIM(vr_dscritra) IS NOT NULL THEN '<dados_campo><label>Crítica de Validação</label><valor>'||vr_dscritra||'</valor></dados_campo>' ELSE ' ' END
         || CASE WHEN TRIM(vr_dtvalida) IS NOT NULL THEN '<dados_campo><label>Data da Validação</label><valor>'   ||vr_dtvalida||'</valor></dados_campo>' ELSE ' ' END;
         
         --Dados especificos
         IF vr_tptranpe IN (1,3,5) THEN --Transferencia
            vr_xml_auxi := vr_xml_auxi
            || '<dados_campo><label>Cooperativa Destino</label><valor>'     ||vr_cdcopdes||'</valor></dados_campo>'
            || '<dados_campo><label>Conta Destino</label><valor>'           ||vr_nrcondes||'</valor></dados_campo>'
            || '<dados_campo><label>Valor da Transferência</label><valor>'  ||vr_dsvltran||'</valor></dados_campo>'
            || '<dados_campo><label>Débito Em</label><valor>'               ||vr_dtdebito||'</valor></dados_campo>'
            || '<dados_campo><label>Indicador de Agendamento</label><valor>'||vr_dsagenda||'</valor></dados_campo>';
         ELSIF vr_tptranpe = 2 THEN --Pagamento
            vr_xml_auxi := vr_xml_auxi
            || '<dados_campo><label>Cedente</label><valor>'                 ||vr_nmcednte||'</valor></dados_campo>'
            || '<dados_campo><label>Código de Barras</label><valor>'        ||vr_nrcodbar||'</valor></dados_campo>'
            || '<dados_campo><label>Linha Digitável</label><valor>'         ||vr_dslindig||'</valor></dados_campo>'
            || '<dados_campo><label>Data do Vencimento</label><valor>'      ||vr_dtvencto||'</valor></dados_campo>'
            || '<dados_campo><label>Valor do Documento</label><valor>'      ||vr_vldocmto||'</valor></dados_campo>'
            || '<dados_campo><label>Valor do Pagamento</label><valor>'      ||vr_dsvltran||'</valor></dados_campo>'
            || '<dados_campo><label>Débito Em</label><valor>'               ||vr_dtdebito||'</valor></dados_campo>'
            || '<dados_campo><label>Identificação DDA</label><valor>'       ||vr_identdda||'</valor></dados_campo>'
            || '<dados_campo><label>Indicador de Agendamento</label><valor>'||vr_dsagenda||'</valor></dados_campo>';
         ELSIF vr_tptranpe = 4 THEN --TED
            vr_xml_auxi := vr_xml_auxi
            || '<dados_campo><label>Banco do Favorecido</label><valor>'     ||vr_nmbanfav||'</valor></dados_campo>'
            || '<dados_campo><label>ISPB</label><valor>'                    ||vr_nmdoispb||'</valor></dados_campo>'
            || '<dados_campo><label>Agência do Favorecido</label><valor>'   ||vr_nmagenci||'</valor></dados_campo>'
            || '<dados_campo><label>Conta do Favorecido</label><valor>'     ||vr_nrctafav||'</valor></dados_campo>'
            || '<dados_campo><label>Nome do Favorecido</label><valor>'      ||vr_nomdofav||'</valor></dados_campo>'
            || '<dados_campo><label>CPF/CNPJ do Favorecido</label><valor>'  ||vr_cpfcgcfv||'</valor></dados_campo>'
            || '<dados_campo><label>Finalidade</label><valor>'              ||vr_dsfindad||'</valor></dados_campo>'
            || '<dados_campo><label>Histórico Complementar</label><valor>'  ||vr_dshistco||'</valor></dados_campo>'
            || '<dados_campo><label>Código Identificador</label><valor>'    ||vr_cdidenti||'</valor></dados_campo>'
            || '<dados_campo><label>Valor da TED</label><valor>'            ||vr_dsvltran||'</valor></dados_campo>'
            || '<dados_campo><label>Débito Em</label><valor>'               ||vr_dtdodebi||'</valor></dados_campo>'
            || '<dados_campo><label>Indicador de Agendamento</label><valor>'||vr_dsagenda||'</valor></dados_campo>';            
         ELSIF vr_tptranpe = 6 THEN --Credito Pre-Aprovado
            vr_xml_auxi := vr_xml_auxi
            || '<dados_campo><label>Valor do Crédito</label><valor>'      ||vr_dsvltran||'</valor></dados_campo>'
            || '<dados_campo><label>Quantidade de Parcelas</label><valor>'||vr_qtdparce||'</valor></dados_campo>'
            || '<dados_campo><label>Valor da Parcela</label><valor>'      ||vr_vldparce||'</valor></dados_campo>'
            || '<dados_campo><label>Primeiro Vencimento</label><valor>'   ||vr_dtpriven||'</valor></dados_campo>'
            || '<dados_campo><label>CET</label><valor>'                   ||vr_vlpercet||'</valor></dados_campo>'
            || '<dados_campo><label>Tarifa</label><valor>'                ||vr_vltarifa||'</valor></dados_campo>'
            || '<dados_campo><label>Taxa Mensal</label><valor>'           ||vr_vltaxmen||'</valor></dados_campo>'
            || '<dados_campo><label>IOF</label><valor>'                   ||vr_vlrdoiof||'</valor></dados_campo>'
            || '<dados_campo><label>Percentual IOF</label><valor>'        ||vr_vlperiof||'</valor></dados_campo>';            
         ELSIF vr_tptranpe = 7 THEN --Aplicacao
            IF vr_tpopeapl = 1 THEN --Cancelamento Aplicacao
               vr_xml_auxi := vr_xml_auxi
               || '<dados_campo><label>Número da Aplicação</label><valor>'||vr_nraplica||'</valor></dados_campo>'
               || '<dados_campo><label>Valor da Aplicação</label><valor>' ||vr_dsvltran||'</valor></dados_campo>'
               || '<dados_campo><label>Data da Aplicação</label><valor>'  ||vl_dtaplica||'</valor></dados_campo>'
               || '<dados_campo><label>Nome do Produto</label><valor>'    ||vr_nmdprodu||'</valor></dados_campo>'
               || '<dados_campo><label>Carência</label><valor>'           ||vr_carencia||'</valor></dados_campo>'
               || '<dados_campo><label>Data da Carência</label><valor>'   ||vr_dtcarenc||'</valor></dados_campo>'
               || '<dados_campo><label>Data de Vencimento</label><valor>' ||vr_dtrdavct||'</valor></dados_campo>';
            ELSIF vr_tpopeapl = 2 THEN --Resgate
               vr_xml_auxi := vr_xml_auxi
               || '<dados_campo><label>Número da Aplicação</label><valor>'||vr_nraplica||'</valor></dados_campo>'
               || '<dados_campo><label>Nome do Produto</label><valor>'    ||vr_nmdprodu||'</valor></dados_campo>'
               || '<dados_campo><label>Data de Vencimento</label><valor>' ||vr_dtrdavct||'</valor></dados_campo>'
               || '<dados_campo><label>Saldo para Resgate</label><valor>' ||vr_sldresga||'</valor></dados_campo>'
               || '<dados_campo><label>Data do Resgate</label><valor>'    ||vr_dtresgat||'</valor></dados_campo>'
               || '<dados_campo><label>Valor do Resgate</label><valor>'   ||vr_vlresgat||'</valor></dados_campo>'
               || '<dados_campo><label>Tipo do Resgate</label><valor>'    ||vr_tpresgat||'</valor></dados_campo>';
            ELSIF vr_tpopeapl = 3 THEN --Agendamento Resgate
               IF vr_flageuni = 0 THEN -- Agendamento Único
                  vr_xml_auxi := vr_xml_auxi
                  || '<dados_campo><label>Valor do Resgate</label><valor>'||vr_dsvltran||'</valor></dados_campo>'
                  || '<dados_campo><label>Data do Resgate</label><valor>' ||vr_dsdtefet||'</valor></dados_campo>';
               ELSIF vr_flageuni = 1 THEN --Agendamento Mensal
                  vr_xml_auxi := vr_xml_auxi
                  || '<dados_campo><label>Valor do Resgate</label><valor>'||vr_dsvltran||'</valor></dados_campo>'
                  || '<dados_campo><label>Creditar no Dia</label><valor>' ||vr_nrdiacre||'</valor></dados_campo>'
                  || '<dados_campo><label>Durante</label><valor>'         ||vr_qtdmeses||'</valor></dados_campo>'
                  || '<dados_campo><label>Iniciando Em</label><valor>'    ||vr_dsdtefet||'</valor></dados_campo>';
               END IF;
            ELSIF vr_tpopeapl = 4 THEN --Cancelamento Total Agendamento
               IF vr_flageuni = 0 THEN --Unico
                  IF vr_tpagenda = 1 THEN --Resgate
                     vr_xml_auxi := vr_xml_auxi
                     || '<dados_campo><label>Valor do Resgate</label><valor>'     ||vr_dsvltran||'</valor></dados_campo>'
                     || '<dados_campo><label>Data do Resgate</label><valor>'      ||vr_dsdtefet||'</valor></dados_campo>'
                     || '<dados_campo><label>Tipo do Agendamento</label><valor>'  ||(CASE WHEN vr_tpagenda = 0 THEN 'Aplicação' ELSE 'Resgate' END)||'</valor></dados_campo>'
                     || '<dados_campo><label>Documento Agendamento</label><valor>'||vr_docagend||'</valor></dados_campo>';
                  ELSE --Aplicacao
                     vr_xml_auxi := vr_xml_auxi
                     || '<dados_campo><label>Valor da Aplicação</label><valor>'   ||vr_dsvltran||'</valor></dados_campo>'
                     || '<dados_campo><label>Debitar no Dia</label><valor>'       ||vr_dsdtefet||'</valor></dados_campo>'
                     || '<dados_campo><label>Tipo do Agendamento</label><valor>'  ||(CASE WHEN vr_tpagenda = 0 THEN 'Aplicação' ELSE 'Resgate' END)||'</valor></dados_campo>'
                     || '<dados_campo><label>Documento Agendamento</label><valor>'||vr_docagend||'</valor></dados_campo>';
                  END IF;
               ELSIF vr_flageuni = 1 THEN --Mensal
                  IF vr_tpagenda = 1 THEN --Resgate
                     vr_xml_auxi := vr_xml_auxi
                     || '<dados_campo><label>Valor do Resgate</label><valor>'     ||vr_dsvltran||'</valor></dados_campo>'
                     || '<dados_campo><label>Creditar no Dia</label><valor>'      ||vr_nrdiacre||'</valor></dados_campo>'
                     || '<dados_campo><label>Durante</label><valor>'              ||vr_qtdmeses||'</valor></dados_campo>'
                     || '<dados_campo><label>Iniciando Em</label><valor>'         ||vr_dsdtefet||'</valor></dados_campo>'
                     || '<dados_campo><label>Tipo do Agendamento</label><valor>'  ||(CASE WHEN vr_tpagenda = 0 THEN 'Aplicação' ELSE 'Resgate' END)||'</valor></dados_campo>'
                     || '<dados_campo><label>Documento Agendamento</label><valor>'||vr_docagend||'</valor></dados_campo>';
                  ELSE --Aplicacao
                     vr_xml_auxi := vr_xml_auxi
                     || '<dados_campo><label>Valor da Aplicação</label><valor>'   ||vr_dsvltran||'</valor></dados_campo>'
                     || '<dados_campo><label>Debitar no Dia</label><valor>'       ||vr_nrdiacre||'</valor></dados_campo>'
                     || '<dados_campo><label>Durante</label><valor>'              ||vr_qtdmeses||'</valor></dados_campo>'
                     || '<dados_campo><label>Iniciando Em</label><valor>'         ||vr_dsdtefet||'</valor></dados_campo>'
                     || '<dados_campo><label>Tipo do Agendamento</label><valor>'  ||(CASE WHEN vr_tpagenda = 0 THEN 'Aplicação' ELSE 'Resgate' END)||'</valor></dados_campo>'
                     || '<dados_campo><label>Documento Agendamento</label><valor>'||vr_docagend||'</valor></dados_campo>';
                  END IF;   
               END IF;
            ELSIF vr_tpopeapl = 5 THEN --Cancelamento Item Agendamento
               IF vr_tpagenda = 0 THEN --Aplicacao
                  vr_xml_auxi := vr_xml_auxi
                  || '<dados_campo><label>Valor da Aplicação</label><valor>'   ||vr_dsvltran||'</valor></dados_campo>'
                  || '<dados_campo><label>Debitar no Dia</label><valor>'       ||vr_dsdtefet||'</valor></dados_campo>'
                  || '<dados_campo><label>Tipo do Agendamento</label><valor>'  ||(CASE WHEN vr_tpagenda = 0 THEN 'Aplicação' ELSE 'Resgate' END)||'</valor></dados_campo>'
                  || '<dados_campo><label>Documento Agendamento</label><valor>'||vr_docagend||'</valor></dados_campo>';   
               ELSE --Resgate
                  vr_xml_auxi := vr_xml_auxi
                  || '<dados_campo><label>Valor do Resgate</label><valor>'     ||vr_dsvltran||'</valor></dados_campo>'
                  || '<dados_campo><label>Data do Resgate</label><valor>'      ||vr_dsdtefet||'</valor></dados_campo>'
                  || '<dados_campo><label>Tipo do Agendamento</label><valor>'  ||(CASE WHEN vr_tpagenda = 0 THEN 'Aplicação' ELSE 'Resgate' END)||'</valor></dados_campo>'
                  || '<dados_campo><label>Documento Agendamento</label><valor>'||vr_docagend||'</valor></dados_campo>';   
               END IF;
            END IF;
         ELSIF vr_tptranpe = 8 THEN --Debito Automatico
            IF vr_tpopconv = 1 THEN --Autorizacao Debito Automatico
               vr_xml_auxi := vr_xml_auxi
               || '<dados_campo><label>Empresa Conveniada</label><valor>'         ||vr_nmrescon||'</valor></dados_campo>'
               || '<dados_campo><label>Identificação do Consumidor</label><valor>'||vr_iddebaut||'</valor></dados_campo>'
               || '<dados_campo><label>Histórico Complementar</label><valor>'     ||vr_dshistor||'</valor></dados_campo>'
               || '<dados_campo><label>Limite Máximo Para Débito</label><valor>'  ||vr_vlmaxdeb||'</valor></dados_campo>';
            ELSIF vr_tpopconv = 2 OR   --Bloqueio Debito Automatico
                  vr_tpopconv = 3 THEN --Desbloqueio Debito Automatico
               vr_xml_auxi := vr_xml_auxi
               || '<dados_campo><label>Empresa Conveniada</label><valor>' ||vr_nmrescon||'</valor></dados_campo>'
               || '<dados_campo><label>Data do Débito</label><valor>'     ||vr_dtdebfat||'</valor></dados_campo>'
               || '<dados_campo><label>Valor do Débito</label><valor>'    ||vr_vllanaut||'</valor></dados_campo>'
               || '<dados_campo><label>Documento do Débito</label><valor>'||vr_nrdocfat||'</valor></dados_campo>';
            END IF;
         ELSIF vr_tptranpe = 9 THEN --Folha de Pagamento
            vr_xml_auxi := vr_xml_auxi
            || '<dados_campo><label>Valor do Pagamento</label><valor>'       ||vr_dsvltran||'</valor></dados_campo>'
            || '<dados_campo><label>Quantidade de Lançamentos</label><valor>'||vr_nrqtlnac||'</valor></dados_campo>'
            || '<dados_campo><label>Solicitado Estouro</label><valor>'       ||vr_solestou||'</valor></dados_campo>'
            || '<dados_campo><label>Data de Débito</label><valor>'           ||vr_dsdtefet||'</valor></dados_campo>'
            || '<dados_campo><label>Valor da Tarifa</label><valor>'          ||vr_vltarifa||'</valor></dados_campo>';
		     ELSIF vr_tptranpe = 10 THEN --Pacote de Tarifas
            vr_xml_auxi := vr_xml_auxi
            || '<dados_campo><label>Serviço</label><valor>'            ||vr_dspacote||'</valor></dados_campo>'
            || '<dados_campo><label>Valor</label><valor>'             ||vr_vlpacote||'</valor></dados_campo>'
            || '<dados_campo><label>Dia do Débito</label><valor>'     ||vr_dtdiadeb||'</valor></dados_campo>'
            || '<dados_campo><label>Início da Vigência</label><valor>'||vr_dtinivig||'</valor></dados_campo>';
         ELSIF vr_tptranpe = 11 THEN --Pagamento DARF/DAS
            vr_xml_auxi := vr_xml_auxi
            || '<dados_campo><label>Representante ou Operador</label><valor>'||vr_nmagenda||'</valor></dados_campo>'
            || '<dados_campo><label>Data da Transação</label><valor>'||vr_dttranpe||'</valor></dados_campo>'
            || '<dados_campo><label>Hora da Transação</label><valor>'||vr_hrtranpe||'</valor></dados_campo>'
            || '<dados_campo><label>Data de Movimentação</label><valor>'||vr_dtmvttra||'</valor></dados_campo>'
            || '<dados_campo><label>Situação</label><valor>'||vr_dssittra||'</valor></dados_campo>'
            || '<dados_campo><label>Tipo de Transação</label><valor>'|| vr_dsdescri ||'</valor></dados_campo>'
            || '<dados_campo><label>Origem da Transação</label><valor>'||vr_dsoritra||'</valor></dados_campo>';
            
            IF vr_dtreptra IS NOT NULL THEN
              vr_xml_auxi := vr_xml_auxi || '<dados_campo><label>Data da Reprovação</label><valor>'||vr_dtreptra||'</valor></dados_campo>';
            END IF;
            
            IF vr_dtexctra IS NOT NULL THEN
              vr_xml_auxi := vr_xml_auxi || '<dados_campo><label>Data da Exclusão</label><valor>'||vr_dtexctra||'</valor></dados_campo>';
            END IF;
            
            IF vr_dtexptra IS NOT NULL THEN
              vr_xml_auxi := vr_xml_auxi || '<dados_campo><label>Data da Expiração</label><valor>'||vr_dtexptra||'</valor></dados_campo>';
            END IF;
            
            IF vr_dscritra IS NOT NULL THEN
              vr_xml_auxi := vr_xml_auxi || '<dados_campo><label>Crítica de Validação</label><valor>'||vr_dscritra||'</valor></dados_campo>';
            END IF;

            IF vr_dscritra IS NOT NULL THEN
              vr_xml_auxi := vr_xml_auxi || '<dados_campo><label>Data da Validação</label><valor>'||vr_dtvalida||'</valor></dados_campo>';
            END IF;

            vr_xml_auxi := vr_xml_auxi || '<dados_campo><label>Tipo de Captura</label><valor>'||vr_dstipcapt||'</valor></dados_campo>';
            
            IF vr_dsdescri IS NOT NULL THEN
              vr_xml_auxi := vr_xml_auxi || '<dados_campo><label>Identificação do Pagamento</label><valor>'||vr_dsdescri||'</valor></dados_campo>';
            END IF;
            
            IF vr_dsnomfone IS NOT NULL THEN
              vr_xml_auxi := vr_xml_auxi|| '<dados_campo><label>Nome e Telefone</label><valor>'||vr_dsnomfone||'</valor></dados_campo>';
            END IF;

            IF vr_tpcaptura = 1 THEN
              vr_xml_auxi := vr_xml_auxi
              || '<dados_campo><label>Código de Barras</label><valor>'||vr_dscod_barras||'</valor></dados_campo>'
              || '<dados_campo><label>Linha Digitável</label><valor>'||vr_dslinha_digitavel||'</valor></dados_campo>';
            ELSIF vr_tpcaptura = 2 THEN
              vr_xml_auxi := vr_xml_auxi
              || '<dados_campo><label>Período de Apuração</label><valor>'||vr_dtapuracao||'</valor></dados_campo>'
              || '<dados_campo><label>Número do CPF ou CNPJ</label><valor>'||vr_nrcpfcgc||'</valor></dados_campo>'
              || '<dados_campo><label>Código da Receita</label><valor>'||vr_cdtributo||'</valor></dados_campo>';
              
              IF vr_nrrefere IS NOT NULL THEN
                vr_xml_auxi := vr_xml_auxi || '<dados_campo><label>Número de Referência</label><valor>'||vr_nrrefere||'</valor></dados_campo>';
              END IF;

              vr_xml_auxi := vr_xml_auxi   
              || '<dados_campo><label>Data de Vencimento</label><valor>'||vr_dtvencto||'</valor></dados_campo>'
              || '<dados_campo><label>Valor do Principal</label><valor>'||vr_vlprincipal||'</valor></dados_campo>'
              || '<dados_campo><label>Valor da Multa</label><valor>'||vr_vlmulta||'</valor></dados_campo>'
              || '<dados_campo><label>Valor dos Juros</label><valor>'||vr_vljuros||'</valor></dados_campo>';
            END IF;

            vr_xml_auxi := vr_xml_auxi || '<dados_campo><label>Valor Total</label><valor>'||vr_vlrtotal||'</valor></dados_campo>';           

            IF vr_tpcaptura = 2 THEN
              IF vr_vlreceita_bruta IS NOT NULL THEN
                vr_xml_auxi := vr_xml_auxi || '<dados_campo><label>Receita Bruta Acumulada</label><valor>'||vr_vlreceita_bruta||'</valor></dados_campo>';
              END IF;
              IF vr_vlpercentual IS NOT NULL THEN
                vr_xml_auxi := vr_xml_auxi || '<dados_campo><label>Percentual (retornar se estiver preenchido)</label><valor>'||vr_vlpercentual||'</valor></dados_campo>';
              END IF;
            END IF;            

            vr_xml_auxi := vr_xml_auxi
            || '<dados_campo><label>Débito Em</label><valor>'||vr_dtdebito||'</valor></dados_campo>'
            || '<dados_campo><label>Indicador de Agendamento</label><valor>'||vr_idagendamento||'</valor></dados_campo>';

         END IF;
         
         vr_xml_auxi := vr_xml_auxi || '</dados_detalhe>';
         
				 vr_xml_auxi := vr_xml_auxi || '<aprovadores>';
         vr_nmagenda := '';

         FOR rw_tbaprova_rep IN cr_tbaprova_rep (pr_cdtransa  => vr_cdtranpe) LOOP
           
           vr_ind := vr_tab_crapavt.FIRST;
           WHILE vr_ind IS NOT NULL LOOP
             -- Operação realizada por responsável da assinatura conjunta
             IF vr_tab_crapavt(vr_ind).nrcpfcgc = rw_tbaprova_rep.cpf_responsavel THEN
               vr_nmagenda := vr_tab_crapavt(vr_ind).nmdavali;
               EXIT;
             END IF;
             vr_ind := vr_tab_crapavt.NEXT(vr_ind);
           END LOOP;

           vr_xml_auxi := vr_xml_auxi || '<aprovador><nmaprova>' || TO_CHAR(NVL(vr_nmagenda,TO_CHAR(rw_tbaprova_rep.cpf_responsavel) || '-' || 'APROVADOR NAO CADASTRADO')) || '</nmaprova>'
                                      || '<situacao>' || rw_tbaprova_rep.situacao || '</situacao></aprovador>';

         END LOOP;

         vr_xml_auxi := vr_xml_auxi || '</aprovadores></transacao>';	
				 
         --Dados Detalhados da transacao
         gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                                ,pr_texto_completo => vr_xml_temp 
                                ,pr_texto_novo     => vr_xml_auxi);
                           
			END LOOP;
      --Fim loop de transacoes
      
      --Montar Tag de fechamento das transacoes pendentes
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '</transacoes>');
      
      --Montar Tag Xml de Total
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '<total>'
                                                || '  <quantidade>'||vr_qttotpen||'</quantidade>'
                                                || '  <valortotal>'||TO_CHAR(vr_vltotpen,'fm999g999g990d00')||'</valortotal>'
                                                || '</total>');
      
      
      -- Encerrar a tag raiz 
      gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '</raiz>' 
                             ,pr_fecha_xml      => TRUE);
                                                 
    EXCEPTION
      WHEN vr_exc_erro THEN
        ROLLBACK;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Consulta de Transacoes Pendentes INET0002.pc_busca_trans_pend: ' || SQLERRM;
        ROLLBACK;
    END;

  END pc_busca_trans_pend;
    
  --> Rotina responsavel pela criacao de transacoes pendentes de DARF/DAS
  PROCEDURE pc_cria_trans_pend_darf_das(pr_cdcooper  IN crapcop.cdcooper%TYPE                 --> Código da cooperativa
                                       ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE                 --> Numero do Caixa
                                       ,pr_cdoperad  IN crapope.cdoperad%TYPE                 --> Codigo do Operados
                                       ,pr_nmdatela  IN craptel.nmdatela%TYPE                 --> Nome da Tela
                                       ,pr_cdagenci  IN crapage.cdagenci%TYPE                 --> Código do PA
                                       ,pr_nrdconta  IN crapass.nrdconta%TYPE                 --> Número da conta
                                       ,pr_idseqttl  IN crapttl.idseqttl%TYPE                 --> Sequencial de titularidade
                                       ,pr_nrcpfrep  IN crapopi.nrcpfope%TYPE                 --> Numero do cpf do representante legal
                                       ,pr_cdcoptfn  IN tbgen_trans_pend.cdcoptfn%TYPE        --> Cooperativa do Terminal
                                       ,pr_cdagetfn  IN tbgen_trans_pend.cdagetfn%TYPE        --> Agencia do Terminal
                                       ,pr_nrterfin  IN tbgen_trans_pend.nrterfin%TYPE        --> Numero do Terminal Financeiro
                                       ,pr_nrcpfope  IN NUMBER								                --> CPF do operador PJ
                                       ,pr_idorigem  IN INTEGER							                  --> Canal de origem da operação
                                       ,pr_dtmvtolt  IN DATE                                  --> Data de Movimento Atual
                                       ,pr_tpdaguia  IN INTEGER							                  --> Tipo da guia (1 – DARF / 2 – DAS)
                                       ,pr_tpcaptur  IN INTEGER							                  --> Tipo de captura da guia (1 – Código Barras / 2 – Manual)
                                       ,pr_lindigi1  IN NUMBER							                  --> Primeiro campo da linha digitável da guia
                                       ,pr_lindigi2  IN NUMBER							                  --> Segundo campo da linha digitável da guia
                                       ,pr_lindigi3  IN NUMBER							                  --> Terceiro campo da linha digitável da guia
                                       ,pr_lindigi4  IN NUMBER 							                  --> Quarto campo da linha digitável da guia
                                       ,pr_cdbarras  IN VARCHAR2 						                  --> Código de barras da guia
                                       ,pr_dsidepag  IN VARCHAR2 						                  --> Descrição da identificação do pagamento
                                       ,pr_vlrtotal  IN NUMBER 							                  --> Valor total do pagamento da guia
                                       ,pr_dsnomfon  IN VARCHAR2 						                  --> Nome e telefone da guia
                                       ,pr_dtapurac  IN DATE 								                  --> Período de apuração da guia
                                       ,pr_nrcpfcgc  IN VARCHAR2 						                  --> CPF/CNPJ da guia
                                       ,pr_cdtribut  IN VARCHAR2 						                  --> Código de tributação da guia
                                       ,pr_nrrefere  IN VARCHAR2 						                  --> Número de referência da guia
                                       ,pr_dtvencto  IN DATE 								                  --> Data de vencimento da guia
                                       ,pr_vlrprinc  IN NUMBER 							                  --> Valor principal da guia
                                       ,pr_vlrmulta  IN NUMBER 							                  --> Valor da multa da guia
                                       ,pr_vlrjuros  IN NUMBER 							                  --> Valor dos juros da guia
                                       ,pr_vlrecbru  IN NUMBER 							                  --> Valor da receita bruta acumulada da guia
                                       ,pr_vlpercen  IN NUMBER 							                  --> Valor do percentual da guia
                                       ,pr_dtagenda  IN DATE 								                  --> Data de agendamento
                                       ,pr_idastcjt  IN crapass.idastcjt%TYPE                 --> Indicador de Assinatura Conjunta
                                       ,pr_idagenda  IN tbpagto_trans_pend.idagendamento%TYPE --> Indica se o pagamento foi agendado (1 – Online / 2 – Agendamento)
                                       ,pr_tpleitur  IN NUMBER                                --> Tipo da leitura do documento (1 – Leitora de Código de Barras / 2 - Manual)
                                       ,pr_cdcritic OUT INTEGER 						                  --> Código do erro
                                       ,pr_dscritic OUT VARCHAR2) IS 			                    --> Descriçao do erro 
  
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_cria_trans_pend_darf_das
  --  Sistema  : Rotina responsavel pela criacao de transacoes pendentes de DARF/DAS
  --  Sigla    : CRED
  --  Autor    : Jean Michel
  --  Data     : Julho/2016                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotina responsavel pela criacao de transacoes pendentes de DARF/DAS
  --
  -- Alteração : 
  --
  ---------------------------------------------------------------------------------------------------------------   
    -- Variáveis
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := '';
    vr_cdtranpe tbgen_trans_pend.cdtransacao_pendente%TYPE;
    vr_tab_crapavt CADA0001.typ_tab_crapavt_58; -- Tabela Avalistas 

    -- Variaveis de Excecao
    vr_exc_erro EXCEPTION;

  BEGIN
    INET0002.pc_cria_transacao_operador(pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nmdatela => pr_nmdatela
                                       ,pr_idorigem => pr_idorigem
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrcpfope => pr_nrcpfope
                                       ,pr_nrcpfrep => pr_nrcpfrep
                                       ,pr_cdcoptfn => pr_cdcoptfn
                                       ,pr_cdagetfn => pr_cdagetfn
                                       ,pr_nrterfin => pr_nrterfin
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_cdtiptra => 11          -- DARF/DAS
                                       ,pr_idastcjt => pr_idastcjt
                                       ,pr_tab_crapavt => vr_tab_crapavt
                                       ,pr_cdtranpe => vr_cdtranpe
                                       ,pr_dscritic => vr_dscritic);
                                         
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    BEGIN
      INSERT INTO
        tbpagto_darf_das_trans_pend(
           cdtransacao_pendente
          ,cdcooper
          ,nrdconta
          ,tppagamento
          ,tpcaptura
          ,dsidentif_pagto
          ,dsnome_fone
          ,dscod_barras
          ,dslinha_digitavel
          ,dtapuracao
          ,nrcpfcgc
          ,cdtributo
          ,nrrefere
          ,vlprincipal
          ,vlmulta
          ,vljuros
          ,vlreceita_bruta
          ,vlpercentual
          ,dtvencto
          ,tpleitura_docto
          ,vlpagamento
          ,dtdebito
          ,idagendamento)
        VALUES(
           vr_cdtranpe
          ,pr_cdcooper
          ,pr_nrdconta
          ,pr_tpdaguia
          ,pr_tpcaptur
          ,pr_dsidepag
          ,pr_dsnomfon
          ,pr_cdbarras
          ,(pr_lindigi1 || pr_lindigi2 || pr_lindigi3 || pr_lindigi4)
          ,pr_dtapurac
          ,pr_nrcpfcgc
          ,pr_cdtribut
          ,pr_nrrefere
          ,pr_vlrprinc
          ,pr_vlrmulta
          ,pr_vlrjuros
          ,pr_vlrecbru
          ,pr_vlpercen
          ,pr_dtvencto
          ,pr_tpleitur
          ,pr_vlrtotal
          ,pr_dtagenda  
          ,pr_idagenda);
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao incluir registro tbpagto_darf_das_trans_pend. Erro: ' || SQLERRM;
        RAISE vr_exc_erro;
    END;

    pc_cria_aprova_transpend(pr_cdagenci => pr_cdagenci
                            ,pr_nrdcaixa => pr_nrdcaixa
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_idorigem => pr_idorigem
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrcpfrep => pr_nrcpfrep
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdtiptra => 11         -- DARF/DAS
                            ,pr_tab_crapavt => vr_tab_crapavt
                            ,pr_cdtranpe => vr_cdtranpe
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

    IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    COMMIT;

  EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
    WHEN OTHERS THEN
      -- Erro
      pr_dscritic:= 'Erro na rotina INET002.pc_cria_trans_pend_darf_das. '||sqlerrm; 
  END pc_cria_trans_pend_darf_das;  

  PROCEDURE pc_busca_darf_das(pr_cdcooper IN crapcop.cdcooper%TYPE              --> Código da Cooperativa
                             ,pr_cdoperad IN crapope.cdoperad%TYPE              --> Código do Operador
                             ,pr_nmdatela IN craptel.nmdatela%TYPE              --> Nome da Tela
                             ,pr_idorigem IN INTEGER                            --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                             ,pr_nrdconta IN crapass.nrdconta%TYPE              --> Número da Conta
                             ,pr_idseqttl IN crapttl.idseqttl%TYPE              --> Titular da Conta
                             ,pr_cdtrapen IN VARCHAR2                           --> Codigo da Transacao
                             ,pr_cdcritic OUT INTEGER                           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2                          --> Descrição da crítica
                             ,pr_tab_darf_das OUT INET0002.typ_tab_darf_das) IS --> Tabela com os dados da DARF/DAS

   BEGIN															 
	 /* .............................................................................

     Programa: pc_busca_darf_das
     Sistema : 
     Sigla   : CRED
     Autor   : Jean Michel
     Data    : Julho/2016.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de registros de DARF/DAS.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/												
		
		DECLARE
	
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
			vr_exc_saida EXCEPTION;
            
			-- Declaração da tabela que conterá os dados de DARF/DAS
			vr_tab_darf_das INET0002.typ_tab_darf_das;
			vr_ind_darf_das PLS_INTEGER := 0;

      -- Seleciona registro de DARF/DAS    
	    CURSOR cr_darfdas(pr_nrdconta IN crapass.nrdconta%TYPE) IS 
			  SELECT darf.cdtransacao_pendente AS cdtransacao_pendente
              ,darf.cdcooper             AS cdcooper
              ,darf.nrdconta             AS nrdconta
              ,darf.tppagamento          AS tppagamento
              ,darf.tpcaptura            AS tpcaptura
              ,darf.dsidentif_pagto      AS dsidentif_pagto
              ,darf.dsnome_fone          AS dsnome_fone
              ,darf.dscod_barras         AS dscod_barras
              ,darf.dslinha_digitavel    AS dslinha_digitavel
              ,darf.dtapuracao           AS dtapuracao
              ,darf.nrcpfcgc             AS nrcpfcgc
              ,darf.cdtributo            AS cdtributo
              ,darf.nrrefere             AS nrrefere
              ,darf.vlprincipal          AS vlprincipal
              ,darf.vlmulta              AS vlmulta
              ,darf.vljuros              AS vljuros
              ,darf.vlreceita_bruta      AS vlreceita_bruta
              ,darf.vlpercentual         AS vlpercentual
              ,darf.dtvencto             AS dtvencto
              ,darf.tpleitura_docto      AS tpleitura_docto
              ,darf.vlpagamento          AS vlpagamento
              ,darf.dtdebito             AS dtdebito
              ,darf.idagendamento        AS idagendamento
              ,ROWID
				  FROM tbpagto_darf_das_trans_pend darf
         WHERE darf.nrdconta = pr_nrdconta OR pr_nrdconta = 0
          AND (pr_cdtrapen IS NULL OR (darf.cdtransacao_pendente IN (SELECT regexp_substr(pr_cdtrapen, '[^;]+', 1, ROWNUM) parametro
               FROM dual CONNECT BY LEVEL <= LENGTH(regexp_replace(pr_cdtrapen ,'[^;]+','')) + 1)));

			rw_darfdas cr_darfdas%ROWTYPE;
			
			-- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
	  BEGIN
			
			-- Para cada registro de DARF/DAS
			FOR rw_darfdas IN cr_darfdas(pr_nrdconta => pr_nrdconta) LOOP      

	      -- Buscar qual a quantidade atual de registros na tabela para posicionar na próxima
	      vr_ind_darf_das := vr_tab_darf_das.COUNT() + 1;

			  vr_tab_darf_das(vr_ind_darf_das).cdtransacao_pendente := rw_darfdas.cdtransacao_pendente;
        vr_tab_darf_das(vr_ind_darf_das).cdcooper							:= rw_darfdas.cdcooper;
        vr_tab_darf_das(vr_ind_darf_das).nrdconta             := rw_darfdas.nrdconta;
        vr_tab_darf_das(vr_ind_darf_das).tppagamento          := rw_darfdas.tppagamento;
        vr_tab_darf_das(vr_ind_darf_das).tpcaptura            := rw_darfdas.tpcaptura;
        vr_tab_darf_das(vr_ind_darf_das).dsidentif_pagto      := rw_darfdas.dsidentif_pagto;
        vr_tab_darf_das(vr_ind_darf_das).dsnome_fone          := rw_darfdas.dsnome_fone;
        vr_tab_darf_das(vr_ind_darf_das).dscod_barras         := rw_darfdas.dscod_barras;
        vr_tab_darf_das(vr_ind_darf_das).dslinha_digitavel    := rw_darfdas.dslinha_digitavel;
        vr_tab_darf_das(vr_ind_darf_das).dtapuracao           := rw_darfdas.dtapuracao;
        vr_tab_darf_das(vr_ind_darf_das).nrcpfcgc             := rw_darfdas.nrcpfcgc;
        vr_tab_darf_das(vr_ind_darf_das).cdtributo            := rw_darfdas.cdtributo;
        vr_tab_darf_das(vr_ind_darf_das).nrrefere             := rw_darfdas.nrrefere;
        vr_tab_darf_das(vr_ind_darf_das).vlprincipal          := rw_darfdas.vlprincipal;
        vr_tab_darf_das(vr_ind_darf_das).vlmulta              := rw_darfdas.vlmulta;
        vr_tab_darf_das(vr_ind_darf_das).vljuros              := rw_darfdas.vljuros;
        vr_tab_darf_das(vr_ind_darf_das).vlreceita_bruta      := rw_darfdas.vlreceita_bruta;
        vr_tab_darf_das(vr_ind_darf_das).vlpercentual         := rw_darfdas.vlpercentual;
        vr_tab_darf_das(vr_ind_darf_das).dtvencto             := rw_darfdas.dtvencto;
        vr_tab_darf_das(vr_ind_darf_das).tpleitura_docto      := rw_darfdas.tpleitura_docto;
        vr_tab_darf_das(vr_ind_darf_das).vlpagamento          := rw_darfdas.vlpagamento;
        vr_tab_darf_das(vr_ind_darf_das).dtdebito             := rw_darfdas.dtdebito;
        vr_tab_darf_das(vr_ind_darf_das).idagendamento        := rw_darfdas.idagendamento;
        vr_tab_darf_das(vr_ind_darf_das).idrowid              := rw_darfdas.ROWID;				
			END LOOP; -- FOR rw_darfdas

			-- Alimenta parâmetro com a PL/Table gerada
			pr_tab_darf_das := vr_tab_darf_das;
						
		EXCEPTION
			WHEN vr_exc_saida THEN
				
        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
				END IF;

			  -- Alimenta parametros com as críticas
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na INET0002.pc_busca_darf_das: ' || SQLERRM;
		END;
	END pc_busca_darf_das;

  PROCEDURE pc_busca_darf_das_car(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                 ,pr_cdoperad IN crapope.cdoperad%TYPE --> Código do Operador
                                 ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da Tela
                                 ,pr_idorigem IN INTEGER               --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta
                                 ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Titular da Conta
                                 ,pr_cdtrapen IN VARCHAR2              --> Codigo da Transacao
												    		 ,pr_clobxmlc OUT CLOB                 --> XML com informações de LOG
												 	 	 		 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
														 		 ,pr_dscritic OUT VARCHAR2) IS         --> Descrição da crítica

		BEGIN
	 /* .............................................................................

     Programa: pc_busca_darf_das_car
     Sistema : 
     Sigla   : CRED
     Autor   : Jean Michel
     Data    : Julho/2016.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de DARF/DAS

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/												
		DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Declaração da tabela que conterá os dados de DARF/DAS
			vr_tab_darf_das INET0002.typ_tab_darf_das;
			vr_ind_darf_das PLS_INTEGER := 0;

      -- Variaveis de XML 
      vr_xml_temp VARCHAR2(32767);
 
    BEGIN
      
		  -- Procedure para buscar informações da aplicação
      INET0002.pc_busca_darf_das(pr_cdcooper => pr_cdcooper           --> Código da Cooperativa
                                ,pr_cdoperad => pr_cdoperad           --> Código do Operador
                                ,pr_nmdatela => pr_nmdatela           --> Nome da Tela
                                ,pr_idorigem => pr_idorigem           --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                ,pr_nrdconta => pr_nrdconta           --> Número da Conta
                                ,pr_idseqttl => pr_idseqttl           --> Titular da Conta 		
                                ,pr_cdtrapen => pr_cdtrapen           --> Codigo da Transacao														 
                                ,pr_cdcritic => vr_cdcritic           --> Código da crítica
                                ,pr_dscritic => vr_dscritic           --> Descrição da crítica
                                ,pr_tab_darf_das => vr_tab_darf_das); --> Tabela com os dados de DARF/DAS
																					
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
			
			IF vr_tab_darf_das.count() > 0 THEN
				-- Percorre todas as DARF/DAS
				FOR vr_contador IN vr_tab_darf_das.FIRST..vr_tab_darf_das.LAST LOOP
					-- Montar XML com registros de DARF/DAS
					gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
																 ,pr_texto_completo => vr_xml_temp 
																 ,pr_texto_novo     => '<darf>'
                                                      || '<cdtransacao_pendente>' || vr_tab_darf_das(vr_contador).cdtransacao_pendente || '</cdtransacao_pendente>'
                                                      || '<cdcooper>'             || vr_tab_darf_das(vr_contador).cdcooper             || '</cdcooper>'
                                                      || '<nrdconta>'             || vr_tab_darf_das(vr_contador).nrdconta             || '</nrdconta>'
                                                      || '<tppagamento>'          || vr_tab_darf_das(vr_contador).tppagamento          || '</tppagamento>'
                                                      || '<tpcaptura>'            || vr_tab_darf_das(vr_contador).tpcaptura            || '</tpcaptura>'
                                                      || '<dsidentif_pagto>'      || vr_tab_darf_das(vr_contador).dsidentif_pagto      || '</dsidentif_pagto>'
                                                      || '<dsnome_fone>'          || vr_tab_darf_das(vr_contador).dsnome_fone          || '</dsnome_fone>'
                                                      || '<dscod_barras>'         || vr_tab_darf_das(vr_contador).dscod_barras         || '</dscod_barras>'
                                                      || '<dslinha_digitavel>'    || vr_tab_darf_das(vr_contador).dslinha_digitavel    || '</dslinha_digitavel>'
                                                      || '<dtapuracao>'           || vr_tab_darf_das(vr_contador).dtapuracao           || '</dtapuracao>'
                                                      || '<nrcpfcgc>'             || vr_tab_darf_das(vr_contador).nrcpfcgc             || '</nrcpfcgc>'
                                                      || '<cdtributo>'            || vr_tab_darf_das(vr_contador).cdtributo            || '</cdtributo>'
                                                      || '<nrrefere>'             || vr_tab_darf_das(vr_contador).nrrefere             || '</nrrefere>'
                                                      || '<vlprincipal>'          || vr_tab_darf_das(vr_contador).vlprincipal          || '</vlprincipal>'
                                                      || '<vlmulta>'              || vr_tab_darf_das(vr_contador).vlmulta              || '</vlmulta>'
                                                      || '<vljuros>'              || vr_tab_darf_das(vr_contador).vljuros              || '</vljuros>'
                                                      || '<vlreceita_bruta>'      || vr_tab_darf_das(vr_contador).vlreceita_bruta      || '</vlreceita_bruta>'
                                                      || '<vlpercentual>'         || vr_tab_darf_das(vr_contador).vlpercentual         || '</vlpercentual>'
                                                      || '<dtvencto>'             || vr_tab_darf_das(vr_contador).dtvencto             || '</dtvencto>'
                                                      || '<tpleitura_docto>'      || vr_tab_darf_das(vr_contador).tpleitura_docto      || '</tpleitura_docto>'
                                                      || '<vlpagamento>'          || vr_tab_darf_das(vr_contador).vlpagamento          || '</vlpagamento>'
                                                      || '<dtdebito>'             || vr_tab_darf_das(vr_contador).dtdebito             || '</dtdebito>'
                                                      || '<idagendamento>'        || vr_tab_darf_das(vr_contador).idagendamento        || '</idagendamento>'
                                                      || '<idrowid>'              || vr_tab_darf_das(vr_contador).idrowid              || '</idrowid>'
																										|| '</darf>');
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
        pr_dscritic := 'Erro nao tratado na busca de aplicacoes INET0002.pc_busca_darf_das_car: ' || SQLERRM;

    END;
  END pc_busca_darf_das_car;

END INET0002;
/
